import { parseHHMM } from '../lib/dates.mjs';

const JOURS = [
  [1, 'hor_lun_ouv', 'hor_lun_fer'],
  [2, 'hor_mar_ouv', 'hor_mar_fer'],
  [3, 'hor_mer_ouv', 'hor_mer_fer'],
  [4, 'hor_jeu_ouv', 'hor_jeu_fer'],
  [5, 'hor_ven_ouv', 'hor_ven_fer'],
  [6, 'hor_sam_ouv', 'hor_sam_fer'],
  [7, 'hor_dim_ouv', 'hor_dim_fer'],
];

export default {
  target: 'site_horaires',
  conflictColumns: ['site_id', 'jour'],
  lookups: [{ name: 'siteIdByLegacyId', table: 'sites', column: 'legacy_id' }],
  source: `
    select cptsit, hor_lun_ouv, hor_lun_fer, hor_mar_ouv, hor_mar_fer, hor_mer_ouv, hor_mer_fer,
           hor_jeu_ouv, hor_jeu_fer, hor_ven_ouv, hor_ven_fer, hor_sam_ouv, hor_sam_fer,
           hor_dim_ouv, hor_dim_fer
    from Site
  `,
  transform(row, ctx) {
    const siteId = ctx.get('siteIdByLegacyId').get(row.cptsit);
    if (siteId == null) return null;

    return JOURS.map(([jour, ouvCol, ferCol]) => ({
      site_id: siteId,
      jour,
      ouverture: parseHHMM(row[ouvCol]),
      fermeture: parseHHMM(row[ferCol]),
    })).filter((r) => r.ouverture != null || r.fermeture != null);
  },
};
