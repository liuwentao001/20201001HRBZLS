CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTRCLNOTENEWPRINT" (
o_base out tools.out_base) is
v_mon varchar2(10);
  begin
  select max(rlmonth) into v_mon from reclist,pbparmtemp where rlid=c1 and rownum=1;
    open o_base for
SELECT
A.RLID ,                      --C1
A.RLMID  ,                    --C2
A.应收月份,                   --C3
A.用户号 ,                    --C4
A.资料号 ,                    --C5
A.表身号,                     --C6
A.用户名,                     --C7
A.用户地址,                   --C8
A.水表地址,                   --C9
A.表册号,                     --C10
A.抄表序号,                   --C11
A.上月行度,                   --C12
A.本月行度,                   --C13
A.抄见水量,                   --C14
A.基本水价 ,                  --C15
A.基本水费,                   --C16
A.污水量,                     --C17
A.污水价,                     --C18
A.污水费,                     --C19
B.结转水量,                   --C20
B.结转基本水费滞纳金,         --C21
B.结转基本水费,               --C22
B.结转污水量,                 --C23
B.结转污水费滞纳金,           --C24
B.结转污水费,                 --C25
substr(to_char(SYSDATE,'yyyymmdd'),1,4)||'    '||substr(to_char(SYSDATE,'yyyymmdd'),5,2)||'    '||substr(to_char(SYSDATE,'yyyymmdd'),7,2) 打印日期, -- C26
A.基本水费 + nvl(B.结转基本水费,0) +nvl( B.结转基本水费滞纳金,0)    预留字段1   , --C27
A.污水费 + nvl(B.结转污水费,0) +nvl( B.结转污水费滞纳金,0)     预留字段2   , --C28
A.基本水费 + nvl(B.结转基本水费,0) +nvl( B.结转基本水费滞纳金,0) +  A.污水费 + nvl(B.结转污水费,0) +nvl( B.结转污水费滞纳金,0)    预留字段3   , --C29
'预留字段4'     预留字段4   , --C30
'预留字段5'     预留字段5   , --C31
1     预留字段6   , --          C32
1     预留字段7   , --          C33
sysdate     预留字段8   , --    C34
sysdate     预留字段9     --       C35
FROM
(
select RLID,substr(max(rlmonth),1,4)||'    '||substr(max(rlmonth),6,2) 应收月份,max(RLMID) RLMID,max(rlccode) 用户号, MAX(RLMCODE) 资料号,max(mdno) 表身号,  max(RLCNAME) 用户名 ,MAX(RLCADR) 用户地址,max(RLMADR ) 水表地址, max(mibfid) 表册号, max(MIRORDER ) 抄表序号, max( rlscode ) 上月行度,max( rlecode ) 本月行度,
MAX(RLREADSL ) 抄见水量 ,
sum(
 (case when rdpiid='01' then rddj*RDPMDSCALE else 0 end)
)  基本水价,
sum((case when rdpiid='01' then rdje else 0 end)) 基本水费,
sum( case when rdpiid='02' then rdsl*RDPMDSCALE else 0 end  ) 污水量,
sum(
 (case when rdpiid='02' then rddj*RDPMDSCALE else 0 end)
)   污水价,
sum((case when rdpiid='02' then rdje else 0 end)) 污水费
from reclist ,recdetail,meterinfo,meterdoc ,pbparmtemp  where rlid=rdid and rlmid=miid
and miid=mdmid
AND   rlid = c1
GROUP BY RLID
) A
LEFT JOIN
(
SELECT RLMID,sum( case when rdpiid='01' then rdsl*RDPMDSCALE else 0 end  ) 结转水量,
0  结转基本水费滞纳金,
sum((case when rdpiid='01' then rdje else 0 end)) 结转基本水费,
sum( case when rdpiid='02' then rdsl*RDPMDSCALE else 0 end  ) 结转污水量,
0 结转污水费滞纳金,
sum((case when rdpiid='02' then rdje else 0 end)) 结转污水费
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

