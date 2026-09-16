/** Pré-filtres `?vue=` du tableau de bord vers /interventions (brief étape 4 §4.2). */
export const VUE_FILTERS: Record<
  string,
  { statut_code?: number; statut_facturation_code?: number; devis_a_faire?: boolean }
> = {
  "a-valider": { statut_code: 9 },
  // Icône « ENTRETIEN / DEPANNAGE DEVIS ACCEPTES » : ouvre la liste sur « A planifier » (constaté sur la capture de démo, 16/09).
  "a-planifier": { statut_code: 1 },
  "a-facturer": { statut_facturation_code: 1 },
  direction: { statut_facturation_code: 8 },
  standby: { statut_facturation_code: 9 },
  "a-commander": { statut_code: -1 },
  "attente-materiel": { statut_code: 2 },
  duplicata: { statut_code: 7, devis_a_faire: true },
};

/** Traduction d'une vue du menu en filtres visibles de la liste (les cases et listes reflètent le pré-filtre, décochables). */
export function parametresVue(vue: string): Record<string, string> | null {
  const v = VUE_FILTERS[vue];
  if (!v) return null;
  const p: Record<string, string> = {};
  if (v.statut_code != null) p.statut = String(v.statut_code);
  if (v.statut_facturation_code != null) p.facturation = String(v.statut_facturation_code);
  if (v.devis_a_faire) p.devis_a_faire = "1";
  return p;
}

export function lienVue(vue: string) {
  const p = parametresVue(vue);
  return p ? `/interventions?${new URLSearchParams(p).toString()}` : "/interventions";
}
