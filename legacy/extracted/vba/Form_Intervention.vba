Attribute VB_Name = "Form_Intervention"
Attribute VB_Base = "0{1D1A68BF-378B-40E1-AA16-7E6E09F37A44}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
'22/04/26 Passage en dbOpenSnapshotpour eviter des locks +Traitement de l'affichage des listes avec Where 1=1 FaitOM
Option Compare Database
'***App Window Constants***
Const WIN_NORMAL = 1         'Open Normal
Const WIN_MAX = 3            'Open Maximized
Const WIN_MIN = 2            'Open Minimized

'***Error Codes***
Private Const ERROR_SUCCESS = 32&
Private Const ERROR_NO_ASSOC = 31&
Private Const ERROR_OUT_OF_MEM = 0&
Private Const ERROR_FILE_NOT_FOUND = 2&
Private Const ERROR_PATH_NOT_FOUND = 3&
Private Const ERROR_BAD_FORMAT = 11&

#If Win64 Then
Private Declare PtrSafe Function apiShellExecute Lib "shell32.dll" _
    Alias "ShellExecuteA" _
    (ByVal hwnd As Long, _
    ByVal lpOperation As String, _
    ByVal lpFile As String, _
    ByVal lpParameters As String, _
    ByVal lpDirectory As String, _
    ByVal nShowCmd As Long) _
    As Long
    
#Else
Private Declare Function apiShellExecute Lib "shell32.dll" _
    Alias "ShellExecuteA" _
    (ByVal hwnd As Long, _
    ByVal lpOperation As String, _
    ByVal lpFile As String, _
    ByVal lpParameters As String, _
    ByVal lpDirectory As String, _
    ByVal nShowCmd As Long) _
    As Long
#End If

Dim gCancel As Boolean

Public Sub SendMail2(ByVal strEmail As String, _
  ByVal strObj As String, _
  ByVal strMsg As String, _
  ByVal blnEdit As Boolean)
On Error Resume Next
DoCmd.SendObject acSendNoObject, , , strEmail, , , strObj, strMsg, blnEdit
End Sub

Private Sub BtcMailClient_Click()

Dim strDest As String       ' L'adresse e-mail du destinataire
Dim strMessage As String    ' Le corps du message
Dim RsClient As Recordset
Dim RsUtil As Recordset
Dim RsSite As Recordset
Dim Vsql As String

Vsql = "SELECT Client.numcli, Client.melcli, Client.concli  FROM Client  WHERE (((Client.numcli)=" & Str(LstClient) & "));"
Set RsClient = CurrentDb.OpenRecordset(Vsql, dbOpenSnapshot)
If RsClient.EOF Then
    RsClient.Close
    Set RsClient = Nothing
    Exit Sub
End If
If Not IsNull(RsClient("melcli")) Then strDest = RsClient("melcli")
 
Vsql = "SELECT Utilisateur.numuti, [preuti] & ' ' & [nomuti] AS Expr1, Utilisateur.typuti From Utilisateur "
Vsql = Vsql & " WHERE (((Utilisateur.numuti) = " & traitepar & ") And ((Utilisateur.typuti) = 1))"
Set RsUtil = CurrentDb.OpenRecordset(Vsql, dbOpenSnapshot)

Vsql = "SELECT Site.cptsit, Site.nomsit, Site.adrsit, Site.codpossit, site.vilsit FROM Site WHERE (((Site.cptsit)= " & Str(cptsit) & "));"
Set RsSite = CurrentDb.OpenRecordset(Vsql, dbOpenSnapshot)
 
' Création du corps du message
strMessage = RsClient("concli")
strMessage = strMessage & vbCrLf & " "
strMessage = strMessage & vbCrLf & "Nous sommes intervenu à " & RsSite("nomsit") & " " & RsSite("adrsit") & " " & RsSite("codpossit") & " " & RsSite("vilsit")
strMessage = strMessage & vbCrLf & "Le " & datint
strMessage = strMessage & vbCrLf & "Pour " & natureintervention.Column(1)
strMessage = strMessage & vbCrLf & " "
strMessage = strMessage & vbCrLf & " "

strMessage = strMessage & vbCrLf & "Cordialement "

If Not RsUtil.EOF Then strMessage = strMessage & vbCrLf & vbCrLf & RsUtil("expr1")

strMessage = strMessage & vbCrLf & "http://www.fmc-climatisation.fr"
 
' On demande l'adresse e-mail du destinataire
'strDest = InputBox("Tapez une adresse e-mail existante : ", _
'  "Fin d'intervention", _
'  "[email-perso-masqué]")

'If strDest = "" Then Exit Sub
 
RsClient.Close
Set RsClient = Nothing
RsUtil.Close
Set RsUtil = Nothing
RsSite.Close
Set RsSite = Nothing
 
' Envoi du message
SendMail2 strDest, _
  "Fin d'intervention", _
  strMessage, _
  True

End Sub

Private Sub CalculHeures_Click()
Calcul_Heures
End Sub

Public Sub Calcul_Heures()
Dim HeuresDepart As Date
Dim HeuresFin As Date
Dim Nb_Min As Double

Nb_Min = 0
If IsNull(Me.numint) = False Then
        Requete = "SELECT HeureDebut,HeureFin  FROM dbo_HeuresTech WHERE numinterv = " & Me.numint & ""
        Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
        Do Until lrs.EOF
            HeuresDepart = lrs!HeureDebut
            HeuresFin = lrs!HeureFin
            '15/02/23 OM
            'Gestion cas Minuit On passe à 23h59 sinon ca compte en negatif depuis 00h00 le matin
            If Hour(HeuresFin) = 0 And Minute(HeuresFin) = 0 Then
                HeuresFin = "23:59:00"
            End If
            
            Nb_Min = Nb_Min + DateDiff("n", HeuresDepart, HeuresFin, vbMonday, vbFirstJan1)
            If HeuresFin = "23:59:00" Then
                Nb_Min = Nb_Min + 1
            End If
            lrs.MoveNext
        Loop
        lrs.Close
        Set lrs = Nothing
        Nb_Heures = Nb_Min \ 60
        Nb_Minutes = Nb_Min Mod 60
        LabelNbHeures.Caption = Str(Nb_Heures) + "H " + Str(Nb_Minutes) + "Mn"
End If
End Sub

Private Sub CheckAutre_Click()
If Me.CheckAutre.Value = True And IsNull(Me.cptsit) = False Then
    Me.Intervenant_Sous_formulaire_Clim.Visible = True
    Me.CheckChauff.Value = False
    Me.CheckClim.Value = False
    Filtre (3)
Else
    Me.Intervenant_Sous_formulaire_Clim.Visible = False
End If
End Sub

Private Sub CheckChauff_Click()
If Me.CheckChauff.Value = True And IsNull(Me.cptsit) = False Then
    Me.Intervenant_Sous_formulaire_Clim.Visible = True
    Me.CheckClim.Value = False
    Me.CheckAutre.Value = False
    Filtre (2)
Else
    Me.Intervenant_Sous_formulaire_Clim.Visible = False
End If
End Sub

Private Sub CheckClim_Click()
If Me.CheckClim.Value = True And IsNull(Me.cptsit) = False Then
    Me.Intervenant_Sous_formulaire_Clim.Visible = True
    Me.CheckChauff.Value = False
    Me.CheckAutre.Value = False
    Filtre (1)
Else
    Me.Intervenant_Sous_formulaire_Clim.Visible = False
End If
End Sub

Private Sub Filtre(TypeFiltre As Integer)
Dim CP As String
Dim Filtre_Ville As String
Dim Filtre As String
Dim Filtre_Activite As String
Dim ZoneGeo As String

If (IsNull(Me.cptsit)) Then
    Exit Sub
End If

lSQl = "SELECT numzonsit FROM Site WHERE (cptsit = " & Me.cptsit & ")"
Set rsNbreEnt = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
If Not rsNbreEnt.EOF Then
    ZoneGeo = rsNbreEnt(0)
End If
rsNbreEnt.Close
Set rsNbreEnt = Nothing

If Len(Me.adrsit) > 2 Then
    Filtre_Ville = "VillesInterventions_Interv like '%" + Left(adrsit, 2) + "%' OR "
Else
    Filtre_Ville = ""
End If


If (TypeFiltre = 1 Or TypeFiltre = 2) Then
    Filtre_Activite = " ( Activite_1=" + Str(TypeFiltre) + " or Activite_2=" + Str(TypeFiltre) + " or Activite_3=" + Str(TypeFiltre) + " or Activite_4=" + Str(TypeFiltre) + " or Activite_5=" + Str(TypeFiltre) + " or Activite_6=" + Str(TypeFiltre) + ")"
Else
    Filtre_Activite = " ( (Activite_1<>1 and Activite_1<>2) OR (Activite_2<>1 and Activite_2<>2) OR (Activite_3<>1 and Activite_3<>2) OR (Activite_4<>1 and Activite_4<>2) OR (Activite_5<>1 and Activite_5<>2) OR (Activite_6<>1 and Activite_6<>2) )"
End If

Filtre = Filtre_Activite + " and (" + Filtre_Ville + " numzonint=" + ZoneGeo + " Or numzonint_2_interv=" + ZoneGeo + " Or  numzonint_3_interv=" + ZoneGeo + " Or  numzonint_4_interv=" + ZoneGeo + ")"
Me.Intervenant_Sous_formulaire_Clim.Form.Filter = Filtre
Me.Intervenant_Sous_formulaire_Clim.Form.FilterOn = True
Me.Intervenant_Sous_formulaire_Clim.Requery
End Sub



Private Sub chkDevisAFaire_AfterUpdate()
    '21/04/26Ajoutonglet 4 Devis Travaux
    If Me.chkDevisAFaire = True Or Me.devisfait = True Then
        Me.Onglets.Pages(2).Visible = True
        Me.Onglets.Pages(4).Visible = True
    Else
        Me.Onglets.Pages(2).Visible = False
        Me.Onglets.Pages(4).Visible = False
    End If
    Call MajIcone
End Sub

Private Sub Chkmajreg_Click()
    If Me.datint & "" = "" Then
        MsgBox "Une date d'intervention doit être saisie", vbExclamation, "Attention"
        Chkmajreg.Value = False
        Me.datint.SetFocus
    End If
End Sub



Private Sub chkprediagres_AfterUpdate()
'30/04/21 OM
If chkprediagres.Value = True Then
    Me.staint = 10
    Me.intfac.Value = True
    Me.datint = Format(DateTime.Now, "dd/mm/yyyy")
    '20/10/25 OM
    Me.LabelMnTel.Visible = True
    Me.NbMinTel.Visible = True
Else
    Me.staint = 1
    Me.intfac.Value = False
    Me.datint = ""
    Me.NbMinTel.Visible = False
    Me.LabelMnTel.Visible = False
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
            Set rsNbreEnt = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
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
                Set RsCodInt = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
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
                    
                    Set rs = CurrentDb().OpenRecordset(lSQl, dbOpenSnapshot)
                    If Not rs.EOF Then
                        Dim lDerniereDate
                        lDerniereDate = rs(0)
                    End If
                    rs.Close
                    Set rs = Nothing
                    
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
                    rsInsert.Close
                    Set rsInsert = Nothing
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

Private Sub CmdEnvoyerMail_Click()
    Dim Destinataire As String
    Dim objet As String
    Dim Corps As String
    Dim RsContact As Recordset
    
    lSQl = "select Contact.*,Intervention.numintint from Contact inner join Intervention on Contact.codcon = Intervention.codcon where adrmelcon is not null and numintint=" & Me.numintint
    Set RsContact = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
    If Not RsContact.EOF Then
        Destinataire = RsContact("adrmelcon")
        Corps = "A l'attention de " & RsContact("precon") & " " & RsContact("nomcon")
    End If
    RsContact.Close
    Set RsContact = Nothing
    objet = "Demande d'intervention pour le site : " & Me.nomsit & " "
    sendEmail Destinataire, objet, Corps
