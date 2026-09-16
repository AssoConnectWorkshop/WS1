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

## Donner un accès à FMC sans aucun e-mail

Tout se passe dans le tableau de bord Supabase :

1. Vérifier que la personne a une ligne dans Paramétrage › Utilisateurs & Techniciens avec la
   bonne adresse dans « Mail » (sinon l'ajouter dans Table Editor › `utilisateurs`).
2. Supabase › Authentication › Users › **Add user › Create new user** : la même adresse, un mot
   de passe choisi par vous, **Auto Confirm User** coché. Aucun e-mail n'est envoyé.
3. À sa première connexion, l'application rattache le compte à la ligne dont le « Mail » est
   identique (rôle gestionnaire par défaut). La colonne « Accès application » passe à « compte
   actif » ; le rôle se change ensuite depuis cette page.
4. Transmettre le mot de passe par un canal séparé (gestionnaire de mots de passe, message vocal,
   SMS), jamais dans le même message que l'identifiant.

Pour révoquer : supprimer le compte dans Authentication › Users, ou vider `auth_user_id`.

Réglage recommandé : Supabase › Authentication › Sign In / Providers › **désactiver « Allow new
users to sign up »**, pour que seuls les comptes créés par vous existent.
