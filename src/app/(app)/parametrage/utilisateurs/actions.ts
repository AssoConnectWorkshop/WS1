"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { getCurrentUser, type Role } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";

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
