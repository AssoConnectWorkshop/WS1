# Étape 1 — Schéma Supabase

## Objectif

Créer le schéma cible dans Supabase via des migrations SQL dans `supabase/migrations/`
(appliquées au build par `scripts/migrate.mjs`, voir README). Charger les référentiels.
Aucune donnée métier à cette étape.

## Livrables

1. Fichiers `supabase/migrations/2026MMDDHHMMSS_<sujet>.sql`, dans l'ordre : `extensions_et_utilitaires`,
   `referentiels`, `tiers` (clients, donneurs, contacts, zones, sociétés, utilisateurs, intervenants),
   `sites`, `interventions`, `devis_planification`, `vehicules`, `vues`, `rls`, `seed_referentiels`.
2. `docs/plan/dictionnaire.md` : tableau source → cible généré depuis ce brief (table, colonne source,
   colonne cible, type, remarque). Ce fichier est la référence de l'étape 2.
3. `npm run build` vert, migrations appliquées sur Supabase (vérifier avec une requête sur
   `information_schema.tables`), push sur `main`.

## Règles générales

- Préfixe de schéma : `public`. Préfixe des noms : aucun (les tables `ws1_*` existantes du workshop
  restent intactes).
- Toute table : `id bigint generated always as identity primary key`, `legacy_id integer unique`
  (nullable pour les lignes créées après migration), `created_at timestamptz not null default now()`,
  `updated_at timestamptz not null default now()` + trigger `set_updated_at()` commun.
- Types : `int` → `integer` ; `bigint` → `bigint` ; `tinyint`, `smallint` → `smallint` ; `bit` → `boolean not null default false` ;
  `real`, `float` → `double precision` ; `money`, `decimal` → `numeric` ; `nvarchar(n)`, `nchar(n)`,
  `varchar(n)` → `text` (pas de longueur, `trim` à la migration) ; `ntext`, `varchar(max)` → `text` ;
  `datetime`, `smalldatetime` → `timestamptz` (interpréter en `Europe/Paris`) ; `date` → `date` ;
  `time` → `time` ; `image` → ignoré (à migrer vers Storage plus tard) ; `timestamp` (rowversion) → ignoré.
- Colonnes détournées : **toujours** le nouveau nom métier ci-dessous, jamais le nom source.
- Clés étrangères déclarées partout où la source en avait une implicite (liste ci-dessous), en
  `on delete restrict`, sauf tables filles (`on delete cascade`).
- Index sur toutes les FK et sur les colonnes de recherche listées.
- Commentaires SQL (`comment on column`) pour chaque colonne renommée ou détournée.

## Référentiels (charger les valeurs de `legacy/referentiels.txt`)

