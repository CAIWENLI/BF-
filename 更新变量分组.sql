grant select,update,insert,delete on sco.jn_challenger2_base to jiangnan;
grant select,update,insert,delete on sco.jn_challenger2_pre to jiangnan;
grant select on cu.risk_var_group_base to sco;
----- 更新变量分组
select * from sco.tmp_info03;
select * from sco.tmp_info04;
select * from cu.risk_var_group_base;

create table sco.risk_var_Group_base
as 
select * from cu.risk_var_group_base;

select * 
from sco.risk_var_Group_base t 
where t.var_name not in ('CERT_4_INITAL','CITY','PROD_CODE','GOODS_INFO','WORK_EMP_TYPE');



update sco.risk_var_Group_base t 
set t.status = 0 
where t.var_name in ('CERT_4_INITAL','CITY','PROD_CODE','GOODS_INFO');
commit;


select * from sco.jn_challenger2_group_base;

------- CERT_4_INITAL
insert into sco.risk_var_Group_base(VAR_NAME, GROUP_NAME, GROUP_RISK_LEVEL, GROUP_NUM, REMARK, LOAN_TYPE, CREATE_TIME, UPDATE_TIME, CREATE_ID, STATUS, DEFAULT_GROUP)
select 'CERT_4_INITAL' var_name
       ,k.testname group_name
       ,k.clus group_risk_level
       ,3 group_num
       ,'' remark
       ,'SS' loan_type
       ,sysdate create_Time
       ,sysdate update_Time
       ,'JN' create_id
       ,'1' status
       ,'' default_Group
from sco.jn_challenger2_Group_base k 
where k.name = 'CERT_4_INITAL'
;
commit;


------- CITY
insert into sco.risk_var_Group_base(VAR_NAME, GROUP_NAME, GROUP_RISK_LEVEL, GROUP_NUM, REMARK, LOAN_TYPE, CREATE_TIME, UPDATE_TIME, CREATE_ID, STATUS, DEFAULT_GROUP)
select 'CITY' var_name
       ,k.testname group_name
       ,k.clus group_risk_level
       ,3 group_num
       ,'' remark
       ,'SS' loan_type
       ,sysdate create_Time
       ,sysdate update_Time
       ,'JN' create_id
       ,'1' status
       ,'' default_Group
from sco.jn_challenger2_Group_base k
where k.name = 'CITY'
;

commit;


------- PROD_CODE
insert into sco.risk_var_Group_base(VAR_NAME, GROUP_NAME, GROUP_RISK_LEVEL, GROUP_NUM, REMARK, LOAN_TYPE, CREATE_TIME, UPDATE_TIME, CREATE_ID, STATUS, DEFAULT_GROUP)
select 'PROD_CODE' var_name
       ,k.testname group_name
       ,k.clus group_risk_level
       ,3 group_num
       ,'' remark
       ,'SS' loan_type
       ,sysdate create_Time
       ,sysdate update_Time
       ,'JN' create_id
       ,'1' status
       ,'' default_Group
from sco.jn_challenger2_Group_base k 
where k.name = 'PROD_CODE'
;
commit;


------- GOODS_INFO
insert into sco.risk_var_Group_base(VAR_NAME, GROUP_NAME, GROUP_RISK_LEVEL, GROUP_NUM, REMARK, LOAN_TYPE, CREATE_TIME, UPDATE_TIME, CREATE_ID, STATUS, DEFAULT_GROUP)
select 'GOODS_INFO' var_name
       ,k.testname group_name
       ,k.clus group_risk_level
       ,3 group_num
       ,'' remark
       ,'SS' loan_type
       ,sysdate create_Time
       ,sysdate update_Time
       ,'JN' create_id
       ,'1' status
       ,'' default_Group
from sco.jn_challenger2_Group_base k
where k.name = 'GOODS_INFO'
;
commit;




------- GOODS_INFO1
insert into sco.risk_var_Group_base(VAR_NAME, GROUP_NAME, GROUP_RISK_LEVEL, GROUP_NUM, REMARK, LOAN_TYPE, CREATE_TIME, UPDATE_TIME, CREATE_ID, STATUS, DEFAULT_GROUP)
select 'GOODS_INFO1' var_name
       ,k.testname group_name
       ,k.clus group_risk_level
       ,3 group_num
       ,'' remark
       ,'SS' loan_type
       ,sysdate create_Time
       ,sysdate update_Time
       ,'JN' create_id
       ,'1' status
       ,'' default_Group
from sco.jn_challenger2_Group_base k
where k.name = 'GOODS_INFO1'
;
commit;

------ 更新DEFAULT_gROUP
update sco.risk_var_Group_base
set default_Group = 2
where var_name in ('CERT_4_INITAL')
      and status = '1';
commit;


update sco.risk_var_Group_base
set default_Group = 2
where var_name in ('GOODS_INFO','GOODS_INFO1')
      and status = '1';
commit;

