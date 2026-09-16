export type TypeColonne = "text" | "number" | "boolean" | "date" | "select";

export type ColonneConfig = {
  key: string;
  label: string;
  type?: TypeColonne;
  required?: boolean;
  /** Pour `select` : table et colonne libellé de la référence (clé = id). */
  options?: { table: string; label: string };
};

export type ReferentielConfig = {
  slug: string;
  table: string;
  label: string;
  columns: ColonneConfig[];
  orderBy: string;
  /** Code métier entier attribué automatiquement (max + 1) s'il n'est pas saisi. */
  codeAuto?: boolean;
};

const CODE: ColonneConfig = { key: "code", label: "Code", type: "number" };
const LIBELLE: ColonneConfig = { key: "libelle", label: "Libellé", type: "text", required: true };
const ORDRE: ColonneConfig = { key: "ordre_affichage", label: "Ordre", type: "number" };

const simple = (slug: string, table: string, label: string, orderBy = "code"): ReferentielConfig => ({
  slug,
  table,
  label,
  orderBy,
  codeAuto: true,
  columns: [CODE, LIBELLE],
});

export const REFERENTIELS: ReferentielConfig[] = [
  {
    slug: "statuts-intervention",
    table: "statuts_intervention",
    label: "Statuts d'intervention",
    orderBy: "ordre_affichage",
    codeAuto: true,
    columns: [CODE, LIBELLE, ORDRE, { key: "actif", label: "Actif", type: "boolean" }],
  },
  { slug: "types-intervention", table: "types_intervention", label: "Types d'intervention", orderBy: "ordre_affichage", codeAuto: true, columns: [CODE, LIBELLE, ORDRE] },
  {
    slug: "statuts-facturation",
    table: "statuts_facturation",
    label: "Statuts de facturation",
    orderBy: "ordre_affichage",
    codeAuto: true,
    columns: [CODE, LIBELLE, ORDRE, { key: "reserve_admin", label: "Réservé admin", type: "boolean" }],
  },
  simple("sous-types-intervention", "sous_types_intervention", "Sous-types d'intervention"),
  simple("natures-visite", "natures_visite", "Natures de visite"),
  { slug: "pannes", table: "pannes", label: "Pannes", orderBy: "code", codeAuto: true, columns: [CODE, LIBELLE, { key: "famille", label: "Famille", type: "text" }] },
  simple("modes-resolution", "modes_resolution", "Modes de résolution"),
  {
    slug: "types-fluide",
    table: "types_fluide",
    label: "Types de fluide",
    orderBy: "code",
    codeAuto: true,
    columns: [CODE, LIBELLE, { key: "gwp", label: "GWP", type: "number" }, { key: "famille_gaz_id", label: "Famille de gaz", type: "select", options: { table: "familles_gaz", label: "libelle" } }],
  },
  simple("familles-gaz", "familles_gaz", "Familles de gaz"),
  simple("marques", "marques", "Marques", "libelle"),
  {
    slug: "reperes",
    table: "reperes",
    label: "Repères",
    orderBy: "code",
    codeAuto: true,
    columns: [CODE, LIBELLE, { key: "controle_etancheite", label: "Soumis au contrôle d'étanchéité", type: "boolean" }],
  },
  simple("types-telecommande", "types_telecommande", "Types de télécommande"),
  { slug: "types-equipement", table: "types_equipement", label: "Types d'équipement", orderBy: "code", codeAuto: true, columns: [CODE, LIBELLE, { key: "famille", label: "Famille", type: "number" }] },
  simple("activites", "activites", "Activités"),
  simple("zones-geographiques", "zones_geographiques", "Zones géographiques", "libelle"),
  { slug: "societes", table: "societes", label: "Sociétés", orderBy: "libelle", codeAuto: true, columns: [CODE, LIBELLE, { key: "est_fmc", label: "FMC", type: "boolean" }] },
  { slug: "jours-feries", table: "jours_feries", label: "Jours fériés", orderBy: "date_jour", columns: [{ key: "date_jour", label: "Date", type: "date", required: true }] },
  {
    slug: "ecarts-visites",
    table: "ecarts_visites",
    label: "Écarts entre visites",
    orderBy: "nombre_visites",
    columns: [
      { key: "nombre_visites", label: "Nombre de visites", type: "number", required: true },
      { key: "ecart_jours", label: "Écart permis (jours)", type: "number" },
      { key: "commentaire", label: "Commentaire", type: "text" },
    ],
  },
  simple("types-evenement-vehicule", "types_evenement_vehicule", "Types d'événement véhicule"),
  simple("etats-vehicule", "etats_vehicule", "États véhicule"),
  simple("statuts-devis", "statuts_devis", "Statuts de devis"),
  {
    slug: "parametres",
    table: "parametres_application",
    label: "Paramètres de l'application",
    orderBy: "cle",
    columns: [
      { key: "cle", label: "Clé", type: "text", required: true },
      { key: "libelle", label: "Libellé", type: "text", required: true },
      { key: "valeur", label: "Valeur", type: "text" },
    ],
  },
];

export function getReferentiel(slug: string) {
  return REFERENTIELS.find((r) => r.slug === slug) ?? null;
}
