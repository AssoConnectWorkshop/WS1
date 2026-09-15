import { toIntOrNull, toNumberOrNull, trim } from '../lib/transform.mjs';
import { mssqlDatetimeToUtc, mssqlDatetimeToTime } from '../lib/dates.mjs';

export default {
  target: 'fiches_intervention',
  conflictColumns: ['legacy_id'],
  lookups: [{ name: 'interventionIdByLegacyId', table: 'interventions', column: 'legacy_id' }],
  source: `
    select numFicheInt, numIntInt, numBon, dateFicheInt, heureDebut, heureFin, tempsAller,
           tempsRetour, remarques
    from FicheIntervention
  `,
  transform(row, ctx) {
    return {
      legacy_id: row.numFicheInt,
      intervention_id: ctx.get('interventionIdByLegacyId').get(row.numIntInt) ?? null,
      numero_bon: toIntOrNull(row.numBon),
      date_fiche: mssqlDatetimeToUtc(row.dateFicheInt),
      heure_debut: mssqlDatetimeToTime(row.heureDebut),
      heure_fin: mssqlDatetimeToTime(row.heureFin),
      temps_aller_h: toNumberOrNull(row.tempsAller),
      temps_retour_h: toNumberOrNull(row.tempsRetour),
      remarques: trim(row.remarques),
    };
  },
};
