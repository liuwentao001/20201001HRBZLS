create or replace function hrbzls.a_ww (vi_char in varchar2,v_type in varchar2, vi_number in number) return varchar2 as
  
  v_int  number := 1;
  i number :=0;
  V_ROW  NUMBER;
  V_TITLE  varchar2(5000);
begin
   while v_int  <= vi_number loop
       
       i:=i+1;
      if v_int=1 then
         V_ROW:=instr(vi_char,v_type,1);
         V_TITLE:=SUBSTR(vi_char,1,V_ROW - 1);
         if v_int<vi_number  then
            V_ROW:=instr(vi_char,v_type,1);
            V_TITLE:=substr(vi_char,instr(vi_char,v_type,1)+1);
         end if;
      else
        if  v_int<vi_number then
          V_ROW:=instr(V_TITLE,',',1);
          V_TITLE:=substr(V_TITLE,instr(V_TITLE,v_type,1)+1);
        end if;
        if vi_number=v_int then
           V_ROW:=instr(V_TITLE,v_type,1);
           V_TITLE:=SUBSTR(V_TITLE,1,V_ROW - 1);
        end if;
      end if;
      v_int:=v_int+1; 
   end loop;
  
  return to_char(V_TITLE);
end ;
/

