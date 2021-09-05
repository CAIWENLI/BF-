select * from dual; 
insert into sco.JN_challenger2_base(CONTRACT_NO, APP_DATE, DEF_FPD30, CREDIT_AMOUNT, INIT_PAY, CERT_4_INITAL, PRODUCTCATEGORYNAME, GOODS_TYPE, BRANDTYPE, MANUFACTURER, PRICE, GOODS_INFO, GOODS_INFO1, INCOME, AGE, INNER_CODE, IS_DD, PROD_CODE, SEX_X_FAMILYSTATE, CERTF_EXP_YEAR, CITY)
select t.CONTRACT_NO
       ,t.APP_DATE
       ,t.DEF_FPD30 
       ,t.CREDIT_AMOUNT
       ,t.INIT_PAY
       ,substr(T.cert_seq,1,4) CERT_4_INITAL
       ,T.PRODUCTCATEGORYNAME
       ,T.GOODS_TYPE
       ,T.BRANDTYPE
       ,T.MANUFACTURER
       ,T.PRICE
       ,CU.F_GET_GOODS_INFO(T.PRODUCTCATEGORYNAME,T.GOODS_TYPE,T.BRANDTYPE,T.MANUFACTURER,T.PRICE) goods_Info
       ,cu.f_jn_get_goods_info(T.PRODUCTCATEGORYNAME,T.GOODS_TYPE,T.BRANDTYPE,T.MANUFACTURER,T.PRICE) goods_Info1
       ,t1.SELFMONTHINCOME income
       ,case when length(T.cert_seq)=20 then TRUNC(months_between(trunc(T.app_date),to_date(substr(T.cert_seq,7,8),'yyyymmdd'))/12,0)else null end age
       ,decode(t2.Interiorcode,'2','2','1') INNER_CODE
       ,decode(T2.REPAYMENTWAY,'2','0','1') IS_DD
       ,t.PROD_CODE
       ,T1.SEX||'$'||T1.MARRIAGE SEX_X_FAMILYSTATE
       ,trunc(months_between(to_date(to_char(t.CERTF_EXP,'yyyymmdd'),'yyyy/mm/dd'),t.APP_DATE)/12) CERTF_EXP_YEAR
       ,t3.city
from rcas.v_cu_risk_credit_summary t
     ,s1.ind_info_cu t1
     ,s1.business_contract_cu t2
     ,s1.store_info t3
where t.ID_PERSON = t1.CUSTOMERID
      and t.CONTRACT_NO = t2.SERIALNO
      and t.POS_CODE = t3.sno
      and t.LOAN_TYPE = '030'
      and t.APPROVED = '1'
      and t.AGR_FPD30 = 1
      and t.STATUS_EN <> '160'
      and t.APP_DATE>=to_date('20151201','yyyymmdd')
;      
commit;    

