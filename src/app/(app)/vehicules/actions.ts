"use server";

import { z } from "zod";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { enregistrerJournal } from "@/lib/journal";
import { requireUtilisateur, redirectWithError } from "@/lib/action-utils";
import { booleen, entier, identifiant, obligatoire, premiereErreur, texte } from "@/lib/zod-form";
import { TYPES_RELEVE_KM } from "@/lib/vehicules";

const VehiculeSchema = z.object({
  immatriculation: obligatoire("L'immatriculation est obligatoire.").transform((s) => s.toUpperCase()),
  etat_code: entier,
  marque: texte,
  modele: texte,
  societe_vehicule: entier,
  conducteur_id: entier,
  date_mise_en_circulation: texte,
  km_achat: entier,
  dernier_km: entier,
  km_entre_revisions: entier,
  mois_entre_revisions: entier,
  garantie: booleen,
  garantie_km: entier,
  garantie_mois: entier,
  leasing: booleen,
  leasing_km: entier,
  leasing_mois: entier,
  leasing_date_fin: texte,
  numero_telepeage: texte,
  carte_essence_code: texte,
  carte_essence_numero: texte,
  crit_air: booleen,
  dossier_chemin: texte,
});

export async function creerVehicule(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const parsed = VehiculeSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError("/vehicules/nouveau", premiereErreur(parsed));

  const supabase = await createClient();
  const { data: created, error } = await supabase.from("vehicules").insert(parsed.data).select("id").single();
  if (error || !created) redirectWithError("/vehicules/nouveau", "La création a échoué.");

  await enregistrerJournal(supabase, "vehicules", created.id, utilisateur.id, { action: "creation" });
  revalidatePath("/vehicules");
  redirect(`/vehicules/${created.id}`);
}

export async function mettreAJourVehicule(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const id = Number(formData.get("vehicule_id"));
  const parsed = VehiculeSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError(`/vehicules/${id}`, premiereErreur(parsed));

  const supabase = await createClient();
  const { error } = await supabase.from("vehicules").update(parsed.data).eq("id", id);
  if (error) redirectWithError(`/vehicules/${id}`, "La mise à jour a échoué.");

  await enregistrerJournal(supabase, "vehicules", id, utilisateur.id, { action: "maj" });
  revalidatePath("/vehicules");
  revalidatePath(`/vehicules/${id}`);
  redirect(`/vehicules/${id}?info=${encodeURIComponent("Véhicule enregistré.")}`);
}

const EvenementSchema = z.object({
  vehicule_id: identifiant,
  type_code: z.coerce.number().int({ message: "Merci de renseigner un type d'événement." }),
  date_evenement: obligatoire("Merci de renseigner une date."),
  km: z.coerce.number().int().min(0, "Merci de renseigner un kilométrage."),
  conducteur_id: entier,
});

/** Saisie_EV_Vehicule.Verif_Data : pour un relevé km, le kilométrage doit être ≥ au dernier relevé du véhicule. */
export async function ajouterEvenement(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const vehiculeId = Number(formData.get("vehicule_id"));
  const retour = `/vehicules/${vehiculeId}`;
  const parsed = EvenementSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError(retour, premiereErreur(parsed));
  const e = parsed.data;

  const supabase = await createClient();
  const { data: vehicule } = await supabase.from("vehicules").select("immatriculation, conducteur_id, dernier_km").eq("id", vehiculeId).maybeSingle();
  if (!vehicule) redirectWithError(retour, "Véhicule introuvable.");

  if (TYPES_RELEVE_KM.includes(e.type_code)) {
    const { data: dernier } = await supabase
      .from("vehicule_evenements")
      .select("km")
      .eq("vehicule_id", vehiculeId)
      .in("type_code", TYPES_RELEVE_KM)
      .order("km", { ascending: false })
      .limit(1)
      .maybeSingle();
    if (dernier && e.km < dernier.km) redirectWithError(retour, `Le dernier kilométrage saisi pour ${vehicule.immatriculation} est ${dernier.km}, merci de changer votre saisie.`);
  }

  const { error } = await supabase.from("vehicule_evenements").insert({
    vehicule_id: vehiculeId,
    type_code: e.type_code,
    date_evenement: e.date_evenement,
    km: e.km,
    conducteur_id: e.conducteur_id ?? vehicule.conducteur_id,
    immatriculation: vehicule.immatriculation,
  });
  if (error) redirectWithError(retour, "L'ajout de l'événement a échoué.");
  if (e.km > (vehicule.dernier_km ?? 0)) await supabase.from("vehicules").update({ dernier_km: e.km }).eq("id", vehiculeId);

  await enregistrerJournal(supabase, "vehicules", vehiculeId, utilisateur.id, { action: "evenement", type_code: e.type_code, km: e.km });
  revalidatePath(retour);
  redirect(`${retour}?info=${encodeURIComponent("Événement ajouté.")}`);
}

export async function supprimerEvenement(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const vehiculeId = Number(formData.get("vehicule_id"));
  const evenementId = Number(formData.get("evenement_id"));
  const supabase = await createClient();
  const { error } = await supabase.from("vehicule_evenements").delete().eq("id", evenementId).eq("vehicule_id", vehiculeId);
  if (error) redirectWithError(`/vehicules/${vehiculeId}`, "La suppression a échoué.");
  await enregistrerJournal(supabase, "vehicules", vehiculeId, utilisateur.id, { action: "suppression_evenement", evenement_id: evenementId });
  revalidatePath(`/vehicules/${vehiculeId}`);
  redirect(`/vehicules/${vehiculeId}`);
}
