"use server";

import { z } from "zod";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { genererCerfaPdf } from "@/lib/cerfa-pdf";
import { enregistrerJournal } from "@/lib/journal";
import { requireUtilisateur, redirectWithError, aujourdhui } from "@/lib/action-utils";
import { booleen, entier, nombre, obligatoire, texte, premiereErreur } from "@/lib/zod-form";
import { CLES_LOTS, STATUTS_EN_COURS, STATUT_A_PLANIFIER, STATUT_NE_PLUS_INTERVENIR } from "@/lib/sites";

type Supabase = Awaited<ReturnType<typeof createClient>>;

function versSite(siteId: number, params?: Record<string, string>) {
  const query = new URLSearchParams(params).toString();
  return `/sites/${siteId}${query ? `?${query}` : ""}`;
}

/* ------------------------------------------------------------------ Fiche */

const SiteSchema = z.object({
  numero_magasin: entier,
  code_client: texte,
  nom_societe: texte,
  adresse: texte,
  code_postal: texte,
  ville: texte,
  telephone: texte,
  fax: texte,
  email: texte,
  responsable_civilite: texte,
  responsable_nom: texte,
  responsable_prenom: texte,
  telephone_centre_commercial: texte,
  zone_id: entier,
  zone_secondaire_id: entier,
  intervenant_id: entier,
  surface_vente: nombre,
  surface_totale: nombre,
  situation: texte,
  type_site: texte,
  date_mise_en_service: texte,
  indice_qualite: entier,
  indice_vetuste: entier,
  indice_puissance: entier,
  indice_accessibilite: entier,
  fluide_id: entier,
  temperature_entree: texte,
  temperature_sortie: texte,
  gtb: booleen,
  allumage_clim: booleen,
  arret_urgence_clim_oui: booleen,
  arret_urgence_clim_non: booleen,
  garantie_pieces_mo_annees: entier,
  garantie_pieces_annees: entier,
  garantie_compresseur_annees: entier,
  tarifs_specifiques: booleen,
  tarif_heure_mo: nombre,
  tarif_deplacement: nombre,
  date_derniere_visite_desenfumage: texte,
  photo_a_faire: booleen,
  photo_faite: booleen,
  audit_a_faire: booleen,
  audit_fait: booleen,
  controle_etancheite_a_faire: booleen,
  controle_etancheite_fait: booleen,
  detection_fuite_permanente: booleen,
  nombre_plans: entier,
  nombre_photos: entier,
  particulier: booleen,
  nacelle_necessaire: booleen,
  retard_paiement: booleen,
  rdv_a_prendre: booleen,
  investissement: booleen,
  descriptif_investissement: texte,
  commentaire_general: texte,
  commentaire_divers: texte,
  dossier_chemin: texte,
  numero_esabora: texte,
});

/** Champs protégés contre la modification accidentelle : envoyés seulement après « Déverrouiller ». */
const VerrouSchema = z.object({
  client_id: z.coerce.number().int().positive("Le client est obligatoire."),
  nom: obligatoire("Le nom du site est obligatoire."),
  donneur_ordre_id: entier,
});

export async function mettreAJourSite(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const siteId = Number(formData.get("site_id"));
  const raw = Object.fromEntries(formData);
  const parsed = SiteSchema.safeParse(raw);
  if (!parsed.success) redirectWithError(versSite(siteId), premiereErreur(parsed));

  const supabase = await createClient();
  const { data: site } = await supabase.from("sites").select("client_id").eq("id", siteId).maybeSingle();
  if (!site) redirectWithError(versSite(siteId), "Site introuvable.");

  const payload: Record<string, unknown> = { ...parsed.data };
  let nouveauClient: number | null = null;
  if (raw.deverrouille === "1") {
    const verrou = VerrouSchema.safeParse(raw);
    if (!verrou.success) redirectWithError(versSite(siteId, { deverrouiller: "1" }), premiereErreur(verrou));
    Object.assign(payload, verrou.data);
    if (verrou.data.client_id !== site.client_id) nouveauClient = verrou.data.client_id;
  }

  const { error } = await supabase.from("sites").update(payload).eq("id", siteId);
  if (error) redirectWithError(versSite(siteId), "La mise à jour a échoué.");

  if (nouveauClient) {
    // Analysis 03 §2.3 : le changement de client se propage aux devis du site.
    await supabase.from("devis").update({ client_id: nouveauClient }).eq("site_id", siteId).eq("client_id", site.client_id);
    await enregistrerJournal(supabase, "sites", siteId, utilisateur.id, { action: "changement_client", de: site.client_id, vers: nouveauClient });
  }
  await enregistrerJournal(supabase, "sites", siteId, utilisateur.id, { action: "maj" });

  revalidatePath("/sites");
  revalidatePath(versSite(siteId));
  redirect(versSite(siteId, { info: "Site enregistré." }));
}

