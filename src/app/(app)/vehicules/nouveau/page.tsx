import { createClient } from "@/lib/supabase/server";
import { toStringParams } from "@/lib/list-params";
import { Messages } from "@/components/ui/Messages";
import { ChampsVehicule } from "@/components/vehicules/FormulaireVehicule";
import { formatNom } from "@/lib/format";
import { creerVehicule } from "../actions";

export const dynamic = "force-dynamic";

export default async function NouveauVehiculePage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();
  const [{ data: conducteurs }, { data: etats }] = await Promise.all([
    supabase.from("utilisateurs").select("id, nom, prenom").eq("profil", 2).not("code_intervenant", "is", null).order("nom"),
    supabase.from("etats_vehicule").select("code, libelle").order("code"),
  ]);

  return (
    <div className="mx-auto flex max-w-3xl flex-col gap-4 p-8">
      <h1 className="text-2xl font-bold">Nouveau véhicule</h1>
      <Messages sp={sp} />
      <form action={creerVehicule} className="flex flex-col gap-4">
        <ChampsVehicule conducteurs={(conducteurs ?? []).map((c) => ({ id: c.id, libelle: formatNom(c.prenom, c.nom) }))} etats={etats ?? []} />
        <button type="submit" className="w-fit rounded-md bg-black px-4 py-2 font-medium text-white">
          Créer
        </button>
      </form>
    </div>
  );
}
