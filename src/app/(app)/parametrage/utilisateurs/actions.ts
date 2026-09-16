"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { getCurrentUser, type Role } from "@/lib/auth";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { redirectWithError } from "@/lib/action-utils";
import { MOTIF_BLOCAGE, emailAutorise } from "@/lib/garde-emails";

const RETOUR = "/parametrage/utilisateurs";

async function requireAdministrateur() {
  const current = await getCurrentUser();
  if (!current?.utilisateur || current.role !== "administrateur") {
    redirect("/login");
  }
  return current;
}

export async function inviteUtilisateur(formData: FormData) {
  await requireAdministrateur();

  const utilisateurId = Number(formData.get("utilisateurId"));
  if (!utilisateurId) return;

  const supabase = await createClient();
  const { data: utilisateur } = await supabase
    .from("utilisateurs")
    .select("id, email, auth_user_id")
    .eq("id", utilisateurId)
    .single();

  if (!utilisateur?.email || utilisateur.auth_user_id) return;

  // Triple ceinture : l'administrateur retape l'adresse, qui doit figurer dans la liste blanche.
  const confirmation = String(formData.get("confirmation") ?? "").trim().toLowerCase();
  if (confirmation !== utilisateur.email.trim().toLowerCase()) {
    redirectWithError(RETOUR, "Invitation refusée : l'adresse retapée ne correspond pas à celle de la ligne.");
  }
  if (!emailAutorise(utilisateur.email)) redirectWithError(RETOUR, MOTIF_BLOCAGE);

  const admin = createAdminClient();
  const site = process.env.NEXT_PUBLIC_SITE_URL ?? "https://assoconnect-ws1.vercel.app";
  const { data, error } = await admin.auth.admin.inviteUserByEmail(utilisateur.email, {
    redirectTo: `${site}/auth/callback?next=/reset-password`,
  });

  if (error || !data.user) redirectWithError(RETOUR, `Invitation non envoyée : ${error?.message ?? "erreur inconnue"}.`);

  // La table utilisateurs restreint l'écriture au rôle administrateur (cf. migration
  // dédiée à l'étape 3) : passer par le client admin garantit l'écriture même si la
  // politique RLS venait à changer côté requête utilisateur.
  await admin
    .from("utilisateurs")
    .update({ auth_user_id: data.user.id, role: "gestionnaire" })
    .eq("id", utilisateurId);

  revalidatePath(RETOUR);
  redirect(`${RETOUR}?info=${encodeURIComponent(`Invitation envoyée à ${utilisateur.email}.`)}`);
}

export async function changerRole(formData: FormData) {
  await requireAdministrateur();

  const utilisateurId = Number(formData.get("utilisateurId"));
  const role = formData.get("role");
  if (!utilisateurId || (role !== "administrateur" && role !== "gestionnaire" && role !== "comptable")) return;

  const admin = createAdminClient();
  await admin.from("utilisateurs").update({ role: role as Role }).eq("id", utilisateurId);

  revalidatePath("/parametrage/utilisateurs");
}
