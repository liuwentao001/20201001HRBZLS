CREATE OR REPLACE PROCEDURE HRBZLS."SP_FCHARGEINVSEARCHHP_OCX" (
p_pbatch in varchar2, --实收批次
P_PID IN varchar2 ,--实收流水(不空按实收流水打印)
p_plid in varchar2,--实收明细流水(不空按实收明细流水打印)
p_modelno in varchar2, --发票格式号:2/25
p_printtype in varchar2, --合票:H/分票:F /按户汇总发票 Z
p_ifbd in varchar2, --是否补打 --是:Y,否:N
P_PRINTER IN VARCHAR2 --打印员
)  is
v_constructhd varchar2(30000);
v_constructdt varchar2(30000);
v_contentstrorder varchar2(30000);
v_hd varchar2(30000);
v_tempstr varchar2(30000);
v_conlen number(10);
I NUMBER(10);
V_C1         VARCHAR2(3000);
V_C2         VARCHAR2(3000);
V_C3         VARCHAR2(3000);
V_C4         VARCHAR2(3000);
V_C5         VARCHAR2(3000);
V_C6         VARCHAR2(3000);
V_C7         VARCHAR2(3000);
V_C8         VARCHAR2(3000);
V_C9         VARCHAR2(3000);
V_C10        VARCHAR2(3000);
V_C11        VARCHAR2(3000);
V_C12        VARCHAR2(3000);
V_C13        VARCHAR2(3000);
V_C14        VARCHAR2(3000);
V_C15        VARCHAR2(3000);
V_C16        VARCHAR2(3000);
V_C17        VARCHAR2(3000);
V_C18        VARCHAR2(3000);
V_C19        VARCHAR2(3000);
V_C20        VARCHAR2(3000);
V_C21        VARCHAR2(3000);
V_C22        VARCHAR2(3000);
V_C23        VARCHAR2(3000);
V_C24        VARCHAR2(3000);
V_C25        VARCHAR2(3000);
V_C26        VARCHAR2(3000);
V_C27        VARCHAR2(3000);
V_C28        VARCHAR2(3000);
V_C29        VARCHAR2(3000);
V_C30        VARCHAR2(3000);
V_C31        VARCHAR2(3000);
V_C32        VARCHAR2(3000);
V_C33        VARCHAR2(3000);
V_C34        VARCHAR2(3000);
V_C35        VARCHAR2(3000);
V_C36        VARCHAR2(3000);
V_C37        VARCHAR2(3000);
V_C38        VARCHAR2(3000);
V_C39        VARCHAR2(3000);
V_C40        VARCHAR2(3000);
V_C41        VARCHAR2(3000);
V_C42        VARCHAR2(3000);
V_C43        VARCHAR2(3000);
V_C44        VARCHAR2(3000);
V_C45        VARCHAR2(3000);
V_C46        VARCHAR2(3000);
V_C47        VARCHAR2(3000);
V_C48        VARCHAR2(3000);
V_C49        VARCHAR2(3000);
V_C50        VARCHAR2(3000);
V_C51        VARCHAR2(3000);
V_C52        VARCHAR2(3000);
V_C53        VARCHAR2(3000);
V_C54        VARCHAR2(3000);
V_C55        VARCHAR2(3000);
V_C56        VARCHAR2(3000);
V_C57        VARCHAR2(3000);
V_C58        VARCHAR2(3000);
V_C59        VARCHAR2(3000);
V_C60        VARCHAR2(3000);
cursor c_hd is
select
        constructhd,
        constructdt,
        contentstrorder
        from (
select
replace(connstr(
trim(t.ptditemno)||'^'||trim(round(t.ptdx ) )||'^'||trim(round(t.ptdy  ))||'^'||trim(round(t.ptdheight ))||'^'||
trim(round(t.ptdwidth ))||'^'||trim(t.ptdfontname)||'^'||trim(t.ptdfontsize*-1)||'^'||trim(ftransformaling(t.ptdfontalign))||'|'),'|/','|') constructdt,
 replace(connstr(trim(t.ptditemno)),'/','^')||'|'  contentstrorder
 from printtemplatedt_str t where ptdid= p_modelno
 --2
  ) b,
(
select pthpaperheight||'^'||pthpaperwidth||'^'||lastpage||'^'||1||'|' constructhd  from printtemplatehd t1 where  pthid =p_modelno --2
) c ;


cursor c_dt is

select * from

