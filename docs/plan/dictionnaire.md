# Dictionnaire de migration — source SQL Server (`logiclim`) → cible Supabase (`public`)

Produit à l'étape 1 (`supabase/migrations/2026091512000*.sql`). Référence pour l'étape 2
(transfert des données). Toute table cible porte `id bigint generated always as identity
primary key`, `created_at timestamptz`, `updated_at timestamptz` (trigger `set_updated_at`)
en plus des colonnes listées ci-dessous ; ces trois colonnes ne sont pas répétées par ligne.

Légende : **détournée** = la colonne source stockait autre chose que ce que son nom suggère
(voir `docs/CONTEXTE.md` §8). *Ignorée* = non reprise dans le schéma cible.

## Règles de transformation (étape 2)

Ajouté à l'étape 2 (`scripts/migrate-legacy/`) : chaque module de mapping applique l'une des
règles génériques suivantes, sauf mention contraire dans le tableau de sa table (colonne
« Remarque »/« Règle de transformation »). Implémentation : `lib/transform.mjs` et
`lib/dates.mjs`.

| Règle | Colonnes concernées (type source) | Détail |
|---|---|---|
| `trim` | tous les `nvarchar`/`varchar`/`ntext`/`text` | espaces de bord retirés, chaîne vide → `null`. |
| `bool` | `bit` | `0`/`1` → `false`/`true` ; `null` → valeur par défaut du schéma (`false` sauf mention contraire). |
| `entier`/`numeric` | `int`, `tinyint`, `smallint`, `real`, `float`, `money` | passthrough typé, `null` si non convertible. |
| `datetime Europe/Paris` | `datetime`, `smalldatetime` → `timestamptz` | la valeur « murale » lue en SQL Server (sans fuseau) est interprétée comme heure de Paris puis convertie en instant UTC (gère le changement heure été/hiver). |
| `heure seule` | colonnes `datetime` ne portant qu'une heure (souvent sentinelle `1899-12-30`) → `time`/`interval` | seule la partie heure est extraite, la date sentinelle est ignorée. |
| `date texte libre` | `nvarchar` contenant une date (`Site.datcresit`, `SiteMateriel.DateMiseEnService`) | essaie `yyyy-MM-dd`, `dd/MM/yyyy`, `dd/MM/yy` ; sinon `null` + copie brute dans `<colonne>_brut`. |
| `HH:MM` | `varchar(5)` horaires d'ouverture (`hor_*_ouv/fer`) | `null` si vide ou `00:00`, sinon `HH:MM:00`. |
| `code texte → entier` | `typint` (et assimilés) | entier si purement numérique, sinon `null` + `<colonne>_brut`. |
| `puissance texte → numeric` | `Reference.PuissanceFrigo/PuissanceCalo` | numeric si convertible, sinon `null` + `<colonne>_brut`. |
| `résolution de FK par legacy_id` | toute colonne `num*`/`cpt*` référençant une autre table | recherche l'`id` cible via `legacy_id` (jamais de reprise d'identifiant source, cf. règle générale étape 1). |
| `résolution de FK par clé texte` | `Intervention.codint`, `Intervention.codcon`, `Utilisateur.codintuti` | recherche par `intervenants.code` / `contacts.legacy_code`, `null` si introuvable. |
| `complétion de référentiel` | `staint`, `typint`, `codpan`, `nbrappint`, `imprimeepar` | code absent du référentiel chargé à l'étape 1 → ligne ajoutée avec libellé « Inconnu (code n) » (`actif=false` quand la colonne existe), signalé dans le rapport. Voir `lib/referentiels.mjs`. |
| `orphelin → sentinelle` | `Site.numcli` sans client existant | rattaché au client sentinelle `legacy_id=-1` « Client inconnu (migration) », signalé dans le rapport. |

## Référentiels

Toutes ces tables ont `id`, `code integer/smallint unique not null`, `libelle text`,
`created_at`, `updated_at` sauf mention contraire. `code` tient lieu de `legacy_id` (pas de
colonne séparée) : exception documentée à la règle générale, le code source fait déjà
office d'identifiant métier stable.

