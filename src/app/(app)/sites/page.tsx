import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { parseListParams, toStringParams, mergeRestrict } from "@/lib/list-params";
import { DataTable, type Column } from "@/components/ui/DataTable";
import { FilterBar, type FilterField } from "@/components/ui/FilterBar";
import { Badge } from "@/components/ui/Badge";
import { formatDate, formatMontant, formatNombre } from "@/lib/format";

export const dynamic = "force-dynamic";

type SiteRow = {
  id: number;
  numero_magasin: number | null;
  nom: string | null;
  client_id: number;
  client_nom: string | null;
  ville: string | null;
  zone_libelle: string | null;
  intervenant_nom: string | null;
  contrat_clim_visites_par_an: number | null;
  contrat_clim_redevance: number | null;
  contrat_clim_sous_traitant_id: number | null;
  date_derniere_visite_entretien: string | null;
  retard_paiement: boolean | null;
  ne_plus_intervenir: boolean | null;
};

export default async function SitesPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();
  const { page, sort, dir, from, to, pageSize } = parseListParams(sp, "nom", 50);

  // Filtres nécessitant une jointure (deux passes : d'abord les site_id concernés).
  let restrictToIds: number[] | null = null;

  if (sp.reference_materiel) {
    const { data } = await supabase.from("site_materiels").select("site_id").ilike("reference", `%${sp.reference_materiel}%`);
    const ids = (data ?? []).map((r) => r.site_id).filter((v): v is number => v != null);
    restrictToIds = mergeRestrict(restrictToIds, ids);
  }
  if (sp.ce_a_editer === "1") {
    const now = new Date();
    const { data } = await supabase
      .from("site_materiels")
      .select("site_id")
      .eq("certificat_etancheite_edite", false)
      .gte("date_controle_etancheite", `${now.getFullYear()}-01-01`)
      .lte("date_controle_etancheite", `${now.getFullYear()}-12-31`);
    const ids = (data ?? []).map((r) => r.site_id).filter((v): v is number => v != null);
    restrictToIds = mergeRestrict(restrictToIds, ids);
  }
  if (sp.non_rooftop === "1") {
    const { data } = await supabase.from("site_materiels").select("site_id").ilike("type_equipement", "%roof%");
    const rooftopIds = new Set((data ?? []).map((r) => r.site_id));
    const { data: allSites } = await supabase.from("sites").select("id");
    const ids = (allSites ?? []).map((s) => s.id).filter((id) => !rooftopIds.has(id));
    restrictToIds = mergeRestrict(restrictToIds, ids);
  }
  if (sp.reference_intervention) {
    const { data } = await supabase.from("interventions").select("site_id").ilike("reference_client", `%${sp.reference_intervention}%`);
    restrictToIds = mergeRestrict(restrictToIds, (data ?? []).map((r) => r.site_id));
  }
  if (sp.numero_bon) {
    const { data } = await supabase.from("interventions").select("site_id").eq("numero_bon", Number(sp.numero_bon));
    restrictToIds = mergeRestrict(restrictToIds, (data ?? []).map((r) => r.site_id));
  }

  let query = supabase.from("v_sites_liste").select("*", { count: "exact" });

  if (sp.client) query = query.ilike("client_nom", `%${sp.client}%`);
  if (sp.q) {
    const n = Number(sp.q);
    query = Number.isFinite(n) && sp.q.trim() !== "" ? query.or(`numero_magasin.eq.${n},nom.ilike.%${sp.q}%`) : query.ilike("nom", `%${sp.q}%`);
  }
  if (sp.code) query = query.ilike("code_client", `%${sp.code}%`);
  if (sp.sans_geoloc === "1") query = query.is("longitude", null);
  if (sp.retard_paiement === "1") query = query.eq("retard_paiement", true);
  if (sp.ne_plus_intervenir === "1") query = query.eq("ne_plus_intervenir", true);
  if (sp.particulier === "1") query = query.eq("particulier", true);
  if (sp.investissement === "1") query = query.eq("investissement", true);
  if (restrictToIds) query = query.in("id", restrictToIds.length ? restrictToIds : [-1]);

  query = query.order(sort, { ascending: dir === "asc" }).range(from, to);
  const { data, count } = await query;
  const rows = (data ?? []) as SiteRow[];

  const filterFields: FilterField[] = [
    { type: "text", name: "client", label: "Client" },
    { type: "text", name: "q", label: "Nom ou numéro" },
    { type: "text", name: "code", label: "Code" },
    { type: "text", name: "reference_materiel", label: "Référence matériel" },
    { type: "text", name: "reference_intervention", label: "N° DI client (intervention)" },
    { type: "text", name: "numero_bon", label: "N° de bon" },
    { type: "checkbox", name: "ce_a_editer", label: "CE à éditer cette année" },
    { type: "checkbox", name: "sans_geoloc", label: "Sans géolocalisation" },
    { type: "checkbox", name: "non_rooftop", label: "Non ROOFTOP" },
    { type: "checkbox", name: "retard_paiement", label: "Retard paiement" },
    { type: "checkbox", name: "ne_plus_intervenir", label: "Ne plus intervenir" },
    { type: "checkbox", name: "particulier", label: "Particulier" },
    { type: "checkbox", name: "investissement", label: "Investissement" },
  ];

  const columns: Column<SiteRow>[] = [
    { key: "numero_magasin", label: "N° magasin", sortable: true, render: (r) => r.numero_magasin ?? "—" },
    { key: "nom", label: "Nom", sortable: true, render: (r) => <Link className="hover:underline" href={`/sites/${r.id}`}>{r.nom}</Link> },
    { key: "client_nom", label: "Client", render: (r) => <Link className="hover:underline" href={`/clients/${r.client_id}`}>{r.client_nom}</Link> },
    { key: "ville", label: "Ville", render: (r) => r.ville ?? "—" },
    { key: "zone_libelle", label: "Zone", render: (r) => r.zone_libelle ?? "—" },
    { key: "intervenant_nom", label: "Intervenant", render: (r) => r.intervenant_nom ?? "—" },
    { key: "contrat_clim_visites_par_an", label: "Visites/an", align: "right", render: (r) => formatNombre(r.contrat_clim_visites_par_an) },
    { key: "contrat_clim_redevance", label: "Redevance", align: "right", render: (r) => formatMontant(r.contrat_clim_redevance) },
    { key: "date_derniere_visite_entretien", label: "Dernière visite", sortable: true, render: (r) => formatDate(r.date_derniere_visite_entretien) },
    {
      key: "alertes",
      label: "Alertes",
      render: (r) => (
        <div className="flex gap-1">
          {r.retard_paiement && <Badge tone="red">Retard paiement</Badge>}
          {r.ne_plus_intervenir && <Badge tone="red">Ne plus intervenir</Badge>}
        </div>
      ),
    },
  ];

  return (
    <div className="mx-auto flex max-w-7xl flex-col gap-4 p-8">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Sites</h1>
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
      />
    </div>
  );
}
