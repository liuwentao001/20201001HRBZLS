CREATE OR REPLACE PROCEDURE HRBZLS."SP_MSS_EXCEPT" (p_cicode in varchar2,p_type in varchar2,p_modeno in  varchar2   default '0' ,
                                            o_text out varchar2

                             ) as   --∂Ã–≈‘§¿¿
v_bh  varchar2(6) ;
begin
  if p_modeno='0' then
    select TMDBH into v_bh from tsmssendmode where tmdlb=p_type  and TMDTACITLY='Y';
   else
    v_bh :=  p_modeno;
  end if;
  select fSetsmmtext(p_cicode,p_type,v_bh) into o_text  from dual;

end ;
/

