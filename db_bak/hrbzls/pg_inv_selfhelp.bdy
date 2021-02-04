CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_INV_SELFHELP IS

  --ͳһ���
  PROCEDURE MAIN(JSONSTR IN VARCHAR2, OUTJSON OUT CLOB) IS
    V_JSONSTR  LONG;
    V_SERVCODE VARCHAR2(20);
    JSONOBJ    JSON;
    V_OUUTJSON CLOB;
    V_IP       VARCHAR2(100); --�û�ip
    V_ID       NUMBER;
  BEGIN
    --����Ԥ����
    V_JSONSTR := REPLACE(REPLACE(JSONSTR, CHR(10), ''), CHR(13), '');
    --��ȡ�����
    JSONOBJ    := JSON(V_JSONSTR);
    V_SERVCODE := JSON_EXT.GET_STRING(JSONOBJ, 'head.servCode');
    --�û�ip
    V_IP := JSON_EXT.GET_STRING(JSONOBJ, 'head.clientip');
    --��¼��־
   P_LOG(V_ID, V_SERVCODE, V_JSONSTR, OUTJSON, V_IP);
    --���״���
    IF V_SERVCODE = '100001' THEN
      V_OUUTJSON := CHECKUSER(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100002' THEN
      V_OUUTJSON := CHECKUSERMOBILE(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100003' THEN
      V_OUUTJSON := GETINVLIST(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100004' THEN
      V_OUUTJSON := OPENINV(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100005' THEN
      V_OUUTJSON := UPDATEINV(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100006' THEN
      V_OUUTJSON := ISOPENINV(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100007' THEN
      V_OUUTJSON := GETINVINFO(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100008' THEN
      V_OUUTJSON := UPDATEPWD(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100009' THEN
      V_OUUTJSON := INVFILE(V_JSONSTR);
    END IF;
    --���غ���������
    OUTJSON := REPLACE(V_OUUTJSON, '/**/', '"');
    --��д��־
    P_LOG(V_ID, V_SERVCODE, V_JSONSTR, OUTJSON, V_IP);

  END;

  --1.���ݿͻ�����ͻ�����֤�û���Ϣ��CHECKUSER��
  FUNCTION CHECKUSER(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_OUTISONSTR CLOB;

    V_KHDM  VARCHAR2(10); --�ͻ�����
    V_HM    VARCHAR2(100); --�û�����Ʊ��ȡ��
    V_YHLX  VARCHAR2(10); --�û����ͣ�1��λ�û� 2�����û���
    V_COUNT NUMBER := 0;

    V_YSH  LONG; --��ˮ��
    V_YSHM LONG; --��ˮ������
    V_KHDZ LONG; --�ͻ���ַ
    V_LXDH LONG; --�ͻ���ϵ�绰
    V_NYSL LONG; --����ˮ��
    V_ZQF  LONG; --��Ƿ��
    V_YCYE LONG; --Ԥ�����
    V_PWD  VARCHAR2(100);
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --�ͻ�����
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    --����
    V_HM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.hm');
    --�û����ͣ�1��λ�û� 2�����û���
    V_YHLX := JSON_EXT.GET_STRING(JSONOBJIN, 'body.yhlx');
    --password
    V_PWD := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pwd');
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{}');

    --���У��
    IF TRIM(V_KHDM) IS NULL OR TRIM(V_PWD) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('�û��ż����벻��Ϊ��', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --�ж�hm�ֶδ�����ǻ���������ȡ�룬�����ּ���Ϊ����ȡ��
    IF REGEXP_LIKE(V_HM, '^[[:digit:]]+$') and lengthb(V_HM) = 10 THEN
      --��ѯ�Ƿ���ڴ��û�
      SELECT COUNT(1)
        INTO V_COUNT
        FROM (SELECT 1
                FROM PAYMENT
               WHERE (PID = V_HM OR PBSEQNO = V_HM)
                 AND PMID = V_KHDM
              UNION
              SELECT 1
                FROM RECLIST
               WHERE RLID = V_HM
                 AND RLMID = V_KHDM);
      IF V_COUNT = 0 THEN
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resState',
                     JSON_VALUE('error', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('����ȡ����ϵͳ�в�����', FALSE));
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
        RETURN V_OUTISONSTR;
      END IF;
    ELSE
      --��ѯ�Ƿ���ڴ��û�
      SELECT COUNT(1)
        INTO V_COUNT
        FROM METERINFO
       WHERE MIID = V_KHDM
         AND miyl4 = MD5(V_PWD);
      IF V_COUNT = 0 THEN
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resState',
                     JSON_VALUE('error', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('���û��Ų����ڻ��������', FALSE));
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
        RETURN V_OUTISONSTR;
      END IF;
    END IF;

    --�����û���֤��Ϣ
    SELECT MI.MIID,
           MI.MINAME,
           MI.MIADR,
           CI.CIMTEL,
           '' NYSL,
           GETUSERQF(MI.MIID) ZQF,
           MI.MISAVING
      INTO V_YSH, V_YSHM, V_KHDZ, V_LXDH, V_NYSL, V_ZQF, V_YCYE
      FROM METERINFO MI, CUSTINFO CI
     WHERE MI.MICID = CI.CIID
       AND MI.MIID = V_KHDM
       AND ROWNUM = 1;
    JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
    JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.resMsg',
                 JSON_VALUE('��ȡ�û���Ϣ�ɹ�', FALSE));
    JSON_EXT.PUT(JSONOBJOUT, 'body.ysh', V_YSH); --��ˮ��
    JSON_EXT.PUT(JSONOBJOUT, 'body.yshmc', JSON_VALUE(V_YSHM, FALSE)); --��ˮ������
    JSON_EXT.PUT(JSONOBJOUT, 'body.khdz', JSON_VALUE(V_KHDZ, FALSE)); --�ͻ���ַ
    JSON_EXT.PUT(JSONOBJOUT, 'body.lxdh', V_LXDH); --�ͻ���ϵ�绰
    JSON_EXT.PUT(JSONOBJOUT, 'body.nysl', V_NYSL); --����ˮ��
    JSON_EXT.PUT(JSONOBJOUT, 'body.zqf', V_ZQF); --��Ƿ��
    JSON_EXT.PUT(JSONOBJOUT, 'body.ycye', V_YCYE); --Ԥ�����

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --2. �����ֻ��������֤����֤�û���Ϣ��һ���Ǻ�����ܴ��ڶ����ˮ�����������CHECKUSERMOBILE��
  FUNCTION CHECKUSERMOBILE(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_OUTISONSTR CLOB;

    V_PHONE VARCHAR2(100); --�ֻ�����
    V_YHLX  VARCHAR2(10); --�û����ͣ�1��λ�û� 2�����û���
    V_COUNT NUMBER := 0;
    J       NUMBER := 0;

  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --�ֻ�����
    V_PHONE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.phone');
    --�û����ͣ�1��λ�û� 2�����û���
    V_YHLX := JSON_EXT.GET_STRING(JSONOBJIN, 'body.yhlx');
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{}');

    --�ֻ�����У��
    --1��δ�����ֻ���
    IF TRIM(V_PHONE) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('�ֻ����벻��Ϊ��', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --2����Ч���ֻ���
    IF NOT REGEXP_LIKE(V_PHONE, '^1[34578]\d{9}$') THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('��Ч���ֻ�����', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --��ѯ�Ƿ�����û�
    SELECT COUNT(1)
      INTO V_COUNT
      FROM METERINFO MI, CUSTINFO CI
     WHERE MI.MICID = CI.CIID
       AND CI.CIMTEL = V_PHONE;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('�޴��ֻ���', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --�����û���Ϣ
    JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
    JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.resMsg',
                 JSON_VALUE('��ȡ�û���Ϣ�ɹ�', FALSE));
    FOR METER IN (SELECT MI.MIID,
                         MI.MINAME,
                         MI.MIADR,
                         CI.CIMTEL,
                         NULL NYSL,
                         GETUSERQF(MI.MIID) ZQF,
                         MI.MISAVING
                    FROM METERINFO MI, CUSTINFO CI
                   WHERE MI.MICID = CI.CIID
                     AND CI.CIMTEL = V_PHONE
                   ORDER BY MI.MIID) LOOP
      J := J + 1;
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.userList[' || J || '].ysh',
                   METER.MIID); --��ˮ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.userList[' || J || '].yshmc',
                   JSON_VALUE(METER.MINAME, FALSE)); --��ˮ������
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.userList[' || J || '].khdz',
                   JSON_VALUE(METER.MIADR, FALSE)); --�ͻ���ַ
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.userList[' || J || '].lxdh',
                   METER.CIMTEL); --�ͻ���ϵ�绰
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.userList[' || J || '].nysl',
                   METER.NYSL); --����ˮ��
      JSON_EXT.PUT(JSONOBJOUT, 'body.userList[' || J || '].zqf', METER.ZQF); --��Ƿ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.userList[' || J || '].ycye',
                   METER.MISAVING); --Ԥ�����
    END LOOP;

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --3. ��ȡ�ɷ���Ϣ�б�(������)����GETINVLIST��
  FUNCTION GETINVLIST(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_OUTISONSTR CLOB;

    P_KHDM  VARCHAR2(20); --�ͻ�����
    V_KHDM  VARCHAR2(20); --�ͻ�����
    V_PID   VARCHAR2(20); --ʵ����ˮ
    V_YID   VARCHAR2(20); --Ӧ����ˮ
    V_COUNT NUMBER := 0;
    J       NUMBER := 0;
    V_PWD  VARCHAR2(100);
    V_TQM   VARCHAR2(20); --��ȡ��
    v_sdate VARCHAR2(20); --
    v_edate VARCHAR2(20); --

    MI     METERINFO%rowtype;
    SEARCHTYPE NUMBER;
    ��ѯȫ��ʵ�� CONSTANT NUMBER := 0;
    ��ѯָ��ʵ�� CONSTANT NUMBER := 1;
    ��ѯָ��Ӧ�� CONSTANT NUMBER := 2;

  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --�ͻ�����
    P_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');

    V_KHDM := SUBSTR(P_KHDM,-10,10);
    --ʵ����ˮ
    V_PID := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pid');
    --Ӧ����ˮ
    V_YID := JSON_EXT.GET_STRING(JSONOBJIN, 'body.yid');
    --password
    V_PWD := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pwd');
    --password
    V_TQM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.tqm');
    --v_sdate
    v_sdate := JSON_EXT.GET_STRING(JSONOBJIN, 'body.sdate');
    --v_edate
    v_edate := JSON_EXT.GET_STRING(JSONOBJIN, 'body.edate');
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{}');

    --���У��
    IF TRIM(V_KHDM) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('�ͻ����벻��Ϊ��', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --��ѯ�Ƿ���ڴ��û�
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;
    SELECT * INTO MI FROM  METERINFO WHERE MIID = V_KHDM;
    JSON_EXT.PUT(JSONOBJOUT, 'head.yshmc', mi.MINAME); --��ˮ������
    JSON_EXT.PUT(JSONOBJOUT, 'head.khdz', mi.miadr); --�ͻ���ַ
    if SUBSTR(P_KHDM,1,1) in ('P','L') then
      if SUBSTR(P_KHDM,1,1) = 'P' then
        SEARCHTYPE := ��ѯָ��ʵ��;
      else
        SEARCHTYPE := ��ѯָ��Ӧ��;
      end if;
    else
      IF TRIM(V_TQM) IS NOT NULL   THEN
        SELECT COUNT(*) INTO V_COUNT FROM PAYMENT WHERE PID =V_TQM;
        IF V_COUNT>0 THEN
          --ʵ��
          SEARCHTYPE := ��ѯָ��ʵ��;
        else
          --Ӧ��
          SEARCHTYPE := ��ѯָ��Ӧ��;
        END IF;
        V_COUNT := 0;
      ELSE
        SEARCHTYPE := ��ѯȫ��ʵ��;
      END IF;

      /*IF TRIM(V_TQM) IS NULL   THEN
        SEARCHTYPE := ��ѯȫ��ʵ��;
      ELSe
        SEARCHTYPE := ��ѯָ��Ӧ��;
      END IF;*/
    end if;
    if v_sdate is null then
      v_sdate := 'NULL';
    end if;
    if v_Edate is null then
      v_Edate := 'NULL';
    end if;
    --��վ��ѯ4�����ָ��Ӧ�ա�ָ��ʵ�ա�ȫ��Ӧ�ա�ȫ��ʵ��
    --ȫ��Ӧ��(���������˼�¼�������û������ݽɷ����ڲ�ѯ)
    --ָ��Ӧ�ա�ȫ��Ӧ�գ�ʵ�ձ��壬Ӧ����ʾ��������

    SELECT NVL(MIPRIID,MIID) INTO P_KHDM FROM METERINFO WHERE MIID=V_KHDM;

    FOR INVLIST IN (select pid,pmid,pdate,pmonth,ppayment,pbatch,sfzzs,MIUSENUM,MISAVING,PPAYWAY,(case when length(GURL) > 0 /*and pdate > to_date(FSYSPARA('1115'),'yyyy-mm-dd')*/ then 'Y' else 'N' end) KPZT,
                       PSAVINGQC,PSAVINGBQ,PSAVINGQM,pposition,GURL, (case when length(GURL) > 0 then '������' else 'δ����' end) GDOWN
 from (                --��ѯ����Ԥ��
                       --ָ��ʵ�ա�ȫ��ʵ��
                       --��ʾ���ձ�������Ϣ
                       SELECT P.PID pid,
                           P.PMID,
                           TRUNC(P.PDATE) PDATE,
                           P.PMONTH,
                           P.PPAYMENT,
                           'P'||P.PBATCH PBATCH,
                           NVL(MIIFTAX, 'N') SFZZS,
                           MI.MIUSENUM,
                           MI.MISAVING,
                           FGETSYSCHARLIST('���׷�ʽ', P.PPAYWAY) PPAYWAY,
                           '' KPZT, --���ӷ�Ʊ�� ֽ�ʷ�Ʊ��ֻ�ܿ�һ��
                           P.PSAVINGQC,
                           P.PSAVINGBQ,
                           P.PSAVINGQM,
                           fgetsmfname(p.pposition) pposition,GETURL(PID,'P') GURL,'' GDOWN
                      FROM PAYMENT P, METERINFO MI
                     WHERE MI.MIID = P.PMID
                       AND P.PDATE >= ADD_MONTHS(SYSDATE, -24)
                       AND P.PREVERSEFLAG = 'N'
                       AND P.PPAYMENT > 0
                       AND nvl(MI.MIIFTAX,'N') <> 'Y'
                       AND ((SEARCHTYPE = ��ѯȫ��ʵ�� and mi.michargetype<>'M') OR
                           (SEARCHTYPE = ��ѯָ��ʵ�� AND P.PID = V_TQM))
                       AND MI.MIPRIID = P_KHDM
                       and pdate > to_date(FSYSPARA('1115'),'yyyy-mm-dd')
                       and (to_char(pdate,'yyyy-mm-dd') >= v_sdate or v_sdate = 'NULL')
                       and (to_char(pdate,'yyyy-mm-dd') <= v_Edate or v_Edate = 'NULL')
                       and (P.PTRANS = 'S' or (P.PTRANS = 'B' and P.PSAVINGBQ=P.PPAYMENT) or PPAYWAY='DC' OR (PSPJE=0 and P.PTRANS='P'))
                       /*AND (P.PTRANS = 'S' OR P.PSCRTRANS = 'S' OR P.PTRANS = 'V' OR
             P.PSCRTRANS = 'V' OR P.PTRANS = 'Y' OR P.PSCRTRANS = 'Y' OR
             P.PTRANS = 'Q' OR P.PSCRTRANS = 'Q' or p.ptrans = 'B' or p.pscrtrans = 'B'
            \*  or p.ptrans = 'H' or p.pscrtrans = 'H' *\ or p.ptrans = 'P' or p.pscrtrans = 'P')*/
                    UNION
                    --��ѯʵ�գ�ָ��ʵ�ա�ȫ��ʵ��
                    --�������գ�����Ԥ�����������û���ʾӦ����ϸ��
                    SELECT P.PID pid,
                           P.PMID,
                           TRUNC(P.PDATE) PDATE,
                           P.PMONTH,
                           P.PPAYMENT,
                           --decode(ptrans,'I','L'|| rlid,'P'|| P.PBATCH) PBATCH,
                           'P'||P.PBATCH PBATCH,
                           NVL(MIIFTAX, 'N') SFZZS,
                           MI.MIUSENUM,
                           MI.MISAVING,
                           FGETSYSCHARLIST('���׷�ʽ', P.PPAYWAY) PPAYWAY,
                           '' KPZT, --���ӷ�Ʊ�� ֽ�ʷ�Ʊ��ֻ�ܿ�һ��
                           P.PSAVINGQC,
                           P.PSAVINGBQ,
                           P.PSAVINGQM,
                           fgetsmfname(p.pposition) pposition,GETURL(PID,'P') GURL,'' GDOWN
                      FROM RECLIST RL, PAYMENT P, METERINFO MI
                     WHERE RL.RLPID = P.PID
                       AND MI.MIID = RL.RLMID
                       AND P.PDATE >= ADD_MONTHS(SYSDATE, -24)
                       AND MI.MIPRIID = P_KHDM
                       AND P.PREVERSEFLAG = 'N'
                       AND RL.RLYSCHARGETYPE<>'M'
                       AND RL.RLTRANS NOT IN  ('13','21','23','v','u')
                       --AND RL.RLREVERSEFLAG = 'N'
                       and pdate > to_date(FSYSPARA('1115'),'yyyy-mm-dd')
                       AND P.PPAYMENT > 0
                       AND NVL(MI.MIIFTAX,'N') <> 'Y'
                       AND ((SEARCHTYPE = ��ѯȫ��ʵ�� ) OR (SEARCHTYPE = ��ѯָ��ʵ�� AND P.PID = V_TQM))
                       and (to_char(pdate,'yyyy-mm-dd') >= v_sdate or v_sdate = 'NULL')
                       and (to_char(pdate,'yyyy-mm-dd') <= v_Edate or v_Edate = 'NULL')
                       AND ( P.PTRANS = 'V' OR
                       P.PSCRTRANS = 'V' OR P.PTRANS = 'Y' OR P.PSCRTRANS = 'Y' OR
                       P.PTRANS = 'Q' OR P.PSCRTRANS = 'Q' or p.ptrans = 'B' or p.pscrtrans = 'B' or p.ptrans = 'P' or p.pscrtrans = 'P')
                       GROUP BY PID,PMID,PDATE,PMONTH,PPAYMENT,PBATCH,MIIFTAX,MIUSENUM,MISAVING,PPAYWAY,PSAVINGQC,PSAVINGBQ,PSAVINGQM,pposition
                 --    ORDER BY PDATE, PBATCH, PID
                     UNION
                     --ȫ��Ӧ��
                     --���������˼�¼�������û������ݽɷ����ڲ�ѯ
                     --��ʾӦ����ϸ������Ӧ����ʾ���ˣ����ԭӦ����ˮ��ǰ̨��ӡ
                     SELECT RL.RLSCRRLID pid,
                           RLMID PMID,
                           TRUNC(PDATE) PDATE,
                           RLMONTH PMONTH,
                           RLJE PPAYMENT,
                           'L'||RL.RLSCRRLID PBATCH,
                           NVL(MIIFTAX, 'N') SFZZS,
                           MI.MIUSENUM,
                           MI.MISAVING,
                           '����' PPAYWAY,
                           '' KPZT, --���ӷ�Ʊ�� ֽ�ʷ�Ʊ��ֻ�ܿ�һ��
                           0 PSAVINGQC,
                           0 PSAVINGBQ,
                           0 PSAVINGQM,
                           fgetsmfname(RLSMFID) pposition,GETURL(RLSCRRLID,'L') GURL,'' GDOWN
                      FROM RECLIST RL , METERINFO MI,PAYMENT P
                     WHERE MI.MIID = RL.RLMID
                       AND MI.MIPRIID = P_KHDM
                       AND RL.RLPID=P.PID
                       AND NVL(MI.MIIFTAX,'N') <> 'Y'
                       AND RL.RLREVERSEFLAG = 'N'
                       AND RL.RLYSCHARGETYPE='M'
                       and rldate > to_date(FSYSPARA('1115'),'yyyy-mm-dd')
                       AND RL.RLJE > 0
                       AND SEARCHTYPE = ��ѯȫ��ʵ��  --ͨ���û��Ų�ѯ,�����û���������
                       --AND ((SEARCHTYPE = ��ѯָ��Ӧ�� AND RL.RLSCRRLID = V_TQM) or (SEARCHTYPE = ��ѯȫ��ʵ�� ))
                       --��������ѯ���ո���ʵ�����ڶβ�ѯ
                       and (to_char(P.PDATE,'yyyy-mm-dd') >= v_sdate or v_sdate = 'NULL')
                       and (to_char(P.PDATE,'yyyy-mm-dd') <= v_Edate or v_Edate = 'NULL')
                     UNION
                     --ָ��Ӧ��
                     --�����û�δ����,ͨ����ά��\��ȡ���ѯ
                     SELECT RL.RLSCRRLID pid,
                           RLMID PMID,
                           TRUNC(RLDATE) PDATE,
                           RLMONTH PMONTH,
                           RLJE PPAYMENT,
                           'L'||RL.RLSCRRLID PBATCH,
                           NVL(MIIFTAX, 'N') SFZZS,
                           MI.MIUSENUM,
                           MI.MISAVING,
                           '����' PPAYWAY,
                           '' KPZT, --���ӷ�Ʊ�� ֽ�ʷ�Ʊ��ֻ�ܿ�һ��
                           0 PSAVINGQC,
                           0 PSAVINGBQ,
                           0 PSAVINGQM,
                           fgetsmfname(RLSMFID) pposition,GETURL(RLSCRRLID,'L') GURL,'' GDOWN
                      FROM RECLIST RL , METERINFO MI
                     WHERE MI.MIID = RL.RLMID
                       AND MI.MIPRIID = P_KHDM
                       AND NVL(MI.MIIFTAX,'N') <> 'Y'
                       AND RL.RLREVERSEFLAG = 'N'
                       AND RL.RLYSCHARGETYPE='M'
                       AND rldate > to_date(FSYSPARA('1115'),'yyyy-mm-dd')
                       AND RL.RLJE > 0
                       AND RL.RLSCRRLID = V_TQM
                       AND SEARCHTYPE = ��ѯָ��Ӧ��  --ͨ����ȡ���ѯ,�����û�δ����
                       --AND ((SEARCHTYPE = ��ѯָ��Ӧ�� AND RL.RLSCRRLID = V_TQM) or (SEARCHTYPE = ��ѯȫ��ʵ�� ))
                       --��������ѯ���ո���ʵ�����ڶβ�ѯ
                       and (to_char(RL.Rldate,'yyyy-mm-dd') >= v_sdate or v_sdate = 'NULL')
                       and (to_char(RL.Rldate,'yyyy-mm-dd') <= v_Edate or v_Edate = 'NULL')

                     ORDER BY PDATE desc, PBATCH desc, PID desc)) LOOP
      J := J + 1;
      --��ϸ����
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].lsh',
                   INVLIST.PID); -- ʵ����ˮ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].yhh',
                   INVLIST.PMID); -- �û���
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].jfrq',
                   to_char(NVL(INVLIST.PDATE,SYSDATE),'YYYY-MM-DD')); -- �ɷ�����
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].jfyf',
                   INVLIST.PMONTH); -- �ɷ��·�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].jfje',
                   to_char(TOOLS.FFORMATNUM(INVLIST.PPAYMENT,2))); -- �ɷѽ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].pch',
                   INVLIST.PBATCH); -- ���κ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].sfzzs',
                   INVLIST.SFZZS); -- �Ƿ���ֵ˰��Y��N��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].ysrs',
                   NVL(INVLIST.MIUSENUM,0)); -- ��ˮ����
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].ycje',
                   to_char(INVLIST.MISAVING,'FM999999999.00')); -- Ԥ����
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].jffs',
                   JSON_VALUE(INVLIST.PPAYWAY, FALSE)); -- �ɷѷ�ʽ
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].kpzt',
                   INVLIST.KPZT); -- ��Ʊ״̬
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].qcyc',
                   to_char(INVLIST.PSAVINGQC,'FM999999999.00')); --�ڳ�Ԥ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].qmyc',
                   to_char(INVLIST.PSAVINGBQ,'FM999999999.00')); --��ĩԤ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].bqyc',
                   to_char(INVLIST.PSAVINGQM,'FM999999999.00')); -- ����Ԥ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].jfdz',
                   INVLIST.PPOSITION); -- ���ѵ�ַ
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.invLists[' || J || '].gurl',
                   INVLIST.gurl); -- ���ѵ�ַ
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.invLists[' || J || '].gdown',
                   INVLIST.gdown); -- ���ѵ�ַ
    END LOOP;

    IF J > 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('��ȡ�ɷ���Ϣ�б�ɹ�', FALSE));
    ELSE
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      IF SEARCHTYPE = ��ѯָ��Ӧ�� THEN
        IF V_TQM IS NULL THEN
          JSON_EXT.PUT(JSONOBJOUT,
                       'head.resMsg',
                       JSON_VALUE('�������������δ���������ݲ��ܿ�Ʊ', FALSE));
        END IF;
      ELSE
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('û�в�ѯ���������', FALSE));
      END IF;
    END IF;

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --4. ��Ʊ���췢Ʊ��(OPENINV)
 FUNCTION OPENINV(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_OUTISONSTR CLOB;
  
    V_KHDM   VARCHAR2(20); --�ͻ�����
    p_PBATCH VARCHAR2(20); --'P'+ʵ������
    V_PBATCH VARCHAR2(20); --ʵ������
    is_pbatch VARCHAR2(20);
    V_COUNT  NUMBER := 0;
    V_GID    PRINTLOG.GID%TYPE;
    J        NUMBER := 0;
  
    O_CODE   VARCHAR2(10);
    O_ERRMSG VARCHAR2(100);
    v_lx     char(1);
    v_isid  varchar2(20);
    o_url1  varchar2(200);
    o_url2  varchar2(200);
    INV_LIST NUMBER;
    V_FPQQLSH VARCHAR2(100);
    V_PTYPE   VARCHAR2(10);
    O_TYPE    VARCHAR2(10);
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --�ͻ�����
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    V_KHDM := SUBSTR(V_KHDM,-10,10);
    --ʵ������
    p_PBATCH := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pbatch');
    V_PBATCH := SUBSTR(p_PBATCH,-10,10);
    V_LX := SUBSTR(p_PBATCH,1,1);
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{}');
    --ϵͳ���ܴ���2������ǰ��Ʊ��Ϣ,�Զ�����
    DELETE INV_SELFHELP_LIST where pdate<sysdate-2/1140;
    --�ж��Ƿ�ͬһʱ���ظ��ύ
    SELECT COUNT(*) INTO INV_LIST FROM INV_SELFHELP_LIST WHERE YHH=V_KHDM AND PID=V_PBATCH;
    IF INV_LIST > 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '122222');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('ͬһ��Ʊ��Ϣ�ظ��ύ', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      DBMS_LOCK.SLEEP(60);
      RETURN V_OUTISONSTR;
    END IF;
    
    --���ӷ�Ʊ�Ŷ�
    SELECT COUNT(*) INTO INV_LIST FROM PAY_EINV_JOB_LOG PE,PAYMENT PM 
    where PE.PBATCH=PM.PBATCH AND PE.perrid='0' AND PM.PID=V_PBATCH;
    IF INV_LIST > 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '122223');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('ϵͳ���ڷ�Ʊ�������µ�½���ط�Ʊ', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      --DBMS_LOCK.SLEEP(60);
      RETURN V_OUTISONSTR;
    END IF;
    
    
    --����ж�
    
    INSERT INTO INV_SELFHELP_LIST(YHH,PID) VALUES (V_KHDM,V_PBATCH);
    COMMIT;
    
    --���У��
    IF TRIM(V_KHDM) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('�ͻ����벻��Ϊ��', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;
    
    --��ѯ�Ƿ���ڴ��û�
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;
    
    /* SELECT COUNT(*)
          INTO V_COUNT
          FROM invstock_sp it, inv_info_sp ii
          WHERE it.isid = to_number(ii.isid)
          AND ((ii.rlid = V_PBATCH and V_LX = 'L') or ( ii.batch = V_PBATCH and V_LX = 'P'))
          AND it.istype = 'P'
          AND ii.status = '0'
          And it.isstatus = '1';*
     select * from INV_EINVOICE_ST t,INV_EINVOICE_RETURN t2,invstock_sp it,inv_detail_sp idt
   where t.fpqqlsh = t2.fpqqlsh and t.ispcisno = IT.ISPCISNO AND  idt.isid = it.isid AND 
   ISSTATUS = '1' AND8*/
        SELECT COUNT(*)
          INTO V_COUNT
          FROM INVSTOCK_SP isp,INV_EINVOICE_ST IE, INV_INFO_SP II
         WHERE IE.ID = II.ID and ii.isid = isp.isid  and isp.isstatus = '1'
           AND ((ii.batch = V_PBATCH and (V_LX = 'P' or v_lx = 'R')) or ( ii.rlid = V_PBATCH and V_LX = 'L'))
           ;
        SELECT max(IE.Fpqqlsh) into V_Fpqqlsh
          FROM INVSTOCK_SP isp,INV_EINVOICE_ST IE, INV_INFO_SP II
         WHERE IE.ID = II.ID and ii.isid = isp.isid  and isp.isstatus = '1'
           AND ((ii.batch = V_PBATCH and (V_LX = 'P' or v_lx = 'R')) or ( ii.rlid = V_PBATCH and V_LX = 'L'))
           ;
     --�Ѿ���Ʊ      
     IF V_Fpqqlsh is not null THEN
        --��鿪Ʊ״̬
        PG_EWIDE_EINVOICE.P_ASYNCINV(V_Fpqqlsh,
                         '',
                         O_TYPE,
                         O_ERRMSG);
        IF O_TYPE='6' THEN
           --����Ʊ
           V_PTYPE := 'A';
           --dbms_lock.sleep(15); ---  �ȴ�15��
        ELSIF O_TYPE='2' THEN
              --��Ʊ��״̬���ȴ��Զ��ص�
              --dbms_lock.sleep(12); ---  �ȴ�10��
              NULL;
        ELSIF O_TYPE='3' THEN
              --��Ʊʧ�ܣ��ؿ�Ʊ
              V_PTYPE := 'R';
              --dbms_lock.sleep(15); ---  �ȴ�15��
        END IF ;
     END IF;
      
     IF V_COUNT = 0 OR O_TYPE IN ('3','6') THEN
      --��δ��Ʊ
      --�ظ���Ʊ���
      /*SELECT COUNT(*)
        INTO V_COUNT
        FROM PRINTLOG
       WHERE FID = V_PBATCH
         AND FTYPE = 'SH';
      IF V_COUNT > 0 THEN
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100003');
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resState',
                     JSON_VALUE('error', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('���ڿ��߷�Ʊ���Ժ�...', FALSE));
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
       -- V_OUTISONSTR := REPLACE(V_OUTISONSTR, '\**\', '"');
        RETURN V_OUTISONSTR;
      END IF;*/
      --��ʼ���߿���
     -- P_PRINTCTRL(V_GID, V_PBATCH);
      --��ʼ������ҵ
      DELETE FROM INVPARMTERMP;
      IF V_LX = 'L' THEN
          SELECT fgetsequence('ENTRUSTLOG') Into is_pbatch From dual;
          INSERT INTO INVPARMTERMP (RLID,pbatch, IFPRINT,MEMO1) VALUES (V_PBATCH,is_pbatch, 'Y',V_PTYPE);
          BEGIN
            PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '5',
                                                       P_INVTYPE   => 'P',
                                                       P_INVNO     => 'HRBZLS.00000001',
                                                       O_CODE      => O_CODE,
                                                       O_ERRMSG    => O_ERRMSG,
                                                       P_SLTJ      => 'QYMH');
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK;
              O_CODE   := '99';
              O_ERRMSG := '��Ʊ����ʧ�ܣ�ʵ������[' || V_PBATCH || ']' ||
                          SUBSTR(SQLERRM, INSTR(SQLERRM, '['), LENGTH(SQLERRM));
          END;
        else
         if V_LX = 'R' THEN
          INSERT INTO INVPARMTERMP (PBATCH, IFPRINT,MEMO1) VALUES (V_PBATCH, 'Y',V_PTYPE);
          BEGIN
/*            PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '1',
                                                       P_INVTYPE   => 'P',
                                                       P_INVNO     => 'HRBZLS.00000001',
                                                       O_CODE      => O_CODE,
                                                       O_ERRMSG    => O_ERRMSG,
                                                       P_SLTJ      => 'QYMH');*/
     ------------------------------------------------------------------------------
     ----------------------by 20190606 ������ձ���վ��Ʊ�쳣----------------------
     ------------------------------------------------------------------------------
          SELECT COUNT(*) INTO V_COUNT FROM payment WHERE PSPJE<>0 AND PBATCH=V_PBATCH;
            IF V_COUNT = 0 THEN
              PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '1',
                                                       P_INVTYPE   => 'P',
                                                       P_INVNO     => 'HRBZLS.00000001',
                                                       O_CODE      => O_CODE,
                                                       O_ERRMSG    => O_ERRMSG,
                                                       P_SLTJ      => 'QYMH');
            ELSE
              PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '2',
                                                       P_INVTYPE   => 'P',
                                                       P_INVNO     => 'HRBZLS.00000001',
                                                       O_CODE      => O_CODE,
                                                       O_ERRMSG    => O_ERRMSG,
                                                       P_SLTJ      => 'QYMH');
            END IF;
      ------------------------------------------------------------------------------
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK;
              O_CODE   := '99';
              O_ERRMSG := '��Ʊ����ʧ�ܣ�ʵ������[' || V_PBATCH || ']' ||
                          SUBSTR(SQLERRM, INSTR(SQLERRM, '['), LENGTH(SQLERRM));
          END;
         ELSE
          INSERT INTO INVPARMTERMP (PBATCH, IFPRINT,MEMO1) VALUES (V_PBATCH, 'Y',V_PTYPE);
          BEGIN
            SELECT COUNT(*) INTO V_COUNT FROM payment WHERE PSPJE<>0 AND PBATCH=V_PBATCH;
            IF V_COUNT = 0 THEN
              PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '1',
                                                       P_INVTYPE   => 'P',
                                                       P_INVNO     => 'HRBZLS.00000001',
                                                       O_CODE      => O_CODE,
                                                       O_ERRMSG    => O_ERRMSG,
                                                       P_SLTJ      => 'QYMH');
            ELSE
              PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '2',
                                                       P_INVTYPE   => 'P',
                                                       P_INVNO     => 'HRBZLS.00000001',
                                                       O_CODE      => O_CODE,
                                                       O_ERRMSG    => O_ERRMSG,
                                                       P_SLTJ      => 'QYMH');
            END IF;
            
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK;
              O_CODE   := '99';
              O_ERRMSG := '��Ʊ����ʧ�ܣ�ʵ������[' || V_PBATCH || ']' ||
                          SUBSTR(SQLERRM, INSTR(SQLERRM, '['), LENGTH(SQLERRM));
          END;
          end if;
      END IF;
      --�������߿���
   --   P_PRINTCTRL(V_GID, V_PBATCH);
      --���߷�Ʊ�ɹ��ύ
      IF O_CODE = '00' THEN
        COMMIT;
        dbms_lock.sleep(15); ---  �ȴ�15��
      ELSE
        ROLLBACK;
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100003');
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resState',
                     JSON_VALUE('error', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE(O_ERRMSG, FALSE));
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
        RETURN V_OUTISONSTR;
      END IF;
    ELSE
      O_CODE := '00'; -- �Ѿ���Ʊ�����Ƿ�Ʊ��û������
    END IF;
  
    IF O_CODE = '00' THEN
      --dbms_lock.sleep(2); ---  �ȴ�10��
      
      --�ر��ο�Ʊ��Ϣ
      J := 0;
      FOR INV IN (SELECT MAX(IE.GHFMC) FPTT,
                         MAX(IR.FP_DM) FPDM,
                         MAX(IR.FP_HM) FPHM,
                         MAX(IR.FWM) FPJYM,
                         MAX(IE.NSRSBH) NSRSBH,
                         MAX(IE.HJBHSJE) FPJE,
                         MAX(TO_CHAR(IE.KPRQ, 'YYYY-MM-DD HH24:MI:SS')) FPRQ,
                         --nvl(ir.pdf_file,IR.PDF_URL)
                         --nvl(REPLACE(pdf_file,'_0.PNG','.pdf'),PDF_URL) URL
                         MAX(PDF_URL) URL
                    FROM INV_EINVOICE_ST     IE,
                         INV_INFO_SP         II,
                         INV_EINVOICE_RETURN IR
                   WHERE IE.ID = II.ID
                     AND IE.FPQQLSH = IR.FPQQLSH
                     --AND (II.PPBATCH = V_PBATCH OR ( V_LX = 'L' AND II.RLID = V_PBATCH))
                     AND ((ii.rlid = V_PBATCH and V_LX = 'L') or ( ii.batch = V_PBATCH and (V_LX = 'P' or v_lx = 'R')))
                   ORDER BY FP_DM, FP_HM) LOOP
        J := J + 1;
        --��ϸ����
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].fptt',
                     JSON_VALUE(INV.FPTT, FALSE)); -- ��Ʊ̧ͷ
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].fpdm',
                     INV.FPDM); -- ��Ʊ����
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].fphm',
                     INV.FPHM); -- ��Ʊ����
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].fpjym',
                     INV.FPJYM); -- ��ƱУ����
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].nsrsbh',
                     INV.NSRSBH); -- ��˰��ʶ���
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].fpje',
                     INV.FPJE); -- ��Ʊ���
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].fprq',
                     INV.FPRQ); -- ��Ʊ����
        JSON_EXT.PUT(JSONOBJOUT, 'body.invLists[' || J || '].url', INV.URL); -- ��Ʊ��ַ
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].gdown',
                     '������'); -- ��Ʊ����
      END LOOP;
      IF J > 0 THEN
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
        JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('���κ�' || V_PBATCH || '��Ʊ�ɹ�', FALSE));
      ELSE
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
        JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('���κ�' || V_PBATCH ||
                                '��Ʊ�ɹ�,��Ʊ��δ���͹��������5���Ӻ��������أ�',
                                FALSE));
      END IF;
    ELSE
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100005');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('���κ�' || V_PBATCH || '��Ʊʧ�ܣ�', FALSE));
    END IF;
  
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    DELETE INV_SELFHELP_LIST WHERE YHH = V_KHDM AND PID = V_PBATCH;
    RETURN V_OUTISONSTR;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DELETE INV_SELFHELP_LIST WHERE YHH = V_KHDM AND PID = V_PBATCH;
      COMMIT;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;


  --5. �޸ķ�Ʊ̧ͷ��Ϣ(UPDATEINV)
  FUNCTION UPDATEINV(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_OUTISONSTR CLOB;

    V_KHDM   VARCHAR2(10); --�ͻ�����
    V_FPTT   LONG; --��Ʊ̧ͷ�����ƣ�
    V_NSRSBH LONG; --��˰��ʶ��ţ�˰�ţ�
    V_DZ     LONG; --��ַ
    V_DH     LONG; --�绰
    V_EMAIL  LONG; --���䣨�û����շ�Ʊ�����䣩
    V_KHMC   LONG; --��������
    V_KHYH   LONG; --��������
    V_KHZH   LONG; --�����˻�
    V_COUNT  NUMBER := 0;
    V_IFZZS  VARCHAR2(10);

  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --�ͻ�����
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    V_KHDM := SUBSTR(V_KHDM,-10,10);
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{}');

    --���У��
    IF TRIM(V_KHDM) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('�ͻ����벻��Ϊ��', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --��ѯ�Ƿ���ڴ��û�
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --�ж���ֵ˰רƱ
    SELECT NVL(MIIFTAX, 'N')
      INTO V_IFZZS
      FROM METERINFO
     WHERE MIID = V_KHDM;
    IF V_IFZZS = 'Y' THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100003');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('��ֵ˰�û������ڴ˴��޸ķ�Ʊ̧ͷ��Ϣ', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    V_FPTT   := JSON_EXT.GET_STRING(JSONOBJIN, 'body.fptt'); --��Ʊ̧ͷ�����ƣ�
    V_NSRSBH := JSON_EXT.GET_STRING(JSONOBJIN, 'body.nsrsbh'); --��˰��ʶ��ţ�˰�ţ�
    V_DZ     := JSON_EXT.GET_STRING(JSONOBJIN, 'body.dz'); --��ַ
    V_DH     := JSON_EXT.GET_STRING(JSONOBJIN, 'body.dh'); --�绰
    V_EMAIL  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.email'); --���䣨�û����շ�Ʊ�����䣩
    V_KHMC   := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khmc'); --��������
    V_KHYH   := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khyh'); --��������
    V_KHZH   := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khzh'); --�����˻�

    BEGIN
      UPDATE METERINFO MI SET MITAXNO = V_NSRSBH WHERE MI.MIID = V_KHDM;

      UPDATE TAXMETERINV TV
         SET TV.TINAME    = V_FPTT,
             TV.TITAXCODE = V_NSRSBH,
             TV.TIADDR    = V_DZ,
             TV.TITEL     = V_DH,
             TV.TIEMAIL   = V_EMAIL,
             TV.TIBANK    = V_KHYH,
             TV.TIBANKACC = V_KHZH
       WHERE TV.TIMID = V_KHDM;
      IF SQL%NOTFOUND THEN
        INSERT INTO TAXMETERINV
          (TIMID,
           TINAME,
           TIBANK,
           TIBANKACC,
           TITAXCODE,
           TIADDR,
           TITEL,
           TIMTEL,
           TIEMAIL,
           TITYPE,
           TIMEMO,
           TIFPTNO)
        VALUES
          (V_KHDM,
           V_FPTT,
           V_KHYH,
           V_KHZH,
           V_NSRSBH,
           V_DZ,
           V_DH,
           NULL,
           V_EMAIL,
           '04',
           NULL,
           NULL);
      END IF;
      COMMIT;
    END;
    JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
    JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.resMsg',
                 JSON_VALUE('�޸ķ�Ʊ̧ͷ��Ϣ�ɹ�', FALSE));
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --6. �Ƿ���Կ�Ʊ(ISOPENINV)�����ṩ�Ļ��������ж����Կ�Ʊ
  FUNCTION ISOPENINV(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_OUTISONSTR CLOB;

    V_KHDM  VARCHAR2(10); --�ͻ�����
    V_COUNT NUMBER := 0;

    V_IS_KP VARCHAR2(10); --�Ƿ���Կ�Ʊ��1���Կ�Ʊ��0�����Կ�Ʊ��

  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --�ͻ�����
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    V_KHDM := SUBSTR(V_KHDM,-10,10);
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{}');

    --���У��
    IF TRIM(V_KHDM) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('�ͻ����벻��Ϊ��', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --��ѯ�Ƿ���ڴ��û�
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    BEGIN
      SELECT DECODE(NVL(MI.MIIFTAX, 'N'), 'Y', '0', '1')
        INTO V_IS_KP
        FROM METERINFO MI
       WHERE MI.MIID = V_KHDM;
    EXCEPTION
      WHEN OTHERS THEN
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resState',
                     JSON_VALUE('error', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('��ȡ��Ʊ��Ϣʧ��', FALSE));
        JSON_EXT.PUT(JSONOBJOUT, 'body.is_kp', JSON_VALUE(V_is_kp, FALSE)); --��ˮ������
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
        RETURN V_OUTISONSTR;
    END;
    JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
    JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.resMsg',
                 JSON_VALUE('��ȡ��Ʊ��Ϣ�ɹ�', FALSE));
    JSON_EXT.PUT(JSONOBJOUT, 'body.is_kp', JSON_VALUE(V_is_kp, FALSE));

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --7. ���ݿͻ������ȡ��Ʊ��Ϣ��GETINVINFO����
  FUNCTION GETINVINFO(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_OUTISONSTR CLOB;

    V_KHDM  VARCHAR2(10); --�ͻ�����
    V_COUNT NUMBER := 0;

    V_FPTT   LONG; --��Ʊ̧ͷ�����ƣ�
    V_NSRSBH LONG; --��˰��ʶ��ţ�˰�ţ�
    V_DZ     LONG; --��ַ
    V_DH     LONG; --�绰
    V_EMAIL  LONG; --���䣨�û����շ�Ʊ�����䣩
    V_KHMC   LONG; --��������
    V_KHYH   LONG; --��������
    V_KHZH   LONG; --�����˻�
    V_CZSBS  LONG; --��ֵ˰��ʶ��Y��N��

  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --�ͻ�����
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    V_KHDM := SUBSTR(V_KHDM,-10,10);
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{}');

    --���У��
    IF TRIM(V_KHDM) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('�ͻ����벻��Ϊ��', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --��ѯ�Ƿ���ڴ��û�
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    BEGIN
      SELECT TINAME FPTT,
             TITAXCODE NSRSBH,
             TIADDR DZ,
             TITEL DH,
             TIEMAIL EMAIL,
             TINAME KHMC,
             TIBANK KHYH,
             TIBANKACC KHZH,
             NVL(MI.MIIFTAX, 'N') CZSBS
        INTO V_FPTT, --��Ʊ̧ͷ�����ƣ�
             V_NSRSBH, --��˰��ʶ��ţ�˰�ţ�
             V_DZ, --��ַ
             V_DH, --�绰
             V_EMAIL, --���䣨�û����շ�Ʊ�����䣩
             V_KHMC, --��������
             V_KHYH, --��������
             V_KHZH, --�����˻�
             V_CZSBS --��ֵ˰��ʶ��Y��N��
        FROM CUSTINFO CI, METERINFO MI
        LEFT JOIN METERINFOSP MSP
          ON MI.MIID = MSP.MIID
       WHERE CI.CIID = MI.MICID
         AND MI.MIID = V_KHDM;
    EXCEPTION
      WHEN OTHERS THEN
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resState',
                     JSON_VALUE('error', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('��ȡ��Ʊ��Ϣʧ��', FALSE));
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
        RETURN V_OUTISONSTR;
    END;
    JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
    JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.resMsg',
                 JSON_VALUE('��ȡ��Ʊ��Ϣ�ɹ�', FALSE));
    JSON_EXT.PUT(JSONOBJOUT, 'body.fptt', JSON_VALUE(V_FPTT, FALSE)); --��ˮ������
    JSON_EXT.PUT(JSONOBJOUT, 'body.nsrsbh', JSON_VALUE(V_NSRSBH, FALSE)); --��˰��ʶ��ţ�˰�ţ�
    JSON_EXT.PUT(JSONOBJOUT, 'body.dz', JSON_VALUE(V_DZ, FALSE)); --�ͻ���ַ
    JSON_EXT.PUT(JSONOBJOUT, 'body.dh', V_DH); --�绰
    JSON_EXT.PUT(JSONOBJOUT, 'body.khmc', JSON_VALUE(V_FPTT, FALSE)); --��������
    JSON_EXT.PUT(JSONOBJOUT, 'body.khyh', JSON_VALUE(V_KHYH, FALSE)); --��������
    JSON_EXT.PUT(JSONOBJOUT, 'body.khzh', JSON_VALUE(V_KHZH, FALSE)); --�����˻�
    JSON_EXT.PUT(JSONOBJOUT, 'body.email', JSON_VALUE(V_EMAIL, FALSE)); --����
    JSON_EXT.PUT(JSONOBJOUT, 'body.czsbs', V_CZSBS); --��ֵ˰��ʶ��Y��N��

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --8. ���ݿͻ������޸�����
  FUNCTION UPDATEPWD(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_OUTISONSTR CLOB;

    V_KHDM VARCHAR2(10); --�ͻ�����

    V_COUNT NUMBER := 0;
    V_PWD  VARCHAR2(100);
    V_YPWD  VARCHAR2(100);
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --�ͻ�����
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    V_KHDM := SUBSTR(V_KHDM,-10,10);
    --������
    V_PWD := trim(JSON_EXT.GET_STRING(JSONOBJIN, 'body.pwd'));
    V_YPWD := trim(JSON_EXT.GET_STRING(JSONOBJIN, 'body.ypwd'));
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{}');

    --���У��
    IF TRIM(V_KHDM) IS NULL OR TRIM(V_PWD) IS NULL or TRIM(V_YPWD) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('�ͻ�����������뼰ԭ���벻��Ϊ��', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;
    IF LENGTH(TRIM(V_YPWD))>10 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('�����볤�Ȳ�������10λ', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --��ѯ�Ƿ���ڴ��û�
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    SELECT COUNT(1)
        INTO V_COUNT
        FROM METERINFO
       WHERE MIID = V_KHDM
         AND miyl4 = MD5(V_YPWD);
     IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100003');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('ԭ���벻��', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    IF TRIM(V_PWD) = TRIM(V_YPWD) THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100004');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('�������ԭ���벻����ͬ', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    BEGIN
      UPDATE METERINFO MI SET MIYL4 = md5(TRIM(V_PWD)) WHERE MI.MIID = V_KHDM;
      COMMIT;
    END;
    JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
    JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.resMsg',
                 JSON_VALUE('�޸��û�����ɹ�', FALSE));
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --�õ��û�Ƿ��
  FUNCTION GETUSERQF(V_MIID IN VARCHAR2) RETURN NUMBER IS
    VRET NUMBER(12, 2);
  BEGIN
    BEGIN
      SELECT NVL(PG_EWIDE_PAY_01.GETZNJADJ(RLID,
                                           SUM(RLJE),
                                           RLGROUP,
                                           MAX(RLZNDATE),
                                           RLSMFID,
                                           TRUNC(SYSDATE)) + SUM(RLJE),
                 0)
        INTO VRET
        FROM RECLIST
       WHERE RLMID = V_MIID
         AND RLPAIDFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N';
    EXCEPTION
      WHEN OTHERS THEN
        VRET := 0;
    END;
    RETURN VRET;
  END;

FUNCTION INVFILE(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_OUTISONSTR CLOB;

    V_KHDM   VARCHAR2(10); --�ͻ�����
    p_PBATCH VARCHAR2(20); --'P'+ʵ������
    V_PBATCH VARCHAR2(20); --ʵ������
    V_COUNT  NUMBER := 0;
    V_GID    PRINTLOG.GID%TYPE;
    J        NUMBER := 0;
    V_ID     VARCHAR2(10);
    O_CODE   VARCHAR2(10);
    O_ERRMSG VARCHAR2(100);
    v_lx     char(1);

  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --�ͻ�����
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    V_KHDM := SUBSTR(V_KHDM,-10,10);
    --ʵ������
    p_PBATCH := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pbatch');
    V_PBATCH := SUBSTR(p_PBATCH,-10,10);
    V_LX := SUBSTR(p_PBATCH,1,1);
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{}');

    --���У��
    IF TRIM(V_KHDM) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('�ͻ����벻��Ϊ��', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --��ѯ�Ƿ���ڴ��û�
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

     SELECT max(id)
          INTO V_ID
          FROM invstock_sp it, inv_info_sp ii
          WHERE it.isid = to_number(ii.isid)
          AND ((ii.rlid = V_PBATCH and V_LX = 'L') or ( ii.batch = V_PBATCH and V_LX = 'P'))
          AND it.istype = 'P'
          AND ii.status = '0'
          And it.isstatus = '1';
    UPDATE INV_INFO_SP t SET T.PRINTNUM=T.PRINTNUM+1 WHERE ID = V_ID;
    COMMIT;
    --printnum
      /*  SELECT COUNT(*)
          INTO V_COUNT
          FROM INV_EINVOICE_ST IE, INV_INFO_SP II
         WHERE IE.ID = II.ID
           AND II.PPBATCH = V_PBATCH
           AND II.ISID IS NULL;*/



    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

FUNCTION GETURL(V_PID IN VARCHAR2,V_LX IN VARCHAR2) RETURN VARCHAR2 IS
    VRET VARCHAR2(1000);
  BEGIN
    BEGIN
   /*   select nvl(REPLACE(max(pdf_file),'_0.PNG','.pdf'),MAX(PDF_URL)) INTO VRET from INV_EINVOICE_ST t,INV_EINVOICE_RETURN t2,invstock_sp it,INV_INFO_SP idt
   where t.fpqqlsh = t2.fpqqlsh and t.ispcisno = IT.ISPCISNO AND  idt.isid = it.isid AND
   ISSTATUS = '1' AND ((PID = V_PID AND V_LX = 'P') OR (RLID = V_PID AND V_LX = 'L')) ;
   select replace(VRET,'http://10.10.10.64:9997/EwideHttpServer/getInvFile','http://www.hrbwatercsc.com') into VRET from dual;
   select replace(VRET,'http://10.10.10.64:9996/EwideHttpServer/getInvFile','http://www.hrbwatercsc.com') into VRET from dual;*/
   select MAX(PDF_URL) INTO VRET from INV_EINVOICE_ST t,INV_EINVOICE_RETURN t2,invstock_sp it,INV_INFO_SP idt
   where t.fpqqlsh = t2.fpqqlsh and t.ID=IDT.ID AND  idt.isid = it.isid AND
   ISSTATUS = '1' AND ((PID = V_PID AND V_LX = 'P') OR (RLID = V_PID AND V_LX = 'L')) ;
    EXCEPTION
      WHEN OTHERS THEN
        VRET := NULL;
    END;
    RETURN VRET;
  END;


  --��¼��־
  PROCEDURE P_LOG(P_ID     IN OUT NUMBER,
                  P_CODE   IN VARCHAR2,
                  P_I_JSON IN VARCHAR2,
                  P_O_JSON IN VARCHAR2,
                  P_V_IP   IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_ID NUMBER;
  BEGIN
    IF P_ID IS NOT NULL THEN
      UPDATE INV_SELFHELP_LOG SET O_JSON = P_O_JSON WHERE ID = P_ID;
    ELSE
      SELECT SEQ_INV_LOGS.NEXTVAL INTO V_ID FROM DUAL;
      INSERT INTO INV_SELFHELP_LOG
        (ID, CODE, TPDATE, OPERATOR, I_JSON, O_JSON, IP)
      VALUES
        (V_ID, P_CODE, SYSDATE, FGETPBOPER, P_I_JSON, P_O_JSON, P_V_IP);
    END IF;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  --��ӡ���ƣ���ֹ�ظ���Ʊ
  PROCEDURE P_PRINTCTRL(P_GID IN OUT VARCHAR2, P_FID IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    PLOG PRINTLOG%ROWTYPE;
  BEGIN
    IF P_GID IS NOT NULL THEN
      DELETE FROM PRINTLOG WHERE GID = P_GID;
    ELSE
      PLOG := NULL;
      SELECT SYS_GUID() INTO P_GID FROM DUAL;
      PLOG.GID   := P_GID; --���
      PLOG.FID   := P_FID; --��ʶ��
      PLOG.FTYPE := 'SH'; --����
      INSERT INTO PRINTLOG VALUES PLOG;
    END IF;
    COMMIT;
  END;

BEGIN
  NULL;
END PG_INV_SELFHELP;
/

