CREATE OR REPLACE TRIGGER HRBZLS."TIU_RECCZDT"
  before insert or update on recczdt  
  for each row
declare
  v_count integer:=0;
  -- local variables here
  cursor s1(i_miid meterinfo.miid%type) is 
  select count(*)
  from meterinfo
  where miid =i_miid;  
begin
   open s1(:new.rcdccode);
   fetch s1 into v_count;
   if s1%notfound then
      v_count:=0;
    end if ;
   close s1;
   if v_count=0 then
       raise_application_error(-20002,'输入客户代码不存在系统中请再次确认') ;
   end if ;
end tiu_recczdt;
/

