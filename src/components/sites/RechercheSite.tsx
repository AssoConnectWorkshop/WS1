import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { CHAMP } from "@/components/ui/Champ";

/** Recherche d'un site par nom ou numéro de magasin (règle Form_Client.lstClient), pour les écrans de création. */
export async function RechercheSite({ recherche, hrefSite, hidden = {} }: { recherche?: string; hrefSite: (id: number) => string; hidden?: Record<string, string> }) {
  const terme = recherche?.trim() ?? "";
  let sites: { id: number; nom: string | null; ville: string | null }[] = [];
  if (terme) {
    const supabase = await createClient();
    let q = supabase.from("sites").select("id, nom, ville").is("supprime_le", null).order("nom").limit(20);
    q = Number.isFinite(Number(terme)) ? q.or(`numero_magasin.eq.${Number(terme)},nom.ilike.%${terme}%`) : q.ilike("nom", `%${terme}%`);
    sites = (await q).data ?? [];
  }

  return (
    <div className="flex flex-col gap-2">
      <form method="GET" className="flex items-end gap-2 rounded-lg border p-3 text-sm">
        {Object.entries(hidden).map(([name, value]) => (
          <input key={name} type="hidden" name={name} value={value} />
        ))}
        <label className="flex flex-col gap-1">
          <span className="text-xs opacity-60">Rechercher un site (nom ou numéro de magasin)</span>
          <input name="recherche" defaultValue={recherche} className={CHAMP} />
        </label>
        <button type="submit" className="rounded-md bg-black px-3 py-2 text-white">
          Rechercher
        </button>
      </form>
      {terme && sites.length === 0 && <p className="text-sm opacity-60">Aucun site trouvé.</p>}
      {sites.length > 0 && (
        <ul className="flex flex-col gap-1 text-sm">
          {sites.map((s) => (
            <li key={s.id}>
              <Link href={hrefSite(s.id)} className="underline">
                {s.nom} ({s.ville})
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
