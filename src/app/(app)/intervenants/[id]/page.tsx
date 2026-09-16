import Link from "next/link";
import { Messages } from "@/components/ui/Messages";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Tabs } from "@/components/ui/Tabs";
import { KeyValue } from "@/components/ui/KeyValue";
import { EmptyState } from "@/components/ui/EmptyState";
import { Badge } from "@/components/ui/Badge";
import { Case, Champ, CHAMP } from "@/components/ui/Champ";
import { ChampsIntervenant } from "@/components/intervenants/FormulaireIntervenant";
import { formatDate, formatMontant, formatNom, oui } from "@/lib/format";
import { toStringParams } from "@/lib/list-params";
import { LIBELLES_LOT, type Lot } from "@/lib/sites";
import { MAX_ACTIVITES, MAX_ZONES } from "@/lib/intervenants";
import { basculerNePlusIntervenirIntervenant, mettreAJourActivites, mettreAJourIntervenant, mettreAJourZones } from "../actions";

export const dynamic = "force-dynamic";

const ONGLETS = [
  { key: "fiche", label: "Fiche" },
  { key: "activites", label: "Activités et tarifs" },
  { key: "zones", label: "Zones" },
  { key: "sites", label: "Sites en contrat" },
  { key: "historique", label: "Historique interventions" },
  { key: "techniciens", label: "Techniciens" },
];

const BOUTON = "rounded-md border px-3 py-1.5 text-sm";
const etoiles = (n: number | null) => (n ? "★".repeat(n) : "—");

