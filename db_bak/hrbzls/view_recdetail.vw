create or replace force view hrbzls.view_recdetail as
select
            RDID,
            RDMONTH,
             --sum(decode(c.rdpiid, '01',1, 0)) c_use, --  笔数
             max(decode(c.rdpiid, '01',1, 0)) c_use, --  笔数  20160429 由于阶梯水价问题  将sum改成max
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) wateruse, --  总水量
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) r1, --  阶梯1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) r2, --  阶梯2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) r3, --  阶梯3
             nvl(sum(c.rdje),0) chargetotal, --  总金额
             nvl(sum(decode(c.rdpiid,'01',c.rdje,0)),0) charge1, --  水费
             nvl(sum(decode(c.rdpiid,'02',c.rdje,0)),0) charge2, --  代收费2
             nvl(sum(decode(c.rdpiid,'03',c.rdje,0)),0) charge3, --  代收费3
             nvl(sum(decode(c.rdpiid,'04',c.rdje,0)),0) charge4, --  代收费4
             nvl(sum(decode(c.rdpiid,'04',c.rdje,0)),0) charge5, --  代收费5
             nvl(sum(decode(c.rdpiid,'04',c.rdje,0)),0) charge6, --  代收费6
             nvl(sum(decode(c.rdpiid,'04',c.rdje,0)),0) charge7, --  代收费7
             nvl(sum(decode(c.rdpiid,'04',c.rdje,0)),0) charge8, --  代收费8
             nvl(sum(decode(c.rdpiid,'01',decode(c.rdclass, 1, c.rdje, 0),0)),0) charge_r1, --  阶梯1金额
             nvl(sum(decode(c.rdpiid,'01',decode(c.rdclass, 2, c.rdje, 0),0)),0) charge_r2, --  阶梯2金额
             nvl(sum(decode(c.rdpiid,'01',decode(c.rdclass, 3, c.rdje, 0),0)),0) charge_r3 --  阶梯3金额
from   recdetail c
        group by RDID,
            RDMONTH
;

