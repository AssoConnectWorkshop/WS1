Attribute VB_Name = "Form_DevisListeContratDeMaintenance"
Attribute VB_Base = "0{90E1EB09-BEDB-48D6-8855-CE4B72BD1947}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Dim strFileName As String
Dim strBaseFileName As String
Private Sub MajMontantHT()
  If Me.NumeroClient <> "" Then
    lSQl = "SELECT coutheuremainoeuvre,coutdeplacement FROM client where numcli=" & Me.NumeroClient
    Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
    If Not lrs.EOF Then
        If IsNull(Me.txtcoutdeplacement) Or Me.txtcoutdeplacement = "" Then
            Me.txtcoutdeplacement = lrs("coutdeplacement")
        End If
        If IsNull(Me.txtcoutheuremainoeuvre) Or Me.txtcoutheuremainoeuvre = "" Then
            Me.txtcoutheuremainoeuvre = lrs("coutheuremainoeuvre")
        End If
    End If
    lrs.Close
    Set lrs = Nothing
End If
    If Me.txtcoutdeplacement <> "" And Me.txtcoutheuremainoeuvre <> "" And Me.MontantFournitureDevis <> "" And Me.NbreDeplacementDevis <> "" And Me.MainOeuvreDevis <> "" Then
        Me.MontantHTDevis = (txtcoutdeplacement * Me.NbreDeplacementDevis) + (Me.MontantFournitureDevis) + (Me.MainOeuvreDevis * Me.txtcoutheuremainoeuvre)
    End If
End Sub



Private Sub BpInsert_Click()
If (Me.AllowAdditions = True) Then
    Me.BpInsert.Caption = "Rendre Insertion Devis Possible"
    Me.AllowAdditions = False
    Me.Avert1.Visible = False
    Me.Avert2.Visible = False
Else
    Me.BpInsert.Caption = "Rendre Insertion Devis Impossible"
    Me.AllowAdditions = True
    Me.Avert1.Visible = True
    Me.Avert2.Visible = True
End If
End Sub

Private Sub cboClient_AfterUpdate()
    Call Filtrer
End Sub
Private Sub Filtrer()
    Dim bClient As Boolean
    Dim bSite As Boolean
    Dim bEtat As Boolean
    Dim bEnvoye As Boolean
    Dim bTypePanne As Boolean
    Dim bDateDebut As Boolean
    Dim bDateFin As Boolean
    
    Dim sFiltre As String
    sFiltre = ""
    
    If cboClient.Value <> 0 Then
        sFiltre = "NumeroClient=" & cboClient.Value
        bClient = True
    End If
    If CboSite.Value <> 0 Then
        If bClient Then
            sFiltre = sFiltre & " AND "
        End If
        sFiltre = sFiltre & " NumeroSite=" & CboSite.Value
        bSite = True
    End If
    If CboEtat.Value <> 0 Then
        If bClient Or bSite Then
            sFiltre = sFiltre & " AND "
        End If
        sFiltre = sFiltre & " StatutDevis=" & CboEtat.Value
    End If
    If CboEnvoyePar <> 0 Then
        If sFiltre <> "" Then
            sFiltre = sFiltre & " AND "
        End If
        sFiltre = sFiltre & "EnvoyePar = " & CboEnvoyePar.Value
    End If
    If CboType <> 0 Then
        If sFiltre <> "" Then
            sFiltre = sFiltre & " AND "
        End If
        sFiltre = sFiltre & "TypePanneDevis = " & Chr(34) & CboType.Value & Chr(34)
    End If
    If TxDateDebut <> "" And IsDate(TxDateDebut) And TxDateFin <> "" And IsDate(TxDateFin) Then
        If sFiltre <> "" Then
            sFiltre = sFiltre & " AND "
        End If
    sFiltre = sFiltre & " DateEnvoiDevis >= #" & Me.TxDateDebut & "# AND DateEnvoiDevis <= #" & Me.TxDateFin & "#"
    
    End If
    
    Me.Filter = sFiltre
    Me.FilterOn = True
    
End Sub

Private Sub CboEnvoyePar_AfterUpdate()
    Call Filtrer
End Sub

Private Sub CboEtat_AfterUpdate()
    Call Filtrer
End Sub

Private Sub CboSite_AfterUpdate()
    Call Filtrer
End Sub

Private Sub CboType_AfterUpdate()
    Call Filtrer
End Sub

Private Sub cmdGenerer_Click()

Dim rs As Recordset, rs2 As Recordset
Dim newid As Long
Dim codint As String

If Not IsNull(Me.NumeroInterventionInterne) Then
   
    Set rs = CurrentDb.OpenRecordset("select * from intervention where numintint=" & Me.NumeroInterventionInterne, dbOpenSnapshot)
    Set rs2 = CurrentDb.OpenRecordset("intervention", dbOpenSnapshot)
    If Not rs.EOF Then
        rs2.AddNew
        rs2("cptsit") = rs("cptsit")
        rs2("datheuapp") = Date
        rs2("objint") = Left(Left(Me.NomFichierDevis, InStr(Me.NomFichierDevis, "#") - 1), 500)
        rs2("staint") = 1
        rs2("typint") = 3
        Set rsI = CurrentDb.OpenRecordset("select codint from intervenant i inner join site s on s.numintervenant = i.numintervenant where s.cptsit=" & Me.NumeroSite, dbOpenSnapshot)
            If Not rsI.EOF Then
                codint = rsI("codint")
            End If
        rsI.Close
        rs2("codint") = codint
        rs2.Update
        rs2.Close
        Set rs2 = CurrentDb.OpenRecordset("select max(numintint) from intervention ", dbReadOnly, dbSeeChanges)
        If Not rs2.EOF Then
            newid = rs2(0)
        End If
        
    End If
