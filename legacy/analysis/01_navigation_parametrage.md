# ClimAccess (FMC) — Lot A : démarrage, navigation, paramétrage, imports, utilitaires

Sources analysées intégralement (VBA décompressé) : `Form_MenuPrincipal`, `Form_MenuClimAccess`, `Form_chargement`, `Form_ChoixSociete`, `Form_Parametrage`, `Form_ListeTables`, `Module1`, `Calcul`, `ClasseTech`, `Parcourir`, `Geocoding`, `ImportExcel`, `PDFCE`, `Form_Utilisateur sous-formulaire`, `Form_Zone Geographique`, `Form__Formulaire1`.
Compléments : extraits binaires des formulaires (`forms/*.txt`), sources de contrôles (`queries/*.sql`), `legacy/schema.sql`. Quand une information vient d'un module hors périmètre (pour confirmer un code), c'est indiqué explicitement.

Convention : `Module.Procédure` = référence au code. Les mots de passe en dur sont remplacés par `[mot de passe codé en dur]`.

---

## 1. Démarrage et connexion

### 1.1 Chaîne de démarrage
- Formulaire d'entrée : **MenuClimAccess** (formulaire à images cliquables). `Form_MenuClimAccess.Form_Current` exécute dans l'ordre :
  1. `Affiche_BP False` : masque tous les boutons/images du menu tant qu'aucun utilisateur n'est choisi.
  2. `NumGestEnCours = -1` (variable globale déclarée dans `Calcul.vba` : `Public NumGestEnCours As Integer`, `Public NomGestEnCours As String`, `Public Kadi_Logge As Boolean`).
  3. `RefreshTableLinks` : **reconnecte toutes les tables liées** en réécrivant leur chaîne ODBC : `ODBC;DSN=CLIMACCESS;UID=climaccess;PWD=[mot de passe codé en dur];APP=Microsoft Office 2010;DATABASE=logiclim` puis `tdf.RefreshLink`.
  4. `Recherche_Si_Envoi_Mail` : envoi automatique de mails de relance (voir §5.3).
  5. `MAJBubule` : calcul des compteurs ("bulles") du menu (voir §2.1).
  6. `UpdateFichierBanane 0` : écriture du fichier "heartbeat" (voir §5.5).
  7. `Shell("C:\users\public\KillAutoAccess\StartKillAuto.bat", vbMaximizedFocus)` : lance un script batch externe (contenu inconnu ; le nom suggère qu'il tue une autre instance Access automatique).
- `Form_chargement.Form_Current` : simple écran d'attente maximisé (`DoCmd.Maximize`), ouvert avant les listes longues (`ChargementListeInter`).

### 1.2 « Connexion » = choix d'un gestionnaire, sans mot de passe
- Il n'y a **pas d'authentification par mot de passe** au démarrage. L'utilisateur choisit son nom dans la liste déroulante `ChoixGest`. Source de la liste (`queries/_sq_cMenuClimAccess_sq_cChoixGest.sql`) :
  `SELECT numuti, preuti & " " & nomuti, typuti, codintuti, numsoc FROM Utilisateur WHERE typuti=1 AND codintuti<>"" AND numsoc<>1 ORDER BY preuti & " " & nomuti`.
  → seuls les utilisateurs **de type 1 (Gestionnaire)**, ayant un `codintuti` renseigné et **hors société numsoc=1** apparaissent.
- `Form_MenuClimAccess.ChoixGest_Change → Login` : si `NumGestEnCours = -1`, mémorise `NumGestEnCours = ChoixGest.Value` (numuti) et `NomGestEnCours`, affiche « Utilisateur Choisi: … », désactive la liste, `Affiche_BP True`.
- `Logout` (appelé par le timer toutes les ~6 s) : si `NumGestEnCours = 0` (perte de la variable globale après un arrêt VBA), MsgBox « Perte de l'utilisateur connécté, merci de vous re-identifier », remet `NumGestEnCours=-1`, réactive la liste, masque les boutons.
- `Affiche_BP` : rend visibles tous les boutons ; le bouton `Image118` « Voir Tables » (formulaire `ListeTables`) n'est visible que si `NumGestEnCours = 65 Or 66` (commentaire : « Fabien ou Pierre »).
- `NumGestEnCours` est ensuite utilisé ailleurs comme « traité par » (`Form_Intervention` ligne 2189 : `Me.traitepar.Value = NumGestEnCours`, hors périmètre) et pour la lecture des demandes web (`TraiteDemandeWeb`, §5.6).
- La table `HistoCnx` (numuti, datheucnx) existe dans le schéma mais **aucun module du périmètre n'y écrit** : l'historique de connexion n'est pas alimenté par Access (peut-être par le site web).

### 1.3 Rôles (`Utilisateur.typuti`)
Liste de valeurs du contrôle `typuti` du sous-formulaire Utilisateur (`forms/Form_31…txt`) : **1 = Gestionnaire ; 2 = Technicien ; 3 = Gestionnaire(Tech)**.
Ce que le code en fait :
| typuti | Utilisation constatée |
|---|---|
| 1 Gestionnaire | Seuls types éligibles à la connexion (`ChoixGest`). Alimentent les listes « traité par », « envoyé par », « prédiag par », etc. (sources `_sq_cIntervention_sq_c*`, `_sq_cDevisListe_sq_cEnvoyePar`). |
| 2 Technicien | Listes de techniciens intervenus/prévus (`InterventionTechnicien`, filtre `nomsocuti = codint de l'intervenant` ou `nomsocuti="FMC"`), conducteurs de véhicules (filtre `numsoc in (1,111,112,113)`). Ne peuvent pas se connecter à Access. |
| 3 Gestionnaire(Tech) | Aucune règle VBA spécifique trouvée dans le périmètre. Seul cas : `Form_Parametrage.EnvoiMail` ajoute « (Gestionnaire) » au mail d'identifiants si `Gestionnaire = "1" Or "3"` (le paramètre reçu est `rs(6)` = colonne `typuti`). |

Autres attributs utilisateur manipulés : `loguti` (login web), `mdputi` (mot de passe web **en clair**), `codintuti` (code « intervenant » — réutilisé par `Commande150` comme **mot de passe web généré**), `numsoc` (société), `Mail`, `Immat`, `KmARenseigner`, `nummod`.

### 1.4 Sociétés (`Societe.numsoc`)
- Les « utilisateurs FMC » sont définis en dur comme `numsoc = 1 Or 111 Or 112 Or 113` (`Form_Parametrage.Commande148/150`, sources de listes conducteurs). `Commande152` (envoi des mails) n'utilise que 111/112/113.
- La connexion exclut `numsoc = 1` (voir 1.2). Le libellé exact de chaque société n'est pas dans le code (table `Societe` : `numsoc`, `nomsoc`). **Incertitude** : 1 = ancienne entité (Clim'Tech ?) ou FMC « historique ».
- `Form_ChoixSociete` : malgré son nom, ce formulaire ne choisit pas de société : `cmdValider_Click` lit `OpenArgs = "<numintint>;<nom d'état>"` et ouvre l'état demandé filtré sur `numintint=…`. C'est un sélecteur d'état pour une intervention (probablement choix de l'en-tête société de la fiche).

### 1.5 Identifications secondaires (mots de passe en dur)
| Où | Qui | Mécanisme | Effet |
|---|---|---|---|
| `Form_MenuClimAccess.Image110_Click` (« Mot de Passe Kadi ») | seulement si `NumGestEnCours = 367` (Kadi) | `InputBox`, comparaison à `[mot de passe codé en dur]` (4 chiffres) | `Kadi_Logge = True`, libellé « KADI IDENTIFIEE ». Débloque `Calcul.Verification_Droit_Modif` (statuts facturation réservés) et le décochage « Ne plus intervenir » dans `Form_Site` (hors périmètre). |
| `Form_Parametrage.Commande153_Click` (« Access Gestion Mot de passe ») | n'importe qui | `InputBox` ; mot de passe attendu = `mdputi` de l'utilisateur **numuti=65** concaténé deux fois (`rs(7)+rs(7)`, commentaire « 65=FM ») | Affiche les boutons de régénération/envoi des mots de passe web (`Commande150`, `Commande152`, `LstTech`, `CocherAll`). |
| `Form_Parametrage.Commande157/163/194_Click` (statuts facturation, statuts intervention, types intervention) | n'importe qui | mot de passe = `"om" & Format(Now,"dd") & Format(Now,"mm")` → `[mot de passe codé en dur, dérivé de la date du jour]` | Passe les sous-formulaires `FormFact` / `FormStatusInterv` / `TypeInter` en `AllowEdits=True`. |

