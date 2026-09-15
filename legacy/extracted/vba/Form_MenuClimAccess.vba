Attribute VB_Name = "Form_MenuClimAccess"
Attribute VB_Base = "0{57D99EAD-F54D-4470-AA8F-41F0909D2403}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
'22/04/26 Passage en dbOpenSnapshotpour eviter des locks +Traitement de l'affichage des listes avec Where 1=1 Fait OM

Option Compare Database
Dim NbMaxBoucleAvantUpdateBanane As Integer
Dim NbMaxBoucleAvantRegardeDemWeb As Integer
Dim BoucleAvantRegardeDemWeb As Integer
Dim NbMaxBoucleAvantMAjBubulleas As Integer
Dim BoucleAvantMAjBubulleas As Integer
Dim BoucleAvantUpdateBanane As Integer
Dim RegardeDemandeWeb As Integer

Private Sub Login()
If (NumGestEnCours = -1) Then
    Me.MessageChoixFait.Caption = "Utilisateur Choisi:" + Me.ChoixGest.Text
    NumGestEnCours = Me.ChoixGest.Value
    NomGestEnCours = Me.ChoixGest.Text
    Me.MessageChoixFait.Visible = True
    Me.ChoixGest.Enabled = False
    Me.MessageChoixGest.Visible = False
    Me.Affiche_BP True
End If
End Sub
Private Sub Logout()
If (NumGestEnCours = 0) Then
    'Si 0 perte des ID suite à un Stop dans le VBA
        MsgBox "Perte de l'utilisateur connécté ,merci de vous re-identifier", vbCritical, "Perte ID"
        Me.MessageChoixFait.Caption = "Utilisateur Choisi:Personne"
        NumGestEnCours = -1
        NomGestEnCours = 0
        Me.MessageChoixFait.Visible = False
        Me.ChoixGest.Enabled = True
        Me.MessageChoixGest.Visible = True
        Me.Affiche_BP False
End If
End Sub
Public Sub Affiche_BP(Visible As Boolean)
Me.ImgEntretien.Visible = Visible
Me.Image25.Visible = Visible
Me.Image65.Visible = Visible
Me.Image67.Visible = Visible
Me.Image69.Visible = Visible
Me.Image33.Visible = Visible
Me.Image52.Visible = Visible
Me.Image85.Visible = Visible
Me.Image107.Visible = Visible
Me.Image8.Visible = Visible
Me.Image31.Visible = Visible
Me.Image89.Visible = Visible
Me.Image113.Visible = Visible
Me.Image110.Visible = Visible
Me.imgClient.Visible = Visible
Me.imgParametrage.Visible = Visible
Me.Img_DevisContratDeMaintenance.Visible = Visible
Me.imgDevis.Visible = Visible
Me.imgDevisTravaux.Visible = Visible
Me.ImgDonneur.Visible = Visible
'Fabien ou Pierre
If (NumGestEnCours = 66 Or NumGestEnCours = 65) Then
    Me.Image118.Visible = Visible
    Me.Étiquette119.Visible = Visible
Else
    Me.Image118.Visible = False
    Me.Étiquette119.Visible = False
End If
End Sub

Private Sub ChoixGest_Change()
Login
End Sub

Private Sub ChoixGest_Dirty(Cancel As Integer)
Me.MessageChoixFait = "Utilisateur Choisi:" + Me.ChoixGest.Text
Me.ChoixGest.Visible = False
Me.MessageChoixGest.Visible = False
Me.ImgEntretien.Visible = True
End Sub

Private Sub Commande157_Click()
MAJBubule

End Sub

Private Sub Form_Current()
Me.Affiche_BP False
NumGestEnCours = -1
RefreshTableLinks
Recherche_Si_Envoi_Mail
MAJBubule
UpdateFichierBanane 0
result = Shell("C:\users\public\KillAutoAccess\StartKillAuto.bat", vbMaximizedFocus)
End Sub

Private Sub Recherche_Si_Envoi_Mail()
'Recherche des sites ayant des rappels
Dim Requete As String
Dim DICLient As String
Dim DateDemande As String
Dim NomSite As String
Dim NbMail As Integer
Dim DateJourInv As String
Dim Nb_Devis, Position As Integer

NbMail = 0
Requete = "Select cptsit,refcliint,datheuapp,dateenvoimail,rappel24h,rappel48h,rappel72h,rappelsemaine,numintint from intervention where staint=1 and (rappel24h=1 or rappel48h=1  or rappel72h=1  or rappelsemaine=1 )"
'Close Recordset Fait
'22/04/26 Passage en dbOpenSnapshotpour eviter des locks OM
Set Data_Ref = CurrentDb().OpenRecordset(Requete, dbOpenSnapshot)

