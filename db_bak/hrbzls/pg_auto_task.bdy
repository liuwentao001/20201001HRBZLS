CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_AUTO_TASK AS


/*--------------------------------------------------------
名称：后台任务设置
功能：根据定义表中内容，设置后台任务
--------------------------------------------------------*/
PROCEDURE 单任务设置(P_ID in NUMBER ,p_msg out varchar2)  as
  
v_step number;
V_TASK JOB_LIST%ROWTYPE;
V_NEXT DATE;
IN_RUNNING EXCEPTION;

begin
  v_step:=1;
  
  --取任务定义资料
  SELECT T.* INTO V_TASK
  FROM JOB_LIST T 
  WHERE T.ID=P_ID;
  
  --该任务是否运行中
  If V_TASK.上次运行状况='Y' THEN
    RAISE IN_RUNNING;
  END if ;
 
  --如任务已定义，则移除该任务。
  BEGIN
    dbms_job.remove(V_TASK.ID);
    commit;
  EXCEPTION 
      WHEN OTHERS THEN
        p_msg:='无法移除任务！';
  END;
  --组织下次运行时间
  V_NEXT:=to_date(V_TASK.下次运行日期||' '|| V_TASK.任务运行时间,'yyyy/mm/dd hh24:mi:ss');  
   
  --提交任务              
  dbms_job.isubmit(V_TASK.ID, V_TASK.任务内容,V_NEXT,V_TASK.运行间隔,TRUE);
  commit;
  p_msg:='建立成功！';
EXCEPTION 
  WHEN NO_DATA_FOUND THEN
    p_msg:='无效的任务编号！';
  WHEN IN_RUNNING THEN
    p_msg:='任务运行中，无法修改！';      
  WHEN OTHERS THEN
    p_msg:='无法建立指定任务！';   

end 单任务设置;

/*--------------------------------------------------------
名称：任务运行注册
功能：在任务表中置运行标志
--------------------------------------------------------*/
PROCEDURE 状态注册(p_id varchar2) as

begin
  update JOB_LIST t
  set t.运行标志='Y'
  WHERE T.ID=p_id;
  
  COMMIT;
end 状态注册;

/*--------------------------------------------------------
名称：任务运行注销
功能：在任务表中置运行结束标志
--------------------------------------------------------*/
PROCEDURE 状态注销(p_id varchar2) as

begin
  update JOB_LIST t
  set t.运行标志='N'
  WHERE T.ID=p_id;
  
  COMMIT;
end 状态注销;
/*--------------------------------------------------------
名称：ISRUNNING取任务运行状态
功能：取任务运行状态
--------------------------------------------------------*/
  FUNCTION ISRUNNING(p_id varchar2) return varchar2 as
    
 v_flag varchar2(10);
 
 begin
   v_flag:='N';
   select t.运行标志 into v_flag
   from JOB_LIST t
   WHERE T.ID=p_id;
   
   return v_flag;
   
 exception 
   when others then
      return v_flag;
         
 end;
/*--------------------------------------------------------
名称：月结任务
功能：执行月结相关事务的过程在此调用
执行时间：每月的倒数第二天，晚上21:00
--------------------------------------------------------*/
procedure 月结任务(p_id varchar2) as
  
v_step number;
IN_RUNNING EXCEPTION;

begin
  --如果任务已经在运行，则直接结束
  if ISRUNNING(p_id)='Y' THEN
    RAISE IN_RUNNING;
  END IF;    
  
  状态注册(p_id);
  
  v_step:=1;
  null;
   --其他的同类事务放置于此 
  状态注销(p_id);
EXCEPTION
   WHEN IN_RUNNING THEN 
     v_step:=9;
   WHEN OTHERS THEN  
     状态注销(p_id);
     
end 月结任务;
/*--------------------------------------------------------
名称：月末任务
功能：执行月结相关事务的过程在此调用
执行时间：每月最后一天，晚上23:00
--------------------------------------------------------*/
procedure 月末任务(p_id varchar2) as
  
v_step number;
IN_RUNNING EXCEPTION;
 
begin
  --如果任务已经在运行，则直接结束
  if ISRUNNING(p_id)='Y' THEN
    RAISE IN_RUNNING;
  END IF;    
  
  状态注册(p_id);
  
  v_step:=1; 
   
    --月底自动月结
    pg_ewide_job_hrb.月末自动预存抵扣;
    
    
   
  状态注销(p_id);
EXCEPTION
   WHEN IN_RUNNING THEN 
     v_step:=9;
   WHEN OTHERS THEN  
     状态注销(p_id);
 
     
end 月末任务;

/*--------------------------------------------------------
名称：日结任务
功能：执行每天需要结转的相关事务
执行时间：每天凌晨01:00
--------------------------------------------------------*/
procedure 日结任务(p_id varchar2) as
  
v_step number;
v_dd   number;
IN_RUNNING EXCEPTION;

