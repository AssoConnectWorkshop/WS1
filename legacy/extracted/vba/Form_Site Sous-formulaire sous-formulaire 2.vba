Attribute VB_Name = "Form_Site Sous-formulaire sous-formulaire 2"
Attribute VB_Base = "0{FC31344E-3768-40A9-B140-360B89C83E2E}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database



Private Sub Form_ApplyFilter(Cancel As Integer, ApplyType As Integer)
'27/01/25 Ajout du filtre pour eviter de charger toutes les inter OM
'If IsNull(Me.cptsit) = False Then
'    Texte_Requete = "SELECT [Site Sous-formulaire].cptsit, [Site Sous-formulaire].codint, [Site Sous-formulaire].[prévue le], [Site Sous-formulaire].[effectuée le], [Site Sous-formulaire].typint, [Site Sous-formulaire].Statut, [Site Sous-formulaire].numintint, [Site Sous-formulaire].datheuapp, [Site Sous-formulaire].devisfait, [Site Sous-formulaire].devisafaire, [Site Sous-formulaire].datheulim, [Site Sous-formulaire].numint, [Site Sous-formulaire].refint, [Site Sous-formulaire].refcliint, [Site Sous-formulaire].numdevacc, [Site Sous-formulaire].NumeroDevis, [Site Sous-formulaire].NumeroDevisInterne, [Site Sous-formulaire].Intervention.cheficdemint, [Site Sous-formulaire].cheficdemcli, [Site Sous-formulaire].StatutDevis, [Site Sous-formulaire].NomFichierDevis, [Site Sous-formulaire].[Statut Facturation]"
'    Texte_Requete = Texte_Requete + " From [Site Sous-formulaire] "
'    Texte_Requete = Texte_Requete + " WHERE ((([Site Sous-formulaire].Statut) = 7 or  ([Site Sous-formulaire].Statut) = 10 or ([Site Sous-formulaire].Statut) = 8 And ([Site Sous-formulaire].Statut) = 20)) And [Site Sous-formulaire].cptsit=" + Str(Me.cptsit) + " "
'    Texte_Requete = Texte_Requete + " ORDER BY [Site Sous-formulaire].[prévue le] DESC , [Site Sous-formulaire].[effectuée le] DESC"
'    Me.Form.RecordSource = Texte_Requete
'    Me.Requery
'End If
End Sub



Private Sub Form_Delete(Cancel As Integer)
    CurrentDb.Execute "delete from intervention where numintint=" & Me.numintint, dbSeeChanges
End Sub





Private Sub Intervenant_DblClick(Cancel As Integer)
On Error GoTo Err_CmdOuvrirInterventions_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    'GformulaireParent = "site"
    
    'If typint = 1 Then
    '    stDocName = "InterventionEntretien"
    'Else
        stDocName = "Intervention"
    'End If
    stLinkCriteria = "numintint=" & Me!numintint
    'If Me.Statut = 1 And Me.Type = 1 Then
    '    arg = "IEP"
    'End If
    'If Me.Statut = 9 And Me.Type = 1 Then
    '    arg = "IEC"
    'End If
   '
   ' If Me.Statut = 1 And (Me.Type = 2 Or Me.Type = 3) Then
   '     arg = "IDE"
   ' End If
   ' If Me.Statut = 9 And (Me.Type = 2 Or Me.Type = 3) Then
   '     arg = "IDC"
   ' End If
   '
   ' If Me.Statut = 1 And Me.Type = 4 Then
   '     arg = "IDCE"
   ' End If
   ' If Me.Statut = 9 And Me.Type = 4 Then
   '     arg = "IDCC"
   ' End If
   '
   ' If Me.Statut = 1 And Me.Type = 5 Then
   '     arg = "IDCE"
   ' End If
   ' If Me.Statut = 9 And Me.Type = 5 Then
   '     arg = "IDCC"
   ' End If
     DoCmd.OpenForm "Intervention", acNormal, "", "numintint=" & Me.numintint, acFormEdit, acWindowNormal ' code Alain
    'DoCmd.OpenForm stDocName, , , stLinkCriteria, , , arg

Exit_CmdOuvrirInterventions_Cli:
    Exit Sub

Err_CmdOuvrirInterventions_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirInterventions_Cli

End Sub


Private Sub Statut_Facturation_BeforeUpdate(Cancel As Integer)

If (IsNull(Statut_Facturation.OldValue) = False) Then
    Rep = Verification_Droit_Modif(Statut_Facturation.OldValue, False)
    If (Rep = False) Then
        MsgBox "Vous n'avez pas les droits pour faire ce changement", vbCritical, "Interdit"
        Cancel = True
        Exit Sub
    End If
End If
Rep = Verification_Droit_Modif(Statut_Facturation.Text, True)
If (Rep = False) Then
    MsgBox "Vous n'avez pas les droits pour faire ce changement", vbCritical, "Interdit"
    Cancel = True
End If
End Sub

Private Sub Texte37_Click()
  MsgBox Me.sigtec, vbInformation, "Information"
End Sub

Private Sub Texte38_Click()
  MsgBox Me.comint, vbInformation, "Information"
End Sub
