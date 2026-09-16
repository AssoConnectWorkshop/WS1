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
import { Case, Champ, CHAMP } from "@/components/ui/Champ";
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
  { key: "exports", label: "Exports Excel" },
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

      {onglet === "exports" && <ClientExports clientId={id} />}
    </div>
  );
}

async function ClientExports({ clientId }: { clientId: string }) {
  const supabase = await createClient();
  const [{ data: types }, { data: statuts }] = await Promise.all([
    supabase.from("types_intervention").select("code, libelle").order("ordre_affichage"),
    supabase.from("statuts_intervention").select("code, libelle").eq("actif", true).order("ordre_affichage"),
  ]);
  const annee = new Date().getFullYear();

  return (
    <div className="grid gap-4 lg:grid-cols-2">
      <form method="GET" action={`/clients/${clientId}/bilan.xlsx`} className="flex flex-col gap-3 rounded-xl border p-4">
        <h2 className="text-sm font-semibold opacity-70">Bilan client (28 colonnes)</h2>
        <p className="text-xs opacity-60">Interventions sur la date réalisée, devis sur la date d&apos;envoi ; statuts annulé et résolu par téléphone exclus des comptages.</p>
        <div className="grid grid-cols-2 gap-3">
          <Champ label="Du">
            <input name="debut" type="date" className={CHAMP} />
          </Champ>
          <Champ label="Au">
            <input name="fin" type="date" className={CHAMP} />
          </Champ>
        </div>
        <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
          Télécharger le bilan
        </button>
      </form>

      <form method="GET" action={`/clients/${clientId}/comptage.xlsx`} className="flex flex-col gap-3 rounded-xl border p-4">
        <h2 className="text-sm font-semibold opacity-70">Comptage et montants par site</h2>
        <p className="text-xs opacity-60">Période sur la date limite. L&apos;année est prioritaire sur la période ; « par mois » produit une feuille par mois.</p>
        <div className="grid grid-cols-3 gap-3">
          <Champ label="Année">
            <input name="annee" type="number" min={2000} max={2100} placeholder={String(annee)} className={CHAMP} />
          </Champ>
          <Champ label="Mois">
            <select name="mois" className={CHAMP}>
              <option value="0">Tous</option>
              {Array.from({ length: 12 }, (_, i) => i + 1).map((m) => (
                <option key={m} value={m}>
                  {m}
                </option>
              ))}
            </select>
          </Champ>
          <div className="flex items-end pb-2">
            <Case name="par_mois" label="Une feuille par mois" />
          </div>
          <Champ label="Du">
            <input name="debut" type="date" className={CHAMP} />
          </Champ>
          <Champ label="Au">
            <input name="fin" type="date" className={CHAMP} />
          </Champ>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <Champ label="Types (plusieurs possibles)">
            <select name="types" multiple size={5} className={CHAMP}>
              {(types ?? []).map((t) => (
                <option key={t.code} value={t.code}>
                  {t.libelle}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="Statuts (plusieurs possibles)">
            <select name="statuts" multiple size={5} className={CHAMP}>
              {(statuts ?? []).map((s) => (
                <option key={s.code} value={s.code}>
                  {s.libelle}
                </option>
              ))}
            </select>
          </Champ>
        </div>
        <div className="grid grid-cols-4 gap-3">
          {[1, 2, 3, 4].map((n) => (
            <Champ key={n} label={`Motif de nom ${n}`}>
              <input name={`nom${n}`} placeholder={["CREMATORIUM", "POINT DE VENTE", "CHAMBRE FUNÉRAIRE", "DÉPÔT"][n - 1]} className={CHAMP} />
            </Champ>
          ))}
        </div>
        <p className="text-xs opacity-60">Avec des motifs de nom, une ligne par motif somme tous les sites dont le nom le contient.</p>
        <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
          Télécharger le comptage
        </button>
      </form>

      <div className="flex flex-col gap-3 rounded-xl border p-4">
        <h2 className="text-sm font-semibold opacity-70">Parc matériel</h2>
        <p className="text-xs opacity-60">Une ligne par équipement, sites sans matériel inclus.</p>
        <a href={`/clients/${clientId}/materiel.xlsx`} className="w-fit rounded-md border px-4 py-1.5 text-sm">
          Télécharger le parc matériel
        </a>
      </div>
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
