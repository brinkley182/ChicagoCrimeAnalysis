**************************************************************************************************
				Data Importing
Contains steps to import data set as crime, comma 
seperated. 

Source: https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-present/ijzp-q8t2
***************************************************************************************************;

proc import datafile='S:\Final Project/Final Project\crimes.csv' out = crime replace;
delimiter = ',';
getnames=yes;
run;

*print current view of data set, first 50 obs shown;
proc print data=crime (obs=50);
run;

*************************************************************************************************
			Data Preprocessing/Cleaning
This section contains the code to create dummy variables.
We convert certain variables into relevant vars pertinent
to our analysis and remove ones we don't use.
************************************************************************************************;

* create dummy variables for arrest, where if arrest is now 1 if true;
* and domestic is 1 if true;
data crime;
set crime;
*arrest dummy;
d_arrest = 0;
if arrest = 'true' then d_arrest = 1;
*domestic dummy;
d_domestic = 0;
if domestic ='true' then d_domestic = 1;


*districts based on https://news.wttw.com/sites/default/files/Map%20of%20Chicago%20Police%20Districts%20and%20Beats.pdf;
*combine chicago districts into three distinct regions: north, south, and central;
north = 0;
south = 0;
central = 0;
if district in (11 14 15 17 19 20 24 16 25) then north = 1;
if district in (4 5 6 7 22) then south = 1;
if district in (1 2 3 8 9 10 12 13 18) then central = 1;

*primary_type of arret we are focusing on by grouping types in 3 cats, violent, drug, or stealing crimes;
violent=0;
drug=0;
stealing = 0;

* primary type is the kind of arrest made and this section combines similar crimes into 3 categories: violent, drug, and stealing;
if Primary_Type in ('BATTERY', 'CRIM SEXUAL ASSAULT', 'HOMICIDE', 'KIDNAPPING', 'DOMESTIC VIOLENCE') then violent = 1;
if Primary_Type in ('NARCOTICS', 'OTHER NARCOTIC VIOLATION') then drug = 1;
if Primary_Type in ('THEFT', 'BURGLARY' 'ROBBERY' 'MOTOR VEHICLE THEFT') then stealing = 1;

*season dummy;
*here we convert our time information into yearly seasons to be more general. We use winter, spring, and summer;
winter=0;
spring=0;
summer=0;
if date in (1 2 12) then winter=1;
if date in (3 4 5)  then spring = 1;
if date in (6 7 8) then summer =1;

*year dummy;
*we focus on the years of 2001, 2009 and 2018;
d_2001 = 0;
d_2009 = 0;
d_2018 = 0;
if year = 2001 then d_2001 = 1;
if year = 2009 then d_2009 = 1;
if year = 2018 then d_2018 = 1;

*location dummy - set home to equal crimes where it occurs at homes as in
* residence or an apartment;
home = 0;
if location_description = 'RESIDENCE' or location_description = 'APARTMENT' then home =1;

*interaction variable - combination of type of location (home) and violent crimes;
HomVio= home * violent;
run;

*prints cleaned and processed data set (100 obs);
title "Crime data set post processing";
proc print data = crime (obs=100);
run;


*******************************************************************************************************
				Data exploration step	
The code in this section is used to see the frequency table for each variable in 
the data set
*******************************************************************************************************;

* create freq table for each var;
Title "Frequency tables for all variables in crime data";
proc freq data=crime;
tables d_arrest d_domestic north south central violent drug stealing summer winter spring d_2001 d_2009 d_2018 home;
run;

*The following code below is used to plot the frequency graphs;
*for each independent variable agaisnt the binary d_arrest values;

title "Frequency of d_arrest vs all independent variables";
* domestic vs arrest;
proc sgplot data=crime;
vbar d_domestic/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* north vs arrest;
proc sgplot data=crime;
vbar north/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* south vs arrest;
proc sgplot data=crime;
vbar south/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* central vs arrest;
proc sgplot data=crime;
vbar central/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* violent vs arrest;
proc sgplot data=crime;
vbar violent/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* drug vs arrest;
proc sgplot data=crime;
vbar drug/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* stealing vs arrest;
proc sgplot data=crime;
vbar stealing/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* summer vs arrest;
proc sgplot data=crime;
vbar summer/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* winter vs arrest;
proc sgplot data=crime;
vbar winter/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* spring vs arrest;
proc sgplot data=crime;
vbar spring/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* d_2001 vs arrest;
proc sgplot data=crime;
vbar d_2001/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* d_2009 vs arrest;
proc sgplot data=crime;
vbar d_2009/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* d_2018 vs arrest;
proc sgplot data=crime;
vbar d_2018/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* home vs arrest;
proc sgplot data=crime;
vbar home/group=d_arrest GROUPDISPLAY = CLUSTER;
run;
* HomVio vs arrest;
proc sgplot data=crime;
vbar HomVio/group=d_arrest GROUPDISPLAY = CLUSTER;
run;

