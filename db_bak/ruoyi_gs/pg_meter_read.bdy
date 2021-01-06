CREATE OR REPLACE PACKAGE BODY PG_METER_READ IS

/*  --抄表录入处调用的重抄
  PROCEDURE METERREAD_RE(
                         --MRID IN VARCHAR2,  --METERREAD表当前流水号
                         SMIID      IN VARCHAR2, --水表编号
                         GS_OPER_ID IN VARCHAR2, --登录人员ID
                         RES        IN OUT INTEGER) --返回结果 0成功 >0 失败*/

  --抄表录入处调用的重抄
  PROCEDURE METERREAD_RE(
                         --MRID IN VARCHAR2,  --METERREAD表当前流水号
                         SMIID      IN VARCHAR2, --水表编号
                         GS_OPER_ID IN VARCHAR2, --登录人员ID
                         RES        IN OUT INTEGER) --返回结果 0成功 >0 失败
   IS
    LS_MRIFREC      VARCHAR2(10);
    LS_MRDATASOURCE VARCHAR2(10);
    LS_READOK       VARCHAR2(1);
    LS_BFRPER       VARCHAR2(20);
    LS_MISTATUS     VARCHAR2(20);
    LL_MICOLUMN5    VARCHAR2(20);
    LS_BFRPER1      VARCHAR2(20);
    LS_MRMID      VARCHAR2(20);

  BEGIN

    RES := 0;

/*    SELECT MRIFREC, MRDATASOURCE, MRREADOK, MRRPER
      INTO LS_MRIFREC, LS_MRDATASOURCE, LS_READOK, LS_BFRPER
      FROM BS_METERREAD
     WHERE MRMID = SMIID;*/
    SELECT MRIFREC, MRDATASOURCE, MRREADOK, MRRPER, MRMID
      INTO LS_MRIFREC, LS_MRDATASOURCE, LS_READOK, LS_BFRPER,LS_MRMID
      FROM BS_METERREAD
     WHERE MRID = SMIID;

    IF LS_MRDATASOURCE = '9' AND LS_READOK = 'Y' THEN
      RES := 1;
      RETURN;
    END IF;
    IF LS_MRIFREC = 'Y' THEN
      RES := 2;
      RETURN;
    END IF;

    --判断当前是否免抄户
/*    SELECT BFRPER
      INTO LS_BFRPER1
      FROM BS_BOOKFRAME
     WHERE BFID = (SELECT MIBFID FROM BS_METERINFO WHERE MIID = SMIID);*/
    SELECT BFRPER
      INTO LS_BFRPER1
      FROM BS_BOOKFRAME
     WHERE BFID = (SELECT MIBFID FROM BS_METERINFO WHERE MIID = LS_MRMID);
    IF LS_BFRPER1 <> LS_BFRPER THEN
      LS_BFRPER := LS_BFRPER1;
    END IF;

/*    SELECT MISTATUS, MICOLUMN5
      INTO LS_MISTATUS, LL_MICOLUMN5
      FROM BS_METERINFO
     WHERE MIID = SMIID;*/
    SELECT MISTATUS, MICOLUMN5
      INTO LS_MISTATUS, LL_MICOLUMN5
      FROM BS_METERINFO
     WHERE MIID = LS_MRMID;

    IF (LS_MISTATUS = '29' OR LS_MISTATUS = '30') THEN
      UPDATE BS_METERREAD
         SET MRREADOK    = 'Y',
             MRIFSUBMIT  = 'N', --免拆户重抄后进抄表审核
             MRCHKFLAG   = 'Y', --重抄时是复核标志重置为'N'
             MRCHKRESULT = NULL, --重抄时检查结果类型重置为空
             MRINPUTPER  = GS_OPER_ID, --入账人员，取系统登录人员
             MRINPUTDATE = SYSDATE,
             --MRMEMO = '',
             MRFACE    = '01',
             MRFACE2   = '01',
             MRCARRYSL = 0,
             MRRPER    = LS_BFRPER
       WHERE MRID = SMIID;
    ELSE
      UPDATE BS_METERREAD
         SET MRREADOK    = 'N',
             MRIFSUBMIT  = 'N', --重抄时是否提交计费标志重置为'Y'
             MRCHKFLAG   = 'Y', --重抄时是复核标志重置为'N'
             MRCHKRESULT = NULL, --重抄时检查结果类型重置为空
             MRINPUTPER  = GS_OPER_ID, --入账人员，取系统登录人员
             MRINPUTDATE = SYSDATE,
             MRMEMO      = NULL,
             MRFACE      = '01',
             MRFACE2     = '01',
             MRCARRYSL   = 0,
             MRRPER      = LS_BFRPER,
             MRECODE     = NULL,
             MRSL        = NULL
       WHERE MRID = SMIID;

    END IF;

  END;

END;
/

