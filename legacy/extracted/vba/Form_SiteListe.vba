Attribute VB_Name = "Form_SiteListe"
Attribute VB_Base = "0{C6B904F7-344E-45D4-A124-0F364BBF78AE}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Form_Load()
    Dim calibre As Integer
    calibre = 100
    Me.Chemin_Dossier.ColumnOrder = 1
    Me.mntredev.ColumnOrder = 11
    Me.mntredev.ColumnWidth = 10 * calibre
    Me.montantredevancefiltre.ColumnOrder = 12
    Me.montantredevancefiltre.ColumnWidth = 10 * calibre
    Me.NumContratChaudiere.ColumnOrder = 40
    Me.NumContratChaudiere.ColumnWidth = 20 * calibre
    Me.NombreContratChaudiere.ColumnOrder = 41
    Me.NombreContratChaudiere.ColumnWidth = 20 * calibre
    Me.DateContratChaudiere.ColumnOrder = 42
    Me.DateContratChaudiere.ColumnWidth = 20 * calibre
    Me.mntredevContratChaudiere.ColumnOrder = 43
    Me.mntredevContratChaudiere.ColumnWidth = 20 * calibre
    Me.NumSousTraitChaudiere.ColumnOrder = 44
    Me.NumSousTraitChaudiere.ColumnWidth = 20 * calibre
    Me.TarifSousTraitChaudiere.ColumnOrder = 45
    Me.TarifSousTraitChaudiere.ColumnWidth = 20 * calibre
    
    Me.numerocontratdesenfumage.ColumnOrder = 46
    Me.numerocontratdesenfumage.ColumnWidth = 20 * calibre
    Me.nombrevisitedesenfumage.ColumnOrder = 47
    Me.nombrevisitedesenfumage.ColumnWidth = 20 * calibre
    Me.datedesenfumage.ColumnOrder = 48
    Me.datedesenfumage.ColumnWidth = 20 * calibre
    Me.montantredevancedesenfumage.ColumnOrder = 49
    Me.montantredevancedesenfumage.ColumnWidth = 20 * calibre
    Me.NumSousTraitDesenfum.ColumnOrder = 50
    Me.NumSousTraitDesenfum.ColumnWidth = 20 * calibre
    Me.TarifSousTraitDesenfum.ColumnOrder = 51
    Me.TarifSousTraitDesenfum.ColumnWidth = 20 * calibre
    
    Me.NumSousTraitClim.ColumnOrder = 52
    Me.NumSousTraitClim.ColumnWidth = 20 * calibre
    Me.TarifSousTraitClim.ColumnOrder = 53
    Me.TarifSousTraitClim.ColumnWidth = 20 * calibre
    
    Me.Chemin_Dossier.ColumnWidth = 4.875 * calibre
    Me.Donneur_d_ordres.ColumnWidth = 12.625 * calibre
    Me.Intervenant.ColumnWidth = 14.875 * calibre
    Me.numzonsit.ColumnWidth = 11 * calibre
    Me.numsit.ColumnWidth = 5.125 * calibre
    Me.codsit.ColumnWidth = 5.625 * calibre
    Me.numcli.ColumnWidth = 12 * calibre
    Me.nbrentsit.ColumnWidth = 11.25 * calibre
    Me.nomsit.ColumnWidth = 28 * calibre
    Me.adrsit.ColumnWidth = 53 * calibre
    Me.codpossit.ColumnWidth = 5.625 * calibre
    Me.vilsit.ColumnWidth = 19 * calibre
    Me.comsit.ColumnWidth = 24.75 * calibre
    Me.surven.ColumnWidth = 13.37 * calibre
    Me.surtot.ColumnWidth = 13.12 * calibre
    Me.datprisencharge.ColumnWidth = 14.5 * calibre
    Me.telsit.ColumnWidth = 11.625 * calibre
    Me.faxsit.ColumnWidth = 11.625 * calibre
    'Me.txtnumerocontratclient.ColumnWidth = 11.625 * calibre
    Me.comsit.ColumnWidth = 80.625 * calibre
    
End Sub

Private Sub nomsit_DblClick(Cancel As Integer)
    DoCmd.OpenForm "Site", acNormal, , "cptsit=" & Me.cptsit, acFormEdit
End Sub
Private Sub Commande134_Click()
On Error GoTo Err_Commande134_Click


    DoCmd.GoToRecord , , acLast

Exit_Commande134_Click:
    Exit Sub

Err_Commande134_Click:
    MsgBox err.Description
    Resume Exit_Commande134_Click
    
End Sub
