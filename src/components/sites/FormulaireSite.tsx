import Link from "next/link";
import { Chemin } from "@/components/ui/Chemin";
import { ETOILES, INDICES_QUALITE, SITUATIONS, TYPES_SITE } from "@/lib/sites";
import { formatDate } from "@/lib/format";
import { geocoderSite, mettreAJourSite } from "@/app/(app)/sites/actions";
import { ContratsSite, type Contrat } from "./ContratsEtHoraires";

type Option = { id: number; libelle: string | null };

type Props = {
  // Ligne `sites` complète : les colonnes sont lues dynamiquement (pas de types générés).
  site: Record<string, unknown> & { id: number; client_id: number };
  deverrouille: boolean;
  clients: Option[];
  donneurs: Option[];
  intervenants: Option[];
  zones: Option[];
  fluides: Option[];
  contrats: Contrat[];
  registre: string[];
  badges: string[];
};

/** Identifiant du formulaire principal : les champs sont dispersés dans la grille et rattachés par l'attribut `form`. */
export const FORM_SITE = "fiche-site";

const CHAMP = "w-full rounded border bg-white px-1.5 py-0.5 text-sm dark:bg-white/5";
const LIGNE = "grid grid-cols-[minmax(0,7.5rem)_1fr] items-center gap-x-2 gap-y-1 text-xs";

function Cadre({ titre, children, className = "" }: { titre?: string; children: React.ReactNode; className?: string }) {
  return (
    <fieldset className={`flex flex-col gap-1.5 rounded border px-2 pb-2 pt-1 ${className}`}>
      {titre && <legend className="px-1 text-xs font-semibold">{titre}</legend>}
      {children}
    </fieldset>
  );
}

function Texte({ name, valeur, type = "text", disabled, step, className = "" }: { name: string; valeur: unknown; type?: string; disabled?: boolean; step?: string; className?: string }) {
  return <input form={FORM_SITE} name={name} type={type} step={step} disabled={disabled} defaultValue={valeur == null ? "" : String(valeur)} className={`${CHAMP} ${disabled ? "opacity-60" : ""} ${className}`} />;
}

function Selection({ name, valeur, options, vide = "", disabled }: { name: string; valeur: unknown; options: Option[]; vide?: string; disabled?: boolean }) {
  return (
    <select form={FORM_SITE} name={name} defaultValue={valeur == null ? "" : String(valeur)} disabled={disabled} className={`${CHAMP} ${disabled ? "opacity-60" : ""}`}>
      <option value="">{vide}</option>
      {options.map((o) => (
        <option key={o.id} value={o.id}>
          {o.libelle}
        </option>
      ))}
    </select>
  );
}

function Etoiles({ name, valeur }: { name: string; valeur: unknown }) {
  return (
    <select form={FORM_SITE} name={name} defaultValue={valeur == null ? "" : String(valeur)} className={CHAMP}>
      <option value=""></option>
      {ETOILES.map((n) => (
        <option key={n} value={n}>
          {"★".repeat(n) + "☆".repeat(5 - n)}
        </option>
      ))}
    </select>
  );
}

function Case({ name, label, checked, disabled, className = "" }: { name?: string; label: React.ReactNode; checked: boolean; disabled?: boolean; className?: string }) {
  return (
    <label className={`flex items-center gap-1.5 text-xs ${className}`}>
      <input form={FORM_SITE} type="checkbox" name={name} value="1" defaultChecked={checked} disabled={disabled} />
      {label}
    </label>
  );
}

