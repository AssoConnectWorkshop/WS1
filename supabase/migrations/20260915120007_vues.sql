-- Vues de consultation pour l'étape 4 (écrans de consultation).

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
  c.id as client_id,
  c.nom as client_nom,
  z.libelle as zone_libelle,
  i.type_code,
  ti.libelle as type_libelle,
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
  i.numero_demande_sous_traitant,
  i.commentaire_devis,
  i.commentaire_devis_interne,
  i.montant_fmc,
  i.montant_sous_traitant,
  i.non_facturable,
  d.id as devis_lie_id,
  d.numero as devis_lie_numero
from public.interventions i
join public.sites s on s.id = i.site_id
join public.clients c on c.id = s.client_id
left join public.zones_geographiques z on z.id = s.zone_id
left join public.types_intervention ti on ti.code = i.type_code
left join public.statuts_intervention si on si.code = i.statut_code
left join public.intervenants iv on iv.id = i.intervenant_id
left join public.statuts_facturation sf on sf.code = i.statut_facturation_code
left join public.devis d on d.intervention_origine_id = i.id
where c.actif is true;
comment on view public.v_interventions_liste is 'Équivalent cible de la vue SQL Server ListeInterventionGenerale (legacy/sql_modules.sql), colonnes renommées.';

create or replace view public.v_sites_liste as
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
  s.date_derniere_visite_entretien,
  s.ferme
from public.sites s
join public.clients c on c.id = s.client_id
left join public.zones_geographiques z on z.id = s.zone_id
left join public.intervenants iv on iv.id = s.intervenant_id
left join public.site_contrats sc on sc.site_id = s.id and sc.lot = 'clim'
where c.actif is true;
comment on view public.v_sites_liste is 'Équivalent cible de la vue SQL Server ListeSite (legacy/sql_modules.sql) : site + client + contrat clim + zone + intervenant.';

create or replace view public.v_tableau_de_bord as
select
  (select count(*) from public.interventions where statut_code = 9) as a_valider,
  (select count(*) from public.interventions where statut_facturation_code = 1) as a_facturer,
  (select count(*) from public.interventions where statut_facturation_code = 8) as a_definir_direction,
  (select count(*) from public.interventions where statut_facturation_code = 9) as stand_by,
  (select count(*) from public.interventions where statut_code = -1) as materiel_a_commander,
  (select count(*) from public.interventions where statut_code = 2) as attente_materiel,
  (select count(*) from public.interventions where statut_code = 7 and devis_a_faire) as duplicata_total,
  (select count(*) from public.interventions where statut_code = 7 and devis_a_faire and duplicata_traite is false) as duplicata_a_traiter,
  (select count(*) from public.interventions where statut_code = 7 and devis_a_faire and duplicata_traite is true) as duplicata_traitees,
  (select count(*) from public.interventions where statut_facturation_code in (1,2) and type_code = 2) as depannage,
  (select count(*) from public.interventions where statut_facturation_code in (1,2) and type_code = 1) as maintenances,
  (select count(*) from public.interventions where statut_facturation_code in (1,2) and type_code = 3) as devis_sav_acceptes,
  (select count(*) from public.interventions where statut_facturation_code in (1,2) and type_code = 5) as en_travaux,
  (select count(*) from public.interventions where statut_facturation_code in (1,2) and type_code not in (1,2,3,5)) as autres;
comment on view public.v_tableau_de_bord is 'Compteurs de l''écran d''accueil (legacy/analysis/01_navigation_parametrage.md §2.1).';
