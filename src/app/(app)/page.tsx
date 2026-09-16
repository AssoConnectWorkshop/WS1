import Link from "next/link";
import { getCurrentUser } from "@/lib/auth";
import { lienVue } from "@/lib/vues-tableau-de-bord";
import { createClient } from "@/lib/supabase/server";
import { ETATS_HORS_ALERTES, calculerAlertes, type Alertes, type Evenement, type Vehicule } from "@/lib/vehicules";

export const dynamic = "force-dynamic";

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

/** Couleurs des pastilles du menu Access (MAJBubule) : rose, rouge, bleu, vert, orange, noir/violet. */
type Couleur = "rose" | "rouge" | "bleu" | "vert" | "orange" | "violet" | "cyan";
const COULEURS: Record<Couleur, string> = {
  rose: "bg-pink-500",
  rouge: "bg-red-600",
  bleu: "bg-indigo-600",
  vert: "bg-lime-500",
  orange: "bg-orange-500",
  violet: "bg-purple-700",
  cyan: "bg-teal-500",
};

type Pastille = { valeur: number | null | undefined; couleur: Couleur; titre: string; petite?: boolean };

function Pastilles({ pastilles }: { pastilles: Pastille[] }) {
  return (
    <div className="absolute -right-2 -top-2 flex max-w-[9rem] flex-wrap justify-end gap-0.5">
      {pastilles.map((p) => (
        <span
          key={p.titre}
          title={p.titre}
          className={`flex items-center justify-center rounded-full font-semibold text-white shadow ${COULEURS[p.couleur]} ${
            p.petite ? "h-6 min-w-6 px-1 text-[10px]" : "h-9 min-w-9 px-1.5 text-sm"
          }`}
        >
          {p.valeur ?? 0}
        </span>
      ))}
    </div>
  );
}

function Icone({
  href,
  label,
  icone,
  pastilles = [],
  indisponible,
}: {
  href?: string;
  label: string;
  icone: string;
  pastilles?: Pastille[];
  indisponible?: string;
}) {
  const contenu = (
    <>
      <span className="relative flex h-20 w-20 items-center justify-center rounded border bg-white text-5xl shadow-sm dark:bg-white/5">
        <span aria-hidden>{icone}</span>
        {pastilles.length > 0 && <Pastilles pastilles={pastilles} />}
      </span>
      <span className="max-w-32 text-center text-[11px] leading-tight uppercase">{label}</span>
    </>
  );
  if (!href) {
    return (
      <span title={indisponible} className="flex w-32 flex-col items-center gap-1.5 opacity-40">
        {contenu}
      </span>
    );
  }
  return (
    <Link href={href} className="flex w-32 flex-col items-center gap-1.5 hover:opacity-80">
      {contenu}
    </Link>
  );
}

const HORS_VERSION = "Non disponible dans cette version (voir docs/plan/etape-8.md, écarts non traités)";

/** Alerte_Voitures (analysis 04 §5.3) : compteurs par type de problème, véhicules vendus / état 5 exclus. */
async function compteursVehicules(): Promise<Record<keyof Alertes, number>> {
  const supabase = await createClient();
  const [{ data: vehicules }, { data: evenements }] = await Promise.all([
    supabase.from("vehicules").select("id, immatriculation, etat_code, date_mise_en_circulation, km_entre_revisions, mois_entre_revisions, garantie, garantie_mois, leasing, leasing_mois, leasing_date_fin"),
    supabase.from("vehicule_evenements").select("vehicule_id, date_evenement, km, type_code"),
  ]);
  const compteurs: Record<keyof Alertes, number> = { ct: 0, cc: 0, revision: 0, leasing: 0, garantie: 0 };
  for (const v of (vehicules ?? []) as Vehicule[]) {
    if (v.etat_code != null && ETATS_HORS_ALERTES.includes(v.etat_code)) continue;
    const alertes = calculerAlertes(v, (evenements ?? []).filter((e): e is Evenement => e.vehicule_id === v.id));
    for (const k of Object.keys(alertes) as (keyof Alertes)[]) if (alertes[k]) compteurs[k] += 1;
  }
  return compteurs;
}

