"use server";

import { z } from "zod";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { enregistrerJournal } from "@/lib/journal";
import { requireUtilisateur, redirectWithError } from "@/lib/action-utils";
import { premiereErreur } from "@/lib/zod-form";

/** Recalcule et persiste `interventions.noms_techniciens` (dénormalisé, utilisé par les listes). */
async function recalculerNomsTechniciens(supabase: Awaited<ReturnType<typeof createClient>>, interventionId: number) {
  const { data: techniciens } = await supabase
    .from("intervention_techniciens")
    .select("utilisateurs(nom, prenom)")
    .eq("intervention_id", interventionId);
  const noms = ((techniciens ?? []) as unknown as { utilisateurs: { nom: string | null; prenom: string | null } | null }[])
    .map((t) => [t.utilisateurs?.prenom, t.utilisateurs?.nom].filter(Boolean).join(" "))
    .filter(Boolean)
    .join(", ");
  await supabase.from("interventions").update({ noms_techniciens: noms || null }).eq("id", interventionId);
}

const CreationSchema = z.object({
  site_id: z.coerce.number().int().positive("Le site est obligatoire."),
  type_code: z.coerce.number().int({ message: "Le type est obligatoire." }),
  objet: z.string().trim().min(1, "L'objet est obligatoire."),
  date_limite: z.string().optional(),
  reference_client: z.string().optional(),
  contact_id: z.coerce.number().int().optional().or(z.literal("")),
  directives: z.string().optional(),
});

export async function creerIntervention(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const raw = Object.fromEntries(formData);
  const parsed = CreationSchema.safeParse(raw);
  if (!parsed.success) {
    redirectWithError("/interventions/nouvelle", premiereErreur(parsed));
  }
  const { site_id, type_code, objet, date_limite, reference_client, contact_id, directives } = parsed.data;

  const supabase = await createClient();
  const { data: site } = await supabase.from("sites").select("intervenant_id").eq("id", site_id).maybeSingle();
  if (!site) redirectWithError("/interventions/nouvelle", "Site introuvable.");

  const { data: created, error } = await supabase
    .from("interventions")
    .insert({
      site_id,
      type_code,
      objet,
      date_limite: date_limite || null,
      reference_client: reference_client || null,
      contact_id: contact_id ? Number(contact_id) : null,
      directives: directives || null,
      date_demande: new Date().toISOString(),
      statut_code: 1,
      nature_visite_code: 3,
      intervenant_id: site.intervenant_id,
      charge_affaire_id: utilisateur.id,
      saisi_par_id: utilisateur.id,
    })
    .select("id")
    .single();

  if (error || !created) {
    redirectWithError("/interventions/nouvelle", "La création a échoué. Réessayez.");
  }

  await enregistrerJournal(supabase, "interventions", created.id, utilisateur.id, { action: "creation" });
  revalidatePath("/interventions");

  const suffix = date_limite ? "" : "?avertissement=" + encodeURIComponent("La date limite d'intervention n'est pas saisie.");
  redirect(`/interventions/${created.id}${suffix}`);
}

const DemandeSchema = z.object({
  intervention_id: z.coerce.number().int(),
  objet: z.string().trim().min(1, "L'objet est obligatoire."),
  reference_client: z.string().optional(),
  date_limite: z.string().optional(),
  date_prevue: z.string().optional(),
  directives: z.string().optional(),
  commentaire_interne: z.string().optional(),
});

export async function mettreAJourDemande(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const parsed = DemandeSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) {
    redirectWithError(`/interventions/${formData.get("intervention_id")}`, premiereErreur(parsed));
  }
  const { intervention_id, date_prevue, date_limite, ...rest } = parsed.data;

  const supabase = await createClient();
  const { data: current } = await supabase.from("interventions").select("date_demande").eq("id", intervention_id).maybeSingle();
  if (date_prevue && current?.date_demande && new Date(date_prevue) < new Date(current.date_demande)) {
    redirectWithError(`/interventions/${intervention_id}`, "La date prévue doit être postérieure ou égale à la date de demande.");
  }

  const { error } = await supabase
    .from("interventions")
    .update({
      ...rest,
      date_limite: date_limite || null,
      date_prevue: date_prevue || null,
    })
    .eq("id", intervention_id);

  if (error) redirectWithError(`/interventions/${intervention_id}`, "La mise à jour a échoué.");

  await enregistrerJournal(supabase, "interventions", intervention_id, utilisateur.id, { action: "maj_demande" });
  revalidatePath(`/interventions/${intervention_id}`);
  redirect(`/interventions/${intervention_id}?onglet=demande`);
}

