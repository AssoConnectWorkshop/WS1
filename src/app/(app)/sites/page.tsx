import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { parseListParams, toStringParams, mergeRestrict } from "@/lib/list-params";
import { DataTable, type Column } from "@/components/ui/DataTable";
import { FilterBar, type FilterField } from "@/components/ui/FilterBar";
import { formatMontant, formatNombre } from "@/lib/format";
import { STATUT_NE_PLUS_INTERVENIR } from "@/lib/sites";
import { CaseInstantanee } from "@/components/ui/CaseInstantanee";

export const dynamic = "force-dynamic";

type SiteRow = {
  id: number;
  numero_magasin: number | null;
  nom: string | null;
  client_id: number;
  client_nom: string | null;
  adresse: string | null;
  code_postal: string | null;
  ville: string | null;
  zone_libelle: string | null;
  intervenant_nom: string | null;
  donneur_ordre_nom: string | null;
  contrat_clim_numero: string | null;
  contrat_clim_visites_par_an: number | null;
  contrat_clim_redevance: number | null;
  contrat_clim_redevance_secondaire: number | null;
  commentaire_general: string | null;
  rdv_a_prendre: boolean | null;
  code_client: string | null;
  dossier_chemin: string | null;
  intervenant_id: number | null;
  donneur_ordre_id: number | null;
  zone_id: number | null;
  retard_paiement: boolean | null;
  ne_plus_intervenir: boolean | null;
};

