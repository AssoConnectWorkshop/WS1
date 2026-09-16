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
| Menu d'accueil (`Form_MenuClimAccess`) | `/` | oui (CDC p.1) | fait (PR menu d'accueil) |
| Liste des sites (`Form_ListeSiteGenerale`) | `/sites` | oui (CDC p.2) | fait (PR liste des sites) |
| Fiche site (`Form_Site`) | `/sites/[id]` | oui (CDC p.2) | fait (PR fiche site) |
| Carte (module PHP, `Form_Carte`) | `/carte` | oui (CDC p.3) | fait (PR carte) |
| Liste des interventions (`Form_ListeInterventionGenerale`) | `/interventions` | oui (lot 2, deux états) | fait (PR lot 2) |
| Fiche site, onglet Interventions | `/sites/[id]?onglet=interventions` | oui (lot 2) | fait (PR lot 2) |
| Fiche site, onglets Devis SAV / Travaux / Contrat (`DevisListe*`) | `/sites/[id]?onglet=sav…` | oui (lot 3) | fait (PR lot 2) |
| Fiche client (`Form_Client`) | `/clients/[id]` | oui (lot 2) | fait (PR lot 2) |
| Fiche intervention (`Form_Intervention`), onglets Clôture et Devis SAV | `/interventions/[id]` | oui (lot 3) | fait (PR lot 3-5) |
| Rapport d'intervention (bon PDF) | `/interventions/[id]/bon.pdf` | oui (lot 3) | à comparer (document, pas un écran) |
| Paramétrage (`Form_Parametrage`), Utilisateurs & Techniciens, Zones | `/parametrage`, `/parametrage/utilisateurs` | oui (lots 4-5) | fait (PR lot 3-5) |
| Modification Véhicule (`Form_99`) | `/vehicules/[id]` | oui (lot 5) | fait (PR lot 3-5) |
| Liste des sites : colonnes « Ct » (dossier) et « Co » (code) | `/sites` | oui (lot 4, capture nette) | fait (PR lot 3-5) |
| Planification | `/planification` | non | attendre la capture |
| Explorateur du serveur de fichiers (dossiers devis) | — | oui (lots 3-4, contexte) | hors code : arborescence `Commun\Commercial\A4- DEVIS\{A0- FMC Maintenance, A1- FMC Climatisation}\Devis AAAA SAV|TR` |

## Écarts non traités (à remplir)

Comportements Access visibles sur les captures mais absents de l'application, à décider plus tard.

- **Menu d'accueil** : icônes « Utilisation FF » (liste des interventions avec gaz, `ListeInterGaz`),
  « Filtre Extraction » (export Excel du parc matériel) et « Intervalle de dates à afficher sur
  tablette » affichées grisées : pas d'équivalent dans l'application. « Mot de Passe Kadi » et « Voir
  Tables » ne sont pas reproduits (remplacés par le rôle administrateur et Paramétrage › Utilisateurs).
  Les illustrations 3D d'Access sont remplacées par des pictogrammes ; le bouton « MAJ » recharge la
  page. Le rafraîchissement automatique toutes les 60 s n'est pas reproduit.
- **Liste des sites** : case « Modification » (bascule Access vers la requête `ListeSite2`, sans
  effet visible) non reproduite ; les cases Access sont tri-état (coché / décoché / indifférent),
  ici deux états (coché = filtre actif). La ligne sélectionnée surlignée en bleu n'a pas
  d'équivalent (pas de sélection de ligne) ; la colonne « Cl » (bouton d'ouverture) est remplacée
  par le lien sur le nom.
- **Fiche site** : bouton « Créer une intervention Résolu Par Téléphone » non reproduit (la
  résolution par téléphone se fait sur la fiche intervention après création) ; « N° Esabora Clim /
  Maint » du client remplacés par le seul « N° unique Esabora » du site ; « Nb.(Infos) » du tarif
  Clim 1 (nombre de visites techniques) absent du modèle cible ; les onglets « Contrat de
  maintenance », « Devis SAV », « Devis Travaux » listent les devis du site sans les colonnes
  détaillées des sous-formulaires Access ; les boutons « Renseigner Colonne Nom Tech » et
  « Régénérer le planning prévisionnel des entretiens » de l'onglet Interventions ne sont pas
  reproduits. Les cases « NE PLUS INTERVENIR » et « Fermé » passent par une confirmation (effets de
  bord sur les interventions) au lieu d'un simple clic.
