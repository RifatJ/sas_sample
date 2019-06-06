ods rtf file= 'C:\Users\rifa\Dropbox\BRF\obesity_jamalpur\Obesity_Dhaka_Jamalpur.rtf';
title1 color=bio bcolor=azure'Report Gererated by Rifat Jahan';
footnote color=bio bcolor=azure"On %sysfunc(date(),date9.)";
/*Comparing Maternal perception between schools of Dhaka-Jamalpur*/
proc import datafile='C:\Users\rifa\Dropbox\BRF\obesity_jamalpur\obes_dhaka_vs_jamalpur.csv'
out=obes dbms=csv replace;
	getnames=yes;
run;
title1;
******************11/10/2018**********Main Dataset*********************************;
*Cleaning;
data obes1;
	set obes;
	if moth_age = "NA" then moth_age = .;
	if moth_faminc = "NA" then moth_faminc = .;
	if moth_faminc3 = "NA" then moth_faminc3 = .;
	if moth_nchild = "NA" then moth_nchild = .;

	if sex = "NA" then sex = "";
	if moth_edu = "NA" then moth_edu = "";
	if moth_edu2 = "NA" then moth_edu2 = "";
	if moth_occupation = "NA" then moth_occupation = "";
	if moth_husedu = "NA" then moth_husedu = "";
	if moth_husocc = "NA" then moth_husocc = "";
	if moth_is_cesarian = "NA" then moth_is_cesarian = "";
	if moth_marital = "NA" then moth_marital = "";
	if obes_status = "NA" then obes_status = "";
	if obes_status2 = "NA" then obes_status2 = "";
	if perc_child_obesity = "NA" then perc_child_obesity = "";
	if perc_obes_goodhlth_future = "NA" then perc_obes_goodhlth_future = "";
	if perc_obes_sign_good_health = "NA" then perc_obes_sign_good_health = "";
	if percep_junkfood = "NA" then percep_junkfood = "";
	if percep_playground = "NA" then percep_playground = "";
	if dlife_feel_concerned = "NA" then dlife_feel_concerned = "";
    if dlife_mat_perception = "NA" then dlife_mat_perception = "";
	if dlife_daily_sleep = "NA" then dlife_daily_sleep = "";
	if dlife_device = "NA" then dlife_device = "";
	if perc_peer_pressure2 = "NA" then perc_peer_pressure = "";
	if perc_child_obesity2 = "NA" then perc_child_obesity2 = "";
	if child_age = "NA" then child_age = .;
	if dlife_activhrs_outside= "NA" then dlife_activhrs_outside = "";
	if percep_lack_games ="NA" then percep_lack_games = "";


	if obes_status = 'Underweight' then Under_weight = 1; 
	else  Under_weight = 0;

	if obes_status = 'Healthy Weight' then Normal = 1; 
	else  Normal = 0;

	if obes_status = 'Overweight' then Over_weight = 1; 
	else  Over_weight = 0;

	if obes_status = 'Obese' then Obese = 1; 
	else  Obese = 0;
	
	*consider underweight as missing;
	if obes_status2='Underweight' then OverWtObes=.;
	else if obes_status2 = 'Overweight/Obese' then OverWtObes = 1; 
	else  OverWtObes = 0;

	
	if dlife_mat_perception = 'Lower than normal' then PercUnderweight = 1; 
	else  PercUnderweight = 0;

	if dlife_mat_perception = 'Normal' then PercNormal = 1; 
	else  PercNormal = 0;

	if dlife_daily_sleep in ('9 hours','10 hours','> 10 hours')then Meet_SleepGuideline = 1;
	else if  missing(dlife_daily_sleep) then Meet_SleepGuideline=.;
	else Meet_SleepGuideline=0;

	if dlife_mat_perception = 'Lower than normal' then PercUnderweight = 1; 
	else  PercUnderweight = 0;

	if dlife_mat_perception = 'Overweight/Obese' then PercOverwtObese = 1; 
	else  PercOverwtObese = 0;

	if dlife_device in ('< 1 hour') then Meet_ScreentimeGuideLine = 1;
	else if dlife_device = "" then Meet_ScreentimeGuideLine = .;
	else Meet_ScreentimeGuideLine = 0;

	if missing (dlife_activhrs_outside)   then meet_phyactoutsidehome = .;
	else if dlife_activhrs_outside in ('< 1 hour','Do not know') then meet_phyactoutsidehome = 0;
	else meet_phyactoutsidehome = 1;

	if moth_faminc3 = 2550 then meet_moth_faminc3 = 1;
	else meet_moth_faminc3 = 0;

	if moth_is_cesarian = "No" then moth_is_cesarian2 = 0;
	else moth_is_cesarian2 = 1;

	if missing(moth_nchild) then moth_nchild_new=.;
	else if moth_nchild = 1 then moth_nchild_new = 1;
	else if moth_nchild = 2 then moth_nchild_new = 2;
	else if moth_nchild in (3, 4) then moth_nchild_new=3; 

	

	if perc_other_disease___4 = 'Checked' then meet_health_conseq = 'Dont know';

	else if perc_other_disease___1 = 'Checked' or perc_other_disease___2 = 'Checked' 
	or perc_other_disease___3 ='Checked' or perc_other_disease___5 = 'Checked'
	then meet_health_conseq = 'Yes';

	else meet_health_conseq = " ";  

	if Meet_SleepGuideline = 1 and meet_ScreentimeGuideLine = 1 and meet_phyactoutsidehome =1
	then Meet_all_guideline = 1;
	else if missing(Meet_SleepGuideline)or missing(meet_ScreentimeGuideLine)or missing(meet_phyactoutsidehome)
	then Meet_all_guideline = .;
	else Meet_all_guideline = 0;
 
