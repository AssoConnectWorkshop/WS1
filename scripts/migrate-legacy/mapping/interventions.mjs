import { trim, toBoolNotNull, toIntOrNull, toNumberOrNull, parseCodeTexte } from '../lib/transform.mjs';
import { mssqlDatetimeToUtc, mssqlDatetimeToTime, mssqlDateOnly, sourceTimestamps } from '../lib/dates.mjs';
import { ensureReferentialCodes } from '../lib/referentiels.mjs';

function validJsonOrNull(text) {
  const t = trim(text);
  if (t == null) return null;
  try {
    JSON.parse(t);
    return t;
  } catch {
    return null;
  }
}

export default {
  target: 'interventions',
  conflictColumns: ['legacy_id'],
  lookups: [
    { name: 'siteIdByLegacyId', table: 'sites', column: 'legacy_id' },
    { name: 'intervenantIdByCode', table: 'intervenants', column: 'code' },
    { name: 'contactIdByLegacyCode', table: 'contacts', column: 'legacy_code' },
    { name: 'utilisateurIdByLegacyId', table: 'utilisateurs', column: 'legacy_id' },
  ],
  // Complète les référentiels statut/type/panne/nature/statut_facturation/sous_type avec les
  // codes rencontrés en données mais absents (cf. docs/plan/etape-2.md "Ordre de chargement" §1).
  async before(pgPool, allRows, ctx) {
    await ensureReferentialCodes(pgPool, 'statuts_intervention', allRows.map((r) => toIntOrNull(r.staint)), ctx.report);
    await ensureReferentialCodes(pgPool, 'types_intervention', allRows.map((r) => parseCodeTexte(r.typint).code), ctx.report);
    await ensureReferentialCodes(pgPool, 'pannes', allRows.map((r) => toIntOrNull(r.codpan)), ctx.report);
    await ensureReferentialCodes(pgPool, 'statuts_facturation', allRows.map((r) => toIntOrNull(r.nbrappint)), ctx.report);
    await ensureReferentialCodes(pgPool, 'sous_types_intervention', allRows.map((r) => toIntOrNull(r.imprimeepar)), ctx.report);
  },
  source: `
    select numintint, numint, cptsit, codint, typint, staint, natureintervention,
           datheuapp, datheulim, datintpre, heuintpre, datint, heuarrint, heudepint,
           tpsallint, tpsretint, datefintech, objint, comint, dirint, comintposint, comtec,
           refint, refcliint, cheficdemcli, cheficdemint, CheminDossEtanch, codcon, codpan,
           pannoncli, traitepar, saisiepar, prediagpar, prediagres, envoisoustraitantpar,
           numerodemandesoustraitant, numutipre, nbrtecint, retourficheoriginal,
           retourfichecopie, retourfichecopieordi, majregsec, controleetancheite,
           controleetancheiteponctuel, photofaite, auditfait, heuvis, visitegratuite,
           devisafaire, devisfait, devisanepasfaire, comdevis, comdevisinterne, numdevacc,
           numdev, duplicatafait, intfac, intfactok, mntfac, mntfmc, mntst, rappel24h,
           rappel48h, rappel72h, rappelsemaine, dateenvoimail, sigsitimg, sigcliimg, sigtecimg,
           sigsit2, sigcli2, sigtec2, sigtecjson, sigclijson, sigsitbase64, creele, majle,
           nbrappint, imprimeepar, retourficheinterventionpar, devisepar, stadev, numpartenaire,
           numdevpartenaire, mnthtdevis, nummodres, nbrpagfax, intafact, numerocommande,
           sigsit, sigtec, sigcli, commajregsec, datesignaturecontrat, mnthtdevpartenaire,
           numerocontratclient
    from Intervention
  `,
  transform(row, ctx) {
    const siteId = ctx.get('siteIdByLegacyId').get(row.cptsit) ?? null;
    if (siteId == null) {
      ctx.report.interventions_orphelines = (ctx.report.interventions_orphelines || []).concat(row.numintint);
      return null;
    }

    const utilisateurs = ctx.get('utilisateurIdByLegacyId');
    const { code: typeCode, brut: typeBrut } = parseCodeTexte(row.typint);

    return {
      legacy_id: row.numintint,
      numero_bon: toIntOrNull(row.numint),
      site_id: siteId,
      intervenant_id: ctx.get('intervenantIdByCode').get(trim(row.codint)) ?? null,
      type_code: typeCode,
      type_brut: typeBrut,
      statut_code: toIntOrNull(row.staint),
      nature_visite_code: toIntOrNull(row.natureintervention),
      date_demande: mssqlDatetimeToUtc(row.datheuapp),
      date_limite: mssqlDatetimeToUtc(row.datheulim),
      date_prevue: mssqlDatetimeToUtc(row.datintpre),
      heure_prevue: mssqlDatetimeToTime(row.heuintpre),
      date_realisee: mssqlDatetimeToUtc(row.datint),
      heure_arrivee: mssqlDatetimeToTime(row.heuarrint),
      heure_depart: mssqlDatetimeToTime(row.heudepint),
      temps_aller: mssqlDatetimeToTime(row.tpsallint),
      temps_retour: mssqlDatetimeToTime(row.tpsretint),
      date_retour_fiche: mssqlDatetimeToUtc(row.datefintech),
      objet: trim(row.objint),
      commentaire_interne: trim(row.comint),
      directives: trim(row.dirint),
      commentaire_post_intervention: trim(row.comintposint),
      commentaire_technicien: trim(row.comtec),
      reference_interne: trim(row.refint),
      reference_client: trim(row.refcliint),
      chemin_di_client: trim(row.cheficdemcli),
      chemin_bon_pdf: trim(row.cheficdemint),
      chemin_dossier_etancheite: trim(row.CheminDossEtanch),
      contact_id: ctx.get('contactIdByLegacyCode').get(trim(row.codcon)) ?? null,
      panne_code: toIntOrNull(row.codpan),
      panne_origine_externe: toBoolNotNull(row.pannoncli, false),
      charge_affaire_id: utilisateurs.get(row.traitepar) ?? null,
      saisi_par_id: utilisateurs.get(row.saisiepar) ?? null,
      prediag_par_id: utilisateurs.get(row.prediagpar) ?? null,
      prediag_resolu: toBoolNotNull(row.prediagres, false),
      envoye_sous_traitant_par_id: utilisateurs.get(row.envoisoustraitantpar) ?? null,
      numero_demande_sous_traitant: trim(row.numerodemandesoustraitant),
      technicien_prevu_id: utilisateurs.get(row.numutipre) ?? null,
      nombre_techniciens: toIntOrNull(row.nbrtecint),
      retour_fiche_original: toBoolNotNull(row.retourficheoriginal, false),
      retour_fiche_copie: toBoolNotNull(row.retourfichecopie, false),
      retour_fiche_numerique: toBoolNotNull(row.retourfichecopieordi, false),
      registre_securite_mis_a_jour: toBoolNotNull(row.majregsec, false),
      controle_etancheite_annuel: toBoolNotNull(row.controleetancheite, false),
      controle_etancheite_ponctuel: toBoolNotNull(row.controleetancheiteponctuel, false),
      photo_faite: toBoolNotNull(row.photofaite, false),
      audit_fait: toBoolNotNull(row.auditfait, false),
      masquer_heures_sur_bon: toBoolNotNull(row.heuvis, false),
      visite_gratuite: toBoolNotNull(row.visitegratuite, false),
      devis_a_faire: toBoolNotNull(row.devisafaire, false),
      devis_fait: toBoolNotNull(row.devisfait, false),
      devis_ne_sera_pas_fait: toBoolNotNull(row.devisanepasfaire, false),
      commentaire_devis: trim(row.comdevis),
      commentaire_devis_interne: trim(row.comdevisinterne),
      numero_devis_accepte: trim(row.numdevacc),
      numero_devis_legacy: trim(row.numdev),
      duplicata_traite: toBoolNotNull(row.duplicatafait, false),
      non_facturable: toBoolNotNull(row.intfac, false),
      facturee_legacy: toBoolNotNull(row.intfactok, false),
      montant_facture_legacy: toNumberOrNull(row.mntfac),
      montant_fmc: toNumberOrNull(row.mntfmc),
      montant_sous_traitant: toNumberOrNull(row.mntst),
      rappel_24h: toBoolNotNull(row.rappel24h, false),
      rappel_48h: toBoolNotNull(row.rappel48h, false),
      rappel_72h: toBoolNotNull(row.rappel72h, false),
      rappel_semaine: toBoolNotNull(row.rappelsemaine, false),
      date_dernier_rappel: mssqlDatetimeToUtc(row.dateenvoimail),
      signature_site_image: trim(row.sigsitimg),
      signature_client_image: trim(row.sigcliimg),
      signature_technicien_image: trim(row.sigtecimg),
      signature_site_nom: trim(row.sigsit2),
      signature_client_nom: trim(row.sigcli2),
      signature_technicien_nom: trim(row.sigtec2),
      signature_technicien_json: validJsonOrNull(row.sigtecjson),
      signature_client_json: validJsonOrNull(row.sigclijson),
      signature_site_base64: trim(row.sigsitbase64),
      statut_facturation_code: toIntOrNull(row.nbrappint),
      sous_type_code: toIntOrNull(row.imprimeepar),
      minutes_telephone: toIntOrNull(row.retourficheinterventionpar),
      urgence_devis: toIntOrNull(row.devisepar),
      duplicata_traite_par_id: utilisateurs.get(row.stadev) ?? null,
      priorite: toIntOrNull(row.numpartenaire),
      noms_techniciens: trim(row.numdevpartenaire),
      quantite_gaz_kg: toNumberOrNull(row.mnthtdevis),
      fluide_id: toIntOrNull(row.nummodres),
      heures_vendues: toNumberOrNull(row.nbrpagfax),
      location_nacelle: toBoolNotNull(row.intafact, false),
      horodatage_prediag: trim(row.numerocommande),
      prestations_realisees: trim(row.sigsit),
      commentaire_cloture_panne: trim(row.sigtec),
      chemin_facture_fmc: trim(row.sigcli),
      chemin_facture_sous_traitant: trim(row.commajregsec),
      date_facturation: mssqlDateOnly(row.datesignaturecontrat),
      montant_ht_devis_accepte: toNumberOrNull(row.mnthtdevpartenaire),
      numero_contrat_client: trim(row.numerocontratclient),
      ...sourceTimestamps(row.creele, row.majle),
    };
  },
};
