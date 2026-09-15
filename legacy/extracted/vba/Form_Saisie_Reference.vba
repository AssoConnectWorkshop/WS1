Attribute VB_Name = "Form_Saisie_Reference"
Attribute VB_Base = "0{E240E367-345E-407A-A9D6-A222D925B58F}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database
Dim Modif_Nom_Ref As Boolean
Dim Modif_Marque As Boolean
Dim Modif_Type As Boolean
Dim Modif_Repere As Boolean
Dim Modif_Fluide As Boolean
Dim Modif_Type_Tel As Boolean
Dim Modif_Reversible As Boolean
Dim Modif_Resistance As Boolean
Dim Modif_Frigo As Boolean
Dim Modif_Calo As Boolean
Dim Modif_Gaz As Boolean
Dim Modif_NbFiltres As Boolean
Dim Modif_DimFiltres As Boolean
Dim Modif_NbCourroies As Boolean
Dim Modif_RefCourroies As Boolean
Dim Modif_AppointRoof As Boolean
Dim Old_Nom_Ref As String
Private Sub Init_Memo_Changement()
    Modif_Nom_Ref = False
    Modif_Marque = False
    Modif_Type = False
    Modif_Repere = False
    Modif_Fluide = False
    Modif_Type_Tel = False
    Modif_Reversible = False
    Modif_Resistance = False
    Modif_Frigo = False
    Modif_Calo = False
    Modif_Gaz = False
    Modif_NbFiltres = False
    Modif_Filtres = False
    Modif_NbCourroies = False
    Modif_RefCourroies = False
    Modif_AppointRoof = False
End Sub


Private Function Verif_Data(Avec_NomRef) As Boolean

'Verification Données Remplies
If Me.Nom_Ref = "" Or IsNull(Me.Nom_Ref) Then
    MsgBox "Veuillez verifier le nom de la reference"
    Verif_Data = False
    Exit Function
End If

If Me.Marque = "" Or IsNull(Me.Marque) Then
    MsgBox "Veuillez verifier le nom de la Marque"
    Verif_Data = False
    Exit Function
End If

If Me.Type = "" Or IsNull(Me.Type) Then
    MsgBox "Veuillez verifier le Type"
    Verif_Data = False
    Exit Function
End If

If Me.Repere = "" Or IsNull(Me.Repere) Then
    MsgBox "Veuillez verifier le Repere"
    Verif_Data = False
    Exit Function
End If

If Me.fluide = "" Or IsNull(Me.fluide) Then
    MsgBox "Veuillez verifier le fluide"
    Verif_Data = False
    Exit Function
End If

If Me.Type_Tel = "" Or IsNull(Me.Type_Tel) Then
    MsgBox "Veuillez verifier le Type de Telecommande"
    Verif_Data = False
    Exit Function
End If

If Me.Reversible = "" Or IsNull(Me.Reversible) Then
    MsgBox "Veuillez verifier le champ reversible"
    Verif_Data = False
    Exit Function
End If

If Me.Resistance = "" Or IsNull(Me.Resistance) Then
    MsgBox "Veuillez verifier le champ Resistance"
    Verif_Data = False
    Exit Function
End If

If Me.Gaz = "" Or IsNull(Me.Gaz) Or (IsNumeric(Me.Gaz) = False) Then
    MsgBox "Veuillez verifier la quantité de gaz"
    Verif_Data = False
    Exit Function
End If

If Me.Puiss_Calo = "" Or IsNull(Me.Puiss_Calo) Or (IsNumeric(Me.Puiss_Calo) = False) Then
    MsgBox "Veuillez verifier la puissance calorifique"
    Verif_Data = False
    Exit Function
Else
    If (Str(Int(Me.Puiss_Calo)) <> Str(Me.Puiss_Calo)) Then
        MsgBox "Veuillez verifier la puissance calorifique,elle est en W"
        Verif_Data = False
        Exit Function
    End If
End If

If Me.Puiss_Frigo = "" Or IsNull(Me.Puiss_Frigo) Or (IsNumeric(Me.Puiss_Frigo) = False) Then
    MsgBox "Veuillez verifier la puissance Frigorifique"
    Verif_Data = False
    Exit Function
Else
    If (Str(Int(Me.Puiss_Frigo)) <> Str(Me.Puiss_Frigo)) Then
        MsgBox "Veuillez verifier la puissance frigorifique,elle est en W"
        Verif_Data = False
        Exit Function
    End If
End If

If Me.Nb_Courroies = "" Or IsNull(Me.Nb_Courroies) Or (IsNumeric(Me.Nb_Courroies) = False) Then
    MsgBox "Veuillez verifier le nombre de courroies"
    Verif_Data = False
    Exit Function
