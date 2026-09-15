Attribute VB_Name = "Form_ListeInterGaz"
Attribute VB_Base = "0{BDF2B0FB-E7E3-44BD-A81D-F12BA09E4F52}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub cboClient_AfterUpdate()
 'Call Filtrer

End Sub

Private Sub Filtre_OM_Test(AvecExportExcel As Boolean)
Dim Date_Inv As String

'Obligatoire Gaz<>0
sFiltre = "ListeInter.mnthtdevis <>0 "
If cboClient.Value <> 0 Then
    sFiltre = sFiltre + " and ListeSite.[numcli]=" & cboClient
Else
    sFiltre = sFiltre + " and True "
End If

If cboStatut.Value <> 0 Then
        sFiltre = sFiltre & " and ListeInter.[staint]=" & cboStatut
End If

If CboIntervenant.Value <> 0 Then
    sFiltre = sFiltre & " and ListeInter.[codint]='" & CboIntervenant & "'"
End If


If cboTypeIntervention.Value <> 0 Then
    sFiltre = sFiltre & " and ListeInter.[typint]='" & cboTypeIntervention & "'"
End If

If cboTypeGaz.Value <> 0 Then
    sFiltre = sFiltre & " and ListeInter.[nummodres]=" & cboTypeGaz
End If


If Texte17 <> "" And IsDate(Texte17) Then
    '22/06/20 inversion format date
    Date_Inv = Mid(Me.Texte17, 4, 2) + "/" + Left(Me.Texte17, 2) + "/" + Right(Me.Texte17, 4)
    sFiltre = sFiltre & "  and ListeInter.datint >=#" & Date_Inv & "#"
End If

If Texte36 <> "" And IsDate(Texte36) Then
   '22/06/20 inversion format date
   Date_Inv = Mid(Me.Texte36, 4, 2) + "/" + Left(Me.Texte36, 2) + "/" + Right(Me.Texte36, 4)
   sFiltre = sFiltre & "  and ListeInter.datint <=#" & Date_Inv & "#"
End If

Dim numsit As String
numsit = ""
If IsNumeric(Me.CboNumSit) Then
    numsit = Me.CboNumSit
End If
       
If numsit <> "" Then
    sFiltre = sFiltre + " and ListeInter.[numsit]=" & numsit
Else
    If Me.CboNumSit <> 0 Then
        sFiltre = sFiltre + " and ListeInter.[nomsit] like '%" & Me.CboNumSit & "%'"
    End If
End If



Dim SQL As String
    If (AvecExportExcel = False) Then
            ListeInterventionGenerale_sous_formulaire.Form.RecordSource = "SELECT * from ( intervention ListeInter inner join [site] ListeSite ON ListeInter.cptsit=ListeSite.cptsit ) where " + sFiltre + " Order by ListeInter.typint,ListeSite.nomsit"
            ListeInterventionGenerale_sous_formulaire.Form.Filter = sFiltre
            ListeInterventionGenerale_sous_formulaire.Form.FilterOn = False
    Else
        If sFiltre <> "" Then
            ExportExcel (sFiltre)
        End If
        
    End If

Requete2 = "select sum(mnthtdevis)as Som from ( intervention ListeInter inner join [site] ListeSite ON ListeInter.cptsit=ListeSite.cptsit ) where " + sFiltre
Set db = CurrentDb
Set SommeGaz = db.OpenRecordset(Requete2, dbOpenSnapshot)
Dim ChiffreSomme As Double

Me.Somme.Visible = True
If IsNull(SommeGaz!Som) = False Then
    ChiffreSomme = SommeGaz!Som
    Me.Somme.Caption = "Somme=" + Str(ChiffreSomme)
Else
    Me.Somme.Caption = "Rien Trouvé"
End If

If Not SommeGaz Is Nothing Then
    If SommeGaz.RecordCount >= 0 <> 0 Then SommeGaz.Close
    Set SommeGaz = Nothing