| Table cible | Source | Colonnes additionnelles | Remarques |
|---|---|---|---|
| `statuts_intervention` | StatusInterv | `ordre_affichage`, `actif` | `code` = `IndexLigne` (valeur métier posée explicitement en source). Codes historiques 3, 4, 5, 6 chargés avec `actif=false`, `ordre_affichage=0`. |
| `types_intervention` | TypeInterv | `ordre_affichage` | `code` = `IndexLigne`. Code 0 « Toutes » non chargé. |
| `statuts_facturation` | StatutFacture | `ordre_affichage`, `reserve_admin` | `reserve_admin` doit correspondre à `QueKadi`, absent de `legacy/referentiels.txt` : chargé à `false` partout, à corriger à l'étape 2 depuis la colonne source. |
| `sous_types_intervention` | SousType | — | = « nature technique ». |
| `natures_visite` | valeurs fixes | — | 1 Visite technique, 2 Visite filtres, 3 Visite maintenance générale (pas de source dump). |
| `pannes` | Panne | `famille text` | `famille` = préfixe du libellé avant le premier « - ». Codes 47..50 (NULL en source) ignorés. Code 41 (NULL en source) conservé, libellé forcé à « Non renseignée », `famille` forcée à `null`. |
| `modes_resolution` | ModeResolution | — | Historique, non référencé par un écran actuel. |
| `familles_gaz` | Liste_Type_Gaz | — | HCFC/HFC/HFO. `legacy/referentiels.txt` ne contient pas cette table : codes 1/2/3 attribués ici, à recaler sur `Liste_Type_Gaz.id` réel à l'étape 2. « HF0 » à corriger en « HFO » si rencontré en source. |
| `types_fluide` | TypeFluide | `gwp integer`, `famille_gaz_id` FK `familles_gaz` | `code`=`id` source, `gwp` = colonne `GWP` (reprise via le champ générique du dump referentiels.txt). `famille_gaz_id` déduit de la chimie connue du fluide (absente du dump), à vérifier à l'étape 2 contre `TypeFluide.Type`. |
| `marques` | Marque | — | Aucune donnée dans `legacy/referentiels.txt` : table vide, peuplée à l'étape 2 depuis `Marque` (nummar, nommar). |
| `references_materiel` | Reference | voir `supabase/migrations/20260915120001_referentiels.sql` | Catalogue (764 modèles en source). Table vide à l'étape 1 (pas de dump disponible). Mapping prévu : `id`→`legacy_id`, `Reference`→`reference`, `Repere`→`repere`, `Type`→`type_equipement`, `Nommar`→`marque_id` (FK résolue par libellé), `Fluide`→`fluide_id` (FK résolue par libellé, nullable), `TypeTel`→`type_telecommande`, `Reversible`→`reversible`, `Resistance`→`resistance`, `PuissanceFrigo`/`PuissanceCalo`→ `numeric` si convertible sinon `_brut text`, `QteGaz`→`quantite_gaz`, `NbFiltres`→`nombre_filtres`, `DimFiltres`→`dimension_filtres`, `NbCourroies`→`nombre_courroies`, `RefCourroies`→`reference_courroies`, `AppointRoof`→`appoint_roof`. |
| `reperes` | Repere | `controle_etancheite boolean` | `id`→`code`, `Repere`→`libelle`, `CtrlEtancheite`→`controle_etancheite`. Table vide à l'étape 1. |
| `types_telecommande` | TypeTel | — | `id`→`code`, `TypeTelecommande`→`libelle`. Table vide à l'étape 1. |
| `types_equipement` | TypeAudit | `famille smallint` | `famille` = chiffre avant le premier « - » du libellé (calculé en SQL via `split_part`). |
| `activites` | Activites | — | `Numactivite`→`code`, `Nomactivite`→`libelle`. 20 métiers. |
| `zones_geographiques` | ZoneGeographique | — | `numzon`→`code`, `nomzon`→`libelle` (référentiels.txt : `ZoneGeo`). |
| `societes` | Societe | `est_fmc boolean` | `numsoc`→`code`, `nomsoc`→`libelle`. `est_fmc=true` pour les codes 1, 111, 112, 113 (cf. brief étape 1). |
| `jours_feries` | JoursFeries | `date_jour date unique` | `datjoufer`→`date_jour`. Aucune donnée dans `legacy/referentiels.txt` : table vide, peuplée à l'étape 2. |
| `ecarts_visites` | VisitesMaint | `nombre_visites smallint unique` (tient lieu de clé), `ecart_jours integer`, `commentaire` | `Nombre_Visites`→`nombre_visites`, `Ecart_Permis_Jour`→`ecart_jours`, `Commentaire`→`commentaire`. Valeur/unité de `ecart_jours` à confirmer à l'étape 2 contre la colonne source (le dump `referentiels.txt` ne distingue pas explicitement `IndexLigne` de `Nombre_Visites`). |
| `types_evenement_vehicule` | ListeEVVehicule | — | Aucune donnée dans `legacy/referentiels.txt` : table vide, peuplée à l'étape 2. |
| `etats_vehicule` | ListeEtatVehicule | — | Code 4 = vendu. Aucune donnée dans `legacy/referentiels.txt` : table vide, peuplée à l'étape 2. |
| `statuts_devis` | valeurs fixes (StatutDevis) | — | 1 à viser, 2 visé/aucun retour, 3 annulé et remplacé, 4 envoyé, 5 refusé, 6 accepté. |

