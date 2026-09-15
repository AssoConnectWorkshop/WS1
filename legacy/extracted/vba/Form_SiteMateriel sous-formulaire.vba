Attribute VB_Name = "Form_SiteMateriel sous-formulaire"
Attribute VB_Base = "0{B1F260BD-CFFA-40D9-A9DE-A991A2710FBE}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Repère_AfterUpdate()
Requete = "SELECT TypeAudit.id, TypeAudit.Type FROM TypeAudit where TypeAudit.Type like '%" + Left(Me.Repère.Text, 2) + "%'"
Me.Type.RowSource = Requete
Me.Type.Requery
End Sub
