CREATE OR REPLACE FUNCTION HRBZLS."FCHARGEINVSEARCHHP_MX_OCX_2" (p_batch in varchar2,p_modelno in varchar2) return clob  is
 v_invprintstr clob;
--v_invprintstr varchar2(32767);
  begin
select  trim(to_char(lengthb( constructhd||constructdt ),'0000000000'))||
        trim(to_char(lengthb( contentstrorder||contentstr ),'0000000000'))||
        constructhd||
        constructdt||
        contentstrorder||
        contentstr into v_invprintstr
          from

   ( select
replace(
connstr(
  trim(c1  )||'^'
||trim(c2  )||'^'
||trim(c3  )||'^'
||trim(c4  )||'^'
||trim(c5  )||'^'
||trim(c6  )||'^'
||trim(c7  )||'^'
||trim(c8  )||'^'
||trim(c9  )||'^'
||trim(c10 )||'^'
||trim(c11 )||'^'
||trim(c12 )||'^'
||trim(c13 )||'^'
||trim(c14 )||'^'
||trim(c15 )||'^'
||trim(c16 )||'^'
||trim(c17 )||'^'
||trim(c18 )||'^'
||trim(c19 )||'^'
||trim(c20 )||'^'
||trim(c21 )||'^'
||trim(c22 )||'^'
||trim(c23 )||'^'
||trim(c24 )||'^'
||trim(c25 )||'^'
||trim(c26 )||'^'
||trim(c27 )||'^'
||trim(c28 )||'^'
||trim(c29 )||'^'
||trim(c30 )||'^'
||trim(c31 )||'^'
||trim(c32 )||'^'
||trim(c33 )||'^'
||trim(c34 )||'^'
||trim(c35 )||'^'
||trim(c36 )||'^'
||trim(c37 )||'^'
||trim(c38 )||'^'
||trim(c39 )||'^'
||trim(c40 )||'^'
||trim(c41 )||'^'
||trim(c42 )||'^'
||trim(c43 )||'^'
||trim(c44 )||'^'
||trim(c45 )||'^'
||trim(c46 )||'^'
||trim(c47 )||'^'
||trim(c48 )||'^'
||trim(c49 )||'^'
||trim(c50 )||'^'
||trim(c51 )||'^'
||trim(c52 )||'^'
||trim(c53 )||'^'
||trim(c54 )||'^'
||trim(c55 )||'^'
||trim(c56 )||'^'
||trim(c57 )||'^'
||trim(c58 )||'^'
||trim(c59 )||'^'
||trim(c60 )
||'|' )
,'|/','|') contentstr
from
(

            select
            max(rlmcode)                                                           C1              ,--资料号                  C1
            max(rlcname )                                                           C2              ,--户名                    C2
            max(rlcadr )                                                            C3              ,--用户地址                C3
            min(rlscode )                                                           C4              ,--抄表起码                C4
            max(rlecode )                                                           C5              ,--抄表止码                C5
            sum(decode(pdpiid,'01',pdsl,0))                                                           C6              ,--应收水量                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--打印日期                C7
            fGetOperName(MAX('c2'))                                                   C8              ,--打印员                  C8
            max(ppayee)                                          C9              ,--收费员                  C9
           '币  '||(case when max(PLCD)='DE' then tools.fuppernumber(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ )) else  tools.fuppernumber((sum(pdje)+sum(pdznj)-max(PLSAVINGBQ ))*-1)   end )                 C10             ,--合计金额大写            C10
            '￥'||(case when max(PLCD)='DE' then tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) ,2) else  tools.fformatnum((sum(pdje)+sum(pdznj)-max(PLSAVINGBQ ))*-1 ,2) end  )                  C11             ,--合计金额                C11
           --  '币  '|| tools.fuppernumber(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ))                  C10             ,--合计金额大写            C10
           -- '￥'||tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) ,2)                   C11             ,--合计金额                C11
            fGetPriceText_gtmx(plid)                C12             ,--水费明细1               C12
            ''                 C13             ,--水费明细2               C13
            to_char(sysdate ,'yyyy') ||'    '||to_char(sysdate ,'mm')||'    '|| to_char(sysdate ,'dd')||' '                                       C14             ,--系统时间年              C14
            to_char(max(rldate) ,'mm')                                             C15             ,--系统时间月              C15
            to_char(max(rldate) ,'dd')                                             C16             ,--系统时间日              C16
            max(pbatch )                                                            C17             ,----缴费交易批次,系统时间月           C17
            to_char(max(rldate) ,'yyyy')                                                                C18             ,----实收帐明细流水号      C18
            ''                                                             C19             ,--销帐流水流水号          C19
            ''                 C20             ,--票务日期 /*票务日期*/   C20
            '暂无启用'                                                         C21             ,--水表编号                C21
            '抄表员：'                                                         C22             ,--用户编号                C22
            max(plrlmonth)                                                         C23             ,--应收账月份                  C23
            max(rlmadr )                                                         C24             ,--水表安装地址            C24
            max(RLBFID)                                                         C25             ,--表册号                  C25
            max(RLRPER)                                                         C26             ,--抄表员              C26
            to_char(max(RLDATE),'yyyy-mm-dd')                                                        C27             ,--制据日期                C27
            fGetUnitPrice_mx(max(rlid),'01,02,03,04|',4)                                                   C28             ,--应收单价                C28
            fGetUnitMoney_gtmx(plid)                                      C29             ,--水费金额                C29
            '暂无启用'                                                         C30             ,--余量                    C30
            ''                                                       C31             ,--滞纳金                  C31
            ''                                                         C32             ,--手续费                  C32
            ''                                                        C33             ,--上期抄表日期    （本次交钱）        C33
            '上次余数:'||replace( tools.fformatnum(max(PLSAVINGQC), 2)   ,'-.','-0.')/*tools.fformatnum(max(PLSAVINGQC),2)*/                                                      C34             ,--抄表日期  (上次结余)             C34
            '本次余数:'||replace( tools.fformatnum(max(PLSAVINGQM), 2)   ,'-.','-0.')/*tools.fformatnum(max(PLSAVINGQM),2)*/                                                        C35             ,--账务日期 (本次结余)               C35
            '暂无启用'                                                         C36             ,--抄表月份                C36
            '应收现金 '||fGetRecZnjMoney_gtmx(plid)                 C37                                                  ,--合计应收1                            C37
            '现金'                                                         C38             ,--收费方式                C38
            '暂无启用'                                                         C39             ,--水费明细3               C39
           ''                                                        C40             ,--预存发生明细            C40
           ''                                  C41             ,--应收金额大写           C41
          case
             when sum(RLADDSL) > 0 then
              '调表：' || '【余量为' || tools.fformatnum(max(RLADDSL), 0) || '】'
             when sum(RLECODE - RLSCODE) <> sum(RLREADSL) then
              '调表'
                 when max(RLTRANS)='O' then
              '追量收费'
             else
              '正常抄表'
           end                                                           C42             ,--备注           C42
            '应缴滞纳金:'||tools.fformatnum(max(PLZNJ),2)                                                       C43             ,--应缴滞纳金3           C43
            '实缴滞纳金:'||tools.fformatnum(max(PLZNJ),2)                                                         C44             ,--实缴滞纳金4           C44
            '应缴水费:'||tools.fformatnum(max(plje),2)                                                        C45             ,--应缴水费5           C45
            '实缴水费:'||tools.fformatnum(max(PLJE),2)                                                        C46             ,--实缴水费6           C46
            case when max(plcd)='DE' then '' else '冲红票' end                                                         C47             ,--用户预留字段7           C47
            ''                                                  C48             ,--用户预留字段8           C48
            ''                                                         C49             ,--用户预留字段9           C49
            ''                                                         C50             ,--用户预留字段10          C50
            ''                                                            C51             ,--应收账流水号            C51
            ''                            C52             ,--费用项目                C52
            MAX('c2')                                                                 C53             ,--打印员编号              C53
            ''                                                       C54             ,--收费员              C54
            '.'                                                                 C55             ,--序号                    C55
            max(PCD )                                                               C56             ,--系统预留字段1           C56
            MAX('c3')                                                        C57             ,--系统预留字段2           C57
            ''                                                        C58             ,--系统预留字段3           C58
            ''                                                         C59             ,--系统预留字段4           C59
            ''                                                         C60              --系统预留字段5           C60
     from payment,paidlist,paiddetail,reclist/* ,  pbparmtemp*/
   where pid=plpid and
         plid=pdid and
         plrlid=rlid and
         --plpid = C1
         plid = p_batch

         group by plid,pid
