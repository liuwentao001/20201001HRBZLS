CREATE OR REPLACE FORCE VIEW HRBZLS.V_�ʽ���ձ��� AS
(
SELECT
 A.Ӫҵ��,
 A.�·�,
 sum(A.����) ���ս��,
 sum(A.����+ A.����) ���ս��,
 sum(A.����)  ����,
 sum(B.����Ʊ��) ����Ʊ��,
 round(sum((B.����Ʊ�� - A.����)*B.ˮ�ѷ�̯),2) ������ˮ����,
 sum(B.����Ʊ��)  ����Ʊ��,
 round(sum(B.����Ʊ��*B.ˮ�ѷ�̯),2)  ����,
 round(sum((B.����Ʊ�� - A.����)*B.��ˮ��̯),2) ��ˮ������ˮ,
 round(sum(B.����Ʊ��*B.��ˮ��̯),2) ������ˮ
FROM
( select
 RSD.OFAGENT Ӫҵ��,
 RSD.U_MONTH �·�,
 RSD.WATERTYPE ����,
 SUM(CASE WHEN RSD.T16 not in ('u', '13', 'v', '14', '21','23') AND RSD.CHAREGETYPE='X' THEN  NVL(RSD.X37,0)  ELSE 0 END ) ����,
SUM(CASE WHEN RSD.T16 not in ('u', '13', 'v', '14', '21','23') AND RSD.CHAREGETYPE='M' THEN  NVL(RSD.X37,0)  ELSE 0 END ) ����,
SUM(CASE WHEN RSD.T16  in ( 'u', '13')  THEN  NVL(RSD.X37,0)  ELSE 0 END ) ����
 from RPT_SUM_DETAIL RSD

 GROUP BY RSD.OFAGENT,RSD.U_MONTH,RSD.WATERTYPE) A,

 (
  select OFAGENT Ӫҵ��,
   pm.pmonth �·�,
   t.watertype ����,
    sum(decode(substr(pm.pposition,1,2),'02',pm.ppayment,0)) ����Ʊ��,
    sum(decode(substr(pm.pposition,1,2),'03',pm.ppayment,0)) ����Ʊ��,
    max(k.sf_rate) ˮ�ѷ�̯,
    max(k.psf_rate) ��ˮ��̯
from
payment pm,MV_METER_PROP T,V_ˮ�����۷ѷ�̯���� K
where pmid=METERNO
       AND T.WATERTYPE=K.pfid
      and CHARGETYPE='X'
      group by OFAGENT,pm.pmonth,t.watertype)B

 WHERE A.Ӫҵ��=B.Ӫҵ��
 and a.�·�=B.�·�
 and a.����=b.����
 group by A.Ӫҵ��,a.�·�
 );

