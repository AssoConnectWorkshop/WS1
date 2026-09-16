import { z } from "zod";

const vide = (v: unknown) => v == null || (typeof v === "string" && v.trim() === "");

/** Champs de FormData : "" → null, nombres coercés, case à cocher absente → false. */
export const texte = z.preprocess((v) => (vide(v) ? null : v), z.string().trim().nullable());
export const nombre = z.preprocess((v) => (vide(v) ? null : Number(v)), z.number({ invalid_type_error: "Valeur numérique invalide." }).nullable());
export const entier = z.preprocess((v) => (vide(v) ? null : Number(v)), z.number({ invalid_type_error: "Valeur entière invalide." }).int().nullable());
export const booleen = z.preprocess((v) => v === "1" || v === "on" || v === true, z.boolean());
export const identifiant = z.coerce.number().int().positive();

export function obligatoire(message: string) {
  return z.string().trim().min(1, message);
}
