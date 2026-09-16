import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/Badge";
import { Tabs } from "@/components/ui/Tabs";
import { KeyValue } from "@/components/ui/KeyValue";
import { EmptyState } from "@/components/ui/EmptyState";
import { Chemin } from "@/components/ui/Chemin";
import { Champ, CHAMP } from "@/components/ui/Champ";
import { FormulaireSite } from "@/components/sites/FormulaireSite";
import { ContratsSite, HorairesSite } from "@/components/sites/ContratsEtHoraires";
import { MaterielSite } from "@/components/sites/MaterielSite";
import { statutInterventionTone } from "@/lib/badges";
import { formatDate, formatMontant, formatNombre, oui } from "@/lib/format";
import { toStringParams } from "@/lib/list-params";
import { JOURS, LIBELLES_LOT, type Lot } from "@/lib/sites";
import { basculerNePlusIntervenir, fermerSite, geocoderSite, rouvrirSite } from "../actions";

export const dynamic = "force-dynamic";

const ONGLETS = [
  { key: "site", label: "Site" },
  { key: "contrats", label: "Contrats" },
  { key: "horaires", label: "Horaires" },
  { key: "interventions", label: "Interventions" },
  { key: "materiel", label: "Matériel" },
  { key: "registre", label: "Registre de sécurité" },
  { key: "devis", label: "Devis" },
  { key: "documents", label: "Documents" },
];

const BOUTON = "rounded-md border px-3 py-1.5 text-sm";

