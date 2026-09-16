import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { parseListParams, toStringParams } from "@/lib/list-params";
import { DataTable, type Column } from "@/components/ui/DataTable";
import { FilterBar, type FilterField } from "@/components/ui/FilterBar";
import { formatMontant } from "@/lib/format";
import { CaseInstantanee } from "@/components/ui/CaseInstantanee";

export const dynamic = "force-dynamic";

type ClientRow = {
  id: number;
  nom: string;
  adresse: string | null;
  code_postal: string | null;
  ville: string | null;
  telephone: string | null;
  fax: string | null;
  email: string | null;
  contact_principal: string | null;
  tarif_heure_mo: number | null;
  tarif_deplacement: number | null;
  numero_esabora_maint: string | null;
  numero_esabora_clim: string | null;
  actif: boolean;
};

export default async function ClientsPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const sp = toStringParams(await searchParams);
  // Règle Form_Client.lstClient : un nombre saisi est un numéro de magasin, un texte un nom de client.
  if (sp.q && sp.q.trim() !== "" && Number.isFinite(Number(sp.q))) redirect(`/sites?q=${encodeURIComponent(sp.q.trim())}`);
  const supabase = await createClient();
  const { page, sort, dir, from, to, pageSize } = parseListParams(sp, "nom_tri", 50);

  let query = supabase.from("clients").select("*", { count: "exact" });
  if (sp.tous !== "1") query = query.eq("actif", true);
  if (sp.q) query = query.ilike("nom", `%${sp.q}%`);
  query = query.order(sort, { ascending: dir === "asc" }).range(from, to);

  const { data, count } = await query;
  const rows = (data ?? []) as ClientRow[];

  const filterFields: FilterField[] = [
    { type: "text", name: "q", label: "Rechercher (N° de site ou Nom de client)" },
    { type: "checkbox", name: "tous", label: "Afficher tous les clients (y compris non affichés)" },
  ];

  // Colonnes de la liste Access « Listeclientaffiche », dans le même ordre.
  const columns: Column<ClientRow>[] = [
    { key: "nom_tri", label: "Nom du client", sortable: true, render: (r) => <Link className="hover:underline" href={`/clients/${r.id}`}>{r.nom}</Link> },
    { key: "adresse", label: "Adresse", render: (r) => <span className="block max-w-[16rem] truncate" title={r.adresse ?? ""}>{r.adresse ?? ""}</span> },
    { key: "code_postal", label: "CP", sortable: true, render: (r) => r.code_postal ?? "" },
    { key: "ville", label: "Ville", sortable: true, render: (r) => r.ville ?? "" },
    { key: "telephone", label: "Téléphone", render: (r) => r.telephone ?? "" },
    { key: "fax", label: "Fax", render: (r) => r.fax ?? "" },
    { key: "contact_principal", label: "Contact", render: (r) => r.contact_principal ?? "" },
    { key: "email", label: "E-mail", render: (r) => (r.email ? <a href={`mailto:${r.email}`} className="hover:underline">{r.email}</a> : "") },
    { key: "tarif_heure_mo", label: "Main d'oeuvre", align: "right", render: (r) => (r.tarif_heure_mo != null ? formatMontant(r.tarif_heure_mo) : "") },
    { key: "tarif_deplacement", label: "Déplacement", align: "right", render: (r) => (r.tarif_deplacement != null ? formatMontant(r.tarif_deplacement) : "") },
    { key: "actif", label: "Affiché", align: "center", render: (r) => <CaseInstantanee table="clients" id={r.id} champ="actif" valeur={r.actif} label="Client affiché" /> },
    { key: "numero_esabora_clim", label: "Num Esabora Clim", render: (r) => r.numero_esabora_clim ?? "" },
    { key: "numero_esabora_maint", label: "Num Esabora Maint", render: (r) => r.numero_esabora_maint ?? "" },
  ];

  return (
    <div className="flex flex-col gap-3 p-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold">Clients</h1>
        <Link href="/clients/nouveau" className="rounded-md bg-black px-3 py-2 text-sm text-white">
          Nouveau client
        </Link>
      </div>
      <FilterBar fields={filterFields} values={sp} />
      <DataTable columns={columns} rows={rows} searchParams={sp} total={count ?? 0} page={page} pageSize={pageSize} emptyMessage="Aucun client." hrefLigne={(r) => `/clients/${r.id}`} />
    </div>
  );
}
