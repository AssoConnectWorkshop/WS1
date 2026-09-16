import Link from "next/link";
import { Messages } from "@/components/ui/Messages";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/Badge";
import { Tabs } from "@/components/ui/Tabs";
import { KeyValue } from "@/components/ui/KeyValue";
import { EmptyState } from "@/components/ui/EmptyState";
import { Champ, CHAMP } from "@/components/ui/Champ";
import { FormulaireSite, FORM_SITE } from "@/components/sites/FormulaireSite";
import { HorairesSite } from "@/components/sites/ContratsEtHoraires";
import { MaterielSite } from "@/components/sites/MaterielSite";
import { statutDevisTone, statutInterventionTone, typeInterventionTone } from "@/lib/badges";
import { formatDate, formatMontant, oui } from "@/lib/format";
import { toStringParams } from "@/lib/list-params";
import { type FamilleDevis } from "@/lib/devis";
import { basculerNePlusIntervenir, fermerSite, genererCertificats, rouvrirSite } from "../actions";

export const dynamic = "force-dynamic";

/** Onglets de la fiche Access (Form_Site) ; « Infos complémentaires Site » reçoit aussi horaires, documents et résumé devis. */
const ONGLETS = [
  { key: "site", label: "Site" },
  { key: "interventions", label: "Interventions" },
  { key: "contrat", label: "Contrat de maintenance" },
  { key: "sav", label: "Devis SAV" },
  { key: "travaux", label: "Devis Travaux" },
  { key: "materiel", label: "Matériel" },
  { key: "complements", label: "Infos complémentaires Site" },
];

const STATUTS_DEVIS_EN_COURS = [1, 2, 4];
const BOUTON = "rounded border bg-white px-2 py-1 text-xs dark:bg-white/5";

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

  const [{ data: client }, { data: contrats }, { data: horaires }, { data: zones }, { data: intervenants }, { data: donneurs }, { data: fluides }, { data: clients }, { data: registre }, { data: devisLies }] =
    await Promise.all([
      supabase.from("clients").select("id, nom").eq("id", site.client_id).maybeSingle(),
      supabase.from("site_contrats").select("*").eq("site_id", id),
      supabase.from("site_horaires").select("*").eq("site_id", id).order("jour"),
      supabase.from("zones_geographiques").select("id, libelle").order("libelle"),
      supabase.from("intervenants").select("id, nom").order("nom"),
      supabase.from("donneurs_ordre").select("id, nom").order("nom"),
      supabase.from("types_fluide").select("id, libelle").order("libelle"),
      deverrouille ? supabase.from("clients").select("id, nom").order("nom") : Promise.resolve({ data: [] as { id: number; nom: string }[] }),
      supabase.from("site_registre_securite").select("date_mise_a_jour").eq("site_id", id).order("date_mise_a_jour", { ascending: false }),
      supabase.from("devis").select("id, famille, numero, statut_code, montant_ht, date_envoi, fichier_chemin").eq("site_id", id).is("supprime_le", null).order("date_envoi", { ascending: false }),
    ]);

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

  // Badges d'état calculés par Form_Site.Form_Activate (analysis 03 §2.2).
  const enCours = (famille: FamilleDevis) => (devisLies ?? []).some((d) => d.famille === famille && STATUTS_DEVIS_EN_COURS.includes(d.statut_code ?? -1));
  const badges = [
    enCours("sav") ? "DEVIS SAV EN COURS" : null,
    enCours("travaux") ? "DEVIS TRAVAUX EN COURS" : null,
    enCours("contrat") ? "CE EN COURS" : null,
    garantieEnCours ? "GARANTIE EN COURS" : null,
  ].filter((b): b is string => !!b);

  const enLibelle = (rows: { id: number; nom?: string | null; libelle?: string | null }[] | null) => (rows ?? []).map((r) => ({ id: r.id, libelle: r.nom ?? r.libelle ?? null }));

  return (
    <div className="flex flex-col gap-3 p-4">
      <Messages sp={sp} />

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

      {/* En-tête Access : « Site : NOM - Ville : VILLE », création d'intervention, Enregistrer, Fermer */}
      <div className="flex flex-wrap items-center justify-between gap-2 border-b pb-2">
        <h1 className="text-base font-bold">
          Site : {site.nom}
          {site.numero_magasin ? ` (n° ${site.numero_magasin})` : ""} - Ville : {site.ville ?? "—"}
          {client && (
            <Link href={`/clients/${client.id}`} className="ml-3 text-xs font-normal underline opacity-70">
              {client.nom}
            </Link>
          )}
          {site.ferme && (
            <span className="ml-3">
              <Badge tone="gray">Fermé</Badge>
            </span>
          )}
        </h1>
        <div className="flex flex-wrap items-center gap-2">
          <Link href={`/interventions/nouvelle?site=${id}`} className={BOUTON}>
            Créer une intervention
          </Link>
          {(ceAEditer ?? 0) > 0 && (
            <form action={genererCertificats}>
              <input type="hidden" name="site_id" value={id} />
              <button type="submit" className={BOUTON}>
                {ceAEditer} CE à éditer
              </button>
            </form>
          )}
          {site.ferme && (
            <form action={rouvrirSite}>
              <input type="hidden" name="site_id" value={id} />
              <button type="submit" className={BOUTON}>
                Rouvrir le site
              </button>
            </form>
          )}
          {onglet === "site" && (
            <button type="submit" form={FORM_SITE} className="rounded bg-black px-3 py-1 text-xs text-white" title="Enregistrer la fiche">
              💾 Enregistrer
            </button>
          )}
          <Link href="/sites" className="rounded bg-red-600 px-3 py-1 text-xs text-white" title="Fermer la fiche">
            ✕ Fermer
          </Link>
        </div>
      </div>

      <Tabs tabs={ONGLETS} active={onglet} searchParams={sp} />

      {onglet === "site" && (
        <FormulaireSite
          site={site}
          deverrouille={deverrouille}
          clients={enLibelle(clients)}
          donneurs={enLibelle(donneurs)}
          intervenants={enLibelle(intervenants)}
          zones={enLibelle(zones)}
          fluides={enLibelle(fluides)}
          contrats={contrats ?? []}
          registre={(registre ?? []).map((r) => r.date_mise_a_jour).filter((d): d is string => !!d)}
          badges={badges}
        />
      )}

      {onglet === "interventions" && <SiteInterventions siteId={id} />}

      {(onglet === "contrat" || onglet === "sav" || onglet === "travaux") && <SiteDevis famille={onglet} devis={(devisLies ?? []).filter((d) => d.famille === onglet)} siteId={id} />}

      {onglet === "materiel" && <MaterielSite siteId={siteId} modifierId={sp.modifier} />}

      {onglet === "complements" && (
        <div className="flex flex-col gap-4">
          <KeyValue
            items={[
              { label: "Investissement", value: oui(site.investissement) },
              { label: "Descriptif investissement", value: site.descriptif_investissement || "—" },
              { label: "Nom de société", value: site.nom_societe || "—" },
              { label: "Nombre de plans / photos", value: `${site.nombre_plans ?? "—"} / ${site.nombre_photos ?? "—"}` },
              { label: "Dernière visite désenfumage", value: formatDate(site.date_derniere_visite_desenfumage) },
              { label: "Dernière visite entretien", value: formatDate(site.date_derniere_visite_entretien) },
              { label: "Résumé devis envoyés (tablette)", value: site.resume_devis_html ? <span className="whitespace-pre-line">{String(site.resume_devis_html).replace(/<br\s*\/?>/gi, "\n")}</span> : "—" },
            ]}
          />
          <HorairesSite siteId={siteId} horaires={horaires ?? []} />
        </div>
      )}
    </div>
  );
}