---

## 2. Menu principal

Deux menus coexistent :
- **MenuClimAccess** (menu « moderne » à images, FMC) — point d'entrée.
- **MenuPrincipal** (« ClimAccess - Gestion des interventions », barre d'outils `CLIM'TECH Formulaire`) — ancien menu Clim'Tech, ouvert depuis MenuClimAccess par `ImgMenuPrincipal_Click` (`DoCmd.OpenForm "MenuPrincipal", …, "MenuPrincipal"`). Il est **lié à la table `parametre`** (source `SELECT … FROM parametre`) : ses champs `datdeb`, `datfin`, `LstClient` (=`numcli`) sont des champs de cette table.

### 2.1 MenuClimAccess — boutons et compteurs

Libellés issus de `forms/Form_47…txt` ; comportement `Form_MenuClimAccess`.

| Contrôle | Libellé | Action (procédure) |
|---|---|---|
| `imgClient` | CLIENTS | Ouvre `Listeclientaffiche`. |
| `Image25` | SITES | Ouvre `ListeSiteGenerale`. |
| `ImgDonneur` | INTERVENANTS | Ouvre `ListeSousTraitGenerale` (malgré le nom « Donneur »). |
| `ImgEntretien` | ENTRETIEN / DEPANNAGE DEVIS ACCEPTES | `chargement` puis `ListeInterventionGenerale` avec OpenArgs `"AValider"`. |
| `Image33` | Fiches d'interventions à valider | `ChargementListeInter "AValider"` → `ListeInterventionGenerale` (hors périmètre : positionne `cboStatut=9`, `cboTypeIntervention=0`, c.-à-d. **staint=9 tous types**). |
| `Image52` | Fiches d'interventions à Facturer | `ChargementListeInter "AFacturer"` → `StatutFact=1` (**nbrappint=1**). |
| `Image85` | A Valider Par le Boss | `ChargementListeInter "AvaliderFabien"` → `StatutFact=8` (**nbrappint=8**). |
| `Image65` | Duplicata | `ChargementListeInter "Duplicata"` → `cboStatut=7` + `CheckDevisAFaire=True` (**staint=7 and devisafaire=true**). |
| `Image67` | Materiel à Commander | `ChargementListeInter "ACommander"` → `cboStatut=-1` (**staint=-1**). |
| `Image69` | Attente Materiel | `ChargementListeInter "AttenteMatos"` → `cboStatut=2` (**staint=2**). |
| `imgDevis` | DEVIS SAV | Ouvre `DevisListe` (OpenArgs `"Entretien"`). |
| `imgDevisTravaux` | DEVIS Travaux | Ouvre `DevisListeTravaux` (OpenArgs `"Entretien"`). |
| `Img_DevisContratDeMaintenance` | Contrat de Maintenance | Ouvre `DevisListeContratDeMaintenance` (OpenArgs `"Entretien"`). |
| `Image8` | STATISTIQUES | Ouvre `00 - Statistiques Clients`. |
| `Image107` | Filtre Extraction | Ouvre `Filtre Extraction`. |
| `Image31` | Intervalle de dates à afficher sur tablette | Ouvre `FiltreInterventionsMobiles` en mode dialogue (paramétrage de l'appli mobile : table `FiltreClimAccessMobile`). |
| `Image27` | (carte) | Ouvre `Carte` en dialogue. |
| `Image89` | Vehicules | Ouvre `ListeEvvehicules`. |
| `Image113` | Utilisation FF (gaz) | Ouvre `ListeInterGaz`. |
| `Image110` | Mot de Passe Kadi | Voir §1.5. |
| `Image118` | Voir Tables (visible seulement numuti 65/66) | Ouvre `ListeTables`. |
| `imgParametrage` | PARAMETRAGE | Ouvre `Parametrage`. |
| `ImgMenuPrincipal` | (non libellé) | Ouvre `MenuPrincipal`. |
| `ImgIntervention` / `ImgSuiteDevis` / `ImgAuditASaisir` | (procédures présentes, contrôles absents de l'extrait → boutons probablement supprimés) | `ListeInterventionGenerale` avec `"Maintenance"` (cboTypeIntervention=2) / `"SuiteDevis"` (=3) ; `Audit`. |
| `Commande157` | MAJ | Recalcule les compteurs (`MAJBubule`). |
| `Commande37` | — | `GoToRecord acLast` (vestige). |

**Compteurs (`MAJBubule`)**, tous calculés sur la requête/vue `ListeInterventionGenerale2` (définition non exportée) :

| Libellé (form) | Requête | Signification |
|---|---|---|
| Nombre d'interventions à valider | `COUNT(*) … where staint=9` | fiches réalisées à valider |
| Stand By | `COUNT(*) … where nbrappint=9` | statut facturation « stand by » |
| Devis SAV accepté (rouge) / Dépannage (vert) / Maintenances (bleu) / En travaux (orange) / Autres types (noir) | `SELECT typint … where nbrappint=1 or nbrappint=2`, ventilé par `typint` : 3→rouge, 2→vert, 1→bleu, 5→orange, autre→noir | interventions en statut facturation 1 ou 2 par type |
| Nombre de Materiel à commander | `staint=-1` | |
| Nombre de Materiel en attente | `staint=2` | |
| Nombre de duplicata Total | `staint=7 and devisafaire=true` | |
| Attente offre de prix (`lblNotifDuplicataafaire`) | `staint=7 and devisafaire=true and duplicatafait=true` | |
| A traiter (`lblNotifDuplicataTrait`) | `staint=7 and devisafaire=true and duplicatafait=false` | |
| Nombre d'interventions à valider par fabien | `nbrappint=8` | |
| Probleme de CT / CC / Leasing / Garantie / Revision | `Alerte_Voitures(False)` (voir §6.6) | parc automobile |

Rafraîchissement : `Form_Timer` (intervalle 1 s d'après le commentaire du 28/11/25) → `MAJBubule` tous les 60 ticks, `Logout` + `UpdateFichierBanane 0` tous les 6 ticks, `TraiteDemandeWeb` tous les 2 ticks (seulement si un gestionnaire est choisi et si `RegardeDemandeWeb <> -1`).

### 2.2 MenuPrincipal (ancien menu Clim'Tech) — par rubrique

`Form_Load` : `DELETE parametre.numpar FROM parametre WHERE numpar<>1` puis `Me.Requery`, affiche la barre d'outils `CLIM'TECH Formulaire`. (**Incertitude** : la table SQL Server `parametre` n'a pas de colonne `numpar` ; il s'agit sans doute de la table locale Access `parametre`, ou la requête échoue silencieusement.) `Form_Current` : `DoCmd.Maximize`.

Filtres communs : `LstClient` (liste `SELECT numcli, nomcli FROM Client`, lié au champ `numcli` de `parametre`), `datdeb`/`datfin` (champs de `parametre`, utilisés par les états/requêtes `ListeInterventionAEffectuer`, `…AFacturer`, `…Facturee` — cf. ANALYSIS.md), `CmdFiltrer` = **« Filtrer » n'applique aucun filtre : il enregistre l'enregistrement courant** (`acSaveRecord`), donc sauvegarde la période/le client dans `parametre`. `ListeTri` (1 Alphabétique / 2 N° de site), `ddlTypeSite`/`ddlTypeSite2`/`cmbIntTrimType` (type de magasin H/F/mixte, spécifique Armand Thierry).

**Rubrique « Entretien »**
| Bouton | Libellé | Action |
|---|---|---|
| `CmdOuvrirInterventionPlanifiee` | Interventions planifiées | `InterventionEntretien` filtré `(typint='1' or '6' or '7') and staint<9 and cptsit in (select cptsit from site where numcli=LstClient)`, OpenArgs `IEP` ; `GformulaireParent="MenuPrincipal"`. |
| `CmdOuvrirInterventionsCloturees` | Interventions clôturées | idem avec `staint=9`, lecture seule, OpenArgs `IEC`. |
| `CmdOuvrirPlanificationEntretien` / `CmdPlanifier` | Planifier les entretiens | `PlanificationEntretien`. |
| `CmdEntretienParMois` | Entretien par mois | état `NombreVisiteEntretienParMois`. |
| `Cmd01…Cmd09`, `Cmd11` | états 01 à 09, 11 (visites d'entretien par mois/trimestre/an, écarts date prévue, manque d'entretien code A05, dépannage en même temps que l'entretien) | `OpenReport` sans filtre. |
| `CmdT1…CmdT4` | Planning prévisionnel entretien T1..T4 | `Calcul.GenererPlanningPrevisionnel` puis état `SiteEntretienPrevu-Tn`, filtre `Intervenant like 'LstIntervenant*'`. |
| `CmdPlaGenEntT1`, `CmdTG2..4` | Planning prévisionnel général entretien T1..T4 | `GenererPlanningPrevisionnel` + état `SiteEntretienPrevuGeneralTn`. |
| `CmdPlanningT1..T4` | Planning entretien T1..T4 | `GenererPlanningPrevisionnel` + état `SiteEntretienGeneralTn`. |
| `cmdPlaAnnee` | Planning prévisionnel entretien Année | formulaire `ChoixIntervenant`. |
| `CmdInterventionAEffectuer` | Entretiens à effectuer | état `ListeInterventionAEffectuer`, filtre `typsit IN ('H','M')` ou `typsit='F'` selon `ddlTypeSite2`. |
| `CmdSitesNonVisites` | Sites non visités | état `Sites non visités`. |
| `btnIntTrim` | Interventions par trimestre → Liste | état `Entretiens par trimestre` ; filtre `typsit LIKE 'H%'` ou `='F'` (passé en 3e argument = FilterName, probablement inopérant). |
| `cmdIntT1`, `Commande274/275/276` | Interventions par client 1er..4e trimestre | états correspondants filtrés `numcli=Me.numcli`. |

**Rubrique « Dépannage palliatif »** (typint 2 et 3 dans ce menu)
| Bouton | Libellé | Action |
|---|---|---|
| `CmdOuvrirInterventionEnCours` | Interventions en cours | `Intervention` filtré `(typint='2' or typint='3') and staint<9 and cptsit in (… numcli=LstClient)`, OpenArgs `IDE`. |
| `CmdOuvrirInterventionCloturee` | Interventions clôturées | idem `staint=9`, lecture seule, OpenArgs `IDC`. |
| `CmdOuvrirAttenteObservation` | (attente) | `Intervention` filtré `typint='2' and staint<9 and datintpre is null` (dépannages non planifiés), OpenArgs `IDA`. |
| `CmdListerInterventionAttente` | Liste des interventions (H+8) en cours | `ListeInterventionAttente` filtré `typint='2' and staint<9 and numcli=LstClient`, OpenArgs `H+8`. |
| `CmdOuvrirListeInterventionFacturable` | Interventions à facturer | `ListeInterventionAttente` filtré `typint='2' and staint<9 and intafact=true and numcli=LstClient`, OpenArgs `Facturable`. |
| `CmdDepannageParMois`, `CmdAnalyseTypePanne`, `CmdDepannageParTypeDeSite`, `CmdDepannageParSite` | Dépannage par mois / Analyse des types de panne / par type de site / par site | états `NombreVisiteDepannageParMois`, `AnalyseDepannage`, `AnalyseDepannageTypeSite`, `NombreDepannageParSite`. |
| `Cmd39`, `Cmd40…Cmd58` | états 39 à 58 (nombre de dépannages par site/mois/trimestre/an/situation/zone/type de site/civilité/surface/marque/contact, coûts, durée moyenne, % par zone, par type de panne) | `OpenReport` sans filtre. |
| `Cmd101`, `CmdItDep` (102), `Cmd103`, `Cmd104`, `Cmd117` | écarts de temps H+8, dépassements, pannes résolues par téléphone | états 101, 102, 103, 104, 117. |
| Page « Coût palliatif » : `Cmd111[/f/h/m]`, `Cmd112[/f/h/m]`, `Cmd113..116` | coûts palliatifs (global / femme / homme / mixte, par situation/zone/civilité/type) | états 111 à 116. |

**Rubrique « Dépannage curatif/correctif »** (typint 4 et 5 dans ce menu)
| Bouton | Action |
|---|---|
| `CmdDepanageCuratifEnCours` | `Intervention` filtré `(typint='4' or typint='5') and staint<9 and cptsit in (… numcli=LstClient)`, OpenArgs `IDCE`. |
| `CmdDepanageCuratifCloture` | idem `staint=9`, OpenArgs `IDCC`. |
| `Cmd59..Cmd78` (curatif), `Cmd123..126` (coûts curatifs), `Cmd71[/f/h/m]`, `Cmd72[/f/h/m]`, `Cmd75[/f/h/m]`, `Cmd76[/f/h/m]`, `Cmd77` | états 59 à 78 et 123 à 126. |
| `Cmd79..Cmd98`, `Cmd97p`, `Cmd91/92/95/96[/f/h/m]`, `Cmd133..136` (correctif) | états 79 à 98 et 133 à 136 (note : `Cmd97` ouvre l'état « 96 - … mixte », probable copier-coller). |

**Rubrique « Suivi »**
| Bouton | Action |
|---|---|
| `BtnImprimerInterventionEnCours` (Liste des interventions) | état `Listes des interventions en cours`, filtre construit à partir de `CboSuiviClient` (`numcli=`), `CboSuiviIntervenant` (`codint='…'`), `CadreSuivi` : option 1 « en cours » → `staint<9 and datint is null` ; option 2 « effectuée en attente de bon » → `datint is not null`. |
| `CmdOuvrirIntervention` | `Intervention` filtré `staint<9 and datint is not null` (effectuées non clôturées). |
| `CmdInterventionCloturee` | `Intervention` filtré `staint=9`, lecture seule. |
| `CmdRechercherSite` | `RechercheSite` filtré `numcli=LstClient`. |
| `CmdRechercherIntervention` | `RechercheIntervention`. |
| `CmdListeInterventionFacturable`, `CmdListeInterventionsFacturees`, `CmdListeInterventionAFacturer` | états `ListeInterventionFacturable`, `ListeInterventionFacturee`, `ListeInterventionAFacturer`. |
| `CmdTopTen` / `Commande248` (Top Ten / Flop Ten) | vide la table `TopTen`, la recharge depuis la requête `RequeteTopTen` / `RequeteFlopTen` (nomsit, indvetust, NBTOTAL, NBDEF, numsit, typsit ; Flop limité à 20 lignes, Top non limité malgré le test `icpt=20` commenté), puis ouvre l'état `TopTen` / `FlopTen`. |
| `Commande237` (stats) | formulaire `statistiques`. |

**Rubrique « Liste des sites / Autres »**
| Bouton | Action |
|---|---|
| `CmdListeSiteIntervenant` | état `ListeSiteIntervenant` ou `ListeSiteIntervenantNum` (selon `ListeTri`) ; filtre `nomzon='LstIntervenant' or codint='LstIntervenant'` + type de site. |
| `CmdListeSimpleSite` | état `ListeSiteSimple[Num]` + filtre type de site. |
| `CmdListeSiteRedevance` | état `ListeSiteRedevance[Num]` ; filtre type de site appliqué **uniquement si `LstClient = 1`** (commentaire « Uniquement pour Armand Thierry » → numcli 1 = Armand Thierry ; valeurs `typsit IN ('H','H et F')`). |
| `Cmd10`, `Cmd12` (`CmdSiteTravauxCreation`), `Cmd20..23` | états 10 (matériels vétustes), 12 (sites en travaux/création), 20-23 (sites par type/situation/zone/civilité). |
| `cmdLstAspirateurFiltre` | ouvre `Zone Geographique` (voir ci-dessous) → état 137. |
| `Commande293` | état `137bis - Liste des sites avec aspirateur` filtré `numcli=LstClient`. |
| `cmdCouverture` | état `Couverture`. |
| `CmdOuvrirRepertoireTechnique` | état `RépertoireTechnique` filtré `numzonsit=CbZone` **ou** `numintervenant=LstIntervenantRepertoire` (le second écrase le premier). |
| `btnModeleRepertoireTechnique`, `btnChampsRepertoireTechnique` | formulaires `ModeleRepertoireTechnique`, `ChampRepertoireTechnique`. |

**Rubrique « Paramétrage » (de MenuPrincipal)**
`CmdOuvrirContact`→`Contact`, `CmdOuvrirIntervenant`→`Intervenant`, `CmdOuvrirMarque`→`Marque`, `CmdOuvrirReference`→`Reference`, `CmdOuvrirSite`→`Site` (filtré `numcli=LstClient` si renseigné), `CmdOuvrirZone`→`ZoneGeographique`, `CmdOuvrirPanne`→`Panne`, `CmdOuvrirClient`→`Client`, `CmdOuvrirJoursFeries`→`JoursFeries`, `cmdTypeFluide`→`TypeFluideFormulaire`, `CmdMarqueDesenfumage`→`MarqueDesenfumage`, `CmdReferenceDesenfumage`→`ReferenceDesenfumage`, `cmdClimserv`→`Climserv`, `cmdClientsClimServ`→`Clients ClimServ` (« Utilisateurs site des inter. »), `Commande297`→`Import_de_site_en_Excel`, `Commande300`→`ImportFichesInter`, `Commande301`→`SaisieEnTableau`, `CmdMajSite`→macro `ImportAnnuaireAT` (libellé : fichier `\\serveur\Logiclim\annuaireAT.xls`), `CmdCelio`→macro `ImportAnnuaireCELIO` (`\\serveur\Logiclim\annuaireCELIO.xls`), `CmdRelinkTables` → réécrit les liaisons avec `Data Source=serveur;Initial Catalog=logiclim;User Id=abrminfo;Password=[mot de passe codé en dur]` (chaîne **non préfixée `ODBC;`**, probablement inopérante ; c'est `RefreshTableLinks` de MenuClimAccess qui fait foi).

### 2.3 Formulaires satellites du périmètre
- `Form_Zone Geographique.cmdValider_Click` : critère `numcli = Form_MenuPrincipal.LstClient` + `numzonsit = LstZoneGeographique` (si choisi) → état `137 - Liste des sites avec aspirateur`.
- `Form_ListeTables` (« Voir Tables », réservé numuti 65/66) : en pratique un **écran de recherche des événements véhicules** : `Filtre_OM_Test` construit `conducteur=`, `immat='…'`, `TypeEv=`, `EtatVehicule=4` si `CheckVendu` sinon `<>4`, `dateev >= / <=` ; source jointe `EvVehicules × Utilisateur × ListeEVVehicule × Vehicules`, tri `DateEv desc`. `Commande58` → `Saisie_EV_Vehicule` en ajout. `Commande59` → `Form_MenuClimAccess.Alerte_Voitures(True)` et affiche le détail des immatriculations en alerte (ou « Tout est OK :)!! »). Contient aussi des vestiges (`Option80/82` bascule `Form_All_Sites`/`Form_All_Inter`).
- `Form__Formulaire1` : formulaire de test d'envoi de mail (exemple Hervé Inisan / self-access.com), `SendMail2` = `DoCmd.SendObject acSendNoObject` (client mail par défaut). `SendMail2` est aussi appelée depuis `Form_Intervention` (hors périmètre).

---

## 3. Paramétrage (`Form_Parametrage`)

Formulaire à sous-formulaires ; chaque bouton appelle `MasquerTout` puis rend visible un sous-formulaire positionné/redimensionné. `Form_Load` → `MasquerTout`. Un avertissement fixe rappelle : suppression impossible, une modification d'un libellé se propage partout (ex. renommer un technicien réaffecte toutes ses interventions).

| Bouton | Libellé | Sous-formulaire / table | Particularités |
|---|---|---|---|
| `CmdOuvrirIntervenant` | Intervenant | `Intervenant sous-formulaire` | |
| `CmdOuvrirZone` | Zone géographique | `ZoneGeographique sous-formulaire` (table `ZoneGeographique` : `numzon`, `nomzon` unique) | |
| `CmdAffectionSocieteZone` | (affectation société/zone) | `ZoneSociete sous-formulaire` (table `ZoneSociete`, vide en base) | |
| `CmdSociete` | Sociétés | `Societe sous-formulaire` | |
| `cmdUtilisateurs` | Utilisateurs && Techniciens | `Utilisateur sous-formulaire` (toutes colonnes de `Utilisateur`) | affiche aussi `Commande153` (accès gestion mots de passe). `Form_Utilisateur sous-formulaire.Form_AfterInsert` : MsgBox « Merci de penser a lancer le Programme de fabien pour prise en compte des jours fériés (Si Chez FMC) » → un **programme externe** gère les jours fériés/congés des nouveaux utilisateurs. |
| `CmdDonneurs` | Donneurs d'ordres | `Donneur sous-formulaire` | |
| `Commande35`/`CmdOuvrirPanne` | Panne | `Panne sous-formulaire` | |
| `Commande58`/`CmdOuvrirMarque` | Marque | `Marque sous-formulaire` | |
| `Commande57`/`CmdOuvrirReference` | References | `Reference sous-formulaire` ; boutons `Commande126` « Ajouter Une Reference » (→ `Saisie_Reference` en ajout) et `Commande143` « Importer Fichier Audit » | |
| `Commande59`/`cmdTypeFluide` | Fluide | `TypeFluide sous-formulaire` (`libelle`, `GWP`, `Type`→`Liste_Type_Gaz`) | |
| `Commande190` | Classif Gaz | `ClassifGaz sous-formulaire` (`Liste_Type_Gaz`) | |
| `Commande55` | Reperes | `Repere_Sous_Form` | |
| `Commande56` | Type Telecommande | `Type_Telecommande Sous_Form` (`TypeTel`) | |
| `Commande61` | Type (audit) | `Type_Audit_Sous_Form` (`TypeAudit`) | |
| `Commande135` | Sous Type Inter | `Sous_Type_Sous_Form` (`SousType`) | |
| `Commande141` | Activites | `Activite sous-formulaire` (`Activites`) | |
| `Commande157` | Statut Facturation | `statut Fact Sous Form` (`StatutFacture` : `IndexLigne`, `Statut`, `OrdreAffichage`, `QueKadi`) | édition protégée par mot de passe date (§1.5) ; libellé : « Si ordre=-1 alors invisible dans liste déroulante » |
| `Commande163` | Statut Interventions | `statut Interv Sous Form` (`StatusInterv`) | idem |
| `Commande194` | Type Intervention | `Type Interv Sous Form` (`TypeInterv` : `IndexLigne`, `TypeInter`, `OrdreAffichage`, `IndexLigneSTRING`) | idem |
| `Commande199` | Ecart Mini Maintenance | `Visites_Maint_Sous_Form` (`VisitesMaint` : `Nombre_Visites`, `Ecart_Permis_Jour`, `Commentaire`) | règle « entretien proche » utilisée par `ListeInterventionGenerale` (hors périmètre) |
| `Commande165` | Liste Vehicules | `Vehicules` | rappel : « Penser également à modifier l'Immatriculation dans la table Utilisateur » |
| `Commande175` / `Commande176` | Evements Vehicules / Etats Vehicules | `ListeEVVehicule` / `ListeEtatVehicule` | |
| `CmdImporter` | Export Audit Materiel (Qte Fluide) | `ImportExcel.Exporter_Audit` (§4.4) | |
| `Commande143` | Importer Fichier Audit | `ImportFichierAudit` (§4.1) | |
| `Commande168` / `Commande186` | Import Audit Materiel (Qte Fluide) | `ImportFichierAuditQte` (§4.2) ; MsgBox nominatif « Pierre Morue, vous allez importer… » | |
| `Commande173` | Convertion Saisie Opérateur | lit `HeuresTech where TypeInterv=60` et crée des `EvVehicules` (§6.7) | |
| `Commande148` | MAJ Login Efface MDP Acien Site FMC | pour `numsoc in (1,111,112,113)` : `loguti = Left(preuti,1) & "." & nomuti` et `mdputi=""` (login vidé si nom/prénom manquant) | |
| `Commande150` | MAJ Mot de passe (Tout les Utilisateurs FMC) | pour les mêmes sociétés, si nom, prénom, login et mail renseignés : `codintuti = RandomCode()` (5 lettres + 2 chiffres + 1 symbole `@#!?;.:` mélangés), sinon `codintuti=""` | **le mot de passe web est stocké dans `codintuti`** (pas `mdputi`) |
| `Commande152` | Envoi Mail Mot de passe | pour `numsoc in (111,112,113)` (+ sélection `LstTech` ou `CocherAll`), si `loguti`, `codintuti` (rs(7)) et `Mail` renseignés : `EnvoiMail(Mail, loguti, codintuti, typuti)` via Outlook, objet « Changement de mot de passe du site FMC », lien `https://intervention.fmc-maintenance.fr/interventionstest/Default.aspx?q=1` | mot de passe envoyé **en clair** |
| `CmdFermer` | Fermer | `DoCmd.Close` | |

Autres paramètres gérés hors de ce formulaire : **période `datdeb`/`datfin` et client courant** (table `parametre`, saisie dans `MenuPrincipal`, sauvegardée par « Filtrer ») ; **jours fériés** (`MenuPrincipal.CmdOuvrirJoursFeries` → formulaire `JoursFeries`, table `JoursFeries(numjou, datjoufer)`, lue par `Calcul.EstFerie`) ; **filtre tablette** (`FiltreInterventionsMobiles`).

---

## 4. Imports / exports Excel

### 4.1 Import du fichier d'audit matériel (`Form_Parametrage.ImportFichierAudit`)
- Déclenché par `Commande143` : confirmation, `FileDialog` (extension `.xls`/`.xlsx` obligatoire), automation Excel (`GetObject`/`CreateObject("Excel.Application")`), 1er onglet.
- Lit les lignes 2 à 32000 ; arrêt quand la colonne B (`NumeroSite` = `Site.cptsit`) vaut 0 ; ligne comptée en erreur si `NumeroSite = -1`. Commentaire : « la première ligne ne passe pas, il faut la recopier en ligne 3 ».
- Colonnes attendues : B NumeroSite, C RepereSurSite, D Repere, E Emplacement, F Quantite (0 si vide), G Marque, H Type, I Reference, J NumeroSerie, K Reversible, L ResistanceElectrique, M PuissanceFrigo, N PuissanceCalo, O FluideQuantite, P DateMiseEnService, Q TypeTelecommande, R NbreTelecommande, S EmplacementTelecommande, puis colonnes T..BH (20..60) mappées vers Disjoncteurs, DisjoncteurPrincipal, …, RideauAir, …, Radiateurs, NbreRadiateurs, LocalisationRadiateurs, …, VMC, LocalisationVMC, Photos (col 55), Observations (col 60). Colonnes 27, 28, 30, 33, 50 numériques (0 si vide) ; colonnes 35, 39, 47, 49, 53, 55 booléennes (« FAUX » → 0, sinon 1 — le test `UCase(TableData(j) = "FAUX")` est bogué : la comparaison est faite avant `UCase`, donc « faux » minuscule donne 1).
- Cible : `INSERT INTO SiteMateriel(...)` ligne par ligne, **sans dédoublonnage** (réimporter crée des doublons). Compteurs OK/KO affichés, MsgBox de fin.
- `ImportFichierAuditOld` : ancienne version (recherche du site par `nomsit` via `RechercheSite`, colonnes décalées) — plus appelée.

### 4.2 Import des quantités de fluide (`ImportFichierAuditQte`, boutons `Commande168`/`Commande186`)
- Colonnes : A `NumeroSiteMateriel` (clé), C fluide (libellé), D quantité (0 si vide/non numérique). Arrêt à la première colonne A vide.
- `UPDATE SiteMateriel SET FluideQuantite='<fluide>', nbreradiateurs=<quantité> WHERE Numerositemateriel=<A>`. **La quantité de fluide est stockée dans la colonne `nbreradiateurs`** (réutilisation de colonne), le libellé du fluide dans `FluideQuantite`.

### 4.3 Import sites + interventions d'entretien (`ImportExcel.ImportSiteIntervention`)
- Non relié à un bouton du périmètre (probablement appelé par le formulaire `Import_de_site_en_Excel`). Lit `c:\temp\import.xlsx`, feuille `IMPORT$`, via ADO/ACE (`HDR=YES`).
- Colonnes attendues (noms d'en-tête) : `client`, colonne 2 = donneur d'ordre (`rs(1)`), `site`, `adressse` (sic), `code postal`, `ville`, `zone`, `intervenant`, `date limite`, `date intervention`.
- Passe 1 (contrôle bloquant) : pour chaque ligne avec `site` non vide, la `zone` (ZoneGeographique.nomzon), le donneur (`Donneur.nomdonneur`), l'intervenant (`Intervenant.codint`) et le client (`Client.nomcli`) doivent exister, sinon MsgBox « … n'existe pas dans le paramétrage. Merci de l'ajouter et de relancer. Le traitement est arrêté, aucune donnée n'a été importée. » et abandon.
- Passe 2 : arrêt quand client et site sont nuls. Si le couple (client, site) n'existe pas → création du `Site` (numcli, nomsit, adrsit, codpossit, vilsit, numzonsit, donneurid, numintervenant) et `cptsit = max(cptsit)`. Si `date limite` renseignée et qu'aucune intervention `typint='1'` n'existe déjà pour ce site à cette `datheulim` → création d'une `Intervention` avec `codint`, `typint=1` (Entretien), **`staint=1` (« à planifier », commentaire : un humain doit clôturer après push/pull du bon)**, `datheulim`, `datint` éventuelle. MsgBox « Import terminé ».

### 4.4 Export audit matériel (`ImportExcel.Exporter_Audit`, bouton `CmdImporter`)
- Ouvre le modèle réseau `\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Audit.xlsx`, remplit à partir de la ligne 2 : A NumeroSiteMateriel, B NumeroSite, C fluide, D quantité (décomposition de `FluideQuantite` au format `"<fluide> / <qté> Kg"` ; sinon fluide = libellé et quantité = `NbreRadiateurs`).
- **Bogue** : la boucle sort dès `Ligne > 16` (variables `debut=0`, `fin=15`) → seules ~14 lignes sont exportées. Enregistre sous `<dossier choisi>\Audit.xlsx`.

### 4.5 Annuaires clients (`ImportExcel.ImportAnnuaire`, macros `ImportAnnuaireAT`/`ImportAnnuaireCELIO`)
- `"AT"` (Armand Thierry) : table liée/importée `annuaire` (colonnes `N°`, `F8` civilité, `Directrice` « Nom Prénom », `Téléphone`, `Fax`) → `UPDATE Site SET civres, nomres, preres, telsit, faxsit WHERE numsit=<N°> AND numcli=1`.
- `"Celio"` : table `LISTING` (`N°`, `TELEPHONE`, `FAX`) → `UPDATE Site SET telsit, faxsit WHERE numsit=<N°> AND numcli=4`.
- → **numcli 1 = Armand Thierry, numcli 4 = Celio** (codés en dur). Erreurs ignorées (`Resume Next`).

### 4.6 Scripts de migration ponctuels (ne font que `Debug.Print`)
- `ImportSiteCelio` : génère des `INSERT INTO Site(...)` avec `numcli=188` depuis la table `SitesCelio`.
- `ImportSite` : génère des `INSERT INTO Site(...)` avec `numzonsit=54` depuis la table `AImporter`. Aucun n'exécute le SQL.

---

## 5. Utilitaires

### 5.1 Géocodage (`Geocoding.Geocode`)
- API **Google Geocoding v3 en HTTP non chiffré, sans clé** : `http://maps.googleapis.com/maps/api/geocode/xml?address=<adresse>,<ville>,<région>,<CP>,FRANCE&sensor=false`, parsé avec `Microsoft.XMLDOM`. Retourne `tGeocodeResult` (lat, lng, `formatted_address`, `location_type` comme précision, `status`). Code d'auteur Philben 2011 (limite 2 500 req/jour, 200 ms entre appels). Probablement **non fonctionnel aujourd'hui** (clé obligatoire côté Google) — à vérifier.
- Appelé (hors périmètre) par `Form_Site.CmdGeocoder_Click` (bouton manuel ; ignoré si précision déjà `ROOFTOP` ; repli sur ville seule si statut ≠ OK) et `Form_Map` (géocodage en masse et adresse libre). Alimente `Site.latitude/longitude/precisiongeo`.

### 5.2 Génération PDF des certificats d'étanchéité (`PDFCE`)
- `Creation_PDF_CE(cptsit)` (boutons `Commande402` de `Form_Site` et `Form_Intervention`) :
  1. Dossier par défaut = début de `Site.chemindoc` (format `#\\chemin\…#`, jusqu'au premier `#` ; si vide, on retire le 1er et le dernier caractère).
  2. `FileDialog` dossier (« Merci de Selectionner le repertoire pour le PDF »).
  3. Sélection `SiteMateriel WHERE numerosite=<cptsit> AND CE_EDITE=0 AND YEAR(DateCE)=<année courante>` ; si aucun → MsgBox « Les CE ont deja été édités ».
  4. Pour chaque matériel : `ControleDatasCE` puis `PDF_CE "<NumeroInter>-<NumeroSiteMateriel>", dossier`.
  Remarque : **`CE_EDITE` n'est jamais mis à 1 dans ce module** (le marquage se fait ailleurs ou pas du tout — incertitude).
- `ControleDatasCE` (contrôles bloquants, MsgBox « La génération du CE … n'a pas pu se faire correctement, cause: … ») : fluide renseigné et présent dans `TypeFluide` ; `TypeFluide.Type ≠ 0` ; type de gaz (`Liste_Type_Gaz.libelle`) ∈ {`HCFC`, `HFC`, `HF0`} (sic : zéro, probablement HFO) ; `NbreRadiateurs` (= quantité de fluide) > 0 ; `GWP` > 0 ; `Marque`, `NumeroSerie`, `Reference` non vides.
- `PDF_CE` : ouvre l'état **`Test Cerfa`** masqué avec OpenArgs = `"<NumeroInter>-<NumeroSiteMateriel>"`, `DoCmd.OutputTo acFormatPDF` vers `<dossier>\<NumInter>-<NumMateriel>.pdf`, ferme l'état. Erreur → « Export Vers PDF Annulé ».

### 5.3 Envoi d'e-mails
| Fonction | Via | Destinataire | Quand | Contenu |
|---|---|---|---|---|
| `Form_MenuClimAccess.EnvoiMail` (appelée par `Recherche_Si_Envoi_Mail`) | `Outlook.Application` (`CreateItem(0)`, `.Send`) | **`sav@fmc-climatisation.fr`** (fixe) | à chaque ouverture de MenuClimAccess, pour toute intervention `staint=1` avec `rappel24h/48h/72h/rappelsemaine=1` dont `DateDiff("h", dateenvoimail, Now)` > 24/48/72/168 h (si `dateenvoimail` nul → considéré comme il y a 1 an → envoi immédiat) | Objet « Rappel Intervention <site> », corps : Site, Numéro DI Client (`refcliint`), Date Demande (`datheuapp`). Après envoi : `UPDATE intervention SET dateenvoimail=Now`. MsgBox « n Mails de Relance envoyé à sav@… ». |
| `Form_Parametrage.EnvoiMail` | Outlook | `Utilisateur.Mail` | bouton `Commande152` | identifiants web login + mot de passe en clair (§3). |
| `Form__Formulaire1.SendMail2` | `DoCmd.SendObject` (client MAPI par défaut) | paramètre | formulaire de test ; réutilisé par `Form_Intervention` | |

### 5.4 Calculs (`Calcul.vba`)
- `Remplacer(s)` : normalise civilités (« Mr »→« M. », « Melle »→« Mlle », chaîne commençant par « ouv » → vide). Non appelée dans le périmètre (probablement dans des états).
- `EstFerie(date)` : vrai si la date figure dans `joursferies` (comparaison sur `dd/mm/yyyy`). Utilisée par `CalculerHeureLimite` et par les formulaires d'intervention/planification (hors périmètre).
- `CalculerHeureLimite(dateHeure)` — **règle H+8 / délai d'intervention contractuel** (dépannage) :
  - Jours ajoutés selon le jour d'appel : lun→jeu +1, ven +3, sam +2, dim +1.
  - Selon l'heure d'appel : 8h–11h → J+n même heure +1h ; 11h–12h → J+n 14:mm ; 12h–14h → J+n 15:00 ; 14h–16h → J+n même heure +1h ; 16h–17h → J+n+1 (jeudi : +3) 08:mm ; 17h–23h → J+n+1 (jeudi : +3) 09:00 ; 0h–8h → J+n (jeudi : +2) 09:00.
  - Si la date obtenue est fériée → +1 jour (une seule fois).
  - **Les seuls appels trouvés sont commentés** (`Form_Intervention` l.2489, `Form_Intervention2` l.975) : la fonction n'est plus utilisée pour remplir `datheulim`.
- `GenererPlanningPrevisionnel` (appelé par les boutons Planning T1..T4 de MenuPrincipal) : vide la table locale `planning`, la recharge depuis la requête `SiteEntretienPrevuDemixage_datintpre` (numsit + `Semaine 1..52`), puis concatène, pour l'année `Right(parametre.datfin,4)`, les valeurs de `SiteEntretienPrevuDemixage_datint` (dates réalisées) dans les mêmes cellules semaine. Erreurs avalées.
- `DateOnly` / `HeureOnly` : découpage d'une chaîne « date heure » sur l'espace.
- `Verification_Droit_Modif(nom, parIndex)` : autorise la modification d'un statut de facturation si `Kadi_Logge`, ou si `StatutFacture.QueKadi = False` pour ce statut (recherche par `Statut` si `parIndex=True`, par `IndexLigne` sinon — **les commentaires disent l'inverse du code**). Utilisée par les listes d'interventions et `Form_Site` (hors périmètre) : certains statuts de facturation sont **réservés à Kadi**.

### 5.5 Heartbeat « banane » (`PDFCE.UpdateFichierBanane(fonction)`)
- Écrit `C:\Users\Public\<AAAA>\<M>\FichierVieAccess.txt` (crée les dossiers). Fonction 0 « Normal » : si le fichier n'existe pas, écrit `<Now>:Je suis Vivant!` ; 1 « Arrêt » : supprime puis écrit `<Now>:Arret Scrutation` ; 2 « Redémarrage » : supprime puis réécrit « Je suis Vivant! ». Appelé au démarrage et toutes les ~6 s par le timer de MenuClimAccess, et avec 1 par les filtres de listes (hors périmètre). Sert probablement à un superviseur externe (le batch `KillAutoAccess`) pour détecter un Access figé.

### 5.6 Demandes web (`Form_MenuClimAccess.TraiteDemandeWeb`)
- Toutes les ~2 s : `SELECT * FROM Demande_Web WHERE NumUser=<NumGestEnCours>`. Si aucune ligne → `RegardeDemandeWeb=-1` (on n'interroge plus). Si `Type_Demande<>0` : `Case 1` → ouvre le formulaire **`Site`** filtré `cptsit=Data2` (l'ouverture de l'intervention `Data1` est commentée), puis remet la ligne à zéro (`Type_Demande=0, Data1=0, Data2=0, Data3=''`). → Un autre système (site web/tablette) peut **piloter l'ouverture d'un écran Access** pour un gestionnaire.

### 5.7 Autres
- `Parcourir.AfficheDossierWindows(nom)` : extrait le chemin réseau d'une valeur au format `…#\\serveur\dossier\fichier#` (prend la partie après le dernier `#\\`, retire le `#` final) et lance `explorer.exe /Select,<chemin>`. Utilisé par les listes de devis (`NomFichierDevis`). Déclarations API `GetOpenFileName` commentées (non 64 bits).
- `ClasseTech` : classe « technicien » avec `Nom`, `Prenom` et un tableau `TabHeure(1..53 semaines, 1..7 jours)` d'heures (passé à 53 semaines le 03/01/2025 « car oui ça arrive »). Instanciée par `Form_Intervention` pour cumuler les heures par technicien/semaine (numéro de semaine ISO, lundi, `vbFirstFourDays`). La propriété `TabHeure` Let contient un appel `CheckItem` inexistant (jamais utilisé).
- `Module1` : globales `GDatPreInt` (date prévue, utilisée par `PlanificationEntretien`) et `GformulaireParent` (formulaire appelant : « MenuPrincipal » / « site », pilote les Requery après changement de statut).
- `Parcourir.GNumclient` : globale déclarée, non utilisée ailleurs.

---

## 6. Règles métier découvertes

1. **Accès sans mot de passe** : la « connexion » est un simple choix dans une liste de gestionnaires (`typuti=1`, `codintuti<>""`, `numsoc<>1`). Aucun contrôle d'identité. Les boutons sont masqués tant qu'aucun gestionnaire n'est choisi (`Affiche_BP`).
2. **Perte de session** : si la globale `NumGestEnCours` retombe à 0 (plantage VBA), l'utilisateur est déconnecté avec message et doit se re-choisir (`Logout`).
3. **Droits nominatifs codés en dur** : numuti **65** (« FM », référence pour le mot de passe super-gestionnaire) et **66** (Pierre) voient « Voir Tables » ; numuti **367** (Kadi) seul peut s'identifier « Kadi » et modifier les statuts de facturation `QueKadi=1` et décocher « Ne plus intervenir ».
4. **Cycle de vie intervention lu dans les filtres du menu** : `staint<9` = non clôturée/en cours ; `staint=9` = réalisée à valider (les anciens menus l'appellent « clôturée ») ; `staint=7` = clôturée (menu récent) ; `staint=-1` = matériel à commander ; `staint=2` = attente matériel (menu récent) ; `staint=1` = à planifier ; `staint=17` = ne plus intervenir (posé par `Form_Site` sur les interventions `-1/1/9` du site, réversible vers 1 par Kadi) ; `staint=8` = annulée avec accord client (exclue des statistiques) ; `staint=10` = résolue par téléphone (`chkprediagres`, facturable `intfac=True`, `datint=aujourd'hui`).
5. **Import d'entretiens** : une intervention importée est créée en `typint=1`, `staint=1` et n'est pas dupliquée si une intervention d'entretien existe déjà pour le même site à la même `datheulim` (`ImportExcel.ImportSiteIntervention`). L'import est **tout ou rien** sur les référentiels (zone, donneur, intervenant, client doivent préexister).
6. **Alertes parc automobile** (`Alerte_Voitures`, véhicules `EtatVehicule ∉ {4,5}`) : contrôle technique en alerte si > 24 mois depuis le dernier `TypeEv=3` ; contrôle complémentaire si > 12 mois depuis le plus récent de (dernier CC `TypeEv=4`, dernier CT) ; révision si `km_max_relevé (TypeEv 1 ou 5) − km_dernière_révision (TypeEv 2) > Km_Inter_Revision`, sinon si écart en mois entre dernier relevé et dernière révision > `Temps_Mois_Inter_Revision` ; leasing si `Leasing` et (`Now > Date_Fin_Leasing`, ou à défaut mois depuis `DateMiseCirculation` > `Temps_Mois_Leasing`) ; garantie si `Garantie` et mois depuis mise en circulation > `Temps_Mois_Garantie`. Les dates au format `yyyy-mm-dd` sont reformatées (`MiseFormeDateLecture`, qui **tronque l'année à 2 chiffres**).
7. **Conversion saisie opérateur** (`Form_Parametrage.Commande173`) : les lignes `HeuresTech` de `TypeInterv=60` dont `NomInterv` est de la forme `…:<IMMAT>=<KM>` sont converties en `EvVehicules(TypeEV=0, Km, conducteur=Numerotech, Immat)`. Pas de dédoublonnage (rejouable → doublons).
8. **Relances SAV automatiques** : toute intervention `staint=1` avec un drapeau `rappel24h/48h/72h/rappelsemaine` génère un mail interne à `sav@fmc-climatisation.fr` dès que le délai depuis le dernier mail est dépassé ; le premier envoi est immédiat (`dateenvoimail` nul).
9. **Statut de facturation dérivé** (hors périmètre, `Form_InterventionEntretien.staint_AfterUpdate`) : `nbrappint = staint − 1` si `staint<9`. `nbrappint` = index de `StatutFacture` (commentaire MenuClimAccess « nbrappint=type facturation »). `nbrappint=8` = à valider par le patron (Fabien), `9` = stand-by, `1` = à facturer.
10. **Certificat d'étanchéité (CE)** : un PDF par matériel non encore édité de l'année, uniquement pour les gaz HCFC/HFC/« HF0 », avec quantité, GWP, marque, n° de série et référence obligatoires (§5.2).
11. **Mots de passe web** : générés dans `codintuti` (`RandomCode`, 8 caractères), login `p.nom`, envoyés en clair par Outlook ; réservés aux sociétés 111/112/113 (et 1 pour la MAJ login).
12. **Périmètre client Armand Thierry** : `numcli=1` ; filtres H/F/mixte (`typsit`) et annuaire spécifiques ; Celio = `numcli=4` ; migration Celio historique `numcli=188`.
13. **Type de magasin** : `typsit` ∈ {`H`, `F`, `M`, `H et F`} (deux conventions coexistent : `IN ('H','M')` vs `IN ('H','H et F')`).
14. **Planning prévisionnel** : les états T1..T4 régénèrent systématiquement la table `planning` (52 colonnes semaine) à partir de deux requêtes de « démixage » avant affichage.
15. **Statuts/types référentiels protégés** : les tables `StatutFacture`, `StatusInterv`, `TypeInterv` ne sont modifiables qu'après mot de passe du jour, et « ordre=-1 » masque une valeur des listes déroulantes.

---

## 7. Codes et libellés

### 7.1 `Intervention.staint` (→ `StatusInterv.IndexLigne`)
| Valeur | Libellé (liste `cboStatut`, `forms/Form_38_ListeInterventionGenerale.txt` et `Report_0…`) | Confirmation dans le code |
|---|---|---|
| -1 | Matériel à commander | `MenuClimAccess.MAJBubule` (`staint=-1` → « Nombre de Materiel à commander ») ; `ChargementListeInter "ACommander"` |
| 1 | A planifier | `ImportExcel.ImportSiteIntervention` (commentaire « statut 'à planifier' ») ; relances `staint=1` |
| 2 | Planifiée (ancienne liste) / **Attente matériel** (usage MenuClimAccess `lblNotifMatosAttente`, `"AttenteMatos"`) | **contradiction entre libellé historique et usage actuel — à trancher avec FMC** |
| 3 | Attente de matériel (ancienne liste, absente de la liste actuelle) | non utilisé dans le périmètre |
| 4 | En cours | `Form_Intervention.MajIcone` (4/5 « icône vide ») |
| 5 | En cours chez le sous-traitant | idem |
| 6 | Effectuée en attente retour fiche intervention | `Form_Intervention.MajIcone` (« ni clôturée ni effectuée en attente retour ») |
| 7 | Clôturée | `MAJBubule` duplicata `staint=7 and devisafaire` ; `Form_Intervention.staint_AfterUpdate` (ajout heures si 7) |
| 8 | Annulée avec accord client | `Form_00 - Statistiques Clients` l.317 « staint=8 Annulé par le client » |
| 9 | Réalisée - à valider | `MAJBubule` « Nombre d'interventions à valider » ; `MenuPrincipal` l'utilise comme « clôturée » (`staint=9` lecture seule) → sémantique historique |
| 10 | Résolue par téléphone | `Form_Intervention.chkprediagres_AfterUpdate` ; stats « NbDepan_Tel » |
| 17 | Ne plus intervenir | `Form_Site.Gestion_Ne_Pas_Intervenir` (l.246-250) |

### 7.2 `Intervention.typint` (nvarchar → `TypeInterv.IndexLigneSTRING`)
| Valeur | Libellé (listes `forms/Form_72…`, `Form_9…`) | Usage dans le périmètre |
|---|---|---|
| 1 | Entretien | `MenuPrincipal` entretien (`typint='1' or '6' or '7'`), import, bulle bleue « Maintenances » |
| 2 | Dépannage | `MenuPrincipal` « Dépannage palliatif » (`'2' or '3'`), H+8, facturable ; bulle verte |
| 3 | Devis accepté | bulle rouge « Devis SAV accepté » ; `"SuiteDevis"` → cboTypeIntervention=3 |
| 4 | Autre | `MenuPrincipal` le traite comme « Dépannage curatif/correctif » (`'4' or '5'`) — **incohérence libellé/usage** |
| 5 | En travaux | bulle orange « En travaux » ; idem menu curatif |
| 6 | En création | regroupé avec entretien dans `MenuPrincipal` |
| 7 | Désenfumage | regroupé avec entretien dans `MenuPrincipal` |
| 8 | Inter. réalisée en attente devis signé client | liste seulement |
| 9 | Audit | liste seulement |
| 14 | ? | `Form_Intervention` l.2198 (`Me.typint = 14`), libellé non trouvé |

### 7.3 `Intervention.nbrappint` (statut de facturation → `StatutFacture.IndexLigne`)
| Valeur | Signification déduite | Source |
|---|---|---|
| 1 | À facturer | `ChargementListeInter "AFacturer"` → `StatutFact=1` ; bulles par type (`nbrappint=1 or 2`) |
| 2 | (second statut facturable, libellé inconnu) | bulles |
| 8 | À valider par le Boss / Fabien | `MAJBubule` `nbrappint=8` → `lblNotificationBoss` ; `"AvaliderFabien"` |
| 9 | Stand By | `MAJBubule` `nbrappint=9` → `lblNotificationStandby` |
| `QueKadi=1` | statut réservé à Kadi | `Calcul.Verification_Droit_Modif` |

### 7.4 `Devis*.StatutDevis` (tinyint, défaut 1)
Liste actuelle (`Form_DevisListe.Détail_Paint` commentaire, `forms/Form_57_Devis.txt`) : **1 Devis à viser** (jaune) ; **2 Aucun Retour Client** (ancienne liste : « Visé, à envoyer ») ; **3 Devis annulé et remplacé par** (bleu) ; **4 Envoyé** ; **5 Devis refusé par le client** (gris) ; **6 Devis accepté par le client** (rouge ; posé par `DevisListe*` à la création d'une intervention « devis accepté »). Ancienne liste à 5 valeurs (`Form_56_Devis.txt`) : 3 Envoyé, 4 Accepté — attention aux données historiques (`Form_DevisListe*` cherche encore `StatutDevis=4` pour le PDF « accepté »).
`Intervention.stadev` : colonne existante, **aucune règle trouvée dans le périmètre**.

### 7.5 `Utilisateur.typuti`
1 Gestionnaire ; 2 Technicien ; 3 Gestionnaire(Tech) (§1.3).

### 7.6 Autres codes rencontrés
- `Vehicules.EtatVehicule` : 4 = vendu (`ListeTables.CheckVendu`), 5 = autre état exclu des alertes (libellés dans `ListeEtatVehicule`).
- `EvVehicules.TypeEv` : 0 = saisie opérateur convertie, 1 et 5 = relevé km, 2 = révision, 3 = contrôle technique, 4 = contrôle complémentaire (`Alerte_Voitures`).
- `HeuresTech.TypeInterv = 60` : saisie kilométrage opérateur.
- `TypeFluide.Type` → `Liste_Type_Gaz.id` ; libellés attendus `HCFC`, `HFC`, `HF0`.
- `Site.indclitec` : 1 réalisé / 2 connu / 3 à auditer / 4 modifié par Clim'Tech (liste MenuPrincipal).
- `Site.typsit` : H, F, M / « H et F ».
- `Demande_Web.Type_Demande` : 0 rien, 1 ouvrir un site (`Data2 = cptsit`).
- `numcli` : 1 Armand Thierry, 4 Celio, 188 Celio (migration). `numsoc` : 1, 111, 112, 113 = FMC. `numuti` : 65 FM, 66 Pierre, 367 Kadi.

---

## 8. Dépendances externes

| Type | Valeur | Où |
|---|---|---|
| ODBC | DSN `CLIMACCESS`, base `logiclim`, UID `climaccess`, PWD `[mot de passe codé en dur]` | `MenuClimAccess.RefreshTableLinks` (à chaque ouverture) |
| Chaîne SQL alternative | `Data Source=serveur;Initial Catalog=logiclim;User Id=abrminfo;Password=[…]` | `MenuPrincipal.CmdRelinkTables` |
| Batch | `C:\users\public\KillAutoAccess\StartKillAuto.bat` | démarrage MenuClimAccess |
| Fichier heartbeat | `C:\Users\Public\<AAAA>\<M>\FichierVieAccess.txt` | `PDFCE.UpdateFichierBanane` |
| Excel modèle réseau | `\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Audit.xlsx` | `ImportExcel.Exporter_Audit` |
| Excel import | `c:\temp\import.xlsx` (feuille `IMPORT`) | `ImportExcel.ImportSiteIntervention` |
| Excel annuaires | `\\serveur\Logiclim\annuaireAT.xls`, `\\serveur\Logiclim\annuaireCELIO.xls` (libellés des boutons ; tables `annuaire`, `LISTING`) | macros `ImportAnnuaireAT/CELIO` |
| Documents devis / site | chemins réseau au format `#\\serveur\…#` dans `Site.chemindoc`, `Devis.NomFichierDevis` | `Parcourir.AfficheDossierWindows`, `PDFCE.Creation_PDF_CE` |
| Automation | `Excel.Application` (imports/exports), `Outlook.Application` (mails), `Scripting.FileSystemObject`, `Scripting.Dictionary`, `Microsoft.XMLDOM`, `ADODB` + `Microsoft.ACE.OLEDB.12.0`, `Office FileDialog` | divers |
| Web | `http://maps.googleapis.com/maps/api/geocode/xml` (sans clé) ; `https://intervention.fmc-maintenance.fr/interventionstest/Default.aspx?q=1` (portail techniciens, URL « test ») | `Geocoding`, `Parametrage.EnvoiMail` |
| E-mail | `sav@fmc-climatisation.fr` | relances |
| Programme externe | « Programme de Fabien » pour les jours fériés des utilisateurs | `Form_Utilisateur sous-formulaire` |
| Autres applis sur la base | tablette/mobile (`FiltreClimAccessMobile`, signatures), site web (`Demande_Web`, `HistoCnx`, `ClientCredential`, `HeuresTech` saisie opérateur, push/pull des bons) | §5.6, §4.3 |
| Windows | `explorer.exe /Select`, barre d'outils Access `CLIM'TECH Formulaire`, imprimantes nommées dans les extraits (Canon iR C2880, XPS) | |
| États Access | `Test Cerfa` (CE), `137 - …`, `137bis - …`, `TopTen`, `FlopTen`, `RépertoireTechnique`, `Listes des interventions en cours`, `SiteEntretienPrevu*`, `ListeIntervention*`, séries 01-136 | MenuPrincipal / PDFCE / Zone Geographique |

---

## 9. Points d'incertitude

1. **Sémantique de `staint=2`** : « Planifiée » (liste historique) vs « Attente matériel » (menu 2023). De même `staint=9` : « Réalisée - à valider » aujourd'hui, mais traité comme « clôturée » dans tout `MenuPrincipal` (`staint<9` = en cours). Le sens de `staint=3` et la présence de deux notions de clôture (7 et 9) doivent être confirmés avec FMC ; la table `StatusInterv` (non exportée en données) donnera les libellés officiels.
2. **`typint` 4/5** : libellés « Autre » / « En travaux » mais `MenuPrincipal` les nomme « Dépannage curatif/correctif ». Le menu Clim'Tech semble obsolète. `typint=14` inconnu.
3. **Vue `ListeInterventionGenerale2`** (base des compteurs) et les requêtes `SiteEntretienPrevuDemixage_*`, `RequeteTopTen/FlopTen` : définitions non disponibles (export `sql_modules.sql` vide).
4. **Table `parametre`** : `MenuPrincipal.Form_Load` référence `numpar`, absent du schéma SQL Server → table locale Access ou code mort.
5. **`Societe.numsoc = 1`** : exclu de la connexion mais inclus dans « utilisateurs FMC » : identité de cette société à confirmer (Clim'Tech ?).
6. **Marquage `CE_EDITE`** : jamais mis à jour dans `PDFCE` ; où est-il positionné ?
7. **`StartKillAuto.bat`**, « Programme de Fabien », superviseur lisant `FichierVieAccess.txt` : programmes externes non fournis.
8. **Géocodage Google sans clé HTTP** : probablement hors service ; vérifier si les coordonnées des sites sont encore mises à jour.
9. **Gestion des demandes web** : seul `Type_Demande=1` est traité ; qui écrit dans `Demande_Web` (portail ?) et existe-t-il d'autres types ?
10. **`CalculerHeureLimite`** : règle H+8 documentée mais plus appelée (appels commentés) — `datheulim` est-il saisi manuellement ou calculé par une autre appli ?
11. **Bogues probables à ne pas reproduire** : export audit limité à ~14 lignes ; comparaison « FAUX » ; imports sans dédoublonnage ; `CmdRelinkTables` avec chaîne non ODBC ; `Cmd97` ouvrant l'état 96 ; `Verification_Droit_Modif` (commentaires inversés) ; `MiseFormeDateLecture` année sur 2 chiffres.
12. **Sécurité** : identifiants SQL Server en clair dans le VBA, mots de passe applicatifs en dur ou dérivés de la date, mots de passe web stockés (`codintuti`, `mdputi`) et envoyés en clair — à remplacer intégralement dans la cible (Supabase Auth, rôles).
