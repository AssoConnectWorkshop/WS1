#!/usr/bin/env node
/**
 * Étape 6.8 — Documents vers Storage (à exécuter sur le PC de l'utilisateur, avec accès au serveur de fichiers).
 *
 *   cd scripts/migrate-documents && npm install
 *   set SUPABASE_URL=https://<projet>.supabase.co
 *   set SUPABASE_SERVICE_ROLE_KEY=<clé service role>
 *   npm start -- [--dry-run] [--limit=100] [--table=interventions|devis]
 *
 * Parcourt `interventions.chemin_bon_pdf` et `devis.fichier_chemin` contenant un chemin réseau (format Access
 * `libellé#\\serveur\chemin\fichier.pdf#` ou chemin brut), copie le fichier dans le bucket privé `bons` ou
 * `devis-documents` sous `legacy/<id>.<ext>` et remplace la colonne par le chemin Storage. `sites.dossier_chemin`
 * désigne des dossiers : non copié, seulement compté. Rapport écrit dans `last-run-report.md` (ignoré par git).
 */
import { readFileSync, existsSync, writeFileSync } from "node:fs";
import { extname } from "node:path";
import { createClient } from "@supabase/supabase-js";

const args = Object.fromEntries(process.argv.slice(2).map((a) => a.replace(/^--/, "").split("=")).map(([k, v]) => [k, v ?? "true"]));
const dryRun = args["dry-run"] === "true";
const limit = Number(args.limit ?? 0) || 0;
const seulement = args.table;

const url = process.env.SUPABASE_URL;
const cle = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!url || !cle) {
  console.error("SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY sont obligatoires.");
  process.exit(1);
}
const supabase = createClient(url, cle, { auth: { persistSession: false } });

/** `libellé#\\serveur\dossier\fichier.pdf#` → `\\serveur\dossier\fichier.pdf` ; chemin brut inchangé. */
export function cheminLocal(valeur) {
  if (!valeur) return null;
  const m = /#(\\\\[^#]+)#?$/.exec(valeur) ?? /^(\\\\[^#]+)#?$/.exec(valeur);
  const chemin = (m ? m[1] : valeur).trim();
  return /^\\\\/.test(chemin) || /^[A-Za-z]:\\/.test(chemin) ? chemin : null;
}

const CIBLES = [
  { table: "interventions", colonne: "chemin_bon_pdf", bucket: "bons" },
  { table: "devis", colonne: "fichier_chemin", bucket: "devis-documents" },
];

const rapport = { copies: [], introuvables: [], ignores: [], erreurs: [] };

async function assurerBucket(nom) {
  const { data } = await supabase.storage.getBucket(nom);
  if (!data && !dryRun) await supabase.storage.createBucket(nom, { public: false });
}

async function traiter({ table, colonne, bucket }) {
  await assurerBucket(bucket);
  let depuis = 0;
  const taille = 500;
  for (;;) {
    let q = supabase.from(table).select(`id, ${colonne}`).not(colonne, "is", null).order("id").range(depuis, depuis + taille - 1);
    const { data, error } = await q;
    if (error) throw error;
    if (!data?.length) break;
    for (const ligne of data) {
      if (limit && rapport.copies.length >= limit) return;
      const valeur = ligne[colonne];
      if (/^(bons|devis-documents|certificats)\//.test(valeur)) continue; // déjà migré
      const local = cheminLocal(valeur);
      if (!local) {
        rapport.ignores.push(`${table}#${ligne.id} : ${valeur}`);
        continue;
      }
      if (!existsSync(local)) {
        rapport.introuvables.push(`${table}#${ligne.id} : ${local}`);
        continue;
      }
      const ext = (extname(local) || ".pdf").toLowerCase();
      const destination = `legacy/${ligne.id}${ext}`;
      if (dryRun) {
        rapport.copies.push(`${table}#${ligne.id} : ${local} → ${bucket}/${destination} (simulation)`);
        continue;
      }
      try {
        const { error: erreurUpload } = await supabase.storage.from(bucket).upload(destination, readFileSync(local), { upsert: true, contentType: ext === ".pdf" ? "application/pdf" : undefined });
        if (erreurUpload) throw erreurUpload;
        const { error: erreurMaj } = await supabase.from(table).update({ [colonne]: `${bucket}/${destination}` }).eq("id", ligne.id);
        if (erreurMaj) throw erreurMaj;
        rapport.copies.push(`${table}#${ligne.id} : ${local} → ${bucket}/${destination}`);
      } catch (e) {
        rapport.erreurs.push(`${table}#${ligne.id} : ${e.message ?? e}`);
      }
    }
    depuis += taille;
  }
}

async function compterDossiersSites() {
  const { count } = await supabase.from("sites").select("id", { count: "exact", head: true }).not("dossier_chemin", "is", null);
  return count ?? 0;
}

const debut = Date.now();
for (const cible of CIBLES) {
  if (seulement && cible.table !== seulement) continue;
  console.log(`→ ${cible.table}.${cible.colonne}`);
  await traiter(cible);
}
const dossiers = await compterDossiersSites();

const lignes = [
  `# Migration des documents — ${new Date().toISOString()}${dryRun ? " (simulation)" : ""}`,
  "",
  `- Copiés : ${rapport.copies.length}`,
  `- Introuvables : ${rapport.introuvables.length}`,
  `- Ignorés (pas un chemin réseau) : ${rapport.ignores.length}`,
  `- Erreurs : ${rapport.erreurs.length}`,
  `- Dossiers de sites (sites.dossier_chemin) non copiés : ${dossiers}`,
  "",
  "## Introuvables",
  ...rapport.introuvables.map((l) => `- ${l}`),
  "",
  "## Erreurs",
  ...rapport.erreurs.map((l) => `- ${l}`),
  "",
  "## Ignorés",
  ...rapport.ignores.map((l) => `- ${l}`),
  "",
  "## Copiés",
  ...rapport.copies.map((l) => `- ${l}`),
];
writeFileSync(new URL("./last-run-report.md", import.meta.url), lignes.join("\n"));
console.log(lignes.slice(2, 8).join("\n"));
console.log(`Terminé en ${Math.round((Date.now() - debut) / 1000)} s — rapport : scripts/migrate-documents/last-run-report.md`);
