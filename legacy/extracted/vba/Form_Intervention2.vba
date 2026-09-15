Attribute VB_Name = "Form_Intervention2"
Attribute VB_Base = "0{63BDC8D0-9085-4FF7-B0BB-7058A340A0CC}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
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



Private Sub chkDevisAFaire_AfterUpdate()
    If Me.chkDevisAFaire = True Or Me.devisfait = True Then
        Me.Onglets.Pages(2).Visible = True
    Else
        Me.Onglets.Pages(2).Visible = False
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
If chkprediagres.Value = True Then
    Me.staint = 7
Else
    Me.staint = 1
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

Private Sub CmdEnvoyerMail_Click()

    Dim strMessage As String    ' Le corps du message
    Dim strDest As String       ' L'adresse e-mail du destinataire
    Dim Destinataire As String
    Dim objet As String
    Dim Corps As String
    Dim RsContact As Recordset
    
    lSQl = "select Contact.*,Intervention.numintint from Contact inner join Intervention on Contact.codcon = Intervention.codcon where adrmelcon is not null and numintint=" & Me.numintint
    Set RsContact = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
    If Not RsContact.EOF Then
        Destinataire = RsContact("adrmelcon")
        strMessage = "A l'attention de " & RsContact("precon") & " " & RsContact("nomcon")
    End If
    
    objet = "Demande d'intervention pour le site : " & Me.nomsit & " "
    'sendEmail destinataire, objet, corps
    
    

 
' Création du corps du message
strMessage = strMessage & vbCrLf & " "
strMessage = strMessage & vbCrLf & "Texte du mail."
strMessage = strMessage & vbCrLf & vbCrLf & " "
strMessage = strMessage & vbCrLf & "http://www."
 
' On demande l'adresse e-mail du destinataire
strDest = Destinataire 'InputBox("Tapez une adresse e-mail existante : ", _

  
If strDest = "" Then Exit Sub
 
' Envoi du message
SendMail strDest, _
  objet, _
  strMessage, _
  True
    
End Sub






'Public Sub sendEmail(destinataire As String, objet As String, corps As String)
    'Dim objOutlook As Object    'Use for late binding
    'Dim objNameSpace As Object  'Use for late binding
    'Dim MailOutLook As Object   'Use for late binding
    'Dim strPath As String
    'Dim strFileName As String
    
    '*************************************************
    'On Error Resume Next
    'Set objOutlook = GetObject(, "Outlook.Application")
    'On Error GoTo 0
    
   ' If objOutlook Is Nothing Then
    '    Set objOutlook = CreateObject("Outlook.Application")
    'End If
    '*****************************************************
    
    'Set MailOutLook = objOutlook.CreateItem(0)  'Late binding method
    'Dim MyOutlook As New Outlook.Application
    'Dim MyMail As Outlook.MailItem
    'Set MyMail = MyOutlook.CreateItem(olMailItem)
    'If Me.cheficdemint <> "" Then
     '   MyMail.Attachments.Add Left(Me.cheficdemint.Value, InStr(Me.cheficdemint.Value, "#") - 1), olByValue, 1, "Bon d'intervention " & Me.numintint & ".pdf"
    'End If
        
    'corps = corps & PreparerSignature
    'With MyMail
     ' .BodyFormat = 3      'Late binding in lieu of olFormatRichText
     ' .To = destinataire
      ''.cc = ""
      ''.bcc = ""
      '.Subject = objet
      '.HTMLBody = corps
      
          
      
      '.Send
      '.Display  'Use for testing in lieu of .Send
    'End With
 'End Sub


