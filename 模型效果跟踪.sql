
grant select on jn_chlg2_score_train_v2 to jiangnan,cu;
grant select on jn_chlg2_score_test_v2 to jiangnan,cu;
grant select on jn_chlg2_score_outofvalid_v2 to jiangnan,cu;



select *
  from table(CU.pkg_utl.f_sco_model_index_compute('sco.jn_chlg2_score_train_v2', -- cu.jn_cl_score_monitor_train
                                                  'F_SCORE',
                                                  'DEF_FPD30',
                                                  'where 1=1'));
select *
  from table(cu.pkg_utl.f_sco_model_group('sco.jn_chlg2_score_train_v2 where 1=1',
                                       'F_SCORE',
                                       'DEF_FPD30',
                                       20));
select *
  from table(CU.pkg_utl.f_sco_model_index_compute('sco.jn_chlg2_score_test_v2', -- cu.jn_cl_score_monitor_train
                                                  'F_SCORE',
                                                  'DEF_FPD30',
                                                  'where 1=1'));
select *
  from table(cu.pkg_utl.f_sco_model_group('sco.jn_chlg2_score_test_v2 where 1=1',
                                       'F_SCORE',
                                       'DEF_FPD30',
                                       20));

select *
  from table(CU.pkg_utl.f_sco_model_index_compute('sco.jn_chlg2_score_outofvalid_v2', -- cu.jn_cl_score_monitor_train
                                                  'F_SCORE',
                                                  'DEF_FPD30',
                                                  'where 1=1'));

select *
  from table(cu.pkg_utl.f_sco_model_group('sco.jn_chlg2_score_outofvalid_v2 where 1=1',
                                       'F_SCORE',
                                       'DEF_FPD30',
                                       20));


create table jn_chlg2_score_outofvalid_v2_t as
select t.CONTRACT_NO
,k.APP_DATE
,t.DEF_FPD30
,t.INNER_CODE
,t.IS_DD
,t.AMOUNT_X_INITPAY
,t.CERT_4_INITAL
,t.CERTF_EXP_YEAR
,t.CITY
,t.SEX_X_FAMILYSTATE
,t.INCOME_X_AGE
,t.GOODS_INFO
,t.GOODS_INFO1
,t.PROD_CODE
,t.INNER_CODE_SCORE
,t.IS_DD_SCORE
,t.AMOUNT_X_INITPAY_SCORE
,t.CERT_4_INITAL_SCORE
,t.CERTF_EXP_YEAR_SCORE
,t.CITY_SCORE
,t.SEX_X_FAMILYSTATE_SCORE
,t.INCOME_X_AGE_SCORE
,t.GOODS_INFO1_SCORE
,t.PROD_CODE_SCORE
,t.F_SCORE
from sco.jn_chlg2_score_outofvalid_v2 t
     ,sco.jn_challenger2_base_out k
where t.contract_no = k.contract_no;

select count(1) from jn_chlg2_score_outofvalid_v2_t;
truncate table jn_chlg2_score_outofvalid_v2;
drop table jn_chlg2_score_outofvalid_v2;
rename jn_chlg2_score_outofvalid_v2_t to jn_chlg2_score_outofvalid_v2;


SELECT A2.*
  FROM (select upper('sco.jn_chlg2_train_v2') table_name, 
               COLUMN_NAME group_type,
               'APP_WEEKEND:' || to_char(t2.date_time, 'yyyymmdd') Criteria_name,
               'where to_char(next_day(trunc(app_date),2)-1,''yyyymmdd'')=''' ||
               to_char(t2.date_time, 'yyyymmdd') ||''''
               Criteria
          from (select B.TABLE_NAME, B.COLUMN_NAME
                  FROM all_tab_columns b
                 where upper(b.TABLE_NAME) = upper('jn_chlg2_train_v2')
                   AND B.COLUMN_NAME not IN
                       ('CONTRACT_NO','APP_DATE','DEF_FPD30')) t1,
               (SELECT SDATE + 14 * (ROWNUM - 1) date_time
                  FROM (SELECT to_date('20151129', 'yyyymmdd') SDATE, 
                               to_date('20160410', 'yyyymmdd') EDATE 
                          FROM DUAL) T ��
                CONNECT BY SDATE + 14 * (ROWNUM - 1) <= EDATE) t2) a1,
       table(cu.pkg_utl.f_sco_index_select_compute(a1.table_name,
                                                a1.group_type,
                                                a1.Criteria_name,
                                                a1.Criteria,
                                                'DEF_FPD30')) a2
 order by a2.TYPE_NAME, a2.GROUP_NAME, a2.NAME;
 
 create table jn_chlg2_outofvalid_v2_tmp as
 select t.CONTRACT_NO
,k.APP_DATE
,t.DEF_FPD30
,t.INNER_CODE
,t.IS_DD
,t.AMOUNT_X_INITPAY
,t.CERT_4_INITAL
,t.CERTF_EXP_YEAR
,t.CITY
,t.SEX_X_FAMILYSTATE
,t.INCOME_X_AGE
,k.GOODS_INFO1
,k.PROD_CODE
from sco.jn_chlg2_model_step2_out_v2 t
     ,sco.jn_chlg2_score_outofvalid_v2 k
where t.contract_no = k.contract_no;

select count(1) from jn_chlg2_model_step2_out_v2;
truncate table jn_chlg2_model_step2_out_v2;
drop table jn_chlg2_model_step2_out_v2;
rename jn_chlg2_outofvalid_v2_tmp to jn_chlg2_model_step2_out_v2;

grant select on jn_chlg2_test_v2 to jiangnan,cu;
select * from sco.jn_chlg2_model_step2_out_v2; 