End If
    
   
End Sub

Public Sub ExportExcel(Filtre As String)
Dim objXL As Excel.Application
Dim objWkbk As Workbook
Dim objSht As Worksheet
Dim Repertoire As FileDialog
Dim SQL As String
Dim Requete As String
Dim db As Database
Dim Liste As Recordset
Dim DateSaisie As Date
Dim Nb As Double

'Requete = "SELECT  Liste.nomsit,Intervention.datint, Intervention.heudepint, Intervention.datefintech FROM (ListeInterventionGenerale2 Liste inner join Intervention on Liste.numintint=Intervention.numintint)  where " + Filtre + " Order by Liste.typint,Liste.nomsit"
'Requete = "SELECT  Liste.nomsit,Interv.datint, Interv.heudepint, Interv.datefintech FROM (((ListeInterventionGenerale2 AS Liste INNER JOIN Intervention AS Interv ON Liste.numintint = Interv.numintint) INNER JOIN Intervenant ON Interv.codint = Intervenant.codint) INNER JOIN InterventionTechnicien ON Interv.numintint = InterventionTechnicien.numintint) INNER JOIN dbo_SousType ON Interv.imprimeepar = dbo_SousType.id"
Requete = "SELECT  Liste.nomsit,Utilisateur.nomuti +' '+Utilisateur.preuti AS Nom,Intervenant.nomint,Liste.typint,Interv.datint, Interv.heudepint, Interv.datefintech FROM (((ListeInterventionGenerale2 AS Liste INNER JOIN Intervention AS Interv ON Liste.numintint = Interv.numintint) INNER JOIN Intervenant ON Interv.codint = Intervenant.codint) INNER JOIN InterventionTechnicien ON Interv.numintint = InterventionTechnicien.numintint) INNER JOIN Utilisateur ON InterventionTechnicien.numuti = Utilisateur.numuti"
Requete = Requete + " WHERE " + Filtre + " Order by Interv.datint,Liste.typint,Liste.nomsit"
Set db = CurrentDb
Set Liste = db.OpenRecordset(Requete, dbOpenSnapshot)

'Pour Test Fersoft
'strCheminFichier = "c:\Fichier_Extraction_Heures_Inter.xlsx"
strCheminFichier = "\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Extraction_Heures_Inter.xlsx"
'ouvrir Excel
'Si Excel est déjà ouvert sur le PC, GetObject suffit.
On Local Error Resume Next

Ligne = 2
Liste.MoveLast
Max = Liste.RecordCount
Liste.MoveFirst

Rep = MsgBox("Attention,Vous allez Exporter les resultats pour " + Str(Max) + " Interventions ,cela peut etre long ,etes vous sur(e) ?", vbExclamation + vbYesNo, "Confirmation")