begin
  --如果任务已经在运行，则直接结束
  --if ISRUNNING(p_id)<>'Y' THEN
  if ISRUNNING(p_id)='Y' THEN
    RAISE IN_RUNNING;
  END IF;    
  
  状态注册(p_id);
  v_step:=1;
  --20160130
  UPDATE sysmanapara
  set SMPPTYPE ='N' 
   WHERE SMPPID='SOURCE' ;
   
  --综合月报，中间表生成
 PG_EWIDE_REPORTSUM_HRB.综合月报(to_char(TRUNC(SYSDATE - 1),'yyyy.mm') );

  v_step:=2;
  --工作验证码生成  
  PG_EWIDE_JOB_HRB.验证码;
  
  --其他的同类事务放置于此
  清抄表月结标志;
  
    --每月欠费明细产生 add 20141101  
  sp_欠费中间表;
  
  -- 财务与银行对账每天晚上执行前一天的20141212
  pro_财务对账银行;
 
  -- gis数据生成
  select to_number(to_char(sysdate, 'dd' ))into v_dd from dual;
  if v_dd=15 then
    PG_EWIDE_REPORTSUM_HRB.gis数据生成;
       
  end if;
  
      
  状态注销(p_id);
EXCEPTION
   WHEN IN_RUNNING THEN 
     v_step:=9;
   WHEN OTHERS THEN  
     状态注销(p_id);
       
end 日结任务;

/*--------------------------------------------------------
名称：当天日结任务
功能：执行每天需要结转的相关事务
执行时间：每天22:00
--------------------------------------------------------*/
procedure 当天日结任务(p_id varchar2) as
  
v_step     number;
v_appcode  number;
v_error    varchar2(500);
IN_RUNNING EXCEPTION;

begin
  --如果任务已经在运行，则直接结束
  --if ISRUNNING(p_id)<>'Y' THEN
  if ISRUNNING(p_id)='Y' THEN
    RAISE IN_RUNNING;
  END IF;    
  
  状态注册(p_id);
  v_step:=1;
      -- 每天自动清除sys_host表记录之前添加历史记录备份 add 20150311
    INSERT INTO SYS_HOST_HIS(ip, login_user, host_name, log_date, ip1, os_user)
    SELECT ip, login_user, host_name, log_date, ip1, os_user FROM SYS_HOST ;
      -- 每天自动清除sys_host表记录 add 20140902
    delete from sys_host;
    commit; 
   v_step:=2;
     --检查2   
    --每天 检查财务到账确认异常资料,如果有异常资料则更新. add 20140903
    pro_财务到账确认异常资料更新; 
    commit; 

   v_step:=3;
     --抄表月结本月倒数第二天做 
    if  to_char( TRUNC(LAST_DAY(SYSDATE)-1),'yyyymmdd')= to_char(SYSDATE,'yyyymmdd' )  then 
         pg_ewide_job_hrb.抄表月结;  --抄表月结
        commit; 
/*        
       pg_ewide_job_hrb.月初处理;   --月结之后再做 自动月初处理 add hb 20141121 营销部提出需求
        commit; 
        delete from  meterinfo_sjcbup ; --add hb 20150421 每次做完抄表月初.删除手机抄表需要更新的资料,因抄表员需月初自动下载数据，下载之后数据是最新的
        commit;
 */
    end if ;
    /*     v_step:=4;
       -- 用户基本信息中间表产生 --20150121 add hb
    pro_auto_rpt_sum_report ;*/
    commit;
    v_step:=5;
   -- if  to_char( TRUNC(LAST_DAY(SYSDATE)-1),'yyyymmdd') > to_char(SYSDATE,'yyyymmdd' )  then 
    PRO_抄表情况统计_hrb; 
    commit; 
  --  end if ;
    
    --基建预存余额调拨统计 月末结转 (每个月最后一天执行)
    if trunc(last_day(sysdate)) = trunc(sysdate) then
       pg_ewide_job_hrb2.prc_rpt_allot_carryOver( to_char(add_months(sysdate,-1),'yyyy.mm'),
                                                  v_appcode,
                                                  v_error);
       if v_appcode > 0 then
          commit;
       end if;     
       
       pg_ewide_job_hrb2.prc_rpt_allot_sum( to_char(sysdate,'yyyy.mm'),
                                            v_appcode,
                                            v_error      
       );
       if v_appcode > 0 then
          commit;
       end if;                                                          
    end if;
  
  状态注销(p_id);
EXCEPTION
   WHEN IN_RUNNING THEN 
     v_step:=9;
   WHEN OTHERS THEN  
     状态注销(p_id);
       
end 当天日结任务;

/*--------------------------------------------------------
名称：自动账务处理
功能：每天自动执行账务相关处理
执行时间：每天凌晨01:00      
--------------------------------------------------------*/
  PROCEDURE 自动账务处理(p_id varchar2) AS
    
v_step number;
IN_RUNNING EXCEPTION;

begin
  --如果任务已经在运行，则直接结束
  if ISRUNNING(p_id)='Y' THEN
    RAISE IN_RUNNING;
  END IF;    
  
  状态注册(p_id);
  v_step:=1;
  --每天凌晨1点检查昨日银行是否扎帐，如果未扎帐则自动扎帐
  zhongbe.sp_autobankzz;

  v_step:=2;
 --抄表月结本月最后一天早上进行处理 
  if  to_char( TRUNC(LAST_DAY(SYSDATE) ),'yyyymmdd')= to_char(SYSDATE,'yyyymmdd' )  then 
/*      select  mrsmfid, min(MRDAY) from meterread    where mrmonth='2015.06'  --七月检查一次语法
        group by mrsmfid
        order by mrsmfid*/
      --pg_ewide_job_hrb.月初处理; 放到月底最后一天凌晨1:00去做，写在【自动账务处理】 modi hb  2015/06/02 因有些营业所跨12点未执行。
			
        --pg_ewide_job_hrb.月初处理;   --月结之后再做 自动月初处理 add hb 20141121 营销部提出需求
				pg_ewide_job_hrb.prc_monthlyInit;
				
        commit; 
      
			  delete from  meterinfo_sjcbup ; --add hb 20150421 每次做完抄表月初.删除手机抄表需要更新的资料,因抄表员需月初自动下载数据，下载之后数据是最新的
        commit;
    end if ;
    状态注销(p_id);
  EXCEPTION
   WHEN IN_RUNNING THEN 
     v_step:=9;
   WHEN OTHERS THEN  
     状态注销(p_id); 
  END 自动账务处理;
    
  
