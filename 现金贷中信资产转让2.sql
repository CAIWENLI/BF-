-- 1. 哈行现金贷资产转让

-- 1.1更新上期数据为历史数据
--1.1更新上期数据为历史数据
update cu.zs_heb_xjd t
set t.update_time = sysdate, t.status = '1'
where t.status = '0';
commit;
delete from cu.zs_heb_xfd t where t.status='0';

-- 1.2写入当期数据

insert into cu.zs_heb_xjd
(合同号,
数据来源,
姓名,
放款日,
首次还款日,
首付金额,
贷款金额,
还款日,
每月还款额,
剩余贷款本金,
总期数,
剩余期数,
逾期天数,
历史最大逾期天数,
前三期最大逾期天数,
年利率
)
select 
serialno 合同号
,'AMAR' 数据来源
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
,cpd 逾期天数
,max_cpd  历史最大逾期天数
,max_cpd2  前三期最大逾期天数
,baserate 年利率
from 
(
select t1.serialno 
,to_char(t1.inputDATE,'yyyymm') app_month
,greatest(t11.cpd-1,0) cpd
,round(t1.TOTALSUM,2) INIT_PAY
,round(t1.BUSINESSSUM,2) CREDIT_AMOUNT ---贷款金额
,round(t8.balance,2) balance  ---贷款余额
,t1.CUSTOMERNAME PERSON_NAME--客户姓名
,upper(t2.certid) CERTID   --身份证号
,t5.historymaxcpddays max_cpd ---历史最大逾期天数
,greatest(nvl(dd1,0),nvl(dd2,0),nvl(dd3,0)) max_cpd2
,t5.putoutdate
,t6.paydate
,t6.pay_date
,t1.PERIODS
,t8.remain_periods
,(t6.payprincipalamt+t6.payinteamt) monthrepayment
,t9.baserate
from s1.business_contract_cu t1 
join 
cu.zs_heb_xianjindai_1 t2
on t1.CUSTOMERID=t2.customerid 
-----条件（5）申请人有提供身份证，且身份信息经过身份验证；
join
cu.zx_heb_xianjindai_12  t3 on t3.contractno=t1.SERIALNO
join
cu.zs_heb_xianjindai_3  t4 on t1.serialno=t4.Objectno
/*join 
cu.zs_heb_xianjindai_4 t5 on t1.serialno=t5.putoutno*/
join
cu.zs_heb_xianjindai_5 t6 on t1.serialno=t6.putoutno
join 
cu.zs_heb_xianjindai_6 t8 on t1.serialno=t8.putoutno
join 
cu.zs_heb_xianjindai_7 t9 on t1.BUSINESSTYPE=t9.typeno
--剔除不在s1.acct_rate_segment里面的53笔合同，这53笔合同存在利率问题
join
cu.zs_heb_xianjindai_8 t10 on t1.serialno=t10.putoutno
join
cu.zs_heb_xiaofeidai_9 t11 on t1.serialno=t11.putoutno

where t1.CONTRACTSTATUS='050'--这里保证合同是正处于还贷计划中，而不是结清的合同
-----条件(1) 申请人的年龄在18-55岁之间；
and trunc(months_between(trunc(to_date(t1.INPUTDATE,'yyyy-mm-dd hh24:mi:ss')),to_date(substr(t2.certid,7,8),'yyyymmdd'))/12) between 18 and 55
-----条件(8) 转让资产为中信合同项下符合条件的现金贷资产；
and t1.PRODUCTID in('020','010')
and t1.creditperson like '中信%'--不包括"哆啦理财"的单
-----条件(11) 当前无逾期；
and nvl(t11.dpd,0)=0
and rn=1
and t1.SERIALNO  not in 
('53408263001'
,'10525200002'
,'10527169001'
,'10527708001'
,'10528775001'
,'10546265001'
,'10976508001'
,'10979962001'
,'10988652001'
,'10990181001'
,'11004459001') 

-----条件(7)不含前期已转让给哈行数据；
and not exists
(select t12.relativeserialno from cu.zx_heb_xiaofeidai_11 t12
 where   t12.relativeserialno=t1.serialno )
-----条件(10) 不包含APP做单形成的资产包括借钱么的资产
--and ( t1.suretype='PC'  or t1.SURETYPE='JQM')----剔除APP,包含借钱
);
commit;






/*
select * from cu.zs_heb_xjd where status='0'
alter table cu.zs_heb_xjd add create_time date default sysdate;
alter table cu.cu.zs_heb_xjd add update_time date default sysdate;
alter table cu.cu.zs_heb_xjd add status varchar2(2) default 0;


select trunc(to_date(t.inputtime, 'YYYY-MM-DD HH24:MI:SS')),count(*) from s1.dealcontract_reative t 
group by trunc(to_date(t.inputtime, 'YYYY-MM-DD HH24:MI:SS'))
--转让至哈行资产（安硕）


select trunc(to_date(t.occurdate, 'YYYY-MM-DD')),count(*) from s1.busi
ness_cession t
group by trunc(to_date(t.occurdate, 'YYYY-MM-DD'))
--转让至嘉实资产（安硕）
select t.transfer_date,count(*) from s2.transfer_credit_final t 
group by t.transfer_date
--转让至嘉实资产（金龙）
select * from etl.log_msg t where \*t.proc_name like 'pkg_audit.P_risk_audit_detail主程序begin%' and*\ t.log_time>trunc(sysdate) order by t.log_time desc;
select * from etl.log_msg t where t.proc_name like 'pkg_risk.p_risk_credit_summary_cur主程序%' and t.log_time>trunc(sysdate) order by t.log_time desc;
-- 审核总表生成日志


select * from cu.zs_heb_xjd where status='0';
update cu.zs_heb_xjd t set t.update_time = to_date('20150819','yyyymmdd');

-- 1. 哈行现金贷资产转让

-- 1.1更新上期数据为历史数据
update cu.zs_heb_xjd t
set t.update_time = sysdate, t.status = '1'
where t.status = '0';
commit;
select * from cu.zs_heb_xjd  t where t.status = '0'
select * from cu.zs_heb_xjd  t
delete from  cu.zs_heb_xjd  t where t.status = '0';*/
