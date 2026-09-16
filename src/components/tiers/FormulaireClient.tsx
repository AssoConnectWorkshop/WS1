import { Case, Champ, CHAMP } from "@/components/ui/Champ";

type Client = {
  nom: string | null;
  adresse: string | null;
  code_postal: string | null;
  ville: string | null;
  telephone: string | null;
  fax: string | null;
  contact_principal: string | null;
  email: string | null;
  delai_intervention_heures: number | null;
  numero_esabora_maint: string | null;
  numero_esabora_clim: string | null;
  tarif_heure_mo: number | null;
  tarif_deplacement: number | null;
  actif: boolean;
};

/** Champs de la fiche client (analysis 03 §1.1), partagés entre création et modification. */
export function ChampsClient({ client }: { client?: Client }) {
  return (
    <>
      <Champ label="Nom *">
        <input name="nom" required defaultValue={client?.nom ?? ""} className={CHAMP} />
      </Champ>
      <Champ label="Adresse">
        <input name="adresse" defaultValue={client?.adresse ?? ""} className={CHAMP} />
      </Champ>
      <div className="grid grid-cols-3 gap-3">
        <Champ label="Code postal">
          <input name="code_postal" defaultValue={client?.code_postal ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Ville">
          <input name="ville" defaultValue={client?.ville ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Délai d'intervention (h)">
          <input name="delai_intervention_heures" type="number" step="0.5" defaultValue={client?.delai_intervention_heures ?? ""} className={CHAMP} />
        </Champ>
      </div>
      <div className="grid grid-cols-3 gap-3">
        <Champ label="Téléphone">
          <input name="telephone" defaultValue={client?.telephone ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Fax">
          <input name="fax" defaultValue={client?.fax ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="E-mail">
          <input name="email" type="email" defaultValue={client?.email ?? ""} className={CHAMP} />
        </Champ>
      </div>
      <Champ label="Contact principal">
        <input name="contact_principal" defaultValue={client?.contact_principal ?? ""} className={CHAMP} />
      </Champ>
      <div className="grid grid-cols-2 gap-3">
        <Champ label="Tarif heure main d'œuvre">
          <input name="tarif_heure_mo" type="number" step="0.01" defaultValue={client?.tarif_heure_mo ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Tarif d'un déplacement">
          <input name="tarif_deplacement" type="number" step="0.01" defaultValue={client?.tarif_deplacement ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="N° Esabora clim">
          <input name="numero_esabora_clim" defaultValue={client?.numero_esabora_clim ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="N° Esabora maintenance">
          <input name="numero_esabora_maint" defaultValue={client?.numero_esabora_maint ?? ""} className={CHAMP} />
        </Champ>
      </div>
      <Case name="actif" label="Client affiché (actif)" checked={client?.actif ?? true} />
    </>
  );
}

type Donneur = {
  nom: string | null;
  adresse: string | null;
  code_postal: string | null;
  ville: string | null;
  telephone: string | null;
  fax: string | null;
  contact_principal: string | null;
  email: string | null;
  delai_intervention_heures: number | null;
  logo_chemin: string | null;
  pied_page_ligne_1: string | null;
  pied_page_ligne_2: string | null;
  pied_page_ligne_3: string | null;
  actif: boolean;
  saisie_simplifiee_tablette: boolean;
};

/** Champs de la fiche donneur d'ordre (analysis 03 §1.4). */
export function ChampsDonneur({ donneur }: { donneur?: Donneur }) {
  return (
    <>
      <Champ label="Nom *">
        <input name="nom" required defaultValue={donneur?.nom ?? ""} className={CHAMP} />
      </Champ>
      <Champ label="Adresse">
        <input name="adresse" defaultValue={donneur?.adresse ?? ""} className={CHAMP} />
      </Champ>
      <div className="grid grid-cols-3 gap-3">
        <Champ label="Code postal">
          <input name="code_postal" defaultValue={donneur?.code_postal ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Ville">
          <input name="ville" defaultValue={donneur?.ville ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Délai d'intervention (h)">
          <input name="delai_intervention_heures" type="number" step="0.5" defaultValue={donneur?.delai_intervention_heures ?? ""} className={CHAMP} />
        </Champ>
      </div>
      <div className="grid grid-cols-3 gap-3">
        <Champ label="Téléphone">
          <input name="telephone" defaultValue={donneur?.telephone ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Fax">
          <input name="fax" defaultValue={donneur?.fax ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="E-mail">
          <input name="email" type="email" defaultValue={donneur?.email ?? ""} className={CHAMP} />
        </Champ>
      </div>
      <Champ label="Contact principal">
        <input name="contact_principal" defaultValue={donneur?.contact_principal ?? ""} className={CHAMP} />
      </Champ>
      <Champ label="Logo (chemin)">
        <input name="logo_chemin" defaultValue={donneur?.logo_chemin ?? ""} className={CHAMP} />
      </Champ>
      <div className="grid grid-cols-3 gap-3">
        <Champ label="Pied de page ligne 1">
          <input name="pied_page_ligne_1" defaultValue={donneur?.pied_page_ligne_1 ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Pied de page ligne 2">
          <input name="pied_page_ligne_2" defaultValue={donneur?.pied_page_ligne_2 ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Pied de page ligne 3">
          <input name="pied_page_ligne_3" defaultValue={donneur?.pied_page_ligne_3 ?? ""} className={CHAMP} />
        </Champ>
      </div>
      <div className="flex flex-wrap gap-4">
        <Case name="actif" label="Donneur d'ordre affiché (actif)" checked={donneur?.actif ?? true} />
        <Case name="saisie_simplifiee_tablette" label="Saisie simplifiée sur tablette" checked={donneur?.saisie_simplifiee_tablette} />
      </div>
    </>
  );
}
