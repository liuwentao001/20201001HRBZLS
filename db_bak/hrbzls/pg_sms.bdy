CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_SMS" IS
--���ŷ��͹���
  PROCEDURE SEND(P_SENDE           IN VARCHAR2, --������
                 P_SENDTYPE        IN VARCHAR2, --�������
                 P_MODENO          IN VARCHAR2, --ģ����
                 p_istiming        IN VARCHAR2, --�Ƿ�ʱ����
                 p_datetime        IN VARCHAR2, --�Ƿ�ʱ����
                 P_BILEPHONENUMBER IN VARCHAR2, --���պ���
                 P_BILEPHONETEXT   IN VARCHAR2, --ģ�����ݻ��������
                 P_BATCH           IN VARCHAR2
                 ) IS

    V_ID NUMBER;--���ŷ��ͱ�Id
    V_C1 VARCHAR2(12);
    V_C2 VARCHAR2(500);
    V_C3 VARCHAR2(500);
    CURSOR C_MN IS
      --SELECT C1, C2 FROM PBPARMNNOCOMMIT;
      SELECT * FROM pbparmtemp_sms where c4=P_BATCH;


    TR TSMSSENDCACHE%ROWTYPE;
    QF ˮ��Ƿ��%ROWTYPE;
    PB pbparmtemp_sms%ROWTYPE;

    p_type      varchar2(200); --���
    p_mdno      varchar2(200); --ģ����
    P_name      VARCHAR2(200); --��Ա����
    P_hm        VARCHAR2(200); --����
    P_hh        VARCHAR2(200); --����
    p_dz        varchar2(200); --��ַ
    P_qfsl      VARCHAR2(200); --Ƿ��ˮ��
    P_qfje      VARCHAR2(200); --Ƿ�ѽ��
    P_qfbs      VARCHAR2(200); --Ƿ�ѱ���
    P_date      VARCHAR2(200); --����
    P_radatemin VARCHAR2(200); --������������
    P_radatemax VARCHAR2(200); --�����������
    P_str1      VARCHAR2(200); --���
    P_str2      VARCHAR2(200); --����ˮ��
    P_str3      VARCHAR2(200); --����ˮ��
    P_MONTH     VARCHAR2(200); --��ǰ�·�
    P_YR        VARCHAR2(200); --X��X��
    P_QS        VARCHAR2(200); --Ƿ������
    P_WYQF      VARCHAR2(200); --����Ƿ��

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
          INTO PB;
        EXIT WHEN C_MN%NOTFOUND OR C_MN%NOTFOUND IS NULL;
        SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
        if P_BILEPHONETEXT is not  null then
          V_C3          :=P_BILEPHONETEXT;
         else
          V_C3          := PB.C2;
        end if;
        SELECT FSET_HZ( PB.C1,v_c3) INTO PB.C2 FROM DUAL;
        TR.ID           := V_ID; --��¼���
        TR.SSENDNO      := PB.C1; --���պ���
        TR.SSMSMESSAGE  := PB.C2; --������Ϣ
        spinset( TR);
      END LOOP;
       CLOSE C_MN;
    ELSIF P_SENDTYPE = '103' THEN
      OPEN C_MN;
      LOOP
        FETCH C_MN
          INTO PB;
        EXIT WHEN C_MN%NOTFOUND OR C_MN%NOTFOUND IS NULL;
        SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
        V_C3  := FSETSMMTEXT(PB.C1,PB.C2,P_BILEPHONETEXT, '000');
        TR.ID           := V_ID; --��¼���
        TR.SSENDNO      := PB.C2; --���պ���
        TR.SSMSMESSAGE  := V_C3; --������Ϣ
        spinset( TR);
      END LOOP;
     CLOSE C_MN;
   ELSE
      OPEN C_MN;
      LOOP
        FETCH C_MN
          INTO PB;
        EXIT WHEN C_MN%NOTFOUND OR C_MN%NOTFOUND IS NULL;
        --��ѯǷ�������м��
        SELECT * INTO QF FROM ˮ��Ƿ�� t where t.���Ϻ�=PB.C1;
        if QF.���Ϻ� is not null then
           SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
          --V_C3  := FSETSMMTEXT(PB.C1,P_BILEPHONENUMBER, P_SENDTYPE, P_MODENO);
          if P_SENDTYPE = '104' then
             null;
          elsif P_SENDTYPE = '105' then
          --�𾴵���ˮ����������Ϊ�ǿͻ����Ʃϣ���ַΪ���û���ַ�ϵ�ˮ���ǵ�ǰ�·ݩ��µĳ�����ΪX�֣����Ϊ�ǵ�ǰ�·ݩ�Ԫ���뾡��ɷѡ�������������ˮ���޹�˾����ˮ���ߣ�96390��
                if P_MODENO='001' then
                   p_type       :=  P_SENDTYPE;  --���
                  p_mdno       :=  P_MODENO;  --ģ����
                  P_name       :=  null;  --��Ա����
                  P_hm         :=  null;  --����
                  P_hh         :=  QF.���Ϻ�;  --����
                  p_dz         :=  QF.�û���ַ;  --��ַ
                  P_qfsl       :=  null;  --Ƿ��ˮ��
                  P_qfje       :=  null;  --Ƿ�ѽ��
                  P_qfbs       :=  null;  --Ƿ�ѱ���
                  P_date       :=  null;  --����
                  P_radatemin  :=  null;  --������������
                  P_radatemax  :=  null;  --�����������
                  P_str1       :=  null;  --���
                  P_str2       :=  QF.����ˮ��;  --Ԥ����
                  P_str3       :=  QF.���ºϼ�Ƿ��;  --Ԥ����
                  P_MONTH      :=  to_char(sysdate,'yyyy.mm');  --��ǰ�·�
                  P_YR         := null;
                  P_QS         := null;
                  P_WYQF       := null;
                elsif P_MODENO='002' then
                --�𾴵���ˮ����������Ϊ���û��ũϣ���ַΪ���û���ַ�ϵ�ˮ�����³���ˮ���Ǳ���ˮ���϶֣����Ϊ�Ǳ���ˮ�ѩ�Ԫ�����⣬��Ƿ�ϩ�Ƿ����������ˮ�ѩ�����Ƿ�ѩ�Ԫ�����������ɽ𣩣��뾡����ɡ�������������ˮ���޹�˾����ˮ���ߣ�96390��
                  p_type       :=  P_SENDTYPE;  --���
                  p_mdno       :=  P_MODENO;  --ģ����
                  P_name       :=  null;  --��Ա����
                  P_hm         :=  null;  --����
                  P_hh         :=  QF.���Ϻ�;  --����
                  p_dz         :=  QF.�û���ַ;  --��ַ
                  P_qfsl       :=  null;  --Ƿ��ˮ��
                  P_qfje       :=  null;  --Ƿ�ѽ��
                  P_qfbs       :=  null;  --Ƿ�ѱ���
                  P_date       :=  null;  --����
                  P_radatemin  :=  null;  --������������
                  P_radatemax  :=  null;  --�����������
                  P_str1       :=  null;  --���
                  P_str2       :=  QF.����ˮ��;  --Ԥ����
                  P_str3       :=  QF.���ºϼ�Ƿ��;  --Ԥ����
                  P_MONTH      :=  to_char(sysdate,'yyyy.mm');  --��ǰ�·�
                  P_YR         := null;
                  P_QS         := QF.Ƿ������;
                  P_WYQF       := QF.�ϼ�Ƿ��-QF.���ºϼ�Ƿ��;
                end if;



          elsif P_SENDTYPE = '106' then
                if P_MODENO='001' then
                --�𾴵���ˮ����������Ϊ���û��ũϣ���ַΪ���û���ַ�ϵ�ˮ����ֹ����X��X�թϣ���Ƿˮ�ѩ�Ƿ�ѽ���Ԫ�����������ɽ𣩣��뾡����ɡ�������������ˮ���޹�˾����ˮ���ߣ�96390��
                   p_type       :=  P_SENDTYPE;  --���
                  p_mdno       :=  P_MODENO;  --ģ����
                  P_name       :=  null;  --��Ա����
                  P_hm         :=  null;  --����
                  P_hh         :=  QF.���Ϻ�;  --����
                  p_dz         :=  QF.�û���ַ;  --��ַ
                  P_qfsl       :=  null;  --Ƿ��ˮ��
                  P_qfje       :=  QF.�ϼ�Ƿ��;  --Ƿ�ѽ��
                  P_qfbs       :=  null;  --Ƿ�ѱ���
                  P_date       :=  null;  --����
                  P_radatemin  :=  null;  --������������
                  P_radatemax  :=  null;  --�����������
                  P_str1       :=  null;  --���
                  P_str2       :=  null;  --Ԥ����
                  P_str3       :=  null;  --Ԥ����
                  P_MONTH      :=  null;  --��ǰ�·�
                  P_YR         := TO_CHAR(SYSDATE,'MM')||'��'||TO_CHAR(SYSDATE,'DD')||'��'; --X��X��
                  P_QS         := null;
                  P_WYQF       := null;
                end if;
          elsif P_SENDTYPE = '107' then
                null;
          ELSIF P_SENDTYPE = '109' THEN
                --�𾴵���ˮ����������Ϊ���û��ũϣ���ַΪ���û���ַ�ϵ�ˮ��������ˮ��˾����Ԥ��ˮ�ѽ��㣬�뾡����ɡ�������������ˮ���޹�˾����ˮ���ߣ�96390��
                IF P_MODENO='001' then
                   p_type       :=  P_SENDTYPE;  --���
                  p_mdno       :=  P_MODENO;  --ģ����
                  P_name       :=  null;  --��Ա����
                  P_hm         :=  null;  --����
                  P_hh         :=  QF.���Ϻ�;  --����
                  p_dz         :=  QF.�û���ַ;  --��ַ
                  P_qfsl       :=  null;  --Ƿ��ˮ��
                  P_qfje       :=  null;  --Ƿ�ѽ��
                  P_qfbs       :=  null;  --Ƿ�ѱ���
                  P_date       :=  null;  --����
                  P_radatemin  :=  null;  --������������
                  P_radatemax  :=  null;  --�����������
                  P_str1       :=  null;  --���
                  P_str2       :=  null;  --Ԥ����
                  P_str3       :=  null;  --Ԥ����
                  P_MONTH      :=  null;  --��ǰ�·�
                  P_YR         := null; --X��X��
                  P_QS         := null;
                  P_WYQF       := null;
                END IF;
          end if;
          TR.SSMSMESSAGE := FGET_dxstr_01(p_type, --���
                      p_mdno, --ģ����
                      P_name, --��Ա����
                      P_hm, --����
                      P_hh, --����
                      p_dz, --��ַ
                      P_qfsl, --Ƿ��ˮ��
                      P_qfje, --Ƿ�ѽ��
                      P_qfbs, --Ƿ�ѱ���
                      P_date, --����
                      P_radatemin, --������������
                      P_radatemax, --�����������
                      P_str1, --���
                      P_str2, --Ԥ����
                      P_str3, --Ԥ����
                      P_MONTH,  --��ǰ�·�
                      P_YR,      --X��X��
                      P_QS,      --Ƿ������
                      P_WYQF     --����Ƿ��
                      );
          TR.ID           :=V_ID; --��¼���
          TR.SSENDNO      :=PB.C2; --���պ���
          --TR.SSMSMESSAGE  :=V_C3 ; --����Ϣ
          spinset( TR);
        end if;

      END LOOP;
     CLOSE C_MN;
    END IF;
    delete pbparmtemp_sms where c4=P_BATCH;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      ROLLBACK;
  END;

  PROCEDURE spinset(TI TSMSSENDCACHE%ROWTYPE ) AS
  BEGIN
    if ti.NTIMINGTAG='1' then
       INSERT INTO TSMSSENDCACHE VALUES TI;
      else
        INSERT INTO TSMSSENDCACHEtimed VALUES TI;
     end if;
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
    --���ƶ��ֻ���Ĭ�Ϻ�׺����δ������Ϊ��Ϊ�����߹�ˮ��
   select  MSBPARAMETERS into V_HZ from mssbasicparameters where MSBID='02';
    if V_HZ is null then
       V_HZ :='�����߹�ˮ��';
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



