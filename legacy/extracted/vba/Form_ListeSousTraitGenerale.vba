Attribute VB_Name = "Form_ListeSousTraitGenerale"
Attribute VB_Base = "0{09310D01-75AB-42DA-8F6C-EA615F3603E4}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database


Private Sub Filtrer()

Dim UnFiltre As Boolean
Dim sFiltre As String

sFiltre = ""

If Not IsNull(Me.cboInterv.Value) Then
    sFiltre = " codint ='" & cboInterv & "'"
    UnFiltre = True
End If

If Me.CocherExistePus.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "(ExistePlus=1)"
    UnFiltre = True
Else
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "(ExistePlus=0)"
    UnFiltre = True
End If


If ChkSansLongitudeLatitude.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "([longitude_interv] is null OR [latitude_interv] is null)"
    UnFiltre = True
End If

If Me.Prospect.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "(Status_Prospect=1)"
    UnFiltre = True
End If

If Me.STFMC.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "(Status_ST_FMC=1)"
    UnFiltre = True
End If


If Me.Tech.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "(EstTech=1)"
    UnFiltre = True
End If

If Me.STFMCPONCT.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "(Status_ST_FMC_Ponctuel=1)"
    UnFiltre = True
End If



If Me.coche_intervenir.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "([NePlusIntervenir] is not null and [NePlusIntervenir]=1)"
    UnFiltre = True
End If

If ChkNonRooftop.Value = True Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    sFiltre = sFiltre & "([precisiongeo_interv]<>'ROOFTOP' or [precisiongeo_interv] is null)"
    UnFiltre = True
End If

'****** liste zone ********************
If Me.LstZone.ItemsSelected.Count <> 0 Then
    Dim varI As Variant
    Nb_Occur = 1
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    
    For Each varI In Me!LstZone.ItemsSelected
            If Nb_Occur = 1 Then
                sFiltre = sFiltre & " ([numzonint]=" & Me!LstZone.ItemData(varI) & " or [numzonint_2_Interv]=" & Me!LstZone.ItemData(varI) & " or [numzonint_3_Interv]=" & Me!LstZone.ItemData(varI) & " or [numzonint_4_Interv]=" & Me!LstZone.ItemData(varI) & "Or Zone_Nationale = 1"
            Else
                sFiltre = sFiltre & " or [numzonint]=" & Me!LstZone.ItemData(varI) & " or [numzonint_2_Interv]=" & Me!LstZone.ItemData(varI) & " or [numzonint_3_Interv]=" & Me!LstZone.ItemData(varI) & " or [numzonint_4_Interv]=" & Me!LstZone.ItemData(varI) & "Or Zone_Nationale = 1"
            End If
            Nb_Occur = Nb_Occur + 1
    Next varI
    sFiltre = sFiltre + ")"
    UnFiltre = True
    
    
  
    
End If

'****** liste Activite ********************
If Me.Lst_Activ.ItemsSelected.Count <> 0 Then
    Nb_Occur = 1
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    
    For Each varI In Me!Lst_Activ.ItemsSelected
            If Nb_Occur = 1 Then
                sFiltre = sFiltre & " ([Activite_1]=" & Me!Lst_Activ.ItemData(varI) & " or [Activite_2]=" & Me!Lst_Activ.ItemData(varI) & " or [Activite_3]=" & Me!Lst_Activ.ItemData(varI) & " or [Activite_4]=" & Me!Lst_Activ.ItemData(varI) & " or [Activite_5]=" & Me!Lst_Activ.ItemData(varI) & " or [Activite_6]=" & Me!Lst_Activ.ItemData(varI)
            Else
                sFiltre = sFiltre & " or [Activite_1]=" & Me!Lst_Activ.ItemData(varI) & " or [Activite_2]=" & Me!Lst_Activ.ItemData(varI) & " or [Activite_3]=" & Me!Lst_Activ.ItemData(varI) & " or [Activite_4]=" & Me!Lst_Activ.ItemData(varI) & " or [Activite_5]=" & Me!Lst_Activ.ItemData(varI) & " or [Activite_6]=" & Me!Lst_Activ.ItemData(varI)
            End If
            Nb_Occur = Nb_Occur + 1
    Next varI
    sFiltre = sFiltre + ")"
    UnFiltre = True
End If



Dim numsit As String
numsit = ""

If Me.InfosInterv <> "" Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    infosInt = Me.InfosInterv
    sFiltre = sFiltre & " ((nomint like '%" & infosInt & "%') or (adrint like '%" & infosInt & "%') or (codposint like '" & infosInt & "%') or (vilint like '%" & infosInt & "%'))"
    UnFiltre = True
End If

If Me.CP_Inter <> "" Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    infosInt = Me.CP_Inter
    sFiltre = sFiltre & " ((VillesInterventions_Interv like '%" & infosInt & "%') )"
    UnFiltre = True
End If

If Me.Info_Div <> "" Then
    If UnFiltre Then
        sFiltre = sFiltre & " AND "
    End If
    infosInt = Me.Info_Div
    sFiltre = sFiltre & " ((Histo_FMC_Interv like '%" & infosInt & "%') or (Info_Interv like '%" & infosInt & "%'))"
    UnFiltre = True
End If

If UnFiltre Then
    Dim SQL As String
    If sFiltre <> "" Then
        Me.ListeIntervenant.Form.RecordSource = "Select * from intervenant where " + sFiltre
        'Me.ListeIntervenant.Form.Filter = sFiltre
    Else
        Me.ListeIntervenant.Form.RecordSource = "Select * from intervenant"
    End If
 Else
    Me.ListeIntervenant.Form.RecordSource = "Select * from intervenant"
End If
Me.ListeIntervenant.Requery




End Sub


Private Sub CmdRechercher_Click()
Call Filtrer
End Sub

Private Sub Form_Load()
    'Call Filtrer
 
DoCmd.Maximize
Me.Form.Width = Me.WindowWidth
For Each sf In Me.Controls
If TypeOf sf Is SubForm Then
sf.Width = Me.WindowWidth - 567
sf.Height = Me.WindowHeight - 567 * 3
End If
Next
Me.cboInterv.SetFocus


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