End If

If Me.Nb_Filtres = "" Or IsNull(Me.Nb_Filtres) Or (IsNumeric(Me.Nb_Filtres) = False) Then
    MsgBox "Veuillez verifier le nombre de Filtres"
    Verif_Data = False
    Exit Function
End If

If (Avec_NomRef) Then
    Dim Requete As String
    'Verification Nom Reference
    Requete = "select * from reference where Reference='" & Me.Nom_Ref & "'"
    Set RsCodInt = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
    If Not RsCodInt.EOF Then
        MsgBox "Le nom de la reference existe deja dans la base"
        RsCodInt.Close
        Verif_Data = False
        Exit Function
    End If
    RsCodInt.Close
End If

Verif_Data = True

End Function



Private Sub Bp_Ajout_Click()
Dim Requete As String
Dim Requete2 As String
Dim Requete3 As String

If Verif_Data(True) = False Then
    Exit Sub
End If

'Ajout dans base

Requete = "INSERT INTO REFERENCE (Reference,Repere,Type,Nommar,Fluide,TypeTel,Reversible,Resistance,PuissanceFrigo,PuissanceCalo,QteGaz,NbFiltres,DimFiltres,NbCourroies,RefCourroies,AppointRoof) VALUES ("
Requete2 = "'" & Me.Nom_Ref & "','" & Trim(Me.Repere.Column(1, Me.Repere)) & "','" & Trim(Me.Type.Column(1, Me.Type)) & "','" & Trim(Me.Marque.Column(1, Me.Marque)) & "','" & Trim(Me.fluide.Column(1, Me.fluide)) & "','" & Trim(Me.Type_Tel.Column(1, Me.Type_Tel)) & "','" & Me.Reversible & "','" & Me.Resistance & "','" & Me.Puiss_Frigo & "','" & Me.Puiss_Calo
Requete3 = "','" & Me.Gaz & "','" & Me.Nb_Filtres & "','" & Me.Dim_Filtres & "','" & Me.Nb_Courroies & "','" & Me.Ref_Courroies & "','" & Me.Appoint_Roof & "')"
CurrentDb.Execute Requete + Requete2 + Requete3
DoCmd.Close
End Sub

Private Sub BP_Creation_Click()
Dim Requete As String
Dim Requete2 As String
Dim Requete3 As String

If Verif_Data(True) = False Then
    Exit Sub
End If

Rep = MsgBox("Attention,Vous allez Creer une nouvelle reference dans la base de données,la reference dont vous etes partie existera toujours,Etes Vous Sur ?", vbExclamation + vbYesNo, "Confirmation")
If Rep = vbNo Then
    Exit Sub
End If


'Ajout dans base
Requete = "INSERT INTO REFERENCE (Reference,Repere,Type,Nommar,Fluide,TypeTel,Reversible,Resistance,PuissanceFrigo,PuissanceCalo,QteGaz,NbFiltres,DimFiltres,NbCourroies,RefCourroies,AppointRoof) VALUES ("
Requete2 = "'" & Me.Nom_Ref & "','" & Trim(Me.Repere.Column(1, Me.Repere)) & "','" & Trim(Me.Type.Column(1, Me.Type)) & "','" & Trim(Me.Marque.Column(1, Me.Marque)) & "','" & Trim(Me.fluide.Column(1, Me.fluide)) & "','" & Trim(Me.Type_Tel.Column(1, Me.Type_Tel)) & "','" & Me.Reversible & "','" & Me.Resistance & "','" & Me.Puiss_Frigo & "','" & Me.Puiss_Calo
Requete3 = "','" & Me.Gaz & "','" & Me.Nb_Filtres & "','" & Me.Dim_Filtres & "','" & Me.Nb_Courroies & "','" & Me.Ref_Courroies & "','" & Me.Appoint_Roof & "')"
CurrentDb.Execute Requete + Requete2 + Requete3
DoCmd.Close
End Sub

Private Sub BP_Modification_Toutes_Click()
    If Verif_Data(False) = False Then
        Exit Sub
    End If
    'Modif de toutes les references utilisées dans le materiel
    Modif_BD_Materiel
    
    Modif_BD_Ref
    DoCmd.Close
End Sub



Private Sub BP_Modification_Une_Click()
    If Verif_Data(False) = False Then
        Exit Sub
    End If
    Modif_BD_Ref
    DoCmd.Close
End Sub
Private Sub Modif_BD_Materiel()

Dim Requete As String

