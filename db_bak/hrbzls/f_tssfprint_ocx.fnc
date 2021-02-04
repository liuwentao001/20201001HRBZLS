CREATE OR REPLACE FUNCTION HRBZLS."F_TSSFPRINT_OCX" (p_rlid in varchar2,p_batch in varchar2,p_modelno in varchar2)  return varchar2  is

v_invprintstr varchar2(32767);
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
 trim(托收批次号  )||'^'
||trim(托收凭证号 )||'^'
||trim(年  )||'^'
||trim(月  )||'^'
||trim(日  )||'^'
||trim(打印日期  )||'^'
||trim(应收帐日期  )||'^'
||trim(收款方式  )||'^'
||trim(客户代码  )||'^'
||trim(用户名 )||'^'
||trim(水表地址 )||'^'
||trim(表册号 )||'^'
||trim(电话 )||'^'
||trim(抄表员 )||'^'
||trim(抄表月份标题 )||'^'
||trim(应收月份 )||'^'
||trim(起码标题 )||'^'
||trim(起码 )||'^'
||trim(止码标题 )||'^'
||trim(止码 )||'^'
||trim(水量标题 )||'^'
||trim(水量 )||'^'
||trim(单价标题)||'^'
||trim(单价 )||'^'
||trim(水费标题 )||'^'
||trim(水费 )||'^'
||trim(水费大写 )||'^'
||trim(金额 )||'^'
||trim(金额大写 )||'^'
||trim(c2 )||'^'
||trim(c3 )||'^'
||trim(备注 )||'^'
||trim(打印员中文 )||'^'
||trim(预留1 )||'^'
||trim(预留2 )||'^'
||trim(预留3 )||'^'
||trim(预留4 )||'^'
||trim(预留5 )||'^'
||trim(预留6 )||'^'
||trim(预留7 )||'^'
||trim(预留8 )||'^'
||trim(预留9 )||'^'
||trim(预留10)
||'|' )
,'|/','|') contentstr
from
(
 select
           max(etlbatch) 托收批次号, --托收批次号
           max(etlpzno) 托收凭证号, --托收凭证号
           max(to_char(eloutdate,'yyyy')) 年,
           max(to_char(eloutdate,'mm')) 月,
           max(to_char(eloutdate,'dd')) 日,
           max(to_char(eloutdate,'yyyy')||'/'||to_char(eloutdate,'mm')||'/'||to_char(eloutdate,'dd')) 打印日期,
           to_char(max(t0.rldate ),'yyyy')||'  '||to_char(max(t0.rldate ),'mm')||'  '||to_char(max(t0.rldate ),'dd') 应收帐日期,-- 应收帐日期
           '托收' 收款方式,
           max(t0.rlmcode) 客户代码 ,--客户代码
           max(t0.rlcname) 用户名 , --用户名
           max(t0.rlmadr)  水表地址 ,--水表地址
           max(RLBFID) 表册号,
           (case when trim(max(rltel)) is not null then 'tel:'||trim(max(rltel))
                when trim(max(rltel )) is  null and trim(max(rlmtel)) is not null  then 'tel:'||trim(max(rlmtel))
                else '' end) 电话,--电话
           max(RLRPER) 抄表员,
           '抄表月份'  抄表月份标题, --抄表月份标题
           max(substr(t0.rlmonth,1,4)||substr(t0.rlmonth,6,2)) 应收月份, --应收月份
           '起码' 起码标题,--起码标题
           max(t0.rlscodechar)  起码,--起码
           '止码' 止码标题,--止码标题
           max(t0.rlecodechar)  止码,--止码
           '水量' 水量标题,--水量标题
           max(t3.rdsl*RDPMDSCALE )    水量,--水量
           '单价' 单价标题,--单价标题
           sum(t3.rddj) 单价,--单价
           '水费' 水费标题,--水费标题
           sum(case when rdpiid='01' then t3.rdje else 0 end)  水费,--水费
           tools.fuppernumber(round(   sum(case when rdpiid='01' then t3.rdje else 0 end)  ,2)  ) 水费大写,--大写
           tools.fformatnum( round(   sum(t3.rdje)  ,2),2) 金额,--实收
           tools.fuppernumber(round(   sum(t3.rdje)  ,2)  ) 金额大写,--大写
           max('c2') c2,--打印员编号
           max('c3') c3, --顺序号
           '正常抄表' 备注,
           fgetopername( max('c2')) 打印员中文,--打印员中文
           '预留1' 预留1,--预留1
           '预留2' 预留2,--预留2
           '预留3' 预留3,--预留3
           '预留4' 预留4,--预留4
           '预留5' 预留5,--预留5
           '预留6' 预留6,--预留6
           '预留7' 预留7,--预留7
           1 预留8,--预留8
           1 预留9,--预留9
           1 预留10--预留10

    from reclist t0,
         recdetail t3,
         entrustlist t,
         entrustlog  t1/*,
         pbparmtemp  t2*/
   where
        t0.rlid=p_rlid
      /*t0.rlid = c5*/
      and t0.rlentrustseqno= etlseqno
      and t0.rlid=t3.rdid
      --and t3.rdpiid='01'
      and t1.elbatch=t.etlbatch
      and etlseqno = p_batch
      --and  c4 = etlseqno
      group by rlid
           order by c3
          )
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

