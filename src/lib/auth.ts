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
  /** Raisons pour lesquelles le rattachement automatique a échoué (vide si tout va bien). */
  diagnostic: string[];
};

const COLONNES = "id, nom, prenom, email, profil, role";

/**
 * Rattachement d'un compte Supabase Auth à une ligne `utilisateurs`, dans l'ordre : ligne déjà
 * rattachée, fiche FMC non rattachée de même e-mail, sinon création d'une ligne compte_application.
 * Master admin (MASTER_ADMINS) : toujours administrateur. Écritures via le client service role.
 * Retourne aussi le diagnostic des échecs, affiché sur l'écran « Compte non rattaché ».
 */
async function rattacher(authUserId: string, email: string | undefined, existant: Utilisateur | null): Promise<{ utilisateur: Utilisateur | null; diagnostic: string[] }> {
  const diagnostic: string[] = [];
  const master = estMasterAdmin(email);
  if (existant && (!master || existant.role === "administrateur")) return { utilisateur: existant, diagnostic };
  if (!email) return { utilisateur: existant, diagnostic: ["Le jeton de connexion ne contient pas d'e-mail."] };

  let admin: ReturnType<typeof createAdminClient>;
  try {
    admin = createAdminClient();
  } catch (e) {
    return { utilisateur: existant, diagnostic: [e instanceof Error ? e.message : "Client service role indisponible."] };
  }

  if (existant) {
    const { error } = await admin.from("utilisateurs").update({ role: "administrateur" }).eq("id", existant.id);
    if (error) diagnostic.push(`Passage administrateur refusé : ${error.message}`);
    return { utilisateur: error ? existant : { ...existant, role: "administrateur" }, diagnostic };
  }

  const role: Role = master ? "administrateur" : "gestionnaire";
  const { data: candidats, error: erreurLecture } = await admin.from("utilisateurs").select(COLONNES).is("auth_user_id", null).ilike("email", email.trim()).limit(2);
  if (erreurLecture) diagnostic.push(`Lecture des fiches : ${erreurLecture.message}`);
  if (candidats?.length === 1) {
    const ligne = candidats[0] as Utilisateur;
    const roleLigne: Role = master ? "administrateur" : (ligne.role ?? "gestionnaire");
    const { error } = await admin.from("utilisateurs").update({ auth_user_id: authUserId, role: roleLigne }).eq("id", ligne.id).is("auth_user_id", null);
    if (!error) return { utilisateur: { ...ligne, role: roleLigne }, diagnostic };
    diagnostic.push(`Rattachement à la fiche ${ligne.id} refusé : ${error.message}`);
  } else if (candidats && candidats.length > 1) {
    diagnostic.push(`${candidats.length} fiches non rattachées portent cet e-mail : création d'un compte indépendant.`);
  }

  const { data, error } = await admin
    .from("utilisateurs")
    .insert({ nom: email, email, role, auth_user_id: authUserId, compte_application: true })
    .select(COLONNES)
    .single();
  if (error) diagnostic.push(`Création du compte application refusée : ${error.message}`);
  return { utilisateur: error ? null : (data as Utilisateur), diagnostic };
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

  const { data: existant } = await supabase.from("utilisateurs").select(COLONNES).eq("auth_user_id", user.id).maybeSingle();

  const { utilisateur, diagnostic } = await rattacher(user.id, user.email, (existant as Utilisateur | null) ?? null);

  return {
    authUser: { id: user.id, email: user.email ?? null },
    utilisateur,
    role: utilisateur?.role ?? null,
    diagnostic,
  };
});
