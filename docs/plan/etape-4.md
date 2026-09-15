# Étape 4 — Écrans de consultation (lecture seule)

## Objectif

Tout ce qu'un gestionnaire regarde dans Access se retrouve dans le navigateur. Aucune saisie.
Lire avant de coder : `legacy/analysis/02_interventions.md` §8 (filtres exacts), `03_clients_sites_materiel_intervenants.md` §6, `01_navigation_parametrage.md` §2.1 (compteurs).

## Conventions d'écran

- Server Components, données via `src/lib/supabase/server.ts`. Filtres dans l'URL (`searchParams`), pagination 50 lignes, tri par colonne.
- Composants partagés dans `src/components/ui/` : `DataTable` (colonnes, tri, pagination), `FilterBar` (champs déclaratifs), `Badge` (statut coloré), `Tabs`, `KeyValue` (fiche), `EmptyState`.
- Couleurs des types d'intervention comme dans Access : 1 bleu, 2 vert, 3 rose, 5 orange, 6-7-8 violet, 4-9 rose (voir analysis 02 §1.1).
- Libellés : ceux des référentiels, jamais les codes seuls. Dates au format `jj/mm/aaaa`.
- Navigation : chaque identifiant cliquable ouvre la fiche liée (site → client, intervention → site…).
- Vocabulaire Access conservé dans les titres de champs (« N° de DI client », « Date limite », « Bon », « Chargé d'affaire »).

## Pages, dans l'ordre de livraison

### 4.1 `/` Tableau de bord
Cartes de compteurs depuis `v_tableau_de_bord`, chacune cliquable vers `/interventions` pré-filtré :
à valider (statut 9) · à facturer (facturation 1) · à définir par la direction (facturation 8) · stand-by (facturation 9) ·
matériel à commander (statut -1) · attente matériel (statut 2) · duplicata total / à traiter / attente offre de prix
(statut 7 et devis_a_faire, ventilé par duplicata_traite) · par type en facturation 1 ou 2 (pastilles Dépannage, Maintenances, Devis SAV acceptés, En travaux, Autres).
Plus les 8 grandes tuiles de navigation (Clients, Sites, Intervenants, Interventions, Devis, Statistiques, Véhicules, Paramétrage).

### 4.2 `/interventions` liste
Source `v_interventions_liste`. Filtres : client, site (numéro ou nom), type, statut (par défaut : exclure statut 7 sauf case « afficher les clôturées »),
intervenant, donneur d'ordre, statut facturation, zones (multi), période sur date limite ou sur date réalisée, cases : devis à faire, audit fait,
contrôle étanchéité, photo faite, registre mis à jour, sous-type vide, particulier, « entretien proche » (règle analysis 02 §8.1 avec `ecarts_visites`).
Colonnes : type (badge), statut, client, site, ville, date limite, date prévue, date réalisée, intervenant, techniciens, chargé d'affaire, statut facturation, N° DI client, N° bon, devis (à faire / fait), commentaire (tronqué, tooltip).
Pied : total et, si statut 10, somme des minutes téléphone. Bouton « Exporter Excel » (étape 6, désactivé).
Pré-filtres par paramètre : `?vue=a-valider|a-facturer|direction|standby|a-commander|attente-materiel|duplicata`.

### 4.3 `/interventions/[id]` fiche
Onglets comme Access : **Demande** (tous les champs de l'onglet Création, analysis 02 §3.1), **Réalisation** (onglet Clôture : dates, heures, techniciens, retour fiche, panne, prestations, commentaires, devis à faire, gaz, PDF bon et dossier), **Devis** (devis liés par `intervention_origine_id` et par `numero_devis_accepte`), **Signatures** (noms + images si chemin http, sinon chemin affiché), **Facturation** (montants, différence calculée, statut, date, chemins factures), **Historique** (interventions du même site, 10 dernières).
Bandeau : type coloré, statut, site avec lien, alertes « garantie en cours » (règle analysis 03 §8.4), « plusieurs interventions ce jour », « nacelle ».

### 4.4 `/sites` liste
Source `v_sites_liste`. Filtres analysis 03 §6.1 : client, nom ou numéro, code, référence matériel (jointure), CE à éditer cette année, sans géolocalisation, non ROOFTOP, retard paiement, ne plus intervenir (via interventions statut 17), particulier, investissement, référence client d'intervention, numéro de bon.
Colonnes : numéro magasin, nom, client, ville, zone, intervenant, contrat clim (visites/an, redevances), sous-traitants, dernière visite entretien, retard paiement, ne plus intervenir.

### 4.5 `/sites/[id]` fiche
Bandeau rouge si `ne_plus_intervenir` ou `retard_paiement`. Badges devis en cours (statut devis 1, 2, 4 par famille), garanties en cours, « n CE à éditer ».
Onglets : **Site** (identité, installation, indicateurs étoiles, contrats par lot depuis `site_contrats`, tarifs, horaires, cases d'alerte, fermeture), **Interventions** (en cours : statut hors 7, 8, 10, 20 ; clôturées : dans 7, 8, 10, 20), **Matériel** (`site_materiels`, colonnes principales, charge fluide kg, CE), **Registre de sécurité** (dates), **Devis** (3 familles), **Documents** (chemins réseau affichés en texte copiable).

### 4.6 `/clients` et `/clients/[id]`
Liste : actifs par défaut, case « afficher tous ». Colonnes : nom, ville, contact, tarifs MO et déplacement, numéros Esabora.
Fiche : identité, tarifs, onglets Sites (recherche par numéro de magasin), Contacts, Devis (3 familles), Planifications.
`/donneurs-ordre` liste + fiche (contacts, sites rattachés).

### 4.7 `/intervenants` et `/intervenants/[id]`
Liste : filtres analysis 03 §6.4 (code, prospect, sous-traitant FMC, ponctuel, technicien interne, ne plus intervenir, n'existe plus, sans géoloc, non ROOFTOP, zones multi avec zone nationale, activités multi, texte libre nom/adresse/ville, villes couvertes, infos).
Fiche : identité, statuts, activités et tarifs, zones, notes qualité ; onglets Sites en contrat (clim, chaudière, désenfumage via `site_contrats.sous_traitant_id`), Historique des interventions par type, Techniciens (utilisateurs avec `code_intervenant`).

### 4.8 `/devis`
Onglets SAV, Travaux, Contrats (filtre `famille`). Filtres : client, site, statut, type de panne, envoyé par, période d'envoi. Colonnes : numéro, statut coloré (1 jaune, 3 bleu, 5 gris, 6 rouge), site, client, montants, envoyé par, date d'envoi, fichier (chemin), intervention d'origine, intervention générée (`interventions.numero_devis_accepte = devis.numero`).

### 4.9 `/planification` lecture
Par client : tableau `planifications` (rang, date limite, nombre de visites). Vue « entretiens à venir » : interventions type 1 statut 1 par site et date limite/prévue.

### 4.10 `/parametrage` lecture
Une page par référentiel, tableau simple. Écriture à l'étape 5.

## Critères d'acceptation

- Un gestionnaire retrouve 5 interventions, 5 sites, 3 devis connus avec les mêmes valeurs qu'Access.
- Les compteurs du tableau de bord sont égaux à ceux d'Access le même jour (ou l'écart est expliqué).
- Chaque liste répond en moins de 2 s sur 70 000 interventions (index de l'étape 1, pagination serveur).
- Aucune donnée personnelle dans les logs ou le repo. Build vert, push sur `main` page par page.

## État

- [x] Toutes les pages livrées : 4.1 tableau de bord, 4.2/4.3 interventions (liste + fiche à
  onglets), 4.4/4.5 sites (liste + fiche à onglets), 4.6 clients/donneurs d'ordre (liste +
  fiche), 4.7 intervenants (liste + fiche), 4.8 devis (3 familles), 4.9 planification,
  4.10 paramétrage (index + une page par référentiel).
- [x] Composants partagés `src/components/ui/` : `DataTable`, `FilterBar`, `Badge`, `Tabs`,
  `KeyValue`, `EmptyState`. Filtres dans l'URL, pagination serveur 50 lignes, tri par colonne
  (Server Components, pas de JS client nécessaire).
- [x] Migration `20260916100000_vues_etape4.sql` : `v_interventions_liste`/`v_sites_liste`
  complétées (zone_id, donneur d'ordre, sous-type, particulier, retard paiement, ne plus
  intervenir, investissement, chargé d'affaire) — colonnes nécessaires aux filtres du brief
  absentes des vues de l'étape 1. Vues recréées (`drop`+`create`, pas `create or replace`,
  qui interdit de réordonner les colonnes existantes). Testée idempotente sur Postgres local.
- [x] `npx next build` et `npx next lint` verts.
- [ ] **Non testé en conditions réelles** : pas d'accès à un projet Supabase (PostgREST) dans
  cette session, seulement à une base Postgres brute (schéma validé aux étapes 1-2, mais
  l'API REST que ces pages consomment ne peut pas tourner ici). Vérifié à la place par lecture
  croisée systématique de chaque nom de table/colonne référencé dans le code contre les
  migrations réelles, et `build`/`lint` stricts (TypeScript ne peut pas détecter une erreur de
  nom de colonne ici : aucun type `Database` généré n'est présent dans le repo — à envisager
  plus tard avec `supabase gen types`).
- [ ] **Simplifications documentées à vérifier avec FMC** (règles VBA non relues en détail,
  approximations raisonnables retenues) :
  - « Entretien proche » (`/interventions`) : type Entretien + statut À planifier + date
    limite dans les 30 jours, plutôt que la règle exacte avec `ecarts_visites`
    (legacy/analysis/02_interventions.md §8.1).
  - « Garantie en cours » (fiches intervention et site) : `date_mise_en_service` +
    max(garanties pièces/MO/compresseur) > aujourd'hui, plutôt que la règle exacte
    (legacy/analysis/03_clients_sites_materiel_intervenants.md §8.4).
  - « Ne plus intervenir » sur `/sites` utilise directement `sites.ne_plus_intervenir`
    plutôt que « via interventions statut 17 » (site plus simple et cohérent avec la donnée).
- [ ] Critères chiffrés (5 interventions/sites/devis connus, compteurs égaux à Access, < 2 s
  sur 70 000 lignes) non vérifiables sans les vraies données (étape 2) ni un vrai déploiement.

### À faire par l'utilisateur

1. Après un transfert de données réel (étape 2), ouvrir chaque page et comparer 5
   interventions, 5 sites et 3 devis connus avec Access.
2. Comparer les compteurs du tableau de bord à ceux d'Access le même jour.
3. Tester les temps de réponse des listes sur le volume réel.
4. Confirmer ou corriger les trois simplifications listées ci-dessus avec FMC ; les ajuster
   dans le code si besoin (recherche des commentaires « simplification documentée » dans
   `src/app/(app)/interventions/page.tsx`, `src/app/(app)/interventions/[id]/page.tsx`,
   `src/app/(app)/sites/[id]/page.tsx`).
