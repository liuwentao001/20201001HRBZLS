CREATE OR REPLACE PROCEDURE HRBZLS."SP_PRINT_LHK_SFQD" (o_base out tools.out_base) is
begin
  open o_base for
    select max(ci.cicode) as 编号,
           max(ci.ciname) as 名称,
           -------将金额大写
           tools.fuppernumber(
                              ------基本水费
                              (SUM(CASE
                                      WHEN RDPIID = '01' THEN
                                       DECODE(RLCD, 'DE', 1, -1) * RDSL
                                      ELSE
                                       0
                                    END) * max(pf.pfprice)) +
                              ---------污水处理费
                               SUM(CASE
                                     WHEN RDPIID = '02' THEN
                                      DECODE(RLCD, 'DE', 1, -1) * RDJE
                                     ELSE
                                      0
                                   END) +
                              --------水资源费
                               SUM(CASE
                                     WHEN RDPIID = '03' THEN
                                      DECODE(RLCD, 'DE', 1, -1) * RDJE
                                     ELSE
                                      0
                                   END)) as 金额合计,
           to_char(sysdate, 'yyyy-mm-dd') AS 开票时间,
           max(ci.cicode) as 编号2,
           --------如果起止码有修改的时候，取最后一次作标准
           substr(min(to_char(rldate, 'yyyymmdd') || '@' || rlid || '@' ||
                      rlscode),
                  21) as 起码,
           substr(max(to_char(rldate, 'yyyymmdd') || '@' || rlid || '@' ||
                      rlecode),
                  21) as 止码,
           ------应收水量
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  DECODE(RLCD, 'DE', 1, -1) * RDSL
                 ELSE
                  0
               END) as 应收水量,

           max(pf.pfname) as 用水类别,
           max(pf.pfprice) as 单价,
           --------水基本费用
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  DECODE(RLCD, 'DE', 1, -1) * RDSL
                 ELSE
                  0
               END) * max(pf.pfprice) as 金额1,
           -------- 污水处理费用
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  DECODE(RLCD, 'DE', 1, -1) * RDJE
                 ELSE
                  0
               END) 金额2,
           ------- 水资源费用
           SUM(CASE
                 WHEN RDPIID = '03' THEN
                  DECODE(RLCD, 'DE', 1, -1) * RDJE
                 ELSE
                  0
               END) 金额3,
           ---------合计
           (SUM(CASE
                  WHEN RDPIID = '01' THEN
                   DECODE(RLCD, 'DE', 1, -1) * RDSL
                  ELSE
                   0
                END) * max(pf.pfprice)) +
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  DECODE(RLCD, 'DE', 1, -1) * RDJE
                 ELSE
                  0
               END) + SUM(CASE
                            WHEN RDPIID = '03' THEN
                             DECODE(RLCD, 'DE', 1, -1) * RDJE
                            ELSE
                             0
                          END) as 小写合计,
           ------水资源费单价
         /*  (select case RDPIID
                     when '03' then
                      rl.rlje
                   end
              from reclist rl, recdetail rd
             where rl.rlid = rd.rdid
               and rl.rlmid = c5)

           as 水资源费单价,
           ---------污水处理费单价
           (select case RDPIID
                     when '02' then
                      rl.rlje
                   end
              from reclist rl, recdetail rd
             where rl.rlid = rd.rdid
               and rl.rlmid = c5) as 污水处理费单价,*/
       F_chargeinvsearch_recmx_ocx(max(pl.plid),max(mi.miid),4) as 水基本费费用,
           null as 预留字段1,
           null as 预留字段2,
           null as 预留字段3
      from custinfo   ci,
           reclist    rl,
           recdetail  rd,
           priceframe pf,
           PBPARMTEMP PP,
           meterinfo  mi,
           paidlist  pl
     where mi.miid = PP.C2
       AND MI.MICID = CI.CIID
       and rl.rlid = rd.rdid
       and rl.rlmid = mi.miid
       and mi.mipfid = pf.pfid
        and pl.plid=rl.rlid
       and mi.miiftax = 'Y'
       and rlmonth = pp.c7
     GROUP BY ci.cicode, rlmonth;
end;
/

