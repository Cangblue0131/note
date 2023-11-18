/* �N���|�x�s��@���ܼƤ� */
%let my_path = 'D:\github\git_data\SAS\�u�W��\data';

/* �ϥ��ܼƳ]�m lib */
libname DemoData &my_path;

data DemoData.demo2;
    set DemoData.demo;
    if eligibility=1 and  pastuser=0; /* ���O������, �B���s���� */
    stroke_outcome=0;
    if event='stroke' then stroke_outcome=1; /* �t�e�@��, �� stroke ����1, �S������0 */
    if ID_S=1 or ID_S=2; /* �u���� �ʧO ��(9����|��) */
run;

proc ttest data = DemoData.demo2; class index_class; var age;run;

proc freq data = DemoData.demo2;
table
    (ID_S

    Schizophrenia
    Depression
    Dyslipidemia
    IHD
    HTN
    COPD

    antidiabete
    Statin
    diuretic
    betablocker
    CCB
    )* index_class  /chisq;
run;

/*calculate the PS*/
proc logistic data=b.demo2 descending ; /* descending ������ܰѼƮɪ��ƧǤ覡(���Ӧ��p�Ȫ��j�p) */
class  index_class (ref='FGA')  ID_S (ref='1') /* �o��n�����O���ܼƩ�W��, �åB�]�w�n reference */
/param=ref; /* �S�w�Ѽư�ǭ� */
/* �b SAS ��, '/' �q�`�Ω���w proc ���ﶵ, �Ҧp�����X�M�ϧή榡 */
model  index_class= /* �]�w�ҫ� �ؼ��ܼ�(�]�ܶq) �M �����ܼ�(���ܶq) */

    age ID_S

    Schizophrenia
    Depression
    Dyslipidemia
    IHD
    HTN
    COPD

    antidiabete
    Statin
    diuretic
    betablocker
    CCB

/ /* �b SAS ��, '/' �q�`�Ω���w proc ���ﶵ, �Ҧp�����X�M�ϧή榡 */
link=glogit /* link �Ψӫ��w�ҫ����s�����, �s����ƨM�w�F���ܼƩM���ܼƪ����Y. �䤤, glogit �O�i��h���O�� logistic �^�k�ɨϥΪ��s����Ƥ��@, ���N��F generalized logit ���. */
selection=stepwise lackfit ; /* �]�wù�N���^�k������ܬۤ�k */
OUTPUT OUT= ps prob=prob ; /* �]�w output �ɦW�٩M��m, �t�~�h�@�� col �W�s prob, �Ψө� prob */
title "Propensity Score for SGA";
RUN;

/*check PS distribution*/
data plot1; set  ps;
if index_class='SGA' then treated_ps=prob; else treated_ps=.;
if index_class='FGA' then untreated_ps=prob; else untreated_ps=.;/*reference: FGA*/
run;

ODS GRAPHICS ON; /* �ҥ� SAS ���ϧο�X�\�� */
PROC KDE DATA=plot1; /* KED(Kernel Density Estimation, �ֱK�צ��p) �O�@�إΩ���p�H���ܼƾ��v�K�ר�ƪ��L�����k. �o���¥u�O���Fø�s�X�U�Ӿ��v���K�׹�, �Ψ��ˬd�ݬO�_�i�H�ܦn���h�i�� match. */
    UNIVAR untreated_ps treated_ps / PLOTS=densityoverlay;
    /* univar �Ω���w�i��ֱK�צ��p���ܶq */
    /* PLOTS = densityoverlay ���i�D SAS �nø�s���ϧάO�K���|�[��, �]�N�O��� label ø�s�b�P�@�i�ϤW. */
TITLE "Propensity score distributions by treatment group";
RUN;
ODS GRAPHICS OFF; /* ����. ����ø�s�Τ��ݭn��X�Ϯɨϥ�, �קK�����n���ϧο�X. */

