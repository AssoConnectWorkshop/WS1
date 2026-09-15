# Étape 3 — Connexion et rôles

## Objectif

Fermer l'application aux anonymes, connecter les gestionnaires FMC par e-mail et mot de passe, deux rôles.

## Livrables

1. `src/app/(auth)/login/page.tsx` : formulaire e-mail + mot de passe, lien « mot de passe oublié » (Supabase `resetPasswordForEmail`), messages d'erreur en français.
2. `src/app/(auth)/reset-password/page.tsx` : saisie du nouveau mot de passe après lien reçu.
3. `src/middleware.ts` : toute route hors `/login`, `/reset-password`, `/auth/*` exige une session Supabase (`@supabase/ssr`, refresh de session).
4. `src/lib/auth.ts` : `getCurrentUser()` côté serveur → `{ authUser, utilisateur, role }` en joignant `utilisateurs.auth_user_id`. Un utilisateur authentifié mais absent de `utilisateurs` voit une page « compte non rattaché, contactez l'administrateur ».
5. Layout applicatif `src/app/(app)/layout.tsx` : en-tête avec nom de l'utilisateur, rôle, bouton déconnexion, navigation (liens vides vers les futures pages de l'étape 4 : Tableau de bord, Interventions, Sites, Clients, Intervenants, Devis, Planification, Paramétrage).
6. Page `/parametrage/utilisateurs` (administrateur seulement) : liste des `utilisateurs` profil gestionnaire, bouton « Inviter » qui appelle `supabase.auth.admin.inviteUserByEmail` via Server Action avec la clé service (variable serveur `SUPABASE_SERVICE_ROLE_KEY`, à ajouter sur Vercel par l'utilisateur), puis renseigne `auth_user_id` et `role`. Bouton « Changer de rôle ».
7. Migration SQL : trigger sur `auth.users` inutile ; le rattachement se fait par l'invitation. Politique RLS `administrateur` = `utilisateurs.role = 'administrateur'`.
8. Amorçage : Server Action ou script one-shot qui rattache l'e-mail de l'utilisateur courant (fourni par l'utilisateur) au premier compte administrateur.

## Règles

- Pas d'inscription libre. Pas de connexion sociale.
- Aucun mot de passe repris de l'ancienne base.
- Les techniciens (`profil = 2`) ne sont pas invités à cette étape.
- Variables Vercel nécessaires : `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY` (existantes), `SUPABASE_SERVICE_ROLE_KEY` (à ajouter par l'utilisateur, jamais `NEXT_PUBLIC_`).
- Configurer dans Supabase Auth l'URL de redirection `https://assoconnect-ws1.vercel.app/auth/callback` (à faire par l'utilisateur, l'indiquer clairement).

## Critères d'acceptation

- Un anonyme sur `/` est redirigé vers `/login`.
- L'utilisateur se connecte et voit son nom et « administrateur ».
- Il invite un collègue depuis `/parametrage/utilisateurs` ; le collègue reçoit un mail, définit son mot de passe, se connecte en « gestionnaire », ne voit pas la page utilisateurs.
- `npm run build` vert, push sur `main`.

## État

- [ ] Non commencée
