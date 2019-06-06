/*************11/21/2018************************/
ods rtf file="C:\Users\rifa\Documents\SAS_Clinical\Project\clinicalproject\clinicalproject\pooled_clinical.rtf";
/*All and only the SAS-files will be stord to rifat-library from the give path*/
libname rifat "C:\Users\rifa\Documents\SAS_Clinical\Project\clinicalproject\clinicalproject\Data";

/*Cleaning data - Final dataset*/
data test_pooled_Final;
	set rifat.test_pooled;
	length don_rel_1 $ 15;
	*categorizing according to the donor relationship with recipients;
	if don_rel = "mother" or don_rel = "father" then don_rel_1 = "Related";
	else if don_rel = "wife" then don_rel_1 = "Spousal";
	else don_rel_1 = "Unrelated";
	*Remove wrong value "femle" from the don_sex variable;
	if don_sex = "femle" then don_sex = " ";
	*Converting gra_func_creatine_3day-var and others from Ch to numeric;
	day3 = input(gra_func_creatine_3day, 5.2);
	day7 = input(gra_func_creatine_7day, 5.2); 
	day15= input(gra_func_creatine_15day, 5.2);
	day30= input(gra_func_creatine_30day, 5.2);
	day90= input(gra_func_creatine_90day, 5.2);
	day180= input(gra_func_creatine_6months, 5.2);
	day360 = input(gra_func_creatine_6months, 5.2);
	day720= input(gra_func_creatine_2year, 5.2);
run;
/*Dataset for rec_hb-variables*/
data hb_numeric;
	set rifat.test_pooled;
	*Converting rec_hb_day-variables to numeric;
	day0=input(rec_hb_0day, 5.2);
	day3=input(rec_hb_3day, 5.2);
	day7=input(rec_hb_7day, 5.2);
	day14=input(rec_hb_14day, 5.2);
	day30=input(rec_hb_30day, 5.2);
	day90=input(rec_hb_90day, 5.2);
	day180 =input(rec_hb_6months, 5.2);
	day360=input(rec_hb_1year, 5.2);
	day720=input(rec_hb_2year, 5.2);
run;
/*
proc freq data=test_pooled_Final;
tables day0_hb day360_hb day720_hb;
run;*/
  
title1 c=blue h=4 underlin=2 f=b justify=left "Pooled RESULTS: ";
title2 c=brbl h=4 underlin=3 f=b justify=left "DEMOGRAPHIC SUMMARY REPORTS";

/*Table 1 - Age analysis for Recipient and Donor*/
title3 c=brbl h=2 justify=center "Table 1: Age Analysis";
proc tabulate data=rifat.test_pooled;
var rec_age don_age;
table (rec_age="Recipient" don_age="Donor"), Mean Stddev="Std"/box="Category";
run;

/*Table 2 - Relationship of recipient with donor*/
title1 c=brbl h=2 "Table 2:Relationship of recipient with donor";
title2 justify=left h=4 f=b move=(+0,+20)c=red "mother" c=brbl", father-:Related";   
title3 j=left h=4 c=brbl f=b "wife-:Spousal";
title4 j=left h=4 c=brbl f=b "Other-:Unrelated";

proc tabulate data=test_pooled_final;
class don_rel_1;
tables don_rel_1="", N = "Number of Records"/box="Category";
run;

/*Table 3:  Gender Analysis*/
title1 c=blue h=2 j=center "Table 3:  Gender Analysis";
proc tabulate data=test_pooled_final;
class rec_sex don_sex;
tables (All='Recipient' rec_sex=""  All='Donors' don_sex=""), N="Total" /box="Category";
run;

/*LAB SUMMARY REPORTS:*/
/*Table 4: Analysis of Serum Creatinine on Different Days*/
title1 c=brbl h=4 j=left underlin=3 f=b "LAB SUMMARY REPORTS:";
title2 c=brbl h=2 j=center "Table 4: Analysis of Serum Creatinine on Different Days";

/*using proc tabulate*/
proc tabulate data=test_pooled_final; 
var day3 day7 day15 day30 day90 day180 day360 day720;
tables(day3 day7 day15 day30 day90 day180 day360 day720),
	  N='No of records' Mean stddev='Std' Range/box='day';
run; 

/*Plot1: Analysis of Serum Creatinine on Different Days*/
  title1 c=brbl h=2 f=b "Plot1: Analysis of Serum Creatinine on Different Days";
  data creatine;
 	set test_pooled_final;
	keep rownum day3 day7 day15 day30 day90 day180 day360 day720;
	rownum = _n_;*_n_ will auto generate the rownumber;
  run;

*Transpose the data to create a day var column and another column will be with values;
proc sort data=creatine out=creatine_sort;
*by day3 day7 day15 day30 day90 day180 day360 day720;
by rownum;
run;

proc transpose data=creatine out=serum;
by rownum;
run;

data serum;
set serum;
rename _name_ = Day Col1 = creatine;
drop rownum;
run;

proc sort data= serum;
by day;
run;

proc means data=serum Mean;
by day;*mean-value will come for every group of day-var;
var creatine;
output out=serum_dat mean = creatine_mean;
run;

/*creating dataset to write day3, day7...serially*/
data serum_sort;
set serum_dat;
if day='day3' then id_day = 1;
if day = 'day7' then id_day = 2;
if day = 'day15' then id_day = 3;
if day = 'day30' then id_day = 4;
if day = 'day90' then id_day = 5;
if day = 'day180' then id_day = 6;
if day = 'day360' then id_day = 7;
if day = 'day720' then id_day=8;
run;

