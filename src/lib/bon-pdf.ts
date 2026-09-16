import "server-only";
import { PDFDocument, StandardFonts, rgb, type PDFFont, type PDFImage, type PDFPage } from "pdf-lib";
import type { SupabaseClient } from "@supabase/supabase-js";
import { formatDate, formatTime, oui } from "@/lib/format";

const PAGE = { largeur: 595.28, hauteur: 841.89 };
const MARGE = 40;
const LARGEUR_TEXTE = PAGE.largeur - 2 * MARGE;

/** Les polices standard PDF n'encodent que WinAnsi : le reste devient « ? ». */
function ansi(texte: string) {
  return texte.replace(/\r/g, "").replace(/[^\x00-\xFF€—–’‘“”…•œŒ]/g, "?");
}

function minutesIntervalle(intervalle: string | null): number | null {
  if (!intervalle) return null;
  const m = /^(?:(\d+) days? )?(\d{1,3}):(\d{2})/.exec(intervalle);
  return m ? Number(m[1] ?? 0) * 1440 + Number(m[2]) * 60 + Number(m[3]) : null;
}

function minutesHeure(heure: string | null): number | null {
  if (!heure) return null;
  const [h, mn] = heure.split(":").map(Number);
  return Number.isFinite(h) && Number.isFinite(mn) ? h * 60 + mn : null;
}

function duree(minutes: number | null) {
  if (minutes == null) return "—";
  return `${Math.floor(minutes / 60)} h ${String(minutes % 60).padStart(2, "0")}`;
}

class Redacteur {
  page: PDFPage;
  y: number;

  constructor(
    private doc: PDFDocument,
    private normale: PDFFont,
    private grasse: PDFFont,
  ) {
    this.page = doc.addPage([PAGE.largeur, PAGE.hauteur]);
    this.y = PAGE.hauteur - MARGE;
  }

