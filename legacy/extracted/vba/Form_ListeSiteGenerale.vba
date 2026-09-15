Attribute VB_Name = "Form_ListeSiteGenerale"
Attribute VB_Base = "0{3D6D04ED-9AF3-41BA-9D30-166D19D87691}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
'22/04/26 Passage en dbOpenSnapshotpour eviter des locks +Traitement de l'affichage des listes avec Where 1=1 FaitOM
Option Compare Database
Dim TexteNumSite As String

Private Sub cboClient_AfterUpdate()
 Call Filtrer

End Sub
Private Sub Filtrer()

Dim UnFiltre As Boolean
Dim FiltreJoin As Boolean
Dim sFiltre As String
Dim TexteJoin As String

sFiltre = ""
'10/11/25 Ajout Invest

'26/04/24 Si choix Ne pas intervenir dans les Inter on va d'abord chercher tous les sites concernés
If (Me.coche_intervenir_Avec_Inter = True) Then

    Dim rs As Recordset
    Set rs = CurrentDb.OpenRecordset("select distinct cptsit from Intervention where Intervention.staint=17", dbOpenSnapshot)
    Do Until rs.EOF
        
        If (sFiltre = "") Then
            sFiltre = " ( cptsit=" & rs(0)
        Else
            sFiltre = sFiltre + " or cptsit=" & rs(0)
        End If
           
        rs.MoveNext
    Loop
    rs.Close
    Set rs = Nothing
    sFiltre = sFiltre + ") "
    UnFiltre = True
    
End If


If Not IsNull(cboClient.Value) Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "[numcli]=" & cboClient
    UnFiltre = True
End If

If ChkSansLongitudeLatitude.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "([longitude] is null OR [latitude] is null)"
    UnFiltre = True
End If

'10/11/25 Ajout Invest
If Me.CocherInvest.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "([Invest] is not null and [Invest]=1)"
    UnFiltre = True
End If
If Me.CocherInvest.Value = False Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "([Invest] is not null and [Invest]=0)"
    UnFiltre = True
End If


'La colonne misajoursecurite correspond au paiement en retard
If Me.CocherRetard.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "([misajoursecurite] is not null and [misajoursecurite]=1)"
    UnFiltre = True
End If

'26/04/24 Ajout du cas False
'La colonne misajoursecurite correspond au paiement en retard
If Me.CocherRetard.Value = False Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "([misajoursecurite] is not null and [misajoursecurite]=0)"
    UnFiltre = True
End If

'La colonne majregistresecuritefait correspond a ne pas intervenir
If Me.coche_intervenir.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "([majregistresecuritefait] is not null and [majregistresecuritefait]=1)"
    UnFiltre = True
End If


'26/04/24 Ajout du cas False
'La colonne majregistresecuritefait correspond a ne pas intervenir
If Me.coche_intervenir.Value = False Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "([majregistresecuritefait] is not null and [majregistresecuritefait]=0)"
    UnFiltre = True
End If


'La colonne demixasit correspond a Particulier
If Me.CocherParticulier.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "([demixasit] is not null and [demixasit]=1)"
    UnFiltre = True
End If

'26/04/24 Ajout du cas False
'La colonne demixasit correspond a Particulier
If Me.CocherParticulier.Value = False Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "([demixasit] is not null and [demixasit]=0)"
    UnFiltre = True
End If

If ChkNonRooftop.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "([precisiongeo]<>'ROOFTOP' or [precisiongeo] is null)"
    UnFiltre = True
End If

If txtrefliint <> "" Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & " cptsit in (select cptsit from intervention where refcliint like '%" & txtrefliint & "%')"
    UnFiltre = True
End If

Dim numsit As String
numsit = ""


If TexteNumSite <> "" Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    numsit = TexteNumSite
    sFiltre = sFiltre & " ((nomsit like '%" & numsit & "%')"
    If IsNumeric(TexteNumSite) Then
        sFiltre = sFiltre & " OR (numsit = " & numsit & ")"
    End If
    If Not IsNull(cboClient) Then
        sFiltre = sFiltre & ") AND numcli=" & cboClient
    Else
        sFiltre = sFiltre & ")"
    End If
    UnFiltre = True
    CboNumSit.SetFocus
End If

If Me.RefMat <> "" Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    UnFiltre = True
    sFiltre = sFiltre & " (SiteMateriel.reference like '%" & RefMat & "%')"
    FiltreJoin = True
    TexteJoin = " inner join SiteMateriel on SiteMateriel.numerosite=site.cptsit "
Else
    TexteJoin = ""
End If

If IsNull(Me.ChkCE.Value) = False Then
    If Me.ChkCE Then
        If UnFiltre Then
            sFiltre = sFiltre & " AND "
        End If
        UnFiltre = True
        sFiltre = sFiltre & " (SiteMateriel.CE_EDITE=0 and YEAR(SiteMateriel.DateCE)=" + Format(Date, "yyyy") + ")"
        FiltreJoin = True
        TexteJoin = " inner join SiteMateriel on SiteMateriel.numerosite=site.cptsit "
    End If
