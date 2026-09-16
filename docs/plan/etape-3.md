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
- Configurer dans Supabase Auth l'URL de redirection `https://fmc-climatisation.vercel.app/auth/callback` (à faire par l'utilisateur, l'indiquer clairement).

## Critères d'acceptation

- Un anonyme sur `/` est redirigé vers `/login`.
- L'utilisateur se connecte et voit son nom et « administrateur ».
- Il invite un collègue depuis `/parametrage/utilisateurs` ; le collègue reçoit un mail, définit son mot de passe, se connecte en « gestionnaire », ne voit pas la page utilisateurs.
- `npm run build` vert, push sur `main`.

## État

- [x] `src/middleware.ts` : toute route hors `/login`, `/reset-password`, `/auth/*` exige une
  session (rafraîchie via `@supabase/ssr`) ; anonyme → redirigé vers `/login?next=...`.
- [x] `src/app/(auth)/login/page.tsx`, `src/app/(auth)/reset-password/page.tsx` (gère les deux
  phases : demande de lien puis saisie du nouveau mot de passe), `src/app/auth/callback/route.ts`.
- [x] `src/lib/auth.ts` (`getCurrentUser`), `src/lib/supabase/client.ts` (client navigateur,
  absent jusqu'ici malgré la mention dans `CLAUDE.md`), `src/lib/supabase/admin.ts` (client
  service role, jamais exposé au navigateur).
- [x] `src/app/(app)/layout.tsx` : en-tête, nom + rôle, déconnexion, navigation (liens vides
  vers les futures pages étape 4), page « compte non rattaché » si l'auth Supabase existe
  sans ligne `utilisateurs` correspondante. Pages existantes (`/`, `/organization`) déplacées
  sous `(app)` pour hériter du layout.
- [x] `src/app/(app)/parametrage/utilisateurs/page.tsx` + `actions.ts` (administrateur
  seulement) : liste des gestionnaires, invitation (`auth.admin.inviteUserByEmail` via le
  client service role), changement de rôle. Lien « Paramétrage » masqué dans la nav pour un
  non-administrateur.
- [x] `scripts/bootstrap-admin.mjs` : amorçage du tout premier administrateur (un script, pas
  une Server Action, pour éviter le problème de l'œuf et la poule décrit dans le brief).
- [x] Migration `20260916090000_utilisateurs_rls_administrateur.sql` : durcissement au-delà du
  brief — la politique générique de l'étape 1 laissait n'importe quel utilisateur reconnu
  écrire sur `utilisateurs` (donc s'auto-élever administrateur via l'API publique).
  Écriture désormais réservée au rôle administrateur. Validée idempotente sur Postgres local.
- [x] Testé avec un vrai navigateur (Playwright, Supabase non disponible dans cette session) :
  anonyme sur `/`, `/organization`, `/parametrage/utilisateurs` → redirigé vers `/login` ;
  échec de connexion → message français affiché sans crasher (a révélé et corrigé un import
  incomplet dans les Server Actions : les appels Supabase sont maintenant protégés par
  `try/catch` pour ne jamais faire planter la page si le service est indisponible) ; demande
  de réinitialisation → message de confirmation neutre (pas d'énumération de comptes).
- [x] `npx next build` et `npx next lint` verts.
- [ ] **Non fait par cette session** (accès Supabase Auth réel requis) :
  - Lancer `scripts/bootstrap-admin.mjs` pour créer le premier administrateur.
  - Configurer dans Supabase Auth l'URL de redirection
    `https://fmc-climatisation.vercel.app/auth/callback`.
  - Ajouter `SUPABASE_SERVICE_ROLE_KEY` et `NEXT_PUBLIC_SITE_URL` sur Vercel.
  - Vérifier le critère d'acceptation complet (connexion, invitation d'un collègue,
    réception du mail, définition du mot de passe, connexion en gestionnaire).

### À faire par l'utilisateur

1. Sur Vercel (projet `ws-1`) : ajouter `SUPABASE_SERVICE_ROLE_KEY` (clé service role
   Supabase, *jamais* `NEXT_PUBLIC_`) et `NEXT_PUBLIC_SITE_URL=https://fmc-climatisation.vercel.app`.
2. Sur Supabase (Authentication → URL Configuration) : ajouter
   `https://fmc-climatisation.vercel.app/auth/callback` aux Redirect URLs.
3. Lancer une fois, avec `SUPABASE_SERVICE_ROLE_KEY` en variable d'environnement locale :
   `node scripts/bootstrap-admin.mjs --email=<ton-email> --nom=... --prenom=...`
4. Vérifier l'e-mail reçu, définir le mot de passe, se connecter sur le site : le nom et
   « administrateur » doivent apparaître dans l'en-tête, et `/parametrage/utilisateurs` doit
   lister les gestionnaires transférés à l'étape 2 (si le transfert a été fait).
5. Depuis cette page, inviter un collègue et vérifier qu'il se connecte en « gestionnaire »
   sans voir le lien « Paramétrage ».
