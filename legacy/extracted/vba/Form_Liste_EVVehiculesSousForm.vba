Attribute VB_Name = "Form_Liste_EVVehiculesSousForm"
Attribute VB_Base = "0{D20555CC-4DC0-478C-952D-F0C19DA61904}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database



Private Sub Form_Dirty(Cancel As Integer)
Dim toto As String
toto = ""
End Sub

 Private Sub Form_Load()
    Dim calibre As Integer
    
    calibre = 100
    Me.DateEv.ColumnWidth = 12.625 * calibre
    Me.Km.ColumnWidth = 12 * calibre
    Me.Immat.ColumnWidth = 10 * calibre
    Me.typev.ColumnWidth = 30 * calibre
    Me.Conduc.ColumnWidth = 25 * calibre
    DoCmd.RunCommand acCmdUnfreezeAllColumns
    
    Me.DateEv.ColumnOrder = 1
    Me.Km.ColumnOrder = 4
    Me.Immat.ColumnOrder = 2
    Me.typev.ColumnOrder = 3
    Me.Conduc.ColumnOrder = 5
   
End Sub

Private Sub nomcli_DblClick(Cancel As Integer)
    DoCmd.OpenForm "Client", acNormal, "", "numcli=" & Me.numcli, acFormEdit, acWindowNormal
End Sub

Private Sub Immat_DblClick(Cancel As Integer)
On Error GoTo Err_Click
    
    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Saisie_Vehicule"
       
    DoCmd.OpenForm stDocName, , , , acFormAdd, acWindowNormal, "Immatriculation ='" & Me.Immat + "'"
Exit_Commande126_Click:
    Exit Sub

Err_Click:
    MsgBox err.Description
    Resume Exit_Commande126_Click
End Sub
