import { toIntOrNull } from '../lib/transform.mjs';

export default {
  target: 'intervenant_zones',
  conflictColumns: ['intervenant_id', 'rang'],
  lookups: [
    { name: 'intervenantIdByLegacyId', table: 'intervenants', column: 'legacy_id' },
    { name: 'zoneIdByCode', table: 'zones_geographiques', column: 'code' },
  ],
  source: `
    select numintervenant, numzonint, numzonint_2_Interv, numzonint_3_Interv, numzonint_4_Interv
    from Intervenant
  `,
  transform(row, ctx) {
    const intervenantId = ctx.get('intervenantIdByLegacyId').get(row.numintervenant);
    if (intervenantId == null) return null;

    const zoneIds = ctx.get('zoneIdByCode');
    const zones = [
      [1, row.numzonint],
      [2, row.numzonint_2_Interv],
      [3, row.numzonint_3_Interv],
      [4, row.numzonint_4_Interv],
    ];

    return zones
      .filter(([, code]) => toIntOrNull(code) != null)
      .map(([rang, code]) => ({
        intervenant_id: intervenantId,
        zone_id: zoneIds.get(toIntOrNull(code)) ?? null,
        rang,
      }));
  },
};
