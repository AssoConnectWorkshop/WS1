import { toIntOrNull, toBoolNotNull } from '../lib/transform.mjs';
import { mssqlDateOnly } from '../lib/dates.mjs';

export default {
  target: 'planifications',
  conflictColumns: ['legacy_id', 'rang'],
  lookups: [{ name: 'clientIdByLegacyId', table: 'clients', column: 'legacy_id' }],
  source: `
    select numeroplanification, numcli, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12,
           nombrevisite, recurrent, datefinrecurrence
    from Planification
  `,
  transform(row, ctx) {
    const clientId = ctx.get('clientIdByLegacyId').get(row.numcli) ?? null;
    const recurrent = toBoolNotNull(row.recurrent, false);
    const dateFinRecurrence = mssqlDateOnly(row.datefinrecurrence);
    const nombreVisites = toIntOrNull(row.nombrevisite);

    const rows = [];
    for (let n = 1; n <= 12; n += 1) {
      const dateLimite = mssqlDateOnly(row[`T${n}`]);
      if (dateLimite == null) continue;
      rows.push({
        legacy_id: row.numeroplanification,
        client_id: clientId,
        rang: n,
        date_limite: dateLimite,
        nombre_visites: nombreVisites,
        recurrent,
        date_fin_recurrence: dateFinRecurrence,
      });
    }
    return rows.length > 0 ? rows : null;
  },
};
