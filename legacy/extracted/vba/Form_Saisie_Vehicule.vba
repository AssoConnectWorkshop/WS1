Attribute VB_Name = "Form_Saisie_Vehicule"
Attribute VB_Base = "0{CA128B0F-80C3-4755-8026-088A8CF77970}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database
Dim Modif_Conducteur As Boolean
Dim Modif_EtatVehicule As Boolean
Dim Modif_Immat As Boolean
Dim Modif_DateMiseCirculation As Boolean
Dim Modif_Garantie As Boolean
Dim Modif_KM_a_l_achat As Boolean
Dim Modif_Nb_KM_Garantie As Boolean
Dim Modif_Temps_Mois_Garantie As Boolean
Dim Modif_Leasing As Boolean
Dim Modif_Nb_Km_Leasing As Boolean
Dim Modif_Temps_Mois_Leasing As Boolean
Dim Modif_Date_Fin_Leasing As Boolean
Dim Modif_Km_Inter_Revision As Boolean
Dim Modif_Temps_Mois_Inter_Revision As Boolean
Dim Modif_NumTelepeage As Boolean
Dim Modif_CodeCarteEssence As Boolean
Dim Modif_NumCarteEssence As Boolean
Dim Modif_Marque As Boolean
Dim Modif_Modele As Boolean
Dim Modif_Societe As Boolean
Dim Modif_Critair As Boolean
Dim Modif_Chemin As Boolean

Private Function Verif_Data() As Boolean

result = EstNumerique(Me.KM_a_l_achat)
If (result = False) Then
    Verif_Data = result
    Exit Function
End If

result = EstNumerique(Me.Km_Dernier_Entretien)
If (result = False) Then
    Verif_Data = result
    Exit Function
End If

result = EstNumerique(Me.Km_Inter_Revision)
If (result = False) Then
    Verif_Data = result
    Exit Function
End If

result = EstNumerique(Me.Temps_Mois_Garantie)
If (result = False) Then
    Verif_Data = result
    Exit Function
End If

result = EstNumerique(Me.Temps_Mois_Inter_Revision)
If (result = False) Then
    Verif_Data = result
    Exit Function
End If

result = EstNumerique(Me.Temps_Mois_Leasing)
If (result = False) Then
    Verif_Data = result
    Exit Function
End If

result = EstNumerique(Me.Nb_KM_Garantie)
If (result = False) Then
    Verif_Data = result
    Exit Function
End If

result = EstNumerique(Me.Nb_Km_Leasing)
If (result = False) Then
    Verif_Data = result
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
End If
EstNumerique = True

End Function

Private Sub Bp_Ajout_Click()
If (Verif_Data) Then
    FaireModif
End If
End Sub

Private Sub CheminPC_Dirty(Cancel As Integer)
Modif_Chemin = True
End Sub

Private Sub CodeCarteEssence_Change()
Modif_CodeCarteEssence = True
End Sub

Private Sub Conducteur_Change()
    Modif_Conducteur = True
End Sub






Private Sub critair_Click()
Modif_Critair = True
End Sub

Private Sub Date_Fin_Leasing_Change()
Modif_Date_Fin_Leasing = True
End Sub

Private Sub DateMiseCirculation_Change()
 Modif_DateMiseCirculation = True
End Sub


Private Sub EtatVehicule_Change()
Modif_EtatVehicule = True
End Sub

Private Sub Form_Load()
    Dim Temp As String
    Me.lblSite.Caption = "Modification Véhicule"
    'Recherche et remplissage Infos

       
