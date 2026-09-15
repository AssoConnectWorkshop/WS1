Attribute VB_Name = "Form_ResultatListeKM"
Attribute VB_Base = "0{FDCF9CD2-3CE1-4C83-BF44-854487F054C7}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database
 

Private Sub codpossit_DblClick(Cancel As Integer)
    DoCmd.OpenForm "Intervention", acNormal, "", "numintint=" & Me.numintint, acFormEdit, acWindowNormal

End Sub

Private Sub Détail_Paint()
     'If Me.staint = 4 Then
     '    Me.Détail.BackColor = 16776960
     'Else
     '    Me.Détail.BackColor = 16777215
     'End If

End Sub

Private Sub Form_Load()
    Dim calibre As Integer
    calibre = 100
    Me.nomcli.ColumnWidth = 20 * calibre
    Me.numsit.ColumnWidth = 50 * calibre
End Sub

Private Sub nomcli_DblClick(Cancel As Integer)
    DoCmd.OpenForm "Client", acNormal, "", "numcli=" & Me.numcli, acFormEdit, acWindowNormal
End Sub

Private Sub nomsit_DblClick(Cancel As Integer)
    DoCmd.OpenForm "Intervention", acNormal, "", "numintint=" & Me.numintint, acFormEdit, acWindowNormal
    'DoCmd.OpenForm "Site", acNormal, "", "cptsit=" & Me.cptsit, acFormEdit, acWindowNormal
End Sub

Private Sub objint_DblClick(Cancel As Integer)
    DoCmd.OpenForm "Intervention", acNormal, "", "numintint=" & Me.numintint, acFormEdit, acWindowNormal
End Sub

Private Sub vilsit_DblClick(Cancel As Integer)
    DoCmd.OpenForm "Intervention", acNormal, "", "numintint=" & Me.numintint, acFormEdit, acWindowNormal

End Sub
