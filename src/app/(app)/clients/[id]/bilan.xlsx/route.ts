import ExcelJS from "exceljs";
import { createClient } from "@/lib/supabase/server";
import { toStringParams } from "@/lib/list-params";
import { feuille, nomFichierPeriode, paginer, parLots, reponseClasseur, somme } from "@/lib/excel";

export const dynamic = "force-dynamic";

type Intervention = {
  id: number;
  site_id: number;
  type_code: number | null;
  statut_code: number | null;
  heure_arrivee: string | null;
  heure_depart: string | null;
  montant_fmc: number | null;
  montant_sous_traitant: number | null;
};

function minutes(h: string | null) {
  if (!h) return null;
  const [hh, mm] = h.split(":").map(Number);
  return Number.isFinite(hh) && Number.isFinite(mm) ? hh * 60 + mm : null;
}

/** Heures = |départ − arrivée| × nombre de techniciens (au moins 1), en heures décimales (Form_00.CmdRechercher). */
function heures(i: Intervention, techniciens: number) {
  const a = minutes(i.heure_arrivee);
  const d = minutes(i.heure_depart);
  return a == null || d == null ? 0 : (Math.abs(d - a) * Math.max(1, techniciens)) / 60;
}

const ANNULE = 8;
const RESOLU_TELEPHONE = 10;

/** Export « Fabien » : bilan économique par site d'un client sur une période (analysis 04 §3.1, 28 colonnes).
 * Interventions filtrées sur la date réalisée, devis sur la date d'envoi ; compteur de devis refusés corrigé. */
