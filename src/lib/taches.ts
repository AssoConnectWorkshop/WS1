/** Kanbans de l'application : « À faire » (projet, points à discuter) et « Todo tech » (tâches de développement). */
export const TABLEAUX = {
  projet: {
    label: "À faire",
    href: "/taches",
    colonnes: [
      { key: "backlog", label: "Backlog" },
      { key: "next", label: "Next" },
      { key: "in_progress", label: "In progress" },
      { key: "to_validate", label: "To validate" },
      { key: "suspended", label: "Suspended" },
      { key: "done", label: "Done" },
    ],
  },
  tech: {
    label: "Todo tech",
    href: "/taches/tech",
    colonnes: [
      { key: "todo", label: "Todo" },
      { key: "doing", label: "Doing" },
      { key: "done", label: "Done" },
    ],
  },
} as const;

export type Tableau = keyof typeof TABLEAUX;
export type ColonneDef = { key: string; label: string };
export type Colonne = (typeof TABLEAUX)[Tableau]["colonnes"][number]["key"];

export const estTableau = (v: unknown): v is Tableau => typeof v === "string" && v in TABLEAUX;
export const colonnesDe = (tableau: Tableau): readonly ColonneDef[] => TABLEAUX[tableau].colonnes;
export const estColonneDe = (tableau: Tableau, v: unknown): v is Colonne => typeof v === "string" && TABLEAUX[tableau].colonnes.some((c) => c.key === v);
