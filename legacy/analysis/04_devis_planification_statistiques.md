# ClimAccess — Compte rendu fonctionnel D : Devis, Planification, Statistiques, Extractions, Parc auto

Sources analysées (VBA décompilé `out/vba/*.vba`, libellés de formulaires `out/forms/*.txt`, schéma `legacy/schema.sql`) :
`Form_Devis`, `Form_DevisListe`, `Form_DevisListeTravaux`, `Form_DevisListeContratDeMaintenance`, `Form_Planification`, `Form_PlanificationEntretien`, `Form_Planification_sous formulaire`, `Form_00 - Statistiques Clients`, `Form_statistiques`, `Form_Filtre Extraction`, `Form_ListeKM`, `Form_ResultatListeKM`, `Form_Saisie_Vehicule`, `Form_Saisie_EV_Vehicule`, `Form_Vehicules`, `Form_ListeEVVehicules`, `Form_Liste_EVVehiculesSousForm`, les cinq sous-formulaires référentiels (`statut Fact`, `statut Interv`, `Type Interv`, `Sous_Type`, `Type_Audit`), plus en appui : `Calcul.vba` (EstFerie, GenererPlanningPrevisionnel), `Module1.vba`, `Parcourir.vba` (AfficheDossierWindows), `PDFCE.vba` (UpdateFichierBanane), `Form_MenuClimAccess` (Alerte_Voitures, boutons de menu), `Form_MenuPrincipal` (GenererSemaine, ouverture planification), `Form_Parametrage` (import KM, sous-formulaires référentiels), `Form_Site` (indicateur devis en cours, "Ne pas intervenir"), `Form_ListeInterventionGenerale` (usage de VisitesMaint).

Convention : « (Module.Procédure) » indique la source de chaque affirmation. Les points marqués **[incertain]** ne sont pas tranchés par le code lu.

---

## 1. Devis

### 1.1 Trois familles, trois tables identiques

| Famille | Table SQL Server | Formulaire liste | Bouton menu (Form_MenuClimAccess) | typint de l'intervention générée |
|---|---|---|---|---|
| Devis SAV / dépannage | `Devis` | `DevisListe` (Form_57) | `imgDevis_Click` | `3` (Devis accepté) |
| Devis Travaux | `DevisTravaux` | `DevisListeTravaux` (Form_67) | `imgDevisTravaux_Click` | `5` (En travaux) |
| Contrat de maintenance | `ContratDeMaintenance` | `DevisListeContratDeMaintenance` | `Img_DevisContratDeMaintenance_Click` | `3` (Devis accepté) |

Les trois tables ont strictement les mêmes 25 colonnes (schema.sql l.527, 579, 641) : `NumeroDevis` (identity, PK), `NumeroDevisInterne` nvarchar(50), `StatutDevis` tinyint DEFAULT 1, `NomFichierDevis` varchar(1000), `NomFichierDevisPartenaire`, `NumeroInterventionInterne`, `NumeroSite` (= Site.cptsit), `CommentaireClientDevis`, `NumeroClient`, `MontantFournitureDevis`, `MainOeuvreDevis`, `NbreDeplacementDevis` tinyint, `DateEnvoiDevis` date, `EnvoyePar`, `NumeroPartenaire`, `NumeroDevisPartenaire`, `MontantHTDevis`, `MontantHTDevisPartenaire`, `NumeroCommande`, `DateDevis`, `TypePanneDevis` nvarchar(100), `QteMaterielDevis`, `coutheuremainoeuvre`, `coutdeplacement`, `NumeroDevisRemplacement`.

Les trois formulaires liste sont des copies quasi identiques (commentaires « ATTENTION TOUTE MODIF ICI ENGENDRE AUSSI LA MEME DANS DEVIS LISTE TRAVAUX », « ATTENTION MEME PROCEDURE DANS DEVIS TRAVAUX »). La seule différence métier entre SAV et Travaux est le `typint` de l'intervention générée (3 vs 5). `DevisListeContratDeMaintenance` est une version plus ancienne (pas de `Controle_Devis`, pas de `nbrpagfax`/`mnthtdevpartenaire`, pas de date d'envoi automatique). Le menu passe `OpenArgs = "Entretien"` aux trois formulaires mais aucun ne l'exploite.

`Form_Devis` (Form_56) est un petit formulaire (N° devis, État, Nom fichier, Envoyé par, Envoyé le) lié à `Devis` ; son code se limite à extraire le numéro du nom de fichier. Il n'est ouvert par aucun module lu **[incertain : peut-être sous-formulaire d'un écran hors périmètre]**.

Écran liste : en-tête de filtres (Client, Site, État, Type de panne = `Panne.libpan`, Envoyé par = `Utilisateur` typuti=1 « Gestionnaire », « Entre le / et » sur `DateEnvoiDevis`) ; détail avec N° Devis, Nom Fichier Devis, État, Envoyé par, « Nb Machines concernées par l'intervention » (`QteMaterielDevis`), « Devis Partenaire » (`NomFichierDevisPartenaire`), Montant Fourniture, Qté Heure Main Oeuvre, Nbre Déplacement, Montant HT, coûts déplacement/heure, Type de panne, Envoyé le, Client, Site, `NumeroDevisRemplacement`, bouton « Vers Fichier », liste Intervention (`numint` non nul), bouton « Générer intervention suite à accord devis » (Form_57_Devis.txt, Form_67_DevisTravaux.txt).

### 1.2 Cycle de vie : StatutDevis

Le code source contient **quatre listes de libellés divergentes** pour `StatutDevis` :

| Code | Détail des listes SAV/Travaux (Form_57/67, contrôle `StatutDevis`) | Filtre CboEtat (Form_57/67) | Commentaire VBA `Détail_Paint` | Form_Devis (Form_56, obsolète) |
|---|---|---|---|---|
| 1 | Devis à viser | Devis à viser | Devis à viser | Devis à viser |
| 2 | Aucun Retour Client | Aucun Retour Client | Visé, à envoyer | Visé, à envoyer |
| 3 | Devis annulé et remplacé par | Devis annulé et remplacé par | Devis annulé et remplacé par | Envoyé |
| 4 | Envoyé | Envoyé | Envoyé | Devis accepté par le client |
| 5 | Devis refusé par le client | Devis refusé par le client | Devis refusé par le client | Devis refusé par le client |
| 6 | Devis accepté | Devis accepté par le client | Devis accepté par le client | — |

Interprétation retenue (cohérente avec le code) : **1 À viser → (2 Visé/aucun retour) → 4 Envoyé → 6 Accepté / 5 Refusé / 3 Annulé et remplacé**. Le statut 2 a glissé de « Visé, à envoyer » à « Aucun retour client » ; le module statistiques (Form_00.CmdRechercher) le traite comme « en attente » au même titre que 4 (`'Envoyé 4 Aucun Retour 2`).

