CREATE OR REPLACE TRIGGER HRBZLS."TI_SYS_HOST"
  before update or  insert on sys_host  
  for each row
declare
  -- local variables here
begin
   --if  instr(:new.ip1,'172.16.1' ) > 0 then 
       null;
  /* else
     raise_application_error(-20002,'�װ����û�,Ŀǰϵͳ��������ά����,����ʱ�䡾2015/04/02 17:00 - 2015/04/02 22:00��.����������绰��ϵ87121751.');
    end if ;*/
   
 /*  if instr(:new.ip,'.',1) > 0 then  --add 20141201 hb
       raise_application_error(-20002,'ϵͳ��⵽����װ��Ӫҵ�շ�ϵͳ�����Զ�����.����ϵ΢��Ա�����ֶ�����');
    end if ;
 */
end ti_sys_host;
/

