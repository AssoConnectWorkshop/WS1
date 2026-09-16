import Link from "next/link";
import { redirect } from "next/navigation";
import { parametresVue } from "@/lib/vues-tableau-de-bord";
import { createClient } from "@/lib/supabase/server";
import { parseListParams, toStringParams, toArrayParam } from "@/lib/list-params";
import { appliquerFiltresInterventions, chaineFiltres } from "@/lib/interventions-filtres";
import { DataTable, type Column } from "@/components/ui/DataTable";
import { Badge } from "@/components/ui/Badge";
import { typeInterventionTone, statutInterventionTone } from "@/lib/badges";
import { formatDate } from "@/lib/format";

export const dynamic = "force-dynamic";

type InterventionRow = {
  id: number;
  numero_bon: number | null;
  site_id: number;
  numero_magasin: number | null;
  site_nom: string | null;
  site_ville: string | null;
  client_id: number;
  client_nom: string | null;
  type_code: number | null;
  type_libelle: string | null;
  sous_type_libelle: string | null;
  statut_code: number | null;
  statut_libelle: string | null;
  intervenant_nom: string | null;
  statut_facturation_libelle: string | null;
  non_facturable: boolean | null;
  date_demande: string | null;
  date_limite: string | null;
  date_prevue: string | null;
  date_realisee: string | null;
  site_date_derniere_visite_entretien: string | null;
  reference_client: string | null;
  objet: string | null;
  devis_a_faire: boolean | null;
  devis_fait: boolean | null;
  urgence_devis: number | null;
  duplicata_traite: boolean | null;
  duplicata_traite_par_nom: string | null;
  commentaire_devis: string | null;
  commentaire_interne: string | null;
  numero_devis_accepte: string | null;
  zone_libelle: string | null;
  charge_affaire_nom: string | null;
};

const URGENCES: Record<number, string> = { 1: "Faible", 2: "Moyenne", 3: "Forte" };
const CHAMP = "w-full rounded border bg-white px-1.5 py-0.5 text-xs dark:bg-white/5";
const BOUTON = "rounded border bg-white px-2 py-1 text-xs dark:bg-white/5";

function Coche({ valeur, label }: { valeur: boolean | null | undefined; label: string }) {
  return <input type="checkbox" readOnly checked={!!valeur} aria-label={label} />;
}

function Tronque({ texte, largeur = "max-w-[14rem]" }: { texte: string | null; largeur?: string }) {
  return (
    <span className={`block truncate ${largeur}`} title={texte ?? undefined}>
      {texte ?? ""}
    </span>
  );
}

