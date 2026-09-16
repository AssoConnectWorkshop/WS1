import { timingSafeEqual } from "node:crypto";
import { createAdminClient } from "@/lib/supabase/admin";
import { envoyerCourriel } from "@/lib/email";
import { chargerParametres } from "@/lib/pdf";
import { formatDateTime } from "@/lib/format";

export const dynamic = "force-dynamic";

const HEURES = 60 * 60 * 1000;
const DELAIS: { case: string; heures: number }[] = [
  { case: "rappel_24h", heures: 24 },
  { case: "rappel_48h", heures: 48 },
  { case: "rappel_72h", heures: 72 },
  { case: "rappel_semaine", heures: 168 },
];

/** Relances SAV (Form_MenuClimAccess.Recherche_Si_Envoi_Mail) : interventions « À planifier » avec une case rappel
 * cochée dont le dernier rappel (ou la création) est plus ancien que le délai de la case → e-mail à l'adresse SAV. */
export async function GET(request: Request) {
  const secret = process.env.CRON_SECRET;
  const attendu = Buffer.from(`Bearer ${secret ?? ""}`);
  const recu = Buffer.from(request.headers.get("authorization") ?? "");
  if (!secret || attendu.length !== recu.length || !timingSafeEqual(attendu, recu)) return new Response("Non autorisé", { status: 401 });

  const admin = createAdminClient();
  const parametres = await chargerParametres(admin);
  const emailSav = parametres.email_sav;
  if (!emailSav) return Response.json({ envoyes: 0, erreur: "parametres_application.email_sav non renseigné" }, { status: 200 });

  const { data: interventions } = await admin
    .from("interventions")
    .select("id, site_id, reference_client, date_demande, created_at, date_dernier_rappel, rappel_24h, rappel_48h, rappel_72h, rappel_semaine, sites(nom)")
    .eq("statut_code", 1)
    .or("rappel_24h.eq.true,rappel_48h.eq.true,rappel_72h.eq.true,rappel_semaine.eq.true");

  const maintenant = Date.now();
  let envoyes = 0;
  const echecs: number[] = [];
  for (const i of (interventions ?? []) as unknown as (Record<string, unknown> & { id: number; sites: { nom: string | null } | null })[]) {
    const delai = Math.min(...DELAIS.filter((d) => i[d.case]).map((d) => d.heures));
    const reference = new Date(String(i.date_dernier_rappel ?? i.created_at)).getTime();
    if (maintenant - reference <= delai * HEURES) continue;

    const site = i.sites?.nom ?? `site #${i.site_id}`;
    const { ok } = await envoyerCourriel(admin, {
      destinataire: emailSav,
      objet: `Rappel Intervention ${site}`,
      texte: `Site : ${site}\nNuméro DI Client : ${i.reference_client ?? "—"}\nDate Demande : ${formatDateTime(i.date_demande as string | null)}\n\nIntervention n° ${i.id} toujours « À planifier ».`,
      type: "relance",
      interventionId: i.id,
    });
    if (!ok) {
      echecs.push(i.id);
      continue;
    }
    await admin.from("interventions").update({ date_dernier_rappel: new Date(maintenant).toISOString() }).eq("id", i.id);
    envoyes++;
  }

  return Response.json({ envoyes, echecs, examinees: interventions?.length ?? 0 });
}
