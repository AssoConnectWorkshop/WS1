Attribute VB_Name = "Form_Planification"
Attribute VB_Base = "0{182BEC02-490B-4D18-B650-559264168F70}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub CmdFermer_Click()
On Error GoTo Err_CmdFermer_Click


    If Me.Dirty Then Me.Dirty = False
    DoCmd.Close

Exit_CmdFermer_Click:
    Exit Sub

Err_CmdFermer_Click:
    MsgBox err.Description
    Resume Exit_CmdFermer_Click
    
End Sub

Private Sub cmdGenerer_Click()

    Dim nbreEntretien As Long
    nbreEntretien = TxtNombreVisite
    Dim rs As Recordset
    Dim rsDup As Recordset
    Dim lSqlDup As String
    Dim Nb As Integer
    Dim StatutInt As Integer
    
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM SITE WHERE numcli=" & LstClient.Value & " AND nbrentsit=" & nbreEntretien, dbOpenDynaset, dbSeeChanges)
    
    Dim rsInsert As Recordset
    Set rsInsert = CurrentDb.OpenRecordset("Intervention", dbOpenDynaset, dbSeeChanges)
    
    DoCmd.Hourglass True
    Nb = 0
    
    Do Until rs.EOF
        
        StatutInt = 1
        '26/04/24 Ajout gestion ne pas intervenir
        'Cette donnée est ne pas intervenir
        If rs("majregistresecuritefait") <> "FAUX" Then
            'Forcage à ne pas intervenir
             StatutInt = 17
        End If
        
        Trouve = True
        lSQl = "delete from intervention where datheulim is not null and datint is null"
        lSQl = lSQl & " and cptsit = " & rs("cptsit")
        lSQl = lSQl & " and typint = " & "'1'"
        'CurrentDb.Execute lSql, dbSeeChanges
    
        For i = 1 To nbreEntretien
            
            rsInsert.AddNew
            'rsInsert("datheulim") = ""
            rsInsert("cptsit") = rs("cptsit")
            Select Case i
                Case 1
                    rsInsert("datheulim") = T1
                    If (DIENT1.Value <> "") Then
                        rsInsert("Refcliint") = DIENT1.Value
                    End If
                Case 2
                    rsInsert("datheulim") = T2
                    If (DIENT1.Value <> "") Then
                        rsInsert("Refcliint") = DIENT2.Value
                    End If
                Case 3
                    rsInsert("datheulim") = T3
                    If (DIENT1.Value <> "") Then
                        rsInsert("Refcliint") = DIENT3.Value
                    End If
                Case 4
                    rsInsert("datheulim") = T4
                    If (DIENT1.Value <> "") Then
                        rsInsert("Refcliint") = DIENT4.Value
                    End If
                Case 5
                    rsInsert("datheulim") = T5
                    If (DIENT1.Value <> "") Then
                        rsInsert("Refcliint") = DIENT5.Value
                    End If
                Case 6
                    rsInsert("datheulim") = T6
                    If (DIENT1.Value <> "") Then
                        rsInsert("Refcliint") = DIENT6.Value
                    End If
                Case 7
                    rsInsert("datheulim") = T7
                    If (DIENT1.Value <> "") Then
                        rsInsert("Refcliint") = DIENT7.Value
                    End If
                Case 8
                    rsInsert("datheulim") = T8
                    If (DIENT1.Value <> "") Then
                        rsInsert("Refcliint") = DIENT8.Value
                    End If
                Case 9
                    rsInsert("datheulim") = T9
                    If (DIENT1.Value <> "") Then
                        rsInsert("Refcliint") = DIENT9.Value
                    End If
                Case 10
                    rsInsert("datheulim") = T10
                    If (DIENT1.Value <> "") Then
                        rsInsert("Refcliint") = DIENT10.Value
                    End If
                Case 11
                    rsInsert("datheulim") = T11
                    If (DIENT1.Value <> "") Then
                        rsInsert("Refcliint") = DIENT11.Value
                    End If
                Case 12
                    rsInsert("datheulim") = T12
                    If (DIENT1.Text <> "") Then
                        rsInsert("refcliint") = DIENT12.Value
                    End If
            End Select
            rsInsert("typint") = "1"
            rsInsert("staint") = StatutInt
            
            
            'Recherche Intervenant Clim
            If IsNull(rs("NumSousTraitClim")) = False Then
                 Dim toto As String
                 toto = rs("nomsit")
                 Dim IntervClim As Recordset
                 Set IntervClim = CurrentDb.OpenRecordset("SELECT codint FROM INTERVENANT WHERE numintervenant=" & rs("NumSousTraitClim"), dbOpenDynaset, dbSeeChanges)
                 rsInsert("codint") = IntervClim("codint")
                 IntervClim.Close
            Else
                'Pas d'intervenant clim on recherche sur intervenant
                Dim rsI As Recordset
                Set rsI = CurrentDb.OpenRecordset("SELECT codint FROM INTERVENANT WHERE numintervenant=" & rs("numintervenant"), dbOpenDynaset, dbSeeChanges)
                If Not rsI.EOF Then
                    rsInsert("codint") = rsI("codint")
                Else
                    'On Fore à FMC
                    rsInsert("codint") = "FMC"
                End If
                rsI.Close
            End If
                  
            rsInsert("datheuapp") = Null
            
            If Not IsNull(rsInsert("datheulim")) Then
                'Attention la version avec datheulim=#" & rsInsert("datheulim") & "# ne marche pas sur mon PC mais chez Pierre oui ?????
                lSqlDup = "SELECT numintint from intervention where cptsit = " & rs("cptsit") & " and datheulim=#" & rsInsert("datheulim") & "# and typint='1'"
                Set rsDup = CurrentDb.OpenRecordset(lSqlDup, dbOpenDynaset, dbSeeChanges)
                ' Si une demande d'intervention de maintenance à planifier n'existe pas déjà pour le même site alors on saute
                If rsDup.EOF And Not IsNull(rsInsert("datheulim")) Then
                    rsInsert.Update
                    Nb = Nb + 1
                End If
                rsDup.Close
            End If
            
  
            DoEvents
        Next
        rs.MoveNext
    Loop
    
    rs.Close
    
    DoCmd.Hourglass False
    MsgBox "La génération de " + Str(Nb) + " visites d'entretien s'est bien éffectuée.", vbInformation


