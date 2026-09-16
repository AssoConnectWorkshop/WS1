import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { parseListParams, toStringParams, toArrayParam, mergeRestrict } from "@/lib/list-params";
import { DataTable, type Column } from "@/components/ui/DataTable";
import { FilterBar, type FilterField } from "@/components/ui/FilterBar";
import { oui } from "@/lib/format";

export const dynamic = "force-dynamic";

type IntervenantRow = {
  id: number;
  code: string;
  nom: string | null;
  ville: string | null;
  est_sous_traitant: boolean | null;
  est_technicien_interne: boolean | null;
  ne_plus_intervenir: boolean | null;
};

export default async function IntervenantsPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const raw = await searchParams;
  const sp = toStringParams(raw);
  const zonesSel = toArrayParam(raw.zones);
  const activitesSel = toArrayParam(raw.activites);
  const supabase = await createClient();
  const { page, sort, dir, from, to, pageSize } = parseListParams(sp, "nom", 50);

  const [{ data: zones }, { data: activites }] = await Promise.all([
    supabase.from("zones_geographiques").select("id, libelle").order("libelle"),
    supabase.from("activites").select("id, libelle").order("libelle"),
  ]);

  let restrictToIds: number[] | null = null;
  if (zonesSel.length) {
    const { data } = await supabase.from("intervenant_zones").select("intervenant_id").in("zone_id", zonesSel.map(Number));
    const ids = (data ?? []).map((r) => r.intervenant_id);
    restrictToIds = mergeRestrict(restrictToIds, ids);
  }
  if (activitesSel.length) {
    const { data } = await supabase.from("intervenant_activites").select("intervenant_id").in("activite_id", activitesSel.map(Number));
    const ids = (data ?? []).map((r) => r.intervenant_id);
    restrictToIds = mergeRestrict(restrictToIds, ids);
  }

  let query = supabase.from("intervenants").select("*", { count: "exact" });
  if (sp.code) query = query.ilike("code", `%${sp.code}%`);
  if (sp.prospect === "1") query = query.eq("est_prospect", true);
  if (sp.sous_traitant === "1") query = query.eq("est_sous_traitant", true);
  if (sp.ponctuel === "1") query = query.eq("est_sous_traitant_ponctuel", true);
  if (sp.technicien_interne === "1") query = query.eq("est_technicien_interne", true);
  if (sp.ne_plus_intervenir === "1") query = query.eq("ne_plus_intervenir", true);
  if (sp.n_existe_plus === "1") query = query.eq("n_existe_plus", true);
  if (sp.sans_geoloc === "1") query = query.is("latitude", null);
  if (sp.zone_nationale === "1") query = query.eq("zone_nationale", true);
  if (sp.q) query = query.or(`nom.ilike.%${sp.q}%,adresse.ilike.%${sp.q}%,ville.ilike.%${sp.q}%`);
  if (sp.villes) query = query.ilike("villes_codes_postaux", `%${sp.villes}%`);
  if (sp.infos) query = query.ilike("informations", `%${sp.infos}%`);
  if (restrictToIds) query = query.in("id", restrictToIds.length ? restrictToIds : [-1]);

  query = query.order(sort, { ascending: dir === "asc" }).range(from, to);
  const { data, count } = await query;
  const rows = (data ?? []) as IntervenantRow[];

  const filterFields: FilterField[] = [
    { type: "text", name: "q", label: "Nom / adresse / ville" },
    { type: "text", name: "code", label: "Code" },
    { type: "text", name: "villes", label: "Villes couvertes" },
    { type: "text", name: "infos", label: "Infos" },
    { type: "multiselect", name: "zones", label: "Zones", options: (zones ?? []).map((z) => ({ value: String(z.id), label: z.libelle })) },
    { type: "multiselect", name: "activites", label: "Activités", options: (activites ?? []).map((a) => ({ value: String(a.id), label: a.libelle })) },
    { type: "checkbox", name: "prospect", label: "Prospect" },
    { type: "checkbox", name: "sous_traitant", label: "Sous-traitant FMC" },
    { type: "checkbox", name: "ponctuel", label: "Ponctuel" },
    { type: "checkbox", name: "technicien_interne", label: "Technicien interne" },
    { type: "checkbox", name: "ne_plus_intervenir", label: "Ne plus intervenir" },
    { type: "checkbox", name: "n_existe_plus", label: "N'existe plus" },
    { type: "checkbox", name: "sans_geoloc", label: "Sans géolocalisation" },
    { type: "checkbox", name: "zone_nationale", label: "Zone nationale" },
  ];

  const columns: Column<IntervenantRow>[] = [
    { key: "code", label: "Code", sortable: true, render: (r) => r.code },
    { key: "nom", label: "Nom", sortable: true, render: (r) => <Link className="hover:underline" href={`/intervenants/${r.id}`}>{r.nom}</Link> },
    { key: "ville", label: "Ville", render: (r) => r.ville ?? "—" },
    { key: "est_sous_traitant", label: "Sous-traitant", render: (r) => oui(r.est_sous_traitant) },
    { key: "est_technicien_interne", label: "Technicien interne", render: (r) => oui(r.est_technicien_interne) },
    { key: "ne_plus_intervenir", label: "Ne plus intervenir", render: (r) => oui(r.ne_plus_intervenir) },
  ];

  return (
    <div className="mx-auto flex max-w-6xl flex-col gap-4 p-8">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Intervenants</h1>
        <Link href="/intervenants/nouveau" className="rounded-md bg-black px-3 py-2 text-sm text-white">
          Nouvel intervenant
        </Link>
      </div>
      <FilterBar fields={filterFields} values={sp} multiValues={{ zones: zonesSel, activites: activitesSel }} />
      <DataTable columns={columns} rows={rows} searchParams={sp} total={count ?? 0} page={page} pageSize={pageSize} emptyMessage="Aucun intervenant." hrefLigne={(r) => `/intervenants/${r.id}`} />
    </div>
  );
}
