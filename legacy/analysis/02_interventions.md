# B — Cycle de vie d'une INTERVENTION (ClimAccess / FMC)

Compte rendu fonctionnel établi à partir du code VBA décompilé (`out/vba/*.vba`), des libellés de contrôles extraits des formulaires/états (`out/forms/*.txt`), des requêtes Access (`out/queries/*.sql`) et du schéma SQL Server (`legacy/schema.sql`, table `dbo.Intervention`, 85 colonnes + `RV`).

Conventions de citation : `[Module.Procédure]`. Les libellés d'écran cités proviennent du dump du formulaire `Intervention` (`forms/Form_66_numintint_406889.txt`, version courante) et de sa version ancienne (`forms/Form_9_numintint_339710.txt`). Quand un libellé n'existe que dans une liste de valeurs figée dans un formulaire ou une requête, la source est indiquée.

Remarque générale importante : la table `Intervention` n'a pratiquement pas évolué structurellement ; en revanche **une douzaine de colonnes ont été "recyclées"** (le nom SQL ne correspond plus au sens métier). La correspondance nom-colonne → sens réel est donnée au §3.4 et au §11 ; elle est indispensable pour la migration.

---

## 1. Qu'est-ce qu'une intervention

Une ligne de `dbo.Intervention` représente une **demande d'intervention** (DI) sur un **site** (`cptsit` → `Site`, FK déclarée), pour un **client** (déduit via `Site.numcli`; le formulaire affiche `LstClient` puis filtre `lstSite` sur ce client — `forms/Form_66` lignes 33-46), confiée à un **intervenant** (`codint` → `Intervenant.codint`, FK déclarée ; `"FMC"` = réalisée en interne, toute autre valeur = sous-traitant — `[Form_Intervention.codint_AfterUpdate]`), avec éventuellement un **contact** client (`codcon` → `Contact`, liste filtrée sur le client — `Form_66` l.77-78), un **chargé d'affaire référent** (`traitepar` → `Utilisateur.numuti`, typuti=1 — `Form_66` l.112-117), un **technicien prévu** (`numutipre` → `Utilisateur` typuti=2 dont `nomsocuti = codint` — `Form_66` l.128-130) et N **techniciens intervenus** (table `InterventionTechnicien.numuti`, sous-formulaire `InterventionTechnicien`, liste = utilisateurs typuti=2 de la société `codint` — `forms/Form_55_InterventionTechnicien.txt`).

Un même site enchaîne des interventions d'entretien planifiées (générées automatiquement) et des interventions ponctuelles (dépannage, travaux selon devis, etc.).

### 1.1 Type d'intervention `typint` (nvarchar(50), défaut `'1'`)

