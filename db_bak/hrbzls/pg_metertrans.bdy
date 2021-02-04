CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_METERTRANS" IS

  CURRENTDATE  DATE := TOOLS.FGETSYSDATE;
  ������ˮ�� NUMBER(10);
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2) IS
    O_MRID VARCHAR2(200);
  BEGIN
    IF upper(P_DJLB) ='L' or upper(P_DJLB) ='F' THEN --���ڻ���������� ��������
        SP_METERTRANS_ZQHB(P_DJLB, P_BILLNO, P_PERSON, 'N');
      --  SP_BILLSUBMIT(P_BILLNO, O_MRID);
       ELSIF P_DJLB = '25' THEN
      SP_METERDZ(P_BILLNO, P_PERSON,'Y'); --���봦��
    ELSE
        SP_METERTRANS(P_DJLB, P_BILLNO, P_PERSON, 'N');
        SP_BILLSUBMIT(P_BILLNO, O_MRID);
     END IF ;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      -- raise_application_error(errcode,sqlerrm);
  END APPROVE;

  --����������
  PROCEDURE SP_METERTRANS(P_TYPE   IN VARCHAR2, --��������
                          P_MTHNO  IN VARCHAR2, --������ˮ
                          P_PER    IN VARCHAR2, --����Ա
                          P_COMMIT IN VARCHAR2 --�ύ��־
                          ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_MTHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�����ͷ��Ϣ������!');
    END;
    
    --byj update 2016.10.21
    IF mh.mthshflag = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѿ����,�����ظ����!');
    END IF;

    /*BEGIN
      SELECT * INTO MD FROM METERTRANSDT WHERE MTDNO = P_MTHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '������Ϣ��ϸֻ����һ������,���������ϻ����һ������!');
    END;*/

    --������Ϣ�Ѿ���˲�������
    /*IF MD.MTDFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѿ����,�����ظ����!');
    END IF;*/
    ----
    
    for md in (SELECT * FROM METERTRANSDT WHERE MTDNO = P_MTHNO) loop
        SP_METERTRANSONE(P_TYPE, P_PER, MD);
        IF P_TYPE in('F') THEN
          --�ɱ�״̬
          update st_meterinfo_store set status='4',MIID='' where bsm=MD.MTDMNOO;
          --�������ɱ����з������
          UPDATE ST_METERFH_STORE
               SET FHSTATUS = '2',
                   MAINMAN  = FGETPBOPER,
                   MAINDATE = SYSDATE
             WHERE BSM=MD.MTDMNOO
             AND FHSTATUS = '1';
        END IF;    
        IF P_TYPE in('L','K') THEN
          --�ɱ�״̬
          update st_meterinfo_store set status='4',MIID='' where bsm=MD.MTDMNOO;
          --���ϻ������ڻ���ɱ����з������
          UPDATE ST_METERFH_STORE
               SET FHSTATUS = '2',
                   MAINMAN  = FGETPBOPER,
                   MAINDATE = SYSDATE
             WHERE BSM=MD.MTDMNOO
             AND FHSTATUS = '1';
          --�±�״̬
          update st_meterinfo_store set status='3',miid=MD.MTDMCODE WHERE bsm=MD.MTDMNON;
          
          --����������̬
          UPDATE METERINFO T
             SET T.MISTATUS  = '1', T.MICOLUMN5  = NULL
           WHERE T.MIID = MD.MTDMID;
          --ȥ�������־
          UPDATE METERDOC T SET T.IFDZSB = 'N' WHERE T.MDMID = MD.MTDMID;
        END IF;    
        IF P_TYPE = 'A' THEN
           UPDATE METERINFO T
             SET T.MIIFCHK = 'Y', T.MIIFCHARGE = 'N'
           WHERE T.MIID = MD.MTDMID;
        END IF;    
    end loop;
             
    UPDATE METERTRANSDT
       SET MTDFLAG = 'Y' /*,MTBK8='Y'*/
     WHERE MTDNO = P_MTHNO;
    UPDATE METERTRANSHD
       SET MTHSHDATE = SYSDATE, MTHSHPER = P_PER, MTHSHFLAG = 'Y'
     WHERE MTHNO = P_MTHNO;
    INSERT INTO METERTRANSSTATES
      (MTSNO, MTSSHDATE, MTSSHFLAG, MTSSHPER, MTSCREDATE)
      SELECT MTHNO, MTHSHDATE, MTHSHFLAG, MTHSHPER, MTHCREDATE
        FROM METERTRANSHD
       WHERE MTHNO = P_MTHNO;
    
    --��������
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_MTHNO);
     
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

 --����������
  PROCEDURE SP_METERTRANS_ZQHB(P_TYPE   IN VARCHAR2, --��������
                          P_MTHNO  IN VARCHAR2, --������ˮ
                          P_PER    IN VARCHAR2, --����Ա
                          P_COMMIT IN VARCHAR2 --�ύ��־
                          ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_MTHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�����ͷ��Ϣ������!');
    END; 
   --    20140815 ������Ϣ�Ѿ���˲������� ���ñ�ͷ�ж�
    IF MH.MTHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѿ����,�����ظ����!');
    END IF;
     
  --20140815�����ڻ�����ִ��ʱ����������Ե���ִ�У���ȡ������д
/*    BEGIN
      SELECT * INTO MD FROM METERTRANSDT WHERE MTDNO = P_MTHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '������Ϣ������!');
    END;  
   --������Ϣ�Ѿ���˲�������
    IF MD.MTDFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѿ����,�����ظ����!');
    END IF;*/
    ----
    for v_cursor in ( SELECT *  FROM METERTRANSDT WHERE MTDNO = P_MTHNO ) loop  
        BEGIN   
          SELECT * 
          into MD 
          FROM METERTRANSDT 
          WHERE MTDNO = P_MTHNO and mtdrowno =v_cursor.Mtdrowno;
        EXCEPTION 
          WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(ERRCODE, '������ϸ��Ϣ������!');
          END ; 
      SP_METERTRANSONE(P_TYPE, P_PER, MD); 
      ----------------������״̬�ı�   
      IF P_TYPE in('F') THEN
        --�ɱ�״̬
        update st_meterinfo_store set status='4',MIID='' where bsm=MD.MTDMNOO;
        --�������ɱ����з������
        UPDATE ST_METERFH_STORE
             SET FHSTATUS = '2',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE BSM=MD.MTDMNOO
           AND FHSTATUS = '1';
      END IF;
      IF P_TYPE in('L','K') THEN
        --�ɱ�״̬
        update st_meterinfo_store set status='4',MIID='' where bsm=MD.MTDMNOO;
        --���ϻ������ڻ���ɱ����з������
        UPDATE ST_METERFH_STORE
             SET FHSTATUS = '2',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE BSM=MD.MTDMNOO
           AND FHSTATUS = '1';
        --�±�״̬
        update st_meterinfo_store set status='3',miid=MD.MTDMCODE WHERE bsm=MD.MTDMNON;
      END IF;
      -----------------
      IF P_TYPE = 'A' THEN
        UPDATE METERINFO T
           SET T.MIIFCHK = 'Y', T.MIIFCHARGE = 'N'
         WHERE T.MIID = MD.MTDMID;
      END IF;
      
      --�Ⳮ������װˮ�� ���ϻ������ڻ����Ϊ������
      IF P_TYPE  in('L','K')  THEN
        --����������̬
        UPDATE METERINFO T
           SET T.MISTATUS  = '1', T.MICOLUMN5  = NULL
         WHERE T.MIID = MD.MTDMID;
         --ȥ�������־
         UPDATE METERDOC T SET T.IFDZSB = 'N' WHERE T.MDMID = MD.MTDMID;
      END IF; 
    end loop ;
    
   UPDATE METERTRANSDT
       SET MTDFLAG = 'Y' /*,MTBK8='Y'*/
     WHERE MTDNO = P_MTHNO;
     
    UPDATE METERTRANSHD
       SET MTHSHDATE = SYSDATE, MTHSHPER = P_PER, MTHSHFLAG = 'Y'
     WHERE MTHNO = P_MTHNO;
     
    INSERT INTO METERTRANSSTATES
      (MTSNO, MTSSHDATE, MTSSHFLAG, MTSSHPER, MTSCREDATE)
      SELECT MTHNO, MTHSHDATE, MTHSHFLAG, MTHSHPER, MTHCREDATE
        FROM METERTRANSHD
       WHERE MTHNO = P_MTHNO;
       
    --��������
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_MTHNO);
     
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  
  --����������˹���
  PROCEDURE SP_METERTRANSONE(P_TYPE   IN VARCHAR2, --����
                             P_PERSON IN VARCHAR2, -- ����Ա
                             P_MD     IN METERTRANSDT%ROWTYPE --�����б��
                             ) AS
    MH            METERTRANSHD%ROWTYPE;
    MD            METERTRANSDT%ROWTYPE;
    MI            METERINFO%ROWTYPE;
    CI            CUSTINFO%ROWTYPE;
    MC            METERDOC%ROWTYPE;
    MA            METERADDSL%ROWTYPE;
    MK            METERTRANSROLLBACK%ROWTYPE;
    v_mrmemo       meterread.mrmemo%type;
    V_COUNT       NUMBER(4);
    V_COUNTMRID   NUMBER(4);
    V_COUNTFLAG    NUMBER(4);
    V_NUMBER      NUMBER(10);
    v_rcode       NUMBER(10);
    V_CRHNO       VARCHAR2(10);
    V_OMRID       VARCHAR2(20);
    O_STR         VARCHAR2(20);
    V_METERSTATUS METERSTATUS%ROWTYPE;
    v_meterstore  st_meterinfo_store%rowType;
    
    --δ��ѳ����¼
    cursor cur_meterread_nocalc(p_mrmid varchar2,p_mrmonth varchar2) is 
      select * from meterread mr where mr.mrmid = p_mrmid and mr.mrmonth = p_mrmonth;
    
  BEGIN
    BEGIN
      SELECT * INTO MI FROM METERINFO WHERE MIID = P_MD.MTDMID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ�����ϲ�����!');
    END;
    BEGIN
      SELECT * INTO CI FROM CUSTINFO WHERE CUSTINFO.CIID = MI.MICID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�û����ϲ�����!');
    END;
    BEGIN
      SELECT * INTO MC FROM METERDOC WHERE MDMID = P_MD.MTDMID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ������!');
    END;

    IF MI.MIRCODE != MD.MTDSCODE THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���ڳ��������仯�����������ڳ���');
    END IF;

    IF FSYSPARA('sys4') = 'Y' THEN
      BEGIN
        SELECT STATUS
          INTO V_METERSTATUS.SID
          FROM ST_METERINFO_STORE
         WHERE BSM = P_MD.MTDMNON;

      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF TRIM(V_METERSTATUS.SID) <> '2' THEN
        SELECT SNAME
          INTO V_METERSTATUS.SNAME
          FROM METERSTATUS
         WHERE SID = V_METERSTATUS.SID;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                MI.MICID||'��ˮ��״̬Ϊ��' || V_METERSTATUS.SNAME ||
                                '������ʹ�ã�');
      END IF;
    END IF;

    --F�������
    IF P_TYPE = BT������� THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      update METERINFO
         set MISTATUS      = m����,
             MISTATUSDATE  = sysdate,
             MISTATUSTRANS = P_TYPE,
             MIUNINSDATE   = sysdate,
             MIBFID = NULL   -- by 20170904 wlj �����������ÿ�
       where MIID = P_MD.Mtdmid;

       --������ͬ���û�״̬
        UPDATE CUSTINFO
           SET CISTATUS = m����,
           cistatusdate = sysdate,
           cistatustrans = P_TYPE
         WHERE CICODE = P_MD.Mtdmid;

      ---���������ȡ����ˮ�ѣ���ȥ���Ͷ�֮ǰ��
      --step1 ���볭���¼

      --step2  ����Ӧ�ռ�¼

      --ȥ���Ͷ�[20110702]
      UPDATE PRICEADJUSTLIST PL
         SET PL.PALSTATUS = 'N'
       WHERE PL.PALMID = P_MD.MTDMID;

      --���ݼ�¼�ع���Ϣ
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;
      MK.MTRBID           := P_MD.MTDNO; --������ˮ
      MK.MTRBROWNO        := P_MD.MTDROWNO; --�к�
      MK.MTRBDATE         := SYSDATE; --�ع���������
      MK.MTRBSTATUS       := MI.MISTATUS; --״̬
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --״̬����
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --״̬����
      MK.MTRBRCODE        := MI.MIRCODE; --���ڶ���
      MK.MTRBADR          := MI.MIADR; --���ַ
      MK.MTRBSIDE         := MI.MISIDE; --��λ
      MK.MTRBPOSITION     := MI.MIPOSITION; --ˮ���ˮ��ַ
      MK.MTRBINSCODE      := MI.MIINSCODE; --��װ���
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --�������
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --��������
      MK.MTRBREINSPER     := MI.MIREINSPER; --������
      MK.MTRBCSTATUS      := CI.CISTATUS; --�û�״̬
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --״̬����
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --״̬����
      MK.MTRBNO           := MC.MDNO; --������
      MK.MTRBCALIBER      := MC.MDCALIBER; --��ھ�
      MK.MTRBBRAND        := MC.MDBRAND; --����
      MK.MTRBMODEL        := MC.MDMODEL; --���ͺ�
      MK.MTRBMSTATUS      := MC.MDSTATUS; --��״̬
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --METERDOC  ��״̬ ��״̬����ʱ��
      update METERDOC
         set MDSTATUS = m����, MDSTATUSDATE = sysdate
       where MDMID = P_MD.Mtdmid;
      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
      MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
      MA.MASCREDATE   := SYSDATE; --��������
      MA.MASCID       := MI.MICID; --�û����
      MA.MASMID       := MI.MIID; --ˮ����
      MA.MASSL        := P_MD.MTDADDSL; --����
      MA.MASCREPER    := P_PERSON; --������Ա
      MA.MASTRANS     := P_TYPE; --�ӵ�����
      MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
      MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
      INSERT INTO METERADDSL VALUES MA;
      ----���Ӳ�����ݵ�ʵʱ��
      BEGIN
        PG_EWIDE_CUSTBASE_01.SUM$DAY$METER(MI.MIID, '7', 'N');
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      ---- METERINFO ��Ч״̬ --״̬���� --״̬���� ��yujia 20110323��
      /*UPDATE METERINFO
        SET MISTATUS      = M����,
            MISTATUSDATE  = SYSDATE,
            MISTATUSTRANS = P_TYPE,
            MIUNINSDATE   = SYSDATE,
            MISEQNO       = '',
            MIBFID        = NULL
      WHERE MIID = P_MD.MTDMID;*/
      UPDATE ST_METERINFO_STORE
         SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
       WHERE BSM = P_MD.MTDMNOO;
      -----METERDOC  ��״̬ ��״̬����ʱ��  ��yujia 20110323��

      UPDATE METERDOC
         SET MDSTATUS = M����, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;



    ELSIF P_TYPE = BT�ھ���� THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      UPDATE METERINFO
         SET MISTATUS      = M����,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE,
             MIREINSCODE   = P_MD.MTDREINSCODE, --�������
             MIREINSDATE   = P_MD.MTDREINSDATE, --��������
             MIREINSPER    = P_MD.MTDREINSPER, --������
             MITYPE        = P_MD.MTDMTYPEN, --����
             MIBFID        = NULL
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  ��״̬ ��״̬����ʱ��
      UPDATE METERDOC
         SET MDSTATUS     = M����,
             MDCALIBER    = P_MD.MTDCALIBERN,
             MDNO         = P_MD.MTDMNON, ---���ͺ�
             MDSTATUSDATE = SYSDATE,
             MDCYCCHKDATE = P_MD.MTDREINSDATE
       WHERE MDMID = P_MD.MTDMID;
      --METERTRANSDT �ع��������� �ع�ˮ��״̬
      UPDATE METERTRANSDT
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --���ݼ�¼�ع���Ϣ
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;
      MK.MTRBID           := P_MD.MTDNO; --������ˮ
      MK.MTRBROWNO        := P_MD.MTDROWNO; --�к�
      MK.MTRBDATE         := SYSDATE; --�ع���������
      MK.MTRBSTATUS       := MI.MISTATUS; --״̬
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --״̬����
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --״̬����
      MK.MTRBRCODE        := MI.MIRCODE; --���ڶ���
      MK.MTRBADR          := MI.MIADR; --���ַ
      MK.MTRBSIDE         := MI.MISIDE; --��λ
      MK.MTRBPOSITION     := MI.MIPOSITION; --ˮ���ˮ��ַ
      MK.MTRBINSCODE      := MI.MIINSCODE; --��װ���
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --�������
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --��������
      MK.MTRBREINSPER     := MI.MIREINSPER; --������
      MK.MTRBCSTATUS      := CI.CISTATUS; --�û�״̬
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --״̬����
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --״̬����
      MK.MTRBNO           := MC.MDNO; --������
      MK.MTRBCALIBER      := MC.MDCALIBER; --��ھ�
      MK.MTRBBRAND        := MC.MDBRAND; --����
      MK.MTRBMODEL        := MC.MDMODEL; --���ͺ�
      MK.MTRBMSTATUS      := MC.MDSTATUS; --��״̬
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      ------������״̬�ı�    �ɱ�״̬
      UPDATE ST_METERINFO_STORE
         SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
       WHERE BSM = P_MD.MTDMNOO;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
      MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
      MA.MASCREDATE   := SYSDATE; --��������
      MA.MASCID       := MI.MICID; --�û����
      MA.MASMID       := MI.MIID; --ˮ����
      MA.MASSL        := P_MD.MTDADDSL; --����
      MA.MASCREPER    := P_PERSON; --������Ա
      MA.MASTRANS     := P_TYPE; --�ӵ�����
      MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
      MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
      INSERT INTO METERADDSL VALUES MA;
      --��ѣ�����

    ELSIF P_TYPE = BT������ THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      UPDATE METERINFO
         SET MISTATUS      = M����,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  ��״̬ ��״̬����ʱ��
      UPDATE METERDOC
         SET MDSTATUS = M����, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --METERTRANSDT �ع��������� �ع�ˮ��״̬
      UPDATE METERTRANSDT
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --���ݼ�¼�ع���Ϣ
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;

      MK.MTRBID           := P_MD.MTDNO; --������ˮ
      MK.MTRBROWNO        := P_MD.MTDROWNO; --�к�
      MK.MTRBDATE         := SYSDATE; --�ع���������
      MK.MTRBSTATUS       := MI.MISTATUS; --״̬
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --״̬����
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --״̬����
      MK.MTRBRCODE        := MI.MIRCODE; --���ڶ���
      MK.MTRBADR          := MI.MIADR; --���ַ
      MK.MTRBSIDE         := MI.MISIDE; --��λ
      MK.MTRBPOSITION     := MI.MIPOSITION; --ˮ���ˮ��ַ
      MK.MTRBINSCODE      := MI.MIINSCODE; --��װ���
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --�������
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --��������
      MK.MTRBREINSPER     := MI.MIREINSPER; --������
      MK.MTRBCSTATUS      := CI.CISTATUS; --�û�״̬
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --״̬����
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --״̬����
      MK.MTRBNO           := MC.MDNO; --������
      MK.MTRBCALIBER      := MC.MDCALIBER; --��ھ�
      MK.MTRBBRAND        := MC.MDBRAND; --����
      MK.MTRBMODEL        := MC.MDMODEL; --���ͺ�
      MK.MTRBMSTATUS      := MC.MDSTATUS; --��״̬
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
      MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
      MA.MASCREDATE   := SYSDATE; --��������
      MA.MASCID       := MI.MICID; --�û����
      MA.MASMID       := MI.MIID; --ˮ����
      MA.MASSL        := P_MD.MTDADDSL; --����
      MA.MASCREPER    := P_PERSON; --������Ա
      MA.MASTRANS     := P_TYPE; --�ӵ�����
      MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
      MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
      INSERT INTO METERADDSL VALUES MA;
      --���
      --
    ELSIF P_TYPE = BTǷ��ͣˮ THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      UPDATE METERINFO
         SET MISTATUS      = MǷ��ͣˮ,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  ��״̬ ��״̬����ʱ��
      UPDATE METERDOC
         SET MDSTATUS = MǷ��ͣˮ, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --METERTRANSDT �ع��������� �ع�ˮ��״̬
      UPDATE METERTRANSDT
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --���ݼ�¼�ع���Ϣ
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;

      MK.MTRBID           := P_MD.MTDNO; --������ˮ
      MK.MTRBROWNO        := P_MD.MTDROWNO; --�к�
      MK.MTRBDATE         := SYSDATE; --�ع���������
      MK.MTRBSTATUS       := MI.MISTATUS; --״̬
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --״̬����
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --״̬����
      MK.MTRBRCODE        := MI.MIRCODE; --���ڶ���
      MK.MTRBADR          := MI.MIADR; --���ַ
      MK.MTRBSIDE         := MI.MISIDE; --��λ
      MK.MTRBPOSITION     := MI.MIPOSITION; --ˮ���ˮ��ַ
      MK.MTRBINSCODE      := MI.MIINSCODE; --��װ���
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --�������
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --��������
      MK.MTRBREINSPER     := MI.MIREINSPER; --������
      MK.MTRBCSTATUS      := CI.CISTATUS; --�û�״̬
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --״̬����
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --״̬����
      MK.MTRBNO           := MC.MDNO; --������
      MK.MTRBCALIBER      := MC.MDCALIBER; --��ھ�
      MK.MTRBBRAND        := MC.MDBRAND; --����
      MK.MTRBMODEL        := MC.MDMODEL; --���ͺ�
      MK.MTRBMSTATUS      := MC.MDSTATUS; --��״̬
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
      MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
      MA.MASCREDATE   := SYSDATE; --��������
      MA.MASCID       := MI.MICID; --�û����
      MA.MASMID       := MI.MIID; --ˮ����
      MA.MASSL        := P_MD.MTDADDSL; --����
      MA.MASCREPER    := P_PERSON; --������Ա
      MA.MASTRANS     := P_TYPE; --�ӵ�����
      MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
      MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
      INSERT INTO METERADDSL VALUES MA;
      --���
    ELSIF P_TYPE = BT�ָ���ˮ THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      UPDATE METERINFO
         SET MISTATUS      = M����,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  ��״̬ ��״̬����ʱ��
      UPDATE METERDOC
         SET MDSTATUS = M����, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --METERTRANSDT �ع��������� �ع�ˮ��״̬
      UPDATE METERTRANSDT
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --���ݼ�¼�ع���Ϣ
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;

      MK.MTRBID           := P_MD.MTDNO; --������ˮ
      MK.MTRBROWNO        := P_MD.MTDROWNO; --�к�
      MK.MTRBDATE         := SYSDATE; --�ع���������
      MK.MTRBSTATUS       := MI.MISTATUS; --״̬
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --״̬����
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --״̬����
      MK.MTRBRCODE        := MI.MIRCODE; --���ڶ���
      MK.MTRBADR          := MI.MIADR; --���ַ
      MK.MTRBSIDE         := MI.MISIDE; --��λ
      MK.MTRBPOSITION     := MI.MIPOSITION; --ˮ���ˮ��ַ
      MK.MTRBINSCODE      := MI.MIINSCODE; --��װ���
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --�������
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --��������
      MK.MTRBREINSPER     := MI.MIREINSPER; --������
      MK.MTRBCSTATUS      := CI.CISTATUS; --�û�״̬
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --״̬����
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --״̬����
      MK.MTRBNO           := MC.MDNO; --������
      MK.MTRBCALIBER      := MC.MDCALIBER; --��ھ�
      MK.MTRBBRAND        := MC.MDBRAND; --����
      MK.MTRBMODEL        := MC.MDMODEL; --���ͺ�
      MK.MTRBMSTATUS      := MC.MDSTATUS; --��״̬
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
      MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
      MA.MASCREDATE   := SYSDATE; --��������
      MA.MASCID       := MI.MICID; --�û����
      MA.MASMID       := MI.MIID; --ˮ����
      MA.MASSL        := P_MD.MTDADDSL; --����
      MA.MASCREPER    := P_PERSON; --������Ա
      MA.MASTRANS     := P_TYPE; --�ӵ�����
      MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
      MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
      INSERT INTO METERADDSL VALUES MA;
      --���
    ELSIF P_TYPE = BT��ͣ THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      UPDATE METERINFO
         SET MISTATUS      = M��ͣ,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  ��״̬ ��״̬����ʱ��
      UPDATE METERDOC
         SET MDSTATUS = M��ͣ, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --METERTRANSDT �ع��������� �ع�ˮ��״̬
      UPDATE METERTRANSDT
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --���ݼ�¼�ع���Ϣ
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;

      MK.MTRBID           := P_MD.MTDNO; --������ˮ
      MK.MTRBROWNO        := P_MD.MTDROWNO; --�к�
      MK.MTRBDATE         := SYSDATE; --�ع���������
      MK.MTRBSTATUS       := MI.MISTATUS; --״̬
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --״̬����
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --״̬����
      MK.MTRBRCODE        := MI.MIRCODE; --���ڶ���
      MK.MTRBADR          := MI.MIADR; --���ַ
      MK.MTRBSIDE         := MI.MISIDE; --��λ
      MK.MTRBPOSITION     := MI.MIPOSITION; --ˮ���ˮ��ַ
      MK.MTRBINSCODE      := MI.MIINSCODE; --��װ���
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --�������
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --��������
      MK.MTRBREINSPER     := MI.MIREINSPER; --������
      MK.MTRBCSTATUS      := CI.CISTATUS; --�û�״̬
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --״̬����
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --״̬����
      MK.MTRBNO           := MC.MDNO; --������
      MK.MTRBCALIBER      := MC.MDCALIBER; --��ھ�
      MK.MTRBBRAND        := MC.MDBRAND; --����
      MK.MTRBMODEL        := MC.MDMODEL; --���ͺ�
      MK.MTRBMSTATUS      := MC.MDSTATUS; --��״̬
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
      MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
      MA.MASCREDATE   := SYSDATE; --��������
      MA.MASCID       := MI.MICID; --�û����
      MA.MASMID       := MI.MIID; --ˮ����
      MA.MASSL        := P_MD.MTDADDSL; --����
      MA.MASCREPER    := P_PERSON; --������Ա
      MA.MASTRANS     := P_TYPE; --�ӵ�����
      MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
      MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
      INSERT INTO METERADDSL VALUES MA;
      --���
      --
    ELSIF P_TYPE = BTУ�� THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      --�ݲ����±��ڶ���     ,MIRCODE=P_MD.MTDREINSCODE
      UPDATE METERINFO
         SET MISTATUS      = M����,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE,
             MIREINSDATE   = P_MD.MTDREINSDATE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  ��״̬ ��״̬����ʱ��
      UPDATE METERDOC
         SET MDSTATUS     = M����,
             MDSTATUSDATE = SYSDATE,
             MDCYCCHKDATE = P_MD.MTDREINSDATE
       WHERE MDMID = P_MD.MTDMID;
      --METERTRANSDT �ع��������� �ع�ˮ��״̬
      UPDATE METERTRANSDT
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --���ݼ�¼�ع���Ϣ
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;

      MK.MTRBID           := P_MD.MTDNO; --������ˮ
      MK.MTRBROWNO        := P_MD.MTDROWNO; --�к�
      MK.MTRBDATE         := SYSDATE; --�ع���������
      MK.MTRBSTATUS       := MI.MISTATUS; --״̬
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --״̬����
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --״̬����
      MK.MTRBRCODE        := MI.MIRCODE; --���ڶ���
      MK.MTRBADR          := MI.MIADR; --���ַ
      MK.MTRBSIDE         := MI.MISIDE; --��λ
      MK.MTRBPOSITION     := MI.MIPOSITION; --ˮ���ˮ��ַ
      MK.MTRBINSCODE      := MI.MIINSCODE; --��װ���
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --�������
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --��������
      MK.MTRBREINSPER     := MI.MIREINSPER; --������
      MK.MTRBCSTATUS      := CI.CISTATUS; --�û�״̬
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --״̬����
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --״̬����
      MK.MTRBNO           := MC.MDNO; --������
      MK.MTRBCALIBER      := MC.MDCALIBER; --��ھ�
      MK.MTRBBRAND        := MC.MDBRAND; --����
      MK.MTRBMODEL        := MC.MDMODEL; --���ͺ�
      MK.MTRBMSTATUS      := MC.MDSTATUS; --��״̬
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
      MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
      MA.MASCREDATE   := SYSDATE; --��������
      MA.MASCID       := MI.MICID; --�û����
      MA.MASMID       := MI.MIID; --ˮ����
      MA.MASSL        := P_MD.MTDADDSL; --����
      MA.MASCREPER    := P_PERSON; --������Ա
      MA.MASTRANS     := P_TYPE; --�ӵ�����
      MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
      MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
      INSERT INTO METERADDSL VALUES MA;
      --���
    ELSIF P_TYPE = BT��װ THEN
      --�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE METERINFO
         SET MISTATUS      = M����, --״̬
             MISTATUSDATE  = SYSDATE, --״̬����
             MISTATUSTRANS = P_TYPE, --״̬����
             MIADR         = P_MD.MTDMADRN, --ˮ���ַ
             MISIDE        = P_MD.MTDSIDEN, --��λ
             MIPOSITION    = P_MD.MTDPOSITIONN, --ˮ���ˮ��ַ
             MIREINSCODE   = P_MD.MTDREINSCODE, --�������
             MIREINSDATE   = P_MD.MTDREINSDATE, --��������
             MIREINSPER    = P_MD.MTDREINSPER --������
       WHERE MIID = P_MD.MTDMID;
      --METERDOC
      UPDATE METERDOC
         SET MDSTATUS     = M����, --״̬
             MDSTATUSDATE = SYSDATE, --״̬����ʱ��
             MDNO         = P_MD.MTDMNON, --�����
             MDCALIBER    = P_MD.MTDCALIBERN, --��ھ�
             MDBRAND      = P_MD.MTDBRANDN, --����
             MDMODEL      = P_MD.MTDMODELN, --���ͺ�
             MDCYCCHKDATE = P_MD.MTDREINSDATE
       WHERE MDMID = P_MD.MTDMID;

      --METERTRANSDT �ع��������� �ع�ˮ��״̬
      UPDATE METERTRANSDT
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --���ݼ�¼�ع���Ϣ
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;

      MK.MTRBID           := P_MD.MTDNO; --������ˮ
      MK.MTRBROWNO        := P_MD.MTDROWNO; --�к�
      MK.MTRBDATE         := SYSDATE; --�ع���������
      MK.MTRBSTATUS       := MI.MISTATUS; --״̬
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --״̬����
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --״̬����
      MK.MTRBRCODE        := MI.MIRCODE; --���ڶ���
      MK.MTRBADR          := MI.MIADR; --���ַ
      MK.MTRBSIDE         := MI.MISIDE; --��λ
      MK.MTRBPOSITION     := MI.MIPOSITION; --ˮ���ˮ��ַ
      MK.MTRBINSCODE      := MI.MIINSCODE; --��װ���
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --�������
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --��������
      MK.MTRBREINSPER     := MI.MIREINSPER; --������
      MK.MTRBCSTATUS      := CI.CISTATUS; --�û�״̬
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --״̬����
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --״̬����
      MK.MTRBNO           := MC.MDNO; --������
      MK.MTRBCALIBER      := MC.MDCALIBER; --��ھ�
      MK.MTRBBRAND        := MC.MDBRAND; --����
      MK.MTRBMODEL        := MC.MDMODEL; --���ͺ�
      MK.MTRBMSTATUS      := MC.MDSTATUS; --��״̬
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
      MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
      MA.MASCREDATE   := SYSDATE; --��������
      MA.MASCID       := MI.MICID; --�û����
      MA.MASMID       := MI.MIID; --ˮ����
      MA.MASSL        := P_MD.MTDADDSL; --����
      MA.MASCREPER    := P_PERSON; --������Ա
      MA.MASTRANS     := P_TYPE; --�ӵ�����
      MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
      MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
      INSERT INTO METERADDSL VALUES MA;
      --���
    ELSIF P_TYPE = BT���ϻ��� THEN
         SELECT COUNT(*)
       INTO V_COUNTFLAG
       FROM METERREAD MR
      WHERE MR.MRMID = P_MD.MTDMID
        and MR.mrreadok ='Y' --�ѳ���
        AND MR.MRIFREC <> 'Y'; --δ���
     IF V_COUNTFLAG > 0 THEN  --������Ѿ�����δ�����������ϻ�����ȡ��������־�س�
           RAISE_APPLICATION_ERROR(ERRCODE,'��' || p_md.mtdmid || '����ˮ���Ѿ�����¼��,������־�д���,���ܽ��й��ϻ������,������ʽ������¼�롿����س���Ŧ,ȡ����ǰˮ��!');
     end if ;

     update meterread t set MRSCODE=P_MD.MTDREINSCODE   --by ralph 20151021  ���ӵĽ�δ����ָ�������
     where mrmid=P_MD.MTDMID AND mrreadok='N' /*and exists (select max(t1.mrmonth) from meterread  t1 where
     t.mrmid=t1.mrmid and t1.mrmid=P_MD.MTDMID  AND T1.mrreadok='N' )*/;

     --add 20141117 hb
     --������ϻ���Ϊ9�·ݿ������ϻ�����һֱδ��ˣ�10�·�������г�����ѣ�������������9�·ݵĹ��ϻ���
     --����������ɳ�ʼָ�����
     /*  select  count(a.MTHNO)
       INTO V_COUNTFLAG
      FROM "METERTRANSHD" a, "METERTRANSDT" b, "METERINFO" C
     WHERE a.MTHNO = b.MTdNO
      AND B.MTDMID = C.MIID
      and a.MTHSHFLAG <> 'Y'
      and a.mthlb = 'K'
      and b.MTdNO=P_MD.MTdNO --���ݺ�
      and (c.MICID =P_MD.MTDMID )   --�ͻ�����
    --  and  c.mircode > b.mtdreinscode  --��ʼָ�� ����
      AND ( a.mthcredate  < (   select max(mrday)
     from view_meterreadall
    where mrmid = c.MICID
      and mrreadok = 'Y' )   ) ;
   IF V_COUNTFLAG > 0 THEN  --
           RAISE_APPLICATION_ERROR(ERRCODE, '��' || p_md.mtdmid || '����ˮ���Ѿ�����¼��ʱ���ڴ˹������ϻ���֮��,���ܽ��й��ϻ������,��ɾ���˹��������½����˹���,���������ʼָ�����!');
     end if ;*/

  ------ˮ������У������� zf  20160828
          if p_md.mtdmiyl9 is not null then
         /*SELECT nvl(mrecode,mircode)
           INTO v_rcode
           FROM meterinfo
           left join ( select mrecode,mrmcode from  METERREAD MR
                       WHERE MR.MRMID = P_MD.MTDMID
                             and MR.mrreadok ='Y' --�ѳ���
                             AND MR.MRIFREC <> 'Y'--δ���
                      ) on micode=mrmcode
           where micode=P_MD.MTDMID;

         IF v_rcode > p_md.mtdmiyl9 THEN  --���ˮ�������Ƿ��������С�ڵ�ǰˮ�����
               RAISE_APPLICATION_ERROR(ERRCODE, '��ˮ��ǰ�����ѳ����ù��������õ�������̣�����!');
         else*/   ---�±����� ���ø��ɱ�Ƚ���

         UPDATE METERINFO
         SET miyl9      = p_md.mtdmiyl9  --ˮ���������
          WHERE MIID = P_MD.MTDMID;
        --- end if ;
       end if;
 ----------------------------20160828

     --end add 20141117 hb

     --20140809 �ֱܷ���ϻ��� modiby hb
     --�ܱ��Ȼ����ֱ���˵���ˮ��������������󲻳���

     -- end 20140809 �ֱܷ���ϻ��� modiby hb
      -- METERINFO�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE METERINFO
         SET MISTATUS      = M����, --״̬
             MISTATUSDATE  = SYSDATE, --״̬����
             MISTATUSTRANS = P_TYPE, --״̬����
             MIRCODE       = P_MD.MTDREINSCODE, --�������
             --MIQFH         = P_MD.MTDQFHN,
             --MIADR         = P_MD.MTDMADRN,--ˮ���ַ
             --MISIDE        = P_MD.MTDSIDEN,--��λ
             --MIPOSITION    = P_MD.MTDPOSITIONN ,--ˮ���ˮ��ַ
             MIREINSCODE = P_MD.MTDREINSCODE, --�������
             MIREINSDATE = P_MD.MTDREINSDATE, --��������
             MIREINSPER  = P_MD.MTDREINSPER,  --������
             MIYL1 = 'N',                      --����� �����־���(�����) byj 2016.08
             MIRTID = p_md.mtdmirtid          --����� ���ݹ������� ����ʽ! byj 2016.12 
       WHERE MIID = P_MD.MTDMID;

      --�������������м���־ byj 2016.08-------------
       update metertgl mtg
          set mtg.mtstatus = 'N'
        where mtmid = p_md.MTDMID and
              mtstatus = 'Y';
      ---------------------------------------------------

      --METERDOC �����±���Ϣ 
      begin
        select * into v_meterstore from st_meterinfo_store st where st.bsm = p_md.MTDMNON and rownum < 2 ;
        UPDATE METERDOC
           SET MDSTATUS     = M����,          --״̬
               MDSTATUSDATE = SYSDATE,        --��״̬����ʱ��
               MDNO         = P_MD.MTDMNON,   --�����
               DQSFH        = P_MD.MTDDQSFHN, --�ܷ��
               DQGFH        = P_MD.MTDLFHN,   --�ַ��
               QFH          = P_MD.MTDQFHN ,  --Ǧ���
               MDCALIBER    = v_meterstore.caliber, --��ھ�
               MDBRAND      = P_MD.MTDBRANDN, --����    
               MDCYCCHKDATE = P_MD.MTDREINSDATE, --
               MDMODEL      = v_meterstore.model --���ͺ�
         WHERE MDMID = P_MD.MTDMID;    
      exception
        when others then
          UPDATE METERDOC
           SET MDSTATUS     = M����, --״̬
               MDSTATUSDATE = SYSDATE, --��״̬����ʱ��
               MDNO         = P_MD.MTDMNON, --�����
               DQSFH        = P_MD.MTDDQSFHN, --�ܷ��
               DQGFH  =  P_MD.MTDLFHN,--�ַ��
               QFH          = P_MD.MTDQFHN ,--Ǧ���
               MDCALIBER    = P_MD.MTDCALIBERN, --��ھ�
               MDBRAND      = P_MD.MTDBRANDN, --����
               MDCYCCHKDATE = P_MD.MTDREINSDATE --
         WHERE MDMID = P_MD.MTDMID;   
      end;
       
       
       
       

      --�����ܷ��Ϊ��ʹ��
      IF P_MD.MTDDQSFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDDQSFHN
         and STOREID =mi.mismfid   --����
         and CALIBER=  P_MD.mtdcalibero  --�ھ�
         AND FHTYPE ='1';
      END IF;
      --���øַ��Ϊ��ʹ��
      IF P_MD.MTDLFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDLFHN
           and STOREID =mi.mismfid  --����
          AND FHTYPE ='2';
      END IF;
        --����Ǧ���Ϊ��ʹ��
      IF P_MD.MTDQFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDQFHN
           and STOREID =mi.mismfid  --����
          AND FHTYPE ='4';
      END IF;

     --���������ת�������ϻ�����д���˱�־
     SELECT COUNT(*)
       INTO V_COUNTFLAG
       FROM METERREAD MR
      WHERE MR.MRMID = P_MD.MTDMID
        AND MR.MRIFSUBMIT = 'N';
     IF V_COUNTFLAG > 0 THEN
       UPDATE METERREAD MR
          SET MR.MRCHKFLAG = 'Y', --���˱�־
              MR.MRCHKDATE = SYSDATE, --��������
              MR.MRCHKPER  = P_PERSON --������Ա

        WHERE MR.MRMID = P_MD.MTDMID
          AND MR.MRIFSUBMIT = 'N';
     END IF;

      --���ݼ�¼�ع���Ϣ
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;
      MK.MTRBID           := P_MD.MTDNO; --������ˮ
      MK.MTRBROWNO        := P_MD.MTDROWNO; --�к�
      MK.MTRBDATE         := SYSDATE; --�ع���������
      MK.MTRBSTATUS       := MI.MISTATUS; --״̬
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --״̬����
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --״̬����
      MK.MTRBRCODE        := MI.MIRCODE; --���ڶ���
      MK.MTRBADR          := MI.MIADR; --���ַ
      MK.MTRBSIDE         := MI.MISIDE; --��λ
      MK.MTRBPOSITION     := MI.MIPOSITION; --ˮ���ˮ��ַ
      MK.MTRBINSCODE      := MI.MIINSCODE; --��װ���
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --�������
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --��������
      MK.MTRBREINSPER     := MI.MIREINSPER; --������
      MK.MTRBCSTATUS      := CI.CISTATUS; --�û�״̬
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --״̬����
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --״̬����
      MK.MTRBNO           := MC.MDNO; --������
      MK.MTRBCALIBER      := MC.MDCALIBER; --��ھ�
      MK.MTRBBRAND        := MC.MDBRAND; --����
      MK.MTRBMODEL        := MC.MDMODEL; --���ͺ�
      MK.MTRBMSTATUS      := MC.MDSTATUS; --��״̬
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --��״̬����ʱ��


      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
      MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
      MA.MASCREDATE   := SYSDATE; --��������
      MA.MASCID       := MI.MICID; --�û����
      MA.MASMID       := MI.MIID; --ˮ����
      MA.MASSL        := P_MD.MTDADDSL; --����
      MA.MASCREPER    := P_PERSON; --������Ա
      MA.MASTRANS     := P_TYPE; --�ӵ�����
      MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
      MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
      INSERT INTO METERADDSL VALUES MA;
      BEGIN
        SELECT STATUS
          INTO V_METERSTATUS.SID
          FROM ST_METERINFO_STORE
         WHERE BSM = P_MD.MTDMNON;

      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF TRIM(V_METERSTATUS.SID) <> '2' THEN
        SELECT SNAME
          INTO V_METERSTATUS.SNAME
          FROM METERSTATUS
         WHERE SID = V_METERSTATUS.SID;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��ˮ��״̬Ϊ��' || V_METERSTATUS.SNAME ||
                                '������ʹ�ã�');
      END IF;
      IF TRIM(V_METERSTATUS.SID) = '2' THEN
        UPDATE ST_METERINFO_STORE
           SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNON;
        UPDATE ST_METERINFO_STORE
           SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNOO;
      END IF;
      --���
    ELSIF P_TYPE = BTˮ������ THEN
      -- METERINFO�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE METERINFO
         SET MISTATUS      = M����, --״̬
             MISTATUSDATE  = SYSDATE, --״̬����
             MISTATUSTRANS = P_TYPE, --״̬����
             --MIADR         = P_MD.MTDMADRN,--ˮ���ַ
             --MISIDE        = P_MD.MTDSIDEN,--��λ
             --MIPOSITION    = P_MD.MTDPOSITIONN ,--ˮ���ˮ��ַ
             MIREINSCODE = P_MD.MTDREINSCODE, --�������
             MIREINSDATE = P_MD.MTDREINSDATE, --��������
             MIREINSPER  = P_MD.MTDREINSPER --������
       WHERE MIID = P_MD.MTDMID;
      --METERDOC
      UPDATE METERDOC
         SET MDSTATUS     = M����, --״̬
             MDSTATUSDATE = SYSDATE, --��״̬����ʱ��
             MDNO         = P_MD.MTDMNON, --�����
             MDCALIBER    = P_MD.MTDCALIBERN, --��ھ�
             MDBRAND      = P_MD.MTDBRANDN, --����
             MDMODEL      = P_MD.MTDMODELN, --���ͺ�
             MDCYCCHKDATE = P_MD.MTDREINSDATE --
       WHERE MDMID = P_MD.MTDMID;
      --���ݼ�¼�ع���Ϣ
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;

      MK.MTRBID           := P_MD.MTDNO; --������ˮ
      MK.MTRBROWNO        := P_MD.MTDROWNO; --�к�
      MK.MTRBDATE         := SYSDATE; --�ع���������
      MK.MTRBSTATUS       := MI.MISTATUS; --״̬
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --״̬����
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --״̬����
      MK.MTRBRCODE        := MI.MIRCODE; --���ڶ���
      MK.MTRBADR          := MI.MIADR; --���ַ
      MK.MTRBSIDE         := MI.MISIDE; --��λ
      MK.MTRBPOSITION     := MI.MIPOSITION; --ˮ���ˮ��ַ
      MK.MTRBINSCODE      := MI.MIINSCODE; --��װ���
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --�������
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --��������
      MK.MTRBREINSPER     := MI.MIREINSPER; --������
      MK.MTRBCSTATUS      := CI.CISTATUS; --�û�״̬
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --״̬����
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --״̬����
      MK.MTRBNO           := MC.MDNO; --������
      MK.MTRBCALIBER      := MC.MDCALIBER; --��ھ�
      MK.MTRBBRAND        := MC.MDBRAND; --����
      MK.MTRBMODEL        := MC.MDMODEL; --���ͺ�
      MK.MTRBMSTATUS      := MC.MDSTATUS; --��״̬
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
      MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
      MA.MASCREDATE   := SYSDATE; --��������
      MA.MASCID       := MI.MICID; --�û����
      MA.MASMID       := MI.MIID; --ˮ����
      MA.MASSL        := P_MD.MTDADDSL; --����
      MA.MASCREPER    := P_PERSON; --������Ա
      MA.MASTRANS     := P_TYPE; --�ӵ�����
      MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
      MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
      INSERT INTO METERADDSL VALUES MA;
    ELSIF P_TYPE = BT���ڻ��� THEN
