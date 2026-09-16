# E-mails sortants : garde-fous

La base contient les vraies adresses du personnel FMC et des contacts clients. Aucun e-mail ne doit
partir par erreur pendant la phase de démonstration.

## Ce qui peut envoyer un e-mail

| Déclencheur | Canal | Destinataire |
|---|---|---|
| Paramétrage › Utilisateurs › « Inviter » (administrateur) | Supabase Auth | l'adresse de la ligne |
| Connexion › « Mot de passe oublié » | Supabase Auth | l'adresse saisie (si compte existant) |
| Fiche intervention › e-mail partenaire / contact / fin d'intervention | Resend | l'adresse saisie |
| `/api/cron/relances` (appel avec `CRON_SECRET`, aucun cron Vercel configuré) | Resend | `parametres_application.email_sav` |

## Triple ceinture

1. **Liste blanche `EMAILS_AUTORISES`** (variable Vercel) : adresses complètes ou domaines
   (`@team.blue`), séparés par des virgules. Absente ou vide → tous les canaux ci-dessus sont
   bloqués (`journal_emails.statut = 'bloque'` pour Resend, message d'erreur pour l'invitation,
   message neutre pour la réinitialisation).
2. **Confirmation à la saisie** : l'administrateur doit retaper l'adresse exacte de la ligne pour
   inviter. Pas d'invitation en masse : un clic = une ligne.
3. **Resend désactivé** : sans `RESEND_API_KEY` sur Vercel, les e-mails Resend sont simulés et
   seulement journalisés.

## Donner un accès à FMC sans aucun e-mail

Chemin recommandé pendant la démo, entièrement sous votre contrôle dans Supabase :

1. Supabase › Authentication › Users › **Add user › Create new user** : e-mail de la personne,
   mot de passe choisi par vous, **Auto Confirm User** coché. Aucun e-mail n'est envoyé.
2. Copier l'UUID du compte créé.
3. Supabase › Table Editor › `utilisateurs` : sur la ligne de la personne (ou une ligne créée pour
   l'occasion), renseigner `auth_user_id` = UUID et `role` = `gestionnaire`.
4. Transmettre le mot de passe par un canal séparé (gestionnaire de mots de passe, message vocal,
   SMS), jamais dans le même message que l'identifiant.

Pour révoquer : supprimer le compte dans Authentication › Users, ou vider `auth_user_id`.
