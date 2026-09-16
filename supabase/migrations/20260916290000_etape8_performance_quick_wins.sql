-- Étape 8 : quick wins a et b réalisés ; la carte performance passe en Todo product (Next) pour suivi.
update public.taches
set tableau = 'projet', colonne = 'next', ordre = 0,
    description = description || E'\n\nFAIT le 16/09 (PR quick wins a + b) : middleware avec vérification locale du jeton (getClaims) au lieu d''un appel réseau à chaque requête ; getCurrentUser() en cache React, un seul appel par requête. Reste à faire : c (parallélisation), d (cache des référentiels), e (région Vercel = région Supabase, à donner), f (mesure). Gain à constater par l''utilisateur.'
where tableau = 'tech' and titre = 'Améliorer les temps de chargement : diagnostic et plan';
