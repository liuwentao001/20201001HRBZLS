CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_TF AS
SELECT '' ID, --出票流水号
       '' ISID, --发票流水号
       '' ISPCISNO, --票据批次||号码
       '0' DYFS, --打印方式(0,正常，1. 补打，2.重打
       0 PRINTNUM, --打印次数
       '0' STATUS, --状态(0，正常、1, 作废、2,红票、3,蓝票
       '' FKFS, --付款类型(xj 现金,zp,支票
       'P' CPLX, --出票类型（p,实收出账,l，应收出账）
       'F' CPFS, --出票方式（合票、分票、预存票、存折，稽查,.......）
       ppbatch  PPBATCH, --打印批次
       '' BATCH, --实收批次
       'Y' FLAG, --销账标志
       减退金额  FKJE, --减退金额
       '' XZJE, --销账金额
       减退滞纳金  ZNJ, --减退滞纳金
       '' SXF, --手续费
       0 JMJE, --减免金额
       rl.rlsavingqc QCSAVING, --上次结存
       rl.rlsavingqm QMSAVING, --本次结存
       rl.rlsavingbq BQSAVING, --本期预存发生
       '' CZPER, --冲正人员
       '' CZDATE, --冲正日期
       '' JZDID, --进账单流水
       rd.减退金额1  CPJE01, --出票金额1
       rd.减退金额2  CPJE02, --出票金额2
       rd.减退金额3  CPJE03, --出票金额3
       rd.减退金额4  CPJE04, --出票金额4
       rd.减退金额5  CPJE05, --出票金额5
       '' CPJE06, --出票金额(阶梯1
       '' CPJE07, --出票金额(阶梯2
       '' CPJE08, --出票金额(阶梯3
       减退金额6  CPJE09, --出票金额6(预留
       减退金额7  CPJE10, --出票金额7(预留
       0 CPJE11,
       fgetrectrans(rltrans)   MEMO01, -- 备注1
       fGetPriceText_水费(rlid) MEMO02, --备注1
       资料号  MCODE, --客户号
       fgetpboper POPER , --打印员
       SYSDATE pdate,  --打印时间
       rl.rlscode  SCODE,-- 起码
       rl.rlecode  ECODE,  --止码
       rl.rlmonth MONTH, --水费月份
       rl.rlid rlid,  --应收id
       rl.rlpid pid,  --实收id
       to_char(sysdate,'yyyy.mm') pmonth,  --打票月份
          '柜台水费发票'  FPTYPE,
        rlREVERSEFLAG   REVERSEFLAG  --冲正
  FROM reclist rl,VIEW_INV_SWAP_TS rd
  WHERE
 rd.应收流水 = rl.rlid
 and f_getifprint(rlmid)<>'N'
and  rd.审核标志='Y'
;