export default async function SitePage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { id } = await params;
  const siteId = Number(id);
  const sp = toStringParams(await searchParams);
  const onglet = ONGLETS.some((o) => o.key === sp.onglet) ? sp.onglet! : "site";
  const deverrouille = sp.deverrouiller === "1";

  const supabase = await createClient();
  const { data: site } = await supabase.from("sites").select("*").eq("id", id).maybeSingle();
  if (!site) notFound();

  const [{ data: client }, { data: contrats }, { data: horaires }, { data: zones }, { data: intervenants }, { data: donneurs }, { data: fluides }, { data: clients }] =
    await Promise.all([
      supabase.from("clients").select("id, nom").eq("id", site.client_id).maybeSingle(),
      supabase.from("site_contrats").select("*").eq("site_id", id),
      supabase.from("site_horaires").select("*").eq("site_id", id).order("jour"),
      supabase.from("zones_geographiques").select("id, libelle").order("libelle"),
      supabase.from("intervenants").select("id, nom").order("nom"),
      supabase.from("donneurs_ordre").select("id, nom").order("nom"),
      supabase.from("types_fluide").select("id, libelle").order("libelle"),
      deverrouille ? supabase.from("clients").select("id, nom").order("nom") : Promise.resolve({ data: [] as { id: number; nom: string }[] }),
    ]);

  const { data: devisLies } = await supabase.from("devis").select("id, famille, numero, statut_code, montant_ht").eq("site_id", id).is("supprime_le", null);
  const devisEnCours = (devisLies ?? []).filter((d) => [1, 2, 4].includes(d.statut_code ?? -1));

  const { count: ceAEditer } = await supabase
    .from("site_materiels")
    .select("id", { count: "exact", head: true })
    .eq("site_id", id)
    .eq("certificat_etancheite_edite", false)
    .not("date_controle_etancheite", "is", null);

  const garantieAnnees = Math.max(site.garantie_pieces_annees ?? 0, site.garantie_pieces_mo_annees ?? 0, site.garantie_compresseur_annees ?? 0);
  let garantieEnCours = false;
  if (site.date_mise_en_service && garantieAnnees > 0) {
    const fin = new Date(site.date_mise_en_service);
    fin.setFullYear(fin.getFullYear() + garantieAnnees);
    garantieEnCours = fin > new Date();
  }

  const enLibelle = (rows: { id: number; nom?: string | null; libelle?: string | null }[] | null) => (rows ?? []).map((r) => ({ id: r.id, libelle: r.nom ?? r.libelle ?? null }));
  const intervenantTitulaire = intervenants?.find((i) => i.id === site.intervenant_id);
  const donneurOrdre = donneurs?.find((d) => d.id === site.donneur_ordre_id);
  const zone = zones?.find((z) => z.id === site.zone_id);

  return (
    <div className="mx-auto flex max-w-6xl flex-col gap-4 p-8">
      {sp.erreur && <p className="rounded-md bg-red-50 p-3 text-sm text-red-700">{sp.erreur}</p>}
      {sp.info && <p className="rounded-md bg-blue-50 p-3 text-sm text-blue-800">{sp.info}</p>}

      {(site.ne_plus_intervenir || site.retard_paiement || site.ferme) && (
        <div className="rounded-lg bg-red-50 p-3 text-sm text-red-700">
          {site.ferme && (
            <div>
              Site fermé le {formatDate(site.date_fermeture)}
              {site.motif_fermeture ? ` : ${site.motif_fermeture}` : ""}.
            </div>
          )}
          {site.ne_plus_intervenir && <div>Ne plus intervenir sur ce site.</div>}
          {site.retard_paiement && <div>Retard de paiement.</div>}
        </div>
      )}

      {sp.confirmer === "fermeture" && !site.ferme && (
        <form action={fermerSite} className="flex flex-col gap-3 rounded-md bg-orange-50 p-4 text-sm text-orange-900">
          <input type="hidden" name="site_id" value={id} />
          <p className="font-medium">
            Êtes-vous sûr de vouloir clôturer le site ? Il sera rattaché au client « sites fermés » ; le client actuel ({client?.nom}) est conservé dans la fiche pour une
            éventuelle réouverture.
          </p>
          <div className="grid grid-cols-[10rem_1fr] gap-3">
            <Champ label="Date de fermeture">
              <input name="date_fermeture" type="date" defaultValue={new Date().toISOString().slice(0, 10)} className={CHAMP} />
            </Champ>
            <Champ label="Motif">
              <input name="motif_fermeture" className={CHAMP} />
            </Champ>
          </div>
          <div className="flex gap-3">
            <button type="submit" className="rounded-md bg-orange-700 px-3 py-1.5 text-white">
              Confirmer la fermeture
            </button>
            <Link href={`/sites/${id}`} className={BOUTON}>
              Annuler
            </Link>
          </div>
        </form>
      )}

      {sp.confirmer === "ne_plus_intervenir" && (
        <form action={basculerNePlusIntervenir} className="flex flex-col gap-3 rounded-md bg-orange-50 p-4 text-sm text-orange-900">
          <input type="hidden" name="site_id" value={id} />
          <input type="hidden" name="actif" value={site.ne_plus_intervenir ? "0" : "1"} />
          <p className="font-medium">
            {site.ne_plus_intervenir
              ? "Attention, vous allez faire passer les interventions du statut « Ne plus intervenir » au statut « À planifier » (réservé à l'administrateur). Confirmez-vous ?"
              : "Attention, vous allez faire passer toutes les interventions en cours au statut « Ne plus intervenir » (pensez à noter leur statut précédent). Confirmez-vous ?"}
          </p>
          <div className="flex gap-3">
            <button type="submit" className="rounded-md bg-orange-700 px-3 py-1.5 text-white">
              Confirmer
            </button>
            <Link href={`/sites/${id}`} className={BOUTON}>
              Annuler
            </Link>
          </div>
        </form>
      )}

      <div className="flex flex-wrap items-center gap-2">
        {site.ferme && <Badge tone="gray">Fermé</Badge>}
        {devisEnCours.length > 0 && <Badge tone="yellow">{devisEnCours.length} devis en cours</Badge>}
        {garantieEnCours && <Badge tone="green">Garantie en cours</Badge>}
        {(ceAEditer ?? 0) > 0 && <Badge tone="orange">{ceAEditer} CE à éditer</Badge>}
        {site.nacelle_necessaire && <Badge tone="purple">Nacelle</Badge>}
        {site.particulier && <Badge tone="blue">Particulier</Badge>}
        {site.rdv_a_prendre && <Badge tone="pink">RDV à prendre</Badge>}
      </div>

      <h1 className="text-xl font-semibold">
        {site.nom} {site.numero_magasin ? `· n°${site.numero_magasin}` : ""}
      </h1>
      <p className="text-sm opacity-70">
        {client && (
          <>
            Client :{" "}
            <Link href={`/clients/${client.id}`} className="underline">
              {client.nom}
            </Link>
          </>
        )}
        {site.ville ? ` · ${site.ville}` : ""}
        {site.latitude != null && site.longitude != null ? ` · ${site.latitude}, ${site.longitude} (${site.precision_geo ?? "précision inconnue"})` : " · non géocodé"}
      </p>

      <div className="flex flex-wrap gap-2">
        <Link href={`/interventions/nouvelle?site=${id}`} className="rounded-md bg-black px-3 py-1.5 text-sm text-white">
          Nouvelle intervention
        </Link>
        <Link href={`/devis/nouveau?site=${id}`} className={BOUTON}>
          Nouveau devis
        </Link>
        <form action={geocoderSite}>
          <input type="hidden" name="site_id" value={id} />
          <button type="submit" className={BOUTON}>
            Géocoder l&apos;adresse
          </button>
        </form>
        <Link href={`/sites/${id}?confirmer=ne_plus_intervenir`} className={BOUTON}>
          {site.ne_plus_intervenir ? "Reprendre les interventions" : "Ne plus intervenir"}
        </Link>
        {site.ferme ? (
          <form action={rouvrirSite}>
            <input type="hidden" name="site_id" value={id} />
            <button type="submit" className={BOUTON}>
              Rouvrir le site
            </button>
          </form>
        ) : (
          <Link href={`/sites/${id}?confirmer=fermeture`} className={`${BOUTON} border-red-300 text-red-700`}>
            Fermer le site
          </Link>
        )}
      </div>

      <Tabs tabs={ONGLETS} active={onglet} searchParams={sp} />

      {onglet === "site" && (
        <div className="flex flex-col gap-6">
          <KeyValue
            items={[
              { label: "Adresse", value: `${site.adresse ?? ""} ${site.code_postal ?? ""} ${site.ville ?? ""}`.trim() || "—" },
              { label: "Zone", value: zone?.libelle },
              { label: "Intervenant", value: intervenantTitulaire ? <Link className="underline" href={`/intervenants/${intervenantTitulaire.id}`}>{intervenantTitulaire.nom}</Link> : "—" },
              { label: "Donneur d'ordre", value: donneurOrdre ? <Link className="underline" href={`/donneurs-ordre/${donneurOrdre.id}`}>{donneurOrdre.nom}</Link> : "—" },
              { label: "Visites/an (pivot)", value: formatNombre(site.visites_entretien_par_an) },
              { label: "Dernière visite entretien", value: formatDate(site.date_derniere_visite_entretien) },
              { label: "Tarifs", value: site.tarifs_specifiques ? `Site : ${formatMontant(site.tarif_heure_mo)} / ${formatMontant(site.tarif_deplacement)}` : "Tarifs du client" },
              { label: "Investissement", value: oui(site.investissement) },
            ]}
          />
          <FormulaireSite
            site={site}
            deverrouille={deverrouille}
            clients={enLibelle(clients)}
            donneurs={enLibelle(donneurs)}
            intervenants={enLibelle(intervenants)}
            zones={enLibelle(zones)}
            fluides={enLibelle(fluides)}
          />
        </div>
      )}

      {onglet === "contrats" && (
        <div className="flex flex-col gap-4">
          <ul className="flex flex-wrap gap-3 text-sm">
            {(contrats ?? []).map((c) => (
              <li key={c.id} className="rounded-md border px-3 py-1.5">
                {LIBELLES_LOT[c.lot as Lot]} : {formatNombre(c.visites_par_an)} visite(s)/an · {formatMontant(c.redevance)}
              </li>
            ))}
          </ul>
          <ContratsSite siteId={siteId} contrats={contrats ?? []} intervenants={enLibelle(intervenants)} />
        </div>
      )}

      {onglet === "horaires" && (
        <div className="flex flex-col gap-4">
          {horaires && horaires.length > 0 && (
            <ul className="grid grid-cols-2 gap-1 text-sm sm:grid-cols-4">
              {horaires.map((h) => (
                <li key={h.id}>
                  {JOURS[h.jour - 1]} : {h.ouverture?.slice(0, 5) ?? "—"} – {h.fermeture?.slice(0, 5) ?? "—"}
                </li>
              ))}
            </ul>
          )}
          <HorairesSite siteId={siteId} horaires={horaires ?? []} />
        </div>
      )}

      {onglet === "interventions" && <SiteInterventions siteId={id} />}
      {onglet === "materiel" && <MaterielSite siteId={siteId} modifierId={sp.modifier} />}
      {onglet === "registre" && <SiteRegistre siteId={id} />}

      {onglet === "devis" &&
        (devisLies && devisLies.length > 0 ? (
          <ul className="flex flex-col gap-2">
            {devisLies.map((d) => (
              <li key={d.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
                <Link href={`/devis/${d.id}`} className="capitalize underline">
                  {d.famille} · {d.numero ?? `#${d.id}`}
                </Link>
                <span>{formatMontant(d.montant_ht)}</span>
              </li>
            ))}
          </ul>
        ) : (
          <EmptyState message="Aucun devis pour ce site." />
        ))}

      {onglet === "documents" && (
        <KeyValue
          items={[
            { label: "Dossier réseau", value: <Chemin value={site.dossier_chemin} /> },
            { label: "Résumé devis envoyés", value: site.resume_devis_html ? <span className="whitespace-pre-line">{String(site.resume_devis_html).replace(/<br\s*\/?>/gi, "\n")}</span> : "—" },
          ]}
        />
      )}
    </div>
  );
}

