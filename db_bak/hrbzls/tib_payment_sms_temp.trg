CREATE OR REPLACE TRIGGER HRBZLS."TIB_PAYMENT_SMS_TEMP" BEFORE INSERT
ON payment FOR EACH ROW
DECLARE
INTEGRITY_ERROR EXCEPTION;
BEGIN
  IF :NEW.PPAYMENT > 0 THEN
  insert into payment_paid
    (ppmid, ppid, ppmiiftax, ppfid, ppje, ppdj, ppsfdj, ppwsfdj, ppfjfdj, ppsl, pprcode, ppprint, ppcharge)
  select miid ,:NEW.PID ,MIIFTAX ,mipfid ,:NEW.ppayment , fgetpricedj(mipfid) ,fgetpriceitemdj(mipfid,'01') ,
  fgetpriceitemdj(mipfid,'02') , fgetpriceitemdj(mipfid,'03') ,fgettaxsl(miid,:NEW.ppayment) ,mi.mircode ,'N'
   ,miifcharge from meterinfo mi where miid = :NEW.pmid;-- and  mi.miifcharge <> 'M' ;
END IF;
 --insert into PAYMENT_SMS_TEMP (pid,pbatch,pmid,pmcode) values (:NEW.PID,:NEW.PBATCH,:NEW.PMID,:NEW.PMCODE);
  --20150314 取消.目前没有发送短信业务
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 NULL;
 --RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

