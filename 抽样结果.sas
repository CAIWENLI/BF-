libname sco oracle user=sco pw='sco&*#1309%' path='RCAS' schema=sco;
libname chlg2 'E:\江楠\SQL SCRIPT\新的任务\万胜评分卡调整\sas数据集';

data jessie.jn_challenger2_pre;
set sco.jn_Challenger2_pre;
run;


data chlg2.jn_challenger2_pre;
set jessie.jn_Challenger2_pre;
run;

proc sort data=chlg2.jn_challenger2_pre ;by def_Fpd30;run;
/*训练集*/
proc surveyselect data=chlg2.jn_challenger2_pre 
     method=srs rate=0.7 out=chlg2.jn_challenger2_train(drop=SelectionProb SamplingWeight);
	 strata def_Fpd30;
run;

proc sort data =chlg2.jn_challenger2_pre ;by  contract_no;run;
proc sort data =chlg2.jn_challenger2_train out=tag(keep= contract_no);by   contract_No;run;
/*验证集*/
data chlg2.jn_challenger2_test;
	merge chlg2.jn_challenger2_pre tag(in=a);
	by   contract_No;
	if ^a then output;
run;


/*导入SCO中*/
data sco.jn_challenger2_train;
set chlg2.jn_challenger2_train;
run;
data sco.jn_challenger2_test;
set chlg2.jn_challenger2_test;
run;


/*样本外数据集*/
data chlg2.jn_chlg2_bairong_outofvalid;
set chlg2.jn_chlg2_outofvalid;
run;



data chlg2.jn_chlg2_outofvalid;
set sco.jn_chlg2_model_step2_out;
run;
