DATA eval;
	INFILE 'D:\github\git_data\SAS\SAS123\DATA\Y777.dat'; /* Ū���~����� */
	INPUT id $ a1-a5 b1-b5 q16-q19 q20a $; /* �إ� feature */
RUN;

PROC PRINT DATA = eval; /* �L�X eval */
RUN;

PROC MEANS DATA = eval; /* �p�� eval ���C�� col �� N, mean, sd, min, max */
RUN;

PROC FREQ DATA = eval;
	TABLES q20a; /* �� eval �� q20a �i��p�� */
RUN;

DATA TEST1;
INPUT #1 name $ 10. /@1 price E7. #3 profit 6.2;
datalines;
Alice
123E2             1
50078
      Bob
 9.99E5
-30000
Anna Marie

-10000
;
run;