End Sub

Public Sub sendEmail(Destinataire As String, objet As String, Corps As String)
    Dim objOutlook As Object    'Use for late binding
    Dim objNameSpace As Object  'Use for late binding
    Dim MailOutLook As Object   'Use for late binding
    Dim strPath As String
    Dim strFileName As String
    
    '*************************************************
    On Error Resume Next
    Set objOutlook = GetObject(, "Outlook.Application")
    On Error GoTo 0
    
    If objOutlook Is Nothing Then
        Set objOutlook = CreateObject("Outlook.Application")
    End If
    '*****************************************************
    
    Set MailOutLook = objOutlook.CreateItem(0)  'Late binding method
    'Dim MyOutlook As New Outlook.Application
    'Dim MyMail As Outlook.MailItem
    'Set MyMail = MyOutlook.CreateItem(olMailItem)
    'If Me.cheficdemint <> "" Then
    '    MyMail.Attachments.Add Left(Me.cheficdemint.Value, InStr(Me.cheficdemint.Value, "#") - 1), olByValue, 1, "Bon d'intervention " & Me.numintint & ".pdf"
    'End If
        
    Corps = Corps & PreparerSignature
    With MyMail
      .BodyFormat = 3      'Late binding in lieu of olFormatRichText
      .To = Destinataire
      '.cc = ""
      '.bcc = ""
      .Subject = objet
      .HTMLBody = Corps
      
          
      
      '.Send
      .Display  'Use for testing in lieu of .Send
    End With
 End Sub


Private Sub cmdEnvoyerMailPartenaire_Click()
    Dim Destinataire As String
    Dim objet As String
    Dim Corps As String
    Dim RsIntervenant As Recordset
    
    lSQl = "select Intervenant.* from Intervenant inner join Intervention on Intervenant.codint = Intervention.codint where adrmelint is not null and numintint=" & Me.numintint
    Set RsIntervenant = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
    If Not RsIntervenant.EOF Then
        Destinataire = RsIntervenant("adrmelint")
    End If
    RsIntervenant.Close
    Set RsIntervenant = Nothing
    objet = "Demande d'intervention pour le client : " & Me.LstClient.Column(1) & " pour le site : " & Me.nomsit & " "
    Corps = "Madame, Monsieur, ..."
    sendEmail Destinataire, objet, Corps
End Sub
Private Function PreparerSignature() As String
    
    Dim sign As String
    sign = "<div><span style='font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'><u></u>&nbsp;<u></u></span><br/>"
    sign = sign & "<span style='font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'><u></u>&nbsp;<u></u></span><br/>"
    sign = sign & "<span style='font-family:&quot;Times New Roman&quot;,&quot;serif&quot;;color:red'><u></u>&nbsp;<u></u></span><br/>"
    Select Case Environ$("Username")
        Case "fabien"
            sign = sign & "<b><span style='font-size:10.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'>Fabien Mathivet<u></u><u></u></span></b><br/>"
            sign = sign & "<b><span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'>Directeur<u></u><u></u></span></b><br/>"
        Case "maxime"
            sign = sign & "<b><span style='font-size:10.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'>Pierre ROUGE<u></u><u></u></span></b><br/>"
            sign = sign & "<b><span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'><u></u><u></u></span></b><br/>"
        Case "pierre"
            sign = sign & "<b><span style='font-size:10.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'>Maxime BORRIS<u></u><u></u></span></b><br/>"
            sign = sign & "<b><span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'><u></u><u></u></span></b><br/>"
        Case "delphine"
            sign = sign & "<b><span style='font-size:10.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'>Delphine<u></u><u></u></span></b><br/>"
            sign = sign & "<b><span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'><u></u><u></u></span></b><br/>"
        End Select
    sign = sign & "<b><span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;;color:#0070c0'>Sarl <span class='il'>FMC</span> Climatisation (étude et installation)<u></u><u></u></span></b><br/>"
    sign = sign & "<b><span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;;color:#0070c0'><span class='il'>FMC</span> Maintenance (étude et maintenance) <u></u><u></u></span></b><br/>"
    sign = sign & "<span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'>2 rue Galilée<u></u><u></u></span><br/>"
    sign = sign & "<span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'>ZA la Morandière<u></u><u></u></span><br/>"
    sign = sign & "<span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'>33185 Le Haillan<u></u><u></u></span><br/>"
    sign = sign & "<span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'><u></u>&nbsp;<u></u></span><br/>"
    sign = sign & "<span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'>Mail: <a href='mailto:f.mathivet@fmc-climatisation.fr' target='_blank'><br/>"
    sign = sign & "<span style='color:blue'>f.mathivet@<span class='il'>fmc</span>-climatisation.<wbr>fr</span></a><u></u><u></u></span><br/>"
    sign = sign & "<span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'>Standard: 05.33.89.12.40<u></u><u></u></span><br/>"
    sign = sign & "<span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'>Portable: 06.62.80.00.98<u></u><u></u></span><br/>"
    sign = sign & "<span style='font-size:8.0pt;font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'>Fax: 05.56.97.38.19<u></u><u></u></span><br/>"
    sign = sign & "<span style='font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'><u></u>&nbsp;<u></u></span><br/>"
    'sign = sign & "<span style='font-family:&quot;Times New Roman&quot;,&quot;serif&quot;'><img border='0' width='101' height='49' src='?ui=2&amp;ik=854270588e&amp;view=att&amp;th=1475ea0582aa9ca9&amp;attid=0.0.1&amp;disp=emb&amp;zw&amp;atsh=1'><u></u><u></u></span>"
    sign = sign & "</div> "
    PreparerSignature = sign
    
End Function
Private Function VerifDatHeuLim() As Boolean
'20/10/25 Ajout Controle des Heures De Telephones pour Resolu ParTel
If (Me.NbMinTel.Visible = True) Then
    If (IsNull(Me.NbMinTel.Value) Or Me.NbMinTel.Value <= 0) Then
        MsgBox "Merci de bien vouloir renseigner les minutes passées au téléphone", vbCritical, "Minutes Manquantes"
        VerifDatHeuLim = False
        Exit Function
    End If
End If

If Not IsNull(Me.TxtHeuLim) Then
    VerifDatHeuLim = True
Else
    If MsgBox("La date limite d'intervention n'est pas saisie, confirmez-vous votre sortie ?", vbOKCancel, "Date limite d'intervention manquante") = vbCancel Then
    VerifDatHeuLim = False
    'gCancel = False
    Else
    VerifDatHeuLim = True
    'gCancel = True
    End If
End If

End Function

Private Sub CmdFermer_Click()

Dim Departement As String
Dim TexteVilles As String
Dim Trouve As Boolean

'02/12/21 Ajout Departement Auto
'Recherche Data Intervenant
If IsNull(Me.codint) = False And IsNull(Me.adrsit) = False Then
    If (Len(Me.adrsit) >= 2) Then
        Requete = "SELECT VillesInterventions_Interv  FROM intervenant WHERE codint = '" & Me.codint & "'"
        Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
        If Not lrs.EOF Then
            If IsNull(lrs!VillesInterventions_Interv) = False Then
                Departement = Left(Me.adrsit, 2)
                TexteVilles = lrs!VillesInterventions_Interv
                TexteVilles = Trim(TexteVilles)
                TabVille = Split(TexteVilles, ",")
                For Each Ville In TabVille
                    If (Departement = Ville) Then
                        Trouve = True
                        Exit For
                    End If
                Next
            End If
        End If
        lrs.Close
        Set lrs = Nothing
    End If
End If

If Trouve = False Then
    Requete = "Update intervenant set VillesInterventions_Interv = '" + TexteVilles + "," + Departement + "' where codint = '" & Me.codint & "'"
    CurrentDb.Execute "Update intervenant set VillesInterventions_Interv = '" + TexteVilles + "," + Departement + "' where codint = '" & Me.codint & "'"
End If


   'On Error Resume Next
    'If CurrentProject.AllForms("ListeInterventionGenerale").IsLoaded Then
    '    Forms![ListeInterventionGenerale]![ListeInterventionGenerale sous-formulaire].Form.Requery
    'End If
    'If gCancel = False Then
    If VerifDatHeuLim Then
        DoCmd.Close ObjectType:=acForm, ObjectName:=Me.Name
    End If
   'End If
End Sub

Private Sub cmdFermer_DblClick(Cancel As Integer)
    If VerifDatHeuLim Then
    DoCmd.Close
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
        rs("staint") = Me!staint
        rs("refcliint") = Me!refcliint
        rs("refint") = Me!refint
        rs("nbrpagfax") = Me!nbrpagfax
        rs("pannoncli") = Me!pannoncli
        rs("codpan") = Me!codpan
        rs.Update
        rs.Close
        Set rs = Nothing
        Set rs = CurrentDb.OpenRecordset("select max(numintint) from intervention", dbOpenSnapshot)
        If Not rs.EOF Then
            DoCmd.Requery
            DoCmd.ApplyFilter , "numintint=" & rs(0)
        End If
        rs.Close
        Set rs = Nothing
    End If
exittraiterrnewinter:
    Exit Sub
traiterrnewinter:
    MsgBox err.Description
    Resume exittraiterrnewinter
End Sub


Private Sub Commande131_Click()
    If Not IsNull(ListeMateriel) Then
        Dim Vsql As String
        Dim rst As dao.Recordset
        Dim Rst2 As dao.Recordset

        Set rst = CurrentDb.OpenRecordset("panneMaterielSite", dbOpenDynaset, dbSeeChanges)
        Vsql = "SELECT PanneMaterielSite.numintint, PanneMaterielSite.numsitmarref FROM PanneMaterielSite"
        Vsql = Vsql + " WHERE (((PanneMaterielSite.numintint)=" + Str(numintint) + ") AND ((PanneMaterielSite.numsitmarref)=" + Str(ListeMateriel) + "));"
        Set Rst2 = CurrentDb.OpenRecordset(Vsql, dbOpenSnapshot)
        If Rst2.EOF = True Then
            rst.AddNew
            rst("numintint") = numintint
            rst("numsitmarref") = ListeMateriel
            rst.Update
            SfMaterielPanne.Requery
        End If
        Rst2.Close
        Set Rst2 = Nothing
        rst.Close
        Set rst = Nothing
    End If
End Sub

Function fPrintFile(stFile As String)

    ' This function uses ShellExecute to print, rather than
    ' open, the file.

    Dim lRet As Long, varTaskID As Variant
    Dim stRet As String

    lRet = apiShellExecute(hWndAccessApp, "print", _
            stFile, vbNullString, vbNullString, 0&)
            
    If lRet > ERROR_SUCCESS Then
        stRet = vbNullString
        lRet = -1
    Else
        Select Case lRet
            Case ERROR_NO_ASSOC:
                stRet = "Erreur: Pas d'application Windows associée pour imprimer.  Impossible d'imprimer !"
            Case ERROR_OUT_OF_MEM:
                stRet = "Erreur: Pas assez de ressource. Impossible d'imprimer !"
            Case ERROR_FILE_NOT_FOUND:
                stRet = "Erreur: Fichier non trouvé.  Impossible d'imprimer !"
            Case ERROR_PATH_NOT_FOUND:
                stRet = "Erreur: Chemin non trouvé. Impossible d'imprimer !"
            Case ERROR_BAD_FORMAT:
                stRet = "Erreur:  Fichier au mauvais format. Impossible d'imprimer !"
            Case Else:
        End Select
    End If
    fPrintFile = lRet & _
                IIf(stRet = "", vbNullString, ", " & stRet)
End Function

