CREATE OR REPLACE TRIGGER HRBZLS."TRG_BU_METERINFO" BEFORE UPDATE
OF milb,miqfh
ON METERINFO FOR EACH ROW

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  
    --哈尔滨无保底水量，直接返回
  return;
  
 insert into wzdz(c1) values('1');
     if :NEW.miqfh>0 THEN
      DELETE priceadjustlist where palmid=:NEW.MIID AND PALTACTIC='02' AND PALMETHOD='05' ;

    sp_维护低度( :NEW.MIID,:NEW.MICODE,:NEW.miqfh,:NEW.MIINSDATE  );
   ELSe
     DELETE priceadjustlist where palmid=:NEW.MIID AND PALTACTIC='02' AND PALMETHOD='05' ;
   END IF;
END;
/

