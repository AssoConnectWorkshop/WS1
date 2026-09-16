"use client";

import L from "leaflet";
import Link from "next/link";
import { LayersControl, MapContainer, Marker, Popup, TileLayer } from "react-leaflet";
import "leaflet/dist/leaflet.css";

export type PointCarte = {
  id: number;
  site_id: number;
  latitude: number;
  longitude: number;
  type_code: number | null;
  type_libelle: string | null;
  statut_code: number | null;
  statut_libelle: string | null;
  client_nom: string | null;
  site_nom: string | null;
  adresse: string | null;
  code_postal: string | null;
  ville: string | null;
  zone_libelle: string | null;
  intervenant_nom: string | null;
  technicien_prevu_nom: string | null;
  date_limite: string | null;
  date_prevue: string | null;
  date_derniere_visite: string | null;
  commentaire_site: string | null;
  commentaire_intervention: string | null;
  depassee: boolean;
};

/** Couleurs des épingles du module carte : 1 bleu, 2 vert, 3 et 12 rouge, 5 orange (cône), 7 gris, 9 noir, 13 violet, autres marron ; statut -1 jaune, 2 ambre. */
export function couleurType(type: number | null, statut: number | null) {
  if (statut === -1) return "#eab308";
  if (statut === 2) return "#f59e0b";
  switch (type) {
    case 1:
      return "#2563eb";
    case 2:
      return "#16a34a";
    case 3:
    case 12:
      return "#dc2626";
    case 5:
      return "#f97316";
    case 7:
      return "#6b7280";
    case 9:
      return "#111111";
    case 13:
      return "#7c3aed";
    default:
      return "#92400e";
  }
}

