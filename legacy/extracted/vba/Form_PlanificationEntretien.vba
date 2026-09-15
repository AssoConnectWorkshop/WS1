Attribute VB_Name = "Form_PlanificationEntretien"
Attribute VB_Base = "0{9C4EDC7D-D1BF-4061-B590-264177A94CE7}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database
Option Explicit

Private Sub BtGenerer_Click()
Dim db As Database
Dim RsSite As Recordset
Dim RsCodInt As Recordset
Dim rsInsert As Recordset
Dim RsInterfaite  As Recordset
Dim Vsql As String
Dim lSQl As String
Dim lcodint As String
Dim Vnombreinter As String
Dim VnbJour As Long
Dim VDatint
Set db = CurrentDb
DoCmd.Hourglass True
    
Vsql = "SELECT Site.numcli, Site.cptsit, Site.nbrentsit,  Site.numzonsit"
Vsql = Vsql + " FROM Site"
Vsql = Vsql + " WHERE (((Site.numcli)=1)) OR (((Site.numcli)=2)) OR (((Site.numcli)=49)) OR (((Site.numcli)=40)) OR (((Site.numcli)=77));"

Set RsSite = db.OpenRecordset(Vsql, dbOpenDynaset, dbSeeChanges)

Set rsInsert = db.OpenRecordset("intervention", dbOpenDynaset, dbSeeChanges)

