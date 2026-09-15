Attribute VB_Name = "Report_ListeInterventionOM"
Attribute VB_Base = "0{91721FD9-7C41-4E66-936B-3002394CB1BA}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Détail_Format(Cancel As Integer, FormatCount As Integer)
    
'22/06/20 Ne sert plus  OM
   
' si le client veux que cette règle ne s'applique que sur l'état avec TYPE INTERNENTION = Toutes : retiré  commentaire à If Forms!listeInterventionGenerale!cboTypeIntervention = 0 Then et Endif  !
    
    'If Forms!listeInterventionGenerale!cboTypeIntervention = 0 Then
        
     '   If typint = 2 Or typint = 3 Then
     '       If typint = 2 Then    'Vert = "RGB(50, 150, 10)"
     '           Me.typint.ForeColor = RGB(50, 150, 10)
     '           Me.datheulim.ForeColor = RGB(50, 150, 10)
     '           Me.nbrentsit.ForeColor = RGB(50, 150, 10)
     '           Me.datedernierevisiteentretien.ForeColor = RGB(50, 150, 10)
     '           Me.numzonsit.ForeColor = RGB(50, 150, 10)
     '           Me.nomcli.ForeColor = RGB(50, 150, 10)
     '           Me.nomsit.ForeColor = RGB(50, 150, 10)
     '           Me.vilsit.ForeColor = RGB(50, 150, 10)
     '           Me.txtadrsit.ForeColor = RGB(50, 150, 10)
     '           Me.comsit.ForeColor = RGB(50, 150, 10)
     '           Me.nomdonneur.ForeColor = RGB(50, 150, 10)
     '           Me.codint.ForeColor = RGB(50, 150, 10)
     '           Me.telsit.ForeColor = RGB(50, 150, 10)
     '           Me.staint.ForeColor = RGB(50, 150, 10)
     '           Me.numsit.ForeColor = RGB(50, 150, 10)
     '           Me.comint.ForeColor = RGB(50, 150, 10)
     '           Me.DevisEnCours.ForeColor = RGB(50, 150, 10)
     '          Me.Cocher57.BorderColor = RGB(50, 150, 10)
     '           Me.Cocher60.BorderColor = RGB(50, 150, 10)
     '           Me.Cocher62.BorderColor = RGB(50, 150, 10)
     '           Me.Cocher64.BorderColor = RGB(50, 150, 10)
     '           Me.NumeroDevis.ForeColor = RGB(50, 150, 10)
     '       End If
     '       If typint = 3 Then   'rouge = "RGB(200, 0, 0)"
     '           Me.typint.ForeColor = RGB(200, 0, 0)
     '           Me.datheulim.ForeColor = RGB(200, 0, 0)
     '           Me.nbrentsit.ForeColor = RGB(200, 0, 0)
     '           Me.datedernierevisiteentretien.ForeColor = RGB(200, 0, 0)
     '           Me.numzonsit.ForeColor = RGB(200, 0, 0)
     '           Me.nomcli.ForeColor = RGB(200, 0, 0)
     '           Me.nomsit.ForeColor = RGB(200, 0, 0)
     '           Me.vilsit.ForeColor = RGB(200, 0, 0)
     '           Me.txtadrsit.ForeColor = RGB(200, 0, 0)
     '           Me.comsit.ForeColor = RGB(200, 0, 0)
     '           Me.nomdonneur.ForeColor = RGB(200, 0, 0)
     '           Me.codint.ForeColor = RGB(200, 0, 0)
     '           Me.telsit.ForeColor = RGB(200, 0, 0)
     '           Me.staint.ForeColor = RGB(200, 0, 0)
     '           Me.numsit.ForeColor = RGB(200, 0, 0)
     '           Me.comint.ForeColor = RGB(200, 0, 0)
     '           Me.DevisEnCours.ForeColor = RGB(200, 0, 0)
     '           Me.Cocher57.BorderColor = RGB(200, 0, 0)
     '           Me.Cocher60.BorderColor = RGB(200, 0, 0)
     '           Me.Cocher62.BorderColor = RGB(200, 0, 0)
     '           Me.Cocher64.BorderColor = RGB(200, 0, 0)
     '           Me.NumeroDevis.ForeColor = RGB(200, 0, 0)
     '       End If
                
     '   Else  'Noire = "RGB(0, 0, 0)"
     '       Me.typint.ForeColor = RGB(0, 0, 0)
     '       Me.datheulim.ForeColor = RGB(0, 0, 0)
     '       Me.nbrentsit.ForeColor = RGB(0, 0, 0)
     '       Me.datedernierevisiteentretien.ForeColor = RGB(0, 0, 0)
     '       Me.numzonsit.ForeColor = RGB(0, 0, 0)
     '       Me.nomcli.ForeColor = RGB(0, 0, 0)
     '       Me.nomsit.ForeColor = RGB(0, 0, 0)
     '       Me.vilsit.ForeColor = RGB(0, 0, 0)
     '       Me.txtadrsit.ForeColor = RGB(0, 0, 0)
     '       Me.comsit.ForeColor = RGB(0, 0, 0)
     '       Me.nomdonneur.ForeColor = RGB(0, 0, 0)
     '       Me.codint.ForeColor = RGB(0, 0, 0)
     '       Me.telsit.ForeColor = RGB(0, 0, 0)
     '       Me.staint.ForeColor = RGB(0, 0, 0)
     '       Me.numsit.ForeColor = RGB(0, 0, 0)
     '       Me.comint.ForeColor = RGB(0, 0, 0)
     '       Me.DevisEnCours.ForeColor = RGB(0, 0, 0)
     '       Me.Cocher57.BorderColor = RGB(0, 0, 0)
     '       Me.Cocher60.BorderColor = RGB(0, 0, 0)
     '       Me.Cocher62.BorderColor = RGB(0, 0, 0)
     '       Me.Cocher64.BorderColor = RGB(0, 0, 0)
     '       Me.NumeroDevis.ForeColor = RGB(0, 0, 0)
     '   End If
    
    'End If


End Sub

Private Sub Report_Load()

    'On Error Resume Next
    Dim SQL As String
    Dim args As String
    Dim Pos
    Dim Ligne_1 As String
    Dim Ligne_2 As String
    
    'SQL = "UPDATE Site set datedernierevisiteentretien = (select MAX(datint) from Intervention where typint=1 and staint=7 and Intervention.cptsit = Site.cptsit)"
 
    'DoCmd.RunSQL SQL
    
    If Me.OpenArgs <> "" Then
        '22/06/20 Modif OM
        '
        'Args = Me.OpenArgs
        'Args = Replace(Args, "[ListeInterventionGenerale sous-formulaire].", "")
        'Args = Replace(Args, "[Lookup_LstZone].", "")
        'Args = Replace(Args, "[Lookup_LstDonneur].", "")
        'Args = Replace(Args, "", "")
        'Args = Replace(Args, "", "")
        
        'Me.Report.OrderBy = Args
        ' Me.OpenArgs
        'Me.Report.OrderByOn = True
        'On cherche la position du ;
        Pos = InStr(1, Me.OpenArgs, ";", vbTextCompare)
        Ligne_1 = Left(Me.OpenArgs, Pos - 1)
        Ligne_2 = Right(Me.OpenArgs, Len(Me.OpenArgs) - Pos)
        Me.Étiquette42.Caption = Ligne_1
        Me.Étiquette313.Caption = Ligne_2
        Me.Étiquette313.Visible = True
    Else
        Me.Étiquette313.Visible = False
    End If
    
    
End Sub

