-- Étape 8 : colonnes de la liste générale Access (Form_ListeInterventionGenerale) : sous-type,
-- urgence du devis, duplicata traité / à traiter par. Colonnes ajoutées en fin de vue.
create or replace view public.v_interventions_liste as
select
  i.id,
  i.legacy_id,
  i.numero_bon,
  i.site_id,
  s.numero_magasin,
  s.nom as site_nom,
  s.adresse as site_adresse,
  s.code_postal as site_code_postal,
  s.ville as site_ville,
  s.telephone as site_telephone,
  s.longitude,
  s.latitude,
  s.particulier,
  s.zone_id,
  s.donneur_ordre_id,
  d.nom as donneur_ordre_nom,
  c.id as client_id,
  c.nom as client_nom,
  z.libelle as zone_libelle,
  i.type_code,
  ti.libelle as type_libelle,
  i.sous_type_code,
  i.statut_code,
  si.libelle as statut_libelle,
  i.intervenant_id,
  iv.nom as intervenant_nom,
  i.statut_facturation_code,
  sf.libelle as statut_facturation_libelle,
  i.objet,
  i.date_demande,
  i.date_limite,
  i.date_prevue,
  i.date_realisee,
  i.chemin_bon_pdf,
  i.devis_a_faire,
  i.devis_fait,
  i.devis_ne_sera_pas_fait,
  i.numero_devis_accepte,
  i.registre_securite_mis_a_jour,
  i.controle_etancheite_annuel,
  i.photo_faite,
  i.audit_fait,
  i.commentaire_interne,
  i.reference_client,
  i.reference_interne,
  i.numero_demande_sous_traitant,
  i.commentaire_devis,
  i.commentaire_devis_interne,
  i.montant_fmc,
  i.montant_sous_traitant,
  i.non_facturable,
  i.minutes_telephone,
  i.charge_affaire_id,
  u.nom as charge_affaire_nom,
  d2.id as devis_lie_id,
  d2.numero as devis_lie_numero,
  i.technicien_prevu_id,
  nullif(trim(concat_ws(' ', tp.prenom, tp.nom)), '') as technicien_prevu_nom,
  s.commentaire_general as site_commentaire_general,
  s.date_derniere_visite_entretien as site_date_derniere_visite_entretien,
  iv.code as intervenant_code,
  iv.est_sous_traitant_ponctuel as intervenant_ponctuel,
  st.libelle as sous_type_libelle,
  i.urgence_devis,
  i.duplicata_traite,
  nullif(trim(concat_ws(' ', dt.prenom, dt.nom)), '') as duplicata_traite_par_nom
from public.interventions i
join public.sites s on s.id = i.site_id
join public.clients c on c.id = s.client_id
left join public.donneurs_ordre d on d.id = s.donneur_ordre_id
left join public.zones_geographiques z on z.id = s.zone_id
left join public.types_intervention ti on ti.code = i.type_code
left join public.sous_types_intervention st on st.code = i.sous_type_code
left join public.statuts_intervention si on si.code = i.statut_code
left join public.intervenants iv on iv.id = i.intervenant_id
left join public.utilisateurs u on u.id = i.charge_affaire_id
left join public.utilisateurs tp on tp.id = i.technicien_prevu_id
left join public.utilisateurs dt on dt.id = i.duplicata_traite_par_id
left join public.statuts_facturation sf on sf.code = i.statut_facturation_code
left join public.devis d2 on d2.intervention_origine_id = i.id
where c.actif is true;
