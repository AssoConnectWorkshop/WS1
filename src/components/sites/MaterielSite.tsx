import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Case, Champ, CHAMP } from "@/components/ui/Champ";
import { EmptyState } from "@/components/ui/EmptyState";
import { formatDate, formatNombre, oui } from "@/lib/format";
import { REVERSIBLE_VALEURS } from "@/lib/sites";
import { ajouterMaterielDepuisCatalogue, ajouterMaterielVide, mettreAJourMateriel, supprimerMateriel } from "@/app/(app)/sites/actions";

type Materiel = {
  id: number;
  repere_sur_site: number | null;
  repere: string | null;
  emplacement: string | null;
  quantite: number | null;
  marque: string | null;
  type_equipement: string | null;
  reference: string | null;
  numero_serie: string | null;
  reversible: string | null;
  resistance_electrique: string | null;
  puissance_frigo_w: number | null;
  puissance_calo_w: number | null;
  fluide_libelle: string | null;
  charge_fluide_kg: number | null;
  date_mise_en_service: string | null;
  type_telecommande: string | null;
  nombre_telecommandes: number | null;
  emplacement_telecommande: string | null;
  date_controle_etancheite: string | null;
  certificat_etancheite_edite: boolean;
  observations: string | null;
};

function ListeChoix({ id, valeurs }: { id: string; valeurs: (string | null)[] }) {
  return (
    <datalist id={id}>
      {valeurs.filter((v): v is string => !!v).map((v) => (
        <option key={v} value={v} />
      ))}
    </datalist>
  );
}

