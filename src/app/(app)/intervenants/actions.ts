"use server";

import { z } from "zod";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { enregistrerJournal } from "@/lib/journal";
import { requireUtilisateur, redirectWithError } from "@/lib/action-utils";
import { booleen, entier, nombre, obligatoire, texte, premiereErreur } from "@/lib/zod-form";
import { MAX_ACTIVITES, MAX_ZONES } from "@/lib/intervenants";

const DOUBLON = "23505";

function versIntervenant(id: number, params?: Record<string, string>) {
  const q = new URLSearchParams(params).toString();
  return `/intervenants/${id}${q ? `?${q}` : ""}`;
}

const FicheSchema = z.object({
  code: obligatoire("Le code intervenant est obligatoire.").transform((c) => c.toUpperCase()),
  nom: texte,
  adresse: texte,
  code_postal: texte,
  ville: texte,
  telephone: texte,
  fax: texte,
  email: texte,
  email_facturation: texte,
  site_internet: texte,
  dirigeant_nom: texte,
  dirigeant_telephone: texte,
  dirigeant_email: texte,
  interlocuteur_nom: texte,
  interlocuteur_telephone: texte,
  interlocuteur_fmc_id: entier,
  provenance: texte,
  informations: texte,
  historique_fmc: texte,
  villes_codes_postaux: texte,
  dossier_chemin: texte,
  note_maintenance: entier,
  note_depannage: entier,
  note_travaux: entier,
  note_reactivite: entier,
  est_technicien_interne: booleen,
  est_prospect: booleen,
  est_sous_traitant: booleen,
  est_sous_traitant_ponctuel: booleen,
  peut_maintenance: booleen,
  peut_depannage: booleen,
  peut_travaux: booleen,
  confie_maintenance: booleen,
  confie_depannage: booleen,
  confie_travaux: booleen,
  zone_nationale: booleen,
  n_existe_plus: booleen,
  autoliquidation: booleen,
});

export async function creerIntervenant(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const parsed = FicheSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError("/intervenants/nouveau", premiereErreur(parsed));

  const supabase = await createClient();
  const { data: created, error } = await supabase.from("intervenants").insert({ ...parsed.data, cree_par_id: utilisateur.id }).select("id").single();
  if (error?.code === DOUBLON) redirectWithError("/intervenants/nouveau", "Ce code intervenant existe déjà.");
  if (error || !created) redirectWithError("/intervenants/nouveau", "La création a échoué.");

  await enregistrerJournal(supabase, "intervenants", created.id, utilisateur.id, { action: "creation" });
  revalidatePath("/intervenants");
  redirect(versIntervenant(created.id));
}

export async function mettreAJourIntervenant(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const id = Number(formData.get("intervenant_id"));
  const parsed = FicheSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError(versIntervenant(id), premiereErreur(parsed));

  const supabase = await createClient();
  const { error } = await supabase.from("intervenants").update(parsed.data).eq("id", id);
  if (error?.code === DOUBLON) redirectWithError(versIntervenant(id), "Ce code intervenant existe déjà.");
  if (error) redirectWithError(versIntervenant(id), "La mise à jour a échoué.");

  await enregistrerJournal(supabase, "intervenants", id, utilisateur.id, { action: "maj" });
  revalidatePath("/intervenants");
  revalidatePath(versIntervenant(id));
  redirect(versIntervenant(id, { info: "Intervenant enregistré." }));
}

/** Six lignes d'activité au plus (analysis 03 §4.3) : les lignes vides sont ignorées, le rang suit l'ordre saisi. */
export async function mettreAJourActivites(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const id = Number(formData.get("intervenant_id"));
  const retour = versIntervenant(id, { onglet: "activites" });

  const lignes = [];
  for (let i = 1; i <= MAX_ACTIVITES; i++) {
    const activite = Number(formData.get(`activite_id_${i}`)) || null;
    if (!activite) continue;
    const ligne = z
      .object({ tarif_mo: nombre, tarif_deplacement: nombre, date_tarif: texte })
      .safeParse({ tarif_mo: formData.get(`tarif_mo_${i}`), tarif_deplacement: formData.get(`tarif_deplacement_${i}`), date_tarif: formData.get(`date_tarif_${i}`) });
    if (!ligne.success) redirectWithError(retour, `Ligne ${i} : ${premiereErreur(ligne, "valeur invalide.")}`);
    lignes.push({ intervenant_id: id, rang: lignes.length + 1, activite_id: activite, ...ligne.data });
  }

  const supabase = await createClient();
  const { error: erreurSuppression } = await supabase.from("intervenant_activites").delete().eq("intervenant_id", id);
  if (erreurSuppression) redirectWithError(retour, "L'enregistrement des activités a échoué.");
  if (lignes.length > 0) {
    const { error } = await supabase.from("intervenant_activites").insert(lignes);
    if (error) redirectWithError(retour, "L'enregistrement des activités a échoué.");
  }

  await enregistrerJournal(supabase, "intervenants", id, utilisateur.id, { action: "maj_activites", lignes: lignes.length });
  revalidatePath(versIntervenant(id));
  redirect(retour);
}

/** Quatre zones au plus (analysis 03 §4.4) ; la zone nationale est un indicateur de la fiche. */
export async function mettreAJourZones(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const id = Number(formData.get("intervenant_id"));
  const retour = versIntervenant(id, { onglet: "zones" });

  const zones = new Set<number>();
  for (let i = 1; i <= MAX_ZONES; i++) {
    const zone = Number(formData.get(`zone_id_${i}`)) || null;
    if (zone) zones.add(zone);
  }
  const lignes = [...zones].map((zone_id, i) => ({ intervenant_id: id, rang: i + 1, zone_id }));

  const supabase = await createClient();
  const { error: erreurSuppression } = await supabase.from("intervenant_zones").delete().eq("intervenant_id", id);
  if (erreurSuppression) redirectWithError(retour, "L'enregistrement des zones a échoué.");
  if (lignes.length > 0) {
    const { error } = await supabase.from("intervenant_zones").insert(lignes);
    if (error) redirectWithError(retour, "L'enregistrement des zones a échoué.");
  }
  await supabase.from("intervenants").update({ zone_nationale: formData.get("zone_nationale") === "1" }).eq("id", id);

  await enregistrerJournal(supabase, "intervenants", id, utilisateur.id, { action: "maj_zones", zones: [...zones] });
  revalidatePath(versIntervenant(id));
  redirect(retour);
}

/** « Ne plus intervenir » avec motif ; sans effet sur les interventions (analysis 03 §4.2). */
export async function basculerNePlusIntervenirIntervenant(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const id = Number(formData.get("intervenant_id"));
  const activer = formData.get("actif") === "1";
  const motif = String(formData.get("motif_ne_plus_intervenir") ?? "").trim();
  if (activer && !motif) redirectWithError(versIntervenant(id, { confirmer: "ne_plus_intervenir" }), "Indiquez le motif.");

  const supabase = await createClient();
  const { error } = await supabase
    .from("intervenants")
    .update({ ne_plus_intervenir: activer, motif_ne_plus_intervenir: activer ? motif : null })
    .eq("id", id);
  if (error) redirectWithError(versIntervenant(id), "La mise à jour a échoué.");

  await enregistrerJournal(supabase, "intervenants", id, utilisateur.id, { action: activer ? "ne_plus_intervenir" : "reprise", motif });
  revalidatePath("/intervenants");
  revalidatePath(versIntervenant(id));
  redirect(versIntervenant(id, { info: activer ? "Intervenant marqué « Ne plus intervenir »." : "Intervenant réactivé." }));
}
