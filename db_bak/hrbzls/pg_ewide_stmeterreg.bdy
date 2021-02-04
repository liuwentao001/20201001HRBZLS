CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_STMETERREG" IS
  --主单据入口
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2) IS
  BEGIN
    --raise_application_error(errcode,'lb:'|| p_djlb || ',bno:' || p_billno || ',oper:' || p_person  );
    IF P_DJLB IN ('U', '0') THEN
      --变更
      SP_STMETERCHANGE(P_BILLNO, P_PERSON, 'N');
    ELSIF P_DJLB = '1' THEN
      --入库
      SP_STMETERREG(P_BILLNO, P_PERSON, 'N');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --水表入库审核
  PROCEDURE SP_STMETERREG(P_DNO    IN VARCHAR2,
                          P_PER    IN VARCHAR2,
                          P_COMMIT IN VARCHAR2) AS
    CURSOR C_STMRD IS
      SELECT * FROM STMETERREGDT WHERE DNO = P_DNO FOR UPDATE;

    CURSOR C_STMRH IS
      SELECT * FROM STMETERREGHD WHERE HNO = P_DNO FOR UPDATE;
    CURSOR C_STM(P_BSM IN VARCHAR2) IS
      SELECT 1 FROM ST_METERINFO_STORE WHERE BSM = P_BSM;
    CURSOR C_STMD(P_BSM IN VARCHAR2) IS
      SELECT 1 FROM METERDOC WHERE MDNO = P_BSM;
    DUMMY     NUMBER;
    HD        STMETERREGHD%ROWTYPE;
    SRH       STMETERREGHD%ROWTYPE;
    SR        STMETERREGHD%ROWTYPE;
    STMRD     STMETERREGDT%ROWTYPE;
    V_STM     ST_METERINFO_STORE%ROWTYPE;
    FLAGN     NUMBER;
    FLAGY     NUMBER;
    V_SEQTEMP VARCHAR2(200);
    V_BILLID  VARCHAR2(200);

  BEGIN
    BEGIN
      SELECT * INTO SRH FROM STMETERREGHD WHERE HNO = P_DNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '立户单不存在!');
    END;
    IF SRH.HSHFLAG = 'Y' THEN

      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF SRH.HSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    SELECT COUNT(*)
      INTO FLAGY
      FROM STMETERREGDT
     WHERE DNO = P_DNO
       AND NVL(DFLAG, 'N') = 'N';
    IF FLAGY = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要入库的水表!');
    END IF;
    SELECT COUNT(*)
      INTO FLAGN
      FROM STMETERREGDT
     WHERE DNO = P_DNO
       AND DFLAG = 'Y';

    IF FLAGN > 0 THEN
      BEGIN
        SELECT BMID INTO V_BILLID FROM BILLMAIN WHERE BMTYPE = SRH.HLB;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '此种类型单据未定义!');
      END;
    END IF;
    --将单体中的记录插入到st_meterinfo_store表中
    OPEN C_STMRD;
    LOOP
      V_STM := NULL;
      FETCH C_STMRD
        INTO STMRD;
      EXIT WHEN C_STMRD%NOTFOUND OR C_STMRD%NOTFOUND IS NULL;
      V_STM.BSM        := STMRD.BSM;
      V_STM.QFH        := STMRD.QFH;
      V_STM.STOREID    := STMRD.STOREID;
      V_STM.MIID       := STMRD.MIID;
      V_STM.CALIBER    := STMRD.CALIBER;
      V_STM.BRAND      := STMRD.BRAND;
      V_STM.MODEL      := STMRD.MODEL;
      V_STM.STATUS     := STMRD.STATUS;
      V_STM.STATUSDATE := SYSDATE;
      V_STM.CYCCHKDATE := STMRD.CYCCHKDATE;
      V_STM.STOCKDATE  := STMRD.STOCKDATE;
      V_STM.RKBATCH    := SRH.HSBATCH;
      V_STM.RKDNO      := SRH.HNO;

      /*      select count(*) into FLAGN from st_meterinfo_store where qfh=stmrd.qfh;
      if FLAGN>0 then
         raise_application_error(errcode, '该水表号已存在，表身码：' || stmrd.qfh);
      end if;*/
      OPEN C_STM(STMRD.BSM);
      FETCH C_STM
        INTO DUMMY;
      IF C_STM%ISOPEN THEN
        CLOSE C_STM;
      END IF;
      IF DUMMY > 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '该水表号已存在，表身码：' || STMRD.BSM);
      END IF;

      OPEN C_STMD(STMRD.BSM);
      FETCH C_STMD
        INTO DUMMY;
      IF C_STMD%ISOPEN THEN
        CLOSE C_STMD;
      END IF;
      IF DUMMY > 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '该水表号已绑定到用户，表身码：' || STMRD.BSM);
      END IF;

      INSERT INTO ST_METERINFO_STORE VALUES V_STM;
      --修改stmeterregdt中的创建日期、操作人员以及审核标志
      UPDATE STMETERREGDT SET DFLAG = 'Y' WHERE CURRENT OF C_STMRD;
    END LOOP;
    CLOSE C_STMRD;
    --修改stmeterreghd中的审核标志
    UPDATE STMETERREGHD
       SET HEDATE = SYSDATE, HEPER = P_PER, HSHFLAG = 'Y'
     WHERE HNO = P_DNO;

    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_DNO);

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  PROCEDURE SP_STMETERCHANGE(P_DNO    IN VARCHAR2,
                             P_PER    IN VARCHAR2,
                             P_COMMIT IN VARCHAR2) AS

    CURSOR C_HD IS
      SELECT * FROM STMETERCHANGEHD WHERE HNO = P_DNO FOR UPDATE;
    CURSOR C_DT IS
      SELECT * FROM STMETERCHANGEDT WHERE DNO = P_DNO FOR UPDATE;
    V_HD     STMETERCHANGEHD%ROWTYPE;
    V_DT     STMETERCHANGEDT%ROWTYPE;
    SRH      STMETERCHANGEHD%ROWTYPE;
    FLAGN    NUMBER;
    FLAGY    NUMBER;
    V_BILLID VARCHAR2(200);
  BEGIN

    BEGIN
      SELECT * INTO SRH FROM STMETERCHANGEHD WHERE HNO = P_DNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单不存在!');
    END;
    IF SRH.HSHFLAG = 'Y' THEN

      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF SRH.HSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    SELECT COUNT(*)
      INTO FLAGY
      FROM STMETERCHANGEDT
     WHERE DNO = P_DNO
       AND NVL(DFLAG, 'N') = 'N'
       AND IFSUBMIT = 'Y';
    IF FLAGY = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要处理的水表!');
    END IF;
    /*   begin
      select bmid into v_billid from billmain where bmtype = srh.hlb;
    exception
      when others then
        raise_application_error(errcode, '此种类型单据未定义!');
    end;*/
    --单头
    OPEN C_HD;
    LOOP
      FETCH C_HD
        INTO V_HD;
      EXIT WHEN C_HD%NOTFOUND OR C_HD%NOTFOUND IS NULL;
      --单体审核
      OPEN C_DT;
      LOOP
        FETCH C_DT
          INTO V_DT;
        EXIT WHEN C_DT%NOTFOUND OR C_DT%NOTFOUND IS NULL;
        IF V_DT.MIID IS NOT NULL AND V_DT.STATUSN <> '1' THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '该水表已绑定用户，状态不能做变更!表身码： ' || V_DT.BSM);
        END IF;
        UPDATE ST_METERINFO_STORE ST
           SET ST.STOREID    = V_DT.STOREIDN,
               ST.CALIBER    = V_DT.CALIBERN,
               ST.BRAND      = V_DT.BRANDN,
               ST.MODEL      = V_DT.BRANDN,
               ST.STATUS     = V_DT.STATUSN,
               ST.STATUSDATE = SYSDATE,
               ST.QFH        = V_DT.QFH
         WHERE ST.BSM = V_DT.BSM;
        --更新审核标志
        UPDATE STMETERCHANGEDT SET DFLAG = 'Y' WHERE CURRENT OF C_DT;
      END LOOP;
      --更新审核标志
      UPDATE STMETERCHANGEHD
         SET HSHDATE = SYSDATE, HSHPER = P_PER, HSHFLAG = 'Y'
       WHERE CURRENT OF C_HD;

    END LOOP;

    --指标更新
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_DNO);
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
END PG_EWIDE_STMETERREG;
/

