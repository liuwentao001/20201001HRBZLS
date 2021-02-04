CREATE OR REPLACE FUNCTION HRBZLS."F_GETCKNAME" (p_ckid in varchar2)
   return varchar2
as
    v_ckname varchar2(20);
begin
 begin
      select smf.smfname
        into v_ckname
        from sysmanaframe smf
       where smf.smfid  = trim(p_ckid);
      return v_ckname;
    exception
      when others then
        return '¼¯ÍÅ²Ö¿â';
    end;
end;
/

