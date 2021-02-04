CREATE OR REPLACE FUNCTION HRBZLS."FGETSYSCHARLIST" (p_scltype in varchar2,p_sclid in varchar2) return varchar2

as
  ret varchar2(100);
begin

   select t.sclvalue into ret from syscharlist t where trim(t.scltype)=trim(p_scltype) and trim(sclid)=trim(p_sclid);

   return ret;
   exception
      when others then
          return p_sclid;
  end;
/

