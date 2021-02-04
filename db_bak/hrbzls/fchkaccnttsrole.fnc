CREATE OR REPLACE FUNCTION HRBZLS."FCHKACCNTTSROLE"
   (vtsbankid IN VARCHAR2,vaccountno IN VARCHAR2)
   Return CHAR
AS
   vAC1LEN  varchar2(1000):=null;
   vAC1STY  varchar2(1000):=null;
BEGIN
  SELECT smppvalue
  INTO vAC1LEN FROM sysmanapara
  where smpid=vtsbankid and smppid='AC1LEN';
  /*SELECT smppvalue
  INTO vAC1STY FROM sysmanapara
  where smpid=vtsbankid and smppid='AC1STY';*/

  if vAC1LEN is not null and trim(to_char(length(vaccountno)))<>vAC1LEN then
    return 'N';
  else
    return 'Y';
  end if;

  return 'Y';
exception when others then
  return 'Y';
end;
/

