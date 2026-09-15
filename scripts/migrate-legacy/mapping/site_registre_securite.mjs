import { mssqlDatetimeToUtc } from '../lib/dates.mjs';

export default {
  target: 'site_registre_securite',
  conflictColumns: ['legacy_id'],
  lookups: [{ name: 'siteIdByLegacyId', table: 'sites', column: 'legacy_id' }],
  source: `select [N°] as numero, cptsit, [Date] as date_maj from SiteMAJRegistre`,
  transform(row, ctx) {
    const siteId = ctx.get('siteIdByLegacyId').get(row.cptsit);
    if (siteId == null) return null;
    return {
      legacy_id: row.numero,
      site_id: siteId,
      date_mise_a_jour: mssqlDatetimeToUtc(row.date_maj),
    };
  },
};