/*--------------------------------------------------------
名称：账务检查
功能：每天执行所有和账务正确性相关的检查
      检查结果能够在客户端反馈出来
执行时间：每天凌晨03:00      
--------------------------------------------------------*/
procedure 账务检查(p_id varchar2) as

v_step number;
IN_RUNNING EXCEPTION;

begin
  --如果任务已经在运行，则直接结束
  if ISRUNNING(p_id)='Y' THEN
    RAISE IN_RUNNING;
  END IF;    
  
  状态注册(p_id);
  v_step:=1;

  v_step:=2;
  --检查2   
  
  状态注销(p_id);
EXCEPTION
   WHEN IN_RUNNING THEN 
     v_step:=9;
   WHEN OTHERS THEN  
     状态注销(p_id);   
end 账务检查;

/*--------------------------------------------------------
名称：清抄表月结标志
功能：在月底的一段时间内（大致22日至27日） ，清除抄表月结标志     
--------------------------------------------------------*/
PROCEDURE  清抄表月结标志 as
  V_NEWRUN varchar2(2);
begin
    --只有在月底执行抄表月结前一周才作此操作
    if sysdate< trunc(last_day(sysdate)-8) AND sysdate>=trunc(last_day(sysdate)-4) then
      goto do_nothing;
    end if;
     
    --清抄表月结标志，
    UPDATE  syspara t
    SET t.spvalue = 'N'
    where t.spid='YJBZ';
    
    COMMIT;

<<do_nothing>>    
    NULL;
end 清抄表月结标志; 


  --p_type 抄表方式 0-无线远传 1-集抄
  procedure 智能表平台抄表(p_type  varchar2) is
    v_handleId        varchar2(15);               
    v_miid            VARCHAR2(20);     
    V_COPY_ECODE      NUMBER;
    V_SUBMIT          VARCHAR2(2);
    V_MRIFSUBMIT      meterread.mrifsubmit%type;
    V_COPY_SL         NUMBER;    
    v_count           number;
    v_mrid            meterread.mrid%type;
    v_MRIFREC         meterread.MRIFREC%type;
    V_mrreadok        meterread.mrreadok%type;
    v_MRSMFID         meterread.MRSMFID%type;
    v_mistatus        meterinfo.mistatus%type; --用户状态
    v_MRTHREESL       meterread.MRTHREESL%type; --波动审核量
    v_mrchkresult     meterread.mrchkresult%type; --查表结果
    v_mrmonth         meterreadhis.mrmonth%type;
    v_ifdzsb          meterdoc.ifdzsb%type; --倒表设置 'Y'--为Y倒表
    v_MRSCODE         meterread.mrscode%type; --起始指针
    v_MRSL            meterread.mrsl%type; --抄表水量
    v_mrface          meterread.mrface%type; --表态
    v_MROUTFLAG       meterread.MROUTFLAG%type; --发出到抄表机标志
    v_MIPID           meterinfo.MIPID%type; --总表号码 3时为总表
    v_MIPRIID         meterinfo.MIPRIID%type; --合收主表号
    v_MIPRIFLAG       meterinfo.MIPRIFLAG%type; --合收表标志
    v_mipfid          meterinfo.mipfid%type; --水价类别
    v_mrdatasource    meterread.mrdatasource%type;
    v_MRCHKFLAG       meterread.MRCHKFLAG%type;
    v_MRCHKDATE       meterread.MRCHKDATE%type;
    v_MRCHKPER        meterread.MRCHKPER%type;
    v_mircode         meterinfo.mircode%type;
    v_mrsl1           number(10);
    v_sysdate     date;
    v_lastdate    date;
    --20160804
    v_mrdzflag    meterread.mrdzflag%type; --等针标志
    v_mrdzcurcode meterread.mrdzcurcode%type; --等针用户实际读数
    v_mrdzsl      meterread.mrdzsl%type; --等针用量
    v_miyl9       meterinfo.miyl9%type; --水表量程
    v_error       varchar2(200);
    cursor cur_local is
      select md.mdmid miid,
             yk.*
        from yk_meter_date yk, 
             meterdoc md       
       where yk.meter_code = md.mdno and
             HANDLEID = v_handleId;
  begin
    --抄表批次号
    v_handleId := to_char(sysdate,'yyyymmddhh24miss');
    --取接口数据到本地表
    insert into yk_meter_date
      (handleid, meter_code, meter_sn, meter_hand, meter_time, meter_man, meter_flag, switch_flag, meter_type, update_time, if_read)    
      select v_handleId,
             meter_code, 
             meter_sn, 
             meter_hand, 
             meter_time, 
             meter_man, 
             meter_flag, 
             switch_flag, 
             meter_type, 
             update_time, 
             if_read
        from v_yk_meter_date 
       where (meter_code,METER_TIME) in 
                (
                 select meter_code,max(meter_time) 
                   from v_yk_meter_date 
                  where METER_TYPE = p_type and
                        nvl(IF_READ,'0') = '0' and 
                        trunc(meter_time,'month') = trunc(sysdate,'month')  
                group by meter_code
                );
    
    
    insert into yk_interface_log
            (handleid, meter_code,miid, meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,'00000000','00000000',sysdate,null,'','开始读取抄表数据.......',sysdate);
       
      
      
    --取日期
    select last_day(trunc(sysdate)) into v_lastdate from dual ;
    select trunc(sysdate) into v_sysdate from dual ;
    --月末最后一天不进行数据采集
