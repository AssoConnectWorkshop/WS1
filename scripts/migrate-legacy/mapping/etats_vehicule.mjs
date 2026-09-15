import { trim } from '../lib/transform.mjs';

// Absent de legacy/referentiels.txt : chargé ici directement depuis la source (étape 2).
// Code 4 = vendu (cf. docs/plan/etape-1.md).
export default {
  target: 'etats_vehicule',
  conflictColumns: ['code'],
  source: `select Numero, EtatVehicule from ListeEtatVehicule`,
  transform(row) {
    return { code: row.Numero, libelle: trim(row.EtatVehicule) };
  },
};
