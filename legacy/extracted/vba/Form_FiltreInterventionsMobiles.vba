Attribute VB_Name = "Form_FiltreInterventionsMobiles"
Attribute VB_Base = "0{C21DD81D-83B7-49B0-8543-6FBD5C6F1274}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Commande3_Click()
On Error GoTo Err_Commande3_Click


    If Me.Dirty Then Me.Dirty = False
    DoCmd.Close

Exit_Commande3_Click:
    Exit Sub

Err_Commande3_Click:
    MsgBox err.Description
    Resume Exit_Commande3_Click
    
End Sub