/** Liste des sites Access (Form_ListeSiteGenerale, analysis 03 §6.1) : filtres et colonnes dans le même ordre. */
export default async function SitesPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();
  const { page, sort, dir, from, to, pageSize } = parseListParams(sp, "nom_tri", 50);

  const { data: clients } = await supabase.from("clients").select("id, nom").eq("actif", true).is("supprime_le", null).order("nom");

  // Filtres nécessitant une jointure (deux passes : d'abord les site_id concernés).
  let restrictToIds: number[] | null = null;

  if (sp.reference_materiel) {
    const { data } = await supabase.from("site_materiels").select("site_id").ilike("reference", `%${sp.reference_materiel}%`);
    restrictToIds = mergeRestrict(restrictToIds, (data ?? []).map((r) => r.site_id).filter((v): v is number => v != null));
  }
  if (sp.ce_a_editer === "1") {
    const annee = new Date().getFullYear();
    const { data } = await supabase
      .from("site_materiels")
      .select("site_id")
      .eq("certificat_etancheite_edite", false)
      .gte("date_controle_etancheite", `${annee}-01-01`)
      .lte("date_controle_etancheite", `${annee}-12-31`);
    restrictToIds = mergeRestrict(restrictToIds, (data ?? []).map((r) => r.site_id).filter((v): v is number => v != null));
  }
  if (sp.reference_intervention) {
    const { data } = await supabase.from("interventions").select("site_id").ilike("reference_client", `%${sp.reference_intervention}%`);
    restrictToIds = mergeRestrict(restrictToIds, (data ?? []).map((r) => r.site_id));
  }
  if (sp.numero_bon) {
    const { data } = await supabase.from("interventions").select("site_id").eq("numero_bon", Number(sp.numero_bon));
    restrictToIds = mergeRestrict(restrictToIds, (data ?? []).map((r) => r.site_id));
  }
  if (sp.inter_ne_plus_intervenir === "1") {
    const { data } = await supabase.from("interventions").select("site_id").eq("statut_code", STATUT_NE_PLUS_INTERVENIR);
    restrictToIds = mergeRestrict(restrictToIds, Array.from(new Set((data ?? []).map((r) => r.site_id))));
  }

  let query = supabase.from("v_sites_liste").select("*", { count: "exact" });

  if (sp.client) query = query.eq("client_id", Number(sp.client));
  if (sp.q) {
    const n = Number(sp.q);
    query = Number.isFinite(n) && sp.q.trim() !== "" ? query.or(`numero_magasin.eq.${n},nom.ilike.%${sp.q}%`) : query.ilike("nom", `%${sp.q}%`);
  }
  if (sp.code) query = query.ilike("code_client", `%${sp.code}%`);
  if (sp.sans_geoloc === "1") query = query.or("longitude.is.null,latitude.is.null");
  if (sp.non_rooftop === "1") query = query.or("precision_geo.is.null,precision_geo.neq.ROOFTOP");
  if (sp.retard_paiement === "1") query = query.eq("retard_paiement", true);
  if (sp.ne_plus_intervenir === "1") query = query.eq("ne_plus_intervenir", true);
  if (sp.investissement === "1") query = query.eq("investissement", true);
  if (sp.particulier === "1") query = query.eq("particulier", true);
  if (restrictToIds) query = query.in("id", restrictToIds.length ? restrictToIds : [-1]);

  query = query.order(sort, { ascending: dir === "asc" }).range(from, to);
  const { data, count, error } = await query;
  if (error) console.error("v_sites_liste", error);
  const rows = (data ?? []) as SiteRow[];

  const filterFields: FilterField[] = [
    { type: "select", name: "client", label: "Client", options: (clients ?? []).map((c) => ({ value: String(c.id), label: c.nom ?? "" })) },
    { type: "text", name: "q", label: "N° Site ou Nom du site" },
    { type: "text", name: "code", label: "Code" },
    { type: "text", name: "numero_bon", label: "N° de Bon" },
    { type: "text", name: "reference_intervention", label: "N° DI" },
    { type: "checkbox", name: "sans_geoloc", label: "Site sans géoloc" },
    { type: "checkbox", name: "non_rooftop", label: "Site non rooftop" },
    { type: "checkbox", name: "retard_paiement", label: "Retard Paiement" },
    { type: "checkbox", name: "ne_plus_intervenir", label: "Sites « Ne pas intervenir »" },
    { type: "text", name: "reference_materiel", label: "Référence Matériel" },
    { type: "checkbox", name: "investissement", label: "Investissement" },
    { type: "checkbox", name: "particulier", label: "Particulier" },
    { type: "checkbox", name: "ce_a_editer", label: "CE à éditer" },
    { type: "checkbox", name: "inter_ne_plus_intervenir", label: "Inter en cours en « Ne pas intervenir »" },
  ];

  const columns: Column<SiteRow>[] = [
    {
      key: "dossier_chemin",
      label: "Ct",
      render: (r) =>
        r.dossier_chemin ? (
          <span className="block max-w-[4rem] truncate text-blue-700 underline" title={r.dossier_chemin}>
            {r.dossier_chemin}
          </span>
        ) : (
          ""
        ),
    },
    { key: "rdv_a_prendre", label: "RDV à Prendre", align: "center", render: (r) => <CaseInstantanee table="sites" id={r.id} champ="rdv_a_prendre" valeur={r.rdv_a_prendre} label="RDV à prendre" /> },
    { key: "donneur_ordre_nom", label: "Donneur", render: (r) => (r.donneur_ordre_id ? <Link className="hover:underline" href={`/donneurs-ordre/${r.donneur_ordre_id}`}>{r.donneur_ordre_nom}</Link> : "") },
    { key: "intervenant_nom", label: "Intervenant", render: (r) => (r.intervenant_id ? <Link className="hover:underline" href={`/intervenants/${r.intervenant_id}`}>{r.intervenant_nom}</Link> : "") },
    { key: "zone_libelle", label: "Zone", render: (r) => (r.zone_id ? <Link className="hover:underline" href={`/parametrage/zones-geographiques?modifier=${r.zone_id}`}>{r.zone_libelle}</Link> : "") },
    { key: "numero_magasin", label: "N°", sortable: true, align: "right", render: (r) => r.numero_magasin ?? "" },
    { key: "code_client", label: "Co", render: (r) => r.code_client ?? "" },
    { key: "client_nom_tri", label: "Client", sortable: true, render: (r) => <Link className="hover:underline" href={`/clients/${r.client_id}`}>{r.client_nom}</Link> },
    { key: "contrat_clim_numero", label: "Contrat client", render: (r) => r.contrat_clim_numero ?? "" },
    { key: "contrat_clim_redevance", label: "Tarif 1 Cl", align: "right", render: (r) => (r.contrat_clim_redevance != null ? formatMontant(r.contrat_clim_redevance) : "") },
    { key: "contrat_clim_redevance_secondaire", label: "Tarif 2 Cl", align: "right", render: (r) => (r.contrat_clim_redevance_secondaire != null ? formatMontant(r.contrat_clim_redevance_secondaire) : "") },
    { key: "contrat_clim_visites_par_an", label: "Nb Entretien", align: "right", render: (r) => (r.contrat_clim_visites_par_an != null ? formatNombre(r.contrat_clim_visites_par_an) : "") },
    {
      key: "nom_tri",
      label: "Nom",
      sortable: true,
      render: (r) => (
        <Link className={`hover:underline ${r.retard_paiement || r.ne_plus_intervenir ? "font-semibold text-red-700" : ""}`} href={`/sites/${r.id}`}>
          {r.nom}
        </Link>
      ),
    },
    { key: "adresse", label: "Adresse", render: (r) => r.adresse ?? "" },
    { key: "code_postal", label: "CP", sortable: true, render: (r) => r.code_postal ?? "" },
    { key: "ville", label: "Ville", sortable: true, render: (r) => r.ville ?? "" },
    { key: "commentaire_general", label: "Commentaire", render: (r) => <span className="block max-w-md truncate" title={r.commentaire_general ?? ""}>{r.commentaire_general ?? ""}</span> },
  ];

  return (
    <div className="flex flex-col gap-3 p-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold">Sites</h1>
        <Link href="/sites/nouveau" className="rounded-md bg-black px-3 py-2 text-sm text-white">
          Nouveau site
        </Link>
      </div>
      <FilterBar fields={filterFields} values={sp} />
      <DataTable
        columns={columns}
        rows={rows}
        searchParams={sp}
        total={count ?? 0}
        page={page}
        pageSize={pageSize}
        emptyMessage="Aucun site pour ces filtres."
        erreur={error?.message}
        hrefLigne={(r) => `/sites/${r.id}`}
      />
    </div>
  );
}
