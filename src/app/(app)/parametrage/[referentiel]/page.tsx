import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getReferentiel } from "@/lib/referentiels-config";
import { EmptyState } from "@/components/ui/EmptyState";
import { oui } from "@/lib/format";

export const dynamic = "force-dynamic";

function renderCell(value: unknown) {
  if (value == null) return "—";
  if (typeof value === "boolean") return oui(value);
  return String(value);
}

export default async function ReferentielPage({ params }: { params: Promise<{ referentiel: string }> }) {
  const { referentiel } = await params;
  const config = getReferentiel(referentiel);
  if (!config) notFound();

  const supabase = await createClient();
  const { data } = await supabase.from(config.table).select("*").order(config.orderBy);

  return (
    <div className="mx-auto flex max-w-4xl flex-col gap-4 p-8">
      <div>
        <Link href="/parametrage" className="text-sm underline">
          ← Paramétrage
        </Link>
      </div>
      <h1 className="text-2xl font-bold">{config.label}</h1>

      {data && data.length > 0 ? (
        <div className="overflow-x-auto rounded-lg border">
          <table className="w-full border-collapse text-sm">
            <thead>
              <tr className="border-b bg-black/[0.02] text-left dark:bg-white/[0.03]">
                {config.columns.map((c) => (
                  <th key={c.key} className="px-3 py-2 font-medium">
                    {c.label}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {data.map((row, i) => (
                <tr key={i} className="border-b last:border-0">
                  {config.columns.map((c) => (
                    <td key={c.key} className="px-3 py-2">
                      {renderCell((row as Record<string, unknown>)[c.key])}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <EmptyState message="Aucune ligne." />
      )}
    </div>
  );
}