| Table cible | Source | Colonnes | Notes |
|---|---|---|---|
| `statuts_intervention` | StatusInterv | `code integer unique` (= IndexLigne), `libelle`, `ordre_affichage`, `actif boolean` | Ajouter les codes historiques 3 « Attente de matériel », 4 « En cours », 5 « En cours chez le sous-traitant », 6 « Effectuée en attente retour fiche » avec `actif=false`, `ordre_affichage=0` |
| `types_intervention` | TypeInterv | `code integer unique`, `libelle`, `ordre_affichage` | Ne pas charger le code 0 « Toutes » |
| `statuts_facturation` | StatutFacture | `code`, `libelle`, `ordre_affichage`, `reserve_admin boolean` (= QueKadi) | |
| `sous_types_intervention` | SousType | `code`, `libelle` | = « nature technique » |
| `natures_visite` | valeurs fixes | 1 Visite technique, 2 Visite filtres, 3 Visite maintenance générale | |
| `pannes` | Panne | `code`, `libelle`, `famille text` (préfixe avant « - » : Clim, VMC, RAC, Destrat, Chambre froide…) | Ignorer les lignes NULL (41, 47..50) mais garder le code 41 comme « Non renseignée » |
| `modes_resolution` | ModeResolution | `code`, `libelle` | historique |
| `types_fluide` | TypeFluide | `code`, `libelle`, `gwp integer`, `famille_gaz_id` | |
| `familles_gaz` | Liste_Type_Gaz | `code`, `libelle` | HCFC, HFC, HFO (« HF0 » → « HFO ») |
| `marques` | Marque | `code`, `libelle` | |
| `references_materiel` | Reference | tous les champs, `trim`, `Nommar` → `marque_id` FK, `Fluide` → `fluide_id` FK nullable, puissances en `numeric` si convertibles sinon `_brut text` | catalogue |
| `reperes` | Repere | `code`, `libelle`, `controle_etancheite boolean` | |
| `types_telecommande` | TypeTel | | |
| `types_equipement` | TypeAudit | `code`, `libelle`, `famille smallint` (chiffre avant « - ») | renommé |
| `activites` | Activites | | 20 métiers |
| `zones_geographiques` | ZoneGeographique | `code`, `libelle` | |
| `societes` | Societe | `code`, `libelle`, `est_fmc boolean` (codes 1, 111, 112, 113) | |
| `jours_feries` | JoursFeries | `date_jour date unique` | |
| `ecarts_visites` | VisitesMaint | `nombre_visites`, `ecart_jours`, `commentaire` | |
| `types_evenement_vehicule` | ListeEVVehicule | | |
| `etats_vehicule` | ListeEtatVehicule | | 4 = vendu |

## Tiers

### `clients` ← Client
`numcli`→`legacy_id` ; `nomcli`→`nom` (unique) ; `adrcli`→`adresse` ; `codposcli`→`code_postal` ;
`vilcli`→`ville` ; `telcli`→`telephone` ; `faxcli`→`fax` ; `concli`→`contact_principal` ;
`melcli`→`email` ; `hormaxintcli`→`delai_intervention_heures` ; `logcli`→ ignoré ;
`cheminpho`→`numero_esabora_maint` ; `cheminpla`→`numero_esabora_clim` ; `affcli`→`actif` ;
`coutheuremainoeuvre`→`tarif_heure_mo numeric` ; `coutdeplacement`→`tarif_deplacement numeric`.
Le client legacy 368 est le « client fermé » : ajouter `est_client_fermeture boolean`.

### `donneurs_ordre` ← Donneur
`donneurid`→`legacy_id` ; `nomdonneur`→`nom` ; adresse/cp/ville/tel/fax/contact/email ;
`hormaxintdonneur`→`delai_intervention_heures` ; `logdonneur`→ ignoré ; `cheminpho`→`pied_page_ligne_2` ;
`cheminpla`→`pied_page_ligne_3` ; `meldonneur`→`pied_page_ligne_1` (voir analysis 03 §1.4 : double usage,
garder aussi `logo_chemin` = cheminpho) ; `affdonneur`→`actif` ; `sairapdonneur`→`saisie_simplifiee_tablette`.

### `contacts` ← Contact
`codcon`→`legacy_code text unique` ; `nomcon`→`nom` ; `precon`→`prenom` ; `numcli`→`client_id` ;
`numdonneur`→`donneur_ordre_id` ; `adrmelcon`→`email` ; `telcon`→`telephone` ; `faxcon`→`fax` ;
`mobcon`→`mobile` ; `obscon`→`observations` ; `foncon`→`fonction` ; `civcon`→`civilite`.

