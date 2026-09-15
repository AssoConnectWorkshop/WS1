Attribute VB_Name = "Form_Saisie_EV_Vehicule"
Attribute VB_Base = "0{B7A06EDD-1A89-4DEE-A98A-6B44B94BD022}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database


Private Function Verif_Data() As Boolean

If Not IsNull(Me.TypeEv) Then
    Verif_Data = True
Else
     MsgBox "Merci de renseigner un type d'evenement"
     Verif_Data = False
     Exit Function
End If

If Not IsNull(Me.Conducteur) Then
    Verif_Data = True
Else
     MsgBox "Merci de renseigner un conducteur"
     Verif_Data = False
     Exit Function
End If

If Not IsNull(Me.Immat) Then
    Verif_Data = True
Else
     MsgBox "Merci de renseigner une Immatriculation"
     Verif_Data = False
     Exit Function
End If

If Not IsNull(Me.DateEv) Then
    Verif_Data = True
Else
     MsgBox "Merci de renseigner une Date"
     Verif_Data = False
     Exit Function
End If


Requete = "Select max(km) from dbo_evvehicules where Immat='" + Me.Immat + "'"
Set db = CurrentDb
Set ListeEV = db.OpenRecordset(Requete, dbOpenSnapshot)

Max = ListeEV(0)
If IsNull(Max) Then
    Max = 0
End If
ListeEV.Close
Set ListeEV = Nothing

If Not IsNull(Me.Km) Then
    result = EstNumerique(Me.Km)
    If (result = False) Then
        Verif_Data = result
        Exit Function
    Else
        '26/04/24 Controle des KM que pour des saisies de KM
        If (Me.TypeEv = "1" Or Me.TypeEv = "5") Then
            If (CLng(Me.Km) < Max) Then
                MsgBox "Le dernier kilometrage saisi pour " + Me.Immat + "est " + Str(Max) + ",Merci de changer votre saisie", vbCritical, "Erreur Saisie KM"
                Verif_Data = False
                Exit Function
            End If
        End If
    End If
Else
     MsgBox "Merci de renseigner un kilometrage"
     Verif_Data = False
     Exit Function
End If


Verif_Data = result

End Function

Private Function EstNumerique(Texte As Object) As Boolean


If Not IsNull(Texte) Then
    If Texte <> "" Then
        If (IsNumeric(Texte) = False) Then
            MsgBox "Veuillez verifier Votre Saisie pour " + Texte.EventProcPrefix
            EstNumerique = False
            Exit Function
        End If
    End If
Else
    '12/01/24 Ajout Valeur nulle
    EstNumerique = False
    Exit Function
End If
EstNumerique = True

End Function

Private Sub Bp_Ajout_Click()
If (Verif_Data) Then
    FaireModif
End If
End Sub

Private Sub Conducteur_Change()
'On recherche l'immat
Requete = "select dbo_Vehicules.Immatriculation from dbo_Vehicules   where  dbo_Vehicules.conducteur=" + Me.Conducteur
Set RsCodInt = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
If Not RsCodInt.EOF Then
    Me.Immat = RsCodInt(0)
    RsCodInt.Close
Else
    Me.Immat = ""
End If
RsCodInt.Close
Set RsCodInt = Nothing
End Sub

Private Sub Form_Load()
Dim Today As Date
Today = Now
Dim Jour As String
Dim Mois As String
Jour = Trim(Str(Day(Today)))

If Len(Jour) = 1 Then
    Jour = "0" + Jour
End If
Mois = Trim(Str(Month(Today)))
If Len(Trim(Mois)) = 1 Then
    Mois = "0" + Mois
End If

Me.DateEv.Value = Jour + Mois + Right(Str(Year(Today)), 2)
End Sub


Public Sub FaireModif()
    Requete = "INSERT INTO dbo_EvVehicules (DateEV,KM,Conducteur,Immat,TypeEv) Values ('" & MiseFormeDateEcriture(Me.DateEv) & "'," & Me.Km & "," & Me.Conducteur.Value & ",'" & Me.Immat & "'," & Me.TypeEv.Value & ")"
    CurrentDb.Execute Requete, dbSeeChanges

 
    DoCmd.Close
End Sub

Public Function MiseFormeDateLecture(DataAvant As String) As String
Jour = Mid(DataAvant, 9, 2)
Mois = Mid(DataAvant, 6, 2)
Annee = Mid(DataAvant, 3, 2)
MiseFormeDateLecture = Jour + "/" + Mois + "/" + Annee
End Function

Public Function MiseFormeDateEcriture(DataAvant As String) As String
Jour = Mid(DataAvant, 1, 2)
Mois = Mid(DataAvant, 3, 2)
If Len(DataAvant) = 6 Then
    Annee = Mid(DataAvant, 5, 2)
Else
    Annee = Mid(DataAvant, 7, 2)
End If
MiseFormeDateEcriture = Jour + "/" + Mois + "/" + Annee

End Function


Private Sub Immat_Change()

 Dim RsCodInt As Recordset

'On recherche le conducteur
Requete = "select Utilisateur.numuti from dbo_Vehicules INNER JOIN Utilisateur ON dbo_Vehicules.Conducteur = Utilisateur.numuti  where  dbo_Vehicules.Immatriculation='" + Me.Immat + "'"
Set RsCodInt = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
If Not RsCodInt.EOF Then
    Me.Conducteur = RsCodInt(0)
Else
    Me.Conducteur = ""
End If
RsCodInt.Close
Set RsCodInt = Nothing
End Sub

Private Sub Quitter__SANS_SAUVEGARDE__Click()


   If Me.Dirty Then Me.Dirty = False
    DoCmd.Close

Exit_Commande297_Click:
    Exit Sub

Err_Commande297_Click:
    MsgBox err.Description
    Resume Exit_Commande297_Click
End Sub
