/*FYI

筛选条件如下：
（1）申请人的年龄在18-55岁之间；
（2）不接受军人申请；
（3）申请人有提供身份证，且身份信息经过身份验证；
（4）有申请人现场申请照片；
（5）贷款已生成且当前无逾期
（6）0息产品和非0息产品在一个表内提供即可；
（7）不包含已转让给嘉实和哈行的资产；
（8）转让资产为中泰合同项下符合条件的消费金融资产；
（9）不包含哆啦理财产品；
（10）不包含APP做单形成的资产。*/

/*转让条件如下：
（1）申请人的年龄在18-55岁之间；
（2）不接受军人申请；
（3）申请人有提供身份证，且身份信息经过身份验证；
（4）有申请人现场申请照片；
（5）贷款已生成且当前无逾期
（6）0息产品和非0息产品在一个表内提供即可；
（7）不包含已转让给嘉实和哈行的资产；
（8）转让资产为中信合同项下符合条件的消费金融资产；
（9）不包含哆啦理财产品；
（10）不包含APP做单形成的资产。*/


合同号	数据来源	姓名	放款日	首次还款日	首付金额	贷款金额	还款日	每月还款额	剩余贷款本金	
总期数	剩余期数	逾期天数	历史最大逾期天数	前三期最大逾期天数*/