While Not Data_Ref.EOF
    
    Dim DateMail As Date
    Dim DateJour As Date
    If (IsNull(Data_Ref(3))) Then
        DateMail = DateTime.Now
        DateMail = DateAdd("yyyy", -1, DateMail)
    Else
        DateMail = Data_Ref(3)
    End If
    
    If (IsNull(Data_Ref(1))) Then
        DICLient = "Non Renseigné"
    Else
        DICLient = Data_Ref(1)
    End If
    
    If (IsNull(Data_Ref(2))) Then
        DateDemande = "Non Renseigné"
    Else
        DateDemande = Data_Ref(2)
    End If
    
    Requete2 = "Select nomsit from site where cptsit=" + Str(Data_Ref(0))
    'Close Recordset Fait
    '22/04/26 Passage en dbOpenSnapshotpour eviter des locks OM
    Set Data_Ref2 = CurrentDb().OpenRecordset(Requete2, dbOpenSnapshot)

    While Not Data_Ref2.EOF
        If (IsNull(Data_Ref2(0))) Then
            NomSite = "Nom Site Non Renseigné"
        Else
            NomSite = Data_Ref2(0)
        End If
        Data_Ref2.MoveNext
    Wend
    'Ajout Close 22/04/26
    Data_Ref2.Close
    
    DateJour = DateTime.Now
    DateJourInv = Str(DateTime.Month(DateJour)) + "/" + Str(DateTime.Day(DateJour)) + "/" + Str(DateTime.Year(DateJour)) + " " + Str(DateTime.Hour(DateJour)) + ":" + Str(DateTime.Minute(DateJour)) + ":" + Str(DateTime.Second(DateJour))
    Dim Ecart_Heures As Integer
    Ecart_Heures = DateDiff("h", DateMail, DateJour)
    If ((Data_Ref(4) = True And Ecart_Heures > 24) Or (Data_Ref(5) = True And Ecart_Heures > 48) Or (Data_Ref(6) = True And Ecart_Heures > 72) Or (Data_Ref(7) = True And Ecart_Heures > 168)) Then
        Rep = EnvoiMail(NomSite, DICLient, DateDemande)
        If Rep = "" Then
            Requete = "Update intervention set dateenvoimail=#" + DateJourInv + "# where numintint=" + Str(Data_Ref(8))
            CurrentDb.Execute Requete, dbSeeChanges
            NbMail = NbMail + 1
        End If
    
    End If
    Data_Ref.MoveNext
Wend
If (NbMail > 0) Then
    MsgBox Str(NbMail) + " Mails de Relance envoyé à sav@fmc-climatisation.fr", vbInformation, "Information"
End If
Data_Ref.Close
Set Data_Ref = Nothing
End Sub

Function EnvoiMail(NomSite As String, DICLient As String, DateDemande) As String
    On Error GoTo Erreur
    Dim MonOutlook As Object
    Dim MonMessage As Object
    Dim Corps As String
    Dim Destinataire As String
 
    Dim EmailApp As Outlook.Application
    Set EmailApp = New Outlook.Application

    Dim EmailItem As Outlook.MailItem
    Set MonMessage = EmailApp.CreateItem(0)
  
    'préparation du message
    Destinataire = "sav@fmc-climatisation.fr"
    MonMessage.To = Trim(Destinataire)
 
    MonMessage.Subject = "Rappel Intervention " + NomSite
    
    Corps = ""
    Corps = Corps + "Site :" + NomSite + vbCrLf
    Corps = Corps + "Numéro DI Client :" + DICLient + vbCrLf
    Corps = Corps + "Date Demande :" + DateDemande + vbCrLf
    MonMessage.body = Corps
 
    'on envoi le message
    MonMessage.send
 
    'on ferme Outlook
    'Set MonOutlook = Nothing
    EnvoiMail = ""
    Exit Function
Erreur:
    EnvoiMail = "Erreur" + vbCrLf
End Function


Public Function RefreshTableLinks() As String


Dim db As Database
Dim tdf As TableDef

Set db = CurrentDb
For Each tdf In db.TableDefs ' ERROR HERE
If Len(tdf.Connect) > 0 Then
'Debug.Print tdf.Connect & " / " & tdf.Name
tdf.Connect = "ODBC;DSN=CLIMACCESS;UID=climaccess;PWD=[REDACTED];APP=Microsoft Office 2010;DATABASE=logiclim"
tdf.RefreshLink
End If
Next tdf
ExitHere:
On Error Resume Next
If intErrorCount > 0 Then
strMsg = "There were errors refreshing the table links: " _
& vbNewLine & strMsg & "In Procedure RefreshTableLinks"
RefreshTableLinks = strMsg
End If
Set tdf = Nothing
Set db = Nothing
Exit Function
End Function
Public Sub MAJBubule()
Dim rs As dao.Recordset
    Dim db As Database
    Dim strSQL As String
 
    Set db = CurrentDb
 
    'Count Query - replace query with your
    'Query of Choice
    strSQL = "SELECT COUNT(*) FROM ListeInterventionGenerale2 where staint=9"
 
    'Set Recordset Query
    
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
 
    'Return Record Count Variable
    RecordCount = rs.Fields(0)
    If RecordCount > 0 Then
        lblNotification.Caption = RecordCount
        lblNotification.Visible = True
        ImgNotification.Visible = True
    Else
        lblNotification.Caption = 0
    End If
    'Close Connections and Reset Variables
    rs.Close
    Set rs = Nothing
    
    
