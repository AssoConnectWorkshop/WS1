SELECT Client.nomcli,Devis.StatutDevis,Count(Devis.StatutDevis) FROM [Client],[Devis] WHERE (((Devis.DateEnvoiDevis) Between #1/1/2015# And #12/31/2015#)) ORDER BY Client.nomcli
