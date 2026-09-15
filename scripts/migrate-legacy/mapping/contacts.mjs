import { trim } from '../lib/transform.mjs';

export default {
  target: 'contacts',
  conflictColumns: ['legacy_code'],
  lookups: [
    { name: 'clientIdByLegacyId', table: 'clients', column: 'legacy_id' },
    { name: 'donneurIdByLegacyId', table: 'donneurs_ordre', column: 'legacy_id' },
  ],
  source: `
    select codcon, nomcon, precon, numcli, adrmelcon, telcon, faxcon, mobcon, obscon, foncon,
           civcon, numdonneur
    from Contact
  `,
  transform(row, ctx) {
    const legacyCode = trim(row.codcon);
    if (legacyCode == null) return null;
    return {
      legacy_code: legacyCode,
      nom: trim(row.nomcon),
      prenom: trim(row.precon),
      civilite: trim(row.civcon),
      client_id: ctx.get('clientIdByLegacyId').get(row.numcli) ?? null,
      donneur_ordre_id: ctx.get('donneurIdByLegacyId').get(row.numdonneur) ?? null,
      email: trim(row.adrmelcon),
      telephone: trim(row.telcon),
      fax: trim(row.faxcon),
      mobile: trim(row.mobcon),
      fonction: trim(row.foncon),
      observations: trim(row.obscon),
    };
  },
};