proc sort data=serum_sort; 
by id_day;
run;

/*creating macro for sgplot*/
proc sgplot data=serum_sort;
	title1 "Plot1 using SGPLOT";
	*series x=day y=creatine_mean/markers;
	series x=day y=creatine_mean/smoothconnect 
	markers markerattrs=(color=blue size=14 symbol=CircleFilled) 
	lineattrs=(color=red thickness=3);
	yaxis label="mean" values=(1.46 to 1.76 by 0.02)display=all;
	xaxis label="Day";
run;

************proc gplot***************************;
*sort the data;
proc sort data=serum_sort;
by id_day;
run;
*Set the options first, use SMnn-option to draw the smooth plot;
goptions reset=global;
symbol1 interpol=smnn ci=red  value=dot h=1 color=blue;
axis1 label=(f='arial/bo' h=2 "Day")
	 order = "day3" "day7" "day15" "day30" "day90" "day180" "day360"
			  "day720";
axis2 label=(f='arial/bo' h=2 "Mean") 
	  order=1.46 to 1.76 by 0.02;


proc gplot data=serum_sort;
plot creatine_mean*day/haxis=axis1 vaxis=axis2;
title1"Plot1 using proc gplot";
run;

/*Plot using proc gplot*/
/*
proc sort data=serum_sort;
by day; run;

proc gplot data=serum_sort;
plot creatine_mean*day;
symbol1 interpol=SMnn value=circle height=2; *//* note that x is sorted */


/*TABLE 5: ANALYSIS OF HB IN DIFFERENT DAYS*/
title1 c=blue h=4 f=b j=center"TABLE 5: ANALYSIS OF HB IN DIFFERENT DAYS";
proc tabulate data=hb_numeric;
var day0 day3 day14 day30 day90 day180 day360
	day720;
tables (day0 day3 day14 day30 day90 day180 
		day360 day720), N Mean Stddev Range;
run;

/*PLOT 2: ANALYSIS OF HB IN DIFFERENT DAYS*/
*proc print data=test_pooled_Final; run;
title1 c=blue h=2 f=b j=center "PLOT 2: ANALYSIS OF HB IN DIFFERENT DAYS";
/*creating a Day-col and a column with correspoding values*/
data hb;
	set hb_numeric;
	keep rownumber day0 day3 day14 day30 day90 day180
		 day360 day720;
*generating rownumber by _n_ to use transpose;
	rownumber = _n_;
run; 

proc sort data=hb;
by rownumber;
run;
proc transpose data=hb 
out=hb_trans(rename=(_NAME_=day COL1=hb));
by rownumber;
run;

/*getting mean by each hb-group*/
proc sort data=hb_trans
out=hb_trans_day;
by day; run;
proc means data=hb_trans_day;
by day;
var hb;
output out=hb_trans_mean mean=hbmean;
run;

/*need to sort data by day and that's why generating an id-col*/
data hb_trans_mean_id;
	set hb_trans_mean;
	if day='day0' then id=1;
	if day='day3' then id=2;
	if day='day14' then id=3;
	if day='day30' then id=4;
	if day='day90' then id=5;
	if day='day180' then id=6;
	if day='day360' then id=7;
	if day='day720' then id=8;
run;
/*Sorting mean by day_id*/
proc sort data=hb_trans_mean_id;
by id;
run;
/*sgplot*/
title1 c=blue h=2 justify=center "Table 2: HB Plot using sgplot";
proc sgplot data=hb_trans_mean_id;
series x=day y=hbmean/smoothconnect
markers markerattrs=(color=blue size=14 symbol=CircleFilled)
lineattrs=(color=red thickness=1);
yaxis label="Mean" values=(8 to 14 by 1)display=all;
xaxis label="Day";
run;

/*Proc gplot*/
***************;
title1 c=blue h=2 justify=center "HB Plot using proc gplot";
goptions reset=global;
symbol1 interpol=SMnn ci=red value=dot h=2 color=blue;
axis1 label=(f='arial/bo' h=2 "Day")
		order="day0" "day3" "day7" "day14" "day30" "day90" "day180" "day360"
			  "day720";
axis2 label=(f='arial/bo' h=2 "Mean")
		order=8 to 14 by 1;

proc gplot data=hb_trans_mean_id;
plot hbmean*day/haxis=axis1 vaxis=axis2;
run;
 

/*TABLE 6: ANALYSIS OF PLATELETS IN DIFFERENT DAYS*/
/*dataset for PLATELETS, converting to numeric*/
title1 c=blue h=2 f=b j=center "TABLE 6: ANALYSIS OF PLATELETS IN DIFFERENT DAYS";
data platelets;
	set rifat.test_pooled;
	day0=input(rec_platelets_0day, 12.);
	day3=input(rec_platelets_3day, 12.);
	day7=input(rec_platelets_7day, 12.);
	day14=input(rec_platelets_14day, 12.);
	day30=input(rec_platelets_30day, 12.);
	day90=input(rec_platelets_90day, 12.);
	day180=input(rec_platelets_6months, 12.);
	day360=input(rec_platelets_1year, 12.);
	day720=input(rec_platelets_2year, 12.);
	keep _id day0 day3 day7 day14 day30 day90 day180 day360 day720; 
	_id = _n_;
