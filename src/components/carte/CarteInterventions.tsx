"use client";

import { Circle, CircleMarker, MapContainer, Popup, TileLayer } from "react-leaflet";
import "leaflet/dist/leaflet.css";

export type PointCarte = {
  id: number;
  latitude: number;
  longitude: number;
  type_code: number | null;
  type_libelle: string | null;
  statut_code: number | null;
  statut_libelle: string | null;
  client_nom: string | null;
  site_nom: string | null;
  adresse: string | null;
  date_demande: string | null;
  date_limite: string | null;
  date_prevue: string | null;
  date_realisee: string | null;
  intervenant_nom: string | null;
  charge_affaire_nom: string | null;
  commentaire_interne: string | null;
  depassee: boolean;
};

/** Couleurs Form_Carte : 1 bleu, 2 vert, 3 rouge, 5 orange (cône), 7 jaune, 9 noir, autres marron ; statut -1 jaune. */
export function couleurType(type: number | null, statut: number | null) {
  if (statut === -1) return "#facc15";
  switch (type) {
    case 1:
      return "#2563eb";
    case 2:
      return "#16a34a";
    case 3:
      return "#dc2626";
    case 5:
      return "#f97316";
    case 7:
      return "#facc15";
    case 9:
      return "#111111";
    default:
      return "#92400e";
  }
}

const date = (v: string | null) => (v ? new Date(v).toLocaleDateString("fr-FR") : "—");

export function CarteInterventions({ points }: { points: PointCarte[] }) {
  const centre: [number, number] = points.length
    ? [points.reduce((s, p) => s + p.latitude, 0) / points.length, points.reduce((s, p) => s + p.longitude, 0) / points.length]
    : [46.6, 2.4];

  return (
    <MapContainer center={centre} zoom={points.length ? 7 : 6} className="h-[70vh] w-full rounded-xl border" scrollWheelZoom>
      <TileLayer attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>' url="https://tile.openstreetmap.org/{z}/{x}/{y}.png" />
      {points.map((p) => (
        <span key={p.id}>
          {p.depassee && <Circle center={[p.latitude, p.longitude]} radius={500} pathOptions={{ color: "#f97316", weight: 1, fillOpacity: 0.1 }} />}
          <CircleMarker
            center={[p.latitude, p.longitude]}
            radius={7}
            pathOptions={{ color: "#ffffff", weight: 1, fillColor: couleurType(p.type_code, p.statut_code), fillOpacity: 0.9 }}
          >
            <Popup>
              <div className="text-xs leading-5">
                <div className="font-semibold">
                  {p.type_libelle ?? "Intervention"} · {p.statut_libelle ?? ""}
                </div>
                <div>
                  {p.client_nom} – {p.site_nom}
                </div>
                <div>{p.adresse}</div>
                <div>Demande : {date(p.date_demande)} · Limite : {date(p.date_limite)}</div>
                <div>Prévue : {date(p.date_prevue)} · Réalisée : {date(p.date_realisee)}</div>
                <div>Intervenant : {p.intervenant_nom ?? "—"} · Chargé d&apos;affaire : {p.charge_affaire_nom ?? "—"}</div>
                {p.commentaire_interne && <div className="italic">{p.commentaire_interne}</div>}
                <a href={`/interventions/${p.id}`} className="underline">
                  Ouvrir l&apos;intervention
                </a>
              </div>
            </Popup>
          </CircleMarker>
        </span>
      ))}
    </MapContainer>
  );
}
