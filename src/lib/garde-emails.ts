import "server-only";

/**
 * Liste blanche des destinataires d'e-mails (réinitialisations de mot de passe, e-mails Resend).
 * `EMAILS_AUTORISES` : adresses complètes ou domaines (`@team.blue`), séparés par des virgules.
 * Variable absente ou vide → aucun e-mail ne part, quel que soit le déclencheur.
 */
export function emailAutorise(adresse: string | null | undefined): boolean {
  if (!adresse) return false;
  const a = adresse.trim().toLowerCase();
  const regles = (process.env.EMAILS_AUTORISES ?? "")
    .split(",")
    .map((r) => r.trim().toLowerCase())
    .filter(Boolean);
  return regles.some((r) => (r.startsWith("@") ? a.endsWith(r) : a === r));
}

export const MOTIF_BLOCAGE = "Envoi bloqué : destinataire hors liste blanche (variable EMAILS_AUTORISES sur Vercel).";
