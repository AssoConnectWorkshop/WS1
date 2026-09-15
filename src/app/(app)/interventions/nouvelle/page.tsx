import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { toStringParams } from "@/lib/list-params";
import { creerIntervention } from "../actions";

export const dynamic = "force-dynamic";

export default async function NouvelleInterventionPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();

  const siteId = sp.site;
  const [{ data: types }, { data: site }] = await Promise.all([
    supabase.from("types_intervention").select("code, libelle").order("ordre_affichage"),
    siteId ? supabase.from("sites").select("id, nom, ville, client_id").eq("id", siteId).maybeSingle() : Promise.resolve({ data: null }),
  ]);

  let sitesTrouves: { id: number; nom: string; ville: string | null }[] = [];
  if (!site && sp.recherche) {
    const n = Number(sp.recherche);
    let q = supabase.from("sites").select("id, nom, ville").limit(20);
    q = Number.isFinite(n) && sp.recherche.trim() !== "" ? q.or(`numero_magasin.eq.${n},nom.ilike.%${sp.recherche}%`) : q.ilike("nom", `%${sp.recherche}%`);
    const { data } = await q;
    sitesTrouves = data ?? [];
  }

  const { data: contacts } = site ? await supabase.from("contacts").select("id, nom, prenom").eq("client_id", site.client_id) : { data: [] };

  return (
    <div className="mx-auto flex max-w-2xl flex-col gap-4 p-8">
      <h1 className="text-2xl font-bold">Nouvelle intervention</h1>

      {sp.erreur && <p className="rounded-md bg-red-50 p-3 text-sm text-red-700">{sp.erreur}</p>}

      {!site && (
        <form method="GET" className="flex items-end gap-2 rounded-lg border p-3 text-sm">
          <label className="flex flex-col gap-1">
            <span className="text-xs opacity-60">Rechercher un site (nom ou numéro)</span>
            <input name="recherche" defaultValue={sp.recherche} className="rounded-md border px-3 py-2" />
          </label>
          <button type="submit" className="rounded-md bg-black px-3 py-2 text-white">
            Rechercher
          </button>
        </form>
      )}

      {!site && sitesTrouves.length > 0 && (
        <ul className="flex flex-col gap-1 text-sm">
          {sitesTrouves.map((s) => (
            <li key={s.id}>
              <Link href={`/interventions/nouvelle?site=${s.id}`} className="underline">
                {s.nom} ({s.ville})
              </Link>
            </li>
          ))}
        </ul>
      )}

      <form action={creerIntervention} className="flex flex-col gap-4 rounded-xl border p-6">
        <label className="flex flex-col gap-1 text-sm">
          Site *
          {site ? (
            <>
              <input type="hidden" name="site_id" value={site.id} />
              <div className="rounded-md border bg-black/[0.02] px-3 py-2 dark:bg-white/[0.03]">
                {site.nom} ({site.ville})
              </div>
            </>
          ) : (
            <div className="rounded-md border border-dashed px-3 py-2 text-xs opacity-60">
              Recherchez et sélectionnez un site ci-dessus.
            </div>
          )}
        </label>

        <label className="flex flex-col gap-1 text-sm">
          Type *
          <select name="type_code" required className="rounded-md border px-3 py-2">
            <option value="">— Choisir —</option>
            {(types ?? []).map((t) => (
              <option key={t.code} value={t.code}>
                {t.libelle}
              </option>
            ))}
          </select>
        </label>

        <label className="flex flex-col gap-1 text-sm">
          Objet *
          <input name="objet" required className="rounded-md border px-3 py-2" />
        </label>

        {contacts && contacts.length > 0 && (
          <label className="flex flex-col gap-1 text-sm">
            Contact
            <select name="contact_id" className="rounded-md border px-3 py-2">
              <option value="">—</option>
              {contacts.map((c) => (
                <option key={c.id} value={c.id}>
                  {[c.prenom, c.nom].filter(Boolean).join(" ")}
                </option>
              ))}
            </select>
          </label>
        )}

        <label className="flex flex-col gap-1 text-sm">
          N° de DI client
          <input name="reference_client" className="rounded-md border px-3 py-2" />
        </label>

        <label className="flex flex-col gap-1 text-sm">
          Date limite
          <input name="date_limite" type="date" className="rounded-md border px-3 py-2" />
          <span className="text-xs opacity-60">
            Recommandée mais non bloquante : un avertissement s&apos;affichera si elle est vide.
          </span>
        </label>

        <label className="flex flex-col gap-1 text-sm">
          Directives
          <textarea name="directives" className="rounded-md border px-3 py-2" rows={3} />
        </label>

        <button type="submit" className="rounded-md bg-black py-2 font-medium text-white">
          Créer
        </button>
      </form>
    </div>
  );
}
