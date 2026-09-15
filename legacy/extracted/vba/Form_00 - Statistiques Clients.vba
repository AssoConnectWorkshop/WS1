Attribute VB_Name = "Form_00 - Statistiques Clients"
Attribute VB_Base = "0{5B5E9E1D-68A0-4013-9A0F-A25C91028E2B}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Annee_LostFocus()
Me.Mois.Enabled = False
If (Not IsNull(Me.Annee)) Then
    If IsNumeric(Me.Annee.Value) Then
        Me.Mois.Enabled = True
    End If
End If
End Sub

Private Sub Check_Degroup_Nature_AfterUpdate()
If (Check_Degroup_Nature.Value = True) Then
    If (Check_Degroup_Interv.Value = True) Then
        Check_Degroup_Interv.Value = False
    End If
    If (Check_Degroup_Statut.Value = True) Then
        Check_Degroup_Statut.Value = False
    End If
End If
End Sub

Private Sub Check_Degroup_Statut_AfterUpdate()
If (Check_Degroup_Statut.Value = True) Then
    If (Check_Degroup_Nature.Value = True) Then
        Check_Degroup_Nature.Value = False
    End If
    If (Check_Degroup_Interv.Value = True) Then
        Check_Degroup_Interv.Value = False
    End If
End If
End Sub
Private Sub Check_Degroup_Interv_AfterUpdate()
If (Check_Degroup_Interv.Value = True) Then
    If (Check_Degroup_Nature.Value = True) Then
        Check_Degroup_Nature.Value = False
    End If
    If (Check_Degroup_Statut.Value = True) Then
        Check_Degroup_Statut.Value = False
    End If
End If
End Sub

Private Sub CmdFermer_Click()
    DoCmd.Close
End Sub

Private Sub CmdRechercher_Click()
Dim objXL As Excel.Application
Dim objWkbk As Workbook
Dim objSht As Worksheet
Dim ListeAccept As Recordset
Dim ListeIntervention As Recordset
Dim ListeDepannage As Recordset
Dim ListeDevisSav As Recordset
Dim ListeDevisTrav As Recordset
Dim ListeSites As Recordset
Dim ListeTech As Recordset
Dim db As Database
Dim NbEnreg As Integer
Dim NbEnreg2 As Integer
Dim NbEnreg3 As Integer
Dim NbEnreg4 As Integer
Dim NbEnreg5 As Integer
Dim Numclient As String
Dim NumeroSite, NbEntretienSite As String
Dim DateSite As String
Dim Ligne As Integer
Dim CoutHeure As Integer
Dim CoutDepl As Integer
Dim Repertoire As FileDialog

Dim Date_Inv As String
'23/04/21 Module Stat OM
sFiltreClient = ""
sFiltre = ""
sFiltreEntretien = ""
If cboClient.Value <> 0 Then
    sFiltreClient = "numcli=" & cboClient
    Numclient = cboClient
Else
    Exit Sub
End If

Set Repertoire = Application.FileDialog(msoFileDialogFolderPicker)
Repertoire.AllowMultiSelect = False
Repertoire.title = "Merci de Selectionner le repertoire pour le fichier de statistiques"

If Repertoire.Show = 0 Then
     Exit Sub
Else
    dossier_dest = Repertoire.SelectedItems(1)
End If

Screen.MousePointer = 11

If Date_Deb <> "" And IsDate(Date_Deb) Then
    Date_Inv = Mid(Me.Date_Deb, 4, 2) + "/" + Left(Me.Date_Deb, 2) + "/" + Right(Me.Date_Deb, 4)
    Date_Devis = Right(Me.Date_Deb, 4) + "-" + Mid(Me.Date_Deb, 4, 2) + "-" + Left(Me.Date_Deb, 2)
    sFiltre = " datint >=#" & Date_Inv & "#"
    sFiltreEntretien = " datint >=#" & Date_Inv & "#"
    sFiltreDevis = " DateEnvoiDevis >='" & Date_Devis & "'"
End If

If Date_Fin <> "" And IsDate(Date_Fin) Then
   Date_Inv = Mid(Me.Date_Fin, 4, 2) + "/" + Left(Me.Date_Fin, 2) + "/" + Right(Me.Date_Fin, 4)
   Date_Devis = Right(Me.Date_Fin, 4) + "-" + Mid(Me.Date_Fin, 4, 2) + "-" + Left(Me.Date_Fin, 2)
   If sFiltre <> "" Then
        sFiltre = sFiltre + " and "
        sFiltreEntretien = sFiltreEntretien + " and "
        sFiltreDevis = sFiltreDevis + " and "
   End If
   sFiltre = sFiltre + " datint <=#" & Date_Inv & "#"
   sFiltreEntretien = sFiltreEntretien + " datint <=#" & Date_Inv & "#"
   sFiltreDevis = sFiltreDevis + " DateEnvoiDevis <='" & Date_Devis & "'"
End If

Dim SQL As String
Dim NomSite As String
Dim Nom_Client As String
Dim RedevTech As Double
Dim Requete, Requete2, Requete3, Requete4, Requete5 As String

'1)Recherche donnees client
Requete = "Select nomcli,coutheuremainoeuvre,coutdeplacement from client where numcli=" + Numclient
Set db = CurrentDb
Set Client = db.OpenRecordset(Requete, dbOpenSnapshot)
Nom_Client = Client!nomcli
CoutHeure = Client!coutheuremainoeuvre
CoutDepl = Client!coutdeplacement
Client.Close
Set Client = Nothing

'2)Recherche de tous les sites
Requete = "Select * from site where " + sFiltreClient
Set ListeSites = db.OpenRecordset(Requete, dbOpenSnapshot)
NbEnreg = ListeSites.RecordCount
    
If (NbEnreg = 0) Then Exit Sub

'Pour Test Fersoft
'strCheminFichier = "c:\Fichier_Stat.xlsx"
strCheminFichier = "\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Stat.xlsx"
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
Set SheetDevis = objWkbk.Worksheets(2)

'Make this sheet the active one when we open the Spreadsheet
objSht.Activate
Ligne = 4

index_site = 0

