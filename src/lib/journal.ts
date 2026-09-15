import "server-only";
import type { SupabaseClient } from "@supabase/supabase-js";

/** Journal des modifications (brief étape 5 §Conventions) : alimenté par les Server Actions
 * des interventions et devis. `diff` est libre (avant/après ou juste l'action selon le cas). */
export async function enregistrerJournal(
  supabase: SupabaseClient,
  table: string,
  ligneId: number,
  utilisateurId: number | null,
  diff: Record<string, unknown>,
) {
  await supabase.from("journal_modifications").insert({
    table,
    ligne_id: ligneId,
    utilisateur_id: utilisateurId,
    diff,
  });
}
