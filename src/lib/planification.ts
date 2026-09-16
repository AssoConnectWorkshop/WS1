import "server-only";
import type { SupabaseClient } from "@supabase/supabase-js";
import type { Lot } from "@/lib/sites";

/** Type d'intervention généré par lot (analysis 04 §2.2) : 1 entretien clim, 13 chaudière, 7 désenfumage. */
export const TYPE_INTERVENTION_PAR_LOT: Record<Lot, number> = { clim: 1, chaudiere: 13, desenfumage: 7 };
export const MAX_DATES = 12;

/** Clients Access à calendrier fixe (analysis 04 §2.3 B/C) : non repris, à signaler. */
export const CLIENTS_LEGACY_CALENDRIER_FIXE = [1, 2, 40, 49, 70, 77];

export function iso(d: Date) {
  return d.toISOString().slice(0, 10);
}

export function ajouterMois(d: Date, mois: number) {
  const r = new Date(d);
  r.setUTCMonth(r.getUTCMonth() + mois);
  return r;
}

/** Férié → veille, samedi → vendredi, dimanche → lundi (Calcul.calcul_jour_ouvrable). */
export function ajusterJourOuvrable(d: Date, feries: Set<string>) {
  const r = new Date(d);
  if (feries.has(iso(r))) r.setUTCDate(r.getUTCDate() - 1);
  if (r.getUTCDay() === 6) r.setUTCDate(r.getUTCDate() - 1);
  if (r.getUTCDay() === 0) r.setUTCDate(r.getUTCDate() + 1);
  return r;
}

/** Dates prévues : départ + pas, puis tous les `pasMois` mois jusqu'à `fin` incluse. */
export function datesPrevues(depart: Date, pasMois: number, fin: Date, feries: Set<string>) {
  const dates: string[] = [];
  let d = ajouterMois(depart, pasMois);
  while (d <= fin && dates.length < 60) {
    dates.push(iso(ajusterJourOuvrable(d, feries)));
    d = ajouterMois(d, pasMois);
  }
  return dates;
}

export type SiteConcerne = { id: number; nom: string | null; intervenant_id: number | null; ne_plus_intervenir: boolean; sous_traitant_id: number | null };

/** Sites ouverts d'un client dont le contrat du lot prévoit exactement `visites` visites/an (Form_Planification.cmdGenerer). */
export async function sitesConcernes(supabase: SupabaseClient, clientId: number, lot: Lot, visites: number): Promise<SiteConcerne[]> {
  const { data: sites } = await supabase
    .from("sites")
    .select("id, nom, intervenant_id, ne_plus_intervenir")
    .eq("client_id", clientId)
    .eq("ferme", false)
    .is("supprime_le", null)
    .order("nom");
  const ids = (sites ?? []).map((s) => s.id);
  if (ids.length === 0) return [];

  const { data: contrats } = await supabase.from("site_contrats").select("site_id, sous_traitant_id").eq("lot", lot).eq("visites_par_an", visites).in("site_id", ids);
  const parSite = new Map((contrats ?? []).map((c) => [c.site_id, c.sous_traitant_id as number | null]));
  return (sites ?? []).filter((s) => parSite.has(s.id)).map((s) => ({ ...s, sous_traitant_id: parSite.get(s.id) ?? null }));
}

export async function intervenantFmcId(supabase: SupabaseClient) {
  const { data } = await supabase.from("intervenants").select("id").eq("code", "FMC").maybeSingle();
  return (data?.id as number | undefined) ?? null;
}

export async function joursFeries(supabase: SupabaseClient) {
  const { data } = await supabase.from("jours_feries").select("date_jour");
  return new Set((data ?? []).map((j) => String(j.date_jour).slice(0, 10)));
}
