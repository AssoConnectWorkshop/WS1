import { trim, toIntOrNull } from '../lib/transform.mjs';
import { mssqlDateOnly } from '../lib/dates.mjs';

export default {
  target: 'vehicule_evenements',
  conflictColumns: ['legacy_id'],
  lookups: [
    { name: 'vehiculeIdByImmat', table: 'vehicules', column: 'immatriculation' },
    { name: 'utilisateurIdByLegacyId', table: 'utilisateurs', column: 'legacy_id' },
    { name: 'typeEvenementCodes', table: 'types_evenement_vehicule', column: 'code' },
  ],
  source: `select NumEV, DateEv, Km, Conducteur, Immat, TypeEv from EvVehicules`,
  transform(row, ctx) {
    const immat = trim(row.Immat);
    const typeCode = toIntOrNull(row.TypeEv);
    return {
      legacy_id: row.NumEV,
      vehicule_id: immat ? ctx.get('vehiculeIdByImmat').get(immat) ?? null : null,
      date_evenement: mssqlDateOnly(row.DateEv),
      km: toIntOrNull(row.Km),
      conducteur_id: ctx.get('utilisateurIdByLegacyId').get(row.Conducteur) ?? null,
      immatriculation: immat,
      type_code: typeCode != null && ctx.get('typeEvenementCodes').has(typeCode) ? typeCode : null,
    };
  },
};