End If



'22/06/20 ListeSite Non Modif
If IsNull(Me.ChkModification.Value) = False Then
    If Me.ChkModification Then
        Me.SiteListe.Form.RecordSource = "SELECT * FROM ListeSite2"
    Else
        Me.SiteListe.Form.RecordSource = "SELECT * FROM ListeSite"
    End If
Else
    Me.SiteListe.Form.RecordSource = "SELECT * FROM ListeSite"
End If


If UnFiltre Then
    '17/04/20 Changement du principe Envoi requete car sinon n'affiche pas forcement le resultat OM
    Dim SQL As String
    If sFiltre <> "" And Not FiltreJoin Then
        Me.SiteListe.Form.RecordSource = Me.SiteListe.Form.RecordSource + " where " + sFiltre
    Else
        'NOTA COMSIT ne peut etre cherché car le type est ntext
        Requete = "select cptsit,numsit,numcli,codsit,nomsit,nomsocsit,sitsit,typsit,adrsit,codpossit,vilsit,telsit,faxsit,civres,nomres,preres,numzonsit,surven,surtot,nbrentsit,nbrdesenfsit,datdervisdes,telcencom,datcresit,mntredev,montantredevancefiltre,datprisencharge,donneurid,numintervenant,numerocontratclient,numerocontratdesenfumage,nombrevisitedesenfumage,montantredevancedesenfumage,datedesenfumage,NumSousTraitDesenfum,NumSousTraitClim,chemindoc,TarifSousTraitChaudiere,TarifSousTraitClim,NumContratChaudiere,NombreContratChaudiere,mntredevContratChaudiere,DateContratChaudiere,NumSousTraitChaudiere,TarifSousTraitDesenfum from site " + TexteJoin + " where " + sFiltre + " group by "
        Requete = Requete + " cptsit , numsit, numcli, codsit, nomsit, nomsocsit, sitsit, typsit, adrsit, codpossit, vilsit, telsit, faxsit, civres, nomres, preres, numzonsit, surven, surtot, nbrentsit, nbrdesenfsit, datdervisdes, telcencom, datcresit, mntredev, montantredevancefiltre, datprisencharge, donneurid, numintervenant, numerocontratclient, numerocontratdesenfumage, nombrevisitedesenfumage, montantredevancedesenfumage, datedesenfumage, NumSousTraitDesenfum, NumSousTraitClim, chemindoc, TarifSousTraitChaudiere, TarifSousTraitClim, NumContratChaudiere, NombreContratChaudiere, mntredevContratChaudiere, DateContratChaudiere, NumSousTraitChaudiere, TarifSousTraitDesenfum"
        Me.SiteListe.Form.RecordSource = Requete
    End If
    Me.SiteListe.Requery
    
    'Me.SiteListe.Form.Filter = sFiltre
    'Me.SiteListe.Form.FilterOn = True
End If



End Sub

Private Sub cboClient_KeyDown(KeyCode As Integer, Shift As Integer)
cboClient.Dropdown
End Sub

Private Sub CboCode_AfterUpdate()
    Dim SQL As String
    SQL = "SELECT * FROM ListeSite where (codsit like '*" & CboCode & "*')"
    If Not IsNull(cboClient) Then
            SQL = SQL + " AND numcli=" & cboClient
    End If
    Me.SiteListe.Form.RecordSource = SQL
    Me.SiteListe.Requery
End Sub

Private Sub CboCode_KeyDown(KeyCode As Integer, Shift As Integer)
 If KeyCode = vbKeyReturn Then
    Dim SQL As String
    SQL = "SELECT * FROM ListeSite where (codsit like '*" & CboCode & "*')"
    If Not IsNull(cboClient) Then
            SQL = SQL + " AND numcli=" & cboClient
    End If
    Me.SiteListe.Form.RecordSource = SQL
    Me.SiteListe.Requery
 End If
End Sub

Private Sub CboNumSit_AfterUpdate()
    Call Filtrer
End Sub

Private Sub CboNumSit_Change()
TexteNumSite = CboNumSit.Text
End Sub

Private Sub CboNumSit_KeyDown(KeyCode As Integer, Shift As Integer)
    
    If KeyCode = vbKeyReturn Then
    
        If CboNumSit <> "" Then
            Call Filtrer
            'CboNumSit.SetFocus
        Else
            If (CboNumSit.Text <> "") Then
                Call Filtrer
                'CboNumSit.SetFocus
           End If
        End If
    'CboNumSit.SetFocus
    End If
End Sub



Private Sub ChkCE_AfterUpdate()
    Call Filtrer
End Sub

