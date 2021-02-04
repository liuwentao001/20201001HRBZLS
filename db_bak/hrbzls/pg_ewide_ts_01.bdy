CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_TS_01" IS
  --CURRENTDATE DATE := TOOLS.FGETSYSDATE;

  ---------------------------------------------------------------------------
  PROCEDURE SP_CREATE_TS(P_MODEL   IN VARCHAR2, --���� TS ,���� LT
                         P_BANKID  IN VARCHAR2,
                         P_MFSMFID IN VARCHAR2,
                         P_OPER    IN VARCHAR2,
                         P_SRLDATE IN VARCHAR2,
                         P_ERLDATE IN VARCHAR2,
                         P_SMON    IN VARCHAR2,
                         P_EMON    IN VARCHAR2,
                         P_SFTYPE  IN VARCHAR2,
                         P_COMMIT  IN VARCHAR2,
                         O_BATCH   OUT VARCHAR2) IS

  BEGIN
    SP_CREATE_TS_MAACCOUNT_03(P_MODEL,
                              P_BANKID,
                              P_MFSMFID,
                              P_OPER,
                              P_SRLDATE,
                              P_ERLDATE,
                              P_SMON,
                              P_EMON,
                              P_SFTYPE,
                              'N', --p_commit   ,
                              O_BATCH);
    /*    sp_create_ts_maaccount_01(P_MODEL,
                              p_bankid,
                              p_mfsmfid,
                              p_oper,
                              p_srldate,
                              p_erldate,
                              p_smon,
                              p_emon,
                              p_sftype,
                              'N', -- p_commit   ,
                              o_batch);
    sp_create_ts_maaccount_02(P_MODEL,
                              p_bankid,
                              p_mfsmfid,
                              p_oper,
                              p_srldate,
                              p_erldate,
                              p_smon,
                              p_emon,
                              p_sftype,
                              'N', --p_commit   ,
                              o_batch);*/
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  ---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid_01
  --note:T:����
  --author:wy
  --date��2009/04/26
  --input: P_MODEL   IN VARCHAR2 ,--���� TS ,���� LT
  -- p_bankid:���д���
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־
  --˵�������շ���һ��Ӧ��һ��һ�����շѼ�¼

  ---------------------------------------------------------------------------
  PROCEDURE SP_CREATE_TS_MAACCOUNT_01(P_MODEL   IN VARCHAR2, --���� TS ,���� LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2) IS
    EL ENTRUSTLIST%ROWTYPE;
    EG ENTRUSTLOG%ROWTYPE;
    MI METERINFO%ROWTYPE;

    RL            RECLIST%ROWTYPE;
    MA            METERACCOUNT%ROWTYPE;
    V_MAACCOUNTNO METERACCOUNT.MAACCOUNTNO%TYPE;
    V_RLID        RECLIST.RLID%TYPE;
    V_SFJE        RECLIST.RLJE%TYPE;
    V_LJFJE       RECLIST.RLJE%TYPE;
    V_LJFSL       RECLIST.RLSL%TYPE;
    CURSOR C_YSZS IS
      SELECT MAX((CASE
                   WHEN RLGROUP = 1 THEN
                    RLID
                   ELSE
                    ''
                 END)) RLID, --Ӧ����ˮ
             MAX((CASE
                   WHEN RLGROUP = 3 THEN
                    RLID
                   ELSE
                    ''
                 END)) RLIDLJ,
             MIID, --ˮ���
             MICODE, --�ͻ�����
             MAX(MABANKID), --����ID
             MAACCOUNTNO, --�û������ʺ�
             MAX(MAACCOUNTNAME), --�û�������
             MAX(MATSBANKID), --�û�������
             SUM(RLJE), --Ӧ�ս��
             SUM(CASE
                   WHEN RLGROUP = 1 THEN
                    RLJE
                   ELSE
                    0
                 END) SFJE, --ˮ�ѽ��
             SUM(CASE
                   WHEN RLGROUP = 3 THEN
                    RLJE
                   ELSE
                    0
                 END) LJFJE, --�����ѽ��
             SUM(CASE
                   WHEN RLGROUP = 1 THEN
                    RLSL
                   ELSE
                    0
                 END) SFSL, --ˮ��ˮ��
             SUM(CASE
                   WHEN RLGROUP = 3 THEN
                    RLSL
                   ELSE
                    0
                 END) LJFSL, --������ˮ��
             MAX(RLZNDATE), --���ɽ�������
             /*             PG_EWIDE_PAY_01.getznjadj(mismfid,
             rlje,
             rlgroup,
             rlzndate,
             mismfid,
             sysdate), --���ɽ�*/
             0, --���ɽ�
             RLMONTH, --Ӧ�����·�
             MAX(RLCADR), --�û���ַ
             MAX(RLMADR), --ˮ���ַ
             MAX(RLCNAME), --��Ȩ��
             T1.MIUIID
        FROM METERACCOUNT T, METERINFO T1, /*ˮ��Ƿ�� T3,*/ RECLIST T
       WHERE MIID = MAMID
         AND (P_MODEL = 'TS' OR
             (P_MODEL = 'LT' AND RLID IN (SELECT C1 FROM PBPARMTEMP)))
            -- AND T3.QFMIID = MIID
         AND MIID = RLMID
         AND RLOUTFLAG = 'N'
         AND RLJE > 0
         AND RLCD = 'DE'
         AND RLPAIDFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
         AND T1.MIUIID IS NOT NULL
            --and t3.�ϼ�Ƿ��>0
         AND ((MISMFID = P_MFSMFID AND P_MFSMFID IS NOT NULL) OR
             P_MFSMFID IS NULL)
         AND T1.MICHARGETYPE = P_SFTYPE
         AND T.MATSBANKID LIKE P_BANKID || '%'
         AND ((RLMONTH >= P_SMON AND P_SMON IS NOT NULL) OR P_SMON IS NULL)
         AND ((RLMONTH <= P_EMON AND P_EMON IS NOT NULL) OR P_EMON IS NULL)
         AND ((RLDATE >= TO_DATE(P_SRLDATE, 'yyyymmdd') AND
             P_SRLDATE IS NOT NULL) OR P_SRLDATE IS NULL)
         AND ((RLDATE <= TO_DATE(P_ERLDATE, 'yyyymmdd') AND
             P_ERLDATE IS NOT NULL) OR P_ERLDATE IS NULL)
         AND RLGROUP <> 2 --    AND RLMONTH='2012.02'
       GROUP BY RLMRID, MAACCOUNTNO, MATSBANKID, MIID, MICODE, RLMONTH
       ORDER BY MAACCOUNTNO;
  BEGIN
    IF P_SFTYPE <> 'T' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�շѷ�ʽ�������');
    END IF;
    EG.ELOUTROWS  := 0; --������
    EG.ELOUTMONEY := 0; --�������
    SELECT 'S' || TRIM(TO_CHAR(SEQ_ENTRUSTLOG.NEXTVAL, '000000000'))
      INTO EG.ELBATCH
      FROM DUAL;
    --����м��ʺ���
    --    v_maaccountno := null;
    V_RLID := NULL;
    OPEN C_YSZS;
    LOOP
      FETCH C_YSZS
        INTO RL.RLID, --Ӧ����ˮ
             V_RLID, --��������ˮ
             MI.MIID, --ˮ���
             MI.MICODE, --�ͻ�����
             MA.MABANKID, --����ID
             MA.MAACCOUNTNO, --�û������ʺ�
             MA.MAACCOUNTNAME, --�û�������
             MA.MATSBANKID,
             RL.RLJE, --Ӧ�ս��
             V_SFJE, --ˮ�ѽ��
             V_LJFJE, --�����ѽ��
             RL.RLSL, --ˮ��ˮ��
             V_LJFSL, --������ˮ��
             RL.RLZNDATE, --���ɽ�������
             RL.RLZNJ, --���ɽ�
             RL.RLMONTH, --Ӧ�����·�
             RL.RLCADR, --�û���ַ
             RL.RLMADR, --ˮ���ַ
             RL.RLCNAME, --��Ȩ��
             MI.MIUIID;
      EXIT WHEN C_YSZS%NOTFOUND OR C_YSZS%NOTFOUND IS NULL;
      EL.ETLBATCH := EG.ELBATCH; --��������
      --EL.TLSEQNO            :=  ;--������ˮ
      EL.ETLRLID        := RL.RLID; --Ӧ����ˮ
      EL.ETLMID         := MI.MIID; --ˮ����
      EL.ETLMCODE       := MI.MICODE; --���Ϻ�
      EL.ETLBANKID      := MA.MABANKID; --��������
      EL.ETLACCOUNTNO   := MA.MAACCOUNTNO; --�����ʺ�
      EL.ETLACCOUNTNAME := MA.MAACCOUNTNAME; --������
      EL.ETLZNDATE      := RL.RLZNDATE; --���ɽ�������
      --EL.ETLPIID             :=  ;--������Ŀ
      --EL.ETLPAIDDATE         :=  ;--��������
      --EL.ETLPAIDCDATE        :=  ;--��������
      EL.ETLPAIDFLAG := 'N'; --���ʱ�־
      --EL.ETLRETURNCODE       :=  ;--������Ϣ��
      --EL.ETLRETURNMSG        :=  ;--������Ϣ
      --EL.ETLCHKDATE          :=  ;--��������
      EL.ETLSFLAG    := 'N'; --���гɹ��ۿ��־
      EL.ETLRLDATE   := RL.RLDATE; --Ӧ����������
      EL.ETLNO       := MA.MANO; --ί����Ȩ��
      EL.ETLTSBANKID := MA.MATSBANKID; --�����кţ��У�
      EL.ETLPZNO     := V_RLID; --ƾ֤��  ������������Ӧ����ˮ
      EL.ETLCIADR    := RL.RLCADR; --�û���ַ
      EL.ETLMIADR    := RL.RLMADR; --ˮ���ַ
      --EL.ETLBANKIDNAME       :=  ;--������������
      --EL.ETLBANKIDNO         :=  ;--��������ʵ�ʱ��
      --EL.ETLTSBANKIDNAME     :=  ;--�տ�����
      -- EL.ETLTSBANKIDNO       :=  ;--�տ��к�
      EL.ETLSFJE := V_SFJE; --ˮ��
      --EL.ETLWSFJE            :=  ;--��ˮ��
      --EL.ETLSFZNJ            :=  ;--ˮ�����ɽ�
      --EL.ETLWSFZNJ           :=  ;--��ˮ�����ɽ�
      --EL.ETLRLIDPIID         :=  ;--Ӧ����ˮ�ӷ�����Ŀ
      EL.ETLSL := RL.RLSL; --ˮ��
      --EL.ETLWSL              :=  ;--��ˮ��
      --EL.ETLSFDJ             :=  ;--ˮ�ѵ���
      --EL.ETLWSFDJ            :=  ;--��ˮ�ѵ���
      EL.ETLCINAME  := RL.RLCNAME; --��Ȩ��
      EL.ETLRLMONTH := RL.RLMONTH; --Ӧ�����·�
      --EL.ETLCHRMODE          :=  ;--���ʷ�ʽ��1��δ���� ��2���ĵ����ʣ�3���ֹ�����,4:����,5:����δ�����ȫ������,6:����δ����Ĳ�������,7���з���δ����
      --EL.ETLPAIDPER          :=  ;--����Ա
      --EL.ETLTSACCOUNTNO      :=  ;--�տ��к�
      --EL.ETLTSACCOUNTNAME    :=  ;--�տ��
      --EL.ETLSZYFZNJ          :=  ;--ˮ��Դ�����ɽ�
      --EL.ETLLJFZNJ           :=  ;--������������ɽ�
      --EL.ETLSZYFSL           :=  ;--ˮ��Դˮ��
      EL.ETLLJFSL := V_LJFSL; --������ˮ��
      --EL.ETLSZYFDJ           :=  ;--ˮ��Դ�ѵ���
      --EL.ETLLJFDJ            :=  ;--�����ѵ���
      --EL.ETLINVSFCOUNT       :=  ;--�����ѵ���
      --EL.ETLINVWSFCOUNT      :=  ;--�����ѵ���
      --EL.ETLINVSZYFCOUNT     :=  ;--�����ѵ���
      --EL.ETLINVLJFCOUNT      :=  ;--�����ѵ���
      --EL.ETLMIUIID           :=  ;--���յ�λ���
      --EL.ETLSZYFJE           :=  ;--ˮ��Դ��
      EL.ETLLJFJE := V_LJFJE; --������
      EL.ETLIFINV := 0; --��Ʊ�Ƿ��Ѵ�ӡ����Ʊ����ƾ֤��
      --ÿһ��Ӧ������һ����¼
      SELECT TRIM(TO_CHAR(SEQ_ENTRUSTLIST.NEXTVAL, '0000000000'))
        INTO EL.ETLSEQNO
        FROM DUAL;
      EL.ETLSXF      := 0; --������
      EL.ETLZNJ      := RL.RLZNJ; --Ӧ�����ɽ�
      EL.ETLJE       := RL.RLJE + RL.RLZNJ + 0; --Ӧ�ս��
      EL.ETLINVCOUNT := 1; --��Ʊ����
      EG.ELOUTROWS   := EG.ELOUTROWS + 1; --������
      ---ÿһ���ʺ�����һ����¼
      /*if v_maaccountno is null or ( v_maaccountno is not null and v_maaccountno<>ma.maaccountname )  then
            select trim(to_char(seq_entrustlist.nextval, '0000000000'))
              into EL.ETLSEQNO
              from dual;

            EL.ETLSXF := 0; --������
            EL.ETLZNJ := rl.rlznj; --Ӧ�����ɽ�
            EL.ETLJE     := rl.rlje + rl.rlznj + 0 ; --Ӧ�ս��
            EL.ETLINVCOUNT := 1; --��Ʊ����
            eg.eloutrows  := eg.eloutrows + 1; --������
      else
            EL.ETLSXF :=EL.ETLSXF + 0; --������
            EL.ETLZNJ :=EL.ETLZNJ +  rl.rlznj; --Ӧ�����ɽ�
            EL.ETLJE  :=EL.ETLJE + rl.rlje + rl.rlznj + 0  ; --Ӧ�ս��
            EL.ETLINVCOUNT :=EL.ETLINVCOUNT + 1; --��Ʊ����

      end if; */

      BEGIN
        INSERT INTO ENTRUSTLIST VALUES EL;
      EXCEPTION
        WHEN OTHERS THEN
          UPDATE ENTRUSTLIST T
             SET ETLSXF      = EL.ETLSXF, --������
                 ETLZNJ      = EL.ETLZNJ, --Ӧ�����ɽ�
                 ETLJE       = EL.ETLJE, --Ӧ�ս��
                 ETLWSFJE    = EL.ETLWSFJE, --��ˮ��
                 ETLINVCOUNT = EL.ETLINVCOUNT --��Ʊ����
           WHERE T.ETLBATCH = EL.ETLBATCH
             AND T.ETLSEQNO = EL.ETLSEQNO;
      END;

      --���ʣ��������κţ���ˮ�����ɽ���ڻ�������
      UPDATE RECLIST T
         SET T.RLZNJ          = RL.RLZNJ,
             T.RLOUTFLAG      = 'Y',
             T.RLENTRUSTBATCH = EL.ETLBATCH,
             T.RLENTRUSTSEQNO = EL.ETLSEQNO
       WHERE RLID = RL.RLID;

      UPDATE RECLIST T
         SET T.RLZNJ          = RL.RLZNJ,
             T.RLOUTFLAG      = 'Y',
             T.RLENTRUSTBATCH = EL.ETLBATCH,
             T.RLENTRUSTSEQNO = EL.ETLSEQNO
       WHERE RLID = V_RLID;

      /*--������ϸ�ͽ�
      update recdetail t set t.rdznj = 0 where rdid = rl.rlid;
      update recdetail t
         set t.rdznj = rl.rlznj
       where rdid = rl.rlid
         and rownum = 1;*/

      EG.ELOUTMONEY := EG.ELOUTMONEY + RL.RLJE; --�������

      --     v_maaccountno := ma.maaccountno  ;

    END LOOP;
    CLOSE C_YSZS;
    IF EG.ELOUTMONEY > 0 THEN
      --eg.ELBATCH          :=    ;--���մ�������
      EG.ELBANKID     := NULL; --�����ĵ�����
      EG.ELCHARGETYPE := P_SFTYPE; --�շѷ�ʽ
      EG.ELOUTOER     := P_OPER; --��������Ա
      EG.ELOUTDATE    := SYSDATE; --��������
      --eg.ELOUTROWS        :=    ;--��������
      --eg.ELOUTMONEY       :=    ;--�������
      --eg.ELCHKDATE        :=    ;--��������
      EG.ELCHKROWS := 0; --����������
      EG.ELCHKJE   := 0; --�����ܽ��
      --eg.ELSCHKDATE       :=    ;--�ɹ��ļ���������
      EG.ELSROWS := 0; --���гɹ�����
      EG.ELSJE   := 0; --���гɹ����
      --eg.ELFCHKDATE       :=    ;--ʧ���ļ���������
      EG.ELFROWS := 0; --����ʧ������
      EG.ELFJE   := 0; --����ʧ�ܽ��
      --eg.ELPAIDDATE       :=    ;--������������
      EG.ELPAIDROWS := 0; --��������������
      EG.ELPAIDJE   := 0; --���������ʽ��
      EG.ELCHKNUM   := 0; --���ض��˴���
      EG.ELCHKEND   := 'N'; --���ض��˽�ֹ��־
      EG.ELSTATUS   := 'Y'; --��Ч״̬
      EG.ELSMFID    := P_MFSMFID; --Ӫҵ��
      --eg.ELTSTYPE         :=    ;--�������ͣ�1��������,2���У�
      --eg.ELPLANIMPDATE    :=    ;--�ƻ���������
      --eg.ELIMPTYPE        :=    ;--�ļ���������1��δ����2���ֹ���3���Զ�
      --eg.ELRECMONTH       :=    ;--Ӧ�����·�
      INSERT INTO ENTRUSTLOG VALUES EG;
      O_BATCH := EG.ELBATCH;
      IF P_COMMIT = 'Y' THEN
        COMMIT;
      END IF;
    ELSE
      NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF C_YSZS%ISOPEN THEN
        CLOSE C_YSZS;
      END IF;
      RAISE;
  END;

  ---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid_02
  --note:T:����
  --author:yf
  --date��2012/02/08
  --input: P_MODEL   IN VARCHAR2 ,--���� TS ,���� LT
  -- p_bankid:���д���
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־
  --˵�������շ���һ��Ӧ��һ��һ�����շѼ�¼

  ---------------------------------------------------------------------------
  PROCEDURE SP_CREATE_TS_MAACCOUNT_02(P_MODEL   IN VARCHAR2, --���� TS ,���� LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2) IS
    EL ENTRUSTLIST%ROWTYPE;
    EG ENTRUSTLOG%ROWTYPE;
    MI METERINFO%ROWTYPE;

    RL            RECLIST%ROWTYPE;
    MA            METERACCOUNT%ROWTYPE;
    V_MAACCOUNTNO METERACCOUNT.MAACCOUNTNO%TYPE;
    V_RLID        RECLIST.RLID%TYPE;

    CURSOR C_YSZW IS
      SELECT RLID, --Ӧ��ˣ��            
             MIID, --ˮ���
             MICODE, --�ͻ�����
             MABANKID, --����ID
             MAACCOUNTNO, --�û������ʺ�
             MAACCOUNTNAME, --�û�������
             MATSBANKID,
             RLJE, --Ӧ�ս��
             RLZNDATE, --���ɽ�������
             /*             PG_EWIDE_PAY_01.getznjadj(mismfid,
             rlje,
             rlgroup,
             rlzndate,
             mismfid,
             sysdate), --���ɽ�*/
             0, --���ɽ�
             RLMONTH, --Ӧ�����·�
             RLCADR, --�û���ַ
             RLMADR, --ˮ���ַ
             RLCNAME --��Ȩ��
        FROM METERACCOUNT T, METERINFO T1, /*ˮ��Ƿ�� T3,*/ RECLIST T
       WHERE MIID = MAMID
         AND (P_MODEL = 'TS' OR
             (P_MODEL = 'LT' AND RLID IN (SELECT C1 FROM PBPARMTEMP)))
            -- AND T3.QFMIID = MIID
         AND MIID = RLMID
         AND RLOUTFLAG = 'N'
         AND RLJE > 0
         AND RLCD = 'DE'
         AND RLPAIDFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
         AND T1.MIUIID IS NOT NULL
            --and t3.�ϼ�Ƿ��>0
         AND ((MISMFID = P_MFSMFID AND P_MFSMFID IS NOT NULL) OR
             P_MFSMFID IS NULL)
         AND T1.MICHARGETYPE = P_SFTYPE
         AND T.MATSBANKID LIKE P_BANKID || '%'
         AND ((RLMONTH >= P_SMON AND P_SMON IS NOT NULL) OR P_SMON IS NULL)
         AND ((RLMONTH <= P_EMON AND P_EMON IS NOT NULL) OR P_EMON IS NULL)
         AND ((RLDATE >= TO_DATE(P_SRLDATE, 'yyyymmdd') AND
             P_SRLDATE IS NOT NULL) OR P_SRLDATE IS NULL)
         AND ((RLDATE <= TO_DATE(P_ERLDATE, 'yyyymmdd') AND
             P_ERLDATE IS NOT NULL) OR P_ERLDATE IS NULL)
         AND RLGROUP = 2
       ORDER BY MAACCOUNTNO;
  BEGIN
    --  INSERT INTO PBPARMTEMP (C1) VALUEs ('89610631');
    IF P_SFTYPE <> 'T' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�շѷ�ʽ�������');
    END IF;
    EG.ELOUTROWS  := 0; --������
    EG.ELOUTMONEY := 0; --�������
    SELECT 'W' || TRIM(TO_CHAR(SEQ_ENTRUSTLOG.NEXTVAL, '000000000'))
      INTO EG.ELBATCH
      FROM DUAL;
    --����м��ʺ���
    --    v_maaccountno := null;
    OPEN C_YSZW;
    LOOP
      FETCH C_YSZW
        INTO RL.RLID, --Ӧ����ˮ
             MI.MIID, --ˮ���
             MI.MICODE, --�ͻ�����
             MA.MABANKID, --����ID
             MA.MAACCOUNTNO, --�û������ʺ�
             MA.MAACCOUNTNAME, --�û�������
             MA.MATSBANKID,
             RL.RLJE, --Ӧ�ս��
             RL.RLZNDATE, --���ɽ�������
             RL.RLZNJ, --���ɽ�
             RL.RLMONTH, --Ӧ�����·�
             RL.RLCADR, --�û���ַ
             RL.RLMADR, --ˮ���ַ
             RL.RLCNAME --��Ȩ��
      ;
      EXIT WHEN C_YSZW%NOTFOUND OR C_YSZW%NOTFOUND IS NULL;
      EL.ETLBATCH := EG.ELBATCH; --��������
      --EL.TLSEQNO            :=  ;--������ˮ
      EL.ETLRLID        := RL.RLID; --Ӧ����ˮ
      EL.ETLMID         := MI.MIID; --ˮ����
      EL.ETLMCODE       := MI.MICODE; --���Ϻ�
      EL.ETLBANKID      := MA.MABANKID; --��������
      EL.ETLACCOUNTNO   := MA.MAACCOUNTNO; --�����ʺ�
      EL.ETLACCOUNTNAME := MA.MAACCOUNTNAME; --������
      EL.ETLZNDATE      := RL.RLZNDATE; --���ɽ�������
      --EL.ETLPIID             :=  ;--������Ŀ
      ----EL.ETLPAIDDATE         :=  ;--��������
      --EL.ETLPAIDCDATE        :=  ;--��������
      EL.ETLPAIDFLAG := 'N'; --���ʱ�־
      --EL.ETLRETURNCODE       :=  ;--������Ϣ��
      --EL.ETLRETURNMSG        :=  ;--������Ϣ
      --EL.ETLCHKDATE          :=  ;--��������
      EL.ETLSFLAG    := 'N'; --���гɹ��ۿ��־
      EL.ETLRLDATE   := RL.RLDATE; --Ӧ����������
      EL.ETLNO       := MA.MANO; --ί����Ȩ��
      EL.ETLTSBANKID := MA.MATSBANKID; --�����кţ��У�
      --EL.TLPZNO             :=  ;--ƾ֤��
      EL.ETLCIADR := RL.RLCADR; --�û���ַ
      EL.ETLMIADR := RL.RLMADR; --ˮ���ַ
      --EL.ETLBANKIDNAME       :=  ;--������������
      --EL.ETLBANKIDNO         :=  ;--��������ʵ�ʱ��
      --EL.ETLTSBANKIDNAME     :=  ;--�տ�����
      --   EL.ETLTSBANKIDNO       := ma.matsbankid ;--�տ��к�
      --EL.ETLSFJE             :=  ;--ˮ��
      --EL.ETLWSFJE            :=  ;--��ˮ��
      --EL.ETLSFZNJ            :=  ;--ˮ�����ɽ�
      --EL.ETLWSFZNJ           :=  ;--��ˮ�����ɽ�
      --EL.ETLRLIDPIID         :=  ;--Ӧ����ˮ�ӷ�����Ŀ
      --EL.ETLSL               :=  ;--ˮ��
      --EL.ETLWSL              :=  ;--��ˮ��
      --EL.ETLSFDJ             :=  ;--ˮ�ѵ���
      --EL.ETLWSFDJ            :=  ;--��ˮ�ѵ���
      EL.ETLCINAME  := RL.RLCNAME; --��Ȩ��
      EL.ETLRLMONTH := RL.RLMONTH; --Ӧ�����·�
      --EL.ETLCHRMODE          :=  ;--���ʷ�ʽ��1��δ���� ��2���ĵ����ʣ�3���ֹ�����,4:����,5:����δ�����ȫ������,6:����δ����Ĳ�������,7���з���δ����
      --EL.ETLPAIDPER          :=  ;--����Ա
      --EL.ETLTSACCOUNTNO      :=  ;--�տ��к�
      --EL.ETLTSACCOUNTNAME    :=  ;--�տ��
      --EL.ETLSZYFZNJ          :=  ;--ˮ��Դ�����ɽ�
      --EL.ETLLJFZNJ           :=  ;--������������ɽ�
      --EL.ETLSZYFSL           :=  ;--ˮ��Դˮ��
      --EL.ETLLJFSL            :=  ;--������ˮ��
      --EL.ETLSZYFDJ           :=  ;--ˮ��Դ�ѵ���
      --EL.ETLLJFDJ            :=  ;--�����ѵ���
      --EL.ETLINVSFCOUNT       :=  ;--�����ѵ���
      --EL.ETLINVWSFCOUNT      :=  ;--�����ѵ���
      --EL.ETLINVSZYFCOUNT     :=  ;--�����ѵ���
      --EL.ETLINVLJFCOUNT      :=  ;--�����ѵ���
      --EL.ETLMIUIID           :=  ;--���յ�λ���
      --EL.ETLSZYFJE           :=  ;--ˮ��Դ��
      --EL.ETLLJFJE            :=  ;--������
      EL.ETLIFINV := 0; --��Ʊ�Ƿ��Ѵ�ӡ����Ʊ����ƾ֤��
      --ÿһ����ˮӦ������һ����¼
      SELECT TRIM(TO_CHAR(SEQ_ENTRUSTLIST.NEXTVAL, '0000000000'))
        INTO EL.ETLSEQNO
        FROM DUAL;
      EL.ETLSXF         := 0; --������
      EL.ETLZNJ         := RL.RLZNJ; --Ӧ�����ɽ�
      EL.ETLJE          := RL.RLJE + RL.RLZNJ + 0; --Ӧ�ս��
      EL.ETLWSFJE       := RL.RLJE; --��ˮ��
      EL.ETLINVCOUNT    := 1; --��Ʊ����
      EL.ETLINVWSFCOUNT := 1; --�����ѵ���
      EG.ELOUTROWS      := EG.ELOUTROWS + 1; --������
      ---ÿһ���ʺ�����һ����¼
      /*if v_maaccountno is null or ( v_maaccountno is not null and v_maaccountno<>ma.maaccountname )  then
            select trim(to_char(seq_entrustlist.nextval, '0000000000'))
              into EL.ETLSEQNO
              from dual;

            EL.ETLSXF := 0; --������
            EL.ETLZNJ := rl.rlznj; --Ӧ�����ɽ�
            EL.ETLJE     := rl.rlje + rl.rlznj + 0 ; --Ӧ�ս��
            EL.ETLINVCOUNT := 1; --��Ʊ����
            eg.eloutrows  := eg.eloutrows + 1; --������
      else
            EL.ETLSXF :=EL.ETLSXF + 0; --������
            EL.ETLZNJ :=EL.ETLZNJ +  rl.rlznj; --Ӧ�����ɽ�
            EL.ETLJE  :=EL.ETLJE + rl.rlje + rl.rlznj + 0  ; --Ӧ�ս��
            EL.ETLINVCOUNT :=EL.ETLINVCOUNT + 1; --��Ʊ����

      end if;    */

      BEGIN
        INSERT INTO ENTRUSTLIST VALUES EL;
      EXCEPTION
        WHEN OTHERS THEN
          UPDATE ENTRUSTLIST T
             SET ETLSXF      = EL.ETLSXF, --������
                 ETLZNJ      = EL.ETLZNJ, --Ӧ�����ɽ�
                 ETLJE       = EL.ETLJE, --Ӧ�ս��
                 ETLWSFJE    = EL.ETLWSFJE, --��ˮ��
                 ETLINVCOUNT = EL.ETLINVCOUNT --��Ʊ����
           WHERE T.ETLBATCH = EL.ETLBATCH
             AND T.ETLSEQNO = EL.ETLSEQNO;
      END;

      --���ʣ��������κţ���ˮ�����ɽ���ڻ�������
      UPDATE RECLIST T
         SET T.RLZNJ          = RL.RLZNJ,
             T.RLOUTFLAG      = 'Y',
             T.RLENTRUSTBATCH = EL.ETLBATCH,
             T.RLENTRUSTSEQNO = EL.ETLSEQNO
       WHERE RLID = RL.RLID;

      /*--������ϸ�ͽ�
      update recdetail t set t.rdznj = 0 where rdid = rl.rlid;
      update recdetail t
         set t.rdznj = rl.rlznj
       where rdid = rl.rlid
         and rownum = 1;*/

      EG.ELOUTMONEY := EG.ELOUTMONEY + RL.RLJE; --�������

      --     v_maaccountno := ma.maaccountno  ;

    END LOOP;
    CLOSE C_YSZW;
    IF EG.ELOUTMONEY > 0 THEN
      --eg.ELBATCH          :=    ;--���մ�������
      EG.ELBANKID     := P_BANKID; --�����ĵ�����
      EG.ELCHARGETYPE := P_SFTYPE; --�շѷ�ʽ
      EG.ELOUTOER     := P_OPER; --��������Ա
      EG.ELOUTDATE    := SYSDATE; --��������
      --eg.ELOUTROWS        :=    ;--��������
      --eg.ELOUTMONEY       :=    ;--�������
      --eg.ELCHKDATE        :=    ;--��������
      EG.ELCHKROWS := 0; --����������
      EG.ELCHKJE   := 0; --�����ܽ��
      --eg.ELSCHKDATE       :=    ;--�ɹ��ļ���������
      EG.ELSROWS := 0; --���гɹ�����
      EG.ELSJE   := 0; --���гɹ����
      --eg.ELFCHKDATE       :=    ;--ʧ���ļ���������
      EG.ELFROWS := 0; --����ʧ������
      EG.ELFJE   := 0; --����ʧ�ܽ��
      --eg.ELPAIDDATE       :=    ;--������������
      EG.ELPAIDROWS := 0; --��������������
      EG.ELPAIDJE   := 0; --���������ʽ��
      EG.ELCHKNUM   := 0; --���ض��˴���
      EG.ELCHKEND   := 'N'; --���ض��˽�ֹ��־
      EG.ELSTATUS   := 'Y'; --��Ч״̬
      EG.ELSMFID    := P_MFSMFID; --
      --eg.ELTSTYPE         :=    ;--�������ͣ�1��������,2���У�
      --eg.ELPLANIMPDATE    :=    ;--�ƻ���������
      --eg.ELIMPTYPE        :=    ;--�ļ���������1��δ����2���ֹ���3���Զ�
      --eg.ELRECMONTH       :=    ;--Ӧ�����·�
      INSERT INTO ENTRUSTLOG VALUES EG;
      O_BATCH := O_BATCH || '/' || EG.ELBATCH;
      IF P_COMMIT = 'Y' THEN
        COMMIT;
      END IF;
    ELSE
      NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF C_YSZW%ISOPEN THEN
        CLOSE C_YSZW;
      END IF;
      RAISE;
  END;

  --name:sp_create_dk_batch_rlid_01
  --note:T:����
  --author:lgb
  --date��2012/09/21
  --input: P_MODEL   IN VARCHAR2 ,--���� TS ,���� LT
  -- p_bankid:���д���
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־
  --˵�������շ���һ��Ӧ��һ��һ�����շѼ�¼
  PROCEDURE SP_CREATE_TS_MAACCOUNT_03(P_MODEL   IN VARCHAR2, --���� TS ,���� LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2) IS
    EL     ENTRUSTLIST%ROWTYPE;
    EG     ENTRUSTLOG%ROWTYPE;
    MI     METERINFO%ROWTYPE;
    RL     RECLIST%ROWTYPE;
    MA     METERACCOUNT%ROWTYPE;
    V_RLID RECLIST.RLID%TYPE;
    V_MIID METERINFO.MIID%TYPE;

    /*������Ϣ*/
    CURSOR C_TSINFO IS
      SELECT RLID, MIID
        FROM METERACCOUNT T, METERINFO T1, RECLIST T
       WHERE MIID = MAMID
         AND (P_MODEL = 'TS' OR
             (P_MODEL = 'LT' AND RLID IN (SELECT C1 FROM PBPARMTEMP)))
         AND MIID = RLMID
         AND RLOUTFLAG = 'N'
         AND RLJE > 0
         AND RLCD = 'DE'
         AND RLPAIDFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
         AND T1.MIUIID IS NOT NULL
            /*     AND ((MISMFID = P_MFSMFID AND P_MFSMFID IS NOT NULL) OR
            P_MFSMFID IS NULL)*/
            --�����պ�����Ӫҵ����������
         AND MIUIID IN
             (SELECT CDMID
                FROM CUSTDWDM
               WHERE (CDMFPCODE = P_MFSMFID OR P_MFSMFID IS NULL))
         AND T1.MICHARGETYPE = P_SFTYPE
         AND T.MATSBANKID LIKE P_BANKID || '%'
         AND ((RLMONTH >= P_SMON AND P_SMON IS NOT NULL) OR P_SMON IS NULL)
         AND ((RLMONTH <= P_EMON AND P_EMON IS NOT NULL) OR P_EMON IS NULL)
         AND ((RLDATE >= TO_DATE(P_SRLDATE, 'yyyymmdd') AND
             P_SRLDATE IS NOT NULL) OR P_SRLDATE IS NULL)
         AND ((RLDATE <= TO_DATE(P_ERLDATE, 'yyyymmdd') AND
             P_ERLDATE IS NOT NULL) OR P_ERLDATE IS NULL)
       GROUP BY RLID, MIID, MAACCOUNTNO
       ORDER BY MAACCOUNTNO;

  BEGIN
    /*�������**/
    IF P_SFTYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�շѷ�ʽ���벻��Ϊ��');
    END IF;
    IF P_SFTYPE <> 'T' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�շѷ�ʽ�������');
    END IF;
    IF P_MODEL NOT IN ('TS', 'LT') OR P_MODEL IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '���շ�ʽ������,���շ�ʽֻ��Ϊ TS ���� LT');
    END IF;
    /**������־��ʼ��*/
    SELECT TRIM(TO_CHAR(SEQ_ENTRUSTLOG.NEXTVAL, '000000000'))
      INTO EG.ELBATCH
      FROM DUAL; --����
    EG.ELCHARGETYPE := P_SFTYPE;
    EG.ELBANKID     := P_BANKID;
    EG.ELOUTOER     := P_OPER; --��������Ա
    EG.ELOUTDATE    := SYSDATE; --��������
    EG.ELOUTROWS    := 0; --��������
    EG.ELOUTMONEY   := 0; --�������
    EG.ELCHKDATE    := NULL; --��������
    EG.ELCHKROWS    := 0; --����������
    EG.ELCHKJE      := 0; --�����ܽ��
    EG.ELSCHKDATE   := NULL; --�ɹ��ļ���������
    EG.ELSROWS      := 0; --���гɹ�����
    EG.ELSJE        := 0; --���гɹ����
    EG.ELFCHKDATE   := NULL; --ʧ���ļ���������
    EG.ELFROWS      := 0; --����ʧ������
    EG.ELFJE        := 0; --����ʧ�ܽ��
    EG.ELPAIDDATE   := NULL; --������������
    EG.ELPAIDROWS   := 0; --��������������
    EG.ELPAIDJE     := 0; --���������ʽ��
    EG.ELCHKNUM     := 0; --���ض��˴���
    EG.ELCHKEND     := 'N'; --���ض��˽�ֹ��־
    EG.ELSTATUS     := 'Y'; --��Ч״̬
    EG.ELSMFID      := P_MFSMFID; --
    IF P_MODEL = 'TS' THEN
      EG.ELTSTYPE := '1'; --��������
    ELSE
      EG.ELTSTYPE := '2'; --����
    END IF;
    EG.ELPLANIMPDATE := NULL; --�ƻ���������
    EG.ELIMPTYPE     := NULL; --�ļ���������1��δ����2���ֹ���3���Զ�
    EG.ELRECMONTH    := P_SMON; --Ӧ�����·�
    /***������Ϣ**/
    OPEN C_TSINFO;

    LOOP
      FETCH C_TSINFO
        INTO V_RLID, V_MIID;
      EXIT WHEN C_TSINFO%NOTFOUND OR C_TSINFO%NOTFOUND IS NULL;

      --Ӧ����Ϣ
      SELECT * INTO RL FROM RECLIST WHERE RLID = V_RLID;
      --�û���Ϣ
      SELECT * INTO MI FROM METERINFO WHERE MIID = V_MIID;
      --�û�������Ϣ
      SELECT * INTO MA FROM METERACCOUNT WHERE MAMID = V_MIID;

      --ΥԼ��
      RL.RLZNJ    := PG_EWIDE_PAY_01.GETZNJADJ(RL.RLID,
                                               RL.RLJE,
                                               RL.RLGROUP,
                                               RL.RLZNDATE,
                                               RL.RLSMFID,
                                               TRUNC(SYSDATE));
      EL.ETLBATCH := EG.ELBATCH; --��������
      SELECT TRIM(TO_CHAR(SEQ_ENTRUSTLIST.NEXTVAL, '0000000000'))
        INTO EL.ETLSEQNO
        FROM DUAL; --������ˮ
      EL.ETLRLID          := RL.RLID; --Ӧ����ˮ
      EL.ETLMID           := MI.MIID; --ˮ����
      EL.ETLMCODE         := MI.MICODE; --���Ϻ�
      EL.ETLBANKID        := MA.MABANKID; --��������
      EL.ETLACCOUNTNO     := MA.MAACCOUNTNO; --�����ʺ�
      EL.ETLACCOUNTNAME   := MA.MAACCOUNTNAME; --������
      EL.ETLZNDATE        := RL.RLZNDATE; --���ɽ�������
      EL.ETLPIID          := NULL; --������Ŀ
      EL.ETLPAIDDATE      := NULL; --��������
      EL.ETLPAIDCDATE     := NULL; --��������
      EL.ETLPAIDFLAG      := 'N'; --���ʱ�־
      EL.ETLRETURNCODE    := NULL; --������Ϣ��
      EL.ETLRETURNMSG     := NULL; --������Ϣ
      EL.ETLCHKDATE       := NULL; --��������
      EL.ETLSFLAG         := 'N'; --���гɹ��ۿ��־
      EL.ETLRLDATE        := RL.RLDATE; --Ӧ����������
      EL.ETLNO            := MA.MANO; --ί����Ȩ��
      EL.ETLTSBANKID      := MA.MATSBANKID; --�����кţ��У�
      EL.ETLPZNO          := NULL; --ƾ֤��
      EL.ETLCIADR         := RL.RLCADR; --�û���ַ
      EL.ETLMIADR         := RL.RLMADR; --ˮ���ַ
      EL.ETLBANKIDNAME    := FGETSYSMANAFRAME(MA.MABANKID); --������������
      EL.ETLBANKIDNO      := MA.MABANKID; --��������ʵ�ʱ��
      EL.ETLTSBANKIDNAME  := FGETSYSMANAFRAME(MA.MATSBANKID); --�տ�����
      EL.ETLTSBANKIDNO    := MA.MATSBANKID; --�տ��к�
      EL.ETLSFJE          := NULL; --ˮ��
      EL.ETLWSFJE         := NULL; --��ˮ��
      EL.ETLSFZNJ         := NULL; --ˮ�����ɽ�
      EL.ETLWSFZNJ        := NULL; --��ˮ�����ɽ�
      EL.ETLRLIDPIID      := NULL; --Ӧ����ˮ�ӷ�����Ŀ
      EL.ETLSL            := NULL; --ˮ��
      EL.ETLWSL           := NULL; --��ˮ��
      EL.ETLSFDJ          := NULL; --ˮ�ѵ���
      EL.ETLWSFDJ         := NULL; --��ˮ�ѵ���
      EL.ETLCINAME        := RL.RLCNAME; --��Ȩ��
      EL.ETLRLMONTH       := RL.RLMONTH; --Ӧ�����·�
      EL.ETLCHRMODE       := NULL; --���ʷ�ʽ��1��δ���� ��2���ĵ����ʣ�3���ֹ�����,4:����,5:����δ�����ȫ������,6:����δ����Ĳ�������,7���з���δ����
      EL.ETLPAIDPER       := NULL; --����Ա
      EL.ETLTSACCOUNTNO   := FGETSYSMANAPARA(MA.MATSBANKID, 'ZH'); --�տ��к�
      EL.ETLTSACCOUNTNAME := FGETSYSMANAPARA(MA.MATSBANKID, 'HM'); --�տ��
      EL.ETLSZYFZNJ       := NULL; --ˮ��Դ�����ɽ�
      EL.ETLLJFZNJ        := NULL; --������������ɽ�
      EL.ETLSZYFSL        := NULL; --ˮ��Դˮ��
      EL.ETLLJFSL         := NULL; --������ˮ��
      EL.ETLSZYFDJ        := NULL; --ˮ��Դ�ѵ���
      EL.ETLLJFDJ         := NULL; --����ѵ����      EL.ETLINVSFCOUNT    := NULL; --�����ѵ���
      EL.ETLINVWSFCOUNT   := NULL; --�����ѵ���
      EL.ETLINVSZYFCOUNT  := NULL; --�����ѵ���
      EL.ETLINVLJFCOUNT   := NULL; --�����ѵ���
      EL.ETLMIUIID        := MI.MIUIID; --���յ�λ���
      EL.ETLSZYFJE        := NULL; --ˮ��Դ��
      EL.ETLLJFJE         := NULL; --������
      EL.ETLIFINV         := 0; --��Ʊ�Ƿ��Ѵ�ӡ����Ʊ����ƾ֤��
      EL.ETLIFINVPZ       := 0; --ƾ֤�Ƿ��Ѿ���ӡ
      EL.ETLSXF           := NULL; --������
      EL.ETLZNJ           := RL.RLZNJ; --Ӧ�����ɽ�
      EL.ETLJE            := RL.RLJE + RL.RLZNJ + 0; --Ӧ�ս��
      EL.ETLWSFJE         := NULL; --��ˮ��
      EL.ETLINVCOUNT      := 1; --��Ʊ����
      EL.ETLINVWSFCOUNT   := NULL; --�����ѵ���
      EG.ELOUTROWS        := EG.ELOUTROWS + 1; --������
      EG.ELOUTMONEY       := EG.ELOUTMONEY + EL.ETLJE;
      INSERT INTO ENTRUSTLIST VALUES EL;
      /**����Ӧ����Ϣ**/
      UPDATE RECLIST T
         SET T.RLZNJ          = RL.RLZNJ,
             T.RLOUTFLAG      = 'Y',
             T.RLENTRUSTBATCH = EL.ETLBATCH,
             T.RLENTRUSTSEQNO = EL.ETLSEQNO
       WHERE RLID = RL.RLID;
    END LOOP;
    IF C_TSINFO%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '����û����Ҫ���������û���Ϣ');
    END IF;
    IF EG.ELOUTMONEY = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�������Ϊ0');
    END IF;
    /*������־*/
    INSERT INTO ENTRUSTLOG VALUES EG;

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF C_TSINFO%ISOPEN THEN
        CLOSE C_TSINFO;
      END IF;
      RAISE;
  END;
  PROCEDURE SP_CREATE_TS_MAACCOUNT_04(P_MODEL   IN VARCHAR2, --���� TS ,���� LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      P_STSH    IN VARCHAR2,
                                      P_ETSH    IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2) IS
    EL     ENTRUSTLIST%ROWTYPE;
    EG     ENTRUSTLOG%ROWTYPE;
    MI     METERINFO%ROWTYPE;
    RL     RECLIST%ROWTYPE;
    MA     METERACCOUNT%ROWTYPE;
    V_RLID RECLIST.RLID%TYPE;
    V_MIID METERINFO.MIID%TYPE;

    /*������Ϣ*/
    CURSOR C_TSINFO IS
      SELECT RLID, MIID
        FROM METERACCOUNT T, METERINFO T1, RECLIST T
       WHERE MIID = MAMID
         AND (P_MODEL = 'TS' OR
             (P_MODEL = 'LT' AND RLID IN (SELECT C1 FROM PBPARMTEMP)))
         AND MIID = RLMID
         AND RLOUTFLAG = 'N'
         AND RLJE > 0
         AND RLCD = 'DE'
         AND RLPAIDFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
         AND T1.MIUIID IS NOT NULL
            /*     AND ((MISMFID = P_MFSMFID AND P_MFSMFID IS NOT NULL) OR
            P_MFSMFID IS NULL)*/
            --�����պ�����Ӫҵ����������

         AND MIUIID IN
             (SELECT CDMID
                FROM CUSTDWDM
               WHERE (CDMFPCODE = P_MFSMFID OR P_MFSMFID IS NULL))
         AND (TO_NUMBER(MIUIID) >= TO_NUMBER(P_STSH) OR P_STSH IS NULL)
         AND (TO_NUMBER(MIUIID) <= TO_NUMBER(P_ETSH) OR P_ETSH IS NULL)
         AND T1.MICHARGETYPE = P_SFTYPE
         AND T.MATSBANKID LIKE P_BANKID || '%'
         AND ((RLMONTH >= P_SMON AND P_SMON IS NOT NULL) OR P_SMON IS NULL)
         AND ((RLMONTH <= P_EMON AND P_EMON IS NOT NULL) OR P_EMON IS NULL)
         AND ((RLDATE >= TO_DATE(P_SRLDATE, 'yyyymmdd') AND
             P_SRLDATE IS NOT NULL) OR P_SRLDATE IS NULL)
         AND ((RLDATE <= TO_DATE(P_ERLDATE, 'yyyymmdd') AND
             P_ERLDATE IS NOT NULL) OR P_ERLDATE IS NULL)
       GROUP BY RLID, MIID, MAACCOUNTNO
       ORDER BY MAACCOUNTNO;

  BEGIN
    /*�������**/
    IF P_SFTYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�շѷ�ʽ���벻��Ϊ��');
    END IF;
    IF P_SFTYPE <> 'T' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�շѷ�ʽ�������');
    END IF;
    IF P_MODEL NOT IN ('TS', 'LT') OR P_MODEL IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '���շ�ʽ������,���շ�ʽֻ��Ϊ TS ���� LT');
    END IF;
    /**������־��ʼ��*/
    SELECT TRIM(TO_CHAR(SEQ_ENTRUSTLOG.NEXTVAL, '000000000'))
      INTO EG.ELBATCH
      FROM DUAL; --����
    EG.ELCHARGETYPE := P_SFTYPE;
    EG.ELBANKID     := P_BANKID;
    EG.ELOUTOER     := P_OPER; --��������Ա
    EG.ELOUTDATE    := SYSDATE; --��������
    EG.ELOUTROWS    := 0; --��������
    EG.ELOUTMONEY   := 0; --�������
    EG.ELCHKDATE    := NULL; --��������
    EG.ELCHKROWS    := 0; --����������
    EG.ELCHKJE      := 0; --�����ܽ��
    EG.ELSCHKDATE   := NULL; --�ɹ��ļ���������
    EG.ELSROWS      := 0; --���гɹ�����
    EG.ELSJE        := 0; --���гɹ����
    EG.ELFCHKDATE   := NULL; --ʧ���ļ���������
    EG.ELFROWS      := 0; --����ʧ������
    EG.ELFJE        := 0; --����ʧ�ܽ��
    EG.ELPAIDDATE   := NULL; --������������
    EG.ELPAIDROWS   := 0; --��������������
    EG.ELPAIDJE     := 0; --���������ʽ��
    EG.ELCHKNUM     := 0; --���ض��˴���
    EG.ELCHKEND     := 'N'; --���ض��˽�ֹ��־
    EG.ELSTATUS     := 'Y'; --��Ч״̬
    EG.ELSMFID      := P_MFSMFID; --
    IF P_MODEL = 'TS' THEN
      EG.ELTSTYPE := '1'; --��������
    ELSE
      EG.ELTSTYPE := '2'; --����
    END IF;
    EG.ELPLANIMPDATE := NULL; --�ƻ���������
    EG.ELIMPTYPE     := NULL; --�ļ���������1��δ����2���ֹ���3���Զ�
    EG.ELRECMONTH    := P_SMON; --Ӧ�����·�
    /***������Ϣ**/
    OPEN C_TSINFO;

    LOOP
      FETCH C_TSINFO
        INTO V_RLID, V_MIID;
      EXIT WHEN C_TSINFO%NOTFOUND OR C_TSINFO%NOTFOUND IS NULL;

      --Ӧ����Ϣ
      SELECT * INTO RL FROM RECLIST WHERE RLID = V_RLID;
      --�û���Ϣ
      SELECT * INTO MI FROM METERINFO WHERE MIID = V_MIID;
      --�û�������Ϣ
      SELECT * INTO MA FROM METERACCOUNT WHERE MAMID = V_MIID;

      --ΥԼ��
      RL.RLZNJ    := PG_EWIDE_PAY_01.GETZNJADJ(RL.RLID,
                                               RL.RLJE,
                                               RL.RLGROUP,
                                               RL.RLZNDATE,
                                               RL.RLSMFID,
                                               TRUNC(SYSDATE));
      EL.ETLBATCH := EG.ELBATCH; --��������
      SELECT TRIM(TO_CHAR(SEQ_ENTRUSTLIST.NEXTVAL, '0000000000'))
        INTO EL.ETLSEQNO
        FROM DUAL; --������ˮ
      EL.ETLRLID          := RL.RLID; --Ӧ����ˮ
      EL.ETLMID           := MI.MIID; --ˮ����
      EL.ETLMCODE         := MI.MICODE; --���Ϻ�
      EL.ETLBANKID        := MA.MABANKID; --��������
      EL.ETLACCOUNTNO     := MA.MAACCOUNTNO; --�����ʺ�
      EL.ETLACCOUNTNAME   := MA.MAACCOUNTNAME; --������
      EL.ETLZNDATE        := RL.RLZNDATE; --���ɽ�������
      EL.ETLPIID          := NULL; --������Ŀ
      EL.ETLPAIDDATE      := NULL; --��������
      EL.ETLPAIDCDATE     := NULL; --��������
      EL.ETLPAIDFLAG      := 'N'; --���ʱ�־
      EL.ETLRETURNCODE    := NULL; --������Ϣ��
      EL.ETLRETURNMSG     := NULL; --������Ϣ
      EL.ETLCHKDATE       := NULL; --��������
      EL.ETLSFLAG         := 'N'; --���гɹ��ۿ��־
      EL.ETLRLDATE        := RL.RLDATE; --Ӧ����������
      EL.ETLNO            := MA.MANO; --ί����Ȩ��
      EL.ETLTSBANKID      := MA.MATSBANKID; --�����кţ��У�
      EL.ETLPZNO          := NULL; --ƾ֤��
      EL.ETLCIADR         := RL.RLCADR; --�û���ַ
      EL.ETLMIADR         := RL.RLMADR; --ˮ���ַ
      EL.ETLBANKIDNAME    := FGETSYSMANAFRAME(MA.MABANKID); --������������
      EL.ETLBANKIDNO      := MA.MABANKID; --��������ʵ�ʱ��
      EL.ETLTSBANKIDNAME  := FGETSYSMANAFRAME(MA.MATSBANKID); --�տ�����
      EL.ETLTSBANKIDNO    := MA.MATSBANKID; --�տ��к�
      EL.ETLSFJE          := NULL; --ˮ��
      EL.ETLWSFJE         := NULL; --��ˮ��
      EL.ETLSFZNJ         := NULL; --ˮ�����ɽ�
      EL.ETLWSFZNJ        := NULL; --��ˮ�����ɽ�
      EL.ETLRLIDPIID      := NULL; --Ӧ����ˮ�ӷ�����Ŀ
      EL.ETLSL            := NULL; --ˮ��
      EL.ETLWSL           := NULL; --��ˮ��
      EL.ETLSFDJ          := NULL; --ˮ�ѵ���
      EL.ETLWSFDJ         := NULL; --��ˮ�ѵ���
      EL.ETLCINAME        := RL.RLCNAME; --��Ȩ��
      EL.ETLRLMONTH       := RL.RLMONTH; --Ӧ�����·�
      EL.ETLCHRMODE       := NULL; --���ʷ�ʽ��1��δ���� ��2���ĵ����ʣ�3���ֹ�����,4:����,5:����δ�����ȫ������,6:����δ����Ĳ�������,7���з���δ����
      EL.ETLPAIDPER       := NULL; --����Ա
      EL.ETLTSACCOUNTNO   := FGETSYSMANAPARA(MA.MATSBANKID, 'ZH'); --�տ��к�
      EL.ETLTSACCOUNTNAME := FGETSYSMANAPARA(MA.MATSBANKID, 'HM'); --�տ��
      EL.ETLSZYFZNJ       := NULL; --ˮ��Դ�����ɽ�
      EL.ETLLJFZNJ        := NULL; --������������ɽ�
      EL.ETLSZYFSL        := NULL; --ˮ��Դˮ��
      EL.ETLLJFSL         := NULL; --������ˮ��
      EL.ETLSZYFDJ        := NULL; --ˮ��Դ�ѵ���
      EL.ETLLJFDJ         := NULL; --�����ѵ���
      EL.ETLINVSFCOUNT    := NULL; --�����ѵ���
      EL.ETLINVWSFCOUNT   := NULL; --�����ѵ���
      EL.ETLINVSZYFCOUNT  := NULL; --�����ѵ���
      EL.ETLINVLJFCOUNT   := NULL; --�����ѵ���
      EL.ETLMIUIID        := MI.MIUIID; --���յ�λ���
      EL.ETLSZYFJE        := NULL; --ˮ��Դ��
      EL.ETLLJFJE         := NULL; --������
      EL.ETLIFINV         := 0; --��Ʊ�Ƿ��Ѵ�ӡ����Ʊ����ƾ֤��
      EL.ETLIFINVPZ       := 0; --ƾ֤�Ƿ��Ѿ���ӡ
      EL.ETLSXF           := NULL; --������
      EL.ETLZNJ           := RL.RLZNJ; --Ӧ�����ɽ�
      EL.ETLJE            := RL.RLJE + RL.RLZNJ + 0; --Ӧ�ս��
      EL.ETLWSFJE         := NULL; --��ˮ��
      EL.ETLINVCOUNT      := 1; --��Ʊ����
      EL.ETLINVWSFCOUNT   := NULL; --�����ѵ���
      EG.ELOUTROWS        := EG.ELOUTROWS + 1; --������
      EG.ELOUTMONEY       := EG.ELOUTMONEY + EL.ETLJE;
      INSERT INTO ENTRUSTLIST VALUES EL;
      /**����Ӧ����Ϣ**/
      UPDATE RECLIST T
         SET T.RLZNJ          = RL.RLZNJ,
             T.RLOUTFLAG      = 'Y',
             T.RLENTRUSTBATCH = EL.ETLBATCH,
             T.RLENTRUSTSEQNO = EL.ETLSEQNO
       WHERE RLID = RL.RLID;
    END LOOP;
    IF C_TSINFO%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '����û����Ҫ���������û���Ϣ');
    END IF;
    IF EG.ELOUTMONEY = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�������Ϊ0');
    END IF;
    /*������־*/
    INSERT INTO ENTRUSTLOG VALUES EG;

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF C_TSINFO%ISOPEN THEN
        CLOSE C_TSINFO;
      END IF;
      RAISE;
  END;
  ---------------------------------------------------------------------------
  --                        ����������������
  --name:sp_cancle_ts_batch
  --note:����������������
  --author:wy
  --date��2009/04/26
  --input: p_entrust_batch �������κ�
  --p_oper in varchar2,--����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  PROCEDURE SP_CANCLE_TS_BATCH_01(P_ENTRUST_BATCH IN VARCHAR2,
                                  P_OPER          IN VARCHAR2, --����Ա
                                  P_COMMIT        IN VARCHAR2) IS

    V_TS_LOG ENTRUSTLOG%ROWTYPE; --������־
    V_TEST   VARCHAR2(10);
  BEGIN
    IF P_ENTRUST_BATCH IS NULL THEN
      V_TEST := '000';
    END IF;
    BEGIN
      SELECT *
        INTO V_TS_LOG
        FROM ENTRUSTLOG
       WHERE ELBATCH = P_ENTRUST_BATCH;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���κ�[' || P_ENTRUST_BATCH || ']������,����!');
    END;
    --�������
    IF V_TS_LOG.ELSTATUS = 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '���κ�[' || P_ENTRUST_BATCH || ']������,�����ٴ�����!');
    END IF;
    IF V_TS_LOG.ELCHKNUM > 0 OR V_TS_LOG.ELCHKEND = 'Y' THEN
      SP_CANCLE_TS_IMP_01(P_ENTRUST_BATCH, 'N');
      --RAISE_application_error(errcode, '����������[' || p_entrust_batch || ']�Ѿ����룬���ܳ�����');
    END IF;
    /* --���Ӧ���˷�����ˮ,���κ�,������־
    update recdetail set rdznj=0
    where rdid in (
    select rlid from reclist WHERE RLENTRUSTBATCH = p_entrust_batch
    )
    and rdpaidflag='N' ;*/

    UPDATE RECLIST
       SET RLENTRUSTBATCH = NULL,
           RLENTRUSTSEQNO = NULL,
           RLOUTFLAG      = 'N',
           RLZNJ          = 0
     WHERE RLENTRUSTBATCH = P_ENTRUST_BATCH;
    --�������շ�����־��Ч��־
    UPDATE ENTRUSTLOG SET ELSTATUS = 'N' WHERE ELBATCH = P_ENTRUST_BATCH;

    ---������־��
    INSERT INTO ELDELBAK
      SELECT P_OPER, SYSDATE, T.*
        FROM ENTRUSTLOG T
       WHERE ELBATCH = P_ENTRUST_BATCH;

    ---������־��
    INSERT INTO ETLDELBAK
      SELECT P_OPER, SYSDATE, T.*
        FROM ENTRUSTLIST T
       WHERE ETLBATCH = P_ENTRUST_BATCH;

    --ɾ��
    DELETE ENTRUSTLOG WHERE ELBATCH = P_ENTRUST_BATCH;
    --ɾ�����յ��м��
    DELETE ENTRUSTLIST WHERE ETLBATCH = P_ENTRUST_BATCH;

    --�ύ
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    --������
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  ---------------------------------------------------------------------------
  --                        ����������������
  --name:sp_cancle_ts_entpzseqno_01
  --note:����������������
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_ts_entpzseqno_01 �������κ�
  -- p_enterst_pzseqno  in varchar2, ��ˮ��
  -- p_oper in varchar2,--����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  PROCEDURE SP_CANCLE_TS_ENTPZSEQNO_01(P_ENTRUST_BATCH   IN VARCHAR2,
                                       P_ENTERST_PZSEQNO IN VARCHAR2,
                                       P_OPER            IN VARCHAR2, --����Ա
                                       P_COMMIT          IN VARCHAR2) IS

    V_TS_LOG  ENTRUSTLOG%ROWTYPE; --������־
    V_TS_LIST ENTRUSTLIST%ROWTYPE; --����ƾ֤
    --v_rl      reclist%rowtype; --Ӧ��
    --v_rd      recdetail%rowtype;--Ӧ����ϸ
    V_JE   NUMBER(12, 2);
    V_TEST VARCHAR2(10);
  BEGIN
    IF P_ENTRUST_BATCH IS NULL THEN
      V_TEST := '000';
    END IF;
    BEGIN
      SELECT *
        INTO V_TS_LOG
        FROM ENTRUSTLOG
       WHERE ELBATCH = P_ENTRUST_BATCH;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���κ�[' || P_ENTRUST_BATCH || ']������,����!');
    END;
    BEGIN
      SELECT *
        INTO V_TS_LIST
        FROM ENTRUSTLIST
       WHERE ETLBATCH = P_ENTRUST_BATCH
         AND ETLSEQNO = P_ENTERST_PZSEQNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���κ�[' || P_ENTRUST_BATCH || '��������ˮ' ||
                                P_ENTERST_PZSEQNO || ']������,����!');
    END;
    IF V_TS_LIST.ETLPAIDFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '�û�[' || V_TS_LIST.ETLMCODE || ']�����ˣ���������!');
    END IF;

    --�������
    IF V_TS_LOG.ELSTATUS = 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '���κ�[' || P_ENTRUST_BATCH || ']������,�����ٴ�����!');
    END IF;
    IF V_TS_LOG.ELCHKNUM > 0 OR V_TS_LOG.ELCHKEND = 'Y' THEN
      NULL;
      --sp_cancle_ts_imp_01(p_entrust_batch, 'N');
      --RAISE_application_error(errcode, '����������[' || p_entrust_batch || ']�Ѿ����룬���ܳ�����');
    END IF;
    /*--���Ӧ���˷�����ˮ,���κ�,������־
    update recdetail set rdznj=0
    where rdid in (
    select rlid from reclist WHERE RLENTRUSTBATCH = p_entrust_batch and  RLENTRUSTSEQNO = p_enterst_pzseqno
    )
    and rdpaidflag='N' ;*/

    UPDATE RECLIST
       SET RLENTRUSTBATCH = NULL,
           RLENTRUSTSEQNO = NULL,
           RLOUTFLAG      = 'N',
           RLZNJ          = 0
     WHERE RLENTRUSTBATCH = P_ENTRUST_BATCH
       AND RLENTRUSTSEQNO = P_ENTERST_PZSEQNO;
    --�������շ�����־
    SELECT ETLJE
      INTO V_JE
      FROM ENTRUSTLIST
     WHERE ETLBATCH = P_ENTRUST_BATCH
       AND ETLSEQNO = P_ENTERST_PZSEQNO;

    ---������־��
    INSERT INTO ETLDELBAK
      SELECT P_OPER, SYSDATE, T.*
        FROM ENTRUSTLIST T
       WHERE ETLBATCH = P_ENTRUST_BATCH
         AND ETLSEQNO = P_ENTERST_PZSEQNO;
    --ɾ�����յ�
    DELETE ENTRUSTLIST
     WHERE ETLBATCH = P_ENTRUST_BATCH
       AND ETLSEQNO = P_ENTERST_PZSEQNO;

    UPDATE ENTRUSTLOG
       SET (ELOUTROWS, --��������
            ELOUTMONEY, --�������
            ELCHKROWS, --����������
            ELCHKJE, --�����ܽ��
            ELSROWS, --���гɹ�����
            ELSJE, --���гɹ����
            ELFROWS, --����ʧ������
            ELFJE, --����ʧ�ܽ��
            ELPAIDROWS, --��������������
            ELPAIDJE) --���������˽��
            =
           (SELECT COUNT(*),
                   SUM(ETLJE),
                   SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                   SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                   SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                   SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                   SUM(DECODE(ETLSFLAG, 'N', 1, 0)),
                   SUM(DECODE(ETLSFLAG, 'N', ETLJE, 0)),
                   SUM(DECODE(EL.ETLPAIDFLAG, 'Y', 1, 0)),
                   SUM(DECODE(ETLPAIDFLAG, 'Y', ETLJE, 0))
              FROM ENTRUSTLIST EL
             WHERE EL.ETLBATCH = P_ENTRUST_BATCH)
     WHERE ELBATCH = P_ENTRUST_BATCH;

    --�ύ
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    --������
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;
  --����δ����
  PROCEDURE SP_CANCLE_TS_WXZ_01(P_BATCH IN VARCHAR2, P_OPER IN VARCHAR2) IS
    CURSOR C_ENTRUSTLIST(VID VARCHAR2) IS
      SELECT *
        FROM ENTRUSTLIST
       WHERE ETLBATCH = VID
         AND ETLPAIDFLAG = 'N';
    V_ENTRUSTLIST ENTRUSTLIST%ROWTYPE;
  BEGIN
    OPEN C_ENTRUSTLIST(P_BATCH);
    LOOP
      FETCH C_ENTRUSTLIST
        INTO V_ENTRUSTLIST;
      EXIT WHEN C_ENTRUSTLIST%NOTFOUND OR C_ENTRUSTLIST%NOTFOUND IS NULL;
      PG_EWIDE_TS_01.SP_CANCLE_TS_ENTPZSEQNO_01(V_ENTRUSTLIST.ETLBATCH,
                                                V_ENTRUSTLIST.ETLSEQNO,
                                                P_OPER,
                                                'N');
    END LOOP;
    IF C_ENTRUSTLIST%ISOPEN THEN
      CLOSE C_ENTRUSTLIST;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_ENTRUSTLIST%ISOPEN THEN
        CLOSE C_ENTRUSTLIST;
      END IF;
      ROLLBACK;
      RAISE;
  END;

  ---------------------------------------------------------------------------
  --                        �������յ���
  --name:sp_cancle_ts_imp_01
  --note:�������յ���
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_ts_imp_01 �������յ���
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  PROCEDURE SP_CANCLE_TS_IMP_01(P_ENTRUST_BATCH IN VARCHAR2,
                                P_COMMIT        IN VARCHAR2) IS

    V_TS_LOG ENTRUSTLOG%ROWTYPE; --������־
    V_TEST   VARCHAR2(10);
    V_EXIT   NUMBER(10);
  BEGIN
    IF P_ENTRUST_BATCH IS NULL THEN
      V_TEST := '000';
    END IF;
    BEGIN
      SELECT *
        INTO V_TS_LOG
        FROM ENTRUSTLOG
       WHERE ELBATCH = P_ENTRUST_BATCH
         AND ELCHARGETYPE = 'T';
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '�������κ�[' || P_ENTRUST_BATCH || ']������,����!');
    END;
    --�������
    IF V_TS_LOG.ELSTATUS = 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '�������κ�[' || P_ENTRUST_BATCH ||
                              ']������,����Ҫȡ������!');
    END IF;
    IF V_TS_LOG.ELPAIDDATE IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '�������κ�[' || P_ENTRUST_BATCH ||
                              ']�Ѿ����ʴ���[�������ڲ�Ϊ��]������ȡ������!');
    END IF;
    IF V_TS_LOG.ELPAIDROWS > 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '�������κ�[' || P_ENTRUST_BATCH ||
                              ']�Ѿ����ʴ���[���ʼ�¼��������0]������ȡ������!');
    END IF;
    IF V_TS_LOG.ELCHKNUM < 1 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '�����մ�������[' || P_ENTRUST_BATCH ||
                              ']û�е��룬����Ҫȡ�����룡');
    END IF;
    SELECT COUNT(*)
      INTO V_EXIT
      FROM ENTRUSTLIST
     WHERE ETLPAIDFLAG = 'Y'
       AND ETLBATCH = P_ENTRUST_BATCH;
    IF V_EXIT > 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '�������κ�[' || P_ENTRUST_BATCH ||
                              ']�Ѿ����ʴ�������ȡ������!');
    END IF;
    --���´��۷�����־��Ч��־
    UPDATE ENTRUSTLOG
       SET ELCHKEND   = 'N',
           ELCHKNUM   = 0,
           ELPAIDJE   = 0,
           ELPAIDROWS = 0,
           ELPAIDDATE = NULL,
           ELFJE      = 0,
           ELFROWS    = 0,
           ELFCHKDATE = NULL,
           ELSJE      = 0,
           ELSROWS    = 0,
           ELSCHKDATE = NULL,
           ELCHKJE    = 0,
           ELCHKROWS  = 0,
           ELCHKDATE  = NULL
     WHERE ELBATCH = P_ENTRUST_BATCH
       AND ELCHARGETYPE = 'T';
    UPDATE ENTRUSTLIST
       SET ETLRETURNCODE = NULL,
           ETLRETURNMSG  = NULL,
           ETLCHKDATE    = NULL,
           ETLSFLAG      = 'N'
     WHERE ETLBATCH = P_ENTRUST_BATCH;
    --�ύ
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    --������
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  --���������ļ�������
  ---------------------------------------------------------------------------
  --                        ���������ļ�������
  --name:fgettsexpname
  --note:���������ļ�������
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --       p_batch �������κ�
  --return TSDS(4λ)+���б��(6λ)+����(8λ)+���κ�+(10λ)
  -- ��:DK03001200904280000000001
  ---------------------------------------------------------------------------
  FUNCTION FGETTSEXPNAME(P_TYPE   IN VARCHAR2,
                         P_BANKID IN VARCHAR2,
                         P_BATCH  IN VARCHAR2) RETURN VARCHAR2 IS
    V_RET VARCHAR2(100);
    ETLOG ENTRUSTLOG%ROWTYPE;
  BEGIN
    --���������ļ��� ��ʽ��TSDS(4λ)+���б��(6λ)+����(8λ)+���κ�+(10λ)
    -- ��:TS031200904280000000001
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;
    IF P_BATCH IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;
    BEGIN
      SELECT * INTO ETLOG FROM ENTRUSTLOG WHERE ELBATCH = P_BATCH;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�������β�����!');
    END;
    IF P_TYPE = '01' THEN

      V_RET := FPARA(P_BANKID, 'TSEXPNAME') ||
               TO_CHAR(ETLOG.ELOUTDATE, 'yymmdd');

    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;

  --ȡ���յ������ļ�����
  ---------------------------------------------------------------------------
  --                        ȡ���յ������ļ�����
  --name:fgettsexpfiletype
  --note:ȡ���յ������ļ�����
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPFILETYPE(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;

    IF P_TYPE = '01' THEN

      V_RETSQL := FPARA(P_BANKID, 'TSEXPTYPE');

    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;

  FUNCTION FGETTSEXPFILEPATH(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;

    IF P_TYPE = '01' THEN
      V_RETSQL := FPARA(P_BANKID, 'TSLPATH');
    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;
  FUNCTION FGETTSEXPFILEGS(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;

    IF P_TYPE = '01' THEN

      V_RETSQL := FPARA(P_BANKID, 'TSEXP');

    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;
  FUNCTION FGETTSEXPFILEHZ(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;

    IF P_TYPE = '01' THEN

      V_RETSQL := FPARA(P_BANKID, 'TSFILETAIL');

    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;
  --ȡ���յ�����ļ�����
  ---------------------------------------------------------------------------
  --                        ȡ���յ�����ļ�����
  --name:fgettsimpfiletype
  --note:ȡ���յ������ļ�����
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSIMPFILETYPE(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;

    IF P_TYPE = '01' THEN

      V_RETSQL := FPARA(P_BANKID, 'TSIMPTYPE');

    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;

  --ȡ���յ����ʽ�ַ���
  ---------------------------------------------------------------------------
  --                        ȡ���յ����ʽ�ַ���
  --name:fgettsimpsqlstr
  --note:ȡ���յ����ʽ�ַ���
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------
  FUNCTION FGETTSIMPSQLSTR(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;
    IF P_TYPE = '01' THEN

      V_RETSQL := FPARA(P_BANKID, 'TSIMP');

    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;

  --ȡ���յ�����ʽ�ַ���
  ---------------------------------------------------------------------------
  --                        ȡ���յ�����ʽ�ַ���
  --name:fgetdkexpsqlstr
  --note:ȡ���յ�����ʽ�ַ���
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPSQLSTR(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,��ϵͳ����Ա���!');
    END IF;

    IF P_TYPE = '01' THEN
      V_RETSQL := FPARA(P_BANKID, 'TSEXP');
    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;

  --�������ݵ������
  ---------------------------------------------------------------------------
  --                        �������ݵ������
  --name:sq_dkfileimp
  --note:�������ݵ������
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  ---------------------------------------------------------------------------
  PROCEDURE SQ_TSFILEIMP_BAK(P_BATCH    IN VARCHAR2,
                             P_COUNT    IN NUMBER,
                             P_LASTTIME IN VARCHAR2) IS
    ETSL     ENTRUSTLIST%ROWTYPE;
    ETSLTEMP ENTRUSTLIST%ROWTYPE;
    ETRG     ENTRUSTLOG%ROWTYPE;
    TYPE CUR IS REF CURSOR;
    C_IMP CUR;
    CURSOR C_ENTRUSLIST(BATCH VARCHAR2) IS
      SELECT *
        FROM ENTRUSTLIST
       WHERE ETLBATCH = BATCH
         AND ETLSFLAG = 'N'
         AND ETLPAIDFLAG = 'N';
    V_SQL            VARCHAR2(10000);
    V_SQLIMPCUR      VARCHAR2(10000);
    V_MULTIFILE      VARCHAR2(1);
    V_MULTIIMP       VARCHAR2(1);
    V_MULTISUCCCOUNT NUMBER(10);
    V_ALLCOUNT       NUMBER(10);
  BEGIN
    /*    v_multifile := fsyspara('0045');
    v_multiimp  := fsyspara('0046');*/
    /*    if v_multifile is null or v_multifile not in ('Y', 'N') THEN
      raise_application_error(errcode, '�����Ƿ���ļ����˱�־���ô���!');
    END IF;*/
    /*    if v_multiimp is null or v_multiimp not in ('Y', 'N') THEN
      raise_application_error(errcode, '�����Ƿ��ζ��˱�־���ô���!');
    END IF;*/
    BEGIN
      SELECT * INTO ETRG FROM ENTRUSTLOG T WHERE T.ELBATCH = P_BATCH;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�������β�����!');
    END;
    IF ETRG.ELCHKEND = 'Y' THEN
      SP_CANCLE_TS_IMP_01(P_BATCH, 'N');
    END IF;
    V_SQL := TRIM(FGETTSIMPSQLSTR('01', ETRG.ELBANKID));
    IF V_SQL IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���յ����ʽδ����!');
    END IF;
    OPEN C_ENTRUSLIST(P_BATCH);
    FETCH C_ENTRUSLIST
      INTO ETSL;
    IF C_ENTRUSLIST%NOTFOUND OR C_ENTRUSLIST%NOTFOUND IS NULL THEN
      CLOSE C_ENTRUSLIST;
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��������[' || P_BATCH || ']�Ѿ�ȫ������!');
    END IF;
    IF C_ENTRUSLIST%ISOPEN THEN
      CLOSE C_ENTRUSLIST;
    END IF;

    OPEN C_ENTRUSLIST(P_BATCH);
    LOOP
      FETCH C_ENTRUSLIST
        INTO ETSL;
      EXIT WHEN C_ENTRUSLIST%NOTFOUND OR C_ENTRUSLIST%NOTFOUND IS NULL;

      V_SQLIMPCUR := REPLACE(V_SQL, '@PARM1', '''' || ETSL.ETLSEQNO || '''');
      OPEN C_IMP FOR V_SQLIMPCUR;
      FETCH C_IMP
        INTO ETSLTEMP;
      IF C_IMP%ROWCOUNT > 1 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '������ˮ[' || ETSLTEMP.ETLSEQNO || ']�ظ�!');
      END IF;
      IF C_IMP%FOUND THEN
        --������
        IF TRIM(ETSL.ETLSEQNO) <> TRIM(ETSLTEMP.ETLSEQNO) THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  'ϵͳ��ˮ��[' || ETSL.ETLSEQNO || ']' ||
                                  'ʵ��ϵͳ��ˮ��[' || ETSL.ETLSEQNO || ']' || '��[' ||
                                  ETSLTEMP.ETLSEQNO || ']' ||
                                  '�����ļ��뵼������ĵ��Ĳ�һ��!');
        END IF;
        IF TRIM(ETSL.ETLBANKIDNO) <> TRIM(ETSLTEMP.ETLBANKIDNO) THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '���Ϻ�[' || ETSL.ETLMCODE || ']' ||
                                  '��������ʵ�ʱ��[' || ETSL.ETLBANKIDNO || ']' || '��[' ||
                                  ETSLTEMP.ETLBANKIDNO || ']' ||
                                  '�����ļ��뵼������ĵ��Ĳ�һ��!');
        END IF;
        IF TRIM(ETSL.ETLACCOUNTNAME) <> TRIM(ETSLTEMP.ETLACCOUNTNAME) THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '���Ϻ�[' || ETSL.ETLMCODE || ']' || '������[' ||
                                  ETSL.ETLACCOUNTNAME || ']' || '��[' ||
                                  ETSLTEMP.ETLACCOUNTNAME || ']' ||
                                  '�����ļ��뵼������ĵ��Ĳ�һ��!');
        END IF;
        IF ETSL.ETLJE <> ETSLTEMP.ETLJE THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '���Ϻ�[' || ETSL.ETLMCODE || ']' || '�ۿ���[' ||
                                  ETSL.ETLJE || ']' || '��[' ||
                                  ETSLTEMP.ETLJE || ']' ||
                                  '�����ļ��뵼������ĵ��Ĳ�һ��!');
        END IF;
        IF ETSLTEMP.ETLSFLAG NOT IN ('Y', 'N') THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '���з��ؿۿ�ɹ���־����!');
        END IF;

        --�ۿ���Ϣ
        UPDATE ENTRUSTLIST
           SET ETLSFLAG      = ETSLTEMP.ETLSFLAG,
               ETLCHKDATE    = SYSDATE,
               ETLRETURNCODE = ETSLTEMP.ETLRETURNCODE,
               ETLRETURNMSG  = ETSLTEMP.ETLRETURNMSG,
               ETLCHRMODE    = ETSLTEMP.ETLCHRMODE
         WHERE ETLBATCH = ETSL.ETLBATCH
           AND ETLSEQNO = ETSL.ETLSEQNO;
      END IF;
      IF C_IMP%ISOPEN THEN
        CLOSE C_IMP;
      END IF;
    END LOOP;
    V_ALLCOUNT := C_ENTRUSLIST%ROWCOUNT;
    IF C_IMP%ISOPEN THEN
      CLOSE C_ENTRUSLIST;
    END IF;
    IF C_ENTRUSLIST%ISOPEN THEN
      CLOSE C_ENTRUSLIST;
    END IF;
    IF V_MULTISUCCCOUNT >= V_ALLCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����ļ��쳣!');
    END IF;
    --��������ͷ
    BEGIN
      /*
      update entrustlog
         set elchkdate  = sysdate,
             elchkrows  = (case when v_multiimp = 'N' OR (v_multiimp = 'Y' and p_lasttime = 'Y') then etrg.eloutrows else (select count(*)
                                                                                                     from entrustlist
                                                                                                    where etlbatch =
                                                                                                          p_batch
                                                                                                      and etlsflag = 'Y') end), --��������
             eloutmoney = (case when v_multiimp = 'N' OR (v_multiimp = 'Y' and p_lasttime = 'Y') then etrg.eloutmoney else (select sum(etlje)
                                                                                                      from entrustlist
                                                                                                     where etlbatch =
                                                                                                           p_batch
                                                                                                       and etlsflag = 'Y') end), --���ʽ��
             elschkdate = (case when v_multifile = 'N' then sysdate else null end),
             elsrows    = (select count(*)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'Y'),
             elsje      = (select sum(etlje)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'Y'),
             elfchkdate = sysdate,
             elfrows    = (select count(*)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'N'),
             elfje      = (select sum(etlje)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'N'),
             elchknum   = nvl(elchknum, 0) + 1,
             elchkend   = (case when v_multiimp = 'N' then 'Y' when v_multiimp = 'Y' then p_lasttime end),
             ELIMPTYPE  = 2,
             ELIMFLAG   = 'Y'
       where ELBATCH = p_batch;*/

      UPDATE ENTRUSTLOG
         SET (ELCHKDATE,
              ELSCHKDATE,
              ELFCHKDATE,
              ELOUTROWS, --��������
              ELOUTMONEY, --�������
              ELCHKROWS, --����������
              ELCHKJE, --�����ܽ��
              ELSROWS, --���гɹ�����
              ELSJE, --���гɹ����
              ELFROWS, --����ʧ������
              ELFJE, --����ʧ�ܽ��
              ELPAIDROWS, --��������������
              ELPAIDJE) --���������˽��
              =
             (SELECT SYSDATE,
                     SYSDATE,
                     SYSDATE,
                     COUNT(*),
                     SUM(ETLJE),
                     SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                     SUM(DECODE(ETLSFLAG, 'N', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'N', ETLJE, 0)),
                     SUM(DECODE(EL.ETLPAIDFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLPAIDFLAG, 'Y', ETLJE, 0))
                FROM ENTRUSTLIST EL
               WHERE EL.ETLBATCH = P_BATCH),
             ELCHKNUM = NVL(ELCHKNUM, 0) + 1,
             ELCHKEND = 'N',
             ELIMPTYPE = 2,
             ELIMFLAG = 'Y'
       WHERE ELBATCH = P_BATCH;

    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�������ջ�����Ϣʧ��!');
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_ENTRUSLIST%ISOPEN THEN
        CLOSE C_ENTRUSLIST;
      END IF;
      IF C_IMP%ISOPEN THEN
        CLOSE C_IMP;
      END IF;
      ROLLBACK;
      RAISE;
  END;
  PROCEDURE SQ_TSFILEIMPFAST(P_BATCH    IN VARCHAR2,
                             P_COUNT    IN NUMBER,
                             P_LASTTIME IN VARCHAR2) IS
    ETSL     ENTRUSTLIST%ROWTYPE;
    ETSLTEMP ENTRUSTLIST%ROWTYPE;
    ETRG     ENTRUSTLOG%ROWTYPE;
    CURSOR C_IMP(P_ETLSEQNO VARCHAR2) IS
      SELECT * FROM ENTRUSTLISTTEMP WHERE ETLSEQNO = P_ETLSEQNO;
    CURSOR C_ENTRUSLIST(BATCH VARCHAR2) IS
      SELECT *
        FROM ENTRUSTLIST
       WHERE ETLBATCH = BATCH
         AND (ETLSFLAG = 'N' AND ETLPAIDFLAG = 'N');
    V_SQL            VARCHAR2(10000);
    V_SQLIMPCUR      VARCHAR2(10000);
    V_MULTIFILE      VARCHAR2(1);
    V_MULTIIMP       VARCHAR2(1);
    V_MULTISUCCCOUNT NUMBER(10);
    V_ALLCOUNT       NUMBER(10);
  BEGIN
    BEGIN
      SELECT * INTO ETRG FROM ENTRUSTLOG T WHERE T.ELBATCH = P_BATCH;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�������β�����!');
    END;
    IF ETRG.ELCHKEND = 'Y' THEN
      PG_EWIDE_TS_01.SP_CANCLE_TS_IMP_01(P_BATCH, 'N');
    END IF;
    V_SQL := TRIM(PG_EWIDE_TS_01.FGETTSIMPSQLSTR('01', ETRG.ELBANKID));

    IF V_SQL IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���յ����ʽδ����!');
    END IF;
    OPEN C_ENTRUSLIST(P_BATCH);
    FETCH C_ENTRUSLIST
      INTO ETSL;
    IF C_ENTRUSLIST%NOTFOUND OR C_ENTRUSLIST%NOTFOUND IS NULL THEN
      CLOSE C_ENTRUSLIST;
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��������[' || P_BATCH || ']�Ѿ�ȫ������!');
    END IF;
    IF C_ENTRUSLIST%ISOPEN THEN
      CLOSE C_ENTRUSLIST;
    END IF;
    --�����ʱ��
    DELETE ENTRUSTLISTTEMP;
    --���뷵���ļ�����ʱ��
    V_SQLIMPCUR := REPLACE(V_SQL, '@PARM1', '''' || ETSL.ETLSEQNO || '''');
    EXECUTE IMMEDIATE V_SQLIMPCUR;

    OPEN C_ENTRUSLIST(P_BATCH);
    LOOP
      FETCH C_ENTRUSLIST
        INTO ETSL;
      EXIT WHEN C_ENTRUSLIST%NOTFOUND OR C_ENTRUSLIST%NOTFOUND IS NULL;
      OPEN C_IMP(ETSL.ETLSEQNO);
      FETCH C_IMP
        INTO ETSLTEMP;
      IF C_IMP%ROWCOUNT > 1 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '������ˮ[' || ETSLTEMP.ETLSEQNO || ']�ظ�!');
      END IF;
      IF C_IMP%FOUND THEN
        --������
        IF TRIM(ETSL.ETLSEQNO) <> TRIM(ETSLTEMP.ETLSEQNO) THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  'ϵͳ��ˮ��[' || ETSL.ETLSEQNO || ']' ||
                                  'ʵ��ϵͳ��ˮ��[' || ETSL.ETLSEQNO || ']' || '��[' ||
                                  ETSLTEMP.ETLSEQNO || ']' ||
                                  '�����ļ��뵼������ĵ��Ĳ�һ��!');
        END IF;
        IF TRIM(ETSL.ETLBANKIDNO) <> TRIM(ETSLTEMP.ETLBANKIDNO) THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '���Ϻ�[' || ETSL.ETLMCODE || ']' ||
                                  '��������ʵ�ʱ��[' || ETSL.ETLBANKIDNO || ']' || '��[' ||
                                  ETSLTEMP.ETLBANKIDNO || ']' ||
                                  '�����ļ��뵼������ĵ��Ĳ�һ��!');
        END IF;
        IF TRIM(ETSL.ETLACCOUNTNAME) <> TRIM(ETSLTEMP.ETLACCOUNTNAME) THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '���Ϻ�[' || ETSL.ETLMCODE || ']' || '������[' ||
                                  ETSL.ETLACCOUNTNAME || ']' || '��[' ||
                                  ETSLTEMP.ETLACCOUNTNAME || ']' ||
                                  '�����ļ��뵼������ĵ��Ĳ�һ��!');
        END IF;
        IF ETSL.ETLJE <> ETSLTEMP.ETLJE THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '���Ϻ�[' || ETSL.ETLMCODE || ']' || '�ۿ���[' ||
                                  ETSL.ETLJE || ']' || '��[' ||
                                  ETSLTEMP.ETLJE || ']' ||
                                  '�����ļ��뵼������ĵ��Ĳ�һ��!');
        END IF;
        IF ETSLTEMP.ETLSFLAG NOT IN ('Y', 'N') THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '���з��ؿۿ�ɹ���־����!');
        END IF;

        --�ۿ���Ϣ
        UPDATE ENTRUSTLIST
           SET ETLSFLAG      = ETSLTEMP.ETLSFLAG,
               ETLCHKDATE    = SYSDATE,
               ETLRETURNCODE = ETSLTEMP.ETLRETURNCODE,
               ETLRETURNMSG  = ETSLTEMP.ETLRETURNMSG,
               ETLCHRMODE    = ETSLTEMP.ETLCHRMODE
         WHERE ETLBATCH = ETSL.ETLBATCH
           AND ETLSEQNO = ETSL.ETLSEQNO;
      END IF;
      IF C_IMP%ISOPEN THEN
        CLOSE C_IMP;
      END IF;
    END LOOP;
    V_ALLCOUNT := C_ENTRUSLIST%ROWCOUNT;
    IF C_IMP%ISOPEN THEN
      CLOSE C_ENTRUSLIST;
    END IF;
    IF C_ENTRUSLIST%ISOPEN THEN
      CLOSE C_ENTRUSLIST;
    END IF;
    IF V_MULTISUCCCOUNT >= V_ALLCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����ļ��쳣!');
    END IF;
    --��������ͷ
    BEGIN
      UPDATE ENTRUSTLOG
         SET (ELCHKDATE,
              ELSCHKDATE,
              ELFCHKDATE,
              ELOUTROWS, --��������
              ELOUTMONEY, --�������
              ELCHKROWS, --����������
              ELCHKJE, --�����ܽ��
              ELSROWS, --���гɹ�����
              ELSJE, --���гɹ����
              ELFROWS, --����ʧ������
              ELFJE, --����ʧ�ܽ��
              ELPAIDROWS, --��������������
              ELPAIDJE) --���������˽��
              =
             (SELECT SYSDATE,
                     SYSDATE,
                     SYSDATE,
                     COUNT(*),
                     SUM(ETLJE),
                     SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                     SUM(DECODE(ETLSFLAG, 'N', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'N', ETLJE, 0)),
                     SUM(DECODE(EL.ETLPAIDFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLPAIDFLAG, 'Y', ETLJE, 0))
                FROM ENTRUSTLIST EL
               WHERE EL.ETLBATCH = P_BATCH),
             ELCHKNUM = NVL(ELCHKNUM, 0) + 1,
             ELCHKEND = 'N',
             ELIMPTYPE = 2,
             ELIMFLAG = 'Y'
       WHERE ELBATCH = P_BATCH;

    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�������ջ�����Ϣʧ��!');
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_ENTRUSLIST%ISOPEN THEN
        CLOSE C_ENTRUSLIST;
      END IF;
      IF C_IMP%ISOPEN THEN
        CLOSE C_IMP;
      END IF;
      ROLLBACK;
      RAISE;
  END;
  PROCEDURE SQ_TSFILEIMP(P_BATCH    IN VARCHAR2,
                         P_COUNT    IN NUMBER,
                         P_LASTTIME IN VARCHAR2) IS
  BEGIN
    SQ_TSFILEIMPFAST(P_BATCH, P_COUNT, P_LASTTIME);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;
  --�����������ʺͽ��� by lgb 2012-09-22
  PROCEDURE SP_TSPOS(P_BATCH  IN VARCHAR2, --����������ˮ ����
                     P_OPER   IN VARCHAR2, ----����Ա
                     P_COMMIT IN VARCHAR2 --�ύ��־
                     ) IS
    V_COUNT NUMBER(10);
    CURSOR C_ENTRUSTLOG(VID VARCHAR2) IS
      SELECT *
        FROM ENTRUSTLOG
       WHERE ELBATCH = VID
         AND ELCHARGETYPE = PG_EWIDE_PAY_01.PAYTRANS_TS; --����ֱ���׳�
    ELOG ENTRUSTLOG%ROWTYPE;

    CURSOR C_ENTRUSTLIST(VID VARCHAR2) IS
      SELECT * FROM ENTRUSTLIST WHERE ETLBATCH = VID;
    --AND ETLSFLAG = 'Y'; --����ֱ���׳�
    ELIST ENTRUSTLIST%ROWTYPE;

    --ע�������ظ����ʹ��򣺴��۳ɹ����Ԥ��
    CURSOR C_RL(VBATCH VARCHAR2, VSEQNO VARCHAR2) IS
      SELECT *
        FROM RECLIST
       WHERE RLENTRUSTBATCH = VBATCH
         AND RLENTRUSTSEQNO = VSEQNO
         AND RLOUTFLAG = 'Y'
         AND RLCD = PG_EWIDE_PAY_01.DEBIT
       ORDER BY RLID; --����ֱ���׳�

    CURSOR C_MI(VMID VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID; --����ֱ���׳�

    CURSOR C_CI(VCID VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID; --����ֱ���׳�

    I          NUMBER;
    MI         METERINFO%ROWTYPE;
    VP         PAYMENT%ROWTYPE;
    RL         RECLIST%ROWTYPE;
    PL         PAIDLIST%ROWTYPE;
    CI         CUSTINFO%ROWTYPE;
    VPIID      VARCHAR2(100);
    VZNJ       VARCHAR2(100);
    VPLJE      NUMBER;
    VPID       VARCHAR2(10); --Ԥ�淵��pid
    V_SXFCOUNT NUMBER(10); --�����ѻص���һ��Ӧ�ն�Ӧ��ʵ����
    V_SXF      NUMBER(12, 2); --������
    V_RET      VARCHAR2(5);
  BEGIN
    FOR I IN 1 .. TOOLS.FBOUNDPARA(P_BATCH) LOOP
      --ȡ����������Ϣ
      OPEN C_ENTRUSTLOG(TOOLS.FGETPARA(P_BATCH, I, 1));
      FETCH C_ENTRUSTLOG
        INTO ELOG;
      IF C_ENTRUSTLOG%NOTFOUND OR C_ENTRUSTLOG%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�Ĵ�������' || P_BATCH);
      END IF;
      --�α���������ϸ��ˮ
      OPEN C_ENTRUSTLIST(ELOG.ELBATCH);
      FETCH C_ENTRUSTLIST
        INTO ELIST;
      IF C_ENTRUSTLIST%NOTFOUND OR C_ENTRUSTLIST%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��Ч���˼�¼�������Ƿ���ۿ�ɹ��ļ���' || P_BATCH);
      END IF;
      WHILE C_ENTRUSTLIST%FOUND LOOP
        IF ELIST.ETLPAIDFLAG = 'N' AND ELIST.ETLSFLAG = 'Y' THEN

          ------------------------------
          --�α����Ρ���ϸ��ˮ��Ӧ����ˮ�����Ǻ��ʴ��ۣ�
          VPLJE      := 0; --�ۼ����ʽ��
          V_SXFCOUNT := 0;
          OPEN C_RL(ELIST.ETLBATCH, ELIST.ETLSEQNO);
          FETCH C_RL
            INTO RL;
          IF C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL THEN
            NULL;
            --raise_application_error(errcode,'��Ч�Ĵ���Ӧ���ʼ�¼'||elist.etlbatch||','||elist.etlseqno);
          END IF;
          WHILE C_RL%FOUND AND RL.RLPAIDFLAG = 'N' LOOP

            --�����ѿ���
            IF V_SXFCOUNT = 0 THEN
              V_SXFCOUNT := V_SXFCOUNT + 1;
              V_SXF      := 0;
            ELSE
              V_SXF := ELIST.ETLSXF;
            END IF;
            V_RET := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                         ELOG.ELBANKID, --�ɷѻ���
                                         P_OPER, --�տ�Ա
                                         RL.RLID || '|', --Ӧ����ˮ
                                         RL.RLJE, --Ӧ�ս��
                                         RL.RLZNJ, --����ΥԼ��
                                         V_SXF, --������
                                         RL.RLJE + RL.RLZNJ + V_SXF, --ʵ���տ�
                                         PG_EWIDE_PAY_01.PAYTRANS_TS, --�ɷ�����
                                         RL.RLMID, --����
                                         'TS', --���ʽ
                                         RL.RLSMFID, --�ɷѵص�
                                         FGETSEQUENCE('ENTRUSTLOG'), --�ɷ�������ˮ
                                         'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                         '', --��Ʊ��
                                         'N' --�����Ƿ��ύ��Y/N��
                                         );
            IF V_RET <> '000' THEN
              RAISE_APPLICATION_ERROR(ERRCODE, '����ʧ��' || RL.RLMID);
            END IF;
            --�ۼ����ʽ��
            VPLJE := VPLJE + RL.RLJE + RL.RLZNJ + V_SXF;
            FETCH C_RL
              INTO RL;
          END LOOP;
          CLOSE C_RL;
          IF ELIST.ETLJE > VPLJE THEN
            --�����Ԥ��

            V_RET := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                         ELOG.ELBANKID, --�ɷѻ���
                                         P_OPER, --�տ�Ա
                                         NULL, --Ӧ����ˮ
                                         0, --Ӧ�ս��
                                         0, --����ΥԼ��
                                         0, --������
                                         ELIST.ETLJE - VPLJE, --ʵ���տ�
                                         'S', --�ɷ�����
                                         RL.RLMID, --����
                                         'TS', --���ʽ
                                         ELOG.ELBANKID, --�ɷѵص�
                                         ELIST.ETLBATCH, --�ɷ�������ˮ
                                         'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                         '', --��Ʊ��
                                         'N' --�����Ƿ��ύ��Y/N��
                                         );
            IF V_RET <> '000' THEN
              RAISE_APPLICATION_ERROR(ERRCODE, '����ʧ��' || P_BATCH);
            END IF;
          END IF;

          --��дelist,elog
          UPDATE ENTRUSTLIST
             SET ETLPAIDDATE = VP.PDATETIME, ETLPAIDFLAG = 'Y'
           WHERE ETLBATCH = ELIST.ETLBATCH
             AND ETLSEQNO = ELIST.ETLSEQNO;
          /*          update entrustlog
            set elpaiddate = vp.pdatetime,
                elpaidrows = nvl(elpaidrows, 0) + 1,
                elpaidje   = nvl(elpaidje, 0) + elist.etlje
          where elbatch = elist.etlbatch;*/
          UPDATE RECLIST
             SET RLOUTFLAG = 'N'
           WHERE RLENTRUSTBATCH = ELIST.ETLBATCH
             AND RLENTRUSTSEQNO = ELIST.ETLSEQNO;

        ELSE
          --elist�α���������������Ӧ�գ�����ֻ�������۳ɹ���Ӧ��
          UPDATE RECLIST
             SET RLOUTFLAG = 'N'
           WHERE RLENTRUSTBATCH = ELIST.ETLBATCH
             AND RLENTRUSTSEQNO = ELIST.ETLSEQNO;
          NULL;
        END IF;
        COMMIT;
        FETCH C_ENTRUSTLIST
          INTO ELIST;
      END LOOP;
      CLOSE C_ENTRUSTLIST;
      CLOSE C_ENTRUSTLOG;

      --������������������ڱ�������ʱ,������ֹ�����־

      SELECT COUNT(*)
        INTO V_COUNT
        FROM ENTRUSTLOG
       WHERE ELBATCH = TOOLS.FGETPARA(P_BATCH, I, 1)
         AND ELSROWS = ELPAIDROWS;

      IF V_COUNT > 0 THEN
        UPDATE ENTRUSTLOG
           SET ELCHKEND = 'Y'
         WHERE ELBATCH = TOOLS.FGETPARA(P_BATCH, I, 1)
           AND ELSROWS = ELPAIDROWS;
      END IF;
      UPDATE ENTRUSTLOG
         SET (ELOUTROWS, --��������
              ELOUTMONEY, --�������
              ELCHKROWS, --����������
              ELCHKJE, --�����ܽ��
              ELSROWS, --���гɹ�����
              ELSJE, --���гɹ����
              ELFROWS, --����ʧ������
              ELFJE, --����ʧ�ܽ��
              ELPAIDROWS, --��������������
              ELPAIDJE) --���������˽��
              =
             (SELECT COUNT(*),
                     SUM(ETLJE),
                     SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                     SUM(DECODE(ETLSFLAG, 'N', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'N', ETLJE, 0)),
                     SUM(DECODE(EL.ETLPAIDFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLPAIDFLAG, 'Y', ETLJE, 0))
                FROM ENTRUSTLIST EL
               WHERE EL.ETLBATCH = TOOLS.FGETPARA(P_BATCH, I, 1))
       WHERE ELBATCH = TOOLS.FGETPARA(P_BATCH, I, 1);
    END LOOP;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_ENTRUSTLOG%ISOPEN THEN
        CLOSE C_ENTRUSTLOG;
      END IF;
      IF C_ENTRUSTLIST%ISOPEN THEN
        CLOSE C_ENTRUSTLIST;
      END IF;
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  PROCEDURE SP_TS_EXP(P_TYPE  IN VARCHAR2, --������
                      P_BATCH IN VARCHAR2, --��������
                      O_BASE  OUT TOOLS.OUT_BASE) IS
    V_SQLSTR  VARCHAR2(2000);
    V_BANKID  VARCHAR2(10);
    V_TEMPSTR VARCHAR2(30000);
    V_CLOB    CLOB;
    EF        ENTRUSTFILE%ROWTYPE;
    ETLOG     ENTRUSTLOG%ROWTYPE;
    TYPE CUR IS REF CURSOR;
    C_CDK        CUR;
    V_SMFID      VARCHAR2(2000);
    V_SMFNAME    VARCHAR2(2000);
    V_SMPPVALUE1 VARCHAR2(2000);
    V_SMPPVALUE2 VARCHAR2(2000);
    CURSOR C_FTPPATH(VSMFID IN VARCHAR2) IS
      SELECT SMFID, SMFNAME, B.SMPPVALUE, A.SMPPVALUE
        FROM SYSMANAFRAME, SYSMANAPARA A, SYSMANAPARA B
       WHERE SMFID = A.SMPID
         AND SMFID = B.SMPID
         AND A.SMPPID = 'FTPDKDIR'
         AND B.SMPPID = 'FTPDKSRV'
         AND SMFID = VSMFID;

  BEGIN
    BEGIN
      SELECT *
        INTO ETLOG
        FROM ENTRUSTLOG
       WHERE ELBATCH = P_BATCH
         AND ELOUTMONEY > 0;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN;
        RAISE_APPLICATION_ERROR(-20012, '�������β�����,����!');
    END;
    IF FSYSPARA('TS01') = 'Y' THEN
      V_BANKID := ETLOG.ELBANKID;
      V_SQLSTR := PG_EWIDE_TS_01.FGETTSEXPSQLSTR(P_TYPE, V_BANKID);
    ELSE
      V_SQLSTR := FSYSPARA('0044');
    END IF;

    IF V_SQLSTR IS NULL THEN
      RETURN;
      RAISE_APPLICATION_ERROR(-20012, '�����д��۸�ʽδ��������!');
    END IF;
    V_SQLSTR := REPLACE(V_SQLSTR, '@PARM1', '''' || P_BATCH || '''');
    IF P_TYPE = '01' THEN
      OPEN O_BASE FOR V_SQLSTR;
    ELSIF P_TYPE = '02' THEN
      DBMS_LOB.CREATETEMPORARY(V_CLOB, TRUE);
      OPEN C_CDK FOR 'select c1 from ( ' || V_SQLSTR || ' )';
      LOOP
        FETCH C_CDK
          INTO V_TEMPSTR;
        EXIT WHEN C_CDK%NOTFOUND OR C_CDK%NOTFOUND IS NULL;
        V_TEMPSTR := V_TEMPSTR || CHR(13) || CHR(10);
        DBMS_LOB.WRITEAPPEND(V_CLOB, LENGTH(V_TEMPSTR), V_TEMPSTR);
      END LOOP;
      CLOSE C_CDK;
      OPEN C_FTPPATH(ETLOG.ELBANKID);
      FETCH C_FTPPATH
        INTO V_SMFID, V_SMFNAME, V_SMPPVALUE1, V_SMPPVALUE2;
      IF C_FTPPATH%FOUND THEN
        SELECT SEQ_ENTRUSTFILE.NEXTVAL INTO EF.EFID FROM DUAL;
        --EF.EFID                     :=   ;--�����ĵ���ˮ
        EF.EFSRVID       := V_SMPPVALUE1; --��Ż�����ʶ���ļ����񱾵�pfile.ini�б�ʶ��
        EF.EFPATH        := V_SMPPVALUE2; --���·��
        EF.EFFILENAME    := FGETTSEXPNAME('01', ETLOG.ELBANKID, P_BATCH) ||
                            '.TXT'; --�����ĵ���
        EF.EFELBATCH     := P_BATCH; --��������
        EF.EFFILEDATA    := C2B(V_CLOB); --v_cdk.c1 ;--�����ĵ�
        EF.EFSOURCE      := '����ˮ��˾ϵͳ�Զ�����'; --�ĵ���Դ
        EF.EFNEWDATETIME := SYSDATE; --�ĵ�����ʱ��
        --EF.EFSYNDATETIME            :=  ;--�ĵ�ͬ��ʱ��
        EF.EFFLAG := '0'; --�ĵ���־λ
        --EF.EFREADDATETIME           :=  ;--�ĵ�����ʱ��
        EF.EFMEMO := '����ˮ��˾ϵͳ�Զ�����'; --�ĵ�˵��

        INSERT INTO ENTRUSTFILE VALUES EF;
        --������ļ�
        SELECT SEQ_ENTRUSTFILE.NEXTVAL INTO EF.EFID FROM DUAL;
        EF.EFFILENAME := EF.EFFILENAME || '.CHK';
        EF.EFFILEDATA := C2B('0'); --v_cdk.c1 ;--�����ĵ�
        INSERT INTO ENTRUSTFILE VALUES EF;
        COMMIT;
      END IF;
      CLOSE C_FTPPATH;

    ELSE
      RETURN;
      --raise_application_error(-20012, '�ݲ�֧�ִ��������д������ݵ���!');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_CDK%ISOPEN THEN
        CLOSE C_CDK;
      END IF;
      IF C_FTPPATH%ISOPEN THEN
        CLOSE C_FTPPATH;
      END IF;
      ROLLBACK;
  END;
  ---------------------------------------------------------------------------
  --name:F_GETwzTSsl_wz
  --note:ȡ��ˮ��ˮ��
  --author:���Ⲩ
  --date��2011/11/10
  --input: pc ���κ�
  --       tsh  ���պ�
  ---------------------------------------------------------------------------
  FUNCTION F_GETWZTSSL_WZ(PC VARCHAR2, TSH VARCHAR2) RETURN NUMBER AS
    DJ NUMBER;
  BEGIN
    SELECT SUM(RDSL)
      INTO DJ
      FROM RECLIST R2, RECDETAIL
     WHERE RLID = RDID
       AND RLENTRUSTBATCH = PC
       AND RLCCODE IN (SELECT MICODE FROM METERINFO WHERE MIUIID = TSH)
       AND RDPIID = '04'
       AND RDJE > 0
       AND RLIFTAX = 'Y';
    RETURN DJ;
  END;
  ---------------------------------------------------------------------------
  --name:F_GETwzTSsl_wz
  --note:ȡ��ˮ�Ľ��
  --author:���Ⲩ
  --date��2011/11/10
  --input: pc ���κ�
  --       tsh  ���պ�
  ---------------------------------------------------------------------------

  FUNCTION F_GETWZTSJE_WZ(PC VARCHAR2, TSH VARCHAR2) RETURN NUMBER AS
    JE NUMBER;
  BEGIN
    SELECT SUM(RDJE)
      INTO JE
      FROM RECLIST R2, RECDETAIL
     WHERE RLID = RDID
       AND RLENTRUSTBATCH = PC
       AND RLCCODE IN (SELECT MICODE FROM METERINFO WHERE MIUIID = TSH)
       AND RDPIID = '04'
       AND RLIFTAX = 'Y';
    RETURN JE;
  END;
END;
/

