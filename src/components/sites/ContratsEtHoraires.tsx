import { Champ, CHAMP } from "@/components/ui/Champ";
import { CLES_LOTS, JOURS, LIBELLES_LOT, type Lot } from "@/lib/sites";
import { mettreAJourContrat, mettreAJourHoraires } from "@/app/(app)/sites/actions";

type Contrat = {
  lot: string;
  numero_contrat: string | null;
  date_contrat: string | null;
  date_signature: string | null;
  visites_par_an: number | null;
  redevance: number | null;
  redevance_secondaire: number | null;
  visites_secondaires: number | null;
  sous_traitant_id: number | null;
  tarif_sous_traitant: number | null;
};

type Option = { id: number; libelle: string | null };

/** Trois blocs éditables, un par lot (analysis 03 §2.2) ; la clim porte deux redevances (technique / filtres). */
export function ContratsSite({ siteId, contrats, intervenants }: { siteId: number; contrats: Contrat[]; intervenants: Option[] }) {
  return (
    <div className="grid gap-4 lg:grid-cols-3">
      {CLES_LOTS.map((lot) => (
        <FormulaireContrat key={lot} siteId={siteId} lot={lot} contrat={contrats.find((c) => c.lot === lot)} intervenants={intervenants} />
      ))}
    </div>
  );
}

function FormulaireContrat({ siteId, lot, contrat, intervenants }: { siteId: number; lot: Lot; contrat?: Contrat; intervenants: Option[] }) {
  return (
    <form action={mettreAJourContrat} className="flex flex-col gap-3 rounded-xl border p-4">
      <h2 className="text-sm font-semibold opacity-70">
        Contrat {LIBELLES_LOT[lot]}
        {!contrat && <span className="ml-2 text-xs font-normal opacity-60">(aucune ligne : créée à l&apos;enregistrement)</span>}
      </h2>
      <input type="hidden" name="site_id" value={siteId} />
      <input type="hidden" name="lot" value={lot} />
      <Champ label="N° de contrat">
        <input name="numero_contrat" defaultValue={contrat?.numero_contrat ?? ""} className={CHAMP} />
      </Champ>
      <div className="grid grid-cols-2 gap-3">
        <Champ label="Prise en charge">
          <input name="date_contrat" type="date" defaultValue={contrat?.date_contrat ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Signature">
          <input name="date_signature" type="date" defaultValue={contrat?.date_signature ?? ""} className={CHAMP} />
        </Champ>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <Champ label="Visites / an">
          <input name="visites_par_an" type="number" min={0} defaultValue={contrat?.visites_par_an ?? ""} className={CHAMP} />
        </Champ>
        <Champ label={lot === "clim" ? "Redevance technique FMC" : "Redevance FMC"}>
          <input name="redevance" type="number" step="0.01" defaultValue={contrat?.redevance ?? ""} className={CHAMP} />
        </Champ>
      </div>
      {lot === "clim" && (
        <div className="grid grid-cols-2 gap-3">
          <Champ label="Visites filtres / an">
            <input name="visites_secondaires" type="number" min={0} defaultValue={contrat?.visites_secondaires ?? ""} className={CHAMP} />
          </Champ>
          <Champ label="Redevance filtres FMC">
            <input name="redevance_secondaire" type="number" step="0.01" defaultValue={contrat?.redevance_secondaire ?? ""} className={CHAMP} />
          </Champ>
        </div>
      )}
      <Champ label="Sous-traitant">
        <select name="sous_traitant_id" defaultValue={contrat?.sous_traitant_id ?? ""} className={CHAMP}>
          <option value="">— FMC / intervenant du site —</option>
          {intervenants.map((i) => (
            <option key={i.id} value={i.id}>
              {i.libelle}
            </option>
          ))}
        </select>
      </Champ>
      <Champ label="Tarif sous-traitant">
        <input name="tarif_sous_traitant" type="number" step="0.01" defaultValue={contrat?.tarif_sous_traitant ?? ""} className={CHAMP} />
      </Champ>
      <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
        Enregistrer
      </button>
    </form>
  );
}

type Horaire = { jour: number; ouverture: string | null; fermeture: string | null };

export function HorairesSite({ siteId, horaires }: { siteId: number; horaires: Horaire[] }) {
  return (
    <form action={mettreAJourHoraires} className="flex flex-col gap-3 rounded-xl border p-4">
      <input type="hidden" name="site_id" value={siteId} />
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b text-left">
            <th className="py-1">Jour</th>
            <th>Ouverture</th>
            <th>Fermeture</th>
          </tr>
        </thead>
        <tbody>
          {JOURS.map((nom, i) => {
            const jour = i + 1;
            const h = horaires.find((x) => x.jour === jour);
            return (
              <tr key={jour} className="border-b">
                <td className="py-1">{nom}</td>
                <td>
                  <input name={`ouverture_${jour}`} type="time" defaultValue={h?.ouverture?.slice(0, 5) ?? ""} className="rounded-md border px-2 py-1" />
                </td>
                <td>
                  <input name={`fermeture_${jour}`} type="time" defaultValue={h?.fermeture?.slice(0, 5) ?? ""} className="rounded-md border px-2 py-1" />
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
      <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
        Enregistrer les horaires
      </button>
    </form>
  );
}