if v_lastdate <> v_sysdate then                         
    --读取处理下载到本地的抄表数据
    for rec_local in cur_local loop
      
      --记录处理日志
      insert into yk_interface_log
            (handleid, meter_code,miid,meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,rec_local.meter_code,rec_local.miid,rec_local.meter_time,rec_local.meter_hand,'','',sysdate);
            
      --1.检索基本资料、抄表资料      
      BEGIN
        select mr.MRID,
               mr.MRIFREC,
               mr.MRSMFID,
               mr.mrreadok,
               mi.mistatus,
               mr.MRTHREESL,
               mr.MRIFSUBMIT,
               mr.mrchkresult,
               md.ifdzsb,
               mr.MRSCODE,
               mi.MIPID,
               mi.MIPRIID,
               mi.MIPRIFLAG,
               mr.mrdatasource,
               mr.mrface,
               mi.mipfid,
               mi.mircode,  
               NVL(mr.mrdzflag, 'N'), --等针标志
               NVL(mr.mrdzcurcode, 0), --等针用户实际读数
               mi.miyl9 --水表量程
          into v_mrid,
               v_MRIFREC,
               v_MRSMFID,
               V_mrreadok,
               v_mistatus,
               v_MRTHREESL,
               V_MRIFSUBMIT,
               v_mrchkresult,
               v_ifdzsb,
               v_MRSCODE,
               v_MIPID,
               v_MIPRIID,
               v_MIPRIFLAG,
               v_mrdatasource,
               v_mrface,
               v_mipfid,
               v_mircode,
               v_mrdzflag,
               v_mrdzcurcode,
               v_miyl9
          from METERREAD mr, 
               meterinfo mi, 
               meterdoc md
         where mr.MRMID = mi.miid
           and mr.mrmid = md.MDMID
           and md.mdno = rec_local.meter_code /*and
               mr.mrdatasource = 'I'*/;
      EXCEPTION
        WHEN no_data_found THEN
          update yk_interface_log 
             set if_read = '0',
                 result = '未找到抄表资料!'
           where HANDLEID = v_handleId and
                 meter_code = rec_local.meter_code;
          goto lab_next;  
        WHEN too_many_rows THEN
          update yk_interface_log 
             set if_read = '0',
                 result = '表身码重复!'
           where HANDLEID = v_handleId and
                 meter_code = rec_local.meter_code;
          goto lab_next;  
      END;
      
      if V_mrreadok = 'Y' then
         update yk_interface_log 
            set if_read = '0',
                result = '本月已经抄见!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;   
      end if;
      
      if v_MRIFREC = 'Y' then
         update yk_interface_log 
            set if_read = '0',
                result = '本月已算费!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;   
      end if;
      
      --2.检验是否允许抄表(工单是否排斥)     
      if v_mistatus in ('24','35')then
         update yk_interface_log 
            set if_read = '0',
                result = '换表流程中,本次不算费!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;           
      elsif v_mistatus = '36' then
         update yk_interface_log 
            set if_read = '0',
                result = '预存冲正中,本次不算费!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;           
      elsif v_mistatus = '19' then
         update yk_interface_log 
            set if_read = '0',
                result = '销户中,本次不算费!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;    
         goto lab_next;             
      elsif v_mistatus = '39' then
         update yk_interface_log 
            set if_read = '0',
                result = '预存撤表退费中,本次不算费!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;       
         goto lab_next;           
      elsif v_mistatus = '19' then
         update yk_interface_log 
            set if_read = '0',
                result = '销户中,本次不算费!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;   
         goto lab_next;                                     
      end if;
      
      --若读数改变,不允许继续算费!
      if v_mircode <> v_mrscode then
         update yk_interface_log 
            set if_read = '0',
                result = '此水表读数自生成抄表计划起已经改变,忽略!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;           
         goto lab_next;           
      end if;
      
      --if rec_local.meter_flag <> '0XA0'/*水表状态:正常*/ then
      if rec_local.meter_flag not in ( '0XA0','0xA0','A0','a0','160','0xA5','A5','a5','0XA5','165')/*水表状态:正常*/ then
         update yk_interface_log 
            set if_read = '0',
                result = '水表状态异常,忽略!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;           
         goto lab_next; 
      end if;
      
      if v_ifdzsb = 'Y' THEN
        --倒表
        v_MRSL := v_MRSCODE - rec_local.meter_hand; --始指针 -末指针
      ELSIF v_mrdzflag = 'Y' THEN
        --等针
        IF rec_local.meter_hand < v_mrdzcurcode THEN
          update yk_interface_log 
             set if_read = '0',
                 result = '等针用户本次指针小于等针读数,忽略!'
           where HANDLEID = v_handleId and
                 meter_code = rec_local.meter_code;           
          goto lab_next;              
        END IF;
          
        IF rec_local.meter_hand >= v_MRSCODE THEN
          --等针结束，水量=止码-起码，等针水量=起码-等针读数
          v_MRSL   := rec_local.meter_code - v_MRSCODE;
          v_mrdzsl := v_MRSCODE - v_mrdzcurcode;
        ELSE
          --等针，水量=0，等针水量=止码-等针读数
          v_MRSL   := 0;
          v_mrdzsl := rec_local.meter_hand - v_mrdzcurcode;
        END IF;
      else
        --超量程
        IF v_miyl9 is not null and  rec_local.meter_hand > v_miyl9 THEN
          update yk_interface_log 
               set if_read = '0',
                   result = '用户本次指针比水表最大量程数大,忽略!'
             where HANDLEID = v_handleId and
                   meter_code = rec_local.meter_code;           
          goto lab_next;                 
        END IF;
        --正常表
        v_MRSL := rec_local.meter_hand - v_MRSCODE; --末指针 -始指针
        IF v_MRSL < 0 AND v_miyl9 IS not null THEN
          --水表走穿
          v_MRSL := to_number(v_miyl9) - v_MRSCODE + rec_local.meter_hand;
        END IF;      
      end if;
      
      if v_MRSL < 0 then
        update yk_interface_log 
           set if_read = '0',
               result = '水量为负数,忽略!'
         where HANDLEID = v_handleId and
               meter_code = rec_local.meter_code;           
        goto lab_next;  
      end if;
      
      if v_MRTHREESL > 0 then
        if v_mrchkresult <> '确认通过' or v_mrchkresult is null then
          PG_EWIDE_RAEDPLAN_01.SP_MRSLCHECK_HRB(v_mrid,
                                                v_MRSL,
                                                V_MRIFSUBMIT);
        end if;
      end if;
      
      --抄表数据来源
      if p_type = '1' then
        v_mrdatasource := '7';  --集抄 
      elsif p_type = '0' then
        v_mrdatasource := '4';  --无线远传
      end if;
      
      UPDATE METERREAD t
         SET mrdatasource = v_mrdatasource,         --抄表方式为智能表接口
             MROUTFLAG    = 'N',                    --发出到抄表机标志
             mrinorder    = nvl(mrinorder, 0) + 1,
             mrindate     = sysdate,                --数据接收日期
             mrinputper   = substrb(rec_local.meter_man, 1, 10),
             mrifsubmit   = V_MRIFSUBMIT,           --是否提交算费(通过波动即可算费)
             mrreadok     = 'Y',                    --抄见标志
             mrecodechar = to_char(rec_local.meter_hand),
             MRSL        = v_MRSL,                  --抄见水量
             MRECODE     = rec_local.meter_hand,    --抄见指针
             mrdzsl =      v_mrdzsl,                --等针用量 20160805
             mrrdate         = rec_local.meter_time,--抄表日期
             mrpdardate      = rec_local.meter_time,--抄表机抄表时间
             mrinputdate     = sysdate,             --编辑日期
             MRFACE          = '01',                --查表表态(如果抄见 则为正常！)
             mrface2         = '01',                --表况(如果抄见 则为正常)
             --mrmemo          = v_cb_memo,
             --MRCHKFLAG       = 'Y',       --手机抄表审核标志
             --MRCHKDATE       = v_MRCHKDATE,
             --MRCHKPER        = v_MRCHKPER,              
             MRIFGU          = '1'                                    --估表标志 见表 1
       WHERE mrid = v_mrid
         AND NVL(MRIFMCH, 'N') <> 'Y'; --免抄件不上传
      
      update yk_interface_log 
         set if_read = '1',
             result = '已读取!'
       where HANDLEID = v_handleId and
             meter_code = rec_local.meter_code;        
                    

      <<lab_next>>
      commit;
    end loop;
    
