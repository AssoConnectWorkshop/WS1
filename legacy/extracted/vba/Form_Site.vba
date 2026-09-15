Attribute VB_Name = "Form_Site"
Attribute VB_Base = "0{DE78DC4C-F172-44FE-B6F4-A67600AD9DBC}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
'22/04/26 Passage en dbOpenSnapshotpour eviter des locks +Traitement de l'affichage des listes avec Where 1=1 FaitOM
Option Compare Database
Dim Old_Num_CLient As String

Private Sub CmdRegenerer_Click()

    On Error GoTo traiterrgenerer
      
    
    If Me!nbrentsit = "" Then
        MsgBox "Merci de saisir le nombre de visite d'entretien pour pouvoir générer le planning prévisionnel."
        Exit Sub
    End If
    
    If Me!numsit <> "" And Me!nbrentsit <> "" And Me!numcli <> "" Then
    
    ' DoCmd.DoMenuItem acFormBar, acRecordsMenu, acSaveRecord, , acMenuVer70
    
    Dim rs As Recordset
    Dim rsInsert As Recordset
    
    Dim RsCodInt As Recordset
    Dim lDatPreInt As Date

    lSQl = "delete from intervention where datintpre is not null and datint is null"
    lSQl = lSQl & " and cptsit = " & Me!cptsit
    CurrentDb.Execute (lSQl)

    lSQl = "Select max(datint) from intervention where cptsit=" & Me!cptsit
    lSQl = lSQl & " and typint='1' and datint is not null"
    lSQl = lSQl & " group by codint "
    lSQl = lSQl & "order by max(datint) DESC"

    
    Set rs = CurrentDb().OpenRecordset(lSQl, dbOpenSnapshot)
    If Not rs.EOF Then
        lDateDepart = rs(0)
        If Year(Date) > Year(lDateDepart) Then
            landernier = True
        Else
            landernier = False
        End If
    Else
        lDateDepart = "15/12/" & (Year(Date) - 1)
        
        
    End If
    lSQl = "SELECT Intervenant.codint "
    lSQl = lSQl & " FROM (ZoneGeographique INNER JOIN Intervenant ON ZoneGeographique.numzon = Intervenant.numzonint) INNER JOIN Site ON ZoneGeographique.numzon = Site.numzonsit "
    lSQl = lSQl & " WHERE (((Site.cptsit)=" & Me!cptsit & "));"
    
    Set RsCodInt = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
    If Not RsCodInt.EOF Then
        lcodint = RsCodInt(0)
    Else
        MsgBox "Il n'y a pas d'intervenant attribué à la zone géographique sélectionnée pour ce site. Aucune intervention ne sera générée.", vbCritical
        Exit Sub
    End If
    RsCodInt.Close
    Set RsCodInt = Nothing
    
    Select Case Me!nbrentsit
    Case 4
        lpassemaine = 13
    Case 6
        lpassemaine = 9
    Case Else
        lpassemaine = Int(52 / Me!nbrentsit)
    End Select
    rs.Close
    Set rs = Nothing
    
    Set rsInsert = CurrentDb.OpenRecordset("intervention", dbOpenDynaset, dbSeeChanges)
    If lDateDepart = "15/12/" & Year(Date) - 1 Then
        lDatPreInt = DateAdd("ww", lpassemaine, lDateDepart)
        unevisitedejafaite = 0
    Else
        lDatPreInt = DateAdd("ww", lpassemaine, lDateDepart)
        If landernier = False Then
            unevisitedejafaite = 1
        End If
    End If
    Dim rsDejaFaite As Recordset
    
    lSQl = "Select count(*) from intervention where datint between #01/01/" & Year(Now()) & "# and #31/12/" & Year(Now()) & "# and typint='1' and staint=9 and cptsit=" & Me!cptsit
    Set rsDejaFaite = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
    If Not rsDejaFaite.EOF Then
        unevisitedejafaite = rsDejaFaite(0)
    End If
    rsDejaFaite.Close
    Set rsDejaFaite = Nothing
    
    For lI = 1 To Me!nbrentsit - unevisitedejafaite
        
        If EstFerie(lDatPreInt) Then
            lDatPreInt = DateAdd("d", -1, lDatPreInt)
        End If
        If Weekday(lDatPreInt) = VbDayOfWeek.vbSaturday Then
            lDatPreInt = DateAdd("d", -1, lDatPreInt)
        End If
        If Weekday(lDatPreInt) = VbDayOfWeek.vbSunday Then
            lDatPreInt = DateAdd("d", 1, lDatPreInt)
        End If
        rsInsert.AddNew
        rsInsert("cptsit") = Me!cptsit
        rsInsert("datintpre") = lDatPreInt
        rsInsert("typint") = "1"
        rsInsert("staint") = 1
        rsInsert("codint") = lcodint
        rsInsert("datheuapp") = Null
        rsInsert.Update
        lDatPreInt = DateAdd("ww", lpassemaine, lDatPreInt)
    
    Next
    
    rsInsert.Close
    Set rsInsert = Nothing
    'DoCmd.DoMenuItem acFormBar, acRecordsMenu, 5, , acMenuVer70
    Me.Site_Sous_formulaire_sous_formulaire.Requery
    
    End If
    
TraitErrGenererOff:
    Exit Sub
    
traiterrgenerer:

    MsgBox err.Number & " " & err.Description
    Resume TraitErrGenererOff
     Select Case err.Number
        Case 3151
            Resume
        Case Else
            MsgBox err.Number & " " & err.Description
            DoCmd.Hourglass False
            Exit Sub
    End Select

End Sub



