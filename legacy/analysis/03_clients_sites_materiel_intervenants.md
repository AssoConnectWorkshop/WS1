# ClimAccess (FMC) — Compte rendu fonctionnel : Clients, Sites, Matériel, Intervenants

Sources analysées : modules VBA décompressés (`out/vba/*.vba`), extraits binaires des formulaires (`out/forms/*.txt`, libellés/contrôles/RowSource), `legacy/schema.sql` (DDL SQL Server `logiclim`), `legacy/rowcounts.csv`, `legacy/extracted/queries/*.sql` (SQL partiel des requêtes Access, jointures perdues), `legacy/SCHEMA_ANALYSIS.md`, `legacy/ANALYSIS.md`.

Conventions : chaque affirmation cite `Module.Procédure` ou `Form_<n>_<nom>.txt` (extrait formulaire) ou `schema.sql:Table`. Les valeurs de listes (« Value List ») proviennent des extraits de formulaires. « ST » = sous-traitant. « CE » est ambigu dans l'application (voir §8.11).

---

## 1. Client (enseigne)

### 1.1 Table et fiche

`schema.sql:Client` (2 323 lignes) : `numcli` (PK identity), `nomcli` (**UNIQUE** `IX_Client`), `adrcli`, `codposcli`, `vilcli`, `telcli`, `faxcli`, `concli`, `melcli`, `hormaxintcli real`, `logcli image`, `cheminpho varchar(255)`, `cheminpla varchar(255)`, `affcli bit DEFAULT 1`, `coutheuremainoeuvre real`, `coutdeplacement real`.

Fiche `Form_Client` (extrait `Form_14_numcli_368.txt`, RecordSource `Client`) :

