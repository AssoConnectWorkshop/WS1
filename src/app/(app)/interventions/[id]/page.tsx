import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser } from "@/lib/auth";
import { Badge } from "@/components/ui/Badge";
import { Tabs } from "@/components/ui/Tabs";
import { KeyValue } from "@/components/ui/KeyValue";
import { EmptyState } from "@/components/ui/EmptyState";
import { typeInterventionTone, statutInterventionTone } from "@/lib/badges";
import { formatDate, formatDateTime, formatMontant, formatTime, oui } from "@/lib/format";
import { toStringParams } from "@/lib/list-params";
import {
  mettreAJourDemande,
  mettreAJourRealisation,
  mettreAJourFacturation,
  basculerResoluTelephone,
  cloturerIntervention,
  confirmerReplanification,
  declôturerIntervention,
  validerIntervention,
  ajouterTechnicien,
  retirerTechnicien,
  nouvelleInterventionDepuis,
  creerPartieSuivante,
} from "../actions";

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

  const [{ data: site }, { data: typeInterv }, { data: statutInterv }, { data: sousType }] = await Promise.all([
    supabase
      .from("sites")
      .select("id, nom, ville, adresse, code_postal, client_id, garantie_pieces_annees, garantie_pieces_mo_annees, garantie_compresseur_annees, date_mise_en_service")
      .eq("id", intervention.site_id)
      .maybeSingle(),
    intervention.type_code != null
      ? supabase.from("types_intervention").select("libelle").eq("code", intervention.type_code).maybeSingle()
      : Promise.resolve({ data: null }),
    intervention.statut_code != null
      ? supabase.from("statuts_intervention").select("libelle").eq("code", intervention.statut_code).maybeSingle()
      : Promise.resolve({ data: null }),
    intervention.sous_type_code != null
      ? supabase.from("sous_types_intervention").select("libelle").eq("code", intervention.sous_type_code).maybeSingle()
      : Promise.resolve({ data: null }),
  ]);

  const { data: client } = site
    ? await supabase.from("clients").select("id, nom").eq("id", site.client_id).maybeSingle()
    : { data: null };

  const { data: intervenant } = intervention.intervenant_id
    ? await supabase.from("intervenants").select("id, nom, code").eq("id", intervention.intervenant_id).maybeSingle()
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
  const utilisateurNom = (utilisateurId: number | null) => {
    if (utilisateurId == null) return "—";
    const u = (utilisateursData ?? []).find((u) => u.id === utilisateurId);
    return u ? [u.prenom, u.nom].filter(Boolean).join(" ") : "—";
  };

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

  const current = await getCurrentUser();
  const [{ data: pannes }, { data: statutsFacturation }] = await Promise.all([
    supabase.from("pannes").select("code, libelle").order("code"),
    supabase.from("statuts_facturation").select("code, libelle, reserve_admin").order("ordre_affichage"),
  ]);

  const { data: techniciensLignesData } = await supabase
    .from("intervention_techniciens")
    .select("id, utilisateur_id, utilisateurs(nom, prenom)")
    .eq("intervention_id", id);
  const techniciensLignes = (techniciensLignesData ?? []) as unknown as {
    id: number;
    utilisateur_id: number | null;
    utilisateurs: { nom: string | null; prenom: string | null } | null;
  }[];

  // Techniciens éligibles : profil technicien (2) dont code_intervenant = code de
  // l'intervenant de l'intervention, ou société FMC (brief §5.1).
  const codesEligibles = [...new Set([intervenant?.code, "FMC"].filter((c): c is string => !!c))];
  const { data: techniciensEligiblesData } = await supabase
    .from("utilisateurs")
    .select("id, nom, prenom")
    .eq("profil", 2)
    .in("code_intervenant", codesEligibles)
    .order("nom");
  const techniciensEligibles = techniciensEligiblesData ?? [];

  const estAdministrateur = current?.role === "administrateur";

  return (
    <div className="mx-auto flex max-w-5xl flex-col gap-4 p-8">
      {sp.erreur && <p className="rounded-md bg-red-50 p-3 text-sm text-red-700">{sp.erreur}</p>}
      {sp.avertissement && <p className="rounded-md bg-yellow-50 p-3 text-sm text-yellow-800">{sp.avertissement}</p>}
      {sp.info && <p className="rounded-md bg-blue-50 p-3 text-sm text-blue-800">{sp.info}</p>}
      {sp.proposer_replanification === "1" && (
        <form action={confirmerReplanification} className="flex items-center justify-between gap-3 rounded-md bg-orange-50 p-3 text-sm text-orange-800">
          <input type="hidden" name="intervention_id" value={id} />
          <input type="hidden" name="site_id" value={intervention.site_id} />
          <span>
            Ce site a 2 ou 4 visites/an et la clôture intervient avant juillet/octobre : annuler les entretiens
            prévus non réalisés et régénérer la planification (étape 5.4) ?
          </span>
          <button type="submit" className="whitespace-nowrap rounded-md border border-orange-300 px-3 py-1">
            Annuler les entretiens non réalisés
          </button>
        </form>
      )}

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

      <div className="flex flex-wrap gap-2">
        {intervention.statut_code === 1 && (
          <form action={cloturerIntervention}>
            <input type="hidden" name="intervention_id" value={id} />
            <button type="submit" className="rounded-md border px-3 py-1.5 text-sm">
              Clôturer
            </button>
          </form>
        )}
        {intervention.statut_code === 9 && (
          <>
            <form action={declôturerIntervention}>
              <input type="hidden" name="intervention_id" value={id} />
              <button type="submit" className="rounded-md border px-3 py-1.5 text-sm">
                Déclôturer
              </button>
            </form>
            <form action={validerIntervention}>
              <input type="hidden" name="intervention_id" value={id} />
              <button type="submit" className="rounded-md border px-3 py-1.5 text-sm">
                Valider (statut Clôturé)
              </button>
            </form>
          </>
        )}
        <form action={basculerResoluTelephone} className="flex items-center gap-2">
          <input type="hidden" name="intervention_id" value={id} />
          <input type="hidden" name="actif" value={intervention.statut_code === 10 ? "0" : "1"} />
          {intervention.statut_code !== 10 && (
            <input
              name="minutes_telephone"
              type="number"
              min={1}
              placeholder="Minutes"
              className="w-20 rounded-md border px-2 py-1 text-sm"
            />
          )}
          <button type="submit" className="rounded-md border px-3 py-1.5 text-sm">
            {intervention.statut_code === 10 ? "Annuler « résolu par téléphone »" : "Résolu par téléphone"}
          </button>
        </form>
        <form action={nouvelleInterventionDepuis}>
          <input type="hidden" name="intervention_id" value={id} />
          <button type="submit" className="rounded-md border px-3 py-1.5 text-sm">
            Nouvelle intervention à partir de celle-ci
          </button>
        </form>
        <form action={creerPartieSuivante}>
          <input type="hidden" name="intervention_id" value={id} />
          <button type="submit" className="rounded-md border px-3 py-1.5 text-sm">
            Partie suivante
          </button>
        </form>
      </div>

      <Tabs tabs={ONGLETS} active={onglet} searchParams={sp} />

      {onglet === "demande" && (
        <div className="flex flex-col gap-6">
          <KeyValue
            items={[
              { label: "Client", value: client ? <Link className="underline" href={`/clients/${client.id}`}>{client.nom}</Link> : "—" },
              { label: "Site", value: site ? <Link className="underline" href={`/sites/${site.id}`}>{site.nom}</Link> : "—" },
              { label: "N° devis accepté", value: intervention.numero_devis_accepte },
              { label: "Date de demande", value: formatDateTime(intervention.date_demande) },
              { label: "Contact", value: contact ? [contact.prenom, contact.nom].filter(Boolean).join(" ") : "—" },
              { label: "Intervenant", value: intervenant?.nom ?? "—" },
              { label: "N° demande sous-traitant", value: intervention.numero_demande_sous_traitant },
              { label: "Type", value: typeInterv?.libelle ?? intervention.type_brut },
              { label: "Sous-type", value: sousType?.libelle },
              { label: "Chargé d'affaire", value: utilisateurNom(intervention.charge_affaire_id) },
              { label: "Heure prévue", value: formatTime(intervention.heure_prevue) },
              { label: "Technicien prévu", value: utilisateurNom(intervention.technicien_prevu_id) },
              { label: "Statut", value: statutInterv?.libelle },
              { label: "Pré-diagnostic résolu", value: oui(intervention.prediag_resolu) },
              { label: "Par", value: utilisateurNom(intervention.prediag_par_id) },
              { label: "Minutes téléphone", value: intervention.minutes_telephone },
              { label: "Rappels", value: [intervention.rappel_24h && "24h", intervention.rappel_48h && "48h", intervention.rappel_72h && "72h", intervention.rappel_semaine && "semaine"].filter(Boolean).join(", ") || "—" },
            ]}
          />

          <form action={mettreAJourDemande} className="flex flex-col gap-3 rounded-xl border p-4">
            <h2 className="text-sm font-semibold opacity-70">Modifier</h2>
            <input type="hidden" name="intervention_id" value={id} />
            <label className="flex flex-col gap-1 text-sm">
              Objet *
              <input name="objet" defaultValue={intervention.objet ?? ""} required className="rounded-md border px-3 py-2" />
            </label>
            <label className="flex flex-col gap-1 text-sm">
              N° de DI client
              <input name="reference_client" defaultValue={intervention.reference_client ?? ""} className="rounded-md border px-3 py-2" />
            </label>
            <div className="grid grid-cols-2 gap-3">
              <label className="flex flex-col gap-1 text-sm">
                Date limite
                <input name="date_limite" type="date" defaultValue={intervention.date_limite?.slice(0, 10) ?? ""} className="rounded-md border px-3 py-2" />
              </label>
              <label className="flex flex-col gap-1 text-sm">
                Date prévue
                <input name="date_prevue" type="date" defaultValue={intervention.date_prevue?.slice(0, 10) ?? ""} className="rounded-md border px-3 py-2" />
              </label>
            </div>
            <label className="flex flex-col gap-1 text-sm">
              Directives
              <textarea name="directives" defaultValue={intervention.directives ?? ""} rows={2} className="rounded-md border px-3 py-2" />
            </label>
            <label className="flex flex-col gap-1 text-sm">
              Commentaire interne
              <textarea name="commentaire_interne" defaultValue={intervention.commentaire_interne ?? ""} rows={2} className="rounded-md border px-3 py-2" />
            </label>
            <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
              Enregistrer
            </button>
          </form>
        </div>
      )}

      {onglet === "realisation" && (
        <div className="flex flex-col gap-6">
          <KeyValue
            items={[
              { label: "N° de bon", value: intervention.numero_bon },
              { label: "Temps aller", value: formatTime(intervention.temps_aller) },
              { label: "Temps retour", value: formatTime(intervention.temps_retour) },
              { label: "Nombre de techniciens", value: intervention.nombre_techniciens },
              { label: "Retour fiche", value: [intervention.retour_fiche_original && "original", intervention.retour_fiche_copie && "copie", intervention.retour_fiche_numerique && "numérique"].filter(Boolean).join(", ") || "—" },
              { label: "Panne d'origine externe", value: oui(intervention.panne_origine_externe) },
              { label: "Devis ne sera pas fait", value: oui(intervention.devis_ne_sera_pas_fait) },
              { label: "Contrôle étanchéité ponctuel", value: oui(intervention.controle_etancheite_ponctuel) },
              { label: "Quantité de gaz (kg)", value: intervention.quantite_gaz_kg },
              { label: "Photo faite", value: oui(intervention.photo_faite) },
              { label: "Audit fait", value: oui(intervention.audit_fait) },
              { label: "Chemin bon PDF", value: chemin(intervention.chemin_bon_pdf) },
              { label: "Dossier étanchéité", value: chemin(intervention.chemin_dossier_etancheite) },
            ]}
          />

          <div>
            <h2 className="mb-2 text-sm font-semibold opacity-70">Techniciens intervenus</h2>
            <ul className="mb-2 flex flex-col gap-1">
              {(techniciensLignes ?? []).map((t) => (
                <li key={t.id} className="flex items-center justify-between rounded-md border px-3 py-1.5 text-sm">
                  <span>{[t.utilisateurs?.prenom, t.utilisateurs?.nom].filter(Boolean).join(" ")}</span>
                  <form action={retirerTechnicien}>
                    <input type="hidden" name="intervention_id" value={id} />
                    <input type="hidden" name="ligne_id" value={t.id} />
                    <button type="submit" className="text-xs underline opacity-70">
                      Retirer
                    </button>
                  </form>
                </li>
              ))}
              {(techniciensLignes ?? []).length === 0 && <li className="text-sm opacity-60">Aucun technicien ajouté.</li>}
            </ul>
            <form action={ajouterTechnicien} className="flex items-center gap-2">
              <input type="hidden" name="intervention_id" value={id} />
              <select name="utilisateur_id" className="rounded-md border px-2 py-1 text-sm">
                <option value="">— Choisir un technicien —</option>
                {techniciensEligibles.map((t) => (
                  <option key={t.id} value={t.id}>
                    {[t.prenom, t.nom].filter(Boolean).join(" ")}
                  </option>
                ))}
              </select>
              <button type="submit" className="rounded-md border px-3 py-1 text-sm">
                Ajouter
              </button>
            </form>
          </div>

          <form action={mettreAJourRealisation} className="flex flex-col gap-3 rounded-xl border p-4">
            <h2 className="text-sm font-semibold opacity-70">Modifier</h2>
            <input type="hidden" name="intervention_id" value={id} />
            <div className="grid grid-cols-3 gap-3">
              <label className="flex flex-col gap-1 text-sm">
                Date réalisée
                <input name="date_realisee" type="date" defaultValue={intervention.date_realisee?.slice(0, 10) ?? ""} className="rounded-md border px-3 py-2" />
              </label>
              <label className="flex flex-col gap-1 text-sm">
                Heure d&apos;arrivée
                <input name="heure_arrivee" type="time" defaultValue={intervention.heure_arrivee?.slice(0, 5) ?? ""} className="rounded-md border px-3 py-2" />
              </label>
              <label className="flex flex-col gap-1 text-sm">
                Heure de départ
                <input name="heure_depart" type="time" defaultValue={intervention.heure_depart?.slice(0, 5) ?? ""} className="rounded-md border px-3 py-2" />
              </label>
            </div>
            <label className="flex flex-col gap-1 text-sm">
              Panne
              <select name="panne_code" defaultValue={intervention.panne_code ?? ""} className="rounded-md border px-3 py-2">
                <option value="">—</option>
                {(pannes ?? []).map((p) => (
                  <option key={p.code} value={p.code}>
                    {p.libelle}
                  </option>
                ))}
              </select>
            </label>
            <label className="flex flex-col gap-1 text-sm">
              Prestations réalisées
              <textarea name="prestations_realisees" defaultValue={intervention.prestations_realisees ?? ""} rows={2} className="rounded-md border px-3 py-2" />
            </label>
            <label className="flex flex-col gap-1 text-sm">
              Commentaire technicien
              <textarea name="commentaire_technicien" defaultValue={intervention.commentaire_technicien ?? ""} rows={2} className="rounded-md border px-3 py-2" />
            </label>
            <div className="flex flex-wrap gap-4 text-sm">
              <label className="flex items-center gap-1.5">
                <input type="checkbox" name="devis_a_faire" value="1" defaultChecked={!!intervention.devis_a_faire} />
                Devis à faire
              </label>
              <label className="flex items-center gap-1.5">
                <input type="checkbox" name="devis_fait" value="1" defaultChecked={!!intervention.devis_fait} />
                Devis fait
              </label>
              <label className="flex items-center gap-1.5">
                <input type="checkbox" name="registre_securite_mis_a_jour" value="1" defaultChecked={!!intervention.registre_securite_mis_a_jour} />
                Registre mis à jour
              </label>
            </div>
            <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
              Enregistrer
            </button>
          </form>
        </div>
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
        <div className="flex flex-col gap-6">
          <KeyValue
            items={[
              {
                label: "Différence",
                value: formatMontant((intervention.montant_fmc ?? 0) - (intervention.montant_sous_traitant ?? 0)),
              },
              { label: "Date de facturation", value: formatDate(intervention.date_facturation) },
              { label: "Non facturable", value: oui(intervention.non_facturable) },
              { label: "Chemin facture FMC", value: chemin(intervention.chemin_facture_fmc) },
              { label: "Chemin facture sous-traitant", value: chemin(intervention.chemin_facture_sous_traitant) },
            ]}
          />

          <form action={mettreAJourFacturation} className="flex flex-col gap-3 rounded-xl border p-4">
            <h2 className="text-sm font-semibold opacity-70">Modifier</h2>
            <input type="hidden" name="intervention_id" value={id} />
            <div className="grid grid-cols-2 gap-3">
              <label className="flex flex-col gap-1 text-sm">
                Montant FMC
                <input name="montant_fmc" type="number" step="0.01" defaultValue={intervention.montant_fmc ?? ""} className="rounded-md border px-3 py-2" />
              </label>
              <label className="flex flex-col gap-1 text-sm">
                Montant sous-traitant
                <input name="montant_sous_traitant" type="number" step="0.01" defaultValue={intervention.montant_sous_traitant ?? ""} className="rounded-md border px-3 py-2" />
              </label>
            </div>
            <label className="flex flex-col gap-1 text-sm">
              Statut facturation
              <select name="statut_facturation_code" defaultValue={intervention.statut_facturation_code ?? ""} className="rounded-md border px-3 py-2">
                <option value="">—</option>
                {(statutsFacturation ?? [])
                  .filter((s) => !s.reserve_admin || estAdministrateur)
                  .map((s) => (
                    <option key={s.code} value={s.code}>
                      {s.libelle}
                      {s.reserve_admin ? " (réservé admin)" : ""}
                    </option>
                  ))}
              </select>
            </label>
            <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
              Enregistrer
            </button>
          </form>
        </div>
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
