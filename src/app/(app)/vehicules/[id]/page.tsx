import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { toStringParams } from "@/lib/list-params";
import { Badge } from "@/components/ui/Badge";
import { Champ, CHAMP } from "@/components/ui/Champ";
import { EmptyState } from "@/components/ui/EmptyState";
import { KeyValue } from "@/components/ui/KeyValue";
import { Messages } from "@/components/ui/Messages";
import { ChampsVehicule } from "@/components/vehicules/FormulaireVehicule";
import { formatDate, formatNom, formatNombre } from "@/lib/format";
import { ETATS_HORS_ALERTES, LIBELLES_ALERTES, TYPES_EVENEMENT, TYPES_RELEVE_KM, calculerAlertes, type Alertes, type Evenement } from "@/lib/vehicules";
import { ajouterEvenement, mettreAJourVehicule, supprimerEvenement } from "../actions";

export const dynamic = "force-dynamic";

type Ev = Evenement & { id: number; conducteur_id: number | null; utilisateurs: { nom: string | null; prenom: string | null } | null };

export default async function VehiculePage({ params, searchParams }: { params: Promise<{ id: string }>; searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const { id } = await params;
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();
  const { data: vehicule } = await supabase.from("vehicules").select("*").eq("id", id).maybeSingle();
  if (!vehicule) notFound();

  const [{ data: evenementsData }, { data: conducteurs }, { data: etats }, { data: typesEv }] = await Promise.all([
    supabase.from("vehicule_evenements").select("id, vehicule_id, date_evenement, km, type_code, conducteur_id, utilisateurs(nom, prenom)").eq("vehicule_id", id).order("date_evenement", { ascending: false }),
    supabase.from("utilisateurs").select("id, nom, prenom").eq("profil", 2).not("code_intervenant", "is", null).order("nom"),
    supabase.from("etats_vehicule").select("code, libelle").order("code"),
    supabase.from("types_evenement_vehicule").select("code, libelle").order("code"),
  ]);
  const evenements = (evenementsData ?? []) as unknown as Ev[];
  const libelleType = (code: number | null) => (code == null ? "—" : (typesEv?.find((t) => t.code === code)?.libelle ?? TYPES_EVENEMENT[code] ?? `Type ${code}`));
  const dernier = (types: number[]) => evenements.find((e) => e.type_code != null && types.includes(e.type_code));
  const revision = dernier([2]);
  const ct = dernier([3]);
  const cc = dernier([4]);
  const releve = dernier(TYPES_RELEVE_KM);
  const alertes = vehicule.etat_code != null && ETATS_HORS_ALERTES.includes(vehicule.etat_code) ? null : calculerAlertes(vehicule, evenements);
  const options = (conducteurs ?? []).map((c) => ({ id: c.id, libelle: formatNom(c.prenom, c.nom) }));
  const typesOptions = typesEv && typesEv.length > 0 ? typesEv.map((t) => ({ code: t.code, libelle: t.libelle ?? TYPES_EVENEMENT[t.code] })) : Object.entries(TYPES_EVENEMENT).map(([code, libelle]) => ({ code: Number(code), libelle }));

  return (
    <div className="mx-auto flex max-w-5xl flex-col gap-4 p-8">
      <div>
        <Link href="/vehicules" className="text-sm underline">
          ← Parc automobile
        </Link>
      </div>
      <Messages sp={sp} />
      <div className="flex flex-wrap items-center gap-2">
        {alertes &&
          (Object.keys(alertes) as (keyof Alertes)[]).filter((k) => alertes[k]).map((k) => (
            <Badge key={k} tone="red">
              Problème de {LIBELLES_ALERTES[k].toLowerCase()}
            </Badge>
          ))}
      </div>
      <h1 className="text-xl font-semibold">
        {vehicule.immatriculation} <span className="text-sm font-normal opacity-60">{[vehicule.marque, vehicule.modele].filter(Boolean).join(" ")}</span>
      </h1>

      <KeyValue
        items={[
          { label: "Dernier relevé km", value: releve ? `${formatNombre(releve.km)} km le ${formatDate(releve.date_evenement)}` : "—" },
          { label: "Dernière révision", value: revision ? `${formatNombre(revision.km)} km le ${formatDate(revision.date_evenement)}` : "—" },
          { label: "Dernier contrôle technique", value: ct ? formatDate(ct.date_evenement) : "—" },
          { label: "Dernier contrôle complémentaire", value: cc ? formatDate(cc.date_evenement) : "—" },
        ]}
      />

      <div className="grid gap-4 lg:grid-cols-[1fr_20rem]">
        <div className="flex flex-col gap-3">
          <h2 className="text-sm font-semibold opacity-70">Événements</h2>
          {evenements.length === 0 ? (
            <EmptyState message="Aucun événement." />
          ) : (
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b text-left">
                  <th className="py-1">Date</th>
                  <th>Type</th>
                  <th className="text-right">Km</th>
                  <th>Conducteur</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {evenements.map((e) => (
                  <tr key={e.id} className="border-b">
                    <td className="py-1">{formatDate(e.date_evenement)}</td>
                    <td>{libelleType(e.type_code)}</td>
                    <td className="text-right">{formatNombre(e.km)}</td>
                    <td>{e.utilisateurs ? formatNom(e.utilisateurs.prenom, e.utilisateurs.nom) : "—"}</td>
                    <td className="text-right">
                      <form action={supprimerEvenement}>
                        <input type="hidden" name="vehicule_id" value={id} />
                        <input type="hidden" name="evenement_id" value={e.id} />
                        <button type="submit" className="text-xs text-red-700 underline">
                          Supprimer
                        </button>
                      </form>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>

        <form action={ajouterEvenement} className="flex flex-col gap-3 rounded-xl border p-4">
          <h2 className="text-sm font-semibold opacity-70">Ajouter un événement</h2>
          <input type="hidden" name="vehicule_id" value={id} />
          <Champ label="Type *">
            <select name="type_code" required className={CHAMP}>
              <option value="">—</option>
              {typesOptions.map((t) => (
                <option key={t.code} value={t.code}>
                  {t.libelle}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="Date *">
            <input name="date_evenement" type="date" required defaultValue={new Date().toISOString().slice(0, 10)} className={CHAMP} />
          </Champ>
          <Champ label="Kilométrage *">
            <input name="km" type="number" min={0} required defaultValue={vehicule.dernier_km ?? ""} className={CHAMP} />
          </Champ>
          <Champ label="Conducteur">
            <select name="conducteur_id" defaultValue={vehicule.conducteur_id ?? ""} className={CHAMP}>
              <option value="">— Conducteur du véhicule —</option>
              {options.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.libelle}
                </option>
              ))}
            </select>
          </Champ>
          <p className="text-xs opacity-60">Pour un relevé km, le kilométrage doit être supérieur ou égal au dernier relevé.</p>
          <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
            Ajouter
          </button>
        </form>
      </div>

      <form action={mettreAJourVehicule} className="flex flex-col gap-4">
        <input type="hidden" name="vehicule_id" value={id} />
        <ChampsVehicule vehicule={vehicule} conducteurs={options} etats={etats ?? []} />
        <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
          Enregistrer le véhicule
        </button>
      </form>
    </div>
  );
}
