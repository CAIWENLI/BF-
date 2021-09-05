----------------------------- v3.0 model
-----------------------------  π”√woe÷µÃÓ≥‰

create table jn_chlg2_train_v2_woe
(
       var_name varchar2(20)
       ,group_name number
       ,woe        number
);


insert into jn_chlg2_train_v2_woe(var_name,group_name,woe)
select var_name
       ,group_name
       ,round(ln(p1/p0),4) woe 
from (
select upper('&amount_x_initpay') var_name
       ,&amount_x_initpay group_name
       ,sum(def_fpd30) n1
       ,count(1) n
       ,count(1) - sum(def_Fpd30) n0
       ,sum(sum(def_fpd30)) over() cnt_bad
       ,sum(count(1) - sum(def_Fpd30)) over() cnt_good
       ,sum(def_fpd30)/(sum(sum(def_fpd30)) over()) p1
       ,(count(1) - sum(def_Fpd30)) / (sum(count(1) - sum(def_Fpd30)) over()) p0
from sco.jn_chlg2_train_v2 t
group by &amount_x_initpay
)
;
commit;

create table jn_chlg2_train_v3 as
select t.contract_no
       ,t.app_date
       ,t.def_fpd30
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.inner_code and k.var_name = upper('inner_code')) woe_inner_code
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.is_dd and k.var_name = upper('is_dd')) woe_is_dd
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.amount_x_initpay and k.var_name = upper('amount_x_initpay')) woe_amount_x_initpay
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.cert_4_inital and k.var_name = upper('cert_4_inital')) woe_cert_4_inital
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.certf_exp_year and k.var_name = upper('certf_exp_year')) woe_certf_exp_year
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.city and k.var_name = upper('city')) woe_city
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.sex_x_familystate and k.var_name = upper('sex_x_familystate')) woe_sex_x_familystate
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.income_x_age and k.var_name = upper('income_x_age')) woe_income_x_age
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.goods_info1 and k.var_name = upper('goods_info1')) woe_goods_info1
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.prod_code and k.var_name = upper('prod_code')) woe_prod_code        
from sco.jn_chlg2_train_v2 t
;
drop table jn_chlg2_model_step2_out_v3

create table jn_chlg2_test_v3 as
select t.contract_no
       ,t.app_Date
       ,t.def_fpd30
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.inner_code and k.var_name = upper('inner_code')) woe_inner_code
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.is_dd and k.var_name = upper('is_dd')) woe_is_dd
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.amount_x_initpay and k.var_name = upper('amount_x_initpay')) woe_amount_x_initpay
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.cert_4_inital and k.var_name = upper('cert_4_inital')) woe_cert_4_inital
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.certf_exp_year and k.var_name = upper('certf_exp_year')) woe_certf_exp_year
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.city and k.var_name = upper('city')) woe_city
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.sex_x_familystate and k.var_name = upper('sex_x_familystate')) woe_sex_x_familystate
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.income_x_age and k.var_name = upper('income_x_age')) woe_income_x_age
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.goods_info1 and k.var_name = upper('goods_info1')) woe_goods_info1
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.prod_code and k.var_name = upper('prod_code')) woe_prod_code        
from sco.jn_chlg2_test_v2 t
;
create table jn_chlg2_model_step2_out_v3 as
select t.contract_no
       ,t.app_Date
       ,t.def_fpd30
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.inner_code and k.var_name = upper('inner_code')) woe_inner_code
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.is_dd and k.var_name = upper('is_dd')) woe_is_dd
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.amount_x_initpay and k.var_name = upper('amount_x_initpay')) woe_amount_x_initpay
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.cert_4_inital and k.var_name = upper('cert_4_inital')) woe_cert_4_inital
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.certf_exp_year and k.var_name = upper('certf_exp_year')) woe_certf_exp_year
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.city and k.var_name = upper('city')) woe_city
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.sex_x_familystate and k.var_name = upper('sex_x_familystate')) woe_sex_x_familystate
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.income_x_age and k.var_name = upper('income_x_age')) woe_income_x_age
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.goods_info1 and k.var_name = upper('goods_info1')) woe_goods_info1
       ,(select woe from jn_chlg2_train_v2_woe k where k.group_name = t.prod_code and k.var_name = upper('prod_code')) woe_prod_code        
from sco.jn_chlg2_model_step2_out_v2 t
;


select * from jn_chlg2_train_v2_woe