### `intervenants` ← Intervenant
`numintervenant`→`legacy_id` ; `codint`→`code text unique not null` (« FMC » = interne) ; `nomint`→`nom` ;
`numzonint`→ migré dans `intervenant_zones` (rang 1) ; adresse/cp/ville/tel/fax/email ;
`NomDirigeant_Interv`→`dirigeant_nom`, `TelDirigeant_Interv`→`dirigeant_telephone`, `Mail_Dirigeant_Interv`→`dirigeant_email` ;
`NomInterlocuteur_Interv`→`interlocuteur_nom`, `TelInterlocuteur_Interv`→`interlocuteur_telephone` ;
`Info_Interv`→`informations` ; `Histo_FMC_Interv`→`historique_fmc` ; `VillesInterventions_Interv`→`villes_codes_postaux` ;
`Latitude_Interv`/`Longitude_Interv`→`latitude`/`longitude numeric(9,6)` ; `PrecisionGeo_Interv`→`precision_geo` ;
`Rooftop_Interv`→ ignoré ; `Provenance_Interv`→`provenance` ; `ChargeAffaireFMC_Interv`→`interlocuteur_fmc_id` (FK utilisateurs) ;
`CreePar_Interv`→`cree_par_id` ; `IndMaint_Interv`→`note_maintenance`, `Ind_Depann_Interv`→`note_depannage`,
`Ind_Travaux_Interv`→`note_travaux`, `Ind_React_Interv`→`note_reactivite` (smallint 1..5) ;
`DossierOrdi_Interv`→`dossier_chemin` ; `TexteNeplusInterv`→`motif_ne_plus_intervenir` ; `EstTech`→`est_technicien_interne` ;
`NePlusIntervenir`→`ne_plus_intervenir` ; `Status_Prospect`→`est_prospect` ; `Status_ST_FMC`→`est_sous_traitant` ;
`Status_ST_FMC_Ponctuel`→`est_sous_traitant_ponctuel` ; `Status_Act_Poss_*`→`peut_maintenance/peut_depannage/peut_travaux` ;
`Status_Act_Donn_*`→`confie_maintenance/confie_depannage/confie_travaux` ; `Zone_Nationale`→`zone_nationale` ;
`MailFacturation`→`email_facturation` ; `SiteInternet`→`site_internet` ; `ExistePlus`→`n_existe_plus` ;
`AutoLiquidation`→`autoliquidation`.

### `intervenant_zones` : `intervenant_id`, `zone_id`, `rang smallint` (1..4) ← numzonint, numzonint_2/3/4_Interv.
### `intervenant_activites` : `intervenant_id`, `activite_id`, `rang`, `tarif_mo numeric`, `tarif_deplacement numeric`, `date_tarif date` ← Activite_n, MO_Activite_n, Depl_Activite_n, Date_Activite_n (n = 1..6, ignorer si Activite_n null).

### `utilisateurs` ← Utilisateur
`numuti`→`legacy_id` ; `nomuti`→`nom` ; `preuti`→`prenom` ; `loguti`→`login_legacy` ; `mdputi`→ **ignoré** ;
`codintuti`→`code_intervenant` (FK `intervenants.code`, nullable ; contient aussi d'anciens mots de passe web :
ne garder la valeur que si elle existe dans `intervenants.code`, sinon null) ; `typuti`→`profil smallint`
(1 gestionnaire, 2 technicien, 3 gestionnaire_tech) ; `nomsocuti`→`societe_libelle_legacy` ; `numsoc`→`societe_id` ;
`nummod`→ ignoré ; `Mail`→`email` ; `KmARenseigner`→`km_a_renseigner` ; `Immat`→`immatriculation` ;
ajouter `auth_user_id uuid unique references auth.users` (null jusqu'à l'invitation, étape 3) et
`role text check (role in ('gestionnaire','administrateur'))` nullable.

## Sites

