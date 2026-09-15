#!/usr/bin/env node
// Test d'intégration local : rejoue tout le pipeline de mapping contre une vraie base
// Postgres (schéma de l'étape 1), avec UNE ligne source synthétique par table (aucune
// donnée réelle). Ne touche jamais SQL Server : sert uniquement à valider que chaque
// module de mapping produit des lignes conformes au schéma et que l'orchestration
// (lookups, upsert, update-pass, sources multiples, ordre de dépendance) fonctionne.
//
// Usage : PG_TEST_URL=postgresql://... node test/run.mjs
import pg from 'pg';
import { buildContext, upsertBatch, updateBatch, countRows } from '../lib/db.mjs';
import { FIXTURES } from './fixtures.mjs';

const LOAD_ORDER = [
  'marques', 'reperes', 'types_telecommande', 'jours_feries', 'types_evenement_vehicule',
  'etats_vehicule', 'references_materiel',
  'clients', 'donneurs_ordre',
  'intervenants', 'intervenant_zones', 'intervenant_activites',
  'utilisateurs', 'intervenants_fk_utilisateurs',
  'contacts',
  'sites', 'site_contrats', 'site_horaires', 'site_registre_securite', 'site_materiels',
  'interventions', 'site_materiels_intervention', 'intervention_techniciens',
  'fiches_intervention', 'heures_techniciens',
  'devis', 'planifications',
  'vehicules', 'vehicule_evenements',
];

function flatten(results) {
  const rows = [];
  for (const r of results) {
    if (r == null) continue;
    if (Array.isArray(r)) rows.push(...r.filter((x) => x != null));
    else rows.push(r);
  }
  return rows;
}

async function main() {
  const connectionString = process.env.PG_TEST_URL;
  if (!connectionString) {
    console.error('Définir PG_TEST_URL (ex. postgresql://postgres:testpass@127.0.0.1:5432/ws1_test)');
    process.exit(1);
  }
  const pgPool = new pg.Pool({ connectionString });
  const report = {};
  let failures = 0;

  for (const name of LOAD_ORDER) {
    const mod = (await import(`../mapping/${name}.mjs`)).default;
    const fixtureRow = FIXTURES[name];
    if (!fixtureRow) {
      console.log(`  SKIP  ${name} (pas de fixture)`);
      continue;
    }

    try {
      const ctx = await buildContext(pgPool, mod.lookups, { report });
      let rows;

      if (mod.sources) {
        rows = flatten(mod.sources.map(({ famille }) => mod.transform(fixtureRow, ctx, famille)));
      } else {
        if (mod.before) await mod.before(pgPool, [fixtureRow], ctx);
        rows = flatten([mod.transform(fixtureRow, ctx)]);
      }

      if (rows.length === 0) {
        console.log(`  WARN  ${name} : transform() n'a produit aucune ligne pour la fixture`);
        continue;
      }

      // Vérifie que chaque colonne produite existe bien dans la table cible.
      const { rows: colRows } = await pgPool.query(
        `select column_name from information_schema.columns where table_schema='public' and table_name = $1`,
        [mod.target]
      );
      const validColumns = new Set(colRows.map((r) => r.column_name));
      for (const row of rows) {
        for (const key of Object.keys(row)) {
          if (!validColumns.has(key)) {
            throw new Error(`colonne "${key}" produite par transform() n'existe pas dans public.${mod.target}`);
          }
        }
      }

      if (mod.kind === 'update-pass') {
        await updateBatch(pgPool, mod.target, mod.keyColumn, rows, mod.updateColumns);
      } else {
        await upsertBatch(pgPool, mod.target, rows, mod.conflictColumns);
      }

      const count = await countRows(pgPool, mod.target);
      console.log(`  OK    ${name} : ${rows.length} ligne(s) écrite(s), table=${count}`);
    } catch (err) {
      failures += 1;
      console.error(`  FAIL  ${name} : ${err.message}`);
    }
  }

  await pgPool.end();
  if (failures > 0) {
    console.error(`\n${failures} module(s) en échec.`);
    process.exit(1);
  }
  console.log('\nTous les modules de mapping ont produit des lignes valides.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