/** Onglet « Site » de la fiche Access (Form_Site, analysis 03 §2.2) : quatre colonnes de cadres. */
export function FormulaireSite({ site, deverrouille, clients, donneurs, intervenants, zones, fluides, contrats, registre, badges }: Props) {
  const s = site as Record<string, string | number | boolean | null>;
  const texte = (k: string) => (s[k] == null ? "" : String(s[k]));
  const date = (k: string) => texte(k).slice(0, 10);
  const bool = (k: string) => !!s[k];
  const alerte = bool("ne_plus_intervenir") || bool("retard_paiement");

  return (
    <div className={`flex flex-col gap-3 rounded p-2 ${alerte ? "bg-red-100 dark:bg-red-950/40" : ""}`}>
      <form id={FORM_SITE} action={mettreAJourSite}>
        <input type="hidden" name="site_id" value={site.id} />
        {deverrouille && <input type="hidden" name="deverrouille" value="1" />}
        <input type="hidden" name="nom_societe" value={texte("nom_societe")} />
        <input type="hidden" name="zone_secondaire_id" value={texte("zone_secondaire_id")} />
        <input type="hidden" name="responsable_prenom" value={texte("responsable_prenom")} />
        <input type="hidden" name="nombre_plans" value={texte("nombre_plans")} />
        <input type="hidden" name="nombre_photos" value={texte("nombre_photos")} />
        <input type="hidden" name="date_derniere_visite_desenfumage" value={date("date_derniere_visite_desenfumage")} />
      </form>

      <div className="grid gap-3 lg:grid-cols-[1.1fr_1fr_1fr_1fr]">
        {/* Colonne 1 : donneur, intervenant, infos site, zone, géolocalisation, tarifs */}
        <div className="flex flex-col gap-2">
          <div className={LIGNE}>
            <span className="flex items-center gap-1">
              <Link href={`/sites/${site.id}${deverrouille ? "" : "?deverrouiller=1"}`} title={deverrouille ? "Verrouiller" : "Déverrouiller client, nom du site et donneur d'ordre"} className="text-[10px] underline">
                {deverrouille ? "🔓" : "🔒"}
              </Link>
              Donneur d&apos;ordre
            </span>
            <Selection name="donneur_ordre_id" valeur={s.donneur_ordre_id} options={donneurs} disabled={!deverrouille} />
            <span>Nom intervenant Clim</span>
            <Selection name="intervenant_id" valeur={s.intervenant_id} options={intervenants} />
          </div>
          <div className="flex flex-wrap gap-3">
            <Case name="particulier" checked={bool("particulier")} label={<span className="bg-yellow-300 px-1 font-semibold text-black">Particulier</span>} />
            <Case name="rdv_a_prendre" checked={bool("rdv_a_prendre")} label={<span className="bg-yellow-300 px-1 font-semibold text-black">RDV à Prendre</span>} />
          </div>
          <div className={LIGNE}>
            <span>N° unique Esabora</span>
            <Texte name="numero_esabora" valeur={s.numero_esabora} />
          </div>

          <Cadre titre="Infos Site">
            <div className={LIGNE}>
              <span>Client</span>
              {deverrouille ? (
                <Selection name="client_id" valeur={site.client_id} options={clients} vide="— Choisir —" />
              ) : (
                <input disabled value={clients.find((c) => c.id === site.client_id)?.libelle ?? `#${site.client_id}`} className={`${CHAMP} opacity-60`} />
              )}
              <span>N° du site</span>
              <div className="grid grid-cols-[1fr_auto_1fr] items-center gap-1">
                <Texte name="numero_magasin" type="number" valeur={s.numero_magasin} />
                <span>Code</span>
                <Texte name="code_client" valeur={s.code_client} />
              </div>
              <span>Nom du site</span>
              <Texte name="nom" valeur={s.nom} disabled={!deverrouille} />
              <span>Adresse</span>
              <Texte name="adresse" valeur={s.adresse} />
              <span>CP / Ville</span>
              <div className="grid grid-cols-[5rem_1fr] gap-1">
                <Texte name="code_postal" valeur={s.code_postal} />
                <Texte name="ville" valeur={s.ville} />
              </div>
              <span>Téléphone</span>
              <Texte name="telephone" valeur={s.telephone} />
              <span>Fax</span>
              <Texte name="fax" valeur={s.fax} />
              <span>Email</span>
              <Texte name="email" type="email" valeur={s.email} />
            </div>
          </Cadre>

          <Cadre>
            <div className={LIGNE}>
              <span>Surface de vente</span>
              <div className="grid grid-cols-[1fr_auto_1fr] items-center gap-1">
                <Texte name="surface_vente" type="number" step="0.01" valeur={s.surface_vente} />
                <span>Surface totale</span>
                <Texte name="surface_totale" type="number" step="0.01" valeur={s.surface_totale} />
              </div>
              <span>Nom responsable</span>
              <div className="grid grid-cols-[1fr_auto_1fr] items-center gap-1">
                <Texte name="responsable_nom" valeur={s.responsable_nom} />
                <span>Tél.</span>
                <Texte name="telephone_centre_commercial" valeur={s.telephone_centre_commercial} />
              </div>
              <span title="Colonne « civilité responsable » réaffectée dans Access">Mail responsable</span>
              <Texte name="responsable_civilite" valeur={s.responsable_civilite} />
            </div>
          </Cadre>

          <Cadre titre="Zone d'intervention">
            <div className={LIGNE}>
              <span>Zone d&apos;intervention</span>
              <Selection name="zone_id" valeur={s.zone_id} options={zones} />
            </div>
          </Cadre>

          <Cadre titre="Géolocalisation">
            <div className="grid grid-cols-[auto_1fr_auto_1fr_auto_1fr] items-center gap-1 text-xs">
              <span>Latitude</span>
              <Texte name="latitude" type="number" step="0.000001" valeur={s.latitude} />
              <span>Longitude</span>
              <Texte name="longitude" type="number" step="0.000001" valeur={s.longitude} />
              <span>Précision</span>
              <input disabled value={texte("precision_geo")} className={`${CHAMP} opacity-60`} />
            </div>
            <div className={LIGNE}>
              <span title="Coller ici « latitude, longitude » copiées depuis Google Maps">Coller coordonnées</span>
              <input form={FORM_SITE} name="coordonnees" placeholder="43.673, 7.189" className={CHAMP} />
            </div>
            <form action={geocoderSite}>
              <input type="hidden" name="site_id" value={site.id} />
              <button type="submit" className="rounded border px-2 py-0.5 text-xs">
                Géocoder
              </button>
            </form>
          </Cadre>

          <Cadre titre="Tarif MO et DP">
            <Case name="tarifs_specifiques" checked={bool("tarifs_specifiques")} label="Tarifs propres au site (sinon tarifs du client)" />
            <div className={LIGNE}>
              <span>Tarif heure Main d&apos;œuvre</span>
              <Texte name="tarif_heure_mo" type="number" step="0.01" valeur={s.tarif_heure_mo} />
              <span>Tarif d&apos;un déplacement</span>
              <Texte name="tarif_deplacement" type="number" step="0.01" valeur={s.tarif_deplacement} />
            </div>
          </Cadre>
        </div>

        {/* Colonne 2 : installation et trois contrats */}
        <div className="flex flex-col gap-2">
          <Cadre titre="Infos Install">
            <div className={LIGNE}>
              <span>En service le</span>
              <Texte name="date_mise_en_service" type="date" valeur={date("date_mise_en_service")} />
              <span>Indicateur</span>
              <select form={FORM_SITE} name="indice_qualite" defaultValue={texte("indice_qualite")} className={CHAMP}>
                <option value=""></option>
                {Object.entries(INDICES_QUALITE).map(([code, libelle]) => (
                  <option key={code} value={code}>
                    {libelle}
                  </option>
                ))}
              </select>
              <span>Situation</span>
              <select form={FORM_SITE} name="situation" defaultValue={texte("situation")} className={CHAMP}>
                <option value=""></option>
                {SITUATIONS.map((v) => (
                  <option key={v} value={v}>
                    {v}
                  </option>
                ))}
              </select>
              <span>Type (H / F)</span>
              <select form={FORM_SITE} name="type_site" defaultValue={texte("type_site")} className={CHAMP}>
                <option value=""></option>
                {TYPES_SITE.map((v) => (
                  <option key={v} value={v}>
                    {v}
                  </option>
                ))}
              </select>
              <span>Type de fluide</span>
              <Selection name="fluide_id" valeur={s.fluide_id} options={fluides} />
              <span>Temp. entrante</span>
              <div className="grid grid-cols-[1fr_auto_auto_1fr_auto] items-center gap-1">
                <Texte name="temperature_entree" valeur={s.temperature_entree} />
                <span>°C</span>
                <span>Temp. sortante</span>
                <Texte name="temperature_sortie" valeur={s.temperature_sortie} />
                <span>°C</span>
              </div>
              <span>Indice Qualité</span>
              <Etoiles name="indice_vetuste" valeur={s.indice_vetuste} />
              <span>Accessibilité</span>
              <Etoiles name="indice_accessibilite" valeur={s.indice_accessibilite} />
              <span>Indice Puissance</span>
              <Etoiles name="indice_puissance" valeur={s.indice_puissance} />
            </div>
          </Cadre>
          <ContratsSite siteId={site.id} contrats={contrats} intervenants={intervenants} />
        </div>

        {/* Colonne 3 : dossier, garanties, registre, informations diverses, à faire, divers, site fermé */}
        <div className="flex flex-col gap-2">
          <div className="flex flex-wrap items-start gap-2">
            <Link href={`/interventions/nouvelle?site=${site.id}`} className="rounded border bg-white px-2 py-1 text-xs dark:bg-white/5">
              Créer une intervention
            </Link>
            <div className="flex min-w-40 flex-1 flex-col gap-0.5 text-xs">
              <span>Raccourci réseau vers le dossier du site</span>
              <Texte name="dossier_chemin" valeur={s.dossier_chemin} />
              {s.dossier_chemin && <Chemin value={String(s.dossier_chemin)} />}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2">
            <Cadre titre="Garanties">
              <div className={`${LIGNE} grid-cols-[1fr_3.5rem]`}>
                <span>Pièces et M.O.</span>
                <Texte name="garantie_pieces_mo_annees" type="number" valeur={s.garantie_pieces_mo_annees} />
                <span>Pièces</span>
                <Texte name="garantie_pieces_annees" type="number" valeur={s.garantie_pieces_annees} />
                <span>Compresseur</span>
                <Texte name="garantie_compresseur_annees" type="number" valeur={s.garantie_compresseur_annees} />
              </div>
            </Cadre>
            <Cadre titre="Registre de sécurité">
              <ul className="max-h-24 overflow-y-auto rounded border bg-white text-xs dark:bg-white/5">
                {registre.length === 0 && <li className="px-1 opacity-60">Aucune date</li>}
                {registre.map((d) => (
                  <li key={d} className="border-b px-1 last:border-0">
                    {formatDate(d)}
                  </li>
                ))}
              </ul>
            </Cadre>
          </div>

          <Cadre titre="Information divers">
            <Case name="nacelle_necessaire" checked={bool("nacelle_necessaire")} label="NACELLE NECESSAIRE" />
            <label className="flex items-center gap-1.5 text-xs">
              <input type="checkbox" checked={bool("ne_plus_intervenir")} disabled />
              NE PLUS INTERVENIR
              <Link href={`/sites/${site.id}?confirmer=ne_plus_intervenir`} className="underline">
                {bool("ne_plus_intervenir") ? "reprendre" : "modifier"}
              </Link>
            </label>
            <Case name="retard_paiement" checked={bool("retard_paiement")} label="RETARD PAIEMENT" />
            <Case name="detection_fuite_permanente" checked={bool("detection_fuite_permanente")} label="Système de détection de fuite" />
          </Cadre>

          <div className="grid grid-cols-2 gap-2">
            <Cadre titre="A Faire">
              <div className="grid grid-cols-2 gap-1">
                <Case name="audit_a_faire" checked={bool("audit_a_faire")} label="Audit à faire" />
                <Case name="audit_fait" checked={bool("audit_fait")} label="Audit fait" />
                <Case name="controle_etancheite_a_faire" checked={bool("controle_etancheite_a_faire")} label="CE à faire" />
                <Case name="controle_etancheite_fait" checked={bool("controle_etancheite_fait")} label="CE fait" />
                <Case name="photo_a_faire" checked={bool("photo_a_faire")} label="Photo à faire" />
                <Case name="photo_faite" checked={bool("photo_faite")} label="Photo faite" />
              </div>
            </Cadre>
            <Cadre titre="Divers">
              <Case name="gtb" checked={bool("gtb")} label="GTB" />
              <Case name="allumage_clim" checked={bool("allumage_clim")} label="Allumage Clim." />
              <Case name="arret_urgence_clim_oui" checked={bool("arret_urgence_clim_oui")} label="Arrêt d'urgence clim (OUI)" />
              <Case name="arret_urgence_clim_non" checked={bool("arret_urgence_clim_non")} label="Arrêt d'urgence clim (NON)" />
            </Cadre>
          </div>

          <Cadre titre="Site fermé">
            <label className="flex items-center gap-1.5 text-xs">
              <input type="checkbox" checked={bool("ferme")} disabled />
              Fermé
              {!bool("ferme") && (
                <Link href={`/sites/${site.id}?confirmer=fermeture`} className="underline">
                  fermer le site
                </Link>
              )}
            </label>
            <div className={LIGNE}>
              <span>Date de fermeture</span>
              <input disabled value={bool("ferme") ? formatDate(texte("date_fermeture")) : ""} className={`${CHAMP} opacity-60`} />
              <span>Motif de fermeture</span>
              <input disabled value={texte("motif_fermeture")} className={`${CHAMP} opacity-60`} />
            </div>
          </Cadre>

          <Cadre titre="Investissement">
            <Case name="investissement" checked={bool("investissement")} label="Investissement" />
            <textarea form={FORM_SITE} name="descriptif_investissement" rows={2} defaultValue={texte("descriptif_investissement")} placeholder="Descriptif investissement" className={CHAMP} />
          </Cadre>
        </div>

        {/* Colonne 4 : badges et commentaires */}
        <div className="flex flex-col gap-2">
          {badges.length > 0 && (
            <div className="flex flex-wrap items-center gap-2 text-xs font-bold">
              <span className="text-2xl" aria-hidden>
                ⚠️
              </span>
              {badges.map((b) => (
                <span key={b}>{b}</span>
              ))}
            </div>
          )}
          <label className="flex flex-col gap-0.5 text-xs">
            Commentaire général Magasin (visible sur liste technicien)
            <textarea form={FORM_SITE} name="commentaire_general" rows={14} defaultValue={texte("commentaire_general")} className={CHAMP} />
          </label>
          <label className="flex flex-col gap-0.5 text-xs">
            Commentaire divers
            <textarea form={FORM_SITE} name="commentaire_divers" rows={12} defaultValue={texte("commentaire_divers")} className={CHAMP} />
          </label>
        </div>
      </div>
    </div>
  );
}
