import ExcelJS from "exceljs";
import { createClient } from "@/lib/supabase/server";
import { feuille, paginer, parLots, reponseClasseur, somme } from "@/lib/excel";
import { exigerUtilisateur } from "@/lib/action-utils";

export const dynamic = "force-dynamic";

type Ligne = { site_id: number; type_code: number | null; statut_code: number | null; sous_type_code: number | null; date_limite: string | null; montant_fmc: number | null };

const MOIS = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"];

/** Export « Pierre » (analysis 04 §3.2-3.3) : quantité et montant FMC par site, période sur la date limite ;
 * option par mois (une feuille par mois de l'année) ; option par motif de nom de site (somme des sites correspondants). */
export async function GET(request: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const url = new URL(request.url);
  const q = url.searchParams;
  const supabase = await createClient();
  const refus = await exigerUtilisateur(supabase);
  if (refus) return refus;

  const { data: client } = await supabase.from("clients").select("nom").eq("id", id).maybeSingle();
  if (!client) return new Response("Client introuvable", { status: 404 });

  const annee = Number(q.get("annee")) || null;
  const mois = Number(q.get("mois")) || 0;
  const debut = annee ? `${annee}-01-01` : q.get("debut") || null;
  const fin = annee ? `${annee}-12-31` : q.get("fin") || null;
  const types = q.getAll("types").filter(Boolean).map(Number);
  const statuts = q.getAll("statuts").filter(Boolean).map(Number);
  const natures = q.getAll("natures").filter(Boolean).map(Number);
  const motifs = [1, 2, 3, 4].map((n) => q.get(`nom${n}`)?.trim()).filter((m): m is string => !!m);

  const sites = await paginer((a, b) => supabase.from("sites").select("id, nom").eq("client_id", id).is("supprime_le", null).order("nom").range(a, b));
  const lignes: Ligne[] = [];
  for (const lot of parLots(sites.map((s) => s.id))) {
    lignes.push(
      ...(await paginer<Ligne>((a, b) => {
        let req = supabase.from("interventions").select("site_id, type_code, statut_code, sous_type_code, date_limite, montant_fmc").in("site_id", lot);
        if (debut) req = req.gte("date_limite", debut);
        if (fin) req = req.lte("date_limite", `${fin}T23:59:59`);
        if (types.length) req = req.in("type_code", types);
        if (statuts.length) req = req.in("statut_code", statuts);
        if (natures.length) req = req.in("sous_type_code", natures);
        return req.order("id").range(a, b);
      })),
    );
  }

  const classeur = new ExcelJS.Workbook();
  const ajouterFeuille = (nom: string, selection: Ligne[], periode: string) => {
    const ws = feuille(classeur, nom, [
      { header: motifs.length ? "Motif de nom de site" : "Site", key: "libelle", width: 36 },
      { header: "Quantité", key: "quantite" },
      { header: "Montant FMC", key: "montant" },
    ]);
    ws.insertRow(1, [client.nom, periode, types.length ? `Types ${types.join(", ")}` : "Tous types", statuts.length ? `Statuts ${statuts.join(", ")}` : "Tous statuts"]);
    ws.getRow(1).font = { bold: true };
    const groupes = motifs.length
      ? motifs.map((m) => ({ libelle: m, ids: sites.filter((s) => (s.nom ?? "").toLowerCase().includes(m.toLowerCase())).map((s) => s.id) }))
      : sites.map((s) => ({ libelle: s.nom ?? `#${s.id}`, ids: [s.id] }));
    for (const g of groupes) {
      const l = selection.filter((x) => g.ids.includes(x.site_id));
      ws.addRow({ libelle: g.libelle, quantite: l.length, montant: somme(l.map((x) => Number(x.montant_fmc ?? 0))) });
    }
  };

  if (annee && mois === 0 && q.get("par_mois") === "1") {
    for (let m = 1; m <= 12; m++) {
      ajouterFeuille(MOIS[m - 1], lignes.filter((l) => l.date_limite && new Date(l.date_limite).getUTCMonth() + 1 === m), `${MOIS[m - 1]} ${annee}`);
    }
  } else if (annee && mois > 0) {
    ajouterFeuille(MOIS[mois - 1], lignes.filter((l) => l.date_limite && new Date(l.date_limite).getUTCMonth() + 1 === mois), `${MOIS[mois - 1]} ${annee}`);
  } else {
    ajouterFeuille("Comptage", lignes, annee ? `Année ${annee}` : debut || fin ? `Du ${debut ?? "—"} au ${fin ?? "—"}` : "Tout l'historique");
  }

  return reponseClasseur(classeur, `${client.nom}${annee ? `_${annee}` : ""}.xlsx`);
}
