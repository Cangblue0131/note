libname a 'D:\Erica\OneDrive\Desktop\input_data';
data a.cd_2002;
infile 'D:\SAS_data1116\TDB_CD2002.DAT' missover lrecl=300;
input
var1	$	1	-	6
var2	$	7	-	7
var3	$	8	-	41
var4	$	42	-	49
var5	$	50	-	51
var6	$	52	-	57
var7	$	58	-	59
var8	$	60	-	61
var9	$	62	-	63
var10	$	64	-	65
var11	$	66	-	67
var12	$	68	-	75
var13	$	76	-	83
var14	$	84	-	91
var15	$	92	-	123
var16	$	124	-	125
var17	$	127	-	127
var18	$	128	-	130
var19	$	131	-	135
var20	$	136	-	140
var21	$	141	-	145
var22	$	146	-	149
var23	$	150	-	151
var24	$	152	-	152
var25	$	153	-	184
var26	$	185	-	216
var27	$	217	-	224
var28	$	225	-	232
var29	$	233	-	244
var30	$	245	-	252
var31	$	253	-	264
var32	$	265	-	272
var33	$	273	-	274
var34	$	275	-	282
var35	$	283	-	290
var36	$	291	-	298
var37	$	299	-	299
;
run;
data a.oo_2001;
infile 'D:\SAS_data1116\TDB_OO2001.DAT' missover lrecl=200;
input
oo_1	$	1	-	6
oo_2	$	7	-	7
oo_3	$	8	-	41
oo_4	$	42	-	49
oo_5	$	50	-	51
oo_6	$	52	-	57
oo_7	$	58	-	58
oo_8	$	59	-	70
oo_9	$	71	-	76
oo_10	$	77	-	94
oo_11	$	95	-	104
oo_12	$	105	-	111
oo_13	$	112	-	119
;
run;

data a.nhi_drug_2;
infile "D:\SAS_data1116\all1_1071025(2).b5" missover lrecl=1900;
input Nhi1	$	1	-	2
Nhi2	$	4	-	13
Nhi3	$	15	-	16
Nhi4	$	18	-	27
Nhi5	$	29	-	37
Nhi6	$	39	-	45
Nhi7	$	47	-	53
Nhi8	$	55	-	174
Nhi9	$	176	-	182
Nhi10	$	184	-	235
Nhi11	$	237	-	292
Nhi12	$	294	-	305
Nhi13	$	307	-	357
Nhi14	$	359	-	444
Nhi15	$	446	-	603
Nhi16	$	605	-	624
Nhi17	$	626	-	766
Nhi18	$	768	-	768
Nhi19	$	770	-	770
Nhi20	$	772	-	899
Nhi21	$	901	-	1200
Nhi22	$	1202	-	1256
Nhi23	$	1258	-	1269
Nhi24	$	1271	-	1321
Nhi25	$	1323	-	1378
Nhi26	$	1380	-	1390
Nhi27	$	1392	-	1442
Nhi28	$	1444	-	1499
Nhi29	$	1501	-	1511
Nhi30	$	1513	-	1563
Nhi31	$	1565	-	1620
Nhi32	$	1622	-	1632
Nhi33	$	1634	-	1684
Nhi34	$	1686	-	1741
Nhi35	$	1743	-	1753
Nhi36	$	1755	-	1805
Nhi37	$	1807	-	1848
Nhi38	$	1850	-	1857
;
run;