Private Sub cmdEnvoyerMailPartenaire_Click()
 Dim strMessage As String    ' Le corps du message
    Dim strDest As String       ' L'adresse e-mail du destinataire
    Dim Destinataire As String
    Dim objet As String
    Dim Corps As String
    Dim RsContact As Recordset
    Dim RsIntervenant As Recordset
    
    lSQl = "select Intervenant.* from Intervenant inner join Intervention on Intervenant.codint = Intervention.codint where adrmelint is not null and numintint=" & Me.numintint
    Set RsIntervenant = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
    If Not RsIntervenant.EOF Then
        Destinataire = RsIntervenant("adrmelint")
    End If
    
    objet = "Demande d'intervention pour le client : " & Me.LstClient.Column(1) & " pour le site : " & Me.nomsit & " "
    strMessage = "Madame, Monsieur, ..."
    'sendEmail destinataire, objet, corps


 
' Création du corps du message
strMessage = strMessage & vbCrLf & " "
strMessage = strMessage & vbCrLf & "Texte du mail."
strMessage = strMessage & vbCrLf & vbCrLf & " "
strMessage = strMessage & vbCrLf & "http://www."
 
' On demande l'adresse e-mail du destinataire
strDest = InputBox("Tapez une adresse e-mail existante : ", , Destinataire)

  
If strDest = "" Then Exit Sub
 
' Envoi du message
SendMail strDest, _
  objet, _
  strMessage, _
  True


End Sub


Public Sub SendMail(ByVal strEmail As String, _
  ByVal strObj As String, _
  ByVal strMsg As String, _
  ByVal blnEdit As Boolean)
On Error Resume Next
DoCmd.SendObject acSendNoObject, , , strEmail, , , strObj, strMsg, blnEdit
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
   'On Error Resume Next
    'If CurrentProject.AllForms("ListeInterventionGenerale").IsLoaded Then
    '    Forms![ListeInterventionGenerale]![ListeInterventionGenerale sous-formulaire].Form.Requery
    'End If
    'If gCancel = False Then
    If VerifDatHeuLim Then
     DoCmd.Close
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
        Set rs = CurrentDb.OpenRecordset("select max(numintint) from intervention", dbOpenDynaset, dbSeeChanges)
        If Not rs.EOF Then
            DoCmd.Requery
            DoCmd.ApplyFilter , "numintint=" & rs(0)
        End If
        
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
    ' A tester
    If (Me.cheficdemint <> "") Then
        Dim sFile As String
        sFile = Left(Me.cheficdemint, InStr(Me.cheficdemint, "#") - 1)
        fPrintFile (sFile)
    End If
    
    

End Sub

Private Sub Cocher231_AfterUpdate()
    If Me.Cocher231.Value = True Then
        Me.comdevis.Visible = True
        Me.devisafaire.Value = False
    Else
        Me.comdevis.Visible = False
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
        Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
        
        If Not lrs.EOF Then
            Me.LstClient = lrs!numcli
            Me.nomsit = lrs!nomsit
            Me.adrsit = lrs!codpossit & " " & lrs!vilsit
            'Me.comsit = lrs!comsit
            'Me.staint = 1 ' à planifier par défaut
            Me.natureintervention = 3 ' Technique par défaut (Sésar a aussi un type d'intervention : Filtres)
            'If Right(titre.Caption, 4) = "TIEN" Then
            '    Me.typint = 1
            'Else
            '    Me.typint = 2
            'End If
            
            If lrs!numintervenant = "" Then  ' code Alain
            'If lrs!numintervenant <> "" Then
                lSQl = "SELECT codint FROM intervenant where numintervenant = " & lrs!numintervenant
                Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
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



    
    If Me.typint = 1 Then
        If Me.Chkmajreg = True Then
            lSQl = "SELECT cptsit, [Date] FROM SiteMAJRegistre WHERE (cptsit = " & Str(Me.cptsit) & ") AND ([Date] LIKE '" & Me.datint & "')"
            Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
            If lrs.EOF Then
                CurrentDb.Execute "INSERT INTO SiteMAJRegistre (cptsit, [Date]) VALUES (" & Me.cptsit & ",'" & Me.datint & "')"
            End If
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
    Call cptsit_AfterUpdate
    Call MajIcone
    If (Me.typint = 1) Then
        Me.titre.Caption = "Création et Clôture d'intervention - ENTRETIEN"
    End If
    If (Me.typint = 2) Then
        Me.titre.Caption = "Création et Clôture d'intervention - DEPANNAGE"
    End If
    
     Select Case typint
        Case 1
            Me.Détail.BackColor = RGB(209, 234, 240)
        Case 2
            Me.Détail.BackColor = RGB(204, 255, 204)
        Case 3
            Me.Détail.BackColor = RGB(255, 204, 204)
            
    End Select
    On Error Resume Next
    If Me.Cocher231.Value = True Then
        Me.comdevis.Visible = True
    End If