/** Liste générale des interventions Access (Form_ListeInterventionGenerale, analysis 02 §8.1) : filtres et colonnes dans l'ordre de la capture. */
export default async function InterventionsPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const raw = await searchParams;
  const sp = toStringParams(raw);
  // Les entrées du menu (?vue=) deviennent des filtres visibles : même liste partout une fois tout décoché.
  if (sp.vue) {
    const p = parametresVue(sp.vue);
    redirect(p ? `/interventions?${new URLSearchParams(p).toString()}` : "/interventions");
  }
  const zonesSel = toArrayParam(raw.zones);
  const supabase = await createClient();

  const [{ data: types }, { data: statuts }, { data: statutsFacturation }, { data: zones }, { data: donneurs }, { data: intervenants }, { data: clients }] =
    await Promise.all([
      supabase.from("types_intervention").select("code, libelle").order("ordre_affichage"),
      supabase.from("statuts_intervention").select("code, libelle").eq("actif", true).order("ordre_affichage"),
      supabase.from("statuts_facturation").select("code, libelle").order("ordre_affichage"),
      supabase.from("zones_geographiques").select("id, libelle").order("libelle"),
      supabase.from("donneurs_ordre").select("id, nom").order("nom"),
      supabase.from("intervenants").select("id, nom").order("nom"),
      supabase.from("clients").select("id, nom").eq("actif", true).is("supprime_le", null).order("nom"),
    ]);

  const { page, sort, dir, from, to, pageSize } = parseListParams(sp, "date_limite", 50);

  // Comptage estimé (planificateur) : le comptage exact sur 71 000 lignes jointes dépasse le délai PostgREST.
  let query = supabase.from("v_interventions_liste").select("*", { count: "estimated" });
  query = appliquerFiltresInterventions(query, sp, zonesSel);
  query = query.order(sort, { ascending: dir === "asc" }).range(from, to);

  const { data, count, error } = await query;
  if (error) console.error("v_interventions_liste", error);
  const rows = (data ?? []) as InterventionRow[];

  let sommeMinutes: number | null = null;
  if (sp.statut === "10") {
    let sumQuery = supabase.from("v_interventions_liste").select("minutes_telephone");
    sumQuery = appliquerFiltresInterventions(sumQuery, sp, zonesSel);
    const { data: sumRows } = await sumQuery;
    sommeMinutes = (sumRows ?? []).reduce((acc, r) => acc + (r.minutes_telephone ?? 0), 0);
  }

  const ids = rows.map((r) => r.id);
  const techniciensParIntervention = new Map<number, string[]>();
  if (ids.length > 0) {
    const { data: techRows } = await supabase.from("intervention_techniciens").select("intervention_id, utilisateurs(nom, prenom)").in("intervention_id", ids);
    for (const t of (techRows ?? []) as unknown as { intervention_id: number; utilisateurs: { nom: string | null; prenom: string | null } | null }[]) {
      const nom = [t.utilisateurs?.prenom, t.utilisateurs?.nom].filter(Boolean).join(" ");
      if (!nom) continue;
      const list = techniciensParIntervention.get(t.intervention_id) ?? [];
      list.push(nom);
      techniciensParIntervention.set(t.intervention_id, list);
    }
  }

  const columns: Column<InterventionRow>[] = [
    { key: "statut_facturation_libelle", label: "Statut Factur", render: (r) => <Tronque texte={r.statut_facturation_libelle} largeur="max-w-[7rem]" /> },
    { key: "non_facturable", label: "Non Fact.", align: "center", render: (r) => <Coche valeur={r.non_facturable} label="Non facturable" /> },
    { key: "date_demande", label: "Date appel", sortable: true, render: (r) => formatDate(r.date_demande).replace("—", "") },
    { key: "site_date_derniere_visite_entretien", label: "Date dern. visite", render: (r) => formatDate(r.site_date_derniere_visite_entretien).replace("—", "") },
    { key: "date_prevue", label: "Date prév", sortable: true, render: (r) => formatDate(r.date_prevue).replace("—", "") },
    { key: "duplicata_traite_par_nom", label: "Duplicata à Traiter", render: (r) => r.duplicata_traite_par_nom ?? "" },
    { key: "duplicata_traite", label: "Attente offre", align: "center", render: (r) => <Coche valeur={r.duplicata_traite} label="Traité / attente offre de prix" /> },
    { key: "client_nom", label: "Client", sortable: true, render: (r) => <Link className="hover:underline" href={`/clients/${r.client_id}`}>{r.client_nom}</Link> },
    { key: "reference_client", label: "N° DI Client", render: (r) => r.reference_client ?? "" },
    { key: "type_libelle", label: "Type", render: (r) => <Badge tone={typeInterventionTone(r.type_code)}>{r.type_libelle ?? "—"}</Badge> },
    { key: "objet", label: "Commentaire client", render: (r) => <Tronque texte={r.objet} /> },
    { key: "sous_type_libelle", label: "Sous Type", render: (r) => r.sous_type_libelle ?? "" },
    { key: "devis_a_faire", label: "Devis à faire", align: "center", render: (r) => <Coche valeur={r.devis_a_faire} label="Devis à faire" /> },
    { key: "urgence_devis", label: "Urgence Devis", render: (r) => (r.urgence_devis ? URGENCES[r.urgence_devis] ?? String(r.urgence_devis) : "") },
    { key: "commentaire_devis", label: "Comm. Devis", render: (r) => <Tronque texte={r.commentaire_devis} largeur="max-w-[10rem]" /> },
    { key: "numero_devis_accepte", label: "N° Devis accepté", render: (r) => r.numero_devis_accepte ?? "" },
    { key: "statut_libelle", label: "Statut", render: (r) => <Badge tone={statutInterventionTone(r.statut_code)}>{r.statut_libelle ?? "—"}</Badge> },
    {
      key: "site_nom",
      label: "Site",
      sortable: true,
      render: (r) => (
        <Link className="block max-w-[16rem] truncate hover:underline" href={`/interventions/${r.id}`} title="Ouvrir l'intervention">
          {r.site_nom}
        </Link>
      ),
    },
    { key: "date_limite", label: "Date limite", sortable: true, render: (r) => formatDate(r.date_limite).replace("—", "") },
    { key: "date_realisee", label: "Effectuée le", sortable: true, render: (r) => formatDate(r.date_realisee).replace("—", "") },
    { key: "intervenant_nom", label: "Intervenant", render: (r) => r.intervenant_nom ?? "" },
    { key: "techniciens", label: "Nom Tech", render: (r) => <Tronque texte={techniciensParIntervention.get(r.id)?.join(", ") ?? null} largeur="max-w-[10rem]" /> },
    { key: "devis_fait", label: "Devis fait", align: "center", render: (r) => <Coche valeur={r.devis_fait} label="Devis fait" /> },
    { key: "commentaire_interne", label: "Comm. Inter.", render: (r) => <Tronque texte={r.commentaire_interne} /> },
    { key: "zone_libelle", label: "Zone", render: (r) => r.zone_libelle ?? "" },
    { key: "site_ville", label: "Ville", render: (r) => r.site_ville ?? "" },
    { key: "numero_magasin", label: "N° Site", align: "right", render: (r) => r.numero_magasin ?? "" },
    { key: "numero_bon", label: "N° Bon", align: "right", render: (r) => r.numero_bon ?? "" },
    { key: "charge_affaire_nom", label: "Traitée par", render: (r) => r.charge_affaire_nom ?? "" },
  ];

  const LIGNE = "grid grid-cols-[9rem_1fr] items-center gap-x-2 gap-y-1 text-xs";
  const option = (rows: { value: string; label: string }[]) =>
    rows.map((o) => (
      <option key={o.value} value={o.value}>
        {o.label}
      </option>
    ));
  const CASE = "flex items-center gap-1 text-xs";

  return (
    <div className="flex flex-col gap-3 p-4">
      <form method="GET" className="grid gap-3 rounded border p-3 lg:grid-cols-[20rem_12rem_14rem_1fr]">
        {/* Bloc gauche : critères principaux */}
        <div className={LIGNE}>
          <span className="text-right">Client</span>
          <select name="client_id" defaultValue={sp.client_id ?? ""} className={CHAMP}>
            <option value=""></option>
            {option((clients ?? []).map((c) => ({ value: String(c.id), label: c.nom ?? "" })))}
          </select>
          <span className="text-right">N° Site ou Nom du site</span>
          <input name="site" defaultValue={sp.site ?? ""} className={CHAMP} />
          <span className="text-right">Statut Intervention</span>
          <select name="statut" defaultValue={sp.statut ?? ""} className={CHAMP}>
            <option value=""></option>
            {option((statuts ?? []).map((s) => ({ value: String(s.code), label: s.libelle })))}
          </select>
          <span className="text-right">Statut Facturation</span>
          <select name="facturation" defaultValue={sp.facturation ?? ""} className={CHAMP}>
            <option value=""></option>
            {option((statutsFacturation ?? []).map((s) => ({ value: String(s.code), label: s.libelle })))}
          </select>
          <span className="text-right">Intervenant</span>
          <select name="intervenant" defaultValue={sp.intervenant ?? ""} className={CHAMP}>
            <option value=""></option>
            {option((intervenants ?? []).map((i) => ({ value: String(i.id), label: i.nom ?? "" })))}
          </select>
          <span className="text-right">Donneur d&apos;ordres</span>
          <select name="donneur" defaultValue={sp.donneur ?? ""} className={CHAMP}>
            <option value=""></option>
            {option((donneurs ?? []).map((d) => ({ value: String(d.id), label: d.nom ?? "" })))}
          </select>
        </div>

        {/* Zone (liste multi-sélection) */}
        <label className="flex flex-col gap-1 text-xs">
          <span>Zone</span>
          <select name="zones" multiple size={7} defaultValue={zonesSel} className={`${CHAMP} flex-1`}>
            {option((zones ?? []).map((z) => ({ value: String(z.id), label: z.libelle })))}
          </select>
        </label>

        {/* Clôturées, type, période, date réelle, Rechercher */}
        <div className="flex flex-col gap-1.5 text-xs">
          <label className={CASE}>
            <input type="checkbox" name="clotures" value="1" defaultChecked={sp.clotures === "1"} />
            Afficher les clôturées
          </label>
          <label className="grid grid-cols-[5rem_1fr] items-center gap-1">
            <span>Type Inter.</span>
            <select name="type" defaultValue={sp.type ?? ""} className={CHAMP}>
              <option value="">Toutes</option>
              {option((types ?? []).map((t) => ({ value: String(t.code), label: t.libelle })))}
            </select>
          </label>
          <div className="grid grid-cols-[5rem_1fr_auto_1fr] items-center gap-1">
            <span>Entre le</span>
            <input type="date" name="periode_debut" defaultValue={sp.periode_debut ?? ""} className={CHAMP} />
            <span>et</span>
            <input type="date" name="periode_fin" defaultValue={sp.periode_fin ?? ""} className={CHAMP} />
          </div>
          <label className={`${CASE} rounded border p-1`}>
            <input type="checkbox" name="periode_champ" value="realisee" defaultChecked={sp.periode_champ === "realisee"} />
            Filtre sur date réelle
          </label>
          <div className="flex items-center gap-2">
            <button type="submit" className="rounded border bg-black px-3 py-1 text-white">
              Rechercher
            </button>
            <Link href="/" className="rounded bg-red-600 px-2 py-1 text-white" title="Retour au menu">
              ✕
            </Link>
          </div>
        </div>

        {/* Boutons et cases à cocher */}
        <div className="flex flex-col gap-2 text-xs">
          <div className="flex flex-wrap items-start gap-2">
            <div className="flex flex-col gap-1">
              <Link href="/interventions/nouvelle" className={`${BOUTON} text-center`}>
                Nouvelle intervention
              </Link>
              <a href={`/interventions/liste.xlsx?${chaineFiltres(raw)}`} className={`${BOUTON} text-center`} title="Export Excel de la liste filtrée">
                Imprimer les interventions à réaliser
              </a>
            </div>
            <label className={`${CASE} pt-1`}>
              <input type="checkbox" name="entretien_proche" value="1" defaultChecked={sp.entretien_proche === "1"} />
              Recherche Entretien « Proche »
            </label>
          </div>
          <div className="grid grid-cols-2 gap-x-4 gap-y-1 sm:grid-cols-[10rem_10rem_auto]">
            <label className={CASE}>
              <input type="checkbox" name="photo_faite" value="1" defaultChecked={sp.photo_faite === "1"} />
              Photo
            </label>
            <label className={CASE}>
              <input type="checkbox" name="particulier" value="1" defaultChecked={sp.particulier === "1"} />
              Particulier
            </label>
            <a href={`/interventions/liste.xlsx?${chaineFiltres(raw)}`} className={`${BOUTON} w-fit`}>
              Exporter clients
            </a>
            <label className={CASE}>
              <input type="checkbox" name="audit_fait" value="1" defaultChecked={sp.audit_fait === "1"} />
              Audit
            </label>
            <label className={CASE}>
              <input type="checkbox" name="devis_a_faire" value="1" defaultChecked={sp.devis_a_faire === "1"} />
              Devis à Faire
            </label>
            <span className={`${BOUTON} w-fit opacity-40`} title="Non disponible dans cette version">
              Export Saisie Heures
            </span>
            <label className={CASE}>
              <input type="checkbox" name="registre_maj" value="1" defaultChecked={sp.registre_maj === "1"} />
              MàJ Registre de sécurité
            </label>
            <label className={CASE}>
              <input type="checkbox" name="sous_type_vide" value="1" defaultChecked={sp.sous_type_vide === "1"} />
              SousType Vide
            </label>
            <span />
            <label className={CASE}>
              <input type="checkbox" name="controle_etancheite" value="1" defaultChecked={sp.controle_etancheite === "1"} />
              Contrôle d&apos;étanchéité
            </label>
          </div>
        </div>
      </form>

      <DataTable columns={columns} rows={rows} searchParams={sp} total={count ?? 0} page={page} pageSize={pageSize} emptyMessage="Aucune intervention pour ces filtres." erreur={error?.message} />

      <div className="text-xs opacity-70">
        Enr : {count ?? 0} intervention{(count ?? 0) > 1 ? "s" : ""}
        {sommeMinutes != null && <> · Temps Total Téléphone : {sommeMinutes} min</>}
      </div>
    </div>
  );
}
