-- Étape 8 : compteurs du menu d'accueil en un seul balayage de `interventions`
-- (14 sous-requêtes count(*) auparavant : dépassement du délai d'exécution, pastilles à 0).
create or replace view public.v_tableau_de_bord as
select
  count(*) filter (where statut_code = 9)                                   as a_valider,
  count(*) filter (where statut_facturation_code = 1)                       as a_facturer,
  count(*) filter (where statut_facturation_code = 8)                       as a_definir_direction,
  count(*) filter (where statut_facturation_code = 9)                       as stand_by,
  count(*) filter (where statut_code = -1)                                  as materiel_a_commander,
  count(*) filter (where statut_code = 2)                                   as attente_materiel,
  count(*) filter (where statut_code = 7 and devis_a_faire)                 as duplicata_total,
  count(*) filter (where statut_code = 7 and devis_a_faire and duplicata_traite is false) as duplicata_a_traiter,
  count(*) filter (where statut_code = 7 and devis_a_faire and duplicata_traite is true)  as duplicata_traitees,
  count(*) filter (where statut_facturation_code in (1,2) and type_code = 2) as depannage,
  count(*) filter (where statut_facturation_code in (1,2) and type_code = 1) as maintenances,
  count(*) filter (where statut_facturation_code in (1,2) and type_code = 3) as devis_sav_acceptes,
  count(*) filter (where statut_facturation_code in (1,2) and type_code = 5) as en_travaux,
  count(*) filter (where statut_facturation_code in (1,2) and type_code not in (1,2,3,5)) as autres
from public.interventions;
comment on view public.v_tableau_de_bord is 'Compteurs de l''écran d''accueil (legacy/analysis/01_navigation_parametrage.md §2.1), calculés en un passage.';
