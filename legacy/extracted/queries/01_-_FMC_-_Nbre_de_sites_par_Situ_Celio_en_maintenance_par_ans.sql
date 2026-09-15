SELECT Client.nomcli,Count(Site.nomsit),Site.sitsit,Year([datint]) FROM [Client],[Site],[Intervention] WHERE (((Intervention.typint)="1") AND ((Client.numcli)=210)) ORDER BY Client.nomcli
