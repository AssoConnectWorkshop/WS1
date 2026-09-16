type Option = { id: number; libelle: string };
type Etat = { code: number; libelle: string | null };

/** Valeurs calculées depuis les événements (lecture seule sur la fiche Access). */
export type DerniersEvenements = {
  dateDernierEntretien?: string;
  kmDernierEntretien?: string;
  dateDernierCT?: string;
  dateDernierCC?: string;
  dateDernierReleve?: string;
  releveKm?: string;
};

const PETIT = "w-full rounded border bg-white px-1.5 py-0.5 text-xs dark:bg-white/5";
const LECTURE = `${PETIT} opacity-60`;
const LIGNE = "grid grid-cols-[11rem_1fr] items-center gap-x-2 gap-y-1 text-xs";

function Cadre({ titre, children, coche }: { titre: string; children: React.ReactNode; coche?: React.ReactNode }) {
  return (
    <fieldset className="flex flex-col gap-1.5 rounded border-2 border-black px-3 pb-3 pt-1 dark:border-white/60">
      <legend className="flex items-center gap-2 px-1 text-xs font-semibold underline">
        {titre}
        {coche}
      </legend>
      {children}
    </fieldset>
  );
}

/** Fiche véhicule Access (Form_99 « Modification Véhicule », analysis 04 §5.2), partagée entre création et modification. */
export function ChampsVehicule({ vehicule, conducteurs, etats, derniers = {} }: { vehicule?: Record<string, unknown>; conducteurs: Option[]; etats: Etat[]; derniers?: DerniersEvenements }) {
  const v = (vehicule ?? {}) as Record<string, string | number | boolean | null | undefined>;
  const texte = (k: string) => (v[k] == null ? "" : String(v[k]));
  const bool = (k: string) => !!v[k];

  return (
    <div className="flex flex-col gap-4">
      <input type="hidden" name="dernier_km" value={texte("dernier_km")} />
      <div className="grid gap-2 text-xs lg:grid-cols-3">
        <div className={LIGNE}>
          <span className="text-right">Immatriculation:</span>
          <input name="immatriculation" required defaultValue={texte("immatriculation")} className={`${PETIT} max-w-40 uppercase`} />
          <span className="text-right">Date Mise En Circulation:</span>
          <input name="date_mise_en_circulation" type="date" defaultValue={texte("date_mise_en_circulation")} className={`${PETIT} max-w-40`} />
        </div>
        <div className={LIGNE}>
          <span className="text-right">Conducteur:</span>
          <select name="conducteur_id" defaultValue={texte("conducteur_id")} className={PETIT}>
            <option value=""></option>
            {conducteurs.map((c) => (
              <option key={c.id} value={c.id}>
                {c.libelle}
              </option>
            ))}
          </select>
          <span className="text-right">KM à l&apos;achat:</span>
          <input name="km_achat" type="number" min={0} defaultValue={texte("km_achat")} className={`${PETIT} max-w-32`} />
        </div>
        <div className={LIGNE}>
          <span className="text-right">EtatVehicule:</span>
          <select name="etat_code" defaultValue={texte("etat_code")} className={PETIT}>
            <option value=""></option>
            {etats.map((e) => (
              <option key={e.code} value={e.code}>
                {e.libelle ?? `État ${e.code}`}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <div className="flex flex-col gap-4">
          <Cadre titre="Garantie:" coche={<input type="checkbox" name="garantie" value="1" defaultChecked={bool("garantie")} />}>
            <div className={LIGNE}>
              <span className="text-right">Km Garantie:</span>
              <input name="garantie_km" type="number" min={0} defaultValue={texte("garantie_km")} className={`${PETIT} max-w-32`} />
              <span className="text-right">Temps Garantie (Mois)</span>
              <input name="garantie_mois" type="number" min={0} defaultValue={texte("garantie_mois")} className={`${PETIT} max-w-32`} />
            </div>
          </Cadre>
          <Cadre titre="Revision(2):">
            <div className={LIGNE}>
              <span className="text-right">Km Entre 2 Revisions:</span>
              <input name="km_entre_revisions" type="number" min={0} defaultValue={texte("km_entre_revisions")} className={`${PETIT} max-w-32`} />
              <span className="text-right">Temps Entre 2 Revisions (Mois)</span>
              <input name="mois_entre_revisions" type="number" min={0} defaultValue={texte("mois_entre_revisions")} className={`${PETIT} max-w-32`} />
              <span className="text-right">Date Dernier Entretien:</span>
              <input disabled value={derniers.dateDernierEntretien ?? ""} className={`${LECTURE} max-w-32`} />
              <span className="text-right">KM Dernier Entretien:</span>
              <input disabled value={derniers.kmDernierEntretien ?? ""} className={`${LECTURE} max-w-32`} />
            </div>
          </Cadre>
          <Cadre titre="Divers:">
            <div className={LIGNE}>
              <span className="text-right">Numéro télépéage:</span>
              <input name="numero_telepeage" defaultValue={texte("numero_telepeage")} className={`${PETIT} max-w-32`} />
              <span className="text-right">Code Carte Essence</span>
              <input name="carte_essence_code" defaultValue={texte("carte_essence_code")} className={`${PETIT} max-w-32`} />
              <span className="text-right">Numéro Carte Essence:</span>
              <input name="carte_essence_numero" defaultValue={texte("carte_essence_numero")} className={`${PETIT} max-w-32`} />
              <span className="text-right">Marque</span>
              <input name="marque" defaultValue={texte("marque")} className={`${PETIT} max-w-32`} />
              <span className="text-right">Modele</span>
              <input name="modele" defaultValue={texte("modele")} className={`${PETIT} max-w-32`} />
              <span className="text-right">Société:</span>
              <select name="societe_vehicule" defaultValue={texte("societe_vehicule")} className={`${PETIT} max-w-32`}>
                <option value=""></option>
                <option value="0">FMC CLIM</option>
                <option value="1">FMC MAINT</option>
              </select>
              <span className="text-right">Crit&apos;Air</span>
              <input type="checkbox" name="crit_air" value="1" defaultChecked={bool("crit_air")} className="justify-self-start" />
            </div>
          </Cadre>
        </div>

        <div className="flex flex-col gap-4">
          <Cadre titre="Leasing:" coche={<input type="checkbox" name="leasing" value="1" defaultChecked={bool("leasing")} />}>
            <div className={LIGNE}>
              <span className="text-right">Km Leasing:</span>
              <input name="leasing_km" type="number" min={0} defaultValue={texte("leasing_km")} className={`${PETIT} max-w-32`} />
              <span className="text-right">Temps Leasing (Mois)</span>
              <input name="leasing_mois" type="number" min={0} defaultValue={texte("leasing_mois")} className={`${PETIT} max-w-32`} />
              <span className="text-right">Date Fin Leasing:</span>
              <input name="leasing_date_fin" type="date" defaultValue={texte("leasing_date_fin")} className={`${PETIT} max-w-40`} />
            </div>
          </Cadre>
          <Cadre titre="Controle Tech.(3)/Controle Compl.(4)/Km(1/5):">
            <div className={LIGNE}>
              <span className="text-right">Date Dernier Controle Technique</span>
              <input disabled value={derniers.dateDernierCT ?? ""} className={`${LECTURE} max-w-32`} />
              <span className="text-right">Date Dernier Controle Complem.</span>
              <input disabled value={derniers.dateDernierCC ?? ""} className={`${LECTURE} max-w-32`} />
              <span className="text-right">Date Dernier Releve Km:</span>
              <input disabled value={derniers.dateDernierReleve ?? ""} className={`${LECTURE} max-w-32`} />
              <span className="text-right">Releve Km:</span>
              <input disabled value={derniers.releveKm ?? ""} className={`${LECTURE} max-w-32`} />
            </div>
          </Cadre>
          <Cadre titre="Raccourci vers le PC:">
            <input name="dossier_chemin" defaultValue={texte("dossier_chemin")} placeholder="Déposer ici le raccourci vers le dossier du pc" className={`${PETIT} text-blue-700`} />
          </Cadre>
        </div>
      </div>
    </div>
  );
}
