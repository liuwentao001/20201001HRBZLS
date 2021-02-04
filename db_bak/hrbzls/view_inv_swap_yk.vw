CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_YK AS
SELECT '' ID, --出票流水号
       '' ISID, --发票流水号
       '' ISPCISNO, --票据批次||号码
       '0' DYFS, --打印方式(0,正常，1. 补打，2.重打
       0 PRINTNUM, --打印次数
       '0' STATUS, --状态(0，正常、1, 作废、2,红票、3,蓝票
       '' FKFS, --付款类型(xj 现金,zp,支票
       'L' CPLX, --出票类型（p,实收出账,l，应收出账）
       'YK' CPFS, --出票方式（合票、分票、预存票、存折，稽查,.......）
       rl.rlmicolumn2  PPBATCH, --打印批次
       ''  BATCH, --实收批次
       rl.rlpaidflag FLAG, --销账标志
       rl.rlje FKJE, --付款金额
       rl.rlje XZJE, --销账金额
       PG_EWIDE_PAY_01.getznjadj(rlid,rlje,rlgroup,rl.rlzndate,RLSMFID,trunc(sysdate))  ZNJ, --滞纳金
       rl.rlsxf SXF, --手续费
       0 JMJE, --减免金额
       rlSAVINGQC QCSAVING, --上次结存
       rlSAVINGQM QMSAVING, --本次结存
       rlSAVINGBQ BQSAVING, --本期预存发生
       '' CZPER, --冲正人员
       '' CZDATE, --冲正日期
       '' JZDID, --进账单流水
       rd.charge1 CPJE01, --出票金额1
       rd.charge2 CPJE02, --出票金额2
       rd.charge3 CPJE03, --出票金额3
       rd.charge4 CPJE04, --出票金额4
       charge5 CPJE05, --出票金额5
       rd.charge_r1 CPJE06, --出票金额5(阶梯1
       rd.charge_r2 CPJE07, --出票金额5(阶梯2
       rd.charge_r3 CPJE08, --出票金额5(阶梯3
       charge6 CPJE09, --出票金额7(预留
       charge7 CPJE10, --出票金额10(预留
              to_char(rl.rlprdate,'yyyy-mm-dd') ||  CHR(13)
       || to_char(rl.rlrdate,'yyyy-mm-dd')    MEMO01, -- 备注1
       '' MEMO02, --备注1
       rl.rlmcode MCODE, --客户号
       rl.rlentrustbatch, --托收批次
       rl.rlentrustseqno, --托收
        fgetpboper POPER , --打印员
       SYSDATE pdate,  --打印时间
       rl.rlscode  SCODE,-- 起码
       rl.rlecode  ECODE,  --止码
       rl.rlid rlid,--应收id
       rl.rlpid pid,--实收id
       rlsl  sl,--水量
       rl.rlmonth month,
       to_char(sysdate,'yyyy.mm')  pmonth,--打票月份
       ( case when m.CHARGETYPE in('M','X') then '走收发票'
              when m.CHARGETYPE ='T' then '托收发票'
              when m.CHARGETYPE ='D' then '代扣发票'
              else '未知发票类型'
         end   )  FPTYPE,
           rlREVERSEFLAG   REVERSEFLAG,  --冲正
          decode(miiftax,
                  'N',
                  rlje,
                  CHARGE2 + CHARGE3 + CHARGE4 + CHARGE5 + CHARGE6 + CHARGE7) kpje --增值税
  FROM reclist rl,view_reclist_charge rd,view_meter_prop m
  WHERE rd.rdid= rl.rlid
  and rl.rlmid=m.MIID
 and f_getifprint(rlmid)<>'N'
AND rl.rloutflag='Y'
AND rlid IN(SELECT c1 FROM pbparmtemp)
;

