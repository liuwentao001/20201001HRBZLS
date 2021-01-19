﻿CREATE OR REPLACE FUNCTION FCHKMETERNEEDCHARGE(VMSTATUS IN VARCHAR2,VIFCHK IN VARCHAR2,VMTYPE IN VARCHAR2) RETURN CHAR AS
LRET CHAR(1);
BEGIN
   IF VIFCHK='Y' THEN RETURN 'N'; END IF;
   SELECT SMTIFCHARGE INTO LRET FROM SYSMETERTYPE WHERE SMTID=VMTYPE;
   IF LRET='N' THEN  RETURN 'N'; END IF;
   RETURN 'Y';
EXCEPTION WHEN OTHERS THEN
   RETURN 'N';
END;
/

