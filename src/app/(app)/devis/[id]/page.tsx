import Link from "next/link";
import { Messages } from "@/components/ui/Messages";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/Badge";
import { KeyValue } from "@/components/ui/KeyValue";
import { Chemin } from "@/components/ui/Chemin";
import { statutDevisTone } from "@/lib/badges";
import { formatDate, formatMontant, formatNom } from "@/lib/format";
import { toStringParams } from "@/lib/list-params";
import { LIBELLES_FAMILLE, calculerMontantHt, type FamilleDevis } from "@/lib/devis";
import { Champ, CHAMP } from "@/components/ui/Champ";
import { mettreAJourDevis, genererIntervention, supprimerDevis } from "../actions";

export const dynamic = "force-dynamic";

const nomComplet = (u: { nom: string | null; prenom: string | null } | null | undefined) => (u ? formatNom(u.prenom, u.nom) : "—");

export default async function DevisPage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { id } = await params;
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();

  const { data: devis } = await supabase.from("devis").select("*").eq("id", id).is("supprime_le", null).maybeSingle();
  if (!devis) notFound();
  const famille = devis.famille as FamilleDevis;

  const [{ data: statuts }, { data: site }, { data: pannes }, { data: gestionnaires }, { data: partenaires }, { data: origine }, { data: generee }] =
    await Promise.all([
      supabase.from("statuts_devis").select("code, libelle").order("code"),
      devis.site_id
        ? supabase.from("sites").select("id, nom, ville, client_id, tarifs_specifiques").eq("id", devis.site_id).maybeSingle()
        : Promise.resolve({ data: null }),
      supabase.from("pannes").select("libelle").order("libelle"),
      supabase.from("utilisateurs").select("id, nom, prenom").in("profil", [1, 3]).order("nom"),
      supabase.from("intervenants").select("id, nom").order("nom"),
      devis.intervention_origine_id
        ? supabase.from("interventions").select("id, objet").eq("id", devis.intervention_origine_id).maybeSingle()
        : Promise.resolve({ data: null }),
      devis.numero
        ? supabase.from("interventions").select("id").eq("numero_devis_accepte", devis.numero).order("id", { ascending: false }).limit(1).maybeSingle()
        : Promise.resolve({ data: null }),
    ]);

  const [{ data: client }, { data: interventionsSite }] = await Promise.all([
    site ? supabase.from("clients").select("id, nom").eq("id", site.client_id).maybeSingle() : Promise.resolve({ data: null }),
    site
      ? supabase.from("interventions").select("id, objet, date_demande").eq("site_id", site.id).order("date_demande", { ascending: false }).limit(50)
      : Promise.resolve({ data: [] }),
  ]);

  const statutLibelle = statuts?.find((s) => s.code === devis.statut_code)?.libelle ?? "—";
  const envoyePar = gestionnaires?.find((g) => g.id === devis.envoye_par_id);
  const partenaire = partenaires?.find((p) => p.id === devis.partenaire_id);
  const montantCalcule = calculerMontantHt(devis);
  const montantManuel = montantCalcule != null && devis.montant_ht != null && montantCalcule !== devis.montant_ht;

  return (
    <div className="mx-auto flex max-w-5xl flex-col gap-4 p-8">
      <Messages sp={sp} />

      <div className="flex flex-wrap items-center gap-2">
        <Badge tone="gray">{LIBELLES_FAMILLE[famille]}</Badge>
        <Badge tone={statutDevisTone(devis.statut_code)}>{statutLibelle}</Badge>
        {site && (
          <Link href={`/sites/${site.id}`} className="text-sm underline">
            {site.nom} ({site.ville})
          </Link>
        )}
        {client && (
          <Link href={`/clients/${client.id}`} className="text-sm underline">
            {client.nom}
          </Link>
        )}
      </div>

      <h1 className="text-xl font-semibold">
        Devis {devis.numero ?? `#${devis.id}`} · {formatMontant(devis.montant_ht)}
      </h1>

      <div className="flex flex-wrap gap-2">
        {devis.statut_code !== 6 && (
          <form action={genererIntervention}>
            <input type="hidden" name="devis_id" value={id} />
            <button type="submit" className="rounded-md border px-3 py-1.5 text-sm">
              Générer l&apos;intervention suite à accord
            </button>
          </form>
        )}
        <form action={supprimerDevis}>
          <input type="hidden" name="devis_id" value={id} />
          <button type="submit" className="rounded-md border border-red-300 px-3 py-1.5 text-sm text-red-700">
            Supprimer
          </button>
        </form>
        <Link href={`/devis?onglet=${famille}`} className="rounded-md border px-3 py-1.5 text-sm">
          Retour à la liste
        </Link>
      </div>

      <KeyValue
        items={[
          { label: "Fichier", value: <Chemin value={devis.fichier_chemin} /> },
          { label: "Fichier partenaire", value: <Chemin value={devis.fichier_partenaire_chemin} /> },
          {
            label: "Intervention d'origine",
            value: origine ? <Link className="underline" href={`/interventions/${origine.id}`}>#{origine.id} · {origine.objet}</Link> : "—",
          },
          {
            label: "Intervention générée",
            value: generee ? <Link className="underline" href={`/interventions/${generee.id}`}>#{generee.id}</Link> : "—",
          },
          { label: "Montant HT calculé", value: montantCalcule != null ? `${formatMontant(montantCalcule)}${montantManuel ? " (montant saisi différent)" : ""}` : "—" },
          { label: "Date du devis", value: formatDate(devis.date_devis) },
          { label: "Date d'envoi", value: formatDate(devis.date_envoi) },
          { label: "Envoyé par", value: nomComplet(envoyePar) },
          { label: "Type de panne", value: devis.type_panne_libelle },
          { label: "Partenaire", value: partenaire?.nom ?? "—" },
          { label: "Remplacé par", value: devis.numero_devis_remplacement },
        ]}
      />

      <form action={mettreAJourDevis} className="flex flex-col gap-3 rounded-xl border p-4">
        <h2 className="text-sm font-semibold opacity-70">Modifier</h2>
        <input type="hidden" name="devis_id" value={id} />

        <div className="grid grid-cols-2 gap-3">
          <Champ label="Statut">
            <select name="statut_code" defaultValue={devis.statut_code ?? 1} className={CHAMP}>
              {(statuts ?? []).map((s) => (
                <option key={s.code} value={s.code}>
                  {s.libelle}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="Remplacé par (obligatoire si « Annulé et remplacé »)">
            <input name="numero_devis_remplacement" defaultValue={devis.numero_devis_remplacement ?? ""} className={CHAMP} />
          </Champ>
        </div>

        <div className="grid grid-cols-2 gap-3">
          <Champ label="Numéro">
            <input name="numero" defaultValue={devis.numero ?? ""} className={CHAMP} />
          </Champ>
          <Champ label="N° de commande">
            <input name="numero_commande" defaultValue={devis.numero_commande ?? ""} className={CHAMP} />
          </Champ>
        </div>

        <Champ label="Fichier PDF (chemin)">
          <input name="fichier_chemin" defaultValue={devis.fichier_chemin ?? ""} className={CHAMP} />
        </Champ>

        <Champ label="Intervention d'origine">
          <select name="intervention_origine_id" defaultValue={devis.intervention_origine_id ?? ""} className={CHAMP}>
            <option value="">—</option>
            {(interventionsSite ?? []).map((i) => (
              <option key={i.id} value={i.id}>
                #{i.id} · {formatDate(i.date_demande)} · {i.objet}
              </option>
            ))}
          </select>
        </Champ>

        <div className="grid grid-cols-2 gap-3">
          <Champ label="Type de panne">
            <select name="type_panne_libelle" defaultValue={devis.type_panne_libelle ?? ""} className={CHAMP}>
              <option value="">—</option>
              {(pannes ?? []).map((p) => (
                <option key={p.libelle} value={p.libelle}>
                  {p.libelle}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="Nb machines concernées">
            <input name="quantite_materiel" type="number" min={0} defaultValue={devis.quantite_materiel ?? ""} className={CHAMP} />
          </Champ>
        </div>

        <div className="grid grid-cols-3 gap-3">
          <Champ label="Montant fournitures">
            <input name="montant_fournitures" type="number" step="0.01" defaultValue={devis.montant_fournitures ?? ""} className={CHAMP} />
          </Champ>
          <Champ label="Heures main d'œuvre">
            <input name="heures_mo" type="number" step="0.25" defaultValue={devis.heures_mo ?? ""} className={CHAMP} />
          </Champ>
          <Champ label="Nb déplacements">
            <input name="nombre_deplacements" type="number" min={0} defaultValue={devis.nombre_deplacements ?? ""} className={CHAMP} />
          </Champ>
          <Champ label="Tarif heure MO">
            <input name="tarif_heure_mo" type="number" step="0.01" defaultValue={devis.tarif_heure_mo ?? ""} className={CHAMP} />
          </Champ>
          <Champ label="Tarif déplacement">
            <input name="tarif_deplacement" type="number" step="0.01" defaultValue={devis.tarif_deplacement ?? ""} className={CHAMP} />
          </Champ>
          <Champ label="Montant HT">
            <input name="montant_ht" type="number" step="0.01" defaultValue={devis.montant_ht ?? ""} className={CHAMP} />
          </Champ>
        </div>
        <p className="text-xs opacity-60">
          Montant HT recalculé à l&apos;enregistrement (fournitures + heures × tarif heure + déplacements × tarif déplacement) ; une valeur saisie
          différente est conservée avec un avertissement.
        </p>

        <div className="grid grid-cols-3 gap-3">
          <Champ label="Date du devis">
            <input name="date_devis" type="date" defaultValue={devis.date_devis ?? ""} className={CHAMP} />
          </Champ>
          <Champ label="Date d'envoi (posée au passage à « Envoyé »)">
            <input name="date_envoi" type="date" defaultValue={devis.date_envoi ?? ""} className={CHAMP} />
          </Champ>
          <Champ label="Envoyé par">
            <select name="envoye_par_id" defaultValue={devis.envoye_par_id ?? ""} className={CHAMP}>
              <option value="">—</option>
              {(gestionnaires ?? []).map((g) => (
                <option key={g.id} value={g.id}>
                  {nomComplet(g)}
                </option>
              ))}
            </select>
          </Champ>
        </div>

        <div className="grid grid-cols-3 gap-3">
          <Champ label="Partenaire">
            <select name="partenaire_id" defaultValue={devis.partenaire_id ?? ""} className={CHAMP}>
              <option value="">—</option>
              {(partenaires ?? []).map((p) => (
                <option key={p.id} value={p.id}>
                  {p.nom}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="N° devis partenaire">
            <input name="numero_devis_partenaire" defaultValue={devis.numero_devis_partenaire ?? ""} className={CHAMP} />
          </Champ>
          <Champ label="Montant HT partenaire">
            <input name="montant_ht_partenaire" type="number" step="0.01" defaultValue={devis.montant_ht_partenaire ?? ""} className={CHAMP} />
          </Champ>
        </div>

        <Champ label="Fichier partenaire (chemin)">
          <input name="fichier_partenaire_chemin" defaultValue={devis.fichier_partenaire_chemin ?? ""} className={CHAMP} />
        </Champ>

        <Champ label="Commentaire client">
          <textarea name="commentaire_client" rows={3} defaultValue={devis.commentaire_client ?? ""} className={CHAMP} />
        </Champ>

        <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
          Enregistrer
        </button>
      </form>
    </div>
  );
}
