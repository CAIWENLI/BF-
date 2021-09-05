libname sco oracle user=sco pw='sco&*#1309%' path='RCAS' schema=sco;
libname chlg2 'E:\���\SQL SCRIPT\�µ�����\��ʤ���ֿ�����\sas���ݼ�';

data jessie.jn_challenger2_pre;
set sco.jn_Challenger2_pre;
run;


data chlg2.jn_challenger2_pre;
set jessie.jn_Challenger2_pre;
run;

proc sort data=chlg2.jn_challenger2_pre ;by def_Fpd30;run;
/*ѵ����*/
proc surveyselect data=chlg2.jn_challenger2_pre 
     method=srs rate=0.7 out=chlg2.jn_challenger2_train(drop=SelectionProb SamplingWeight);
	 strata def_Fpd30;
run;

proc sort data =chlg2.jn_challenger2_pre ;by  contract_no;run;
proc sort data =chlg2.jn_challenger2_train out=tag(keep= contract_no);by   contract_No;run;
/*��֤��*/
data chlg2.jn_challenger2_test;
	merge chlg2.jn_challenger2_pre tag(in=a);
	by   contract_No;
	if ^a then output;
run;


/*����SCO��*/
data sco.jn_challenger2_train;
set chlg2.jn_challenger2_train;
run;
data sco.jn_challenger2_test;
set chlg2.jn_challenger2_test;
run;


/*���������ݼ�*/
data chlg2.jn_chlg2_bairong_outofvalid;
set chlg2.jn_chlg2_outofvalid;
run;



data chlg2.jn_chlg2_outofvalid;
set sco.jn_chlg2_model_step2_out;
run;