End Sub

Private Sub Commande125_Click()

    Dim rs As Recordset
    Dim rsDup As Recordset
    Dim lSqlDup As String
    Dim Nb As Integer
    Dim StatutInt As Integer
    toto1 = "SELECT * FROM SITE WHERE numcli=" & LstClient.Value & " AND NombreContratChaudiere=" & NbChaud.Value
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM SITE WHERE numcli=" & LstClient.Value & " AND NombreContratChaudiere=" & NbChaud.Value, dbOpenDynaset, dbSeeChanges)
    
    Dim rsInsert As Recordset
    Set rsInsert = CurrentDb.OpenRecordset("Intervention", dbOpenDynaset, dbSeeChanges)
    
    DoCmd.Hourglass True
    Nb = 0
    
    Do Until rs.EOF
        
        StatutInt = 1
        '26/04/24 Ajout gestion ne pas intervenir
        'Cette donnée est ne pas intervenir
        If rs("majregistresecuritefait") <> "FAUX" Then
            'Forcage à ne pas intervenir
             StatutInt = 17
        End If
        
        Trouve = True
        lSQl = "delete from intervention where datheulim is not null and datint is null"
        lSQl = lSQl & " and cptsit = " & rs("cptsit")
        lSQl = lSQl & " and typint = '1'"
        'CurrentDb.Execute lSql, dbSeeChanges
    
        For i = 1 To NbChaud
            
            rsInsert.AddNew
            'rsInsert("datheulim") = ""
            rsInsert("cptsit") = rs("cptsit")
            Select Case i
                Case 1
                    rsInsert("datheulim") = ChaudT1
                    If (DICHAUD1.Value <> "") Then
                        rsInsert("Refcliint") = DICHAUD1.Value
                    End If
                Case 2
                    rsInsert("datheulim") = ChaudT2
                    If (DICHAUD1.Value <> "") Then
                        rsInsert("Refcliint") = DICHAUD2.Value
                    End If
                Case 3
                    rsInsert("datheulim") = ChaudT3
                    If (DICHAUD1.Value <> "") Then
                        rsInsert("Refcliint") = DICHAUD3.Value
                    End If
                Case 4
                    rsInsert("datheulim") = ChaudT4
                    If (DICHAUD1.Value <> "") Then
                        rsInsert("Refcliint") = DICHAUD4.Value
                    End If
                Case 5
                    rsInsert("datheulim") = ChaudT5
                    If (DICHAUD1.Value <> "") Then
                        rsInsert("Refcliint") = DICHAUD5.Value
                    End If
                Case 6
                    rsInsert("datheulim") = ChaudT6
                    If (DICHAUD1.Value <> "") Then
                        rsInsert("Refcliint") = DICHAUD6.Value
                    End If
                Case 7
                    rsInsert("datheulim") = ChaudT7
                    If (DICHAUD1.Value <> "") Then
                        rsInsert("Refcliint") = DICHAUD7.Value
                    End If
                Case 8
                    rsInsert("datheulim") = ChaudT8
                    If (DICHAUD1.Value <> "") Then
                        rsInsert("Refcliint") = DICHAUD8.Value
                    End If
                Case 9
                    rsInsert("datheulim") = ChaudT9
                    If (DICHAUD1.Value <> "") Then
                        rsInsert("Refcliint") = DICHAUD9.Value
                    End If
                Case 10
                    rsInsert("datheulim") = ChaudT10
                    If (DICHAUD1.Value <> "") Then
                        rsInsert("Refcliint") = DICHAUD10.Value
                    End If
                Case 11
                    rsInsert("datheulim") = ChaudT11
                    If (DICHAUD1.Value <> "") Then
                        rsInsert("Refcliint") = DICHAUD11.Value
                    End If
                Case 12
                    rsInsert("datheulim") = ChaudT12
                    If (DICHAUD1.Text <> "") Then
                        rsInsert("refcliint") = DICHAUD12.Value
                    End If
            End Select
            '19/08/25 Maintenant l'inter est de type Entretien Chaudiere (13) avant c'etait entretien (1)
            rsInsert("typint") = "13"
            rsInsert("staint") = StatutInt
            
            
            'Recherche Intervenant Chaudiere
            If IsNull(rs("NumSousTraitChaudiere")) = False Then
                 
                 Dim IntervChaud As Recordset
                 Set IntervChaud = CurrentDb.OpenRecordset("SELECT codint FROM INTERVENANT WHERE numintervenant=" & rs("NumSousTraitChaudiere"), dbOpenDynaset, dbSeeChanges)
                 rsInsert("codint") = IntervChaud("codint")
                 IntervChaud.Close
                 
            Else
                Dim toto As String
                toto = rs("nomsit")
                MsgBox "Attention pas d'intervenant chaudiere pour " + toto, vbCritical
                'Pas d'intervenant clim on recherche sur intervenant
                Dim rsI As Recordset
                Set rsI = CurrentDb.OpenRecordset("SELECT codint FROM INTERVENANT WHERE numintervenant=" & rs("numintervenant"), dbOpenDynaset, dbSeeChanges)
                If Not rsI.EOF Then
                    rsInsert("codint") = rsI("codint")
                Else
                    'On Force à FMC
                    rsInsert("codint") = "FMC"
                End If
                rsI.Close
            End If
                  
            rsInsert("datheuapp") = Null
            
            If Not IsNull(rsInsert("datheulim")) Then
                rsInsert.Update
                Nb = Nb + 1
            End If
            
            
            DoEvents
        Next
        rs.MoveNext
    Loop
    
    rs.Close
    
    DoCmd.Hourglass False
    MsgBox "La génération de " + Str(Nb) + " visites de chaudiere s'est bien éffectuée.", vbInformation

