CREATE OR REPLACE TRIGGER HRBZLS."TIA_INVEINVOICERETURN" after insert
on inv_einvoice_return
for each row

DECLARE
  V_MSG     VARCHAR2(200);
  V_ISID    VARCHAR2(20);
  V_ID      VARCHAR2(20);
  V_ICID    VARCHAR2(20);
begin
  --用于电子发票中间件回调
  --回写发票号
  UPDATE INV_EINVOICE_ST
     SET ISPCISNO = TRIM(:NEW.FP_DM || '.' || :NEW.FP_HM)
   WHERE FPQQLSH = :NEW.FPQQLSH;
   --SELECT MAX(ID),MAX(ICID) INTO V_ID,V_ICID FROM INV_EINVOICE_ST WHERE FPQQLSH = :NEW.FPQQLSH;
  UPDATE INV_INFO_SP
     SET ISPCISNO = TRIM(:NEW.FP_DM || '.' || :NEW.FP_HM)
   WHERE ID IN
   (SELECT ID FROM INV_EINVOICE_ST WHERE FPQQLSH = :NEW.FPQQLSH);
   UPDATE INVSTOCK_SP 
   SET ISPCISNO= TRIM(:NEW.FP_DM || '.' || :NEW.FP_HM),
       ISBCNO=:NEW.FP_DM,
       ISNO=:NEW.FP_HM
   WHERE ISID IN  
   (SELECT IIS.ISID FROM INV_EINVOICE_ST IES,INV_INFO_SP IIS WHERE IES.FPQQLSH = :NEW.FPQQLSH AND IES.ID=IIS.ID);
   
   --增加发票
  /*PG_EWIDE_INVMANAGE_SP.SP_INVMANG_NEW(:NEW.FP_DM, --批次号
                                       'SYSTEM', --领票人
                                       'P', --发票类别
                                       :NEW.FP_HM, --发票起号
                                       :NEW.FP_HM, --发票止号
                                       'SYSTEM', --发放票据人
                                       V_MSG);

  PG_EWIDE_INVMANAGE_SP.SP_INVMANG_ZLY('P',
                                           :NEW.FP_HM,
                                           :NEW.FP_HM,
                                           :NEW.FP_DM,
                                           '5455',
                                           0,
                                           'NOCOMMIT',
                                           V_MSG);
  SELECT MAX(ISID)
        INTO V_ISID
        FROM INVSTOCK_SP
       WHERE ISBCNO = :NEW.FP_DM
         AND ISNO = :NEW.FP_HM
         AND ISTYPE = 'P';
      UPDATE INV_INFO_SP SET ISID = V_ISID WHERE ID = V_ID;
      UPDATE INV_DETAIL_SP SET ISID = V_ISID WHERE INVID = V_ID;*/
      --UPDATE INV_EINVOICE_RETURN SET IRID = V_ICID WHERE FPQQLSH = :NEW.FPQQLSH;
end;
/

