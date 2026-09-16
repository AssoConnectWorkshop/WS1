import Link from "next/link";
import { Messages } from "@/components/ui/Messages";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Tabs } from "@/components/ui/Tabs";
import { EmptyState } from "@/components/ui/EmptyState";
import { Badge } from "@/components/ui/Badge";
import { Contacts } from "@/components/tiers/Contacts";
import { Case, Champ, CHAMP } from "@/components/ui/Champ";
import { statutDevisTone } from "@/lib/badges";
import { formatDate, formatMontant } from "@/lib/format";
import { toStringParams } from "@/lib/list-params";
import { mettreAJourClient } from "../../tiers/actions";

export const dynamic = "force-dynamic";

/** Onglets de la fiche Access (Form_Client : Sites, Contacts, Devis) suivis des compléments de l'application. */
const ONGLETS = [
  { key: "sites", label: "Sites" },
  { key: "contacts", label: "Contacts" },
  { key: "devis", label: "Devis" },
  { key: "planifications", label: "Planifications" },
  { key: "exports", label: "Exports Excel" },
];

const PETIT = "w-full rounded border bg-white px-1.5 py-0.5 text-sm dark:bg-white/5";
const BOUTON = "rounded border bg-white px-2 py-1 text-xs dark:bg-white/5";
const LIGNE = "grid grid-cols-[9rem_1fr] items-center gap-x-2 gap-y-1 text-xs";

