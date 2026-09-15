SELECT Site.numsit,Intervenant.nomint,[nomsit] & " - " & [typsit],Site.nbrentsit,Client.nomcli,planning.* FROM [Client],[Site],[Intervenant],[planning] 
