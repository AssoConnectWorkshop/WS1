"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { z } from "zod";
import { getCurrentUser, type Role } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { enregistrerJournal } from "@/lib/journal";
import { estMasterAdmin, motDePasseInitial } from "@/lib/acces";

const CHEMIN = "/parametrage/acces";
const ROLES = ["gestionnaire", "comptable", "administrateur"] as const;

async function requireAdministrateur() {
  const current = await getCurrentUser();
  if (!current?.utilisateur || current.role !== "administrateur") redirect("/login");
  return current.utilisateur;
}

export type ResultatCreation = { ok: true; email: string; motDePasse: string } | { ok: false; erreur: string } | null;

const CreationSchema = z.object({
  email: z.string().trim().toLowerCase().email("Adresse e-mail invalide."),
  nom: z.string().trim().max(120).optional(),
  role: z.enum(ROLES),
});

/**
 * Crée un accès sans envoyer d'e-mail : compte Supabase Auth confirmé d'office + ligne
 * `utilisateurs` (rattachée à la fiche FMC de même e-mail si elle existe, sinon compte_application).
 * Le mot de passe initial n'est renvoyé qu'une fois, à l'écran de l'administrateur.
 */
export async function creerAcces(_precedent: ResultatCreation, formData: FormData): Promise<ResultatCreation> {
  const auteur = await requireAdministrateur();
  const parsed = CreationSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return { ok: false, erreur: parsed.error.issues[0]?.message ?? "Saisie invalide." };
  const { email, nom, role } = parsed.data;

  let admin: ReturnType<typeof createAdminClient>;
  try {
    admin = createAdminClient();
  } catch {
    return { ok: false, erreur: "SUPABASE_SERVICE_ROLE_KEY absente : création impossible." };
  }

  const { data: existants } = await admin.from("utilisateurs").select("id, auth_user_id").ilike("email", email).limit(2);
  if (existants?.some((u) => u.auth_user_id)) return { ok: false, erreur: "Cette adresse a déjà un accès." };

  const motDePasse = motDePasseInitial();
  const { data: cree, error } = await admin.auth.admin.createUser({ email, password: motDePasse, email_confirm: true });
  if (error || !cree.user) return { ok: false, erreur: `Compte non créé : ${error?.message ?? "erreur inconnue"}.` };

  const roleFinal: Role = estMasterAdmin(email) ? "administrateur" : role;
  let ligneId: number | null = null;
  if (existants?.length === 1) {
    const { data } = await admin.from("utilisateurs").update({ auth_user_id: cree.user.id, role: roleFinal }).eq("id", existants[0].id).select("id").single();
    ligneId = data?.id ?? null;
  } else {
    const { data } = await admin
      .from("utilisateurs")
      .insert({ nom: nom || email, email, role: roleFinal, auth_user_id: cree.user.id, compte_application: true })
      .select("id")
      .single();
    ligneId = data?.id ?? null;
  }
  if (ligneId) await enregistrerJournal(admin, "utilisateurs", ligneId, auteur.id, { action: "creer_acces", email, role: roleFinal });

  revalidatePath(CHEMIN);
  return { ok: true, email, motDePasse };
}

export async function changerRoleAcces(formData: FormData) {
  const auteur = await requireAdministrateur();
  const id = Number(formData.get("id"));
  const role = String(formData.get("role"));
  if (!id || !ROLES.includes(role as Role)) return;
  const admin = createAdminClient();
  const { data: cible } = await admin.from("utilisateurs").select("email").eq("id", id).maybeSingle();
  const roleFinal: Role = estMasterAdmin(cible?.email) ? "administrateur" : (role as Role);
  await admin.from("utilisateurs").update({ role: roleFinal }).eq("id", id);
  await enregistrerJournal(admin, "utilisateurs", id, auteur.id, { action: "changer_role", role: roleFinal });
  revalidatePath(CHEMIN);
}

/** Révocation : suppression du compte Auth (l'adresse retapée sert de confirmation) ; la fiche FMC reste. */
export async function revoquerAcces(formData: FormData) {
  const auteur = await requireAdministrateur();
  const id = Number(formData.get("id"));
  const confirmation = String(formData.get("confirmation") ?? "").trim().toLowerCase();
  if (!id) return;
  const admin = createAdminClient();
  const { data: cible } = await admin.from("utilisateurs").select("id, email, auth_user_id, compte_application").eq("id", id).maybeSingle();
  if (!cible?.auth_user_id || cible.email?.trim().toLowerCase() !== confirmation) {
    redirect(`${CHEMIN}?erreur=${encodeURIComponent("Révocation refusée : l'adresse retapée ne correspond pas.")}`);
  }
  if (estMasterAdmin(cible.email)) redirect(`${CHEMIN}?erreur=${encodeURIComponent("Un master admin (MASTER_ADMINS) ne se révoque pas depuis l'application.")}`);
  if (cible.id === auteur.id) redirect(`${CHEMIN}?erreur=${encodeURIComponent("Vous ne pouvez pas révoquer votre propre accès.")}`);

  await admin.auth.admin.deleteUser(cible.auth_user_id);
  if (cible.compte_application) await admin.from("utilisateurs").delete().eq("id", id);
  else await admin.from("utilisateurs").update({ auth_user_id: null }).eq("id", id);
  await enregistrerJournal(admin, "utilisateurs", id, auteur.id, { action: "revoquer_acces", email: cible.email });
  revalidatePath(CHEMIN);
  redirect(`${CHEMIN}?info=${encodeURIComponent(`Accès de ${cible.email} révoqué.`)}`);
}