run;

/*Frequency table for Overweight/Obese by sex*/
proc freq data=obes1;
tables obes_status2*sex; run;

*********************************************************************************;
/*Total non-observations in obes1;*/
proc sql;
select count(record_id) as N
from obes1; quit;

*or perc_other_disease___1 to perc_other_disease___5;
 proc freq data = obes1;
 tables OverWtObes;
 run;

%FreqTable(perc_other_disease___1);
%FreqTable(perc_other_disease___2);
%FreqTable(perc_other_disease___3);
%FreqTable(perc_other_disease___4);
%FreqTable(perc_other_disease___5);

%FreqTable(meet_phyactoutsidehome);



/*Data preprocessing*/
/*macro for FreqTable*/
libname rifa "C:\Users\rifa\Dropbox\BRF\obesity_jamalpur";
options mstored sasmstore=rifa;
%macro FreqTable(var)/store;
proc freq data=obes1;
tables &var;
run;
%mend FreqTable;

/*macro variable for title*/
%macro title (f)/store;
"Mother's &f by School Type";
%mend title;

/*Chisq test for categorical variable*/
%macro ChisqTest(var)/store;
proc freq data=obes1;
tables &var*school_code/norow chisq relrisk riskdiff expected;
exact or;
format school_code schoolfmt.;
run;
%mend;

/*Fisher Exact Test for categorical variable, where cells have expected counts<5*/
%macro FisherExact(var)/store;
proc freq data=obes1;
tables &var*school_code/norow nopercent fisher;
format school_code schoolfmt.;
run;
%mend;


/*school_code 8 and 9 means JamalpurSchool and 1 means DhakaSchool*/
title2 c=blue h=2 'Frequency table for school_code';
/*Freq table for school_code*/
		proc freq data=obes1;
		tables school_code;
		run;
title2 c=blue h=2 'No of records by school';
proc format;
	value schoolfmt
		1 = DhakaSchool
		8,9 = 'JamalpurSchool'
		;		;
		run;

/*How many records for JamalpurSchool*/
		proc sql;
		select count(school_code) as JamalpurRecord_No
		from obes1
		where school_code in (8, 9);
		run;

/*How many records for DhakaSchool*/
		proc sql;
		select count(school_code) as DhakaRecord_No 
		from obes1
		where school_code =1;
		run;
