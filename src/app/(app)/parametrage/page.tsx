import Link from "next/link";
import { getCurrentUser } from "@/lib/auth";

export const dynamic = "force-dynamic";

/** Écran Paramétrage Access : les boutons sont dans la colonne de gauche (layout) ; ici l'avertissement fixe d'Access. */
export default async function ParametragePage() {
  const current = await getCurrentUser();
  const isAdmin = current?.role === "administrateur";

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold">Paramétrage</h1>
        <Link href="/" className="rounded bg-red-600 px-3 py-1 text-xs text-white" title="Retour au menu">
          ✕
        </Link>
      </div>
      <p className="max-w-xl rounded border border-red-300 bg-red-50 p-3 text-sm text-red-800 dark:bg-red-950/30 dark:text-red-200">
        Attention : une modification d&apos;un libellé se propage partout (ex. renommer un technicien réaffecte toutes ses interventions).
        {isAdmin ? " Vous pouvez ajouter, modifier et supprimer des valeurs." : " Consultation ; la modification est réservée à l'administrateur."}
      </p>
      <p className="text-sm opacity-70">Choisissez un référentiel dans la colonne de gauche.</p>
    </div>
  );
}
