Attribute VB_Name = "Form_MenuPrincipal"
Attribute VB_Base = "0{5CFC40FE-90CF-49F6-9EDB-DAF981DA89BB}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database
Option Explicit


Private Sub CmdDepanageCuratifCloture_Click()
On Error GoTo Err_CmdDepanageCuratifCloture_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Intervention"
    stLinkCriteria = "(typint='4' or typint='5') and staint=9  and cptsit in (select cptsit from site where numcli=" & Me.LstClient & ")"
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "IDCC"

Exit_CmdDepanageCuratifCloture_Click:
    Exit Sub

Err_CmdDepanageCuratifCloture_Click:
    MsgBox err.Description
    Resume Exit_CmdDepanageCuratifCloture_Click
End Sub

Private Sub CmdDepanageCuratifEnCours_Click()
On Error GoTo Err_CmdDepanageCuratifEnCours_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Intervention"
    stLinkCriteria = "(typint='4' or typint='5') and staint<9  and cptsit in (select cptsit from site where numcli=" & Me.LstClient & ")"
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "IDCE"

Exit_CmdDepanageCuratifEnCours_Click:
    Exit Sub

Err_CmdDepanageCuratifEnCours_Click:
    MsgBox err.Description
    Resume Exit_CmdDepanageCuratifEnCours_Click
    
End Sub

Private Sub CmdListerInterventionAttente_Click()

On Error GoTo Err_CmdListerInterventionAttente_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "ListeInterventionAttente"
    stLinkCriteria = "typint='2' and staint<9 and numcli=" & Me.LstClient
    
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "H+8"

Exit_CmdListerInterventionAttente_Click:
    Exit Sub

Err_CmdListerInterventionAttente_Click:
    MsgBox err.Description
    Resume Exit_CmdListerInterventionAttente_Click

End Sub

Private Sub CmdOuvrirAttenteObservation_Click()

On Error GoTo Err_CmdOuvrirAttenteObservation_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Intervention"
    stLinkCriteria = "typint='2' and staint<9 and datintpre is null"
    
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "IDA"

Exit_CmdOuvrirAttenteObservation_Click:
    Exit Sub

Err_CmdOuvrirAttenteObservation_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirAttenteObservation_Click
    
End Sub

Private Sub cmdLstAspirateurFiltre_Click()
On Error GoTo Err_cmdLstAspirateurFiltre_Click

    Dim stDocName As String
    
    stDocName = "Zone Geographique"
    DoCmd.OpenForm stDocName

Exit_cmdLstAspirateurFiltre_Click:
    Exit Sub

Err_cmdLstAspirateurFiltre_Click:
    MsgBox err.Description
    Resume Exit_cmdLstAspirateurFiltre_Click
End Sub

Private Sub CmdOuvrirContact_Click()
On Error GoTo Err_CmdOuvrirContact_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Contact"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdOuvrirContact_Click:
    Exit Sub

Err_CmdOuvrirContact_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirContact_Click
    
End Sub
Private Sub CmdOuvrirIntervenant_Click()
On Error GoTo Err_CmdOuvrirIntervenant_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Intervenant"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdOuvrirIntervenant_Click:
    Exit Sub

Err_CmdOuvrirIntervenant_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirIntervenant_Click
    
End Sub

Private Sub CmdOuvrirInterventionCloturee_Click()
On Error GoTo Err_CmdOuvrirInterventionCloturee_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Intervention"
    stLinkCriteria = "(typint='2' or typint='3') and staint=9  and cptsit in (select cptsit from site where numcli=" & Me.LstClient & ")"
    DoCmd.OpenForm stDocName, , , stLinkCriteria, acFormReadOnly, , "IDC"

Exit_CmdOuvrirInterventionCloturee_Click:
    Exit Sub

Err_CmdOuvrirInterventionCloturee_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirInterventionCloturee_Click
    
    

End Sub

Private Sub CmdOuvrirInterventionEnCours_Click()
On Error GoTo Err_CmdOuvrirInterventionEnCours_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Intervention"
    stLinkCriteria = "(typint='2' or typint='3') and staint<9  and cptsit in (select cptsit from site where numcli=" & Me.LstClient & ")"
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "IDE"

Exit_CmdOuvrirInterventionEnCours_Click:
    Exit Sub

Err_CmdOuvrirInterventionEnCours_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirInterventionEnCours_Click
    
    
End Sub

Private Sub CmdOuvrirMarque_Click()
On Error GoTo Err_CmdOuvrirMarque_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Marque"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdOuvrirMarque_Click:
    Exit Sub

Err_CmdOuvrirMarque_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirMarque_Click
    
End Sub
Private Sub CmdOuvrirReference_Click()
On Error GoTo Err_CmdOuvrirReference_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Reference"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdOuvrirReference_Click:
    Exit Sub

Err_CmdOuvrirReference_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirReference_Click
    
End Sub
Private Sub CmdOuvrirSite_Click()
On Error GoTo Err_CmdOuvrirSite_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Site"
    If Me.LstClient <> "" Then
        stLinkCriteria = "numcli=" & Me.LstClient
    End If
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdOuvrirSite_Click:
    Exit Sub

Err_CmdOuvrirSite_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirSite_Click
    
End Sub
Private Sub CmdOuvrirZone_Click()
On Error GoTo Err_CmdOuvrirZone_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "ZoneGeographique"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdOuvrirZone_Click:
    Exit Sub

Err_CmdOuvrirZone_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirZone_Click
    
End Sub
Private Sub CmdOuvrirPanne_Click()
On Error GoTo Err_CmdOuvrirPanne_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Panne"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdOuvrirPanne_Click:
    Exit Sub

Err_CmdOuvrirPanne_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirPanne_Click
    
End Sub
Private Sub CmdOuvrirIntervention_Click()
On Error GoTo Err_CmdOuvrirIntervention_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Intervention"
    stLinkCriteria = "staint<9 and datint is not null"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdOuvrirIntervention_Click:
    Exit Sub

Err_CmdOuvrirIntervention_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirIntervention_Click
    
End Sub
Private Sub CmdInterventionCloturee_Click()
On Error GoTo Err_CmdInterventionCloturee_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Intervention"
    stLinkCriteria = "staint=9"
    DoCmd.OpenForm stDocName, , , stLinkCriteria, acFormReadOnly

Exit_CmdInterventionCloturee_Click:
    Exit Sub

Err_CmdInterventionCloturee_Click:
    MsgBox err.Description
    Resume Exit_CmdInterventionCloturee_Click
    
End Sub
Private Sub CmdPlanifier_Click()
On Error GoTo Err_CmdPlanifier_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "PlanificationEntretien"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdPlanifier_Click:
    Exit Sub

Err_CmdPlanifier_Click:
    MsgBox err.Description
    Resume Exit_CmdPlanifier_Click
    
End Sub

Private Sub CmdEntretienParMois_Click()
On Error GoTo Err_CmdEntretienParMois_Click

    Dim stDocName As String

    stDocName = "NombreVisiteEntretienParMois"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdEntretienParMois_Click:
    Exit Sub

Err_CmdEntretienParMois_Click:
    MsgBox err.Description
    Resume Exit_CmdEntretienParMois_Click
    
End Sub
Private Sub CmdDepannageParMois_Click()
On Error GoTo Err_CmdDepannageParMois_Click

    Dim stDocName As String

    stDocName = "NombreVisiteDepannageParMois"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdDepannageParMois_Click:
    Exit Sub

Err_CmdDepannageParMois_Click:
    MsgBox err.Description
    Resume Exit_CmdDepannageParMois_Click
    
End Sub
Private Sub CmdAnalyseTypePanne_Click()
On Error GoTo Err_CmdAnalyseTypePanne_Click

    Dim stDocName As String

    stDocName = "AnalyseDepannage"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdAnalyseTypePanne_Click:
    Exit Sub

Err_CmdAnalyseTypePanne_Click:
    MsgBox err.Description
    Resume Exit_CmdAnalyseTypePanne_Click
    
End Sub
Private Sub CmdDepannageParTypeDeSite_Click()
On Error GoTo Err_CmdDepannageParTypeDeSite_Click

    Dim stDocName As String

    stDocName = "AnalyseDepannageTypeSite"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdDepannageParTypeDeSite_Click:
    Exit Sub

Err_CmdDepannageParTypeDeSite_Click:
    MsgBox err.Description
    Resume Exit_CmdDepannageParTypeDeSite_Click
    
End Sub
Private Sub CmdDepannageParSite_Click()
On Error GoTo Err_CmdDepannageParSite_Click

    Dim stDocName As String

    stDocName = "NombreDepannageParSite"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdDepannageParSite_Click:
    Exit Sub

Err_CmdDepannageParSite_Click:
    MsgBox err.Description
    Resume Exit_CmdDepannageParSite_Click
    
End Sub

Private Sub cmdPlaAnnee_Click()
    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "ChoixIntervenant"
    DoCmd.OpenForm stDocName, , , stLinkCriteria


End Sub

Private Sub CmdRechercherSite_Click()
On Error GoTo Err_CmdRechercherSite_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "RechercheSite"
    stLinkCriteria = "numcli=" & Me.LstClient.Column(0)
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdRechercherSite_Click:
    Exit Sub

Err_CmdRechercherSite_Click:
    MsgBox err.Description
    Resume Exit_CmdRechercherSite_Click
    
End Sub
Private Sub CmdOuvrirClient_Click()
On Error GoTo Err_CmdOuvrirClient_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Client"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdOuvrirClient_Click:
    Exit Sub

Err_CmdOuvrirClient_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirClient_Click
    
End Sub
Private Sub CmdOuvrirJoursFeries_Click()
On Error GoTo Err_CmdOuvrirJoursFeries_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "JoursFeries"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdOuvrirJoursFeries_Click:
    Exit Sub

Err_CmdOuvrirJoursFeries_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirJoursFeries_Click
    
End Sub
Private Sub CmdOuvrirInterventionPlanifiee_Click()
On Error GoTo Err_CmdOuvrirInterventionPlanifiee_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    GformulaireParent = "MenuPrincipal"
    stDocName = "InterventionEntretien"
    stLinkCriteria = "(typint='1' or typint='6' or typint='7') and staint<9 and cptsit in (select cptsit from site where numcli=" & Me.LstClient & " ORDER BY Intervention.cptsit)"
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "IEP"
    'DoCmd.OpenForm stDocName

Exit_CmdOuvrirInterventionPlanifiee_Clic:
    Exit Sub

Err_CmdOuvrirInterventionPlanifiee_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirInterventionPlanifiee_Clic
    
