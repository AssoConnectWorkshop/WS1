-- Étape 8 : première colonne de la liste des sites Access (lien vers le dossier réseau du site).
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
  s.date_derniere_visite_entretien,
  s.rdv_a_prendre,
  d.nom as donneur_ordre_nom,
  sc.redevance_secondaire as contrat_clim_redevance_secondaire,
  s.commentaire_general,
  s.precision_geo,
  s.dossier_chemin
from public.sites s
join public.clients c on c.id = s.client_id
left join public.zones_geographiques z on z.id = s.zone_id
left join public.intervenants iv on iv.id = s.intervenant_id
left join public.donneurs_ordre d on d.id = s.donneur_ordre_id
left join public.site_contrats sc on sc.site_id = s.id and sc.lot = 'clim'
where c.actif is true;