Private Sub CmdFermer_Click()
On Error GoTo Err_CmdFermer_Click


    If Me.Dirty Then Me.Dirty = False
    
    If IsNull(Me.latitude) Or IsNull(Me.longitude) Then
        If MsgBox("La géolocalisation est vide, confirmez-vous la sortie", vbOKCancel, "Pas de géolocalisation pour ce site") = vbOK Then
            DoCmd.Close
        End If
    Else
        DoCmd.Close
    End If
    

Exit_CmdFermer_Click:
    Exit Sub

Err_CmdFermer_Click:
    MsgBox err.Description
    Resume Exit_CmdFermer_Click
    
End Sub

Private Sub Controle_Intervenir()
'16/04/21 OM
If Me.CochePasIntervenir.Value = True Then
    Me.ImgPasInterven.Visible = True
    Me.Section(0).BackColor = RGB(255, 0, 0)
Else
    Me.ImgPasInterven.Visible = False
    'Pour passer en blanc il faut les 2 OK
    If Me.CocheRetard.Value = False Then
        Me.Section(0).BackColor = RGB(255, 255, 255)
    End If
End If

End Sub

Private Sub Controle_Retard()
'16/04/210 OM
If Me.CocheRetard.Value = True Then
    Me.ImgProbPaiement.Visible = True
    Me.Section(0).BackColor = RGB(255, 0, 0)
Else
    Me.ImgProbPaiement.Visible = False
    'Pour passer en blanc il faut les 2 OK
    If Me.CochePasIntervenir.Value = False Then
        Me.Section(0).BackColor = RGB(255, 255, 255)
    End If
End If

End Sub

Private Sub CochePasIntervenir_Click()

'16/04/21 OM
If Me.CochePasIntervenir.Value = True Then
    Rep = MsgBox("Attention,Vous allez faire passer toutes les intervention en cours au statut 'Ne plus intervenir', (Pensez à noter leur statut precedent avnt de faire cette action), Confirmez vous?", vbExclamation + vbYesNo, "Confirmation")
    If Rep = vbNo Then
        Me.CochePasIntervenir.Value = False
        Exit Sub
    End If
    Me.ImgPasInterven.Visible = True
    Gestion_Ne_Pas_Intervenir (True)
    '-1 Entete 0 detail 1 pied de page
    Me.Section(0).BackColor = RGB(255, 0, 0)
Else
    If (Kadi_Logge = True) Then
        Rep = MsgBox("Attention,Vous allez faire passer les intervention du statut 'Ne plus intervenir' au statut 'à planifier' ,Confirmez vous?", vbExclamation + vbYesNo, "Confirmation")
        If Rep = vbNo Then
            Me.CochePasIntervenir.Value = True
            Exit Sub
        End If
        Me.ImgPasInterven.Visible = False
        Gestion_Ne_Pas_Intervenir (False)
        'Pour passer en blanc il faut les 2 OK
        If Me.CocheRetard.Value = False Then
            Me.Section(0).BackColor = RGB(255, 255, 255)
        End If
    Else
        Rep = MsgBox("Attention,Vous n'etes pas autorisé a faire cette modification", vbExclamation, "Login Necessaire")
        Me.CochePasIntervenir.Value = True
    End If
End If

End Sub
Private Sub Gestion_Ne_Pas_Intervenir(Sens As Boolean)
Dim Type_Inter As Integer
Dim Condition As String
'Recherche des interventions
If IsNull(Me.cptsit) Then Exit Sub
If Me.cptsit = "" Then Exit Sub
'Changement des status pour chaque intervention
If (Sens = True) Then
    Type_Inter = 17
    Condition = " (staint=-1 or staint=1 or staint=9)"
Else
    Type_Inter = 1
    Condition = "(staint=17)"
End If
Requete = "UPDATE Intervention SET staint=" + Str(Type_Inter) + " WHERE cptsit=" & Str(Me.cptsit) + " and " + Condition
CurrentDb.Execute Requete, dbSeeChanges
End Sub


Private Sub CocheRetard_AfterUpdate()
Controle_Retard

End Sub
Private Sub Gestion_Affiche_Prix()
If CocherPrix.Value = True Then
    Me.Tarifs_MO_et_DP.Visible = False
    Me.texteMO.Visible = True
    Me.LabelMO.Visible = True
    Me.LabelDepl.Visible = True
    Me.TexteDepl.Visible = True
Else
    Me.Tarifs_MO_et_DP.Visible = True
    Me.texteMO.Visible = False
    Me.LabelMO.Visible = False
    Me.LabelDepl.Visible = False
    Me.TexteDepl.Visible = False
End If
End Sub


Private Sub CocherPrix_AfterUpdate()
    Gestion_Affiche_Prix
End Sub

Private Sub Commande143_Click()
Rep = MsgBox("Vous allez importer le fichier d'audit!!,,vous etes sur(e) ?,c'est votre dernier mot ?", vbYesNoCancel + vbQuestion, "Avertissement")
    
If (Rep = vbYes) Then

    Set Repertoire = Application.FileDialog(msoFileDialogOpen)
    Repertoire.AllowMultiSelect = False
    Repertoire.title = "Merci de Selectionner le Fichier pour l'import des audits"
    
    If Repertoire.Show = 0 Then
         Exit Sub
    Else
        FichierOri = Repertoire.SelectedItems(1)
    End If
    toto = Right(FichierOri, 18)
    If (Right(FichierOri, 18) <> "Fichier_Audit.xlsx") Then
         MsgBox "Le fichier choisi doit etre: Fichier_Audit.xlsx", vbCritical, "Erreur"
    Else
        ImportFichierAuditSite (FichierOri)
    End If
Else
    MsgBox "Une prochaine fois etre...", vbOKOnly + vbExclamation, "Tant Pis"
    
