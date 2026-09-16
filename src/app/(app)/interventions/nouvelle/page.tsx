import { formatNom } from "@/lib/format";
import { Champ, CHAMP } from "@/components/ui/Champ";
import { Messages } from "@/components/ui/Messages";
import { RechercheSite } from "@/components/sites/RechercheSite";
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

  const { data: contacts } = site ? await supabase.from("contacts").select("id, nom, prenom").eq("client_id", site.client_id) : { data: [] };

  return (
    <div className="mx-auto flex max-w-2xl flex-col gap-4 p-8">
      <h1 className="text-2xl font-bold">Nouvelle intervention</h1>

      <Messages sp={sp} />

      {!site && <RechercheSite recherche={sp.recherche} hrefSite={(id) => `/interventions/nouvelle?site=${id}`} />}

      <form action={creerIntervention} className="flex flex-col gap-4 rounded-xl border p-6">
        <Champ label="Site *">
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
        </Champ>

        <Champ label="Type *">
          <select name="type_code" required className={CHAMP}>
            <option value="">— Choisir —</option>
            {(types ?? []).map((t) => (
              <option key={t.code} value={t.code}>
                {t.libelle}
              </option>
            ))}
          </select>
        </Champ>

        <Champ label="Objet *">
          <input name="objet" required className={CHAMP} />
        </Champ>

        {contacts && contacts.length > 0 && (
          <Champ label="Contact">
            <select name="contact_id" className={CHAMP}>
              <option value="">—</option>
              {contacts.map((c) => (
                <option key={c.id} value={c.id}>
                  {formatNom(c.prenom, c.nom)}
                </option>
              ))}
            </select>
          </Champ>
        )}

        <Champ label="N° de DI client">
          <input name="reference_client" className={CHAMP} />
        </Champ>

        <Champ label="Date limite">
          <input name="date_limite" type="date" className={CHAMP} />
          <span className="text-xs opacity-60">
            Recommandée mais non bloquante : un avertissement s&apos;affichera si elle est vide.
          </span>
        </Champ>

        <Champ label="Directives">
          <textarea name="directives" className={CHAMP} rows={3} />
        </Champ>

        <button type="submit" className="rounded-md bg-black py-2 font-medium text-white">
          Créer
        </button>
      </form>
    </div>
  );
}
