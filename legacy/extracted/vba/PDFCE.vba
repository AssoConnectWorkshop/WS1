Attribute VB_Name = "PDFCE"
Option Compare Database
Public Function UpdateFichierBanane(Fonction As Integer) As String
'10/11/25 Ajout Fonction +Passage dans general
'0=Normal
'1=Arret
'2=Redemarrage
Dim NomFichier As String
Dim fs As Object
Dim Today
Dim Annee As String
Dim Mois As String
Dim Dossier As String

Mois = Month(Now)
Annee = Year(Now)
Dossier = "C:\Users\Public\" + Annee

If (Dir(Dossier, vbDirectory) = "") Then
    MkDir Dossier
End If
Dossier = "C:\Users\Public\" + Annee + "\" + Mois
If (Dir(Dossier, vbDirectory) = "") Then
    MkDir Dossier
End If

NomFichier = Dossier + "\FichierVieAccess.txt"
Set fs = CreateObject("Scripting.FileSystemObject")

If (fs.FileExists(NomFichier) = True And (Fonction = 2 Or Fonction = 1)) Then
    Kill (NomFichier)
End If


If (fs.FileExists(NomFichier) = False) Then
    Set f = fs.OpenTextFile(NomFichier, 2, True, 0)
    Dim DateToday As String
    DateToday = Now
    If (Fonction = 0 Or Fonction = 2) Then
        f.Write Str(Now) + ":Je suis Vivant!"
        UpdateFichierBanane = Str(Now) + ":Je suis Vivant!"
    Else
        f.Write Str(Now) + ":Arret Scrutation"
        UpdateFichierBanane = Str(Now) + ":Arret Scrutation"
    End If
    f.Close
End If
End Function
Public Sub Creation_PDF_CE(cptsit As String)
'Pour Choix du dossier Il faut ajouter la reference Microsoft office 15
Dim Nom_PDF As String, Dossier_PDF As String, Chemin_PDF As String
Dim Repertoir As FileDialog
Dim Requete As String
Dim Chemin_Ini As String
Dim Temp As String

Set Repertoire = Application.FileDialog(msoFileDialogFolderPicker)
'Recherche Chemin par defaut
Chemin_Ini = ""
Requete = "SELECT *  FROM Site WHERE cptsit = " & cptsit
Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
If Not lrs.EOF Then
    If IsNull(lrs!cptsit) = False Then
        Chemin_Ini = lrs!chemindoc
        Carac_Fin_Chemin = InStr(1, Chemin_Ini, "#", vbTextCompare)
        If Carac_Fin_Chemin <> 0 Then
            Chemin_Ini = Left(Chemin_Ini, Carac_Fin_Chemin - 1)
            If Chemin_Ini = "" Then
                'Push/Pull ne donne que une fois le chemin
                Chemin_Ini = Left(lrs!chemindoc, Len(lrs!chemindoc) - 1)
                Chemin_Ini = Right(Chemin_Ini, Len(Chemin_Ini) - 1)
            End If
        Else
            
            Chemin_Ini = ""
        End If
    Else
        Chemin_Ini = ""
    End If
End If

If Not lrs Is Nothing Then
    If lrs.RecordCount >= 0 <> 0 Then lrs.Close
    Set lrs = Nothing
End If


If Chemin_Ini <> "" Then
    Repertoire.InitialFileName = Chemin_Ini
End If
Repertoire.AllowMultiSelect = False
Repertoire.title = "Merci de Selectionner le repertoire pour le PDF puis cliquez sur OK"

If Repertoire.Show = 0 Then
     Exit Sub
Else
    Dossier_PDF = Repertoire.SelectedItems(1)
End If

 '28/10/24 Recherche des CE à editer
Requete = "SELECT *  FROM sitemateriel WHERE numerosite = " & cptsit + " and CE_EDITE=0 and YEAR(DateCE)=" + Format(Date, "yyyy")
Set Materiel = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)