**********************************************************************************
				Data Train/Test Split
*Divide Data in to train/test set using 75/25 split
* and save into xv_all dataset
*********************************************************************************;
title 'Dataset train/test division';
proc surveyselect data = crime 
out= xv_all seed=495857
samprate = 0.75 outall;
run;

* display 100 obs after splitting;
proc print data =xv_all (obs=100);
run;

* set new_arrest as train_y variable for the train data;
data xv_all;
set xv_all;
if selected then new_arrest=d_arrest;
run;
* display 20 obs after making train y var;
title "Train/test split data with ney_y (new_arrest)";
proc print data=xv_all (obs=20);
run;


*************************************************************************************
				Model Selection
The code in this section is used to determine the final model. We start with creating
a full model and using forward and backward selection techniques, to determine
the best possible model to fit our data
************************************************************************************;

*full model;
proc logistic data = xv_all;
title 'Full Model for Crime data';
model new_arrest (event='1')= d_domestic north south central violent drug stealing summer winter spring d_2009 d_2018 home homvio/stb corrb rsquare;
run; 

*Model Selection and comparison;
*Backward selection;
proc logistic data = xv_all;
title 'Backward Selection';
model new_arrest (event='1')= d_domestic north south central violent drug stealing summer winter spring d_2009 d_2018 home homvio/
stb corrb rsquare selection = backward;
run; 
*Forwards selection;
proc logistic data = xv_all;
title 'Forward Selection';
model new_arrest (event='1')= d_domestic north south central violent drug stealing summer winter spring d_2009 d_2018 home homvio/
stb corrb rsquare selection=forward;
run; 
*both produce the same model;
*final model with most signiicant variables;
proc logistic data = xv_all;
title 'Final model for xv_all data';
model new_arrest (event='1')= d_domestic north south violent drug stealing summer winter spring d_2009 d_2018 home homvio/
stb corrb rsquare;
run; 

******************************************************************************************
				Model Validation
*The code in this sectio is used for validation via 2 options: 0.5 threshold vs
finding best threshold sing predicted probailites.
******************************************************************************************;

*Calculate phat along with its intervals and create pred data for test data to determine;
* if pred_y for test is > 0.5;
proc logistic data = xv_all;
title 'Validation (fixed threshold)';
model new_arrest (event = '1') = d_domestic north central violent drug stealing summer winter spring d_2009 d_2018 home homvio;
output out=pred(where=(new_arrest=.)) p=phat lower=lcl upper=ucl
predprob=(individual);
run;
*print 10 obs of pred data;
proc print data=pred (obs=10);
run;

* calculats classification results for each obs using 0.5 threshold;
title "Confusion matrix (fixed treshold)";
data probs;
set pred;
pred_y=0;
threshold=0.5;
if phat>threshold then pred_y=1;
run;

* generate confusion matrix for option 2; 
proc freq data = probs;
tables d_arrest*pred_y/norow nocol nopercent;
run;


*Calculate phat along with its intervals and create pred data;
* and generates prob levels from 0.2 to 0.6 so we can find best;
* threshold value;
proc logistic data = xv_all;
title 'Validation (detect best threshold)';
model new_arrest (event = '1') = d_domestic north central violent drug stealing summer winter spring d_2009 d_2018 home homvio/ 
									ctable pprob= (0.2 to 0.6 by 0.05);
output out=pred(where=(new_arrest=.)) p= phat lower=lcl upper=ucl predprob=(individual);
run;


* computes predicted y for test set based on best threshold (0.25);
title "Confusion matrix (detect best threshold)";
data probs;
set pred;
pred_y=0;
threshold=0.30;
if phat>threshold then pred_y=1;
run;

* generate confusion matrix for best threshold (option 3);
proc freq data = probs;
tables d_arrest*pred_y/norow nocol nopercent;
run;
