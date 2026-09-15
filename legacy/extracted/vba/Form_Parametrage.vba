Attribute VB_Name = "Form_Parametrage"
Attribute VB_Base = "0{EC8E4498-49DD-4F9E-9770-BC17FAEA3F9B}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub CmdAffectionSocieteZone_Click()
    MasquerTout
    Me.ZoneSociete_sous_formulaire.Visible = True
    Me.ZoneSociete_sous_formulaire.Top = 0.4 * 567
    Me.ZoneSociete_sous_formulaire.Left = 4 * 567
    Me.ZoneSociete_sous_formulaire.Width = 24 * 567
    Me.ZoneSociete_sous_formulaire.Height = 22 * 567

End Sub

Private Sub CmdDonneurs_Click()
    MasquerTout
    Me.Donneur_sous_formulaire.Visible = True
    Me.Donneur_sous_formulaire.Top = 0.4 * 567
    Me.Donneur_sous_formulaire.Left = 4 * 567
    Me.Donneur_sous_formulaire.Width = 24 * 567
    Me.Donneur_sous_formulaire.Height = 22 * 567

End Sub

Private Sub CmdFermer_Click()
    DoCmd.Close
End Sub

Private Sub CmdImporter_Click()
   Call Exporter_Audit
End Sub

Private Sub CmdOuvrirIntervenant_Click()
MasquerTout
    Me.Intervenant_sous_formulaire.Visible = True
    Me.Intervenant_sous_formulaire.Top = 0.4 * 567
    Me.Intervenant_sous_formulaire.Left = 4 * 567
    Me.Intervenant_sous_formulaire.Width = 24 * 567
    Me.Intervenant_sous_formulaire.Height = 22 * 567
End Sub

Private Sub CmdOuvrirMarque_Click()
    MasquerTout
    Me.Marque_sous_formulaire.Visible = True
    Me.Marque_sous_formulaire.Top = 0.4 * 567
    Me.Marque_sous_formulaire.Left = 4 * 567
    Me.Marque_sous_formulaire.Width = 24 * 567
    Me.Marque_sous_formulaire.Height = 22 * 567
End Sub

Private Sub CmdOuvrirPanne_Click()
    MasquerTout
    Me.Panne_sous_formulaire.Visible = True
    Me.Panne_sous_formulaire.Top = 0.4 * 567
    Me.Panne_sous_formulaire.Left = 4 * 567
    Me.Panne_sous_formulaire.Width = 24 * 567
    Me.Panne_sous_formulaire.Height = 22 * 567
End Sub

Private Sub CmdOuvrirReference_Click()
    MasquerTout
    Me.Reference_sous_formulaire.Visible = True
    Me.Reference_sous_formulaire.Top = 0.4 * 567
    Me.Reference_sous_formulaire.Left = 4 * 567
    Me.Reference_sous_formulaire.Width = 24 * 567
    Me.Reference_sous_formulaire.Height = 22 * 567
    Commande126.Visible = True
End Sub

Private Sub CmdOuvrirZone_Click()
    MasquerTout
    Me.ZoneGeographique_sous_formulaire.Visible = True
    Me.ZoneGeographique_sous_formulaire.Top = 0.4 * 567
    Me.ZoneGeographique_sous_formulaire.Left = 4 * 567
    Me.ZoneGeographique_sous_formulaire.Width = 24 * 567
    Me.ZoneGeographique_sous_formulaire.Height = 22 * 567
End Sub

Private Sub CmdSociete_Click()
    MasquerTout
    Me.Societe_sous_formulaire.Visible = True
    Me.Societe_sous_formulaire.Top = 0.4 * 567
    Me.Societe_sous_formulaire.Left = 4 * 567
    Me.Societe_sous_formulaire.Width = 24 * 567
    Me.Societe_sous_formulaire.Height = 22 * 567
    
End Sub

Private Sub cmdTypeFluide_Click()
    MasquerTout
    Me.TypeFluide_sous_formulaire.Visible = True
    Me.TypeFluide_sous_formulaire.Top = 0.4 * 567
    Me.TypeFluide_sous_formulaire.Left = 4 * 567
    Me.TypeFluide_sous_formulaire.Width = 24 * 567
    Me.TypeFluide_sous_formulaire.Height = 22 * 567
End Sub

Private Sub cmdUtilisateurs_Click()
MasquerTout
Me.Utilisateur_sous_formulaire.Visible = True
 Me.Utilisateur_sous_formulaire.Top = 0.4 * 567
    Me.Utilisateur_sous_formulaire.Left = 4 * 567
Me.Étiquette156.Visible = True
Me.Commande153.Visible = True
End Sub

Private Sub Commande126_Click()
On Error GoTo Err_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Saisie_Reference"
       
    DoCmd.OpenForm stDocName, , , stLinkCriteria, acFormAdd, acWindowNormal, ""
    Me.Reference_sous_formulaire.Visible = False

Exit_Commande126_Click:
    Exit Sub

Err_Click:
    MsgBox err.Description
    Resume Exit_Commande126_Click
    
End Sub

Private Sub Commande135_Click()
MasquerTout
    Me.SousType.Visible = True
    Me.SousType.Top = 0.4 * 567
    Me.SousType.Left = 4 * 567
    Me.SousType.Width = 24 * 567
    Me.SousType.Height = 22 * 567
End Sub

Private Sub Commande141_Click()
MasquerTout
    Me.Activite_sous_formulaire.Visible = True
    Me.Activite_sous_formulaire.Top = 0.4 * 567
    Me.Activite_sous_formulaire.Left = 4 * 567
    Me.Activite_sous_formulaire.Width = 24 * 567
    Me.Activite_sous_formulaire.Height = 22 * 567
End Sub

Private Sub Commande143_Click()

