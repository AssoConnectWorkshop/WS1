"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { TABLEAUX, colonnesDe, type Tableau } from "@/lib/taches";

type Colonne = string;
import { creerTache, deposerTache, modifierTache, supprimerTache } from "@/app/(app)/taches/actions";

export type Tache = { id: number; titre: string; description: string | null; colonne: Colonne; ordre: number; created_at: string; updated_at: string };

const COULEUR: Record<string, string> = {
  backlog: "bg-gray-400",
  next: "bg-blue-500",
  in_progress: "bg-amber-500",
  to_validate: "bg-purple-500",
  suspended: "bg-red-400",
  done: "bg-green-500",
  todo: "bg-gray-400",
  doing: "bg-amber-500",
};

const date = (v: string) => new Date(v).toLocaleDateString("fr-FR", { day: "2-digit", month: "short", year: "numeric" });

/** Kanban « À faire » : glisser-déposer natif HTML5, panneau de détail façon Notion (titre en grand, propriétés, description). */
export function Kanban({ taches: initiales, tableau }: { taches: Tache[]; tableau: Tableau }) {
  const router = useRouter();
  const COLONNES = colonnesDe(tableau);
  const config = TABLEAUX[tableau];
  const [taches, setTaches] = useState(initiales);
  const [glissee, setGlissee] = useState<number | null>(null);
  const [survol, setSurvol] = useState<Colonne | null>(null);
  const [ouverte, setOuverte] = useState<Tache | null | "nouvelle">(null);
  const [colonneNouvelle, setColonneNouvelle] = useState<Colonne>(COLONNES[0].key);
  const [, lancer] = useTransition();

  const deposer = (colonne: Colonne) => {
    if (glissee == null) return;
    const tache = taches.find((t) => t.id === glissee);
    if (!tache || tache.colonne === colonne) {
      setGlissee(null);
      setSurvol(null);
      return;
    }
    const ordre = Math.max(0, ...taches.filter((t) => t.colonne === colonne).map((t) => t.ordre)) + 1;
    setTaches((liste) => liste.map((t) => (t.id === glissee ? { ...t, colonne, ordre } : t)));
    setGlissee(null);
    setSurvol(null);
    lancer(async () => {
      const r = await deposerTache(tache.id, tableau, colonne, ordre);
      if (!r.ok) setTaches(initiales);
      router.refresh();
    });
  };

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <div className="flex items-center gap-3">
          <h1 className="text-xl font-bold">{config.label}</h1>
          <nav className="flex gap-1 text-xs">
            {(Object.keys(TABLEAUX) as Tableau[]).map((t) => (
              <a key={t} href={TABLEAUX[t].href} className={`rounded px-2 py-0.5 ${t === tableau ? "bg-black text-white dark:bg-white dark:text-black" : "border"}`}>
                {TABLEAUX[t].label}
              </a>
            ))}
          </nav>
        </div>
        <button
          type="button"
          onClick={() => {
            setColonneNouvelle(COLONNES[0].key);
            setOuverte("nouvelle");
          }}
          className="rounded border bg-white px-2 py-1 text-xs dark:bg-white/5"
        >
          + Nouvelle carte
        </button>
      </div>

      <div className={`grid gap-2 ${COLONNES.length > 3 ? "lg:grid-cols-6" : "lg:grid-cols-3"}`}>
        {COLONNES.map((colonne) => {
          const cartes = taches.filter((t) => t.colonne === colonne.key).sort((a, b) => a.ordre - b.ordre || a.id - b.id);
          return (
            <section
              key={colonne.key}
              onDragOver={(e) => {
                e.preventDefault();
                if (survol !== colonne.key) setSurvol(colonne.key);
              }}
              onDragLeave={() => setSurvol((s) => (s === colonne.key ? null : s))}
              onDrop={(e) => {
                e.preventDefault();
                deposer(colonne.key);
              }}
              className={`flex min-h-48 flex-col gap-2 rounded-lg border p-2 transition-colors ${survol === colonne.key ? "border-blue-400 bg-blue-50 dark:bg-blue-950/30" : "bg-black/[0.02] dark:bg-white/[0.03]"}`}
            >
              <header className="flex items-center justify-between text-xs font-semibold">
                <span className="flex items-center gap-1.5">
                  <span className={`inline-block h-2.5 w-2.5 rounded-full ${COULEUR[colonne.key]}`} />
                  {colonne.label} <span className="opacity-50">{cartes.length}</span>
                </span>
                <button
                  type="button"
                  onClick={() => {
                    setColonneNouvelle(colonne.key);
                    setOuverte("nouvelle");
                  }}
                  className="rounded px-1 opacity-50 hover:bg-black/10 hover:opacity-100"
                  title="Ajouter ici"
                >
                  +
                </button>
              </header>
              {cartes.map((t) => (
                <article
                  key={t.id}
                  draggable
                  onDragStart={() => setGlissee(t.id)}
                  onDragEnd={() => {
                    setGlissee(null);
                    setSurvol(null);
                  }}
                  onClick={() => setOuverte(t)}
                  className={`cursor-grab rounded-md border bg-white p-2 text-xs shadow-sm transition hover:shadow-md dark:bg-white/5 active:cursor-grabbing ${glissee === t.id ? "opacity-40" : ""} ${colonne.key === "done" ? "opacity-70" : ""}`}
                >
                  <div className="font-medium leading-snug">{t.titre}</div>
                  {t.description && <p className="mt-1 line-clamp-2 text-[11px] opacity-60">{t.description}</p>}
                  <div className="mt-1.5 text-[10px] opacity-50">{date(t.updated_at)}</div>
                </article>
              ))}
            </section>
          );
        })}
      </div>

      {ouverte && (
        <div className="fixed inset-0 z-40 flex justify-end bg-black/30" onClick={() => setOuverte(null)}>
          <aside className="flex h-full w-full max-w-xl flex-col gap-4 overflow-y-auto bg-white p-6 shadow-2xl dark:bg-neutral-900" onClick={(e) => e.stopPropagation()}>
            <form action={ouverte === "nouvelle" ? creerTache : modifierTache} className="flex flex-col gap-4">
              {ouverte !== "nouvelle" && <input type="hidden" name="tache_id" value={ouverte.id} />}
              <input type="hidden" name="tableau" value={tableau} />
              <div className="flex items-start justify-between gap-2">
                <input
                  name="titre"
                  required
                  autoFocus
                  placeholder="Sans titre"
                  defaultValue={ouverte === "nouvelle" ? "" : ouverte.titre}
                  className="w-full border-0 bg-transparent text-2xl font-bold outline-none placeholder:opacity-40"
                />
                <button type="button" onClick={() => setOuverte(null)} className="rounded px-2 py-1 text-sm opacity-60 hover:bg-black/5 hover:opacity-100" title="Fermer">
                  ✕
                </button>
              </div>

              <dl className="grid grid-cols-[8rem_1fr] items-center gap-y-2 text-sm">
                <dt className="opacity-60">Colonne</dt>
                <dd>
                  <select name="colonne" defaultValue={ouverte === "nouvelle" ? colonneNouvelle : ouverte.colonne} className="rounded border bg-white px-2 py-1 text-sm dark:bg-white/5">
                    {COLONNES.map((c) => (
                      <option key={c.key} value={c.key}>
                        {c.label}
                      </option>
                    ))}
                  </select>
                </dd>
                {ouverte !== "nouvelle" && (
                  <>
                    <dt className="opacity-60">Créée le</dt>
                    <dd>{date(ouverte.created_at)}</dd>
                    <dt className="opacity-60">Modifiée le</dt>
                    <dd>{date(ouverte.updated_at)}</dd>
                  </>
                )}
              </dl>

              <hr />

              <textarea
                name="description"
                rows={14}
                placeholder="Décrire le point, les options, ce qu'il faut décider…"
                defaultValue={ouverte === "nouvelle" ? "" : ouverte.description ?? ""}
                className="w-full resize-y rounded border-0 bg-transparent text-sm leading-6 outline-none placeholder:opacity-40"
              />

              <div className="flex items-center justify-between gap-2 pt-2">
                <button type="submit" className="rounded bg-black px-4 py-1.5 text-sm text-white">
                  {ouverte === "nouvelle" ? "Créer" : "Enregistrer"}
                </button>
                {ouverte !== "nouvelle" && (
                  <button type="submit" formAction={supprimerTache} className="text-sm text-red-700 hover:underline" onClick={(e) => !confirm("Supprimer cette carte ?") && e.preventDefault()}>
                    Supprimer
                  </button>
                )}
              </div>
            </form>
          </aside>
        </div>
      )}
    </div>
  );
}
