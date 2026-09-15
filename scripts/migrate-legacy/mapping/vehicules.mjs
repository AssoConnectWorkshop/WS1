import { trim, toBoolNotNull, toIntOrNull } from '../lib/transform.mjs';
import { mssqlDateOnly } from '../lib/dates.mjs';

export default {
  target: 'vehicules',
  conflictColumns: ['legacy_id'],
  lookups: [
    { name: 'etatCodes', table: 'etats_vehicule', column: 'code' },
    { name: 'utilisateurIdByLegacyId', table: 'utilisateurs', column: 'legacy_id' },
  ],
  source: `
    select NumVehicule, EtatVehicule, Dernier_KM, Immatriculation, DateMiseCirculation,
           KM_a_l_achat, Km_Inter_Revision, Temps_Mois_Inter_Revision, Champ_Libre, Garantie,
           Nb_KM_Garantie, Temps_Mois_Garantie, Leasing, Nb_Km_Leasing, Temps_Mois_Leasing,
           Date_Fin_Leasing, Conducteur, NumTelepeage, CodeCarteEssence, NumCarteEssence,
           Marque, Modele, Societe, CritAir
    from Vehicules
  `,
  transform(row, ctx) {
    const etatCode = toIntOrNull(row.EtatVehicule);
    return {
      legacy_id: row.NumVehicule,
      immatriculation: trim(row.Immatriculation),
      etat_code: etatCode != null && ctx.get('etatCodes').has(etatCode) ? etatCode : null,
      dernier_km: toIntOrNull(row.Dernier_KM),
      date_mise_en_circulation: mssqlDateOnly(row.DateMiseCirculation),
      km_achat: toIntOrNull(row.KM_a_l_achat),
      km_entre_revisions: toIntOrNull(row.Km_Inter_Revision),
      mois_entre_revisions: toIntOrNull(row.Temps_Mois_Inter_Revision),
      dossier_chemin: trim(row.Champ_Libre),
      garantie: toBoolNotNull(row.Garantie, false),
      garantie_km: toIntOrNull(row.Nb_KM_Garantie),
      garantie_mois: toIntOrNull(row.Temps_Mois_Garantie),
      leasing: toBoolNotNull(row.Leasing, false),
      leasing_km: toIntOrNull(row.Nb_Km_Leasing),
      leasing_mois: toIntOrNull(row.Temps_Mois_Leasing),
      leasing_date_fin: mssqlDateOnly(row.Date_Fin_Leasing),
      conducteur_id: ctx.get('utilisateurIdByLegacyId').get(row.Conducteur) ?? null,
      numero_telepeage: trim(row.NumTelepeage),
      carte_essence_code: trim(row.CodeCarteEssence),
      carte_essence_numero: trim(row.NumCarteEssence),
      marque: trim(row.Marque),
      modele: trim(row.Modele),
      societe_vehicule: toIntOrNull(row.Societe),
      crit_air: toBoolNotNull(row.CritAir, false),
    };
  },
};
