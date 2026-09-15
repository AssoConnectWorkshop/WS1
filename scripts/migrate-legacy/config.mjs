import { readFileSync, existsSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dir = dirname(fileURLToPath(import.meta.url));

// Charge scripts/migrate-legacy/.env.local (gitignoré) dans process.env sans écraser
// des variables déjà présentes dans l'environnement (utile en CI ou en shell interactif).
function loadDotEnvLocal() {
  const path = join(__dir, '.env.local');
  if (!existsSync(path)) return;
  const content = readFileSync(path, 'utf8');
  for (const rawLine of content.split('\n')) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;
    const eq = line.indexOf('=');
    if (eq === -1) continue;
    const key = line.slice(0, eq).trim();
    let value = line.slice(eq + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    if (!(key in process.env)) process.env[key] = value;
  }
}

loadDotEnvLocal();

function required(name) {
  const value = process.env[name];
  if (!value) {
    console.error(`ERREUR : variable d'environnement ${name} manquante (voir scripts/migrate-legacy/README.md).`);
    process.exit(1);
  }
  return value;
}

export function loadConfig() {
  const mssql = process.env.MSSQL_URL
    ? { connectionString: process.env.MSSQL_URL }
    : {
        server: process.env.MSSQL_HOST || 'localhost',
        port: process.env.MSSQL_PORT ? Number(process.env.MSSQL_PORT) : 1433,
        user: process.env.MSSQL_USER || 'sa',
        password: required('MSSQL_PASSWORD'),
        database: process.env.MSSQL_DB || 'logiclim',
        options: {
          trustServerCertificate: true,
          encrypt: false,
        },
      };

  const supabaseDbUrl = required('SUPABASE_DB_URL');

  return {
    mssql,
    supabaseDbUrl,
    batchSize: process.env.MIGRATE_BATCH_SIZE ? Number(process.env.MIGRATE_BATCH_SIZE) : 1000,
  };
}
