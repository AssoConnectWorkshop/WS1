# Étape 8 — Reproduction des écrans Access à partir des captures

## Objectif

Rapprocher chaque écran de la nouvelle application de son équivalent Access **au plus simple et
quasi à l'identique** : mêmes zones, même ordre des champs, mêmes libellés, mêmes boutons, mêmes
codes couleur. L'amélioration de l'ergonomie viendra plus tard ; à ce stade on veut que les
utilisateurs FMC retrouvent leurs repères. Le cahier des charges FMC (PDF « Cahier des charges,
Migration du logiciel de gestion FMC », 11/09/2026) le confirme : phase 1 = parité fonctionnelle à
l'identique, aucune nouvelle fonctionnalité.

## Situation de départ

- Étapes 1 à 7.1 terminées : application en production sur `https://assoconnect-ws1.vercel.app/`,
  **vraies données chargées** (71 507 interventions, 6 163 sites, 2 323 clients…), compte
  administrateur créé. Voir `docs/plan/etape-6.md` et `docs/plan/etape-7.md` (sections État).
- Ce qui reste hors code (Resend, cron, logos, script documents) est listé dans `etape-7.md` et ne
  bloque pas cette étape.
- Les anomalies de données connues sont dans `docs/problemes-donnees.md` : ne pas les corriger ici,
  seulement compléter le journal si une capture en révèle une nouvelle.

## Matériel fourni par l'utilisateur, dans la conversation

L'utilisateur envoie des **captures d'écran de l'application Access** (et du module carte PHP), par
lots de 5 images maximum par message, sans les nommer forcément. Le cahier des charges PDF peut aussi
être joint (6 pages, 10 captures embarquées : menu d'accueil, liste des sites, fiche site, carte,
fiche intervention web du technicien, planning Outlook, planning prévisionnel Excel, Esabora).

**Aucune capture ne doit être commitée** : elles montrent des clients et des sites réels
(règle « pas de donnée réelle dans le dépôt »). Les analyser dans la conversation, décrire la
structure dans ce brief si utile, jamais l'image.

## Méthode, pour chaque lot de captures

1. **Trier** : identifier l'écran Access de chaque capture (nom du formulaire dans le titre de la
   fenêtre ou d'après `legacy/extracted/forms/*.txt`, qui liste libellés et contrôles de chaque
   formulaire) et la route correspondante dans l'application (`src/app/(app)/...`). Tenir à jour le
   tableau « Correspondance » ci-dessous. Signaler les captures hors périmètre (tablette, portail,
   Outlook, Excel, Esabora : voir `docs/hors-perimetre-tablette-portail.md`) sans les traiter.
2. **Comparer** avec l'écran actuel : lire le composant, lister les écarts de structure (zones,
   ordre, libellés, boutons, couleurs de statut, colonnes de liste, filtres et leur disposition).
3. **Ajuster** au plus proche : même ordre et mêmes libellés qu'Access, colonnes de liste
   identiques, boutons au même endroit. Garder l'existant technique (Server Components, formulaires
   URL-driven, composants `src/components/ui/*`). Pas de nouvelle fonctionnalité, pas de refonte.
   Un écran Access dont le comportement n'existe pas encore dans l'application : le noter dans
   « Écarts non traités » plutôt que de l'inventer.
4. **Vérifier** : `npm run build` sans erreur ni avertissement ; noms des Server Actions exportées
   en ASCII (contrôle `grep -lP '[^\x00-\x7F]' .next/server/*manifest*.json` doit être vide).
5. **Livrer** : commit sur `tentative-1`, PR vers `main`, merge dès que le check Vercel est vert,
   puis `git fetch origin main && git rebase --autostash origin/main && git push`. Dire à
   l'utilisateur quelle page ouvrir en production et quoi regarder. Ne pas demander de validation
   intermédiaire : l'utilisateur a demandé d'avancer sans checkpoints.

Priorité des écrans : menu d'accueil / tableau de bord, liste des interventions, fiche
intervention, liste des sites, fiche site, fiche client, planification, puis le reste.

