CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_YC AS
SELECT '' ID, --出票流水号
       '' ISID, --发票流水号
       '' ISPCISNO, --票据批次||号码
       '0' DYFS, --打印方式(0,正常，1. 补打，2.重打)
       0 PRINTNUM, --打印次数
       '0' STATUS, --状态(0，正常、1, 作废、2,红票、3,蓝票)
       P.PPAYWAY FKFS, --付款类型(xj 现金,zp,支票 )
       'P' CPLX, --出票类型（p,实收出账,l，应收出账）
       'YC' CPFS, --出票方式（合票、分票、预存票、存折，稽查,.......）
       P.PBATCH PPBATCH, --打印批次
       P.PBATCH BATCH, --实收批次
       'Y' FLAG, --销账标志
      abs( P.PPAYMENT) FKJE, --付款金额
       PSPJE XZJE, --销账金额
       PZNJ ZNJ, --滞纳金
       PSXF SXF, --手续费
       0 JMJE, --减免金额
       PSAVINGQC QCSAVING, --上次结存
       PSAVINGQM QMSAVING, --本次结存
       PSAVINGBQ BQSAVING, --本期预存发生
       '' CZPER, --冲正人员
       '' CZDATE, --冲正日期
       (select max(fgetopername(bfrper)) from bookframe where bfid =mi.mibfid ) JZDID, --进账单流水//2017.09.18 改为核对人
       0 CPJE01, --出票金额1
       0 CPJE02, --出票金额2
       0 CPJE03, --出票金额3
       0 CPJE04, --出票金额4
       0 CPJE05, --出票金额5(阶梯0
       0 CPJE06, --出票金额5(阶梯1
       0 CPJE07, --出票金额5(阶梯2
       0 CPJE08, --出票金额5(阶梯3
       0 CPJE09, --出票金额9(预留)
       0 CPJE10, --出票金额10(预留)
       fgetzhdj(mipfid) dj, --单价
       fgetsf(mipfid) dj1, --单价水费
       --fgetwsf(mipfid) dj2, -- 单价污水费
       fgetsjwsf((mipfid),(miid)) dj2,  --  单价污水费   2016.08.01  WLJ   处理污水加价费加入到单价计算中
       (case
         when FGET_CBJ_REC(p.pmid, 'QF') >= 0 then
          to_char(floor(FGET_CBJ_REC(p.pmid, 'QF') / fgetzhdj(mipfid)))
         else
          '-'
       end) MEMO14, --预计可用水量
       --to_char(floor(to_number(pg_ewide_invmanage_01.fgethsqmsaving(p.pmid))/fgetzhdj(mipfid))) MEMO14,
       TOOLS.FFORMATNUM(to_number(pg_ewide_invmanage_01.fgethsqmsaving(p.pmid)),2) MEMO13,
       to_char(pg_ewide_invmanage_01.fgethsinvdeatil(p.pmid)) MEMO12, --合收水表指针明细
       to_char(FGET_CBJ_REC(p.pmid, 'WJSSF')) MEMO15, --未结算水费（纯欠费）
       '' MEMO16,--20151222
       fgetopername(fgetpboper) MEMO17, --备注17  //2017.09.18 缴费机构改为与打印员一样
        --FGETSMFNAME(pposition) MEMO17, --备注17 缴费机构（开票单位）
      -- 'cc' MEMO17, --备注17 缴费机构（开票单位）
       fun_getjtdqdj(mipfid,MIPRIID,miid,'2') MEMO18, -- 备注18 阶梯水价单价
       (case
         when pg_ewide_invmanage_01.fgetmeterstatus(p.pmid) = 'Y' OR FGETIFDZSB(p.pmid)='Y' then
          '-'
         when FGET_CBJ_REC(p.pmid, 'QF') >= 0 then
          to_char(MI.MIRCODE +
                  trunc(FGET_CBJ_REC(p.pmid, 'QF') / (fun_getjtdqdj(mipfid,MIPRIID,miid,'1')+fgetwsf(mipfid))))
         else
          '-'
       end) MEMO19,-- 备注19 阶梯水价预计表示数
       (case
         when FGET_CBJ_REC(p.pmid, 'QF') >= 0 then
          to_char(floor(FGET_CBJ_REC(p.pmid, 'QF') / (fun_getjtdqdj(mipfid,MIPRIID,miid,'1')+fgetwsf(mipfid))))
         else
          '-'
       end) MEMO20,--备注20 阶梯水价多表预计表示数
       (case
         when pg_ewide_invmanage_01.fgetmeterstatus(p.pmid) = 'Y' OR FGETIFDZSB(p.pmid)='Y' then
          '-'
         when FGET_CBJ_REC(p.pmid, 'QF') >= 0 then
          to_char(MI.MIRCODE +
                  trunc(FGET_CBJ_REC(p.pmid, 'QF') / fgetzhdj(mipfid)))
         else
          '-'
       end) MEMO01, -- 备注1
       --decode(pg_ewide_invmanage_01.fgetmeterstatus(p.pmid),'Y','-',(MI.MIRCODE+trunc(PSAVINGQM/nvl(fGetdjhj(pmid),1)))) MEMO01, -- 备注1
       --to_char(PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch,'BSS',3)) MEMO02, --备注2表示数
       to_char(decode(FGETIFDZSB(p.pmid),'Y','-',decode(pg_ewide_invmanage_01.fgetmeterstatus(p.pmid),
                      'Y',
                      '-',
                      mi.mircode))) MEMO02, --当前表示数
       PG_EWIDE_INVMANAGE_01.fgethscode(p.pmid) MEMO09, --备注9合收户数
       mi.miadr rlcadr,
       mi.miname rlcname,
       p.pmcode MCODE, --客户号
       fgetpboper POPER, --打印员
       SYSDATE pdate, --打印时间
       0 SCODE, -- 起码
       0 ECODE, --止码
       p.pmonth MONTH, --水费月份
       --abs( P.PPAYMENT)/fgetzhdj(mipfid) SL, --水量
       abs( P.PPAYMENT)/fgetsjzhdj((mipfid),(miid)) SL, --水量     --2016.08.01 WLJ  处理污水加价费加入到单价计算中
       to_char(sysdate, 'yyyy.mm') pmonth, --打票月份
      -- '柜台预存发票' FPTYPE,

   (  case  when P.PPAYMENT > 0 then
         '柜台预存发票'
          when mi.miyl8 = 1 then
              '预存退费'
          when mi.miyl8 = 2 then
             '撤表退费'
           end  ) FPTYPE,
       PREVERSEFLAG REVERSEFLAG, --冲正
       PPAYMENT kpje
  FROM PAYMENT P, meterinfo mi
 WHERE p.pmid = mi.miid
   and (P.PTRANS = 'S' or p.PSCRTRANS = 'S' OR P.PTRANS = 'V' or p.PSCRTRANS = 'V' OR P.PTRANS = 'Y' or p.PSCRTRANS = 'Y')
 order by pid
;

