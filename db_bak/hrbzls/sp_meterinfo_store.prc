CREATE OR REPLACE PROCEDURE HRBZLS."SP_METERINFO_STORE"(P_QFH     IN VARCHAR2, --铅封
                                                 P_STOREID IN VARCHAR2, --仓库编号
                                                 P_MIID    IN VARCHAR2, --用户编号
                                                 P_CALIBER IN NUMBER, --口径
                                                 P_BRAND   IN VARCHAR2, --品牌
                                                 P_MODEL   IN VARCHAR2, --表型号
                                                 P_STATUS  IN VARCHAR2, -- 表状态
                                                 P_QSBSM   IN VARCHAR2, --表身码起号
                                                 P_JSBSM   IN VARCHAR2, --表身码止号
                                                 P_QSR     IN DATE, --周检起算日
                                                 P_RKPC    IN VARCHAR2, --入库批次
                                                 P_RKDH    IN VARCHAR2, --入库单号
                                                 P_ROOMID  IN VARCHAR2, --库房编号
                                                 MSG       OUT VARCHAR2) IS

  V_DO      VARCHAR2(100);
  V_QTY     NUMBER;
  V_ISTRUE1 NUMBER;
  V_ISTRUE2 NUMBER;
  V_ISTRUE3 NUMBER;
  V_SBTH    VARCHAR2(6);
  V_EBTH    VARCHAR2(6);
  V_STR     VARCHAR2(7);
  V_QFH     VARCHAR2(40);
  V_OPER    VARCHAR2(20);
BEGIN
  IF P_CALIBER IS NULL THEN
    MSG := '表口径不允许为空值!';
    RETURN;
  END IF;

  IF P_QSBSM IS NULL AND P_JSBSM IS NULL THEN
    MSG := '批量入库请请录入起始止表身码号，单个入库请录入表身码起号或止号!';
    RETURN;
  END IF;

  V_OPER := FGETPBOPER;

  V_QTY := TO_NUMBER(P_JSBSM) - TO_NUMBER(P_QSBSM) + 1;

  /*1 一级库
  2 二级库
  3 已安装
  4 旧表
  5 返修
  6 作废
  7 出库*/

  IF P_STATUS = '1' THEN
    -- 0入库
    V_DO := '入总库';
  
    --检查表身码唯一性
    SELECT COUNT(BSM)
      INTO V_ISTRUE1
      FROM ST_METERINFO_STORE
     WHERE STOREID = TRIM(P_STOREID)
       AND BSM >= TRIM(P_QSBSM)
       AND BSM <= TRIM(P_JSBSM);
  
    --检查铅封号唯一性
    SELECT COUNT(QFH)
      INTO V_ISTRUE2
      FROM ST_METERINFO_STORE
     WHERE QFH = TRIM(P_QFH);
    ---------------
    SELECT COUNT(QFH)
      INTO V_ISTRUE3
      FROM ST_METERINFO_STORE
     WHERE TO_NUMBER(QFH) >= TRIM(P_QFH)
       AND TO_NUMBER(QFH) <= TRIM(P_QFH) + V_QTY - 1;
  
    V_QFH := P_QFH;
    --如果都唯一则插入
    IF V_ISTRUE1 = 0 AND V_ISTRUE2 = 0 AND V_ISTRUE3 = 0 THEN
      V_STR  := SUBSTR(P_QSBSM, 1, 7);
      V_SBTH := SUBSTR(P_QSBSM, 8, 6);
      V_EBTH := SUBSTR(P_JSBSM, 8, 6);
      FOR I IN V_SBTH .. V_EBTH LOOP
        INSERT INTO ST_METERINFO_STORE
          (QFH,
           STOREID,
           MIID,
           CALIBER,
           BRAND,
           MODEL,
           STATUS,
           STATUSDATE,
           CYCCHKDATE,
           STOCKDATE,
           BSM,
           RKBATCH,
           RKDNO,
           STOREROOMID,
           RKMAN,
           MAINMAN,
           MAINDATE)
        VALUES
          (V_QFH,
           P_STOREID,
           P_MIID,
           P_CALIBER,
           P_BRAND,
           P_MODEL,
           '1',
           SYSDATE,
           P_QSR,
           SYSDATE,
           V_STR || LPAD(I, 6, '0'),
           P_RKPC,
           P_RKDH,
           P_ROOMID,
           V_OPER,
           V_OPER,
           SYSDATE);
        V_QFH := V_QFH + 1;
      END LOOP;
      --判断每条是否添加成功
      IF SQL%ROWCOUNT > 0 THEN
        MSG := 'Y';
      ELSE
        MSG := 'N';
        RETURN;
      END IF;
    commit;
    ELSIF V_ISTRUE1 > 0 THEN
      MSG := '该表身码段存在已入总库的表身码！';
    ELSIF V_ISTRUE2 > 0 THEN
      MSG := '该铅封号已存在，请检查输入！';
    ELSIF V_ISTRUE3 > 0 THEN
      MSG := '连续铅封号中已有存在，请检查输入！';
    END IF;
  END IF;
 exception 
   when others then
      MSG := 'N';
      rollback;
     return ;
END;
/