End Sub
Private Sub CmdOuvrirInterventionsCloturees_Click()
On Error GoTo Err_CmdOuvrirInterventionsCloturees_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

 GformulaireParent = "MenuPrincipal"
 
    stDocName = "InterventionEntretien"
    stLinkCriteria = "(typint='1' or typint='6' or typint='7') and staint=9  and cptsit in (select cptsit from site where numcli=" & Me.LstClient & ")"
    DoCmd.OpenForm stDocName, , , stLinkCriteria, acFormReadOnly, , "IEC"

Exit_CmdOuvrirInterventionsCloturees_Cli:
    Exit Sub

Err_CmdOuvrirInterventionsCloturees_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirInterventionsCloturees_Cli
    
End Sub
Private Sub CmdOuvrirPlanificationEntretien_Click()
On Error GoTo Err_CmdOuvrirPlanificationEntretien_Click

    'GenererSemaine
    'Exit Sub
    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "PlanificationEntretien"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdOuvrirPlanificationEntretien_Cli:
    Exit Sub

Err_CmdOuvrirPlanificationEntretien_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirPlanificationEntretien_Cli
    
End Sub
Private Sub Cmd01_Click()
On Error GoTo Err_Cmd01_Click

    Dim stDocName As String

    stDocName = "01 - Nombre total de visite d'entretien par mois"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd01_Click:
    Exit Sub

Err_Cmd01_Click:
    MsgBox err.Description
    Resume Exit_Cmd01_Click
    
End Sub
Private Sub Cmd02_Click()
On Error GoTo Err_Cmd02_Click

    Dim stDocName As String

    stDocName = "02 - Nombre total de visite d'entretien par trimestre"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd02_Click:
    Exit Sub

Err_Cmd02_Click:
    MsgBox err.Description
    Resume Exit_Cmd02_Click
    
End Sub
Private Sub Cmd03_Click()
On Error GoTo Err_Cmd03_Click

    Dim stDocName As String

    stDocName = "03 - Nombre total de visite d'entretien par an"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd03_Click:
    Exit Sub

Err_Cmd03_Click:
    MsgBox err.Description
    Resume Exit_Cmd03_Click
    
End Sub
Private Sub Cmd04_Click()
On Error GoTo Err_Cmd04_Click

    Dim stDocName As String

    stDocName = "04 - Nombre de visites d'entretien par site par trimestre"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd04_Click:
    Exit Sub

Err_Cmd04_Click:
    MsgBox err.Description
    Resume Exit_Cmd04_Click
    
End Sub
Private Sub Cmd05_Click()
On Error GoTo Err_Cmd05_Click

    Dim stDocName As String

    stDocName = "05 - Nombre de visites d'entretien par site par an"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd05_Click:
    Exit Sub

Err_Cmd05_Click:
    MsgBox err.Description
    Resume Exit_Cmd05_Click
    
End Sub
Private Sub Cmd06_Click()
On Error GoTo Err_Cmd06_Click

    Dim stDocName As String

    stDocName = "06 - Ecart en jours entre date prévue d'entretien par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd06_Click:
    Exit Sub

Err_Cmd06_Click:
    MsgBox err.Description
    Resume Exit_Cmd06_Click
    
End Sub
Private Sub Cmd07_Click()
On Error GoTo Err_Cmd07_Click

    Dim stDocName As String

    stDocName = "07 - Ecart en jours entre date prévue d'entretien global"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd07_Click:
    Exit Sub

Err_Cmd07_Click:
    MsgBox err.Description
    Resume Exit_Cmd07_Click
    
End Sub
Private Sub Cmd08_Click()
On Error GoTo Err_Cmd08_Click

    Dim stDocName As String

    stDocName = "08 - Ecart en jours date prévue d'entretien par intervenant"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd08_Click:
    Exit Sub

Err_Cmd08_Click:
    MsgBox err.Description
    Resume Exit_Cmd08_Click
    
End Sub
Private Sub Cmd09_Click()
On Error GoTo Err_Cmd09_Click

    Dim stDocName As String

    stDocName = "09 - Sites, nombre d'entretien et de dépannage A05"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd09_Click:
    Exit Sub

Err_Cmd09_Click:
    MsgBox err.Description
    Resume Exit_Cmd09_Click
    
End Sub
Private Sub Cmd40_Click()
On Error GoTo Err_Cmd40_Click

    Dim stDocName As String

    stDocName = "40 - Nombre total de dépannage par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd40_Click:
    Exit Sub

Err_Cmd40_Click:
    MsgBox err.Description
    Resume Exit_Cmd40_Click
    
End Sub
Private Sub Cmd41_Click()
On Error GoTo Err_Cmd41_Click

    Dim stDocName As String

    stDocName = "41 - Nombre total de dépannage par mois"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd41_Click:
    Exit Sub

Err_Cmd41_Click:
    MsgBox err.Description
    Resume Exit_Cmd41_Click
    
End Sub
Private Sub Commande60_Click()
On Error GoTo Err_Commande60_Click

    Dim stDocName As String

    stDocName = "01 - Nombre total de visite d'entretien par mois"
    DoCmd.OpenReport stDocName, acPreview

Exit_Commande60_Click:
    Exit Sub

Err_Commande60_Click:
    MsgBox err.Description
    Resume Exit_Commande60_Click
    
End Sub
Private Sub Cmd42_Click()
On Error GoTo Err_Cmd42_Click

    Dim stDocName As String

    stDocName = "42 - Nombre total de dépannage par trimestre"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd42_Click:
    Exit Sub

Err_Cmd42_Click:
    MsgBox err.Description
    Resume Exit_Cmd42_Click
    
End Sub
Private Sub Cmd43_Click()
On Error GoTo Err_Cmd43_Click

    Dim stDocName As String

    stDocName = "43 - Nombre total de dépannage par an"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd43_Click:
    Exit Sub

Err_Cmd43_Click:
    MsgBox err.Description
    Resume Exit_Cmd43_Click
    
End Sub
Private Sub Cmd44_Click()
On Error GoTo Err_Cmd44_Click

    Dim stDocName As String

    stDocName = "44 - Nombre total de dépannage par situation"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd44_Click:
    Exit Sub

Err_Cmd44_Click:
    MsgBox err.Description
    Resume Exit_Cmd44_Click
    
End Sub
Private Sub Cmd45_Click()
On Error GoTo Err_Cmd45_Click

    Dim stDocName As String

    stDocName = "45 - Nombre total de dépannage par zone"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd45_Click:
    Exit Sub

Err_Cmd45_Click:
    MsgBox err.Description
    Resume Exit_Cmd45_Click
    
End Sub

Private Sub Cmd46_Click()
On Error GoTo Err_Cmd46_Click

    Dim stDocName As String

    stDocName = "46 - Nombre total de dépannage par type de site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd46_Click:
    Exit Sub

Err_Cmd46_Click:
    MsgBox err.Description
    Resume Exit_Cmd46_Click
    
End Sub
Private Sub Cmd47_Click()
On Error GoTo Err_Cmd47_Click

    Dim stDocName As String

    stDocName = "47 - Nombre total de dépannage par civilité responsable"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd47_Click:
    Exit Sub

Err_Cmd47_Click:
    MsgBox err.Description
    Resume Exit_Cmd47_Click
    
End Sub
Private Sub Cmd48_Click()
On Error GoTo Err_Cmd48_Click

    Dim stDocName As String

    stDocName = "48 - Nombre total de dépannage par surface de vente"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd48_Click:
    Exit Sub

Err_Cmd48_Click:
    MsgBox err.Description
    Resume Exit_Cmd48_Click
    
End Sub
Private Sub Cmd49_Click()
On Error GoTo Err_Cmd49_Click

    Dim stDocName As String

    stDocName = "49 - Nombre de dépannage par marque des matériels"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd49_Click:
    Exit Sub

Err_Cmd49_Click:
    MsgBox err.Description
    Resume Exit_Cmd49_Click
    
End Sub
Private Sub Cmd50_Click()
On Error GoTo Err_Cmd50_Click

    Dim stDocName As String

    stDocName = "50 - Nombre total de dépannage par contact"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd50_Click:
    Exit Sub

Err_Cmd50_Click:
    MsgBox err.Description
    Resume Exit_Cmd50_Click
    
End Sub
Private Sub Cmd51_Click()
On Error GoTo Err_Cmd51_Click

    Dim stDocName As String

    stDocName = "51 - Calcul du coût ramené à la surface de vente"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd51_Click:
    Exit Sub

Err_Cmd51_Click:
    MsgBox err.Description
    Resume Exit_Cmd51_Click
    
End Sub
Private Sub Cmd52_Click()
On Error GoTo Err_Cmd52_Click

    Dim stDocName As String

    stDocName = "52 - Calcul du coût par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd52_Click:
    Exit Sub

Err_Cmd52_Click:
    MsgBox err.Description
    Resume Exit_Cmd52_Click
    
End Sub
Private Sub Cmd20_Click()
On Error GoTo Err_Cmd20_Click

    Dim stDocName As String

    stDocName = "20 - Nombre de site par type"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd20_Click:
    Exit Sub

Err_Cmd20_Click:
    MsgBox err.Description
    Resume Exit_Cmd20_Click
    
End Sub
Private Sub Cmd21_Click()
On Error GoTo Err_Cmd21_Click

    Dim stDocName As String

    stDocName = "21 - Nombre de site par situation"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd21_Click:
    Exit Sub

Err_Cmd21_Click:
    MsgBox err.Description
    Resume Exit_Cmd21_Click
    
End Sub
Private Sub Cmd22_Click()
On Error GoTo Err_Cmd22_Click

    Dim stDocName As String

    stDocName = "22 - Nombre de site par zone"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd22_Click:
    Exit Sub

Err_Cmd22_Click:
    MsgBox err.Description
    Resume Exit_Cmd22_Click
    
End Sub
Private Sub Cmd23_Click()
On Error GoTo Err_Cmd23_Click

    Dim stDocName As String

    stDocName = "23 - Nombre de site par civilité"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd23_Click:
    Exit Sub

Err_Cmd23_Click:
    MsgBox err.Description
    Resume Exit_Cmd23_Click
    
End Sub

