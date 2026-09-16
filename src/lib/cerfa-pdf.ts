import "server-only";
import type { SupabaseClient } from "@supabase/supabase-js";
import { formatDate } from "@/lib/format";
import { Redacteur, chargerParametres, nomFichierSur } from "@/lib/pdf";

export const FAMILLES_CE = ["HCFC", "HFC", "HFO"] as const;
type FamilleCE = (typeof FAMILLES_CE)[number];

type Equipement = {
  id: number;
  site_id: number;
  emplacement: string | null;
  marque: string | null;
  reference: string | null;
  numero_serie: string | null;
  fluide_id: number | null;
  fluide_libelle: string | null;
  charge_fluide_kg: number | null;
  date_controle_etancheite: string | null;
  intervention_id: number | null;
  certificat_etancheite_edite: boolean;
};

type Fluide = { id: number; libelle: string; gwp: number | null; familles_gaz: { libelle: string } | null };

/** Pré-contrôles bloquants de PDFCE.ControleDatasCE (analysis 01 §5.2, 03 §3.6), messages Access. */
export function controlerEquipementCE(e: Equipement, fluide: Fluide | null): string[] {
  const erreurs: string[] = [];
  if (!fluide) erreurs.push(`Le fluide doit être renseigné, il est actuellement défini à : ${e.fluide_libelle ?? "vide"}.`);
  else {
    if (!fluide.familles_gaz || !(FAMILLES_CE as readonly string[]).includes(fluide.familles_gaz.libelle)) erreurs.push("Le type gaz n'est pas utilisé pour les CE.");
    if (!fluide.gwp || fluide.gwp <= 0) erreurs.push(`GWP non renseigné pour le fluide ${fluide.libelle}.`);
  }
  if (!e.charge_fluide_kg || e.charge_fluide_kg <= 0) erreurs.push("Pas de quantité de fluide saisie.");
  if (!e.marque || !e.numero_serie || !e.reference) erreurs.push("Marque, référence et numéro de série sont obligatoires.");
  return erreurs;
}

/** Cases du Cerfa par seuils réglementaires : HCFC en kg, HFC en t.éq.CO2, HFO en kg. */
export function seuils(famille: FamilleCE, kg: number, tco2: number): [boolean, boolean, boolean] {
  const v = famille === "HFC" ? tco2 : kg;
  const [s1, s2] = famille === "HCFC" ? [30, 300] : famille === "HFC" ? [50, 500] : [10, 100];
  return [v < s1, v >= s1 && v < s2, v >= s2];
}

export type Cerfa = { octets: Uint8Array; nomFichier: string; annee: number };

export async function chargerEquipementCE(supabase: SupabaseClient, materielId: number) {
  const { data: equipement } = await supabase.from("site_materiels").select("*").eq("id", materielId).maybeSingle();
  if (!equipement) return null;
  const e = equipement as unknown as Equipement;
  let requete = supabase.from("types_fluide").select("id, libelle, gwp, familles_gaz(libelle)");
  requete = e.fluide_id ? requete.eq("id", e.fluide_id) : requete.eq("libelle", e.fluide_libelle ?? "");
  const { data: fluide } = await requete.limit(1).maybeSingle();
  return { equipement: e, fluide: (fluide as unknown as Fluide | null) ?? null };
}