Le champ est **texte** en base mais manipulé comme entier (`Me.typint = 14`, `Select Case typint`). Référentiel `dbo.TypeInterv` (`IndexLigne`, `TypeInter`, `OrdreAffichage` (-1 = masqué), `IndexLigneSTRING` = copie texte de l'index utilisée pour les jointures — `forms/Form_109_dbo_typeInterv.txt`). Le contenu de la table n'a pas été exporté ; les libellés ci-dessous sont déduits du code et des listes de valeurs figées.

| typint | Libellé (source) | Couleur du fond formulaire | Remarques |
|---|---|---|---|
| 1 | Entretien (`[Form_Intervention.GetNomOp]`, `[ColoreFenetre]` : « ENTRETIEN ») ; « Maintenance » dans `[Form_MenuClimAccess.ImgIntervention_Click]` → en fait typint 2, voir §8 | bleu clair RGB(209,234,240) | Visites périodiques générées automatiquement ; seul type déclenchant `SiteMAJRegistre` |
| 2 | Dépannage | vert RGB(204,255,204) | |
| 3 | Devis accepté / « Devis SAV » (`ColoreFenetre`) / « Suite à devis » (`forms/Report_0`) / « TRAVAUX SELON DEVIS » (`queries/EXPORT-MODELE.sql`) | rose RGB(255,204,204) | Créé depuis `DevisListe.cmdGenerer` et `DevisListeContratDeMaintenance.cmdGenerer` |
| 4 | Autre | rose | Fax « Curatif » pour ce type (`[Form_Intervention.CmdImprimerFax_Click]`) ; MenuPrincipal regroupe 4 et 5 sous « Dépannage curatif » |
| 5 | En travaux | orange RGB(255,226,198) | Créé depuis `DevisListeTravaux.cmdGenerer` (devis travaux) |
| 6 | En création | violet clair RGB(255,230,255) | MenuPrincipal le range avec 1 et 7 (famille entretien) |
| 7 | Désenfumage | violet clair | |
| 8 | Inter. réalisée en attente devis signé client | violet clair | |
| 9 | Audit | rose | Marqueur noir sur la carte (`forms/Form_38`) |
| 12 | Devis SAV (TR) (`ColoreFenetre`, ajouté 10/11/25) | rose | Sens de « TR » non documenté (travaux ? tiers ?) |
| 13 | Maint. Chaudière (ajouté 10/11/25) | bleu clair | |
| 14 | Appel Résolu Par Téléphone (ajouté 20/10/25) | rose | Créé automatiquement par l'ouverture avec argument `ResTel` (§2.3) |

Familles utilisées par l'ancien menu `[Form_MenuPrincipal]` : (1,6,7) = « interventions d'entretien » (ouvre `InterventionEntretien`), (2,3) = « dépannage / suite à devis », (4,5) = « dépannage curatif ».

### 1.2 Nature d'intervention `natureintervention` (tinyint)

Liste de valeurs figée dans le formulaire : `1;Visite Technique;2;Visite Filtres;3;Visite Maintenance Général` (`Form_66` l.70-75). Valeur par défaut **3** posée à chaque sélection de site (`[Form_Intervention.cptsit_AfterUpdate]`, commentaire : « Technique par défaut (Sésar a aussi un type d'intervention : Filtres) »). Utilisée dans le mail « Fin d'intervention » (`[BtcMailClient_Click]` : « Pour » + libellé).

### 1.3 Sous-type

Combo « Sous-Type » (`Modifiable347`, `Form_66` l.107-111) bound à la colonne **`imprimeepar`** (recyclée), liste `dbo_SousType (id, SousType)`. Le filtre « SousType Vide » de la liste générale teste `Interv.imprimeepar is null` (`[Form_ListeInterventionGenerale.Filtre_OM_Test]`). Contenu de `SousType` non exporté.

### 1.4 Panne

`codpan` → `Panne` (FK). Libellés imprimés sur la fiche ancienne (`forms/Report_3`) : 01 PB. SUR ORGANES ELEC., 02 PB. SUR ORGANES FRIGO., 03 PB. DE REGULATION, 04 FUITE(S) D'EAU CONDENSATS, 05 MAUVAISE UTILISATION, 06 PB. D'ALIMENTATION ELEC., 07 ENTRETIEN SUPPLEMENTAIRE, 08 PB. D'ALIMENTATION HYDRO., 09 AUTRES "DEFAUT MATERIEL", 10 P.O. (PORTE OUVERTE A L'ARRIVEE), 11 REARMEMENT DI, 12 AUGMENTER FREQUENCE VISITES, 13 AUTRES ORIGINES EXTERNES, 14 PB. AERAULIQUE. La valeur **41** est utilisée comme « panne vide » (`[Form_Intervention.PartieSuivante]` : « Forcé à 41 car c'est un texte vide → on ne peut pas mettre 0 car il y a une liaison de table »). `pannoncli` = « Panne d'origine externe ». Le matériel en panne est rattaché via `PanneMaterielSite(numintint, numsitmarref)` (double-clic sur `ListeMateriel` ou bouton `Commande131` ; suppression dans `[Form_SfMaterielPanne.Commande11_Click]` après confirmation « Voulez vous supprimer cette enregistrement ? »).

---

## 2. Cycle de vie complet

### 2.1 Statuts `staint` (int)

Référentiel `dbo.StatusInterv (IndexLigne, StatutInter, OrdreAffichage)` ; les combos n'affichent que `OrdreAffichage > 0` (`Form_66` l.139). Contenu non exporté ; libellés reconstitués :

| staint | Libellé | Source du libellé | Usage dans le code |
|---|---|---|---|
| -1 | Matériel à commander (liste courante) / « Matériel en attente » (`EXPORT-MODELE`) | `forms/Form_38` cboStatut | Bulle « Materiel a commander » `[Form_MenuClimAccess.MAJBubule]` (`staint=-1`) ; menu `ACommander` → `cboStatut=-1` ; inclus dans « Ne pas intervenir » (§2.4) |
| 1 | A planifier | toutes listes | Statut initial de toute création (`Form_Load`, générations, devis, import) ; déclôture ; rappels mails ne ciblent que `staint=1` |
| 2 | Planifiée (anciennes listes) — **réutilisé comme « Attente de matériel »** | `Report_0`/`Form_9` vs `[MAJBubule]` commentaire « Materiel en attente » (`staint=2`) et menu `AttenteMatos` → `cboStatut=2` | `RechercheIntervention` traite 2 comme « clôturée » (codes IEC/IDC/IDCC) → héritage |
| 3 | Attente de matériel (anciennes listes seulement) | `Report_0`, `Form_9` | plus dans la liste courante |
| 4 | En cours (anciennes listes) | `Report_0`, `Form_9` | `[Form_PlanificationEntretien]` l.947 compte les visites faites avec `staint=4` (incohérent avec l.456 qui utilise 9) ; `MajIcone` vide l'icône pour 4/5 |
| 5 | En cours chez le sous-traitant / « En cours » (`EXPORT-MODELE`) | `Form_38` | |
| 6 | Effectuée en attente retour fiche intervention | `Form_38` | `MajIcone` : icône « dossier » sur l'onglet clôture ; onglets devis visibles si `devisafaire/devisfait` |
| 7 | Clôturée | `Form_38` | Statut final « archivé » : masqué par défaut (`ChkShowArchived`), déclenche `AjoutHeures` (§4.3), bloqué sans `cheficdemint` (§2.2) ; liste Duplicata = `staint=7 and devisafaire` |
| 8 | Annulée avec accord client | `Form_38` ; `[Form_00 - Statistiques Clients]` l.317 « staint=8 Annulé par le client » | exclu des comptages d'entretien ; compté comme « refus » en stats |
| 9 | Réalisée - à valider | `Form_38`, `EXPORT-MODELE` | Posé par le bouton **« Clôturer l'intervention »** ; bulle principale du menu (`staint=9`) ; menu `AValider` ; ancien menu et `Form_43` le nomment « Clôturée » (héritage) ; utilisé pour compter les visites d'entretien « déjà faites » |
| 10 | Résolue par téléphone | `Form_38` | Posé par la case « Résolu » (`chkprediagres`) ; affiche « Nb Minutes passées » ; stats comptent `NbDepan_Tel` |
| 17 | (pas de libellé trouvé) — **« Ne pas intervenir »** | `[Form_Site.Gestion_Ne_Pas_Intervenir]` : bascule -1/1/9 → 17 et 17 → 1 ; `[Form_Planification.Commande125_Click]` « Forcage à ne pas intervenir » ; `[Form_ListeSiteGenerale]` l.31 | Gel des interventions d'un site fermé/à ne pas visiter |
| 20 | (aucun libellé, aucune écriture trouvée) | requêtes `Site Sous-formulaire sous-formulaire (2)` : traité comme statut terminal (7,8,10,20) | Inconnu |

Statuts 11-16 : **aucune occurrence** dans le code.

### 2.2 Transitions codées

| Transition | Où / bouton | Condition / effet |
|---|---|---|
| (création) → 1 | `[Form_Intervention.Form_Load]` si `staint` vide ; toutes générations (`Form_Site`, `PlanificationEntretien`, `Planification`, `ImportExcel`, `DevisListe*`, `CmdCloturerIntervention` replanification, `InterventionEntretien.CmdNouvelleIntervention`) | `Planification.Commande125` met 17 si `majregistresecuritefait <> "FAUX"` (colonne site recyclée en « ne pas intervenir ») |
| (création) → 10 | `Form_Load` avec `OpenArgs` = `cptsit;numcli;numintervenant;ResTel` (appel depuis `[Form_Site]` l.666, bouton dédié) | pose aussi `typint=14`, `codint="FMC"`, `datheulim` = dernier jour du mois courant (`DateSerial(Year, Month+1, 0)`), `refcliint="Appel du dd/mm/yy"`, coche `chkprediagres` |
| x → 10 | case « Résolu » (`chkprediagres`) cochée `[chkprediagres_AfterUpdate]` | `intfac=True` (« faite et non facturable »), `datint=aujourd'hui`, affiche `NbMinTel`. Décochée : `staint=1`, `intfac=False`, `datint=""`. (Dans `Form_Intervention2` la même case met **7**.) |
| x → 9 | bouton **« Clôturer l'intervention »** `[CmdCloturerIntervention_Click]` après MsgBox « Est-vous sûr de vouloir clôturer cette intervention ? » | `UPDATE Intervention SET staint=9` direct (pas de contrôle de type ni de champ) ; **puis replanification automatique des entretiens** (§2.5) |
| 9/x → 1 | bouton **« Déclôturer l'intervention »** `[CmdDecloturer_Click]` « Est-vous sûr de vouloir déclôturer… » | `UPDATE … staint=1` |
| x → 7 | saisie manuelle dans la combo Statut | `[staint_BeforeUpdate]` refuse si `cheficdemint=""` : « La demande ne peut pas être clôturée s'il n'y a pas de fichier associé. » (le bon d'intervention PDF doit avoir été généré). `[staint_AfterUpdate]` : si 7 → `AjoutHeures` (pointage `HeuresTechAuto`) ; `MajIcone` |
| -1/1/9 ↔ 17 | `[Form_Site.Gestion_Ne_Pas_Intervenir]` (case « ne pas intervenir » du site, réservée à un utilisateur loggué : « Attention, Vous n'etes pas autorisé a faire cette modification ») | mise à jour en masse de toutes les interventions du site |
| tout autre changement | combo Statut, libre | `[Form_InterventionEntretien.staint_AfterUpdate]` (ancien écran) : si `staint<9` alors `nbrappint = staint-1` (héritage : nbrappint = nombre de rappels ; aujourd'hui nbrappint = statut de facturation, §7) |

Aucune table d'historique n'est alimentée par le VBA (`Intervention_Status_Changed_history` ne contient que `numintint` — probablement trigger SQL, hors périmètre Access).

### 2.3 Schéma texte du workflow

```
                 Sources de création (staint=1, sauf mention)
   ┌──────────────────────────────────────────────────────────────────────┐
   │ Liste générale "Nouvelle intervention" (acFormAdd)                    │
   │ Site → bouton nouvelle inter (cptsit;numcli;numintervenant)           │
   │ Site → "Appel résolu par tél" (…;ResTel) → typint 14, staint 10       │
   │ Devis accepté (DevisListe → typint 3, DevisListeTravaux → typint 5)   │
   │ Génération visites d'entretien (Site, PlanificationEntretien,         │
   │   Planification T1..T12 [staint 1 ou 17], ImportExcel, clôture auto)  │
   │ "Nouvelle intervention" (duplication) / "Creation Inter Partie Suivante"│
   └──────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
      ┌───────────── 17 Ne pas intervenir ◄──┐ (site gelé)
      │                                      │
      ▼                                      │
   1 A planifier ──────────────────────────► -1 Matériel à commander
      │  ▲                                    2 Attente de matériel
      │  │ Déclôturer                         5 En cours chez le sous-traitant
      │  │                                    (saisie libre dans la combo)
      │  │        [rappels mail 24h/48h/72h/semaine tant que staint=1]
      │  │
      │  ├──── case "Résolu" ───────────────► 10 Résolue par téléphone
      │  │                                     (intfac=1, datint=jour, minutes tél.)
      │  │
      ▼  │
   Bouton "Clôturer l'intervention"
      │
      ▼
   9 Réalisée - à valider  ── (déclenche la replanification des entretiens du site)
      │        └── bulle "à valider" du menu, liste AValider
      │
      ▼  saisie combo (contrôle : PDF du bon généré = cheficdemint renseigné)
   6 Effectuée en attente retour fiche intervention  (optionnel)
      │
      ▼
   7 Clôturée ── AjoutHeures → HeuresTechAuto ; masquée des listes sauf "Afficher les clôturées"
      │             └── si devisafaire : file "Duplicata / devis à faire"
      │
   8 Annulée avec accord client (saisie libre, exclue des stats d'entretien)

   En parallèle, indépendamment du statut :
   - facturation : nbrappint (statut facturation) ; intfac / intfactok / mntfmc / mntst
   - devis : devisafaire → devisfait | devisanepasfaire ; urgence (devisepar), duplicata (stadev, duplicatafait)
   - contrôle d'étanchéité : bouton "n CE à Editer" → Cerfa PDF, SiteMateriel.CE_EDITE=1
```

### 2.4 Champs « par qui / quand » — sens réel

| Colonne | Sens d'origine (ancien écran `Form_9`) | Sens actuel (écran `Form_66`) | Alimentation |
|---|---|---|---|
| `traitepar` | Traité par | « Chargé d'affaire référent » (Utilisateur typuti=1 avec `codintuti<>""`) | auto = utilisateur connecté `NumGestEnCours` à l'ouverture en création (`[Form_Load]`, 20/10/25) ; sinon saisie |
| `saisiepar` | Saisie par (bloc clôture) | idem | saisie manuelle ; forcé à 0 dans `PartieSuivante` |
| `imprimeepar` | Imprimée par | **Sous-Type** (`dbo_SousType`) | saisie |
| `classeepar` | Classée par | non affiché | jamais alimenté par le VBA |
| `prediagpar` | Pré-diagnostic tél. effectué par | « Effectué par » du cadre « Pré-Diagnostic Telephone » | saisie ; `[prediagpar_AfterUpdate]` écrit l'horodatage « dd/mm/yy à hh:mm » dans `TextePreDiag` = colonne **`numerocommande`** (recyclée) |
| `prediagres` | Résolu (pré-diag) | case « Résolu » | voir transition → 10 |
| `envoisoustraitantpar` | Envoi au sous-traitant par | idem (typuti=1) | saisie ; visible seulement si `codint<>"FMC"` |
| `numerodemandesoustraitant` | N° demande du sous-traitant | idem | saisie ; recopié dans la fiche Excel |
| `retourficheinterventionpar` | Retour fiche par | **« Nb Minutes passées »** au téléphone (`NbMinTel`, General Number) | saisie obligatoire si visible (`staint=10`) : « Merci de bien vouloir renseigner les minutes passées au téléphone » `[VerifDatHeuLim]` ; sommé dans la liste générale (« Temps Total Telephone ») |
| `datefintech` | — | « Retour fiche d'intervention » (date/heure, `Texte361`) | jamais écrit par Access → alimenté par l'appli mobile (probable) ; exporté dans « Export Saisie Heures » |
| `devisepar` | Devisé par | **« Urgence Devis »** 1 Faible / 2 Moyenne / 3 Forte | saisie |
| `stadev` | Statut devis | **« Duplicata à traiter par »** (Utilisateur typuti=1, `codintuti<>"" and <>"XX"`) | saisie |
| `duplicatacreepar` | Duplicata créé par | non affiché | forcé 0 dans `PartieSuivante` |
| `duplicatafait` | Impression d'un duplicata (l'ancien `Cocher202_Click` imprimait le fichier `cheficdemint`) | « Traité / Attente offre de prix » | saisie ; comptages Duplicata du menu |
| `creele` / `majle` | horodatage | non affichés | `creele` défaut `getdate()` ; `majle` jamais écrit par le VBA |
| `dateenvoimail` | — | « Date dernier rappel » | `Now` au clic sur une case rappel ; mis à jour par l'envoi automatique (§10) |
| `datesignaturecontrat` | — | « Facturé le : » (liste) / « Date » (bloc Facturation) | auto = aujourd'hui dès que `mntfmc` est modifié (`[mntfmc_Dirty]`) |

### 2.5 Replanification automatique des entretiens à la clôture

`[Form_Intervention.CmdCloturerIntervention_Click]` (code identique dans `Form_Intervention2` et `Form_InterventionEntretien`) — après `staint=9`, **quel que soit le type de l'intervention clôturée** :
1. Lit `Site.nbrentsit` (nombre de visites d'entretien/an ; défaut 4 si site introuvable). `lDernierMois` = 7 si 2 visites, 10 si 4 visites, **0 sinon** (donc aucune génération pour 1, 3, 6… visites).
2. Si `Month(datint) < lDernierMois` : cherche l'intervenant de la zone du site (`ZoneGeographique ⋈ Intervenant.numzonint ⋈ Site.numzonsit`).
3. Si trouvé : `DELETE FROM intervention WHERE datintpre IS NOT NULL AND datint IS NULL AND cptsit=… AND typint='1'` (**supprime toutes les visites d'entretien non réalisées du site**).
4. Dernière date d'entretien réalisé (`max(datint)` typint 1) + `12/nbrentsit` mois → boucle `nbrentsit - (nb visites typint 1 staint 9 datées de l'année)` fois : décale d'un jour si férié (`[Calcul.EstFerie]` via `JoursFeries`), samedi → vendredi, dimanche → lundi ; insère `cptsit, datintpre, typint='1', staint=1, codint, datheuapp=NULL`.
Le label d'erreur `NoCloture` remet `staint=1` mais le `On Error GoTo` est commenté.

`[Form_InterventionEntretien.BtReplanifier_Click]` (« Replanifier les entretiens ») fait un calcul voisin en jours (`365/nbrentsit`) sur l'année civile ; exige `datint` (« Vous devez saisir la date réelle d'intervention. »), message final « La génération des visites d'entretien s'est bien éffectuée. » Bug visible : `If Year(Date) > Year(Date)` toujours faux.

---

## 3. Écran de saisie d'une intervention (`Form_Intervention`)

Titre dynamique « Création et Clôture d'intervention - <TYPE> » et couleur de fond par type `[ColoreFenetre]`. Les formulaires `Intervention2` (copie ancienne, `chkprediagres` → 7, pas de `ResTel`, pas de partie suivante, pas de CE) et `InterventionEntretien` (écran « Interventions d'entretien planifiées », ancienne saisie par fiche `FicheIntervention`, boutons fax vers `ChoixSociete`) sont des versions antérieures encore présentes ; le menu courant `MenuClimAccess` n'ouvre que `Intervention`.

### 3.1 Onglets (`Onglets`, `Form_66`)

0. **Création d'intervention** (« INFORMATIONS DEMANDES D'INTERVENTION ») : Client, Site (Réf. Site / Nom Site / CP-Ville), N° de DI CLIENT (`refcliint`), N° Devis accepté (`numdevacc`), Date demande (`datheuapp`, défaut `=Date()`), Objet demande (`objint`), Nature intervention, Contact, Intervenant, N° demande du sous-traitant, Envoi au sous-traitant par, Directives d'intervention (`dirint`, « demande initiale du client — n'apparaît pas sur le bon d'intervention destiné au client »), Type, Sous-Type, Chargé d'affaire référent, Date limite d'intervention (`datheulim`), Date prévue (`datintpre`), Technicien prévu (`numutipre`), Heure prévue (`heuintpre`), Statut, cadre Pré-Diagnostic Telephone (Effectué par, Résolu, horodatage, Nb Minutes passées), N° de demande interne (`refint`, « apparaît en haut à droite des demandes »), Commentaire interne sur la demande (`comint`, « imprimé sur les documents pour les techniciens »), DI CLIENT (`cheficdemcli`, lien), Commentaire général du site (`comsit`, lecture), bloc **Facturation** (Montant FMC `mntfmc`, Montant Sous-Traitant `mntst`, Différence `=[mntfmc]-[mntst]`, Statut Facturation `nbrappint`, Date `datesignaturecontrat`, Chemin Facture Sous-Traitant = `commajregsec`, Chemin Facture FMC = `sigcli`), rappels auto (24H/48H/72H/Semaine + Date dernier rappel), Nb Heures Vendues (`nbrpagfax`), Heures Chantier (Nb Heures Totales Passées calculé, Année Export, Export Heures Excel), Creer Fiche Excel, MAJ Liste Tech, Creation Inter Partie Suivante, Montant Devis (`mnthtdevpartenaire`), alertes « !!!!!!!!! GARANTIE ENCORE EN COURS !!!!! » et « !!PLUSIEURS INTER CE JOUR!! », Location Nacelle (= `intafact`) → « !!NACELLE LOUEE!! », liste « Liste Sous Traitants Possibles » (cases Climatisation / Chauffage / Autres).
1. **Clôture de l'intervention en cours** (« SAISIE CLOTURE D'INTERVENTION ») : Date réelle d'inter. (`datint`), N° de bon (`numint`), Retour fiche (Original / Copie / Copie dans ordinateur), Audit / Photo / Contrôle d'étanchéité annuel / Contrôle d'étanchéité ponctuel / Mise à jour du registre de sécurité, Technicien(s) intervenu(s) (sous-formulaire), Temps aller / Temps retour / Heure arrivée sur site / Heure de départ du site, Nombre de techniciens (`nbrtecint`), Saisie par, Commentaire interne post intervention (`comintposint`), Prestations réalisées (saisie par un technicien) = `sigsit`, Commentaire (saisie par technicien) = `comtec`, Statut Facturation, Devis à faire / Devis fait / Traité-Attente offre de prix / Devis ne sera pas fait (+ `comdevis`), Commentaire de clôture sur panne (lié au devis à faire) = `sigtec`, Commentaire interne sur le devis à réaliser (`comdevisinterne`), Panne, Panne d'origine externe, Bon intervention numérisé (`cheficdemint`), Ouvrir l'état, Ne pas faire apparaître les heures (`heuvis`), Generer le PDF, Dossier Site (`Site.chemindoc`), PDF (ouvre le dossier), Generer le CE, Gaz (`nummodres` → `TypeFluide`), Qté Gaz (`mnthtdevis`), `CheminDossEtanch`, Urgence Devis, Duplicata à traiter par, Retour fiche d'intervention (`datefintech`), matériel en panne (`ListeMateriel` + `SfMaterielPanne`).
2. **Devis SAV** : sous-formulaire `DevisListe` lié `NumeroInterventionInterne;NumeroSite;NumeroClient` ↔ `numintint;cptsit;lstClient`.
3. (page icône).
4. **Devis Travaux** : sous-formulaire `DevisListeTravaux` (ajout 21/04/26).
5. **Signatures** : images `sigsitimg` (Cachet du site), `sigcliimg` (Signature du client), `sigtecimg` (Signature du technicien) + noms `sigsit2/sigcli2/sigtec2`.

Visibilité des onglets devis `[MajIcone]` : visibles si (`staint` ∈ {6,7}) et (`devisafaire` ou `devisfait`) ; également si `chkDevisAFaire` ou `devisfait` cochés (`[chkDevisAFaire_AfterUpdate]`). Icône « ! » tant que `devisfait=False`. `[Form_Load]` : icône « ! » si un `Devis` (resp. `DevisTravaux`) du site a `statutdevis<>6`.

### 3.2 Contrôles bloquants / avertissements

| Contrôle | Procédure | Message |
|---|---|---|
| Date limite vide à la fermeture | `[VerifDatHeuLim]` (appelé par Fermer, double-clic, Fermer2) | « La date limite d'intervention n'est pas saisie, confirmez-vous votre sortie ? » (OK/Annuler) |
| Minutes téléphone ≤ 0 quand `staint=10` | `[VerifDatHeuLim]` | « Merci de bien vouloir renseigner les minutes passées au téléphone » (bloquant) |
| Case MàJ registre sans date réelle | `[Chkmajreg_Click]` | « Une date d'intervention doit être saisie » (décoche) |
| Passage à 7 sans PDF | `[staint_BeforeUpdate]` | « La demande ne peut pas être clôturée s'il n'y a pas de fichier associé. » |
| Changement de statut facturation réservé | `[Modifiable386/388_BeforeUpdate]` → `[Calcul.Verification_Droit_Modif]` | « Vous n'avez pas les droits pour faire ce changement » si `StatutFacture.QueKadi=True` et utilisateur non « Kadi » (`numuti 367` + mot de passe, `[Form_MenuClimAccess.Image110_Click]`) |
| Cohérences historiques (ref client, date d'appel, objet, dates prévue/réelle, heures) | `[Form_BeforeInsert]` | **toutes commentées** → aucun champ obligatoire à l'enregistrement |
| Fiche : date < date d'appel | `[Form_FicheIntervention sous-formulaire.Date_Exit]` | « La date/heure d'arrivée doit être ultérieure à la date/heure d'appel » |

### 3.3 Valeurs par défaut et automatismes

- `datheuapp` = `Date()` (propriété du contrôle) ; `staint=1` si vide ; `natureintervention=3` ; `codint` = intervenant du site (`Site.numintervenant`) si vide ; `traitepar` = utilisateur connecté (`[Form_Load]`, `[cptsit_AfterUpdate]`).
- Saisie du nom de site + Entrée (`[nomsit_KeyDown]`) : recherche `Site.nomsit like 'x%'` et renseigne client/site ; sinon « aucun site trouvé ! ».
- `refint`, `refcliint` passés en majuscules à la sortie du champ.
- `[Form_Current]` : garantie en cours (`[Form_Site.Calcul_Affiche_Garantie]` : date de mise en service + `garantiecompresseur/pieces/piecesmainoeuvre` en années), « plusieurs inter ce jour » (`[MultiplesInter]` : >1 intervention du site à la même `datint`), bouton « n CE à Editer » si `SiteMateriel` avec `CE_EDITE=0` et `YEAR(DateCE)` = année courante, affichage `NbMinTel` si `staint=10`.
- Département auto (`[CmdFermer_Click]`, `[Commande342_Click]`) : ajoute les 2 premiers caractères de `adrsit` (dans ce formulaire `adrsit` = « CP Ville », donc le département) à `Intervenant.VillesInterventions_Interv` s'il n'y est pas. Bug : si la colonne est nulle, `Trouve` reste faux et une chaîne « ,NN » est écrite.
- « Liste Sous Traitants Possibles » `[Filtre]` : Climatisation → `Activite_1..6 = 1`, Chauffage → `= 2`, Autres → ni 1 ni 2 ; ET (zone du site ∈ `numzonint, numzonint_2..4_interv` OU département ∈ `VillesInterventions_Interv`).
- Historique `[CmdHistorique_Click]` : filtre `refint like '<20 premiers car.>*'`.

### 3.4 Calculs

- **Heures passées** `[Calcul_Heures]` (bouton « Calculer » et au chargement) : somme de `dbo_HeuresTech.HeureFin - HeureDebut` **WHERE `numinterv = Me.numint`** (le N° de bon, pas `numintint` — à vérifier), minuit (`00:00`) traité comme 23:59 +1 mn ; affichage « xH yMn ».
- **Temps trajet / durée** sur l'état : `=[tpsretint]+[tpsallint]`, `=[heudepint]-[heuarrint]` (`forms/Report_2`) ; l'ancienne copie fait `[tpsretint]-[tpsallint]` (`Report_3`, probablement une erreur).
- **Différence facturation** `=[mntfmc]-[mntst]` (formulaire et liste `txtDiff`). `mntfac` (montant facturé historique) n'est plus à l'écran ; seulement recopié par « Nouvelle intervention » et lu par les états legacy `ListeInterventionAFacturer/Facturable/Facturee`.
- **Montant économie** : `[Montant_Devis_Partenaire_AfterUpdate]` / `[Montant_H_T__Devis_AfterUpdate]` requêtent `Montant_économie_H_T_` — contrôles absents du dump courant (code mort).

### 3.5 Numérotation

- `numintint` : identity SQL Server = **numéro interne**, affiché « numintint: », « Num Inter », « Fiche d'intervention N° » sur l'état, « Numéro Demande » sur le fax.
- `numint` : **N° de bon** (bon papier du technicien), saisi dans l'onglet clôture ou recopié depuis `FicheIntervention.numBon` (`[Form_FicheIntervention sous-formulaire.N°_de_bon_AfterUpdate]` : `Forms!Intervention!numint = N°_de_Bon`). Recherche par numéro de bon dans `[Form_ListeSiteGenerale.txtNumeroBon_Exit]`.
- `refint` : N° de demande interne (texte libre) ; `refcliint` : N° de DI client ; `numdevacc` : N° de devis interne accepté ; `numerodemandesoustraitant` : N° attribué par le sous-traitant.

### 3.6 Signatures

Colonnes `sigsit/sigtec/sigcli` (texte, recyclées : prestations réalisées / commentaire clôture panne / chemin facture FMC), `sigsit2/sigcli2/sigtec2` (noms des signataires), `sigsitimg/sigcliimg/sigtecimg` (chemins de fichiers image affichés dans l'onglet Signatures, l'état `FicheIntervention` et le Cerfa CE), `sigtecjson/sigclijson/sigsitbase64` (jamais lus/écrits par le VBA → appli mobile). `PartieSuivante` vide toutes les signatures de la nouvelle partie.

### 3.7 Duplication et « parties »

- **Nouvelle intervention** `[CmdNouvelleIntervention_Click]` (« Est-vous sûr de vouloir créer une nouvelle intervention en utilisant les données actuelles ? ») : nouvelle ligne avec `cptsit, datheuapp, codcon, codint, intfac, mntfac, typint, staint (copié tel quel), refcliint, refint, nbrpagfax, pannoncli, codpan`, puis filtre sur `max(numintint)`. Dans `InterventionEntretien` : `staint=1` forcé et création d'une ligne `FicheIntervention(numintint)`.
- **Creation Inter Partie Suivante** `[Commande414_Click → PartieSuivante]` : demande un commentaire (InputBox), copie les 90 colonnes de l'intervention (INSERT généré colonne par colonne) en forçant : `comint = "PARTIE n :<texte>"`, `refcliint = "PARTIE n :<ref>"`, `staint=1`, `nbrappint=0`, `codpan=41`, gaz (`mnthtdevis`, `nummodres`, `controleetancheiteponctuel` index 80) à 0, dates/heures réelles vides, signatures vides, `cheficdemint=''`, booléens de clôture à 0, `nbrtecint/saisiepar/duplicatafait=0`. La partie 1 d'origine est renommée « PARTIE 1 : … » `[UpdatePartie1]`. Messages « Partie 2 crée » / « Partie n crée » / « Saisie Partie n impossible, une erreur est apparue ».

---

## 4. Fiches d'intervention et heures techniciens

### 4.1 Table `FicheIntervention` (numFicheInt, numIntInt, numBon, dateFicheInt, heureDebut, heureFin, tempsAller, tempsRetour, ficheInt1..4, remarques)

Ancien mécanisme : une intervention pouvait avoir **plusieurs fiches/bons papier** (une par passage), saisies dans le sous-formulaire `FicheIntervention sous-formulaire` / `FicheInterventionEntretien sous-formulaire` (colonnes « N° de bon, Date, Heure arrivée, Heure départ, Temps aller, Temps retour, Remarques » — `forms/Form_39`, `Form_46`). Événements : `Date_Exit` (cohérence avec `datheuapp`, et dans la version Entretien recopie `datint` du parent), `N°_de_bon_AfterUpdate` (recopie `numint` du parent). `InterventionEntretien.CmdNouvelleIntervention` crée une fiche vide. Requête `_importFichesInter` (import Excel de fiches). **Le formulaire `Intervention` courant ne contient plus ce sous-formulaire** (absent de `Form_66`) : les heures sont désormais saisies directement dans `Intervention.heuarrint/heudepint/tpsallint/tpsretint` (une seule plage par intervention, d'où le mécanisme « partie suivante »).

### 4.2 Techniciens intervenus

Sous-formulaire `InterventionTechnicien` (table `InterventionTechnicien(numintint, numuti)`). À la sortie du sous-formulaire `[InterventionTechnicien_Exit → Ajout_Noms]` : concatène « NOM Prénom, … » (50 car. max) dans **`numdevpartenaire`** (colonne recyclée, affichée « Tech(S): » / « Technicien(s) » dans les listes). Bouton « MAJ Liste Tech » = Refresh/Requery (liste des techniciens dépend de `codint`).

### 4.3 Pointage automatique `HeuresTechAuto`

`[AjoutHeures]` (déclenché quand `staint` passe à 7, et par « Generer le PDF » si `staint=7`) : pour chaque `numuti` de `InterventionTechnicien`, `[IntegrerHeureTech]` insère ou met à jour (`[InsertionHeures]`/`[ModifHeures]`) une ligne `dbo_HeuresTechAuto` : `NomInterv` = texte HTML (« MULTIPLE TECHNICIENS », libellé type via `[GetNomOp]`, site, « N° DI: », « N° Devis: », « Commentaire: », « Num Inter: », liste des techniciens), `NumInterv=numintint`, `NumeroSite`, `NumeroTech`, `TypeInterv=typint`, `DateInterv=datint`, `HeureDebut=heuarrint`, `HeureFin=heudepint`, `InterdictionModif=0`. Sort sans rien faire si `datint/heuarrint/heudepint` nuls. Erreur : « Erreur sur Ajout Heures dans Planning ,merci de contacter la banane!! ». TODO du code : « reste à définir si on le fait pour tous les types d'inter ».

### 4.4 Export heures chantier `[Commande381_Click]`

Pour l'année saisie (`AnneeExport`, 2020-2050, sinon « L'année saisie n'est pas correcte!! »), lit `dbo_HeuresTech ⋈ Utilisateur` **WHERE `numinterv = numint`**, cumule par technicien / semaine ISO (`vbFirstFourDays`, 53 semaines) / jour, remplit le modèle `\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Heures.xlsx` (10 lignes par semaine max : « Il y a Trop de technicien … ») et sauve `<nomsit>_<numdevacc>_<année>.xlsx` dans le dossier choisi.

---

## 5. Sous-traitance

- Un sous-traitant est un `Intervenant` (`codint ≠ "FMC"`). Le site porte un intervenant par défaut (`Site.numintervenant`, et `NumSousTraitClim/Desenfum/Chaudiere` utilisés par `Form_Planification`). Champs affichés uniquement pour un sous-traitant : « N° demande du sous-traitant », « Envoi au sous-traitant par » (`[codint_AfterUpdate]`, `[Form_Load]`, `[cptsit_AfterUpdate]`).
- **Envoi de la demande** — trois canaux codés :
  1. **Fax / état** : bouton « Imprimer le Fax » `[CmdImprimerFax_Click]` → sauvegarde puis `OpenReport "FaxInterventionClient"` filtré `numintint` (les noms `FaxInterventionIntervenant[Curatif]` construits dans `lArgs` ne servent plus dans `Form_Intervention` ; `InterventionEntretien` passe par le formulaire `ChoixSociete` qui ouvre l'état nommé dans l'argument — ces états n'existent plus dans la base, seule la requête `FaxInterventionIntervenant` subsiste). Message si aucun enregistrement : « Vous devez d'abord sélectionner une intervention. » ; « Il faut sélectionner le type d'intervention pour pouvoir imprimer le fax. » (Entretien).
  2. **Mail au partenaire** `[cmdEnvoyerMailPartenaire_Click]` : destinataire `Intervenant.adrmelint`, objet « Demande d'intervention pour le client : <client> pour le site : <site> », corps « Madame, Monsieur, ... » + signature HTML FMC (`[PreparerSignature]`, variante selon `Environ("Username")`), via Outlook `[sendEmail]` en **`.Display`** (pas d'envoi automatique). Le code référence `MyMail` non instancié (le `Set MailOutLook` créé n'est pas utilisé) → fonctionnement réel douteux. `Intervention2` utilise `DoCmd.SendObject` avec InputBox de l'adresse.
  3. **Fiche Excel « Dossier VERT et ROUGE »** `[Commande342_Click]` (bouton « Creer Fiche Excel », types 1/2/3 seulement) : ouvre le classeur modèle réseau, onglet 1 Dépannage / 3 Entretien / 2 Devis SAV accepté, écrit site + (numsit), date demande, date limite, client, adresse, N° DI, zone, commentaire, `codint`, `numerodemandesoustraitant`, `numdevacc` (type 3), et pour le dépannage : « Date Mise en service », garanties MO / Pièces / Compresseur OUI (rouge gras) / NON, prix MO et déplacement (site sinon client : `Site.PrixMO/PrixDepl` ou `Client.coutheuremainoeuvre/coutdeplacement`). Le classeur reste ouvert pour l'utilisateur.
- **Mail au contact client** `[CmdEnvoyerMail_Click]` : `Contact.adrmelcon`, objet « Demande d'intervention pour le site : … », corps « A l'attention de … ». **Mail « Fin d'intervention » au client** `[BtcMailClient_Click]` : `Client.melcli`, texte « Nous sommes intervenu à <site> Le <datint> Pour <nature> … Cordialement <chargé d'affaire> », via `SendObject` éditable.
- **Montants** : `mntfmc` « Montant FMC » (facturé au client), `mntst` « Montant Sous-Traitant » (coût), différence affichée ; `mnthtdevpartenaire` « Montant Devis » (HT du devis accepté, alimenté à la génération depuis le devis) ; « Chemin Facture Sous-Traitant » = `commajregsec`. `numpartenaire` est recyclé en « Priorité » (liste). Pas de calcul de marge au-delà de la différence.
- Suivi : statut 5 « En cours chez le sous-traitant » (saisie manuelle).

---

## 6. Devis liés à l'intervention

- `numdev` : n'apparaît plus qu'en état legacy (`ListeInterventionFacturee`) et dans la copie de partie ; `numdevacc` = N° de devis interne accepté (saisi ou alimenté à la génération).
- **Création depuis un devis** `[Form_DevisListe.cmdGenerer_Click]` (« ATTENTION TOUTE MODIF ICI ENGENDRE AUSSI LA MEME DANS DEVIS LISTE TRAVAUX ») : `INSERT INTO intervention (cptsit, datheuapp=Date, objint=<nom fichier devis>, staint=1, typint=3, codint=<intervenant du site>, numdevacc=NumeroDevisInterne, nbrpagfax=MainOeuvreDevis (heures MO vendues), mnthtdevpartenaire=MontantHTDevis)`, puis `StatutDevis=6` (« Devis accepté par le client ») et ouverture de l'intervention. `DevisListeTravaux` : identique avec `typint=5`. `DevisListeContratDeMaintenance` : version `Recordset` avec `typint=3`, sans montant.
- Indicateurs sur l'intervention : `devisafaire` « Devis à faire », `devisfait` « Devis fait » (décoche `devisafaire` — `[devisfait_AfterUpdate]`), `devisanepasfaire` « Devis ne sera pas fait » (décoche `devisafaire`, affiche `comdevis` — `[Cocher231_AfterUpdate]`), `comdevisinterne`, `sigtec` « Commentaire de clôture sur panne (lié au devis à faire) », `devisepar` = urgence, `stadev` = « Duplicata à traiter par », `duplicatafait` « Traité / Attente offre de prix ».
- File « Duplicata » (menu `[Form_MenuClimAccess.Image65_Click]` → `ListeInterventionGenerale` OpenArgs `Duplicata` → `cboStatut=7`, `CheckDevisAFaire=True`) : bulles `staint=7 and devisafaire=true` (total), `… and duplicatafait=true`, `… and duplicatafait=false` (`[MAJBubule]`). Sens métier : après clôture, les interventions marquées « devis à faire » constituent le portefeuille de devis à produire ; « duplicata » désigne historiquement la réimpression du bon pour le chiffrage.
- `mnthtdevis` **n'est plus un montant** : c'est la « Qté Gaz » (kg de fluide) ; `stadev` n'est plus un statut de devis. Les statuts de devis vivent dans `Devis.StatutDevis` (1 à viser, 2 visé à envoyer, 4 envoyé, 3 annulé et remplacé, 6 accepté, 5 refusé — commentaire `[Form_DevisListe.Détail_Paint]`).

---

## 7. Facturation

| Colonne | Libellé courant | Règle |
|---|---|---|
| `intfac` | « Intervention faite et non facturable » (ancien : « Facturable (non facturée) ») | exclusif avec `intfactok` (`[intfac_AfterUpdate]`/`[intfactok_AfterUpdate]`) ; posé à True par « Résolu » (téléphone) |
| `intfactok` | « Facturée » (ancien écran) | plus affiché dans `Form_66` ; alimente l'état legacy `ListeInterventionFacturee` |
| `intafact` | ancien « à facturer » ; **recyclé « Location Nacelle »** | `[CocherNacelle_AfterUpdate]` affiche « !!NACELLE LOUEE!! » ; l'ancien menu `CmdOuvrirListeInterventionFacturable` filtre encore `intafact=true` (sens perdu) |
| `mntfac` | montant facturé (legacy) | non saisi dans l'écran courant |
| `nbrappint` | **« Statut Facturation »** (`dbo_StatutFacture` : `IndexLigne, Statut, OrdreAffichage, QueKadi`) | saisi dans le formulaire (`Modifiable386/388`), la liste générale (`Modifiable417`) et les sous-formulaires du site ; les valeurs `QueKadi=1` ne sont modifiables que par « Kadi » ; valeurs codées : 1 → menu « AFacturer » et bulles couleur (1,2 par type : bleu=1, vert=2, rouge=3, orange=5, noir=autres), 8 → menu « AvaliderFabien » / bulle « Boss », 9 → bulle « Standby ». Libellés non exportés. |
| `mntfmc` / `mntst` / `datesignaturecontrat` | Montant FMC / Montant Sous-Traitant / « Facturé le » | `datesignaturecontrat` = aujourd'hui dès modification de `mntfmc` |
| `visitegratuite`, `numerocontratclient` | — | non affichés (copiés seulement) |

Circuit déduit : le chargé d'affaire clôture (9) → contrôle/valide (7) → positionne le statut de facturation (1 « à facturer », 8 validation direction, 9 standby…) → saisit `mntfmc/mntst` (date auto) et le chemin de facture. Les états legacy du `MenuPrincipal` (`ListeInterventionAFacturer` : `intafact=True` ; `ListeInterventionFacturable` : `intfac=True` ; `ListeInterventionFacturee` : `intfactok=True`, tous bornés par `parametre.datdeb/datfin`) reflètent l'ancien circuit à trois cases.

---

## 8. Listes et filtres

### 8.1 `ListeInterventionGenerale` (liste principale) — `[Filtre_OM_Test]`

Source : `SELECT * FROM (ListeInterventionGenerale2 Liste INNER JOIN Intervention Interv ON Liste.numintint=Interv.numintint) WHERE <filtre> ORDER BY Liste.typint, Liste.nomsit`. `ListeInterventionGenerale2` est une vue SQL Server (non exportée ; la requête Access du même nom liste ses colonnes : Client/Site/Intervention/Devis/ZoneGeographique avec `Client.affcli=True`).

Filtre construit (AND) :
- `Liste.[numcli]=<cboClient>` ou `True`
- si « Recherche Entretien 'Proche' » (`CheckEntretienProche`) : `Liste.[typint]='1' and datedernierevisiteentretien is not null and Liste.[staint]=1 and ((nbrentsit=i And dateadd("d",<Ecart_Permis_Jour_i>, datedernierevisiteentretien) > Liste.[datheulim]) or …)` pour chaque ligne de `dbo_VisitesMaint(Nombre_Visites, Ecart_Permis_Jour)` ; force `cboTypeIntervention=1`, `cboStatut=1`
- sinon `Liste.[typint]='<type>'` et `Liste.[staint]=<statut>` ou `in (<statut>,7)` si « Afficher les clôturées »
- `Liste.[codint]='<intervenant>'`, `Liste.[donneurid]=<donneur>`, `Liste.[nbrappint]=<StatutFact>`
- zones : `(Liste.numzonsit=a or Liste.[numzonsit]=b …)` (liste multi) et/ou `Liste.[numzonsit]=<CboZone>`
- cases : `auditfait=true`, `controleetancheite=true`, `demixasit=1` (« Particulier »), `Interv.imprimeepar is null` (« SousType Vide »), `photofaite=true`, `devisafaire=true` (« Devis à Faire »), `majregsec=true`
- dates « Entre le … et … » (format inversé mm/dd/yyyy) sur `Liste.datheulim` ou sur `Liste.datint` si « sur date réelle »
- site : `Liste.[numsit]=<n>` si numérique sinon `Liste.[nomsit] like '%<texte>%'`

Si `cboStatut=10` : affiche « Temps Total Telephone: » = `sum(retourficheinterventionpar)` sur le même filtre. `UpdateFichierBanane 1/2` écrit un fichier « je suis vivant » (`C:\Users\Public\<année>\<mois>\FichierVieAccess.txt`, surveillance externe).

Pré-positionnement par `OpenArgs` `[Form_Load]` : `Entretien` → type 1 ; `Maintenance` → type 2 ; `SuiteDevis` → type 3 ; `AValider` → statut 9 ; `AFacturer` → StatutFact 1 ; `AvaliderFabien` → StatutFact 8 ; `ACommander` → statut -1 ; `AttenteMatos` → statut 2 ; `Duplicata` → statut 7 + devis à faire.

Listes de valeurs des combos (`forms/Form_38`, version carte) : statuts `-1;"Matériel à commander";1;"A planifier";5;"En cours chez le sous-traitant";6;"Effectuée en attente retour fiche intervention";7;"Clôturée";9;"Réalisée - à valider";10;"Résolue par téléphone";8;"Annulée avec accord client"` ; types `0;Toutes;1;Entretien;2;Dépannage;3;Devis accepté;7;Désenfumage;9;Audit;4;Autre;8;Inter. réalisée en attente devis signé client;5;En travaux;6;En création`.

Actions : double-clic (CP, site, objet, ville) → `Intervention` filtré `numintint` ; clic sur `comint`/`Comm_Devis` → MsgBox du texte ; **suppression d'une ligne = `DELETE FROM intervention`** (`[Form_Delete]`) ; « Nouvelle intervention » ; « Rechercher » ; « Export Saisie Heures » (`Commande60` → `[ExportExcel]` : `nomsit, technicien, intervenant, type, datint, heure de départ, datefintech (heure + date)` dans `Fichier_Extraction_Heures_Inter.xlsx` → `SaisieHeuresInter.xlsx`, confirmation « Attention, Vous allez Exporter les resultats pour n Interventions … ») ; « Exporter clients » (`[CmdExporter_Click]` : requête `EXPORT-MODELE` + filtre → `Export.xlsx`) ; « Imprimer les interventions à réaliser » → état `ListeInterventionOM` avec le filtre du sous-formulaire et un titre par type (« Liste des interventions d'entretien à réaliser », « … de Dépannage … », « Liste des Devis acceptés », « … Désenfumage … », « Liste des audits à réaliser », « Autres », « Inter. réalisées en attente devis signé client », « en travaux », « en creation ») + intervenant + période.

Anciennes procédures `[Filtrer]` (filtre Access côté client, ajoute `[staint]<> 7` si clôturées non affichées) et `[Filtre_OM]` (sans jointure) restent dans le module mais ne sont plus appelées.

### 8.2 `ListeInterGaz` (fluides frigorigènes) — `[Form_ListeInterGaz.Filtre_OM_Test]`

Source `SELECT * FROM (intervention ListeInter INNER JOIN [site] ListeSite ON ListeInter.cptsit=ListeSite.cptsit) WHERE ListeInter.mnthtdevis <>0 [and ListeSite.numcli=…] [and ListeInter.staint=…] [and ListeInter.codint='…'] [and ListeInter.typint='…'] [and ListeInter.nummodres=<type gaz>] [and ListeInter.datint >=/<= …] [and numsit / nomsit like] ORDER BY typint, nomsit`. Affiche « Somme= » `sum(mnthtdevis)` (kg de gaz) ou « Rien Trouvé ». Colonnes du sous-formulaire : Statut, Type, Traitée par, Effectuée le, Intervenant, Sous Type, Type Gaz (`TypeFluide`), Qté Gaz, Tech(S), Lien CE (`CheminDossEtanch`), Bon, Lien vers Site. Contient une copie du code d'export heures.

### 8.3 `ListeInterventionAttente` (ancien menu)

Ouverte par `[Form_MenuPrincipal.CmdListerInterventionAttente_Click]` avec filtre `typint='2' and staint<9 and numcli=<client>` et OpenArgs `H+8` (titre « Liste des interventions de dépannage en cours (H+8) ») ou par `CmdOuvrirListeInterventionFacturable` avec `typint='2' and staint<9 and intafact=true and numcli=…` et `Facturable` (masque la date limite). Bouton détail → `Intervention` avec arg `IDA`.

### 8.4 `RechercheIntervention`

`SELECT numintint, typint, staint FROM intervention WHERE refcliint like '*<texte>*'` ; ouvre la **première** trouvée dans `Intervention` avec un code d'écran (IEP/IEC : entretien planifiée/clôturée ; IDE/IDC : dépannage-devis en cours/clôturée ; IDCE/IDCC : « autre ») basé sur `staint` 1 ou 2 — codes ignorés par `Form_Intervention` aujourd'hui. « Il n'y a pas d'intervention contenant cette référence client. »

### 8.5 Filtres du `MenuPrincipal` (ancien menu, toujours présent)

`Intervention` : « en cours » `(typint 2 ou 3) and staint<9` ; « clôturées » `staint=9` (lecture seule) ; « curatif » `(typint 4 ou 5) and staint<9 / =9` ; « attente observation » `typint='2' and staint<9 and datintpre is null` ; « toutes en cours avec date » `staint<9 and datint is not null`. `InterventionEntretien` : `(typint 1,6,7) and staint<9` (`IEP`) / `=9` (`IEC`). États legacy : `ListeInterventionAEffectuer` (`typint='1' and datintpre between parametre.datdeb/datfin and datint is null`), `ListeInterventionEnCoursPlusSansBon` (`typint='2' and staint<9`), `SiteSansIntervention`, `…AFacturer/Facturable/Facturee` (§7).

### 8.6 Autres listes

- Fiche **Site** : sous-formulaire « en cours » = `Statut not in (7,10,8,20)`, sous-formulaire « clôturées » = `Statut in (7,8,10,20)` (`queries/_sq_fSite_Sous-formulaire_sous-formulaire*.sql`) ; suppression = `DELETE FROM intervention`.
- **MenuClimAccess** (bulles, rafraîchies toutes les 60 s `[Form_Timer]`) : `staint=9` ; `nbrappint=9` ; `nbrappint in (1,2)` par type ; `staint=-1` ; `staint=2` ; `staint=7 and devisafaire=true` (+ `duplicatafait` true/false) ; `nbrappint=8` ; toutes sur `ListeInterventionGenerale2`.
- **Carte** (`forms/Form_38`) : marqueurs par type (Entretiens bleu, Dépannages vert, Tx selon devis rouge, Désenfumage gris, Attente de matériel jaune, Audit noir, En travaux icône), « à réaliser entre le … et le … ».
- **FiltreInterventionsMobiles** : table `FiltreClimAccessMobile(DateDebut, DateFin)` — « Saisir les dates de début et de fin pour filtrer les interventions visibles sur les tablettes » (paramètre lu par l'appli mobile).

---

## 9. États imprimés

| État | Déclenchement | Contenu |
|---|---|---|
| **FicheIntervention** (« RAPPORT D'INTERVENTION », `forms/Report_2`) | « Ouvrir l'état » `[CmdApercu_Click]` (aperçu) ; « Generer le PDF » `[Commande339_Click]` ; filtre `numintint=…`, OpenArgs `"O"` si `heuvis` (masque heures arrivée/départ, temps aller/retour/trajet, durée — `[Report_FicheIntervention.Détail_Format]`) | En-tête logo FMC ou **logo du donneur d'ordre** `\\Serveur\commun\Commercial\A0- Clim Access\Logo ST\<nomdonneur>.jpg` s'il existe (`[ChercherDonneurOrdre]`, `[Report_Load]`), sinon coordonnées FMC ; Fiche d'intervention N° (`numintint`), N° Site (`numsit & codsit`), Date, CLIENT/SITE, adresse, TEMPS DE TRAJET (aller, retour, `=[tpsretint]+[tpsallint]`), TEMPS SUR SITE (arrivée, départ, `=[heudepint]-[heuarrint]`), NBR TECHNICIENS, MISE A JOUR DU REGISTRE DE SECURITE OUI/NON, PRESTATIONS EFFECTUEES (`sigsit`), A PREVOIR / RESTE A FAIRE (`SIGTEC`), COMMENTAIRE (`comtec`), TYPE D'INTERVENTION, CACHET DU CLIENT / NOM DU CLIENT / SIGNATURE CLIENT (`sigsitimg`, `sigcli2`, `sigcliimg`), NOM ET SIGNATURE DES TECHNICIENS (`sigtec2`, `sigtecimg`), mention « LES MENTIONS A REMPLIR CI-DESSOUS SONT OBLIGATOIRES » |
| PDF du bon | `[Commande339_Click]` : dossier proposé = `Site.chemindoc` (lien `path#path`), nom proposé `dd.mm.yyyy (Selon <numdevacc si typint 3, sinon refcliint>)` modifiable (InputBox « Merci de verifier le nom du futur fichier PDF: »), export `acFormatPDF`, `Z:` remplacé par `\\vmware-host\Shared Folders`, `UPDATE Intervention SET cheficdemint='<chemin>#<chemin>#'`, message « PDF Exporté Vers: … » ; erreur « Erreur: Export Vers PDF Annulé. » ; si `staint=7` appelle `AjoutHeures` | prérequis pour le passage en statut 7 |
| **Copie de FicheIntervention** (« FICHE D'INTERVENTION », `Report_3`) | plus appelé par le VBA | ancienne mise en page : cases A DEPANNAGE (pannes 01-14), B ENTRETIEN (CLIMATISATION / RIDEAUX D'AIR CHAUD / EXTRACTION), C DEVIS ACCEPTE ; cases réparation (définitive/provisoire/pas réparé/pas réparable) initialisées à faux |
| **FaxInterventionClient** (`Report_4` probable : « Saisie dans Access (Demande d'intervention) », « Impression de la demande », « Classer dossier "Demande d'intervention" ORDI ») | « Imprimer le Fax » | SITE, Date de la demande, Date maxi intervention, CLIENT, Adresse, Tél, Fax, Mail, Numéro Demande (`numintint`), Zone, Objet + cases de suivi ; `[Report_Open]` : sans OpenArgs → entête/pied « rclim » et expéditeur alternatif, avec OpenArgs → entête FMC |
| **ListeInterventionOM** (`Report_5`) | « Imprimer les interventions à réaliser » | colonnes Type Intervention, Dernière visite réalisée, Date Limite Intervention, Site, Code Site, Commentaire Intervention, Adresse ; titre ligne 1 et sous-titre « Pour <intervenant> du … au … » (`[Report_Load]` découpe OpenArgs sur `;`) ; pied « Document confidentiel - propriété exclusive de FMC Climatisation » |
| **ListeInterventionGenerale** / **… sans quadrillage** (`Report_0`/`Report_1`) | legacy (`Commande41` vide) | colonnes client, site, type, statut, zone, intervenant, entreprise référente, date limite, adresse, Nb Visite, cases Audit/Photos/Contrôle étanchéité/MàJ registre à faire, commentaire, N° Tél, Devis en cours, Dernière visite d'entretien, Devis N° ; couleur verte typint 2, rouge typint 3 `[Détail_Format]` ; `UPDATE Site.datedernierevisiteentretien = max(datint) typint 1 staint 7` présent mais commenté |
| **Test Cerfa** (« Cerfa CE », `Report_6`) | bouton « n CE à Editer » `[Commande402_Click]` → `[PDFCE.Creation_PDF_CE]` → `[PDF_CE]` (`OpenReport "Test Cerfa"` caché, OpenArgs `"<numintint>-<NumeroSiteMateriel>"`, PDF `<numintint>-<nummateriel>.pdf` dans le dossier choisi, défaut `Site.chemindoc`) | Fond image Cerfa, opérateur « FMC MAINTENANCE, 2 RUE GALILEE, 33185 LE HAILLAN », SIRET et n° d'attestation, détecteur « TESTO 316-4 » ; site (nom, adresse, CP ville), N° inter, emplacement, « Marque / Référence / N° de série », fluide (`TypeFluide.libelle`), charge « n kg » (= `SiteMateriel.NbreRadiateurs`, colonne recyclée), « t.éq.CO2 » = kg × GWP / 1000, date « 02/01/<année de datint> » (`Texte843`, sens : probablement prochain contrôle ou début de période — non confirmé), signatures technicien/client (`sigtec2/sigcli2`, images `sigtecimg/sigcliimg`), date `datint`. Cases : famille HCFC (kg <30 / <300 / ≥300), HFC (t.éq.CO2 <50 / <500 / ≥500), HFO (kg <10 / <100 / ≥100) ; « système permanent de détection de fuite » OUI (ligne 5) si `Site.controleetancheiteponctuel` sinon NON (ligne 4). Après génération : `UPDATE SiteMateriel SET CE_EDITE=1`. Erreur : « La génération du CE … n'as pas pu se faire correctement ». `[PDFCE.ControleDatasCE]` valide avant : fluide renseigné et de type connu (« Le type gaz n'est pas utilisé pour les CE »), quantité > 0, GWP > 0, marque, n° de série, référence non vides ; « Les CE ont deja été édités » si rien à faire. |

---

## 10. Rappels et automatismes

- **Rappels** : cases « Rappel Auto 24H / 48H / 72H / Semaine » (`rappel24h/48h/72h/rappelsemaine`) ; un clic sur l'une d'elles écrit `dateenvoimail = Now` (`[Cocher362/364/367/369_Click]`, « Date dernier rappel »). À **chaque ouverture du menu** `[Form_MenuClimAccess.Form_Current → Recherche_Si_Envoi_Mail]` : pour toute intervention `staint=1` avec au moins une case cochée, si `DateDiff("h", dateenvoimail (ou Now-1 an si nul), Now)` > 24 / 48 / 72 / 168 selon la case → `[EnvoiMail]` Outlook **envoi direct** (`.Send`) à la boîte SAV générique de FMC (adresse codée en dur), objet « Rappel Intervention <site> », corps « Site : / Numéro DI Client : / Date Demande : » ; puis `UPDATE intervention SET dateenvoimail=Now`. Message « n Mails de Relance envoyé à … ». Le rappel se répète donc à chaque échéance tant que l'intervention reste « A planifier ».
- **Timer du menu** (1 s) : bulles toutes les 60 s, fichier de vie toutes les 6 s + `Logout` si identifiant perdu, toutes les 2 s `[TraiteDemandeWeb]` : lit `Dbo_Demande_Web WHERE NumUser=<utilisateur>` ; `Type_Demande=1` → ouvre le formulaire `Site` sur `Data2` (l'ouverture de `Intervention` sur `Data1` est commentée) puis remet la demande à 0 → **pont depuis une application web/mobile**.
- **Registre de sécurité** : à l'insertion/mise à jour d'une intervention `typint=1` avec `majregsec` coché, insertion `SiteMAJRegistre(cptsit, Date=datint)` si absente (`[Form_BeforeInsert]`, appelé aussi par `Form_BeforeUpdate`).
- **Génération d'entretiens** hors clôture : `[Form_Site]` (pas hebdomadaire 13 sem. pour 4 visites, 9 pour 6, sinon `52/nbrentsit`, message si zone sans intervenant), `[Form_PlanificationEntretien]` (pas mensuel `12/nbrentsit`), `[Form_Planification]` (T1..T12 → `datheulim`, `refcliint` = N° DI par période, intervenant = `NumSousTraitClim` sinon intervenant du site sinon « FMC », anti-doublon sur `datheulim`), `[ImportExcel]` (colonne « date limite », commentaire : « statut 'à planifier' car un oeil humain doit clôturer les interventions importées »).
- `datedernierevisiteentretien` (Site) : utilisée par « Entretien proche » et les états ; la mise à jour automatique est commentée dans les états — alimentation à identifier (SQL Server ou autre écran).

---

## 11. Codes et libellés — récapitulatif

### staint (StatusInterv.IndexLigne)
| Code | Libellé | Source |
|---|---|---|
| -1 | Matériel à commander (« Matériel en attente » dans l'export) | `Form_38` cboStatut ; `EXPORT-MODELE` ; `MAJBubule` |
| 1 | A planifier | toutes listes ; `Form_Load` |
| 2 | Attente de matériel (ex « Planifiée ») | `MAJBubule` commentaire, `Form_Load` `AttenteMatos` ; anciens : `Report_0` |
| 3 | Attente de matériel (ancien) | `Report_0`, `Form_9` |
| 4 | En cours (ancien) | `Report_0`, `Form_9` ; `PlanificationEntretien` l.947 |
| 5 | En cours chez le sous-traitant | `Form_38` |
| 6 | Effectuée en attente retour fiche intervention | `Form_38` |
| 7 | Clôturée | `Form_38` ; `staint_BeforeUpdate/AfterUpdate` |
| 8 | Annulée avec accord client | `Form_38` ; `Statistiques Clients` |
| 9 | Réalisée - à valider (« Clôturée » dans l'ancien menu) | `Form_38` ; `CmdCloturerIntervention` ; `MenuPrincipal` |
| 10 | Résolue par téléphone | `Form_38` ; `chkprediagres_AfterUpdate` |
| 17 | Ne pas intervenir (libellé non trouvé) | `Form_Site.Gestion_Ne_Pas_Intervenir` |
| 20 | inconnu (statut terminal) | requêtes sous-formulaires Site |

### typint (TypeInterv.IndexLigneSTRING)
1 Entretien · 2 Dépannage · 3 Devis accepté / Devis SAV / Travaux selon devis · 4 Autre · 5 En travaux · 6 En création · 7 Désenfumage · 8 Inter. réalisée en attente devis signé client · 9 Audit · 12 Devis SAV (TR) · 13 Maint. Chaudière · 14 Appel Résolu Par Téléphone — sources `[Form_Intervention.ColoreFenetre]`, `[GetNomOp]`, `[Form_ListeInterventionGenerale.ExportExcel]`, `Form_38`, `EXPORT-MODELE`.

### natureintervention
1 Visite Technique · 2 Visite Filtres · 3 Visite Maintenance Général (défaut) — `Form_66`, `[cptsit_AfterUpdate]`.

### nummodres
Historiquement `ModeResolution(nummodres, libmodres)` « Mode de résolution » (`Form_9`, contrôle obligatoire commenté « Vous devez définir le mode de résolution ! »). **Aujourd'hui : type de fluide** (`TypeFluide.ID/Libelle`, libellé « Gaz: », `Form_66` l.406-410 ; filtre « Type Gaz » de `ListeInterGaz`). La FK vers `ModeResolution` n'est pas déclarée, l'index `IX_Intervention_2` subsiste.

### stadev
Historiquement statut de devis ; **aujourd'hui « Duplicata à traiter par »** (numuti). Les statuts de devis réels : `Devis.StatutDevis` 1 Devis à viser · 2 Visé, à envoyer · 4 Envoyé · 3 Devis annulé et remplacé par · 6 Devis accepté par le client · 5 Devis refusé par le client (`[Form_DevisListe.Détail_Paint]`).

### nbrappint (StatutFacture.IndexLigne)
Libellés non exportés ; 1 = « à facturer » (menu `AFacturer`), 8 = validation direction (`AvaliderFabien` / bulle Boss), 9 = « Standby » ; drapeau `QueKadi` = modifiable seulement par l'utilisateur Kadi.

### Colonnes recyclées (nom SQL → sens réel)
`imprimeepar`→Sous-type · `retourficheinterventionpar`→minutes téléphone · `devisepar`→urgence devis (1/2/3) · `stadev`→duplicata à traiter par · `numpartenaire`→priorité · `numdevpartenaire`→noms des techniciens · `mnthtdevis`→quantité de gaz (kg) · `nummodres`→type de fluide · `nbrpagfax`→nb heures MO vendues · `intafact`→location nacelle · `numerocommande`→horodatage pré-diag · `nbrappint`→statut facturation · `sigsit`→prestations réalisées · `sigtec`→commentaire clôture/devis · `sigcli`→chemin facture FMC · `commajregsec`→chemin facture sous-traitant · `datesignaturecontrat`→date de facturation · `SiteMateriel.NbreRadiateurs`→charge de fluide (kg) · `Site.majregistresecuritefait`→« ne pas intervenir ».

---

## 12. Règles métier et messages utilisateur révélateurs

- Clôture en deux temps : bouton « Clôturer » = 9 (réalisée, à valider par le bureau), statut 7 = clôture définitive **impossible sans bon d'intervention PDF** (`cheficdemint`).
- La clôture (9) d'**une intervention quelconque** d'un site à 2 ou 4 visites/an, avant juillet/octobre, **supprime et régénère** les visites d'entretien non faites du site (§2.5).
- Une intervention « Résolue par téléphone » est automatiquement non facturable (`intfac=1`), datée du jour, et doit porter un nombre de minutes ; un type dédié 14 existe pour les appels créés directement comme résolus.
- Les interventions d'entretien (`typint 1`) sont créées par lots à partir de `Site.nbrentsit`, jamais avec `datheuapp` ; leur date pivot est `datheulim` (date limite) pour la planification `Planification`, `datintpre` pour les générateurs Site/Clôture.
- Les rappels e-mail internes ne concernent que les interventions « A planifier » et sont expédiés à l'ouverture d'Access (pas de tâche planifiée).
- Le contrôle d'étanchéité (Cerfa) est produit par matériel (`SiteMateriel`) et par intervention, une seule fois (`CE_EDITE`), avec seuils réglementaires HCFC/HFC/HFO et détection permanente issue du site.
- Sous-traitant vs interne : `codint="FMC"` masque les champs de sous-traitance ; le mail au partenaire s'affiche mais n'est pas envoyé automatiquement.
- Les listes autorisent la **suppression physique** d'une intervention (touche Suppr dans le sous-formulaire) sans confirmation VBA.
- Messages notables : « Est-vous sûr de vouloir clôturer cette intervention ? » ; « La demande ne peut pas être clôturée s'il n'y a pas de fichier associé. » ; « La date limite d'intervention n'est pas saisie, confirmez-vous votre sortie ? » ; « Merci de bien vouloir renseigner les minutes passées au téléphone » ; « Une date d'intervention doit être saisie » ; « Il n'y a pas d'intervenant attribué à la zone géographique sélectionnée pour ce site. Aucune intervention ne sera générée. » (`Form_Site`) ; « Vous n'avez pas les droits pour faire ce changement » ; « Les CE ont deja été édités » ; « Erreur sur Ajout Heures dans Planning, merci de contacter la banane!! » ; « PDF Exporté Vers: … » ; « n Mails de Relance envoyé … » ; contrôles historiques désactivés (« Vous devez définir la référence client ! », « … la date d'appel ! », « … le numéro de bon ! », « … le mode de résolution ! », « L'heure de fin de l'intervention doit être ultérieure à l'heure de début »).

---

## 13. Points d'incertitude

1. **Libellés des référentiels** `StatusInterv`, `TypeInterv`, `StatutFacture`, `SousType`, `VisitesMaint`, `Liste_Type_Gaz` : données non exportées ; libellés reconstitués à partir des listes figées (versions parfois divergentes : statut 2 « Planifiée » vs « Attente de matériel » ; statut 9 « Clôturée » vs « Réalisée - à valider »). À confirmer par extraction des tables.
2. **Statuts 17 et 20** : 17 = « ne pas intervenir » (déduit du code), 20 jamais écrit par Access — probablement posé par l'application mobile/web.
3. **Clé des heures** : `Calcul_Heures` et l'export heures lisent `dbo_HeuresTech.numinterv = numint` (N° de bon) alors que `HeuresTechAuto` est alimentée avec `numintint`. Selon la table effectivement remplie par les techniciens, le total affiché peut être faux ; à vérifier sur données.
4. **`datefintech`, `sig*json`, `sigsitbase64`, statut 20, `Demande_Web`, `FiltreClimAccessMobile`** : écrits par une application mobile non fournie ; le flux exact (qui passe en 6/7, qui saisit `datefintech`) n'est pas visible ici.
5. **`sendEmail`** (`Form_Intervention`) manipule une variable `MyMail` jamais instanciée : l'envoi au contact/partenaire échoue probablement (ou dépend d'`On Error`) ; à tester avant de reproduire.
6. **Replanification à la clôture sans contrôle de type** : comportement voulu ou effet de bord ? Impact fort (suppression de visites planifiées).
7. **Vue `ListeInterventionGenerale2`** : définition SQL Server non exportée (échec collation) ; la requête Access n'en donne que les colonnes. Les jointures (Devis, Intervenant) et le filtre `Client.affcli=True` doivent être vérifiés côté serveur.
8. **Sens de `Texte843` = « 02/01/<année> »** sur le Cerfa et de « (TR) » dans « Devis SAV (TR) ».
9. **`imprimeepar` / `classeepar` / `duplicatacreepar`** : l'ancien circuit « imprimée / classée / duplicata créé par » a disparu ; seuls des restes existent (`Cocher202` désactivé, libellés `Report_4`).
10. **`nbrappint`** : l'ancien écran `InterventionEntretien` l'écrase encore par `staint-1` — si cet écran est utilisé, il corrompt le statut de facturation.
11. **Mails « rclim »** : le fax possède une variante d'entête pour une autre entité (« rclim ») ; sens contractuel inconnu.
12. Les **états `FaxInterventionIntervenant[Curatif]`, `FaxInterventionClientDepannage`** référencés par `InterventionEntretien`/`ChoixSociete` n'existent plus dans la base (`objects.txt`) : code mort.
