import Link from "next/link";
import { Case, Champ, CHAMP } from "@/components/ui/Champ";
import { ETOILES, INDICES_QUALITE, SITUATIONS, TYPES_SITE } from "@/lib/sites";
import { mettreAJourSite } from "@/app/(app)/sites/actions";

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
};

function Selection({ name, valeur, options, vide = "—", disabled }: { name: string; valeur: unknown; options: Option[]; vide?: string; disabled?: boolean }) {
  return (
    <select name={name} defaultValue={valeur == null ? "" : String(valeur)} disabled={disabled} className={CHAMP}>
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
    <select name={name} defaultValue={valeur == null ? "" : String(valeur)} className={CHAMP}>
      <option value="">—</option>
      {ETOILES.map((n) => (
        <option key={n} value={n}>
          {"★".repeat(n)}
        </option>
      ))}
    </select>
  );
}

function Section({ titre, children }: { titre: string; children: React.ReactNode }) {
  return (
    <fieldset className="flex flex-col gap-3 rounded-xl border p-4">
      <legend className="px-1 text-sm font-semibold opacity-70">{titre}</legend>
      {children}
    </fieldset>
  );
}

export function FormulaireSite({ site, deverrouille, clients, donneurs, intervenants, zones, fluides }: Props) {
  const s = site as Record<string, string | number | boolean | null>;
  const texte = (k: string) => (s[k] == null ? "" : String(s[k]));
  const date = (k: string) => texte(k).slice(0, 10);
  const bool = (k: string) => !!s[k];

  return (
    <form action={mettreAJourSite} className="flex flex-col gap-4">
      <input type="hidden" name="site_id" value={site.id} />
      {deverrouille && <input type="hidden" name="deverrouille" value="1" />}

      <Section titre="Infos site">
        <div className="flex items-center justify-between text-xs opacity-70">
          <span>Client, nom du site et donneur d&apos;ordre sont protégés contre la modification accidentelle.</span>
          <Link href={`/sites/${site.id}${deverrouille ? "" : "?deverrouiller=1"}`} className="underline">
            {deverrouille ? "Verrouiller" : "Déverrouiller"}
          </Link>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <Champ label="Client *">
            {deverrouille ? (
              <Selection name="client_id" valeur={site.client_id} options={clients} vide="— Choisir —" />
            ) : (
              <input disabled value={clients.find((c) => c.id === site.client_id)?.libelle ?? `#${site.client_id}`} className={`${CHAMP} opacity-60`} />
            )}
          </Champ>
          <Champ label="Donneur d'ordre">
            <Selection name="donneur_ordre_id" valeur={s.donneur_ordre_id} options={donneurs} disabled={!deverrouille} />
          </Champ>
        </div>
        <div className="grid grid-cols-3 gap-3">
          <Champ label="Nom du site *">
            <input name="nom" defaultValue={texte("nom")} disabled={!deverrouille} required={deverrouille} className={`${CHAMP} ${deverrouille ? "" : "opacity-60"}`} />
          </Champ>
          <Champ label="N° de magasin (client)">
            <input name="numero_magasin" type="number" defaultValue={texte("numero_magasin")} className={CHAMP} />
          </Champ>
          <Champ label="Code">
            <input name="code_client" defaultValue={texte("code_client")} className={CHAMP} />
          </Champ>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <Champ label="Nom de société">
            <input name="nom_societe" defaultValue={texte("nom_societe")} className={CHAMP} />
          </Champ>
          <Champ label="Intervenant clim (titulaire)">
            <Selection name="intervenant_id" valeur={s.intervenant_id} options={intervenants} />
          </Champ>
        </div>
        <Champ label="Adresse">
          <input name="adresse" defaultValue={texte("adresse")} className={CHAMP} />
        </Champ>
        <div className="grid grid-cols-4 gap-3">
          <Champ label="Code postal">
            <input name="code_postal" defaultValue={texte("code_postal")} className={CHAMP} />
          </Champ>
          <Champ label="Ville">
            <input name="ville" defaultValue={texte("ville")} className={CHAMP} />
          </Champ>
          <Champ label="Zone d'intervention">
            <Selection name="zone_id" valeur={s.zone_id} options={zones} />
          </Champ>
          <Champ label="Zone secondaire">
            <Selection name="zone_secondaire_id" valeur={s.zone_secondaire_id} options={zones} />
          </Champ>
        </div>
        <div className="grid grid-cols-3 gap-3">
          <Champ label="Téléphone">
            <input name="telephone" defaultValue={texte("telephone")} className={CHAMP} />
          </Champ>
          <Champ label="Fax">
            <input name="fax" defaultValue={texte("fax")} className={CHAMP} />
          </Champ>
          <Champ label="E-mail">
            <input name="email" type="email" defaultValue={texte("email")} className={CHAMP} />
          </Champ>
        </div>
        <div className="grid grid-cols-4 gap-3">
          <Champ label="Civilité responsable">
            <input name="responsable_civilite" defaultValue={texte("responsable_civilite")} className={CHAMP} />
          </Champ>
          <Champ label="Nom responsable">
            <input name="responsable_nom" defaultValue={texte("responsable_nom")} className={CHAMP} />
          </Champ>
          <Champ label="Prénom responsable">
            <input name="responsable_prenom" defaultValue={texte("responsable_prenom")} className={CHAMP} />
          </Champ>
          <Champ label="Tél. centre commercial">
            <input name="telephone_centre_commercial" defaultValue={texte("telephone_centre_commercial")} className={CHAMP} />
          </Champ>
        </div>
        <div className="grid grid-cols-3 gap-3">
          <Champ label="Surface de vente (m²)">
            <input name="surface_vente" type="number" step="0.01" defaultValue={texte("surface_vente")} className={CHAMP} />
          </Champ>
          <Champ label="Surface totale (m²)">
            <input name="surface_totale" type="number" step="0.01" defaultValue={texte("surface_totale")} className={CHAMP} />
          </Champ>
          <Champ label="N° Esabora site">
            <input name="numero_esabora" defaultValue={texte("numero_esabora")} className={CHAMP} />
          </Champ>
        </div>
        <Champ label="Raccourci réseau vers le dossier du site">
          <input name="dossier_chemin" defaultValue={texte("dossier_chemin")} className={CHAMP} />
        </Champ>
      </Section>

      <Section titre="Infos installation">
        <div className="grid grid-cols-3 gap-3">
          <Champ label="En service le">
            <input name="date_mise_en_service" type="date" defaultValue={date("date_mise_en_service")} className={CHAMP} />
          </Champ>
          <Champ label="Situation">
            <select name="situation" defaultValue={texte("situation")} className={CHAMP}>
              <option value="">—</option>
              {SITUATIONS.map((v) => (
                <option key={v} value={v}>
                  {v}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="Type (H chaud / F froid)">
            <select name="type_site" defaultValue={texte("type_site")} className={CHAMP}>
              <option value="">—</option>
              {TYPES_SITE.map((v) => (
                <option key={v} value={v}>
                  {v}
                </option>
              ))}
            </select>
          </Champ>
        </div>
        <div className="grid grid-cols-4 gap-3">
          <Champ label="Indice qualité">
            <select name="indice_qualite" defaultValue={texte("indice_qualite")} className={CHAMP}>
              <option value="">—</option>
              {Object.entries(INDICES_QUALITE).map(([code, libelle]) => (
                <option key={code} value={code}>
                  {libelle}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="Vétusté">
            <Etoiles name="indice_vetuste" valeur={s.indice_vetuste} />
          </Champ>
          <Champ label="Puissance">
            <Etoiles name="indice_puissance" valeur={s.indice_puissance} />
          </Champ>
          <Champ label="Accessibilité">
            <Etoiles name="indice_accessibilite" valeur={s.indice_accessibilite} />
          </Champ>
        </div>
        <div className="grid grid-cols-3 gap-3">
          <Champ label="Type de fluide">
            <Selection name="fluide_id" valeur={s.fluide_id} options={fluides} />
          </Champ>
          <Champ label="Temp. entrante (°C)">
            <input name="temperature_entree" defaultValue={texte("temperature_entree")} className={CHAMP} />
          </Champ>
          <Champ label="Temp. sortante (°C)">
            <input name="temperature_sortie" defaultValue={texte("temperature_sortie")} className={CHAMP} />
          </Champ>
        </div>
        <div className="flex flex-wrap gap-4">
          <Case name="gtb" label="GTB" checked={bool("gtb")} />
          <Case name="allumage_clim" label="Allumage clim." checked={bool("allumage_clim")} />
          <Case name="arret_urgence_clim_oui" label="Arrêt d'urgence clim (OUI)" checked={bool("arret_urgence_clim_oui")} />
          <Case name="arret_urgence_clim_non" label="Arrêt d'urgence clim (NON)" checked={bool("arret_urgence_clim_non")} />
          <Case name="detection_fuite_permanente" label="Système de détection de fuite" checked={bool("detection_fuite_permanente")} />
        </div>
        <div className="grid grid-cols-3 gap-3">
          <Champ label="Garantie pièces et MO (années)">
            <input name="garantie_pieces_mo_annees" type="number" min={0} defaultValue={texte("garantie_pieces_mo_annees")} className={CHAMP} />
          </Champ>
          <Champ label="Garantie pièces (années)">
            <input name="garantie_pieces_annees" type="number" min={0} defaultValue={texte("garantie_pieces_annees")} className={CHAMP} />
          </Champ>
          <Champ label="Garantie compresseur (années)">
            <input name="garantie_compresseur_annees" type="number" min={0} defaultValue={texte("garantie_compresseur_annees")} className={CHAMP} />
          </Champ>
        </div>
      </Section>

      <Section titre="Tarifs MO et déplacement">
        <Case name="tarifs_specifiques" label="Le site surcharge les tarifs du client" checked={bool("tarifs_specifiques")} />
        <div className="grid grid-cols-2 gap-3">
          <Champ label="Tarif heure main d'œuvre (site)">
            <input name="tarif_heure_mo" type="number" step="0.01" defaultValue={texte("tarif_heure_mo")} className={CHAMP} />
          </Champ>
          <Champ label="Tarif d'un déplacement (site)">
            <input name="tarif_deplacement" type="number" step="0.01" defaultValue={texte("tarif_deplacement")} className={CHAMP} />
          </Champ>
        </div>
      </Section>

      <Section titre="À faire">
        <div className="flex flex-wrap gap-4">
          <Case name="photo_a_faire" label="Photo à faire" checked={bool("photo_a_faire")} />
          <Case name="photo_faite" label="Photo faite" checked={bool("photo_faite")} />
          <Case name="audit_a_faire" label="Audit à faire" checked={bool("audit_a_faire")} />
          <Case name="audit_fait" label="Audit fait" checked={bool("audit_fait")} />
          <Case name="controle_etancheite_a_faire" label="Contrôle d'étanchéité à faire" checked={bool("controle_etancheite_a_faire")} />
          <Case name="controle_etancheite_fait" label="Contrôle d'étanchéité fait" checked={bool("controle_etancheite_fait")} />
        </div>
        <div className="grid grid-cols-3 gap-3">
          <Champ label="Nombre de plans">
            <input name="nombre_plans" type="number" min={0} defaultValue={texte("nombre_plans")} className={CHAMP} />
          </Champ>
          <Champ label="Nombre de photos">
            <input name="nombre_photos" type="number" min={0} defaultValue={texte("nombre_photos")} className={CHAMP} />
          </Champ>
          <Champ label="Dernière visite désenfumage">
            <input name="date_derniere_visite_desenfumage" type="date" defaultValue={date("date_derniere_visite_desenfumage")} className={CHAMP} />
          </Champ>
        </div>
      </Section>

      <Section titre="Alertes">
        <div className="flex flex-wrap gap-4">
          <Case name="retard_paiement" label="Retard de paiement" checked={bool("retard_paiement")} />
          <Case name="nacelle_necessaire" label="Nacelle nécessaire" checked={bool("nacelle_necessaire")} />
          <Case name="particulier" label="Particulier" checked={bool("particulier")} />
          <Case name="rdv_a_prendre" label="RDV à prendre" checked={bool("rdv_a_prendre")} />
          <Case name="investissement" label="Investissement" checked={bool("investissement")} />
        </div>
        <Champ label="Descriptif investissement">
          <textarea name="descriptif_investissement" rows={2} defaultValue={texte("descriptif_investissement")} className={CHAMP} />
        </Champ>
      </Section>

      <Section titre="Commentaires">
        <Champ label="Commentaire général (visible sur la liste technicien)">
          <textarea name="commentaire_general" rows={3} defaultValue={texte("commentaire_general")} className={CHAMP} />
        </Champ>
        <Champ label="Commentaire divers">
          <textarea name="commentaire_divers" rows={2} defaultValue={texte("commentaire_divers")} className={CHAMP} />
        </Champ>
      </Section>

      <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
        Enregistrer la fiche
      </button>
    </form>
  );
}
