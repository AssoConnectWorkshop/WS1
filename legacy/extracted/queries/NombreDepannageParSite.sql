SELECT Site.nomsit,Count(Intervention.numint),Intervention.typint,Year([datint]) FROM [Site],[parametre],[Intervention] WHERE (((Year([datint]))=Year([Parametre]![datdeb]))) 
