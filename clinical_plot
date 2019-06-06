ods rtf file="C:\Users\rifa\Documents\SAS_Clinical\Project\clinicalproject\clinicalproject\plot.rtf";

/*creating a dataset using all cd3 from all test-type datasets*/
data cd3_all(drop=id rename=(cd3_p_mean=Latest cd3singlemean=Single cd3doublemean=Double cd3triplemean=Triple));
merge cd3_pooled_means cd3_s_means cd3_d_means cd3_tri_means;
run;

goptions reset=global;

symbol1 interpol=join ci=bisque v=dot h=4 c=bisque;
symbol2 interpol=join ci=limegreen v=diamondfilled h=4 c=limegreen;
symbol3 interpol=join ci=red v=trianglefilled h=3 c=red;
symbol4 interpol=join ci=blue v=dot h=2.4 c=blue;

legend1 order=('Latest' 'Single' 'Double' 'Triple')
		label=(f='arial/bo' h=2 "CD3");

axis1 label=(f='arial/bo' h=2 'day')
		order="day0" "day3" "day7" "day14" "day30" "day90" "day180" "day360" "day720";
axis2 label=(f='arial/bo' h=2 'mean')
		order=0 to 1900 by 100;

proc gplot data=cd3_all;
plot(Latest Single Double Triple)*day/overlay haxis=axis1 vaxis=axis2 legend=legend1;
run;

/*cd4-plot*/
data cd4_all(rename=(cd4mean=Latest cd4singlemean=Single cd4doublemean=Double cd4triplemean=Triple));
merge cd4_means cd4_s_mean cd4_d_means cd4_t_means;
by id;
run;

goptions reset=global;

symbol1 interpol=join ci=red h=4 v=squarefilled c=red;
symbol2 interpol=join ci=blue h=4 v=diamondfilled c=blue;
symbol3 interpol=join ci=bisque h=4 v=trianglefilled c=bisque;
symbol4 interpol=join ci=green h=4 v=dot c=green;

axis1 label=(f='arial/bo' "day")
		order="day0" "day3" "day7" "day14" "day30" "day90" "day180" "day360" "day720";
axis2 label=(f='arial/bo' "mean")
		order=0 to 1000 by 100;

legend1 order=('Latest' 'Single' 'Double' 'Triple')
		label=(f='arial/bo' h=2 "cd4");

proc gplot data=cd4_all;
plot (Latest Single Double Triple)*day/overlay haxis=axis1 vaxis=axis2 legend=legend1; 
run;

/*cd8-plot*/
data cd8_all(rename=(cd8mean=Latest cd8singlemean=Single cd8doublemean=Double cd8triplemean=Triple));
merge cd8_means cd8_s_means cd8_d_means cd8_t_means;
by id;
run;

goptions reset=global;

symbol1 interpol=join ci=red h=4 v=squarefilled c=red;
symbol2 interpol=join ci=blue h=4 v=diamondfilled c=blue;
symbol3 interpol=join ci=bisque h=4 v=trianglefilled c=bisque;
symbol4 interpol=join ci=big h=4 v=dot c=big;

axis1 label=(f='arial/bo' h=2 'day')
		order="day0" "day3" "day7" "day14" "day30" "day90" "day180" "day360" "day720";
axis2 label=(f='arial/bo' h=2 'mean')
		order=0 to 700 by 100;

legend1 order=('Latest' 'Single' 'Double' 'Triple')
		label=(f='arial/bo' h=2 "cd8");

proc gplot data=cd8_all;
plot (Latest Single Double Triple)*day/overlay haxis=axis1 vaxis=axis2 legend=legend1;
run;

/*TLC - merging all tlc-dataset*/
data tlc_all(drop=id rename=(tlcpooledmean=Latest tlcsinglemean=Single tlcdoublemean=Double tlctriplemean=Triple));
merge tlc_p_means tlc_s_means tlc_d_means tlc_t_means;
by id;
run;

/*plotting - tlc*/
goptions reset=global;

symbol1 interpol=join ci=red h=4 v=squarefilled c=red;
symbol2 interpol=join ci=blue h=4 v=diamondfilled c=blue;
symbol3 interpol=join ci=bisque h=4 v=trianglefilled c=bisque;
symbol4 interpol=join ci=big h=4 v=dot c=big;

axis1 label=(f='arial/bo' h=2 'day')
		order="day0" "day3" "day7" "day14" "day30" "day90" "day180" "day360" "day720";
axis2 label=(f='arial/bo' h=2 'mean')
		order=6000 to 15000 by 1000;

legend1 order=('Latest' 'Single' 'Double' 'Triple')
		label=(f='arial/bo' h=2 "TLC");

proc gplot data=tlc_all;
plot (Latest Single Double Triple)*day/overlay haxis=axis1 vaxis=axis2 legend=legend1;
run;

/*HB-total*/
data hb_all(drop=_type_ _freq_ rename=(hbmean=Latest hbsinglemean=Single hbdoublemean=Double hbtriplemean=Triple));
merge hb_trans_mean_id hb_s_means hb_d_means hb_t_means;
by id;
run;

/*plot - HB*/
goptions reset=global;

symbol1 interpol=join ci=bio v=squarefilled h=4 c=bio;
symbol2 interpol=join ci=blue v=diamondfilled h=4 c=blue;
symbol3 interpol=join ci=chartreuse v=dot h=4 c=chartreuse;
symbol4 interpol=join ci=red v=trianglefilled h=4 c=red;

legend1 order=('Latest' 'Single' 'Double' 'Triple')
		label=(f='arial/bo' 'HB');

axis1 label=(f='arial/bo' "day" h=4) 
		order="day0" "day3" "day7" "day14" "day30" "day90" "day180" "day360" "day720";
axis2 label=(f='arial/bo' "mean" h=4)
		order=8 to 15;
 
proc gplot data=hb_all;
plot (Latest Single Double Triple)*day/overlay haxis=axis1 vaxis=axis2 legend=legend1;
run;

/*Plot-Platelets*/
data platelet_all(drop=_type_ _freq_ rename=(plateletmean=Latest plsinglemean=Single pldoublemean=Double pltriplemean=Triple));
merge platelet_mean_t platelet_s_means platelet_d_means platelet_t_means;
by id;
run;

goptions reset=global;

symbol1 interpol=join ci=bio v=squarefilled h=4 c=bio;
symbol2 interpol=join ci=blue v=diamondfilled h=4 c=blue;
symbol3 interpol=join ci=chartreuse v=dot h=4 c=chartreuse;
symbol4 interpol=join ci=red v=trianglefilled h=4 c=red;

legend1 order=('Latest' 'Single' 'Double' 'Triple')
		label=(f='arial/bo' 'Platelet');

axis1 label=(f='arial/bo' "day" h=4) 
		order="day0" "day3" "day7" "day14" "day30" "day90" "day180" "day360" "day720";
axis2 label=(f='arial/bo' "mean" h=4)
		order=140 to 340 by 10;


proc gplot data=platelet_all;
title1 h=2 c=blue j=center "Paltelet Plot"; 
plot (Latest Single Double Triple)*day/overlay haxis=axis1 vaxis=axis2 legend=legend1;
run;

ods rtf close;

