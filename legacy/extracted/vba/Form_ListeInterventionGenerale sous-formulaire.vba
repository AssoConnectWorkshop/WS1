Attribute VB_Name = "Form_ListeInterventionGenerale sous-formulaire"
Attribute VB_Base = "0{7DCA8784-081D-416C-B9A9-7BB66AE105AE}"
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

Private Sub comint_Click()
    MsgBox Me.comint.Text, vbInformation, "Information"
End Sub

Private Sub Comm_Devis_Click()
    MsgBox Me.Comm_Devis.Text, vbInformation, "Information"
End Sub

Private Sub Détail_Paint()
     'If Me.staint = 4 Then
     '    Me.Détail.BackColor = 16776960
     'Else
     '    Me.Détail.BackColor = 16777215
     'End If

End Sub

Private Sub Form_Delete(Cancel As Integer)
    CurrentDb.Execute "delete from intervention where numintint=" & Me.numintint, dbSeeChanges
End Sub

Private Sub Form_Load()
    Dim calibre As Integer
    calibre = 100
    Me.nomdonneur.ColumnWidth = 12.625 * calibre
    Me.LstIntervenant.ColumnWidth = 14.875 * calibre
    Me.LstZone.ColumnWidth = 11 * calibre
    'Me.numcli.ColumnWidth = 12 * calibre
    Me.nomsit.ColumnWidth = 28 * calibre
    Me.codpossit.ColumnWidth = 5.625 * calibre
    Me.vilsit.ColumnWidth = 19 * calibre
    Me.typint.ColumnWidth = 14 * calibre
    Me.numerodevisaccepte.ColumnWidth = 14 * calibre
    Me.datheulim.ColumnWidth = 11.875 * calibre
    Me.datint.ColumnWidth = 12.625 * calibre
    Me.staint.ColumnWidth = 16 * calibre
    Me.devisafaire.ColumnWidth = 12 * calibre
    Me.devisfait.ColumnWidth = 9.5 * calibre
    Me.devisanepasfaire.ColumnWidth = 12.875 * calibre
    Me.cheficdemint.ColumnWidth = 12.75 * calibre
    Me.controleetancheite.ColumnWidth = 12.12 * calibre
    Me.photofaite.ColumnWidth = 7 * calibre
    Me.auditfait.ColumnWidth = 7 * calibre
    Me.majregsec.ColumnWidth = 11.55 * calibre
    
    
    Me.nomdonneur.TabIndex = 0
    Me.LstIntervenant.TabIndex = 1
    Me.LstZone.TabIndex = 2
    'Me.numcli.ColumnWidth = 12 * calibre
    Me.nomsit.TabIndex = 3
    Me.codpossit.TabIndex = 4
    Me.vilsit.TabIndex = 5
    Me.typint.TabIndex = 6
    Me.numerodevisaccepte.TabIndex = 7
    Me.datheulim.TabIndex = 8
    Me.datint.TabIndex = 9
    Me.staint.TabIndex = 10
    Me.devisafaire.TabIndex = 11
    Me.devisfait.TabIndex = 12
    Me.devisanepasfaire.TabIndex = 13
    Me.cheficdemint.TabIndex = 14
    Me.controleetancheite.TabIndex = 15
    Me.photofaite.TabIndex = 16
    Me.auditfait.TabIndex = 17
    Me.majregsec.TabIndex = 18
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