end if; 
    --回写 亚控接口表
    update v_yk_meter_date yk
       set yk.IF_READ = (select max(l.if_read) from yk_interface_log l where yk.METER_CODE = l.meter_code and l.handleid = v_handleId)
     where exists
       (select 1 from yk_interface_log log where yk.METER_CODE = log.meter_code and handleId = v_handleId) and 
       yk.METER_TIME = (select max(METER_TIME) from yk_interface_log where meter_code = yk.METER_CODE and handleId = v_handleId) and
       trunc(meter_time,'month') = trunc(sysdate,'month')  ;
    
    insert into yk_interface_log
            (handleid, meter_code,miid, meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,'########','########',sysdate,null,'','本次读取接口抄表数据结束!!!!!!',sysdate);
    
    commit;
    
  exception
    when others then
      v_error := sqlerrm;
      --rollback;  
      insert into yk_interface_log
            (handleid, meter_code,miid, meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,'########','########',sysdate,null,'','本次读取接口抄表数据异常结束:' || v_error ,sysdate);
      commit;            
  end;
  
  
  procedure 智能表平台抄表_test(p_type  varchar2) is
    v_handleId        varchar2(15);               
    v_miid            VARCHAR2(20);     
    V_COPY_ECODE      NUMBER;
    V_SUBMIT          VARCHAR2(2);
    V_MRIFSUBMIT      meterread.mrifsubmit%type;
    V_COPY_SL         NUMBER;    
    v_count           number;
    v_mrid            meterread.mrid%type;
    v_MRIFREC         meterread.MRIFREC%type;
    V_mrreadok        meterread.mrreadok%type;
    v_MRSMFID         meterread.MRSMFID%type;
    v_mistatus        meterinfo.mistatus%type; --用户状态
    v_MRTHREESL       meterread.MRTHREESL%type; --波动审核量
    v_mrchkresult     meterread.mrchkresult%type; --查表结果
    v_mrmonth         meterreadhis.mrmonth%type;
    v_ifdzsb          meterdoc.ifdzsb%type; --倒表设置 'Y'--为Y倒表
    v_MRSCODE         meterread.mrscode%type; --起始指针
    v_MRSL            meterread.mrsl%type; --抄表水量
    v_mrface          meterread.mrface%type; --表态
    v_MROUTFLAG       meterread.MROUTFLAG%type; --发出到抄表机标志
    v_MIPID           meterinfo.MIPID%type; --总表号码 3时为总表
    v_MIPRIID         meterinfo.MIPRIID%type; --合收主表号
    v_MIPRIFLAG       meterinfo.MIPRIFLAG%type; --合收表标志
    v_mipfid          meterinfo.mipfid%type; --水价类别
    v_mrdatasource    meterread.mrdatasource%type;
    v_MRCHKFLAG       meterread.MRCHKFLAG%type;
    v_MRCHKDATE       meterread.MRCHKDATE%type;
    v_MRCHKPER        meterread.MRCHKPER%type;
    v_mircode         meterinfo.mircode%type;
    v_mrsl1           number(10);
    v_sysdate     date;
    v_lastdate    date;
    --20160804
    v_mrdzflag    meterread.mrdzflag%type; --等针标志
    v_mrdzcurcode meterread.mrdzcurcode%type; --等针用户实际读数
    v_mrdzsl      meterread.mrdzsl%type; --等针用量
    v_miyl9       meterinfo.miyl9%type; --水表量程
    v_error       varchar2(200);
    cursor cur_local is
      select md.mdmid miid,
             yk.*
        from yk_meter_date yk, 
             meterdoc md       
       where yk.meter_code = md.mdno and --md.mdno='0151709402183' and
             HANDLEID = v_handleId;
  begin
    --抄表批次号
    v_handleId := to_char(sysdate,'yyyymmddhh24miss');
    --取接口数据到本地表
    insert into yk_meter_date
      (handleid, meter_code, meter_sn, meter_hand, meter_time, meter_man, meter_flag, switch_flag, meter_type, update_time, if_read)    
      select v_handleId,
             meter_code, 
             meter_sn, 
             meter_hand, 
             meter_time, 
             meter_man, 
             meter_flag, 
             switch_flag, 
             meter_type, 
             update_time, 
             if_read
        from v_yk_meter_date 
       where (meter_code,METER_TIME) in 
                (
                 select meter_code,max(meter_time) 
                   from v_yk_meter_date 
                  where METER_TYPE = p_type and
                        nvl(IF_READ,'0') = '0' and 
                        trunc(meter_time,'month') = trunc(sysdate,'month') -- and meter_code='0151709402183'
                group by meter_code
                );
    
    
    insert into yk_interface_log
            (handleid, meter_code, meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,'00000000',sysdate,null,'','开始读取抄表数据.......',sysdate);
       
      
      
    --取日期
    select last_day(trunc(sysdate)) into v_lastdate from dual ;
    select trunc(sysdate) into v_sysdate from dual ;
    --月末最后一天不进行数据采集
