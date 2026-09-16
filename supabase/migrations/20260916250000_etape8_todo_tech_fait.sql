-- Étape 8 : trois premières cartes « Todo tech » réalisées le 16/09.
update public.taches set colonne = 'done'
where tableau = 'tech' and titre in (
  'Tableaux : bouton pour ouvrir l''objet de la ligne',
  'Ouvrir les objets liés affichés dans les tableaux',
  'Bug /sites : « RDV à prendre » non cliquable'
);
