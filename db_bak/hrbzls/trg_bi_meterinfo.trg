CREATE OR REPLACE TRIGGER HRBZLS."TRG_BI_METERINFO" BEFORE insert
ON METERINFO FOR EACH ROW

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  
  --�������ޱ���ˮ����ֱ�ӷ���
  return;
  
   if :NEW.milb='B' THEN
     DELETE priceadjustlist where palmid=:NEW.MIID AND PALTACTIC='02' AND PALMETHOD='02' ;
     sp_ά���ͱ�( :NEW.MIID );
   ELSE
     DELETE priceadjustlist where palmid=:NEW.MIID AND PALTACTIC='02' AND PALMETHOD='02' ;
   END IF;
     if :NEW.miqfh>0 THEN
      DELETE priceadjustlist where palmid=:NEW.MIID AND PALTACTIC='02' AND PALMETHOD='05' ;

    sp_ά���Ͷ�( :NEW.MIID,:new.micode,:NEW.miqfh,:NEW.MIINSDATE );
   ELSe
     DELETE priceadjustlist where palmid=:NEW.MIID AND PALTACTIC='02' AND PALMETHOD='05' ;
   END IF;
END;
/