run;

/*converting data to long format*/
proc sort data=platelets;
by _id;
run;
proc transpose data=platelets 
out=platelets_trans(rename=(_NAME_=day COL1=Platelet));
by _id;
run;

/*getting mean*/
proc sort data=platelets_trans
out=platelets_trans_day;
by day;
run;

proc means data=platelets_trans_day;
by day;
var Platelet;
	output out=platelet_mean_t mean=plateletmean;
run; 

/*again generating*/
data platelet_mean_t;
	set platelet_mean_t;
	if day="day0" then id=1;
	if day="day3" then id=2;
	if day="day7" then id=3;
	if day="day14" then id=4;
	if day="day30" then id=5;
	if day="day90" then id=6;
	if day="day180" then id=7;
	if day="day360" then id=8;
	if day="day720" then id=9;
run;

/*sgplot-plotting*/
proc sort data=platelet_mean_t;
*out=platelet_mean_scaling;
by id;
run;

/*change scale of plateletmean*/
/*
data platelet_mean_scaling;
	set platelet_mean_scaling;
    plateletmean_scaled= plateletmean*100;
run;*/

/*proc gplot*/
goptions reset=global;

symbol1 interpol=SMnn ci=red value=dot c=blue;
axis1 label=(f='arial/bo' "day")
	order="day0" "day3" "day7" "day14" "day30" "day90" "day180" "day360" "day720";
axis2 label=(f='arial/bo' "mean");

proc gplot data=platelet_mean_t;
title1 "PLT Plot using proc gplot";
plot plateletmean*day/haxis=axis1 vaxis=axis2;
run; 

********************************************************;
/*proc sgplot*/
proc sgplot data=platelet_mean_t;
title1 c=black j=center h=3 "PLT Plot using proc sgplot";
series x=day y=plateletmean/smoothconnect
markers markerattrs=(color=blue size=14 symbol=CircleFilled)
lineattrs=(color=red thickness=1);
yaxis label="Mean" display=all;
xaxis label="Day";
run;

/*Table 7. Analysis of Urine Test*/
title1 c=blue h=2 f=b j=center "Table 7. Analysis of Urine Test";
data urine;
	set rifat.test_pooled;
	keep _id rec_urine_r_e_0day rec_urine_r_e_3day rec_urine_r_e_7day
		 rec_urine_r_e_14day rec_urine_r_e_30day rec_urine_r_e_90day
		 rec_urine_r_e_6months rec_urine_r_e_1year rec_urine_r_e_2years;
	_id = _n_;
run;


/*proc tabuate doesn't work
proc tabulate data=rifat.test_pooled;
*class  rec_urine_r_e_3day rec_urine_r_e_7day rec_urine_r_e_14day;
table  rec_urine_r_e_3day='day3' rec_urine_r_e_7day='day7' rec_urine_r_e_14day ='day14', N;
run;
*/
proc sql;
create table urine_count as
select  count(rec_urine_r_e_0day)as day0, count(rec_urine_r_e_3day) as day3, count(rec_urine_r_e_7day) as day7,
		count(rec_urine_r_e_14day) as day14, count(rec_urine_r_e_30day) as day30,
		count(rec_urine_r_e_90day) as day90, count(rec_urine_r_e_6months) as day180,
		count(rec_urine_r_e_1year) as day360, count(rec_urine_r_e_2years) as day720 
from rifat.test_pooled;
quit;

proc transpose data=urine_count
out=urine_count_trans(rename=(_NAME_=Day COL1=No_of_records));
run;

proc print data=urine_count_trans label noobs;
label
	Day = 'Day'
	No_of_records = 'No of records';
run;

/*Table 8: Analysis of CD3 in different days*/

title1 c=blue h=2 f=b j=center "Table 8: Analysis of CD3 in different days";

/*data preparation*/
data cd3;
	set rifat.test_pooled;
	keep _id rec_cd3_0day rec_cd3_3day rec_cd3_7day rec_cd3_14day rec_cd3_30day
		 rec_cd3_90day rec_cd3_6months rec_cd3_1year rec_cd3_2year;
	_id = _n_;
run;

/*converting to numeric*/
data cd3(keep=rec_cd3_0day rec_cd3_3day Day0 Day3 Day7 Day14 Day30 Day90 Day180 Day360 Day720);
	set cd3;
    Day0_subs=substr(rec_cd3_0day,1,7);
	*converting to numeric;
	Day0 = input(Day0_subs, comma12.);
	Day3 = input(rec_cd3_3day, 11.);
	Day7 = input(rec_cd3_7day, 12.);
	Day14 = input(rec_cd3_14day, 11.);
	Day30 = input(rec_cd3_30day, 12.);
	Day90 = input(rec_cd3_90day, 12.);
	Day180 = input(rec_cd3_6months, 12.);
	Day360 = input(rec_cd3_1year, 12.);
	Day720 = input(rec_cd3_2year, 12.);
	
run;

proc tabulate data=cd3;
var Day0 Day3 Day7 Day14 Day30 Day90 Day180 Day360 Day720;
tables (Day0 Day3 Day7 Day14 Day30 Day90 Day180 Day360 Day720), 
		N='No of records' Mean Stddev Range/box='Day';
run;