'19/01/23 Gestion Multiples Bulles
    
    Dim NbRouge As Integer
    Dim NbVert As Integer
    Dim NbBleu As Integer
    Dim NbOrange As Integer
    Dim NbNoir As Integer

    
    NbRouge = 0
    NbVert = 0
    NbBleu = 0
    NbOrange = 0
    NbNoir = 0
  
    
    'nbrappint=type facturation
    strSQL = "SELECT COUNT(*)  FROM ListeInterventionGenerale2 where nbrappint=9"
     
    'Set Recordset Query
    'Close Recordset Fait
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
 
    'Return Record Count Variable
    RecordCount = rs.Fields(0)
    If RecordCount > 0 Then
        Me.lblNotificationStandby.Caption = RecordCount
        lblNotificationStandby.Visible = True
        lblNotificationStandby.Visible = True
    Else
        Me.lblNotificationStandby.Caption = 0
    End If
    'Close Connections and Reset Variables
    rs.Close
    Set rs = Nothing
        
    'nbrappint=type facturation
    strSQL = "SELECT typint FROM ListeInterventionGenerale2 where nbrappint=1 or nbrappint=2"
     
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
 
    Do Until rs.EOF
   
  
        Select Case rs.Fields(0)
            Case 1:
                NbBleu = NbBleu + 1
            Case 2:
                NbVert = NbVert + 1
            Case 3:
                NbRouge = NbRouge + 1
            Case 5:
                NbOrange = NbOrange + 1
            Case Else:
                NbNoir = NbNoir + 1
    
        End Select
        rs.MoveNext
    Loop

    lblNotificationRouge.Caption = NbRouge
    lblNotificationVert.Caption = NbVert
    lblNotificationBleu.Caption = NbBleu
    lblNotificationOrange.Caption = NbOrange
    lblNotificationNoir.Caption = NbNoir
    
         
    'Close Connections and Reset Variables
    rs.Close
    Set rs = Nothing
    
    
    '16/03/23 Ajout Materiel a commander
    strSQL = "SELECT COUNT(*) FROM ListeInterventionGenerale2 where staint=-1"
    'Close Recordset Fait
    'Set Recordset Query
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
 
    'Return Record Count Variable
    RecordCount = rs.Fields(0)
    If RecordCount > 0 Then
        Me.lblNotifMatosCommande.Caption = RecordCount
        lblNotifMatosCommande.Visible = True
        ImageNotifMatosCommande.Visible = True
    Else
        Me.lblNotifMatosCommande.Caption = 0
    End If
    'Close Connections and Reset Variables
    rs.Close
    Set rs = Nothing
    
    '16/03/23 Ajout Materiel en attente
    strSQL = "SELECT COUNT(*) FROM ListeInterventionGenerale2 where staint=2"
 
    'Set Recordset Query
    'Close Recordset Fait
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
 
    'Return Record Count Variable
    RecordCount = rs.Fields(0)
    If RecordCount > 0 Then
        Me.lblNotifMatosAttente.Caption = RecordCount
        lblNotifMatosAttente.Visible = True
        ImageNotifMatosAttente.Visible = True
    Else
        Me.lblNotifMatosAttente.Caption = 0
    End If
    'Close Connections and Reset Variables
    rs.Close
    Set rs = Nothing
    
    '16/03/23 Ajout Duplicata
    '27/03/23 Duplicata *2
    strSQL = "SELECT COUNT(*) FROM ListeInterventionGenerale2 where staint=7 and devisafaire=true"
    'Close Recordset Fait
    'Set Recordset Query
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
 
    'Return Record Count Variable
    RecordCount = rs.Fields(0)
    If RecordCount > 0 Then
        Me.lblNotifDuplicataTotal.Caption = RecordCount
        lblNotifDuplicataTotal.Visible = True
        ImageNotifDuplicata.Visible = True
    Else
        Me.lblNotifDuplicataTotal.Caption = 0
    End If
    'Close Connections and Reset Variables
    rs.Close
    Set rs = Nothing
    
    strSQL = "SELECT COUNT(*) FROM ListeInterventionGenerale2 where staint=7 and devisafaire=true and duplicatafait=true"
 
    'Set Recordset Query
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
    'Close Recordset Fait
    'Return Record Count Variable
    RecordCount = rs.Fields(0)
    If RecordCount > 0 Then
        Me.lblNotifDuplicataAFAIRE.Caption = RecordCount
        lblNotifDuplicataAFAIRE.Visible = True
    Else
        Me.lblNotifDuplicataAFAIRE.Caption = 0
    End If
    'Close Connections and Reset Variables
    rs.Close
    Set rs = Nothing
    
    strSQL = "SELECT COUNT(*) FROM ListeInterventionGenerale2 where staint=7 and devisafaire=true and duplicatafait=false"
    'Close Recordset Fait
    'Set Recordset Query
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
 
    'Return Record Count Variable
    RecordCount = rs.Fields(0)
    If RecordCount > 0 Then
        Me.lblNotifDuplicataTrait.Caption = RecordCount
        lblNotifDuplicataTrait.Visible = True
    Else
        Me.lblNotifDuplicataTrait.Caption = 0
    End If
    'Close Connections and Reset Variables
    rs.Close
    Set rs = Nothing
    
    strSQL = "SELECT COUNT(*) FROM ListeInterventionGenerale2 where nbrappint=8"
 
    'Set Recordset Query
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
    'Close Recordset Fait
    'Return Record Count Variable
    RecordCount = rs.Fields(0)
    If RecordCount > 0 Then
        Me.lblNotificationBoss.Caption = RecordCount
        lblNotificationBoss.Visible = True
    Else
        Me.lblNotificationBoss.Caption = 0
    End If
    'Close Connections and Reset Variables
    rs.Close
    Set rs = Nothing
    Alerte_Voitures (False)
    
    Set db = Nothing

