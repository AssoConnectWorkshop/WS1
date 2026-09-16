import "server-only";
import { cache } from "react";
import { createClient } from "@/lib/supabase/server";

export type Role = "gestionnaire" | "administrateur" | "comptable";

/** Statuts de facturation réservés (mot de passe « Kadi » d'Access) : comptable ou administrateur. */
export const peutStatutsReserves = (role: Role | null | undefined) => role === "administrateur" || role === "comptable";

export type Utilisateur = {
  id: number;
  nom: string | null;
  prenom: string | null;
  email: string | null;
  profil: number | null;
  role: Role | null;
};

export type CurrentUser = {
  authUser: { id: string; email: string | null };
  utilisateur: Utilisateur | null;
  role: Role | null;
};

/**
 * Utilisateur courant côté serveur, en joignant `utilisateurs.auth_user_id`.
 * Retourne `null` si personne n'est authentifié. `utilisateur` est `null` si le compte
 * Supabase Auth n'est rattaché à aucune ligne `utilisateurs` (cf. étape 3, layout applicatif).
 */
export const getCurrentUser = cache(async (): Promise<CurrentUser | null> => {
  const supabase = await createClient();

  // Jeton vérifié localement (getClaims) : pas d'appel réseau au service Auth. Mis en cache React :
  // un seul appel par requête, partagé entre layout, page et actions.
  let user: { id: string; email?: string } | null = null;
  try {
    const { data } = await supabase.auth.getClaims();
    user = data?.claims?.sub ? { id: data.claims.sub, email: data.claims.email } : null;
  } catch {
    return null;
  }

  if (!user) return null;

  const { data: utilisateur } = await supabase
    .from("utilisateurs")
    .select("id, nom, prenom, email, profil, role")
    .eq("auth_user_id", user.id)
    .maybeSingle();

  return {
    authUser: { id: user.id, email: user.email ?? null },
    utilisateur: (utilisateur as Utilisateur | null) ?? null,
    role: (utilisateur?.role as Role | null | undefined) ?? null,
  };
});