(
--分票(销帐)
/*            select
            max(rlmcode)                          C1              ,--资料号                  C1
            max(rlcname )                       C2              ,--户名                    C2
            max(rlcadr )                                C3              ,--用户地址                C3
            '上月抄表数  :'||to_char(min(rlscode ) )     C4              ,--抄表起码                C4
            '本月抄表数  :'||to_char(max(rlecode ) )     C5              ,--抄表止码                C5
            '实际用量    :'||to_char(max(rlsl )     )       C6              ,--应收水量                C6
            to_char(SYSDATE,'yyyy-mm-dd')              C7              ,--打印日期                C7
            fGetOperName(P_PRINTER)                     C8              ,--打印员                  C8
           fgetopername(   max(ppayee)  )                                        C9              ,--收费员                  C9
          replace(   tools.fuppernumber(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) )   ,'-.','-0.')            C10             ,--合计金额大写            C10
            '实收金额:'||replace( tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) - SUM(CASE WHEN MIIFTAX='Y' AND PDPIID='01'  THEN   PDJE  ELSE 0 END)  ,2)   ,'-.','-0.')                  C11             ,--合计金额                C11
           F_chargeinvsearch_recmx_ocx(plid,null,'1')                C12             ,--水费明细1               C12
           '                                '                           C13             ,--水费明细2               C13
            to_char(sysdate ,'yyyy')              C14             ,--系统时间年              C14
            to_char(sysdate ,'mm')                                             C15             ,--系统时间月              C15
            to_char(sysdate ,'dd')                                             C16             ,--系统时间日              C16
            max(pbatch )                                                            C17             ,----缴费交易批次,系统时间月           C17
            max(pid)                                                                C18             ,----实收帐明细流水号      C18
            '                                '                                                            C19             ,--销帐流水流水号          C19
            to_char(max(pdatetime),'yyyy-mm-dd')                 C20             ,--票务日期 \*票务日期*\   C20
           '                                '                                                        C21             ,--水表编号                C21
            '                                '                                                       C22             ,--用户编号                C22
            max(plrlmonth)                                                         C23             ,--应收账月份                  C23
            max(rlmadr )                                                         C24             ,--水表安装地址            C24
            max(RLBFID)                                                         C25             ,--表册号                  C25
           '抄表员：'||    max(FGETBFRPER_smfid(mibfid,mismfid))||  max(case when mistatus in ('13','21') then '  电话：'||FGETBFRPERtel_smfid(mibfid,mismfid) else '' end)                                                          C26             ,--抄表员              C26
            to_char(SYSDATE,'yyyy-mm-dd')                                                        C27             ,--制据日期                C27
            ''                  C28             ,--应收单价                C28
           replace(  tools.fformatnum(sum(pdje),2)   ,'-.','-0.')                                      C29             ,--水费金额                C29
            '                                '                                                         C30             ,--余量                    C30
          '违约金:'|| replace( tools.fformatnum( sum(pdznj)  ,2)  ,'-.','-0.')           C31             ,--滞纳金                  C31
           '                                '                                                        C32             ,--手续费                  C32
           '                                '                                                      C33             ,--上期抄表日期    （本次交钱）        C33
           '上次结余:'||   replace( tools.fformatnum(max(PLSAVINGQC), 2)   ,'-.','-0.')                                                    C34             ,--抄表日期  (上次结余)             C34
           '本次结余:'||   replace( tools.fformatnum(max(PLSAVINGQM), 2)   ,'-.','-0.')                                                    C35             ,--账务日期 (本次结余)               C35
            '本月抄表日期:'||max(to_char(RLRDATE,'yyyy-mm-dd'))                                                         C36             ,--抄表月份                C36
          replace(  tools.fformatnum(sum(pdje) - SUM(CASE WHEN MIIFTAX='Y' AND PDPIID='01'  THEN   PDJE  ELSE 0 END) ,2)  ,'-.','-0.')                     C37  ,--合计应收1                            C37
            '                                '                                                         C38             ,--收费方式                C38
            '                                '                                                         C39             ,--水费明细3               C39
           '                                '                                                     C40             ,--预存发生明细            C40
           tools.fuppernumber(sum(pdje) - SUM(CASE WHEN MIIFTAX='Y' AND PDPIID='01'  THEN   PDJE  ELSE 0 END) )                                C41             ,--应收金额大写           C41
            '加减水量    :' || tools.fformatnum(max(RLADDSL), 0)  C42             ,--备注           C42
            '                                '                                                      C43             ,--应缴滞纳金3           C43
            '                                '                                                        C44             ,--实缴滞纳金4           C44
            '                                '           C45             ,--应缴水费5           C45
            '                                '   C46             ,--实缴水费6           C46
           ''                                                     C47             ,--用户预留字段7           C47
         fgetopername(  max(ppayee)  )                                               C48             ,--用户预留字段8           C48
        '                              '                                                        C49            ,--用户预留字段9           C49
            '                                '                                                         C50             ,--用户预留字段10          C50
          '                                '                                                             C51             ,--应收账流水号            C51
           '                                '                            C52             ,--费用项目                C52
           '                                '                                                                C53             ,--打印员编号              C53
          '                                '                                                       C54             ,--收费员              C54
          TO_CHAR(SUM(CASE WHEN MIIFTAX='Y' AND PDPIID='01'  THEN   PDJE  ELSE 0 END))                                                                 C55             ,--序号                    C55
          '                                '            C56             ,--系统预留字段1           C56
           '                                '                                                      C57             ,--系统预留字段2           C57
           '                                '                                                        C58             ,--系统预留字段3           C58
          (case when  p_ifbd='Y' THEN '补 '||to_char(sysdate,'yyyy-mm-dd') else ''  END )                                                        C59             ,--系统预留字段4           C59
          MAX(pbatch)|| pid||plid                                                        C60              --系统预留字段5           C60

    from payment,paidlist,paiddetail,reclist ,meterinfo
   where pid=plpid and
         plid=pdid and
         plrlid=rlid and
         pmid=miid   AND
         pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         (p_plid is null or p_plid=plid) and
         p_printtype ='F'

         group by plid,pid
UNION
--分票(预存)
select
            max(pmcode)                                                           C1              ,--资料号                  C1
            max(ciname )                                                           C2              ,--户名                    C2
            max(ciadr )                                                            C3              ,--用户地址                C3
            ''                                                          C4              ,--抄表起码                C4
            ''                                                             C5              ,--抄表止码                C5
            ''                                                            C6              ,--应收水量                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--打印日期                C7
            fGetOperName(P_PRINTER)                                                   C8              ,--打印员                  C8
            fgetopername(  max(ppayee)   )                                       C9              ,--收费员                  C9
           '币  '|| tools.fuppernumber(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)))                       C10             ,--合计金额大写            C10
            '实收金额:'||replace(tools.fformatnum(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)) ,2),'-.','-0.')                     C11             ,--合计金额                C11
            ''                C12             ,--水费明细1               C12
            ''                 C13             ,--水费明细2               C13
            to_char(sysdate ,'yyyy') ||'    '||to_char(sysdate ,'mm')||'    '|| to_char(sysdate ,'dd')||' '                                       C14             ,--系统时间年              C14
            to_char(max(pdatetime) ,'mm')                                             C15             ,--系统时间月              C15
            to_char(max(pdatetime) ,'dd')                                             C16             ,--系统时间日              C16
            max(pbatch )                                                            C17             ,----缴费交易批次          C17
             to_char(max(pdatetime) ,'yyyy')                                                                C18             ,----实收帐明细流水号      C18
            ''                                                             C19             ,--销帐流水流水号          C19
            to_char(max(pdatetime) ,'yyyy-mm-dd')                  C20             ,--票务日期 \*票务日期*\   C20
            '暂无启用'                                                         C21             ,--水表编号                C21
            ''                                                      C22             ,--用户编号                C22
            ''                                                         C23             ,--应收账月份                  C23
            ''                                                         C24             ,--水表安装地址            C24
            max(MIBFID)                                                         C25             ,--表册号                  C25
            '抄表员：'||    max(FGETBFRPER_smfid(mibfid,mismfid))||max(case when mistatus in ('13','21') then '  电话：'||FGETBFRPERtel_smfid(mibfid,mismfid) else '' end)                                                          C26             ,--抄表员              C26
            ''                                                         C27             ,--抄表水量                C27
            ''                                                           C28             ,--应收单价                C28
            ''                                      C29             ,--应收金额                C29
            '暂无启用'                                                         C30             ,--余量                    C30
            ''                                                       C31             ,--滞纳金                  C31
            ''                                                         C32             ,--手续费                  C32
            ''                                                        C33             ,--上期抄表日期    （本次交钱）        C33 '上次结余 '||tools.fformatnum(max(PSAVINGQC),2)
            '上次结余:'||   replace( tools.fformatnum(sum(PSAVINGQC), 2)   ,'-.','-0.')                                                        C34             ,--抄表日期  (上次结余)  '本次结余 '||tools.fformatnum(max(PSAVINGQM),2)            C34
            '本次结余:'||   replace( tools.fformatnum(sum(PSAVINGQM), 2)   ,'-.','-0.')                                                        C35             ,--账务日期 (本次结余)               C35
            ''                                                         C36             ,--抄表月份                C36
            tools.fformatnum(0,2)                 合计应收1                                                  ,--合计应收1                            C37
            '现金'                                                         C38             ,--收费方式                C38
            '暂无启用'                                                         C39             ,--水费明细3               C39
           ''                                                        C40             ,--预存发生明细            C40
           tools.fuppernumber(0)                                  C41             ,--应收金额大写           C41
           ''                                                         C42             ,--用户预留字段2           C42
            ''                                                       C43             ,--用户预留字段3           C43
            ''                                                         C44             ,--用户预留字段4           C44
            ''                                                         C45             ,--用户预留字段5           C45
            ''                                                         C46             ,--用户预留字段6           C46
            ''                                                         C47             ,--用户预留字段7           C47
           fgetopername(   max(ppayee)      )                                            C48             ,--用户预留字段8           C48
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
            '预存'||(case when  p_ifbd='Y' THEN '补 '||to_char(sysdate,'yyyy-mm-dd') else ''  END )                                                         C59             ,--系统预留字段4           C59
           MAX(PBATCH)|| PID                                                         C60              --系统预留字段5           C60
     from payment , custinfo,METERINFO
   where  pmid=miid and
         pcid=ciid and
        pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         PTRANS ='S' AND
         p_printtype ='F'
         group by PID
         HAVING sum( decode(pcd,'DE',1,-1)*(ppayment -pchange))<>0
*/


SELECT
 c1    ,
c2    ,
c3    ,
c4    ,
c5    ,
c6    ,
c7    ,
c8    ,
c9    ,
c10   ,
c11   ,
c12   ,
c13   ,
c14   ,
c15   ,
c16   ,
c17   ,
c18   ,
c19   ,
c20   ,
c21   ,
c22   ,
c23   ,
c24   ,
c25   ,
c26   ,
c27   ,
c28   ,
c29   ,
c30   ,
c31   ,
c32   ,
c33   ,
c34   ,
c35   ,
c36   ,
c37   ,
c38   ,
c39   ,
c40   ,
c41   ,
c42   ,
c43   ,
c44   ,
c45   ,
c46   ,
c47   ,
c48   ,
c49   ,
c50   ,
c51   ,
c52   ,
c53   ,
c54   ,
c55   ,
c56   ,
c57   ,
c58   ,
c59   ,
c60    FROM PBPARMNNOCOMMIT_PRINT_gt

/*-----------------------------------------
UNION

--分票PID(销帐)
            select
            max(rlmcode)                          C1              ,--资料号                  C1
            max(rlcname )                       C2              ,--户名                    C2
            max(rlcadr )                                C3              ,--用户地址                C3
            '上月抄表数  :'||to_char(min(rlscode ) )     C4              ,--抄表起码                C4
            '本月抄表数  :'||to_char(max(rlecode ) )     C5              ,--抄表止码                C5
            '实际用量    :'||to_char(sum(rlsl )     )       C6              ,--应收水量                C6
            to_char(SYSDATE,'yyyy-mm-dd')              C7              ,--打印日期                C7
            fGetOperName(P_PRINTER)                     C8              ,--打印员                  C8
           fgetopername(   max(ppayee)  )                                        C9              ,--收费员                  C9
            ''            C10             ,--合计金额大写            C10
            '实收金额:'||replace( tools.fformatnum(sum(plje)+sum(plznj)+sum(PLSAVINGBQ ) - SUM(CASE WHEN MIIFTAX='Y'    THEN   to_number(F_chargeinvsearch_pdje01_ocx(pid,'1'))  ELSE 0 END)  ,2)   ,'-.','-0.')                  C11             ,--合计金额                C11
           F_chargeinvsearch_recmx_ocx(pid,'3')                C12             ,--水费明细1               C12
           '                                '                           C13             ,--水费明细2               C13
            to_char(sysdate ,'yyyy')              C14             ,--系统时间年              C14
            to_char(sysdate ,'mm')                                             C15             ,--系统时间月              C15
            to_char(sysdate ,'dd')                                             C16             ,--系统时间日              C16
            max(pbatch )                                                            C17             ,----缴费交易批次,系统时间月           C17
            max(pid)                                                                C18             ,----实收帐明细流水号      C18
            '                                '                                                            C19             ,--销帐流水流水号          C19
            to_char(max(pdatetime),'yyyy-mm-dd')                 C20             ,--票务日期 \*票务日期*\   C20
           '                                '                                                        C21             ,--水表编号                C21
            '                                '                                                       C22             ,--用户编号                C22
            max(plrlmonth)                                                         C23             ,--应收账月份                  C23
            max(rlmadr )                                                         C24             ,--水表安装地址            C24
            max(RLBFID)                                                         C25             ,--表册号                  C25
           '抄表员：'||    max(FGETBFRPER_smfid(rlbfid,rlsmfid))                                                          C26             ,--抄表员              C26
            to_char(SYSDATE,'yyyy-mm-dd')                                                        C27             ,--制据日期                C27
            ''                  C28             ,--应收单价                C28
           replace(  tools.fformatnum(sum(plje),2)   ,'-.','-0.')                                      C29             ,--水费金额                C29
            '                                '                                                         C30             ,--余量                    C30
          '违约金:'|| replace( tools.fformatnum( sum(plznj)  ,2)  ,'-.','-0.')           C31             ,--滞纳金                  C31
           '                                '                                                        C32             ,--手续费                  C32
           '                                '                                                      C33             ,--上期抄表日期    （本次交钱）        C33
           '上次结余:'||   replace( tools.fformatnum(to_number(substr(min(plid||PLSAVINGQC),10))  , 2)   ,'-.','-0.')                                                    C34             ,--抄表日期  (上次结余)             C34
           '本次结余:'||   replace( tools.fformatnum(to_number(substr(max(plid||PLSAVINGQM),10)) , 2)   ,'-.','-0.')                                                    C35             ,--账务日期 (本次结余)               C35
            '本月抄表日期:'||max(to_char(RLRDATE,'yyyy-mm-dd'))                                                         C36             ,--抄表月份                C36
          replace(  tools.fformatnum(sum(plje) - SUM(CASE WHEN MIIFTAX='Y'    THEN   to_number(F_chargeinvsearch_pdje01_ocx(pid,'1'))  ELSE 0 END) ,2)  ,'-.','-0.')                     C37  ,--合计应收1                            C37
            '                                '                                                         C38             ,--收费方式                C38
            '                                '                                                         C39             ,--水费明细3               C39
           '                                '                                                     C40             ,--预存发生明细            C40
           tools.fuppernumber(sum(plje) - SUM(CASE WHEN MIIFTAX='Y'    THEN   to_number(F_chargeinvsearch_pdje01_ocx(pid,'1'))  ELSE 0 END) )                                C41             ,--应收金额大写           C41
            '加减水量    :' || tools.fformatnum(sum(RLADDSL), 0)  C42             ,--备注           C42
            '                                '                                                      C43             ,--应缴滞纳金3           C43
            '                                '                                                        C44             ,--实缴滞纳金4           C44
            '                                '           C45             ,--应缴水费5           C45
            '                                '   C46             ,--实缴水费6           C46
          ''                                                     C47             ,--用户预留字段7           C47
         fgetopername(  max(ppayee)  )                                               C48             ,--用户预留字段8           C48
        '                              '                                                        C49            ,--用户预留字段9           C49
            '                                '                                                         C50             ,--用户预留字段10          C50
          '                                '                                                             C51             ,--应收账流水号            C51
           '                                '                            C52             ,--费用项目                C52
           '                                '                                                                C53             ,--打印员编号              C53
          '                                '                                                       C54             ,--收费员              C54
          ''                                                                 C55             ,--序号                    C55
          '                                '            C56             ,--系统预留字段1           C56
           '                                '                                                      C57             ,--系统预留字段2           C57
           '                                '                                                        C58             ,--系统预留字段3           C58
          (case when  p_ifbd='Y' THEN '补 '||to_char(sysdate,'yyyy-mm-dd') else ''  END )                                                        C59             ,--系统预留字段4           C59
          MAX(pbatch)|| pid                                                        C60              --系统预留字段5           C60

    from payment,paidlist,reclist ,meterinfo
   where pid=plpid and

         plrlid=rlid and
         pmid=miid   AND
         pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         (p_plid is null or p_plid=plid) and
         p_printtype ='Z'

         group by pid
UNION
--分票PID(预存)
select
            max(NVL(MIPRIID, pmcode))                                                           C1              ,--资料号                  C1
            max(ciname )                                                           C2              ,--户名                    C2
            max(ciadr )                                                            C3              ,--用户地址                C3
            ''                                                          C4              ,--抄表起码                C4
            ''                                                             C5              ,--抄表止码                C5
            ''                                                            C6              ,--应收水量                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--打印日期                C7
            fGetOperName(P_PRINTER)                                                   C8              ,--打印员                  C8
            fgetopername(  max(ppayee)   )                                       C9              ,--收费员                  C9
           '币  '|| tools.fuppernumber(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)))                       C10             ,--合计金额大写            C10
            '实收金额:'||replace(tools.fformatnum(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)) ,2),'-.','-0.')                     C11             ,--合计金额                C11
            ''                C12             ,--水费明细1               C12
            ''                 C13             ,--水费明细2               C13
            to_char(sysdate ,'yyyy') ||'    '||to_char(sysdate ,'mm')||'    '|| to_char(sysdate ,'dd')||' '                                       C14             ,--系统时间年              C14
            to_char(max(pdatetime) ,'mm')                                             C15             ,--系统时间月              C15
            to_char(max(pdatetime) ,'dd')                                             C16             ,--系统时间日              C16
            max(pbatch )                                                            C17             ,----缴费交易批次          C17
             to_char(max(pdatetime) ,'yyyy')                                                                C18             ,----实收帐明细流水号      C18
            ''                                                             C19             ,--销帐流水流水号          C19
            to_char(max(pdatetime) ,'yyyy-mm-dd')                  C20             ,--票务日期 \*票务日期*\   C20
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
            '上次结余:'||   replace( tools.fformatnum(sum(PSAVINGQC), 2)   ,'-.','-0.')                                                        C34             ,--抄表日期  (上次结余)  '本次结余 '||tools.fformatnum(max(PSAVINGQM),2)            C34
            '本次结余:'||   replace( tools.fformatnum(sum(PSAVINGQM), 2)   ,'-.','-0.')                                                        C35             ,--账务日期 (本次结余)               C35
            ''                                                         C36             ,--抄表月份                C36
            tools.fformatnum(0,2)                 合计应收1                                                  ,--合计应收1                            C37
            '现金'                                                         C38             ,--收费方式                C38
            '暂无启用'                                                         C39             ,--水费明细3               C39
           ''                                                        C40             ,--预存发生明细            C40
           tools.fuppernumber(0)                                  C41             ,--应收金额大写           C41
           ''                                                         C42             ,--用户预留字段2           C42
            ''                                                       C43             ,--用户预留字段3           C43
            ''                                                         C44             ,--用户预留字段4           C44
            ''                                                         C45             ,--用户预留字段5           C45
            ''                                                         C46             ,--用户预留字段6           C46
            ''                                                         C47             ,--用户预留字段7           C47
           fgetopername(   max(ppayee)      )                                            C48             ,--用户预留字段8           C48
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
            '预存'||(case when  p_ifbd='Y' THEN '补 '||to_char(sysdate,'yyyy-mm-dd') else ''  END )                                                         C59             ,--系统预留字段4           C59
           MAX(PBATCH)|| PID                                                         C60              --系统预留字段5           C60
     from payment , custinfo,METERINFO
   where  pmid=miid and
         pcid=ciid and
        pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         PTRANS ='S' AND
         p_printtype ='Z'
         group by PID
         HAVING sum( decode(pcd,'DE',1,-1)*(ppayment -pchange))<>0

--------------------------------------------- */

UNION
------------------------------------------------
--合票pid(销帐预存)
            select
        tools.fmid( max(cminfo),1,'N','/')                           C1              ,--资料号                  C1
        tools.fmid( max(cminfo) ,2,'N','/')                         C2              ,--户名                    C2
        tools.fmid( max(cminfo),3,'N','/')                                 C3              ,--用户地址                C3
            '上月抄表数  :'||to_char(min(rlscode ) )     C4              ,--抄表起码                C4
            '本月抄表数  :'||to_char(max(rlecode ) )     C5              ,--抄表止码                C5
            '实际用量    :'||to_char(sum(rlsl )     )       C6              ,--应收水量                C6
            to_char(SYSDATE,'yyyy-mm-dd')              C7              ,--打印日期                C7
            fGetOperName(P_PRINTER)                     C8              ,--打印员                  C8
           fgetopername(   max(ppayee)  )                                        C9              ,--收费员                  C9
            ''              C10             ,--合计金额大写            C10
  '实收金额:'||F_PRINTINV_OCX('C10' ,pbatch,max(pmid) )     /*'实收金额:'|| tools.fformatnum(sum(pdje)+sum(pdznj)+sum(PLSAVINGBQ ) + max(YC) - nvl(SUM(PD01JE),0) ,2) */                   C11             ,--合计金额                C11
           F_chargeinvsearch_recmx_ocx1(PBATCH,max(pmid),'3',1)               C12             ,--水费明细1               C12
           '                                '                           C13             ,--水费明细2               C13
            to_char(sysdate ,'yyyy')              C14             ,--系统时间年              C14
            to_char(sysdate ,'mm')                                             C15             ,--系统时间月              C15
            to_char(sysdate ,'dd')                                             C16             ,--系统时间日              C16
            max(pbatch )                                                            C17             ,----缴费交易批次,系统时间月           C17
            ''                                                                C18             ,----实收帐明细流水号      C18
            '                                '                                                            C19             ,--销帐流水流水号          C19
            to_char(max(pdatetime),'yyyy-mm-dd')                 C20             ,--票务日期 /*票务日期*/   C20
           '                                '                                                        C21             ,--水表编号                C21
            '                                '                                                       C22             ,--用户编号                C22
            ''                                                         C23             ,--应收账月份                  C23
            tools.fmid( max(cminfo) ,3,'N','/')                                                           C24             ,--水表安装地址            C24
            tools.fmid( max(cminfo) ,6,'N','/')                                                        C25             ,--表册号                  C25
           '抄表员：'||    max(FGETBFRPER_smfid(mibfid,mismfid))||max(case when mistatus in ('13','21') then '  电话：'||FGETBFRPERtel_smfid(mibfid,mismfid) else '' end)                                                          C26             ,--抄表员              C26
            to_char(SYSDATE,'yyyy-mm-dd')                                                        C27             ,--制据日期                C27
            ''                  C28             ,--应收单价                C28
            ''                                      C29             ,--水费金额                C29
            '                                '                                                         C30             ,--余量                    C30
          '违约金:'||replace( tools.fformatnum( sum(pdznj)  ,2) ,'-.','-0.')            C31             ,--滞纳金                  C31
           '                                '                                                        C32             ,--手续费                  C32
           '                                '                                                      C33             ,--上期抄表日期    （本次交钱）        C33
     '上次结余:'||   F_PRINTINV_OCX('C7' ,pbatch,max(pmid) )        /*'上次结余:'||   replace( tools.fformatnum(max(qcsaving),2)   ,'-.','-0.')  */                                                  C34             ,--抄表日期  (上次结余)             C34
     '本次结余:'||   F_PRINTINV_OCX('C9' ,pbatch,max(pmid) ) /* '本次结余:'||   tools.fformatnum( max(qcsaving) + SUM(PLSAVINGBQ ) + max(YC) ,2) */                                                    C35             ,--账务日期 (本次结余)               C35
            '本月抄表日期:'||MAX(to_char(RLRDATE,'yyyy-mm-dd'))                                                         C36             ,--抄表月份                C36
        replace(  tools.fformatnum(  sum(pdje) - SUM(PD01JE ) ,2)  ,'-.','-0.')                   C37  ,--合计应收1                            C37
            '                                '                                                         C38             ,--收费方式                C38
            '                                '                                                         C39             ,--水费明细3               C39
           '                                '                                                     C40             ,--预存发生明细            C40
            tools.fuppernumber(  sum(pdje) - SUM(PD01JE ) )                                C41             ,--应收金额大写           C41
            '加减水量    :' || tools.fformatnum(SUM(RLADDSL), 0)  C42             ,--备注           C42
            '                                '                                                      C43             ,--应缴滞纳金3           C43
            '                                '                                                        C44             ,--实缴滞纳金4           C44
            '                                '           C45             ,--应缴水费5           C45
            '                                '   C46             ,--实缴水费6           C46
           ''                                                     C47             ,--用户预留字段7           C47
         fgetopername(  MAX(ppayee)  )                                               C48             ,--用户预留字段8           C48
          F_chargeinvsearch_recmx_ocx1(PBATCH,max(pmid),'3',2)                                                         C49            ,--用户预留字段9           C49
          F_chargeinvsearch_recmx_ocx1(PBATCH,max(pmid),'3',3)                                                         C50             ,--用户预留字段10          C50
          F_chargeinvsearch_recmx_ocx1(PBATCH,max(pmid),'3',4)                                                             C51             ,--应收账流水号            C51
          F_chargeinvsearch_recmx_ocx1(PBATCH,max(pmid),'3',5)                            C52             ,--费用项目                C52
           '                                '                                                                C53             ,--打印员编号              C53
          '                                '                                                       C54             ,--收费员              C54
         TO_CHAR( SUM(PD01JE ) )                                                                C55             ,--序号                    C55
          '                                '            C56             ,--系统预留字段1           C56
           '                                '                                                      C57             ,--系统预留字段2           C57
           '                                '                                                        C58             ,--系统预留字段3           C58
           (case when  p_ifbd='Y' THEN '补 '||to_char(sysdate,'yyyy-mm-dd') else ''  END )                                                         C59             ,--系统预留字段4           C59
          pbatch                                                       C60              --系统预留字段5           C60

from
(
SELECT max(rlmcode||'/'||rlcname||'/'||rlcadr||'/'||
              rlmadr||'/'||rlmonth||'/'||RLBFID||'/'||rlsmfid) cminfo,max(pmid) pmid,
min(rlscode) rlscode,max(rlecode) rlecode,max(rlsl) rlsl,max(RLADDSL) RLADDSL,MIN(RLDATE) RLDATE, MIN(RLRDATE) RLRDATE,
max(ppayee) ppayee,sum(pdje) pdje, sum(pdznj) pdznj , max(PLSAVINGBQ ) PLSAVINGBQ,
max(PLSAVINGQC) PLSAVINGQC,max(PLSAVINGQm) PLSAVINGQm, max(pdatetime) pdatetime ,
MAX(PID) PID,MAX(ptrans) ptrans,
max(psavingqc ) psavingqc ,max(psavingbq ) psavingbq  ,max(psavingqm ) psavingqm  ,
max(ppayment ) ppayment  ,max(pchange ) pchange ,max(pcd) pcd,max(pbatch)  pbatch,
F_chargeinvsearch_sqmaving_ocx(max(pbatch),max(pmid)) qcsaving,
F_chargeinvsearch_yc_ocx(max(pbatch),max(pmid)) yc,
SUM(CASE WHEN PDPIID='01' AND MIIFTAX='Y'  THEN DECODE(PLCD,'DE',1,-1)*PDJE ELSE 0 END) PD01JE,
max(mibfid) mibfid,max(mismfid) mismfid,max(mistatus) mistatus
   from payment,paidlist,paiddetail,reclist,meterinfo
   where pid=plpid and
         plid=pdid and
         plrlid=rlid and
         pmid=miid AND
         pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         (p_plid is null or p_plid=plid) and
         p_printtype ='Z'
         group by plid
)
group by pbatch,pmid




---------------------------------------------------------------------------------
UNION
--合票(销帐预存)
            select
        tools.fmid( max(cminfo),1,'N','/')                           C1              ,--资料号                  C1
        tools.fmid( max(cminfo) ,2,'N','/')                         C2              ,--户名                    C2
        tools.fmid( max(cminfo),3,'N','/')                                 C3              ,--用户地址                C3
            '上月抄表数  :'||to_char(min(rlscode ) )     C4              ,--抄表起码                C4
            '本月抄表数  :'||to_char(max(rlecode ) )     C5              ,--抄表止码                C5
            '实际用量    :'||to_char(sum(rlsl )     )       C6              ,--应收水量                C6
            to_char(SYSDATE,'yyyy-mm-dd')              C7              ,--打印日期                C7
            fGetOperName(P_PRINTER)                     C8              ,--打印员                  C8
           fgetopername(   max(ppayee)  )                                        C9              ,--收费员                  C9
            ''              C10             ,--合计金额大写            C10
            '实收金额:'|| tools.fformatnum(sum(pdje)+sum(pdznj)+sum(PLSAVINGBQ ) + max(YC) - nvl(SUM(PD01JE),0) ,2)                    C11             ,--合计金额                C11
           F_chargeinvsearch_recmx_ocx1(PBATCH,null,'2',1)               C12             ,--水费明细1               C12
           '                                '                           C13             ,--水费明细2               C13
            to_char(sysdate ,'yyyy')              C14             ,--系统时间年              C14
            to_char(sysdate ,'mm')                                             C15             ,--系统时间月              C15
            to_char(sysdate ,'dd')                                             C16             ,--系统时间日              C16
            max(pbatch )                                                            C17             ,----缴费交易批次,系统时间月           C17
            ''                                                                C18             ,----实收帐明细流水号      C18
            '                                '                                                            C19             ,--销帐流水流水号          C19
            to_char(max(pdatetime),'yyyy-mm-dd')                 C20             ,--票务日期 /*票务日期*/   C20
           '                                '                                                        C21             ,--水表编号                C21
            '                                '                                                       C22             ,--用户编号                C22
            ''                                                         C23             ,--应收账月份                  C23
            tools.fmid( max(cminfo) ,3,'N','/')                                                           C24             ,--水表安装地址            C24
            tools.fmid( max(cminfo) ,6,'N','/')                                                        C25             ,--表册号                  C25
           '抄表员：'||    max(FGETBFRPER_smfid(mibfid,mismfid))||max(case when mistatus in ('13','21') then '  电话：'||FGETBFRPERtel_smfid(mibfid,mismfid) else '' end)                                                          C26             ,--抄表员              C26
            to_char(SYSDATE,'yyyy-mm-dd')                                                        C27             ,--制据日期                C27
            ''                  C28             ,--应收单价                C28
            ''                                      C29             ,--水费金额                C29
            '                                '                                                         C30             ,--余量                    C30
          '违约金:'||replace( tools.fformatnum( sum(pdznj)  ,2) ,'-.','-0.')            C31             ,--滞纳金                  C31
           '                                '                                                        C32             ,--手续费                  C32
           '                                '                                                      C33             ,--上期抄表日期    （本次交钱）        C33
           '上次结余:'||   replace( tools.fformatnum(max(qcsaving),2)   ,'-.','-0.')                                                    C34             ,--抄表日期  (上次结余)             C34
           '本次结余:'||   tools.fformatnum( max(qcsaving) + SUM(PLSAVINGBQ ) + max(YC) ,2)                                                     C35             ,--账务日期 (本次结余)               C35
            '本月抄表日期:'||MAX(to_char(RLRDATE,'yyyy-mm-dd'))                                                         C36             ,--抄表月份                C36
        replace(  tools.fformatnum(  sum(pdje) - SUM(PD01JE ) ,2)  ,'-.','-0.')                   C37  ,--合计应收1                            C37
            '                                '                                                         C38             ,--收费方式                C38
            '                                '                                                         C39             ,--水费明细3               C39
           '                                '                                                     C40             ,--预存发生明细            C40
            tools.fuppernumber(  sum(pdje) - SUM(PD01JE ) )                                C41             ,--应收金额大写           C41
            '加减水量    :' || tools.fformatnum(SUM(RLADDSL), 0)  C42             ,--备注           C42
            '                                '                                                      C43             ,--应缴滞纳金3           C43
            '                                '                                                        C44             ,--实缴滞纳金4           C44
            '                                '           C45             ,--应缴水费5           C45
            '                                '   C46             ,--实缴水费6           C46
           ''                                                     C47             ,--用户预留字段7           C47
         fgetopername(  MAX(ppayee)  )                                               C48             ,--用户预留字段8           C48
        F_chargeinvsearch_recmx_ocx1(PBATCH,null,'2',2)                                                        C49            ,--用户预留字段9           C49
        F_chargeinvsearch_recmx_ocx1(PBATCH,null,'2',3)                                                       C50             ,--用户预留字段10          C50
        F_chargeinvsearch_recmx_ocx1(PBATCH,null,'2',4)                                                           C51             ,--应收账流水号            C51
        F_chargeinvsearch_recmx_ocx1(PBATCH,null,'2',5)                         C52             ,--费用项目                C52
           '                                '                                                                C53             ,--打印员编号              C53
          '                                '                                                       C54             ,--收费员              C54
         TO_CHAR( SUM(PD01JE ) )                                                                C55             ,--序号                    C55
          '                                '            C56             ,--系统预留字段1           C56
           '                                '                                                      C57             ,--系统预留字段2           C57
           '                                '                                                        C58             ,--系统预留字段3           C58
           (case when  p_ifbd='Y' THEN '补 '||to_char(sysdate,'yyyy-mm-dd') else ''  END )                                                         C59             ,--系统预留字段4           C59
          pbatch                                                       C60              --系统预留字段5           C60

from
(
SELECT max(rlmcode||'/'||rlcname||'/'||rlcadr||'/'||
              rlmadr||'/'||rlmonth||'/'||RLBFID||'/'||rlsmfid) cminfo,
min(rlscode) rlscode,max(rlecode) rlecode,max(rlsl) rlsl,max(RLADDSL) RLADDSL,MIN(RLDATE) RLDATE, MIN(RLRDATE) RLRDATE,
max(ppayee) ppayee,sum(pdje) pdje, sum(pdznj) pdznj , max(PLSAVINGBQ ) PLSAVINGBQ,
max(PLSAVINGQC) PLSAVINGQC,max(PLSAVINGQm) PLSAVINGQm, max(pdatetime) pdatetime ,
MAX(PID) PID,MAX(ptrans) ptrans,
max(psavingqc ) psavingqc ,max(psavingbq ) psavingbq  ,max(psavingqm ) psavingqm  ,
max(ppayment ) ppayment  ,max(pchange ) pchange ,max(pcd) pcd,max(pbatch)  pbatch,
F_chargeinvsearch_sqmaving_ocx(max(pbatch),null) qcsaving,
F_chargeinvsearch_yc_ocx(max(pbatch),null) yc,
SUM(CASE WHEN PDPIID='01' AND MIIFTAX='Y'  THEN DECODE(PLCD,'DE',1,-1)*PDJE ELSE 0 END) PD01JE ,
max(mibfid) mibfid,max(mismfid) mismfid ,max(mistatus ) mistatus
  from payment,paidlist,paiddetail,reclist,meterinfo
   where pid=plpid and
         plid=pdid and
         plrlid=rlid and
         pmid=miid AND
         pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         (p_plid is null or p_plid=plid) and
         p_printtype ='H'
         group by plid
)
group by pbatch


order by c60
)
order by c60
 ;

