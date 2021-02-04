CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_AUTO_TASK AS


/*--------------------------------------------------------
���ƣ���̨��������
���ܣ����ݶ���������ݣ����ú�̨����
--------------------------------------------------------*/
PROCEDURE ����������(P_ID in NUMBER ,p_msg out varchar2)  as
  
v_step number;
V_TASK JOB_LIST%ROWTYPE;
V_NEXT DATE;
IN_RUNNING EXCEPTION;

begin
  v_step:=1;
  
  --ȡ����������
  SELECT T.* INTO V_TASK
  FROM JOB_LIST T 
  WHERE T.ID=P_ID;
  
  --�������Ƿ�������
  If V_TASK.�ϴ�����״��='Y' THEN
    RAISE IN_RUNNING;
  END if ;
 
  --�������Ѷ��壬���Ƴ�������
  BEGIN
    dbms_job.remove(V_TASK.ID);
    commit;
  EXCEPTION 
      WHEN OTHERS THEN
        p_msg:='�޷��Ƴ�����';
  END;
  --��֯�´�����ʱ��
  V_NEXT:=to_date(V_TASK.�´���������||' '|| V_TASK.��������ʱ��,'yyyy/mm/dd hh24:mi:ss');  
   
  --�ύ����              
  dbms_job.isubmit(V_TASK.ID, V_TASK.��������,V_NEXT,V_TASK.���м��,TRUE);
  commit;
  p_msg:='�����ɹ���';
EXCEPTION 
  WHEN NO_DATA_FOUND THEN
    p_msg:='��Ч�������ţ�';
  WHEN IN_RUNNING THEN
    p_msg:='���������У��޷��޸ģ�';      
  WHEN OTHERS THEN
    p_msg:='�޷�����ָ������';   

end ����������;

/*--------------------------------------------------------
���ƣ���������ע��
���ܣ���������������б�־
--------------------------------------------------------*/
PROCEDURE ״̬ע��(p_id varchar2) as

begin
  update JOB_LIST t
  set t.���б�־='Y'
  WHERE T.ID=p_id;
  
  COMMIT;
end ״̬ע��;

/*--------------------------------------------------------
���ƣ���������ע��
���ܣ���������������н�����־
--------------------------------------------------------*/
PROCEDURE ״̬ע��(p_id varchar2) as

begin
  update JOB_LIST t
  set t.���б�־='N'
  WHERE T.ID=p_id;
  
  COMMIT;
end ״̬ע��;
/*--------------------------------------------------------
���ƣ�ISRUNNINGȡ��������״̬
���ܣ�ȡ��������״̬
--------------------------------------------------------*/
  FUNCTION ISRUNNING(p_id varchar2) return varchar2 as
    
 v_flag varchar2(10);
 
 begin
   v_flag:='N';
   select t.���б�־ into v_flag
   from JOB_LIST t
   WHERE T.ID=p_id;
   
   return v_flag;
   
 exception 
   when others then
      return v_flag;
         
 end;
/*--------------------------------------------------------
���ƣ��½�����
���ܣ�ִ���½��������Ĺ����ڴ˵���
ִ��ʱ�䣺ÿ�µĵ����ڶ��죬����21:00
--------------------------------------------------------*/
procedure �½�����(p_id varchar2) as
  
v_step number;
IN_RUNNING EXCEPTION;

begin
  --��������Ѿ������У���ֱ�ӽ���
  if ISRUNNING(p_id)='Y' THEN
    RAISE IN_RUNNING;
  END IF;    
  
  ״̬ע��(p_id);
  
  v_step:=1;
  null;
   --������ͬ����������ڴ� 
  ״̬ע��(p_id);
EXCEPTION
   WHEN IN_RUNNING THEN 
     v_step:=9;
   WHEN OTHERS THEN  
     ״̬ע��(p_id);
     
end �½�����;
/*--------------------------------------------------------
���ƣ���ĩ����
���ܣ�ִ���½��������Ĺ����ڴ˵���
ִ��ʱ�䣺ÿ�����һ�죬����23:00
--------------------------------------------------------*/
procedure ��ĩ����(p_id varchar2) as
  
v_step number;
IN_RUNNING EXCEPTION;
 
begin
  --��������Ѿ������У���ֱ�ӽ���
  if ISRUNNING(p_id)='Y' THEN
    RAISE IN_RUNNING;
  END IF;    
  
  ״̬ע��(p_id);
  
  v_step:=1; 
   
    --�µ��Զ��½�
    pg_ewide_job_hrb.��ĩ�Զ�Ԥ��ֿ�;
    
    
   
  ״̬ע��(p_id);