End Sub

Private Sub Commande167_Click()
Dim nbreEntretien As Long
    Dim rs As Recordset
    Dim rsDup As Recordset
    Dim lSqlDup As String
    Dim Nb As Integer
    Dim StatutInt As Integer
    toto1 = "SELECT * FROM SITE WHERE numcli=" & LstClient.Value & " AND nombrevisitedesenfumage=" & NbChaud.Value
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM SITE WHERE numcli=" & LstClient.Value & " AND nombrevisitedesenfumage=" & Me.NbDesen.Value, dbOpenDynaset, dbSeeChanges)
    
    Dim rsInsert As Recordset
    Set rsInsert = CurrentDb.OpenRecordset("Intervention", dbOpenDynaset, dbSeeChanges)
    
    DoCmd.Hourglass True
    Nb = 0
    
    Do Until rs.EOF
                
        StatutInt = 1
        '26/04/24 Ajout gestion ne pas intervenir
        'Cette donnée est ne pas intervenir
        If rs("majregistresecuritefait") <> "FAUX" Then
            'Forcage à ne pas intervenir
             StatutInt = 17
        End If
                
        Trouve = True
        lSQl = "delete from intervention where datheulim is not null and datint is null"
        lSQl = lSQl & " and cptsit = " & rs("cptsit")
        lSQl = lSQl & " and typint = '1'"
        'CurrentDb.Execute lSql, dbSeeChanges
    
        For i = 1 To NbDesen
            
            rsInsert.AddNew
            'rsInsert("datheulim") = ""
            rsInsert("cptsit") = rs("cptsit")
            Select Case i
                Case 1
                    rsInsert("datheulim") = DesenT1
                    If (DIDESEN1.Value <> "") Then
                        rsInsert("Refcliint") = DIDESEN1.Value
                    End If
                Case 2
                    rsInsert("datheulim") = DesenT2
                    If (DIDESEN1.Value <> "") Then
                        rsInsert("Refcliint") = DIDESEN2.Value
                    End If
                Case 3
                    rsInsert("datheulim") = DesenT3
                    If (DIDESEN1.Value <> "") Then
                        rsInsert("Refcliint") = DIDESEN3.Value
                    End If
                Case 4
                    rsInsert("datheulim") = DesenT4
                    If (DIDESEN1.Value <> "") Then
                        rsInsert("Refcliint") = DIDESEN4.Value
                    End If
                Case 5
                    rsInsert("datheulim") = DesenT5
                    If (DIDESEN1.Value <> "") Then
                        rsInsert("Refcliint") = DIDESEN5.Value
                    End If
                Case 6
                    rsInsert("datheulim") = DesenT6
                    If (DIDESEN1.Value <> "") Then
                        rsInsert("Refcliint") = DIDESEN6.Value
                    End If
                Case 7
                    rsInsert("datheulim") = DesenT7
                    If (DIDESEN1.Value <> "") Then
                        rsInsert("Refcliint") = DIDESEN7.Value
                    End If
                Case 8
                    rsInsert("datheulim") = DesenT8
                    If (DIDESEN1.Value <> "") Then
                        rsInsert("Refcliint") = DIDESEN8.Value
                    End If
                Case 9
                    rsInsert("datheulim") = DesenT9
                    If (DIDESEN1.Value <> "") Then
                        rsInsert("Refcliint") = DIDESEN9.Value
                    End If
                Case 10
                    rsInsert("datheulim") = DesenT10
                    If (DIDESEN1.Value <> "") Then
                        rsInsert("Refcliint") = DIDESEN10.Value
                    End If
                Case 11
                    rsInsert("datheulim") = DesenT11
                    If (DIDESEN1.Value <> "") Then
                        rsInsert("Refcliint") = DIDESEN11.Value
                    End If
                Case 12
                    rsInsert("datheulim") = DesenT12
                    If (DIDESEN1.Text <> "") Then
                        rsInsert("refcliint") = DIDESEN12.Value
                    End If
            End Select
            rsInsert("typint") = "1"
            rsInsert("staint") = StatutInt
            
            
            'Recherche Intervenant Desenfumage
            If IsNull(rs("NumSousTraitDesenfum")) = False Then
                 
                 Dim IntervDesen As Recordset
                 Set IntervDesen = CurrentDb.OpenRecordset("SELECT codint FROM INTERVENANT WHERE numintervenant=" & rs("NumSousTraitDesenfum"), dbOpenDynaset, dbSeeChanges)
                 rsInsert("codint") = IntervDesen("codint")
                 IntervDesen.Close
                 
            Else
                Dim toto As String
                toto = rs("nomsit")
                MsgBox "Attention pas d'intervenant Desenfumage pour " + toto, vbCritical
                'Pas d'intervenant clim on recherche sur intervenant
                Dim rsI As Recordset
                Set rsI = CurrentDb.OpenRecordset("SELECT codint FROM INTERVENANT WHERE numintervenant=" & rs("numintervenant"), dbOpenDynaset, dbSeeChanges)
                If Not rsI.EOF Then
                    rsInsert("codint") = rsI("codint")
                Else
                    'On Fore à FMC
                    rsInsert("codint") = "FMC"
                End If
                rsI.Close
            End If
                  
            rsInsert("datheuapp") = Null
            
            If Not IsNull(rsInsert("datheulim")) Then
                rsInsert.Update
                Nb = Nb + 1
            End If
            
            
            DoEvents
        Next
        rs.MoveNext
    Loop
    
    rs.Close
    
    DoCmd.Hourglass False
    MsgBox "La génération de " + Str(Nb) + " visites de desenfumage s'est bien éffectuée.", vbInformation
