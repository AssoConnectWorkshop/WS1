Attribute VB_Name = "Form_Map"
Attribute VB_Base = "0{6111D1C8-CECA-4989-AB41-DCD45F0401AE}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database
Option Explicit

Private Const csScriptLanguage As String = "JavaScript"

Private Sub CmdAfficher_Click()
   
   'Call GeocodeClient
    
   Dim rs As Recordset
   Set rs = CurrentDb.OpenRecordset("SELECT nomcli, nomsit, longitude, latitude from site inner join client on client.numcli = site.numcli where longitude is not null and latitude is not null and client.numcli=" & Me.numcli, dbOpenForwardOnly)
   Do Until rs.EOF
   
      displayMarker rs("latitude"), rs("longitude"), rs("nomcli") & " - " & rs("nomsit"), "blue"
      
      rs.MoveNext
   Loop
   setViewPort
   
  
End Sub

Public Sub GeocodeClient()
    Dim tGeo As tGeocodeResult
   Dim rs As Recordset
   Dim lg As Double
   Dim lt As Double
   'Close Recordset Fait
   Set rs = CurrentDb.OpenRecordset("SELECT cptsit,nomsit,adrsit,codpossit,vilsit from site where longitude is null and numcli in (432) ", dbOpenForwardOnly) 'inner join client on client.numcli = site.numcli where client.numcli=" & Me.numcli, dbOpenForwardOnly)
   Do Until rs.EOF
      
   tGeo = Geocode(PrepareAddress(rs("adrsit")), PrepareAddress(rs("vilsit")), PrepareAddress(rs("codpossit")), "", PrepareAddress("France"))
   'Display results
   With tGeo
   
      If tGeo.sStatus <> "OK" Then
           tGeo = Geocode("", PrepareAddress(rs("vilsit")), "", "", "France")
      End If
      lt = .dLatitude
      lg = .dLongitude
      'Me.txtLatitude = .dLatitude
      'Me.txtLongitude = .dLongitude
      'Me.txtAccuracy = .sAccuracy
      'Me.txtStatus = .sStatus
      Dim SQL As String
      SQL = "update site set longitude=" & Replace(lg, ",", ".") & ", latitude=" & Replace(lt, ",", ".") & " where cptsit=" & rs("cptsit")
      Debug.Print "--" & rs("nomsit")
      Debug.Print SQL
      CurrentDb.Execute SQL, dbSeeChanges
      Delay (0.2)
      End With
      rs.MoveNext
   Loop
   rs.Close
End Sub

Public Function Delay(dblInterval As Double)
'----------------------------------------------------
' Name: Delay
' Purpose: Generic delay code
' Inputs: dblInterval As Double
' Author: Arvin Meyer
' Date: January 2, 1999
' Comment:
'----------------------------------------------------
On Error GoTo Err_Delay
Dim Timer1 As Double
Dim Timer2 As Double

Timer1 = Timer()
Do Until Timer2 >= Timer1 + dblInterval
DoEvents
Timer2 = Timer()
Loop

Exit_Delay:
Exit Function

Err_Delay:
Select Case err

Case Else
MsgBox err.Description
Resume Exit_Delay
End Select

End Function


Private Sub CmdGeocoderTout_Click()
   Call GeocodeClient
End Sub

'------------------------------------------------------
'Form events
'------------------------------------------------------
Private Sub Form_Load()
   'Initial address
   'Me.txtAddress = "505 North Michigan Avenue"
   'Me.txtCity = "Chicago"
   'Me.txtZipCode = "60611"
   'Me.txtRegion = "IL"
   'Me.txtCountry = "USA"

   Me.btnAddMarker.Enabled = False
   Me.WebBrowser.navigate CurrentProject.Path & "\geocoding.html"
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

Private Sub btnGeocode_Click()
   On Error GoTo catch
   Dim tGeo As tGeocodeResult

   ClearGeocodingResults
   Me.Repaint
   
   'Start geocoding
   tGeo = Geocode(PrepareAddress(Me.txtAddress), PrepareAddress(Me.txtCity), _
                  PrepareAddress(Me.txtZipCode), PrepareAddress(Me.txtRegion), _
                  PrepareAddress(Me.txtCountry))
   'Display results
   With tGeo
   
      If tGeo.sStatus <> "OK" Then
           tGeo = Geocode("", PrepareAddress(Me.txtCity), _
                  "", PrepareAddress(Me.txtRegion), _
                  PrepareAddress(Me.txtCountry))
      End If
      
      Me.txtRetAddress = .sRetAddress
      Me.txtLatitude = .dLatitude
      Me.txtLongitude = .dLongitude
      Me.txtAccuracy = .sAccuracy
      Me.txtStatus = .sStatus
    
      If .sStatus = "OK" Then
         Me.btnAddMarker.Enabled = True
         Me.btnAddMarker.SetFocus
      End If
   End With

