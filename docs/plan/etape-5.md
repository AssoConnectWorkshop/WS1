# Étape 5 — Écrans de saisie

## Objectif

L'application remplace Access pour le travail quotidien du bureau. Chaque écran de l'étape 4 devient
éditable, avec les règles métier du code VBA. **Lire le fichier `legacy/analysis/` du domaine avant chaque écran.**
Valider chaque écran avec l'utilisateur avant de passer au suivant.

## Conventions

- Server Actions avec validation `zod`, messages d'erreur en français, mêmes textes que les MsgBox Access quand ils existent (`legacy/extracted/vba_msgbox.txt`).
- Toute écriture passe par un utilisateur rattaché (`getCurrentUser()`), `updated_at` automatique, colonnes « par qui » remplies avec `utilisateur.id`.
- Suppression : jamais physique pour interventions, sites, clients, devis. Ajouter `supprime_le timestamptz` et filtrer.
- Journal : table `journal_modifications` (`table`, `ligne_id`, `utilisateur_id`, `date`, `diff jsonb`) alimentée par les Server Actions des interventions et devis.

## 5.1 Intervention (analysis 02)
- Création depuis `/interventions/nouvelle`, depuis une fiche site (site pré-rempli, intervenant = intervenant du site, chargé d'affaire = utilisateur), depuis un devis accepté (voir 5.2).
- Valeurs par défaut : date de demande = aujourd'hui, statut 1, nature 3, type choisi obligatoirement.
- Champs obligatoires à la création : site, type, objet. Date limite recommandée : avertissement non bloquant si vide (« La date limite d'intervention n'est pas saisie »).
- Cohérences : date prévue ≥ date de demande ; heure départ > heure arrivée ; date réalisée requise pour cocher « registre mis à jour ».
- **Résolu par téléphone** : case → statut 10, `non_facturable = true`, date réalisée = aujourd'hui, `minutes_telephone` obligatoire > 0. Décocher → statut 1.
- **Clôturer** (bouton, confirmation) → statut 9. **Déclôturer** → statut 1. Passage manuel à 7 refusé si `chemin_bon_pdf` vide (« La demande ne peut pas être clôturée s'il n'y a pas de fichier associé »).
- Passage à 7 : pointage des techniciens intervenus dans `heures_techniciens` (une ligne par technicien, date réalisée, heures arrivée/départ, `intervention_numero_bon`), si date et heures présentes.
- Entretien (type 1) avec « registre mis à jour » coché → insérer dans `site_registre_securite` si absent pour ce site et cette date.
- Statut facturation : modification refusée si l'ancien ou le nouveau statut a `reserve_admin` et que l'utilisateur n'est pas administrateur.
- Sous-traitance : si intervenant ≠ FMC, afficher numéro de demande sous-traitant et « envoyé par ». Pas d'envoi de mail à cette étape.
- Saisie de `montant_fmc` → `date_facturation = aujourd'hui` si vide.
- Rappels : cocher une case → `date_dernier_rappel = now()`. L'envoi automatique est en étape 6.
- « Nouvelle intervention à partir de celle-ci » : copie site, contact, intervenant, type, référence client, référence interne, heures vendues, panne ; statut 1.
- « Partie suivante » : copie complète sauf dates/heures réelles, signatures, PDF, booléens de clôture ; commentaire interne préfixé « PARTIE n : ».
- **Replanification à la clôture** (décision section 8 du plan, défaut) : à la clôture (9) d'une intervention **de type 1 seulement**, si le site a 2 ou 4 visites/an et que le mois de la date réalisée est avant juillet (2) ou octobre (4), proposer (modale, pas automatique) de supprimer les entretiens prévus non réalisés du site et de régénérer selon 5.4.
- Techniciens intervenus : sous-liste ajout/suppression parmi les utilisateurs profil 2 dont `code_intervenant` = code de l'intervenant, ou société FMC ; mettre à jour `noms_techniciens`.

## 5.2 Devis (analysis 04 §1)
- Création dans une famille, site et client, statut 1 par défaut. Saisie du chemin ou dépôt du PDF (Storage bucket `devis`, étape 6 ; d'ici là chemin texte).
- Numéro : saisi manuellement (ne pas reproduire l'extraction depuis le nom de fichier), pré-rempli depuis le nom de fichier si le motif `XX-NNNN` est reconnu.
- Tarifs : si vides, pré-remplis depuis le client (ou le site si `tarifs_specifiques`) puis figés. **Montant HT = fournitures + heures × tarif heure + déplacements × tarif déplacement**, recalculé à chaque changement, modifiable à la main avec avertissement.
- `date_envoi` posée automatiquement au passage au statut 4 si vide.
- Statut 3 : champ « remplacé par » obligatoire.
- **Générer l'intervention** (statut ≠ 6) : crée une intervention statut 1, type 3 (sav, contrat) ou 5 (travaux), date de demande = aujourd'hui, objet = numéro du devis, intervenant = intervenant du site, `numero_devis_accepte`, `heures_vendues`, `montant_ht_devis_accepte` ; devis → statut 6 ; ouvre l'intervention.
- Après tout changement de statut : recalculer `sites.resume_devis_html` (liste des devis statut 4 du site).

## 5.3 Site et client (analysis 03)
- Site : formulaire par onglets ; client, nom et donneur d'ordre verrouillés par défaut (bouton « déverrouiller »). Contrats : trois blocs éditables (lot), création automatique de la ligne `site_contrats`. Horaires par jour. Cases d'alerte.
- Changer le client d'un site → propager sur ses devis.
- **Fermer un site** : confirmation, `ferme = true`, date, motif ; rattachement au client « fermé » (legacy 368) et propagation sur les devis, avec conservation de l'ancien client dans `client_avant_fermeture_id` (nouvelle colonne, correction d'un défaut Access).
- **Ne plus intervenir** : confirmation ; interventions du site en statut -1, 1, 9 → 17. Décocher : administrateur seulement ; 17 → 1.
- Matériel : ajout depuis le catalogue (référence 1 × N, référence 2 × N, alternance 1 puis 2), copie des valeurs, `quantite = 1` ; édition en ligne ; import Excel non repris (remplacé par saisie et par l'ajout catalogue).
- Client : fiche, tarifs, contacts. Donneur d'ordre : fiche, contacts.
- Géocodage : bouton appelant une API de géocodage gratuite (adresse.data.gouv.fr, sans clé), stocke lat/long et précision.

## 5.4 Planification des entretiens (analysis 04 §2, décision section 8 du plan)
- Écran par client : nombre de visites, jusqu'à 12 dates limites, référence DI par date, lot (clim / chaudière / désenfumage).
- Générer : pour chaque site du client dont `site_contrats.visites_par_an` (du lot) = nombre saisi, une intervention par date : type 1 (clim), 13 (chaudière), 7 (désenfumage) ; statut 1, ou 17 si `ne_plus_intervenir` ; date limite ; référence client ; intervenant = sous-traitant du lot, sinon intervenant du site, sinon FMC. Anti-doublon pour tous les lots (même site, même type, même date limite). Compte rendu affiché.
- Mode calculé (dates prévues) : par client ou site, pas de `12 / visites_par_an` mois depuis la dernière visite réalisée (sinon 15/12 année précédente) jusqu'à une date de fin saisie ; ajustement férié (−1 j), samedi (−1), dimanche (+1) ; supprime d'abord les entretiens prévus non réalisés du site (type 1 uniquement) ; même règle d'intervenant. Les calendriers fixes « clients 1, 2, 40, 49, 77 » ne sont **pas** repris ; le signaler à l'utilisateur.
- Jours fériés : écran de paramétrage.

## 5.5 Intervenants (analysis 03 §4)
Fiche éditable, activités (6 lignes max, tarifs, date), zones (4 max + zone nationale), statuts, notes, ne plus intervenir avec motif.

## 5.6 Paramétrage (administrateur)
CRUD sur chaque référentiel : statuts (ordre d'affichage, actif, réservé admin), types, sous-types, pannes, fluides et familles, marques, catalogue de références (validation analysis 03 §3.5 : champs obligatoires, puissances entières en W, nom unique ; propagation optionnelle aux matériels de même référence sauf fluide et charge), repères, types de télécommande, types d'équipement, activités, zones, sociétés, jours fériés, écarts entre visites, utilisateurs (étape 3).

## Critères d'acceptation

- Pour chaque écran : scénario de test écrit dans `docs/plan/tests/etape-5-<ecran>.md` (saisie, résultat attendu), joué par l'utilisateur.
- Une semaine de double saisie Access / nouvelle application sur un client pilote sans écart.
- Build vert, push sur `main` écran par écran, `État` mis à jour.

## État

- [x] Conventions transverses : migration `supprime_le` (interventions/sites/clients/devis) et table `journal_modifications` (RLS ajout seul).
- [x] 5.1 Intervention : création (`/interventions/nouvelle`, pré-remplie depuis un site), modification demande/réalisation/facturation, résolu par téléphone, clôture/déclôture/validation (avec pointage `heures_techniciens` et refus si `chemin_bon_pdf` vide), proposition de réplanification à la clôture, mise à jour `site_registre_securite`, gestion des techniciens intervenus, « nouvelle intervention à partir de celle-ci », « partie suivante ». Journalisé (`journal_modifications`) sur chaque écriture.
- [ ] 5.1 — simplifications assumées à valider avec l'utilisateur avant de continuer :
  - La confirmation de réplanification annule les entretiens non réalisés mais ne régénère pas encore la planification (dépend de 5.4, pas encore livrée).
  - Pas d'envoi de mail sur les rappels (prévu étape 6, conforme au brief).
  - Pas de scénario de test écrit dans `docs/plan/tests/` (accès Supabase/PostgREST non disponible dans ce bac à sable ; vérifié par build/lint + relecture manuelle du schéma + migration testée en idempotence sur Postgres local).
- [x] 5.2 Devis : création (`/devis/nouveau`, depuis la liste, une fiche site ou une intervention d'origine), fiche `/devis/[id]` éditable (statut, fichiers, montants, partenaire), numéro déduit du nom de fichier (motif `XX-NNNN`), tarifs pré-remplis client/site puis figés, montant HT recalculé à l'enregistrement (saisie manuelle conservée avec avertissement), `date_envoi` posée au statut 4, « remplacé par » obligatoire au statut 3, génération de l'intervention (type 3/5, devis → 6), recalcul de `sites.resume_devis_html`, suppression logique. Migration : `devis.legacy_id` nullable.
- [x] 5.3 Site et client : fiche site éditable par sections (client / nom / donneur verrouillés, « Déverrouiller » via l'URL ; changement de client propagé aux devis), trois contrats par lot (ligne `site_contrats` créée à l'enregistrement, pivots `visites_entretien_par_an` / `nombre_desenfumage` synchronisés), horaires par jour, cases d'alerte, fermeture avec confirmation (client « sites fermés » + `client_avant_fermeture_id`, devis propagés, réouverture possible), « Ne plus intervenir » avec confirmation (-1/1/9 → 17 ; retour 17 → 1 réservé à l'administrateur), géocodage adresse.data.gouv.fr, création de site. Matériel : ajout depuis le catalogue (réf. 1 × N, réf. 2 × N, alternance), équipement vide, édition en ligne, suppression. Client et donneur d'ordre : fiche éditable, contacts (ajout, édition, suppression), création. Migration : `sites.client_avant_fermeture_id`.
- [ ] 5.3 — simplifications assumées : pas d'import Excel d'audit (remplacé par la saisie et le catalogue, conforme au brief) ; le « Voir sur Maps » Access n'est pas repris (les coordonnées sont affichées) ; les liaisons référentiel du matériel restent textuelles (listes de suggestion), comme en source.
- [x] 5.4 Planification : écran par client (lot clim / chaudière / désenfumage, nombre de visites, jusqu'à 12 dates limites avec référence DI), génération d'une intervention par site concerné (contrat du lot au nombre de visites saisi) et par date : type 1 / 13 / 7, statut 1 ou 17 si « ne plus intervenir », intervenant = sous-traitant du lot → intervenant du site → FMC, anti-doublon site + type + date limite, compte rendu affiché. Mode calculé (dates prévues, clim) par client ou site : pas de 12 / visites mois depuis la dernière visite réalisée sinon 15/12 de l'année précédente, ajustement férié / samedi / dimanche, entretiens prévus non réalisés annulés (statut 8, jamais de suppression physique) ; calendriers fixes Access signalés, non repris. Migration : `planifications.legacy_id` nullable, colonnes `lot` et `reference_client`. Jours fériés : écran de paramétrage (5.6).
- [x] 5.5 Intervenants : fiche éditable (identité, contacts, statuts, activités possibles / confiées, notes 1 à 5, divers), six activités avec tarifs MO / déplacement et date, quatre zones + zone nationale, « Ne plus intervenir » avec motif (sans effet sur les interventions, comme en source), création avec code unique.
- [x] 5.6 Paramétrage (administrateur) : CRUD générique sur chaque référentiel piloté par `lib/referentiels-config.ts` (colonnes typées, code métier attribué automatiquement, messages sur doublon et sur valeur utilisée), statuts avec ordre d'affichage / actif / réservé admin, jours fériés, écarts entre visites, familles de gaz ; catalogue de références matériel avec les validations Access (champs obligatoires, puissances entières en W, quantités numériques, nom unique) et propagation optionnelle aux équipements de même référence sauf fluide et charge ; utilisateurs (étape 3). Lecture ouverte à tous, écriture réservée à l'administrateur.
