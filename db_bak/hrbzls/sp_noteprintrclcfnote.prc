CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTRCLCFNOTE" (
p_smfid             in varchar2, --Ӫҵ��
p_monmin            in varchar2, --�·�
p_monmax            in varchar2, --�·�
p_micodemin         in varchar2, --���Ϻ�
p_micodemax         in varchar2, --���Ϻ�
p_cicodemin         in varchar2, --�ͻ���
p_cicodemax         in varchar2, --�ͻ���
p_bfidmin           in varchar2, --���
p_bfidmax           in varchar2, --���
p_mrrper            in varchar2, --����Ա
p_rlcper            in varchar2, --�߷�Ա
p_rldatemin         in varchar2, --�������
p_rldatemax         in varchar2, --�������
p_mrdaymin          in varchar2, --��������
p_mrdaymax          in varchar2, --��������
p_milb              in varchar2, --ˮ������
p_qfcount           in varchar2, --Ƿ������
p_qfje              in varchar2, --Ƿ�ѽ��
o_base out tools.out_base) is
  begin


    open o_base for
select
a.miid,                   --C1
a.�û���,                 --C2
a.�û���ַ,               --C3
a.���Ϻ�,                 --C4
a.������,                 --C5
a.ˮ�Ѵ�����,             --C6
a.ˮ��С����,             --C7
a.��ˮ������,             --C8
a.��ˮС����,             --C9
a.ˮ��,                   --C10
a.��ˮˮ��,               --C11
a.Ƿ�ѱ���,               --C12
a.�ϼ�,                   --C13
a.����,                   --C14
a.���,                   --C15
a.�������,               --C16
a.�ͻ���,                 --C17
a.ˮ���ַ,               --C18
'Ԥ���ֶ�1'   Ԥ���ֶ�1  , --Ԥ���ֶ�1  C19
'Ԥ���ֶ�2'   Ԥ���ֶ�2  , --Ԥ���ֶ�2  C20
'Ԥ���ֶ�3'   Ԥ���ֶ�3  , --Ԥ���ֶ�3  C21
'Ԥ���ֶ�4'   Ԥ���ֶ�4  , --Ԥ���ֶ�4  C22
'Ԥ���ֶ�5'   Ԥ���ֶ�5  , --Ԥ���ֶ�5  C23
1   Ԥ���ֶ�6  , --Ԥ���ֶ�6            C24
1   Ԥ���ֶ�7  , --Ԥ���ֶ�7            C25
SYSDATE   Ԥ���ֶ�8  , --Ԥ���ֶ�8      C26
SYSDATE   Ԥ���ֶ�9   --Ԥ���ֶ�9       C27
from (
select miid,MAX(ciname) �û���,MAX(ciadr) �û���ַ,MAX(micode) ���Ϻ�,MAX(mdno) ������,
max(mibfid) ���,max(mirorder ) �������,max(cicode) �ͻ���,max(miadr) ˮ���ַ,
max( case when  rdpiid='01' then rlmonth else '0000.00' end )  ˮ�Ѵ�����,
min( case when  rdpiid='01' then rlmonth else '9999.01' end )  ˮ��С����,
max( case when  rdpiid='02' then rlmonth else '0000.00' end )  ��ˮ������,
min( case when  rdpiid='02' then rlmonth else '9999.01' end )  ��ˮС����,
SUM(case when  rdpiid='01' then RDJE else 0 end ) ˮ��,
SUM(case when  rdpiid='02' then RDJE else 0 end ) ��ˮˮ��,
count(distinct rlid) Ƿ�ѱ���,
sum( rdje ) �ϼ� ,
'15'  ����
from reclist ,recdetail,meterinfo, custinfo , meterdoc , bookframe
where rlid=rdid and rlmid=miid and miid=mdmid and  micid=ciid and mibfid=bfid and mismfid=bfsmfid
and rlcd='DE' and rdpaidflag='N' and rdje>0


and (p_smfid is null or mismfid=p_smfid)
and (p_micodemin is null or micode>=p_micodemin)
and (p_micodemax is null or micode<=p_micodemax)
and (
 (p_micodemin is null and  p_micodemax is  null)
 or
 (p_micodemin is not null and  p_micodemax is not null)
 or
 (p_micodemin is  null and  p_micodemax is not null and micode=p_micodemax)
 or
 (p_micodemin is not  null and  p_micodemax is  null and micode=p_micodemin)
 )
and (p_cicodemin is null or cicode>=p_cicodemin)
and (p_cicodemax is null or cicode<=p_cicodemax)
and (
 (p_cicodemin is null and  p_cicodemax is  null)
 or
 (p_cicodemin is not null and  p_cicodemax is not null)
 or
 (p_cicodemin is  null and  p_cicodemax is not null and cicode=p_cicodemax)
 or
 (p_cicodemin is not  null and  p_cicodemax is  null and cicode=p_cicodemin)
 )
and (p_bfidmin is null or mibfid>=p_bfidmin)
and (p_bfidmax is null or mibfid<=p_bfidmax)
and (
 (p_bfidmin is null and  p_bfidmax is  null)
 or
 (p_bfidmin is not null and  p_bfidmax is not null)
 or
 (p_bfidmin is  null and  p_bfidmax is not null and mibfid=p_bfidmax)
 or
 (p_bfidmin is not  null and  p_bfidmax is  null and mibfid=p_bfidmin)
 )
and (p_mrrper is null or  BFRPER=p_mrrper)
and (p_rlcper is null or  MICPER=p_rlcper)
and (p_milb is null or  milb=p_milb)

group by miid
) a
where  (p_qfcount is null or  a.Ƿ�ѱ���>=p_qfcount) and  (p_qfje is null or  a.�ϼ�>=p_qfje)  ;

end ;
/

