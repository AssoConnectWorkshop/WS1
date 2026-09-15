# logiclim — analyse du schéma SQL Server et modèle cible

Sources : `schema.sql` (DDL DBeaver, 78 tables), `rowcounts.csv`, `foreign_keys.csv`.
Complète `ANALYSIS.md` (front-end Access).

## 1. Vue d'ensemble

| Catégorie | Tables | Lignes |
|---|---|---|
| Cœur métier | Client, Site, Intervention, FicheIntervention, InterventionTechnicien, HeuresTech, Devis, DevisTravaux, ContratDeMaintenance, SiteMateriel, SiteMAJRegistre, Intervenant, Utilisateur, Donneur, Contact, Planification | ~560 000 |
| Référentiels | 20 tables (statuts, types, pannes, zones, marques, fluides…) | ~1 200 |
| Parc auto | Vehicules, EvVehicules, ListeEtatVehicule, ListeEVVehicule | ~900 |
| Audits | Audit, AuditAerotherme, AuditClimatisation, AuditRegulationCommande, AuditRoofTop | 1 |
| Staging / imports Excel | C16, C24, C33, ClientRMA, ClientRMANew, annuaire | ~3 400 |
| Doublons / copies de travail | Plan1, planning, planning1, parametre1, TopTen1, HeuresTechAuto | ~40 500 |
| Vides ou techniques | Photo, Plan, Plans, HistoCnx, SiteNombreEntretien, InterventionFicheFluide, InterventionFourniture, PanneMaterielSite, ZoneSociete, TopTen, dtproperties, Demande_Web, FiltreClimAccessMobile | ~0 |

Seules **9 clés étrangères** sont déclarées. Toutes les autres relations sont implicites
(nommage `numcli`, `cptsit`, `numuti`…) et devront être reconstruites et vérifiées lors
de la migration.

Vues non exportées : `ListeInterventionGenerale`, `ListeSite`, `Vue_FileMaker` (+1).
L'export `sql_modules.sql` a échoué sur un conflit de collation ; commande corrigée en §6.

## 2. Modèle métier reconstitué

```
Client (2 323) ──< Site (6 163) ──< Intervention (71 694) ──< FicheIntervention (101 837)
   │                  │                   │                   ──< InterventionTechnicien (81 659) >── Utilisateur (317)
   │                  │                   ├── Devis / DevisTravaux / ContratDeMaintenance (19 822)
   │                  │                   ├── Intervenant (193)  [technicien interne ou sous-traitant]
   │                  │                   ├── Panne (49), ModeResolution (4), StatusInterv (10), TypeInterv (13)
   │                  │                   └── Contact (57)
   │                  ├──< SiteMateriel (29 511)         [équipements CVC installés]
   │                  ├──< SiteMarqueReference (11)
   │                  ├──< SiteMAJRegistre (22 310)      [mises à jour du registre de sécurité]
   │                  ├── ZoneGeographique (43), TypeFluide (13), Donneur (103)
   │                  └── Intervenant ×3 (sous-traitant clim / désenfumage / chaudière)
   ├──< Planification (166)  [T1..T12 : dates de visites, récurrence]
   ├──< ClientCredential (2)  [portail client]
   └──< Contact
Utilisateur ──< HeuresTech (102 637) [pointage horaire des techniciens]
Utilisateur ──< Vehicules (38) ──< EvVehicules (866) [km, entretiens]
Societe (124) ──< Utilisateur ; ZoneSociete (vide)
ModeleRepertoireTechnique ──< ParametreRepertoireTechnique >── ChampRepertoireTechnique
```

### Identifiants doubles
- `Site.cptsit` (PK technique) et `Site.numsit` (numéro visible par le client, non unique).
- `Intervention.numintint` (PK) et `Intervention.numint` (numéro visible).
- `Intervenant.numintervenant` (PK) et `Intervenant.codint` (code unique, utilisé par la FK).

À conserver tous les deux dans la cible : PK technique + numéro métier.

### Relations implicites (à formaliser)

