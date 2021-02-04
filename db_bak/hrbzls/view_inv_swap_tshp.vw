CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_TSHP AS
SELECT '' ID, --出票流水号
       '' ISID, --发票流水号
       '' ISPCISNO, --票据批次||号码
       '0' DYFS, --打印方式(0,正常，1. 补打，2.重打
       0 PRINTNUM, --打印次数
       '0' STATUS, --状态(0，正常、1, 作废、2,红票、3,蓝票
       '' FKFS, --付款类型(xj 现金,zp,支票
       'L' CPLX, --出票类型（p,实收出账,l，应收出账）
       'TS' CPFS, --出票方式（合票、分票、预存票、存折，稽查,.......）
       rlentrustbatch  PPBATCH, --打印批次
       ''  BATCH, --实收批次
       'N' FLAG, --销账标志
      sum( rl.rlje) FKJE, --付款金额
       sum(rl.rlje) XZJE, --销账金额
      sum( PG_EWIDE_PAY_01.getznjadj(rlid,rlje,rlgroup,rl.rlzndate,RLSMFID,trunc(sysdate)) )  ZNJ, --滞纳金
       sum(rl.rlsxf) SXF, --手续费
       0 JMJE, --减免金额
       0 QCSAVING, --上次结存
       0 QMSAVING, --本次结存
       0 BQSAVING, --本期预存发生
       '' CZPER, --冲正人员
       '' CZDATE, --冲正日期
       '' JZDID, --进账单流水
      sum( rd.charge1) CPJE01, --出票金额1
       sum(rd.charge2) CPJE02, --出票金额2
       sum(rd.charge3) CPJE03, --出票金额3
      sum( rd.charge4) CPJE04, --出票金额4
       sum(charge5) CPJE05, --出票金额5
      sum( rd.charge_r1) CPJE06, --出票金额5(阶梯1
       sum(rd.charge_r2) CPJE07, --出票金额5(阶梯2
       sum(rd.charge_r3) CPJE08, --出票金额5(阶梯3
      sum( charge6) CPJE09, --出票金额7(预留
      sum( charge7) CPJE10, --出票金额10(预留
      CASE WHEN COUNT(*)=1 THEN to_char (MIN(rl.rlprdate),'yyyy-mm-dd') ELSE  NULL  END  ||  CHR(13)
       || CASE WHEN COUNT(*)=1 THEN to_char (MIN(rl.rldate),'yyyy-mm-dd') ELSE  NULL END  MEMO01, -- 备注1
       CASE WHEN COUNT(*)=1 THEN  MIN(FGETITEMDJ('01', rlid))   ELSE  NULL  END  ||  CHR(13) || CHR(13)
       || CASE WHEN COUNT(*)=1 THEN MIN(  FGETITEMDJ('02', rlid))  ELSE  NULL END  MEMO02, --备注1

       MAX(rl.rlmcode) MCODE, --客户号
       rl.rlentrustbatch, --托收批次
        MAX(fgetpboper) POPER , --打印员
       SYSDATE pdate,  --打印时间
       CASE WHEN COUNT(*)=1 THEN MIN(rlscode) ELSE NULL END  SCODE,-- 起码
       CASE WHEN COUNT(*)=1 THEN MIN(rlecode) ELSE NULL END ECODE,  --止码
      '' rlid,--应收id
       '' pid,--实收id
       SUM(rlsl) sl,--水量
       ''  month,
       to_char(sysdate,'yyyy.mm')  pmonth,--打票月份
        '托收合票' FPTYPE,
           'N'   REVERSEFLAG,  --冲正
          sum(rlje) kpje, --增值税
                 to_number( MIUIID)  MIUIID,
                 max(m.MIIFTAX) MIIFTAX
  FROM reclist rl,view_reclist_charge rd,view_meter_prop m
  WHERE rd.rdid= rl.rlid
  and rl.rlmid=m.MIID
  and f_getifprint(rlmid)<>'N'
 -- AND rl.rloutflag='Y'
  AND FGETIFPRINTFP('rlid', rlid) ='N'
   AND rlid in(select c1 from pbparmtemp )
group by m.MIUIID,rl.rlentrustbatch
;