select 
CONTRACT_NO 合同号
,DATA_SOURCE 数据来源
,PERSON_NAME 姓名
,putoutdate 放款日
,paydate 首次还款日
,INIT_PAY    首付金额
,CREDIT_AMOUNT 贷款金额
,pay_date 还款日
,monthrepayment 每月还款额 
,balance 剩余贷款本金
,periods 总期数
,remain_periods 剩余期数
,nvl(cpd,0) 逾期天数
,max_cpd    历史最大逾期天数
,max_cpd2 前三期最大逾期天数
,baserate 年利率
from 
(
select t1.CONTRACT_NO ,to_char(t1.APP_DATE,'yyyymm') app_month
,greatest(t1.cpd-1,0) cpd
,t1.DATA_SOURCE
,round(t1.INIT_PAY,2) INIT_PAY
,round(t1.CREDIT_AMOUNT,2) CREDIT_AMOUNT ---贷款金额
,round(t8.balance,2) balance  ---贷款余额
,t1.PERSON_NAME
,t1.PERSON_SEX
,trunc(months_between(sysdate,to_date(substr(upper(t1.cert_seq),7,8),'yyyymmdd'))/12) PERSON_CUR_AGE         ---客户当前年龄
,t2.cur_address            ---住址
,upper(t1.CERT_seq) CERTID   --身份证号
,t2.family_state        --- 婚姻状况
,case when rcas.pkg_utl.f_get_city_name(substr(t1.CERT_seq,1,4)||'00')=t1.CITY then '本地身份证' else '外地身份证' end certid_status  ---户口性质
,t2.education                                                                                    ---文化程度
,t2.jobtime                                                                                     ----当前岗位从业年限
,decode(t2.income,0,0,round(t1.CREDIT_AMOUNT/t2.income, 2))  CREDIT_AMOUNT_rate                 ----贷款额与月均收入比
,t5.historymaxcpddays max_cpd ---历史最大逾期天数
,greatest(nvl(dd1,0),nvl(dd2,0),nvl(dd3,0)) max_cpd2
,t5.putoutdate
,t6.paydate
,t6.pay_date
,t7.periods
,t8.remain_periods
,(t6.payprincipalamt+t6.payinteamt) monthrepayment
,t9.baserate
from rcas.v_Cu_Risk_Credit_Summary t1 
join 
(
select customerid,certid,
       nvl(otherrevenue,0)+nvl(familymonthincome,0) income ----月收入
       ,(select itemname from s1.code_library  where codeno='Marriage' and itemno=a.marriage) family_state --婚姻状况
       ,(select itemname from s1.code_library  where codeno='EducationExperience' and itemno=a.EduExperience)
                                                             education             ---教育程度
       ,(select itemname from s1.code_library  where codeno='WorkDate' and itemno=a.jobtime)  jobtime ---当前岗位从业年限
       ,(select itemname from s1.code_library  where codeno='HeadShip' and itemno=a.headship)
                                                           position                ---工作职位
       ,(select itemname from s1.code_library  where codeno='AreaCode' and itemno=a.FamilyAdd)||a.Countryside||a.Villagecenter||a.Plot||a.Room
        cur_address    ---现居住住址
from s1.ind_info_cu a
where unitkind<>'10'   ----条件（2）不接受军人申请       
) t2
on t1.ID_PERSON=t2.customerid  
-----条件（3）申请人有提供身份证，且身份信息经过身份验证;
join 
(
select distinct  upper(t.identitycard) identitycard ----------------去重
from s1.id5_xml_ele_val_cu  t
where t.reqheader='1A020201' and compresult='一致' -------------------安硕
union
select upper(t.ident)
from  bqfinance.ID5_IDENT_RESULT@jinlong_link t--------------金龙
where t.compare_result='一致'
UNION
select UPPER(T.IDENT)
from  bqfinance.ID5_RESULT@jinlong_link t-----------------金龙
WHERE T.RESULT='身份证号与姓名一致'
) t3
on upper(nvl(t1.CERT_seq,t2.certid))=identitycard
join-----条件（4）有申请人现场申请照片。
(
select  Objectno ----------合同号
from s1.ECM_PAGE 
where typeno='20002'
)  t4 on t1.CONTRACT_NO=Objectno
join -----最近一笔合同、当前无未按时还款金额、未提前结清、
(
select c.putoutno,row_number()over(partition by c.customerid order by c.putoutdate desc)rn,c.putoutdate,c.historymaxcpddays
from 
(
select a.putoutdate,a.putoutno,a.customerid , nvl(a.normalbalance,0) balance,nvl(a.historymaxcpddays,0) historymaxcpddays
from s1.acct_loan a
where nvl(overduebalance,0)=0 and normalbalance>0 
--and nvl(a.historymaxcpddays,0)<30 
and a.settledate is null
)c )t5 on t1.CONTRACT_NO=t5.putoutno
join                                     -------------------每月还款日期及应还本金利息
(select a2.putoutno,to_date(a1.paydate,'yyyy/mm/dd') paydate,to_char(to_date(a1.paydate,'yyyy/mm/dd'),'dd') pay_date,a1.payprincipalamt,a1.payinteamt
from s1.acct_payment_schedule a1,s1.acct_loan a2
where a1.objectno=a2.serialno and a1.objecttype='jbo.app.ACCT_LOAN' and a1.seqid=1 and a1.paytype='1'
) t6 on t1.CONTRACT_NO=t6.putoutno
join s1.business_contract_cu t7 on t1.CONTRACT_NO=t7.serialno
join                                     --------------------剩余本金、期数
(select a2.putoutno
,count(distinct a1.seqid) remain_periods
,sum(a1.payprincipalamt)balance
from s1.acct_payment_schedule a1,s1.acct_loan a2
where a1.objectno=a2.serialno
and a1.objecttype='jbo.app.ACCT_LOAN' 
and a1.paytype='1' 
and to_date(a1.paydate,'yyyy/mm/dd')>=trunc(sysdate)
group by a2.putoutno
) t8 on t1.CONTRACT_NO=t8.putoutno
join                      -------------------年利率
(
select a.typeno,round(a.baserate,2)||'%' baserate
from
s1.business_type a
) t9 on t1.PROD_CODE=t9.typeno
--剔除不在s1.acct_rate_segment里面的53笔合同，这53笔合同存在利率问题
join
(
select t2.putoutno
from s1.acct_rate_segment t1,s1.acct_loan t2
where t1.objecttype='jbo.app.ACCT_LOAN' 
and t2.serialno=t1.objectno
and t1.status ='1'
) t10 on t10.putoutno=t1.contract_no 

where t1.STATUS_EN in('a','050')--这里保证合同是正处于还贷计划中，而不是结清的合同
-----条件(1) 申请人的年龄在18-55岁之间；
and trunc(months_between(t1.APP_DATE,to_date(substr(nvl(t1.CERT_seq,t2.certid),7,8),'yyyymmdd'))/12) between 18 and 55
-----条件(8) 转让资产为中信合同项下符合条件的消费金融资产；
and t1.loan_type='030'
and t7.CREDITPERSON like '%中信%'
-----条件(5) 当前无逾期；
and nvl(t1.dpd,0)=0
-----条件(7) 不包含此前嘉实转让数据，不含前期已转让给哈行数据；
and rn=1
and not exists
(select 1  
 from s1.acct_transaction t11
where (t11.transstatus ='0' or t11.transstatus='3')
and  t11.serialno=T1.CONTRACT_NO
)
and not exists
(select 1
from
(
select t.relativeserialno from s1.business_cession t --已转让嘉实资产
union
SELECT t.contractserialno FROM s1.dealcontract_reative t where t.status='01' --已转让哈行资产
union
--条件(9) 不包含哆啦理财产品；  
select serialno from s1.business_contract where isp2p='1' --剔除哆啦理财
)
where relativeserialno=t1.contract_no 
)
and t1.DATA_SOURCE='AMAR'
-----条件(10) 不包含APP做单形成的资产。
and t1.sure_type='PC' --剔除APP
)