If Rep = vbYes Then
    Set Repertoire = Application.FileDialog(msoFileDialogFolderPicker)
    Repertoire.AllowMultiSelect = False
    Repertoire.title = "Merci de Selectionner le repertoire pour le fichier d'export"
    If Repertoire.Show = 0 Then
         Exit Sub
    Else
        dossier_dest = Repertoire.SelectedItems(1)
    End If
    Screen.MousePointer = 11
    Set objXL = GetObject(, "Excel.Application")
    'Par contre, si Excel n'est pas encore lancé sur le PC, alors il faut le faire par ce CreateObject
    'Modif 29/06/23 On enleve le IF  car sur Windows 11 oblxl n'est pas à nothing
    'If Nothing Is objXL Then
        Set objXL = CreateObject("Excel.Application")
    'End If
    'ouvrir le fichier
    Set objWkbk = objXL.Workbooks.Open(strCheminFichier)
    'Onglet 1
    Set objSht = objWkbk.Worksheets(1)
    'Make this sheet the active one when we open the Spreadsheet
    objSht.Activate
    NbExport.Visible = True
    Nb = 0
    
    Do Until Liste.EOF
        NbExport.Caption = Str(Nb) + "/" + Str(Max)
        For i = 0 To 6
            Temp = Liste(i)
            If (IsNull(Temp) = True) Then
                Temp = ""
            Else
                If (i = 3) Then
                    Select Case Temp
                        '0;Toutes;1;Entretien;2;Dépannage;3;Devis accepté;7;Désenfumage;9;Audit;4;Autre;8;Inter. réalisée en attente devis signé client;5;En travaux;6;En création
                        Case 0:
                            Temp = "Toutes"
                        
                        Case 1:
                            Temp = "Entretien"
                        
                        Case 2:
                            Temp = "Dépannage"
                        
                        Case 3:
                            Temp = "Devis accepté"
                            
                        Case 4:
                            Temp = "Autre"
                            
                        Case 5:
                            Temp = "En travaux"
                            
                        Case 6:
                            Temp = "En création"
                        
                        Case 7:
                            Temp = "Désenfumage"
                            
                        Case 8:
                            Temp = "Inter. réalisée en attente devis signé client"
                            
                            
                        Case 9:
                            Temp = "Audit"
                                                   
                    End Select
                End If
                
                'Date Saisie
                If (i = 4) Then
                    'Comme ca la date apparait correctement
                    Temp = "'" + Str(Liste(i))
                End If
                
                'Heure Saisie -->On recupere que l'heure car la date est incorrecte
                If (i = 5) Then
                    DateSaisie = Liste(i)
                    Temp = "'" + Format(Hour(DateSaisie), "00") + ":" + Format(Minute(DateSaisie), "00") + ":" + Format(Second(DateSaisie), "00")
                End If
                'Heure/Date Saisie par le tech (doit etre mis en derniere colonne dans la requete car on scinde en deux)
                'Le mois et la date sont inv
                If (i = 6) Then
                    DateSaisie = Liste(i)
                    Temp = Format(Hour(DateSaisie), "00") + ":" + Format(Minute(DateSaisie), "00") + ":" + Format(Second(DateSaisie), "00")
                    objSht.cells(Ligne, i + 2).Value = Temp
                    Temp = "'" + Format(Day(DateSaisie), "00") + "/" + Format(Month(DateSaisie), "00") + "/" + Format(Year(DateSaisie), "0000")
                End If
            End If
            
            With objSht
                .cells(Ligne, i + 1).Value = Temp
            End With
            DoEvents
        Next i
        Nb = Nb + 1
        Ligne = Ligne + 1
        Liste.MoveNext
    Loop
    If Not Liste Is Nothing Then
        If Liste.RecordCount >= 0 <> 0 Then Liste.Close
        Set Liste = Nothing
    End If
    objWkbk.SaveAs (dossier_dest + "\SaisieHeuresInter.xlsx")
    'Fermer le fichier et le sauver
    objWkbk.Close True
    NbExport.Visible = False
    'libérer les pointeurs
    Set objWkbk = Nothing
    Set objXL = Nothing
End If
Screen.MousePointer = 0
End Sub


Private Sub Filtrer()

Dim bClient As Boolean
Dim bTypeIntervention As Boolean
Dim bNumSit As Boolean
Dim sFiltre As String
Dim bStatut As Boolean
Dim bDonneur As Boolean
Dim bIntervenant As Boolean
Dim bZone As Boolean
Dim bAudit As Boolean
Dim bPhoto As Boolean
Dim bMaJRegSec As Boolean
Dim bControleEtancheite As Boolean

sFiltre = ""

'OK
If cboClient.Value <> 0 Then
    bClient = True
    If sFiltre <> "" Then
          sFiltre = sFiltre & " AND "
      End If
    sFiltre = "[numcli]=" & cboClient
End If

'OK
If cboTypeIntervention.Value <> 0 Then
    If bClient Or bNumSit Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "[typint]='" & cboTypeIntervention & "'"
    bTypeIntervention = True
End If

