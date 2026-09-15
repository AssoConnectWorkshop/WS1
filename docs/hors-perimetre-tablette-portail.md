# Hors périmètre : application tablette et portail web

Ces deux applications partagent la base SQL Server `logiclim` avec Access. Elles ne sont pas
reprises dans la migration du bureau. Ce document garde ce qu'on sait pour les reprendre plus tard.

## Application tablette (techniciens)

- Lit la vue `InterventionsMobile` (intervention + site + client, horaires d'ouverture, commentaires)
  et la période visible paramétrée dans `FiltreClimAccessMobile` (`DateDebut`, `DateFin`).
- Écrit dans `Intervention` : signatures (`sigtecjson`, `sigclijson`, `sigsitbase64`, images
  `sigtecimg`, `sigcliimg`, `sigsitimg`, noms `sigtec2`, `sigcli2`, `sigsit2`), `heuarrint`,
  `heudepint`, `tpsallint`, `tpsretint`, `sigsit` (prestations réalisées), `comtec`,
  `datefintech` (retour de fiche), probablement `staint` 9, 19 et 20.
- Écrit probablement `SiteMateriel.DateCE` et `SiteMateriel.NumeroInter` (contrôle d'étanchéité).
- Écrit sans doute dans `HeuresTech` (pointage ; relevés kilométriques `TypeInterv = 60`,
  `NomInterv` au format `...:IMMAT=KM`).
- Lit `Site.Mess_Devis` (résumé HTML des devis envoyés, rempli par Access) et
  `Donneur.sairapdonneur` (« saisie simplifiée sur tablette »).

## Portail web (techniciens, sous-traitants, clients)

- Adresse `https://intervention.fmc-maintenance.fr/interventionstest/Default.aspx`, ASP.NET.
- Comptes : `Utilisateur.loguti` + mot de passe stocké dans `Utilisateur.codintuti` (généré et
  envoyé par Access, en clair), et `ClientCredential` (2 comptes clients).
- Lit via les procédures stockées `Get*_Pager` (voir `legacy/sql_modules.sql`) :
  `GetCustomers_Pager`, `GetInterventions_Pager`, `GetInterventions1_Pager`,
  `GetInterventionsAFaireToday/LastSevenDays/LastFourteenDays_Pager`,
  `GetInterventionsFaites*_Pager`, `GetInterventionsParIntervenant_Pager`,
  `GetInterventionsParZone_Pager`, `GetInterventionsParZoneClient_Pager`,
  `GetInterventionsParZoneFMC_Pager`, `GetSites_Pager`, `GetSites_Client_Pager`,
  `GetSitesIntervenant_Pager`, `GetSitesMANSUY_Client_Pager`, `GetSitesRC_Client_Pager`.
- Écrit dans `Demande_Web` (`Type_Demande = 1`, `Data2 = cptsit`) pour demander à Access d'ouvrir
  une fiche site chez un gestionnaire, et probablement dans `HistoCnx`.

## À obtenir avant de les reprendre

1. Le code source ou le nom de l'éditeur (probablement Fersoft), et la liste des utilisateurs actifs.
2. La confirmation des colonnes écrites, par comparaison de la base à deux dates.

## Deux options

- **Réécriture** dans la même application Next.js : pages mobiles pour les techniciens
  (interventions du jour, heures, signatures, photos) et espace sous-traitant. SQL Server arrêté.
- **Coexistence** : synchronisation SQL Server → Supabase des colonnes écrites par ces outils
  tant qu'ils vivent.

Le schéma Supabase conserve les colonnes de signatures, heures et dates de retour pour ne rien bloquer.
