import Link from "next/link";
import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { createClient } from "@/lib/supabase/server";
import { NavPrincipale } from "@/components/ui/NavPrincipale";
import { estMasterAdmin } from "@/lib/acces";

const BOUTON_ENTETE = "cursor-pointer rounded-md border px-3 py-1 shadow-sm transition hover:bg-black/[0.05] hover:shadow active:translate-y-px dark:hover:bg-white/10";

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
  { href: "/taches", label: "Todo product" },
  { href: "/taches/tech", label: "Todo tech" },
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
    if (current.diagnostic.length) console.error("rattachement:", current.authUser.id, current.diagnostic.join(" | "));
    return (
      <main className="flex min-h-screen items-center justify-center p-8">
        <div className="flex max-w-md flex-col gap-3 text-center">
          <h1 className="text-xl font-semibold">Compte non rattaché</h1>
          <p className="text-sm opacity-70">
            Impossible de rattacher votre compte ({current.authUser.email ?? "sans e-mail"}) à
            l&apos;application. Réessayez ; si le problème persiste, contactez un administrateur.
          </p>
          {estMasterAdmin(current.authUser.email) && current.diagnostic.length > 0 && (
            <ul className="rounded border border-red-300 bg-red-50 p-3 text-left text-xs text-red-700 dark:bg-red-950/30">
              {current.diagnostic.map((d) => (
                <li key={d}>{d}</li>
              ))}
            </ul>
          )}
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
        <NavPrincipale items={visibleNav.map(({ href, label }) => ({ href, label }))} />
        <div className="flex items-center gap-3 text-sm">
          <span>
            {[utilisateur.prenom, utilisateur.nom].filter(Boolean).join(" ") || utilisateur.email}
            {" · "}
            {role ?? "gestionnaire"}
          </span>
          <Link href="/mot-de-passe" className={BOUTON_ENTETE} title="Changer mon mot de passe">
            Mot de passe
          </Link>
          <form action={signOut}>
            <button type="submit" className={BOUTON_ENTETE}>
              Déconnexion
            </button>
          </form>
        </div>
      </header>
      <main className="flex-1">{children}</main>
    </div>
  );
}
