import { trim, toBoolNotNull, toIntOrNull, toNumberOrNull } from '../lib/transform.mjs';
import { mssqlDatetimeToUtc, mssqlDateOnly, sourceTimestamps } from '../lib/dates.mjs';

const CLIENT_INCONNU_LEGACY_ID = -1;

export default {
  target: 'sites',
  conflictColumns: ['legacy_id'],
  lookups: [
    { name: 'clientIdByLegacyId', table: 'clients', column: 'legacy_id' },
    { name: 'zoneIdByCode', table: 'zones_geographiques', column: 'code' },
    { name: 'intervenantIdByLegacyId', table: 'intervenants', column: 'legacy_id' },
    { name: 'donneurIdByLegacyId', table: 'donneurs_ordre', column: 'legacy_id' },
    { name: 'fluideIdByCode', table: 'types_fluide', column: 'code' },
  ],
  // Garantit l'existence d'un client sentinelle pour les sites orphelins (client
  // supprimé en source) : cf. docs/plan/etape-2.md "Orphelins".
  async before(pgPool) {
    await pgPool.query(
      `insert into public.clients (legacy_id, nom, actif)
       values ($1, 'Client inconnu (migration)', false)
       on conflict (legacy_id) do nothing`,
      [CLIENT_INCONNU_LEGACY_ID]
    );
  },
  source: `
    select cptsit, numsit, numcli, codsit, nomsit, nomsocsit, sitsit, typsit, adrsit, codpossit,
           vilsit, telsit, faxsit, melsti, civres, nomres, preres, telcencom, numzonsit, numzone2,
           numintervenant, donneurid, surven, surtot, nbrentsit, nbrdesenfsit, datdervisdes,
           comsit, commentaire, InfosCompl, Invest, datcresit, demixasit, indclitec, indvetust,
           indpuissance, indaccessib, nbrplan, nbrpho, allumageclim, domotique, accessfiltre,
           datprisencharge, misajoursecurite, aspirateur, typfluid, temp_entree, temp_sortie,
           longitude, latitude, precisiongeo, chemindoc, datemiseenservicesite,
           garantiepiecesmainoeuvre, garantiepieces, garantiecompresseur,
           datedernierevisiteentretien, photoafaire, photofaite, auditafaire, auditfait,
           controleetancheiteafaire, controleetancheitefait, controleetancheiteponctuel,
           Mess_Devis, NumEsabora, AvecPrixSite, PrixMo, PrixDepl, RDV_Prendre, fermeture,
           datefermeture, motiffermeture, majregistresecuritefait, majregistresecuriteafaire,
           creele, majle
    from Site
  `,
  transform(row, ctx) {
    let clientId = ctx.get('clientIdByLegacyId').get(row.numcli) ?? null;
    if (clientId == null) {
      clientId = ctx.get('clientIdByLegacyId').get(CLIENT_INCONNU_LEGACY_ID);
      ctx.report.sites_orphelins = (ctx.report.sites_orphelins || []).concat(row.cptsit);
    }

    return {
      legacy_id: row.cptsit,
      numero_magasin: toIntOrNull(row.numsit),
      client_id: clientId,
      code_client: trim(row.codsit),
      nom: trim(row.nomsit),
      nom_societe: trim(row.nomsocsit),
      situation: trim(row.sitsit),
      type_site: trim(row.typsit),
      adresse: trim(row.adrsit),
      code_postal: trim(row.codpossit),
      ville: trim(row.vilsit),
      telephone: trim(row.telsit),
      fax: trim(row.faxsit),
      email: trim(row.melsti),
      responsable_civilite: trim(row.civres),
      responsable_nom: trim(row.nomres),
      responsable_prenom: trim(row.preres),
      telephone_centre_commercial: trim(row.telcencom),
      zone_id: ctx.get('zoneIdByCode').get(toIntOrNull(row.numzonsit)) ?? null,
      zone_secondaire_id: ctx.get('zoneIdByCode').get(toIntOrNull(row.numzone2)) ?? null,
      intervenant_id: ctx.get('intervenantIdByLegacyId').get(row.numintervenant) ?? null,
      donneur_ordre_id: ctx.get('donneurIdByLegacyId').get(row.donneurid) ?? null,
      surface_vente: toNumberOrNull(row.surven),
      surface_totale: toNumberOrNull(row.surtot),
      visites_entretien_par_an: toIntOrNull(row.nbrentsit),
      nombre_desenfumage: toIntOrNull(row.nbrdesenfsit),
      date_derniere_visite_desenfumage: mssqlDatetimeToUtc(row.datdervisdes),
      commentaire_general: trim(row.comsit),
      commentaire_divers: trim(row.commentaire),
      descriptif_investissement: trim(row.InfosCompl),
      investissement: toBoolNotNull(row.Invest, false),
      date_creation_site_brut: trim(row.datcresit),
      particulier: toBoolNotNull(row.demixasit, false),
      indice_qualite: toIntOrNull(row.indclitec),
      indice_vetuste: toIntOrNull(row.indvetust),
      indice_puissance: toIntOrNull(row.indpuissance),
      indice_accessibilite: toIntOrNull(row.indaccessib),
      nombre_plans: toIntOrNull(row.nbrplan),
      nombre_photos: toIntOrNull(row.nbrpho),
      allumage_clim: toBoolNotNull(row.allumageclim, false),
      gtb: toBoolNotNull(row.domotique, false),
      fluide_id: ctx.get('fluideIdByCode').get(toIntOrNull(row.typfluid)) ?? null,
      temperature_entree: trim(row.temp_entree),
      temperature_sortie: trim(row.temp_sortie),
      longitude: toNumberOrNull(row.longitude),
      latitude: toNumberOrNull(row.latitude),
      precision_geo: trim(row.precisiongeo),
      dossier_chemin: trim(row.chemindoc),
      date_mise_en_service: mssqlDateOnly(row.datemiseenservicesite),
      garantie_pieces_mo_annees: toIntOrNull(row.garantiepiecesmainoeuvre),
      garantie_pieces_annees: toIntOrNull(row.garantiepieces),
      garantie_compresseur_annees: toIntOrNull(row.garantiecompresseur),
      date_prise_en_charge: mssqlDatetimeToUtc(row.datprisencharge),
      date_derniere_visite_entretien: mssqlDatetimeToUtc(row.datedernierevisiteentretien),
      photo_a_faire: toBoolNotNull(row.photoafaire, false),
      photo_faite: toBoolNotNull(row.photofaite, false),
      audit_a_faire: toBoolNotNull(row.auditafaire, false),
      audit_fait: toBoolNotNull(row.auditfait, false),
      controle_etancheite_a_faire: toBoolNotNull(row.controleetancheiteafaire, false),
      controle_etancheite_fait: toBoolNotNull(row.controleetancheitefait, false),
      detection_fuite_permanente: toBoolNotNull(row.controleetancheiteponctuel, false),
      resume_devis_html: trim(row.Mess_Devis),
      numero_esabora: trim(row.NumEsabora),
      tarifs_specifiques: toBoolNotNull(row.AvecPrixSite, false),
      tarif_heure_mo: toNumberOrNull(row.PrixMo),
      tarif_deplacement: toNumberOrNull(row.PrixDepl),
      rdv_a_prendre: toBoolNotNull(row.RDV_Prendre, false),
      ferme: toBoolNotNull(row.fermeture, false),
      date_fermeture: mssqlDateOnly(row.datefermeture),
      motif_fermeture: trim(row.motiffermeture),
      ne_plus_intervenir: toBoolNotNull(row.majregistresecuritefait, false),
      retard_paiement: toBoolNotNull(row.misajoursecurite, false),
      nacelle_necessaire: toBoolNotNull(row.majregistresecuriteafaire, false),
      arret_urgence_clim_oui: toBoolNotNull(row.aspirateur, false),
      arret_urgence_clim_non: toBoolNotNull(row.accessfiltre, false),
      ...sourceTimestamps(row.creele, row.majle),
    };
  },
};
