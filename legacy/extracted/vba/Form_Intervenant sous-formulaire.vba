Attribute VB_Name = "Form_Intervenant sous-formulaire"
Attribute VB_Base = "0{C7C68BA2-D61A-4CC8-A7BF-44157659365B}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub nomint_DblClick(Cancel As Integer)
DoCmd.OpenForm "Intervenant_Fersoft", acNormal, , "nomint='" & Me.nomint & "'", acFormEdit
End Sub
