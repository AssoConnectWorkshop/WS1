import { toIntOrNull, toBoolNotNull, trim } from '../lib/transform.mjs';
import { mssqlDateOnly, mssqlDatetimeToTime, mssqlDatetimeToUtc } from '../lib/dates.mjs';

export default {
  target: 'heures_techniciens',
  conflictColumns: ['legacy_id'],
  lookups: [
    { name: 'utilisateurIdByLegacyId', table: 'utilisateurs', column: 'legacy_id' },
    { name: 'siteIdByLegacyId', table: 'sites', column: 'legacy_id' },
  ],
  source: `
    select Numero, NumeroTech, TypeInterv, NumInterv, NomInterv, DateInterv, HeureDebut,
           HeureFin, HeureDebut_FMC, HeureFin_FMC, InterdictionModif, NumeroSite, DateSaisie,
           NePasComptabiliser
    from HeuresTech
  `,
  transform(row, ctx) {
    return {
      legacy_id: row.Numero,
      utilisateur_id: ctx.get('utilisateurIdByLegacyId').get(row.NumeroTech) ?? null,
      type_code: toIntOrNull(row.TypeInterv),
      // Clé = numéro de bon (Intervention.numint), pas legacy_id : gardé brut (cf. dictionnaire.md).
      intervention_numero_bon: toIntOrNull(row.NumInterv),
      libelle: trim(row.NomInterv),
      date_travail: mssqlDateOnly(row.DateInterv),
      heure_debut: mssqlDatetimeToTime(row.HeureDebut),
      heure_fin: mssqlDatetimeToTime(row.HeureFin),
      heure_debut_fmc: mssqlDatetimeToTime(row.HeureDebut_FMC),
      heure_fin_fmc: mssqlDatetimeToTime(row.HeureFin_FMC),
      verrouille: toBoolNotNull(row.InterdictionModif, false),
      site_id: ctx.get('siteIdByLegacyId').get(row.NumeroSite) ?? null,
      date_saisie: mssqlDatetimeToUtc(row.DateSaisie),
      ne_pas_comptabiliser: toBoolNotNull(row.NePasComptabiliser, false),
    };
  },
};
