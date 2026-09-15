SELECT Site.cptsit,Site.numsit,Site.nomsit,Site.VilSit,Client.nomcli FROM [Client],[Site] WHERE (((Site.numcli)=[Formulaires]![Intervention]![LstClient])) ORDER BY Site.nomsit
