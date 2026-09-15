import { trim, toBoolNotNull, toNumberOrNull } from '../lib/transform.mjs';

export default {
  target: 'clients',
  conflictColumns: ['legacy_id'],
  source: `
    select numcli, nomcli, adrcli, codposcli, vilcli, telcli, faxcli, concli, melcli,
           hormaxintcli, cheminpho, cheminpla, affcli, coutheuremainoeuvre, coutdeplacement
    from Client
  `,
  transform(row) {
    return {
      legacy_id: row.numcli,
      nom: trim(row.nomcli) ?? `Client ${row.numcli}`,
      adresse: trim(row.adrcli),
      code_postal: trim(row.codposcli),
      ville: trim(row.vilcli),
      telephone: trim(row.telcli),
      fax: trim(row.faxcli),
      contact_principal: trim(row.concli),
      email: trim(row.melcli),
      delai_intervention_heures: toNumberOrNull(row.hormaxintcli),
      numero_esabora_maint: trim(row.cheminpho),
      numero_esabora_clim: trim(row.cheminpla),
      actif: toBoolNotNull(row.affcli, true),
      tarif_heure_mo: toNumberOrNull(row.coutheuremainoeuvre),
      tarif_deplacement: toNumberOrNull(row.coutdeplacement),
      est_client_fermeture: row.numcli === 368,
    };
  },
};
