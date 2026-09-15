Attribute VB_Name = "Form_Intervenant Sous-formulaire Depannage"
Attribute VB_Base = "0{0F047F80-82E8-4F75-900C-95077B0F1A1C}"
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
