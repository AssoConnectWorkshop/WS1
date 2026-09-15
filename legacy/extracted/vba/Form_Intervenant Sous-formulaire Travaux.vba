Attribute VB_Name = "Form_Intervenant Sous-formulaire Travaux"
Attribute VB_Base = "0{49DB6A52-5A3A-457E-A491-42882E482DAB}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Nom_du_site_DblClick(Cancel As Integer)
DoCmd.OpenForm "Site", acNormal, , "cptsit=" & Me.cptsit, acFormEdit
End Sub
