import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { ETATS_HORS_ALERTES, LIBELLES_ALERTES, calculerAlertes, type Alertes, type Evenement, type Vehicule } from "@/lib/vehicules";

export const dynamic = "force-dynamic";

/** Alerte_Voitures (analysis 04 §5.3) : compteurs par type de problème, véhicules vendus / état 5 exclus. */
async function AlertesVehicules() {
  const supabase = await createClient();
  const [{ data: vehicules }, { data: evenements }] = await Promise.all([
    supabase.from("vehicules").select("id, immatriculation, etat_code, date_mise_en_circulation, km_entre_revisions, mois_entre_revisions, garantie, garantie_mois, leasing, leasing_mois, leasing_date_fin"),
    supabase.from("vehicule_evenements").select("vehicule_id, date_evenement, km, type_code"),
  ]);
  const compteurs: Record<keyof Alertes, string[]> = { ct: [], cc: [], revision: [], leasing: [], garantie: [] };
  for (const v of (vehicules ?? []) as Vehicule[]) {
    if (v.etat_code != null && ETATS_HORS_ALERTES.includes(v.etat_code)) continue;
    const alertes = calculerAlertes(v, (evenements ?? []).filter((e): e is Evenement => e.vehicule_id === v.id));
    for (const k of Object.keys(alertes) as (keyof Alertes)[]) if (alertes[k]) compteurs[k].push(v.immatriculation ?? `#${v.id}`);
  }
  const total = Object.values(compteurs).reduce((s, l) => s + l.length, 0);

  return (
    <section className="flex flex-col gap-2">
      <h2 className="text-sm font-semibold opacity-70">Parc automobile{total === 0 ? " : tout est OK" : ""}</h2>
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-5">
        {(Object.keys(compteurs) as (keyof Alertes)[]).map((k) => (
          <Tile key={k} href={`/vehicules?alerte=${k}`} value={compteurs[k].length} label={`Problème de ${LIBELLES_ALERTES[k].toLowerCase()}${compteurs[k].length ? ` : ${compteurs[k].slice(0, 3).join(", ")}${compteurs[k].length > 3 ? "…" : ""}` : ""}`} />
        ))}
      </div>
    </section>
  );
}

const NAV_TILES = [
  { href: "/clients", label: "Clients" },
  { href: "/sites", label: "Sites" },
  { href: "/intervenants", label: "Intervenants" },
  { href: "/interventions", label: "Interventions" },
  { href: "/devis", label: "Devis" },
  { href: "/planification", label: "Planification" },
  { href: "/carte", label: "Carte" },
  { href: "/vehicules", label: "Véhicules" },
  { href: "/parametrage", label: "Paramétrage" },
];

type Compteurs = {
  a_valider: number | null;
  a_facturer: number | null;
  a_definir_direction: number | null;
  stand_by: number | null;
  materiel_a_commander: number | null;
  attente_materiel: number | null;
  duplicata_total: number | null;
  duplicata_a_traiter: number | null;
  duplicata_traitees: number | null;
  depannage: number | null;
  maintenances: number | null;
  devis_sav_acceptes: number | null;
  en_travaux: number | null;
  autres: number | null;
};

function Tile({ href, value, label }: { href: string; value: number | null | undefined; label: string }) {
  return (
    <Link
      href={href}
      className="flex flex-col gap-1 rounded-xl border p-4 hover:bg-black/[0.02] dark:hover:bg-white/[0.03]"
    >
      <span className="text-2xl font-bold">{value ?? 0}</span>
      <span className="text-xs opacity-70">{label}</span>
    </Link>
  );
}

export default async function DashboardPage() {
  const supabase = await createClient();
  const { data } = await supabase.from("v_tableau_de_bord").select("*").maybeSingle();
  const c = (data ?? {}) as Partial<Compteurs>;

  return (
    <div className="mx-auto flex max-w-6xl flex-col gap-8 p-8">
      <h1 className="text-2xl font-bold">Tableau de bord</h1>

      <section className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-6">
        <Tile href="/interventions?vue=a-valider" value={c.a_valider} label="À valider" />
        <Tile href="/interventions?vue=a-facturer" value={c.a_facturer} label="À facturer" />
        <Tile href="/interventions?vue=direction" value={c.a_definir_direction} label="À définir par la direction" />
        <Tile href="/interventions?vue=standby" value={c.stand_by} label="Stand-by" />
        <Tile href="/interventions?vue=a-commander" value={c.materiel_a_commander} label="Matériel à commander" />
        <Tile href="/interventions?vue=attente-materiel" value={c.attente_materiel} label="Attente matériel" />
      </section>

      <section className="flex flex-col gap-2">
        <h2 className="text-sm font-semibold opacity-70">Duplicata (clôturé, devis à faire)</h2>
        <div className="grid grid-cols-3 gap-3 sm:max-w-md">
          <Tile href="/interventions?vue=duplicata" value={c.duplicata_total} label="Total" />
          <Tile href="/interventions?vue=duplicata" value={c.duplicata_a_traiter} label="À traiter" />
          <Tile href="/interventions?vue=duplicata" value={c.duplicata_traitees} label="Traités" />
        </div>
      </section>

      <section className="flex flex-col gap-2">
        <h2 className="text-sm font-semibold opacity-70">En facturation 1 ou 2, par type</h2>
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-5">
          <div className="rounded-xl border p-4">
            <div className="text-2xl font-bold">{c.depannage ?? 0}</div>
            <div className="text-xs opacity-70">Dépannage</div>
          </div>
          <div className="rounded-xl border p-4">
            <div className="text-2xl font-bold">{c.maintenances ?? 0}</div>
            <div className="text-xs opacity-70">Maintenances</div>
          </div>
          <div className="rounded-xl border p-4">
            <div className="text-2xl font-bold">{c.devis_sav_acceptes ?? 0}</div>
            <div className="text-xs opacity-70">Devis SAV acceptés</div>
          </div>
          <div className="rounded-xl border p-4">
            <div className="text-2xl font-bold">{c.en_travaux ?? 0}</div>
            <div className="text-xs opacity-70">En travaux</div>
          </div>
          <div className="rounded-xl border p-4">
            <div className="text-2xl font-bold">{c.autres ?? 0}</div>
            <div className="text-xs opacity-70">Autres</div>
          </div>
        </div>
      </section>

      <AlertesVehicules />

      <section className="flex flex-col gap-2">
        <h2 className="text-sm font-semibold opacity-70">Navigation</h2>
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
          {NAV_TILES.map((tile) => (
            <Link
              key={tile.href}
              href={tile.href}
              className="rounded-xl border p-6 text-center font-medium hover:bg-black/[0.02] dark:hover:bg-white/[0.03]"
            >
              {tile.label}
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
}