/*How many Total records*/
		proc sql;
		select count(school_code) as Total_records 
		from obes1
		run;
/**/


/*Table 01 - Demography---11/08/2018*/
/*Age average (SD) of mother for col - Total */
title1 c=bio bcolor=beige f=b h=4 underlin=3 "Table 01 - Demographic Information";
title2 c=blue h=2 'Table for Mother age'; 
proc means data=obes1;
*class school_code;
var moth_age;
*format school_code schoolfmt.;
run;
/*Performing Two-smaple T-Test for moth_age*/
title2 c=blue h=2 'Two Sample T-Test for Mother Age';
proc ttest data=obes1;
class school_code;
var moth_age;
format school_code schoolfmt.;
run; title2;

*******;
/*Age average (SD) of child for col - Total */
title2 c=blue h=2 'Table for Child age';
proc means data=obes1;
*class school_code;
var child_age;
*format school_code schoolfmt.;
run;
/*Performing Two-smaple T-Test for moth_age*/
title2 c=cblue h=2 'Two Sample T-Test for Child Age';
proc ttest data=obes1;
class school_code;
var child_age;
format school_code schoolfmt.;
run; title1;

/*Test for Mother Education*/
title2 c=blue h=2 %title(Education);
%FreqTable(moth_edu);
%FisherExact(moth_edu);

/*Test for Mother Occupation*/
title2 c=blue h=2 %title(Occupation);
%FreqTable(moth_occupation);
%FisherExact(moth_occupation);

/*Test for Mother Marital Status*/
title2 c=blue h=2 %title(Marital Status);
%FreqTable(moth_marital);
%FisherExact(moth_marital);

/*Test for Husband's Education Status*/
title2 c=blue h=2 %title(Husband Education);
%FreqTable(moth_husedu);
%FisherExact(moth_husedu);

/*Test for Husband's Occupation Status*/
title2 c=blue h=2 %title(Husband Occupation);
%FreqTable(moth_husocc);
%FisherExact(moth_husocc);

/*Test for Family Income*/
title2 c=blue h=2 %title(Monthly Family Income);
%FreqTable(moth_faminc);
%FisherExact(moth_faminc);

/*Test for No. of Living  Children*/
	**Categorizing for No of Living Children;
title2 c=blue h=2  "Table No of Living Children";
	proc format;
		value livechildfmt
			1,2 = "1 - 2 kids"
			3,4 = "more than 2 kids"
			;
			run;
*freq by school;
		
		*For Total freq;
		proc freq data=obes1;
		tables moth_nchild;
		format moth_nchild livechildfmt.;
		run;
		proc freq data=obes1;
		tables moth_nchild*school_code/norow nopercent fisher;
		format school_code schoolfmt. moth_nchild livechildfmt.;
		run;


/*Test for Mode of Delivery*/
title2 c=blue h=2  "Table Mode of delivery";
%FreqTable(moth_is_cesarian);
%FisherExact(moth_is_cesarian);



/*TABLE-2 calculation*/

	/*Actual-weight status for each single category-*/
title1 c=bio bcolor=beige f=b h=4 underlin=3 "TABLE-2 Analysis";
title2 c=blue h=2 %title(Actual Weight Status);
%FreqTable(obes_status);
%FisherExact(obes_status);

title2 c=blue h=2 'Frequency table for Normal weight by school type';
proc freq data= obes1;
tables Normal*school_code/norow nopercent chisq relrisk riskdiff expected;
exact or;
format school_code schoolfmt.;
run;	

*p-val for Overweight;
title2 c=blue h=2  'Frequency table for Over weight by school type';
proc freq data= obes1;
tables Over_weight*school_code/norow nopercent chisq relrisk riskdiff expected;
exact or;
format school_code schoolfmt.;
run;	

*p-val for obese;
title2 c=blue h=2 'Frequency table for Obese by school type';
proc freq data= obes1;
tables Obese*school_code/norow nopercent chisq relrisk riskdiff expected;
exact or;
format school_code schoolfmt.;
run;

