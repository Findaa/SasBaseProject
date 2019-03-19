*Create libname;
libname Rt 'D:\Datasets\BaseProject\libs\rt'; run;
*Write shit about data we focus on and why those keeps; 
data Rt.Imported;
set Prep.MainTable;
format Chat_Duration time7.;
format Customer_Wait_Time time7.;
run;

*Select only commented chats;
data Rt.RatedChat;
set Rt.Imported;
if Customer_Rating = '.' then delete;
keep Session_Name Chat_Duration Customer_Wait_Time Operating_System BrowserGetName Customer_Rating Customer_Comment OS Agent;
run;


*Only Commented/rated;
data Rt.CommentedChat;
set Rt.Imported;
if Customer_Comment = ' ' then delete;
keep Session_Name Chat_Duration Customer_Wait_Time Operating_System BrowserGetName Customer_Rating Customer_Comment OS Agent;
run;

proc means data = Rt.RatedChat;
var Customer_Rating;
run;

*Get time every 5 s;
data Rt.Taglines;
set Rt.RatedChat;
  format Chat_Duration time8.;
  format Customer_Wait_Time time8.;
  format TaglineDuration time8.;
  format TaglineWait time8.;
      TaglineDuration=intnx('second30',Chat_Duration,1,'b');
	  TaglineWait=round(Customer_Wait_Time, '00:00:05't);
run;
*Mean rating;                                                                                 
proc means data = Rt.RatedChat noprint; 
var Customer_Rating;
class Chat_Duration;
output out = Rt.RatingOnChatDurationMeans;
run;

proc sort data=Rt.RatedChat out=Rt.RatedChatSortedOs;
by OS;
run;

*prep data table;
data Rt.OsProc;
set Rt.RatedChatSortedOs;
keep OS Customer_rating;
run;

*get summary;
proc means data = Rt.OsProc noprint;
var Customer_rating;
class OS;
output out = Rt.MeansForOs;
run;

proc sort data=Rt.Imported out=Rt.SortedByTeams;
by Teams;
run;

proc means data = Rt.SortedByteams noprint;
var Customer_Rating;
class Teams;
output out = Rt.TeamMeansRating;
run;



data Rt.TeamMean (rename=(Customer_Rating=Average_Rating));
set Rt.TeamMeansRating;
if _STAT_ = "MEAN" then ; else delete;
keep Teams Customer_Rating;
if Teams = ' ' then delete;
run;
proc sort data = Rt.TeamMean out = Rt.GraphTeamMean;
by Average_Rating;
run;


proc sort data = Rt.RatedChat out=Rt.SortedAgent;
by Agent;
run;

proc means data = Rt.SortedAgent;
var Customer_Rating;
class Agent;
output out = Rt.RatedChatAgentMeans;
run;

data Rt.AgentRating (rename=(Customer_Rating=Average_Rating));
set Rt.RatedChatAgentMeans;
if _STAT_ = "MEAN" then ; else delete;
keep Agent Customer_rating;
run;


proc sort  data = Rt.AgentRating 
out = Rt.AgentRatingSorted;
by descending Average_Rating;
run;

proc summary data=Rt.SortedAgent nway;
class Agent;
var Customer_Rating;
output out= Rt.AgentRatingSum sum=;
run;

data Rt.AgentRatingSum (rename=(_FREQ_=Amount));
set Rt.AgentRatingSum;
keep Agent _FREQ_;
run;


data Rt.PrepAgentAverage;
merge Rt.AgentRating Rt.AgentRatingSum;
if Amount lt 12 then delete;
run;

proc sort data = Rt.PrepAgentAverage out = Rt.TopAgents;
by descending Average_Rating;
run;

data Rt.TopTenAgents;
set Rt.TopAgents (obs=10);
run;




title 'Top 10 agentów';
proc sgplot data = Rt.TopTenAgents;
vbar Agent / response = Average_Rating groupdisplay = cluster
categoryholder = respdesc;
xaxis label = 'Pracownik' ;
yaxis label = 'Œrednia ocena';
run;