If (Me.OpenArgs <> "") Then
    
    Requete = "select * from dbo_vehicules where " & Me.OpenArgs
    'dbOpenSnapshot Pas de modif possible
    Set RsCodInt = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot, dbReadOnly)
    If Not RsCodInt.EOF Then
       Me.Immat = RsCodInt("Immatriculation")
       Me.NumVehicule = RsCodInt("NumVehicule")
       Me.Conducteur = RsCodInt("Conducteur")
       Me.EtatVehicule = RsCodInt("EtatVehicule")
       
       If IsNull(RsCodInt("DateMiseCirculation")) = False Then
            Temp = RsCodInt("DateMiseCirculation")
            '29/03/24 Pierre et Moi ->2015-06-01 autres PC ->06/01/2015
            If (InStr(1, Temp, "-", vbTextCompare) <> 0) Then
                Me.DateMiseCirculation = MiseFormeDateLecture(Temp)
            Else
                Me.DateMiseCirculation = Temp
            End If
       End If
       Me.KM_a_l_achat = RsCodInt("KM_a_l_achat")
       Me.Km_Inter_Revision = RsCodInt("Km_Inter_Revision")
       Me.Temps_Mois_Inter_Revision = RsCodInt("Temps_Mois_Inter_Revision")
       Me.Nb_KM_Garantie = RsCodInt("Nb_KM_Garantie")
       Me.Temps_Mois_Garantie = RsCodInt("Temps_Mois_Garantie")
       Me.Nb_Km_Leasing = RsCodInt("Nb_Km_Leasing")
       Me.Temps_Mois_Leasing = RsCodInt("Temps_Mois_Leasing")
       If IsNull(RsCodInt("Date_Fin_Leasing")) = False Then
            Temp = RsCodInt("Date_Fin_Leasing")
            If (InStr(1, Temp, "-", vbTextCompare) <> 0) Then
                Me.Date_Fin_Leasing = MiseFormeDateLecture(Temp)
            Else
                Me.Date_Fin_Leasing = Temp
            End If
       End If
               
       Me.Leasing = RsCodInt("Leasing")
       Me.NumTelepeage = RsCodInt("NumTelepeage")
       Me.CodeCarteEssence = RsCodInt("CodeCarteEssence")
       Me.NumCarteEssence = RsCodInt("NumCarteEssence")
       Me.Garantie.Value = RsCodInt("Garantie")
       Me.CheminPC = RsCodInt("Champ_Libre")
       
       '29/03/24 Nouvelles colonnes
        Me.Marque = RsCodInt("Marque")
       Me.Modele = RsCodInt("Modele")
       Me.Societe = RsCodInt("societe")
       Me.critair = RsCodInt("critair")
       
       'Recherche par rapport aux Evenements
       Requete = "select * from dbo_evvehicules where Immat='" + Me.Immat + "'"
       'dbOpenSnapshot Pas de modif possible
       Set RsEvVehicules = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot, dbReadOnly)
       Dim KmMaxRev As Double
        Dim KmMaxCT As Double
        Dim KmMaxCC As Double
        Dim KMSaisie As Double
        Dim KmMaxReleve As Double
       Do Until RsEvVehicules.EOF
            
            
            If IsNull(RsEvVehicules("TypeEv")) = False Then
                If IsNull(RsEvVehicules("Km")) = False Then
                    KMSaisie = RsEvVehicules("Km")
                                                                               
                    'Revision
                    If (RsEvVehicules("TypeEv") = 2) Then
                        If (KmMaxRev < KMSaisie) Then
                            KmMaxRev = KMSaisie
                            Me.Km_Dernier_Entretien = RsEvVehicules("Km")
                            If IsNull(RsEvVehicules("DateEv")) = False Then
                                Me.Date_Dernier_Entretien = RsEvVehicules("DateEv")
                            End If
                        End If
                    End If
                       
                    'Controle Technique
                    If (RsEvVehicules("TypeEv") = 3) Then
                        If (KmMaxCT < KMSaisie) Then
                            KmMaxCT = KMSaisie
                            If IsNull(RsEvVehicules("DateEv")) = False Then
                                Me.Date_Dernier_CT = RsEvVehicules("DateEv")
                            End If
                        End If
                    End If
                    
                    'Controle Complementaire
                    If (RsEvVehicules("TypeEv") = 4) Then
                        If (KmMaxCC < KMSaisie) Then
                            KmMaxCC = KMSaisie
                            If IsNull(RsEvVehicules("DateEv")) = False Then
                                Me.Date_Dernier_CC = RsEvVehicules("DateEv")
                            End If
                        End If
                    End If
                    
                    'Releve KM
                    If (RsEvVehicules("TypeEv") = 1 Or RsEvVehicules("TypeEv") = 5) Then
                        If (KmMaxReleve < KMSaisie) Then
                            KmMaxReleve = KMSaisie
                            Me.Dernier_Releve_KM = RsEvVehicules("Km")
                            If IsNull(RsEvVehicules("DateEv")) = False Then
                                Me.Date_Dernier_Releve_KM = RsEvVehicules("DateEv")
                            End If
                        End If
                    End If
                       
                       
                End If
            End If
            RsEvVehicules.MoveNext
       Loop
    End If
    InitMemo
