Attribute VB_Name = "Form_ListeInterventionGenerale"
Attribute VB_Base = "0{F34B1BC0-6EB0-4D8C-8A7E-D97E1F5945FE}"
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
Private Sub Filtre_OM()
Dim Date_Inv As String
sFiltre = ""
If cboClient.Value <> 0 Then
    sFiltre = "[numcli]=" & cboClient
Else
    sFiltre = " True "
End If

If cboStatut.Value <> 0 Then
    If Me.ChkShowArchived = True Then
        sFiltre = sFiltre & " and [staint] in (" & cboStatut & ",7)"
    Else
        sFiltre = sFiltre & " and [staint]=" & cboStatut
    End If
End If

If CboIntervenant.Value <> 0 Then
    sFiltre = sFiltre & " and [codint]='" & CboIntervenant & "'"
End If

If CboDonneur.Value <> 0 Then
    sFiltre = sFiltre & "and [donneurid]=" & CboDonneur
End If

'****** liste zone ********************
If Me.LstZone.ItemsSelected.Count <> 0 Then
    Dim varI As Variant
    Nb_Occur = 1
    For Each varI In Me!LstZone.ItemsSelected
            If Nb_Occur = 1 Then
                sFiltre = sFiltre & " and ([numzonsit]=" & Me!LstZone.ItemData(varI)
            Else
                sFiltre = sFiltre & " or [numzonsit]=" & Me!LstZone.ItemData(varI)
            End If
            Nb_Occur = Nb_Occur + 1
    Next varI
    sFiltre = sFiltre + ")"
End If

If cboTypeIntervention.Value <> 0 Then
    sFiltre = sFiltre & " and [typint]='" & cboTypeIntervention & "'"
End If

If CboZone.Value <> 0 Then
    sFiltre = sFiltre & " and [numzonsit]=" & CboZone
End If

If ChkAudit.Value = True Then
    sFiltre = sFiltre & " and [auditfait]=true"
End If

If ChkControleEtancheite.Value = True Then
   sFiltre = sFiltre & " and [controleetancheite]=true"
End If

If ChkPhoto.Value = True Then
    sFiltre = sFiltre & " and [photofaite]=true"
End If

If ChkMajRegSec.Value = True Then
    sFiltre = sFiltre & " and [majregsec]=true"
End If

If Texte17 <> "" And IsDate(Texte17) Then
    '22/06/20 inversion format date
    Date_Inv = Mid(Me.Texte17, 4, 2) + "/" + Left(Me.Texte17, 2) + "/" + Right(Me.Texte17, 4)
    sFiltre = sFiltre & "  and datheulim >=#" & Date_Inv & "#"
End If

If Texte36 <> "" And IsDate(Texte36) Then
   '22/06/20 inversion format date
   Date_Inv = Mid(Me.Texte36, 4, 2) + "/" + Left(Me.Texte36, 2) + "/" + Right(Me.Texte36, 4)
   sFiltre = sFiltre & "  and datheulim <=#" & Date_Inv & "#"
End If

Dim numsit As String
numsit = ""
If IsNumeric(Me.CboNumSit) Then
    numsit = Me.CboNumSit
End If
       
If numsit <> "" Then
    sFiltre = sFiltre + " and [numsit]=" & numsit
Else
    If Me.CboNumSit <> 0 Then
        sFiltre = sFiltre + " and [nomsit] like '%" & Me.CboNumSit & "%'"
    End If
End If

Dim SQL As String

    ListeInterventionGenerale_sous_formulaire.Form.RecordSource = "SELECT * FROM ListeInterventionGenerale2 "
    If sFiltre <> "" Then
        ListeInterventionGenerale_sous_formulaire.Form.RecordSource = ListeInterventionGenerale_sous_formulaire.Form.RecordSource + " where " & sFiltre & " Order by typint,nomsit"
        ListeInterventionGenerale_sous_formulaire.Form.Filter = sFiltre
        ListeInterventionGenerale_sous_formulaire.Form.FilterOn = False
    End If
    ListeInterventionGenerale_sous_formulaire.Requery
    
   
End Sub



Private Sub Filtre_OM_Test(AvecExportExcel As Boolean)
'27/11/25 Ajout Update banane OM
'27/11/25 Gestion date reele .. ou pas
'         Ajout gestion des inter proches

UpdateFichierBanane 1

Dim Date_Inv As String
sFiltre = ""
If cboClient.Value <> 0 Then
    sFiltre = "Liste.[numcli]=" & cboClient
Else
    sFiltre = " True "
End If

