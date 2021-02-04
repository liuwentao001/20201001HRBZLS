create or replace force view hrbzls.view_metertranshd as
select mthno, mthbh, mthlb, mthsource, mthsmfid, mthdept, TRUNC(MTHCREDATE) MTHCREDATE, mthcreper, mthshflag, DECODE(MTHSHFLAG,'Y',TRUNC(MTHSHDATE),NULL) mthshdate, mthshper, mthhot, mthmrid, mtdynum
from metertranshd;

