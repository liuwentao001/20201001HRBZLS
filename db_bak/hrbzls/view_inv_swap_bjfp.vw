CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_BJFP AS
SELECT '' ID, --出票流水号
       '' ISID, --发票流水号
       '' ISPCISNO, --票据批次||号码
       '0' DYFS, --打印方式(0,正常，1. 补打，2.重打)
       0 PRINTNUM, --打印次数
       '0' STATUS, --状态(0，正常、1, 作废、2,红票、3,蓝票)
       '' FKFS, --付款类型(xj 现金,zp,支票 )
       'I' CPLX, --出票类型（p,实收出账,l，应收出账）
       'H' CPFS, --出票方式（合票、分票、预存票、存折，稽查,.......）
       MAX(RLMICOLUMN2)  PPBATCH, --打印批次
       '' BATCH, --实收批次
       'Y' FLAG, --销账标志
       MAX(RLPRIMCODE) MCODE, --客户代码
       FGETOPERNAME(fgetpboper) POPER , --打印员
       SYSDATE pdate,  --打印时间
      (CASE
         WHEN MAX(RLTRANS) in ('u','v','13','14','21','23') THEN
          MAX(RLCNAME)
         ELSE
          MAX(MINAME)
       END) RLCNAME, --用户名称
       DECODE(FGETIFBJZY(MAX(RLPRIMCODE)),'Y',MAX(RLMADR),MAX(MIADR)) RLCADR, --用户地址
       --'' rlcname ,       --用户名称
       --'' rlcadr,         --用户地址
       --(select MAX(M.MINAME) from meterinfo M where M.MIID=RLPRIMCODE)  rlcname ,       --用户名称
       --(select MAX(M.MIADR) from meterinfo M where M.MIID=RLPRIMCODE)  rlcadr,         --用户地址
       max(rd.dj) dj,          --总单价
       max(rd.dj1) dj1,         --单价1
       max(rd.dj2) dj2,         --单价2
       max(rd.dj3) dj3,         --单价3
       max(rd.dj4) dj4,         --单价4
