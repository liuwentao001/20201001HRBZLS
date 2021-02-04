CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_FP AS
SELECT '' ID, --出票流水号
       '' ISID, --发票流水号
       '' ISPCISNO, --票据批次||号码
       '0' DYFS, --打印方式(0,正常，1. 补打，2.重打
       0 PRINTNUM, --打印次数
       '0' STATUS, --状态(0，正常、1, 作废、2,红票、3,蓝票
       P.PPAYWAY FKFS, --付款类型(xj 现金,zp,支票
       'P' CPLX, --出票类型（p,实收出账,l，应收出账）
       'F' CPFS, --出票方式（合票、分票、预存票、存折，稽查,.......）
       PBATCH PPBATCH, --打印批次
       P.PBATCH BATCH, --实收批次
       'Y' FLAG, --销账标志
       P.PPAYMENT FKJE, --付款金额
       rl.rlje + rl.rlznj XZJE, --销账金额
       rlznj ZNJ, --滞纳金
       rlsxf SXF, --手续费
       0 JMJE, --减免金额
       rl.rlsavingqc QCSAVING, --上次结存
       rl.rlsavingqm QMSAVING, --本次结存
       rl.rlsavingbq BQSAVING, --本期预存发生
       '' CZPER, --冲正人员
       '' CZDATE, --冲正日期
       '' JZDID, --进账单流水
       ------------dj------------------
       rd.dj1   cpdj01,  ---出票单价1
       rd.dj1   cpdj02,  ---出票单价2
       rd.dj1   cpdj03,  ---出票单价3
       rd.dj1   cpdj04,  ---出票单价4
        rd.dj1   cpdj05,  ---出票单价5
        rd.dj1   cpdj06,  ---出票单价6
        rd.dj1   cpdj07,  ---出票单价7
        rd.dj1   cpdj018,  ---出票单价8
       ------------------------------
       --------------je-----------------
       rd.charge1 CPJE01, --出票金额1
       rd.charge2 CPJE02, --出票金额2
       rd.charge3 CPJE03, --出票金额3
       rd.charge4 CPJE04, --出票金额4
       rd.charge5 CPJE05, --出票金额5
       rd.charge_r1 CPJE06, --出票金额(阶梯1
       rd.charge_r2 CPJE07, --出票金额(阶梯2
       rd.charge_r3 CPJE08, --出票金额(阶梯3
       charge6 CPJE09, --出票金额6(预留
       charge7 CPJE10, --出票金额7(预留
       0 CPJE11,
        ------------------------------------------
       to_char(rl.rlprdate,'yyyy-mm-dd') ||  CHR(13)
       || to_char(rl.rlrdate,'yyyy-mm-dd')   MEMO01, -- 备注1
       fGetPriceText_水费(rlid) MEMO02, --备注1
       p.pmcode MCODE, --客户号
       fgetpboper POPER , --打印员
       SYSDATE pdate,  --打印时间
       rl.rlscode  SCODE,-- 起码
       rl.rlecode  ECODE,  --止码
       rl.rlsl     sl,--水量
       rl.rlmonth MONTH, --水费月份
       rl.rlid rlid,  --应收id
       rl.rlpid pid,  --实收id
       to_char(sysdate,'yyyy.mm') pmonth,  --打票月份
          '柜台水费发票'  FPTYPE,
        rlREVERSEFLAG   REVERSEFLAG  --冲正
  FROM PAYMENT P,reclist rl,view_reclist_charge rd
  WHERE
   rlpid = pid and rd.rdid= rl.rlid
and f_getifprint(rlmid)<>'N'
and rlpaidflag = 'Y'
;