--if v_lastdate <> v_sysdate  then                         
    --读取处理下载到本地的抄表数据
    for rec_local in cur_local loop
      
      --记录处理日志
      insert into yk_interface_log
            (handleid, meter_code,miid,meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,rec_local.meter_code,rec_local.miid,rec_local.meter_time,rec_local.meter_hand,'','',sysdate);
            
      --1.检索基本资料、抄表资料      
      BEGIN
        select mr.MRID,
               mr.MRIFREC,
               mr.MRSMFID,
               mr.mrreadok,
               mi.mistatus,
               mr.MRTHREESL,
               mr.MRIFSUBMIT,
               mr.mrchkresult,
               md.ifdzsb,
               mr.MRSCODE,
               mi.MIPID,
               mi.MIPRIID,
               mi.MIPRIFLAG,
               mr.mrdatasource,
               mr.mrface,
               mi.mipfid,
               mi.mircode,  
               NVL(mr.mrdzflag, 'N'), --等针标志
               NVL(mr.mrdzcurcode, 0), --等针用户实际读数
               mi.miyl9 --水表量程
          into v_mrid,
               v_MRIFREC,
               v_MRSMFID,
               V_mrreadok,
               v_mistatus,
               v_MRTHREESL,
               V_MRIFSUBMIT,
               v_mrchkresult,
               v_ifdzsb,
               v_MRSCODE,
               v_MIPID,
               v_MIPRIID,
               v_MIPRIFLAG,
               v_mrdatasource,
               v_mrface,
               v_mipfid,
               v_mircode,
               v_mrdzflag,
               v_mrdzcurcode,
               v_miyl9
          from METERREAD mr, 
               meterinfo mi, 
               meterdoc md
         where mr.MRMID = mi.miid
           and mr.mrmid = md.MDMID
           and md.mdno = rec_local.meter_code /*and
               mr.mrdatasource = 'I'*/;
      EXCEPTION
        WHEN no_data_found THEN
          update yk_interface_log 
             set if_read = '0',
                 result = '未找到抄表资料!'
           where HANDLEID = v_handleId and
                 meter_code = rec_local.meter_code;
          goto lab_next;       
        WHEN too_many_rows THEN
          update yk_interface_log 
             set if_read = '0',
                 result = '表身码重复!'
           where HANDLEID = v_handleId and
                 meter_code = rec_local.meter_code;
          goto lab_next;    
      END;
      
      if rec_local.meter_code <>'0151709404822' then 
       insert into test_44
              (a,b,c,d)
              values
              (rec_local.meter_code,v_MRSMFID,'3','4');
      end if;
      if V_mrreadok = 'Y' then
         update yk_interface_log 
            set if_read = '0',
                result = '本月已经抄见!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;   
      end if;
      
      if v_MRIFREC = 'Y' then
         update yk_interface_log 
            set if_read = '0',
                result = '本月已算费!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;   
      end if;
      
      --2.检验是否允许抄表(工单是否排斥)     
      if v_mistatus in ('24','35')then
         update yk_interface_log 
            set if_read = '0',
                result = '换表流程中,本次不算费!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;           
      elsif v_mistatus = '36' then
         update yk_interface_log 
            set if_read = '0',
                result = '预存冲正中,本次不算费!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;           
      elsif v_mistatus = '19' then
         update yk_interface_log 
            set if_read = '0',
                result = '销户中,本次不算费!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;    
         goto lab_next;             
      elsif v_mistatus = '39' then
         update yk_interface_log 
            set if_read = '0',
                result = '预存撤表退费中,本次不算费!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;       
         goto lab_next;           
      elsif v_mistatus = '19' then
         update yk_interface_log 
            set if_read = '0',
                result = '销户中,本次不算费!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;   
         goto lab_next;                                     
      end if;
      
      --若读数改变,不允许继续算费!
      if v_mircode <> v_mrscode then
         update yk_interface_log 
            set if_read = '0',
                result = '此水表读数自生成抄表计划起已经改变,忽略!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;           
         goto lab_next;           
      end if;
      
      --if rec_local.meter_flag <> '0XA0'/*水表状态:正常*/ then
      if rec_local.meter_flag not in ( '0XA0','0xA0','A0','a0','160','0xA5','A5','a5','0XA5','165')/*水表状态:正常*/ then
         update yk_interface_log 
            set if_read = '0',
                result = '水表状态异常,忽略!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;           
         goto lab_next; 
      end if;
      
      if v_ifdzsb = 'Y' THEN
        --倒表
        v_MRSL := v_MRSCODE - rec_local.meter_hand; --始指针 -末指针
      ELSIF v_mrdzflag = 'Y' THEN
        --等针
        IF rec_local.meter_hand < v_mrdzcurcode THEN
          update yk_interface_log 
             set if_read = '0',
                 result = '等针用户本次指针小于等针读数,忽略!'
           where HANDLEID = v_handleId and
                 meter_code = rec_local.meter_code;           
          goto lab_next;              
        END IF;
          
        IF rec_local.meter_hand >= v_MRSCODE THEN
          --等针结束，水量=止码-起码，等针水量=起码-等针读数
          v_MRSL   := rec_local.meter_code - v_MRSCODE;
          v_mrdzsl := v_MRSCODE - v_mrdzcurcode;
        ELSE
          --等针，水量=0，等针水量=止码-等针读数
          v_MRSL   := 0;
          v_mrdzsl := rec_local.meter_hand - v_mrdzcurcode;
        END IF;
      else
        --超量程
        IF v_miyl9 is not null and  rec_local.meter_hand > v_miyl9 THEN
          update yk_interface_log 
               set if_read = '0',
                   result = '用户本次指针比水表最大量程数大,忽略!'
             where HANDLEID = v_handleId and
                   meter_code = rec_local.meter_code;           
          goto lab_next;                 
        END IF;
        --正常表
        v_MRSL := rec_local.meter_hand - v_MRSCODE; --末指针 -始指针
        IF v_MRSL < 0 AND v_miyl9 IS not null THEN
          --水表走穿
          v_MRSL := to_number(v_miyl9) - v_MRSCODE + rec_local.meter_hand;
        END IF;      
      end if;
      
      if v_MRSL < 0 then
        update yk_interface_log 
           set if_read = '0',
               result = '水量为负数,忽略!'
         where HANDLEID = v_handleId and
               meter_code = rec_local.meter_code;           
        goto lab_next;  
      end if;
      
      if v_MRTHREESL > 0 then
        if v_mrchkresult <> '确认通过' or v_mrchkresult is null then
          PG_EWIDE_RAEDPLAN_01.SP_MRSLCHECK_HRB(v_mrid,
                                                v_MRSL,
                                                V_MRIFSUBMIT);
        end if;
      end if;
      
      --抄表数据来源
      if p_type = '1' then
        v_mrdatasource := '7';  --集抄 
      elsif p_type = '0' then
        v_mrdatasource := '4';  --无线远传
      end if;
      
      
      UPDATE METERREAD t
         SET mrdatasource = v_mrdatasource,         --抄表方式为智能表接口
             MROUTFLAG    = 'N',                    --发出到抄表机标志
             mrinorder    = nvl(mrinorder, 0) + 1,
             mrindate     = sysdate,                --数据接收日期
             mrinputper   = substrb(rec_local.meter_man, 1, 10),
             mrifsubmit   = V_MRIFSUBMIT,           --是否提交算费(通过波动即可算费)
             mrreadok     = 'Y',                    --抄见标志
             mrecodechar = to_char(rec_local.meter_hand),
             MRSL        = v_MRSL,                  --抄见水量
             MRECODE     = rec_local.meter_hand,    --抄见指针
             mrdzsl =      v_mrdzsl,                --等针用量 20160805
             mrrdate         = rec_local.meter_time,--抄表日期
             mrpdardate      = rec_local.meter_time,--抄表机抄表时间
             mrinputdate     = sysdate,             --编辑日期
             MRFACE          = '01',                --查表表态(如果抄见 则为正常！)
             mrface2         = '01',                --表况(如果抄见 则为正常)
             --mrmemo          = v_cb_memo,
             --MRCHKFLAG       = 'Y',       --手机抄表审核标志
             --MRCHKDATE       = v_MRCHKDATE,
             --MRCHKPER        = v_MRCHKPER,              
             MRIFGU          = '1'                                    --估表标志 见表 1
       WHERE mrid = v_mrid
         AND NVL(MRIFMCH, 'N') <> 'Y'; --免抄件不上传
      
      update yk_interface_log 
         set if_read = '1',
             result = '已读取!'
       where HANDLEID = v_handleId and
             meter_code = rec_local.meter_code;        
                    

      <<lab_next>>
      commit;
    end loop;
    
