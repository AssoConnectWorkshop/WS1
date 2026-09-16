"use client";

import dynamic from "next/dynamic";
import type { PointCarte } from "./CarteInterventions";

// Leaflet touche `window` à l'import : rendu côté navigateur uniquement.
const Carte = dynamic(() => import("./CarteInterventions").then((m) => m.CarteInterventions), {
  ssr: false,
  loading: () => <div className="flex h-[calc(100vh-11rem)] min-h-[28rem] items-center justify-center border text-sm opacity-60">Chargement de la carte…</div>,
});

export function CarteClient({ points }: { points: PointCarte[] }) {
  return <Carte points={points} />;
}
