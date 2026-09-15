Attribute VB_Name = "Form_ClientListe"
Attribute VB_Base = "0{1272417C-82A3-466C-B60C-B4E72951BC93}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Nom_du_client_DblClick(Cancel As Integer)
    DoCmd.OpenForm "Client", , , "numcli=" & Me.numcli
End Sub
