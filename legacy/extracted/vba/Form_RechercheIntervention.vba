Attribute VB_Name = "Form_RechercheIntervention"
Attribute VB_Base = "0{32A54F7E-E6A5-413E-96D0-1534AA912F39}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub CmdRechercher_Click()

    On Error GoTo TraitErrRech
    
    Dim rs As Recordset
    
    If Me.TxtRefCli <> "" Then
    
        Dim lSQl As String
        lSQl = "Select numintint, typint, staint from intervention where refcliint like '*" & Me.TxtRefCli & "*'"
        'Close Recordset Fait
        Set rs = CurrentDb.OpenRecordset(lSQl, dbOpenDynaset, dbSeeChanges)
        If rs.EOF Then
            MsgBox "Il n'y a pas d'intervention contenant cette référence client.", vbInformation, "Fin de la recherche"
            rs.Close
            Exit Sub
        Else
            If rs("typint") = 1 And rs("staint") = 1 Then
                arg = "IEP"
            End If
            If rs("typint") = 1 And rs("staint") = 2 Then
                arg = "IEC"
            End If
            
            
            If (rs("typint") = 2 Or rs("typint") = 3) And rs("staint") = 1 Then
                arg = "IDE"
            End If
            If (rs("typint") = 2 Or rs("typint") = 3) And rs("staint") = 2 Then
                arg = "IDC"
            End If
            
            If (rs("typint") = 4) And rs("staint") = 1 Then
                arg = "IDCE"
            End If
            If (rs("typint") = 4) And rs("staint") = 2 Then
                arg = "IDCC"
            End If
            
        End If
        DoCmd.OpenForm "Intervention", acNormal, , "numintint=" & rs("numintint"), , , arg
        rs.Close
    End If
    Exit Sub
TraitErrRech:
    Exit Sub

End Sub