### `sites` ← Site
`cptsit`→`legacy_id` ; `numsit`→`numero_magasin integer` (non unique, indexé) ; `numcli`→`client_id not null` ;
`codsit`→`code_client` ; `nomsit`→`nom` ; `nomsocsit`→`nom_societe` ; `sitsit`→`situation` ; `typsit`→`type_site` (H, F, H et F) ;
`adrsit`→`adresse` ; `codpossit`→`code_postal` ; `vilsit`→`ville` ; `telsit`→`telephone` ; `faxsit`→`fax` ; `melsti`→`email` ;
`civres`→`responsable_civilite` ; `nomres`→`responsable_nom` ; `preres`→`responsable_prenom` ; `telcencom`→`telephone_centre_commercial` ;
`numzonsit`→`zone_id` ; `numzone2`→`zone_secondaire_id` ; `numintervenant`→`intervenant_id` ; `donneurid`→`donneur_ordre_id` ;
`surven`→`surface_vente` ; `surtot`→`surface_totale` ; `datcresit`→`date_creation_site_brut text` ;
`comsit`→`commentaire_general` ; `commentaire`→`commentaire_divers` ; `InfosCompl`→`descriptif_investissement` ; `Invest`→`investissement` ;
`indclitec`→`indice_qualite` ; `indvetust`→`indice_vetuste` ; `indpuissance`→`indice_puissance` ; `indaccessib`→`indice_accessibilite` ;
`nbrplan`→`nombre_plans` ; `nbrpho`→`nombre_photos` ; `allumageclim`→`allumage_clim` ; `domotique`→`gtb` ;
`typfluid`→`fluide_id` ; `temp_entree`→`temperature_entree` ; `temp_sortie`→`temperature_sortie` ;
`longitude`/`latitude`→`numeric(9,6)` ; `precisiongeo`→`precision_geo` ; `chemindoc`→`dossier_chemin` ;
`datemiseenservicesite`→`date_mise_en_service` ; `garantiepiecesmainoeuvre`→`garantie_pieces_mo_annees` ;
`garantiepieces`→`garantie_pieces_annees` ; `garantiecompresseur`→`garantie_compresseur_annees` ;
`datprisencharge`→`date_prise_en_charge` ; `datedernierevisiteentretien`→`date_derniere_visite_entretien` ;
`datdervisdes`→`date_derniere_visite_desenfumage` ; `nbrdesenfsit`→`nombre_desenfumage` ;
`photoafaire`/`photofaite`→`photo_a_faire`/`photo_faite` ; `auditafaire`/`auditfait`→`audit_a_faire`/`audit_fait` ;
`controleetancheiteafaire`/`controleetancheitefait`→`controle_etancheite_a_faire`/`controle_etancheite_fait` ;
`controleetancheiteponctuel`→`detection_fuite_permanente` ; `Mess_Devis`→`resume_devis_html` ; `NumEsabora`→`numero_esabora` ;
`AvecPrixSite`→`tarifs_specifiques` ; `PrixMo`→`tarif_heure_mo` ; `PrixDepl`→`tarif_deplacement` ; `RDV_Prendre`→`rdv_a_prendre` ;
`fermeture`→`ferme` ; `datefermeture`→`date_fermeture` ; `motiffermeture`→`motif_fermeture` ; `creele`→`created_at` ; `majle`→`updated_at`.
**Colonnes détournées** : `majregistresecuritefait`→`ne_plus_intervenir` ; `misajoursecurite`→`retard_paiement` ;
`majregistresecuriteafaire`→`nacelle_necessaire` ; `demixasit`→`particulier` ; `aspirateur`→`arret_urgence_clim_oui` ;
`accessfiltre`→`arret_urgence_clim_non`. Ignorer `datesignaturecontrat`, `numerocontratclient` (repris dans `site_contrats`).

