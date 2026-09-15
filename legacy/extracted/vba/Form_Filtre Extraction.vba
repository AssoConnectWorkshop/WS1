Attribute VB_Name = "Form_Filtre Extraction"
Attribute VB_Base = "0{8FE25EE9-624A-4221-8CD5-52B134DE8750}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database
Dim Stop_Export As Boolean

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

'27/11/25 AjoutUpdate Banane


UpdateFichierBanane 1
'23/04/21 Module Stat OM
sFiltreClient = ""
sFiltre = ""
sFiltreEntretien = ""
If cboClient.Value <> 0 Then
    Numclient = cboClient
Else
    Exit Sub
End If

Set Repertoire = Application.FileDialog(msoFileDialogFolderPicker)
Repertoire.AllowMultiSelect = False
Repertoire.title = "Merci de Selectionner le repertoire pour le fichier d'export"

If Repertoire.Show = 0 Then
     Exit Sub
Else
    dossier_dest = Repertoire.SelectedItems(1)
End If

Screen.MousePointer = 11

Dim SQL As String
Dim NomSite As String
Dim Nom_Client As String
Dim RedevTech As Double
Dim Requete, Requete2, Requete3, Requete4, Requete5 As String

'1)Recherche donnees client

Requete = "SELECT Client.nomcli, Site.numsit, Site.codsit, Site.nomsit, Site.adrsit, Site.codpossit, Site.vilsit, SiteMateriel.RepereSurSite, SiteMateriel.repere, SiteMateriel.Emplacement, SiteMateriel.Quantite, SiteMateriel.Marque, SiteMateriel.Type, SiteMateriel.Reference, SiteMateriel.NumeroSerie, SiteMateriel.Reversible, SiteMateriel.ResistanceElectrique, SiteMateriel.PuissanceFrigo, SiteMateriel.PuissanceCalo, SiteMateriel.FluideQuantite,"
Requete = Requete + "SiteMateriel.DateMiseEnService, SiteMateriel.TypeTelecommande, SiteMateriel.NbreTelecommande, SiteMateriel.EmplacementTelecommande, SiteMateriel.Disjoncteurs, SiteMateriel.DisjoncteurPrincipal, SiteMateriel.DisjoncteurArmoirePrincipale, SiteMateriel.DisjoncteurCoffretIndependant, SiteMateriel.AccessibiliteGroupe, SiteMateriel.AccessibiliteCassettes, SiteMateriel.SupportGroupes, SiteMateriel.EtatSupports, SiteMateriel.NbreFiltreRoofTop,"
Requete = Requete + "SiteMateriel.ReferenceFiltreRoofTop , SiteMateriel.NbreCourroiesRoofTop, SiteMateriel.ReferenceCourroiesRoofTop, SiteMateriel.AppointChauffageSurRoof, SiteMateriel.NbreAerotherme, SiteMateriel.AerothermeGazElec, SiteMateriel.RideauAir, SiteMateriel.NbreRideauType, SiteMateriel.PuissanceRideau, SiteMateriel.TypeDisjoncteurRideau, SiteMateriel.SasEntree, SiteMateriel.ClimLocauxSociauxEmplacement, SiteMateriel.ClimLocauxSociauxEmplacementGroupeExterieur,"
Requete = Requete + "SiteMateriel.ClimLocauxSociauxMarque, SiteMateriel.ClimLocauxSociauxType, SiteMateriel.ClimLocauxSociauxReference, SiteMateriel.ClimLocauxSociauxNumeroSerie, SiteMateriel.ClimLocauxSociauxDateMiseService, SiteMateriel.ClimLocauxSociauxReversible, SiteMateriel.ClimLocauxSociauxFluideQuantite, SiteMateriel.Radiateurs, SiteMateriel.NbreRadiateurs, SiteMateriel.LocalisationRadiateurs, SiteMateriel.DisjoncteurRadiateursTypeIntensite, "
Requete = Requete + "SiteMateriel.VMC, SiteMateriel.LocalisationVMC, SiteMateriel.Photos, SiteMateriel.RapportsMaintenance, SiteMateriel.DevisEnCours, SiteMateriel.DevisValide, SiteMateriel.ControleEtancheite, SiteMateriel.Observations FROM (Client LEFT JOIN Site ON Client.numcli = Site.numcli) LEFT JOIN SiteMateriel ON Site.cptsit = SiteMateriel.NumeroSite"
Requete = Requete + " WHERE Client.numcli=" + Numclient


'Requete = "Select nomcli,coutheuremainoeuvre,coutdeplacement from client where numcli=" + Numclient
Set db = CurrentDb
Set ListeMatos = db.OpenRecordset(Requete, dbOpenDynaset, dbSeeChanges)

'Pour Test Fersoft
'strCheminFichier = "c:\Fichier_Extraction_Materiel.xlsx"
strCheminFichier = "\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Extraction_Materiel.xlsx"
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
Ligne = 2

Label_Export.Visible = True

ListeMatos.MoveLast
Max = ListeMatos.RecordCount
ListeMatos.MoveFirst

Do Until ListeMatos.EOF
    Label_Export.Caption = Str(Ligne - 2) + "/" + Str(Max)
    DoEvents
    For i = 0 To 64
        If (i = 0) Then
            Nomclient = ListeMatos(i)
        End If
        Temp = ListeMatos(i)
        With objSht
            .cells(Ligne, i + 1).Value = Temp
        End With
    Next i
    Ligne = Ligne + 1
    ListeMatos.MoveNext
    
    If (Stop_Export) Then
        GoTo fin:
    End If
Loop
        
fin:
    Stop_Export = False
   
NomFichier = Replace(Nom_Client, "/", "_")
NomFichier = Replace(NomFichier, "\", "_")
NomFichier = Replace(NomFichier, "'", " ")
'objXL.Visible = True


objWkbk.SaveAs (dossier_dest + "\Materiel_" + Nomclient + ".xlsx")
'Fermer le fichier et le sauver
objWkbk.Close True
 
'libérer les pointeurs
Set objWkbk = Nothing
Set objXL = Nothing
ListeMatos.Close
Screen.MousePointer = 0
UpdateFichierBanane 2
End Sub

Private Sub Commande11_Click()
'****** Filtre Nom ********************
If CocherNom.Value = False Then
    Calcul_Eclate
Else
    Calcul_Nom
End If
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
Client.Close

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


Private Sub Commande40_Click()
Stop_Export = True
End Sub
