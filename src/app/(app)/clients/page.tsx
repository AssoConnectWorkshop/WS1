import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { parseListParams, toStringParams } from "@/lib/list-params";
import { DataTable, type Column } from "@/components/ui/DataTable";
import { FilterBar, type FilterField } from "@/components/ui/FilterBar";
import { formatMontant } from "@/lib/format";

export const dynamic = "force-dynamic";

type ClientRow = {
  id: number;
  nom: string;
  ville: string | null;
  contact_principal: string | null;
  tarif_heure_mo: number | null;
  tarif_deplacement: number | null;
  numero_esabora_maint: string | null;
  numero_esabora_clim: string | null;
  actif: boolean;
};

export default async function ClientsPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();
  const { page, sort, dir, from, to, pageSize } = parseListParams(sp, "nom", 50);

  let query = supabase.from("clients").select("*", { count: "exact" });
  if (sp.tous !== "1") query = query.eq("actif", true);
  if (sp.q) query = query.ilike("nom", `%${sp.q}%`);
  query = query.order(sort, { ascending: dir === "asc" }).range(from, to);

  const { data, count } = await query;
  const rows = (data ?? []) as ClientRow[];

  const filterFields: FilterField[] = [
    { type: "text", name: "q", label: "Nom" },
    { type: "checkbox", name: "tous", label: "Afficher tous (y compris inactifs)" },
  ];

  const columns: Column<ClientRow>[] = [
    { key: "nom", label: "Nom", sortable: true, render: (r) => <Link className="hover:underline" href={`/clients/${r.id}`}>{r.nom}</Link> },
    { key: "ville", label: "Ville", render: (r) => r.ville ?? "—" },
    { key: "contact_principal", label: "Contact", render: (r) => r.contact_principal ?? "—" },
    { key: "tarif_heure_mo", label: "Tarif MO", align: "right", render: (r) => formatMontant(r.tarif_heure_mo) },
    { key: "tarif_deplacement", label: "Tarif déplacement", align: "right", render: (r) => formatMontant(r.tarif_deplacement) },
    { key: "numero_esabora_maint", label: "Esabora maint.", render: (r) => r.numero_esabora_maint ?? "—" },
    { key: "numero_esabora_clim", label: "Esabora clim", render: (r) => r.numero_esabora_clim ?? "—" },
  ];

  return (
    <div className="mx-auto flex max-w-6xl flex-col gap-4 p-8">
      <h1 className="text-2xl font-bold">Clients</h1>
      <FilterBar fields={filterFields} values={sp} />
      <DataTable columns={columns} rows={rows} searchParams={sp} total={count ?? 0} page={page} pageSize={pageSize} emptyMessage="Aucun client." />
    </div>
  );
}
