/*训练集和测试集*/
/*
chlg2.jn_chlg2_train

chlg2.jn_chlg2_test

chlg2.jn_chlg2_outofvalid
*/

proc logistic data= chlg2.jn_chlg2_train outmodel = Chlg2.final_model1 descending simple ;
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
output out=Chlg2.model_result1 pred=predvar;
ods output close ;
ods output ParameterEstimates=Chlg2.model_coef1;
run; 



/*计算测试集的分数*/
proc logistic inmodel=chlg2.final_model1;
		score data=chlg2.jn_chlg2_train out=train1_score;
	run;


proc logistic inmodel=chlg2.final_model1;
		score data=chlg2.jn_chlg2_test out=valid1_score;
	run;


proc logistic inmodel=chlg2.final_model1;
		score data=chlg2.jn_chlg2_outofvalid out=outofvalid1_score;
	run;



/*放到work里头*/ 
proc logistic inmodel=chlg2.final_model1;
		score data=chlg2.jn_chlg2_train out=train1_score;
	run;


proc logistic inmodel=chlg2.final_model1;
		score data=chlg2.jn_chlg2_test out=valid1_score;
	run;


proc logistic inmodel=chlg2.final_model1;
		score data=chlg2.jn_chlg2_outofvalid out=outofvalid1_score;
	run;