'OK
If cboStatut.Value <> 0 Then
    If bClient Or bTypeIntervention Or bNumSit Then
        sFiltre = sFiltre & " AND "
    End If
    If Me.ChkShowArchived = True Then
        sFiltre = sFiltre & "[staint] in (" & cboStatut & ",7)"
    Else
        sFiltre = sFiltre & "[staint]=" & cboStatut
    End If
    bStatut = True
End If
    
If Texte17 <> "" And IsDate(Texte17) And Texte36 <> "" And IsDate(Texte36) Then
    If bClient Or bTypeIntervention Or bNumSit Or bStatut Then
        sFiltre = sFiltre & " AND "
    End If
        sFiltre = sFiltre & " datheulim >= #" & Me.Texte17 & "# AND datheulim <= #" & Me.Texte36 & "#"
    bTrimestre = True
End If

'OK
If CboDonneur.Value <> 0 Then
    If bClient Or bTypeIntervention Or bNumSit Or bTrimestre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "[donneurid]=" & CboDonneur
    bDonneur = True
End If

'OK
If CboIntervenant.Value <> 0 Then
    If bClient Or bTypeIntervention Or bNumSit Or bTrimestre Or bDonneur Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "[codint]='" & CboIntervenant & "'"
    bIntervenant = True
End If
'****************************************************************
'OK
If CboZone.Value <> 0 Then
    If bClient Or bTypeIntervention Or bNumSit Or bTrimestre Or bDonneur Or bIntervenant Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "[numzonsit]=" & CboZone
    bZone = True
End If


'**********************************************************************
If ChkAudit.Value = True Then
    If bZone Or bClient Or bTypeIntervention Or bNumSit Or bTrimestre Or bDonneur Or bIntervenant Then
        sFiltre = sFiltre & " AND "
    End If
    If ChkAudit.Value = True Then
        sFiltre = sFiltre & "[auditfait]=true"
    Else
        sFiltre = sFiltre & "[auditfait]=false"
    End If
    bAudit = True
End If

If ChkControleEtancheite.Value = True Then
    If bAudit Or bZone Or bClient Or bTypeIntervention Or bNumSit Or bTrimestre Or bDonneur Or bIntervenant Then
        sFiltre = sFiltre & " AND "
    End If
    If ChkControleEtancheite.Value = True Then
        sFiltre = sFiltre & "[controleetancheite]=true"
    Else
        sFiltre = sFiltre & "[controleetancheite]=false"
    End If
    bControleEtancheite = True
End If

If ChkPhoto.Value = True Then
    If bControleEtancheite Or bAudit Or bZone Or bClient Or bTypeIntervention Or bNumSit Or bTrimestre Or bDonneur Or bIntervenant Then
        sFiltre = sFiltre & " AND "
    End If
    If ChkPhoto.Value = True Then
        sFiltre = sFiltre & "[photofaite]=true"
    Else
        sFiltre = sFiltre & "[photofaite]=false"
    End If
    bPhoto = True
End If

If ChkMajRegSec.Value = True Then
    If bPhoto Or bControleEtancheite Or bAudit Or bZone Or bClient Or bTypeIntervention Or bNumSit Or bTrimestre Or bDonneur Or bIntervenant Then
        sFiltre = sFiltre & " AND "
    End If
    If ChkMajRegSec.Value = True Then
        sFiltre = sFiltre & "[majregsec]=true"
    Else
        sFiltre = sFiltre & "[majregsec]=false"
    End If
End If
'***************** code alain
If ChkShowArchived.Value = False Then
    If sFiltre <> "" Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "[staint]<> 7"
    'If ChkShowArchived.Value = False Then
    '    sFiltre = sFiltre & "[staint]<> 7"
   ' Else
    '    sFiltre = sFiltre & "[staint]=false"
    'End If
 End If


Dim numsit As String
numsit = ""
If IsNumeric(Me.CboNumSit) Then
    numsit = Me.CboNumSit.Text
End If
       