export default async function IntervenantPage({
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
  const { data: intervenant } = await supabase.from("intervenants").select("*").eq("id", id).maybeSingle();
  if (!intervenant) notFound();

  const [{ data: zonesData }, { data: activitesData }, { data: toutesZones }, { data: toutesActivites }, { data: gestionnaires }] = await Promise.all([
    supabase.from("intervenant_zones").select("rang, zone_id, zones_geographiques(libelle)").eq("intervenant_id", id).order("rang"),
    supabase.from("intervenant_activites").select("rang, activite_id, tarif_mo, tarif_deplacement, date_tarif, activites(libelle)").eq("intervenant_id", id).order("rang"),
    supabase.from("zones_geographiques").select("id, libelle").order("libelle"),
    supabase.from("activites").select("id, libelle").order("libelle"),
    supabase.from("utilisateurs").select("id, nom, prenom").in("profil", [1, 3]).order("nom"),
  ]);
  const zones = (zonesData ?? []) as unknown as { rang: number; zone_id: number | null; zones_geographiques: { libelle: string } | null }[];
  const activites = (activitesData ?? []) as unknown as {
    rang: number;
    activite_id: number | null;
    tarif_mo: number | null;
    tarif_deplacement: number | null;
    date_tarif: string | null;
    activites: { libelle: string } | null;
  }[];
  const interlocuteur = gestionnaires?.find((g) => g.id === intervenant.interlocuteur_fmc_id);

  return (
    <div className="mx-auto flex max-w-5xl flex-col gap-4 p-8">
      <Messages sp={sp} />

      {intervenant.ne_plus_intervenir && (
        <div className="rounded-lg bg-red-50 p-3 text-sm text-red-700">Ne plus intervenir{intervenant.motif_ne_plus_intervenir ? ` : ${intervenant.motif_ne_plus_intervenir}` : ""}.</div>
      )}

      {sp.confirmer === "ne_plus_intervenir" && (
        <form action={basculerNePlusIntervenirIntervenant} className="flex flex-col gap-3 rounded-md bg-orange-50 p-4 text-sm text-orange-900">
          <input type="hidden" name="intervenant_id" value={id} />
          <input type="hidden" name="actif" value={intervenant.ne_plus_intervenir ? "0" : "1"} />
          {intervenant.ne_plus_intervenir ? (
            <p className="font-medium">Réactiver cet intervenant ?</p>
          ) : (
            <Champ label="Motif « Ne plus intervenir » *">
              <input name="motif_ne_plus_intervenir" required className={CHAMP} />
            </Champ>
          )}
          <div className="flex gap-3">
            <button type="submit" className="rounded-md bg-orange-700 px-3 py-1.5 text-white">
              Confirmer
            </button>
            <Link href={`/intervenants/${id}`} className={BOUTON}>
              Annuler
            </Link>
          </div>
        </form>
      )}

      <div className="flex flex-wrap items-center gap-2">
        {intervenant.est_technicien_interne && <Badge tone="blue">Technicien interne</Badge>}
        {intervenant.est_sous_traitant && <Badge tone="purple">Sous-traitant FMC</Badge>}
        {intervenant.est_sous_traitant_ponctuel && <Badge tone="purple">Ponctuel</Badge>}
        {intervenant.est_prospect && <Badge tone="yellow">Prospect</Badge>}
        {intervenant.zone_nationale && <Badge tone="green">Zone nationale</Badge>}
        {intervenant.n_existe_plus && <Badge tone="gray">N&apos;existe plus</Badge>}
      </div>
      <h1 className="text-xl font-semibold">
        {intervenant.nom} <span className="text-sm font-normal opacity-60">({intervenant.code})</span>
      </h1>
      <div className="flex flex-wrap gap-2">
        <Link href={`/intervenants/${id}?confirmer=ne_plus_intervenir`} className={BOUTON}>
          {intervenant.ne_plus_intervenir ? "Réactiver" : "Ne plus intervenir"}
        </Link>
      </div>

      <Tabs tabs={ONGLETS} active={onglet} searchParams={sp} />

      {onglet === "fiche" && (
        <div className="flex flex-col gap-6">
          <KeyValue
            items={[
              { label: "Adresse", value: `${intervenant.adresse ?? ""} ${intervenant.code_postal ?? ""} ${intervenant.ville ?? ""}`.trim() || "—" },
              { label: "Téléphone", value: intervenant.telephone },
              { label: "E-mail", value: intervenant.email },
              { label: "Dirigeant", value: intervenant.dirigeant_nom },
              { label: "Interlocuteur FMC", value: interlocuteur ? formatNom(interlocuteur.prenom, interlocuteur.nom) : "—" },
              { label: "Zones", value: zones.map((z) => z.zones_geographiques?.libelle).filter(Boolean).join(", ") || (intervenant.zone_nationale ? "Nationale" : "—") },
              { label: "Notes maint. / dép. / trav. / réact.", value: [intervenant.note_maintenance, intervenant.note_depannage, intervenant.note_travaux, intervenant.note_reactivite].map(etoiles).join(" · ") },
              { label: "Autoliquidation", value: oui(intervenant.autoliquidation) },
            ]}
          />
          <form action={mettreAJourIntervenant} className="flex flex-col gap-4">
            <input type="hidden" name="intervenant_id" value={id} />
            <ChampsIntervenant intervenant={intervenant} gestionnaires={(gestionnaires ?? []).map((g) => ({ id: g.id, libelle: formatNom(g.prenom, g.nom) }))} />
            <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
              Enregistrer la fiche
            </button>
          </form>
        </div>
      )}

      {onglet === "activites" && (
        <form action={mettreAJourActivites} className="flex flex-col gap-3 rounded-xl border p-4">
          <input type="hidden" name="intervenant_id" value={id} />
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b text-left">
                <th className="py-1">Activité</th>
                <th>Tarif MO</th>
                <th>Tarif déplacement</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
              {Array.from({ length: MAX_ACTIVITES }, (_, i) => activites[i]).map((a, i) => (
                <tr key={i} className="border-b">
                  <td className="py-1">
                    <select name={`activite_id_${i + 1}`} defaultValue={a?.activite_id ?? ""} className="w-full rounded-md border px-2 py-1">
                      <option value="">—</option>
                      {(toutesActivites ?? []).map((act) => (
                        <option key={act.id} value={act.id}>
                          {act.libelle}
                        </option>
                      ))}
                    </select>
                  </td>
                  <td>
                    <input name={`tarif_mo_${i + 1}`} type="number" step="0.01" defaultValue={a?.tarif_mo ?? ""} className="w-28 rounded-md border px-2 py-1" />
                  </td>
                  <td>
                    <input name={`tarif_deplacement_${i + 1}`} type="number" step="0.01" defaultValue={a?.tarif_deplacement ?? ""} className="w-28 rounded-md border px-2 py-1" />
                  </td>
                  <td>
                    <input name={`date_tarif_${i + 1}`} type="date" defaultValue={a?.date_tarif ?? ""} className="rounded-md border px-2 py-1" />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <p className="text-xs opacity-60">Six activités au plus ; les tarifs par site et par lot sont saisis sur les contrats des sites.</p>
          <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
            Enregistrer les activités
          </button>
        </form>
      )}

      {onglet === "zones" && (
        <form action={mettreAJourZones} className="flex flex-col gap-3 rounded-xl border p-4">
          <input type="hidden" name="intervenant_id" value={id} />
          <div className="grid grid-cols-4 gap-3">
            {Array.from({ length: MAX_ZONES }, (_, i) => zones[i]).map((z, i) => (
              <Champ key={i} label={`Zone ${i + 1}`}>
                <select name={`zone_id_${i + 1}`} defaultValue={z?.zone_id ?? ""} className={CHAMP}>
                  <option value="">—</option>
                  {(toutesZones ?? []).map((zone) => (
                    <option key={zone.id} value={zone.id}>
                      {zone.libelle}
                    </option>
                  ))}
                </select>
              </Champ>
            ))}
          </div>
          <Case name="zone_nationale" label="Zone nationale (ressort pour toute zone dans les recherches)" checked={intervenant.zone_nationale} />
          <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
            Enregistrer les zones
          </button>
        </form>
      )}

      {onglet === "sites" && <IntervenantSites intervenantId={id} />}
      {onglet === "historique" && <IntervenantHistorique intervenantId={id} />}
      {onglet === "techniciens" && <IntervenantTechniciens code={intervenant.code} />}
    </div>
  );
}

async function IntervenantSites({ intervenantId }: { intervenantId: string }) {
  const supabase = await createClient();
  const { data } = await supabase.from("site_contrats").select("id, lot, site_id, tarif_sous_traitant, sites(nom, ville)").eq("sous_traitant_id", intervenantId);

  if (!data || data.length === 0) return <EmptyState message="Aucun site en contrat pour cet intervenant." />;

  return (
    <ul className="flex flex-col gap-2">
      {(data as unknown as { id: number; lot: string; site_id: number; tarif_sous_traitant: number | null; sites: { nom: string; ville: string } | null }[]).map((c) => (
        <li key={c.id} className="flex items-center justify-between rounded-lg border p-3 text-sm">
          <Link href={`/sites/${c.site_id}`} className="underline">
            {c.sites?.nom} ({c.sites?.ville})
          </Link>
          <span className="opacity-70">
            {LIBELLES_LOT[c.lot as Lot] ?? c.lot} · {formatMontant(c.tarif_sous_traitant)}
          </span>
        </li>
      ))}
    </ul>
  );
}

async function IntervenantHistorique({ intervenantId }: { intervenantId: string }) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("v_interventions_liste")
    .select("id, type_libelle, objet, date_realisee, site_nom")
    .eq("intervenant_id", intervenantId)
    .order("date_realisee", { ascending: false, nullsFirst: false })
    .limit(50);

  if (!data || data.length === 0) return <EmptyState message="Aucune intervention." />;

  const parType = new Map<string, number>();
  for (const i of data) parType.set(i.type_libelle ?? "—", (parType.get(i.type_libelle ?? "—") ?? 0) + 1);

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
              {i.site_nom} · {i.objet ?? i.type_libelle}
            </Link>
            <span className="opacity-70">{formatDate(i.date_realisee)}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}

async function IntervenantTechniciens({ code }: { code: string }) {
  const supabase = await createClient();
  const { data } = await supabase.from("utilisateurs").select("id, nom, prenom, email").eq("code_intervenant", code).order("nom");

  if (!data || data.length === 0) return <EmptyState message="Aucun technicien rattaché (utilisateurs dont le code intervenant est ce code)." />;

  return (
    <ul className="flex flex-col gap-2">
      {data.map((u) => (
        <li key={u.id} className="rounded-lg border p-3 text-sm">
          {formatNom(u.prenom, u.nom)} {u.email ? `· ${u.email}` : ""}
        </li>
      ))}
    </ul>
  );
}