If (CheckEntretienProche = True) Then
    Dim Tab_Result(20) As Integer
    RequeteMaint = "Select * from dbo_VisitesMaint"
    Set dbmaint = CurrentDb
    Set result = dbmaint.OpenRecordset(RequeteMaint, dbOpenSnapshot)
    
    Do Until result.EOF
        NbVisites = result!Nombre_Visites
        Ecart = result!Ecart_Permis_Jour
        Tab_Result(NbVisites) = Ecart
        result.MoveNext
    Loop
    result.Close
    Set result = Nothing
    
    
    sFiltre = sFiltre & "and Liste.[typint]='1' and datedernierevisiteentretien is not null and Liste.[staint]=1"
    Premier = False
    Aujourdhui = Format(Now, "mm/dd/yyyy")
    For i = 1 To 20
        If (Tab_Result(i) <> 0) Then
            If (Premier = False) Then
                'sFiltre = sFiltre & " and ( ( nbrentsit=" + Str(i) + " And dateadd(""d""," + Str(Tab_Result(i)) + ", datedernierevisiteentretien) >#" + Aujourdhui + "#)"
                sFiltre = sFiltre & " and ( ( nbrentsit=" + Str(i) + " And dateadd(""d""," + Str(Tab_Result(i)) + ", datedernierevisiteentretien) >Liste.[datheulim])"
                Premier = True
            Else
                'sFiltre = sFiltre & " or ( nbrentsit=" + Str(i) + " And dateadd(""d""," + Str(Tab_Result(i)) + ", datedernierevisiteentretien) >#" + Aujourdhui + "#)"
                sFiltre = sFiltre & " or ( nbrentsit=" + Str(i) + " And dateadd(""d""," + Str(Tab_Result(i)) + ", datedernierevisiteentretien) >Liste.[datheulim])"
            End If
        End If
    Next i
    
    sFiltre = sFiltre & ")"
    cboTypeIntervention.Value = 1
    cboStatut.Value = 1
Else
    If cboTypeIntervention.Value <> 0 Then
        sFiltre = sFiltre & " and Liste.[typint]='" & cboTypeIntervention & "'"
    End If
    If cboStatut.Value <> 0 Then
    If Me.ChkShowArchived = True Then
        sFiltre = sFiltre & " and Liste.[staint] in (" & cboStatut & ",7)"
    Else
        sFiltre = sFiltre & " and Liste.[staint]=" & cboStatut
    End If
End If
End If



If CboIntervenant.Value <> 0 Then
    sFiltre = sFiltre & " and Liste.[codint]='" & CboIntervenant & "'"
End If

If CboDonneur.Value <> 0 Then
    sFiltre = sFiltre & "and Liste.[donneurid]=" & CboDonneur
End If

If Me.StatutFact.Value <> 0 Then
    sFiltre = sFiltre & "and Liste.[nbrappint]=" & StatutFact
End If

'****** liste zone ********************
If Me.LstZone.ItemsSelected.Count <> 0 Then
    Dim varI As Variant
    Nb_Occur = 1
    For Each varI In Me!LstZone.ItemsSelected
            If Nb_Occur = 1 Then
                sFiltre = sFiltre & " and (Liste.numzonsit=" & Me!LstZone.ItemData(varI)
            Else
                sFiltre = sFiltre & " or Liste.[numzonsit]=" & Me!LstZone.ItemData(varI)
            End If
            Nb_Occur = Nb_Occur + 1
    Next varI
    sFiltre = sFiltre + ")"
End If


If CboZone.Value <> 0 Then
    sFiltre = sFiltre & " and Liste.[numzonsit]=" & CboZone
End If

If ChkAudit.Value = True Then
    sFiltre = sFiltre & " and Liste.[auditfait]=true"
End If

If ChkControleEtancheite.Value = True Then
   sFiltre = sFiltre & " and Liste.[controleetancheite]=true"
End If

If CheckParticulier.Value = True Then
   sFiltre = sFiltre & " and Liste.[demixasit]=1"
End If

If CheckSousType.Value = True Then
   sFiltre = sFiltre & " and Interv.imprimeepar is null"
End If

If ChkPhoto.Value = True Then
    sFiltre = sFiltre & " and Liste.[photofaite]=true"
End If

If Me.CheckDevisAFaire.Value = True Then
    sFiltre = sFiltre & " and Liste.[devisafaire]=true"
End If

If ChkMajRegSec.Value = True Then
    sFiltre = sFiltre & " and Liste.[majregsec]=true"
End If

If Texte17 <> "" And IsDate(Texte17) Then
    '22/06/20 inversion format date
        Date_Inv = Mid(Me.Texte17, 4, 2) + "/" + Left(Me.Texte17, 2) + "/" + Right(Me.Texte17, 4)
    If (CheckDateReele.Value = True) Then
        sFiltre = sFiltre & "  and Liste.datint >=#" & Date_Inv & "#"
    Else
        sFiltre = sFiltre & "  and Liste.datheulim >=#" & Date_Inv & "#"
    End If
End If

