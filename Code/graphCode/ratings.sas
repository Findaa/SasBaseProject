*Wykres;
proc template;
define statgraph Graph;
dynamic _TAGLINEDURATION2 _CUSTOMER_RATING;
begingraph / designwidth=1000 designheight=375;
   entrytitle halign=center 'Zalezno�� zadowolenia klienta od czasu trwania rozmowy';
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10;
      layout overlay / xaxisopts=( label=('�redni czas trwania rozmowy z dok�adno�ci� do 5 sekund [m]')) yaxisopts=( label=('Ocena klienta [0-10]'));
         scatterplot x=_TAGLINEDURATION2 y=_CUSTOMER_RATING / name='scatter';
         regressionplot x=_TAGLINEDURATION2 y=_CUSTOMER_RATING / name='regression';
      endlayout;
   endlayout;
endgraph;
end;
run;
proc sgrender data=RT.TAGLINES template=Graph;
dynamic _TAGLINEDURATION2="TAGLINEDURATION" _CUSTOMER_RATING="'CUSTOMER_RATING'n";
run;

*ToWaitTime;
proc template;
define statgraph Graph2;
dynamic _TAGLINEWAIT _CUSTOMER_RATING;
begingraph / designwidth=1000 designheight=375;
   entrytitle halign=center 'Zalezno�� zadowolenia klienta od czasu oczekiwania na odpowied�';
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10;
      layout overlay / xaxisopts=( label=('�redni czas oczekiwania na odpowied� [s]')) yaxisopts=( label=('Ocena Klienta [0-10]'));
         scatterplot x=_TAGLINEWAIT y=_CUSTOMER_RATING / name='scatter';
         regressionplot x=_TAGLINEWAIT y=_CUSTOMER_RATING / name='regression';
      endlayout;
   endlayout;
endgraph;
end;
run;
*ToTeams;
proc sgrender data=RT.TAGLINES template=Graph2;
dynamic _TAGLINEWAIT="TAGLINEWAIT" _CUSTOMER_RATING="'CUSTOMER_RATING'n";
run;

proc template;
define statgraph sgdesign;
dynamic _TEAMS _CUSTOMER_RATING;
begingraph / designwidth=1000 designheight=375;
   entrytitle halign=center '�rednie ocen dla dru�yn';
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10;
      layout overlay / xaxisopts=( discreteopts=( tickvaluefitpolicy=splitrotate)) yaxisopts=( linearopts=( viewmin=0.0 viewmax=10.0));
         barchart category=_TEAMS response=_CUSTOMER_RATING / name='bar' stat=mean barlabel=true barlabelattrs=GraphLabelText(family='Arial' style=NORMAL weight=BOLD ) groupdisplay=Cluster clusterwidth=1.0;
      endlayout;
   endlayout;
endgraph;
end;
run;

proc sgrender data=RT.SORTEDBYTEAMS template=sgdesign;
dynamic _TEAMS="TEAMS" _CUSTOMER_RATING="'CUSTOMER_RATING'n";
run;

