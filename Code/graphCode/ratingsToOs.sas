proc template;
define statgraph sgdesign;
dynamic _OS _CUSTOMER_RATING;
begingraph / designwidth=1000 designheight=375 ;
   entrytitle halign=center 'Zale¿noœæ ocen od systemu';
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10;
      layout overlay / xaxisopts=( reverse=false display=(TICKS TICKVALUES LINE LABEL ) label=('System Operacyjny') discreteopts=( tickvaluefitpolicy=splitrotate)) yaxisopts=( label=('Œrednia Ocena'));
         barchart category=_OS response=_CUSTOMER_RATING / name='bar' display=(OUTLINE FILL) stat=mean barlabel=true barwidth=0.88 discreteoffset=0.0 groupdisplay=Cluster clusterwidth=1.0 grouporder=descending;
      endlayout;
   endlayout;
endgraph;
end;
run;

proc sgrender data=RT.RATEDCHAT template=sgdesign;
dynamic _OS="OS" _CUSTOMER_RATING="'CUSTOMER_RATING'n";
run;
