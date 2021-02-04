create or replace force view hrbzls.view_reclist_charge as
select   rdid, RDMID meterno, RDMONTH,max(RDPAIDMONTH) RDPAIDMONTH,max(RDPAIDFLAG) RDPAIDFLAG,max(RDMSMFID) RDMSMFID,
             sum(decode(rdpiid, '01',RDSL, 0)) wateruse, --  总水量
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, RDSL, 0),0)),0) use_r1, --  阶梯1
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, RDSL, 0),0)),0) use_r2, --  阶梯2
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, RDSL, 0),0)),0) use_r3, --  阶梯3
             nvl(sum(rdje),0) chargetotal, --  总金额
          --SUM (CASE WHEN RDPIID = '01' AND RDadjsl<> 0 THEN 1 ELSE 0 END)  dis_c,                   --  收免件数
           max (CASE WHEN RDPIID = '01' AND RDadjsl<> 0 THEN 1 ELSE 0 END)  dis_c,                   --  收免件数  20160429 由于阶梯水价问题  将sum改成max
         SUM (CASE WHEN RDPIID = '01' AND RDadjsl<> 0 THEN RDadjsl  ELSE 0 END) dis_u1,                   --  收免水量
         SUM (CASE WHEN RDPIID = '01' AND RDadjsl<> 0 THEN RDadjsl * rddj  ELSE 0 END) dis_m1,                   --  收免水费
         SUM (CASE WHEN RDPIID = '02' AND RDadjsl<> 0 THEN RDadjsl  ELSE 0 END) dis_u2,                   --  收免污水量
          SUM (CASE WHEN RDPIID = '02' AND RDadjsl<> 0 THEN RDadjsl * rddj  ELSE 0 END) dis_m2,                   --  收免污水费
         SUM (CASE WHEN  RDadjsl<> 0 THEN RDadjsl * rddj  ELSE 0 END)  dis_m,                   --  收免金额

             nvl(sum(RDYSDJ),0) dj ,--综合单价
             nvl(max(decode(rdpiid, '01', rdysdj, 0)), 0) ysdj1, --  应收单价1
             nvl(max(decode(rdpiid, '02', rdysdj, 0)), 0) ysdj2, --  应收单价2
             nvl(max(decode(rdpiid, '03', rdysdj, 0)), 0) ysdj3, --  应收单价3

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
             nvl(sum(decode(rdpiid,'02',rdje,0)),0) charge2, --  污水费
             nvl(sum(decode(rdpiid,'03',rdje,0)),0) charge3, --  水资源
             nvl(sum(decode(rdpiid,'04',rdje,0)),0) charge4, --  垃圾费
             nvl(sum(decode(rdpiid,'05',rdje,0)),0) charge5, --  垃圾费
             nvl(sum(decode(rdpiid,'06',rdje,0)),0) charge6, --  垃圾费
             nvl(sum(decode(rdpiid,'07',rdje,0)),0) charge7, --  垃圾费
             nvl(sum(decode(rdpiid,'08',rdje,0)),0) charge8, --  垃圾费
             nvl(sum(decode(rdpiid,'09',rdje,0)),0) charge9, --  垃圾费
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) charge_r1, --  阶梯1金额
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) charge_r2, --  阶梯2金额
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) charge_r3, --  阶梯3金额
             sum(decode(rdpiid, '01',1, 0)) c_charge --  笔数             0 X14,
         from recdetail c
        group by  rdid,  RDMID, RDMONTH
;