If numsit <> "" Then
    If sFiltre <> "" Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre + "numsit=" & numsit
Else
    If sFiltre <> "" Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre + " nomsit like '%" & Me.CboNumSit & "%'"
End If
If cboClient <> "" Then
    If sFiltre <> "" Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre + " numcli=" & cboClient
End If
        
'OK
'****** liste zone ********************
If Me.LstZone.ItemsSelected.Count <> 0 Then
    Dim VsFiltre As String

    If sFiltre <> "" Then
          sFiltre = sFiltre & " AND "
      End If
    VsFiltre = sFiltre
    Dim varI As Variant
    Dim VarJ As Long
    Dim Varp As Long
    Varp = 1
    VarJ = 1
    For Each varI In Me!LstZone.ItemsSelected
        If Varp = 1 Then
            sFiltre = VsFiltre & "[numzonsit]=" & Me!LstZone.ItemData(varI)
        Else
            sFiltre = sFiltre & VsFiltre & "[numzonsit]=" & Me!LstZone.ItemData(varI)
        End If
        Varp = Varp + 1
        If VarJ < Me.LstZone.ItemsSelected.Count Then
            sFiltre = sFiltre & " or "
            VarJ = VarJ + 1
        End If
    Next varI
End If
'***************************************




'***************** code alain fin
ListeInterventionGenerale_sous_formulaire.Form.Filter = sFiltre
ListeInterventionGenerale_sous_formulaire.Form.FilterOn = True

End Sub

Private Sub CboDonneur_AfterUpdate()
    'Call Filtrer
End Sub

Private Sub CboIntervenant_AfterUpdate()
  '  Call Filtrer
End Sub

Private Sub CboNumSit_AfterUpdate()
  ' Call Filtrer
End Sub

Private Sub CboNumSit_KeyDown(KeyCode As Integer, Shift As Integer)
    If KeyCode = vbKeyReturn Then
        Dim numsit As String
        numsit = ""
        If IsNumeric(Me.CboNumSit.Text) Then
            numsit = Me.CboNumSit.Text
        End If
               
        If numsit <> "" Then
            sFiltre = sFiltre + "numsit=" & numsit
        Else
            sFiltre = sFiltre + " nomsit like '%" & Me.CboNumSit.Text & "%'"
        End If
        If cboClient <> "" Then
            sFiltre = sFiltre + " AND numcli=" & cboClient
        End If
        
        'Forms![ListeInterventionGenerale].[ListeInterventionGenerale sous-formulaire].SourceObject = "ListeInterventionGenerale sous-formulaire"
        ListeInterventionGenerale_sous_formulaire.Form.Filter = sFiltre
        ListeInterventionGenerale_sous_formulaire.Form.FilterOn = True

        
    End If
End Sub

Private Sub cboStatut_AfterUpdate()
 'Call Filtrer
End Sub

Private Sub cboTrimestre_AfterUpdate()
 'Call Filtrer
End Sub

Private Sub cboTypeIntervention_AfterUpdate()
 'Call Filtrer
  Select Case cboTypeIntervention
        Case 1
            Me.Détail.BackColor = RGB(209, 234, 240)
        Case 2
            Me.Détail.BackColor = RGB(204, 255, 204)
         Case 3
            Me.Détail.BackColor = RGB(255, 204, 204)
            
        Case Else
            Me.Détail.BackColor = RGB(128, 128, 128)
        
    End Select
     
End Sub

Private Sub CboZone_AfterUpdate()
 'Call Filtrer
End Sub

Private Sub ChkAudit_AfterUpdate()
 '   Call Filtrer
End Sub

Private Sub ChkControleEtancheite_AfterUpdate()
  '  Call Filtrer
End Sub

Private Sub ChkMajRegSec_AfterUpdate()
   ' Call Filtrer
End Sub

