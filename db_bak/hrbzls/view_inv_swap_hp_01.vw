create or replace force view hrbzls.view_inv_swap_hp_01 as
select '' ID, --出票流水号
       '' ISID, --发票流水号
       '' ISPCISNO, --票据批次||号码
       '0' DYFS, --打印方式(0,正常，1. 补打，2.重打)
       0 PRINTNUM, --打印次数
       '0' STATUS, --状态(0，正常、1, 作废、2,红票、3,蓝票)
       max(P.PPAYWAY) FKFS, --付款类型(xj 现金,zp,支票 )
       'P' CPLX, --出票类型（p,实收出账,l，应收出账）
       'H' CPFS, --出票方式（合票、分票、预存票、存折，稽查,.......）
       PBATCH  PPBATCH, --打印批次
       P.PBATCH BATCH, --实收批次
       'Y' FLAG, --销账标志
       max(P.Pmcode) MCODE, --客户代码
       FGETOPERNAME(fgetpboper) POPER , --打印员
       SYSDATE pdate,  --打印时间
       max(rlcname) rlcname ,       --用户名称
       max(rlcadr) rlcadr,         --用户地址
       max(rd.dj) dj,          --总单价
       max(rd.dj1) dj1,         --单价1  水费
       max(rd.dj2) dj2,         --单价2  污水费
       max(rd.dj3) dj3,         --单价3  附加费
       max(rd.dj4) dj4,         --单价4
       max(rd.dj5) dj5,         --单价5
       max(rd.dj6) dj6,         --单价6
       max(rd.dj7) dj7,         --单价7
       max(rd.dj8) dj8,         --单价8
       max(rd.dj9) dj9,         --单价9
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
       SUM(rlznj) ZNJ,              --违约金
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
       max(P.PPAYMENT) FKJE, --付款金额
       SUM(rlznj + rlje) XZJE, --销账金额
       max(  decode(miiftax,
                  'N',
                  PSPJE,
                  CHARGE2 + CHARGE3 + CHARGE4 + CHARGE5 + CHARGE6 + CHARGE7)) kpje, --开票金额
       SUM(rlsxf) SXF, --手续费
       0 JMJE, --减免金额
       tools.fformatnum(substr( min(pbatch||'@'||pid ||'@'|| PSAVINGQC ),23),2)  QCSAVING, --上次结存  max(PSAVINGQC)
       to_number(substr( max(pbatch||'@'||pid ||'@'|| PSAVINGQM ),23))  QMSAVING, --本次结存   max(PSAVINGQM)
       to_number(substr( max(pbatch||'@'||pid ||'@'|| PSAVINGBQ ),23))  BQSAVING, --本期预存发生
       '' CZPER, --冲正人员
       '' CZDATE, --冲正日期
       '' JZDID, --进账单流水
       decode(max(mistatus),'29','-',to_number(substr( max(RLID||'@'|| RLECODE ),12))+floor((to_number(substr( max(pbatch||'@'||pid ||'@'|| PSAVINGQM ),23))/MAX(RD.dj)))) /*fgetrlecode(max(rlid))*/  yjbss,     --预计表示数
       decode(max(mistatus),'29','-',min(rl.rlscode))  SCODE,-- 起码
       decode(max(mistatus),'29','-',max(rl.rlecode))  ECODE,  --止码
       max(rl.rlmonth)  MONTH,  --水费月份
       to_char(sysdate,'yyyy.mm')  pmonth,  --打票月份
       '柜台合打发票'  FPTYPE,
       max(PREVERSEFLAG)   REVERSEFLAG,  --冲正
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch,'NY',3) MEMO01, -- 备注1年月
       decode(max(mistatus),'29','-',PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch,'BSS',3)) MEMO02, --备注2表示数
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch,'SL',3) MEMO03, --备注3水量
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch,'DJ',3) MEMO04, --备注4单价
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch,'SF',3) MEMO05, --备注5水费
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch,'WSF',3) MEMO06, --备注6污水处理费
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch,'WYJ',3) MEMO07, --备注7违约金
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch,'XJ',3) MEMO08, --备注8小计
       PG_EWIDE_INVMANAGE_01.fgethscode(MAX(p.Pmid)) MEMO09, --备注9合收户数
       floor(to_number(substr( max(pbatch||'@'||pid ||'@'|| PSAVINGQM ),23))/MAX(RD.dj)) MEMO10, --备注10预计可用水量
      /* pg_ewide_invmanage_01.fgetcltno(max(p.pmid)) MEMO11, --备注11水账标识号*/
       pg_ewide_invmanage_01.fgetnewcardno(max(p.pmid)) MEMO11, --备注11新账卡号
       decode(max(mistatus),'29','-',pg_ewide_invmanage_01.fgethsinvdeatil(max(p.pmid))) MEMO12, --备注12合收水表指针明细
       to_number(pg_ewide_invmanage_01.fgethsqmsaving(max(p.pmid))) MEMO13, --备注13合收主表预存余额
       floor(to_number(pg_ewide_invmanage_01.fgethsqmsaving(max(p.pmid)))/MAX(RD.dj)) MEMO14, --备注14合收表预计可用水量
       max(rlmemo)  MEMO15, --备注15获取单据中的原因备注
       pg_ewide_invmanage_01.FGETTRANSLATE(max(RLTRANS),max(RLINVMEMO)) MEMO16, --备注16打印交费项目即应收的发票备注
       '' MEMO17, --备注17
       '' MEMO18, --备注18
       '' MEMO19, --备注19
       '' MEMO20  --备注20
  FROM PAYMENT P,reclist rl,view_reclist_charge rd,view_meter_prop
  WHERE
   rlpid = pid and rd.rdid= rl.rlid
   and rlmid=miid
 and f_getifprint(rlmid)<>'N'
and rlpaidflag = 'Y'
 group BY p.pbatch
;

