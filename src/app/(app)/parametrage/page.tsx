import Link from "next/link";
import { getCurrentUser } from "@/lib/auth";
import { REFERENTIELS } from "@/lib/referentiels-config";

export const dynamic = "force-dynamic";

export default async function ParametragePage() {
  const current = await getCurrentUser();
  const isAdmin = current?.role === "administrateur";

  return (
    <div className="mx-auto flex max-w-4xl flex-col gap-4 p-8">
      <h1 className="text-2xl font-bold">Paramétrage</h1>
      <p className="text-sm opacity-70">
        Consultation des référentiels. L&apos;écriture arrive à l&apos;étape 5.
      </p>

      {isAdmin && (
        <Link href="/parametrage/utilisateurs" className="w-fit rounded-lg border p-4 font-medium hover:bg-black/[0.02] dark:hover:bg-white/[0.03]">
          Utilisateurs
        </Link>
      )}

      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
        {REFERENTIELS.map((r) => (
          <Link
            key={r.slug}
            href={`/parametrage/${r.slug}`}
            className="rounded-lg border p-4 text-sm hover:bg-black/[0.02] dark:hover:bg-white/[0.03]"
          >
            {r.label}
          </Link>
        ))}
      </div>
    </div>
  );
}