Do Until RsSite.EOF


    If RsSite("nbrentsit") <> "" And RsSite("numcli") <> "" Then
    
        lSQl = "delete from intervention where datintpre is not null and datint is null"
        lSQl = lSQl & " and cptsit = " & RsSite("cptsit")
        lSQl = lSQl & " and typint = '1'"
        ' Efface les interventions non faite pour ce site
        CurrentDb.Execute lSQl, dbSeeChanges
        lSQl = "SELECT Intervenant.codint "
        lSQl = lSQl & " FROM (ZoneGeographique INNER JOIN Intervenant ON ZoneGeographique.numzon = Intervenant.numzonint) INNER JOIN Site ON ZoneGeographique.numzon = Site.numzonsit "
        lSQl = lSQl & " WHERE (((Site.cptsit)=" & RsSite("cptsit") & "));"
        ' recherche le code intervenant du site
        Set RsCodInt = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
        lcodint = ""
        If Not RsCodInt.EOF Then
            lcodint = RsCodInt(0)
        End If
        ' recherche des interventions faites pour ce site
        lSQl = "SELECT Intervention.cptsit, Intervention.datint FROM Intervention "
        lSQl = lSQl + "WHERE (Intervention.cptsit)=" + Str(RsSite("cptsit")) + " AND (Intervention.typint)='1' AND (Mid([datint],7,4))=Year(Date()) ORDER BY Intervention.datint;"
        Set RsInterfaite = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
        ' compte le nombre d'interventions faites
        Vnombreinter = 0
        Do While Not RsInterfaite.EOF
            Vnombreinter = Vnombreinter + 1
            VDatint = RsInterfaite("datint")
            RsInterfaite.MoveNext
        Loop
        If RsSite("nbrentsit") = Vnombreinter Then GoTo suite
            
        End If
        If Month(dateDebut) = 1 Then
            If RsSite("nbrentsit") = 8 And Vnombreinter = 0 Or RsSite("nbrentsit") = 12 And Vnombreinter = 0 Then
                ' janvier
                GDatPreInt = "15/01/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        If Month(dateDebut) < 3 Then
            If RsSite("nbrentsit") < 8 And Vnombreinter = 0 Or RsSite("nbrentsit") = 12 And Vnombreinter < 2 Then
                'février
                GDatPreInt = "15/02/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        If Month(dateDebut) < 4 Then
            If RsSite("nbrentsit") = 12 And Vnombreinter < 3 Then
                'mars
                GDatPreInt = "15/03/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        If Month(dateDebut) < 5 Then
            If RsSite("nbrentsit") = 12 And Vnombreinter < 4 Then
                'Avril
                GDatPreInt = "15/04/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        ' calcul 2° Visite pour les sites à 8 visites **************************************************
       
        If RsSite("nbrentsit") = 8 And Vnombreinter < 2 Then
            If Vnombreinter = 1 Then
                VnbJour = Int(135 - ((135 - DateDiff("d", "1/01/" & Year(dateDebut), VDatint)) / 2))
                 GDatPreInt = DateAdd("d", VnbJour, "1/1/" & Year(dateDebut))
                Call calcul_jour_ouvrable
                 rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            Else
                GDatPreInt = "15/03/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        ' fin de calcul
        If Month(dateDebut) < 6 Then
            If RsSite("nbrentsit") = 8 And Vnombreinter < 3 Or RsSite("nbrentsit") = 12 And Vnombreinter < 5 Then
                'Mai
                GDatPreInt = "15/05/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        ' calcul 2° visite  pour les sites à 6 ou 7 visites **************************************************
       
        If RsSite("nbrentsit") < 8 And Vnombreinter < 2 Then
            If Vnombreinter = 1 Then
                VnbJour = Int(165 - ((165 - DateDiff("d", "1/01/" & Year(dateDebut), VDatint)) / 2))
                GDatPreInt = DateAdd("d", VnbJour, "1/1/" & Year(dateDebut))
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            Else
                GDatPreInt = "15/04/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        ' fin de calcul *************************************
        If Month(dateDebut) < 7 Then
            If RsSite("nbrentsit") < 8 And Vnombreinter < 3 Or RsSite("nbrentsit") = 8 And Vnombreinter < 4 Or RsSite("nbrentsit") = 12 And Vnombreinter < 6 Then
                'Juin
                GDatPreInt = "15/06/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        If Month(dateDebut) < 8 Then
            If RsSite("nbrentsit") < 8 And Vnombreinter < 4 Or RsSite("nbrentsit") = 8 And Vnombreinter < 5 Or RsSite("nbrentsit") = 12 And Vnombreinter < 7 Then
                'Juillet
                GDatPreInt = "15/07/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        If Month(dateDebut) < 9 Then
            If RsSite("nbrentsit") < 8 And Vnombreinter < 5 Or RsSite("nbrentsit") = 8 And Vnombreinter < 6 Or RsSite("nbrentsit") = 12 And Vnombreinter < 8 Then
                'Aout
                GDatPreInt = "15/08/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        ' calcul 7° Visite pour les sites à 8 visites et 6° visite pour les sites à 7 visites **************************************************
     
        If RsSite("nbrentsit") = 8 And Vnombreinter < 7 Or RsSite("nbrentsit") = 7 And Vnombreinter < 6 Then
            If RsSite("nbrentsit") = 8 And Vnombreinter = 7 Or RsSite("nbrentsit") = 7 And Vnombreinter = 6 Then
                VnbJour = Int(350 - ((350 - DateDiff("d", "1/01/" & Year(dateDebut), VDatint)) / 2))
                GDatPreInt = DateAdd("d", VnbJour, "1/1/" & Year(dateDebut))
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            Else
                GDatPreInt = "15/10/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        ' fin de calcul *******************************************************
        If Month(dateDebut) < 10 Then
            If RsSite("nbrentsit") = 12 And Vnombreinter < 9 Then
                'Septembre
                GDatPreInt = "15/09/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        If Month(dateDebut) < 11 Then
            If RsSite("nbrentsit") = 12 And Vnombreinter < 10 Then
                'Octobre
                GDatPreInt = "15/10/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        If Month(dateDebut) < 12 Then
            If RsSite("nbrentsit") = 6 And Vnombreinter < 6 Or RsSite("nbrentsit") = 12 And Vnombreinter < 11 Then
                'Novembre
                GDatPreInt = "15/11/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
        If Month(dateDebut) < 13 Then
            If RsSite("nbrentsit") = 7 And Vnombreinter < 7 Or RsSite("nbrentsit") = 8 And Vnombreinter < 8 Or RsSite("nbrentsit") = 12 And Vnombreinter < 12 Then
                'Décembre
                GDatPreInt = "15/12/" & Year(dateDebut)
                Call calcul_jour_ouvrable
                rsInsert.AddNew
                rsInsert("cptsit") = RsSite("cptsit")
                rsInsert("datintpre") = GDatPreInt
                rsInsert("typint") = "1"
                rsInsert("staint") = 1
                rsInsert("codint") = lcodint
                rsInsert("datheuapp") = Null
                rsInsert.Update
            End If
        End If
