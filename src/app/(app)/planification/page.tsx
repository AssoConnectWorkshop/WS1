import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { toStringParams } from "@/lib/list-params";
import { FilterBar, type FilterField } from "@/components/ui/FilterBar";
import { EmptyState } from "@/components/ui/EmptyState";
import { formatDate } from "@/lib/format";

export const dynamic = "force-dynamic";

export default async function PlanificationPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();

  let clients: { id: number; nom: string }[] = [];
  if (sp.client) {
    const { data } = await supabase.from("clients").select("id, nom").ilike("nom", `%${sp.client}%`).order("nom").limit(20);
    clients = data ?? [];
  }

  const clientId = sp.client_id ? Number(sp.client_id) : clients.length === 1 ? clients[0].id : null;

  const { data: planifications } = clientId
    ? await supabase.from("planifications").select("id, rang, date_limite, nombre_visites").eq("client_id", clientId).order("rang")
    : { data: null };

  const { data: entretiensAVenir } = await supabase
    .from("v_interventions_liste")
    .select("id, site_nom, client_nom, date_limite, date_prevue")
    .eq("type_code", 1)
    .eq("statut_code", 1)
    .order("date_limite")
    .limit(50);

  const filterFields: FilterField[] = [{ type: "text", name: "client", label: "Rechercher un client" }];

  return (
    <div className="mx-auto flex max-w-5xl flex-col gap-8 p-8">
      <h1 className="text-2xl font-bold">Planification</h1>

      <section className="flex flex-col gap-3">
        <h2 className="text-sm font-semibold opacity-70">Par client</h2>
        <FilterBar fields={filterFields} values={sp} />

        {sp.client && !sp.client_id && clients.length > 1 && (
          <ul className="flex flex-col gap-1 text-sm">
            {clients.map((c) => (
              <li key={c.id}>
                <Link href={`/planification?client=${encodeURIComponent(sp.client!)}&client_id=${c.id}`} className="underline">
                  {c.nom}
                </Link>
              </li>
            ))}
          </ul>
        )}

        {clientId &&
          (planifications && planifications.length > 0 ? (
            <table className="w-full border-collapse text-sm">
              <thead>
                <tr className="border-b text-left">
                  <th className="py-1">Rang</th>
                  <th>Date limite</th>
                  <th>Nombre de visites</th>
                </tr>
              </thead>
              <tbody>
                {planifications.map((p) => (
                  <tr key={p.id} className="border-b">
                    <td className="py-1">{p.rang}</td>
                    <td>{formatDate(p.date_limite)}</td>
                    <td>{p.nombre_visites ?? "—"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <EmptyState message="Aucune planification pour ce client." />
          ))}
      </section>

      <section className="flex flex-col gap-3">
        <h2 className="text-sm font-semibold opacity-70">Entretiens à venir (type Entretien, à planifier)</h2>
        {entretiensAVenir && entretiensAVenir.length > 0 ? (
          <ul className="flex flex-col gap-2">
            {entretiensAVenir.map((i) => (
              <li key={i.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
                <Link href={`/interventions/${i.id}`} className="underline">
                  {i.site_nom} · {i.client_nom}
                </Link>
                <span className="opacity-70">
                  Limite {formatDate(i.date_limite)} · Prévue {formatDate(i.date_prevue)}
                </span>
              </li>
            ))}
          </ul>
        ) : (
          <EmptyState message="Aucun entretien à venir." />
        )}
      </section>
    </div>
  );
}
