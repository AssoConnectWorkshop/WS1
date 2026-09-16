import { toStringParams } from "@/lib/list-params";
import { Messages } from "@/components/ui/Messages";
import { ChampsDonneur } from "@/components/tiers/FormulaireClient";
import { creerDonneur } from "../../tiers/actions";

export const dynamic = "force-dynamic";

export default async function NouveauDonneurPage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const sp = toStringParams(await searchParams);
  return (
    <div className="mx-auto flex max-w-2xl flex-col gap-4 p-8">
      <h1 className="text-2xl font-bold">Nouveau donneur d&apos;ordre</h1>
      <Messages sp={sp} />
      <form action={creerDonneur} className="flex flex-col gap-4 rounded-xl border p-6">
        <ChampsDonneur />
        <button type="submit" className="rounded-md bg-black py-2 font-medium text-white">
          Créer
        </button>
      </form>
    </div>
  );
}
