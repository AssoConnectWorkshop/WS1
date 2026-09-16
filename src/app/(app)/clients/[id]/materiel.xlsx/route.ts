import ExcelJS from "exceljs";
import { createClient } from "@/lib/supabase/server";
import { feuille, paginer, parLots, reponseClasseur } from "@/lib/excel";
import { exigerUtilisateur } from "@/lib/action-utils";

export const dynamic = "force-dynamic";

const COLONNES_TECHNIQUES = new Set(["created_at", "updated_at", "legacy_id", "fluide_id", "date_mise_en_service_brut", "intervention_id"]);

/** Export du parc matériel d'un client (Form_Filtre Extraction) : une ligne par équipement, sites sans matériel inclus. */
export async function GET(_request: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const refus = await exigerUtilisateur(supabase);
  if (refus) return refus;

  const { data: client } = await supabase.from("clients").select("nom").eq("id", id).maybeSingle();
  if (!client) return new Response("Client introuvable", { status: 404 });

  const sites = await paginer((a, b) =>
    supabase.from("sites").select("id, numero_magasin, code_client, nom, adresse, code_postal, ville").eq("client_id", id).is("supprime_le", null).order("nom").range(a, b),
  );
  const materiels: Record<string, unknown>[] = [];
  for (const lot of parLots(sites.map((s) => s.id))) {
    materiels.push(...(await paginer<Record<string, unknown>>((a, b) => supabase.from("site_materiels").select("*").in("site_id", lot).order("id").range(a, b))));
  }

  const colonnesMateriel = Object.keys(materiels[0] ?? { id: null, repere: null, marque: null, type_equipement: null, reference: null, numero_serie: null }).filter(
    (k) => !COLONNES_TECHNIQUES.has(k) && k !== "site_id",
  );
  const classeur = new ExcelJS.Workbook();
  const ws = feuille(classeur, "Matériel", [
    { header: "Client", key: "client", width: 24 },
    { header: "N° magasin", key: "numero_magasin" },
    { header: "Code site", key: "code_client" },
    { header: "Site", key: "site", width: 30 },
    { header: "Adresse", key: "adresse", width: 30 },
    { header: "Code postal", key: "code_postal" },
    { header: "Ville", key: "ville" },
    ...colonnesMateriel.map((k) => ({ header: k, key: `m_${k}` })),
  ]);

  for (const site of sites) {
    const lignes = materiels.filter((m) => m.site_id === site.id);
    const base = { client: client.nom, numero_magasin: site.numero_magasin, code_client: site.code_client, site: site.nom, adresse: site.adresse, code_postal: site.code_postal, ville: site.ville };
    if (lignes.length === 0) ws.addRow(base);
    for (const m of lignes) ws.addRow({ ...base, ...Object.fromEntries(colonnesMateriel.map((k) => [`m_${k}`, m[k]])) });
  }

  return reponseClasseur(classeur, `Materiel_${client.nom}.xlsx`);
}
