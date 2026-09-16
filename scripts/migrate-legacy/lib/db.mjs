import sql from 'mssql';
import pg from 'pg';

const { Pool } = pg;

export async function connectMssql(mssqlConfig) {
  const pool = new sql.ConnectionPool(mssqlConfig);
  await pool.connect();
  return pool;
}

export function connectPg(connectionString) {
  return new Pool({ connectionString });
}

/**
 * Charge une table de correspondance { valeur_source -> id_cible } depuis Postgres,
 * pour résoudre les FK sans reprendre les identifiants source (règle étape 1).
 * Exemple : loadLookup(pg, 'clients', 'legacy_id') -> Map(numcli -> clients.id).
 */
export async function loadLookup(pgPool, table, column) {
  const { rows } = await pgPool.query(
    `select id, ${column} as key from public.${table} where ${column} is not null`
  );
  const map = new Map();
  for (const row of rows) map.set(row.key, row.id);
  return map;
}

/**
 * Précharge les correspondances déclarées par un module de mapping
 * (module.lookups = [{ name, table, column }]) et les expose via ctx.get(name).
 */
export async function buildContext(pgPool, lookups = [], extra = {}) {
  const maps = new Map();
  for (const { name, table, column } of lookups) {
    maps.set(name, await loadLookup(pgPool, table, column));
  }
  return {
    get(name) {
      const map = maps.get(name);
      if (!map) throw new Error(`Lookup "${name}" non déclaré dans lookups[] de ce module.`);
      return map;
    },
    ...extra,
  };
}

/**
 * Insère des lignes par lots avec `insert ... on conflict (...) do update`.
 * Toutes les lignes doivent avoir exactement les mêmes clés (colonnes cibles).
 */
const MAX_PARAMETRES_REQUETE = 60000;

/** Postgres limite une requête à 65 535 paramètres liés : le lot est réduit pour les tables larges (ex. sites, ~100 colonnes). */
function tailleLot(batchSize, nbColonnes) {
  return Math.max(1, Math.min(batchSize, Math.floor(MAX_PARAMETRES_REQUETE / nbColonnes)));
}

export async function upsertBatch(pgPool, table, rows, conflictColumns, batchSize = 1000) {
  if (rows.length === 0) return 0;
  const columns = Object.keys(rows[0]);
  batchSize = tailleLot(batchSize, columns.length);
  const updateColumns = columns.filter((c) => !conflictColumns.includes(c));
  // `updated_at` est déjà fournie par la ligne pour les quelques tables où le brief demande
  // de reprendre la vraie date de modification source (ex. sites.majle, interventions.majle) ;
  // sinon on la bascule sur now() pour refléter le passage de ce script.
  const sourceProvidesUpdatedAt = updateColumns.includes('updated_at');
  const setAssignments = updateColumns.map((c) => `${c} = excluded.${c}`);
  if (!sourceProvidesUpdatedAt) setAssignments.push('updated_at = now()');
  const setClause = setAssignments.length ? setAssignments.join(', ') : null;

  // Le trigger set_updated_at (étape 1) écrase inconditionnellement updated_at à now() sur
  // tout UPDATE, y compris celui déclenché par ON CONFLICT DO UPDATE : quand la ligne fournit
  // sa propre valeur (reprise de la source), on désactive ce trigger le temps du lot pour que
  // cette valeur ne soit pas perdue à chaque réexécution du script.
  const client = sourceProvidesUpdatedAt ? await pgPool.connect() : pgPool;

  let inserted = 0;
  try {
    if (sourceProvidesUpdatedAt) {
      await client.query('begin');
      await client.query('set local session_replication_role = replica');
    }

    for (let start = 0; start < rows.length; start += batchSize) {
      const chunk = rows.slice(start, start + batchSize);
      const values = [];
      const tuples = chunk.map((row) => {
        const placeholders = columns.map((col) => {
          values.push(row[col] ?? null);
          return `$${values.length}`;
        });
        return `(${placeholders.join(', ')})`;
      });

      const conflictClause = setClause
        ? `on conflict (${conflictColumns.join(', ')}) do update set ${setClause}`
        : `on conflict (${conflictColumns.join(', ')}) do nothing`;

      const text = `
        insert into public.${table} (${columns.join(', ')})
        values ${tuples.join(', ')}
        ${conflictClause}
      `;
      await client.query(text, values);
      inserted += chunk.length;
    }

    if (sourceProvidesUpdatedAt) await client.query('commit');
  } catch (err) {
    if (sourceProvidesUpdatedAt) await client.query('rollback');
    throw err;
  } finally {
    if (sourceProvidesUpdatedAt) client.release();
  }
  return inserted;
}

/**
 * Met à jour uniquement certaines colonnes de lignes déjà insérées, par lots, via
 * `update ... from (values ...)`. Utilisé pour les FK circulaires (ex. intervenants
 * <-> utilisateurs) qu'on ne peut pas résoudre en une seule passe d'insertion, sans
 * devoir fournir les autres colonnes NOT NULL de la table (contrairement à upsertBatch).
 */
export async function updateBatch(pgPool, table, keyColumn, rows, updateColumns, batchSize = 1000) {
  if (rows.length === 0) return 0;

  // `update ... from (values ...)` n'a pas de contexte de colonnes cible comme un insert :
  // sans cast explicite, Postgres résout le type des paramètres en "text" et échoue dès
  // que la colonne réelle est un entier (ex. "operator does not exist: integer = text").
  const allColumns = [keyColumn, ...updateColumns];
  const { rows: colRows } = await pgPool.query(
    `select column_name, udt_name from information_schema.columns
     where table_schema = 'public' and table_name = $1 and column_name = any($2)`,
    [table, allColumns]
  );
  const castByColumn = new Map(colRows.map((r) => [r.column_name, r.udt_name]));
  batchSize = tailleLot(batchSize, allColumns.length);

  let updated = 0;
  for (let start = 0; start < rows.length; start += batchSize) {
    const chunk = rows.slice(start, start + batchSize);
    const values = [];
    const tuples = chunk.map((row) => {
      const rowValues = [row[keyColumn], ...updateColumns.map((c) => row[c] ?? null)];
      const placeholders = allColumns.map((col, i) => {
        values.push(rowValues[i]);
        const cast = castByColumn.get(col);
        return cast ? `$${values.length}::${cast}` : `$${values.length}`;
      });
      return `(${placeholders.join(', ')})`;
    });
    const setClause = updateColumns.map((c) => `${c} = v.${c}`).join(', ');
    const valueCols = allColumns.join(', ');
    const text = `
      update public.${table} t
      set ${setClause}, updated_at = now()
      from (values ${tuples.join(', ')}) as v(${valueCols})
      where t.${keyColumn} = v.${keyColumn}
    `;
    await pgPool.query(text, values);
    updated += chunk.length;
  }
  return updated;
}

export async function countRows(pgPool, table, where = '') {
  const { rows } = await pgPool.query(`select count(*) as n from public.${table} ${where}`);
  return Number(rows[0].n);
}
