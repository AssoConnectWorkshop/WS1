import "server-only";
import { cache } from "react";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { estMasterAdmin } from "@/lib/acces";

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
 * Compte Supabase Auth créé à la main dans le tableau de bord (aucun e-mail) : à la première
 * connexion, rattachement à la ligne `utilisateurs` non rattachée dont l'e-mail est identique.
 * Rôle gestionnaire si la ligne n'en a pas. Écriture via le client service role (RLS).
 */
async function rattacherParEmail(authUserId: string, email: string): Promise<Utilisateur | null> {
  try {
    const admin = createAdminClient();
    const { data: candidats } = await admin
      .from("utilisateurs")
      .select("id, nom, prenom, email, profil, role")
      .is("auth_user_id", null)
      .ilike("email", email.trim())
      .limit(2);
    if (!candidats || candidats.length !== 1) return null;
    const ligne = candidats[0] as Utilisateur;
    const role: Role = ligne.role ?? "gestionnaire";
    const { error } = await admin.from("utilisateurs").update({ auth_user_id: authUserId, role }).eq("id", ligne.id).is("auth_user_id", null);
    return error ? null : { ...ligne, role };
  } catch {
    return null;
  }
}

/**
 * Master admin (variable Vercel MASTER_ADMINS) : toujours administrateur. Sans ligne `utilisateurs`,
 * une ligne compte_application est créée pour porter l'accès, indépendamment du personnel FMC.
 */
async function garantirMasterAdmin(authUserId: string, email: string, existant: Utilisateur | null): Promise<Utilisateur | null> {
  if (existant?.role === "administrateur") return existant;
  try {
    const admin = createAdminClient();
    if (existant) {
      const { error } = await admin.from("utilisateurs").update({ role: "administrateur" }).eq("id", existant.id);
      return error ? existant : { ...existant, role: "administrateur" };
    }
    return await creerCompteApplication(authUserId, email, "administrateur");
  } catch {
    return existant;
  }
}

/**
 * Tout compte Supabase Auth a accès : seul un administrateur peut en créer (inscription libre
 * désactivée). Sans fiche FMC portant l'e-mail, une ligne compte_application porte l'accès.
 */
async function creerCompteApplication(authUserId: string, email: string, role: Role): Promise<Utilisateur | null> {
  try {
    const admin = createAdminClient();
    const { data, error } = await admin
      .from("utilisateurs")
      .insert({ nom: email, email, role, auth_user_id: authUserId, compte_application: true })
      .select("id, nom, prenom, email, profil, role")
      .single();
    return error ? null : (data as Utilisateur);
  } catch {
    return null;
  }
}

/**
 * Utilisateur courant côté serveur, en joignant `utilisateurs.auth_user_id`.
 * Retourne `null` si personne n'est authentifié. `utilisateur` n'est `null` que si la création
 * automatique de la ligne a échoué (service role absent, e-mail vide).
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

  let { data: utilisateur } = await supabase
    .from("utilisateurs")
    .select("id, nom, prenom, email, profil, role")
    .eq("auth_user_id", user.id)
    .maybeSingle();

  if (!utilisateur && user.email) utilisateur = await rattacherParEmail(user.id, user.email);
  if (user.email && estMasterAdmin(user.email)) utilisateur = await garantirMasterAdmin(user.id, user.email, utilisateur);
  if (!utilisateur && user.email) utilisateur = await creerCompteApplication(user.id, user.email, "gestionnaire");

  return {
    authUser: { id: user.id, email: user.email ?? null },
    utilisateur: (utilisateur as Utilisateur | null) ?? null,
    role: (utilisateur?.role as Role | null | undefined) ?? null,
  };
});