## Ce qu'on sait déjà des captures du cahier des charges

- **Menu d'accueil Access** : grille d'icônes illustrées (une par fonction : clients, sites,
  entretien / dépannage / devis acceptés, utilisateurs FP, tableau de bord, dupliquer, matériel à
  commander, fiches d'intervention à valider / en retour, à valider pas de devis, filtre
  extraction, paramétrage, statistiques, contrat de maintenance, devis SAV, devis travaux,
  intervalle de dates à définir, intervenants, véhicules, tous tableaux), avec des **pastilles de
  compteurs colorées** (rouge, bleu, vert, violet…) sur les icônes concernées, le nom de
  l'utilisateur connecté au centre, et deux logos (FMC Climatisation, FMC Maintenance) en bas.
  Notre tableau de bord actuel est en cartes textuelles : reproduire la grille et les compteurs
  (les valeurs viennent de `v_tableau_de_bord`, voir `src/lib/vues-tableau-de-bord.ts`).
- **Liste des sites** : barre de filtres en haut (client, n° site ou nom, référence matériel, nom
  du site, code postal, n° de bon, cases « site sous contrat », « sites avec matériel », « site
  fermé », etc.), puis un tableau très dense, une ligne par intervention/site, avec coche de
  sélection, colonnes N°, client, intervenant, date, type, statut, adresse, CP, ville,
  commentaire ; ligne sélectionnée surlignée en bleu.
- **Fiche site** : en-tête « Site : NOM (CAP 3000) – Ville : … », **onglets** (Site,
  Interventions, Contrat de maintenance, Matériel, Fiche Technique, Habilitation, Fluides / Contrôle
  d'étanchéité, Historique), corps en trois colonnes de cadres : identité et adresse à gauche,
  contacts / horaires / responsable au centre, commentaires et indicateurs (cases à cocher photo,
  audit, contrôle étanchéité, registre sécurité) à droite, boutons d'action (Enregistrer, Fermer,
  Modifier) en haut à droite.
- **Carte** (module PHP) : plein écran, en-tête « Retour Menu – Carte des interventions à réaliser
  du … au … Nb résultats », légende par type avec icônes colorées, épingles numérotées, info-bulle
  avec adresse, dates, techniciens, commentaire et boutons « Copier titre / Copier intervention ».
  Notre `/carte` est proche ; aligner la légende et l'info-bulle.
- **Fiche intervention du technicien** (web, hors périmètre bureau) et **planning Outlook / Excel**
  (hors périmètre, phase 2 du cahier des charges) : ne pas reproduire.

## Correspondance captures → écrans (à compléter au fil des lots)

| Écran Access (formulaire) | Route application | Capture reçue | État |
|---|---|---|---|
| Menu d'accueil (`Form_MenuClimAccess`) | `/` | oui (CDC p.1) | à faire |
| Liste des sites (`Form_ListeSiteGenerale`) | `/sites` | oui (CDC p.2) | à faire |
| Fiche site | `/sites/[id]` | oui (CDC p.2) | à faire |
| Carte | `/carte` | oui (CDC p.3, module PHP) | à faire |
| Liste des interventions | `/interventions` | non | attendre la capture |
| Fiche intervention | `/interventions/[id]` | non | attendre la capture |
| Fiche client | `/clients/[id]` | non | attendre la capture |
| Planification | `/planification` | non | attendre la capture |

## Écarts non traités (à remplir)

Comportements Access visibles sur les captures mais absents de l'application, à décider plus tard.

## Critères d'acceptation

- Pour chaque écran traité, un utilisateur FMC devant la capture Access et la page web retrouve les
  mêmes zones, dans le même ordre, avec les mêmes libellés.
- Build vert à chaque push ; aucune capture ni donnée réelle dans le dépôt.
- Tableau « Correspondance » à jour, section « État » ci-dessous mise à jour à chaque PR mergée.

## État

- [x] Brief rédigé le 16/09/2026 à partir du cahier des charges FMC.
- [ ] Écrans traités : aucun pour l'instant.
