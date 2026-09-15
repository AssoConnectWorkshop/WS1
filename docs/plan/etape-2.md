# Étape 2 — Transfert des données SQL Server → Supabase

## Objectif

Charger toutes les données de `logiclim` dans le schéma de l'étape 1, depuis le PC de l'utilisateur,
sans que les données transitent par GitHub. Rejouable. Rapport de contrôle.

## Contexte utilisateur

- SQL Server 2022 tourne dans Docker sur le PC de l'utilisateur : conteneur `sqlserver`, port 1433,
  base `logiclim`, login `sa`. Le mot de passe est fourni par l'utilisateur au moment de lancer
  (variable d'environnement, jamais dans le repo).
- Supabase : chaîne de connexion Postgres directe (pooler en mode session, port 5432) fournie par
  l'utilisateur en variable d'environnement `SUPABASE_DB_URL`. Le service role contourne RLS.
- Node 20+ sur le PC de l'utilisateur. Windows : commandes PowerShell.

## Livrables

1. `scripts/migrate-legacy/` : projet Node autonome (`package.json` propre, dépendances `mssql`, `pg`,
   `pg-copy-streams` ou insertion par lots de 1 000 lignes en `insert ... on conflict (legacy_id) do update`).
   - `index.mjs` : orchestrateur, option `--tables=a,b` et `--dry-run`.
   - `config.mjs` : lit `MSSQL_URL` (ou `MSSQL_HOST/USER/PASSWORD/DB`) et `SUPABASE_DB_URL` depuis `.env.local` (fichier gitignoré) ou l'environnement.
   - `mapping/*.mjs` : un module par table cible, exportant `{ source: sql, target, transform(row) }`. Le mapping suit **exactement** `docs/plan/dictionnaire.md`.
   - `lib/` : conversions communes (dates texte, heures `varchar(5)`, trim, booléens, `typint` texte → entier).
   - `report.mjs` : produit `scripts/migrate-legacy/last-run-report.md` (gitignoré) et affiche le résumé.
2. `scripts/migrate-legacy/README.md` : prérequis, variables, commande en une ligne, comment relancer une seule table.
3. `.gitignore` : `.env.local`, `last-run-report.md`.
4. Ajout à `docs/plan/dictionnaire.md` d'une colonne « règle de transformation » si absente.

## Ordre de chargement

1. Référentiels déjà chargés par l'étape 1 : vérifier la présence, compléter les codes manquants rencontrés dans les données (ex. un `staint` inconnu) en les créant avec `actif=false` et libellé « Inconnu (code n) », et le signaler dans le rapport.
2. `clients`, `donneurs_ordre`, `zones_geographiques` (déjà), `societes` (déjà).
3. `intervenants`, puis `intervenant_zones`, `intervenant_activites`.
4. `utilisateurs`.
5. `contacts`.
6. `sites`, puis `site_contrats`, `site_horaires`, `site_registre_securite`, `site_materiels` (sans `intervention_id`).
7. `interventions`.
8. Seconde passe : `site_materiels.intervention_id` (NumeroInter → legacy_id), `intervention_techniciens`, `fiches_intervention`, `heures_techniciens`.
9. `devis` (trois sources), `planifications`.
10. `vehicules`, `vehicule_evenements`.
11. Mise à jour des séquences (`setval`) pour que les nouveaux `id` ne collisionnent pas ; **les `id` cibles ne reprennent pas les identifiants sources**, les liens passent par `legacy_id`.

## Règles de transformation

- `trim` de tous les textes ; chaîne vide → `null`.
- `datetime` : timezone `Europe/Paris`. Dates sentinelles `1899-12-30` (heures Access) : ne garder que l'heure.
- Dates en texte (`Site.datcresit`, `SiteMateriel.DateMiseEnService`, dates `jj/mm/aa` et `yyyy-mm-dd`) : tenter `dd/MM/yyyy`, `dd/MM/yy`, `yyyy-MM-dd` ; sinon `null` et copie dans la colonne `_brut`.
- `typint` : texte → entier si numérique ; sinon `null` + `type_brut`.
- Codes de référentiel absents : voir ordre 1.
- Intervenants : `codint` résolu par `intervenants.code` ; code introuvable → `null` + signalement.
- Utilisateurs : `codintuti` conservé seulement s'il existe dans `intervenants.code`.
- Devis : les trois tables vers `devis` avec `famille` ; `NumeroSite`/`NumeroClient` incohérents conservés tels quels.
- Planification : une ligne par `Tn` non null.
- Orphelins (site sans client existant, intervention sans site) : conservés avec FK `null` si la contrainte l'autorise, sinon rattachés à une ligne « Inconnu » créée pour l'occasion (`legacy_id` négatif), toujours signalés.
- Doublons de `legacy_id` : impossible en source (identités) sauf `devis` ; ne rien dédoublonner d'autre.

## Contrôles du rapport

- Par table : lignes source, lignes cible, écart, lignes signalées.
- `interventions` : répartition par `statut_code` et `type_code`, sommes de `montant_fmc` et `montant_sous_traitant` par année de `date_realisee`, comparées à SQL Server.
- `devis` : nombre et somme `montant_ht` par famille et statut.
- `sites` : nombre par client pour les 10 plus gros clients.
- Échantillon : 20 `sites.legacy_id` tirés au sort, affichage côte à côte nom, ville, client, nombre d'interventions.

## Exécution

```powershell
cd scripts\migrate-legacy
npm install
# .env.local : MSSQL_HOST=localhost MSSQL_USER=sa MSSQL_PASSWORD=... MSSQL_DB=logiclim SUPABASE_DB_URL=postgresql://...
node index.mjs --dry-run
node index.mjs
node index.mjs --tables=interventions
```

Le script se connecte à SQL Server avec `trustServerCertificate: true`. Il vide et recharge chaque table
cible sélectionnée avant insertion, dans l'ordre des dépendances, en une transaction par table.

## Critères d'acceptation

- Écart source/cible nul sur toutes les tables sauf devis (fusion) et planifications (dépivot), où le rapport explique l'écart.
- Sommes de montants identiques à l'euro près.
- Relancer deux fois donne le même résultat.
- L'utilisateur vérifie 5 sites et 5 interventions connus dans le tableau Supabase.

## État

- [ ] Non commencée
