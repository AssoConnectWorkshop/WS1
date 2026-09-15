Attribute VB_Name = "Form_Donneur"
Attribute VB_Base = "0{27BA3474-DA9E-4BA9-91A6-EF77A7045845}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database


Public Sub DisplayImage(ctlImageControl As Control, strImagePath As Variant)
On Error GoTo Err_DisplayImage

Dim strResult As String
Dim strDatabasePath As String
Dim intSlashLocation As Integer

With ctlImageControl
    If IsNull(strImagePath) Then
        .Visible = False
        strResult = "Pas d'image définie."
    Else
        If InStr(1, strImagePath, "\") = 0 Then
            ' Path is relative
            strDatabasePath = CurrentProject.FullName
            intSlashLocation = InStrRev(strDatabasePath, "\", Len(strDatabasePath))
            strDatabasePath = Left(strDatabasePath, intSlashLocation)
            strImagePath = strDatabasePath & strImagePath
        End If
        .Visible = True
        strImagePath = Left(strImagePath, InStr(strImagePath, "#") - 1)
        .Picture = strImagePath
        strResult = "Image trouvée et affichée"
    End If
End With
    
Exit_DisplayImage:
    Exit Sub

Err_DisplayImage:
    Select Case err.Number
        Case 2220       ' Can't find the picture.
            ctlImageControl.Visible = False
            strResult = "Image non trouvée avec le nom défini."
            Resume Exit_DisplayImage:
        Case Else       ' Some other error.
            MsgBox err.Number & " " & err.Description
            strResult = "Une erreur s'est produite lors de l'affichage du logo."
            Resume Exit_DisplayImage:
    End Select
End Sub

Private Sub CallDisplayImage()
    Call DisplayImage(Me!ImageFrame, Me!cheminpho)
End Sub

Private Sub cheminpho_AfterUpdate()
CallDisplayImage
End Sub

Private Sub Form_AfterUpdate()
CallDisplayImage
End Sub

Private Sub Form_Current()
CallDisplayImage
End Sub

Private Sub lstClient_AfterUpdate()
    ' Find the record that matches the control.
    'Dim rs As Object
    'Dim strSQL As String
    'Dim dbs As DAO.Database
    'Dim rsSQL As DAO.Recordset
        
    ' Si le champ de recherche ne contient que des chiffres faire la recherche sur le N° de site
    'Set rs = Me.Recordset.Clone
    'If (IsNumeric(Me!LstClient)) Then
    '    Dim sql As String
    '    strSQL = "SELECT Site.numcli FROM Site Where Site.numsit=" & Me.LstClient
    
        
    '    Set dbs = CurrentDb

    '    Set rsSQL = dbs.OpenRecordset(strSQL, dbOpenSnapshot)
    '    If Not rsSQL.EOF Then
    '        rs.FindFirst "[numcli] = " & rsSQL("numcli")
    '        If Not rs.EOF Then Me.Bookmark = rs.Bookmark
    '        Me.Site_sous_formulaire_Client.Form.Filter = "[numsit]=" & Me.LstClient
    '        Me.Site_sous_formulaire_Client.Form.FilterOn = True
            
    '    End If
    'Else
    '    strSQL = "SELECT client.numcli FROM client Where client.nomcli like '%" & Me.LstClient & "%'"
        
        
    '    Set dbs = CurrentDb

    '    Set rsSQL = dbs.OpenRecordset(strSQL, dbOpenSnapshot)
    '    If Not rsSQL.EOF Then
    '        rs.FindFirst "[numcli] = " & rsSQL("numcli")
    '        If Not rs.EOF Then Me.Bookmark = rs.Bookmark
    '        Me.Site_sous_formulaire_Client.Form.FilterOn = False
    '    End If
            
    'End If
    
    
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


Private Sub cmdAddCustomer_Click()
On Error GoTo Err_cmdAddCustomer_Click


    DoCmd.GoToRecord , , acNewRec

Exit_cmdAddCustomer_Click:
    Exit Sub

Err_cmdAddCustomer_Click:
    MsgBox err.Description
    Resume Exit_cmdAddCustomer_Click
    
End Sub
Private Sub cmdPlanIntervention_Click()
On Error GoTo Err_cmdPlanIntervention_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Planification"
    
    stLinkCriteria = "[numcli]=" & Me![numcli]
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_cmdPlanIntervention_Click:
    Exit Sub

Err_cmdPlanIntervention_Click:
    MsgBox err.Description
    Resume Exit_cmdPlanIntervention_Click
    
End Sub
Private Sub CmdMap_Click()
On Error GoTo Err_CmdMap_Click

 'NOTE: see this link for Google Map parms>> http://mapki.com/index.php?title=Google_Map_Parameters
     
     Dim tmpstr As String
     Dim tmpstr2 As String
     Dim shellcmd As String
     
     tmpstr = "http://maps.google.com/maps?q="
     tmpstr2 = Replace(Replace(Trim(Me.adrdonneur), "  ", " "), " ", "+")
     tmpstr = tmpstr & tmpstr2 & ",+" & Replace(Trim(Me.codposdonneur), " ", "+") & ",+" & Replace(Trim(Me.vildonneur), " ", "+")
     tmpstr = tmpstr & "&t=m&hl=fr"    ' m = map parameter, k = hybrid parameter
     shellcmd = "C:\Program Files\Internet Explorer\iexplore.exe " & tmpstr
     
     Shell shellcmd, vbNormalFocus
     


Exit_CmdMap_Click:
    Exit Sub

Err_CmdMap_Click:
    MsgBox err.Description
    Resume Exit_CmdMap_Click
    
End Sub
Private Sub CmdAddSite_Click()
On Error GoTo Err_CmdAddSite_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Site"
    DoCmd.OpenForm stDocName, , , stLinkCriteria, acFormAdd, , Me.numcli
Exit_CmdAddSite_Click:
    Exit Sub

Err_CmdAddSite_Click:
    MsgBox err.Description
    Resume Exit_CmdAddSite_Click
    
End Sub