/*PLOT 4: ANALYSIS ON CD3 IN DIFFERENT DAYS*/
*Since 'Day' and 'Mean' are not two variables of cd3-dataset;
/*transpose the cd3-dataset to make all-Day in one column and mean-values in other column*/
/*generating and id-column to sort the variable*/
title1 c=blue f=b h=2 j=center "PLOT 4: ANALYSIS ON CD3 IN DIFFERENT DAYS";
data cd3;
	set cd3;
	_id=_n_;
run;

/*using by-var means the values will be sorted by grouping in ascending order*/
proc transpose data=cd3
	out=cd3_transpose(rename=(_NAME_=Day COL1=cd3));
by _id;*same _id will be grouped and all values will be in one single column;	
run; 

/*sorting by Day before using proc means*/
proc sort data=cd3_transpose
out=cd3_sorted;
by Day;
run;

/*getting mean-value for each single Day-value*/
proc means data=cd3_sorted;
by Day;*will give mean for each group of values;
var cd3;
	output out=cd3_means mean=meancd3;
run; 

/*Now need to order Day-value for the plot, so generate and _id-column*/
data cd3_means;
	set cd3_means;
	drop _freq_ _TYPE_;*ca't use drop as statement in proc-step;
	if Day='Day0' then  id= 1;
	if Day='Day3' then id = 2;
    if Day='Day7' then id = 3;
	if Day='Day14' then id = 4;
	if Day = 'Day30' then id = 5;
	if Day = 'Day90' then id = 6;
	if Day = 'Day180' then id = 7;
	if Day = 'Day360' then id = 8;
	if Day='Day720' then id = 9;
run;
/*Now Sorting by id_day */
proc sort data=cd3_means out=cd3_pooled_means(rename=(meancd3=cd3_p_mean));
by id;
run;

/*plotting SGplot-CD3*/
/*
proc sgplot data=cd3_pooled_means;
series x=Day y=cd3_p_mean/smoothconnect
markers markerattrs=(color=blue size=14 symbol=CircleFilled)
lineattrs=(color=red thickness=1);
yaxis label="Mean" display=all;
xaxis label="Day";
run;*/

/*plotting gplot-CD3*/
goptions reset=global;
symbol1 interpol=SMnn ci=red value=dot color=blue;
axis1 label=(f='arial/bo' h=2 "day")
		order="Day0" "Day3" "Day7" "Day14" "Day30" "Day90" "Day180" "Day360" "Day720"; 
axis2 label=(f='arial/bo' h=2 "mean")
		order=100 to 1000 by 100;
		

proc gplot data=cd3_pooled_means;
title1 c=blue h=2 j=center "PLOT 4: ANALYSIS ON CD3 IN DIFFERENT DAYS"; 
plot cd3_p_mean*day/haxis=axis1 vaxis=axis2;
run;

/*TABLE 9 : ANALYSIS ON CD4   IN DIFFERENT DAYS*/
title1 c=blue h=2 f=b j=center "TABLE 9: ANALYSIS ON CD4 IN DIFFERENT DAYS";
data cd4;
	set rifat.test_pooled;
	keep rec_cd4_0day rec_cd4_3day rec_cd4_7day rec_cd4_14day rec_cd4_30day
		 rec_cd4_90day rec_cd4_6months rec_cd4_1year rec_cd4_2year;
run;
/*reading rec_cd4_0day to 7 digits to avoid date-value and convert to numeric*/
data cd4(keep=day0 day3 day7 day14 day30 day90 day180 day360 day720);
	set cd4;
	day0_cd4 = substr(rec_cd4_0day, 1, 7);
	*converting to numeric;
	day0 = input(day0_cd4, comma15.);
	day3 = input(rec_cd4_3day, 11.);
	day7 = input(rec_cd4_7day, 16.);
	day14 = input(rec_cd4_14day, 15.);
	day30 = input(rec_cd4_30day, 12.);
	day90 = input(rec_cd4_90day, 12.);
	day180 = input(rec_cd4_6months, 12.);
	day360 = input(rec_cd4_1year, 12.);
	day720 = input(rec_cd4_2year, 12.);
run;

/*Analysis table*/
proc tabulate data=cd4;
var day0 day3 day7 day14 day30 day90 day180 day360 day720;
tables (day0 day3 day7 day14 day30 day90 day180 day360 day720), 
		N='No of records' Mean Stddev Range/box="day";
run; 

/*PLOT5: ANALYSIS OF CD4 IN DIFFERENT DAYS*/
title1 c=blue f=b h=2 j=center "PLOT5: ANALYSIS OF CD4 IN DIFFERENT DAYS";

/*generating an id-col to transpose by id-variable*/
data cd4;
	set cd4;
	_id = _n_;
run;
/*Using transpose to taking Day in one column and value in other column*/
proc transpose data=cd4
out=cd4_transpose(rename=(_NAME_=Day COL1=cd4));
by _id;
run;

/*Getting mean for each group of Day-variable*/
/*Sorting using by-variable before using proc means*/
proc sort data=cd4_transpose
out=cd4_transpose_sort;
by Day;
run;

proc means data=cd4_transpose_sort;
	output out=cd4_means(drop=_TYPE_ _FREQ_) mean=cd4mean;
by Day;
var cd4;
run;

/*for plotting need to sort Day by id*/
data cd4_means;
	set cd4_means;
		
	if Day='day0' then id = 1;
	if Day='day3' then id =2;
	if Day='day7' then id =3;
	if Day='day14' then id =4;
	if Day='day30' then id =5;
	if Day='day90' then id=6;
	if Day='day180' then id=7;
	if Day='day360' then id=8;
	if Day='day720' then id=9;
 *cd4mean_convert = cd4mean/10; 
