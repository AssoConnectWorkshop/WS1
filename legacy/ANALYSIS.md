# ClimAccess — analyse du fichier `ClimAccess 2026-05-06.accdb`

Source : release GitHub `legacy-accdb` (132 MB, format ACE14 / Access 2010).
Extraction réalisée avec mdbtools ; artefacts dans `legacy/extracted/`.

## 1. Nature de l'application

**ClimAccess est un front-end Access.** Les données métier ne sont pas dans le .accdb :
63 tables sont liées en ODBC vers une base **SQL Server `logiclim`** (DSN `CLIMACCESS`).
Le .accdb ne contient que l'interface (formulaires, états, requêtes, VBA) et quelques
tables locales de travail.

| Objets | Nombre | Extrait ? |
|---|---|---|
| Tables liées SQL Server | 63 | Noms seulement (colonnes partielles via les requêtes) |
| Tables locales | 14 | Schéma + données (import/staging, planning, paramètre) |
| Requêtes nommées | 72 | SQL partiel (jointures perdues, requêtes action vides) |
| Sources de formulaires / contrôles | 342 | SQL partiel |
| Formulaires | 114 | Noms + source de données |
| États | 8 | Noms |
| Modules VBA | 7 | Noms (`Calcul`, `ClasseTech`, `Geocoding`, `ImportExcel`, `Module1`, `PDFCE`, `Parcourir`) |
| Macros | 3 | Noms (`ImportAnnuaireAT`, `ImportAnnuaireCELIO`, `sABLIER`) |

Note sécurité : la chaîne ODBC embarque un identifiant et un mot de passe SQL Server en clair.
La table `Utilisateur` a une colonne `mdputi` (mot de passe applicatif, probablement en clair aussi).

## 2. Domaine métier

Gestion de **maintenance CVC** (climatisation, désenfumage, chaudières) pour des enseignes
de retail : Celio, Calzedonia, Intimissimi, GIFI, OGF, André, SAS… Une société de
maintenance (FMC / ClimTech) pilote des interventions réalisées par des techniciens
internes ou des sous-traitants sur des centaines de magasins.

### Entités principales (tables SQL Server)

```
Client (enseigne) ──< Site (magasin) ──< Intervention ──< FicheIntervention
                          │                  │            InterventionTechnicien
                          │                  │            InterventionFourniture
                          │                  └── Devis / DevisTravaux
                          ├──< SiteMateriel (équipements CVC installés)
                          ├──< SiteMarqueReference / …Desenfumage
                          ├──< Planification (visites T1..T12)
                          ├──< Photo, Plan, SiteMAJRegistre
                          └──< Audit* (AuditRoofTop, AuditRegulationCommande)
Intervenant (technicien / sous-traitant, activités, zones)
Donneur (donneur d'ordre côté client) ──< Contact
ContratDeMaintenance
Référentiels : Marque, Reference, Repere, TypeFluide, TypeTel, TypeAudit, Panne,
               ModeResolution, ZoneGeographique, ZoneSociete, Societe, Activites,
               dbo_TypeInterv, dbo_StatusInterv, dbo_StatutFacture, dbo_SousType
Parc : dbo_Vehicules, dbo_EvVehicules, dbo_HeuresTech, dbo_HeuresTechAuto
Sécurité : Utilisateur, ClientCredential, dbo_Demande_Web, FiltreClimAccessMobile
```

### Champs clés repérés

