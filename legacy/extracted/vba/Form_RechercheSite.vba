Attribute VB_Name = "Form_RechercheSite"
Attribute VB_Base = "0{99380D20-BC9E-4C9B-881B-1ABBF5FBA4FA}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub CmdRechercher_Click()
On Error GoTo Err_CmdRechercher_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Site"
    stLinkCriteria = ""
    
    If Me![nomsit] <> "" Then
        stLinkCriteria = "[nomsit] like '*" & Me![nomsit] & "*'"
    End If
    If Me![numsit] <> "" Then
        If stLinkCriteria <> "" Then
            stLinkCriteria = stLinkCriteria & "and [numsit] = " & Me![numsit] & ""
        Else
            stLinkCriteria = "[numsit] =" & Me![numsit] & ""
        End If
    End If
    If Me![vilsit] <> "" Then
        If stLinkCriteria <> "" Then
            stLinkCriteria = stLinkCriteria & "and [vilsit] like '*" & Me![vilsit] & "*'"
        Else
            stLinkCriteria = "[vilsit] like '*" & Me![vilsit] & "*'"
        End If
    End If
    If Me![depsit] <> "" Then
        If stLinkCriteria <> "" Then
            stLinkCriteria = stLinkCriteria & "and [codpossit] like '" & Me![depsit] & "*'"
        Else
            stLinkCriteria = "[codpossit] like '" & Me![depsit] & "*'"
        End If
    End If
   
    ' Avec le critère de la mise à jour du registre
    ' If Me.Cadre12 = 1 Then
        ' If stLinkCriteria <> "" Then
            ' stLinkCriteria = stLinkCriteria & " and [misajoursecurite] = 1"
        ' Else
            ' stLinkCriteria = "[misajoursecurite] = 1"
        ' End If
    ' ElseIf Me.Cadre12 = 2 Then
        ' If stLinkCriteria <> "" Then
            ' stLinkCriteria = stLinkCriteria & " and [misajoursecurite] = 0"
        ' Else
            ' stLinkCriteria = "[misajoursecurite] = 0"
        ' End If
    ' End If
    If Form_MenuPrincipal.LstClient <> "" Then
        If stLinkCriteria <> "" Then
            stLinkCriteria = stLinkCriteria & " and [numcli] = " & Form_MenuPrincipal.LstClient & ""
        Else
            stLinkCriteria = "[numcli] = " & Form_MenuPrincipal.LstClient & ""
        End If
    End If
    
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_CmdRechercher_Click:
    Exit Sub

Err_CmdRechercher_Click:
    MsgBox err.Description
    Resume Exit_CmdRechercher_Click
    
End Sub

