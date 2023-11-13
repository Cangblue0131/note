libname a 'D:\02_DATABASE\模擬數據檔\健保資料_上課用模擬數據';
libname b 'D:\software_test\SAS\上課NHIRD\課堂練習\02master';
libname c 'D:\software_test\SAS\上課NHIRD\課堂練習\03output';
/*
if substr(ATC_7,1,7)='N05AE04' then  index_agent='ziprasidone'; 
if substr(ATC_7,1,7)='N05AH02' then  index_agent='clozapine';
if substr(ATC_7,1,7)='N05AH03' then  index_agent='olanzapine';
if substr(ATC_7,1,7)='N05AH04' then  index_agent='quetiapine'; 
if substr(ATC_7,1,7)='N05AH06' then  index_agent='clotiapine'; 
if substr(ATC_7,1,7)='N05AL05' then  index_agent='amisulpride'; 
if substr(ATC_7,1,7)='N05AX08' then  index_agent='risperidone'; 
if substr(ATC_7,1,7)='N05AX09' then  index_agent='clothiapine'; 
if substr(ATC_7,1,7)='N05AX11' then  index_agent='zotepine'; 
if substr(ATC_7,1,7)='N05AX12'	then  index_agent='aripiprazole';
if substr(ATC_7,1,7)='N05AX13' then  index_agent='paliperidone'; */

/***cohort identification***/
/*** start from antipsychotics***/
data c.n05a; set a.nhi_atc;
	if substr(atc_7,1,4)='N05A';  /*selection of antipsychotics*/
	if substr(atc_7,1,5)='N05AN' then delete; 
	if substr(atc_7,1,7) in ('N05AE04','N05AH02','N05AH03','N05AH04' ,'N05AH06','N05AL05' ,'N05AX08' ,'N05AX09',
    'N05AX11' , 'N05AX12','N05AX13') 
	then index_class='SGA'; else index_class='FGA';  /**grouping**/
	index_agent=atc_7;
run;

proc freq data=c.n05a;
table index_class;
run;

/***extract patient who used antipsychotics***/
proc sort data=c.n05a; by drug_code; run;
proc sort data=a.H_nhi_opdto9501_10; by drug_no; run;

data opdto_9501;
	merge a.H_nhi_opdto9501_10 (in=x)  c.n05a(in=y rename=(drug_code=drug_no));
	by drug_no;
	if x and y;
run;

proc sort data=opdto_9501; by fee_ym appl_type appl_date case_type seq_no hosp_id;run;
proc sort data=a.H_nhi_opdte9501_10; by fee_ym appl_type appl_date case_type seq_no hosp_id;run;

data opdte_9501;
	merge a.H_nhi_opdte9501_10 (in=x)  opdto_9501(in=y);
	by fee_ym appl_type appl_date case_type seq_no hosp_id;
	if x and y;
run;



%macro opd;
%do i=95 %to 98;
%do j=&i.01 %to &i.12;

proc sort data=a.H_nhi_opdto&j._10; by drug_no; run;

data opdto_&j.;
	merge a.H_nhi_opdto&j._10 (in=x)  c.n05a(in=y rename=(drug_code=drug_no));
	by drug_no;
	if x and y;
run;

proc sort data=opdto_&j.; by fee_ym appl_type appl_date case_type seq_no hosp_id;run;
proc sort data=a.H_nhi_opdte&j._10; by fee_ym appl_type appl_date case_type seq_no hosp_id;run;

data opdte_&j.;
	merge a.H_nhi_opdte&j._10 (in=x)  opdto_&j.(in=y);
	by fee_ym appl_type appl_date case_type seq_no hosp_id;
	if x and y;
run;
%end; %end;
%mend;
%opd;

data n05_95;
	set opdte_9501-opdte_9512;
run;

%macro yr(y1, y2);
%do x=&y1. %to &y2.;
data n05_&x.;
	set opdte_&x.01-opdte_&x.12;
run;
%end;
%mend;
%yr (95, 98);

data n05_index; *retain id index_date;
	set n05_95-n05_98;
	index_date=input(func_date, yymmdd10.);
	age=substr(func_date,1,4)-substr(birth_ym,1,4);
	if age<50 then age_50=0; else age_50=1;
	keep id index_date index_agent index_class  ID_S drug_day age age_50;
	format index_date yymmdd10.;
