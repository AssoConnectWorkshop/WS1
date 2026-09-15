Attribute VB_Name = "Form_ListeInterventionGaz sous-formulaire"
Attribute VB_Base = "0{B6DE9B53-7785-4F8F-9CAE-9BD282E95F83}"
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



Private Sub Form_Load()
    Dim calibre As Integer
    calibre = 100
    Me.LstIntervenant.ColumnWidth = 14.875 * calibre
    'Me.numcli.ColumnWidth = 12 * calibre
    Me.nomsit.ColumnWidth = 28 * calibre
    Me.codpossit.ColumnWidth = 5.625 * calibre
    Me.vilsit.ColumnWidth = 19 * calibre
    Me.typint.ColumnWidth = 14 * calibre
    Me.datint.ColumnWidth = 12.625 * calibre
    Me.staint.ColumnWidth = 16 * calibre

    
    
    Me.LstIntervenant.TabIndex = 1
    'Me.numcli.ColumnWidth = 12 * calibre
    Me.nomsit.TabIndex = 3
    Me.codpossit.TabIndex = 4
    Me.vilsit.TabIndex = 5
    Me.typint.TabIndex = 6
    Me.datint.TabIndex = 9
    Me.staint.TabIndex = 10
        'Me.Modifiable417.RowSource = "SELECT dbo_StatutFacture.IndexLigne, dbo_StatutFacture.Statut FROM dbo_StatutFacture"
   
End Sub

Private Sub Modifiable417_BeforeUpdate(Cancel As Integer)

If (IsNull(Modifiable417.OldValue) = False) Then
    Rep = Verification_Droit_Modif(Modifiable417.OldValue, False)
    If (Rep = False) Then
        MsgBox "Vous n'avez pas les droits pour faire ce changement", vbCritical, "Interdit"
        Cancel = True
        Exit Sub
    End If
End If
Rep = Verification_Droit_Modif(Modifiable417.Text, True)
If (Rep = False) Then
    MsgBox "Vous n'avez pas les droits pour faire ce changement", vbCritical, "Interdit"
    Cancel = True
End If
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
