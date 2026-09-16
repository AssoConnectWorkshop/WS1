import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Chemin } from "@/components/ui/Chemin";
import { EmptyState } from "@/components/ui/EmptyState";
import { formatMontant, formatNom } from "@/lib/format";
import type { FamilleDevis } from "@/lib/devis";
import { genererIntervention } from "@/app/(app)/devis/actions";

export type DevisAccess = {
  id: number;
  famille: string;
  numero: string | null;
  statut_code: number | null;
  fichier_chemin: string | null;
  intervention_origine_id: number | null;
  site_id: number | null;
  client_id: number | null;
  numero_devis_partenaire: string | null;
  type_panne_libelle: string | null;
  quantite_materiel: number | null;
  montant_fournitures: number | null;
  heures_mo: number | null;
  tarif_heure_mo: number | null;
  nombre_deplacements: number | null;
  tarif_deplacement: number | null;
  montant_ht: number | null;
  date_envoi: string | null;
  envoye_par_id: number | null;
};

const STATUT_ACCEPTE = 6;
const CHAMP = "rounded border bg-white px-1.5 py-0.5 text-xs dark:bg-white/5";
const LECTURE = "rounded border bg-white px-1.5 py-0.5 text-xs dark:bg-white/5";

/**
 * Sous-formulaire Access DevisListe / DevisListeTravaux / DevisListeContratDeMaintenance : barre de
 * filtres (Etat, Envoyé par, Type de panne, Entre le / et) puis une fiche par devis, fond rouge si accepté.
 */