FUNCTION FGET_dxstr_01(p_type      in varchar2, --���
                      p_mdno      in varchar2, --ģ����
                      P_name        IN VARCHAR2, --��Ա����
                      P_hm        IN VARCHAR2, --����
                      P_hh        IN VARCHAR2, --����
                      p_dz        in varchar2, --��ַ
                      P_qfsl      IN VARCHAR2, --Ƿ��ˮ
                      P_qfje      IN VARCHAR2, --Ƿ�ѽ��
                      P_qfbs      IN VARCHAR2, --Ƿ�ѱ���
                      P_date      IN VARCHAR2, --����
                      P_radatemin IN VARCHAR2, --������������
                      P_radatemax IN VARCHAR2, --�����������
                      P_str1      IN VARCHAR2, --���
                      P_str2      IN VARCHAR2, --Ԥ����
                      P_str3      IN VARCHAR2, --Ԥ����
                      P_MONTH     IN VARCHAR2,  --��ǰ�·�
                      P_YR        IN VARCHAR2,   --X��X��
                      P_QS        IN VARCHAR2,   --Ƿ������
                      P_WYQF        IN VARCHAR2   --����Ƿ��
                      ) RETURN VARCHAR2 IS
    V_STR VARCHAR2(4000);
    v_date date;
  begin
    select tmdmd into v_str from tsmssendmode t where t.tmdlb =p_type  and tmdbh=p_mdno;
    if P_name is not null then
       v_str := replace(v_str,'�ǳ�Ա���Ʃ�',trim(to_multi_byte(P_name)));
    end if;
    if P_hm is not null then
       v_str := replace(v_str,'���û�����',trim(to_multi_byte(P_hm)));
    end if;
    if P_hh is not null then
       v_str := replace(v_str,'���û��ũ�',trim(P_hh));
    end if;
    if p_dz is not null then
       v_str := replace(v_str,'���û���ַ��',trim(to_multi_byte(p_dz)));
    end if;
    if P_qfsl is not null then
       v_str := replace(v_str,'��Ƿ��ˮ����',trim(P_qfsl));
    end if;
    if P_qfje is not null then
       v_str := replace(v_str,'��Ƿ�ѽ���',trim(P_qfje));
    end if;
    if P_qfbs is not null then
       v_str := replace(v_str,'��Ƿ�ѱ�����',trim(P_qfbs));
    end if;
    if P_date is not null then
       v_date := to_date(p_date,'yyyymmdd');
       v_str := replace(v_str,'�ǵ�ǰ���ک�',to_char(v_date,'yyyy')||'��'||to_char(v_date,'mm')||'��'||to_char(v_date,'dd')||'��');
    end if;
    if P_str1 is not null then
       v_str := replace(v_str,'������',trim(P_str1));
    end if;
    if P_radatemin is not null then
       v_date := to_date(P_radatemin,'yyyymmdd');
       v_str := replace(v_str,'������Ƿ�����ک�',to_char(v_date,'yyyy')||'��'||to_char(v_date,'mm')||'��'||to_char(v_date,'dd')||'��');
    end if;
    if P_radatemax is not null then
       v_date := to_date(P_radatemax,'yyyymmdd');
       v_str := replace(v_str,'�����Ƿ�����ک�',to_char(v_date,'yyyy')||'��'||to_char(v_date,'mm')||'��'||to_char(v_date,'dd')||'��');
    end if;
    if P_str2 is not null then
       v_str := replace(v_str,'�Ǳ���ˮ����',trim(P_str2));
    end if;
    if P_str3 is not null then
       v_str := replace(v_str,'�Ǳ���ˮ�ѩ�',trim(P_str3));
    end if;
    if P_MONTH is not null then
       v_str := replace(v_str,'�ǵ�ǰ�·ݩ�',trim(P_MONTH));
    end if;
    if P_YR is not null then
       v_str := replace(v_str,'�ǵ�ǰ�·ݩ�',trim(P_YR));
    end if;
    if P_QS is not null then
       v_str := replace(v_str,'��Ƿ��������',trim(P_QS));
    end if;
    if P_WYQF is not null then
       v_str := replace(v_str,'������Ƿ�ѩ�',trim(P_WYQF));
    end if;
    --v_str := to_multi_byte(v_str);
    RETURN V_STR;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN V_STR;
  END;

  PROCEDURE sp_��ʱ����job AS
 begin
    insert into tsmssendcache
    (select * from tsmssendcachetimed WHERE DTIMINGTIME<systimestamp);
    delete tsmssendcachetimed WHERE DTIMINGTIME<systimestamp;
    commit;
  end ;

END PG_SMS;
/

