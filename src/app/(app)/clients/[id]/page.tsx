import Link from "next/link";
import { Messages } from "@/components/ui/Messages";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Tabs } from "@/components/ui/Tabs";
import { KeyValue } from "@/components/ui/KeyValue";
import { EmptyState } from "@/components/ui/EmptyState";
import { Badge } from "@/components/ui/Badge";
import { FilterBar, type FilterField } from "@/components/ui/FilterBar";
import { Contacts } from "@/components/tiers/Contacts";
import { ChampsClient } from "@/components/tiers/FormulaireClient";
import { statutDevisTone } from "@/lib/badges";
import { formatDate, formatMontant, oui } from "@/lib/format";
import { toStringParams } from "@/lib/list-params";
import { mettreAJourClient } from "../../tiers/actions";

export const dynamic = "force-dynamic";

const ONGLETS = [
  { key: "fiche", label: "Fiche" },
  { key: "sites", label: "Sites" },
  { key: "contacts", label: "Contacts" },
  { key: "devis", label: "Devis" },
  { key: "planifications", label: "Planifications" },
];

export default async function ClientPage({
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
  const { data: client } = await supabase.from("clients").select("*").eq("id", id).maybeSingle();
  if (!client) notFound();

  return (
    <div className="mx-auto flex max-w-5xl flex-col gap-4 p-8">
      <Messages sp={sp} />

      <div className="flex flex-wrap items-center gap-2">
        {!client.actif && <Badge tone="gray">Non affiché</Badge>}
        {client.est_client_fermeture && <Badge tone="red">Pseudo-client des sites fermés</Badge>}
      </div>
      <h1 className="text-xl font-semibold">{client.nom}</h1>

      <Tabs tabs={ONGLETS} active={onglet} searchParams={sp} />

      {onglet === "fiche" && (
        <div className="flex flex-col gap-6">
          <KeyValue
            items={[
              { label: "Adresse", value: `${client.adresse ?? ""} ${client.code_postal ?? ""} ${client.ville ?? ""}`.trim() || "—" },
              { label: "Contact principal", value: client.contact_principal },
              { label: "Téléphone", value: client.telephone },
              { label: "E-mail", value: client.email },
              { label: "Tarif horaire MO", value: formatMontant(client.tarif_heure_mo) },
              { label: "Tarif déplacement", value: formatMontant(client.tarif_deplacement) },
              { label: "N° Esabora maintenance", value: client.numero_esabora_maint },
              { label: "N° Esabora clim", value: client.numero_esabora_clim },
              { label: "Actif", value: oui(client.actif) },
            ]}
          />
          <form action={mettreAJourClient} className="flex flex-col gap-3 rounded-xl border p-4">
            <h2 className="text-sm font-semibold opacity-70">Modifier</h2>
            <input type="hidden" name="client_id" value={id} />
            <ChampsClient client={client} />
            <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
              Enregistrer
            </button>
          </form>
        </div>
      )}

      {onglet === "sites" && <ClientSites clientId={id} numero={sp.numero} />}

      {onglet === "contacts" && <ClientContacts clientId={id} modifierId={sp.modifier} />}

      {onglet === "devis" && <ClientDevis clientId={id} />}

      {onglet === "planifications" && <ClientPlanifications clientId={id} />}
    </div>
  );
}

async function ClientSites({ clientId, numero }: { clientId: string; numero?: string }) {
  const supabase = await createClient();
  let query = supabase.from("sites").select("id, numero_magasin, nom, ville, ferme").eq("client_id", clientId).is("supprime_le", null).order("nom");
  if (numero) query = query.eq("numero_magasin", Number(numero));
  const { data } = await query;

  const filterFields: FilterField[] = [{ type: "text", name: "numero", label: "N° de magasin" }];

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-end justify-between gap-3">
        <FilterBar fields={filterFields} values={{ numero }} />
        <Link href={`/sites/nouveau?client=${clientId}`} className="whitespace-nowrap rounded-md bg-black px-3 py-2 text-sm text-white">
          Nouveau site
        </Link>
      </div>
      {data && data.length > 0 ? (
        <ul className="flex flex-col gap-2">
          {data.map((s) => (
            <li key={s.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
              <Link href={`/sites/${s.id}`} className="underline">
                {s.nom} {s.numero_magasin ? `(n°${s.numero_magasin})` : ""}
              </Link>
              <span className="flex items-center gap-2 opacity-70">
                {s.ferme && <Badge tone="gray">Fermé</Badge>}
                {s.ville}
              </span>
            </li>
          ))}
        </ul>
      ) : (
        <EmptyState message="Aucun site pour ce client." />
      )}
    </div>
  );
}

async function ClientContacts({ clientId, modifierId }: { clientId: string; modifierId?: string }) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("contacts")
    .select("id, nom, prenom, civilite, fonction, email, telephone, mobile, fax, observations")
    .eq("client_id", clientId)
    .order("nom");

  return <Contacts contacts={data ?? []} parent={{ client_id: Number(clientId) }} modifierId={modifierId} retour={`/clients/${clientId}?onglet=contacts`} />;
}

async function ClientDevis({ clientId }: { clientId: string }) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("devis")
    .select("id, famille, numero, statut_code, montant_ht, date_devis")
    .eq("client_id", clientId)
    .is("supprime_le", null)
    .order("date_devis", { ascending: false });

  if (!data || data.length === 0) return <EmptyState message="Aucun devis pour ce client." />;

  return (
    <ul className="flex flex-col gap-2">
      {data.map((d) => (
        <li key={d.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
          <Link href={`/devis/${d.id}`} className="capitalize underline">
            {d.famille} · {d.numero ?? `#${d.id}`}
          </Link>
          <span className="flex items-center gap-2">
            <Badge tone={statutDevisTone(d.statut_code)}>{d.statut_code}</Badge>
            {formatMontant(d.montant_ht)} · {formatDate(d.date_devis)}
          </span>
        </li>
      ))}
    </ul>
  );
}

async function ClientPlanifications({ clientId }: { clientId: string }) {
  const supabase = await createClient();
  const { data } = await supabase.from("planifications").select("id, rang, date_limite, nombre_visites").eq("client_id", clientId).order("date_limite");

  if (!data || data.length === 0) return <EmptyState message="Aucune planification." />;

  return (
    <table className="w-full border-collapse text-sm">
      <thead>
        <tr className="border-b text-left">
          <th className="py-1">Rang</th>
          <th>Date limite</th>
          <th>Nombre de visites</th>
        </tr>
      </thead>
      <tbody>
        {data.map((p) => (
          <tr key={p.id} className="border-b">
            <td className="py-1">{p.rang}</td>
            <td>{formatDate(p.date_limite)}</td>
            <td>{p.nombre_visites ?? "—"}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
