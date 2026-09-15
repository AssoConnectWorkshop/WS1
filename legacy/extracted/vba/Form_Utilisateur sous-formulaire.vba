Attribute VB_Name = "Form_Utilisateur sous-formulaire"
Attribute VB_Base = "0{1B09B0AE-A09E-4666-852D-C92CA25BC7BA}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = False
Option Compare Database

Private Sub Form_AfterInsert()
MsgBox "Merci de penser a lancer le Programme de fabien pour prise en compte des jours fériés (Si Chez FMC)", vbInformation
End Sub
