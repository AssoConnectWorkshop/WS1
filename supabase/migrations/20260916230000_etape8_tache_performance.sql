-- Étape 8 : retour utilisateur du 16/09 : l'application est lente.
insert into public.taches (titre, description, colonne, ordre) values
  ('Performance : l''application est lente, chantier à ouvrir',
   'Constat (Arnaud, 16/09) : navigation et listes lentes en production. Pistes : 1) toutes les pages sont rendues à la demande (force-dynamic) avec plusieurs requêtes Supabase en série par page (fiche site : une dizaine, fiche intervention : une quinzaine) → paralléliser, regrouper en une RPC ou une vue par écran ; 2) vues v_interventions_liste / v_sites_liste à 8-12 jointures, comptages exacts → vues matérialisées ou colonnes dénormalisées, index composites sur les filtres courants (statut + date_limite, site_id + statut) ; 3) listes déroulantes chargées à chaque affichage (2 300 clients, 193 intervenants) → mise en cache (unstable_cache / revalidate) des référentiels ; 4) région Vercel et région Supabase à aligner (latence réseau) ; 5) mesurer avant d''optimiser : Vercel Speed Insights + journal des temps de requête PostgREST.',
   'next', 0)
on conflict do nothing;
