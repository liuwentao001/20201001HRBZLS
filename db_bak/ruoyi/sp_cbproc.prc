CREATE OR REPLACE PROCEDURE SP_CBProc(p_miid IN VARCHAR,p_mdno IN VARCHAR)
AS
BEGIN

--撤表

update BS_METERDOC set mdstatus= '2',mdstatusdate=sysdate  where mdid=p_miid;   --表身码作废
update BS_METERFH_STORE set FHSTATUS='2',MAINDATE=sysdate  where BSM=p_mdno;   --封号作废
update BS_METERINFO set MISTATUS='2',MISTATUSDATE=sysdate  where miid=p_miid;   --水表作废

commit;

end;
/

