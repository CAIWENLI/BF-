data work.a;
set chlg2.jn_chlg2_train_v2(obs=100);
/*where obs=100;*/
run;


PROC EXPORT DATA=chlg2.jn_chlg2_corr_v2
   OUTFILE="C:\Users\lenovo\Desktop\tmp02.xlsx"
   DBMS=EXCEL
   REPLACE
   ;
   SHEET="sheet1";
RUN; 

proc corr data=chlg2.jn_chlg2_train_v2 outp=chlg2.jn_chlg2_corr_v2 ;
run;

proc sql;
create table work.temp01 as
select t.contract_no
       ,def_fpd30
       ,case when t.inner_code = 1 then 1 else 0 end as inner_code
       ,case when t.is_dd = 1 then 1 else 0 end as  is_dd
       ,case when t.amount_x_initpay = 1 then 1 else 0 end as  amount_x_initpay_1
       ,case when t.amount_x_initpay = 2 then 1 else 0 end as  amount_x_initpay_2
       ,case when t.cert_4_inital = 1 then 1 else 0 end as  cert_4_inital_1s
       ,case when t.cert_4_inital = 2 then 1 else 0 end as  cert_4_inital_2
       ,case when t.certf_exp_year = 1 then 1 else 0 end as  certf_exp_year_1
       ,case when t.certf_exp_year = 2 then 1 else 0 end as  certf_exp_year_2
       ,case when t.city = 1 then 1 else 0 end as  city_1
       ,case when t.city = 2 then 1 else 0 end as  city_2
       ,case when t.sex_x_familystate = 1 then 1 else 0 end as  sex_x_familystate_1
       ,case when t.sex_x_familystate = 2 then 1 else 0 end as  sex_x_familystate_2
       ,case when t.income_x_age = 1 then 1 else 0 end as  income_x_age_1
       ,case when t.income_x_age = 2 then 1 else 0 end as  income_x_age_2
       ,case when t.goods_info1 = 1 then 1 else 0 end as  goods_info1_1
       ,case when t.goods_info1 = 2 then 1 else 0 end as  goods_info1_2
       ,case when t.prod_code = 1 then 1 else 0 end as  prod_code_1
       ,case when t.prod_code = 2 then 1 else 0 end as  prod_code_2
from chlg2.jn_chlg2_train_v2 t;
quit;

proc corr data=work.temp01 outp=work.corr;
run;



PROC EXPORT DATA=work.corr
   OUTFILE="C:\Users\lenovo\Desktop\tmp03.xlsx"
   DBMS=EXCEL
   REPLACE
   ;
   SHEET="sheet1";
RUN; 
