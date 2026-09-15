Attribute VB_Name = "Report_Test Cerfa"
Attribute VB_Base = "0{0DEF48F2-A33C-42C4-8F54-66A775371428}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database




Private Sub Report_Load()

Dim NumInter As Long

If Me.OpenArgs <> "" Then
    NomInter = Me.OpenArgs
    Pos = InStr(1, Me.OpenArgs, "-", vbTextCompare)
    NumInter = Left(Me.OpenArgs, Pos - 1)
    NumMateriel = Right(Me.OpenArgs, Len(Me.OpenArgs) - Pos)
End If
    

On Error GoTo Erreur:

Requete = "Select * from intervention where numintint=" + Str(NumInter)
Set db = CurrentDb
Set DataIntervention = db.OpenRecordset(Requete, dbOpenSnapshot)
Requete = "select * from Site where cptsit=" + Str(DataIntervention!cptsit)
Set DatasSite = db.OpenRecordset(Requete, dbOpenSnapshot)
Requete = "select * from SiteMateriel where Numerositemateriel=" + Str(NumMateriel)
Set DatasMateriel = db.OpenRecordset(Requete, dbOpenSnapshot)
Requete = "select * from TypeFluide where Libelle='" + DatasMateriel!FluideQuantite + "'"
Set DatasFluide = db.OpenRecordset(Requete, dbOpenSnapshot)
Requete = "select * from dbo_Liste_Type_Gaz where id=" + Str(DatasFluide!Type)
Set DatasGaz = db.OpenRecordset(Requete, dbOpenSnapshot)
DatasFluide.MoveLast


'Controle des Datas fluide car si /ok ca sert à rien d'aller plus loin
Ligne = 0
If (Trim(DatasGaz!libelle) = "HCFC") Then
    Ligne = 1
Else
    If (Trim(DatasGaz!libelle) = "HFC") Then
        Ligne = 2
    Else
        If (Trim(DatasGaz!libelle) = "HF0") Then
            Ligne = 3
        End If
    End If
End If

Me.Texte25.Caption = DatasSite!nomsit
Me.Texte27.Caption = DatasSite!adrsit
Me.Texte31.Caption = DatasSite!codpossit + " " + DatasSite!vilsit
Me.Texte656.Caption = NomInter

If (IsNull(DatasMateriel!Emplacement) = False) Then
    Me.Texte844.Caption = DatasMateriel!Emplacement
Else
    Me.Texte844.Caption = ""
End If
Me.Texte845.Caption = DatasMateriel!Marque + " / " + DatasMateriel!Reference + " / " + DatasMateriel!NumeroSerie

Me.Texte839.Caption = DatasFluide!libelle
Me.Texte840.Caption = Str(DatasMateriel!NbreRadiateurs) + " kg"

kg = DatasMateriel!NbreRadiateurs
TonneCo2 = (DatasMateriel!NbreRadiateurs * DatasFluide!GWP) / 1000

Me.Texte841.Caption = Str(Format(TonneCo2, " 0.0000")) + " t.éq.CO2"
DateInt = DataIntervention!datint
Me.Texte843.Caption = "02/01/" + Right(DateInt, 4)

CheckInvisible


'HCFC en kg
If (Ligne = 1) Then
    If (kg < 30) Then
        Me.ChkL1C1.Value = 1
        Me.ChkL1C1.Visible = True
        'Systeme permanent detec fuite ->2 eme Ligne Sinon 1 ere
        If (DatasSite!controleetancheiteponctuel = True) Then
            Me.ChkOui.Value = 1
            Me.ChkOui.Visible = True
            Me.ChkL5C1.Value = 1
            Me.ChkL5C1.Visible = True
        Else
            Me.ChkNon.Value = 1
            Me.ChkNon.Visible = True
            Me.ChkL4C1.Value = 1
            Me.ChkL4C1.Visible = True
        End If
    Else
        If (kg < 300) Then
            Me.ChkL1C2.Value = 1
            Me.ChkL1C2.Visible = True
            'Systeme permanent detec fuite ->2 eme Ligne Sinon 1 ere
            If (DatasSite!controleetancheiteponctuel = True) Then
                Me.ChkOui.Value = 1
                Me.ChkOui.Visible = True
                Me.ChkL5C2.Value = 1
                Me.ChkL5C2.Visible = True
            Else
                Me.ChkNon.Value = 1
                Me.ChkNon.Visible = True
                Me.ChkL4C2.Value = 1
                Me.ChkL4C2.Visible = True
            End If
        Else
            Me.ChkL1C3.Value = 1
            Me.ChkL1C3.Visible = True
             'Systeme permanent detec fuite ->2 eme Ligne Sinon 1 ere
            If (DatasSite!controleetancheiteponctuel = True) Then
                Me.ChkOui.Value = 1
                Me.ChkOui.Visible = True
                Me.ChkL5C3.Value = 1
                Me.ChkL5C3.Visible = True
            Else
                Me.ChkNon.Value = 1
                Me.ChkNon.Visible = True
                Me.ChkL4C3.Value = 1
                Me.ChkL4C3.Visible = True
            End If
        End If
    End If
