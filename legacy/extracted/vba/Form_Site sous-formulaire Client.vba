Attribute VB_Name = "Form_Site sous-formulaire Client"
Attribute VB_Base = "0{3B9C82B1-C681-49A0-8D8E-6EC0FCB2B88B}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub nomsit_DblClick(Cancel As Integer)
    DoCmd.OpenForm "Site", acNormal, , "cptsit=" & Me.cptsit
End Sub