Rep = MsgBox("Vous allez importer le fichier d'audit!!,,vous etes sure ?,c'est votre dernier mot ?", vbYesNoCancel + vbQuestion, "Avertissement")
    
If (Rep = vbYes) Then

    Set Repertoire = Application.FileDialog(msoFileDialogOpen)
    Repertoire.AllowMultiSelect = False
    Repertoire.title = "Merci de Selectionner le Fichier pour l'import des audits"
    
    If Repertoire.Show = 0 Then
         Exit Sub
    Else
        FichierOri = Repertoire.SelectedItems(1)
    End If
    
    If Right(FichierOri, 4) <> "xlsx" And Right(FichierOri, 3) <> "xls" Then
         MsgBox "Le fichier doit etre forcement un fichier excel", vbCritical, "Erreur"
    Else
        ImportFichierAudit (FichierOri)
    End If
Else
    MsgBox "Une prochaine fois etre...", vbOKOnly + vbExclamation, "Tant Pis"
    
End If

End Sub

Public Sub ImportFichierAudit(strCheminFichier As String)

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
    
    temptoto = 0
    Dim Requete As String
    Dim NbLig As Long
    Dim nomsit As String
    Dim Memo_nomsit As String
    Memo_nomsit = ""
    Dim NumeroSite As Long
    Dim TableData(60) As String
    
    NbLig = 0
    NbLigErr = 0
    With objSht
        For i = 2 To 32000
            'Attention je nesais pas pourquoi la premiere ligne ne passe pas il faut la recopier en Ligne 3 et ce sera ok
            DoEvents
            Me.CptLignes.Visible = True
            Me.CptKo.Visible = True
            Me.CptLignes.Caption = "En Cours OK:" + Str(NbLig)
            Me.CptKo.Caption = "En Cours KO:" + Str(NbLigErr)
            Screen.MousePointer = 11
            NumeroSite = .cells(i, 2).Value
            RepereSurSite = Replace(.cells(i, 3).Value, "'", "''")
            Repere = Replace(.cells(i, 4).Value, "'", "''")
            Emplacement = Replace(.cells(i, 5).Value, "'", "''")
            Quantite = .cells(i, 6).Value
            If IsEmpty(Quantite) Then
                Quantite = "0"
            End If
            Marque = Replace(.cells(i, 7).Value, "'", "''")
            typ = Replace(.cells(i, 8).Value, "'", "''")
            ref = Replace(.cells(i, 9).Value, "'", "''")
            NumSerie = Replace(.cells(i, 10).Value, "'", "''")
            Reversible = Replace(.cells(i, 11).Value, "'", "''")
            ResElec = Replace(.cells(i, 12).Value, "'", "''")
            PuissFrigo = Replace(.cells(i, 13).Value, "'", "''")
            If IsEmpty(PuissFrigo) Or PuissFrigo = "" Then
                PuissFrigo = "0"
            End If
            PuissCalo = .cells(i, 14).Value
            If IsEmpty(PuissCalo) Or PuissCalo = "" Then
                PuissCalo = "0"
            End If
            fluide = Replace(.cells(i, 15).Value, "'", "''")
            DateMES = Replace(.cells(i, 16).Value, "'", "''")
            Type_Tel = Replace(.cells(i, 17).Value, "'", "''")
            Nb_Tel = .cells(i, 18).Value
            If IsEmpty(Nb_Tel) Or Nb_Tel = "" Then
                Nb_Tel = "0"
            End If
            EmplTel = Replace(.cells(i, 19).Value, "'", "''")
            
            For j = 20 To 60
                TableData(j) = Replace(.cells(i, j).Value, "'", "''")
                If (IsEmpty(TableData(j)) Or TableData(j) = "") And (j = 27 Or j = 28 Or j = 30 Or j = 33 Or j = 50) Then
                    TableData(j) = "0"
                End If
                If (j = 35 Or j = 39 Or j = 47 Or j = 49 Or j = 53 Or j = 55) Then
                    If (UCase(TableData(j) = "FAUX")) Then
                        TableData(j) = "0"
                    Else
                        TableData(j) = "1"
                    End If
                End If
                
                
            Next j
                 
            If (NumeroSite = "0") Then
                Exit For
            End If
            
            If (NumeroSite <> -1) Then
                NbLig = NbLig + 1
                'Requete = "INSERT INTO SiteMateriel(Numerosite"
                Requete = "INSERT INTO SiteMateriel(Numerosite,RepereSurSite,Repere,Emplacement,Quantite,Marque,Type,Reference,NumeroSerie,Reversible,ResistanceElectrique,PuissanceFrigo,PuissanceCalo,FluideQuantite,DateMiseEnService,TypeTelecommande,NbreTelecommande,EmplacementTelecommande"
                Requete = Requete + ",Disjoncteurs,DisjoncteurPrincipal,DisjoncteurArmoirePrincipale,DisjoncteurCoffretIndependant,AccessibiliteGroupe,AccessibiliteCassettes,SupportGroupes,EtatSupports,NbreFiltreRoofTop,ReferenceFiltreRoofTop"
                Requete = Requete + ",NbreCourroiesRoofTop,ReferenceCourroiesRoofTop,AppointChauffageSurRoof,NbreAerotherme,AerothermeGazElec"
                Requete = Requete + ",RideauAir,NbreRideauType,PuissanceRideau,TypeDisjoncteurRideau,SasEntree"
                Requete = Requete + ",ClimLocauxSociauxReversible,Radiateurs,NbreRadiateurs,LocalisationRadiateurs,DisjoncteurRadiateursTypeIntensite,VMC,LocalisationVMC,Photos,Observations"
                Requete = Requete + ") VALUES (" + Str(NumeroSite)
                Requete = Requete + ",'" + RepereSurSite + "'"
                Requete = Requete + ",'" + Repere + "'"
                Requete = Requete + ",'" + Emplacement + "'"
                Requete = Requete + "," + Str(Quantite)
                Requete = Requete + ",'" + Marque + "'"
                Requete = Requete + ",'" + typ + "'"
                Requete = Requete + ",'" + ref + "'"
                Requete = Requete + ",'" + NumSerie + "'"
                Requete = Requete + ",'" + Reversible + "'"
                Requete = Requete + ",'" + ResElec + "'"
                Requete = Requete + "," + Str(PuissFrigo)
                Requete = Requete + "," + Str(PuissCalo)
                Requete = Requete + ",'" + fluide + "'"
                Requete = Requete + ",'" + DateMES + "'"
                Requete = Requete + ",'" + Type_Tel + "'"
                Requete = Requete + "," + Str(Nb_Tel)
                Requete = Requete + ",'" + EmplTel + "'"
                Requete = Requete + ",'" + TableData(20) + "'"
                Requete = Requete + ",'" + TableData(21) + "'"
                Requete = Requete + ",'" + TableData(22) + "'"
                Requete = Requete + ",'" + TableData(23) + "'"
                Requete = Requete + ",'" + TableData(24) + "'"
                Requete = Requete + ",'" + TableData(25) + "'"
                Requete = Requete + ",'" + TableData(26) + "'"
                Requete = Requete + "," + Str(TableData(27))
                Requete = Requete + "," + Str(TableData(28))
                Requete = Requete + ",'" + TableData(29) + "'"
                Requete = Requete + "," + Str(TableData(30))
                Requete = Requete + ",'" + TableData(31) + "'"
                Requete = Requete + ",'" + TableData(32) + "'"
                Requete = Requete + "," + Str(TableData(33))
                Requete = Requete + ",'" + TableData(34) + "'"
                Requete = Requete + ",'" + TableData(35) + "'"
                Requete = Requete + ",'" + TableData(36) + "'"
                Requete = Requete + ",'" + TableData(37) + "'"
                Requete = Requete + ",'" + TableData(38) + "'"
                Requete = Requete + ",'" + TableData(39) + "'"
                
                Requete = Requete + ",'" + TableData(47) + "'"
                Requete = Requete + ",'" + TableData(49) + "'"
                Requete = Requete + "," + Str(TableData(50))
                Requete = Requete + ",'" + TableData(51) + "'"
                Requete = Requete + ",'" + TableData(52) + "'"
                Requete = Requete + ",'" + TableData(53) + "'"
                Requete = Requete + ",'" + TableData(54) + "'"
                Requete = Requete + ",'" + TableData(55) + "'"
                Requete = Requete + ",'" + TableData(60) + "')"

                
                            
                CurrentDb.Execute Requete
                If err.Number <> 0 Then
                    NbLigErr = NbLigErr + 1
                    err.Clear
                End If
            Else
                NbLigErr = NbLigErr + 1
            End If
            
            
        Next i
    End With
    
    Me.CptLignes.Visible = False
    Me.CptKo.Visible = False
    'Fermer le fichier et le sauver
    objWkbk.Close True
     
    'libérer les pointeurs
    Set objWkbk = Nothing
    Set objXL = Nothing
    Screen.MousePointer = 0
    MsgBox "Import Audit Terminé de " + Str(NbLig) + " Lignes Avec " + Str(NbLigErr) + "Lignes pas OK", vbInformation, "Information"