Do Until ListeSites.EOF
    index_site = index_site + 1
    Label_Export_Fabien.Visible = True
    Label_Export_Fabien.Caption = "Statistiques Fabien Site " + Str(index_site) + "/" + Str(ListeSites.RecordCount)
    
    DoEvents

    Ligne_en_plus = False
    NumeroSite = ListeSites!cptsit
    NomSite = ListeSites!nomsit
    DateSite = ListeSites!datemiseenservicesite
    
    If (InStr(1, NomSite, "DIJON", vbTextCompare > 1)) Then
        toto = 1
    End If
    
     With objSht
            If Ligne = 4 Then
                .cells(1, 2).Value = Nom_Client
                .cells(1, 4).Value = Date_Deb.Value
                .cells(1, 11).Value = Date_Fin.Value
            End If
            .cells(Ligne, 1).Value = NomSite
            .cells(Ligne, 2).Value = DateSite
    End With
    
    If (IsNull(ListeSites!mntredev)) Then
        RedevTech = 0
    Else
        RedevTech = ListeSites!mntredev
    End If
    If (IsNull(ListeSites!nbrentsit)) Then
        NbEntretienSite = ""
    Else
        NbEntretienSite = ListeSites!nbrentsit
    End If
    
    
    '2)Recherche des interventions sites par date demandé (pour devis accepté)
    If (sFiltre <> "") Then
        Ajout = " and "
    Else
        Ajout = " "
    End If
    
    NbDevisSAVAttente = 0
    NbDevisSAVRefus = 0
    MntDevisSAVAttente = 0
    MntDevisSAVRefus = 0
    
    NbDevisTravAttente = 0
    NbDevisTravRefus = 0
    MntDevisTravAttente = 0
    MntDevisTravRefus = 0
    
    
    'Recherche des DEVIS SAV  par sites par date demandé
    Requete4 = "select StatutDevis,MontantHTDevis from Devis where NumeroSite=" + Str(NumeroSite) + Ajout + sFiltreDevis
    Set ListeDevisSav = db.OpenRecordset(Requete4, dbOpenSnapshot)
    index_liste = 0
    If (ListeDevisSav.RecordCount > 0) Then
        index_liste = index_liste + 1
        Label_Stats_Fabien_2.Caption = "Traitement Devis SAV" + Str(index_liste) + "/" + Str(ListeDevisSav.RecordCount)
        Label_Stats_Fabien_2.Visible = True
        DoEvents
        Do Until ListeDevisSav.EOF
            If ListeDevisSav!StatutDevis = 4 Or ListeDevisSav!StatutDevis = 2 Then
                'Envoyé 4 Aucun Retour 2
                NbDevisSAVAttente = NbDevisSAVAttente + 1
                If (Not IsNull(ListeDevisSav!MontantHTDevis)) Then
                    MntDevisSAVAttente = MntDevisSAVAttente + ListeDevisSav!MontantHTDevis
                End If
            ElseIf ListeDevisSav!StatutDevis = 5 Then
                'Refusé
                NbDevisSAVRefus = NbDevisRefus + 1
                If (Not IsNull(ListeDevisSav!MontantHTDevis)) Then
                    MntDevisSAVRefus = MntDevisSAVRefus + ListeDevisSav!MontantHTDevis
                End If
            End If
            ListeDevisSav.MoveNext
        Loop
        ListeDevisSav.Close
        Set ListeDevisSav = Nothing
        
            Ligne_en_plus = True
            With objSht
                If Ligne = 4 Then
                    .cells(1, 2).Value = Nom_Client
                    .cells(1, 4).Value = Date_Deb.Value
                    .cells(1, 11).Value = Date_Fin.Value
                End If
                .cells(Ligne, 21).Value = NbDevisSAVAttente
                .cells(Ligne, 22).Value = MntDevisSAVAttente
                .cells(Ligne, 23).Value = NbDevisSAVRefus
                .cells(Ligne, 24).Value = MntDevisSAVRefus
            End With
   
    End If
    
    'Recherche des DEVIS Trav  par sites par date demandé
    Requete5 = "select StatutDevis,MontantHTDevis from DevisTravaux where NumeroSite=" + Str(NumeroSite) + Ajout + sFiltreDevis
    Set ListeDevisTrav = db.OpenRecordset(Requete5, dbOpenDynaset, dbSeeChanges)
    index_liste = 0
    If (ListeDevisTrav.RecordCount > 0) Then
        
        Do Until ListeDevisTrav.EOF
            index_liste = index_liste + 1
            Label_Stats_Fabien_2.Caption = "Traitement Devis Travaux " + Str(index_liste) + "/" + Str(ListeDevisTrav.RecordCount)
            Label_Stats_Fabien_2.Visible = True
            DoEvents
            
            If ListeDevisTrav!StatutDevis = 4 Or ListeDevisTrav!StatutDevis = 2 Then
                'Envoyé 4 Aucun Retour 2
                NbDevisTravAttente = NbDevisTravAttente + 1
                If (Not IsNull(ListeDevisTrav!MontantHTDevis)) Then
                    MntDevisTravAttente = MntDevisTravAttente + ListeDevisTrav!MontantHTDevis
                End If
            ElseIf ListeDevisTrav!StatutDevis = 5 Then
                'Refusé
                NbDevisTravRefus = NbDevisRefus + 1
                If (Not IsNull(ListeDevisTrav!MontantHTDevis)) Then
                    MntDevisTravRefus = MntDevisTravRefus + ListeDevisTrav!MontantHTDevis
                End If
            End If
            ListeDevisTrav.MoveNext
        Loop
        
        
            Ligne_en_plus = True
            With objSht
                If Ligne = 4 Then
                    .cells(1, 2).Value = Nom_Client
                    .cells(1, 4).Value = Date_Deb.Value
                    .cells(1, 11).Value = Date_Fin.Value
                End If
                .cells(Ligne, 25).Value = NbDevisTravAttente
                .cells(Ligne, 26).Value = MntDevisTravAttente
                .cells(Ligne, 27).Value = NbDevisTravRefus
                .cells(Ligne, 28).Value = MntDevisTravRefus
            End With
    End If
    
    
    '3)Recherche des interventions sites par date demandé (pour entretien)
    'staint=8 Annulé par le client
    Requete2 = "select Count(numintint) AS QteIntervention from Intervention where staint<>8 and cptsit=" + Str(NumeroSite) + Ajout + sFiltreEntretien + " and typint=""1"" "
    Set ListeIntervention = db.OpenRecordset(Requete2, dbOpenDynaset, dbSeeChanges)
    ListeIntervention.MoveLast
    NbEnreg3 = ListeIntervention.RecordCount
    index_liste = 0
    If (NbEnreg3 > 0 And ListeIntervention(0) > 0) Then
           
        Ligne_en_plus = True
        With objSht
            If Ligne = 4 Then
                .cells(1, 2).Value = Nom_Client
                .cells(1, 4).Value = Date_Deb.Value
                .cells(1, 11).Value = Date_Fin.Value
            End If
            .cells(Ligne, 1).Value = NomSite
            .cells(Ligne, 2).Value = DateSite
            .cells(Ligne, 6).Value = RedevTech
            .cells(Ligne, 5).Value = NbEntretienSite
            .cells(Ligne, 12).Value = ListeIntervention(0)
            .cells(Ligne, 13).Value = ListeIntervention(0) * RedevTech
        End With
    End If

    '3)Recherche des interventions sites par date demandé (pour depannage et devis accepté)
    Requete2 = "select datediff(""n"",heuarrint,heudepint)as Nb_Min ,numintint,mntfmc,typint,mntst,heuarrint,heudepint,staint from Intervention where cptsit=" + Str(NumeroSite) + Ajout + sFiltre + " and ( typint=""2"" or typint=""3"") "
    Set ListeDepannage = db.OpenRecordset(Requete2, dbOpenDynaset, dbSeeChanges)
    NbEnreg3 = ListeDepannage.RecordCount
    index_liste = 0
    If (NbEnreg3 > 0) Then
    
        Ligne_en_plus = True
        Dim Total_Mn_Depan, Total_Mn_Accept, SomAccept, NbAccept, NbDepan, Nb_Tech, TotSousTraitantDepan, TotSousTraitantAccept As Long
        
        Dim NumInter As String
        TotSousTraitantDepan = 0
        TotSousTraitantAccept = 0
        Total_Mn_Depan = 0
        NbDepan = 0
        NbAccept = 0
        SomAccept = 0
        Total_Mn_Accept = 0
        NbDepan_Tel = 0
        Nb_RefusDepan = 0
        Nb_RefusDevis = 0
        TotalFMCDepan = 0
        
        Do Until ListeDepannage.EOF
        
            index_liste = index_liste + 1
            Label_Stats_Fabien_2.Caption = "Traitement Depannage et Devis acceptés " + Str(index_liste) + "/" + Str(ListeDepannage.RecordCount)
            Label_Stats_Fabien_2.Visible = True
            DoEvents
            Dim DateDepart As Date
            Dim dateFin As Date
            Dim DateFinTemp As Date

            If ListeDepannage!staint = 8 Then
                If (ListeDepannage!typint = "2") Then
                    'Depannages
                    Nb_RefusDepan = Nb_RefusDepan + 1
                End If
                If (ListeDepannage!typint = "3") Then
                    'Devis Accepte
                    Nb_RefusDevis = Nb_RefusDevis + 1
                End If
            ElseIf ListeDepannage!staint = 10 Then
                If (ListeDepannage!typint = "2") Then
                    'Depannages
                    NbDepan_Tel = NbDepan_Tel + 1
                End If
            Else
            
                DateDepart = ListeDepannage!heuarrint
                dateFin = ListeDepannage!heudepint
                
                If Year(dateFin) <> Year(DateDepart) Then
                    'Cas bizarre ou le jour n'est pas le meme !!!! ->On force
                    dateFin = Str(Day(DateDepart)) + "/" + Str(Month(DateDepart)) + "/" + Str(Year(DateDepart)) + " " + Str(Hour(dateFin)) + ":" + Str(Minute(dateFin))
                End If
                
                Dim Nb_Min As Integer
                
                Nb_Min = DateDiff("n", DateDepart, dateFin, vbMonday, vbFirstJan1)
                               
                If (Not IsNull(ListeDepannage(1))) Then
                    Nb_Tech = 1
                    'On regarde le nombre de technicien sur l'inter
                    NumInter = ListeDepannage!numintint
                    Requete3 = "select Count(numintint) AS NbTech from InterventionTechnicien where numintint=" + Str(NumInter)
                    Set ListeTech = db.OpenRecordset(Requete3, dbOpenDynaset, dbSeeChanges)
                    ListeTech.MoveLast
                    NbEnreg3 = ListeTech.RecordCount
                    If (NbEnreg3 > 0 And ListeTech(0) > 1) Then
                        If (Not IsNull(ListeTech(0))) Then
                            Nb_Tech = ListeTech(0)
                        Else
                            Nb_Tech = 1
                        End If
                        
                    End If
                End If
            
                If (ListeDepannage!typint = "2") Then
                    'Depannages
                     If (Not IsNull(ListeDepannage(4))) Then
                        TotSousTraitantDepan = TotSousTraitantDepan + ListeDepannage(4)
                     End If
                                                                  
                    If (Not IsNull(ListeDepannage(0))) Then
                         'Au cas ou la saisie est inversé
                        If (Nb_Min >= 0) Then
                            Total_Mn_Depan = Total_Mn_Depan + (Nb_Min * Nb_Tech)
                        Else
                            Total_Mn_Depan = Total_Mn_Depan - (Nb_Min * Nb_Tech)
                        End If
                    End If
                    NbDepan = NbDepan + 1
                     If (Not IsNull(ListeDepannage!mntfmc)) Then
                        TotalFMCDepan = TotalFMCDepan + ListeDepannage!mntfmc
                    End If
                End If
                
                If (ListeDepannage!typint = "3") Then
                    'Devis Acceptés
                     If (Not IsNull(ListeDepannage(2))) Then
                        SomAccept = SomAccept + ListeDepannage(2)
                     End If
                                                 
                     If (Not IsNull(ListeDepannage(4))) Then
                        TotSousTraitantAccept = TotSousTraitantAccept + ListeDepannage(4)
                     End If
                                                 
                    If (Not IsNull(ListeDepannage(0))) Then
                        'Au cas ou la saisie est inversé
                        If (Nb_Min >= 0) Then
                            Total_Mn_Accept = Total_Mn_Accept + (Nb_Min * Nb_Tech)
                        Else
                            Total_Mn_Accept = Total_Mn_Accept - (Nb_Min * Nb_Tech)
                        End If
                    End If
                    NbAccept = NbAccept + 1
                End If
            End If
            
            ListeDepannage.MoveNext
        Loop
        
        With objSht
            If Ligne = 4 Then
                .cells(1, 2).Value = Nom_Client
                .cells(1, 4).Value = Date_Deb.Value
                .cells(1, 11).Value = Date_Fin.Value
            End If
            .cells(Ligne, 1).Value = NomSite
            .cells(Ligne, 2).Value = DateSite
            .cells(Ligne, 3).Value = CoutHeure
            .cells(Ligne, 4).Value = CoutDepl
            .cells(Ligne, 7).Value = NbAccept
            .cells(Ligne, 8).Value = Total_Mn_Accept / 60
            .cells(Ligne, 9).Value = TotSousTraitantAccept
            .cells(Ligne, 10).Value = SomAccept
            .cells(Ligne, 11).Value = Nb_RefusDevis
            .cells(Ligne, 14).Value = NbDepan
            .cells(Ligne, 15).Value = Total_Mn_Depan / 60
            .cells(Ligne, 16).Value = TotSousTraitantDepan
            .cells(Ligne, 17).Value = NbDepan * CoutDepl + CoutHeure * (Total_Mn_Depan / 60)
            .cells(Ligne, 18).Value = TotalFMCDepan
            .cells(Ligne, 19).Value = NbDepan_Tel
            .cells(Ligne, 20).Value = Nb_RefusDepan
        End With
        
    End If

    If Ligne_en_plus = True Then
        Ligne = Ligne + 1
    End If
    ListeSites.MoveNext
