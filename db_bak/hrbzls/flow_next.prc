CREATE OR REPLACE PROCEDURE HRBZLS."FLOW_NEXT" (P_ID       IN VARCHAR2, --流程id
                                      P_NO       IN VARCHAR2, --流程号
                                      P_BILLNO   IN VARCHAR2, --单据号
                                      P_PPER     IN VARCHAR2, --执行人员
                                      P_TYPE     IN VARCHAR2, -- 0 通过，1 回退 ,2 处理
                                      P_OPINION  IN VARCHAR2, --审批意见
                                      P_BILLTYPE IN VARCHAR2, --工单类型
                                      P_NEXTOPER IN VARCHAR2, --下一步人员
                                      P_AUDITING IN VARCHAR2) --是否审批完成
 IS
  ---流程定义
  CURSOR C_FLDEFINE(V_ID IN VARCHAR2, V_NO IN VARCHAR2) IS
    SELECT *
      FROM FLOW_DEFINE
     WHERE FID = V_ID
       AND (FNO = V_NO OR V_NO IS NULL)
     ORDER BY FNO;
  --流程执行
  CURSOR C_FLOW_MAIN(V_ID     IN VARCHAR2,
                     V_NO     IN VARCHAR2,
                     V_BILLNO IN VARCHAR2) IS
    SELECT *
      FROM FLOW_MAIN
     WHERE FMID = V_ID
       AND FMNO = V_NO
       AND FMBILLNO = V_BILLNO
       FOR UPDATE NOWAIT
     ORDER BY FMNO;
  V_FLOW_MAIN     FLOW_MAIN%ROWTYPE;
  V_FLDEFINE      FLOW_DEFINE%ROWTYPE;
  V_STAUS         FLOW_MAIN.FMSTAUS%TYPE;
  V_FLOW_OPEREXEC FLOW_OPEREXEC%ROWTYPE;
  V_ID            FLOW_MAIN.FMID%TYPE;
  V_NO            FLOW_MAIN.FMNO%TYPE;
  V_BILLNO        FLOW_MAIN.FMBILLNO%TYPE;
  V_FLOW_EXCLOG   FLOW_EXCLOG%ROWTYPE;
  V_FLOWSTAUS     VARCHAR2(10);
  V_NUM           NUMBER := 0;
  V_NUM2          NUMBER := 0;
  V_NUM3          NUMBER := 0;
  TR              TSMSSENDCACHE%ROWTYPE;
  V_NEXTOPER      VARCHAR2(100);
  未执行   CONSTANT VARCHAR2(2) := '0';
  已执行   CONSTANT VARCHAR2(2) := '1';
  当前执行 CONSTANT VARCHAR2(2) := '2';
  退单     CONSTANT VARCHAR2(2) := '3';
  v_count number(10);

