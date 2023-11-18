/* 將路徑儲存於一個變數中 */
%let my_path = 'D:\github\git_data\SAS\線上課\data';

/* 使用變數設置 lib */
libname DemoData &my_path;

data DemoData.demo2;
    set DemoData.demo;
    if eligibility=1 and  pastuser=0; /* 健保期間內, 且為新用藥 */
    stroke_outcome=0;
    if event='stroke' then stroke_outcome=1; /* 含前一行, 有 stroke 的為1, 沒有的為0 */
    if ID_S=1 or ID_S=2; /* 只取有 性別 的(9為遺漏值) */
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
proc logistic data=b.demo2 descending ; /* descending 控制顯示參數時的排序方式(按照估計值的大小) */
class  index_class (ref='FGA')  ID_S (ref='1') /* 這邊要把類別行變數放上來, 並且設定好 reference */
/param=ref; /* 特定參數基準值 */
/* 在 SAS 中, '/' 通常用於指定 proc 的選項, 例如控制輸出和圖形格式 */
model  index_class= /* 設定模型 目標變數(因變量) 和 解釋變數(自變量) */

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

/ /* 在 SAS 中, '/' 通常用於指定 proc 的選項, 例如控制輸出和圖形格式 */
link=glogit /* link 用來指定模型的連結函數, 連結函數決定了應變數和自變數的關係. 其中, glogit 是進行多類別的 logistic 回歸時使用的連結函數之一, 它代表了 generalized logit 函數. */
selection=stepwise lackfit ; /* 設定羅吉斯回歸的選擇變相方法 */
OUTPUT OUT= ps prob=prob ; /* 設定 output 檔名稱和位置, 另外多一個 col 名叫 prob, 用來放 prob */
title "Propensity Score for SGA";
RUN;

/*check PS distribution*/
data plot1; set  ps;
if index_class='SGA' then treated_ps=prob; else treated_ps=.;
if index_class='FGA' then untreated_ps=prob; else untreated_ps=.;/*reference: FGA*/
run;

ODS GRAPHICS ON; /* 啟用 SAS 的圖形輸出功能 */
PROC KDE DATA=plot1; /* KED(Kernel Density Estimation, 核密度估計) 是一種用於估計隨機變數機率密度函數的無母樹方法. 這邊單純只是為了繪製出各個機率的密度圖, 用來檢查看是否可以很好的去進行 match. */
    UNIVAR untreated_ps treated_ps / PLOTS=densityoverlay;
    /* univar 用於指定進行核密度估計的變量 */
    /* PLOTS = densityoverlay 為告訴 SAS 要繪製的圖形是密度疊加圖, 也就是兩個 label 繪製在同一張圖上. */
TITLE "Propensity score distributions by treatment group";
RUN;
ODS GRAPHICS OFF; /* 關閉. 當完成繪製或不需要輸出圖時使用, 避免不必要的圖形輸出. */

ods graphics on;
proc logistic data=ps plots(only) = (roc(id= obs) effect);
    /* plots(only) : 用於指定繪製圖表類型, 不生成其他默認圖形 */
    /* roc(id=obs) : 生成 ROC 曲線圖, id=obs 指定使用觀察值得標示符 */
    /* effect : 生成估計效益圖 */
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
    if  index_class='FGA' then interven = 0 ;else interven = 1; /* 以 FGA 為參考組 */
run;


/* ************************************* */
/* Call statement for Greedy Match Macro */
/* ************************************* */

/* ************************************* */
/* Greedy 5->1 Digit Matching Macro (匹配至小數後幾位)*/
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
	/*  &LIB..Scase 代表生成在 LIB 裡面, 並且資料名稱叫做 Scase. 
	    其中 LIB 是前面(MACRO GREEDMTCH) 設定變數時給定的, 
	    依照之後呼叫這個 MACRO 時使用的變數(第一格)改變. */
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
    if &depend. = 0 and prob ne . /* 如果 depend = 0 且 prob 不等於 遺漏值 */
    then do;
        cprob = Round(prob,&digits.); /* 對 prob 進行四捨五入, 因為 digits 只有 0(前面IF的關係), 所以只會輸出整數. */
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



