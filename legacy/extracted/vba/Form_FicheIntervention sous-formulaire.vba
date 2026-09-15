Attribute VB_Name = "Form_FicheIntervention sous-formulaire"
Attribute VB_Base = "0{D0DFFA96-AE6F-48E9-91E7-4B724A087894}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database



Private Sub Date_Exit(Cancel As Integer)
'Cohérence de la date réelle en fonction de la date d'appel
    If Not IsNull(Me.Date) Then
            If DateDiff("d", Forms![Intervention]![datheuapp], CDate(Me.Date)) < 0 Then
                MsgBox "La date/heure d'arrivée doit être ultérieure à la date/heure d'appel", vbExclamation, "Attention"
                Cancel = True
            End If
    End If
End Sub

Private Sub N°_de_bon_AfterUpdate()
On Error Resume Next
Forms!Intervention!numint = N°_de_Bon


End Sub
