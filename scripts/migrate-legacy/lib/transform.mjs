// Conversions génériques réutilisées par les modules de mapping/*.mjs.

export function trim(value) {
  if (value == null) return null;
  const t = String(value).trim();
  return t === '' ? null : t;
}

export function toBool(value) {
  if (value == null) return null;
  if (typeof value === 'boolean') return value;
  if (typeof value === 'number') return value !== 0;
  const t = String(value).trim().toLowerCase();
  if (t === '' ) return null;
  return t === '1' || t === 'true' || t === 'oui';
}

export function toBoolNotNull(value, fallback = false) {
  const b = toBool(value);
  return b == null ? fallback : b;
}

export function toIntOrNull(value) {
  if (value == null) return null;
  const n = typeof value === 'number' ? value : Number(String(value).trim());
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

export function toNumberOrNull(value) {
  if (value == null) return null;
  const n = typeof value === 'number' ? value : Number(String(value).trim().replace(',', '.'));
  return Number.isFinite(n) ? n : null;
}

/**
 * Intervention.typint (et autres colonnes similaires stockées en texte) : entier si
 * purement numérique, sinon { code: null, brut: texte }.
 */
export function parseCodeTexte(value) {
  const t = trim(value);
  if (t == null) return { code: null, brut: null };
  if (/^-?\d+$/.test(t)) return { code: Number(t), brut: null };
  return { code: null, brut: t };
}

/**
 * Puissance (Reference.PuissanceFrigo/PuissanceCalo, texte) : numeric si convertible,
 * sinon { valeur: null, brut: texte }.
 */
export function parsePuissance(value) {
  const t = trim(value);
  if (t == null) return { valeur: null, brut: null };
  const n = Number(t.replace(',', '.'));
  return Number.isFinite(n) ? { valeur: n, brut: null } : { valeur: null, brut: t };
}