/*p-val for Obese/Overweight which is from obes_status2 - variable*/
title2 c=blue h=2 'Frequency table for Overweight/Obese by school type';
proc freq data= obes1;
tables OverWtObes*school_code/norow nopercent chisq relrisk riskdiff expected;
exact or;
format school_code schoolfmt.;
run;

/*Perceived-weight status for each single category*/

	/*Test for Lower than normal i.e. Underweight*/

title2 c=blue h=2 %title(Perceived Weight Status);
%FreqTable(dlife_mat_perception);
%FisherExact(dlife_mat_perception);

title2 c=blue h=2 'Frequency Table for Perceived Under Weight Status';
proc freq data= obes1;
tables PercUnderweight*sex/norow nopercent chisq relrisk riskdiff expected;
exact or;
*format school_code schoolfmt.;
run;	

title2 c=blue h=2 'Frequency Table for Perceived Normal Weight Status';
proc freq data= obes1;
tables PercNormal*school_code/norow nopercent chisq relrisk riskdiff expected;
exact or;
format school_code schoolfmt.;
run;

/*Frequenct table of Overweight/Obese by School Type*/
title2 c=blue h=2 'Frequency Table for Perceived Overweight/Obese Status by SchoolType';
proc freq data= obes1;
tables PercOverwtObese*school_code/norow nopercent chisq relrisk riskdiff expected;
exact or;
format school_code schoolfmt.;
run;

/*Frequenct table of Overweight/Obese by sex(Boys and girls)*/
title2 c=blue h=2 'Table for Overweight/Obese Status by Sex';
proc freq data= obes1;
tables obes_status*sex/norow nopercent chisq relrisk riskdiff expected;
exact or;
*format school_code schoolfmt.;
run;


/*TABLE-6 calculation-Test of Actual-weight and Perceived-weight by sex*/

	/*Actual-weight status for each single category-by sex*/
title1 c=bio bcolor=beige f=b h=4 underlin=3 "TABLE-6 Analysis";
title2 c=blue h=2 %title(Actual Weight Status by sex);
/*obes_status Freq table by sex*/
proc freq data=obes1;
tables obes_status*sex;
run;

*%FisherExact(obes_status);
title2 c=blue h=2 'Frequency table for Underweight by sex';
proc freq data= obes1;
tables Under_weight*sex/norow nopercent chisq relrisk riskdiff expected;
exact or;
*format school_code schoolfmt.;
run;

title2 c=blue h=2 'Frequency table for Normal weight by sex';
proc freq data= obes1;
tables Normal*sex/norow nopercent chisq relrisk riskdiff expected;
exact or;
*format school_code schoolfmt.;
run;	

*p-val for Overweight;
title2 c=blue h=2  'Frequency table for Over weight by sex';
proc freq data= obes1;
tables Over_weight*sex/norow nopercent chisq relrisk riskdiff expected;
exact or;
*format school_code schoolfmt.;
run;	

*p-val for obese;
title2 c=blue h=2 'Frequency table for Obese by sex';
proc freq data= obes1;
tables Obese*sex/norow nopercent chisq relrisk riskdiff expected;
exact or;
*format school_code schoolfmt.;
run;

/*p-val for Obese/Overweight which is from obes_status2 - variable*/
title2 c=blue h=2 'Frequency table for Overweight/Obese by school type';
proc freq data= obes1;
tables OverWtObes*sex/norow nopercent chisq relrisk riskdiff expected;
exact or;
*format school_code schoolfmt.;
run;

/*Perceived-weight status for each single category*/

	/*Test for Lower than normal i.e. Underweight*/

title2 c=blue h=2 %title(Perceived Weight Status);
title2 c=blue h=2 'Frequency Table for Perceived Under Weight Status';
proc freq data= obes1;
tables PercUnderweight*sex/norow nopercent chisq relrisk riskdiff expected;
exact or;
*format school_code schoolfmt.;
run;	