create table sco.jn_chlg2_model_step1 AS
select tt.CONTRACT_NO
       ,tt.def_fpd30
       ,tt.INNER_CODE
       ,tt.IS_DD
       ,tt.CITY
       ,(case when tt.credit_amount<=1600 and tt.init_pay <= 400 then '(-1,1600]$(-1,400]'
              when tt.credit_amount<=1600 and tt.init_pay <= 1000 then '(-1,1600]$(400,1000]'
              when tt.credit_amount<=1600 and tt.init_pay <= 100000 then '(-1,1600]$(1000,100000]'
              when tt.credit_amount>1600  and tt.credit_amount<=2400 and tt.init_pay <= 200 then '(1600,2400]$(-1,200]'
              when tt.credit_amount>1600  and  tt.credit_amount<=2400 and tt.init_pay <= 800 then '(1600,2400]$(200,800]'
              when tt.credit_amount>1600  and  tt.credit_amount<=2400 and tt.init_pay <= 100000 then '(1600,2400]$(200,800]'
              when tt.credit_amount>2400   and tt.init_pay <= 1000 then '(2400,100000]$(-1,1000]'
              when tt.credit_amount>2400   and tt.init_pay <= 2200 then '(2400,100000]$(1000,2200]'
              when tt.credit_amount>2400   and tt.init_pay > 2200 then '(2400,100000]$(2200,100000]'
        else null end)AMOUNT_X_INITPAY
       ,tt.CERT_4_INITAL CERT_4_INITAL
       ,(case when tt.certf_exp_year<=7 then '(-999999,7]'
              when tt.certf_exp_year<=16 then '(7,16]'
              when tt.certf_exp_year>16 then '(16,999999]' ELSE 'other' END) CERTF_EXP_YEAR
       ,tt.sex_x_familystate SEX_X_FAMILYSTATE
       ,case when tt.income<=3000 and tt.age<=24 then '(-1,3000]$(-1,24]'
             when tt.income<=3000 and tt.age<=34 then '(-1,3000]$(24,34]'
             when tt.income<=3000 and tt.age>34 then '(-1,3000]$(34,100]'
             when tt.income<=4800 and tt.age<=20 then '(3000,4800]$(-1,20]'
             when tt.income<=4800 and tt.age<=26 then '(3000,4800]$(20,26]'
             when tt.income<=4800 and tt.age>26 then '(3000,4800]$(26,100]'
             when tt.income>4800 and tt.age<=28 then '(4800,100000000000)$(-1,28]'
             when tt.income>4800 and tt.age<=40 then '(4800,100000000000)$(28,40]'
             when tt.income>4800 and tt.age>40 then '(4800,100000000000)$(40,100]'
               else '����' end INCOME_X_AGE
       ,tt.goods_info
       ,tt.goods_info1
       ,tt.PROD_CODE 
FROM sco.jn_challenger2_base tt
;


CREATE TABLE sco.jn_chlg2_model_step2 AS
select tt.contract_no
       ,tt.def_fpd30
       ,nvl((select k.group_risk_level from sco.risk_var_Group_base k where k.var_name='INNER_CODE' and k.status = '1' and tt.INNER_CODE=k.group_name),2) INNER_CODE 
       ,nvl((select k.group_risk_level from sco.risk_var_Group_base k where k.var_name='IS_DD' and k.status = '1' and tt.IS_DD=k.group_name),2) IS_DD 
       ,nvl((select k.group_risk_level from sco.risk_var_Group_base k where k.var_name='AMOUNT_X_INITPAY' and k.status = '1' and tt.AMOUNT_X_INITPAY=k.group_name),3) AMOUNT_X_INITPAY 
       ,nvl((select k.group_risk_level from sco.risk_var_Group_base k where k.var_name='CERT_4_INITAL' and k.status = '1' and tt.CERT_4_INITAL=k.group_name),2) CERT_4_INITAL 
       ,nvl((select k.group_risk_level from sco.risk_var_Group_base k where k.var_name='CERTF_EXP_YEAR' and k.status = '1' and tt.CERTF_EXP_YEAR=k.group_name),2) CERTF_EXP_YEAR 
       ,nvl((select k.group_risk_level from sco.risk_var_Group_base k where k.var_name='CITY' and k.status = '1' and tt.CITY=k.group_name),3) CITY 
       ,nvl((select k.group_risk_level from sco.risk_var_Group_base k where k.var_name='SEX_X_FAMILYSTATE' and k.status = '1' and tt.SEX_X_FAMILYSTATE=k.group_name),2) SEX_X_FAMILYSTATE 
       ,nvl((select k.group_risk_level from sco.risk_var_Group_base k where k.var_name='INCOME_X_AGE' and k.status = '1' and tt.INCOME_X_AGE=k.group_name),2) INCOME_X_AGE 
       ,nvl((select k.group_risk_level from sco.risk_var_Group_base k where k.var_name='GOODS_INFO' and k.status = '1' and tt.GOODS_INFO=k.group_name),2) GOODS_INFO 
       ,nvl((select k.group_risk_level from sco.risk_var_Group_base k where k.var_name='GOODS_INFO1' and k.status = '1' and tt.GOODS_INFO1=k.group_name),2) GOODS_INFO1 
       ,nvl((select k.group_risk_level from sco.risk_var_Group_base k where k.var_name='PROD_CODE' and k.status = '1' and tt.PROD_CODE=k.group_name),3) PROD_CODE 
from sco.jn_chlg2_model_step1 tt;

