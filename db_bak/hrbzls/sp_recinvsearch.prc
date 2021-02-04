CREATE OR REPLACE PROCEDURE HRBZLS."SP_RECINVSEARCH" (
                  o_base out tools.out_base) is
  begin
    open o_base for
      SELECT
           MAX(rlmid) 水表编号                                                                        ,--水表编号                   C1
            MAX(rlmcode) 客户代码                                                                      ,--资料号                     C2
            MAX(rlcid) 用户编号                                                                        ,--用户编号                   C3
            max(RLCCODE) 用户号                                                                      ,--用户号                       C4
            MAX(RLCNAME) 用户名                                                                     ,--户名                          C5
            MAX(RLCADR) 用户地址                                                                       ,--用户地址                   C6
            MAX(RLMADR)    水表地址                                                                    ,--水表安装地址               C7
            MAX(RLBFID ) 水价编号                                                                      ,--表册号                     C8
            '暂无启用'   抄表次序号                                                                ,--抄表次序号                     C9
            MAX(rlscode) 抄表起码                                                                      ,--抄表起码                   C10
            MAX(rlecode) 抄表止码                                                                      ,--抄表止码                   C11
            MAX(RLREADSL ) 抄表水量                                                                    ,--抄表水量                   C12
            MAX(RLSL ) 应收水量                                                                         ,--应收水量       C13
            fGetUnitPrice(rlid)  应收单价         ,--应收单价                    C14
            fGetUnitMoney(rlid)                          应收金额                           ,--应收金额                    C15
            max(RLADDSL) 余量                                                                      ,--余量                           C16
            '暂无启用'        滞纳金                                                           ,--滞纳金                             C17
            '暂无启用'        手续费                                                           ,--手续费                             C18
            to_char(max(RLPRDATE),'yyyy-mm-dd'  )          上期抄表日期                                   ,--上期抄表日期            C19
            to_char(max(RLRDATE),'yyyy-mm-dd'  )          抄表日期                                    ,--抄表日期                    C20
            to_char(max(RLDATE),'yyyy-mm-dd'  )           账务日期                                    ,--账务日期                    C21
            '暂无启用'                        抄表月份                                           ,--抄表月份                         C22
            max(RLMONTH)     账务月份                                                                  ,--账务月份                   C23
            to_char(SYSDATE,'yyyy-mm-dd'  )              打印日期                                ,--打印日期                         C24
            fGetOperName(max(c8))                            打印员                                 ,--打印员                        C25
            fGetOperName(max(RLCHARGEPER))                收费员                                    ,--收费员                        C26
            '币  '||tools.fuppernumber(to_number(fGetRecZnjMoney(rlid)))             合计金额大写                               ,--合计金额大写             C27
            '￥'||fGetRecZnjMoney(rlid)                      合计金额2                               ,--合计金额2              C28
            FGETSYSCHARGETYPE(max(RLYSCHARGETYPE)) 收费方式                             ,--收费方式                 c89              C29
            fGetPriceText(rlid) 水费明细1                             ,--水费明细1                       C30
            'pg_recinv.getinvdetail(rlid,''2'',''ALLPI'')'  水费明细2                            ,--水费明细2                        C31
            '暂无启用'          水费明细3                                                          ,--水费明细3                      C32
            '暂无启用'          预存发生明细                                                         ,--预存发生明细                 C33
            to_char(sysdate ,'yyyy') 系统时间年                                               ,--系统时间年                          C34
            to_char(sysdate ,'mm') 系统时间月                                                  ,--系统时间月                         C35
            to_char(sysdate ,'dd') 系统时间日                                                  ,--系统时间日                         C36
            '应收现金 '||fGetRecZnjMoney(rlid)                 合计应收1                                                  ,--合计应收1                            C37
            '暂无启用'                                                                   ,--用户预留字段5                            C38
            '暂无启用'                                                                   ,--用户预留字段6                            C39
            '暂无启用'                                                                   ,--用户预留字段7                            C40
            '暂无启用'                                                                   ,--用户预留字段8                            C41
            '暂无启用'                                                                   ,--用户预留字段9                            C42
            '暂无启用'                                                                   ,--用户预留字段10                           C43
            '暂无启用'                                                                   ,--用户预留字段11                           C44
            '暂无启用'                                                                   ,--用户预留字段12                           C45
            '暂无启用'                                                                   ,--用户预留字段13                           C46
            '暂无启用'                                                                   ,--用户预留字段14                           C47
            '暂无启用'                                                                   ,--用户预留字段15                           C48
            '暂无启用'                                                                   ,--用户预留字段16                           C49
            '暂无启用'                                                                   ,--用户预留字段17                           C50
            RLID                                                                         ,--应收账流水号                             C51
            '费用项目' 费用项目                                             ,--费用项目                                              C52
            max(c8)                                                                           ,--打印员编号                          C53
            max(RLCHARGEPER) 收费员编号                                                                 ,--收费员编号                C54
            max(c9) 序号                                                                           ,--序号                           C55
            '暂无启用'                                                                   ,--系统预留字段6                            C56
            '暂无启用'                                                                   ,--系统预留字段7                            C57
            '暂无启用'                                                                   ,--系统预留字段8                            C58
            '暂无启用'                                                                   ,--系统预留字段9                            C59
            '暂无启用'                                                                   --系统预留字段10                            C60
       from reclist, recdetail ,pbparmtemp
  WHERE RLID=RDID
  and rlid=c1
  and instr(c5 , rdpiid ) >0
  --AND RLID='0000107301'
  GROUP BY RLID
order by max(c9)
    ;

  end ;
/

