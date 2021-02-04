CREATE OR REPLACE PROCEDURE HRBZLS."FLOW_NEXT" (P_ID       IN VARCHAR2, --����id
                                      P_NO       IN VARCHAR2, --���̺�
                                      P_BILLNO   IN VARCHAR2, --���ݺ�
                                      P_PPER     IN VARCHAR2, --ִ����Ա
                                      P_TYPE     IN VARCHAR2, -- 0 ͨ����1 ���� ,2 ����
                                      P_OPINION  IN VARCHAR2, --�������
                                      P_BILLTYPE IN VARCHAR2, --��������
                                      P_NEXTOPER IN VARCHAR2, --��һ����Ա
                                      P_AUDITING IN VARCHAR2) --�Ƿ��������
 IS
  ---���̶���
  CURSOR C_FLDEFINE(V_ID IN VARCHAR2, V_NO IN VARCHAR2) IS
    SELECT *
      FROM FLOW_DEFINE
     WHERE FID = V_ID
       AND (FNO = V_NO OR V_NO IS NULL)
     ORDER BY FNO;
  --����ִ��
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
  δִ��   CONSTANT VARCHAR2(2) := '0';
  ��ִ��   CONSTANT VARCHAR2(2) := '1';
  ��ǰִ�� CONSTANT VARCHAR2(2) := '2';
  �˵�     CONSTANT VARCHAR2(2) := '3';
  v_count number(10);

