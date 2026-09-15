Attribute VB_Name = "Form_InterventionEntretien"
Attribute VB_Base = "0{D45A3661-AEDD-4D18-ACEF-E919C22980FF}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub BtReplanifier_Click()

'********************************************************************
Dim RsSite As Recordset
Dim rs As Recordset
Dim rsInsert As Recordset

Dim RsCodInt As Recordset
Dim lDatPreInt As Date
Dim lSQl As String
Dim lcodint As String
Dim NbVisitedejafaite As Long ' alain
Dim nbrentsit As Long
Dim VpasJour As Long
Dim VnouveauSite 'alain
Dim Tcompteur As String
Dim Vcompteur As Long
Dim Vcompt As Long

 '******************************************************************************************
DoCmd.DoMenuItem acFormBar, acRecordsMenu, acSaveRecord, , acMenuVer70

If IsNull(datint) Then
     MsgBox "Vous devez saisir la date réelle d'intervention.", vbInformation
    Exit Sub
End If
    
   
        ' efface les inter non faite pour le site
        lSQl = "delete from intervention where datintpre is not null and datint is null"
        lSQl = lSQl & " and cptsit = " & Str(TbCptsit)
        lSQl = lSQl & " and typint = '1'"
        CurrentDb.Execute lSQl, dbSeeChanges
    
    
        'recherche le dernier entretien
        
        lSQl = "Select max(datint) from intervention where cptsit=" & Str(TbCptsit)
        lSQl = lSQl & " and typint='1' and datint is not null"
        lSQl = lSQl & " group by codint "
        lSQl = lSQl & "order by max(datint) DESC"
    
        Set rs = CurrentDb().OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
        
        lSQl = "SELECT Site.*, Intervenant.codint, Site.numzonsit"
        lSQl = lSQl + " FROM Intervenant INNER JOIN Site ON Intervenant.numintervenant = Site.numintervenant WHERE Site.cptsit=" & Str(TbCptsit)

        Set RsSite = CurrentDb().OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
        If Not rs.EOF Then
            VnouveauSite = False
            Dim lDateDepart
            lDateDepart = rs(0) ' date du dernier entretien
            If Year(Date) > Year(Date) Then      ' si année derniere
                lDateDepart = "01/01/" & Year(Date)
                Dim landernier
                landernier = True
            Else
                landernier = False
            End If
        
        End If
    
    rs.Close
    Set rs = Nothing
    
    Set rsInsert = CurrentDb.OpenRecordset("intervention", dbOpenDynaset, dbSeeChanges)
    'Dim unevisitedejafaite
    Dim rsDejaFaite As Recordset
    Dim lDatdeb
    Dim lDatFin
    
    lDatdeb = lDateDepart
    lDatFin = "12/31/" & Year(Date)                             ' Me.datfinpla
    ' compte le nombre de visite deja faite
    lSQl = "Select count(*) from intervention where datint between #01/01/" & Year(Date) & "# and #" & lDatFin & "# and typint='1' and staint=9 and cptsit=" & Str(TbCptsit)
    Set rsDejaFaite = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
    If Not rsDejaFaite.EOF Then
        NbVisitedejafaite = rsDejaFaite(0) 'nb de visite faite
    End If
    
    'Dim NbreDeVisite
    'NbreDeVisite = Int(DateDiff("m", Me.txtDateDeb, Me.txtDatFin) / lpasmois)
    
    nbrentsit = RsSite("nbrentsit") - NbVisitedejafaite ' nombre d'entretein qu'il reste à planifier
    
    If VnouveauSite = True Then
        Dim Vnumvisite
        
        lDateDepart = datint
        Vnumvisite = Round(DateDiff("d", lDateDepart, "31/12/" & Year(Date)) * RsSite("nbrentsit") / 365) 'calcul nombre de visite pour le nouveau site par rapport à la date()
        
        
    End If
    If landernier = True Or VnouveauSite = True Then                                 'si aucune visite dans l'année
            VpasJour = Round(365 / nbrentsit)                    'calule l'interval entre 2 visite
            
            lDatPreInt = DateAdd("d", Round(VpasJour / 2), lDateDepart)     'date de premiere visite
    Else
            VpasJour = Round(DateDiff("d", lDateDepart, "31/12/" & Year(Date)) / (nbrentsit + 0.5))
            lDatPreInt = DateAdd("d", VpasJour, lDateDepart)
    End If
    Dim lI
    For lI = 1 To nbrentsit
        'Do While lDatPreInt <= lDatFin
        
        If EstFerie(lDatPreInt) Then
            If Weekday(lDatPreInt) = VbDayOfWeek.vbMonday Then
                lDatPreInt = DateAdd("d", 1, lDatPreInt)
            Else
                lDatPreInt = DateAdd("d", -1, lDatPreInt)
            End If
            
        End If
        If Weekday(lDatPreInt) = VbDayOfWeek.vbSaturday Then
            lDatPreInt = DateAdd("d", -1, lDatPreInt)
        End If
        If Weekday(lDatPreInt) = VbDayOfWeek.vbSunday Then
            lDatPreInt = DateAdd("d", 1, lDatPreInt)
        End If
        rsInsert.AddNew
        rsInsert("cptsit") = RsSite("cptsit")
        rsInsert("datintpre") = lDatPreInt
        rsInsert("typint") = "1"
        rsInsert("staint") = 1
        rsInsert("codint") = RsSite("codint")
        rsInsert("datheuapp") = Null
        rsInsert.Update
        lDatPreInt = DateAdd("d", VpasJour, lDatPreInt)
        DoEvents
    Next
       
    
   
    

    MsgBox "La génération des visites d'entretien s'est bien éffectuée.", vbInformation
    

    Exit Sub
