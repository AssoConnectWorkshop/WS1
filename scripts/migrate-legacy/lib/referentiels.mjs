// Complète un référentiel avec les codes rencontrés dans les données mais absents
// du référentiel chargé à l'étape 1 (cf. docs/plan/etape-2.md, "Ordre de chargement" §1).

// Colonnes obligatoires supplémentaires par référentiel (au-delà de code/libelle),
// avec la valeur à poser pour un code "découvert" pendant le transfert.
const EXTRA_COLUMNS_ON_DISCOVERY = {
  statuts_intervention: { actif: false },
};

/**
 * @param {import('pg').Pool} pgPool
 * @param {string} table référentiel cible (ex. 'statuts_intervention')
 * @param {Array<number|string|null>} codesRencontres tous les codes vus dans les lignes source
 * @param {object} report accumulateur { table: [codes ajoutés] } passé par l'orchestrateur
 * @returns {Promise<Set<number|string>>} l'ensemble des codes maintenant valides
 */
export async function ensureReferentialCodes(pgPool, table, codesRencontres, report) {
  const distinct = [...new Set(codesRencontres.filter((c) => c != null))];
  if (distinct.length === 0) return new Set();

  const { rows } = await pgPool.query(`select code from public.${table}`);
  const existing = new Set(rows.map((r) => r.code));

  const missing = distinct.filter((c) => !existing.has(c));
  if (missing.length > 0) {
    const extra = EXTRA_COLUMNS_ON_DISCOVERY[table] || {};
    const extraCols = Object.keys(extra);
    const columns = ['code', 'libelle', ...extraCols];
    const values = [];
    const tuples = missing.map((code) => {
      const rowValues = [code, `Inconnu (code ${code})`, ...extraCols.map((c) => extra[c])];
      const placeholders = rowValues.map((v) => {
        values.push(v);
        return `$${values.length}`;
      });
      return `(${placeholders.join(', ')})`;
    });
    await pgPool.query(
      `insert into public.${table} (${columns.join(', ')}) values ${tuples.join(', ')}
       on conflict (code) do nothing`,
      values
    );
    report[table] = (report[table] || []).concat(missing);
  }

  return new Set(distinct);
}