EXCEPTION
   WHEN IN_RUNNING THEN 
     v_step:=9;
   WHEN OTHERS THEN  
     ״̬ע��(p_id);
 
     
end ��ĩ����;

/*--------------------------------------------------------
���ƣ��ս�����
���ܣ�ִ��ÿ����Ҫ��ת���������
ִ��ʱ�䣺ÿ���賿01:00
--------------------------------------------------------*/
procedure �ս�����(p_id varchar2) as
  
v_step number;
v_dd   number;
IN_RUNNING EXCEPTION;

begin
  --��������Ѿ������У���ֱ�ӽ���
  --if ISRUNNING(p_id)<>'Y' THEN
  if ISRUNNING(p_id)='Y' THEN
    RAISE IN_RUNNING;
  END IF;    
  
  ״̬ע��(p_id);
  v_step:=1;
  --20160130
  UPDATE sysmanapara
  set SMPPTYPE ='N' 
   WHERE SMPPID='SOURCE' ;
   
  --�ۺ��±����м������
 PG_EWIDE_REPORTSUM_HRB.�ۺ��±�(to_char(TRUNC(SYSDATE - 1),'yyyy.mm') );

  v_step:=2;
  --������֤������  
  PG_EWIDE_JOB_HRB.��֤��;
  
  --������ͬ����������ڴ�
  �峭���½��־;
  
    --ÿ��Ƿ����ϸ���� add 20141101  
  sp_Ƿ���м��;
  
  -- ���������ж���ÿ������ִ��ǰһ���20141212
  pro_�����������;
 
  -- gis��������
  select to_number(to_char(sysdate, 'dd' ))into v_dd from dual;
  if v_dd=15 then
    PG_EWIDE_REPORTSUM_HRB.gis��������;
       
  end if;
  
      
  ״̬ע��(p_id);
EXCEPTION
   WHEN IN_RUNNING THEN 
     v_step:=9;
   WHEN OTHERS THEN  
     ״̬ע��(p_id);
       
end �ս�����;

/*--------------------------------------------------------
���ƣ������ս�����
���ܣ�ִ��ÿ����Ҫ��ת���������
ִ��ʱ�䣺ÿ��22:00
--------------------------------------------------------*/
procedure �����ս�����(p_id varchar2) as
  
v_step     number;
v_appcode  number;
v_error    varchar2(500);
IN_RUNNING EXCEPTION;

begin
  --��������Ѿ������У���ֱ�ӽ���
  --if ISRUNNING(p_id)<>'Y' THEN
  if ISRUNNING(p_id)='Y' THEN
    RAISE IN_RUNNING;
  END IF;    
  
  ״̬ע��(p_id);
  v_step:=1;
      -- ÿ���Զ����sys_host���¼֮ǰ�����ʷ��¼���� add 20150311
    INSERT INTO SYS_HOST_HIS(ip, login_user, host_name, log_date, ip1, os_user)
    SELECT ip, login_user, host_name, log_date, ip1, os_user FROM SYS_HOST ;
      -- ÿ���Զ����sys_host���¼ add 20140902
    delete from sys_host;
    commit; 
   v_step:=2;
     --���2   
    --ÿ�� ��������ȷ���쳣����,������쳣���������. add 20140903
    pro_������ȷ���쳣���ϸ���; 
    commit; 

   v_step:=3;
     --�����½᱾�µ����ڶ����� 
    if  to_char( TRUNC(LAST_DAY(SYSDATE)-1),'yyyymmdd')= to_char(SYSDATE,'yyyymmdd' )  then 
         pg_ewide_job_hrb.�����½�;  --�����½�
        commit; 
/*        
       pg_ewide_job_hrb.�³�����;   --�½�֮������ �Զ��³����� add hb 20141121 Ӫ�����������
        commit; 
        delete from  meterinfo_sjcbup ; --add hb 20150421 ÿ�����곭���³�.ɾ���ֻ�������Ҫ���µ�����,�򳭱�Ա���³��Զ��������ݣ�����֮�����������µ�
        commit;
 */
    end if ;
    /*     v_step:=4;
       -- �û�������Ϣ�м����� --20150121 add hb
    pro_auto_rpt_sum_report ;*/
    commit;
    v_step:=5;
   -- if  to_char( TRUNC(LAST_DAY(SYSDATE)-1),'yyyymmdd') > to_char(SYSDATE,'yyyymmdd' )  then 
    PRO_�������ͳ��_hrb; 
    commit; 
  --  end if ;
    
    --����Ԥ��������ͳ�� ��ĩ��ת (ÿ�������һ��ִ��)
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
  
  ״̬ע��(p_id);
EXCEPTION
   WHEN IN_RUNNING THEN 
     v_step:=9;
   WHEN OTHERS THEN  
     ״̬ע��(p_id);
       