End If
End Sub
Public Sub ImportFichierAuditSite(strCheminFichier As String)

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
        For i = 3 To 32000
            'Attention je ne sais pas pourquoi la premiere ligne ne passe pas il faut la recopier en Ligne 3 et ce sera ok
            DoEvents
            Screen.MousePointer = 11
            NumeroSite = Me.cptsit
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
            
            'Si marque et reference Vide on considere que c'est fini
            If (Marque = "" And ref = "") Then
                Exit For
            End If
                 
            If (NumeroSite = "0") Then
                Exit For
            End If
            
            If (NumeroSite <> -1) Then
                NbLig = NbLig + 1
                'Requete = "INSERT INTO SiteMateriel(Numerosite"
                Requete = "INSERT INTO SiteMateriel(Numerosite,RepereSurSite,Repere,Emplacement,NbreRadiateurs,Marque,Type,Reference,NumeroSerie,Reversible,ResistanceElectrique,PuissanceFrigo,PuissanceCalo,FluideQuantite,DateMiseEnService,TypeTelecommande,NbreTelecommande,EmplacementTelecommande,Quantite"
                'Requete = Requete + ",Disjoncteurs,DisjoncteurPrincipal,DisjoncteurArmoirePrincipale,DisjoncteurCoffretIndependant,AccessibiliteGroupe,AccessibiliteCassettes,SupportGroupes,EtatSupports,NbreFiltreRoofTop,ReferenceFiltreRoofTop"
                'Requete = Requete + ",NbreCourroiesRoofTop,ReferenceCourroiesRoofTop,AppointChauffageSurRoof,NbreAerotherme,AerothermeGazElec"
                'Requete = Requete + ",RideauAir,NbreRideauType,PuissanceRideau,TypeDisjoncteurRideau,SasEntree"
                'Requete = Requete + ",ClimLocauxSociauxReversible,Radiateurs,NbreRadiateurs,LocalisationRadiateurs,DisjoncteurRadiateursTypeIntensite,VMC,LocalisationVMC,Photos,Observations"
                Requete = Requete + ") VALUES (" + Str(NumeroSite)
                Requete = Requete + ",'" + RepereSurSite + "'"
                Requete = Requete + ",'" + Trim(Repere) + "'"
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
                Requete = Requete + ",'" + EmplTel + "','1')"
                           
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
    
    'Fermer le fichier et le sauver
    objWkbk.Close True
     
    'libérer les pointeurs
    Set objWkbk = Nothing
    Set objXL = Nothing
    Screen.MousePointer = 0
    MsgBox "Import Audit Terminé de " + Str(NbLig) + " Lignes OK avec " + Str(NbLigErr) + " Lignes pas OK", vbInformation, "Information"

End Sub

Private Sub Commande314_Click()
'25/06/20 Ajout Automatique OM
Dim i As Integer
Dim Requete  As String
Dim Requete2 As String
Dim Requete3 As String
Dim Requete4 As String

If (Me.NB1 = "" Or IsNull(Me.NB1) Or (IsNumeric(Me.NB1) = False)) Then
    MsgBox "Ajout Impossible,Veuilllez verifier le nombre de la reference 1"
    Exit Sub
End If
If (Me.Ref1 = "" Or IsNull(Me.Ref1)) Then
    MsgBox "Ajout Impossible,Veuilllez verifier la reference 1"
    Exit Sub
End If

'Recherche Data Ref1
Set Data_Ref = CurrentDb().OpenRecordset("Select * from Reference where id =" & Me.Ref1, dbOpenSnapshot)
If Not Data_Ref.EOF Then
    'Insertion des lignes
    '10/05/23 Fluide et quantité dans 2 colonnes diff
    For i = 1 To Int(Me.NB1)
        Requete = "INSERT INTO SiteMateriel (Reference,Repere,Type,Marque,FluideQuantite,NbreRadiateurs,TypeTelecommande,Reversible,ResistanceElectrique,PuissanceFrigo,PuissanceCalo,NbreFiltreRoofTop,ReferenceFiltreRoofTop,NbreCourroiesRoofTop,ReferenceCourroiesRoofTop,AppointChauffageSurRoof,NumeroSite,Quantite) VALUES ("
        Requete2 = "'" & Trim(Data_Ref(1)) & "','" & Trim(Data_Ref(2)) & "','" & Trim(Data_Ref(3)) & "','" & Trim(Data_Ref(4)) & "','" & Trim(Data_Ref(5)) & "','" & Trim(Data_Ref(11)) & "','" & Trim(Data_Ref(6)) & "','" & Trim(Data_Ref(7)) & "','" & Trim(Data_Ref(8)) & "'," & Trim(Data_Ref(9)) & "," & Trim(Data_Ref(10))
        Requete3 = ",'" & Trim(Data_Ref(12)) & "','" & Trim(Data_Ref(13)) & "','" & Trim(Data_Ref(14)) & "','" & Trim(Data_Ref(15)) & "','" & Trim(Data_Ref(16)) & "'," & Trim(Me.cptsit) & ",1)"
        CurrentDb.Execute Requete + Requete2 + Requete3
    Next i
    'Maj Tableau
    Me.SiteMateriel_sous_formulaire.Requery
End If
Data_Ref.Close
Set Data_Ref = Nothing


End Sub

Private Sub Commande319_Click()
'25/06/20 Ajout Automatique OM
Dim i As Integer
Dim Requete  As String
Dim Requete2 As String
Dim Requete3 As String
Dim Requete4 As String

