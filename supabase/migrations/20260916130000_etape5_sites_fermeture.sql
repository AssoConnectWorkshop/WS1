-- Étape 5.3 : à la fermeture d'un site, l'ancien client est conservé (Access le perdait en
-- rattachant le site au pseudo-client « fermé », cf. analysis 03 §2.4).
alter table public.sites add column if not exists client_avant_fermeture_id bigint references public.clients(id) on delete set null;