Private Sub CmdTopTen_Click()
   Dim db As Database
   Dim rs As Recordset
   Dim lSQl As String
   Set db = CurrentDb
   db.Execute "Delete * FROM TopTen", dbSeeChanges
   'lSql = "SELECT TOP 20 Site.nomsit, Site.numsit, Site.typsit, Site.indvetust, [TopTen - Nb inter total]."
   'lSql = lSql & "[Nombre d'interventions total] AS [NBTOTAL], [TopTen - Nb inter defaut Mat]"
   'lSql = lSql & ".[Nombre d'interventions defaut matériel] AS [NBDEF] FROM ((Site LEFT JOIN"
   'lSql = lSql & " [TopTen - Nb inter defaut Mat] ON Site.cptsit = [TopTen - Nb inter defaut Mat]"
   'lSql = lSql & ".cptsit) LEFT JOIN [TopTen - Nb inter total] ON Site.cptsit = "
   'lSql = lSql & "[TopTen - Nb inter total].cptsit) INNER JOIN Intervention ON Site.cptsit ="
   'lSql = lSql & "Intervention.cptsit GROUP BY Site.nomsit, Site.indvetust, [TopTen - Nb inter"
   'lSql = lSql & " total].[Nombre d'interventions total], [TopTen - Nb inter defaut Mat]."
   'lSql = lSql & "[Nombre d'interventions defaut matériel], Site.numsit, Site.typsit "
   'lSql = lSql & "ORDER BY Site.indvetust DESC , [TopTen - Nb inter total].[Nombre d'interventions total]"
   'lSql = lSql & ", [TopTen - Nb inter defaut Mat].[Nombre d'interventions defaut matériel], Site.nomsit"
    
    'Open "c:\fichier.txt" For Output As 1
    'Print #1, lSql
    'Close #1
    lSQl = "Select * FROM [RequeteTopTen]"
   Set rs = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
   Dim lNom As String
   Dim icpt As Integer
   Dim lIndice As Variant
   Dim lNbTot As Variant
   Dim lNbDef As Variant
   icpt = 0
   Do While Not rs.EOF
   icpt = icpt + 1
   lNom = Replace(rs("nomsit"), "'", "''")
   
   If IsNull(rs("indvetust")) Then
        lIndice = "''"
    Else
        lIndice = rs("indvetust")
   End If
   If IsNull(rs("[NBTOTAL]")) Then
        lNbTot = "''"
   Else
        lNbTot = rs("[NBTOTAL]")
   End If
   If IsNull(rs("[NBDEF]")) Then
        lNbDef = "''"
    Else
        lNbDef = rs("[NBDEF]")
   End If
        'MsgBox CStr(icpt)
        'MsgBox "Insert INTO TopTen(nomsittop, indvettop, Nbintphy, nbintdef, numsittop, typsittop) VALUES ('" & lNom & "', " & lIndice & ", " & lNbTot & ", " & lNbDef & ", " & rs("numsit") & ", '" & rs("typsit") & "')"
        db.Execute ("Insert INTO TopTen(nomsittop, indvettop, Nbintphy, nbintdef, numsittop, typsittop) VALUES ('" & lNom & "', " & lIndice & ", " & lNbTot & ", " & lNbDef & ", " & rs("numsit") & ", '" & rs("typsit") & "')")
   'MsgBox rs("nomsit")
   If icpt = 20 Then
        'Exit Do
    End If
   rs.MoveNext
   Loop
   rs.Close
   Set rs = Nothing
   DoCmd.OpenReport "TopTen", acPreview
   
End Sub

Private Sub Commande237_Click()
DoCmd.OpenForm "statistiques", acNormal
End Sub

Private Sub Commande248_Click()
    Dim db As Database
   Dim rs As Recordset
   Dim lSQl As String
   Set db = CurrentDb
   db.Execute "Delete * FROM TopTen", dbSeeChanges
   'lSql = "SELECT TOP 20 Site.nomsit, Site.numsit, Site.typsit, Site.indvetust, [TopTen - Nb inter total]."
   'lSql = lSql & "[Nombre d'interventions total] AS [NBTOTAL], [TopTen - Nb inter defaut Mat]"
   'lSql = lSql & ".[Nombre d'interventions defaut matériel] AS [NBDEF] FROM ((Site LEFT JOIN"
   'lSql = lSql & " [TopTen - Nb inter defaut Mat] ON Site.cptsit = [TopTen - Nb inter defaut Mat]"
   'lSql = lSql & ".cptsit) LEFT JOIN [TopTen - Nb inter total] ON Site.cptsit = "
   'lSql = lSql & "[TopTen - Nb inter total].cptsit) INNER JOIN Intervention ON Site.cptsit ="
   'lSql = lSql & "Intervention.cptsit GROUP BY Site.nomsit, Site.indvetust, [TopTen - Nb inter"
   'lSql = lSql & " total].[Nombre d'interventions total], [TopTen - Nb inter defaut Mat]."
   'lSql = lSql & "[Nombre d'interventions defaut matériel], Site.numsit, Site.typsit "
   'lSql = lSql & "ORDER BY Site.indvetust, [TopTen - Nb inter total].[Nombre d'interventions total]"
   'lSql = lSql & "DESC , [TopTen - Nb inter defaut Mat].[Nombre d'interventions defaut matériel] DESC, Site.nomsit"

'MsgBox lSql
lSQl = "Select * FROM [RequeteFlopTen]"
   'Close Recordset Fait
   Set rs = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
   Dim lNom As String
   Dim lIndice As Variant
   Dim lNbTot As Variant
   Dim lNbDef As Variant
   Dim icpt As Integer
   icpt = 0
   Do While Not rs.EOF
   icpt = icpt + 1
   lNom = Replace(rs("nomsit"), "'", "''")
   
   If IsNull(rs("indvetust")) Then
        lIndice = "''"
    Else
        lIndice = rs("indvetust")
   End If
   If IsNull(rs("[NBTOTAL]")) Then
        lNbTot = "''"
   Else
        lNbTot = rs("[NBTOTAL]")
   End If
   If IsNull(rs("[NBDEF]")) Then
        lNbDef = "''"
    Else
        lNbDef = rs("[NBDEF]")
   End If
        'MsgBox "Insert INTO TopTen(nomsittop, indvettop, Nbintphy, nbintdef) VALUES ('" & lNom & "', " & lIndice & ", " & lNbTot & ", " & lNbDef & ")"
        db.Execute ("Insert INTO TopTen(nomsittop, indvettop, Nbintphy, nbintdef, numsittop, typsittop) VALUES ('" & lNom & "', " & lIndice & ", " & lNbTot & ", " & lNbDef & ", " & rs("numsit") & ", '" & rs("typsit") & "')")
   'MsgBox rs("nomsit")
    If icpt = 20 Then
        Exit Do
    End If
   rs.MoveNext
   Loop
   rs.Close
   Set rs = Nothing
   DoCmd.OpenReport "FlopTen", acPreview
End Sub

Private Sub Commande274_Click()
On Error GoTo Err_cmdIntT1_Click

    Dim stDocName As String

    stDocName = "Interventions par client second trimestre"
    DoCmd.OpenReport stDocName, acPreview, , "numcli=" & Me.numcli

Exit_cmdIntT1_Click:
    Exit Sub

Err_cmdIntT1_Click:
    MsgBox err.Description
    Resume Exit_cmdIntT1_Click
    
End Sub

Private Sub Commande275_Click()
On Error GoTo Err_cmdIntT1_Click

    Dim stDocName As String

    stDocName = "Interventions par client troisième trimestre"
    DoCmd.OpenReport stDocName, acPreview, , "numcli=" & Me.numcli

Exit_cmdIntT1_Click:
    Exit Sub

Err_cmdIntT1_Click:
    MsgBox err.Description
    Resume Exit_cmdIntT1_Click
    
End Sub

Private Sub Commande276_Click()
On Error GoTo Err_cmdIntT1_Click

    Dim stDocName As String

    stDocName = "Interventions par client quatrième trimestre"
    DoCmd.OpenReport stDocName, acPreview, , "numcli=" & Me.numcli

Exit_cmdIntT1_Click:
    Exit Sub

Err_cmdIntT1_Click:
    MsgBox err.Description
    Resume Exit_cmdIntT1_Click
    
End Sub

Private Sub Form_Current()

    DoCmd.Maximize

End Sub
Private Sub CmdOuvrirRepertoireTechnique_Click()
'On Error GoTo Err_CmdOuvrirRepertoireTechnique_Click

    Dim stDocName As String
    Dim stFiltre As String
    If Me.CbZone <> "" Then
        stFiltre = "numzonsit =" & Str(Me.CbZone)
    End If
    If Me.LstIntervenantRepertoire <> "" Then
        stFiltre = "numintervenant =" & Str(Me.LstIntervenantRepertoire)
    End If
    stDocName = "RépertoireTechnique"
    
    DoCmd.OpenReport stDocName, acPreview, , stFiltre

Exit_CmdOuvrirRepertoireTechnique_Click:
    Exit Sub

Err_CmdOuvrirRepertoireTechnique_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirRepertoireTechnique_Click
    
End Sub
Private Sub CmdListeInterventionFacturable_Click()
On Error GoTo Err_CmdListeInterventionFacturable_Click

    Dim stDocName As String

    stDocName = "ListeInterventionFacturable"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdListeInterventionFacturable_Clic:
    Exit Sub

Err_CmdListeInterventionFacturable_Click:
    MsgBox err.Description
    Resume Exit_CmdListeInterventionFacturable_Clic
    
End Sub
Public Sub GenererSemaine()
    Dim lI As Integer
    Dim Semaine As String
    For lI = 1 To 52
        Semaine = Semaine & Chr(34) & "Semaine " & lI & Chr(34) & ";"
    Next lI
    Debug.Print Semaine
    
End Sub
Private Sub CmdT1_Click()
On Error GoTo Err_CmdT1_Click

    Dim stDocName As String
    Dim lCritere As String

    Call GenererPlanningPrevisionnel
    
    If Me.LstIntervenant <> "" Then
    lCritere = "Intervenant like '" & Me.LstIntervenant & "*'"
    End If
    stDocName = "SiteEntretienPrevu-T1"
    DoCmd.OpenReport stDocName, acPreview, , lCritere

Exit_CmdT1_Click:
    Exit Sub

Err_CmdT1_Click:
    MsgBox err.Description
    Resume Exit_CmdT1_Click
    
End Sub
Private Sub CmdT2_Click()
On Error GoTo Err_CmdT2_Click

    Dim stDocName As String
    Dim lCritere As String
    
    Call GenererPlanningPrevisionnel
    
    If Me.LstIntervenant <> "" Then
    lCritere = "Intervenant like '" & Me.LstIntervenant & "*'"
    End If
    stDocName = "SiteEntretienPrevu-T2"
    DoCmd.OpenReport stDocName, acPreview, , lCritere

Exit_CmdT2_Click:
    Exit Sub

Err_CmdT2_Click:
    MsgBox err.Description
    Resume Exit_CmdT2_Click
    
End Sub
Private Sub CmdT3_Click()
On Error GoTo Err_CmdT3_Click

    Dim stDocName As String
    Dim lCritere As String
    
    Call GenererPlanningPrevisionnel
    
    stDocName = "SiteEntretienPrevu-T3"
    If Me.LstIntervenant <> "" Then
    lCritere = "Intervenant like '" & Me.LstIntervenant & "*'"
    End If
    DoCmd.OpenReport stDocName, acPreview, , lCritere

Exit_CmdT3_Click:
    Exit Sub

Err_CmdT3_Click:
    MsgBox err.Description
    Resume Exit_CmdT3_Click
    
