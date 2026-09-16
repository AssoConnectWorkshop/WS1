import { createClient } from "@/lib/supabase/server";
import { toStringParams } from "@/lib/list-params";
import { Champ, CHAMP } from "@/components/ui/Champ";
import { creerSite } from "../actions";

export const dynamic = "force-dynamic";

export default async function NouveauSitePage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();
  const clientId = sp.client ? Number(sp.client) : null;

  const [{ data: client }, { data: clients }, { data: zones }, { data: intervenants }, { data: donneurs }] = await Promise.all([
    clientId ? supabase.from("clients").select("id, nom").eq("id", clientId).maybeSingle() : Promise.resolve({ data: null }),
    clientId ? Promise.resolve({ data: [] }) : supabase.from("clients").select("id, nom").eq("actif", true).eq("est_client_fermeture", false).order("nom"),
    supabase.from("zones_geographiques").select("id, libelle").order("libelle"),
    supabase.from("intervenants").select("id, nom").order("nom"),
    supabase.from("donneurs_ordre").select("id, nom").eq("actif", true).order("nom"),
  ]);

  return (
    <div className="mx-auto flex max-w-2xl flex-col gap-4 p-8">
      <h1 className="text-2xl font-bold">Nouveau site</h1>
      {sp.erreur && <p className="rounded-md bg-red-50 p-3 text-sm text-red-700">{sp.erreur}</p>}

      <form action={creerSite} className="flex flex-col gap-4 rounded-xl border p-6">
        <Champ label="Client *">
          {client ? (
            <>
              <input type="hidden" name="client_id" value={client.id} />
              <div className="rounded-md border bg-black/[0.02] px-3 py-2 dark:bg-white/[0.03]">{client.nom}</div>
            </>
          ) : (
            <select name="client_id" required className={CHAMP}>
              <option value="">— Choisir —</option>
              {(clients ?? []).map((c) => (
                <option key={c.id} value={c.id}>
                  {c.nom}
                </option>
              ))}
            </select>
          )}
        </Champ>
        <div className="grid grid-cols-[1fr_8rem_8rem] gap-3">
          <Champ label="Nom du site *">
            <input name="nom" required className={CHAMP} />
          </Champ>
          <Champ label="N° de magasin">
            <input name="numero_magasin" type="number" className={CHAMP} />
          </Champ>
          <Champ label="Code">
            <input name="code_client" className={CHAMP} />
          </Champ>
        </div>
        <Champ label="Adresse">
          <input name="adresse" className={CHAMP} />
        </Champ>
        <div className="grid grid-cols-3 gap-3">
          <Champ label="Code postal">
            <input name="code_postal" className={CHAMP} />
          </Champ>
          <Champ label="Ville">
            <input name="ville" className={CHAMP} />
          </Champ>
          <Champ label="Téléphone">
            <input name="telephone" className={CHAMP} />
          </Champ>
        </div>
        <div className="grid grid-cols-3 gap-3">
          <Champ label="Zone d'intervention">
            <select name="zone_id" className={CHAMP}>
              <option value="">—</option>
              {(zones ?? []).map((z) => (
                <option key={z.id} value={z.id}>
                  {z.libelle}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="Intervenant clim">
            <select name="intervenant_id" className={CHAMP}>
              <option value="">—</option>
              {(intervenants ?? []).map((i) => (
                <option key={i.id} value={i.id}>
                  {i.nom}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="Donneur d'ordre">
            <select name="donneur_ordre_id" className={CHAMP}>
              <option value="">—</option>
              {(donneurs ?? []).map((d) => (
                <option key={d.id} value={d.id}>
                  {d.nom}
                </option>
              ))}
            </select>
          </Champ>
        </div>
        <p className="text-xs opacity-60">Horaires par défaut, contrats et matériel se complètent ensuite sur la fiche.</p>
        <button type="submit" className="rounded-md bg-black py-2 font-medium text-white">
          Créer
        </button>
      </form>
    </div>
  );
}