const RealisationSchema = z.object({
  intervention_id: z.coerce.number().int(),
  date_realisee: z.string().optional(),
  heure_arrivee: z.string().optional(),
  heure_depart: z.string().optional(),
  panne_code: z.coerce.number().int().optional().or(z.literal("")),
  prestations_realisees: z.string().optional(),
  commentaire_technicien: z.string().optional(),
  devis_a_faire: z.string().optional(),
  devis_fait: z.string().optional(),
  registre_securite_mis_a_jour: z.string().optional(),
});

export async function mettreAJourRealisation(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const parsed = RealisationSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) {
    redirectWithError(`/interventions/${formData.get("intervention_id")}?onglet=realisation`, premiereErreur(parsed));
  }
  const { intervention_id, heure_arrivee, heure_depart, panne_code, registre_securite_mis_a_jour, ...rest } = parsed.data;

  if (heure_arrivee && heure_depart && heure_depart <= heure_arrivee) {
    redirectWithError(`/interventions/${intervention_id}?onglet=realisation`, "L'heure de départ doit être postérieure à l'heure d'arrivée.");
  }

  const supabase = await createClient();
  const { data: intervention } = await supabase.from("interventions").select("date_realisee, site_id, type_code").eq("id", intervention_id).maybeSingle();
  if (!intervention) redirectWithError(`/interventions/${intervention_id}`, "Intervention introuvable.");

  const registreCoche = registre_securite_mis_a_jour === "1";
  const dateRealisee = parsed.data.date_realisee || intervention.date_realisee;
  if (registreCoche && !dateRealisee) {
    redirectWithError(`/interventions/${intervention_id}?onglet=realisation`, "La date réalisée est requise pour cocher « registre mis à jour ».");
  }

  const { error } = await supabase
    .from("interventions")
    .update({
      ...rest,
      heure_arrivee: heure_arrivee || null,
      heure_depart: heure_depart || null,
      panne_code: panne_code ? Number(panne_code) : null,
      registre_securite_mis_a_jour: registreCoche,
      devis_a_faire: parsed.data.devis_a_faire === "1",
      devis_fait: parsed.data.devis_fait === "1",
      date_realisee: parsed.data.date_realisee || null,
    })
    .eq("id", intervention_id);

  if (error) redirectWithError(`/interventions/${intervention_id}?onglet=realisation`, "La mise à jour a échoué.");

  if (registreCoche && dateRealisee) {
    const dateJour = dateRealisee.slice(0, 10);
    const { data: existant } = await supabase
      .from("site_registre_securite")
      .select("id")
      .eq("site_id", intervention.site_id)
      .gte("date_mise_a_jour", `${dateJour}T00:00:00Z`)
      .lt("date_mise_a_jour", `${dateJour}T23:59:59Z`)
      .maybeSingle();
    if (!existant) {
      await supabase.from("site_registre_securite").insert({ site_id: intervention.site_id, date_mise_a_jour: dateRealisee });
    }
  }

  await enregistrerJournal(supabase, "interventions", intervention_id, utilisateur.id, { action: "maj_realisation" });
  revalidatePath(`/interventions/${intervention_id}`);
  redirect(`/interventions/${intervention_id}?onglet=realisation`);
}

export async function basculerResoluTelephone(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const interventionId = Number(formData.get("intervention_id"));
  const active = formData.get("actif") === "1";
  const minutes = Number(formData.get("minutes_telephone") || 0);

  if (active && (!minutes || minutes <= 0)) {
    redirectWithError(`/interventions/${interventionId}`, "Le nombre de minutes au téléphone est obligatoire pour « Résolu par téléphone ».");
  }

  const supabase = await createClient();
  const { error } = await supabase
    .from("interventions")
    .update(
      active
        ? {
            statut_code: 10,
            non_facturable: true,
            date_realisee: new Date().toISOString(),
            minutes_telephone: minutes,
            prediag_par_id: utilisateur.id,
            prediag_resolu: true,
          }
        : { statut_code: 1 },
    )
    .eq("id", interventionId);

  if (error) redirectWithError(`/interventions/${interventionId}`, "La mise à jour a échoué.");

  await enregistrerJournal(supabase, "interventions", interventionId, utilisateur.id, { action: active ? "resolu_telephone" : "annule_resolu_telephone" });
  revalidatePath(`/interventions/${interventionId}`);
  redirect(`/interventions/${interventionId}`);
}

