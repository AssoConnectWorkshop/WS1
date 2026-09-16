"use client";

import { useState, useTransition } from "react";
import { basculerCase, type CaseEditable } from "@/app/(app)/actions-cases";

/** Case à cocher de feuille de données : enregistre au clic, sans bouton (comme Access). */
export function CaseInstantanee({ table, id, champ, valeur, label }: CaseEditable & { valeur: boolean | null | undefined; label: string }) {
  const [coche, setCoche] = useState(!!valeur);
  const [enCours, lancer] = useTransition();
  return (
    <input
      type="checkbox"
      checked={coche}
      disabled={enCours}
      aria-label={label}
      title={label}
      onChange={(e) => {
        const nouvelle = e.target.checked;
        setCoche(nouvelle);
        lancer(async () => {
          const r = await basculerCase({ table, id, champ }, nouvelle);
          if (!r.ok) setCoche(!nouvelle);
        });
      }}
    />
  );
}