End If

'HFC en TonnesCo2
If (Ligne = 2) Then
    If (TonneCo2 < 50) Then
        Me.ChkL2C1.Value = 1
        Me.ChkL2C1.Visible = True
        'Systeme permanent detec fuite ->2 eme Ligne Sinon 1 ere
        If (DatasSite!controleetancheiteponctuel = True) Then
            Me.ChkOui.Value = 1
            Me.ChkOui.Visible = True
            Me.ChkL5C1.Value = 1
            Me.ChkL5C1.Visible = True
        Else
            Me.ChkNon.Value = 1
            Me.ChkNon.Visible = True
            Me.ChkL4C1.Value = 1
            Me.ChkL4C1.Visible = True
        End If
    Else
        If (TonneCo2 < 500) Then
            Me.ChkL2C2.Value = 1
            Me.ChkL2C2.Visible = True
             'Systeme permanent detec fuite ->2 eme Ligne Sinon 1 ere
            If (DatasSite!controleetancheiteponctuel = True) Then
                Me.ChkOui.Value = 1
                Me.ChkOui.Visible = True
                Me.ChkL5C2.Value = 1
                Me.ChkL5C2.Visible = True
            Else
                Me.ChkNon.Value = 1
                Me.ChkNon.Visible = True
                Me.ChkL4C2.Value = 1
                Me.ChkL4C2.Visible = True
            End If
        Else
            Me.ChkL2C3.Value = 1
            Me.ChkL2C3.Visible = True
             'Systeme permanent detec fuite ->2 eme Ligne Sinon 1 ere
            If (DatasSite!controleetancheiteponctuel = True) Then
                Me.ChkOui.Value = 1
                Me.ChkOui.Visible = True
                Me.ChkL5C3.Value = 1
                Me.ChkL5C3.Visible = True
            Else
                Me.ChkNon.Value = 1
                Me.ChkNon.Visible = True
                Me.ChkL4C3.Value = 1
                Me.ChkL4C3.Visible = True
            End If
        End If
    End If
End If

'HFO en kg
If (Ligne = 3) Then
    If (kg < 10) Then
        Me.ChkL3C1.Value = 1
        Me.ChkL3C1.Visible = True
        'Systeme permanent detec fuite ->2 eme Ligne Sinon 1 ere
        If (DatasSite!controleetancheiteponctuel = True) Then
            Me.ChkOui.Value = 1
            Me.ChkOui.Visible = True
            Me.ChkL5C1.Value = 1
            Me.ChkL5C1.Visible = True
        Else
            Me.ChkNon.Value = 1
            Me.ChkNon.Visible = True
            Me.ChkL4C1.Value = 1
            Me.ChkL4C1.Visible = True
        End If
    Else
        If (kg < 100) Then
            Me.ChkL3C2.Value = 1
            Me.ChkL3C2.Visible = True
             'Systeme permanent detec fuite ->2 eme Ligne Sinon 1 ere
            If (DatasSite!controleetancheiteponctuel = True) Then
                Me.ChkOui.Value = 1
                Me.ChkOui.Visible = True
                Me.ChkL5C2.Value = 1
                Me.ChkL5C2.Visible = True
            Else
                Me.ChkNon.Value = 1
                Me.ChkNon.Visible = True
                Me.ChkL4C2.Value = 1
                Me.ChkL4C2.Visible = True
            End If
        Else
            Me.ChkL3C3.Value = 1
            Me.ChkL3C3.Visible = True
             'Systeme permanent detec fuite ->2 eme Ligne Sinon 1 ere
            If (DatasSite!controleetancheiteponctuel = True) Then
                Me.ChkOui.Value = 1
                Me.ChkOui.Visible = True
                Me.ChkL5C3.Value = 1
                Me.ChkL5C3.Visible = True
            Else
                Me.ChkNon.Value = 1
                Me.ChkNon.Visible = True
                Me.ChkL4C3.Value = 1
                Me.ChkL4C3.Visible = True
            End If
        End If
    End If
