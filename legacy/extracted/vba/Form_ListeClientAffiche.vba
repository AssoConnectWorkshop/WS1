Attribute VB_Name = "Form_ListeClientAffiche"
Attribute VB_Base = "0{12A8B100-D809-4A07-8069-8463236674FC}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Cocher2_AfterUpdate()
  
        Dim SQL As String
        If Cocher2 = True Then
            SQL = "SELECT * FROM client"
        
        Else
            SQL = "SELECT * FROM client WHERE (((Client.affcli)=Yes));"
        End If
        Me.ClientListe.Form.RecordSource = SQL
        Me.ClientListe.Requery
        
End Sub

Private Sub Commande4_Click()
On Error GoTo Err_Commande4_Click


    If Me.Dirty Then Me.Dirty = False
    DoCmd.Close

Exit_Commande4_Click:
    Exit Sub

Err_Commande4_Click:
    MsgBox err.Description
    Resume Exit_Commande4_Click
    
End Sub

Private Sub Form_Current()
Me.ClientListe.Width = Me.WindowWidth - 390
End Sub

Private Sub Form_Resize()
    Me.ClientListe.Width = Me.WindowWidth - 390
End Sub
Private Sub CmdPlanifier_Click()
On Error GoTo Err_CmdPlanifier_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Planification"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdPlanifier_Click:
    Exit Sub

Err_CmdPlanifier_Click:
    MsgBox err.Description
    Resume Exit_CmdPlanifier_Click
    
End Sub
