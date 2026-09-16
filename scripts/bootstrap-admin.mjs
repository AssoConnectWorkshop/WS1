#!/usr/bin/env node
/**
 * Amorçage du premier compte administrateur ClimAccess (étape 3).
 *
 * Rattache l'e-mail fourni à une ligne `utilisateurs` (créée si besoin) avec
 * role = 'administrateur', et envoie l'invitation Supabase Auth pour que la personne
 * définisse son mot de passe. Nécessaire uniquement pour le tout premier administrateur :
 * les suivants sont invités depuis /parametrage/utilisateurs une fois connecté.
 *
 * Usage :
 *   NEXT_PUBLIC_SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... \
 *     node scripts/bootstrap-admin.mjs --email=admin@example.com [--nom=Dupont --prenom=Jean]
 */
import { createClient } from '@supabase/supabase-js';

function parseArgs(argv) {
  const args = {};
  for (const arg of argv) {
    const m = /^--([^=]+)=(.*)$/.exec(arg);
    if (m) args[m[1]] = m[2];
  }
  return args;
}

async function main() {
  const { email, nom, prenom } = parseArgs(process.argv.slice(2));
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const siteUrl = process.env.NEXT_PUBLIC_SITE_URL;
  if (!siteUrl) throw new Error('NEXT_PUBLIC_SITE_URL non défini');

  if (!email) {
    console.error('Usage: node scripts/bootstrap-admin.mjs --email=... [--nom=... --prenom=...]');
    process.exit(1);
  }
  if (!url || !serviceRoleKey) {
    console.error('NEXT_PUBLIC_SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY sont requis dans l\'environnement.');
    process.exit(1);
  }

  const admin = createClient(url, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  console.log(`Invitation Supabase Auth de ${email}...`);
  const { data, error } = await admin.auth.admin.inviteUserByEmail(email, {
    redirectTo: `${siteUrl}/auth/callback?next=/reset-password`,
  });
  if (error) {
    console.error('Erreur invitation Supabase Auth :', error.message);
    process.exit(1);
  }
  const authUserId = data.user.id;
  console.log(`  auth.users.id = ${authUserId}`);

  const { data: existing, error: selectError } = await admin
    .from('utilisateurs')
    .select('id')
    .eq('email', email)
    .maybeSingle();
  if (selectError) {
    console.error('Erreur lecture utilisateurs :', selectError.message);
    process.exit(1);
  }

  if (existing) {
    const { error: updateError } = await admin
      .from('utilisateurs')
      .update({ auth_user_id: authUserId, role: 'administrateur' })
      .eq('id', existing.id);
    if (updateError) {
      console.error('Erreur mise à jour utilisateurs :', updateError.message);
      process.exit(1);
    }
    console.log(`  utilisateurs.id = ${existing.id} mis à jour (role=administrateur).`);
  } else {
    const { data: created, error: insertError } = await admin
      .from('utilisateurs')
      .insert({
        nom: nom ?? null,
        prenom: prenom ?? null,
        email,
        auth_user_id: authUserId,
        role: 'administrateur',
        profil: 1,
      })
      .select('id')
      .single();
    if (insertError) {
      console.error('Erreur création utilisateurs :', insertError.message);
      process.exit(1);
    }
    console.log(`  utilisateurs.id = ${created.id} créé (role=administrateur).`);
  }

  console.log("\nTerminé. Un e-mail d'invitation a été envoyé pour définir le mot de passe.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