End Sub

Function Alerte_Voitures(AvecResultat As Boolean) As String()
    Dim Temp As String
    Dim Nb_Erreur_CC As Integer
    Dim Nb_Erreur_CT As Integer
    Dim Nb_Erreur_Garantie As Integer
    Dim Nb_Erreur_Leasing As Integer
    Dim Nb_Erreur_Rev As Integer
    Dim Reponse(10) As String
    Nb_Erreur_Rev = 0
    Nb_Erreur_Leasing = 0
    Nb_Erreur_Garantie = 0
    Nb_Erreur_CC = 0
    Nb_Erreur_CT = 0
    Dim RsCodInt As Recordset
    
    '26/04/24 Init
    For i = 1 To 10
        Reponse(i) = ""
    Next i
    
    Requete = "select * from dbo_vehicules where EtatVehicule<>4 and  EtatVehicule<>5 order by Immatriculation  "
    'dbOpenSnapshot Pas de modif possible
    'Close Effectué
    Set RsCodInt = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
    Do Until RsCodInt.EOF
    'Recherche de chaque immat
       Immat = RsCodInt("Immatriculation")
       Immat = Trim(Immat)
       
       
       EtatVehicule = RsCodInt("EtatVehicule")

           
       If IsNull(RsCodInt("DateMiseCirculation")) = False Then
            Temp = RsCodInt("DateMiseCirculation")
            '29/03/24 Pierre et Moi ->2015-06-01 autres PC ->06/01/2015
            If (InStr(1, Temp, "-", vbTextCompare) <> 0) Then
                DateMiseCirculation = MiseFormeDateLecture(Temp)
            Else
                DateMiseCirculation = Temp
            End If
       End If
       
       Km_Inter_Revision = RsCodInt("Km_Inter_Revision")
       Temps_Mois_Inter_Revision = RsCodInt("Temps_Mois_Inter_Revision")
       Nb_KM_Garantie = RsCodInt("Nb_KM_Garantie")
       Temps_Mois_Garantie = RsCodInt("Temps_Mois_Garantie")
       Nb_Km_Leasing = RsCodInt("Nb_Km_Leasing")
       Temps_Mois_Leasing = RsCodInt("Temps_Mois_Leasing")
       Garantie = RsCodInt("Garantie")
       Leasing = RsCodInt("leasing")
       If IsNull(RsCodInt("Date_Fin_Leasing")) = False Then
            Temp = RsCodInt("Date_Fin_Leasing")
            If (InStr(1, Temp, "-", vbTextCompare) <> 0) Then
                Date_Fin_Leasing = MiseFormeDateLecture(Temp)
            Else
                Date_Fin_Leasing = Temp
            End If
       End If
    
              
        'Recherche par rapport aux Evenements
        Requete = "select * from dbo_evvehicules where Immat='" + Immat + "'"
        'dbOpenSnapshot Pas de modif possible
        'Close Effectué
        Set RsEvVehicules = CurrentDb.OpenRecordset(Requete, dbOpenSnapshot)
        Dim KmMaxRev As Double
        Dim KmMaxCT As Double
        Dim KmMaxCC As Double
        Dim KMSaisie As Double
        Dim KmMaxReleve As Double
        
        KmMaxRev = 0
        KmMaxCT = 0
        KmMaxCC = 0
        KMSaisie = 0
        KmMaxReleve = 0
        Date_Dernier_CC = ""
        Date_Dernier_CT = ""
        Date_Dernier_Entretien = ""
        Do Until RsEvVehicules.EOF
                
            If IsNull(RsEvVehicules("TypeEv")) = False Then
                If IsNull(RsEvVehicules("Km")) = False Then
                    KMSaisie = RsEvVehicules("Km")
                    'Revision
                    If (RsEvVehicules("TypeEv") = 2) Then
                        If (KmMaxRev < KMSaisie) Then
                            KmMaxRev = KMSaisie
                            If IsNull(RsEvVehicules("DateEv")) = False Then
                                Date_Dernier_Entretien = RsEvVehicules("DateEv")
                            End If
                        End If
                    End If
                       
                    'Controle Technique
                    If (RsEvVehicules("TypeEv") = 3) Then
                        If (KmMaxCT < KMSaisie) Then
                            KmMaxCT = KMSaisie
                            If IsNull(RsEvVehicules("DateEv")) = False Then
                                Date_Dernier_CT = RsEvVehicules("DateEv")
                            End If
                        End If
                    End If
                    
                    'Controle Complementaire
                    If (RsEvVehicules("TypeEv") = 4) Then
                        If (KmMaxCC < KMSaisie) Then
                            KmMaxCC = KMSaisie
                            If IsNull(RsEvVehicules("DateEv")) = False Then
                                Date_Dernier_CC = RsEvVehicules("DateEv")
                            End If
                        End If
                    End If
                    
                    'Releve KM
                    If (RsEvVehicules("TypeEv") = 1 Or RsEvVehicules("TypeEv") = 5) Then
                        If (KmMaxReleve < KMSaisie) Then
                            KmMaxReleve = KMSaisie
                            If IsNull(RsEvVehicules("DateEv")) = False Then
                                Date_Dernier_Releve_KM = RsEvVehicules("DateEv")
                            End If
                        End If
                    End If
                       
                       
                End If
            End If
        RsEvVehicules.MoveNext
       Loop
            
        'Erreur Date CT
        If (Date_Dernier_CT <> "") Then
            Intervalle_mois_CT = DateDiff("m", Date_Dernier_CT, DateTime.Now)
            If Intervalle_mois_CT > 24 Then
                Nb_Erreur_CT = Nb_Erreur_CT + 1
                Reponse(0) = "Voiture(s) avec probleme de controle technique:"
                Reponse(1) = Reponse(1) + "  " + Immat
            End If
        End If
        
        'Erreur Date CC
        If (Date_Dernier_CC <> "") Then
            Date_Compar = Date_Dernier_CC
            'On prends dans ce cas la le plus recent entre le Ct et le CC
            If (Date_Dernier_CT <> "") Then
                If (Date_Dernier_CT > Date_Dernier_CC) Then
                '03/09/24 Modif avant on signait l'erreur
                    Date_Compar = Date_Dernier_CT
                End If
            End If
        
            Intervalle_mois_CC = DateDiff("m", Date_Compar, DateTime.Now)
            If Intervalle_mois_CC > 12 Then
                Nb_Erreur_CC = Nb_Erreur_CC + 1
                Reponse(2) = "Voiture(s) avec probleme de controle complementaire:"
                Reponse(3) = Reponse(3) + "  " + Immat
            End If
        End If
        
        'Erreur Revision
        If (KmMaxReleve <> 0 And KmMaxRev <> 0) Then
            Km_Parcouru = KmMaxReleve - KmMaxRev
            'Erreur KM
            If Km_Parcouru > Km_Inter_Revision Then
                Nb_Erreur_Rev = Nb_Erreur_Rev + 1
                Reponse(4) = "Voiture(s) avec probleme de revision:"
                Reponse(5) = Reponse(5) + "  " + Immat
            Else
                If (Date_Dernier_Entretien <> "" And Date_Dernier_Releve_KM <> "") Then
                    'Erreur Temps
                    Intervalle_mois_Rev = Abs(DateDiff("m", Date_Dernier_Releve_KM, Date_Dernier_Entretien))
                    If Intervalle_mois_Rev > Temps_Mois_Inter_Revision Then
                        Nb_Erreur_Rev = Nb_Erreur_Rev + 1
                        Reponse(4) = "Voiture(s) avec probleme de revision:"
                        Reponse(5) = Reponse(5) + "  " + Immat
                    End If
                End If
            End If
        End If
        
        'Erreur Leasing
        If (Leasing = True) Then
            If IsNull(RsCodInt("Date_Fin_Leasing")) = False Then
                If (DateTime.Now > Date_Fin_Leasing) Then
                    Nb_Erreur_Leasing = Nb_Erreur_Leasing + 1
                    Reponse(6) = "Voiture(s) avec probleme de leasing:"
                    Reponse(7) = Reponse(7) + "  " + Immat
                    GoTo suite:
                End If
            Else
                If IsNull(RsCodInt("DateMiseCirculation")) = False Then
                    Intervalle_mois_Leasing = DateDiff("m", DateMiseCirculation, DateTime.Now)
                    If (Intervalle_mois_Leasing > Temps_Mois_Leasing) Then
                        Nb_Erreur_Leasing = Nb_Erreur_Leasing + 1
                        Reponse(6) = "Voiture(s) avec probleme de leasing:"
                        Reponse(7) = Reponse(7) + "  " + Immat
                    End If
                End If
            End If
        End If
