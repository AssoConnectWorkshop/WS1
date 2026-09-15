Attribute VB_Name = "Form_SiteMarqueReference Sous-formulaire"
Attribute VB_Base = "0{5E8C49B5-EB64-43B3-B3D6-CBEB2DD0F05F}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Fluide_Exit(Cancel As Integer)
    On Error Resume Next
    Me.fluide = UCase(Me.fluide)
End Sub

Private Sub Référence_AfterUpdate()
On Error Resume Next
    Me.des = Me.Référence.Column(1)
    Me.Marque = Me.Référence.Column(2)
End Sub
