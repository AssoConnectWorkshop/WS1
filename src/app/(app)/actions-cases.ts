"use server";

import { createClient } from "@/lib/supabase/server";
import { enregistrerJournal } from "@/lib/journal";
import { requireUtilisateur } from "@/lib/action-utils";

/** Cases modifiables directement dans les feuilles de données, comme dans Access (liste blanche). */
const CASES_EDITABLES: Record<string, readonly string[]> = {
  sites: ["rdv_a_prendre"],
  interventions: ["non_facturable", "devis_a_faire", "devis_fait", "duplicata_traite"],
  clients: ["actif"],
};

export type CaseEditable = { table: "sites" | "interventions" | "clients"; id: number; champ: string };

export async function basculerCase({ table, id, champ }: CaseEditable, valeur: boolean) {
  const { utilisateur } = await requireUtilisateur();
  if (!CASES_EDITABLES[table]?.includes(champ) || !Number.isInteger(id)) return { ok: false };
  const supabase = await createClient();
  const { error } = await supabase.from(table).update({ [champ]: valeur }).eq("id", id);
  if (error) return { ok: false };
  await enregistrerJournal(supabase, table, id, utilisateur.id, { action: "case_liste", champ, valeur });
  return { ok: true };
}
