CREATE OR REPLACE FUNCTION HRBZLS."F_GET_DAYS" (TASKDAYS in varchar2,PEROID in varchar2) return number is
  Result number;
begin
  if TASKDAYS='0001' and PEROID='M' then
     Result:=0;
  else
     Result:=1;
  end if;
  return(Result);
end f_get_days;
/