UNION

select
            max(NVL(MIPRIID, pmcode))                                                           C1              ,--资料号                  C1
            max(ciname )                                                           C2              ,--户名                    C2
            max(ciadr )                                                            C3              ,--用户地址                C3
            case when 0=0 then null else 0 end                                                           C4              ,--抄表起码                C4
            case when 0=0 then null else 0 end                                                            C5              ,--抄表止码                C5
            case when 0=0 then null else 0 end                                                            C6              ,--应收水量                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--打印日期                C7
            fGetOperName(MAX('c2'))                                                   C8              ,--打印员                  C8
            max(ppayee)                                          C9              ,--收费员                  C9
           '币  '|| tools.fuppernumber(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)))                     C10             ,--合计金额大写            C10
            '￥'||tools.fformatnum(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)) ,2)                     C11             ,--合计金额                C11
            ''                C12             ,--水费明细1               C12
            ''                 C13             ,--水费明细2               C13
            to_char(sysdate ,'yyyy') ||'    '||to_char(sysdate ,'mm')||'    '|| to_char(sysdate ,'dd')||' '                                       C14             ,--系统时间年              C14
            to_char(max(pdatetime) ,'mm')                                             C15             ,--系统时间月              C15
            to_char(max(pdatetime) ,'dd')                                             C16             ,--系统时间日              C16
            max(pbatch )                                                            C17             ,----缴费交易批次          C17
             to_char(max(pdatetime) ,'yyyy')                                                                C18             ,----实收帐明细流水号      C18
            ''                                                             C19             ,--销帐流水流水号          C19
            ''                 C20             ,--票务日期 /*票务日期*/   C20
            '暂无启用'                                                         C21             ,--水表编号                C21
            '抄表员：'                                                         C22             ,--用户编号                C22
            ''                                                         C23             ,--应收账月份                  C23
            ''                                                         C24             ,--水表安装地址            C24
            max(MIBFID)                                                         C25             ,--表册号                  C25
            ''                                                         C26             ,--抄表次序号              C26
            ''                                                         C27             ,--抄表水量                C27
            ''                                                           C28             ,--应收单价                C28
            ''                                      C29             ,--应收金额                C29
            '暂无启用'                                                         C30             ,--余量                    C30
            ''                                                       C31             ,--滞纳金                  C31
            ''                                                         C32             ,--手续费                  C32
            ''                                                        C33             ,--上期抄表日期    （本次交钱）        C33 '上次结余 '||tools.fformatnum(max(PSAVINGQC),2)
            '合收预存'||tools.fuppernumber(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)))                                                        C34             ,--抄表日期  (上次结余)  '本次结余 '||tools.fformatnum(max(PSAVINGQM),2)            C34
            ''                                                        C35             ,--账务日期 (本次结余)               C35
            '暂无启用'                                                         C36             ,--抄表月份                C36
            ''                 合计应收1                                                  ,--合计应收1                            C37
            '现金'                                                         C38             ,--收费方式                C38
            '暂无启用'                                                         C39             ,--水费明细3               C39
           ''                                                        C40             ,--预存发生明细            C40
           ''                                  C41             ,--应收金额大写           C41
           ''                                                         C42             ,--用户预留字段2           C42
            ''                                                       C43             ,--用户预留字段3           C43
            ''                                                         C44             ,--用户预留字段4           C44
            ''                                                         C45             ,--用户预留字段5           C45
            ''                                                         C46             ,--用户预留字段6           C46
            ''                                                         C47             ,--用户预留字段7           C47
            ''                                                  C48             ,--用户预留字段8           C48
            ''                                                         C49             ,--用户预留字段9           C49
            ''                                                         C50             ,--用户预留字段10          C50
            ''                                                            C51             ,--应收账流水号            C51
            ''                            C52             ,--费用项目                C52
            MAX('c2')                                                                 C53             ,--打印员编号              C53
            ''                                                       C54             ,--收费员编号              C54
            ''                                                                 C55             ,--序号                    C55
            max(PCD )                                                               C56             ,--系统预留字段1           C56
            MAX('c3')                                                        C57             ,--系统预留字段2           C57
            ''                                                        C58             ,--系统预留字段3           C58
            ''                                                         C59             ,--系统预留字段4           C59
            MAX(PID)                                                         C60              --系统预留字段5           C60
     from payment , /* pbparmtemp,*/custinfo,METERINFO
   where  pmid=miid and
         pcid=ciid and
        -- pid = C1 and
        pid = p_batch and
         PTRANS ='S'
         group by PBATCH
         HAVING sum( decode(pcd,'DE',1,-1)*(ppayment -pchange))<>0

order by c55 ,c60 )
)  a,
(
select
replace(connstr(
trim(t.ptditemno)||'^'||trim(round(t.ptdx ) )||'^'||trim(round(t.ptdy  ))||'^'||trim(round(t.ptdheight ))||'^'||
trim(round(t.ptdwidth ))||'^'||trim(t.ptdfontname)||'^'||trim(t.ptdfontsize*-1)||'^'||trim(t.ptdfontalign)||'|'),'|/','|') constructdt,
 replace(connstr(trim(t.ptditemno)),'/','^')||'|'  contentstrorder
 from printtemplatedt_str t where ptdid= p_modelno
 --2
  ) b,
(
select pthpaperheight||'^'||pthpaperwidth||'^'||lastpage||'^'||1||'|' constructhd  from printtemplatehd t1 where  pthid =p_modelno --2
) c ;
    return v_invprintstr;


  end ;
/

