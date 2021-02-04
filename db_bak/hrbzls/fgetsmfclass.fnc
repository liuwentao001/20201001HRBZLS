CREATE OR REPLACE FUNCTION HRBZLS."FGETSMFCLASS" (p_id in varchar2) return number is
  vclass number;
begin
  if p_id='0' then
     return 0;
  end if;
  select smfclass
  into vclass
  from sysmanaframe
  where smfid = p_id;
  return(vclass);
exception when others then
  return 0;
end fgetsmfclass;
/