End Sub

Private Sub Form_Current()
    Call Affichage
End Sub

Private Sub Affichage()
    T1.Visible = False: L1.Visible = False: DIENT1.Visible = False
    T2.Visible = False: L2.Visible = False: DIENT2.Visible = False
    T3.Visible = False: L3.Visible = False: DIENT3.Visible = False
    T4.Visible = False: L4.Visible = False: DIENT4.Visible = False
    T5.Visible = False: L5.Visible = False: DIENT5.Visible = False
    T6.Visible = False: L6.Visible = False: DIENT6.Visible = False
    T7.Visible = False: L7.Visible = False: DIENT7.Visible = False
    T8.Visible = False: L8.Visible = False: DIENT8.Visible = False
    T9.Visible = False: L9.Visible = False: DIENT9.Visible = False
    T10.Visible = False: L10.Visible = False: DIENT10.Visible = False
    T11.Visible = False: L11.Visible = False: DIENT11.Visible = False
    T12.Visible = False: L12.Visible = False: DIENT12.Visible = False

    Select Case TxtNombreVisite
        Case 1
            T1.Visible = True: L1.Visible = True: DIENT1.Visible = True
        Case 2
            T1.Visible = True: L1.Visible = True: DIENT1.Visible = True
            T2.Visible = True: L2.Visible = True: DIENT2.Visible = True
        Case 3
            T1.Visible = True: L1.Visible = True: DIENT1.Visible = True
            T2.Visible = True: L2.Visible = True: DIENT2.Visible = True
            T3.Visible = True: L3.Visible = True: DIENT3.Visible = True
        Case 4
            T1.Visible = True: L1.Visible = True: DIENT1.Visible = True
            T2.Visible = True: L2.Visible = True: DIENT2.Visible = True
            T3.Visible = True: L3.Visible = True: DIENT3.Visible = True
            T4.Visible = True: L4.Visible = True: DIENT4.Visible = True
        Case 5
            T1.Visible = True: L1.Visible = True: DIENT1.Visible = True
            T2.Visible = True: L2.Visible = True: DIENT2.Visible = True
            T3.Visible = True: L3.Visible = True: DIENT3.Visible = True
            T4.Visible = True: L4.Visible = True: DIENT4.Visible = True
            T5.Visible = True: L5.Visible = True: DIENT5.Visible = True
        Case 6
            T1.Visible = True: L1.Visible = True: DIENT1.Visible = True
            T2.Visible = True: L2.Visible = True: DIENT2.Visible = True
            T3.Visible = True: L3.Visible = True: DIENT3.Visible = True
            T4.Visible = True: L4.Visible = True: DIENT4.Visible = True
            T5.Visible = True: L5.Visible = True: DIENT5.Visible = True
            T6.Visible = True: L6.Visible = True: DIENT6.Visible = True
        Case 7
            T1.Visible = True: L1.Visible = True: DIENT1.Visible = True
            T2.Visible = True: L2.Visible = True: DIENT2.Visible = True
            T3.Visible = True: L3.Visible = True: DIENT3.Visible = True
            T4.Visible = True: L4.Visible = True: DIENT4.Visible = True
            T5.Visible = True: L5.Visible = True: DIENT5.Visible = True
            T6.Visible = True: L6.Visible = True: DIENT6.Visible = True
            T7.Visible = True: L7.Visible = True: DIENT7.Visible = True
        Case 8
            T1.Visible = True: L1.Visible = True: DIENT1.Visible = True
            T2.Visible = True: L2.Visible = True: DIENT2.Visible = True
            T3.Visible = True: L3.Visible = True: DIENT3.Visible = True
            T4.Visible = True: L4.Visible = True: DIENT4.Visible = True
            T5.Visible = True: L5.Visible = True: DIENT5.Visible = True
            T6.Visible = True: L6.Visible = True: DIENT6.Visible = True
            T7.Visible = True: L7.Visible = True: DIENT7.Visible = True
            T8.Visible = True: L8.Visible = True: DIENT8.Visible = True
        Case 9
            T1.Visible = True: L1.Visible = True: DIENT1.Visible = True
            T2.Visible = True: L2.Visible = True: DIENT2.Visible = True
            T3.Visible = True: L3.Visible = True: DIENT3.Visible = True
            T4.Visible = True: L4.Visible = True: DIENT4.Visible = True
            T5.Visible = True: L5.Visible = True: DIENT5.Visible = True
            T6.Visible = True: L6.Visible = True: DIENT6.Visible = True
            T7.Visible = True: L7.Visible = True: DIENT7.Visible = True
            T8.Visible = True: L8.Visible = True: DIENT8.Visible = True
            T9.Visible = True: L9.Visible = True: DIENT9.Visible = True
            
        Case 10
            T1.Visible = True: L1.Visible = True: DIENT1.Visible = True
            T2.Visible = True: L2.Visible = True: DIENT2.Visible = True
            T3.Visible = True: L3.Visible = True: DIENT3.Visible = True
            T4.Visible = True: L4.Visible = True: DIENT4.Visible = True
            T5.Visible = True: L5.Visible = True: DIENT5.Visible = True
            T6.Visible = True: L6.Visible = True: DIENT6.Visible = True
            T7.Visible = True: L7.Visible = True: DIENT7.Visible = True
            T8.Visible = True: L8.Visible = True: DIENT8.Visible = True
            T9.Visible = True: L9.Visible = True: DIENT9.Visible = True
            T10.Visible = True: L10.Visible = True: DIENT10.Visible = True
        Case 11
            T1.Visible = True: L1.Visible = True: DIENT1.Visible = True
            T2.Visible = True: L2.Visible = True: DIENT2.Visible = True
            T3.Visible = True: L3.Visible = True: DIENT3.Visible = True
            T4.Visible = True: L4.Visible = True: DIENT4.Visible = True
            T5.Visible = True: L5.Visible = True: DIENT5.Visible = True
            T6.Visible = True: L6.Visible = True: DIENT6.Visible = True
            T7.Visible = True: L7.Visible = True: DIENT7.Visible = True
            T8.Visible = True: L8.Visible = True: DIENT8.Visible = True
            T9.Visible = True: L9.Visible = True: DIENT9.Visible = True
            T10.Visible = True: L10.Visible = True: DIENT10.Visible = True
            T11.Visible = True: L11.Visible = True: DIENT11.Visible = True
            
        Case 12
            T1.Visible = True: L1.Visible = True: DIENT1.Visible = True
            T2.Visible = True: L2.Visible = True: DIENT2.Visible = True
            T3.Visible = True: L3.Visible = True: DIENT3.Visible = True
            T4.Visible = True: L4.Visible = True: DIENT4.Visible = True
            T5.Visible = True: L5.Visible = True: DIENT5.Visible = True
            T6.Visible = True: L6.Visible = True: DIENT6.Visible = True
            T7.Visible = True: L7.Visible = True: DIENT7.Visible = True
            T8.Visible = True: L8.Visible = True: DIENT8.Visible = True
            T9.Visible = True: L9.Visible = True: DIENT9.Visible = True
            T10.Visible = True: L10.Visible = True: DIENT10.Visible = True
            T11.Visible = True: L11.Visible = True: DIENT11.Visible = True
            T12.Visible = True: L12.Visible = True: DIENT12.Visible = True
    End Select
