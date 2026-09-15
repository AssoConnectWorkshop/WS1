Attribute VB_Name = "Form_Devis"
Attribute VB_Base = "0{D8F7FDA4-BC94-4506-A865-4E6CBC8A059F}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Dim strFileName As String
Dim strBaseFileName As String
 

Private Sub NomFichierDevis_AfterUpdate()
    strBaseFileName = Me!NomFichierDevis
    If Me!NomFichierDevis <> "" Then
        strFileName = Right$(strBaseFileName, Len(strBaseFileName) - InStrRev(strBaseFileName, "\"))
        
        Me!NomFichierDevis = strFileName & strBaseFileName
        Me!NumeroDevis = Mid(strFileName, 11, 5)
    End If
End Sub

Private Sub NomFichierDevis_BeforeUpdate(Cancel As Integer)
   ' If IsNull(Me.DateEnvoiDevis) Then
   '     Me.DateEnvoiDevis = Date
   ' End If
    

End Sub

