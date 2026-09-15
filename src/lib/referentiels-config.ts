export type ReferentielConfig = {
  slug: string;
  table: string;
  label: string;
  columns: { key: string; label: string }[];
  orderBy: string;
};

export const REFERENTIELS: ReferentielConfig[] = [
  { slug: "statuts-intervention", table: "statuts_intervention", label: "Statuts d'intervention", orderBy: "ordre_affichage", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }, { key: "ordre_affichage", label: "Ordre" }, { key: "actif", label: "Actif" }] },
  { slug: "types-intervention", table: "types_intervention", label: "Types d'intervention", orderBy: "ordre_affichage", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }, { key: "ordre_affichage", label: "Ordre" }] },
  { slug: "statuts-facturation", table: "statuts_facturation", label: "Statuts de facturation", orderBy: "ordre_affichage", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }, { key: "reserve_admin", label: "Réservé admin" }] },
  { slug: "sous-types-intervention", table: "sous_types_intervention", label: "Sous-types d'intervention", orderBy: "code", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }] },
  { slug: "natures-visite", table: "natures_visite", label: "Natures de visite", orderBy: "code", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }] },
  { slug: "pannes", table: "pannes", label: "Pannes", orderBy: "code", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }, { key: "famille", label: "Famille" }] },
  { slug: "modes-resolution", table: "modes_resolution", label: "Modes de résolution", orderBy: "code", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }] },
  { slug: "types-fluide", table: "types_fluide", label: "Types de fluide", orderBy: "code", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }, { key: "gwp", label: "GWP" }] },
  { slug: "familles-gaz", table: "familles_gaz", label: "Familles de gaz", orderBy: "code", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }] },
  { slug: "marques", table: "marques", label: "Marques", orderBy: "libelle", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }] },
  { slug: "reperes", table: "reperes", label: "Repères", orderBy: "code", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }, { key: "controle_etancheite", label: "Contrôle étanchéité" }] },
  { slug: "types-telecommande", table: "types_telecommande", label: "Types de télécommande", orderBy: "code", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }] },
  { slug: "types-equipement", table: "types_equipement", label: "Types d'équipement", orderBy: "code", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }, { key: "famille", label: "Famille" }] },
  { slug: "activites", table: "activites", label: "Activités", orderBy: "code", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }] },
  { slug: "zones-geographiques", table: "zones_geographiques", label: "Zones géographiques", orderBy: "libelle", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }] },
  { slug: "societes", table: "societes", label: "Sociétés", orderBy: "libelle", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }, { key: "est_fmc", label: "FMC" }] },
  { slug: "jours-feries", table: "jours_feries", label: "Jours fériés", orderBy: "date_jour", columns: [{ key: "date_jour", label: "Date" }] },
  { slug: "ecarts-visites", table: "ecarts_visites", label: "Écarts entre visites", orderBy: "nombre_visites", columns: [{ key: "nombre_visites", label: "Nombre de visites" }, { key: "ecart_jours", label: "Écart (jours)" }, { key: "commentaire", label: "Commentaire" }] },
  { slug: "types-evenement-vehicule", table: "types_evenement_vehicule", label: "Types d'événement véhicule", orderBy: "code", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }] },
  { slug: "etats-vehicule", table: "etats_vehicule", label: "États véhicule", orderBy: "code", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }] },
  { slug: "statuts-devis", table: "statuts_devis", label: "Statuts de devis", orderBy: "code", columns: [{ key: "code", label: "Code" }, { key: "libelle", label: "Libellé" }] },
];

export function getReferentiel(slug: string) {
  return REFERENTIELS.find((r) => r.slug === slug) ?? null;
}
