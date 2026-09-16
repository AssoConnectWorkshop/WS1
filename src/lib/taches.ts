/** Colonnes du kanban « À faire », dans l'ordre d'affichage. */
export const COLONNES = [
  { key: "backlog", label: "Backlog" },
  { key: "next", label: "Next" },
  { key: "in_progress", label: "In progress" },
  { key: "to_validate", label: "To validate" },
  { key: "suspended", label: "Suspended" },
  { key: "done", label: "Done" },
] as const;

export type Colonne = (typeof COLONNES)[number]["key"];
