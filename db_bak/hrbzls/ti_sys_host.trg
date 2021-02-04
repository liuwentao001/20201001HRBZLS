CREATE OR REPLACE TRIGGER HRBZLS."TI_SYS_HOST"
  before update or  insert on sys_host  
  for each row
declare
  -- local variables here
begin
   --if  instr(:new.ip1,'172.16.1' ) > 0 then 
       null;
  /* else
     raise_application_error(-20002,'亲爱的用户,目前系统正在升级维护中,升级时间【2015/04/02 17:00 - 2015/04/02 22:00】.如有问题请电话联系87121751.');
    end if ;*/
   
 /*  if instr(:new.ip,'.',1) > 0 then  --add 20141201 hb
       raise_application_error(-20002,'系统检测到您安装的营业收费系统不能自动更新.请联系微机员进行手动更新');
    end if ;
 */
end ti_sys_host;
/

