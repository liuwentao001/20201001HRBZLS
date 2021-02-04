create or replace force view hrbzls.view_reclist_charge_01_01 as
select  /*+ index(c  IDX_V_G)*/ rdid, RDMID meterno, RDMONTH,max(RDPAIDMONTH) RDPAIDMONTH,rdpfid,RDMSMFID,
             sum(decode(rdpiid, '01',RDSL, 0)) wateruse, --  总水量
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, RDSL, 0),0)),0) use_r1, --  阶梯1
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, RDSL, 0),0)),0) use_r2, --  阶梯2
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, RDSL, 0),0)),0) use_r3, --  阶梯3
             nvl(sum(rdje),0) chargetotal, --  总金额
             sum(nvl(rdznj,0)) chargeznj,
           --  nvl(sum(RDYSDJ),0) dj ,--综合单价
             nvl(max(decode(rdpiid,'01',rddj,0)),0) dj1, --  单价1
             nvl(max(decode(rdpiid,'02',rddj,0)),0) dj2, --  单价2
             nvl(max(decode(rdpiid,'03',rddj,0)),0) dj3, --  单价3
             nvl(max(decode(rdpiid,'04',rddj,0)),0) dj4, --  单价4
             nvl(max(decode(rdpiid,'05',rddj,0)),0) dj5, --  单价5
             nvl(max(decode(rdpiid,'06',rddj,0)),0) dj6, --  单价6
             nvl(max(decode(rdpiid,'07',rddj,0)),0) dj7, --  单价7
             nvl(max(decode(rdpiid,'08',rddj,0)),0) dj8, --  单价8
             nvl(max(decode(rdpiid,'09',rddj,0)),0) dj9, --  单价9
             nvl(sum(decode(rdpiid,'01',rdje,0)),0) charge1, --  水费
             nvl(sum(decode(rdpiid,'02',rdje,0)),0) charge2, --  代收费1
             nvl(sum(decode(rdpiid,'03',rdje,0)),0) charge3, --  代收费2
             nvl(sum(decode(rdpiid,'04',rdje,0)),0) charge4, --  代收费3
             nvl(sum(decode(rdpiid,'05',rdje,0)),0) charge5, --  代收费4
             nvl(sum(decode(rdpiid,'06',rdje,0)),0) charge6, --  代收费5
             nvl(sum(decode(rdpiid,'07',rdje,0)),0) charge7, --  代收费6
             nvl(sum(decode(rdpiid,'08',rdje,0)),0) charge8, --  代收费7
             nvl(sum(decode(rdpiid,'09',rdje,0)),0) charge9, --  代收费8
             nvl(sum(decode(rdpiid,'10',rdje,0)),0) charge10, --  代收费9
              nvl(sum(decode(rdpiid,'11',rdje,0)),0) charge11, --  代收费10
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) charge_r1, --  阶梯1金额
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) charge_r2, --  阶梯2金额
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) charge_r3, --  阶梯3金额
             sum(decode(rdpiid, '01',1, 0)) c_charge, --  笔数             0 X14,
              round(sum(case when (select mibox from meterinfo where miid = RDMID) = '1' and (rdpfid like '%B%' or rdpfid like '%C%')
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                when (select mibox from meterinfo where miid = RDMID)='2' and rdpfid like '%B%'
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                when (select mibox from meterinfo where miid = RDMID)='3' and rdpfid like '%C%'
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                when  rdpiid='05' then 0
                else rdje end),2)  realcharge
         from recdetail c
        group by  rdid,  RDMID, RDMONTH,rdpfid,RDMSMFID
;