/*       max(rd.dj5) dj5,         --单价5
       max(rd.dj6) dj6,         --单价6
       max(rd.dj7) dj7,         --单价7*/
       (case when MAX(RLTRANS) in ('13','14','21','23') and MAX(RLINVMEMO)='A' then MAX(rd.YSDJ1) else null end ) dj5,         --单价5
       (case when MAX(RLTRANS) in ('13','14','21','23') and MAX(RLINVMEMO)='A' then MAX(rd.YSDJ2) else null end ) dj6,         --单价6
       (case when MAX(RLTRANS) in ('13','14','21','23') and MAX(RLINVMEMO)='A' then MAX(rd.YSDJ3) else null end ) dj7,         --单价7
       --max(rd.dj8) dj8,         --单价8
       --max(rd.dj9) dj9,         --单价9
       fgetsf(max(mipfid)) dj8,         --借用存用户当前净水价
       fgetwsf(max(mipfid)) dj9,      --借用存用户当前污水价

       SUM(rlsl)   sl,--水量
       SUM(rd.charge1) CPJE01, --出票金额1
       SUM(rd.charge2) CPJE02, --出票金额2
       SUM(rd.charge3) CPJE03, --出票金额3
       sum(rd.charge4) CPJE04, --出票金额4
       sum(rd.charge5) CPJE05, --出票金额5
       SUM(rd.charge_r1) CPJE06, --出票金额5(阶梯1
       SUM(rd.charge_r2) CPJE07, --出票金额5(阶梯2
       SUM(rd.charge_r3) CPJE08, --出票金额5(阶梯3
       sum(rd.charge6) CPJE09, --出票金额6
       sum(rd.charge7) CPJE10, --出票金额7
       0 ZNJ,              --违约金
       SUM(rd.charge1+
           rd.charge2+
           rd.charge3+
           rd.charge4+
           rd.charge5+
           rd.charge_r1+
           rd.charge_r2+
           rd.charge_r3+
           rd.charge6+
           rd.charge7+
           rlznj) yshj,  --应收合计
       SUM(RLJE) FKJE, --付款金额
       SUM(rlje) XZJE, --销账金额
       SUM(  decode(miiftax,
                  'N',
                  RLJE,
                  CHARGE2 + CHARGE3 + CHARGE4 + CHARGE5 + CHARGE6 + CHARGE7)) kpje, --开票金额
       SUM(rlsxf) SXF, --手续费
       0 JMJE, --减免金额
       0  QCSAVING, --上次结存  max(PSAVINGQC)
       0  QMSAVING, --本次结存   max(PSAVINGQM)
       0  BQSAVING, --本期预存发生
       '' CZPER, --冲正人员
       '' CZDATE, --冲正日期
       '' JZDID, --进账单流水
       0 yjbss,     --预计表示数
       min(decode(FGETIFDZSB(rl.rlmid),'Y','-',decode(pg_ewide_invmanage_01.fgetmeterstatus(rl.rlmid),'Y','-',rl.rlscode)))  SCODE,-- 起码
       max(decode(FGETIFDZSB(rl.rlmid),'Y','-',decode(pg_ewide_invmanage_01.fgetmeterstatus(rl.rlmid),'Y','-',rl.rlecode)))  ECODE,  --止码
       max(rl.rlmonth)  MONTH,  --水费月份
       to_char(sysdate,'yyyy.mm')  pmonth,  --打票月份
       '走收合打发票'  FPTYPE,
       ''   REVERSEFLAG,  --冲正
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'NY',6) MEMO01, -- 备注1
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'BSS',6) MEMO02, --备注2
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'SL',6) MEMO03, --备注3
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'DJ',6) MEMO04, --备注4
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'SF',6) MEMO05, --备注5
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'WSF',6) MEMO06, --备注6
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'WYJ',6) MEMO07, --备注7
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'XJ',6) MEMO08, --备注8
       PG_EWIDE_INVMANAGE_01.fgethscode(MAX(RLID)) MEMO09, --备注9
       FGETOPERNAME(max(mi.micper)) MEMO10, --备注10收款员
       pg_ewide_invmanage_01.fgetnewcardno(max(rl.rlmid)) MEMO11, --备注11新账卡号
       (CASE WHEN MAX(RLTRANS)  in ('13','14','21','23') then FGETSYSCHARLIST('补缴类别',PG_EWIDE_INVMANAGE_01.fgetinvmemo(max(rlid),'rlinvmemo')) else null end) MEMO12, --备注12  发票备注 追补类别
       (CASE WHEN MAX(RLTRANS)  in ('13','14','21','23') then PG_EWIDE_INVMANAGE_01.fgetinvmemo(max(rlid),'rlmemo') else null end) MEMO13, --备注13  备注
       FGETSMFNAME(FGETOPERDEPT(fgetpboper))  MEMO14, --备注14  开票人单位
       PG_EWIDE_INVMANAGE_01.fgetinvmemo(max(rlid),'bfpper') MEMO15, --备注15  表册收费员
       MAX(RLTRANS) MEMO16, --备注16 --应收事务
       FGETSMFNAME(max(rlsmfid)) MEMO17, --备注17 缴费机构（开票单位）
       '' MEMO18, --备注18
       '' MEMO19, --备注19
       FGETBFORDER(MAX(RL.RLPRIMCODE)) MEMO20  --备注20
  FROM reclist rl,view_reclist_charge rd,meterinfo mi,pbparmtemp p
  WHERE rd.rdid= rl.rlid and
        rl.rlmid=mi.miid
  and rl.rlid=p.c1
  and f_getifprint(rlmid)<>'N'
  and rlpaidflag = 'N'
  and (rloutflag = 'Y' or nvl(RLIFINV, 'N') = 'Y')
--  and rlmid='3125041020'
  GROUP BY RLID
;

