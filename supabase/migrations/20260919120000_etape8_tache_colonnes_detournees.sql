-- Étape 8 : carte kanban « Todo product » issue du fil e-mail FMC/Kayro du 18/09.
insert into public.taches (titre, description, colonne, ordre) values
  ('Colonnes détournées : récupérer la correspondance d''Olivier',
   'Sujet issu du fil e-mail FMC/Kayro du 18/09. Olivier Mengue (dev/DBA historique de logiclim) a recyclé au fil des ans des colonnes libres de tables existantes pour y loger de nouvelles données, et tient un fichier Excel de correspondance « nom d''origine ↔ donnée réellement stockée » (avec aussi des colonnes notées comme non utilisées). Il doit l''envoyer. '
   'Impact migration : c''est la vérité sur les colonnes détournées, à récupérer et croiser avec docs/plan/dictionnaire.md et les détournements déjà connus (NbreRadiateurs = quantité de fluide, nbrappint = statut de facturation, numdevpartenaire = nom du technicien…). '
   'À faire : 1) récupérer et archiver l''Excel d''Olivier ; 2) compléter et valider le dictionnaire des colonnes ; 3) vérifier qu''aucune colonne détournée n''est traitée à tort comme vide ou ignorée dans le transfert de données. '
   'À rapprocher des nouvelles tables Kayro_* (Zone, InterventionMateriel, DevisLigne, Photo, MaterielLie) ajoutées à logiclim par l''application terrain, qui comblent des manques que la cible devra aussi porter.',
   'backlog', 0)
on conflict do nothing;
