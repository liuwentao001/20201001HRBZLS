CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_HPBYMID AS
select '' ID, --出票流水号
       '' ISID, --发票流水号
       '' ISPCISNO, --票据批次||号码
       '0' DYFS, --打印方式(0,正常，1. 补打，2.重打)
       0 PRINTNUM, --打印次数
       '0' STATUS, --状态(0，正常、1, 作废、2,红票、3,蓝票)
       max(P.PPAYWAY) FKFS, --付款类型(xj 现金,zp,支票 )
       'P' CPLX, --出票类型（p,实收出账,l，应收出账）
       'M' CPFS, --出票方式（合票、分票、预存票、存折，稽查,.......）
       ''  PPBATCH, --打印批次
       '' BATCH, --实收批次
       'Y' FLAG, --销账标志
       SUM(rlznj + rlje + rl.rlsavingbq) FKJE, --付款金额
       SUM(rlznj + rlje) XZJE, --销账金额
       SUM(rlznj) ZNJ, --滞纳金
       SUM(rlsxf) SXF, --手续费
       0 JMJE, --减免金额
       tools.fformatnum(substr( min(pbatch||'@'||pid ||'@'|| PSAVINGQC ),23),2)  QCSAVING, --上次结存  max(PSAVINGQC)
       to_number(substr( max(pbatch||'@'||pid ||'@'|| PSAVINGQM ),23))  QMSAVING, --本次结存   max(PSAVINGQM)
       to_number(substr( max(pbatch||'@'||pid ||'@'|| PSAVINGBQ ),23))  BQSAVING, --本期预存发生
      -- max(PSAVINGBQ) BQSAVING, --本期预存发生
       '' CZPER, --冲正人员
       '' CZDATE, --冲正日期
       '' JZDID, --进账单流水
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
       to_char(min(rl.rlprdate),'yyyy-mm-dd') ||  CHR(13)
       || to_char(max(rl.rlrdate),'yyyy-mm-dd')   MEMO01, -- 备注1
        ' 上期示数: ' || min(rl.rlscode)  || ' 本期示数: ' || max(rl.rlecode) ||
        ' 水量：' ||sum(rlsl) ||
        ' 水费：' || tools.fformatnum(SUM(rd.charge1),2) ||
        ' 污水费：' || tools.fformatnum(SUM(rd.charge2),2) ||  CHR(13) ||
        ' 计费期：' ||to_char(min(rl.rlprdate),'yyyy-mm-dd') || '至' || to_char(max(rl.rlrdate),'yyyy-mm-dd')
        MEMO02, --备注1
       max(P.Pmcode) MCODE, --客户号
           fgetpboper POPER , --打印员
       SYSDATE pdate,  --打印时间
       min(rl.rlscode)  SCODE,-- 起码
       max(rl.rlecode)  ECODE,  --止码
       SUM(rlsl)   sl,--水量
       max(rl.rlmonth)  MONTH,  --水费月份
       to_char(sysdate,'yyyy.mm')  pmonth,  --打票月份
        '柜台合打发票'  FPTYPE,
        max(PREVERSEFLAG)   REVERSEFLAG   --冲正
  FROM PAYMENT P,reclist rl,view_reclist_charge rd,view_meter_prop
  WHERE
   rlpid = pid and rd.rdid= rl.rlid
   and rlmid=miid
 and f_getifprint(rlmid)<>'N'
and rlpaidflag = 'Y'
AND rlid IN(
 SELECT c1 FROM pbparmtemp
)
GROUP BY pmid
;