## Référentiels chargés directement depuis la source à l'étape 2

Ces tables étaient vides à l'étape 1 (absentes de `legacy/referentiels.txt`) ; l'étape 2 les
peuple directement depuis SQL Server (`scripts/migrate-legacy/mapping/*.mjs`), avant les
tables métier qui les référencent.

| Table cible | Source | Mapping |
|---|---|---|
| `marques` | Marque | `nummar`→`code`, `nommar`→`libelle`. |
| `reperes` | Repere | `id`→`code`, `Repere`→`libelle`, `CtrlEtancheite`→`controle_etancheite`. |
| `types_telecommande` | TypeTel | `id`→`code`, `TypeTelecommande`→`libelle`. |
| `jours_feries` | JoursFeries | `datjoufer`→`date_jour` (pas de `legacy_id` sur cette table, la date est la clé). |
| `types_evenement_vehicule` | ListeEVVehicule | `Numero`→`code`, `Evenement_Vehicule`→`libelle`. |
| `etats_vehicule` | ListeEtatVehicule | `Numero`→`code`, `EtatVehicule`→`libelle`. |
| `references_materiel` | Reference | mapping complet dans `supabase/migrations/20260915120001_referentiels.sql` ; `Nommar`/`Fluide` résolus par libellé vers `marques`/`types_fluide` (pas de FK déclarée en source). |

## Tiers

### `clients` ← `Client`
| Source | Cible | Remarque |
|---|---|---|
| numcli | legacy_id | |
| nomcli | nom | unique |
| adrcli | adresse | |
| codposcli | code_postal | |
| vilcli | ville | |
| telcli | telephone | |
| faxcli | fax | |
| concli | contact_principal | |
| melcli | email | |
| hormaxintcli | delai_intervention_heures | |
| logcli | *ignorée* | image, à migrer vers Storage plus tard |
| cheminpho | numero_esabora_maint | **détournée** |
| cheminpla | numero_esabora_clim | **détournée** |
| affcli | actif | |
| coutheuremainoeuvre | tarif_heure_mo | |
| coutdeplacement | tarif_deplacement | |
| — | est_client_fermeture | vrai pour le client legacy 368 « client fermé » |

