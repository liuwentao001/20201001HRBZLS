CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_SMS_01" IS
--���ŷ��͹���
  PROCEDURE SEND(P_SENDE           IN VARCHAR2, --������
                 P_SENDTYPE        IN VARCHAR2, --�������
                 P_MODENO          IN VARCHAR2, --ģ����
                 p_istiming        IN VARCHAR2, --�Ƿ�ʱ����
                 p_datetime        IN VARCHAR2, --�Ƿ�ʱ����
                 P_BILEPHONENUMBER IN VARCHAR2, --���պ���
                 P_BILEPHONETEXT   IN VARCHAR2 --ģ�����ݻ��������
                 ) IS

    V_ID NUMBER;--���ŷ��ͱ�Id
    V_C1 VARCHAR2(12);
    V_C2 VARCHAR2(500);
    V_C3 VARCHAR2(500);
    CURSOR C_MN IS
      SELECT C1, C2 FROM PBPARMTEMP;
    TR TSMSSENDCACHE%ROWTYPE;
  BEGIN
      TR.SSENDER      := P_SENDE;       --�����߱�ʶ
      TR.DBEGINTIME   := SYSDATE;       --����ʱ��
      TR.NTIMINGTAG   :=p_istiming;     --��ʱ��־
      TR.DTIMINGTIME  :=to_date(p_datetime,'yyyy-mm-dd hh24:mi:ss');--��ʱ����ʱ��
      TR.NCONTENTTYPE := P_SENDTYPE;    --��������
      TR.EXNUMBER     := NULL;          --��չ����
      TR.CFLAG        := 'N';           --�����־
      TR.RETURNFLAG   := NULL;          --������
      TR.ISMGSTATUS   := NULL;          --���ܷ���ֵ
      TR.STATUSTIME   := NULL;          --������Ӧ״̬
    IF to_number(P_SENDTYPE) > 108 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '����ʧ�ܣ��������' || P_SENDTYPE || 'δ���壡');
    ELSIF  P_SENDTYPE = '101' THEN
        SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
        SELECT FSET_HZ( P_BILEPHONENUMBER,P_BILEPHONETEXT) INTO V_C3 FROM DUAL;
        TR.ID           := V_ID;              --��¼���
        TR.SSENDNO      := P_BILEPHONENUMBER; --���պ���
        TR.SSMSMESSAGE  := V_C3;    --������Ϣ
        spinset( TR);
    ELSIF P_SENDTYPE = '102' THEN
      OPEN C_MN;
      LOOP
        FETCH C_MN
          INTO V_C1, V_C2;
        EXIT WHEN C_MN%NOTFOUND OR C_MN%NOTFOUND IS NULL;
        SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
        if P_BILEPHONETEXT is not  null then
          V_C3          :=P_BILEPHONETEXT;
         else
          V_C3          := V_C2;
        end if;
        SELECT FSET_HZ( V_C1,v_c3) INTO v_c2 FROM DUAL;
        TR.ID           := V_ID; --��¼���
        TR.SSENDNO      := V_C1; --���պ���
        TR.SSMSMESSAGE  := V_C2; --������Ϣ
        spinset( TR);
      END LOOP;
       CLOSE C_MN;
    ELSIF P_SENDTYPE = '103' THEN
      OPEN C_MN;
      LOOP
        FETCH C_MN
          INTO V_C1, V_C2;
        EXIT WHEN C_MN%NOTFOUND OR C_MN%NOTFOUND IS NULL;
        SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
        V_C3  := FSETSMMTEXT(V_C1, V_C2,P_BILEPHONETEXT, '000');
        TR.ID           := V_ID; --��¼���
        TR.SSENDNO      := V_C2; --���պ���
        TR.SSMSMESSAGE  := V_C3; --������Ϣ
        spinset( TR);
      END LOOP;
     CLOSE C_MN;
   ELSE
      OPEN C_MN;
      LOOP
        FETCH C_MN
          INTO V_C1, V_C2;
        EXIT WHEN C_MN%NOTFOUND OR C_MN%NOTFOUND IS NULL;
        SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
        V_C3  := FSETSMMTEXT(V_C1,P_BILEPHONENUMBER, P_SENDTYPE, P_MODENO);
        TR.ID           :=V_ID; --��¼���
        TR.SSENDNO      :=V_C2; --���պ���
        TR.SSMSMESSAGE  :=V_C3 ; --����Ϣ
        spinset( TR);
      END LOOP;
     CLOSE C_MN;
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      ROLLBACK;
  END;

  PROCEDURE spinset(TI TSMSSENDCACHE%ROWTYPE ) AS
  BEGIN
    INSERT INTO TSMSSENDCACHE VALUES TI;
    /*if ti.NTIMINGTAG='1' then
       INSERT INTO TSMSSENDCACHE VALUES TI;
      else
        INSERT INTO TSMSSENDCACHEtimed VALUES TI;
     end if;*/
  END;
   --�û����ź������������ύ
  PROCEDURE spimportnumber  as
    BEGIN
    null;
  END;
   --����Ԥ��
  PROCEDURE SMSEXCEPT(P_CICODE        IN VARCHAR2,
                       P_number        IN VARCHAR2,
                       P_BILEPHONETEXT IN VARCHAR2,
                       P_typeno           IN VARCHAR2,
                       O_TEXT          OUT VARCHAR2) AS

  BEGIN
    SELECT FSETSMMTEXT(P_CICODE,P_number, P_BILEPHONETEXT,P_typeno)
      INTO O_TEXT
      FROM DUAL;
  END;
  --����������˾����
  PROCEDURE spnumbertype(P_number IN VARCHAR2,
                        O_TEXT    OUT VARCHAR2) AS
 begin
    SELECT  FGET_SJLB(P_number)
      INTO O_TEXT
      FROM DUAL;
  end ;
  --���Ų���
  PROCEDURE SMSMSSSTRATEGY AS
    V_ID       NUMBER;
    V_BH       VARCHAR2(11);
    V_NUMBER   VARCHAR2(140);
    MTG        MSSSTRATEGY%ROWTYPE;
    TR         TSMSSENDCACHE%ROWTYPE;
    TYPE TCUR IS REF CURSOR;
    CUR_MM TCUR;
  BEGIN
    BEGIN
      SELECT * INTO MTG FROM MSSSTRATEGY WHERE MSTENABLED = 'Y'  and rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20201, '����δ����,����!');
    END;
    /* INSERT INTO YYYY VALUES(MTG.MSTSTRATEGY);
    COMMENT;*/
    OPEN CUR_MM FOR MTG.MSTSTRATEGY;
    LOOP
      FETCH CUR_MM
        INTO V_BH, V_NUMBER;
      EXIT WHEN CUR_MM%NOTFOUND OR CUR_MM%NOTFOUND IS NULL;
      SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;

      TR.ID           := V_ID; --��¼���
      TR.SSENDER      := 'SYS'; --�����߱�ʶ
      TR.DBEGINTIME   := SYSDATE; --����ʱ��
      TR.NTIMINGTAG   := '0'; --��ʱ��־
      TR.NCONTENTTYPE := 108; --��������
      TR.SSENDNO      := V_NUMBER; --���պ���
      TR.SSMSMESSAGE  := FSETSMMTEXT(V_BH,'','108', '001'); --������Ϣ
      INSERT INTO TSMSSENDCACHE VALUES TR;
    END LOOP;
    COMMIT;
    CLOSE CUR_MM;
    NULL;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      -- RAISE_APPLICATION_ERROR(ERRCODE,SQLERRM);
  END;
  --����  ģ��������ת��
  FUNCTION FSETSMMTEXT(P_CICODE IN VARCHAR2,
                       P_number IN VARCHAR2,
                       P_TYPE   IN VARCHAR2,
                       P_MODENO IN VARCHAR2) RETURN VARCHAR2 AS
    CURSOR C_BUTTROWS IS
      SELECT * FROM MSSEDITINGTOOL;
    R_BUTTER       MSSEDITINGTOOL%ROWTYPE;
    V_LEN          VARCHAR2(2);
    V_MODE         VARCHAR2(500);
    V_CHAR         VARCHAR2(50);
    V_SQL          VARCHAR2(400);
    V_RETEXTNUMBER NUMBER;
  BEGIN
   -- �ж�ģ�������Ƿ�Ϊʵʱ�޸�ģ��,���������ȡ�޸Ĺ���ģ�棬������ȡ�����ģ��
    IF P_MODENO <> '000' THEN
      SELECT TMDMD, TMDLENGTH
        INTO V_MODE, V_LEN
        FROM TSMSSENDMODE
       WHERE TMDLB = P_TYPE
         AND TMDBH = P_MODENO;
    ELSE
      V_MODE := P_TYPE;
      V_LEN  := 'N';
    END IF;
 --�������滻ģ���е������ַ�
    OPEN C_BUTTROWS;
    LOOP
      FETCH C_BUTTROWS
        INTO R_BUTTER;
      EXIT WHEN C_BUTTROWS%NOTFOUND OR C_BUTTROWS%NOTFOUND IS NULL;
      V_RETEXTNUMBER := 0;
      SELECT INSTR(V_MODE, '��' || R_BUTTER.METBUTTERNAME || '��', 1, 1) INSTRING
        INTO V_RETEXTNUMBER
        FROM DUAL;
      IF V_RETEXTNUMBER > 0 THEN
        IF R_BUTTER.METPARAMETERS = 'Y' THEN
          V_SQL := R_BUTTER.METCONTENT || '''' || P_CICODE || '''';
        ELSE
          V_SQL := R_BUTTER.METCONTENT;
        END IF;
        EXECUTE IMMEDIATE V_SQL
          INTO V_CHAR;
        SELECT REPLACE(V_MODE,
                       '��' || R_BUTTER.METBUTTERNAME || '��',
                       V_CHAR)
          INTO V_MODE
          FROM DUAL;
      END IF;
    END LOOP;
    CLOSE C_BUTTROWS;
      --�ж϶���ģ�����Ƿ��������Ƴ���
    IF V_LEN = 'Y' THEN
      --ȡ��ϵͳ����Ķ��ų���
      select  to_number(MSBPARAMETERS) into V_RETEXTNUMBER from mssbasicparameters where MSBID='01';
      --���������ݽ�ȡΪ���Ƴ���
      SELECT SUBSTR(V_MODE, 1, V_RETEXTNUMBER) INTO V_MODE FROM DUAL;
    END IF;
    SELECT FSET_HZ( P_number,V_MODE) INTO V_MODE FROM DUAL;
    RETURN V_MODE;
  EXCEPTION
    When No_Data_Found Then
       RAISE_APPLICATION_ERROR(ERRCODE, 'ģ�涨����󣺸����ģ���в����������'||R_BUTTER.METBUTTERNAME||'���ֶ�');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --���ź�׺
  FUNCTION FSET_HZ(P_NUMBER IN VARCHAR2,P_TEXT IN VARCHAR2) RETURN VARCHAR2 AS
    V_HZ VARCHAR2(60);
    V_TEXT VARCHAR2(900);
  BEGIN
    --���ƶ��ֻ���Ĭ�Ϻ�׺����δ������Ϊ��Ϊ�����й�ˮ��
   --select  MSBPARAMETERS into V_HZ from mssbasicparameters where MSBID='02';
    if V_HZ is null then
       V_HZ :='';
    end if ;
    if  fget_sjlb(P_NUMBER)='A' then
      V_TEXT  :=P_TEXT;
    else
      V_TEXT  :=P_TEXT||V_HZ;
    end if ;

    RETURN V_TEXT;
  END ;
  --�����ֻ��������ļҹ�˾
  FUNCTION FGET_SJLB(P_NO IN VARCHAR2) RETURN VARCHAR2 AS
    LRET VARCHAR2(60);
  BEGIN
     LRET := 'E';
     --�й��ƶ���ͨ����
    IF REGEXP_LIKE(P_NO, '^1(3[4-9]|5[012789]|8[78])\d{8}$') THEN
      LRET := 'A';
    END IF;
    --�й��ƶ�3G����
    IF REGEXP_LIKE(P_NO, '^((157)|(18[78]))[0-9]{8}$') THEN
      LRET := 'A';
    END IF;
    --�й���ͨ��ͨ����
    IF REGEXP_LIKE(P_NO, '^1(([3][012])|([5][6])|([8][56]))[0-9]{8}$') THEN
      LRET := 'B';
    END IF;
    --�й���ͨ3G����
    IF REGEXP_LIKE(P_NO, '^((156)|(18[56]))[0-9]{8}$') THEN
      LRET := 'B';
    END IF;
    --�й�������ͨ����
    IF REGEXP_LIKE(P_NO, '^1(([3][3])|([5][3])|([8][09]))[0-9]{8}$') THEN
      LRET := 'C';
    END IF;
    --�й�����3G����
    IF REGEXP_LIKE(P_NO, '^(18[09])[0-9]{8}$') THEN
      LRET := 'C';
    END IF;
    RETURN LRET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'F';
  END;
END ;
/

