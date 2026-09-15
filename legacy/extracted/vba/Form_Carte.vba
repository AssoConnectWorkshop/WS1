Attribute VB_Name = "Form_Carte"
Attribute VB_Base = "0{B3FBBE1A-499A-4013-A06E-36612DF1C014}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database
Option Explicit

Private Const csScriptLanguage As String = "JavaScript"


'Public WithEvents HTML As HTMLDocument
'Dim tMarker() As String

Private Sub HTML_onmouseover()
'main event space procedure
    On Error GoTo err
    'srcElement should be the one with the mouse over it
    'that caused this event - mouseover
    'Dim curElement As MSHTML.IHTMLElement
    'Set curElement = _
        WebBrowser.Document.parentWindow.event.srcElement

    'see if we have an object
    'If Not (curElement Is Nothing) Then
        'use getattribute instead of more direct object
        ' properties
        '0 flag=Default. Performs a property search that is
        ' not case-sensitive, and returns an interpolated
        ' value if the property is found
        'http://msdn2.microsoft.com/en-us/library/ms536429.aspx
        'the return value is usually a string, whereas the
        ' documentation seems to say string or null
        'spec says empty string
        'http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-666EE0F9
        'might be safer to use
        ' format$(curElement.getAttribute etc...
        '------------------------------------------------------------------------
        'Texte64 = "Sourceindex=" & _
        '    curElement.sourceIndex    '& ":" &
        '     WebBrowser.Document.All (curElement.sourceIndex)
        'Texte64 = Texte64 & ":width=" & _
        '    curElement.getAttribute("ID", 0) & _
        '             ":height=" & _
        '                 curElement.getAttribute("title", _
        '                 0)
        'Texte64 = Texte64 & "href=" & _
        '    curElement.getAttribute("numint", 0)
        'lesson for the day
        'curElement.getAttribute("href", 0) on an image is
        ' same as
        'curElement.getAttribute("src", 0)
        'Texte64.Text = Texte64.Text & tMarker(curElement.sourceIndex)
       '
       ' Texte64.Text = Texte64.Text & curElement.innerText
        'Texte64.Text = Texte64.Text & curElement.innerHTML
    'End If
   ' curElement.Style.setAttribute "border", "dashed"
    ' 3px #ff0000"
    '-----------------------------------
    'uncomment to see dashed line box around item and the
    ' border disappear!
    '    curElement.Style.setAttribute "border", "dashed
    ' 1px #ff0000"
    '
    '    Set curElement =
    ' WebBrowser1.document.parentWindow.event.fromElement
    '    If Not (curElement Is Nothing) Then
    '        curElement.Style.setAttribute "border", "none"
    '    End If

    Exit Sub
err:
    'MsgBox err.Description & ":" & err.Number
End Sub

Private Sub WebBrowser_DocumentComplete(ByVal pDisp As Object, _
                                                 URL As Variant)
   'Set HTML = Me.WebBrowser.Document
   
End Sub

Private Function HTML_OnClick() As Boolean
'HTML_OnClick = True
'Dim curElement As MSHTML.IHTMLElement
'Debug.Print Me.WebBrowser.Document.parentWindow.event.srcElement.Document
'If Me.WebBrowser.Document.parentWindow.event.srcElement <> Null Then
'    curElement = Me.WebBrowser.Document.parentWindow.event.srcElement
'    MsgBox (curElement.numint)
'End If
End Function
Private Sub CmdAfficher_Click()
   
