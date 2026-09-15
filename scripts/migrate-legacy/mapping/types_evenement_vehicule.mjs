import { trim } from '../lib/transform.mjs';

// Absent de legacy/referentiels.txt : chargé ici directement depuis la source (étape 2).
export default {
  target: 'types_evenement_vehicule',
  conflictColumns: ['code'],
  source: `select Numero, Evenement_Vehicule from ListeEVVehicule`,
  transform(row) {
    return { code: row.Numero, libelle: trim(row.Evenement_Vehicule) };
  },
};
