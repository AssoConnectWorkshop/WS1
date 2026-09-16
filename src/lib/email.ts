import "server-only";
import { Resend } from "resend";
import type { SupabaseClient } from "@supabase/supabase-js";

export type Courriel = {
  destinataire: string;
  objet: string;
  texte: string;
  type: "relance" | "partenaire" | "contact" | "fin_intervention";
  interventionId?: number | null;
};

/** Envoi via Resend (clé serveur) ; sans `RESEND_API_KEY`, l'envoi est simulé. Chaque tentative est journalisée. */
export async function envoyerCourriel(journal: SupabaseClient, courriel: Courriel): Promise<{ ok: boolean; statut: string; detail?: string }> {
  const cle = process.env.RESEND_API_KEY;
  const expediteur = process.env.EMAIL_FROM ?? "ClimAccess <no-reply@example.com>";
  let statut = "simule";
  let detail: string | undefined;

  if (cle) {
    try {
      const { error } = await new Resend(cle).emails.send({ from: expediteur, to: courriel.destinataire, subject: courriel.objet, text: courriel.texte });
      statut = error ? "echec" : "envoye";
      detail = error?.message;
    } catch (e) {
      statut = "echec";
      detail = e instanceof Error ? e.message : String(e);
    }
  }

  await journal.from("journal_emails").insert({
    intervention_id: courriel.interventionId ?? null,
    destinataire: courriel.destinataire,
    objet: courriel.objet,
    type: courriel.type,
    statut,
    detail: detail ?? (statut === "simule" ? "RESEND_API_KEY absent : envoi simulé." : null),
  });

  return { ok: statut !== "echec", statut, detail };
}
