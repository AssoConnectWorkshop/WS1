/** Types d'événement véhicule (EvVehicules.TypeEv) : 0 import km, 1 et 5 relevé km, 2 révision, 3 contrôle technique, 4 contrôle complémentaire. */
export const TYPES_EVENEMENT: Record<number, string> = {
  0: "Import kilométrage",
  1: "Relevé kilométrique",
  2: "Révision",
  3: "Contrôle technique",
  4: "Contrôle complémentaire",
  5: "Relevé kilométrique",
};
export const TYPES_RELEVE_KM = [0, 1, 5];
export const ETAT_VENDU = 4;
export const ETATS_HORS_ALERTES = [4, 5];

export type Vehicule = {
  id: number;
  immatriculation: string | null;
  etat_code: number | null;
  date_mise_en_circulation: string | null;
  km_entre_revisions: number | null;
  mois_entre_revisions: number | null;
  garantie: boolean;
  garantie_mois: number | null;
  leasing: boolean;
  leasing_mois: number | null;
  leasing_date_fin: string | null;
};

export type Evenement = { vehicule_id: number | null; date_evenement: string; km: number; type_code: number | null };

export type Alertes = { ct: boolean; cc: boolean; revision: boolean; leasing: boolean; garantie: boolean };

function moisEntre(a: Date, b: Date) {
  return (b.getUTCFullYear() - a.getUTCFullYear()) * 12 + (b.getUTCMonth() - a.getUTCMonth());
}

function dernier(evenements: Evenement[], types: number[]) {
  return evenements.filter((e) => e.type_code != null && types.includes(e.type_code)).sort((x, y) => y.date_evenement.localeCompare(x.date_evenement))[0] ?? null;
}

/** Alerte_Voitures (analysis 04 §5.3) : CT > 24 mois, CC > 12 mois depuis le plus récent CT/CC, révision (km ou mois),
 * leasing (date de fin ou mois), garantie (mois). Véhicules d'état 4 (vendu) et 5 exclus par l'appelant. */
export function calculerAlertes(v: Vehicule, evenements: Evenement[], maintenant = new Date()): Alertes {
  const ct = dernier(evenements, [3]);
  const cc = dernier(evenements, [4]);
  const revision = dernier(evenements, [2]);
  const releves = evenements.filter((e) => e.type_code != null && TYPES_RELEVE_KM.includes(e.type_code));
  const releveMax = releves.sort((x, y) => y.km - x.km)[0] ?? null;
  const releveRecent = dernier(evenements, TYPES_RELEVE_KM);

  const alerteCt = !!ct && moisEntre(new Date(ct.date_evenement), maintenant) > 24;
  const dernierControle = [ct, cc].filter((e): e is Evenement => !!e).sort((x, y) => y.date_evenement.localeCompare(x.date_evenement))[0] ?? null;
  const alerteCc = !!dernierControle && moisEntre(new Date(dernierControle.date_evenement), maintenant) > 12;

  let alerteRevision = false;
  if (revision && releveMax && v.km_entre_revisions && releveMax.km - revision.km > v.km_entre_revisions) alerteRevision = true;
  else if (revision && releveRecent && v.mois_entre_revisions && Math.abs(moisEntre(new Date(revision.date_evenement), new Date(releveRecent.date_evenement))) > v.mois_entre_revisions) alerteRevision = true;

  const miseEnCirculation = v.date_mise_en_circulation ? new Date(v.date_mise_en_circulation) : null;
  let alerteLeasing = false;
  if (v.leasing) {
    if (v.leasing_date_fin) alerteLeasing = new Date(v.leasing_date_fin) < maintenant;
    else if (miseEnCirculation && v.leasing_mois) alerteLeasing = moisEntre(miseEnCirculation, maintenant) > v.leasing_mois;
  }
  const alerteGarantie = v.garantie && !!miseEnCirculation && !!v.garantie_mois && moisEntre(miseEnCirculation, maintenant) > v.garantie_mois;

  return { ct: alerteCt, cc: alerteCc, revision: alerteRevision, leasing: alerteLeasing, garantie: alerteGarantie };
}

export const LIBELLES_ALERTES: Record<keyof Alertes, string> = {
  ct: "Contrôle technique",
  cc: "Contrôle complémentaire",
  revision: "Révision",
  leasing: "Leasing",
  garantie: "Garantie",
};