| Contrôle | Colonne | Libellé écran |
|---|---|---|
| nomcli | nomcli | Nom |
| adrcli / codposcli / vilcli | | Adresse / Code postal / Ville |
| telcli / faxcli | | Téléphone / Fax |
| concli | concli | Contact principal |
| melcli | melcli | E-mail |
| coutheuremainoeuvre | | **Tarif heure Main oeuvre** (format `#,##0.00`) |
| coutdeplacement | | **Tarif d'un déplacement** |
| Texte46 | cheminpla | **Numéro Esa Clim** |
| Texte48 | cheminpho | **Numéro Esa Maint** |
| lstClient | (non lié) | « Rechercher (N° de site ou Nom de client) » |
| Onglets | | **Sites** (sous-formulaire `Site sous-formulaire Client`, lié `numcli`), **Contacts** (`Contact sous-formulaire`, lié `numcli`), **Devis** (contient seulement l'étiquette « A Développer si nécessaire ») |
| Boutons | | Fermer formulaire, Créer un nouveau client, Planifier les entretiens, Voir sur Maps, Créer un nouveau site |

Remarques :
- `hormaxintcli` (délai max d'intervention, en heures d'après l'équivalent Donneur) et `logcli` (image binaire) ne sont **pas** affichés sur la fiche Client ; `logcli` n'est référencé par aucun VBA lu.
- Les colonnes `cheminpho` / `cheminpla` (nommées « chemin photo/plan ») sont **réutilisées** pour stocker des **numéros Esabora** (« Numéro Esa Clim », « Numéro Esa Maint »). `Form_Site.RechercheNumEsa(numcli)` lit `SELECT cheminpho,cheminpla FROM client WHERE Numcli=…` et affiche `cheminpla` → `NumClim` (« N° Esabora Clim ») et `cheminpho` → `NumMaint` (« N° Esabora Maint ») en lecture seule sur la fiche Site. Esabora n'est défini nulle part dans le code (probablement un logiciel externe de gestion/facturation ; voir §11).
- `Form_Client.DisplayImage` (affichage de logo par chemin de fichier) existe mais `CallDisplayImage` est **vide** : aucun logo affiché côté Client (code mort). La version Donneur est active (§1.4).

### 1.2 Comportements VBA (`Form_Client`)

- `lstClient_AfterUpdate` : si la saisie est numérique → `SELECT Site.numcli FROM Site WHERE Site.numsit=<saisie>` ; positionne la fiche sur ce client et filtre le sous-formulaire Sites sur `[numsit]=<saisie>`. Sinon → `SELECT client.numcli FROM client WHERE client.nomcli like '%<saisie>%'` (premier trouvé), filtre du sous-formulaire désactivé. **Donc `numsit` est le numéro de magasin connu du client, utilisé comme clé de recherche transverse.**
- `CmdAddSite_Click` : `DoCmd.OpenForm "Site", …, acFormAdd, , Me.numcli` → `Form_Site.Form_Load` affecte `Me.numcli = OpenArgs`.
- `cmdPlanIntervention_Click` : ouvre `Planification` filtré `[numcli]=…`.
- `CmdMap_Click` : construit `http://maps.google.com/maps?q=<adresse>,+<cp>,+<ville>&t=m&hl=fr` et lance `C:\Program Files\Internet Explorer\iexplore.exe` via `Shell`.
- `cmdAddCustomer_Click` : `GoToRecord acNewRec`.

### 1.3 Listes clients

- `Form_ClientListe` (extrait `Form_0_ClientListe.txt`, feuille de données) : RecordSource par défaut `SELECT * FROM client WHERE (((Client.affcli)=Yes));`. Colonnes : Nom du client, Adresse, CP, Ville, Téléphone, Fax, Contact principal, E-mail, « Main d'oeuvre: », « Déplacement: », « Affiché: » (affcli), « Num Esabora Clim » (cheminpla), « Num Esabora Maint » (cheminpho). `Nom_du_client_DblClick` → `OpenForm "Client", , , "numcli=" & Me.numcli`.
- `Form_ListeClientAffiche` (conteneur, ouvert par `Form_MenuClimAccess.imgClient_Click`) : `Cocher2_AfterUpdate` bascule le RecordSource du sous-formulaire entre `SELECT * FROM client` (coché) et `SELECT * FROM client WHERE (((Client.affcli)=Yes));` (décoché). `CmdPlanifier_Click` ouvre `Planification` sans filtre.
- **`affcli` = « client affiché »** : filtre standard des listes (ClientListe, `_sq_cCarte_sq_ccboClient.sql` : `WHERE client.affcli=True`, requête `ListeSite2` : `WHERE Client.affcli=True`). Sert à masquer les clients inactifs sans les supprimer.

### 1.4 Donneur d'ordre (`Form_Donneur`) et rôle par rapport au Client

`schema.sql:Donneur` (103 lignes) : `donneurid` (PK), `nomdonneur nvarchar(100)`, `adrdonneur`, `codposdonneur`, `vildonneur`, `teldonneur`, `faxdonneur`, `condonneur`, `meldonneur`, `hormaxintdonneur real`, `logdonneur image`, `cheminpho`, `cheminpla`, `affdonneur bit DEFAULT 1`, `sairapdonneur bit DEFAULT 0`.

La fiche `Form_Donneur` (extrait `Form_63_Donneur.txt`) est une **copie de la fiche Client** (les noms de contrôles/étiquettes sont ceux du Client, ex. `nomcli_Étiquette`, mais liés aux colonnes `*donneur`) :
- Nom, Adresse, Code postal, Ville, Téléphone, Fax, Contact principal, E-mail ;
- `hormaxintdonneur` : « **Délai d'intervention** … en heures » ;
- onglet **Contacts** : `Contact sous-formulaire` lié `numdonneur` ↔ `donneurid` ;
- `cheminpho` : « **Logo donneur** » + `ImageFrame` ; `Form_Donneur.CallDisplayImage` appelle `DisplayImage(Me!ImageFrame, Me!cheminpho)` : chemin relatif résolu depuis le dossier du `.accdb` si pas de `\`, tronqué au premier `#`, image masquée si introuvable (erreur 2220) ;
- `sairapdonneur` : « **Saisie simplifiée sur tablette** » (bit ; usage côté tablette/mobile non visible dans le VBA lu) ;
- boutons « Créer un nouveau donneur », « Voir sur Maps » (`CmdMap_Click`, même mécanisme IE/Google Maps), « Fermer formulaire ». `lstClient_AfterUpdate` est entièrement commenté (recherche désactivée). `CmdAddSite_Click` référence `Me.numcli` (contrôle « numcli: » présent sur la fiche) : reliquat de copie, comportement douteux (§11).

Dans `Form_Parametrage` le `Donneur sous-formulaire` (extrait `Form_33_Donneur_sous-formulaire.txt`) expose : `nomdonneur` « Donneur d'ordres », `sairapdonneur` « Saisie simplifiée sur tablette », `meldonneur` « **Ligne 1 Pied de page** », `cheminpho` « **Ligne 2 Pied de page** », `cheminpla` « **Ligne 3 Pied de page** ». Les trois colonnes sont donc aussi **réutilisées comme lignes de pied de page** (probablement des documents/fax imprimés au nom du donneur d'ordre) — double usage contradictoire avec « Logo donneur » sur la fiche (§11).

**Rôle du Donneur** (déduit des liaisons) :
- `Site.donneurid` (combo `CboDonneur` « Donneur d'ordre », `select * from donneur where 1=1`, verrouillé, déverrouillage par `ValidModifDonOrdre`) : chaque site peut être rattaché à un donneur d'ordre **indépendamment** du client (`Site.numcli`). Le Client est l'enseigne (facturée, tarifs MO/déplacement, sites) ; le Donneur est l'organisation qui **commande** les interventions pour ce site (siège, gestionnaire de patrimoine, facility manager…), avec son propre délai d'intervention et ses contacts. Le code n'explicite pas davantage cette sémantique.
- `Contact.numdonneur` : contacts propres au donneur.
- Filtres : `Form_Carte.CmdAfficher_Click` filtre `[donneurid]=…` ; la vue `ListeSite` expose « Donneur d'ordres ».
- Requête Access `0002 - mise à jour des donneurs d'ordre` (action, SQL non exporté).

---

## 2. Site (magasin)

### 2.1 Identifiants : `cptsit` vs `numsit` (et `codsit`)

- `cptsit int IDENTITY` = **PK technique interne** (`schema.sql:Site`). Toutes les ouvertures de fiche utilisent `"cptsit=" & …` (`Form_SiteListe.nomsit_DblClick`, `Form_Site sous-formulaire Client.nomsit_DblClick`, tous les `Form_Intervenant Sous-formulaire *.Nom_du_site_DblClick`, `Form_MenuClimAccess.TraiteDemandeWeb` via `Data2`). Toutes les tables filles pointent `cptsit` (`Intervention.cptsit`, `SiteMateriel.NumeroSite`, `SiteMAJRegistre.cptsit`, `Devis*.NumeroSite`, `Audit.cptsit`).
- `numsit int NULL`, **non unique** (index `missing_index_78_77` non unique), libellé « **N° du site** » (`Form_6`) ou « **N° de magasin** » (`Form_40_Site_sous-formulaire_Client.txt`) : numéro de magasin **attribué par le client** (ex. import Celio : `INSERT INTO Site(numcli,numsit,…) values(188,'<N° Site>'…` dans `ImportExcel.ImportSiteCelio` ; `ImportExcel.ImportAnnuaire` met à jour `WHERE numsit=<N°> AND numcli=1|4`). Utilisé pour la recherche (`Form_Client.lstClient`, `Form_RechercheSite`, `Form_ListeSiteGenerale.Filtrer` si numérique), la planification (`Calcul.GenererPlanningPrevisionnel` clé `numsit`) et affiché sur les listes intervenants.
- `codsit nvarchar(50)` « Code » : second code client (recherche `CboCode` dans `ListeSiteGenerale`), `nomsocsit` « nom société site » (non affiché sur la fiche).
- Donc dans la cible : garder `cptsit` (id) + `numsit` (numéro métier client, non unique) + `codsit`.

### 2.2 Fiche Site — structure par onglets (`Form_Site`, extrait `Form_6_cptsit_28927.txt`)

En-tête : `lblSite` = « Site : <NOMSIT> - Ville : <VILSIT> » (`Form_Current`), boutons « Fermer formulaire », « Actualiser » (`Commande298` → `acCmdRefresh` + `ControleCE`), « **Créer une intervention Résolu Par Téléphone** » (`Commande462` : `OpenForm "Intervention", acFormAdd, OpenArgs = cptsit;numcli;numintervenant;ResTel`). Le fond de la section détail passe en **rouge** si « NE PLUS INTERVENIR » ou « RETARD PAIEMENT » est coché (`Controle_Intervenir`, `Controle_Retard`), blanc seulement si les deux sont décochés.

Contrôle d'accès à la fiche : `ValidModifClient`, `ValidModifNomSite`, `ValidModifDonOrdre` (cases non liées) déverrouillent respectivement `numcli`, `nomsit`, `CboDonneur` (`*_AfterUpdate` : `.Locked = Not coché`) ; `Form_Load` remet `ValidModifClient=False`. Le client, le nom du site et le donneur d'ordre sont donc **protégés contre la modification accidentelle**.

#### Onglet « Site » (`tpSite`)

**Cadre « Infos Site »**
| Contrôle → colonne | Libellé |
|---|---|
| numcli (combo `select * from Client where 1=1`) | Client |
| CboDonneur → donneurid | Donneur d'ordre |
| Modifiable218 → numintervenant (`SELECT numintervenant, nomint FROM Intervenant`) | **Nom intervenant Clim** (intervenant « titulaire » du site, cf. §4.5) |
| numsit / codsit / nomsit | N° du site / Code / Nom du site |
| adrsit / codpossit / vilsit | Adresse / CP / Ville |
| telsit / faxsit / melsti | Téléphone / Fax / Email |
| surven / surtot (real) | Surface de vente / Surface totale |
| civres / nomres / preres / telcencom | Nom responsable, « Mail responsable » (civres réutilisé ?), Tél. |
| numzonsit (`select * from ZoneGeographique`) | **Zone d'intervention** (zone géographique) |
| txtLatitude → latitude, txtLongitude → longitude, txtAccuracy → precisiongeo | Latitude / Longitude / Précision ; bouton **Géocoder** (`CmdGeocoder_Click`) |
| Texte248 → chemindoc | « Déposer ici le raccourci vers le dossier du site » / « Raccourci réseau vers le dossier du site » |
| NumClim / NumMaint (non liés, lecture seule) | N° Esabora Clim / N° Esabora Maint (issus du Client, §1.1) |

Note : `civres` (civilité responsable dans le schéma) porte l'étiquette « Mail responsable » sur `Form_6` (Étiquette340) — réaffectation probable de la colonne ; sur `Form_40` (sous-formulaire client) `civres` reste « Civilité ».

**Cadre « Infos Install »**
| Contrôle → colonne | Libellé / valeurs |
|---|---|
| datemiseenservicesite | En service le |
| cboindclitec → indclitec | Value List `1;réalisé par nous;2;connu de nous;3;à auditer par nous;4;modifié par nous` (indicateur « Indice Qualité »/relation technique avec l'installation) |
| sitsit | **Situation** : `Clim. dépendante (centre commercial)`, `Clim. indépendante (centre commercial)`, `Clim. dépendante (centre ville)`, `Clim. indépendante (centre ville)`, `Eficia avec pilotage`, `Eficia sans pilotage` |
| Texte369 → typsit | Type (valeurs `H`, `F`, `H et F` d'après `Form_12_Intervenant_Sous-formulaire_sous-formulaire.txt`) |
| Modifiable178 → typfluid | Type de fluide (`SELECT id, libelle FROM TypeFluide`) |
| temp_entree / temp_sortie | Temp. entrante / Temp. sortante (°C) |
| indvetust | **Indicateur de Vétusté (1 à 5 étoiles)** : Value List `1;"µ««««";2;"µµ«««";3;"µµµ««";4;"µµµµ«";5;"µµµµµ"` police Wingdings (étoiles pleines/vides) |
| indpuissance / indaccessib | Indice Puissance / Accessibilité (listes non extraites, vraisemblablement 1..5) |
| Cocher68 → domotique | **GTB** |
| Cocher64 → allumageclim | Allumage Clim. |
| Cocher150 → aspirateur | **Arret d'urgence clim (OUI)** |
| Cocher70 → accessfiltre | **Arret d'urgence clim (NON)** |
| garantiepiecesmainoeuvre / garantiepieces / garantiecompresseur (tinyint, en années) | cadre **Garanties** : Pièces et M.O. / Pièces / Compresseur |

`aspirateur` et `accessfiltre` ont été **réaffectés** à « arrêt d'urgence clim OUI/NON » alors que le rapport « 137 - Liste des sites avec aspirateur » (ouvert par `Form_Zone Geographique.cmdValider_Click`) garde l'ancienne sémantique.

**Cadre « Contrat Entretien Clim »**
| Colonne | Libellé |
|---|---|
| numerocontratclient | N° Contrat Clim. |
| datprisencharge | Date Prise en Charge |
| nbrentsit | **Nb /an** (« Nombre d'entretiens annuels planifiés ») |
| mntredev | **Tarif Clim 1 FMC** (« Montant de la redevance ») |
| nombrevisitetechnique | Nb.(Infos) |
| montantredevancefiltre | **Tarif Clim 2 FMC** |
| nombrevisitefiltre | (nb visites filtre) |
| NumSousTraitClim (combo Intervenant) → dbl-clic ouvre `Intervenant_Fersoft` (`Modifiable405_DblClick`) | Nom Sous Traitant |
| TarifSousTraitClim | Tarif Sous Traitant |
| datesignaturecontrat, montantredevancetechnique | présents en table, non vus sur la fiche |

**Cadre « Contrat Entretien Chaudiere »** : `NumContratChaudiere` (N° Contrat Chaudiere), `DateContratChaudiere`, `NombreContratChaudiere` (Nb/an), `mntredevContratChaudiere` (Tarif Chaudiere FMC), `NumSousTraitChaudiere` (dbl-clic → `Intervenant_Fersoft`, `Modifiable407_DblClick`), `TarifSousTraitChaudiere`.

**Cadre « Contrat Entretien Désenfumage »** : `numerocontratdesenfumage` (N° Contrat Desenfum.), `datedesenfumage`, `nombrevisitedesenfumage`, `montantredevancedesenfumage` (Tarif désenf. FMC), `NumSousTraitDesenfum` (dbl-clic → `Intervenant_Fersoft`, `Modifiable402_DblClick`), `TarifSousTraitDesenfum`, `nbrdesenfsit` (« Nombre de désenfumage annuel » / « Nbre désenfumage »), `datdervisdes` (« Dernière visite le »).

Donc pour chaque site, **trois lots** (clim, chaudière, désenfumage), chacun avec : n° de contrat, date de prise en charge, nb visites/an, redevance FMC, sous-traitant éventuel et tarif ST. La clim a deux redevances (« Tarif Clim 1/2 FMC » = redevance technique / filtre d'après les noms de colonnes `montantredevancetechnique`/`montantredevancefiltre` et `nombrevisitetechnique`/`nombrevisitefiltre`).

**Cadre « Tarif MO et DP »** : `CocherPrix` → `AvecPrixSite`. `Gestion_Affiche_Prix` : si coché, affiche `texteMO`→`PrixMO` (« Tarif Heure Main d'oeuvre(Site): ») et `TexteDepl`→`PrixDepl` (« Tarif d'un Deplacement(Site): ») et masque le sous-formulaire `Tarifs MO et DP` (= tarifs du **Client** `coutheuremainoeuvre`/`coutdeplacement`, extrait `Form_74_Client.txt`) ; sinon l'inverse. **Règle : un site peut surcharger les tarifs MO/déplacement du client.**

**Cadre « Horaires d'ouverture »** : `hor_lun_ouv`…`hor_dim_fer` (varchar(5), défaut `09:00`/`19:00`, masque `00:00`).

**« Registre de sécurité : »** sous-formulaire `SiteMAJRegistre sous-formulaire` lié `cptsit` : liste de dates (`[Date] DESC`, `Form_34_SiteMAJRegistre.txt`) = historique des mises à jour du registre de sécurité (22 310 lignes). Alimenté par `Form_Intervention.Form_BeforeInsert` / `Form_Intervention2` / `Form_InterventionEntretien` : si `typint=1` et `Chkmajreg` coché → `INSERT INTO SiteMAJRegistre (cptsit,[Date]) VALUES (cptsit, datint)` s'il n'existe pas déjà.

**Cadre « A Faire »** : `photoafaire`/`photofaite` (Photo à faire / faite), `auditafaire`/`auditfait` (Audit à faire / fait), `controleetancheiteafaire` (« **CE à faire** »)/`controleetancheitefait` (« CE fait »), `nbrplan`/`nbrpho` (« Plans/Photos », descriptions SQL « Nombre de plans »/« Nombre de photos »).

**Cases spéciales (colonnes réaffectées, confirmé par les commentaires de `Form_ListeSiteGenerale.Filtrer`)** :
| Contrôle | Colonne | Libellé | Commentaire VBA |
|---|---|---|---|
| CochePasIntervenir | **majregistresecuritefait** | **NE PLUS INTERVENIR** | « La colonne majregistresecuritefait correspond a ne pas intervenir » |
| CocheRetard | **misajoursecurite** | **RETARD PAIEMENT** | « La colonne misajoursecurite correspond au paiement en retard » |
| Cocher360 | **majregistresecuriteafaire** | **NACELLE NECESSAIRE** | — |
| Cocher391 | **demixasit** | **Particulier** | « La colonne demixasit correspond a Particulier » |
| Cocher453 | controleetancheiteponctuel | **Syteme de detection de fuite** (détection permanente, cf. §3.6) | — |
| Cocher458 | RDV_Prendre | RDV à Prendre | — |

Attention : `Form_40_Site_sous-formulaire_Client.txt` affiche encore `misajoursecurite` comme « MàJ registre sécurité » (ancienne signification).

**Cadre « Site fermé »** : `fermeture` (Fermé), `datefermeture`, `motiffermeture`. **Cadre « Divers »** : `commentaire` (Commentaire divers). `comsit` (ntext) : « Commentaire général Magasin (visible sur liste technicien) ».

Badges d'état calculés dans `Form_Site.Form_Activate` : « **DEVIS SAV EN COURS** » (`Devis` du site avec `StatutDevis in (1,2,4)`), « **DEVIS TRAVAUX EN COURS** » (`DevisTravaux` idem), « **CE EN COURS** » (`ContratDeMaintenance` idem — ici CE = contrat d'entretien), image `ImgDevisEnCours` si l'un des trois. « GARANTIE MO / PIECES / COMPR. EN COURS » via `Calcul_Affiche_Garantie` (§8.4).

#### Onglet « Interventions » (`tpInterventions`)
- « **Interventions en cours :** » = `Site Sous-formulaire sous-formulaire` (RecordSource `Form_13` : requête `Site Sous-formulaire` jointe à `dbo_TypeInterv` (sur `typint = IndexLigneSTRING`) et `dbo_StatusInterv`, `WHERE Statut<>7 And Statut<>10 And Statut<>8 And Statut<>20`, tri `prévue le DESC, effectuée le DESC`).
- « **Interventions clôturées :** » = `Site Sous-formulaire sous-formulaire 2` (`Form_29` : `WHERE Statut=7 Or 8 Or 10 Or 20`), filtré à l'ouverture sur `Cptsit=<site>` (`Form_Current`, « 27/01/25 Ajout du filtre pour éviter de charger toutes les inter »).
- Colonnes : N° du site, Intervenant (`codint`), Date limite d'intervention (`datheulim`), Effectuée le, Date et heure d'appel, Devis fait / à faire, N° Bon (`numint`), N° Devis Accepté, Devis SAV Fait (`NumeroDevisInterne`), N° DI (`refcliint`), DI Client (`cheficdemcli`), Statut Devis (liste `1 Devis à viser;2 Aucun Retour Client;3 Devis annulé et remplacé par;4 Envoyé;5 Devis refusé par le client;6 Devis accepté`), Bon (`cheficdemint`), Devis (`nomfichierdevis`), **Nom Tech** (`numdevpartenaire` — colonne réutilisée, voir `Renseigner_Tech`), Type Interv, Statut Inter, Statut Facturation (`dbo_StatutFacture`), Qté Gaz (`mnthtdevis` — réutilisé), Doss.Etanch. (`CheminDossEtanch`), TypeGaz (`nummodres` → `TypeFluide` — réutilisé), Comm.Devis (`sigtec` — réutilisé), Urgence Devis (`devisepar` : `1 Faible;2 Moyenne;3 Forte` — réutilisé), Comm.Inter. (`comint`), Devis TR / Statut Devis TR / Devis TR Fait, Montant Devis (`mnthtdevpartenaire`).
- Dans les deux sous-formulaires : `Intervenant_DblClick` ouvre `Intervention` sur `numintint` ; `Form_Delete` exécute `delete from intervention where numintint=…` ; `Statut_Facturation_BeforeUpdate` vérifie `Calcul.Verification_Droit_Modif` (ancienne et nouvelle valeur) sinon « Vous n'avez pas les droits pour faire ce changement ». `Texte37_Click`/`Texte38_Click` (sous-form 2) affichent `sigtec`/`comint` en MsgBox.
- Boutons : « Créer une intervention » (`CmdAddIntervention_Click`, OpenArgs `cptsit;numcli;numintervenant`), rafraîchir (`CmdRefreshInterventions_Click`), « **Renseigner Colonne Nom Tech** » (`Commande393_Click` → `Renseigner_Tech` : pour chaque intervention du site, concatène `nomuti preuti` des `InterventionTechnicien` (max 50 car.) et `UPDATE Intervention SET numdevpartenaire='<noms>'`), « **Régénérer le planning prévisionnel des entretiens** » (`CmdRegenerer_Click`, §8.1).
- Onglets « Contrat de maintenance », « Devis SAV », « Devis Travaux » : sous-formulaires `DevisListeContratDeMaintenance` / `DevisListe` / `DevisListeTravaux` liés `NumeroSite;numeroclient` ↔ `cptsit;numcli` (hors périmètre).

#### Onglet « Matériel » (`Page225`) — voir §3.

#### Onglet « Infos complémentaires Site » (`Page231`) : `Invest` « **Investissement** », `InfosCompl` « Descriptif Investissement » (ajout 10/11/25).

#### Onglet « Marque & Référence de désenfumage » (`tpDesenfumage`) : sous-formulaire `SiteMarqueReferenceDesenfumage Sous-formulaire` (`Form_19`) : Description, Qté, Mis en service le, Fin de service le, Vétusté. Table **vide** (0 ligne).

### 2.3 Création, duplication, import

- Création manuelle : `Form_Client.CmdAddSite_Click` (acFormAdd + `numcli` pré-rempli), ou `Form_MenuPrincipal.CmdOuvrirSite_Click` (ouvre `Site` filtré `numcli=LstClient`, ajout via navigation Access). Valeurs par défaut SQL : horaires 09:00–19:00, `creele=getdate()`, bits à 0.
- **Duplication** : aucun code de duplication de site trouvé dans les modules lus. Seule « duplication » : l'onglet Matériel « Alternance Ref1 Puis Ref2 » recopie des références catalogue (§3.3).
- Import : `ImportExcel.ImportSiteCelio` / `ImportSite` génèrent des `INSERT INTO Site(...)` mais en **`Debug.Print` uniquement** (non exécutés — outillage développeur). `ImportExcel.ImportAnnuaire("AT"|"Celio")` met à jour responsable/tél/fax par `numsit` pour `numcli=1` ou `4` (macros `ImportAnnuaireAT`/`ImportAnnuaireCELIO`). Formulaire `Import_de_site_en_Excel` (ouvert par `Form_MenuPrincipal.Commande297_Click`) et requête `AjoutSite` : code non disponible.
- Changement de client d'un site : `numcli_GotFocus` mémorise `Old_Num_CLient`, `numcli_AfterUpdate` propage : `Update devis|ContratDeMaintenance|DevisTravaux set NumeroClient=<nouveau> where NumeroClient=<ancien> and NumeroSite=<cptsit>`.

### 2.4 Fermeture de site (`Form_Site.fermeture_Click`)

Si `fermeture` coché et `numcli <> 368` (commentaire : « 368 = client fermé ») : MsgBox « Etes vous sur de vouloir cloturer le site ? Cela va changer le nom du client, si oui pensez à le noter avant » (Oui/Non/Annuler). Si Oui : `Update devis|ContratDeMaintenance|DevisTravaux set NumeroClient=368 where NumeroClient=<numcli> and NumeroSite=<cptsit>` puis `Me.numcli = 368`. Sinon `fermeture=0`. **Règle : un site fermé est rattaché au pseudo-client n° 368 (« client fermé »), l'ancien client est perdu (d'où l'invitation à le noter).** `datefermeture`/`motiffermeture` sont saisis manuellement.

### 2.5 Géocodage

- `Form_Site.CmdGeocoder_Click` : si `txtAccuracy = "ROOFTOP"` → rien (déjà précis). Sinon `Geocoding.Geocode(PrepareAddress(adrsit), PrepareAddress(vilsit), PrepareAddress(codpossit), "", "France")` ; si statut ≠ OK, second essai **ville seule**. Résultats → `txtRetAddress`, `latitude`, `longitude`, `precisiongeo` (= `location_type` Google : ROOFTOP, RANGE_INTERPOLATED, GEOMETRIC_CENTER, APPROXIMATE), `txtStatus`.
- `Geocoding.Geocode` (auteur Philben, 2011) : `http://maps.googleapis.com/maps/api/geocode/xml?address=<adr>,<ville>,<region>,<cp>,<pays>&sensor=false` via `Microsoft.XMLDOM`, **HTTP sans clé API** (limite 2 500/jour notée). `PrepareAddress` met en majuscules et supprime les diacritiques.
- `Form_Site.CmdFermer_Click` : si latitude ou longitude vide → « La géolocalisation est vide, confirmez-vous la sortie » (OK/Annuler).
- Batch : `Form_Map.GeocodeClient` (bouton « Géocoder tous les sites ») géocode `site where longitude is null and numcli in (432)` (**client codé en dur**), `update site set longitude=…, latitude=… where cptsit=…`, pause 0,2 s.
- Stockage `latitude`/`longitude decimal(6,3)` (3 décimales ≈ 100 m) ; `Intervenant.Latitude_Interv`/`Longitude_Interv` idem.
- Filtres associés : `ListeSiteGenerale` « sans longitude/latitude » et « non ROOFTOP » ; idem `ListeSousTraitGenerale`.

---

## 3. Matériel du site

### 3.1 `SiteMateriel` (29 511 lignes) — l'inventaire réel

`schema.sql:SiteMateriel` : `NumeroSiteMateriel` (PK), `NumeroSite` (→ `Site.cptsit`), `RepereSurSite smallint`, `Repere nchar(50)`, `Emplacement`, `Quantite tinyint`, `Marque`, `Type nvarchar(100)`, `Reference`, `NumeroSerie`, `Reversible char(5)`, `ResistanceElectrique char(5)`, `PuissanceFrigo real`, `PuissanceCalo real`, `FluideQuantite nvarchar(50)`, `DateMiseEnService nvarchar(20)`, `TypeTelecommande`, `NbreTelecommande`, `EmplacementTelecommande`, disjoncteurs (4 colonnes), `AccessibiliteGroupe`, `AccessibiliteCassettes`, `SupportGroupes`, `EtatSupports`, roof-top (`NbreFiltreRoofTop`, `ReferenceFiltreRoofTop`, `NbreCourroiesRoofTop`, `ReferenceCourroiesRoofTop`, `AppointChauffageSurRoof`), aérothermes, rideau d'air (4), `SasEntree`, clim locaux sociaux (9 colonnes), radiateurs (`Radiateurs`, `NbreRadiateurs real`, `LocalisationRadiateurs`, `DisjoncteurRadiateursTypeIntensite`), `VMC`, `LocalisationVMC`, `Photos bit`, `RapportsMaintenance`, `DevisEnCours`, `DevisValide`, `ControleEtancheite nvarchar(50)`, `Observations`, **`DateCE date`, `CE_Edite bit`, `NumeroInter int`, `DateAchat date`**.

Sous-formulaire `SiteMateriel sous-formulaire` (extrait `Form_58`, feuille de données sur l'onglet Matériel du Site, lié `NumeroSite`) : colonnes affichées « Repère sur site », Repere (combo `Repere.Repere`), Emplacement, Qté, Marque (combo `Marque.nommar`), Type (combo `TypeAudit.Type`), Référence, N° Série, Réversible, Résistance électrique (`NC;OUI;NON`), P.Fr.(W), P.Ch.(W), **Fluide** (`FluideQuantite`, combo `TypeFluide.libelle`), Date MES, Type Télécommande (`TypeTel`), Nbre Télécommande, « **Qté FF** » (quantité de fluide frigorigène — contrôle non identifié dans l'extrait, très probablement lié à `NbreRadiateurs`, voir ci-dessous), Rapports maintenance, Devis en cours, Devis validé, Contrôle d'étanchéité, **CE Annuel edité** (`CE_EDITE`), `DateCE`, « **Inter Associée** » (`NumeroInter`), « Date Achat ».

**Règle de saisie** `Form_SiteMateriel sous-formulaire.Repère_AfterUpdate` : la liste « Type » est refiltrée sur `TypeAudit.Type like '%<2 premiers caractères du repère>%'` → le **repère** (famille : ex. « CL », « RT »…) conditionne les **types** proposés. Même règle dans `Form_Saisie_Reference.Repere_Change`.

**Convention importante (10/05/23, commentaire dans `Form_Site.Commande314_Click`) : « Fluide et quantité dans 2 colonnes diff »** : `FluideQuantite` contient le **libellé du fluide** (ex. R410A) et la **quantité en kg est stockée dans `NbreRadiateurs`** (`INSERT … FluideQuantite,NbreRadiateurs … VALUES (Data_Ref(5)=Fluide, Data_Ref(11)=QteGaz`). `PDFCE.ControleDatasCE` et `Report_Test Cerfa` lisent la quantité de fluide dans `NbreRadiateurs` (« Pas de Quantité de fluide saisie », `TonneCo2 = NbreRadiateurs * GWP / 1000`). **Colonne détournée à documenter absolument pour la migration.**

### 3.2 Référentiels

| Table | Lignes | Contenu / usage |
|---|---|---|
| `Reference` | 764 | Catalogue matériel : `Reference` (nom), `Repere`, `Type`, `Nommar` (marque), `Fluide`, `TypeTel`, `Reversible`, `Resistance`, `PuissanceFrigo`, `PuissanceCalo`, `QteGaz`, `NbFiltres`, `DimFiltres`, `NbCourroies`, `RefCourroies`, `AppointRoof` — **tout en `nchar(50)`**, libellés stockés (pas de FK). |
| `Marque` | 192 | `nummar`, `nommar` |
| `Repere` | 24 | `Repere`, **`CtrlEtancheite bit`** (« Controle Etancheite », `Form_80_Repere.txt`) — indicateur « ce type de repère est soumis au contrôle d'étanchéité » ; **non utilisé dans le VBA lu** (probablement lu par l'appli mobile ou une requête) |
| `TypeAudit` | 103 | `Type` : malgré son nom, c'est la **liste des types d'équipement** (RowSource de « Type » dans SiteMateriel et Reference) |
| `TypeFluide` | 13 | `libelle`, **`GWP int`** (potentiel de réchauffement), **`Type int` → `Liste_Type_Gaz.id`** |
| `Liste_Type_Gaz` | 5 | familles de gaz ; valeurs testées dans le code : `HCFC`, `HFC`, `HF0` (sic, = HFO) |
| `TypeTel` | 3 | types de télécommande |
| `MarqueDesenfumage`, `ReferenceDesenfumage` | ? | référentiels désenfumage (`Form_20`, `Form_21`) |

Saisie des référentiels dans `Form_Parametrage` (sous-formulaires Marque, Reference, TypeFluide, Repere, Activités, Zones, Donneurs, Intervenants) ; les formulaires `Form_Zone Geographique`, `Form_Reference sous-formulaire` (dbl-clic `nomref` → `Saisie_Reference` avec OpenArgs `"Reference ='<nom>'"`) ouvrent les fiches.

### 3.3 Ajout de matériel à un site depuis le catalogue (`Form_Site`, onglet Matériel)

- `Ref1`/`Ref2` (combos `SELECT id, Reference FROM Reference`), `NB1`/`NB2`/`NB3` (nombres).
- `Commande314_Click` « Ajout Reference 1 » : contrôle `NB1` numérique et `Ref1` renseigné (MsgBox « Ajout Impossible, Veuillez verifier le nombre de la reference 1 » / « …la reference 1 »), puis **NB1 fois** `INSERT INTO SiteMateriel (Reference,Repere,Type,Marque,FluideQuantite,NbreRadiateurs,TypeTelecommande,Reversible,ResistanceElectrique,PuissanceFrigo,PuissanceCalo,NbreFiltreRoofTop,ReferenceFiltreRoofTop,NbreCourroiesRoofTop,ReferenceCourroiesRoofTop,AppointChauffageSurRoof,NumeroSite,Quantite) VALUES (<champs Reference>, <cptsit>, 1)`. **Une ligne par équipement (Quantite=1)**, valeurs copiées (pas de FK vers Reference).
- `Commande319_Click` « Ajout Reference 2 » : idem avec Ref2/NB2.
- `Commande325_Click` « Ajout Reference 1+2 » (« Alternance Ref1 Puis Ref2 ») : NB3 fois, insère Ref1 puis Ref2 (paires intérieur/extérieur par exemple).
- `Commande336_Click` « Vers Page Parametres » ouvre `Parametrage`.

### 3.4 Import Excel d'audit matériel

- `Form_Site.Commande143_Click` « Importer Fichier Audit » : MsgBox « Vous allez importer le fichier d'audit!!,,vous etes sur(e) ?,c'est votre dernier mot ? » ; fichier choisi doit se terminer par **`Fichier_Audit.xlsx`** (sinon « Le fichier choisi doit etre: Fichier_Audit.xlsx ») ; `ImportFichierAuditSite` lit la feuille 1 **à partir de la ligne 3** (« je ne sais pas pourquoi la première ligne ne passe pas il faut la recopier en Ligne 3 »), colonnes C..S : RepereSurSite, Repere, Emplacement, Quantité, Marque, Type, Réf, N° série, Réversible, Rés. élec., P. frigo, P. calo, fluide, Date MES, type télécommande, nb télécommandes, emplacement télécommande ; arrêt quand Marque et Réf vides ; `INSERT INTO SiteMateriel(Numerosite,RepereSurSite,Repere,Emplacement,NbreRadiateurs,…,Quantite) VALUES (<cptsit>,…,<Quantite Excel>,…,'1')` — la colonne « Quantité » Excel est écrite dans **`NbreRadiateurs`** (donc lue ensuite comme quantité de fluide) et `Quantite` forcé à 1. Fin : « Import Audit Terminé de N Lignes OK avec M Lignes pas OK ».
- `Form_Parametrage.ImportFichierAudit` : variante globale (colonne B = `NumeroSite` = cptsit, dès la ligne 2, ~45 colonnes dont disjoncteurs, roof-top, rideau d'air, radiateurs, VMC, Photos, Observations ; « FAUX » → 0 pour les bits). `ImportFichierAuditOld` : ancienne version cherchant le site par `nomsit` (`RechercheSite`).
- Export inverse : `Form_Filtre Extraction` écrit dans `\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Extraction_Materiel.xlsx` le jeu `Client LEFT JOIN Site LEFT JOIN SiteMateriel WHERE Client.numcli=…` ; requête `ListeSiteMaterielGifi` (`WHERE Client.nomcli="GIFI MAG"`).

### 3.5 Fiche référence catalogue (`Form_Saisie_Reference`, extrait `Form_81_Site.txt` — l'extrait porte le nom « Site » par erreur d'export)

- Mode ajout (OpenArgs vide) : titre « Ajout Reference Materiel », bouton `Bp_Ajout` « Ajouter Reference ». Mode modification (OpenArgs = `Reference ='…'`) : titre « Modification Reference Materiel », charge la ligne par index (`RsCodInt(1..16)`), boutons `BP_Modification_Toutes` « **Modification de Toutes les References Materiel (Base + Materiels Existants) SAUF FLUIDE ET QTE GAZ** » et `BP_Modification_Une` « Modification Seulement de la Reference dans la Base » ; `BP_Creation` « Ajout d'une Nouvelle Reference dans la base » apparaît si le nom change (`Nom_Ref_Change`), avec confirmation « Attention, Vous allez Creer une nouvelle reference…, la reference dont vous etes partie existera toujours, Etes Vous Sur ? ».
- `Verif_Data(Avec_NomRef)` — **règles de validation** (MsgBox « Veuillez verifier … ») : nom, Marque, Type, Repere, fluide, Type de Télécommande, réversible (`OUI;NON;NC`), Résistance obligatoires ; `Gaz` (Quantité Gaz (KG)) numérique ; `Puiss_Calo` et `Puiss_Frigo` numériques **entiers** (« elle est en W ») ; `Nb_Courroies`, `Nb_Filtres` numériques ; en ajout, unicité du nom (`select * from reference where Reference='…'` → « Le nom de la reference existe deja dans la base »).
- `Modif_BD_Ref` met à jour `Reference` champ par champ (flags `Modif_*` posés par les événements `_Change`) ; `Modif_BD_Materiel` propage sur `SiteMateriel WHERE Reference='<nom>'` : Marque, Repere, Type, TypeTelecommande, Reversible, ResistanceElectrique, PuissanceFrigo, PuissanceCalo, NbreFiltreRoofTop, ReferenceFiltreRoofTop, NbreCourroiesRoofTop, ReferenceCourroiesRoofTop, AppointChauffageSurRoof — **jamais Fluide ni QteGaz** (chaque équipement garde sa charge réelle). Bug mineur : `Dim_Filtres_Change` pose `Modif_Filtres` au lieu de `Modif_DimFiltres` (la dimension des filtres n'est donc jamais propagée).

### 3.6 Contrôle d'étanchéité (CE) — règles

Objet : générer le **Cerfa de contrôle d'étanchéité** (état `Test Cerfa`, `Report_Test Cerfa.Report_Load`) par équipement et par an.

- **Éligibilité** : `SiteMateriel WHERE numerosite=<cptsit> and CE_EDITE=0 and YEAR(DateCE)=<année courante>` (`Form_Site.ControleCE`, `Form_Intervention` idem, `PDFCE.Creation_PDF_CE`, filtre `ChkCE` de `ListeSiteGenerale`). Le bouton `Commande402` affiche « N CE à Editer ». **Qui renseigne `DateCE` et `NumeroInter`** (intervention associée) : aucun `UPDATE` trouvé dans le VBA lu → très probablement l'application mobile/web (§11).
- **Pré-contrôles** `PDFCE.ControleDatasCE(NumeroInter, NumeroSiteMateriel)` (MsgBox « La génération du CE n-m n'as pas pu se faire correctement, cause: … ») : fluide (`FluideQuantite`) présent et trouvé dans `TypeFluide` avec `Type<>0` (« Le fluide … doit etre renseigné il est actuellement defini à: … ») ; famille `Liste_Type_Gaz.libelle` ∈ {HCFC, HFC, HF0} (« Le type gaz n'est pas utilisé pour les CE ») ; quantité `NbreRadiateurs` > 0 ; `GWP` > 0 ; `Marque`, `NumeroSerie`, `Reference` non vides.
- **Classement réglementaire** (`Report_Test Cerfa`) : `TonneCo2 = kg × GWP / 1000` ; HCFC en kg : `<30`, `<300`, `≥300` ; HFC en t.éq.CO2 : `<50`, `<500`, `≥500` ; HFO en kg : `<10`, `<100`, `≥100` (trois colonnes de cases du Cerfa) ; ligne « avec système permanent de détection de fuite » (`ChkOui`, ligne 5) si `Site.controleetancheiteponctuel = True`, sinon ligne 4 (`ChkNon`). Donc **`controleetancheiteponctuel` = « Système de détection de fuite » (permanent) au niveau du site**, ce qui change la périodicité réglementaire du contrôle.
- Le rapport imprime site, emplacement, `Marque / Reference / NumeroSerie`, fluide, kg, t.éq.CO2, date « 02/01/<année de datint> », signatures technicien/client (`sigtec2`, `sigcli2`, images `sigtecimg`/`sigcliimg` si fichiers existants) puis `Update SiteMateriel set CE_EDITE = 1`.
- `PDFCE.Creation_PDF_CE(cptsit)` : dossier proposé = `Site.chemindoc` tronqué au `#` (format raccourci « texte#\\chemin# ») ; PDF nommé `<NumeroInter>-<NumeroSiteMateriel>.pdf` via `DoCmd.OutputTo acFormatPDF`. « Les CE ont deja été édités » si rien à faire.
- Le seuil d'**obligation** du CE n'est pas codé (aucun test « en dessous de X kg pas de CE ») ; `Repere.CtrlEtancheite` est le seul indicateur de « soumis au contrôle », non exploité dans Access.

### 3.7 `SiteMarqueReference` (ancien modèle, 11 lignes) et pannes matériel

- `schema.sql:SiteMarqueReference` : `cptsit`, `nummar`, `nomref`, `des`, `fluide`, `qte`, `datmisser`, `datfinser`, `numsitmarref` (PK), `indvet` (Vétusté), `indvetplu` (V+), `indpri` (Principal), `type` (`CLIM;RAC;VENTIL`), `climtecouinon nchar(3)`, `numerochantier`.
- `Form_SiteMarqueReference Sous-formulaire` (`Form_7`) : `Référence_AfterUpdate` recopie description et marque depuis la combo `SELECT Reference.nomref, Reference.desref, Reference.nummar, Marque.nommar FROM Reference INNER JOIN Marque…` — **colonnes `nomref`/`desref`/`nummar` n'existent plus dans `Reference`** (schéma actuel) : ce sous-formulaire est **obsolète/cassé**. `Fluide_Exit` force les majuscules.
- `PanneMaterielSite` (0 ligne) : `numintint`, `datedebut`, `datefin`, `numsitmarref` → lie une intervention à un équipement **de l'ancien modèle** ; `Form_SfMaterielPanne.Commande11_Click` supprime (« Voulez vous supprimer cette enregistrement ? »). **Le lien panne ↔ matériel n'est pas utilisé** (table vide, modèle obsolète) ; les pannes d'intervention passent par `Intervention.codpan` (hors périmètre). `SiteMateriel.NumeroInter` (« Inter Associée ») est le seul lien actuel équipement ↔ intervention, dédié au CE.

---

## 4. Intervenants

### 4.1 Table `Intervenant` (193 lignes)

`schema.sql:Intervenant` : `codint nvarchar(10)` (UNIQUE `IX_Codint`, code court, ex. « FMC »), `nomint`, `numzonint` (FK `ZoneGeographique`), adresse/CP/ville/tél/fax, `numintervenant` (PK identity), `adrmelint`, dirigeant (nom/tél/mail), interlocuteur (nom/tél), `Info_Interv`, `Histo_FMC_Interv`, `numzonint_2/3/4_Interv`, `VillesInterventions_Interv nvarchar(512)`, `Activite_1..6 int` (→ `Activites`, 20 lignes), `MO_Activite_1..6 real`, `Depl_Activite_1..6 real`, `Date_Activite_1..6`, `Latitude_Interv`/`Longitude_Interv`, `Rooftop_Interv`, `PrecisionGeo_Interv`, `Provenance_Interv`, `ChargeAffaireFMC_Interv int` (→ Utilisateur), `CreePar_Interv int`, `IndMaint_Interv`, `Ind_Depann_Interv`, `Ind_Travaux_Interv`, `Ind_React_Interv` (tinyint), `DossierOrdi_Interv`, `TexteNeplusInterv`, **`EstTech bit`**, **`NePlusIntervenir bit`**, `Status_Prospect`, `Status_ST_FMC`, `Status_ST_FMC_Ponctuel`, `Status_Act_Poss_Maint/Depan/Travaux`, `Status_Act_Donn_Maint/Depan/Travaux`, `Zone_Nationale`, `MailFacturation`, `SiteInternet`, `ExistePlus`, `AutoLiquidation`.

Lien avec les utilisateurs : `Utilisateur.codintuti` = `Intervenant.codint` (`SCHEMA_ANALYSIS`), les techniciens internes sont des `Utilisateur` (`typuti=2`, `codintuti<>''`) rattachés à un intervenant. `Intervention.codint` référence le code intervenant.

### 4.2 Technicien interne / sous-traitant / prospect

- **`EstTech`** : libellé « **TECHNICIEN (Sinon Intervenant)** » (`Form_83`) → distingue un **technicien FMC interne** d'un intervenant externe. Filtre « Tech » de `ListeSousTraitGenerale` : `(EstTech=1)`.
- **Statut de l'intervenant** (cadre) : `Status_Prospect` « **Prospect** », `Status_ST_FMC` « **Sous traitant FMC** », `Status_ST_FMC_Ponctuel` « **Sous traitant FMC (Ponctuel)** ». Ce sont des bits indépendants (pas d'exclusion mutuelle codée).
- « **Activité possible ST** » : `Status_Act_Poss_Maint/Depan/Travaux` (ce que le ST sait faire) ; « **Activité à donner au ST (Par FMC)** » : `Status_Act_Donn_Maint/Depan/Travaux` (ce que FMC décide de lui confier).
- `NePlusIntervenir` « **Ne plus intervenir** » + `TexteNeplusInterv` (motif) + image `ImgPasInterven` ; `Form_Intervenant_Fersoft.Cocher172_Click` / `Form_Load` affichent l'image et le texte si coché. Aucun effet automatique sur les interventions (contrairement au site, §8.2).
- `ExistePlus` « **N'existe Plus** » (société disparue) ; `AutoLiquidation` « Autoliquidation » (TVA) ; `MailFacturation` « Mail Facture: » ; `SiteInternet`.
- Code intervenant par défaut **`FMC`** (« On Force à FMC », `Form_Planification`).

### 4.3 Activités et tarifs

Cadre « Activités » : 6 lignes `Activite_n` (combo `Activites.Nomactivite`), `MO_Activite_n` (colonne « MO » = tarif main d'œuvre), `Depl_Activite_n` (« DP » = déplacement), `Date_Activite_n` (« Date », probable date de validité/négociation). `Provenance_Interv` « Provenance: », `ChargeAffaireFMC_Interv` « **Interlocuteur FMC:** » (combo `Utilisateur WHERE typuti=1 AND codintuti<>""` = gestionnaires), `CreePar_Interv` « Cree par: ». Les tarifs ST **par site** sont dans `Site.TarifSousTraitClim/Chaudiere/Desenfum` (§2.2), distincts des tarifs par activité.

### 4.4 Zones, géolocalisation, indicateurs

- Zones : `numzonint` « Zone Interv 1 » + `numzonint_2/3/4_Interv`, `Zone_Nationale` (« Zone Nationale » : intervient partout), `VillesInterventions_Interv` « Villes ou CP (Si plusieurs séparer par VIRGULE) ». `ZoneGeographique` (43) : `numzon`, `nomzon` (UNIQUE). Fichier `Remplissage_numintervenant_site` : requête d'affectation d'intervenant par zone (`ZoneGeographique.nomzon="…"`, SQL partiel).
- Géolocalisation : `Latitude_Interv`, `Longitude_Interv`, `Rooftop_Interv` « Précision » (aucun bouton géocoder sur la fiche ; filtres « sans lat/long » et « non ROOFTOP » sur `precisiongeo_interv` dans `ListeSousTraitGenerale` — colonne réelle `PrecisionGeo_Interv`).
- Indicateurs : `IndMaint_Interv` « Indicateur de Vétusté (1 à 5 étoiles) » sous « Maintenance » (même liste Wingdings que le site : ici note qualité maintenance) ; cadre « **Qualité Sous-Traitant** » : `Ind_Depann_Interv` (Dépannage), `Ind_Travaux_Interv` (Travaux), `Ind_React_Interv` (Réactivité) — listes non extraites, vraisemblablement 1..5.
- `DossierOrdi_Interv` « Raccourci vers le dossier » (« Déposer ici le raccourci vers le dossier du site »).

### 4.5 Écrans

- **`Intervenant`** (extrait `Form_1_Intervenant.txt`, pas de module VBA) : fiche simple Code, Nom, Zone géographique, Adresse, CP/Ville, Téléphone, Fax + sous-liste « Interventions » (`Intervenant Sous-formulaire sous-formulaire`, `Form_12` : Code, Prévue le, Effectuée le, Nom du site, Ville, Type du site (`H;F;H et F`), N° du site ; requête `Intervenant Sous-formulaire` = Intervenant × Intervention × Site).
- **`Intervenant sous-formulaire`** (`Form_50`, feuille de données dans `Parametrage`) : mêmes colonnes + Prospect, Ne Pas Intervenir, dirigeant, interlocuteur, Info, Zone Nationale, Zones 1-4, Activités 1-6 ; `nomint_DblClick` → `OpenForm "Intervenant_Fersoft", …, "nomint='" & nomint & "'"` (filtre par **nom**, fragile si apostrophe/homonyme).
- **`Intervenant_Fersoft`** (`Form_83`) : fiche complète décrite ci-dessus, plus :
  - sous-listes « **Sites Clim / Sites Chaudiere / Sites Desenfumage** » (`CheckClim/CheckChaudiere/CheckDesen` exclusifs, `Form_Intervenant_Fersoft.Check*_Click`) : `SELECT Site.nomsit, Site.NumSousTraitClim, Site.TarifSousTraitClim, … FROM Site` lié `NumSousTraitClim|Chaudiere|Desenfum` ↔ `numintervenant`, colonnes Nom du site / « Tarif ST » ; dbl-clic → fiche Site (`Form_Intervenant Sous-formulaire Clim/Chaudiere/Desenfum.Nom_du_site_DblClick`) ;
  - sous-listes « **Magasins confiés en maintenance au ST** » (`Maintenance`) et « **Historique des sites où ils sont intervenus** » (`Depann`, `Devis` « Devis Accepte », `Travaux`) — `CheckMaint/CheckDepann/CheckDevis/CheckTravaux` exclusifs ; RecordSource maintenance (`Form_89`) : `SELECT Site.nomsit, Intervention.codint, Site.cptsit FROM Site INNER JOIN Intervention ON … WHERE Intervention.typint='1' GROUP BY …` (lié `codint`) ; les autres sont liés `codint` (`_sq_cIntervenant_Fersoft_sq_cDepann.sql` : `WHERE [__codint]=codint`), SQL non exporté ;
  - chargement : Clim + Dépannage affichés par défaut (`Form_Load`).
- **Qu'est-ce que « Fersoft » ?** Aucune définition dans le code. Indices : commentaires récurrents `'Pour Test Fersoft` devant des chemins locaux `c:\…` substitués aux chemins `\\Serveur\…` (`Form_00 - Statistiques Clients`, `Form_Filtre Extraction`, `ImportExcel`, `Form_Intervention` : « Pour Fersoft (Car pas de chemin serveur ») ; initiales « OM » dans les commentaires de modification datés 2020-2026. **Déduction : Fersoft est le nom du prestataire/développeur externe (environnement de test sans accès au serveur FMC) ; `Intervenant_Fersoft` est la fiche intervenant refondue par ce prestataire, qui remplace la fiche `Intervenant` d'origine.** À confirmer.
- **`ListeSousTraitGenerale`** (ouvert par `Form_MenuClimAccess.ImgDonneur_Click` — l'icône « Donneur » ouvre en fait la liste des intervenants) : filtres §6.4.
- `Form_MenuPrincipal` : listes `LstIntervenant` (`SELECT codint, nomint FROM Intervenant ORDER BY codint`), `CboSuiviIntervenant`, `LstIntervenantRepertoire` (répertoire technique).

### 4.6 Règle d'affectation d'un intervenant à un site / une intervention

- `Form_Planification` (génération des entretiens) : `codint` = `Intervenant.codint` de **`Site.NumSousTraitClim`** si renseigné, sinon de **`Site.numintervenant`** (« Nom intervenant Clim »), sinon **`"FMC"`**. Idem chaudière (`NumSousTraitChaudiere`) et désenfumage (`NumSousTraitDesenfum`).
- `Form_Site.CmdRegenerer_Click` : intervenant = premier `Intervenant.codint` dont `numzonint = Site.numzonsit` (jointure via `ZoneGeographique`) ; si aucun : « Il n'y a pas d'intervenant attribué à la zone géographique sélectionnée pour ce site. Aucune intervention ne sera générée. » (**incohérent** avec la règle de `Form_Planification`).
- `Form_Intervention` (création depuis un site) : `codint` par défaut = `Intervenant.codint` de `Site.numintervenant` (`Form_Intervention.vba:1879`).

### 4.7 Zone géographique (`Form_Zone Geographique`)

Boîte de dialogue : `LstZoneGeographique` (`SELECT numzon, nomzon FROM ZoneGeographique ORDER BY nomzon`) ; `cmdValider_Click` ouvre le rapport « **137 - Liste des sites avec aspirateur** » avec `numcli=<Form_MenuPrincipal.LstClient>` [`AND numzonsit=<zone>`]. Ouvert par `Form_MenuPrincipal.cmdLstAspirateurFiltre_Click`. Variante « 137bis » sans zone (`Commande293_Click`).

---

## 5. Cartes

### 5.1 `Form_Carte` — carte des interventions (Leaflet)

- Technologie : contrôle **WebBrowser** (IE embarqué, `Shell.Explorer.2`) chargeant le fichier local **`<dossier du .accdb>\geo.html`** (`Form_Load`, `CmdAfficher_Click`) ; le VBA injecte du JavaScript par `Document.parentWindow.execScript` : `L.marker([lat,lng],{icon: <couleur>Icon}).addTo(mymap).bindPopup(...)`, `L.circle(...)`, `markers.addLayer(marker)`, `mymap.addLayer(markers)` → bibliothèque **Leaflet** (commentaire « RMA - Leaflet »), objets `mymap`, `markers` et icônes `blueIcon`, `greenIcon`, `redIcon`, `yellowIcon`, `blackIcon`, `brownIcon`, `greyIcon`, `coneIcon` définis dans `geo.html` (non disponible). Le fond de carte (tuiles) est inconnu (dans le HTML).
- Données : `SELECT numintint,latitude,longitude,typint,staint,nomcli,nomsit,datheulim,datheuapp,datintpre,nomuti,adrsit,codpossit,comsit,comint,vilsit,datedernierevisiteentretien as [datdervis] FROM [ListeInterventionGenerale] LEFT JOIN [Utilisateur] ON …numutipre = Utilisateur.numuti WHERE <filtre> AND [longitude] is not null and [latitude] is not null` → **une épingle par intervention géolocalisée** (pas par site).
- Filtres (`CmdAfficher_Click`, listes multi-sélection) : clients `[numcli]=… OR …` (RowSource `client.affcli=True`), types `[typint]='…'`, statuts `[staint]=…` (+ `OR [staint]=7` si `ChkShowArchived`), `datheulim >= #txtdebut#`, `datheulim <= #Texte17#`, `[donneurid]=CboDonneur`, intervenants `[codint]='…'`, zones `[numzonsit]=…`.
- Couleurs par `typint` : 1 **bleu** « ENTRETIEN » (+ « à faire avant le <datheulim> »), 2 **vert** « DEPANNAGE » (« reçue le <datheuapp> », « prévue le <datintpre> »), 3 **rouge** « TRAVAUX SELON DEVIS », 4 « AUTRE », 5 « EN TRAVAUX » icône `cone`, 7 **jaune** « DESENFUMAGE », 9 **noir** « AUDIT », autre **marron** ; `staint = -1` → **jaune** ; « Désenfumage » → gris (test sur une casse jamais atteinte, code mort). **Cercle orange de 500 m** si `datheulim < Now` (dépassement d'échéance).
- Info-bulle : type, « Client - Site », adresse, CP ville, Date demande, Date limite, Dernière visite d'entretien, Technicien prévu (`nomuti` de `numutipre`), Date prévue, Commentaire général Site, Commentaire Intervention.
- `Form_Timer` rappelle `CmdAfficher_Click` (rafraîchissement périodique, intervalle dans les propriétés du formulaire). `SaveHTML` (non appelée) écrirait `cartefmc.html`. `clearMap`/`setViewPort` vides (anciennes fonctions Google `oMap.*` commentées). Ouverture : `Form_MenuClimAccess.Image27_Click` (`acDialog`).

### 5.2 `Form_Map` — carte des sites d'un client + géocodage (Google Maps, ancien)

- Charge **`<dossier du .accdb>\geocoding.html`** et pilote un objet JS **`oMap`** (`oMap.addMarker(lat,lng,texte,couleur)`, `oMap.clearMarkers()`, `oMap.adjustViewPort()`) : composant Google Maps de la démo Philben 2011 (même auteur que `Geocoding`). Extrait `Form_37` : titre « Géocoder un site », RecordSource `Site`, liste `LstClient`, champs adresse/ville/CP/région/pays (« France »), « Résultat Géocodage » (adresse renvoyée, latitude, longitude, précision, statut), boutons Géocoder, Afficher/Masquer le marqueur, Clear Address, Précédent/Suivant, Afficher, Actualiser, « **Géocoder tous les sites** ».
- `CmdAfficher_Click` : `SELECT nomcli, nomsit, longitude, latitude FROM site INNER JOIN client … WHERE longitude is not null and latitude is not null and client.numcli=<numcli>` → marqueurs bleus « Client - Site ». `btnGeocode_Click` géocode l'adresse saisie ; `CmdGeocoderTout_Click` → `GeocodeClient` (client 432 codé en dur, §2.5).
- Aucun `OpenForm "Map"` trouvé dans les modules lus : formulaire probablement **accessible seulement via le volet de navigation / obsolète**.

### 5.3 « Voir sur Maps »
Client, Donneur, Site : URL `http://maps.google.com/maps?q=…&t=m&hl=fr` ouverte dans **Internet Explorer** (chemin codé en dur `C:\Program Files\Internet Explorer\iexplore.exe`) — cassé sur Windows récents.

---

## 6. Listes et recherches (filtres SQL exacts)

### 6.1 `Form_ListeSiteGenerale.Filtrer` (ouvert par `Form_MenuClimAccess.Image25_Click`)
Base : sous-formulaire `SiteListe` sur la vue SQL Server **`ListeSite`** (`SELECT * FROM ListeSite`, définition non exportée ; colonnes = `Site.*` + `Client.*` + `Expr1` d'après `txtNumeroBon_Exit`) ; si `ChkModification` coché → **`ListeSite2`** (requête Access : `Site × Client WHERE Client.affcli=True`, jointure perdue à l'export). Conditions ajoutées avec ` AND ` :
- `coche_intervenir_Avec_Inter` : `( cptsit=<id1> or cptsit=<id2> … )` construit depuis `select distinct cptsit from Intervention where Intervention.staint=17` (sites ayant des interventions « Ne plus intervenir »).
- `cboClient` : `[numcli]=<n>`.
- `ChkSansLongitudeLatitude` : `([longitude] is null OR [latitude] is null)`.
- `CocherInvest` (tri-état) : True → `([Invest] is not null and [Invest]=1)`, False → `… =0`, Null → rien.
- `CocherRetard` : `([misajoursecurite] is not null and [misajoursecurite]=1|0)` (retard paiement).
- `coche_intervenir` : `([majregistresecuritefait] is not null and [majregistresecuritefait]=1|0)` (ne plus intervenir).
- `CocherParticulier` : `([demixasit] is not null and [demixasit]=1|0)`.
- `ChkNonRooftop` : `([precisiongeo]<>'ROOFTOP' or [precisiongeo] is null)`.
- `txtrefliint` : `cptsit in (select cptsit from intervention where refcliint like '%<txt>%')` (référence client d'intervention).
- `CboNumSit` (texte saisi) : `((nomsit like '%<txt>%') [OR (numsit = <txt>)] ) [AND numcli=<cboClient>]`.
- `RefMat` : `(SiteMateriel.reference like '%<txt>%')` avec `inner join SiteMateriel on SiteMateriel.numerosite=site.cptsit`.
- `ChkCE` : `(SiteMateriel.CE_EDITE=0 and YEAR(SiteMateriel.DateCE)=<année>)` avec la même jointure.
- Si jointure matériel : requête explicite `select cptsit,numsit,numcli,codsit,nomsit,nomsocsit,sitsit,typsit,adrsit,…,TarifSousTraitDesenfum from site inner join SiteMateriel … where <filtre> group by <mêmes colonnes>` (« NOTA COMSIT ne peut etre cherché car le type est ntext »).
- `CboCode_AfterUpdate` / `KeyDown Entrée` / `Texte31_GotFocus` : `SELECT * FROM ListeSite where (codsit like '*<code>*') [AND numcli=<cboClient>]` (joker Access `*`, incohérent avec `%` ailleurs).
- `txtNumeroBon_Exit` : `SELECT <toutes colonnes Intervention + ListeSite> FROM ListeSite INNER JOIN Intervention ON ListeSite.cptsit = Intervention.cptsit WHERE intervention.numint = <n° bon>` (recherche d'un site par n° de bon d'intervention).
- `Form_Load` maximise, redimensionne, appelle `Filtrer` (avec les tri-états à Null : liste complète).
- Sous-formulaire `SiteListe` (`Form_SiteListe.Form_Load`) réordonne/dimensionne les colonnes (Chemin Dossier, redevances, contrats chaudière/désenfumage, ST, tarifs) ; `nomsit_DblClick` → fiche Site ; extrait `Form_44` : libellés « Tarif 1 Clim FMC » (mntredev), « Tarif 2 Clim FMC » (montantredevancefiltre), « Date prise en charge clim », « Sous-Traitant Clim/Chaudiere/Desenfumage », « Tarif Desenfumage FMC » (TarifSousTraitDesenfum — libellé douteux), « RDV à Prendre ».

### 6.2 `Form_RechercheSite.CmdRechercher_Click` (ouvert par `Form_MenuPrincipal.CmdRechercherSite_Click`)
Ouvre `Site` avec le filtre : `[nomsit] like '*<nom>*'` AND `[numsit] = <n°>` AND `[vilsit] like '*<ville>*'` AND `[codpossit] like '<département>*'` AND `[numcli] = <Form_MenuPrincipal.LstClient>` (chaque terme si saisi ; le cadre « Mise à jour du registre de sécurité : Cochée/Non cochée/Indifférent » est **commenté**, donc inactif).

### 6.3 Recherche dans `Form_Client.lstClient` — §1.2. `Form_MenuPrincipal.CmdOuvrirSite_Click` : `Site` filtré `numcli=<LstClient>`.

### 6.4 `Form_ListeSousTraitGenerale.Filtrer` (bouton Rechercher)
RecordSource `Select * from intervenant where <filtre>` :
- `cboInterv` : ` codint ='<code>'`.
- `CocherExistePus` : `(ExistePlus=1)` si coché **sinon `(ExistePlus=0)`** (les disparus sont toujours exclus par défaut).
- `ChkSansLongitudeLatitude` : `([longitude_interv] is null OR [latitude_interv] is null)`.
- `Prospect` : `(Status_Prospect=1)` ; `STFMC` : `(Status_ST_FMC=1)` ; `Tech` : `(EstTech=1)` ; `STFMCPONCT` : `(Status_ST_FMC_Ponctuel=1)`.
- `coche_intervenir` : `([NePlusIntervenir] is not null and [NePlusIntervenir]=1)`.
- `ChkNonRooftop` : `([precisiongeo_interv]<>'ROOFTOP' or [precisiongeo_interv] is null)`.
- `LstZone` (multi) : `([numzonint]=z or [numzonint_2_Interv]=z or [numzonint_3_Interv]=z or [numzonint_4_Interv]=z Or Zone_Nationale = 1 …)` (**les intervenants « Zone Nationale » sortent pour toute zone**).
- `Lst_Activ` (multi) : `([Activite_1]=a or … [Activite_6]=a …)`.
- `InfosInterv` : `((nomint like '%t%') or (adrint like '%t%') or (codposint like 't%') or (vilint like '%t%'))`.
- `CP_Inter` : `((VillesInterventions_Interv like '%t%'))`.
- `Info_Div` : `((Histo_FMC_Interv like '%t%') or (Info_Interv like '%t%'))`.

### 6.5 Autres listes
- `Site sous-formulaire Client` (onglet Sites du Client, `Form_40`) : N° de magasin (`numsit`), Site, Situation, Type, Adresse, CP, Ville, Tél, Fax, Civilité, Nom, Prénom, Surface Vente/Totale, Nbre Entretien, Dernière visite désenfumage, Commentaire, Tel. centre co., Créé le, Redevance, Pris en charge le, MàJ registre sécurité (`misajoursecurite`). Tri `nomsit, numsit`.
- Requêtes Access de listing (SQL partiel) : `ListeSiteIntervenant`, `ListeSiteIntervenantNum`, `ListeSiteSimple*` (sites par intervenant/zone via `parametre`), `SiteSansIntervention` (sites avec entretien prévu non réalisé sur la période `parametre.datdeb/datfin`), `Site_Redevance` (`Count(cptsit), mntredev, IIf(typsit='H et F','H',typsit)` par client), `All_Sites`.
- `Form_Carte`/`Form_Map` : §5.

---

## 7. Audits (`Form_Audit`)

- `Form_Audit.vba` ne contient **aucun code**. Extrait `Form_60_Audit.txt` : en-tête **« BROUILLON »**, RecordSource `Audit`, combos Client (`SELECT numcli, nomcli FROM Client`) et Site (`SELECT cptsit, nomsit, vilsit FROM Site`), `dateaudit`, sections « 1 - CLIMATISATION / PRODUCTION CALORIFIQUE / FRIGORIFIQUE » (sous-formulaire `AuditClimatisation` : Marque, Reference, NumeroSerie, Type, FluideQuantite, AccessibiliteGroupe/Cassettes, Emplacement, Etat, Observations, NumeroSiteMateriel), « REGULATION / COMMANDE » (`AuditRegulationCommande` : type/nb/emplacement/état/hauteur télécommande), « COUPURE DE PROXIMITE », « CONDENSATS » (pompe de relevage, PVC/souple, diamètres, raccordement EU/EP/EXT, cheminement), « LOT AERAULIQUE » (diffuseurs, gaines, galva, reprise), « ROOF TOP », « 2 - RIDEAU D'AIR CHAUD », « 3 - VENTILATION », « 4 - DESENFUMAGE », « 5 - PROTECTION ELECTRIQUE », « 6 - PHOTOS », « 7 - PLAN ». Table `Audit` : panoplie hydraulique (bits), observations, condensats, aéraulique, photos à réaliser.
- Volumes : `Audit` 1 ligne, `AuditAerotherme`/`AuditClimatisation`/`AuditRegulationCommande`/`AuditRoofTop` 0 ligne → **module prototype jamais mis en production**. Ouvert par `Form_MenuClimAccess.ImgAuditASaisir_Click`.
- En pratique l'« audit » = **relevé Excel du parc importé dans `SiteMateriel`** (§3.4), flags `Site.auditafaire/auditfait`, type d'intervention 9 « AUDIT » (carte), et la table `TypeAudit` sert de liste de types d'équipement. Recommandation implicite : ne pas migrer les tables `Audit*`.

---

## 8. Règles métier découvertes et messages utilisateur

### 8.1 Génération du planning prévisionnel d'entretien d'un site (`Form_Site.CmdRegenerer_Click`)
1. `nbrentsit` obligatoire : « Merci de saisir le nombre de visite d'entretien pour pouvoir générer le planning prévisionnel. »
2. Supprime les entretiens prévus non réalisés du site : `delete from intervention where datintpre is not null and datint is null and cptsit=<site>` (**tous types !**).
3. Date de départ = dernier `datint` d'entretien réalisé (`typint='1'`) ; sinon `15/12/<année-1>`.
4. Intervenant = premier intervenant de la zone du site (§4.6) sinon message critique et abandon.
5. Pas de semaines : 4 visites → 13 semaines ; 6 → 9 ; sinon `Int(52 / nbrentsit)`.
6. Nombre à générer = `nbrentsit − nb d'entretiens déjà réalisés dans l'année (typint='1' and staint=9)`.
7. Chaque date : recule d'un jour si férié (`Calcul.EstFerie`, table `joursferies`) ; samedi → vendredi ; dimanche → lundi. Insère `Intervention(cptsit, datintpre, typint='1', staint=1, codint, datheuapp=Null)`.

### 8.2 « Ne plus intervenir » sur un site (`Form_Site.CochePasIntervenir_Click`, `Gestion_Ne_Pas_Intervenir`)
- Cocher : « Attention, Vous allez faire passer toutes les intervention en cours au statut 'Ne plus intervenir', (Pensez à noter leur statut precedent avant de faire cette action), Confirmez vous? » → `UPDATE Intervention SET staint=17 WHERE cptsit=<site> and (staint=-1 or staint=1 or staint=9)`.
- Décocher : réservé à l'utilisateur spécial (`Calcul.Kadi_Logge`, identifié dans `Form_MenuClimAccess.Image110_Click` : utilisateur `NumGestEnCours=367` + mot de passe saisi, non recopié ici) : « Attention, Vous allez faire passer les intervention du statut 'Ne plus intervenir' au statut 'à planifier', Confirmez vous? » → `staint=17` → `1`. Sinon « Attention, Vous n'etes pas autorisé a faire cette modification » (titre « Login Necessaire »).
- Donc : **staint 1 = à planifier, 17 = ne plus intervenir ; -1, 1, 9 = statuts « en cours » concernés.**

### 8.3 Droits sur le statut de facturation (`Calcul.Verification_Droit_Modif`) : autorisé si `Kadi_Logge`, sinon autorisé seulement si `dbo_StatutFacture.QueKadi = False` pour l'ancien **et** le nouveau statut. Message : « Vous n'avez pas les droits pour faire ce changement » (titre « Interdit »).

### 8.4 Garanties (`Form_Site.Calcul_Affiche_Garantie`) : pour chaque durée (années) non nulle, garantie « EN COURS » si `DateDiff("d", datemiseenservicesite, Now) < durée × 365` ; image `ImageGarantie` si au moins une.

### 8.5 Fermeture de site → client 368 (§2.4). Changement de client → propagation devis/contrats (§2.3).

### 8.6 Tarifs : client (`coutheuremainoeuvre`, `coutdeplacement`) surchargés par site si `AvecPrixSite` (`PrixMO`, `PrixDepl`) ; tarifs ST par lot et par site ; tarifs ST par activité (MO/DP) sur la fiche intervenant.

### 8.7 CE : éligibilité `CE_EDITE=0 and YEAR(DateCE)=année`, pré-contrôles et seuils Cerfa (§3.6). Messages : « Les CE ont deja été édités » (« Déja Fait!! »), « La génération du CE n-m n'as pas pu se faire correctement, cause: … », « Erreur: Export Vers PDF Annulé. », « Merci de Selectionner le repertoire pour le PDF puis cliquez sur OK ».

### 8.8 Références catalogue : validations et propagation (§3.5). Messages : « Veuillez verifier le nom de la reference », « …la puissance calorifique, elle est en W », « Le nom de la reference existe deja dans la base », « Attention, Vous allez Creer une nouvelle reference… ».

### 8.9 Import audit : « Vous allez importer le fichier d'audit!!,,vous etes sur(e) ?,c'est votre dernier mot ? », « Le fichier choisi doit etre: Fichier_Audit.xlsx », « Une prochaine fois etre... » (« Tant Pis »), « Import Audit Terminé de N Lignes OK avec M Lignes pas OK ».

### 8.10 Géolocalisation : « La géolocalisation est vide, confirmez-vous la sortie » ; « An error occurs during the geocoding... ».

### 8.11 Le sigle « CE » a **deux sens** : « CE EN COURS » (`EtiquetteContratEnCours`, = **Contrat d'Entretien** actif) vs « CE à faire / CE fait / CE à Editer / Generer le CE » (= **Contrôle d'Étanchéité**). À lever dans la cible.

### 8.12 Divers : `Renseigner_Tech` stocke des noms de techniciens dans `Intervention.numdevpartenaire` ; `Form_Site.Form_Delete` des sous-formulaires supprime physiquement l'intervention ; le sous-formulaire des interventions clôturées ne montre que `staint ∈ {7,8,10,20}`.

---

## 9. Codes et libellés

| Code | Valeurs / signification | Source |
|---|---|---|
| `Site.sitsit` (Situation) | `Clim. dépendante (centre commercial)`, `Clim. indépendante (centre commercial)`, `Clim. dépendante (centre ville)`, `Clim. indépendante (centre ville)`, `Eficia avec pilotage`, `Eficia sans pilotage` (texte stocké tel quel, nvarchar(50)) | `Form_6` Value List |
| `Site.typsit` (Type) | `H`, `F`, `H et F` ; `Site_Redevance` ramène `'H et F'` à `'H'`. **Signification non explicitée** : très probablement H = chaud/chauffage, F = froid (réversible = « H et F ») — déduction | `Form_12`, `Site_Redevance.sql` |
| `Site.indclitec` (Indice Qualité) | `1 réalisé par nous`, `2 connu de nous`, `3 à auditer par nous`, `4 modifié par nous` | `Form_6` |
| `Site.indvetust`, `Intervenant.IndMaint_Interv` | 1..5 étoiles (Wingdings) | `Form_6`, `Form_83` |
| `Site.indpuissance`, `indaccessib`, `Intervenant.Ind_*` | tinyint, listes non extraites (vraisemblablement 1..5) | — |
| `misajoursecurite` | = **Retard paiement** ; `majregistresecuritefait` = **Ne plus intervenir** ; `majregistresecuriteafaire` = **Nacelle nécessaire** ; `demixasit` = **Particulier** ; `aspirateur`/`accessfiltre` = arrêt d'urgence clim OUI/NON ; `controleetancheiteponctuel` = système de détection de fuite | `Form_6`, `Form_ListeSiteGenerale.Filtrer` |
| `Client.cheminpla/cheminpho` | N° Esabora Clim / Maint ; `Donneur.meldonneur/cheminpho/cheminpla` = lignes 1-3 de pied de page (et cheminpho = logo) | `Form_14`, `Form_33` |
| `Intervention.typint` (texte) | 1 ENTRETIEN, 2 DEPANNAGE, 3 TRAVAUX SELON DEVIS, 4 AUTRE, 5 EN TRAVAUX, 6 (exclu des stats `ListeSiteSimpleResume`), 7 DESENFUMAGE, 9 AUDIT ; table `TypeInterv.IndexLigneSTRING` | `Form_Carte`, `Form_MenuPrincipal` |
| `Intervention.staint` | 1 à planifier ; 9 effectuée (compte comme visite faite) ; 7 archivée/clôturée (`ChkShowArchived`, `datedernierevisiteentretien` = max datint avec staint=7) ; 8, 10, 20 clôturés ; 17 Ne plus intervenir ; -1 en cours (jaune sur la carte) ; libellés dans `dbo_StatusInterv` | `Form_Site`, `Form_Carte`, `Form_13/29` |
| `StatutDevis` | 1 Devis à viser, 2 Aucun Retour Client, 3 Devis annulé et remplacé par, 4 Envoyé, 5 Devis refusé par le client, 6 Devis accepté ; « en cours » = 1,2,4 | `Form_29`, `Form_Site.Form_Activate` |
| `Intervention.devisepar` (réutilisé « Urgence Devis ») | 1 Faible, 2 Moyenne, 3 Forte | `Form_13` |
| `SiteMateriel.Reversible` / `ResistanceElectrique` | `OUI`, `NON`, `NC` | `Form_58`, `Form_81` |
| `SiteMarqueReference.type` | `CLIM`, `RAC`, `VENTIL` | `Form_7` |
| `Liste_Type_Gaz.Libelle` | `HCFC`, `HFC`, `HF0` (+2 autres non utilisés pour le CE) | `PDFCE`, `Report_Test Cerfa` |
| `precisiongeo` | `ROOFTOP` = meilleure précision Google ; autres valeurs Google | `Form_Site.CmdGeocoder_Click` |
| `Client 368` | pseudo-client « fermé » | `Form_Site.fermeture_Click` |
| `codint 'FMC'` | intervenant interne par défaut | `Form_Planification` |
| `Utilisateur 367` | compte « Kadi » à droits étendus | `Form_MenuClimAccess.Image110_Click` |

---

## 10. Dépendances externes

| Élément | Où | Usage |
|---|---|---|
| `<dossier .accdb>\geo.html` (Leaflet, icônes colorées) | `Form_Carte` | carte interventions |
| `<dossier .accdb>\geocoding.html` (objet JS `oMap`, Google Maps) | `Form_Map` | carte sites / géocodage |
| `<dossier .accdb>\cartefmc.html` | `Form_Carte.SaveHTML` (non appelé) | export carte |
| `http://maps.googleapis.com/maps/api/geocode/xml?address=…&sensor=false` | `Geocoding.Geocode` | géocodage, **HTTP sans clé** (API dépréciée) |
| `http://maps.google.com/maps?q=…` + `C:\Program Files\Internet Explorer\iexplore.exe` | Client/Donneur/Site `CmdMap(s)_Click` | « Voir sur Maps » |
| Contrôle ActiveX WebBrowser (`Shell.Explorer.2`) | Carte, Map | rendu HTML |
| Excel (COM `Excel.Application`), fichiers `Fichier_Audit.xlsx` (nom imposé) | `Form_Site`, `Form_Parametrage` | import parc matériel |
| `\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Extraction_Materiel.xlsx`, `Fichier_Stat.xlsx`, `Fichier_Stat_OGF.xlsx` | `Form_Filtre Extraction`, `Form_00 - Statistiques Clients` | modèles d'export (chemins `c:\` en test « Fersoft ») |
| `Site.chemindoc` (raccourci réseau « texte#\\chemin# »), `Intervenant.DossierOrdi_Interv`, `Intervention.cheficdemint` | fiches | dossier documentaire par site/intervenant ; `PDFCE` propose ce dossier pour les PDF CE ; `Form_Intervention.Commande399_Click` ouvre l'explorateur |
| `Donneur.cheminpho` (chemin relatif au .accdb, tronqué au `#`) | `Form_Donneur.DisplayImage` | logo |
| `Intervention.sigtecimg`, `sigcliimg` (chemins fichiers) | `Report_Test Cerfa` | images de signature sur le Cerfa |
| État `Test Cerfa` → PDF `<NumeroInter>-<NumeroSiteMateriel>.pdf` | `PDFCE.PDF_CE` | Cerfa contrôle d'étanchéité |
| `C:\Users\Public\<AAAA>\<M>\FichierVieAccess.txt` | `PDFCE.UpdateFichierBanane` (timer du menu) | fichier « heartbeat » (« Je suis Vivant! ») pour supervision externe |
| Table `Dbo_Demande_Web` (`NumUser`, `Type_Demande`, `Data1..3`) | `Form_MenuClimAccess.TraiteDemandeWeb` | une appli web demande à Access d'ouvrir la fiche Site `cptsit=Data2` (intégration web → Access) |
| Outlook (`Outlook.Application`), `https://intervention.fmc-maintenance.fr/interventionstest/Default.aspx` | `Form_Parametrage.EnvoiMail` | envoi d'identifiants du portail web (hors périmètre, cité pour l'écosystème) |
| « Esabora » | `Client.cheminpla/cheminpho` | numéros dans un logiciel tiers (facturation/GMAO ?) |
| Rapports Access « 137 - Liste des sites avec aspirateur », « 137bis » | `Form_Zone Geographique`, `Form_MenuPrincipal` | listes sites par client/zone |
| Vues SQL Server `ListeSite`, `ListeInterventionGenerale` | `SiteListe`, `Carte` | définitions non exportées (`sql_modules.sql` vide) |

---

## 11. Points d'incertitude

1. **Définition de la vue `ListeSite`** (et `ListeInterventionGenerale`) inconnue ; on sait seulement qu'elle joint Site et Client (colonnes `nomcli…coutdeplacement`, `Expr1`). Différence exacte avec `ListeSite2` (filtre `affcli=True`) et sens du libellé de `ChkModification` (« 22/06/20 ListeSite Non Modif ») non établis.
2. **Qui alimente `SiteMateriel.DateCE` / `NumeroInter`** et `Site.datedernierevisiteentretien` au quotidien : aucun UPDATE dans le VBA lu (hormis `Report_ListeInterventionGenerale sans quadrillage` pour la dernière visite). Vraisemblablement l'application mobile/web partageant la base.
3. **Signification de `typsit` H / F / H et F** : déduite (chaud/froid), non confirmée par le code.
4. **« Fersoft »** : identifié comme prestataire/environnement de développement par déduction (commentaires « Pour Test Fersoft »). Le nom `Intervenant_Fersoft` peut aussi désigner une version testée chez Fersoft.
5. **Esabora** : nature du logiciel tiers non décrite dans le code.
6. **Contenu de `geo.html` / `geocoding.html`** (fond de carte, clé API Google éventuelle, icônes) non disponible ; le géocodage Google en HTTP sans clé ne fonctionne plus depuis 2018 → la fonction est probablement **hors service** aujourd'hui.
7. **Listes `indpuissance`, `indaccessib`, `Ind_Depann/Travaux/React_Interv`** : RowSource non extraites (supposées 1..5).
8. **Contrôle « Qté FF »** du sous-formulaire matériel : très probablement lié à `NbreRadiateurs` (quantité de fluide), non prouvé par l'extrait.
9. **Nom du client 368** (« client fermé ») non disponible (données non exportées).
10. **`Form_Donneur.CmdAddSite_Click`** utilise `Me.numcli` sur une fiche Donneur : contrôle probablement non lié ou reliquat ; comportement réel incertain.
11. **Double usage de `Donneur.cheminpho`** (logo sur la fiche vs « Ligne 2 Pied de page » dans le paramétrage) : l'un des deux libellés est obsolète, impossible de dire lequel.
12. **Règle d'affectation de l'intervenant** divergente entre `Form_Site.CmdRegenerer_Click` (par zone) et `Form_Planification` (ST clim → intervenant du site → FMC) : laquelle fait foi aujourd'hui ?
13. **Jokers `*` vs `%`** mélangés dans les filtres (`CboCode`, `RechercheSite` en `*` ; le reste en `%`) : dépend du mode ANSI de la base Access ; certains filtres peuvent ne rien renvoyer.
14. `Repere.CtrlEtancheite` : usage réel inconnu (non lu dans Access).
15. Formulaire `Map` : aucun point d'entrée trouvé → obsolète ou ouvert manuellement.
16. `Site.numzone2`, `nomsocsit`, `datesignaturecontrat`, `montantredevancetechnique`, `NumEsabora`, `Mess_Devis` (rempli par `Form_DevisListe*`) : présents en table, non visibles sur la fiche Site analysée.
17. `SiteNombreEntretien` (historique de `nbrentsit` avec `datfin`, 0 ligne) et `Photo`/`Plan`/`Plans` (0 ligne) : tables abandonnées ; `nbrplan`/`nbrpho` sont saisis à la main.