Règles codées :
- Valeur par défaut 1 (schéma `DEFAULT 1`).
- Passage à **6** automatique lors de la génération de l'intervention (`cmdGenerer_Click`, les trois formulaires : `Me.StatutDevis = 6 'à mettre à accepté par le client`).
- Couleur de fond de ligne (`Détail_Paint`, trois formulaires) : 1 jaune (255,255,102), 5 gris (80,80,80), 3 bleu (119,181,254), 6 rouge (240,0,0) — le commentaire dit « (white) », c'est une erreur de commentaire —, autres blanc.
- « Devis en cours » côté Site (`Form_Site`, l.787-820) : un devis est considéré en cours si `StatutDevis IN (1,2,4)` dans l'une des trois tables → affichage des étiquettes « Devis en cours » / « Devis travaux en cours » / « Contrat en cours » et de l'image `ImgDevisEnCours`.
- Remplacement : champ libre `NumeroDevisRemplacement` (contrôle `txtNumeroDevisRemplacement`) associé au statut 3 « Devis annulé et remplacé par ». Aucune logique VBA (pas de lien automatique vers le nouveau devis, pas de copie).
- `StatutDevis_AfterUpdate` (DevisListe, DevisListeTravaux) déclenche `Controle_Devis` (voir 1.6). Absent dans ContratDeMaintenance.

### 1.3 Numérotation : NumeroDevisInterne

Le contrôle affiché « N° Devis » (nommé `NumeroDevis`) est lié au champ `NumeroDevisInterne` (Form_57 : `NumeroDevis` / `NumeroDevisInterne` / « N° Devis »). Le numéro **n'est pas généré par l'application** : il est **déduit du nom du fichier PDF** à la saisie de `NomFichierDevis` (`NomFichierDevis_AfterUpdate`) :

- DevisListe et DevisListeTravaux (modif 09/04/21 et 24/01/25) : on prend le nom court après le dernier `\` ; si le nom commence par `Devis n°` (anciens fichiers) on retire 9 caractères, sinon 6 ; puis on garde le texte jusqu'au premier `-` rencontré à partir de la position 5 (« pour éviter le premier - ») ; s'il n'y a pas de tiret, on garde 14 caractères. Format déduit : **un préfixe de 6 caractères (par ex. « Devis ») suivi d'un numéro contenant un tiret dans ses 4 premiers caractères, puis un tiret séparateur** (ex. plausible `AA-NNNN-Libellé.pdf` → `AA-NNNN`) **[incertain : format exact non visible dans le code]**.
- DevisListeContratDeMaintenance : `Mid(strFileName, 7, 10)` → 10 caractères à partir du 7e.
- Form_Devis : `Mid(strFileName, 11, 5)` → 5 caractères à partir du 11e (ancienne convention).

Le champ `NomFichierDevis` est ensuite réécrit `strFileName & strBaseFileName` (nom court + valeur saisie). Le reste de l'application (bouton « Vers Fichier », `Controle_Devis`, `cmdGenerer`) suppose le **format hyperlien Access `libellé#\\serveur\chemin\fichier.pdf#`** : on cherche `#` ou `#\\` pour séparer le libellé du chemin (`Parcourir.AfficheDossierWindows`, `Controle_Devis`, `cmdGenerer`). Le même format `chemin#chemin#` est écrit pour les fiches d'intervention (`Form_Intervention` l.1058). **[incertain : le contrôle est probablement de type Lien hypertexte ; la concaténation ci-dessus n'est cohérente que si la valeur saisie commence déjà par `#\\`.]**

`NumeroDevis` (identity) est la clé technique ; `NumeroDevisInterne` est le numéro métier visible.

### 1.4 Calcul des montants

