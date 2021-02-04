CREATE OR REPLACE PROCEDURE HRBZLS."SP_FCHARGEINVSEARCH_FP_OCX1" (
p_pbatch in varchar2, --实收批次
P_PID IN varchar2 ,--实收流水(不空按实收流水打印)
p_plid in varchar2,--实收明细流水(不空按实收明细流水打印)
p_modelno in varchar2, --发票格式号:2/25
p_printtype in varchar2, --合票:H/分票:F /按户汇总发票 Z
p_ifbd in varchar2, --是否补打 --是:Y,否:N
P_PRINTER IN VARCHAR2 --打印员
) is
V_COUNT NUMBER(10);
v_pidstr varchar2(1000);
v_PID varchar2(1000);
v_PMID varchar2(1000);
v_PTRANS  varchar2(1000);
v_plid  varchar2(1000);
v_ycje NUMBER(13,3);
begin
null;
delete PBPARMNNOCOMMIT_PRINT_gt;
if p_printtype='F' THEN
insert into PBPARMNNOCOMMIT_PRINT_gt
( c1    ,
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
c60   ,
C61   ,
C62   ,
C63   ,
C64   ,
C65
 )


--分票(销帐)
            select
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
            replace( tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) - SUM(CASE WHEN MIIFTAX='Y' AND PDPIID='01'  THEN   PDJE  ELSE 0 END)  ,2)   ,'-.','-0.')                  C11             ,--合计金额                C11
           F_chargeinvsearch_recmx_ocx(plid,null,'1')                C12             ,--水费明细1               C12
           '                                '                           C13             ,--水费明细2               C13
            to_char(sysdate ,'yyyy')              C14             ,--系统时间年              C14
            to_char(sysdate ,'mm')                                             C15             ,--系统时间月              C15
            to_char(sysdate ,'dd')                                             C16             ,--系统时间日              C16
            max(pbatch )                                                            C17             ,----缴费交易批次,系统时间月           C17
            max(pid)                                                                C18             ,----实收帐明细流水号      C18
            '                                '                                                            C19             ,--销帐流水流水号          C19
            to_char(max(pdatetime),'yyyy-mm-dd')                 C20             ,--票务日期 /*票务日期*/   C20
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
             replace( tools.fformatnum(max(PLSAVINGQM), 2)   ,'-.','-0.')                                                    C35             ,--账务日期 (本次结余)               C35
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
          MAX(pbatch)|| pid||plid                                                    C60      ,          --系统预留字段5           C60
            MAX(pbatch),
          pid,
          plid,
          MAX(PMID),
          MAX(PCID)
    from payment,paidlist,paiddetail,reclist ,meterinfo
   where pid=plpid and
         plid=pdid and
         plrlid=rlid and
         pmid=miid   AND
         pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         (p_plid is null or p_plid=plid) and
         p_printtype ='F'
         group by plid,pid ;

  SELECT COUNT(*) INTO V_COUNT FROM PAYMENT T WHERE PBATCH=p_pbatch AND PTRANS<>'S';
IF V_COUNT>0 THEN
  SELECT MAX(PID||'@'||PMID||PTRANS||  (ppayment - pchange )   ) into v_pidstr
   FROM PAYMENT T WHERE PBATCH=p_pbatch;
  v_pid :=substr(v_pidstr,1,10 ) ;
  v_PMID :=substr(v_pidstr,12,10 ) ;
  v_PTRANS :=substr(v_pidstr,22,1 ) ;
  v_ycje :=to_number( substr(v_pidstr,23 ) ) ;
  if v_PTRANS='S' THEN
  begin
  SELECT MAX(PlID ) into v_plid
   FROM PAYMENT T,paidlist t1 WHERE pid=plpid
   and  PBATCH=p_pbatch /*and pmid=v_PMID*/ ;
  exception when others then
  raise_application_error(-20010,'打票异常');
  end;

UPDATE PBPARMNNOCOMMIT_PRINT_gt
  SET c11=   replace(  tools.fformatnum(  to_number(c11) +  v_ycje ,2) ,'-.','-0.')     ,
      c35=    replace(  tools.fformatnum(   to_number(c35) + v_ycje,2 ) ,'-.','-0.')
  WHERE c63=v_plid ;
    END IF;
  UPDATE PBPARMNNOCOMMIT_PRINT_gt
  SET c11= '实收金额:'|| c11    ,
      c35=  '本次结余:'||c35 ;
ELSE
 insert into PBPARMNNOCOMMIT_PRINT_gt
( c1    ,
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
c60   ,
C61   ,
C62   ,
C63   ,
C64   ,
C65
 )
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
            to_char(max(pdatetime) ,'yyyy-mm-dd')                  C20             ,--票务日期 /*票务日期*/   C20
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
           MAX(PBATCH)|| PID                                                         C60   ,           --系统预留字段5           C60
           MAX(PBATCH) ,
           PID,
            '',
          MAX(PMID),
          MAX(PCID)
   from payment , custinfo,METERINFO
   where  pmid=miid and
         pcid=ciid and
        pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         PTRANS ='S' AND
         p_printtype ='F'
         group by PID
         HAVING sum( decode(pcd,'DE',1,-1)*(ppayment -pchange))<>0 ;
      END IF;
END IF;
end;
/

