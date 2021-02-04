CREATE OR REPLACE FUNCTION HRBZLS."F_GETBOOK_PRINT_TZDNUM" (p_bfid in varchar2,p_type in varchar2) return number is
  v_bfnum       number(5);
  v_pbfnum      number(5);
begin

  select count(mr.mrid),nvl(sum(decode(mr.mrrequisition,0,0,1)),0)
  into v_bfnum,v_pbfnum
  from meterread mr,
       meterinfo mi
  where mr.mrmid = mi.miid
  and   mi.miifchk <> 'Y'
  and   mr.mrbfid = p_bfid;

  if p_type = '1' then
     return(v_bfnum);
  else
     return(v_pbfnum);
  end if;
end f_getbook_print_tzdnum;
/

