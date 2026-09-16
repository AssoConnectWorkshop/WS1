import { createClient } from "@/lib/supabase/server";
import { toArrayParam, toStringParams } from "@/lib/list-params";
import { FilterBar, type FilterField } from "@/components/ui/FilterBar";
import { CarteClient } from "@/components/carte/CarteClient";
import type { PointCarte } from "@/components/carte/CarteInterventions";

export const dynamic = "force-dynamic";

const LEGENDE = [
  ["#2563eb", "Entretien"],
  ["#16a34a", "Dépannage"],
  ["#dc2626", "Travaux selon devis"],
  ["#f97316", "En travaux"],
  ["#facc15", "Désenfumage / statut -1"],
  ["#111111", "Audit"],
  ["#92400e", "Autre"],
];

/** Carte des interventions géolocalisées (Form_Carte) : une épingle par intervention, cercle 500 m si date limite dépassée. */
export default async function CartePage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const raw = await searchParams;
  const sp = toStringParams(raw);
  const types = toArrayParam(raw.types);
  const statuts = toArrayParam(raw.statuts);
  const intervenantsSel = toArrayParam(raw.intervenants);
  const zonesSel = toArrayParam(raw.zones);
  const supabase = await createClient();

  const [{ data: typesRef }, { data: statutsRef }, { data: zones }, { data: donneurs }, { data: intervenants }] = await Promise.all([
    supabase.from("types_intervention").select("code, libelle").order("ordre_affichage"),
    supabase.from("statuts_intervention").select("code, libelle").eq("actif", true).order("ordre_affichage"),
    supabase.from("zones_geographiques").select("id, libelle").order("libelle"),
    supabase.from("donneurs_ordre").select("id, nom").order("nom"),
    supabase.from("intervenants").select("id, nom").order("nom"),
  ]);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let query: any = supabase
    .from("v_interventions_liste")
    .select(
      "id, latitude, longitude, type_code, type_libelle, statut_code, statut_libelle, client_nom, site_nom, site_adresse, site_code_postal, site_ville, date_demande, date_limite, date_prevue, date_realisee, intervenant_nom, charge_affaire_nom, commentaire_interne",
    )
    .not("latitude", "is", null)
    .not("longitude", "is", null)
    .limit(3000);
  if (sp.client) query = query.ilike("client_nom", `%${sp.client}%`);
  if (types.length) query = query.in("type_code", types.map(Number));
  if (statuts.length) query = query.in("statut_code", statuts.map(Number));
  else if (sp.clotures !== "1") query = query.not("statut_code", "in", "(7,8,10,20)");
  if (sp.donneur) query = query.eq("donneur_ordre_id", Number(sp.donneur));
  if (intervenantsSel.length) query = query.in("intervenant_id", intervenantsSel.map(Number));
  if (zonesSel.length) query = query.in("zone_id", zonesSel.map(Number));
  if (sp.periode_debut) query = query.gte("date_limite", sp.periode_debut);
  if (sp.periode_fin) query = query.lte("date_limite", sp.periode_fin);
  type LigneCarte = Omit<PointCarte, "latitude" | "longitude" | "adresse" | "depassee"> & {
    latitude: string | number;
    longitude: string | number;
    site_adresse: string | null;
    site_code_postal: string | null;
    site_ville: string | null;
  };
  const { data } = (await query) as { data: LigneCarte[] | null };

  const maintenant = Date.now();
  const points: PointCarte[] = (data ?? []).map((i) => ({
    id: i.id,
    latitude: Number(i.latitude),
    longitude: Number(i.longitude),
    type_code: i.type_code,
    type_libelle: i.type_libelle,
    statut_code: i.statut_code,
    statut_libelle: i.statut_libelle,
    client_nom: i.client_nom,
    site_nom: i.site_nom,
    adresse: [i.site_adresse, i.site_code_postal, i.site_ville].filter(Boolean).join(" ") || null,
    date_demande: i.date_demande,
    date_limite: i.date_limite,
    date_prevue: i.date_prevue,
    date_realisee: i.date_realisee,
    intervenant_nom: i.intervenant_nom,
    charge_affaire_nom: i.charge_affaire_nom,
    commentaire_interne: i.commentaire_interne,
    depassee: !!i.date_limite && new Date(i.date_limite).getTime() < maintenant && !i.date_realisee,
  }));

  const filterFields: FilterField[] = [
    { type: "text", name: "client", label: "Client" },
    { type: "multiselect", name: "types", label: "Types", options: (typesRef ?? []).map((t) => ({ value: String(t.code), label: t.libelle })) },
    { type: "multiselect", name: "statuts", label: "Statuts", options: (statutsRef ?? []).map((s) => ({ value: String(s.code), label: s.libelle })) },
    { type: "select", name: "donneur", label: "Donneur d'ordre", options: (donneurs ?? []).map((d) => ({ value: String(d.id), label: d.nom ?? "" })) },
    { type: "multiselect", name: "intervenants", label: "Intervenants", options: (intervenants ?? []).map((i) => ({ value: String(i.id), label: i.nom ?? "" })) },
    { type: "multiselect", name: "zones", label: "Zones", options: (zones ?? []).map((z) => ({ value: String(z.id), label: z.libelle })) },
    { type: "date", name: "periode_debut", label: "Date limite du" },
    { type: "date", name: "periode_fin", label: "Date limite au" },
    { type: "checkbox", name: "clotures", label: "Inclure les clôturées / annulées" },
  ];

  return (
    <div className="mx-auto flex max-w-7xl flex-col gap-4 p-8">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Carte des interventions</h1>
        <span className="text-sm opacity-70">{points.length} intervention(s) géolocalisée(s){points.length >= 3000 ? " (limite atteinte, affinez les filtres)" : ""}</span>
      </div>
      <FilterBar fields={filterFields} values={sp} multiValues={{ types, statuts, intervenants: intervenantsSel, zones: zonesSel }} />
      <div className="flex flex-wrap gap-3 text-xs">
        {LEGENDE.map(([couleur, libelle]) => (
          <span key={libelle} className="flex items-center gap-1">
            <span className="inline-block h-3 w-3 rounded-full" style={{ backgroundColor: couleur }} />
            {libelle}
          </span>
        ))}
        <span className="flex items-center gap-1">
          <span className="inline-block h-3 w-3 rounded-full border border-orange-500" /> Date limite dépassée (cercle 500 m)
        </span>
      </div>
      <CarteClient points={points} />
    </div>
  );
}
