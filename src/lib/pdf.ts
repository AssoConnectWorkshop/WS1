import "server-only";
import { PDFDocument, StandardFonts, rgb, type PDFFont, type PDFImage, type PDFPage } from "pdf-lib";
import type { SupabaseClient } from "@supabase/supabase-js";

export const PAGE = { largeur: 595.28, hauteur: 841.89 };
export const MARGE = 40;
const LARGEUR_TEXTE = PAGE.largeur - 2 * MARGE;

/** Les polices standard PDF n'encodent que WinAnsi : le reste devient « ? ». */
export function ansi(texte: string) {
  return texte.replace(/\r/g, "").replace(/[^\x00-\xFF€—–’‘“”…•œŒ]/g, "?");
}

/** Écriture séquentielle de haut en bas, avec retour à la ligne et saut de page automatiques. */
export class Redacteur {
  page: PDFPage;
  y: number;

  private constructor(
    readonly doc: PDFDocument,
    private normale: PDFFont,
    private grasse: PDFFont,
  ) {
    this.page = doc.addPage([PAGE.largeur, PAGE.hauteur]);
    this.y = PAGE.hauteur - MARGE;
  }

  static async creer() {
    const doc = await PDFDocument.create();
    const [normale, grasse] = await Promise.all([doc.embedFont(StandardFonts.Helvetica), doc.embedFont(StandardFonts.HelveticaBold)]);
    return new Redacteur(doc, normale, grasse);
  }

  sauterSiBesoin(hauteur: number) {
    if (this.y - hauteur < MARGE) {
      this.page = this.doc.addPage([PAGE.largeur, PAGE.hauteur]);
      this.y = PAGE.hauteur - MARGE;
    }
  }

  ligne(texte: string, { taille = 10, gras = false, x = MARGE, largeur = LARGEUR_TEXTE }: { taille?: number; gras?: boolean; x?: number; largeur?: number } = {}) {
    const police = gras ? this.grasse : this.normale;
    for (const paragraphe of ansi(texte).split("\n")) {
      let courante = "";
      for (const mot of paragraphe.split(/\s+/)) {
        const essai = courante ? `${courante} ${mot}` : mot;
        if (police.widthOfTextAtSize(essai, taille) > largeur && courante) {
          this.dessiner(courante, police, taille, x);
          courante = mot;
        } else {
          courante = essai;
        }
      }
      this.dessiner(courante, police, taille, x);
    }
  }

  private dessiner(texte: string, police: PDFFont, taille: number, x: number) {
    this.sauterSiBesoin(taille + 4);
    this.page.drawText(texte, { x, y: this.y - taille, size: taille, font: police, color: rgb(0.1, 0.1, 0.1) });
    this.y -= taille + 4;
  }

  titre(texte: string) {
    this.espace(6);
    this.ligne(texte.toUpperCase(), { taille: 10.5, gras: true });
    this.page.drawLine({ start: { x: MARGE, y: this.y + 1 }, end: { x: PAGE.largeur - MARGE, y: this.y + 1 }, thickness: 0.5, color: rgb(0.6, 0.6, 0.6) });
    this.espace(4);
  }

  champ(label: string, valeur: string | number | null | undefined) {
    const v = valeur == null || valeur === "" ? "—" : String(valeur);
    this.ligne(`${label} : ${v}`);
  }

  case(coche: boolean, texte: string) {
    this.ligne(`${coche ? "[X]" : "[ ]"} ${texte}`);
  }

  espace(h = 8) {
    this.y -= h;
  }

  /** Texte posé à une position absolue, sans faire avancer le curseur. */
  texteA(texte: string, x: number, y: number, { taille = 10, gras = false, alignement = "gauche" }: { taille?: number; gras?: boolean; alignement?: "gauche" | "centre" | "droite" } = {}) {
    const police = gras ? this.grasse : this.normale;
    const t = ansi(texte);
    const w = police.widthOfTextAtSize(t, taille);
    const xr = alignement === "centre" ? x - w / 2 : alignement === "droite" ? x - w : x;
    this.page.drawText(t, { x: xr, y, size: taille, font: police, color: rgb(0.1, 0.1, 0.1) });
  }

