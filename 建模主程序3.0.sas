libname sco oracle user=sco pw='sco&*#1309%' path='RCAS' schema=sco;
libname chlg2 'E:\���\SQL SCRIPT\�µ�����\��ʤ���ֿ�����\sas���ݼ�';
/*ѵ�����Ͳ��Լ�*/
/* v3_1: ���������鰴�������ʸߵ�������woeֵ��������ģ��(goods_info1) */
/*

data chlg2.jn_chlg2_train_v3;
set sco.jn_chlg2_train_v3;
run;
data chlg2.jn_chlg2_test_v3;
set sco.jn_chlg2_test_v3;
run;
data chlg2.jn_chlg2_outofvalid_v3;
set sco.jn_chlg2_model_step2_out_v3;
run;





chlg2.jn_chlg2_train_v3
chlg2.jn_chlg2_test_v3
chlg2.jn_chlg2_outofvalid_v3
*/

proc logistic data= chlg2.jn_chlg2_train_v3 outmodel = Chlg2.final_model_v3 descending simple ;
model DEF_FPD30=
 woe_INNER_CODE
 woe_IS_DD
 woe_AMOUNT_X_INITPAY
 woe_CERT_4_INITAL
 woe_CERTF_EXP_YEAR
 woe_CITY
 woe_SEX_X_FAMILYSTATE
 woe_INCOME_X_AGE
/* GOODS_INFO*/
 woe_GOODS_INFO1
 woe_PROD_CODE
/ rsq cl rl selection=none;
output out=Chlg2.model_result_v3 pred=predvar;
ods output close ;
ods output ParameterEstimates=Chlg2.model_coef_v3;
run; 



/*������Լ���ѵ������������ķ���*/
proc logistic inmodel=chlg2.final_model_v3;
		score data=chlg2.jn_chlg2_train_v3 out=train_v3_score;
	run;


proc logistic inmodel=chlg2.final_model_v3;
		score data=chlg2.jn_chlg2_test_v3 out=valid_v3_score;
	run;


proc logistic inmodel=chlg2.final_model_v3;
		score data=chlg2.jn_chlg2_outofvalid_v3 out=outofvalid_v3_score;
	run;



/*�ŵ�work��ͷ*/ 
proc logistic inmodel=chlg2.final_model_v3;
		score data=chlg2.jn_chlg2_train_v3 out=train_v3_score;
	run;


proc logistic inmodel=chlg2.final_model_v3;
		score data=chlg2.jn_chlg2_test_v3 out=valid_v3_score;
	run;


proc logistic inmodel=chlg2.final_model_v3;
		score data=chlg2.jn_chlg2_outofvalid_v3 out=outofvalid_v3_score;
	run;



data sco.jn_chlg2_train;
set chlg2.jn_chlg2_train;
run;
data sco.jn_chlg2_test;
set chlg2.jn_chlg2_test;
run;


data sco.jn_chlg2_Train1_v2_score;
set work.Train1_v2_score;
run;

data sco.jn_chlg2_test1_v2_score;
set work.valid1_v2_score;
run;

proc sql;
select INCOME_X_AGE
	   ,sum(def_Fpd30)/count(1)
	   ,count(1)
from chlg2.jn_chlg2_train_v2
group by INCOME_X_AGE;
quit;