update sco.risk_var_Group_base
set default_Group = 3
where var_name in ('CITY')
      and status = '1';
commit;


update sco.risk_var_Group_base
set default_Group = 3
where var_name in ('PROD_CODE')
      and status = '1';
commit;















-------- 验证模型
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
               else '其他' end INCOME_X_AGE
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
;



------- 更新分组的排序后建立以下表
CREATE TABLE sco.jn_chlg2_model_step2_v2 AS
select tt.contract_no
       ,tt.def_fpd30
       ,nvl((select k.range from sco.risk_var_Group_base k where k.var_name='INNER_CODE' and k.status = '1' and tt.INNER_CODE=k.group_name),2) INNER_CODE 
       ,nvl((select k.range from sco.risk_var_Group_base k where k.var_name='IS_DD' and k.status = '1' and tt.IS_DD=k.group_name),2) IS_DD 
       ,nvl((select k.range from sco.risk_var_Group_base k where k.var_name='AMOUNT_X_INITPAY' and k.status = '1' and tt.AMOUNT_X_INITPAY=k.group_name),3) AMOUNT_X_INITPAY 
       ,nvl((select k.range from sco.risk_var_Group_base k where k.var_name='CERT_4_INITAL' and k.status = '1' and tt.CERT_4_INITAL=k.group_name),2) CERT_4_INITAL 
       ,nvl((select k.range from sco.risk_var_Group_base k where k.var_name='CERTF_EXP_YEAR' and k.status = '1' and tt.CERTF_EXP_YEAR=k.group_name),2) CERTF_EXP_YEAR 
       ,nvl((select k.range from sco.risk_var_Group_base k where k.var_name='CITY' and k.status = '1' and tt.CITY=k.group_name),3) CITY 
       ,nvl((select k.range from sco.risk_var_Group_base k where k.var_name='SEX_X_FAMILYSTATE' and k.status = '1' and tt.SEX_X_FAMILYSTATE=k.group_name),2) SEX_X_FAMILYSTATE 
       ,nvl((select k.range from sco.risk_var_Group_base k where k.var_name='INCOME_X_AGE' and k.status = '1' and tt.INCOME_X_AGE=k.group_name),2) INCOME_X_AGE 
       ,nvl((select k.range from sco.risk_var_Group_base k where k.var_name='GOODS_INFO' and k.status = '1' and tt.GOODS_INFO=k.group_name),2) GOODS_INFO 
       ,nvl((select k.range from sco.risk_var_Group_base k where k.var_name='GOODS_INFO1' and k.status = '1' and tt.GOODS_INFO1=k.group_name),2) GOODS_INFO1 
       ,nvl((select k.range from sco.risk_var_Group_base k where k.var_name='PROD_CODE' and k.status = '1' and tt.PROD_CODE=k.group_name),3) PROD_CODE 
from sco.jn_chlg2_model_step1 tt;




;
select * from sco.risk_var_Group_base where var_name = 'GOODS_INFO';



create table sco.risk_var_group 
(
       var_name varchar2(30)
       ,clus    number
       ,r_fpd30 number
       ,range   number
)

;
declare
str_l_sql varchar2(10000);
begin
  
for c in (
          select column_name 
          from all_tab_cols t 
          where t.TABLE_NAME = upper('jn_chlg2_train')
                and t.column_name not in ('CONTRACT_NO','DEF_FPD30')
                --and rownum<2
         )
loop
  str_l_sql:= '
              insert into sco.risk_var_group (var_name,clus,r_fpd30,range)
              select '''||c.column_name||''' var_name
                     ,t.'||c.column_name||' clus
                     ,round(sum(t.def_fpd30)/count(*),4) r_fpd30
                     ,row_number() over(order by round(sum(t.def_fpd30)/count(*),4) desc) range
              from sco.jn_chlg2_model_step2 t
                   ,sco.jn_chlg2_train t1
              where t.contract_no = t1.contract_no
              group by t.'||c.column_name||''
              ;
--dbms_output.put_line(str_l_sql);
execute immediate str_l_sql;
end loop;
commit;

end;

update sco.risk_var_Group_base t1
set GROUP_RISK_LEVEL = RANGE 
WHERE create_id = 'JN';
commit;


select t1.*,t.range 
from sco.risk_var_group t
     ,sco.risk_var_Group_base t1
where t.var_name = t1.var_name
      and t.clus = t1.group_risk_level
;


select * from sco.jn_chlg2_model_step2_v2
      
select * from risk_var_group;

select * from sco.risk_var_Group_base
order by  create_time,var_name;



select t.income_x_age
       ,sum(t.def_fpd30)/count(1) 
from sco.jn_chlg2_model_step2_v2 t
     ,sco.jn_chlg2_train_v2 t1
where t.contract_no = t1.contract_no
group by t.income_x_age;


select *
from sco.jn_chlg2_model_step2_v2 t
     ,sco.jn_chlg2_train_v2 t1
where t.contract_no = t1.contract_no