End Sub
Public Sub ImportFichierAuditOld(strCheminFichier As String)

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
    
    temptoto = 0
    
    Dim NbLig As Integer
    Dim nomsit As String
    Dim Memo_nomsit As String
    Memo_nomsit = ""
    Dim NumeroSite As Integer
    
    NbLig = 0
    NbLigErr = 0
    With objSht
        For i = 2 To 32000
            Me.CptLignes.Visible = True
            Me.CptKo.Visible = True
            Me.CptLignes.Caption = "En Cours OK:" + Str(NbLig)
            Me.CptKo.Caption = "En Cours KO:" + Str(NbLigErr)
            Screen.MousePointer = 11
            nomsit = .cells(i, 4).Value
            Repere = Replace(.cells(i, 9).Value, "'", "''")
            Emplacement = Replace(.cells(i, 10).Value, "'", "''")
            Quantite = .cells(i, 11).Value
            If IsEmpty(Quantite) Then
                Quantite = "0"
            End If
            Marque = Replace(.cells(i, 12).Value, "'", "''")
            typ = Replace(.cells(i, 13).Value, "'", "''")
            ref = Replace(.cells(i, 14).Value, "'", "''")
            NumSerie = Replace(.cells(i, 15).Value, "'", "''")
            Reversible = Replace(.cells(i, 17).Value, "'", "''")
            ResElec = Replace(.cells(i, 18).Value, "'", "''")
            PuissFrigo = Replace(.cells(i, 19).Value, "'", "''")
            If IsEmpty(PuissFrigo) Or PuissFrigo = "" Then
                PuissFrigo = "0"
            End If
            PuissCalo = .cells(i, 20).Value
            If IsEmpty(PuissCalo) Or PuissCalo = "" Then
                PuissCalo = "0"
            End If
            fluide = Replace(.cells(i, 21).Value, "'", "''")
            DateMES = Replace(.cells(i, 22).Value, "'", "''")
            Type_Tel = Replace(.cells(i, 23).Value, "'", "''")
            Nb_Tel = .cells(i, 24).Value
            If IsEmpty(Nb_Tel) Or Nb_Tel = "" Then
                Nb_Tel = "0"
            End If
            EmplTel = Replace(.cells(i, 25).Value, "'", "''")
            
            If nomsit = "" Then
                Exit For
            End If
            
            If (Memo_nomsit <> nomsit) Then
                NumeroSite = RechercheSite(nomsit)
                Memo_nomsit = nomsit
            End If
            
            If (NumeroSite <> -1) Then
                NbLig = NbLig + 1
                Dim Requete As String
                Requete = "INSERT INTO SiteMateriel(Numerosite,Repere,Emplacement,Quantite,Marque,Type,Reference,NumeroSerie,Reversible,ResistanceElectrique,PuissanceFrigo,PuissanceCalo,FluideQuantite,DateMiseEnService,TypeTelecommande,NbreTelecommande,EmplacementTelecommande) VALUES ("
                Requete = Requete + Str(NumeroSite)
                Requete = Requete + ",'" + Repere + "'"
                Requete = Requete + ",'" + Emplacement + "'"
                Requete = Requete + "," + Str(Quantite)
                Requete = Requete + ",'" + Marque + "'"
                Requete = Requete + ",'" + typ + "'"
                Requete = Requete + ",'" + ref + "'"
                Requete = Requete + ",'" + NumSerie + "'"
                Requete = Requete + ",'" + Reversible + "'"
                Requete = Requete + ",'" + ResElec + "'"
                Requete = Requete + "," + Str(PuissFrigo)
                Requete = Requete + "," + Str(PuissCalo)
                Requete = Requete + ",'" + fluide + "'"
                Requete = Requete + ",'" + DateMES + "'"
                Requete = Requete + ",'" + Type_Tel + "'"
                Requete = Requete + "," + Str(Nb_Tel)
                Requete = Requete + ",'" + EmplTel + "')"
                            
                CurrentDb.Execute Requete
                If err.Number <> 0 Then
                    NbLigErr = NbLigErr + 1
                    err.Clear
                End If
            Else
                NbLigErr = NbLigErr + 1
            End If
            
            
        Next i
    End With
    
    Me.CptLignes.Visible = False
    Me.CptKo.Visible = False
    'Fermer le fichier et le sauver
    objWkbk.Close True
     
    'libérer les pointeurs
    Set objWkbk = Nothing
    Set objXL = Nothing
    Screen.MousePointer = 0
    MsgBox "Import Audit Terminé de " + Str(NbLig) + " Lignes OK et de " + Str(NbLigErr) + "Lignes pas OK", vbInformation, "Information"

