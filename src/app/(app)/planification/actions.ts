"use server";

import { z } from "zod";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { enregistrerJournal } from "@/lib/journal";
import { requireUtilisateur, redirectWithError, aujourdhui } from "@/lib/action-utils";
import { entier, identifiant, obligatoire, texte } from "@/lib/zod-form";
import { CLES_LOTS, LIBELLES_LOT, STATUT_A_PLANIFIER, STATUT_NE_PLUS_INTERVENIR } from "@/lib/sites";
import { CLIENTS_LEGACY_CALENDRIER_FIXE, MAX_DATES, TYPE_INTERVENTION_PAR_LOT, datesPrevues, intervenantFmcId, joursFeries, sitesConcernes } from "@/lib/planification";

const STATUT_ANNULE = 8;

const PlanSchema = z.object({
  client_id: identifiant,
  lot: z.enum(CLES_LOTS),
  nombre_visites: z.coerce.number().int().min(1).max(MAX_DATES),
});
type Plan = z.infer<typeof PlanSchema>;

function versPlanification(plan: Partial<Plan>, extra?: Record<string, string>) {
  const q = new URLSearchParams(extra);
  if (plan.client_id) q.set("client_id", String(plan.client_id));
  if (plan.lot) q.set("lot", plan.lot);
  if (plan.nombre_visites) q.set("visites", String(plan.nombre_visites));
  return `/planification?${q}`;
}

/** Dates limites (jusqu'à 12) et références DI d'un plan client + lot + nombre de visites. */
export async function enregistrerPlanification(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const parsed = PlanSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError("/planification", "Client, lot et nombre de visites sont obligatoires.");
  const plan = parsed.data;
  const retour = versPlanification(plan);

  const lignes = [];
  for (let rang = 1; rang <= plan.nombre_visites; rang++) {
    const date = String(formData.get(`date_${rang}`) ?? "").trim();
    if (!date) continue;
    const reference = String(formData.get(`reference_${rang}`) ?? "").trim();
    lignes.push({ ...plan, rang, date_limite: date, reference_client: reference || null });
  }

  const supabase = await createClient();
  const { error: erreurSuppression } = await supabase
    .from("planifications")
    .delete()
    .eq("client_id", plan.client_id)
    .eq("lot", plan.lot)
    .eq("nombre_visites", plan.nombre_visites);
  if (erreurSuppression) redirectWithError(retour, "L'enregistrement a échoué.");
  if (lignes.length > 0) {
    const { error } = await supabase.from("planifications").insert(lignes);
    if (error) redirectWithError(retour, "L'enregistrement des dates a échoué.");
  }

  await enregistrerJournal(supabase, "clients", plan.client_id, utilisateur.id, { action: "maj_planification", lot: plan.lot, nombre_visites: plan.nombre_visites, dates: lignes.length });
  revalidatePath("/planification");
  redirect(versPlanification(plan, { info: `${lignes.length} date(s) limite(s) enregistrée(s).` }));
}

