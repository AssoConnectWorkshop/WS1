import { toStringParams } from "@/lib/list-params";
import { ChampsClient } from "@/components/tiers/FormulaireClient";
import { creerClient } from "../../tiers/actions";

export const dynamic = "force-dynamic";

export default async function NouveauClientPage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const sp = toStringParams(await searchParams);
  return (
    <div className="mx-auto flex max-w-2xl flex-col gap-4 p-8">
      <h1 className="text-2xl font-bold">Nouveau client</h1>
      {sp.erreur && <p className="rounded-md bg-red-50 p-3 text-sm text-red-700">{sp.erreur}</p>}
      <form action={creerClient} className="flex flex-col gap-4 rounded-xl border p-6">
        <ChampsClient />
        <button type="submit" className="rounded-md bg-black py-2 font-medium text-white">
          Créer
        </button>
      </form>
    </div>
  );
}