run;
/*selection of study group*/
data n05_index1;
	set n05_index;
	*if 2007<=year(index_date)<=2008; 
	if '01Jan2007'd<=index_date<='31Dec2008'd; 
run;
/***first prescription of antipsychotics***/
proc sort data=n05_index1; by id index_date;run;
proc sort data=n05_index1 nodupkey out=b.master; by id; run;  

proc means data=b.master ; /*n q1 median q3 mean min max*/
var age;
run;

/* idfile */
data idfile;
	set a.H_nhi_enrol9501-a.H_nhi_enrol9512
	a.H_nhi_enrol9601-a.H_nhi_enrol9612
	a.H_nhi_enrol9701-a.H_nhi_enrol9712
	a.H_nhi_enrol9801-a.H_nhi_enrol9812;
	keep id id_in_date id_out_date;
run;

data idfile1;
	set idfile;
	in_date=input(id_in_date, yymmdd10.);
	if id_out_date='' then out_date='31Dec2009'd; else out_date=input(id_out_date, yymmdd10.);	
	format in_date out_date yymmdd10.;
	drop id_in_date id_out_date;
run;

proc sort data=idfile1; by id in_date out_date; run;

data id_in(drop=out_date) id_out (drop=in_date);
	set idfile1;
	by id;
	if first.id then output id_in;
	if last.id then output id_out;
run;

proc sort data=id_in ; by id;run;
proc sort data=id_out; by id; run;

data idfile2;
	merge id_in (in=x) id_out(in=y);
	by id;
	if x and y;
run;

data selectpt (keep=id index_date);
	set b.master;
run;

proc sort data=idfile2; by id; run;
proc sort data=selectpt; by id; run;

data idfile3;
	merge selectpt(in=x) idfile2 (in=y);
	by id;
	if x;
	if in_date<index_date-180 and out_date>index_date+180 then eligibility=1; else eligibility=0;
run;

proc sql;
create table b.master1 as select
a.*, b.eligibility, b.out_date
from b.master a
left join idfile3 b on a.id=b.id
;
quit;

/*** extract all medical record of target population***/
proc sql;
create table opd_9501 as select
b.*, c.*, d.atc_7
from  selectpt a
inner join a.H_nhi_opdte9501_10 b on a.id=b.id
inner join a.H_nhi_opdto9501_10 c on (b.fee_ym=c.fee_ym and  b.appl_type=c.appl_type and b.appl_date =c.appl_date and b.case_type= c.case_type and 
b.seq_no= c.seq_no and b.hosp_id=c.hosp_id)
left join a.nhi_atc d on c.drug_no=d.drug_code
;
quit;
%macro opd;
%do i= 95 %to 98;
data c.opd_&i.; run;
%do j=&i.01 %to &i.12;
proc sql;
create table opd_&j. as select
b.*, c.*, d.atc_7
from  selectpt a
inner join a.H_nhi_opdte&j._10 b on a.id=b.id
inner join a.H_nhi_opdto&j._10 c on (b.fee_ym=c.fee_ym and  b.appl_type=c.appl_type and b.appl_date =c.appl_date and b.case_type= c.case_type and 
b.seq_no= c.seq_no and b.hosp_id=c.hosp_id)
left join a.nhi_atc d on c.drug_no=d.drug_code
;
quit;
data c.opd_&i.;
set c.opd_&i. opd_&j.;
if id='' then delete;
run;
%end;%end;
%mend;
%opd;

%macro ipd;
%do i= 95 %to 98;
data c.ipd_&i.; run;
%do j=&i.01 %to &i.12;
proc sql;
create table ipd_&j. as select 
b.*, c.*, d.atc_7
from  selectpt a
inner join a.H_nhi_ipdte&i. b on a.id=b.id
inner join a.H_nhi_ipdto&j. c on (b.fee_ym=c.fee_ym and  b.appl_type=c.appl_type and b.appl_date =c.appl_date and b.case_type= c.case_type and 
b.seq_no= c.seq_no and b.hosp_id=c.hosp_id)
left join a.nhi_atc d on c.order_code=d.drug_code
;
quit;
data c.ipd_&i.;
set c.ipd_&i. ipd_&j.;
if id='' then delete;
run;
%end;%end;
%mend;
%ipd;

