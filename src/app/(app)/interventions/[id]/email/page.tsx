import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { toStringParams } from "@/lib/list-params";
import { Champ, CHAMP } from "@/components/ui/Champ";
import { Messages } from "@/components/ui/Messages";
import { formatDate, formatNom } from "@/lib/format";
import { envoyerEmailIntervention } from "../../actions";

export const dynamic = "force-dynamic";

const TYPES = {
  partenaire: "Mail au partenaire (sous-traitant)",
  contact: "Mail au contact client",
  fin_intervention: "Mail de fin d'intervention au client",
} as const;
type TypeMail = keyof typeof TYPES;

export default async function EmailInterventionPage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { id } = await params;
  const sp = toStringParams(await searchParams);
  const type: TypeMail = sp.type && sp.type in TYPES ? (sp.type as TypeMail) : "partenaire";

  const supabase = await createClient();
  const { data: intervention } = await supabase.from("interventions").select("*").eq("id", id).maybeSingle();
  if (!intervention) notFound();

  const [{ data: site }, { data: intervenant }, { data: contact }, { data: charge }, { data: typeInterv }] = await Promise.all([
    supabase.from("sites").select("nom, adresse, code_postal, ville, client_id").eq("id", intervention.site_id).maybeSingle(),
    intervention.intervenant_id ? supabase.from("intervenants").select("nom, email").eq("id", intervention.intervenant_id).maybeSingle() : Promise.resolve({ data: null }),
    intervention.contact_id ? supabase.from("contacts").select("nom, prenom, civilite, email").eq("id", intervention.contact_id).maybeSingle() : Promise.resolve({ data: null }),
    intervention.charge_affaire_id ? supabase.from("utilisateurs").select("nom, prenom, email").eq("id", intervention.charge_affaire_id).maybeSingle() : Promise.resolve({ data: null }),
    intervention.type_code != null ? supabase.from("types_intervention").select("libelle").eq("code", intervention.type_code).maybeSingle() : Promise.resolve({ data: null }),
  ]);
  const { data: client } = site ? await supabase.from("clients").select("nom, email").eq("id", site.client_id).maybeSingle() : { data: null };

  const adresse = [site?.adresse, site?.code_postal, site?.ville].filter(Boolean).join(" ");
  const signature = `Cordialement,\n${charge ? formatNom(charge.prenom, charge.nom) : "L'équipe FMC"}\nFMC Maintenance`;
  const numero = intervention.legacy_id ?? intervention.id;

  // Textes repris des mails Access (analysis 02 §5), envoyés en texte brut et modifiables avant envoi.
  const modeles: Record<TypeMail, { destinataire: string; objet: string; texte: string }> = {
    partenaire: {
      destinataire: intervenant?.email ?? "",
      objet: `Demande d'intervention pour le client : ${client?.nom ?? ""} pour le site : ${site?.nom ?? ""}`,
      texte: `Madame, Monsieur,\n\nNous vous remercions de bien vouloir intervenir sur le site ${site?.nom ?? ""} (${adresse}) pour le client ${client?.nom ?? ""}.\n\nObjet : ${intervention.objet ?? ""}\nN° de demande : ${numero}${intervention.reference_client ? ` · N° DI client : ${intervention.reference_client}` : ""}\nDate limite : ${formatDate(intervention.date_limite)}\n${intervention.directives ? `Directives : ${intervention.directives}\n` : ""}\nMerci de nous confirmer la date d'intervention.\n\n${signature}`,
    },
    contact: {
      destinataire: contact?.email ?? "",
      objet: `Demande d'intervention pour le site : ${site?.nom ?? ""}`,
      texte: `À l'attention de ${contact ? [contact.civilite, formatNom(contact.prenom, contact.nom)].filter(Boolean).join(" ") : "Madame, Monsieur"},\n\nNous avons bien enregistré la demande d'intervention n° ${numero} pour le site ${site?.nom ?? ""} (${adresse}).\nObjet : ${intervention.objet ?? ""}\nDate limite d'intervention : ${formatDate(intervention.date_limite)}\n\nNous vous tiendrons informé(e) de la date d'intervention.\n\n${signature}`,
    },
    fin_intervention: {
      destinataire: client?.email ?? "",
      objet: `Fin d'intervention – ${site?.nom ?? ""}`,
      texte: `Madame, Monsieur,\n\nNous sommes intervenus à ${site?.nom ?? ""} le ${formatDate(intervention.date_realisee)} pour ${typeInterv?.libelle?.toLowerCase() ?? "intervention"}${intervention.objet ? ` : ${intervention.objet}` : ""}.\n${intervention.prestations_realisees ? `\nPrestations effectuées :\n${intervention.prestations_realisees}\n` : ""}${intervention.commentaire_cloture_panne ? `\nÀ prévoir / reste à faire :\n${intervention.commentaire_cloture_panne}\n` : ""}\n${signature}`,
    },
  };
  const modele = modeles[type];

  return (
    <div className="mx-auto flex max-w-2xl flex-col gap-4 p-8">
      <div>
        <Link href={`/interventions/${id}`} className="text-sm underline">
          ← Intervention n°{numero}
        </Link>
      </div>
      <h1 className="text-2xl font-bold">{TYPES[type]}</h1>
      <Messages sp={sp} />
      <div className="flex flex-wrap gap-2 text-sm">
        {(Object.keys(TYPES) as TypeMail[]).map((t) => (
          <Link key={t} href={`/interventions/${id}/email?type=${t}`} className={`rounded-md border px-3 py-1.5 ${t === type ? "bg-black text-white" : ""}`}>
            {TYPES[t]}
          </Link>
        ))}
      </div>

      <form action={envoyerEmailIntervention} className="flex flex-col gap-3 rounded-xl border p-4">
        <input type="hidden" name="intervention_id" value={id} />
        <input type="hidden" name="type" value={type} />
        <Champ label="Destinataire *">
          <input name="destinataire" type="email" required defaultValue={modele.destinataire} className={CHAMP} placeholder={modele.destinataire ? undefined : "Aucune adresse connue : saisissez-la"} />
        </Champ>
        <Champ label="Objet *">
          <input name="objet" required defaultValue={modele.objet} className={CHAMP} />
        </Champ>
        <Champ label="Message *">
          <textarea name="texte" required rows={14} defaultValue={modele.texte} className={`${CHAMP} font-mono text-xs`} />
        </Champ>
        <p className="text-xs opacity-60">Envoi en texte brut via Resend ; l&apos;envoi est journalisé (`journal_emails`). Sans clé Resend configurée, l&apos;envoi est simulé.</p>
        <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
          Envoyer
        </button>
      </form>
    </div>
  );
}
