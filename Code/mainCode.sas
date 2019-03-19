*Create libname;
libname Prep 'D:\Datasets\BaseProject\libs\prep'; run;
*Import main data;
proc import out = Prep.MainInput datafile= "D:\Datasets\BaseProject\resources\Chat_Team_CaseStudy.csv"
dbms = csv;
run;
*Import browserDetails data;
proc import out=Prep.BrowserDetails datafile= "D:\Datasets\BaseProject\resources\BrowserId.csv"
dbms = csv;
run;

*Select distinct records from browser with sql;
data Prep.BrowserList;
set Prep.MainInput;
keep Session_Name Browser;
run;
*Fetch browser first name. Idk why one method in another doesnt;
*Few are with if after assignment because they appear during it;
data Prep.BrowserProc;
set Prep.BrowserList;
Browser = tranwrd(Browser, " ", "~");
j = 0;
_fb = 'Fb';
_ff = 'Firefox';
_ch = 'Chrome';
_sf = 'Safari';
_ie = 'IE';
do until(j = 0);
	j = findc(Browser, '~', j+1);
	if j = 0
	then ;
	else do;
		x=substr(Browser, 1, j);
		tmpBrowserName=compress(x, '1234567890.~');
	end;
	if tmpBrowserName eq 'f' then BrowserName = _ff;
		else if tmpBrowserName eq 'c' then BrowserName = _ch;
		else if tmpBrowserName eq 's' then BrowserName = _sf;
		else if tmpBrowserName eq 'f' then BrowserName = _ff;
		else if tmpBrowserName eq 'a' then delete;
		else BrowserName=tmpBrowserName;
		if BrowserName = "ChromeW" 	then BrowserName = _ch;
		if BrowserName = "Faceboo" 	then BrowserName = _fb;
		if BrowserName = "faceboo" 	then BrowserName = _fb;
		if BrowserName = "fb" 		then BrowserName = _fb;
		if BrowserName = "MobileS" 	then BrowserName = _sf;
		if BrowserName = "mobile_" 	then BrowserName = _sf;
		if BrowserName = "chrome_" 	then BrowserName = _ch;
		if BrowserName = "gsa" then BrowserName 	= "GSA";
		if BrowserName = "samsung" then BrowserName = "Samsung";
		if BrowserName = "webkit" then BrowserName  = "WebKit";
		if BrowserName = "miui_br" then BrowserName ="MiuiBrowser";
		if BrowserName = "MIUIBro" then BrowserName ="MiuiBrowser";
		if BrowserName = "other" then BrowserName 	= "Other";
		if BrowserName = "opera" then BrowserName 	= "Opera";
		if BrowserName = "edge" then BrowserName = "Edge";
		if BrowserName = "iemobil" then BrowserName = _ie;
		if BrowserName = "ucbrows" then BrowserName = "UCBrows";
		if BrowserName = "wechat" then BrowserName = "WeChat";
		if BrowserName = "yandex" then BrowserName = "Yandex";
		if browserName = "i" then BrowserName = _ie;
		if BrowserName = "qqbrows" then BrowserName = "QQBro";
end;
keep Session_Name BrowserName Browser;
run;
*get disctinct names again with sql proc. We get the list of browsers in this step 
fix in project that it was not given from beginning but we got that list;
proc sql;
create table Prep.BrowserTaglist as
select distinct BrowserName from Prep.BrowserProc
order by BrowserName asc;
quit;
*Need to merge Taglist with details;
data Prep.BrowserDomain;
merge Prep.BrowserTaglist Prep.BrowserDetails;
run;
*Need to sort before merging;
proc sort data=Prep.BrowserProc out=Prep.BrowserToMerge;
by BrowserName;
run;
proc sort data=Prep.BrowserDetails out=Prep.BrowserDomainSorted;
by BrowserName;
run;
*Merge session ID with browserDetails;
data Prep.BrowserAssignedToSessionId;
merge Prep.BrowserDomainSorted Prep.BrowserToMerge;
by BrowserName;
keep BrowserGetName BrowserCompany Session_Name;
run;
*Sort current table;
proc sort data=Prep.BrowserAssignedToSessionId out=Prep.BrowserAssignedToSessionId;
by Session_Name;
run;

*Create fist main table;
proc sort data=Prep.MainInput out=Prep.MainInputSortedById;
by Session_Name;
run;

data Prep.PrepGetSystems;
set Prep.MainInput;
Operating_System = tranwrd(Operating_System, " ", "-");
j = 0;
do until(j = 0);
	j = findc(Operating_System, '-', j+1);
	Operating_System = compress(Operating_System, '.-');
	if Operating_System ne . then Operating_System = 'iOS';
	if j = 0
	then ;
	else do;
		result=compress(Operating_System, '1234567890.-');
	end;
end;
keep result Session_Name
run;
data Prep.GetSystem;
set Prep.PrepGetSystems;
_w = 'Windows';
_l = 'Linux';
	if result = 'Androidunkno' then result = 'Android';
	if result = 'Linuxi' then result = _l;
	if result = 'Linuxx_' then result = _l;
	if result = 'Ubuntuunknow' then result = _l;
	if result = 'Linuxunknown' then result = _l;
	if result = 'WindowsVista' then result = _w;
	if result = 'WindowsXP' then result = _w;
	keep result Session_Name;
run;
proc sort data=Prep.GetSystem out=Prep.AssignSystem;
by Session_Name;
run;
proc sql;
create table Prep.OSList as 
select distinct result from Prep.GetSystem;
order by result asc;
quit;

data Prep.PrepMainTable;
merge Prep.MainInputSortedById Prep.BrowserAssignedToSessionId;
by Session_Name;
run;

data Prep.MainTable(rename=(result=OS));
merge Prep.PrepMainTable Prep.AssignSystem;
by Session_Name;
run;