  /** Ligne centrée sur la largeur utile, qui fait avancer le curseur. */
  centre(texte: string, { taille = 10, gras = false, souligne = false }: { taille?: number; gras?: boolean; souligne?: boolean } = {}) {
    this.sauterSiBesoin(taille + 4);
    const police = gras ? this.grasse : this.normale;
    const t = ansi(texte);
    const w = police.widthOfTextAtSize(t, taille);
    const x = PAGE.largeur / 2 - w / 2;
    this.page.drawText(t, { x, y: this.y - taille, size: taille, font: police, color: rgb(0.1, 0.1, 0.1) });
    if (souligne) this.page.drawLine({ start: { x, y: this.y - taille - 1.5 }, end: { x: x + w, y: this.y - taille - 1.5 }, thickness: 0.6, color: rgb(0.1, 0.1, 0.1) });
    this.y -= taille + 4;
  }

  rectangle(x: number, y: number, largeur: number, hauteur: number, epaisseur = 0.8) {
    this.page.drawRectangle({ x, y, width: largeur, height: hauteur, borderWidth: epaisseur, borderColor: rgb(0.1, 0.1, 0.1) });
  }

  /** Case à cocher dessinée (les polices standard n'ont pas de ☑). */
  caseA(coche: boolean, x: number, y: number, taille = 8) {
    this.rectangle(x, y, taille, taille, 0.6);
    if (coche) {
      this.page.drawLine({ start: { x: x + 1.5, y: y + 1.5 }, end: { x: x + taille - 1.5, y: y + taille - 1.5 }, thickness: 1, color: rgb(0.1, 0.1, 0.1) });
      this.page.drawLine({ start: { x: x + 1.5, y: y + taille - 1.5 }, end: { x: x + taille - 1.5, y: y + 1.5 }, thickness: 1, color: rgb(0.1, 0.1, 0.1) });
    }
  }

  /**
   * Cadre de l'état Access : titre centré souligné, contenu, puis rectangle sur toute la largeur.
   * Le contenu ne doit pas changer de page (hauteur minimale réservée avant de commencer).
   */
  cadre(titre: string | null, contenu: () => void, { hauteurMin = 0, reserve = 60 }: { hauteurMin?: number; reserve?: number } = {}) {
    this.sauterSiBesoin(Math.max(hauteurMin, reserve));
    const haut = this.y;
    this.espace(4);
    if (titre) this.centre(titre.toUpperCase(), { taille: 9, gras: true, souligne: true });
    contenu();
    this.espace(4);
    if (haut - this.y < hauteurMin) this.y = haut - hauteurMin;
    this.rectangle(MARGE, this.y, LARGEUR_TEXTE, haut - this.y);
    this.espace(3);
  }

  piedDePage(lignes: string[]) {
    let y = MARGE - 6;
    for (const l of [...lignes].reverse()) {
      this.texteA(l, PAGE.largeur / 2, y, { taille: 7.5, alignement: "centre" });
      y += 9;
    }
  }

  image(img: PDFImage, { x, largeurMax, hauteurMax }: { x: number; largeurMax: number; hauteurMax: number }) {
    const echelle = Math.min(largeurMax / img.width, hauteurMax / img.height, 1);
    const w = img.width * echelle;
    const h = img.height * echelle;
    this.sauterSiBesoin(h);
    this.page.drawImage(img, { x, y: this.y - h, width: w, height: h });
    this.y -= h + 4;
  }

  async embarquer(octets: Uint8Array | null): Promise<PDFImage | null> {
    if (!octets || octets.length < 8) return null;
    try {
      const png = octets[0] === 0x89 && octets[1] === 0x50;
      return png ? await this.doc.embedPng(octets) : await this.doc.embedJpg(octets);
    } catch {
      return null;
    }
  }

  sauvegarder() {
    return this.doc.save();
  }
}

export async function telecharger(url: string | null | undefined): Promise<Uint8Array | null> {
  if (!url || !/^https?:\/\//i.test(url)) return null;
  try {
    const res = await fetch(url);
    return res.ok ? new Uint8Array(await res.arrayBuffer()) : null;
  } catch {
    return null;
  }
}

/** Image du bucket `logos` (png puis jpg), null si absente ou sans client service role. */
export async function logoStorage(admin: SupabaseClient | null, nom: string): Promise<Uint8Array | null> {
  if (!admin) return null;
  for (const ext of ["png", "jpg"]) {
    const { data } = await admin.storage.from("logos").download(`${nom}.${ext}`);
    if (data) return new Uint8Array(await data.arrayBuffer());
  }
  return null;
}

export function nomFichierSur(nom: string) {
  return nom.replace(/[\\/:*?"<>|]/g, "_");
}

export async function chargerParametres(supabase: SupabaseClient) {
  const { data } = await supabase.from("parametres_application").select("cle, valeur");
  return Object.fromEntries((data ?? []).map((p) => [p.cle as string, p.valeur as string | null])) as Record<string, string | null | undefined>;
}
