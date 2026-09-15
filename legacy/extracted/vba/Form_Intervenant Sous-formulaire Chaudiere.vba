Attribute VB_Name = "Form_Intervenant Sous-formulaire Chaudiere"
Attribute VB_Base = "0{EB8C45C9-F658-4828-BB5F-7D26EF7D1BFA}"
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