export default async function ClientPage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { id } = await params;
  const sp = toStringParams(await searchParams);
  const onglet = ONGLETS.some((o) => o.key === sp.onglet) ? sp.onglet! : "sites";

  const supabase = await createClient();
  const { data: client } = await supabase.from("clients").select("*").eq("id", id).maybeSingle();
  if (!client) notFound();

  return (
    <div className="flex flex-col gap-3 p-4">
      <Messages sp={sp} />

      {/* En-tête Access : recherche, Créer un nouveau client, Planifier les entretiens, carte */}
      <form method="GET" action="/clients" className="flex flex-wrap items-center gap-2 text-sm">
        <span className="font-bold">Rechercher (N° de site ou Nom de client)</span>
        <input name="q" className="w-64 rounded border px-1.5 py-0.5 text-sm" />
        <Link href="/clients/nouveau" className={BOUTON}>
          Créer un nouveau client
        </Link>
        <Link href={`/planification?client_id=${id}`} className={BOUTON}>
          Planifier les entretiens
        </Link>
        <Link href={`/carte?client=${encodeURIComponent(client.nom ?? "")}`} className={BOUTON} title="Carte des interventions du client">
          🌍
        </Link>
        <span className="ml-auto flex items-center gap-2">
          {!client.actif && <Badge tone="gray">Non affiché</Badge>}
          {client.est_client_fermeture && <Badge tone="red">Pseudo-client des sites fermés</Badge>}
          <Link href="/clients" className="rounded bg-red-600 px-3 py-1 text-xs text-white" title="Fermer la fiche">
            ✕
          </Link>
        </span>
      </form>

      <form action={mettreAJourClient} className="grid gap-3 lg:grid-cols-[28rem_1fr]">
        <input type="hidden" name="client_id" value={id} />
        <div className={LIGNE}>
          <span className="text-right">Nom</span>
          <div className="flex items-center gap-2">
            <input name="nom" required defaultValue={client.nom ?? ""} className={PETIT} />
            <Link href={`/sites/nouveau?client=${id}`} className={`${BOUTON} whitespace-nowrap`}>
              Créer un nouveau site
            </Link>
          </div>
          <span className="text-right">Adresse</span>
          <input name="adresse" defaultValue={client.adresse ?? ""} className={PETIT} />
          <span className="text-right">Code postal</span>
          <div className="grid grid-cols-[6rem_auto_1fr] items-center gap-2">
            <input name="code_postal" defaultValue={client.code_postal ?? ""} className={PETIT} />
            <span>Ville</span>
            <input name="ville" defaultValue={client.ville ?? ""} className={PETIT} />
          </div>
          <span className="text-right">Téléphone</span>
          <input name="telephone" defaultValue={client.telephone ?? ""} className={`${PETIT} max-w-48`} />
          <span className="text-right">Fax</span>
          <input name="fax" defaultValue={client.fax ?? ""} className={`${PETIT} max-w-48`} />
          <span className="text-right">Contact principal</span>
          <input name="contact_principal" defaultValue={client.contact_principal ?? ""} className={PETIT} />
          <span className="text-right">E-mail</span>
          <input name="email" type="email" defaultValue={client.email ?? ""} className={PETIT} />
          <span className="text-right">Tarif heure Main oeuvre</span>
          <div className="grid grid-cols-[6rem_auto_1fr] items-center gap-2">
            <input name="tarif_heure_mo" type="number" step="0.01" defaultValue={client.tarif_heure_mo ?? ""} className={PETIT} />
            <span>Numéro Esa Clim</span>
            <input name="numero_esabora_clim" defaultValue={client.numero_esabora_clim ?? ""} className={`${PETIT} max-w-40`} />
          </div>
          <span className="text-right">Tarif d&apos;un déplacement</span>
          <div className="grid grid-cols-[6rem_auto_1fr] items-center gap-2">
            <input name="tarif_deplacement" type="number" step="0.01" defaultValue={client.tarif_deplacement ?? ""} className={PETIT} />
            <span>Numéro Esa Maint</span>
            <input name="numero_esabora_maint" defaultValue={client.numero_esabora_maint ?? ""} className={`${PETIT} max-w-40`} />
          </div>
        </div>
        <div className="flex flex-col gap-2 text-xs">
          <Champ label="Délai d'intervention (h)">
            <input name="delai_intervention_heures" type="number" step="0.5" defaultValue={client.delai_intervention_heures ?? ""} className={`${PETIT} max-w-32`} />
          </Champ>
          <Case name="actif" label="Client affiché (actif)" checked={client.actif ?? true} />
          <button type="submit" className="w-fit rounded bg-black px-3 py-1 text-xs text-white">
            💾 Enregistrer
          </button>
        </div>
      </form>

      <Tabs tabs={ONGLETS} active={onglet} searchParams={sp} />

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

/** Onglet « Sites » Access (Site sous-formulaire Client) : N° de magasin, Site, Situation, Adresse, CP, Ville. */
async function ClientSites({ clientId, numero }: { clientId: string; numero?: string }) {
  const supabase = await createClient();
  let query = supabase.from("sites").select("id, numero_magasin, nom, situation, adresse, code_postal, ville, ferme").eq("client_id", clientId).is("supprime_le", null).order("nom").order("numero_magasin");
  if (numero) query = query.eq("numero_magasin", Number(numero));
  const { data } = await query;

  return (
    <div className="flex flex-col gap-2">
      <form method="GET" className="flex items-center gap-2 text-xs">
        <input type="hidden" name="onglet" value="sites" />
        <span>N° de magasin</span>
        <input name="numero" defaultValue={numero ?? ""} className="w-24 rounded border px-1.5 py-0.5" />
        <button type="submit" className={BOUTON}>
          Rechercher
        </button>
      </form>
      {data && data.length > 0 ? (
        <div className="overflow-x-auto rounded border">
          <table className="w-full border-collapse text-xs">
            <thead>
              <tr className="border-b bg-black/[0.03] text-left dark:bg-white/[0.05]">
                {["N° de magasin", "Site", "Situation", "Adresse", "CP", "Ville"].map((h) => (
                  <th key={h} className="whitespace-nowrap px-2 py-1 font-medium">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {data.map((s) => (
                <tr key={s.id} className="border-b last:border-0 hover:bg-blue-100 dark:hover:bg-blue-950/40">
                  <td className="px-2 py-1 text-right">{s.numero_magasin ?? ""}</td>
                  <td className="px-2 py-1">
                    <Link href={`/sites/${s.id}`} className="hover:underline">
                      {s.nom}
                    </Link>
                    {s.ferme && (
                      <span className="ml-2">
                        <Badge tone="gray">Fermé</Badge>
                      </span>
                    )}
                  </td>
                  <td className="max-w-[10rem] truncate px-2 py-1" title={s.situation ?? ""}>
                    {s.situation ?? ""}
                  </td>
                  <td className="px-2 py-1">{s.adresse ?? ""}</td>
                  <td className="px-2 py-1">{s.code_postal ?? ""}</td>
                  <td className="px-2 py-1">{s.ville ?? ""}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <EmptyState message="Aucun site pour ce client." />
      )}
      <div className="text-xs opacity-70">Enr : {data?.length ?? 0}</div>
    </div>
  );
}

async function ClientContacts({ clientId, modifierId }: { clientId: string; modifierId?: string }) {
  const supabase = await createClient();
  const { data } = await supabase.from("contacts").select("id, nom, prenom, civilite, fonction, email, telephone, mobile, fax, observations").eq("client_id", clientId).order("nom");

  return <Contacts contacts={data ?? []} parent={{ client_id: Number(clientId) }} modifierId={modifierId} retour={`/clients/${clientId}?onglet=contacts`} />;
}

async function ClientDevis({ clientId }: { clientId: string }) {
  const supabase = await createClient();
  const [{ data }, { data: statuts }] = await Promise.all([
    supabase.from("devis").select("id, famille, numero, statut_code, montant_ht, date_devis, date_envoi, sites(nom)").eq("client_id", clientId).is("supprime_le", null).order("date_envoi", { ascending: false, nullsFirst: false }),
    supabase.from("statuts_devis").select("code, libelle"),
  ]);
  const libelle = (code: number | null) => statuts?.find((s) => s.code === code)?.libelle ?? "";

  if (!data || data.length === 0) return <EmptyState message="Aucun devis pour ce client." />;

  return (
    <div className="overflow-x-auto rounded border">
      <table className="w-full border-collapse text-xs">
        <thead>
          <tr className="border-b bg-black/[0.03] text-left dark:bg-white/[0.05]">
            {["N° Devis", "Famille", "Site", "Etat", "Envoyé le", "Montant HT"].map((h) => (
              <th key={h} className="whitespace-nowrap px-2 py-1 font-medium">
                {h}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {(data as unknown as { id: number; famille: string; numero: string | null; statut_code: number | null; montant_ht: number | null; date_envoi: string | null; sites: { nom: string | null } | null }[]).map((d) => (
            <tr key={d.id} className="border-b last:border-0 hover:bg-blue-100 dark:hover:bg-blue-950/40">
              <td className="px-2 py-1">
                <Link href={`/devis/${d.id}`} className="underline">
                  {d.numero ?? `#${d.id}`}
                </Link>
              </td>
              <td className="px-2 py-1 capitalize">{d.famille}</td>
              <td className="px-2 py-1">{d.sites?.nom ?? ""}</td>
              <td className="px-2 py-1">
                <Badge tone={statutDevisTone(d.statut_code)}>{libelle(d.statut_code)}</Badge>
              </td>
              <td className="px-2 py-1">{formatDate(d.date_envoi).replace("—", "")}</td>
              <td className="px-2 py-1 text-right">{formatMontant(d.montant_ht)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
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
