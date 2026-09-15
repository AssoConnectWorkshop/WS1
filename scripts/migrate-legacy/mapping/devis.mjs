import { trim, toIntOrNull, toNumberOrNull } from '../lib/transform.mjs';
import { mssqlDateOnly } from '../lib/dates.mjs';

const COMMON_COLUMNS = `
  NumeroDevis, NumeroDevisInterne, StatutDevis, NomFichierDevis, NomFichierDevisPartenaire,
  NumeroInterventionInterne, NumeroSite, CommentaireClientDevis, NumeroClient,
  MontantFournitureDevis, MainOeuvreDevis, NbreDeplacementDevis, DateEnvoiDevis, EnvoyePar,
  NumeroPartenaire, NumeroDevisPartenaire, MontantHTDevis, MontantHTDevisPartenaire,
  NumeroCommande, DateDevis, TypePanneDevis, QteMaterielDevis, coutheuremainoeuvre,
  coutdeplacement, NumeroDevisRemplacement
`;

// Trois tables source identiques (cf. legacy/schema.sql), fusionnées ici avec une colonne
// `famille` distinguant leur origine (docs/plan/etape-1.md §Devis).
export default {
  target: 'devis',
  conflictColumns: ['famille', 'legacy_id'],
  lookups: [
    { name: 'interventionIdByLegacyId', table: 'interventions', column: 'legacy_id' },
    { name: 'siteIdByLegacyId', table: 'sites', column: 'legacy_id' },
    { name: 'clientIdByLegacyId', table: 'clients', column: 'legacy_id' },
    { name: 'utilisateurIdByLegacyId', table: 'utilisateurs', column: 'legacy_id' },
    { name: 'intervenantIdByLegacyId', table: 'intervenants', column: 'legacy_id' },
  ],
  sources: [
    { famille: 'sav', sql: `select ${COMMON_COLUMNS} from Devis` },
    { famille: 'travaux', sql: `select ${COMMON_COLUMNS} from DevisTravaux` },
    { famille: 'contrat', sql: `select ${COMMON_COLUMNS} from ContratDeMaintenance` },
  ],
  transform(row, ctx, famille) {
    return {
      legacy_id: row.NumeroDevis,
      famille,
      numero: trim(row.NumeroDevisInterne),
      statut_code: toIntOrNull(row.StatutDevis),
      fichier_chemin: trim(row.NomFichierDevis),
      fichier_partenaire_chemin: trim(row.NomFichierDevisPartenaire),
      intervention_origine_id: ctx.get('interventionIdByLegacyId').get(row.NumeroInterventionInterne) ?? null,
      site_id: ctx.get('siteIdByLegacyId').get(row.NumeroSite) ?? null,
      client_id: ctx.get('clientIdByLegacyId').get(row.NumeroClient) ?? null,
      commentaire_client: trim(row.CommentaireClientDevis),
      montant_fournitures: toNumberOrNull(row.MontantFournitureDevis),
      heures_mo: toNumberOrNull(row.MainOeuvreDevis),
      nombre_deplacements: toIntOrNull(row.NbreDeplacementDevis),
      tarif_heure_mo: toNumberOrNull(row.coutheuremainoeuvre),
      tarif_deplacement: toNumberOrNull(row.coutdeplacement),
      montant_ht: toNumberOrNull(row.MontantHTDevis),
      montant_ht_partenaire: toNumberOrNull(row.MontantHTDevisPartenaire),
      date_devis: mssqlDateOnly(row.DateDevis),
      date_envoi: mssqlDateOnly(row.DateEnvoiDevis),
      envoye_par_id: ctx.get('utilisateurIdByLegacyId').get(row.EnvoyePar) ?? null,
      partenaire_id: ctx.get('intervenantIdByLegacyId').get(row.NumeroPartenaire) ?? null,
      numero_devis_partenaire: trim(row.NumeroDevisPartenaire),
      numero_commande: trim(row.NumeroCommande),
      type_panne_libelle: trim(row.TypePanneDevis),
      quantite_materiel: toNumberOrNull(row.QteMaterielDevis),
      numero_devis_remplacement: trim(row.NumeroDevisRemplacement),
    };
  },
};
