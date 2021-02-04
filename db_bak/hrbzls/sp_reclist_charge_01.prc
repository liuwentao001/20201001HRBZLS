CREATE OR REPLACE PROCEDURE HRBZLS."SP_RECLIST_CHARGE_01" (V_RDID IN VARCHAR2,
                                                 V_TYPE IN VARCHAR2) IS
  -- nodata  exception;--
  RC  RECLIST_CHARGE_01%ROWTYPE;
  VRC VIEW_RECLIST_CHARGE_02%ROWTYPE;
  CURSOR C_VRC IS
    SELECT * FROM VIEW_RECLIST_CHARGE_02 WHERE RDID = V_RDID;
BEGIN
  OPEN C_VRC;
  LOOP
    FETCH C_VRC
      INTO VRC;
    IF C_VRC%NOTFOUND OR C_VRC%NOTFOUND IS NULL THEN
      RETURN;
    END IF;
    IF V_TYPE = '1' THEN
      RC.RDID        := VRC.RDID;
      RC.METERNO     := VRC.METERNO;
      RC.RDMONTH     := VRC.RDMONTH;
      RC.RDPAIDMONTH := VRC.RDPAIDMONTH;
      RC.RDPFID      := VRC.RDPFID;
      RC.RDMSMFID    := VRC.RDMSMFID;
      RC.WATERUSE    := VRC.WATERUSE;
      RC.USER_DJ1    := VRC.USER_DJ1;
      RC.USER_DJ2    := VRC.USER_DJ2;
      RC.USER_DJ3    := VRC.USER_DJ3;
      RC.USE_R1      := VRC.USE_R1;
      RC.USE_R2      := VRC.USE_R2;
      RC.USE_R3      := VRC.USE_R3;
      RC.CHARGETOTAL := VRC.CHARGETOTAL;
      RC.CHARGEZNJ   := VRC.CHARGEZNJ;
      RC.DJ1         := VRC.DJ1;
      RC.DJ2         := VRC.DJ2;
      RC.DJ3         := VRC.DJ3;
      RC.DJ4         := VRC.DJ4;
      RC.DJ5         := VRC.DJ5;
      RC.DJ6         := VRC.DJ6;
      RC.DJ7         := VRC.DJ7;
      RC.DJ8         := VRC.DJ8;
      RC.DJ9         := VRC.DJ9;
      RC.CHARGE1     := VRC.CHARGE1;
      RC.CHARGE2     := VRC.CHARGE2;
      RC.CHARGE3     := VRC.CHARGE3;
      RC.CHARGE4     := VRC.CHARGE4;
      RC.CHARGE5     := VRC.CHARGE5;
      RC.CHARGE6     := VRC.CHARGE6;
      RC.CHARGE7     := VRC.CHARGE7;
      RC.CHARGE8     := VRC.CHARGE8;
      RC.CHARGE9     := VRC.CHARGE9;
      RC.CHARGE10    := VRC.CHARGE10;
      RC.CHARGE11    := VRC.CHARGE11;
      RC.CHARGE12    := VRC.CHARGE12;
      RC.CHARGE13    := VRC.CHARGE13;
      RC.CHARGE_R1   := VRC.CHARGE_R1;
      RC.CHARGE_R2   := VRC.CHARGE_R2;
      RC.CHARGE_R3   := VRC.CHARGE_R3;
      RC.C_CHARGE    := VRC.C_CHARGE;
      RC.MEMO1       := VRC.MEMO1;
      RC.MEMO2       := VRC.MEMO2;
      RC.MEMO3       := VRC.MEMO3;
      RC.MEMO4       := VRC.MEMO4;
      RC.MEMO5       := VRC.MEMO5;
      RC.MEMO6       := VRC.MEMO6;
      RC.RDSL02      := VRC.RDSL2;
      RC.RDSL03      := VRC.RDSL3;
      RC.RDSL04      := VRC.RDSL4;
      RC.RDSL05      := VRC.RDSL5;
      RC.RDSL06      := VRC.RDSL6;
      RC.RDSL07      := VRC.RDSL7;
      RC.RDSL08      := VRC.RDSL8;
      RC.RDSL09      := VRC.RDSL9;
      RC.DJ          := VRC.DJ;

      INSERT INTO RECLIST_CHARGE_01 VALUES RC;

    ELSE
      UPDATE RECLIST_CHARGE_01 RC
         SET RC.RDPAIDMONTH = VRC.RDPAIDMONTH
       WHERE RC.RDID = VRC.RDID;
    END IF;
  END LOOP;
  CLOSE C_VRC;
  --commit;

EXCEPTION
  WHEN OTHERS THEN
    -- rollback ;
    NULL;
END SP_RECLIST_CHARGE_01;
/

