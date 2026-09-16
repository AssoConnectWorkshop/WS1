"use server";

import { z } from "zod";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { enregistrerJournal } from "@/lib/journal";
import { requireUtilisateur, redirectWithError, aujourdhui } from "@/lib/action-utils";
import { calculerMontantHt, chargerSiteEtTarifs, numeroDepuisFichier, TYPE_INTERVENTION_PAR_FAMILLE, FAMILLES_DEVIS, type FamilleDevis } from "@/lib/devis";

type Supabase = Awaited<ReturnType<typeof createClient>>;

const vide = (v: unknown) => v == null || (typeof v === "string" && v.trim() === "");
const nombre = z.preprocess((v) => (vide(v) ? null : Number(v)), z.number({ invalid_type_error: "Valeur numérique invalide." }).nullable());
const texte = z.preprocess((v) => (vide(v) ? null : v), z.string().trim().nullable());

const ChampsSchema = z.object({
  numero: texte,
  fichier_chemin: texte,
  fichier_partenaire_chemin: texte,
  intervention_origine_id: nombre,
  commentaire_client: texte,
  montant_fournitures: nombre,
  heures_mo: nombre,
  nombre_deplacements: nombre,
  tarif_heure_mo: nombre,
  tarif_deplacement: nombre,
  montant_ht: nombre,
  montant_ht_partenaire: nombre,
  date_devis: texte,
  date_envoi: texte,
  envoye_par_id: nombre,
  partenaire_id: nombre,
  numero_devis_partenaire: texte,
  numero_commande: texte,
  type_panne_libelle: texte,
  quantite_materiel: nombre,
  numero_devis_remplacement: texte,
});
type Champs = z.infer<typeof ChampsSchema>;

type Tarifs = { tarif_heure_mo: number | null; tarif_deplacement: number | null };

/** Applique les règles de saisie (brief §5.2) : tarifs pré-remplis si vides, numéro déduit du fichier,
 * montant HT recalculé sauf si l'utilisateur l'a modifié à la main (avertissement). */
function preparerLigne(champs: Champs, tarifs: Tarifs, precedent?: { montant_ht: number | null }) {
  const tarif_heure_mo = champs.tarif_heure_mo ?? tarifs.tarif_heure_mo;
  const tarif_deplacement = champs.tarif_deplacement ?? tarifs.tarif_deplacement;
  const calcule = calculerMontantHt({ ...champs, tarif_heure_mo, tarif_deplacement });
  const saisi = champs.montant_ht;
  const manuel = saisi != null && calcule != null && saisi !== calcule && saisi !== precedent?.montant_ht;

  const ligne = {
    ...champs,
    tarif_heure_mo,
    tarif_deplacement,
    montant_ht: manuel ? saisi : (calcule ?? saisi),
    numero: champs.numero ?? numeroDepuisFichier(champs.fichier_chemin),
  };
  const avertissement = manuel ? `Montant HT saisi manuellement (calcul : ${calcule.toFixed(2)} €).` : null;
  return { ligne, avertissement };
}