end �����ս�����;

/*--------------------------------------------------------
���ƣ��Զ�������
���ܣ�ÿ���Զ�ִ��������ش���
ִ��ʱ�䣺ÿ���賿01:00      
--------------------------------------------------------*/
  PROCEDURE �Զ�������(p_id varchar2) AS
    
v_step number;
IN_RUNNING EXCEPTION;

begin
  --��������Ѿ������У���ֱ�ӽ���
  if ISRUNNING(p_id)='Y' THEN
    RAISE IN_RUNNING;
  END IF;    
  
  ״̬ע��(p_id);
  v_step:=1;
  --ÿ���賿1�������������Ƿ����ʣ����δ�������Զ�����
  zhongbe.sp_autobankzz;

  v_step:=2;
 --�����½᱾�����һ�����Ͻ��д��� 
  if  to_char( TRUNC(LAST_DAY(SYSDATE) ),'yyyymmdd')= to_char(SYSDATE,'yyyymmdd' )  then 
/*      select  mrsmfid, min(MRDAY) from meterread    where mrmonth='2015.06'  --���¼��һ���﷨
        group by mrsmfid
        order by mrsmfid*/
      --pg_ewide_job_hrb.�³�����; �ŵ��µ����һ���賿1:00ȥ����д�ڡ��Զ������� modi hb  2015/06/02 ����ЩӪҵ����12��δִ�С�
			
        --pg_ewide_job_hrb.�³�����;   --�½�֮������ �Զ��³����� add hb 20141121 Ӫ�����������
				pg_ewide_job_hrb.prc_monthlyInit;
				
        commit; 
      
			  delete from  meterinfo_sjcbup ; --add hb 20150421 ÿ�����곭���³�.ɾ���ֻ�������Ҫ���µ�����,�򳭱�Ա���³��Զ��������ݣ�����֮�����������µ�
        commit;
    end if ;
    ״̬ע��(p_id);
  EXCEPTION
   WHEN IN_RUNNING THEN 
     v_step:=9;
   WHEN OTHERS THEN  
     ״̬ע��(p_id); 
  END �Զ�������;
    
  
/*--------------------------------------------------------
���ƣ�������
���ܣ�ÿ��ִ�����к�������ȷ����صļ��
      ������ܹ��ڿͻ��˷�������
ִ��ʱ�䣺ÿ���賿03:00      
--------------------------------------------------------*/
procedure ������(p_id varchar2) as

v_step number;
IN_RUNNING EXCEPTION;

begin
  --��������Ѿ������У���ֱ�ӽ���
  if ISRUNNING(p_id)='Y' THEN
    RAISE IN_RUNNING;
  END IF;    
  
  ״̬ע��(p_id);
  v_step:=1;

  v_step:=2;
  --���2   
  
  ״̬ע��(p_id);
EXCEPTION
   WHEN IN_RUNNING THEN 
     v_step:=9;
   WHEN OTHERS THEN  
     ״̬ע��(p_id);   
end ������;

/*--------------------------------------------------------
���ƣ��峭���½��־
���ܣ����µ׵�һ��ʱ���ڣ�����22����27�գ� ����������½��־     
--------------------------------------------------------*/
PROCEDURE  �峭���½��־ as
  V_NEWRUN varchar2(2);
begin
    --ֻ�����µ�ִ�г����½�ǰһ�ܲ����˲���
    if sysdate< trunc(last_day(sysdate)-8) AND sysdate>=trunc(last_day(sysdate)-4) then
      goto do_nothing;
    end if;
     
    --�峭���½��־��
    UPDATE  syspara t
    SET t.spvalue = 'N'
    where t.spid='YJBZ';
    
    COMMIT;

<<do_nothing>>    
    NULL;
