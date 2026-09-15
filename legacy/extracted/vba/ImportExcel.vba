Attribute VB_Name = "ImportExcel"
Option Compare Database
Public Sub Exporter_Audit()
Dim objXL As Excel.Application
Dim objWkbk As Workbook
Dim objSht As Worksheet
Dim ListeAccept As Recordset
Dim ListeIntervention As Recordset
Dim ListeTech As Recordset
Dim db As Database
Dim NbEnreg As Integer
Dim Repertoire As FileDialog
On Error Resume Next

Set Repertoire = Application.FileDialog(msoFileDialogFolderPicker)
Repertoire.AllowMultiSelect = False
Repertoire.title = "Merci de Selectionner le repertoire pour le fichier d'export du materiel"

If Repertoire.Show = 0 Then
     Exit Sub
Else
    dossier_dest = Repertoire.SelectedItems(1)
End If


Screen.MousePointer = 11

Dim SQL As String
Dim Position As Integer
Dim Requete, Requete2, Quantite As String

'Pour Test Fersoft
'strCheminFichier = "C:\Fichier_Audit.xlsx"
strCheminFichier = "\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Audit.xlsx"
'ouvrir Excel
'Si Excel est déjà ouvert sur le PC, GetObject suffit.
On Local Error Resume Next
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

Ligne = 2
LigneExcel = 2

Dim Liste As SortedList

Requete = "SELECT NumerositeMateriel,NumeroSite,Quantite,FluideQuantite,nbreradiateurs from sitemateriel"
Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenDynaset, dbSeeChanges)
lrs.MoveLast
Max = lrs.RecordCount
lrs.MoveFirst
Do Until lrs.EOF

    
    debut = 0
    fin = 15
    
    If Ligne > fin + 1 Then
       Exit Do
    End If
    
    If Ligne >= debut And Ligne < fin Then
        If (IsNull(lrs!FluideQuantite)) Then
            fluide = ""
            Quantite = 0
        Else
            QuantiteEtFluide = lrs!FluideQuantite
            Position = InStr(1, QuantiteEtFluide, "/", vbTextCompare)
            If (Position > 0) Then
                fluide = Left(QuantiteEtFluide, Position - 1)
                fluide = Trim(fluide)
                Quantite = Right(QuantiteEtFluide, Len(QuantiteEtFluide) - Position)
                Quantite = Replace(Quantite, "Kg", "", 1)
                Quantite = Trim(Quantite)
            Else
                fluide = QuantiteEtFluide
                If (IsNull(lrs!NbreRadiateurs)) Then
                    Quantite = 0
                Else
                    Quantite = lrs!NbreRadiateurs
                End If
            End If
        End If
        If (IsNull(lrs!NumeroSite)) Then
            NumeroSite = ""
        Else
            NumeroSite = Str(lrs!NumeroSite)
        End If

        objSht.cells(LigneExcel, 1).Value = Str(lrs!NumeroSiteMateriel)
        objSht.cells(LigneExcel, 2).Value = NumeroSite
        objSht.cells(LigneExcel, 3).Value = fluide
        objSht.cells(LigneExcel, 4).Value = Quantite
        LigneExcel = LigneExcel + 1
    End If
    Ligne = Ligne + 1
    
    DoEvents
    Form_Parametrage.CmdImporter.Caption = "Encours :" + Str(Ligne) + " Sur " + Str(Max)
lrs.MoveNext
    
Loop

Destination = dossier_dest + "\Audit.xlsx"
objWkbk.SaveAs (Destination)
'Fermer le fichier et le sauver
objWkbk.Close True
 
'libérer les pointeurs
Set objWkbk = Nothing
Set objXL = Nothing
Screen.MousePointer = 0
Form_Parametrage.CmdImporter.Caption = "Export Audit Materiel"
End Sub




Function ImportSiteIntervention() As Boolean

Dim db As Database
Set db = CurrentDb
Dim rst As Recordset
Dim RsSite As Recordset
Dim RsZone As Recordset
Dim RsIntervenant As Recordset
Dim RsDonneur As Recordset
Dim rsSiteSearch As Recordset
Dim rsIntervention As Recordset
Dim rsInterventionSearch As Recordset

Set RsSite = db.OpenRecordset("Site", dbOpenDynaset, dbSeeChanges)
Set rsIntervention = db.OpenRecordset("Intervention", dbOpenDynaset, dbSeeChanges)

Dim cn As ADODB.Connection
Set cn = New ADODB.Connection

