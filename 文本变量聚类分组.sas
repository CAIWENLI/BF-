data chlg2.in_data1(keep = contract_No def_fpd30 cert_4_inital city prod_code goods_info goods_info1);
set chlg2.jn_challenger2_train;
run;

data chlg2.in_data2;
set sashelp.vcolumn;
where libname='CHLG2' and memname='IN_DATA1' and name not in ('CONTRACT_NO','DEF_FPD30');
n = _n_;
run;


Proc Contents Data=chlg2.in_data1(keep=_Character_ drop = contract_no) Out=chlg2.Cnts(Keep=Varnum Name);
Run;


proc sort data=chlg2.Cnts;by varnum;
run;


Data chlg2.Out;/*生成一张空表*/
	Length Name $40 testname $40 clus 8;
	Stop;
Run;

%let re_char= testname;
%let y_char= def;
%let num_char = 3;



%Let Dsid=%Sysfunc(Open(chlg2.Cnts,I));
%put &Dsid;
%Let Nobs=%Sysfunc(Attrn(&Dsid,Nobs)); 
/*if (&Dsid > 0) then do;*/
%put &Nobs;
/*	%let I=1;*/
	do I=1 to &Nobs;
	 %Let Rc=%Sysfunc(Fetchobs(&Dsid,&I));
	 %put &Rc;
	 %Let Varnum=%Sysfunc(Varnum(&Dsid,Name));
	 %put &Varnum;
	 %Let Name=%Sysfunc(Getvarc(&Dsid,&Varnum));
	 %Put &Name;
	 proc sql;
	 create table chlg2.in_Data3 as
	 select "&name" as group_Type
	 	    ,contract_no
			,&name as testname label='TESTNAME'
			,def_fpd30 as def
	 from chlg2.in_data1;
	 quit;

/*第一步，获取数据集的文本变量各个值的频度*/
	proc means data=chlg2.in_data3 noprint nway;
	   class &re_char.;
	   var &y_char.;
	   output out=chlg2.level mean=prop;
	run;

	/*第二步 */
	ods listing close;
	ods output clusterhistory=chlg2.cluster;


	/*采用ward最小方差法*/
	proc cluster data=chlg2.level method=ward
	     outtree=chlg2.fortree;
	   freq _freq_;
	   var prop; /*此处为聚类的变量*/
	   id &re_char.; /*此处为在输出集中展示该字段*/
	run;

	ods listing;


	/*proc print data=cluster;*/
	/*run;*/

	/*卡方检验，主要检验re_char所有类型变量是否存在显著性差异
	K^2 = n (ad - bc) ^ 2 / [(a+b)(c+d)(a+c)(b+d)] 其中n=a+b+c+d为样本容量
	K^2的值越大，说明“XY有关系”成立的可能性越大。
	*/

	proc freq data=chlg2.in_data3 noprint;
	   tables &re_char.* &y_char. / chisq;
	   output out=chlg2.chi(keep=_pchi_) chisq;
	run;


	/*proc print data=chi;run;*/

	data chlg2.cutoff;
	   if _n_ = 1 then set chlg2.chi;
	   set chlg2.cluster;
	   chisquare=_pchi_*rsquared;
	   degfree=numberofclusters-1;
	   logpvalue=logsdf('CHISQ',chisquare,degfree); /*logsdf计算生存函数的对数值*/
	run;



	/*通过取logpvalue的最小值来判断选择模型*/

	/*proc plot data=cutoff;*/
	/*   plot logpvalue*numberofclusters/vpos= 30;*/
	/*run; quit;*/

	/*proc sql;*/
	/*   select NumberOfClusters into :ncl*/
	/*   from cutoff*/
	/*   having logpvalue=min(logpvalue);*/
	/*quit;*/
	/**/
	/*%put &ncl;*/

	proc tree data=chlg2.fortree h=rsq
	          nclusters=&num_char. out=chlg2.clus;
	   id &re_char.;
	run;



	proc sql;
	insert into chlg2.Out
	select "&Name" as name
		   ,&re_char. as testname
		   ,cluster as clus
	from chlg2.clus;
	quit;

















**插入数据后再覆盖原表**
proc sql;
create table wilson.SCO_char_Deal_clus as
select *
from wilson.SCO_char_Deal_clus
where GROUP_TYPE is not null
union
select trim(&re_char1.) as GROUP_TYPE,TESTNAME,CLUSTER,CLUSNAME, &num_char. as CLUSnum
from clus;
quit;





























/*通过宏文本形式实现*/
/*针对文本变量进行变量压缩，压缩至N个值以内*/
%macro char_reduce(in_data,y_char,re_char,re_char1,num_char);
/*%if %sysfunc (exist(&lib..tb_Deal_clus)) ne 0 %then %do ;*/
/*proc datasets lib=&lib. nolist;*/
/*delete tb_Deal_clus;*/
/*quit;*/
/*data &lib..tb_Deal_clus;*/
/*format GROUP_TYPE $60.;*/
/*format TESTNAME $60.;*/
/*format CLUSTER BEST12.;*/
/*format CLUSNAME $60.;*/
/*format CLUSnum BEST12.;*/
/*labEL GROUP_TYPE='GROUP_TYPE';*/
/*labEL TESTNAME='TESTNAME';*/
/*labEL CLUSTER='CLUSTER';*/
/*labEL CLUSNAME='CLUSNAME';*/
/*labEL CLUSnum='CLUSnum';*/
/*run;*/
/*%end;*/
proc sql;
create table in_data as
select *
from &in_data.
where GROUP_TYPE=&re_char1.;
quit;
/*第一步，获取数据集的文本变量各个值的频度*/
proc means data=in_data noprint nway;
   class &re_char.;
   var &y_char.;
   output out=level mean=prop;
