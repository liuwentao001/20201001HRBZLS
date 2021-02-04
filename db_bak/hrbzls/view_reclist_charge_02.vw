create or replace force view hrbzls.view_reclist_charge_02 as
select  /*+ index(c  IDX_V_G)*/ rdid,--流水号
             RDMID meterno, --水表编码
             RDMONTH,--账务月份
             max(RDPAIDMONTH) RDPAIDMONTH, --销账月份
             rdpfid,--费率
             RDMSMFID,--营业公司
             sum(decode(rdpiid, '01',RDSL, 0)) wateruse, --  总水量
              nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, RDDJ, 0),0)),0) USER_DJ1, --  阶梯1单价
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, RDDJ, 0),0)),0) USER_DJ2, --  阶梯2单价
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, RDDJ, 0),0)),0) USER_DJ3, --  阶梯3单价
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, RDSL, 0),0)),0) use_r1, --  阶梯1
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, RDSL, 0),0)),0) use_r2, --  阶梯2
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, RDSL, 0),0)),0) use_r3, --  阶梯3
             nvl(sum(rdje),0) chargetotal, --  总金额
             sum(nvl(rdznj,0)) chargeznj, --滞纳金
             nvl(sum(rddj),0) dj ,--综合单价
             nvl(sum(decode(rdpiid,'01',rddj,0)),0) dj1, --  单价1
             nvl(sum(decode(rdpiid,'02',rddj,0)),0) dj2, --  单价2
             nvl(sum(decode(rdpiid,'03',rddj,0)),0) dj3, --  单价3
             nvl(sum(decode(rdpiid,'04',rddj,0)),0) dj4, --  单价4
             nvl(sum(decode(rdpiid,'05',rddj,0)),0) dj5, --  单价5
             nvl(sum(decode(rdpiid,'06',rddj,0)),0) dj6, --  单价6
             nvl(sum(decode(rdpiid,'07',rddj,0)),0) dj7, --  单价7
             nvl(sum(decode(rdpiid,'08',rddj,0)),0) dj8, --  单价8
             nvl(sum(decode(rdpiid,'09',rddj,0)),0) dj9, --  单价9
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
              nvl(sum(decode(rdpiid,'12',rdje,0)),0) charge12, --  代收费11
              nvl(sum(decode(rdpiid,'13',rdje,0)),0) charge13, --  代收费12
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) charge_r1, --  阶梯1金额
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) charge_r2, --  阶梯2金额
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) charge_r3, --  阶梯3金额
             sum(decode(rdpiid, '01',1, 0)) c_charge, --  笔数             0 X14,
             max('') MEMO1,--备用字段1
             max('') MEMO2,--备用字段2
             sum('') MEMO3,--备用字段3
             sum('') MEMO4,--备用字段4
             max('') MEMO5,--备用字段5
             max('') MEMO6, --备用字段6
             nvl(sum(decode(rdpiid,'02',rdsl,0)),0) rdsl2, --  水量2
             nvl(sum(decode(rdpiid,'03',rdsl,0)),0) rdsl3, --  水量3
             nvl(sum(decode(rdpiid,'04',rdsl,0)),0) rdsl4, --  水量4
             nvl(sum(decode(rdpiid,'05',rdsl,0)),0) rdsl5, --  水量5
             nvl(sum(decode(rdpiid,'06',rdsl,0)),0) rdsl6, --  水量6
             nvl(sum(decode(rdpiid,'07',rdsl,0)),0) rdsl7, --  水量7
             nvl(sum(decode(rdpiid,'08',rdsl,0)),0) rdsl8, --  水量8
             nvl(sum(decode(rdpiid,'09',rdsl,0)),0) rdsl9 --  水量9
         from recdetail c
        group by  rdid,  RDMID, RDMONTH,rdpfid,RDMSMFID
;

