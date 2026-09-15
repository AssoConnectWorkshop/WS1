Attribute VB_Name = "Calcul"
Option Compare Database
Public Kadi_Logge As Boolean
Public NumGestEnCours As Integer
Public NomGestEnCours As String
Function Remplacer(sChaine As String) As String
    sTest = LCase(Left(sChaine, 3))
    Select Case sChaine
        Case "Mr"
            Remplacer = "M."
        Case "Melle", "Melle."
            Remplacer = "Mlle"
        Case Else
            If (sTest = "ouv") Then
            Remplacer = ""
            End If
    End Select
End Function
Function EstFerie(DateDonnee As Date) As Boolean
    On Error GoTo TraitErrFerie
    Dim rs As Recordset
    Set rs = CurrentDb.OpenRecordset("select * from joursferies", dbOpenSnapshot)
    EstFerie = False
    Do Until rs.EOF
        If Format(rs(1), "dd/mm/yyyy") = Format(DateDonnee, "dd/mm/yyyy") Then
            EstFerie = True
            Exit Do
        End If
        rs.MoveNext
    Loop
    rs.Close
    Set rs = Nothing
    Exit Function
TraitErrFerie:
    Select Case err.Number
        Case 3151
            Resume
        Case Else
            MsgBox err.Number & " " & err.Description
            DoCmd.Hourglass False
            Exit Function
    End Select
End Function
Function CalculerHeureLimite(DateHeure As Date) As Date

    Dim DateHeureMax As Date
    Dim DureeJour As Integer
    'Si c'est 9h l'heure d'arrivée
    'L'heure max est à 10h le lendemain
    'Si c'est 12h l'heure d'arrivée
    'L'heure max est à 13h le lendemain
    'Si c'est 16h l'heure d'arrivée
    
    Select Case Weekday(DateHeure)
    
        Case VbDayOfWeek.vbMonday
            NbrJouPlus = 1
        Case VbDayOfWeek.vbTuesday
            NbrJouPlus = 1
        Case VbDayOfWeek.vbWednesday
            NbrJouPlus = 1
        Case VbDayOfWeek.vbThursday
            NbrJouPlus = 1
        Case VbDayOfWeek.vbFriday
            NbrJouPlus = 3
        Case VbDayOfWeek.vbSaturday
            NbrJouPlus = 2
        Case VbDayOfWeek.vbSunday
            NbrJouPlus = 1
    End Select
    
    If Hour(DateHeure) >= 8 And Hour(DateHeure) < 11 Then
        DateHeureMax = DateAdd("d", NbrJouPlus, DateHeure)
        DateHeureMax = DateAdd("h", 1, DateHeureMax)
    End If
    If Hour(DateHeure) >= 11 And Hour(DateHeure) < 12 Then
            DateHeureMax = DateAdd("d", NbrJouPlus, DateHeure)
            DateHeureMax = Format(DateHeureMax, "dd/mm/yyyy") & " 14:" & Minute(DateHeure) & ":00"
    End If
    If Hour(DateHeure) >= 12 And Hour(DateHeure) < 14 Then
            DateHeureMax = DateAdd("d", NbrJouPlus, DateHeure)
            DateHeureMax = Format(DateHeureMax, "dd/mm/yyyy") & " 15:00:00"
    End If
    If Hour(DateHeure) >= 14 And Hour(DateHeure) < 16 Then
            DateHeureMax = DateAdd("d", NbrJouPlus, DateHeure)
            DateHeureMax = DateAdd("h", 1, DateHeureMax)
    End If
    If Hour(DateHeure) >= 16 And Hour(DateHeure) < 17 Then
            If Weekday(DateHeure) = VbDayOfWeek.vbThursday Then
                DateHeureMax = DateAdd("d", NbrJouPlus + 3, DateHeure)
            Else
                DateHeureMax = DateAdd("d", NbrJouPlus + 1, DateHeure)
            End If
            DateHeureMax = Format(DateHeureMax, "dd/mm/yyyy") & " 08:" & Minute(DateHeure) & ":00"
    End If
    If Hour(DateHeure) >= 17 And Hour(DateHeure) <= 23 Then
            If Weekday(DateHeure) = VbDayOfWeek.vbThursday Then
                DateHeureMax = DateAdd("d", NbrJouPlus + 3, DateHeure)
            Else
                DateHeureMax = DateAdd("d", NbrJouPlus + 1, DateHeure)
            End If
            DateHeureMax = Format(DateHeureMax, "dd/mm/yyyy") & " 09:00:00"
    End If
    If Hour(DateHeure) >= 0 And Hour(DateHeure) < 8 Then
            If Weekday(DateHeure) = VbDayOfWeek.vbThursday Then
                DateHeureMax = DateAdd("d", NbrJouPlus + 2, DateHeure)
            Else
                DateHeureMax = DateAdd("d", NbrJouPlus, DateHeure)
            End If
            DateHeureMax = Format(DateHeureMax, "dd/mm/yyyy") & " 09:00:00"
    End If
    
    If EstFerie(DateHeureMax) Then
        DateHeureMax = DateAdd("d", 1, DateHeureMax)
    End If
    CalculerHeureLimite = DateHeureMax
    
