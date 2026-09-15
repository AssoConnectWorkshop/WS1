Attribute VB_Name = "Form_Planification_sous formulaire"
Attribute VB_Base = "0{F098ED64-2A95-401A-A49C-F27290551E82}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database



Private Sub Affichage()
    
End Sub

Private Sub lstClient_BeforeUpdate(Cancel As Integer)
    txClient = LstClient
    txClient.Requery
    'Me.Filter = "[numcli]=" & LstClient
End Sub



Private Sub TxtNombreVisite_DblClick(Cancel As Integer)
    Dim Vt As String
    Dim Vl As String
    If IsNull(TxtNombreVisite) Then Exit Sub
    For i = 1 To 12
        Vt = "T" & Trim(Str(i))
        Vl = "L" & Trim(Str(i))
        Forms!Planification!(Vt).Visible = False
        Forms!Planification!(Vl).Visible = False
        Forms!Planification!(Vt) = Null
    
    Next i
    
    Forms!Planification!TxtNombreVisite.Visible = True
    Forms!Planification!TxtNombreVisite = TxtNombreVisite.Value
    Forms!Planification!numeroplanification = numeroplanification
    Forms!Planification!numcli = Me![numcli]
    Forms!Planification!Étiquette83.Visible = True
    
    For i = 1 To Val(TxtNombreVisite)
        Vt = "T" & Trim(Str(i))
        Vl = "L" & Trim(Str(i))
        Forms!Planification!(Vt).Visible = True
        Forms!Planification!(Vl).Visible = True
        Forms!Planification!(Vt) = Me(Vt)
    
    Next i
    

End Sub
