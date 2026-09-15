Attribute VB_Name = "Form_ListeKM"
Attribute VB_Base = "0{6A34EDF8-BC7E-4591-B56E-82134D4F00EA}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub CmdRechercher_Click()
   Dim Date_Inv As String
sFiltre = ""
If cboClient.Value <> 0 Then
    sFiltre = "dbo_HeuresTech.numerotech=" & cboClient
Else
    sFiltre = " True "
End If

If Texte17 <> "" And IsDate(Texte17) Then
    'Pas besoin d'version de date mais on laisse au cas ou
    'Date_Inv = Mid(Me.Texte17, 4, 2) + "/" + Left(Me.Texte17, 2) + "/" + Right(Me.Texte17, 4)
    'sFiltre = sFiltre & "  and dbo_HeuresTech.DateInterv >='" & Date_Inv & "'"
    sFiltre = sFiltre & "  and dbo_HeuresTech.DateInterv >='" & Me.Texte17 & "'"
End If

If Texte36 <> "" And IsDate(Texte36) Then
   'Pas besoin d'version de date mais on laisse au cas ou
   'Date_Inv = Mid(Me.Texte36, 4, 2) + "/" + Left(Me.Texte36, 2) + "/" + Right(Me.Texte36, 4)
   'sFiltre = sFiltre & "  and dbo_HeuresTech.DateInterv <='" & Date_Inv & "'"
    sFiltre = sFiltre & "  and dbo_HeuresTech.DateInterv <='" & Texte36 & "'"
End If

Dim SQL As String

    'ListeInterventionGenerale_sous_formulaire.Form.RecordSource = "SELECT dbo_HeuresTech.DateInterv, nomuti+' '+preuti AS Nom, dbo_HeuresTech.nominterv FROM Utilisateur INNER JOIN dbo_HeuresTech ON Utilisateur.numuti = dbo_HeuresTech.numerotech WHERE (((dbo_HeuresTech.TypeInterv)=60))"
    
    
    If sFiltre <> "" Then
        Requete = "SELECT dbo_HeuresTech.DateInterv, nomuti+' '+preuti AS Nom, dbo_HeuresTech.nominterv FROM Utilisateur INNER JOIN dbo_HeuresTech ON Utilisateur.numuti = dbo_HeuresTech.numerotech WHERE (dbo_HeuresTech.TypeInterv=60 and " + sFiltre + ")"
        Form_ResultatListeKM.Form.Form.RecordSource = Requete
    End If
    
    If sFiltre <> "" Then
        Form_ResultatListeKM.Form.Filter = sFiltre
        Form_ResultatListeKM.Form.FilterOn = False
    End If
    Form_ResultatListeKM.Requery
    
   
End Sub


Private Sub Form_Load()
    
    
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