Private Sub Cocher202_Click()
    '28/03/23 Supprime car le coche sert a autre chose OM
    
    'If Me.cheficdemint <> "" And Cocher202.Value = True Then
    '    Dim sFile As String
    '    sFile = Left(Me.cheficdemint, InStr(Me.cheficdemint, "#") - 1)
    '    fPrintFile (sFile)
    'End If
    
    

End Sub

Private Sub Cocher231_AfterUpdate()
    If Me.Cocher231.Value = True Then
        Me.comdevis.Visible = True
        Me.devisafaire.Value = False
    Else
        Me.comdevis.Visible = False
    End If
End Sub

Private Sub Cocher362_Click()

Me.dateenvoimail = DateTime.Now
End Sub

Private Sub Cocher364_Click()
Me.dateenvoimail = DateTime.Now
End Sub

Private Sub Cocher367_Click()
Me.dateenvoimail = DateTime.Now
End Sub

Private Sub Cocher369_Click()
Me.dateenvoimail = DateTime.Now
End Sub

Private Sub CocherNacelle_AfterUpdate()
If (Me.CocherNacelle = True) Then
    Me.Nacelle.Visible = True
Else
    Me.Nacelle.Visible = False
End If

End Sub

Private Sub codint_AfterUpdate()
    Me.InterventionTechnicien.Requery
    If Me.codint = "FMC" Then
        Me.numerodemandesoustraitant.Visible = False
        Me.envoisoustraitantpar.Visible = False
    Else
        Me.numerodemandesoustraitant.Visible = True
        Me.envoisoustraitantpar.Visible = True
    End If
    
End Sub
Public Sub AjoutHeures()
On Error GoTo err
'31/03/22 Ajout Heures Auto dans Heures Technicien
Dim Requete As String
Dim NumeroTech As Integer
Dim TexteTech As String
Requete = "SELECT numuti FROM InterventionTechnicien WHERE numintint = " & Me.numintint
Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
If (lrs.RecordCount = 0) Then
    NumeroTech = -1
Else
    TexteTech = ""
    Do Until lrs.EOF
        If IsNull(lrs!numuti) = False Then
            If TexteTech = "" Then
                TexteTech = lrs!numuti
            Else
                TexteTech = TexteTech + ";" + Str(lrs!numuti)
            End If
        End If
        lrs.MoveNext
    Loop

    lrs.MoveFirst
    Do Until lrs.EOF
        If IsNull(lrs!numuti) = False Then
            NumeroTech = lrs!numuti
            IntegrerHeureTech NumeroTech, TexteTech
        End If
        lrs.MoveNext
    Loop
End If
lrs.Close
Set lrs = Nothing
Exit Sub

err:
    MsgBox "Erreur sur Ajout Heures dans Planning ,merci de contacter la banane!!", vbCritical, "Erreur"

End Sub
Public Sub IntegrerHeureTech(NumeroTech As Integer, TexteTech As String)
'31/03/22 Ajout Heures Auto dans Heures Technicien
Dim Requete As String
Requete = "select * from dbo_HeuresTechAuto WHERE numinterv = " & Me.numintint & " and NumeroTech=" & NumeroTech
Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
If (lrs.RecordCount = 0) Then
    InsertionHeures NumeroTech, TexteTech
Else
    ModifHeures NumeroTech, Str(lrs!Numero), TexteTech
End If
lrs.Close
Set lrs = Nothing
End Sub

