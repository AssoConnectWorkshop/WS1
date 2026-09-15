Attribute VB_Name = "ClasseTech"
Attribute VB_Base = "0{FCFB3D2A-A0FA-1068-A738-08002B3371B5}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database
Option Explicit
Public Nom As String
Public Prenom As String
'03/01/2025 Passage à 53 (Car oui ca arrive !!)
Private mTabHeure(1 To 53, 1 To 7) As Double
'Public TabHeureAnMoinsUn() As Double
'Public TabHeureAnMoinsDeux() As Double
'Public TabHeureAnMoinsTrois() As Double
'Public TabHeureAnMoinsQuatre() As Double

Property Get TabHeure()
   TabHeure = mTabHeure
End Property

Property Let TabHeure(NewTabHeure)
    'Propriété en écriture
    Dim i As Long
    'Vérification des caractéristiques de NewList (base et dimensions)
    For i = 0 To UBound(NewTabHeure)                                               'Validation
        If Not CheckItem(NewTabHeure(i)) Then
            err.Raise vbObjectError + 1, , "Valeur incorrecte à l'indice " & i   'Erreur
        End If
    Next
    mTabHeure = NewTabHeure
End Property

Public Property Let TabHeureItem(Semaine As Integer, Jour As Integer, NewTabHeureItem As Long)
      mTabHeure(Semaine, Jour) = NewTabHeureItem                                            'Affectation
End Property
 


