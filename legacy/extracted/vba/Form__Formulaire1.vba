Attribute VB_Name = "Form__Formulaire1"
Attribute VB_Base = "0{897F1019-E384-4F32-A38A-24CFA030D092}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Public Sub SendMail2(ByVal strEmail As String, _
  ByVal strObj As String, _
  ByVal strMsg As String, _
  ByVal blnEdit As Boolean)
On Error Resume Next
DoCmd.SendObject acSendNoObject, , , strEmail, , , strObj, strMsg, blnEdit
End Sub
Private Sub Commande1_Click()
      
Dim strDest As String       ' L'adresse e-mail du destinataire
Dim strMessage As String    ' Le corps du message
 
' Création du corps du message
strMessage = "Voici un petit exemple illustrant la"
strMessage = strMessage & vbCrLf & "la possibilité d'expédier un e-mail"
strMessage = strMessage & vbCrLf & "depuis Microsoft Access."
strMessage = strMessage & vbCrLf & vbCrLf & "Hervé Inisan"
strMessage = strMessage & vbCrLf & "http://www.self-access.com"
 
' On demande l'adresse e-mail du destinataire
strDest = InputBox("Tapez une adresse e-mail existante : ", _
  "Fin d'intervention", _
  "[email-perso-masqué]")
If strDest = "" Then Exit Sub
 
' Envoi du message
SendMail2 strDest, _
  "Fin d'intervention", _
  strMessage, _
  True

    
End Sub
Private Sub Commande4_Click()
On Error GoTo Err_Commande4_Click


    If Me.Dirty Then Me.Dirty = False
    DoCmd.Close

Exit_Commande4_Click:
    Exit Sub

Err_Commande4_Click:
    MsgBox err.Description
    Resume Exit_Commande4_Click
    
End Sub