/*      -- METERINFO�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE METERINFO
         SET MISTATUS      = M����, --״̬
             MISTATUSDATE  = SYSDATE, --״̬����
             MISTATUSTRANS = P_TYPE, --״̬����
             MIRCODE       = P_MD.MTDREINSCODE, --�±�����
             --MIADR         = P_MD.MTDMADRN,--ˮ���ַ
             --MISIDE        = P_MD.MTDSIDEN,--��λ
             --MIPOSITION    = P_MD.MTDPOSITIONN ,--ˮ���ˮ��ַ
             MIREINSCODE = P_MD.MTDREINSCODE, --�������
             MIREINSDATE = P_MD.MTDREINSDATE, --��������
             MIREINSPER  = P_MD.MTDREINSPER --������
       WHERE MIID = P_MD.MTDMID;
      --METERDOC
      UPDATE METERDOC
         SET MDSTATUS     = M����, --״̬
             MDSTATUSDATE = SYSDATE, --��״̬����ʱ��
             MDNO         = P_MD.MTDMNON, --�����
             DQSFH        = P_MD.MTDDQSFHN, --�ܷ��
             --LFH          = P_MD.MTDLFHN, --����ţ����Ǹַ�ţ�
             DQGFH  =  P_MD.MTDLFHN,--�ַ��
             QFH          = P_MD.MTDQFHN ,--Ǧ���
             MDCALIBER    = P_MD.MTDCALIBERN, --��ھ�
             MDBRAND      = P_MD.MTDBRANDN, --����
             MDMODEL      = P_MD.MTDMODELN, --���ͺ�
             MDCYCCHKDATE = P_MD.MTDREINSDATE --
       WHERE MDMID = P_MD.MTDMID;

            --�����ܷ��Ϊ��ʹ��
      IF P_MD.MTDDQSFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDDQSFHN
          AND FHTYPE ='1';
      END IF;
      --���øַ��Ϊ��ʹ��
      IF P_MD.MTDLFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDLFHN
          AND FHTYPE ='2';
      END IF;
        --����Ǧ���Ϊ��ʹ��
      IF P_MD.MTDQFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDQFHN
          AND FHTYPE ='4';
      END IF;

      --���ݼ�¼�ع���Ϣ
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;

      MK.MTRBID           := P_MD.MTDNO; --������ˮ
      MK.MTRBROWNO        := P_MD.MTDROWNO; --�к�
      MK.MTRBDATE         := SYSDATE; --�ع���������
      MK.MTRBSTATUS       := MI.MISTATUS; --״̬
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --״̬����
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --״̬����
      MK.MTRBRCODE        := MI.MIRCODE; --���ڶ���
      MK.MTRBADR          := MI.MIADR; --���ַ
      MK.MTRBSIDE         := MI.MISIDE; --��λ
      MK.MTRBPOSITION     := MI.MIPOSITION; --ˮ���ˮ��ַ
      MK.MTRBINSCODE      := MI.MIINSCODE; --��װ���
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --�������
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --��������
      MK.MTRBREINSPER     := MI.MIREINSPER; --������
      MK.MTRBCSTATUS      := CI.CISTATUS; --�û�״̬
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --״̬����
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --״̬����
      MK.MTRBNO           := MC.MDNO; --������
      MK.MTRBCALIBER      := MC.MDCALIBER; --��ھ�
      MK.MTRBBRAND        := MC.MDBRAND; --����
      MK.MTRBMODEL        := MC.MDMODEL; --���ͺ�
      MK.MTRBMSTATUS      := MC.MDSTATUS; --��״̬
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
      MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
      MA.MASCREDATE   := SYSDATE; --��������
      MA.MASCID       := MI.MICID; --�û����
      MA.MASMID       := MI.MIID; --ˮ����
      MA.MASSL        := P_MD.MTDADDSL; --����
      MA.MASCREPER    := P_PERSON; --������Ա
      MA.MASTRANS     := P_TYPE; --�ӵ�����
      MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
      MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
      INSERT INTO METERADDSL VALUES MA;
      BEGIN
        SELECT STATUS
          INTO V_METERSTATUS.SID
          FROM ST_METERINFO_STORE
         WHERE BSM = P_MD.MTDMNON;

      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF TRIM(V_METERSTATUS.SID) <> '2' THEN
        SELECT SNAME
          INTO V_METERSTATUS.SNAME
          FROM METERSTATUS
         WHERE SID = V_METERSTATUS.SID;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��ˮ��״̬Ϊ��' || V_METERSTATUS.SNAME ||
                                '������ʹ�ã�');
      END IF;
      IF TRIM(V_METERSTATUS.SID) = '2' THEN
        UPDATE ST_METERINFO_STORE
           SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNON;
        UPDATE ST_METERINFO_STORE
           SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNOO;
      END IF;
    */
    --����Ϊ֮ǰ���ڻ������ modiby hb 20140815
    --����Ϊ���ϻ���Ĵ���Ź�����ԭ������ϻ���ԭ��һ��

           SELECT COUNT(*)
       INTO V_COUNTFLAG
       FROM METERREAD MR
      WHERE MR.MRMID = P_MD.MTDMID
        and MR.mrreadok ='Y' --�ѳ���
        AND MR.MRIFREC <> 'Y'; --δ���
     IF V_COUNTFLAG > 0 THEN  --������Ѿ�����δ�����������ϻ�����ȡ��������־�س�
           RAISE_APPLICATION_ERROR(ERRCODE, '��ˮ��['|| P_MD.MTDMID||']�Ѿ�����¼��,������־�д���,���ܽ������ڻ������,������ʽ������¼�롿����س���Ŧ,ȡ����ǰˮ��!');
     end if ;

    ------ˮ������У������� zf  20160828
          if p_md.mtdmiyl9 is not null then
        /* SELECT nvl(mrecode,mircode)
           INTO v_rcode
           FROM meterinfo
           left join ( select mrecode,mrmcode from  METERREAD MR
                       WHERE MR.MRMID = P_MD.MTDMID
                             and MR.mrreadok ='Y' --�ѳ���
                             AND MR.MRIFREC <> 'Y'--δ���
                      ) on micode=mrmcode
           where micode=P_MD.MTDMID;

         IF v_rcode > p_md.mtdmiyl9 THEN  --���ˮ�������Ƿ��������С�ڵ�ǰˮ�����
               RAISE_APPLICATION_ERROR(ERRCODE, '��ˮ��ǰ�����ѳ����ù��������õ�������̣�����!');
         else*/
         UPDATE METERINFO
         SET miyl9      = p_md.mtdmiyl9  --ˮ���������
          WHERE MIID = P_MD.MTDMID;
       ---  end if ;
       end if;
       ----------------------------20160828

     --20140809 �ֱܷ���ϻ��� modiby hb
     --�ܱ��Ȼ����ֱ���˵���ˮ��������������󲻳���

     -- end 20140809 �ֱܷ���ϻ��� modiby hb
      -- METERINFO�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE METERINFO
         SET MISTATUS      = M����, --״̬
             MISTATUSDATE  = SYSDATE, --״̬����
             MISTATUSTRANS = P_TYPE, --״̬����
             MIRCODE       = P_MD.MTDREINSCODE, --�������
             --MIQFH         = P_MD.MTDQFHN,
             --MIADR         = P_MD.MTDMADRN,--ˮ���ַ
             --MISIDE        = P_MD.MTDSIDEN,--��λ
             --MIPOSITION    = P_MD.MTDPOSITIONN ,--ˮ���ˮ��ַ
             MIREINSCODE = P_MD.MTDREINSCODE, --�������
             MIREINSDATE = P_MD.MTDREINSDATE, --��������
             MIREINSPER  = P_MD.MTDREINSPER,  --������
             MIYL1 = 'N',                     --����� �����־���(�����) byj 2016.08
             MIRTID = p_md.mtdmirtid          --����� ���ݹ������� ����ʽ! byj 2016.12 
       WHERE MIID = P_MD.MTDMID;

      --�������������м���־ byj 2016.08-------------
       update metertgl mtg
          set mtg.mtstatus = 'N'
        where mtmid = p_md.MTDMID and
              mtstatus = 'Y';
      ---------------------------------------------------

      --METERDOC �����±���Ϣ 
      begin
        select * into v_meterstore from st_meterinfo_store st where st.bsm = p_md.MTDMNON and rownum < 2 ;
        UPDATE METERDOC
           SET MDSTATUS     = M����,          --״̬
               MDSTATUSDATE = SYSDATE,        --��״̬����ʱ��
               MDNO         = P_MD.MTDMNON,   --�����
               DQSFH        = P_MD.MTDDQSFHN, --�ܷ��
               DQGFH        = P_MD.MTDLFHN,   --�ַ��
               QFH          = P_MD.MTDQFHN ,  --Ǧ���
               MDCALIBER    = v_meterstore.caliber, --��ھ�
               MDBRAND      = P_MD.MTDBRANDN, --����    
               MDCYCCHKDATE = P_MD.MTDREINSDATE, --
               MDMODEL      = v_meterstore.model --���ͺ�
         WHERE MDMID = P_MD.MTDMID;    
      exception
        when others then
          UPDATE METERDOC
           SET MDSTATUS     = M����, --״̬
               MDSTATUSDATE = SYSDATE, --��״̬����ʱ��
               MDNO         = P_MD.MTDMNON, --�����
               DQSFH        = P_MD.MTDDQSFHN, --�ܷ��
               DQGFH  =  P_MD.MTDLFHN,--�ַ��
               QFH          = P_MD.MTDQFHN ,--Ǧ���
               MDCALIBER    = P_MD.MTDCALIBERN, --��ھ�
               MDBRAND      = P_MD.MTDBRANDN, --����
               MDCYCCHKDATE = P_MD.MTDREINSDATE --
         WHERE MDMID = P_MD.MTDMID;   
      end;
 

      --�����ܷ��Ϊ��ʹ��
      IF P_MD.MTDDQSFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDDQSFHN
         and STOREID =mi.mismfid   --����
         and CALIBER=  P_MD.mtdcalibero  --�ھ�
         AND FHTYPE ='1';
      END IF;
      --���øַ��Ϊ��ʹ��
      IF P_MD.MTDLFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDLFHN
           and STOREID =mi.mismfid  --����
          AND FHTYPE ='2';
      END IF;
        --����Ǧ���Ϊ��ʹ��
      IF P_MD.MTDQFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDQFHN
           and STOREID =mi.mismfid  --����
          AND FHTYPE ='4';
      END IF;

     --���������ת�������ڻ�����д���˱�־
     SELECT COUNT(*)
       INTO V_COUNTFLAG
       FROM METERREAD MR
      WHERE MR.MRMID = P_MD.MTDMID
        AND MR.MRIFSUBMIT = 'N';
     IF V_COUNTFLAG > 0 THEN
       UPDATE METERREAD MR
          SET MR.MRCHKFLAG = 'Y', --���˱�־
              MR.MRCHKDATE = SYSDATE, --��������
              MR.MRCHKPER  = P_PERSON --������Ա

        WHERE MR.MRMID = P_MD.MTDMID
          AND MR.MRIFSUBMIT = 'N';
     END IF;

      --���ݼ�¼�ع���Ϣ
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;
      MK.MTRBID           := P_MD.MTDNO; --������ˮ
      MK.MTRBROWNO        := P_MD.MTDROWNO; --�к�
      MK.MTRBDATE         := SYSDATE; --�ع���������
      MK.MTRBSTATUS       := MI.MISTATUS; --״̬
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --״̬����
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --״̬����
      MK.MTRBRCODE        := MI.MIRCODE; --���ڶ���
      MK.MTRBADR          := MI.MIADR; --���ַ
      MK.MTRBSIDE         := MI.MISIDE; --��λ
      MK.MTRBPOSITION     := MI.MIPOSITION; --ˮ���ˮ��ַ
      MK.MTRBINSCODE      := MI.MIINSCODE; --��װ���
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --�������
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --��������
      MK.MTRBREINSPER     := MI.MIREINSPER; --������
      MK.MTRBCSTATUS      := CI.CISTATUS; --�û�״̬
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --״̬����
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --״̬����
      MK.MTRBNO           := MC.MDNO; --������
      MK.MTRBCALIBER      := MC.MDCALIBER; --��ھ�
      MK.MTRBBRAND        := MC.MDBRAND; --����
      MK.MTRBMODEL        := MC.MDMODEL; --���ͺ�
      MK.MTRBMSTATUS      := MC.MDSTATUS; --��״̬
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --��״̬����ʱ��


      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
      MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
      MA.MASCREDATE   := SYSDATE; --��������
      MA.MASCID       := MI.MICID; --�û����
      MA.MASMID       := MI.MIID; --ˮ����
      MA.MASSL        := P_MD.MTDADDSL; --����
      MA.MASCREPER    := P_PERSON; --������Ա
      MA.MASTRANS     := P_TYPE; --�ӵ�����
      MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
      MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
      INSERT INTO METERADDSL VALUES MA;
      BEGIN
        SELECT STATUS
          INTO V_METERSTATUS.SID
          FROM ST_METERINFO_STORE
         WHERE BSM = P_MD.MTDMNON;

      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF TRIM(V_METERSTATUS.SID) <> '2' THEN
        SELECT SNAME
          INTO V_METERSTATUS.SNAME
          FROM METERSTATUS
         WHERE SID = V_METERSTATUS.SID;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                MI.MICID||'��ˮ��״̬Ϊ��' || V_METERSTATUS.SNAME ||
                                '������ʹ�ã�');
      END IF;
      IF TRIM(V_METERSTATUS.SID) = '2' THEN
        UPDATE ST_METERINFO_STORE
           SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNON;
        UPDATE ST_METERINFO_STORE
           SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNOO;
      END IF;


      --���
    ELSIF P_TYPE = BT���鹤�� THEN
      NULL;
    ELSIF P_TYPE = BT��װ�ܱ� THEN
      IF NVL(P_MD.MTDWMCOUNT, 0) > 0 THEN
        TOOLS.SP_BILLSEQ('100', V_CRHNO);
        INSERT INTO CUSTREGHD
          (CRHNO,
           CRHBH,
           CRHLB,
           CRHSOURCE,
           CRHSMFID,
           CRHDEPT,
           CRHCREDATE,
           CRHCREPER,
           CRHSHFLAG)
        VALUES
          (V_CRHNO,
           P_MD.MTDNO,
           '0',
           P_TYPE,
           P_MD.MTDSMFID,
           NULL,
           SYSDATE,
           P_PERSON,
           'N');

        V_NUMBER := 0;
        LOOP
          INSERT INTO CUSTMETERREGDT
            (CMRDNO,
             CMRDROWNO,
             CISMFID,
             CINAME,
             CINAME2,
             CIADR,
             CISTATUS,
             CISTATUSTRANS,
             CIIDENTITYLB,
             CIIDENTITYNO,
             CIMTEL,
             CITEL1,
             CITEL2,
             CITEL3,
             CICONNECTPER,
             CICONNECTTEL,
             CIIFINV,
             CIIFSMS,
             CIIFZN,
             MIADR,
             MISAFID,
             MISMFID,
             MIRTID,
             MISTID,
             MIPFID,
             MISTATUS,
             MISTATUSTRANS,
             MIRPID,
             MISIDE,
             MIPOSITION,
             MITYPE,
             MIIFCHARGE,
             MIIFSL,
             MIIFCHK,
             MIIFWATCH,
             MICHARGETYPE,
             MILB,
             MINAME,
             MINAME2,
             CICLASS,
             CIFLAG,
             MIIFMP,
             MIIFSP,
             MIIFCKF,
             MIUSENUM,
             MISAVING,
             MIIFTAX,
             MIINSCODE,
             MIINSDATE,
             MIPRIFLAG,
             MDSTATUS,
             MAIFXEZF,
             MIRCODE,
             MDNO,
             MDMODEL,
             MDBRAND,
             MDCALIBER,
             CMDCHKPER,
             MIINSCODECHAR,
             MIPID)
          VALUES
            (V_CRHNO,
             V_NUMBER + 1,
             MI.MISMFID,
             '���û�',
             '���û�',
             CI.CIADR,
             '0',
             CI.CISTATUSTRANS,
             '1',
             CI.CIIDENTITYNO,
             P_MD.MTDTEL,
             CI.CITEL1,
             CI.CITEL2,
             CI.CITEL3,
             P_MD.MTDCONPER,
             P_MD.MTDCONTEL,
             'Y',
             'N',
             'Y',
             MI.MIADR,
             MI.MISAFID,
             MI.MISMFID,
             MI.MIRTID,
             MI.MISTID,
             MI.MIPFID,
             '1',
             MI.MISTATUSTRANS,
             MI.MIRPID,
             P_MD.MTDSIDEO,
             P_MD.MTDPOSITIONO,
             '1',
             'Y',
             'Y',
             'N',
             'N',
             'X',
             'H',
             MI.MINAME,
             MI.MINAME2,
             1,
             'Y',
             'N',
             'N',
             'N',
             1,
             0,
             'N',
             0,
             TRUNC(SYSDATE),
             'N',
             '00',
             'N',
             P_MD.MTDREINSCODE,
             P_MD.MTDMNOO,
             P_MD.MTDMODELO,
             P_MD.MTDBRANDO,
             P_MD.MTDCALIBERO,
             P_MD.MTDCHKPER,
             '00000',
             P_MD.MTDMCODE);
          V_NUMBER := V_NUMBER + 1;
          EXIT WHEN V_NUMBER = P_MD.MTDWMCOUNT;
        END LOOP;
      END IF;
    ELSIF P_TYPE = BT��װ���� THEN
      IF NVL(P_MD.MTDWMCOUNT, 0) > 0 THEN
        TOOLS.SP_BILLSEQ('100', V_CRHNO);
        INSERT INTO CUSTREGHD
          (CRHNO,
           CRHBH,
           CRHLB,
           CRHSOURCE,
           CRHSMFID,
           CRHDEPT,
           CRHCREDATE,
           CRHCREPER,
           CRHSHFLAG)
        VALUES
          (V_CRHNO,
           P_MD.MTDNO,
           '0',
           P_TYPE,
           P_MD.MTDSMFID,
           NULL,
           SYSDATE,
           P_PERSON,
           'N');

        V_NUMBER := 0;
        LOOP
          INSERT INTO CUSTMETERREGDT
            (CMRDNO,
             CMRDROWNO,
             CISMFID,
             CINAME,
             CINAME2,
             CIADR,
             CISTATUS,
             CISTATUSTRANS,
             CIIDENTITYLB,
             CIIDENTITYNO,
             CIMTEL,
             CITEL1,
             CITEL2,
             CITEL3,
             CICONNECTPER,
             CICONNECTTEL,
             CIIFINV,
             CIIFSMS,
             CIIFZN,
             MIADR,
             MISAFID,
             MISMFID,
             MIRTID,
             MISTID,
             MIPFID,
             MISTATUS,
             MISTATUSTRANS,
             MIRPID,
             MISIDE,
             MIPOSITION,
             MITYPE,
             MIIFCHARGE,
             MIIFSL,
             MIIFCHK,
             MIIFWATCH,
             MICHARGETYPE,
             MILB,
             MINAME,
             MINAME2,
             CICLASS,
             CIFLAG,
             MIIFMP,
             MIIFSP,
             MIIFCKF,
             MIUSENUM,
             MISAVING,
             MIIFTAX,
             MIINSCODE,
             MIINSDATE,
             MIPRIFLAG,
             MDSTATUS,
             MAIFXEZF,
             MIRCODE,
             MDNO,
             MDMODEL,
             MDBRAND,
             MDCALIBER,
             CMDCHKPER,
             MIINSCODECHAR,
             MIPID)
          VALUES
            (V_CRHNO,
             V_NUMBER + 1,
             MI.MISMFID,
             '���û�',
             '���û�',
             CI.CIADR,
             '0',
             CI.CISTATUSTRANS,
             '1',
             CI.CIIDENTITYNO,
             P_MD.MTDTEL,
             CI.CITEL1,
             CI.CITEL2,
             CI.CITEL3,
             P_MD.MTDCONPER,
             P_MD.MTDCONTEL,
             'Y',
             'N',
             'Y',
             MI.MIADR,
             MI.MISAFID,
             MI.MISMFID,
             MI.MIRTID,
             MI.MISTID,
             MI.MIPFID,
             '1',
             MI.MISTATUSTRANS,
             MI.MIRPID,
             P_MD.MTDSIDEO,
             P_MD.MTDPOSITIONO,
             '1',
             'Y',
             'Y',
             'N',
             'N',
             'X',
             'H',
             MI.MINAME,
             MI.MINAME2,
             1,
             'Y',
             'N',
             'N',
             'N',
             1,
             0,
             'N',
             0,
             TRUNC(SYSDATE),
             'N',
             '00',
             'N',
             P_MD.MTDREINSCODE,
             P_MD.MTDMNOO,
             P_MD.MTDMODELO,
             P_MD.MTDBRANDO,
             P_MD.MTDCALIBERO,
             P_MD.MTDCHKPER,
             '00000',
             P_MD.MTDMPID);
          V_NUMBER := V_NUMBER + 1;
          EXIT WHEN V_NUMBER = P_MD.MTDWMCOUNT;
        END LOOP;
      END IF;
    ELSIF P_TYPE = BT��װ��������� THEN
      TOOLS.SP_BILLSEQ('100', V_CRHNO);

      INSERT INTO CUSTREGHD
        (CRHNO,
         CRHBH,
         CRHLB,
         CRHSOURCE,
         CRHSMFID,
         CRHDEPT,
         CRHCREDATE,
         CRHCREPER,
         CRHSHFLAG)
      VALUES
        (V_CRHNO,
         P_MD.MTDNO,
         '0',
         P_TYPE,
         P_MD.MTDSMFID,
         NULL,
         SYSDATE,
         P_PERSON,
         'N');

      INSERT INTO CUSTMETERREGDT
        (CMRDNO,
         CMRDROWNO,
         CISMFID,
         CINAME,
         CINAME2,
         CIADR,
         CISTATUS,
         CISTATUSTRANS,
         CIIDENTITYLB,
         CIIDENTITYNO,
         CIMTEL,
         CITEL1,
         CITEL2,
         CITEL3,
         CICONNECTPER,
         CICONNECTTEL,
         CIIFINV,
         CIIFSMS,
         CIIFZN,
         MIADR,
         MISAFID,
         MISMFID,
         MIRTID,
         MISTID,
         MIPFID,
         MISTATUS,
         MISTATUSTRANS,
         MIRPID,
         MISIDE,
         MIPOSITION,
         MITYPE,
         MIIFCHARGE,
         MIIFSL,
         MIIFCHK,
         MIIFWATCH,
         MICHARGETYPE,
         MILB,
         MINAME,
         MINAME2,
         CICLASS,
         CIFLAG,
         MIIFMP,
         MIIFSP,
         MIIFCKF,
         MIUSENUM,
         MISAVING,
         MIIFTAX,
         MIINSCODE,
         MIINSDATE,
         MIPRIFLAG,
         MDSTATUS,
         MAIFXEZF,
         MIRCODE,
         MDNO,
         MDMODEL,
         MDBRAND,
         MDCALIBER,
         CMDCHKPER,
         MIINSCODECHAR)
      VALUES
        (V_CRHNO,
         1,
         MI.MISMFID,
         '���û�',
         '���û�',
         CI.CIADR,
         '0',
         CI.CISTATUSTRANS,
         '1',
         CI.CIIDENTITYNO,
         P_MD.MTDTEL,
         CI.CITEL1,
         CI.CITEL2,
         CI.CITEL3,
         P_MD.MTDCONPER,
         P_MD.MTDCONTEL,
         'Y',
         'N',
         'Y',
         MI.MIADR,
         MI.MISAFID,
         MI.MISMFID,
         MI.MIRTID,
         MI.MISTID,
         MI.MIPFID,
         '1',
         MI.MISTATUSTRANS,
         MI.MIRPID,
         P_MD.MTDSIDEO,
         P_MD.MTDPOSITIONO,
         '1',
         'Y',
         'Y',
         'N',
         'N',
         'X',
         'D',
         MI.MINAME,
         MI.MINAME2,
         1,
         'Y',
         'N',
         'N',
         'N',
         1,
         0,
         'N',
         0,
         TRUNC(SYSDATE),
         'N',
         '00',
         'N',
         P_MD.MTDREINSCODE,
         P_MD.MTDMNOO,
         P_MD.MTDMODELO,
         P_MD.MTDBRANDO,
         P_MD.MTDCALIBERO,
         P_MD.MTDCHKPER,
         '00000');
    ELSIF P_TYPE = BTˮ������ THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      UPDATE METERINFO
         SET MISTATUS      = M����,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE,
             MIPOSITION    = P_MD.MTDPOSITIONN
       WHERE MIID = P_MD.MTDMID;
      -- meterdoc
      UPDATE METERDOC
         SET MDSTATUS = M����, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --METERTRANSDT �ع��������� �ع�ˮ��״̬
      UPDATE METERTRANSDT
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE

       WHERE MTDMID = MI.MIID;
      --���ݼ�¼�ع���Ϣ
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;

      MK.MTRBID           := P_MD.MTDNO; --������ˮ
      MK.MTRBROWNO        := P_MD.MTDROWNO; --�к�
      MK.MTRBDATE         := SYSDATE; --�ع���������
      MK.MTRBSTATUS       := MI.MISTATUS; --״̬
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --״̬����
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --״̬����
      MK.MTRBRCODE        := MI.MIRCODE; --���ڶ���
      MK.MTRBADR          := MI.MIADR; --���ַ
      MK.MTRBSIDE         := MI.MISIDE; --��λ
      MK.MTRBPOSITION     := MI.MIPOSITION; --ˮ���ˮ��ַ
      MK.MTRBINSCODE      := MI.MIINSCODE; --��װ���
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --�������
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --��������
      MK.MTRBREINSPER     := MI.MIREINSPER; --������
      MK.MTRBCSTATUS      := CI.CISTATUS; --�û�״̬
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --״̬����
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --״̬����
      MK.MTRBNO           := MC.MDNO; --������
      MK.MTRBCALIBER      := MC.MDCALIBER; --��ھ�
      MK.MTRBBRAND        := MC.MDBRAND; --����
      MK.MTRBMODEL        := MC.MDMODEL; --���ͺ�
      MK.MTRBMSTATUS      := MC.MDSTATUS; --��״̬
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      --���
    END IF;
    --��������
    IF FSYSPARA('sys4') = 'Y' THEN
      --�����±�״̬
      UPDATE ST_METERINFO_STORE
         SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
       WHERE BSM = P_MD.MTDMNON;
      IF P_TYPE = BT������� OR P_TYPE = BT��ͣ OR P_TYPE = BTǷ��ͣˮ OR
         P_TYPE = BT��װ OR P_TYPE = BT������ OR P_TYPE = BTˮ������ THEN
        --���¾ɱ�״̬
        UPDATE ST_METERINFO_STORE
           SET --STATUS=P_MD.MTBK4 ,
                  STATUS = '4',
               STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNOO;
      ELSE
        --���¾ɱ�״̬
        UPDATE ST_METERINFO_STORE
           SET --STATUS=P_MD.MTBK4 ,
                  STATUS = '4',
               STATUSDATE = SYSDATE,
               MIID       = NULL
         WHERE BSM = P_MD.MTDMNOO;
      END IF;
    END IF;


    --��� ��������ѿ����Ѵ򿪣�����������0 ������� �������
    IF FSYSPARA('1102') = 'Y' THEN
      --    IF P_MD.MTDADDSL >= ������ˮ�� AND P_MD.MTDADDSL IS NOT NULL THEN
