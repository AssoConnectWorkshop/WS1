import { trim } from '../lib/transform.mjs';

// Absent de legacy/referentiels.txt : chargé ici directement depuis la source (étape 2).
export default {
  target: 'types_telecommande',
  conflictColumns: ['code'],
  source: `select id, TypeTelecommande from TypeTel`,
  transform(row) {
    return { code: row.id, libelle: trim(row.TypeTelecommande) };
  },
};
