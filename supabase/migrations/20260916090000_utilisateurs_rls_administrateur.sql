-- Étape 3 (connexion et rôles) : la politique générique posée à l'étape 1 laisse tout
-- utilisateur authentifié reconnu écrire sur `utilisateurs` (donc modifier son propre
-- `role` ou `auth_user_id` via l'API publique). Comme cette table porte désormais les
-- droits d'accès de l'application, on restreint son écriture au rôle administrateur.

drop policy if exists write_utilisateurs on public.utilisateurs;
drop policy if exists update_utilisateurs on public.utilisateurs;
drop policy if exists write_administrateur on public.utilisateurs;
drop policy if exists update_administrateur on public.utilisateurs;

create policy write_administrateur on public.utilisateurs
  for insert to authenticated
  with check (public.current_role() = 'administrateur');

create policy update_administrateur on public.utilisateurs
  for update to authenticated
  using (public.current_role() = 'administrateur')
  with check (public.current_role() = 'administrateur');
