// Second passage : pose interlocuteur_fmc_id / cree_par_id sur `intervenants`, une fois
// `utilisateurs` chargée (dépendance circulaire intervenants <-> utilisateurs).
export default {
  kind: 'update-pass',
  target: 'intervenants',
  keyColumn: 'legacy_id',
  updateColumns: ['interlocuteur_fmc_id', 'cree_par_id'],
  lookups: [{ name: 'utilisateurIdByLegacyId', table: 'utilisateurs', column: 'legacy_id' }],
  source: `select numintervenant, ChargeAffaireFMC_Interv, CreePar_Interv from Intervenant`,
  transform(row, ctx) {
    const utilisateurIds = ctx.get('utilisateurIdByLegacyId');
    const interlocuteurFmcId = utilisateurIds.get(row.ChargeAffaireFMC_Interv) ?? null;
    const creeParId = utilisateurIds.get(row.CreePar_Interv) ?? null;
    if (interlocuteurFmcId == null && creeParId == null) return null;
    return {
      legacy_id: row.numintervenant,
      interlocuteur_fmc_id: interlocuteurFmcId,
      cree_par_id: creeParId,
    };
  },
};
