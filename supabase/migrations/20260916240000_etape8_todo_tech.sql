-- Étape 8 : second kanban « Todo tech » (Todo / Doing / Done) : tâches côté développement, dépilées une à une.
alter table public.taches add column if not exists tableau text not null default 'projet' check (tableau in ('projet','tech'));
alter table public.taches drop constraint if exists taches_colonne_check;
alter table public.taches add constraint taches_colonne_check check (colonne in ('backlog','next','in_progress','to_validate','suspended','done','todo','doing'));
create index if not exists taches_tableau_idx on public.taches (tableau, colonne, ordre);

insert into public.taches (tableau, titre, description, colonne, ordre) values
  ('tech', 'Tableaux : bouton pour ouvrir l''objet de la ligne',
   'Dans les listes (ex. /sites), on ne comprend pas comment ouvrir un site : le lien est seulement sur le nom. Ajouter sur chaque ligne un bouton explicite « Ouvrir » (première colonne, comme le « Ct » d''Access ou le double-clic) qui ouvre l''objet correspondant : site, intervention, client, devis, véhicule, intervenant.',
   'todo', 1),
  ('tech', 'Ouvrir les objets liés affichés dans les tableaux',
   'Question à trancher puis appliquer partout : toute valeur d''un tableau qui désigne un objet (client, site, donneur d''ordre, intervenant, technicien, devis…) devrait être un lien vers sa fiche. Aujourd''hui seuls client et site le sont, et pas dans toutes les listes.',
   'todo', 2),
  ('tech', 'Bug /sites : « RDV à prendre » non cliquable',
   'La case « RDV à Prendre » de la liste des sites est en lecture seule (readOnly). Dans Access la case se coche directement dans la feuille de données. À faire : la rendre cliquable et enregistrer immédiatement (action serveur), même chose pour les autres cases de listes qui étaient éditables dans Access (Non Fact., Devis à faire…) à confirmer.',
   'todo', 3)
on conflict do nothing;