End Sub
Private Sub CmdT4_Click()
On Error GoTo Err_CmdT4_Click

    Dim stDocName As String
    Dim lCritere As String
    
    Call GenererPlanningPrevisionnel
    
    If Me.LstIntervenant <> "" Then
    lCritere = "Intervenant like '" & Me.LstIntervenant & "*'"
    End If
    
    stDocName = "SiteEntretienPrevu-T4"
    DoCmd.OpenReport stDocName, acPreview, , lCritere

Exit_CmdT4_Click:
    Exit Sub

Err_CmdT4_Click:
    MsgBox err.Description
    Resume Exit_CmdT4_Click
    
End Sub
Private Sub CmdMarqueDesenfumage_Click()
On Error GoTo Err_CmdMarqueDesenfumage_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "MarqueDesenfumage"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdMarqueDesenfumage_Click:
    Exit Sub

Err_CmdMarqueDesenfumage_Click:
    MsgBox err.Description
    Resume Exit_CmdMarqueDesenfumage_Click
    
End Sub
Private Sub CmdReferenceDesenfumage_Click()
On Error GoTo Err_CmdReferenceDesenfumage_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "ReferenceDesenfumage"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdReferenceDesenfumage_Click:
    Exit Sub

Err_CmdReferenceDesenfumage_Click:
    MsgBox err.Description
    Resume Exit_CmdReferenceDesenfumage_Click
    
End Sub
Private Sub CmdInterventionAEffectuer_Click()
On Error GoTo Err_CmdInterventionAEffectuer_Click

    Dim stDocName As String
    Dim lCritere As String: lCritere = ""

    stDocName = "ListeInterventionAEffectuer"
    
    If ddlTypeSite2 = "Hommes et mixte" Then
        lCritere = lCritere & "typsit IN ('H', 'M')"
    ElseIf ddlTypeSite2 = "Femmes" Then
        lCritere = lCritere & "typsit = 'F'"
    End If
    
    DoCmd.OpenReport stDocName, acPreview, , lCritere
    
Exit_CmdInterventionAEffectuer_Click:
    Exit Sub

Err_CmdInterventionAEffectuer_Click:
    MsgBox err.Description
    Resume Exit_CmdInterventionAEffectuer_Click
    
End Sub
Private Sub CmdListeInterventionsFacturees_Click()
On Error GoTo Err_CmdListeInterventionsFacturees_Click

    Dim stDocName As String

    stDocName = "ListeInterventionFacturee"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdListeInterventionsFacturees_Clic:
    Exit Sub

Err_CmdListeInterventionsFacturees_Click:
    MsgBox err.Description
    Resume Exit_CmdListeInterventionsFacturees_Clic
    
End Sub
Private Sub CmdSitesNonVisites_Click()
On Error GoTo Err_CmdSitesNonVisites_Click

    Dim stDocName As String

    stDocName = "Sites non visités"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdSitesNonVisites_Click:
    Exit Sub

Err_CmdSitesNonVisites_Click:
    MsgBox err.Description
    Resume Exit_CmdSitesNonVisites_Click
    
End Sub
Private Sub CmdPlaGenEntT1_Click()
On Error GoTo Err_CmdPlaGenEntT1_Click

    Dim stDocName As String

    Call GenererPlanningPrevisionnel
    
    stDocName = "SiteEntretienPrevuGeneralT1"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdPlaGenEntT1_Click:
    Exit Sub

Err_CmdPlaGenEntT1_Click:
    MsgBox err.Description
    Resume Exit_CmdPlaGenEntT1_Click
    
End Sub
Private Sub Cmd53_Click()
On Error GoTo Err_Cmd53_Click

    Dim stDocName As String

    stDocName = "53 - Nombre total de dépannage cause non climatisation"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd53_Click:
    Exit Sub

Err_Cmd53_Click:
    MsgBox err.Description
    Resume Exit_Cmd53_Click
    
End Sub
Private Sub Cmd54_Click()
On Error GoTo Err_Cmd54_Click

    Dim stDocName As String

    stDocName = "54 - Durée moyenne d'un dépannage"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd54_Click:
    Exit Sub

Err_Cmd54_Click:
    MsgBox err.Description
    Resume Exit_Cmd54_Click
    
End Sub
Private Sub Cmd55_Click()
On Error GoTo Err_Cmd55_Click

    Dim stDocName As String

    stDocName = "55 - Coût moyen d'un dépannage par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd55_Click:
    Exit Sub

Err_Cmd55_Click:
    MsgBox err.Description
    Resume Exit_Cmd55_Click
    
End Sub
Private Sub Cmd56_Click()
On Error GoTo Err_Cmd56_Click

    Dim stDocName As String

    stDocName = "56 - Coût moyen d'un dépannage par intervention"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd56_Click:
    Exit Sub

Err_Cmd56_Click:
    MsgBox err.Description
    Resume Exit_Cmd56_Click
    
End Sub
Private Sub Cmd57_Click()
On Error GoTo Err_Cmd57_Click

    Dim stDocName As String

    stDocName = "57 - Pourcentage Nombre de dépannage par zone géographique"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd57_Click:
    Exit Sub

Err_Cmd57_Click:
    MsgBox err.Description
    Resume Exit_Cmd57_Click
    
End Sub
Private Sub Cmd10_Click()
On Error GoTo Err_Cmd10_Click

    Dim stDocName As String

    stDocName = "10 - Liste des sites contenant des matériels vétustes"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd10_Click:
    Exit Sub

Err_Cmd10_Click:
    MsgBox err.Description
    Resume Exit_Cmd10_Click
    
End Sub
Private Sub Cmd58_Click()
On Error GoTo Err_Cmd58_Click

    Dim stDocName As String

    stDocName = "58 - Nombre total de dépannage par type de panne"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd58_Click:
    Exit Sub

Err_Cmd58_Click:
    MsgBox err.Description
    Resume Exit_Cmd58_Click
    
End Sub
Private Sub CmdTG2_Click()
On Error GoTo Err_CmdTG2_Click

    Dim stDocName As String

    Call GenererPlanningPrevisionnel
    
    stDocName = "SiteEntretienPrevuGeneralT2"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdTG2_Click:
    Exit Sub

Err_CmdTG2_Click:
    MsgBox err.Description
    Resume Exit_CmdTG2_Click
    
End Sub
Private Sub CmdTG3_Click()
On Error GoTo Err_CmdTG3_Click

    Dim stDocName As String

    Call GenererPlanningPrevisionnel
    
    stDocName = "SiteEntretienPrevuGeneralT3"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdTG3_Click:
    Exit Sub

Err_CmdTG3_Click:
    MsgBox err.Description
    Resume Exit_CmdTG3_Click
    
End Sub
Private Sub CmdTG4_Click()
On Error GoTo Err_CmdTG4_Click

    Dim stDocName As String

    Call GenererPlanningPrevisionnel
    
    stDocName = "SiteEntretienPrevuGeneralT4"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdTG4_Click:
    Exit Sub

Err_CmdTG4_Click:
    MsgBox err.Description
    Resume Exit_CmdTG4_Click
    
End Sub
Private Sub CmdFiltrer_Click()
On Error GoTo Err_CmdFiltrer_Click


    DoCmd.DoMenuItem acFormBar, acRecordsMenu, acSaveRecord, , acMenuVer70

Exit_CmdFiltrer_Click:
    Exit Sub

Err_CmdFiltrer_Click:
    MsgBox err.Description
    Resume Exit_CmdFiltrer_Click
    
End Sub
Private Sub CmdOuvrirListeInterventionFacturable_Click()
On Error GoTo Err_CmdOuvrirListeInterventionFacturable_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "ListeInterventionAttente"
    
    stLinkCriteria = "typint='2' and staint<9 and intafact=true and numcli=" & Me.LstClient
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "Facturable"

Exit_CmdOuvrirListeInterventionFacturabl:
    Exit Sub

Err_CmdOuvrirListeInterventionFacturable_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirListeInterventionFacturabl
    
End Sub
Private Sub CmdRechercherIntervention_Click()
On Error GoTo Err_CmdRechercherIntervention_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "RechercheIntervention"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdRechercherIntervention_Click:
    Exit Sub

Err_CmdRechercherIntervention_Click:
    MsgBox err.Description
    Resume Exit_CmdRechercherIntervention_Click
    
End Sub
Private Sub Commande124_Click()
On Error GoTo Err_Commande124_Click

    Dim stDocName As String

    stDocName = "01 - Nombre total de visite d'entretien par mois"
    DoCmd.OpenReport stDocName, acPreview

Exit_Commande124_Click:
    Exit Sub

Err_Commande124_Click:
    MsgBox err.Description
    Resume Exit_Commande124_Click
    
End Sub
Private Sub Cmd60_Click()
On Error GoTo Err_Cmd60_Click

    Dim stDocName As String

    stDocName = "60 - Nombre total de dépannage curatif par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd60_Click:
    Exit Sub

Err_Cmd60_Click:
    MsgBox err.Description
    Resume Exit_Cmd60_Click
    
End Sub
Private Sub Cmd61_Click()
On Error GoTo Err_Cmd61_Click

    Dim stDocName As String

    stDocName = "61 - Nombre total de dépannage curatif par mois"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd61_Click:
    Exit Sub

Err_Cmd61_Click:
    MsgBox err.Description
    Resume Exit_Cmd61_Click
    
End Sub
Private Sub Cmd62_Click()
On Error GoTo Err_Cmd62_Click

    Dim stDocName As String

    stDocName = "62 - Nombre total de dépannage curatif par trimestre"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd62_Click:
    Exit Sub

Err_Cmd62_Click:
    MsgBox err.Description
    Resume Exit_Cmd62_Click
    
End Sub
Private Sub Cmd63_Click()
On Error GoTo Err_Cmd63_Click

    Dim stDocName As String

    stDocName = "63 - Nombre total de dépannage curatif par an"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd63_Click:
    Exit Sub

Err_Cmd63_Click:
    MsgBox err.Description
    Resume Exit_Cmd63_Click
    
End Sub
Private Sub Cmd64_Click()
On Error GoTo Err_Cmd64_Click

    Dim stDocName As String

    stDocName = "64 - Nombre total de dépannage curatif par situation"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd64_Click:
    Exit Sub

Err_Cmd64_Click:
    MsgBox err.Description
    Resume Exit_Cmd64_Click
    
End Sub
Private Sub Cmd65_Click()
On Error GoTo Err_Cmd65_Click

    Dim stDocName As String

    stDocName = "65 - Nombre total de dépannage curatif par zone"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd65_Click:
    Exit Sub

Err_Cmd65_Click:
    MsgBox err.Description
    Resume Exit_Cmd65_Click
    
End Sub
Private Sub Cmd66_Click()
On Error GoTo Err_Cmd66_Click

    Dim stDocName As String

    stDocName = "66 - Nombre total de dépannage curatif par type de site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd66_Click:
    Exit Sub