suite:
         'Erreur Garantie
        If (Garantie = True) Then
            If IsNull(RsCodInt("DateMiseCirculation")) = False Then
                Intervalle_mois_Garantie = DateDiff("m", DateMiseCirculation, DateTime.Now)
                If (Intervalle_mois_Garantie > Temps_Mois_Garantie) Then
                    Nb_Erreur_Garantie = Nb_Erreur_Garantie + 1
                    Reponse(8) = "Voiture(s) avec probleme de garantie:"
                    Reponse(9) = Reponse(9) + "  " + Immat
                End If
            End If
        End If
                            
       RsCodInt.MoveNext
    Loop
    Me.lblNotificationCT.Caption = Nb_Erreur_CT
    Me.lblNotificationCC.Caption = Nb_Erreur_CC
    Me.lblNotificationLeasing.Caption = Nb_Erreur_Leasing
    Me.lblNotificationGarantie.Caption = Nb_Erreur_Garantie
    Me.lblNotificationRevision.Caption = Nb_Erreur_Rev
    
    Alerte_Voitures = Reponse
    RsCodInt.Close
    Set RsCodInt = Nothing
    RsEvVehicules.Close
    Set RsEvVehicules = Nothing
End Function

    
Public Function MiseFormeDateLecture(DataAvant As String) As String
Jour = Mid(DataAvant, 9, 2)
Mois = Mid(DataAvant, 6, 2)
Annee = Mid(DataAvant, 3, 2)
MiseFormeDateLecture = Jour + "/" + Mois + "/" + Annee
End Function
Private Sub Form_Timer()
NbMaxBoucleAvantMAjBubulleas = 60
NbMaxBoucleAvantUpdateBanane = 6
NbMaxBoucleAvantRegardeDemWeb = 2
BoucleAvantMAjBubulleas = BoucleAvantMAjBubulleas + 1
BoucleAvantUpdateBanane = BoucleAvantUpdateBanane + 1
BoucleAvantRegardeDemWeb = BoucleAvantRegardeDemWeb + 1

