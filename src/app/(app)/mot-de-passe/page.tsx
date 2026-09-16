import { redirect } from "next/navigation";
import { requireUtilisateur } from "@/lib/action-utils";
import { createClient } from "@/lib/supabase/server";
import { BOUTON_PRIMAIRE } from "@/components/ui/boutons";

const CHEMIN = "/mot-de-passe";

async function changerMotDePasse(formData: FormData) {
  "use server";
  await requireUtilisateur();
  const actuel = String(formData.get("actuel") ?? "");
  const nouveau = String(formData.get("nouveau") ?? "");
  const confirmation = String(formData.get("confirmation") ?? "");
  if (nouveau.length < 10) redirect(`${CHEMIN}?erreur=${encodeURIComponent("Le nouveau mot de passe doit contenir au moins 10 caractères.")}`);
  if (nouveau !== confirmation) redirect(`${CHEMIN}?erreur=${encodeURIComponent("Les deux saisies ne correspondent pas.")}`);
  if (nouveau === actuel) redirect(`${CHEMIN}?erreur=${encodeURIComponent("Le nouveau mot de passe doit être différent de l'actuel.")}`);

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user?.email) redirect("/login");

  // Revérification du mot de passe actuel : évite qu'une session laissée ouverte suffise à le changer.
  const { error: erreurActuel } = await supabase.auth.signInWithPassword({ email: user.email, password: actuel });
  if (erreurActuel) redirect(`${CHEMIN}?erreur=${encodeURIComponent("Mot de passe actuel incorrect.")}`);

  const { error } = await supabase.auth.updateUser({ password: nouveau });
  if (error) redirect(`${CHEMIN}?erreur=${encodeURIComponent(`Changement refusé : ${error.message}`)}`);
  redirect(`${CHEMIN}?info=${encodeURIComponent("Mot de passe modifié.")}`);
}

const CHAMP = "rounded-md border px-3 py-2 text-sm";

/** Changement du mot de passe par l'utilisateur connecté : l'administrateur transmet un mot de passe initial, la personne le remplace ici. */
export default async function MotDePassePage({ searchParams }: { searchParams: Promise<{ erreur?: string; info?: string }> }) {
  const { erreur, info } = await searchParams;
  const { authUser } = await requireUtilisateur();
  return (
    <main className="flex justify-center p-8">
      <form action={changerMotDePasse} className="flex w-full max-w-sm flex-col gap-3 rounded-xl border p-6">
        <h1 className="text-xl font-bold">Changer mon mot de passe</h1>
        <p className="text-xs opacity-70">Compte : {authUser.email}</p>
        {erreur && <p className="rounded-md bg-red-50 p-3 text-sm text-red-700 dark:bg-red-950/30">{erreur}</p>}
        {info && <p className="rounded-md bg-green-50 p-3 text-sm text-green-700 dark:bg-green-950/30">{info}</p>}
        <label className="flex flex-col gap-1 text-sm">
          Mot de passe actuel
          <input name="actuel" type="password" required autoComplete="current-password" className={CHAMP} />
        </label>
        <label className="flex flex-col gap-1 text-sm">
          Nouveau mot de passe (10 caractères minimum)
          <input name="nouveau" type="password" required minLength={10} autoComplete="new-password" className={CHAMP} />
        </label>
        <label className="flex flex-col gap-1 text-sm">
          Confirmation
          <input name="confirmation" type="password" required minLength={10} autoComplete="new-password" className={CHAMP} />
        </label>
        <button type="submit" className={`${BOUTON_PRIMAIRE} text-sm`}>
          Enregistrer
        </button>
      </form>
    </main>
  );
}
