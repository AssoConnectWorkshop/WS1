"use server";

import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { requireUtilisateur, redirectWithError } from "@/lib/action-utils";
import { COLONNES, type Colonne } from "@/lib/taches";

const estColonne = (v: unknown): v is Colonne => typeof v === "string" && COLONNES.some((c) => c.key === v);

export async function creerTache(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const titre = String(formData.get("titre") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim() || null;
  const colonne = formData.get("colonne");
  if (!titre) redirectWithError("/taches", "Le titre est obligatoire.");

  const supabase = await createClient();
  const { data: dernier } = await supabase.from("taches").select("ordre").eq("colonne", estColonne(colonne) ? colonne : "backlog").order("ordre", { ascending: false }).limit(1).maybeSingle();
  const { error } = await supabase.from("taches").insert({ titre, description, colonne: estColonne(colonne) ? colonne : "backlog", ordre: (dernier?.ordre ?? 0) + 1, cree_par_id: utilisateur.id });
  if (error) redirectWithError("/taches", "La création a échoué.");
  revalidatePath("/taches");
  redirect("/taches");
}

export async function modifierTache(formData: FormData) {
  await requireUtilisateur();
  const id = Number(formData.get("tache_id"));
  const titre = String(formData.get("titre") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim() || null;
  const colonne = formData.get("colonne");
  if (!id || !titre) redirectWithError("/taches", "Le titre est obligatoire.");

  const supabase = await createClient();
  const { error } = await supabase.from("taches").update({ titre, description, colonne: estColonne(colonne) ? colonne : undefined }).eq("id", id);
  if (error) redirectWithError("/taches", "La modification a échoué.");
  revalidatePath("/taches");
  redirect("/taches");
}

/** Déplace une carte dans la colonne voisine (← / →) ou dans une colonne donnée. */
export async function deplacerTache(formData: FormData) {
  await requireUtilisateur();
  const id = Number(formData.get("tache_id"));
  const colonne = formData.get("colonne");
  if (!id || !estColonne(colonne)) return;

  const supabase = await createClient();
  const { data: dernier } = await supabase.from("taches").select("ordre").eq("colonne", colonne).order("ordre", { ascending: false }).limit(1).maybeSingle();
  await supabase.from("taches").update({ colonne, ordre: (dernier?.ordre ?? 0) + 1 }).eq("id", id);
  revalidatePath("/taches");
  redirect("/taches");
}

export async function supprimerTache(formData: FormData) {
  await requireUtilisateur();
  const id = Number(formData.get("tache_id"));
  if (!id) return;
  const supabase = await createClient();
  await supabase.from("taches").delete().eq("id", id);
  revalidatePath("/taches");
  redirect("/taches");
}
