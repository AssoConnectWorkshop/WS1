"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { getCurrentUser, type Role } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { z } from "zod";
import { redirectWithError } from "@/lib/action-utils";
import { enregistrerJournal } from "@/lib/journal";

const RETOUR = "/parametrage/utilisateurs";

async function requireAdministrateur() {
  const current = await getCurrentUser();
  if (!current?.utilisateur || current.role !== "administrateur") {
    redirect("/login");
  }
  return current;
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

const AjoutSchema = z.object({
  nom: z.string().trim().min(1, "Le nom est obligatoire.").max(120),
  prenom: z.string().trim().max(120).optional(),
  email: z.union([z.literal(""), z.string().trim().toLowerCase().email("Adresse e-mail invalide.")]).optional(),
  profil: z.coerce.number().int().refine((p) => [1, 2, 3].includes(p), "Type utilisateur invalide."),
});

/** Ajout d'une fiche (feuille de données Access) ; l'accès à l'application se crée ensuite dans Accès application. */
export async function ajouterUtilisateur(formData: FormData) {
  const auteur = await requireAdministrateur();
  const parsed = AjoutSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError(RETOUR, parsed.error.issues[0]?.message ?? "Saisie invalide.");
  const { nom, prenom, email, profil } = parsed.data;

  const admin = createAdminClient();
  if (email) {
    const { data: doublon } = await admin.from("utilisateurs").select("id").ilike("email", email).limit(1);
    if (doublon?.length) redirectWithError(RETOUR, `Une fiche porte déjà l'adresse ${email}.`);
  }
  const { data, error } = await admin
    .from("utilisateurs")
    .insert({ nom, prenom: prenom || null, email: email || null, profil })
    .select("id")
    .single();
  if (error || !data) redirectWithError(RETOUR, `Ajout refusé : ${error?.message ?? "erreur inconnue"}.`);
  await enregistrerJournal(admin, "utilisateurs", data.id, auteur.utilisateur?.id ?? null, { action: "ajout", nom, email });

  revalidatePath(RETOUR);
  redirect(`${RETOUR}?info=${encodeURIComponent(`Fiche ${nom} ajoutée.`)}&q=${encodeURIComponent(email || nom)}`);
}