export async function GET(request: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const sp = toStringParams(Object.fromEntries(new URL(request.url).searchParams));
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return new Response("Non autorisé", { status: 401 });

  const { data: client } = await supabase.from("clients").select("nom, tarif_heure_mo, tarif_deplacement").eq("id", id).maybeSingle();
  if (!client) return new Response("Client introuvable", { status: 404 });
  const coutHeure = Number(client.tarif_heure_mo ?? 0);
  const coutDepl = Number(client.tarif_deplacement ?? 0);

  const sites = await paginer((a, b) =>
    supabase.from("sites").select("id, nom, date_mise_en_service, visites_entretien_par_an").eq("client_id", id).is("supprime_le", null).order("nom").range(a, b),
  );
  const ids = sites.map((s) => s.id);
  if (ids.length === 0) return new Response("Aucun site pour ce client", { status: 404 });

  const [interventions, contrats, devis] = await Promise.all([
    paginer<Intervention>((a, b) => {
      let q = supabase
        .from("interventions")
        .select("id, site_id, type_code, statut_code, heure_arrivee, heure_depart, montant_fmc, montant_sous_traitant")
        .in("site_id", ids)
        .in("type_code", [1, 2, 3])
        .not("date_realisee", "is", null);
      if (sp.debut) q = q.gte("date_realisee", sp.debut);
      if (sp.fin) q = q.lte("date_realisee", `${sp.fin}T23:59:59`);
      return q.order("id").range(a, b);
    }),
    paginer((a, b) => supabase.from("site_contrats").select("site_id, redevance").eq("lot", "clim").in("site_id", ids).range(a, b)),
    paginer((a, b) => {
      let q = supabase.from("devis").select("site_id, famille, statut_code, montant_ht").in("site_id", ids).is("supprime_le", null);
      if (sp.debut) q = q.gte("date_envoi", sp.debut);
      if (sp.fin) q = q.lte("date_envoi", sp.fin);
      return q.order("id").range(a, b);
    }),
  ]);

  const techniciensParIntervention = new Map<number, number>();
  for (const lot of parLots(interventions.map((i) => i.id))) {
    const { data } = await supabase.from("intervention_techniciens").select("intervention_id").in("intervention_id", lot);
    for (const t of data ?? []) techniciensParIntervention.set(t.intervention_id, (techniciensParIntervention.get(t.intervention_id) ?? 0) + 1);
  }
  const redevanceParSite = new Map(contrats.map((c) => [c.site_id, Number(c.redevance ?? 0)]));

  const classeur = new ExcelJS.Workbook();
  const ws = feuille(classeur, "Bilan", [
    { header: "Site", key: "site", width: 32 },
    { header: "Mise en service", key: "mes" },
    { header: "Coût heure client", key: "coutHeure" },
    { header: "Coût déplacement client", key: "coutDepl" },
    { header: "Nb entretiens contractuels", key: "nbEntretiensContrat" },
    { header: "Redevance technique", key: "redevance" },
    { header: "Nb devis acceptés réalisés", key: "nbDevisAcc" },
    { header: "Heures devis acceptés", key: "hDevisAcc" },
    { header: "Sous-traitance devis acceptés", key: "stDevisAcc" },
    { header: "Montant devis acceptés", key: "mtDevisAcc" },
    { header: "Devis acceptés annulés", key: "devisAccAnnules" },
    { header: "Nb entretiens réalisés", key: "nbEntretiens" },
    { header: "Valeur entretiens", key: "valEntretiens" },
    { header: "Nb dépannages", key: "nbDepan" },
    { header: "Heures dépannage", key: "hDepan" },
    { header: "Sous-traitance dépannage", key: "stDepan" },
    { header: "Coût dépannage théorique", key: "coutDepan" },
    { header: "Montant FMC dépannage", key: "mtDepan" },
    { header: "Dépannages résolus par téléphone", key: "depanTel" },
    { header: "Dépannages annulés", key: "depanAnnules" },
    { header: "Devis SAV en attente (nb)", key: "savAttNb" },
    { header: "Devis SAV en attente (HT)", key: "savAttHt" },
    { header: "Devis SAV refusés (nb)", key: "savRefNb" },
    { header: "Devis SAV refusés (HT)", key: "savRefHt" },
    { header: "Devis travaux en attente (nb)", key: "trAttNb" },
    { header: "Devis travaux en attente (HT)", key: "trAttHt" },
    { header: "Devis travaux refusés (nb)", key: "trRefNb" },
    { header: "Devis travaux refusés (HT)", key: "trRefHt" },
  ]);
  ws.insertRow(1, [client.nom, "Du", sp.debut ?? "—", "au", sp.fin ?? "—"]);
  ws.getRow(1).font = { bold: true };

  for (const site of sites) {
    const inter = interventions.filter((i) => i.site_id === site.id);
    const dev = devis.filter((d) => d.site_id === site.id);
    if (inter.length === 0 && dev.length === 0) continue;

    const realisees = (type: number) => inter.filter((i) => i.type_code === type && i.statut_code !== ANNULE && i.statut_code !== RESOLU_TELEPHONE);
    const heuresDe = (liste: Intervention[]) => somme(liste.map((i) => heures(i, techniciensParIntervention.get(i.id) ?? 1)));
    const montants = (liste: Intervention[], cle: "montant_fmc" | "montant_sous_traitant") => somme(liste.map((i) => Number(i[cle] ?? 0)));
    const devisDe = (famille: string, statuts: number[]) => dev.filter((d) => d.famille === famille && statuts.includes(d.statut_code ?? -1));
    const ht = (liste: { montant_ht: number | null }[]) => somme(liste.map((d) => Number(d.montant_ht ?? 0)));

    const devisAcc = realisees(3);
    const depan = realisees(2);
    const entretiens = inter.filter((i) => i.type_code === 1 && i.statut_code !== ANNULE);
    const redevance = redevanceParSite.get(site.id) ?? 0;
    const hDepan = heuresDe(depan);

    ws.addRow({
      site: site.nom,
      mes: site.date_mise_en_service,
      coutHeure,
      coutDepl,
      nbEntretiensContrat: site.visites_entretien_par_an,
      redevance,
      nbDevisAcc: devisAcc.length,
      hDevisAcc: heuresDe(devisAcc),
      stDevisAcc: montants(devisAcc, "montant_sous_traitant"),
      mtDevisAcc: montants(devisAcc, "montant_fmc"),
      devisAccAnnules: inter.filter((i) => i.type_code === 3 && i.statut_code === ANNULE).length,
      nbEntretiens: entretiens.length,
      valEntretiens: somme([entretiens.length * redevance]),
      nbDepan: depan.length,
      hDepan,
      stDepan: montants(depan, "montant_sous_traitant"),
      coutDepan: somme([depan.length * coutDepl + coutHeure * hDepan]),
      mtDepan: montants(depan, "montant_fmc"),
      depanTel: inter.filter((i) => i.type_code === 2 && i.statut_code === RESOLU_TELEPHONE).length,
      depanAnnules: inter.filter((i) => i.type_code === 2 && i.statut_code === ANNULE).length,
      savAttNb: devisDe("sav", [2, 4]).length,
      savAttHt: ht(devisDe("sav", [2, 4])),
      savRefNb: devisDe("sav", [5]).length,
      savRefHt: ht(devisDe("sav", [5])),
      trAttNb: devisDe("travaux", [2, 4]).length,
      trAttHt: ht(devisDe("travaux", [2, 4])),
      trRefNb: devisDe("travaux", [5]).length,
      trRefHt: ht(devisDe("travaux", [5])),
    });
  }

  return reponseClasseur(classeur, nomFichierPeriode(client.nom, sp.debut, sp.fin));
}
