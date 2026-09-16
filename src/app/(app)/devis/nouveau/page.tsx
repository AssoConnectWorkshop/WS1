import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { getCurrentUser } from "@/lib/auth";
import { toStringParams } from "@/lib/list-params";
import { formatDate } from "@/lib/format";
import { FAMILLES_DEVIS, LIBELLES_FAMILLE, chargerSiteEtTarifs, estFamille } from "@/lib/devis";
import { creerDevis } from "../actions";

export const dynamic = "force-dynamic";

const CHAMP = "rounded-md border px-3 py-2";

function Champ({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <label className="flex flex-col gap-1 text-sm">
      {label}
      {children}
    </label>
  );
}

export default async function NouveauDevisPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const sp = toStringParams(await searchParams);
  const famille = estFamille(sp.famille) ? sp.famille : "sav";
  const supabase = await createClient();
  const siteId = sp.site ? Number(sp.site) : null;

  const [current, site, { data: pannes }, { data: gestionnaires }] = await Promise.all([
    getCurrentUser(),
    siteId ? chargerSiteEtTarifs(supabase, siteId) : Promise.resolve(null),
    supabase.from("pannes").select("libelle").order("libelle"),
    supabase.from("utilisateurs").select("id, nom, prenom").in("profil", [1, 3]).order("nom"),
  ]);

  let sitesTrouves: { id: number; nom: string; ville: string | null }[] = [];
  if (!site && sp.recherche?.trim()) {
    const recherche = sp.recherche.trim();
    const numero = Number(recherche);
    let q = supabase.from("sites").select("id, nom, ville").limit(20);
    q = Number.isFinite(numero) ? q.or(`numero_magasin.eq.${numero},nom.ilike.%${recherche}%`) : q.ilike("nom", `%${recherche}%`);
    const { data } = await q;
    sitesTrouves = data ?? [];
  }

  const [{ data: client }, { data: interventionsSite }] = await Promise.all([
    site ? supabase.from("clients").select("nom").eq("id", site.client_id).maybeSingle() : Promise.resolve({ data: null }),
    site
      ? supabase.from("interventions").select("id, objet, date_demande").eq("site_id", site.id).order("date_demande", { ascending: false }).limit(50)
      : Promise.resolve({ data: [] }),
  ]);

  return (
    <div className="mx-auto flex max-w-2xl flex-col gap-4 p-8">
      <h1 className="text-2xl font-bold">Nouveau devis</h1>

      {sp.erreur && <p className="rounded-md bg-red-50 p-3 text-sm text-red-700">{sp.erreur}</p>}

      {!site && (
        <form method="GET" className="flex items-end gap-2 rounded-lg border p-3 text-sm">
          <input type="hidden" name="famille" value={famille} />
          <label className="flex flex-col gap-1">
            <span className="text-xs opacity-60">Rechercher un site (nom ou numéro)</span>
            <input name="recherche" defaultValue={sp.recherche} className={CHAMP} />
          </label>
          <button type="submit" className="rounded-md bg-black px-3 py-2 text-white">
            Rechercher
          </button>
        </form>
      )}

      {!site && sitesTrouves.length > 0 && (
        <ul className="flex flex-col gap-1 text-sm">
          {sitesTrouves.map((s) => (
            <li key={s.id}>
              <Link href={`/devis/nouveau?famille=${famille}&site=${s.id}`} className="underline">
                {s.nom} ({s.ville})
              </Link>
            </li>
          ))}
        </ul>
      )}

      <form action={creerDevis} className="flex flex-col gap-4 rounded-xl border p-6">
        <Champ label="Famille *">
          <select name="famille" defaultValue={famille} required className={CHAMP}>
            {FAMILLES_DEVIS.map((f) => (
              <option key={f} value={f}>
                {LIBELLES_FAMILLE[f]}
              </option>
            ))}
          </select>
        </Champ>

        <Champ label="Site *">
          {site ? (
            <>
              <input type="hidden" name="site_id" value={site.id} />
              <div className="rounded-md border bg-black/[0.02] px-3 py-2 dark:bg-white/[0.03]">
                {site.nom} ({site.ville}) · {client?.nom}
              </div>
            </>
          ) : (
            <div className="rounded-md border border-dashed px-3 py-2 text-xs opacity-60">Recherchez et sélectionnez un site ci-dessus.</div>
          )}
        </Champ>

        <Champ label="Fichier PDF (chemin)">
          <input name="fichier_chemin" className={CHAMP} placeholder="\\serveur\devis\AB-1234-Libellé.pdf" />
        </Champ>

        <Champ label="Numéro (déduit du nom de fichier si vide, motif XX-NNNN)">
          <input name="numero" className={CHAMP} />
        </Champ>

        {site && (
          <Champ label="Intervention d'origine">
            <select name="intervention_origine_id" defaultValue={sp.intervention ?? ""} className={CHAMP}>
              <option value="">—</option>
              {(interventionsSite ?? []).map((i) => (
                <option key={i.id} value={i.id}>
                  #{i.id} · {formatDate(i.date_demande)} · {i.objet}
                </option>
              ))}
            </select>
          </Champ>
        )}

        <div className="grid grid-cols-2 gap-3">
          <Champ label="Type de panne">
            <select name="type_panne_libelle" className={CHAMP}>
              <option value="">—</option>
              {(pannes ?? []).map((p) => (
                <option key={p.libelle} value={p.libelle}>
                  {p.libelle}
                </option>
              ))}
            </select>
          </Champ>
          <Champ label="Nb machines concernées">
            <input name="quantite_materiel" type="number" min={0} className={CHAMP} />
          </Champ>
        </div>

        <div className="grid grid-cols-3 gap-3">
          <Champ label="Montant fournitures">
            <input name="montant_fournitures" type="number" step="0.01" className={CHAMP} />
          </Champ>
          <Champ label="Heures main d'œuvre">
            <input name="heures_mo" type="number" step="0.25" className={CHAMP} />
          </Champ>
          <Champ label="Nb déplacements">
            <input name="nombre_deplacements" type="number" min={0} className={CHAMP} />
          </Champ>
          <Champ label="Tarif heure MO">
            <input name="tarif_heure_mo" type="number" step="0.01" defaultValue={site?.tarifs.tarif_heure_mo ?? ""} className={CHAMP} />
          </Champ>
          <Champ label="Tarif déplacement">
            <input name="tarif_deplacement" type="number" step="0.01" defaultValue={site?.tarifs.tarif_deplacement ?? ""} className={CHAMP} />
          </Champ>
          <Champ label="Montant HT (calculé si vide)">
            <input name="montant_ht" type="number" step="0.01" className={CHAMP} />
          </Champ>
        </div>
        <p className="text-xs opacity-60">
          Tarifs pré-remplis depuis le {site?.tarifs_specifiques ? "site (tarifs spécifiques)" : "client"}. Montant HT = fournitures + heures × tarif heure +
          déplacements × tarif déplacement.
        </p>

        <div className="grid grid-cols-2 gap-3">
          <Champ label="Date du devis">
            <input name="date_devis" type="date" defaultValue={new Date().toISOString().slice(0, 10)} className={CHAMP} />
          </Champ>
          <Champ label="Envoyé par">
            <select name="envoye_par_id" defaultValue={current?.utilisateur?.id ?? ""} className={CHAMP}>
              <option value="">—</option>
              {(gestionnaires ?? []).map((g) => (
                <option key={g.id} value={g.id}>
                  {[g.prenom, g.nom].filter(Boolean).join(" ")}
                </option>
              ))}
            </select>
          </Champ>
        </div>

        <Champ label="Commentaire client">
          <textarea name="commentaire_client" rows={3} className={CHAMP} />
        </Champ>

        <button type="submit" className="rounded-md bg-black py-2 font-medium text-white">
          Créer
        </button>
      </form>
    </div>
  );
}