traiterrgenerer:

 Select Case err.Number
        Case 3151
            Resume
        Case Else
            MsgBox err.Number & " " & err.Description
            DoCmd.Hourglass False
            Exit Sub
    End Select
      
End Sub

Private Sub Chkmajreg_Click()
    If Me.datint & "" = "" Then
        MsgBox "Une date d'intervention doit être saisie", vbExclamation, "Attention"
        Chkmajreg.Value = False
        Me.datint.SetFocus
    End If
End Sub

Private Sub CmdCloturerIntervention_Click()
    
    'On Error GoTo NoCloture
    
    If Me!numintint <> "" Then
        If MsgBox("Est-vous sûr de vouloir clôturer cette intervention ?", vbQuestion + vbYesNo, "Confirmation de clôture d'une intervention") = vbYes Then
            'Me!staint = 9
            'DoCmd.RunCommand acCmdSaveRecord
            CurrentDb.Execute "UPDATE Intervention SET staint=9 WHERE numintint=" & Me.numintint, dbSeeChanges
            
            ' Ajout de 3 ou 6 mois à la prochaine visite
            Dim lDernierMois As Integer
            Dim lNbreEnt As Integer
            lSQl = "SELECT nbrentsit FROM Site WHERE (cptsit = " & Me.cptsit & ")"
            Set rsNbreEnt = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
            If Not rsNbreEnt.EOF Then
                lNbreEnt = rsNbreEnt(0)
            Else
                lNbreEnt = 4
            End If
            rsNbreEnt.Close
            Set rsNbreEnt = Nothing
            Select Case lNbreEnt
                Case 2
                    lDernierMois = 7
                Case 4
                    lDernierMois = 10
            End Select
            
            If Month(Me.datint) < lDernierMois Then
                lSQl = "SELECT Intervenant.codint "
                lSQl = lSQl & " FROM (ZoneGeographique INNER JOIN Intervenant ON ZoneGeographique.numzon = Intervenant.numzonint) INNER JOIN Site ON ZoneGeographique.numzon = Site.numzonsit "
                lSQl = lSQl & " WHERE (((Site.cptsit)=" & Me.cptsit & "));"
                Set RsCodInt = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
                If Not RsCodInt.EOF Then
                    lcodint = RsCodInt(0)
                End If
                RsCodInt.Close
                Set RsCodInt = Nothing
                If lcodint <> "" Then
                    lSQl = "delete from intervention where datintpre is not null and datint is null"
                    lSQl = lSQl & " and cptsit = " & Me.cptsit
                    lSQl = lSQl & " and typint = '1'"
                    CurrentDb.Execute lSQl, dbSeeChanges
                    
                    lSQl = "Select max(datint) from intervention where cptsit=" & Me.cptsit
                    lSQl = lSQl & " and typint='1' and datint is not null"
                    lSQl = lSQl & " group by codint "
                    lSQl = lSQl & "order by max(datint) DESC"
                    
                    Set rs = CurrentDb().OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
                    If Not rs.EOF Then
                        Dim lDerniereDate
                        lDerniereDate = rs(0)
                    End If
                    
                    Dim lDatPreInt As Date
                    lDatPreInt = DateAdd("m", 12 / lNbreEnt, lDerniereDate)
                    
                    Set rsInsert = CurrentDb.OpenRecordset("intervention", dbOpenDynaset, dbSeeChanges)
                    
                    lSQl = "Select count(*) from intervention where datint between #01/01/" & Year(Now()) & "# and #31/12/" & Year(Now()) & "# and typint='1' and staint=9 and cptsit=" & Me.cptsit
                    Set rsDejaFaite = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
                    If Not rsDejaFaite.EOF Then
                        visitedejafaite = rsDejaFaite(0)
                    End If
                    
                    Dim nbrentsit
                    Dim lI
                    For lI = 1 To lNbreEnt - visitedejafaite
                        
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
                        rsInsert("cptsit") = Me.cptsit
                        rsInsert("datintpre") = lDatPreInt
                        rsInsert("typint") = "1"
                        rsInsert("staint") = 1
                        rsInsert("codint") = lcodint
                        rsInsert("datheuapp") = Null
                        rsInsert.Update
                        lDatPreInt = DateAdd("m", 12 / lNbreEnt, lDatPreInt)
                        DoEvents
                    Next
                End If
            End If
        End If
    End If
    Exit Sub
    