- **Carte** : le module PHP affiche aussi le lieu de vie des techniciens (épingle « Technicien ») ;
  l'application n'a pas d'adresse de domicile des techniciens, la case « Technicien » n'est donc pas
  reproduite. Les icônes Access (cône pour « En travaux », pictogrammes de statut) sont remplacées par
  des épingles colorées uniformes. Les filtres par zone et par donneur d'ordre, absents de la
  capture, ont été retirés de la page carte (ils restent sur la liste des interventions).
- **Liste des interventions** : « Imprimer les interventions à réaliser » et « Exporter clients »
  pointent tous deux sur l'export Excel de la liste filtrée (pas d'état imprimable) ; « Export
  Saisie Heures » grisé (pas d'équivalent) ; cases à cocher en deux états au lieu de trois ; la
  suppression d'une ligne depuis la liste n'est pas reproduite ; la colonne « Date der… » de la
  capture est interprétée comme la dernière visite d'entretien du site.
- **Fiche site, onglet Interventions** : colonne « Nom Tech » non reprise (elle vient de la colonne
  détournée `numdevpartenaire`, alimentée par le bouton « Renseigner Colonne Nom Tech » non
  reproduit) ; colonnes de devis SAV / TR (Devis SAV Fait, Statut Devis, Devis TR…) non reprises.
- **Onglets Devis SAV / Travaux / Contrat** (fiche site) : « Rendre Insertion Devis Possible »
  ouvre la création de devis ; les fiches sont en lecture, la modification se fait sur `/devis/[id]`.
- **Fiche client** : le bouton carte ouvre `/carte` filtrée sur le nom du client ; les onglets
  Planifications et Exports Excel (absents d'Access, qui passe par Statistiques) sont conservés
  après les trois onglets Access.
- **Fiche intervention** : l'onglet « Création d'intervention » n'a pas encore été capturé (contenu
  actuel conservé, bloc facturation déplacé dans cet onglet comme dans Access) ; le statut n'est
  pas modifiable par liste déroulante : les transitions passent par les boutons Clôturer /
  Déclôturer / Valider (règles métier : PDF obligatoire, replanification) ; « Liste Sous Traitants
  Possibles » renvoie à l'annuaire des intervenants sans filtre par activité ; « Date réelle de
  saisie » est portée par la date de retour de fiche ; l'onglet Historique a été retiré (les autres
  interventions du site sont sur la fiche site).
- **Paramétrage** : « Access Gestion Mot de passe » (génération et envoi des mots de passe du
  portail web) non reproduit ; l'invitation à l'application le remplace. « Références » ouvre le
  catalogue matériel de l'application (colonnes différentes du sous-formulaire Access).
- **Fiche véhicule** : les dates et km « dernier entretien / CT / CC / relevé » sont calculés depuis
  les événements et affichés en lecture seule (comme Access) ; la saisie des événements reste sous
  la fiche (Access : formulaire séparé « Saisie_EV_Vehicule »).
- **Captures hors périmètre du CDC** (non traitées) : fiche intervention web du technicien (p.3),
  planning Outlook et planning prévisionnel Excel (p.4), trois écrans Esabora (p.5-6).

## Critères d'acceptation

- Pour chaque écran traité, un utilisateur FMC devant la capture Access et la page web retrouve les
  mêmes zones, dans le même ordre, avec les mêmes libellés.
- Build vert à chaque push ; aucune capture ni donnée réelle dans le dépôt.
- Tableau « Correspondance » à jour, section « État » ci-dessous mise à jour à chaque PR mergée.

## État

- [x] Brief rédigé le 16/09/2026 à partir du cahier des charges FMC.
- [x] 16/09/2026 : cahier des charges PDF lu (6 pages, 10 captures ; 4 dans le périmètre, 6 hors
  périmètre). Lot 1 = les 4 captures du CDC.