If Materiel.RecordCount > 0 Then
    Materiel.MoveFirst
    Do While Not Materiel.EOF
        If (ControleDatasCE(Materiel!NumeroInter, Materiel!NumeroSiteMateriel)) Then
            PDF_CE Str(Materiel!NumeroInter) + "-" + Str(Materiel!NumeroSiteMateriel), Dossier_PDF
        End If
        Materiel.MoveNext
    Loop
Else

    MsgBox "Les CE ont deja été édités", vbInformation, "Déja Fait!!"
End If

If Not Materiel Is Nothing Then
    If Materiel.RecordCount >= 0 <> 0 Then Materiel.Close
    Set Materiel = Nothing
End If
End Sub

Public Function ControleDatasCE(NumInter As Long, NumMateriel As Long) As Boolean
'Requete = "Select * from intervention where numintint=" + Str(NumInter)
Set db = CurrentDb

Requete = "select * from SiteMateriel where Numerositemateriel=" + Str(NumMateriel)
Set DatasMateriel = db.OpenRecordset(Requete, dbOpenSnapshot)
If (IsNull(DatasMateriel!FluideQuantite) = False) Then
    '10/11/25 Controle du fluide saisi car il y a eu le cas d'une saisie incorrecte
    Requete = "select * from TypeFluide where Libelle='" + DatasMateriel!FluideQuantite + "'"
    Set DatasFluide = db.OpenRecordset(Requete, dbOpenSnapshot)
    If (DatasFluide!Type = 0) Then
        Txt_Erreur = "Le fluide pour le numero " + Str(NumMateriel) + " doit etre renseigné il est actuellement defini à:" + DatasMateriel!FluideQuantite + ",Merci de Corriger"
        ErreurFluide = True
        GoTo ErreurTracee
    Else
        Requete = "select * from dbo_Liste_Type_Gaz where id=" + Str(DatasFluide!Type)
        Set DatasGaz = db.OpenRecordset(Requete, dbOpenSnapshot)
    End If
Else
    Txt_Erreur = "Aucun Fluide Trouvé pour le numero " + Str(NumMateriel) + ",Merci de Corriger"
    ErreurFluide = True
    GoTo ErreurTracee
End If

ErreurFluide = False
Txt_Erreur = ""

'Controle des Datas fluide car si /ok ca sert à rien d'aller plus loin
Ligne = 0
If (Trim(DatasGaz!libelle) = "HCFC") Then
    Ligne = 1
Else
    If (Trim(DatasGaz!libelle) = "HFC") Then
        Ligne = 2
    Else
        If (Trim(DatasGaz!libelle) = "HF0") Then
            Ligne = 3
        Else
            Txt_Erreur = "Le type gaz n'est pas utilisé pour les CE:" + Trim(DatasGaz!libelle)
            ErreurFluide = True
            GoTo ErreurTracee
        End If
    End If
End If

If (DatasFluide.RecordCount <= 0) Then
    Txt_Erreur = "Aucun Fluide Trouvé pour le numero " + Str(NumMateriel) + ",Merci de Corriger"
    ErreurFluide = True
    GoTo ErreurTracee
Else
    If IsNull(DatasMateriel!NbreRadiateurs) Then
        Txt_Erreur = "Pas de Quantité de fluide saisie pour le numero " + Str(NumMateriel) + ",Merci de Corriger"
        ErreurFluide = True
        GoTo ErreurTracee
    Else
        If (DatasMateriel!NbreRadiateurs <= 0) Then
            Txt_Erreur = "Mauvaise Quantité de fluide saisie pour le numero " + Str(NumMateriel) + ",Merci de Corriger"
            ErreurFluide = True
            GoTo ErreurTracee
        End If
    End If
    If IsNull(DatasFluide!GWP) Then
        Txt_Erreur = "Pas de GWP pour le fluide " + Trim(DatasFluide!libelle) + ",Merci de Corriger"
        ErreurFluide = True
        GoTo ErreurTracee
    Else
        If (DatasFluide!GWP <= 0) Then
            Txt_Erreur = "Mauvaise saisie du GWP pour le fluide " + Trim(DatasFluide!libelle) + ",Merci de Corriger"
            ErreurFluide = True
            GoTo ErreurTracee
        End If
    End If
End If

