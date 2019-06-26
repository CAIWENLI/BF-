/*FYI

ɸѡ�������£�
��1�������˵�������18-55��֮�䣻
��2�������ܾ������룻
��3�����������ṩ���֤���������Ϣ���������֤��
��4�����������ֳ�������Ƭ��
��5�������������ҵ�ǰ������
��6��0Ϣ��Ʒ�ͷ�0Ϣ��Ʒ��һ�������ṩ���ɣ�
��7����������ת�ø���ʵ�͹��е��ʲ���
��8��ת���ʲ�Ϊ��̩��ͬ���·������������ѽ����ʲ���
��9��������������Ʋ�Ʒ��
��10��������APP�����γɵ��ʲ���*/

/*ת���������£�
��1�������˵�������18-55��֮�䣻
��2�������ܾ������룻
��3�����������ṩ���֤���������Ϣ���������֤��
��4�����������ֳ�������Ƭ��
��5�������������ҵ�ǰ������
��6��0Ϣ��Ʒ�ͷ�0Ϣ��Ʒ��һ�������ṩ���ɣ�
��7����������ת�ø���ʵ�͹��е��ʲ���
��8��ת���ʲ�Ϊ���ź�ͬ���·������������ѽ����ʲ���
��9��������������Ʋ�Ʒ��
��10��������APP�����γɵ��ʲ���*/


��ͬ��	������Դ	����	�ſ���	�״λ�����	�׸����	������	������	ÿ�»����	ʣ������	
������	ʣ������	��������	��ʷ�����������	ǰ���������������*/