### `site_contrats` : `site_id`, `lot text check in ('clim','chaudiere','desenfumage')`, `numero_contrat`, `date_contrat date`,
`visites_par_an smallint`, `redevance numeric`, `redevance_secondaire numeric` (clim : filtres), `visites_secondaires smallint`,
`sous_traitant_id` (FK intervenants), `tarif_sous_traitant numeric`, `date_signature date`. Unique (`site_id`, `lot`).
Source clim : numerocontratclient, datprisencharge, nbrentsit, mntredev, montantredevancefiltre, nombrevisitefiltre, nombrevisitetechnique
(→ visites_secondaires si filtre null), montantredevancetechnique (si non null remplace mntredev), NumSousTraitClim, TarifSousTraitClim, datesignaturecontrat.
Chaudière : NumContratChaudiere, DateContratChaudiere, NombreContratChaudiere, mntredevContratChaudiere, NumSousTraitChaudiere, TarifSousTraitChaudiere.
Désenfumage : numerocontratdesenfumage, datedesenfumage, nombrevisitedesenfumage, montantredevancedesenfumage, NumSousTraitDesenfum, TarifSousTraitDesenfum.
Créer la ligne seulement si au moins une colonne du lot est renseignée. **Garder aussi `sites.visites_entretien_par_an`** (= nbrentsit) car
toute la planification s'appuie dessus.

### `site_horaires` : `site_id`, `jour smallint 1..7`, `ouverture time`, `fermeture time` ← hor_lun_ouv…hor_dim_fer (`varchar(5)` « HH:MM », null si vide ou « 00:00 »).
### `site_materiels` ← SiteMateriel : `NumeroSiteMateriel`→`legacy_id` ; `NumeroSite`→`site_id` ; `RepereSurSite`→`repere_sur_site` ; `Repere`→`repere` (text, FK souple non déclarée) ;
`Emplacement`, `Quantite`→`quantite`, `Marque`→`marque`, `Type`→`type_equipement`, `Reference`→`reference`, `NumeroSerie`→`numero_serie`,
`Reversible`→`reversible text` (OUI/NON/NC), `ResistanceElectrique`→`resistance_electrique text`, `PuissanceFrigo`→`puissance_frigo_w`,
`PuissanceCalo`→`puissance_calo_w`, **`FluideQuantite`→`fluide_libelle`** (+ `fluide_id` résolu par libellé), **`NbreRadiateurs`→`charge_fluide_kg`**,
`DateMiseEnService`→`date_mise_en_service_brut text` + `date_mise_en_service date` si convertible, `TypeTelecommande`→`type_telecommande`,
`NbreTelecommande`→`nombre_telecommandes`, `EmplacementTelecommande`→`emplacement_telecommande`, disjoncteurs → `disjoncteur_*`,
roof-top → `rooftop_*`, rideau d'air → `rideau_air_*`, `SasEntree`→`sas_entree`, `ClimLocauxSociaux*`→`clim_locaux_sociaux_*`,
`Radiateurs`→`radiateurs`, `LocalisationRadiateurs`→`radiateurs_localisation`, `DisjoncteurRadiateursTypeIntensite`→`radiateurs_disjoncteur`,
`VMC`→`vmc`, `LocalisationVMC`→`vmc_localisation`, `Photos`→`photos`, `RapportsMaintenance`→`rapports_maintenance`, `DevisEnCours`→`devis_en_cours`,
`DevisValide`→`devis_valide`, `ControleEtancheite`→`controle_etancheite_libelle`, `Observations`→`observations`,
`DateCE`→`date_controle_etancheite`, `CE_Edite`→`certificat_etancheite_edite`, `NumeroInter`→`intervention_id` (FK nullable), `DateAchat`→`date_achat`.
### `site_registre_securite` ← SiteMAJRegistre : `N°`→`legacy_id`, `cptsit`→`site_id`, `Date`→`date_mise_a_jour`.

## Interventions