Err_Cmd66_Click:
    MsgBox err.Description
    Resume Exit_Cmd66_Click
    
End Sub
Private Sub Cmd67_Click()
On Error GoTo Err_Cmd67_Click

    Dim stDocName As String

    stDocName = "67 - Nombre total de dépannage curatif par civilité responsable"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd67_Click:
    Exit Sub

Err_Cmd67_Click:
    MsgBox err.Description
    Resume Exit_Cmd67_Click
    
End Sub
Private Sub Cmd68_Click()
On Error GoTo Err_Cmd68_Click

    Dim stDocName As String

    stDocName = "68 - Nombre total de dépannage curatif par surface de vente"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd68_Click:
    Exit Sub

Err_Cmd68_Click:
    MsgBox err.Description
    Resume Exit_Cmd68_Click
    
End Sub
Private Sub Cmd69_Click()
On Error GoTo Err_Cmd69_Click

    Dim stDocName As String

    stDocName = "69 - Nombre de dépannage curatif par marque des matériels"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd69_Click:
    Exit Sub

Err_Cmd69_Click:
    MsgBox err.Description
    Resume Exit_Cmd69_Click
    
End Sub
Private Sub Cmd70_Click()
On Error GoTo Err_Cmd70_Click

    Dim stDocName As String

    stDocName = "70 - Nombre total de dépannage curatif par contact"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd70_Click:
    Exit Sub

Err_Cmd70_Click:
    MsgBox err.Description
    Resume Exit_Cmd70_Click
    
End Sub
Private Sub Cmd71_Click()
On Error GoTo Err_Cmd71_Click

    Dim stDocName As String

    stDocName = "71 - Calcul du coût ramené à la surface de vente"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd71_Click:
    Exit Sub

Err_Cmd71_Click:
    MsgBox err.Description
    Resume Exit_Cmd71_Click
    
End Sub
Private Sub Cmd72a_Click()
On Error GoTo Err_Cmd72a_Click

    Dim stDocName As String

    stDocName = "72 - Calcul du coût de dépannage curatif par site pour femme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd72a_Click:
    Exit Sub

Err_Cmd72a_Click:
    MsgBox err.Description
    Resume Exit_Cmd72a_Click
    
End Sub
Private Sub Cmd71h_Click()
On Error GoTo Err_Cmd71h_Click

    Dim stDocName As String

    stDocName = "71 - Calcul du coût ramené à la surface de vente pour homme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd71h_Click:
    Exit Sub

Err_Cmd71h_Click:
    MsgBox err.Description
    Resume Exit_Cmd71h_Click
    
End Sub
Private Sub Cmd71m_Click()
On Error GoTo Err_Cmd71m_Click

    Dim stDocName As String

    stDocName = "71 - Calcul du coût ramené à la surface de vente pour mixte"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd71m_Click:
    Exit Sub

Err_Cmd71m_Click:
    MsgBox err.Description
    Resume Exit_Cmd71m_Click
    
End Sub
Private Sub Cmd72_Click()
On Error GoTo Err_Cmd72_Click

    Dim stDocName As String

    stDocName = "72 - Calcul du coût de dépannage curatif par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd72_Click:
    Exit Sub

Err_Cmd72_Click:
    MsgBox err.Description
    Resume Exit_Cmd72_Click
    
End Sub
Private Sub Cmd72f_Click()
On Error GoTo Err_Cmd72f_Click

    Dim stDocName As String

    stDocName = "72 - Calcul du coût de dépannage curatif par site pour femme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd72f_Click:
    Exit Sub

Err_Cmd72f_Click:
    MsgBox err.Description
    Resume Exit_Cmd72f_Click
    
End Sub
Private Sub Cmd72h_Click()
On Error GoTo Err_Cmd72h_Click

    Dim stDocName As String

    stDocName = "72 - Calcul du coût de dépannage curatif par site pour homme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd72h_Click:
    Exit Sub

Err_Cmd72h_Click:
    MsgBox err.Description
    Resume Exit_Cmd72h_Click
    
End Sub
Private Sub Cmd72m_Click()
On Error GoTo Err_Cmd72m_Click

    Dim stDocName As String

    stDocName = "72 - Calcul du coût de dépannage curatif par site pour mixte"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd72m_Click:
    Exit Sub

Err_Cmd72m_Click:
    MsgBox err.Description
    Resume Exit_Cmd72m_Click
    
End Sub
Private Sub Cmd73_Click()
On Error GoTo Err_Cmd73_Click

    Dim stDocName As String

    stDocName = "73 - Nombre total de dépannage curatif cause non climatisation"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd73_Click:
    Exit Sub

Err_Cmd73_Click:
    MsgBox err.Description
    Resume Exit_Cmd73_Click
    
End Sub
Private Sub Cmd75_Click()
On Error GoTo Err_Cmd75_Click

    Dim stDocName As String

    stDocName = "75 - Coût moyen d'un dépannage curatif par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd75_Click:
    Exit Sub

Err_Cmd75_Click:
    MsgBox err.Description
    Resume Exit_Cmd75_Click
    
End Sub
Private Sub Cmd75f_Click()
On Error GoTo Err_Cmd75f_Click

    Dim stDocName As String

    stDocName = "75 - Coût moyen d'un dépannage curatif par site pour femme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd75f_Click:
    Exit Sub

Err_Cmd75f_Click:
    MsgBox err.Description
    Resume Exit_Cmd75f_Click
    
End Sub
Private Sub Cmd75h_Click()
On Error GoTo Err_Cmd75h_Click

    Dim stDocName As String

    stDocName = "75 - Coût moyen d'un dépannage curatif par site pour homme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd75h_Click:
    Exit Sub

Err_Cmd75h_Click:
    MsgBox err.Description
    Resume Exit_Cmd75h_Click
    
End Sub
Private Sub Cmd75m_Click()
On Error GoTo Err_Cmd75m_Click

    Dim stDocName As String

    stDocName = "75 - Coût moyen d'un dépannage curatif par site pour mixte"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd75m_Click:
    Exit Sub

Err_Cmd75m_Click:
    MsgBox err.Description
    Resume Exit_Cmd75m_Click
    
End Sub
Private Sub Cmd76_Click()
On Error GoTo Err_Cmd76_Click

    Dim stDocName As String

    stDocName = "76 - Coût moyen d'un dépannage curatif par intervention"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd76_Click:
    Exit Sub

Err_Cmd76_Click:
    MsgBox err.Description
    Resume Exit_Cmd76_Click
    
End Sub
Private Sub Cmd76f_Click()
On Error GoTo Err_Cmd76f_Click

    Dim stDocName As String

    stDocName = "76 - Coût moyen d'un dépannage curatif par intervention femme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd76f_Click:
    Exit Sub

Err_Cmd76f_Click:
    MsgBox err.Description
    Resume Exit_Cmd76f_Click
    
End Sub
Private Sub Cmd76h_Click()
On Error GoTo Err_Cmd76h_Click

    Dim stDocName As String

    stDocName = "76 - Coût moyen d'un dépannage curatif par intervention homme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd76h_Click:
    Exit Sub

Err_Cmd76h_Click:
    MsgBox err.Description
    Resume Exit_Cmd76h_Click
    
End Sub
Private Sub Cmd76m_Click()
On Error GoTo Err_Cmd76m_Click

    Dim stDocName As String

    stDocName = "76 - Coût moyen d'un dépannage curatif par intervention mixte"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd76m_Click:
    Exit Sub

Err_Cmd76m_Click:
    MsgBox err.Description
    Resume Exit_Cmd76m_Click
    
End Sub
Private Sub Cmd77_Click()
On Error GoTo Err_Cmd77_Click

    Dim stDocName As String

    stDocName = "77 - Pourcentage Nombre de dépannage curatif par zone"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd77_Click:
    Exit Sub

Err_Cmd77_Click:
    MsgBox err.Description
    Resume Exit_Cmd77_Click
    
End Sub
Private Sub Cmd78_Click()
On Error GoTo Err_Cmd78_Click

    Dim stDocName As String

    stDocName = "78 - Nombre total de dépannage curatif par type de panne"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd78_Click:
    Exit Sub

Err_Cmd78_Click:
    MsgBox err.Description
    Resume Exit_Cmd78_Click
    
End Sub
Private Sub Cmd80_Click()
On Error GoTo Err_Cmd80_Click

    Dim stDocName As String

    stDocName = "80 - Nombre total de dépannage correctif par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd80_Click:
    Exit Sub

Err_Cmd80_Click:
    MsgBox err.Description
    Resume Exit_Cmd80_Click
    
End Sub
Private Sub Cmd81_Click()
On Error GoTo Err_Cmd81_Click

    Dim stDocName As String

    stDocName = "81 - Nombre total de dépannage correctif par mois"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd81_Click:
    Exit Sub

Err_Cmd81_Click:
    MsgBox err.Description
    Resume Exit_Cmd81_Click
    
End Sub
Private Sub Cmd82_Click()
On Error GoTo Err_Cmd82_Click

    Dim stDocName As String

    stDocName = "82 - Nombre total de dépannage correctif par trimestre"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd82_Click:
    Exit Sub

Err_Cmd82_Click:
    MsgBox err.Description
    Resume Exit_Cmd82_Click
    
End Sub
Private Sub Cmd83_Click()
On Error GoTo Err_Cmd83_Click

    Dim stDocName As String

    stDocName = "83 - Nombre total de dépannage correctif par an"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd83_Click:
    Exit Sub

Err_Cmd83_Click:
    MsgBox err.Description
    Resume Exit_Cmd83_Click
    
End Sub
Private Sub Cmd84_Click()
On Error GoTo Err_Cmd84_Click

    Dim stDocName As String

    stDocName = "84 - Nombre total de dépannage correctif par situation"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd84_Click:
    Exit Sub

Err_Cmd84_Click:
    MsgBox err.Description
    Resume Exit_Cmd84_Click
    
End Sub
Private Sub Cmd85_Click()
On Error GoTo Err_Cmd85_Click

    Dim stDocName As String

    stDocName = "85 - Nombre total de dépannage correctif par zone"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd85_Click:
    Exit Sub

Err_Cmd85_Click:
    MsgBox err.Description
    Resume Exit_Cmd85_Click
    
End Sub
Private Sub Cmd86_Click()
On Error GoTo Err_Cmd86_Click

    Dim stDocName As String

    stDocName = "86 - Nombre total de dépannage correctif par type de site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd86_Click:
    Exit Sub

Err_Cmd86_Click:
    MsgBox err.Description
    Resume Exit_Cmd86_Click
    
End Sub
Private Sub Cmd87_Click()
On Error GoTo Err_Cmd87_Click

    Dim stDocName As String

    stDocName = "87 - Nombre total de dépannage correctif par civilité"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd87_Click:
    Exit Sub