run;

/*proc print data=level;run;*/

/*第二步 */
ods listing close;
ods output clusterhistory=cluster;

/*采用ward最小方差法*/
proc cluster data=level method=ward
     outtree=fortree;
   freq _freq_;
   var prop; /*此处为聚类的变量*/
   id &re_char.; /*此处为在输出集中展示该字段*/
run;

ods listing;

/*proc print data=cluster;*/
/*run;*/

/*卡方检验，主要检验re_char所有类型变量是否存在显著性差异
K^2 = n (ad - bc) ^ 2 / [(a+b)(c+d)(a+c)(b+d)] 其中n=a+b+c+d为样本容量
K^2的值越大，说明“XY有关系”成立的可能性越大。
*/

proc freq data=in_data noprint;
   tables &re_char.* &y_char. / chisq;
   output out=chi(keep=_pchi_) chisq;
run;

/*proc print data=chi;run;*/

data cutoff;
   if _n_ = 1 then set chi;
   set cluster;
   chisquare=_pchi_*rsquared;
   degfree=numberofclusters-1;
   logpvalue=logsdf('CHISQ',chisquare,degfree); /*logsdf计算生存函数的对数值*/
run;

/*通过取logpvalue的最小值来判断选择模型*/

/*proc plot data=cutoff;*/
/*   plot logpvalue*numberofclusters/vpos= 30;*/
/*run; quit;*/

/*proc sql;*/
/*   select NumberOfClusters into :ncl*/
/*   from cutoff*/
/*   having logpvalue=min(logpvalue);*/
/*quit;*/
/**/
/*%put &ncl;*/

proc tree data=fortree h=rsq
          nclusters=&num_char. out=clus;
   id &re_char.;
run;

**插入数据后再覆盖原表**
proc sql;
create table wilson.SCO_char_Deal_clus as
select *
from wilson.SCO_char_Deal_clus
where GROUP_TYPE is not null
union
select trim(&re_char1.) as GROUP_TYPE,TESTNAME,CLUSTER,CLUSNAME, &num_char. as CLUSnum
from clus;
quit;

/**/
/*proc sql noprint;*/
/*     %do i=1 %to &num_char. ;*/
/*          select "'"||trim(&re_char.)||"'" into: var_&i. separated by ','*/
/*          from clus*/
/*          where CLUSTER=&i.;*/
/*     %end;*/
/*Quit;*/
/*%put &var_1;*/
/**/

/**/
/*data &out_data.(drop=&re_char. );*/
/*set &in_data.;*/
/*%do i=1 %to &num_char.;*/
/*&new_col.&i.=(&re_char. in(&&var_&i.));*/
/*%end;*/
/*run;*/
/**/
/**/
/**/
/**/
/*DATA bq.&out_data.;*/
/*SET &out_data.;*/
/*RUN;*/
/**/
/**/


/*PROC DATASETS LIBRARY = work  KILL;*/
/*QUIT;*/
/*RUN;*/


%mend char_reduce;
data test.SCO_char_Deal_clus;
set wilson.SCO_char_Deal_clus;
run;
/**/
/**/


/*%char_reduce (bq.tb_pre_clus,def_fpd30,testname,'CERTF_AREA',3);*/


/**/
/*%char_reduce (bq.tb_pre_clus,def_fpd30,testname,'CITY',3);*/
/**/


**libname test oracle user=cu pw="cu++90*7" path='RCAS_PROD' schema=cu;

/*libname TEST oracle user=fengqinyuan pw=feng123 path='TEST' schema=fengqinyuan;*/
**libname bq 'E:\dataminer\data\';



data wilson.SCO_char_pre_clus;
	set test.SCO_char_pre_clus;
run;

data wilson.SCO_char_Deal_clus;
format GROUP_TYPE $60.;
format TESTNAME $60.;
format CLUSTERS BEST12.;
format CLUSNAME $60.;
format CLUSnum BEST12.;
labEL GROUP_TYPE='GROUP_TYPE';
labEL TESTNAME='TESTNAME';
labEL CLUSTERS='CLUSTERS';
labEL CLUSNAME='CLUSNAME';
labEL CLUSnum='CLUSnum';
run;


proc sql;
create table macro_txt as
select distinct "wilson.SCO_char_pre_clus" as in_data,"def" as y_char,"testname" as re_char,"'"||trim(GROUP_TYPE)||"'" as re_char1,2 as num_char
from wilson.SCO_char_pre_clus as t
union
select distinct "wilson.SCO_char_pre_clus" as in_data,"def" as y_char,"testname" as re_char,"'"||trim(GROUP_TYPE)||"'" as re_char1,3 as num_char
from wilson.SCO_char_pre_clus as t
where distinct_num>=3
union
select distinct "wilson.SCO_char_pre_clus" as in_data,"def" as y_char,"testname" as re_char,"'"||trim(GROUP_TYPE)||"'" as re_char1,4 as num_char
from wilson.SCO_char_pre_clus as t
where distinct_num>=4
union
select distinct "wilson.SCO_char_pre_clus" as in_data,"def" as y_char,"testname" as re_char,"'"||trim(GROUP_TYPE)||"'" as re_char1,5 as num_char
from wilson.SCO_char_pre_clus as t
where distinct_num>=5
;
quit;



data _null_;/*生成一个临时的a，用以生成宏代码*/
set macro_txt;
file "E:\sas\sampstock.txt" ;
a='%char_reduce (';
b='(&txt_addess,';
c=',';
g=');';
e=cats(a,in_data,c,y_char,c,re_char,c,re_char1,c,num_char,g);
put e;
run;

%include "E:\sas\sampstock.txt" ;
run;