End If


Me.Texte815.Caption = DataIntervention!sigtec2
Me.Texte819.Caption = "Technicien"
Me.Texte820.Caption = DataIntervention!datint

Me.Texte824.Caption = DataIntervention!sigcli2
Me.Texte825.Caption = "Client"
Me.Texte832.Caption = DataIntervention!datint

Nom_Sign = ""
If (IsNull(DataIntervention!sigtecimg) = False) Then
    Nom_Sign = DataIntervention!sigtecimg
End If

If (FileExists(Nom_Sign)) Then
    Me.Image846.Picture = Nom_Sign
Else
    Me.Image846.Visible = False
End If

Nom_Sign = ""
If (IsNull(DataIntervention!sigcliimg) = False) Then
    Nom_Sign = DataIntervention!sigcliimg
End If

If (FileExists(Nom_Sign)) Then
    Me.Image847.Picture = Nom_Sign
Else
    Me.Image847.Visible = False
End If

'Tout c'est bien passé On va donc 'Coché Editer
CurrentDb.Execute "Update SiteMateriel set CE_EDITE = 1 where NumerositeMateriel=" + NumMateriel, dbSeeChanges

If Not DataIntervention Is Nothing Then
    If DataIntervention.RecordCount >= 0 <> 0 Then DataIntervention.Close
    Set DataIntervention = Nothing
End If
If Not DatasSite Is Nothing Then
    If DatasSite.RecordCount >= 0 <> 0 Then DatasSite.Close
    Set DatasSite = Nothing
End If
If Not DatasMateriel Is Nothing Then
    If DatasMateriel.RecordCount >= 0 <> 0 Then DatasMateriel.Close
    Set DatasMateriel = Nothing
End If
If Not DatasFluide Is Nothing Then
    If DatasFluide.RecordCount >= 0 <> 0 Then DatasFluide.Close
    Set DatasFluide = Nothing
End If
If Not DatasGaz Is Nothing Then
    If DatasGaz.RecordCount >= 0 <> 0 Then DatasGaz.Close
    Set DatasGaz = Nothing
End If
    
Exit Sub
   
Erreur:

MsgBox "La génération du CE " + Me.OpenArgs + " n'as pas pu se faire correctement", vbCritical

End Sub
Public Function FileExists(ByVal path_ As String) As Boolean
    On Error GoTo err
    FileExists = (Len(Dir(path_)) > 0)
    Exit Function
err:
    FileExists = False
End Function

Public Sub CheckInvisible()
Me.ChkL1C1.Visible = False
Me.ChkL1C2.Visible = False
Me.ChkL1C3.Visible = False
Me.ChkL2C1.Visible = False
Me.ChkL2C2.Visible = False
Me.ChkL2C3.Visible = False
Me.ChkL3C1.Visible = False
Me.ChkL3C2.Visible = False
Me.ChkL3C3.Visible = False
Me.ChkL4C1.Visible = False
Me.ChkL4C2.Visible = False
Me.ChkL4C3.Visible = False
Me.ChkL5C1.Visible = False
Me.ChkL5C2.Visible = False
Me.ChkL5C3.Visible = False
Me.ChkNon.Visible = False
Me.ChkOui.Visible = False
Me.ChkOn.Visible = True
Me.ChkOn.Value = True
Me.Cocher735.Visible = True
Me.Cocher735.Value = True
End Sub