/** Clôturer (statut -> 9) : propose la réplanification pour les entretiens (type 1). */
export async function cloturerIntervention(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const interventionId = Number(formData.get("intervention_id"));

  const supabase = await createClient();
  const { data: intervention } = await supabase
    .from("interventions")
    .select("type_code, site_id, date_realisee")
    .eq("id", interventionId)
    .maybeSingle();
  if (!intervention) redirectWithError(`/interventions/${interventionId}`, "Intervention introuvable.");

  const { error } = await supabase.from("interventions").update({ statut_code: 9 }).eq("id", interventionId);
  if (error) redirectWithError(`/interventions/${interventionId}`, "La clôture a échoué.");
  await enregistrerJournal(supabase, "interventions", interventionId, utilisateur.id, { action: "cloture", statut_code: 9 });

  // Réplanification : proposée seulement pour un entretien (type 1), sites à 2 ou 4
  // visites/an, avant juillet (2) ou octobre (4). Cf. brief §5.1 (décision section 8).
  let proposerReplanification = false;
  if (intervention.type_code === 1) {
    const { data: contrat } = await supabase
      .from("site_contrats")
      .select("visites_par_an")
      .eq("site_id", intervention.site_id)
      .eq("lot", "clim")
      .maybeSingle();
    const visites = contrat?.visites_par_an;
    const mois = new Date(intervention.date_realisee ?? new Date()).getMonth() + 1;
    if ((visites === 2 && mois < 7) || (visites === 4 && mois < 10)) {
      proposerReplanification = true;
    }
  }

  revalidatePath(`/interventions/${interventionId}`);
  redirect(`/interventions/${interventionId}${proposerReplanification ? "?proposer_replanification=1" : ""}`);
}

/** Confirmation de la réplanification proposée après clôture : supprime les entretiens
 * prévus non réalisés du site (type 1). La régénération (étape 5.4, pas encore livrée)
 * reste à faire manuellement pour l'instant. */
export async function confirmerReplanification(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const interventionId = Number(formData.get("intervention_id"));
  const siteId = Number(formData.get("site_id"));

  const supabase = await createClient();
  const { data: supprimees } = await supabase
    .from("interventions")
    .update({ statut_code: 8 })
    .eq("site_id", siteId)
    .eq("type_code", 1)
    .eq("statut_code", 1)
    .is("date_realisee", null)
    .select("id");

  await enregistrerJournal(supabase, "interventions", interventionId, utilisateur.id, {
    action: "replanification_confirmee",
    entretiens_annules: (supprimees ?? []).map((r) => r.id),
  });

  revalidatePath(`/interventions/${interventionId}`);
  redirect(`/interventions/${interventionId}?info=${encodeURIComponent("Entretiens non réalisés annulés. Pensez à régénérer la planification (étape 5.4).")}`);
}

export async function decloturerIntervention(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const interventionId = Number(formData.get("intervention_id"));

  const supabase = await createClient();
  const { error } = await supabase.from("interventions").update({ statut_code: 1 }).eq("id", interventionId);
  if (error) redirectWithError(`/interventions/${interventionId}`, "La déclôture a échoué.");

  await enregistrerJournal(supabase, "interventions", interventionId, utilisateur.id, { action: "decloture", statut_code: 1 });
  revalidatePath(`/interventions/${interventionId}`);
  redirect(`/interventions/${interventionId}`);
}

