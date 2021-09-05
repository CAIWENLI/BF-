
/*训练集和测试集*/
/* v2: 将变量分组按照逾期率高低排序后 建立的模型 */
proc sql;
create table    as
select t.*
from sco.jn_chlg2_model_step2_v2 as t
join chlg2.jn_challenger2_train as t1
on t.contract_no = t1.contract_no;
quit;

proc sql;
create table chlg2.jn_chlg2_test_v2 as
select t.*
from sco.jn_chlg2_model_step2_v2 as t
join chlg2.jn_challenger2_test as t1
on t.contract_no = t1.contract_no;
quit;

proc sql;
create table chlg2.jn_chlg2_outofvalid_v2 as
select t.*
from sco.jn_chlg2_model_step2_out_v2 as t;
quit;	



proc logistic data= chlg2.jn_chlg2_train_v2 outmodel = Chlg2.final_model_v2 descending simple ;
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
output out=Chlg2.model_result_v2 pred=predvar;
ods output close ;
ods output ParameterEstimates=Chlg2.model_coef_v2;
run; 



/*计算测试集的分数*/
proc logistic inmodel=chlg2.final_model_v2;
		score data=chlg2.jn_chlg2_train_v2 out=train_v2_score;
	run;


proc logistic inmodel=chlg2.final_model_v2;
		score data=chlg2.jn_chlg2_test_v2 out=valid_v2_score;
	run;


proc logistic inmodel=chlg2.final_model_v2;
		score data=chlg2.jn_chlg2_outofvalid_v2 out=outofvalid_v2_score;
	run;



/*放到work里头*/ 
proc logistic inmodel=chlg2.final_model_v2;
		score data=chlg2.jn_chlg2_train_v2 out=train_v2_score;
	run;


proc logistic inmodel=chlg2.final_model_v2;
		score data=chlg2.jn_chlg2_test_v2 out=valid_v2_score;
	run;


proc logistic inmodel=chlg2.final_model_v2;
		score data=chlg2.jn_chlg2_outofvalid_v2 out=outofvalid_v2_score;
	run;





data sco.jn_chlg2_train;
set chlg2.jn_chlg2_train;
run;
data sco.jn_chlg2_test;
set chlg2.jn_chlg2_test;
run;
