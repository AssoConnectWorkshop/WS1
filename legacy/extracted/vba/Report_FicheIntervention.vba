Attribute VB_Name = "Report_FicheIntervention"
Attribute VB_Base = "0{C0596DAC-5F91-4CFC-B040-073F8E01A4B5}"
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
    If Left(Me.OpenArgs, 1) = "O" Then
        txtheuarrint.Visible = False
        txtheudepint.Visible = False
        txttpsallint.Visible = False
        txttpsretint.Visible = False
        txttpstrajet.Visible = False
        txtdurint.Visible = False
    End If
End Sub

Public Function ChercherDonneurOrdre() As String
Dim nomdonneur As String
Dim CptNomDonneur As Integer
Dim Site As Recordset
Dim Donneur As Recordset
On Error GoTo Erreur:

Requete = "Select nomdonneur,meldonneur,cheminpho,cheminpla from donneur where donneurid=" + Str(Me.Texte544)
Set db = CurrentDb
Set Donneur = db.OpenRecordset(Requete, dbOpenSnapshot)
nomdonneur = Donneur!nomdonneur
If IsNull(nomdonneur) Then
   nomdonneur = "FMC"
End If
Me.Étiquette146.Visible = True
Me.Étiquette147.Visible = True
Me.Étiquette148.Visible = True

If nomdonneur <> "FMC" Then
    If IsNull(Donneur!meldonneur) Then
        Me.Étiquette146.Visible = False
    Else
        Me.Étiquette146.Caption = Donneur!meldonneur
        Me.Étiquette147.FontUnderline = False
    End If
    If IsNull(Donneur!cheminpho) Then
        Me.Étiquette147.Visible = False
    Else
        Me.Étiquette147.Caption = Donneur!cheminpho
        Me.Étiquette147.FontUnderline = False
    End If
    If IsNull(Donneur!cheminpla) Then
        Me.Étiquette148.Visible = False
    Else
        Me.Étiquette148.Caption = Donneur!cheminpla
        Me.Étiquette147.FontUnderline = False
    End If
End If

If Not Donneur Is Nothing Then
    If Donneur.RecordCount >= 0 <> 0 Then Donneur.Close
    Set Donneur = Nothing
End If
ChercherDonneurOrdre = nomdonneur
Exit Function

Erreur:
If Not Donneur Is Nothing Then
    If Donneur.RecordCount >= 0 Then Donneur.Close
    Set Donneur = Nothing
End If

ChercherDonneurOrdre = "FMC"

End Function

Private Sub Report_Load()
    
    
    NomdDonneur = ChercherDonneurOrdre()
    
    Dim Nom_Icone, New_Open_Args, OpenArgs As String
    
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
    If majregsec.Value = True Then
        regsecnon = False
    Else
        regsecnon = True
    End If
    
    chkDevisAFaire = False
    chknouvelleintervention = False
    
    reparationdefinitive = False
    reparationprovisoire = False
    pasrepare = False
    pasreparable = False
   
    'Si l'icone n'existe pas on est dans le cas general
    If (NomdDonneur <> "FMC") Then
        Nom_Icone = "\\Serveur\commun\Commercial\A0- Clim Access\Logo ST\" + NomdDonneur + ".jpg"
        'Nom_Icone = "C:\Users\FERSOFT\Desktop\Sauve BDD FMC\Logo ST\" + NomdDonneur + ".jpg"
        If (FileExists(Nom_Icone)) Then
            Me.Image5.Picture = Nom_Icone
        Else
            'Pas d'icone donc on affiche les conditions de FMC
            Me.Étiquette146.Visible = True
            Me.Étiquette147.Visible = True
            Me.Étiquette148.Visible = True
        End If
    End If
        
 
   

End Sub
Public Function FileExists(ByVal path_ As String) As Boolean
        On Error GoTo err
    FileExists = (Len(Dir(path_)) > 0)
    Exit Function
err:
    FileExists = False
End Function