select 
CONTRACT_NO ��ͬ��
,DATA_SOURCE ������Դ
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
,nvl(cpd,0) ��������
,max_cpd    ��ʷ�����������
,max_cpd2 ǰ���������������
,baserate ������
from 
(
select t1.CONTRACT_NO ,to_char(t1.APP_DATE,'yyyymm') app_month
,greatest(t1.cpd-1,0) cpd
,t1.DATA_SOURCE
,round(t1.INIT_PAY,2) INIT_PAY
,round(t1.CREDIT_AMOUNT,2) CREDIT_AMOUNT ---������
,round(t8.balance,2) balance  ---�������
,t1.PERSON_NAME
,t1.PERSON_SEX
,trunc(months_between(sysdate,to_date(substr(upper(t1.cert_seq),7,8),'yyyymmdd'))/12) PERSON_CUR_AGE         ---�ͻ���ǰ����
,t2.cur_address            ---סַ
,upper(t1.CERT_seq) CERTID   --���֤��
,t2.family_state        --- ����״��
,case when rcas.pkg_utl.f_get_city_name(substr(t1.CERT_seq,1,4)||'00')=t1.CITY then '�������֤' else '������֤' end certid_status  ---��������
,t2.education                                                                                    ---�Ļ��̶�
,t2.jobtime                                                                                     ----��ǰ��λ��ҵ����
,decode(t2.income,0,0,round(t1.CREDIT_AMOUNT/t2.income, 2))  CREDIT_AMOUNT_rate                 ----��������¾������
,t5.historymaxcpddays max_cpd ---��ʷ�����������
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
       nvl(otherrevenue,0)+nvl(familymonthincome,0) income ----������
       ,(select itemname from s1.code_library  where codeno='Marriage' and itemno=a.marriage) family_state --����״��
       ,(select itemname from s1.code_library  where codeno='EducationExperience' and itemno=a.EduExperience)
                                                             education             ---�����̶�
       ,(select itemname from s1.code_library  where codeno='WorkDate' and itemno=a.jobtime)  jobtime ---��ǰ��λ��ҵ����
       ,(select itemname from s1.code_library  where codeno='HeadShip' and itemno=a.headship)
                                                           position                ---����ְλ
       ,(select itemname from s1.code_library  where codeno='AreaCode' and itemno=a.FamilyAdd)||a.Countryside||a.Villagecenter||a.Plot||a.Room
        cur_address    ---�־�ססַ
from s1.ind_info_cu a
where unitkind<>'10'   ----������2�������ܾ�������       
) t2
on t1.ID_PERSON=t2.customerid  
-----������3�����������ṩ���֤���������Ϣ���������֤;
join 
(
select distinct  upper(t.identitycard) identitycard ----------------ȥ��
from s1.id5_xml_ele_val_cu  t
where t.reqheader='1A020201' and compresult='һ��' -------------------��˶
union
select upper(t.ident)
from  bqfinance.ID5_IDENT_RESULT@jinlong_link t--------------����
where t.compare_result='һ��'
UNION
select UPPER(T.IDENT)
from  bqfinance.ID5_RESULT@jinlong_link t-----------------����
WHERE T.RESULT='���֤��������һ��'
) t3
on upper(nvl(t1.CERT_seq,t2.certid))=identitycard
join-----������4�����������ֳ�������Ƭ��
(
select  Objectno ----------��ͬ��
from s1.ECM_PAGE 
where typeno='20002'
)  t4 on t1.CONTRACT_NO=Objectno
join -----���һ�ʺ�ͬ����ǰ��δ��ʱ�����δ��ǰ���塢
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
join                                     -------------------ÿ�»������ڼ�Ӧ��������Ϣ
(select a2.putoutno,to_date(a1.paydate,'yyyy/mm/dd') paydate,to_char(to_date(a1.paydate,'yyyy/mm/dd'),'dd') pay_date,a1.payprincipalamt,a1.payinteamt
from s1.acct_payment_schedule a1,s1.acct_loan a2
where a1.objectno=a2.serialno and a1.objecttype='jbo.app.ACCT_LOAN' and a1.seqid=1 and a1.paytype='1'
) t6 on t1.CONTRACT_NO=t6.putoutno
join s1.business_contract_cu t7 on t1.CONTRACT_NO=t7.serialno
join                                     --------------------ʣ�౾������
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
join                      -------------------������
(
select a.typeno,round(a.baserate,2)||'%' baserate
from
s1.business_type a
) t9 on t1.PROD_CODE=t9.typeno
--�޳�����s1.acct_rate_segment�����53�ʺ�ͬ����53�ʺ�ͬ������������
join
(
select t2.putoutno
from s1.acct_rate_segment t1,s1.acct_loan t2
where t1.objecttype='jbo.app.ACCT_LOAN' 
and t2.serialno=t1.objectno
and t1.status ='1'
) t10 on t10.putoutno=t1.contract_no 

where t1.STATUS_EN in('a','050')--���ﱣ֤��ͬ�������ڻ����ƻ��У������ǽ���ĺ�ͬ
-----����(1) �����˵�������18-55��֮�䣻
and trunc(months_between(t1.APP_DATE,to_date(substr(nvl(t1.CERT_seq,t2.certid),7,8),'yyyymmdd'))/12) between 18 and 55
-----����(8) ת���ʲ�Ϊ���ź�ͬ���·������������ѽ����ʲ���
and t1.loan_type='030'
and t7.CREDITPERSON like '%����%'
-----����(5) ��ǰ�����ڣ�
and nvl(t1.dpd,0)=0
-----����(7) ��������ǰ��ʵת�����ݣ�����ǰ����ת�ø��������ݣ�
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
select t.relativeserialno from s1.business_cession t --��ת�ü�ʵ�ʲ�
union
SELECT t.contractserialno FROM s1.dealcontract_reative t where t.status='01' --��ת�ù����ʲ�
union
--����(9) ������������Ʋ�Ʒ��  
select serialno from s1.business_contract where isp2p='1' --�޳��������
)
where relativeserialno=t1.contract_no 
)
and t1.DATA_SOURCE='AMAR'
-----����(10) ������APP�����γɵ��ʲ���
and t1.sure_type='PC' --�޳�APP
)


