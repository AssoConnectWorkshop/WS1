import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/Badge";
import { Tabs } from "@/components/ui/Tabs";
import { KeyValue } from "@/components/ui/KeyValue";
import { EmptyState } from "@/components/ui/EmptyState";
import { typeInterventionTone, statutInterventionTone } from "@/lib/badges";
import { formatDate, formatDateTime, formatMontant, formatTime, oui } from "@/lib/format";
import { toStringParams } from "@/lib/list-params";

export const dynamic = "force-dynamic";

const ONGLETS = [
  { key: "demande", label: "Demande" },
  { key: "realisation", label: "Réalisation" },
  { key: "devis", label: "Devis" },
  { key: "signatures", label: "Signatures" },
  { key: "facturation", label: "Facturation" },
  { key: "historique", label: "Historique" },
];

function chemin(value: string | null) {
  if (!value) return "—";
  if (/^https?:\/\//i.test(value)) {
    return (
      <a href={value} target="_blank" rel="noreferrer" className="underline">
        {value}
      </a>
    );
  }
  return <span className="font-mono text-xs">{value}</span>;
}

export default async function InterventionPage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { id } = await params;
  const sp = toStringParams(await searchParams);
  const onglet = ONGLETS.some((o) => o.key === sp.onglet) ? sp.onglet! : "demande";

  const supabase = await createClient();
  const { data: intervention } = await supabase.from("interventions").select("*").eq("id", id).maybeSingle();

  if (!intervention) notFound();

  const [{ data: site }, { data: panne }, { data: typeInterv }, { data: statutInterv }, { data: statutFacturation }, { data: sousType }] =
    await Promise.all([
      supabase
        .from("sites")
        .select("id, nom, ville, adresse, code_postal, client_id, garantie_pieces_annees, garantie_pieces_mo_annees, garantie_compresseur_annees, date_mise_en_service")
        .eq("id", intervention.site_id)
        .maybeSingle(),
      intervention.panne_code != null
        ? supabase.from("pannes").select("libelle").eq("code", intervention.panne_code).maybeSingle()
        : Promise.resolve({ data: null }),
      intervention.type_code != null
        ? supabase.from("types_intervention").select("libelle").eq("code", intervention.type_code).maybeSingle()
        : Promise.resolve({ data: null }),
      intervention.statut_code != null
        ? supabase.from("statuts_intervention").select("libelle").eq("code", intervention.statut_code).maybeSingle()
        : Promise.resolve({ data: null }),
      intervention.statut_facturation_code != null
        ? supabase.from("statuts_facturation").select("libelle").eq("code", intervention.statut_facturation_code).maybeSingle()
        : Promise.resolve({ data: null }),
      intervention.sous_type_code != null
        ? supabase.from("sous_types_intervention").select("libelle").eq("code", intervention.sous_type_code).maybeSingle()
        : Promise.resolve({ data: null }),
    ]);

  const { data: client } = site
    ? await supabase.from("clients").select("id, nom").eq("id", site.client_id).maybeSingle()
    : { data: null };

  const { data: intervenant } = intervention.intervenant_id
    ? await supabase.from("intervenants").select("id, nom").eq("id", intervention.intervenant_id).maybeSingle()
    : { data: null };

  const { data: contact } = intervention.contact_id
    ? await supabase.from("contacts").select("nom, prenom").eq("id", intervention.contact_id).maybeSingle()
    : { data: null };

  const utilisateurIds = [
    intervention.charge_affaire_id,
    intervention.saisi_par_id,
    intervention.prediag_par_id,
    intervention.envoye_sous_traitant_par_id,
    intervention.technicien_prevu_id,
  ].filter((v): v is number => v != null);
  const { data: utilisateursData } = utilisateurIds.length
    ? await supabase.from("utilisateurs").select("id, nom, prenom").in("id", utilisateurIds)
    : { data: [] };
  const utilisateurNom = (id: number | null) => {
    if (id == null) return "—";
    const u = (utilisateursData ?? []).find((u) => u.id === id);
    return u ? [u.prenom, u.nom].filter(Boolean).join(" ") : "—";
  };

  const { data: techniciensLies } = await supabase
    .from("intervention_techniciens")
    .select("utilisateurs(nom, prenom)")
    .eq("intervention_id", id);
  const techniciens = ((techniciensLies ?? []) as unknown as { utilisateurs: { nom: string | null; prenom: string | null } | null }[])
    .map((t) => [t.utilisateurs?.prenom, t.utilisateurs?.nom].filter(Boolean).join(" "))
    .filter(Boolean);

  const { data: devisLies } = await supabase
    .from("devis")
    .select("id, famille, numero, statut_code, montant_ht")
    .or(`intervention_origine_id.eq.${id},numero.eq.${intervention.numero_devis_accepte ?? "__none__"}`);

  const { data: historique } = await supabase
    .from("interventions")
    .select("id, type_code, statut_code, date_realisee, date_limite, objet")
    .eq("site_id", intervention.site_id)
    .neq("id", id)
    .order("date_realisee", { ascending: false, nullsFirst: false })
    .limit(10);

  // Garantie en cours : approximation documentée (règle exacte non reprise depuis
  // legacy/analysis/03_clients_sites_materiel_intervenants.md §8.4).
  const garantieAnnees = site
    ? Math.max(site.garantie_pieces_annees ?? 0, site.garantie_pieces_mo_annees ?? 0, site.garantie_compresseur_annees ?? 0)
    : 0;
  let garantieEnCours = false;
  if (site?.date_mise_en_service && garantieAnnees > 0) {
    const fin = new Date(site.date_mise_en_service);
    fin.setFullYear(fin.getFullYear() + garantieAnnees);
    garantieEnCours = fin > new Date();
  }

  const { count: plusieursCeJour } = intervention.date_prevue
    ? await supabase
        .from("interventions")
        .select("id", { count: "exact", head: true })
        .eq("site_id", intervention.site_id)
        .eq("date_prevue", intervention.date_prevue)
        .neq("id", id)
    : { count: 0 };

  return (
    <div className="mx-auto flex max-w-5xl flex-col gap-4 p-8">
      <div className="flex flex-wrap items-center gap-2">
        <Badge tone={typeInterventionTone(intervention.type_code)}>{typeInterv?.libelle ?? intervention.type_brut ?? "—"}</Badge>
        <Badge tone={statutInterventionTone(intervention.statut_code)}>{statutInterv?.libelle ?? "—"}</Badge>
        {site && (
          <Link href={`/sites/${site.id}`} className="text-sm underline">
            {site.nom} ({site.ville})
          </Link>
        )}
        {garantieEnCours && <Badge tone="green">Garantie en cours</Badge>}
        {(plusieursCeJour ?? 0) > 0 && <Badge tone="orange">Plusieurs interventions ce jour</Badge>}
        {intervention.location_nacelle && <Badge tone="purple">Nacelle</Badge>}
      </div>

      <h1 className="text-xl font-semibold">
        Intervention n°{intervention.legacy_id} {intervention.numero_bon ? `· Bon n°${intervention.numero_bon}` : ""}
      </h1>

      <Tabs tabs={ONGLETS} active={onglet} searchParams={sp} />

      {onglet === "demande" && (
        <KeyValue
          items={[
            { label: "Client", value: client ? <Link className="underline" href={`/clients/${client.id}`}>{client.nom}</Link> : "—" },
            { label: "Site", value: site ? <Link className="underline" href={`/sites/${site.id}`}>{site.nom}</Link> : "—" },
            { label: "N° DI client", value: intervention.reference_client },
            { label: "N° devis accepté", value: intervention.numero_devis_accepte },
            { label: "Date de demande", value: formatDateTime(intervention.date_demande) },
            { label: "Objet", value: intervention.objet },
            { label: "Nature", value: intervention.nature_visite_code },
            { label: "Contact", value: contact ? [contact.prenom, contact.nom].filter(Boolean).join(" ") : "—" },
            { label: "Intervenant", value: intervenant?.nom ?? "—" },
            { label: "N° demande sous-traitant", value: intervention.numero_demande_sous_traitant },
            { label: "Directives", value: intervention.directives },
            { label: "Type", value: typeInterv?.libelle ?? intervention.type_brut },
            { label: "Sous-type", value: sousType?.libelle },
            { label: "Chargé d'affaire", value: utilisateurNom(intervention.charge_affaire_id) },
            { label: "Date limite", value: formatDateTime(intervention.date_limite) },
            { label: "Date prévue", value: formatDate(intervention.date_prevue) },
            { label: "Heure prévue", value: formatTime(intervention.heure_prevue) },
            { label: "Technicien prévu", value: utilisateurNom(intervention.technicien_prevu_id) },
            { label: "Statut", value: statutInterv?.libelle },
            { label: "Pré-diagnostic résolu", value: oui(intervention.prediag_resolu) },
            { label: "Par", value: utilisateurNom(intervention.prediag_par_id) },
            { label: "Minutes téléphone", value: intervention.minutes_telephone },
            { label: "Commentaire interne", value: intervention.commentaire_interne },
            { label: "Rappels", value: [intervention.rappel_24h && "24h", intervention.rappel_48h && "48h", intervention.rappel_72h && "72h", intervention.rappel_semaine && "semaine"].filter(Boolean).join(", ") || "—" },
          ]}
        />
      )}

      {onglet === "realisation" && (
        <KeyValue
          items={[
            { label: "Date réalisée", value: formatDate(intervention.date_realisee) },
            { label: "N° de bon", value: intervention.numero_bon },
            { label: "Heure d'arrivée", value: formatTime(intervention.heure_arrivee) },
            { label: "Heure de départ", value: formatTime(intervention.heure_depart) },
            { label: "Temps aller", value: formatTime(intervention.temps_aller) },
            { label: "Temps retour", value: formatTime(intervention.temps_retour) },
            { label: "Nombre de techniciens", value: intervention.nombre_techniciens },
            { label: "Techniciens intervenus", value: techniciens.length ? techniciens.join(", ") : "—" },
            { label: "Retour fiche", value: [intervention.retour_fiche_original && "original", intervention.retour_fiche_copie && "copie", intervention.retour_fiche_numerique && "numérique"].filter(Boolean).join(", ") || "—" },
            { label: "Panne", value: panne?.libelle },
            { label: "Panne d'origine externe", value: oui(intervention.panne_origine_externe) },
            { label: "Prestations réalisées", value: intervention.prestations_realisees },
            { label: "Commentaire technicien", value: intervention.commentaire_technicien },
            { label: "Commentaire clôture", value: intervention.commentaire_cloture_panne },
            { label: "Devis à faire", value: oui(intervention.devis_a_faire) },
            { label: "Devis fait", value: oui(intervention.devis_fait) },
            { label: "Devis ne sera pas fait", value: oui(intervention.devis_ne_sera_pas_fait) },
            { label: "Registre mis à jour", value: oui(intervention.registre_securite_mis_a_jour) },
            { label: "Contrôle étanchéité annuel", value: oui(intervention.controle_etancheite_annuel) },
            { label: "Contrôle étanchéité ponctuel", value: oui(intervention.controle_etancheite_ponctuel) },
            { label: "Quantité de gaz (kg)", value: intervention.quantite_gaz_kg },
            { label: "Photo faite", value: oui(intervention.photo_faite) },
            { label: "Audit fait", value: oui(intervention.audit_fait) },
            { label: "Chemin bon PDF", value: chemin(intervention.chemin_bon_pdf) },
            { label: "Dossier étanchéité", value: chemin(intervention.chemin_dossier_etancheite) },
          ]}
        />
      )}

      {onglet === "devis" &&
        (devisLies && devisLies.length > 0 ? (
          <ul className="flex flex-col gap-2">
            {devisLies.map((d) => (
              <li key={d.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
                <span>
                  {d.famille} · {d.numero} · statut {d.statut_code}
                </span>
                <span>{formatMontant(d.montant_ht)}</span>
              </li>
            ))}
          </ul>
        ) : (
          <EmptyState message="Aucun devis lié à cette intervention." />
        ))}

      {onglet === "signatures" && (
        <KeyValue
          items={[
            { label: "Signature site", value: intervention.signature_site_nom ?? chemin(intervention.signature_site_image) },
            { label: "Signature client", value: intervention.signature_client_nom ?? chemin(intervention.signature_client_image) },
            { label: "Signature technicien", value: intervention.signature_technicien_nom ?? chemin(intervention.signature_technicien_image) },
          ]}
        />
      )}

      {onglet === "facturation" && (
        <KeyValue
          items={[
            { label: "Montant FMC", value: formatMontant(intervention.montant_fmc) },
            { label: "Montant sous-traitant", value: formatMontant(intervention.montant_sous_traitant) },
            {
              label: "Différence",
              value: formatMontant((intervention.montant_fmc ?? 0) - (intervention.montant_sous_traitant ?? 0)),
            },
            { label: "Statut facturation", value: statutFacturation?.libelle },
            { label: "Date de facturation", value: formatDate(intervention.date_facturation) },
            { label: "Non facturable", value: oui(intervention.non_facturable) },
            { label: "Chemin facture FMC", value: chemin(intervention.chemin_facture_fmc) },
            { label: "Chemin facture sous-traitant", value: chemin(intervention.chemin_facture_sous_traitant) },
          ]}
        />
      )}

      {onglet === "historique" &&
        (historique && historique.length > 0 ? (
          <ul className="flex flex-col gap-2">
            {historique.map((h) => (
              <li key={h.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
                <Link href={`/interventions/${h.id}`} className="underline">
                  {h.objet ?? `Intervention ${h.id}`}
                </Link>
                <span className="opacity-70">{formatDate(h.date_realisee ?? h.date_limite)}</span>
              </li>
            ))}
          </ul>
        ) : (
          <EmptyState message="Aucune autre intervention sur ce site." />
        ))}
    </div>
  );
}