If (Me.NB2 = "" Or IsNull(Me.NB2) Or (IsNumeric(Me.NB2) = False)) Then
    MsgBox "Ajout Impossible,Veuilllez verifier le nombre de la reference 2"
    Exit Sub
End If
If (Me.Ref2 = "" Or IsNull(Me.Ref2)) Then
    MsgBox "Ajout Impossible,Veuilllez verifier la reference 1"
    Exit Sub
End If

'Recherche Data Ref2
Set Data_Ref = CurrentDb().OpenRecordset("Select * from Reference where id =" & Me.Ref2, dbOpenSnapshot)
If Not Data_Ref.EOF Then
    'Insertion des lignes
    '10/05/23 Fluide et quantité dans 2 colonnes diff
    For i = 1 To Int(Me.NB2)
        Requete = "INSERT INTO SiteMateriel (Reference,Repere,Type,Marque,FluideQuantite,NbreRadiateurs,TypeTelecommande,Reversible,ResistanceElectrique,PuissanceFrigo,PuissanceCalo,NbreFiltreRoofTop,ReferenceFiltreRoofTop,NbreCourroiesRoofTop,ReferenceCourroiesRoofTop,AppointChauffageSurRoof,NumeroSite,Quantite) VALUES ("
        Requete2 = "'" & Trim(Data_Ref(1)) & "','" & Trim(Data_Ref(2)) & "','" & Trim(Data_Ref(3)) & "','" & Trim(Data_Ref(4)) & "','" & Trim(Data_Ref(5)) & "','" & Trim(Data_Ref(11)) & "','" & Trim(Data_Ref(6)) & "','" & Trim(Data_Ref(7)) & "','" & Trim(Data_Ref(8)) & "'," & Trim(Data_Ref(9)) & "," & Trim(Data_Ref(10))
        Requete3 = ",'" & Trim(Data_Ref(12)) & "','" & Trim(Data_Ref(13)) & "','" & Trim(Data_Ref(14)) & "','" & Trim(Data_Ref(15)) & "','" & Trim(Data_Ref(16)) & "'," & Trim(Me.cptsit) & ",1)"
        CurrentDb.Execute Requete + Requete2 + Requete3
    Next i
    'Maj Tableau
    Me.SiteMateriel_sous_formulaire.Requery
End If
Data_Ref.Close
Set Data_Ref = Nothing
End Sub

Private Sub Commande325_Click()
'25/06/20 Ajout Automatique OM

Dim i As Integer
Dim Requete  As String
Dim Requete2 As String
Dim Requete3 As String
Dim Requete4 As String

If (Me.Ref1 = "" Or IsNull(Me.Ref1)) Then
    MsgBox "Ajout Impossible,Veuilllez verifier la reference 1"
    Exit Sub
End If

If (Me.NB3 = "" Or IsNull(Me.NB3) Or (IsNumeric(Me.NB3) = False)) Then
    MsgBox "Ajout Impossible,Veuilllez verifier le nombre de la reference 1+2"
    Exit Sub
End If
If (Me.Ref2 = "" Or IsNull(Me.Ref2)) Then
    MsgBox "Ajout Impossible,Veuilllez verifier la reference 2"
    Exit Sub
End If

'Recherche Data Ref1 et 2
Set Data_Ref1 = CurrentDb().OpenRecordset("Select * from Reference where id =" & Me.Ref1, dbOpenSnapshot)
Set Data_Ref2 = CurrentDb().OpenRecordset("Select * from Reference where id =" & Me.Ref2, dbOpenSnapshot)

If (Data_Ref1.RecordCount <> 0 And Data_Ref2.RecordCount <> 0) Then
    'Insertion des lignes Ref1
    '10/05/23 Fluide et quantité dans 2 colonnes diff
    For i = 1 To Int(Me.NB3)
        Requete = "INSERT INTO SiteMateriel (Reference,Repere,Type,Marque,FluideQuantite,NbreRadiateurs,TypeTelecommande,Reversible,ResistanceElectrique,PuissanceFrigo,PuissanceCalo,NbreFiltreRoofTop,ReferenceFiltreRoofTop,NbreCourroiesRoofTop,ReferenceCourroiesRoofTop,AppointChauffageSurRoof,NumeroSite,Quantite) VALUES ("
        Requete2 = "'" & Trim(Data_Ref1(1)) & "','" & Trim(Data_Ref1(2)) & "','" & Trim(Data_Ref1(3)) & "','" & Trim(Data_Ref1(4)) & "','" & Trim(Data_Ref1(5)) & "','" & Trim(Data_Ref1(11)) & "','" & Trim(Data_Ref1(6)) & "','" & Trim(Data_Ref1(7)) & "','" & Trim(Data_Ref1(8)) & "'," & Trim(Data_Ref1(9)) & "," & Trim(Data_Ref1(10))
        Requete3 = ",'" & Trim(Data_Ref1(12)) & "','" & Trim(Data_Ref1(13)) & "','" & Trim(Data_Ref1(14)) & "','" & Trim(Data_Ref1(15)) & "','" & Trim(Data_Ref1(16)) & "'," & Trim(Me.cptsit) & ",1)"
        CurrentDb.Execute Requete + Requete2 + Requete3
        
        Requete = "INSERT INTO SiteMateriel (Reference,Repere,Type,Marque,FluideQuantite,NbreRadiateurs,TypeTelecommande,Reversible,ResistanceElectrique,PuissanceFrigo,PuissanceCalo,NbreFiltreRoofTop,ReferenceFiltreRoofTop,NbreCourroiesRoofTop,ReferenceCourroiesRoofTop,AppointChauffageSurRoof,NumeroSite,Quantite) VALUES ("
        Requete2 = "'" & Trim(Data_Ref2(1)) & "','" & Trim(Data_Ref2(2)) & "','" & Trim(Data_Ref2(3)) & "','" & Trim(Data_Ref2(4)) & "','" & Trim(Data_Ref2(5)) & "','" & Trim(Data_Ref2(11)) & "','" & Trim(Data_Ref2(6)) & "','" & Trim(Data_Ref2(7)) & "','" & Trim(Data_Ref2(8)) & "'," & Trim(Data_Ref2(9)) & "," & Trim(Data_Ref2(10))
        Requete3 = ",'" & Trim(Data_Ref2(12)) & "','" & Trim(Data_Ref2(13)) & "','" & Trim(Data_Ref2(14)) & "','" & Trim(Data_Ref2(15)) & "','" & Trim(Data_Ref2(16)) & "'," & Trim(Me.cptsit) & ",1)"
        CurrentDb.Execute Requete + Requete2 + Requete3
        
    Next i

    'Maj Tableau
    Me.SiteMateriel_sous_formulaire.Requery
