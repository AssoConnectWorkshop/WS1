SELECT Trim([nom du magasin]),Trim([Adresse]),Trim(IIf(Len([cp])=4,"0" & [cp],[cp])),Trim([Ville]),Trim([Telephone]),Trim([Fax]) FROM [Site],[LISTING] 
