import "server-only";
import type { SupabaseClient } from "@supabase/supabase-js";
import { rgb, type PDFImage } from "pdf-lib";
import { formatDate, formatNom, formatTime } from "@/lib/format";
import { MARGE, PAGE, Redacteur, logoStorage, nomFichierSur, telecharger } from "@/lib/pdf";

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

  const r = await Redacteur.creer();
  const LARGEUR = PAGE.largeur - 2 * MARGE;
  const DROITE = PAGE.largeur - MARGE;
  const P = 6;

  const [logo, cachet, signatureClient, signatureTechnicien] = await Promise.all([
    r.embarquer((donneur ? await logoStorage(admin, `donneur-${donneur.id}`) : null) ?? (await logoStorage(admin, "fmc"))),
    r.embarquer(await telecharger(intervention.signature_site_image)),
    r.embarquer(await telecharger(intervention.signature_client_image)),
    r.embarquer(await telecharger(intervention.signature_technicien_image)),
  ]);

  // En-tête : logo à gauche, activité à droite (Report_2).
  const hautEntete = r.y;
  if (logo) r.image(logo, { x: MARGE, largeurMax: 140, hauteurMax: 50 });
  else r.ligne("FMC Maintenance", { taille: 12, gras: true });
  r.texteA("Installation - Dépannage", DROITE, hautEntete - 12, { taille: 9, alignement: "droite" });
  r.texteA("Climatisation - Ventilation", DROITE, hautEntete - 24, { taille: 9, alignement: "droite" });
  r.y = Math.min(r.y, hautEntete - 54);

  r.cadre(null, () => r.centre("RAPPORT D'INTERVENTION", { taille: 16, gras: true }), { reserve: 40 });

  // Bloc d'identification : client / site à gauche, numéros et date à droite.
  const hautIdent = r.y;
  const colDroite = MARGE + LARGEUR * 0.62;
  r.espace(2);
  r.ligne(`CLIENT / SITE :   ${[client?.nom, site?.nom].filter(Boolean).join(" / ") || "—"}`, { taille: 9, largeur: LARGEUR * 0.58 });
  r.ligne(`ADRESSE :   ${[site?.adresse, site?.code_postal, site?.ville].filter(Boolean).join(" ") || "—"}`, { taille: 9, largeur: LARGEUR * 0.58 });
  if (intervention.reference_client) r.ligne(`N° DI client :   ${intervention.reference_client}`, { taille: 9, largeur: LARGEUR * 0.58 });
  if (intervention.numero_devis_accepte) r.ligne(`Devis accepté :   ${intervention.numero_devis_accepte}`, { taille: 9, largeur: LARGEUR * 0.58 });
  r.texteA(`Fiche d'intervention N° :   ${intervention.legacy_id ?? intervention.id}`, colDroite, hautIdent - 11, { taille: 9 });
  r.texteA(`N° Site :   ${[site?.numero_magasin, site?.code_client].filter(Boolean).join(" · ") || "—"}`, colDroite, hautIdent - 24, { taille: 9 });
  r.texteA(`Date :   ${formatDate(intervention.date_realisee ?? intervention.date_prevue ?? intervention.date_demande)}`, colDroite, hautIdent - 37, { taille: 9 });
  r.y = Math.min(r.y, hautIdent - 44);
  r.espace(4);

  const masquer = intervention.masquer_heures_sur_bon;
  const aller = minutesIntervalle(intervention.temps_aller);
  const retour = minutesIntervalle(intervention.temps_retour);
  const arrivee = minutesHeure(intervention.heure_arrivee);
  const depart = minutesHeure(intervention.heure_depart);
  const troisColonnes = (valeurs: [string, string][]) => {
    const y = r.y - 9;
    valeurs.forEach(([label, v], i) => r.texteA(`${label} : ${v}`, MARGE + P + (i * (LARGEUR - 2 * P)) / 3, y, { taille: 9 }));
    r.y -= 14;
  };

  r.cadre("Temps de trajet", () => {
    if (masquer) return;
    troisColonnes([["Aller", duree(aller)], ["Retour", duree(retour)], ["Total", duree(aller == null && retour == null ? null : (aller ?? 0) + (retour ?? 0))]]);
  }, { hauteurMin: 34 });

  r.cadre("Temps sur site", () => {
    if (!masquer) troisColonnes([["Arrivée", formatTime(intervention.heure_arrivee)], ["Départ", formatTime(intervention.heure_depart)], ["Durée", duree(arrivee != null && depart != null ? Math.max(0, depart - arrivee) : null)]]);
    r.texteA(`NBR TECHNICIENS :   ${intervention.nombre_techniciens ?? "—"}`, DROITE - P, r.y - 9, { taille: 9, gras: true, alignement: "droite" });
    r.y -= 14;
  }, { hauteurMin: 34 });

  r.cadre("Type d'intervention", () => r.centre(type?.libelle ?? intervention.type_brut ?? "—", { taille: 9 }));

  r.cadre("Mise à jour du registre de sécurité", () => {
    const y = r.y - 9;
    const fait = intervention.registre_securite_mis_a_jour === true;
    r.caseA(fait, MARGE + P, y);
    r.texteA("OUI", MARGE + P + 12, y, { taille: 9 });
    r.caseA(!fait, MARGE + P + 60, y);
    r.texteA("NON", MARGE + P + 72, y, { taille: 9 });
    r.y -= 14;
  });

  r.cadre("Prestations effectuées", () => r.ligne(intervention.prestations_realisees ?? "", { taille: 9, x: MARGE + P, largeur: LARGEUR - 2 * P }), { hauteurMin: 130, reserve: 130 });
  r.cadre("À prévoir / reste à faire", () => r.ligne(intervention.commentaire_cloture_panne ?? "", { taille: 9, x: MARGE + P, largeur: LARGEUR - 2 * P }), { hauteurMin: 70, reserve: 70 });
  r.cadre("Commentaire", () => r.ligne(intervention.commentaire_technicien ?? "", { taille: 9, x: MARGE + P, largeur: LARGEUR - 2 * P }), { hauteurMin: 50, reserve: 50 });

  // Quatre cases de signature (Report_2), précédées de la mention obligatoire.
  const noms = (techniciens as unknown as { utilisateurs: { nom: string | null; prenom: string | null } | null }[] | null)
    ?.map((t) => formatNom(t.utilisateurs?.prenom, t.utilisateurs?.nom))
    .filter((n) => n !== "—");
  const nomsTechniciens = noms?.length ? noms.join(", ") : (intervention.noms_techniciens ?? intervention.signature_technicien_nom ?? "");
  const HAUTEUR_SIGN = 78;
  r.sauterSiBesoin(HAUTEUR_SIGN + 30);
  r.centre("LES MENTIONS A REMPLIR CI-DESSOUS SONT OBLIGATOIRES", { taille: 8, gras: true });
  const hautSign = r.y;
  const largeurCase = LARGEUR / 4;
  const cases: [string, PDFImage | null, string | null][] = [
    ["CACHET DU CLIENT", cachet, null],
    ["NOM DU CLIENT", null, intervention.signature_client_nom ?? intervention.signature_site_nom],
    ["SIGNATURE CLIENT", signatureClient, null],
    ["NOM ET SIGNATURE DES TECHNICIENS", signatureTechnicien, nomsTechniciens],
  ];
  cases.forEach(([titre, img, texte], i) => {
    const x = MARGE + i * largeurCase;
    r.rectangle(x, hautSign - HAUTEUR_SIGN, largeurCase, HAUTEUR_SIGN);
    r.texteA(titre, x + largeurCase / 2, hautSign - 10, { taille: 6.5, gras: true, alignement: "centre" });
    r.page.drawLine({ start: { x: x + 4, y: hautSign - 13 }, end: { x: x + largeurCase - 4, y: hautSign - 13 }, thickness: 0.4, color: rgb(0.1, 0.1, 0.1) });
    let yTexte = hautSign - 24;
    if (texte) {
      r.texteA(texte.slice(0, 40), x + 4, yTexte, { taille: 7.5 });
      yTexte -= 6;
    }
    if (img) {
      const zone = yTexte - (hautSign - HAUTEUR_SIGN) - 4;
      const echelle = Math.min((largeurCase - 8) / img.width, zone / img.height, 1);
      r.page.drawImage(img, { x: x + 4, y: hautSign - HAUTEUR_SIGN + 3, width: img.width * echelle, height: img.height * echelle });
    }
  });
  r.y = hautSign - HAUTEUR_SIGN;

  r.piedDePage(["FMC Maintenance", "Siège social : 2 rue Galilée - 33185 Le Haillan", "Document confidentiel - propriété exclusive de FMC Climatisation"]);

  const dateBon = new Date(intervention.date_realisee ?? intervention.date_demande ?? Date.now());
  const selon = intervention.type_code === 3 ? intervention.numero_devis_accepte : intervention.reference_client;
  const nomFichier = nomFichierSur(`${formatDate(dateBon).replace(/\//g, ".")}${selon ? ` (Selon ${selon})` : ""}.pdf`);
  return { octets: await r.sauvegarder(), nomFichier, annee: dateBon.getUTCFullYear() };
}
