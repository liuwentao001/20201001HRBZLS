CREATE OR REPLACE PROCEDURE HRBZLS."P_CHEAKMSG" (as_type in varchar2,  as_mid in varchar2 ,as_msg out varchar2,as_flag out varchar2,as_ifmsg out varchar2)
is
v_type varchar2(10);
begin
        if as_type='SF' then
               select MIPRIFLAG into v_type  from meterinfo mi where mi.miid=as_mid;
               if v_type='Y' then
                 as_msg:='合收表暂时不支持缴费';
                 as_flag:='N';
                 as_ifmsg:='Y';
               end if;
        end if;
  exception
     when others then
          as_msg:= null;
          as_flag :='Y';
          as_ifmsg:='N';
end;
/