const CreationSiteSchema = z.object({
  client_id: z.coerce.number().int().positive("Le client est obligatoire."),
  nom: obligatoire("Le nom du site est obligatoire."),
  numero_magasin: entier,
  code_client: texte,
  adresse: texte,
  code_postal: texte,
  ville: texte,
  telephone: texte,
  zone_id: entier,
  intervenant_id: entier,
  donneur_ordre_id: entier,
});

export async function creerSite(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const retour = `/sites/nouveau${formData.get("client_id") ? `?client=${formData.get("client_id")}` : ""}`;
  const parsed = CreationSiteSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError(retour, premiereErreur(parsed));

  const supabase = await createClient();
  const { data: created, error } = await supabase.from("sites").insert(parsed.data).select("id").single();
  if (error || !created) redirectWithError(retour, "La création du site a échoué.");

  await enregistrerJournal(supabase, "sites", created.id, utilisateur.id, { action: "creation" });
  revalidatePath("/sites");
  redirect(versSite(created.id, { info: "Site créé : complétez la fiche, les contrats et les horaires." }));
}

/* --------------------------------------------------------------- Contrats */

const ContratSchema = z.object({
  lot: z.enum(CLES_LOTS),
  numero_contrat: texte,
  date_contrat: texte,
  date_signature: texte,
  visites_par_an: entier,
  redevance: nombre,
  redevance_secondaire: nombre,
  visites_secondaires: entier,
  sous_traitant_id: entier,
  tarif_sous_traitant: nombre,
});

/** Un lot par formulaire ; la ligne `site_contrats` est créée si elle n'existe pas (brief §5.3). */
export async function mettreAJourContrat(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const siteId = Number(formData.get("site_id"));
  const retour = versSite(siteId, { onglet: "contrats" });
  const parsed = ContratSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError(retour, premiereErreur(parsed));

  const supabase = await createClient();
  const { error } = await supabase.from("site_contrats").upsert({ site_id: siteId, ...parsed.data }, { onConflict: "site_id,lot" });
  if (error) redirectWithError(retour, "L'enregistrement du contrat a échoué.");

  // Données pivot de la planification conservées sur le site (cf. commentaire de sites.visites_entretien_par_an).
  if (parsed.data.lot === "clim") await supabase.from("sites").update({ visites_entretien_par_an: parsed.data.visites_par_an }).eq("id", siteId);
  if (parsed.data.lot === "desenfumage") await supabase.from("sites").update({ nombre_desenfumage: parsed.data.visites_par_an }).eq("id", siteId);

  await enregistrerJournal(supabase, "sites", siteId, utilisateur.id, { action: "maj_contrat", lot: parsed.data.lot });
  revalidatePath(versSite(siteId));
  redirect(retour);
}

/* --------------------------------------------------------------- Horaires */

export async function mettreAJourHoraires(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const siteId = Number(formData.get("site_id"));
  const retour = versSite(siteId, { onglet: "horaires" });
  const heure = (v: FormDataEntryValue | null) => (typeof v === "string" && v.trim() ? v : null);
  const lignes = [1, 2, 3, 4, 5, 6, 7].map((jour) => ({
    site_id: siteId,
    jour,
    ouverture: heure(formData.get(`ouverture_${jour}`)),
    fermeture: heure(formData.get(`fermeture_${jour}`)),
  }));

  const supabase = await createClient();
  const { error } = await supabase.from("site_horaires").upsert(lignes, { onConflict: "site_id,jour" });
  if (error) redirectWithError(retour, "L'enregistrement des horaires a échoué.");

  await enregistrerJournal(supabase, "sites", siteId, utilisateur.id, { action: "maj_horaires" });
  revalidatePath(versSite(siteId));
  redirect(retour);
}

