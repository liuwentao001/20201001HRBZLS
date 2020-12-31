CREATE OR REPLACE PROCEDURE SP_MRSLCHECK_HRB(P_MRMID     IN VARCHAR2,
                           P_MRSL      IN NUMBER,
                           O_SUBCOMMIT OUT VARCHAR2) AS
  V_TYPE        VARCHAR2(10);
  V_SCALE_H     NUMBER(10);
  V_SCALE_L     NUMBER(10);  
  V_USE_H       NUMBER(10); 
  V_USE_L       NUMBER(10);
  V_TOTAL_H     NUMBER(10);
  V_TOTAL_L     NUMBER(10);
  V_PFID        VARCHAR2(10); --用水类别
  V_THREEMONAVG NUMBER(10);
BEGIN
  O_SUBCOMMIT := 'Y';
  --获得该用户前三月均量
  SELECT MRTHREESL INTO V_THREEMONAVG FROM BS_METERREAD WHERE MRMID = P_MRMID;
  --获得该用户的用水类别
  SELECT MIPFID INTO V_PFID FROM BS_METERINFO WHERE MIID = P_MRMID;
  begin
    --查出该用水类别的波动规则
    SELECT USETYPE, SCALE_H, SCALE_L, USE_H, USE_L, TOTAL_H, TOTAL_L
      INTO V_TYPE,
           V_SCALE_H, --超上限比例
           V_SCALE_L, --超下限比例
           V_USE_H, --超上限相对用量
           V_USE_L, --超下限相对用量
           V_TOTAL_H, --超上限绝对用量
           V_TOTAL_L --超下限绝对用量
      FROM CHK_METERREAD
     WHERE USETYPE = V_PFID;
   exception
      when others then
           V_TYPE:='';
           V_SCALE_H:=0; --超上限比例
           V_SCALE_L:=0; --超下限比例
           V_USE_H:=0; --超上限相对用量
           V_USE_L:=0; --超下限相对用量
           V_TOTAL_H:=0; --超上限绝对用量
           V_TOTAL_L:=0; --超下限绝对用量
  end ;
  IF P_MRSL IS NOT NULL THEN

    --如果绝对用量 不为空
    IF V_SCALE_H <> 0 AND V_SCALE_L <> 0 THEN
      IF P_MRSL > V_THREEMONAVG * (1 + V_SCALE_H * 0.01) OR
         P_MRSL < V_THREEMONAVG * (1 - V_SCALE_L * 0.01) THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;

    --如果相对用量 限制不为空
    IF V_USE_H <> 0 AND V_USE_L <> 0 THEN
      IF P_MRSL > V_THREEMONAVG + V_USE_H OR
         P_MRSL < V_THREEMONAVG - V_USE_L THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;

    --如果相对用量 限制不为空
    IF V_TOTAL_H <> 0 AND V_TOTAL_L <> 0 THEN
      IF P_MRSL > V_TOTAL_H OR P_MRSL < V_TOTAL_L THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;

  END IF;

END;
/

