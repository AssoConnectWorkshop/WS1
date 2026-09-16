import { VUE_FILTERS } from "@/lib/vues-tableau-de-bord";

/** Filtres de la liste des interventions (écran et export Excel) appliqués à `v_interventions_liste`. */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function appliquerFiltresInterventions(query: any, sp: Record<string, string | undefined>, zonesSel: string[]) {
  const vue = sp.vue ? VUE_FILTERS[sp.vue] : undefined;
  if (vue) {
    if (vue.statut_code != null) query = query.eq("statut_code", vue.statut_code);
    if (vue.statut_facturation_code != null) query = query.eq("statut_facturation_code", vue.statut_facturation_code);
    if (vue.devis_a_faire != null) query = query.eq("devis_a_faire", vue.devis_a_faire);
  }

  if (sp.client) query = query.ilike("client_nom", `%${sp.client}%`);
  if (sp.client_id) query = query.eq("client_id", Number(sp.client_id));
  if (sp.site) {
    const n = Number(sp.site);
    query = Number.isFinite(n) && sp.site.trim() !== "" ? query.or(`numero_magasin.eq.${n},site_nom.ilike.%${sp.site}%`) : query.ilike("site_nom", `%${sp.site}%`);
  }
  if (sp.type) query = query.eq("type_code", Number(sp.type));
  if (sp.statut) {
    // Access (Filtre_OM_Test) : « Afficher les clôturées » étend le statut choisi à `in (<statut>, 7)`.
    query = sp.clotures === "1" ? query.in("statut_code", [Number(sp.statut), 7]) : query.eq("statut_code", Number(sp.statut));
  } else if (!vue?.statut_code && !sp.facturation && !vue?.statut_facturation_code && sp.clotures !== "1") {
    // Le statut de facturation n'est posé qu'après clôture : un filtre facturation doit inclure les clôturées.
    query = query.neq("statut_code", 7);
  }
  if (sp.intervenant) query = query.eq("intervenant_id", Number(sp.intervenant));
  if (sp.donneur) query = query.eq("donneur_ordre_id", Number(sp.donneur));
  if (sp.facturation) query = query.eq("statut_facturation_code", Number(sp.facturation));
  if (zonesSel.length) query = query.in("zone_id", zonesSel.map(Number));

  const champPeriode = sp.periode_champ === "realisee" ? "date_realisee" : "date_limite";
  if (sp.periode_debut) query = query.gte(champPeriode, sp.periode_debut);
  if (sp.periode_fin) query = query.lte(champPeriode, sp.periode_fin);

  if (sp.devis_a_faire === "1") query = query.eq("devis_a_faire", true);
  if (sp.audit_fait === "1") query = query.eq("audit_fait", true);
  if (sp.controle_etancheite === "1") query = query.eq("controle_etancheite_annuel", true);
  if (sp.photo_faite === "1") query = query.eq("photo_faite", true);
  if (sp.registre_maj === "1") query = query.eq("registre_securite_mis_a_jour", true);
  if (sp.sous_type_vide === "1") query = query.is("sous_type_code", null);
  if (sp.particulier === "1") query = query.eq("particulier", true);
  if (sp.entretien_proche === "1") {
    // Simplification documentée (règle exacte legacy/analysis/02_interventions.md §8.1 non
    // reprise à l'identique) : entretien (type 1) à planifier (statut 1) dans les 30 jours.
    const today = new Date();
    const in30 = new Date(today.getTime() + 30 * 86400000);
    query = query.eq("type_code", 1).eq("statut_code", 1).gte("date_limite", today.toISOString()).lte("date_limite", in30.toISOString());
  }

  return query;
}

/** Recompose la chaîne de requête de la liste (filtres et zones multiples) pour l'export. */
export function chaineFiltres(raw: Record<string, string | string[] | undefined>) {
  const q = new URLSearchParams();
  for (const [k, v] of Object.entries(raw)) {
    if (v == null || k === "page") continue;
    for (const x of Array.isArray(v) ? v : [v]) if (x !== "") q.append(k, x);
  }
  return q.toString();
}
