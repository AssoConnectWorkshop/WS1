Attribute VB_Name = "Form_ListeTables"
Attribute VB_Base = "0{F238B85F-075C-423F-A53D-2B0D6B79C823}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database


Private Sub Filtre_OM_Test()
Dim Date_Inv As String
sFiltre = "true"


If cboconduc.Value <> 0 Then
    sFiltre = sFiltre & " and dbo_EvVehicules.conducteur=" & cboconduc
End If

If cboimmat.Value <> 0 Then
    sFiltre = sFiltre & " and dbo_EvVehicules.immat='" & cboimmat & "'"
End If

If cbotypev.Value <> 0 Then
    sFiltre = sFiltre & " and dbo_EvVehicules.TypeEv=" & cbotypev
End If

If Me.CheckVendu = True Then
    sFiltre = sFiltre & " and dbo_Vehicules.EtatVehicule=4"
Else
    sFiltre = sFiltre & " and dbo_Vehicules.EtatVehicule<>4"
End If


If Texte17 <> "" And IsDate(Texte17) Then
    '12/01/24 Pas besion d'inverser la date ???
    Date_Inv = Mid(Me.Texte17, 4, 2) + "/" + Left(Me.Texte17, 2) + "/" + Right(Me.Texte17, 4)
    sFiltre = sFiltre & "  and dbo_EvVehicules.dateev >='" & Me.Texte17 & "'"
End If

If Texte36 <> "" And IsDate(Texte36) Then
   '12/01/24 Pas besion d'inverser la date ???
   Date_Inv = Mid(Me.Texte36, 4, 2) + "/" + Left(Me.Texte36, 2) + "/" + Right(Me.Texte36, 4)
   sFiltre = sFiltre & "  and dbo_EvVehicules.dateev<='" & Me.Texte36 & "'"
End If


'Me.ListeEvVehicules_sous_formulaire.Form.RecordSource = "SELECT * FROM dbo_evvehicules   where " + sFiltre + " Order by DateEv"
Dim Temp As String
Temp = "SELECT dbo_EvVehicules.DateEv, dbo_EvVehicules.Immat, [Utilisateur.Nomuti]+' '+[Utilisateur.Preuti] AS NomComplet, dbo_EvVehicules.Km, dbo_ListeEVVehicule.Evenement_Vehicule FROM ((dbo_EvVehicules INNER JOIN Utilisateur ON dbo_EvVehicules.Conducteur = Utilisateur.numuti) INNER JOIN dbo_ListeEVVehicule ON dbo_EvVehicules.TypeEv = dbo_ListeEVVehicule.Numero) INNER JOIN dbo_Vehicules ON dbo_EvVehicules.Immat = dbo_Vehicules.Immatriculation"
Temp = Temp + " where " + sFiltre + " Order by DateEv desc"
Me.ListeEvVehicules_sous_formulaire.Form.RecordSource = Temp
Me.ListeEvVehicules_sous_formulaire.Form.Filter = sFiltre
Me.ListeEvVehicules_sous_formulaire.Form.FilterOn = False

    
   
End Sub

Private Sub CmdRechercher_Click()
 
    Call Filtre_OM_Test
End Sub


Private Sub Commande58_Click()
On Error GoTo Err_Click
    
    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Saisie_EV_Vehicule"
       
    DoCmd.OpenForm stDocName, , , , acFormAdd, acWindowNormal
Exit_Commande126_Click:
    Exit Sub

Err_Click:
    MsgBox err.Description
    Resume Exit_Commande126_Click
End Sub

Private Sub Commande59_Click()

Resultat = Form_MenuClimAccess.Alerte_Voitures(True)

MessagePourMsGbox = ""
If Resultat(0) <> "" Then
    MessagePourMsGbox = Resultat(0) + vbCrLf + Resultat(1) + vbCrLf
End If
If Resultat(2) <> "" Then
    MessagePourMsGbox = MessagePourMsGbox + Resultat(2) + vbCrLf + Resultat(3) + vbCrLf
End If
If Resultat(4) <> "" Then
    MessagePourMsGbox = MessagePourMsGbox + Resultat(4) + vbCrLf + Resultat(5) + vbCrLf
End If
If Resultat(6) <> "" Then
    MessagePourMsGbox = MessagePourMsGbox + Resultat(6) + vbCrLf + Resultat(7) + vbCrLf
End If
If Resultat(8) <> "" Then
    MessagePourMsGbox = MessagePourMsGbox + Resultat(8) + vbCrLf + Resultat(9) + vbCrLf
End If

If (MessagePourMsGbox = "") Then
    MessagePourMsGbox = "Tout est OK :)!!"
End If

MsgBox "Resultat;" + vbCrLf + MessagePourMsGbox, vbInformation, "Résultat des recherches de problémes"

End Sub

Private Sub Form_Load()
    'Select Case Me.OpenArgs
        'Case "Entretien"
        '    Me.cboTypeIntervention = 1
           '' Call Filtre_OM_Test
        'Case "Maintenance"
        '    Me.cboTypeIntervention = 2
        '    Call Filtre_OM_Test
   ' End Select

    
DoCmd.Maximize
Me.Form.Width = Me.WindowWidth
For Each sf In Me.Controls
    If TypeOf sf Is SubForm Then
        sf.Width = Me.WindowWidth - 567
        sf.Height = Me.WindowHeight - 567 * 5.7
    End If
Next



End Sub


Private Sub CmdFermer_Click()
On Error GoTo Err_CmdFermer_Click


    DoCmd.Close

Exit_CmdFermer_Click:
    Exit Sub

Err_CmdFermer_Click:
    MsgBox err.Description
    Resume Exit_CmdFermer_Click
    
End Sub
Private Sub Commande16_Click()
On Error GoTo Err_Commande16_Click


    DoCmd.RunCommand acCmdRefresh

Exit_Commande16_Click:
    Exit Sub

Err_Commande16_Click:
    MsgBox err.Description
    Resume Exit_Commande16_Click
    
End Sub

Private Sub Form_Resize()
    Me.ListeInterventionGenerale_sous_formulaire.Width = Me.Width
End Sub


Private Sub Option80_GotFocus()
Me.Form_All_Sites.Visible = False
Me.Form_All_Inter.Visible = True
End Sub

Private Sub Option82_GotFocus()
Me.Form_All_Sites.Visible = True
Me.Form_All_Inter.Visible = False
End Sub
