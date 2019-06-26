select count(*),count(distinct customerid)from cu.zs_heb_xianjindai_1;
--select count(*),count(distinct identitycard)from cu.zs_heb_xianjindai_2;
select count(*),count(distinct Objectno) from cu.zs_heb_xianjindai_3;
--select count(*),count(distinct putoutno) from cu.zs_heb_xianjindai_4;
select count(*),count(distinct putoutno) from cu.zs_heb_xianjindai_5;
select count(*),count(distinct putoutno) from cu.zs_heb_xianjindai_6;
select count(*),count(distinct typeno) from cu.zs_heb_xianjindai_7;
select count(*),count(distinct putoutno) from cu.zs_heb_xianjindai_8;
select count(*),count(distinct putoutno) from cu.zs_heb_xiaofeidai_9;
select count(*),count(distinct relativeserialno) from cu.zx_heb_xiaofeidai_11;
select count(*),count(distinct CONTRACT_NO) from cu.zx_heb_xianjindai_12;
----------------------------------------------------
delete from cu.zs_heb_xianjindai_1;
--delete from cu.zs_heb_xianjindai_2;
delete from cu.zs_heb_xianjindai_3;
--delete from cu.zs_heb_xianjindai_4;
delete from cu.zs_heb_xianjindai_5;
delete from cu.zs_heb_xianjindai_6;
delete from cu.zs_heb_xianjindai_7;
delete from cu.zs_heb_xianjindai_8;
delete from cu.zs_heb_xiaofeidai_9;
delete from cu.zx_heb_xiaofeidai_11;
delete from cu.zx_heb_xianjindai_12;
commit; 
-----------------------------------------------------
insert into cu.zs_heb_xianjindai_1
select * from v_zs_heb_xianjindai_1;
commit;
/*insert into cu.zs_heb_xianjindai_2
select * from  V_zs_heb_xianjindai_2;
commit;*/
insert into  cu.zs_heb_xianjindai_3
select * from  V_zs_heb_xianjindai_3;
commit;
/*insert into  cu.zs_heb_xianjindai_4
select * from  V_zs_heb_xianjindai_4;
commit;*/
insert into  cu.zs_heb_xianjindai_5
select * from V_zs_heb_xianjindai_5;
commit;
insert into cu.zs_heb_xianjindai_6
select * from V_zs_heb_xianjindai_6;
commit;
insert into cu.zs_heb_xianjindai_7
select * from v_zs_heb_xianjindai_7;
commit;
insert into cu.zs_heb_xianjindai_8
select * from V_zs_heb_xianjindai_8;
commit;
insert into cu.zs_heb_xiaofeidai_9
select * from V_zs_heb_xiaofeidai_9;
commit;
insert into cu.zx_heb_xiaofeidai_11
select * from v_zx_heb_xiaofeidai_11;
commit;
insert into cu.zx_heb_xianjindai_12;
select * from V_zx_heb_xianjindai_12;
commit;
---------------------------------------------------------------------------------------------------------------------
--�ͻ���Ϣ
create or replace view  V_zs_heb_xianjindai_1 as 
(
select customerid,certid,
       nvl(otherrevenue,0)+nvl(familymonthincome,0) income ----������
       ,(select itemname from s1.code_library  where codeno='Marriage' and itemno=a.marriage) family_state --����״��
       ,(select itemname from s1.code_library  where codeno='EducationExperience' and itemno=a.EduExperience)
                                                             education             ---�����̶�
       ,(select itemname from s1.code_library  where codeno='WorkDate' and itemno=a.jobtime)  jobtime ---��ǰ��λ��ҵ����
       ,(select itemname from s1.code_library  where codeno='HeadShip' and itemno=a.headship)
                                                           position                ---����ְλ
       ,(select itemname from s1.code_library  where codeno='AreaCode' and itemno=a.FamilyAdd)||a.Countryside||a.Villagecenter||a.Plot||a.Room
        cur_address    ---�־�ססַ
from rcas.v_cu_risk_credit_summary t,s1.ind_info_cu a
where t.id_person=a.customerid 
and t.EMP_POSITION_NAME not like '%����%' or t.EMP_POSITION_NAME is null----������3�������ܾ�������       
);

---------------------------------------------------------------------------------------------------------------------
/*--�����Ϣ��֤
create  or replace view  V_zs_heb_xianjindai_2 as
(
select distinct  upper(t.identitycard) identitycard 
from s1.id5_xml_ele_val_cu  t 
where t.reqheader='1A020201' and compresult='һ��' 
union
select upper(t.ident)
from  bqfinance.ID5_IDENT_RESULT@jinlong_link t
where t.compare_result='һ��'
UNION
select UPPER(T.IDENT)
from  bqfinance.ID5_RESULT@jinlong_link t
WHERE T.RESULT='���֤��������һ��'
);*/


----------------------------------------------------------------------------------------------------------------------
--�ֳ���Ƭ
create or replace view V_zs_heb_xianjindai_3 as
(
select  distinct Objectno 
from s1.ECM_PAGE 
where typeno='20002'
);

