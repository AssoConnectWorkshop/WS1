Attribute VB_Name = "Form_DevisListeTravaux"
Attribute VB_Base = "0{338A28E0-AE40-4EF4-B8FC-544EE2697F37}"
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

'26/07/22 Changement du principe de la requete ->On fait un insert into car le update ne marche pas sur mon PC
'         De plus suppression des 2 cas si le numero interne existait deja ou pas ->Meme finalité
'03/07/24 Ajout du passage du NumCLient dans devis +Modif Date

Dim rs As Recordset, rs2 As Recordset
Dim newid As Long
Dim codint As String
Dim NumeroSite As String
Dim NumeroClient As String
Dim Req As String

NumeroSite = Me.NumeroSite
NumeroClient = Me.NumeroClient
Req = "select codint from intervenant i inner join site s on s.numintervenant = i.numintervenant where s.cptsit=" & Me.NumeroSite


'22/04/26 Passage en dbOpenSnapshotpour eviter des locks OM
Set rsI = CurrentDb.OpenRecordset(Req, dbOpenSnapshot)
If Not rsI.EOF Then
    codint = rsI("codint")
End If
rsI.Close
Set rsI = Nothing

Dim Message As String
Message = Left(Left(Me.NomFichierDevis, InStr(Me.NomFichierDevis, "#") - 1), 500)
Message = Replace(Message, """", " ")
Message = Replace(Message, "\", " ")
Message = Replace(Message, "'", " ")

'27/03/23 Ajout nbrpagfax (qui est le nombre d'heure main d'oeuvre) OM
If IsNull(Me.MainOeuvreDevis) Then
    NbHeuresMO = "0"
Else
    NbHeuresMO = Str(Me.MainOeuvreDevis)
End If

If IsNull(Me.MontantHTDevis) Then
    MontantDevis = "0"
Else
    MontantDevis = Str(Me.MontantHTDevis)
End If

'03/07/24 On enleve les # # entre les dates car cela mets la date en anglais OM
'         Declaration en string de REQ sinon longueur de la chaine gene
'22/04/26 Ajoutdu montant HT dans mnthtdevpartenaire OM
Req = "INSERT INTO intervention (cptsit, datheuapp,objint,staint,typint,codint,numdevacc,nbrpagfax,mnthtdevpartenaire) VALUES (" + Str(Me.NumeroSite) + ",'" + Str(Date) + "','" + Message + "',1,5,'" + codint + "','" + Me.NumeroDevisInterne + "'," + NbHeuresMO + "," + MontantDevis + ")"
Req1 = Str(Me.NumeroSite) + ",'" + Str(Date) + "','" + Message + "',1,5,'" + codint + "','" + Me.NumeroDevisInterne + "','" + Str(NbHeuresMO) + "','" + MontantDevis + "')"
CurrentDb.Execute Req
        
        
Set rs2 = CurrentDb.OpenRecordset("select max(numintint) from intervention ", dbOpenSnapshot)
If Not rs2.EOF Then
    newid = rs2(0)
End If
rs2.Close
Set rs2 = Nothing



Me.StatutDevis = 6 'à mettre à accepté par le client

'26/07/22Ajout OM
Me.Requery
Controle_Devis NumeroSite, NumeroClient

DoCmd.OpenForm "Intervention", acNormal, , "numintint=" & newid, acFormEdit, acWindowNormal


End Sub

Private Sub Commande68_Click()
AfficheDossierWindows (Me.NomFichierDevis)
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
    'Attention Si modif a faire sur Devis SAV et Travaux!!!!!!!!!
    'Modif OM 09/04/21
    Dim lSQl As String
    Dim NomDevis As String
    Dim Tronquage As Integer
    strBaseFileName = Me!NomFichierDevis
    If Me!NomFichierDevis <> "" Then
        strFileName = Right$(strBaseFileName, Len(strBaseFileName) - InStrRev(strBaseFileName, "\"))
        '24/01/25 On differencie les anciens fichiers des nouveaux OM
        If (Left(strFileName, 8) = "Devis n°") Then
            'Anciens Fichiers
            Tronquage = 9
        Else
            Tronquage = 6
        End If
        NomDevis = Right(strFileName, Len(strFileName) - Tronquage)
        'On demarre a 5 pour eviter le premier -
        PosFin = InStr(5, NomDevis, "-", vbTextCompare)
        If PosFin <> 0 Then
            NomDevis = Left(NomDevis, PosFin - 1)
        Else
            NomDevis = Left(NomDevis, 14)
        End If
        Me!NomFichierDevis = strFileName & strBaseFileName
        Me!NumeroDevis = NomDevis
    
        If Not IsNull(Me.NumeroInterventionInterne) Then
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
    If IsNull(Me.DateEnvoiDevis) Then
        Me.DateEnvoiDevis = Date
    End If
    

End Sub

Private Sub Controle_Devis(NumeroSite As String, NumeroClient As String)
'01/07/20 Modif OM Verification Changement Status ->Remplissage (ou pas) de la colonne Mess_Devis
'07/07/20 Ajout Gestion caractere '
'26/07/22 NumeroSite en param
'26/04/24 Ajout aussi en critere du numero client car il existe->Pourquoi ? des devis avec le numero client et numerosite qui ne correspondent pas !!
'ATTENTION MEME PROCEDURE DANS DEVIS SAV
'Maj Data
Me.Requery

Dim Message, Requete_Mess_Filtre As String

Dim Nb_Devis, Position As Integer
Requete = "Select NomFichierDevis from Devis where numerosite =" & NumeroSite & " and StatutDevis=4 and NumeroClient = " & NumeroClient
Set Data_Ref = CurrentDb().OpenRecordset(Requete, dbOpenSnapshot)
Message = ""
Nb_Devis = 0
While Not Data_Ref.EOF
    Nb_Devis = Nb_Devis + 1
    'Recherche caractere #
    Position = InStr(1, Trim(Data_Ref(0)), "#", vbTextCompare)
    If Position = -1 Then
        Message = Message + Trim(Data_Ref(0)) + ";"
    Else
        Message = Message + Trim(Left(Data_Ref(0), Position - 1)) + "<br/>"
    End If
    
    Data_Ref.MoveNext
Wend
Data_Ref.Close

Requete = "Select NomFichierDevis from DevisTravaux where numerosite =" & NumeroSite & " and StatutDevis=4 and NumeroClient = " & NumeroClient
Set Data_Ref = CurrentDb().OpenRecordset(Requete, dbOpenSnapshot)
Nb_Devis = 0
While Not Data_Ref.EOF
    Nb_Devis = Nb_Devis + 1
    'Recherche caractere #
    Position = InStr(1, Trim(Data_Ref(0)), "#", vbTextCompare)
    If Position = -1 Then
        Message = Message + Trim(Data_Ref(0)) + ";"
    Else
        Message = Message + Trim(Left(Data_Ref(0), Position - 1)) + "<br/>"
    End If
    
    Data_Ref.MoveNext
Wend
Data_Ref.Close
Set Data_Ref = Nothing

    Message = Replace(Message, "'", " ")
    Requete = "Update Site set Mess_Devis='" & Message & "' where cptsit =" & NumeroSite
    CurrentDb.Execute Requete, dbSeeChanges

End Sub

Private Sub StatutDevis_AfterUpdate()
If (IsNull(Me.NumeroSite) = False And IsNull(Me.NumeroClient) = False) Then
    Controle_Devis Me.NumeroSite, Me.NumeroClient
End If
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