- **Site** (~100 colonnes) : identité et adresse, géoloc (`latitude`, `longitude`,
  `precisiongeo`), horaires d'ouverture par jour, redevances (technique, filtre,
  désenfumage, chaudière), nombre de visites par type, sous-traitants par lot
  (`NumSousTraitClim`, `NumSousTraitDesenfum`, `NumSousTraitChaudiere`), indicateurs
  (qualité, vétusté, puissance, accessibilité), suivi réglementaire (contrôle
  d'étanchéité, registre de sécurité, audit, photos).
- **Intervention** (~85 colonnes) : type (`typint`), statut (`staint`), dates prévue /
  réalisée, heures, technicien (`codint`), panne (`codpan`), mode de résolution,
  facturation (`intafact`, `intfac`, `mntfac`, `mntst`), devis (`numdev`, `stadev`,
  montants), signatures (`sigcli`, `sigtec`, images), circuit papier (fiche originale,
  copie, retour).
- **Devis** : numéro interne / externe, montants HT, statut, fichier PDF, date d'envoi.
- **Planification** : une ligne par site avec `T1..T12` (un mois = une colonne) et
  `nombrevisite`. La table locale `planning` fait de même par semaine (52 colonnes).

## 3. Écrans (formulaires)

Menu d'entrée : `MenuClimAccess` → `MenuPrincipal` (choix client, zone, intervenant).

| Domaine | Formulaires principaux |
|---|---|
| Clients / sites | `Client`, `ClientListe`, `Site`, `SiteListe`, `ListeSiteGenerale`, `RechercheSite`, `Carte`, `Map` |
| Interventions | `Intervention`, `Intervention2`, `InterventionEntretien`, `ListeInterventionGenerale`, `ListeInterventionAttente`, `RechercheIntervention`, `ListeInterGaz`, `ListeKM` |
| Devis | `Devis`, `DevisListe`, `DevisListeTravaux`, `DevisListeContratDeMaintenance` |
| Planification | `Planification`, `PlanificationEntretien` et sous-formulaires |
| Intervenants | `Intervenant`, `Intervenant_Fersoft`, `ListeSousTraitGenerale`, sous-formulaires par activité |
| Matériel / audits | `Saisie_Reference`, `Reference`, `Marque`, `Audit`, `Panne`, `SfMaterielPanne` |
| Parc auto | `Vehicules`, `Saisie_Vehicule`, `Saisie_EV_Vehicule`, `ListeEVVehicules` |
| Statistiques | `00 - Statistiques Clients`, `statistiques` (Top/Flop ten) |
| Paramétrage | `Parametrage`, `ZoneGeographique`, `JoursFeries`, `Utilisateur`, `Societe`, `Tarifs MO et DP`, `ModeleRepertoireTechnique` |
| Imports | `Form_All_Sites`, `Form_All_Inter`, macros d'import annuaire, tables `Import*` |

États : `FicheIntervention` (bon d'intervention), `FaxIntervention*`,
`ListeInterventionGenerale`, `ListeInterventionOM`, `DossierBureauVert`, `Test Cerfa`.

Fonctions VBA repérées : géocodage d'adresses (`Geocoding`), génération PDF (`PDFCE`),
import Excel, envoi d'e-mail (`sendEmail`).

## 4. Requêtes métier notables

- `ListeInterventionAEffectuer`, `…AFacturer`, `…Facturee`, `…Attente`,
  `…EnCoursPlusSansBon` : pipeline de suivi d'une intervention, filtré par la période
  de la table `parametre` (`datdeb`, `datfin`).
- `PlanningEtat`, `Entretiens par trimestre`, `CréerEntretien` : génération et
  affichage du planning d'entretiens.
- `NombreDepannageParSite`, `GIFI - Qté de dépannage par site`, `RequeteTopTen`,
  `RequeteFlopTen`, `FMC - 0x …` : reporting client.
- `Import*`, `000x - mise à jour …`, `AjoutSite` : imports de fichiers Excel clients
  (requêtes action, non extractibles ici).

## 5. Limites de l'extraction

- Les colonnes et types des 63 tables SQL Server ne sont pas dans le .accdb.
  `linked_table_columns.txt` liste seulement les colonnes citées dans les requêtes.
- mdbtools perd les clauses JOIN et n'exporte pas les requêtes action (INSERT/UPDATE).
- Formulaires, états, macros et VBA ne sont pas décodables hors d'Access.

## 6. Éléments nécessaires pour poursuivre

1. **Schéma SQL Server `logiclim`** (indispensable) : SSMS → base → Tâches →
   Générer des scripts → « Schéma et données » → `legacy/schema.sql`.
   Si trop volumineux : schéma seul en .sql + données en CSV.
2. **Export texte des objets Access** (formulaires, états, macros, modules) via
   `Application.SaveAsText` → `legacy/export/`. Donne la logique métier VBA et les
   règles de chaque écran.
3. Confirmation du périmètre : tout migrer, ou seulement le cœur
   (clients, sites, interventions, devis, planification) ?

## 7. Cible envisagée

- **Supabase** : schéma normalisé (`clients`, `sites`, `interventions`,
  `intervenants`, `devis`, `planifications`, `site_materiels`, référentiels),
  colonnes renommées en snake_case explicite, `T1..T12` et `Semaine n` transformés en
  lignes, mots de passe remplacés par Supabase Auth, RLS par société.
- **Next.js** : un module par domaine du tableau §3, listes filtrables côté serveur,
  fiches en Server Components, saisie en Server Actions, PDF de fiche d'intervention
  généré côté serveur, carte des sites, import Excel via upload.