End Sub

Private Sub NbChaud_AfterUpdate()
    ChaudT1.Visible = False: LC1.Visible = False: DICHAUD1.Visible = False
    ChaudT2.Visible = False: LC2.Visible = False: DICHAUD2.Visible = False
    ChaudT3.Visible = False: LC3.Visible = False: DICHAUD3.Visible = False
    ChaudT4.Visible = False: LC4.Visible = False: DICHAUD4.Visible = False
    ChaudT5.Visible = False: LC5.Visible = False: DICHAUD5.Visible = False
    ChaudT6.Visible = False: LC6.Visible = False: DICHAUD6.Visible = False
    ChaudT7.Visible = False: LC7.Visible = False: DICHAUD7.Visible = False
    ChaudT8.Visible = False: LC8.Visible = False: DICHAUD8.Visible = False
    ChaudT9.Visible = False: LC9.Visible = False: DICHAUD9.Visible = False
    ChaudT10.Visible = False: LC10.Visible = False: DICHAUD10.Visible = False
    ChaudT11.Visible = False: LC11.Visible = False: DICHAUD11.Visible = False
    ChaudT12.Visible = False: LC12.Visible = False: DICHAUD12.Visible = False

    Select Case NbChaud
        Case 1
            ChaudT1.Visible = True: LC1.Visible = True: DICHAUD1.Visible = True
        Case 2
            ChaudT1.Visible = True: LC1.Visible = True: DICHAUD1.Visible = True
            ChaudT2.Visible = True: LC2.Visible = True: DICHAUD2.Visible = True
        Case 3
            ChaudT1.Visible = True: LC1.Visible = True: DICHAUD1.Visible = True
            ChaudT2.Visible = True: LC2.Visible = True: DICHAUD2.Visible = True
            ChaudT3.Visible = True: LC3.Visible = True: DICHAUD3.Visible = True
        Case 4
            ChaudT1.Visible = True: LC1.Visible = True: DICHAUD1.Visible = True
            ChaudT2.Visible = True: LC2.Visible = True: DICHAUD2.Visible = True
            ChaudT3.Visible = True: LC3.Visible = True: DICHAUD3.Visible = True
            ChaudT4.Visible = True: LC4.Visible = True: DICHAUD4.Visible = True
        Case 5
            ChaudT1.Visible = True: LC1.Visible = True: DICHAUD1.Visible = True
            ChaudT2.Visible = True: LC2.Visible = True: DICHAUD2.Visible = True
            ChaudT3.Visible = True: LC3.Visible = True: DICHAUD3.Visible = True
            ChaudT4.Visible = True: LC4.Visible = True: DICHAUD4.Visible = True
            ChaudT5.Visible = True: LC5.Visible = True: DICHAUD5.Visible = True
        Case 6
            ChaudT1.Visible = True: LC1.Visible = True: DICHAUD1.Visible = True
            ChaudT2.Visible = True: LC2.Visible = True: DICHAUD2.Visible = True
            ChaudT3.Visible = True: LC3.Visible = True: DICHAUD3.Visible = True
            ChaudT4.Visible = True: LC4.Visible = True: DICHAUD4.Visible = True
            ChaudT5.Visible = True: LC5.Visible = True: DICHAUD5.Visible = True
            ChaudT6.Visible = True: LC6.Visible = True: DICHAUD6.Visible = True
        Case 7
            ChaudT1.Visible = True: LC1.Visible = True: DICHAUD1.Visible = True
            ChaudT2.Visible = True: LC2.Visible = True: DICHAUD2.Visible = True
            ChaudT3.Visible = True: LC3.Visible = True: DICHAUD3.Visible = True
            ChaudT4.Visible = True: LC4.Visible = True: DICHAUD4.Visible = True
            ChaudT5.Visible = True: LC5.Visible = True: DICHAUD5.Visible = True
            ChaudT6.Visible = True: LC6.Visible = True: DICHAUD6.Visible = True
            ChaudT7.Visible = True: LC7.Visible = True: DICHAUD7.Visible = True
        Case 8
            ChaudT1.Visible = True: LC1.Visible = True: DICHAUD1.Visible = True
            ChaudT2.Visible = True: LC2.Visible = True: DICHAUD2.Visible = True
            ChaudT3.Visible = True: LC3.Visible = True: DICHAUD3.Visible = True
            ChaudT4.Visible = True: LC4.Visible = True: DICHAUD4.Visible = True
            ChaudT5.Visible = True: LC5.Visible = True: DICHAUD5.Visible = True
            ChaudT6.Visible = True: LC6.Visible = True: DICHAUD6.Visible = True
            ChaudT7.Visible = True: LC7.Visible = True: DICHAUD7.Visible = True
            ChaudT8.Visible = True: LC8.Visible = True: DICHAUD8.Visible = True
        Case 9
            ChaudT1.Visible = True: LC1.Visible = True: DICHAUD1.Visible = True
            ChaudT2.Visible = True: LC2.Visible = True: DICHAUD2.Visible = True
            ChaudT3.Visible = True: LC3.Visible = True: DICHAUD3.Visible = True
            ChaudT4.Visible = True: LC4.Visible = True: DICHAUD4.Visible = True
            ChaudT5.Visible = True: LC5.Visible = True: DICHAUD5.Visible = True
            ChaudT6.Visible = True: LC6.Visible = True: DICHAUD6.Visible = True
            ChaudT7.Visible = True: LC7.Visible = True: DICHAUD7.Visible = True
            ChaudT8.Visible = True: LC8.Visible = True: DICHAUD8.Visible = True
            ChaudT9.Visible = True: LC9.Visible = True: DICHAUD9.Visible = True
            
        Case 10
            ChaudT1.Visible = True: LC1.Visible = True: DICHAUD1.Visible = True
            ChaudT2.Visible = True: LC2.Visible = True: DICHAUD2.Visible = True
            ChaudT3.Visible = True: LC3.Visible = True: DICHAUD3.Visible = True
            ChaudT4.Visible = True: LC4.Visible = True: DICHAUD4.Visible = True
            ChaudT5.Visible = True: LC5.Visible = True: DICHAUD5.Visible = True
            ChaudT6.Visible = True: LC6.Visible = True: DICHAUD6.Visible = True
            ChaudT7.Visible = True: LC7.Visible = True: DICHAUD7.Visible = True
            ChaudT8.Visible = True: LC8.Visible = True: DICHAUD8.Visible = True
            ChaudT9.Visible = True: LC9.Visible = True: DICHAUD9.Visible = True
            ChaudT10.Visible = True: LC10.Visible = True: DICHAUD10.Visible = True
        Case 11
            ChaudT1.Visible = True: LC1.Visible = True: DICHAUD1.Visible = True
            ChaudT2.Visible = True: LC2.Visible = True: DICHAUD2.Visible = True
            ChaudT3.Visible = True: LC3.Visible = True: DICHAUD3.Visible = True
            ChaudT4.Visible = True: LC4.Visible = True: DICHAUD4.Visible = True
            ChaudT5.Visible = True: LC5.Visible = True: DICHAUD5.Visible = True
            ChaudT6.Visible = True: LC6.Visible = True: DICHAUD6.Visible = True
            ChaudT7.Visible = True: LC7.Visible = True: DICHAUD7.Visible = True
            ChaudT8.Visible = True: LC8.Visible = True: DICHAUD8.Visible = True
            ChaudT9.Visible = True: LC9.Visible = True: DICHAUD9.Visible = True
            ChaudT10.Visible = True: LC10.Visible = True: DICHAUD10.Visible = True
            ChaudT11.Visible = True: LC11.Visible = True: DICHAUD11.Visible = True
            
        Case 12
            ChaudT1.Visible = True: LC1.Visible = True: DICHAUD1.Visible = True
            ChaudT2.Visible = True: LC2.Visible = True: DICHAUD2.Visible = True
            ChaudT3.Visible = True: LC3.Visible = True: DICHAUD3.Visible = True
            ChaudT4.Visible = True: LC4.Visible = True: DICHAUD4.Visible = True
            ChaudT5.Visible = True: LC5.Visible = True: DICHAUD5.Visible = True
            ChaudT6.Visible = True: LC6.Visible = True: DICHAUD6.Visible = True
            ChaudT7.Visible = True: LC7.Visible = True: DICHAUD7.Visible = True
            ChaudT8.Visible = True: LC8.Visible = True: DICHAUD8.Visible = True
            ChaudT9.Visible = True: LC9.Visible = True: DICHAUD9.Visible = True
            ChaudT10.Visible = True: LC10.Visible = True: DICHAUD10.Visible = True
            ChaudT11.Visible = True: LC11.Visible = True: DICHAUD11.Visible = True
            ChaudT12.Visible = True: LC12.Visible = True: DICHAUD12.Visible = True
    End Select