`MajMontantHT` (identique dans les trois listes), appelé après modification de Montant Fourniture, Qté heures MO, Nbre déplacements, coût déplacement, coût heure :
1. Si `NumeroClient` renseigné et que `coutdeplacement` / `coutheuremainoeuvre` du devis sont vides, ils sont **pré-remplis depuis `Client.coutdeplacement` et `Client.coutheuremainoeuvre`** (tarifs client). Une fois copiés dans le devis, ils sont figés (historisation du tarif).
2. Si les cinq valeurs sont renseignées :
   **`MontantHTDevis = coutdeplacement × NbreDeplacementDevis + MontantFournitureDevis + MainOeuvreDevis × coutheuremainoeuvre`**
   (`MainOeuvreDevis` est une **quantité d'heures**, libellé « Qté Heure Main Oeuvre »). Le contrôle `MontantHTDevis` porte aussi cette formule en source de contrôle par défaut (Form_57).

Coûts horaires par site ou par intervenant : **non utilisés** dans le calcul du devis (seul le tarif client intervient). Marge partenaire : les champs `NumeroPartenaire`, `NumeroDevisPartenaire`, `NomFichierDevisPartenaire` (« Devis Partenaire »), `MontantHTDevisPartenaire` existent mais **aucune formule VBA** ne calcule de marge dans ces modules. Seul lien : à la génération, `Intervention.mnthtdevpartenaire` reçoit le `MontantHTDevis` du devis (commentaire 22/04/26 « Ajout du montant HT dans mnthtdevpartenaire »), ce qui est sémantiquement discutable (montant client rangé dans un champ « partenaire »).

Autres champs sans logique VBA : `CommentaireClientDevis`, `NumeroCommande`, `DateDevis`, `QteMaterielDevis` (« Nb Machines concernées »), `TypePanneDevis` (liste `Panne.libpan`, stocké en texte).

### 1.5 Fichiers PDF et envoi

- Stockage : chemin complet dans `NomFichierDevis` (varchar 1000), format hyperlien, fichiers sur partage réseau (`\\...`). Aucun répertoire de devis n'est codé dans ces modules ; le bouton « Vers Fichier » (`Commande68_Click` → `Parcourir.AfficheDossierWindows`) ouvre `explorer.exe /Select,<chemin>` sur le dossier du fichier.
- `DateEnvoiDevis` : posée automatiquement à la date du jour lors de la saisie du nom de fichier si elle est vide (`NomFichierDevis_BeforeUpdate`, DevisListe et DevisListeTravaux). **Désactivée (commentée)** dans Form_Devis et ContratDeMaintenance. Elle sert de date de référence pour les filtres et les statistiques devis.
- `EnvoyePar` : liste des utilisateurs `typuti = 1` (gestionnaires).
- Pas d'envoi de mail depuis ces modules.

### 1.6 Lien avec l'intervention

**Génération** (`cmdGenerer_Click`, bouton « Générer intervention suite à accord devis ») :
- Intervenant : `codint` de l'intervenant du site (`Site.numintervenant → Intervenant.codint`).
- `INSERT INTO intervention (cptsit, datheuapp, objint, staint, typint, codint, numdevacc, nbrpagfax, mnthtdevpartenaire)` avec : `datheuapp = Date` (date de demande), `objint` = libellé du fichier avant `#` tronqué à 500 et nettoyé (`"` `\` `'` → espace), `staint = 1` (À planifier), `typint = 3` (SAV/Contrat) ou `5` (Travaux), **`numdevacc = NumeroDevisInterne`** (n° de devis accepté), **`nbrpagfax = MainOeuvreDevis`** (commentaire 27/03/23 : « nbrpagfax qui est le nombre d'heures main d'œuvre » — champ « nb pages fax » détourné pour stocker les heures vendues), `mnthtdevpartenaire = MontantHTDevis`.
- Récupération du nouvel id par `select max(numintint) from intervention` (non transactionnel, risque de collision multi-utilisateurs).
- `StatutDevis = 6`, `Me.Requery`, `Controle_Devis`, puis ouverture du formulaire `Intervention` sur le nouvel enregistrement.
- Variante ContratDeMaintenance : si `NumeroInterventionInterne` est renseigné, la nouvelle intervention copie le `cptsit` de l'intervention d'origine mais **n'écrit pas `numdevacc`** ; sinon insertion classique avec `numdevacc`.

**Autres liens** : `NumeroInterventionInterne` (liste déroulante des interventions ayant un `numint`) relie le devis à l'intervention d'origine (dépannage ayant donné lieu au devis). `NomFichierDevis_AfterUpdate` appelle `PassThroughFixup` censé exécuter la procédure stockée SQL Server **`UpdateIntervention(NumeroInterventionInterne)`** via ADODB/DSN, mais **l'exécution est commentée** (`'Set rst = cmd.Execute()`) : la procédure n'est plus appelée ; son rôle reste inconnu **[incertain]**. La chaîne de connexion contient des identifiants en clair (non reproduits ici).

Côté Intervention (hors périmètre, pour contexte) : `numdevacc` est repris dans le nom du PDF de fiche pour les interventions `typint = 3` (`Form_Intervention` l.1016-1022), dans le nom de chantier `nomsit_numdevacc` (l.1542) et dans le message de planning envoyé aux techniciens (« N° Devis: »). La table `Intervention` porte aussi `numdev`, `stadev`, `mnthtdevis`, `devisafaire`, `devisfait`, `comdevis`, `comdevisinterne`, `devisepar` (non lus dans ce périmètre).

**`Controle_Devis(NumeroSite, NumeroClient)`** (DevisListe, DevisListeTravaux ; déclenché à chaque changement de statut et après génération) : recalcule `Site.Mess_Devis` = concaténation (`<br/>`) des libellés (partie avant `#`) de tous les devis **au statut 4 (Envoyé)** des tables `Devis` et `DevisTravaux` pour le site **et** le client (critère client ajouté le 26/04/24 car « il existe des devis avec numéro client et numéro site qui ne correspondent pas »). Ce texte HTML alimente l'affichage des devis en attente sur la fiche site / le mobile **[incertain sur le consommateur]**. Défaut : le test `Position = -1` ne se produit jamais (`InStr` renvoie 0) ; un nom sans `#` provoque `Left(x, -1)` → erreur.

### 1.7 Divers

- Bouton `BpInsert` : bascule `AllowAdditions` (« Rendre Insertion Devis Possible / Impossible ») et affiche les avertissements « Penser à Actualiser / après Insertion » ; l'ajout est re-verrouillé après chaque insertion (`Form_AfterInsert`).
- Filtre (`Filtrer`) : `NumeroClient`, `NumeroSite`, `StatutDevis`, `EnvoyePar`, `TypePanneDevis` (texte), `DateEnvoiDevis` entre deux dates (format `#date#` Access, sensible au paramétrage régional).

---

## 2. Planification des entretiens

### 2.1 Données

- `Site.nbrentsit` : nombre de visites d'entretien contractuelles par an (clé de tout l'algorithme). `Site.NombreContratChaudiere`, `Site.nombrevisitedesenfumage` : idem chaudière / désenfumage. `Site.NumSousTraitClim / NumSousTraitDesenfum / NumSousTraitChaudiere` : sous-traitants par lot ; `Site.numintervenant` : intervenant par défaut.
- `Site.majregistresecuritefait` : **colonne détournée = indicateur « Ne pas intervenir »** (`Form_Planification` : `'Cette donnée est ne pas intervenir` ; `Form_ListeSiteGenerale` l.102 : « La colonne majregistresecuritefait correspond a ne pas intervenir »). Valeur `"FAUX"` = on intervient.
- Table `Planification` (schema l.1007) : `numeroplanification`, `numcli`, `T1..T12` (date), `nombrevisite`, `recurrent` bit, `datefinrecurrence`. Une ligne par **client** (pas par site), 166 lignes. Les colonnes `recurrent` / `datefinrecurrence` **ne sont lues par aucun VBA** du périmètre **[incertain : usage abandonné ou via requêtes]**.
- Table locale `planning` (`numsit`, `Semaine 1..52`) : cache du planning prévisionnel hebdomadaire (voir 2.5).
- `parametre` (`numcli`, `datdeb`, `datfin`, `datfinpla`) : `datfinpla` = date de fin du planning prévisionnel, liée au champ « Jusqu'au » de `PlanificationEntretien`.
- `JoursFeries.datjoufer` ; `VisitesMaint` (`Nombre_Visites`, `Ecart_Permis_Jour`, `Commentaire`) ; `SiteNombreEntretien` (`cptsit`, `nbrentsit`, `datfin` — historique « Nombre Visite / Jusqu'au », sous-formulaire Form_22, aucun VBA).
- Résultat de toute planification : des lignes `Intervention` avec `typint='1'` (Entretien), `staint=1` (À planifier), et soit `datheulim` (date limite, mode « Planification par client »), soit `datintpre` (date prévue, mode « PlanificationEntretien »).

### 2.2 Formulaire `Planification` (par client, dates limites T1..T12)

Ouvert depuis la fiche Client (`Form_Client.cmdPlanIntervention_Click`, filtre `numcli`), Donneur et ListeClientAffiche. Lié à `Planification` (Form_70). Le sous-formulaire (Form_64, `Form_Planification_sous formulaire`) affiche `nombrevisite` et T1..T12 ; un double-clic sur le nombre de visites recopie la ligne dans le formulaire parent et affiche `n` champs « Date Limite n » (`TxtNombreVisite_DblClick`, `Affichage`).

Trois blocs de génération, tous sur `SELECT * FROM SITE WHERE numcli = <client>` :

**Entretien clim — `cmdGenerer_Click` « Générer Interventions »** : pour chaque site du client ayant **`nbrentsit = TxtNombreVisite`** (« Nombre de visites à planifier »), et pour i = 1..n :
- `cptsit`, `datheulim = Ti`, `Refcliint = DIENTi` (référence de demande d'intervention client saisie en face de chaque date — test fait sur `DIENT1` pour toutes les lignes, bug mineur), `typint='1'`, `datheuapp = Null`.
- `staint = 1`, **ou 17 si `majregistresecuritefait <> "FAUX"`** (site « Ne pas intervenir », ajout 26/04/24).
- `codint` : sous-traitant clim (`NumSousTraitClim`) sinon intervenant du site sinon **`"FMC"`**.
- **Anti-doublon** : on n'insère pas s'il existe déjà une intervention `typint='1'` pour le même site et la même `datheulim`.
- La suppression préalable des entretiens non réalisés est **commentée**.
- MsgBox : « La génération de N visites d'entretien s'est bien éffectuée. »

**Chaudière — `Commande125_Click`** : sites avec `NombreContratChaudiere = NbChaud` ; dates `ChaudT1..12`, réf. `DICHAUDi` ; **`typint='13'` (Entretien Chaudière, depuis le 19/08/25 ; avant c'était 1)** ; `codint = NumSousTraitChaudiere`, sinon **MsgBox « Attention pas d'intervenant chaudiere pour <site> »** puis repli intervenant du site / FMC. **Pas d'anti-doublon** (étiquette écran : « Attention pour chaudiere et Desenfumage pas de Test de date si l'inter existe deja !! »). MsgBox « La génération de N visites de chaudiere s'est bien éffectuée. »

**Désenfumage — `Commande167_Click`** : sites avec `nombrevisitedesenfumage = NbDesen` ; dates `DesenT1..12`, réf. `DIDESENi` ; **`typint='1'`** (et non 7 « Désenfumage » — probable oubli) ; `codint = NumSousTraitDesenfum` sinon MsgBox « Attention pas d'intervenant Desenfumage pour <site> ». Pas d'anti-doublon. MsgBox « ... visites de desenfumage ... ».

Étiquette écran : « Faire ABSOLUMENT en priorité les entretiens ».

### 2.3 Formulaire `PlanificationEntretien` (dates prévues calculées)

Ouvert depuis `MenuPrincipal` (« Planifier les entretiens », `CmdPlanifier_Click` / `CmdOuvrirPlanificationEntretien_Click`). Source : `parametre.datfinpla` (« Jusqu'au »). Contrôles : `lstClient` (clients `affcli=1`), `txtDatFin`/`datfinpla`, `DateDebut` (« A partir du », défaut `Date()`), `compteur` (barre de progression textuelle).

Point commun aux trois générateurs : **suppression des entretiens non réalisés** du site avant régénération : `DELETE FROM intervention WHERE datintpre IS NOT NULL AND datint IS NULL AND cptsit=… AND typint='1'`.

**A. `cmdGenerer_Click` « Générer les interventions d'entretien » (algorithme générique, pas mensuel)**
- Périmètre : client choisi, sinon **tous les clients sauf 1, 2, 49, 77, 70, 40** (clients à algorithme spécifique).
- Contrôles : « Merci de saisir une date de fin pour pouvoir générer le planning prévisionnel. » ; « Merci de saisir le nombre de visite d'entretien pour pouvoir générer le planning prévisionnel. »
- Date de départ = `max(datint)` des entretiens réalisés du site ; sinon **15/12 de l'année précédente**.
- Intervenant : `Intervenant.codint` via `Site.numintervenant`, avec jointure `ZoneGeographique` ; **site ignoré si aucun intervenant**.
- **Pas = `Int(12 / nbrentsit)` mois**. Première date = départ + pas ; puis boucle tant que date ≤ `datfinpla` : ajustement férié (−1 jour), samedi (−1), dimanche (+1) ; insertion `datintpre`, `typint='1'`, `staint=1`, `codint`, `datheuapp=Null` ; date suivante = date + pas mois.
- Un comptage des visites déjà réalisées (`staint=9`) entre départ et fin est calculé mais **non utilisé**.

**B. `BtGenerer_Click` « Générer les interventions d'entretien ARMAND THIERY et TOSCAN » (clients 1, 2, 49, 40, 77, calendrier fixe)**
- Compte les entretiens réalisés dans l'année (`Mid(datint,7,4) = Year(Date())` — comparaison sur chaîne) ; si le compte = `nbrentsit`, site terminé.
- Génère des visites au **15 de mois fixes** selon `nbrentsit` (6, 7, 8 ou 12) et le nombre déjà réalisé, uniquement pour les mois ≥ mois de `DateDebut` : par ex. 12 visites → 15/01…15/12 ; 8 visites → 15/01, 15/03 (ou milieu recalculé), 15/05, 15/06, 15/07, 15/08, 15/10, 15/12 ; 6-7 visites → 15/02, 15/04, 15/06, 15/07, 15/08, 15/11 (6) ou 15/10 + 15/12 (7).
- Règle d'**écart** : si une seule visite est déjà faite, la 2e est placée à mi-chemin : `VnbJour = Int(135 − (135 − jours écoulés au 1/1)/2)` pour 8 visites, 165 pour 6-7 visites, 350 pour l'avant-dernière (7e/8 ou 6e/7).
- Jour ouvrable via `calcul_jour_ouvrable` (férié −1, samedi −1, dimanche +1) sur la globale `GDatPreInt` (`Module1`).
- Intervenant : `Intervenant.numzonint = Site.numzonsit` (par zone géographique, pas par site).

**C. `Commande16_Click` « Générer les interventions d'entretien TOSCAN » (client 70)** : dates **codées en dur pour 2008** (#2/15/2008#, …) → obsolète, à ne pas migrer.

**D. `Commande19_Click` (bouton sans libellé, avec compteur ; algorithme « alain », modif 15/03/2010)**
- Même périmètre client qu'en A. Sites `nbrentsit = 0` ignorés.
- Visites déjà faites = `count(*)` typint 1 **`staint=4`** (En cours) entre le 01/01 et le 31/12 de l'année — incohérent avec A qui utilise `staint=9` **[incertain : lequel est correct]**.
- Reste à planifier = `nbrentsit − déjà faites`.
- **Nouveau site** (aucun entretien) : départ = `DateDebut`, pas = `Round(365 / nbrentsit)` jours, 1re visite = départ + pas/2.
- **Site existant** : pas = `Round(jours(dernier entretien → 31/12) / (reste + 0,5))`, 1re visite = dernier entretien + pas ; si l'année obtenue est l'année précédente, +1 mois.
- Férié : **+1 jour si lundi, sinon −1** ; samedi −1 ; dimanche +1.
- **`codint` forcé à "FMC"** (l'intervenant du site est ignoré).
- Barre de progression : un « l » ajouté tous les `Round(nbSites/150)` sites.

Tous affichent en fin « La génération des visites d'entretien s'est bien éffectuée. » Erreur DAO 3151 (connexion ODBC) ignorée par `Resume`.

### 2.4 Jours fériés

`Calcul.EstFerie(date)` : parcourt toute la table `JoursFeries` et compare `Format(dd/mm/yyyy)`. Administration via le formulaire `JoursFeries` (bouton « Jours fériés » du MenuPrincipal). Utilisé par les planifications et par `CalculerHeureLimite` (délai de dépannage, hors périmètre).

### 2.5 Table `planning` (Semaine 1..52) et `GenererSemaine`

- `Calcul.GenererPlanningPrevisionnel` : vide `planning`, la remplit depuis la requête **`SiteEntretienPrevuDemixage_datintpre`** (une colonne par semaine = entretiens prévus), puis concatène les valeurs de **`SiteEntretienPrevuDemixage_datint`** (réalisés) dont l'année = année de `parametre.datfin`. Ces requêtes (analyse croisée) ne sont pas extractibles **[incertain sur leur SQL]**.
- Appelée par `MenuPrincipal.CmdT1..CmdT4_Click` avant l'ouverture des états `SiteEntretienPrevu-T1..T4` (planning prévisionnel par trimestre, filtrable par intervenant `Intervenant like 'X*'`). Boutons connexes : « Planning prévisionnel général entretien T1..T4 », « Planning entretien T1..T4 », « Planning prévisionnel entretien Année ».
- `MenuPrincipal.GenererSemaine` : simple utilitaire développeur qui imprime dans la fenêtre Exécution la liste `"Semaine 1";"Semaine 2";…` (pour construire une liste de valeurs). Aucun rôle métier.
- Numéro de semaine : règle « la semaine 1 est celle du 4 janvier » (commentaire `Form_Intervention` l.1503, 24/01/2025).

### 2.6 Écart entre visites : `VisitesMaint`

Table de paramétrage (`Nombre_Visites`, `Ecart_Permis_Jour`, `Commentaire`), éditable dans `Parametrage` (sous-formulaire `dbo_VisitesMaint`, Form_113 : « Nombre Visites / Ecart Permis (Jour) / Commentaire »). Usage (`Form_ListeInterventionGenerale.Filtre_OM_Test`, case « entretien proche », 27/11/25) : charge un tableau `écart[nbVisites]` puis filtre les entretiens **à planifier** (`typint='1'`, `staint=1`) dont **`datedernierevisiteentretien + Ecart_Permis_Jour > datheulim`**, c'est-à-dire les entretiens dont la date limite tombe trop tôt après la dernière visite réalisée pour ce nombre de visites annuel. C'est un **contrôle a posteriori**, pas une contrainte à la génération.

### 2.7 Autres règles liées

- « Ne pas intervenir » : `Form_Site` bascule toutes les interventions du site de `staint IN (-1,1,9)` vers **17** et inversement (`Type_Inter = 17`). `Form_ListeSiteGenerale` liste les sites ayant une intervention `staint=17`.
- Clôture d'un entretien (`Form_Intervention.CmdCloturerIntervention_Click`, hors périmètre) : passe `staint=9` et « ajoute 3 ou 6 mois à la prochaine visite ».
- Génération des interventions d'entretien par les requêtes nommées `CréerEntretien` / `Entretiens par trimestre` (ANALYSIS.md) : **aucun appel VBA trouvé** dans les modules lus **[incertain : requêtes action manuelles ou obsolètes]**.

---

## 3. Statistiques clients (`Form_00 - Statistiques Clients`, 1566 lignes)

Ouvert depuis `MenuClimAccess.Image8_Click`. Écran (Form_72) : Client (`affcli=1`), « Entre le / et » (`Date_Deb`, `Date_Fin`), « Année » (« La saisie de l'année est prioritaire sur la periode de Temps »), « Mois » (0 Tous, 1..12 ; activé seulement si Année numérique — `Annee_LostFocus`), listes multi-sélection « Type Intervention » (valeurs 1 Entretien, 2 Dépannage, 3 Devis accepté, 7 Désenfumage, 9 Audit, 4 Autre, 8 Inter. réalisée en attente devis signé client, 5 En travaux, 6 En création), « Statut » (`StatusInterv` avec `OrdreAffichage > 0`), « Nature » (`SousType`), « Recherche Par Nom » + 4 textes (défauts : CREMATORIUM, POINT DE VENTE, CHAMBRE FUNÉRAIRE, DÉPÔT), trois cases « Degrouper les natures / Interventions / Statuts » (mutuellement exclusives : `Check_Degroup_*_AfterUpdate`). Deux boutons d'export : **« Export Excel 'Fabien' »** (`CmdRechercher_Click`) et **« Export Excel 'Pierre' »** (`Commande11_Click` → `Calcul_Nom` si « Recherche Par Nom » coché, sinon `Calcul_Eclate`). `Calcul_Total` existe mais **n'est appelé nulle part** (code mort). `Form_statistiques` : module vide (les Top/Flop Ten du MenuPrincipal `CmdTopTen` / `Commande248` reposent sur les requêtes `RequeteTopTen` / `RequeteFlopTen` et la table `TopTen` (`nomsittop`, `indvettop` indice de vétusté, `Nbintphy`, `nbintdef`, `numsittop`) — SQL non disponible **[incertain]**).

Mécanique commune : sélection d'un dossier de destination (`FileDialog` « Merci de Selectionner le repertoire pour le fichier de statistiques »), ouverture d'Excel (`GetObject` puis `CreateObject` systématique depuis le 29/06/23 « sur Windows 11 objXL n'est pas à Nothing »), ouverture d'un **modèle réseau**, remplissage cellule par cellule, `SaveAs` dans le dossier choisi. **Aucune donnée `parametre.datdeb/datfin` n'est utilisée** : le formulaire a ses propres bornes.

### 3.1 Export « Fabien » (`CmdRechercher_Click`) — bilan économique par site

Modèle : `\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Stat.xlsx`, feuille 1, données à partir de la ligne 4 ; en-tête B1 = nom client, D1 = date début, K1 = date fin.
Période : interventions filtrées sur **`datint`** (date réalisée) ; devis filtrés sur **`DateEnvoiDevis`** (format `yyyy-mm-dd`). Sans dates → tout l'historique.
Tarifs : `Client.coutheuremainoeuvre` (CoutHeure) et `Client.coutdeplacement` (CoutDepl), déclarés `Integer` (troncature des centimes).
Une ligne par site du client **ayant au moins une donnée** (`Ligne_en_plus`). Colonnes :

| Col | Contenu | Formule / source |
|---|---|---|
| 1 | Site | `nomsit` |
| 2 | Mise en service | `datemiseenservicesite` |
| 3 | Coût heure client | `Client.coutheuremainoeuvre` |
| 4 | Coût déplacement client | `Client.coutdeplacement` |
| 5 | Nb entretiens contractuels | `Site.nbrentsit` |
| 6 | Redevance technique | `Site.mntredev` (0 si nul) |
| 7 | Nb devis acceptés réalisés | count interventions `typint='3'`, `staint ∉ {8,10}` |
| 8 | Heures devis acceptés | Σ `DateDiff("n", heuarrint, heudepint) × NbTech` / 60 ; NbTech = count `InterventionTechnicien` (min 1) ; minutes négatives prises en valeur absolue (« au cas où la saisie est inversée ») ; si l'année de départ ≠ arrivée, la date d'arrivée est forcée au jour de départ |
| 9 | Sous-traitance devis acceptés | Σ `mntst` (typint 3) |
| 10 | Montant devis acceptés | Σ `mntfmc` (typint 3) |
| 11 | Devis acceptés annulés | count typint 3 avec `staint=8` |
| 12 | Nb entretiens réalisés | count `typint='1'` et `staint<>8` (datint dans la période) |
| 13 | Valeur entretiens | col 12 × redevance technique |
| 14 | Nb dépannages | count `typint='2'`, `staint ∉ {8,10}` |
| 15 | Heures dépannage | même formule que col 8 sur typint 2 |
| 16 | Sous-traitance dépannage | Σ `mntst` (typint 2) |
| 17 | Coût dépannage théorique | `NbDepan × CoutDepl + CoutHeure × heures dépannage` |
| 18 | Montant FMC dépannage | Σ `mntfmc` (typint 2) |
| 19 | Dépannages résolus par téléphone | count typint 2, `staint=10` |
| 20 | Dépannages annulés | count typint 2, `staint=8` |
| 21-22 | Devis SAV en attente : nombre, montant HT | `Devis.StatutDevis IN (4,2)` |
| 23-24 | Devis SAV refusés : nombre, montant HT | `StatutDevis = 5` |
| 25-28 | Idem pour `DevisTravaux` | |

Nom du fichier : `<nom client nettoyé>_DU_<jj_mm_aaaa>_AU_<jj_mm_aaaa>.xlsx`, ou `DEPUIS_…` / `JUSQU_A_…` si une seule borne.
Défauts constatés : `NbDevisSAVRefus = NbDevisRefus + 1` (variable jamais incrémentée → le compteur de refus vaut toujours 1) ; si `Date_Fin` est vide c'est `debut` qui est remis à vide (inversion) ; les libellés de progression (« Statistiques … Site i/N », « Traitement Devis SAV », « Traitement Depannage et Devis acceptés ») sont affichés dans `Label_Export_Fabien` / `Label_Stats_Fabien_2`.

### 3.2 Export « Pierre » sans nom (`Calcul_Eclate`) — comptage / montant par site

Modèle : `Fichier_Stat_OGF.xlsx` (feuille 1) ou **`Fichier_Stat_OGF_Par_Mois.xlsx`** (12 feuilles, une par mois) si Année + Mois renseignés ; Mois = 0 « Tous » → boucle `Suite_Mois` sur les 12 feuilles.
Période : filtre sur **`datheulim`** (date limite d'intervention, pas la date réalisée) : `Année` → 01/01..31/12 ; sinon `Date_Deb`/`Date_Fin` ; avec Mois → `month(datheulim)=m and Year(datheulim)=a`.
Filtres : `typint IN (…)`, `staint IN (…)`, **`Imprimeepar IN (…)`** — la colonne `Intervention.Imprimeepar` (« imprimée par ») est **détournée pour stocker le sous-type / nature** (`SousType.id`). Textes des filtres écrits en A2 (types), A3 (statuts), A4 (natures).
Indicateur unique par site : **`Count(numintint)` et `Sum(mntfmc)`**.
En-tête : B1 client ; D1 « Année aaaa » / « <Mois> aaaa » / « Du jj/mm/aaaa Au jj/mm/aaaa ». Données à partir de la ligne 8 : A = site, puis sans dégroupage B = quantité, C = montant ; **avec dégroupage** (une seule dimension possible : statut, type ou nature), une paire de colonnes (Qté, Montant) par valeur sélectionnée, en-têtes de colonnes en ligne 6.
Fichier : `<nom client>.xlsx` (écrasé à chaque export, sans période dans le nom).

### 3.3 Export « Pierre » par nom (`Calcul_Nom`)

Même moteur, mais les lignes ne sont plus les sites : pour chacun des 4 textes saisis (i = 1..4), on prend les sites du client dont **`nomsit LIKE '%texte%'`** et on **somme** quantités et montants sur tous ces sites (tableaux `NbInter`, `TotalInter`) ; la ligne porte le texte recherché. Étiquette écran : « La recherche par nom est effectuée sur tous les sites du client et donne une somme pour tous les sites correspondants (Sert pour OGF, Crematorium, Point de vente, etc) ». Sort si les 4 textes sont vides. Défaut : pour le dégroupage par type ou nature, les en-têtes de colonnes sont pris dans `ListeStatut` au lieu de la bonne liste (copier-coller).

### 3.4 Codes statut interprétés par le module

`staint = 8` « Annulé par le client », `staint = 10` « résolu par téléphone » (dépannage sans déplacement), `typint 2` dépannage, `typint 3` devis accepté, `typint 1` entretien.

---

## 4. Extractions

### 4.1 `Filtre Extraction` (Form_105) — export du parc matériel

Ouvert depuis `MenuClimAccess.Image107_Click` (étiquette « Filtre Extraction »). Écran réel : Client, bouton **« Export Excel Materiel »** (`CmdRechercher_Click`), label de progression, bouton **« Stop Export »** (`Commande40_Click` → `Stop_Export = True`, testé à chaque ligne). Le module contient aussi une copie de `Calcul_Eclate` / `Calcul_Nom` (`Commande11_Click`) mais **le formulaire n'a pas ces contrôles** : code mort hérité des statistiques.

Traitement : `UpdateFichierBanane 1` (suspend le « heartbeat », voir §9) ; requête `Client LEFT JOIN Site LEFT JOIN SiteMateriel` renvoyant **65 colonnes** : nomcli, numsit, codsit, nomsit, adrsit, codpossit, vilsit, puis SiteMateriel : RepereSurSite, repere, Emplacement, Quantite, Marque, Type, Reference, NumeroSerie, Reversible, ResistanceElectrique, PuissanceFrigo, PuissanceCalo, FluideQuantite, DateMiseEnService, TypeTelecommande, NbreTelecommande, EmplacementTelecommande, Disjoncteurs, DisjoncteurPrincipal, DisjoncteurArmoirePrincipale, DisjoncteurCoffretIndependant, AccessibiliteGroupe, AccessibiliteCassettes, SupportGroupes, EtatSupports, NbreFiltreRoofTop, ReferenceFiltreRoofTop, NbreCourroiesRoofTop, ReferenceCourroiesRoofTop, AppointChauffageSurRoof, NbreAerotherme, AerothermeGazElec, RideauAir, NbreRideauType, PuissanceRideau, TypeDisjoncteurRideau, SasEntree, ClimLocauxSociaux* (7 colonnes), Radiateurs, NbreRadiateurs, LocalisationRadiateurs, DisjoncteurRadiateursTypeIntensite, VMC, LocalisationVMC, Photos, RapportsMaintenance, DevisEnCours, DevisValide, ControleEtancheite, Observations. Copie brute dans le modèle `Fichier_Extraction_Materiel.xlsx` (même dossier réseau) à partir de la ligne 2, une ligne par matériel (sites sans matériel inclus via LEFT JOIN). Sauvegarde `<dossier>\Materiel_<nomcli>.xlsx`. `UpdateFichierBanane 2` en fin.

### 4.2 `ListeKM` / `ResultatListeKM` (Form_96) — relevés kilométriques des techniciens

- Liste « Techniciens » = utilisateurs ayant des lignes **`HeuresTech.TypeInterv = 60`** ; bornes « Entre le / et » sur `HeuresTech.DateInterv` (format texte `'date'`, SQL Server).
- Résultat (`Form_ResultatListeKM`, sous-formulaire) : `DateInterv`, `Nom` (nomuti + preuti), `nominterv`. **`TypeInterv = 60` = relevé kilométrique** saisi par le technicien (probablement depuis l'application mobile **[incertain]**) ; `NomInterv` a le format `…:<IMMAT>=<KM>` (déduit de `Form_Parametrage.Commande173_Click`, qui parse `:` puis `=` pour migrer ces lignes en `EvVehicules` avec **`TypeEV = 0`**, conducteur = `NumeroTech`).
- Les handlers double-clic de `ResultatListeKM` (`nomcli`, `nomsit`, `objint`, `vilsit`, `codpossit`) référencent des champs absents de la source (`numintint`, `numcli`) : reliquat d'un copier-coller de `ListeInterventionGenerale`, non fonctionnel.
- Pas d'export Excel pour les KM.

### 4.3 Table `HeuresTech` (pointage)

Colonnes : `NumeroTech` (→ Utilisateur), `TypeInterv`, `NumInterv` (→ Intervention.numint), `NomInterv` (texte libre / message planning), `DateInterv`, `HeureDebut`, `HeureFin`, `HeureDebut_FMC`, `HeureFin_FMC`, `InterdictionModif`, `NumeroSite`, `DateSaisie`, `NePasComptabiliser`. `HeuresTechAuto` = copie alimentée par `Form_Intervention` (planning envoyé aux techniciens, `NomInterv` = message HTML « N° DI / N° Devis / Commentaire / Num Inter »). Hors du périmètre, cité pour le lien KM. `Utilisateur.KmARenseigner` (bit) et `Utilisateur.Immat` relient un utilisateur à un véhicule pour la saisie des km **[incertain : usage côté mobile]**.

---

## 5. Parc automobile

### 5.1 Données

- `Vehicules` (schema l.1552) : `NumVehicule` (PK), `Immatriculation` nchar(10), `EtatVehicule` smallint (→ `ListeEtatVehicule`), `Dernier_KM`, `DateMiseCirculation`, `KM_a_l_achat`, `Km_Inter_Revision`, `Temps_Mois_Inter_Revision`, `Garantie` bit + `Nb_KM_Garantie` + `Temps_Mois_Garantie`, `Leasing` bit + `Nb_Km_Leasing` + `Temps_Mois_Leasing` + `Date_Fin_Leasing`, `Conducteur` (→ Utilisateur.numuti), `NumTelepeage`, `CodeCarteEssence`, `NumCarteEssence`, `Marque`, `Modele`, `Societe` (0 FMC CLIM / 1 FMC MAINT — liste de valeurs Form_99), `CritAir` bit, `Champ_Libre` (« Déposer ici le raccourci vers le dossier du pc »).
- `EvVehicules` : `NumEV`, `DateEv`, `Km`, `Conducteur`, `Immat`, `TypeEv` (→ `ListeEVVehicule.Numero`, libellé `Evenement_Vehicule`).
- Conducteurs éligibles : `Utilisateur` avec `typuti = 2` (techniciens), `numsoc IN (1,111,112,113)`, `codintuti <> ''` (Form_98/99/102/103).

### 5.2 Écrans

- `Vehicules` (Form_98, liste `SELECT * from dbo_vehicules`) : double-clic sur le conducteur → `Saisie_Vehicule` avec `OpenArgs "NumVehicule = n"`. Accessible via `Parametrage` (sous-formulaire `Vehicules`).
- `Saisie_Vehicule` (Form_99 « Modification Véhicule ») : charge le véhicule (`Form_Load`) ; gère les dates SQL au format ISO `yyyy-mm-dd` ou FR selon le poste (`MiseFormeDateLecture`, commentaire 29/03/24) ; calcule à partir de `EvVehicules` : **TypeEv 2 = Révision** (km max → « KM Dernier Entretien », « Date Dernier Entretien »), **3 = Contrôle technique** (« Date Dernier Controle Technique »), **4 = Contrôle complémentaire** (« Date Dernier Controle Complem. »), **1 ou 5 = Relevé km** (« Releve Km », « Date Dernier Releve Km ») — étiquettes écran « Revision(2) », « Controle Tech.(3)/Controle Compl.(4)/Km(1/5) ». Sauvegarde (`Bp_Ajout_Click` → `Verif_Data` puis `FaireModif`) : un `UPDATE dbo_Vehicules SET <champ>` **par champ modifié** (drapeaux `Modif_*` posés par les événements `_Change`/`_Click`), dates réécrites en `jj/mm/aa` via `MiseFormeDateEcriture`. `Verif_Data` contrôle le caractère numérique de KM à l'achat, Km dernier entretien, Km entre révisions, Temps garantie, Temps révision, Temps leasing, Km garantie, Km leasing (MsgBox « Veuillez verifier Votre Saisie pour <champ> »). « Quitter (SANS SAUVEGARDE) ». `Modif_Marque/Modele/Societe/Critair/Chemin` ne sont pas réinitialisés par `InitMemo` (mineur).
- `Saisie_EV_Vehicule` (Form_103 « Ajout Evenement Vehicule ») : date par défaut = aujourd'hui au format `jjmmaa` ; saisie du conducteur → immatriculation auto (`Conducteur_Change`) et inversement (`Immat_Change`) ; liste des immatriculations **hors état 4**. `Verif_Data` : type d'événement, conducteur, immatriculation, date et km obligatoires (MsgBox « Merci de renseigner un type d'evenement / un conducteur / une Immatriculation / une Date / un kilometrage ») ; **pour TypeEv 1 ou 5, le km doit être ≥ au km max déjà saisi pour l'immatriculation** : « Le dernier kilometrage saisi pour <immat> est <n>, Merci de changer votre saisie » (26/04/24 : contrôle limité aux relevés km). Insertion `INSERT INTO dbo_EvVehicules (DateEV, KM, Conducteur, Immat, TypeEv)`. Ouvert depuis `ListeEVVehicules` (« Ajout Evenement ») et `ListeTables`.
- `ListeEVVehicules` (Form_102) : filtres Immat, Conducteur, Evenement (`TypeEv`), « Entre le / et » sur `DateEv`, case **« Afficher Les Vendus »** (`EtatVehicule = 4` sinon `<> 4`) ; sous-formulaire `Liste_EVVehiculesSousForm` (colonnes DateEv, Immat, type, Km, Conducteur ; double-clic Immat → `Saisie_Vehicule`), tri `DateEv desc`. Bouton **« Afficher Erreur »** (`Commande59_Click`) → `Alerte_Voitures(True)` puis MsgBox « Résultat des recherches de problémes » (ou « Tout est OK :)!! »).
- `Parametrage` : sous-formulaires `Type_EV_Vehicule_Sous_Form` (référentiel `ListeEVVehicule`), `Type_Etat_Vehicule_Sous_Form` (`ListeEtatVehicule`), `Vehicules` ; bouton `Commande173` de migration des KM `HeuresTech(TypeInterv=60)` → `EvVehicules(TypeEV=0)` (usage ponctuel).

### 5.3 Alertes véhicules (`Form_MenuClimAccess.Alerte_Voitures`)

Exécutée au chargement du menu (compteurs `lblNotificationCT/CC/Leasing/Garantie/Revision`, étiquettes « Probleme de Controle Technique / Controle Complementaire / Leasing / Garantie / Revision ») et à la demande. Périmètre : véhicules **`EtatVehicule NOT IN (4, 5)`**. Pour chaque véhicule, à partir des événements :
- **Contrôle technique** : alerte si `DateDiff("m", dernier CT, maintenant) > 24`.
- **Contrôle complémentaire** : alerte si > 12 mois depuis le plus récent de (dernier CC, dernier CT) (modif 03/09/24).
- **Révision** : alerte si `km relevé max − km dernière révision > Km_Inter_Revision`, sinon si `|mois entre dernier relevé km et dernière révision| > Temps_Mois_Inter_Revision`.
- **Leasing** (si `Leasing`) : alerte si `Date_Fin_Leasing` dépassée ; sinon si mois depuis `DateMiseCirculation` > `Temps_Mois_Leasing`.
- **Garantie** (si `Garantie`) : alerte si mois depuis `DateMiseCirculation` > `Temps_Mois_Garantie`.
Messages : « Voiture(s) avec probleme de controle technique: <immats> », etc.

---

## 6. Référentiels administrables (sous-formulaires sans code)

Les cinq modules du périmètre (`statut Fact Sous Form`, `statut Interv Sous Form`, `Type Interv Sous Form`, `Sous_Type_Sous_Form`, `Type_Audit_Sous_Form`) sont **vides** : ce sont des feuilles de données liées, affichées/masquées par `Form_Parametrage` (`MasquerTout` puis positionnement). Contenu d'après les libellés :

| Sous-formulaire | Table | Champs édités | Remarques |
|---|---|---|---|
| Statut Interv (Form_95) | `StatusInterv` | `StatutInter` (« Type »), `OrdreAffichage`, `IndexLigne` « Numero Interne (Ne pas toucher) » | `OrdreAffichage > 0` = visible dans les listes |
| Type Interv (Form_109) | `TypeInterv` | `TypeInter`, `OrdreAffichage`, `IndexLigne`, `IndexLigneSTRING` « COPIE Numero Interne » | `Intervention.typint` est nvarchar → copie texte de la clé |
| Statut Fact (Form_94) | `StatutFacture` | `Statut`, `OrdreAffichage`, `QueKadi` « Visible Que par Kadi » | `Calcul.Verification_Droit_Modif` : un statut `QueKadi` n'est modifiable que par l'utilisateur « Kadi » (`Kadi_Logge`) |
| Sous type / Nature (Form_82) | `SousType` | `SousType` | stocké dans `Intervention.Imprimeepar` |
| Type Audit (Form_79) | `TypeAudit` | `Type` | |
| Evenement véhicule (Form_100) | `ListeEVVehicule` | `Evenement_Vehicule` | |
| Etat véhicule (Form_101) | `ListeEtatVehicule` | `EtatVehicule` | |
| Visites maintenance (Form_113) | `VisitesMaint` | `Nombre_Visites`, `Ecart_Permis_Jour`, `Commentaire` | |
| Jours fériés (Form_17) | `JoursFeries` | `datjoufer` | formulaire autonome |

---

## 7. Règles métier découvertes et messages utilisateur

Règles :
1. Un devis n'a pas de numéro généré : le numéro interne est extrait du nom du PDF ; la date d'envoi est posée au moment où le fichier est rattaché (SAV/Travaux).
2. Le prix d'un devis = fournitures + heures × tarif horaire client + déplacements × forfait déplacement client, tarifs copiés du client puis figés dans le devis.
3. Accepter un devis = cliquer « Générer intervention » : crée une intervention À planifier de type Devis accepté (SAV/Contrat) ou En travaux (Travaux), portant le n° de devis (`numdevacc`), les heures vendues (`nbrpagfax`) et le montant HT (`mnthtdevpartenaire`) ; le devis passe à 6.
4. Les devis Envoyés (4) d'un site sont recopiés en HTML dans `Site.Mess_Devis` ; les devis 1/2/4 allument l'indicateur « devis en cours » du site.
5. Planification par client : une date limite (`datheulim`) et une référence DI client par visite ; anti-doublon uniquement pour la clim ; chaudière → `typint 13`, désenfumage → `typint 1`.
6. Planification calculée : pas de `Int(12/nbrentsit)` mois à partir du dernier entretien réalisé (ou du 15/12 N-1), jusqu'à `parametre.datfinpla`, avec suppression préalable des visites prévues non faites ; jours fériés/week-ends décalés ; certains clients (1, 2, 40, 49, 77) suivent un calendrier fixe au 15 du mois ; l'algorithme « alain » force l'intervenant FMC.
7. Site « Ne pas intervenir » = `majregistresecuritefait <> "FAUX"` → interventions créées directement en statut 17.
8. Écart minimal entre deux entretiens paramétré par `VisitesMaint` selon le nombre de visites annuel (contrôle de liste, pas de blocage).
9. Statistiques : un dépannage résolu par téléphone (10) ou annulé (8) n'est ni compté ni valorisé ; les heures sont multipliées par le nombre de techniciens ; le coût théorique du dépannage = déplacements × forfait + heures × tarif client.
10. Véhicule : un relevé km ne peut pas être inférieur au dernier relevé ; CT tous les 24 mois, contrôle complémentaire 12 mois après le dernier CT/CC ; révision par km ou par mois ; alertes leasing/garantie sur la date de mise en circulation.
11. Les véhicules d'état 4 (« vendus », d'après la case « Afficher Les Vendus ») et 5 sont exclus des alertes et des saisies d'événements (4 uniquement).

Messages (MsgBox) :
- « La génération de N visites d'entretien / de chaudiere / de desenfumage s'est bien éffectuée. » (Form_Planification)
- « Attention pas d'intervenant chaudiere pour <site> » / « Attention pas d'intervenant Desenfumage pour <site> » (Form_Planification)
- « Merci de saisir une date de fin pour pouvoir générer le planning prévisionnel. » ; « Merci de saisir le nombre de visite d'entretien pour pouvoir générer le planning prévisionnel. » ; « La génération des visites d'entretien s'est bien éffectuée. » (Form_PlanificationEntretien)
- « Merci de Selectionner le repertoire pour le fichier de statistiques / d'export » (FileDialog)
- « Veuillez verifier Votre Saisie pour <champ> » ; « Merci de renseigner un type d'evenement / un conducteur / une Immatriculation / une Date / un kilometrage » ; « Le dernier kilometrage saisi pour <immat> est <n>, Merci de changer votre saisie » (titre « Erreur Saisie KM ») (Saisie véhicule / événement)
- « Resultat; … Voiture(s) avec probleme de controle technique / controle complementaire / revision / leasing / garantie: <immats> » ; « Tout est OK :)!! » (ListeEVVehicules / Alerte_Voitures)
- Étiquettes d'avertissement : « Penser à Actualiser après Insertion » (devis) ; « Attention pour chaudiere et Desenfumage pas de Test de date si l'inter existe deja !! » ; « Faire ABSOLUMENT en priorité les entretiens » (planification) ; « La saisie de l'année est prioritaire sur la periode de Temps » (statistiques).

---

## 8. Codes et libellés

**StatutDevis** (Devis, DevisTravaux, ContratDeMaintenance) — voir tableau §1.2. Retenir : 1 Devis à viser · 2 Visé, à envoyer / Aucun retour client · 3 Devis annulé et remplacé par · 4 Envoyé · 5 Devis refusé par le client · 6 Devis accepté par le client. Sources : listes de valeurs Form_57/67, commentaire `Détail_Paint`, `cmdGenerer` (6), `Controle_Devis` (4), Form_Site (1,2,4 = en cours), Form_00 (2,4 attente ; 5 refus).

**Intervention.typint** (nvarchar ; référentiel `TypeInterv.IndexLigneSTRING`) — listes de valeurs Form_72/38 et commentaires VBA : 1 Entretien · 2 Dépannage · 3 Devis accepté (« Suite à devis » dans un ancien état) · 4 Autre · 5 En travaux · 6 En création · 7 Désenfumage · 8 Inter. réalisée en attente devis signé client · 9 Audit · **13 Entretien Chaudière** (commentaire `Form_Planification.Commande125`, 19/08/25).

**Intervention.staint** (référentiel `StatusInterv`) — listes Form_38/Report_0 et VBA : −1 Matériel à commander · 1 A planifier · 2 Planifiée · 3 Attente de matériel · 4 En cours · 5 En cours chez le sous-traitant · 6 Effectuée en attente retour fiche intervention · 7 Clôturée (archivée, `ChkShowArchived`) · 8 Annulée avec accord client · 9 Réalisée - à valider (posé par « Clôturer ») · 10 Résolue par téléphone (posé par `chkprediagres`) · **17 Ne pas intervenir** (déduit : Form_Site bascule 1/9/−1 ↔ 17 ; étiquettes « Sites "Ne pas intervenir" »).

**EvVehicules.TypeEv** (référentiel `ListeEVVehicule`, déduit de `Saisie_Vehicule` et des étiquettes) : 0 Import KM depuis HeuresTech (Parametrage) · 1 Relevé km · 2 Révision · 3 Contrôle technique · 4 Contrôle complémentaire · 5 Relevé km (second type, ex. mobile) **[incertain sur la différence 1/5]**.

**Vehicules.EtatVehicule** (référentiel `ListeEtatVehicule`) : 4 = Vendu (case « Afficher Les Vendus » ↔ `EtatVehicule = 4`) ; 5 = état inactif exclu des alertes (épave / restitué ?) **[incertain]** ; autres valeurs = en service, libellés en table.

**HeuresTech.TypeInterv** : 60 = relevé kilométrique (ListeKM, Parametrage). Autres codes non rencontrés.

**Vehicules.Societe** : 0 FMC CLIM · 1 FMC MAINT (liste de valeurs Form_99).

**Utilisateur.typuti** : 1 = gestionnaire (liste « Envoyé par ») · 2 = technicien (conducteurs).

**Site.majregistresecuritefait** : `"FAUX"` = intervenir ; toute autre valeur = « Ne pas intervenir ».

---

## 9. Dépendances externes

- **Microsoft Excel** par automation (`Excel.Application`, `Workbook`, `Worksheet`) et **référence Office (`FileDialog`)**, pour : statistiques (3 exports), extraction matériel. Ouverture des modèles réseau puis `SaveAs`.
- **Modèles Excel** dans `\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\` : `Fichier_Stat.xlsx` (2 feuilles, la 2e « SheetDevis » n'est pas remplie), `Fichier_Stat_OGF.xlsx`, `Fichier_Stat_OGF_Par_Mois.xlsx` (12 feuilles), `Fichier_Extraction_Materiel.xlsx`. Chemins de test `c:\…` en commentaire.
- **Fichiers PDF de devis** sur partage réseau, référencés par chemin hyperlien dans `NomFichierDevis` ; ouverture du dossier via `explorer.exe /Select,`.
- **Fichier « heartbeat »** `C:\Users\Public\<année>\<mois>\FichierVieAccess.txt` écrit par `PDFCE.UpdateFichierBanane` (0 = « Je suis Vivant! » toutes les ~6 s depuis le timer du menu, 1 = « Arret Scrutation » pendant un export long, 2 = redémarrage) : surveillé par un processus externe (« Banane ») **[incertain sur ce processus]**.
- **SQL Server `logiclim`** via DSN ODBC `climaccess` (tables liées `dbo_*`) et ADODB pour la procédure stockée `UpdateIntervention` (appel désactivé). Les identifiants sont en clair dans le code.
- Timer du menu (`Form_MenuClimAccess.Form_Timer`, 1 s) : rafraîchit les bulles de notification, le heartbeat et traite les `Demande_Web` (autre application).
- Imports Excel annuaire (`\\serveur\Logiclim\annuaireAT.xls`, `annuaireCELIO.xls`) et import d'audits : boutons du MenuPrincipal / Parametrage, hors périmètre.

---

## 10. Points d'incertitude

1. **Format exact de `NumeroDevisInterne`** : seule la règle d'extraction depuis le nom de fichier est connue (préfixe 6 ou 9 caractères, coupure au premier `-` après la position 5, sinon 14 caractères). Le motif réel des noms de fichiers n'est pas dans le code.
2. **Format hyperlien de `NomFichierDevis`** (`libellé#\\chemin#`) : déduit de `AfficheDossierWindows`, `Controle_Devis` et de l'écriture `chemin#chemin#` dans Form_Intervention ; la concaténation de `NomFichierDevis_AfterUpdate` reste ambiguë.
3. **Procédure stockée `UpdateIntervention`** : rôle inconnu, appel désactivé.
4. **`Planification.recurrent` / `datefinrecurrence`** : jamais lus dans le VBA du périmètre.
5. **Requêtes `CréerEntretien`, `Entretiens par trimestre`, `SiteEntretienPrevuDemixage_*`, `RequeteTopTen/FlopTen`** : SQL non disponible ; leur articulation avec les générateurs VBA n'est pas établie. Aucun appel VBA à `CréerEntretien`.
6. **Quel algorithme de planification est réellement utilisé** aujourd'hui (`Planification.cmdGenerer` par dates limites vs `PlanificationEntretien.cmdGenerer` / `Commande19`) : les deux coexistent ; `Commande16` (2008) est manifestement obsolète. Les listes de clients « spéciaux » (1, 2, 40, 49, 70, 77) sont codées en dur.
7. **Statut « visite faite »** : `PlanificationEntretien.cmdGenerer` compte `staint = 9`, `Commande19` compte `staint = 4` ; Form_00 exclut 8 et 10. À confirmer avec le métier.
8. **`TypeEv` 1 vs 5** et **`EtatVehicule` 5** : libellés en table non disponibles.
9. **`Site.Mess_Devis`** : consommateur (fiche site, portail, mobile) non identifié dans le périmètre.
10. **`Fichier_Stat.xlsx` feuille 2** (« SheetDevis ») ouverte mais jamais remplie : fonction abandonnée ou prévue.
11. **`Form_Devis`** (petit formulaire) : appelant non trouvé ; probablement sous-formulaire d'un écran hors périmètre.
12. **`Form_Filtre Extraction`** contient `Calcul_Eclate`/`Calcul_Nom` sans contrôles associés : code mort à confirmer.
13. Les libellés des statuts de devis divergent entre écrans (2 « Visé, à envoyer » vs « Aucun Retour Client ») : le sens actuel du statut 2 doit être validé.
14. Nombreux bugs latents à ne pas reproduire : compteur de devis refusés toujours à 1 ; `max(numintint)` pour récupérer l'id créé ; `Left(x, -1)` si pas de `#` ; désenfumage généré en `typint 1` ; dates manipulées en chaînes `jj/mm/aa` ; comparaison d'année sur `Mid(datint,7,4)`.
