import { trim, toBoolNotNull } from '../lib/transform.mjs';

// Absent de legacy/referentiels.txt : chargé ici directement depuis la source (étape 2).
export default {
  target: 'reperes',
  conflictColumns: ['code'],
  source: `select id, Repere, CtrlEtancheite from Repere`,
  transform(row) {
    return {
      code: row.id,
      libelle: trim(row.Repere),
      controle_etancheite: toBoolNotNull(row.CtrlEtancheite, false),
    };
  },
};
