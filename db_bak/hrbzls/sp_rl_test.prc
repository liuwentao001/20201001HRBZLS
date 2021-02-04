CREATE OR REPLACE PROCEDURE HRBZLS."SP_RL_TEST" (a_type in varchar2, a_str in varchar2,
                  o_base out tools.out_base) is
  begin
    --新版发票(柜台缴费)
    open o_base for
   select rlpid, pid,
   pmonth, pdate, pdatetime, pper,
        pposition, ptrans, pbatch, ppaypoint,
        ppayment, psavingqc, psavingbq, psavingqm,
        psxf, pznj, pspje,
        rlcname,rlmadr,
       rlid,rlmonth,rldate,rlmid,rlmcode,
       rlbfid,rlrdate,rlcaliber,
       rlpaidper,rlpaidje,
       rlscode,rlecode,rlsl,rlje,rlsxf,rlznj,
       rlsavingqc,rlsavingbq,rlsavingqm,
        D.rdje1,
        D.rdje2,
        D.rdje3,
        D.rdje4,
        D.rdje5,
        D.rdje6,
        D.rdje7,
        D.rdje8

from reclist l,PAYMENT P,
     (SELECT rdid, sum(decode(rdpiid,'01',rdsl,0)) rdsl1,
       sum(rdje) rdje,
       sum(decode(rdpiid,'01',rdje,0)) rdje1,
       sum(decode(rdpiid,'02',rdje,0)) rdje2,
       sum(decode(rdpiid,'03',rdje,0)) rdje3,
       sum(decode(rdpiid,'04',rdje,0)) rdje4,
       sum(decode(rdpiid,'05',rdje,0)) rdje5,
       sum(decode(rdpiid,'06',rdje,0)) rdje6,
       sum(decode(rdpiid,'07',rdje,0)) rdje7,
       sum(decode(rdpiid,'08',rdje,0)) rdje8
       FROM recdetail GROUP BY RDID ) D
where   l.rlpid(+)=p.pid and l.rlid=d.rdid(+)
      AND rlpaidflag='Y'
      and rlreverseflag='N'
      and preverseflag='N';

  end ;
/

