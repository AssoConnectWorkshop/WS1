Attribute VB_Name = "Form_Intervenant Sous-formulaire Maintenance"
Attribute VB_Base = "0{CBCB945E-EA0F-4257-9F24-B7E68836E43B}"
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