--end if; 
    --回写 亚控接口表
    update v_yk_meter_date yk
       set yk.IF_READ = (select l.if_read from yk_interface_log l where yk.METER_CODE = l.meter_code and l.handleid = v_handleId)
     where exists
       (select 1 from yk_interface_log log where yk.METER_CODE = log.meter_code and handleId = v_handleId) and 
       yk.METER_TIME = (select METER_TIME from yk_interface_log where meter_code = yk.METER_CODE and handleId = v_handleId) and
       trunc(meter_time,'month') = trunc(sysdate,'month')  ;
    
    insert into yk_interface_log
            (handleid, meter_code, meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,'########',sysdate,null,'','本次读取接口抄表数据结束!!!!!!',sysdate);
    
    commit;
    
  exception
    when others then
      v_error := sqlerrm;
      --rollback;  
      insert into yk_interface_log
            (handleid, meter_code, meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,'########',sysdate,null,'','本次读取接口抄表数据异常结束:' || v_error ,sysdate);
      commit;            
  end;
  
 PROCEDURE updatey001 as 
  begin
    --更新合收表月底结算日期参数
      update syspara 
       set spvalue = to_char(last_day(sysdate),'yyyymmdd') || '230000' 
     where spid = 'Y001';
     commit;
 end ;

 
  