End If
End Sub
Public Sub InitMemo()
Modif_Conducteur = False
Modif_Immat = False
Modif_EtatVehicule = False
Modif_DateMiseCirculation = False
Modif_Garantie = False
Modif_KM_a_l_achat = False
Modif_Nb_KM_Garantie = False
Modif_Temps_Mois_Garantie = False
Modif_Leasing = False
Modif_Nb_Km_Leasing = False
Modif_Temps_Mois_Leasing = False
Modif_Date_Fin_Leasing = False
Modif_Km_Inter_Revision = False
Modif_Temps_Mois_Inter_Revision = False
Modif_NumTelepeage = False
Modif_CodeCarteEssence = False
Modif_NumCarteEssence = False
End Sub

Public Sub FaireModif()
    If Modif_Conducteur = True Then
        Requete = "Update dbo_Vehicules set Conducteur=" & Me.Conducteur & " Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Conducteur = False
    End If
    
    If Modif_Immat = True Then
        Requete = "Update dbo_Vehicules set Immatriculation='" & Me.Immat & "' Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Immat = False
    End If
    
    If Modif_EtatVehicule = True Then
        Requete = "Update dbo_Vehicules set EtatVehicule=" & Me.EtatVehicule & " Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_EtatVehicule = False
    End If
    
    If Modif_DateMiseCirculation = True Then
        Requete = "Update dbo_Vehicules set DateMiseCirculation='" & MiseFormeDateEcriture(Me.DateMiseCirculation) & "' Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_DateMiseCirculation = False
    End If
    
    If Modif_Date_Fin_Leasing = True Then
        Requete = "Update dbo_Vehicules set Date_Fin_Leasing='" & MiseFormeDateEcriture(Me.Date_Fin_Leasing) & "' Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Date_Fin_Leasing = False
    End If
    

    If Modif_Leasing = True Then
        Requete = "Update dbo_Vehicules set leasing=" & Me.Leasing.Value & " Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Leasing = False
    End If

   
    If Modif_Garantie = True Then
        Requete = "Update dbo_Vehicules set Garantie=" & Me.Garantie.Value & " Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Garantie = False
    End If
    
    If Modif_Leasing = True Then
        Requete = "Update dbo_Vehicules set Leasing=" & Me.Leasing.Value & " Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Leasing = False
    End If
    
    If Modif_KM_a_l_achat = True Then
        Requete = "Update dbo_Vehicules set KM_a_l_achat=" & Me.KM_a_l_achat & " Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_KM_a_l_achat = False
    End If
    
     If Modif_Nb_KM_Garantie = True Then
        Requete = "Update dbo_Vehicules set Nb_KM_Garantie=" & Me.Nb_KM_Garantie & " Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Nb_KM_Garantie = False
    End If
    
    If Modif_Temps_Mois_Garantie = True Then
        Requete = "Update dbo_Vehicules set Temps_Mois_Garantie=" & Me.Temps_Mois_Garantie & " Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Temps_Mois_Garantie = False
    End If
    
    If Modif_Nb_Km_Leasing = True Then
        Requete = "Update dbo_Vehicules set Nb_Km_Leasing=" & Me.Nb_Km_Leasing & " Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Nb_Km_Leasing = False
    End If
    
    If Modif_Temps_Mois_Leasing = True Then
        Requete = "Update dbo_Vehicules set Temps_Mois_Leasing=" & Me.Temps_Mois_Leasing & " Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Temps_Mois_Leasing = False
    End If
   
   If Modif_Km_Inter_Revision = True Then
        Requete = "Update dbo_Vehicules set Km_Inter_Revision=" & Me.Km_Inter_Revision & " Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Km_Inter_Revision = False
    End If
   
    
    If Modif_Temps_Mois_Inter_Revision = True Then
        Requete = "Update dbo_Vehicules set Temps_Mois_Inter_Revision=" & Me.Temps_Mois_Inter_Revision & " Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Temps_Mois_Inter_Revision = False
    End If
    

    
    If Modif_NumTelepeage = True Then
        Requete = "Update dbo_Vehicules set NumTelepeage  ='" & Me.NumTelepeage & "' Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_NumTelepeage = False
    End If
    
    If Modif_CodeCarteEssence = True Then
        Requete = "Update dbo_Vehicules set CodeCarteEssence  ='" & Me.CodeCarteEssence & "' Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_CodeCarteEssence = False
    End If
    
    If Modif_NumCarteEssence = True Then
        Requete = "Update dbo_Vehicules set NumCarteEssence  ='" & Me.NumCarteEssence & "' Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_NumCarteEssence = False
    End If
    
    If Modif_Marque = True Then
        Requete = "Update dbo_Vehicules set Marque  ='" & Me.Marque & "' Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Marque = False
    End If
    
    If Modif_Modele = True Then
        Requete = "Update dbo_Vehicules set Modele  ='" & Me.Modele & "' Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Modele = False
    End If
    
    If Modif_Societe = True Then
        Requete = "Update dbo_Vehicules set Societe  ='" & Me.Societe & "' Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Societe = False
    End If
    
     If Modif_Critair = True Then
        Requete = "Update dbo_Vehicules set Critair  ='" & Me.critair & "' Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Critair = False
    End If
    
    If Modif_Chemin = True Then
        Requete = "Update dbo_Vehicules set Champ_Libre  ='" & Me.CheminPC & "' Where NumVehicule=" & Me.NumVehicule & ""
        CurrentDb.Execute Requete, dbSeeChanges
        Modif_Chemin = False
    End If
    
    
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
Private Sub Garantie_Click()
Modif_Garantie = True
End Sub