/*past user*/
%macro pastopd;
%do i= 95 %to 98;
proc sql;
create table pastopd_&i. as select
a.id, a.index_date, input(func_date, yymmdd10.) as pre_date format yymmdd10., 1 as pastuser
from selectpt a 
inner join c.opd_&i. b on a.id=b.id
inner join c.n05a c on b.drug_no=c.drug_code
having index_date-180<=pre_date <index_date
;
quit;
%end;
%mend;
%pastopd;

%macro pastipd;
%do i= 95 %to 98;
proc sql;
create table pastipd_&i. as select
a.id, a.index_date, input(in_date, yymmdd10.) as pre_date format yymmdd10., 1 as pastuser
from selectpt a 
inner join c.ipd_&i. b on a.id=b.id
inner join c.n05a c on b.order_code=c.drug_code
having index_date-180<=pre_date <index_date
;
quit;
%end;
%mend;
%pastipd;

data past; 
	set pastopd_95-pastopd_98 pastipd_95-pastipd_98;
run;

proc sort data=past nodupkey; by id; run;
proc sort data=b.master1; by id; run;

data b.master2;
	merge b.master1 (in=x) past (in=y);
	by id;
	if x;
	if pastuser=. then pastuser=0;
run;

/*outcome*/

/**stroke**/

proc sort data=selectpt; by id;run;
proc sort data=c.ipd_95; by id; run;

data stroke_95;
	merge selectpt(in=x) c.ipd_95 (in=y);
	by id;
	if x and y;
    pre_date=input(in_date, yymmdd10.);
	if index_date<=pre_date<=index_date+365;
	if  "430"<=substr(ICD9CM_1,1,3)<="438" then stroke=1;
	if  "430"<=substr(ICD9CM_2,1,3)<="438" then stroke=1;
	if  "430"<=substr(ICD9CM_3,1,3)<="438" then stroke=1;
	if  "430"<=substr(ICD9CM_4,1,3)<="438" then stroke=1;
	if  "430"<=substr(ICD9CM_5,1,3)<="438" then stroke=1;
	if stroke=1;
	stroke_date=pre_date;
	format pre_date stroke_date yymmdd10.;
	keep id stroke stroke_date;
run;

%macro stroke;
%do i=95 %to 98;
proc sort data=selectpt; by id;run;
proc sort data=c.ipd_&i.; by id; run;
data stroke_&i.;
	merge selectpt(in=x) c.ipd_&i. (in=y);
	by id;
	if x and y;
    pre_date=input(in_date, yymmdd10.);
	if index_date<=pre_date<=index_date+365;
	if  "430"<=substr(ICD9CM_1,1,3)<="438" then stroke=1;
	if  "430"<=substr(ICD9CM_2,1,3)<="438" then stroke=1;
	if  "430"<=substr(ICD9CM_3,1,3)<="438" then stroke=1;
	if  "430"<=substr(ICD9CM_4,1,3)<="438" then stroke=1;
	if  "430"<=substr(ICD9CM_5,1,3)<="438" then stroke=1;
	if stroke=1;
	stroke_date=pre_date;
	format pre_date stroke_date yymmdd10.;
	keep id stroke stroke_date icd9cm_1-icd9cm_5 index_date;
run;
%end;
%mend;
%stroke;

data stroke;
	set stroke_95-stroke_98;
run;

proc sort data=stroke; by id stroke_date;run;
proc sort data=stroke nodupkey; by id; run;

data b.master3;
	merge b.master2 (in=x) stroke (in=y keep=id stroke stroke_date);
	by id ;
	if x ;
	if stroke=. then stroke=0;
run;

/***death***/

proc sort data=a.H_ost_death95; by id; run;
data death_95;
	merge selectpt(in=x) a.H_ost_death95 (in=y keep =id d_date);
	by id;
	if x;
	death_date=input(d_date, yymmdd10.);
	if index_date<=death_date<=index_date+365;
	death=1;
	format death_date yymmdd10.;
