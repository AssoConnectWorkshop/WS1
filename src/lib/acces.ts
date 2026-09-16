import "server-only";
import { randomBytes } from "node:crypto";

/**
 * Master admins : adresses listées dans la variable Vercel `MASTER_ADMINS` (virgules).
 * Toujours administrateur, indépendamment des données FMC ; une ligne `utilisateurs`
 * (compte_application) est créée à leur première connexion si aucune ne porte leur e-mail.
 */
export function masterAdmins(): string[] {
  return (process.env.MASTER_ADMINS ?? "")
    .split(",")
    .map((e) => e.trim().toLowerCase())
    .filter(Boolean);
}

export function estMasterAdmin(email: string | null | undefined): boolean {
  return !!email && masterAdmins().includes(email.trim().toLowerCase());
}

const ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789";

/** Mot de passe initial affiché une seule fois à l'administrateur, jamais envoyé par e-mail. */
export function motDePasseInitial(longueur = 16): string {
  const octets = randomBytes(longueur);
  return Array.from(octets, (o) => ALPHABET[o % ALPHABET.length]).join("");
}