async function SiteInterventions({ siteId }: { siteId: string }) {
  const supabase = await createClient();
  const [{ data: enCours }, { data: cloturees }] = await Promise.all([
    supabase
      .from("v_interventions_liste")
      .select("id, type_libelle, statut_code, statut_libelle, date_limite, objet")
      .eq("site_id", siteId)
      .not("statut_code", "in", "(7,8,10,20)")
      .order("date_limite", { ascending: false })
      .limit(50),
    supabase
      .from("v_interventions_liste")
      .select("id, type_libelle, statut_code, statut_libelle, date_realisee, objet")
      .eq("site_id", siteId)
      .in("statut_code", [7, 8, 10, 20])
      .order("date_realisee", { ascending: false })
      .limit(50),
  ]);

  type Ligne = {
    id: number;
    type_libelle: string | null;
    statut_code: number | null;
    statut_libelle: string | null;
    objet: string | null;
    date_limite?: string | null;
    date_realisee?: string | null;
  };
  const Liste = ({ titre, rows, date, vide }: { titre: string; rows: Ligne[] | null; date: "date_limite" | "date_realisee"; vide: string }) => (
    <div>
      <h2 className="mb-2 text-sm font-semibold opacity-70">{titre}</h2>
      {rows && rows.length > 0 ? (
        <ul className="flex flex-col gap-2">
          {rows.map((i) => (
            <li key={i.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
              <Link href={`/interventions/${i.id}`} className="underline">
                {i.objet ?? i.type_libelle}
              </Link>
              <span className="flex items-center gap-2">
                <Badge tone={statutInterventionTone(i.statut_code)}>{i.statut_libelle}</Badge>
                {formatDate(i[date])}
              </span>
            </li>
          ))}
        </ul>
      ) : (
        <EmptyState message={vide} />
      )}
    </div>
  );

  return (
    <div className="flex flex-col gap-6">
      <Liste titre="En cours" rows={enCours} date="date_limite" vide="Aucune intervention en cours." />
      <Liste titre="Clôturées" rows={cloturees} date="date_realisee" vide="Aucune intervention clôturée." />
    </div>
  );
}

async function SiteRegistre({ siteId }: { siteId: string }) {
  const supabase = await createClient();
  const { data } = await supabase.from("site_registre_securite").select("id, date_mise_a_jour").eq("site_id", siteId).order("date_mise_a_jour", { ascending: false });

  if (!data || data.length === 0) return <EmptyState message="Aucune mise à jour du registre." />;

  return (
    <ul className="flex flex-col gap-1 text-sm">
      {data.map((r) => (
        <li key={r.id}>{formatDate(r.date_mise_a_jour)}</li>
      ))}
    </ul>
  );
}
