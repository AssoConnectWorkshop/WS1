-- Étape 8 : carte kanban « Todo product » issue de la revue offensive du 17/09.
insert into public.taches (titre, description, colonne, ordre) values
  ('Sécurité : verrouiller les écritures directes en base (RLS)',
   'Revue offensive en boîte blanche (17/09). Faille racine : l''URL Supabase et la clé anonyme étant publiques, tout compte connecté peut appeler l''API REST directement et contourner tous les contrôles de l''application. '
   '1) Écritures directes (critique) : la règle RLS autorise l''écriture dès que l''utilisateur est connu, sans vérifier le rôle ni le champ. Un gestionnaire peut modifier n''importe quelle intervention/site/client/devis en PATCH direct, en contournant le contrôle comptable des statuts de facturation, la liste blanche CASES_EDITABLES et le circuit de clôture. Correctif : router toutes les écritures par les actions serveur avec un client élevé et les contrôles applicatifs, puis retirer aux comptes authenticated le droit d''écriture directe (RLS en lecture seule côté client). '
   '2) Aucune séparation de rôle en base (élevé) : gestionnaire, comptable et administrateur ont le même pouvoir d''écriture ; le modèle de rôles n''existe que dans l''interface. Appliquer les contrôles comptable/administrateur en base. '
   '3) Lecture universelle (moyen) : tout compte connecté lit toutes les tables via REST (clients, sites, utilisateurs, journal_emails, parametres_application). Restreindre au minimum parametres_application et journal_emails aux administrateurs ; à moyen terme, cloisonner. '
   '4) Créer un compte = accès (moyen) : tout compte Supabase Auth s''auto-provisionne en gestionnaire. La seule barrière est le réglage « Allow new signups ». Le désactiver et ajouter une liste blanche côté serveur. '
   '5) Documents non cloisonnés (moyen) : /interventions/[id]/bon.pdf et les certificats vérifient seulement que l''utilisateur est connecté, pas qu''il a le droit de voir cette intervention. Par énumération d''identifiants, un compte aspire tous les PDF. '
   'Corrects : buckets privés, secrets côté serveur, suppression et écriture sur utilisateurs réservées aux administrateurs, jeton vérifié localement, redirections filtrées, secret du cron en temps constant. À traiter avant un partage large / mise en production réelle.',
   'next', 0)
on conflict do nothing;
