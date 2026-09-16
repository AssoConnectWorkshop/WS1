"use server";

import { z } from "zod";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { enregistrerJournal } from "@/lib/journal";
import { requireAdministrateur, redirectWithError } from "@/lib/action-utils";
import { booleen, entier, identifiant, obligatoire, texte } from "@/lib/zod-form";

const RETOUR = "/parametrage/catalogue";

const entierW = z.preprocess(
  (v) => (v == null || v === "" ? null : Number(v)),
  z.number({ invalid_type_error: "Les puissances sont des entiers en W." }).int("Les puissances sont des entiers en W.").nullable(),
);

/** Règles Form_Saisie_Reference.Verif_Data (analysis 03 §3.5). */
const ReferenceSchema = z.object({
  reference: obligatoire("Veuillez vérifier le nom de la référence."),
  marque_id: z.coerce.number().int().positive("Veuillez vérifier la marque."),
  type_equipement: obligatoire("Veuillez vérifier le type."),
  repere: obligatoire("Veuillez vérifier le repère."),
  fluide_id: z.coerce.number().int().positive("Veuillez vérifier le fluide."),
  type_telecommande: obligatoire("Veuillez vérifier le type de télécommande."),
  reversible: z.enum(["OUI", "NON", "NC"], { message: "Veuillez vérifier réversible (OUI / NON / NC)." }),
  resistance: z.enum(["OUI", "NON", "NC"], { message: "Veuillez vérifier la résistance (OUI / NON / NC)." }),
  quantite_gaz: texte.refine((v) => v == null || Number.isFinite(Number(v)), "La quantité de gaz (kg) doit être numérique."),
  puissance_frigo: entierW,
  puissance_calo: entierW,
  nombre_filtres: texte.refine((v) => v == null || Number.isFinite(Number(v)), "Le nombre de filtres doit être numérique."),
  dimension_filtres: texte,
  nombre_courroies: texte.refine((v) => v == null || Number.isFinite(Number(v)), "Le nombre de courroies doit être numérique."),
  reference_courroies: texte,
  appoint_roof: texte,
  propager: booleen,
  reference_id: entier,
});

export async function enregistrerReference(formData: FormData) {
  const { utilisateur } = await requireAdministrateur(RETOUR);
  const parsed = ReferenceSchema.safeParse(Object.fromEntries(formData));
  const modifierId = Number(formData.get("reference_id")) || null;
  const retourFormulaire = modifierId ? `${RETOUR}?modifier=${modifierId}` : RETOUR;
  if (!parsed.success) redirectWithError(retourFormulaire, parsed.error.issues[0]?.message ?? "Formulaire invalide.");
  const { propager, reference_id, ...ligne } = parsed.data;

  const supabase = await createClient();
  const { data: homonyme } = await supabase.from("references_materiel").select("id").eq("reference", ligne.reference).neq("id", reference_id ?? -1).maybeSingle();
  if (homonyme) redirectWithError(retourFormulaire, "Le nom de la référence existe déjà dans la base.");

  if (reference_id) {
    const { data: avant } = await supabase.from("references_materiel").select("reference").eq("id", reference_id).maybeSingle();
    const { error } = await supabase.from("references_materiel").update(ligne).eq("id", reference_id);
    if (error) redirectWithError(retourFormulaire, "La mise à jour a échoué.");

    let propagees = 0;
    if (propager && avant?.reference) {
      // Modif_BD_Materiel : tout sauf fluide et charge (chaque équipement garde sa charge réelle).
      const [{ data: marque }, { data: maj }] = await Promise.all([
        supabase.from("marques").select("libelle").eq("id", ligne.marque_id).maybeSingle(),
        supabase
          .from("site_materiels")
          .update({
            reference: ligne.reference,
            repere: ligne.repere,
            type_equipement: ligne.type_equipement,
            type_telecommande: ligne.type_telecommande,
            reversible: ligne.reversible,
            resistance_electrique: ligne.resistance,
            puissance_frigo_w: ligne.puissance_frigo,
            puissance_calo_w: ligne.puissance_calo,
            rooftop_nombre_filtres: ligne.nombre_filtres ? Number(ligne.nombre_filtres) : null,
            rooftop_reference_filtres: ligne.dimension_filtres,
            rooftop_nombre_courroies: ligne.nombre_courroies ? Number(ligne.nombre_courroies) : null,
            rooftop_reference_courroies: ligne.reference_courroies,
            rooftop_appoint_chauffage: ligne.appoint_roof,
          })
          .eq("reference", avant.reference)
          .select("id"),
      ]);
      propagees = maj?.length ?? 0;
      if (propagees && marque?.libelle) await supabase.from("site_materiels").update({ marque: marque.libelle }).eq("reference", ligne.reference);
    }

    await enregistrerJournal(supabase, "references_materiel", reference_id, utilisateur.id, { action: "maj", propagees });
    revalidatePath(RETOUR);
    redirect(`${RETOUR}?info=${encodeURIComponent(propager ? `Référence enregistrée, ${propagees} équipement(s) mis à jour.` : "Référence enregistrée.")}`);
  }

  const { data: created, error } = await supabase.from("references_materiel").insert(ligne).select("id").single();
  if (error || !created) redirectWithError(RETOUR, "La création a échoué.");
  await enregistrerJournal(supabase, "references_materiel", created.id, utilisateur.id, { action: "creation" });
  revalidatePath(RETOUR);
  redirect(`${RETOUR}?info=${encodeURIComponent("Référence ajoutée.")}`);
}

export async function supprimerReference(formData: FormData) {
  const { utilisateur } = await requireAdministrateur(RETOUR);
  const id = identifiant.safeParse(formData.get("reference_id"));
  if (!id.success) redirectWithError(RETOUR, "Référence introuvable.");

  const supabase = await createClient();
  const { error } = await supabase.from("references_materiel").delete().eq("id", id.data);
  if (error) redirectWithError(RETOUR, "La suppression a échoué.");

  await enregistrerJournal(supabase, "references_materiel", id.data, utilisateur.id, { action: "suppression" });
  revalidatePath(RETOUR);
  redirect(`${RETOUR}?info=${encodeURIComponent("Référence supprimée (les équipements existants sont conservés).")}`);
}