end �峭���½��־; 


  --p_type ����ʽ 0-����Զ�� 1-����
  procedure ���ܱ�ƽ̨����(p_type  varchar2) is
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
    v_mistatus        meterinfo.mistatus%type; --�û�״̬
    v_MRTHREESL       meterread.MRTHREESL%type; --���������
    v_mrchkresult     meterread.mrchkresult%type; --�����
    v_mrmonth         meterreadhis.mrmonth%type;
    v_ifdzsb          meterdoc.ifdzsb%type; --�������� 'Y'--ΪY����
    v_MRSCODE         meterread.mrscode%type; --��ʼָ��
    v_MRSL            meterread.mrsl%type; --����ˮ��
    v_mrface          meterread.mrface%type; --��̬
    v_MROUTFLAG       meterread.MROUTFLAG%type; --�������������־
    v_MIPID           meterinfo.MIPID%type; --�ܱ���� 3ʱΪ�ܱ�
    v_MIPRIID         meterinfo.MIPRIID%type; --���������
    v_MIPRIFLAG       meterinfo.MIPRIFLAG%type; --���ձ��־
    v_mipfid          meterinfo.mipfid%type; --ˮ�����
    v_mrdatasource    meterread.mrdatasource%type;
    v_MRCHKFLAG       meterread.MRCHKFLAG%type;
    v_MRCHKDATE       meterread.MRCHKDATE%type;
    v_MRCHKPER        meterread.MRCHKPER%type;
    v_mircode         meterinfo.mircode%type;
    v_mrsl1           number(10);
    v_sysdate     date;
    v_lastdate    date;
    --20160804
    v_mrdzflag    meterread.mrdzflag%type; --�����־
    v_mrdzcurcode meterread.mrdzcurcode%type; --�����û�ʵ�ʶ���
    v_mrdzsl      meterread.mrdzsl%type; --��������
    v_miyl9       meterinfo.miyl9%type; --ˮ������
    v_error       varchar2(200);
    cursor cur_local is
      select md.mdmid miid,
             yk.*
        from yk_meter_date yk, 
             meterdoc md       
       where yk.meter_code = md.mdno and
             HANDLEID = v_handleId;
  begin
    --�������κ�
    v_handleId := to_char(sysdate,'yyyymmddhh24miss');
    --ȡ�ӿ����ݵ����ر�
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
            (v_handleId,'00000000','00000000',sysdate,null,'','��ʼ��ȡ��������.......',sysdate);
       
      
      
    --ȡ����
    select last_day(trunc(sysdate)) into v_lastdate from dual ;
    select trunc(sysdate) into v_sysdate from dual ;
    --��ĩ���һ�첻�������ݲɼ�
if v_lastdate <> v_sysdate then                         
    --��ȡ�������ص����صĳ�������
    for rec_local in cur_local loop
      
      --��¼������־
      insert into yk_interface_log
            (handleid, meter_code,miid,meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,rec_local.meter_code,rec_local.miid,rec_local.meter_time,rec_local.meter_hand,'','',sysdate);
            
      --1.�����������ϡ���������      
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
               NVL(mr.mrdzflag, 'N'), --�����־
               NVL(mr.mrdzcurcode, 0), --�����û�ʵ�ʶ���
               mi.miyl9 --ˮ������
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
                 result = 'δ�ҵ���������!'
           where HANDLEID = v_handleId and
                 meter_code = rec_local.meter_code;
          goto lab_next;  
        WHEN too_many_rows THEN
          update yk_interface_log 
             set if_read = '0',
                 result = '�������ظ�!'
           where HANDLEID = v_handleId and
                 meter_code = rec_local.meter_code;
          goto lab_next;  
      END;
      
      if V_mrreadok = 'Y' then
         update yk_interface_log 
            set if_read = '0',
                result = '�����Ѿ�����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;   
      end if;
      
      if v_MRIFREC = 'Y' then
         update yk_interface_log 
            set if_read = '0',
                result = '���������!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;   
      end if;
      
      --2.�����Ƿ�������(�����Ƿ��ų�)     
      if v_mistatus in ('24','35')then
         update yk_interface_log 
            set if_read = '0',
                result = '����������,���β����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;           
      elsif v_mistatus = '36' then
         update yk_interface_log 
            set if_read = '0',
                result = 'Ԥ�������,���β����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;           
      elsif v_mistatus = '19' then
         update yk_interface_log 
            set if_read = '0',
                result = '������,���β����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;    
         goto lab_next;             
      elsif v_mistatus = '39' then
         update yk_interface_log 
            set if_read = '0',
                result = 'Ԥ�泷���˷���,���β����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;       
         goto lab_next;           
      elsif v_mistatus = '19' then
         update yk_interface_log 
            set if_read = '0',
                result = '������,���β����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;   
         goto lab_next;                                     
      end if;
      
      --�������ı�,������������!
      if v_mircode <> v_mrscode then
         update yk_interface_log 
            set if_read = '0',
                result = '��ˮ����������ɳ���ƻ����Ѿ��ı�,����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;           
         goto lab_next;           
      end if;
      
      --if rec_local.meter_flag <> '0XA0'/*ˮ��״̬:����*/ then
      if rec_local.meter_flag not in ( '0XA0','0xA0','A0','a0','160','0xA5','A5','a5','0XA5','165')/*ˮ��״̬:����*/ then
         update yk_interface_log 
            set if_read = '0',
                result = 'ˮ��״̬�쳣,����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;           
         goto lab_next; 
      end if;
      
      if v_ifdzsb = 'Y' THEN
        --����
        v_MRSL := v_MRSCODE - rec_local.meter_hand; --ʼָ�� -ĩָ��
      ELSIF v_mrdzflag = 'Y' THEN
        --����
        IF rec_local.meter_hand < v_mrdzcurcode THEN
          update yk_interface_log 
             set if_read = '0',
                 result = '�����û�����ָ��С�ڵ������,����!'
           where HANDLEID = v_handleId and
                 meter_code = rec_local.meter_code;           
          goto lab_next;              
        END IF;
          
        IF rec_local.meter_hand >= v_MRSCODE THEN
          --���������ˮ��=ֹ��-���룬����ˮ��=����-�������
          v_MRSL   := rec_local.meter_code - v_MRSCODE;
          v_mrdzsl := v_MRSCODE - v_mrdzcurcode;
        ELSE
          --���룬ˮ��=0������ˮ��=ֹ��-�������
          v_MRSL   := 0;
          v_mrdzsl := rec_local.meter_hand - v_mrdzcurcode;
        END IF;
      else
        --������
        IF v_miyl9 is not null and  rec_local.meter_hand > v_miyl9 THEN
          update yk_interface_log 
               set if_read = '0',
                   result = '�û�����ָ���ˮ�������������,����!'
             where HANDLEID = v_handleId and
                   meter_code = rec_local.meter_code;           
          goto lab_next;                 
        END IF;
        --������
        v_MRSL := rec_local.meter_hand - v_MRSCODE; --ĩָ�� -ʼָ��
        IF v_MRSL < 0 AND v_miyl9 IS not null THEN
          --ˮ���ߴ�
          v_MRSL := to_number(v_miyl9) - v_MRSCODE + rec_local.meter_hand;
        END IF;      
      end if;
      
      if v_MRSL < 0 then
        update yk_interface_log 
           set if_read = '0',
               result = 'ˮ��Ϊ����,����!'
         where HANDLEID = v_handleId and
               meter_code = rec_local.meter_code;           
        goto lab_next;  
      end if;
      
      if v_MRTHREESL > 0 then
        if v_mrchkresult <> 'ȷ��ͨ��' or v_mrchkresult is null then
          PG_EWIDE_RAEDPLAN_01.SP_MRSLCHECK_HRB(v_mrid,
                                                v_MRSL,
                                                V_MRIFSUBMIT);
        end if;
      end if;
      
      --����������Դ
      if p_type = '1' then
        v_mrdatasource := '7';  --���� 
      elsif p_type = '0' then
        v_mrdatasource := '4';  --����Զ��
      end if;
      
      UPDATE METERREAD t
         SET mrdatasource = v_mrdatasource,         --����ʽΪ���ܱ�ӿ�
             MROUTFLAG    = 'N',                    --�������������־
             mrinorder    = nvl(mrinorder, 0) + 1,
             mrindate     = sysdate,                --���ݽ�������
             mrinputper   = substrb(rec_local.meter_man, 1, 10),
             mrifsubmit   = V_MRIFSUBMIT,           --�Ƿ��ύ���(ͨ�������������)
             mrreadok     = 'Y',                    --������־
             mrecodechar = to_char(rec_local.meter_hand),
             MRSL        = v_MRSL,                  --����ˮ��
             MRECODE     = rec_local.meter_hand,    --����ָ��
             mrdzsl =      v_mrdzsl,                --�������� 20160805
             mrrdate         = rec_local.meter_time,--��������
             mrpdardate      = rec_local.meter_time,--���������ʱ��
             mrinputdate     = sysdate,             --�༭����
             MRFACE          = '01',                --����̬(������� ��Ϊ������)
             mrface2         = '01',                --���(������� ��Ϊ����)
             --mrmemo          = v_cb_memo,
             --MRCHKFLAG       = 'Y',       --�ֻ�������˱�־
             --MRCHKDATE       = v_MRCHKDATE,
             --MRCHKPER        = v_MRCHKPER,              
             MRIFGU          = '1'                                    --�����־ ���� 1
       WHERE mrid = v_mrid
         AND NVL(MRIFMCH, 'N') <> 'Y'; --�Ⳮ�����ϴ�
      
      update yk_interface_log 
         set if_read = '1',
             result = '�Ѷ�ȡ!'
       where HANDLEID = v_handleId and
             meter_code = rec_local.meter_code;        
                    

      <<lab_next>>
      commit;
    end loop;
    