Public Function EnleverCaracGenant(chaine As String) As String
    Dim ChaineRetour As String
    ChaineRetour = Replace(chaine, ",", " ")
    ChaineRetour = Replace(ChaineRetour, "'", " ")
    ChaineRetour = Replace(ChaineRetour, """", " ")
    EnleverCaracGenant = ChaineRetour
End Function


Public Sub InsertionHeures(NumeroTech As Integer, TexteTech As String)
'31/03/22 Ajout Heures Auto dans Heures Technicien
Dim MessagePlanning As String
Dim Requete As String
Dim NomSite As String
Dim commentaire As String
Dim Operateurs As String
Dim Numoper As String
Dim EnteteMultiOper As String
Dim TabNumOperateur As Variant


If IsNull(Me.datint) Or IsNull(Me.heuarrint) Or IsNull(Me.heudepint) Then
    Exit Sub
End If

Requete = "SELECT nomsit FROM site WHERE cptsit = " & Me.cptsit
Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
If IsNull(lrs!nomsit) = False Then
    NomSite = lrs!nomsit
End If
lrs.Close
Set lrs = Nothing

TabNumOperateur = Split(TexteTech, ";")

If (UBound(TabNumOperateur) > 0) Then
    EnteteMultiOper = "MULTIPLE TECHNICIENS" + "<br>"
    Operateurs = "<br>" + "Techniciens intervenus:" + "<br>"
    For i = 0 To UBound(TabNumOperateur)
        Numoper = TabNumOperateur(i)
        Operateurs = Operateurs + RechercheNomOp(Numoper) + "<br>"
    Next i
Else
    EnteteMultiOper = ""
    Operateurs = ""
End If

MessagePlanning = EnteteMultiOper + GetNomOp(Str(Me.typint)) + ":" + "<br>" + EnleverCaracGenant(NomSite) + "<br>"
If Me.refcliint <> "" Then
    MessagePlanning = MessagePlanning + "N° DI:" + EnleverCaracGenant(Me.refcliint) + "<br>"
End If
If Me.numdevacc <> "" Then
    MessagePlanning = MessagePlanning + "N° Devis:" + EnleverCaracGenant(Me.numdevacc) + "<br>"
End If
If Me.comint <> "" Then
    MessagePlanning = MessagePlanning + "Commentaire:" + EnleverCaracGenant(Me.comint) + "<br>"
End If
MessagePlanning = MessagePlanning + "Num Inter:" + "<br>" + Str(Me.numintint) + "<br>" + Operateurs

Requete = "Insert INTO dbo_HeuresTechAuto(NomInterv,Numinterv,NumeroSite,NumeroTech, TypeInterv, DateInterv,HeureDebut,HeureFin,InterdictionModif) VALUES ('"
Requete = Requete + MessagePlanning + "'," + Str(Me.numintint) + "," + Str(Me.cptsit) + "," + Str(NumeroTech) + "," + Str(Me.typint) + ",'" + Str(Me.datint) + "'," + "'" + Right(Me.heuarrint, 8) + "',"
Requete = Requete + "'" + Right(Me.heudepint, 8) + "',0)"
CurrentDb.Execute Requete

End Sub

 Public Function GetNomOp(NumOP As String) As String
        GetNomOp = "Inconnu"
        If (Trim(NumOP) = "1") Then
            GetNomOp = "Entretien"
        End If
        If (Trim(NumOP) = "2") Then
            GetNomOp = "Dépannage"
        End If
        If (Trim(NumOP) = "3") Then
            GetNomOp = "Devis accepté"
        End If
        If (Trim(NumOP) = "4") Then
            GetNomOp = "Autre"
        End If
        If (Trim(NumOP) = "5") Then
            GetNomOp = "En travaux"
        End If
        If (Trim(NumOP) = "7") Then
            GetNomOp = "Désenfumage"
        End If
        If (Trim(NumOP) = "9") Then
            GetNomOp = "Audit"
        End If
        
 End Function
Function RechercheNomOp(Numoper As String) As String
Requete = "SELECT nomuti,preuti FROM utilisateur WHERE numuti = " + Numoper
Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
If IsNull(lrs!nomuti) = False Then
    Reponse = lrs!nomuti + " " + lrs!preuti
    RechercheNomOp = Reponse
Else
    RechercheNomOp = ""
End If
lrs.Close
Set lrs = Nothing
End Function

Public Sub ModifHeures(NumeroTech As Integer, NumeroBlocHeure As String, TexteTech As String)
'31/03/22 Ajout Heures Auto dans Heures Technicien
Dim MessagePlanning As String
Dim Requete As String
Dim NomSite As String
Dim Operateurs As String
Dim Numoper As String
Dim EnteteMultiOper As String
Dim TabNumOperateur As Variant

Requete = "SELECT nomsit FROM site WHERE cptsit = " & Me.cptsit
Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
If IsNull(lrs!nomsit) = False Then
    NomSite = lrs!nomsit
End If
lrs.Close
Set lrs = Nothing
TabNumOperateur = Split(TexteTech, ";")

If (UBound(TabNumOperateur) > 0) Then
    EnteteMultiOper = "MULTIPLE TECHNICIENS" + "<br>"
    Operateurs = "<br>" + "Techniciens intervenus:" + "<br>"
    For i = 0 To UBound(TabNumOperateur)
        Numoper = TabNumOperateur(i)
        Operateurs = Operateurs + RechercheNomOp(Numoper) + "<br>"
    Next i
Else
    EnteteMultiOper = ""
    Operateurs = ""
End If

MessagePlanning = EnteteMultiOper + GetNomOp(Str(Me.typint)) + ":" + "<br>" + EnleverCaracGenant(NomSite) + "<br>"
If Me.refcliint <> "" Then
    MessagePlanning = MessagePlanning + "N° DI:" + EnleverCaracGenant(Me.refcliint) + "<br>"
End If
If Me.numdevacc <> "" Then
    MessagePlanning = MessagePlanning + "N° Devis:" + EnleverCaracGenant(Me.numdevacc) + "<br>"
End If
If Me.comint <> "" Then
    MessagePlanning = MessagePlanning + "Commentaire:" + EnleverCaracGenant(Me.comint) + "<br>"
End If
MessagePlanning = MessagePlanning + "Num Inter:" + "<br>" + Str(Me.numintint) + "<br>" + Operateurs

Requete = "Update dbo_HeuresTechAuto set NumeroSite=" + Str(Me.cptsit) + ","
Requete = Requete + "NomInterv='" + MessagePlanning + "',"
Requete = Requete + "NumeroTech=" + Str(NumeroTech) + ","
Requete = Requete + "TypeInterv=" + Str(Me.typint) + ","
Requete = Requete + "DateInterv='" + Str(Me.datint) + "',"
Requete = Requete + "HeureDebut='" + Right(Me.heuarrint, 8) + "',"
Requete = Requete + "HeureFin='" + Right(Me.heudepint, 8) + "'"
Requete = Requete + " Where Numero=" + NumeroBlocHeure
CurrentDb.Execute Requete, dbSeeChanges

End Sub



Private Sub Commande339_Click()

'31/03/22 Ajout Heures Auto dans Heures Technicien
'TODO reste a definir si on le fait pour tous les types d'inter et si la modification est possible apres
If Me.staint = 7 Then
    AjoutHeures
End If

'23/07/20 Modif OM Cloture Auto

'Pour Choix du dossier Il faut ajouter la reference Microsoft office 15
Dim Nom_PDF As String, Dossier_PDF As String, Chemin_PDF As String
Dim Repertoir As FileDialog
Dim Requete As String
Dim Chemin_Ini As String
Dim Temp As String
 
Set Repertoire = Application.FileDialog(msoFileDialogFolderPicker)
'Recherche Chemin par defaut
Chemin_Ini = ""
Requete = "SELECT *  FROM Site WHERE cptsit = " & Me.cptsit
Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
If Not lrs.EOF Then
    If IsNull(lrs!cptsit) = False Then
        Chemin_Ini = lrs!chemindoc
        Carac_Fin_Chemin = InStr(1, Chemin_Ini, "#", vbTextCompare)
        If Carac_Fin_Chemin <> 0 Then
            Chemin_Ini = Left(Chemin_Ini, Carac_Fin_Chemin - 1)
            If Chemin_Ini = "" Then
                'Push/Pull ne donne que une fois le chemin
                Chemin_Ini = Left(lrs!chemindoc, Len(lrs!chemindoc) - 1)
                Chemin_Ini = Right(Chemin_Ini, Len(Chemin_Ini) - 1)
            End If
        Else
            
            Chemin_Ini = ""
        End If
    Else
        Chemin_Ini = ""
    End If
End If
lrs.Close
Set lrs = Nothing

If Chemin_Ini <> "" Then
    Repertoire.InitialFileName = Chemin_Ini
End If
Repertoire.AllowMultiSelect = False
Repertoire.title = "Merci de Selectionner le repertoire pour le PDF puis cliquez sur OK"

If Repertoire.Show = 0 Then
     Exit Sub
Else
    Dossier_PDF = Repertoire.SelectedItems(1)
End If


Dim stDocName As String

    Nom_PDF = Me.datint
    Nom_PDF = Replace(Nom_PDF, "/", ".")
  'Si Devis accepté Date +(Selon Colonne N Sav Client)
  If Me.typint = 3 Then
    If Me.numdevacc <> "" Then
      Temp = Replace(Me.numdevacc, "/", ".")
      Temp = Replace(Me.numdevacc, "\", ".")
      Temp = Replace(Me.numdevacc, "'", " ")
    End If
  Else
    'Sinon Date +(Selon Colonne N DI Client)
    If Me.refcliint <> "" Then
      Temp = Replace(Me.refcliint, "/", ".")
      Temp = Replace(Me.refcliint, "\", ".")
      Temp = Replace(Me.refcliint, "'", " ")
    End If
  End If
  If (Temp <> "") Then
    Nom_PDF = Nom_PDF + " (Selon " + Temp + ")"
  End If
  Nom_PDF = InputBox("Merci de verifier le nom du futur fichier PDF:", "Nom du fichier PDF", Nom_PDF)
  If Nom_PDF = "" Then
    Exit Sub
  End If
  
  Chemin_PDF = Dossier_PDF & "\" & Nom_PDF & ".pdf"
  
  On Error GoTo invalidFolderPath

  stDocName = "FicheIntervention"
    
  'DoCmd.OpenReport stDocName, acViewPreview, , "numintint=" & Me.numintint, acHidden, Me.heuvis
  If Me.heuvis = True Then
        args = "O"
    Else
        args = "N"
    End If
  DoCmd.OpenReport stDocName, acViewPreview, , "numintint=" & Me.numintint, acHidden, args
  DoCmd.OutputTo ObjectType:=acOutputReport, ObjectName:=stDocName, outputformat:=acFormatPDF, outputFile:=Chemin_PDF
  DoCmd.Close acReport, stDocName, acSaveNo
  Me.Refresh
  Chemin_PDF = Replace(Chemin_PDF, "'", "''")
  'TODO Verifier la correspondance pour FMC
  Chemin_PDF = Replace(Chemin_PDF, "Z:", "\\vmware-host\Shared Folders")
  Requete = "Update Intervention set cheficdemint='" & Chemin_PDF & "#" & Chemin_PDF & "#" & "' where numintint =" & Me.numintint
  CurrentDb.Execute Requete, dbSeeChanges
  MsgBox prompt:="PDF Exporté Vers: " & vbNewLine & Chemin_PDF, buttons:=vbInformation, title:="Fiche Intervention Exportée"
  Me.Refresh
  Exit Sub
 
invalidFolderPath:
  MsgBox prompt:="Erreur: Export Vers PDF Annulé.", buttons:=vbCritical


End Sub


Private Sub Commande342_Click()
'02/10/2020 Modif OM
'Necessite Microsoft Object Library
 
If Me.typint <> 2 And Me.typint <> 1 And Me.typint <> 3 Then Exit Sub
 
Dim objXL As Excel.Application
Dim objWkbk As Workbook
Dim objSht As Worksheet
Dim i As Integer
Dim Adresse As String
Dim Numero_Client As String
Dim Numero_Zone As String
Dim Date_Op As String
Dim Date_Lim As String
Dim Departement As String
Dim TexteVilles As String
Dim Trouve As Boolean
Dim PrixMoSite As Integer
Dim PrixDeplSite As Integer
Dim PrixMoClient As Integer
Dim PrixDeplClient As Integer
Dim DateMSE As String

'02/12/21 Ajout Departement Auto
'Recherche Data Intervenant
If IsNull(Me.codint) = False And IsNull(Me.adrsit) = False Then
    If (Len(Me.adrsit) >= 2) Then
        Requete = "SELECT VillesInterventions_Interv  FROM intervenant WHERE codint = '" & Me.codint & "'"
        Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
        If Not lrs.EOF Then
            If IsNull(lrs!VillesInterventions_Interv) = False Then
                Departement = Left(Me.adrsit, 2)
                TexteVilles = lrs!VillesInterventions_Interv
                TexteVilles = Trim(TexteVilles)
                TabVille = Split(TexteVilles, ",")
                For Each Ville In TabVille
                    If (Departement = Ville) Then
                        Trouve = True
                        Exit For
                    End If
                Next
            End If
        End If
        lrs.Close
        Set lrs = Nothing
    End If
End If

If Trouve = False Then
    Requete = "Update intervenant set VillesInterventions_Interv = '" + TexteVilles + "," + Departement + "' where codint = '" & Me.codint & "'"
    CurrentDb.Execute "Update intervenant set VillesInterventions_Interv = '" + TexteVilles + "," + Departement + "' where codint = '" & Me.codint & "'"
End If

'02/10/20 Modif OM
'Recherche Site
Requete = "SELECT *  FROM Site WHERE cptsit = " & Me.cptsit
Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
If Not lrs.EOF Then
    If IsNull(lrs!cptsit) = False Then
    
        Dim ÉtiquetteGarantirCompr As Boolean
        Dim ÉtiquetteGarantiePieces As Boolean
        Dim ÉtiquetteGarantieMO As Boolean
        
        If IsNull(lrs!PrixMO) = False Then
            PrixMoSite = lrs!PrixMO
        Else
            PrixMoSite = 0
        End If
        
        If IsNull(lrs!PrixDepl) = False Then
            PrixDeplSite = lrs!PrixDepl
        Else
            PrixDeplSite = 0
        End If
        
        If IsNull(lrs!datemiseenservicesite) = False Then
            DateMSE = lrs!datemiseenservicesite
            Intervalle_Jour = DateDiff("d", DateMSE, DateTime.Now)
            If IsNull(lrs!garantiecompresseur) = False Then
                If (Intervalle_Jour < lrs!garantiecompresseur * 365) Then
                    ÉtiquetteGarantirCompr = True
                Else
                    ÉtiquetteGarantirCompr = False
                End If
            Else
                ÉtiquetteGarantirCompr = False
            End If
            
            If IsNull(lrs!garantiepieces) = False Then
                If (Intervalle_Jour < lrs!garantiepieces * 365) Then
                    ÉtiquetteGarantiePieces = True
                Else
                    ÉtiquetteGarantiePieces = False
                End If
            Else
                ÉtiquetteGarantiePieces = False
            End If
            
            If IsNull(lrs!garantiepiecesmainoeuvre) = False Then
                If (Intervalle_Jour < lrs!garantiepiecesmainoeuvre * 365) Then
                    ÉtiquetteGarantieMO = True
                Else
                    ÉtiquetteGarantieMO = False
                End If
            Else
                ÉtiquetteGarantieMO = False
            End If
        Else
            DateMSE = ""
            ÉtiquetteGarantieMO = False
            ÉtiquetteGarantiePieces = False
            ÉtiquetteGarantirCompr = False
        End If
    
    
    
    
        Adresse = ""
        If IsNull(lrs!adrsit) = False Then
            Adresse = lrs!adrsit
        End If
        If IsNull(lrs!codpossit) = False Then
            Adresse = Adresse + " " + lrs!codpossit
        End If
        If IsNull(lrs!vilsit) = False Then
            Adresse = Adresse + " " + lrs!vilsit
        End If
 
        If IsNull(lrs!numcli) = False Then
            Numero_Client = lrs!numcli
        Else
            Numero_Client = ""
        End If
        
        If IsNull(lrs!numzonsit) = False Then
            Numero_Zone = lrs!numzonsit
        Else
            Numero_Zone = ""
        End If
        
        If IsNull(lrs!numsit) = False Then
            Numero_Site = lrs!numsit
        Else
            Numero_Site = ""
        End If
    End If
End If
lrs.Close
Set lrs = Nothing

'Recherche Zone
Requete = "SELECT *  FROM ZoneGeographique WHERE numzon = " & Numero_Zone
Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
If Not lrs.EOF Then
    If IsNull(lrs!numzon) = False Then
        Numero_Zone = lrs!nomzon
    End If
End If
lrs.Close
Set lrs = Nothing

'Recherche CLient
Requete = "SELECT *  FROM Client WHERE numcli = " & Numero_Client
Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
If Not lrs.EOF Then
    If IsNull(lrs!numcli) = False Then
        Numero_Client = lrs!nomcli
    End If
    
    If IsNull(lrs!coutheuremainoeuvre) = False Then
        PrixMoClient = lrs!coutheuremainoeuvre
    Else
        PrixMoClient = 0
    End If
    
    If IsNull(lrs!coutdeplacement) = False Then
        PrixDeplClient = lrs!coutdeplacement
    Else
        PrixDeplClient = 0
    End If
    
End If
lrs.Close
Set lrs = Nothing

Dim PrixMO As Integer
Dim PrixDepl As Integer
If (PrixMoSite = 0) Then
    PrixMO = PrixMoClient
Else
    PrixMO = PrixMoSite
End If

If (PrixDeplSite = 0) Then
    PrixDepl = PrixDeplClient
Else
    PrixDepl = PrixDeplSite
End If
 
'Pour Test Fersoft
'strCheminFichier = "c:\Dossier_Bureau_VERT_et_ROUGE.xlsx"
strCheminFichier = "\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Dossier_Bureau_VERT_et_ROUGE.xlsx"
'ouvrir Excel
'Si Excel est déjà ouvert sur le PC, GetObject suffit.
On Local Error Resume Next
Set objXL = GetObject(, "Excel.Application")
'Par contre, si Excel n'est pas encore lancé sur le PC, alors il faut le faire par ce CreateObject
'Modif 29/06/23 On enleve le IF  car sur Windows 11 oblxl n'est pas à nothing
'If Nothing Is objXL Then
    Set objXL = CreateObject("Excel.Application")
'End If
On Error GoTo 0
 
'ouvrir le fichier
Set objWkbk = objXL.Workbooks.Open(strCheminFichier)
 
If Me.typint = 2 Then
    'Onglet Depannage
    Set objSht = objWkbk.Worksheets(1)
Else
    If Me.typint = 1 Then
        'Onglet Entretien/Maintenance
        Set objSht = objWkbk.Worksheets(3)
    Else
        If Me.typint = 3 Then
            'Onglet Devis SAV Accepté
            Set objSht = objWkbk.Worksheets(2)
        End If
    End If
End If
 
objXL.Visible = True
 
'Make this sheet the active one when we open the Spreadsheet
objSht.Activate
 
With objSht
    If Numero_Site <> "" Then
        Numero_Site = " (" + Trim(Str(Numero_Site)) + ")"
    End If
    If IsNull(Me.datheuapp) = True Then
        Date_Op = ""
    Else
       
        Date_Op = Str(Me.datheuapp)
        '02/10/20 inversion format date
        Date_Inv = Mid(Date_Op, 4, 2) + "/" + Left(Date_Op, 2) + "/" + Right(Date_Op, 4)
        Date_Op = Date_Inv
    End If
    If IsNull(Me.datheulim) = True Then
        Date_Lim = ""
    Else
        Date_Lim = Str(Me.datheulim)
        '02/10/20 inversion format date
        Date_Inv = Mid(Date_Lim, 4, 2) + "/" + Left(Date_Lim, 2) + "/" + Right(Date_Lim, 4)
        Date_Lim = Date_Inv
    End If
    
    If Me.typint = 2 Then
        'Onglet Depannage
        
        '23/11/23 Ajout des couts
        .cells(50, 11).Value = PrixMO
        .cells(51, 11).Value = PrixDepl
        
        .cells(1, 2).Value = Me.nomsit + Numero_Site
        
        .cells(1, 2).Value = Me.nomsit + Numero_Site
        .cells(5, 3).Value = Date_Op
        .cells(5, 9).Value = Date_Lim
        .cells(7, 2).Value = Numero_Client
        .cells(9, 3).Value = Adresse
        .cells(13, 4).Value = Me.refcliint
        .cells(13, 10).Value = Numero_Zone
        .cells(17, 1).Value = Me.comint
        .cells(35, 6).Value = Me.codint
        .cells(38, 6).Value = Me.numerodemandesoustraitant
        '11/11/21 Ajout
        If DateMSE <> "" Then
            .cells(28, 2).Value = "Date Mise en service :" + DateMSE
        End If
        If (ÉtiquetteGarantieMO = True) Then
            .cells(29, 4).Value = "OUI"
            .cells(29, 4).Font.Bold = True
            .cells(29, 4).Font.Color = RGB(255, 0, 0)
        Else
            .cells(29, 4).Value = "NON"
        End If
        
        If (ÉtiquetteGarantiePieces = True) Then
            .cells(30, 4).Value = "OUI"
            .cells(30, 4).Font.Bold = True
            .cells(30, 4).Font.Color = RGB(255, 0, 0)
        Else
            .cells(30, 4).Value = "NON"
        End If
        
        If (ÉtiquetteGarantirCompr = True) Then
            .cells(31, 4).Value = "OUI"
            .cells(31, 4).Font.Bold = True
            .cells(31, 4).Font.Color = RGB(255, 0, 0)
        Else
            .cells(31, 4).Value = "NON"
        End If
    End If
    If Me.typint = 1 Then
        .cells(1, 2).Value = Me.nomsit + Numero_Site
        .cells(6, 3).Value = Date_Op
        .cells(6, 9).Value = Date_Lim
        .cells(10, 2).Value = Numero_Client
        .cells(12, 3).Value = Adresse
        .cells(17, 4).Value = Me.refcliint
        .cells(17, 10).Value = Numero_Zone
        .cells(22, 1).Value = Me.comint
        .cells(35, 6).Value = Me.codint
        .cells(38, 6).Value = Me.numerodemandesoustraitant
    End If
    If Me.typint = 3 Then
        .cells(1, 3).Value = Me.nomsit + Numero_Site
        .cells(5, 4).Value = Date_Op
        .cells(5, 11).Value = Date_Lim
        .cells(9, 3).Value = Numero_Client
        .cells(11, 4).Value = Adresse
        .cells(15, 13).Value = Me.refcliint
        .cells(15, 5).Value = Me.numdevacc
        .cells(9, 11).Value = Numero_Zone
        .cells(19, 2).Value = Me.comint
        .cells(44, 10).Value = Me.codint
        If IsNull(Me.numerodemandesoustraitant) = False Then
            .cells(48, 10).Value = Me.numerodemandesoustraitant
        End If
    End If
End With
 
'Fermer le fichier et le sauver
'objWkbk.Close True
 
'libérer les pointeurs
'Set objWkbk = Nothing
'Set objXL = Nothing
 
End Sub

Private Sub Commande381_Click()
Dim objXL As Excel.Application
Dim objWkbk As Workbook
Dim objSht As Worksheet
Dim ListeAccept As Recordset
Dim ListeIntervention As Recordset
Dim ListeTech As Recordset
Dim db As Database
Dim NbEnreg As Integer
Dim Repertoire As FileDialog


Set Repertoire = Application.FileDialog(msoFileDialogFolderPicker)
Repertoire.AllowMultiSelect = False
Repertoire.title = "Merci de Selectionner le repertoire pour le fichier d'export des heures"

If Repertoire.Show = 0 Then
     Exit Sub
Else
    dossier_dest = Repertoire.SelectedItems(1)
End If




Dim Annee As Integer

If AnneeExport = "" Or IsNull(AnneeExport) Then
    MsgBox "L'année saisie n'est pas correcte!!", vbInformation
    Exit Sub
End If

If (IsNumeric(AnneeExport)) Then
    If CInt(AnneeExport) < 2020 Or CInt(AnneeExport) > 2050 Then
        MsgBox "L'année saisie n'est pas correcte!!", vbInformation
        Exit Sub
    Else
        Annee = CInt(AnneeExport)
    End If
Else
    MsgBox "L'année saisie n'est pas correcte!!", vbInformation
    Exit Sub
End If

Screen.MousePointer = 11

Dim SQL As String
Dim NomSite As String
Dim Nom_Client As String
Dim RedevTech As Double
Dim Requete, Requete2, Requete3, Requete4, Requete5 As String

Dim TabTech(500) As ClasseTech
Dim NumeroTech As Integer
Dim NumeroSemaine As Integer
Dim NumeroJour As Integer
Dim DateInter As Date

Requete = "SELECT HeureDebut,HeureFin,DateInterv,nomuti,preuti,NumeroTech FROM dbo_HeuresTech INNER JOIN Utilisateur ON Utilisateur.numuti = dbo_HeuresTech.NumeroTech where numinterv= " & Me.numint & ""
Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
Do Until lrs.EOF
    DateInter = lrs!DateInterv
    'Controle de l'année en cours

    '26/04/24 Modif ->Mauvaise ecriture du if !!
    If (Year(DateInter) = Annee) Then
        HeuresDepart = lrs!HeureDebut
        HeuresFin = lrs!HeureFin
        NumeroTech = lrs!NumeroTech
        '15/02/23 OM
        'Gestion cas Minuit On passe à 23h59 sinon ca compte en negatif depuis 00h00 le matin
        If Hour(HeuresFin) = 0 And Minute(HeuresFin) = 0 Then
            HeuresFin = "23:59:00"
        End If
        
        '24/01/2025 Comme pour les num de semaine passage en vbFirstFourDays->Consequences ??
        Nb_Min = DateDiff("n", HeuresDepart, HeuresFin, vbMonday, vbFirstFourDays)
        If HeuresFin = "23:59:00" Then
            Nb_Min = Nb_Min + 1
        End If
                            
        If TabTech(NumeroTech) Is Nothing Then
            Set TabTech(NumeroTech) = New ClasseTech
            TabTech(NumeroTech).Prenom = lrs!preuti
            TabTech(NumeroTech).Nom = lrs!nomuti
        End If
    
        '24/01/2025 Changement pour les numeros de semaine la regle est la semaine 1 est celle du 4 janvier
        NumeroSemaine = Format(DateInter, "ww", vbMonday, vbFirstFourDays)
        NumeroJour = Format(DateInter, "w", vbMonday)
        
        TabTech(NumeroTech).TabHeureItem(NumeroSemaine, NumeroJour) = TabTech(NumeroTech).TabHeure(NumeroSemaine, NumeroJour) + Nb_Min
    End If
lrs.MoveNext
    
Loop
lrs.Close
Set lrs = Nothing

'Nb_Heures = Nb_Min \ 60
'Nb_Minutes = Nb_Min Mod 60

'Pour Test Fersoft
'strCheminFichier = "C:\Fichier_Heures.xlsx"
strCheminFichier = "\\Serveur\commun\Commercial\A0- Clim Access\Dossier VERT et ROUGE (Ne pas effacer)\Fichier_Heures.xlsx"
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

Ligne = 5

'TODO
Dim NomChantier As String
NomChantier = nomsit + "_" + numdevacc

objSht.cells(2, 2).Value = NomChantier
DoEvents
Dim i As Integer
Dim Semaine As Integer
Dim Nb_Lignes_Par_Semaine As Integer
Nb_Lignes_Par_Semaine = 10
Dim Jour As Integer
IndexOperateur = 0

'Boucle sur les Tech
For i = 1 To 500
    If Not (TabTech(i) Is Nothing) Then
        If IndexOperateur >= Nb_Lignes_Par_Semaine Then
            MsgBox "Il y a Trop de technicien les données ne sont prevues que pour " + Str(Nb_Lignes_Par_Semaine) + "Maximum", vbInformation
            Exit For
        End If
        '03/01/2025 Passage à 53 (Car oui ca arrive !!)
        For Semaine = 1 To 53
            For Jour = 1 To 7
                If (TabTech(i).TabHeure(Semaine, Jour) <> 0) Then
                     LigneInsertion = 5 + (Semaine - 1) * Nb_Lignes_Par_Semaine + IndexOperateur
                     objSht.cells(LigneInsertion, 2) = TabTech(i).Nom + " " + TabTech(i).Prenom
                     objSht.cells(LigneInsertion, Jour + 2).Value = Str(TabTech(i).TabHeure(Semaine, Jour) / 60)
                End If
            Next Jour
        Next Semaine
        IndexOperateur = IndexOperateur + 1
    End If
Next

NomChantier = Replace(NomChantier, "/", "_")
NomChantier = Replace(NomChantier, "\", "_")
NomChantier = Replace(NomChantier, "'", " ")

Destination = dossier_dest + "\" + NomChantier + "_" + Str(Annee) + ".xlsx"
objWkbk.SaveAs (Destination)
'Fermer le fichier et le sauver
objWkbk.Close True
 
'libérer les pointeurs
Set objWkbk = Nothing
Set objXL = Nothing
Screen.MousePointer = 0

End Sub

Private Sub Commande399_Click()
If IsNull(Me.cheficdemint) = False Then
    Position = 0
    'La premiere partie (Avant le #\\) ne sert pas
    'Pour Fersoft (Car pasde chemiin serveur
    'Pos_Depart = InStr(1, Me.cheficdemint, "#", vbTextCompare)
    Pos_Depart = InStr(1, Me.cheficdemint, "#\\", vbTextCompare)
    If (Pos_Depart <> 0) Then
        Depart_Texte = Pos_Depart
        TexteDossier = Right(Me.cheficdemint, Depart_Texte)
        Pos_Depart = 0
        For i = 0 To 30
            Position = InStr(Pos_Depart + 1, TexteDossier, "\", vbTextCompare)
            If Position = 0 Then
                Exit For
            Else
                Pos_Depart = Position
            End If
        Next i
        'On enleve ce qu'il y a apres le dernier /
        If Pos_Depart <> 0 Then
            Chemin = Left(Me.cheficdemint, Pos_Depart)
            Shell Environ("WINDIR") & "\explorer.exe " & Chemin, vbNormalFocus
        End If
    End If
Else

End If

End Sub

Private Sub Commande402_Click()
UpdateFichierBanane 1
PDFCE.Creation_PDF_CE (Me.cptsit)
UpdateFichierBanane 2
End Sub

Private Sub Commande413_Click()
'11/04/25 Ajout pour refresh la liste des tech en fonction de l'intervenant
Me.Refresh
Me.Requery
End Sub

Private Sub Commande414_Click()
PartieSuivante
End Sub

Private Sub UpdatePartie1(OldComment As String, OldRefCliInt As String, numintint As String)
Requete = "UPDATE Intervention SET comint='" + OldComment + "',refcliint='" + OldRefCliInt + "' WHERE numintint=" & numintint
CurrentDb.Execute Requete, dbSeeChanges
End Sub

Private Sub PartieSuivante()
Dim Tabdata(91) As Object
Dim Param As String
Dim ReqStart As String
Dim Req As String
Dim TypeData As Integer
Dim OldComment As String
Dim NewComment As String
Dim OldRefCliInt As String
Dim NewRefCliInt As String
Dim IndiceEnCours As Integer
Dim Tableau() As String
Dim Txt As Variant
Dim i As Integer
Dim TexteMsgbox As String

    
On Error GoTo Error

TexteMsgbox = InputBox("Merci de Saisir le commentaire pour la partie suivante:", "Saisie Commentaire", " ")
If (TexteMsgbox = "") Then
    MsgBox "Création partie suivante annulée", vbOKOnly
    Exit Sub
End If

TexteMsgbox = Replace(TexteMsgbox, "'", "''", 1)
TexteMsgbox = Replace(TexteMsgbox, ",", " ", 1)
   
   
Req = ""
lSQl = "SELECT * FROM Intervention where numintint =  " & Me.numintint
Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)

If Not lrs.EOF Then
        If (lrs.RecordCount <> 0) Then
            For i = 0 To 90
                Set Tabdata(i) = lrs(i)
            Next i
    
            ReqStart = "Insert into Intervention (numint,cptsit,codint,typint,datintpre,heuintpre,datint,tpsallint,tpsretint,heuarrint,heudepint,codpan,comint,dirint,intfac,intfactok,intafact,codcon,staint,refint,refcliint,nbrappint,mntfac,datheuapp,datheulim,pannoncli,nbrpagfax,nummodres,numdev,objint,traitepar,majregsec,sigsit,sigtec,sigcli,creele,majle,nbrtecint,numdevacc,saisiepar,imprimeepar,classeepar,prediagpar,envoisoustraitantpar,numerodemandesoustraitant,retourficheinterventionpar,devisepar,duplicatacreepar,duplicatafait,prediagres,devisafaire,numpartenaire,numdevpartenaire,mnthtdevpartenaire,stadev,mnthtdevis,retourficheoriginal,retourfichecopie,retourfichecopieordi,numerocommande,cheficdemint,visitegratuite,datesignaturecontrat,numerocontratclient,devisfait,cheficdemcli,comdevis,devisanepasfaire,controleetancheite,natureintervention,photofaite,auditfait,commajregsec,sigtec2,sigcli2,sigsit2,sigtecimg,"
            ReqStart = ReqStart + "sigcliimg,sigsitimg,controleetancheiteponctuel,sigtecjson,sigclijson,sigsitbase64,comintposint,numutipre,comtec,heuvis,mntfmc,mntst,comdevisinterne) Values("

            'Verification du numéro de partie
            IndiceEnCours = -1
            If (VarType(Tabdata(13)) = 1) Then 'null
                OldComment = ""
            Else
                OldComment = Replace(Tabdata(13), "'", "''", 1)
                OldComment = Replace(OldComment, ",", " ", 1)
            End If
            If (VarType(Tabdata(21)) = 1) Then 'null
                OldRefCliInt = ""
            Else
                OldRefCliInt = Replace(Tabdata(21), "'", "''", 1)
                OldRefCliInt = Replace(OldRefCliInt, ",", " ", 1)
            End If
            If (Len(OldComment) >= 8) Then
                If (Mid(OldComment, 1, 7) = "PARTIE ") Then
                    IndiceEnCours = CInt(Mid(OldComment, 8, 2))
                End If
            End If
                       
            If (IndiceEnCours = -1) Then
                OldComment = "PARTIE 1 :" + OldComment
                NewRefCliInt = "PARTIE 2 :" + OldRefCliInt
                OldRefCliInt = "PARTIE 1 :" + OldRefCliInt
                NewComment = "PARTIE 2 :" + TexteMsgbox
                UpdatePartie1 OldComment, OldRefCliInt, Me.numintint
            Else
                NewComment = "PARTIE " + Trim(Str(IndiceEnCours + 1)) + " :" + TexteMsgbox
                Tableau = Split(OldRefCliInt, ":")
                i = 0
                For Each Txt In Tableau 'On ne prends pas le 1er (Indicie 0) car c'est 'partie x'
                    If (i = 1) Then
                        NewRefCliInt = Tableau(i)
                    ElseIf (i > 1) Then
                        NewRefCliInt = OldRefCliInt + ":" + Tableau(i)
                    End If
                    i = i + 1
                Next Txt
                NewRefCliInt = "PARTIE " + Trim(Str(IndiceEnCours + 1)) + " :" + NewRefCliInt
            End If
            
            For i = 1 To 90
               
                '30/05/25  Ces données ne doivent pas etre recupérées
                Select Case (i)
                    'New Comm
                    Case 13:
                        Req = Req + ",'" + NewComment + "'"
                    'New RefCliInt
                    Case 21:
                        Req = Req + ",'" + NewRefCliInt + "'"
                    'Qté Gaz
                    Case 56:
                        Req = Req + ",0"
                    'Avec Gaz
                    Case 80:
                        Req = Req + ",0"
                    'Index Gaz
                    Case 28:
                        Req = Req + ",0"
                    '33:Commentaire Inter,34:NomTEC,74 à 82:Signatures Lien+Json
                    Case 33, 34, 74, 75, 76, 77, 78, 79, 81, 82, 86:
                        Req = Req + ",''"
                    '12 Panne ->Forcé a 41 car c'est un texte vide ->ON ne peut pas mettre 0 car il y a une liaison de table
                    Case 12:
                        Req = Req + ",41"
                    '38:Nbtec,40:saisie par,55:duplicata
                    Case 38, 40, 55:
                        Req = Req + ",0"
                    '19:statut inter
                    Case 19:
                        Req = Req + ",1"
                    '61:Chemin Bon
                    Case 61:
                        Req = Req + ",''"
                    'Divers Bool
                    Case 57, 58, 32, 59, 72, 71, 69, 87, 15, 51, 49, 65, 26, 68:
                        Req = Req + ",0"
                      '22:statut fact
                    Case 22:
                        Req = Req + ",0"
                    'Dates/Heures diverses
                    Case 7, 8, 9, 10, 11:
                        Req = Req + ",''"
                Case Else
                             
                    TypeData = VarType(Tabdata(i))
                    If (TypeData = 2 Or TypeData = 3) Then 'Entier
                        If (i = 1) Then
                            Req = Req + Str(Tabdata(i))
                        Else
                            Req = Req + "," + Str(Tabdata(i))
                        End If
                    ElseIf (TypeData = 8) Then 'String
                            Dim StringTemp As String
                            StringTemp = Replace(Tabdata(i), "'", "''", 1)
                            Req = Req + ",'" + StringTemp + "'"
                    ElseIf (TypeData = 11) Then 'Bool
                        If CBool(Tabdata(i)) = False Then
                            Req = Req + ",0"
                        Else
                            Req = Req + ",1"
                        End If
                    ElseIf (TypeData = 1) Then 'Null
                            Req = Req + ",''"
                     ElseIf (TypeData = 7) Then 'Date
                        Req = Req + ",'" + Str(Tabdata(i)) + "'"
                     ElseIf (TypeData = 17) Then 'octet
                        Req = Req + "," + Str(Tabdata(i))
                     ElseIf (TypeData = 5) Then 'Flottant
                        Req = Req + "," + Str(Tabdata(i))
                     Else
                        MsgBox "Donnée inconnue Index " + Str(i) + ":" + Str(TypeData)
                     End If
                End Select
            Next i
            
            For i = 1 To 90
                TypeData = VarType(Tabdata(i))
                If (TypeData = 8) Then 'String
                            Param = "[Param" + Trim(Str(i)) + "]"
                            Req = Replace(Req, Param, "'" + Tabdata(i) + "'", 1)
                End If
            Next i
            
            Req = ReqStart + Req + ")"
            Debug.Print Req
            CurrentDb.Execute (Req)
            If (IndiceEnCours = -1) Then
                MsgBox "Partie 2 crée", vbOKOnly
            Else
                MsgBox "Partie " + Str(IndiceEnCours + 1) + " crée", vbOKOnly
            End If
         
            
        End If
End If
lrs.Close
Set lrs = Nothing
Exit Sub

Error:
    MsgBox "Saisie Partie " + Str(IndiceEnCours + 1) + " impossible,une erreur est apparue", vbCritical
End Sub

Private Sub Commande434_Click()
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

Private Sub Commande90_Click()
    Me.comint.SetFocus
    SendKeys "+{F2}"
End Sub

Private Sub Commande91_Click()
    Me.dirint.SetFocus
    SendKeys "+{F2}"
End Sub

Private Sub cptsit_AfterUpdate()
On Error GoTo Err_cptsit_AfterUpdate
    
    If Me.cptsit <> "" Then
        lSQl = "SELECT *  FROM Site WHERE cptsit = " & Me.cptsit
        Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
        
        If Not lrs.EOF Then
            Me.LstClient = lrs!numcli
            Me.nomsit = lrs!nomsit
            Me.adrsit = lrs!codpossit & " " & lrs!vilsit
            Me.comsit = lrs!comsit
            'Me.staint = 1 ' à planifier par défaut
            Me.natureintervention = 3 ' Technique par défaut (Sésar a aussi un type d'intervention : Filtres)
            'If Right(titre.Caption, 4) = "TIEN" Then
            '    Me.typint = 1
            'Else
            '    Me.typint = 2
            'End If
            If Me.codint = "" Then
                lSQl = "SELECT codint FROM intervenant where numintervenant = " & lrs!numintervenant
                Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
                If Not lrs.EOF Then
                    Me.codint = lrs!codint
                End If
            End If
        
            Select Case typint
                Case 1
                    Me.Détail.BackColor = RGB(209, 234, 240)
                Case 2
                    Me.Détail.BackColor = RGB(204, 255, 204)
                Case 3
                    Me.Détail.BackColor = RGB(255, 204, 204)
            End Select
            If Me.codint <> "" Then
                If Me.codint = "FMC" Then
                    Me.numerodemandesoustraitant.Visible = False
                    Me.envoisoustraitantpar.Visible = False
                Else
                    Me.numerodemandesoustraitant.Visible = True
                    Me.envoisoustraitantpar.Visible = True
                End If
            End If
        Else
            Me.nomsit = "inconnu"
            Me.adrsit = "inconnu"
            'Me.typsit = "inconnu"
        End If
        
        lrs.Close
        Set lrs = Nothing
    Else
        Me.nomsit = ""
        Me.adrsit = ""
        'Me.typsit = ""
    End If
    
  
    
Exit_cptsit_AfterUpdate:
Exit Sub

Err_cptsit_AfterUpdate:
    If err.Number = 2448 Then
        Resume Next
        Resume
    Else
        MsgBox err.Number & " " & err.Description
        Resume Exit_cptsit_AfterUpdate
    End If


End Sub


Private Sub devisfait_AfterUpdate()
    If Me.devisfait.Value = True Then
        Me.devisafaire = False
    End If
    Call MajIcone
End Sub


Private Sub Form_BeforeInsert(Cancel As Integer)
    Dim lrs As Recordset


    
    If Me.typint = 1 Then
        If Me.Chkmajreg = True Then
            lSQl = "SELECT cptsit, [Date] FROM SiteMAJRegistre WHERE (cptsit = " & Str(Me.cptsit) & ") AND ([Date] LIKE '" & Me.datint & "')"
            Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
            If lrs.EOF Then
                CurrentDb.Execute "INSERT INTO SiteMAJRegistre (cptsit, [Date]) VALUES (" & Me.cptsit & ",'" & Me.datint & "')"
            End If
            lrs.Close
            Set lrs = Nothing
        End If
    Else
        'If Me.refcliint = "" Or IsNull(Me.refcliint) Then
        '    MsgBox "Vous devez définir la référence client !", vbExclamation, "Attention"
        '    Me.refcliint.SetFocus
        '    Cancel = 1
        '    Exit Sub
        'End If
    
        'If Me.datheuapp = "" Or IsNull(Me.datheuapp) Then
        '    MsgBox "Vous devez définir la date d'appel !", vbExclamation, "Attention"
        '    Me.datheuapp.SetFocus
        '    Cancel = 1
        '    Exit Sub
        'End If
    
        'If Me.objint = "" Or IsNull(Me.objint) Then
        '    MsgBox "Vous devez définir l'objet de l'appel !", vbExclamation, "Attention"
        '    Me.objint.SetFocus
        '    Cancel = 1
        '    Exit Sub
        'End If
        
        ' Traité par
        'If Me.Modifiable96 = "" Or IsNull(Me.Modifiable96) Then
        '    MsgBox "Vous devez indiquer la personne ayant traité l'appel !", vbExclamation, "Attention"
        '    Me.Modifiable96.SetFocus
        '    Cancel = 1
        '    Exit Sub
        'End If
        
        'If Me.staint = "" Or IsNull(Me.staint) Then
        '    MsgBox "Vous devez indiquer le statut de l'intervention !", vbExclamation, "Attention"
        '    Me.staint.SetFocus
        '    Cancel = 1
        '    Exit Sub
        'End If
        
        'If Me.datintpre = "" Or IsNull(Me.datintpre) Then
        '   MsgBox "Vous devez définir la date d'intervention prévue !", vbExclamation, "Attention"
        '   Me.datintpre.SetFocus
        '    Cancel = 1
        '    Exit Sub
        'End If
        
        ' Heure d'intervention prévue
        'If Me.Texte59 = "" Or IsNull(Me.Texte59) Then
        '    MsgBox "Vous devez définir l'heure d'intervention prévue !", vbExclamation, "Attention"
        '    Me.Texte59.SetFocus
        '    Cancel = 1
        '    Exit Sub
        'End If
        
        If Me.staint <> 9 Then
            
            ' Cohérence de la date prévue en fonction de la date d'appel
            'If DateDiff("s", Me.datheuapp, CDate(Me.datintpre & " " & Me.heuintpre)) < 0 Then
            '    MsgBox "La date/heure prévue doit être ultérieure la date/heure d'appel", vbExclamation, "Attention"
            '    Me.datintpre.SetFocus
            '    Cancel = 1
            '    Exit Sub
            'End If
            
        Else
        
            'If Me.datint = "" Or IsNull(Me.datint) Then
            '    MsgBox "Vous devez définir la date d'intervention réelle !", vbExclamation, "Attention"
            '    Me.datint.SetFocus
            '    Cancel = 1
            '    Exit Sub
            'End If
            
            'If Me.numint = "" Or IsNull(Me.numint) Then
            '    MsgBox "Vous devez définir le numéro de bon !", vbExclamation, "Attention"
            '    Me.numint.SetFocus
           '    Cancel = 1
           '     Exit Sub
           ' End If
            
            'If Me.nummodres = "" Or IsNull(Me.nummodres) Then
            '    MsgBox "Vous devez définir le mode de résolution !", vbExclamation, "Attention"
            '    Me.nummodres.SetFocus
            '    Cancel = 1
            '    Exit Sub
            'End If
            
            'If Me.heuarrint = "" Or IsNull(Me.heuarrint) Then
            '    MsgBox "Vous devez définir l'heure de début de l'intervention !", vbExclamation, "Attention"
            '    Me.heuarrint.SetFocus
            '    Cancel = 1
            '    Exit Sub
            'End If
            
            'If Me.heudepint = "" Or IsNull(Me.heudepint) Then
            '    MsgBox "Vous devez définir l'heure de fin de l'intervention !", vbExclamation, "Attention"
           '     Me.heudepint.SetFocus
           '     Cancel = 1
           '     Exit Sub
           ' End If
            
            'If Me.comint = "" Or IsNull(Me.comint) Then
            '    MsgBox "Vous devez définir le commentaire de l'intervention !", vbExclamation, "Attention"
            '    Me.comint.SetFocus
            '    Cancel = 1
            '    Exit Sub
            'End If
            
            ' Cohérence de la date prévue en fonction de la date d'appel
            'If DateDiff("s", Me.datheuapp, CDate(Me.datintpre & " " & Me.heuintpre)) < 0 Then
            '    MsgBox "La date/heure prévue doit être ultérieure la date/heure d'appel", vbExclamation, "Attention"
            '    Me.datintpre.SetFocus
            '    Cancel = 1
            '    Exit Sub
            'End If
    
            ' Cohérence de la date réelle en fonction de la date d'appel
            'If DateDiff("s", Me.datheuapp, CDate(Me.datint & " " & Me.heuarrint)) < 0 Then
            '    MsgBox "La date/heure d'arrivée doit être ultérieure à la date/heure d'appel", vbExclamation, "Attention"
            '    Me.datint.SetFocus
             '   Cancel = 1
            '    Exit Sub
            'End If
            
            ' Cohérence de l'heure de fin en fonction de l'heure de début
            'If DateDiff("s", Me.heuarrint, Me.heudepint) < 0 Then
            '    MsgBox "L'heure de fin de l'intervention doit être ultérieure à l'heure de début", vbExclamation, "Attention"
            '    Me.heudepint.SetFocus
            '    Cancel = 1
            '    Exit Sub
           ' End If
            
        End If
    End If

End Sub

Private Sub Form_BeforeUpdate(Cancel As Integer)

    Form_BeforeInsert Cancel
    
End Sub


Private Sub Form_Current()
    Me.CheckAutre.Value = False
    Me.CheckChauff.Value = False
    Me.CheckClim.Value = False
    Me.Intervenant_Sous_formulaire_Clim.Visible = False
    Call cptsit_AfterUpdate
    Call MajIcone
    
   
    ColoreFenetre
    
    On Error Resume Next
    If Me.Cocher231.Value = True Then
        Me.comdevis.Visible = True
    End If
    
     '02/10/20 Modif OM
    'Recherche Chemin par defaut
    Dim lrs As Recordset
    Requete = "SELECT *  FROM Site WHERE cptsit = " & Str(Me.cptsit)
    Set lrs = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
    Me.CaptionGarantie.Visible = False
    If Not lrs.EOF Then
        If IsNull(lrs!cptsit) = False Then
            Me.Texte340 = lrs!chemindoc
            Me.Étiquette343.Caption = lrs!nomsit
            '19/08/25 Ajout Avertissement Garantie
            Me.CaptionGarantie.Visible = Form_Site.Calcul_Affiche_Garantie(lrs!cptsit)
        End If
    End If
    '19/08/25 Ajout du close et nothing
    lrs.Close
    Set lrs = Nothing
    Me.Commande402.Visible = False
    
    '19/08/25 Recherche si Multiples inter le meme jour
    Me.CaptionMultiInter.Visible = False
    If (IsNull(Me.datint) = False) Then
        Me.CaptionMultiInter.Visible = MultiplesInter(Me.datint, Me.cptsit)
    End If
    
    If (Me.CocherNacelle = True) Then
        Me.Nacelle.Visible = True
    Else
        Me.Nacelle.Visible = False
    End If
    
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
    TesterAfficheMnDepannTel
    
End Sub
Public Function MultiplesInter(DateInter As String, CptSite As String) As Boolean
    Dim Nbinterv As Recordset
    'Il faut inverser Mois/Jour
    Requete = "SELECT datint  FROM intervention WHERE cptsit = " & Str(Me.cptsit) + " and datint=#" + Format(DateInter, "mm/dd/yyyy") + "#"
    Set Nbinterv = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
    'Move last obligatoire car on veut connaitre le nombre
    Nbinterv.MoveLast

    If Nbinterv.RecordCount > 1 Then
        Nbinterv.Close
        MultiplesInter = True
    Else
        Nbinterv.Close
        MultiplesInter = False
    End If
    
    Set Nbinterv = Nothing
    
End Function



Private Sub Form_Load()
    Dim arrSplitStrings() As String
    

    If Me.OpenArgs <> "" Then
        '20/10/25 Auto Remplissage du traitepar
        Me.traitepar.Value = NumGestEnCours
        '20/10/25 Passage en Split et ajout de l'appel resolu
        arrSplitStrings = Split(Me.OpenArgs, ";")
        'récupération du numcli et cptsit à faire pour positionner les DropDownList
        Me.lstSite = arrSplitStrings(0)
        Me.LstClient = arrSplitStrings(1)
        If (UBound(arrSplitStrings) = 3) Then
            If (arrSplitStrings(3) = "ResTel") Then
                Me.staint = 10
                Me.typint = 14
                Me.codint = "FMC"
                Me.datheulim = DateSerial(Year(Now), Month(Now) + 1, 0)
                Me.refcliint = "Appel du " + Format(Now, "dd/mm/yy")
                Me.chkprediagres.Value = True
            End If
        Else
        
            
            If (Me.staint = "") Or IsNull(Me.staint) Then
                Me.staint = 1
            End If
        End If
    End If
    
    Dim lSQl As String
    Dim lrs As Recordset
    If Me.cptsit <> "" Then
        lSQl = "SELECT *  FROM Devis WHERE statutdevis<>6 and numerosite =" & Me.cptsit
        Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
        
        If lrs.EOF Then
            Me.Onglets.Pages(2).Picture = ""
        Else
            Me.Onglets.Pages(2).PictureData = Me.Onglets.Pages(3).PictureData
        End If
        lrs.Close
        Set lrs = Nothing
    End If
    
    '21/04/26 Ajout des devis travaux
    If Me.cptsit <> "" Then
        lSQl = "SELECT *  FROM DevisTravaux WHERE statutdevis<>6 and numerosite =" & Me.cptsit
        Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
        
        If lrs.EOF Then
            Me.Onglets.Pages(4).Picture = ""
        Else
            Me.Onglets.Pages(4).PictureData = Me.Onglets.Pages(3).PictureData
        End If
        lrs.Close
        Set lrs = Nothing
    End If
   
    
    If Me.codint <> "" Then
        If Me.codint = "FMC" Then
            Me.numerodemandesoustraitant.Visible = False
            Me.envoisoustraitantpar.Visible = False
        Else
            Me.numerodemandesoustraitant.Visible = True
            Me.envoisoustraitantpar.Visible = True
        End If
    End If
    
    Calcul_Heures
   
        'Me.Modifiable386.RowSource = "SELECT dbo_StatutFacture.IndexLigne, dbo_StatutFacture.Statut FROM dbo_StatutFacture"
        'Me.Modifiable388.RowSource = "SELECT dbo_StatutFacture.IndexLigne, dbo_StatutFacture.Statut FROM dbo_StatutFacture"
   
    
End Sub




Private Sub Ajout_Noms()
Dim Data_Ref1 As Recordset
Dim Data_Ref2 As Recordset
Dim Noms As String
Dim i As Integer
Dim Prenom As String

'Recherche des intervenant
If IsNull(Me.numintint) Then Exit Sub
If Me.numintint = "" Then Exit Sub
Requete = "SELECT numuti  FROM interventiontechnicien WHERE numintint=" & Me.numintint
'Close Recordset Fait
Set Data_Ref2 = CurrentDb().OpenRecordset(Requete, dbOpenSnapshot)
If (Data_Ref2.RecordCount <> 0) Then
    i = 0
    Do Until Data_Ref2.EOF
        Requete = "SELECT nomuti, preuti  FROM Utilisateur WHERE numuti=" & Data_Ref2(0)
        'Recherche Nom Prenom
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
End If
Data_Ref2.Close
Set Data_Ref2 = Nothing
Noms = Left(Noms, 50)
Requete = "UPDATE Intervention SET numdevpartenaire='" + Noms + "' WHERE numintint=" & Me.numintint
CurrentDb.Execute Requete, dbSeeChanges
End Sub

Private Sub InterventionTechnicien_Exit(Cancel As Integer)
Ajout_Noms
Me.Requery
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
        stDocName = "FaxInterventionClient"
        'DoCmd.OpenForm stDocName, , , , , , lArgs
    
        stLinkCriteria = "numintint=" & Me!numintint
        DoCmd.OpenReport stDocName, acPreview, , stLinkCriteria
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
    Set Rst2 = db.OpenRecordset(Vsql, dbOpenSnapshot)
    If Rst2.EOF = True Then
        rst.AddNew
        rst("numintint") = numintint
        rst("numsitmarref") = ListeMateriel
        rst.Update
        SfMaterielPanne.Requery
    End If
    rst.Close
    Set rst = Nothing
    Rst2.Close
    Set Rst2 = Nothing

End Sub

Private Sub Montant_Devis_Partenaire_AfterUpdate()
    Call MajMontantEconomie
End Sub
Private Sub MajMontantEconomie()
    Montant_économie_H_T_.Requery
End Sub

Private Sub Montant_H_T__Devis_AfterUpdate()
Call MajMontantEconomie
End Sub

Private Sub lstClient_AfterUpdate()
lstSite.Requery
End Sub

Private Sub mntfmc_Dirty(Cancel As Integer)
Me.datesignaturecontrat = Format(Day(Now), "00") + "/" + Format(Month(Now), "00") + "/" + Format(Year(Now), "00")
End Sub

Private Sub Modifiable241_Change()
TesterAfficheMnDepannTel
End Sub
Private Sub TesterAfficheMnDepannTel()
Me.LabelMnTel.Visible = False
Me.NbMinTel.Visible = False
'19/08/2025 Création OM
If (Me.staint = 10) Then
    Me.LabelMnTel.Visible = True
    Me.NbMinTel.Visible = True
End If

End Sub


Private Sub Modifiable386_BeforeUpdate(Cancel As Integer)

If (IsNull(Modifiable386.OldValue) = False) Then
    Rep = Verification_Droit_Modif(Modifiable386.OldValue, False)
    If (Rep = False) Then
        MsgBox "Vous n'avez pas les droits pour faire ce changement", vbCritical, "Interdit"
        Cancel = True
        Exit Sub
    End If
End If
Rep = Verification_Droit_Modif(Modifiable386.Text, True)
If (Rep = False) Then
    MsgBox "Vous n'avez pas les droits pour faire ce changement", vbCritical, "Interdit"
    Cancel = True
End If
End Sub

Private Sub Modifiable388_BeforeUpdate(Cancel As Integer)

If (IsNull(Modifiable388.OldValue) = False) Then
    Rep = Verification_Droit_Modif(Modifiable388.OldValue, False)
    If (Rep = False) Then
        MsgBox "Vous n'avez pas les droits pour faire ce changement", vbCritical, "Interdit"
        Cancel = True
        Exit Sub
    End If
End If
Rep = Verification_Droit_Modif(Modifiable388.Text, True)
If (Rep = False) Then
    MsgBox "Vous n'avez pas les droits pour faire ce changement", vbCritical, "Interdit"
    Cancel = True
End If
End Sub

Private Sub nomsit_KeyDown(KeyCode As Integer, Shift As Integer)
    If KeyCode = vbKeyReturn Then
        If Me.nomsit.Text <> "" Then
        lSQl = "SELECT *  FROM Site WHERE nomsit like '" & Me.nomsit.Text & "%'"
        Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenSnapshot)
        
        If Not lrs.EOF Then
            Me.LstClient = lrs!numcli
            Me.nomsit = lrs!nomsit
            Me.adrsit = lrs!codpossit & " " & lrs!vilsit
            Me.cptsit = lrs!cptsit
            'Me.typsit = lrs!typsit
            'If Not IsNull(Me.datheuapp) Then
            '    Me.datheulim.Value = CalculerHeureLimite(Me.datheuapp)
            'End If
        Else
            Me.adrsit = "aucun site trouvé !"
            'Me.typsit = "inconnu"
        End If
        
        lrs.Close
        Set lrs = Nothing
    Else
        Me.nomsit = ""
        Me.adrsit = ""
        'Me.typsit = ""
    End If
    End If
End Sub



Private Sub prediagpar_AfterUpdate()
'50 Caracteres Max
'Me.TextePreDiag = "Par:" + Right(prediagpar.Text, 26) + " le " + Format(Str(Day(Now)), "00") + "/" + Format(Str(Month(Now)), "00") + "/" + Right(Trim(Str(Year(Now))), 2) + " à " + Format(Str(Hour(Now)), "00") + ":" + Format(Minute(Now), "00")
Me.TextePreDiag = Format(Str(Day(Now)), "00") + "/" + Format(Str(Month(Now)), "00") + "/" + Right(Trim(Str(Year(Now))), 2) + " à " + Format(Str(Hour(Now)), "00") + ":" + Format(Minute(Now), "00")
Me.TextePreDiag.Visible = True
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

   Call MajIcone
   
   '31/03/22 Ajout Heures Auto dans Heures Technicien
'TODO reste a definir si on le fait pour tous les types d'inter et si la modification est possible apres
If Me.staint = 7 Then
    AjoutHeures
End If

End Sub
Private Sub MajIcone()
'21/04/26 Ajoutonglet 4 Devis Travaux
If (Me.staint = 7 Or Me.staint = 6) And (Me.devisafaire = True Or Me.devisfait = True) Then
    
    Me.Onglets.Pages(2).Visible = True
    Me.Onglets.Pages(4).Visible = True
    If (Me.devisfait = True) Then
        Me.Onglets.Pages(2).Picture = ""
        Me.Onglets.Pages(4).Picture = ""
    Else
        Me.Onglets.Pages(2).PictureData = Me.Onglets.Pages(3).PictureData ' Icône Point Exclamation
        Me.Onglets.Pages(4).PictureData = Me.Onglets.Pages(3).PictureData ' Icône Point Exclamation
    End If
Else
    Me.Onglets.Pages(2).Visible = False
    Me.Onglets.Pages(4).Visible = False
End If
    
If (Me.staint <> 7 And Me.staint <> 6) Then ' ni clôturée ni effectuée en attente retour
    If (Me.devisfait = True) Then
        Me.Onglets.Pages(2).Picture = ""
        Me.Onglets.Pages(4).Picture = ""
    Else
            Me.Onglets.Pages(2).PictureData = Me.Onglets.Pages(3).PictureData ' Icône Point Exclamation
            Me.Onglets.Pages(4).PictureData = Me.Onglets.Pages(3).PictureData ' Icône Point Exclamation
    End If
Else
    Me.Onglets.Pages(1).Picture = ""
End If
If (Me.staint = 6) Then
    Me.Onglets.Pages(1).PictureData = Me.Onglets.Pages(4).PictureData  ' Icône Dossier
End If
If (Me.staint = 4 Or Me.staint = 5) Then
    Me.Onglets.Pages(1).Picture = "" ' Icône vide
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

Private Sub staint_BeforeUpdate(Cancel As Integer)
    If (Me.cheficdemint = "" And Me.staint = 7) Then
        Cancel = True
        MsgBox "La demande ne peut pas être clôturée s'il n'y a pas de fichier associé.", vbExclamation, "Clôture interrompue"
    End If
End Sub

Private Sub Texte109_Change()
ListeMateriel.Requery
End Sub
Private Sub CmdFermer2_Click()
On Error GoTo Err_CmdFermer2_Click


    If Me.Dirty Then Me.Dirty = False
    If VerifDatHeuLim Then
    DoCmd.Close
    End If

Exit_CmdFermer2_Click:
    Exit Sub

Err_CmdFermer2_Click:
    MsgBox err.Description
    Resume Exit_CmdFermer2_Click
    
End Sub
Private Sub CmdValiderFermer_Click()
On Error GoTo Err_CmdValiderFermer_Click


    DoCmd.RunCommand acCmdSaveRecord
    DoCmd.Close

Exit_CmdValiderFermer_Click:
    Exit Sub

Err_CmdValiderFermer_Click:
    MsgBox err.Description
    Resume Exit_CmdValiderFermer_Click
    
End Sub

Private Sub Texte168_AfterUpdate()

End Sub

Private Sub TxtHeuLim_AfterUpdate()
    'If Me.numcli <> "" And Me.nomsit <> "" And Me.datheulim <> "" And Not IsNull(Me.cptsit) Then
    '    Me.LblCloture.Caption = "SAISIE CLOTURE D'INTERVENTION - Client " & Me.numcli.Column(1) & " - Site " & Me.nomsit & "- Ville :" & Me.cptsit.Columns(3) & " - prévue le " & Me.datintpre
    'End If

    
End Sub

Private Sub TxtHeuLim_GotFocus()
  If (Me.TxtHeuLim <> Null) Then
    TxtHeuLim.SelStart = 0
    TxtHeuLim.SelLength = Len(Me.TxtHeuLim)
  End If
End Sub

Private Sub typint_AfterUpdate()

ColoreFenetre
TesterAfficheMnDepannTel
End Sub

Public Sub ColoreFenetre()

'10/11/25 Nouvelle Fonction Malheureusement me.typint.txt n'est pas encore chargé si Load de la page donc on ecrit le texte en dur->Sinon il faudrait le recherche dans sa table vu que la couleurest en dur on fait pas

Select Case typint
        Case 1
            Me.Détail.BackColor = RGB(209, 234, 240)
            Me.titre.Caption = "Création et Clôture d'intervention - ENTRETIEN"
        Case 2
            Me.Détail.BackColor = RGB(204, 255, 204)
            Me.titre.Caption = "Création et Clôture d'intervention - DEPANNAGE"
        Case 3
            Me.Détail.BackColor = RGB(255, 204, 204)
            Me.titre.Caption = "Création et Clôture d'intervention - Devis SAV"
        Case 4
           Me.Détail.BackColor = RGB(255, 204, 204)
           Me.titre.Caption = "Création et Clôture d'intervention - Autre"
        Case 5
           Me.Détail.BackColor = RGB(255, 226, 198)
           Me.titre.Caption = "Création et Clôture d'intervention - En Travaux"
        Case 6
           Me.Détail.BackColor = RGB(255, 230, 255)
           Me.titre.Caption = "Création et Clôture d'intervention - En Création"
        Case 7
           Me.Détail.BackColor = RGB(255, 230, 255)
           Me.titre.Caption = "Création et Clôture d'intervention - Désenfumage"
        Case 8
           Me.Détail.BackColor = RGB(255, 230, 255)
           Me.titre.Caption = "Création et Clôture d'intervention - Inter. réalisée en attente devis signé client"
        '10/11/25 New
        Case 9
           Me.Détail.BackColor = RGB(255, 204, 204)
           Me.titre.Caption = "Création et Clôture d'intervention - Audit"
        '10/11/25 New
        Case 12
           Me.Détail.BackColor = RGB(255, 204, 204)
           Me.titre.Caption = "Création et Clôture d'intervention - Devis SAV (TR)"
        '10/11/25 New
        Case 13
           Me.Détail.BackColor = RGB(209, 234, 240)
           Me.titre.Caption = "Création et Clôture d'intervention - Maint.Chaudiere"
        '20/10/25 New
        Case 14
           Me.Détail.BackColor = RGB(255, 204, 204)
           Me.titre.Caption = "Création et Clôture d'intervention - Appel Résolu Par Téléphone"
            
    End Select
    
End Sub


Private Sub Commande296_Click()
On Error GoTo Err_Commande296_Click


    DoCmd.GoToRecord , , acLast

Exit_Commande296_Click:
    Exit Sub

Err_Commande296_Click:
    MsgBox err.Description
    Resume Exit_Commande296_Click
    
End Sub
Private Sub CmdApercu_Click()
On Error GoTo Err_CmdApercu_Click

    Dim stDocName, nomdonneur, args As String
    stDocName = "FicheIntervention"
    'DoCmd.OpenReport stDocName, acViewPreview, , "numintint=" & Me.numintint, acWindowNormal, Me.heuvis
    If Me.heuvis = True Then
        args = "O"
    Else
        args = "N"
    End If
    DoCmd.OpenReport stDocName, acViewPreview, , "numintint=" & Me.numintint, acWindowNormal, args

Exit_CmdApercu_Click:
    Exit Sub

Err_CmdApercu_Click:
    MsgBox err.Description
    Resume Exit_CmdApercu_Click
    
End Sub