Err_Cmd87_Click:
    MsgBox err.Description
    Resume Exit_Cmd87_Click
    
End Sub
Private Sub Cmd88_Click()
On Error GoTo Err_Cmd88_Click

    Dim stDocName As String

    stDocName = "88 - Nombre total de dépannage correctif par surface de vente"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd88_Click:
    Exit Sub

Err_Cmd88_Click:
    MsgBox err.Description
    Resume Exit_Cmd88_Click
    
End Sub
Private Sub Cmd89_Click()
On Error GoTo Err_Cmd89_Click

    Dim stDocName As String

    stDocName = "89 - Nombre de dépannage correctif par marque des matériels"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd89_Click:
    Exit Sub

Err_Cmd89_Click:
    MsgBox err.Description
    Resume Exit_Cmd89_Click
    
End Sub
Private Sub Cmd90_Click()
On Error GoTo Err_Cmd90_Click

    Dim stDocName As String

    stDocName = "90 - Nombre total de dépannage correctif par contact"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd90_Click:
    Exit Sub

Err_Cmd90_Click:
    MsgBox err.Description
    Resume Exit_Cmd90_Click
    
End Sub
Private Sub Cmd91_Click()
On Error GoTo Err_Cmd91_Click

    Dim stDocName As String

    stDocName = "91 - Calcul du coût ramené à la surface de vente"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd91_Click:
    Exit Sub

Err_Cmd91_Click:
    MsgBox err.Description
    Resume Exit_Cmd91_Click
    
End Sub
Private Sub Cmd91f_Click()
On Error GoTo Err_Cmd91f_Click

    Dim stDocName As String

    stDocName = "91 - Calcul du coût ramené à la surface de vente pour femme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd91f_Click:
    Exit Sub

Err_Cmd91f_Click:
    MsgBox err.Description
    Resume Exit_Cmd91f_Click
    
End Sub
Private Sub Cmd91h_Click()
On Error GoTo Err_Cmd91h_Click

    Dim stDocName As String

    stDocName = "91 - Calcul du coût ramené à la surface de vente pour homme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd91h_Click:
    Exit Sub

Err_Cmd91h_Click:
    MsgBox err.Description
    Resume Exit_Cmd91h_Click
    
End Sub
Private Sub Cmd91m_Click()
On Error GoTo Err_Cmd91m_Click

    Dim stDocName As String

    stDocName = "91 - Calcul du coût ramené à la surface de vente pour mixte"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd91m_Click:
    Exit Sub

Err_Cmd91m_Click:
    MsgBox err.Description
    Resume Exit_Cmd91m_Click
    
End Sub
Private Sub Cmd92_Click()
On Error GoTo Err_Cmd92_Click

    Dim stDocName As String

    stDocName = "92 - Calcul du coût de dépannage correctif par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd92_Click:
    Exit Sub

Err_Cmd92_Click:
    MsgBox err.Description
    Resume Exit_Cmd92_Click
    
End Sub
Private Sub Cmd92f_Click()
On Error GoTo Err_Cmd92f_Click

    Dim stDocName As String

    stDocName = "92 - Calcul du coût de dépannage correctif par site pour femme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd92f_Click:
    Exit Sub

Err_Cmd92f_Click:
    MsgBox err.Description
    Resume Exit_Cmd92f_Click
    
End Sub
Private Sub Cmd92h_Click()
On Error GoTo Err_Cmd92h_Click

    Dim stDocName As String

    stDocName = "92 - Calcul du coût de dépannage correctif par site pour homme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd92h_Click:
    Exit Sub

Err_Cmd92h_Click:
    MsgBox err.Description
    Resume Exit_Cmd92h_Click
    
End Sub
Private Sub Cmd92m_Click()
On Error GoTo Err_Cmd92m_Click

    Dim stDocName As String

    stDocName = "92 - Calcul du coût de dépannage correctif par site pour mixte"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd92m_Click:
    Exit Sub

Err_Cmd92m_Click:
    MsgBox err.Description
    Resume Exit_Cmd92m_Click
    
End Sub
Private Sub Cmd95_Click()
On Error GoTo Err_Cmd95_Click

    Dim stDocName As String

    stDocName = "95 - Coût moyen d'un dépannage correctif par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd95_Click:
    Exit Sub

Err_Cmd95_Click:
    MsgBox err.Description
    Resume Exit_Cmd95_Click
    
End Sub
Private Sub Cmd95f_Click()
On Error GoTo Err_Cmd95f_Click

    Dim stDocName As String

    stDocName = "95 - Coût moyen d'un dépannage correctif par site pour femme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd95f_Click:
    Exit Sub

Err_Cmd95f_Click:
    MsgBox err.Description
    Resume Exit_Cmd95f_Click
    
End Sub
Private Sub Cmd95h_Click()
On Error GoTo Err_Cmd95h_Click

    Dim stDocName As String

    stDocName = "95 - Coût moyen d'un dépannage correctif par site pour homme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd95h_Click:
    Exit Sub

Err_Cmd95h_Click:
    MsgBox err.Description
    Resume Exit_Cmd95h_Click
    
End Sub
Private Sub Cmd95m_Click()
On Error GoTo Err_Cmd95m_Click

    Dim stDocName As String

    stDocName = "95 - Coût moyen d'un dépannage correctif par site pour mixte"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd95m_Click:
    Exit Sub

Err_Cmd95m_Click:
    MsgBox err.Description
    Resume Exit_Cmd95m_Click
    
End Sub
Private Sub Cmd96_Click()
On Error GoTo Err_Cmd96_Click

    Dim stDocName As String

    stDocName = "96 - Coût moyen d'un dépannage correctif par intervention"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd96_Click:
    Exit Sub

Err_Cmd96_Click:
    MsgBox err.Description
    Resume Exit_Cmd96_Click
    
End Sub
Private Sub Cmd96f_Click()
On Error GoTo Err_Cmd96f_Click

    Dim stDocName As String

    stDocName = "96 - Coût moyen d'un dépannage correctif par intervention femme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd96f_Click:
    Exit Sub

Err_Cmd96f_Click:
    MsgBox err.Description
    Resume Exit_Cmd96f_Click
    
End Sub
Private Sub Cmd96h_Click()
On Error GoTo Err_Cmd96h_Click

    Dim stDocName As String

    stDocName = "96 - Coût moyen d'un dépannage correctif par intervention homme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd96h_Click:
    Exit Sub

Err_Cmd96h_Click:
    MsgBox err.Description
    Resume Exit_Cmd96h_Click
    
End Sub
Private Sub Cmd97_Click()
On Error GoTo Err_Cmd97_Click

    Dim stDocName As String

    stDocName = "96 - Coût moyen d'un dépannage correctif par intervention mixte"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd97_Click:
    Exit Sub

Err_Cmd97_Click:
    MsgBox err.Description
    Resume Exit_Cmd97_Click
    
End Sub
Private Sub Cmd97p_Click()
On Error GoTo Err_Cmd97p_Click

    Dim stDocName As String

    stDocName = "97 - Pourcentage Nombre de dépannage correctif par zone"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd97p_Click:
    Exit Sub

Err_Cmd97p_Click:
    MsgBox err.Description
    Resume Exit_Cmd97p_Click
    
End Sub
Private Sub Cmd98_Click()
On Error GoTo Err_Cmd98_Click

    Dim stDocName As String

    stDocName = "98 - Nombre total de dépannage correctif par type de panne"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd98_Click:
    Exit Sub

Err_Cmd98_Click:
    MsgBox err.Description
    Resume Exit_Cmd98_Click
    
End Sub
Private Sub Cmd71f_Click()
On Error GoTo Err_Cmd71f_Click

    Dim stDocName As String

    stDocName = "71 - Calcul du coût ramené à la surface de vente pour femme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd71f_Click:
    Exit Sub

Err_Cmd71f_Click:
    MsgBox err.Description
    Resume Exit_Cmd71f_Click
    
End Sub
Private Sub CmdItDep_Click()
On Error GoTo Err_CmdItDep_Click

    Dim stDocName As String

    stDocName = "102 - Intervention dépannage palliatif H+8 dépassé"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdItDep_Click:
    Exit Sub

Err_CmdItDep_Click:
    MsgBox err.Description
    Resume Exit_CmdItDep_Click
    
End Sub
Private Sub CmdListeInterventionAFacturer_Click()
On Error GoTo Err_CmdListeInterventionAFacturer_Click

    Dim stDocName As String

    stDocName = "ListeInterventionAFacturer"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdListeInterventionAFacturer_Click:
    Exit Sub

Err_CmdListeInterventionAFacturer_Click:
    MsgBox err.Description
    Resume Exit_CmdListeInterventionAFacturer_Click
    
End Sub
Private Sub Cmd11_Click()
On Error GoTo Err_Cmd11_Click

    Dim stDocName As String

    stDocName = "11 - Nombre de visites de dépannage même temps entretien"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd11_Click:
    Exit Sub

Err_Cmd11_Click:
    MsgBox err.Description
    Resume Exit_Cmd11_Click
    
End Sub
Private Sub CmdPlanningT1_Click()
On Error GoTo Err_CmdPlanningT1_Click

    Dim stDocName As String

    Call GenererPlanningPrevisionnel
    
    stDocName = "SiteEntretienGeneralT1"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdPlanningT1_Click:
    Exit Sub

Err_CmdPlanningT1_Click:
    MsgBox err.Description
    Resume Exit_CmdPlanningT1_Click
    
End Sub
Private Sub CmdPlanningT2_Click()
On Error GoTo Err_CmdPlanningT2_Click

    Dim stDocName As String

    Call GenererPlanningPrevisionnel
    
    stDocName = "SiteEntretienGeneralT2"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdPlanningT2_Click:
    Exit Sub

Err_CmdPlanningT2_Click:
    MsgBox err.Description
    Resume Exit_CmdPlanningT2_Click
    
End Sub
Private Sub CmdPlanningT3_Click()
On Error GoTo Err_CmdPlanningT3_Click

    Dim stDocName As String

    Call GenererPlanningPrevisionnel
    
    stDocName = "SiteEntretienGeneralT3"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdPlanningT3_Click:
    Exit Sub

Err_CmdPlanningT3_Click:
    MsgBox err.Description
    Resume Exit_CmdPlanningT3_Click
    
End Sub
Private Sub CmdPlanningT4_Click()
On Error GoTo Err_CmdPlanningT4_Click

    Dim stDocName As String

    Call GenererPlanningPrevisionnel
    
    stDocName = "SiteEntretienGeneralT4"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdPlanningT4_Click:
    Exit Sub

Err_CmdPlanningT4_Click:
    MsgBox err.Description
    Resume Exit_CmdPlanningT4_Click
    
