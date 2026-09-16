# Problèmes rencontrés : données, transfert, environnement

Journal exhaustif de ce qui « ne va pas » et qu'on a contourné pour que l'application fonctionne.
Chaque entrée dit : le constat, ce que fait la migration aujourd'hui, et ce qu'il faudrait faire
pour améliorer ensuite. **Rien ici n'est à traiter maintenant** : l'objectif de la phase actuelle est
que le transfert passe et que l'application tourne sur les vraies données.

Compléter ce fichier à chaque anomalie nouvelle (transfert, recette, production). Les chiffres
viennent de `scripts/migrate-legacy/last-run-report.md` (jamais commité) et des sorties console
du transfert réel du 16/09/2026.

## 1. Incohérences de données dans la base source (`logiclim`)

| # | Constat | Traitement actuel | À améliorer ensuite |
|---|---|---|---|
| D1 | Horaires d'ouverture impossibles saisis en texte libre, ex. `18:93` (`Site.hor_*_ouv/fer`, `varchar(5)`). Le transfert s'est arrêté sur `site_horaires`. | `parseHHMM` ignore toute heure > 23 ou minute > 59 → horaire vide. | Lister les sites concernés (requête `hor_%` non conforme à `^\d{1,2}:[0-5]\d$`) et corriger à la main dans l'application. |
| D2 | Sites orphelins : `Site.numcli` pointe vers un client absent de `Client`. **281 sites** (2e « client » du parc), ex. legacy_id 29204 « MASSY ». | Rattachés à un client sentinelle « Client inconnu (migration) » (`legacy_id = -1`), d'où `clients` = 2 324 lignes pour 2 323 en source. | **À vérifier en priorité** : 281 est élevé ; contrôler dans SQL Server si `numcli` est bien comparé au bon identifiant client, ou si ce sont des clients supprimés. Puis réaffecter ou archiver (`supprime_le`), et supprimer le client sentinelle. |
| D3 | Interventions orphelines : `Intervention.cptsit` sans site correspondant. **187 interventions** (ex. 331853, 333009…), entraînant 191 lignes `intervention_techniciens` et 2 liens matériel non repris. | Ignorées (`transform` → `null`), liste complète dans `last-run-report.md`. | Décider : recréer le site, ou accepter la perte (souvent des sites supprimés). |
| D4 | Codes de référentiel présents en données mais absents de `legacy/referentiels.txt` (statuts, types, pannes, statuts de facturation, sous-types…). | Créés automatiquement avec le libellé « Inconnu (code n) » (`lib/referentiels.mjs`), listés dans le rapport. | Donner un vrai libellé ou fusionner avec le bon code, depuis Paramétrage. |
| D5 | Intervenants sans zone (105 sur 193 : `intervenant_zones` = 88) et sans activité (8 sur 193). | Lignes non créées. | Vérifier si c'est normal (prospects, « n'existe plus ») ou une saisie manquante. |
| D6 | Sites sans contrat clim (3 682 sur 6 163 : `site_contrats` = 2 481). La règle ne crée un contrat que si numéro, date, visites ou redevance sont renseignés. | Aucune ligne `site_contrats` pour ces sites ; la planification les ignore. | Confirmer avec FMC quels sites sont réellement sous contrat. |
| D7 | Intervenants sans interlocuteur FMC ni créateur (84 sur 193 : `intervenants_fk_utilisateurs` = 109). | FK laissées vides. | Compléter depuis la fiche intervenant. |
| D8 | Dates stockées en texte (`Site.datcresit`, `SiteMateriel.DateMiseEnService`), formats variés. | Conservées brutes (`date_creation_site_brut`, `date_mise_en_service_brut`) et converties quand c'est possible. | Requête sur les valeurs brutes non converties, correction manuelle. |
| D9 | `Intervention.typint` en texte (code + libellé collés). | `parseCodeTexte` extrait le code ; le brut est gardé dans `type_brut`. | Vérifier les lignes où `type_code` est vide mais `type_brut` non. |
| D10 | Anciens statuts d'intervention 3, 4, 5, 6 encore portés par des lignes historiques. | Conservés dans `statuts_intervention` avec `actif = false`. | Aucune action, mais ne pas les réactiver. |
| D11 | Mots de passe en clair (`Utilisateur.mdputi`, `ClientCredential`). | Jamais migrés ; authentification Supabase Auth. | Inviter chaque utilisateur (`/parametrage/utilisateurs`). |
| D12 | Signatures et logos en base (base64, JSON, `image`). | Colonnes reprises telles quelles (`signature_*`), logos non migrés. | Déplacer vers Storage si le volume gêne. |
| D13 | Chemins de fichiers Windows (`\\serveur\...`) dans `chemin_bon_pdf`, `devis.fichier_chemin`, `dossier_chemin`. | Affichés tels quels, non cliquables. Script 6.8 prêt (`scripts/migrate-documents`). | Exécuter le script depuis un PC ayant accès au serveur de fichiers, traiter les introuvables. |
| D14 | Tables `Devis`, `DevisTravaux`, `ContratDeMaintenance` identiques ; colonnes répétées (`Planification.T1..T12`, `Intervenant.Activite_1..6`, `hor_lun..dim`). | Fusionnées / dépivotées à la migration (`devis.famille`, `planifications.rang`, `intervenant_activites.rang`, `site_horaires.jour`). | Rien, sauf si des données se cachaient dans des colonnes non mappées (voir `dictionnaire.md`). |
| D15 | Tables inexploitables ou abandonnées (`Intervention_Status_Changed_history` sans statut ni date, `HeuresTechAuto`, `TopTen*`, `*1` dupliquées, staging Excel…). | Non migrées (voir `docs/plan/README.md` § Périmètre). | Confirmer avec FMC qu'aucun besoin ne s'y rattache. |
| D17 | Dates de mise en service impossibles en texte, ex. `2012-16-05` (`SiteMateriel.DateMiseEnService`). Le transfert s'est arrêté sur `site_materiels`. | `parseLooseDateText` vérifie l'existence de la date ; sinon valeur gardée brute dans `date_mise_en_service_brut`. | Requête sur `date_mise_en_service_brut is not null` et correction manuelle sur la fiche matériel. |
| D18 | Montants d'intervention aberrants : total `montant_fmc` de **124,97 M€ en 2018** et **134,24 M€ en 2023** contre 2 à 11 M€ les autres années ; devis travaux statut 3 « annulé et remplacé » à 68,6 M€. Probablement quelques saisies avec des chiffres en trop. | Repris tels quels. Les bilans client et statistiques les incluront. | Requête `order by montant_fmc desc limit 20` par année, correction des lignes fautives. |
| D19 | Dates de réalisation impossibles : interventions réalisées en 1971, 2001, 2011, 2013 (sans montant), avant la création de l'activité. | Reprises telles quelles. | Lister `date_realisee < '2014-01-01'` et corriger ou vider. |
| D20 | Interventions sans statut (26) ou sans type (195) : `staint` vide ou `typint` non décodable. | `statut_code` / `type_code` vides, `type_brut` conservé ; invisibles dans les filtres par statut ou type. | Requête `statut_code is null or type_code is null`, requalification manuelle. |
| D16 | Référentiels véhicules incomplets dans le seed de l'étape 1 (`etats_vehicule` : 1 code, `types_evenement_vehicule` : 1 code) alors que l'application utilise les codes 0–5. | Complétés par le transfert depuis la source (8 et 5 codes). | Aligner le seed de l'étape 1 sur la source pour un environnement vierge. |

