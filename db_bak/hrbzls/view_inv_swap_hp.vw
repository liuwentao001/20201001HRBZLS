CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_HP AS
SELECT '' ID, --出票流水号
       '' ISID, --发票流水号
       '' ISPCISNO, --票据批次||号码
       '0' DYFS, --打印方式(0,正常，1. 补打，2.重打)
       0 PRINTNUM, --打印次数
       '0' STATUS, --状态(0，正常、1, 作废、2,红票、3,蓝票)
       MAX(P.PPAYWAY) FKFS, --付款类型(XJ 现金,ZP,支票 )
       'P' CPLX, --出票类型（P,实收出账,L，应收出账）
       'H' CPFS, --出票方式（合票、分票、预存票、存折，稽查,.......）
       PBATCH PPBATCH, --打印批次
       P.PBATCH BATCH, --实收批次
       'Y' FLAG, --销账标志
       MAX(P.PPRIID) MCODE, --客户代码
       FGETOPERNAME(FGETPBOPER) POPER, --打印员
       SYSDATE PDATE, --打印时间
       DECODE(FGETIFBJZY(MAX(P.PPRIID)),'Y',MAX(RLCNAME),MAX(MINAME)) RLCNAME, --用户名称
       DECODE(FGETIFBJZY(MAX(P.PPRIID)),'Y',MAX(RLCADR),MAX(MIADR)) RLCADR, --用户地址
       MAX(T.DJ) DJ, --总单价
       MAX(T.DJ1) DJ1, --单价1  水费
       --MAX(T.DJ2) DJ2, --单价2  污水费
       fgetsjwsf(max(mipfid),MAX(P.PPRIID)) dj2,  --  单价污水费   2016.10.18  WLJ   处理污水加价费加入到单价计算中
       MAX(T.DJ3) DJ3, --单价3  附加费
       MAX(T.DJ4) DJ4, --单价4
       MAX(T.DJ5) DJ5, --单价5
       MAX(T.DJ6) DJ6, --单价6
       MAX(T.DJ7) DJ7, --单价7
       MAX(T.DJ1) DJ8,         --单价8
       fgetwsf(max(mipfid)) DJ9,         --单价9
       --FGETSF(MAX(RLPFID)) DJ8, --借用存用户当前净水价
       --FGETWSF(MAX(RLPFID)) DJ9, --借用存用户当前污水价
       DECODE(max(MIIFTAX),'N',SUM(NVL(RLSL, 0)),(MAX(DECODE(PMID, PPRIID, P.PPAYMENT, 0))/(MAX(T.DJ1)+fgetsjwsf(max(mipfid),MAX(P.PPRIID)))  ) ) SL, --水量 2016.10.18  WLJ   处理污水加价费加入到单价计算中
       SUM(T.CHARGE1) CPJE01, --出票金额1
       SUM(T.CHARGE2) CPJE02, --出票金额2
       SUM(T.CHARGE3) CPJE03, --出票金额3
       SUM(T.CHARGE4) CPJE04, --出票金额4
       SUM(T.CHARGE5) CPJE05, --出票金额5
       SUM(T.CHARGE_R1) CPJE06, --出票金额5(阶梯1
       SUM(T.CHARGE_R2) CPJE07, --出票金额5(阶梯2
       SUM(T.CHARGE_R3) CPJE08, --出票金额5(阶梯3
       SUM(T.CHARGE6) CPJE09, --出票金额6
       SUM(T.CHARGE7) CPJE10, --出票金额7
       SUM(NVL(RLZNJ, 0)) ZNJ, --违约金
       SUM(T.CHARGE1 + T.CHARGE2 + T.CHARGE3 + T.CHARGE4 + T.CHARGE5 +
           /*T.CHARGE_R1 + T.CHARGE_R2 + T.CHARGE_R3 +*/ T.CHARGE6 + T.CHARGE7 +
           NVL(RLZNJ, 0)) YSHJ, --应收合计
       MAX(DECODE(PMID, PPRIID, P.PPAYMENT, 0)) FKJE, --付款金额
       SUM(NVL(RLZNJ, 0) + NVL(RLJE, 0)) XZJE, --销账金额
       sum(DECODE(MIIFTAX, 'N', PSPJE, CHARGE2)) KPJE, --开票金额
       SUM(NVL(RLSXF, 0)) SXF, --手续费
       0 JMJE, --减免金额
       TO_NUMBER(FGETPSAVING(PBATCH, 'QC')) QCSAVING, --上次结存
       SUM(PSAVINGBQ) BQSAVING, --本期预存发生
       TO_NUMBER(FGETPSAVING(PBATCH, 'QM')) QMSAVING, --本次结存
       /*TO_NUMBER(TOOLS.FFORMATNUM(SUBSTR(MIN(PBATCH || '@' || PID || '@' ||
                                             PSAVINGQC),
                                         23),
                                  2)) QCSAVING, --上次结存  MAX(PSAVINGQC)
       TO_NUMBER(SUBSTR(MAX(PBATCH || '@' || PID || '@' || PSAVINGQM), 23)) QMSAVING, --本次结存   MAX(PSAVINGQM)
       TO_NUMBER(SUBSTR(MAX(PBATCH || '@' || PID || '@' || PSAVINGBQ), 23)) BQSAVING, --本期预存发生*/
       PG_EWIDE_INVMANAGE_01.fgetinvmemo(max(rlid),'bfpper') CZPER, --冲正人员
       '' CZDATE, --冲正日期
       FGETOPERNAME(max(cby)) JZDID, --进账单流水  //2017.09.18 改为发票核对人
       (CASE
         WHEN PG_EWIDE_INVMANAGE_01.FGETMETERSTATUS(MAX(T.RLMID)) = 'N' AND FGETIFDZSB(MAX(T.RLMID))='N' THEN
          TO_NUMBER(SUBSTR(MAX(RLID || '@' || RLECODE), 12)) +
          FLOOR((TO_NUMBER(SUBSTR(MAX(PBATCH || '@' || PID || '@' ||
                                      PSAVINGQM),
                                  23)) / (fun_getjtdqdj(max(WATERTYPE),max(MIPRIID),max(miid),'1') + fgetwsf(max(mipfid)))))
       END) /*FGETRLECODE(MAX(RLID))*/ YJBSS, --预计表示数
       MIN(decode(FGETIFDZSB(T.RLMID),'Y','-',DECODE(PG_EWIDE_INVMANAGE_01.FGETMETERSTATUS(T.RLMID),
                  'Y',
                  '-',
                  T.RLSCODE))) SCODE, -- 起码
       MAX(decode(FGETIFDZSB(T.RLMID),'Y','-',DECODE(PG_EWIDE_INVMANAGE_01.FGETMETERSTATUS(T.RLMID),
                  'Y',
                  '-',
                  T.RLECODE))) ECODE, --止码
       MAX(T.RLMONTH) MONTH, --水费月份
       TO_CHAR(SYSDATE, 'YYYY.MM') PMONTH, --打票月份
       '柜台合打发票' FPTYPE,
       MAX(PREVERSEFLAG) REVERSEFLAG, --冲正
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'NY', 6) MEMO01, -- 备注1年月
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'BSS', 6) MEMO02, --备注2表示数
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'SL', 6) MEMO03, --备注3水量
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'DJ', 6) MEMO04, --备注4单价
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'SF', 6) MEMO05, --备注5水费
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'WSF', 6) MEMO06, --备注6污水处理费
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'WYJ', 6) MEMO07, --备注7违约金
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'XJ', 6) MEMO08, --备注8小计
       PG_EWIDE_INVMANAGE_01.FGETHSCODE(MAX(P.PMID)) MEMO09, --备注9合收户数
       FLOOR(TO_NUMBER(SUBSTR(MAX(PBATCH || '@' || PID || '@' || PSAVINGQM),
                              23)) / MAX(T.DJ)) MEMO10, --备注10预计可用水量
       /* PG_EWIDE_INVMANAGE_01.FGETCLTNO(MAX(P.PMID)) MEMO11, --备注11水账标识号*/
       PG_EWIDE_INVMANAGE_01.FGETNEWCARDNO(MAX(P.PMCODE)) MEMO11, --备注11新账卡号
       PG_EWIDE_INVMANAGE_01.FGETHSINVDEATIL(MAX(P.PMCODE)) MEMO12, --备注12合收水表指针明细
       TOOLS.FFORMATNUM(TO_NUMBER(PG_EWIDE_INVMANAGE_01.FGETHSQMSAVING(MAX(P.PMCODE))),2) MEMO13, --备注13合收主表预存余额
       (CASE
         WHEN FGET_CBJ_REC(MAX(P.PMCODE), 'QF') >= 0 THEN
          TO_CHAR(FLOOR(TO_NUMBER(PG_EWIDE_INVMANAGE_01.FGETHSQMSAVING(MAX(P.PMCODE))) /
                        (fun_getjtdqdj(max(WATERTYPE),max(MIPRIID),max(miid),'1') + fgetwsf(max(mipfid))) ))
         ELSE
          '-'
       END) MEMO14, --备注14合收表预计可用水量
       fun_getjtdqdj(max(WATERTYPE),max(MIPRIID),max(miid),'2')  MEMO15, --备注15获取单据中的原因备注
       PG_EWIDE_INVMANAGE_01.FGETTRANSLATE(MAX(RLTRANS), MAX(RLINVMEMO)) MEMO16, --备注16打印交费项目即应收的发票备注
       --FGETSMFNAME(MAX(PPOSITION)) MEMO17, --备注17 缴费机构（开票单位）
       FGETOPERNAME(max(FGETPBOPER)) MEMO17, --备注17 2017.09.18 缴费机构变成与打印员一样
       TO_CHAR(FGET_CBJ_REC(MAX(P.PMID), 'WJSSF')) MEMO18, --未结算水费（纯欠费）
       (CASE
         WHEN PG_EWIDE_INVMANAGE_01.FGETMETERSTATUS(MAX(T.RLMID)) = 'Y' OR FGETIFDZSB(MAX(T.RLMID))='Y' THEN
          '-'
         WHEN FGET_CBJ_REC(MAX(T.RLMID), 'QF') >= 0 THEN
/*          TO_CHAR(TO_NUMBER(SUBSTR(MAX(RLID || '@' || RLECODE), 12)) +
                  FLOOR((TO_NUMBER(SUBSTR(MAX(PBATCH || '@' || PID || '@' ||
                                              PSAVINGQM),
                                          23)) / MAX(T.DJ))))*/
         --预计表示数抓取meterinfo当期读数 、预存及单价
          TO_CHAR(TO_NUMBER( MAX( VIEW_METER_PROP.MIRCODE) ) +
                  FLOOR((TO_NUMBER( MAX(VIEW_METER_PROP.MISAVING) ) / (fun_getjtdqdj(max(WATERTYPE),max(MIPRIID),max(miid),'1')+ fgetwsf(max(mipfid))))))

         ELSE
          '-'
       END) MEMO19, --备注19  预计表示数

        PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'JT', 6)  MEMO20 --备注20
  FROM PAYMENT P,
       (SELECT *
          FROM RECLIST RL, VIEW_RECLIST_CHARGE RD
         WHERE RD.RDID = RL.RLID) T,
       VIEW_METER_PROP
 WHERE PID = T. RLPID(+)
   AND PPRIID = MIID
   AND F_GETIFPRINT(PMID) <> 'N'
   AND PREVERSEFLAG = 'N'
   AND ptrans <> 'K' --预存抵扣不需要打印发票 20150410 hb 因合收表3088575144打印出来交费金额为预存抵扣的金额
 GROUP BY P.PBATCH
;