----------------------------------------------------------------------------------------------------------
/*--����������������ʲ���ת������һ��δ�����ʲ�
create or replace view V_zs_heb_xianjindai_4
 as
 (
 select c.putoutno,row_number()over(partition by c.customerid order by c.putoutdate desc)rn,c.putoutdate,c.historymaxcpddays
 from 
(
select a.putoutdate,a.putoutno,a.customerid , nvl(a.normalbalance,0) balance,nvl(a.historymaxcpddays,0)historymaxcpddays
from s1.acct_loan a
where nvl(overduebalance,0)=0 and normalbalance>0 
and a.settledate is null
)c
);*/

----------------------------------------------------------------------------------------------------------
--��һ�ڻ�����
create or replace view  V_zs_heb_xianjindai_5 as
(select a2.putoutno
        ,to_date(a1.paydate,'yyyy/mm/dd') paydate
        ,to_char(to_date(a1.paydate,'yyyy/mm/dd'),'dd') pay_date
        ,a1.payprincipalamt
        ,a1.payinteamt
from s1.acct_payment_schedule a1,s1.acct_loan a2
where a1.objectno=a2.serialno 
and a1.objecttype='jbo.app.ACCT_LOAN' 
and a1.seqid=1 
and a1.paytype='1'
);

---------------------------------------------------------------------------------------------------------
--ʣ������
create or replace view V_zs_heb_xianjindai_6 as
(select a2.putoutno
        ,count(distinct a1.seqid) remain_periods
        ,sum(a1.payprincipalamt)balance
from s1.acct_payment_schedule a1,s1.acct_loan a2 
where a1.objectno=a2.serialno
and a1.objecttype='jbo.app.ACCT_LOAN' 
and a1.paytype='1' 
and to_date(a1.paydate,'yyyy/mm/dd')>=trunc(sysdate)
and nvl(a2.overduebalance,0)=0 
and a2.normalbalance>0 
and a2.settledate is null
group by a2.putoutno
);


----------------------------------------------------------------------------------------------------
--������
create or replace view  V_zs_heb_xianjindai_7 as
(
select a.typeno,round(a.baserate,2)||'%' baserate
from s1.business_type a
);

---------------------------------------------------------------------------------------------------
--�޳�����s1.acct_rate_segment�����53�ʺ�ͬ����53�ʺ�ͬ������������
create or replace view V_zs_heb_xianjindai_8 as
(
select distinct t2.putoutno
from s1.acct_rate_segment t1,s1.acct_loan t2
where t1.objecttype='jbo.app.ACCT_LOAN' 
and t2.serialno=t1.objectno
and t1.status ='1'
);
---------------------------------------------------------------------------------------------------
--ǰ����������������ǰ��������

create or replace view v_zs_heb_xiaofeidai_9 as
(
select al.putoutno,
max(al.cpddays) cpd,
max(case when aps.seqid='1' then nvl(to_date(aps.finishdate,'yyyy/mm/dd'),trunc(sysdate))-to_date(aps.paydate,'yyyy/mm/dd') else 0 end)dd1,
max(case when aps.seqid='2' then nvl(to_date(aps.finishdate,'yyyy/mm/dd'),trunc(sysdate))-to_date(aps.paydate,'yyyy/mm/dd') else 0 end)dd2,
max(case when aps.seqid='3' then nvl(to_date(aps.finishdate,'yyyy/mm/dd'),trunc(sysdate))-to_date(aps.paydate,'yyyy/mm/dd') else 0 end)dd3,

max(al.putoutdate) putoutdate,
min(trunc(sysdate)) - min(case when aps.finishdate is null and to_date(aps.paydate, 'yyyy/mm/dd') < trunc(sysdate) then to_date(aps.paydate, 'yyyy/mm/dd') else trunc(sysdate) end) dpd
from s1.acct_loan al,s1.acct_payment_schedule aps
where al.serialno=aps.acct_loan_no
group by al.putoutno
);
-----------------------------------------------------------------------------------------------------
--��ת���ʲ����������
create or replace view V_zx_heb_xiaofeidai_11 as
(
select t.relativeserialno from s1.business_cession t --��ת�ü�ʵ�ʲ�
union all
SELECT t1.contractserialno FROM s1.dealcontract_reative t1,s1.transfer_group t2 
where t1.status in ('01','04') 
and t1.SERIALNO=t2.serialno
and t2.dealstatus='05'--����ȷ����ת�ù����ʲ�
--and t1.inputtime<'2016/05/31'
union all
--����(9)������������Ʋ�Ʒ��   
select serialno from s1.business_contract_cu where isp2p='1'
)
;
-----------------------------------------------------------------------------------------------------
----���������֤��ͬ
create or replace view V_zx_heb_xianjindai_12 as
(select distinct CONTRACT_NO from 
(
select t.CONTRACT_NO from rcas.v_risk_audit_detail t where t.CUR_REASULT like '%��Ϣ����%' 
union
select t3.SERIALNO from s1.id5_xml_ele_val_cu t1,s1.ind_info_cu t2,s1.business_contract_cu t3 
where upper(t1.IDENTITYCARD)=upper(t2.CERTID)
and t2.CUSTOMERID=t3.CUSTOMERID
and t1.reqheader='1A020201' and t1.compresult='һ��') 
)
;
