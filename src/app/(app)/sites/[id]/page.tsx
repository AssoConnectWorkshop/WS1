import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/Badge";
import { Tabs } from "@/components/ui/Tabs";
import { KeyValue } from "@/components/ui/KeyValue";
import { EmptyState } from "@/components/ui/EmptyState";
import { statutInterventionTone } from "@/lib/badges";
import { formatDate, formatMontant, formatNombre, oui } from "@/lib/format";
import { toStringParams } from "@/lib/list-params";

export const dynamic = "force-dynamic";

const ONGLETS = [
  { key: "site", label: "Site" },
  { key: "interventions", label: "Interventions" },
  { key: "materiel", label: "Matériel" },
  { key: "registre", label: "Registre de sécurité" },
  { key: "devis", label: "Devis" },
  { key: "documents", label: "Documents" },
];

const JOURS = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"];

export default async function SitePage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { id } = await params;
  const sp = toStringParams(await searchParams);
  const onglet = ONGLETS.some((o) => o.key === sp.onglet) ? sp.onglet! : "site";

  const supabase = await createClient();
  const { data: site } = await supabase.from("sites").select("*").eq("id", id).maybeSingle();
  if (!site) notFound();

  const [{ data: client }, { data: contrats }, { data: horaires }, { data: zone }, { data: intervenant }, { data: donneur }] = await Promise.all([
    supabase.from("clients").select("id, nom").eq("id", site.client_id).maybeSingle(),
    supabase.from("site_contrats").select("*").eq("site_id", id),
    supabase.from("site_horaires").select("*").eq("site_id", id).order("jour"),
    site.zone_id ? supabase.from("zones_geographiques").select("libelle").eq("id", site.zone_id).maybeSingle() : Promise.resolve({ data: null }),
    site.intervenant_id ? supabase.from("intervenants").select("id, nom").eq("id", site.intervenant_id).maybeSingle() : Promise.resolve({ data: null }),
    site.donneur_ordre_id ? supabase.from("donneurs_ordre").select("id, nom").eq("id", site.donneur_ordre_id).maybeSingle() : Promise.resolve({ data: null }),
  ]);

  const { data: devisLies } = await supabase.from("devis").select("id, famille, numero, statut_code, montant_ht").eq("site_id", id);
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

  return (
    <div className="mx-auto flex max-w-5xl flex-col gap-4 p-8">
      {(site.ne_plus_intervenir || site.retard_paiement) && (
        <div className="rounded-lg bg-red-50 p-3 text-sm text-red-700">
          {site.ne_plus_intervenir && <div>Ne plus intervenir sur ce site.</div>}
          {site.retard_paiement && <div>Retard de paiement.</div>}
        </div>
      )}

      <div className="flex flex-wrap items-center gap-2">
        {devisEnCours.length > 0 && <Badge tone="yellow">{devisEnCours.length} devis en cours</Badge>}
        {garantieEnCours && <Badge tone="green">Garantie en cours</Badge>}
        {(ceAEditer ?? 0) > 0 && <Badge tone="orange">{ceAEditer} CE à éditer</Badge>}
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
      </p>

      <Tabs tabs={ONGLETS} active={onglet} searchParams={sp} />

      {onglet === "site" && (
        <div className="flex flex-col gap-6">
          <KeyValue
            items={[
              { label: "Code", value: site.code_client },
              { label: "Adresse", value: `${site.adresse ?? ""} ${site.code_postal ?? ""} ${site.ville ?? ""}`.trim() },
              { label: "Téléphone", value: site.telephone },
              { label: "Zone", value: zone?.libelle },
              { label: "Intervenant", value: intervenant ? <Link className="underline" href={`/intervenants/${intervenant.id}`}>{intervenant.nom}</Link> : "—" },
              { label: "Donneur d'ordre", value: donneur ? <Link className="underline" href={`/donneurs-ordre/${donneur.id}`}>{donneur.nom}</Link> : "—" },
              { label: "Situation", value: site.situation },
              { label: "Type (H/F)", value: site.type_site },
              { label: "Date de mise en service", value: formatDate(site.date_mise_en_service) },
              { label: "Indice qualité", value: "★".repeat(site.indice_qualite ?? 0) || "—" },
              { label: "Indice vétusté", value: "★".repeat(site.indice_vetuste ?? 0) || "—" },
              { label: "Visites/an (pivot)", value: formatNombre(site.visites_entretien_par_an) },
              { label: "Dernière visite entretien", value: formatDate(site.date_derniere_visite_entretien) },
              { label: "Tarifs spécifiques", value: oui(site.tarifs_specifiques) },
              { label: "Tarif horaire MO", value: formatMontant(site.tarif_heure_mo) },
              { label: "Tarif déplacement", value: formatMontant(site.tarif_deplacement) },
              { label: "Particulier", value: oui(site.particulier) },
              { label: "Nacelle nécessaire", value: oui(site.nacelle_necessaire) },
              { label: "Investissement", value: oui(site.investissement) },
              { label: "Fermé", value: oui(site.ferme) },
            ]}
          />

          <div>
            <h2 className="mb-2 text-sm font-semibold opacity-70">Contrats par lot</h2>
            {contrats && contrats.length > 0 ? (
              <table className="w-full border-collapse text-sm">
                <thead>
                  <tr className="border-b text-left">
                    <th className="py-1">Lot</th>
                    <th>N° contrat</th>
                    <th>Visites/an</th>
                    <th>Redevance</th>
                  </tr>
                </thead>
                <tbody>
                  {contrats.map((c) => (
                    <tr key={c.id} className="border-b">
                      <td className="py-1 capitalize">{c.lot}</td>
                      <td>{c.numero_contrat ?? "—"}</td>
                      <td>{formatNombre(c.visites_par_an)}</td>
                      <td>{formatMontant(c.redevance)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : (
              <EmptyState message="Aucun contrat." />
            )}
          </div>

          <div>
            <h2 className="mb-2 text-sm font-semibold opacity-70">Horaires</h2>
            {horaires && horaires.length > 0 ? (
              <ul className="grid grid-cols-2 gap-1 text-sm sm:grid-cols-3">
                {horaires.map((h) => (
                  <li key={h.id}>
                    {JOURS[h.jour - 1]} : {h.ouverture ?? "—"} – {h.fermeture ?? "—"}
                  </li>
                ))}
              </ul>
            ) : (
              <EmptyState message="Aucun horaire renseigné." />
            )}
          </div>
        </div>
      )}

      {onglet === "interventions" && <SiteInterventions siteId={id} />}
      {onglet === "materiel" && <SiteMateriel siteId={id} />}
      {onglet === "registre" && <SiteRegistre siteId={id} />}

      {onglet === "devis" &&
        (devisLies && devisLies.length > 0 ? (
          <ul className="flex flex-col gap-2">
            {devisLies.map((d) => (
              <li key={d.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
                <span className="capitalize">
                  {d.famille} · {d.numero}
                </span>
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
            { label: "Dossier réseau", value: site.dossier_chemin ? <span className="font-mono text-xs">{site.dossier_chemin}</span> : "—" },
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

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h2 className="mb-2 text-sm font-semibold opacity-70">En cours</h2>
        {enCours && enCours.length > 0 ? (
          <ul className="flex flex-col gap-2">
            {enCours.map((i) => (
              <li key={i.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
                <Link href={`/interventions/${i.id}`} className="underline">
                  {i.objet ?? i.type_libelle}
                </Link>
                <span className="flex items-center gap-2">
                  <Badge tone={statutInterventionTone(i.statut_code)}>{i.statut_libelle}</Badge>
                  {formatDate(i.date_limite)}
                </span>
              </li>
            ))}
          </ul>
        ) : (
          <EmptyState message="Aucune intervention en cours." />
        )}
      </div>
      <div>
        <h2 className="mb-2 text-sm font-semibold opacity-70">Clôturées</h2>
        {cloturees && cloturees.length > 0 ? (
          <ul className="flex flex-col gap-2">
            {cloturees.map((i) => (
              <li key={i.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
                <Link href={`/interventions/${i.id}`} className="underline">
                  {i.objet ?? i.type_libelle}
                </Link>
                <span className="flex items-center gap-2">
                  <Badge tone={statutInterventionTone(i.statut_code)}>{i.statut_libelle}</Badge>
                  {formatDate(i.date_realisee)}
                </span>
              </li>
            ))}
          </ul>
        ) : (
          <EmptyState message="Aucune intervention clôturée." />
        )}
      </div>
    </div>
  );
}

async function SiteMateriel({ siteId }: { siteId: string }) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("site_materiels")
    .select("id, repere, marque, type_equipement, reference, numero_serie, fluide_libelle, charge_fluide_kg, certificat_etancheite_edite")
    .eq("site_id", siteId)
    .order("repere_sur_site");

  if (!data || data.length === 0) return <EmptyState message="Aucun matériel enregistré." />;

  return (
    <table className="w-full border-collapse text-sm">
      <thead>
        <tr className="border-b text-left">
          <th className="py-1">Repère</th>
          <th>Marque</th>
          <th>Type</th>
          <th>Référence</th>
          <th>N° série</th>
          <th>Fluide</th>
          <th className="text-right">Charge (kg)</th>
          <th>CE</th>
        </tr>
      </thead>
      <tbody>
        {data.map((m) => (
          <tr key={m.id} className="border-b">
            <td className="py-1">{m.repere ?? "—"}</td>
            <td>{m.marque ?? "—"}</td>
            <td>{m.type_equipement ?? "—"}</td>
            <td>{m.reference ?? "—"}</td>
            <td>{m.numero_serie ?? "—"}</td>
            <td>{m.fluide_libelle ?? "—"}</td>
            <td className="text-right">{formatNombre(m.charge_fluide_kg)}</td>
            <td>{oui(m.certificat_etancheite_edite)}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

async function SiteRegistre({ siteId }: { siteId: string }) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("site_registre_securite")
    .select("id, date_mise_a_jour")
    .eq("site_id", siteId)
    .order("date_mise_a_jour", { ascending: false });

  if (!data || data.length === 0) return <EmptyState message="Aucune mise à jour du registre." />;

  return (
    <ul className="flex flex-col gap-1 text-sm">
      {data.map((r) => (
        <li key={r.id}>{formatDate(r.date_mise_a_jour)}</li>
      ))}
    </ul>
  );
}