/** Inventaire réel du site : ajout depuis le catalogue (analysis 03 §3.3), édition en ligne d'un équipement (`?modifier=<id>`). */
export async function MaterielSite({ siteId, modifierId }: { siteId: number; modifierId?: string }) {
  const supabase = await createClient();
  const [{ data: materiels }, { data: references }, { data: reperes }, { data: types }, { data: marques }, { data: telecommandes }, { data: fluides }] =
    await Promise.all([
      supabase.from("site_materiels").select("*").eq("site_id", siteId).order("repere_sur_site").order("id"),
      supabase.from("references_materiel").select("id, reference, repere, marques(libelle)").order("reference"),
      supabase.from("reperes").select("libelle").order("libelle"),
      supabase.from("types_equipement").select("libelle").order("libelle"),
      supabase.from("marques").select("libelle").order("libelle"),
      supabase.from("types_telecommande").select("libelle").order("libelle"),
      supabase.from("types_fluide").select("libelle").order("libelle"),
    ]);
  const lignes = (materiels ?? []) as Materiel[];
  const catalogue = (references ?? []) as unknown as { id: number; reference: string | null; repere: string | null; marques: { libelle: string | null } | null }[];
  const enEdition = lignes.find((m) => String(m.id) === modifierId);

  return (
    <div className="flex flex-col gap-4">
      <form action={ajouterMaterielDepuisCatalogue} className="flex flex-col gap-3 rounded-xl border p-4">
        <h2 className="text-sm font-semibold opacity-70">Ajouter depuis le catalogue</h2>
        <input type="hidden" name="site_id" value={siteId} />
        <div className="grid grid-cols-[1fr_6rem_auto] items-end gap-3">
          <Champ label="Référence 1">
            <select name="reference_1_id" className={CHAMP}>
              <option value="">—</option>
              {catalogue.map((r) => (
                <option key={r.id} value={r.id}>
                  {[r.repere, r.reference, r.marques?.libelle].filter(Boolean).join(" · ")}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="Nombre">
            <input name="nombre_1" type="number" min={1} max={100} defaultValue={1} className={CHAMP} />
          </Champ>
          <button type="submit" name="mode" value="ref1" className="rounded-md border px-3 py-2 text-sm">
            Ajouter référence 1
          </button>
          <Champ label="Référence 2">
            <select name="reference_2_id" className={CHAMP}>
              <option value="">—</option>
              {catalogue.map((r) => (
                <option key={r.id} value={r.id}>
                  {[r.repere, r.reference, r.marques?.libelle].filter(Boolean).join(" · ")}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="Nombre">
            <input name="nombre_2" type="number" min={1} max={100} defaultValue={1} className={CHAMP} />
          </Champ>
          <button type="submit" name="mode" value="ref2" className="rounded-md border px-3 py-2 text-sm">
            Ajouter référence 2
          </button>
          <span className="text-xs opacity-60">Alternance : référence 1 puis référence 2, N fois (paires intérieur / extérieur).</span>
          <Champ label="Paires">
            <input name="nombre_3" type="number" min={1} max={100} defaultValue={1} className={CHAMP} />
          </Champ>
          <button type="submit" name="mode" value="alternance" className="rounded-md border px-3 py-2 text-sm">
            Ajouter 1 puis 2
          </button>
        </div>
        <p className="text-xs opacity-60">Une ligne par équipement (quantité 1), valeurs copiées du catalogue. Aucune référence dans la liste ? Le catalogue se remplit au paramétrage (5.6).</p>
      </form>

      {enEdition && (
        <form action={mettreAJourMateriel} className="flex flex-col gap-3 rounded-xl border border-black/30 p-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold opacity-70">Équipement #{enEdition.id}</h2>
            <Link href={`/sites/${siteId}?onglet=materiel`} className="text-xs underline">
              Fermer
            </Link>
          </div>
          <input type="hidden" name="site_id" value={siteId} />
          <input type="hidden" name="materiel_id" value={enEdition.id} />
          <div className="grid grid-cols-4 gap-3">
            <Champ label="Repère sur site (n°)">
              <input name="repere_sur_site" type="number" defaultValue={enEdition.repere_sur_site ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="Repère (famille)">
              <input name="repere" list="reperes" defaultValue={enEdition.repere ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="Type d'équipement">
              <input name="type_equipement" list="types_equipement" defaultValue={enEdition.type_equipement ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="Marque">
              <input name="marque" list="marques" defaultValue={enEdition.marque ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="Référence">
              <input name="reference" defaultValue={enEdition.reference ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="N° de série">
              <input name="numero_serie" defaultValue={enEdition.numero_serie ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="Emplacement">
              <input name="emplacement" defaultValue={enEdition.emplacement ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="Quantité">
              <input name="quantite" type="number" min={1} defaultValue={enEdition.quantite ?? 1} className={CHAMP} />
            </Champ>
            <Champ label="Réversible">
              <select name="reversible" defaultValue={enEdition.reversible ?? ""} className={CHAMP}>
                <option value="">—</option>
                {REVERSIBLE_VALEURS.map((v) => (
                  <option key={v} value={v}>
                    {v}
                  </option>
                ))}
              </select>
            </Champ>
            <Champ label="Résistance électrique">
              <select name="resistance_electrique" defaultValue={enEdition.resistance_electrique ?? ""} className={CHAMP}>
                <option value="">—</option>
                {REVERSIBLE_VALEURS.map((v) => (
                  <option key={v} value={v}>
                    {v}
                  </option>
                ))}
              </select>
            </Champ>
            <Champ label="P. frigorifique (W)">
              <input name="puissance_frigo_w" type="number" defaultValue={enEdition.puissance_frigo_w ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="P. calorifique (W)">
              <input name="puissance_calo_w" type="number" defaultValue={enEdition.puissance_calo_w ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="Fluide">
              <input name="fluide_libelle" list="fluides" defaultValue={enEdition.fluide_libelle ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="Charge fluide (kg)">
              <input name="charge_fluide_kg" type="number" step="0.01" defaultValue={enEdition.charge_fluide_kg ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="Mise en service">
              <input name="date_mise_en_service" type="date" defaultValue={enEdition.date_mise_en_service ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="Type de télécommande">
              <input name="type_telecommande" list="telecommandes" defaultValue={enEdition.type_telecommande ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="Nb télécommandes">
              <input name="nombre_telecommandes" type="number" min={0} defaultValue={enEdition.nombre_telecommandes ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="Emplacement télécommande">
              <input name="emplacement_telecommande" defaultValue={enEdition.emplacement_telecommande ?? ""} className={CHAMP} />
            </Champ>
            <Champ label="Date contrôle d'étanchéité">
              <input name="date_controle_etancheite" type="date" defaultValue={enEdition.date_controle_etancheite ?? ""} className={CHAMP} />
            </Champ>
            <div className="flex items-end pb-2">
              <Case name="certificat_etancheite_edite" label="CE annuel édité" checked={enEdition.certificat_etancheite_edite} />
            </div>
          </div>
          <Champ label="Observations">
            <textarea name="observations" rows={2} defaultValue={enEdition.observations ?? ""} className={CHAMP} />
          </Champ>
          <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
            Enregistrer l&apos;équipement
          </button>
          <ListeChoix id="reperes" valeurs={(reperes ?? []).map((r) => r.libelle)} />
          <ListeChoix id="types_equipement" valeurs={(types ?? []).map((t) => t.libelle)} />
          <ListeChoix id="marques" valeurs={(marques ?? []).map((m) => m.libelle)} />
          <ListeChoix id="telecommandes" valeurs={(telecommandes ?? []).map((t) => t.libelle)} />
          <ListeChoix id="fluides" valeurs={(fluides ?? []).map((f) => f.libelle)} />
        </form>
      )}

      <div className="flex items-center justify-between">
        <h2 className="text-sm font-semibold opacity-70">{lignes.length} équipement(s)</h2>
        <form action={ajouterMaterielVide}>
          <input type="hidden" name="site_id" value={siteId} />
          <button type="submit" className="rounded-md border px-3 py-1.5 text-sm">
            Ajouter un équipement vide
          </button>
        </form>
      </div>

      {lignes.length === 0 ? (
        <EmptyState message="Aucun matériel enregistré." />
      ) : (
        <table className="w-full border-collapse text-sm">
          <thead>
            <tr className="border-b text-left">
              <th className="py-1">N°</th>
              <th>Repère</th>
              <th>Marque</th>
              <th>Type</th>
              <th>Référence</th>
              <th>N° série</th>
              <th>Fluide</th>
              <th className="text-right">kg</th>
              <th>MES</th>
              <th>CE</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {lignes.map((m) => (
              <tr key={m.id} className={`border-b ${String(m.id) === modifierId ? "bg-black/[0.03] dark:bg-white/[0.05]" : ""}`}>
                <td className="py-1">{m.repere_sur_site ?? "—"}</td>
                <td>{m.repere ?? "—"}</td>
                <td>{m.marque ?? "—"}</td>
                <td>{m.type_equipement ?? "—"}</td>
                <td>{m.reference ?? "—"}</td>
                <td>{m.numero_serie ?? "—"}</td>
                <td>{m.fluide_libelle ?? "—"}</td>
                <td className="text-right">{formatNombre(m.charge_fluide_kg)}</td>
                <td>{formatDate(m.date_mise_en_service)}</td>
                <td className="whitespace-nowrap">
                  {oui(m.certificat_etancheite_edite)}
                  {m.date_controle_etancheite && (
                    <a href={`/materiels/${m.id}/certificat.pdf`} target="_blank" rel="noreferrer" className="ml-1 text-xs underline">
                      PDF
                    </a>
                  )}
                </td>
                <td className="whitespace-nowrap text-right">
                  <Link href={`/sites/${siteId}?onglet=materiel&modifier=${m.id}`} className="text-xs underline">
                    Modifier
                  </Link>
                  <form action={supprimerMateriel} className="ml-2 inline">
                    <input type="hidden" name="site_id" value={siteId} />
                    <input type="hidden" name="materiel_id" value={m.id} />
                    <button type="submit" className="text-xs text-red-700 underline">
                      Supprimer
                    </button>
                  </form>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
