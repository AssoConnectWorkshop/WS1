import "server-only";
import type { SupabaseClient } from "@supabase/supabase-js";

export const FAMILLES_DEVIS = ["sav", "travaux", "contrat"] as const;
export type FamilleDevis = (typeof FAMILLES_DEVIS)[number];

export const LIBELLES_FAMILLE: Record<FamilleDevis, string> = {
  sav: "SAV",
  travaux: "Travaux",
  contrat: "Contrat de maintenance",
};

/** Type de l'intervention générée à l'acceptation (analysis 04 §1.1) : 3 devis accepté, 5 en travaux. */
export const TYPE_INTERVENTION_PAR_FAMILLE: Record<FamilleDevis, number> = { sav: 3, travaux: 5, contrat: 3 };

export function estFamille(value: string | undefined): value is FamilleDevis {
  return (FAMILLES_DEVIS as readonly string[]).includes(value ?? "");
}

/** Motif « XX-NNNN » dans le nom court du fichier PDF (brief §5.2). */
export function numeroDepuisFichier(chemin: string | null | undefined): string | null {
  if (!chemin) return null;
  const nomCourt = chemin.split(/[\\/]/).pop() ?? "";
  return /([A-Z]{2}-\d{4})/i.exec(nomCourt)?.[1]?.toUpperCase() ?? null;
}

type ComposantsMontant = {
  montant_fournitures?: number | null;
  heures_mo?: number | null;
  nombre_deplacements?: number | null;
  tarif_heure_mo?: number | null;
  tarif_deplacement?: number | null;
};

/** Montant HT = fournitures + heures × tarif heure + déplacements × tarif déplacement (analysis 04 §1.4). */
export function calculerMontantHt(c: ComposantsMontant): number | null {
  const valeurs = [c.montant_fournitures, c.heures_mo, c.nombre_deplacements, c.tarif_heure_mo, c.tarif_deplacement];
  if (valeurs.every((v) => v == null)) return null;
  const total = (c.montant_fournitures ?? 0) + (c.heures_mo ?? 0) * (c.tarif_heure_mo ?? 0) + (c.nombre_deplacements ?? 0) * (c.tarif_deplacement ?? 0);
  return Math.round(total * 100) / 100;
}

/** Site avec ses tarifs applicables : les siens si `tarifs_specifiques`, sinon ceux du client. */
export async function chargerSiteEtTarifs(supabase: SupabaseClient, siteId: number) {
  const { data: site } = await supabase
    .from("sites")
    .select("id, nom, ville, client_id, intervenant_id, tarifs_specifiques, tarif_heure_mo, tarif_deplacement")
    .eq("id", siteId)
    .maybeSingle();
  if (!site) return null;

  let tarifs = { tarif_heure_mo: site.tarif_heure_mo as number | null, tarif_deplacement: site.tarif_deplacement as number | null };
  if (!site.tarifs_specifiques) {
    const { data: client } = await supabase.from("clients").select("tarif_heure_mo, tarif_deplacement").eq("id", site.client_id).maybeSingle();
    tarifs = { tarif_heure_mo: client?.tarif_heure_mo ?? null, tarif_deplacement: client?.tarif_deplacement ?? null };
  }
  return { ...site, tarifs };
}