run;

/*sorting by id*/
proc sort data=cd4_means;
by id;
run;

/*gplot-cd4*/
goptions reset=global;

symbol interpol=SMnn ci=red v=dot c=blue;

axis1 label=(f='arial/bo' "day")
		order="day3" "day7" "day14" "day30" "day90" "day180" "day360" "day720";
axis2 label=(f='arial/bo' "mean")
		order=0 to 500 by 100;

proc gplot data=cd4_means;
title1 c=black bold j=center h=3 "PLOT 3:CD4";
plot cd4mean*day/haxis=axis1 vaxis=axis2;
run;

/*sgplot - CD4*/
/*
proc sgplot data=cd4_means;
series x=Day y=cd4mean/smoothconnect
markers markerattrs=(color=blue size=14 symbol=Circlefilled)
lineattrs=(color=red thickness=1);
xaxis label="Day";
yaxis label="Mean" display=all;
run;*/

/*TABLE10 :ANALYSIS ON CD8 IN DIFFERENT DAYS*/
title1 c=blue f=b h=2 "TABLE10 :ANALYSIS ON CD8 IN DIFFERENT DAYS";
/*Dataset for cd8*/
data cd8(keep=rec_cd8_0day day0 day3 day7 day14 day30 day90 day180 day360 day720);
	set rifat.test_pooled;
	keep day0 day3 day7 day14 day30 day90 day180 day360 day720
		 rec_cd8_0day recrec_cd8_3day rec_cd8_7day rec_cd8_14day rec_cd8_30day
		 rec_cd8_90day rec_cd8_6months rec_cd8_1year rec_cd8_2year;

	/*avoid the date value in rec_cd8_0day*/

	 day0 = input(substr(rec_cd8_0day, 1, 7), comma12.);
	 day3 = input(rec_cd8_3day, 10.);
	 day7 = input(rec_cd8_7day, 16.); 
	 day14 = input(rec_cd8_14day, 13.);
	 day30 = input(rec_cd8_30day, 12.);
	 day90 = input(rec_cd8_90day, 12.);
	 day180 = input(rec_cd8_6months, 12.);
	 day360 = input(rec_cd8_1year, 12.);
	 day720 = input(rec_cd8_2year, 12.);
run;

/*Generating id-col to transpose by id-variable*/
data cd8;
	set cd8;
	id = _n_;
run;

/*transpose to transfer wide-format to long-format*/
proc transpose data=cd8
out=cd8_transpose(rename=(_NAME_=Day COL1=cd8));
by id;
run;

/*Sorting before proc means by Day*/
proc sort data=cd8_transpose
out=cd8_sort_day;
by Day;
run;

/*Get the mean-valuse for by-variable*/
proc means data=cd8_sort_day;
by Day;
	output out=cd8_means(drop=_TYPE_ _FREQ_) mean=cd8mean;
var cd8; 
run;

/*generate id-col*/
data cd8_means;
	set cd8_means;
	
	if Day='day0' then id=1;
	if Day='day3' then id=2;
	if Day='day7' then id=3;
	if Day='day14' then id=4;
	if Day='day30' then id=5;
	if Day='day90' then id=6;
	if Day='day180' then id=7;
	if Day='day360' then id=8;
	if Day='day720' then id=9;
run;

/*sorting by id*/
proc sort data=cd8_means;
by id;
run;
/*plot 4:CD8 plot*/
title1 c=blue j=center bold h=2 "PLOT 4:CD8 PLOT";
symbol interpol=SMnn c=red v=dot ci=blue h=3;

axis1 label=(f='arial/bo' "day")
		order='day0' 'day3' 'day7' 'day14' 'day30' 'day90' 'day180' 'day360' 'day720';
axis2 label=(f='arial/bo' "mean")
		order=0 to 500 by 100;

proc gplot data=cd8_means;
plot cd8mean*Day/haxis=axis1 vaxis=axis2;
run;

/*plot*/
/*
title1 c=blue j=center bold h=2 "PLOT 4:CD8 PLOT USING SGPLOT";
proc sgplot data=cd8_means;
series x=Day y=cd8mean/smoothconnect
markers markerattrs=(color=blue size=14 symbol=CircleFilled)
lineattrs=(color=red thickness=1);
xaxis label="Day";
yaxis label="Mean" values=(0 to 500 by 100);
run; 
*/

***************************Table11-nanudu*******************************************;

data pr_table11 (keep = rec_a don_a rec_b don_b rec_dr don_dr rec_a_hla don_a_hla rec_b_hla don_b_hla rec_dr_hla don_dr_hla  hlm );
    set rifat.test_pooled;
    rec_a = int(input(translate(rec_a_hla,'.',','),?? best6.));
    don_a =int(input(translate(don_a_hla,'.',','),?? best6.));
    rec_b = int(input(translate(rec_b_hla,'.',','),?? best6.));
    don_b = int(input(translate(don_b_hla,'.',','),?? best6.));
    rec_dr =int(input(translate(rec_dr_hla,'.',','),?? best6.));
    don_dr =int(input(translate(don_dr_hla,'.',','),?? best6.));

    if rec_a ne . & rec_a = don_a then hlm = 1; else hlm = 0;
    if rec_b ne . & rec_b = don_b     then hlm = hlm +1; 
    if rec_dr ne . & rec_dr = don_dr then hlm = hlm +1;
