CREATE OR REPLACE TRIGGER HRBZLS."TRG_BI_METERINFO" BEFORE insert
ON METERINFO FOR EACH ROW

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  
  --哈尔滨无保底水量，直接返回
  return;
  
   if :NEW.milb='B' THEN
     DELETE priceadjustlist where palmid=:NEW.MIID AND PALTACTIC='02' AND PALMETHOD='02' ;
     sp_维护低保( :NEW.MIID );
   ELSE
     DELETE priceadjustlist where palmid=:NEW.MIID AND PALTACTIC='02' AND PALMETHOD='02' ;
   END IF;
     if :NEW.miqfh>0 THEN
      DELETE priceadjustlist where palmid=:NEW.MIID AND PALTACTIC='02' AND PALMETHOD='05' ;

    sp_维护低度( :NEW.MIID,:new.micode,:NEW.miqfh,:NEW.MIINSDATE );
   ELSe
     DELETE priceadjustlist where palmid=:NEW.MIID AND PALTACTIC='02' AND PALMETHOD='05' ;
   END IF;
END;
/

