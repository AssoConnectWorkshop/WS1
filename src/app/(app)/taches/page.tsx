import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Messages } from "@/components/ui/Messages";
import { toStringParams } from "@/lib/list-params";
import { formatDate } from "@/lib/format";
import { COLONNES, type Colonne } from "@/lib/taches";
import { creerTache, deplacerTache, modifierTache, supprimerTache } from "./actions";

export const dynamic = "force-dynamic";

type Tache = { id: number; titre: string; description: string | null; colonne: Colonne; ordre: number; updated_at: string };

const CHAMP = "w-full rounded border bg-white px-1.5 py-0.5 text-xs dark:bg-white/5";
const BOUTON = "rounded border bg-white px-1.5 py-0.5 text-[11px] dark:bg-white/5";

/** Kanban projet : choses à faire ou à discuter (backlog → done). */
export default async function TachesPage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();
  const { data, error } = await supabase.from("taches").select("id, titre, description, colonne, ordre, updated_at").order("ordre").order("id");
  const taches = (data ?? []) as Tache[];
  const enEdition = sp.modifier ? taches.find((t) => String(t.id) === sp.modifier) : undefined;

  return (
    <div className="flex flex-col gap-3 p-4">
      <Messages sp={sp} />
      <div className="flex flex-wrap items-center justify-between gap-2">
        <h1 className="text-xl font-bold">À faire</h1>
        <Link href={enEdition || sp.ajouter ? "/taches" : "/taches?ajouter=1"} className={BOUTON}>
          {enEdition || sp.ajouter ? "Fermer le formulaire" : "Ajouter une carte"}
        </Link>
      </div>
      {error && <div className="rounded border border-red-300 bg-red-50 p-3 text-sm text-red-800">Erreur : {error.message}</div>}

      {(sp.ajouter === "1" || enEdition) && (
        <form action={enEdition ? modifierTache : creerTache} className="grid gap-2 rounded border p-3 text-xs lg:grid-cols-[1fr_2fr_10rem_auto]">
          {enEdition && <input type="hidden" name="tache_id" value={enEdition.id} />}
          <label className="flex flex-col gap-0.5">
            Titre
            <input name="titre" required defaultValue={enEdition?.titre ?? ""} className={CHAMP} />
          </label>
          <label className="flex flex-col gap-0.5">
            Description / points à discuter
            <textarea name="description" rows={3} defaultValue={enEdition?.description ?? ""} className={CHAMP} />
          </label>
          <label className="flex flex-col gap-0.5">
            Colonne
            <select name="colonne" defaultValue={enEdition?.colonne ?? sp.colonne ?? "backlog"} className={CHAMP}>
              {COLONNES.map((c) => (
                <option key={c.key} value={c.key}>
                  {c.label}
                </option>
              ))}
            </select>
          </label>
          <button type="submit" className="self-end rounded bg-black px-3 py-1 text-white">
            {enEdition ? "Enregistrer" : "Ajouter"}
          </button>
        </form>
      )}

      <div className="grid gap-2 lg:grid-cols-6">
        {COLONNES.map((colonne, index) => {
          const cartes = taches.filter((t) => t.colonne === colonne.key);
          const precedente = COLONNES[index - 1]?.key;
          const suivante = COLONNES[index + 1]?.key;
          return (
            <section key={colonne.key} className="flex min-h-40 flex-col gap-2 rounded border bg-black/[0.02] p-2 dark:bg-white/[0.03]">
              <header className="flex items-center justify-between text-xs font-semibold">
                <span>
                  {colonne.label} <span className="opacity-60">({cartes.length})</span>
                </span>
                <Link href={`/taches?ajouter=1&colonne=${colonne.key}`} className="opacity-60 hover:opacity-100" title="Ajouter ici">
                  +
                </Link>
              </header>
              {cartes.map((t) => (
                <article key={t.id} className={`flex flex-col gap-1 rounded border bg-white p-2 text-xs shadow-sm dark:bg-white/5 ${colonne.key === "done" ? "opacity-70" : ""}`}>
                  <div className="font-semibold">{t.titre}</div>
                  {t.description && (
                    <details>
                      <summary className="cursor-pointer opacity-70">Détail</summary>
                      <p className="whitespace-pre-line pt-1">{t.description}</p>
                    </details>
                  )}
                  <div className="flex items-center justify-between gap-1 pt-1 text-[10px] opacity-70">
                    <span>{formatDate(t.updated_at)}</span>
                    <span className="flex items-center gap-1">
                      {precedente && (
                        <form action={deplacerTache}>
                          <input type="hidden" name="tache_id" value={t.id} />
                          <input type="hidden" name="colonne" value={precedente} />
                          <button type="submit" className={BOUTON} title={`Vers ${COLONNES[index - 1].label}`}>
                            ←
                          </button>
                        </form>
                      )}
                      {suivante && (
                        <form action={deplacerTache}>
                          <input type="hidden" name="tache_id" value={t.id} />
                          <input type="hidden" name="colonne" value={suivante} />
                          <button type="submit" className={BOUTON} title={`Vers ${COLONNES[index + 1].label}`}>
                            →
                          </button>
                        </form>
                      )}
                      <Link href={`/taches?modifier=${t.id}`} className={BOUTON} title="Modifier">
                        ✎
                      </Link>
                      <form action={supprimerTache}>
                        <input type="hidden" name="tache_id" value={t.id} />
                        <button type="submit" className={`${BOUTON} text-red-700`} title="Supprimer">
                          ✕
                        </button>
                      </form>
                    </span>
                  </div>
                </article>
              ))}
            </section>
          );
        })}
      </div>
    </div>
  );
}
