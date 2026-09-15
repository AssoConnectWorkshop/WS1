import { toIntOrNull, toNumberOrNull } from '../lib/transform.mjs';
import { mssqlDateOnly } from '../lib/dates.mjs';

export default {
  target: 'intervenant_activites',
  conflictColumns: ['intervenant_id', 'rang'],
  lookups: [
    { name: 'intervenantIdByLegacyId', table: 'intervenants', column: 'legacy_id' },
    { name: 'activiteIdByCode', table: 'activites', column: 'code' },
  ],
  source: `
    select numintervenant,
           Activite_1, MO_Activite_1, Depl_Activite_1, Date_Activite_1,
           Activite_2, MO_Activite_2, Depl_Activite_2, Date_Activite_2,
           Activite_3, MO_Activite_3, Depl_Activite_3, Date_Activite_3,
           Activite_4, MO_Activite_4, Depl_Activite_4, Date_Activite_4,
           Activite_5, MO_Activite_5, Depl_Activite_5, Date_Activite_5,
           Activite_6, MO_Activite_6, Depl_Activite_6, Date_Activite_6
    from Intervenant
  `,
  transform(row, ctx) {
    const intervenantId = ctx.get('intervenantIdByLegacyId').get(row.numintervenant);
    if (intervenantId == null) return null;

    const activiteIds = ctx.get('activiteIdByCode');
    const rangs = [1, 2, 3, 4, 5, 6].map((n) => ({
      rang: n,
      code: toIntOrNull(row[`Activite_${n}`]),
      tarifMo: toNumberOrNull(row[`MO_Activite_${n}`]),
      tarifDepl: toNumberOrNull(row[`Depl_Activite_${n}`]),
      dateTarif: mssqlDateOnly(row[`Date_Activite_${n}`]),
    }));

    return rangs
      .filter((r) => r.code != null)
      .map((r) => ({
        intervenant_id: intervenantId,
        activite_id: activiteIds.get(r.code) ?? null,
        rang: r.rang,
        tarif_mo: r.tarifMo,
        tarif_deplacement: r.tarifDepl,
        date_tarif: r.dateTarif,
      }));
  },
};