### `donneurs_ordre` ← `Donneur`
| Source | Cible | Remarque |
|---|---|---|
| donneurid | legacy_id | |
| nomdonneur | nom | |
| adrdonneur/codposdonneur/vildonneur/teldonneur/faxdonneur/condonneur | adresse/code_postal/ville/telephone/fax/contact_principal | |
| meldonneur | pied_page_ligne_1 | **détournée** |
| cheminpho | pied_page_ligne_2, logo_chemin | **détournée**, double usage (logo + pied de page) |
| cheminpla | pied_page_ligne_3 | **détournée** |
| hormaxintdonneur | delai_intervention_heures | |
| logdonneur | *ignorée* | image |
| affdonneur | actif | |
| sairapdonneur | saisie_simplifiee_tablette | |

### `contacts` ← `Contact`
| Source | Cible |
|---|---|
| codcon | legacy_code (clé texte) |
| nomcon / precon / civcon | nom / prenom / civilite |
| numcli | client_id |
| numdonneur | donneur_ordre_id |
| adrmelcon | email |
| telcon / faxcon / mobcon | telephone / fax / mobile |
| obscon | observations |
| foncon | fonction |

### `intervenants` ← `Intervenant`
| Source | Cible |
|---|---|
| numintervenant | legacy_id |
| codint | code (unique, « FMC » = interne) |
| nomint | nom |
| numzonint (+ _2/_3/_4) | → table `intervenant_zones` (rang 1 à 4) |
| adrint/codposint/vilint/telint/faxint/adrmelint | adresse/code_postal/ville/telephone/fax/email |
| NomDirigeant_Interv / TelDirigeant_Interv / Mail_Dirigeant_Interv | dirigeant_nom / dirigeant_telephone / dirigeant_email |
| NomInterlocuteur_Interv / TelInterlocuteur_Interv | interlocuteur_nom / interlocuteur_telephone |
| Info_Interv | informations |
| Histo_FMC_Interv | historique_fmc |
| VillesInterventions_Interv | villes_codes_postaux |
| Activite_1..6 + MO_/Depl_/Date_ | → table `intervenant_activites` |
| Latitude_Interv / Longitude_Interv | latitude / longitude `numeric(9,6)` |
| PrecisionGeo_Interv | precision_geo |
| Rooftop_Interv | *ignorée* (cassé en source) |
| Provenance_Interv | provenance |
| ChargeAffaireFMC_Interv | interlocuteur_fmc_id (FK utilisateurs) |
| CreePar_Interv | cree_par_id (FK utilisateurs) |
| IndMaint/Ind_Depann/Ind_Travaux/Ind_React_Interv | note_maintenance/note_depannage/note_travaux/note_reactivite |
| DossierOrdi_Interv | dossier_chemin |
| TexteNeplusInterv | motif_ne_plus_intervenir |
| EstTech | est_technicien_interne |
| NePlusIntervenir | ne_plus_intervenir |
| Status_Prospect | est_prospect |
| Status_ST_FMC | est_sous_traitant |
| Status_ST_FMC_Ponctuel | est_sous_traitant_ponctuel |
| Status_Act_Poss_Maint/Depan/Travaux | peut_maintenance/peut_depannage/peut_travaux |
| Status_Act_Donn_Maint/Depan/Travaux | confie_maintenance/confie_depannage/confie_travaux |
| Zone_Nationale | zone_nationale |
| MailFacturation | email_facturation |
| SiteInternet | site_internet |
| ExistePlus | n_existe_plus |
| AutoLiquidation | autoliquidation |