BEGIN

  V_ID     := P_ID;
  V_NO     := P_NO;
  V_BILLNO := P_BILLNO;
  --流程判断
  OPEN C_FLOW_MAIN(V_ID, V_NO, V_BILLNO);
  FETCH C_FLOW_MAIN
    INTO V_FLOW_MAIN;
  --当前执行
  IF C_FLOW_MAIN%ROWCOUNT = 0 THEN
    IF P_TYPE = '0' THEN
      V_NO := V_NO + 1;
    END IF;
  END IF;
  CLOSE C_FLOW_MAIN;
  V_FLOW_EXCLOG.ZRR := P_NEXTOPER;
  /***********参数检查****************/
  IF V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20012, '参数《p_id 流程id》 传值不能为 null');
  END IF;
  IF V_NO IS NULL THEN
    RAISE_APPLICATION_ERROR(-20012, '参数《P_NO 流程号》 传值不能为 null');
  END IF;
  IF V_BILLNO IS NULL THEN
    RAISE_APPLICATION_ERROR(-20012,
                            '参数《P_BILLNO 单据号》 传值不能为 null');
  END IF;
  IF P_PPER IS NULL THEN
    RAISE_APPLICATION_ERROR(-20012,
                            '参数《P_PPER 执行人员》 传值不能为 null');
  END IF;
  IF P_TYPE IS NULL THEN
    RAISE_APPLICATION_ERROR(-20012,
                            '参数《P_TYPE 执行类别》 传值不能为 null');
  END IF;
  IF V_NO = 1 AND P_TYPE = '1' THEN
    RAISE_APPLICATION_ERROR(-20012, '当前为一级流程，不可回退!');
  END IF;

  OPEN C_FLDEFINE(V_ID, V_NO);
  FETCH C_FLDEFINE
    INTO V_FLDEFINE;
  IF C_FLDEFINE%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20012, '传入流程在系统中尚未定义！');
    CLOSE C_FLDEFINE;
  END IF;
  IF C_FLDEFINE%ISOPEN THEN
    CLOSE C_FLDEFINE;
  END IF;
  --流程执行
  OPEN C_FLOW_MAIN(V_ID, V_NO, V_BILLNO);
  FETCH C_FLOW_MAIN
    INTO V_FLOW_MAIN;

  --当前执行
  IF C_FLOW_MAIN%ROWCOUNT = 0 THEN
    ---初始化流程
    OPEN C_FLDEFINE(V_ID, NULL);
    LOOP
      FETCH C_FLDEFINE
        INTO V_FLDEFINE;
      EXIT WHEN C_FLDEFINE%NOTFOUND OR C_FLDEFINE%NOTFOUND IS NULL;
      V_FLOW_MAIN          := NULL;
      V_FLOW_MAIN.FMID     := V_FLDEFINE.FID;
      V_FLOW_MAIN.FMNO     := V_FLDEFINE.FNO;
      V_FLOW_MAIN.FMBILLNO := V_BILLNO;
      IF V_FLDEFINE.FNO = 1 THEN
        V_FLOW_MAIN.FMSTAUS := 当前执行; --当前执行
        V_FLOW_MAIN.FMOPER  := P_PPER;
        V_FLOW_MAIN.FMDATE  := SYSDATE;
      ELSE
        V_FLOW_MAIN.FMSTAUS := 未执行; --未执行
      END IF;

      V_FLOW_MAIN.FMOPINION := NULL;
      V_FLOW_MAIN.FMETYPE   := NULL;
      INSERT INTO FLOW_MAIN VALUES V_FLOW_MAIN;
    END LOOP;
    IF C_FLDEFINE%ISOPEN THEN
      CLOSE C_FLDEFINE;
    END IF;
  ELSE
    /*   IF (V_FLOW_MAIN.FMSTAUS = 1 OR V_FLOW_MAIN.FMSTAUS = 0) AND P_TYPE = 0 THEN
      RAISE_APPLICATION_ERROR(-20012,
                              '该流程已经由其他人员做出处理，请刷新单据后再进行发送!');
    END IF;
    IF (V_FLOW_MAIN.FMSTAUS = 1 OR V_FLOW_MAIN.FMSTAUS = 0) AND P_TYPE = 1 THEN
      RAISE_APPLICATION_ERROR(-20012,
                              '该流程已经由其他人员做出处理，请刷新单据后再进行回退!');
    END IF;*/

    ---流程执行
    IF P_TYPE = '0' AND V_FLOW_MAIN.FMSTAUS <> '1' AND P_AUDITING = 'N' THEN
      --通过
      --更新当前通过
      UPDATE FLOW_MAIN
         SET FMSTAUS   = 已执行,
             FMDATE    = SYSDATE,
             FMOPER    = P_PPER,
             FMOPINION = P_OPINION,
             FMETYPE   = P_TYPE
       WHERE CURRENT OF C_FLOW_MAIN;
      --更新新下一流程为正在处理状态
      UPDATE FLOW_MAIN
         SET FMSTAUS   = 当前执行,
             FMDATE    = NULL,
             FMOPER    = NULL,
             FMOPINION = NULL,
             FMETYPE   = P_TYPE
       WHERE FMID = P_ID
         AND FMNO = TO_NUMBER(P_NO) + 1
         AND FMBILLNO = P_BILLNO
         AND (FMSTAUS = '0' OR FMSTAUS = '2' OR FMSTAUS = '3');
      V_STAUS := 已执行;
      if P_NO='2' then
      begin

      select count(*) into  v_count
        from billmain t, flow_define t1
       where bmflag2 = fid
         and t.bmid = '199'
         and fid = P_ID
         and fno = P_NO
         and fno=2
          ;
      if v_count>0 then
        null;
      end if;

      /*PG_EWIDE_CUSTBASE_01.sp_临时用水管理('b',--单据类别
                        P_billNO  ,--单据编号
                        fgetpboper     ,--审批人
                        'Y');*/

        exception when others then
          null;
      end ;
      end if;

    END IF;

    IF P_TYPE = '1' AND V_NO <> 1 THEN
      --回退
      --更新当前未
      UPDATE FLOW_MAIN
         SET FMSTAUS   = 未执行,
             FMDATE    = NULL,
             FMOPER    = NULL,
             FMOPINION = NULL,
             FMETYPE   = P_TYPE
       WHERE CURRENT OF C_FLOW_MAIN;
      --更新新上一流程为正在退单状态

      SELECT FGETOPERNAME(FMOPER)
        INTO V_FLOW_EXCLOG.ZRR
        FROM FLOW_MAIN
       WHERE FMID = P_ID
         AND FMNO = TO_NUMBER(P_NO) - 1
         AND FMBILLNO = P_BILLNO;
      UPDATE FLOW_MAIN
         SET FMSTAUS = 退单,
             FMDATE  = SYSDATE,
             --       FMOPER    = NULL,
             FMOPINION = P_OPINION,
             FMETYPE   = P_TYPE
       WHERE FMID = P_ID
         AND FMNO = TO_NUMBER(P_NO) - 1
         AND FMBILLNO = P_BILLNO;
      V_STAUS := 退单;
    END IF;

    --人员执行记录
    V_FLOW_OPEREXEC.FEFID    := V_FLOW_MAIN.FMID;
    V_FLOW_OPEREXEC.FEFNO    := V_FLOW_MAIN.FMNO;
    V_FLOW_OPEREXEC.FEOPER   := P_PPER;
    V_FLOW_OPEREXEC.FESTATUS := V_STAUS;
    V_FLOW_OPEREXEC.FEDATE   := SYSDATE;
    V_FLOW_OPEREXEC.FMBILLNO := V_FLOW_MAIN.FMBILLNO;
    V_FLOW_OPEREXEC.FMEMO    := P_OPINION;
    IF (P_TYPE = '0' OR P_TYPE = '1') THEN
      INSERT INTO FLOW_OPEREXEC VALUES V_FLOW_OPEREXEC;
    END IF;
  END IF;
  --COMMIT;
  IF C_FLOW_MAIN%ISOPEN THEN
    CLOSE C_FLOW_MAIN;
  END IF;

  SELECT COUNT(BILLID) INTO V_NUM FROM FLOW_EXCLOG WHERE BILLID = P_BILLNO;
  IF V_NUM > 0 THEN
    BEGIN