/** Certificat d'étanchéité (état Access « Test Cerfa ») pour un équipement ; mise en page équivalente au Cerfa. */
export async function genererCerfaPdf(supabase: SupabaseClient, materielId: number): Promise<{ cerfa: Cerfa | null; erreurs: string[] }> {
  const charge = await chargerEquipementCE(supabase, materielId);
  if (!charge) return { cerfa: null, erreurs: ["Équipement introuvable."] };
  const { equipement: e, fluide } = charge;
  const erreurs = controlerEquipementCE(e, fluide);
  if (erreurs.length || !fluide) return { cerfa: null, erreurs };

  const [{ data: site }, { data: intervention }, parametres] = await Promise.all([
    supabase.from("sites").select("nom, adresse, code_postal, ville, detection_fuite_permanente").eq("id", e.site_id).maybeSingle(),
    e.intervention_id
      ? supabase.from("interventions").select("id, legacy_id, date_realisee, signature_technicien_nom, signature_client_nom, noms_techniciens").eq("id", e.intervention_id).maybeSingle()
      : Promise.resolve({ data: null }),
    chargerParametres(supabase),
  ]);

  const famille = fluide.familles_gaz!.libelle as FamilleCE;
  const kg = e.charge_fluide_kg!;
  const tco2 = Math.round((kg * fluide.gwp! * 100) / 1000) / 100;
  const [c1, c2, c3] = seuils(famille, kg, tco2);
  const dateControle = new Date(e.date_controle_etancheite ?? intervention?.date_realisee ?? Date.now());
  const annee = dateControle.getUTCFullYear();

  const r = await Redacteur.creer();
  r.ligne("CERTIFICAT DE CONTRÔLE D'ÉTANCHÉITÉ", { taille: 15, gras: true });
  r.ligne("Équipements contenant des fluides frigorigènes (mise en page équivalente au formulaire Cerfa)", { taille: 8 });

  r.titre("Opérateur");
  r.champ("Raison sociale", parametres.operateur_nom ?? "FMC Maintenance");
  r.champ("Adresse", parametres.operateur_adresse ?? "2 rue Galilée, 33185 Le Haillan");
  r.champ("SIRET", parametres.operateur_siret);
  r.champ("N° d'attestation de capacité", parametres.operateur_attestation);
  r.champ("Détecteur de fuites", parametres.detecteur_fuites);

  r.titre("Détenteur / site");
  r.champ("Site", site?.nom);
  r.champ("Adresse", [site?.adresse, site?.code_postal, site?.ville].filter(Boolean).join(" ") || null);
  r.champ("N° d'intervention", intervention ? (intervention.legacy_id ?? intervention.id) : null);
  r.champ("Emplacement de l'équipement", e.emplacement);

  r.titre("Équipement");
  r.champ("Marque / Référence / N° de série", `${e.marque} / ${e.reference} / ${e.numero_serie}`);
  r.champ("Fluide", `${fluide.libelle} (${famille}, GWP ${fluide.gwp})`);
  r.champ("Charge", `${kg} kg`);
  r.champ("Équivalent CO2", `${tco2} t.éq.CO2`);

  r.titre("Périodicité du contrôle");
  if (famille === "HCFC") {
    r.case(c1, "HCFC : charge < 30 kg");
    r.case(c2, "HCFC : charge de 30 kg à moins de 300 kg");
    r.case(c3, "HCFC : charge ≥ 300 kg");
  } else if (famille === "HFC") {
    r.case(c1, "HFC : moins de 50 t.éq.CO2");
    r.case(c2, "HFC : de 50 à moins de 500 t.éq.CO2");
    r.case(c3, "HFC : 500 t.éq.CO2 et plus");
  } else {
    r.case(c1, "HFO : charge < 10 kg");
    r.case(c2, "HFO : charge de 10 kg à moins de 100 kg");
    r.case(c3, "HFO : charge ≥ 100 kg");
  }
  r.case(!!site?.detection_fuite_permanente, "Équipement muni d'un système permanent de détection de fuite");
  r.case(!site?.detection_fuite_permanente, "Équipement sans système permanent de détection de fuite");

  r.titre("Contrôle");
  r.champ("Date du contrôle", formatDate(dateControle));
  r.champ("Début de période", `02/01/${annee}`);
  r.champ("Résultat", "Aucune fuite détectée");

  r.titre("Signatures");
  r.champ("Technicien", intervention?.signature_technicien_nom ?? intervention?.noms_techniciens);
  r.champ("Détenteur", intervention?.signature_client_nom);
  r.champ("Date", formatDate(intervention?.date_realisee ?? dateControle));

  const nomFichier = nomFichierSur(`${intervention?.legacy_id ?? intervention?.id ?? "sans-intervention"}-${e.id}.pdf`);
  return { cerfa: { octets: await r.sauvegarder(), nomFichier, annee }, erreurs: [] };
}
