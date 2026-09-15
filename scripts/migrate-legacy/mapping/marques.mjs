import { trim } from '../lib/transform.mjs';

// Absent de legacy/referentiels.txt : chargé ici directement depuis la source (étape 2).
export default {
  target: 'marques',
  conflictColumns: ['code'],
  source: `select nummar, nommar from Marque`,
  transform(row) {
    const libelle = trim(row.nommar);
    if (libelle == null) return null;
    return { code: row.nummar, libelle };
  },
};
