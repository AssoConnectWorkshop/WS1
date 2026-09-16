export const CLES_LOTS = ["clim", "chaudiere", "desenfumage"] as const;
export type Lot = (typeof CLES_LOTS)[number];
export const LIBELLES_LOT: Record<Lot, string> = { clim: "Clim", chaudiere: "Chaudière", desenfumage: "Désenfumage" };

export const JOURS = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"];

/** Listes de valeurs de la fiche Site Access (analysis 03 §2.2 et §9). */
export const SITUATIONS = [
  "Clim. dépendante (centre commercial)",
  "Clim. indépendante (centre commercial)",
  "Clim. dépendante (centre ville)",
  "Clim. indépendante (centre ville)",
  "Eficia avec pilotage",
  "Eficia sans pilotage",
];
export const TYPES_SITE = ["H", "F", "H et F"];
export const INDICES_QUALITE: Record<number, string> = { 1: "Réalisé par nous", 2: "Connu de nous", 3: "À auditer par nous", 4: "Modifié par nous" };
export const ETOILES = [1, 2, 3, 4, 5];

/** Statuts d'intervention manipulés par « Ne plus intervenir » (analysis 03 §8.2). */
export const STATUTS_EN_COURS = [-1, 1, 9];
export const STATUT_A_PLANIFIER = 1;
export const STATUT_NE_PLUS_INTERVENIR = 17;

export const REVERSIBLE_VALEURS = ["OUI", "NON", "NC"];
