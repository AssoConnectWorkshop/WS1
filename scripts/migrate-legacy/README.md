# migrate-legacy

Transfert unique des données `logiclim` (SQL Server) vers le schéma Supabase créé à
l'étape 1. **Tourne uniquement sur le PC de l'utilisateur** : les données ne transitent
jamais par GitHub, ni par une session Claude Code distante.

## Prérequis

- Node 20+.
- SQL Server 2022 accessible (le conteneur Docker `sqlserver` du PC de l'utilisateur,
  base `logiclim`).
- Une chaîne de connexion Postgres **directe** vers Supabase (pooler en mode *session*,
  port 5432 — pas le pooler *transaction* 6543, qui ne supporte pas les transactions
  multi-requêtes utilisées ici). Le service role Supabase contourne RLS.

## Installation

```powershell
cd scripts\migrate-legacy
npm install
```

## Configuration

Créer `scripts/migrate-legacy/.env.local` (gitignoré, jamais commité) :

```
MSSQL_HOST=localhost
MSSQL_PORT=1433
MSSQL_USER=sa
MSSQL_PASSWORD=...           # mot de passe du conteneur SQL Server, jamais dans le repo
MSSQL_DB=logiclim
SUPABASE_DB_URL=postgresql://postgres:...@...supabase.co:5432/postgres
# Optionnel : MSSQL_URL=... (remplace MSSQL_HOST/USER/PASSWORD/DB si fourni)
# Optionnel : MIGRATE_BATCH_SIZE=1000
```

Les variables peuvent aussi être passées directement dans l'environnement (PowerShell :
`$env:MSSQL_PASSWORD = "..."`), auquel cas elles priment sur `.env.local`.

## Exécution

```powershell
cd scripts\migrate-legacy

# Simulation : aucune écriture, juste les compteurs par table.
node index.mjs --dry-run

# Transfert complet, dans l'ordre de dépendance du brief (docs/plan/etape-2.md).
node index.mjs

# Ne relancer qu'une ou plusieurs tables (utile après une correction de mapping) :
node index.mjs --tables=interventions
node index.mjs --tables=sites,site_contrats,site_horaires

# Combinable avec --dry-run.
node index.mjs --tables=devis --dry-run
```

Le script est **idempotent** : chaque table est chargée avec
`insert ... on conflict (...) do update`, sur la clé `legacy_id` (ou la clé métier
documentée dans `docs/plan/dictionnaire.md` pour les tables qui n'en ont pas, ex.
`(famille, legacy_id)` pour `devis`). Relancer une table ou tout le script plusieurs
fois de suite donne le même résultat.

Un rapport `scripts/migrate-legacy/last-run-report.md` (gitignoré) est produit à
chaque exécution non `--dry-run` : compteurs par table, codes de référentiel
découverts et ajoutés, lignes orphelines signalées, répartitions et sommes de
contrôle, échantillon de 20 sites.

## Structure

- `index.mjs` : orchestrateur (ordre de dépendance, `--tables`, `--dry-run`).
- `config.mjs` : lecture de `.env.local` / variables d'environnement.
- `lib/db.mjs` : connexions SQL Server / Postgres, upsert par lots, résolution de FK par
  `legacy_id` (ou autre clé), mise à jour ciblée (`update-pass`).
- `lib/dates.mjs` : conversions de dates/heures (fuseau Europe/Paris, dates texte
  `dd/MM/yyyy`, sentinelles Access).
- `lib/transform.mjs` : conversions génériques (trim, booléens, nombres, `typint` texte
  → entier...).
- `lib/referentiels.mjs` : complète un référentiel avec les codes rencontrés en données
  mais absents (créés avec libellé « Inconnu (code n) »).
- `mapping/*.mjs` : un module par table cible, `{ target, conflictColumns, source,
  lookups, transform(row, ctx) }`. Certains modules ont un rôle particulier :
  - `transform` peut retourner un objet, un tableau d'objets (ex. `site_horaires` : une
    ligne source → jusqu'à 7 lignes cible), ou `null`/`undefined` pour ignorer la ligne.
  - `sources` (tableau `{ famille, sql }`) remplace `source` pour `devis`, qui fusionne
    trois tables source.
  - `kind: 'update-pass'` (avec `keyColumn` et `updateColumns`) pose des colonnes sur des
    lignes déjà insérées par un autre module — utilisé pour les deux dépendances
    circulaires du schéma : `intervenants.interlocuteur_fmc_id`/`cree_par_id` (vers
    `utilisateurs`, chargée après) et `site_materiels.intervention_id` (vers
    `interventions`, chargée après).
  - `before(pgPool, rows, ctx)` (optionnel) s'exécute avant la transformation, par
    exemple pour compléter les référentiels ou créer une ligne sentinelle (client
    « inconnu » pour les sites orphelins).
- `report.mjs` : écrit `last-run-report.md`.

Le mapping de chaque module suit **exactement** `docs/plan/dictionnaire.md` : toute
correction de règle de transformation doit être répercutée dans les deux.

## Pourquoi pas de `setval` de séquence

Contrairement à d'autres approches de migration, les `id` cibles ne reprennent jamais
les identifiants source (colonnes `generated always as identity` : PostgreSQL refuse
même une insertion explicite dessus). Le lien avec la source passe uniquement par
`legacy_id`. Il n'y a donc aucun risque de collision de séquence à corriger après coup.

## Dépannage

- `ERREUR : variable d'environnement ... manquante` : compléter `.env.local`.
- Erreur de connexion SQL Server : vérifier que le conteneur Docker tourne
  (`docker ps`) et que le mot de passe est correct. Le script se connecte avec
  `trustServerCertificate: true`.
- Erreur de connexion Supabase : vérifier que `SUPABASE_DB_URL` utilise bien le pooler
  en mode *session* (port 5432), et que l'IP est autorisée si des règles réseau sont
  actives côté Supabase.
- Violation de clé étrangère : signale un cas non couvert par les règles de
  `docs/plan/dictionnaire.md` (donnée orpheline plus profonde que prévu) — regarder la
  ligne fautive avant d'ajuster le mapping, jamais désactiver la contrainte.
