# E-mails sortants : garde-fous

La base contient les vraies adresses du personnel FMC et des contacts clients. Aucun e-mail ne doit
partir par erreur pendant la phase de démonstration.

## Ce qui peut envoyer un e-mail

| Déclencheur | Canal | Destinataire |
|---|---|---|
| Connexion › « Mot de passe oublié » | Supabase Auth | l'adresse saisie (si compte existant) |
| Fiche intervention › e-mail partenaire / contact / fin d'intervention | Resend | l'adresse saisie |
| `/api/cron/relances` (appel avec `CRON_SECRET`, aucun cron Vercel configuré) | Resend | `parametres_application.email_sav` |

## Triple ceinture

1. **Liste blanche `EMAILS_AUTORISES`** (variable Vercel) : adresses complètes ou domaines
   (`@team.blue`), séparés par des virgules. Absente ou vide → tous les canaux ci-dessus sont
   bloqués (`journal_emails.statut = 'bloque'` pour Resend, message d'erreur pour l'invitation,
   message neutre pour la réinitialisation).
2. **Pas d'invitation depuis l'application** : le bouton « Inviter » a été retiré. Les comptes se
   créent uniquement dans le tableau de bord Supabase (ci-dessous).
3. **Resend désactivé** : sans `RESEND_API_KEY` sur Vercel, les e-mails Resend sont simulés et
   seulement journalisés.

## Accès à l'application (Paramétrage › Accès application)

Les accès sont découplés des fiches « Utilisateurs & Techniciens » (données FMC). L'identifiant
de connexion est l'e-mail ; l'application n'envoie jamais d'e-mail automatique.

- **Master admins** : variable Vercel `MASTER_ADMINS` (adresses séparées par des virgules).
  Toujours administrateur, non révocables depuis l'application. Créer leur compte Auth une
  première fois (page Accès application depuis un autre master admin, ou Supabase ›
  Authentication › Users › Create new user avec Auto Confirm) ; à la connexion, une ligne
  `utilisateurs` marquée `compte_application` est créée automatiquement si aucune ne porte leur
  adresse.
- **Créer un accès** : e-mail, nom facultatif, rôle. Le compte Auth est créé confirmé, le mot de
  passe initial s'affiche une seule fois à l'écran. L'administrateur l'envoie lui-même à la
  personne (idéalement séparément de l'identifiant) et lui demande de le remplacer via le bouton
  « Mot de passe » en haut à droite (`/mot-de-passe`, mot de passe actuel exigé). Si une fiche
  FMC porte déjà l'adresse, l'accès lui est rattaché ; sinon un compte indépendant est créé.
- **Rôles et révocation** : sur la même page. Révoquer supprime le compte Auth (adresse à retaper
  pour confirmer) ; la fiche FMC, s'il y en a une, est conservée.
- **Tout compte Supabase Auth a accès** : à la première connexion, rattachement à la fiche FMC
  non rattachée portant le même e-mail s'il y en a une, sinon création d'une ligne
  `compte_application` (rôle gestionnaire, administrateur pour un master admin). C'est pourquoi
  l'inscription libre doit rester désactivée dans Supabase : la création d'un compte Auth vaut
  autorisation d'accès.

Réglage recommandé : Supabase › Authentication › Sign In / Providers › **désactiver « Allow new
users to sign up »**, pour que seuls les comptes créés par vous existent.

## Revue sécurité du volet connexion (16/09)

Vérifié : mots de passe et sessions gérés par Supabase Auth (cookies httpOnly, limitation des
tentatives côté Supabase) ; clé service role et clés API uniquement côté serveur ; messages
d'erreur issus d'un dictionnaire fixe (aucun texte de l'URL n'est réaffiché) ; rôles validés
côté serveur dans chaque action ; RLS active sur toutes les tables.

Corrigé lors de la revue :
- Redirection ouverte : le paramètre `next` de la connexion et du callback acceptait `//hote` ou
  `@hote` ; désormais filtré par `cheminInterne()` (chemin interne uniquement).
- Écran « Compte non rattaché » : le détail technique n'est affiché qu'aux master admins, sinon
  journalisé côté serveur.
- Mot de passe oublié : plus de détail technique à l'écran, message générique « contactez un
  administrateur ».
- Comparaison du secret du cron en temps constant ; route `/api/cron` hors redirection de
  connexion (elle a son propre secret).
- Génération du mot de passe initial sans biais statistique.

Points à connaître, non modifiés :
- Tout compte Supabase Auth a accès (rôle gestionnaire) : l'inscription libre doit rester
  désactivée dans Supabase › Authentication › Sign In / Providers.
- Tout utilisateur connecté peut lire la liste des utilisateurs (e-mails, rôles) : usage interne.
- La page « Nouveau mot de passe » atteinte par le lien e-mail ne demande pas l'ancien mot de
  passe (c'est le principe de la réinitialisation) ; « Mot de passe » dans l'en-tête l'exige.
- Pas de double authentification ; à prévoir dans la cible si FMC le souhaite.