'28/11/25 Passage du Timer à 1 Seconde et donc creation des variables pour Bananes
'         Creation des demandes Web

If (BoucleAvantMAjBubulleas >= NbMaxBoucleAvantMAjBubulleas) Then
    MAJBubule
    BoucleAvantMAjBubulleas = 0
End If

If (BoucleAvantUpdateBanane >= NbMaxBoucleAvantUpdateBanane) Then
    Logout
    UpdateFichierBanane 0
    BoucleAvantUpdateBanane = 0
End If
If (BoucleAvantRegardeDemWeb >= NbMaxBoucleAvantRegardeDemWeb) Then
    If (RegardeDemandeWeb <> -1 And NumGestEnCours <> 0 And NumGestEnCours <> -1) Then
        TraiteDemandeWeb
    End If
    BoucleAvantRegardeDemWeb = 0
End If
End Sub
Public Sub TraiteDemandeWeb()
    Dim Data_Ref As Recordset
    'RegardeDemandeWeb=0 ->On ne sait pas
    'RegardeDemandeWeb=-1 ->N'existe pas pour le Login actuel donc on ne regarde plus
    'RegardeDemandeWeb= 1  ->Le login existe donc on va regarder
    '22/04/26 Passage en dbOpenSnapshotpour eviter des locks OM
    Requete = "select * from  Dbo_Demande_Web where NumUser=" + Str(NumGestEnCours)
    '22/04/26 Passage en dbOpenSnapshotpour eviter des locks OM
    Set Data_Ref = CurrentDb().OpenRecordset(Requete, dbOpenSnapshot)
    If (Data_Ref.RecordCount = 0) Then
        RegardeDemandeWeb = -1
    Else
        
        If (Data_Ref("Type_Demande").Value <> 0) Then
            'Demande en Cours
            Select Case Data_Ref("Type_Demande").Value
                'Affichage Inter
                Case 1
                    'DoCmd.OpenForm "Intervention", acNormal, "", "numintint=" & Data_Ref("Data1").Value, acFormEdit, acWindowNormal ' code Alain
                    DoCmd.OpenForm "Site", acNormal, , "cptsit=" & Data_Ref("Data2").Value, acFormEdit
            End Select
            'Effacement Demande
            CurrentDb.Execute ("UPDATE Dbo_Demande_Web Set Type_Demande=0,Data1=0,Data2=0,Data3=''" + "where NumUser=" + Str(NumGestEnCours))
        End If
    End If
    Data_Ref.Close
    Set Data_Ref = Nothing
