import "server-only";
import { createClient } from "@/lib/supabase/server";

export type Role = "gestionnaire" | "administrateur";

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
export async function getCurrentUser(): Promise<CurrentUser | null> {
  const supabase = await createClient();

  let user = null;
  try {
    const {
      data: { user: authUser },
    } = await supabase.auth.getUser();
    user = authUser;
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
}