/** « Générer Interventions » : une intervention par site concerné et par date, anti-doublon site + type + date limite. */
export async function genererInterventions(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const parsed = PlanSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError("/planification", "Client, lot et nombre de visites sont obligatoires.");
  const plan = parsed.data;
  const retour = versPlanification(plan);

  const supabase = await createClient();
  const [{ data: dates }, sites, fmcId] = await Promise.all([
    supabase.from("planifications").select("date_limite, reference_client").eq("client_id", plan.client_id).eq("lot", plan.lot).eq("nombre_visites", plan.nombre_visites).order("rang"),
    sitesConcernes(supabase, plan.client_id, plan.lot, plan.nombre_visites),
    intervenantFmcId(supabase),
  ]);
  if (!dates || dates.length === 0) redirectWithError(retour, "Enregistrez d'abord les dates limites du plan.");
  if (sites.length === 0) redirectWithError(retour, `Aucun site ouvert de ce client n'a un contrat ${LIBELLES_LOT[plan.lot]} à ${plan.nombre_visites} visite(s) par an.`);

  const type = TYPE_INTERVENTION_PAR_LOT[plan.lot];
  const jours = dates.map((d) => String(d.date_limite).slice(0, 10)).sort();
  const { data: existantes } = await supabase
    .from("interventions")
    .select("site_id, date_limite")
    .eq("type_code", type)
    .in("site_id", sites.map((s) => s.id))
    .gte("date_limite", jours[0])
    .lte("date_limite", `${jours[jours.length - 1]}T23:59:59`);
  const dejaPlanifiees = new Set((existantes ?? []).map((e) => `${e.site_id}|${String(e.date_limite).slice(0, 10)}`));

  const lignes = [];
  let doublons = 0;
  for (const site of sites) {
    for (const d of dates) {
      const jour = String(d.date_limite).slice(0, 10);
      if (dejaPlanifiees.has(`${site.id}|${jour}`)) {
        doublons++;
        continue;
      }
      lignes.push({
        site_id: site.id,
        type_code: type,
        statut_code: site.ne_plus_intervenir ? STATUT_NE_PLUS_INTERVENIR : STATUT_A_PLANIFIER,
        date_limite: jour,
        reference_client: d.reference_client,
        intervenant_id: site.sous_traitant_id ?? site.intervenant_id ?? fmcId,
        saisi_par_id: utilisateur.id,
      });
    }
  }
  if (lignes.length > 0) {
    const { error } = await supabase.from("interventions").insert(lignes);
    if (error) redirectWithError(retour, "La génération des interventions a échoué.");
  }

  await enregistrerJournal(supabase, "clients", plan.client_id, utilisateur.id, { action: "generation_entretiens", lot: plan.lot, nombre_visites: plan.nombre_visites, creees: lignes.length, doublons, sites: sites.length });
  revalidatePath("/interventions");
  revalidatePath("/planification");
  redirect(versPlanification(plan, { info: `Génération ${LIBELLES_LOT[plan.lot]} : ${lignes.length} intervention(s) créée(s) sur ${sites.length} site(s), ${doublons} doublon(s) ignoré(s).` }));
}

const CalculSchema = z.object({
  client_id: entier,
  site_id: entier,
  date_debut: texte,
  date_fin: obligatoire("La date de fin est obligatoire pour générer le planning prévisionnel."),
});

/** Mode calculé (analysis 04 §2.3 A) : pas de 12 / visites mois depuis la dernière visite réalisée,
 * sinon le 15/12 de l'année précédente ; les entretiens prévus non réalisés (type 1) sont annulés (statut 8) avant régénération. */