Private Sub ChkModificationAutorisée_Click()
'Bouton Invisible donc inutilisé
  If Forms![ListeInterventionGenerale].[ListeInterventionGenerale sous-formulaire].Form.RecordSource = "ListeInterventionGenerale2" Then
        Forms![ListeInterventionGenerale].[ListeInterventionGenerale sous-formulaire].Form.RecordSource = "ListeInterventionGenerale"
        Call Filtrer
    Else
        Forms![ListeInterventionGenerale].[ListeInterventionGenerale sous-formulaire].Form.RecordSource = "ListeInterventionGenerale2"
        Call Filtrer
    End If
End Sub

Private Sub ChkPhoto_AfterUpdate()
'Call Filtrer
End Sub

Private Sub ChkShowArchived_AfterUpdate()
' Call Filtrer
End Sub

Private Sub CmdExporter_Click()

  Dim db As dao.Database
  
  Set db = CurrentDb()
  Dim SQL As String
  SQL = db.QueryDefs("EXPORT-MODELE").SQL
  
  If ListeInterventionGenerale_sous_formulaire.Form.Filter <> "" Then
    SQL = Left(SQL, Len(SQL) - 3) & " WHERE " & ListeInterventionGenerale_sous_formulaire.Form.Filter
  End If
  'If ListeInterventionGenerale_sous_formulaire.Form.OrderBy <> "" Then
  '  Sql = Sql & " ORDER BY " & ListeInterventionGenerale_sous_formulaire.Form.OrderBy
  'End If
  db.QueryDefs("EXPORT").SQL = SQL
  DoCmd.OutputTo acOutputQuery, "EXPORT", acFormatXLSX, CurrentProject.Path & "\Export.xlsx", False
   ' Or use DoCmd.TransferSpreadsheet acExport, acSpreadsheetTypeExcel12Xml, qdf.Name, "C:\test\" & qdf.Name, True
  
  Set db = Nothing
  txtFichierExporte.HyperlinkAddress = CurrentProject.Path & "\Export.xlsx"
  txtFichierExporte.Visible = True
  
End Sub

Private Sub CmdNouvelleIntervention_Click()
On Error GoTo Err_CmdNouvelleIntervention_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Intervention"
    DoCmd.OpenForm stDocName, acNormal, , stLinkCriteria, acFormAdd

Exit_CmdNouvelleIntervention_Click:
    Exit Sub

Err_CmdNouvelleIntervention_Click:
    MsgBox err.Description
    Resume Exit_CmdNouvelleIntervention_Click
    
End Sub

Private Sub CmdRechercher_Click()
    'Call Filtrer
    Call Filtre_OM_Test(False)
End Sub

Private Sub Commande60_Click()
    Call Filtre_OM_Test(True)
End Sub

Private Sub Form_Current()
 'Dim d As Date
    
 'Dim q As Integer
 'd = Now()
 'q = (Month(d) \ 3) + 1
 
 'Me.cboTrimestre = q
 'Forms![ListeInterventionGenerale].[ListeInterventionGenerale sous-formulaire].Form.Requery
      
     Select Case cboTypeIntervention
        Case 1
            Me.Détail.BackColor = RGB(209, 234, 240)
        Case 2
            Me.Détail.BackColor = RGB(204, 255, 204)
        Case 3
            Me.Détail.BackColor = RGB(255, 204, 204)
        Case Else
            Me.Détail.BackColor = RGB(128, 128, 128)
        
    End Select
End Sub

Private Sub Form_Load()
    
DoCmd.Maximize
Me.Form.Width = Me.WindowWidth
For Each sf In Me.Controls
If TypeOf sf Is SubForm Then
sf.Width = Me.WindowWidth - 567
sf.Height = Me.WindowHeight - 567 * 5.7

End If
Next
CboNumSit.SetFocus


End Sub


Private Sub CmdFermer_Click()
On Error GoTo Err_CmdFermer_Click


    DoCmd.Close

Exit_CmdFermer_Click:
    Exit Sub

Err_CmdFermer_Click:
    MsgBox err.Description
    Resume Exit_CmdFermer_Click
    
