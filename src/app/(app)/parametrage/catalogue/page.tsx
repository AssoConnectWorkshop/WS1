import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser } from "@/lib/auth";
import { toStringParams } from "@/lib/list-params";
import { Case, Champ, CHAMP } from "@/components/ui/Champ";
import { EmptyState } from "@/components/ui/EmptyState";
import { REVERSIBLE_VALEURS } from "@/lib/sites";
import { enregistrerReference, supprimerReference } from "./actions";

export const dynamic = "force-dynamic";

type Reference = Record<string, string | number | null> & { id: number };

export default async function CataloguePage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();
  const [current, { data: marques }, { data: fluides }, { data: reperes }, { data: types }, { data: telecommandes }] = await Promise.all([
    getCurrentUser(),
    supabase.from("marques").select("id, libelle").order("libelle"),
    supabase.from("types_fluide").select("id, libelle").order("libelle"),
    supabase.from("reperes").select("libelle").order("libelle"),
    supabase.from("types_equipement").select("libelle").order("libelle"),
    supabase.from("types_telecommande").select("libelle").order("libelle"),
  ]);
  const estAdmin = current?.role === "administrateur";

  let requete = supabase.from("references_materiel").select("*, marques(libelle), types_fluide(libelle)").order("reference").limit(200);
  if (sp.recherche) requete = requete.or(`reference.ilike.%${sp.recherche}%,repere.ilike.%${sp.recherche}%,type_equipement.ilike.%${sp.recherche}%`);
  const { data } = await requete;
  const references = (data ?? []) as unknown as (Reference & { marques: { libelle: string } | null; types_fluide: { libelle: string } | null })[];
  const enEdition = sp.modifier ? references.find((r) => String(r.id) === sp.modifier) : undefined;
  const afficherFormulaire = estAdmin && (sp.ajouter === "1" || enEdition);

  return (
    <div className="mx-auto flex max-w-6xl flex-col gap-4 p-8">
      <div>
        <Link href="/parametrage" className="text-sm underline">
          ← Paramétrage
        </Link>
      </div>
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Catalogue de références matériel</h1>
        {estAdmin && (
          <Link href="/parametrage/catalogue?ajouter=1" className="rounded-md bg-black px-3 py-2 text-sm text-white">
            Nouvelle référence
          </Link>
        )}
      </div>
      {sp.erreur && <p className="rounded-md bg-red-50 p-3 text-sm text-red-700">{sp.erreur}</p>}
      {sp.info && <p className="rounded-md bg-blue-50 p-3 text-sm text-blue-800">{sp.info}</p>}

      <form method="GET" className="flex items-end gap-2 text-sm">
        <Champ label="Rechercher (référence, repère, type)">
          <input name="recherche" defaultValue={sp.recherche} className={CHAMP} />
        </Champ>
        <button type="submit" className="rounded-md border px-3 py-2">
          Filtrer
        </button>
      </form>

      {afficherFormulaire && (
        <form action={enregistrerReference} className="flex flex-col gap-3 rounded-xl border border-black/30 p-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold opacity-70">{enEdition ? `Modification de la référence « ${enEdition.reference} »` : "Ajout d'une référence"}</h2>
            <Link href="/parametrage/catalogue" className="text-xs underline">
              Fermer
            </Link>
          </div>
          {enEdition && <input type="hidden" name="reference_id" value={enEdition.id} />}
          <div className="grid grid-cols-4 gap-3">
            <Champ label="Nom de la référence *">
              <input name="reference" required defaultValue={String(enEdition?.reference ?? "")} className={CHAMP} />
            </Champ>
            <Champ label="Marque *">
              <select name="marque_id" required defaultValue={String(enEdition?.marque_id ?? "")} className={CHAMP}>
                <option value="">—</option>
                {(marques ?? []).map((m) => (
                  <option key={m.id} value={m.id}>
                    {m.libelle}
                  </option>
                ))}
              </select>
            </Champ>
            <Champ label="Repère *">
              <input name="repere" required list="reperes" defaultValue={String(enEdition?.repere ?? "")} className={CHAMP} />
            </Champ>
            <Champ label="Type d'équipement *">
              <input name="type_equipement" required list="types" defaultValue={String(enEdition?.type_equipement ?? "")} className={CHAMP} />
            </Champ>
            <Champ label="Fluide *">
              <select name="fluide_id" required defaultValue={String(enEdition?.fluide_id ?? "")} className={CHAMP}>
                <option value="">—</option>
                {(fluides ?? []).map((f) => (
                  <option key={f.id} value={f.id}>
                    {f.libelle}
                  </option>
                ))}
              </select>
            </Champ>
            <Champ label="Quantité de gaz (kg)">
              <input name="quantite_gaz" defaultValue={String(enEdition?.quantite_gaz ?? "")} className={CHAMP} />
            </Champ>
            <Champ label="Type de télécommande *">
              <input name="type_telecommande" required list="telecommandes" defaultValue={String(enEdition?.type_telecommande ?? "")} className={CHAMP} />
            </Champ>
            <Champ label="Réversible *">
              <select name="reversible" required defaultValue={String(enEdition?.reversible ?? "")} className={CHAMP}>
                <option value="">—</option>
                {REVERSIBLE_VALEURS.map((v) => (
                  <option key={v} value={v}>
                    {v}
                  </option>
                ))}
              </select>
            </Champ>
            <Champ label="Résistance électrique *">
              <select name="resistance" required defaultValue={String(enEdition?.resistance ?? "")} className={CHAMP}>
                <option value="">—</option>
                {REVERSIBLE_VALEURS.map((v) => (
                  <option key={v} value={v}>
                    {v}
                  </option>
                ))}
              </select>
            </Champ>
            <Champ label="Puissance frigorifique (W, entier)">
              <input name="puissance_frigo" type="number" step="1" defaultValue={String(enEdition?.puissance_frigo ?? "")} className={CHAMP} />
            </Champ>
            <Champ label="Puissance calorifique (W, entier)">
              <input name="puissance_calo" type="number" step="1" defaultValue={String(enEdition?.puissance_calo ?? "")} className={CHAMP} />
            </Champ>
            <Champ label="Nb filtres (roof-top)">
              <input name="nombre_filtres" defaultValue={String(enEdition?.nombre_filtres ?? "")} className={CHAMP} />
            </Champ>
            <Champ label="Dimension filtres">
              <input name="dimension_filtres" defaultValue={String(enEdition?.dimension_filtres ?? "")} className={CHAMP} />
            </Champ>
            <Champ label="Nb courroies">
              <input name="nombre_courroies" defaultValue={String(enEdition?.nombre_courroies ?? "")} className={CHAMP} />
            </Champ>
            <Champ label="Référence courroies">
              <input name="reference_courroies" defaultValue={String(enEdition?.reference_courroies ?? "")} className={CHAMP} />
            </Champ>
            <Champ label="Appoint chauffage roof-top">
              <input name="appoint_roof" defaultValue={String(enEdition?.appoint_roof ?? "")} className={CHAMP} />
            </Champ>
          </div>
          {enEdition && (
            <Case name="propager" label="Propager aux équipements existants portant cette référence (tout sauf fluide et quantité de gaz)" />
          )}
          <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
            {enEdition ? "Enregistrer" : "Ajouter la référence"}
          </button>
          <datalist id="reperes">{(reperes ?? []).map((r) => r.libelle && <option key={r.libelle} value={r.libelle} />)}</datalist>
          <datalist id="types">{(types ?? []).map((t) => <option key={t.libelle} value={t.libelle} />)}</datalist>
          <datalist id="telecommandes">{(telecommandes ?? []).map((t) => t.libelle && <option key={t.libelle} value={t.libelle} />)}</datalist>
        </form>
      )}

      {references.length === 0 ? (
        <EmptyState message="Aucune référence." />
      ) : (
        <div className="overflow-x-auto rounded-lg border">
          <table className="w-full border-collapse text-sm">
            <thead>
              <tr className="border-b bg-black/[0.02] text-left dark:bg-white/[0.03]">
                <th className="px-3 py-2">Référence</th>
                <th className="px-3 py-2">Repère</th>
                <th className="px-3 py-2">Type</th>
                <th className="px-3 py-2">Marque</th>
                <th className="px-3 py-2">Fluide</th>
                <th className="px-3 py-2 text-right">Gaz (kg)</th>
                <th className="px-3 py-2 text-right">P. frigo</th>
                <th className="px-3 py-2 text-right">P. calo</th>
                {estAdmin && <th className="px-3 py-2"></th>}
              </tr>
            </thead>
            <tbody>
              {references.map((r) => (
                <tr key={r.id} className="border-b last:border-0">
                  <td className="px-3 py-2">{r.reference}</td>
                  <td className="px-3 py-2">{r.repere ?? "—"}</td>
                  <td className="px-3 py-2">{r.type_equipement ?? "—"}</td>
                  <td className="px-3 py-2">{r.marques?.libelle ?? "—"}</td>
                  <td className="px-3 py-2">{r.types_fluide?.libelle ?? "—"}</td>
                  <td className="px-3 py-2 text-right">{r.quantite_gaz ?? "—"}</td>
                  <td className="px-3 py-2 text-right">{r.puissance_frigo ?? "—"}</td>
                  <td className="px-3 py-2 text-right">{r.puissance_calo ?? "—"}</td>
                  {estAdmin && (
                    <td className="whitespace-nowrap px-3 py-2 text-right">
                      <Link href={`/parametrage/catalogue?modifier=${r.id}`} className="text-xs underline">
                        Modifier
                      </Link>
                      <form action={supprimerReference} className="ml-2 inline">
                        <input type="hidden" name="reference_id" value={r.id} />
                        <button type="submit" className="text-xs text-red-700 underline">
                          Supprimer
                        </button>
                      </form>
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