/* -------------------------------------------------------------- Fermeture */

/** Fermeture : rattachement au pseudo-client « fermé » avec conservation de l'ancien client (brief §5.3). */
export async function fermerSite(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const siteId = Number(formData.get("site_id"));
  const motif = String(formData.get("motif_fermeture") ?? "").trim();
  const dateFermeture = String(formData.get("date_fermeture") ?? "").trim() || aujourdhui();

  const supabase = await createClient();
  const [{ data: site }, { data: clientFerme }] = await Promise.all([
    supabase.from("sites").select("client_id, ferme").eq("id", siteId).maybeSingle(),
    supabase.from("clients").select("id").eq("est_client_fermeture", true).limit(1).maybeSingle(),
  ]);
  if (!site) redirectWithError(versSite(siteId), "Site introuvable.");
  if (site.ferme) redirectWithError(versSite(siteId), "Ce site est déjà fermé.");
  if (!clientFerme) redirectWithError(versSite(siteId), "Aucun client « sites fermés » n'est défini (clients.est_client_fermeture).");

  const { error } = await supabase
    .from("sites")
    .update({ ferme: true, date_fermeture: dateFermeture, motif_fermeture: motif || null, client_avant_fermeture_id: site.client_id, client_id: clientFerme.id })
    .eq("id", siteId);
  if (error) redirectWithError(versSite(siteId), "La fermeture a échoué.");

  await supabase.from("devis").update({ client_id: clientFerme.id }).eq("site_id", siteId).eq("client_id", site.client_id);
  await enregistrerJournal(supabase, "sites", siteId, utilisateur.id, { action: "fermeture", client_avant: site.client_id, motif });

  revalidatePath("/sites");
  revalidatePath(versSite(siteId));
  redirect(versSite(siteId, { info: "Site fermé et rattaché au client « sites fermés »." }));
}

export async function rouvrirSite(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const siteId = Number(formData.get("site_id"));

  const supabase = await createClient();
  const { data: site } = await supabase.from("sites").select("client_id, ferme, client_avant_fermeture_id").eq("id", siteId).maybeSingle();
  if (!site?.ferme) redirectWithError(versSite(siteId), "Ce site n'est pas fermé.");
  if (!site.client_avant_fermeture_id) redirectWithError(versSite(siteId), "Client d'origine inconnu : réaffectez le client via « Déverrouiller », puis décochez « Fermé ».");

  const { error } = await supabase
    .from("sites")
    .update({ ferme: false, date_fermeture: null, motif_fermeture: null, client_id: site.client_avant_fermeture_id, client_avant_fermeture_id: null })
    .eq("id", siteId);
  if (error) redirectWithError(versSite(siteId), "La réouverture a échoué.");

  await supabase.from("devis").update({ client_id: site.client_avant_fermeture_id }).eq("site_id", siteId).eq("client_id", site.client_id);
  await enregistrerJournal(supabase, "sites", siteId, utilisateur.id, { action: "reouverture", client: site.client_avant_fermeture_id });

  revalidatePath("/sites");
  revalidatePath(versSite(siteId));
  redirect(versSite(siteId, { info: "Site rouvert." }));
}

/* ---------------------------------------------------- Ne plus intervenir */

/** Cocher : interventions en cours (-1, 1, 9) → 17. Décocher (administrateur) : 17 → 1 (analysis 03 §8.2). */
export async function basculerNePlusIntervenir(formData: FormData) {
  const { utilisateur, role } = await requireUtilisateur();
  const siteId = Number(formData.get("site_id"));
  const activer = formData.get("actif") === "1";
  if (!activer && role !== "administrateur") redirectWithError(versSite(siteId), "Seul un administrateur peut réactiver les interventions d'un site « Ne plus intervenir ».");

  const supabase = await createClient();
  const { error } = await supabase.from("sites").update({ ne_plus_intervenir: activer }).eq("id", siteId);
  if (error) redirectWithError(versSite(siteId), "La mise à jour a échoué.");

  const { data: basculees } = activer
    ? await supabase.from("interventions").update({ statut_code: STATUT_NE_PLUS_INTERVENIR }).eq("site_id", siteId).in("statut_code", STATUTS_EN_COURS).select("id")
    : await supabase.from("interventions").update({ statut_code: STATUT_A_PLANIFIER }).eq("site_id", siteId).eq("statut_code", STATUT_NE_PLUS_INTERVENIR).select("id");

  await enregistrerJournal(supabase, "sites", siteId, utilisateur.id, {
    action: activer ? "ne_plus_intervenir" : "reprise_interventions",
    interventions: (basculees ?? []).map((i) => i.id),
  });

  revalidatePath("/sites");
  revalidatePath(versSite(siteId));
  const n = basculees?.length ?? 0;
  redirect(versSite(siteId, { info: activer ? `${n} intervention(s) passée(s) en « Ne plus intervenir ».` : `${n} intervention(s) remise(s) « À planifier ».` }));
}

