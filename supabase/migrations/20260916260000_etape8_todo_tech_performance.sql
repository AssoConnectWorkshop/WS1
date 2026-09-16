-- Étape 8 : carte Todo tech « Améliorer les temps de chargement » (diagnostic technique du 16/09).
insert into public.taches (tableau, titre, description, colonne, ordre) values
  ('tech', 'Améliorer les temps de chargement : diagnostic et plan',
'DIAGNOSTIC (lecture du code, 16/09). Chaque page est rendue côté serveur à la demande et enchaîne des appels Supabase EN SÉRIE, chacun = un aller-retour réseau Vercel → Supabase (50 à 150 ms selon les régions) :
- middleware : auth.getUser() = 1 appel réseau au service Auth sur CHAQUE requête (pages, mais aussi navigations et images) ;
- layout : getCurrentUser() refait auth.getUser() + 1 requête utilisateurs, à chaque page ;
- fiche intervention : ~16 awaits séquentiels ; fiche site : ~8 ; liste des sites : jusqu''à 9 (filtres en deux passes) ; menu : 4 ;
- les listes déroulantes (2 300 clients, 193 intervenants, zones, statuts…) sont rechargées à chaque affichage ;
- comptages exacts sur des vues à 8-12 jointures (v_interventions_liste, v_sites_liste) ;
- aucun cache applicatif (pas de unstable_cache / revalidate, pas de React cache()).
Ordre de grandeur : une fiche intervention = 18 à 20 allers-retours en série ≈ 1,5 à 3 s avant le premier octet. Le réseau, pas le SQL, est le premier coupable.

1. QUICK WINS (une demi-journée, gain attendu ×2 à ×3) :
 a. Middleware : remplacer auth.getUser() (réseau) par la vérification locale du JWT (supabase.auth.getClaims() de @supabase/ssr récent) ; ne rafraîchir la session que si le jeton expire bientôt. Exclure /_next, images et fichiers statiques du matcher.
 b. getCurrentUser() enveloppé dans React cache() : un seul appel par requête, partagé layout + page + actions.
 c. Paralléliser les awaits indépendants avec Promise.all (fiche intervention, fiche site, listes : référentiels + requête principale + comptage en même temps).
 d. Référentiels et listes déroulantes (statuts, types, zones, clients actifs, intervenants, gestionnaires) : unstable_cache avec revalidate 300 s et tag invalidé par les actions de paramétrage.
 e. Aligner la région des fonctions Vercel sur celle du projet Supabase (vercel.json "regions" : fra1 ou cdg1 si Supabase est en eu-central/eu-west). À vérifier en premier : si les deux sont sur des continents différents, c''est le gain le plus important et le moins cher.
 f. Activer Vercel Speed Insights + journaliser la durée de chaque requête Supabase en dev pour mesurer avant/après.
 Oui, « un peu de cache » (b + d) et la parallélisation (c) suffiront probablement pour les fiches ; le middleware (a) et la région (e) pèsent sur toutes les pages.

2. SI INSUFFISANT (améliorations plus conséquentes) :
 a. Une fonction RPC (ou une vue) par écran qui renvoie toute la fiche en un seul appel (intervention + site + client + intervenant + techniciens + devis + heures) au lieu de 16.
 b. Vues matérialisées rafraîchies par déclencheur ou toutes les N minutes pour v_interventions_liste / v_sites_liste, ou colonnes dénormalisées (libellés) sur interventions / sites ; index composites sur les filtres courants (statut_code + date_limite, site_id + statut_code, client_id).
 c. Supprimer le comptage total des listes (Access affiche « Enr : 1 sur N » mais on peut afficher « page N » et « suivant » seulement) ou le calculer via une table de compteurs.
 d. Streaming : rendre l''en-tête tout de suite et les onglets/listes lourds dans des Suspense, pour un affichage perçu immédiat.
 e. Passer les pages peu changeantes (menu, paramétrage) en cache de route court (revalidate 30-60 s) plutôt que force-dynamic partout.
 f. En dernier recours : PostgREST direct depuis le navigateur pour les listes (moins de sauts) ou pooler Supavisor en mode transaction si le nombre de connexions devient le goulot.',
   'todo', 0)
on conflict do nothing;
