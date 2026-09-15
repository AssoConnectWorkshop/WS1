import { trim, toBoolNotNull, toNumberOrNull } from '../lib/transform.mjs';

export default {
  target: 'donneurs_ordre',
  conflictColumns: ['legacy_id'],
  source: `
    select donneurid, nomdonneur, adrdonneur, codposdonneur, vildonneur, teldonneur, faxdonneur,
           condonneur, meldonneur, hormaxintdonneur, cheminpho, cheminpla, affdonneur, sairapdonneur
    from Donneur
  `,
  transform(row) {
    return {
      legacy_id: row.donneurid,
      nom: trim(row.nomdonneur),
      adresse: trim(row.adrdonneur),
      code_postal: trim(row.codposdonneur),
      ville: trim(row.vildonneur),
      telephone: trim(row.teldonneur),
      fax: trim(row.faxdonneur),
      contact_principal: trim(row.condonneur),
      email: trim(row.meldonneur),
      delai_intervention_heures: toNumberOrNull(row.hormaxintdonneur),
      logo_chemin: trim(row.cheminpho),
      pied_page_ligne_1: trim(row.meldonneur),
      pied_page_ligne_2: trim(row.cheminpho),
      pied_page_ligne_3: trim(row.cheminpla),
      actif: toBoolNotNull(row.affdonneur, true),
      saisie_simplifiee_tablette: toBoolNotNull(row.sairapdonneur, false),
    };
  },
};
