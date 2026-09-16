import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { KeyValue } from "@/components/ui/KeyValue";
import { EmptyState } from "@/components/ui/EmptyState";
import { Badge } from "@/components/ui/Badge";
import { Tabs } from "@/components/ui/Tabs";
import { Contacts } from "@/components/tiers/Contacts";
import { ChampsDonneur } from "@/components/tiers/FormulaireClient";
import { oui } from "@/lib/format";
import { toStringParams } from "@/lib/list-params";
import { mettreAJourDonneur } from "../../tiers/actions";

export const dynamic = "force-dynamic";

const ONGLETS = [
  { key: "fiche", label: "Fiche" },
  { key: "contacts", label: "Contacts" },
  { key: "sites", label: "Sites rattachés" },
];

export default async function DonneurOrdrePage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { id } = await params;
  const sp = toStringParams(await searchParams);
  const onglet = ONGLETS.some((o) => o.key === sp.onglet) ? sp.onglet! : "fiche";

  const supabase = await createClient();
  const { data: donneur } = await supabase.from("donneurs_ordre").select("*").eq("id", id).maybeSingle();
  if (!donneur) notFound();

  const [{ data: contacts }, { data: sites }] = await Promise.all([
    supabase.from("contacts").select("id, nom, prenom, civilite, fonction, email, telephone, mobile, fax, observations").eq("donneur_ordre_id", id).order("nom"),
    supabase.from("sites").select("id, nom, ville").eq("donneur_ordre_id", id).is("supprime_le", null).order("nom"),
  ]);

  return (
    <div className="mx-auto flex max-w-4xl flex-col gap-4 p-8">
      {sp.erreur && <p className="rounded-md bg-red-50 p-3 text-sm text-red-700">{sp.erreur}</p>}
      {sp.info && <p className="rounded-md bg-blue-50 p-3 text-sm text-blue-800">{sp.info}</p>}

      <div className="flex flex-wrap items-center gap-2">{!donneur.actif && <Badge tone="gray">Non affiché</Badge>}</div>
      <h1 className="text-xl font-semibold">{donneur.nom}</h1>

      <Tabs tabs={ONGLETS} active={onglet} searchParams={sp} />

      {onglet === "fiche" && (
        <div className="flex flex-col gap-6">
          <KeyValue
            items={[
              { label: "Adresse", value: `${donneur.adresse ?? ""} ${donneur.code_postal ?? ""} ${donneur.ville ?? ""}`.trim() || "—" },
              { label: "Contact principal", value: donneur.contact_principal },
              { label: "Téléphone", value: donneur.telephone },
              { label: "E-mail", value: donneur.email },
              { label: "Délai d'intervention (h)", value: donneur.delai_intervention_heures },
              { label: "Saisie simplifiée tablette", value: oui(donneur.saisie_simplifiee_tablette) },
            ]}
          />
          <form action={mettreAJourDonneur} className="flex flex-col gap-3 rounded-xl border p-4">
            <h2 className="text-sm font-semibold opacity-70">Modifier</h2>
            <input type="hidden" name="donneur_ordre_id" value={id} />
            <ChampsDonneur donneur={donneur} />
            <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
              Enregistrer
            </button>
          </form>
        </div>
      )}

      {onglet === "contacts" && (
        <Contacts contacts={contacts ?? []} parent={{ donneur_ordre_id: Number(id) }} modifierId={sp.modifier} retour={`/donneurs-ordre/${id}?onglet=contacts`} />
      )}

      {onglet === "sites" &&
        (sites && sites.length > 0 ? (
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
        ))}
    </div>
  );
}