### `interventions` ← Intervention
`numintint`→`legacy_id` ; `numint`→`numero_bon integer` ; `cptsit`→`site_id not null` ; `codint`→`intervenant_id` (résolu par code) ;
`typint`→`type_code integer` FK `types_intervention.code` (convertir le texte ; valeurs non numériques → null + `type_brut`) ;
`staint`→`statut_code integer` FK `statuts_intervention.code` ; `natureintervention`→`nature_visite_code` ;
`datheuapp`→`date_demande timestamptz` ; `datheulim`→`date_limite timestamptz` ; `datintpre`→`date_prevue` ; `heuintpre`→`heure_prevue time` ;
`datint`→`date_realisee` ; `heuarrint`→`heure_arrivee` ; `heudepint`→`heure_depart` ; `tpsallint`→`temps_aller interval` ; `tpsretint`→`temps_retour interval`
(les 4 sont des `datetime` ne portant que l'heure : extraire l'heure) ; `datefintech`→`date_retour_fiche` ;
`objint`→`objet` ; `comint`→`commentaire_interne` ; `dirint`→`directives` ; `comintposint`→`commentaire_post_intervention` ; `comtec`→`commentaire_technicien` ;
`refint`→`reference_interne` ; `refcliint`→`reference_client` ; `cheficdemcli`→`chemin_di_client` ; `cheficdemint`→`chemin_bon_pdf` ; `CheminDossEtanch`→`chemin_dossier_etancheite` ;
`codcon`→`contact_id` (résolu par legacy_code) ; `codpan`→`panne_code` ; `pannoncli`→`panne_origine_externe` ;
`traitepar`→`charge_affaire_id` ; `saisiepar`→`saisi_par_id` ; `prediagpar`→`prediag_par_id` ; `prediagres`→`prediag_resolu` ;
`envoisoustraitantpar`→`envoye_sous_traitant_par_id` ; `numerodemandesoustraitant`→`numero_demande_sous_traitant` ; `numutipre`→`technicien_prevu_id` ;
`nbrtecint`→`nombre_techniciens` ; `retourficheoriginal`→`retour_fiche_original` ; `retourfichecopie`→`retour_fiche_copie` ; `retourfichecopieordi`→`retour_fiche_numerique` ;
`majregsec`→`registre_securite_mis_a_jour` ; `controleetancheite`→`controle_etancheite_annuel` ; `controleetancheiteponctuel`→`controle_etancheite_ponctuel` ;
`photofaite`→`photo_faite` ; `auditfait`→`audit_fait` ; `heuvis`→`masquer_heures_sur_bon` ; `visitegratuite`→`visite_gratuite` ;
`devisafaire`→`devis_a_faire` ; `devisfait`→`devis_fait` ; `devisanepasfaire`→`devis_ne_sera_pas_fait` ; `comdevis`→`commentaire_devis` ; `comdevisinterne`→`commentaire_devis_interne` ;
`numdevacc`→`numero_devis_accepte` ; `numdev`→`numero_devis_legacy` ; `duplicatafait`→`duplicata_traite` ;
`intfac`→`non_facturable` ; `intfactok`→`facturee_legacy` ; `mntfac`→`montant_facture_legacy` ; `mntfmc`→`montant_fmc` ; `mntst`→`montant_sous_traitant` ;
`rappel24h/48h/72h/rappelsemaine`→`rappel_24h/48h/72h/semaine` ; `dateenvoimail`→`date_dernier_rappel` ;
`sigsitimg/sigcliimg/sigtecimg`→`signature_site_image/client_image/technicien_image` (chemins) ; `sigsit2/sigcli2/sigtec2`→`signature_site_nom/client_nom/technicien_nom` ;
`sigtecjson/sigclijson/sigsitbase64`→`signature_technicien_json/client_json/site_base64` ; `creele`→`created_at` ; `majle`→`updated_at`.
**Colonnes détournées** : `nbrappint`→`statut_facturation_code` FK ; `imprimeepar`→`sous_type_code` FK ; `retourficheinterventionpar`→`minutes_telephone integer` ;
`devisepar`→`urgence_devis smallint` (1..3) ; `stadev`→`duplicata_traite_par_id` ; `numpartenaire`→`priorite integer` ; `numdevpartenaire`→`noms_techniciens text` ;
`mnthtdevis`→`quantite_gaz_kg numeric` ; `nummodres`→`fluide_id` (FK types_fluide par code) ; `nbrpagfax`→`heures_vendues numeric` ; `intafact`→`location_nacelle` ;
`numerocommande`→`horodatage_prediag text` ; `sigsit`→`prestations_realisees` ; `sigtec`→`commentaire_cloture_panne` ; `sigcli`→`chemin_facture_fmc` ;
`commajregsec`→`chemin_facture_sous_traitant` ; `datesignaturecontrat`→`date_facturation` ; `mnthtdevpartenaire`→`montant_ht_devis_accepte` ; `numerocontratclient`→`numero_contrat_client`.
Ignorer : `classeepar`, `duplicatacreepar`, `RV`, `nbrpagfax` doublon éventuel.
Index : `site_id`, `statut_code`, `type_code`, `intervenant_id`, `date_limite`, `date_realisee`, `reference_client`, `numero_bon`, `statut_facturation_code`.

