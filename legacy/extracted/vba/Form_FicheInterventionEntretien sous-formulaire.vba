Attribute VB_Name = "Form_FicheInterventionEntretien sous-formulaire"
Attribute VB_Base = "0{0483173B-1D9A-401C-85DD-DF97BE8BAEC6}"
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
            If DateDiff("d", Forms![interventionEntretien]![datheuapp], CDate(Me.Date)) < 0 Then
                MsgBox "La date/heure d'arrivée doit être ultérieure à la date/heure d'appel", vbExclamation, "Attention"
                Cancel = True
            Else
                Forms!interventionEntretien!datint = DateFicheInt
            End If
    End If
End Sub

Private Sub N°_de_bon_AfterUpdate()
    On Error Resume Next
    Forms!interventionEntretien!numint = N°_de_Bon
End Sub
