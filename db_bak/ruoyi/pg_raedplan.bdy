CREATE OR REPLACE PACKAGE BODY "PG_RAEDPLAN" IS

  /*
  进行生成抄码表
  参数：P_MANAGE_NO： 临时表类型(PBPARMTEMP.C1)，存放调段后目标表册中所有水表编号C1,抄表次序C2
        P_MONTH: 目标营业所
        P_BOOK_NO:  目标表册
  处理：生成抄表资料
  输出：返回  0  执行成功
        返回 -1 执行失败
  */

  PROCEDURE CREATECB(P_MANAGE_NO IN VARCHAR2, /*营销公司*/
                     P_MONTH     IN VARCHAR2, /*抄表月份*/
                     P_BOOK_NO   IN VARCHAR2, /*表册*/
                     O_STATE     OUT VARCHAR2) /*执行状态*/
   IS
    /*表册*/
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    V_DATE DATE;
    V_BFRCYC NUMBER;
    V_MONTH  VARCHAR2(100);
    --存在
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BKSB IS
      SELECT A.CIID,
             B.MIID,
             B.MISMFID,
             B.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             B.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             B.MISTATUS,
             B.MIRECSL,
             B.MIENEED
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MISMFID = P_MANAGE_NO
         AND B.MIBFID = P_BOOK_NO
         AND A.CISTATUS = '1';
  BEGIN
    SELECT TO_DATE(BFNRMONTH, 'yyyy.mm'),BFRCYC
      INTO V_DATE,V_BFRCYC
      FROM BS_BOOKFRAME
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;
       
       <<REPEAT_LOOP>>
     IF SYSDATE >= TRUNC(V_DATE) THEN
       IF TRUNC(LAST_DAY(V_DATE)+1) < TRUNC(SYSDATE) THEN 
         V_DATE := ADD_MONTHS(V_DATE,V_BFRCYC);
         GOTO REPEAT_LOOP;
         END IF;
         
         V_MONTH := TO_CHAR(V_DATE,'yyyy.mm');
         
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --判断是否存在重复抄表计划
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --流水号
        SBR.MRMONTH       := V_MONTH; --抄表月份
        SBR.MRSMFID       := SB.MISMFID; --管辖公司
        SBR.MRBFID        := P_BOOK_NO; --表册
        SBR.MRBATCH       := BC.BFBATCH; --抄表批次
        SBR.MRRPER        := BC.BFRPER; --抄表员
        SBR.MRRORDER      := SB.MIRORDER; --抄表次序号
        SBR.MRCCODE       := YH.CIID; --用户编号
        SBR.MRMID         := SB.MIID; --水表编号
        SBR.MRSTID        := SB.MISTID; --行业分类
        SBR.MRMPID        := SB.MIPID; --上级水表
        SBR.MRMCLASS      := SB.MICLASS; --水表级次
        SBR.MRMFLAG       := SB.MIFLAG; --末级标志
        SBR.MRCREADATE    := SYSDATE; --创建日期
        SBR.MRINPUTDATE   := NULL; --编辑日期
        SBR.MRREADOK      := 'N'; --抄见标志
        SBR.MRRDATE       := NULL; --抄表日期
        SBR.MRPRDATE      := SB.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        SBR.MRSCODE       := SB.MIRCODE; --上期抄见
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --本期抄见
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --本期水量
        SBR.MRFACE        := NULL; --表况
        SBR.MRIFSUBMIT    := 'N'; --是否提交计费
        SBR.MRIFHALT      := 'N'; --系统停算
        SBR.MRDATASOURCE  := 1; --抄表结果来源
        SBR.MRMEMO        := NULL; --抄表备注
        SBR.MRIFGU        := 'N'; --估表标志
        SBR.MRIFREC       := 'N'; --已计费
        SBR.MRRECDATE     := NULL; --计费日期
        SBR.MRRECSL       := NULL; --应收水量
        SBR.MRADDSL       := 0; --余量
        SBR.MRCHKFLAG     := 'N'; --复核标志
        SBR.MRCHKDATE     := NULL; --复核日期
        SBR.MRCHKPER      := NULL; --复核人员
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  合收表标志
        SBR.MRFACE2       := NULL; --抄见故障
        SBR.MRREQUISITION := 0; --通知单打印次数
        SBR.MRIFCHK       := SB.MIIFCHK; --考核表标志
        SBR.MRINPUTPER    := NULL; --入账人员
        SBR.MRCALIBER     := MD.MDCALIBER; --口径
        SBR.MRSIDE        := SB.MISIDE; --表位
        SBR.MRLASTSL      := SB.MIRECSL;  --上次抄表水量
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --是否免抄户(Y-是 N-否)固定量

        --上次水费   至  去年度次均量
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = V_MONTH
         WHERE MIID = SB.MIID;
      END IF;
    END LOOP;
    CLOSE C_BKSB;

    UPDATE BS_BOOKFRAME K
       SET BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(V_MONTH, 'yyyy.mm'),
                                            BFRCYC),
                                 'yyyy.mm')
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;

    COMMIT;
    END IF;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;