- [x] Menu d'accueil `/` : grille d'icônes en quatre rangées comme Access (Clients, Sites,
  Entretien / Dépannage Devis acceptés, « Utilisateur choisi », Utilisateurs ; Duplicata, Matériel à
  commander, Attente matériel, Fiches à valider, Fiches à facturer + MAJ, À valider par le Boss ;
  Paramétrage, Statistiques, Contrat de maintenance, Devis SAV, Devis travaux, Intervenants,
  Véhicules ; Carte, Planification), pastilles colorées : duplicata (total rose, à traiter violet,
  attente offre de prix rose), à valider rouge, à facturer ventilé maintenances bleu / devis SAV
  rouge / dépannage vert / travaux orange / autres violet + stand-by, Boss rouge, véhicules (5),
  logos FMC Climatisation / FMC Maintenance en pied.
- [x] Liste des sites `/sites` : barre de filtres dans l'ordre Access (Client en liste, N° Site ou
  Nom du site, Code, N° de Bon, N° DI, Site sans géoloc, Site non rooftop, Retard Paiement, Sites
  « Ne pas intervenir », Référence Matériel, Investissement, Particulier, CE à éditer, Inter en
  cours en « Ne pas intervenir ») ; colonnes RDV à Prendre, Donneur, Intervenant, Zone, N°, Client,
  Contrat client, Tarif 1 Cl, Tarif 2 Cl, Nb Entretien, Nom, Adresse, CP, Ville, Commentaire.
  Filtre « non rooftop » aligné sur Access (précision du géocodage ≠ ROOFTOP). Vue `v_sites_liste`
  complétée (migration `20260916170000_etape8_v_sites_liste.sql`).
- [x] Fiche site `/sites/[id]` : en-tête « Site : NOM (n°) - Ville : VILLE » avec Créer une
  intervention, N CE à éditer, Enregistrer, Fermer ; onglets Access (Site, Interventions, Contrat de
  maintenance, Devis SAV, Devis Travaux, Matériel, Infos complémentaires Site) ; onglet Site en
  quatre colonnes de cadres comme la capture : donneur d'ordre / intervenant clim / Particulier /
  RDV à prendre / Esabora, Infos Site, surfaces et responsable, Zone d'intervention,
  Géolocalisation, Tarif MO et DP | Infos Install, Contrat Entretien Clim / Chaudière /
  Désenfumage | dossier réseau, Garanties, Registre de sécurité, Information divers, A Faire,
  Divers, Site fermé, Investissement | badges (DEVIS SAV EN COURS…), Commentaire général Magasin,
  Commentaire divers. Fond rouge si « Ne plus intervenir » ou « Retard paiement ». Onglet
  Interventions en deux tableaux (en cours, clôturées) avec les colonnes principales d'Access.
- [x] Carte `/carte` : en-tête « Retour Menu - Carte des interventions à réaliser du … au … Nb
  Résultats », légende cliquable par type avec épingles colorées (Maintenance, Dépannage, Devis
  SAV, Devis SAV (Pour TR), En Travaux, Désenfumage, Audit, Entretien Chaudière, Attente Fiche,
  Tout), liste des techniciens, cases Intervenant FMC / Intervenant Ponctuel, légende des statuts
  (A planifier, A Commander, En attente de matériel, Devis SAV) à droite ; carte plein écran, fonds
  STREETS / SATELLITE, une épingle par site numérotée du nombre d'interventions, halo orange si
  date limite dépassée ; info-bulle au format Access (type, site, adresse, zone, intervenant, date
  limite, dernière visite de maintenance, tech. prévu, date prévue, commentaire général site,
  commentaire intervention, liens Devis Encours / Liste Sous Traitants, boutons Copie Titre / Copie
  Intervention). Vue `v_interventions_liste` complétée (migration
  `20260916180000_etape8_v_interventions_liste_carte.sql`).