run;

%macro de;
%do i= 95 %to 98;
proc sort data=a.H_ost_death&i.; by id; run;
data death_&i.;
	merge selectpt(in=x) a.H_ost_death&i. (in=y keep =id d_date);
	by id;
	if x;
	death_date=input(d_date, yymmdd10.);
	if index_date<=death_date<=index_date+365;
	death=1;
	format death_date yymmdd10.;
run;
%end;
%mend;
%de;

data death;
	set death_95-death_98;
run;

proc sort data=death; by id descending death_date;run;
proc sort data=death nodupkey; by id; run;

proc sql;
create table b.master4 as select
a.*, b.death, death_date
from b.master3 a
left join death b on a.id=b.id
;
quit;
/***exposure***/
/***discontinuation  gap=30 (by definition)!!!***/
%macro drug;
%do i= 95 %to 98;
proc sql; 
create table psy_&i. as select
a.id, a.func_date, a.drug_day, b.index_class as pre_class, b.index_agent as pre_agent
from c.opd_&i. a 
inner join c.n05a b on a.drug_no =b.drug_code
;
quit; 
%end;
%mend;
%drug;
data psy_drug;
set psy_95-psy_98;
pre_date=input(func_date, yymmdd10.);
format pre_date yymmdd10.;
drop func_date;
run;

data selectpt  (keep=id index_date index_class) ;
	set b.master4;
run;

proc sort data=psy_drug; by id; run;
proc sort data=selectpt; by id; run;

data dur;
	merge selectpt(in=x) psy_drug (in=y);
	by id;
	if x;
	if index_date<=pre_date<=index_date+365;
run;

proc sort data=dur; by id pre_date; run;

data dur1 dur2;
	set dur;
	by id;
	if first.id then first=1;
	if last.id then last=1;
	if first+last=2 then output dur1; else output dur2;
run;
/***patients with only one prescription***/
data dur3; 
	set dur1;
	discon_date=pre_date+drug_day;
	discon=1;
	format discon_date yymmdd10.;
	keep id discon discon_date;
run;

/***patients with multiple prescription***/

data dur4;
	set dur2;
	pre_end_date=pre_date+drug_day;
	pre_lag=lag(pre_end_date);
	gap=pre_date-pre_lag;

	if first=1 then do pre_lag=.; gap=.;end;
	if gap>90 then do discon=1; discon_date=pre_lag;end;

	format pre_end_date pre_lag discon_date yymmdd10.;

	if discon=1;
	keep id discon discon_date;
run;

proc sort data=dur4; by id discon_date; run;
proc sort data=dur4 nodupkey out=dur5; by id; run;

data dur6;
	set dur3 dur5;
run;

proc sql;
create table b.master5 as select
a.*, b.discon, b.discon_date
from b.master4 a
left join dur6 b on a.id=b.id
;
quit;

/***switching***/

proc sort data=psy_drug; by id; run;
proc sort data=selectpt; by id; run;

data switch;
	merge selectpt (in=x) psy_drug (in=y);
	by id;
	if x and y;
	if index_date<pre_date<=index_date+365;
	if index_class ^= pre_class then do ;switching=1;switching_date=pre_date;end;
	format switching_date yymmdd10.;
	if switching=1;
	keep id switching switching_date;
run;

proc sort data=switch; by id switching_date;run;
proc sort data=switch nodupkey; by id; run;

proc sql;
create table b.master6 as select
a.*, b.switching, b.switching_date
from b.master5 a
left join switch b on a.id=b.id
;
quit;

/*continuous eligibility and last date and 1 year followup*/
data b.master7;
	set b.master6;
	if out_date<index_date+365 then do; disenroll=1; disenroll_date=out_date;end;
	
	follow1yr=1;
	follow1yr_date=index_date+365;
	
	last_date='31dec2009'd;
	last_flag=1;

	format disenroll_date follow1yr_date last_date yymmdd10.;
run;

/*outcome determination*/

data b.master8;
set b.master7;

follow_end=min (discon_date,switching_date, death_date,
follow1yr_date,last_date, disenroll_date,stroke_date );