End Sub
Private Sub CmdSiteTravauxCreation_Click()
On Error GoTo Err_CmdSiteTravauxCreation_Click

    Dim stDocName As String

    stDocName = "12 - Liste des sites en travaux ou en création"
    DoCmd.OpenReport stDocName, acPreview

Exit_CmdSiteTravauxCreation_Click:
    Exit Sub

Err_CmdSiteTravauxCreation_Click:
    MsgBox err.Description
    Resume Exit_CmdSiteTravauxCreation_Click
    
End Sub
Private Sub Cmd39_Click()
On Error GoTo Err_Cmd39_Click

    Dim stDocName As String

    stDocName = "39 - Nombre total de dépannage avec date par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd39_Click:
    Exit Sub

Err_Cmd39_Click:
    MsgBox err.Description
    Resume Exit_Cmd39_Click
    
End Sub
Private Sub Cmd59_Click()
On Error GoTo Err_Cmd59_Click

    Dim stDocName As String

    stDocName = "59 - Nombre total de dépannage curatif avec date par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd59_Click:
    Exit Sub

Err_Cmd59_Click:
    MsgBox err.Description
    Resume Exit_Cmd59_Click
    
End Sub
Private Sub Cmd79_Click()
On Error GoTo Err_Cmd79_Click

    Dim stDocName As String

    stDocName = "79 - Nombre total de dépannage correctif avec date par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd79_Click:
    Exit Sub

Err_Cmd79_Click:
    MsgBox err.Description
    Resume Exit_Cmd79_Click
    
End Sub
Private Sub Cmd103_Click()
On Error GoTo Err_Cmd103_Click

    Dim stDocName As String

    stDocName = "103 - Ecart de temps décroissant sur dépannage palliatif"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd103_Click:
    Exit Sub

Err_Cmd103_Click:
    MsgBox err.Description
    Resume Exit_Cmd103_Click
    
End Sub
Private Sub Cmd104_Click()
On Error GoTo Err_Cmd104_Click

    Dim stDocName As String

    stDocName = "104 - Nombre de pannes résolues par téléphone"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd104_Click:
    Exit Sub

Err_Cmd104_Click:
    MsgBox err.Description
    Resume Exit_Cmd104_Click
    
End Sub
Private Sub Cmd111_Click()
On Error GoTo Err_Cmd111_Click

    Dim stDocName As String

    stDocName = "111 - Calcul du coût ramené à la surface de vente"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd111_Click:
    Exit Sub

Err_Cmd111_Click:
    MsgBox err.Description
    Resume Exit_Cmd111_Click
    
End Sub
Private Sub Cmd111f_Click()
On Error GoTo Err_Cmd111f_Click

    Dim stDocName As String

    stDocName = "111 - Calcul du coût ramené à la surface de vente pour femme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd111f_Click:
    Exit Sub

Err_Cmd111f_Click:
    MsgBox err.Description
    Resume Exit_Cmd111f_Click
    
End Sub
Private Sub Cmd111h_Click()
On Error GoTo Err_Cmd111h_Click

    Dim stDocName As String

    stDocName = "111 - Calcul du coût ramené à la surface de vente pour homme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd111h_Click:
    Exit Sub

Err_Cmd111h_Click:
    MsgBox err.Description
    Resume Exit_Cmd111h_Click
    
End Sub
Private Sub Cmd111m_Click()
On Error GoTo Err_Cmd111m_Click

    Dim stDocName As String

    stDocName = "111 - Calcul du coût ramené à la surface de vente pour mixte"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd111m_Click:
    Exit Sub

Err_Cmd111m_Click:
    MsgBox err.Description
    Resume Exit_Cmd111m_Click
    
End Sub
Private Sub Cmd112_Click()
On Error GoTo Err_Cmd112_Click

    Dim stDocName As String

    stDocName = "112 - Calcul du coût de dépannage palliatif par site"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd112_Click:
    Exit Sub

Err_Cmd112_Click:
    MsgBox err.Description
    Resume Exit_Cmd112_Click
    
End Sub
Private Sub Cmd112f_Click()
On Error GoTo Err_Cmd112f_Click

    Dim stDocName As String

    stDocName = "112 - Calcul du coût de dépannage palliatif par site pour femme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd112f_Click:
    Exit Sub

Err_Cmd112f_Click:
    MsgBox err.Description
    Resume Exit_Cmd112f_Click
    
End Sub
Private Sub Cmd112h_Click()
On Error GoTo Err_Cmd112h_Click

    Dim stDocName As String

    stDocName = "112 - Calcul du coût de dépannage palliatif par site pour homme"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd112h_Click:
    Exit Sub

Err_Cmd112h_Click:
    MsgBox err.Description
    Resume Exit_Cmd112h_Click
    
End Sub
Private Sub Cmd112m_Click()
On Error GoTo Err_Cmd112m_Click

    Dim stDocName As String

    stDocName = "112 - Calcul du coût de dépannage palliatif par site pour mixte"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd112m_Click:
    Exit Sub

Err_Cmd112m_Click:
    MsgBox err.Description
    Resume Exit_Cmd112m_Click
    
End Sub
Private Sub Cmd113_Click()
On Error GoTo Err_Cmd113_Click

    Dim stDocName As String

    stDocName = "113 - Calcul du coût de dépannage palliatif par situation"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd113_Click:
    Exit Sub

Err_Cmd113_Click:
    MsgBox err.Description
    Resume Exit_Cmd113_Click
    
End Sub
Private Sub Cmd114_Click()
On Error GoTo Err_Cmd114_Click

    Dim stDocName As String

    stDocName = "114 - Calcul du coût de dépannage palliatif par zone"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd114_Click:
    Exit Sub

Err_Cmd114_Click:
    MsgBox err.Description
    Resume Exit_Cmd114_Click
    
End Sub
Private Sub Cmd115_Click()
On Error GoTo Err_Cmd115_Click

    Dim stDocName As String

    stDocName = "115 - Calcul du coût de dépannage palliatif par civilité"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd115_Click:
    Exit Sub

Err_Cmd115_Click:
    MsgBox err.Description
    Resume Exit_Cmd115_Click
    
End Sub
Private Sub Cmd123_Click()
On Error GoTo Err_Cmd123_Click

    Dim stDocName As String

    stDocName = "123 - Calcul du coût de dépannage curatif par situation"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd123_Click:
    Exit Sub

Err_Cmd123_Click:
    MsgBox err.Description
    Resume Exit_Cmd123_Click
    
End Sub
Private Sub Cmd124_Click()
On Error GoTo Err_Cmd124_Click

    Dim stDocName As String

    stDocName = "124 - Calcul du coût de dépannage curatif par zone"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd124_Click:
    Exit Sub

Err_Cmd124_Click:
    MsgBox err.Description
    Resume Exit_Cmd124_Click
    
End Sub
Private Sub Cmd125_Click()
On Error GoTo Err_Cmd125_Click

    Dim stDocName As String

    stDocName = "125 - Calcul du coût de dépannage curatif par civilité"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd125_Click:
    Exit Sub

Err_Cmd125_Click:
    MsgBox err.Description
    Resume Exit_Cmd125_Click
    
End Sub
Private Sub Cmd133_Click()
On Error GoTo Err_Cmd133_Click

    Dim stDocName As String

    stDocName = "133 - Calcul du coût de dépannage correctif par situation"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd133_Click:
    Exit Sub

Err_Cmd133_Click:
    MsgBox err.Description
    Resume Exit_Cmd133_Click
    
End Sub
Private Sub Cmd134_Click()
On Error GoTo Err_Cmd134_Click

    Dim stDocName As String

    stDocName = "134 - Calcul du coût de dépannage correctif par zone"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd134_Click:
    Exit Sub

Err_Cmd134_Click:
    MsgBox err.Description
    Resume Exit_Cmd134_Click
    
End Sub
Private Sub Cmd135_Click()
On Error GoTo Err_Cmd135_Click

    Dim stDocName As String

    stDocName = "135 - Calcul du coût de dépannage correctif par civilité"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd135_Click:
    Exit Sub

Err_Cmd135_Click:
    MsgBox err.Description
    Resume Exit_Cmd135_Click
    
End Sub
Private Sub Cmd101_Click()
On Error GoTo Err_Cmd101_Click

    Dim stDocName As String

    stDocName = "101 - Ecart de temps sur dépannage palliatif"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd101_Click:
    Exit Sub

Err_Cmd101_Click:
    MsgBox err.Description
    Resume Exit_Cmd101_Click
    
End Sub
Private Sub Cmd116_Click()
On Error GoTo Err_Cmd116_Click

    Dim stDocName As String

    stDocName = "116 - Calcul du coût de dépannage palliatif par type"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd116_Click:
    Exit Sub

Err_Cmd116_Click:
    MsgBox err.Description
    Resume Exit_Cmd116_Click
    
End Sub
Private Sub Cmd126_Click()
On Error GoTo Err_Cmd126_Click

    Dim stDocName As String

    stDocName = "126 - Calcul du coût de dépannage curatif par type"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd126_Click:
    Exit Sub

Err_Cmd126_Click:
    MsgBox err.Description
    Resume Exit_Cmd126_Click
    
End Sub
Private Sub Cmd136_Click()
On Error GoTo Err_Cmd136_Click

    Dim stDocName As String

    stDocName = "136 - Calcul du coût de dépannage correctif par type"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd136_Click:
    Exit Sub

Err_Cmd136_Click:
    MsgBox err.Description
    Resume Exit_Cmd136_Click
    
End Sub
Private Sub CmdListeSiteIntervenant_Click()
On Error GoTo Err_CmdListeSiteIntervenant_Click

    Dim stDocName As String
    Dim lCritere As String
    
    If Me.LstIntervenant <> "" Then lCritere = "nomzon = '" & Me.LstIntervenant & "' or codint='" & Me.LstIntervenant & "'"

    If Form_MenuPrincipal.ListeTri.Value = 2 Then
        stDocName = "ListeSiteIntervenantNum"
    Else
        stDocName = "ListeSiteIntervenant"
    End If
    
    If ddlTypeSite = "Hommes et mixte" Then
        If lCritere <> "" Then lCritere = lCritere & " AND "
        lCritere = lCritere & "typsit IN ('H', 'M')"
    ElseIf ddlTypeSite = "Femmes" Then
        If lCritere <> "" Then lCritere = lCritere & " AND "
        lCritere = lCritere & "typsit = 'F'"
    End If
    
    DoCmd.OpenReport stDocName, acPreview, , lCritere

Exit_CmdListeSiteIntervenant_Click:
    Exit Sub

Err_CmdListeSiteIntervenant_Click:
    MsgBox err.Description
    Resume Exit_CmdListeSiteIntervenant_Click
    