End Sub





Public Sub ImportFichierAuditQte(strCheminFichier As String)
    
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
    
    temptoto = 0
    
    Dim NbLig As Integer
    Dim nomsit As String
    Dim Memo_nomsit As String
    Memo_nomsit = ""
    Dim NumeroSite As Integer
    
    NbLig = 0
    NbLigErr = 0
    With objSht
        For i = 2 To 32000
            Me.CptLignes.Visible = True
            Me.CptKo.Visible = True
            Me.CptLignes.Caption = "En Cours OK:" + Str(NbLig)
            Me.CptKo.Caption = "En Cours KO:" + Str(NbLigErr)
            Screen.MousePointer = 11
            Index = .cells(i, 1).Value
            fluide = Replace(.cells(i, 3).Value, "'", "''")
             If IsEmpty(fluide) Then
                fluide = ""
            End If
            Quantite = Replace(.cells(i, 4).Value, "'", "''")
            If IsEmpty(Quantite) Then
                Quantite = "0"
            End If
            If IsNumeric(Quantite) = False Then
                Quantite = "0"
            End If
                                 
            If Index = "" Then
                Exit For
            End If
                      
                NbLig = NbLig + 1
                Dim Requete As String
                Requete = ""
                Requete = "update SiteMateriel SET FluideQuantite='" + fluide + "',nbreradiateurs=" + Str(Quantite)
                Requete = Requete + " where Numerositemateriel=" + Str(Index)
                DoEvents
                CurrentDb.Execute Requete, dbSeeChanges
                If err.Number <> 0 Then
                    NbLigErr = NbLigErr + 1
                    err.Clear
                End If
           
            
            
        Next i
    End With
    
    Me.CptLignes.Visible = False
    Me.CptKo.Visible = False
    'Fermer le fichier et le sauver
    objWkbk.Close True
     
    'libérer les pointeurs
    Set objWkbk = Nothing
    Set objXL = Nothing
    Screen.MousePointer = 0
    MsgBox "Import Audit Terminé de " + Str(NbLig) + " Lignes OK et de " + Str(NbLigErr) + " Lignes pas OK", vbInformation, "Information"

End Sub


Public Function RechercheSite(nomsit As String) As Integer

Dim NumeroSite As Integer
Dim CptNomDonneur As Integer
Dim Site As Recordset
Dim Donneur As Recordset

On Error GoTo Erreur:


Requete = "Select cptsit from site where nomsit='" + Replace(nomsit, "'", "''") + "'"
Set db = CurrentDb
Set Sites = db.OpenRecordset(Requete, dbOpenSnapshot)

NumeroSite = Sites!cptsit

RechercheSite = NumeroSite
Site.Close
SetSite = Nothing
Exit Function

Erreur:
RechercheSite = -1

End Function