end if; 
    --��д �ǿؽӿڱ�
    update v_yk_meter_date yk
       set yk.IF_READ = (select max(l.if_read) from yk_interface_log l where yk.METER_CODE = l.meter_code and l.handleid = v_handleId)
     where exists
       (select 1 from yk_interface_log log where yk.METER_CODE = log.meter_code and handleId = v_handleId) and 
       yk.METER_TIME = (select max(METER_TIME) from yk_interface_log where meter_code = yk.METER_CODE and handleId = v_handleId) and
       trunc(meter_time,'month') = trunc(sysdate,'month')  ;
    
    insert into yk_interface_log
            (handleid, meter_code,miid, meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,'########','########',sysdate,null,'','���ζ�ȡ�ӿڳ������ݽ���!!!!!!',sysdate);
    
    commit;
    
  exception
    when others then
      v_error := sqlerrm;
      --rollback;  
      insert into yk_interface_log
            (handleid, meter_code,miid, meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,'########','########',sysdate,null,'','���ζ�ȡ�ӿڳ��������쳣����:' || v_error ,sysdate);
      commit;            
  end;
  
  
  procedure ���ܱ�ƽ̨����_test(p_type  varchar2) is
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
    v_mistatus        meterinfo.mistatus%type; --�û�״̬
    v_MRTHREESL       meterread.MRTHREESL%type; --���������
    v_mrchkresult     meterread.mrchkresult%type; --�����
    v_mrmonth         meterreadhis.mrmonth%type;
    v_ifdzsb          meterdoc.ifdzsb%type; --�������� 'Y'--ΪY����
    v_MRSCODE         meterread.mrscode%type; --��ʼָ��
    v_MRSL            meterread.mrsl%type; --����ˮ��
    v_mrface          meterread.mrface%type; --��̬
    v_MROUTFLAG       meterread.MROUTFLAG%type; --�������������־
    v_MIPID           meterinfo.MIPID%type; --�ܱ���� 3ʱΪ�ܱ�
    v_MIPRIID         meterinfo.MIPRIID%type; --���������
    v_MIPRIFLAG       meterinfo.MIPRIFLAG%type; --���ձ��־
    v_mipfid          meterinfo.mipfid%type; --ˮ�����
    v_mrdatasource    meterread.mrdatasource%type;
    v_MRCHKFLAG       meterread.MRCHKFLAG%type;
    v_MRCHKDATE       meterread.MRCHKDATE%type;
    v_MRCHKPER        meterread.MRCHKPER%type;
    v_mircode         meterinfo.mircode%type;
    v_mrsl1           number(10);
    v_sysdate     date;
    v_lastdate    date;
    --20160804
    v_mrdzflag    meterread.mrdzflag%type; --�����־
    v_mrdzcurcode meterread.mrdzcurcode%type; --�����û�ʵ�ʶ���
    v_mrdzsl      meterread.mrdzsl%type; --��������
    v_miyl9       meterinfo.miyl9%type; --ˮ������
    v_error       varchar2(200);
    cursor cur_local is
      select md.mdmid miid,
             yk.*
        from yk_meter_date yk, 
             meterdoc md       
       where yk.meter_code = md.mdno and --md.mdno='0151709402183' and
             HANDLEID = v_handleId;
  begin
    --�������κ�
    v_handleId := to_char(sysdate,'yyyymmddhh24miss');
    --ȡ�ӿ����ݵ����ر�
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
            (v_handleId,'00000000',sysdate,null,'','��ʼ��ȡ��������.......',sysdate);
       
      
      
    --ȡ����
    select last_day(trunc(sysdate)) into v_lastdate from dual ;
    select trunc(sysdate) into v_sysdate from dual ;
    --��ĩ���һ�첻�������ݲɼ�
--if v_lastdate <> v_sysdate  then                         
    --��ȡ�������ص����صĳ�������
    for rec_local in cur_local loop
      
      --��¼������־
      insert into yk_interface_log
            (handleid, meter_code,miid,meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,rec_local.meter_code,rec_local.miid,rec_local.meter_time,rec_local.meter_hand,'','',sysdate);
            
      --1.�����������ϡ���������      
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
               NVL(mr.mrdzflag, 'N'), --�����־
               NVL(mr.mrdzcurcode, 0), --�����û�ʵ�ʶ���
               mi.miyl9 --ˮ������
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
                 result = 'δ�ҵ���������!'
           where HANDLEID = v_handleId and
                 meter_code = rec_local.meter_code;
          goto lab_next;       
        WHEN too_many_rows THEN
          update yk_interface_log 
             set if_read = '0',
                 result = '�������ظ�!'
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
                result = '�����Ѿ�����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;   
      end if;
      
      if v_MRIFREC = 'Y' then
         update yk_interface_log 
            set if_read = '0',
                result = '���������!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;   
      end if;
      
      --2.�����Ƿ�������(�����Ƿ��ų�)     
      if v_mistatus in ('24','35')then
         update yk_interface_log 
            set if_read = '0',
                result = '����������,���β����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;           
      elsif v_mistatus = '36' then
         update yk_interface_log 
            set if_read = '0',
                result = 'Ԥ�������,���β����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;
         goto lab_next;           
      elsif v_mistatus = '19' then
         update yk_interface_log 
            set if_read = '0',
                result = '������,���β����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;    
         goto lab_next;             
      elsif v_mistatus = '39' then
         update yk_interface_log 
            set if_read = '0',
                result = 'Ԥ�泷���˷���,���β����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;       
         goto lab_next;           
      elsif v_mistatus = '19' then
         update yk_interface_log 
            set if_read = '0',
                result = '������,���β����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;   
         goto lab_next;                                     
      end if;
      
      --�������ı�,������������!
      if v_mircode <> v_mrscode then
         update yk_interface_log 
            set if_read = '0',
                result = '��ˮ����������ɳ���ƻ����Ѿ��ı�,����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;           
         goto lab_next;           
      end if;
      
      --if rec_local.meter_flag <> '0XA0'/*ˮ��״̬:����*/ then
      if rec_local.meter_flag not in ( '0XA0','0xA0','A0','a0','160','0xA5','A5','a5','0XA5','165')/*ˮ��״̬:����*/ then
         update yk_interface_log 
            set if_read = '0',
                result = 'ˮ��״̬�쳣,����!'
          where HANDLEID = v_handleId and
                meter_code = rec_local.meter_code;           
         goto lab_next; 
      end if;
      
      if v_ifdzsb = 'Y' THEN
        --����
        v_MRSL := v_MRSCODE - rec_local.meter_hand; --ʼָ�� -ĩָ��
      ELSIF v_mrdzflag = 'Y' THEN
        --����
        IF rec_local.meter_hand < v_mrdzcurcode THEN
          update yk_interface_log 
             set if_read = '0',
                 result = '�����û�����ָ��С�ڵ������,����!'
           where HANDLEID = v_handleId and
                 meter_code = rec_local.meter_code;           
          goto lab_next;              
        END IF;
          
        IF rec_local.meter_hand >= v_MRSCODE THEN
          --���������ˮ��=ֹ��-���룬����ˮ��=����-�������
          v_MRSL   := rec_local.meter_code - v_MRSCODE;
          v_mrdzsl := v_MRSCODE - v_mrdzcurcode;
        ELSE
          --���룬ˮ��=0������ˮ��=ֹ��-�������
          v_MRSL   := 0;
          v_mrdzsl := rec_local.meter_hand - v_mrdzcurcode;
        END IF;
      else
        --������
        IF v_miyl9 is not null and  rec_local.meter_hand > v_miyl9 THEN
          update yk_interface_log 
               set if_read = '0',
                   result = '�û�����ָ���ˮ�������������,����!'
             where HANDLEID = v_handleId and
                   meter_code = rec_local.meter_code;           
          goto lab_next;                 
        END IF;
        --������
        v_MRSL := rec_local.meter_hand - v_MRSCODE; --ĩָ�� -ʼָ��
        IF v_MRSL < 0 AND v_miyl9 IS not null THEN
          --ˮ���ߴ�
          v_MRSL := to_number(v_miyl9) - v_MRSCODE + rec_local.meter_hand;
        END IF;      
      end if;
      
      if v_MRSL < 0 then
        update yk_interface_log 
           set if_read = '0',
               result = 'ˮ��Ϊ����,����!'
         where HANDLEID = v_handleId and
               meter_code = rec_local.meter_code;           
        goto lab_next;  
      end if;
      
      if v_MRTHREESL > 0 then
        if v_mrchkresult <> 'ȷ��ͨ��' or v_mrchkresult is null then
          PG_EWIDE_RAEDPLAN_01.SP_MRSLCHECK_HRB(v_mrid,
                                                v_MRSL,
                                                V_MRIFSUBMIT);
        end if;
      end if;
      
      --����������Դ
      if p_type = '1' then
        v_mrdatasource := '7';  --���� 
      elsif p_type = '0' then
        v_mrdatasource := '4';  --����Զ��
      end if;
      
      
      UPDATE METERREAD t
         SET mrdatasource = v_mrdatasource,         --����ʽΪ���ܱ�ӿ�
             MROUTFLAG    = 'N',                    --�������������־
             mrinorder    = nvl(mrinorder, 0) + 1,
             mrindate     = sysdate,                --���ݽ�������
             mrinputper   = substrb(rec_local.meter_man, 1, 10),
             mrifsubmit   = V_MRIFSUBMIT,           --�Ƿ��ύ���(ͨ�������������)
             mrreadok     = 'Y',                    --������־
             mrecodechar = to_char(rec_local.meter_hand),
             MRSL        = v_MRSL,                  --����ˮ��
             MRECODE     = rec_local.meter_hand,    --����ָ��
             mrdzsl =      v_mrdzsl,                --�������� 20160805
             mrrdate         = rec_local.meter_time,--��������
             mrpdardate      = rec_local.meter_time,--���������ʱ��
             mrinputdate     = sysdate,             --�༭����
             MRFACE          = '01',                --����̬(������� ��Ϊ������)
             mrface2         = '01',                --���(������� ��Ϊ����)
             --mrmemo          = v_cb_memo,
             --MRCHKFLAG       = 'Y',       --�ֻ�������˱�־
             --MRCHKDATE       = v_MRCHKDATE,
             --MRCHKPER        = v_MRCHKPER,              
             MRIFGU          = '1'                                    --�����־ ���� 1
       WHERE mrid = v_mrid
         AND NVL(MRIFMCH, 'N') <> 'Y'; --�Ⳮ�����ϴ�
      
      update yk_interface_log 
         set if_read = '1',
             result = '�Ѷ�ȡ!'
       where HANDLEID = v_handleId and
             meter_code = rec_local.meter_code;        
                    

      <<lab_next>>
      commit;
    end loop;
    