### `utilisateurs` ← `Utilisateur`
| Source | Cible |
|---|---|
| numuti | legacy_id |
| nomuti / preuti | nom / prenom |
| loguti | login_legacy |
| mdputi | *ignorée* (mot de passe en clair, remplacé par Supabase Auth) |
| codintuti | code_intervenant (FK `intervenants.code`, gardé seulement s'il existe dans `intervenants.code`, sinon null) |
| typuti | profil (1 gestionnaire, 2 technicien, 3 gestionnaire_tech) |
| nomsocuti | societe_libelle_legacy |
| numsoc | societe_id |
| nummod | *ignorée* |
| Mail | email |
| KmARenseigner | km_a_renseigner |
| Immat | immatriculation |
| — | auth_user_id (posé à l'étape 3), role (nullable) |

## Sites

### `sites` ← `Site`
Voir `supabase/migrations/20260915120003_sites.sql` pour la liste complète des colonnes ;
mapping identique à celui du brief `docs/plan/etape-1.md` §Sites, notamment les colonnes
détournées :

| Source | Cible | Type |
|---|---|---|
| majregistresecuritefait | ne_plus_intervenir | **détournée** |
| misajoursecurite | retard_paiement | **détournée** |
| majregistresecuriteafaire | nacelle_necessaire | **détournée** |
| demixasit | particulier | **détournée** |
| aspirateur | arret_urgence_clim_oui | **détournée** |
| accessfiltre | arret_urgence_clim_non | **détournée** |

`datesignaturecontrat` et `numerocontratclient` ne sont pas repris dans `sites` : ils vont
dans `site_contrats` (lot clim). `nbrentsit` est conservé sur `sites.visites_entretien_par_an`
en plus de `site_contrats.visites_par_an` (donnée pivot de la planification, cf. brief).

### `site_contrats` (nouvelle table, un lot par ligne)
Un enregistrement par lot (`clim`, `chaudiere`, `desenfumage`) créé seulement si au moins une
colonne du lot est renseignée en source :
- **Clim** : numerocontratclient, datprisencharge, nbrentsit, mntredev (remplacé par
  montantredevancetechnique si non null), montantredevancefiltre, nombrevisitefiltre,
  nombrevisitetechnique (→ visites_secondaires si filtre null), NumSousTraitClim,
  TarifSousTraitClim, datesignaturecontrat.
- **Chaudière** : NumContratChaudiere, DateContratChaudiere, NombreContratChaudiere,
  mntredevContratChaudiere, NumSousTraitChaudiere, TarifSousTraitChaudiere.
- **Désenfumage** : numerocontratdesenfumage, datedesenfumage, nombrevisitedesenfumage,
  montantredevancedesenfumage, NumSousTraitDesenfum, TarifSousTraitDesenfum.

### `site_horaires` (nouvelle table)
`hor_lun_ouv`…`hor_dim_fer` (varchar « HH:MM », null si vide ou « 00:00 ») → une ligne par
jour (1 lundi … 7 dimanche), colonnes `ouverture`/`fermeture` en `time`.

### `site_materiels` ← `SiteMateriel`
Voir `supabase/migrations/20260915120003_sites.sql`. Colonnes détournées :

| Source | Cible |
|---|---|
| FluideQuantite | fluide_libelle **détournée** |
| NbreRadiateurs | charge_fluide_kg **détournée** (piège de migration connu) |
| NumeroInter | intervention_id (FK ajoutée après création de `interventions`) |

### `site_registre_securite` ← `SiteMAJRegistre`
`N°`→legacy_id, `cptsit`→site_id, `Date`→date_mise_a_jour.

## Interventions

### `interventions` ← `Intervention`
Mapping complet dans `supabase/migrations/20260915120004_interventions.sql` (commentaires SQL
sur chaque colonne détournée). Résumé des colonnes détournées :

| Source | Cible |
|---|---|
| nbrappint | statut_facturation_code |
| imprimeepar | sous_type_code |
| retourficheinterventionpar | minutes_telephone |
| devisepar | urgence_devis (1..3) |
| stadev | duplicata_traite_par_id |
| numpartenaire | priorite |
| numdevpartenaire | noms_techniciens |
| mnthtdevis | quantite_gaz_kg |
| nummodres | fluide_id (FK `types_fluide` par `code`) |
| nbrpagfax | heures_vendues |
| intafact | location_nacelle |
| numerocommande | horodatage_prediag |
| sigsit | prestations_realisees |
| sigtec | commentaire_cloture_panne |
| sigcli | chemin_facture_fmc |
| commajregsec | chemin_facture_sous_traitant |
| datesignaturecontrat | date_facturation |
| mnthtdevpartenaire | montant_ht_devis_accepte |
| numerocontratclient | numero_contrat_client |

Ignorées : `classeepar`, `duplicatacreepar`, `RV` (rowversion SQL Server, remplacé par
`updated_at`).

### `intervention_techniciens` ← `InterventionTechnicien`
`numintuti`→legacy_id, `numintint`→intervention_id, `numuti`→utilisateur_id. `numint` ignoré.

### `fiches_intervention` ← `FicheIntervention`
`numFicheInt`→legacy_id, `numIntInt`→intervention_id, `numBon`→numero_bon,
`dateFicheInt`→date_fiche, `heureDebut`/`heureFin`→heure_debut/heure_fin (extraction de
l'heure), `tempsAller`/`tempsRetour`→temps_aller_h/temps_retour_h, `remarques`. `ficheInt1..4`
ignorés.

### `heures_techniciens` ← `HeuresTech`
`Numero`→legacy_id, `NumeroTech`→utilisateur_id, `TypeInterv`→type_code (60 = relevé km,
garder le code brut), `NumInterv`→intervention_numero_bon (**clé = numéro de bon, pas
legacy_id**, à résoudre vers `interventions.id` à l'étape 2), `NomInterv`→libelle,
`DateInterv`→date_travail, `HeureDebut`/`HeureFin`, `HeureDebut_FMC`/`HeureFin_FMC`,
`InterdictionModif`→verrouille, `NumeroSite`→site_id, `DateSaisie`→date_saisie,
`NePasComptabiliser`→ne_pas_comptabiliser. `HeuresTechAuto` non migrée (cache plafonné).

## Devis et planification

### `devis` ← `Devis` ∪ `DevisTravaux` ∪ `ContratDeMaintenance`
`famille` ('sav'/'travaux'/'contrat') ajouté pour distinguer la table d'origine.
`legacy_id` = `NumeroDevis`, **pas unique seul** (les trois tables ont des identités qui se
chevauchent) : `unique (famille, legacy_id)`. Le reste du mapping (`NumeroDevisInterne`→numero,
`StatutDevis`→statut_code, etc.) suit `docs/plan/etape-1.md` §Devis, repris à l'identique dans
`supabase/migrations/20260915120005_devis_planification.sql`.

### `planifications` ← `Planification`
Une ligne par date : `numcli`→client_id, colonnes `T1`..`T12` éclatées en `rang` (1..12) +
`date_limite`, `nombrevisite`→nombre_visites, `recurrent`, `datefinrecurrence`→
date_fin_recurrence. `legacy_id` = `numeroplanification`, non unique seul :
`unique (legacy_id, rang)`.

## Véhicules

### `vehicules` ← `Vehicules`
Mapping direct, voir `supabase/migrations/20260915120006_vehicules.sql`. `Societe`→
societe_vehicule (0 FMC Clim, 1 FMC Maintenance, distinct de `societes.code`).

### `vehicule_evenements` ← `EvVehicules`
`NumEV`→legacy_id, `DateEv`→date_evenement, `Km`→km, `Conducteur`→conducteur_id,
`Immat`→immatriculation (+ `vehicule_id` résolu au transfert), `TypeEv`→type_code.

## Vues

- `v_interventions_liste` : équivalent de `ListeInterventionGenerale` (legacy/sql_modules.sql),
  colonnes renommées côté cible.
- `v_sites_liste` : équivalent de `ListeSite`.
- `v_tableau_de_bord` : compteurs de l'écran d'accueil (legacy/analysis/01_navigation_parametrage.md §2.1).

## Tables non migrées (rappel, cf. `docs/plan/README.md` §Périmètre)

`SiteMarqueReference*`, `PanneMaterielSite`, C16/C24/C33, `ClientRMA*`, `annuaire`,
`Plan`/`Plan1`/`Plans`, `planning*`, `parametre*`, `TopTen*`, `dtproperties`, `Demande_Web`,
`FiltreClimAccessMobile`, `HistoCnx`, `HeuresTechAuto`,
`Intervention_Status_Changed_history`, `SiteNombreEntretien`, `ClientCredential`,
`ClientUtilisateur`, module Audit (`Audit*`), ancien modèle `SiteMarqueReference*`,
répertoire technique (`ModeleRepertoireTechnique` & co).
