CREATE OR REPLACE FUNCTION HRBZLS."ÇóË®¼Û" (p_usetype in varchar2) return varchar2 is
    v_pfname varchar2(300);
  begin
    select pfname
      into v_pfname
      from priceframe
     where pfid  = p_usetype;
    return v_pfname;
  exception
    when others then
      return p_usetype;
  end;
/

