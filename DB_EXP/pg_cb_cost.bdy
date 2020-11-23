CREATE OR REPLACE PACKAGE BODY PG_CB_COST IS

  �ܱ����     VARCHAR2(10);
  ������ˮ�� NUMBER(10);
  
  
  
  --�ṩ�ⲿ��������
  PROCEDURE COSTBATCH(P_BFID IN VARCHAR2) IS
    CURSOR C_MR(VBFID IN VARCHAR2, VSMFID IN VARCHAR2) IS
      SELECT YCM.ID
        FROM YS_CB_MTREAD YCM, YS_YH_SBINFO YYS
       WHERE YCM.SBID = YYS.SBID
         AND YCM.BOOK_NO = VBFID
         AND YCM.MANAGE_NO = VSMFID
         AND CBMRIFREC = 'N' --δ�Ʒ�
         AND CBMRREADOK = 'Y' --����
       ORDER BY SBCLASS DESC,
                (CASE
                  WHEN SBPRIFLAG = 'Y' AND SBPRIID <> SBCODE THEN
                   1
                  ELSE
                   2
                END) ASC;
    --�α��в�������Դ������ǰ��Դ���ܱ����²��Ҳ��ȴ����׳��쳣
  
    VMRID  YS_CB_MTREAD.ID%TYPE;
    VBFID  YS_CB_MTREAD.BOOK_NO%TYPE;
    VSMFID YS_CB_MTREAD.MANAGE_NO%TYPE;
  BEGIN
  
    FOR I IN 1 .. FBOUNDPARA(P_BFID) LOOP
      VBFID  := FGETPARA(P_BFID, I, 1);
      VSMFID := FGETPARA(P_BFID, I, 2);
      OPEN C_MR(VBFID, VSMFID);
      LOOP
        FETCH C_MR
          INTO VMRID;
        EXIT WHEN C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL;
        --���������¼����
        BEGIN
          COSTCULATE(VMRID, �ύ);
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
      END LOOP;
      CLOSE C_MR;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  
  
  
  --�ƻ����������-��������ˮ
  PROCEDURE COSTCULATE(P_MRID IN YS_CB_MTREAD.ID%TYPE, P_COMMIT IN NUMBER) IS
    CURSOR C_MR IS
      SELECT *
        FROM YS_CB_MTREAD
       WHERE ID = P_MRID
         AND CBMRIFREC = 'N'
         AND CBMRREADOK = 'Y' --����
         AND CBMRSL >= 0
         FOR UPDATE NOWAIT;
  
    --�����ӱ����¼
    CURSOR C_MR_PRI(P_PRIMCODE IN VARCHAR2) IS
      SELECT CBMRSL, CBMRIFREC, YCM.SBID
        FROM YS_YH_SBINFO YYS, YS_CB_MTREAD YCM
       WHERE YYS.SBID = YCM.SBID
         AND SBPRIFLAG = 'Y'
         AND SBPRIID = P_PRIMCODE
         AND YYS.SBID <> P_PRIMCODE;
  
    --ȡ���ձ���Ϣ
    CURSOR C_MI(P_MID IN VARCHAR2) IS
      SELECT SBPRIFLAG,
             SBPRIID,
             SBRPID,
             SBCLASS,
             SBIFCHARGE,
             SBIFSL,
             SBLB,
             SBSTATUS,
             SBIFCHK
        FROM YS_YH_SBINFO
       WHERE SBID = P_MID;
  
    MR         YS_CB_MTREAD%ROWTYPE;
    MRCHILD    YS_CB_MTREAD%ROWTYPE;
    MRPRICHILD YS_CB_MTREAD%ROWTYPE;
    MI         YS_YH_SBINFO%ROWTYPE;
    MRL        YS_CB_MTREAD%ROWTYPE;
    --MD         METERTRANSDT%ROWTYPE;
    V_COUNT  NUMBER;
    V_COUNT1 NUMBER;
    V_MRSL   YS_CB_MTREAD.CBMRSL%TYPE;
    VPID     VARCHAR2(10);
    V_MMTYPE VARCHAR2(10);
  BEGIN
    OPEN C_MR;
    FETCH C_MR
      INTO MR;
    IF C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '������ˮ��:' || P_MRID || '��Ч�ĳ���ƻ���ˮ�ţ��򲻷��ϼƷ�����');
    END IF;
    MR.CBMRCHKSL := MR.CBMRSL;
  
    --ˮ���¼
    OPEN C_MI(MR.SBID);
    FETCH C_MI
      INTO MI.SBPRIFLAG,
           MI.SBPRIID,
           MI.SBRPID,
           MI.SBCLASS,
           MI.SBIFCHARGE,
           MI.SBIFSL,
           MI.SBLB,
           MI.SBSTATUS,
           MI.SBIFCHK;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.SBID);
    END IF;
    CLOSE C_MI;
  
    MR.CBMRRECSL := MR.CBMRSL;
    IF MR.CBMRSL > 0 AND MR.CBMRSL < ������ˮ�� AND
       MR.CBMRDATASOURCE IN ('1', '5', '9') THEN
      MR.CBMRIFREC   := 'Y';
      MR.CBMRRECDATE := TRUNC(SYSDATE);
      MR.CBMRMEMO    := MR.CBMRMEMO || ',' || ������ˮ�� || '�����²��Ʒ�';
    ELSIF �ܱ���� = 'Y' THEN
      --�����Ƿ��ж༶���ϵ Ԥ��
    
      --�ƷѺ���----------------------------------------------------------
      IF MR.CBMRIFREC = 'N' AND (MR.CBMRIFSUBMIT = 'Y' OR P_COMMIT = ����) AND
         MI.SBIFCHARGE = 'Y' THEN
        COSTCULATECORE(MR, �ƻ�����, '0', P_COMMIT); --���ѵ�ǰˮ�۽��мƷѣ�ˮ�۰汾��Ĭ��0����������չ
      END IF;
      --��ֹ��------------------------------------------------------------
      IF P_COMMIT != ���� THEN
        UPDATE YS_YH_SBINFO
           SET SBRCODE     = MR.CBMRECODE,
               SBRECDATE   = MR.CBMRRDATE,
               SBRECSL     = MR.CBMRSL, --ȡ����ˮ����������
               SBFACE      = MR.CBMRFACE,
               SBNEWFLAG   = 'N',
               SBRCODECHAR = MR.CBMRECODECHAR
         WHERE SBID = MR.SBID;
      END IF;
    ELSE
      --�ƷѺ���----------------------------------------------------------
      IF MR.CBMRIFREC = 'N' AND (MR.CBMRIFSUBMIT = 'Y' OR P_COMMIT = ����) AND
         MI.SBIFCHARGE = 'Y' THEN
        COSTCULATECORE(MR, �ƻ�����, '0', P_COMMIT); --���ѵ�ǰˮ�۽��мƷѣ�ˮ�۰汾��Ĭ��0����������չ
      END IF;
      --��ֹ��------------------------------------------------------------
      IF P_COMMIT != ���� AND MR.CBMRIFREC = 'Y' THEN
        UPDATE YS_YH_SBINFO
           SET SBRCODE     = MR.CBMRECODE,
               SBRECDATE   = MR.CBMRRDATE,
               SBRECSL     = MR.CBMRSL, --ȡ����ˮ����������
               SBFACE      = MR.CBMRFACE,
               SBNEWFLAG   = 'N',
               SBRCODECHAR = MR.CBMRECODECHAR
         WHERE SBID = MR.SBID;
      END IF;
    END IF;
    --���µ�ǰ�����¼���������Ʒ���Ϣ
    IF P_COMMIT != ���� AND MR.CBMRIFREC = 'Y' THEN
      UPDATE YS_CB_MTREAD
         SET CBMRIFREC   = MR.CBMRIFREC,
             CBMRRECDATE = MR.CBMRRECDATE,
             CBMRRECSL   = MR.CBMRRECSL,
             CBMRRECJE01 = MR.CBMRRECJE01,
             CBMRRECJE02 = MR.CBMRRECJE02,
             CBMRRECJE03 = MR.CBMRRECJE03,
             CBMRRECJE04 = MR.CBMRRECJE04,
             CBMRMEMO    = MR.CBMRMEMO
       WHERE CURRENT OF C_MR;
    
    ELSE
      UPDATE YS_CB_MTREAD
         SET CBMRRECJE01 = MR.CBMRRECJE01,
             CBMRRECJE02 = MR.CBMRRECJE02,
             CBMRRECJE03 = MR.CBMRRECJE03,
             CBMRRECJE04 = MR.CBMRRECJE04,
             CBMRMEMO    = MR.CBMRMEMO,
             CBMRRECDATE = MR.CBMRRECDATE,
             CBMRRECSL   = MR.CBMRRECSL
       WHERE CURRENT OF C_MR;
    END IF;
    --2���ύ����
    BEGIN
      CLOSE C_MR;
      IF P_COMMIT = ���� THEN
        NULL;
        --rollback;
      ELSE
        IF P_COMMIT = �ύ THEN
          COMMIT;
        ELSIF P_COMMIT = ���ύ THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '�Ƿ��ύ��������ȷ');
        END IF;
      END IF;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_MR_PRI%ISOPEN THEN
        CLOSE C_MR_PRI;
      END IF;
      IF C_MR%ISOPEN THEN
        CLOSE C_MR;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END COSTCULATE;
  --������Ѻ���
  PROCEDURE COSTCULATECORE(MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                           P_TRANS  IN CHAR,
                           P_PSCID  IN NUMBER,
                           P_COMMIT IN NUMBER) IS
    CURSOR C_MI(VMIID IN YS_YH_SBINFO.SBID%TYPE) IS
      SELECT * FROM YS_YH_SBINFO WHERE SBID = VMIID;
  
    CURSOR C_CI(VCIID IN YS_YH_CUSTINFO.YHID%TYPE) IS
      SELECT * FROM YS_YH_CUSTINFO WHERE YHID = VCIID;
  
    CURSOR C_MD(VMIID IN YS_YH_SBDOC.SBID%TYPE) IS
      SELECT * FROM YS_YH_SBDOC WHERE SBID = VMIID;
  
    CURSOR C_MA(VMIID IN YS_YH_ACCOUNT.SBID%TYPE) IS
      SELECT * FROM YS_YH_ACCOUNT WHERE SBID = VMIID;
  
    CURSOR C_VER IS
      SELECT *
        FROM (SELECT MAX(PRICE_VER) ID, TO_DATE('99991231', 'yyyymmdd')
                FROM bas_price_name)
       ORDER BY ID DESC;
    V_VERID BAS_PRICE_VERSION.ID%TYPE;
    V_ODATE DATE;
    V_RDATE DATE;
    V_SL    NUMBER;
  
    --�����ˮ�ȶ����ٶ���
    CURSOR C_PMD(VPSCID IN NUMBER, VMID IN ys_yh_pricegroup.SBID%TYPE) IS
      SELECT *
        FROM (SELECT * FROM ys_yh_pricegroup WHERE SBID = VMID)
       ORDER BY GRPTYPE DESC, GRPID; --��ά���Ⱥ�˳��
  
    PMD YS_YH_PRICEGROUP%ROWTYPE;
  
    --�۸���ϵ
    CURSOR C_PD(VPSCID IN NUMBER, VPFID IN BAS_PRICE_DETAIL.PRICE_NO%TYPE) IS
      SELECT *
        FROM (SELECT *
                FROM BAS_PRICE_DETAIL T
               WHERE PRICE_VER = VPSCID
                 AND PRICE_NO = VPFID)
       ORDER BY PRICE_VER DESC, PRICE_ITEM ASC;
    PD BAS_PRICE_DETAIL%ROWTYPE;
  
    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.ITEM_TYPE, 1) FROM BAS_PRICE_ITEM T;
  
    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM BAS_PRICE_ITEM T WHERE T.ITEM_TYPE = VPIGROUP;
  
    MI        YS_YH_SBINFO%ROWTYPE;
    CI        YS_YH_CUSTINFO%ROWTYPE;
    MD        YS_YH_SBDOC%ROWTYPE;
    MA        YS_YH_ACCOUNT%ROWTYPE;
    RL        YS_ZW_ARLIST%ROWTYPE;
    BF        YS_BAS_BOOK%ROWTYPE;
    MAXPMDID  NUMBER;
    PMNUM     NUMBER;
    TEMPSL    NUMBER;
    V_PMDSL   NUMBER;
    V_PMDDBSL NUMBER;
    RLVER     YS_ZW_ARLIST%ROWTYPE;
    RLTAB     RL_TABLE;
    RDTAB     RD_TABLE;
    N         NUMBER;
    M         NUMBER;
    CLASSCTL  CHAR(1) := 'N'; --Ĭ�ϲ�ȡ�����ݼƷѷ���
  
    I   NUMBER;
    VRD YS_ZW_ARDETAIL%ROWTYPE;
  
  BEGIN
    --����ˮ���¼
    OPEN C_MI(MR.SBID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.SBID);
    END IF;
    --����ˮ����
    OPEN C_MD(MR.SBID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.SBID);
    END IF;
    --����ˮ������
    OPEN C_MA(MR.SBID);
    FETCH C_MA
      INTO MA;
    CLOSE C_MA;
    --�����û���¼
    OPEN C_CI(MI.SBID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч���û����' || MI.SBID);
    END IF;
    --����ǼƷѵ���������ˮ�۽��мƷ�
    IF MR.ID = '?' OR P_TRANS = 'O' THEN
      MI.PRICE_NO := MR.PRICE_NO;
    END IF;
    /*------------------���������У��-------------------
    IF �Ƿ������ˮ��(MI.SBID) = 'Y' AND MI.SBYEARDATE IS NULL THEN
      MI.SBYEARSL := 0; --���ۼ���
      MI.SBYEARDATE := TRUNC(SYSDATE, 'YYYY'); --�����������
      UPDATE YS_YH_SBINFO
         SET SBYEARSL = MI.SBYEARSL, SBYEARDATE = MI.SBYEARDATE
       WHERE SBID = MI.SBID;
    END IF;
    ------------------���������У��-------------------*/
  
    --�ǼƷѱ�ִ�пչ��̣������쳣
    --reclist����������������������������������������������������������������������������������������������
    BEGIN
      SELECT SYS_GUID() INTO RL.ID FROM DUAL;
      RL.HIRE_CODE     := MI.HIRE_CODE;
      RL.ARID          := LPAD(SEQ_ARID.NEXTVAL,10,'0');
      RL.MANAGE_NO     := MI.MANAGE_NO;
      RL.ARMONTH       := Fobtmanapara(RL.MANAGE_NO, 'READ_MONTH');
      RL.ARDATE        := TRUNC(SYSDATE);
      RL.YHID          := MR.YHID;
      RL.SBID          := MR.SBID;
      RL.ARCHARGEPER   := MI.SBCPER;
      RL.ARCPID        := CI.YHPID;
      RL.ARCCLASS      := CI.YHCLASS;
      RL.ARCFLAG       := CI.YHFLAG;
      RL.ARUSENUM      := MI.SBUSENUM;
      RL.ARCNAME       := CI.YHNAME;
      RL.ARCNAME2      := CI.YHNAME2;
      RL.ARCADR        := CI.YHADR;
      RL.ARMINAME      := MI.SBNAME;
      RL.ARMADR        := MI.SBADR;
      RL.ARCSTATUS     := CI.YHSTATUS;
      RL.ARMTEL        := CI.YHMTEL;
      RL.ARTEL         := CI.YHTEL1;
      RL.ARBANKID      := MA.YHABANKID;
      RL.ARTSBANKID    := MA.YHATSBANKID;
      RL.ARACCOUNTNO   := MA.YHAACCOUNTNO;
      RL.ARACCOUNTNAME := MA.YHAACCOUNTNAME;
      RL.ARIFTAX       := MI.SBIFTAX;
      RL.ARTAXNO       := MI.SBTAXNO;
      RL.ARIFINV       := CI.YHIFINV; --��Ʊ��־
      RL.ARMCODE       := MI.SBCODE;
      RL.ARMPID        := MI.SBPID;
      RL.ARMCLASS      := MI.SBCLASS;
      RL.ARMFLAG       := MI.SBFLAG;
      RL.ARDAY         := MR.CBMRDAY;
      RL.ARBFID        := MI.BOOK_NO; --
      --�ֶ��㷨Ҫ�����ڳ������ںͱ��ڳ������ڷǿ�
      RL.ARPRDATE := NVL(NVL(NVL(MR.CBMRPRDATE, MI.SBINSDATE), MI.SBNEWDATE),
                         TRUNC(SYSDATE));
      RL.ARRDATE  := NVL(NVL(MR.CBMRRDATE, TRUNC(MR.CBMRINPUTDATE)),
                         TRUNC(SYSDATE));
    
      --ΥԼ���������ڣ�ע��ͬ���޸�Ӫҵ��������ˣ�
      /*A  ���¶�������
      B  ���¶�������
      C  �Ʒ�������*/
      /*BEGIN
        SELECT * INTO BL FROM BREACHLIST;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF BL.BLMETHOD = 'A' THEN
        RL.RLZNDATE := FIRST_DAY(RL.RLDATE) + BL.BLTCOUNT - 1;
      ELSIF BL.BLMETHOD = 'B' THEN
        RL.RLZNDATE := FIRST_DAY(ADD_MONTHS(RL.RLDATE, 1)) + BL.BLTCOUNT - 1;
      ELSIF BL.BLMETHOD = 'C' THEN
        RL.RLZNDATE := RL.RLDATE + NVL(BL.BLTCOUNT, 30);
      ELSE
        RL.RLZNDATE := FIRST_DAY(ADD_MONTHS(RL.RLDATE, 1));
      END IF;*/
      RL.ARZNDATE       := RL.ARDATE + 30;
      RL.ARCALIBER      := MD.MDCALIBER;
      RL.ARRTID         := MI.SBRTID;
      RL.ARMSTATUS      := MI.SBSTATUS;
      RL.ARMTYPE        := MI.SBTYPE;
      RL.ARMNO          := MD.MDNO;
      RL.ARSCODE        := MR.CBMRSCODE;
      RL.ARECODE        := MR.CBMRECODE;
      RL.ARREADSL       := MR.CBMRSL; --�����ݴ棬���ָ�
      RL.ARINVMEMO := CASE
                        WHEN NOT (P_PSCID = '0000.00' OR P_PSCID IS NULL) THEN
                         '[' || P_PSCID || ']��ʷ����'
                        ELSE
                         ''
                      END;
      RL.ARENTRUSTBATCH := NULL;
      RL.ARENTRUSTSEQNO := NULL;
      RL.AROUTFLAG      := 'N';
      RL.ARTRANS        := P_TRANS;
      RL.ARCD           := DEBIT;
      RL.ARYSCHARGETYPE := MI.SBCHARGETYPE;
      RL.ARSL           := 0; --Ӧ��ˮ��ˮ������rlsl = rlreadsl + rladjsl��
      RL.ARJE           := 0; --������������,�ȳ�ʼ��
      RL.ARADDSL        := NVL(MR.CBMRADDSL, 0);
      RL.ARPAIDJE       := 0;
      RL.ARPAIDFLAG     := 'N';
      RL.ARPAIDPER      := NULL;
      RL.ARPAIDDATE     := NULL;
      RL.ARMRID         := MR.ID;
      RL.ARMEMO         := MR.CBMRMEMO;
      RL.ARZNJ          := 0;
      RL.ARLB           := MI.SBLB;
      RL.ARPFID         := MI.PRICE_NO;
      RL.ARDATETIME     := SYSDATE;
      RL.ARPRIMCODE     := MI.SBPRIID; --��¼�����ӱ�
      RL.ARPRIFLAG      := MI.SBPRIFLAG;
      RL.ARRPER         := MR.CBMRRPER;
      RL.ARSCODECHAR    := MR.CBMRSCODE;
      RL.ARECODECHAR    := MR.CBMRECODE;
      RL.ARGROUP        := '1'; --Ӧ���ʷ���
      RL.ARPID          := NULL; --ʵ����ˮ����payment.pid��Ӧ��
      RL.ARPBATCH       := NULL; --�ɷѽ������Σ���payment.pbatch��Ӧ��
      RL.ARSAVINGQC     := 0; --�ڳ�Ԥ�棨����ʱ������
      RL.ARSAVINGBQ     := 0; --����Ԥ�淢��������ʱ������
      RL.ARSAVINGQM     := 0; --��ĩԤ�棨����ʱ������
      RL.ARREVERSEFLAG  := 'N'; --  ������־��nΪ������yΪ������
      RL.ARBADFLAG      := 'N'; --���ʱ�־��y :�����ʣ�o:�����������У�n:�����ʣ�
      RL.ARZNJREDUCFLAG := 'N'; --���ɽ�����־,δ����ʱΪn������ʱ���ɽ�ֱ�Ӽ��㣻�����Ϊy,����ʱ���ɽ�ֱ��ȡrlznj
      RL.ARSXF          := 0; --������
      RL.ARMIFACE2      := MI.SBFACE2; --��������
      RL.ARMIFACE3      := MI.SBFACE3; --�ǳ�����
      RL.ARMIFACE4      := MI.SBFACE4; --����ʩ˵��
      RL.ARMIIFCKF      := MI.SBIFCHK; --�����ѻ���
      RL.ARMIGPS        := MI.SBGPS; --�Ƿ��Ʊ
      RL.ARMIQFH        := MI.SBQFH; --Ǧ���
      RL.ARMIBOX        := MI.SBBOX; --����ˮ�ۣ���ֵ˰ˮ�ۣ�
      RL.ARMINAME2      := MI.SBNAME2; --��������(С������
      RL.ARMISEQNO      := MI.SBSEQNO; --���ţ���ʼ��ʱ���+��ţ�
      RL.ARSCRARID      := RL.ARID; --ԭӦ������ˮ
      RL.ARSCRARTRANS   := RL.ARTRANS; --ԭӦ��������
      RL.ARSCRARMONTH   := RL.ARMONTH; --ԭӦ�����·�
      RL.ARSCRARDATE    := RL.ARDATE; --ԭӦ��������
    
      IF (MR.CBMRNEWFLAG = 'Y' AND (MR.ID = '?' OR P_TRANS = 'O')) THEN
        --Ӧ��׷����ѡ���ƽ��ݱ�־
        CLASSCTL := 'Y';
      ELSE
        CLASSCTL := 'N';
      END IF;
    
      BEGIN
        SELECT NVL(SUM(ARDJE), 0)
          INTO RL.ARPRIORJE
          FROM YS_ZW_ARLIST, YS_ZW_ARDETAIL
         WHERE ARID = ARDID
           AND ARREVERSEFLAG = 'N'
           AND ARPAIDFLAG = 'N'
           AND ARJE > 0
           AND SBID = MI.SBID;
      EXCEPTION
        WHEN OTHERS THEN
          RL.ARPRIORJE := 0; --���֮ǰǷ��
      END;
      RL.ARMISAVING := MI.SBSAVING; --���ʱԤ��
      /*END IF;*/
      RL.ARMICOMMUNITY   := MI.SBCOMMUNITY;
      RL.ARMIREMOTENO    := MI.SBREMOTENO;
      RL.ARMIREMOTEHUBNO := MI.SBREMOTEHUBNO;
      RL.ARMIEMAIL       := MI.SBEMAIL;
      RL.ARMIEMAILFLAG   := MI.SBEMAILFLAG;
      RL.ARMICOLUMN1     := P_PSCID;
      RL.ARMICOLUMN2     := NULL;
      RL.ARMICOLUMN3     := NULL;
      RL.ARMICOLUMN4     := NULL;
      RL.ARCOLUMN5       := NULL; --�ϴ�Ӧ��������
      RL.ARCOLUMN9       := NULL; --�ϴ�Ӧ������ˮ
      RL.ARCOLUMN10      := NULL; --�ϴ�Ӧ�����·�
      RL.ARCOLUMN11      := NULL; --�ϴ�Ӧ��������
    END;
    --reclist��������������������������������������������������������������������������������������������������
  
    --0�������鵵�۸�ϵ�ֶΡ���ָ���۸�ϵ��ǰ�����ݼ�׼��
    IF P_PSCID IS NOT NULL THEN
      --ָ���۸�ϵ
      IF P_PSCID = 0 THEN
        SELECT MAX(PRICE_VER) INTO RL.ARMICOLUMN1 FROM BAS_PRICE_NAME;
      END IF;
      RLTAB := RL_TABLE(RL);
    ELSE
      --�ֶ�
      OPEN C_VER;
      FETCH C_VER
        INTO V_VERID, V_ODATE;
      IF C_VER%NOTFOUND OR C_VER%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�޷���ȡ��Ч�ļ۸�ϵ1');
      END IF;
      WHILE C_VER%FOUND LOOP
        IF V_ODATE >= RL.ARPRDATE AND
           (RLVER.ARRDATE IS NULL OR RLVER.ARRDATE < RL.ARRDATE) THEN
          RLVER := RL;
          ---------------------
          RLVER.ARPRDATE := CASE
                              WHEN V_RDATE IS NULL THEN
                               RL.ARPRDATE
                              ELSE
                               V_RDATE
                            END;
          RLVER.ARRDATE := CASE
                             WHEN RL.ARRDATE <= V_ODATE THEN
                              RL.ARRDATE
                             ELSE
                              V_ODATE
                           END;
          RLVER.ARREADSL := ROUND(RLVER.ARREADSL * CASE
                                    WHEN (RL.ARRDATE - RL.ARPRDATE) = 0 THEN
                                     1
                                    ELSE
                                     (RLVER.ARRDATE - RLVER.ARPRDATE) /
                                     (RL.ARRDATE - RL.ARPRDATE)
                                  END,
                                  0);
          RLVER.ARADDSL := ROUND(RLVER.ARADDSL * CASE
                                   WHEN (RL.ARRDATE - RL.ARPRDATE) = 0 THEN
                                    1
                                   ELSE
                                    (RLVER.ARRDATE - RLVER.ARPRDATE) /
                                    (RL.ARRDATE - RL.ARPRDATE)
                                 END,
                                 0);
          RLVER.ARSL := ROUND(RLVER.ARSL * CASE
                                WHEN (RL.ARRDATE - RL.ARPRDATE) = 0 THEN
                                 1
                                ELSE
                                 (RLVER.ARRDATE - RLVER.ARPRDATE) /
                                 (RL.ARRDATE - RL.ARPRDATE)
                              END,
                              0);
          V_SL              := NVL(V_SL, 0) + RLVER.ARREADSL;
          RLVER.ARMICOLUMN1 := V_VERID;
          ---------------------
          V_RDATE := RLVER.ARRDATE;
          --���������ʱ�ֶΰ�
          IF RLTAB IS NULL THEN
            RLTAB := RL_TABLE(RLVER);
          ELSE
            RLTAB.EXTEND;
            RLTAB(RLTAB.LAST) := RLVER;
          END IF;
        END IF;
        FETCH C_VER
          INTO V_VERID, V_ODATE;
      END LOOP;
      RLTAB(RLTAB.LAST).ARREADSL := RLTAB(RLTAB.LAST)
                                    .ARREADSL + (RL.ARREADSL - V_SL);
      CLOSE C_VER;
    END IF;
    IF RLTAB IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�޷���ȡ��Ч�ļ۸�ϵ2');
    END IF;
  
    --1�����۸���ϵ�����鵵�۸�
    FOR I IN RLTAB.FIRST .. RLTAB.LAST LOOP
      RLVER := RLTAB(I);
      OPEN C_PMD(RLVER.ARMICOLUMN1, MI.SBID);
      FETCH C_PMD
        INTO PMD;
      --1.1����һ��ˮ
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN
        --1.1.1�����ر𵥼�
        OPEN C_PD(RLVER.ARMICOLUMN1, MI.PRICE_NO);
        LOOP
          FETCH C_PD
            INTO PD;
          EXIT WHEN C_PD%NOTFOUND;
        
          PMD := NULL;
          COSTPIID(P_RL       => RLVER,
                   P_MR       => MR,
                   P_SL       => RLVER.ARREADSL,
                   PD         => PD,
                   PMD        => PMD,
                   RDTAB      => RDTAB,
                   P_CLASSCTL => CLASSCTL,
                   P_PSCID    => P_PSCID,
                   P_COMMIT   => P_COMMIT);
        
        END LOOP;
        CLOSE C_PD;
        ------------------------------------------------------
        --1.2�������ˮ
      ELSE
        SELECT COUNT(GRPID)
          INTO MAXPMDID
          FROM (SELECT * FROM YS_YH_PRICEGROUP WHERE SBID = MI.SBID);
      
        V_PMDSL   := 0; --�����ˮ��
        PMNUM     := 0;
        V_PMDDBSL := RLVER.ARREADSL; --����Ԫˮ��
        TEMPSL    := RLVER.ARREADSL; --�����ʣ��ˮ��
      
        WHILE C_PMD%FOUND AND TEMPSL >= 0 LOOP
          PMNUM := PMNUM + 1;
          --�����������������
          IF PMNUM = MAXPMDID THEN
            V_PMDSL := TEMPSL;
          ELSE
            IF PMD.GRPTYPE = '00' THEN
              --���Ȼ��
              V_PMDSL := CEIL(PMD.GRPSCALE * V_PMDDBSL);
            ELSE
              --�������
              V_PMDSL := (CASE
                           WHEN TEMPSL >= TRUNC(PMD.GRPSCALE) THEN
                            TRUNC(PMD.GRPSCALE)
                           ELSE
                            TEMPSL
                         END);
              V_PMDDBSL := V_PMDDBSL - V_PMDSL;
            END IF;
          END IF;
        
          --�˴��������۸���������Ʒ�--------------------------
          OPEN C_PD(RLVER.ARMICOLUMN1, PMD.PRICE_NO);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;
            COSTPIID(RLVER,
                     MR,
                     V_PMDSL,
                     PD,
                     PMD,
                     RDTAB,
                     CLASSCTL,
                     P_PSCID,
                     P_COMMIT);
          END LOOP;
          CLOSE C_PD;
          ------------------------------------------------------
          FETCH C_PMD
            INTO PMD;
          TEMPSL := TEMPSL - V_PMDSL;
        END LOOP;
      END IF;
      CLOSE C_PMD;
    END LOOP;
    --ͳһ�������Ӧ��ˮ������������
    RL.ARREADSL := MR.CBMRSL; --��ԭ
    RL.ARSL     := 0;
    RL.ARJE     := 0;
    IF RDTAB IS NOT NULL THEN
      FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
        IF RDTAB(I).ARDPIID = '01' THEN
          RL.ARSL := RL.ARSL + RDTAB(I).ARDSL;
        END IF;
        RL.ARJE := RL.ARJE + RDTAB(I).ARDJE;
      END LOOP;
    ELSE
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '�޷�����Ӧ��������ϸ����������ˮ����');
    END IF;
    IF P_COMMIT != ���� THEN
      INSERT INTO YS_ZW_ARLIST VALUES RL;
    ELSE
      INSERT INTO YS_ZW_ARLIST_BUDGET VALUES RL;
      INSERT INTO YS_ZW_ARLIST_virtual VALUES RL;
    END IF;
    INSRD(RDTAB, P_COMMIT);
  
    CLOSE C_MI;
    CLOSE C_MD;
    CLOSE C_CI;
    --����Ӧ��ˮ��ˮ�ѵ�ԭʼ�����¼
    MR.CBMRRECSL        := NVL(RL.ARSL, 0);
    MR.CBMRIFREC        := 'Y';
    MR.CBMRRECDATE      := RL.ARDATE;
    MR.CBMRPRIVILEGEPER := RL.ARID; --���ֶμ�¼rlid���أ�����ʱ����20140507
  
    --Ϊ��Ӧ����¼���е��˱�С�ᣬ�����ȳ�ʼ��Ϊ0
    MR.CBMRRECJE01 := 0;
    MR.CBMRRECJE02 := 0;
    MR.CBMRRECJE03 := 0;
    MR.CBMRRECJE04 := 0;
    MR.CBMRRECSL   := 0;
    IF RDTAB IS NOT NULL THEN
      FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
        VRD := RDTAB(I);
        --�����ܽ�
        CASE VRD.ARDPIID
          WHEN '01' THEN
            MR.CBMRRECJE01 := NVL(MR.CBMRRECJE01, 0) + VRD.ARDJE;
          WHEN '02' THEN
            MR.CBMRRECJE02 := NVL(MR.CBMRRECJE02, 0) + VRD.ARDJE;
          WHEN '03' THEN
            MR.CBMRRECJE03 := NVL(MR.CBMRRECJE03, 0) + VRD.ARDJE;
          WHEN '04' THEN
            MR.CBMRRECJE04 := NVL(MR.CBMRRECJE04, 0) + VRD.ARDJE;
          ELSE
            NULL;
        END CASE;
      END LOOP;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      IF C_MD%ISOPEN THEN
        CLOSE C_MD;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      IF C_VER%ISOPEN THEN
        CLOSE C_VER;
      END IF;
      IF C_PMD%ISOPEN THEN
        CLOSE C_PMD;
      END IF;
      IF C_PD%ISOPEN THEN
        CLOSE C_PD;
      END IF;
      IF C_PI%ISOPEN THEN
        CLOSE C_PI;
      END IF;
      IF C_PICOUNT%ISOPEN THEN
        CLOSE C_PICOUNT;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --������ϸ���㲽��
  PROCEDURE COSTPIID(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                     P_MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                     P_SL       IN NUMBER,
                     PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                     PMD        IN YS_YH_PRICEGROUP%ROWTYPE,
                     RDTAB      IN OUT RD_TABLE,
                     P_CLASSCTL IN CHAR,
                     P_PSCID    IN NUMBER,
                     P_COMMIT   IN NUMBER) IS
    --p_classctl��Y��ǿ�Ʋ�ʹ�ý��ݼƷѷ�����N��������ݣ�����ǵĻ���
    RD        YS_ZW_ARDETAIL%ROWTYPE;
    I         INTEGER;
    V_MONTHS  NUMBER(10);
    N         NUMBER;
    M         NUMBER;
    TEMPADJSL NUMBER(10);
    VPDMETHOD BAS_PRICE_DETAIL.METHOD%TYPE;
    BF        YS_BAS_BOOK%ROWTYPE;
  BEGIN
  
    --���ƽ��ݿ��Ʋ���������ӹ��̣�������1�׽��
    IF P_CLASSCTL = 'Y' AND PD.METHOD IN ('yjt', 'njt') THEN
      VPDMETHOD := 'dj';
    ELSE
      VPDMETHOD := PD.METHOD;
    END IF;
  
    BEGIN
      SELECT ROUND(MONTHS_BETWEEN(TRUNC(P_RL.ARRDATE, 'MM'),
                                  TRUNC(P_RL.ARPRDATE, 'MM')))
        INTO N --�Ʒ�ʱ������
        FROM DUAL;
      IF N <= 0 OR N IS NULL THEN
        N := 1;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        N := 0;
    END;
    SELECT SYS_GUID() INTO RD.ID FROM DUAL;
    RD.HIRE_CODE     := P_RL.HIRE_CODE;
    RD.ARDID         := P_RL.ARID; --��ˮ��
    RD.ARDPMDID      := NVL(PMD.GRPID, 0); --�����ˮ����
    RD.ARDPMDSCALE   := NVL(PMD.GRPSCALE, 1);
    RD.ARDPIID       := PD.PRICE_ITEM; --������Ŀ
    RD.ARDPFID       := PD.PRICE_NO; --����
    RD.ARDPSCID      := PD.PRICE_VER; --������ϸ����
    RD.ARDMETHOD     := VPDMETHOD;
    RD.ARDPAIDFLAG   := 'N';
    RD.ARDYSDJ       := 0;
    RD.ARDYSSL       := 0;
    RD.ARDYSJE       := 0;
    RD.ARDDJ         := 0;
    RD.ARDSL         := 0;
    RD.ARDJE         := 0;
    RD.ARDADJDJ      := 0;
    RD.ARDADJSL      := 0;
    RD.ARDADJJE      := 0;
    RD.ARDMSMFID     := P_RL.MANAGE_NO; --Ӫ����˾
    RD.ARDMONTH      := P_RL.ARMONTH; --�����·�
    RD.ARDMID        := P_RL.SBID; --ˮ����
    RD.ARDPMDTYPE    := NVL(PMD.GRPTYPE, '01'); --������
    RD.ARDPMDCOLUMN1 := PMD.GRPCOLUMN1; --�����ֶ�1
  
    CASE VPDMETHOD
      WHEN '01' THEN
        --�̶�����  Ĭ�Ϸ�ʽ���볭���й�
        BEGIN
          RD.ARDCLASS := 0;
          RD.ARDYSDJ  := PD.PRICE;
          RD.ARDYSSL  := P_SL;
          RD.ARDYSJE  := ROUND(RD.ARDYSDJ * RD.ARDYSSL, 2);
          RD.ARDDJ    := PD.PRICE;
          RD.ARDSL    := P_SL;
          RD.ARDJE    := ROUND(RD.ARDDJ * RD.ARDSL, 2);
          RD.ARDADJDJ := 0;
          RD.ARDADJSL := 0;
          RD.ARDADJJE := RD.ARDJE - RD.ARDYSJE;
          --������ϸ��
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
        END;
      WHEN '02' THEN
        --�̶����볭���޹�
        BEGIN
          RD.ARDCLASS := 0;
          RD.ARDYSDJ  := 0;
          RD.ARDYSSL  := 0;
          RD.ARDADJDJ := 0;
          RD.ARDADJSL := 0;
          RD.ARDADJJE := 0;
          RD.ARDYSDJ  := 0;
          RD.ARDSL    := 0;
        
          IF P_SL > 0 THEN
            RD.ARDYSDJ := ROUND(NVL(PD.MONEY, 0), 2);
            RD.ARDDJ   := ROUND(NVL(PD.MONEY, 0), 2);
            RD.ARDYSJE := ROUND(NVL(PD.MONEY, 0), 2) * N;
            RD.ARDJE   := ROUND(NVL(PD.MONEY, 0), 2) * N;
          ELSE
            RD.ARDYSJE := 0;
            RD.ARDJE   := 0;
          END IF;
          --������ϸ��
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
        END;
      WHEN '03' THEN
        BEGIN
          COSTSTEP_MON(P_RL, P_MR, P_SL, 0, 0, PD, RDTAB, P_CLASSCTL, PMD);
        END;
      WHEN '04' THEN
        BEGIN
          NULL;
          COSTSTEP_YEAR(P_RL,
                        P_SL,
                        0,
                        0,
                        PD,
                        RDTAB,
                        P_CLASSCTL,
                        PMD,
                        P_PSCID);
        END;
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '��֧�ֵļƷѷ���' || VPDMETHOD);
    END CASE;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --�½��ݼƷѲ���
  PROCEDURE COSTSTEP_MON(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                         P_MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                         P_SL       IN NUMBER,
                         P_ADJSL    IN NUMBER,
                         P_ADJDJ    IN NUMBER,
                         PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                         RDTAB      IN OUT RD_TABLE,
                         P_CLASSCTL IN CHAR,
                         PMD        IN YS_YH_PRICEGROUP%ROWTYPE) IS
    --rd.rdpiid��rd.rdpfid��rd.rdpscidΪ��Ҫ����
    CURSOR C_PS IS
      SELECT *
        FROM (SELECT *
                FROM BAS_PRICE_STEP
               WHERE PRICE_VER = PD.PRICE_VER
                 AND PRICE_NO = PD.PRICE_NO
                 AND PRICE_ITEM = PD.PRICE_ITEM)
       ORDER BY STEP_CLASS;
  
    TMPYSSL      NUMBER;
    LASTPSSLPERS NUMBER := 0;
    TMPSL        NUMBER;
    RD           YS_ZW_ARDETAIL%ROWTYPE;
    RD0          YS_ZW_ARDETAIL%ROWTYPE;
    PS           BAS_PRICE_STEP%ROWTYPE;
    PS0          BAS_PRICE_STEP%ROWTYPE;
    MINFO        YS_YH_SBINFO%ROWTYPE;
    N            NUMBER(38, 12); --�Ʒ�����
    TMPSCODE     NUMBER;
  BEGIN
    SELECT SYS_GUID() INTO RD.ID FROM DUAL;
    RD.HIRE_CODE   := P_RL.HIRE_CODE;
    RD.ARDID       := P_RL.ARID;
    RD.ARDPMDID    := NVL(PMD.GRPID, 0);
    RD.ARDPMDSCALE := NVL(PMD.GRPSCALE, 1);
    RD.ARDPIID     := PD.PRICE_ITEM;
    RD.ARDPFID     := PD.PRICE_NO;
    RD.ARDPSCID    := PD.PRICE_VER;
    RD.ARDMETHOD   := PD.METHOD;
    RD.ARDPAIDFLAG := 'N';
  
    RD.ARDMSMFID  := P_RL.MANAGE_NO; --Ӫ����˾
    RD.ARDMONTH   := P_RL.ARMONTH; --�����·�
    RD.ARDMID     := P_RL.SBID; --ˮ����
    RD.ARDPMDTYPE := NVL(PMD.GRPTYPE, '01'); --������
  
    TMPYSSL := P_SL; --�����ۼ�Ӧ��ˮ�����
    TMPSL   := P_SL + P_ADJSL; --�����ۼ�ʵ��ˮ�����
  
    --�ж������Ƿ�������ȡ���ݵ�����
    SELECT MI.* INTO MINFO FROM YS_YH_SBINFO MI WHERE MI.SBID = P_RL.SBID;
  
    --���ݼƷ�����
    --�����(��ÿ�μƷѰ�ʵ�ʼ�������Ʒ�)
    BEGIN
      SELECT ROUND(MONTHS_BETWEEN(TRUNC(P_RL.ARRDATE, 'MM'),
                                  TRUNC(P_RL.ARPRDATE, 'MM')))
        INTO N --�Ʒ�ʱ������
        FROM DUAL;
    
      IF N <= 0 OR N IS NULL THEN
        N := 1; --�쳣���ڶ���һ���½���
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        N := 0;
    END;
  
    P_RL.ARUSENUM := NVL(P_RL.ARUSENUM, 1);
  
    PS0 := NULL;
    RD0 := NULL;
  
    OPEN C_PS;
    FETCH C_PS
      INTO PS;
    IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�Ľ��ݼƷ�����');
    END IF;
    WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
      -->=0��֤0��ˮ����һ��������ϸ
      /*
      ��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
      �����ݹ��򣨻�/�˾���ˮ����ͬһ��ַ������ˮ����ˮ��֮��Ϊ�������㣩                      ��
      ��1����ͥ�����˿���4�����£���4�ˣ�����ˮ����������ˮ�����ֽ���ʽ����ˮ�ۡ�                      ��
      ��2����ͥ�����˿���5�ˣ���5�ˣ����ϵ���ˮ�������˾���ˮ�����ֽ���ʽ����ˮ�ۡ�                    ��
      ���������������������ة����������������������������������������������ة����������������������������������������������������������������������ة���������������������������������������������������
      */ --һ��ֹ������Ҫ������ֵ��ͬ����������
      P_RL.ARUSENUM := (CASE
                         WHEN NVL(P_RL.ARUSENUM, 0) < PS.PEOPLES THEN
                          PS.PEOPLES
                         ELSE
                          P_RL.ARUSENUM
                       END);
      IF PS.STEP_CLASS > 1 THEN
        PS.START_CODE := TMPSCODE;
      END IF;
      PS.END_CODE  := CEIL(N * (PS.END_CODE +
                           GETMAX(P_RL.ARUSENUM - PS.PEOPLES, 0) *
                           PS.ADD_WATERQTY + LASTPSSLPERS)); --���ݶ�ֹ����
      TMPSCODE     := PS.END_CODE;
      LASTPSSLPERS := GETMAX(P_RL.ARUSENUM - PS.PEOPLES, 0) *
                      PS.ADD_WATERQTY;
      --����CEIL�����룬���������ӽ��ݶΣ�������ͻ�
      RD.ARDCLASS      := PS.STEP_CLASS;
      RD.ARDYSDJ       := PS.PRICE;
      RD.ARDYSSL       := GETMIN(TMPYSSL, PS.END_CODE - PS.START_CODE);
      RD.ARDYSJE       := ROUND(RD.ARDYSDJ * RD.ARDYSSL, 2);
      RD.ARDDJ         := GETMAX(PS.PRICE + P_ADJDJ, 0);
      RD.ARDSL         := GETMIN(TMPSL, PS.END_CODE - PS.START_CODE);
      RD.ARDJE         := ROUND(RD.ARDDJ * RD.ARDSL, 2);
      RD.ARDADJDJ      := RD.ARDDJ - RD.ARDYSDJ;
      RD.ARDADJSL      := RD.ARDSL - RD.ARDYSSL;
      RD.ARDADJJE      := RD.ARDJE - RD.ARDYSJE;
      RD.ARDPMDCOLUMN1 := TO_CHAR(ROUND(N, 2));
      RD.ARDPMDCOLUMN2 := PS.START_CODE;
      RD.ARDPMDCOLUMN3 := PS.END_CODE;
      --������ϸ��
      IF RDTAB IS NULL THEN
        RDTAB := RD_TABLE(RD);
      ELSE
        RDTAB.EXTEND;
        RDTAB(RDTAB.LAST) := RD;
      END IF;
      --�ۼ��������һ���α�
      TMPYSSL := GETMAX(TMPYSSL - RD.ARDYSSL, 0);
      TMPSL   := GETMAX(TMPSL - RD.ARDYSSL, 0);
      EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
      FETCH C_PS
        INTO PS;
    END LOOP;
    CLOSE C_PS;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_PS%ISOPEN THEN
        CLOSE C_PS;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --
  PROCEDURE COSTSTEP_YEAR(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                          P_SL       IN NUMBER,
                          P_ADJSL    IN NUMBER,
                          P_ADJDJ    IN NUMBER,
                          PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                          RDTAB      IN OUT RD_TABLE,
                          P_CLASSCTL IN CHAR,
                          PMD        YS_YH_PRICEGROUP%ROWTYPE,
                          PMONTH     IN VARCHAR2) IS
    --rd.ardpiid��rd.ardpfid��rd.ardpscidΪ��Ҫ����
    CURSOR C_PS IS
      SELECT *
        FROM (SELECT *
                FROM BAS_PRICE_STEP
               WHERE PRICE_VER = PD.PRICE_VER
                 AND PRICE_NO = PD.PRICE_NO
                 AND PRICE_ITEM = PD.PRICE_ITEM)
       ORDER BY STEP_CLASS;
  
    TMPYSSL        NUMBER;
    TMPSL          NUMBER;
    RD             YS_ZW_ARDETAIL%ROWTYPE;
    PS             BAS_PRICE_STEP%ROWTYPE;
    MI             YS_YH_SBINFO%ROWTYPE;
    TMPSCODE       NUMBER;
    LASTPSSLPERS   NUMBER := 0;
    N              NUMBER; --�Ʒ�����
    ���ۼ�����ˮ�� NUMBER;
    ���ۼ�Ӧ��ˮ�� NUMBER;
    ���ۼ�ʵ��ˮ�� NUMBER;
  BEGIN
    SELECT SYS_GUID() INTO RD.ID FROM DUAL;
    RD.HIRE_CODE   := P_RL.HIRE_CODE;
    RD.ARDID       := P_RL.ARID;
    RD.ARDPMDID    := NVL(PMD.GRPID, 0);
    RD.ARDPMDSCALE := NVL(PMD.GRPSCALE, 1);
    RD.ARDPIID     := PD.PRICE_ITEM;
    RD.ARDPFID     := PD.PRICE_NO;
    RD.ARDPSCID    := PD.PRICE_VER;
    RD.ARDMETHOD   := PD.METHOD;
    RD.ARDPAIDFLAG := 'N';
  
    RD.ARDMSMFID  := P_RL.MANAGE_NO; --Ӫ����˾
    RD.ARDMONTH   := P_RL.ARMONTH; --�����·�
    RD.ARDMID     := P_RL.SBID; --ˮ����
    RD.ARDPMDTYPE := NVL(PMD.GRPTYPE, '01'); --������
  
    TMPYSSL := P_SL; --�����ۼ�Ӧ��ˮ�����
    TMPSL   := P_SL + P_ADJSL; --�����ۼ�ʵ��ˮ�����
  
    --�ж������Ƿ�������ȡ���ݵ�����
    SELECT * INTO MI FROM YS_YH_SBINFO WHERE SBID = P_RL.SBID;
  
    --ʵʱ�������ۼ�����ˮ��
    ���ۼ�����ˮ�� := ʵʱ�������ۼ�������(MI.SBID, TRUNC(SYSDATE, 'YYYY'));
    --���뱾������
    ���ۼ�Ӧ��ˮ�� := GETMAX(TO_NUMBER(NVL(���ۼ�����ˮ��, 0)), 0) + TMPYSSL;
    ���ۼ�ʵ��ˮ�� := GETMAX(TO_NUMBER(NVL(���ۼ�����ˮ��, 0)), 0) + TMPSL;
  
    OPEN C_PS;
    FETCH C_PS
      INTO PS;
    IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�Ľ��ݼƷ�����');
    END IF;
    WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
    
      P_RL.ARUSENUM := (CASE
                         WHEN NVL(P_RL.ARUSENUM, 0) < PS.PEOPLES THEN
                          PS.PEOPLES
                         ELSE
                          P_RL.ARUSENUM
                       END);
      IF PS.STEP_CLASS > 1 THEN
        PS.START_CODE := TMPSCODE;
      END IF;
      PS.END_CODE      := PS.END_CODE +
                          GETMAX(P_RL.ARUSENUM - PS.PEOPLES, 0) *
                          PS.ADD_WATERQTY + LASTPSSLPERS; --���ݶ�ֹ����
      TMPSCODE         := PS.END_CODE;
      LASTPSSLPERS     := GETMAX(P_RL.ARUSENUM - PS.PEOPLES, 0) *
                          PS.PEOPLES;
      RD.ARDPMDCOLUMN1 := PS.START_CODE;
      RD.ARDPMDCOLUMN2 := PS.END_CODE;
      RD.ARDCLASS      := PS.STEP_CLASS;
    
      RD.ARDYSDJ := PS.PRICE;
      RD.ARDYSSL := CASE
                      WHEN P_CLASSCTL = 'Y' THEN
                       TMPYSSL
                      ELSE
                       CASE
                         WHEN ���ۼ�Ӧ��ˮ�� >= PS.START_CODE AND ���ۼ�Ӧ��ˮ�� <= PS.END_CODE THEN
                          ���ۼ�Ӧ��ˮ�� -
                          GETMAX(TO_NUMBER(NVL(���ۼ�����ˮ��, 0)), PS.START_CODE)
                         WHEN ���ۼ�Ӧ��ˮ�� > PS.END_CODE THEN
                          GETMAX(0,
                                 GETMIN(PS.END_CODE -
                                        TO_NUMBER(NVL(���ۼ�����ˮ��, 0)),
                                        PS.END_CODE - PS.START_CODE))
                         ELSE
                          0
                       END
                    END;
      RD.ARDYSJE := RD.ARDYSDJ * RD.ARDYSSL;
    
      RD.ARDDJ := GETMAX(PS.PRICE + P_ADJDJ, 0);
      RD.ARDSL := CASE
                    WHEN P_CLASSCTL = 'Y' THEN
                     TMPSL
                    ELSE
                     CASE
                       WHEN ���ۼ�ʵ��ˮ�� >= PS.START_CODE AND ���ۼ�ʵ��ˮ�� <= PS.END_CODE THEN
                        ���ۼ�ʵ��ˮ�� -
                        GETMAX(TO_NUMBER(NVL(���ۼ�����ˮ��, 0)), PS.START_CODE)
                       WHEN ���ۼ�ʵ��ˮ�� > PS.END_CODE THEN
                        GETMAX(0,
                               GETMIN(PS.END_CODE - TO_NUMBER(NVL(���ۼ�����ˮ��, 0)),
                                      PS.END_CODE - PS.START_CODE))
                       ELSE
                        0
                     END
                  END;
      RD.ARDJE := ROUND(RD.ARDDJ * RD.ARDSL, 2); --ʵ�ս��
    
      RD.ARDADJDJ := RD.ARDDJ - RD.ARDYSDJ;
      RD.ARDADJSL := RD.ARDSL - RD.ARDYSSL;
      RD.ARDADJJE := RD.ARDJE - RD.ARDYSJE;
    
      --������ϸ��
      IF RDTAB IS NULL THEN
        RDTAB := RD_TABLE(RD);
      ELSE
        RDTAB.EXTEND;
        RDTAB(RDTAB.LAST) := RD;
      END IF;
      --����
      P_RL.ARJE := P_RL.ARJE + RD.ARDJE;
      P_RL.ARSL := P_RL.ARSL + (CASE
                     WHEN RD.ARDPIID = '01' THEN
                      RD.ARDSL
                     ELSE
                      0
                   END);
      --�ۼ��������һ���α�
      TMPYSSL := GETMAX(TMPYSSL - RD.ARDYSSL, 0);
      TMPSL   := GETMAX(TMPSL - RD.ARDSL, 0);
      EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
      FETCH C_PS
        INTO PS;
    END LOOP;
    CLOSE C_PS;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_PS%ISOPEN THEN
        CLOSE C_PS;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --
  PROCEDURE INSRD(RD IN RD_TABLE, P_COMMIT IN NUMBER) IS
    VRD YS_ZW_ARDETAIL%ROWTYPE;
    I   NUMBER;
  BEGIN
    FOR I IN RD.FIRST .. RD.LAST LOOP
      VRD := RD(I);
      IF P_COMMIT != ���� THEN
        INSERT INTO YS_ZW_ARDETAIL VALUES VRD;
      ELSE
        INSERT INTO YS_ZW_ARDETAIL_BUDGET VALUES VRD;
        INSERT INTO YS_ZW_ARDETAIL_virtual VALUES VRD;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --
  FUNCTION GETMIN(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NVL(N1, 0) <= NVL(N2, 0) THEN
      RETURN NVL(N1, 0);
    ELSE
      RETURN NVL(N2, 0);
    END IF;
  END GETMIN;

  FUNCTION GETMAX(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NVL(N1, 0) >= NVL(N2, 0) THEN
      RETURN NVL(N1, 0);
    ELSE
      RETURN NVL(N2, 0);
    END IF;
  END GETMAX;
  FUNCTION FBOUNDPARA(P_PARASTR IN CLOB) RETURN INTEGER IS
    --һά�������#####,####,####|
    --��ά�������#####,####,####|#####,####,#######|##,####,####|
    I     INTEGER;
    N     INTEGER := 0;
    VCHAR NCHAR(1);
  BEGIN
    FOR I IN 1 .. LENGTH(P_PARASTR) LOOP
      VCHAR := SUBSTR(P_PARASTR, I, 1);
      IF VCHAR = '|' THEN
        N := N + 1;
      END IF;
    END LOOP;
  
    RETURN N;
  END;
  FUNCTION FGETPARA(P_PARASTR IN VARCHAR2,
                    ROWN      IN INTEGER,
                    COLN      IN INTEGER) RETURN VARCHAR2 IS
    --һά�������#####|####|####|
    --��ά�������#####,####,####|#####,####,#######|##,####,####|
    VCHAR NCHAR(1);
    V     VARCHAR2(10000);
    VSTR  VARCHAR2(10000) := '';
    R     INTEGER := 1;
    C     INTEGER := 0;
  BEGIN
    V := TRIM(P_PARASTR);
    IF LENGTH(V) = 0 OR SUBSTR(V, LENGTH(V)) != '|' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����ַ�����ʽ����' || P_PARASTR);
    END IF;
    FOR I IN 1 .. LENGTH(V) LOOP
      VCHAR := SUBSTR(V, I, 1);
      CASE VCHAR
        WHEN '|' THEN
          --һ�ж���
          BEGIN
            C := C + 1;
            IF R = ROWN AND C = COLN THEN
              RETURN VSTR;
            END IF;
            R    := R + 1;
            C    := 0;
            VSTR := '';
          END;
        WHEN ',' THEN
          --һ�ж���
          BEGIN
            C := C + 1;
            IF R = ROWN AND C = COLN THEN
              RETURN VSTR;
            END IF;
            VSTR := '';
          END;
        ELSE
          BEGIN
            VSTR := VSTR || VCHAR;
          END;
      END CASE;
    END LOOP;
  
    RETURN '';
  END;
  --Ԥ��ѣ��ṩ׷����Ӧ�յ������˷ѵ�����������м�����
 PROCEDURE SUBMIT_VIRTUAL(p_mid    in varchar2,
                           p_prdate in date,
                           p_rdate  in date,
                           p_scode  in number,
                           p_ecode  in number,
                           p_sl     in number,
                           p_rper   in varchar2,
                           p_pfid   in varchar2,
                           p_usenum in number,
                           p_trans  in varchar2,
                           o_rlid   out varchar2) IS 
    cb Ys_Cb_Mtread%ROWTYPE; --������ʷ��
    mi ys_yh_sbinfo%rowtype;
  BEGIN
    delete ys_zw_arlist_virtual;
    delete ys_zw_ardetail_virtual;
    BEGIN
      select * into mi from ys_yh_sbinfo where SBID = p_mid; 
      cb.id            := '?'; --varchar2(10)  ��ˮ�� 
      cb.CBMRMONTH         := to_char(p_rdate, 'yyyy.mm'); --varchar2(7)  �����·�
      cb.MANAGE_NO         := mi.MANAGE_NO; --varchar2(10)  Ӫ����˾
      cb.BOOK_NO          := mi.BOOK_NO; --varchar2(10)  ��� 
      cb.cbmrbatch         := null; --number(20)  ��������
      cb.cbmrday           := null; --date  �ƻ�������
      cb.cbmrrorder        := null; --number(10)  �������
      cb.YHID           := p_mid; --varchar2(10)  �û���� 
      cb.SBID           := p_mid; --varchar2(10)  ˮ���� 
      cb.TRADE_NO          := null; --varchar2(10)  ��ҵ����
      cb.SBPID          := null; --varchar2(10)  �ϼ�ˮ��
      cb.CBMRMCLASS        := null; --number  ˮ����
      cb.cbmrmflag         := null; --char(1)  ĩ����־
      cb.cbmrcreadate      := p_rdate; --date  ��������
      cb.cbmrinputdate     := p_rdate; --date  �༭����
      cb.cbmrreadok        := 'Y'; --char(1)  ������־
      cb.cbmrrdate         := p_rdate; --date  ��������
      cb.cbmrrper          := p_rper; --varchar2(15)  ����Ա
      cb.cbmrprdate        := p_prdate; --date  �ϴγ�������
      cb.cbmrscode         := p_scode; --number(10)  ���ڳ���
      cb.cbmrecode         := p_ecode; --number(10)  ���ڳ���
      cb.cbmrsl            := p_sl; --number(10)  ����ˮ��
      cb.cbmrface          := null; --varchar2(2)  ˮ�����
      cb.cbmrifsubmit      := 'Y'; --char(1)  �Ƿ��ύ�Ʒ�
      cb.cbmrifhalt        := null; --char(1)  ϵͳͣ��
      cb.cbmrdatasource    := null; --char(1)  ��������Դ
      cb.cbmrifignoreminsl := null; --char(1)  ͣ����ͳ���
      cb.cbmrpdardate      := null; --date  ���������ʱ��
      cb.cbmroutflag       := null; --char(1)  �������������־
      cb.cbmroutid         := null; --varchar2(10)  �������������ˮ��
      cb.cbmroutdate       := null; --date  ���������������
      cb.cbmrinorder       := null; --number(4)  ��������մ���
      cb.cbmrindate        := null; --date  �������������
      cb.cbmrrpid          := null; --varchar2(3)  �Ƽ�����
      cb.cbmrmemo          := null; --varchar2(120)  ����ע
      cb.cbmrifgu          := null; --char(1)  �����־
      cb.cbmrifrec         := null; --char(1)  �ѼƷ�
      cb.cbmrrecdate       := null; --date  �Ʒ�����
      cb.cbmrrecsl         := p_sl; --number(10)  Ӧ��ˮ��
      cb.cbmraddsl         := null; --number(10)  ����
      cb.cbmrcarrysl       := null; --number(10)  У��ˮ��
      cb.cbmrctrl1         := null; --varchar2(10)  ���������λ1
      cb.cbmrctrl2         := null; --varchar2(10)  ���������λ2
      cb.cbmrctrl3         := null; --varchar2(10)  ���������λ3
      cb.cbmrctrl4         := null; --varchar2(10)  ���������λ4
      cb.cbmrctrl5         := null; --varchar2(10)  �����ݺ�
      cb.cbmrchkflag       := null; --char(1)  ���˱�־
      cb.cbmrchkdate       := null; --date  ��������
      cb.cbmrchkper        := null; --varchar2(10)  ������Ա
      cb.cbmrchkscode      := null; --number(10)  ԭ����
      cb.cbmrchkecode      := null; --number(10)  ԭֹ��
      cb.cbmrchksl         := null; --number(10)  ԭˮ��
      cb.cbmrchkaddsl      := null; --number(10)  ԭ����
      cb.cbmrchkcarrysl    := null; --number(10)  ԭ��λˮ��
      cb.cbmrchkrdate      := null; --date  ԭ��������
      cb.cbmrchkface       := null; --varchar2(2)  ԭ���
      cb.cbmrchkresult     := null; --varchar2(100)  ���������
      cb.cbmrchkresultmemo := null; --varchar2(100)  �����˵��
      cb.cbmrprimid        := null; --varchar2(200)  ���ձ�����
      cb.cbmrprimflag      := null; --char(1)  ���ձ��־
      cb.cbmrlb            := null; --char(1)  ˮ�����
      cb.cbmrnewflag       := null; --char(1)  �±��־
      cb.cbmrface2         := null; --varchar2(2)  ��������
      cb.cbmrface3         := null; --varchar2(2)  �ǳ�����
      cb.cbmrface4         := null; --varchar2(2)  ����ʩ˵��
      cb.cbmrscodechar     := p_scode; --varchar2(10)  ���ڳ���
      cb.cbmrecodechar     := p_ecode; --varchar2(10)  ���ڳ���
      cb.cbmrprivilegeflag := null; --varchar2(1)  ��Ȩ��־(y/n)
      cb.cbmrprivilegeper  := null; --varchar2(10)  ��Ȩ������
      cb.cbmrprivilegememo := null; --varchar2(200)  ��Ȩ������ע
      cb.cbmrprivilegedate := null; --date  ��Ȩ����ʱ��
      cb.AREA_NO         := null; --varchar2(10)  ��������
      cb.cbmriftrans       := null; --char(1)  ��������
      cb.cbmrrequisition   := null; --number(2)  ֪ͨ����ӡ����
      cb.cbmrifchk         := null; --char(1)  ���˱�
      cb.cbmrinputper      := null; --varchar2(10)  ������Ա
      cb.Price_No          := p_pfid; --varchar2(10)  ��ˮ���
      cb.cbmrcaliber       := null; --number(10)  �ھ�
      cb.cbmrside          := null; --varchar2(100)  ��λ
      cb.cbmrlastsl        := null; --number(10)  �ϴγ���ˮ��
      cb.cbmrthreesl       := null; --number(10)  ǰ���³���ˮ��
      cb.cbmryearsl        := null; --number(10)  ȥ��ͬ�ڳ���ˮ��
      cb.cbmrrecje01       := null; --number(13,3)  Ӧ�ս�������Ŀ01
      cb.cbmrrecje02       := null; --number(13,3)  Ӧ�ս�������Ŀ02
      cb.cbmrrecje03       := null; --number(13,3)  Ӧ�ս�������Ŀ03
      cb.cbmrrecje04       := null; --number(13,3)  Ӧ�ս�������Ŀ04
      cb.cbmrmtype         := null; --varchar2(10)  ����
      cb.cbmrnullcont      := null; --number(10)  ��������δ����
      cb.cbmrnulltotal     := null; --number(10)  �ۼƼ���δ����
      cb.cbmrplansl        := null; --number(18,8)  �ƻ�ˮ��
      cb.cbmrplanje01      := null; --number(18,8)  �ƻ�ˮ��
      cb.cbmrplanje02      := null; --number(18,8)  �ƻ���ˮ�����
      cb.cbmrplanje03      := null; --number(18,8)  �ƻ�ˮ��Դ��
      cb.cbmrlastje01      := null; --number(13,3)  �ϴ�ˮ��
      cb.cbmrthreeje01     := null; --number(13,3)  ǰn�ξ�ˮ��
      cb.cbmryearje01      := null; --number(13,3)  ȥ��ͬ��ˮ��
      cb.cbmrlastje02      := null; --number(13,3)  �ϴ���ˮ��
      cb.cbmrthreeje02     := null; --number(13,3)  ǰn�ξ���ˮ��
      cb.cbmryearje02      := null; --number(13,3)  ȥ��ͬ����ˮ��
      cb.cbmrlastje03      := null; --number(13,3)  �ϴ�ˮ��Դ��
      cb.cbmrthreeje03     := null; --number(13,3)  ǰn�ξ�ˮ��Դ��
      cb.cbmryearje03      := null; --number(13,3)  ȥ��ͬ��ˮ��Դ��
      cb.cbmrlastyearsl    := null; --number(10)  ȥ��ȴξ���
      cb.cbmrlastyearje01  := null; --number(13,3)  ȥ��ȴξ�ˮ��
      cb.cbmrlastyearje02  := null; --number(13,3)  ȥ��ȴξ���ˮ��
      cb.cbmrlastyearje03  := null; --number(13,3)  ȥ��ȴξ�ˮ��Դ��  
      --
      COSTCULATECORE(cb, p_trans, 'ָ��', ����);
      --20150414 Ӧ��׷��Ԥ���֧����ʷˮ�����
      --CALCULATE(cb, p_trans, to_char(p_rdate,'yyyy.mm'), ����);

      o_rlid := cb.cbmrprivilegeper;
    EXCEPTION
      WHEN OTHERS THEN
        /*WLOG(p_mid || ',' || p_prdate || ',' || p_rdate || ',' || p_sl || ',' ||
             p_pfid || ',' || p_usenum || ',' || p_trans || 'Ԥ���ʧ��2���ѱ�����' ||
             sqlerrm);*/
              RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    END;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

 BEGIN
  �ܱ����     := 'Y';
  ������ˮ�� := 0;
END;
/