--初始版本备份
/*  PROCEDURE CREATECB(P_MANAGE_NO IN VARCHAR2, \*营销公司*\
                     P_MONTH     IN VARCHAR2, \*抄表月份*\
                     P_BOOK_NO   IN VARCHAR2, \*表册*\
                     O_STATE     OUT VARCHAR2) \*执行状态*\
   IS
    \*表册*\
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    --存在
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BKSB IS
      SELECT A.CIID,
             B.MIID,
             B.MISMFID,
             B.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             B.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             B.MISTATUS,
             B.MIRECSL,
             B.MIENEED
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MISMFID = P_MANAGE_NO
         AND B.MIBFID = P_BOOK_NO
         AND D.BFNRMONTH = P_MONTH
         AND A.CISTATUS = '1';
  BEGIN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --判断是否存在重复抄表计划
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --流水号
        SBR.MRMONTH       := P_MONTH; --抄表月份
        SBR.MRSMFID       := SB.MISMFID; --管辖公司
        SBR.MRBFID        := P_BOOK_NO; --表册
        SBR.MRBATCH       := BC.BFBATCH; --抄表批次
        SBR.MRRPER        := BC.BFRPER; --抄表员
        SBR.MRRORDER      := SB.MIRORDER; --抄表次序号
        SBR.MRCCODE       := YH.CIID; --用户编号
        SBR.MRMID         := SB.MIID; --水表编号
        SBR.MRSTID        := SB.MISTID; --行业分类
        SBR.MRMPID        := SB.MIPID; --上级水表
        SBR.MRMCLASS      := SB.MICLASS; --水表级次
        SBR.MRMFLAG       := SB.MIFLAG; --末级标志
        SBR.MRCREADATE    := SYSDATE; --创建日期
        SBR.MRINPUTDATE   := NULL; --编辑日期
        SBR.MRREADOK      := 'N'; --抄见标志
        SBR.MRRDATE       := NULL; --抄表日期
        SBR.MRPRDATE      := SB.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        SBR.MRSCODE       := SB.MIRCODE; --上期抄见
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --本期抄见
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --本期水量
        SBR.MRFACE        := NULL; --表况
        SBR.MRIFSUBMIT    := 'N'; --是否提交计费
        SBR.MRIFHALT      := 'N'; --系统停算
        SBR.MRDATASOURCE  := 1; --抄表结果来源
        SBR.MRMEMO        := NULL; --抄表备注
        SBR.MRIFGU        := 'N'; --估表标志
        SBR.MRIFREC       := 'N'; --已计费
        SBR.MRRECDATE     := NULL; --计费日期
        SBR.MRRECSL       := NULL; --应收水量
        SBR.MRADDSL       := 0; --余量
        SBR.MRCHKFLAG     := 'N'; --复核标志
        SBR.MRCHKDATE     := NULL; --复核日期
        SBR.MRCHKPER      := NULL; --复核人员
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  合收表标志
        SBR.MRFACE2       := NULL; --抄见故障
        SBR.MRREQUISITION := 0; --通知单打印次数
        SBR.MRIFCHK       := SB.MIIFCHK; --考核表标志
        SBR.MRINPUTPER    := NULL; --入账人员
        SBR.MRCALIBER     := MD.MDCALIBER; --口径
        SBR.MRSIDE        := SB.MISIDE; --表位
        SBR.MRLASTSL      := SB.MIRECSL;  --上次抄表水量
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --是否免抄户(Y-是 N-否)固定量

        --上次水费   至  去年度次均量
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = SB.MIID;
      END IF;
    END LOOP;
    CLOSE C_BKSB;

    UPDATE BS_BOOKFRAME K
       SET BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC),
                               'yyyy.mm')
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;

    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;*/