/* -------------------------------------------------------------- Géocodage */

type ResultatAdresse = { features?: { geometry: { coordinates: [number, number] }; properties: { type: string; score: number; label: string } }[] };

async function geocoder(q: string) {
  const res = await fetch(`https://api-adresse.data.gouv.fr/search/?q=${encodeURIComponent(q)}&limit=1`, { cache: "no-store" });
  if (!res.ok) return null;
  const json = (await res.json()) as ResultatAdresse;
  return json.features?.[0] ?? null;
}

/** Géocodage par la Base Adresse Nationale (sans clé) ; repli sur la ville seule comme dans Access (analysis 03 §2.5). */
export async function geocoderSite(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const siteId = Number(formData.get("site_id"));

  const supabase = await createClient();
  const { data: site } = await supabase.from("sites").select("adresse, code_postal, ville").eq("id", siteId).maybeSingle();
  if (!site) redirectWithError(versSite(siteId), "Site introuvable.");
  if (!site.ville && !site.code_postal) redirectWithError(versSite(siteId), "Renseignez au moins la ville ou le code postal avant de géocoder.");

  let resultat: Awaited<ReturnType<typeof geocoder>> = null;
  try {
    resultat = await geocoder([site.adresse, site.code_postal, site.ville].filter(Boolean).join(" "));
    if (!resultat && site.ville) resultat = await geocoder([site.code_postal, site.ville].filter(Boolean).join(" "));
  } catch {
    redirectWithError(versSite(siteId), "Le service de géocodage est injoignable.");
  }
  if (!resultat) redirectWithError(versSite(siteId), "Adresse introuvable par le service de géocodage.");

  const [longitude, latitude] = resultat.geometry.coordinates;
  const { error } = await supabase.from("sites").update({ latitude, longitude, precision_geo: resultat.properties.type }).eq("id", siteId);
  if (error) redirectWithError(versSite(siteId), "L'enregistrement des coordonnées a échoué.");

  await enregistrerJournal(supabase, "sites", siteId, utilisateur.id, { action: "geocodage", precision: resultat.properties.type, score: resultat.properties.score });
  revalidatePath(versSite(siteId));
  redirect(versSite(siteId, { info: `Géocodé : ${resultat.properties.label} (précision : ${resultat.properties.type}).` }));
}

/* --------------------------------------------------------------- Matériel */

type ReferenceCatalogue = {
  id: number;
  reference: string | null;
  repere: string | null;
  type_equipement: string | null;
  fluide_id: number | null;
  type_telecommande: string | null;
  reversible: string | null;
  resistance: string | null;
  puissance_frigo: number | null;
  puissance_calo: number | null;
  quantite_gaz: string | null;
  nombre_filtres: string | null;
  dimension_filtres: string | null;
  nombre_courroies: string | null;
  reference_courroies: string | null;
  appoint_roof: string | null;
  marques: { libelle: string | null } | null;
  types_fluide: { libelle: string | null } | null;
};

const versNombre = (v: string | null) => (v != null && v.trim() !== "" && Number.isFinite(Number(v)) ? Number(v) : null);