ods graphics on;
proc logistic data=ps plots(only) = (roc(id= obs) effect);
    /* plots(only) : �Ω���wø�s�Ϫ�����, ���ͦ���L�q�{�ϧ� */
    /* roc(id=obs) : �ͦ� ROC ���u��, id=obs ���w�ϥ��[��ȱo�Хܲ� */
    /* effect : �ͦ����p�įq�� */
    class  index_class (ref='FGA')  ID_S (ref='1');
    model  index_class =
    age ID_S

    Schizophrenia
    Depression
    Dyslipidemia
    IHD
    HTN
    COPD

    antidiabete
    Statin
    diuretic
    betablocker
    CCB
    / link=glogit selection=stepwise lackfit 
    scale=none clparm=wald clodds=pl rsquare;
run;
ods graphics off;

/*PS-match*/
data b.ps;
    set ps;
    if  index_class='FGA' then interven = 0 ;else interven = 1; /* �H FGA ���ѦҲ� */
run;


/* ************************************* */
/* Call statement for Greedy Match Macro */
/* ************************************* */

/* ************************************* */
/* Greedy 5->1 Digit Matching Macro (�ǰt�ܤp�ƫ�X��)*/
/* ************************************* */
%MACRO GREEDMTCH(
    Lib, /* Library Name */
    Dataset, /* Data set of all */
    depend, /* Dependent variable, (cases, controls) = (1, 0)*/
    matches /* Output file of matched */
    );

%MACRO SORTCC;
    proc sort data = tcases
    out = &LIB..Scase; 
	/*  &LIB..Scase �N��ͦ��b LIB �̭�, �åB��ƦW�٥s�� Scase. 
	    �䤤 LIB �O�e��(MACRO GREEDMTCH) �]�w�ܼƮɵ��w��, 
	    �̷Ӥ���I�s�o�� MACRO �ɨϥΪ��ܼ�(�Ĥ@��)����. */
    by prob;
    
    proc sort data=tctrl
    out = &LIB..Scontrol;
    by prob randnum;
    run;
%MEND SORTCC;

/*  Macro to Create the initial
    Case and Control Data Sets */
%MACRO INITCC(digits);
    data tcases (drop=cprob)
         tctrl (drop=aprob) ;
    set &LIB..&dataset. ;

    /* Create the data set of Controls*/
    if &depend. = 0 and prob ne . /* �p�G depend = 0 �B prob ������ ��|�� */
    then do;
        cprob = Round(prob,&digits.); /* �� prob �i��|�ˤ��J, �]�� digits �u�� 0(�e��IF�����Y), �ҥH�u�|��X���. */
        Cmatch = 0;
        Length RandNum 8;
        RandNum = ranuni(1234567);
        Label RandNum=
        'Uniform Randomization Score';
        output tctrl;
    end;
