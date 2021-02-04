CREATE OR REPLACE FUNCTION HRBZLS."FGETOPERID" return varchar2 is
  Result varchar2(10);
begin
  select login_user
    into Result
    FROM sys_host
   WHERE ip = sys_context('userenv', 'sid') ;
  return(Result);
end FGETOPERID;
/