/** Épingle SVG colorée (forme des marqueurs Leaflet d'Access), avec le nombre d'interventions du site si > 1. */
export function svgEpingle(couleur: string, nombre?: number) {
  const texte = nombre && nombre > 1 ? `<text x="12" y="13" text-anchor="middle" font-size="11" font-weight="bold" fill="#fff" font-family="sans-serif">${nombre}</text>` : `<circle cx="12" cy="9" r="3.5" fill="#fff"/>`;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="34" viewBox="0 0 24 34"><path d="M12 33 C12 33 2 19 2 11 A10 10 0 0 1 22 11 C22 19 12 33 12 33 Z" fill="${couleur}" stroke="#333" stroke-width="1"/>${texte}</svg>`;
}

function icone(couleur: string, nombre: number, depassee: boolean) {
  return L.divIcon({
    html: `<div style="position:relative;width:24px;height:34px">${depassee ? '<div style="position:absolute;left:-6px;top:-4px;width:36px;height:36px;border-radius:50%;background:rgba(249,115,22,.35)"></div>' : ""}${svgEpingle(couleur, nombre)}</div>`,
    className: "",
    iconSize: [24, 34],
    iconAnchor: [12, 33],
    popupAnchor: [0, -30],
  });
}

const date = (v: string | null) => (v ? new Date(v).toLocaleDateString("fr-FR") : "");

function copier(texte: string) {
  if (typeof navigator !== "undefined" && navigator.clipboard) void navigator.clipboard.writeText(texte);
}

function FicheIntervention({ p }: { p: PointCarte }) {
  const titre = `${p.type_libelle ?? "INTERVENTION"} - ${p.site_nom ?? ""} - ${p.ville ?? ""}`;
  const texte = [
    titre,
    [p.adresse, p.code_postal, p.ville].filter(Boolean).join(" "),
    `Intervenant : ${p.intervenant_nom ?? ""}`,
    `Date limite : ${date(p.date_limite)}`,
    `Tech. prévu : ${p.technicien_prevu_nom ?? ""}`,
    `Date prévue : ${date(p.date_prevue)}`,
    p.commentaire_intervention ?? "",
  ].join("\n");

  return (
    <div className="flex flex-col gap-1 text-xs leading-4">
      <div className="text-[11px] font-bold uppercase">{p.type_libelle ?? "Intervention"}</div>
      <Link href={`/sites/${p.site_id}`} className="font-bold text-blue-700 no-underline">
        {p.site_nom}
      </Link>
      <div>{p.adresse}</div>
      <div>
        {p.code_postal} {p.ville}
      </div>
      <div>{p.zone_libelle}</div>
      <div>Intervenant : {p.intervenant_nom ?? ""}</div>
      <hr className="my-1" />
      <div>
        Date limite : <b>{date(p.date_limite)}</b>
      </div>
      <div>
        Dernière visite de maintenance le : <b>{date(p.date_derniere_visite)}</b>
      </div>
      <div className="mt-1">Tech. prévu : {p.technicien_prevu_nom ?? ""}</div>
      <div>Date prévue : {date(p.date_prevue)}</div>
      <hr className="my-1" />
      <div className="font-bold underline">Commentaire général Site</div>
      <div className="whitespace-pre-line">{p.commentaire_site ?? ""}</div>
      <div className="mt-1 font-bold underline">Commentaire Intervention à réaliser</div>
      <div className="whitespace-pre-line">{p.commentaire_intervention ?? ""}</div>
      <hr className="my-1" />
      <Link href={`/sites/${p.site_id}?onglet=sav`} className="text-blue-700">
        Devis Encours
      </Link>
      <Link href="/intervenants" className="text-blue-700">
        Liste Sous Traitants.
      </Link>
      <div className="mt-1 flex flex-wrap items-center gap-1">
        <Link href={`/interventions/${p.id}`} className="rounded border px-1.5 py-0.5 text-[11px] no-underline" title="Ouvrir la fiche intervention">
          Fiche
        </Link>
        <button type="button" onClick={() => copier(titre)} className="rounded border px-1.5 py-0.5 text-[11px]">
          Copie Titre
        </button>
        <button type="button" onClick={() => copier(texte)} className="rounded border px-1.5 py-0.5 text-[11px]">
          Copie Intervention
        </button>
      </div>
    </div>
  );
}

export function CarteInterventions({ points }: { points: PointCarte[] }) {
  // Une épingle par site, numérotée du nombre d'interventions à réaliser (comme sur la capture).
  const parSite = new Map<number, PointCarte[]>();
  for (const p of points) {
    const liste = parSite.get(p.site_id) ?? [];
    liste.push(p);
    parSite.set(p.site_id, liste);
  }
  const centre: [number, number] = points.length
    ? [points.reduce((s, p) => s + p.latitude, 0) / points.length, points.reduce((s, p) => s + p.longitude, 0) / points.length]
    : [46.6, 2.4];

  return (
    <MapContainer center={centre} zoom={6} className="h-[calc(100vh-11rem)] min-h-[28rem] w-full border" scrollWheelZoom>
      <LayersControl position="topright">
        <LayersControl.BaseLayer checked name="STREETS">
          <TileLayer attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>' url="https://tile.openstreetmap.org/{z}/{x}/{y}.png" />
        </LayersControl.BaseLayer>
        <LayersControl.BaseLayer name="SATELLITE">
          <TileLayer attribution="Tiles &copy; Esri" url="https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}" />
        </LayersControl.BaseLayer>
      </LayersControl>
      {Array.from(parSite.entries()).map(([siteId, liste]) => {
        const premier = liste[0];
        return (
          <Marker key={siteId} position={[premier.latitude, premier.longitude]} icon={icone(couleurType(premier.type_code, premier.statut_code), liste.length, liste.some((p) => p.depassee))}>
            <Popup maxWidth={320}>
              <div className="flex max-h-96 flex-col gap-3 overflow-y-auto pr-1">
                {liste.map((p) => (
                  <FicheIntervention key={p.id} p={p} />
                ))}
              </div>
            </Popup>
          </Marker>
        );
      })}
    </MapContainer>
  );
}
