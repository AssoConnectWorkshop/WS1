Attribute VB_Name = "Form_Intervenant_Fersoft"
Attribute VB_Base = "0{CD412469-E40B-4CE9-A9BC-A7F1C7A5154D}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub CheckChaudiere_Click()
Me.CheckClim.Value = False
Me.CheckDesen.Value = False
Me.CheckChaudiere.Value = True
Me.Intervenant_Sous_formulaire_Chaudiere.Visible = True
Me.Intervenant_Sous_formulaire_Clim.Visible = False
Me.Intervenant_Sous_formulaire_Desenfum.Visible = False
End Sub

Private Sub CheckClim_Click()
Me.CheckClim.Value = True
Me.CheckDesen.Value = False
Me.CheckChaudiere.Value = False
Me.Intervenant_Sous_formulaire_Chaudiere.Visible = False
Me.Intervenant_Sous_formulaire_Clim.Visible = True
Me.Intervenant_Sous_formulaire_Desenfum.Visible = False
End Sub


Private Sub CheckDesen_Click()
Me.CheckClim.Value = False
Me.CheckDesen.Value = True
Me.CheckChaudiere.Value = False
Me.Intervenant_Sous_formulaire_Chaudiere.Visible = False
Me.Intervenant_Sous_formulaire_Clim.Visible = False
Me.Intervenant_Sous_formulaire_Desenfum.Visible = True
End Sub

Private Sub CheckDepann_Click()
Me.CheckDevis.Value = False
Me.CheckDepann.Value = True
Me.CheckMaint.Value = False
Me.CheckTravaux.Value = False
Me.Travaux.Visible = False
Me.Devis.Visible = False
Me.Maintenance.Visible = False
Me.Depann.Visible = True
End Sub


Private Sub CheckDevis_Click()
Me.CheckDevis.Value = True
Me.CheckDepann.Value = False
Me.CheckMaint.Value = False
Me.CheckTravaux.Value = False
Me.Travaux.Visible = False
Me.Devis.Visible = True
Me.Maintenance.Visible = False
Me.Depann.Visible = False
End Sub

Private Sub CheckMaint_Click()
Me.CheckDevis.Value = False
Me.CheckDepann.Value = False
Me.CheckMaint.Value = True
Me.CheckTravaux.Value = False
Me.Travaux.Visible = False
Me.Devis.Visible = False
Me.Maintenance.Visible = True
Me.Depann.Visible = False
End Sub

Private Sub CheckTravaux_Click()
Me.CheckDevis.Value = False
Me.CheckDepann.Value = False
Me.CheckMaint.Value = False
Me.CheckTravaux.Value = True
Me.Travaux.Visible = True
Me.Devis.Visible = False
Me.Maintenance.Visible = False
Me.Depann.Visible = False
End Sub

Private Sub Cocher172_Click()
If Me.NePlusIntervenir.Value = True Then
    Me.ImgPasInterven.Visible = True
    TextePasInterv.Visible = True
Else
    Me.ImgPasInterven.Visible = False
    TextePasInterv.Visible = False
End If
End Sub

Private Sub Commande297_Click()
On Error GoTo Err_Commande297_Click


    If Me.Dirty Then Me.Dirty = False
    DoCmd.Close

Exit_Commande297_Click:
    Exit Sub

Err_Commande297_Click:
    MsgBox err.Description
    Resume Exit_Commande297_Click
End Sub

Private Sub Commande298_Click()
On Error GoTo Err_Commande298_Click


    DoCmd.RunCommand acCmdRefresh

Exit_Commande298_Click:
    Exit Sub

Err_Commande298_Click:
    MsgBox err.Description
    Resume Exit_Commande298_Click
End Sub

Private Sub Form_Load()
Me.CheckClim.Value = True
Me.CheckDesen.Value = False
Me.CheckChaudiere.Value = False
Me.Intervenant_Sous_formulaire_Chaudiere.Visible = False
Me.Intervenant_Sous_formulaire_Clim.Visible = True
Me.Intervenant_Sous_formulaire_Desenfum.Visible = False

Me.CheckDevis.Value = False
Me.CheckDepann.Value = True
Me.CheckMaint.Value = False
Me.CheckTravaux.Value = False
Me.Travaux.Visible = False
Me.Devis.Visible = False
Me.Maintenance.Visible = False
Me.Depann.Visible = True

If Me.NePlusIntervenir.Value = True Then
    Me.ImgPasInterven.Visible = True
    TextePasInterv.Visible = True
Else
    Me.ImgPasInterven.Visible = False
    TextePasInterv.Visible = False
End If
End Sub



