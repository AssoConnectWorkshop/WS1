import Link from "next/link";
import { Messages } from "@/components/ui/Messages";
import { createClient } from "@/lib/supabase/server";
import { toStringParams } from "@/lib/list-params";
import { FilterBar, type FilterField } from "@/components/ui/FilterBar";
import { EmptyState } from "@/components/ui/EmptyState";
import { Badge } from "@/components/ui/Badge";
import { Champ, CHAMP } from "@/components/ui/Champ";
import { formatDate } from "@/lib/format";
import { CLES_LOTS, LIBELLES_LOT, type Lot } from "@/lib/sites";
import { MAX_DATES, sitesConcernes } from "@/lib/planification";
import { enregistrerPlanification, genererDatesPrevues, genererInterventions } from "./actions";

export const dynamic = "force-dynamic";

const BOUTON = "rounded-md border px-3 py-1.5 text-sm";

export default async function PlanificationPage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();

  let clients: { id: number; nom: string }[] = [];
  if (sp.client && !sp.client_id) {
    const { data } = await supabase.from("clients").select("id, nom").ilike("nom", `%${sp.client}%`).eq("actif", true).order("nom").limit(20);
    clients = data ?? [];
  }
  const clientId = sp.client_id ? Number(sp.client_id) : clients.length === 1 ? clients[0].id : null;
  const lot: Lot = (CLES_LOTS as readonly string[]).includes(sp.lot ?? "") ? (sp.lot as Lot) : "clim";
  const visites = Math.min(MAX_DATES, Math.max(1, Number(sp.visites) || 2));

  const [{ data: client }, { data: plan }, sites, { data: sitesClient }] = clientId
    ? await Promise.all([
        supabase.from("clients").select("id, nom").eq("id", clientId).maybeSingle(),
        supabase.from("planifications").select("rang, date_limite, reference_client").eq("client_id", clientId).eq("lot", lot).eq("nombre_visites", visites).order("rang"),
        sitesConcernes(supabase, clientId, lot, visites),
        supabase.from("sites").select("id, nom, ville").eq("client_id", clientId).eq("ferme", false).is("supprime_le", null).order("nom"),
      ])
    : [{ data: null }, { data: [] }, [] as Awaited<ReturnType<typeof sitesConcernes>>, { data: [] }];

  const { data: entretiensAVenir } = await supabase
    .from("v_interventions_liste")
    .select("id, site_nom, client_nom, date_limite, date_prevue")
    .eq("type_code", 1)
    .eq("statut_code", 1)
    .order("date_limite", { nullsFirst: false })
    .limit(50);

  const filterFields: FilterField[] = [{ type: "text", name: "client", label: "Rechercher un client" }];
  const lien = (params: Record<string, string | number>) => `/planification?${new URLSearchParams({ client_id: String(clientId), lot, visites: String(visites), ...Object.fromEntries(Object.entries(params).map(([k, v]) => [k, String(v)])) })}`;

  return (
    <div className="mx-auto flex max-w-5xl flex-col gap-8 p-8">
      <h1 className="text-2xl font-bold">Planification des entretiens</h1>
      <Messages sp={sp} />

      <section className="flex flex-col gap-3">
        <h2 className="text-sm font-semibold opacity-70">Client</h2>
        <FilterBar fields={filterFields} values={sp} />
        {sp.client && !sp.client_id && clients.length > 1 && (
          <ul className="flex flex-col gap-1 text-sm">
            {clients.map((c) => (
              <li key={c.id}>
                <Link href={`/planification?client_id=${c.id}`} className="underline">
                  {c.nom}
                </Link>
              </li>
            ))}
          </ul>
        )}
        {sp.client && !sp.client_id && clients.length === 0 && <EmptyState message="Aucun client actif ne correspond." />}
      </section>

      {client && (
        <>
          <section className="flex flex-col gap-3">
            <h2 className="text-lg font-semibold">
              <Link href={`/clients/${client.id}`} className="underline">
                {client.nom}
              </Link>
            </h2>
            <div className="flex flex-wrap items-center gap-2 text-sm">
              {CLES_LOTS.map((l) => (
                <Link key={l} href={lien({ lot: l })} className={`${BOUTON} ${l === lot ? "bg-black text-white" : ""}`}>
                  {LIBELLES_LOT[l]}
                </Link>
              ))}
              <form method="GET" className="ml-4 flex items-center gap-2">
                <input type="hidden" name="client_id" value={client.id} />
                <input type="hidden" name="lot" value={lot} />
                <label className="flex items-center gap-2">
                  Nombre de visites à planifier
                  <select name="visites" defaultValue={visites} className="rounded-md border px-2 py-1">
                    {Array.from({ length: MAX_DATES }, (_, i) => i + 1).map((n) => (
                      <option key={n} value={n}>
                        {n}
                      </option>
                    ))}
                  </select>
                </label>
                <button type="submit" className={BOUTON}>
                  Afficher
                </button>
              </form>
            </div>
            <p className="text-xs opacity-60">
              Les sites concernés sont ceux dont le contrat {LIBELLES_LOT[lot]} prévoit exactement {visites} visite(s) par an. Faire absolument en priorité les entretiens.
            </p>
          </section>

          <section className="grid gap-6 lg:grid-cols-2">
            <form action={enregistrerPlanification} className="flex flex-col gap-3 rounded-xl border p-4">
              <h3 className="text-sm font-semibold opacity-70">
                Dates limites {LIBELLES_LOT[lot]} · {visites} visite(s)
              </h3>
              <input type="hidden" name="client_id" value={client.id} />
              <input type="hidden" name="lot" value={lot} />
              <input type="hidden" name="nombre_visites" value={visites} />
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b text-left">
                    <th className="py-1">#</th>
                    <th>Date limite</th>
                    <th>Référence DI client</th>
                  </tr>
                </thead>
                <tbody>
                  {Array.from({ length: visites }, (_, i) => i + 1).map((rang) => {
                    const ligne = (plan ?? []).find((p) => p.rang === rang);
                    return (
                      <tr key={rang} className="border-b">
                        <td className="py-1">{rang}</td>
                        <td>
                          <input name={`date_${rang}`} type="date" defaultValue={ligne?.date_limite ?? ""} className="rounded-md border px-2 py-1" />
                        </td>
                        <td>
                          <input name={`reference_${rang}`} defaultValue={ligne?.reference_client ?? ""} className="w-full rounded-md border px-2 py-1" />
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
              <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
                Enregistrer les dates
              </button>
            </form>

            <div className="flex flex-col gap-3 rounded-xl border p-4">
              <h3 className="text-sm font-semibold opacity-70">{sites.length} site(s) concerné(s)</h3>
              {sites.length > 0 ? (
                <ul className="max-h-64 overflow-auto text-sm">
                  {sites.map((s) => (
                    <li key={s.id} className="flex items-center justify-between border-b py-1">
                      <Link href={`/sites/${s.id}`} className="underline">
                        {s.nom}
                      </Link>
                      <span className="flex gap-1">
                        {s.ne_plus_intervenir && <Badge tone="red">Ne plus intervenir</Badge>}
                        {s.sous_traitant_id && <Badge tone="purple">Sous-traité</Badge>}
                      </span>
                    </li>
                  ))}
                </ul>
              ) : (
                <EmptyState message={`Aucun site avec un contrat ${LIBELLES_LOT[lot]} à ${visites} visite(s)/an.`} />
              )}
              <form action={genererInterventions}>
                <input type="hidden" name="client_id" value={client.id} />
                <input type="hidden" name="lot" value={lot} />
                <input type="hidden" name="nombre_visites" value={visites} />
                <button type="submit" disabled={sites.length === 0 || (plan ?? []).length === 0} className="rounded-md bg-black px-4 py-1.5 text-sm text-white disabled:opacity-40">
                  Générer les interventions
                </button>
              </form>
              <p className="text-xs opacity-60">
                Une intervention par site et par date enregistrée (type {LIBELLES_LOT[lot]}, statut « À planifier », ou « Ne plus intervenir » pour les sites concernés) ;
                intervenant = sous-traitant du lot, sinon intervenant du site, sinon FMC. Les doublons (même site, même type, même date limite) sont ignorés.
              </p>
            </div>
          </section>

          <section className="flex flex-col gap-3 rounded-xl border p-4">
            <h3 className="text-sm font-semibold opacity-70">Dates prévues calculées (entretien clim)</h3>
            <form action={genererDatesPrevues} className="flex flex-wrap items-end gap-3">
              <input type="hidden" name="client_id" value={client.id} />
              <Champ label="Site (vide = tous les sites du client)">
                <select name="site_id" className={CHAMP}>
                  <option value="">— Tous —</option>
                  {(sitesClient ?? []).map((s) => (
                    <option key={s.id} value={s.id}>
                      {s.nom} ({s.ville})
                    </option>
                  ))}
                </select>
              </Champ>
              <Champ label="À partir du">
                <input name="date_debut" type="date" defaultValue={new Date().toISOString().slice(0, 10)} className={CHAMP} />
              </Champ>
              <Champ label="Jusqu'au *">
                <input name="date_fin" type="date" required className={CHAMP} />
              </Champ>
              <button type="submit" className="rounded-md bg-black px-4 py-2 text-sm text-white">
                Générer les dates prévues
              </button>
            </form>
            <p className="text-xs opacity-60">
              Pas de 12 / visites mois depuis la dernière visite réalisée (sinon le 15/12 de l&apos;année précédente), ajusté férié −1 j, samedi −1, dimanche +1. Les entretiens prévus
              non réalisés du site sont d&apos;abord annulés (statut 8). Les calendriers fixes Access (Armand Thiery, Toscan…) ne sont pas repris.
            </p>
          </section>
        </>
      )}

      <section className="flex flex-col gap-3">
        <h2 className="text-sm font-semibold opacity-70">Entretiens à planifier (type Entretien, statut 1)</h2>
        {entretiensAVenir && entretiensAVenir.length > 0 ? (
          <ul className="flex flex-col gap-2">
            {entretiensAVenir.map((i) => (
              <li key={i.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
                <Link href={`/interventions/${i.id}`} className="underline">
                  {i.site_nom} · {i.client_nom}
                </Link>
                <span className="opacity-70">
                  Limite {formatDate(i.date_limite)} · Prévue {formatDate(i.date_prevue)}
                </span>
              </li>
            ))}
          </ul>
        ) : (
          <EmptyState message="Aucun entretien à planifier." />
        )}
      </section>
    </div>
  );
}
