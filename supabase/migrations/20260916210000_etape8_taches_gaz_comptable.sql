-- Étape 8 (suite du call de démo FMC du 15/09/2026) :
-- 1. Tableau « À faire » (kanban) pour tracer les points à faire / à discuter du projet.
-- 2. Colonnes gaz / heures dans v_interventions_liste (module « Utilisation FF », heures vendues).
-- 3. Rôle « comptable » : seul rôle, avec l'administrateur, à poser les statuts de facturation
--    réservés (mot de passe « Kadi » d'Access).

create table if not exists public.taches (
  id bigint generated always as identity primary key,
  titre text not null,
  description text,
  colonne text not null default 'backlog' check (colonne in ('backlog','next','in_progress','to_validate','suspended','done')),
  ordre integer not null default 0,
  cree_par_id bigint references public.utilisateurs(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.taches is 'Kanban projet : choses à faire ou à discuter (backlog, next, in_progress, to_validate, suspended, done).';
select public.apply_set_updated_at('taches');
alter table public.taches enable row level security;
drop policy if exists select_authenticated on public.taches;
create policy select_authenticated on public.taches for select to authenticated using (true);
drop policy if exists write_utilisateurs on public.taches;
create policy write_utilisateurs on public.taches for insert to authenticated with check (public.current_utilisateur_id() is not null);
drop policy if exists update_utilisateurs on public.taches;
create policy update_utilisateurs on public.taches for update to authenticated using (public.current_utilisateur_id() is not null) with check (public.current_utilisateur_id() is not null);
drop policy if exists delete_utilisateurs on public.taches;
create policy delete_utilisateurs on public.taches for delete to authenticated using (public.current_utilisateur_id() is not null);

insert into public.taches (titre, description, colonne, ordre) values
  ('Décider comment découper la bascule Access → nouvelle application',
   'Pierre (FMC) préfère garder Access jusqu''à ce que le nouveau soit abouti ; Arnaud veut y aller par étapes. Tant que le bureau saisit dans Access, les deux bases divergent. Proposition : Access reste maître, le transfert (idempotent) est rejoué à cadence fixe depuis le PC de Pierre, la nouvelle application sert de recette, puis bascule module par module. Premier module détachable désigné par Pierre : les véhicules.',
   'next', 1),
  ('Fichiers de devis : téléversement et retrouver les PDF déplacés',
   'Access stocke un chemin réseau qui casse dès qu''un dossier est réorganisé (par année, par société ; ancienne entité 2005-2013). À faire : téléverser le PDF dans le stockage Supabase depuis la fiche devis ; pour l''historique, retrouver le fichier par son numéro de devis dans l''arborescence lors du script de migration des documents.',
   'backlog', 1),
  ('Géocodage à la création d''un site',
   'Géocodage fonctionnel à la création (adresse → coordonnées) avec repli sur la saisie manuelle des coordonnées. La saisie manuelle (collage depuis Google Maps) est déjà possible sur la fiche site.',
   'backlog', 2),
  ('Connexion avec le compte Microsoft (SSO)',
   'FMC a des licences Microsoft 365. Activer le fournisseur Azure AD de Supabase Auth quand l''accès sera ouvert aux 15 à 20 gestionnaires.',
   'backlog', 3),
  ('Validation souple des saisies : revoir les champs obligatoires',
   'Pierre insiste : ne rien rendre bloquant. Vérifier les formats (e-mail), mais relire tous les formulaires et retirer les « obligatoire » qui ne le sont pas dans Access.',
   'backlog', 4),
  ('Client, enseigne, donneur d''ordre : clarifier le modèle',
   'Cas SFR / Technivolution : le « client » d''Access est l''enseigne, celui qu''on facture est le donneur d''ordre. Pierre reconnaît que c''est à revoir. Étape 1 : libellés « Client (enseigne) » et « Donneur d''ordre (facturé) ». Étape 2 : changement de modèle après validation FMC.',
   'backlog', 5),
  ('Deux profils d''accès web : gestionnaire et technicien / sous-traitant',
   'Sur le portail actuel, un gestionnaire voit tout, un technicien ou un sous-traitant ne voit que les interventions de son intervenant. Hors périmètre bureau pour l''instant, mais fixe le modèle de rôles à prévoir.',
   'backlog', 6),
  ('Coordination avec Kairo (IA sur les duplicata et la recherche)',
   'Kairo travaille sur la file « devis à faire » (photos et informations du technicien) et sur un assistant de recherche sur l''historique d''un site. Ne pas développer deux fois la même chose.',
   'backlog', 7),
  ('Interopérabilité Esabora (création de client en triple)',
   'Le client est créé trois fois : Esabora, Access, papier. Phase 2 du cahier des charges (API Esabora : devis, commandes, facturation).',
   'backlog', 8),
  ('Vérifier que le numéro de bon est attribué automatiquement à la création',
   'Dans Access, un déclencheur SQL Server pose numint = numintint (numéro de bon = numéro d''intervention). Vérifier que l''application fait de même pour les interventions créées ici.',
   'backlog', 9)
on conflict do nothing;

-- Rôle comptable (statuts de facturation réservés).
alter table public.utilisateurs drop constraint if exists utilisateurs_role_check;
alter table public.utilisateurs add constraint utilisateurs_role_check check (role in ('gestionnaire','administrateur','comptable'));

-- Colonnes gaz et heures vendues (module « Utilisation FF », onglet Clôture).
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
  nullif(trim(concat_ws(' ', dt.prenom, dt.nom)), '') as duplicata_traite_par_nom,
  i.quantite_gaz_kg,
  tf.libelle as fluide_libelle,
  i.chemin_dossier_etancheite,
  i.heures_vendues
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
left join public.types_fluide tf on tf.code = i.fluide_id
left join public.statuts_facturation sf on sf.code = i.statut_facturation_code
left join public.devis d2 on d2.intervention_origine_id = i.id
where c.actif is true;

create index if not exists heures_techniciens_intervention_numero_bon_idx on public.heures_techniciens (intervention_numero_bon);
