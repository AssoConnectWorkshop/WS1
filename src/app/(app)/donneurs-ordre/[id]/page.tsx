import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { KeyValue } from "@/components/ui/KeyValue";
import { EmptyState } from "@/components/ui/EmptyState";

export const dynamic = "force-dynamic";

export default async function DonneurOrdrePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const { data: donneur } = await supabase.from("donneurs_ordre").select("*").eq("id", id).maybeSingle();
  if (!donneur) notFound();

  const [{ data: contacts }, { data: sites }] = await Promise.all([
    supabase.from("contacts").select("id, nom, prenom, email, telephone").eq("donneur_ordre_id", id).order("nom"),
    supabase.from("sites").select("id, nom, ville").eq("donneur_ordre_id", id).order("nom"),
  ]);

  return (
    <div className="mx-auto flex max-w-4xl flex-col gap-6 p-8">
      <h1 className="text-xl font-semibold">{donneur.nom}</h1>

      <KeyValue
        items={[
          { label: "Adresse", value: `${donneur.adresse ?? ""} ${donneur.code_postal ?? ""} ${donneur.ville ?? ""}`.trim() || "—" },
          { label: "Contact principal", value: donneur.contact_principal },
          { label: "Téléphone", value: donneur.telephone },
          { label: "E-mail", value: donneur.email },
          { label: "Délai d'intervention (h)", value: donneur.delai_intervention_heures },
        ]}
      />

      <div>
        <h2 className="mb-2 text-sm font-semibold opacity-70">Contacts</h2>
        {contacts && contacts.length > 0 ? (
          <ul className="flex flex-col gap-2">
            {contacts.map((c) => (
              <li key={c.id} className="rounded-lg border p-3 text-sm">
                {[c.prenom, c.nom].filter(Boolean).join(" ")} · {c.email ?? "—"} · {c.telephone ?? "—"}
              </li>
            ))}
          </ul>
        ) : (
          <EmptyState message="Aucun contact." />
        )}
      </div>

      <div>
        <h2 className="mb-2 text-sm font-semibold opacity-70">Sites rattachés</h2>
        {sites && sites.length > 0 ? (
          <ul className="flex flex-col gap-2">
            {sites.map((s) => (
              <li key={s.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
                <Link href={`/sites/${s.id}`} className="underline">
                  {s.nom}
                </Link>
                <span className="opacity-70">{s.ville}</span>
              </li>
            ))}
          </ul>
        ) : (
          <EmptyState message="Aucun site rattaché." />
        )}
      </div>
    </div>
  );
}
