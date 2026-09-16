"use server";

import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { enregistrerJournal } from "@/lib/journal";
import { requireAdministrateur, redirectWithError } from "@/lib/action-utils";
import { getReferentiel, type ColonneConfig } from "@/lib/referentiels-config";

const DOUBLON = "23505";
const REFERENCE_UTILISEE = "23503";

function valeurColonne(colonne: ColonneConfig, brut: FormDataEntryValue | null): { valeur: unknown; erreur?: string } {
  const texte = typeof brut === "string" ? brut.trim() : "";
  if (colonne.type === "boolean") return { valeur: texte === "1" };
  if (texte === "") return colonne.required ? { valeur: null, erreur: `« ${colonne.label} » est obligatoire.` } : { valeur: null };
  if (colonne.type === "number" || colonne.type === "select") {
    const n = Number(texte);
    return Number.isFinite(n) ? { valeur: n } : { valeur: null, erreur: `« ${colonne.label} » doit être un nombre.` };
  }
  return { valeur: texte };
}

/** Création (`ligne_id` vide) ou mise à jour d'une ligne de référentiel, colonnes pilotées par la configuration. */
export async function enregistrerReferentiel(formData: FormData) {
  const slug = String(formData.get("slug") ?? "");
  const config = getReferentiel(slug);
  if (!config) redirectWithError("/parametrage", "Référentiel inconnu.");
  const retour = `/parametrage/${slug}`;
  const { utilisateur } = await requireAdministrateur(retour);
  const ligneId = Number(formData.get("ligne_id")) || null;
  const retourFormulaire = ligneId ? `${retour}?modifier=${ligneId}` : `${retour}?ajouter=1`;

  const payload: Record<string, unknown> = {};
  for (const colonne of config.columns) {
    const { valeur, erreur } = valeurColonne(colonne, formData.get(colonne.key));
    if (erreur) redirectWithError(retourFormulaire, erreur);
    payload[colonne.key] = valeur;
  }

  const supabase = await createClient();
  if (config.codeAuto && payload.code == null) {
    const { data: dernier } = await supabase.from(config.table).select("code").order("code", { ascending: false }).limit(1).maybeSingle();
    payload.code = (Number(dernier?.code) || 0) + 1;
  }

  if (ligneId) {
    const { error } = await supabase.from(config.table).update(payload).eq("id", ligneId);
    if (error?.code === DOUBLON) redirectWithError(retourFormulaire, "Cette valeur existe déjà (code ou libellé unique).");
    if (error) redirectWithError(retourFormulaire, "La mise à jour a échoué.");
    await enregistrerJournal(supabase, config.table, ligneId, utilisateur.id, { action: "maj", ...payload });
  } else {
    const { data: created, error } = await supabase.from(config.table).insert(payload).select("id").single();
    if (error?.code === DOUBLON) redirectWithError(retourFormulaire, "Cette valeur existe déjà (code ou libellé unique).");
    if (error || !created) redirectWithError(retourFormulaire, "La création a échoué.");
    await enregistrerJournal(supabase, config.table, created.id, utilisateur.id, { action: "creation", ...payload });
  }

  revalidatePath(retour);
  redirect(`${retour}?info=${encodeURIComponent("Enregistré.")}`);
}

export async function supprimerReferentiel(formData: FormData) {
  const slug = String(formData.get("slug") ?? "");
  const config = getReferentiel(slug);
  if (!config) redirectWithError("/parametrage", "Référentiel inconnu.");
  const retour = `/parametrage/${slug}`;
  const { utilisateur } = await requireAdministrateur(retour);
  const ligneId = Number(formData.get("ligne_id"));
  if (!ligneId) redirectWithError(retour, "Ligne introuvable.");

  const supabase = await createClient();
  const { error } = await supabase.from(config.table).delete().eq("id", ligneId);
  if (error?.code === REFERENCE_UTILISEE) redirectWithError(retour, "Impossible de supprimer : cette valeur est utilisée. Désactivez-la ou modifiez son libellé.");
  if (error) redirectWithError(retour, "La suppression a échoué.");

  await enregistrerJournal(supabase, config.table, ligneId, utilisateur.id, { action: "suppression" });
  revalidatePath(retour);
  redirect(`${retour}?info=${encodeURIComponent("Ligne supprimée.")}`);
}