If Texte36 <> "" And IsDate(Texte36) Then
   '22/06/20 inversion format date
   Date_Inv = Mid(Me.Texte36, 4, 2) + "/" + Left(Me.Texte36, 2) + "/" + Right(Me.Texte36, 4)
   
   If (CheckDateReele.Value = True) Then
        sFiltre = sFiltre & "  and Liste.datint <=#" & Date_Inv & "#"
    Else
        sFiltre = sFiltre & "  and Liste.datheulim <=#" & Date_Inv & "#"
    End If
End If

Dim numsit As String
numsit = ""
If IsNumeric(Me.CboNumSit) Then
    numsit = Me.CboNumSit
End If
       
If numsit <> "" Then
    sFiltre = sFiltre + " and Liste.[numsit]=" & numsit
Else
    If Me.CboNumSit <> 0 Then
        sFiltre = sFiltre + " and Liste.[nomsit] like '%" & Me.CboNumSit & "%'"
    End If
End If


Dim SQL As String
    If (IsNull(ListeInterventionGenerale_sous_formulaire.Form) = False) Then
        If (AvecExportExcel = False) Then
            If sFiltre <> "" Then
                ListeInterventionGenerale_sous_formulaire.Form.RecordSource = "SELECT * FROM (ListeInterventionGenerale2 Liste inner join Intervention on Liste.numintint=Intervention.numintint)  where " + sFiltre + " Order by Liste.typint,Liste.nomsit"
                ListeInterventionGenerale_sous_formulaire.Form.Filter = sFiltre
                ListeInterventionGenerale_sous_formulaire.Form.FilterOn = False
            Else
                ListeInterventionGenerale_sous_formulaire.Form.RecordSource = "SELECT * FROM ListeInterventionGenerale2  Liste inner join Intervention Interv on Liste.numintint=Interv.numintint"
            End If
        Else
            If sFiltre <> "" Then
                ExportExcel (sFiltre)
            End If
            
        
        End If
    End If
    'ListeInterventionGenerale_sous_formulaire.Requery
Me.Somme.Visible = False

If (cboStatut = 10) Then
    Requete2 = "select sum(retourficheinterventionpar)as Som from (ListeInterventionGenerale2 Liste inner join Intervention on Liste.numintint=Intervention.numintint) where " + sFiltre
    Set db = CurrentDb
    Set SommeMn = db.OpenRecordset(Requete2, dbOpenSnapshot)
    Dim ChiffreSomme As Double
    Dim NbMn As Integer
    Dim NbH As Integer
    Dim NbJ As Integer
    
    Me.Somme.Visible = True
    If IsNull(SommeMn!Som) = False Then
        ChiffreSomme = SommeMn!Som
        If (ChiffreSomme < 60) Then
            Me.Somme.Caption = "Temps Total Telephone:" + Str(ChiffreSomme) + " Min"
        Else
            NbMn = ChiffreSomme Mod 60
            NbH = ChiffreSomme \ 60
            'If (NbH < 24) Then
                Me.Somme.Caption = "Temps Total Telephone:" + Str(NbH) + " h " + Str(NbMn) + " Min"
            'Else
            '    NbJ = NbH \ 24
            '    NbH = NbH Mod 24
            '    Me.Somme.Caption = "Temps Total Telephone:" + Str(NbJ) + " J " + Str(NbH) + " h " + Str(NbMn) + " Min"
            'End If
        End If
    Else
        Me.Somme.Caption = "Temps Total Telephone:0 mn"
    End If
    SommeMn.Close
    Set SommeMn = Nothing
End If
UpdateFichierBanane 2
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
    objWkbk.SaveAs (dossier_dest + "\SaisieHeuresInter.xlsx")
    'Fermer le fichier et le sauver
    objWkbk.Close True
    NbExport.Visible = False
    'libérer les pointeurs
    Set objWkbk = Nothing
    Set objXL = Nothing
End If
Liste.Close
Set Liste = Nothing

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
    DoCmd.Close acForm, "chargement"
End Sub

Private Sub Form_Load()
    Select Case Me.OpenArgs
        Case "Entretien"
            Me.cboTypeIntervention = 1
            
        Case "Maintenance"
            Me.cboTypeIntervention = 2
        Case "SuiteDevis"
            Me.cboTypeIntervention = 3

        Case "AValider"
            Me.cboStatut = 9
            Me.cboTypeIntervention = 0

        Case "AFacturer"
            Me.StatutFact = 1

        Case "AvaliderFabien"
            Me.StatutFact = 8

        Case "ACommander"
            Me.cboStatut = -1

        Case "AttenteMatos"
            Me.cboStatut = 2

        Case "Duplicata"
            Me.cboStatut = 7
            Me.CheckDevisAFaire.Value = True

            
    End Select
    Call Filtre_OM_Test(False)
    'Forms![ListeInterventionGenerale].[ListeInterventionGenerale sous-formulaire].SourceObject = ""
    
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