/*--------------------------------------------------------
合同用户变更记录20180419  已签合同用户如有更名，地址变更，水价变更则在第二天陵城插入到日志表contractlog中
--------------------------------------------------------*/
PROCEDURE 合同用户变更记录 as

begin
insert into contractlog value
    (select '户名变更' 变更类型,
           b.cismfid 营业所,
           b.miid 客户号,
           b.ciname 变更后,
           b.ciname2 变更前,
           cchshdate 变更日期,
           a.cchno 变更单据号,
           a.cchshper 审核人员,
           m.MIHTBH 合同编号,
           m.MIHTZQ 周期,
           m.MIRQXZ 日期限制,
           m.HTDATE 合同签订日期
      From custchangehd a, custchangedt b, meterinfo m
     where a.cchno = b.ccdno
       and b.miid = m.miid
       and m.MIHTBH is not null
       and m.ZFDATE is null
       and a.cchshflag='Y'
       --and b.ccdno in ('3000757572', '3000757573', '3000757574')
       --and b.cismfid = '0207'
       and cchshdate >= trunc(sysdate)-1
       and cchshdate <= trunc(sysdate)
       and （ b.ciname <> b.ciname2)
    union
    select '地址变更' 变更类型,
           b.cismfid 营业所,
           b.miid 客户号,
           b.ciadr 变更后,
           c.ciadr 变更前,
           cchshdate 变更日期,
           a.cchno 变更单据号,
           a.cchshper 审核人员,
           m.MIHTBH 合同编号,
           m.MIHTZQ 周期,
           m.MIRQXZ 日期限制,
           m.HTDATE 合同签订日期
      From custchangehd a, custchangedt b, custchangedthis c, meterinfo m
     where a.cchno = b.ccdno
       and a.cchno = c.ccdno
       and b.miid = m.miid
       and m.MIHTBH is not null
       and m.ZFDATE is null
       and a.cchshflag='Y'
       --and b.ccdno in ('3000757572', '3000757573', '3000757574')
       --and b.cismfid = '0207'
       and cchshdate >= trunc(sysdate)-1
       and cchshdate <= trunc(sysdate)
       and （ b.ciadr <> c.ciadr)
    union
    select '水价变更' 变更类型,
           b.cismfid 营业所,
           b.miid 客户号,
           b.mipfid 变更后,
           c.mipfid 变更前,
           cchshdate 变更日期,
           a.cchno 变更单据号,
           a.cchshper 审核人员,
           m.MIHTBH 合同编号,
           m.MIHTZQ 周期,
           m.MIRQXZ 日期限制,
           m.HTDATE 合同签订日期
      From custchangehd a, custchangedt b, custchangedthis c, meterinfo m
     where a.cchno = b.ccdno
       and a.cchno = c.ccdno
       and b.miid = m.miid
       and m.MIHTBH is not null
       and m.ZFDATE is null
       and a.cchshflag='Y'
       --and b.ccdno in ('3000757572', '3000757573', '3000757574')
       --and b.cismfid = '0207'
       and cchshdate >= trunc(sysdate)-1
       and cchshdate <= trunc(sysdate)
       and （ b.mipfid <> c.mipfid));
  
  COMMIT;
end 合同用户变更记录;

  

END;
/