/*      SELECT *
        INTO V_FLOW_MAIN
        FROM FLOW_MAIN T
       WHERE T.FMBILLNO = P_BILLNO
         AND T.FMSTAUS = 当前执行
          OR FMSTAUS = 退单;*/
          --20141215修改  hb
                SELECT *
        INTO V_FLOW_MAIN
        FROM FLOW_MAIN T
       WHERE T.FMBILLNO = P_BILLNO
         AND ( T.FMSTAUS = 当前执行   OR t.FMSTAUS = 退单) ;
          

      SELECT COUNT(FMID)
        INTO V_NUM2
        FROM FLOW_MAIN
       WHERE FMBILLNO = P_BILLNO;
      SELECT COUNT(FMID)
        INTO V_NUM3
        FROM FLOW_MAIN
       WHERE FMBILLNO = P_BILLNO
         AND FMSTAUS = 已执行;
      IF V_NUM2 = V_NUM3 THEN
        V_FLOW_EXCLOG.WCDATE := SYSDATE;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        V_FLOW_EXCLOG.WCDATE := SYSDATE;
    END;
    V_FLDEFINE.FBILLSTATUS := 'Y';
    V_FLOW_EXCLOG.BILLID   := P_BILLNO; --单据编号
    V_FLOW_EXCLOG.BILLTYPE := P_BILLTYPE; --单据类别
    V_FLOW_EXCLOG.TJR      := FGETOPERNAME(P_PPER); --提交人员
    --工单状态
    OPEN C_FLDEFINE(V_FLOW_MAIN.FMID, V_FLOW_MAIN.FMNO);
    FETCH C_FLDEFINE
      INTO V_FLDEFINE;
    IF C_FLDEFINE%ISOPEN THEN
      CLOSE C_FLDEFINE;
    END IF;
    IF P_TYPE = 1 AND V_NO <> 1 THEN
      V_FLOW_EXCLOG.BILLSTATUS := 'B'; --回退
    ELSE
      IF V_FLOW_EXCLOG.WCDATE IS NULL THEN
        V_FLOW_EXCLOG.BILLSTATUS := V_FLDEFINE.FBILLSTATUS;
      ELSE
        V_FLOW_EXCLOG.BILLSTATUS := 'Y';
      END IF;
    END IF;
    V_FLOW_EXCLOG.FLOWSTATUS := V_FLDEFINE.FNAME; --流程状态
    UPDATE FLOW_EXCLOG
       SET FLOWSTATUS = V_FLOW_EXCLOG.FLOWSTATUS,
           BILLSTATUS = V_FLOW_EXCLOG.BILLSTATUS,
           ZRR        = V_FLOW_EXCLOG.ZRR,
           --FQR        = V_FLOW_EXCLOG.FQR,
           TJR    = V_FLOW_EXCLOG.TJR,
           WCDATE = V_FLOW_EXCLOG.WCDATE
     WHERE BILLID = V_FLOW_EXCLOG.BILLID
       AND BILLTYPE = V_FLOW_EXCLOG.BILLTYPE;
  ELSE
    BEGIN
