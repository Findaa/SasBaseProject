*Create libname;
libname Geo 'D:\Datasets\BaseProject\libs\geo'; run;

proc sort data = Prep.MainTable out = Geo.GeoSort;
format Chat_Duration time8.;
by Geo;
run;
proc means data = Geo.GeoSort noprint;
var Order_Value;
class Geo;
output out = Geo.VCOrderCountByGeo;
run;

data Geo.VCGetGeoCount (rename=(_FREQ_=Frequency));
set Geo.VCOrderCountByGeo;
if _STAT_ ne 'N' then delete;
keep Geo _FREQ_;
run;

proc sort data = Geo.VCGetGeoCount out = Geo.VCGeoCountSorted ;
by descending Frequency;
run;


data Geo.VCPrepReport;
set Geo.VCGeoCountSorted;
if Frequency lt 10 then Geo = 'Other';
run;

proc summary data=Geo.VCPrepReport nway noprint;
class Geo;
var Frequency;
output out= Geo.VCReport sum=;
run;
*Widac ze w australii najwiecej kontakow;
data Geo.VCReportNormalize;
set Geo.VCReport;
if Geo = 'UNKNOWN' then Geo = 'Other';
if Geo = 'null' then Geo = 'Other';
keep Geo Frequency;
proc sort data = Geo.VCReportNormalize out = Geo.VCReportFinal;
by descending Frequency;
run;
 
*GeoSorted;
data Geo.Output;
set Geo.GeoSort;
if Geo = 'UNKNOWN' then Geo = 'Other';
if Geo = 'null' then Geo = 'Other';
if (Geo eq ' ') then Geo = 'Other';
help = 1;
run;

data Geo.BrowsersByGeo;
set Geo.Output;
keep OS Geo;
run;

proc means data = Geo.BrowsersByGeo noprint;
var Order_Value;
class Geo;
output out = Geo.VCOrderCountByGeo;
run;

proc means data=Geo.Output n noprint;
class Geo;
class OS;
types Geo Geo*Os;
var help;
output out = Geo.OsProcByGeo;
run;
*We can see Australia and Other has the most so we can get it as probe;
data Geo.OsGeoSort (rename=(_FREQ_=Ilosc));
set Geo.OsProcByGeo;
keep Geo OS _FREQ_;
if _STAT_ = 'N' then ; else delete;
if (OS eq ' ') then delete;
if Geo = 'UNKNOWN' then Geo = 'Other';
if Geo = 'null' then Geo = 'Other';
if (Geo eq ' ') then Geo = 'Other';
if Geo = 'United Stat' then Geo = 'USA';
run;

data Geo.OsGeoSort (rename=(_FREQ_=Ilosc));
set Geo.OsProcByGeo;
keep Geo OS _FREQ_;
if _STAT_ = 'N' then ; else delete;
if (OS eq ' ') then delete;
if Geo = 'UNKNOWN' then Geo = 'Other';
if Geo = 'null' then Geo = 'Other';
if (Geo eq ' ') then Geo = 'Other';
if Geo = 'United Stat' then Geo = 'USA';
if (Geo = 'USA' OR Geo = 'Australia' OR Geo = 'Other') then ; else delete;
run;
*DOUBLE MEANS REPORT ENDS HERE AND START ANOTHER FOR OS;
data Geo.BrowsersByGeo;
set Geo.Output;
keep BrowserGetName Geo;
run;
proc means data=Geo.Output n noprint;
class Geo;
class BrowserGetName;
types Geo Geo*BrowserGetName;
var help;
output out = Geo.BrowserProcByGeo;
run;
data Geo.BrowserGeoSort (rename=(_FREQ_=Ilosc));
set Geo.BrowserProcByGeo;
keep Geo BrowserGetName _FREQ_;
if _STAT_ = 'N' then ; else delete;
run;

data Geo.BrowserGeoSort (rename=(_FREQ_=Ilosc));
set Geo.BrowserProcByGeo;
keep Geo BrowserGetName _FREQ_;
if _STAT_ = 'N' then ; else delete;
if (BrowserGetNAme eq ' ') then delete;
if Geo = 'UNKNOWN' then Geo = 'Other';
if Geo = 'null' then Geo = 'Other';
if (Geo eq ' ') then Geo = 'Other';
if Geo = 'United Stat' then Geo = 'USA';
if (Geo = 'USA' OR Geo = 'Australia' OR Geo = 'Other') then ; else delete;
run;


proc summary data=Brwsr.ByTeams nway;
class Geo;
var Order_Value;
output out= Geo.GeoDealSummary sum=;
run;
data Geo.GeoSalesReport (rename=(_FREQ_=Frequency));
set Geo.GeoDealSummary;
Average = Order_Value / _FREQ_;
keep Geo _FREQ_ Order_Value Average;
drop _TYPE_;
format average dollar10.;
run;
*Select distinct values from tables OS system joined
 split into 2 variables and search for both at one call.;