End Sub
Private Sub Commande16_Click()
On Error GoTo Err_Commande16_Click


    DoCmd.RunCommand acCmdRefresh

Exit_Commande16_Click:
    Exit Sub

Err_Commande16_Click:
    MsgBox err.Description
    Resume Exit_Commande16_Click
    
End Sub

Private Sub Form_Resize()
    Me.ListeInterventionGenerale_sous_formulaire.Width = Me.Width
End Sub


Private Sub LstZone_AfterUpdate()
 '   Call Filtrer
End Sub

Private Sub Texte17_AfterUpdate()
  '  Call Filtrer
End Sub
Private Sub CmdImprimerListeInterventions_Click()
'22/06/20 Nouveau Formulaire OM
On Error GoTo Err_CmdImprimerListeInterventions_Click

    Dim stDocName As String
    stDocName = "ListeInterventionOM"
    Dim args As String
    If (Me.cboTypeIntervention = 0) Then
        args = "Liste de toutes les interventions à réaliser"
    Else
        '"0;Toutes;1;Entretien;2;Dépannage;3;Devis accepté;7;Désenfumage;9;Audit;4;Autre;8;Inter. réalisée en attente devis signé client;5;En travaux;6;En création"
        Select Case (Me.cboTypeIntervention)
            Case 1:
                    args = "Liste des interventions d'entretien à réaliser"
            Case 2:
                    args = "Liste des interventions de Dépannage à réaliser"
            Case 3:
                    args = "Liste des Devis acceptés"
            Case 7:
                    args = "Liste des interventions de Désenfumage à réaliser"
            Case 9:
                    args = "Liste des audits à réaliser"
            Case 4:
                    args = "Liste des interventions:Autres à réaliser"
            Case 8:
                    args = "Liste des Inter. réalisées en attente devis signé client "
            Case 5:
                    args = "Liste des Intervention en travaux"
            Case 6:
                    args = "Liste des Intervention en creation"
            Case 6:
                    args = "Liste des Intervention Type: " + Str(Me.cboTypeIntervention)
        
        End Select
         
    End If
    args = args + ";"
    
    If (Me.CboIntervenant <> "") Then
        args = args + Me.CboIntervenant
    End If
    If Me.Texte17 <> "" And Me.Texte36 <> "" Then
        args = args + " du " + Str(Me.Texte17) + " au " + Str(Me.Texte36)
    End If
    If ((Me.Texte17 = "") Or IsNull(Me.Texte17)) And Me.Texte36 <> "" Then
        args = args + " Jusqu au " + Str(Me.Texte36)
    End If
    
    DoCmd.OpenReport stDocName, acViewPreview, , ListeInterventionGenerale_sous_formulaire.Form.Filter, , args
   

Exit_CmdImprimerListeInterventions_Click:
    Exit Sub

Err_CmdImprimerListeInterventions_Click:
    MsgBox err.Description
    Resume Exit_CmdImprimerListeInterventions_Click
    
End Sub

Private Sub Texte36_AfterUpdate()
   ' Call Filtrer
End Sub
Private Sub Commande40_Click()
Dim varI As Variant
 
  If Me.LstZone.ItemsSelected.Count = 0 Then
    MsgBox "Aucun client n'a été sélectionné"
  Else
    For Each varI In Me!LstZone.ItemsSelected
      MsgBox Me!LstZone.ItemData(varI)
    Next varI
  End If


End Sub
Private Sub Commande41_Click()

'DoCmd.OpenReport stDocName, acViewPreview, , ListeInterventionGenerale_sous_formulaire.Form.Filter

End Sub
Private Sub CmdModifier_Click()
On Error GoTo Err_CmdModifier_Click

  
    

Exit_CmdModifier_Click:
    Exit Sub

Err_CmdModifier_Click:
    MsgBox err.Description
    Resume Exit_CmdModifier_Click
    
End Sub
