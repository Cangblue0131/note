DATA eval;
	INFILE 'D:\github\git_data\SAS\SAS123\DATA\Y777.dat'; /* 讀取外部資料 */
	INPUT id $ a1-a5 b1-b5 q16-q19 q20a $; /* 建立 feature */
RUN;

PROC PRINT DATA = eval; /* 印出 eval */
RUN;

PROC MEANS DATA = eval; /* 計算 eval 的每個 col 的 N, mean, sd, min, max */
RUN;

PROC FREQ DATA = eval;
	TABLES q20a; /* 對 eval 的 q20a 進行計數 */
RUN;