Dim bClient As Boolean
Dim bTypeIntervention As Boolean
Dim bNumSit As Boolean
Dim sFiltre As String
Dim bStatut As Boolean
Dim bDonneur As Boolean
Dim bIntervenant As Boolean
Dim bZone As Boolean
Dim bTrimestre As Boolean
Dim bDebut As Boolean
Dim sColor As String
Dim sTypInt As String
Dim i As Integer
Dim comsit As String
Dim comint As String
Dim datintpre As String
Dim nomuti As String
Dim adrsit As String
Dim datdervis As String
Dim codpossit As String
Dim datheulim As String
Dim datheuapp As String

    sColor = ""
    sFiltre = ""
    DoCmd.Hourglass True
    Me.WebBrowser.navigate CurrentProject.Path & "\geo.html"
    DoEvents
    Dim frm As Form, ctl As Control
    Dim varItm As Variant, intI As Integer
    DoEvents
    Set frm = Forms!Carte
    DoEvents
    If cboClient.ItemsSelected.Count > 0 Then
        bClient = True
        sFiltre = sFiltre & "("
        Set ctl = frm!cboClient
        For Each varItm In ctl.ItemsSelected
            sFiltre = sFiltre & "[numcli]=" & ctl.Column(0, varItm) & " OR "
        Next varItm
        sFiltre = Left(sFiltre, Len(sFiltre) - 4)
        sFiltre = sFiltre & ")"
    End If
    DoEvents
    If cboTypeIntervention.ItemsSelected.Count > 0 Then
        If bClient Or bNumSit Then
            sFiltre = sFiltre & " AND "
        End If
        bTypeIntervention = True
        
        sFiltre = sFiltre & "("
        Set ctl = frm!cboTypeIntervention
        For Each varItm In ctl.ItemsSelected
            sFiltre = sFiltre & "[typint]='" & ctl.Column(0, varItm) & "' OR "
        Next varItm
        sFiltre = Left(sFiltre, Len(sFiltre) - 4)
        sFiltre = sFiltre & ")"
    End If
    DoEvents
    
    If cboStatut.ItemsSelected.Count > 0 Then
        If bClient Or bTypeIntervention Or bNumSit Then
            sFiltre = sFiltre & " AND "
        End If
        
        sFiltre = sFiltre & "("
        Set ctl = frm!cboStatut
        For Each varItm In ctl.ItemsSelected
            sFiltre = sFiltre & "[staint]=" & ctl.Column(0, varItm) & " OR "
        Next varItm
        sFiltre = Left(sFiltre, Len(sFiltre) - 4)
        
        If Me.ChkShowArchived = True Then
            sFiltre = sFiltre & " OR [staint] = 7"
        
        End If
        
        sFiltre = sFiltre & ")"
       
        bStatut = True
    End If
    DoEvents
    If txtdebut <> "" And IsDate(txtdebut) Then
        If bClient Or bTypeIntervention Or bNumSit Or bStatut Then
            sFiltre = sFiltre & " AND "
        End If
            sFiltre = sFiltre & " datheulim >= #" & Me.txtdebut & "#"
        bDebut = True
    End If
    DoEvents
    If Texte17 <> "" And IsDate(Texte17) Then
        If bClient Or bTypeIntervention Or bNumSit Or bStatut Or bDebut Then
            sFiltre = sFiltre & " AND "
        End If
            sFiltre = sFiltre & " datheulim <= #" & Me.Texte17 & "#"
        bTrimestre = True
    End If
    DoEvents
    If CboDonneur.Value <> 0 Then
        If bClient Or bTypeIntervention Or bNumSit Or bTrimestre Or bDebut Then
            sFiltre = sFiltre & " AND "
        End If
        sFiltre = sFiltre & "[donneurid]=" & CboDonneur
        bDonneur = True
    End If
    DoEvents
    If CboIntervenant.ItemsSelected.Count > 0 Then
        If bClient Or bTypeIntervention Or bNumSit Or bTrimestre Or bDebut Or bDonneur Then
            sFiltre = sFiltre & " AND "
        End If
        
        sFiltre = sFiltre & "("
        Set ctl = frm!CboIntervenant
        For Each varItm In ctl.ItemsSelected
            sFiltre = sFiltre & "[codint]='" & ctl.Column(0, varItm) & "' OR "
        Next varItm
        sFiltre = Left(sFiltre, Len(sFiltre) - 4)
        
        sFiltre = sFiltre & ")"
        
        bIntervenant = True
    End If
    DoEvents
    If CboZone.ItemsSelected.Count > 0 <> 0 Then
        If bClient Or bTypeIntervention Or bNumSit Or bTrimestre Or bDonneur Or bDebut Or bIntervenant Then
            sFiltre = sFiltre & " AND "
        End If
        
        sFiltre = sFiltre & "("
        Set ctl = frm!CboZone
        For Each varItm In ctl.ItemsSelected
            sFiltre = sFiltre & "[numzonsit]=" & ctl.Column(0, varItm) & " OR "
        Next varItm
        sFiltre = Left(sFiltre, Len(sFiltre) - 4)
        
        sFiltre = sFiltre & ")"
        
        bZone = True
    End If
    If sFiltre = "" Then
        sFiltre = "[longitude] is not null and [latitude] is not null"
    Else
        sFiltre = sFiltre & " AND [longitude] is not null and [latitude] is not null"
    End If
   DoEvents
   
   Dim SQL As String
   
   SQL = "SELECT numintint,latitude,longitude,typint,staint,nomcli,nomsit,datheulim,datheuapp,datintpre,nomuti,adrsit,codpossit,comsit,comint,vilsit,datedernierevisiteentretien as [datdervis] From [ListeInterventionGenerale] left join [Utilisateur] on [ListeInterventionGenerale].numutipre = Utilisateur.numuti WHERE " & sFiltre

   Dim rs As Recordset
   Set rs = CurrentDb.OpenRecordset(SQL, dbOpenForwardOnly)
   
   Do Until rs.EOF
   
    Dim Fiche As String
    Fiche = "" & rs("nomcli") & " - " & Replace(rs("nomsit"), """", "'")
    Select Case rs("typint")
      Case 1
        sColor = "blue"
        Fiche = Fiche & " à faire avant le " & " - " & rs("datheulim")
        sTypInt = "ENTRETIEN"
      Case 2
        Fiche = Fiche & " reçue le " & " - " & rs("datheuapp")
        Fiche = Fiche & " prévue le " & " - " & rs("datintpre")
        sColor = "green"
        sTypInt = "DEPANNAGE"
      Case 3
        sColor = "red"
        sTypInt = "TRAVAUX SELON DEVIS"
      Case 4
        sTypInt = "AUTRE"
      Case 5
        sTypInt = "EN TRAVAUX"
        sColor = "cone"
      Case 7
        sTypInt = "DESENFUMAGE"
        sColor = "yellow"
      Case 9
        sTypInt = "AUDIT"
        sColor = "black"
      Case Else
        sColor = "brown"
    End Select
    If rs("staint") = -1 Then
        sColor = "yellow"
    End If
    
    If IsNull(rs.Fields("nomuti")) Then
        nomuti = ""
    Else
        nomuti = rs("nomuti")
    End If
    If IsNull(rs.Fields("comsit")) Then
        comsit = ""
    Else
        comsit = rs("comsit")
    End If
    If IsNull(rs.Fields("comint")) Then
        comint = ""
    Else
        comint = rs("comint")
    End If
    If IsNull(rs.Fields("datintpre")) Then
        datintpre = ""
    Else
        datintpre = rs("datintpre")
    End If
    
    If IsNull(rs.Fields("adrsit")) Then
        adrsit = ""
    Else
        adrsit = rs("adrsit")
    End If
    
    If IsNull(rs("datdervis")) Then
        datdervis = ""
    Else
        datdervis = rs("datdervis")
    End If
    
    If IsNull(rs("codpossit")) Then
        codpossit = ""
    Else
        codpossit = rs("codpossit")
    End If
    
    If IsNull(rs("datheulim")) Then
        datheulim = ""
    Else
        datheulim = rs("datheulim")
    End If
    
    If IsNull(rs("datheuapp")) Then
        datheuapp = ""
    Else
        datheuapp = rs("datheuapp")
    End If
    
    If rs("datheulim") < Now Then
        displayMarker rs("latitude"), rs("longitude"), sTypInt, adrsit, comsit, comint, "" & rs("codpossit"), "" & rs("vilsit"), datheuapp, datheulim, datintpre, nomuti, Fiche, sColor, datdervis, True
    Else
        displayMarker rs("latitude"), rs("longitude"), sTypInt, adrsit, comsit, comint, rs("codpossit"), rs("vilsit"), datheuapp, datheulim, datintpre, nomuti, Fiche, sColor, datdervis, False
    End If
      rs.MoveNext
   Loop
   Me.WebBrowser.Document.parentWindow.execScript "mymap.addLayer(markers);", csScriptLanguage
   DoCmd.Hourglass False
   
   
End Sub




Private Sub Form_Current()

DoCmd.Maximize

End Sub

 
'------------------------------------------------------
'Form events
'------------------------------------------------------
Private Sub Form_Load()
   DoCmd.Maximize
   Me.Section(acHeader).Visible = True
   Me.WebBrowser.navigate CurrentProject.Path & "\geo.html"
   
End Sub
 

Private Sub Form_MouseUp(Button As Integer, Shift As Integer, x As Single, Y As Single)
DoCmd.Maximize
End Sub

'Adjust webcontrol size and form minimum size
Private Sub Form_Resize()
   Const clMinHeight As Long = 1200
   
   If Me.InsideHeight - Me.Section(acHeader).Height < clMinHeight Then
      Me.InsideHeight = Me.Section(acHeader).Height + clMinHeight
   End If
   Me.WebBrowser.Height = Me.InsideHeight - Me.Section(acHeader).Height
   
   If Me.InsideWidth < Me.Rect1.Left * 2 + Me.Rect1.Width Then
      Me.InsideWidth = Me.Rect1.Left * 2 + Me.Rect1.Width
   End If
   Me.WebBrowser.Width = Me.InsideWidth
End Sub

'Work around a webcontrol error (StatusTextChange event)
Private Sub Form_Error(DataErr As Integer, Response As Integer)
   If DataErr = 2473 Then Response = acDataErrContinue
End Sub


Private Sub btnClearMarker_Click()
   clearMap
   'If Me.txtStatus & "" = "OK" Then Me.btnAddMarker.Enabled = True
End Sub

Private Sub displayMarker(ByVal sLatitude As String, ByVal sLongitude As String, ByVal sTypInt As String, ByVal sAdrSit As String, ByVal sComSit As String, ByVal sComInt As String, ByVal sCodPosSit As String, ByVal sVilSit As String, ByVal sDatHeuApp As String, ByVal sDatHeuLim As String, ByVal sDatIntPre As String, ByVal sNomUti As String, ByVal sText As String, ByVal sColor As String, ByVal sDatDerVis As String, ByVal bDepassement As Boolean)
   Dim sScript As String
   Dim sTooltip As String
   
   sTooltip = ""
   
   sTooltip = sTooltip & "<b></b>" & sTypInt & "<br/><hr/>"
   sTooltip = sTooltip & "<b>" & Replace(Replace(sText, Chr(13), "<br/>"), Chr(10), "<br/>") & "</b><br/>"
   sTooltip = sTooltip & "" & Replace(Replace(sAdrSit, Chr(13), "<br/>"), Chr(10), "<br/>") & "<br/>"
   sTooltip = sTooltip & "" & sCodPosSit & " " & sVilSit & "<br/><hr/>"
   sTooltip = sTooltip & "Date demande: <b>" & sDatHeuApp & "</b><br/>"
   sTooltip = sTooltip & "Date limite : <b>" & sDatHeuLim & "</b><br/>"
   sTooltip = sTooltip & "Dernière visite d'entretien le : " & sDatDerVis & "<br/><hr/>"
   sTooltip = sTooltip & "Technicien prévu : " & sNomUti & "<br/>"
   sTooltip = sTooltip & "Date prévue : " & sDatIntPre & "<br/><hr/>"
   sTooltip = sTooltip & "<b>Commentaire général Site</b><br/>"
   sTooltip = sTooltip & Replace(Replace(sComSit, Chr(13), "<br/>"), Chr(10), "<br/>") & "<br/><hr/>"
   sTooltip = sTooltip & "<b>Commentaire Intervention</b><br/>"
   sTooltip = sTooltip & Replace(Replace(sComInt, Chr(13), "<br/>"), Chr(10), "<br/>") & "<br/>"
   
    If sTypInt = "Désenfumage" Then sColor = "grey"
    If sTypInt = "AUDIT" Then sColor = "black"
   'RMA - Leaflet
   'sScript = "L.marker([" & CoordToStr(sLatitude) & "," & CoordToStr(sLongitude) & "]).addTo(mymap).bindPopup(" & """" & PrepareTextToMap(sText) & """" & ");"
   If bDepassement Then
    sScript = "var marker=L.marker([" & CoordToStr(sLatitude) & "," & CoordToStr(sLongitude) & "],{icon: " & sColor & "Icon}).addTo(mymap).bindPopup(" & """" & PrepareTextToMap(sTooltip) & """" & ");"
    sScript = sScript & "L.circle([" & CoordToStr(sLatitude) & "," & CoordToStr(sLongitude) & "], 500,{ color: 'orange',opacity:1,fillColor:'orange',fillOpacity:.1 }).addTo(mymap);"
   Else
    sScript = "var marker=L.marker([" & CoordToStr(sLatitude) & "," & CoordToStr(sLongitude) & "],{icon: " & sColor & "Icon}).addTo(mymap).bindPopup(" & """" & PrepareTextToMap(sTooltip) & """" & ");"
   End If
   sScript = sScript & "markers.addLayer(marker);"
   'sScript = "markers.addLayer(L.marker"
   Me.WebBrowser.Document.parentWindow.execScript sScript, csScriptLanguage
End Sub

'Clear markers on the map
Private Sub clearMap()
   'Me.WebBrowser.Document.parentWindow.execScript "oMap.clearMarkers()", csScriptLanguage
End Sub

'adjust the viewport
Private Sub setViewPort()
   'Me.WebBrowser.Document.parentWindow.execScript "oMap.adjustViewPort()", csScriptLanguage
End Sub

'------------------------------------------------------
'Others functions
'------------------------------------------------------
'Waiting for the good Readystate of the webcontrol
Private Function IsWebBrowserReady() As Boolean
   Const cfWait As Single = 0.5   'second
   Const cfMax As Single = 5    'seconds
   Dim ftMax As Single, ft As Single

   With Me.WebBrowser
      ftMax = Timer + cfMax
      Do While .ReadyState < 4 And Timer < ftMax
         ft = Timer + cfWait
         While Timer <= ft: DoEvents: Wend
      Loop
      IsWebBrowserReady = (.ReadyState = 4)
   End With
End Function



'Convert coordinates to str
Private Function CoordToStr(ByVal dValue As Double) As String
   CoordToStr = Replace(Format(dValue, "0.0#####"), ",", ".")
End Function

'Prepare text for the marker on map
Private Function PrepareTextToMap(ByVal sTxt As String) As String
   sTxt = Replace(sTxt, "\", "\\")
   sTxt = Replace(sTxt, "'", "\'")
   sTxt = Replace(sTxt, """", "\""")
   sTxt = Replace(sTxt, vbCrLf, "")
   PrepareTextToMap = sTxt
End Function

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
Private Sub SaveHTML()
On Error GoTo Err_SaveHTML
    Dim HTML
    Dim pageElement
    Dim sHTML As String
    Set HTML = Me.WebBrowser.Object.Document
    For Each pageElement In HTML.all
        
        sHTML = sHTML & pageElement.outerHTML
        If InStr(sHTML, "</HTML>") > 0 Then
            Exit For
        End If
        'Debug.Print (pageElement.outerHTML)
     Next
    
    'sHTML = Me.WebBrowser.Document.parentWindow.execScript("v = function(){return document.documentElement.innerHTML;};v()"
    Dim intFic As Integer
    sHTML = Replace(sHTML, "isLoaded=""true""", "isLoaded=""false""")
    intFic = FreeFile
    Open Application.CurrentProject.Path & "\cartefmc.html" For Output As intFic
    Print #intFic, sHTML
    Close intFic