title2 c=blue h=2 'Frequency Table for Perceived Normal Weight Status';
proc freq data= obes1;
tables PercNormal*sex/norow nopercent chisq relrisk riskdiff expected;
exact or;
*format school_code schoolfmt.;
run;

/*Frequenct table of Overweight/Obese by sex*/
title2 c=blue h=2 'Frequency Table for Perceived Overweight/Obese Status by Sex';
proc freq data= obes1;
tables PercOverwtObese*sex/norow nopercent chisq relrisk riskdiff expected;
exact or;
*format school_code schoolfmt.;
run;

/*Frequenct table of Overweight/Obese by sex(Boys and girls)*/
title2 c=blue h=2 'Table for Overweight/Obese Status by Sex';
proc freq data= obes1;
tables obes_status*sex/norow nopercent chisq relrisk riskdiff expected;
exact or;
*format school_code schoolfmt.;
run;


**************************************************************************;
/*TABLE -3*/
/*Perception and knowledge of childhood overweight and obesity*/

	*Maternal Perception;

/*Childhood obesity is a health problem*/
title1 c=bio bcolor=beige f=b h=3 underlin=3 "Table 3. Perception and knowledge of childhood overweight and obesity";
title2 c=blue h=2 %title(Perception About Childhood Obesity);
%ChisqTest(perc_child_obesity);
 /*Create format for perc_child_obesity*/
proc format;
value $childobes
'It is not a severe health problem','It is a general health problem','It is a severe health problem' = 'Yes'
'It is not at all a problem' = 'No'
'Do not know' = 'Dont know'
;
proc freq data=obes1;
tables perc_child_obesity*school_code/norow chisq relrisk riskdiff expected;
exact or;
format school_code schoolfmt. perc_child_obesity $childobes.;
run;			

/*Childhood obesity is a sign of good health -- perc_obes_sign_good_health*/

title2 c=blue h=2 %title(Perception About Childhood Obesity is a Sign of Good Health);
%ChisqTest(perc_obes_sign_good_health);

/*An obes child will be healthy when becomes adult*/

title2 c=blue h=2 %title(Perception About Obese Child Will be Healthy When Becomes Adult );
%ChisqTest(perc_obes_goodhlth_future);

/*Creating format for perc_obes_goodhlth_future*/
proc format;
value $goodhlfuture
	'May be or may not be','Do not know' = 'Dont know'
	;
proc freq data=obes1;
tables perc_obes_goodhlth_future*school_code/norow chisq relrisk riskdiff expected;
exact or;
format school_code schoolfmt. perc_obes_goodhlth_future $goodhlfuture.;
run;		
	 
*************************;
/*Factors Contributing Childhood Obesity*/
title2 c=blue h=3 underlin=2 f=b "Factors Contributing Childhood Obesity";

/*Consuming junkfood*/
title2 c=blue h=2 %title(Perception About Consuming Junkfood);
%ChisqTest(percep_junkfood);
	
/*Lack of Physical Activity*/
title2 c=blue h=2 %title(Perception About Lack of Physical Activity);
%ChisqTest(percep_lack_games);

/*Spending more than 2 hrs screen time--dlife_device*/
title2 c=blue h=2 %title(Perception About Spending More Than 2 hrs Screen Time);
%FreqTable(dlife_device);
	
	proc format;
		value $hrsfmt
			'< 1 hour','2 hours' = 'le 2 hrs'
			'3 hours' - '5 hours or more' = 'gt 2 hrs'
			'Do not know' = 'Dont know'
			;
			run;
proc freq data=obes1;
tables dlife_device*school_code/norow chisq relrisk riskdiff expected;
exact or;
format school_code schoolfmt. dlife_device $hrsfmt.;
run;

/*Lack of Play Ground*/
title2 c=blue h=2 %title(Perception About Lack of Play Ground);
%ChisqTest(percep_playground);

/*****Knowledge of any health consequences of childhood**************************/
title2 c=blue h=2 f=b %title(Perception About Knowledge of Any Health Consequences of Childhood Obesity);
%FreqTable(meet_health_conseq);
%ChisqTest(meet_health_conseq);