if follow_end=stroke_date then event='stroke           ';
else if follow_end=switching_date  then event='switch' ;
else if follow_end=discon_date  then event='discon' ;
else if follow_end=discon_date  then event='death' ;
else if follow_end=disenroll_date  then event='disenroll' ;
else if follow_end=follow1yr_date  then event='follow1yr' ;
else event='lastday' ;

if event='stroke' then event_flag=1; else event_flag=0;

FOLLOW_DAY=follow_end-index_date;

format follow_end yymmdd10.; 
run;

proc freq data=b.master8  ;
table index_class*event_flag / nocol norow nopercent;
run;


/*covariates*/

data Selectpt (keep=id index_date);
set b.master8;
run;
%macro dx;
%do i=95 %to 98;
proc sql;
create table opddx_&i. as select 
a.*, b.icd9cm_1, b.icd9cm_2, b.icd9cm_3, input(b.func_date, yymmdd10.) as pre_date format yymmdd10., b.atc_7
from selectpt a
inner join c.opd_&i. b on a.id=b.id
having index_date-180<pre_date<= index_date
;
quit;
%end;
%mend;
%dx;

%macro dx_1;
%do i=95 %to 98;
proc sql;
create table ipddx_&i. as select 
a.*, b.icd9cm_1, b.icd9cm_2, b.icd9cm_3, b.icd9cm_4, b.icd9cm_5,
input(b.in_date, yymmdd10.) as pre_date format yymmdd10., b.atc_7
from selectpt a
inner join c.ipd_&i. b on a.id=b.id
having index_date-180<pre_date<= index_date
;
quit;
%end;
%mend;
%dx_1;

data baseline;
set 
opddx_95-opddx_98
ipddx_95-ipddx_98;
run;


data baseline2;
set baseline;

Schizophrenia=0;
Depression=0;
DM=0;
Dyslipidemia=0;
IHD=0;
HTN=0;
COPD=0;

array discode{5} icd9cm_1-icd9cm_5;
do i=1 to DIM(discode);

if (substr(left(discode{i}),1,3)='295') then Schizophrenia=1;
if (substr(left(discode{i}),1,3)='311') then Depression=1;
if (substr(left(discode{i}),1,3)='250') then DM=1;
if (substr(left(discode{i}),1,3)='272') then Dyslipidemia=1;
if (substr(left(discode{i}),1,3) in ('410','411','412','413','414')) then IHD=1;
if (substr(left(discode{i}),1,3) in ('401','402','403','404','405')) then HTN=1;
if (substr(left(discode{i}),1,3) in ('491','492')) then COPD=1;
end; 

if substr(atc_7,1,3)='A10' then antidiabete=1;else antidiabete=0;
if substr(atc_7,1,5)='C10AA'  then  Statin=1   ;   else Statin=0   ;  
if substr(atc_7,1,3)='C03' then diuretic=1;else diuretic=0;
if substr(atc_7,1,3)='C07' then betablocker=1 ;else betablocker=0;
if substr(atc_7,1,3)='C08' then CCB=1; else CCB=0; 

run;

proc means data=Baseline2 nway noprint; class id;
var  
Schizophrenia
Depression
DM
Dyslipidemia
IHD
HTN
COPD
antidiabete
Statin
diuretic
betablocker
CCB;
output out=baseline3

Max(Schizophrenia)=Schizophrenia
Max(Depression)=Depression
Max(DM)=DM
Max(Dyslipidemia)=Dyslipidemia
Max(IHD)=IHD
Max(HTN)=HTN
Max(COPD)=COPD
Max(antidiabete)=antidiabete
Max(Statin)=Statin
Max(diuretic)=diuretic
Max(betablocker)=betablocker
Max(CCB)=CCB
;
run;

proc sort data=Baseline3; by id;run;
proc sort data=b.master8; by id;run;

data b.master9;
merge b.master8 (in=x) Baseline3;
by id ; 
if x ;
drop _type_ _freq_;
run;



/*************************
data b.ps; set b.master9;
drop drug_day out_date pre_date discon_date switching switching_date disenroll disenroll_date follow1yr
last_date last_flag follow_end event_flag discon;
run;
*************************/