  private sauterSiBesoin(hauteur: number) {
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

  espace(h = 8) {
    this.y -= h;
  }

  image(img: PDFImage, { x, largeurMax, hauteurMax }: { x: number; largeurMax: number; hauteurMax: number }) {
    const echelle = Math.min(largeurMax / img.width, hauteurMax / img.height, 1);
    const w = img.width * echelle;
    const h = img.height * echelle;
    this.sauterSiBesoin(h);
    this.page.drawImage(img, { x, y: this.y - h, width: w, height: h });
    this.y -= h + 4;
  }
}

async function embarquer(doc: PDFDocument, octets: Uint8Array | null): Promise<PDFImage | null> {
  if (!octets || octets.length < 8) return null;
  try {
    const png = octets[0] === 0x89 && octets[1] === 0x50;
    return png ? await doc.embedPng(octets) : await doc.embedJpg(octets);
  } catch {
    return null;
  }
}

async function telecharger(url: string | null): Promise<Uint8Array | null> {
  if (!url || !/^https?:\/\//i.test(url)) return null;
  try {
    const res = await fetch(url);
    return res.ok ? new Uint8Array(await res.arrayBuffer()) : null;
  } catch {
    return null;
  }
}

async function logoStorage(admin: SupabaseClient | null, nom: string): Promise<Uint8Array | null> {
  if (!admin) return null;
  for (const ext of ["png", "jpg"]) {
    const { data } = await admin.storage.from("logos").download(`${nom}.${ext}`);
    if (data) return new Uint8Array(await data.arrayBuffer());
  }
  return null;
}

export type Bon = { octets: Uint8Array; nomFichier: string; annee: number };

/** Rapport d'intervention (état Access « FicheIntervention », analysis 02 §9). */
export async function genererBonPdf(supabase: SupabaseClient, admin: SupabaseClient | null, interventionId: number): Promise<Bon | null> {
  const { data: intervention } = await supabase.from("interventions").select("*").eq("id", interventionId).maybeSingle();
  if (!intervention) return null;

  const [{ data: site }, { data: type }, { data: techniciens }] = await Promise.all([
    supabase.from("sites").select("nom, numero_magasin, code_client, adresse, code_postal, ville, client_id, donneur_ordre_id").eq("id", intervention.site_id).maybeSingle(),
    intervention.type_code != null ? supabase.from("types_intervention").select("libelle").eq("code", intervention.type_code).maybeSingle() : Promise.resolve({ data: null }),
    supabase.from("intervention_techniciens").select("utilisateurs(nom, prenom)").eq("intervention_id", interventionId),
  ]);
  const [{ data: client }, { data: donneur }] = await Promise.all([
    site ? supabase.from("clients").select("nom").eq("id", site.client_id).maybeSingle() : Promise.resolve({ data: null }),
    site?.donneur_ordre_id ? supabase.from("donneurs_ordre").select("id, nom").eq("id", site.donneur_ordre_id).maybeSingle() : Promise.resolve({ data: null }),
  ]);

  const doc = await PDFDocument.create();
  const [normale, grasse] = await Promise.all([doc.embedFont(StandardFonts.Helvetica), doc.embedFont(StandardFonts.HelveticaBold)]);
  const r = new Redacteur(doc, normale, grasse);

  const logo = await embarquer(doc, (donneur ? await logoStorage(admin, `donneur-${donneur.id}`) : null) ?? (await logoStorage(admin, "fmc")));
  if (logo) r.image(logo, { x: MARGE, largeurMax: 160, hauteurMax: 60 });
  else r.ligne("FMC Maintenance · 2 rue Galilée · 33185 Le Haillan", { taille: 9 });
  r.espace(4);

  const numero = intervention.legacy_id ?? intervention.id;
  r.ligne(`RAPPORT D'INTERVENTION N° ${numero}`, { taille: 15, gras: true });
  r.espace(4);
  r.champ("N° Site", [site?.numero_magasin, site?.code_client].filter(Boolean).join(" · ") || null);
  r.champ("Date", formatDate(intervention.date_realisee ?? intervention.date_prevue ?? intervention.date_demande));
  r.champ("Client", client?.nom);
  r.champ("Site", site?.nom);
  r.champ("Adresse", [site?.adresse, site?.code_postal, site?.ville].filter(Boolean).join(" ") || null);
  r.champ("Type d'intervention", type?.libelle ?? intervention.type_brut);
  if (intervention.reference_client) r.champ("N° DI client", intervention.reference_client);
  if (intervention.numero_devis_accepte) r.champ("Devis accepté", intervention.numero_devis_accepte);

  if (!intervention.masquer_heures_sur_bon) {
    const aller = minutesIntervalle(intervention.temps_aller);
    const retour = minutesIntervalle(intervention.temps_retour);
    r.titre("Temps de trajet");
    r.champ("Aller", duree(aller));
    r.champ("Retour", duree(retour));
    r.champ("Total", duree(aller == null && retour == null ? null : (aller ?? 0) + (retour ?? 0)));

    const arrivee = minutesHeure(intervention.heure_arrivee);
    const depart = minutesHeure(intervention.heure_depart);
    r.titre("Temps sur site");
    r.champ("Arrivée", formatTime(intervention.heure_arrivee));
    r.champ("Départ", formatTime(intervention.heure_depart));
    r.champ("Durée", duree(arrivee != null && depart != null ? Math.max(0, depart - arrivee) : null));
  }

  r.titre("Intervention");
  r.champ("Nombre de techniciens", intervention.nombre_techniciens);
  r.champ("Mise à jour du registre de sécurité", oui(intervention.registre_securite_mis_a_jour));
  r.espace(4);
  r.ligne("Prestations effectuées", { gras: true });
  r.ligne(intervention.prestations_realisees ?? "—");
  r.espace(4);
  r.ligne("À prévoir / reste à faire", { gras: true });
  r.ligne(intervention.commentaire_cloture_panne ?? "—");
  r.espace(4);
  r.ligne("Commentaire", { gras: true });
  r.ligne(intervention.commentaire_technicien ?? "—");

  r.titre("Cachet et signature du client");
  r.champ("Nom", intervention.signature_client_nom ?? intervention.signature_site_nom);
  const signatureClient = await embarquer(doc, await telecharger(intervention.signature_client_image ?? intervention.signature_site_image));
  if (signatureClient) r.image(signatureClient, { x: MARGE, largeurMax: 200, hauteurMax: 80 });

  r.titre("Nom et signature des techniciens");
  const noms = (techniciens as unknown as { utilisateurs: { nom: string | null; prenom: string | null } | null }[] | null)
    ?.map((t) => [t.utilisateurs?.prenom, t.utilisateurs?.nom].filter(Boolean).join(" "))
    .filter(Boolean);
  r.champ("Techniciens", noms?.length ? noms.join(", ") : (intervention.noms_techniciens ?? intervention.signature_technicien_nom));
  const signatureTechnicien = await embarquer(doc, await telecharger(intervention.signature_technicien_image));
  if (signatureTechnicien) r.image(signatureTechnicien, { x: MARGE, largeurMax: 200, hauteurMax: 80 });

  r.espace(10);
  r.ligne("Les mentions à remplir ci-dessus sont obligatoires.", { taille: 8 });

  const dateBon = new Date(intervention.date_realisee ?? intervention.date_demande ?? Date.now());
  const selon = intervention.type_code === 3 ? intervention.numero_devis_accepte : intervention.reference_client;
  const nomFichier = `${formatDate(dateBon).replace(/\//g, ".")}${selon ? ` (Selon ${selon})` : ""}.pdf`.replace(/[\\/:*?"<>|]/g, "_");
  return { octets: await doc.save(), nomFichier, annee: dateBon.getUTCFullYear() };
}