/*
    proc freq data=obes1;
	tables meet_health_conseq*school_code/norow chisq relrisk riskdiff expected;
	exact or;
	format school_code schoolfmt.;
	run;
*/

**************************************************************************;

/*Table - 04*/
	/*Proportion for children not meeting guideline*/
title1 c=bio bcolor=beige h=4 underlin=3 f=b "Table 4.Proportion for children not meeting guideline ";
title2 c=blue h=2 %title(Perception About Daily Sleep);
%FreqTable(dlife_daily_sleep);
%ChisqTest(dlife_daily_sleep);

	proc format;
		value $dsleepfmt
			'6 hours' - '8 hours' = '<9 hrs/day'
			'9 hours','10 hours','> 10 hours' = '>9 hrs/day'
			;
			run;
	proc freq data=obes1;
	tables dlife_daily_sleep*school_code/norow chisq relrisk riskdiff expected;
	exact or;
	format dlife_daily_sleep $dsleepfmt. school_code schoolfmt.;
	run;
	/*p-value for '<9 hrs/day'*/
	proc freq data=obes1;
	tables Meet_SleepGuideline*school_code/norow chisq relrisk riskdiff expected;
	exact or;
	format school_code schoolfmt.;
	run; 

/* Screen time*/
	title2 c=blue h=2 %title(Perception About Screen Time);
	proc freq data=obes1;
	tables Meet_ScreentimeGuideLine*school_code/norow chisq relrisk riskdiff expected;
	exact or;
	format school_code schoolfmt.;
	run;

	
/*Physical Activity Outside of Home*/
	title2 c=blue h=2 %title(Perception About Physical Activity Outside of Home);
	%FreqTable(dlife_activhrs_outside);

/*Meet all guidelines*/
	title2 c=blue h=2 %title(Perception About Meeting All Guidelines);
	%FreqTable(Meet_all_guideline);

	/*P-value for Physical Activity Outside of Home(<1 hr/day)*/
	proc freq data=obes1;
	tables meet_phyactoutsidehome*school_code/norow chisq relrisk riskdiff expected;
	exact or;
	format school_code schoolfmt.;
	run;
	****************************************************************************;

/*Table - 05*/
	
/*OR to show the association between Overweight/Obese and sex*/
title1 c=bio bcolor=beige f=b h=4 underlin=3 "Table 5. Odds Ratio";
title2 c=blue h=2 'Model for OR for Overweight/Obese and Sex';
proc freq data=obes1;
tables OverWtObes*sex; run;

proc logistic data = obes1;
class sex OverWtObes(ref='0');
*model OverWtObes = sex/expb;
model OverWtObes = sex/risklimits rsquare;
run;

/*OR to show the association between Overweight/Obese and Mother Education*/

title2 c=blue h=2 "Model for OR for Overweight/Obese and Mother's education ";
proc logistic data=obes1;
class moth_edu2;
model OverWtObes(ref='0') = moth_edu2/risklimits rsquare;
run;

/*OR to show the association between Overweight/Obese and Mother Family Income*/
/*in moth_faminc3 - 10 means <25*/

title2 c=blue h=2 'Model for OR for Monthly Income';
%FreqTable(moth_faminc3);
proc freq data=obes1;
tables OverWtObes*moth_faminc3;run;

proc logistic data=obes1;
class moth_faminc3(ref='10');
model OverWtObes(ref='0') = moth_faminc3/risklimits rsquare;
run;


/*24 hours activities (Sleep, PA, screen time)*/
title2 c=blue h=2 'Model for OR for Sleeping Guideline';
%FreqTable(Meet_SleepGuideline);
proc freq data=obes1;
tables OverWtObes*Meet_SleepGuideline; run;
*Sleep;
proc logistic data=obes1;
class Meet_SleepGuideline(ref='0');
model OverWtObes(ref='0') = Meet_SleepGuideline/risklimits rsquare;
run;