/** Copie des valeurs du catalogue, une ligne par équipement, quantité 1 (analysis 03 §3.3). */
function ligneDepuisCatalogue(siteId: number, ref: ReferenceCatalogue) {
  return {
    site_id: siteId,
    quantite: 1,
    reference: ref.reference,
    repere: ref.repere,
    type_equipement: ref.type_equipement,
    marque: ref.marques?.libelle ?? null,
    fluide_id: ref.fluide_id,
    fluide_libelle: ref.types_fluide?.libelle ?? null,
    charge_fluide_kg: versNombre(ref.quantite_gaz),
    type_telecommande: ref.type_telecommande,
    reversible: ref.reversible,
    resistance_electrique: ref.resistance,
    puissance_frigo_w: ref.puissance_frigo,
    puissance_calo_w: ref.puissance_calo,
    rooftop_nombre_filtres: versNombre(ref.nombre_filtres),
    rooftop_reference_filtres: ref.dimension_filtres,
    rooftop_nombre_courroies: versNombre(ref.nombre_courroies),
    rooftop_reference_courroies: ref.reference_courroies,
    rooftop_appoint_chauffage: ref.appoint_roof,
  };
}

async function chargerReference(supabase: Supabase, id: number) {
  const { data } = await supabase.from("references_materiel").select("*, marques(libelle), types_fluide(libelle)").eq("id", id).maybeSingle();
  return data as unknown as ReferenceCatalogue | null;
}

export async function ajouterMaterielDepuisCatalogue(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const siteId = Number(formData.get("site_id"));
  const retour = versSite(siteId, { onglet: "materiel" });
  const mode = String(formData.get("mode"));
  const ref1 = Number(formData.get("reference_1_id")) || null;
  const ref2 = Number(formData.get("reference_2_id")) || null;
  const nb = (name: string) => Math.trunc(Number(formData.get(name)) || 0);

  const supabase = await createClient();
  let lignes: ReturnType<typeof ligneDepuisCatalogue>[] = [];

  if (mode === "ref1" || mode === "ref2") {
    const refId = mode === "ref1" ? ref1 : ref2;
    const n = nb(mode === "ref1" ? "nombre_1" : "nombre_2");
    if (!refId || n < 1 || n > 100) redirectWithError(retour, `Ajout impossible : vérifiez le nombre et la référence ${mode === "ref1" ? 1 : 2}.`);
    const ref = await chargerReference(supabase, refId);
    if (!ref) redirectWithError(retour, "Référence introuvable.");
    lignes = Array.from({ length: n }, () => ligneDepuisCatalogue(siteId, ref));
  } else if (mode === "alternance") {
    const n = nb("nombre_3");
    if (!ref1 || !ref2 || n < 1 || n > 100) redirectWithError(retour, "Ajout impossible : vérifiez le nombre et les deux références.");
    const [r1, r2] = await Promise.all([chargerReference(supabase, ref1), chargerReference(supabase, ref2)]);
    if (!r1 || !r2) redirectWithError(retour, "Référence introuvable.");
    lignes = Array.from({ length: n }, () => [ligneDepuisCatalogue(siteId, r1), ligneDepuisCatalogue(siteId, r2)]).flat();
  } else {
    redirectWithError(retour, "Mode d'ajout inconnu.");
  }

  const { error } = await supabase.from("site_materiels").insert(lignes);
  if (error) redirectWithError(retour, "L'ajout du matériel a échoué.");

  await enregistrerJournal(supabase, "sites", siteId, utilisateur.id, { action: "ajout_materiel_catalogue", mode, nombre: lignes.length });
  revalidatePath(versSite(siteId));
  redirect(retour);
}

export async function ajouterMaterielVide(formData: FormData) {
  await requireUtilisateur();
  const siteId = Number(formData.get("site_id"));
  const supabase = await createClient();
  const { data: created, error } = await supabase.from("site_materiels").insert({ site_id: siteId, quantite: 1 }).select("id").single();
  if (error || !created) redirectWithError(versSite(siteId, { onglet: "materiel" }), "L'ajout a échoué.");
  revalidatePath(versSite(siteId));
  redirect(versSite(siteId, { onglet: "materiel", modifier: String(created.id) }));
}

const MaterielSchema = z.object({
  repere_sur_site: entier,
  repere: texte,
  emplacement: texte,
  quantite: entier,
  marque: texte,
  type_equipement: texte,
  reference: texte,
  numero_serie: texte,
  reversible: texte,
  resistance_electrique: texte,
  puissance_frigo_w: nombre,
  puissance_calo_w: nombre,
  fluide_libelle: texte,
  charge_fluide_kg: nombre,
  date_mise_en_service: texte,
  type_telecommande: texte,
  nombre_telecommandes: entier,
  emplacement_telecommande: texte,
  date_controle_etancheite: texte,
  certificat_etancheite_edite: booleen,
  observations: texte,
});