| Colonne | Cible |
|---|---|
| Site.numcli, Contact.numcli, Devis*.NumeroClient, Planification.numcli | Client.numcli |
| Site.numzonsit, numzone2 | ZoneGeographique.numzon |
| Site.donneurid, Contact.numdonneur | Donneur.donneurid |
| Site.typfluid | TypeFluide.id |
| Site.numintervenant, NumSousTraitClim/Desenfum/Chaudiere, Intervention.numpartenaire | Intervenant.numintervenant |
| Intervention.staint | StatusInterv.IndexLigne |
| Intervention.typint (**nvarchar**) | TypeInterv.IndexLigneSTRING |
| Intervention.nummodres | ModeResolution.nummodres |
| Intervention.codcon | Contact.codcon |
| Intervention.traitepar, saisiepar, imprimeepar, classeepar, prediagpar, devisepar, envoisoustraitantpar, retourficheinterventionpar, duplicatacreepar, numutipre | Utilisateur.numuti |
| Devis*.NumeroSite, SiteMateriel.NumeroSite, SiteMAJRegistre.cptsit | Site.cptsit |
| Devis*.NumeroInterventionInterne, InterventionTechnicien.numintint, FicheIntervention.numIntInt, HeuresTech.NumInterv | Intervention.numintint |
| Devis*.EnvoyePar, InterventionTechnicien.numuti, HeuresTech.NumeroTech, Vehicules.Conducteur | Utilisateur.numuti |
| Utilisateur.numsoc | Societe.numsoc |
| Utilisateur.codintuti | Intervenant.codint |

## 3. Problèmes de qualité à corriger en migrant

- **Trois tables Devis identiques** (`Devis`, `DevisTravaux`, `ContratDeMaintenance`) : fusionner en une table avec une colonne `type`.
- **Colonnes répétées** au lieu de lignes : `Planification.T1..T12`, `planning.Semaine 1..52`, `Intervenant.Activite_1..6` (+ `MO_`, `Depl_`, `Date_`), `Intervenant.numzonint_2..4`, `Site.hor_lun_ouv..hor_dim_fer`.
- **Types faibles** : dates en `nvarchar` (`Site.datcresit`, `SiteMateriel.DateMiseEnService`), heures en `varchar(5)`, `typint` en texte, `Reference` entièrement en `nchar(50) NOT NULL`, `Reversible char(5)`.
- **Binaires et fichiers dans la base** : logos en `image` (`Client.logcli`, `Donneur.logdonneur`), signatures en base64/JSON dans `Intervention` (`sig*img`, `sig*json`, `sig*base64`), chemins de fichiers Windows (`NomFichierDevis`, `chemindoc`, `cheminpho`) → **Supabase Storage**.
- **Mots de passe en clair** : `Utilisateur.mdputi`, `ClientCredential.password` → **Supabase Auth**, pas de migration des mots de passe.
- `Intervention_Status_Changed_history` (69 883 lignes) ne contient que `numintint` : aucun statut ni date, inexploitable en l'état.
- `HeuresTechAuto` : copie de `HeuresTech` plafonnée à 40 000 lignes, probablement un cache.
- `Intervention.RV timestamp` : rowversion SQL Server, à remplacer par `updated_at`.
- Indices `missing_index_*` et `_dta_index_*` : générés par le tuning advisor, à ne pas reprendre tels quels.

## 4. Signaux d'autres applications sur cette base

Ces tables suggèrent qu'un **portail web / une appli mobile** partage la base avec Access :
`ClientCredential` (login client), `Demande_Web`, `FiltreClimAccessMobile`, `HistoCnx`,
signatures `sig*json` / `sigsitbase64`, `Intervention.rappel24h/48h/72h`, `dateenvoimail`.
À confirmer avant de couper SQL Server : quels autres programmes lisent ou écrivent dans `logiclim` ?

## 5. Modèle cible Supabase (proposition)

Convention : snake_case, `id bigint identity`, `legacy_id` pour garder l'ancien identifiant,
`created_at` / `updated_at`, RLS par rôle.

