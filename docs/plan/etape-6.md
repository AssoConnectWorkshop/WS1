# Étape 6 — Compléments : documents, automatismes, exports, carte, véhicules

## Objectif

Parité fonctionnelle avec Access pour le bureau. Après cette étape, SQL Server n'est plus nécessaire
au bureau (la tablette et le portail restent hors périmètre, voir `docs/hors-perimetre-tablette-portail.md`).

## 6.1 PDF du rapport d'intervention (analysis 02 §9)
- Route `/interventions/[id]/bon.pdf`, génération serveur (`@react-pdf/renderer` ou `pdf-lib`).
- Contenu : logo FMC (ou logo du donneur d'ordre s'il a une image dans Storage `logos`), « Fiche d'intervention N° » (legacy_id ou id), N° site et code, date, client, site, adresse, temps de trajet (aller, retour, total), temps sur site (arrivée, départ, durée) sauf si `masquer_heures_sur_bon`, nombre de techniciens, registre de sécurité oui/non, prestations effectuées, à prévoir / reste à faire, commentaire, type, cachet et signature client (nom, image), noms et signatures techniciens.
- Bouton « Générer le PDF » : enregistre dans Storage `bons/<annee>/<id>.pdf`, renseigne `chemin_bon_pdf` (URL Storage), autorise le passage au statut 7.

## 6.2 Certificat d'étanchéité Cerfa (analysis 03 §3.6, 01 §5.2)
- Éligibilité : `site_materiels` du site avec `certificat_etancheite_edite = false` et `date_controle_etancheite` dans l'année.
- Pré-contrôles bloquants avec les messages Access : fluide connu et de famille HCFC/HFC/HFO, `charge_fluide_kg > 0`, `gwp > 0`, marque, numéro de série, référence renseignés.
- Calcul : t.éq.CO2 = kg × GWP / 1000 ; cases par seuils : HCFC kg < 30 / < 300 / ≥ 300 ; HFC tCO2e < 50 / < 500 / ≥ 500 ; HFO kg < 10 / < 100 / ≥ 100 ; « détection permanente » si `sites.detection_fuite_permanente`.
- Un PDF par équipement, Storage `certificats/<annee>/<intervention>-<materiel>.pdf`, puis `certificat_etancheite_edite = true`. Fond du Cerfa : à fournir par l'utilisateur (image), sinon mise en page équivalente.
- Opérateur : FMC Maintenance, 2 rue Galilée, 33185 Le Haillan ; SIRET et n° d'attestation à mettre en paramètre (`parametres_application`).

## 6.3 Relances SAV automatiques (analysis 01 §5.3)
- Vercel Cron toutes les heures, route `/api/cron/relances` protégée par `CRON_SECRET`.
- Pour chaque intervention statut 1 avec une case rappel cochée : si `now - date_dernier_rappel` (ou création si null) dépasse 24 h / 48 h / 72 h / 168 h selon la case → envoi d'un e-mail à l'adresse SAV paramétrée (`parametres_application.email_sav`) via Resend (clé `RESEND_API_KEY`, serveur), objet « Rappel Intervention <site> », corps site, N° DI client, date de demande ; `date_dernier_rappel = now()`.
- Journal des envois dans `journal_emails`.

## 6.4 E-mails manuels
- Depuis la fiche intervention : « Mail au partenaire » (intervenant.email), « Mail au contact » (contact.email), « Mail de fin d'intervention » (client.email) : ouverture d'un formulaire pré-rempli avec les textes Access, envoi via Resend, journalisé.