Else
    Set rsI = CurrentDb.OpenRecordset("select codint from intervenant i inner join site s on s.numintervenant = i.numintervenant where s.cptsit=" & Me.NumeroSite, dbOpenSnapshot)
            If Not rsI.EOF Then
                codint = rsI("codint")
            End If
            rsI.Close
    Set rs2 = CurrentDb.OpenRecordset("intervention", dbOpenSnapshot)
        rs2.AddNew
        rs2("cptsit") = Me.NumeroSite
        rs2("datheuapp") = Date
        rs2("objint") = Left(Left(Me.NomFichierDevis, InStr(Me.NomFichierDevis, "#") - 1), 500)
        rs2("staint") = 1
        rs2("typint") = 3
        rs2("codint") = codint
        rs2("numdevacc") = Me.NumeroDevisInterne
        rs2.Update
        rs2.Close
        
    Set rs2 = CurrentDb.OpenRecordset("select max(numintint) from intervention ", dbOpenSnapshot)
    If Not rs2.EOF Then
        newid = rs2(0)
    End If
End If
Me.StatutDevis = 6 'à mettre à accepté par le client

DoCmd.OpenForm "Intervention", acNormal, , "numintint=" & newid, acFormEdit, acWindowNormal


End Sub

Private Sub Détail_Paint()
'1;"Devis à viser";2;"Visé, à envoyer";4;"Envoyé";3;"Devis annulé et remplacé par";6;"Devis accepté par le client";5;"Devis refusé par le client"
If (Me.CurrentRecord <> 0) Then
Select Case Me.StatutDevis  'the name of the control with the value to be tested
  Case 1
    Me.Détail.BackColor = RGB(255, 255, 102)  '(yellow)
  Case 5
    Me.Détail.BackColor = RGB(80, 80, 80)  '(grey)
  Case 3
    Me.Détail.BackColor = RGB(119, 181, 254) '(blue)
  Case 6
    Me.Détail.BackColor = RGB(240, 0, 0)  '(white)
  Case Else
    Me.Détail.BackColor = RGB(255, 255, 255)  '(white)
End Select
End If
End Sub

Private Sub Form_AfterInsert()
Me.BpInsert.Caption = "Rendre Insertion Devis Possible"
Me.AllowAdditions = False
Me.Avert1.Visible = False
Me.Avert2.Visible = False
End Sub

Private Sub MainOeuvreDevis_AfterUpdate()
Call MajMontantHT
End Sub

Private Sub MontantFournitureDevis_AfterUpdate()
Call MajMontantHT
End Sub

Private Sub NbreDeplacementDevis_AfterUpdate()
Call MajMontantHT
End Sub

Private Sub NomFichierDevis_AfterUpdate()
 Dim lSQl As String
    strBaseFileName = Me!NomFichierDevis
    If Me!NomFichierDevis <> "" Then
        strFileName = Right$(strBaseFileName, Len(strBaseFileName) - InStrRev(strBaseFileName, "\"))
        Me!NomFichierDevis = strFileName & strBaseFileName
        Me!NumeroDevis = Mid(strFileName, 7, 10)
        If Not IsNull(Me.NumeroInterventionInterne) Then
           'lSQl = "UpdateIntervention " & Me.NumeroInterventionInterne
           'CurrentDb.Execute lSql, dbSQLPassThrough
            PassThroughFixup "maj", lSQl, "", False
        End If
    End If
End Sub

Public Sub PassThroughFixup(QueryName As String, SQL As String, Connect As String, ReturnsRecords As Boolean)

  Dim cmd As ADODB.Command, rst As ADODB.Recordset
    Set cmd = New ADODB.Command
    
    cmd.ActiveConnection = "DSN=climaccess;UserId=climaccess;Password=[REDACTED]"
    cmd.CommandText = "UpdateIntervention"
    cmd.CommandType = adCmdStoredProc
    cmd.Parameters.Refresh
    cmd(1) = Me.NumeroInterventionInterne
    'Set rst = cmd.Execute()
    'Set Me.Form.Recordset = rst
    Set cmd = Nothing
End Sub


Private Sub NomFichierDevis_BeforeUpdate(Cancel As Integer)
   ' If IsNull(Me.DateEnvoiDevis) Then
   '     Me.DateEnvoiDevis = Date
   ' End If
End Sub

Private Sub TxDateDebut_AfterUpdate()
Call Filtrer
End Sub

Private Sub TxDateFin_AfterUpdate()
    Call Filtrer
End Sub

Private Sub txtcoutdeplacement_AfterUpdate()
Call MajMontantHT
End Sub

Private Sub txtcoutheuremainoeuvre_AfterUpdate()
Call MajMontantHT
End Sub
Private Sub Commande61_Click()
On Error GoTo Err_Commande61_Click


    If Me.Dirty Then Me.Dirty = False
    DoCmd.Close

Exit_Commande61_Click:
    Exit Sub

Err_Commande61_Click:
    MsgBox err.Description
    Resume Exit_Commande61_Click
    
End Sub
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
