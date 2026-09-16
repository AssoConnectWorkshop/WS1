import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { toArrayParam, toStringParams } from "@/lib/list-params";
import { CarteClient } from "@/components/carte/CarteClient";
import { couleurType, svgEpingle, type PointCarte } from "@/components/carte/CarteInterventions";
import { formatDate } from "@/lib/format";

export const dynamic = "force-dynamic";

/** Légende / filtre par type du module carte, dans l'ordre de la capture (codes `types_intervention`). */
const TYPES_LEGENDE: { code: number; label: string }[] = [
  { code: 1, label: "Maintenance" },
  { code: 2, label: "Dépannage" },
  { code: 3, label: "Devis SAV" },
  { code: 12, label: "Devis SAV (Pour TR)" },
  { code: 5, label: "En Travaux" },
  { code: 7, label: "Désenfumage" },
  { code: 9, label: "Audit" },
  { code: 13, label: "Entretien Chaudière" },
];
const STATUT_ATTENTE_FICHE = 19;
const STATUTS_LEGENDE: { statut: number; label: string }[] = [
  { statut: 1, label: "A planifier (Attente Fiche)" },
  { statut: -1, label: "A Commander" },
  { statut: 2, label: "En attente de matériel" },
];

function Epingle({ couleur }: { couleur: string }) {
  return <span className="inline-block h-[17px] w-3 align-middle" dangerouslySetInnerHTML={{ __html: svgEpingle(couleur).replace('width="24" height="34"', 'width="12" height="17"') }} />;
}

