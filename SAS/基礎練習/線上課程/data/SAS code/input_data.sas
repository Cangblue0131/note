/*** input formatted data, list input***/
DATA cars1;
 INPUT make $ model $ mpg weight price ;
DATALINES;
AMC Spirit  22 2640 3799 
AMC Concord 22 2930 4099 
AMC Pacer   17 3350 4749
Buick Century 20 3250 4816
Buick Electra 15 4080 7827
;
RUN; 

/*** input fixed formatted data, column input***/
DATA cars2;
  INPUT make $ 1-5 model $ 6-12 mpg 13-14 weight 15-18 price 19-22;
CARDS;
AMC  Concord2229304099
AMC  Pacer  1733504749
AMC  Spirit 2226403799
BuickCentury2032504816
BuickElectra1540807827
;
RUN;

/***read data from external file***/
DATA cars3;
  INFILE "D:\input_data\cars3.txt";
  INPUT make $ model $ mpg weight price;
RUN;

/***using Tab***/
DATA cars4;
  INFILE "D:\input_data\cars4.txt" DELIMITER='09'x ;
  INPUT make $ model $ mpg weight price;
RUN;

/***using ','***/
DATA cars5;
  INFILE "D:\input_data\cars5.txt" delimiter=',';
  INPUT make $ model $ mpg weight price;
RUN;

/*********print data**************/
Title "cars5 data";
PROC PRINT DATA=cars5;
RUN; 

Title "cars5 data last 3";
PROC PRINT DATA=cars5 (firstobs=4 OBS=5);
RUN; 

Title "cars3 data ";
proc contents data=cars3;
run;
