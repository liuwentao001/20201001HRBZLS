CREATE OR REPLACE TRIGGER HRBZLS."TBA_PAYMENT"
  AFTER INSERT ON PAYMENT
  FOR EACH ROW
 declare 
v_count NUMBER :=0;
BEGIN
  UPDATE INV_DETAIL T
     SET T.PID = :NEW.PID, PBATCH = :NEW.PBATCH
   WHERE T.RLID IN (SELECT RLID FROM RECLIST_1METER_TMP);
   
     begin 
           select count(*)
           into v_count
           from meterinfo_sjcbup  where miid =:new.PBATCH AND UPDATE_MK='3' ;
           if v_count is null then
               v_count:=0;
           end if ;
     exception when others then
          v_count:=0;
     end ;
     if v_count = 0 then
        insert into meterinfo_sjcbup(MIID,CIID,UPDATE_MK) values(:NEW.PBATCH,:NEW.PMID,'3');--¸üÐÂ
     end if ; 
             
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/

