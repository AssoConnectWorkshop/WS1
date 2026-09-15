-- Étape 4 (écrans de consultation) : quelques colonnes manquaient aux vues de l'étape 1
-- pour les filtres décrits dans docs/plan/etape-4.md (zone_id pour un filtre multi-zones,
-- donneur d'ordre, sous-type, particulier, retard de paiement, ne plus intervenir,
-- investissement). `create or replace view` conserve les colonnes existantes.

-- create or replace view exige que les colonnes existantes gardent leur ordre/nom/type ;
-- plus simple et plus sûr de recréer ces deux vues (rien d'autre n'en dépend).
drop view if exists public.v_interventions_liste;
drop view if exists public.v_sites_liste;

create view public.v_interventions_liste as
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
  d2.numero as devis_lie_numero
from public.interventions i
join public.sites s on s.id = i.site_id
join public.clients c on c.id = s.client_id
left join public.donneurs_ordre d on d.id = s.donneur_ordre_id
left join public.zones_geographiques z on z.id = s.zone_id
left join public.types_intervention ti on ti.code = i.type_code
left join public.statuts_intervention si on si.code = i.statut_code
left join public.intervenants iv on iv.id = i.intervenant_id
left join public.utilisateurs u on u.id = i.charge_affaire_id
left join public.statuts_facturation sf on sf.code = i.statut_facturation_code
left join public.devis d2 on d2.intervention_origine_id = i.id
where c.actif is true;

create view public.v_sites_liste as
select
  s.id,
  s.legacy_id,
  s.numero_magasin,
  s.code_client,
  s.nom,
  s.adresse,
  s.code_postal,
  s.ville,
  s.telephone,
  s.longitude,
  s.latitude,
  s.particulier,
  s.investissement,
  s.retard_paiement,
  s.ne_plus_intervenir,
  s.ferme,
  s.zone_id,
  s.donneur_ordre_id,
  c.id as client_id,
  c.nom as client_nom,
  c.tarif_heure_mo as client_tarif_heure_mo,
  c.tarif_deplacement as client_tarif_deplacement,
  z.libelle as zone_libelle,
  iv.id as intervenant_id,
  iv.nom as intervenant_nom,
  sc.numero_contrat as contrat_clim_numero,
  sc.visites_par_an as contrat_clim_visites_par_an,
  sc.redevance as contrat_clim_redevance,
  sc.sous_traitant_id as contrat_clim_sous_traitant_id,
  s.date_derniere_visite_entretien
from public.sites s
join public.clients c on c.id = s.client_id
left join public.zones_geographiques z on z.id = s.zone_id
left join public.intervenants iv on iv.id = s.intervenant_id
left join public.site_contrats sc on sc.site_id = s.id and sc.lot = 'clim'
where c.actif is true;
