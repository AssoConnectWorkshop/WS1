Attribute VB_Name = "Form_Intervenant Sous-formulaire Clim"
Attribute VB_Base = "0{CD498B6B-6A1D-4B13-9188-37785D71B720}"
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