/** Carte des interventions à réaliser (module PHP « Carte des interventions », Form_Carte) : une épingle par site, info-bulle Access. */
export default async function CartePage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const raw = await searchParams;
  const sp = toStringParams(raw);
  const typesSel = toArrayParam(raw.types).map(Number);
  const tout = sp.tout === "1" || (typesSel.length === 0 && sp.attente_fiche !== "1");
  const supabase = await createClient();

  const { data: techniciens } = await supabase.from("utilisateurs").select("id, nom, prenom").in("profil", [2, 3]).order("nom");

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let query: any = supabase
    .from("v_interventions_liste")
    .select(
      "id, site_id, latitude, longitude, type_code, type_libelle, statut_code, statut_libelle, client_nom, site_nom, site_adresse, site_code_postal, site_ville, zone_libelle, date_limite, date_prevue, date_realisee, intervenant_nom, technicien_prevu_nom, commentaire_interne, objet, site_commentaire_general, site_date_derniere_visite_entretien",
    )
    .not("latitude", "is", null)
    .not("longitude", "is", null)
    .limit(3000);
  if (sp.clotures === "1") query = query.in("statut_code", [7]);
  else query = query.not("statut_code", "in", "(7,8,10,20)");
  if (!tout) {
    const conditions = [typesSel.length ? `type_code.in.(${typesSel.join(",")})` : null, sp.attente_fiche === "1" ? `statut_code.eq.${STATUT_ATTENTE_FICHE}` : null].filter(Boolean);
    query = query.or(conditions.join(","));
  }
  if (sp.client) query = query.ilike("client_nom", `%${sp.client}%`);
  if (sp.technicien) query = query.eq("technicien_prevu_id", Number(sp.technicien));
  if (sp.intervenant_fmc === "1") query = query.eq("intervenant_code", "FMC");
  if (sp.intervenant_ponctuel === "1") query = query.eq("intervenant_ponctuel", true);
  if (sp.periode_debut) query = query.gte("date_limite", sp.periode_debut);
  if (sp.periode_fin) query = query.lte("date_limite", sp.periode_fin);

  type LigneCarte = {
    id: number;
    site_id: number;
    latitude: string | number;
    longitude: string | number;
    type_code: number | null;
    type_libelle: string | null;
    statut_code: number | null;
    statut_libelle: string | null;
    client_nom: string | null;
    site_nom: string | null;
    site_adresse: string | null;
    site_code_postal: string | null;
    site_ville: string | null;
    zone_libelle: string | null;
    date_limite: string | null;
    date_prevue: string | null;
    date_realisee: string | null;
    intervenant_nom: string | null;
    technicien_prevu_nom: string | null;
    commentaire_interne: string | null;
    objet: string | null;
    site_commentaire_general: string | null;
    site_date_derniere_visite_entretien: string | null;
  };
  const { data } = (await query) as { data: LigneCarte[] | null };

  const maintenant = Date.now();
  const points: PointCarte[] = (data ?? []).map((i) => ({
    id: i.id,
    site_id: i.site_id,
    latitude: Number(i.latitude),
    longitude: Number(i.longitude),
    type_code: i.type_code,
    type_libelle: i.type_libelle,
    statut_code: i.statut_code,
    statut_libelle: i.statut_libelle,
    client_nom: i.client_nom,
    site_nom: i.site_nom,
    adresse: i.site_adresse,
    code_postal: i.site_code_postal,
    ville: i.site_ville,
    zone_libelle: i.zone_libelle,
    intervenant_nom: i.intervenant_nom,
    technicien_prevu_nom: i.technicien_prevu_nom,
    date_limite: i.date_limite,
    date_prevue: i.date_prevue,
    date_derniere_visite: i.site_date_derniere_visite_entretien,
    commentaire_site: i.site_commentaire_general,
    commentaire_intervention: [i.objet, i.commentaire_interne].filter(Boolean).join("\n") || null,
    depassee: !!i.date_limite && new Date(i.date_limite).getTime() < maintenant && !i.date_realisee,
  }));

  const CASE = "flex items-center gap-1 whitespace-nowrap";
  const CHAMP = "rounded border px-1 py-0.5 text-xs";

  return (
    <div className="flex flex-col gap-2 px-3 py-2">
      <form method="GET" className="flex flex-col gap-1.5 text-xs">
        <div className="flex flex-wrap items-center gap-3">
          <Link href="/" className="text-sm font-bold text-blue-700">
            Retour Menu
          </Link>
          <span className="text-sm">
            <b>- Carte</b> des interventions à réaliser du{" "}
            <input type="date" name="periode_debut" defaultValue={sp.periode_debut ?? ""} className={CHAMP} /> au <input type="date" name="periode_fin" defaultValue={sp.periode_fin ?? ""} className={CHAMP} />{" "}
            Nb Résultats : <b>{points.length}</b>
            {points.length >= 3000 ? " (limite atteinte, affinez les filtres)" : ""}
          </span>
          <span className="ml-auto flex flex-wrap items-center gap-3">
            {STATUTS_LEGENDE.map((s) => (
              <span key={s.statut} className={CASE}>
                <Epingle couleur={couleurType(null, s.statut)} />
                <b>{s.label}</b>
              </span>
            ))}
            <span className={CASE}>
              <Epingle couleur={couleurType(3, null)} />
              <b>Devis SAV</b>
            </span>
          </span>
        </div>
        <div className="flex flex-wrap items-center gap-3">
          {TYPES_LEGENDE.map((t) => (
            <label key={t.code} className={CASE}>
              <Epingle couleur={couleurType(t.code, null)} />
              <input type="checkbox" name="types" value={t.code} defaultChecked={typesSel.includes(t.code)} />
              {t.label}
            </label>
          ))}
          <label className={CASE}>
            <input type="checkbox" name="attente_fiche" value="1" defaultChecked={sp.attente_fiche === "1"} />
            Attente Fiche
          </label>
          <label className={CASE}>
            <input type="checkbox" name="tout" value="1" defaultChecked={tout} />
            Tout
          </label>
          <select name="technicien" defaultValue={sp.technicien ?? ""} className={`${CHAMP} min-w-36`}>
            <option value="">Technicien…</option>
            {(techniciens ?? []).map((t) => (
              <option key={t.id} value={t.id}>
                {[t.nom, t.prenom].filter(Boolean).join(" ")}
              </option>
            ))}
          </select>
          <label className={CASE}>
            <input type="checkbox" name="intervenant_fmc" value="1" defaultChecked={sp.intervenant_fmc === "1"} />
            Intervenant FMC
          </label>
          <label className={CASE}>
            <Epingle couleur="#ffffff" />
            <input type="checkbox" name="intervenant_ponctuel" value="1" defaultChecked={sp.intervenant_ponctuel === "1"} />
            Intervenant Ponctuel
          </label>
          <input type="text" name="client" placeholder="Client" defaultValue={sp.client ?? ""} className={`${CHAMP} w-32`} />
          <label className={CASE}>
            <input type="checkbox" name="clotures" value="1" defaultChecked={sp.clotures === "1"} />
            Clôturées
          </label>
          <button type="submit" className="rounded bg-black px-2 py-0.5 text-white">
            Afficher
          </button>
          <a href="/carte" className="rounded border px-2 py-0.5">
            Réinitialiser la carte
          </a>
          <span className="opacity-60">Cercle orange : date limite dépassée{sp.periode_debut || sp.periode_fin ? ` · période du ${formatDate(sp.periode_debut)} au ${formatDate(sp.periode_fin)}` : ""}</span>
        </div>
      </form>
      <CarteClient points={points} />
    </div>
  );
}
