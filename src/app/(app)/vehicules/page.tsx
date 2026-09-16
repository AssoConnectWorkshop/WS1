import Link from "next/link";
import { LigneOuvrable } from "@/components/ui/LigneOuvrable";
import { createClient } from "@/lib/supabase/server";
import { toStringParams } from "@/lib/list-params";
import { Badge } from "@/components/ui/Badge";
import { EmptyState } from "@/components/ui/EmptyState";
import { FilterBar, type FilterField } from "@/components/ui/FilterBar";
import { Messages } from "@/components/ui/Messages";
import { formatNom, formatNombre } from "@/lib/format";
import { ETATS_HORS_ALERTES, ETAT_VENDU, LIBELLES_ALERTES, calculerAlertes, type Alertes, type Evenement, type Vehicule } from "@/lib/vehicules";

export const dynamic = "force-dynamic";

export default async function VehiculesPage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();

  let requete = supabase.from("vehicules").select("*, utilisateurs(nom, prenom), etats_vehicule(libelle)").order("immatriculation");
  requete = sp.vendus === "1" ? requete.eq("etat_code", ETAT_VENDU) : requete.or(`etat_code.is.null,etat_code.neq.${ETAT_VENDU}`);
  const [{ data: vehiculesData }, { data: evenements }] = await Promise.all([requete, supabase.from("vehicule_evenements").select("vehicule_id, date_evenement, km, type_code")]);
  const vehicules = (vehiculesData ?? []) as unknown as (Vehicule & { marque: string | null; modele: string | null; dernier_km: number | null; utilisateurs: { nom: string | null; prenom: string | null } | null; etats_vehicule: { libelle: string | null } | null })[];

  const alertesPar = new Map<number, Alertes>();
  for (const v of vehicules) {
    if (v.etat_code != null && ETATS_HORS_ALERTES.includes(v.etat_code)) continue;
    alertesPar.set(v.id, calculerAlertes(v, (evenements ?? []).filter((e): e is Evenement => e.vehicule_id === v.id)));
  }
  const filtreAlerte = sp.alerte as keyof Alertes | undefined;
  const lignes = filtreAlerte ? vehicules.filter((v) => alertesPar.get(v.id)?.[filtreAlerte]) : vehicules;

  const filterFields: FilterField[] = [
    {
      type: "select",
      name: "alerte",
      label: "Alerte",
      options: Object.entries(LIBELLES_ALERTES).map(([value, label]) => ({ value, label })),
    },
    { type: "checkbox", name: "vendus", label: "Afficher les vendus" },
  ];

  return (
    <div className="mx-auto flex max-w-6xl flex-col gap-4 p-8">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Parc automobile</h1>
        <Link href="/vehicules/nouveau" className="rounded-md bg-black px-3 py-2 text-sm text-white">
          Nouveau véhicule
        </Link>
      </div>
      <Messages sp={sp} />
      <FilterBar fields={filterFields} values={sp} />

      {lignes.length === 0 ? (
        <EmptyState message="Aucun véhicule." />
      ) : (
        <table className="w-full border-collapse text-xs">
          <thead>
            <tr className="border-b text-left">
              <th className="py-1" />
              <th className="py-1">Immatriculation</th>
              <th>Véhicule</th>
              <th>Conducteur</th>
              <th>État</th>
              <th className="text-right">Dernier km</th>
              <th>Alertes</th>
            </tr>
          </thead>
          <tbody>
            {lignes.map((v) => {
              const alertes = alertesPar.get(v.id);
              return (
                <LigneOuvrable key={v.id} href={`/vehicules/${v.id}`} className="border-b hover:bg-blue-100 dark:hover:bg-blue-950/40">
                  <td className="py-1 pr-2">
                    <Link href={`/vehicules/${v.id}`} className="rounded border bg-white px-1.5 py-0.5 text-[11px] dark:bg-white/5">
                      Ouvrir
                    </Link>
                  </td>
                  <td className="py-1">
                    <Link href={`/vehicules/${v.id}`} className="underline">
                      {v.immatriculation ?? `#${v.id}`}
                    </Link>
                  </td>
                  <td>{[v.marque, v.modele].filter(Boolean).join(" ") || "—"}</td>
                  <td>{v.utilisateurs ? <Link href="/parametrage/utilisateurs" className="hover:underline">{formatNom(v.utilisateurs.prenom, v.utilisateurs.nom)}</Link> : "—"}</td>
                  <td>{v.etats_vehicule?.libelle ?? (v.etat_code != null ? `État ${v.etat_code}` : "—")}</td>
                  <td className="text-right">{formatNombre(v.dernier_km)}</td>
                  <td className="flex flex-wrap gap-1 py-1">
                    {alertes &&
                      (Object.keys(alertes) as (keyof Alertes)[]).filter((k) => alertes[k]).map((k) => (
                        <Badge key={k} tone="red">
                          {LIBELLES_ALERTES[k]}
                        </Badge>
                      ))}
                  </td>
                </LigneOuvrable>
              );
            })}
          </tbody>
        </table>
      )}
    </div>
  );
}