suite:
    RsSite.MoveNext
Loop

DoCmd.Hourglass False
MsgBox "La génération des visites d'entretien s'est bien éffectuée.", vbInformation
End Sub
Private Sub calcul_jour_ouvrable()
    If EstFerie(GDatPreInt) Then
            GDatPreInt = DateAdd("d", -1, GDatPreInt)
        End If
        If Weekday(GDatPreInt) = VbDayOfWeek.vbSaturday Then
            GDatPreInt = DateAdd("d", -1, GDatPreInt)
        End If
        If Weekday(GDatPreInt) = VbDayOfWeek.vbSunday Then
            GDatPreInt = DateAdd("d", 1, GDatPreInt)
        End If
End Sub
Private Sub cmdGenerer_Click()
    
Dim RsSite As Recordset
Dim rs As Recordset
Dim rsInsert As Recordset

Dim RsCodInt As Recordset
Dim lDatPreInt As Date
Dim lSQl As String
Dim lcodint As String

DoCmd.Hourglass True

    If Me.LstClient & "" = "" Then
        Set RsSite = CurrentDb().OpenRecordset("SELECT Site.*  FROM Site  WHERE (Site.numcli)<>1 And (Site.numcli)<>2 And (Site.numcli)<>49 And (Site.numcli)<>77 And (Site.numcli)<>70 And (Site.numcli)<>40", dbOpenDynaset, dbSeeChanges)
    Else
        Set RsSite = CurrentDb().OpenRecordset("Select * from site where numcli=" & Me.LstClient, dbOpenDynaset, dbSeeChanges)
    End If
    
    If Me.txtDatFin & "" = "" Then
        MsgBox "Merci de saisir une date de fin pour pouvoir générer le planning prévisionnel."
        DoCmd.Hourglass False
        Exit Sub
    End If
 
 Do Until RsSite.EOF
 
    On Error GoTo traiterrgenerer
    
    If RsSite("nbrentsit") = "" Then
        MsgBox "Merci de saisir le nombre de visite d'entretien pour pouvoir générer le planning prévisionnel."
        DoCmd.Hourglass False
        Exit Sub
    End If
    
    If RsSite("numsit") <> "" And RsSite("nbrentsit") <> "" And RsSite("numcli") <> "" Then
    
        lSQl = "delete from intervention where datintpre is not null and datint is null"
        lSQl = lSQl & " and cptsit = " & RsSite("cptsit")
        lSQl = lSQl & " and typint = '1'"
        CurrentDb.Execute lSQl, dbSeeChanges
    
        lSQl = "Select max(datint) from intervention where cptsit=" & RsSite("cptsit")
        lSQl = lSQl & " and typint='1' and datint is not null"
        lSQl = lSQl & " group by codint "
        lSQl = lSQl & "order by max(datint) DESC"
    
        Set rs = CurrentDb().OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
        If Not rs.EOF Then
            Dim lDateDepart
            lDateDepart = rs(0)
            If Year(Date) > Year(lDateDepart) Then
                Dim landernier
                landernier = True
            Else
                landernier = False
            End If
        Else
            lDateDepart = "15/12/" & (Year(Date) - 1)
        End If
    
    lSQl = "SELECT Intervenant.codint "
    lSQl = lSQl & " FROM (ZoneGeographique INNER JOIN Intervenant ON ZoneGeographique.numzon = Intervenant.numzonint) "
    lSQl = lSQl & " INNER JOIN Site ON Intervenant.numintervenant = Site.numintervenant "
    lSQl = lSQl & " WHERE (((Site.cptsit)=" & RsSite("cptsit") & "));"
    
    Set RsCodInt = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
    If Not RsCodInt.EOF Then
        lcodint = RsCodInt(0)
    Else
        GoTo sitesuivant
    End If
    RsCodInt.Close
    Set RsCodInt = Nothing
    
    Dim lpasmois
    
    lpasmois = Int(12 / RsSite("nbrentsit"))
    
    rs.Close
    Set rs = Nothing
    
    Set rsInsert = CurrentDb.OpenRecordset("intervention", dbOpenDynaset, dbSeeChanges)
    Dim unevisitedejafaite
    If lDateDepart = "15/12/" & Year(Date) - 1 Then
        lDatPreInt = DateAdd("m", lpasmois, lDateDepart)
        unevisitedejafaite = 0
    Else
        lDatPreInt = DateAdd("m", lpasmois, lDateDepart)
        If landernier = False Then
            unevisitedejafaite = 1
        End If
    End If
    Dim rsDejaFaite As Recordset
    
    'lSql = "Select count(*) from intervention where datint between #01/01/" & Year(Now()) & "# and #31/12/" & Year(Now()) & "# and typint='1' and staint=9 and cptsit=" & RsSite("cptsit")
    Dim lDatdeb
    Dim lDatFin
    'lDatdeb = Mid(Me.txtDateDeb, 4, 2) & "/" & Left(Me.txtDateDeb, 2) & Mid(Me.txtDateDeb, 6)
    lDatdeb = lDateDepart
    'lDatFin = Mid(Me.txtDatFin, 4, 2) & "/" & Left(Me.txtDatFin, 2) & Mid(Me.txtDatFin, 6)
    lDatFin = Me.datfinpla
    
    lSQl = "Select count(*) from intervention where datint between #" & lDatdeb & "# and #" & lDatFin & "# and typint='1' and staint=9 and cptsit=" & RsSite("cptsit")
    Set rsDejaFaite = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
    If Not rsDejaFaite.EOF Then
        unevisitedejafaite = rsDejaFaite(0)
    End If
    
    'Dim NbreDeVisite
    'NbreDeVisite = Int(DateDiff("m", Me.txtDateDeb, Me.txtDatFin) / lpasmois)
    
    Dim nbrentsit
    Dim lI
    'For lI = 1 To NbreDeVisite - unevisitedejafaite
    Do While lDatPreInt <= lDatFin
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
        rsInsert("cptsit") = RsSite("cptsit")
        rsInsert("datintpre") = lDatPreInt
        rsInsert("typint") = "1"
        rsInsert("staint") = 1
        rsInsert("codint") = lcodint
        rsInsert("datheuapp") = Null
        rsInsert.Update
        lDatPreInt = DateAdd("m", lpasmois, lDatPreInt)
        DoEvents
    'Next
    Loop
     rsInsert.Close
    End If
    
