create or replace force view hrbzls.view_reclist_charge_usetype as
select   rdid, RDPFID, RDMID meterno, RDMONTH, RDPMDID,
             sum(decode(rdpiid, '01',RDSL, 0)) wateruse, --  总水量
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, RDSL, 0),0)),0) use_r1, --  阶梯1
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, RDSL, 0),0)),0) use_r2, --  阶梯2
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, RDSL, 0),0)),0) use_r3, --  阶梯3
             nvl(sum(rdje),0) chargetotal, --  总金额
             nvl(sum(decode(rdpiid,'01',rdje,0)),0) charge1, --  代收费1
             nvl(sum(decode(rdpiid,'02',rdje,0)),0) charge2, --  代收费2
             nvl(sum(decode(rdpiid,'03',rdje,0)),0) charge3, --  代收费3
             nvl(sum(decode(rdpiid,'04',rdje,0)),0) charge4, --  代收费4
             nvl(sum(decode(rdpiid,'05',rdje,0)),0) charge5, --  代收费5
             nvl(sum(decode(rdpiid,'06',rdje,0)),0) charge6, --  代收费6
             nvl(sum(decode(rdpiid,'07',rdje,0)),0) charge7, --  代收费7
             nvl(sum(decode(rdpiid,'08',rdje,0)),0) charge8, --  代收费8
             nvl(sum(decode(rdpiid,'09',rdje,0)),0) charge9, --  代收费9
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) charge_r1, --  阶梯1金额
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) charge_r2, --  阶梯2金额
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) charge_r3, --  阶梯3金额
             sum(decode(rdpiid, '01',1, 0)) c_charge, --  笔数             0 X14,
                round(sum(case when (select mibox from meterinfo where miid = RDMID) = 1 and (rdpfid like '%B%' or rdpfid like '%C%')
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                when (select mibox from meterinfo where miid = RDMID)=2 and rdpfid like '%B%'
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                when (select mibox from meterinfo where miid = RDMID)=3 and rdpfid like '%C%'
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                when  rdpiid='05' then 0
                else rdje end),2)  realcharge
         from recdetail c
        group by  rdid, RDPFID,  RDMID, RDMONTH, RDPMDID
;