--end if; 
    --��д �ǿؽӿڱ�
    update v_yk_meter_date yk
       set yk.IF_READ = (select l.if_read from yk_interface_log l where yk.METER_CODE = l.meter_code and l.handleid = v_handleId)
     where exists
       (select 1 from yk_interface_log log where yk.METER_CODE = log.meter_code and handleId = v_handleId) and 
       yk.METER_TIME = (select METER_TIME from yk_interface_log where meter_code = yk.METER_CODE and handleId = v_handleId) and
       trunc(meter_time,'month') = trunc(sysdate,'month')  ;
    
    insert into yk_interface_log
            (handleid, meter_code, meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,'########',sysdate,null,'','���ζ�ȡ�ӿڳ������ݽ���!!!!!!',sysdate);
    
    commit;
    
  exception
    when others then
      v_error := sqlerrm;
      --rollback;  
      insert into yk_interface_log
            (handleid, meter_code, meter_time, meter_hand, if_read, result, handle_time)
      values
            (v_handleId,'########',sysdate,null,'','���ζ�ȡ�ӿڳ��������쳣����:' || v_error ,sysdate);
      commit;            
  end;
  
 PROCEDURE updatey001 as 
  begin
    --���º��ձ��µ׽������ڲ���
      update syspara 
       set spvalue = to_char(last_day(sysdate),'yyyymmdd') || '230000' 
     where spid = 'Y001';
     commit;
 end ;

 
  
/*--------------------------------------------------------
��ͬ�û������¼20180419  ��ǩ��ͬ�û����и�������ַ�����ˮ�۱�����ڵڶ�����ǲ��뵽��־��contractlog��
--------------------------------------------------------*/
PROCEDURE ��ͬ�û������¼ as

begin
insert into contractlog value
    (select '�������' �������,
           b.cismfid Ӫҵ��,
           b.miid �ͻ���,
           b.ciname �����,
           b.ciname2 ���ǰ,
           cchshdate �������,
           a.cchno ������ݺ�,
           a.cchshper �����Ա,
           m.MIHTBH ��ͬ���,
           m.MIHTZQ ����,
           m.MIRQXZ ��������,
           m.HTDATE ��ͬǩ������
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
       and �� b.ciname <> b.ciname2)
    union
    select '��ַ���' �������,
           b.cismfid Ӫҵ��,
           b.miid �ͻ���,
           b.ciadr �����,
           c.ciadr ���ǰ,
           cchshdate �������,
           a.cchno ������ݺ�,
           a.cchshper �����Ա,
           m.MIHTBH ��ͬ���,
           m.MIHTZQ ����,
           m.MIRQXZ ��������,
           m.HTDATE ��ͬǩ������
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
       and �� b.ciadr <> c.ciadr)
    union
    select 'ˮ�۱��' �������,
           b.cismfid Ӫҵ��,
           b.miid �ͻ���,
           b.mipfid �����,
           c.mipfid ���ǰ,
           cchshdate �������,
           a.cchno ������ݺ�,
           a.cchshper �����Ա,
           m.MIHTBH ��ͬ���,
           m.MIHTZQ ����,
           m.MIRQXZ ��������,
           m.HTDATE ��ͬǩ������
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
       and �� b.mipfid <> c.mipfid));
  
  COMMIT;
end ��ͬ�û������¼;

  

END;
/