sitesuivant:

    RsSite.MoveNext
Loop
    Set rsInsert = Nothing
    RsSite.Close
    Set RsSite = Nothing
    DoCmd.Hourglass False
    MsgBox "La génération des visites d'entretien s'est bien éffectuée.", vbInformation
    
TraitErrGenererOff:
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

Private Sub Commande16_Click()
Dim db As Database
Dim RsSite As Recordset
Dim RsCodInt As Recordset
Dim rsInsert As Recordset
Dim Vsql As String
Dim lSQl As String
Dim lcodint As String
Set db = CurrentDb
DoCmd.Hourglass True
Vsql = "SELECT Site.numcli, Site.cptsit, Site.nbrentsit,  Site.numzonsit"
Vsql = Vsql + " FROM Site"
Vsql = Vsql + " WHERE Site.numcli = 70;"

Set RsSite = db.OpenRecordset(Vsql, dbOpenDynaset, dbSeeChanges)

Set rsInsert = db.OpenRecordset("intervention", dbOpenDynaset, dbSeeChanges)

Do Until RsSite.EOF
    If RsSite("nbrentsit") <> "" And RsSite("numcli") <> "" Then
    
        lSQl = "delete from intervention where datintpre is not null and datint is null"
        lSQl = lSQl & " and cptsit = " & RsSite("cptsit")
        lSQl = lSQl & " and typint = '1'"
        CurrentDb.Execute lSQl, dbSeeChanges
        lSQl = "SELECT Intervenant.codint "
        lSQl = lSQl & " FROM (ZoneGeographique INNER JOIN Intervenant ON ZoneGeographique.numzon = Intervenant.numzonint) INNER JOIN Site ON ZoneGeographique.numzon = Site.numzonsit "
        lSQl = lSQl & " WHERE (((Site.cptsit)=" & RsSite("cptsit") & "));"
    
        Set RsCodInt = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
        lcodint = ""
        If Not RsCodInt.EOF Then
            lcodint = RsCodInt(0)
        End If
        If RsSite("nbrentsit") < 7 Then
        
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #2/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #4/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #6/16/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #7/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #8/14/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #11/14/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
        End If
        If RsSite("nbrentsit") = 7 Then
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #2/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #4/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #6/16/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #7/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #8/14/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #10/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #12/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
        End If
        If RsSite("nbrentsit") = 8 Then
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #1/22/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #3/14/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #5/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #6/16/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #7/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #8/14/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #10/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #12/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
        End If
        If RsSite("nbrentsit") = 12 Then
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #1/22/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #2/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #3/14/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #4/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #5/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #6/16/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #7/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #8/14/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #9/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #10/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #11/14/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
            rsInsert.AddNew
            rsInsert("cptsit") = RsSite("cptsit")
            rsInsert("datintpre") = #12/15/2008#
            rsInsert("typint") = "1"
            rsInsert("staint") = 1
            rsInsert("codint") = lcodint
            rsInsert("datheuapp") = Null
            rsInsert.Update
        End If
        
    End If


    RsSite.MoveNext
