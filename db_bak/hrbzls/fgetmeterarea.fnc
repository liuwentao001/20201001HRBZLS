CREATE OR REPLACE FUNCTION HRBZLS."FGETMETERAREA" (p_mcode in varchar2) return varchar2
is
  ret varchar2(10);
begin
        select mi.misafid into ret from  meterinfo mi where micode=p_mcode;
        return ret;
    exception
       when others then
           return 'нч';
  end;
/

