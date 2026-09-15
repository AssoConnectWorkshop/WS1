Attribute VB_Name = "Form_ListeInterventionAttente"
Attribute VB_Base = "0{C4A2B2E9-7525-4DB0-8538-2D958E00EEC3}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub CmdOuvrirDetail_Click()
On Error GoTo Err_numsit_DblClick
    Dim stDocName As String
    Dim stLinkCriteria As String

    If Me!numsit <> "" Then
        stDocName = "Intervention"
        stLinkCriteria = "numintint=" & Me!numintint
        
        DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "IDA"
    End If
Exit_numsit_DblClick:
    Exit Sub

Err_numsit_DblClick:
    MsgBox err.Description
    Resume Exit_numsit_DblClick
    
End Sub

Private Sub Form_Load()
    Select Case Me.OpenArgs
        Case "H+8"
            Me.titre.Caption = "Liste des interventions de dépannage en cours (H+8)"
        Case "Facturable"
            Me.titre.Caption = "Liste des interventions de dépannage en cours (facturable)"
            Me.TxtHeuLim.ControlSource = ""
            Me.TxtHeuLim.Visible = False
            Me.LblHeuLim.Visible = False
    End Select
End Sub