If Modif_Nom_Ref = True Then
    Requete = "Update SiteMateriel set Reference='" & Me.Nom_Ref & "' Where " & Old_Nom_Ref
    CurrentDb.Execute Requete
End If

If Modif_Marque = True Then
    Requete = "Update SiteMateriel set Marque='" & Trim(Me.Marque.Column(1, Me.Marque)) & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
End If

If Modif_Repere = True Then
    Requete = "Update SiteMateriel set Repere='" & Trim(Me.Repere.Column(1, Me.Repere)) & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
End If

If Modif_Type = True Then
    Requete = "Update SiteMateriel set Type='" & Trim(Me.Type.Column(1, Me.Type)) & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
End If


If Modif_Type_Tel = True Then
    Requete = "Update SiteMateriel set TypeTelecommande='" & Trim(Me.Type_Tel.Column(1, Me.Type_Tel)) & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
End If

If Modif_Reversible = True Then
    Requete = "Update SiteMateriel set Reversible='" & Me.Reversible & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
End If

If Modif_Resistance = True Then
    Requete = "Update SiteMateriel set ResistanceElectrique='" & Me.Resistance & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
End If

If Modif_Frigo = True Then
    Requete = "Update SiteMateriel set PuissanceFrigo='" & Me.Puiss_Frigo & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
End If

If Modif_Calo = True Then
    Requete = "Update SiteMateriel set PuissanceCalo='" & Me.Puiss_Calo & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
End If

If Modif_NbFiltres = True Then
    Requete = "Update SiteMateriel set NbreFiltreRoofTop='" & Me.Nb_Filtres & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
End If

If Modif_DimFiltres = True Then
    Requete = "Update SiteMateriel set ReferenceFiltreRoofTop='" & Me.Dim_Filtres & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
End If

If Modif_NbCourroies = True Then
    Requete = "Update SiteMateriel set NbreCourroiesRoofTop='" & Me.Nb_Courroies & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
End If

If Modif_RefCourroies = True Then
    Requete = "Update SiteMateriel set ReferenceCourroiesRoofTop='" & Ref_Courroies & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
End If

If Modif_AppointRoof = True Then
    Requete = "Update SiteMateriel set AppointChauffageSurRoof='" & Appoint_Roof & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
End If

End Sub


Private Sub Modif_BD_Ref()
Dim Requete As String

If Modif_Nom_Ref = True Then
    Requete = "Update Reference set Reference='" & Me.Nom_Ref & "' Where " & Old_Nom_Ref
    CurrentDb.Execute Requete
    Modif_Nom_Ref = False
End If

If Modif_Nom_Ref = True Then
    Requete = "Update Reference set Reference='" & Me.Nom_Ref & "' Where " & Old_Nom_Ref
    CurrentDb.Execute Requete
    Modif_Nom_Ref = False
End If

If Modif_Marque = True Then
    Requete = "Update Reference set Nommar='" & Trim(Me.Marque.Column(1, Me.Marque)) & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_Marque = False
End If

If Modif_Repere = True Then
    Requete = "Update Reference set Repere='" & Trim(Me.Repere.Column(1, Me.Repere)) & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_Repere = False
End If

If Modif_Type = True Then
    Requete = "Update Reference set Type='" & Trim(Me.Type.Column(1, Me.Type)) & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_Type = False
End If

If Modif_Fluide = True Then
    Requete = "Update Reference set Fluide='" & Trim(Me.fluide.Column(1, Me.fluide)) & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_Fluide = False
End If

If Modif_Type_Tel = True Then
    Requete = "Update Reference set TypeTel='" & Trim(Me.Type_Tel.Column(1, Me.Type_Tel)) & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_Type_Tel = False
End If

If Modif_Reversible = True Then
    Requete = "Update Reference set Reversible='" & Me.Reversible & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_Reversible = False
End If

If Modif_Resistance = True Then
    Requete = "Update Reference set Resistance='" & Me.Resistance & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_Resistance = False
End If

If Modif_Frigo = True Then
    Requete = "Update Reference set PuissanceFrigo='" & Me.Puiss_Frigo & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_Frigo = False
End If

If Modif_Calo = True Then
    Requete = "Update Reference set PuissanceCalo='" & Me.Puiss_Calo & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_Calo = False
End If

If Modif_Gaz = True Then
    Requete = "Update Reference set QteGaz='" & Me.Gaz & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_Gaz = False
End If

If Modif_NbFiltres = True Then
    Requete = "Update Reference set NbFiltres='" & Me.Nb_Filtres & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_NbFiltres = False
End If

