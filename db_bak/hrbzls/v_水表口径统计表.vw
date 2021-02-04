create or replace force view hrbzls.v_水表口径统计表 as
select
--按口径统计水表只数报表的数据来源
  A.营销公司,
/*  A.口径,*/
  sum(DECODE(A.口径,0,表数,0))  x0,
  sum(DECODE(A.口径,13,表数,0)) x13,
  sum(DECODE(A.口径,15,表数,0)) x15,
  sum(DECODE(A.口径,20,表数,0)) x20,
  sum(DECODE(A.口径,25,表数,0)) x25,
  sum(DECODE(A.口径,32,表数,0)) x32,
  sum(DECODE(A.口径,40,表数,0)) x40,
  sum(DECODE(A.口径,50,表数,0)) x50,
  sum(DECODE(A.口径,65,表数,0)) x65,
  sum(DECODE(A.口径,80,表数,0)) x80,
  sum(DECODE(A.口径,100,表数,0)) x100,
  sum(DECODE(A.口径,150,表数,0)) x150,
  sum(DECODE(A.口径,200,表数,0)) x200,
  sum(DECODE(A.口径,300,表数,0)) x300,
  sum(DECODE(A.口径,700,表数,0)) x700,
  sum(DECODE(sign(A.口径-700),1,表数,0)) 其他

from
(select
mi.MISMFID 营销公司,
s.smsname 状况,
case
   when md.mdcaliber in (0,13,15,20,25,32,40,50,65,80,100,150,200,300,700)
     then md.mdcaliber
    else 999
  end  口径,
count(mi.miid) 表数
from meterinfo mi,meterdoc md,sysmeterstatus s
where mi.mistatus=s.smsid
and mi.miid=md.mdmid
and mi.mistatus not in ('28','31','32','7','34','33')
--and mi.mistatus ='1'   --正常抄表
group by mi.MISMFID,s.smsname,md.mdcaliber
) A

group by 营销公司
order by 营销公司
;

