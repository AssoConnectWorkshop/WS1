export default {
  target: 'intervention_techniciens',
  conflictColumns: ['legacy_id'],
  lookups: [
    { name: 'interventionIdByLegacyId', table: 'interventions', column: 'legacy_id' },
    { name: 'utilisateurIdByLegacyId', table: 'utilisateurs', column: 'legacy_id' },
  ],
  source: `select numintuti, numintint, numuti from InterventionTechnicien`,
  transform(row, ctx) {
    const interventionId = ctx.get('interventionIdByLegacyId').get(row.numintint);
    if (interventionId == null) return null;
    return {
      legacy_id: row.numintuti,
      intervention_id: interventionId,
      utilisateur_id: ctx.get('utilisateurIdByLegacyId').get(row.numuti) ?? null,
    };
  },
};
