import Link from "next/link";
import { Champ, CHAMP } from "@/components/ui/Champ";
import { Messages } from "@/components/ui/Messages";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser, peutStatutsReserves } from "@/lib/auth";
import { Badge } from "@/components/ui/Badge";
import { Tabs } from "@/components/ui/Tabs";
import { KeyValue } from "@/components/ui/KeyValue";
import { Chemin } from "@/components/ui/Chemin";
import { ListeDevisAccess, type DevisAccess } from "@/components/devis/ListeDevisAccess";
import { typeInterventionTone } from "@/lib/badges";
import { formatDate, formatDateTime, formatMontant, formatTime, oui, formatNom } from "@/lib/format";
import { toStringParams } from "@/lib/list-params";
import {
  mettreAJourDemande,
  mettreAJourRealisation,
  mettreAJourFacturation,
  basculerResoluTelephone,
  cloturerIntervention,
  confirmerReplanification,
  decloturerIntervention,
  validerIntervention,
  ajouterTechnicien,
  retirerTechnicien,
  nouvelleInterventionDepuis,
  creerPartieSuivante,
  genererEtEnregistrerBon,
} from "../actions";

export const dynamic = "force-dynamic";

/** Onglets de Form_Intervention (capture lot 3). */
const ONGLETS = [
  { key: "demande", label: "Création d'intervention" },
  { key: "realisation", label: "Clôture de l'intervention en cours" },
  { key: "sav", label: "Devis SAV" },
  { key: "travaux", label: "Devis Travaux" },
  { key: "signatures", label: "Signatures" },
];

/** Couleur de la fenêtre Access selon le type (ColoreFenetre) : fond clair de la même teinte que le badge. */
const FOND_TYPE: Record<string, string> = {
  blue: "bg-sky-100 dark:bg-sky-950/30",
  green: "bg-green-100 dark:bg-green-950/30",
  pink: "bg-pink-100 dark:bg-pink-950/30",
  orange: "bg-orange-100 dark:bg-orange-950/30",
  purple: "bg-purple-100 dark:bg-purple-950/30",
  gray: "bg-gray-100 dark:bg-gray-900/30",
};

const URGENCES: Record<number, string> = { 1: "Faible", 2: "Moyenne", 3: "Forte" };
const PETIT = "w-full rounded border bg-white px-1.5 py-0.5 text-xs dark:bg-white/5";
const BOUTON = "rounded border bg-white px-2 py-1 text-xs dark:bg-white/5";
const FORM_CLOTURE = "cloture-intervention";

function Cadre({ titre, children, className = "" }: { titre?: string; children: React.ReactNode; className?: string }) {
  return (
    <fieldset className={`flex flex-col gap-1.5 rounded border px-2 pb-2 pt-1 ${className}`}>
      {titre && <legend className="px-1 text-xs font-semibold">{titre}</legend>}
      {children}
    </fieldset>
  );
}

function CaseF({ name, label, checked }: { name: string; label: string; checked: boolean | null | undefined }) {
  return (
    <label className="flex items-center gap-1.5 text-xs">
      <input form={FORM_CLOTURE} type="checkbox" name={name} value="1" defaultChecked={!!checked} />
      {label}
    </label>
  );
}