### `intervention_techniciens` ← InterventionTechnicien : `numintuti`→`legacy_id`, `numintint`→`intervention_id`, `numuti`→`utilisateur_id`. Ignorer `numint`.
### `fiches_intervention` ← FicheIntervention : `numFicheInt`→`legacy_id`, `numIntInt`→`intervention_id`, `numBon`→`numero_bon`, `dateFicheInt`→`date_fiche`, `heureDebut`/`heureFin`→`heure_debut`/`heure_fin`, `tempsAller`/`tempsRetour`→`temps_aller_h`/`temps_retour_h`, `remarques`, `ficheInt1..4`→ ignorés.
### `heures_techniciens` ← HeuresTech : `Numero`→`legacy_id`, `NumeroTech`→`utilisateur_id`, `TypeInterv`→`type_code` (60 = relevé km, garder brut), `NumInterv`→`intervention_numero_bon integer` (**clé = numéro de bon, pas legacy_id**), `NomInterv`→`libelle`, `DateInterv`→`date_travail`, `HeureDebut`/`HeureFin`, `HeureDebut_FMC`/`HeureFin_FMC`→`heure_debut_fmc`/`heure_fin_fmc`, `InterdictionModif`→`verrouille`, `NumeroSite`→`site_id`, `DateSaisie`→`date_saisie`, `NePasComptabiliser`→`ne_pas_comptabiliser`.

## Devis et planification

