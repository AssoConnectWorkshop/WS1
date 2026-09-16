import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { parseListParams, toStringParams } from "@/lib/list-params";
import { DataTable, type Column } from "@/components/ui/DataTable";
import { Badge } from "@/components/ui/Badge";
import { Chemin } from "@/components/ui/Chemin";
import { typeInterventionTone, statutInterventionTone } from "@/lib/badges";
import { formatDate, formatNombre } from "@/lib/format";

export const dynamic = "force-dynamic";

type Ligne = {
  id: number;
  site_id: number;
  site_nom: string | null;
  client_nom: string | null;
  type_code: number | null;
  type_libelle: string | null;
  statut_code: number | null;
  statut_libelle: string | null;
  charge_affaire_nom: string | null;
  date_realisee: string | null;
  intervenant_id: number | null;
  intervenant_nom: string | null;
  sous_type_libelle: string | null;
  fluide_libelle: string | null;
  quantite_gaz_kg: number | null;
  chemin_dossier_etancheite: string | null;
  chemin_bon_pdf: string | null;
  numero_bon: number | null;
};

const CHAMP = "w-full rounded border bg-white px-1.5 py-0.5 text-xs dark:bg-white/5";

/** « Utilisation FF » du menu Access (Form_ListeInterGaz, analysis 02 §8.2) : interventions avec quantité de gaz saisie, somme des kg. */
export default async function GazPage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();
  const { page, sort, dir, from, to, pageSize } = parseListParams(sp, "date_realisee", 50);

  const [{ data: clients }, { data: statuts }, { data: intervenants }, { data: types }, { data: fluides }] = await Promise.all([
    supabase.from("clients").select("id, nom").eq("actif", true).is("supprime_le", null).order("nom"),
    supabase.from("statuts_intervention").select("code, libelle").eq("actif", true).order("ordre_affichage"),
    supabase.from("intervenants").select("id, nom").order("nom"),
    supabase.from("types_intervention").select("code, libelle").order("ordre_affichage"),
    supabase.from("types_fluide").select("code, libelle").order("libelle"),
  ]);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const filtrer = (q: any) => {
    q = q.not("quantite_gaz_kg", "is", null).neq("quantite_gaz_kg", 0);
    if (sp.client_id) q = q.eq("client_id", Number(sp.client_id));
    if (sp.statut) q = q.eq("statut_code", Number(sp.statut));
    if (sp.intervenant) q = q.eq("intervenant_id", Number(sp.intervenant));
    if (sp.type) q = q.eq("type_code", Number(sp.type));
    if (sp.fluide) q = q.eq("fluide_libelle", sp.fluide);
    if (sp.debut) q = q.gte("date_realisee", sp.debut);
    if (sp.fin) q = q.lte("date_realisee", sp.fin);
    if (sp.site) {
      const n = Number(sp.site);
      q = Number.isFinite(n) && sp.site.trim() !== "" ? q.or(`numero_magasin.eq.${n},site_nom.ilike.%${sp.site}%`) : q.ilike("site_nom", `%${sp.site}%`);
    }
    return q;
  };

  const { data, count, error } = await filtrer(supabase.from("v_interventions_liste").select("*", { count: "exact" }))
    .order(sort, { ascending: dir === "desc" ? false : true, nullsFirst: false })
    .range(from, to);
  if (error) console.error("v_interventions_liste (gaz)", error);
  const rows = (data ?? []) as Ligne[];

  const { data: sommeRows } = await filtrer(supabase.from("v_interventions_liste").select("quantite_gaz_kg"));
  const somme = ((sommeRows ?? []) as { quantite_gaz_kg: number | null }[]).reduce((t, r) => t + Number(r.quantite_gaz_kg ?? 0), 0);

  const columns: Column<Ligne>[] = [
    { key: "statut_libelle", label: "Statut", render: (r) => <Badge tone={statutInterventionTone(r.statut_code)}>{r.statut_libelle ?? "—"}</Badge> },
    { key: "type_libelle", label: "Type", render: (r) => <Badge tone={typeInterventionTone(r.type_code)}>{r.type_libelle ?? "—"}</Badge> },
    { key: "charge_affaire_nom", label: "Traitée par", render: (r) => r.charge_affaire_nom ?? "" },
    { key: "date_realisee", label: "Effectuée le", sortable: true, render: (r) => formatDate(r.date_realisee).replace("—", "") },
    { key: "intervenant_nom", label: "Intervenant", render: (r) => (r.intervenant_id ? <Link className="hover:underline" href={`/intervenants/${r.intervenant_id}`}>{r.intervenant_nom}</Link> : "") },
    { key: "sous_type_libelle", label: "Sous Type", render: (r) => r.sous_type_libelle ?? "" },
    { key: "fluide_libelle", label: "Type Gaz", render: (r) => r.fluide_libelle ?? "" },
    { key: "quantite_gaz_kg", label: "Qté Gaz (kg)", sortable: true, align: "right", render: (r) => formatNombre(r.quantite_gaz_kg) },
    { key: "chemin_dossier_etancheite", label: "Lien CE", render: (r) => (r.chemin_dossier_etancheite ? <Chemin value={r.chemin_dossier_etancheite} /> : "") },
    { key: "numero_bon", label: "Bon", render: (r) => <Link href={`/interventions/${r.id}`} className="underline">{r.numero_bon ?? r.id}</Link> },
    { key: "site_nom", label: "Lien vers Site", sortable: true, render: (r) => <Link href={`/sites/${r.site_id}`} className="hover:underline">{r.site_nom}</Link> },
    { key: "client_nom", label: "Client", render: (r) => r.client_nom ?? "" },
  ];

  const LIGNE = "grid grid-cols-[7rem_1fr] items-center gap-x-2 gap-y-1 text-xs";
  const opt = (rows: { value: string; label: string }[]) =>
    rows.map((o) => (
      <option key={o.value} value={o.value}>
        {o.label}
      </option>
    ));

  return (
    <div className="flex flex-col gap-3 p-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold">Utilisation des fluides frigorigènes</h1>
        <Link href="/" className="rounded bg-red-600 px-3 py-1 text-xs text-white" title="Retour au menu">
          ✕
        </Link>
      </div>
      <form method="GET" className="grid gap-3 rounded border p-3 lg:grid-cols-[18rem_18rem_18rem_auto]">
        <div className={LIGNE}>
          <span className="text-right">Client</span>
          <select name="client_id" defaultValue={sp.client_id ?? ""} className={CHAMP}>
            <option value=""></option>
            {opt((clients ?? []).map((c) => ({ value: String(c.id), label: c.nom ?? "" })))}
          </select>
          <span className="text-right">N° Site ou Nom</span>
          <input name="site" defaultValue={sp.site ?? ""} className={CHAMP} />
          <span className="text-right">Statut</span>
          <select name="statut" defaultValue={sp.statut ?? ""} className={CHAMP}>
            <option value=""></option>
            {opt((statuts ?? []).map((s) => ({ value: String(s.code), label: s.libelle })))}
          </select>
        </div>
        <div className={LIGNE}>
          <span className="text-right">Intervenant</span>
          <select name="intervenant" defaultValue={sp.intervenant ?? ""} className={CHAMP}>
            <option value=""></option>
            {opt((intervenants ?? []).map((i) => ({ value: String(i.id), label: i.nom ?? "" })))}
          </select>
          <span className="text-right">Type Inter.</span>
          <select name="type" defaultValue={sp.type ?? ""} className={CHAMP}>
            <option value="">Toutes</option>
            {opt((types ?? []).map((t) => ({ value: String(t.code), label: t.libelle })))}
          </select>
          <span className="text-right">Type Gaz</span>
          <select name="fluide" defaultValue={sp.fluide ?? ""} className={CHAMP}>
            <option value=""></option>
            {opt((fluides ?? []).map((f) => ({ value: f.libelle, label: f.libelle })))}
          </select>
        </div>
        <div className={LIGNE}>
          <span className="text-right">Effectuée entre le</span>
          <input type="date" name="debut" defaultValue={sp.debut ?? ""} className={CHAMP} />
          <span className="text-right">et</span>
          <input type="date" name="fin" defaultValue={sp.fin ?? ""} className={CHAMP} />
        </div>
        <div className="flex flex-col gap-2 text-xs">
          <button type="submit" className="rounded border bg-black px-3 py-1 text-white">
            Rechercher
          </button>
          <span className="rounded border bg-white px-2 py-1 font-semibold dark:bg-white/5">Somme = {formatNombre(Math.round(somme * 100) / 100)} kg</span>
        </div>
      </form>
      <DataTable columns={columns} rows={rows} searchParams={sp} total={count ?? 0} page={page} pageSize={pageSize} emptyMessage="Rien trouvé." erreur={error?.message} hrefLigne={(r) => `/interventions/${r.id}`} />
    </div>
  );
}
