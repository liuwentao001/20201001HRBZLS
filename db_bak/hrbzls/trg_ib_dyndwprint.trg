CREATE OR REPLACE TRIGGER HRBZLS."TRG_IB_DYNDWPRINT" BEFORE INSERT
ON DYNDWPRINT FOR EACH ROW


BEGIN
if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
--≤Â»Îƒ£∞Â∫≈µΩ workprintset
INSERT INTO workprintset
SELECT WSID,:NEW.DYDPTYPE   ,:NEW.DYDPID        FROM workstation ;

-- ERRORS HANDLING

END;
/

