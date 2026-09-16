-- Étape 8 : la carte « suppressions par erreur » relève du produit : déplacée de Todo tech vers Todo product (Next).
update public.taches
set tableau = 'projet', colonne = 'next', ordre = 3
where tableau = 'tech' and titre = 'Éviter les suppressions par erreur et permettre la restauration';
