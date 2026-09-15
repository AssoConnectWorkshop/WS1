Attribute VB_Name = "Form_ChoixSociete"
Attribute VB_Base = "0{9D84B999-8E32-4D0A-8B36-506B0EBF7118}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub cmdValider_Click()
    On Error GoTo Err_cmdValider_Click

    Dim stDocName As String
    Dim lCritere As String
    Dim lArg As String

    lArg = Me.OpenArgs

    stLinkCriteria = "numintint=" & Left(Me.OpenArgs, InStr(Me.OpenArgs, ";") - 1)
    stDocName = Mid(Me.OpenArgs, InStr(Me.OpenArgs, ";") + 1)
    
    DoCmd.OpenReport stDocName, acPreview, , stLinkCriteria
    
Exit_cmdValider_Click:
    Exit Sub

Err_cmdValider_Click:
    MsgBox err.Description
    Resume Exit_cmdValider_Click
End Sub