If Modif_DimFiltres = True Then
    Requete = "Update Reference set DimFiltres='" & Me.Dim_Filtres & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_DimFiltres = False
End If

If Modif_NbCourroies = True Then
    Requete = "Update Reference set NbCourroies='" & Me.Nb_Courroies & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_NbCourroies = False
End If

If Modif_RefCourroies = True Then
    Requete = "Update Reference set RefCourroies='" & Ref_Courroies & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_RefCourroies = False
End If

If Modif_AppointRoof = True Then
    Requete = "Update Reference set AppointRoof='" & Appoint_Roof & "' Where Reference='" & Me.Nom_Ref & "'"
    CurrentDb.Execute Requete
    Modif_AppointRoof = False
End If

End Sub




Private Sub Form_Load()
If Me.OpenArgs <> "" Then
    Old_Nom_Ref = Me.OpenArgs
    Me.lblSite.Caption = "Modification Reference Materiel"
    'Recherche et remplissage Infos
   
    Requete = "select * from reference where " & Me.OpenArgs
    Set RsCodInt = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
    If Not RsCodInt.EOF Then
       Me.Nom_Ref = RsCodInt(1)
       Me.Repere = RsCodInt(2)
       Me.Type = RsCodInt(3)
       Me.Marque = RsCodInt(4)
       Me.fluide = RsCodInt(5)
       Me.Type_Tel = RsCodInt(6)
       Me.Reversible = RsCodInt(7)
       Me.Resistance = RsCodInt(8)
       Me.Puiss_Frigo = RsCodInt(9)
       Me.Puiss_Calo = RsCodInt(10)
       Me.Gaz = RsCodInt(11)
       Me.Nb_Filtres = RsCodInt(12)
       Me.Dim_Filtres = RsCodInt(13)
       Me.Nb_Courroies = RsCodInt(14)
       Me.Ref_Courroies = RsCodInt(15)
       Me.Appoint_Roof = RsCodInt(16)
    End If
    Init_Memo_Changement
    Me.Bp_Ajout.Visible = False
    Me.BP_Modification_Toutes.Visible = True
    Me.BP_Modification_Une.Visible = True
    RsCodInt.Close
    Set RsCodInt = Nothing
Else
    Me.Bp_Ajout.Visible = True
    Me.BP_Modification_Toutes.Visible = False
    Me.BP_Modification_Une.Visible = False
    Me.lblSite.Caption = "Ajout Reference Materiel"
End If
    Me.BP_Creation.Visible = False
End Sub
Private Sub Appoint_Roof_Change()
    Modif_AppointRoof = True
End Sub
Private Sub Dim_Filtres_Change()
    Modif_Filtres = True
End Sub
Private Sub Fluide_Change()
    Modif_Fluide = True
End Sub
Private Sub Gaz_Change()
    Modif_Gaz = True
End Sub
Private Sub Marque_Change()
    Modif_Marque = True
End Sub
Private Sub Nb_Courroies_Change()
    Modif_NbCourroies = True
End Sub
Private Sub Nb_Filtres_Change()
    Modif_NbFiltres = True
End Sub
Private Sub Nom_Ref_Change()
    Modif_Nom_Ref = True
    If Me.Bp_Ajout.Visible = False Then
        Me.BP_Creation.Visible = True
    End If
End Sub
Private Sub Puiss_Calo_Change()
    Modif_Calo = True
End Sub
Private Sub Puiss_Frigo_Change()
    Modif_Frigo = True
End Sub

Private Sub Quitter__SANS_SAUVEGARDE__Click()
On Error GoTo Err_Commande297_Click
    

    If Me.Dirty Then Me.Dirty = False
    DoCmd.Close

Exit_Commande297_Click:
    Exit Sub

Err_Commande297_Click:
    MsgBox err.Description
    Resume Exit_Commande297_Click
    
End Sub

Private Sub Ref_Courroies_Change()
    Modif_RefCourroies = True
End Sub
Private Sub Repere_Change()
    Modif_Repere = True
    Requete = "SELECT TypeAudit.id, TypeAudit.Type FROM TypeAudit where TypeAudit.Type like '%" + Left(Me.Repere.Text, 2) + "%' order by TypeAudit.Type"
    Me.Type.RowSource = Requete
    Me.Type.Requery
End Sub
Private Sub Resistance_Change()
    Modif_Resistance = True
End Sub
Private Sub Reversible_Change()
    Modif_Reversible = True
End Sub
Private Sub Type_Change()
    Modif_Type = True
End Sub
Private Sub Type_Tel_Change()
    Modif_Type_Tel = True
End Sub
