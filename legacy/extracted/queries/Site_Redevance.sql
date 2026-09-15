SELECT Site.numcli,Count(Site.cptsit),Site.mntredev,IIf(Site.typsit='H et F','H',Site.typsit) FROM [Site] 
