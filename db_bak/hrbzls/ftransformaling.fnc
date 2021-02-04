CREATE OR REPLACE FUNCTION HRBZLS."FTRANSFORMALING" (p_size in varchar2) return varchar2
is
begin
  if p_size='0' then
    return '1';
  end if;
  if p_size='1' then
    return '2';
  end if;
  if p_size='2' then
    return '0';
  end if;
  return p_size;

  end;
/