End Sub

Private Sub NbDesen_AfterUpdate()
    DesenT1.Visible = False: LD1.Visible = False: DIDESEN1.Visible = False
    DesenT2.Visible = False: LD2.Visible = False: DIDESEN2.Visible = False
    DesenT3.Visible = False: LD3.Visible = False: DIDESEN3.Visible = False
    DesenT4.Visible = False: LD4.Visible = False: DIDESEN4.Visible = False
    DesenT5.Visible = False: LD5.Visible = False: DIDESEN5.Visible = False
    DesenT6.Visible = False: LD6.Visible = False: DIDESEN6.Visible = False
    DesenT7.Visible = False: LD7.Visible = False: DIDESEN7.Visible = False
    DesenT8.Visible = False: LD8.Visible = False: DIDESEN8.Visible = False
    DesenT9.Visible = False: LD9.Visible = False: DIDESEN9.Visible = False
    DesenT10.Visible = False: LD10.Visible = False: DIDESEN10.Visible = False
    DesenT11.Visible = False: LD11.Visible = False: DIDESEN11.Visible = False
    DesenT12.Visible = False: LD12.Visible = False: DIDESEN12.Visible = False

    Select Case Me.NbDesen
        Case 1
            DesenT1.Visible = True: LD1.Visible = True: DIDESEN1.Visible = True
        Case 2
            DesenT1.Visible = True: LD1.Visible = True: DIDESEN1.Visible = True
            DesenT2.Visible = True: LD2.Visible = True: DIDESEN2.Visible = True
        Case 3
            DesenT1.Visible = True: LD1.Visible = True: DIDESEN1.Visible = True
            DesenT2.Visible = True: LD2.Visible = True: DIDESEN2.Visible = True
            DesenT3.Visible = True: LD3.Visible = True: DIDESEN3.Visible = True
        Case 4
            DesenT1.Visible = True: LD1.Visible = True: DIDESEN1.Visible = True
            DesenT2.Visible = True: LD2.Visible = True: DIDESEN2.Visible = True
            DesenT3.Visible = True: LD3.Visible = True: DIDESEN3.Visible = True
            DesenT4.Visible = True: LD4.Visible = True: DIDESEN4.Visible = True
        Case 5
            DesenT1.Visible = True: LD1.Visible = True: DIDESEN1.Visible = True
            DesenT2.Visible = True: LD2.Visible = True: DIDESEN2.Visible = True
            DesenT3.Visible = True: LD3.Visible = True: DIDESEN3.Visible = True
            DesenT4.Visible = True: LD4.Visible = True: DIDESEN4.Visible = True
            DesenT5.Visible = True: LD5.Visible = True: DIDESEN5.Visible = True
        Case 6
            DesenT1.Visible = True: LD1.Visible = True: DIDESEN1.Visible = True
            DesenT2.Visible = True: LD2.Visible = True: DIDESEN2.Visible = True
            DesenT3.Visible = True: LD3.Visible = True: DIDESEN3.Visible = True
            DesenT4.Visible = True: LD4.Visible = True: DIDESEN4.Visible = True
            DesenT5.Visible = True: LD5.Visible = True: DIDESEN5.Visible = True
            DesenT6.Visible = True: LD6.Visible = True: DIDESEN6.Visible = True
        Case 7
            DesenT1.Visible = True: LD1.Visible = True: DIDESEN1.Visible = True
            DesenT2.Visible = True: LD2.Visible = True: DIDESEN2.Visible = True
            DesenT3.Visible = True: LD3.Visible = True: DIDESEN3.Visible = True
            DesenT4.Visible = True: LD4.Visible = True: DIDESEN4.Visible = True
            DesenT5.Visible = True: LD5.Visible = True: DIDESEN5.Visible = True
            DesenT6.Visible = True: LD6.Visible = True: DIDESEN6.Visible = True
            DesenT7.Visible = True: LD7.Visible = True: DIDESEN7.Visible = True
        Case 8
            DesenT1.Visible = True: LD1.Visible = True: DIDESEN1.Visible = True
            DesenT2.Visible = True: LD2.Visible = True: DIDESEN2.Visible = True
            DesenT3.Visible = True: LD3.Visible = True: DIDESEN3.Visible = True
            DesenT4.Visible = True: LD4.Visible = True: DIDESEN4.Visible = True
            DesenT5.Visible = True: LD5.Visible = True: DIDESEN5.Visible = True
            DesenT6.Visible = True: LD6.Visible = True: DIDESEN6.Visible = True
            DesenT7.Visible = True: LD7.Visible = True: DIDESEN7.Visible = True
            DesenT8.Visible = True: LD8.Visible = True: DIDESEN8.Visible = True
        Case 9
            DesenT1.Visible = True: LD1.Visible = True: DIDESEN1.Visible = True
            DesenT2.Visible = True: LD2.Visible = True: DIDESEN2.Visible = True
            DesenT3.Visible = True: LD3.Visible = True: DIDESEN3.Visible = True
            DesenT4.Visible = True: LD4.Visible = True: DIDESEN4.Visible = True
            DesenT5.Visible = True: LD5.Visible = True: DIDESEN5.Visible = True
            DesenT6.Visible = True: LD6.Visible = True: DIDESEN6.Visible = True
            DesenT7.Visible = True: LD7.Visible = True: DIDESEN7.Visible = True
            DesenT8.Visible = True: LD8.Visible = True: DIDESEN8.Visible = True
            DesenT9.Visible = True: LD9.Visible = True: DIDESEN9.Visible = True
            
        Case 10
            DesenT1.Visible = True: LD1.Visible = True: DIDESEN1.Visible = True
            DesenT2.Visible = True: LD2.Visible = True: DIDESEN2.Visible = True
            DesenT3.Visible = True: LD3.Visible = True: DIDESEN3.Visible = True
            DesenT4.Visible = True: LD4.Visible = True: DIDESEN4.Visible = True
            DesenT5.Visible = True: LD5.Visible = True: DIDESEN5.Visible = True
            DesenT6.Visible = True: LD6.Visible = True: DIDESEN6.Visible = True
            DesenT7.Visible = True: LD7.Visible = True: DIDESEN7.Visible = True
            DesenT8.Visible = True: LD8.Visible = True: DIDESEN8.Visible = True
            DesenT9.Visible = True: LD9.Visible = True: DIDESEN9.Visible = True
            DesenT10.Visible = True: LD10.Visible = True: DIDESEN10.Visible = True
        Case 11
            DesenT1.Visible = True: LD1.Visible = True: DIDESEN1.Visible = True
            DesenT2.Visible = True: LD2.Visible = True: DIDESEN2.Visible = True
            DesenT3.Visible = True: LD3.Visible = True: DIDESEN3.Visible = True
            DesenT4.Visible = True: LD4.Visible = True: DIDESEN4.Visible = True
            DesenT5.Visible = True: LD5.Visible = True: DIDESEN5.Visible = True
            DesenT6.Visible = True: LD6.Visible = True: DIDESEN6.Visible = True
            DesenT7.Visible = True: LD7.Visible = True: DIDESEN7.Visible = True
            DesenT8.Visible = True: LD8.Visible = True: DIDESEN8.Visible = True
            DesenT9.Visible = True: LD9.Visible = True: DIDESEN9.Visible = True
            DesenT10.Visible = True: LD10.Visible = True: DIDESEN10.Visible = True
            DesenT11.Visible = True: LD11.Visible = True: DIDESEN11.Visible = True
            
        Case 12
            DesenT1.Visible = True: LD1.Visible = True: DIDESEN1.Visible = True
            DesenT2.Visible = True: LD2.Visible = True: DIDESEN2.Visible = True
            DesenT3.Visible = True: LD3.Visible = True: DIDESEN3.Visible = True
            DesenT4.Visible = True: LD4.Visible = True: DIDESEN4.Visible = True
            DesenT5.Visible = True: LD5.Visible = True: DIDESEN5.Visible = True
            DesenT6.Visible = True: LD6.Visible = True: DIDESEN6.Visible = True
            DesenT7.Visible = True: LD7.Visible = True: DIDESEN7.Visible = True
            DesenT8.Visible = True: LD8.Visible = True: DIDESEN8.Visible = True
            DesenT9.Visible = True: LD9.Visible = True: DIDESEN9.Visible = True
            DesenT10.Visible = True: LD10.Visible = True: DIDESEN10.Visible = True
            DesenT11.Visible = True: LD11.Visible = True: DIDESEN11.Visible = True
            DesenT12.Visible = True: LD12.Visible = True: DIDESEN12.Visible = True
    End Select
End Sub

Private Sub TxtNombreVisite_AfterUpdate()

        Call Affichage
End Sub