/*  PROCEDURE CREATECB(P_MANAGE_NO IN VARCHAR2, \*营销公司*\
                     P_MONTH     IN VARCHAR2, \*抄表月份*\
                     P_BOOK_NO   IN VARCHAR2, \*表册*\
                     O_STATE     OUT VARCHAR2) \*执行状态*\
   IS
    \*表册*\
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    V_DATE DATE;

    --存在
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BKSB IS
      SELECT A.CIID,
             B.MIID,
             B.MISMFID,
             B.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             B.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             B.MISTATUS,
             B.MIRECSL,
             B.MIENEED
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MISMFID = P_MANAGE_NO
         AND B.MIBFID = P_BOOK_NO
         AND A.CISTATUS = '1';
  BEGIN
    SELECT TO_DATE(BFNRMONTH, 'yyyy.mm')
      INTO V_DATE
      FROM BS_BOOKFRAME
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;

    IF TO_DATE(P_MONTH, 'yyyy.mm') >= V_DATE THEN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --判断是否存在重复抄表计划
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --流水号
        SBR.MRMONTH       := P_MONTH; --抄表月份
        SBR.MRSMFID       := SB.MISMFID; --管辖公司
        SBR.MRBFID        := P_BOOK_NO; --表册
        SBR.MRBATCH       := BC.BFBATCH; --抄表批次
        SBR.MRRPER        := BC.BFRPER; --抄表员
        SBR.MRRORDER      := SB.MIRORDER; --抄表次序号
        SBR.MRCCODE       := YH.CIID; --用户编号
        SBR.MRMID         := SB.MIID; --水表编号
        SBR.MRSTID        := SB.MISTID; --行业分类
        SBR.MRMPID        := SB.MIPID; --上级水表
        SBR.MRMCLASS      := SB.MICLASS; --水表级次
        SBR.MRMFLAG       := SB.MIFLAG; --末级标志
        SBR.MRCREADATE    := SYSDATE; --创建日期
        SBR.MRINPUTDATE   := NULL; --编辑日期
        SBR.MRREADOK      := 'N'; --抄见标志
        SBR.MRRDATE       := NULL; --抄表日期
        SBR.MRPRDATE      := SB.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        SBR.MRSCODE       := SB.MIRCODE; --上期抄见
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --本期抄见
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --本期水量
        SBR.MRFACE        := NULL; --表况
        SBR.MRIFSUBMIT    := 'N'; --是否提交计费
        SBR.MRIFHALT      := 'N'; --系统停算
        SBR.MRDATASOURCE  := 1; --抄表结果来源
        SBR.MRMEMO        := NULL; --抄表备注
        SBR.MRIFGU        := 'N'; --估表标志
        SBR.MRIFREC       := 'N'; --已计费
        SBR.MRRECDATE     := NULL; --计费日期
        SBR.MRRECSL       := NULL; --应收水量
        SBR.MRADDSL       := 0; --余量
        SBR.MRCHKFLAG     := 'N'; --复核标志
        SBR.MRCHKDATE     := NULL; --复核日期
        SBR.MRCHKPER      := NULL; --复核人员
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  合收表标志
        SBR.MRFACE2       := NULL; --抄见故障
        SBR.MRREQUISITION := 0; --通知单打印次数
        SBR.MRIFCHK       := SB.MIIFCHK; --考核表标志
        SBR.MRINPUTPER    := NULL; --入账人员
        SBR.MRCALIBER     := MD.MDCALIBER; --口径
        SBR.MRSIDE        := SB.MISIDE; --表位
        SBR.MRLASTSL      := SB.MIRECSL;  --上次抄表水量
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --是否免抄户(Y-是 N-否)固定量

        --上次水费   至  去年度次均量
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = SB.MIID;
      END IF;
    END LOOP;
    CLOSE C_BKSB;

    SELECT ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                            BFRCYC)
      INTO V_DATE
      FROM BS_BOOKFRAME
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;

    WHILE TO_DATE(TO_CHAR(SYSDATE, 'yyyy.mm'),'yyyy.mm') >= V_DATE LOOP
      UPDATE BS_BOOKFRAME K
         SET BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                            BFRCYC),
                                 'yyyy.mm')
       WHERE BFSMFID = P_MANAGE_NO
         AND BFID = P_BOOK_NO;

        SELECT TO_DATE(BFNRMONTH, 'yyyy.mm')
      INTO V_DATE
      FROM BS_BOOKFRAME
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;
    END LOOP;
    END IF;
    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;*/
  /*
  进行生成抄码表
  参数：P_MANAGE_NO： 临时表类型(PBPARMTEMP.C1)，存放调段后目标表册中所有水表编号C1,抄表次序C2
        P_MONTH: 目标营业所
        P_BOOK_NO:  目标表册
  处理：生成抄表资料
  输出：返回  0  执行成功
        返回 -1 执行失败
  */

  PROCEDURE CREATECB2(P_MANAGE_NO IN VARCHAR2, /*营销公司*/
                      P_MONTH     IN VARCHAR2, /*抄表月份*/
                      P_BOOK_NO   IN VARCHAR2, /*表册*/
                      O_STATE     OUT VARCHAR2) /*执行状态*/
   IS
    /*表册*/
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    V_DATE DATE;
    V_BFRCYC NUMBER;
    V_MONTH  VARCHAR2(100);
    --存在
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BKSB IS
      SELECT A.CIID,
             A.MIID,
             A.MISMFID,
             A.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             A.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             MISTATUS,
             MIRECSL,
             MIENEED
        FROM BS_CBJH_TEMP A
       WHERE A.MIBFID = P_BOOK_NO
         AND A.MISMFID = P_MANAGE_NO;
  BEGIN
    SELECT TO_DATE(BFNRMONTH, 'yyyy.mm'),BFRCYC
      INTO V_DATE,V_BFRCYC
      FROM BS_BOOKFRAME
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;
       
       <<REPEAT_LOOP>>
     IF SYSDATE >= TRUNC(V_DATE) THEN
       IF TRUNC(LAST_DAY(V_DATE)+1) < TRUNC(SYSDATE) THEN 
         V_DATE := ADD_MONTHS(V_DATE,V_BFRCYC);
         GOTO REPEAT_LOOP;
         END IF;
         
         V_MONTH := TO_CHAR(V_DATE,'yyyy.mm');

    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --判断是否存在重复抄表计划
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --流水号
        SBR.MRMONTH       := V_MONTH; --抄表月份
        SBR.MRSMFID       := SB.MISMFID; --管辖公司
        SBR.MRBFID        := P_BOOK_NO; --表册
        SBR.MRBATCH       := BC.BFBATCH; --抄表批次
        SBR.MRRPER        := BC.BFRPER; --抄表员
        SBR.MRRORDER      := SB.MIRORDER; --抄表次序号
        SBR.MRCCODE       := YH.CIID; --用户编号
        SBR.MRMID         := SB.MIID; --水表编号
        SBR.MRSTID        := SB.MISTID; --行业分类
        SBR.MRMPID        := SB.MIPID; --上级水表
        SBR.MRMCLASS      := SB.MICLASS; --水表级次
        SBR.MRMFLAG       := SB.MIFLAG; --末级标志
        SBR.MRCREADATE    := SYSDATE; --创建日期
        SBR.MRINPUTDATE   := NULL; --编辑日期
        SBR.MRREADOK      := 'N'; --抄见标志
        SBR.MRRDATE       := NULL; --抄表日期
        SBR.MRPRDATE      := SB.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        SBR.MRSCODE       := SB.MIRCODE; --上期抄见
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --本期抄见
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --本期水量
        SBR.MRFACE        := NULL; --表况
        SBR.MRIFSUBMIT    := 'N'; --是否提交计费
        SBR.MRIFHALT      := 'N'; --系统停算
        SBR.MRDATASOURCE  := 1; --抄表结果来源
        SBR.MRMEMO        := NULL; --抄表备注
        SBR.MRIFGU        := 'N'; --估表标志
        SBR.MRIFREC       := 'N'; --已计费
        SBR.MRRECDATE     := NULL; --计费日期
        SBR.MRRECSL       := NULL; --应收水量
        SBR.MRADDSL       := 0; --余量
        SBR.MRCHKFLAG     := 'N'; --复核标志
        SBR.MRCHKDATE     := NULL; --复核日期
        SBR.MRCHKPER      := NULL; --复核人员
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  合收表标志
        SBR.MRFACE2       := NULL; --抄见故障
        SBR.MRREQUISITION := 0; --通知单打印次数
        SBR.MRIFCHK       := SB.MIIFCHK; --考核表标志
        SBR.MRINPUTPER    := NULL; --入账人员
        SBR.MRCALIBER     := MD.MDCALIBER; --口径
        SBR.MRSIDE        := SB.MISIDE; --表位
        SBR.MRLASTSL      := SB.MIRECSL;  --上次抄表水量
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --是否免抄户(Y-是 N-否)固定量

        --上次水费   至  去年度次均量
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = V_MONTH
         WHERE MIID = SB.MIID;
         --COMMIT;
      END IF;
    END LOOP;
    CLOSE C_BKSB;
    UPDATE BS_BOOKFRAME K
       SET BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(V_MONTH, 'YYYY.MM'),
                                          BFRCYC),
                               'YYYY.MM')
     WHERE BFID = P_BOOK_NO;
    COMMIT;
    END IF;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;
  
