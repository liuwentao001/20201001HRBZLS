CREATE OR REPLACE PROCEDURE HRBZLS."SP_CHARGEINVSEARCHHP_MISAING" (
                  o_base out tools.out_base) is
  begin
    --新版发票(柜台缴费)
    open o_base for
           select
            max(pmcode)                                                           C1              ,--资料号                  C1
            max(ciname )                                                           C2              ,--户名                    C2
            max(ciadr )                                                            C3              ,--用户地址                C3
            ''                                                           C4              ,--抄表起码                C4
            ''                                                           C5              ,--抄表止码                C5
            ''                                                           C6              ,--应收水量                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--打印日期                C7
            fGetOperName(MAX(c2))                                                   C8              ,--打印员                  C8
            fGetOperName(max(ppayee))                                          C9              ,--收费员                  C9
           '币  '||case when max(PCD)='DE' then tools.fuppernumber(sum(ppayment)-sum(pchange)) else tools.fuppernumber((sum(ppayment)-sum(pchange))*-1) end                     C10             ,--合计金额大写            C10
            '￥'||case when max(pcd)='DE' then tools.fformatnum(sum(ppayment)-sum(pchange) ,2) else tools.fformatnum((sum(ppayment)-sum(pchange))*-1 ,2)  end                   C11             ,--合计金额                C11
            ''                C12             ,--水费明细1               C12
            ''                 C13             ,--水费明细2               C13
            to_char(sysdate ,'yyyy') ||'    '||to_char(sysdate ,'mm')||'    '|| to_char(sysdate ,'dd')||' '                                       C14             ,--系统时间年              C14
            to_char(sysdate ,'mm')                                             C15             ,--系统时间月              C15
            to_char(sysdate ,'dd')                                             C16             ,--系统时间日              C16
            max(pbatch )                                                            C17             ,----缴费交易批次          C17
            ''                                                                C18             ,----实收帐明细流水号      C18
            ''                                                             C19             ,--销帐流水流水号          C19
            ''                 C20             ,--票务日期 /*票务日期*/   C20
            ''                                                         C21             ,--水表编号                C21
            '抄表员：'                                                         C22             ,--用户编号                C22
            ''                                                         C23             ,--应收账月份                  C23
            ''                                                         C24             ,--水表安装地址            C24
            ''                                                         C25             ,--表册号                  C25
            ''                                                         C26             ,--抄表次序号              C26
            ''                                                         C27             ,--抄表水量                C27
            ''                                                           C28             ,--应收单价                C28
            ''                                      C29             ,--应收金额                C29
            ''                                                         C30             ,--余量                    C30
            ''                                                       C31             ,--滞纳金                  C31
            ''                                                         C32             ,--手续费                  C32
            ''                                                        C33             ,--上期抄表日期    （本次交钱）        C33
            '上次结余 '||tools.fformatnum(max(PSAVINGQC),2)                                                        C34             ,--抄表日期  (上次结余)             C34
            '本次结余 '||tools.fformatnum(max(PSAVINGQM),2)                                                        C35             ,--账务日期 (本次结余)               C35
            ''                                                         C36             ,--抄表月份                C36
            ''                 合计应收1                                                  ,--合计应收1                            C37
            ''                                                         C38             ,--收费方式                C38
            ''                                                         C39             ,--水费明细3               C39
           ''                                                        C40             ,--预存发生明细            C40
           ''                                  C41             ,--应收金额大写           C41
           ''                                                         C42             ,--用户预留字段2           C42
            ''                                                       C43             ,--用户预留字段3           C43
            ''                                                         C44             ,--用户预留字段4           C44
            ''                                                         C45             ,--用户预留字段5           C45
            ''                                                         C46             ,--用户预留字段6           C46
            case when max(pcd)='DE' then '' else '冲红票' end                                                         C47             ,--用户预留字段7           C47
            ''                                                  C48             ,--用户预留字段8           C48
            ''                                                         C49             ,--用户预留字段9           C49
            ''                                                         C50             ,--用户预留字段10          C50
            ''                                                            C51             ,--应收账流水号            C51
            ''                            C52             ,--费用项目                C52
            MAX(c2)                                                                 C53             ,--打印员编号              C53
            ''                                                       C54             ,--收费员编号              C54
            '.'                                                                C55             ,--序号                    C55
            max(PCD )                                                               C56             ,--系统预留字段1           C56
            MAX(c3)                                                        C57             ,--系统预留字段2           C57
            ''                                                        C58             ,--系统预留字段3           C58
            ''                                                         C59             ,--系统预留字段4           C59
            ''                                                         C60              --系统预留字段5           C60
     from payment,  pbparmtemp,custinfo
   where
         pcid=ciid and
         pid = C1
         group by pid

order by c3 ,pid
    ;

  end ;
/