type LigneIntervention = {
  id: number;
  intervenant_nom: string | null;
  date_limite: string | null;
  date_realisee: string | null;
  date_demande: string | null;
  devis_a_faire: boolean | null;
  devis_fait: boolean | null;
  numero_bon: number | null;
  numero_devis_accepte: string | null;
  reference_client: string | null;
  type_code: number | null;
  type_libelle: string | null;
  statut_code: number | null;
  statut_libelle: string | null;
  statut_facturation_libelle: string | null;
  commentaire_interne: string | null;
};

const COLONNES_INTERVENTIONS = "id, intervenant_nom, date_limite, date_realisee, date_demande, devis_a_faire, devis_fait, numero_bon, numero_devis_accepte, reference_client, type_code, type_libelle, statut_code, statut_libelle, statut_facturation_libelle, commentaire_interne";

/** Onglet « Interventions » Access : deux feuilles de données, en cours puis clôturées (analysis 03 §2.2). */
async function SiteInterventions({ siteId }: { siteId: string }) {
  const supabase = await createClient();
  const [{ data: enCours }, { data: cloturees }] = await Promise.all([
    supabase.from("v_interventions_liste").select(COLONNES_INTERVENTIONS).eq("site_id", siteId).not("statut_code", "in", "(7,8,10,20)").order("date_prevue", { ascending: false, nullsFirst: false }).order("date_realisee", { ascending: false, nullsFirst: false }).limit(200),
    supabase.from("v_interventions_liste").select(COLONNES_INTERVENTIONS).eq("site_id", siteId).in("statut_code", [7, 8, 10, 20]).order("date_realisee", { ascending: false, nullsFirst: false }).limit(200),
  ]);

  const Tableau = ({ titre, rows, vide }: { titre: string; rows: LigneIntervention[] | null; vide: string }) => (
    <div className="flex flex-col gap-1">
      <h2 className="text-sm font-semibold">{titre}</h2>
      {rows && rows.length > 0 ? (
        <div className="overflow-x-auto rounded border">
          <table className="w-full border-collapse text-xs">
            <thead>
              <tr className="border-b bg-black/[0.03] text-left dark:bg-white/[0.05]">
                {["Intervenant", "Date limite", "Effectuée le", "Date d'appel", "Devis à faire", "Devis fait", "N° Bon", "N° Devis Accepté", "N° DI", "Type Interv", "Statut Inter", "Statut Facturation", "Comm. Inter."].map((h) => (
                  <th key={h} className="whitespace-nowrap px-2 py-1 font-medium">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {rows.map((i) => (
                <tr key={i.id} className="border-b last:border-0 hover:bg-blue-50 dark:hover:bg-blue-950/30">
                  <td className="whitespace-nowrap px-2 py-1">
                    <Link href={`/interventions/${i.id}`} className="underline">
                      {i.intervenant_nom ?? "—"}
                    </Link>
                  </td>
                  <td className="whitespace-nowrap px-2 py-1">{formatDate(i.date_limite)}</td>
                  <td className="whitespace-nowrap px-2 py-1">{formatDate(i.date_realisee)}</td>
                  <td className="whitespace-nowrap px-2 py-1">{formatDate(i.date_demande)}</td>
                  <td className="px-2 py-1 text-center">
                    <input type="checkbox" readOnly checked={!!i.devis_a_faire} aria-label="Devis à faire" />
                  </td>
                  <td className="px-2 py-1 text-center">
                    <input type="checkbox" readOnly checked={!!i.devis_fait} aria-label="Devis fait" />
                  </td>
                  <td className="px-2 py-1">{i.numero_bon ?? ""}</td>
                  <td className="px-2 py-1">{i.numero_devis_accepte ?? ""}</td>
                  <td className="px-2 py-1">{i.reference_client ?? ""}</td>
                  <td className="whitespace-nowrap px-2 py-1">
                    <Badge tone={typeInterventionTone(i.type_code)}>{i.type_libelle ?? "—"}</Badge>
                  </td>
                  <td className="whitespace-nowrap px-2 py-1">
                    <Badge tone={statutInterventionTone(i.statut_code)}>{i.statut_libelle ?? "—"}</Badge>
                  </td>
                  <td className="whitespace-nowrap px-2 py-1">{i.statut_facturation_libelle ?? ""}</td>
                  <td className="max-w-xs truncate px-2 py-1" title={i.commentaire_interne ?? ""}>
                    {i.commentaire_interne ?? ""}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <EmptyState message={vide} />
      )}
    </div>
  );

  return (
    <div className="flex flex-col gap-4">
      <Tableau titre="Interventions en cours :" rows={enCours as LigneIntervention[] | null} vide="Aucune intervention en cours." />
      <Tableau titre="Interventions clôturées :" rows={cloturees as LigneIntervention[] | null} vide="Aucune intervention clôturée." />
    </div>
  );
}

type LigneDevis = { id: number; numero: string | null; statut_code: number | null; montant_ht: number | null; date_envoi: string | null; fichier_chemin: string | null };

/** Onglets « Contrat de maintenance », « Devis SAV », « Devis Travaux » : la liste des devis du site pour la famille. */
async function SiteDevis({ famille, devis, siteId }: { famille: FamilleDevis; devis: LigneDevis[]; siteId: string }) {
  const supabase = await createClient();
  const { data: statuts } = await supabase.from("statuts_devis").select("code, libelle");
  const libelle = (code: number | null) => statuts?.find((s) => s.code === code)?.libelle ?? (code == null ? "—" : `Statut ${code}`);

  return (
    <div className="flex flex-col gap-2">
      <div>
        <Link href={`/devis/nouveau?site=${siteId}&famille=${famille}`} className={BOUTON}>
          Nouveau devis
        </Link>
      </div>
      {devis.length === 0 ? (
        <EmptyState message="Aucun devis de cette famille pour ce site." />
      ) : (
        <div className="overflow-x-auto rounded border">
          <table className="w-full border-collapse text-xs">
            <thead>
              <tr className="border-b bg-black/[0.03] text-left dark:bg-white/[0.05]">
                {["N° devis", "Statut", "Date d'envoi", "Montant HT", "Fichier"].map((h) => (
                  <th key={h} className="whitespace-nowrap px-2 py-1 font-medium">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {devis.map((d) => (
                <tr key={d.id} className="border-b last:border-0 hover:bg-blue-50 dark:hover:bg-blue-950/30">
                  <td className="px-2 py-1">
                    <Link href={`/devis/${d.id}`} className="underline">
                      {d.numero ?? `#${d.id}`}
                    </Link>
                  </td>
                  <td className="px-2 py-1">
                    <Badge tone={statutDevisTone(d.statut_code)}>{libelle(d.statut_code)}</Badge>
                  </td>
                  <td className="px-2 py-1">{formatDate(d.date_envoi)}</td>
                  <td className="px-2 py-1 text-right">{formatMontant(d.montant_ht)}</td>
                  <td className="max-w-xs truncate px-2 py-1" title={d.fichier_chemin ?? ""}>
                    {d.fichier_chemin ?? ""}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