Exit_SaveHTML_Click:
    Exit Sub

Err_SaveHTML:
    MsgBox err.Description
    Resume Exit_SaveHTML_Click
End Sub
Private Sub CmdHideDisplay_Click()
On Error GoTo Err_CmdHideDisplay_Click
    'MsgBox (Me.WebBrowser.Top)
    DoCmd.SetWarnings False
    If Me.WebBrowser.Top = 0 Then
        Me.WebBrowser.Top = 3968
        Me.WebBrowser.Height = Me.InsideHeight - Me.Section(acFooter).Height - 3968
    Else
        Me.WebBrowser.Top = 0
        Me.WebBrowser.Height = Me.InsideHeight - Me.Section(acFooter).Height
    End If
    
    setViewPort
    
    DoCmd.SetWarnings True
   
   
Exit_CmdHideDisplay_Click:
    Exit Sub

Err_CmdHideDisplay_Click:
    MsgBox err.Description
    Resume Exit_CmdHideDisplay_Click
    
End Sub

Private Sub Form_Timer()
    CmdAfficher_Click
End Sub
Private Sub CmdResetMap_Click()
On Error GoTo Err_CmdResetMap_Click

    clearMap

Exit_CmdResetMap_Click:
    Exit Sub

Err_CmdResetMap_Click:
    MsgBox err.Description
    Resume Exit_CmdResetMap_Click
    
End Sub
