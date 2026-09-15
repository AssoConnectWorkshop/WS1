Attribute VB_Name = "Report_Copie de FicheIntervention"
Attribute VB_Base = "0{1BDCC8FF-A50D-4DD0-B08B-7D29A19F232D}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Détail_Format(Cancel As Integer, FormatCount As Integer)
    
 Select Case Me![typint]
        Case 1
            typint1 = True
        Case 2
            typint2 = True
        Case 3
            typint3 = True
    End Select
    
 Select Case Me![codpan]
        Case "01"
            pan1 = True
        Case "02"
            pan2 = True
        Case "03"
            pan3 = True
        Case "04"
            pan4 = True
        Case "05"
            pan5 = True
        Case "06"
            pan6 = True
        Case "07"
            pan7 = True
        Case "08"
            pan8 = True
        Case "09"
            pan9 = True
        Case "10"
            pan10 = True
        Case "11"
            pan11 = True
        Case "12"
            pan12 = True
        Case "13"
            pan13 = True
        Case "14"
            pan14 = True
    End Select
    
End Sub

Private Sub Report_Load()

    typint1 = False
    typint2 = False
    typint3 = False
    
    pan1 = False
    pan2 = False
    pan3 = False
    pan4 = False
    pan5 = False
    pan6 = False
    pan7 = False
    pan8 = False
    pan9 = False
    pan10 = False
    pan11 = False
    pan12 = False
    pan13 = False
    pan14 = False
    
    entcli = False
    entrac = False
    entext = False
    
    'regsecoui = False
    regsecnon = False
    
    chkDevisAFaire = False
    chknouvelleintervention = False
    
    reparationdefinitive = False
    reparationprovisoire = False
    pasrepare = False
    pasreparable = False
    

End Sub