End If
Data_Ref1.Close
Set Data_Ref1 = Nothing
Data_Ref2.Close
Set Data_Ref2 = Nothing

End Sub

Private Sub Commande336_Click()
    On Error GoTo Err_imgParametrage_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Parametrage"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_imgParametrage_Click:
    Exit Sub

Err_imgParametrage_Click:
    MsgBox err.Description
    Resume Exit_imgParametrage_Click

End Sub

Private Sub Commande393_Click()
Renseigner_Tech
End Sub
Private Sub Renseigner_Tech()
Dim Data_Ref0 As Recordset
Dim Data_Ref1 As Recordset
Dim Data_Ref2 As Recordset
Dim Noms As String
Dim Prenom As String
Dim i As Integer

'Recherche des interventions
If IsNull(Me.cptsit) Then Exit Sub
If Me.cptsit = "" Then Exit Sub
Requete = "SELECT numintint  FROM intervention WHERE cptsit=" & Me.cptsit
'Close Recordset Fait
Set Data_Ref0 = CurrentDb().OpenRecordset(Requete, dbOpenSnapshot)
If (Data_Ref0.RecordCount = 0) Then Exit Sub
Do Until Data_Ref0.EOF
    'Recherche des intervenant pour chaque intervention
    If IsNull(Data_Ref0(0)) Then Exit Sub
    If Data_Ref0(0) = "" Then Exit Sub
    Requete = "SELECT numuti  FROM interventiontechnicien WHERE numintint=" & Data_Ref0(0)
    'Close Recordset Fait
    Set Data_Ref2 = CurrentDb().OpenRecordset(Requete, dbOpenSnapshot)
    If (Data_Ref2.RecordCount <> 0) Then
        i = 0
        Do Until Data_Ref2.EOF
            Requete = "SELECT nomuti, preuti  FROM Utilisateur WHERE numuti=" & Data_Ref2(0)
            'Recherche Nom Prenom pour l'intervention concernée
            'Close Recordset Fait
            Set Data_Ref1 = CurrentDb().OpenRecordset(Requete, dbOpenSnapshot)
            If (Data_Ref1.RecordCount <> 0) Then
                If IsNull(Data_Ref1(1)) Then
                    Prenom = ""
                Else
                    Prenom = " " + Data_Ref1(1)
                End If
                    
                If i = 0 Then
                    Noms = Data_Ref1(0) + Prenom
                Else
                    Noms = Noms + "," + Data_Ref1(0) + Prenom
                End If
                i = i + 1
                Data_Ref1.Close
            End If
            Data_Ref2.MoveNext
        Loop
        Data_Ref2.Close
        Set Data_Ref2 = Nothing
        Noms = Left(Noms, 50)
        Requete = "UPDATE Intervention SET numdevpartenaire='" + Noms + "' WHERE numintint=" & Data_Ref0(0)
        CurrentDb.Execute Requete, dbSeeChanges
    End If
    Data_Ref0.MoveNext
Loop
Data_Ref0.Close
Set Data_Ref0 = Nothing
End Sub


Private Sub Commande402_Click()
PDFCE.Creation_PDF_CE (Me.cptsit)
End Sub

Private Sub Commande462_Click()
On Error GoTo Err_CmdAddIntervention_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Intervention"
       
    DoCmd.OpenForm stDocName, , , stLinkCriteria, acFormAdd, acWindowNormal, Me.cptsit & ";" & Me.numcli & ";" & Me.numintervenant & ";ResTel"

Exit_CmdAddIntervention_Click:
    Exit Sub

Err_CmdAddIntervention_Click:
    MsgBox err.Description
    Resume Exit_CmdAddIntervention_Click
    
End Sub

Private Sub fermeture_Click()
'22/06 On fait suivre aussi les contrat si on clique sur magasin ferme
'      368 =client ferme
Dim Requete As String

If Me.fermeture And numcli <> 368 Then
    '12/01/24 Ajout confirmation OM
    Rep = MsgBox("Etes vous sur de vouloir cloturer le site ? Cela va changer le nom du client ,si oui pensez à le noter avant", vbYesNoCancel + vbCritical, "Confirmation")
    If (Rep = vbYes) Then
        Requete = "Update devis set NumeroClient =368 where NumeroClient =" + Str(Me![numcli]) + " and NumeroSite=" + Str(Me![cptsit])
        CurrentDb.Execute Requete
        Requete = "Update ContratDeMaintenance set NumeroClient  =368 where NumeroClient =" + Str(Me![numcli]) + " and NumeroSite=" + Str(Me![cptsit])
        CurrentDb.Execute Requete
        Requete = "Update DevisTravaux set NumeroClient =368 where NumeroClient =" + Str(Me![numcli]) + " and NumeroSite=" + Str(Me![cptsit])
        CurrentDb.Execute Requete
    Me.numcli = 368
    Else
        Me.fermeture = 0
    End If
