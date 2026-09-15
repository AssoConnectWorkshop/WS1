SELECT 4,Trim([nom du magasin]),Trim([Adresse]),Trim(IIf(Len([cp])=4,"0" & [cp],[cp])),Trim([Ville]),Trim([Telephone]),Trim([Fax]) FROM [LISTING],[Site] WHERE (((Site.numsit) Is Null)) 
