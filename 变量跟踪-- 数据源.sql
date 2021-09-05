SELECT A2.*
  FROM (select upper('sco.jn_chlg2_train_v2') table_name, 
               COLUMN_NAME group_type,
               'APP_WEEKEND:' || to_char(t2.date_time, 'yyyymmdd') Criteria_name,
               'where to_char(next_day(trunc(app_date),2)-1,''yyyymmdd'')=''' ||
               to_char(t2.date_time, 'yyyymmdd') ||''''--' and DATA_FORM=''TRAIN''' 
               Criteria
          from (select B.TABLE_NAME, B.COLUMN_NAME
                  FROM all_tab_columns b
                 where upper(b.TABLE_NAME) = upper('jn_chlg2_train_v2')
                   AND B.COLUMN_NAME not IN
                       ('CONTRACT_NO','APP_DATE','DEF_FPD30')) t1,
               (SELECT SDATE + 7 * (ROWNUM - 1) date_time
                  FROM (SELECT to_date('20151206', 'yyyymmdd') SDATE, --- 取2015/01/18 - 2015/11/15的数据
                               to_date('20160410', 'yyyymmdd') EDATE 
                          FROM DUAL) T 　
                CONNECT BY SDATE + 7 * (ROWNUM - 1) <= EDATE) t2) a1,--- 数据量较少，每两周跟踪一次
       table(cu.pkg_utl.f_sco_index_select_compute(a1.table_name,
                                                a1.group_type,
                                                a1.Criteria_name,
                                                a1.Criteria,
                                                'DEF_FPD30')) a2
 order by a2.TYPE_NAME, a2.GROUP_NAME, a2.NAME;
 