End If
    
End Sub
Public Function Calcul_Affiche_Garantie(CptSite As String) As Boolean
'16/04/21 creation OM
'19/08/25 Passage en fonction car utilisé ailleurs OM
Dim DateMSE As Date
Dim Intervalle_Jour As Integer
Dim Requete As String
Dim Trouve As Boolean
Requete = "Select datemiseenservicesite,garantiecompresseur,garantiepieces,garantiepiecesmainoeuvre from site where cptsit =" & CptSite
Set Data_Ref = CurrentDb().OpenRecordset(Requete, dbOpenSnapshot)

Trouve = False
If IsNull(Data_Ref(0)) = False Then
    DateMSE = Data_Ref(0)
    Intervalle_Jour = DateDiff("d", DateMSE, DateTime.Now)
    If IsNull(Data_Ref(1)) = False Then
        If (Intervalle_Jour < Data_Ref(1) * 365) Then
            Me.ÉtiquetteGarantirCompr.Visible = True
            Trouve = True
        Else
            Me.ÉtiquetteGarantirCompr.Visible = False
        End If
    Else
        Me.ÉtiquetteGarantirCompr.Visible = False
    End If
    
    If IsNull(Data_Ref(2)) = False Then
        If (Intervalle_Jour < Data_Ref(2) * 365) Then
            Me.ÉtiquetteGarantiePieces.Visible = True
            Trouve = True
        Else
            Me.ÉtiquetteGarantiePieces.Visible = False
        End If
    Else
        Me.ÉtiquetteGarantiePieces.Visible = False
    End If
    
    If IsNull(Data_Ref(3)) = False Then
        If (Intervalle_Jour < Data_Ref(3) * 365) Then
            Me.ÉtiquetteGarantieMO.Visible = True
            Trouve = True
        Else
            Me.ÉtiquetteGarantieMO.Visible = False
        End If
    Else
        Me.ÉtiquetteGarantieMO.Visible = False
    End If
Else
    Me.ÉtiquetteGarantieMO.Visible = False
    Me.ÉtiquetteGarantiePieces.Visible = False
    Me.ÉtiquetteGarantirCompr.Visible = False
End If

If Trouve = True Then
    Me.ImageGarantie.Visible = True
    Calcul_Affiche_Garantie = True
Else
    Me.ImageGarantie.Visible = False
    Calcul_Affiche_Garantie = False
End If

Data_Ref.Close
Set Data_Ref = Nothing
End Function




Private Sub Form_Activate()
'09/04/21 creation OM
Dim Requete As String
Dim Trouve As Boolean



If IsNull(Me.cptsit) Then
    EtiquetteContratEnCours.Visible = False
    EtiquetteDevisEnCours.Visible = False
    EtiquetteDevisTravauxEnCours.Visible = False
    ImgDevisEnCours.Visible = False
    Me.ÉtiquetteGarantieMO.Visible = False
    Me.ÉtiquetteGarantiePieces.Visible = False
    Me.ÉtiquetteGarantirCompr.Visible = False
    Me.ImageGarantie.Visible = False
    Exit Sub
End If

Calcul_Affiche_Garantie (Me.cptsit)

Requete = "Select * from Devis where numerosite =" & Me.cptsit & " and ( StatutDevis=4 or StatutDevis=2 or StatutDevis=1)"
Set Data_Ref = CurrentDb().OpenRecordset(Requete, dbOpenSnapshot)
If Data_Ref.RecordCount > 0 Then
    Trouve = True
    EtiquetteDevisEnCours.Visible = True
Else
    EtiquetteDevisEnCours.Visible = False
End If
Data_Ref.Close
Set Data_Ref = Nothing

Requete = "Select * from DevisTravaux where numerosite =" & Me.cptsit & " and ( StatutDevis=4 or StatutDevis=2 or StatutDevis=1)"
Set Data_Ref = CurrentDb().OpenRecordset(Requete, dbOpenSnapshot)
If Data_Ref.RecordCount > 0 Then
    Trouve = True
    EtiquetteDevisTravauxEnCours.Visible = True
Else
    EtiquetteDevisTravauxEnCours.Visible = False
End If
Data_Ref.Close
Set Data_Ref = Nothing

Requete = "Select * from ContratDeMaintenance where numerosite =" & Me.cptsit & " and ( StatutDevis=4 or StatutDevis=2 or StatutDevis=1)"
Set Data_Ref = CurrentDb().OpenRecordset(Requete, dbOpenSnapshot)
If Data_Ref.RecordCount > 0 Then
    Trouve = True
    EtiquetteContratEnCours.Visible = True
Else
    EtiquetteContratEnCours.Visible = False
End If
Data_Ref.Close
Set Data_Ref = Nothing

Gestion_Affiche_Prix


If Trouve Then
    ImgDevisEnCours.Visible = True
Else
    ImgDevisEnCours.Visible = False
End If

'27/11/25 Ajout des 2 fonctions pour remplir automatiquement les Tech
'Renseigner_Tech
'DoCmd.RunCommand acCmdRefresh

End Sub

Private Sub Form_AfterUpdate()
 toto = 1
End Sub

Private Sub Form_Current()


Me.Site_Sous_formulaire_sous_formulaire.Requery
'27/01/25 Ajout du filtre pour eviter de charger toutes les inter OM
If IsNull(Me.cptsit) = False Then
    Me.Site_Sous_formulaire_sous_formulaire_2.Form.Filter = "Cptsit=" + Str(Me.cptsit)
    Me.Site_Sous_formulaire_sous_formulaire_2.Form.FilterOn = True
