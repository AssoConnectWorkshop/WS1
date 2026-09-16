import "server-only";
import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";

/** Toute écriture passe par un utilisateur rattaché (brief étape 5 §Conventions). */
export async function requireUtilisateur() {
  const current = await getCurrentUser();
  if (!current?.utilisateur) redirect("/login");
  return { ...current, utilisateur: current.utilisateur };
}

/** Paramétrage : écriture réservée au rôle administrateur (brief §5.6). */
export async function requireAdministrateur(retour: string) {
  const current = await requireUtilisateur();
  if (current.role !== "administrateur") redirectWithError(retour, "Réservé à l'administrateur.");
  return current;
}

export function redirectWithError(path: string, message: string): never {
  const separateur = path.includes("?") ? "&" : "?";
  redirect(`${path}${separateur}erreur=${encodeURIComponent(message)}`);
}

export function aujourdhui() {
  return new Date().toISOString().slice(0, 10);
}

/** Routes de téléchargement (PDF, Excel) : utilisateur connecté ou réponse 401. */
export async function exigerUtilisateur(supabase: { auth: { getUser: () => Promise<{ data: { user: unknown | null } }> } }) {
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return user ? null : new Response("Non autorisé", { status: 401 });
}