run;

proc print data = pr_table11 noobs;
title 'Table 11. HLA MATCHING';
var rec_a_hla don_a_hla rec_b_hla don_b_hla rec_dr_hla don_dr_hla  hlm    ;
run;

****************************************************************************;

title c=blue h=2 j=center f=b "TABLE 11: HLA MATCHING";
*split column-value, here the col-val is separated by comma
and convert to numeric***********;
data table11(keep=rec_a_hla rec_a don_a_hla don_a hlm rec_b_hla rec_b don_b_hla don_b rec_dr_hla rec_dr don_dr_hla don_dr);
	set rifat.test_pooled;
	rec_a = input(scan(rec_a_hla, 1, ','), 10.);
	don_a = input(scan(don_a_hla, 1, ','),10.);
	rec_b = input(scan(rec_b_hla, 1, ','), 10.);
	don_b = input(scan(don_b_hla, 1, ','), 10.);
	rec_dr = input(scan(rec_dr_hla, 1, ','), 10.);
	don_dr = input(scan(don_dr_hla, 1, ','), 10.);

/*Create an indicator variable and initialize to '0' i.e.all values are set to zero*/
	hlm = 0;*all values are set to zero and now you update;

/*matching rec_a with don_a*/
	if not missing(rec_a) and rec_a = don_a then hlm = 1;
	else hlm = 0;*if total value of hlm is 1 then only rec_a matched with donor;
/*matching rec_b with don_b*/
	if not missing(rec_b) and rec_b = don_b then hlm = hlm+1;*if total value is 2 then rec_a=don_a and rec_b=don_b both matched;
	
/*matching rec_dr with don_dr*/
	if not missing(rec_dr) and rec_dr = don_dr then hlm = hlm+1;*if total value is 3 then rec_a and rec_b and rec_dr all three matched with donor;
run;
 proc print data=table11 noobs;
 var rec_a_hla don_a_hla rec_b_hla don_b_hla rec_dr_hla don_dr_hla  hlm;   
 run;

/*TABLE I2: ANALYSIS OF TLC ON DIFFERENT DAYS*/
title1 c=blue f=b h=2 j=center "TABLE I2: ANALYSIS OF TLC ON DIFFERENT DAYS";
data tlc;
	set rifat.test_pooled;
	keep rec_tlc_0day rec_tlc_3day rec_tlc_7day rec_tlc_14day rec_tlc_30day
		 rec_tlc_90day rec_tlc_6months rec_tlc_1year rec_tlc__2years
		 _id day0 day3 day7 day14 day30 day90 day180 day360 day720;
	_id = _n_;
	day0 = input(rec_tlc_0day, comma14.);
	day3 = input(rec_tlc_3day, comma14.);
	day7 = input(rec_tlc_7day, comma14.);
	day14 = input(rec_tlc_14day, comma14.);
	day30 = input(rec_tlc_30day, comma14.);
	day90 = input(rec_tlc_90day, comma14.);
	day180 = input(rec_tlc_6months, comma14.);
	day360 = input(rec_tlc_1year, comma14.);
	day720 = input(rec_tlc__2years, comma14.);
run;

proc transpose data=tlc
out=tlc_p_trans(drop=_id rename=(_name_=day col1=val));
by _id;
run;

proc sort data=tlc_p_trans;
by day;
run;

proc means data=tlc_p_trans;
output out=tlc_p_means(drop=_type_ _freq_) mean=tlcpooledmean;
by day;
var val;
run;

data tlc_p_means;
set tlc_p_means;

if day='day0' then id=1;
if day='day3' then id=2;
if day='day7' then id=3;
if day='day14' then id=4;
if day='day30' then id=5;
if day='day90' then id=6;
if day='day180' then id=7;
if day='day360' then id=8;
if day='day720' then id=9;
run;

proc sort data=tlc_p_means;
by id;
run;


	
/*table*/
proc tabulate data=tlc;
var day0 day3 day7 day14 day30 day90 day180 day360 day720;
tables (day0 day3 day7 day14 day30 day90 day180 day360 day720), 
N = 'No of records' Mean Stddev = 'Std' Range/box='Day';
run;
								
/*MEDICATION SUMMARY REPORTS*/
title1 c=black h=4 j=center f=b underlin=3 "MEDICATION SUMMARY REPORTS";
title2 ;*to put space in between title1 and title3;
title3 c=blue h=2 j=center f=b "TABLE 13: ANALYSIS OF MMF DOSE IN DIFFERENT DAYS";

/*preparing dataset*/
data mmf;
	set rifat.test_pooled;
	keep /*rec_mmfdose_0day rec_mmfdose_3day rec_mmfdose_7day rec_mmfdose_14day
		 rec_mmfdose_30day rec_mmfdose_90day rec_mmfdose_6months rec_mmfdose_1year
		 rec_mmfdose_2years*/
		 day0 day3 day7 day14 day30 day90 day180 day360 day720 id_mmf;

	day0 = input(substr(rec_mmfdose_0day, 1, 3), 11.);
	day3 = input(substr(rec_mmfdose_3day, 1, 3), 11.);
	day7 = input(substr(rec_mmfdose_7day, 1, 3), 11.);
	day14 = input(substr(rec_mmfdose_14day, 1, 3), 11.);
	day30 = input(substr(rec_mmfdose_30day, 1, 3), 11.);
	day90 = input(substr(rec_mmfdose_90day, 1, 3), 11.);
	day180 = input(substr(rec_mmfdose_6months, 1, 3), 11.);
	day360 = input(substr(rec_mmfdose_1year, 1, 3), 11.);
	day720 = input(substr(rec_mmfdose_2years, 1, 3), 11.);
	id_mmf = _n_;
