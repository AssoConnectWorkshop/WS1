import ExcelJS from "exceljs";
import { createClient } from "@/lib/supabase/server";
import { toStringParams } from "@/lib/list-params";
import { appliquerFiltresInterventions } from "@/lib/interventions-filtres";
import { feuille, paginer, parLots, reponseClasseur } from "@/lib/excel";
import { exigerUtilisateur } from "@/lib/action-utils";
import { formatNom } from "@/lib/format";

export const dynamic = "force-dynamic";

/** Export de la liste d'interventions courante (mêmes filtres et colonnes que l'écran). */
export async function GET(request: Request) {
  const url = new URL(request.url);
  const sp = toStringParams(Object.fromEntries(url.searchParams));
  const zonesSel = url.searchParams.getAll("zones").filter(Boolean);
  const supabase = await createClient();
  const refus = await exigerUtilisateur(supabase);
  if (refus) return refus;

  const lignes = await paginer<Record<string, unknown> & { id: number }>((a, b) =>
    appliquerFiltresInterventions(
      supabase
        .from("v_interventions_liste")
        .select(
          "id, type_libelle, statut_libelle, client_nom, site_nom, numero_magasin, site_ville, date_limite, date_prevue, date_realisee, intervenant_nom, charge_affaire_nom, statut_facturation_libelle, reference_client, numero_bon, devis_a_faire, devis_fait, commentaire_interne",
        ),
      sp,
      zonesSel,
    )
      .order(sp.sort ?? "date_limite", { ascending: sp.dir === "asc" })
      .range(a, b),
  );

  const techniciens = new Map<number, string[]>();
  for (const lot of parLots(lignes.map((l) => l.id))) {
    const { data } = await supabase.from("intervention_techniciens").select("intervention_id, utilisateurs(nom, prenom)").in("intervention_id", lot);
    for (const t of (data ?? []) as unknown as { intervention_id: number; utilisateurs: { nom: string | null; prenom: string | null } | null }[]) {
      const nom = formatNom(t.utilisateurs?.prenom, t.utilisateurs?.nom);
      if (nom !== "—") techniciens.set(t.intervention_id, [...(techniciens.get(t.intervention_id) ?? []), nom]);
    }
  }

  const classeur = new ExcelJS.Workbook();
  const ws = feuille(classeur, "Interventions", [
    { header: "N°", key: "id" },
    { header: "Type", key: "type_libelle" },
    { header: "Statut", key: "statut_libelle" },
    { header: "Client", key: "client_nom", width: 28 },
    { header: "Site", key: "site_nom", width: 32 },
    { header: "N° magasin", key: "numero_magasin" },
    { header: "Ville", key: "site_ville" },
    { header: "Date limite", key: "date_limite" },
    { header: "Date prévue", key: "date_prevue" },
    { header: "Date réalisée", key: "date_realisee" },
    { header: "Intervenant", key: "intervenant_nom" },
    { header: "Techniciens", key: "techniciens", width: 28 },
    { header: "Chargé d'affaire", key: "charge_affaire_nom" },
    { header: "Statut facturation", key: "statut_facturation_libelle" },
    { header: "N° DI client", key: "reference_client" },
    { header: "N° bon", key: "numero_bon" },
    { header: "Devis", key: "devis" },
    { header: "Commentaire", key: "commentaire_interne", width: 40 },
  ]);
  for (const l of lignes) {
    ws.addRow({
      ...l,
      date_limite: l.date_limite ? String(l.date_limite).slice(0, 10) : null,
      date_prevue: l.date_prevue ? String(l.date_prevue).slice(0, 10) : null,
      date_realisee: l.date_realisee ? String(l.date_realisee).slice(0, 10) : null,
      techniciens: techniciens.get(l.id)?.join(", ") ?? null,
      devis: l.devis_fait ? "Fait" : l.devis_a_faire ? "À faire" : null,
    });
  }

  return reponseClasseur(classeur, `interventions_${new Date().toISOString().slice(0, 10)}.xlsx`);
}