export async function ListeDevisAccess({
  devis,
  famille,
  siteId,
  clientNom,
  siteNom,
  filtres,
}: {
  devis: DevisAccess[];
  famille: FamilleDevis;
  siteId: number;
  clientNom: string | null;
  siteNom: string | null;
  filtres: Record<string, string | undefined>;
}) {
  const supabase = await createClient();
  const [{ data: statuts }, { data: gestionnaires }] = await Promise.all([
    supabase.from("statuts_devis").select("code, libelle").order("code"),
    supabase.from("utilisateurs").select("id, nom, prenom").in("profil", [1, 3]).order("nom"),
  ]);
  const libelleStatut = (code: number | null) => statuts?.find((s) => s.code === code)?.libelle ?? "";
  const nomGestionnaire = (id: number | null) => {
    const u = gestionnaires?.find((g) => g.id === id);
    return u ? formatNom(u.prenom, u.nom) : "";
  };

  let liste = devis.filter((d) => d.famille === famille);
  if (filtres.etat) liste = liste.filter((d) => String(d.statut_code) === filtres.etat);
  if (filtres.envoye_par) liste = liste.filter((d) => String(d.envoye_par_id) === filtres.envoye_par);
  if (filtres.panne) liste = liste.filter((d) => (d.type_panne_libelle ?? "").toLowerCase().includes(filtres.panne!.toLowerCase()));
  if (filtres.envoi_debut) liste = liste.filter((d) => d.date_envoi && d.date_envoi >= filtres.envoi_debut!);
  if (filtres.envoi_fin) liste = liste.filter((d) => d.date_envoi && d.date_envoi <= filtres.envoi_fin!);

  const LIGNE = "grid grid-cols-[7rem_1fr] items-center gap-x-2 gap-y-1 text-xs";

  return (
    <div className="flex flex-col gap-2">
      <form method="GET" className="grid gap-2 rounded border bg-rose-50 p-3 text-xs dark:bg-rose-950/20 sm:grid-cols-[1fr_1fr_1fr_auto]">
        {Object.entries(filtres)
          .filter(([k, v]) => v && !["etat", "envoye_par", "panne", "envoi_debut", "envoi_fin"].includes(k))
          .map(([k, v]) => (
            <input key={k} type="hidden" name={k} value={v} />
          ))}
        <div className={LIGNE}>
          <span className="text-right">Client</span>
          <input disabled value={clientNom ?? ""} className={`${CHAMP} opacity-70`} />
          <span className="text-right">Site</span>
          <input disabled value={siteNom ?? ""} className={`${CHAMP} opacity-70`} />
        </div>
        <div className={LIGNE}>
          <span className="text-right">Etat</span>
          <select name="etat" defaultValue={filtres.etat ?? ""} className={CHAMP}>
            <option value=""></option>
            {(statuts ?? []).map((s) => (
              <option key={s.code} value={s.code}>
                {s.libelle}
              </option>
            ))}
          </select>
          <span className="text-right">Envoyé par</span>
          <select name="envoye_par" defaultValue={filtres.envoye_par ?? ""} className={CHAMP}>
            <option value=""></option>
            {(gestionnaires ?? []).map((g) => (
              <option key={g.id} value={g.id}>
                {formatNom(g.prenom, g.nom)}
              </option>
            ))}
          </select>
        </div>
        <div className={LIGNE}>
          <span className="text-right">Type de panne</span>
          <input name="panne" defaultValue={filtres.panne ?? ""} className={CHAMP} />
          <span className="text-right">Entre le</span>
          <div className="grid grid-cols-[1fr_auto_1fr] items-center gap-1">
            <input type="date" name="envoi_debut" defaultValue={filtres.envoi_debut ?? ""} className={CHAMP} />
            <span>et</span>
            <input type="date" name="envoi_fin" defaultValue={filtres.envoi_fin ?? ""} className={CHAMP} />
          </div>
        </div>
        <div className="flex flex-col gap-1">
          <button type="submit" className="rounded border bg-white px-2 py-1 dark:bg-white/5">
            Rechercher
          </button>
          <Link href={`/devis/nouveau?site=${siteId}&famille=${famille}`} className="rounded border bg-white px-2 py-1 text-center dark:bg-white/5">
            Rendre Insertion Devis Possible
          </Link>
        </div>
      </form>

      {liste.length === 0 ? (
        <EmptyState message="Aucun devis pour ces critères." />
      ) : (
        <div className="flex flex-col divide-y rounded border">
          {liste.map((d) => {
            const accepte = d.statut_code === STATUT_ACCEPTE;
            return (
              <div key={d.id} className={`grid gap-2 p-2 text-xs lg:grid-cols-[1.3fr_1fr_1fr_8rem] ${accepte ? "bg-red-600 text-white" : ""}`}>
                <div className="grid grid-cols-[7.5rem_1fr] items-center gap-x-2 gap-y-1">
                  <span className="text-right">Client</span>
                  <span className={`${LECTURE} truncate text-black`}>{clientNom}</span>
                  <span className="text-right">Nom Fichier Devis</span>
                  <span className={`${LECTURE} truncate text-black`} title={d.fichier_chemin ?? ""}>
                    {d.fichier_chemin ? d.fichier_chemin.split(/[\\/]/).pop() : ""}
                  </span>
                  <span className="text-right">N° Devis</span>
                  <Link href={`/devis/${d.id}`} className={`${LECTURE} text-black underline`}>
                    {d.numero ?? `#${d.id}`}
                  </Link>
                  <span className="text-right">Etat</span>
                  <span className={`${LECTURE} text-black`}>{libelleStatut(d.statut_code)}</span>
                  <span className="text-right">Envoyé par</span>
                  <span className={`${LECTURE} text-black`}>{nomGestionnaire(d.envoye_par_id)}</span>
                  <span className="text-right">Envoyé le</span>
                  <span className={`${LECTURE} text-black`}>{d.date_envoi ?? ""}</span>
                </div>
                <div className="grid grid-cols-[8rem_1fr] items-center gap-x-2 gap-y-1">
                  <span className="text-right">Site</span>
                  <span className={`${LECTURE} truncate text-black`}>{siteNom}</span>
                  <span className="text-right">Devis Partenaire</span>
                  <span className={`${LECTURE} text-black`}>{d.numero_devis_partenaire ?? ""}</span>
                  <span className="text-right">Type de panne</span>
                  <span className={`${LECTURE} text-black`}>{d.type_panne_libelle ?? ""}</span>
                  <span className="text-right">Nb Machines concernées par l&apos;intervention</span>
                  <span className={`${LECTURE} text-black`}>{d.quantite_materiel ?? ""}</span>
                </div>
                <div className="grid grid-cols-[9rem_1fr_5rem] items-center gap-x-2 gap-y-1">
                  <span className="text-right">Intervention</span>
                  <span className={`${LECTURE} col-span-2 text-black`}>
                    {d.intervention_origine_id ? (
                      <Link href={`/interventions/${d.intervention_origine_id}`} className="underline">
                        {d.intervention_origine_id}
                      </Link>
                    ) : (
                      ""
                    )}
                  </span>
                  <span className="text-right">Montant Fourniture</span>
                  <span className={`${LECTURE} col-span-2 text-right text-black`}>{formatMontant(d.montant_fournitures).replace("—", "")}</span>
                  <span className="text-right">Qté Heure Main Oeuvre</span>
                  <span className={`${LECTURE} text-right text-black`}>{d.heures_mo ?? 0} *</span>
                  <span className={`${LECTURE} text-right text-black`}>{formatMontant(d.tarif_heure_mo).replace("—", "")}</span>
                  <span className="text-right">Nbre Déplacement</span>
                  <span className={`${LECTURE} text-right text-black`}>{d.nombre_deplacements ?? 0} *</span>
                  <span className={`${LECTURE} text-right text-black`}>{formatMontant(d.tarif_deplacement).replace("—", "")}</span>
                  <span className="text-right font-semibold">Montant HT</span>
                  <span className={`${LECTURE} col-span-2 text-right font-semibold text-black`}>{formatMontant(d.montant_ht).replace("—", "")}</span>
                </div>
                <div className="flex flex-col gap-1">
                  {!accepte && (
                    <form action={genererIntervention}>
                      <input type="hidden" name="devis_id" value={d.id} />
                      <button type="submit" className="w-full rounded border bg-white px-1 py-1 text-center text-[11px] text-black">
                        Générer intervention suite à accord devis
                      </button>
                    </form>
                  )}
                  {d.fichier_chemin ? (
                    <span className="rounded border bg-white px-1 py-1 text-center text-[11px] text-black">
                      <Chemin value={d.fichier_chemin} />
                    </span>
                  ) : (
                    <span className="rounded border bg-white px-1 py-1 text-center text-[11px] text-black opacity-50">Vers Fichier</span>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
      <div className="text-xs opacity-70">Enr : {liste.length} sur {devis.filter((d) => d.famille === famille).length}</div>
    </div>
  );
}
