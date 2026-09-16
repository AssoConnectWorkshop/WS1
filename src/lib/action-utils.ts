import "server-only";
import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";

/** Toute écriture passe par un utilisateur rattaché (brief étape 5 §Conventions). */
export async function requireUtilisateur() {
  const current = await getCurrentUser();
  if (!current?.utilisateur) redirect("/login");
  return { ...current, utilisateur: current.utilisateur };
}

export function redirectWithError(path: string, message: string): never {
  const separateur = path.includes("?") ? "&" : "?";
  redirect(`${path}${separateur}erreur=${encodeURIComponent(message)}`);
}

export function aujourdhui() {
  return new Date().toISOString().slice(0, 10);
}