finally:
   Exit Sub
catch:
   MsgBox "Error number:" & err.Number & vbCrLf & "Description:" & err.Description, _
          vbExclamation, "An error occurs during the geocoding..."
   Resume finally
End Sub

'Display a marker on the map and adjust the viewport
Private Sub btnAddMarker_Click()
   If Not (IsNull(Me.txtLatitude) Or IsNull(Me.txtLongitude)) Then
      displayMarker Me.txtLatitude, Me.txtLongitude, Me.txtRetAddress, "blue"
      setViewPort

      Me.btnClearMarker.SetFocus
      Me.btnAddMarker.Enabled = False
   End If
End Sub

Private Sub btnClearAddress_Click()
   ClearAddress
   ClearGeocodingResults
End Sub

Private Sub btnClearMarker_Click()
   clearMap
   If Me.txtStatus & "" = "OK" Then Me.btnAddMarker.Enabled = True
End Sub

'------------------------------------------------------
'Interactions with the map
'------------------------------------------------------
'Display a marker on the map
Private Sub displayMarker(ByVal sLatitude As String, ByVal sLongitude As String, ByVal sText As String, ByVal sColor As String)
   Dim sScript As String
   sScript = "oMap.addMarker(" & CoordToStr(sLatitude) & "," & CoordToStr(sLongitude) & _
             "," & PrepareTextToMap(sText) & "," & PrepareTextToMap(sColor) & ");"
   Me.WebBrowser.Document.parentWindow.execScript sScript, csScriptLanguage
End Sub

'Clear markers on the map
Private Sub clearMap()
   Me.WebBrowser.Document.parentWindow.execScript "oMap.clearMarkers()", csScriptLanguage
End Sub

'adjust the viewport
Private Sub setViewPort()
   Me.WebBrowser.Document.parentWindow.execScript "oMap.adjustViewPort()", csScriptLanguage
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

Private Sub ClearGeocodingResults()
   Me.txtRetAddress = ""
   Me.txtLatitude = ""
   Me.txtLongitude = ""
   Me.txtAccuracy = ""
   Me.txtStatus = ""
   
   Me.btnAddMarker.Enabled = False
End Sub

Private Sub ClearAddress()
   Me.txtAddress = ""
   Me.txtCity = ""
   Me.txtZipCode = ""
   Me.txtRegion = ""
   Me.txtCountry = ""
End Sub

'Convert coordinates to str
Private Function CoordToStr(ByVal dValue As Double) As String
   CoordToStr = Replace(Format(dValue, "0.0#####"), ",", ".")
End Function

'Prepare text for the marker on map
Private Function PrepareTextToMap(ByVal sTxt As String) As String
   sTxt = Replace(sTxt, "\", "\\")
   sTxt = Replace(sTxt, "'", "\'")
   sTxt = Replace(sTxt, """", "\""")
   PrepareTextToMap = sTxt
End Function

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
Private Sub CmdPrevious_Click()
On Error GoTo Err_CmdPrevious_Click


    DoCmd.GoToRecord , , acPrevious

Exit_CmdPrevious_Click:
    Exit Sub

Err_CmdPrevious_Click:
    MsgBox err.Description
    Resume Exit_CmdPrevious_Click
    
End Sub
Private Sub CmdNext_Click()
On Error GoTo Err_CmdNext_Click


    DoCmd.GoToRecord , , acNext

Exit_CmdNext_Click:
    Exit Sub

Err_CmdNext_Click:
    MsgBox err.Description
    Resume Exit_CmdNext_Click
    
End Sub
Private Sub Commande40_Click()
On Error GoTo Err_Commande40_Click


    DoCmd.RunCommand acCmdRefresh

Exit_Commande40_Click:
    Exit Sub

Err_Commande40_Click:
    MsgBox err.Description
    Resume Exit_Commande40_Click
    
End Sub
