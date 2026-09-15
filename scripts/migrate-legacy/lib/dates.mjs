// Conversions de dates/heures pour le transfert logiclim -> Supabase.
// Aucune dépendance externe : la conversion de fuseau horaire s'appuie sur
// Intl.DateTimeFormat (disponible nativement dans Node 20+).

const PARIS_TZ = 'Europe/Paris';

const parisFormatter = new Intl.DateTimeFormat('en-US', {
  timeZone: PARIS_TZ,
  hour12: false,
  year: 'numeric',
  month: '2-digit',
  day: '2-digit',
  hour: '2-digit',
  minute: '2-digit',
  second: '2-digit',
});

function parisOffsetMillis(utcGuessMs) {
  const parts = parisFormatter.formatToParts(new Date(utcGuessMs));
  const get = (type) => Number(parts.find((p) => p.type === type).value);
  const asUtc = Date.UTC(
    get('year'),
    get('month') - 1,
    get('day'),
    get('hour') === 24 ? 0 : get('hour'),
    get('minute'),
    get('second')
  );
  return asUtc - utcGuessMs;
}

/**
 * Interprète des composants de date/heure "muets" (sans fuseau, tels que lus dans
 * SQL Server) comme une heure locale Europe/Paris, et retourne l'instant UTC
 * correspondant sous forme de Date JS (donc de timestamptz valide pour Postgres).
 */
export function parisWallTimeToUtcDate(year, month, day, hour = 0, minute = 0, second = 0) {
  const utcGuess = Date.UTC(year, month - 1, day, hour, minute, second);
  const offset = parisOffsetMillis(utcGuess);
  // Un deuxième passage corrige les rares cas où le décalage change autour du point de bascule DST.
  const offset2 = parisOffsetMillis(utcGuess - offset);
  return new Date(utcGuess - offset2);
}

/**
 * mssql retourne les colonnes datetime/smalldatetime comme des objets Date dont les
 * champs UTC (getUTCFullYear, etc.) portent en réalité la valeur "murale" lue en base,
 * sans fuseau. On les réinterprète donc comme heure de Paris.
 */
export function mssqlDatetimeToUtc(value) {
  if (value == null) return null;
  const d = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(d.getTime())) return null;
  return parisWallTimeToUtcDate(
    d.getUTCFullYear(),
    d.getUTCMonth() + 1,
    d.getUTCDate(),
    d.getUTCHours(),
    d.getUTCMinutes(),
    d.getUTCSeconds()
  );
}

/** Sentinelle Access pour "date inconnue, seule l'heure compte" (heuintpre, heuarrint...). */
const ACCESS_ZERO_DATE = '1899-12-30';

/**
 * Extrait uniquement l'heure (HH:mm:ss) d'une colonne datetime source ne portant
 * qu'une heure (souvent avec la date sentinelle 1899-12-30). Ignore la date.
 */
export function mssqlDatetimeToTime(value) {
  if (value == null) return null;
  const d = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(d.getTime())) return null;
  const hh = String(d.getUTCHours()).padStart(2, '0');
  const mm = String(d.getUTCMinutes()).padStart(2, '0');
  const ss = String(d.getUTCSeconds()).padStart(2, '0');
  return `${hh}:${mm}:${ss}`;
}

/** date (sans heure) -> "yyyy-MM-dd" pour une colonne Postgres `date`. */
export function mssqlDateOnly(value) {
  if (value == null) return null;
  const d = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(d.getTime())) return null;
  const y = d.getUTCFullYear();
  const m = String(d.getUTCMonth() + 1).padStart(2, '0');
  const day = String(d.getUTCDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

/**
 * Parse un texte de date libre (Site.datcresit, SiteMateriel.DateMiseEnService...) en
 * essayant successivement dd/MM/yyyy, dd/MM/yy, yyyy-MM-dd. Retourne { date, brut }.
 * `date` est une chaîne "yyyy-MM-dd" ou null ; `brut` est le texte source si non convertible.
 */
export function parseLooseDateText(text) {
  const trimmed = trim(text);
  if (trimmed == null) return { date: null, brut: null };

  let m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(trimmed);
  if (m) {
    const [, y, mo, d] = m;
    return { date: `${y}-${mo}-${d}`, brut: null };
  }

  m = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/.exec(trimmed);
  if (m) {
    const [, d, mo, y] = m;
    return { date: `${y}-${mo.padStart(2, '0')}-${d.padStart(2, '0')}`, brut: null };
  }

  m = /^(\d{1,2})\/(\d{1,2})\/(\d{2})$/.exec(trimmed);
  if (m) {
    const [, d, mo, yy] = m;
    const y = Number(yy) >= 70 ? `19${yy}` : `20${yy}`;
    return { date: `${y}-${mo.padStart(2, '0')}-${d.padStart(2, '0')}`, brut: null };
  }

  return { date: null, brut: trimmed };
}

/**
 * created_at/updated_at à partir des colonnes source creele/majle (nullable en source,
 * malgré un DEFAULT getdate()). created_at et updated_at sont NOT NULL côté cible : on
 * retombe sur l'autre colonne, puis sur l'instant du transfert, plutôt que d'échouer.
 */
export function sourceTimestamps(creele, majle) {
  const createdAt = mssqlDatetimeToUtc(creele);
  const updatedAt = mssqlDatetimeToUtc(majle);
  const now = new Date();
  return {
    created_at: createdAt ?? updatedAt ?? now,
    updated_at: updatedAt ?? createdAt ?? now,
  };
}

/** "HH:MM" (varchar(5)) -> "HH:MM:00", ou null si vide / "00:00". */
export function parseHHMM(text) {
  const trimmed = trim(text);
  if (trimmed == null) return null;
  const m = /^(\d{1,2}):(\d{2})$/.exec(trimmed);
  if (!m) return null;
  const [, hh, mm] = m;
  if (hh === '00' && mm === '00') return null;
  return `${hh.padStart(2, '0')}:${mm}:00`;
}

// Réexporté ici pour éviter une dépendance circulaire avec lib/transform.mjs.
function trim(value) {
  if (value == null) return null;
  const t = String(value).trim();
  return t === '' ? null : t;
}