End Sub
Private Sub CmdListeSimpleSite_Click()
On Error GoTo Err_CmdListeSimpleSite_Click

    Dim stDocName As String
    Dim lCritere As String
    
    If Form_MenuPrincipal.ListeTri.Value = 2 Then
        stDocName = "ListeSiteSimpleNum"
    Else
        stDocName = "ListeSiteSimple"
    End If
    
    If ddlTypeSite = "Hommes et mixte" Then
        lCritere = lCritere & "typsit IN ('H', 'M')"
    ElseIf ddlTypeSite = "Femmes" Then
        lCritere = lCritere & "typsit = 'F'"
    End If
    
    DoCmd.OpenReport stDocName, acPreview, , lCritere

Exit_CmdListeSimpleSite_Click:
    Exit Sub

Err_CmdListeSimpleSite_Click:
    MsgBox err.Description
    Resume Exit_CmdListeSimpleSite_Click
    
End Sub
Private Sub CmdMajSite_Click()
On Error GoTo Err_CmdMajSite_Click

    Dim stDocName As String

    stDocName = "ImportAnnuaireAT"
    DoCmd.RunMacro stDocName

Exit_CmdMajSite_Click:
    Exit Sub

Err_CmdMajSite_Click:
    MsgBox err.Description
    Resume Exit_CmdMajSite_Click
    
End Sub
Private Sub CmdListeSiteRedevance_Click()
On Error GoTo Err_CmdListeSiteRedevance_Click

    Dim stDocName As String
    Dim lCritere As String: lCritere = ""
    
    If Form_MenuPrincipal.ListeTri.Value = 2 Then
        stDocName = "ListeSiteRedevanceNum"
    Else
        stDocName = "ListeSiteRedevance"
    End If
    
    ' Uniquement pour Armand Thierry
    If LstClient = 1 Then
        If ddlTypeSite = "Hommes et mixte" Then
            lCritere = lCritere & "typsit IN ('H', 'H et F')"
        ElseIf ddlTypeSite = "Femmes" Then
            lCritere = lCritere & "typsit = 'F'"
        End If
    End If
    
    DoCmd.OpenReport stDocName, acPreview, , lCritere

Exit_CmdListeSiteRedevance_Click:
    Exit Sub

Err_CmdListeSiteRedevance_Click:
    MsgBox err.Description
    Resume Exit_CmdListeSiteRedevance_Click
    
End Sub
Private Sub Cmd117_Click()
On Error GoTo Err_Cmd117_Click

    Dim stDocName As String

    stDocName = "117 - Ecart de temps décroissant sur dépannage palliatif modes"
    DoCmd.OpenReport stDocName, acPreview

Exit_Cmd117_Click:
    Exit Sub

Err_Cmd117_Click:
    MsgBox err.Description
    Resume Exit_Cmd117_Click
    
End Sub
Private Sub CmdCelio_Click()
On Error GoTo Err_CmdCelio_Click

    Dim stDocName As String

    stDocName = "ImportAnnuaireCELIO"
    DoCmd.RunMacro stDocName

Exit_CmdCelio_Click:
    Exit Sub

Err_CmdCelio_Click:
    MsgBox err.Description
    Resume Exit_CmdCelio_Click
    
End Sub


Private Sub Form_Load()
CurrentDb.Execute ("DELETE parametre.numpar FROM parametre WHERE (((parametre.numpar)<>1));")
Me.Requery
    DoCmd.ShowToolbar "CLIM'TECH Formulaire", acToolbarYes
End Sub
Private Sub btnModeleRepertoireTechnique_Click()
On Error GoTo Err_btnModeleRepertoireTechnique_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "ModeleRepertoireTechnique"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_btnModeleRepertoireTechnique_Click:
    Exit Sub

Err_btnModeleRepertoireTechnique_Click:
    MsgBox err.Description
    Resume Exit_btnModeleRepertoireTechnique_Click
    
End Sub
Private Sub btnChampsRepertoireTechnique_Click()
On Error GoTo Err_btnChampsRepertoireTechnique_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "ChampRepertoireTechnique"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_btnChampsRepertoireTechnique_Click:
    Exit Sub

Err_btnChampsRepertoireTechnique_Click:
    MsgBox err.Description
    Resume Exit_btnChampsRepertoireTechnique_Click
    
End Sub
Private Sub BtnImprimerInterventionEnCours_Click()
On Error GoTo Err_BtnImprimerInterventionEnCours_Click

    Dim stDocName As String
    Dim sCondition As String
    Dim sArgs As String
    stDocName = "Listes des interventions en cours"
    If CboSuiviClient <> "" Then
        sCondition = "numcli=" & CboSuiviClient
        If CboSuiviIntervenant <> "" Then
            sCondition = sCondition & " and codint='" & CboSuiviIntervenant & "'"
        End If
        If CadreSuivi = 1 Then
            sArgs = "en cours"
            sCondition = sCondition & " and staint<9 and datint is null"
        Else
            sArgs = "effectuées"
            sCondition = sCondition & " and datint is not null "
        End If
        
    Else
        If CboSuiviIntervenant <> "" Then
            sCondition = sCondition & "codint='" & CboSuiviIntervenant & "'"
            If CadreSuivi = 1 Then
                sArgs = "en cours"
                sCondition = sCondition & " and staint<9 and datint is null"
            Else
                sArgs = "effectuées"
                sCondition = sCondition & " and datint is not null "
            End If
        Else
            If CadreSuivi = 1 Then
                sArgs = "en cours"
                sCondition = "staint<9 and datint is null"
            Else
                sArgs = "effectuées"
                sCondition = " datint is not null "
            End If
        End If
    End If
    DoCmd.OpenReport stDocName, acPreview, , sCondition, , sArgs

Exit_BtnImprimerInterventionEnCours_Clic:
    Exit Sub

Err_BtnImprimerInterventionEnCours_Click:
    MsgBox err.Description
    Resume Exit_BtnImprimerInterventionEnCours_Clic
    
End Sub
Private Sub cmdIntT1_Click()
On Error GoTo Err_cmdIntT1_Click

    Dim stDocName As String

    stDocName = "Interventions par client premier trimestre"
    DoCmd.OpenReport stDocName, acPreview, , "numcli=" & Me.numcli

Exit_cmdIntT1_Click:
    Exit Sub

Err_cmdIntT1_Click:
    MsgBox err.Description
    Resume Exit_cmdIntT1_Click
    
End Sub
Private Sub btnIntTrim_Click()
On Error GoTo Err_btnIntTrim_Click

    Dim stDocName As String
    Dim stType As String


    '[Report_Entretiens par trimestre].Report.RecordSource = "SELECT numsit, typsit, nomsit, numcli, cptsit FROM Site WHERE numcli = " & Me.numcli & "ORDER BY nomsit"
    
    stDocName = "Entretiens par trimestre"

    If cmbIntTrimType = "H et mixte" Then
        stType = " AND typsit LIKE 'H%'"
    ElseIf cmbIntTrimType = "F" Then
        stType = " AND typsit = 'F'"
    Else
        stType = vbNullString
    End If

    DoCmd.OpenReport stDocName, acPreview, stType
    

Exit_btnIntTrim_Click:
    Exit Sub

Err_btnIntTrim_Click:
    MsgBox err.Description
    Resume Exit_btnIntTrim_Click
    
End Sub
Private Sub cmdTypeFluide_Click()
On Error GoTo Err_cmdTypeFluide_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "TypeFluideFormulaire"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_cmdTypeFluide_Click:
    Exit Sub

Err_cmdTypeFluide_Click:
    MsgBox err.Description
    Resume Exit_cmdTypeFluide_Click
    
End Sub
Private Sub cmdClimserv_Click()
On Error GoTo Err_cmdClimserv_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Climserv"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_cmdClimserv_Click:
    Exit Sub

Err_cmdClimserv_Click:
    MsgBox err.Description
    Resume Exit_cmdClimserv_Click
    
End Sub
Private Sub cmdClientsClimServ_Click()
On Error GoTo Err_cmdClientsClimServ_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Clients ClimServ"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_cmdClientsClimServ_Click:
    Exit Sub

Err_cmdClientsClimServ_Click:
    MsgBox err.Description
    Resume Exit_cmdClientsClimServ_Click
    
End Sub
Private Sub Commande293_Click()
On Error GoTo Err_Commande293_Click

    Dim stDocName As String
    Dim stCritere As String
    
    stCritere = "numcli=" & Me.LstClient
    
    stDocName = "137bis - Liste des sites avec aspirateur"
    DoCmd.OpenReport stDocName, acPreview, , stCritere

Exit_Commande293_Click:
    Exit Sub

Err_Commande293_Click:
    MsgBox err.Description
    Resume Exit_Commande293_Click
    
End Sub
Private Sub cmdCouverture_Click()
On Error GoTo Err_cmdCouverture_Click

    Dim stDocName As String

    stDocName = "Couverture"
    DoCmd.OpenReport stDocName, acPreview

Exit_cmdCouverture_Click:
    Exit Sub

Err_cmdCouverture_Click:
    MsgBox err.Description
    Resume Exit_cmdCouverture_Click
    
End Sub
Private Sub Commande297_Click()
On Error GoTo Err_Commande297_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Import_de_site_en_Excel"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_Commande297_Click:
    Exit Sub

Err_Commande297_Click:
    MsgBox err.Description
    Resume Exit_Commande297_Click
    
End Sub

Private Sub Commande298_Click()
On Error GoTo Err_Commande298_Click

    Dim stDocName As String

    stDocName = "01 - Nombre total de visite d'entretien par mois"
    DoCmd.OpenReport stDocName, acPreview

Exit_Commande298_Click:
    Exit Sub

Err_Commande298_Click:
    MsgBox err.Description
    Resume Exit_Commande298_Click
    
End Sub
Private Sub Commande300_Click()
On Error GoTo Err_Commande300_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "ImportFichesInter"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_Commande300_Click:
    Exit Sub

Err_Commande300_Click:
    MsgBox err.Description
    Resume Exit_Commande300_Click
    
End Sub
Private Sub Commande301_Click()
On Error GoTo Err_Commande301_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "SaisieEnTableau"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_Commande301_Click:
    Exit Sub

Err_Commande301_Click:
    MsgBox err.Description
    Resume Exit_Commande301_Click
    
End Sub
Private Sub CmdRelinkTables_Click()
On Error GoTo Err_CmdRelinkTables_Click

    Dim tdf As dao.TableDef
  
    For Each tdf In CurrentDb.TableDefs
        ' check if table is a linked table
        If Len(tdf.Connect) > 0 Then
            tdf.Connect = "Data Source=serveur;Initial Catalog=logiclim;User Id=abrminfo;Password=[REDACTED];"
            tdf.RefreshLink
        End If
    Next
  
    
Exit_CmdRelinkTables_Click:
    Exit Sub

Err_CmdRelinkTables_Click:
    MsgBox err.Description
    Resume Exit_CmdRelinkTables_Click
    
End Sub