/*      SELECT *
        INTO V_FLOW_MAIN
        FROM FLOW_MAIN T
       WHERE T.FMBILLNO = P_BILLNO
         AND T.FMSTAUS = 当前执行
          OR FMSTAUS = 退单;*/
              --20141215修改  hb
                SELECT *
        INTO V_FLOW_MAIN
        FROM FLOW_MAIN T
       WHERE T.FMBILLNO = P_BILLNO
         AND (T.FMSTAUS = 当前执行    OR FMSTAUS = 退单) ;
          
      SELECT COUNT(FMID)
        INTO V_NUM2
        FROM FLOW_MAIN
       WHERE FMBILLNO = P_BILLNO;
      SELECT COUNT(FMID)
        INTO V_NUM3
        FROM FLOW_MAIN
       WHERE FMBILLNO = P_BILLNO
         AND FMSTAUS = 已执行;
      IF V_NUM2 = V_NUM3 THEN
        --V_FLOW_EXCLOG.WCDATE := SYSDATE;
        NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        V_FLOW_EXCLOG.WCDATE := SYSDATE;
    END;
    V_FLOW_EXCLOG.BILLID   := P_BILLNO; --单据编号
    V_FLOW_EXCLOG.BILLTYPE := P_BILLTYPE; --单据类别
    --工单状态
    OPEN C_FLDEFINE(V_FLOW_MAIN.FMID, V_FLOW_MAIN.FMNO);
    FETCH C_FLDEFINE
      INTO V_FLDEFINE;
    IF C_FLDEFINE%ISOPEN THEN
      CLOSE C_FLDEFINE;
    END IF;
    IF P_TYPE = 1 AND V_NO <> 1 THEN
      V_FLOW_EXCLOG.BILLSTATUS := 'B'; --回退
    ELSE
      IF V_FLOW_EXCLOG.WCDATE IS NULL THEN
        V_FLOW_EXCLOG.BILLSTATUS := V_FLDEFINE.FBILLSTATUS;
      ELSE
        V_FLOW_EXCLOG.BILLSTATUS := 'Y';
      END IF;
    END IF;
    V_FLOW_EXCLOG.FLOWSTATUS := V_FLDEFINE.FNAME; --流程状态
    V_FLOW_EXCLOG.ZRR        := P_NEXTOPER; --责任人
    V_FLOW_EXCLOG.FQR        := FGETOPERNAME(P_PPER); --发起人
    V_FLOW_EXCLOG.FQDATE     := SYSDATE; --发起
    V_FLOW_EXCLOG.SMFID      := FGETPBSYSMANA;
    V_FLOW_EXCLOG.WCDATE     := V_FLOW_EXCLOG.WCDATE;
    V_FLOW_EXCLOG.TJR        := FGETOPERNAME(P_PPER); --提交人员
    INSERT INTO FLOW_EXCLOG VALUES V_FLOW_EXCLOG;
  END IF;
  IF P_AUDITING = 'Y' THEN

    UPDATE FLOW_MAIN
       SET FMSTAUS = '1', FMDATE = SYSDATE, FMOPER = P_PPER
     WHERE FMID = V_ID
       AND FMNO = V_NO
       AND FMBILLNO = V_BILLNO;

    UPDATE FLOW_EXCLOG
       SET /*FLOWSTATUS = V_FLOW_EXCLOG.FLOWSTATUS,*/ BILLSTATUS = 'Y',
           ZRR        = FGETOPERNAME(P_PPER),
           WCDATE     = SYSDATE
     WHERE BILLID = V_BILLNO
       AND BILLTYPE = P_BILLTYPE;

  END IF;

 /* --短信发送
  IF P_TYPE = '0' OR P_TYPE = '1' AND P_AUDITING = 'N' THEN
    FOR I IN 1 .. TOOLS.FBOUNDPARA2(P_NEXTOPER) LOOP
      V_NEXTOPER := TOOLS.FMID(P_NEXTOPER, I, 'Y', ',');
      IF V_NEXTOPER IS NOT NULL THEN
        SELECT SEQ_TRECEIVE.NEXTVAL INTO TR.ID FROM DUAL; --记录编号
        TR.SSENDER      := P_PPER; --发送者标识
        TR.DBEGINTIME   := SYSDATE; --请求时间
        TR.NTIMINGTAG   := '1'; --定时标志
        TR.DTIMINGTIME  := NULL; --定时发送时间
        TR.NCONTENTTYPE := '100'; --短信类型 -- 流程短信通知
        TR.EXNUMBER     := NULL; --扩展号码
        BEGIN
          SELECT OATEL
            INTO TR.SSENDNO
            FROM OPERACCNT OA
           WHERE OA.OAID = V_NEXTOPER; --接收号码
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        TR.SSMSMESSAGE := FGETOPERNAME(P_PPER) || ' 发起的《' ||
                          FGETBILLNAME01(P_BILLTYPE) || '》' || '单据号为:<' ||
                          P_BILLNO || '>已经发至' || FGETOPERNAME(V_NEXTOPER) ||
                          '审批，请您尽快处理!';
        TR.CFLAG       := 'N'; --处理标志
        TR.RETURNFLAG  := NULL; --发送结果
        TR.ISMGSTATUS  := NULL; --网管返回值
        TR.STATUSTIME  := NULL; --网管响应状态
        IF TR.SSENDNO IS NOT NULL THEN
          PG_EWIDE_SMS_01.SPINSET(TR);
        END IF;
      END IF;
    END LOOP;
  END IF;
*/
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF C_FLOW_MAIN%ISOPEN THEN
      CLOSE C_FLOW_MAIN;
    END IF;
    IF C_FLDEFINE%ISOPEN THEN
      CLOSE C_FLDEFINE;
    END IF;
    RAISE_APPLICATION_ERROR(-20012, SQLERRM);
END;
/

