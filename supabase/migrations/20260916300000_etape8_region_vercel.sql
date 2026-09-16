-- Étape 8 : quick win e réalisé (région Vercel alignée sur Supabase).
update public.taches
set description = description || E'\n\nFAIT le 16/09 (e) : projet Supabase en eu-central-2 (Zurich) ; fonctions Vercel fixées en fra1 (Francfort) via vercel.json. Si le tableau de bord Vercel affiche encore une autre région après déploiement, la changer aussi dans Settings › Functions › Function Region.'
where titre = 'Améliorer les temps de chargement : diagnostic et plan';