- [x] Lot 2 (captures fiche site onglets Site et Interventions, liste des interventions « A
  Planifier » et « Réalisé - A Valider », fiche client) et lot 3 partiel (onglet Devis SAV de la
  fiche site) : liste des interventions `/interventions` avec le bloc de filtres Access (Client,
  N° Site ou Nom du site, Statut Intervention, Statut Facturation, Intervenant, Donneur d'ordres,
  Zone multi, Afficher les clôturées, Type Inter., Entre le / et, Filtre sur date réelle,
  Rechercher, Nouvelle intervention, Imprimer…, Recherche Entretien « Proche », Photo, Audit, MàJ
  Registre, Contrôle d'étanchéité, Particulier, Devis à Faire, SousType Vide, Exporter clients,
  Export Saisie Heures) et les colonnes de la capture (Statut Factur, Non Fact., Date appel, Date
  dern. visite, Date prév, Duplicata à Traiter, Attente offre, Client, N° DI Client, Type,
  Commentaire client, Sous Type, Devis à faire, Urgence Devis, Comm. Devis, N° Devis accepté,
  Statut, Site, Date limite, Effectuée le, Intervenant, Nom Tech, Devis fait, Comm. Inter., Zone,
  Ville, N° Site, N° Bon, Traitée par) ; tableaux plus denses (texte 12 px, survol bleu) ; fiche
  site : onglet Interventions avec les colonnes Access, onglets Devis SAV / Devis Travaux /
  Contrat de maintenance en fiches empilées avec barre de filtres et fond rouge pour les devis
  acceptés ; fiche client : en-tête de recherche « N° de site ou Nom de client » (nombre → liste
  des sites), champs disposés comme Access, onglet Sites en tableau (N° de magasin, Site,
  Situation, Adresse, CP, Ville). Vue `v_interventions_liste` complétée (migration
  `20260916190000_etape8_v_interventions_liste_generale.sql`).
- [x] Lots 3 à 5 : fiche intervention `/interventions/[id]` (titre « Création et Clôture
  d'intervention - TYPE » sur fond coloré par type, boutons Envoyer un mail au contact / partenaire
  / client, onglets Création d'intervention, Clôture de l'intervention en cours, Devis SAV, Devis
  Travaux, Signatures ; onglet Clôture en trois colonnes avec tous les champs de la capture et un
  seul bouton Enregistrer, bandeau rouge « GARANTIE ENCORE EN COURS », onglets devis façon
  `DevisListe` avec « INFORMATIONS SUR LE DEVIS ») ; action de clôture étendue à tous les champs
  (retour fiche, contrôles, gaz, temps, saisie par, commentaires, statut facturation avec règle des
  statuts réservés, panne, devis à faire, duplicata) ; paramétrage `/parametrage` avec la colonne
  de boutons Access à gauche sur toutes les pages du paramétrage, page « Utilisateurs &
  Techniciens » en feuille de données (Nom, Prénom, Type utilisateur, Immat, Intervenant, Société,
  Code FMC, Login FMC, Mail) ouverte à tous en lecture ; fiche véhicule `/vehicules/[id]` disposée
  comme « Modification Véhicule » (cadres Garantie, Revision(2), Divers, Leasing, Contrôles,
  Raccourci vers le PC, boutons Quitter (SANS SAUVEGARDE) et enregistrer) ; liste des sites :
  colonnes « Ct » (dossier réseau) et « Co » (code). Migration
  `20260916200000_etape8_v_sites_liste_dossier.sql`.
- [x] Suite du call de démo FMC du 15/09 (transcript analysé, rien de commité) : onglet « À faire »
  `/taches` (kanban backlog / next / in progress / to validate / suspended / done, cartes avec
  description, déplacement, édition, suppression ; table `taches`) alimenté avec la décision de
  découpage de la bascule (next) et les évolutions à discuter (backlog) ; coordonnées d'un site
  saisissables avec collage « latitude, longitude » depuis Google Maps (précision « SAISIE
  MANUELLE ») ; module « Utilisation FF » `/interventions/gaz` (interventions avec gaz, filtres,
  somme des kg) ; heures vendues saisissables et heures passées calculées depuis les fiches d'heures
  dans l'onglet Clôture, dépassement en rouge ; rôle « comptable » (statuts de facturation réservés,
  remplace le mot de passe Kadi) attribuable depuis Utilisateurs & Techniciens ; message d'erreur de
  requête affiché sous les listes et comptage estimé sur la liste générale (liste vide constatée en
  production). Migration `20260916210000_etape8_taches_gaz_comptable.sql`.
- [x] Kanban `/taches` en glisser-déposer natif avec panneau de détail (titre en grand, colonne,
  dates, description) ; carte « comptage estimé » ajoutée en Next. Les entrées du menu vers la liste
  des interventions (`?vue=`) sont traduites en filtres visibles (statut, statut facturation, devis
  à faire) : tout décocher redonne la même liste partout, comme dans Access. La liste vide en
  production était bien due au comptage exact : elle s'affiche depuis le passage en comptage estimé.
- [ ] À faire quand les captures arriveront : onglet « Création d'intervention », planification,
  fiche intervenant, listes de devis générales, comparaison du rapport d'intervention PDF.
