# Plan de migration ClimAccess → Next.js + Supabase

Ce dossier contient les briefs de mission, un par étape. Chaque brief est autonome : une session
Claude Code vierge doit pouvoir l'exécuter sans relire l'historique.

## Comment démarrer une étape

Dans une nouvelle session Claude Code, prompt :

> Lis `docs/plan/README.md` puis `docs/plan/etape-N.md` et exécute l'étape N. Respecte `CLAUDE.md`.

## Lecture préalable obligatoire (10 minutes)

1. `CLAUDE.md` : conventions du repo, workflow (commit → push sur `main` = production Vercel).
2. `legacy/SCHEMA_ANALYSIS.md` : schéma SQL Server source et problèmes de qualité.
3. `legacy/schema.sql` : DDL exact des 78 tables sources. **C'est la référence pour les types.**
4. `legacy/referentiels.txt` : libellés officiels des statuts, types, pannes, fluides, sociétés, zones.
5. `legacy/analysis/*.md` : règles métier lues dans le VBA, par domaine. Lire le fichier du domaine
   concerné avant de coder un écran.
6. Le compte rendu métier complet est dans Notion : FMC → « Application existante ». Le plan validé :
   FMC → « Plan de migration ClimAccess → Vercel + Supabase ».

## Périmètre

- Inclus : tout ce que fait l'application Access (bureau FMC).
- Reporté : application tablette et portail web (`docs/hors-perimetre-tablette-portail.md`).
- Abandonné : ancien menu Clim'Tech et ses états, module Audit, ancien modèle de matériel
  (`SiteMarqueReference*`, `PanneMaterielSite`), tables de staging Excel, tables `*1` dupliquées,
  `TopTen*`, `HeuresTechAuto`, `Intervention_Status_Changed_history`, `Demande_Web`,
  `FiltreClimAccessMobile`, `ClientCredential`, `ClientUtilisateur`, `HistoCnx`, `dtproperties`,
  `Photo`, `Plan`, `Plans`, `SiteNombreEntretien`, `annuaire`, `parametre*`, `planning*`.

## Règles transverses

- Noms `snake_case`, français, explicites. Jamais de nom d'origine détourné (voir dictionnaire
  dans `etape-1.md`).
- Chaque table migrée a `legacy_id` (identifiant source, unique), `created_at`, `updated_at`.
- Identifiants : `id bigint generated always as identity primary key`.
- Aucune donnée réelle dans le repo. Les scripts de transfert tournent sur le PC de l'utilisateur.
- Anciens codes de statut (3, 4, 5, 6) conservés dans les référentiels avec un flag `actif = false`.
- Une étape = une PR mergée ou une série de commits sur `main`, `npm run build` vert avant chaque push.
- Fin d'étape : mettre à jour la section « État » en bas du brief, et dire à l'utilisateur quoi tester.

## Étapes

| Étape | Fichier | Taille | Modèle conseillé |
|---|---|---|---|
| 1 Schéma Supabase | `etape-1.md` | M | Sonnet |
| 2 Transfert des données | `etape-2.md` | L | Sonnet |
| 3 Connexion et rôles | `etape-3.md` | S | Sonnet |
| 4 Écrans de consultation | `etape-4.md` | L | Sonnet |
| 5 Écrans de saisie | `etape-5.md` | L | Opus, ou Sonnet avec validation écran par écran |
| 6 Compléments | `etape-6.md` | M | Opus, ou Sonnet avec validation |
| 7 Mise en service (données réelles, e-mails, documents) | `etape-7.md` | S | Utilisateur, sur son PC |
