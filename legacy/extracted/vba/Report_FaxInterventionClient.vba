Attribute VB_Name = "Report_FaxInterventionClient"
Attribute VB_Base = "0{83B86318-C401-4EB8-A81A-E16D859DAFEC}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Report_Open(Cancel As Integer)

    If IsNull(Me.OpenArgs) Then
        entete_fmc.Visible = False
        entete_rclim.Visible = True
        pied_fmc.Visible = False
        pied_rclim.Visible = True
        logo_rclim.Visible = True
        EtiquetteDE.Caption = "DE : Mickaël ROBERT"
        EtiquetteTEL.Caption = "TEL. : 01.60.34.5000"
        
    Else
        EtiquetteDE.Caption = "DE : Fabien MATHIVET"
        EtiquetteTEL.Caption = "TEL. : 05 33 89 12 40"
        pied_fmc.Visible = True
        pied_rclim.Visible = False
        entete_fmc.Visible = True
        entete_rclim.Visible = False
        logo_rclim.Visible = False
        txtCorps.ControlSource = Replace(txtCorps.ControlSource, "Mickaël ROBERT", "Fabien Mathivet")
    End If
End Sub

