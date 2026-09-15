Attribute VB_Name = "Form_SfMaterielPanne"
Attribute VB_Base = "0{3E5711FB-5E15-4CE0-BEAB-1CA0EFCD37F3}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Commande11_Click()
    reponce = MsgBox(" Voulez vous supprimer cette enregistrement ? ", 260)
    If reponce = 6 Then
        Dim db As dao.Database
        Dim rst As dao.Recordset
        Dim Vsql As String
        Set db = CurrentDb
        Vsql = "DELETE * FROM PanneMaterielSite"
        Vsql = Vsql + " WHERE (((PanneMaterielSite.numintint)= " + Str(numintint) + ") AND ((PanneMaterielSite.numsitmarref)= " + Str(numsitmarref) + "));"
        db.Execute Vsql, dbSeeChanges
        Me.Requery
    End If

End Sub

Private Sub Commande14_Click()
On Error GoTo Err_Commande14_Click


    DoCmd.DoMenuItem acFormBar, acEditMenu, 8, , acMenuVer70
    DoCmd.DoMenuItem acFormBar, acEditMenu, 6, , acMenuVer70

Exit_Commande14_Click:
    Exit Sub

Err_Commande14_Click:
    MsgBox err.Description
    Resume Exit_Commande14_Click
    
End Sub
