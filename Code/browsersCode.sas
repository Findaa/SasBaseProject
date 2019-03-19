*Create libname;
libname Brwsr 'D:\Datasets\BaseProject\libs\brwrs'; run;
proc sort data = Prep.MainTable out = Brwsr.BrowserSort;
format Chat_Duration time8.;
by BrowserGetName;
run;

*Average ChatDuration per browser;
proc means data = Brwsr.BrowserSort; 
var Chat_Duration;
class BrowserGetName;

output out = Brwsr.MeanBrowserData;
run;

data Brwsr.MeanOnlyBrowserToLength;
set Brwsr.MeanBrowserData;
if _STAT_ eq 'MEAN' then ; else delete;
keep Chat_Duration BrowserGetName;
run;

*GetOnlyDealChats;
data Brwsr.OrderValues;
set Prep.MainTable;
if Order_Value = 0 then delete;
run;
*sortDealsByBrowser;
proc sort data = Brwsr.OrderValues out = Brwsr.DealsByBrowser;
by BrowserGetName;
run;

proc sort data = Brwsr.OrderValues out = Brwsr.DealsByTeam;
by Teams;
run;

*Keep relevant info;
data Brwsr.ByDeals;
set Brwsr.DealsByBrowser;
keep Session_Name Order_Value Teams Geo;
run;
data Brwsr.ByTeams;
set Brwsr.DealsByTeam;
keep Session_Name Order_Value Teams Geo;
run;



data Brwsr.PreGraph;
set Brwsr.MeanOnlyBrowserToLength;
format Chat_Duration time5.;
run;
title 'Œredni czas trwania chatu w zale¿noœæi od przegl¹darki';
proc sgplot data = Brwsr.PreGraph;
vbar BrowserGetName / response = Chat_Duration groupdisplay = cluster
categoryholder = respdesc;
xaxis label = 'Nazwa przegl¹darki';
yaxis label = 'Œredni czas rozmowy [m]';
xaxistable Chat_Duration / stat=mean location=inside position=top;
run;

data Brwsr.BrowserSortProc;
set Brwsr.BrowserSort;
help = 1;
run;

 

proc means data=Brwsr.BrowserSort nway noprint;
class BrowserGetName;
var Chat_Duration;
output out= Brwsr.SummaryBrowsers sum=;
run;

data Brwsr.BrowserOutput (rename=(BrowserGetName=Browser) rename=(_FREQ_=Amount));
set Brwsr.SummaryBrowsers;
keep BrowserGetName _FREQ_;
run;

title 'Popularne przegl¹darki';
proc sgplot data = Brwsr.BrowserOutput;
vbar Browser / response = Amount groupdisplay = cluster
categoryholder = respdesc;
xaxis label = 'Popularnoœæ' ;
yaxis label = 'Przegl¹darka';
xaxistable Amount / stat=percent location=inside position=top;
run;

*Summary by Teams ADD TO PROJ;
proc summary data=Brwsr.ByTeams nway;
class Teams;
var Order_Value;
output out= Brwsr.TeamDealSummary sum=;
run;

data Brwsr.TeamSalesReport (rename=(_FREQ_=Frequency));
set Brwsr.TeamDealSummary;
Average = Order_Value / _FREQ_;
keep Teams _FREQ_ Order_Value Average;
format Order_Value dollar10.;
format Average dollar10.;
run;