Loop
DoCmd.Hourglass False

End Sub

Private Sub Commande19_Click()
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

    
    'If Me.LstClient = 1 Or Me.LstClient = 2 Or Me.LstClient = 49 Or Me.LstClient = 77 Or Me.LstClient = 70 Or Me.LstClient = 40 Then
       ' MsgBox ("Pour ce client utiliser l'autre bouton")
       ' Exit Sub
   ' End If
 DoCmd.Hourglass True
    lSQl = "SELECT Site.*, Intervenant.codint, Site.numzonsit"
    lSQl = lSQl + " FROM Intervenant RIGHT JOIN Site ON Intervenant.numintervenant = Site.numintervenant"


    If Me.LstClient & "" = "" Then
        lSQl = lSQl + " WHERE (Site.numcli)<>1 And (Site.numcli)<>2 And (Site.numcli)<>49 And (Site.numcli)<>77 And (Site.numcli)<>70 And (Site.numcli)<>40 ;"
        Set RsSite = CurrentDb().OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
        Set rs = CurrentDb.OpenRecordset("SELECT Count(Site.nomsit) FROM Site WHERE (Site.numcli)<>1 And (Site.numcli)<>2 And (Site.numcli)<>49 And (Site.numcli)<>77 And (Site.numcli)<>70 And (Site.numcli)<>40 ;", dbOpenDynaset, dbSeeChanges)
    Else
        lSQl = lSQl + " where numcli = " & Str(Me.LstClient) & " ;"
        Set RsSite = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
        Set rs = CurrentDb.OpenRecordset("SELECT Count(Site.nomsit) FROM Site WHERE Site.numcli=" & Str(Me.LstClient) & " ;", dbOpenDynaset, dbSeeChanges)
    End If
    
    Vcompteur = Round(rs(0) / 150)
    If Vcompteur = 0 Then Vcompteur = 1
    If Me.txtDatFin & "" = "" Then
        MsgBox "Merci de saisir une date de fin pour pouvoir générer le planning prévisionnel."
        DoCmd.Hourglass False
        Exit Sub
    End If
    Tcompteur = Tcompteur & "l"
    compteur.Value = Tcompteur
    compteur.Visible = True
 '******************************************************************************************
 Do Until RsSite.EOF    ' boucle sur la vue de la table site filtrée par numclient
    If Vcompt = Vcompteur Then
        Tcompteur = Tcompteur & "l"
        compteur.Value = Tcompteur
        Vcompt = 0
    End If
    Vcompt = Vcompt + 1
    
    On Error GoTo traiterrgenerer
    
    If RsSite("nbrentsit") = "" Then
        MsgBox "Merci de saisir le nombre de visite d'entretien pour pouvoir générer le planning prévisionnel."
        DoCmd.Hourglass False
        Exit Sub
    End If
    If RsSite("nbrentsit") = 0 Then GoTo sitesuivant
    
    If RsSite("nbrentsit") <> "" And RsSite("numcli") <> "" Then
        ' efface les inter non faite pour le site
        lSQl = "delete from intervention where datintpre is not null and datint is null"
        lSQl = lSQl & " and cptsit = " & RsSite("cptsit")
        lSQl = lSQl & " and typint = '1'"
        CurrentDb.Execute lSQl, dbSeeChanges
    
    
        'recherche le dernier entretien
        
        lSQl = "Select max(datint) from intervention where cptsit=" & RsSite("cptsit")
        lSQl = lSQl & " and typint='1' and datint is not null"
        lSQl = lSQl & " group by codint "
        lSQl = lSQl & "order by max(datint) DESC"
    
        Set rs = CurrentDb().OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
        If Not rs.EOF Then
            VnouveauSite = False
            Dim lDateDepart
            lDateDepart = rs(0) ' date du dernier entretien
            '********** code supprimé le 15 03 2010
           ' If Year(Date) > Year(lDateDepart) Then      ' si année derniere
           '     lDateDepart = "01/01/" & Year(Date)
           '     Dim landernier
           '     landernier = True
           ' Else
           '     landernier = False
           ' End If
            '************
        Else
        ' aucun entretient trouvé donc nouveau site **************************************************************************************
            VnouveauSite = True
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
    lSQl = "Select count(*) from intervention where datint between #01/01/" & Year(Date) & "# and #" & lDatFin & "# and typint='1' and staint=4 and cptsit=" & RsSite("cptsit")
    Set rsDejaFaite = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
    If Not rsDejaFaite.EOF Then
        NbVisitedejafaite = rsDejaFaite(0) 'nb de visite faite
    End If
    
    'Dim NbreDeVisite
    'NbreDeVisite = Int(DateDiff("m", Me.txtDateDeb, Me.txtDatFin) / lpasmois)
    
    nbrentsit = RsSite("nbrentsit") - NbVisitedejafaite ' nombre d'entretein qu'il reste à planifier
    If nbrentsit = 0 Then GoTo sitesuivant
    If VnouveauSite = True Then
        Dim Vnumvisite
        
        lDateDepart = dateDebut
        Vnumvisite = Round(DateDiff("d", lDateDepart, "31/12/" & Year(Date)) * RsSite("nbrentsit") / 365) 'calcul nombre de visite pour le nouveau site par rapport à la date()
        ''If Mid(Vnumvisite, Len(Vnumvisite), 1) > 1 Then
            ''Vnumvisite = Vnumvisite + 10
            
        'End If
       ' nbrentsit = Int(Vnumvisite / 10)
        If nbrentsit = 0 Then GoTo sitesuivant
        
    End If
    'If landernier = True Or VnouveauSite = True Then          'si aucune visite dans l'année
    If VnouveauSite = True Then                 '***************** modif du 15 03 2010
            VpasJour = Round(365 / nbrentsit)                    'calule l'interval entre 2 visite
            
            lDatPreInt = DateAdd("d", Round(VpasJour / 2), lDateDepart)     'date de premiere visite
    Else
            VpasJour = Round(DateDiff("d", lDateDepart, "31/12/" & Year(Date)) / (nbrentsit + 0.5))
            lDatPreInt = DateAdd("d", VpasJour, lDateDepart)
            If Year(lDatPreInt) - Year(Now()) = -1 Then
                lDatPreInt = DateAdd("m", 1, lDatPreInt)
            End If
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
        rsInsert("codint") = "FMC" 'RsSite("codint")
        rsInsert("datheuapp") = Null
        rsInsert.Update
        lDatPreInt = DateAdd("d", VpasJour, lDatPreInt)
        DoEvents
    Next
        'Loop
     rsInsert.Close
    End If
    
sitesuivant:

    RsSite.MoveNext
Loop
    Set rsInsert = Nothing
    RsSite.Close
    Set RsSite = Nothing
    DoCmd.Hourglass False
    compteur.Visible = False
    MsgBox "La génération des visites d'entretien s'est bien éffectuée.", vbInformation
    
TraitErrGenererOff:
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

Private Sub Form_Open(Cancel As Integer)
'dateDebut.Value = "01/01/" & Year(Date)
End Sub
