CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTRCLNOTENEWPRINT" (
o_base out tools.out_base) is
v_mon varchar2(10);
  begin
  select max(rlmonth) into v_mon from reclist,pbparmtemp where rlid=c1 and rownum=1;
    open o_base for
SELECT
A.RLID ,                      --C1
A.RLMID  ,                    --C2
A.Ӧ���·�,                   --C3
A.�û��� ,                    --C4
A.���Ϻ� ,                    --C5
A.�����,                     --C6
A.�û���,                     --C7
A.�û���ַ,                   --C8
A.ˮ���ַ,                   --C9
A.����,                     --C10
A.�������,                   --C11
A.�����ж�,                   --C12
A.�����ж�,                   --C13
A.����ˮ��,                   --C14
A.����ˮ�� ,                  --C15
A.����ˮ��,                   --C16
A.��ˮ��,                     --C17
A.��ˮ��,                     --C18
A.��ˮ��,                     --C19
B.��תˮ��,                   --C20
B.��ת����ˮ�����ɽ�,         --C21
B.��ת����ˮ��,               --C22
B.��ת��ˮ��,                 --C23
B.��ת��ˮ�����ɽ�,           --C24
B.��ת��ˮ��,                 --C25
substr(to_char(SYSDATE,'yyyymmdd'),1,4)||'    '||substr(to_char(SYSDATE,'yyyymmdd'),5,2)||'    '||substr(to_char(SYSDATE,'yyyymmdd'),7,2) ��ӡ����, -- C26
A.����ˮ�� + nvl(B.��ת����ˮ��,0) +nvl( B.��ת����ˮ�����ɽ�,0)    Ԥ���ֶ�1   , --C27
A.��ˮ�� + nvl(B.��ת��ˮ��,0) +nvl( B.��ת��ˮ�����ɽ�,0)     Ԥ���ֶ�2   , --C28
A.����ˮ�� + nvl(B.��ת����ˮ��,0) +nvl( B.��ת����ˮ�����ɽ�,0) +  A.��ˮ�� + nvl(B.��ת��ˮ��,0) +nvl( B.��ת��ˮ�����ɽ�,0)    Ԥ���ֶ�3   , --C29
'Ԥ���ֶ�4'     Ԥ���ֶ�4   , --C30
'Ԥ���ֶ�5'     Ԥ���ֶ�5   , --C31
1     Ԥ���ֶ�6   , --          C32
1     Ԥ���ֶ�7   , --          C33
sysdate     Ԥ���ֶ�8   , --    C34
sysdate     Ԥ���ֶ�9     --       C35
FROM
(
select RLID,substr(max(rlmonth),1,4)||'    '||substr(max(rlmonth),6,2) Ӧ���·�,max(RLMID) RLMID,max(rlccode) �û���, MAX(RLMCODE) ���Ϻ�,max(mdno) �����,  max(RLCNAME) �û��� ,MAX(RLCADR) �û���ַ,max(RLMADR ) ˮ���ַ, max(mibfid) ����, max(MIRORDER ) �������, max( rlscode ) �����ж�,max( rlecode ) �����ж�,
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
from reclist ,recdetail,meterinfo,meterdoc ,pbparmtemp  where rlid=rdid and rlmid=miid
and miid=mdmid
AND   rlid = c1
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
 FROM reclist ,recdetail where rlid=rdid AND RLCD='DE' AND RDPAIDFLAG='N' AND  rdje>0  AND RLMONTH<v_mon
AND RLMID IN (
select rlmid from reclist,pbparmtemp where rlid=c1
)
GROUP BY RLMID
) B
ON A.RLMID=B.RLMID
;

end ;
/

