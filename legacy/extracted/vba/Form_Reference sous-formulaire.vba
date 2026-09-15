Attribute VB_Name = "Form_Reference sous-formulaire"
Attribute VB_Base = "0{6CC60B5D-D466-44DD-9876-991571825CD1}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub nomref_DblClick(Cancel As Integer)
On Error GoTo Err_Click
    
    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Saisie_Reference"
       
    DoCmd.OpenForm stDocName, , , , acFormAdd, acWindowNormal, "Reference ='" & Me.Reference & "'"
Exit_Commande126_Click:
    Exit Sub

Err_Click:
    MsgBox err.Description
    Resume Exit_Commande126_Click
End Sub
