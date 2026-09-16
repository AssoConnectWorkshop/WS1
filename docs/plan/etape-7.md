# Étape 7 — Mise en service : données réelles, e-mails, documents

## Objectif

Passer de l'application déployée à vide à l'application utilisée par FMC. Tout le code des
étapes 1 à 6 est en production ; cette étape ne contient que des opérations à faire **par l'utilisateur** (ou
avec lui, sur son PC), car elles demandent des accès que la session Claude Code n'a pas : SQL Server Docker,
serveur de fichiers `\\serveur\...`, compte Resend, réglages Vercel et Supabase.

Chaque point est indépendant : les faire dans l'ordre indiqué, mais l'application reste utilisable entre deux.
Tout problème rencontré (donnée incohérente, erreur de transfert, poste utilisateur) est consigné dans
`docs/problemes-donnees.md`, à compléter au fil de l'eau.

## 7.1 Transfert des données réelles (étape 2, jamais exécutée)

- Prérequis : SQL Server `logiclim` dans le conteneur Docker `sqlserver` du PC de l'utilisateur, et la chaîne
  Postgres **directe** de Supabase (Settings → Database → Connection string, mode *session*, port 5432).
- Suivre `scripts/migrate-legacy/README.md` : `npm install`, `.env.local`, `node index.mjs --dry-run`, puis
  `node index.mjs`, puis relancer une seconde fois et comparer `last-run-report.md`.
- Contrôles d'acceptation chiffrés : voir `docs/plan/etape-2.md` (écarts par table, sommes des montants par
  année, 5 sites et 5 interventions connus).
- Après le transfert, rattacher les personnes réelles à leur compte : `/parametrage/utilisateurs` (invitation)
  puis renseigner `code_intervenant` si la personne est technicien.

## 7.2 E-mails (Resend)

- Créer un compte sur resend.com, vérifier le domaine expéditeur (enregistrements DNS fournis par Resend),
  créer une clé API.
- Vercel → projet ws-1 → Settings → Environment Variables (Production) :
  - `RESEND_API_KEY` : la clé.
  - `EMAIL_FROM` : `ClimAccess <no-reply@<domaine vérifié>>`.
- Redéployer (Deployments → ⋯ → Redeploy). Sans ces variables l'envoi est **simulé** et journalisé dans
  `journal_emails`, ce qui suffit pour tester les écrans.
- Test : fiche intervention → e-mail « fin d'intervention » vers une adresse de test → réception + ligne
  `journal_emails.statut = 'envoye'`.

## 7.3 Relances SAV automatiques (cron Vercel)

- Vercel → Environment Variables : `CRON_SECRET` = chaîne aléatoire longue (`openssl rand -hex 32`). Vercel
  l'envoie lui-même au cron horaire `/api/cron/relances` (`vercel.json`). Sans elle, la route répond 401 et ne
  fait rien.
- Paramétrage → Paramètres → `email_sav` : adresse qui reçoit les relances.
- Test : cocher « rappel 24 h » sur une intervention « À planifier » créée il y a plus de 24 h, attendre le
  passage horaire, vérifier `journal_emails` et `interventions.date_dernier_rappel`.

## 7.4 Paramètres d'application et logos

- Paramétrage → Paramètres : `operateur_siret`, `operateur_attestation` (n° d'attestation de capacité fluides),
  vérifier `operateur_nom`, `operateur_adresse`, `detecteur_fuites`.
- Supabase → Storage → bucket `logos` : `fmc.png` (logo par défaut des bons), et par donneur d'ordre
  `donneur-<id>.png` (l'id est celui de l'URL `/donneurs-ordre/<id>`). Sans logo, le PDF est généré sans image.

## 7.5 Documents existants vers Storage (étape 6.8)

- Nécessite un PC qui voit le serveur de fichiers (`\\serveur\...`) référencé par `interventions.chemin_bon_pdf`
  et `devis.fichier_chemin`.
- `scripts/migrate-documents/` : `npm install`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, puis
  `npm start -- --dry-run --limit=50`, lecture de `last-run-report.md`, puis `npm start`.
- En attendant, les anciens chemins sont affichés tels quels dans les fiches (non cliquables) ; les nouveaux
  PDF générés par l'application sont déjà archivés dans Storage.

## 7.6 Après mise en service

- Inviter les utilisateurs FMC depuis `/parametrage/utilisateurs`, retirer le compte de test.
- Vérifier que les référentiels véhicules (`etats_vehicule`, `types_evenement_vehicule`) contiennent bien les
  codes utilisés par l'application (voir `src/lib/vehicules.ts`) ; l'étape 2 les complète depuis la source.
- Question ouverte : décommissionnement de SQL Server et coexistence avec la tablette / le portail, voir
  `docs/hors-perimetre-tablette-portail.md`.

## Critères d'acceptation

- Transfert étape 2 exécuté deux fois avec un rapport identique ; 5 sites et 5 interventions vérifiés.
- Un e-mail réel reçu depuis la fiche intervention ; une relance SAV reçue sur l'adresse SAV.
- Un bon PDF avec logo et un certificat d'étanchéité avec SIRET et n° d'attestation.
- Rapport du script 6.8 lu : fichiers introuvables traités ou acceptés.

## État

- [x] Brief rédigé.
- [x] 7.1 Transfert réel exécuté le 16/09/2026 (deux passages identiques). Premier administrateur créé à la main (Authentication → Users + insertion `utilisateurs`).
- [ ] 7.2 à 7.6 : à faire par l'utilisateur (accès requis absents de la session : SQL Server Docker, serveur de
  fichiers, Resend, Vercel, Supabase). Cocher au fil de l'eau.