If (IsNull(DatasMateriel!Marque) = True) Then
    Txt_Erreur = "Pas de Marque saisie pour le numero " + Str(NumMateriel) + ",Merci de Corriger"
    ErreurFluide = True
    GoTo ErreurTracee
Else
    If (Trim(DatasMateriel!Marque) = "") Then
        Txt_Erreur = "Marque Vide pour le numero " + Str(NumMateriel) + ",Merci de Corriger"
        ErreurFluide = True
        GoTo ErreurTracee
    End If
End If

If (IsNull(DatasMateriel!NumeroSerie) = True) Then
    Txt_Erreur = "Pas de NumeroSerie saisie pour le numero " + Str(NumMateriel) + ",Merci de Corriger"
    ErreurFluide = True
    GoTo ErreurTracee
Else
    If (Trim(DatasMateriel!NumeroSerie) = "") Then
        Txt_Erreur = "NumeroSerie Vide pour le numero " + Str(NumMateriel) + ",Merci de Corriger"
        ErreurFluide = True
        GoTo ErreurTracee
    End If
End If

If (IsNull(DatasMateriel!Reference) = True) Then
    Txt_Erreur = "Pas de Reference saisiepour le numero " + Str(NumMateriel) + ",Merci de Corriger"
    ErreurFluide = True
    GoTo ErreurTracee
Else
    If (Trim(DatasMateriel!Reference) = "") Then
        Txt_Erreur = "Reference Vide pour le numero " + Str(NumMateriel) + ",Merci de Corriger"
        ErreurFluide = True
        GoTo ErreurTracee
    End If
End If

If Not DatasMateriel Is Nothing Then
    If DatasMateriel.RecordCount >= 0 <> 0 Then DatasMateriel.Close
    Set DatasMateriel = Nothing
End If
If Not DatasFluide Is Nothing Then
    If DatasFluide.RecordCount >= 0 <> 0 Then DatasFluide.Close
    Set DatasFluide = Nothing
End If
If Not DatasGaz Is Nothing Then
    If DatasGaz.RecordCount >= 0 <> 0 Then DatasGaz.Close
    Set DatasGaz = Nothing
End If

ControleDatasCE = True
Exit Function
   
Erreur:

MsgBox "La génération du CE " + Str(NumInter) + "-" + Str(NumMateriel) + " n'as pas pu se faire correctement", vbCritical
ControleDatasCE = False

ErreurTracee:

MsgBox "La génération du CE " + Str(NumInter) + "-" + Str(NumMateriel) + " n'as pas pu se faire correctement ,cause:" + Txt_Erreur, vbCritical
ControleDatasCE = False

If Not DatasMateriel Is Nothing Then
    If DatasMateriel.RecordCount >= 0 <> 0 Then DatasMateriel.Close
    Set DatasMateriel = Nothing
End If
If Not DatasFluide Is Nothing Then
    If DatasFluide.RecordCount >= 0 <> 0 Then DatasFluide.Close
    Set DatasFluide = Nothing
End If
If Not DatasGaz Is Nothing Then
    If DatasGaz.RecordCount >= 0 <> 0 Then DatasGaz.Close
    Set DatasGaz = Nothing
End If
End Function


Public Sub PDF_CE(NomCE As String, Dossier_PDF As String)
'Pour Choix du dossier Il faut ajouter la reference Microsoft office 15
Dim Chemin_PDF As String
Dim Repertoir As FileDialog
Dim Requete As String
Dim Chemin_Ini As String
Dim Temp As String

  Chemin_PDF = Dossier_PDF & "\" & NomCE & ".pdf"
  
  On Error GoTo invalidFolderPath

  stDocName = "Test Cerfa"
    
  args = NomCE
  
  DoCmd.OpenReport stDocName, acViewPreview, , , acHidden, args
  DoCmd.OutputTo ObjectType:=acOutputReport, ObjectName:=stDocName, outputformat:=acFormatPDF, outputFile:=Chemin_PDF
  DoCmd.Close acReport, stDocName, acSaveNo

  
  Exit Sub
 
invalidFolderPath:
  MsgBox prompt:="Erreur: Export Vers PDF Annulé.", buttons:=vbCritical

End Sub