export async function mettreAJourMateriel(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const siteId = Number(formData.get("site_id"));
  const materielId = Number(formData.get("materiel_id"));
  const retour = versSite(siteId, { onglet: "materiel" });
  const parsed = MaterielSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError(versSite(siteId, { onglet: "materiel", modifier: String(materielId) }), premiereErreur(parsed));

  const supabase = await createClient();
  const { data: fluide } = parsed.data.fluide_libelle
    ? await supabase.from("types_fluide").select("id").eq("libelle", parsed.data.fluide_libelle).maybeSingle()
    : { data: null };
  const { error } = await supabase
    .from("site_materiels")
    .update({ ...parsed.data, fluide_id: fluide?.id ?? null })
    .eq("id", materielId)
    .eq("site_id", siteId);
  if (error) redirectWithError(retour, "La mise à jour du matériel a échoué.");

  await enregistrerJournal(supabase, "sites", siteId, utilisateur.id, { action: "maj_materiel", materiel_id: materielId });
  revalidatePath(versSite(siteId));
  redirect(retour);
}

export async function supprimerMateriel(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const siteId = Number(formData.get("site_id"));
  const materielId = Number(formData.get("materiel_id"));
  const retour = versSite(siteId, { onglet: "materiel" });

  const supabase = await createClient();
  const { error } = await supabase.from("site_materiels").delete().eq("id", materielId).eq("site_id", siteId);
  if (error) redirectWithError(retour, "La suppression a échoué.");

  await enregistrerJournal(supabase, "sites", siteId, utilisateur.id, { action: "suppression_materiel", materiel_id: materielId });
  revalidatePath(versSite(siteId));
  redirect(retour);
}

/* --------------------------------------------------- Certificats d'étanchéité */

/** Un Cerfa par équipement éligible (non édité, contrôle daté de l'année en cours), archivé dans Storage
 * `certificats/<année>/<intervention>-<materiel>.pdf` puis `certificat_etancheite_edite = true` (brief §6.2). */
export async function genererCertificats(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const siteId = Number(formData.get("site_id"));
  const retour = versSite(siteId, { onglet: "materiel" });

  let admin: ReturnType<typeof createAdminClient>;
  try {
    admin = createAdminClient();
  } catch {
    redirectWithError(retour, "Stockage non configuré (SUPABASE_SERVICE_ROLE_KEY).");
  }

  const supabase = await createClient();
  const annee = new Date().getUTCFullYear();
  const { data: eligibles } = await supabase
    .from("site_materiels")
    .select("id")
    .eq("site_id", siteId)
    .eq("certificat_etancheite_edite", false)
    .gte("date_controle_etancheite", `${annee}-01-01`)
    .lte("date_controle_etancheite", `${annee}-12-31`)
    .order("id");
  if (!eligibles || eligibles.length === 0) redirectWithError(retour, "Les CE ont déjà été édités.");

  const edites: string[] = [];
  const echecs: string[] = [];
  for (const { id } of eligibles) {
    const { cerfa, erreurs } = await genererCerfaPdf(supabase, id);
    if (!cerfa) {
      echecs.push(`équipement #${id} : ${erreurs.join(" ")}`);
      continue;
    }
    const chemin = `${cerfa.annee}/${cerfa.nomFichier}`;
    const { error } = await admin.storage.from("certificats").upload(chemin, Buffer.from(cerfa.octets), { contentType: "application/pdf", upsert: true });
    if (error) {
      echecs.push(`équipement #${id} : export PDF annulé (${error.message})`);
      continue;
    }
    await supabase.from("site_materiels").update({ certificat_etancheite_edite: true }).eq("id", id);
    edites.push(`certificats/${chemin}`);
  }

  await enregistrerJournal(supabase, "sites", siteId, utilisateur.id, { action: "generation_certificats", edites, echecs: echecs.length });
  revalidatePath(versSite(siteId));
  const params: Record<string, string> = { onglet: "materiel", info: `${edites.length} certificat(s) archivé(s).` };
  if (echecs.length) params.erreur = `La génération du CE n'a pas pu se faire correctement pour ${echecs.length} équipement(s) : ${echecs.join(" ; ")}`;
  redirect(versSite(siteId, params));
}