title2 c=blue h=2 'Model for OR for Screen time';
*Screentime;
proc freq data=obes1;
tables OverWtObes*meet_ScreentimeGuideLine; run;

proc logistic data=obes1;
class meet_ScreentimeGuideLine(ref='0');
model OverWtObes(ref='0') = meet_ScreentimeGuideLine/risklimits rsquare;
run;


*Physical Activity Outside Home - meet_phyactoutsidehome;

title2 c=blue h=2 'Model for OR for Physical Activity Outside Home';
proc freq data=obes1;
tables OverWtObes*meet_phyactoutsidehome; run;

proc logistic data=obes1;
class meet_phyactoutsidehome(ref='0');
model OverWtObes(ref='0') = meet_phyactoutsidehome /risklimits rsquare;
*where school_code in (8, 9);*Sig for Jamalpur->OR=4.427, CI=1.18-16.67,CI-doesn't contain 1;
*where school_code = 1;  *Notsig for Dhaka-->OR=1.194 and CI=0.428-8.794, CI contains 1;
run;

*Meeting Physical Activity - Meet_all_guideline***OR and AOR can't be done here;
title2 c=blue h=2 'Model for OR for Meeting All Guidelines';
proc freq data=obes1;
tables OverWtObes*Meet_all_guideline; run;
*model can't be fitted for Meet_all_guideline;
/*
proc logistic data=obes1;
class Meet_all_guideline(ref='0');
model OverWtObes(ref='0') = Meet_all_guideline/risklimits rsquare;
run;*/

/*Peer Pressure2 -- check from obes1-dataset->is 0 means No and 1 means Yes*/
title2 c=blue h=2 'Model for OR for Perception of Peer Pressure';
%FreqTable(perc_peer_pressure2);
proc freq data=obes1;
tables OverWtObes*perc_peer_pressure2; run;

proc logistic data=obes1;
class perc_peer_pressure2(ref='0');
model OverWtObes(ref='0') = perc_peer_pressure2/expb;
run;

/*Perception: Obesity is a health problem*/
title2 c=blue h=2 'Model for OR for Perception: Obesity is a health problem';
%FreqTable(perc_child_obesity2);
proc freq data=obes1;
tables OverWtObes*perc_child_obesity2; run;

proc logistic data=obes1;
class perc_child_obesity2;
model OverWtObes(ref='0') = perc_child_obesity2/expb;
run;

/*Cesarian delivery*/
title2 c=blue h=2 'Model for OR for Mode of Delivery';
%FreqTable(moth_is_cesarian2);
proc logistic data=obes1;
class moth_is_cesarian2(ref='0');
model OverWtObes(ref='0') = moth_is_cesarian2/expb;
run;


/*No of child*/
title2 c=blue h=2 'Model for OR for No of Child';
%FreqTable(moth_nchild_new);

proc logistic data=obes1;
class moth_nchild_new(ref='1');
model OverWtObes(ref='0') = moth_nchild_new/risklimits rsquare;
run;

title1 c=blue h=3 underlin=3 f=b "Table 5. Adjusted Odds Ratio";
title2 c=blue h=2 'Model for AOR';
proc logistic data=obes1;
class sex moth_edu2 moth_nchild_new(ref='1') moth_is_cesarian2(ref='0') perc_peer_pressure2(ref='0') 
				   meet_phyactoutsidehome(ref='0')  meet_ScreentimeGuideLine(ref='0') 
				   Meet_SleepGuideline(ref='0') moth_faminc3(ref='10') perc_child_obesity2;
model OverWtObes(ref='0') = sex moth_edu2 moth_faminc3 Meet_SleepGuideline
					meet_ScreentimeGuideLine meet_phyactoutsidehome
					perc_peer_pressure2 perc_child_obesity2 
					moth_is_cesarian2 moth_nchild_new/risklimits rsquare;
					   
	    
				    
run;
ods rtf close;


proc freq data=obes1;
tables meet_phyactoutsidehome * OverWtObes /chisq;
run;