## 6.5 Exports Excel (analysis 04 §3, §4)
- `exceljs`, génération serveur, téléchargement.
- **Bilan client** (export « Fabien ») : mêmes 28 colonnes et mêmes règles (période sur date réalisée pour les interventions, sur date d'envoi pour les devis ; statuts 8 et 10 exclus ; heures × nombre de techniciens ; coût théorique = déplacements × tarif + heures × tarif). Corriger le compteur de devis refusés.
- **Comptage et montants par site** (export « Pierre ») : filtres type, statut, sous-type, période sur date limite ; option par mois ; option par motif de nom de site (4 textes).
- **Export du parc matériel** d'un client (colonnes de `site_materiels`).
- **Export de la liste d'interventions** courante (colonnes affichées).
- Pas de modèle réseau : fichiers générés de zéro avec en-têtes.

## 6.6 Carte (analysis 03 §5)
- `/carte` : Leaflet (`react-leaflet`, tuiles OpenStreetMap), une épingle par intervention avec géolocalisation du site, couleur par type (1 bleu, 2 vert, 3 rouge, 5 cône orange, 7 jaune, 9 noir, autres marron), cercle orange 500 m si date limite dépassée, info-bulle (type, client, site, adresse, date demande, date limite, dernière visite, technicien prévu, date prévue, commentaires). Filtres : clients, types, statuts, période, donneur, intervenants, zones.

## 6.7 Parc automobile (analysis 04 §5)
- `/vehicules` : liste, fiche éditable, événements (relevé km, révision, CT, contrôle complémentaire) avec règle « km ≥ dernier relevé », case « afficher les vendus » (état 4).
- Alertes sur le tableau de bord : CT > 24 mois, contrôle complémentaire > 12 mois depuis le plus récent CT/CC, révision (km entre révisions dépassés ou mois), leasing (date de fin ou mois), garantie (mois) ; véhicules d'état 4 et 5 exclus.

## 6.8 Documents vers Storage (si accès au serveur de fichiers)
- Script `scripts/migrate-documents/` sur le PC de l'utilisateur : parcourt les chemins `\\serveur\...` référencés (`chemin_bon_pdf`, `devis.fichier_chemin`, `sites.dossier_chemin`), copie dans Storage, remplace le chemin par l'URL. Rapport des fichiers introuvables.

## Critères d'acceptation

- Un bon PDF et un Cerfa comparés à leurs équivalents Access : mêmes informations.
- Une relance de test reçue sur l'adresse SAV de test.
- Bilan client d'une période comparé à l'export Access : mêmes totaux (hors correction du compteur de refus).
- Build vert, push sur `main` fonctionnalité par fonctionnalité.

## État

- [x] Buckets Storage privés `bons`, `certificats`, `logos` (migration, lecture/écriture par le serveur).
- [x] 6.1 Rapport d'intervention PDF (`pdf-lib`) : rendu à la volée sur `/interventions/[id]/bon.pdf` (authentifié) et « Générer et archiver le PDF » → `bons/<année>/<id>.pdf`, `chemin_bon_pdf` renseigné (prérequis du statut 7). Contenu de l'état Access : logo (Storage `logos/donneur-<id>` ou `logos/fmc`, sinon coordonnées FMC en texte), n° de fiche, n° site et code, date, client, site, adresse, temps de trajet et temps sur site (masqués si `masquer_heures_sur_bon`), nombre de techniciens, registre de sécurité, prestations, à prévoir / reste à faire, commentaire, type, signature client (nom, image si URL), techniciens (noms, image si URL), mention obligatoire. Nom de fichier proposé « jj.mm.aaaa (Selon <devis ou DI>) ».
- [x] 6.2 Certificat d'étanchéité : éligibilité (`certificat_etancheite_edite = false`, contrôle daté de l'année), pré-contrôles bloquants avec les messages Access (fluide connu de famille HCFC/HFC/HFO, charge > 0, GWP > 0, marque / référence / n° de série), t.éq.CO2 = kg × GWP / 1000, cases par seuils, détection permanente selon le site ; aperçu `/materiels/[id]/certificat.pdf`, « Éditer les certificats d'étanchéité (n) » sur la fiche site → Storage `certificats/<année>/<intervention>-<materiel>.pdf` puis `certificat_etancheite_edite = true`, compte rendu des échecs. Opérateur, SIRET, n° d'attestation et détecteur dans `parametres_application` (paramétrage). Mise en page équivalente au Cerfa : le fond image n'est pas superposé (coordonnées du formulaire officiel non disponibles).
- [x] Tables `parametres_application` (éditable au paramétrage) et `journal_emails`.
- [x] 6.3 Relances SAV : Vercel Cron horaire (`vercel.json`) sur `/api/cron/relances` (`Authorization: Bearer CRON_SECRET`) ; interventions statut 1 avec une case rappel cochée dont le dernier rappel (ou la création) dépasse 24 h / 48 h / 72 h / 168 h → e-mail à `parametres_application.email_sav` (« Rappel Intervention <site> » : site, n° DI client, date de demande), `date_dernier_rappel = now()`, journal `journal_emails`. Variables Vercel à renseigner : `RESEND_API_KEY`, `EMAIL_FROM` (domaine vérifié chez Resend), `CRON_SECRET` ; sans clé Resend, les envois sont simulés et journalisés.
- [x] 6.4 E-mails manuels depuis la fiche intervention (`/interventions/[id]/email?type=`) : partenaire (intervenant), contact client, fin d'intervention (client), formulaire pré-rempli avec les textes Access, modifiable, envoi Resend en texte brut, journalisé.
- [x] 6.5 Exports Excel (`exceljs`, générés de zéro avec en-têtes, onglet « Exports Excel » de la fiche client) : bilan client 28 colonnes (`/clients/[id]/bilan.xlsx`, période sur date réalisée pour les interventions et date d'envoi pour les devis, statuts 8 et 10 exclus, heures × techniciens, coût théorique, compteur de devis refusés corrigé) ; comptage et montants par site (`comptage.xlsx`, période sur date limite, année prioritaire, une feuille par mois, filtres types / statuts / natures, motifs de nom de site sommés) ; parc matériel (`materiel.xlsx`, colonnes de `site_materiels`, sites sans matériel inclus) ; liste d'interventions courante (`/interventions/liste.xlsx`, mêmes filtres et colonnes que l'écran). Simplification : le dégroupage en colonnes par statut / type / nature de l'export Access n'est pas repris (filtres équivalents).
- [x] 6.6 Carte (`/carte`, `react-leaflet` + tuiles OpenStreetMap) : une épingle par intervention géolocalisée (coordonnées du site), couleur par type (1 bleu, 2 vert, 3 rouge, 5 orange, 7 jaune, 9 noir, autres marron, statut -1 jaune), cercle orange 500 m si la date limite est dépassée, info-bulle (type, statut, client, site, adresse, dates de demande / limite / prévue / réalisée, intervenant, chargé d'affaire, commentaire, lien vers la fiche) ; filtres client, types, statuts, donneur, intervenants, zones, période sur la date limite, clôturées incluses ou non ; limite 3 000 points.
- [x] 6.7 Parc automobile (`/vehicules`) : liste avec alertes, case « afficher les vendus » (état 4), fiche éditable, événements (relevé km, révision, CT, contrôle complémentaire) avec la règle « km ≥ dernier relevé », suppression ; alertes sur le tableau de bord (CT > 24 mois, contrôle complémentaire > 12 mois depuis le plus récent CT / CC, révision par km ou mois, leasing par date de fin ou mois, garantie par mois ; états 4 et 5 exclus). Navigation : Carte, Véhicules, Planification et Paramétrage ajoutés au menu.
- [ ] 6.8 Documents vers Storage : script à exécuter sur le PC de l'utilisateur (accès au serveur de fichiers requis), à faire.
