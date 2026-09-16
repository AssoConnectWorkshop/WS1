import Link from "next/link";
import { Messages } from "@/components/ui/Messages";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser } from "@/lib/auth";
import { getReferentiel, type ColonneConfig } from "@/lib/referentiels-config";
import { toStringParams } from "@/lib/list-params";
import { EmptyState } from "@/components/ui/EmptyState";
import { Case, Champ, CHAMP } from "@/components/ui/Champ";
import { formatDate, oui } from "@/lib/format";
import { enregistrerReferentiel, supprimerReferentiel } from "../actions";

export const dynamic = "force-dynamic";

type Ligne = Record<string, unknown> & { id: number };
type Options = Record<string, { id: number; libelle: string }[]>;

function afficher(colonne: ColonneConfig, valeur: unknown, options: Options) {
  if (valeur == null) return "—";
  if (colonne.type === "boolean") return oui(Boolean(valeur));
  if (colonne.type === "date") return formatDate(String(valeur));
  if (colonne.type === "select") return options[colonne.key]?.find((o) => o.id === Number(valeur))?.libelle ?? String(valeur);
  return String(valeur);
}

function ChampColonne({ colonne, valeur, options }: { colonne: ColonneConfig; valeur: unknown; options: Options }) {
  const texte = valeur == null ? "" : String(valeur);
  if (colonne.type === "boolean") return <Case name={colonne.key} label={colonne.label} checked={Boolean(valeur)} />;
  return (
    <Champ label={`${colonne.label}${colonne.required ? " *" : ""}`}>
      {colonne.type === "select" ? (
        <select name={colonne.key} defaultValue={texte} required={colonne.required} className={CHAMP}>
          <option value="">—</option>
          {(options[colonne.key] ?? []).map((o) => (
            <option key={o.id} value={o.id}>
              {o.libelle}
            </option>
          ))}
        </select>
      ) : (
        <input
          name={colonne.key}
          type={colonne.type === "number" ? "number" : colonne.type === "date" ? "date" : "text"}
          step={colonne.type === "number" ? "1" : undefined}
          defaultValue={colonne.type === "date" ? texte.slice(0, 10) : texte}
          required={colonne.required}
          placeholder={colonne.key === "code" ? "auto" : undefined}
          className={CHAMP}
        />
      )}
    </Champ>
  );
}

export default async function ReferentielPage({
  params,
  searchParams,
}: {
  params: Promise<{ referentiel: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { referentiel } = await params;
  const sp = toStringParams(await searchParams);
  const config = getReferentiel(referentiel);
  if (!config) notFound();

  const supabase = await createClient();
  const [current, { data }] = await Promise.all([getCurrentUser(), supabase.from(config.table).select("*").order(config.orderBy)]);
  const lignes = (data ?? []) as Ligne[];
  const estAdmin = current?.role === "administrateur";

  const options: Options = {};
  for (const colonne of config.columns) {
    if (colonne.type === "select" && colonne.options) {
      const { data: rows } = await supabase.from(colonne.options.table).select(`id, libelle:${colonne.options.label}`).order(colonne.options.label);
      options[colonne.key] = (rows ?? []) as unknown as { id: number; libelle: string }[];
    }
  }

  const enEdition = sp.modifier ? lignes.find((l) => String(l.id) === sp.modifier) : undefined;
  const afficherFormulaire = estAdmin && (sp.ajouter === "1" || enEdition);

  return (
    <div className="mx-auto flex max-w-4xl flex-col gap-4 p-8">
      <div>
        <Link href="/parametrage" className="text-sm underline">
          ← Paramétrage
        </Link>
      </div>
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">{config.label}</h1>
        {estAdmin && (
          <Link href={`/parametrage/${config.slug}?ajouter=1`} className="rounded-md bg-black px-3 py-2 text-sm text-white">
            Ajouter
          </Link>
        )}
      </div>
      <Messages sp={sp} />

      {afficherFormulaire && (
        <form action={enregistrerReferentiel} className="flex flex-col gap-3 rounded-xl border border-black/30 p-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold opacity-70">{enEdition ? `Modifier la ligne #${enEdition.id}` : "Nouvelle ligne"}</h2>
            <Link href={`/parametrage/${config.slug}`} className="text-xs underline">
              Fermer
            </Link>
          </div>
          <input type="hidden" name="slug" value={config.slug} />
          {enEdition && <input type="hidden" name="ligne_id" value={enEdition.id} />}
          <div className="grid grid-cols-3 gap-3">
            {config.columns.map((c) => (
              <ChampColonne key={c.key} colonne={c} valeur={enEdition?.[c.key]} options={options} />
            ))}
          </div>
          <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
            Enregistrer
          </button>
        </form>
      )}

      {lignes.length > 0 ? (
        <div className="overflow-x-auto rounded-lg border">
          <table className="w-full border-collapse text-sm">
            <thead>
              <tr className="border-b bg-black/[0.02] text-left dark:bg-white/[0.03]">
                {config.columns.map((c) => (
                  <th key={c.key} className="px-3 py-2 font-medium">
                    {c.label}
                  </th>
                ))}
                {estAdmin && <th className="px-3 py-2"></th>}
              </tr>
            </thead>
            <tbody>
              {lignes.map((row) => (
                <tr key={row.id} className={`border-b last:border-0 ${enEdition?.id === row.id ? "bg-black/[0.03] dark:bg-white/[0.05]" : ""}`}>
                  {config.columns.map((c) => (
                    <td key={c.key} className="px-3 py-2">
                      {afficher(c, row[c.key], options)}
                    </td>
                  ))}
                  {estAdmin && (
                    <td className="whitespace-nowrap px-3 py-2 text-right">
                      <Link href={`/parametrage/${config.slug}?modifier=${row.id}`} className="text-xs underline">
                        Modifier
                      </Link>
                      <form action={supprimerReferentiel} className="ml-2 inline">
                        <input type="hidden" name="slug" value={config.slug} />
                        <input type="hidden" name="ligne_id" value={row.id} />
                        <button type="submit" className="text-xs text-red-700 underline">
                          Supprimer
                        </button>
                      </form>
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <EmptyState message="Aucune ligne." />
      )}
    </div>
  );
}
