Attribute VB_Name = "Report_ListeInterventionGenerale sans quadrillage"
Attribute VB_Base = "0{D5EC7959-E79A-4AFE-9B32-8813F964C47E}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Détail_Format(Cancel As Integer, FormatCount As Integer)
    
    
   
' si le client veux que cette règle ne s'applique que sur l'état avec TYPE INTERNENTION = Toutes : retiré  commentaire à If Forms!listeInterventionGenerale!cboTypeIntervention = 0 Then et Endif  !
    
    'If Forms!listeInterventionGenerale!cboTypeIntervention = 0 Then
        
        If typint = 2 Or typint = 3 Then
            If typint = 2 Then    'Vert = "RGB(50, 150, 10)"
                Me.typint.ForeColor = RGB(50, 150, 10)
                Me.datheulim.ForeColor = RGB(50, 150, 10)
                Me.nbrentsit.ForeColor = RGB(50, 150, 10)
                Me.datedernierevisiteentretien.ForeColor = RGB(50, 150, 10)
                Me.numzonsit.ForeColor = RGB(50, 150, 10)
                Me.nomcli.ForeColor = RGB(50, 150, 10)
                Me.nomsit.ForeColor = RGB(50, 150, 10)
                Me.vilsit.ForeColor = RGB(50, 150, 10)
                Me.txtadrsit.ForeColor = RGB(50, 150, 10)
                Me.comsit.ForeColor = RGB(50, 150, 10)
                Me.nomdonneur.ForeColor = RGB(50, 150, 10)
                Me.codint.ForeColor = RGB(50, 150, 10)
                Me.telsit.ForeColor = RGB(50, 150, 10)
                Me.staint.ForeColor = RGB(50, 150, 10)
                Me.numsit.ForeColor = RGB(50, 150, 10)
                Me.comint.ForeColor = RGB(50, 150, 10)
                Me.DevisEnCours.ForeColor = RGB(50, 150, 10)
                Me.Cocher57.BorderColor = RGB(50, 150, 10)
                Me.Cocher60.BorderColor = RGB(50, 150, 10)
                Me.Cocher62.BorderColor = RGB(50, 150, 10)
                Me.Cocher64.BorderColor = RGB(50, 150, 10)
                Me.NumeroDevis.ForeColor = RGB(50, 150, 10)
            End If
            If typint = 3 Then   'rouge = "RGB(200, 0, 0)"
                Me.typint.ForeColor = RGB(200, 0, 0)
                Me.datheulim.ForeColor = RGB(200, 0, 0)
                Me.nbrentsit.ForeColor = RGB(200, 0, 0)
                Me.datedernierevisiteentretien.ForeColor = RGB(200, 0, 0)
                Me.numzonsit.ForeColor = RGB(200, 0, 0)
                Me.nomcli.ForeColor = RGB(200, 0, 0)
                Me.nomsit.ForeColor = RGB(200, 0, 0)
                Me.vilsit.ForeColor = RGB(200, 0, 0)
                Me.txtadrsit.ForeColor = RGB(200, 0, 0)
                Me.comsit.ForeColor = RGB(200, 0, 0)
                Me.nomdonneur.ForeColor = RGB(200, 0, 0)
                Me.codint.ForeColor = RGB(200, 0, 0)
                Me.telsit.ForeColor = RGB(200, 0, 0)
                Me.staint.ForeColor = RGB(200, 0, 0)
                Me.numsit.ForeColor = RGB(200, 0, 0)
                Me.comint.ForeColor = RGB(200, 0, 0)
                Me.DevisEnCours.ForeColor = RGB(200, 0, 0)
                Me.Cocher57.BorderColor = RGB(200, 0, 0)
                Me.Cocher60.BorderColor = RGB(200, 0, 0)
                Me.Cocher62.BorderColor = RGB(200, 0, 0)
                Me.Cocher64.BorderColor = RGB(200, 0, 0)
                Me.NumeroDevis.ForeColor = RGB(200, 0, 0)
            End If
                
        Else  'Noire = "RGB(0, 0, 0)"
            Me.typint.ForeColor = RGB(0, 0, 0)
            Me.datheulim.ForeColor = RGB(0, 0, 0)
            Me.nbrentsit.ForeColor = RGB(0, 0, 0)
            Me.datedernierevisiteentretien.ForeColor = RGB(0, 0, 0)
            Me.numzonsit.ForeColor = RGB(0, 0, 0)
            Me.nomcli.ForeColor = RGB(0, 0, 0)
            Me.nomsit.ForeColor = RGB(0, 0, 0)
            Me.vilsit.ForeColor = RGB(0, 0, 0)
            Me.txtadrsit.ForeColor = RGB(0, 0, 0)
            Me.comsit.ForeColor = RGB(0, 0, 0)
            Me.nomdonneur.ForeColor = RGB(0, 0, 0)
            Me.codint.ForeColor = RGB(0, 0, 0)
            Me.telsit.ForeColor = RGB(0, 0, 0)
            Me.staint.ForeColor = RGB(0, 0, 0)
            Me.numsit.ForeColor = RGB(0, 0, 0)
            Me.comint.ForeColor = RGB(0, 0, 0)
            Me.DevisEnCours.ForeColor = RGB(0, 0, 0)
            Me.Cocher57.BorderColor = RGB(0, 0, 0)
            Me.Cocher60.BorderColor = RGB(0, 0, 0)
            Me.Cocher62.BorderColor = RGB(0, 0, 0)
            Me.Cocher64.BorderColor = RGB(0, 0, 0)
            Me.NumeroDevis.ForeColor = RGB(0, 0, 0)
        End If
    
    'End If


End Sub

Private Sub Report_Load()

    'On Error Resume Next
    Dim SQL As String
    Dim args As String
    
    SQL = "UPDATE Site set datedernierevisiteentretien = (select MAX(datint) from Intervention where typint=1 and staint=7 and Intervention.cptsit = Site.cptsit)"
 
    'DoCmd.RunSQL SQL
    
    If Me.OpenArgs <> "" Then
        args = Me.OpenArgs
        args = Replace(args, "[ListeInterventionGenerale sous-formulaire].", "")
        args = Replace(args, "[Lookup_LstZone].", "")
        args = Replace(args, "[Lookup_LstDonneur].", "")
        args = Replace(args, "", "")
        args = Replace(args, "", "")
        
        Me.Report.OrderBy = args
' Me.OpenArgs
        Me.Report.OrderByOn = True
    End If

End Sub

