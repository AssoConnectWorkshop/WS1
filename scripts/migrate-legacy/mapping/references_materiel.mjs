import { trim, parsePuissance } from '../lib/transform.mjs';

// Absent de legacy/referentiels.txt (catalogue de 764 modèles) : chargé ici directement
// depuis la source (étape 2). Nommar/Fluide résolus par libellé (pas de FK en source).
export default {
  target: 'references_materiel',
  conflictColumns: ['legacy_id'],
  lookups: [
    { name: 'marqueIdByLibelle', table: 'marques', column: 'libelle' },
    { name: 'fluideIdByLibelle', table: 'types_fluide', column: 'libelle' },
  ],
  source: `
    select id, Reference, Repere, [Type], Nommar, Fluide, TypeTel, Reversible, Resistance,
           PuissanceFrigo, PuissanceCalo, QteGaz, NbFiltres, DimFiltres, NbCourroies,
           RefCourroies, AppointRoof
    from Reference
  `,
  transform(row, ctx) {
    const puissanceFrigo = parsePuissance(row.PuissanceFrigo);
    const puissanceCalo = parsePuissance(row.PuissanceCalo);
    const nommar = trim(row.Nommar);
    const fluide = trim(row.Fluide);

    return {
      legacy_id: row.id,
      reference: trim(row.Reference),
      repere: trim(row.Repere),
      type_equipement: trim(row.Type),
      marque_id: nommar ? ctx.get('marqueIdByLibelle').get(nommar) ?? null : null,
      fluide_id: fluide ? ctx.get('fluideIdByLibelle').get(fluide) ?? null : null,
      type_telecommande: trim(row.TypeTel),
      reversible: trim(row.Reversible),
      resistance: trim(row.Resistance),
      puissance_frigo: puissanceFrigo.valeur,
      puissance_frigo_brut: puissanceFrigo.brut,
      puissance_calo: puissanceCalo.valeur,
      puissance_calo_brut: puissanceCalo.brut,
      quantite_gaz: trim(row.QteGaz),
      nombre_filtres: trim(row.NbFiltres),
      dimension_filtres: trim(row.DimFiltres),
      nombre_courroies: trim(row.NbCourroies),
      reference_courroies: trim(row.RefCourroies),
      appoint_roof: trim(row.AppointRoof),
    };
  },
};