/** Passage à 7 (Clôturé) : pointe les techniciens, refuse si le bon PDF est absent. */
export async function validerIntervention(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const interventionId = Number(formData.get("intervention_id"));

  const supabase = await createClient();
  const { data: intervention } = await supabase
    .from("interventions")
    .select("chemin_bon_pdf, date_realisee, heure_arrivee, heure_depart, numero_bon, site_id")
    .eq("id", interventionId)
    .maybeSingle();
  if (!intervention) redirectWithError(`/interventions/${interventionId}`, "Intervention introuvable.");

  if (!intervention.chemin_bon_pdf) {
    redirectWithError(`/interventions/${interventionId}?onglet=realisation`, "La demande ne peut pas être clôturée s'il n'y a pas de fichier associé.");
  }

  const { error } = await supabase.from("interventions").update({ statut_code: 7 }).eq("id", interventionId);
  if (error) redirectWithError(`/interventions/${interventionId}`, "La validation a échoué.");

  if (intervention.date_realisee && intervention.heure_arrivee && intervention.heure_depart) {
    const { data: techniciens } = await supabase
      .from("intervention_techniciens")
      .select("utilisateur_id")
      .eq("intervention_id", interventionId);
    for (const t of techniciens ?? []) {
      if (t.utilisateur_id == null) continue;
      await supabase.from("heures_techniciens").insert({
        utilisateur_id: t.utilisateur_id,
        date_travail: intervention.date_realisee.slice(0, 10),
        heure_debut: intervention.heure_arrivee,
        heure_fin: intervention.heure_depart,
        intervention_numero_bon: intervention.numero_bon,
        site_id: intervention.site_id,
        date_saisie: new Date().toISOString(),
      });
    }
  }

  await enregistrerJournal(supabase, "interventions", interventionId, utilisateur.id, { action: "validation", statut_code: 7 });
  revalidatePath(`/interventions/${interventionId}`);
  redirect(`/interventions/${interventionId}`);
}

const FacturationSchema = z.object({
  intervention_id: z.coerce.number().int(),
  montant_fmc: z.string().optional(),
  montant_sous_traitant: z.string().optional(),
  statut_facturation_code: z.string().optional(),
});

export async function mettreAJourFacturation(formData: FormData) {
  const { utilisateur, role } = await requireUtilisateur();
  const parsed = FacturationSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError(`/interventions/${formData.get("intervention_id")}?onglet=facturation`, "Formulaire invalide.");
  const { intervention_id, montant_fmc, montant_sous_traitant, statut_facturation_code } = parsed.data;

  const supabase = await createClient();
  const { data: intervention } = await supabase
    .from("interventions")
    .select("statut_facturation_code, montant_fmc, date_facturation")
    .eq("id", intervention_id)
    .maybeSingle();
  if (!intervention) redirectWithError(`/interventions/${intervention_id}`, "Intervention introuvable.");

  const nouveauStatut = statut_facturation_code ? Number(statut_facturation_code) : intervention.statut_facturation_code;
  if (nouveauStatut !== intervention.statut_facturation_code) {
    const { data: statuts } = await supabase
      .from("statuts_facturation")
      .select("code, reserve_admin")
      .in("code", [intervention.statut_facturation_code, nouveauStatut].filter((c): c is number => c != null));
    const reserve = (statuts ?? []).some((s) => s.reserve_admin);
    if (reserve && role !== "administrateur") {
      redirectWithError(`/interventions/${intervention_id}?onglet=facturation`, "Ce statut de facturation est réservé à l'administrateur.");
    }
  }

  const montantFmcNum = montant_fmc ? Number(montant_fmc) : null;
  const posantDateFacturation = montantFmcNum != null && !intervention.montant_fmc && !intervention.date_facturation;

  const { error } = await supabase
    .from("interventions")
    .update({
      montant_fmc: montantFmcNum,
      montant_sous_traitant: montant_sous_traitant ? Number(montant_sous_traitant) : null,
      statut_facturation_code: nouveauStatut,
      date_facturation: posantDateFacturation ? new Date().toISOString().slice(0, 10) : undefined,
    })
    .eq("id", intervention_id);

  if (error) redirectWithError(`/interventions/${intervention_id}?onglet=facturation`, "La mise à jour a échoué.");

  await enregistrerJournal(supabase, "interventions", intervention_id, utilisateur.id, { action: "maj_facturation" });
  revalidatePath(`/interventions/${intervention_id}`);
  redirect(`/interventions/${intervention_id}?onglet=facturation`);
}

