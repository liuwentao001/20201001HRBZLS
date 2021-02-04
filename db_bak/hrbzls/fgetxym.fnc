CREATE OR REPLACE FUNCTION HRBZLS."FGETXYM" (p_micode in varchar2,p_modnum in number ) --参数2是除数值
  RETURN VARCHAR2          --获取银行效验码
AS
v_ret varchar2(200);
v_codenum number(10);
v_retnum number(10);
v_modnum number(10);
i number(10):=0;
BEGIN

  if p_micode is not null then
    v_codenum := 0;
    v_retnum := 0;
    v_modnum := 0;
     v_codenum := to_number(p_micode);
     loop
       exit when v_codenum < p_modnum;
       v_retnum := trunc(v_codenum/p_modnum,0) ;
       v_modnum := v_modnum + mod(v_codenum,p_modnum);
       if v_retnum >= p_modnum then
         v_codenum := v_retnum;
       elsif v_retnum + v_modnum >= p_modnum and i=0 then
         v_codenum := v_retnum + v_modnum;
         v_modnum := 0;
         i := 1;
       else
         v_codenum := /*v_retnum +*/ v_modnum;
         v_modnum := 0;
       end if;
     end loop;
  else
    return p_micode;
  end if;
  v_ret := to_char(v_codenum);
  return v_ret;
END;
/