### `devis` ← Devis ∪ DevisTravaux ∪ ContratDeMaintenance
`famille text check in ('sav','travaux','contrat')` ; `legacy_id` = `NumeroDevis` ; unique (`famille`, `legacy_id`) (les trois tables ont des identités qui se chevauchent : `legacy_id` n'est donc **pas** unique seul sur cette table, exception à la règle générale) ;
`NumeroDevisInterne`→`numero` ; `StatutDevis`→`statut_code smallint` (1 à viser, 2 visé/aucun retour, 3 annulé remplacé, 4 envoyé, 5 refusé, 6 accepté ; table `statuts_devis` à créer avec ces 6 lignes) ;
`NomFichierDevis`→`fichier_chemin` ; `NomFichierDevisPartenaire`→`fichier_partenaire_chemin` ; `NumeroInterventionInterne`→`intervention_origine_id` ; `NumeroSite`→`site_id` ; `NumeroClient`→`client_id` ;
`CommentaireClientDevis`→`commentaire_client` ; `MontantFournitureDevis`→`montant_fournitures` ; `MainOeuvreDevis`→`heures_mo` ; `NbreDeplacementDevis`→`nombre_deplacements` ;
`coutheuremainoeuvre`→`tarif_heure_mo` ; `coutdeplacement`→`tarif_deplacement` ; `MontantHTDevis`→`montant_ht` ; `MontantHTDevisPartenaire`→`montant_ht_partenaire` ;
`DateDevis`→`date_devis` ; `DateEnvoiDevis`→`date_envoi` ; `EnvoyePar`→`envoye_par_id` ; `NumeroPartenaire`→`partenaire_id` (FK intervenants nullable) ; `NumeroDevisPartenaire`→`numero_devis_partenaire` ;
`NumeroCommande`→`numero_commande` ; `TypePanneDevis`→`type_panne_libelle` ; `QteMaterielDevis`→`quantite_materiel` ; `NumeroDevisRemplacement`→`numero_devis_remplacement`.

### `planifications` ← Planification : une ligne par date : `client_id` (numcli), `rang smallint` (1..12), `date_limite date` (Tn non null), `nombre_visites` (nombrevisite), `recurrent`, `date_fin_recurrence`, `legacy_id` = numeroplanification (non unique seul : unique (`legacy_id`, `rang`)).

## Véhicules

### `vehicules` ← Vehicules : `NumVehicule`→`legacy_id`, `Immatriculation`→`immatriculation`, `EtatVehicule`→`etat_code`, `Dernier_KM`→`dernier_km`, `DateMiseCirculation`→`date_mise_en_circulation`, `KM_a_l_achat`→`km_achat`, `Km_Inter_Revision`→`km_entre_revisions`, `Temps_Mois_Inter_Revision`→`mois_entre_revisions`, `Champ_Libre`→`dossier_chemin`, `Garantie`→`garantie`, `Nb_KM_Garantie`→`garantie_km`, `Temps_Mois_Garantie`→`garantie_mois`, `Leasing`, `Nb_Km_Leasing`→`leasing_km`, `Temps_Mois_Leasing`→`leasing_mois`, `Date_Fin_Leasing`→`leasing_date_fin`, `Conducteur`→`conducteur_id`, `NumTelepeage`→`numero_telepeage`, `CodeCarteEssence`→`carte_essence_code`, `NumCarteEssence`→`carte_essence_numero`, `Marque`→`marque`, `Modele`→`modele`, `Societe`→`societe_vehicule smallint` (0 FMC Clim, 1 FMC Maint), `CritAir`→`crit_air`.
### `vehicule_evenements` ← EvVehicules : `NumEV`→`legacy_id`, `DateEv`→`date_evenement`, `Km`→`km`, `Conducteur`→`conducteur_id`, `Immat`→`immatriculation` (+ `vehicule_id` résolu), `TypeEv`→`type_code`.

## Vues (pour l'étape 4)

- `v_interventions_liste` : reprend les colonnes de la vue SQL Server `ListeInterventionGenerale` (voir `legacy/sql_modules.sql`) avec libellés joints (client, site, zone, statut, type, intervenant, statut facturation, devis lié).
- `v_sites_liste` : site + client + contrat clim + zone + intervenant.
- `v_tableau_de_bord` : les compteurs de l'écran d'accueil (voir `legacy/analysis/01_navigation_parametrage.md` §2.1) : à valider (statut 9), à facturer (facturation 1), à définir direction (facturation 8), stand-by (facturation 9), matériel à commander (-1), attente matériel (2), duplicata (statut 7 et devis_a_faire), duplicata traité / à traiter, par type en facturation 1 ou 2.

## RLS

- Activer RLS sur toutes les tables. Politique : `authenticated` peut tout lire ; écriture réservée aux
  utilisateurs présents dans `utilisateurs` avec `auth_user_id = auth.uid()` ; suppression et
  référentiels réservés au rôle `administrateur`. Fonction `current_role()` en `security definer`.
- Le service role (script de migration) contourne RLS par nature.

## Critères d'acceptation

- Toutes les migrations passent à vide et sont rejouables (`create table if not exists`, `on conflict do nothing` pour les seeds).
- `select count(*) from statuts_intervention` = 14 (10 officiels + 4 historiques) ; `types_intervention` = 12 ; `pannes` = 45 ; `types_fluide` = 13.
- `docs/plan/dictionnaire.md` liste chaque colonne source non ignorée avec sa cible.
- Build vert, push sur `main`.

## État

- [ ] Non commencée