Function EnvoiMail(Dest As String, Login As String, MDP As String, Gestionnaire As String) As String
    On Error GoTo Erreur
    Dim MonOutlook As Object
    Dim MonMessage As Object
    Dim Corps As String
    Dim Destinataire As String
 
    Dim EmailApp As Outlook.Application
    Set EmailApp = New Outlook.Application

    Dim EmailItem As Outlook.MailItem
    Set MonMessage = EmailApp.CreateItem(0)
  
    'préparation du message
    Destinataire = Dest
    'Destinataire = "[email-perso-masqué]"
    MonMessage.To = Trim(Destinataire)
 
    MonMessage.Subject = "Changement de mot de passe du site FMC"
    
    TexteGest = ""
    If (Gestionnaire = "1" Or Gestionnaire = "3") Then
        TexteGest = "(Gestionnaire)"
    End If
    
    
    Corps = Corps + "Nouveaux identifiants et mot de passe " + TexteGest + " pour votre accès au site :" + vbCrLf
    Corps = Corps + "https://intervention.fmc-maintenance.fr/interventionstest/Default.aspx?q=1" + vbCrLf + vbCrLf
    Corps = Corps + "Voici vos identifiants:" + vbCrLf
    Corps = Corps + "Login:" + Login + vbCrLf
    Corps = Corps & "Mot de Passe:" + MDP + vbCrLf
    MonMessage.body = Corps
 
    'on envoi le message
    MonMessage.send
 
    'on ferme Outlook
    'Set MonOutlook = Nothing
    EnvoiMail = ""
    Exit Function
Erreur:
    EnvoiMail = Dest + vbCrLf
End Function


Private Sub Commande148_Click()