const intervalleHHMM = (v: string | null) => {
  if (!v) return "";
  const m = /^(?:(\d+) days? )?(\d{1,3}):(\d{2})/.exec(v);
  if (!m) return "";
  const heures = Number(m[2]) + Number(m[1] ?? 0) * 24;
  return `${String(heures).padStart(2, "0")}:${m[3]}`;
};

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

  const [{ data: site }, { data: typeInterv }, { data: statutInterv }, { data: sousType }, { data: statuts }, { data: fluides }, { data: gestionnaires }] = await Promise.all([
    supabase
      .from("sites")
      .select("id, nom, ville, adresse, code_postal, client_id, garantie_pieces_annees, garantie_pieces_mo_annees, garantie_compresseur_annees, date_mise_en_service, dossier_chemin")
      .eq("id", intervention.site_id)
      .maybeSingle(),
    intervention.type_code != null ? supabase.from("types_intervention").select("libelle").eq("code", intervention.type_code).maybeSingle() : Promise.resolve({ data: null }),
    intervention.statut_code != null ? supabase.from("statuts_intervention").select("libelle").eq("code", intervention.statut_code).maybeSingle() : Promise.resolve({ data: null }),
    intervention.sous_type_code != null ? supabase.from("sous_types_intervention").select("libelle").eq("code", intervention.sous_type_code).maybeSingle() : Promise.resolve({ data: null }),
    supabase.from("statuts_intervention").select("code, libelle").order("ordre_affichage"),
    supabase.from("types_fluide").select("code, libelle").order("libelle"),
    supabase.from("utilisateurs").select("id, nom, prenom").in("profil", [1, 3]).order("nom"),
  ]);

  const { data: client } = site ? await supabase.from("clients").select("id, nom").eq("id", site.client_id).maybeSingle() : { data: null };
  const { data: intervenant } = intervention.intervenant_id ? await supabase.from("intervenants").select("id, nom, code").eq("id", intervention.intervenant_id).maybeSingle() : { data: null };
  const { data: contact } = intervention.contact_id ? await supabase.from("contacts").select("nom, prenom").eq("id", intervention.contact_id).maybeSingle() : { data: null };

  const utilisateurIds = [intervention.charge_affaire_id, intervention.saisi_par_id, intervention.prediag_par_id, intervention.envoye_sous_traitant_par_id, intervention.technicien_prevu_id].filter(
    (v): v is number => v != null,
  );
  const { data: utilisateursData } = utilisateurIds.length ? await supabase.from("utilisateurs").select("id, nom, prenom").in("id", utilisateurIds) : { data: [] };
  const utilisateurNom = (utilisateurId: number | null) => {
    if (utilisateurId == null) return "—";
    const u = (utilisateursData ?? []).find((u) => u.id === utilisateurId);
    return u ? formatNom(u.prenom, u.nom) : "—";
  };

  const { data: devisLies } = await supabase
    .from("devis")
    .select("id, famille, numero, statut_code, fichier_chemin, intervention_origine_id, site_id, client_id, numero_devis_partenaire, type_panne_libelle, quantite_materiel, montant_fournitures, heures_mo, tarif_heure_mo, nombre_deplacements, tarif_deplacement, montant_ht, date_envoi, envoye_par_id")
    .is("supprime_le", null)
    .or(`intervention_origine_id.eq.${id},numero.eq.${intervention.numero_devis_accepte ?? "__none__"}`);

  // Garantie en cours : approximation documentée (règle exacte non reprise depuis analysis 03 §8.4).
  const garantieAnnees = site ? Math.max(site.garantie_pieces_annees ?? 0, site.garantie_pieces_mo_annees ?? 0, site.garantie_compresseur_annees ?? 0) : 0;
  let garantieEnCours = false;
  if (site?.date_mise_en_service && garantieAnnees > 0) {
    const fin = new Date(site.date_mise_en_service);
    fin.setFullYear(fin.getFullYear() + garantieAnnees);
    garantieEnCours = fin > new Date();
  }

  const { count: plusieursCeJour } = intervention.date_prevue
    ? await supabase.from("interventions").select("id", { count: "exact", head: true }).eq("site_id", intervention.site_id).eq("date_prevue", intervention.date_prevue).neq("id", id)
    : { count: 0 };

  const current = await getCurrentUser();
  const [{ data: pannes }, { data: statutsFacturation }] = await Promise.all([
    supabase.from("pannes").select("code, libelle").order("code"),
    supabase.from("statuts_facturation").select("code, libelle, reserve_admin").order("ordre_affichage"),
  ]);

  // Heures pointées par les techniciens (HeuresTech, clé = numéro de bon) : « on a vendu 4 h, il a passé 6 h ».
  const { data: heuresLignes } = intervention.numero_bon
    ? await supabase.from("heures_techniciens").select("heure_debut, heure_fin, ne_pas_comptabiliser").eq("intervention_numero_bon", intervention.numero_bon)
    : { data: [] };
  const minutes = (h: string | null) => (h ? Number(h.slice(0, 2)) * 60 + Number(h.slice(3, 5)) : null);
  const heuresPassees = (heuresLignes ?? []).reduce((total, l) => {
    if (l.ne_pas_comptabiliser) return total;
    const d = minutes(l.heure_debut);
    const f = minutes(l.heure_fin);
    return d != null && f != null && f > d ? total + (f - d) / 60 : total;
  }, 0);

  const { data: techniciensLignesData } = await supabase.from("intervention_techniciens").select("id, utilisateur_id, utilisateurs(nom, prenom)").eq("intervention_id", id);
  const techniciensLignes = (techniciensLignesData ?? []) as unknown as { id: number; utilisateur_id: number | null; utilisateurs: { nom: string | null; prenom: string | null } | null }[];

  // Techniciens éligibles : profil technicien (2) dont code_intervenant = code de l'intervenant, ou société FMC (brief §5.1).
  const codesEligibles = [...new Set([intervenant?.code, "FMC"].filter((c): c is string => !!c))];
  const { data: techniciensEligiblesData } = await supabase.from("utilisateurs").select("id, nom, prenom").eq("profil", 2).in("code_intervenant", codesEligibles).order("nom");
  const techniciensEligibles = techniciensEligiblesData ?? [];

  const estAdministrateur = peutStatutsReserves(current?.role);
  const fond = FOND_TYPE[typeInterventionTone(intervention.type_code)] ?? FOND_TYPE.gray;
  const optionsStatutFacturation = (statutsFacturation ?? []).filter((s) => !s.reserve_admin || estAdministrateur || s.code === intervention.statut_facturation_code);
  const LIGNE = "grid grid-cols-[8.5rem_1fr] items-center gap-x-2 gap-y-1 text-xs";

  return (
    <div className={`flex min-h-full flex-col gap-3 p-4 ${fond}`}>
      <Messages sp={sp} />
      {sp.proposer_replanification === "1" && (
        <form action={confirmerReplanification} className="flex items-center justify-between gap-3 rounded-md bg-orange-50 p-3 text-sm text-orange-800">
          <input type="hidden" name="intervention_id" value={id} />
          <input type="hidden" name="site_id" value={intervention.site_id} />
          <span>Ce site a 2 ou 4 visites/an et la clôture intervient avant juillet/octobre : annuler les entretiens prévus non réalisés et régénérer la planification (étape 5.4) ?</span>
          <button type="submit" className="whitespace-nowrap rounded-md border border-orange-300 px-3 py-1">
            Annuler les entretiens non réalisés
          </button>
        </form>
      )}

      {/* En-tête Access : titre, mails, fermer, liste des sous-traitants possibles */}
      <div className="grid gap-2 lg:grid-cols-[1fr_auto]">
        <div className="flex flex-col gap-2">
          <div className="flex flex-wrap items-center gap-3">
            <h1 className="rounded border bg-white px-6 py-1 text-lg font-bold dark:bg-white/5">Création et Clôture d&apos;intervention - {(typeInterv?.libelle ?? intervention.type_brut ?? "").toUpperCase()}</h1>
            <Link href="/interventions" className="rounded bg-red-600 px-3 py-1 text-xs text-white" title="Fermer la fiche">
              ✕
            </Link>
            <span className="text-xs opacity-70">
              N° {intervention.legacy_id ?? intervention.id}
              {intervention.numero_bon ? ` · Bon n° ${intervention.numero_bon}` : ""} · {statutInterv?.libelle ?? "—"}
            </span>
            {(plusieursCeJour ?? 0) > 0 && <Badge tone="orange">Plusieurs interventions ce jour</Badge>}
            {intervention.location_nacelle && <Badge tone="purple">Nacelle</Badge>}
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <Link href={`/interventions/${id}/email?type=contact`} className={BOUTON}>
              Envoyer un mail au contact
            </Link>
            <Link href={`/interventions/${id}/email?type=partenaire`} className={BOUTON}>
              Envoyer un mail au partenaire
            </Link>
            <Link href={`/interventions/${id}/email?type=fin_intervention`} className={BOUTON}>
              Envoyer un mail au client
            </Link>
            {site && (
              <Link href={`/sites/${site.id}`} className="ml-auto rounded border bg-white px-8 py-1 text-sm font-bold dark:bg-white/5">
                {site.nom}
              </Link>
            )}
          </div>
        </div>
        <div className="flex flex-col gap-1 text-xs">
          <span className="font-semibold">Liste Sous Traitants Possibles</span>
          <div className="flex gap-3">
            {["Climatisation", "Chauffage", "Autres"].map((a) => (
              <Link key={a} href="/intervenants" className="flex items-center gap-1 underline">
                <input type="checkbox" readOnly /> {a}
              </Link>
            ))}
          </div>
        </div>
      </div>

      <Tabs tabs={ONGLETS} active={onglet} searchParams={sp} />

      {onglet === "demande" && (
        <div className="flex flex-col gap-4">
          <div className="grid gap-3 lg:grid-cols-[1fr_1fr]">
            <KeyValue
              items={[
                { label: "Client", value: client ? <Link className="underline" href={`/clients/${client.id}`}>{client.nom}</Link> : "—" },
                { label: "Site", value: site ? <Link className="underline" href={`/sites/${site.id}`}>{site.nom}</Link> : "—" },
                { label: "N° devis accepté", value: intervention.numero_devis_accepte },
                { label: "Date de demande", value: formatDateTime(intervention.date_demande) },
                { label: "Contact", value: contact ? formatNom(contact.prenom, contact.nom) : "—" },
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
            <form action={mettreAJourDemande} className="flex flex-col gap-3 rounded-xl border bg-white p-4 dark:bg-white/5">
              <h2 className="text-sm font-semibold opacity-70">Demande</h2>
              <input type="hidden" name="intervention_id" value={id} />
              <Champ label="Objet *">
                <input name="objet" defaultValue={intervention.objet ?? ""} required className={CHAMP} />
              </Champ>
              <Champ label="N° de DI client">
                <input name="reference_client" defaultValue={intervention.reference_client ?? ""} className={CHAMP} />
              </Champ>
              <div className="grid grid-cols-2 gap-3">
                <Champ label="Date limite">
                  <input name="date_limite" type="date" defaultValue={intervention.date_limite?.slice(0, 10) ?? ""} className={CHAMP} />
                </Champ>
                <Champ label="Date prévue">
                  <input name="date_prevue" type="date" defaultValue={intervention.date_prevue?.slice(0, 10) ?? ""} className={CHAMP} />
                </Champ>
              </div>
              <Champ label="Directives">
                <textarea name="directives" defaultValue={intervention.directives ?? ""} rows={2} className={CHAMP} />
              </Champ>
              <Champ label="Commentaire interne">
                <textarea name="commentaire_interne" defaultValue={intervention.commentaire_interne ?? ""} rows={2} className={CHAMP} />
              </Champ>
              <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
                Enregistrer
              </button>
            </form>
          </div>

          <div className="flex flex-wrap gap-2">
            <form action={basculerResoluTelephone} className="flex items-center gap-2">
              <input type="hidden" name="intervention_id" value={id} />
              <input type="hidden" name="actif" value={intervention.statut_code === 10 ? "0" : "1"} />
              {intervention.statut_code !== 10 && <input name="minutes_telephone" type="number" min={1} placeholder="Minutes" className="w-20 rounded-md border px-2 py-1 text-sm" />}
              <button type="submit" className={BOUTON}>
                {intervention.statut_code === 10 ? "Annuler « résolu par téléphone »" : "Résolu par téléphone"}
              </button>
            </form>
            <form action={nouvelleInterventionDepuis}>
              <input type="hidden" name="intervention_id" value={id} />
              <button type="submit" className={BOUTON}>
                Nouvelle intervention
              </button>
            </form>
            <form action={creerPartieSuivante}>
              <input type="hidden" name="intervention_id" value={id} />
              <button type="submit" className={BOUTON}>
                Partie suivante
              </button>
            </form>
          </div>

          <form action={mettreAJourFacturation} className="flex flex-col gap-3 rounded-xl border bg-white p-4 dark:bg-white/5">
            <h2 className="text-sm font-semibold opacity-70">Facturation</h2>
            <input type="hidden" name="intervention_id" value={id} />
            <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
              <Champ label="Montant FMC">
                <input name="montant_fmc" type="number" step="0.01" defaultValue={intervention.montant_fmc ?? ""} className={CHAMP} />
              </Champ>
              <Champ label="Montant sous-traitant">
                <input name="montant_sous_traitant" type="number" step="0.01" defaultValue={intervention.montant_sous_traitant ?? ""} className={CHAMP} />
              </Champ>
              <Champ label="Différence">
                <input disabled value={formatMontant((intervention.montant_fmc ?? 0) - (intervention.montant_sous_traitant ?? 0))} className={`${CHAMP} opacity-60`} />
              </Champ>
              <Champ label="Date de facturation">
                <input disabled value={formatDate(intervention.date_facturation)} className={`${CHAMP} opacity-60`} />
              </Champ>
            </div>
            <Champ label="Statut facturation">
              <select name="statut_facturation_code" defaultValue={intervention.statut_facturation_code ?? ""} className={CHAMP}>
                <option value="">—</option>
                {optionsStatutFacturation.map((s) => (
                  <option key={s.code} value={s.code}>
                    {s.libelle}
                    {s.reserve_admin ? " (réservé comptabilité)" : ""}
                  </option>
                ))}
              </select>
            </Champ>
            <KeyValue
              items={[
                { label: "Chemin facture FMC", value: <Chemin value={intervention.chemin_facture_fmc} /> },
                { label: "Chemin facture sous-traitant", value: <Chemin value={intervention.chemin_facture_sous_traitant} /> },
              ]}
            />
            <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
              Enregistrer la facturation
            </button>
          </form>
        </div>
      )}

      {onglet === "realisation" && (
        <div className="flex flex-col gap-2">
          <form id={FORM_CLOTURE} action={mettreAJourRealisation}>
            <input type="hidden" name="intervention_id" value={id} />
          </form>
          <h2 className="text-xs font-bold">SAISIE CLOTURE D&apos;INTERVENTION</h2>
          <div className="grid gap-3 rounded border bg-white/60 p-2 dark:bg-white/5 lg:grid-cols-[1fr_1.1fr_auto_1fr]">
            {/* Colonne 1 */}
            <div className="flex flex-col gap-2">
              <div className={LIGNE}>
                <span className="text-right">Date réelle d&apos;inter.</span>
                <div className="grid grid-cols-[1fr_auto_1fr] items-center gap-1">
                  <input form={FORM_CLOTURE} name="date_realisee" type="date" defaultValue={intervention.date_realisee?.slice(0, 10) ?? ""} className={PETIT} />
                  <span>Date réelle de saisie</span>
                  <input form={FORM_CLOTURE} name="date_retour_fiche" type="date" defaultValue={intervention.date_retour_fiche?.slice(0, 10) ?? ""} className={PETIT} />
                </div>
                <span className="text-right">N° de bon</span>
                <input form={FORM_CLOTURE} name="numero_bon" type="number" defaultValue={intervention.numero_bon ?? ""} className={`${PETIT} max-w-32`} />
              </div>
              <div className="grid grid-cols-2 gap-2">
                <div className="flex flex-col gap-1">
                  <span className="text-xs font-semibold underline">Retour fiche d&apos;intervention</span>
                  <CaseF name="retour_fiche_original" label="Original" checked={intervention.retour_fiche_original} />
                  <CaseF name="retour_fiche_copie" label="Copie" checked={intervention.retour_fiche_copie} />
                  <CaseF name="retour_fiche_numerique" label="Copie dans ordinateur" checked={intervention.retour_fiche_numerique} />
                  <CaseF name="audit_fait" label="Audit" checked={intervention.audit_fait} />
                  <CaseF name="photo_faite" label="Photo" checked={intervention.photo_faite} />
                  <CaseF name="location_nacelle" label="Location Nacelle" checked={intervention.location_nacelle} />
                </div>
                <div className="flex flex-col gap-1 pt-4">
                  <CaseF name="registre_securite_mis_a_jour" label="Mise à jour du registre de sécurité" checked={intervention.registre_securite_mis_a_jour} />
                  <CaseF name="controle_etancheite_annuel" label="Contrôle d'étanchéité annuel" checked={intervention.controle_etancheite_annuel} />
                  <CaseF name="controle_etancheite_ponctuel" label="Contrôle d'étanchéité ponctuel" checked={intervention.controle_etancheite_ponctuel} />
                  <div className="mt-2 grid grid-cols-[3.5rem_1fr] items-center gap-1 text-xs">
                    <span className="text-right">Gaz :</span>
                    <select form={FORM_CLOTURE} name="fluide_id" defaultValue={intervention.fluide_id ?? ""} className={PETIT}>
                      <option value=""></option>
                      {(fluides ?? []).map((f) => (
                        <option key={f.code} value={f.code}>
                          {f.libelle}
                        </option>
                      ))}
                    </select>
                    <span className="text-right">Qté Gaz :</span>
                    <input form={FORM_CLOTURE} name="quantite_gaz_kg" type="number" step="0.01" defaultValue={intervention.quantite_gaz_kg ?? ""} className={`${PETIT} max-w-24`} />
                  </div>
                </div>
              </div>

              <Cadre titre="Technicien(s) intervenu(s)">
                <ul className="flex flex-col gap-0.5 text-xs">
                  {techniciensLignes.map((t) => (
                    <li key={t.id} className="flex items-center justify-between rounded border bg-white px-1.5 py-0.5 dark:bg-white/5">
                      <span>{formatNom(t.utilisateurs?.prenom, t.utilisateurs?.nom)}</span>
                      <form action={retirerTechnicien}>
                        <input type="hidden" name="intervention_id" value={id} />
                        <input type="hidden" name="ligne_id" value={t.id} />
                        <button type="submit" className="text-[10px] underline opacity-70">
                          Retirer
                        </button>
                      </form>
                    </li>
                  ))}
                </ul>
                <form action={ajouterTechnicien} className="flex items-center gap-1">
                  <input type="hidden" name="intervention_id" value={id} />
                  <select name="utilisateur_id" className={PETIT}>
                    <option value="">*</option>
                    {techniciensEligibles.map((t) => (
                      <option key={t.id} value={t.id}>
                        {formatNom(t.prenom, t.nom)}
                      </option>
                    ))}
                  </select>
                  <button type="submit" className={BOUTON}>
                    Ajouter
                  </button>
                </form>
                <div className="grid grid-cols-[8.5rem_4rem_auto_4rem] items-center gap-1 text-xs">
                  <span className="text-right">Nombre de techniciens</span>
                  <input form={FORM_CLOTURE} name="nombre_techniciens" type="number" min={0} defaultValue={intervention.nombre_techniciens ?? ""} className={PETIT} />
                  <span className="text-right">Heures vendues</span>
                  <input form={FORM_CLOTURE} name="heures_vendues" type="number" step="0.25" min={0} defaultValue={intervention.heures_vendues ?? ""} className={PETIT} />
                  <span className="col-span-2 text-right">Heures passées (fiches d&apos;heures)</span>
                  <span className={`col-span-2 ${intervention.heures_vendues != null && heuresPassees > Number(intervention.heures_vendues) ? "font-bold text-red-700" : ""}`}>
                    {heuresPassees ? heuresPassees.toFixed(2).replace(".", ",") : "0"} h{intervention.heures_vendues != null && heuresPassees > Number(intervention.heures_vendues) ? " (dépassement)" : ""}
                  </span>
                </div>
              </Cadre>

              <div className="grid grid-cols-[auto_1fr] items-start gap-2 text-xs">
                <a href={`/interventions/${id}/bon.pdf`} target="_blank" rel="noreferrer" className={`${BOUTON} h-fit`} title="Voir le rapport PDF">
                  PDF
                </a>
                <div className="flex flex-col gap-0.5">
                  <span>Bon intervention numérisé</span>
                  <span className="rounded border bg-white px-1.5 py-0.5 text-blue-700 dark:bg-white/5">
                    <Chemin value={intervention.chemin_bon_pdf} />
                  </span>
                </div>
              </div>

              <div className="grid grid-cols-[7rem_5rem_7.5rem_5rem] items-center gap-1 text-xs">
                <span className="text-right">Temps aller</span>
                <input form={FORM_CLOTURE} name="temps_aller" type="time" defaultValue={intervalleHHMM(intervention.temps_aller)} className={PETIT} />
                <span className="text-right">Temps retour</span>
                <input form={FORM_CLOTURE} name="temps_retour" type="time" defaultValue={intervalleHHMM(intervention.temps_retour)} className={PETIT} />
                <span className="text-right">Heure arrivée sur site</span>
                <input form={FORM_CLOTURE} name="heure_arrivee" type="time" defaultValue={intervention.heure_arrivee?.slice(0, 5) ?? ""} className={PETIT} />
                <span className="text-right">Heure de départ du site</span>
                <input form={FORM_CLOTURE} name="heure_depart" type="time" defaultValue={intervention.heure_depart?.slice(0, 5) ?? ""} className={PETIT} />
              </div>
              <CaseF name="masquer_heures_sur_bon" label="Ne pas faire apparaître les heures" checked={intervention.masquer_heures_sur_bon} />

              <div className="grid grid-cols-[7rem_1fr] items-start gap-2 text-xs">
                <span className="text-right">Dossier Site</span>
                <span className="rounded border bg-white px-1.5 py-0.5 text-blue-700 dark:bg-white/5">
                  <Chemin value={site?.dossier_chemin} />
                </span>
              </div>
            </div>

            {/* Colonne 2 */}
            <div className="flex flex-col gap-2 text-xs">
              <div className="grid grid-cols-[5rem_1fr] items-center gap-1">
                <span className="text-right">Saisie par</span>
                <select form={FORM_CLOTURE} name="saisi_par_id" defaultValue={intervention.saisi_par_id ?? ""} className={PETIT}>
                  <option value=""></option>
                  {(gestionnaires ?? []).map((g) => (
                    <option key={g.id} value={g.id}>
                      {formatNom(g.prenom, g.nom)}
                    </option>
                  ))}
                </select>
              </div>
              <label className="flex flex-col gap-0.5">
                Commentaire interne post intervention
                <textarea form={FORM_CLOTURE} name="commentaire_post_intervention" rows={4} defaultValue={intervention.commentaire_post_intervention ?? ""} className={PETIT} />
              </label>
              <label className="flex flex-col gap-0.5">
                Prestations réalisées (saisie par un technicien)
                <textarea form={FORM_CLOTURE} name="prestations_realisees" rows={11} defaultValue={intervention.prestations_realisees ?? ""} className={PETIT} />
              </label>
              <label className="flex flex-col gap-0.5">
                Commentaire (saisie par technicien)
                <textarea form={FORM_CLOTURE} name="commentaire_technicien" rows={3} defaultValue={intervention.commentaire_technicien ?? ""} className={PETIT} />
              </label>
              <div className="grid grid-cols-[6.5rem_1fr_auto] items-center gap-1">
                <span className="text-right">Statut</span>
                <select disabled value={intervention.statut_code ?? ""} className={`${PETIT} opacity-70`}>
                  <option value=""></option>
                  {(statuts ?? []).map((s) => (
                    <option key={s.code} value={s.code}>
                      {s.libelle}
                    </option>
                  ))}
                </select>
                <a href={`/interventions/${id}/bon.pdf`} target="_blank" rel="noreferrer" className={BOUTON} title="Aperçu du rapport">
                  🔍
                </a>
                <span className="text-right">Statut Facturation</span>
                <select form={FORM_CLOTURE} name="statut_facturation_code" defaultValue={intervention.statut_facturation_code ?? ""} className={`${PETIT} col-span-2`}>
                  <option value=""></option>
                  {optionsStatutFacturation.map((s) => (
                    <option key={s.code} value={s.code}>
                      {s.libelle}
                    </option>
                  ))}
                </select>
              </div>
              <div className="flex flex-wrap items-center gap-2">
                {intervention.statut_code === 1 && (
                  <form action={cloturerIntervention}>
                    <input type="hidden" name="intervention_id" value={id} />
                    <button type="submit" className={BOUTON}>
                      Clôturer (→ Réalisé, à valider)
                    </button>
                  </form>
                )}
                {intervention.statut_code === 9 && (
                  <>
                    <form action={decloturerIntervention}>
                      <input type="hidden" name="intervention_id" value={id} />
                      <button type="submit" className={BOUTON}>
                        Déclôturer
                      </button>
                    </form>
                    <form action={validerIntervention}>
                      <input type="hidden" name="intervention_id" value={id} />
                      <button type="submit" className={BOUTON}>
                        Valider (→ Clôturé)
                      </button>
                    </form>
                  </>
                )}
                <form action={genererEtEnregistrerBon} className="ml-auto">
                  <input type="hidden" name="intervention_id" value={id} />
                  <button type="submit" className={BOUTON}>
                    Generer le PDF
                  </button>
                </form>
              </div>
            </div>

            {/* Bandeau garantie */}
            <div className="hidden lg:block">
              {garantieEnCours && (
                <div className="flex h-full w-8 items-center justify-center rounded bg-red-600 text-xs font-bold text-white" style={{ writingMode: "vertical-rl" }}>
                  !!!!!!! GARANTIE ENCORE EN COURS !!!!!
                </div>
              )}
            </div>

            {/* Colonne 3 */}
            <div className="flex flex-col gap-2 text-xs">
              <label className="flex items-center justify-end gap-1.5">
                Intervention faite et non facturable
                <input form={FORM_CLOTURE} type="checkbox" name="non_facturable" value="1" defaultChecked={!!intervention.non_facturable} />
              </label>
              <label className="flex flex-col gap-0.5">
                Commentaire de clôture sur panne (lié au devis à faire)
                <textarea form={FORM_CLOTURE} name="commentaire_cloture_panne" rows={6} defaultValue={intervention.commentaire_cloture_panne ?? ""} className={PETIT} />
              </label>
              <div className="grid grid-cols-[3.5rem_1fr] items-center gap-1">
                <span className="text-right">Panne</span>
                <select form={FORM_CLOTURE} name="panne_code" defaultValue={intervention.panne_code ?? ""} className={PETIT}>
                  <option value=""></option>
                  {(pannes ?? []).map((p) => (
                    <option key={p.code} value={p.code}>
                      {p.libelle}
                    </option>
                  ))}
                </select>
              </div>
              <div className="flex flex-col gap-1 pl-16">
                <CaseF name="panne_origine_externe" label="Panne d'origine externe" checked={intervention.panne_origine_externe} />
                <CaseF name="devis_ne_sera_pas_fait" label="Devis ne sera pas fait" checked={intervention.devis_ne_sera_pas_fait} />
              </div>
              <Cadre titre="Devis à faire">
                <div className="flex gap-4">
                  <CaseF name="devis_a_faire" label="Devis à faire" checked={intervention.devis_a_faire} />
                  <CaseF name="devis_fait" label="Devis fait" checked={intervention.devis_fait} />
                </div>
                <div className="grid grid-cols-[8rem_1fr] items-center gap-1">
                  <span className="text-right">Urgence Devis</span>
                  <select form={FORM_CLOTURE} name="urgence_devis" defaultValue={intervention.urgence_devis ?? ""} className={PETIT}>
                    <option value=""></option>
                    {Object.entries(URGENCES).map(([code, libelle]) => (
                      <option key={code} value={code}>
                        {libelle}
                      </option>
                    ))}
                  </select>
                  <span className="text-right">Duplicata à traiter par</span>
                  <select form={FORM_CLOTURE} name="duplicata_traite_par_id" defaultValue={intervention.duplicata_traite_par_id ?? ""} className={PETIT}>
                    <option value=""></option>
                    {(gestionnaires ?? []).map((g) => (
                      <option key={g.id} value={g.id}>
                        {formatNom(g.prenom, g.nom)}
                      </option>
                    ))}
                  </select>
                </div>
                <CaseF name="duplicata_traite" label="Traité / Attente offre de prix" checked={intervention.duplicata_traite} />
                <label className="flex flex-col gap-0.5">
                  Commentaire interne sur le devis à réaliser
                  <textarea form={FORM_CLOTURE} name="commentaire_devis_interne" rows={5} defaultValue={intervention.commentaire_devis_interne ?? ""} className={PETIT} />
                </label>
              </Cadre>
              <div className="mt-auto flex items-center justify-between gap-2 pt-2">
                {site && (
                  <Link href={`/sites/${site.id}`} className={BOUTON}>
                    Afficher le site
                  </Link>
                )}
                <button type="submit" form={FORM_CLOTURE} className="rounded bg-black px-3 py-1 text-xs text-white">
                  💾 Enregistrer
                </button>
              </div>
            </div>
          </div>
          <div className="text-xs opacity-70">
            Dossier étanchéité : <Chemin value={intervention.chemin_dossier_etancheite} />
          </div>
        </div>
      )}

      {(onglet === "sav" || onglet === "travaux") && site && (
        <div className="flex flex-col gap-2">
          <h2 className="text-xs font-bold">INFORMATIONS SUR LE DEVIS</h2>
          <ListeDevisAccess devis={(devisLies ?? []) as DevisAccess[]} famille={onglet} siteId={site.id} clientNom={client?.nom ?? null} siteNom={site.nom} filtres={sp} />
          <Link href={`/devis/nouveau?site=${intervention.site_id}&intervention=${id}&famille=${onglet}`} className={`${BOUTON} w-fit`}>
            Nouveau devis depuis cette intervention
          </Link>
        </div>
      )}

      {onglet === "signatures" && (
        <KeyValue
          items={[
            { label: "Signature site", value: intervention.signature_site_nom ?? <Chemin value={intervention.signature_site_image} /> },
            { label: "Signature client", value: intervention.signature_client_nom ?? <Chemin value={intervention.signature_client_image} /> },
            { label: "Signature technicien", value: intervention.signature_technicien_nom ?? <Chemin value={intervention.signature_technicien_image} /> },
          ]}
        />
      )}
    </div>
  );
}
