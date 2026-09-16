-- Étape 8 : cartes du 16/09 sur la suppression et l'archivage.
insert into public.taches (tableau, titre, description, colonne, ordre) values
  ('tech', 'Éviter les suppressions par erreur et permettre la restauration',
'Constat : plusieurs listes et fiches proposent « Supprimer » d''un clic (matériel, contacts, événements véhicule, devis, cartes kanban, référentiels) ; Access supprimait aussi sans confirmation et FMC s''en plaint (analysis 02 : « suppression physique possible depuis les listes, sans confirmation »).
À faire :
1. Confirmation systématique avant toute suppression (boîte de dialogue ou page de confirmation comme pour la fermeture d''un site).
2. Suppression logique partout : les tables interventions, sites, clients et devis ont déjà une colonne supprime_le ; l''étendre aux autres tables (site_materiels, contacts, vehicules, vehicule_evenements, taches, référentiels) et remplacer les DELETE par un marquage, avec l''utilisateur et la date (supprime_le, supprime_par_id).
3. Corbeille : page /corbeille listant les éléments supprimés (type, libellé, date, par qui) avec un bouton « Restaurer » ; purge physique différée (ex. 90 jours) ou jamais.
4. Journal : la suppression et la restauration sont déjà tracées via enregistrerJournal pour certaines tables ; généraliser.
5. Filtrer supprime_le is null dans toutes les vues et requêtes (v_interventions_liste, v_sites_liste…) et vérifier que rien ne réapparaît.',
   'todo', 1),
  ('projet', 'Statut « archivé » en plus de « supprimé »',
'Distinguer trois états pour les objets métier (clients, sites, interventions, devis, matériels, véhicules) : actif, archivé, supprimé.
- Archivé : l''objet n''apparaît plus dans les listes par défaut mais reste consultable, filtrable (« afficher les archivés ») et lié à son historique ; c''est le cas d''usage des sites fermés, des véhicules vendus, des clients « non affichés » (affcli) qu''Access gère aujourd''hui par des cases et des pseudo-clients.
- Supprimé : dans la corbeille, restaurable (voir la carte Todo tech).
À décider avec FMC : quels objets archiver, qui peut archiver / désarchiver, et si l''archivage remplace le pseudo-client « sites fermés » et le flag affcli.',
   'backlog', 0)
on conflict do nothing;
