import "server-only";
import ExcelJS from "exceljs";

export type Colonne = { header: string; key: string; width?: number };

export function feuille(classeur: ExcelJS.Workbook, nom: string, colonnes: Colonne[]) {
  const ws = classeur.addWorksheet(nom.slice(0, 31));
  ws.columns = colonnes.map((c) => ({ ...c, width: c.width ?? Math.max(12, Math.min(40, c.header.length + 2)) }));
  ws.getRow(1).font = { bold: true };
  ws.views = [{ state: "frozen", ySplit: 1 }];
  return ws;
}

export async function reponseClasseur(classeur: ExcelJS.Workbook, nomFichier: string) {
  const octets = await classeur.xlsx.writeBuffer();
  return new Response(Buffer.from(octets as ArrayBuffer), {
    headers: {
      "Content-Type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "Content-Disposition": `attachment; filename="${encodeURIComponent(nomFichier.replace(/[\\/:*?"<>|]/g, "_"))}"`,
      "Cache-Control": "no-store",
    },
  });
}

/** PostgREST plafonne chaque requête (1 000 lignes par défaut) : lecture par pages. */
export async function paginer<T>(page: (debut: number, fin: number) => PromiseLike<{ data: T[] | null }>, taille = 1000): Promise<T[]> {
  const lignes: T[] = [];
  for (let debut = 0; ; debut += taille) {
    const { data } = await page(debut, debut + taille - 1);
    if (!data || data.length === 0) break;
    lignes.push(...data);
    if (data.length < taille) break;
  }
  return lignes;
}

export function nomFichierPeriode(base: string, debut?: string, fin?: string) {
  const j = (d: string) => d.split("-").reverse().join("_");
  const periode = debut && fin ? `_DU_${j(debut)}_AU_${j(fin)}` : debut ? `_DEPUIS_${j(debut)}` : fin ? `_JUSQU_A_${j(fin)}` : "";
  return `${base.replace(/[^\w\-]+/g, "_")}${periode}.xlsx`;
}

export const somme = (xs: number[]) => Math.round(xs.reduce((s, x) => s + x, 0) * 100) / 100;

/** Découpe une liste d'identifiants pour les filtres `in(...)` (longueur d'URL PostgREST). */
export function parLots<T>(valeurs: T[], taille = 300): T[][] {
  const lots: T[][] = [];
  for (let i = 0; i < valeurs.length; i += taille) lots.push(valeurs.slice(i, i + taille));
  return lots;
}

/** Utilisateur connecté ou réponse 401, pour les routes d'export. */
export async function exigerUtilisateur(supabase: { auth: { getUser: () => Promise<{ data: { user: unknown | null } }> } }) {
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return user ? null : new Response("Non autorisé", { status: 401 });
}
