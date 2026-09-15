Attribute VB_Name = "Parcourir"
Option Compare Database

Global GNumclient As Long
  'Déclaration de l'API
'Private Declare Sub ptrsafe PathStripPath Lib "shlwapi.dll" Alias "PathStripPathA" (ByVal pszPath As String)
'Private Declare Function GetOpenFileName Lib "comdlg32.dll" Alias _
                   "GetOpenFileNameA" (pOpenfilename As OPENFILENAME) As Long

 'Structure du fichier
Private Type OPENFILENAME
    lStructSize As Long
    hwndOwner As Long
    hInstance As Long
    lpstrFilter As String
    lpstrCustomFilter As String
    nMaxCustFilter As Long
    nFilterIndex As Long
    lpstrFile As String
    nMaxFile As Long
    lpstrFileTitle As String
    nMaxFileTitle As Long
    lpstrInitialDir As String
    lpstrTitle As String
    flags As Long
    nFileOffset As Integer
    nFileExtension As Integer
    lpstrDefExt As String
    lCustData As Long
    lpfnHook As Long
    lpTemplateName As String
End Type

 'Constantes
Private Const OFN_READONLY = &H1
Private Const OFN_OVERWRITEPROMPT = &H2
Private Const OFN_HIDEREADONLY = &H4
Private Const OFN_NOCHANGEDIR = &H8
Private Const OFN_SHOWHELP = &H10
Private Const OFN_ENABLEHOOK = &H20
Private Const OFN_ENABLETEMPLATE = &H40
Private Const OFN_ENABLETEMPLATEHANDLE = &H80
Private Const OFN_NOVALIDATE = &H100
Private Const OFN_ALLOWMULTISELECT = &H200
Private Const OFN_EXTENSIONDIFFERENT = &H400
Private Const OFN_PATHMUSTEXIST = &H800
Private Const OFN_FILEMUSTEXIST = &H1000
Private Const OFN_CREATEPROMPT = &H2000
Private Const OFN_SHAREAWARE = &H4000
Private Const OFN_NOREADONLYRETURN = &H8000
Private Const OFN_NOTESTFILECREATE = &H10000

Private Const OFN_SHAREFALLTHROUGH = 2
Private Const OFN_SHARENOWARN = 1
Private Const OFN_SHAREWARN = 0

Public Sub AfficheDossierWindows(Nom As String)

If IsNull(Nom) = False Then
    Position = 0
    NomFichier = Nom
suite:
    'La premiere partie (Avant le #\\) ne sert pas

    Pos_Depart = InStr(1, NomFichier, "#\\", vbTextCompare)
    If (Pos_Depart <> 0) Then
        Depart_Texte = Pos_Depart
        TexteDossier = Right(NomFichier, Len(NomFichier) - Depart_Texte)
        Pos_Depart = 0
        For i = 0 To 30
            Position = InStr(Pos_Depart + 1, TexteDossier, "\", vbTextCompare)
            If Position = 0 Then
                Exit For
            Else
                Pos_Depart = Position
            End If
        Next i
        'On enleve ce qu'il y a apres le dernier /
        If Pos_Depart <> 0 Then
            'On verifie qu'il n'y a pas 2 fois "#\\"
            pos_encore = InStr(1, TexteDossier, "#\\", vbTextCompare)
            If pos_encore <> 0 Then
                NomFichier = TexteDossier
                GoTo suite
            End If
            'Chemin = Left(TexteDossier, Pos_Depart)
            'On enleve le dernier#
            Chemin = Left(TexteDossier, Len(TexteDossier) - 1)
            Shell Environ("WINDIR") & "\explorer.exe /Select," & Chemin, vbNormalFocus
        End If
    End If
Else

End If
End Sub