End Sub

Private Sub Form_Load()

    If Me.OpenArgs <> "" Then
     'récupération du numcli et cptsit à faire pour positionner les DropDownList
        Me.lstSite = Left(Me.OpenArgs, InStr(Me.OpenArgs, ";") - 1)
        Me.LstClient = Mid(Me.OpenArgs, InStr(Me.OpenArgs, ";") + 1, Len(Me.OpenArgs))
        If (Me.staint = "") Or IsNull(Me.staint) Then
            Me.staint = 1
        End If
    End If
    
    Dim lSQl As String
    Dim lrs As Recordset
    If Me.cptsit <> "" Then
        lSQl = "SELECT *  FROM Devis WHERE statutdevis<>6 and numerosite =" & Me.cptsit
        Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
        
        If lrs.EOF Then
            Me.Onglets.Pages(2).Picture = ""
        Else
            Me.Onglets.Pages(2).PictureData = Me.Onglets.Pages(3).PictureData
        End If
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
End Sub


Private Sub Form_Unload(Cancel As Integer)
    'If VerifDatHeuLim Then
    '    Cancel = True
    '    gCancel = False
    '    'Me.TxtHeuLim.SetFocus
        'You could set the focus on the specific control if your wish, change the background color, ...
    'Else
    '    gCancel = True
    'End If
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
    Set Rst2 = db.OpenRecordset(Vsql)
    If Rst2.EOF = True Then
        rst.AddNew
        rst("numintint") = numintint
        rst("numsitmarref") = ListeMateriel
        rst.Update
        SfMaterielPanne.Requery
    End If


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

Private Sub nomsit_KeyDown(KeyCode As Integer, Shift As Integer)
    If KeyCode = vbKeyReturn Then
        If Me.nomsit.Text <> "" Then
        lSQl = "SELECT *  FROM Site WHERE nomsit like '" & Me.nomsit.Text & "%'"
        Set lrs = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
        
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

End Sub
Private Sub MajIcone()

If (Me.staint = 7 Or Me.staint = 6) And (Me.devisafaire = True Or Me.devisfait = True) Then
    Me.Onglets.Pages(2).Visible = True
    If (Me.devisfait = True) Then
        Me.Onglets.Pages(2).Picture = ""
    Else
        Me.Onglets.Pages(2).PictureData = Me.Onglets.Pages(3).PictureData ' Icône Point Exclamation
    End If
Else
    
    Me.Onglets.Pages(2).Visible = False
End If
    
If (Me.staint <> 7 And Me.staint <> 6) Then ' ni clôturée ni effectuée en attente retour
    If (Me.devisfait = True) Then
        Me.Onglets.Pages(2).Picture = ""
    Else
        Me.Onglets.Pages(2).PictureData = Me.Onglets.Pages(3).PictureData ' Icône Point Exclamation
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

    Select Case typint
        Case 1
            Me.Détail.BackColor = RGB(209, 234, 240)
        Case 2
            Me.Détail.BackColor = RGB(204, 255, 204)
        Case 3
            Me.Détail.BackColor = RGB(255, 204, 204)
            
    End Select

End Sub