function echapperHtml(s: string) {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

/** `sites.resume_devis_html` = devis envoyés (statut 4) du site, un par ligne (analysis 04 §1.6 Controle_Devis). */
async function recalculerResumeDevis(supabase: Supabase, siteId: number) {
  const { data } = await supabase
    .from("devis")
    .select("numero, fichier_chemin, famille")
    .eq("site_id", siteId)
    .eq("statut_code", 4)
    .is("supprime_le", null)
    .order("date_envoi", { ascending: false });
  const lignes = (data ?? []).map((d) => echapperHtml(`${d.numero ?? d.fichier_chemin?.split(/[\\/]/).pop() ?? "Devis"} (${d.famille})`));
  await supabase.from("sites").update({ resume_devis_html: lignes.length ? lignes.join("<br/>") : null }).eq("id", siteId);
}

function urlAvecAvertissement(path: string, avertissement: string | null) {
  return avertissement ? `${path}?avertissement=${encodeURIComponent(avertissement)}` : path;
}

const CreationSchema = ChampsSchema.extend({
  famille: z.enum(FAMILLES_DEVIS, { message: "La famille est obligatoire." }),
  site_id: z.coerce.number().int().positive("Le site est obligatoire."),
});

export async function creerDevis(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const retour = `/devis/nouveau?famille=${formData.get("famille") ?? "sav"}${formData.get("site_id") ? `&site=${formData.get("site_id")}` : ""}`;
  const parsed = CreationSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError(retour, parsed.error.issues[0]?.message ?? "Formulaire invalide.");
  const { famille, site_id, ...champs } = parsed.data;

  const supabase = await createClient();
  const site = await chargerSiteEtTarifs(supabase, site_id);
  if (!site) redirectWithError(retour, "Site introuvable.");

  const { ligne, avertissement } = preparerLigne(champs, site.tarifs);
  const { data: created, error } = await supabase
    .from("devis")
    .insert({ ...ligne, famille, site_id, client_id: site.client_id, statut_code: 1 })
    .select("id")
    .single();
  if (error || !created) redirectWithError(retour, "La création du devis a échoué.");

  await enregistrerJournal(supabase, "devis", created.id, utilisateur.id, { action: "creation", famille });
  revalidatePath("/devis");
  redirect(urlAvecAvertissement(`/devis/${created.id}`, avertissement));
}

const MiseAJourSchema = ChampsSchema.extend({
  devis_id: z.coerce.number().int(),
  statut_code: z.coerce.number().int(),
});

export async function mettreAJourDevis(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const devisId = Number(formData.get("devis_id"));
  const parsed = MiseAJourSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError(`/devis/${devisId}`, parsed.error.issues[0]?.message ?? "Formulaire invalide.");
  const { devis_id, statut_code, ...champs } = parsed.data;

  const supabase = await createClient();
  const { data: devis } = await supabase.from("devis").select("site_id, statut_code, montant_ht").eq("id", devis_id).is("supprime_le", null).maybeSingle();
  if (!devis) redirectWithError(`/devis/${devis_id}`, "Devis introuvable.");

  const site = devis.site_id ? await chargerSiteEtTarifs(supabase, devis.site_id) : null;
  const { ligne, avertissement } = preparerLigne(champs, site?.tarifs ?? { tarif_heure_mo: null, tarif_deplacement: null }, devis);

  if (statut_code === 3 && !ligne.numero_devis_remplacement) {
    redirectWithError(`/devis/${devis_id}`, "Le numéro du devis remplaçant est obligatoire pour le statut « Annulé et remplacé ».");
  }
  if (statut_code === 4 && !ligne.date_envoi) ligne.date_envoi = aujourdhui();

  const { error } = await supabase.from("devis").update({ ...ligne, statut_code }).eq("id", devis_id);
  if (error) redirectWithError(`/devis/${devis_id}`, "La mise à jour a échoué.");

  await enregistrerJournal(supabase, "devis", devis_id, utilisateur.id, { action: "maj", statut_code });
  if (statut_code !== devis.statut_code && devis.site_id) await recalculerResumeDevis(supabase, devis.site_id);

  revalidatePath("/devis");
  revalidatePath(`/devis/${devis_id}`);
  redirect(urlAvecAvertissement(`/devis/${devis_id}`, avertissement));
}

/** « Générer intervention suite à accord devis » (analysis 04 §1.6) : intervention statut 1, devis → statut 6. */
export async function genererIntervention(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const devisId = Number(formData.get("devis_id"));

  const supabase = await createClient();
  const { data: devis } = await supabase
    .from("devis")
    .select("id, famille, numero, site_id, heures_mo, montant_ht, statut_code")
    .eq("id", devisId)
    .is("supprime_le", null)
    .maybeSingle();
  if (!devis) redirectWithError(`/devis/${devisId}`, "Devis introuvable.");
  if (devis.statut_code === 6) redirectWithError(`/devis/${devisId}`, "Ce devis est déjà accepté : l'intervention a déjà été générée.");
  if (!devis.site_id) redirectWithError(`/devis/${devisId}`, "Le devis doit être rattaché à un site.");

  const site = await chargerSiteEtTarifs(supabase, devis.site_id);
  if (!site) redirectWithError(`/devis/${devisId}`, "Site introuvable.");

  const { data: created, error } = await supabase
    .from("interventions")
    .insert({
      site_id: devis.site_id,
      type_code: TYPE_INTERVENTION_PAR_FAMILLE[devis.famille as FamilleDevis],
      statut_code: 1,
      nature_visite_code: 3,
      date_demande: new Date().toISOString(),
      objet: devis.numero ?? `Devis ${devis.id}`,
      intervenant_id: site.intervenant_id,
      numero_devis_accepte: devis.numero,
      heures_vendues: devis.heures_mo,
      montant_ht_devis_accepte: devis.montant_ht,
      charge_affaire_id: utilisateur.id,
      saisi_par_id: utilisateur.id,
    })
    .select("id")
    .single();
  if (error || !created) redirectWithError(`/devis/${devisId}`, "La génération de l'intervention a échoué.");

  await supabase.from("devis").update({ statut_code: 6 }).eq("id", devisId);
  await Promise.all([
    enregistrerJournal(supabase, "devis", devisId, utilisateur.id, { action: "generation_intervention", intervention_id: created.id, statut_code: 6 }),
    enregistrerJournal(supabase, "interventions", created.id, utilisateur.id, { action: "creation_depuis_devis", devis_id: devisId }),
    recalculerResumeDevis(supabase, devis.site_id),
  ]);

  revalidatePath("/devis");
  revalidatePath("/interventions");
  redirect(`/interventions/${created.id}`);
}

export async function supprimerDevis(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const devisId = Number(formData.get("devis_id"));

  const supabase = await createClient();
  const { data: devis } = await supabase.from("devis").select("famille, site_id").eq("id", devisId).is("supprime_le", null).maybeSingle();
  if (!devis) redirectWithError(`/devis/${devisId}`, "Devis introuvable.");

  const { error } = await supabase.from("devis").update({ supprime_le: new Date().toISOString() }).eq("id", devisId);
  if (error) redirectWithError(`/devis/${devisId}`, "La suppression a échoué.");

  await enregistrerJournal(supabase, "devis", devisId, utilisateur.id, { action: "suppression" });
  if (devis.site_id) await recalculerResumeDevis(supabase, devis.site_id);

  revalidatePath("/devis");
  redirect(`/devis?onglet=${devis.famille}&info=${encodeURIComponent("Devis supprimé.")}`);
}
