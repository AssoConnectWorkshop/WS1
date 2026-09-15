import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Tabs } from "@/components/ui/Tabs";
import { KeyValue } from "@/components/ui/KeyValue";
import { EmptyState } from "@/components/ui/EmptyState";
import { formatMontant, oui } from "@/lib/format";
import { toStringParams } from "@/lib/list-params";

export const dynamic = "force-dynamic";

const ONGLETS = [
  { key: "sites", label: "Sites en contrat" },
  { key: "historique", label: "Historique interventions" },
  { key: "techniciens", label: "Techniciens" },
];

export default async function IntervenantPage({
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
  const { data: intervenant } = await supabase.from("intervenants").select("*").eq("id", id).maybeSingle();
  if (!intervenant) notFound();

  const [{ data: zones }, { data: activites }] = await Promise.all([
    supabase.from("intervenant_zones").select("rang, zones_geographiques(libelle)").eq("intervenant_id", id).order("rang"),
    supabase.from("intervenant_activites").select("rang, tarif_mo, tarif_deplacement, activites(libelle)").eq("intervenant_id", id).order("rang"),
  ]);

  return (
    <div className="mx-auto flex max-w-5xl flex-col gap-4 p-8">
      <h1 className="text-xl font-semibold">
        {intervenant.nom} <span className="text-sm font-normal opacity-60">({intervenant.code})</span>
      </h1>

      <KeyValue
        items={[
          { label: "Adresse", value: `${intervenant.adresse ?? ""} ${intervenant.code_postal ?? ""} ${intervenant.ville ?? ""}`.trim() || "—" },
          { label: "Téléphone", value: intervenant.telephone },
          { label: "E-mail", value: intervenant.email },
          { label: "Dirigeant", value: intervenant.dirigeant_nom },
          { label: "Sous-traitant FMC", value: oui(intervenant.est_sous_traitant) },
          { label: "Ponctuel", value: oui(intervenant.est_sous_traitant_ponctuel) },
          { label: "Technicien interne", value: oui(intervenant.est_technicien_interne) },
          { label: "Ne plus intervenir", value: oui(intervenant.ne_plus_intervenir) },
          { label: "N'existe plus", value: oui(intervenant.n_existe_plus) },
          { label: "Note maintenance", value: intervenant.note_maintenance ? "★".repeat(intervenant.note_maintenance) : "—" },
          { label: "Note dépannage", value: intervenant.note_depannage ? "★".repeat(intervenant.note_depannage) : "—" },
          { label: "Note travaux", value: intervenant.note_travaux ? "★".repeat(intervenant.note_travaux) : "—" },
          {
            label: "Zones",
            value:
              zones && zones.length > 0
                ? (zones as unknown as { zones_geographiques: { libelle: string } | null }[]).map((z) => z.zones_geographiques?.libelle).filter(Boolean).join(", ")
                : "—",
          },
        ]}
      />

      <div>
        <h2 className="mb-2 text-sm font-semibold opacity-70">Activités et tarifs</h2>
        {activites && activites.length > 0 ? (
          <table className="w-full border-collapse text-sm">
            <thead>
              <tr className="border-b text-left">
                <th className="py-1">Activité</th>
                <th className="text-right">Tarif MO</th>
                <th className="text-right">Tarif déplacement</th>
              </tr>
            </thead>
            <tbody>
              {(activites as unknown as { activites: { libelle: string } | null; tarif_mo: number | null; tarif_deplacement: number | null }[]).map((a, i) => (
                <tr key={i} className="border-b">
                  <td className="py-1">{a.activites?.libelle ?? "—"}</td>
                  <td className="text-right">{formatMontant(a.tarif_mo)}</td>
                  <td className="text-right">{formatMontant(a.tarif_deplacement)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <EmptyState message="Aucune activité renseignée." />
        )}
      </div>

      <Tabs tabs={ONGLETS} active={onglet} searchParams={sp} />

      {onglet === "sites" && <IntervenantSites intervenantId={id} />}
      {onglet === "historique" && <IntervenantHistorique intervenantId={id} />}
      {onglet === "techniciens" && <IntervenantTechniciens code={intervenant.code} />}
    </div>
  );
}

async function IntervenantSites({ intervenantId }: { intervenantId: string }) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("site_contrats")
    .select("id, lot, site_id, sites(nom, ville)")
    .eq("sous_traitant_id", intervenantId);

  if (!data || data.length === 0) return <EmptyState message="Aucun site en contrat pour cet intervenant." />;

  return (
    <ul className="flex flex-col gap-2">
      {(data as unknown as { id: number; lot: string; site_id: number; sites: { nom: string; ville: string } | null }[]).map((c) => (
        <li key={c.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
          <Link href={`/sites/${c.site_id}`} className="underline">
            {c.sites?.nom}
          </Link>
          <span className="capitalize opacity-70">{c.lot}</span>
        </li>
      ))}
    </ul>
  );
}

async function IntervenantHistorique({ intervenantId }: { intervenantId: string }) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("v_interventions_liste")
    .select("id, type_libelle, objet, date_realisee")
    .eq("intervenant_id", intervenantId)
    .order("date_realisee", { ascending: false, nullsFirst: false })
    .limit(50);

  if (!data || data.length === 0) return <EmptyState message="Aucune intervention." />;

  const parType = new Map<string, number>();
  for (const i of data) {
    const key = i.type_libelle ?? "—";
    parType.set(key, (parType.get(key) ?? 0) + 1);
  }

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap gap-2 text-xs opacity-70">
        {[...parType.entries()].map(([type, n]) => (
          <span key={type} className="rounded-full border px-2 py-0.5">
            {type} : {n}
          </span>
        ))}
      </div>
      <ul className="flex flex-col gap-2">
        {data.map((i) => (
          <li key={i.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
            <Link href={`/interventions/${i.id}`} className="underline">
              {i.objet ?? i.type_libelle}
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}

async function IntervenantTechniciens({ code }: { code: string }) {
  const supabase = await createClient();
  const { data } = await supabase.from("utilisateurs").select("id, nom, prenom, email").eq("code_intervenant", code).order("nom");

  if (!data || data.length === 0) return <EmptyState message="Aucun technicien rattaché." />;

  return (
    <ul className="flex flex-col gap-2">
      {data.map((u) => (
        <li key={u.id} className="rounded-lg border p-3 text-sm">
          {[u.prenom, u.nom].filter(Boolean).join(" ")} {u.email ? `· ${u.email}` : ""}
        </li>
      ))}
    </ul>
  );
}
