import Link from "next/link";

/** Colonne de boutons de Form_Parametrage, dans l'ordre Access ; les référentiels absents d'Access suivent sous « Autres ». */
const BOUTONS_ACCESS: { label: string; href: string }[] = [
  { label: "Utilisateurs & Techniciens", href: "/parametrage/utilisateurs" },
  { label: "Intervenant", href: "/intervenants" },
  { label: "Donneurs d'ordres", href: "/donneurs-ordre" },
  { label: "Sociétés", href: "/parametrage/societes" },
  { label: "Zone géographique", href: "/parametrage/zones-geographiques" },
  { label: "Activites", href: "/parametrage/activites" },
  { label: "References", href: "/parametrage/catalogue" },
  { label: "Reperes", href: "/parametrage/reperes" },
  { label: "Marque", href: "/parametrage/marques" },
  { label: "Type", href: "/parametrage/types-equipement" },
  { label: "Fluide", href: "/parametrage/types-fluide" },
  { label: "Classif Gaz", href: "/parametrage/familles-gaz" },
  { label: "Type Telecommande", href: "/parametrage/types-telecommande" },
  { label: "Panne", href: "/parametrage/pannes" },
  { label: "Type Intervention", href: "/parametrage/types-intervention" },
  { label: "Sous Type Inter", href: "/parametrage/sous-types-intervention" },
  { label: "Statut Facturation", href: "/parametrage/statuts-facturation" },
  { label: "Statut Interventions", href: "/parametrage/statuts-intervention" },
  { label: "Ecart Mini Maintenance", href: "/parametrage/ecarts-visites" },
  { label: "Liste Vehicules", href: "/vehicules" },
  { label: "Evements Vehicules", href: "/parametrage/types-evenement-vehicule" },
];

const AUTRES: { label: string; href: string }[] = [
  { label: "Natures de visite", href: "/parametrage/natures-visite" },
  { label: "Modes de résolution", href: "/parametrage/modes-resolution" },
  { label: "Jours fériés", href: "/parametrage/jours-feries" },
  { label: "États véhicule", href: "/parametrage/etats-vehicule" },
  { label: "Statuts de devis", href: "/parametrage/statuts-devis" },
  { label: "Paramètres de l'application", href: "/parametrage/parametres" },
  { label: "Accès application", href: "/parametrage/acces" },
];

const BOUTON = "block rounded border bg-white px-2 py-1 text-center text-xs shadow-sm hover:bg-black/[0.03] dark:bg-white/5 dark:hover:bg-white/10";

export default function ParametrageLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="grid gap-4 p-4 lg:grid-cols-[11rem_1fr]">
      <nav className="flex flex-col gap-1.5">
        {BOUTONS_ACCESS.map((b, i) => (
          <span key={b.href} className={[1, 3, 7, 13, 14, 18, 19].includes(i) ? "pt-2" : ""}>
            <Link href={b.href} className={BOUTON}>
              {b.label}
            </Link>
          </span>
        ))}
        <span className="pt-3 text-[10px] uppercase opacity-60">Autres</span>
        {AUTRES.map((b) => (
          <Link key={b.href} href={b.href} className={BOUTON}>
            {b.label}
          </Link>
        ))}
      </nav>
      <div className="min-w-0">{children}</div>
    </div>
  );
}
