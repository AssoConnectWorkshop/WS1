import { Case, Champ, CHAMP, Section } from "@/components/ui/Champ";

type Option = { id: number; libelle: string };
type Etat = { code: number; libelle: string | null };

/** Champs de la fiche véhicule (Saisie_Vehicule, analysis 04 §5.2), partagés entre création et modification. */
export function ChampsVehicule({ vehicule, conducteurs, etats }: { vehicule?: Record<string, unknown>; conducteurs: Option[]; etats: Etat[] }) {
  const v = (vehicule ?? {}) as Record<string, string | number | boolean | null | undefined>;
  const texte = (k: string) => (v[k] == null ? "" : String(v[k]));
  const bool = (k: string) => !!v[k];

  return (
    <>
      <Section titre="Véhicule">
        <div className="grid grid-cols-4 gap-3">
          <Champ label="Immatriculation *">
            <input name="immatriculation" required defaultValue={texte("immatriculation")} className={`${CHAMP} uppercase`} />
          </Champ>
          <Champ label="Marque">
            <input name="marque" defaultValue={texte("marque")} className={CHAMP} />
          </Champ>
          <Champ label="Modèle">
            <input name="modele" defaultValue={texte("modele")} className={CHAMP} />
          </Champ>
          <Champ label="État">
            <select name="etat_code" defaultValue={texte("etat_code")} className={CHAMP}>
              <option value="">—</option>
              {etats.map((e) => (
                <option key={e.code} value={e.code}>
                  {e.libelle ?? `État ${e.code}`}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="Société">
            <select name="societe_vehicule" defaultValue={texte("societe_vehicule")} className={CHAMP}>
              <option value="">—</option>
              <option value="0">FMC Clim</option>
              <option value="1">FMC Maintenance</option>
            </select>
          </Champ>
          <Champ label="Conducteur">
            <select name="conducteur_id" defaultValue={texte("conducteur_id")} className={CHAMP}>
              <option value="">—</option>
              {conducteurs.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.libelle}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="Mise en circulation">
            <input name="date_mise_en_circulation" type="date" defaultValue={texte("date_mise_en_circulation")} className={CHAMP} />
          </Champ>
          <div className="flex items-end pb-2">
            <Case name="crit_air" label="Crit'Air" checked={bool("crit_air")} />
          </div>
        </div>
      </Section>

      <Section titre="Kilométrage et révisions">
        <div className="grid grid-cols-4 gap-3">
          <Champ label="Km à l'achat">
            <input name="km_achat" type="number" min={0} defaultValue={texte("km_achat")} className={CHAMP} />
          </Champ>
          <Champ label="Dernier km connu">
            <input name="dernier_km" type="number" min={0} defaultValue={texte("dernier_km")} className={CHAMP} />
          </Champ>
          <Champ label="Km entre révisions">
            <input name="km_entre_revisions" type="number" min={0} defaultValue={texte("km_entre_revisions")} className={CHAMP} />
          </Champ>
          <Champ label="Mois entre révisions">
            <input name="mois_entre_revisions" type="number" min={0} defaultValue={texte("mois_entre_revisions")} className={CHAMP} />
          </Champ>
        </div>
      </Section>

      <Section titre="Garantie et leasing">
        <div className="grid grid-cols-4 gap-3">
          <div className="flex items-end pb-2">
            <Case name="garantie" label="Sous garantie" checked={bool("garantie")} />
          </div>
          <Champ label="Garantie (km)">
            <input name="garantie_km" type="number" min={0} defaultValue={texte("garantie_km")} className={CHAMP} />
          </Champ>
          <Champ label="Garantie (mois)">
            <input name="garantie_mois" type="number" min={0} defaultValue={texte("garantie_mois")} className={CHAMP} />
          </Champ>
          <div />
          <div className="flex items-end pb-2">
            <Case name="leasing" label="En leasing" checked={bool("leasing")} />
          </div>
          <Champ label="Leasing (km)">
            <input name="leasing_km" type="number" min={0} defaultValue={texte("leasing_km")} className={CHAMP} />
          </Champ>
          <Champ label="Leasing (mois)">
            <input name="leasing_mois" type="number" min={0} defaultValue={texte("leasing_mois")} className={CHAMP} />
          </Champ>
          <Champ label="Fin de leasing">
            <input name="leasing_date_fin" type="date" defaultValue={texte("leasing_date_fin")} className={CHAMP} />
          </Champ>
        </div>
      </Section>

      <Section titre="Divers">
        <div className="grid grid-cols-3 gap-3">
          <Champ label="N° télépéage">
            <input name="numero_telepeage" defaultValue={texte("numero_telepeage")} className={CHAMP} />
          </Champ>
          <Champ label="Code carte essence">
            <input name="carte_essence_code" defaultValue={texte("carte_essence_code")} className={CHAMP} />
          </Champ>
          <Champ label="N° carte essence">
            <input name="carte_essence_numero" defaultValue={texte("carte_essence_numero")} className={CHAMP} />
          </Champ>
        </div>
        <Champ label="Raccourci vers le dossier du véhicule">
          <input name="dossier_chemin" defaultValue={texte("dossier_chemin")} className={CHAMP} />
        </Champ>
      </Section>
    </>
  );
}
