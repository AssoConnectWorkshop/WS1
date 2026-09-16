import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { parseListParams, toStringParams } from "@/lib/list-params";
import { DataTable, type Column } from "@/components/ui/DataTable";
import { FilterBar, type FilterField } from "@/components/ui/FilterBar";

export const dynamic = "force-dynamic";

type DonneurRow = { id: number; nom: string | null; ville: string | null; telephone: string | null; actif: boolean };

export default async function DonneursOrdrePage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();
  const { page, sort, dir, from, to, pageSize } = parseListParams(sp, "nom", 50);

  let query = supabase.from("donneurs_ordre").select("*", { count: "exact" });
  if (sp.tous !== "1") query = query.eq("actif", true);
  if (sp.q) query = query.ilike("nom", `%${sp.q}%`);
  query = query.order(sort, { ascending: dir === "asc" }).range(from, to);
  const { data, count } = await query;
  const rows = (data ?? []) as DonneurRow[];

  const filterFields: FilterField[] = [
    { type: "text", name: "q", label: "Nom" },
    { type: "checkbox", name: "tous", label: "Afficher tous" },
  ];

  const columns: Column<DonneurRow>[] = [
    { key: "nom", label: "Nom", sortable: true, render: (r) => <Link className="hover:underline" href={`/donneurs-ordre/${r.id}`}>{r.nom}</Link> },
    { key: "ville", label: "Ville", render: (r) => r.ville ?? "—" },
    { key: "telephone", label: "Téléphone", render: (r) => r.telephone ?? "—" },
  ];

  return (
    <div className="mx-auto flex max-w-5xl flex-col gap-4 p-8">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Donneurs d&apos;ordre</h1>
        <Link href="/donneurs-ordre/nouveau" className="rounded-md bg-black px-3 py-2 text-sm text-white">
          Nouveau donneur d&apos;ordre
        </Link>
      </div>
      <FilterBar fields={filterFields} values={sp} />
      <DataTable columns={columns} rows={rows} searchParams={sp} total={count ?? 0} page={page} pageSize={pageSize} emptyMessage="Aucun donneur d'ordre." hrefLigne={(r) => `/donneurs-ordre/${r.id}`} />
    </div>
  );
}