begin
sp_fchargeinvsearch_fp_ocx(
p_pbatch  , --实收批次
P_PID   ,--实收流水(不空按实收流水打印)
p_plid  ,--实收明细流水(不空按实收明细流水打印)
p_modelno  , --发票格式号:2/25
p_printtype  , --合票:H/分票:F /按户汇总发票 Z
p_ifbd   , --是否补打 --是:Y,否:N
P_PRINTER  --打印员
)  ;
SP_PRINTINV_OCX( p_pbatch ,p_printtype ) ;

open c_hd   ;
  fetch c_hd
    into v_constructhd,v_constructdt,v_contentstrorder;
  null;
close c_hd;

I := 1 ;
v_conlen := 0 ;
DELETE PRINTLISTTEMP;
    open c_dt   ;
    loop
      fetch c_dt
        into V_C1       ,
V_C2       ,
V_C3       ,
V_C4       ,
V_C5       ,
V_C6       ,
V_C7       ,
V_C8       ,
V_C9       ,
V_C10      ,
V_C11      ,
V_C12      ,
V_C13      ,
V_C14      ,
V_C15      ,
V_C16      ,
V_C17      ,
V_C18      ,
V_C19      ,
V_C20      ,
V_C21      ,
V_C22      ,
V_C23      ,
V_C24      ,
V_C25      ,
V_C26      ,
V_C27      ,
V_C28      ,
V_C29      ,
V_C30      ,
V_C31     ,
V_C32      ,
V_C33      ,
V_C34      ,
V_C35      ,
V_C36      ,
V_C37      ,
V_C38      ,
V_C39      ,
V_C40      ,
V_C41      ,
V_C42      ,
V_C43      ,
V_C44      ,
V_C45      ,
V_C46      ,
V_C47      ,
V_C48      ,
V_C49     ,
V_C50      ,
V_C51       ,
V_C52    ,
V_C53      ,
V_C54         ,
V_C55      ,
V_C56      ,
V_C57      ,
V_C58      ,
V_C59      ,
V_C60
;
      exit when c_dt%notfound or c_dt%notfound is null;
     select replace(
connstr(
  trim(v_c1  )||'^'
||trim(v_c2  )||'^'
||trim(v_c3  )||'^'
||trim(v_c4  )||'^'
||trim(v_c5  )||'^'
||trim(v_c6  )||'^'
||trim(v_c7  )||'^'
||trim(v_c8  )||'^'
||trim(v_c9  )||'^'
||trim(v_c10 )||'^'
||trim(v_c11 )||'^'
||trim(v_c12 )||'^'
||trim(v_c13 )||'^'
||trim(v_c14 )||'^'
||trim(v_c15 )||'^'
||trim(v_c16 )||'^'
||trim(v_c17 )||'^'
||trim(v_c18 )||'^'
||trim(v_c19 )||'^'
||trim(v_c20 )||'^'
||trim(v_c21 )||'^'
||trim(v_c22 )||'^'
||trim(v_c23 )||'^'
||trim(v_c24 )||'^'
||trim(v_c25 )||'^'
||trim(v_c26 )||'^'
||trim(v_c27 )||'^'
||trim(v_c28 )||'^'
||trim(v_c29 )||'^'
||trim(v_c30 )||'^'
||trim(v_c31 )||'^'
||trim(v_c32 )||'^'
||trim(v_c33 )||'^'
||trim(v_c34 )||'^'
||trim(v_c35 )||'^'
||trim(v_c36 )||'^'
||trim(v_c37 )||'^'
||trim(v_c38 )||'^'
||trim(v_c39 )||'^'
||trim(v_c40 )||'^'
||trim(v_c41 )||'^'
||trim(v_c42 )||'^'
||trim(v_c43 )||'^'
||trim(v_c44 )||'^'
||trim(v_c45 )||'^'
||trim(v_c46 )||'^'
||trim(v_c47 )||'^'
||trim(v_c48 )||'^'
||trim(v_c49 )||'^'
||trim(v_c50 )||'^'
||trim(v_c51 )||'^'
||trim(v_c52 )||'^'
||trim(v_c53 )||'^'
||trim(v_c54 )||'^'
||trim(v_c55 )||'^'
||trim(v_c56 )||'^'
||trim(v_c57 )||'^'
||trim(v_c58 )||'^'
||trim(v_c59 )||'^'
||trim(v_c60 )
||'|' )
,'|/','|') into v_tempstr   from dual;
     I := I + 1;
     v_conlen :=v_conlen +  lengthb( v_tempstr ) ;
    INSERT INTO PRINTLISTTEMP VALUES (I,v_tempstr);
    end loop;
    close c_dt;
    v_hd :=  trim(to_char(lengthb( v_constructhd||v_constructdt ),'0000000000'))||
        trim(to_char(lengthb( v_contentstrorder )  + v_conlen,'0000000000'))||
        v_constructhd||
        v_constructdt||
        v_contentstrorder  ;
     INSERT INTO PRINTLISTTEMP VALUES (1,v_hd);


  end ;
/

