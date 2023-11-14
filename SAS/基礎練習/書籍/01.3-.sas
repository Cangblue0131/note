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
