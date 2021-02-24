﻿CREATE OR REPLACE PROCEDURE SP_METERINFO_MIRORDER(I_MICODE IN VARCHAR2,O_STATE  OUT VARCHAR2) AS

--更新户表信息中单独表册的抄表次序

BEGIN
  FOR I IN (SELECT ROWNUM RN, MIID
              FROM (SELECT B.MIID
                      FROM BS_CUSTINFO A
                      LEFT JOIN BS_METERINFO B
                        ON A.CIID = B.MICODE
                     WHERE A.CISTATUS IN ('1', '2')
                       AND B.MIBFID = I_MICODE
                     ORDER BY A.CISTATUS)) LOOP
    UPDATE BS_METERINFO T SET T.MIRORDER = I.RN WHERE T.MIID = I.MIID;
  END LOOP;
  COMMIT;
  O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN 
      O_STATE := '-1';
END;
/

