CREATE OR REPLACE PROCEDURE HRBZLS."SP_CHARGEINVSEARCHHP_NEW1" (o_base out tools.out_base) is
begin
  --新版发票(柜台缴费)
  open o_base for
    select max(rlmcode) C1, --资料号                  C1
           max(rlcname) C2, --户名                    C2
           max(rlcadr) C3, --用户地址                C3
           min(rlscode) C4, --抄表起码                C4
           max(rlecode) C5, --抄表止码                C5
           sum(decode(pdpiid, '01', pdsl, 0)) C6, --应收水量                C6
           to_char(SYSDATE, 'yyyy-mm-dd') C7, --打印日期                C7
           fGetOperName(MAX(c2)) C8, --打印员                  C8
           fGetOperName(max(ppayee)) C9, --收费员                  C9
           '币  ' || (case
             when max(PLCD) = 'DE' then
              tools.fuppernumber(sum(pdje) + sum(pdznj) + max(PLSAVINGBQ))
             else
              tools.fuppernumber((sum(pdje) + sum(pdznj) - max(PLSAVINGBQ)) * -1)
           end) C10, --合计金额大写            C10
           '￥' || (case
             when max(PLCD) = 'DE' then
              tools.fformatnum(sum(pdje) + sum(pdznj) + max(PLSAVINGBQ), 2)
             else
              tools.fformatnum((sum(pdje) + sum(pdznj) - max(PLSAVINGBQ)) * -1,
                               2)
           end) C11, --合计金额                C11
           --  '币  '|| tools.fuppernumber(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ))                  C10             ,--合计金额大写            C10
           -- '￥'||tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) ,2)                   C11             ,--合计金额                C11
           fGetPriceText_gtmx(plid) C12, --水费明细1               C12
           '' C13, --水费明细2               C13
           to_char(sysdate, 'yyyy') || '    ' || to_char(sysdate, 'mm') ||
           '    ' || to_char(sysdate, 'dd') || ' ' C14, --系统时间年              C14
           to_char(sysdate, 'mm') C15, --系统时间月              C15
           to_char(sysdate, 'dd') C16, --系统时间日              C16
           max(pbatch) C17, ----缴费交易批次,系统时间月           C17
           to_char(sysdate, 'yyyy') C18, ----实收帐明细流水号      C18
           '' C19, --销帐流水流水号          C19
           '' C20, --票务日期 /*票务日期*/   C20
           '暂无启用' C21, --水表编号                C21
           '抄表员：' C22, --用户编号                C22
           max(plrlmonth) C23, --应收账月份                  C23
           max(rlmadr) C24, --水表安装地址            C24
           max(RLBFID) C25, --表册号                  C25
           max(RLRPER) C26, --抄表员              C26
           to_char(max(RLDATE), 'yyyy-mm-dd') C27, --制据日期                C27
           fGetUnitPrice_mx(max(rlid), '01,02,03,04|', 4) C28, --应收单价                C28
           fGetUnitMoney_gtmx(plid) C29, --水费金额                C29
           '暂无启用' C30, --余量                    C30
           '' C31, --滞纳金                  C31
           '' C32, --手续费                  C32
           '' C33, --上期抄表日期    （本次交钱）        C33
           '上次余数:' || tools.fformatnum(max(PLSAVINGQC), 2) C34, --抄表日期  (上次结余)             C34
           '本次余数:' || tools.fformatnum(max(PLSAVINGQM), 2) C35, --账务日期 (本次结余)               C35
           '暂无启用' C36, --抄表月份                C36
           '应收现金 ' || fGetRecZnjMoney_gtmx(plid) 合计应收1, --合计应收1                            C37
           '现金' C38, --收费方式                C38
           '暂无启用' C39, --水费明细3               C39
           '' C40, --预存发生明细            C40
           '' C41, --应收金额大写           C41
          /* case
             when sum(RLADDSL) > 0 then
              '调表：' || '【余量为' || tools.fformatnum(max(RLADDSL), 0) || '】'
             when sum(RLECODE - RLSCODE) <> sum(RLREADSL) then
              '调表'
             else
              '正常抄表'
           end   */   ' 11111111'   C42, --备注           C42
           '应缴滞纳金:' || tools.fformatnum(max(PLRECZNJ), 2) C43, --应缴滞纳金3           C43
           '实缴滞纳金:' || tools.fformatnum(max(PLZNJ), 2) C44, --实缴滞纳金4           C44
           '应缴水费:' || tools.fformatnum(max(rlje), 2) C45, --应缴水费5           C45
           '实缴水费:' || tools.fformatnum(max(PLJE), 2) C46, --实缴水费6           C46
           case
             when max(plcd) = 'DE' then
              ''
             else
              '冲红票'
           end C47, --用户预留字段7           C47
           '' C48, --用户预留字段8           C48
           '' C49, --用户预留字段9           C49
           '' C50, --用户预留字段10          C50
           '' C51, --应收账流水号            C51
           '' C52, --费用项目                C52
           MAX(c2) C53, --打印员编号              C53
           '' C54, --收费员              C54
           '.' C55, --序号                    C55
           max(PCD) C56, --系统预留字段1           C56
           MAX(c3) C57, --系统预留字段2           C57
           '' C58, --系统预留字段3           C58
           '' C59, --系统预留字段4           C59
           '' C60 --系统预留字段5           C60
      from payment, paidlist, paiddetail, reclist, pbparmtemp
     where pid = plpid
       and plid = pdid
       and plrlid = rlid
       and plpid = C1
     group by plid, pid
    UNION

    select max(NVL(MIPRIID, pmcode)) C1, --资料号                  C1
           max(ciname) C2, --户名                    C2
           max(ciadr) C3, --用户地址                C3
           case
             when 0 = 0 then
              null
             else
              0
           end C4, --抄表起码                C4
           case
             when 0 = 0 then
              null
             else
              0
           end C5, --抄表止码                C5
           case
             when 0 = 0 then
              null
             else
              0
           end C6, --应收水量                C6
           to_char(SYSDATE, 'yyyy-mm-dd') C7, --打印日期                C7
           fGetOperName(MAX(c2)) C8, --打印员                  C8
           fGetOperName(max(ppayee)) C9, --收费员                  C9
           '币  ' || tools.fuppernumber(sum(decode(pcd, 'DE', 1, -1) *
                                           (ppayment - pchange))) C10, --合计金额大写            C10
           '￥' || tools.fformatnum(sum(decode(pcd, 'DE', 1, -1) *
                                       (ppayment - pchange)),
                                   2) C11, --合计金额                C11
           '' C12, --水费明细1               C12
           '' C13, --水费明细2               C13
           to_char(sysdate, 'yyyy') || '    ' || to_char(sysdate, 'mm') ||
           '    ' || to_char(sysdate, 'dd') || ' ' C14, --系统时间年              C14
           to_char(sysdate, 'mm') C15, --系统时间月              C15
           to_char(sysdate, 'dd') C16, --系统时间日              C16
           max(pbatch) C17, ----缴费交易批次          C17
           to_char(sysdate, 'yyyy') C18, ----实收帐明细流水号      C18
           '' C19, --销帐流水流水号          C19
           '' C20, --票务日期 /*票务日期*/   C20
           '暂无启用' C21, --水表编号                C21
           '抄表员：' C22, --用户编号                C22
           '' C23, --应收账月份                  C23
           '' C24, --水表安装地址            C24
           max(MIBFID) C25, --表册号                  C25
           '暂无启用' C26, --抄表次序号              C26
           '暂无启用' C27, --抄表水量                C27
           '' C28, --应收单价                C28
           '' C29, --应收金额                C29
           '暂无启用' C30, --余量                    C30
           '' C31, --滞纳金                  C31
           '' C32, --手续费                  C32
           '' C33, --上期抄表日期    （本次交钱）        C33 '上次结余 '||tools.fformatnum(max(PSAVINGQC),2)
           '合收预存' ||
           tools.fuppernumber(sum(decode(pcd, 'DE', 1, -1) *
                                  (ppayment - pchange))) C34, --抄表日期  (上次结余)  '本次结余 '||tools.fformatnum(max(PSAVINGQM),2)            C34
           '' C35, --账务日期 (本次结余)               C35
           '暂无启用' C36, --抄表月份                C36
           '' 合计应收1, --合计应收1                            C37
           '现金' C38, --收费方式                C38
           '暂无启用' C39, --水费明细3               C39
           '' C40, --预存发生明细            C40
           '' C41, --应收金额大写           C41
           '正常抄表' C42, --用户预留字段2           C42
           '' C43, --用户预留字段3           C43
           '' C44, --用户预留字段4           C44
           '' C45, --用户预留字段5           C45
           '' C46, --用户预留字段6           C46
           '' C47, --用户预留字段7           C47
           '' C48, --用户预留字段8           C48
           '' C49, --用户预留字段9           C49
           '' C50, --用户预留字段10          C50
           '' C51, --应收账流水号            C51
           '' C52, --费用项目                C52
           MAX(c2) C53, --打印员编号              C53
           '' C54, --收费员编号              C54
           '.' C55, --序号                    C55
           max(PCD) C56, --系统预留字段1           C56
           MAX(c3) C57, --系统预留字段2           C57
           '' C58, --系统预留字段3           C58
           '' C59, --系统预留字段4           C59
           MAX(PID) C60 --系统预留字段5           C60
      from payment, pbparmtemp, custinfo, METERINFO
     where pmid = miid
       and pcid = ciid
       and pid = C1
       and PTRANS = 'S'
     group by PBATCH
    HAVING sum(decode(pcd, 'DE', 1, -1) * (ppayment - pchange)) <> 0

     order by c55, c60;

end;
/