export async function genererDatesPrevues(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const parsed = CalculSchema.safeParse(Object.fromEntries(formData));
  const clientId = Number(formData.get("client_id")) || undefined;
  const retour = versPlanification({ client_id: clientId });
  if (!parsed.success) redirectWithError(retour, parsed.error.issues[0]?.message ?? "Formulaire invalide.");
  const { client_id, site_id, date_fin } = parsed.data;
  const dateDebut = parsed.data.date_debut ?? aujourdhui();
  if (!client_id && !site_id) redirectWithError(retour, "Choisissez un client ou un site.");
  const fin = new Date(`${date_fin}T00:00:00Z`);
  if (Number.isNaN(fin.getTime()) || fin < new Date(`${dateDebut}T00:00:00Z`)) redirectWithError(retour, "La date de fin doit être postérieure à la date de début.");

  const supabase = await createClient();
  let requeteSites = supabase.from("sites").select("id, nom, client_id, intervenant_id, ne_plus_intervenir, visites_entretien_par_an").eq("ferme", false).is("supprime_le", null);
  requeteSites = site_id ? requeteSites.eq("id", site_id) : requeteSites.eq("client_id", client_id!);
  const [{ data: sites }, feries, fmcId] = await Promise.all([requeteSites, joursFeries(supabase), intervenantFmcId(supabase)]);
  if (!sites || sites.length === 0) redirectWithError(retour, "Aucun site ouvert à planifier.");

  const ids = sites.map((s) => s.id);
  const [{ data: contrats }, { data: dernieres }, { data: client }] = await Promise.all([
    supabase.from("site_contrats").select("site_id, visites_par_an, sous_traitant_id").eq("lot", "clim").in("site_id", ids),
    supabase.from("interventions").select("site_id, date_realisee").eq("type_code", 1).in("site_id", ids).not("date_realisee", "is", null).order("date_realisee", { ascending: false }),
    client_id ? supabase.from("clients").select("legacy_id").eq("id", client_id).maybeSingle() : Promise.resolve({ data: null }),
  ]);
  const contratParSite = new Map((contrats ?? []).map((c) => [c.site_id, c]));
  const derniereParSite = new Map<number, string>();
  for (const d of dernieres ?? []) if (!derniereParSite.has(d.site_id)) derniereParSite.set(d.site_id, String(d.date_realisee));

  const anneePrecedente = new Date(`${dateDebut}T00:00:00Z`).getUTCFullYear() - 1;
  const lignes = [];
  const sitesSansVisites: string[] = [];
  let annulees = 0;
  for (const site of sites) {
    const contrat = contratParSite.get(site.id);
    const visites = contrat?.visites_par_an ?? site.visites_entretien_par_an;
    if (!visites || visites <= 0) {
      sitesSansVisites.push(site.nom ?? `#${site.id}`);
      continue;
    }
    const derniere = derniereParSite.get(site.id);
    const depart = derniere ? new Date(derniere) : new Date(Date.UTC(anneePrecedente, 11, 15));
    const pas = Math.max(1, Math.trunc(12 / visites));

    const { data: aAnnuler } = await supabase
      .from("interventions")
      .update({ statut_code: STATUT_ANNULE })
      .eq("site_id", site.id)
      .eq("type_code", 1)
      .eq("statut_code", STATUT_A_PLANIFIER)
      .not("date_prevue", "is", null)
      .is("date_realisee", null)
      .select("id");
    annulees += aAnnuler?.length ?? 0;

    for (const date of datesPrevues(depart, pas, fin, feries)) {
      lignes.push({
        site_id: site.id,
        type_code: 1,
        statut_code: site.ne_plus_intervenir ? STATUT_NE_PLUS_INTERVENIR : STATUT_A_PLANIFIER,
        date_prevue: date,
        intervenant_id: contrat?.sous_traitant_id ?? site.intervenant_id ?? fmcId,
        saisi_par_id: utilisateur.id,
      });
    }
  }
  if (lignes.length > 0) {
    const { error } = await supabase.from("interventions").insert(lignes);
    if (error) redirectWithError(retour, "La génération des dates prévues a échoué.");
  }

  const cible = site_id ? { table: "sites", id: site_id } : { table: "clients", id: client_id! };
  await enregistrerJournal(supabase, cible.table, cible.id, utilisateur.id, { action: "generation_dates_prevues", jusqu_au: date_fin, creees: lignes.length, annulees, sites: sites.length });
  revalidatePath("/interventions");
  revalidatePath("/planification");

  const avertissements = [];
  if (sitesSansVisites.length) avertissements.push(`sans nombre de visites : ${sitesSansVisites.slice(0, 5).join(", ")}${sitesSansVisites.length > 5 ? "…" : ""}`);
  if (client?.legacy_id && CLIENTS_LEGACY_CALENDRIER_FIXE.includes(client.legacy_id)) {
    avertissements.push("ce client avait un calendrier fixe dans Access (15 du mois) qui n'est pas repris : dates calculées avec la règle générale");
  }
  redirect(
    versPlanification(
      { client_id: clientId },
      {
        info: `Dates prévues : ${lignes.length} entretien(s) créé(s) sur ${sites.length - sitesSansVisites.length} site(s), ${annulees} prévu(s) non réalisé(s) annulé(s).`,
        ...(avertissements.length ? { avertissement: avertissements.join(" ; ") } : {}),
      },
    ),
  );
}
