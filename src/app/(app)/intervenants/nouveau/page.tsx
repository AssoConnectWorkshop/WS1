import { createClient } from "@/lib/supabase/server";
import { Messages } from "@/components/ui/Messages";
import { toStringParams } from "@/lib/list-params";
import { formatNom } from "@/lib/format";
import { ChampsIntervenant } from "@/components/intervenants/FormulaireIntervenant";
import { creerIntervenant } from "../actions";

export const dynamic = "force-dynamic";

export default async function NouvelIntervenantPage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();
  const { data: gestionnaires } = await supabase.from("utilisateurs").select("id, nom, prenom").in("profil", [1, 3]).order("nom");

  return (
    <div className="mx-auto flex max-w-3xl flex-col gap-4 p-8">
      <h1 className="text-2xl font-bold">Nouvel intervenant</h1>
      <Messages sp={sp} />
      <form action={creerIntervenant} className="flex flex-col gap-4">
        <ChampsIntervenant gestionnaires={(gestionnaires ?? []).map((g) => ({ id: g.id, libelle: formatNom(g.prenom, g.nom) }))} />
        <button type="submit" className="w-fit rounded-md bg-black px-4 py-2 font-medium text-white">
          Créer
        </button>
      </form>
    </div>
  );
}