/* Create the data set of Cases */
else if &depend. = 1 and prob ne .
then do;
Cmatch = 0;
aprob =Round(prob,&digits.);
output tcases;
end;
run;
%SORTCC;
%MEND INITCC;
/* Macro to Perform the Match */
%MACRO MATCH (MATCHED,DIGITS);
data &lib..&matched. (drop=Cmatch randnum
aprob cprob start oldi curctrl matched);
/* select the cases data set */
set &lib..SCase ;
curob + 1;
matchto = curob;
if curob = 1 then do;
start = 1;
oldi = 1;
end;
/* select the controls data set */
DO i = start to n;
set &lib..Scontrol point= i nobs = n;
if i gt n then goto startovr;
if _Error_ = 1 then abort;
curctrl = i;
/* output control if match found */
if aprob = cprob then
do;
Cmatch = 1;
output &lib..&matched.;
matched = curctrl;
goto found;
end;
/* exit do loop if out of potential matches */
else if cprob gt aprob then
goto nextcase;
startovr: if i gt n then
goto nextcase;
END; /* end of DO LOOP */
/* If no match was found, put pointer
Posters
back*/
nextcase:
if Cmatch=0 then start = oldi;
/* If a match was found, output case and
increment pointer */
found:
if Cmatch = 1 then do;
oldi = matched + 1;
start = matched + 1;
set &lib..SCase point = curob;
output &lib..&matched.;
end;
retain oldi start;
if _Error_=1 then _Error_=0;
run;
/* Get files of unmatched cases and */
/* controls. Note that in the example */
/* data, the patient identifiers are HID*/
/* (Hospital ID) and PATIENTN (Patient */
/* identifier. All cases have complete */
/* data for these two fields. Modify */
/* these fields with the appropriate */
/* patient identifier field(s) */
proc sort data=&lib..scase out=sumcase;
by id ;
run;
proc sort data=&lib..scontrol
out=sumcontrol;
by id;
run;
proc sort data=&lib..&matched. out=smatched
(keep=id matchto);
by id;
run;
data tcases (drop=matchto);
merge sumcase(in=a) smatched;
by id;
if a and matchto = . ;
cmatch = 0;
aprob =Round(prob,&digits.);
run;
data tctrl (drop=matchto);
merge sumcontrol(in=a) smatched;
by id;
if a and matchto = . ;
cmatch = 0;
cprob = Round(prob,&digits.);
run;
%SORTCC
%MEND MATCH;
/* Note: This section can be */
/* modified to try variations of the */
/* basic algorithm. */
/* Create file of cases and controls */
%INITCC(.00001);
/* Do a 5-digit match */
%MATCH(Match5,.0001);
/* Do a 4-digit match on remaining
unmatched */
%MATCH(Match4,.001);
/* Do a 3-digit match on remaining
unmatched */
%MATCH(Match3,.01);  
/* Do a 2-digit match on remaining
unmatched */
%MATCH(Match2,.1); 	
/* Do a 1-digit match on remaining
unmatched */
%MATCH(Match1,.1); 
/* Merge all the matches into one file */
/* The purpose of the marchto variable */
/* is to identify matched pairs for the*/
/* matched pair anlayses. matchto is */
/* initially assigned the observation */
/* number of the case. Since there */
/* would be duplicate numbers after the*/
/* individual files were merged, */
/* matchto is incremented by file. */
/* Note that if the controls file */
/* contains more than N=100,000 records*/
/* and/or there are more than 1,000 */
/* matches made at each match level, */
/* then the incrementation factor must */
/* be changed. */
data &lib..&matches.;
    set &lib..match5(in=a)
        &lib..match4(in=b) &lib..match3(in=c)
        &lib..match2(in=d) &lib..match1(in=e);
    if b then matchto=matchto + 100000;
    if c then matchto=matchto + 10000000;
    if d then matchto=matchto + 1000000000;
    if e then matchto=matchto + 100000000000;
run;
/* Sort file -- Need sort for Univariate
analysis in tables
*/
proc sort data=&lib..&matches. out =
&lib..S&matches.;
by &depend.;
run;
%MEND GREEDMTCH;

%GREEDMTCH (DemoData, ps, interven , matchfile);



/****Check the PS distribution*/

data plot_match; set  b.matchfile;
if index_class='SGA' then treated_ps=prob; else treated_ps=.;
if index_class='FGA' then untreated_ps=prob; else untreated_ps=.;/*reference: FGA*/
run;

ODS GRAPHICS ON;
PROC KDE DATA=plot_match;
UNIVAR untreated_ps treated_ps / PLOTS=densityoverlay;
TITLE "Propensity score distributions by treatment group";
RUN;
ODS GRAPHICS OFF;


/*Check the matched baseline characteristic between groups*/
proc ttest data=b.matchfile; class index_class; var age;run;
proc freq data=b.matchfile;
table
(ID_S

Schizophrenia
Depression
Dyslipidemia
IHD
HTN
COPD

antidiabete
Statin
diuretic
betablocker
CCB

)* index_class  /chisq;
run;

/*HR after PS matching */
proc phreg data=b.matchfile;
class  index_class (ref='FGA');
strata matchto;
model follow_day*stroke_outcome  (0)=index_class/risklimit;  title "Crude";
run;