| Table cible | Source | Notes |
|---|---|---|
| `clients` | Client | logo → Storage `logos/` |
| `donneurs_ordre` | Donneur | |
| `contacts` | Contact | FK client + donneur |
| `zones_geographiques` | ZoneGeographique | |
| `societes` | Societe | |
| `utilisateurs` | Utilisateur | lié à `auth.users`, rôle (`typuti`), société |
| `intervenants` | Intervenant | colonnes fixes uniquement |
| `intervenant_activites` | Intervenant.Activite_1..6 + MO/Depl/Date | une ligne par activité |
| `intervenant_zones` | Intervenant.numzonint(_2..4) | |
| `sites` | Site | horaires en `jsonb` ou table `site_horaires` ; 3 FK sous-traitants |
| `site_materiels` | SiteMateriel | |
| `site_marques_references` | SiteMarqueReference (+ Desenfumage via `type`) | |
| `site_registre_securite` | SiteMAJRegistre | |
| `interventions` | Intervention | signatures → Storage `signatures/` ; `type_id`, `statut_id` typés |
| `intervention_techniciens` | InterventionTechnicien | |
| `fiches_intervention` | FicheIntervention | |
| `intervention_fournitures` | InterventionFourniture | vide aujourd'hui, à garder |
| `heures_techniciens` | HeuresTech | ignorer HeuresTechAuto |
| `devis` | Devis ∪ DevisTravaux ∪ ContratDeMaintenance | `type` enum ; PDF → Storage `devis/` |
| `planifications` | Planification T1..T12 | une ligne par visite planifiée |
| `pannes`, `modes_resolution`, `statuts_intervention`, `types_intervention`, `statuts_facture`, `sous_types`, `types_fluide`, `marques`, `references_materiel`, `reperes`, `types_telecommande`, `types_audit`, `jours_feries`, `visites_maintenance` | référentiels | |
| `vehicules`, `vehicule_evenements` | Vehicules, EvVehicules | |
| `audits*` | Audit* | **optionnel** : 1 ligne en base |
| `repertoire_technique_*` | ModeleRepertoireTechnique & co | **optionnel** |

Non migrés : C16, C24, C33, ClientRMA*, annuaire, Plan/Plan1/Plans, planning*, parametre*,
TopTen*, dtproperties, Demande_Web, FiltreClimAccessMobile, HistoCnx, HeuresTechAuto,
Intervention_Status_Changed_history, SiteNombreEntretien.

### Méthode de migration des données
Script Node exécuté **sur le PC local** (Docker SQL Server → Supabase via connexion Postgres
directe), idempotent, par lots, avec `legacy_id` pour rejouer et contrôler. Les données ne
transitent jamais par GitHub.

## 6. Export des vues et procédures (commande corrigée)

```powershell
docker exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Str0ngP@ss123!' -C -d logiclim -y 0 -o /backup/sql_modules.sql -Q "SET NOCOUNT ON; SELECT '-- ===== ' + o.type_desc COLLATE DATABASE_DEFAULT + ' ' + s.name COLLATE DATABASE_DEFAULT + '.' + o.name COLLATE DATABASE_DEFAULT + CHAR(10) + m.definition COLLATE DATABASE_DEFAULT + CHAR(10) + 'GO' FROM sys.sql_modules m JOIN sys.objects o ON o.object_id=m.object_id JOIN sys.schemas s ON s.schema_id=o.schema_id ORDER BY o.type_desc, o.name"
```

## 7. Décisions à prendre avant d'écrire les migrations

1. **Périmètre** : cœur seul (clients, sites, interventions, devis, planification, intervenants, matériel) ou aussi parc auto, heures techniciens, audits, répertoire technique ?
2. **Autres applications** connectées à `logiclim` (portail client, mobile) : lesquelles, et sont-elles migrées aussi ?
3. **Fichiers** : où sont les PDF de devis, photos, plans référencés par chemin ? Faut-il les migrer dans Storage ?
4. **Utilisateurs** : qui se connecte à la nouvelle app (salariés FMC, techniciens, sous-traitants, clients) ?
5. **Historique** : tout migrer (71 694 interventions depuis ~2007) ou une fenêtre glissante ?
