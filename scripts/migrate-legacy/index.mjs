#!/usr/bin/env node
import { loadConfig } from './config.mjs';
import { connectMssql, connectPg, buildContext, upsertBatch, updateBatch, countRows } from './lib/db.mjs';
import { writeReport } from './report.mjs';

// Ordre de dépendance, cf. docs/plan/etape-2.md "Ordre de chargement".
const LOAD_ORDER = [
  // Référentiels absents de legacy/referentiels.txt : chargés directement depuis la source.
  'marques',
  'reperes',
  'types_telecommande',
  'jours_feries',
  'types_evenement_vehicule',
  'etats_vehicule',
  'references_materiel',
  // Tiers
  'clients',
  'donneurs_ordre',
  'intervenants',
  'intervenant_zones',
  'intervenant_activites',
  'utilisateurs',
  'intervenants_fk_utilisateurs', // 2e passe : FK circulaire intervenants <-> utilisateurs
  'contacts',
  // Sites
  'sites',
  'site_contrats',
  'site_horaires',
  'site_registre_securite',
  'site_materiels', // sans intervention_id
  // Interventions
  'interventions',
  'site_materiels_intervention', // 2e passe : NumeroInter -> interventions.legacy_id
  'intervention_techniciens',
  'fiches_intervention',
  'heures_techniciens',
  // Devis et planification
  'devis',
  'planifications',
  // Véhicules
  'vehicules',
  'vehicule_evenements',
];

function parseArgs(argv) {
  const args = { tables: null, dryRun: false };
  for (const arg of argv) {
    if (arg === '--dry-run') args.dryRun = true;
    else if (arg.startsWith('--tables=')) args.tables = arg.slice('--tables='.length).split(',').map((s) => s.trim());
  }
  return args;
}

async function loadModule(name) {
  const mod = await import(`./mapping/${name}.mjs`);
  return { name, ...mod.default };
}

function flattenTransformed(rawResults) {
  const rows = [];
  for (const r of rawResults) {
    if (r == null) continue;
    if (Array.isArray(r)) rows.push(...r.filter((x) => x != null));
    else rows.push(r);
  }
  return rows;
}

async function runStandardModule(mod, mssqlPool, pgPool, report, dryRun) {
  const { recordset } = await mssqlPool.request().query(mod.source);
  const ctx = await buildContext(pgPool, mod.lookups, { report });

  if (mod.before) await mod.before(pgPool, recordset, ctx);

  const transformed = recordset.map((row) => mod.transform(row, ctx));
  const rows = flattenTransformed(transformed);

  let written = 0;
  if (!dryRun && rows.length > 0) {
    written = await upsertBatch(pgPool, mod.target, rows, mod.conflictColumns);
  }
  return { sourceCount: recordset.length, targetRows: rows.length, written };
}

async function runMultiSourceModule(mod, mssqlPool, pgPool, report, dryRun) {
  const ctx = await buildContext(pgPool, mod.lookups, { report });
  let sourceCount = 0;
  const allRows = [];
  for (const { famille, sql: sourceSql } of mod.sources) {
    const { recordset } = await mssqlPool.request().query(sourceSql);
    sourceCount += recordset.length;
    const transformed = recordset.map((row) => mod.transform(row, ctx, famille));
    allRows.push(...flattenTransformed(transformed));
  }
  let written = 0;
  if (!dryRun && allRows.length > 0) {
    written = await upsertBatch(pgPool, mod.target, allRows, mod.conflictColumns);
  }
  return { sourceCount, targetRows: allRows.length, written };
}

async function runUpdatePassModule(mod, mssqlPool, pgPool, report, dryRun) {
  const { recordset } = await mssqlPool.request().query(mod.source);
  const ctx = await buildContext(pgPool, mod.lookups, { report });
  const transformed = recordset.map((row) => mod.transform(row, ctx));
  const rows = flattenTransformed(transformed);

  let written = 0;
  if (!dryRun && rows.length > 0) {
    written = await updateBatch(pgPool, mod.target, mod.keyColumn, rows, mod.updateColumns);
  }
  return { sourceCount: recordset.length, targetRows: rows.length, written };
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const config = loadConfig();
  const tableNames = args.tables || LOAD_ORDER;

  console.log(`Connexion à SQL Server (${config.mssql.server || 'via MSSQL_URL'})...`);
  const mssqlPool = await connectMssql(config.mssql);
  console.log('Connexion à Supabase (Postgres direct)...');
  const pgPool = connectPg(config.supabaseDbUrl);

  const report = { startedAt: new Date().toISOString(), dryRun: args.dryRun, tables: {} };

  try {
    for (const name of LOAD_ORDER) {
      if (!tableNames.includes(name)) continue;
      const mod = await loadModule(name);
      process.stdout.write(`  ${mod.kind === 'update-pass' ? 'maj  ' : 'charge'} ${name}...`);

      let result;
      if (mod.kind === 'update-pass') {
        result = await runUpdatePassModule(mod, mssqlPool, pgPool, report, args.dryRun);
      } else if (mod.sources) {
        result = await runMultiSourceModule(mod, mssqlPool, pgPool, report, args.dryRun);
      } else {
        result = await runStandardModule(mod, mssqlPool, pgPool, report, args.dryRun);
      }

      const targetCount = args.dryRun ? null : await countRows(pgPool, mod.target);
      report.tables[name] = { ...result, targetCountAfter: targetCount };
      console.log(
        ` source=${result.sourceCount} transformé=${result.targetRows} écrit=${result.written}` +
          (targetCount != null ? ` (table=${targetCount})` : ' (dry-run)')
      );
    }

    await writeReport(pgPool, report);
    console.log('\nTransfert terminé. Rapport : scripts/migrate-legacy/last-run-report.md');
  } finally {
    await mssqlPool.close();
    await pgPool.end();
  }
}

main().catch((err) => {
  console.error('\nERREUR :', err.message);
  console.error(err.stack);
  process.exit(1);
});