## 2. Problèmes techniques du transfert

| # | Constat | Correctif |
|---|---|---|
| T1 | `bind message has 11464 parameter formats but 0 parameters` sur `sites` : 1 000 lignes × ~100 colonnes dépassent la limite Postgres de 65 535 paramètres par requête. | Taille de lot bornée à 60 000 paramètres (`lib/db.mjs`, PR #31). |
| T2 | `date/time field value out of range: "18:93:00"` sur `site_horaires` (voir D1). | `parseHHMM` tolérant (PR #32). |
| T5 | `date/time field value out of range: "2012-16-05"` sur `site_materiels` (voir D17). | `parseLooseDateText` valide la date (PR #33). |
| T3 | En `--dry-run`, les tables dépendantes affichent `transformé=0` car les correspondances (`sites`, `intervenants`…) sont lues dans la cible encore vide. | Comportement attendu ; le dry-run ne valide que la lecture source et les référentiels. À améliorer : simuler les lookups depuis la source. |
| T6 | `planifications` : 166 lignes source → 477 cibles (« écart transform = -311 » dans le rapport). | Normal : dépivot des colonnes `T1..T12` en une ligne par rang. Le rapport devrait le présenter comme attendu et non comme un écart. |
| T4 | Étape 2 jamais exécutée avant le 16/09 : les sessions Claude Code n'ont accès ni à SQL Server ni aux données réelles. | Exécution sur le PC de l'utilisateur, guidée pas à pas. |

## 3. Environnement du poste utilisateur (Windows)

| # | Constat | Correctif |
|---|---|---|
| E1 | `git clone` : « checkout failed » à cause d'un fichier `legacy/extracted/queries/1;"µ««««";…".sql` (guillemets interdits sous Windows). | Renommé `expression_etoiles_1_a_5.sql` (PR #30). Vérifier à l'avenir les noms extraits d'Access. |
| E2 | Node.js absent ; `npm` bloqué par la politique d'exécution PowerShell (`npm.ps1 cannot be loaded`). | `winget install OpenJS.NodeJS.LTS`, puis `npm.cmd` ou `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`. À ajouter au README du script. |
| E4 | `Get-Content last-run-report.md` affiche les accents en « Ã© » : le rapport est en UTF-8, PowerShell 5 lit en cp1252 par défaut. | Affichage seulement ; utiliser `Get-Content -Encoding utf8 last-run-report.md` ou ouvrir le fichier dans VS Code. |
| E3 | Deux mots de passe distincts (SQL Server `sa`, Postgres Supabase) et deux chaînes de connexion : source de confusion. | README à compléter avec un tableau source / cible. Ne jamais coller les mots de passe dans une conversation. |

## 4. Application (à vérifier après transfert)

- Pages listes et tableau de bord sur 71 694 interventions : temps de réponse à mesurer, index à ajouter si besoin.
- Vues `v_interventions_liste`, `v_sites_liste` : vérifier les libellés pour les codes « Inconnu (code n) ».
- Cartes : sites sans latitude/longitude non affichés ; compter les sites non géocodés et lancer le géocodage depuis la fiche.
- Réglages restants : voir `docs/plan/etape-7.md` (Resend, cron, logos, paramètres, documents).

## 5. Résultat du transfert réel du 16/09/2026

Toutes les tables chargées, écarts source → cible limités aux orphelins (D2, D3). Volumes : 2 323 clients, 6 163 sites,
29 511 matériels, 71 507 interventions, 101 837 fiches, 102 637 lignes d'heures, 19 822 devis, 477 planifications,
38 véhicules. Second passage complet le même jour : compteurs identiques sur toutes les tables (idempotence vérifiée). Répartition des interventions : 64 236 clôturées (7), 2 606 à planifier (1), 3 012 annulées (8),
788 résolues par téléphone (10), 590 annulées en interne (20). Aucun code de référentiel inconnu signalé dans le rapport.

## À faire pour compléter ce journal

1. Noter toute anomalie vue en recette (écran, donnée absurde, libellé manquant) avec l'identifiant de la ligne.