Private Sub Immat_Change()
 Modif_Immat = True
End Sub

Private Sub KM_a_l_achat_Change()
Modif_KM_a_l_achat = True
End Sub



Private Sub Km_Inter_Revision_Change()
Modif_Km_Inter_Revision = True
End Sub

Private Sub Leasing_Click()
Modif_Leasing = True
End Sub

Private Sub Marque_Change()
Modif_Marque = True
End Sub

Private Sub Modele_Change()
Modif_Modele = True
End Sub

Private Sub Nb_KM_Garantie_Change()
Modif_Nb_KM_Garantie = True
End Sub

Private Sub Nb_Km_Leasing_Change()
Modif_Nb_Km_Leasing = True
End Sub

Private Sub NumCarteEssence_Change()
Modif_NumCarteEssence = True
End Sub

Private Sub NumTelepeage_Change()
Modif_NumTelepeage = True
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

Private Sub societe_Change()
Modif_Societe = True
End Sub

Private Sub Temps_Mois_Garantie_Change()
Modif_Temps_Mois_Garantie = True
End Sub

Private Sub Temps_Mois_Inter_Revision_Change()
Modif_Temps_Mois_Inter_Revision = True
End Sub

Private Sub Temps_Mois_Leasing_Change()
Modif_Temps_Mois_Leasing = True
End Sub