run;

/*table 13*/
proc tabulate data=mmf;
var day0 day3 day7 day14 day30 day90 day180 day360 day720;
tables (day0 day3 day7 day14 day30 day90 day180 day360 day720), 
		N='no of records' Mean stddev='Std' Range/box='Day';
run; 

/*PLOT 7 : ANALYSIS OF MMF DOSE IN DIFFERENT DAYS*/
title1 c=blue h=2 f=b j=center "PLOT 7 : ANALYSIS OF MMF DOSE IN DIFFERENT DAYS";

/*transferring data to long format fro  wide format*/
/*transpose by id_mmf*/
proc transpose data=mmf
	out=mmf_transpose(rename=(_NAME_=Day COL1=mmfdose));
by id_mmf;
run;

/*sort by day before proc means-by day*/
proc sort data=mmf_transpose;
by Day;
run;

proc means data=mmf_transpose;
	output out=mmf_means(drop=_TYPE_ _FREQ_) mean=mmfmean;
by Day;
var mmfdose;
run;

/*plot*/
*sort day by id;
data mmf_means;
	set mmf_means;
	
	if Day = 'day0' then id=1;
	if Day = 'day3' then id=2;
	if Day = 'day7' then id=3;
	if Day = 'day14' then id=4;
	if Day = 'day30' then id=5;
	if Day = 'day90' then id=6;
	if Day = 'day180' then id=7;
	if Day = 'day360' then id=8;
	if Day = 'day720' then id=9;
run;

/*sort by id so that we get Day sequentially*/
proc sort data=mmf_means;
by id;
run;

proc sgplot data=mmf_means;
series x=Day y=mmfmean/smoothconnect
markers markerattrs=(color=blue size=14 symbol=circlefilled)
lineattrs=(color=red thickness=2);

xaxis label = "Day";
yaxis label= "Mean" display=all;
run;

/*TABLE 14: ANALYSIS OF WYS DOSE TEST ON DIFFERENT DAYS*/
title1 c=blue f=b h=2 j=center "TABLE 14: ANALYSIS OF WYS DOSE TEST ON DIFFERENT DAYS";
*Dataset preparation;
 data wys(where=(day90 ne 2011200718));
 	set rifat.test_pooled;
	keep /*rec_wysolonedose_3day rec_wysolonedose_7day rec_wysolonedose_14day
		 rec_wysolonedose_30day rec_wysolonedose_90day rec_wysolonedose_6months
		 rec_wysolonedose_1year*/
		 day3 day7 day14 day30 day90 day180 _id;
	
   *removing ch and special-ch and converting to numeric;
	day3 = input(compress(rec_wysolonedose_3day, '0123456789.', 'k'), 10.);
 	day7 = input(compress(rec_wysolonedose_7day, '0123456789.', 'k'), 10.);
	day14 = input(compress(rec_wysolonedose_14day, '0123456789.', 'k'), 10.);
	day30 = input(compress(rec_wysolonedose_30day, '0123456789.', 'k'), 10.);
	day90 = input(compress(rec_wysolonedose_90day, '0123456789.', 'k'), 10.);
	day180 = input(compress(rec_wysolonedose_6months, '0123456789.', 'k'), 10.);
	_id = _n_;*generating id to transpose by id;
 run;

/*table 14*/
 proc tabulate data=wys;
 var day3 day7 day14 day30 day90 day180;
 tables (day3 day7 day14 day30 day90 day180),
		N = 'No of records' Mean Stddev='Std' Range/box='Day';
 run;

/*plot*/
 proc transpose data=wys
 	out=wysdose(rename=(_NAME_= Day COL1 = wysolonedose ));
 by _id;
 run;

/*Sorting by Day before using Proc Means*/
proc sort data=wysdose;
by Day;
run;

proc means data=wysdose;
 	output out = wysdose_means (drop=_TYPE_ _FREQ_) mean= wysdosemean; *to get the dataset;
by Day;
var wysolonedose; *don't forget to use VAR-statement in proc means;
run;	

/*arranging days in ascending order*/
data wysdose_means_sort;
	set wysdose_means;

	if Day='day3' then id = 1;
	if Day = 'day7' then id = 2;
	if Day = 'day14' then id = 3;
	if Day = 'day30' then id = 4;
	if Day = 'day90' then id = 5;
	if DAy = 'day180' then id = 6;
run;

/*sorting Day for plot*/
proc sort data=wysdose_means_sort;
by id;
run;

/*Finally plotting*/
proc sgplot data=wysdose_means_sort;
series x=Day y=wysdosemean/smoothconnect
markers markerattrs=(color=blue symbol=circlefilled size=14)
lineattrs=(color=red thickness=1);
xaxis label = "Day";
yaxis label = "Mean" display=all;
run;

/*TABLE 15: ANALYSIS OF ATG DOSE TEST IN DIFERENT DAYS*/
data atg;
	set rifat.test_pooled;
	keep rec_atg_doses;
run;

proc sort data=atg;
by rec_atg_doses;
run;