End Function
Public Function GenererPlanningPrevisionnel()

On Error GoTo traiterrgenerer
Dim rs As Recordset
Dim rsplanning As Recordset
Dim rsdatint As Recordset

DoCmd.Hourglass True

CurrentDb.Execute "Delete from planning"

Set rs = CurrentDb.OpenRecordset("Select * from SiteEntretienPrevuDemixage_datintpre", dbOpenForwardOnly)
Set rsplanning = CurrentDb.OpenRecordset("Select * from Planning", dbOpenDynaset, dbSeeChanges)
Set rsparam = CurrentDb.OpenRecordset("Select * from Parametre", dbOpenDynaset, dbSeeChanges)
lDatePrm = Right(CStr(rsparam("datfin")), 4)

Do Until rs.EOF
    rsplanning.AddNew
    rsplanning("numsit") = rs("numsit")
    For lI = 1 To 52
        rsplanning("Semaine " & lI) = rs("Semaine " & lI)
    Next lI
    rsplanning.Update
    rs.MoveNext
Loop
Set rsdatint = CurrentDb.OpenRecordset("Select * from SiteEntretienPrevuDemixage_datint", dbOpenForwardOnly)
Do Until rsdatint.EOF
    lSQl = "Select * from planning where numsit=" & rsdatint("numsit")
    
    Set rs = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
    If Not rs.EOF Then
        rs.Edit
        For lI = 1 To 52
            If Format(rsdatint("Semaine " & lI), "yyyy") = lDatePrm Then
                rs("Semaine " & lI) = rs("Semaine " & lI) & rsdatint("Semaine " & lI)
            End If
        Next lI
        rs.Update
    End If
    rs.Close
    
    rsdatint.MoveNext
Loop

DoCmd.Hourglass False
traiterrgenerer:
    Exit Function
End Function

' Renvoie la date uniquement en fonction de la date et l'heure
Function DateOnly(ByVal DateHeure As String) As String

    DateOnly = Left(DateHeure, InStr(DateHeure, " ") - 1)
    
End Function

' Renvoie l'heure uniquement en fonction de la date et l'heure
Function HeureOnly(ByVal DateHeure As String) As String

    HeureOnly = Right(DateHeure, Len(DateHeure) - InStr(DateHeure, " "))
    
End Function
Function Verification_Droit_Modif(Nom As String, TypeRecherche As Boolean) As Boolean
    'TypeRecherche=false Par Nom
    'TypeRecherche=True par Index
    Dim QueKadi As Boolean
    If (Kadi_Logge) Then
        Verification_Droit_Modif = True
        Exit Function
    End If
    If (TypeRecherche) Then
        Requete = "SELECT * FROM dbo_StatutFacture where dbo_StatutFacture.Statut='" + Trim(Nom) + "'"
    Else
        Requete = "SELECT * FROM dbo_StatutFacture where dbo_StatutFacture.IndexLigne=" + Trim(Nom)
    End If
    'dbOpenSnapshot Pas de modif possible
    Set RsCodInt = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot, dbReadOnly)
    If Not RsCodInt.EOF Then
        QueKadi = RsCodInt("QueKadi")
        If (QueKadi = False) Then
            Verification_Droit_Modif = True
            Exit Function
        End If
    End If

    Verification_Droit_Modif = False
End Function
