CREATE OR REPLACE PROCEDURE HRBZLS."SP_PRINT_LHKZLS_SFQD_02" (o_base out tools.out_base) is
begin
  open o_base for
    select
      max(c1),     -------单用户(用户编号)、合收表(合收表号)
      max(c2),      --------用户(单位名称)
      max(c3),      ------开票时间
      max(c4),       -------- 单用户(用户编号)、合收表(合收表号下的多块水表的编号)
      max(c5),      --------起码
      max(c6),      --------止码
      max(c7),      --------水量
      max(c8),      --------用水类别(费用项目)+单价+水量+金额
      max(c9),       -------小写合计
      max(c10),      -------大写合计
      max(c11),      --------预留字段1
      max(c12),       --------预留字段2
      max(c13)       --------预留字段3
     from
     (
     select max(case
              when mipriflag = 'Y' then
               mipriid
              else
               cicode
            end) as c1,   -------单用户(用户编号)、合收表(合收表号)

            max(ciname ) as c2,   --------用户(单位名称)

            to_char(sysdate, 'yyyy-mm-dd') AS c3,  ------开票时间

            max(case
              when mipriflag = 'Y' then
                 f_sfqd_02('mipriid')
                 else
                   cicode
             end) as c4, -------- 单用户(用户编号)、合收表(合收表号下的多块水表的编号)

              substr(min(to_char(rldate, 'yyyymmdd') || '@' || rlid || '@' ||
                      rlscode),
                  21) as c5,    --------起码
           substr(max(to_char(rldate, 'yyyymmdd') || '@' || rlid || '@' ||
                      rlecode),
                  21) as c6,    --------止码

           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  DECODE(RLCD, 'DE', 1, -1) * RDSL
                 ELSE
                  0
               END) as c7,      ------应收水量

           F_lhkzls_ruzszzsdp_print(pp.c1,pp.c2,pp.c12) as c8,  --------用水类别(费用项目)+水量+单价+金额

              null as c9,
              null as c10,
              null as c11,
              null as c12,
              null as c13

          from
           custinfo   ci,
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
       and michargetype='M'
     GROUP BY ci.cicode, rlmonth
 ) x
  group by  c1;
end;
/

