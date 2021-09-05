libname sco oracle user=sco pw='sco&*#1309%' path='RCAS' schema=sco;
libname chlg2 'E:\���\SQL SCRIPT\�µ�����\��ʤ���ֿ�����\sas���ݼ�';
/*ѵ�����Ͳ��Լ�*/
/* v2_1: ���������鰴�������ʸߵ������ ������ģ��(goods_info1) */
/*
chlg2.jn_chlg2_train_v2
chlg2.jn_chlg2_test_v2
chlg2.jn_chlg2_outofvalid_v2
*/

proc logistic data= chlg2.jn_chlg2_train_v2 outmodel = Chlg2.final_model1_v2 descending simple ;
class 	 INNER_CODE
		 IS_DD
		 AMOUNT_X_INITPAY
		 CERT_4_INITAL
		 CERTF_EXP_YEAR
		 CITY
		 SEX_X_FAMILYSTATE
		 INCOME_X_AGE
/*		 GOODS_INFO*/
		 GOODS_INFO1
		 PROD_CODE 
		/param = reference;
model DEF_FPD30=
 INNER_CODE
 IS_DD
 AMOUNT_X_INITPAY
 CERT_4_INITAL
 CERTF_EXP_YEAR
 CITY
 SEX_X_FAMILYSTATE
 INCOME_X_AGE
/* GOODS_INFO*/
 GOODS_INFO1
 PROD_CODE
/ rsq cl rl selection=none;
output out=Chlg2.model_result1_v2 pred=predvar;
ods output close ;
ods output ParameterEstimates=Chlg2.model_coef1_v2;
run; 



/*������Լ���ѵ������������ķ���*/
proc logistic inmodel=chlg2.final_model1_v2;
		score data=chlg2.jn_chlg2_train_v2 out=train1_v2_score;
	run;


proc logistic inmodel=chlg2.final_model1_v2;
		score data=chlg2.jn_chlg2_test_v2 out=valid1_v2_score;
	run;


proc logistic inmodel=chlg2.final_model1_v2;
		score data=chlg2.jn_chlg2_outofvalid_v2 out=outofvalid1_v2_score;
	run;



/*�ŵ�work��ͷ*/ 
proc logistic inmodel=chlg2.final_model1_v2;
		score data=chlg2.jn_chlg2_train_v2 out=train1_v2_score;
	run;


proc logistic inmodel=chlg2.final_model1_v2;
		score data=chlg2.jn_chlg2_test_v2 out=valid1_v2_score;
	run;


proc logistic inmodel=chlg2.final_model1_v2;
		score data=chlg2.jn_chlg2_outofvalid_v2 out=outofvalid1_v2_score;
	run;




data sco.jn_chlg2_train;
set chlg2.jn_chlg2_train;
run;
data sco.jn_chlg2_test;
set chlg2.jn_chlg2_test;
run;


/**/
data sco.jn_chlg2_Train1_v2_score;
set work.Train1_v2_score;
run;

data sco.jn_chlg2_test1_v2_score;
set work.valid1_v2_score;
run;

data sco.jn_chlg2_test1_v2_score;
set work.valid1_v2_score;
run;


proc sql;
select sum(def_Fpd30)/count(1) as bad_rate
	   ,count(1) as n
	   ,sum(def_Fpd30) as n1
from chlg2.jn_chlg2_train_v2;
quit;

proc sql;
select sum(def_Fpd30)/count(1) as bad_rate
	   ,count(1) as n
	   ,sum(def_Fpd30) as n1
from chlg2.jn_chlg2_test_v2;
quit;
proc sql;
select sum(def_Fpd30)/count(1) as bad_rate
	   ,count(1) as n
	   ,sum(def_Fpd30) as n1
from chlg2.jn_chlg2_outofvalid_v2;
quit;
