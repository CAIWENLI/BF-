-- 1. �����ֽ���ʲ�ת��

-- 1.1������������Ϊ��ʷ����
--1.1������������Ϊ��ʷ����
update cu.zs_heb_xjd t
set t.update_time = sysdate, t.status = '1'
where t.status = '0';
commit;
delete from cu.zs_heb_xfd t where t.status='0';

-- 1.2д�뵱������

insert into cu.zs_heb_xjd
(��ͬ��,
������Դ,
����,
�ſ���,
�״λ�����,
�׸����,
������,
������,
ÿ�»����,
ʣ������,
������,
ʣ������,
��������,
��ʷ�����������,
ǰ���������������,
������
)
select 
serialno ��ͬ��
,'AMAR' ������Դ
,PERSON_NAME ����
,putoutdate �ſ���
,paydate �״λ�����
,INIT_PAY    �׸����
,CREDIT_AMOUNT ������
,pay_date ������
,monthrepayment ÿ�»���� 
,balance ʣ������
,periods ������
,remain_periods ʣ������
,cpd ��������
,max_cpd  ��ʷ�����������
,max_cpd2  ǰ���������������
,baserate ������
from 
(
select t1.serialno 
,to_char(t1.inputDATE,'yyyymm') app_month
,greatest(t11.cpd-1,0) cpd
,round(t1.TOTALSUM,2) INIT_PAY
,round(t1.BUSINESSSUM,2) CREDIT_AMOUNT ---������
,round(t8.balance,2) balance  ---�������
,t1.CUSTOMERNAME PERSON_NAME--�ͻ�����
,upper(t2.certid) CERTID   --���֤��
,t5.historymaxcpddays max_cpd ---��ʷ�����������
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
-----������5�����������ṩ���֤���������Ϣ���������֤��
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
--�޳�����s1.acct_rate_segment�����53�ʺ�ͬ����53�ʺ�ͬ������������
join
cu.zs_heb_xianjindai_8 t10 on t1.serialno=t10.putoutno
join
cu.zs_heb_xiaofeidai_9 t11 on t1.serialno=t11.putoutno

where t1.CONTRACTSTATUS='050'--���ﱣ֤��ͬ�������ڻ����ƻ��У������ǽ���ĺ�ͬ
-----����(1) �����˵�������18-55��֮�䣻
and trunc(months_between(trunc(to_date(t1.INPUTDATE,'yyyy-mm-dd hh24:mi:ss')),to_date(substr(t2.certid,7,8),'yyyymmdd'))/12) between 18 and 55
-----����(8) ת���ʲ�Ϊ���ź�ͬ���·����������ֽ���ʲ���
and t1.PRODUCTID in('020','010')
and t1.creditperson like '����%'--������"�������"�ĵ�
-----����(11) ��ǰ�����ڣ�
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

-----����(7)����ǰ����ת�ø��������ݣ�
and not exists
(select t12.relativeserialno from cu.zx_heb_xiaofeidai_11 t12
 where   t12.relativeserialno=t1.serialno )
-----����(10) ������APP�����γɵ��ʲ�������Ǯô���ʲ�
--and ( t1.suretype='PC'  or t1.SURETYPE='JQM')----�޳�APP,������Ǯ
);
commit;






/*
select * from cu.zs_heb_xjd where status='0'
alter table cu.zs_heb_xjd add create_time date default sysdate;
alter table cu.cu.zs_heb_xjd add update_time date default sysdate;
alter table cu.cu.zs_heb_xjd add status varchar2(2) default 0;


select trunc(to_date(t.inputtime, 'YYYY-MM-DD HH24:MI:SS')),count(*) from s1.dealcontract_reative t 
group by trunc(to_date(t.inputtime, 'YYYY-MM-DD HH24:MI:SS'))
--ת���������ʲ�����˶��


select trunc(to_date(t.occurdate, 'YYYY-MM-DD')),count(*) from s1.busi
ness_cession t
group by trunc(to_date(t.occurdate, 'YYYY-MM-DD'))
--ת������ʵ�ʲ�����˶��
select t.transfer_date,count(*) from s2.transfer_credit_final t 
group by t.transfer_date
--ת������ʵ�ʲ���������
select * from etl.log_msg t where \*t.proc_name like 'pkg_audit.P_risk_audit_detail������begin%' and*\ t.log_time>trunc(sysdate) order by t.log_time desc;
select * from etl.log_msg t where t.proc_name like 'pkg_risk.p_risk_credit_summary_cur������%' and t.log_time>trunc(sysdate) order by t.log_time desc;
-- ����ܱ�������־


select * from cu.zs_heb_xjd where status='0';
update cu.zs_heb_xjd t set t.update_time = to_date('20150819','yyyymmdd');

-- 1. �����ֽ���ʲ�ת��

-- 1.1������������Ϊ��ʷ����
update cu.zs_heb_xjd t
set t.update_time = sysdate, t.status = '1'
where t.status = '0';
commit;
select * from cu.zs_heb_xjd  t where t.status = '0'
select * from cu.zs_heb_xjd  t
delete from  cu.zs_heb_xjd  t where t.status = '0';*/
