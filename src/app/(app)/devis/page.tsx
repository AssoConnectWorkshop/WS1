import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { parseListParams, toStringParams } from "@/lib/list-params";
import { DataTable, type Column } from "@/components/ui/DataTable";
import { FilterBar, type FilterField } from "@/components/ui/FilterBar";
import { Badge } from "@/components/ui/Badge";
import { Tabs } from "@/components/ui/Tabs";
import { statutDevisTone } from "@/lib/badges";
import { formatDate, formatMontant } from "@/lib/format";

export const dynamic = "force-dynamic";

type DevisRow = {
  id: number;
  numero: string | null;
  statut_code: number | null;
  famille: string;
  site_id: number | null;
  client_id: number | null;
  montant_ht: number | null;
  envoye_par_id: number | null;
  date_envoi: string | null;
  fichier_chemin: string | null;
  intervention_origine_id: number | null;
  type_panne_libelle: string | null;
};

const FAMILLES = [
  { key: "sav", label: "SAV" },
  { key: "travaux", label: "Travaux" },
  { key: "contrat", label: "Contrats" },
];

export default async function DevisPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const sp = toStringParams(await searchParams);
  const famille = FAMILLES.some((f) => f.key === sp.onglet) ? sp.onglet! : "sav";
  const supabase = await createClient();
  const { page, sort, dir, from, to, pageSize } = parseListParams(sp, "date_devis", 50);

  const [{ data: statuts }, { data: utilisateurs }] = await Promise.all([
    supabase.from("statuts_devis").select("code, libelle").order("code"),
    supabase.from("utilisateurs").select("id, nom").order("nom"),
  ]);

  let query = supabase
    .from("devis")
    .select("id, numero, statut_code, famille, site_id, client_id, montant_ht, envoye_par_id, date_envoi, fichier_chemin, intervention_origine_id, type_panne_libelle, sites(nom), clients(nom)", {
      count: "exact",
    })
    .eq("famille", famille);

  if (sp.client) query = query.eq("client_id", Number(sp.client));
  if (sp.site) query = query.eq("site_id", Number(sp.site));
  if (sp.statut) query = query.eq("statut_code", Number(sp.statut));
  if (sp.panne) query = query.ilike("type_panne_libelle", `%${sp.panne}%`);
  if (sp.envoye_par) query = query.eq("envoye_par_id", Number(sp.envoye_par));
  if (sp.periode_debut) query = query.gte("date_envoi", sp.periode_debut);
  if (sp.periode_fin) query = query.lte("date_envoi", sp.periode_fin);

  query = query.order(sort, { ascending: dir === "asc" }).range(from, to);
  const { data, count } = await query;
  const rows = (data ?? []) as unknown as (DevisRow & { sites: { nom: string } | null; clients: { nom: string } | null })[];

  const numeros = rows.map((r) => r.numero).filter((n): n is string => !!n);
  const { data: generees } = numeros.length
    ? await supabase.from("interventions").select("id, numero_devis_accepte").in("numero_devis_accepte", numeros)
    : { data: [] };
  const genereeParNumero = new Map((generees ?? []).map((i) => [i.numero_devis_accepte, i.id]));

  const filterFields: FilterField[] = [
    { type: "text", name: "client", label: "Client (id)" },
    { type: "text", name: "site", label: "Site (id)" },
    { type: "select", name: "statut", label: "Statut", options: (statuts ?? []).map((s) => ({ value: String(s.code), label: s.libelle })) },
    { type: "text", name: "panne", label: "Type de panne" },
    { type: "select", name: "envoye_par", label: "Envoyé par", options: (utilisateurs ?? []).map((u) => ({ value: String(u.id), label: u.nom ?? "" })) },
    { type: "date", name: "periode_debut", label: "Envoyé du" },
    { type: "date", name: "periode_fin", label: "Envoyé au" },
  ];

  const columns: Column<(typeof rows)[number]>[] = [
    { key: "numero", label: "Numéro", render: (r) => r.numero ?? "—" },
    { key: "statut_code", label: "Statut", render: (r) => <Badge tone={statutDevisTone(r.statut_code)}>{statuts?.find((s) => s.code === r.statut_code)?.libelle ?? r.statut_code}</Badge> },
    { key: "site", label: "Site", render: (r) => (r.site_id ? <Link className="hover:underline" href={`/sites/${r.site_id}`}>{r.sites?.nom}</Link> : "—") },
    { key: "client", label: "Client", render: (r) => (r.client_id ? <Link className="hover:underline" href={`/clients/${r.client_id}`}>{r.clients?.nom}</Link> : "—") },
    { key: "montant_ht", label: "Montant HT", align: "right", render: (r) => formatMontant(r.montant_ht) },
    { key: "date_envoi", label: "Date d'envoi", sortable: true, render: (r) => formatDate(r.date_envoi) },
    { key: "fichier_chemin", label: "Fichier", render: (r) => (r.fichier_chemin ? <span className="font-mono text-xs">{r.fichier_chemin}</span> : "—") },
    {
      key: "intervention_origine_id",
      label: "Intervention d'origine",
      render: (r) => (r.intervention_origine_id ? <Link className="hover:underline" href={`/interventions/${r.intervention_origine_id}`}>#{r.intervention_origine_id}</Link> : "—"),
    },
    {
      key: "intervention_generee",
      label: "Intervention générée",
      render: (r) => {
        const genId = r.numero ? genereeParNumero.get(r.numero) : null;
        return genId ? (
          <Link className="hover:underline" href={`/interventions/${genId}`}>
            #{genId}
          </Link>
        ) : (
          "—"
        );
      },
    },
  ];

  return (
    <div className="mx-auto flex max-w-7xl flex-col gap-4 p-8">
      <h1 className="text-2xl font-bold">Devis</h1>
      <Tabs tabs={FAMILLES} active={famille} searchParams={sp} />
      <FilterBar fields={filterFields} values={sp} />
      <DataTable columns={columns} rows={rows} searchParams={sp} total={count ?? 0} page={page} pageSize={pageSize} emptyMessage="Aucun devis." />
    </div>
  );
}
