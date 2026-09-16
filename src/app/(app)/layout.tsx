import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { createClient } from "@/lib/supabase/server";

const NAV_ITEMS: { href: string; label: string; adminOnly?: boolean }[] = [
  { href: "/", label: "Tableau de bord" },
  { href: "/interventions", label: "Interventions" },
  { href: "/sites", label: "Sites" },
  { href: "/clients", label: "Clients" },
  { href: "/intervenants", label: "Intervenants" },
  { href: "/devis", label: "Devis" },
  { href: "/planification", label: "Planification" },
  { href: "/carte", label: "Carte" },
  { href: "/vehicules", label: "Véhicules" },
  { href: "/parametrage", label: "Paramétrage" },
  { href: "/taches", label: "À faire" },
];

async function signOut() {
  "use server";
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/login");
}

export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const current = await getCurrentUser();

  if (!current) {
    redirect("/login");
  }

  if (!current.utilisateur) {
    return (
      <main className="flex min-h-screen items-center justify-center p-8">
        <div className="flex max-w-md flex-col gap-3 text-center">
          <h1 className="text-xl font-semibold">Compte non rattaché</h1>
          <p className="text-sm opacity-70">
            Votre compte ({current.authUser.email}) n&apos;est rattaché à aucun utilisateur
            ClimAccess. Contactez un administrateur.
          </p>
          <form action={signOut}>
            <button type="submit" className="text-sm underline">
              Se déconnecter
            </button>
          </form>
        </div>
      </main>
    );
  }

  const { utilisateur, role } = current;
  const visibleNav = NAV_ITEMS.filter((item) => !item.adminOnly || role === "administrateur");

  return (
    <div className="flex min-h-screen flex-col">
      <header className="flex flex-wrap items-center justify-between gap-3 border-b px-6 py-3">
        <nav className="flex flex-wrap gap-4 text-sm">
          {visibleNav.map((item) => (
            <a key={item.href} href={item.href} className="hover:underline">
              {item.label}
            </a>
          ))}
        </nav>
        <div className="flex items-center gap-3 text-sm">
          <span>
            {[utilisateur.prenom, utilisateur.nom].filter(Boolean).join(" ") || utilisateur.email}
            {" · "}
            {role ?? "gestionnaire"}
          </span>
          <form action={signOut}>
            <button type="submit" className="rounded-md border px-3 py-1">
              Déconnexion
            </button>
          </form>
        </div>
      </header>
      <main className="flex-1">{children}</main>
    </div>
  );
}
