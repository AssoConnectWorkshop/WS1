"use server";

import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { requireUtilisateur, redirectWithError } from "@/lib/action-utils";
import { TABLEAUX, estColonneDe, estTableau, type Tableau } from "@/lib/taches";

const tableauDe = (v: unknown): Tableau => (estTableau(v) ? v : "projet");
const retourDe = (tableau: Tableau) => TABLEAUX[tableau].href;

async function ordreSuivant(tableau: Tableau, colonne: string) {
  const supabase = await createClient();
  const { data } = await supabase.from("taches").select("ordre").eq("tableau", tableau).eq("colonne", colonne).order("ordre", { ascending: false }).limit(1).maybeSingle();
  return (data?.ordre ?? 0) + 1;
}

export async function creerTache(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const tableau = tableauDe(formData.get("tableau"));
  const retour = retourDe(tableau);
  const titre = String(formData.get("titre") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim() || null;
  const colonneBrute = formData.get("colonne");
  const colonne = estColonneDe(tableau, colonneBrute) ? colonneBrute : TABLEAUX[tableau].colonnes[0].key;
  if (!titre) redirectWithError(retour, "Le titre est obligatoire.");

  const supabase = await createClient();
  const { error } = await supabase.from("taches").insert({ tableau, titre, description, colonne, ordre: await ordreSuivant(tableau, colonne), cree_par_id: utilisateur.id });
  if (error) redirectWithError(retour, "La création a échoué.");
  revalidatePath(retour);
  redirect(retour);
}

export async function modifierTache(formData: FormData) {
  await requireUtilisateur();
  const tableau = tableauDe(formData.get("tableau"));
  const retour = retourDe(tableau);
  const id = Number(formData.get("tache_id"));
  const titre = String(formData.get("titre") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim() || null;
  const colonne = formData.get("colonne");
  if (!id || !titre) redirectWithError(retour, "Le titre est obligatoire.");

  const supabase = await createClient();
  const { error } = await supabase.from("taches").update({ titre, description, colonne: estColonneDe(tableau, colonne) ? colonne : undefined }).eq("id", id);
  if (error) redirectWithError(retour, "La modification a échoué.");
  revalidatePath(retour);
  redirect(retour);
}

export async function supprimerTache(formData: FormData) {
  await requireUtilisateur();
  const tableau = tableauDe(formData.get("tableau"));
  const retour = retourDe(tableau);
  const id = Number(formData.get("tache_id"));
  if (!id) return;
  const supabase = await createClient();
  await supabase.from("taches").delete().eq("id", id);
  revalidatePath(retour);
  redirect(retour);
}

/** Glisser-déposer : appel direct depuis le composant client, sans redirection. */
export async function deposerTache(id: number, tableau: string, colonne: string, ordre: number) {
  await requireUtilisateur();
  const t = tableauDe(tableau);
  if (!id || !estColonneDe(t, colonne)) return { ok: false };
  const supabase = await createClient();
  const { error } = await supabase.from("taches").update({ colonne, ordre }).eq("id", id);
  revalidatePath(retourDe(t));
  return { ok: !error };
}