BEGIN

  V_ID     := P_ID;
  V_NO     := P_NO;
  V_BILLNO := P_BILLNO;
  --�����ж�
  OPEN C_FLOW_MAIN(V_ID, V_NO, V_BILLNO);
  FETCH C_FLOW_MAIN
    INTO V_FLOW_MAIN;
  --��ǰִ��
  IF C_FLOW_MAIN%ROWCOUNT = 0 THEN
    IF P_TYPE = '0' THEN
      V_NO := V_NO + 1;
    END IF;
  END IF;
  CLOSE C_FLOW_MAIN;
  V_FLOW_EXCLOG.ZRR := P_NEXTOPER;
  /***********�������****************/
  IF V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20012, '������p_id ����id�� ��ֵ����Ϊ null');
  END IF;
  IF V_NO IS NULL THEN
    RAISE_APPLICATION_ERROR(-20012, '������P_NO ���̺š� ��ֵ����Ϊ null');
  END IF;
  IF V_BILLNO IS NULL THEN
    RAISE_APPLICATION_ERROR(-20012,
                            '������P_BILLNO ���ݺš� ��ֵ����Ϊ null');
  END IF;
  IF P_PPER IS NULL THEN
    RAISE_APPLICATION_ERROR(-20012,
                            '������P_PPER ִ����Ա�� ��ֵ����Ϊ null');
  END IF;
  IF P_TYPE IS NULL THEN
    RAISE_APPLICATION_ERROR(-20012,
                            '������P_TYPE ִ����� ��ֵ����Ϊ null');
  END IF;
  IF V_NO = 1 AND P_TYPE = '1' THEN
    RAISE_APPLICATION_ERROR(-20012, '��ǰΪһ�����̣����ɻ���!');
  END IF;

  OPEN C_FLDEFINE(V_ID, V_NO);
  FETCH C_FLDEFINE
    INTO V_FLDEFINE;
  IF C_FLDEFINE%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20012, '����������ϵͳ����δ���壡');
    CLOSE C_FLDEFINE;
  END IF;
  IF C_FLDEFINE%ISOPEN THEN
    CLOSE C_FLDEFINE;
  END IF;
  --����ִ��
  OPEN C_FLOW_MAIN(V_ID, V_NO, V_BILLNO);
  FETCH C_FLOW_MAIN
    INTO V_FLOW_MAIN;

  --��ǰִ��
  IF C_FLOW_MAIN%ROWCOUNT = 0 THEN
    ---��ʼ������
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
        V_FLOW_MAIN.FMSTAUS := ��ǰִ��; --��ǰִ��
        V_FLOW_MAIN.FMOPER  := P_PPER;
        V_FLOW_MAIN.FMDATE  := SYSDATE;
      ELSE
        V_FLOW_MAIN.FMSTAUS := δִ��; --δִ��
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
                              '�������Ѿ���������Ա����������ˢ�µ��ݺ��ٽ��з���!');
    END IF;
    IF (V_FLOW_MAIN.FMSTAUS = 1 OR V_FLOW_MAIN.FMSTAUS = 0) AND P_TYPE = 1 THEN
      RAISE_APPLICATION_ERROR(-20012,
                              '�������Ѿ���������Ա����������ˢ�µ��ݺ��ٽ��л���!');
    END IF;*/

    ---����ִ��
    IF P_TYPE = '0' AND V_FLOW_MAIN.FMSTAUS <> '1' AND P_AUDITING = 'N' THEN
      --ͨ��
      --���µ�ǰͨ��
      UPDATE FLOW_MAIN
         SET FMSTAUS   = ��ִ��,
             FMDATE    = SYSDATE,
             FMOPER    = P_PPER,
             FMOPINION = P_OPINION,
             FMETYPE   = P_TYPE
       WHERE CURRENT OF C_FLOW_MAIN;
      --��������һ����Ϊ���ڴ���״̬
      UPDATE FLOW_MAIN
         SET FMSTAUS   = ��ǰִ��,
             FMDATE    = NULL,
             FMOPER    = NULL,
             FMOPINION = NULL,
             FMETYPE   = P_TYPE
       WHERE FMID = P_ID
         AND FMNO = TO_NUMBER(P_NO) + 1
         AND FMBILLNO = P_BILLNO
         AND (FMSTAUS = '0' OR FMSTAUS = '2' OR FMSTAUS = '3');
      V_STAUS := ��ִ��;
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

      /*PG_EWIDE_CUSTBASE_01.sp_��ʱ��ˮ����('b',--�������
                        P_billNO  ,--���ݱ��
                        fgetpboper     ,--������
                        'Y');*/

        exception when others then
          null;
      end ;
      end if;

    END IF;

    IF P_TYPE = '1' AND V_NO <> 1 THEN
      --����
      --���µ�ǰδ
      UPDATE FLOW_MAIN
         SET FMSTAUS   = δִ��,
             FMDATE    = NULL,
             FMOPER    = NULL,
             FMOPINION = NULL,
             FMETYPE   = P_TYPE
       WHERE CURRENT OF C_FLOW_MAIN;
      --��������һ����Ϊ�����˵�״̬

      SELECT FGETOPERNAME(FMOPER)
        INTO V_FLOW_EXCLOG.ZRR
        FROM FLOW_MAIN
       WHERE FMID = P_ID
         AND FMNO = TO_NUMBER(P_NO) - 1
         AND FMBILLNO = P_BILLNO;
      UPDATE FLOW_MAIN
         SET FMSTAUS = �˵�,
             FMDATE  = SYSDATE,
             --       FMOPER    = NULL,
             FMOPINION = P_OPINION,
             FMETYPE   = P_TYPE
       WHERE FMID = P_ID
         AND FMNO = TO_NUMBER(P_NO) - 1
         AND FMBILLNO = P_BILLNO;
      V_STAUS := �˵�;
    END IF;

    --��Աִ�м�¼
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
         AND T.FMSTAUS = ��ǰִ��
          OR FMSTAUS = �˵�;*/
          --20141215�޸�  hb
                SELECT *
        INTO V_FLOW_MAIN
        FROM FLOW_MAIN T
       WHERE T.FMBILLNO = P_BILLNO
         AND ( T.FMSTAUS = ��ǰִ��   OR t.FMSTAUS = �˵�) ;
          

      SELECT COUNT(FMID)
        INTO V_NUM2
        FROM FLOW_MAIN
       WHERE FMBILLNO = P_BILLNO;
      SELECT COUNT(FMID)
        INTO V_NUM3
        FROM FLOW_MAIN
       WHERE FMBILLNO = P_BILLNO
         AND FMSTAUS = ��ִ��;
      IF V_NUM2 = V_NUM3 THEN
        V_FLOW_EXCLOG.WCDATE := SYSDATE;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        V_FLOW_EXCLOG.WCDATE := SYSDATE;
    END;
    V_FLDEFINE.FBILLSTATUS := 'Y';
    V_FLOW_EXCLOG.BILLID   := P_BILLNO; --���ݱ��
    V_FLOW_EXCLOG.BILLTYPE := P_BILLTYPE; --�������
    V_FLOW_EXCLOG.TJR      := FGETOPERNAME(P_PPER); --�ύ��Ա
    --����״̬
    OPEN C_FLDEFINE(V_FLOW_MAIN.FMID, V_FLOW_MAIN.FMNO);
    FETCH C_FLDEFINE
      INTO V_FLDEFINE;
    IF C_FLDEFINE%ISOPEN THEN
      CLOSE C_FLDEFINE;
    END IF;
    IF P_TYPE = 1 AND V_NO <> 1 THEN
      V_FLOW_EXCLOG.BILLSTATUS := 'B'; --����
    ELSE
      IF V_FLOW_EXCLOG.WCDATE IS NULL THEN
        V_FLOW_EXCLOG.BILLSTATUS := V_FLDEFINE.FBILLSTATUS;
      ELSE
        V_FLOW_EXCLOG.BILLSTATUS := 'Y';
      END IF;
    END IF;
    V_FLOW_EXCLOG.FLOWSTATUS := V_FLDEFINE.FNAME; --����״̬
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
         AND T.FMSTAUS = ��ǰִ��
          OR FMSTAUS = �˵�;*/
              --20141215�޸�  hb
                SELECT *
        INTO V_FLOW_MAIN
        FROM FLOW_MAIN T
       WHERE T.FMBILLNO = P_BILLNO
         AND (T.FMSTAUS = ��ǰִ��    OR FMSTAUS = �˵�) ;
          
      SELECT COUNT(FMID)
        INTO V_NUM2
        FROM FLOW_MAIN
       WHERE FMBILLNO = P_BILLNO;
      SELECT COUNT(FMID)
        INTO V_NUM3
        FROM FLOW_MAIN
       WHERE FMBILLNO = P_BILLNO
         AND FMSTAUS = ��ִ��;
      IF V_NUM2 = V_NUM3 THEN
        --V_FLOW_EXCLOG.WCDATE := SYSDATE;
        NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        V_FLOW_EXCLOG.WCDATE := SYSDATE;
    END;
    V_FLOW_EXCLOG.BILLID   := P_BILLNO; --���ݱ��
    V_FLOW_EXCLOG.BILLTYPE := P_BILLTYPE; --�������
    --����״̬
    OPEN C_FLDEFINE(V_FLOW_MAIN.FMID, V_FLOW_MAIN.FMNO);
    FETCH C_FLDEFINE
      INTO V_FLDEFINE;
    IF C_FLDEFINE%ISOPEN THEN
      CLOSE C_FLDEFINE;
    END IF;
    IF P_TYPE = 1 AND V_NO <> 1 THEN
      V_FLOW_EXCLOG.BILLSTATUS := 'B'; --����
    ELSE
      IF V_FLOW_EXCLOG.WCDATE IS NULL THEN
        V_FLOW_EXCLOG.BILLSTATUS := V_FLDEFINE.FBILLSTATUS;
      ELSE
        V_FLOW_EXCLOG.BILLSTATUS := 'Y';
      END IF;
    END IF;
    V_FLOW_EXCLOG.FLOWSTATUS := V_FLDEFINE.FNAME; --����״̬
    V_FLOW_EXCLOG.ZRR        := P_NEXTOPER; --������
    V_FLOW_EXCLOG.FQR        := FGETOPERNAME(P_PPER); --������
    V_FLOW_EXCLOG.FQDATE     := SYSDATE; --����
    V_FLOW_EXCLOG.SMFID      := FGETPBSYSMANA;
    V_FLOW_EXCLOG.WCDATE     := V_FLOW_EXCLOG.WCDATE;
    V_FLOW_EXCLOG.TJR        := FGETOPERNAME(P_PPER); --�ύ��Ա
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

 /* --���ŷ���
  IF P_TYPE = '0' OR P_TYPE = '1' AND P_AUDITING = 'N' THEN
    FOR I IN 1 .. TOOLS.FBOUNDPARA2(P_NEXTOPER) LOOP
      V_NEXTOPER := TOOLS.FMID(P_NEXTOPER, I, 'Y', ',');
      IF V_NEXTOPER IS NOT NULL THEN
        SELECT SEQ_TRECEIVE.NEXTVAL INTO TR.ID FROM DUAL; --��¼���
        TR.SSENDER      := P_PPER; --�����߱�ʶ
        TR.DBEGINTIME   := SYSDATE; --����ʱ��
        TR.NTIMINGTAG   := '1'; --��ʱ��־
        TR.DTIMINGTIME  := NULL; --��ʱ����ʱ��
        TR.NCONTENTTYPE := '100'; --�������� -- ���̶���֪ͨ
        TR.EXNUMBER     := NULL; --��չ����
        BEGIN
          SELECT OATEL
            INTO TR.SSENDNO
            FROM OPERACCNT OA
           WHERE OA.OAID = V_NEXTOPER; --���պ���
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        TR.SSMSMESSAGE := FGETOPERNAME(P_PPER) || ' ����ġ�' ||
                          FGETBILLNAME01(P_BILLTYPE) || '��' || '���ݺ�Ϊ:<' ||
                          P_BILLNO || '>�Ѿ�����' || FGETOPERNAME(V_NEXTOPER) ||
                          '�������������촦��!';
        TR.CFLAG       := 'N'; --�����־
        TR.RETURNFLAG  := NULL; --���ͽ��
        TR.ISMGSTATUS  := NULL; --���ܷ���ֵ
        TR.STATUSTIME  := NULL; --������Ӧ״̬
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

