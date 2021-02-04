CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTRCLNOTENEW" (
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
SELECT
A.RLID ,                            --C1
A.RLMID  ,                          --C2
A.Ӧ���·�,                         --C3
A.�û��� ,                          --C4
A.���Ϻ� ,                          --C5
A.�����,                           --C6
A.�û���,                           --C7
A.�û���ַ,                         --C8
A.ˮ���ַ,                         --C9
A.����,                           --C10
A.�������,                         --C11
A.�����ж�,                         --C12
A.�����ж�,                         --C13
A.����ˮ��,                         --C14
A.����ˮ�� ,                        --C15
A.����ˮ��,                         --C16
A.��ˮ��,                           --C17
A.��ˮ��,                           --C18
A.��ˮ��,                           --C19
B.��תˮ��,                         --C20
B.��ת����ˮ�����ɽ�,               --C21
B.��ת����ˮ��,                     --C22
B.��ת��ˮ��,                       --C23
B.��ת��ˮ�����ɽ�,                 --C24
B.��ת��ˮ��,                       --C25
substr(to_char(SYSDATE,'yyyymmdd'),1,4)||'  '||substr(to_char(SYSDATE,'yyyymmdd'),5,2)||'    '||substr(to_char(SYSDATE,'yyyymmdd'),7,2) ��ӡ����,   --C26
'Ԥ���ֶ�1'           Ԥ���ֶ�1  ,  --C27
'Ԥ���ֶ�2'           Ԥ���ֶ�2  ,  --C28
'Ԥ���ֶ�3'           Ԥ���ֶ�3  ,  --C29
'Ԥ���ֶ�4'           Ԥ���ֶ�4  ,  --C30
'Ԥ���ֶ�5'           Ԥ���ֶ�5  ,  --C31
'Ԥ���ֶ�6'           Ԥ���ֶ�6  ,  --C32
'Ԥ���ֶ�7'           Ԥ���ֶ�7  ,  --C33
'Ԥ���ֶ�8'           Ԥ���ֶ�8  ,  --C34
'Ԥ���ֶ�9'           Ԥ���ֶ�9  ,  --C35
'Ԥ���ֶ�10'          Ԥ���ֶ�10 ,  --C36
'Ԥ���ֶ�11'          Ԥ���ֶ�11 ,  --C37
'Ԥ���ֶ�12'          Ԥ���ֶ�12 ,  --C38
'Ԥ���ֶ�13'          Ԥ���ֶ�13 ,  --C39
'Ԥ���ֶ�14'          Ԥ���ֶ�14 ,  --C40
'Ԥ���ֶ�15'          Ԥ���ֶ�15 ,  --C41
'Ԥ���ֶ�16'          Ԥ���ֶ�16 ,  --C42
'Ԥ���ֶ�17'          Ԥ���ֶ�17 ,  --C43
'Ԥ���ֶ�18'          Ԥ���ֶ�18 ,  --C44
'Ԥ���ֶ�19'          Ԥ���ֶ�19 ,  --C45
'Ԥ���ֶ�20'          Ԥ���ֶ�20    --C46
 FROM
(
select RLID,max(rlmonth) Ӧ���·�,max(RLMID) RLMID,max(rlccode) �û���, MAX(RLMCODE) ���Ϻ�,max(mdno) �����, max(RLCNAME) �û��� ,MAX(RLCADR) �û���ַ,max(RLMADR ) ˮ���ַ, max(mibfid) ����, max(MIRORDER ) �������, max( rlscode ) �����ж�,max( rlecode ) �����ж�,
MAX(RLREADSL ) ����ˮ�� ,
sum(
 (case when rdpiid='01' then rddj*RDPMDSCALE else 0 end)
)  ����ˮ��,
sum((case when rdpiid='01' then rdje else 0 end)) ����ˮ��,
sum( case when rdpiid='02' then rdsl*RDPMDSCALE else 0 end  ) ��ˮ��,
sum(
 (case when rdpiid='02' then rddj*RDPMDSCALE else 0 end)
)   ��ˮ��,
sum((case when rdpiid='02' then rdje else 0 end)) ��ˮ��
from reclist ,recdetail,meterinfo,meterdoc  where rlid=rdid and rlmid=miid and miid=mdmid
AND  RLCD='DE' AND RLMONTH='2009.05' AND RLBFID='1020'
and rdje>0
GROUP BY RLID
) A
LEFT JOIN
(
SELECT RLMID,sum( case when rdpiid='01' then rdsl*RDPMDSCALE else 0 end  ) ��תˮ��,
0  ��ת����ˮ�����ɽ�,
sum((case when rdpiid='01' then rdje else 0 end)) ��ת����ˮ��,
sum( case when rdpiid='02' then rdsl*RDPMDSCALE else 0 end  ) ��ת��ˮ��,
0 ��ת��ˮ�����ɽ�,
sum((case when rdpiid='02' then rdje else 0 end)) ��ת��ˮ��
 FROM reclist ,recdetail where rlid=rdid AND RLCD='DE' AND RDPAIDFLAG='N' AND  rdje>0  AND RLMONTH<'2009.05'
AND RLMID IN (
select RLMID from reclist ,recdetail where rlid=rdid
AND  RLCD='DE' AND RLMONTH='2009.05' AND RLBFID='1020'
)
GROUP BY RLMID
) B
ON A.RLMID=B.RLMID

;

end ;
/