/*      IF P_MD.MTDADDSL >= 0 AND P_MD.MTDADDSL IS NOT NULL THEN*/   --20140506

        if P_TYPE = BT���ڻ��� then
            --��������0 �������
        --20140520 ����������ӵ���ˮ��
        --��������ӳ����meterread
        V_OMRID := TO_CHAR(SYSDATE, 'yyyy.mm');
        SP_INSERTMR(P_PERSON,
                    TO_CHAR(SYSDATE, 'yyyy.mm'),
                    'L',
                    P_MD.MTDADDSL,
                    P_MD.MTDSCODE,
                    P_MD.MTDECODE,
                    P_MD.MTCARRYSL,
                    MI,
                    V_OMRID);
        else
        --��������0 �������
        --20140520 ����������ӵ���ˮ��
        --��������ӳ����meterread
        V_OMRID := TO_CHAR(SYSDATE, 'yyyy.mm');
        SP_INSERTMR(P_PERSON,
                    TO_CHAR(SYSDATE, 'yyyy.mm'),
                    'M',
                    P_MD.MTDADDSL,
                    P_MD.MTDSCODE,
                    P_MD.MTDECODE,
                    P_MD.MTCARRYSL,
                    MI,
                    V_OMRID);
       end if ;
          
       IF P_MD.MTDADDSL > 0 AND P_MD.MTDADDSL IS NOT NULL THEN
          IF V_OMRID IS NOT NULL THEN
              --������ˮ�����ڿգ���ӳɹ�

              --���
              PG_EWIDE_METERREAD_01.CALCULATE(V_OMRID);

              --��֮ǰ���õ�
              PG_EWIDE_RAEDPLAN_01.SP_USEADDINGSL(V_OMRID, --������ˮ
                                                  MA.MASID, --������ˮ
                                                  O_STR --����ֵ
                                                  );

              --���»���ֹ��
              if p_type in (BT���ϻ���, BT���ڻ���) then
                update meterinfo
                   set mircode     = p_md.mtdreinscode, --�������
                       mircodechar = to_char(p_md.mtdreinscode) --�������char
                 where miid = p_md.mtdmid;
              end if;

             -- modify 20140628 ���������־ΪN��δ��ѣ����ϻ������֮����ճ���⣬�û�����������
             for rec_mr in cur_meterread_nocalc(P_MD.Mtdmid,TOOLS.FGETREADMONTH(MI.MISMFID)) loop
                if rec_mr.mrifrec = 'N' and rec_mr.mrdatasource in ('1','5') then
                   delete from meterread where mrid = rec_mr.mrid;
                end if;
             end loop;
                
             

             INSERT INTO METERREADHIS
                  SELECT * FROM METERREAD WHERE MRID = V_OMRID;
             DELETE METERREAD WHERE MRID = V_OMRID;
         END IF;
      elsif P_MD.MTDADDSL = 0  or  P_MD.MTDADDSL IS   NULL then
           --20140512 ��������������δ��ѵ����������¼�����������
        IF P_TYPE = BT���ϻ��� THEN
           v_mrmemo :='���ϻ�������ָ��';
        elsif  P_TYPE = BT���ڻ��� THEN
            v_mrmemo :='���ڻ�������ָ��';
        end if ;
                --���»���ֹ��
        if p_type in (BT���ϻ���, BT���ڻ���) then
          update meterinfo
             set mircode     = p_md.mtdreinscode, --�������
                 mircodechar = to_char(p_md.mtdreinscode) --�������char
           where miid = p_md.mtdmid;
        end if;
        
        -- modify 20140628 ���������־ΪN��δ��ѣ����ϻ������֮����ճ���⣬�û�����������
         for rec_mr in cur_meterread_nocalc(P_MD.Mtdmid,TOOLS.FGETREADMONTH(MI.MISMFID)) loop
            if rec_mr.mrifrec = 'N' and rec_mr.mrdatasource in ('1','5') then
               delete from meterread where mrid = rec_mr.mrid;
            end if;
         end loop;
        
 
        INSERT INTO METERREADHIS
        SELECT * FROM METERREAD WHERE MRID = V_OMRID;
         DELETE METERREAD WHERE MRID = V_OMRID;

      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;
 

  --�����ɹ�
  PROCEDURE SP_METEROUT(P_BILLID IN VARCHAR2, --������ˮ
                        P_DEPT   IN VARCHAR2, --�ɹ�����
                        P_OPER   IN VARCHAR2, --����Ա
                        P_MAN    IN VARCHAR2 --ʩ��Ա
                        ) AS
    MT METERTRANSDT%ROWTYPE;
    MH METERTRANSHD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_BILLID;
      SELECT * INTO MT FROM METERTRANSDT WHERE MTDNO = P_BILLID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, P_BILLID || '->1 ���������ڣ�');
    END;
    UPDATE METERTRANSHD
       SET MTHSHFLAG = 'W', MTHSHDATE = SYSDATE, MTHSHPER = P_OPER
     WHERE MTHNO = P_BILLID;
    INSERT INTO METERTRANSSTATES
      (MTSNO, MTSSHDATE, MTSSHFLAG, MTSSHPER, MTSCREDATE)
      SELECT MTHNO, MTHSHDATE, MTHSHFLAG, MTHSHPER, MTHCREDATE
        FROM METERTRANSHD
       WHERE MTHNO = P_BILLID;
    UPDATE METERTRANSDT
       SET MTDFLAG     = 'W',
           MTDSENTDEPT = P_DEPT,
           MTDSENTDATE = SYSDATE,
           MTDSENTPER  = P_OPER,
           MTDUNINSPER = P_MAN,
           MTDREINSPER = P_MAN
     WHERE MTDNO = P_BILLID;
    IF MH.MTHLB = BTˮ������ THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M������,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BTˮ������
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT������� THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M������,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT�������,
             MIBFID          = NULL
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT�ھ���� THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M�ھ������,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT�ھ����
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BTǷ��ͣˮ THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = MǷ��ͣˮ��,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BTǷ��ͣˮ
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT��ͣ THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M��ͣ��,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT��ͣ
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT��װ THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M��װ��,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT��װ
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BTУ�� THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = MУ����,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BTУ��
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT���ϻ��� THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M���ϻ�����,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT���ϻ���
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT���ڻ��� THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M�ܼ컻����,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT���ڻ���
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT���鹤�� THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M������,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT���鹤��
       WHERE T.MIID = MT.MTDMID;
    END IF;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  --��������
  PROCEDURE SP_METERZF(P_BILLID IN VARCHAR2, --������ˮ
                       P_OPER   IN VARCHAR2 --����Ա
                       ) AS
    MT METERTRANSDT%ROWTYPE;
    MH METERTRANSHD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_BILLID;
      SELECT * INTO MT FROM METERTRANSDT WHERE MTDNO = P_BILLID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, P_BILLID || '->1 ���������ڣ�');
    END;

    UPDATE METERTRANSHD
       SET MTHSHFLAG = 'Q', MTHSHDATE = SYSDATE, MTHSHPER = P_OPER
     WHERE MTHNO = P_BILLID;
    INSERT INTO METERTRANSSTATES
      (MTSNO, MTSSHDATE, MTSSHFLAG, MTSSHPER, MTSCREDATE)
      SELECT MTHNO, MTHSHDATE, MTHSHFLAG, MTHSHPER, MTHCREDATE
        FROM METERTRANSHD
       WHERE MTHNO = P_BILLID;
    UPDATE METERTRANSDT SET MTDFLAG = 'Q' WHERE MTDNO = P_BILLID;
    UPDATE METERINFO
       SET MISTATUS = NVL(MT.MTDMSTATUSO, M����)
     WHERE MIID = MT.MTDMID;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  --���������
  PROCEDURE SP_METERWAITER(P_BILLID IN VARCHAR2, --������ˮ
                           P_OPER   IN VARCHAR2 --����Ա
                           ) AS
    MT METERTRANSDT%ROWTYPE;
    MH METERTRANSHD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_BILLID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, P_BILLID || '->1 ���������ڣ�');
    END;

    UPDATE METERTRANSHD
       SET MTHSHFLAG = 'D', MTHSHDATE = SYSDATE, MTHSHPER = P_OPER
     WHERE MTHNO = P_BILLID;
    INSERT INTO METERTRANSSTATES
      (MTSNO, MTSSHDATE, MTSSHFLAG, MTSSHPER, MTSCREDATE)
      SELECT MTHNO, MTHSHDATE, MTHSHFLAG, MTHSHPER, MTHCREDATE
        FROM METERTRANSHD
       WHERE MTHNO = P_BILLID;
    UPDATE METERTRANSDT SET MTDFLAG = 'D' WHERE MTDNO = P_BILLID;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  --�����ѽ��
  PROCEDURE SP_METEROK(P_BILLID IN VARCHAR2, --������ˮ
                       P_OPER   IN VARCHAR2 --����Ա
                       ) AS
    MT METERTRANSDT%ROWTYPE;
    MH METERTRANSHD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_BILLID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, P_BILLID || '->1 ���������ڣ�');
    END;

    UPDATE METERTRANSHD
       SET MTHSHFLAG = 'Z', MTHSHDATE = SYSDATE, MTHSHPER = P_OPER
     WHERE MTHNO = P_BILLID;
    INSERT INTO METERTRANSSTATES
      (MTSNO, MTSSHDATE, MTSSHFLAG, MTSSHPER, MTSCREDATE)
      SELECT MTHNO, MTHSHDATE, MTHSHFLAG, MTHSHPER, MTHCREDATE
        FROM METERTRANSHD
       WHERE MTHNO = P_BILLID;
    UPDATE METERTRANSDT SET MTDFLAG = 'Z' WHERE MTDNO = P_BILLID;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;
  
   --���봦��
PROCEDURE SP_METERDZ(P_BILLID IN VARCHAR2, --������ˮ
                     P_OPER   IN VARCHAR2, --����Ա
                     P_COMMIT IN VARCHAR2 --�ύ��־
                     ) AS
  CURSOR C_MD(VNO IN METERTGLDT.MTDNO%TYPE) IS
    SELECT * FROM METERTGLDT WHERE MTDNO = VNO ORDER BY MTDROWNO;
  MH METERTGLHD%ROWTYPE;
  MD METERTGLDT%ROWTYPE;
  MT METERTGL%ROWTYPE;
BEGIN
  BEGIN
    SELECT * INTO MH FROM METERTGLHD WHERE MTHNO = P_BILLID;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����ͷ��Ϣ������!');
  END;

  --������Ϣ�Ѿ���˲�������
  IF MH.MTHSHFLAG = 'Y' THEN
    RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѿ����,�����ظ����!');
  END IF;

  --ȡ��������ϸ��
  MD := NULL;
  OPEN C_MD(MH.MTHNO);
  LOOP
    FETCH C_MD
      INTO MD;
    EXIT WHEN C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL;
      --������ʷ��¼��ÿ���û�ֻ����һ����Ч�ĵ����¼
      BEGIN
        UPDATE METERTGL SET MTSTATUS = 'N' WHERE MTMID = MD.MTDMID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    MT := NULL;
    SELECT SYS_GUID() INTO MT.MTSID FROM DUAL; --���
    MT.MTMID      := MD.MTDMID; --�û���
    MT.MTSYSCODE  := MD.MTDSYSCODE; --ϵͳ���������룬ά��ʱ��ϵͳָ�룩
    MT.MTREALCODE := MD.MTDREALCODE; --ʵ�ʶ���
    MT.MTCURCODE  := MT.MTREALCODE; --��ǰ��������ʼ��Ϊʵ�ʶ�����ÿ�γ���ʱ���£�
    MT.MTTGL      := MD.MTDTGL; --�ƹ�����=ϵͳ����-ʵ�ʶ�����
    MT.MTSTATUS   := 'Y'; --��Ч��־���������������ǰ�������ڵ���ϵͳ����ʱ��ΪN��
    MT.MTBILLNO   := MD.MTDNO; --������ˮ
    MT.MTSCRPER   := P_OPER; --������Ա
    MT.MTSCRDATE  := SYSDATE; --����ʱ��
    INSERT INTO METERTGL VALUES MT;
      --����meterinfo �ĵ����־
      UPDATE METERINFO SET MIYL1 ='Y' WHERE MIID=MD.MTDMID;
  END LOOP;
  
    UPDATE METERTGLHD
       SET MTHSHFLAG = 'Y', mthshper = P_OPER, mthshdate = SYSDATE
     WHERE MTHNO = P_BILLID;
  CLOSE C_MD;

  IF P_COMMIT = 'Y' THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF C_MD%ISOPEN THEN
      CLOSE C_MD;
    END IF;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END;


  --����ƻ��������ɹ��ϻ�����
  PROCEDURE SP_MRMRIFSUBMIT(P_MRID   IN VARCHAR2,
                            P_TYPE   IN VARCHAR2,
                            P_SOURCE IN VARCHAR2,
                            P_SMFID  IN VARCHAR2,
                            P_DEPT   IN VARCHAR2,
                            P_OPER   IN VARCHAR2,
                            P_FLAG   IN VARCHAR2) IS
    CURSOR C_EXIST IS
      SELECT *
        FROM METERTRANSHD
       WHERE MTHNO IN
             (SELECT MTDNO
                FROM METERTRANSDT
               WHERE MTDMID =
                     (SELECT MRMID FROM METERREAD WHERE MRID = P_MRID))
         AND MTHSHFLAG NOT IN ('Q', 'Y')
         AND MTHLB = P_TYPE
         FOR UPDATE;

    V_BILLID VARCHAR2(10);
    V_ID     VARCHAR2(10);
    MR       METERREAD%ROWTYPE;
    CI       CUSTINFO%ROWTYPE;
    MI       METERINFO%ROWTYPE;
    MD       METERDOC%ROWTYPE;
    MH       METERTRANSHD%ROWTYPE;
    MT       METERTRANSDT%ROWTYPE;
  BEGIN
    IF P_FLAG = '0' THEN
      --ȡ��
      UPDATE METERREAD SET MRFACE = NULL WHERE MRID = P_MRID;
    ELSE
      --���ɹ���(�ظ��������üӼ�ֵ���������ɹ���)
      BEGIN
        SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '����ƻ�������!');
      END;
      BEGIN
        SELECT * INTO CI FROM CUSTINFO WHERE CIID = MR.MRCID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '�ͻ���Ϣ������!');
      END;
      BEGIN
        SELECT * INTO MI FROM METERINFO WHERE MIID = MR.MRMID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ����Ϣ��Ϣ������!');
      END;
      BEGIN
        SELECT * INTO MD FROM METERDOC WHERE METERDOC.MDMID = MR.MRMID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ������Ϣ��Ϣ������!');
      END;
      BEGIN
        SELECT BMID INTO V_BILLID FROM BILLMAIN WHERE BMTYPE = P_TYPE;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '�������͵���δ����!');
      END;

      --��ǳ���ƻ�ת����־
      UPDATE METERREAD SET MRIFTRANS = 'Y' WHERE MRID = P_MRID;

      OPEN C_EXIST;
      FETCH C_EXIST
        INTO MH;
      IF C_EXIST%NOTFOUND OR C_EXIST%NOTFOUND IS NULL THEN
        --���ɹ���
        TOOLS.SP_BILLSEQ(V_BILLID, V_ID, 'N');

        MH.MTHNO      := V_ID; --������ˮ��
        MH.MTHBH      := MH.MTHNO; --���ݱ��
        MH.MTHLB      := P_TYPE; --�������
        MH.MTHSOURCE  := P_SOURCE; --������Դ
        MH.MTHSMFID   := P_SMFID; --Ӫ����˾
        MH.MTHDEPT    := P_DEPT; --������
        MH.MTHCREDATE := SYSDATE; --��������
        MH.MTHCREPER  := P_OPER; --������Ա
        MH.MTHSHFLAG  := 'N'; --��˱�־
        MH.MTHSHDATE  := NULL; --�������
        MH.MTHSHPER   := NULL; --�����Ա
        MH.MTHHOT     := 1;
        MH.MTHMRID    := P_MRID;
        INSERT INTO METERTRANSHD VALUES MH;

        MT.MTDNO         := MH.MTHNO; --������ˮ
        MT.MTDROWNO      := 1; --�к�
        MT.MTDSMFID      := MI.MISMFID; --Ӫҵ��
        MT.MTDREQUDATE   := SYSDATE + 7; --Ҫ�����ʱ��
        MT.MTDTEL        := CI.CIMTEL; --�绰
        MT.MTDCONPER     := CI.CINAME; --��ϵ��
        MT.MTDCONTEL     := SUBSTR(CI.CIMTEL || ' ' || CI.CITEL1 || ' ' ||
                                   CI.CITEL2 || ' ' || CI.CICONNECTTEL,
                                   90); --��ϵ�绰
        MT.MTDSHDATE     := NULL; --�깤¼������
        MT.MTDSHPER      := NULL; --�깤¼����Ա
        MT.MTDSENTDEPT   := NULL; --�ɹ�����
        MT.MTDSENTDATE   := NULL; --�ɹ�ʱ��
        MT.MTDSENTPER    := NULL; --�ɹ���Ա
        MT.MTDFLAG       := 'N'; --�깤��־��N����S�ɹ�Y�깤X���ϣ�
        MT.MTDCHKPER     := NULL; --��������
        MT.MTDCHKDATE    := NULL; --��������
        MT.MTDCHKMEMO    := NULL; --���ս��
        MT.MTDMID        := MI.MIID; --ԭˮ����
        MT.MTDMCODE      := MI.MICODE; --ԭ���Ϻ�
        MT.MTDMDIDO      := MD.MDID; --ԭ������
        MT.MTDMDIDN      := MD.MDID; --�±�����
        MT.MTDCNAME      := CI.CINAME; --ԭ�û���
        MT.MTDMADRO      := MI.MIADR; --ԭˮ���ַ
        MT.MTDCALIBERO   := MD.MDCALIBER; --ԭ��ھ�
        MT.MTDBRANDO     := MD.MDBRAND; --ԭ����
        MT.MTDMODELO     := MD.MDMODEL; --ԭ���ͺ�
        MT.MTDMNON       := MD.MDNO; --�±����
        MT.MTDCALIBERN   := NULL; --�±�ھ�
        MT.MTDBRANDN     := NULL; --�±���
        MT.MTDMODELN     := NULL; --�±��ͺ�
        MT.MTDPOSITIONO  := MI.MIPOSITION; --ԭ��λ����
        MT.MTDSIDEO      := MI.MISIDE; --ԭ��λ
        MT.MTDMNOO       := MD.MDNO; --ԭ�����
        MT.MTDMADRN      := NULL; --�±�
        MT.MTDPOSITIONN  := NULL; --�±�
        MT.MTDSIDEN      := NULL; --�±�
        MT.MTDUNINSPER   := NULL; --���Ա
        MT.MTDUNINSDATE  := NULL; --�������
        MT.MTDSCODE      := MR.MRECODE; --���ڶ���
        MT.MTDSCODECHAR  := MR.MRECODECHAR;
        MT.MTDECODE      := NULL; --������
        MT.MTDADDSL      := NULL; --����
        MT.MTDREINSPER   := NULL; --����Ա
        MT.MTDREINSDATE  := NULL; --��������
        MT.MTDREINSCODE  := NULL; --�±�����
        MT.MTDREINSDATEO := NULL; --�ع���������
        MT.MTDMSTATUSO   := MI.MISTATUS; --�ع�ˮ��״̬
        MT.MTDAPPNOTE    := NULL; --����˵��
        MT.MTDFILASHNOTE := NULL; --�쵼���
        MT.MTDMEMO       := '�������ϱ�ת��'; --��ע
        MT.MTDYCCHKDATE  := MD.MDCYCCHKDATE;
        MT.MTFACE1       := MR.MRFACE; --ˮ�����
        MT.MTFACE2       := MR.MRFACE2; --��������
        MT.MIFACE4       := MR.MRFACE4; --������
        INSERT INTO METERTRANSDT VALUES MT;
      END IF;
      WHILE C_EXIST%FOUND LOOP
        UPDATE METERTRANSHD
           SET MTHHOT = NVL(MTHHOT, 0) + 1
         WHERE CURRENT OF C_EXIST;
        FETCH C_EXIST
          INTO MH;
      END LOOP;
      CLOSE C_EXIST;
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_EXIST%ISOPEN THEN
        CLOSE C_EXIST;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_MRMRIFSUBMIT;

  --���չ�����������Ƿ�ѹ���
  PROCEDURE SP_CRERECBILL(P_MID    IN VARCHAR2,
                          P_TYPE   IN VARCHAR2,
                          P_SOURCE IN VARCHAR2,
                          P_SMFID  IN VARCHAR2,
                          P_DEPT   IN VARCHAR2,
                          P_OPER   IN VARCHAR2,
                          P_FLAG   IN VARCHAR2) IS
    CURSOR C_EXIST IS
      SELECT *
        FROM METERTRANSHD
       WHERE MTHNO IN (SELECT MTDNO FROM METERTRANSDT WHERE MTDMID = P_MID)
         AND MTHSHFLAG NOT IN ('Q', 'Y')
         AND MTHLB = P_TYPE
         FOR UPDATE;

    V_BILLID VARCHAR2(10);
    V_ID     VARCHAR2(10);
    MR       METERREAD%ROWTYPE;
    CI       CUSTINFO%ROWTYPE;
    MI       METERINFO%ROWTYPE;
    MD       METERDOC%ROWTYPE;
    MH       METERTRANSHD%ROWTYPE;
    MT       METERTRANSDT%ROWTYPE;
  BEGIN
    IF P_FLAG = '0' THEN
      --ȡ��
      NULL;
    ELSE
      --���ɹ���(�ظ��������üӼ�ֵ���������ɹ���)
      BEGIN
        SELECT * INTO MI FROM METERINFO WHERE MIID = P_MID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ����Ϣ��Ϣ������!');
      END;
      BEGIN
        SELECT * INTO CI FROM CUSTINFO WHERE CIID = MI.MICID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '�ͻ���Ϣ������!');
      END;
      BEGIN
        SELECT * INTO MD FROM METERDOC WHERE METERDOC.MDMID = P_MID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ������Ϣ��Ϣ������!');
      END;
      BEGIN
        SELECT BMID INTO V_BILLID FROM BILLMAIN WHERE BMTYPE = P_TYPE;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '�������͵���δ����!');
      END;

      OPEN C_EXIST;
      FETCH C_EXIST
        INTO MH;
      IF C_EXIST%NOTFOUND OR C_EXIST%NOTFOUND IS NULL THEN
        --���ɹ���
        TOOLS.SP_BILLSEQ(V_BILLID, V_ID, 'N');

        MH.MTHNO      := V_ID; --������ˮ��
        MH.MTHBH      := MH.MTHNO; --���ݱ��
        MH.MTHLB      := P_TYPE; --�������
        MH.MTHSOURCE  := P_SOURCE; --������Դ
        MH.MTHSMFID   := P_SMFID; --Ӫ����˾
        MH.MTHDEPT    := P_DEPT; --������
        MH.MTHCREDATE := SYSDATE; --��������
        MH.MTHCREPER  := P_OPER; --������Ա
        MH.MTHSHFLAG  := 'N'; --��˱�־
        MH.MTHSHDATE  := NULL; --�������
        MH.MTHSHPER   := NULL; --�����Ա
        MH.MTHHOT     := 1;
        MH.MTHMRID    := NULL;
        INSERT INTO METERTRANSHD VALUES MH;

        MT.MTDNO         := MH.MTHNO; --������ˮ
        MT.MTDROWNO      := 1; --�к�
        MT.MTDSMFID      := MI.MISMFID; --Ӫҵ��
        MT.MTDREQUDATE   := SYSDATE + 7; --Ҫ�����ʱ��
        MT.MTDTEL        := CI.CIMTEL; --�绰
        MT.MTDCONPER     := CI.CINAME; --��ϵ��
        MT.MTDCONTEL     := CI.CICONNECTTEL; --��ϵ�绰
        MT.MTDSHDATE     := NULL; --�깤¼������
        MT.MTDSHPER      := NULL; --�깤¼����Ա
        MT.MTDSENTDEPT   := NULL; --�ɹ�����
        MT.MTDSENTDATE   := NULL; --�ɹ�ʱ��
        MT.MTDSENTPER    := NULL; --�ɹ���Ա
        MT.MTDFLAG       := 'N'; --�깤��־��N����S�ɹ�Y�깤X���ϣ�
        MT.MTDCHKPER     := NULL; --��������
        MT.MTDCHKDATE    := NULL; --��������
        MT.MTDCHKMEMO    := NULL; --���ս��
        MT.MTDMID        := MI.MIID; --ԭˮ����
        MT.MTDMCODE      := MI.MICODE; --ԭ���Ϻ�
        MT.MTDMDIDO      := MD.MDID; --ԭ������
        MT.MTDMDIDN      := MD.MDID; --�±�����
        MT.MTDCNAME      := CI.CINAME; --ԭ�û���
        MT.MTDMADRO      := MI.MIADR; --ԭˮ���ַ
        MT.MTDCALIBERO   := MD.MDCALIBER; --ԭ��ھ�
        MT.MTDBRANDO     := MD.MDBRAND; --ԭ����
        MT.MTDMODELO     := MD.MDMODEL; --ԭ���ͺ�
        MT.MTDMNON       := MD.MDNO; --�±����
        MT.MTDCALIBERN   := NULL; --�±�ھ�
        MT.MTDBRANDN     := NULL; --�±���
        MT.MTDMODELN     := NULL; --�±��ͺ�
        MT.MTDPOSITIONO  := NULL; --ԭ��λ����
        MT.MTDSIDEO      := NULL; --ԭ��λ
        MT.MTDMNOO       := MD.MDNO; --ԭ�����
        MT.MTDMADRN      := NULL; --�±�
        MT.MTDPOSITIONN  := NULL; --�±�
        MT.MTDSIDEN      := NULL; --�±�
        MT.MTDUNINSPER   := NULL; --���Ա
        MT.MTDUNINSDATE  := NULL; --�������
        MT.MTDSCODE      := MR.MRECODE; --���ڶ���
        MT.MTDSCODECHAR  := MR.MRECODECHAR;
        MT.MTDECODE      := NULL; --������
        MT.MTDADDSL      := NULL; --����
        MT.MTDREINSPER   := NULL; --����Ա
        MT.MTDREINSDATE  := NULL; --��������
        MT.MTDREINSCODE  := NULL; --�±�����
        MT.MTDREINSDATEO := NULL; --�ع���������
        MT.MTDMSTATUSO   := NULL; --�ع�ˮ��״̬
        MT.MTDAPPNOTE    := NULL; --����˵��
        MT.MTDFILASHNOTE := NULL; --�쵼���
        MT.MTDMEMO       := '����ת��'; --��ע
        INSERT INTO METERTRANSDT VALUES MT;
      END IF;
      WHILE C_EXIST%FOUND LOOP
        UPDATE METERTRANSHD
           SET MTHHOT = NVL(MTHHOT, 0) + 1
         WHERE CURRENT OF C_EXIST;
        FETCH C_EXIST
          INTO MH;
      END LOOP;
      CLOSE C_EXIST;
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_EXIST%ISOPEN THEN
        CLOSE C_EXIST;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_CRERECBILL;

  --����ƻ��������ɹ��ϻ�����
  PROCEDURE SP_BUILDZJBILL(P_NUM    IN VARCHAR2, --ˮ����
                           P_TYPE   IN VARCHAR2, --��������
                           P_SOURCE IN VARCHAR2, --������Դ
                           P_SMFID  IN VARCHAR2, --Ӫҵ��
                           P_DEPT   IN VARCHAR2, --����
                           P_OPER   IN VARCHAR2) IS
    --������
    /*  cursor c_exist is
    select * from metertranshd
    where mthno in (select mtdno from metertransdt
                   where mtdmid=(select mrmid from meterread where mrid=p_mrid)
                   ) and
          mthshflag not in ('Q','Y') and mthlb=p_type
    for update;*/
    ROWCNT   INT;
    N        NUMBER;
    V_BILLID VARCHAR2(10);
    V_ID     VARCHAR2(10);
    MH       METERTRANSHD%ROWTYPE;
    MT       METERTRANSDT%ROWTYPE;
  BEGIN
    /*begin
      select * into ci from custinfo where ciid=mr.mrcid;
    exception when others then
      raise_application_error(errcode, '�ͻ���Ϣ������!');
    end;
    begin
      select * into mi from meterinfo where miid=mr.mrmid;
    exception when others then
      raise_application_error(errcode, 'ˮ����Ϣ��Ϣ������!');
    end;
    begin
      select * into md from meterdoc where meterdoc.mdmid =mr.mrmid;
    exception when others then
      raise_application_error(errcode, 'ˮ������Ϣ��Ϣ������!');
    end;*/
    BEGIN
      SELECT BMID INTO V_BILLID FROM BILLMAIN WHERE BMTYPE = P_TYPE;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�������͵���δ����!');
    END;

    --��ǳ���ƻ�ת����־

    SELECT COUNT(*)
      INTO N
      FROM CUSTINFO, METERINFO, METERDOC, BOOKFRAME
     WHERE MIID = MDMID
       AND BFID = MIBFID
       AND MISMFID = BFSMFID
       AND CIID = MICID
       AND MIID IN (SELECT C1 FROM PBPARMTEMP);
    IF P_NUM <> N THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��������ʧ��!' || SQLERRM);
    END IF;
    FOR CMMB IN (SELECT *
                   FROM CUSTINFO, METERINFO, METERDOC, BOOKFRAME
                  WHERE MIID = MDMID
                    AND BFID = MIBFID
                    AND MISMFID = BFSMFID
                    AND CIID = MICID
                    AND MIID IN (SELECT C1 FROM PBPARMTEMP)) LOOP
      --���ɹ���
      TOOLS.SP_BILLSEQ(V_BILLID, V_ID, 'N');

      MH.MTHNO      := V_ID; --������ˮ��
      MH.MTHBH      := MH.MTHNO; --���ݱ��
      MH.MTHLB      := P_TYPE; --�������
      MH.MTHSOURCE  := P_SOURCE; --������Դ
      MH.MTHSMFID   := P_SMFID; --Ӫ����˾
      MH.MTHDEPT    := P_DEPT; --������
      MH.MTHCREDATE := SYSDATE; --��������
      MH.MTHCREPER  := P_OPER; --������Ա
      MH.MTHSHFLAG  := 'N'; --��˱�־
      MH.MTHSHDATE  := NULL; --�������
      MH.MTHSHPER   := NULL; --�����Ա
      MH.MTHHOT     := 1;
      MH.MTHMRID    := NULL;
      INSERT INTO METERTRANSHD VALUES MH;

      MT.MTDNO         := MH.MTHNO; --������ˮ
      MT.MTDROWNO      := 1; --�к�
      MT.MTDSMFID      := CMMB.MISMFID; --Ӫҵ��
      MT.MTDREQUDATE   := SYSDATE + 7; --Ҫ�����ʱ��
      MT.MTDTEL        := CMMB.CITEL1; --�绰
      MT.MTDCONPER     := CMMB.CINAME; --��ϵ��
      MT.MTDCONTEL     := CMMB.CICONNECTTEL; --��ϵ�绰
      MT.MTDSHDATE     := NULL; --�깤¼������
      MT.MTDSHPER      := NULL; --�깤¼����Ա
      MT.MTDSENTDEPT   := NULL; --�ɹ�����
      MT.MTDSENTDATE   := NULL; --�ɹ�ʱ��
      MT.MTDSENTPER    := NULL; --�ɹ���Ա
      MT.MTDFLAG       := 'N'; --�깤��־��N����S�ɹ�Y�깤X���ϣ�
      MT.MTDCHKPER     := NULL; --��������
      MT.MTDCHKDATE    := NULL; --��������
      MT.MTDCHKMEMO    := NULL; --���ս��
      MT.MTDMID        := CMMB.MIID; --ԭˮ����
      MT.MTDMCODE      := CMMB.MICODE; --ԭ���Ϻ�
      MT.MTDMDIDO      := CMMB.MDID; --ԭ������
      MT.MTDMDIDN      := CMMB.MDID; --�±�����
      MT.MTDCNAME      := CMMB.CINAME; --ԭ�û���
      MT.MTDMADRO      := CMMB.MIADR; --ԭˮ���ַ
      MT.MTDCALIBERO   := CMMB.MDCALIBER; --ԭ��ھ�
      MT.MTDBRANDO     := CMMB.MDBRAND; --ԭ����
      MT.MTDMTYPEO     := CMMB.MITYPE;
      MT.MTDMODELO     := CMMB.MDMODEL;
      MT.MTDMNON       := CMMB.MDNO; --�±����
      MT.MTDCALIBERN   := NULL; --�±�ھ�
      MT.MTDBRANDN     := NULL; --�±���
      MT.MTDMODELN     := NULL; --�±��ͺ�
      MT.MTDPOSITIONO  := CMMB.MIPOSITION; --ԭ��ˮ��ַ
      MT.MTDSIDEO      := CMMB.MISIDE; --ԭ��λ
      MT.MTDMNOO       := CMMB.MDNO; --ԭ�����
      MT.MTDMADRN      := NULL; --�±�
      MT.MTDPOSITIONN  := NULL; --�±�
      MT.MTDSIDEN      := NULL; --�±�
      MT.MTDUNINSPER   := NULL; --���Ա
      MT.MTDUNINSDATE  := NULL; --�������
      MT.MTDSCODE      := CMMB.MIRCODE; --���ڶ���
      MT.MTDSCODECHAR  := CMMB.MIRCODECHAR;
      MT.MTDECODE      := NULL; --������
      MT.MTDADDSL      := NULL; --����
      MT.MTDREINSPER   := NULL; --����Ա
      MT.MTDREINSDATE  := NULL; --��������
      MT.MTDREINSCODE  := NULL; --�±�����
      MT.MTDREINSDATEO := NULL; --�ع���������
      MT.MTDMSTATUSO   := NULL; --�ع�ˮ��״̬
      MT.MTDAPPNOTE    := NULL; --����˵��
      MT.MTDFILASHNOTE := NULL; --�쵼���
      MT.MTDMEMO       := '�ܼ컻����������'; --��ע
      MT.MTFACE1       := CMMB.MIFACE; --ˮ�����
      MT.MTFACE2       := CMMB.MIFACE2; --��������
      MT.MIFACE4       := CMMB.MIFACE4; --������
      INSERT INTO METERTRANSDT VALUES MT;
      ROWCNT := SQL%ROWCOUNT;
      IF ROWCNT < 1 THEN
        RAISE_APPLICATION_ERROR(-20010, '��������ʧ��!' || SQLERRM);
      END IF;
    END LOOP;

    COMMIT;
    /*      while c_exist%found loop
      update metertranshd set mthhot=nvl(mthhot,0)+1 where current of c_exist;
      fetch c_exist into mh;
    end loop;
    close c_exist;*/
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_BUILDZJBILL;

  PROCEDURE SP_INSERTMR(P_PPER    IN VARCHAR2, --����Ա
                        P_MONTH   IN VARCHAR2, --Ӧ���·�
                        P_MRTRANS IN VARCHAR2, --��������
                        P_RLSL    IN NUMBER, --Ӧ��ˮ��
                        P_SCODE   IN NUMBER, --����
                        P_ECODE   IN NUMBER, --ֹ��
                        P_CARRYSL    IN NUMBER, --����ˮ��
                        MI        IN METERINFO%ROWTYPE, --ˮ����Ϣ
                        OMRID     OUT METERREAD.MRID%TYPE --������ˮ
                        ) AS
    MR METERREAD%ROWTYPE; --�����
    CI    CUSTINFO%ROWTYPE; --�û���Ϣ
  BEGIN
    BEGIN
      SELECT * INTO CI FROM CUSTINFO WHERE CIID = MI.MICID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20010, '�û�������!');
    END;

    MR.MRID    := FGETSEQUENCE('METERREAD'); --��ˮ��
    OMRID         := MR.MRID;
    MR.MRMONTH := TOOLS.FGETREADMONTH(MI.MISMFID); --�����·�
    MR.MRSMFID := FGETMETERINFO(MI.MIID, 'MISMFID'); --Ӫ����˾
    MR.MRBFID  := MI.MIBFID /*rth.RTHBFID*/
     ; --���
    BEGIN
      SELECT BFBATCH
        INTO MR.MRBATCH
        FROM BOOKFRAME
       WHERE BFID = MI.MIBFID
         AND BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRBATCH := 1; --��������
    END;

    BEGIN
      SELECT MRBSDATE
        INTO MR.MRDAY
        FROM METERREADBATCH
       WHERE MRBSMFID = MI.MISMFID
         AND MRBMONTH = MR.MRMONTH
         AND MRBBATCH = MR.MRBATCH;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRDAY := SYSDATE; --�ƻ�������
      /* if fsyspara('0039')='Y' then--�Ƿ񰴼ƻ������ո���ʵ�ʳ�����
            raise_application_error(ErrCode, 'ȡ�ƻ������մ�������ƻ��������ζ���');
      end if;*/
    END;
    MR.MRDAY       := SYSDATE; --�ƻ�������
    MR.MRRORDER    := MI.MIRORDER; --�������
    MR.MRCID       := CI.CIID; --�û����
    MR.MRCCODE     := CI.CICODE; --�û���
    MR.MRMID       := MI.MIID; --ˮ����
    MR.MRMCODE     := MI.MICODE; --ˮ���ֹ����
    MR.MRSTID      := MI.MISTID; --��ҵ����
    MR.MRMPID      := MI.MIPID; --�ϼ�ˮ��
    MR.MRMCLASS    := MI.MICLASS; --ˮ����
    MR.MRMFLAG     := MI.MIFLAG; --ĩ����־
    MR.MRCREADATE  := SYSDATE; --��������
    MR.MRINPUTDATE := SYSDATE; --�༭����
    MR.MRREADOK    := 'Y'; --������־
    MR.MRRDATE     := SYSDATE /*TO_DATE(p_month||'.15','YYYY.MM.DD') */
     ; --��������
    BEGIN
      SELECT MAX(T.BFRPER)
        INTO MR.MRRPER
        FROM BOOKFRAME T
       WHERE T.BFID = MI.MIBFID
         AND T.BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRRPER := P_PPER; --Ԥ�� �ճ���Ա
    END;
    MR.MRPRDATE        := NULL; --�ϴγ�������
    MR.MRSCODE         := P_SCODE; --���ڳ���
    MR.MRECODE         := P_ECODE; --���ڳ���
    MR.MRSL            := P_RLSL-NVL(P_CARRYSL,0); --����ˮ��
    MR.MRFACE          := NULL; --ˮ�����
    MR.MRIFSUBMIT      := 'Y'; --�Ƿ��ύ�Ʒ�
    MR.MRIFHALT        := 'N'; --ϵͳͣ��
    MR.MRDATASOURCE    := P_MRTRANS; --��������Դ�����񳭱� L-���ڻ���
    MR.MRIFIGNOREMINSL := 'N'; --ͣ����ͳ���
    MR.MRPDARDATE      := NULL; --���������ʱ��
    MR.MROUTFLAG       := 'N'; --�������������־
    MR.MROUTID         := NULL; --�������������ˮ��
    MR.MROUTDATE       := NULL; --���������������
    MR.MRINORDER       := NULL; --��������մ���
    MR.MRINDATE        := NULL; --�������������
    MR.MRRPID          := NULL; --�Ƽ�����
    if P_MRTRANS='L' THEN
          MR.MRMEMO          := '���ڻ�������Ƿ��'; --����ע
    ELSE 
         MR.MRMEMO          := '��������Ƿ��'; --����ע
    END IF ;
    MR.MRIFGU          := 'N'; --�����־
    MR.MRIFREC         := 'N'; --�ѼƷ�
    MR.MRRECDATE       := SYSDATE; --�Ʒ�����
    MR.MRRECSL         := P_RLSL-NVL(P_CARRYSL,0); --Ӧ��ˮ��
   --  MR.MRADDSL         := 0; --���� 
   --add 20140809 ���ϻ���ʱ���ܱ�����д�������У���������г���ʱ����ץȡ�������ж�
    if P_MRTRANS='M' and MI.Miclass ='2' THEN  
        MR.MRADDSL  :=  P_RLSL; --����
    ELSE
       MR.MRADDSL         := 0; --����
    END IF ;
    MR.MRCARRYSL       := NVL(P_CARRYSL,0); --��λˮ��
    MR.MRCTRL1         := NULL; --���������λ1
    MR.MRCTRL2         := NULL; --���������λ2
    MR.MRCTRL3         := NULL; --���������λ3
    MR.MRCTRL4         := NULL; --���������λ4
    MR.MRCTRL5         := NULL; --���������λ5
    MR.MRCHKFLAG       := 'N'; --���˱�־
    MR.MRCHKDATE       := NULL; --��������
    MR.MRCHKPER        := NULL; --������Ա
    MR.MRCHKSCODE      := NULL; --ԭ����
    MR.MRCHKECODE      := NULL; --ԭֹ��
    MR.MRCHKSL         := NULL; --ԭˮ��
    MR.MRCHKADDSL      := NULL; --ԭ����
    MR.MRCHKCARRYSL    := NULL; --ԭ��λˮ��
    MR.MRCHKRDATE      := NULL; --ԭ��������
    MR.MRCHKFACE       := NULL; --ԭ���
    MR.MRCHKRESULT     := NULL; --���������
    MR.MRCHKRESULTMEMO := NULL; --�����˵��
    MR.MRPRIMID        := MI.MIPRIID; --���ձ�����
    MR.MRPRIMFLAG      := MI.MIPRIFLAG; --���ձ��־
    MR.MRLB            := MI.MILB; --ˮ�����
    MR.MRNEWFLAG       := NULL; --�±��־
    MR.MRFACE2         := NULL; --��������
    MR.MRFACE3         := NULL; --�ǳ�����
    MR.MRFACE4         := NULL; --����ʩ˵��
    MR.MRSCODECHAR     := TO_CHAR(P_SCODE); --���ڳ���
    MR.MRECODECHAR     := TO_CHAR(P_ECODE); --���ڳ���
    MR.MRPRIVILEGEFLAG := 'N'; --��Ȩ��־(Y/N)
    MR.MRPRIVILEGEPER  := NULL; --��Ȩ������
    MR.MRPRIVILEGEMEMO := NULL; --��Ȩ������ע
    MR.MRPRIVILEGEDATE := NULL; --��Ȩ����ʱ��
    MR.MRSAFID         := MI.MISAFID; --��������
    MR.MRIFTRANS       := 'N'; --��������
    MR.MRREQUISITION   := 0; --֪ͨ����ӡ����
    MR.MRIFCHK         := MI.MIIFCHK; --���˱�
    INSERT INTO METERREAD VALUES MR;
  END;
  
  PROCEDURE SP_INSERTMRHIS(P_PPER    IN VARCHAR2, --����Ա
                        P_MONTH   IN VARCHAR2, --Ӧ���·�
                        P_MRTRANS IN VARCHAR2, --��������
                        P_RLSL    IN NUMBER, --Ӧ��ˮ��
                        P_SCODE   IN NUMBER, --����
                        P_ECODE   IN NUMBER, --ֹ��
                        P_CARRYSL    IN NUMBER, --����ˮ��
                        MI        IN METERINFO%ROWTYPE, --ˮ����Ϣ
                        OMRID     OUT METERREADHIS.MRID%TYPE --������ˮ
                        ) AS
    MRHIS METERREADHIS%ROWTYPE; --������ʷ��
    CI    CUSTINFO%ROWTYPE; --�û���Ϣ
  BEGIN
    BEGIN
      SELECT * INTO CI FROM CUSTINFO WHERE CIID = MI.MICID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20010, '�û�������!');
    END;

    MRHIS.MRID    := FGETSEQUENCE('METERREAD'); --��ˮ��
    OMRID         := MRHIS.MRID;
    MRHIS.MRMONTH := TOOLS.FGETREADMONTH(MI.MISMFID); --�����·�
    MRHIS.MRSMFID := FGETMETERINFO(MI.MIID, 'MISMFID'); --Ӫ����˾
    MRHIS.MRBFID  := MI.MIBFID /*rth.RTHBFID*/
     ; --���
    BEGIN
      SELECT BFBATCH
        INTO MRHIS.MRBATCH
        FROM BOOKFRAME
       WHERE BFID = MI.MIBFID
         AND BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MRHIS.MRBATCH := 1; --��������
    END;

    BEGIN
      SELECT MRBSDATE
        INTO MRHIS.MRDAY
        FROM METERREADBATCH
       WHERE MRBSMFID = MI.MISMFID
         AND MRBMONTH = MRHIS.MRMONTH
         AND MRBBATCH = MRHIS.MRBATCH;
    EXCEPTION
      WHEN OTHERS THEN
        MRHIS.MRDAY := SYSDATE; --�ƻ�������
      /* if fsyspara('0039')='Y' then--�Ƿ񰴼ƻ������ո���ʵ�ʳ�����
            raise_application_error(ErrCode, 'ȡ�ƻ������մ�������ƻ��������ζ���');
      end if;*/
    END;
    MRHIS.MRDAY       := SYSDATE; --�ƻ�������
    MRHIS.MRRORDER    := MI.MIRORDER; --�������
    MRHIS.MRCID       := CI.CIID; --�û����
    MRHIS.MRCCODE     := CI.CICODE; --�û���
    MRHIS.MRMID       := MI.MIID; --ˮ����
    MRHIS.MRMCODE     := MI.MICODE; --ˮ���ֹ����
    MRHIS.MRSTID      := MI.MISTID; --��ҵ����
    MRHIS.MRMPID      := MI.MIPID; --�ϼ�ˮ��
    MRHIS.MRMCLASS    := MI.MICLASS; --ˮ����
    MRHIS.MRMFLAG     := MI.MIFLAG; --ĩ����־
    MRHIS.MRCREADATE  := SYSDATE; --��������
    MRHIS.MRINPUTDATE := SYSDATE; --�༭����
    MRHIS.MRREADOK    := 'Y'; --������־
    MRHIS.MRRDATE     := SYSDATE /*TO_DATE(p_month||'.15','YYYY.MM.DD') */
     ; --��������
    BEGIN
      SELECT MAX(T.BFRPER)
        INTO MRHIS.MRRPER
        FROM BOOKFRAME T
       WHERE T.BFID = MI.MIBFID
         AND T.BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MRHIS.MRRPER := P_PPER; --Ԥ�� �ճ���Ա
    END;
    MRHIS.MRPRDATE        := NULL; --�ϴγ�������
    MRHIS.MRSCODE         := P_SCODE; --���ڳ���
    MRHIS.MRECODE         := P_ECODE; --���ڳ���
    MRHIS.MRSL            := P_RLSL-NVL(P_CARRYSL,0); --����ˮ��
    MRHIS.MRFACE          := NULL; --ˮ�����
    MRHIS.MRIFSUBMIT      := 'Y'; --�Ƿ��ύ�Ʒ�
    MRHIS.MRIFHALT        := 'N'; --ϵͳͣ��
    MRHIS.MRDATASOURCE    := P_MRTRANS; --��������Դ�����񳭱�
    MRHIS.MRIFIGNOREMINSL := 'N'; --ͣ����ͳ���
    MRHIS.MRPDARDATE      := NULL; --���������ʱ��
    MRHIS.MROUTFLAG       := 'N'; --�������������־
    MRHIS.MROUTID         := NULL; --�������������ˮ��
    MRHIS.MROUTDATE       := NULL; --���������������
    MRHIS.MRINORDER       := NULL; --��������մ���
    MRHIS.MRINDATE        := NULL; --�������������
    MRHIS.MRRPID          := NULL; --�Ƽ�����
    MRHIS.MRMEMO          := '��������Ƿ��'; --����ע
    MRHIS.MRIFGU          := 'N'; --�����־
    MRHIS.MRIFREC         := 'N'; --�ѼƷ�
    MRHIS.MRRECDATE       := SYSDATE; --�Ʒ�����
    MRHIS.MRRECSL         := P_RLSL-NVL(P_CARRYSL,0); --Ӧ��ˮ��
    MRHIS.MRADDSL         := 0; --����
    MRHIS.MRCARRYSL       := NVL(P_CARRYSL,0); --��λˮ��
    MRHIS.MRCTRL1         := NULL; --���������λ1
    MRHIS.MRCTRL2         := NULL; --���������λ2
    MRHIS.MRCTRL3         := NULL; --���������λ3
    MRHIS.MRCTRL4         := NULL; --���������λ4
    MRHIS.MRCTRL5         := NULL; --���������λ5
    MRHIS.MRCHKFLAG       := 'N'; --���˱�־
    MRHIS.MRCHKDATE       := NULL; --��������
    MRHIS.MRCHKPER        := NULL; --������Ա
    MRHIS.MRCHKSCODE      := NULL; --ԭ����
    MRHIS.MRCHKECODE      := NULL; --ԭֹ��
    MRHIS.MRCHKSL         := NULL; --ԭˮ��
    MRHIS.MRCHKADDSL      := NULL; --ԭ����
    MRHIS.MRCHKCARRYSL    := NULL; --ԭ��λˮ��
    MRHIS.MRCHKRDATE      := NULL; --ԭ��������
    MRHIS.MRCHKFACE       := NULL; --ԭ���
    MRHIS.MRCHKRESULT     := NULL; --���������
    MRHIS.MRCHKRESULTMEMO := NULL; --�����˵��
    MRHIS.MRPRIMID        := MI.MIPRIID; --���ձ�����
    MRHIS.MRPRIMFLAG      := MI.MIPRIFLAG; --���ձ��־
    MRHIS.MRLB            := MI.MILB; --ˮ�����
    MRHIS.MRNEWFLAG       := NULL; --�±��־
    MRHIS.MRFACE2         := NULL; --��������
    MRHIS.MRFACE3         := NULL; --�ǳ�����
    MRHIS.MRFACE4         := NULL; --����ʩ˵��
    MRHIS.MRSCODECHAR     := TO_CHAR(P_SCODE); --���ڳ���
    MRHIS.MRECODECHAR     := TO_CHAR(P_ECODE); --���ڳ���
    MRHIS.MRPRIVILEGEFLAG := 'N'; --��Ȩ��־(Y/N)
    MRHIS.MRPRIVILEGEPER  := NULL; --��Ȩ������
    MRHIS.MRPRIVILEGEMEMO := NULL; --��Ȩ������ע
    MRHIS.MRPRIVILEGEDATE := NULL; --��Ȩ����ʱ��
    MRHIS.MRSAFID         := MI.MISAFID; --��������
    MRHIS.MRIFTRANS       := 'N'; --��������
    MRHIS.MRREQUISITION   := 0; --֪ͨ����ӡ����
    MRHIS.MRIFCHK         := MI.MIIFCHK; --���˱�
    INSERT INTO METERREADHIS VALUES MRHIS;
  END;
 
  
BEGIN
  ������ˮ�� := TO_NUMBER(FSYSPARA('1092'));
END;
/

