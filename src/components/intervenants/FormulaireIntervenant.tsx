import { Case, Champ, CHAMP } from "@/components/ui/Champ";
import { ETOILES } from "@/lib/sites";

type Option = { id: number; libelle: string };

function Note({ name, valeur, label }: { name: string; valeur: number | null | undefined; label: string }) {
  return (
    <Champ label={label}>
      <select name={name} defaultValue={valeur ?? ""} className={CHAMP}>
        <option value="">—</option>
        {ETOILES.map((n) => (
          <option key={n} value={n}>
            {"★".repeat(n)}
          </option>
        ))}
      </select>
    </Champ>
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

/** Champs de la fiche intervenant (analysis 03 §4), partagés entre création et modification. */
export function ChampsIntervenant({ intervenant, gestionnaires }: { intervenant?: Record<string, unknown>; gestionnaires: Option[] }) {
  const v = (intervenant ?? {}) as Record<string, string | number | boolean | null | undefined>;
  const texte = (k: string) => (v[k] == null ? "" : String(v[k]));
  const bool = (k: string) => !!v[k];
  const note = (k: string) => (typeof v[k] === "number" ? (v[k] as number) : null);

  return (
    <>
      <Section titre="Identité">
        <div className="grid grid-cols-[8rem_1fr] gap-3">
          <Champ label="Code *">
            <input name="code" required defaultValue={texte("code")} className={`${CHAMP} uppercase`} placeholder="FMC" />
          </Champ>
          <Champ label="Nom">
            <input name="nom" defaultValue={texte("nom")} className={CHAMP} />
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
          <Champ label="Téléphone">
            <input name="telephone" defaultValue={texte("telephone")} className={CHAMP} />
          </Champ>
          <Champ label="Fax">
            <input name="fax" defaultValue={texte("fax")} className={CHAMP} />
          </Champ>
        </div>
        <div className="grid grid-cols-3 gap-3">
          <Champ label="E-mail">
            <input name="email" type="email" defaultValue={texte("email")} className={CHAMP} />
          </Champ>
          <Champ label="E-mail facturation">
            <input name="email_facturation" type="email" defaultValue={texte("email_facturation")} className={CHAMP} />
          </Champ>
          <Champ label="Site internet">
            <input name="site_internet" defaultValue={texte("site_internet")} className={CHAMP} />
          </Champ>
        </div>
      </Section>

      <Section titre="Contacts">
        <div className="grid grid-cols-3 gap-3">
          <Champ label="Dirigeant">
            <input name="dirigeant_nom" defaultValue={texte("dirigeant_nom")} className={CHAMP} />
          </Champ>
          <Champ label="Tél. dirigeant">
            <input name="dirigeant_telephone" defaultValue={texte("dirigeant_telephone")} className={CHAMP} />
          </Champ>
          <Champ label="E-mail dirigeant">
            <input name="dirigeant_email" type="email" defaultValue={texte("dirigeant_email")} className={CHAMP} />
          </Champ>
          <Champ label="Interlocuteur">
            <input name="interlocuteur_nom" defaultValue={texte("interlocuteur_nom")} className={CHAMP} />
          </Champ>
          <Champ label="Tél. interlocuteur">
            <input name="interlocuteur_telephone" defaultValue={texte("interlocuteur_telephone")} className={CHAMP} />
          </Champ>
          <Champ label="Interlocuteur FMC">
            <select name="interlocuteur_fmc_id" defaultValue={texte("interlocuteur_fmc_id")} className={CHAMP}>
              <option value="">—</option>
              {gestionnaires.map((g) => (
                <option key={g.id} value={g.id}>
                  {g.libelle}
                </option>
              ))}
            </select>
          </Champ>
        </div>
      </Section>

      <Section titre="Statut">
        <div className="flex flex-wrap gap-4">
          <Case name="est_technicien_interne" label="Technicien (sinon intervenant)" checked={bool("est_technicien_interne")} />
          <Case name="est_prospect" label="Prospect" checked={bool("est_prospect")} />
          <Case name="est_sous_traitant" label="Sous-traitant FMC" checked={bool("est_sous_traitant")} />
          <Case name="est_sous_traitant_ponctuel" label="Sous-traitant FMC (ponctuel)" checked={bool("est_sous_traitant_ponctuel")} />
          <Case name="n_existe_plus" label="N'existe plus" checked={bool("n_existe_plus")} />
          <Case name="autoliquidation" label="Autoliquidation" checked={bool("autoliquidation")} />
        </div>
        <div className="grid grid-cols-2 gap-3 text-sm">
          <div className="flex flex-col gap-1">
            <span className="text-xs opacity-60">Activité possible (ce que le sous-traitant sait faire)</span>
            <div className="flex flex-wrap gap-4">
              <Case name="peut_maintenance" label="Maintenance" checked={bool("peut_maintenance")} />
              <Case name="peut_depannage" label="Dépannage" checked={bool("peut_depannage")} />
              <Case name="peut_travaux" label="Travaux" checked={bool("peut_travaux")} />
            </div>
          </div>
          <div className="flex flex-col gap-1">
            <span className="text-xs opacity-60">Activité confiée par FMC</span>
            <div className="flex flex-wrap gap-4">
              <Case name="confie_maintenance" label="Maintenance" checked={bool("confie_maintenance")} />
              <Case name="confie_depannage" label="Dépannage" checked={bool("confie_depannage")} />
              <Case name="confie_travaux" label="Travaux" checked={bool("confie_travaux")} />
            </div>
          </div>
        </div>
      </Section>

      <Section titre="Qualité">
        <div className="grid grid-cols-4 gap-3">
          <Note name="note_maintenance" valeur={note("note_maintenance")} label="Maintenance" />
          <Note name="note_depannage" valeur={note("note_depannage")} label="Dépannage" />
          <Note name="note_travaux" valeur={note("note_travaux")} label="Travaux" />
          <Note name="note_reactivite" valeur={note("note_reactivite")} label="Réactivité" />
        </div>
      </Section>

      <Section titre="Divers">
        <Case name="zone_nationale" label="Zone nationale (intervient partout)" checked={bool("zone_nationale")} />
        <Champ label="Villes ou codes postaux d'intervention (séparés par des virgules)">
          <input name="villes_codes_postaux" defaultValue={texte("villes_codes_postaux")} className={CHAMP} />
        </Champ>
        <div className="grid grid-cols-2 gap-3">
          <Champ label="Provenance">
            <input name="provenance" defaultValue={texte("provenance")} className={CHAMP} />
          </Champ>
          <Champ label="Raccourci vers le dossier">
            <input name="dossier_chemin" defaultValue={texte("dossier_chemin")} className={CHAMP} />
          </Champ>
        </div>
        <Champ label="Informations">
          <textarea name="informations" rows={3} defaultValue={texte("informations")} className={CHAMP} />
        </Champ>
        <Champ label="Historique FMC">
          <textarea name="historique_fmc" rows={3} defaultValue={texte("historique_fmc")} className={CHAMP} />
        </Champ>
      </Section>
    </>
  );
}