With cn
.Provider = "Microsoft.Jet.OLEDB.4.0"
.ConnectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=c:\temp\import.xlsx;Extended Properties=""Excel 12.0;HDR=YES;"""
.Open
End With

Dim rs As ADODB.Recordset
Dim failed As Boolean

Set rs = New ADODB.Recordset

failed = False

With rs

    .ActiveConnection = cn
    .Open ("SELECT * FROM [IMPORT$]")
    
    ' 1er passage pour vérifier la qualité des données
    Do Until rs.EOF
        If rs("site") <> "" Then
            Set RsZone = CurrentDb.OpenRecordset("SELECT numzon FROM ZoneGeographique WHERE nomzon ='" & rs("zone") & "'", dbOpenDynaset, dbSeeChanges)
            If RsZone.EOF Then
                failed = True
                MsgBox "La zone '" & rs("zone") & "' du fichier à importer n'existe pas dans le paramétrage. Merci de l'ajouter et de relancer. Le traitement est arrêté, aucune donnée n'a été importée."
            End If
            
            Set RsDonneur = db.OpenRecordset("select donneurid from donneur where nomdonneur='" & rs(1) & "'", dbOpenDynaset, dbSeeChanges)
            If RsDonneur.EOF Then
                failed = True
                MsgBox "Le donneur d'ordre '" & rs(1) & "' du fichier à importer n'existe pas dans le paramétrage. Merci de l'ajouter et de relancer. Le traitement est arrêté, aucune donnée n'a été importée."
            End If
            
            Set RsIntervenant = db.OpenRecordset("select numintervenant from intervenant where codint='" & rs("intervenant") & "'", dbOpenDynaset, dbSeeChanges)
            If RsIntervenant.EOF Then
                failed = True
                MsgBox "L'intervenant '" & rs("intervenant") & "' du fichier à importer n'existe pas dans le paramétrage. Merci de l'ajouter et de relancer. Le traitement est arrêté, aucune donnée n'a été importée."
            End If
            
            Set RsClient = db.OpenRecordset("select numcli from client where nomcli='" & rs("client") & "'", dbOpenDynaset, dbSeeChanges)
            If RsClient.EOF Then
                failed = True
                MsgBox "Le client '" & rs("client") & "' du fichier à importer n'existe pas dans le paramétrage. Merci de l'ajouter et de relancer. Le traitement est arrêté, aucune donnée n'a été importée."
            End If
            
            RsClient.Close
            RsIntervenant.Close
            RsDonneur.Close
            RsZone.Close
        End If
        rs.MoveNext
    Loop
    rs.Close
    
End With
    
' Là ça rigole plus, on commence à importer des données
If Not failed Then

Set rs = New ADODB.Recordset
Dim cptsit As Long

With rs
    .ActiveConnection = cn
    .Open ("SELECT * FROM [IMPORT$]")
    
    Do Until rs.EOF
                   
        Set RsDonneur = db.OpenRecordset("select donneurid from donneur where nomdonneur='" & rs(1) & "'", dbOpenDynaset, dbSeeChanges)
        Set RsIntervenant = db.OpenRecordset("select numintervenant from intervenant where codint='" & rs("intervenant") & "'", dbOpenDynaset, dbSeeChanges)
        Set RsClient = db.OpenRecordset("select numcli from client where nomcli='" & rs("client") & "'", dbOpenDynaset, dbSeeChanges)
        
        If IsNull(rs("client")) And IsNull(rs("site")) Then
            Exit Do
        End If
        
        'Est-ce que le site existe ?
        Set rsSiteSearch = db.OpenRecordset("select cptsit from site inner join client on client.numcli = site.numcli where client.nomcli ='" & Replace(rs("client"), "'", "''") & "' and site.nomsit='" & Replace(rs("site"), "'", "''") & "'", dbOpenDynaset, dbSeeChanges)
       
        
        If rsSiteSearch.EOF Then ' Alors on le créé
            RsSite.AddNew
            RsSite("numcli") = RsClient("numcli")
            RsSite("nomsit") = rs("site")
            RsSite("adrsit") = rs("adressse")
            RsSite("codpossit") = rs("code postal")
            RsSite("vilsit") = rs("ville")
             
            If rs("zone") <> "" Then
                Set RsZone = db.OpenRecordset("SELECT numzon FROM ZoneGeographique WHERE nomzon ='" & rs("zone") & "'", dbOpenDynaset, dbSeeChanges)
                RsSite("numzonsit") = RsZone("numzon")
                RsZone.Close
            End If
            
            RsSite("donneurid") = RsDonneur("donneurid")
            RsSite("numintervenant") = RsIntervenant("numintervenant")
            RsSite.Update
            Set rsCptSit = db.OpenRecordset("select max(cptsit) from site", dbOpenDynaset, dbSeeChanges)
            If Not rsCptSit.EOF Then
                cptsit = rsCptSit(0)
            End If
            rsCptSit.Close
        Else ' Sinon on récupère son numéro pour la suite
            cptsit = rsSiteSearch("cptsit")
        End If
        
        'Y a-t-il une intervention à créer ?
        If rs("date limite") <> "" Then
            'N'y en-a t'il pas déjà une à cette date ?
            Set rsInterventionSearch = db.OpenRecordset("select numintint from intervention where datheulim=#" & rs("date limite") & "# and cptsit=" & cptsit & " and typint='1'", dbOpenDynaset, dbSeeChanges)
            If rsInterventionSearch.EOF Then
                rsIntervention.AddNew
                rsIntervention("cptsit") = cptsit
                rsIntervention("codint") = rs("intervenant")
                rsIntervention("typint") = 1 'Entretien
                rsIntervention("staint") = 1 'On met le statut 'à planifier' car un oeil humain doit clôturer les interventions qui ont été importées en faisant le push/pull du bon !
                rsIntervention("datheulim") = rs("date limite")
                If rs("date intervention") <> "" Then
                    rsIntervention("datint") = rs("date intervention")
                End If
                'On Error Resume Next
                rsIntervention.Update
                'For Each MyError In DBEngine.Errors
                'With MyError
                '   MsgBox .Number & " " & .Description
                'End With
                '    MsgBox MyError.Number & " " & MyError.Description
                'Next MyError
                'On Error GoTo 0
            Else
                'Sinon on ne fait rien car pas d'intervention d'entretien à la même date pour le même site :) !
            End If
            rsInterventionSearch.Close
        End If
                
        rsSiteSearch.Close
        RsClient.Close
        RsIntervenant.Close
        RsDonneur.Close
       
        rs.MoveNext
        
    Loop
    rs.Close
    MsgBox "Import terminé"
        
End With

End If
cn.Close
Set cn = Nothing
End Function




Function ImportAnnuaire(sClient As String) As Boolean
    On Error GoTo TraitErrImport
    Dim rs As Recordset
    Dim lNumMag As Integer
    Dim lCivilite, lNom, lPrenom, lTel, lFax As String
    Select Case sClient
        ' Import Armand Thierry
        Case "AT"
            Set rs = CurrentDb.OpenRecordset("SELECT annuaire.N° AS NumMag, annuaire.F8, annuaire.Directrice, annuaire.Téléphone AS Tel, annuaire.Fax FROM annuaire", dbOpenDynaset, dbSeeChanges)
            Do Until rs.EOF
                lNumMag = rs("NumMag")
                lCivilite = rs("F8")
                If InStr(Trim(rs("Directrice")), " ") > 0 Then
                    lNom = Left(Trim(rs("Directrice")), InStr(Trim(rs("Directrice")), " ") - 1)
                    lPrenom = Mid(Trim(rs("Directrice")), InStr(Trim(rs("Directrice")), " ") + 1)
                Else
                    lNom = Trim(rs("Directrice"))
                    lPrenom = ""
                End If
                lTel = rs("Tel")
                lFax = rs("Fax")
                CurrentDb.Execute ("UPDATE Site Set civres='" & lCivilite & "', nomres='" & Replace(lNom, "'", "''") & "', preres='" & Replace(lPrenom, "'", "''") & "', telsit='" & lTel & "', faxsit='" & lFax & "' WHERE numsit=" & lNumMag & " AND numcli=1")
                rs.MoveNext
            Loop
        ' Import Celio
        Case "Celio"
            Set rs = CurrentDb.OpenRecordset("SELECT LISTING.N° AS NumMag, LISTING.TELEPHONE AS Tel, LISTING.FAX FROM LISTING WHERE (((LISTING.N°) Is Not Null))", dbOpenDynaset, dbSeeChanges)
            Do Until rs.EOF
                lNumMag = rs("NumMag")
                lTel = rs("Tel")
                lFax = rs("Fax")
                CurrentDb.Execute ("UPDATE Site Set telsit='" & lTel & "', faxsit='" & lFax & "' WHERE numsit=" & lNumMag & " AND numcli=4")
                rs.MoveNext
            Loop
    End Select
    ImportAnnuaire = True
    rs.Close
    Set rs = Nothing
    Exit Function
TraitErrImport:
    Resume Next
End Function
Function ImportSiteCelio() As Boolean

 
    Dim rs As Recordset
    Dim rq As String
    rq = "SELECT ID, Client, [N° Client interne], [N° Compteur Site], [N° Site], Champ7, [Code Site],"
    rq = rq & "[Nom Site], Situation, Champ9, Adresse, CP, Ville, Téléphone, Fax, Civilité, [Nom Responsable], "
    rq = rq & "[Prénom Responsable] , [Zone Géo], [Surface Vente], [Surface Totale], [Nbre Entretien], nbrdesenfsit, [Date Dernière Visite Désenfumage], Commentaire, [Tél Centre Commercial], [Date Création du Site], [Montant redevance], [Indicateur Qualité], [Indicateur Vetusté], [Indicateur Puissance], "
    rq = rq & "[Indicateur Accessibilité], [Date Prise en charge], hor_lun_ouv, hor_lun_fer, "
    rq = rq & "hor_mar_ouv , hor_mar_fer, hor_mer_ouv, hor_mer_fer, hor_jeu_ouv, hor_jeu_fer, hor_ven_ouv, hor_ven_fer, hor_sam_ouv, hor_sam_fer, hor_dim_ouv, hor_dim_fer, [Type de fluide], [T° Entrée], [T° Sortie], Champ50, [Code Intervenant], [Créée le], [Date de mise à jour], longitude, latitude"
    rq = rq & " FROM ClientsCelio"

    Set rs = CurrentDb.OpenRecordset("SELECT * From SitesCelio", dbOpenDynaset, dbSeeChanges)
    Do Until rs.EOF
        SQL = "INSERT INTO Site(numcli,numsit,nomsit,codsit,sitsit,adrsit,codpossit,vilsit,telsit,faxsit,civres,nomres,preres,surven,surtot,nbrentsit,comsit,temp_entree,temp_sortie,longitude,latitude) values("
        SQL2 = "188,'" & rs("N° Site") & "', '" & Replace(Replace(rs("Nom Site"), "'", "''"), vbCrLf, "") & "', '" & rs("Code Site") & "', '" & rs("Situation") & "','" & Replace(Replace(rs("Adresse"), "'", "''"), vbCrLf, "") & "','" & rs("CP") & "','" & Replace(rs("Ville"), "'", "''") & "',"
        SQL2 = SQL2 & "'" & rs("Téléphone") & "', '" & rs("Fax") & "', '" & rs("Civilité") & "', '" & rs("Nom Responsable") & "','" & rs("Prénom Responsable") & "',"
        SQL2 = SQL2 & Replace("" & "0" & rs("Surface Vente"), ",", ".") & "," & Replace("" & "0" & rs("Surface Totale"), ",", ".") & ","
        SQL2 = SQL2 & "0" & rs("Nbre Entretien") & ",'" & Replace(Replace(Replace("" & rs("Commentaire"), vbCrLf, " / ") & "", "'", "''"), Chr(13), " ") & "','" & rs("T° Entrée") & "','" & rs("T° Sortie") & "'," & Replace("0" & rs("longitude"), ",", ".") & "," & Replace("0" & rs("latitude"), ",", ".")
        Debug.Print SQL & SQL2 & ")"
        rs.MoveNext
    Loop
    rs.Close
    Set rs = Nothing

End Function

Function ImportSite() As Boolean

 
    Dim rs As Recordset
    Dim rq As String
    Dim i As Integer
    Set rs = CurrentDb.OpenRecordset("SELECT * From AImporter", dbOpenDynaset, dbSeeChanges)
    Do Until rs.EOF
        SQL = "INSERT INTO Site(numzonsit,numcli,nomsit,codsit,adrsit,codpossit,vilsit,nbrentsit,numvistecsit,mntredev,comsit,codint) values("
        SQL2 = SQL2 & "54," & rs("numcli") & ",'" & Replace(Replace(rs("nomsit"), "'", "''"), vbCrLf, "")
        SQL2 = SQL2 & "', '" & rs("codsit") & "','" & Replace(Replace(rs("adrsit"), "'", "''"), vbCrLf, "")
        SQL2 = SQL2 & "','" & rs("codpossit") & "','" & Replace(Replace(rs("vilsit"), "'", "''"), """", "'") & "',"
        SQL2 = SQL2 & "0" & rs("nbrentsit") & "," & "0" & rs("nbrvistecsit") & ","
        SQL2 = SQL2 & Replace("0" & rs("mntredev"), ",", ".") & ",'"
        SQL2 = SQL2 & Replace(Replace("" & rs("comsit"), "'", "''"), vbCrLf, "") & "','"
        SQL2 = SQL2 & Replace(Replace(rs("codint"), "'", "''"), vbCrLf, "") & "'"
        Debug.Print SQL & SQL2 & ")" & vbCrLf
        SQL2 = ""
        i = i + 1
        If i Mod 100 = 1 Then
            i = 0
            'Debug.Print "pause"
        End If
        rs.MoveNext
    Loop
    rs.Close
    Set rs = Nothing

End Function
