import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { parseListParams, toStringParams, toArrayParam } from "@/lib/list-params";
import { appliquerFiltresInterventions, chaineFiltres } from "@/lib/interventions-filtres";
import { DataTable, type Column } from "@/components/ui/DataTable";
import { FilterBar, type FilterField } from "@/components/ui/FilterBar";
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
  statut_code: number | null;
  statut_libelle: string | null;
  intervenant_id: number | null;
  intervenant_nom: string | null;
  statut_facturation_code: number | null;
  statut_facturation_libelle: string | null;
  date_limite: string | null;
  date_prevue: string | null;
  date_realisee: string | null;
  reference_client: string | null;
  devis_a_faire: boolean | null;
  devis_fait: boolean | null;
  commentaire_interne: string | null;
  charge_affaire_nom: string | null;
  minutes_telephone: number | null;
};

export default async function InterventionsPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const raw = await searchParams;
  const sp = toStringParams(raw);
  const zonesSel = toArrayParam(raw.zones);
  const supabase = await createClient();

  const [{ data: types }, { data: statuts }, { data: statutsFacturation }, { data: zones }, { data: donneurs }, { data: intervenants }] =
    await Promise.all([
      supabase.from("types_intervention").select("code, libelle").order("ordre_affichage"),
      supabase.from("statuts_intervention").select("code, libelle").eq("actif", true).order("ordre_affichage"),
      supabase.from("statuts_facturation").select("code, libelle").order("ordre_affichage"),
      supabase.from("zones_geographiques").select("id, libelle").order("libelle"),
      supabase.from("donneurs_ordre").select("id, nom").order("nom"),
      supabase.from("intervenants").select("id, nom").order("nom"),
    ]);

  const { page, sort, dir, from, to, pageSize } = parseListParams(sp, "date_limite", 50);

  let query = supabase.from("v_interventions_liste").select("*", { count: "exact" });
  query = appliquerFiltresInterventions(query, sp, zonesSel);
  query = query.order(sort, { ascending: dir === "asc" }).range(from, to);

  const { data, count } = await query;
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
    const { data: techRows } = await supabase
      .from("intervention_techniciens")
      .select("intervention_id, utilisateurs(nom, prenom)")
      .in("intervention_id", ids);
    for (const t of (techRows ?? []) as unknown as {
      intervention_id: number;
      utilisateurs: { nom: string | null; prenom: string | null } | null;
    }[]) {
      const nom = [t.utilisateurs?.prenom, t.utilisateurs?.nom].filter(Boolean).join(" ");
      if (!nom) continue;
      const list = techniciensParIntervention.get(t.intervention_id) ?? [];
      list.push(nom);
      techniciensParIntervention.set(t.intervention_id, list);
    }
  }

  const filterFields: FilterField[] = [
    { type: "text", name: "client", label: "Client" },
    { type: "text", name: "site", label: "Site (n° ou nom)" },
    { type: "select", name: "type", label: "Type", options: (types ?? []).map((t) => ({ value: String(t.code), label: t.libelle })) },
    { type: "select", name: "statut", label: "Statut", options: (statuts ?? []).map((s) => ({ value: String(s.code), label: s.libelle })) },
    { type: "select", name: "intervenant", label: "Intervenant", options: (intervenants ?? []).map((i) => ({ value: String(i.id), label: i.nom ?? "" })) },
    { type: "select", name: "donneur", label: "Donneur d'ordre", options: (donneurs ?? []).map((d) => ({ value: String(d.id), label: d.nom ?? "" })) },
    { type: "select", name: "facturation", label: "Statut facturation", options: (statutsFacturation ?? []).map((s) => ({ value: String(s.code), label: s.libelle })) },
    { type: "multiselect", name: "zones", label: "Zones", options: (zones ?? []).map((z) => ({ value: String(z.id), label: z.libelle })) },
    { type: "select", name: "periode_champ", label: "Période sur", options: [{ value: "limite", label: "Date limite" }, { value: "realisee", label: "Date réalisée" }] },
    { type: "date", name: "periode_debut", label: "Du" },
    { type: "date", name: "periode_fin", label: "Au" },
    { type: "checkbox", name: "clotures", label: "Afficher les clôturées" },
    { type: "checkbox", name: "devis_a_faire", label: "Devis à faire" },
    { type: "checkbox", name: "audit_fait", label: "Audit fait" },
    { type: "checkbox", name: "controle_etancheite", label: "Contrôle étanchéité" },
    { type: "checkbox", name: "photo_faite", label: "Photo faite" },
    { type: "checkbox", name: "registre_maj", label: "Registre mis à jour" },
    { type: "checkbox", name: "sous_type_vide", label: "Sous-type vide" },
    { type: "checkbox", name: "particulier", label: "Particulier" },
    { type: "checkbox", name: "entretien_proche", label: "Entretien proche" },
  ];

  const columns: Column<InterventionRow>[] = [
    {
      key: "type_libelle",
      label: "Type",
      render: (r) => <Badge tone={typeInterventionTone(r.type_code)}>{r.type_libelle ?? "—"}</Badge>,
    },
    {
      key: "statut_libelle",
      label: "Statut",
      render: (r) => <Badge tone={statutInterventionTone(r.statut_code)}>{r.statut_libelle ?? "—"}</Badge>,
    },
    { key: "client_nom", label: "Client", sortable: true, render: (r) => <Link className="hover:underline" href={`/clients/${r.client_id}`}>{r.client_nom}</Link> },
    { key: "site_nom", label: "Site", sortable: true, render: (r) => <Link className="hover:underline" href={`/sites/${r.site_id}`}>{r.site_nom}</Link> },
    { key: "site_ville", label: "Ville", render: (r) => r.site_ville ?? "—" },
    { key: "date_limite", label: "Date limite", sortable: true, render: (r) => formatDate(r.date_limite) },
    { key: "date_prevue", label: "Date prévue", sortable: true, render: (r) => formatDate(r.date_prevue) },
    { key: "date_realisee", label: "Date réalisée", sortable: true, render: (r) => formatDate(r.date_realisee) },
    { key: "intervenant_nom", label: "Intervenant", render: (r) => r.intervenant_nom ?? "—" },
    { key: "techniciens", label: "Techniciens", render: (r) => techniciensParIntervention.get(r.id)?.join(", ") ?? "—" },
    { key: "charge_affaire_nom", label: "Chargé d'affaire", render: (r) => r.charge_affaire_nom ?? "—" },
    { key: "statut_facturation_libelle", label: "Statut facturation", render: (r) => r.statut_facturation_libelle ?? "—" },
    { key: "reference_client", label: "N° DI client", render: (r) => r.reference_client ?? "—" },
    { key: "numero_bon", label: "N° bon", render: (r) => r.numero_bon ?? "—" },
    {
      key: "devis",
      label: "Devis",
      render: (r) => (r.devis_fait ? "Fait" : r.devis_a_faire ? "À faire" : "—"),
    },
    {
      key: "commentaire_interne",
      label: "Commentaire",
      render: (r) => (
        <span className="block max-w-[16rem] truncate" title={r.commentaire_interne ?? undefined}>
          {r.commentaire_interne ?? "—"}
        </span>
      ),
    },
    {
      key: "actions",
      label: "",
      render: (r) => (
        <Link href={`/interventions/${r.id}`} className="text-xs underline">
          Ouvrir
        </Link>
      ),
    },
  ];

  return (
    <div className="mx-auto flex max-w-7xl flex-col gap-4 p-8">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Interventions</h1>
        <div className="flex gap-2">
          <Link href="/interventions/nouvelle" className="rounded-md bg-black px-3 py-1.5 text-sm text-white">
            Nouvelle intervention
          </Link>
          <a href={`/interventions/liste.xlsx?${chaineFiltres(raw)}`} className="rounded-md border px-3 py-1.5 text-sm">
            Exporter Excel
          </a>
        </div>
      </div>

      <FilterBar fields={filterFields} values={sp} multiValues={{ zones: zonesSel }} />

      <DataTable
        columns={columns}
        rows={rows}
        searchParams={sp}
        total={count ?? 0}
        page={page}
        pageSize={pageSize}
        emptyMessage="Aucune intervention pour ces filtres."
      />

      <div className="text-xs opacity-70">
        Total : {count ?? 0} intervention{(count ?? 0) > 1 ? "s" : ""}
        {sommeMinutes != null && <> · Somme des minutes de téléphone (statut « Résolu par téléphone ») : {sommeMinutes}</>}
      </div>
    </div>
  );
}