NoCloture:

    Me.staint = 1
    
End Sub

Private Sub CmdDecloturer_Click()
    
    If Me!numintint <> "" Then
    If MsgBox("Est-vous sûr de vouloir déclôturer cette intervention ?", vbQuestion + vbYesNo, "Confirmation de clôture d'une intervention") = vbYes Then
        CurrentDb.Execute "update intervention set staint=1 where numintint=" & Me!numintint, dbSeeChanges
        Me.Requery
    End If
    End If

End Sub

Private Sub CmdHistorique_Click()
    Me.Filter = "refint like '" & Left(Me.refint, 20) & "*'"
    Me.FilterOn = True
End Sub

Private Sub CmdNouvelleIntervention_Click()

    On Error GoTo traiterrnewinter
    If MsgBox("Est-vous sûr de vouloir créer une nouvelle intervention en utilisant les données actuelles ?", vbQuestion + vbYesNo, "Confirmation de création d'une nouvelle intervention") = vbYes Then
        Dim rs As Recordset
        Dim Vnumintint As Long
        
        Set rs = CurrentDb.OpenRecordset("intervention", dbOpenDynaset, dbSeeChanges)
        rs.AddNew
        rs("cptsit") = Me!cptsit 'Form_MenuPrincipal.LstClient
        'rs("numsit") = Me!numsit
        rs("datheuapp") = Me!datheuapp
        rs("codcon") = Me!codcon
        rs("codint") = Me!codint
        rs("intfac") = Me!intfac
        rs("mntfac") = Me!mntfac
        rs("typint") = Me!typint
        rs("staint") = 1
        rs("refcliint") = Me!refcliint
        rs("refint") = Me!refint
        rs("nbrpagfax") = Me!nbrpagfax
        rs("pannoncli") = Me!pannoncli
        rs("codpan") = Me!codpan
        rs.Update
        rs.MoveLast
        Vnumintint = rs("numintint")
        rs.Close
        Set rs = Nothing
        'Set rs = CurrentDb.OpenRecordset("select max(numintint) from intervention", dbOpenDynaset, dbSeeChanges)
        'If Not rs.EOF Then
            
        'End If
       ' rs.Close
        Set rs = CurrentDb.OpenRecordset("FicheIntervention", dbOpenDynaset, dbSeeChanges)
        rs.AddNew
        rs("numintint") = Vnumintint
        rs.Update
        rs.Close
        
        'DoCmd.Requery
        'DoCmd.ApplyFilter , "numintint = " & Str(Vnumintint)
        Me.Filter = "numintint = " & Str(Vnumintint)
        
        Me.Requery
        Me.Refresh
        If GformulaireParent = "site" Then
            Forms![Site]![Site Sous-formulaire sous-formulaire].Requery
        End If
    End If
exittraiterrnewinter:
    Exit Sub
traiterrnewinter:
    MsgBox err.Description
    Resume exittraiterrnewinter
End Sub


Private Sub codcon_AfterUpdate()
    Dim rst As dao.Recordset
    Vsql = "SELECT Contact.codcon FROM Contact WHERE (((Contact.codcon)='" + Me.codcon + "'));"
    Set rst = CurrentDb.OpenRecordset(Vsql)
    If rst.EOF = True Then
        rst.AddNew
        rst("codcon") = Me.codcon
        rst.Update
    End If
    'Me.codcon.Requery
End Sub

