import Link from "next/link";
import { EmptyState } from "./EmptyState";
import { LigneOuvrable } from "./LigneOuvrable";

export type Column<T> = {
  key: string;
  label: string;
  sortable?: boolean;
  align?: "left" | "right" | "center";
  render: (row: T) => React.ReactNode;
};

function buildHref(searchParams: Record<string, string | undefined>, patch: Record<string, string | undefined>) {
  const params = new URLSearchParams();
  for (const [k, v] of Object.entries({ ...searchParams, ...patch })) {
    if (v) params.set(k, v);
  }
  const qs = params.toString();
  return qs ? `?${qs}` : "?";
}

export function DataTable<T>({
  columns,
  rows,
  searchParams,
  total,
  page,
  pageSize,
  emptyMessage,
  erreur,
  hrefLigne,
}: {
  columns: Column<T>[];
  rows: T[];
  searchParams: Record<string, string | undefined>;
  total: number;
  page: number;
  pageSize: number;
  emptyMessage?: string;
  erreur?: string | null;
  /** Lien d'ouverture de l'objet de la ligne : bouton « Ouvrir » en première colonne et double-clic. */
  hrefLigne?: (row: T) => string | null | undefined;
}) {
  const totalPages = Math.max(1, Math.ceil(total / pageSize));
  const sort = searchParams.sort;
  const dir = searchParams.dir === "desc" ? "desc" : "asc";

  if (erreur) {
    return <div className="rounded-lg border border-red-300 bg-red-50 p-4 text-sm text-red-800 dark:bg-red-950/30 dark:text-red-200">Erreur de requête : {erreur}</div>;
  }
  if (rows.length === 0) {
    return <EmptyState message={emptyMessage ?? "Aucun résultat."} />;
  }

  return (
    <div className="flex flex-col gap-3">
      <div className="overflow-x-auto rounded-lg border">
        <table className="w-full border-collapse text-xs">
          <thead>
            <tr className="border-b bg-black/[0.02] text-left dark:bg-white/[0.03]">
              {hrefLigne && <th className="w-16 px-2 py-1" />}
              {columns.map((col) => (
                <th
                  key={col.key}
                  className={`whitespace-nowrap px-2 py-1 font-medium ${
                    col.align === "right" ? "text-right" : col.align === "center" ? "text-center" : "text-left"
                  }`}
                >
                  {col.sortable ? (
                    <Link
                      href={buildHref(searchParams, {
                        sort: col.key,
                        dir: sort === col.key && dir === "asc" ? "desc" : "asc",
                        page: undefined,
                      })}
                      className="hover:underline"
                    >
                      {col.label}
                      {sort === col.key ? (dir === "asc" ? " ▲" : " ▼") : ""}
                    </Link>
                  ) : (
                    col.label
                  )}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((row, i) => (
              <LigneOuvrable key={i} href={hrefLigne?.(row)} className="border-b last:border-0 hover:bg-blue-100 dark:hover:bg-blue-950/40">
                {hrefLigne && (
                  <td className="px-2 py-1">
                    {hrefLigne(row) && (
                      <Link href={hrefLigne(row)!} className="rounded border bg-white px-1.5 py-0.5 text-[11px] hover:bg-black/5 dark:bg-white/5">
                        Ouvrir
                      </Link>
                    )}
                  </td>
                )}
                {columns.map((col) => (
                  <td
                    key={col.key}
                    className={`whitespace-nowrap px-2 py-1 ${
                      col.align === "right" ? "text-right" : col.align === "center" ? "text-center" : "text-left"
                    }`}
                  >
                    {col.render(row)}
                  </td>
                ))}
              </LigneOuvrable>
            ))}
          </tbody>
        </table>
      </div>

      <div className="flex items-center justify-between text-xs opacity-70">
        <span>
          {total} résultat{total > 1 ? "s" : ""} · page {page} / {totalPages}
        </span>
        <div className="flex gap-2">
          <Link
            href={buildHref(searchParams, { page: String(Math.max(1, page - 1)) })}
            aria-disabled={page <= 1}
            className={`rounded-md border px-2 py-1 ${page <= 1 ? "pointer-events-none opacity-40" : ""}`}
          >
            Précédent
          </Link>
          <Link
            href={buildHref(searchParams, { page: String(Math.min(totalPages, page + 1)) })}
            aria-disabled={page >= totalPages}
            className={`rounded-md border px-2 py-1 ${page >= totalPages ? "pointer-events-none opacity-40" : ""}`}
          >
            Suivant
          </Link>
        </div>
      </div>
    </div>
  );
}
