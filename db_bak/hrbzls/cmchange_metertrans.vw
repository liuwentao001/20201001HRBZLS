create or replace force view hrbzls.cmchange_metertrans as
(select cchno,
       cchbh,
       cchlb,
       cchsource,
       cchsmfid,
       cchdept,
       cchcredate,
       cchcreper,
       cchshflag,
       cchshdate,
       cchshper,
       to_char(cchcredate,'yyyy.mm') cchmonth
  from custchangehd t, billmain t1
 where t.cchlb = t1.bmtype
   and t1.bmid in ('003','005', '017', '019', '018', '006'))
   union
  (select mthno      cchno,
       mthbh      cchbh,
       mthlb      cchlb,
       mthsource  cchsource,
       mthsmfid   cchsmfid,
       mthdept    cchdept,
       mthcredate cchcredate,
       mthcreper  cchcreper,
       mthshflag  cchshflag,
       mthshdate  cchshdate,
       mthshper   cchshper,
       to_char(MTHCREDATE,'yyyy.mm') cchmonth
  from metertranshd t2, billmain t3
 where t2.mthlb = t3.bmtype
   and t3.bmid in ('110', '113', '112', '011', '110','111','002','007'));