Private Sub ChkModification_Click()
'22/06/20 Modif OM ->Traitement dans Filtrer
Call Filtrer
' If Forms![ListeSiteGenerale].[SiteListe].Form.RecordSource = "ListeSite2" Then
'        Forms![ListeSiteGenerale].[SiteListe].Form.RecordSource = "ListeSite"
'        Call Filtrer
'    Else
'        Forms![ListeSiteGenerale].[SiteListe].Form.RecordSource = "ListeSite2"
'        Call Filtrer
'    End If
End Sub

Private Sub ChkNonRooftop_AfterUpdate()
    Call Filtrer
End Sub

Private Sub ChkNonRooftop_Click()
    Call Filtrer
End Sub

Private Sub ChkSansLongitudeLatitude_AfterUpdate()
    Call Filtrer

End Sub

Private Sub coche_intervenir_AfterUpdate()
Call Filtrer
End Sub

Private Sub coche_intervenir_Avec_Inter_AfterUpdate()
Call Filtrer
End Sub

Private Sub Cocher60_AfterUpdate()
 Call Filtrer
End Sub

Private Sub CocherInvest_AfterUpdate()
 Call Filtrer
End Sub

Private Sub CocherParticulier_AfterUpdate()
 Call Filtrer
End Sub

Private Sub CocherRetard_AfterUpdate()
    Call Filtrer
End Sub

Private Sub Form_Load()
Me.CboNumSit.SetFocus
Me.CboNumSit.Text = ""
    Call Filtrer
 

DoCmd.Maximize
Me.Form.Width = Me.WindowWidth
For Each sf In Me.Controls
If TypeOf sf Is SubForm Then
sf.Width = Me.WindowWidth - 567
sf.Height = Me.WindowHeight - 567 * 3
End If
Next
CboNumSit.SetFocus


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



Private Sub Texte17_AfterUpdate()
    Call Filtrer
End Sub

Private Sub Texte31_GotFocus()
 Dim SQL As String
        SQL = "SELECT * FROM ListeSite WHERE (codsit like '*" & CboCode & "*')"
        
        Me.SiteListe.Form.RecordSource = SQL
        Me.SiteListe.Requery
End Sub


Private Sub RefMat_Dirty(Cancel As Integer)

End Sub

Private Sub RefMat_Exit(Cancel As Integer)
Call Filtrer
End Sub

Private Sub txtNumeroBon_Exit(Cancel As Integer)

If txtNumeroBon.Text <> "" Then

    Dim SQL As String
