-- Étape 8 : comptes d'accès à l'application découplés du personnel FMC.
-- Une ligne `utilisateurs` créée par l'application (master admin ou accès créé depuis
-- Paramétrage › Accès application) porte compte_application = true : elle n'apparaît pas dans
-- « Utilisateurs & Techniciens » (données FMC) mais porte le rôle et le rattachement Auth.
alter table public.utilisateurs add column if not exists compte_application boolean not null default false;
comment on column public.utilisateurs.compte_application is 'true : ligne créée par l''application pour porter un accès (master admin, accès créé sans e-mail), pas une fiche du personnel FMC.';
create index if not exists utilisateurs_email_lower_idx on public.utilisateurs (lower(email));
