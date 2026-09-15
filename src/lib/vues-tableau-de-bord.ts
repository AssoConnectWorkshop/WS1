/** Pré-filtres `?vue=` du tableau de bord vers /interventions (brief étape 4 §4.2). */
export const VUE_FILTERS: Record<
  string,
  { statut_code?: number; statut_facturation_code?: number; devis_a_faire?: boolean }
> = {
  "a-valider": { statut_code: 9 },
  "a-facturer": { statut_facturation_code: 1 },
  direction: { statut_facturation_code: 8 },
  standby: { statut_facturation_code: 9 },
  "a-commander": { statut_code: -1 },
  "attente-materiel": { statut_code: 2 },
  duplicata: { statut_code: 7, devis_a_faire: true },
};