SQL = "SELECT     Intervention.numintint, Intervention.numint, Intervention.codint, Intervention.typint, Intervention.datintpre, Intervention.heuintpre, Intervention.datint, Intervention.tpsallint, Intervention.tpsretint,"
SQL = SQL & "     Intervention.heuarrint, Intervention.heudepint, Intervention.codpan, Intervention.comint, Intervention.dirint, Intervention.intfac, Intervention.intfactok, Intervention.intafact, Intervention.codcon,"
SQL = SQL & "     Intervention.staint, Intervention.refint, Intervention.refcliint, Intervention.nbrappint, Intervention.mntfac, Intervention.datheuapp, Intervention.datheulim, Intervention.pannoncli, Intervention.nbrpagfax,"
SQL = SQL & "     Intervention.nummodres, Intervention.numdev, Intervention.objint, Intervention.traitepar, Intervention.majregsec, Intervention.sigsit, Intervention.sigtec, Intervention.sigcli,"
SQL = SQL & "     Intervention.creele AS Expr2, Intervention.majle AS Expr3, Intervention.nbrtecint, Intervention.numdevacc, Intervention.saisiepar, Intervention.imprimeepar, Intervention.classeepar,"
SQL = SQL & "     Intervention.prediagpar, Intervention.envoisoustraitantpar, Intervention.numerodemandesoustraitant, Intervention.retourficheinterventionpar, Intervention.devisepar, Intervention.duplicatacreepar,"
SQL = SQL & "     Intervention.duplicatafait, Intervention.prediagres, Intervention.devisafaire, Intervention.numpartenaire, Intervention.numdevpartenaire, Intervention.mnthtdevpartenaire, Intervention.stadev,"
SQL = SQL & "     Intervention.mnthtdevis, Intervention.retourficheoriginal, Intervention.retourfichecopie, Intervention.retourfichecopieordi, Intervention.numerocommande, Intervention.cheficdemint,"
SQL = SQL & "     Intervention.visitegratuite, Intervention.datesignaturecontrat AS Expr4, Intervention.numerocontratclient AS Expr5, Intervention.devisfait, Intervention.cheficdemcli, Intervention.comdevis,"
SQL = SQL & "     Intervention.devisanepasfaire, Intervention.controleetancheite, Intervention.natureintervention, Intervention.photofaite AS Expr6, Intervention.auditfait AS Expr7, Intervention.commajregsec,"
SQL = SQL & "     Intervention.sigtec2, Intervention.sigcli2, Intervention.sigsit2, Intervention.sigtecimg, Intervention.sigcliimg, Intervention.sigsitimg, Intervention.controleetancheiteponctuel AS Expr8,"
SQL = SQL & "     Intervention.sigtecjson, Intervention.sigclijson, Intervention.sigsitbase64, Intervention.comintposint, Intervention.numutipre, Intervention.comtec, Intervention.heuvis, ListeSite.numsit,"
SQL = SQL & "     ListeSite.numcli, ListeSite.codsit, ListeSite.nomsit, ListeSite.nomsocsit, ListeSite.sitsit, ListeSite.typsit, ListeSite.adrsit, ListeSite.codpossit, ListeSite.vilsit, ListeSite.telsit, ListeSite.faxsit,"
SQL = SQL & "     ListeSite.civres, ListeSite.nomres, ListeSite.preres, ListeSite.numzonsit, ListeSite.surven, ListeSite.surtot, ListeSite.nbrentsit, ListeSite.nbrdesenfsit, ListeSite.datdervisdes, ListeSite.comsit,"
SQL = SQL & "     ListeSite.telcencom, ListeSite.datcresit, ListeSite.demixasit, ListeSite.mntredev, ListeSite.indclitec, ListeSite.indvetust, ListeSite.indpuissance, ListeSite.indaccessib, ListeSite.nbrplan,"
SQL = SQL & "     ListeSite.nbrpho, ListeSite.allumageclim, ListeSite.domotique, ListeSite.accessfiltre, ListeSite.datprisencharge, ListeSite.misajoursecurite, ListeSite.aspirateur, ListeSite.hor_lun_ouv,"
SQL = SQL & "     ListeSite.hor_lun_fer, ListeSite.hor_mar_ouv, ListeSite.hor_mar_fer, ListeSite.hor_mer_ouv, ListeSite.hor_mer_fer, ListeSite.hor_jeu_ouv, ListeSite.hor_jeu_fer, ListeSite.hor_ven_ouv,"
SQL = SQL & "     ListeSite.hor_ven_fer, ListeSite.hor_sam_ouv, ListeSite.hor_sam_fer, ListeSite.hor_dim_ouv, ListeSite.hor_dim_fer, ListeSite.typfluid, ListeSite.temp_entree, ListeSite.temp_sortie,"
SQL = SQL & "     ListeSite.numzone2, ListeSite.numintervenant, ListeSite.creele, ListeSite.majle, ListeSite.longitude, ListeSite.latitude, ListeSite.donneurid, ListeSite.chemindoc, ListeSite.datesignaturecontrat,"
SQL = SQL & "     ListeSite.numerocontratclient, ListeSite.commentaire, ListeSite.photoafaire, ListeSite.photofaite, ListeSite.auditafaire, ListeSite.auditfait, ListeSite.controleetancheiteafaire,"
SQL = SQL & "     ListeSite.controleetancheitefait, ListeSite.majregistresecuriteafaire, ListeSite.majregistresecuritefait, ListeSite.montantredevancetechnique, ListeSite.montantredevancefiltre,"
SQL = SQL & "     ListeSite.nombrevisitetechnique, ListeSite.nombrevisitefiltre, ListeSite.numerocontratdesenfumage, ListeSite.nombrevisitedesenfumage, ListeSite.datedesenfumage,"
SQL = SQL & "     ListeSite.montantredevancedesenfumage, ListeSite.datedernierevisiteentretien, ListeSite.precisiongeo, ListeSite.datefermeture, ListeSite.motiffermeture, ListeSite.controleetancheiteponctuel,"
SQL = SQL & "     ListeSite.fermeture, ListeSite.Expr1, ListeSite.nomcli, ListeSite.adrcli, ListeSite.codposcli, ListeSite.vilcli, ListeSite.telcli, ListeSite.faxcli, ListeSite.concli, ListeSite.melcli, ListeSite.hormaxintcli,"
SQL = SQL & "     ListeSite.logcli , ListeSite.cheminpho, ListeSite.cheminpla, ListeSite.affcli, ListeSite.coutheuremainoeuvre, ListeSite.coutdeplacement, ListeSite.cptsit"
SQL = SQL & "     FROM         ListeSite INNER JOIN"
SQL = SQL & "     Intervention ON ListeSite.cptsit = Intervention.cptsit"
SQL = SQL & "     WHERE intervention.numint = " & txtNumeroBon
    
    Me.SiteListe.Form.RecordSource = SQL
    Me.SiteListe.Requery
End If
End Sub

Private Sub txtrefliint_Exit(Cancel As Integer)
If txtrefliint.Text <> "" Then
    Call Filtrer
End If
End Sub
