import { trim, toIntOrNull, toNumberOrNull } from '../lib/transform.mjs';
import { mssqlDateOnly } from '../lib/dates.mjs';

function firstNonNull(...values) {
  for (const v of values) if (v != null) return v;
  return null;
}

export default {
  target: 'site_contrats',
  conflictColumns: ['site_id', 'lot'],
  lookups: [
    { name: 'siteIdByLegacyId', table: 'sites', column: 'legacy_id' },
    { name: 'intervenantIdByLegacyId', table: 'intervenants', column: 'legacy_id' },
  ],
  source: `
    select cptsit,
           numerocontratclient, datprisencharge, nbrentsit, mntredev, montantredevancetechnique,
           montantredevancefiltre, nombrevisitefiltre, nombrevisitetechnique,
           NumSousTraitClim, TarifSousTraitClim, datesignaturecontrat,
           NumContratChaudiere, DateContratChaudiere, NombreContratChaudiere,
           mntredevContratChaudiere, NumSousTraitChaudiere, TarifSousTraitChaudiere,
           numerocontratdesenfumage, datedesenfumage, nombrevisitedesenfumage,
           montantredevancedesenfumage, NumSousTraitDesenfum, TarifSousTraitDesenfum
    from Site
  `,
  transform(row, ctx) {
    const siteId = ctx.get('siteIdByLegacyId').get(row.cptsit);
    if (siteId == null) return null;
    const intervenantIds = ctx.get('intervenantIdByLegacyId');

    const rows = [];

    const climPresent = [
      row.numerocontratclient,
      row.nbrentsit,
      row.mntredev,
      row.montantredevancetechnique,
      row.montantredevancefiltre,
      row.NumSousTraitClim,
    ].some((v) => v != null);
    if (climPresent) {
      rows.push({
        site_id: siteId,
        lot: 'clim',
        numero_contrat: trim(row.numerocontratclient),
        date_contrat: mssqlDateOnly(row.datprisencharge),
        visites_par_an: toIntOrNull(row.nbrentsit),
        redevance: firstNonNull(toNumberOrNull(row.montantredevancetechnique), toNumberOrNull(row.mntredev)),
        redevance_secondaire: toNumberOrNull(row.montantredevancefiltre),
        visites_secondaires: firstNonNull(toIntOrNull(row.nombrevisitefiltre), toIntOrNull(row.nombrevisitetechnique)),
        sous_traitant_id: intervenantIds.get(row.NumSousTraitClim) ?? null,
        tarif_sous_traitant: toNumberOrNull(row.TarifSousTraitClim),
        date_signature: mssqlDateOnly(row.datesignaturecontrat),
      });
    }

    const chaudierePresent = [
      row.NumContratChaudiere,
      row.NombreContratChaudiere,
      row.mntredevContratChaudiere,
      row.NumSousTraitChaudiere,
    ].some((v) => v != null);
    if (chaudierePresent) {
      rows.push({
        site_id: siteId,
        lot: 'chaudiere',
        numero_contrat: trim(row.NumContratChaudiere),
        date_contrat: mssqlDateOnly(row.DateContratChaudiere),
        visites_par_an: toIntOrNull(row.NombreContratChaudiere),
        redevance: toNumberOrNull(row.mntredevContratChaudiere),
        redevance_secondaire: null,
        visites_secondaires: null,
        sous_traitant_id: intervenantIds.get(row.NumSousTraitChaudiere) ?? null,
        tarif_sous_traitant: toNumberOrNull(row.TarifSousTraitChaudiere),
        date_signature: null,
      });
    }

    const desenfumagePresent = [
      row.numerocontratdesenfumage,
      row.nombrevisitedesenfumage,
      row.montantredevancedesenfumage,
      row.NumSousTraitDesenfum,
    ].some((v) => v != null);
    if (desenfumagePresent) {
      rows.push({
        site_id: siteId,
        lot: 'desenfumage',
        numero_contrat: trim(row.numerocontratdesenfumage),
        date_contrat: mssqlDateOnly(row.datedesenfumage),
        visites_par_an: toIntOrNull(row.nombrevisitedesenfumage),
        redevance: toNumberOrNull(row.montantredevancedesenfumage),
        redevance_secondaire: null,
        visites_secondaires: null,
        sous_traitant_id: intervenantIds.get(row.NumSousTraitDesenfum) ?? null,
        tarif_sous_traitant: toNumberOrNull(row.TarifSousTraitDesenfum),
        date_signature: null,
      });
    }

    return rows.length > 0 ? rows : null;
  },
};