Private Sub Commande131_Click()
    If Not IsNull(ListeMateriel) Then
        Dim Vsql As String
        Dim rst As dao.Recordset
        Dim Rst2 As dao.Recordset

        Set rst = CurrentDb.OpenRecordset("panneMaterielSite", dbOpenDynaset, dbSeeChanges)
        Vsql = "SELECT PanneMaterielSite.numintint, PanneMaterielSite.numsitmarref FROM PanneMaterielSite"
        Vsql = Vsql + " WHERE (((PanneMaterielSite.numintint)=" + Str(numintint) + ") AND ((PanneMaterielSite.numsitmarref)=" + Str(ListeMateriel) + "));"
        Set Rst2 = CurrentDb.OpenRecordset(Vsql)
        If Rst2.EOF = True Then
            rst.AddNew
            rst("numintint") = numintint
            rst("numsitmarref") = ListeMateriel
            rst.Update
            SfMaterielPanne.Requery
        End If
    End If
End Sub

Private Sub Commande90_Click()
    'Me.comint.SetFocus
    SendKeys "+{F2}"
End Sub

Private Sub Commande91_Click()
    'Me.dirint.SetFocus
    SendKeys "+{F2}"
End Sub





Private Sub datintpre_AfterUpdate()
    If GformulaireParent = "site" Then
        DoCmd.DoMenuItem acFormBar, acRecordsMenu, acSaveRecord, , acMenuVer70
        Forms![Site]![Site Sous-formulaire sous-formulaire].Requery

    End If
End Sub

Private Sub Form_AfterInsert()
ListeMateriel.Requery
End Sub

Private Sub Form_BeforeInsert(Cancel As Integer)

    If Me.typint = 1 Then
        If Me.Chkmajreg = True Then
            lSQl = "SELECT cptsit, [Date] FROM SiteMAJRegistre WHERE (cptsit = " & Str(Me.cptsit) & ") AND ([Date] LIKE '" & Me.datint & "')"
            Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
            If lrs.EOF Then
                CurrentDb.Execute "INSERT INTO SiteMAJRegistre (cptsit, [Date]) VALUES (" & Me.cptsit & ",'" & Me.datint & "')"
            End If
        End If
    End If

End Sub

Private Sub Form_BeforeUpdate(Cancel As Integer)

    Form_BeforeInsert Cancel

End Sub

Private Sub Form_Close()
    If GformulaireParent = "site" Then
        DoCmd.DoMenuItem acFormBar, acRecordsMenu, acSaveRecord, , acMenuVer70
        Forms![Site]![Site Sous-formulaire sous-formulaire].Requery
        Forms![Site]![Site Sous-formulaire sous-formulaire 2].Requery
       'Forms![site].Requery
    End If
End Sub

Private Sub Form_Load()


        'numcli = Forms!menuPrincipal!LstClient
        Me.titre.Caption = "Interventions d'entretien planifiées"
        
End Sub

Private Sub intfac_AfterUpdate()
    
    If Me.intfactok.Value = True And Me.intfac.Value = True Then
        Me.intfactok.Value = False
    End If

End Sub


Private Sub intfactok_AfterUpdate()

    If Me.intfactok.Value = True And Me.intfac.Value = True Then
        Me.intfac.Value = False
    End If

End Sub


Private Sub CmdAfficherSite_Click()
On Error GoTo Err_CmdAfficherSite_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Site"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdAfficherSite_Click:
    Exit Sub

Err_CmdAfficherSite_Click:
    MsgBox err.Description
    Resume Exit_CmdAfficherSite_Click
    
End Sub
Private Sub CmdImprimerFax_Click()
On Error GoTo Err_CmdImprimerFax_Click

    DoCmd.DoMenuItem acFormBar, acRecordsMenu, acSaveRecord, , acMenuVer70
    Dim stDocName As String
    Dim stLinkCriteria As String
    
    
    lArgs = Me!numintint
    If Me!typint = 4 Then
        lArgs = lArgs & ";FaxInterventionIntervenantCuratif"
    Else
        lArgs = lArgs & ";FaxInterventionIntervenant"
    End If

    If Me!numintint <> "" Then
        stDocName = "ChoixSociete"
        DoCmd.OpenForm stDocName, , , , , , lArgs
    
        'stLinkCriteria = "numintint=" & Me!numintint
        'DoCmd.OpenReport stDocName, acPreview, , stLinkCriteria
    Else
        MsgBox "Vous devez d'abord sélectionner une intervention.", vbInformation
    End If
Exit_CmdImprimerFax_Click:
    Exit Sub

Err_CmdImprimerFax_Click:
    MsgBox err.Description
    Resume Exit_CmdImprimerFax_Click
    
End Sub





