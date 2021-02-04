CREATE OR REPLACE FUNCTION HRBZLS."FUPPERONENUMBER" (p_num in varchar2 ) return varchar2 is
  num_character  varchar2(20) := 'ÁãÒ¼·¡ÈşËÁÎéÂ½Æâ°Æ¾Á';
  begin
      if p_num is null then
         return null;
      elsif lengthb(p_num)=1 and is_number(p_num)='Y' then
         return substr(num_character,to_number(p_num) + 1,1) ;
      else
         return null;
      end if;
  end;
/

