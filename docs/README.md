# Documentation du projet ClimAccess → Next.js + Supabase

Tout ce qu'une session de travail (humain ou Claude Code) doit savoir est ici. Rien d'indispensable
n'est ailleurs. La page Notion « FMC → Application existante » est une copie de `CONTEXTE.md`.

## Ordre de lecture

1. `docs/CONTEXTE.md` — ce que fait l'application actuelle et comment elle fonctionne (20 min).
2. `docs/plan/README.md` — périmètre, règles transverses, liste des étapes (5 min).
3. `docs/plan/etape-N.md` — le brief de l'étape à réaliser.
4. `legacy/analysis/0X_*.md` — les règles métier détaillées du domaine concerné, au moment de coder.
5. `legacy/schema.sql` et `legacy/referentiels.txt` — la vérité sur les types et les codes.

## Carte des fichiers

| Chemin | Contenu | Quand le lire |
|---|---|---|
| `CLAUDE.md` | Conventions du repo et workflow | toujours |
| `docs/CONTEXTE.md` | Rapport fonctionnel complet de l'application Access | au début de toute session |
| `docs/plan/README.md` | Plan de migration : périmètre, règles, étapes | au début de toute session |
| `docs/plan/etape-1..8.md` | Briefs de mission par étape | pour l'étape en cours |
| `docs/plan/dictionnaire.md` | Correspondance colonne source → colonne cible (produit par l'étape 1) | étapes 2 à 6 |
| `docs/hors-perimetre-tablette-portail.md` | Ce qu'on sait des deux autres applications | si la question se pose |
| `docs/problemes-donnees.md` | Journal des incohérences de données, problèmes de transfert et d'environnement rencontrés, avec leur contournement | étape 7 et toute amélioration ultérieure |
| `legacy/SCHEMA_ANALYSIS.md` | Analyse du schéma SQL Server, relations implicites, problèmes de qualité | étapes 1 et 2 |
| `legacy/ANALYSIS.md` | Analyse du fichier Access (objets, requêtes) | rarement |
| `legacy/schema.sql` | DDL exact des 78 tables SQL Server | étapes 1 et 2 |
| `legacy/referentiels.txt` | Valeurs officielles des tables de référence | étape 1 et pour tout libellé |
| `legacy/rowcounts.csv`, `foreign_keys.csv` | Volumes et clés étrangères déclarées | étape 2 |
| `legacy/sql_modules.sql` | Vues, procédures et déclencheurs SQL Server | étapes 1 et 4 |
| `legacy/analysis/01_navigation_parametrage.md` | Démarrage, menus, compteurs, paramétrage, imports, utilitaires | étapes 4 et 5 |
| `legacy/analysis/02_interventions.md` | Cycle de vie complet d'une intervention, colonnes recyclées, listes, états | étapes 4, 5, 6 |
| `legacy/analysis/03_clients_sites_materiel_intervenants.md` | Clients, sites, matériel, contrôle d'étanchéité, intervenants, cartes | étapes 4, 5, 6 |
| `legacy/analysis/04_devis_planification_statistiques.md` | Devis, planification, statistiques, exports, parc auto | étapes 4, 5, 6 |
| `legacy/extracted/vba/*.vba` | Code VBA d'origine (mots de passe masqués) | en cas de doute sur une règle |
| `legacy/extracted/forms/*.txt` | Libellés et contrôles des écrans Access | pour reproduire un écran |
| `legacy/extracted/vba_msgbox.txt` | Messages utilisateur d'origine | pour les messages d'erreur |
| `legacy/extracted/queries/*.sql` | Requêtes Access (jointures perdues) | rarement |

## Itérations

Le projet sera construit en plusieurs tentatives. Règles :

- Les directives (`docs/`, `legacy/`, `CLAUDE.md`) vivent sur `main` et ne sont modifiées que pour
  corriger ou préciser. Toute leçon apprise pendant une tentative est reportée dans le brief concerné
  (section « Leçons des tentatives précédentes » à créer si besoin).
- Chaque tentative de code se fait sur une branche `tentative-N` créée depuis `main`, avec son propre
  projet Supabase (ou un schéma dédié) pour pouvoir repartir de zéro. La tentative retenue est
  fusionnée dans `main`.
- Une session = une étape. Le brief est mis à jour (section « État ») à la fin.
- Prompt de démarrage d'une session :

```
Lis docs/README.md, puis docs/CONTEXTE.md, puis docs/plan/README.md, puis docs/plan/etape-N.md.
Exécute l'étape N sur la branche tentative-M. Respecte CLAUDE.md.
```