End If
Me.Site_Sous_formulaire_sous_formulaire_2.Requery

Me.lblSite.Caption = "Site : " & UCase(Me.nomsit) & " - Ville : " & UCase(Me.vilsit)

AfficherImgGeoloc

Me.tpInterventions.Width = Me.WindowWidth
Me.Site_Sous_formulaire_sous_formulaire.Width = Me.WindowWidth - 800
Me.Site_Sous_formulaire_sous_formulaire_2.Width = Me.WindowWidth - 800
Me.SiteMateriel_sous_formulaire.Width = Me.WindowWidth - 800
ControleCE
RechercheNumEsa (Me.numcli)
End Sub
Private Sub AfficherImgGeoloc()

If IsNull(Me.longitude) Then
    'Me.ImgGeoloc.Visible = True
    'Me.BoiteGeoloc.Visible = True
    'Me.TraitGeoloc.Visible = True
Else
    'Me.ImgGeoloc.Visible = False
    'Me.BoiteGeoloc.Visible = False
    'Me.TraitGeoloc.Visible = False
End If

End Sub
Private Sub CmdMaps_Click()
On Error GoTo Err_CmdMap_Click

 'NOTE: see this link for Google Map parms>> http://mapki.com/index.php?title=Google_Map_Parameters
     
     Dim tmpstr As String
     Dim tmpstr2 As String
     Dim shellcmd As String
     
     tmpstr = "http://maps.google.com/maps?q="
     tmpstr2 = Replace(Replace(Trim(Me.adrsit), "  ", " "), " ", "+")
     tmpstr = tmpstr & tmpstr2 & ",+" & Replace(Trim(Me.codpossit), " ", "+") & ",+" & Replace(Trim(Me.vilsit), " ", "+")
     tmpstr = tmpstr & "&t=m&hl=fr"    ' m = map parameter, k = hybrid parameter
     shellcmd = "C:\Program Files\Internet Explorer\iexplore.exe " & tmpstr
     
     Shell shellcmd, vbNormalFocus
     


Exit_CmdMap_Click:
    Exit Sub

Err_CmdMap_Click:
    MsgBox err.Description
    Resume Exit_CmdMap_Click
End Sub

Private Sub Form_Load()
    If Me.OpenArgs <> "" Then
        Me.numcli = Me.OpenArgs
    End If
    Controle_Intervenir
    Controle_Retard
    Me.ValidModifClient.Value = False
   
    
End Sub

Private Sub RechercheNumEsa(numcli As Integer)
Requete = "SELECT cheminpho,cheminpla  FROM client WHERE Numcli = " + Str(numcli)
    Set Esabora = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)

    If Esabora.RecordCount > 0 Then
        Esabora.MoveLast
        If IsNull(Esabora!cheminpla) = False Then
            Me.NumClim = Esabora!cheminpla
        Else
            Me.NumClim = ""
        End If
        Me.NumClim.Enabled = False
        If IsNull(Esabora!cheminpho) = False Then
            Me.NumMaint = Esabora!cheminpho
        Else
            Me.NumMaint = ""
        End If
         Me.NumMaint.Enabled = False
    End If
    Esabora.Close
    Set Esabora = Nothing
    
End Sub


Private Sub ControleCE()
If (IsNull(Me.cptsit) = False) Then
 Me.Commande402.Visible = False
    '28/10/24 Recherche des CE à editer
    Requete = "SELECT *  FROM sitemateriel WHERE numerosite = " & Str(Me.cptsit) + " and CE_EDITE=0 and YEAR(DateCE)=" + Format(Date, "yyyy")
    Set Materiel = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)

    If Materiel.RecordCount > 0 Then
        Materiel.MoveLast
        Me.Commande402.Caption = Str(Materiel.RecordCount) + " CE à Editer"
        Me.Commande402.Visible = True
    End If
    Materiel.Close
    Set Materiel = Nothing
End If
End Sub


Private Sub CmdAddIntervention_Click()
On Error GoTo Err_CmdAddIntervention_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Intervention"
       
    DoCmd.OpenForm stDocName, , , stLinkCriteria, acFormAdd, acWindowNormal, Me.cptsit & ";" & Me.numcli & ";" & Me.numintervenant

Exit_CmdAddIntervention_Click:
    Exit Sub

Err_CmdAddIntervention_Click:
    MsgBox err.Description
    Resume Exit_CmdAddIntervention_Click
    
End Sub
Private Sub CmdFermer2_Click()
On Error GoTo Err_CmdFermer2_Click


    If Me.Dirty Then Me.Dirty = False
    DoCmd.Close

Exit_CmdFermer2_Click:
    Exit Sub

Err_CmdFermer2_Click:
    MsgBox err.Description
    Resume Exit_CmdFermer2_Click
    
End Sub
Private Sub CmdRefreshInterventions_Click()
On Error GoTo Err_CmdRefreshInterventions_Click

    Me.Site_Sous_formulaire_sous_formulaire.Requery
    '27/01/25 Ajout du filtre pour eviter de charger toutes les inter OM
    If IsNull(Me.cptsit) = False Then
        Me.Site_Sous_formulaire_sous_formulaire_2.Form.Filter = "Cptsit=" + Str(Me.cptsit)
        Me.Site_Sous_formulaire_sous_formulaire_2.Form.FilterOn = True
    End If
    Me.Site_Sous_formulaire_sous_formulaire_2.Requery

Exit_CmdRefreshInterventions_Click:
    Exit Sub

Err_CmdRefreshInterventions_Click:
    MsgBox err.Description
    Resume Exit_CmdRefreshInterventions_Click
    
