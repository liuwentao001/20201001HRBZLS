CREATE OR REPLACE PROCEDURE HRBZLS."SP_FCHARGEINVSEARCHHP_MX_OCX" (
p_batch in varchar2,
p_modelno in varchar2)  is
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
          tools.fuppernumber(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ))                 C10             ,--合计金额大写            C10
            '￥'||/*tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) ,2)*/ tools.fformatnum(max(rlje),2)                  C11             ,--合计金额                C11
            fGetPriceText_gtmx(plid)                C12             ,--水费明细1               C12
                   case when  sum(case when pdpiid ='08' then  pdje else 0 end )<>0 then '垃圾费:     ￥'||to_char(round(sum(case when pdpiid ='08' then  pdje else 0 end ),2),'99.00')     else '' end                     C13             ,--水费明细2               C13
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
            fgetunitprice_mx_wzzls(max(rlid))                                                   C28             ,--应收单价                C28
            fGetUnitMoney_gtmx(plid)                                      C29             ,--水费金额                C29
            '暂无启用'                                                         C30             ,--余量                    C30
              case when sum(pdznj)=0 then '0.00' else TO_CHAR( sum(pdznj),'9990.00') end                                                      C31             ,--滞纳金                  C31
         '总计:'|| TO_CHAR( SUM(pdje)+sum(pdznj ),'9999999.00')                                                         C32             ,--手续费                  C32
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
                when max(RLTRANS)='O' then
              '追量收费'
             when sum(RLECODE - RLSCODE) <> sum(RLREADSL) then
              '调表'

             else
              '正常抄表'
           end                                                           C42             ,--备注           C42
            '应缴滞纳金:'||tools.fformatnum(max(PLZNJ),2)                                                       C43             ,--应缴滞纳金3           C43
            '实缴滞纳金:'||tools.fformatnum(max(PLZNJ),2)                                                         C44             ,--实缴滞纳金4           C44
            '应缴水费:'||tools.fformatnum(max(plje)+max(PLZNJ)-max(PLSAVINGQC),2)                                                        C45             ,--应缴水费5           C45
            '实缴水费:'||/*tools.fformatnum(max(PLJE),2)*/tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) ,2)                                                        C46             ,--实缴水费6           C46
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
            '￥'||tools.fformatnum(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)) ,2)                    C11             ,--合计金额                C11
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

order by c55 ,c60
 ;

begin

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
V_C31      ,
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
V_C49      ,
V_C50      ,
V_C51      ,
V_C52      ,
V_C53      ,
V_C54      ,
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

