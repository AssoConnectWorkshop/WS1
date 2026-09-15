import { mssqlDateOnly } from '../lib/dates.mjs';

// Absent de legacy/referentiels.txt : chargé ici directement depuis la source (étape 2).
// Pas de legacy_id sur cette table (voir supabase/migrations/20260915120001_referentiels.sql) :
// la date elle-même est la clé.
export default {
  target: 'jours_feries',
  conflictColumns: ['date_jour'],
  source: `select datjoufer from JoursFeries`,
  transform(row) {
    const dateJour = mssqlDateOnly(row.datjoufer);
    return dateJour ? { date_jour: dateJour } : null;
  },
};
