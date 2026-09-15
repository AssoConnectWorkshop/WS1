import { trim, toBoolNotNull, toIntOrNull } from '../lib/transform.mjs';

export default {
  target: 'utilisateurs',
  conflictColumns: ['legacy_id'],
  lookups: [
    { name: 'intervenantCodes', table: 'intervenants', column: 'code' },
    { name: 'societeIdByCode', table: 'societes', column: 'code' },
  ],
  source: `
    select numuti, nomuti, preuti, loguti, codintuti, typuti, nomsocuti, numsoc,
           Mail, KmARenseigner, Immat
    from Utilisateur
  `,
  transform(row, ctx) {
    const codintuti = trim(row.codintuti);
    const intervenantCodes = ctx.get('intervenantCodes');
    const codeIntervenant = codintuti != null && intervenantCodes.has(codintuti) ? codintuti : null;

    return {
      legacy_id: row.numuti,
      nom: trim(row.nomuti),
      prenom: trim(row.preuti),
      login_legacy: trim(row.loguti),
      code_intervenant: codeIntervenant,
      profil: toIntOrNull(row.typuti),
      societe_libelle_legacy: trim(row.nomsocuti),
      societe_id: ctx.get('societeIdByCode').get(toIntOrNull(row.numsoc)) ?? null,
      email: trim(row.Mail),
      km_a_renseigner: toBoolNotNull(row.KmARenseigner, false),
      immatriculation: trim(row.Immat),
    };
  },
};