End Sub




Private Sub Image107_Click()
  On Error GoTo Err_Stats_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Filtre Extraction"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_Err_Stats_Click:
    Exit Sub

Err_Stats_Click:
    MsgBox err.Description
    Resume Exit_Err_Stats_Click

End Sub



Private Sub Image110_Click()
If (NumGestEnCours <> 367) Then
    MsgBox "Vous n'etes pas identifié en tant que Kadi donc pas de saisie de mot de passe :)", vbCritical, "Acces Interdit"
     Kadi_Logge = False
    Kadi.Visible = False
Else
    Rep = InputBox("Bonjour Kadi,Merci de saisir le mot de passe afin de s'identifier")
    If (Rep <> "0301") Then
        Rep = MsgBox("Mauvais Mot de passe", vbOKOnly + vbCritical, "Erreur")
        Kadi_Logge = False
        Kadi.Visible = False
    Else
        Kadi_Logge = True
        Kadi.Visible = True
    End If
End If
End Sub

Private Sub Image113_Click()
On Error GoTo Err_ImgInterventionAValider_Click

    Dim stDocName As String
    Dim stLinkCriteria As String
    
    stDocName = "ListeInterGaz"
    
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , Critere
    
Exit_Err_ImgInterventionAValider_Click:
    Exit Sub

Err_ImgInterventionAValider_Click:
    MsgBox err.Description
    Resume Exit_Err_ImgInterventionAValider_Click
End Sub

Private Sub Image118_Click()
On Error GoTo Err_ImgInterventionAValider_Click

    Dim stDocName As String
    Dim stLinkCriteria As String
    Dim Critere As String

    stDocName = "ListeTables"
    
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , Critere
    
Exit_Err_ImgInterventionAValider_Click:
    Exit Sub

Err_ImgInterventionAValider_Click:
    MsgBox err.Description
    Resume Exit_Err_ImgInterventionAValider_Click
End Sub

Private Sub Image25_Click()

   On Error GoTo Err_ImgSite_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "ListeSiteGenerale"
    DoCmd.OpenForm stDocName, acNormal, , stLinkCriteria

Exit_ImgSite_Click:
    Exit Sub

Err_ImgSite_Click:
    MsgBox err.Description
    Resume Exit_ImgSite_Click


End Sub

Private Sub Image27_Click()
    DoCmd.OpenForm "Carte", acNormal, , , , acDialog
End Sub

Private Sub Image31_Click()
    DoCmd.OpenForm "FiltreInterventionsMobiles", acNormal, , , , acDialog
End Sub

Private Sub Image33_Click()
    ChargementListeInter "AValider"
End Sub

Private Sub Image51_Click()

End Sub

Private Sub ChargementListeInter(Critere As String)
On Error GoTo Err_ImgInterventionAValider_Click

    Dim stDocName As String
    Dim stLinkCriteria As String
    
    DoCmd.OpenForm "chargement"

    stDocName = "ListeInterventionGenerale"
    
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , Critere
    
Exit_Err_ImgInterventionAValider_Click:
    Exit Sub

Err_ImgInterventionAValider_Click:
    MsgBox err.Description
    Resume Exit_Err_ImgInterventionAValider_Click
End Sub


Private Sub Image52_Click()
    ChargementListeInter "AFacturer"
End Sub

Private Sub Image65_Click()
    ChargementListeInter "Duplicata"
End Sub

Private Sub Image67_Click()
    ChargementListeInter "ACommander"
End Sub

Private Sub Image69_Click()
    ChargementListeInter "AttenteMatos"
End Sub

Private Sub Image8_Click()

   On Error GoTo Err_Stats_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "00 - Statistiques Clients"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_Err_Stats_Click:
    Exit Sub

Err_Stats_Click:
    MsgBox err.Description
    Resume Exit_Err_Stats_Click


End Sub

Private Sub Image85_Click()
ChargementListeInter "AvaliderFabien"
End Sub

Private Sub Image89_Click()
On Error GoTo Err_ImgInterventionAValider_Click

    Dim stDocName As String
    Dim stLinkCriteria As String
    Dim Critere As String

    stDocName = "ListeEvvehicules"
    
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , Critere
    
