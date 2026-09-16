"use client";

import dynamic from "next/dynamic";
import type { PointCarte } from "./CarteInterventions";

// Leaflet touche `window` à l'import : rendu côté navigateur uniquement.
const Carte = dynamic(() => import("./CarteInterventions").then((m) => m.CarteInterventions), {
  ssr: false,
  loading: () => <div className="flex h-[70vh] items-center justify-center rounded-xl border text-sm opacity-60">Chargement de la carte…</div>,
});

export function CarteClient({ points }: { points: PointCarte[] }) {
  return <Carte points={points} />;
}
