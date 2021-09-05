/*训练集和测试集*/
proc sql;
create table chlg2.jn_chlg2_train as
select t.*
from sco.jn_chlg2_model_step2 as t
join chlg2.jn_challenger2_train as t1
on t.contract_no = t1.contract_no;
quit;

proc sql;
create table chlg2.jn_chlg2_test as
select t.*
from sco.jn_chlg2_model_step2 as t
join chlg2.jn_challenger2_test as t1
on t.contract_no = t1.contract_no;
quit;

proc sql;
create table chlg2.jn_chlg2_outofvalid as
select t.*
from sco.bairong_chlg2_model_step2 as t;
quit;	



proc logistic data= chlg2.jn_chlg2_train outmodel = Chlg2.final_model descending simple ;
class 	 INNER_CODE
		 IS_DD
		 AMOUNT_X_INITPAY
		 CERT_4_INITAL
		 CERTF_EXP_YEAR
		 CITY
		 SEX_X_FAMILYSTATE
		 INCOME_X_AGE
		 GOODS_INFO
		/* GOODS_INFO1*/
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
 GOODS_INFO
/* GOODS_INFO1*/
 PROD_CODE
/ rsq cl rl selection=none;
output out=Chlg2.model_result pred=predvar;
ods output close ;
ods output ParameterEstimates=Chlg2.model_coef;
run; 



/*计算测试集的分数*/
proc logistic inmodel=chlg2.final_model;
		score data=chlg2.jn_chlg2_train out=train_score;
	run;


proc logistic inmodel=chlg2.final_model;
		score data=chlg2.jn_chlg2_test out=valid_score;
	run;


proc logistic inmodel=chlg2.final_model;
		score data=chlg2.jn_chlg2_outofvalid out=outofvalid_score;
	run;



/*放到work里头*/ 
proc logistic inmodel=chlg2.final_model;
		score data=chlg2.jn_chlg2_train out=train_score;
	run;


proc logistic inmodel=chlg2.final_model;
		score data=chlg2.jn_chlg2_test out=valid_score;
	run;


proc logistic inmodel=chlg2.final_model;
		score data=chlg2.jn_chlg2_outofvalid out=outofvalid_score;
	run;



data sco.jn_chlg2_train;
set chlg2.jn_chlg2_train;
run;
data sco.jn_chlg2_test;
set chlg2.jn_chlg2_test;
run;