Private Sub ListeMateriel_DblClick(Cancel As Integer)
    Dim db As dao.Database
    Dim rst As dao.Recordset
    Dim Rst2 As dao.Recordset
    Dim Vsql As String
    Set db = CurrentDb
    Set rst = db.OpenRecordset("panneMaterielSite", dbOpenDynaset, dbSeeChanges)
    Vsql = "SELECT PanneMaterielSite.numintint, PanneMaterielSite.numsitmarref FROM PanneMaterielSite"
    Vsql = Vsql + " WHERE (((PanneMaterielSite.numintint)=" + Str(numintint) + ") AND ((PanneMaterielSite.numsitmarref)=" + Str(ListeMateriel) + "));"
    Set Rst2 = db.OpenRecordset(Vsql)
    If Rst2.EOF = True Then
        rst.AddNew
        rst("numintint") = numintint
        rst("numsitmarref") = ListeMateriel
        rst.Update
        SfMaterielPanne.Requery
    End If


End Sub

Private Sub numcli_AfterUpdate()
cptsit.Requery

End Sub




Private Sub refcliint_Exit(Cancel As Integer)
    If Not IsNull(Me.refcliint) Then
        Me.refcliint = UCase(Me.refcliint)
    End If
End Sub

Private Sub refint_Exit(Cancel As Integer)
    If Not IsNull(Me.refint) Then
        Me.refint = UCase(Me.refint)
    End If
End Sub

Private Sub staint_AfterUpdate()

    If Me!staint < 9 Then
        Me!nbrappint = Me!staint - 1
    End If
    If GformulaireParent = "site" Then
        DoCmd.DoMenuItem acFormBar, acRecordsMenu, acSaveRecord, , acMenuVer70
        Forms![Site]![Site Sous-formulaire sous-formulaire].Requery
        Forms![Site]![Site Sous-formulaire sous-formulaire 2].Requery
    End If

End Sub

Private Sub CmdRechercherSite_Click()
On Error GoTo Err_CmdRechercherSite_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "RechercheSite"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdRechercherSite_Click:
    Exit Sub

Err_CmdRechercherSite_Click:
    MsgBox err.Description
    Resume Exit_CmdRechercherSite_Click
    
End Sub
Private Sub CmdImprimerFaxClient_Click()
On Error GoTo Err_CmdImprimerFaxClient_Click
    DoCmd.DoMenuItem acFormBar, acRecordsMenu, acSaveRecord, , acMenuVer70
    'GenererSemaine
    'Exit Sub
    Dim stDocName As String
    Dim lArgs As String
    Dim stLinkCriteria As String

    If Me!typint = "" Then
        MsgBox "Il faut sélectionner le type d'intervention pour pouvoir imprimer le fax.", vbInformation
        Exit Sub
    End If
    If Me!numintint <> "" Then

        lArgs = Me!numintint
        If Me!typint = "1" Then
            lArgs = lArgs & ";FaxInterventionClient"
        End If
        If Me!typint = "2" Or Me!typint = "3" Or Me!typint = "4" Or Me!typint = "5" Then
            lArgs = lArgs & ";FaxInterventionClientDepannage"
        End If
        
        'DoCmd.OpenReport stDocName, acPreview, , stLinkCriteria
        stDocName = "ChoixSociete"
        DoCmd.OpenForm stDocName, , , , , , lArgs
    End If

Exit_CmdImprimerFaxClient_Cli:
    Exit Sub

Err_CmdImprimerFaxClient_Click:
    MsgBox err.Description
    Resume Exit_CmdImprimerFaxClient_Cli
    
End Sub

Private Sub CmdAfficherUnSite_Click()
On Error GoTo Err_CmdAfficherUnSite_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Site"
    
    stLinkCriteria = "[CPTSIT]=" & Me![cptsit]
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdAfficherUnSite_Click:
    Exit Sub

Err_CmdAfficherUnSite_Click:
    MsgBox err.Description
    Resume Exit_CmdAfficherUnSite_Click
    
End Sub
Private Sub CmdEnregistrer_Click()
On Error GoTo Err_CmdEnregistrer_Click


    DoCmd.DoMenuItem acFormBar, acRecordsMenu, acSaveRecord, , acMenuVer70

Exit_CmdEnregistrer_Click:
    Exit Sub

Err_CmdEnregistrer_Click:
    MsgBox err.Description
    Resume Exit_CmdEnregistrer_Click
    
End Sub

Private Sub Texte109_Change()
ListeMateriel.Requery
End Sub
Private Sub Commande139_Click()
On Error GoTo Err_Commande139_Click


    DoCmd.DoMenuItem acFormBar, acRecordsMenu, acSaveRecord, , acMenuVer70

Exit_Commande139_Click:
    Exit Sub

Err_Commande139_Click:
    MsgBox err.Description
    Resume Exit_Commande139_Click
    
End Sub
