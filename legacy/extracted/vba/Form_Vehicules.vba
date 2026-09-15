Attribute VB_Name = "Form_Vehicules"
Attribute VB_Base = "0{EABFD2F4-7211-4154-BEDB-19D936C1F2CB}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub preuti_DblClick(Cancel As Integer)
On Error GoTo Err_Click
    
    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Saisie_Vehicule"
       
    DoCmd.OpenForm stDocName, , , , acFormAdd, acWindowNormal, "NumVehicule =" & Me.NumVehicule
Exit_Commande126_Click:
    Exit Sub

Err_Click:
    MsgBox err.Description
    Resume Exit_Commande126_Click
End Sub