data atg_count;
	set atg;
	by rec_atg_doses; *surely you have to use by-variable;

	where not missing(rec_atg_doses);
	
	retain count;
	
	if first.rec_atg_doses then count=1;
	else count=count+1;
	
/*we want only last counting*/
	if last.rec_atg_doses then output;
run;

/*converting to numeric*/
data atg_numeric;
	set atg_count;
  atg_doses_num = input(compress(rec_atg_doses, ' ', 'kd'), 20.);
  
  if rec_atg_doses = '100mg*3' then atg_doses_num = 100*3/count;
  if rec_atg_doses = '50mg*1' then atg_doses_num = 50*1/count;
  if rec_atg_doses = '50mg*1,75mg*1' then atg_doses_num = ((50*1)+(75*1))/count;
  if rec_atg_doses = '50mg*2' then atg_doses_num = (50*2)/count;
  if rec_atg_doses = '50mg*3' then atg_doses_num = (50*3)/count;
  if rec_atg_doses = '50mg*4' then atg_doses_num = (50*4)/count;
  if rec_atg_doses = '50mg*5' then atg_doses_num = (50*5)/count;
  if rec_atg_doses = '50mg*6,75mg*1' then atg_doses_num = (50*6+75*1)/count;
  if rec_atg_doses = '50mg,75mg' then atg_doses_num = (50+75)/count;
  if rec_atg_doses = '5mg*2' then atg_doses_num = (5*2)/count;
  if rec_atg_doses = '75mg*1' then atg_doses_num = (75*1)/count;
  if rec_atg_doses = '75mg*1,50mg*1' then atg_doses_num = (75*1+50*1)/count;
  if rec_atg_doses = '75mg*2' then atg_doses_num = (75*2)/count; 
  if rec_atg_doses = '75mg,50mg*3' then atg_doses_num = (75+50*3)/count;
  if rec_atg_doses = '75mg,75mg,50mg' then atg_doses_num = (75+75+50)/count;
run;

/*Average*/
proc print data=atg_numeric(drop=count) label round;
label atg_doses_num = Avg_dose;
run;


/*TABLE 16: VIRUS EFFECT*/
title1 c=blue h=2 f=b j=center "TABLE 16: VIRUS EFFECT";
data virus;
	set rifat.test_pooled;
	keep HCV HIV HBS rec_HCV_HIV_HBsAg;

/*split column*/
	HCV = scan(rec_HCV_HIV_HBsAg, 1, '/');
	HIV = scan(rec_HCV_HIV_HBsAg, 2, '/');
	HBS = scan(rec_HCV_HIV_HBsAg, 3, '/');

/*Table*/
  proc tabulate data=virus;
  class hcv hiv hbs;
  tables (hcv hiv hbs), N='Count'/box='LabTestName';
  run;

/*TABLE17: ADVERSE EFFECTS ON ATG DRUG*/
title1 c=blue f=b h=2 j=center "TABLE17: ADVERSE EFFECTS ON ATG DRUG";
/*
proc tabulate data=rifat.test_pooled;
Class inf_comp_viral inf_comp_bacterial inf_comp_fungal inf_comp_others;
tables(inf_comp_viral='Viral' All='Total' inf_comp_bacterial='Bacterial' All='Total' 
	   inf_comp_fungal='Fungal' All='Total' inf_comp_others='Others') All='Total', N='No of records';
run;*/

/*Table17: Using proc sql*/
proc sql;
create table atg_drug as
select count(inf_comp_viral) as Viral, count(inf_comp_bacterial)as Bacterial,
	   count(inf_comp_fungal) as Fungal, count(inf_comp_others) as Others
from rifat.test_pooled;
quit;

proc transpose data=atg_drug
	out=atgdrug;
run;

proc print data=atgdrug label noobs;
label _name_= "Infection category"
	   col1 = "No of records";
	   run;

/*TABLE18: ANALYSIS OF ORGAN S INVOLVED*/
title1 c=blue h=2 j=center "TABLE18: ANALYSIS OF ORGAN S INVOLVED";
proc sql;
create table organ as
select count(inf_comp_UTI) as UTI, count(inf_comp_lung) as LUNG,
	   count(inf_comp_CNS) as CNS, count(inf_comp_others1) as OTHERS1
from rifat.test_pooled;
quit; 

proc transpose data=organ
	out=organ2;
run;

proc print data=organ2 label noobs;
label _NAME_ = "Organ Infected"
	   COL1 = "No of records";
run;

/*TABLE19: ANALYSIS OF INFECTION*/
title1 c=blue h=2 j=center "TABLE19: ANALYSIS OF INFECTION";
proc sql;
create table infection as
select count(non_inf_comp_nodm)as Nodm, 
	   count(non_inf_comp_dyslipidemia) as dyslipidemia,
	   count(non_inf_comp_dyselectrolytemia) as dyselectrolytemia,
	   count(non_inf_comp_cosmetic) as cosmetic
from rifat.test_pooled;
quit; 

proc transpose data=infection
	out=_infection;
run;

proc print data=_infection noobs label;
label _name_="Category"
	   col1="no of records";
run;

/*no of parcipants in case group*/
title1 c=blue h=3 j=center "No of Total Participants";
proc sql;
select count(regis_number) as TotalCase
from rifat.test_pooled;
run;

/*no of participants in control grouo*/
proc sql;
select count(regis_number) as TotalControl
from rifat.control_data;
run;

	

