#!/usr/bin/env node
/**
 * Syncs WS12-WS39: personalized site.ts + renames prenoms table
 *
 * Required env vars: GITHUB_TOKEN, SUPABASE_ACCESS_TOKEN
 * Optional: WS_START, WS_END
 */

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const SUPABASE_TOKEN = process.env.SUPABASE_ACCESS_TOKEN;
const GITHUB_ORG = 'AssoConnectWorkshop';
const WS_START = parseInt(process.env.WS_START || '12');
const WS_END = parseInt(process.env.WS_END || '39');

async function github(method, path, body) {
  const res = await fetch(`https://api.github.com${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${GITHUB_TOKEN}`,
      Accept: 'application/vnd.github+json',
      'Content-Type': 'application/json',
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const json = await res.json();
  if (!res.ok) throw new Error(`GitHub ${method} ${path}: ${json.message}`);
  return json;
}

async function supabase(method, path, body) {
  const res = await fetch(`https://api.supabase.com/v1${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${SUPABASE_TOKEN}`,
      'Content-Type': 'application/json',
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const json = await res.json();
  if (!res.ok) throw new Error(`Supabase ${method} ${path}: ${JSON.stringify(json)}`);
  return json;
}

async function pushFile(repo, path, content, message) {
  let sha;
  try {
    const existing = await github('GET', `/repos/${GITHUB_ORG}/${repo}/contents/${path}`);
    sha = existing.sha;
  } catch {}
  await github('PUT', `/repos/${GITHUB_ORG}/${repo}/contents/${path}`, {
    message,
    content: Buffer.from(content).toString('base64'),
    ...(sha ? { sha } : {}),
  });
}

async function syncWorkspace(n) {
  const name = `WS${n}`;
  console.log(`\n── ${name} ──────────────────────────`);

  // 1. Push personalized site.ts
  const siteTs = `export const siteConfig = {
  name: "${name}",
  description: "Next.js + Supabase + AssoConnect API.",
};\n`;
  await pushFile(name, 'src/config/site.ts', siteTs, `chore: set workspace name to ${name}`);
  console.log(`  ✓ site.ts updated`);

  // 2. Rename prenoms table in Supabase
  const projects = await supabase('GET', '/projects');
  const project = projects.find(p => p.name === name);
  if (!project) { console.log(`  ✗ Supabase project not found`); return; }

  const sql = `
    DO $$ BEGIN
      IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'prenoms') THEN
        ALTER TABLE prenoms RENAME TO ws${n}_prenoms;
      END IF;
      DROP TABLE IF EXISTS notes;
      DROP TABLE IF EXISTS cities;
    END $$;
  `;

  try {
    await supabase('POST', `/projects/${project.id}/database/query`, { query: sql });
    console.log(`  ✓ DB: prenoms → ws${n}_prenoms, notes/cities dropped`);
  } catch (e) {
    console.log(`  ✗ DB error: ${e.message}`);
  }
}

async function main() {
  console.log(`Syncing WS${WS_START} → WS${WS_END}`);
  for (let n = WS_START; n <= WS_END; n++) {
    await syncWorkspace(n);
  }
  console.log('\n✓ Done');
}

main().catch(err => { console.error(err.message); process.exit(1); });