Loop
ListeSites.Close
Set ListeSites = Nothing
NomFichier = Replace(Nom_Client, "/", "_")
NomFichier = Replace(NomFichier, "\", "_")
NomFichier = Replace(NomFichier, "'", " ")
'objXL.Visible = True
If (Date_Deb <> "" And IsDate(Date_Deb)) Then
    debut = Date_Deb.Value
    debut = Replace(debut, "/", "_")
Else
    debut = ""
End If

If Date_Fin <> "" And IsDate(Date_Fin) Then
    fin = Date_Fin.Value
    fin = Replace(fin, "/", "_")
Else
    debut = ""
End If

If (debut = "") Then
    If (fin <> "") Then
        NomFichier = NomFichier + "JUSQU_A_" + fin
    End If
Else
    If (fin = "") Then
        NomFichier = NomFichier + "DEPUIS_" + debut
    Else
        NomFichier = NomFichier + "_DU_" + debut + "_AU_" + fin
    End If
    
End If

objWkbk.SaveAs (dossier_dest + "\" + NomFichier + ".xlsx")
'Fermer le fichier et le sauver
objWkbk.Close True
 
'libérer les pointeurs
Set objWkbk = Nothing
Set objXL = Nothing
Screen.MousePointer = 0
Label_Export_Fabien.Visible = False
Label_Stats_Fabien_2.Visible = False
End Sub

Private Sub Commande11_Click()
'****** Filtre Nom ********************
If CocherNom.Value = False Then
    Calcul_Eclate
Else
    Calcul_Nom
End If
End Sub

Private Sub Calcul_Total()
Dim objXL As Excel.Application
Dim objWkbk As Workbook
Dim objSht As Worksheet
Dim ListeInter As Recordset
Dim ListeSites As Recordset
Dim db As Database
Dim NbEnreg As Integer
Dim NbEnreg2 As Integer
Dim NbEnreg3 As Integer
Dim NbEnreg4 As Integer
Dim Numclient As String
Dim NumeroSite, NbEntretienSite As String
Dim DateSite As String
Dim Ligne As Integer
Dim CoutHeure As Integer
Dim CoutDepl As Integer
Dim Repertoire As FileDialog
Dim varI As Variant

Dim Date_Inv As String
'23/04/21 Module Stat OM
sFiltreClient = ""
sFiltre = ""

sFiltreInterv = ""
sFiltreNature = ""
sFiltreStatut = ""
sFiltreEntretien = ""
sFiltreAnnee = ""
TexteFiltreNature = ""
TexteFiltreStatut = ""
TexteFiltreInter = ""
If cboClient.Value <> 0 Then
    sFiltreClient = "numcli=" & cboClient
    Numclient = cboClient
Else
    Exit Sub
End If


Set Repertoire = Application.FileDialog(msoFileDialogFolderPicker)
Repertoire.AllowMultiSelect = False
Repertoire.title = "Merci de Selectionner le repertoire pour le fichier de statistiques"

If Repertoire.Show = 0 Then
     Exit Sub
Else
    dossier_dest = Repertoire.SelectedItems(1)
End If

Screen.MousePointer = 11


'****** Filtre Année ********************

If Annee <> "" And IsNumeric(Annee) Then
    sFiltreAnnee = " and datheulim <=#12/31/" + Trim(Str(Me.Annee)) + "# and datheulim >=#01/01/" + Trim(Str(Me.Annee)) + "# "
   
End If


'****** Filtre Type Inter ********************
If Me.LstTypeIntervention.ItemsSelected.Count <> 0 Then
    Nb_Occur = 1
    For Each varI In Me!LstTypeIntervention.ItemsSelected
        If (TexteFiltreInter = "") Then
            TexteFiltreInter = "Filtre par Type Intervention: " & Trim(Me!LstTypeIntervention.Column(1, varI))
        Else
            TexteFiltreInter = TexteFiltreInter & " , " & Trim(Me!LstTypeIntervention.Column(1, varI))
        End If
        If Nb_Occur = 1 Then
            sFiltreInterv = " and ( typint=""" & Me!LstTypeIntervention.ItemData(varI) + """"
        Else
            sFiltreInterv = sFiltreInterv & " or typint=""" & Me!LstTypeIntervention.ItemData(varI) + """"
        End If
        Nb_Occur = Nb_Occur + 1
    Next varI
    sFiltreInterv = sFiltreInterv + " )"
End If

'****** Filtre Statut ********************
If Me.ListeStatut.ItemsSelected.Count <> 0 Then
    Nb_Occur = 1
    For Each varI In Me!ListeStatut.ItemsSelected
        If (TexteFiltreStatut = "") Then
            TexteFiltreStatut = "Filtre par Statut: " & Trim(Me!ListeStatut.Column(1, varI))
        Else
            TexteFiltreStatut = TexteFiltreStatut & " , " & Trim(Me!ListeStatut.Column(1, varI))
        End If
        If Nb_Occur = 1 Then
            sFiltreStatut = " and ( staint=" & Me!ListeStatut.ItemData(varI)
        Else
            sFiltreStatut = sFiltreStatut & " or staint=" & Me!ListeStatut.ItemData(varI)
        End If
        Nb_Occur = Nb_Occur + 1
    Next varI
    sFiltreStatut = sFiltreStatut + " )"
End If

'****** Filtre Nature ********************
If Me.ListeNature.ItemsSelected.Count <> 0 Then
    Nb_Occur = 1
    For Each varI In Me!ListeNature.ItemsSelected
        If (TexteFiltreNature = "") Then
            TexteFiltreNature = "Filtre par nature: " & Trim(Me!ListeNature.Column(1, varI))
        Else
            TexteFiltreNature = TexteFiltreNature & " , " & Trim(Me!ListeNature.Column(1, varI))
        End If
        If Nb_Occur = 1 Then
            sFiltreNature = " and ( Imprimeepar=" + Trim(Me!ListeNature.Column(0, varI))
        Else
            sFiltreNature = sFiltreNature & " or Imprimeepar=" & Trim(Me!ListeNature.Column(0, varI))
        End If
        Nb_Occur = Nb_Occur + 1
    Next varI
    sFiltreNature = sFiltreNature + " )"
End If





Dim SQL As String
Dim NomSite As String
Dim Nom_Client As String
Dim RedevTech As Double
Dim Requete, Requete2, Requete3 As String

'1)Recherche donnees client
Requete = "Select nomcli from client where numcli=" + Numclient
Set db = CurrentDb
Set Client = db.OpenRecordset(Requete, dbOpenDynaset, dbSeeChanges)
Nom_Client = Client!nomcli

'2)Recherche de tous les sites
'!!!!!!!!!!!!!!!!ICI Changer Requete Pour filtre par Nom + Boucle pour chaque nom declaré
Requete = "Select * from site where " + sFiltreClient
Set ListeSites = db.OpenRecordset(Requete, dbOpenDynaset, dbSeeChanges)
NbEnreg = ListeSites.RecordCount
    
If (NbEnreg = 0) Then Exit Sub

'Pour Test Fersoft
'strCheminFichier = "c:\Fichier_Stat_OGF.xlsx"
strCheminFichier = "\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Stat_OGF.xlsx"
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
Ligne = 8


Do Until ListeSites.EOF
    Ligne_en_plus = False
    NumeroSite = ListeSites!cptsit
    NomSite = ListeSites!nomsit
    If (Not IsNull(ListeSites!datemiseenservicesite)) Then
        DateSite = ListeSites!datemiseenservicesite
    Else
        DateSite = ""
    End If
    
    '3)Recherche des interventions sites
    Requete2 = "select Count(numintint) AS QteIntervention , Sum(mntfmc) as Montant from Intervention where cptsit=" + Str(NumeroSite) + sFiltreStatut + sFiltreNature + sFiltreAnnee + sFiltreInterv
    Set ListeInter = db.OpenRecordset(Requete2, dbOpenDynaset, dbSeeChanges)
    
    ListeInter.MoveLast
    NbEnreg3 = ListeInter.RecordCount
    If (NbEnreg3 > 0 And ListeInter(0) > 0) Then
        Ligne_en_plus = True
        With objSht
            If Ligne = 8 Then
                .cells(1, 2).Value = Nom_Client
                If (Not IsNull(Me.Annee)) Then
                    .cells(1, 4).Value = Trim(Str(Me.Annee))
                Else
                    .cells(1, 4).Value = "Aucune"
                End If
            End If
            .cells(Ligne, 1).Value = NomSite
            .cells(Ligne, 2).Value = ListeInter!QteIntervention
            .cells(Ligne, 3).Value = ListeInter!Montant
        End With
    End If

    
    If Ligne_en_plus = True Then
        Ligne = Ligne + 1
    End If
    ListeSites.MoveNext
Loop
objSht.cells(2, 1).Value = TexteFiltreInter
objSht.cells(3, 1).Value = TexteFiltreStatut
objSht.cells(4, 1).Value = TexteFiltreNature


NomFichier = Replace(Nom_Client, "/", "_")
NomFichier = Replace(NomFichier, "\", "_")
NomFichier = Replace(NomFichier, "'", " ")
'objXL.Visible = True


objWkbk.SaveAs (dossier_dest + "\" + NomFichier + ".xlsx")
'Fermer le fichier et le sauver
objWkbk.Close True
 
'libérer les pointeurs
Set objWkbk = Nothing
Set objXL = Nothing
Screen.MousePointer = 0
End Sub
Private Sub Calcul_Eclate()
Dim objXL As Excel.Application
Dim objWkbk As Workbook
Dim objSht As Worksheet
Dim ListeInter As Recordset
Dim ListeSites As Recordset
Dim db As Database
Dim NbEnreg As Integer
Dim NbEnreg2 As Integer
Dim NbEnreg3 As Integer
Dim NbEnreg4 As Integer
Dim Numclient As String
Dim NumeroSite, NbEntretienSite As String
Dim Ligne As Integer
Dim CoutHeure As Integer
Dim CoutDepl As Integer
Dim Repertoire As FileDialog
Dim varI As Variant

Dim Date_Inv As String
'10/08/21 Module Stat OM
sFiltreClient = ""
sFiltre = ""
sFiltreInterv = ""
sFiltreNature = ""
sFiltreStatut = ""
sFiltreEntretien = ""
sFiltreAnnee = ""
TexteFiltreNature = ""
TexteFiltreStatut = ""
TexteFiltreInter = ""
If cboClient.Value <> 0 Then
    sFiltreClient = "numcli=" & cboClient
    Numclient = cboClient
Else
    Exit Sub
End If


Set Repertoire = Application.FileDialog(msoFileDialogFolderPicker)
Repertoire.AllowMultiSelect = False
Repertoire.title = "Merci de Selectionner le repertoire pour le fichier de statistiques"

If Repertoire.Show = 0 Then
     Exit Sub
Else
    dossier_dest = Repertoire.SelectedItems(1)
End If

Screen.MousePointer = 11


'****** Filtre Année/Date ********************

If Annee <> "" And IsNumeric(Annee) Then
    sFiltreAnnee = " and datheulim <=#12/31/" + Trim(Str(Me.Annee)) + "# and datheulim >=#01/01/" + Trim(Str(Me.Annee)) + "# "
Else
    If Date_Deb <> "" And IsDate(Date_Deb) Then
        Date_Inv = Mid(Me.Date_Deb, 4, 2) + "/" + Left(Me.Date_Deb, 2) + "/" + Right(Me.Date_Deb, 4)
        sFiltreAnnee = " and datheulim >=#" & Date_Inv & "# "
    End If
    
    If Date_Fin <> "" And IsDate(Date_Fin) Then
       Date_Inv = Mid(Me.Date_Fin, 4, 2) + "/" + Left(Me.Date_Fin, 2) + "/" + Right(Me.Date_Fin, 4)
        sFiltreAnnee = sFiltreAnnee + "and  datheulim <=#" & Date_Inv & "# "
    End If
End If

'****** Filtre Type Inter ********************
If Me.LstTypeIntervention.ItemsSelected.Count <> 0 And Check_Degroup_Interv.Value = False Then
    Nb_Occur = 1
    If (Me.LstTypeIntervention.ItemsSelected.Count = 0) Then
        TexteFiltreInter = "Aucun Filtre pour les types intervention"
    End If
    For Each varI In Me!LstTypeIntervention.ItemsSelected
        If (TexteFiltreInter = "") Then
            TexteFiltreInter = "Filtre par Type Intervention: " & Trim(Me!LstTypeIntervention.Column(1, varI))
        Else
            TexteFiltreInter = TexteFiltreInter & " , " & Trim(Me!LstTypeIntervention.Column(1, varI))
        End If
        If Nb_Occur = 1 Then
            sFiltreInterv = " and ( typint=""" & Me!LstTypeIntervention.ItemData(varI) + """"
        Else
            sFiltreInterv = sFiltreInterv & " or typint=""" & Me!LstTypeIntervention.ItemData(varI) + """"
        End If
        Nb_Occur = Nb_Occur + 1
    Next varI
    sFiltreInterv = sFiltreInterv + " )"
End If


'****** Filtre Statut ********************
If Me.ListeStatut.ItemsSelected.Count <> 0 And Check_Degroup_Statut.Value = False Then
    Nb_Occur = 1
    If (Me.ListeStatut.ItemsSelected.Count = 0) Then
        TexteFiltreStatut = "Aucun Filtre pour les status d'intervention"
    End If
    For Each varI In Me!ListeStatut.ItemsSelected
        If (TexteFiltreStatut = "") Then
            TexteFiltreStatut = "Filtre par Statut: " & Trim(Me!ListeStatut.Column(1, varI))
        Else
            TexteFiltreStatut = TexteFiltreStatut & " , " & Trim(Me!ListeStatut.Column(1, varI))
        End If
        If Nb_Occur = 1 Then
            sFiltreStatut = " and ( staint=" & Me!ListeStatut.ItemData(varI)
        Else
            sFiltreStatut = sFiltreStatut & " or staint=" & Me!ListeStatut.ItemData(varI)
        End If
        Nb_Occur = Nb_Occur + 1
    Next varI
    sFiltreStatut = sFiltreStatut + " )"
End If

    
'****** Filtre Nature ********************
If Me.ListeNature.ItemsSelected.Count <> 0 And Check_Degroup_Nature.Value = False Then
    Nb_Occur = 1
    If (Me.ListeNature.ItemsSelected.Count = 0) Then
        TexteFiltreNature = "Aucun Filtre pour les sous types d'intervention"
    End If
    For Each varI In Me!ListeNature.ItemsSelected
        If (TexteFiltreNature = "") Then
            TexteFiltreNature = "Filtre par sous type : " & Trim(Me!ListeNature.Column(1, varI))
        Else
            TexteFiltreNature = TexteFiltreNature & " , " & Trim(Me!ListeNature.Column(1, varI))
        End If
        If Nb_Occur = 1 Then
            sFiltreNature = " and ( Imprimeepar=" + Trim(Me!ListeNature.Column(0, varI))
        Else
            sFiltreNature = sFiltreNature & " or Imprimeepar=" & Trim(Me!ListeNature.Column(0, varI))
        End If
        Nb_Occur = Nb_Occur + 1
    Next varI
    sFiltreNature = sFiltreNature + " )"
End If

Dim SQL As String
Dim NomSite As String
Dim Nom_Client As String
Dim RedevTech As Double
Dim Requete, Requete2, Requete3 As String

'1)Recherche donnees client
Requete = "Select nomcli from client where numcli=" + Numclient
Set db = CurrentDb
Set Client = db.OpenRecordset(Requete, dbOpenDynaset, dbSeeChanges)
Nom_Client = Client!nomcli

'2)Recherche de tous les sites
Requete = "Select * from site where " + sFiltreClient
Set ListeSites = db.OpenRecordset(Requete, dbOpenDynaset, dbSeeChanges)
NbEnreg = ListeSites.RecordCount
    
If (NbEnreg = 0) Then Exit Sub

Excel_Ouvert = False
'****** Cas Gestion des Mois ********************
Dim Index_mois As Integer
Index_mois = 0
Suite_Mois:
ListeSites.MoveFirst
If Annee <> "" And IsNumeric(Annee) And Me.Mois.Enabled = True Then
    If Me.Mois.Value = 0 Then
        Index_mois = Index_mois + 1
        sFiltreAnnee = " and month(datheulim)=" + Str(Index_mois) + " and Year(datheulim)=" + Trim(Str(Me.Annee))
    ElseIf Me.Mois.Value >= 1 And Me.Mois.Value <= 12 Then
        Index_mois = Me.Mois.Value
        sFiltreAnnee = " and month(datheulim)=" + Str(Index_mois) + " and Year(datheulim)=" + Trim(Str(Me.Annee))
    End If
End If


If (Excel_Ouvert = False) Then
    ''''''''''''''PENSER A REMETTRE LES BONS NOM DE FICHIERS''''''''''''''''''''''''''''''''''''
    If (Index_mois = 0) Then
        'strCheminFichier = "c:\Fichier_Stat_OGF.xlsx"
        strCheminFichier = "\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Stat_OGF.xlsx"
    Else
        'strCheminFichier = "c:\Fichier_Stat_OGF_Par_Mois.xlsx"
        strCheminFichier = "\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Stat_OGF_Par_Mois.xlsx"
    End If
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
    
    Excel_Ouvert = True
End If


'Selection Onglet
If (Index_mois = 0) Then
    Set objSht = objWkbk.Worksheets(1)
Else
    Set objSht = objWkbk.Worksheets(Index_mois)
End If

'Make this sheet the active one when we open the Spreadsheet
objSht.Activate
Ligne = 8

'Données Generiques de la feuille
objSht.cells(1, 2).Value = Nom_Client
If (Not IsNull(Me.Annee)) Then
    If Index_mois = 0 Then
        objSht.cells(1, 4).Value = "Année " + Trim(Str(Me.Annee))
    Else
        objSht.cells(1, 4).Value = MonthName(Index_mois) + " " + Trim(Str(Me.Annee))
    End If
Else
    If Date_Deb <> "" And IsDate(Date_Deb) And Date_Fin <> "" And IsDate(Date_Fin) Then
       objSht.cells(1, 4).Value = "Du " + Format(Date_Deb, "dd/mm/yyyy") + " Au " + Format(Date_Fin, "dd/mm/yyyy")
    End If
End If
objSht.cells(2, 1).Value = TexteFiltreInter
objSht.cells(3, 1).Value = TexteFiltreStatut
objSht.cells(4, 1).Value = TexteFiltreNature


Dim TableauFiltre(15) As String
Dim NomColonne(15) As String
Dim Index As Integer
Dim DegroupStatut, DegroupType, DegroupNature As Boolean
Index = 1
DegroupStatut = False
DegroupType = False
DegroupNature = False
      
'****** Degroupé par Statut ********************
If Me.ListeStatut.ItemsSelected.Count <> 0 And Check_Degroup_Statut.Value = True Then
    For Each varI In Me!ListeStatut.ItemsSelected
        TableauFiltre(Index) = " and ( staint=" & Trim(Me!ListeStatut.Column(0, varI)) + ")"
        NomColonne(Index) = Trim(Me!ListeStatut.Column(1, varI))
        Index = Index + 1
    Next varI
    DegroupStatut = True
End If

'****** Degroupé par Interv ********************
If Me.LstTypeIntervention.ItemsSelected.Count <> 0 And Check_Degroup_Interv.Value = True Then
    For Each varI In Me!LstTypeIntervention.ItemsSelected
        TableauFiltre(Index) = " and ( typint=""" & Trim(Me!LstTypeIntervention.Column(0, varI)) + """)"
        NomColonne(Index) = Trim(Me!LstTypeIntervention.Column(1, varI))
        Index = Index + 1
    Next varI
    DegroupType = True
End If

'****** Degroupé par Nature/SousType ********************
If Me.ListeNature.ItemsSelected.Count <> 0 And Check_Degroup_Nature.Value = True Then
    For Each varI In Me!ListeNature.ItemsSelected
        TableauFiltre(Index) = " and ( Imprimeepar=" + Trim(Me!ListeNature.Column(0, varI)) + ")"
        NomColonne(Index) = Trim(Me!ListeNature.Column(1, varI))
        Index = Index + 1
    Next varI
    DegroupNature = True
End If


'Boucle sur tous les sites
Do Until ListeSites.EOF
    Bloc_Colonne = 0
    Affiche_Nom_Site = False
    Ligne_en_plus = False
    NumeroSite = ListeSites!cptsit
    NomSite = ListeSites!nomsit
              
    If DegroupType Or DegroupNature Or DegroupStatut Then
        For i = 1 To Index - 1
            If DegroupStatut Then
                sFiltreStatut = TableauFiltre(i)
            ElseIf DegroupType Then
                sFiltreInterv = TableauFiltre(i)
            ElseIf DegroupNature Then
                sFiltreNature = TableauFiltre(i)
            End If
            If Ligne = 8 Then
                objSht.cells(6, Bloc_Colonne * 2 + 2).Value = NomColonne(i)
            End If
            
            Requete2 = "select Count(numintint) AS QteIntervention , Sum(mntfmc) as Montant from Intervention where cptsit=" + Str(NumeroSite) + sFiltreStatut + sFiltreNature + sFiltreAnnee + sFiltreInterv
            Set ListeInter = db.OpenRecordset(Requete2, dbOpenDynaset, dbSeeChanges)
            
            ListeInter.MoveLast
            NbEnreg3 = ListeInter.RecordCount
            If (NbEnreg3 > 0 And ListeInter(0) > 0) Then
                If (Affiche_Nom_Site = False) Then
                    'Nom du Site
                    objSht.cells(Ligne, 1).Value = NomSite
                    Affiche_Nom_Site = True
                End If
                Ligne_en_plus = True
                If (Not IsNull(ListeInter!QteIntervention)) Then
                    objSht.cells(Ligne, Bloc_Colonne * 2 + 2).Value = Str(ListeInter!QteIntervention)
                End If
                 If (Not IsNull(ListeInter!Montant)) Then
                    objSht.cells(Ligne, Bloc_Colonne * 2 + 3).Value = Str(ListeInter!Montant)
                End If

            End If
            Bloc_Colonne = Bloc_Colonne + 1
        Next i
        
    Else
        '****** Sans Degroupage ********************
        Requete2 = "select Count(numintint) AS QteIntervention , Sum(mntfmc) as Montant from Intervention where cptsit=" + Str(NumeroSite) + sFiltreStatut + sFiltreNature + sFiltreAnnee + sFiltreInterv
        Set ListeInter = db.OpenRecordset(Requete2, dbOpenDynaset, dbSeeChanges)
        
        ListeInter.MoveLast
        NbEnreg3 = ListeInter.RecordCount
        If (NbEnreg3 > 0 And ListeInter(0) > 0) Then
            If (Affiche_Nom_Site = False) Then
                'Nom du Site
                objSht.cells(Ligne, 1).Value = NomSite
                Affiche_Nom_Site = True
            End If
            Ligne_en_plus = True
            With objSht
                .cells(Ligne, 2).Value = ListeInter!QteIntervention
                .cells(Ligne, 3).Value = ListeInter!Montant
            End With
        End If
    End If
    
    If Ligne_en_plus = True Then
        Ligne = Ligne + 1
    End If
    ListeSites.MoveNext
Loop


If (Index_mois <> 0 And Me.Mois.Value = 0 And Index_mois < 12) Then
    GoTo Suite_Mois
End If

NomFichier = Replace(Nom_Client, "/", "_")
NomFichier = Replace(NomFichier, "\", "_")
NomFichier = Replace(NomFichier, "'", " ")
'objXL.Visible = True


objWkbk.SaveAs (dossier_dest + "\" + NomFichier + ".xlsx")
'Fermer le fichier et le sauver
objWkbk.Close True
 
'libérer les pointeurs
Set objWkbk = Nothing
Set objXL = Nothing
Screen.MousePointer = 0
End Sub

Private Sub Calcul_Nom()
Dim objXL As Excel.Application
Dim objWkbk As Workbook
Dim objSht As Worksheet
Dim ListeInter As Recordset
Dim ListeSites As Recordset
Dim db As Database
Dim NbEnreg As Integer
Dim NbEnreg2 As Integer
Dim NbEnreg3 As Integer
Dim NbEnreg4 As Integer
Dim Numclient As String
Dim NumeroSite, NbEntretienSite As String
Dim Ligne As Integer
Dim CoutHeure As Integer
Dim CoutDepl As Integer
Dim Repertoire As FileDialog
Dim varI As Variant
Dim NbInter(100)
Dim TotalInter(100)


Dim Date_Inv As String
'10/08/21 Module Stat OM
sFiltreClient = ""
sFiltre = ""
sFiltreNom = ""
sFiltreInterv = ""
sFiltreNature = ""
sFiltreStatut = ""
sFiltreEntretien = ""
sFiltreAnnee = ""
TexteFiltreNature = ""
TexteFiltreStatut = ""
TexteFiltreInter = ""
TexteFiltreNom = ""
If cboClient.Value <> 0 Then
    sFiltreClient = "numcli=" & cboClient
    Numclient = cboClient
Else
    Exit Sub
End If

'Aucun texte de saisi on sort
If (Me.Texte18.Value = "" And Me.Texte21.Value = "" And Me.Texte22.Value = "" And Me.Texte23.Value = "") Then
    Exit Sub
End If

Set Repertoire = Application.FileDialog(msoFileDialogFolderPicker)
Repertoire.AllowMultiSelect = False
Repertoire.title = "Merci de Selectionner le repertoire pour le fichier de statistiques"

If Repertoire.Show = 0 Then
     Exit Sub
Else
    dossier_dest = Repertoire.SelectedItems(1)
End If

Screen.MousePointer = 11


'****** Filtre Année/Date ********************

If Annee <> "" And IsNumeric(Annee) Then
    sFiltreAnnee = " and datheulim <=#12/31/" + Trim(Str(Me.Annee)) + "# and datheulim >=#01/01/" + Trim(Str(Me.Annee)) + "# "
Else
    If Date_Deb <> "" And IsDate(Date_Deb) Then
        Date_Inv = Mid(Me.Date_Deb, 4, 2) + "/" + Left(Me.Date_Deb, 2) + "/" + Right(Me.Date_Deb, 4)
        sFiltreAnnee = " datheulim >=#" & Date_Inv & "# "
    End If
    
    If Date_Fin <> "" And IsDate(Date_Fin) Then
       Date_Inv = Mid(Me.Date_Fin, 4, 2) + "/" + Left(Me.Date_Fin, 2) + "/" + Right(Me.Date_Fin, 4)
        sFiltreAnnee = sFiltreAnnee + "and  datheulim <=#" & Date_Inv & "# "
    End If
End If



'****** Filtre Type Inter ********************
If Me.LstTypeIntervention.ItemsSelected.Count <> 0 And Check_Degroup_Interv.Value = False Then
    Nb_Occur = 1
    If (Me.LstTypeIntervention.ItemsSelected.Count = 0) Then
        TexteFiltreInter = "Aucun Filtre pour les Types d'intervention"
    End If
    For Each varI In Me!LstTypeIntervention.ItemsSelected
        If (TexteFiltreInter = "") Then
            TexteFiltreInter = "Filtre par Type Intervention: " & Trim(Me!LstTypeIntervention.Column(1, varI))
        Else
            TexteFiltreInter = TexteFiltreInter & " , " & Trim(Me!LstTypeIntervention.Column(1, varI))
        End If
        If Nb_Occur = 1 Then
            sFiltreInterv = " and ( typint=""" & Me!LstTypeIntervention.ItemData(varI) + """"
        Else
            sFiltreInterv = sFiltreInterv & " or typint=""" & Me!LstTypeIntervention.ItemData(varI) + """"
        End If
        Nb_Occur = Nb_Occur + 1
    Next varI
    sFiltreInterv = sFiltreInterv + " )"
End If


'****** Filtre Statut ********************
If Me.ListeStatut.ItemsSelected.Count <> 0 And Check_Degroup_Statut.Value = False Then
    Nb_Occur = 1
    If (Me.ListeStatut.ItemsSelected.Count = 0) Then
        TexteFiltreStatut = "Aucun Filtre pour les status d'intervention"
    End If
    For Each varI In Me!ListeStatut.ItemsSelected
        If (TexteFiltreStatut = "") Then
            TexteFiltreStatut = "Filtre par Statut: " & Trim(Me!ListeStatut.Column(1, varI))
        Else
            TexteFiltreStatut = TexteFiltreStatut & " , " & Trim(Me!ListeStatut.Column(1, varI))
        End If
        If Nb_Occur = 1 Then
            sFiltreStatut = " and ( staint=" & Me!ListeStatut.ItemData(varI)
        Else
            sFiltreStatut = sFiltreStatut & " or staint=" & Me!ListeStatut.ItemData(varI)
        End If
        Nb_Occur = Nb_Occur + 1
    Next varI
    sFiltreStatut = sFiltreStatut + " )"
End If

    
'****** Filtre Nature ********************
If Me.ListeNature.ItemsSelected.Count <> 0 And Check_Degroup_Nature.Value = False Then
    Nb_Occur = 1
    If (Me.ListeNature.ItemsSelected.Count = 0) Then
        TexteFiltreNature = "Aucun Filtre pour les sous types d'intervention"
    End If
    For Each varI In Me!ListeNature.ItemsSelected
        If (TexteFiltreNature = "") Then
            TexteFiltreNature = "Filtre par sous type : " & Trim(Me!ListeNature.Column(1, varI))
        Else
            TexteFiltreNature = TexteFiltreNature & " , " & Trim(Me!ListeNature.Column(1, varI))
        End If
        If Nb_Occur = 1 Then
            sFiltreNature = " and ( Imprimeepar=" + Trim(Me!ListeNature.Column(0, varI))
        Else
            sFiltreNature = sFiltreNature & " or Imprimeepar=" & Trim(Me!ListeNature.Column(0, varI))
        End If
        Nb_Occur = Nb_Occur + 1
    Next varI
    sFiltreNature = sFiltreNature + " )"
End If


Dim SQL As String
Dim NomSite As String
Dim Nom_Client As String
Dim RedevTech As Double
Dim Requete, Requete2, Requete3 As String


Erase TotalInter
Erase NbInter


'1)Recherche donnees client
Requete = "Select nomcli from client where numcli=" + Numclient
Set db = CurrentDb
Set Client = db.OpenRecordset(Requete, dbOpenDynaset, dbSeeChanges)
Nom_Client = Client!nomcli

Excel_Ouvert = False
'****** Cas Gestion des Mois ********************
Dim Index_mois As Integer
Index_mois = 0
Suite_Mois:
If Annee <> "" And IsNumeric(Annee) And Me.Mois.Enabled = True Then
    If Me.Mois.Value = 0 Then
        Index_mois = Index_mois + 1
        sFiltreAnnee = " and month(datheulim)=" + Str(Index_mois) + " and Year(datheulim)=" + Trim(Str(Me.Annee))
    ElseIf Me.Mois.Value >= 1 And Me.Mois.Value <= 12 Then
        Index_mois = Me.Mois.Value
        sFiltreAnnee = " and month(datheulim)=" + Str(Index_mois) + " and Year(datheulim)=" + Trim(Str(Me.Annee))
    End If
End If


If (Excel_Ouvert = False) Then
    ''''''''''''''PENSER A REMETTRE LES BONS NOM DE FICHIERS''''''''''''''''''''''''''''''''''''
    If (Index_mois = 0) Then
        'strCheminFichier = "c:\Fichier_Stat_OGF.xlsx"
        strCheminFichier = "\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Stat_OGF.xlsx"
    Else
        'strCheminFichier = "c:\Fichier_Stat_OGF_Par_Mois.xlsx"
        strCheminFichier = "\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Stat_OGF_Par_Mois.xlsx"
    End If
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
    
    Excel_Ouvert = True
End If

'Selection Onglet
If (Index_mois = 0) Then
    Set objSht = objWkbk.Worksheets(1)
Else
    Set objSht = objWkbk.Worksheets(Index_mois)
End If


'Make this sheet the active one when we open the Spreadsheet
objSht.Activate
Ligne = 8

      
Dim TableauFiltre(15) As String
Dim NomColonne(15) As String
Dim Index As Integer
Dim DegroupStatut, DegroupType, DegroupNature As Boolean
Index = 1
DegroupStatut = False
DegroupType = False
DegroupNature = False
      
'****** Degroupé par Statut ********************
If Me.ListeStatut.ItemsSelected.Count <> 0 And Check_Degroup_Statut.Value = True Then
    For Each varI In Me!ListeStatut.ItemsSelected
        TableauFiltre(Index) = " and ( staint=" & Trim(Me!ListeStatut.Column(0, varI)) + ")"
        NomColonne(Index) = Trim(Me!ListeStatut.Column(1, varI))
        Index = Index + 1
    Next varI
    DegroupStatut = True
End If

'****** Degroupé par Interv ********************
If Me.LstTypeIntervention.ItemsSelected.Count <> 0 And Check_Degroup_Interv.Value = True Then
    For Each varI In Me!LstTypeIntervention.ItemsSelected
        TableauFiltre(Index) = " and ( typint=""" & Trim(Me!LstTypeIntervention.Column(0, varI)) + """)"
        NomColonne(Index) = Trim(Me!ListeStatut.Column(1, varI))
        Index = Index + 1
    Next varI
    DegroupType = True
End If

'****** Degroupé par Nature/SousType ********************
If Me.ListeNature.ItemsSelected.Count <> 0 And Check_Degroup_Nature.Value = True Then
    For Each varI In Me!ListeNature.ItemsSelected
        TableauFiltre(Index) = " and ( Imprimeepar=" + Trim(Me!ListeNature.Column(0, varI)) + ")"
        NomColonne(Index) = Trim(Me!ListeStatut.Column(1, varI))
        Index = Index + 1
    Next varI
    DegroupNature = True
End If



'2)Recherche de tous les sites correpondant au nom
For i = 1 To 4
    sFiltreNom = ""
    If (i = 1 And Me.Texte18.Value <> "") Then
        sFiltreNom = "and  ( nomsit like '%" + Me.Texte18.Value + "%')"
    End If
    
    If (i = 2 And Me.Texte21.Value <> "") Then
        sFiltreNom = "and  ( nomsit like '%" + Me.Texte21.Value + "%')"
    End If
    
    If (i = 3 And Me.Texte22.Value <> "") Then
        sFiltreNom = "and  ( nomsit like '%" + Me.Texte22.Value + "%')"
    End If
    
    If (i = 4 And Me.Texte23.Value <> "") Then
        sFiltreNom = "and  ( nomsit like '%" + Me.Texte23.Value + "%')"
    End If
    
    If Ligne = 8 Then
        'Données Generiques de la feuille
        objSht.cells(1, 2).Value = Nom_Client
        If (Not IsNull(Me.Annee)) Then
            If Index_mois = 0 Then
                objSht.cells(1, 4).Value = "Année " + Trim(Str(Me.Annee))
            Else
                objSht.cells(1, 4).Value = MonthName(Index_mois) + " " + Trim(Str(Me.Annee))
            End If
        Else
            If Date_Deb <> "" And IsDate(Date_Deb) And Date_Fin <> "" And IsDate(Date_Fin) Then
               objSht.cells(1, 4).Value = "Du " + Format(Date_Deb, "dd/mm/yyyy") + " Au " + Format(Date_Fin, "dd/mm/yyyy")
            End If
        End If
        objSht.cells(2, 1).Value = TexteFiltreInter
        objSht.cells(3, 1).Value = TexteFiltreStatut
        objSht.cells(4, 1).Value = TexteFiltreNature
    End If
    
    If (sFiltreNom <> "") Then
        
        Requete = "Select * from site where " + sFiltreClient + sFiltreNom
        Set ListeSites = db.OpenRecordset(Requete, dbOpenDynaset, dbSeeChanges)
        NbEnreg = ListeSites.RecordCount
            
        If (NbEnreg = 0) Then GoTo suite
       
        Intitule_Ligne = False
        Do Until ListeSites.EOF
            Bloc_Colonne = 0
            Ligne_en_plus = False
            NumeroSite = ListeSites!cptsit
            NomSite = ListeSites!nomsit
            
               
             If DegroupType Or DegroupNature Or DegroupStatut Then
                For j = 1 To Index - 1
                    If DegroupStatut Then
                        sFiltreStatut = TableauFiltre(j)
                    ElseIf DegroupType Then
                        sFiltreInterv = TableauFiltre(j)
                    ElseIf DegroupNature Then
                        sFiltreNature = TableauFiltre(j)
                    End If
                    If Ligne = 8 Then
                        'Nom Colonne
                        objSht.cells(6, Bloc_Colonne * 2 + 2).Value = NomColonne(j)
                    End If
                                    
                    Requete2 = "select Count(numintint) AS QteIntervention , Sum(mntfmc) as Montant from Intervention where cptsit=" + Str(NumeroSite) + sFiltreStatut + sFiltreNature + sFiltreAnnee + sFiltreInterv
                    Set ListeInter = db.OpenRecordset(Requete2, dbOpenDynaset, dbSeeChanges)
                    
                    ListeInter.MoveLast
                    NbEnreg3 = ListeInter.RecordCount
                    If (NbEnreg3 > 0 And ListeInter(0) > 0) Then
                        'Intitulé ligne
                        If (i = 1 And Intitule_Ligne = False) Then
                            objSht.cells(Ligne, 1).Value = Me.Texte18.Value
                            Intitule_Ligne = True
                        End If
                        If (i = 2 And Intitule_Ligne = False) Then
                            objSht.cells(Ligne, 1).Value = Me.Texte21.Value
                            Intitule_Ligne = True
                        End If
                        If (i = 3 And Intitule_Ligne = False) Then
                            objSht.cells(Ligne, 1).Value = Me.Texte22.Value
                            Intitule_Ligne = True
                        End If
                        If (i = 4 And Intitule_Ligne = False) Then
                            objSht.cells(Ligne, 1).Value = Me.Texte23.Value
                            Intitule_Ligne = True
                        End If
                        Ligne_en_plus = True
                            
                        If (Not IsNull(ListeInter!QteIntervention)) Then
                            NbInter(Bloc_Colonne * 2 + 2) = NbInter(Bloc_Colonne * 2 + 2) + ListeInter!QteIntervention
                        End If
                        If (Not IsNull(ListeInter!Montant)) Then
                            TotalInter(Bloc_Colonne * 2 + 3) = TotalInter(Bloc_Colonne * 2 + 3) + ListeInter!Montant
                        End If
                    End If
                    Bloc_Colonne = Bloc_Colonne + 1
                Next j
            Else
                '****** Sans Degroupage ********************
                Requete2 = "select Count(numintint) AS QteIntervention , Sum(mntfmc) as Montant from Intervention where cptsit=" + Str(NumeroSite) + sFiltreStatut + sFiltreNature + sFiltreAnnee + sFiltreInterv
                Set ListeInter = db.OpenRecordset(Requete2, dbOpenDynaset, dbSeeChanges)
                
                ListeInter.MoveLast
                NbEnreg3 = ListeInter.RecordCount
                If (NbEnreg3 > 0 And ListeInter(0) > 0) Then
                    Ligne_en_plus = True
                    With objSht
                        
                        'Intitulé ligne
                        If (i = 1 And Intitule_Ligne = False) Then
                            objSht.cells(Ligne, 1).Value = Me.Texte18.Value
                            Intitule_Ligne = True
                        End If
                        If (i = 2 And Intitule_Ligne = False) Then
                            objSht.cells(Ligne, 1).Value = Me.Texte21.Value
                            Intitule_Ligne = True
                        End If
                        If (i = 3 And Intitule_Ligne = False) Then
                            objSht.cells(Ligne, 1).Value = Me.Texte22.Value
                            Intitule_Ligne = True
                        End If
                        If (i = 4 And Intitule_Ligne = False) Then
                            objSht.cells(Ligne, 1).Value = Me.Texte23.Value
                            Intitule_Ligne = True
                        End If
                        If (Not IsNull(ListeInter!QteIntervention)) Then
                            NbInter(Bloc_Colonne * 2 + 2) = NbInter(Bloc_Colonne * 2 + 2) + ListeInter!QteIntervention
                        End If
                        If (Not IsNull(ListeInter!Montant)) Then
                            TotalInter(Bloc_Colonne * 2 + 3) = TotalInter(Bloc_Colonne * 2 + 3) + ListeInter!Montant
                        End If
                    End With
                End If
            End If
                    
            ListeSites.MoveNext
        Loop
        For k = 0 To Bloc_Colonne + 1
           objSht.cells(Ligne, k * 2 + 2).Value = NbInter(k * 2 + 2)
           objSht.cells(Ligne, k * 2 + 3).Value = TotalInter(k * 2 + 3)
        Next k
        Erase TotalInter
        Erase NbInter
        Ligne = Ligne + 1
    End If
    
suite:
Next

If (Index_mois <> 0 And Me.Mois.Value = 0 And Index_mois < 12) Then
    GoTo Suite_Mois
End If


NomFichier = Replace(Nom_Client, "/", "_")
NomFichier = Replace(NomFichier, "\", "_")
NomFichier = Replace(NomFichier, "'", " ")
'objXL.Visible = True


objWkbk.SaveAs (dossier_dest + "\" + NomFichier + ".xlsx")
'Fermer le fichier et le sauver
objWkbk.Close True
 
'libérer les pointeurs
Set objWkbk = Nothing
Set objXL = Nothing
Screen.MousePointer = 0
End Sub


