Attribute VB_Name = "Form_Site Sous-formulaire sous-formulaire"
Attribute VB_Base = "0{7FD55A97-87FB-4FDF-836F-17D15736087E}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database


Private Sub Form_Delete(Cancel As Integer)
   
   CurrentDb.Execute "delete from intervention where numintint=" & Me.numintint, dbSeeChanges
End Sub

Private Sub Intervenant_DblClick(Cancel As Integer)
On Error GoTo Err_CmdOuvrirInterventions_Click

    Dim stDocName As String
    Dim stLinkCriteria As String
    
    'GformulaireParent = "site"
    stDocName = "Intervention"
    stLinkCriteria = "numintint=" & Me!numintint
    'If Me.Statut = 1 And Me.Type = 1 Then
        DoCmd.OpenForm "Intervention", acNormal, "", "numintint=" & Me.numintint, acFormEdit, acWindowNormal ' code Alain
        
        'DoCmd.OpenForm "intervention", , , stLinkCriteria
        GoTo Exit_CmdOuvrirInterventions_Cli
    'End If
    
    
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , arg

Exit_CmdOuvrirInterventions_Cli:
    Exit Sub

Err_CmdOuvrirInterventions_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirInterventions_Cli

End Sub
Private Sub Commande25_Click()
On Error GoTo Err_Commande25_Click


    DoCmd.GoToRecord , , acLast

Exit_Commande25_Click:
    Exit Sub

Err_Commande25_Click:
    MsgBox err.Description
    Resume Exit_Commande25_Click
    
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