/** Menu d'accueil Access (Form_MenuClimAccess) : grille d'icônes et pastilles de compteurs (analysis 01 §2.1). */
export default async function MenuPage() {
  const supabase = await createClient();
  const [{ data, error }, vehicules, current] = await Promise.all([supabase.from("v_tableau_de_bord").select("*").maybeSingle(), compteursVehicules(), getCurrentUser()]);
  const c = (data ?? {}) as Partial<Compteurs>;
  if (error) console.error("v_tableau_de_bord:", error.message);
  const u = current?.utilisateur;
  const nomUtilisateur = [u?.prenom, u?.nom].filter(Boolean).join(" ") || u?.email || "";

  return (
    <div className="mx-auto flex max-w-6xl flex-col gap-10 p-8">
      {error && (
        <p className="rounded border border-red-300 bg-red-50 px-3 py-2 text-xs text-red-700 dark:bg-red-950/30">
          Compteurs indisponibles : {error.message}
        </p>
      )}
      <section className="grid grid-cols-3 items-start gap-6 md:grid-cols-[repeat(3,8rem)_1fr_repeat(2,8rem)]">
        <Icone href="/clients" label="Clients" icone="🤝" />
        <Icone href="/sites" label="Sites" icone="🛒" />
        <Icone href={lienVue("a-planifier")} label="Entretien / Dépannage Devis acceptés" icone="🧰" />
        <p className="col-span-3 self-center text-center text-lg md:col-span-1">Utilisateur choisi : {nomUtilisateur}</p>
        <Icone href="/interventions/gaz" label="Utilisation FF" icone="🧪" />
        <Icone href="/parametrage/utilisateurs" label="Utilisateurs" icone="🔑" />
      </section>

      <section className="grid grid-cols-3 items-start gap-6 md:grid-cols-[repeat(4,8rem)_10rem_repeat(2,8rem)]">
        <Icone
          href={lienVue("duplicata")}
          label="Duplicata"
          icone="📋"
          pastilles={[
            { valeur: c.duplicata_total, couleur: "rose", titre: "Total" },
            { valeur: c.duplicata_a_traiter, couleur: "violet", titre: "À traiter", petite: true },
            { valeur: c.duplicata_traitees, couleur: "rose", titre: "Attente offre de prix", petite: true },
          ]}
        />
        <Icone href={lienVue("a-commander")} label="Matériel à commander" icone="📦" pastilles={[{ valeur: c.materiel_a_commander, couleur: "rose", titre: "Matériel à commander" }]} />
        <Icone href={lienVue("attente-materiel")} label="Attente matériel" icone="🚚" pastilles={[{ valeur: c.attente_materiel, couleur: "rose", titre: "Attente matériel" }]} />
        <Icone href={lienVue("a-valider")} label="Fiches d'interventions à valider" icone="📝" pastilles={[{ valeur: c.a_valider, couleur: "rouge", titre: "À valider" }]} />
        <div className="flex flex-col items-center gap-1.5">
          <Icone
            href={lienVue("a-facturer")}
            label="Fiches d'interventions à facturer"
            icone="💶"
            pastilles={[
              { valeur: c.maintenances, couleur: "bleu", titre: "Maintenances" },
              { valeur: c.devis_sav_acceptes, couleur: "rouge", titre: "Devis SAV acceptés" },
              { valeur: c.depannage, couleur: "vert", titre: "Dépannage" },
              { valeur: c.en_travaux, couleur: "orange", titre: "En travaux" },
              { valeur: c.autres, couleur: "violet", titre: "Autres types" },
              { valeur: c.stand_by, couleur: "violet", titre: "Stand by", petite: true },
            ]}
          />
          <Link href="/" className="rounded border px-2 py-0.5 text-[11px]">
            MAJ
          </Link>
        </div>
        <Icone href={lienVue("direction")} label="À valider par le Boss" icone="🪑" pastilles={[{ valeur: c.a_definir_direction, couleur: "rouge", titre: "À valider par la direction" }]} />
        <Icone label="Filtre extraction" icone="📊" indisponible={HORS_VERSION} />
      </section>

      <section className="grid grid-cols-3 items-start gap-6 md:grid-cols-[repeat(8,8rem)]">
        <Icone href="/parametrage" label="Paramétrage" icone="🔧" />
        <Icone href="/clients" label="Statistiques" icone="📈" />
        <Icone href="/devis?onglet=contrat" label="Contrat de maintenance" icone="📄" />
        <Icone href="/devis?onglet=sav" label="Devis SAV" icone="👷" />
        <Icone href="/devis?onglet=travaux" label="Devis travaux" icone="👷‍♂️" />
        <Icone label="Intervalle de dates à afficher sur tablette" icone="📅" indisponible={HORS_VERSION} />
        <Icone href="/intervenants" label="Intervenants" icone="💼" />
        <Icone
          href="/vehicules"
          label="Véhicules"
          icone="🚛"
          pastilles={[
            { valeur: vehicules.ct, couleur: "violet", titre: "Problème de contrôle technique" },
            { valeur: vehicules.cc, couleur: "orange", titre: "Problème de contrôle complémentaire" },
            { valeur: vehicules.revision, couleur: "vert", titre: "Problème de révision" },
            { valeur: vehicules.leasing, couleur: "cyan", titre: "Problème de leasing" },
            { valeur: vehicules.garantie, couleur: "violet", titre: "Problème de garantie" },
          ]}
        />
      </section>

      <section className="grid grid-cols-3 items-start gap-6 md:grid-cols-[repeat(8,8rem)]">
        <Icone href="/carte" label="Carte" icone="🗺️" />
        <Icone href="/planification" label="Planification" icone="🗓️" />
      </section>

      <footer className="flex items-center justify-between pt-6 text-2xl font-bold tracking-tight">
        <span>
          <span className="text-indigo-700">FMC</span> <span className="text-sm font-semibold text-indigo-700">CLIMATISATION</span>
        </span>
        <span>
          <span className="text-purple-700">FMC</span> <span className="text-sm font-semibold text-purple-700">MAINTENANCE</span>
        </span>
      </footer>
    </div>
  );
}
