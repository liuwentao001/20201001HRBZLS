CREATE OR REPLACE FUNCTION HRBZLS."FGETMETERSTATUSNAME" (p_mistatus in varchar2) return varchar2
is
  ret varchar2(20);
begin
        select ms.smsname into ret from  sysmeterstatus  ms where ms.smsid=p_mistatus;
        return ret;
    exception
       when others then
           return 'нч';
  end;
/

