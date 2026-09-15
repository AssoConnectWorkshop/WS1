Attribute VB_Name = "Form_Zone Geographique"
Attribute VB_Base = "0{64A717C5-3FC4-468D-9812-9F44EB05EBA1}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub cmdValider_Click()
    On Error GoTo Err_cmdValider_Click

    stCritere = "numcli=" & Form_MenuPrincipal.LstClient
    
    If Me.LstZoneGeographique <> "" Then
        stCritere = stCritere & " AND numzonsit = " & Me.LstZoneGeographique
    End If
    
    stDocName = "137 - Liste des sites avec aspirateur"
    DoCmd.OpenReport stDocName, acPreview, , stCritere
    
Exit_cmdValider_Click:
    Exit Sub

Err_cmdValider_Click:
    MsgBox err.Description
    Resume Exit_cmdValider_Click
End Sub