Exit_Err_ImgInterventionAValider_Click:
    Exit Sub

Err_ImgInterventionAValider_Click:
    MsgBox err.Description
    Resume Exit_Err_ImgInterventionAValider_Click
End Sub

Private Sub Img_DevisContratDeMaintenance_Click()
On Error GoTo Err_Img_DevisContratDeMaintenance_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "DevisListeContratDeMaintenance"
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "Entretien"

Exit_Img_DevisContratDeMaintenance_Click:
    Exit Sub

Err_Img_DevisContratDeMaintenance_Click:
    MsgBox err.Description
    Resume Exit_Img_DevisContratDeMaintenance_Click

End Sub

Private Sub ImgAuditASaisir_Click()

   On Error GoTo Err_ImgAuditASaisir_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Audit"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_ImgAuditASaisir_Click:
    Exit Sub

Err_ImgAuditASaisir_Click:
    MsgBox err.Description
    Resume Exit_ImgAuditASaisir_Click

End Sub

Private Sub imgClient_Click()
    On Error GoTo Err_imgClient_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Listeclientaffiche"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_imgClient_Click:
    Exit Sub

Err_imgClient_Click:
    MsgBox err.Description
    Resume Exit_imgClient_Click
    
End Sub


Private Sub imgDevis_Click()
On Error GoTo Err_imgDevis_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "DevisListe"
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "Entretien"

Exit_imgDevis_Click:
    Exit Sub

Err_imgDevis_Click:
    MsgBox err.Description
    Resume Exit_imgDevis_Click

End Sub

Private Sub imgDevisTravaux_Click()
On Error GoTo Err_imgDevisTravaux_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "DevisListeTravaux"
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "Entretien"

Exit_imgDevisTravaux_Click:
    Exit Sub

Err_imgDevisTravaux_Click:
    MsgBox err.Description
    Resume Exit_imgDevisTravaux_Click

End Sub

Private Sub ImgDonneur_Click()
    On Error GoTo Err_ImgDonneur_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "ListeSousTraitGenerale"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_ImgDonneur_Click:
    Exit Sub

Err_ImgDonneur_Click:
    MsgBox err.Description
    Resume Exit_ImgDonneur_Click
End Sub

Private Sub ImgEntretien_Click()
On Error GoTo Err_ImgEntretien_Click

    Dim stDocName As String
    Dim stLinkCriteria As String
    
    DoCmd.OpenForm "chargement"

    stDocName = "ListeInterventionGenerale"
    
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "AValider"
    
Exit_ImgEntretien_Click:
    Exit Sub

Err_ImgEntretien_Click:
    MsgBox err.Description
    Resume Exit_ImgEntretien_Click
End Sub

Private Sub ImgIntervention_Click()
    On Error GoTo Err_ImgIntervention_Click

    Dim stDocName As String
    Dim stLinkCriteria As String
    
    DoCmd.OpenForm "chargement"
    
    stDocName = "ListeInterventionGenerale"
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "Maintenance"

Exit_ImgIntervention_Click:
    Exit Sub

Err_ImgIntervention_Click:
    MsgBox err.Description
    Resume Exit_ImgIntervention_Click

End Sub

Private Sub ImgMenuPrincipal_Click()
    stDocName = "MenuPrincipal"
    DoCmd.OpenForm stDocName, , , , , , "MenuPrincipal"
End Sub

Private Sub imgParametrage_Click()
    On Error GoTo Err_imgParametrage_Click

    Dim stDocName As String
    Dim stLinkCriteria As String

    stDocName = "Parametrage"
    DoCmd.OpenForm stDocName, , , stLinkCriteria

Exit_imgParametrage_Click:
    Exit Sub

Err_imgParametrage_Click:
    MsgBox err.Description
    Resume Exit_imgParametrage_Click
End Sub

Private Sub ImgSuiteDevis_Click()
On Error GoTo Err_ImgSuiteDevis_Click

    Dim stDocName As String
    Dim stLinkCriteria As String
    
    DoCmd.OpenForm "chargement"

    stDocName = "ListeInterventionGenerale"
    DoCmd.OpenForm stDocName, , , stLinkCriteria, , , "SuiteDevis"

Exit_ImgSuiteDevis_Click:
    Exit Sub

Err_ImgSuiteDevis_Click:
    MsgBox err.Description
    Resume Exit_ImgSuiteDevis_Click
End Sub
Private Sub Commande37_Click()
On Error GoTo Err_Commande37_Click


    DoCmd.GoToRecord , , acLast

Exit_Commande37_Click:
    Exit Sub

Err_Commande37_Click:
    MsgBox err.Description
    Resume Exit_Commande37_Click
    
End Sub
