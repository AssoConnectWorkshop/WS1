-- Étape 8 : point à discuter issu du test de la liste des interventions en production.
insert into public.taches (titre, description, colonne, ordre) values
  ('Liste des interventions : comptage estimé, à vérifier',
   'Constat : /interventions affichait « Aucune intervention » en production (filtre À planifier, ~2 600 lignes attendues). Hypothèse : dépassement du délai de requête PostgREST sur le comptage exact via la vue v_interventions_liste (12 jointures, 71 000 lignes). Fait le 16/09 : comptage passé de « exact » à « estimated » (estimation du planificateur au-delà de 1 000 lignes) et message d''erreur PostgREST affiché sous les listes. Résultat : la liste s''affiche à nouveau, ce qui confirme le diagnostic. Probablement insuffisant à terme (le total affiché est une estimation, et les autres listes gardent un comptage exact) : mesurer la requête (EXPLAIN), envisager une vue matérialisée ou une table de comptage, ou supprimer le comptage total (Access affiche « Enr : 1 sur N »).',
   'next', 2)
on conflict do nothing;