Rep = MsgBox("Vous allez remplacer les logins et effacer les mots de mot de l'ancien site Web pour les utilisateurs FMC,Etes vous sur ?", vbOKCancel + vbQuestion, "Avertissement")
    
    If (Rep = vbOK) Then
        Dim rs As Recordset
        Set rs = CurrentDb.OpenRecordset("select * from utilisateur where numsoc=1 or numsoc=111 or numsoc=112 or numsoc=113", dbOpenDynaset, dbSeeChanges)
        Do Until rs.EOF
            Num = rs(0)
            Saute = False
            If (IsNull(rs(2)) Or IsNull(rs(1))) Then
                Saute = True
            End If
           
            If (Saute = False) Then
                Login = Left(rs(2), 1) + "." + rs(1)
                Requete = "UPDATE utilisateur SET loguti=""" + Login + """,mdputi="""" WHERE numuti=" + Str(Num)
            Else
                Login = ""
                Requete = "UPDATE utilisateur SET loguti=""" + Login + """ WHERE numuti=" + Str(Num)
                
            End If
            
            CurrentDb.Execute Requete, dbSeeChanges
            
            rs.MoveNext
        Loop
        rs.Close
        Set rs = Nothing
    End If


End Sub

Private Sub Commande150_Click()
Dim Code As String

Rep = MsgBox("Vous allez remplacer les mots de mot de le site Web pour les utilisateurs FMC,Etes vous sur ?", vbOKCancel + vbQuestion, "Avertissement")
    
    If (Rep = vbOK) Then
        Dim rs As Recordset
            Set rs = CurrentDb.OpenRecordset("select * from utilisateur where numsoc=1 or numsoc=111 or numsoc=112 or numsoc=113", dbOpenDynaset, dbSeeChanges)
            Do Until rs.EOF
                Num = rs(0)
                Saute = False
                '1:Nom 2:Prenom 3:Login 10:Mail
                If (IsNull(rs(2)) Or IsNull(rs(1)) Or IsNull(rs(3)) Or IsNull(rs(10))) Then
                    Saute = True
                End If
                
                If (rs(2) = "" Or rs(1) = "" Or rs(3) = "" Or rs(10) = "") Then
                    Saute = True
                End If
                
               
                If (Saute = False) Then
                    Code = RandomCode()
                    Requete = "UPDATE utilisateur SET codintuti=""" + Code + """ WHERE numuti=" + Str(Num)
                Else
                    Code = ""
                    Requete = "UPDATE utilisateur SET codintuti=""" + Code + """ WHERE numuti=" + Str(Num)
                    
                End If
                
                CurrentDb.Execute Requete, dbSeeChanges
                
                rs.MoveNext
            Loop
            rs.Close
            Set rs = Nothing
    End If

End Sub

Public Function RandomCode() As String
    Dim MDP, chaine As String, cpt As Long, dico As Object
    Dim strLettres, strChiffres, strSymboles, faire, lettre As String, chiffre As String, symb As String, ind As Long
    strLettres = Split(StrConv("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", vbUnicode), Chr(0))
    strChiffres = Split(StrConv("0123456789", vbUnicode), Chr(0))
    strSymboles = Split(StrConv("@#!?;.:", vbUnicode), Chr(0))
    Randomize

    Set dico = CreateObject("Scripting.Dictionary")
    NBCarac = 5
    NBChiffre = 2
    NBSymb = 1
        MDP = ""
        chaine = "": faire = dico.RemoveAll()
        '***************************************************
        Do    'boucle pour les caracteres
            lettre = strLettres(Rnd * UBound(strLettres))
            If Not dico.exists(lettre) Then dico(lettre) = "": chaine = chaine & lettre
        Loop Until Len(chaine) >= NBCarac
        '****************************************************
        '******************************************************************
        Do    'boucle pour les chiffres
            chiffre = strChiffres(Rnd * UBound(strChiffres))
            If Not dico.exists(chiffre) Then dico(chiffre) = "": chaine = chaine & chiffre
        Loop Until Len(chaine) >= NBCarac + NBChiffre
        '*******************************************************************
        '******************************************************************************************
        Do    'boucle pour les symboles
            symb$ = strSymboles(Round(Rnd * UBound(strSymboles)))
            If Not dico.exists(symb$) Then dico(symb) = "": chaine = chaine & symb$
        Loop Until Len(chaine) >= NBCarac + NBChiffre + NBSymb
        '******************************************************************************************
        
        Randomize
        Do    ' boucle pour mettre en desordre les carateres
            indice = Int(Len(chaine) * Rnd) + 1
            Caractere = Mid(chaine, indice, 1)
            Gauche = Left(chaine, indice - 1)
            Droite = Right(chaine, Len(chaine) - indice)
            chaine = Gauche + Droite
            MDP = MDP + Caractere
        Loop Until chaine = ""
        '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        '/////////////////////////////////////////////////////////////////////////////////////////////

        RandomCode = MDP
End Function



Private Sub Commande152_Click()
Dim Mess_Err_Mail As String
Rep = MsgBox("Vous allez envoyer un mail avec login/mot de passe à tous les utilisateurs FMC,Etes vous sur ?", vbOKCancel + vbQuestion, "Avertissement")
    
If (Rep = vbOK) Then
    sFiltre = ""
    Mess_Err_Mail = ""
    '****** liste User ********************
    If Me.LstTech.ItemsSelected.Count <> 0 Then
        Dim varI As Variant
        Nb_Occur = 1
        For Each varI In Me!LstTech.ItemsSelected
                If Nb_Occur = 1 Then
                    sFiltre = sFiltre & " and (utilisateur.numuti=" & Me!LstTech.Column(0, varI)
                Else
                    sFiltre = sFiltre & " or utilisateur.numuti=" & Me!LstTech.Column(0, varI)
                End If
                Nb_Occur = Nb_Occur + 1
        Next varI
        sFiltre = sFiltre + ")"
    Else
        If (Me.CocherAll.Value = Unchecked) Then
            GoTo fin:
        End If
    End If

    Dim rs As Recordset
    Dim Nb As Integer
    Set rs = CurrentDb.OpenRecordset("select * from utilisateur where (numsoc=111 or numsoc=112 or numsoc=113 )" + sFiltre, dbOpenDynaset, dbSeeChanges)
    Do Until rs.EOF

        'Excel.Application.Wait (Now + TimeValue("00:00:05"))
    
        Num = rs(0)
        Saute = False
        If (IsNull(rs(3)) Or IsNull(rs(7)) Or IsNull(rs(10))) Then
            Saute = True
        End If
        
        If (rs(3) = "" Or rs(7) = "" Or rs(10) = "") Then
            Saute = True
        End If
        
       
        If (Saute = False) Then
            Mess_Err_Mail = Mess_Err_Mail + EnvoiMail(rs(10), rs(3), rs(7), rs(6))
            Nb = Nb + 1
        End If
        rs.MoveNext
    Loop
    rs.Close
    Set rs = Nothing
    If (Mess_Err_Mail <> "") Then
        MsgBox Str(Nb) + " E-mails envoyés ,avec des erreurs sur les adresses suivantes:" + vbCrLf + Mess_Err_Mail, vbOKOnly + vbCritical, "Information"
    Else
fin:
        MsgBox Str(Nb) + " E-mails envoyés !!", vbOKOnly + vbInformation, "Information"
    End If
End If
End Sub

Private Sub Commande153_Click()
Dim MDP As String
Rep = InputBox("Merci de saisir le mot de passe pour acceder a la gestion des mots de passe utilisateurs", "Mot de passe Super-Gestionnaire")
'65=FM
Set rs = CurrentDb.OpenRecordset("select * from utilisateur where numuti=65", dbOpenDynaset, dbSeeChanges)
    Do Until rs.EOF
        MDP = rs(7) + rs(7)
        rs.MoveNext
    Loop
    rs.Close
    Set rs = Nothing
If (Rep = MDP) Then
    Me.Commande150.Visible = True
    Me.Commande152.Visible = True
    Me.LstTech.Visible = True
    Me.CocherAll.Value = Unchecked
    Me.CocherAll.Visible = True
    Me.Étiquette156.Visible = False
Else
    MsgBox "Mauvais mot de Passe..pas bien :(", vbCritical + vbOKOnly, "ERREUR MDP"
End If

End Sub

Private Sub Commande157_Click()
MasquerTout
Me.FormFact.Visible = True
Me.FormFact.Top = 0.4 * 567
Me.FormFact.Left = 4 * 567
Me.FormFact.Width = 24 * 567
Me.FormFact.Height = 22 * 567
    
If Me.FormFact.Form.AllowEdits = False Then
    Rep = InputBox("Merci de saisir le mot de passe pour permettre la modification de la tables des status Facturations ", "Mot de passe")
    
    Mot_de_passe = "om" + Format(Now, "dd") + Format(Now, "mm")
    
    If Rep = Mot_de_passe Then
        MsgBox "Modification Possible :)", vbInformation, "Mot de Passe Correct"
        Me.FormFact.Form.AllowEdits = True
        Me.FormStatusInterv.Form.AllowEdits = True
        Me.Étiquette164.Visible = True
    Else
        MsgBox "Pas de bon mot de passe ,pas de modification Possible (BestClub JeJeMeMe Choix dans la ..) :(", vbCritical, "Mot de Passe Incorrect"
        Me.FormFact.Form.AllowEdits = False
        Me.FormStatusInterv.Form.AllowEdits = False
    End If
End If
   
End Sub

Private Sub Commande163_Click()
MasquerTout
    Me.FormStatusInterv.Visible = True
    Me.FormStatusInterv.Top = 0.4 * 567
    Me.FormStatusInterv.Left = 4 * 567
    Me.FormStatusInterv.Width = 24 * 567
    Me.FormStatusInterv.Height = 22 * 567
        
If Me.FormStatusInterv.Form.AllowEdits = False Then
    Rep = InputBox("Merci de saisir le mot de passe pour permettre la modification de la tables des status intervention ", "Mot de passe")
    Mot_de_passe = "om" + Format(Now, "dd") + Format(Now, "mm")
    
    If Rep = Mot_de_passe Then
        MsgBox "Modification Possible :)", vbInformation, "Mot de Passe Correct"
        Me.FormFact.Form.AllowEdits = True
        Me.FormStatusInterv.Form.AllowEdits = True
        Me.Étiquette164.Visible = True
    Else
        MsgBox "Pas de bon mot de passe ,pas de modification Possible (BestClub JeJeMeMe Choix dans la ..) :(", vbCritical, "Mot de Passe Incorrect"
        Me.FormStatusInterv.Form.AllowEdits = False
        Me.FormFact.Form.AllowEdits = False
    End If
End If
End Sub

Private Sub Commande165_Click()
    MasquerTout
    Me.Vehicules.Visible = True
    Me.Vehicules.Top = 0.4 * 567
    Me.Vehicules.Left = 4 * 567
    Me.Vehicules.Width = 33 * 567
    Me.Vehicules.Height = 22 * 567
    Me.Étiquette185.Visible = True
End Sub

Private Sub Commande168_Click()
Rep = MsgBox("Pierre Morue ,vous allez importer le fichier d'audit!!,,vous etes sur ?,c'est votre dernier mot ?", vbYesNoCancel + vbQuestion, "Avertissement")
    
If (Rep = vbYes) Then

    Set Repertoire = Application.FileDialog(msoFileDialogOpen)
    Repertoire.AllowMultiSelect = False
    Repertoire.title = "Merci de Selectionner le Fichier pour l'import des audits (Quantite fluide)"
    
    If Repertoire.Show = 0 Then
         Exit Sub
    Else
        FichierOri = Repertoire.SelectedItems(1)
    End If
    
    If Right(FichierOri, 4) <> "xlsx" And Right(FichierOri, 3) <> "xls" Then
         MsgBox "Le fichier doit etre forcement un fichier excel", vbCritical, "Erreur"
    Else
        ImportFichierAuditQte (FichierOri)
    End If
Else
    MsgBox "Une prochaine fois etre...", vbOKOnly + vbExclamation, "Tant Pis"
    
End If
End Sub

Private Sub Commande173_Click()

       
       
       
Dim StringKM As String
Dim Immat As String
Dim Km As String
Dim DateEv As String
Dim NumTech As String

Set RsCodInt = CurrentDb.OpenRecordset("select NomInterv,Numerotech,dateinterv from dbo_HeuresTech where TypeInterv=60", dbOpenDynaset, dbSeeChanges)
    Do Until RsCodInt.EOF
        
        If IsNull(RsCodInt("NomInterv")) = False Then
            DateEv = RsCodInt("dateinterv")
            NumTech = RsCodInt("Numerotech")
            StringKM = RsCodInt("NomInterv")
            Pos = InStr(1, StringKM, "=")
            Km = Right(StringKM, Len(StringKM) - Pos)
            'On enleve les KM
            StringKM = Left(StringKM, Pos - 1)
            'On Cherche l'IMMAT
            Pos = InStr(1, StringKM, ":")
            Immat = Trim(Right(StringKM, Len(StringKM) - Pos))
                       
            SQL = "INSERT INTO dbo_EvVehicules(DateEV,TypeEV,Km,conducteur,Immat) values(#" + DateEv + "#,0," + Km + "," + NumTech + ",'" + Immat + "')"
            CurrentDb.Execute SQL
        End If
        RsCodInt.MoveNext
    Loop

End Sub

Private Sub Commande175_Click()
MasquerTout
    Me.Type_EV_Vehicule_Sous_Form.Visible = True
    Me.Type_EV_Vehicule_Sous_Form.Top = 0.4 * 567
    Me.Type_EV_Vehicule_Sous_Form.Left = 4 * 567
    Me.Type_EV_Vehicule_Sous_Form.Width = 24 * 567
    Me.Type_EV_Vehicule_Sous_Form.Height = 22 * 567
End Sub

Private Sub Commande176_Click()
MasquerTout
    Me.Type_Etat_Vehicule_Sous_Form.Visible = True
    Me.Type_Etat_Vehicule_Sous_Form.Top = 0.4 * 567
    Me.Type_Etat_Vehicule_Sous_Form.Left = 4 * 567
    Me.Type_Etat_Vehicule_Sous_Form.Width = 24 * 567
    Me.Type_Etat_Vehicule_Sous_Form.Height = 22 * 567

End Sub

Private Sub Commande186_Click()
Rep = MsgBox("Pierre Morue ,vous allez importer le fichier d'audit!!,,vous etes sur ?,c'est votre dernier mot ?", vbYesNoCancel + vbQuestion, "Avertissement")
    
If (Rep = vbYes) Then

    Set Repertoire = Application.FileDialog(msoFileDialogOpen)
    Repertoire.AllowMultiSelect = False
    Repertoire.title = "Merci de Selectionner le Fichier pour l'import des audits"
    
    If Repertoire.Show = 0 Then
         Exit Sub
    Else
        FichierOri = Repertoire.SelectedItems(1)
    End If
    
    If Right(FichierOri, 4) <> "xlsx" And Right(FichierOri, 3) <> "xls" Then
         MsgBox "Le fichier doit etre forcement un fichier excel", vbCritical, "Erreur"
    Else
        ImportFichierAuditQte (FichierOri)
    End If
Else
    MsgBox "Une prochaine fois etre...", vbOKOnly + vbExclamation, "Tant Pis"
    
End If
End Sub

Private Sub Commande190_Click()
MasquerTout
    Me.ClassifGaz.Visible = True
    Me.ClassifGaz.Top = 0.4 * 567
    Me.ClassifGaz.Left = 4 * 567
    Me.ClassifGaz.Width = 33 * 567
    Me.ClassifGaz.Height = 22 * 567
    Me.ClassifGaz.Visible = True
End Sub

Private Sub Commande194_Click()
MasquerTout
    Me.TypeInter.Visible = True
    Me.TypeInter.Top = 0.4 * 567
    Me.TypeInter.Left = 4 * 567
    Me.TypeInter.Width = 24 * 567
    Me.TypeInter.Height = 22 * 567
        
If Me.TypeInter.Form.AllowEdits = False Then
    Rep = InputBox("Merci de saisir le mot de passe pour permettre la modification de la tables des types intervention ", "Mot de passe")
    Mot_de_passe = "om" + Format(Now, "dd") + Format(Now, "mm")
    
    If Rep = Mot_de_passe Then
        MsgBox "Modification Possible :)", vbInformation, "Mot de Passe Correct"
        Me.TypeInter.Form.AllowEdits = True
    Else
        MsgBox "Pas de bon mot de passe ,pas de modification Possible (BestClub JeJeMeMe Choix dans la ..) :(", vbCritical, "Mot de Passe Incorrect"
        Me.TypeInter.Form.AllowEdits = False
    End If
End If
End Sub

Private Sub Commande199_Click()
    MasquerTout
    Me.Visites_Maint_Sous_Form.Visible = True
    Me.Visites_Maint_Sous_Form.Top = 0.4 * 567
    Me.Visites_Maint_Sous_Form.Left = 4 * 567
    Me.Visites_Maint_Sous_Form.Width = 24 * 567
    Me.Visites_Maint_Sous_Form.Height = 22 * 567
End Sub

Private Sub Commande35_Click()
    MasquerTout
    Me.Panne_sous_formulaire.Visible = True
    Me.Panne_sous_formulaire.Top = 0.4 * 567
    Me.Panne_sous_formulaire.Left = 4 * 567
    Me.Panne_sous_formulaire.Width = 24 * 567
    Me.Panne_sous_formulaire.Height = 22 * 567
End Sub

Private Sub Commande55_Click()
    MasquerTout
    Me.Repere_Sous_Form.Visible = True
    Me.Repere_Sous_Form.Top = 0.4 * 567
    Me.Repere_Sous_Form.Left = 4 * 567
    Me.Repere_Sous_Form.Width = 24 * 567
    Me.Repere_Sous_Form.Height = 22 * 567
End Sub

Private Sub Commande56_Click()
    MasquerTout
    Me.Type_Telecommande_Sous_Form.Visible = True
    Me.Type_Telecommande_Sous_Form.Top = 0.4 * 567
    Me.Type_Telecommande_Sous_Form.Left = 4 * 567
    Me.Type_Telecommande_Sous_Form.Width = 24 * 567
    Me.Type_Telecommande_Sous_Form.Height = 22 * 567
 
End Sub

Private Sub Commande57_Click()
    MasquerTout
    Me.Reference_sous_formulaire.Visible = True
    Me.Reference_sous_formulaire.Top = 0.4 * 567
    Me.Reference_sous_formulaire.Left = 4 * 567
    Me.Reference_sous_formulaire.Width = 24 * 567
    Me.Reference_sous_formulaire.Height = 22 * 567
    Me.Reference_sous_formulaire.Requery
    Commande126.Visible = True
    Commande143.Visible = True
End Sub

Private Sub Commande58_Click()
 MasquerTout
    Me.Marque_sous_formulaire.Visible = True
    Me.Marque_sous_formulaire.Top = 0.4 * 567
    Me.Marque_sous_formulaire.Left = 4 * 567
    Me.Marque_sous_formulaire.Width = 24 * 567
    Me.Marque_sous_formulaire.Height = 22 * 567
End Sub

Private Sub Commande59_Click()
    MasquerTout
    Me.TypeFluide_sous_formulaire.Visible = True
    Me.TypeFluide_sous_formulaire.Top = 0.4 * 567
    Me.TypeFluide_sous_formulaire.Left = 4 * 567
    Me.TypeFluide_sous_formulaire.Width = 24 * 567
    Me.TypeFluide_sous_formulaire.Height = 22 * 567
End Sub

Private Sub Commande61_Click()
    MasquerTout
    Me.Type_Audit_Sous_Form.Visible = True
    Me.Type_Audit_Sous_Form.Top = 0.4 * 567
    Me.Type_Audit_Sous_Form.Left = 4 * 567
    Me.Type_Audit_Sous_Form.Width = 24 * 567
    Me.Type_Audit_Sous_Form.Height = 22 * 567
End Sub

Private Sub Form_Load()
    MasquerTout
End Sub
Private Sub MasquerTout()
    Me.Visites_Maint_Sous_Form.Visible = False
    Me.ClassifGaz.Visible = False
    Me.Étiquette164.Visible = False
    Me.Étiquette185.Visible = False
    Me.Activite_sous_formulaire.Visible = False
    Me.Donneur_sous_formulaire.Visible = False
    Me.ZoneGeographique_sous_formulaire.Visible = False
    Me.Intervenant_sous_formulaire.Visible = False
    Me.TypeFluide_sous_formulaire.Visible = False
    Me.Marque_sous_formulaire.Visible = False
    Me.Reference_sous_formulaire.Visible = False
    Me.Panne_sous_formulaire.Visible = False
    Me.Utilisateur_sous_formulaire.Visible = False
    Me.Societe_sous_formulaire.Visible = False
    Me.ZoneSociete_sous_formulaire.Visible = False
     Me.Type_Telecommande_Sous_Form.Visible = False
     Me.Repere_Sous_Form.Visible = False
     Me.Type_Audit_Sous_Form.Visible = False
     Me.SousType.Visible = False
     Commande126.Visible = False
     Me.Commande148.Visible = False
     Me.FormFact.Visible = False
Me.Commande150.Visible = False
Me.Commande152.Visible = False
Me.Commande143.Visible = False
Me.LstTech.Visible = False
Me.Étiquette156.Visible = False
Me.CocherAll.Visible = False
Me.FormStatusInterv.Visible = False
Me.Vehicules.Visible = False
Me.Type_EV_Vehicule_Sous_Form.Visible = False
Me.Type_Etat_Vehicule_Sous_Form.Visible = False
Me.TypeInter.Visible = False
End Sub

