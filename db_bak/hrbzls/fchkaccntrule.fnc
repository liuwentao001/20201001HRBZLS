CREATE OR REPLACE FUNCTION HRBZLS."FCHKACCNTRULE" (vbankid in varchar2)
  return varchar2 as
  v_SMPPDESC varchar2(30);
begin
select  SMPPDESC into v_SMPPDESC
   from sysmanapara
 where SMPID = vbankid
   and SMPPDESC like '%’ ∫≈–£—È%';
   return 'N';
end fchkaccntrule;
/

