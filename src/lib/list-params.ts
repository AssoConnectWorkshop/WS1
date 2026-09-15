export type ListParams = {
  page: number;
  sort: string;
  dir: "asc" | "desc";
  from: number;
  to: number;
  pageSize: number;
};

export function parseListParams(
  searchParams: Record<string, string | undefined>,
  defaultSort: string,
  pageSize = 50,
): ListParams {
  const page = Math.max(1, Number(searchParams.page) || 1);
  const sort = searchParams.sort || defaultSort;
  const dir: "asc" | "desc" = searchParams.dir === "desc" ? "desc" : "asc";
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;
  return { page, sort, dir, from, to, pageSize };
}

export function toStringParams(searchParams: Record<string, string | string[] | undefined>): Record<string, string | undefined> {
  const out: Record<string, string | undefined> = {};
  for (const [k, v] of Object.entries(searchParams)) {
    out[k] = Array.isArray(v) ? v[0] : v;
  }
  return out;
}

export function toArrayParam(value: string | string[] | undefined): string[] {
  if (!value) return [];
  return Array.isArray(value) ? value : [value];
}

/**
 * Combine deux passes de filtrage par jointure (intersection). Fonction pure plutôt qu'une
 * closure qui réassigne une variable externe : TypeScript ne rétrécit pas correctement le
 * type d'une variable mutée depuis une fermeture imbriquée.
 */
export function mergeRestrict(current: number[] | null, ids: number[]): number[] {
  return current ? current.filter((id) => ids.includes(id)) : ids;
}
