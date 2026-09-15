// Second passage : pose site_materiels.intervention_id une fois `interventions` chargée
// (NumeroInter -> interventions.legacy_id, cf. docs/plan/etape-2.md "Ordre de chargement" §8).
export default {
  kind: 'update-pass',
  target: 'site_materiels',
  keyColumn: 'legacy_id',
  updateColumns: ['intervention_id'],
  lookups: [{ name: 'interventionIdByLegacyId', table: 'interventions', column: 'legacy_id' }],
  source: `select NumeroSiteMateriel, NumeroInter from SiteMateriel where NumeroInter is not null`,
  transform(row, ctx) {
    const interventionId = ctx.get('interventionIdByLegacyId').get(row.NumeroInter) ?? null;
    if (interventionId == null) return null;
    return { legacy_id: row.NumeroSiteMateriel, intervention_id: interventionId };
  },
};