/*  PROCEDURE CREATECB2(P_MANAGE_NO IN VARCHAR2, \*营销公司*\
                     P_MONTH     IN VARCHAR2, \*抄表月份*\
                     P_BOOK_NO   IN VARCHAR2, \*表册*\
                     O_STATE     OUT VARCHAR2) \*执行状态*\
   IS
    \*表册*\
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    --存在
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BKSB IS
      SELECT A.CIID,
             A.MIID,
             A.MISMFID,
             A.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             A.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             MISTATUS,
             MIRECSL,
             MIENEED
        FROM BS_CBJH_TEMP A
       WHERE A.MIBFID = P_BOOK_NO
         AND A.MISMFID = P_MANAGE_NO;
  BEGIN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --判断是否存在重复抄表计划
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --流水号
        SBR.MRMONTH       := P_MONTH; --抄表月份
        SBR.MRSMFID       := SB.MISMFID; --管辖公司
        SBR.MRBFID        := P_BOOK_NO; --表册
        SBR.MRBATCH       := BC.BFBATCH; --抄表批次
        SBR.MRRPER        := BC.BFRPER; --抄表员
        SBR.MRRORDER      := SB.MIRORDER; --抄表次序号
        SBR.MRCCODE       := YH.CIID; --用户编号
        SBR.MRMID         := SB.MIID; --水表编号
        SBR.MRSTID        := SB.MISTID; --行业分类
        SBR.MRMPID        := SB.MIPID; --上级水表
        SBR.MRMCLASS      := SB.MICLASS; --水表级次
        SBR.MRMFLAG       := SB.MIFLAG; --末级标志
        SBR.MRCREADATE    := SYSDATE; --创建日期
        SBR.MRINPUTDATE   := NULL; --编辑日期
        SBR.MRREADOK      := 'N'; --抄见标志
        SBR.MRRDATE       := NULL; --抄表日期
        SBR.MRPRDATE      := SB.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        SBR.MRSCODE       := SB.MIRCODE; --上期抄见
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --本期抄见
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --本期水量
        SBR.MRFACE        := NULL; --表况
        SBR.MRIFSUBMIT    := 'N'; --是否提交计费
        SBR.MRIFHALT      := 'N'; --系统停算
        SBR.MRDATASOURCE  := 1; --抄表结果来源
        SBR.MRMEMO        := NULL; --抄表备注
        SBR.MRIFGU        := 'N'; --估表标志
        SBR.MRIFREC       := 'N'; --已计费
        SBR.MRRECDATE     := NULL; --计费日期
        SBR.MRRECSL       := NULL; --应收水量
        SBR.MRADDSL       := 0; --余量
        SBR.MRCHKFLAG     := 'N'; --复核标志
        SBR.MRCHKDATE     := NULL; --复核日期
        SBR.MRCHKPER      := NULL; --复核人员
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  合收表标志
        SBR.MRFACE2       := NULL; --抄见故障
        SBR.MRREQUISITION := 0; --通知单打印次数
        SBR.MRIFCHK       := SB.MIIFCHK; --考核表标志
        SBR.MRINPUTPER    := NULL; --入账人员
        SBR.MRCALIBER     := MD.MDCALIBER; --口径
        SBR.MRSIDE        := SB.MISIDE; --表位
        SBR.MRLASTSL      := SB.MIRECSL;  --上次抄表水量
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --是否免抄户(Y-是 N-否)固定量

        --上次水费   至  去年度次均量
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = SB.MIID;
         --COMMIT;
      END IF;
    END LOOP;
    CLOSE C_BKSB;
    UPDATE BS_BOOKFRAME K
       SET BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'YYYY.MM'),
                                          BFRCYC),
                               'YYYY.MM')
     WHERE BFID = P_BOOK_NO;
    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;*/

  /*
  单户月初
  进行生成抄码表
  参数：P_MONTH:抄表月份
        P_SBID:水表档案编号
  处理：生成抄表资料
  输出：返回 0  执行成功
        返回 -1 执行失败
  */
  PROCEDURE CREATECBSB(P_MONTH IN VARCHAR2, /*抄表月份*/
                       P_SBID  IN VARCHAR2, /*水表档案编号*/
                       O_STATE OUT VARCHAR2) /*执行状态*/
   IS
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    --存在
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BKSB IS
      SELECT A.CIID,    --用户号
             B.MIID,    --水表档案编号
             B.MISMFID, --营销公司
             B.MIRORDER, --抄表次序
             B.MISTID, --行业分类
             B.MIPID,    --上级水表编号
             B.MICLASS,  --水表级次
             B.MIFLAG, --末级标志
             B.MIRECDATE, --本期抄见日期
             B.MIRCODE, --本期读数
             S.MDMODEL, --计量方式
             B.MIPRIFLAG,  --合收表标志
             D.BFBATCH, --抄表批次
             D.BFRPER,  --抄表员
             B.MIRMON,  --本期抄表月份
             B.MISAFID, --区域
             B.MIIFCHK, --是否考核表(Y-是,N-否 )
             S.MDCALIBER, --表口径(METERCALIBER)
             B.MISIDE,
             B.MIBFID,
             B.MISTATUS,
             B.MIRECSL,
             B.MIENEED
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MIID = P_SBID
         AND A.CISTATUS = '1';
  BEGIN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MIRMON,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MIBFID,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --判断是否存在重复抄表计划
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --流水号
        SBR.MRMONTH       := P_MONTH; --抄表月份
        SBR.MRSMFID       := SB.MISMFID; --管辖公司
        SBR.MRBFID        := SB.MIBFID; --表册
        SBR.MRBATCH       := BC.BFBATCH; --抄表批次
        SBR.MRRPER        := BC.BFRPER; --抄表员
        SBR.MRRORDER      := SB.MIRORDER; --抄表次序号
        SBR.MRCCODE       := YH.CIID; --用户编号
        SBR.MRMID         := SB.MIID; --水表编号
        SBR.MRSTID        := SB.MISTID; --行业分类
        SBR.MRMPID        := SB.MIPID; --上级水表
        SBR.MRMCLASS      := SB.MICLASS; --水表级次
        SBR.MRMFLAG       := SB.MIFLAG; --末级标志
        SBR.MRCREADATE    := SYSDATE; --创建日期
        SBR.MRINPUTDATE   := NULL; --编辑日期
        SBR.MRREADOK      := 'N'; --抄见标志
        SBR.MRRDATE       := NULL; --抄表日期
        SBR.MRPRDATE      := SB.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        SBR.MRSCODE       := SB.MIRCODE; --上期抄见
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --本期抄见
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --本期水量
        SBR.MRFACE        := NULL; --表况
        SBR.MRIFSUBMIT    := 'N'; --是否提交计费
        SBR.MRIFHALT      := 'N'; --系统停算
        SBR.MRDATASOURCE  := 1; --抄表结果来源
        SBR.MRMEMO        := NULL; --抄表备注
        SBR.MRIFGU        := 'N'; --估表标志
        SBR.MRIFREC       := 'N'; --已计费
        SBR.MRRECDATE     := NULL; --计费日期
        SBR.MRRECSL       := NULL; --应收水量
        SBR.MRADDSL       := 0; --余量
        SBR.MRCHKFLAG     := 'N'; --复核标志
        SBR.MRCHKDATE     := NULL; --复核日期
        SBR.MRCHKPER      := NULL; --复核人员
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  合收表标志
        SBR.MRFACE2       := NULL; --抄见故障
        SBR.MRREQUISITION := 0; --通知单打印次数
        SBR.MRIFCHK       := SB.MIIFCHK; --考核表标志
        SBR.MRINPUTPER    := NULL; --入账人员
        SBR.MRCALIBER     := MD.MDCALIBER; --口径
        SBR.MRSIDE        := SB.MISIDE; --表位
        SBR.MRLASTSL      := SB.MIRECSL;  --上次抄表水量
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --是否免抄户(Y-是 N-否)固定量

        --上次水费   至  去年度次均量
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = SB.MIID;
      END IF;
    END LOOP;
    CLOSE C_BKSB;
    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;

  -- 月终
  --TIME 2020-12-22  BY WL
  --返回 0  执行成功
  --返回 -1 执行失败
  PROCEDURE CARRYFORWARD_MR(P_SMFID  IN VARCHAR2, /*营业所,售水公司*/
                            P_MONTH  IN VARCHAR2, /*当前月份*/
                            P_COMMIT IN VARCHAR2, /*提交标识*/
                            O_STATE  OUT VARCHAR2) /*执行状态*/
   IS
    --提交标识
    --P_COMMIT 提交标志
    V_TEMPMONTH VARCHAR2(7);
    V_ZZMONTH   VARCHAR2(7);
  BEGIN
    ---START检查是否有漏算情况(在客户端中检查)----------------------------------------------------------
    V_TEMPMONTH := TOOLS.FGETREADMONTH(P_SMFID);
    IF V_TEMPMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '月终月份异常,请检查!');
    END IF;
    --更新上期抄表月份
    UPDATE SYSMANAPARA
       SET SMPPVALUE = V_TEMPMONTH
     WHERE SMPID = P_SMFID
       AND SMPPID = '000005';
    --月份加一
    V_ZZMONTH := TO_CHAR(ADD_MONTHS(TO_DATE(V_TEMPMONTH || '.01',
                                            'yyyy.mm.dd'),
                                    1),
                         'yyyy.mm');
    --更新抄表月份
    UPDATE SYSMANAPARA
       SET SMPPVALUE = V_ZZMONTH
     WHERE SMPID = P_SMFID
       AND SMPPID = '000009';
    --将抄表数据转入到历史抄表库
    INSERT INTO BS_METERREAD_HIS
      (SELECT MRID,
              MRMONTH,
              MRSMFID,
              MRBFID,
              MRBATCH,
              MRDAY,
              MRRORDER,
              MRCCODE,
              MRMID,
              MRSTID,
              MRMPID,
              MRMCLASS,
              MRMFLAG,
              MRCREADATE,
              MRINPUTDATE,
              MRREADOK,
              MRRDATE,
              MRRPER,
              MRPRDATE,
              MRSCODE,
              MRECODE,
              MRSL,
              MRFACE,
              MRIFSUBMIT,
              MRIFHALT,
              MRDATASOURCE,
              '' MRPDARDATE,
              '' MROUTFLAG,
              '' MROUTID,
              '' MROUTDATE,
              '' MRINORDER,
              '' MRINDATE,
              MRMEMO,
              MRIFGU,
              MRIFREC,
              MRRECDATE,
              MRRECSL,
              MRADDSL,
              '' MRCTRL1,
              '' MRCTRL2,
              '' MRCTRL3,
              '' MRCTRL4,
              '' MRCTRL5,
              MRCARRYSL,
              MRCHKFLAG,
              MRCHKDATE,
              MRCHKPER,
              '' MRCHKSCODE,
              '' MRCHKECODE,
              '' MRCHKSL,
              '' MRCHKADDSL,
              '' MRCHKRDATE,
              '' MRCHKFACE,
              MRCHKRESULT,
              MRCHKRESULTMEMO,
              MRPRIMID,
              MRPRIMFLAG,
              MRFACE2,
              '' MRSCODECHAR,
              '' MRECODECHAR,
              '' MRIFTRANS,
              MRREQUISITION,
              MRIFCHK,
              MRINPUTPER,
              MRPFID,
              MRCALIBER,
              MRSIDE,
              MRLASTSL,
              MRTHREESL,
              MRYEARSL,
              MRRECJE01,
              MRRECJE02,
              MRRECJE03,
              MRRECJE04,
              MRNULLCONT,
              MRNULLTOTAL,
              MRBFSDATE,
              MRBFEDATE,
              MRBFDAY,
              MRIFMCH,
              MRIFZBSM,
              MRIFYSCZ,
              MRDZSL,
              MRDZFLAG,
              MRDZSYSCODE,
              MRDZCURCODE,
              MRDZTGL,
              MRZKH,
              MRSFFS,
              MRGDID
         FROM BS_METERREAD T
        WHERE T.MRSMFID = P_SMFID
          AND T.MRMONTH = P_MONTH);

    --删除当前抄表库信息
    DELETE BS_METERREAD T
     WHERE T.MRSMFID = P_SMFID
       AND T.MRMONTH = P_MONTH;

    /*    --历史均量计算
    UPDATEMRSLHIS(P_SMFID, P_MONTH);*/
    --提交标志
    IF P_COMMIT = 'Y' THEN
      COMMIT;
      O_STATE := '0';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '月终失败' || SQLERRM);
      O_STATE := '-1';
  END;

  -- 抄表审核
  --TIME 2020-12-24  BY WL
  --返回 0  执行成功
  --返回 -1 执行失败
  PROCEDURE SP_MRMRIFSUBMIT(P_MRID  IN VARCHAR2,     /*流水号*/
                            P_OPER  IN VARCHAR2,     /*操作人姓名*/
                            P_FLAG  IN VARCHAR2,     /*是否通过*/
                            O_STATE OUT VARCHAR2) AS /*执行状态*/
    MR BS_METERREAD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MR FROM BS_METERREAD WHERE MRID = P_MRID;
      IF MR.MRIFSUBMIT = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '无需审核');
      END IF;
      IF MR.MRSL IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '用户号【' || MR.MRCCODE || '】抄表水量为空');
      END IF;
      IF MR.MRIFREC = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '已计费无需审核');
      END IF;
      /*    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '无效的抄表记录');*/
    END;

    UPDATE BS_METERREAD
       SET MRIFSUBMIT = 'Y',
           MRCHKFLAG  = 'Y', --复核标志
           MRCHKDATE  = SYSDATE, --复核日期
           MRCHKPER   = P_OPER, --复核人员
           --MRCHKSCODE      = MR.MRSCODE, --原起数
           --MRCHKECODE      = MR.MRECODE, --原止数
           --MRCHKSL         = MR.MRSL, --原水量
           --MRCHKADDSL      = MR.MRADDSL, --原余量
           --MRCHKCARRYSL    = MR.MRCARRYSL, --原进位水量
           --MRCHKRDATE      = MR.MRRDATE, --原抄见日期
           --MRCHKFACE       = MR.MRFACE, --原表况
           MRCHKRESULT = (CASE
                           WHEN P_FLAG = '0' THEN
                            '确认通过'
                           ELSE
                            '退回重入帐'
                         END), --检查结果类型
           MRCHKRESULTMEMO = (CASE
                               WHEN P_FLAG = '0' THEN
                                '确认通过'
                               ELSE
                                '退回重入帐'
                             END) --检查结果说明
     WHERE MRID = P_MRID;

    IF P_FLAG = '-1' THEN
      --审批不通过
      UPDATE BS_METERREAD
         SET MRREADOK   = 'N',
             MRIFSUBMIT = 'N',
             MRRDATE    = NULL,
             MRECODE    = NULL,
             MRSL       = NULL,
             MRFACE     = NULL,
             MRFACE2    = NULL,
             --MRFACE3      = NULL,
             --MRFACE4      = NULL,
             --MRECODECHAR  = NULL,
             MRDATASOURCE = NULL
       WHERE MRID = P_MRID;
    END IF;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_STATE := '-1';
  END;
  /*
  均量（费）算法
  1、前N次均量：     从最近抄表水量向历史方向递推12次抄表累计水量（0水量不计次）/递推次数
  2、上次水量：      最近一次抄表水量（包括0水量）
  3、去年同期水量：  去年同抄表月份的抄表水量（包括0水量）
  4、去年度次均量：  去年度的抄表累计水量（0水量不计次）/递推次数
  */
  PROCEDURE GETMRHIS(P_SBID  IN VARCHAR2,
                     P_MONTH IN VARCHAR2,
                     O_SL_1  OUT NUMBER,
                     O_SL_2  OUT NUMBER,
                     O_SL_3  OUT NUMBER) IS
    CURSOR C_MRH(V_SBID BS_METERREAD_HIS.MRMID%TYPE) IS
      SELECT NVL(MRSL, 0),
             NVL(MRRECJE01, 0),
             NVL(MRRECJE02, 0),
             NVL(MRRECJE03, 0),
             MRMONTH
        FROM BS_METERREAD_HIS
       WHERE MRMID = V_SBID
            /*AND MRSL > 0*/
         AND (MRDATASOURCE <> '9' OR MRDATASOURCE IS NULL)
       ORDER BY MRRDATE DESC;

    MRH BS_METERREAD_HIS%ROWTYPE;
    N1  INTEGER := 0;
    N2  INTEGER := 0;
    N3  INTEGER := 0;
    N4  INTEGER := 0;
  BEGIN
    OPEN C_MRH(P_SBID);
    LOOP
      FETCH C_MRH
        INTO MRH.MRSL,
             MRH.MRRECJE01,
             MRH.MRRECJE02,
             MRH.MRRECJE03,
             MRH.MRMONTH;
      EXIT WHEN C_MRH%NOTFOUND IS NULL OR C_MRH%NOTFOUND OR(N1 > 12 AND
                                                            N2 > 1 AND
                                                            N3 > 1 AND
                                                            N4 > 12);
      IF MRH.MRSL > 0 AND N1 <= 12 THEN
        N1            := N1 + 1;
        MRH.MRTHREESL := NVL(MRH.MRTHREESL, 0) + MRH.MRSL; --前N次均量
      END IF;

      IF C_MRH%ROWCOUNT = 1 THEN
        N2           := N2 + 1;
        MRH.MRLASTSL := NVL(MRH.MRLASTSL, 0) + MRH.MRSL; --上次水量
      END IF;

      IF MRH.MRMONTH = TO_CHAR(TO_NUMBER(SUBSTR(P_MONTH, 1, 4)) - 1) || '.' ||
         SUBSTR(P_MONTH, 6, 2) THEN
        N3           := N3 + 1;
        MRH.MRYEARSL := NVL(MRH.MRYEARSL, 0) + MRH.MRSL; --去年同期水量
      END IF;

      IF MRH.MRSL > 0 AND TO_NUMBER(SUBSTR(MRH.MRMONTH, 1, 4)) =
         TO_NUMBER(SUBSTR(P_MONTH, 1, 4)) - 1 THEN
        N4 := N4 + 1;
      END IF;
    END LOOP;

    O_SL_1 := (CASE
                WHEN N1 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRTHREESL / N1, 0)
              END);

    O_SL_2 := (CASE
                WHEN N2 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRLASTSL / N2, 0)
              END);

    O_SL_3 := (CASE
                WHEN N3 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRYEARSL / N3, 0)
              END);

  EXCEPTION
    WHEN OTHERS THEN
      IF C_MRH%ISOPEN THEN
        CLOSE C_MRH;
      END IF;
  END GETMRHIS;
  /*
  工单抄表库回写
  处理：生成抄表资料
  输出：返回 0  执行成功
        返回 -1 执行失败
  */
  PROCEDURE CREATECBGD(P_SBID  IN VARCHAR2, /*水表档案编号*/
                       O_STATE OUT VARCHAR2) /*执行状态*/
   IS
    YH   BS_CUSTINFO%ROWTYPE;
    SB   BS_METERINFO%ROWTYPE;
    MD   BS_METERDOC%ROWTYPE;
    BC   BS_BOOKFRAME%ROWTYPE;
    SBR  BS_METERREAD%ROWTYPE;

    --计划
    CURSOR C_BKSB IS
      SELECT A.CIID,    --用户号
             B.MIID,    --水表档案编号
             B.MISMFID, --营销公司
             B.MIRORDER, --抄表次序
             B.MISTID, --行业分类
             B.MIPID,    --上级水表编号
             B.MICLASS,  --水表级次
             B.MIFLAG, --末级标志
             B.MIRECDATE, --本期抄见日期
             B.MIRCODE, --本期读数
             S.MDMODEL, --计量方式
             B.MIPRIFLAG,  --合收表标志
             D.BFBATCH, --抄表批次
             D.BFRPER,  --抄表员
             B.MIRMON,  --本期抄表月份
             B.MISAFID, --区域
             B.MIIFCHK, --是否考核表(Y-是,N-否 )
             S.MDCALIBER, --表口径(METERCALIBER)
             B.MISIDE,
             B.MIBFID,
             B.MISTATUS
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MIID = P_SBID
         /*AND FCHKCBMK(B.MRMID) = 'Y'*/;
  BEGIN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MIRMON,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MIBFID,
             SB.MISTATUS;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;

        SBR.MRID          := FGETSEQUENCE('METERREAD'); --流水号
        SBR.MRMONTH       := TO_CHAR(SYSDATE,'YYYY.MM'); --当前月份
        SBR.MRSMFID       := SB.MISMFID; --管辖公司
        SBR.MRBFID        := SB.MIBFID; --表册
        SBR.MRBATCH       := BC.BFBATCH; --抄表批次
        SBR.MRRPER        := BC.BFRPER; --抄表员
        SBR.MRRORDER      := SB.MIRORDER; --抄表次序号
        SBR.MRCCODE       := YH.CIID; --用户编号
        SBR.MRMID         := SB.MIID; --水表编号
        SBR.MRSTID        := SB.MISTID; --行业分类
        SBR.MRMPID        := SB.MIPID; --上级水表
        SBR.MRMCLASS      := SB.MICLASS; --水表级次
        SBR.MRMFLAG       := SB.MIFLAG; --末级标志
        SBR.MRCREADATE    := SYSDATE; --创建日期
        SBR.MRINPUTDATE   := NULL; --编辑日期
        SBR.MRREADOK      := 'N'; --抄见标志
        SBR.MRRDATE       := NULL; --抄表日期
        SBR.MRPRDATE      := SB.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        SBR.MRSCODE       := SB.MIRCODE; --上期抄见
        SBR.MRECODE       := NULL; --本期抄见
        SBR.MRSL          := NULL; --本期水量
        SBR.MRFACE        := NULL; --表况
        SBR.MRIFSUBMIT    := 'Y'; --是否提交计费
        SBR.MRIFHALT      := 'N'; --系统停算
        SBR.MRDATASOURCE  := 1; --抄表结果来源
        SBR.MRMEMO        := NULL; --抄表备注
        SBR.MRIFGU        := 'N'; --估表标志
        SBR.MRIFREC       := 'N'; --已计费
        SBR.MRRECDATE     := NULL; --计费日期
        SBR.MRRECSL       := NULL; --应收水量
        SBR.MRADDSL       := 0; --余量
        SBR.MRCHKFLAG     := 'N'; --复核标志
        SBR.MRCHKDATE     := NULL; --复核日期
        SBR.MRCHKPER      := NULL; --复核人员
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  合收表标志
        SBR.MRFACE2       := NULL; --抄见故障
        SBR.MRREQUISITION := 0; --通知单打印次数
        SBR.MRIFCHK       := SB.MIIFCHK; --考核表标志
        SBR.MRINPUTPER    := NULL; --入账人员
        SBR.MRCALIBER     := MD.MDCALIBER; --口径
        SBR.MRSIDE        := SB.MISIDE; --表位
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --是否免抄户(Y-是 N-否)固定量

        --上次水费   至  去年度次均量
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;
    END LOOP;
    CLOSE C_BKSB;
    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;
END;
/