export async function ajouterTechnicien(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const interventionId = Number(formData.get("intervention_id"));
  const technicienId = Number(formData.get("utilisateur_id"));
  if (!technicienId) redirectWithError(`/interventions/${interventionId}?onglet=realisation`, "Sélectionnez un technicien.");

  const supabase = await createClient();
  await supabase.from("intervention_techniciens").insert({ intervention_id: interventionId, utilisateur_id: technicienId });
  await recalculerNomsTechniciens(supabase, interventionId);

  await enregistrerJournal(supabase, "interventions", interventionId, utilisateur.id, { action: "ajout_technicien", utilisateur_id: technicienId });
  revalidatePath(`/interventions/${interventionId}`);
  redirect(`/interventions/${interventionId}?onglet=realisation`);
}

export async function retirerTechnicien(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const interventionId = Number(formData.get("intervention_id"));
  const ligneId = Number(formData.get("ligne_id"));

  const supabase = await createClient();
  await supabase.from("intervention_techniciens").delete().eq("id", ligneId);
  await recalculerNomsTechniciens(supabase, interventionId);

  await enregistrerJournal(supabase, "interventions", interventionId, utilisateur.id, { action: "retrait_technicien", ligne_id: ligneId });
  revalidatePath(`/interventions/${interventionId}`);
  redirect(`/interventions/${interventionId}?onglet=realisation`);
}

const COLONNES_DUPLICATION = [
  "site_id",
  "contact_id",
  "intervenant_id",
  "type_code",
  "reference_client",
  "reference_interne",
  "heures_vendues",
  "panne_code",
] as const;

export async function nouvelleInterventionDepuis(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const interventionId = Number(formData.get("intervention_id"));

  const supabase = await createClient();
  const { data: source } = await supabase.from("interventions").select("*").eq("id", interventionId).maybeSingle();
  if (!source) redirectWithError(`/interventions/${interventionId}`, "Intervention introuvable.");

  const copie: Record<string, unknown> = {};
  for (const col of COLONNES_DUPLICATION) copie[col] = source[col];

  const { data: created, error } = await supabase
    .from("interventions")
    .insert({
      ...copie,
      objet: source.objet,
      statut_code: 1,
      nature_visite_code: 3,
      date_demande: new Date().toISOString(),
      charge_affaire_id: utilisateur.id,
      saisi_par_id: utilisateur.id,
    })
    .select("id")
    .single();

  if (error || !created) redirectWithError(`/interventions/${interventionId}`, "La création a échoué.");

  await enregistrerJournal(supabase, "interventions", created.id, utilisateur.id, { action: "creation_depuis", source_id: interventionId });
  redirect(`/interventions/${created.id}`);
}

export async function creerPartieSuivante(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const interventionId = Number(formData.get("intervention_id"));

  const supabase = await createClient();
  const { data: source } = await supabase.from("interventions").select("*").eq("id", interventionId).maybeSingle();
  if (!source) redirectWithError(`/interventions/${interventionId}`, "Intervention introuvable.");

  const partieActuelle = /^PARTIE (\d+)/i.exec(source.commentaire_interne ?? "");
  const n = partieActuelle ? Number(partieActuelle[1]) + 1 : 2;

  const EXCLUES = new Set([
    "id",
    "legacy_id",
    "created_at",
    "updated_at",
    "date_realisee",
    "heure_arrivee",
    "heure_depart",
    "temps_aller",
    "temps_retour",
    "signature_site_image",
    "signature_client_image",
    "signature_technicien_image",
    "signature_site_nom",
    "signature_client_nom",
    "signature_technicien_nom",
    "signature_technicien_json",
    "signature_client_json",
    "signature_site_base64",
    "chemin_bon_pdf",
    "statut_code",
    "devis_fait",
    "registre_securite_mis_a_jour",
    "controle_etancheite_annuel",
    "photo_faite",
    "audit_fait",
    "numero_bon",
    "commentaire_interne",
  ]);
  const copie: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(source)) {
    if (!EXCLUES.has(key)) copie[key] = value;
  }

  const { data: created, error } = await supabase
    .from("interventions")
    .insert({
      ...copie,
      statut_code: 1,
      date_demande: new Date().toISOString(),
      commentaire_interne: `PARTIE ${n} : ${source.commentaire_interne ?? ""}`.trim(),
    })
    .select("id")
    .single();

  if (error || !created) redirectWithError(`/interventions/${interventionId}`, "La création de la partie suivante a échoué.");

  await enregistrerJournal(supabase, "interventions", created.id, utilisateur.id, { action: "partie_suivante", source_id: interventionId, n });
  redirect(`/interventions/${created.id}`);
}
