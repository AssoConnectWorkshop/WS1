import { CHAMP } from "@/components/ui/Champ";
import { CLES_LOTS, JOURS, type Lot } from "@/lib/sites";
import { mettreAJourContrat, mettreAJourHoraires } from "@/app/(app)/sites/actions";

export type Contrat = {
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

/** Libellés des trois cadres « Contrat Entretien … » de la fiche Access (analysis 03 §2.2). */
const LIBELLES: Record<Lot, { titre: string; numero: string; tarif: string }> = {
  clim: { titre: "Contrat Entretien Clim", numero: "N° Contrat Clim.", tarif: "Tarif Clim 1 FMC" },
  chaudiere: { titre: "Contrat Entretien Chaudière", numero: "N° Contrat Chaudière", tarif: "Tarif Chaudière FMC" },
  desenfumage: { titre: "Contrat Entretien Désenfumage", numero: "N° Contrat Désenfum.", tarif: "Tarif désenf. FMC" },
};

const PETIT = "w-full rounded border bg-white px-1.5 py-0.5 text-sm dark:bg-white/5";
const LIGNE = "grid grid-cols-[minmax(0,7.5rem)_1fr] items-center gap-x-2 gap-y-1 text-xs";

/** Trois cadres éditables, un par lot ; la clim porte deux redevances (technique / filtres). */
export function ContratsSite({ siteId, contrats, intervenants }: { siteId: number; contrats: Contrat[]; intervenants: Option[] }) {
  return (
    <>
      {CLES_LOTS.map((lot) => (
        <FormulaireContrat key={lot} siteId={siteId} lot={lot} contrat={contrats.find((c) => c.lot === lot)} intervenants={intervenants} />
      ))}
    </>
  );
}

function FormulaireContrat({ siteId, lot, contrat, intervenants }: { siteId: number; lot: Lot; contrat?: Contrat; intervenants: Option[] }) {
  const l = LIBELLES[lot];
  return (
    <form action={mettreAJourContrat} className="flex flex-col gap-1.5 rounded border px-2 pb-2 pt-1">
      <span className="px-1 text-xs font-semibold">{l.titre}</span>
      <input type="hidden" name="site_id" value={siteId} />
      <input type="hidden" name="lot" value={lot} />
      <div className={LIGNE}>
        <span>{l.numero}</span>
        <input name="numero_contrat" defaultValue={contrat?.numero_contrat ?? ""} className={PETIT} />
        <span>Date Prise en Charge</span>
        <div className="grid grid-cols-[1fr_auto_3.5rem] items-center gap-1">
          <input name="date_contrat" type="date" defaultValue={contrat?.date_contrat ?? ""} className={PETIT} />
          <span>Nb /an</span>
          <input name="visites_par_an" type="number" min={0} defaultValue={contrat?.visites_par_an ?? ""} className={`${PETIT} border-red-500`} />
        </div>
        <span>{l.tarif}</span>
        <input name="redevance" type="number" step="0.01" defaultValue={contrat?.redevance ?? ""} className={PETIT} />
        {lot === "clim" && (
          <>
            <span>Tarif Clim 2 FMC</span>
            <div className="grid grid-cols-[1fr_auto_3.5rem] items-center gap-1">
              <input name="redevance_secondaire" type="number" step="0.01" defaultValue={contrat?.redevance_secondaire ?? ""} className={PETIT} />
              <span>Nb.(Infos)</span>
              <input name="visites_secondaires" type="number" min={0} defaultValue={contrat?.visites_secondaires ?? ""} className={PETIT} />
            </div>
          </>
        )}
        <span>Nom Sous Traitant</span>
        <select name="sous_traitant_id" defaultValue={contrat?.sous_traitant_id ?? ""} className={PETIT}>
          <option value=""></option>
          {intervenants.map((i) => (
            <option key={i.id} value={i.id}>
              {i.libelle}
            </option>
          ))}
        </select>
        <span>Tarif Sous Traitant</span>
        <input name="tarif_sous_traitant" type="number" step="0.01" defaultValue={contrat?.tarif_sous_traitant ?? ""} className={PETIT} />
        <span>Date signature</span>
        <input name="date_signature" type="date" defaultValue={contrat?.date_signature ?? ""} className={PETIT} />
      </div>
      <button type="submit" className="w-fit rounded border px-2 py-0.5 text-xs">
        Enregistrer le contrat
      </button>
    </form>
  );
}

type Horaire = { jour: number; ouverture: string | null; fermeture: string | null };

export function HorairesSite({ siteId, horaires }: { siteId: number; horaires: Horaire[] }) {
  return (
    <form action={mettreAJourHoraires} className="flex flex-col gap-3 rounded-xl border p-4">
      <h2 className="text-sm font-semibold">Horaires d&apos;ouverture</h2>
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
                  <input name={`ouverture_${jour}`} type="time" defaultValue={h?.ouverture?.slice(0, 5) ?? ""} className={CHAMP} />
                </td>
                <td>
                  <input name={`fermeture_${jour}`} type="time" defaultValue={h?.fermeture?.slice(0, 5) ?? ""} className={CHAMP} />
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
