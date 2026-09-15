SELECT Client.nomcli,Site.nomsit,Count(Intervention.numintint),Year([datint]) FROM [Client],[Site],[Intervention] WHERE (((Intervention.typint)="1") AND ((Client.numcli)=210)) ORDER BY Client.nomcli