End Sub
Private Sub CmdGeocoder_Click()
 On Error GoTo catch
   Dim tGeo As tGeocodeResult

    If Me.txtAccuracy = "ROOFTOP" Then
        Exit Sub
    End If
  ' ClearGeocodingResults
  ' Me.Repaint
   
   'Start geocoding
   tGeo = Geocode(PrepareAddress(Me.adrsit), PrepareAddress(Me.vilsit), _
                  PrepareAddress(Me.codpossit), PrepareAddress(""), _
                  PrepareAddress("France"))
   'Display results
   With tGeo
   
      If tGeo.sStatus <> "OK" Then
           tGeo = Geocode("", PrepareAddress(Me.vilsit), _
                  "", PrepareAddress(""), _
                  PrepareAddress("France"))
      End If
      
      Me.txtRetAddress = .sRetAddress
      Me.txtLatitude = .dLatitude
      Me.txtLongitude = .dLongitude
      Me.txtAccuracy = .sAccuracy
      Me.txtStatus = .sStatus
    
      
   End With
   
   'AfficherImgGeoloc

finally:
   Exit Sub
catch:
   MsgBox "Error number:" & err.Number & vbCrLf & "Description:" & err.Description, _
          vbExclamation, "An error occurs during the geocoding..."
   Resume finally
End Sub
'Prepare address for geocoding (remove diacritic,...)
Private Function PrepareAddress(ByVal vText As Variant) As Variant   ' R. Dezan
   Const csIn As String = "ÀÁÂÃÄÅÈÉÊËÌÍÎÏÑÐÒÓÔÕÖÙÚÛÜÝŸÇ"
   Const csOut As String = "AAAAAAEEEEIIIINOOOOOOUUUUYYC"
   Dim i As Long, j As Long
   Dim sText As String

   If Not IsNull(vText) Then
      sText = UCase(vText)
      For i = 1 To Len(sText)
         j = InStr(1, csIn, Mid$(sText, i, 1), vbBinaryCompare)
         If j Then Mid$(sText, i, 1) = Mid$(csOut, j, 1)
      Next i
      PrepareAddress = CVar(Replace(Replace(sText, "Œ", "OE"), "Æ", "AE"))
   End If
End Function

Private Sub Commande297_Click()
On Error GoTo Err_Commande297_Click


    If Me.Dirty Then Me.Dirty = False
    DoCmd.Close

Exit_Commande297_Click:
    Exit Sub

Err_Commande297_Click:
    MsgBox err.Description
    Resume Exit_Commande297_Click
    
End Sub
Private Sub Commande298_Click()
On Error GoTo Err_Commande298_Click


    DoCmd.RunCommand acCmdRefresh
    ControleCE
Exit_Commande298_Click:
    Exit Sub

Err_Commande298_Click:
    MsgBox err.Description
    Resume Exit_Commande298_Click
    
End Sub
Private Sub CmdOuvrirClient_Click()
On Error GoTo Err_CmdOuvrirClient_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Client"
    
    stLinkCriteria = "[numcli]=" & Me![numcli]
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdOuvrirClient_Click:
    Exit Sub

Err_CmdOuvrirClient_Click:
    MsgBox err.Description
    Resume Exit_CmdOuvrirClient_Click
    
End Sub

Private Sub Modifiable402_DblClick(Cancel As Integer)
DoCmd.OpenForm "Intervenant_Fersoft", acNormal, , "numintervenant=" & Me.Modifiable402, acFormEdit
End Sub

Private Sub Modifiable405_DblClick(Cancel As Integer)
DoCmd.OpenForm "Intervenant_Fersoft", acNormal, , "numintervenant=" & Me.Modifiable405, acFormEdit
End Sub

Private Sub Modifiable407_DblClick(Cancel As Integer)
DoCmd.OpenForm "Intervenant_Fersoft", acNormal, , "numintervenant=" & Me.Modifiable407, acFormEdit
End Sub

Private Sub numcli_AfterUpdate()
'17/04/20 Modif OM Gestion du changement de numero de client
Dim Requete As String

If Old_Num_CLient <> Str(Me![numcli]) Then
    Requete = "Update devis set NumeroClient =" + Str(Me![numcli]) + " where NumeroClient =" + Old_Num_CLient + " and NumeroSite=" + Str(Me![cptsit])
    CurrentDb.Execute Requete
    Requete = "Update ContratDeMaintenance set NumeroClient =" + Str(Me![numcli]) + " where NumeroClient =" + Old_Num_CLient + " and NumeroSite=" + Str(Me![cptsit])
    CurrentDb.Execute Requete
    Requete = "Update DevisTravaux set NumeroClient =" + Str(Me![numcli]) + " where NumeroClient =" + Old_Num_CLient + " and NumeroSite=" + Str(Me![cptsit])
    CurrentDb.Execute Requete
End If


End Sub



Private Sub numcli_GotFocus()
Old_Num_CLient = Me![numcli]
End Sub


Private Sub ValidModifClient_AfterUpdate()
    If (Me.ValidModifClient.Value = True) Then
        Me.numcli.Locked = False
    Else
        Me.numcli.Locked = True
    End If
End Sub

Private Sub ValidModifDonOrdre_AfterUpdate()
If (Me.ValidModifDonOrdre.Value = True) Then
        Me.CboDonneur.Locked = False
    Else
        Me.CboDonneur.Locked = True
    End If
End Sub

Private Sub ValidModifNomSite_AfterUpdate()
If (Me.ValidModifNomSite.Value = True) Then
        Me.nomsit.Locked = False
    Else
        Me.nomsit.Locked = True
    End If
End Sub
