CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_RAEDPLAN_01" IS
  CURRENTDATE DATE := TOOLS.FGETSYSDATE;

  MSL METER_STATIC_LOG%ROWTYPE;
  /*
  ������ҳ���ύ����
  ������p_mtab�� ��ʱ������(PBPARMTEMP.c1)����ŵ��κ�Ŀ����������ˮ����c1,�������c2
        p_smfid: Ŀ��Ӫҵ��
        p_bfid:  Ŀ����
        p_oper�� ����ԱID
  ����1�����³������
        2�����±��
        3�����ţ���ҳ�ţ���ʼ��
        4������ϵͳ��������γ���ʷ�������
  �������
  */
  PROCEDURE METERBOOK(P_SMFID IN VARCHAR2,
                      P_BFID  IN VARCHAR2,
                      P_OPER  IN VARCHAR2) IS
    CURSOR C_MTAB IS
      SELECT C1, C2, C3, C4 FROM PBPARMTEMP ORDER BY TO_NUMBER(C2);

    PVAL      PBPARMTEMP%ROWTYPE;
    CCH       CUSTCHANGEHD%ROWTYPE;
    MI        METERINFO%ROWTYPE;
    VMISEQNO  VARCHAR2(20);
    VMISEQNO1 VARCHAR2(20);
    N         INTEGER;
    BF        BOOKFRAME%ROWTYPE;
  BEGIN
    SELECT *
      INTO BF
      FROM BOOKFRAME
     WHERE BFSMFID = P_SMFID
       AND BFID = P_BFID;
    --�ر���ʱ���α�ǰ����commit���,������ʱ�����
    /* Tools.SP_BillSeq('003', cch.cchno, 'N');
    --��������˱����
    cch.cchbh      := cch.cchno;
    cch.cchlb      := 'B';
    cch.cchsource  := '2';
    cch.cchsmfid   := p_smfid;
    cch.cchdept    := null;
    cch.cchcredate := sysdate;
    cch.cchcreper  := p_oper;
    cch.cchshdate  := sysdate;
    cch.cchshper   := p_oper;
    cch.cchshflag  := 'Y';
    cch.cchwfid    := null;
    insert into custchangehd values cch;*/
    --���»��ţ��ӹ�PBPARMTEMP.c3������
    --ĩβ׷��(�����±��λ�ú���ԭ���)
    --�м����(�����±��λ�ú���ԭ���)
    N := 0;
    OPEN C_MTAB;
    LOOP
      FETCH C_MTAB
        INTO PVAL.C1, PVAL.C2, PVAL.C3, PVAL.C4;
      EXIT WHEN C_MTAB%NOTFOUND OR C_MTAB%NOTFOUND IS NULL;
      BEGIN
        SELECT * INTO MI FROM METERINFO WHERE MIID = PVAL.C1;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || PVAL.C1);
      END;

      IF MI.MIBFID <> P_BFID OR MI.MIBFID IS NULL THEN
        N := N + 1;
        UPDATE PBPARMTEMP
           SET C3 = VMISEQNO1, C4 = TO_CHAR(N)
         WHERE C1 = PVAL.C1;
      ELSE
        VMISEQNO1 := MI.MISEQNO;
        N         := 0;
      END IF;
    END LOOP;
    CLOSE C_MTAB;

    OPEN C_MTAB;
    LOOP
      FETCH C_MTAB
        INTO PVAL.C1, PVAL.C2, PVAL.C3, PVAL.C4;
      EXIT WHEN C_MTAB%NOTFOUND OR C_MTAB%NOTFOUND IS NULL;
      BEGIN
        SELECT * INTO MI FROM METERINFO WHERE MIID = PVAL.C1;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || PVAL.C1);
      END;
      IF PVAL.C4 IS NOT NULL THEN
        IF INSTR(PVAL.C3, '-') > 0 THEN
          VMISEQNO := SUBSTR(PVAL.C3, 1, INSTR(PVAL.C3, '-') - 1) || '-' ||
                      TO_CHAR(TO_NUMBER(SUBSTR(PVAL.C3,
                                               INSTR(PVAL.C3, '-') + 1)) +
                              TO_NUMBER(PVAL.C4));
        ELSIF PVAL.C3 IS NULL THEN
          IF VMISEQNO1 IS NOT NULL THEN
            VMISEQNO := P_BFID || '-' || PVAL.C4;
          ELSE
            VMISEQNO := P_BFID || LPAD(PVAL.C4, 3, '0');
          END IF;
        ELSE
          VMISEQNO := PVAL.C3 || '-' || PVAL.C4;
        END IF;
      ELSE
        VMISEQNO := MI.MISEQNO;
      END IF;
      /*
            insert into custchangedt
              select cch.cchno,
                     to_number(pval.c2),
                     ci.ciid, --�û����
                     ci.cicode, --�û���
                     ci.ciconid, --��װ��ͬ���
                     ci.cismfid, --Ӫ����˾
                     ci.cipid, --�ϼ��û����
                     ci.ciclass, --�û�����
                     ci.ciflag, --ĩ����־
                     ci.ciname, --�û�����
                     ci.ciname2, --������
                     ci.ciadr, --�û���ַ
                     ci.cistatus, --�û�״̬
                     ci.cistatusdate, --״̬����
                     ci.cistatustrans, --״̬����
                     ci.cinewdate, --��������
                     ci.ciidentitylb, --֤������
                     ci.ciidentityno, --֤������
                     ci.cimtel, --�ƶ��绰
                     ci.citel1, --�̶��绰1
                     ci.citel2, --�̶��绰2
                     ci.citel3, --�̶��绰3
                     ci.ciconnectper, --��ϵ��
                     ci.ciconnecttel, --��ϵ�绰
                     ci.ciifinv, --�Ƿ���Ʊ
                     ci.ciifsms, --�Ƿ��ṩ���ŷ���
                     ci.ciifzn, --�Ƿ����ɽ�
                     ci.ciprojno, --���̱��
                     ci.cifileno, --������
                     ci.cimemo, --��ע��Ϣ
                     ci.cideptid, --��������
                     mi.micid, --�û����
                     mi.miid, --ˮ����
                     mi.miadr, --���ַ
                     bf.bfsafid, --����
                     mi.micode, --ˮ���ֹ����
                     mi.mismfid, --Ӫ����˾
                     mi.miprmon, --���ڳ����·�
                     mi.mirmon, --���ڳ����·�
                     \*�����*\
                     (case
                       when lower(p_bfid) = 'null' then
                        null
                       else
                        p_bfid
                     end), --���
                     \*�����*\
                     (case
                       when lower(p_bfid) = 'null' then
                        null
                       else
                        to_number(pval.c2)
                     end), --�������
                     mi.mipid, --�ϼ�ˮ����
                     mi.miclass, --ˮ����
                     mi.miflag, --ĩ����־
                     mi.mirtid, --����ʽ
                     mi.miifmp, --�����ˮ��־
                     mi.miifsp, --���ⵥ�۱�־
                     mi.mistid, --��ҵ����
                     mi.mipfid, --�۸����
                     mi.mistatus, --��Ч״̬
                     mi.mistatusdate, --״̬����
                     mi.mistatustrans, --״̬����
                     mi.miface, --���
                     mi.mirpid, --�Ƽ�����
                     mi.miside, --��λ
                     mi.miposition, --ˮ���ˮ��ַ
                     mi.miinscode, --��װ���
                     mi.miinsdate, --װ������
                     mi.miinsper, --��װ��
                     mi.mireinscode, --�������
                     mi.mireinsdate, --��������
                     mi.mireinsper, --������
                     mi.mitype, --����
                     mi.mircode, --���ڶ���
                     mi.mirecdate, --���ڳ�������
                     mi.mirecsl, --���ڳ���ˮ��
                     mi.miifcharge, --�Ƿ�Ʒ�
                     mi.miifsl, --�Ƿ����
                     mi.miifchk, --�Ƿ񿼺˱�
                     mi.miifwatch, --�Ƿ��ˮ
                     mi.miicno, --ic����
                     mi.mimemo, --��ע��Ϣ
                     mi.mipriid, --���ձ������
                     mi.mipriflag, --���ձ��־
                     mi.miusenum, --��������
                     mi.michargetype, --�շѷ�ʽ
                     mi.misaving, --Ԥ������
                     mi.milb, --ˮ�����
                     mi.minewflag, --�±��־
                     mi.micper, --�շ�Ա
                     mi.miiftax, --�Ƿ�˰Ʊ
                     mi.mitaxno, --˰��
                     mi.micid,
                     pval.c1,
                     null,
                     null,
                     null,
                     md.mdmid,
                     md.mdno,
                     md.mdcaliber,
                     md.mdbrand,
                     md.mdmodel,
                     md.mdstatus,
                     md.mdstatusdate,
                     ma.mamid, --ˮ�����Ϻ�
                     ma.mano, --ί����Ȩ��
                     ma.manoname, --ǩԼ����
                     ma.mabankid, --�����У����У�
                     ma.maaccountno, --�����ʺţ����У�
                     ma.maaccountname, --�����������У�
                     ma.matsbankid, --�����кţ��У�
                     ma.matsbankname, --ƾ֤���У��У�
                     ma.maifxezf, --С��֧�����У�
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     'Y',
                     sysdate,
                     p_oper,
                     mi.miifckf, --�Ƿ�ſط�
                     mi.migps, --gps��ַ
                     mi.miqfh, --Ǧ���
                     mi.mibox, --������
                     null,
                     null,
                     null,
                     ma.maregdate, --ǩԼ����
                     mi.miname, --Ʊ������
                     mi.miname2, --��������
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     \*�����*\
                     vmiseqno --����
                    ,
                     mi.mijfkrow,
                     mi.miuiid
                from custinfo ci, meterinfo mi, meterdoc md, meteraccount ma
               where mi.micid = ci.ciid
                 and mi.miid = md.mdmid
                 and mi.miid = ma.mamid(+)
                 and mi.miid = pval.c1;

      */
      --------------------------------------------------------
      --��¼ˮ����־���ύͳ��
      MSL              := NULL;
      MSL.�ͻ�����     := MI.MICODE;
      MSL.��Ȩ��       := FGETCUSTNAME(MI.MICID);
      MSL.ˮ���ַ     := MI.MIADR;
      MSL.�������     := '���ά��';
      MSL.ԭ����       := FGETMETERINFO(MI.MIID, 'BFSAFID');
      MSL.ԭӪ����˾   := MI.MISMFID;
      MSL.ԭ����ʽ   := MI.MIRTID;
      MSL.ԭˮ��ھ�   := FGETMETERCABILER(MI.MIID);
      MSL.ԭ��ҵ����   := MI.MISTID;
      MSL.ԭˮ������   := MI.MITYPE;
      MSL.ԭ���˱��־ := MI.MIIFCHK;
      MSL.ԭ�շѷ�ʽ   := MI.MICHARGETYPE;
      MSL.ԭˮ�����   := MI.MILB;
      MSL.ԭ��ˮ����   := FPRICEFRAMEJCBM(MI.MIPFID, 1);
      MSL.ԭ��ˮ����   := FPRICEFRAMEJCBM(MI.MIPFID, 2);
      MSL.ԭ��ˮС��   := MI.MIPFID;
      MSL.ԭ��λ       := MI.MISIDE;
      MSL.ԭ���       := MI.MIBFID;
      MSL.ԭ��������   := TRUNC(MI.MINEWDATE);
      --------------------------------------------------------
      --������ر�
      UPDATE METERINFO
         SET MIBFID   = P_BFID,
             MIRORDER = TO_NUMBER(PVAL.C2),
             MISEQNO  = VMISEQNO
       WHERE MIID = PVAL.C1;
      --------------------------------------------------------
      --��¼ˮ����־���ύͳ��
      MSL.������       := FGETMETERINFO(MI.MIID, 'BFSAFID');
      MSL.��Ӫ����˾   := MSL.ԭӪ����˾;
      MSL.�³���ʽ   := MSL.ԭ����ʽ;
      MSL.��ˮ��ھ�   := MSL.ԭˮ��ھ�;
      MSL.����ҵ����   := MSL.ԭ��ҵ����;
      MSL.��ˮ������   := MSL.ԭˮ������;
      MSL.�¿��˱��־ := MSL.ԭ���˱��־;
      MSL.���շѷ�ʽ   := MSL.ԭ�շѷ�ʽ;
      MSL.��ˮ�����   := MSL.ԭˮ�����;
      MSL.����ˮ����   := MSL.ԭ��ˮ����;
      MSL.����ˮ����   := MSL.ԭ��ˮ����;
      MSL.����ˮС��   := MSL.ԭ��ˮС��;
      MSL.�±�λ       := MSL.ԭ��λ;
      MSL.�±��       := P_BFID;
      MSL.����������   := MSL.ԭ��������;

      PG_EWIDE_CUSTBASE_01.METERLOG(MSL, 'N');
      --��¼ˮ����־���ύͳ��
      --------------------------------------------------------
    END LOOP;
    CLOSE C_MTAB;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END METERBOOK;

  --�������ɳ����
  PROCEDURE CREATEMR(P_MFPCODE IN VARCHAR2,
                     P_MONTH   IN VARCHAR2,
                     P_BFID    IN VARCHAR2) IS
    CI        CUSTINFO%ROWTYPE;
    MI        METERINFO%ROWTYPE;
    MD        METERDOC%ROWTYPE;
    BF        BOOKFRAME%ROWTYPE;
    MR        METERREAD%ROWTYPE;
    V_TEMPNUM NUMBER(10);
    V_ADDSL   NUMBER(10);
    V_TEMPSTR VARCHAR2(10);
    V_RET     VARCHAR2(10);
    V_DATE    DATE;
    V_MRBATCH NUMBER(20);
    --����
    CURSOR C_MR(VMIID IN VARCHAR2) IS
      SELECT 1
        FROM METERREAD
       WHERE MRMID = VMIID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --�ƻ�
    CURSOR C_BFMETER IS
      SELECT CICODE,
             MIID,
             MICID,
             MISMFID,
             MIRORDER,
             MICODE,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MIRPID,
             MIPRIID,
             MIPRIFLAG,
             MILB,
             MINEWFLAG,
             BFBATCH,
             BFRPER,
             MIRCODECHAR,
             MISAFID,
             MIIFCHK,
             MIPFID,
             MDCALIBER,
             MISIDE,
             MITYPE,
             MIYL2, --�ܱ������־(0=��ͨ��1=�ܱ����⣬2=�༶��(���ܱ�����))
             BFSDATE,
             BFEDATE
        FROM CUSTINFO, METERINFO, METERDOC, BOOKFRAME
       WHERE CIID = MICID
         AND MIID = MDMID
         AND MISMFID = BFSMFID
         AND MIBFID = BFID
         AND MISMFID = P_MFPCODE
         AND MIBFID = P_BFID
            --and (to_char(ADD_MONTHS(to_date(MIRMON,'yyyy.mm'),BFRCYC),'yyyy.mm') = p_month or MIRMON is null)
         AND BFNRMONTH = P_MONTH
         AND FCHKMETERNEEDREAD(MIID) = 'Y'
         and mistatus='1' 
      --zhw20160312���ӽ��ݵ��ں�ǿ�����ɳ���ƻ�  
         union 
         SELECT CICODE,
             MIID,
             MICID,
             MISMFID,
             MIRORDER,
             MICODE,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MIRPID,
             MIPRIID,
             MIPRIFLAG,
             MILB,
             MINEWFLAG,
             BFBATCH,
             BFRPER,
             MIRCODECHAR,
             MISAFID,
             MIIFCHK,
             MIPFID,
             MDCALIBER,
             MISIDE,
             MITYPE,
             MIYL2, --�ܱ������־(0=��ͨ��1=�ܱ����⣬2=�༶��(���ܱ�����))
             BFSDATE,
             BFEDATE
        FROM CUSTINFO, METERINFO, METERDOC, BOOKFRAME 
       WHERE CIID = MICID
         AND MIID = MDMID
         AND MISMFID = BFSMFID
         AND MIBFID = BFID
         AND MISMFID = P_MFPCODE
         AND MIBFID = P_BFID
         and  mipfid in(select pdpfid from PRICEDETAIL t where pdmethod = 'sl3')
            --and (to_char(ADD_MONTHS(to_date(MIRMON,'yyyy.mm'),BFRCYC),'yyyy.mm') = p_month or MIRMON is null)
         AND MIYL11 = ADD_MONTHS(to_date(P_MONTH,'yyyy.mm'),-12)
         AND BFNRMONTH <> P_MONTH
         AND FCHKMETERNEEDREAD(MIID) = 'Y'
         and mistatus='1'; 
         
   /*  --20160801 �����û��α�
    CURSOR C_MT(VMIID IN VARCHAR2) IS
      SELECT *
        FROM METERTGL
       WHERE MTMID = VMIID
         AND MTTGL > 0
         AND MTSTATUS = 'Y';
    MT METERTGL%ROWTYPE;*/
                     
  BEGIN

    --select to_number(to_char(sysdate,'yyyymmddhhmmss')) into v_mrbatch from dual;
    OPEN C_BFMETER;
    LOOP
      FETCH C_BFMETER
        INTO CI.CICODE,
             MI.MIID,
             MI.MICID,
             MI.MISMFID,
             MI.MIRORDER,
             MI.MICODE,
             MI.MISTID,
             MI.MIPID,
             MI.MICLASS,
             MI.MIFLAG,
             MI.MIRECDATE,
             MI.MIRCODE,
             MI.MIRPID,
             MI.MIPRIID,
             MI.MIPRIFLAG,
             MI.MILB,
             MI.MINEWFLAG,
             BF.BFBATCH,
             BF.BFRPER,
             MI.MIRCODECHAR,
             MI.MISAFID,
             MI.MIIFCHK,
             MI.MIPFID,
             MD.MDCALIBER,
             MI.MISIDE,
             MI.MITYPE,
             MI.MIYL2, --�ܱ������־(0=��ͨ��1=�ܱ����⣬2=�༶��(���ܱ�����))
             BF.BFSDATE,
             BF.BFEDATE;
      EXIT WHEN C_BFMETER%NOTFOUND OR C_BFMETER%NOTFOUND IS NULL;
      --�ж��Ƿ�����ظ�����ƻ�
      OPEN C_MR(MI.MIID);
      FETCH C_MR
        INTO DUMMY;
      FOUND := C_MR%FOUND;
      CLOSE C_MR;
      IF NOT FOUND THEN
        MR.MRID     := FGETSEQUENCE('METERREAD'); --��ˮ��
        MR.MRMONTH  := P_MONTH; --�����·�
        MR.MRSMFID  := MI.MISMFID; --��Ͻ��˾
        MR.MRBFID   := P_BFID; --���
        MR.MRBATCH  := BF.BFBATCH; --��������  v_mrbatch;  --
        MR.MRRPER   := BF.BFRPER; --����Ա
        MR.MRRORDER := MI.MIRORDER; --��������

        --ȡ�ƻ��ƻ�������
        BEGIN
          SELECT MRBSDATE
            INTO MR.MRDAY
            FROM METERREADBATCH
           WHERE MRBSMFID = MI.MISMFID
             AND MRBMONTH = P_MONTH
             AND MRBBATCH = BF.BFBATCH;
        EXCEPTION
          WHEN OTHERS THEN
            IF FSYSPARA('0039') = 'Y' THEN
              --�Ƿ񰴼ƻ������ո���ʵ�ʳ�����
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      'ȡ�ƻ������մ�������ƻ��������ζ���');
            ELSE
              MR.MRDAY := SYSDATE;
            END IF;
        END;
        
           
      /*      --20160801 �����û��³�����
        OPEN C_MT(MR.MRMID);
        FETCH C_MT
          INTO MT;
        IF C_MT%FOUND THEN
          MR.MRDZSL      := NULL; --��������
          MR.MRDZFLAG    := 'Y'; --�����־
          MR.MRDZSYSCODE := MT.MTSYSCODE; --����
          MR.MRDZCURCODE := MT.MTCURCODE; --�������
          MR.MRDZTGL     := MT.MTTGL; --�ƹ���
        ELSE
          MR.MRDZSL      := NULL; --��������
          MR.MRDZFLAG    := 'N'; --�����־
          MR.MRDZSYSCODE := NULL; --����
          MR.MRDZCURCODE := NULL; --�������
          MR.MRDZTGL     := NULL; --�ƹ���
        END IF;
        CLOSE C_MT;
        -------20160801*/

        MR.MRCID           := MI.MICID; --�û����
        MR.MRCCODE         := CI.CICODE;
        MR.MRMID           := MI.MIID; --ˮ����
        MR.MRMCODE         := MI.MICODE; --ˮ���ֹ����
        MR.MRSTID          := MI.MISTID; --��ҵ����
        MR.MRMPID          := MI.MIPID; --�ϼ�ˮ��
        MR.MRMCLASS        := MI.MICLASS; --ˮ����
        MR.MRMFLAG         := MI.MIFLAG; --ĩ����־
        MR.MRCREADATE      := CURRENTDATE; --��������
        MR.MRINPUTDATE     := NULL; --�༭����
        MR.MRREADOK        := 'N'; --������־
        MR.MRRDATE         := NULL; --��������
        MR.MRPRDATE        := MI.MIRECDATE; --�ϴγ�������(ȡ�ϴ���Ч��������)
        MR.MRSCODE         := MI.MIRCODE; --���ڳ���
        MR.MRSCODECHAR     := MI.MIRCODECHAR; --���ڳ���char
        MR.MRECODE         := NULL; --���ڳ���
        MR.MRSL            := NULL; --����ˮ��
        MR.MRFACE          := NULL; --���
        MR.MRIFSUBMIT      := 'Y'; --�Ƿ��ύ�Ʒ�
        MR.MRIFHALT        := 'N'; --ϵͳͣ��
        MR.MRDATASOURCE    := 1; --��������Դ
        MR.MRIFIGNOREMINSL := 'Y'; --ͣ����ͳ���
        MR.MRPDARDATE      := NULL; --���������ʱ��
        MR.MROUTFLAG       := 'N'; --�������������־
        MR.MROUTID         := NULL; --�������������ˮ��
        MR.MROUTDATE       := NULL; --���������������
        MR.MRINORDER       := NULL; --��������մ���
        MR.MRINDATE        := NULL; --�������������
        MR.MRRPID          := MI.MIRPID; --�Ƽ�����
        MR.MRMEMO          := NULL; --����ע
        MR.MRIFGU          := 'N'; --�����־
        MR.MRIFREC         := 'N'; --�ѼƷ�
        MR.MRRECDATE       := NULL; --�Ʒ�����
        MR.MRRECSL         := NULL; --Ӧ��ˮ��
        /*        --ȡδ������
        sp_fetchaddingsl(mr.mrid , --������ˮ
                         mi.miid,--ˮ���
                         v_tempnum,--�ɱ�ֹ��
                         v_tempnum,--�±����
                         v_addsl ,--����
                         v_date,--��������
                         v_tempstr,--�ӵ�����
                         v_ret  --����ֵ
                         ) ;
        mr.mraddsl         :=   v_addsl ;  --����   */
        MR.MRADDSL         := 0; --����
        MR.MRCARRYSL       := NULL; --��λˮ��
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
        MR.MRPRIMFLAG      := MI.MIPRIFLAG; --  ���ձ��־
        MR.MRLB            := MI.MILB; -- ˮ�����
        MR.MRNEWFLAG       := MI.MINEWFLAG; -- �±��־
        MR.MRFACE2         := NULL; --��������
        MR.MRFACE3         := NULL; --�ǳ�����
        MR.MRFACE4         := NULL; --����ʩ˵��

        MR.MRPRIVILEGEFLAG := 'N'; --��Ȩ��־(Y/N)
        MR.MRPRIVILEGEPER  := NULL; --��Ȩ������
        MR.MRPRIVILEGEMEMO := NULL; --��Ȩ������ע
        MR.MRSAFID         := MI.MISAFID; --��������
        MR.MRIFTRANS       := 'N'; --ת����־
        MR.MRREQUISITION   := 0; --֪ͨ����ӡ����
        MR.MRIFCHK         := MI.MIIFCHK; --���˱��־
        MR.MRINPUTPER      := NULL; --������Ա
        MR.MRPFID          := MI.MIPFID; --��ˮ���
        MR.MRCALIBER       := MD.MDCALIBER; --�ھ�
        MR.MRSIDE          := MI.MISIDE; --��λ
        MR.MRMTYPE         := MI.MITYPE; --����

        --�������ѣ��㷨
        --1��ǰn�ξ�����     ���������ˮ������ʷ�������12�γ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���
        --2���ϴ�ˮ����      �������ˮ��
        --3��ȥ��ͬ��ˮ����  ȥ��ͬ�����·ݵĳ���ˮ��
        --4��ȥ��ȴξ�����  ȥ��ȵĳ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���

       /* mr.mrlastsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-1),mi.mirecdate); --�ϴγ���ˮ��
        mr.mrthreesl       := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-3),mi.mirecdate); --ǰ���³���ˮ��
        mr.mryearsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-12),add_months(CurrentDate,-12)); --ȥ��ͬ�ڳ���ˮ��*/
                 --20140316 �޸�
        mr.mrlastsl   := FGETBDMONTHSL( mi.miid, mi.mirecdate,'SYSL'); --�ϴγ���ˮ��
        mr.mrthreesl   := FGETBDMONTHSL( mi.miid, mi.mirecdate,'SCJL'); --ǰ���³���ˮ��
        mr.mryearsl     := FGETBDMONTHSL( mi.miid, mi.mirecdate,'QNTQ'); --ȥ��ͬ�ڳ���ˮ��
        
        -- ����������ʷ�������ۼ�δ��������
        --sp_getnoread(mi.miid, mr.mrnullcont, mr.mrnulltotal); --��ʷ�������ۼ�δ��������
        MR.MRPLANSL   := 0; --�ƻ�ˮ��
        MR.MRPLANJE01 := 0; --�ƻ�ˮ��
        MR.MRPLANJE02 := 0; --�ƻ���ˮ�����
        MR.MRPLANJE03 := 0; --�ƻ�ˮ��Դ��
        MR.MRBFSDATE  := BF.BFSDATE;
        MR.MRBFEDATE  := BF.BFEDATE;
        MR.MRBFDAY    := 0;
        MR.MRIFMCH    := 'N';
        MR.MRIFYSCZ   := 'N';
        --�ܱ������־(0=��ͨ��1=�ܱ����⣬2=�༶��(���ܱ�����))
        MR.MRIFZBSM := MI.MIYL2;

        --�ϴ�ˮ��   ��  ȥ��ȴξ���
        GETMRHIS(MR.MRMID,
                 MR.MRMONTH,
                 MR.MRTHREESL,
                 MR.MRTHREEJE01,
                 MR.MRTHREEJE02,
                 MR.MRTHREEJE03,
                 MR.MRLASTSL,
                 MR.MRLASTJE01,
                 MR.MRLASTJE02,
                 MR.MRLASTJE03,
                 MR.MRYEARSL,
                 MR.MRYEARJE01,
                 MR.MRYEARJE02,
                 MR.MRYEARJE03,
                 MR.MRLASTYEARSL,
                 MR.MRLASTYEARJE01,
                 MR.MRLASTYEARJE02,
                 MR.MRLASTYEARJE03);

        INSERT INTO METERREAD VALUES MR;
        --������   ��meterread_ck���в�������
        IF NVL(FSYSPARA('sys5'), 'N') = 'Y' THEN
          INSERT INTO METERREAD_CK VALUES MR;
        END IF;
        UPDATE METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = MI.MIID;
      END IF;
      
       --���µ�����Ϣ
   update meterread mr 
      set (MRDZFLAG,MRDZSYSCODE,MRDZCURCODE,MRDZTGL) =
            (
               select 'Y',
                      MTSYSCODE,
                      MTCURCODE,
                      MTTGL
                 from METERTGL  
                where mtmid = mr.mrmid 
                and MTTGL > 0  AND MTSTATUS = 'Y'
            )
     where mr.mrsmfid = P_MFPCODE and mr.mrbfid= P_BFID and 
           exists (select 1 from METERTGL mt where mt.mtmid = mr.mrmid and MTTGL > 0  AND MTSTATUS = 'Y'); 
           
    END LOOP;
    CLOSE C_BFMETER;
    
    --20131208 �����Ⳮ�������Ⳮ��ƻ� by houkai
    delete METERREAD�Ⳮ�� where mrsmfid  = P_MFPCODE AND mrbfid  = P_BFID;
    CREATEMR�Ⳮ��(P_MFPCODE,P_MONTH,P_BFID);
    

/*  --------------2013.10.23�޸ģ���Ӹ���bookframe�ļƻ���ʼ���ڽ�������---------------
    UPDATE BOOKFRAME
       SET BFMONTH = BFNRMONTH,  --BFMONTH ���ڳ����·�   BFNRMONTH �´γ����·�
           BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC),  --��������
                               'yyyy.mm'),
            BFSDATE = add_months(BFSDATE,BFRCYC), --�ƻ���ʼ����
            BFEDATE =  add_months(BFEDATE,BFRCYC) --�ƻ���������       
     WHERE BFSMFID = P_MFPCODE
       AND BFID = P_BFID;*/

  --------------20140902�޸ģ���Ӹ���bookframe�ļƻ���ʼ���ڽ�������---------------
    UPDATE BOOKFRAME
       SET BFMONTH = BFNRMONTH,  --BFMONTH ���ڳ����·�   BFNRMONTH �´γ����·�
           BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC),  --��������
                               'yyyy.mm'),
            BFSDATE = first_day(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC) )  , --�ƻ���ʼ����
            BFEDATE =  last_day(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC) ) --�ƻ���������       
     WHERE BFSMFID = P_MFPCODE
       AND BFID = P_BFID 
       AND BFNRMONTH = P_MONTH;
      
      --20150407 add hb ����ֻ�������¡������Ƿ������·ݡ��Ƿ�ǰ���ص��·�
      --�ж��ֻ������·��Ƿ����ص��·��Ƿ�һ��
      update datadesign
      set �ֵ�code =P_MONTH
      where �ֵ�����='�����Ƿ�����' ;
      --��Ӱ汾��������
      update datadesign
      set �ֵ�CODE =to_char( to_number(�ֵ�CODE) + 1,'0000000000') 
      where �ֵ�����='�ֻ������汾' ; 
 
    COMMIT;
 
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
	
	
	--���ɳ���ƻ�-byj�޸İ�
  PROCEDURE CREATEMR2(P_MFPCODE IN VARCHAR2,
                      P_MONTH   IN VARCHAR2,
                      P_BFID    IN VARCHAR2                      
                      ) IS  
  cursor cur_meterread is
    select mrid,mrmid,MRMONTH from meterread mr where mr.mrsmfid = P_MFPCODE and mr.mrmonth = P_MONTH and mr.mrbfid = decode(P_BFID,null,mrbfid,P_BFID) and MRDATASOURCE = '1';   
  V_DATA_TABLE1       TAB_HISAVGDATA;
  V_DATA_TABLE2       TAB_HISAVGDATA;
  V_DATA_TABLE3       TAB_HISAVGDATA;
  V_DATA_TABLE4       TAB_HISAVGDATA;
  v_index             number;
  BEGIN    
    --ֱ�����ɳ���ƻ�
    insert/*+ parallel */ into meterread
      (mrid, mrmonth, mrsmfid, mrbfid, mrbatch, mrday, mrrorder, mrcid, mrccode, mrmid, mrmcode, mrstid, mrmpid, mrmclass, mrmflag, mrcreadate, mrinputdate, mrreadok, mrrdate, mrrper, mrprdate, mrscode, mrecode, mrsl, mrface, mrifsubmit, mrifhalt, mrdatasource, mrifignoreminsl, mrpdardate, mroutflag, mroutid, mroutdate, mrinorder, mrindate, mrrpid, mrmemo, mrifgu, mrifrec, mrrecdate, mrrecsl, mraddsl, mrcarrysl, mrctrl1, mrctrl2, mrctrl3, mrctrl4, mrctrl5, mrchkflag, mrchkdate, mrchkper, mrchkscode, mrchkecode, mrchksl, mrchkaddsl, mrchkcarrysl, mrchkrdate, mrchkface, mrchkresult, mrchkresultmemo, mrprimid, mrprimflag, mrlb, mrnewflag, mrface2, mrface3, mrface4, mrscodechar, mrecodechar, mrprivilegeflag, mrprivilegeper, mrprivilegememo, mrprivilegedate, mrsafid, mriftrans, mrrequisition, mrifchk, mrinputper, mrpfid, mrcaliber, mrside, mrlastsl, mrthreesl, mryearsl, mrrecje01, mrrecje02, mrrecje03, mrrecje04, mrmtype, mrnullcont, mrnulltotal, mrplansl, mrplanje01, mrplanje02, mrplanje03, mrlastje01, mrthreeje01, mryearje01, mrlastje02, mrthreeje02, mryearje02, mrlastje03, mrthreeje03, mryearje03, mrlastyearsl, mrlastyearje01, mrlastyearje02, mrlastyearje03, mrbfsdate, mrbfedate, mrbfday, mrifmch, mrifzbsm, mrifyscz,MRDZSL,MRDZFLAG,MRDZSYSCODE,MRDZCURCODE,MRDZTGL)
    select 
       FGETSEQUENCE('METERREAD'),  --������ˮ��
       P_MONTH,                    --�����·�
       P_MFPCODE,                  --Ӫҵ��
       bf.bfid,                    --���Id
       BF.BFBATCH,                 --��������
       sysdate,                    --�ƻ�������
       MI.MIRORDER,                --�������
       MI.MICID,                   --�û����
       mi.miid,                    --�û���
       mi.miid,                    --ˮ����
       MI.MICODE,                  --ˮ���ֹ����
       MI.MISTID,                  --��ҵ����
       MI.MIPID,                   --�ϼ�ˮ��
       MI.MICLASS,                 --ˮ����
       MI.MIFLAG,                  --ĩ����־
       sysdate,                    --��������
       null,                       --�༭����
       'N',                        --������־(Y-�� N-��)
       null,                       --�������� 
       BF.BFRPER,                  --����Ա 
       MI.MIRECDATE,               --�ϴγ������� 
       MI.MIRCODE,                 --���ڳ��� 
       null,                       --���ڳ���
       null,                       --����ˮ�� 
       null,                       --ˮ����ϣ����������󣺲���̬��(01����/02���쳣/03��ˮ��) 
       'Y',                        --�Ƿ��ύ�Ʒ�(y-�� n-��) 
       'N',                        --ϵͳͣ��(y-�� n-��) 
       '1',                        --��������Դ(1-�ֹ�,5-������,9-�ֻ�����,k-���ϻ���,l-���ڻ���,z-׷��)  
       'Y',                        --ͣ����ͳ��� 
       null,                       --���������ʱ�� 
       'N',                        --�������������־
       NULL,                       --�������������ˮ��
       NULL,                       --���������������
       NULL,                       --��������մ���
       NULL,                       --�������������
       MI.MIRPID,                  --�Ƽ�����
       NULL,                       --����ע
       'N',                        --�����־
       'N',                        --�ѼƷ�
       NULL,                       --�Ʒ�����
       NULL,                       --Ӧ��ˮ��
       0,                          --����
       NULL,                       --��λˮ�� У��ˮ�� 
       NULL,                       --���������λ1
       NULL,                       --���������λ2
       NULL,                       --���������λ3
       NULL,                       --���������λ4
       NULL,                       --���������λ5
       'N',                        --���˱�־
       NULL,                       --��������
       NULL,                       --������Ա
       NULL,                       --ԭ����
       NULL,                       --ԭֹ��
       NULL,                       --ԭˮ��
       NULL,                       --ԭ����
       NULL,                       --ԭ��λˮ��
       NULL,                       --ԭ��������
       NULL,                       --ԭ���
       NULL,                       --��������� ���������(�ֻ���������ԭ��) 
       NULL,                       --�����˵�� 
       MI.MIPRIID,                 --���ձ�����
       MI.MIPRIFLAG,               --���ձ��־
       MI.MILB,                    -- ˮ�����
       MI.MINEWFLAG,               -- �±��־
       NULL,                       --�������� �������ϡ�sysfacelist2��(01����/02����ͬ�ϴ�/03��������/04ͣҵ/05��˨/06����ˮ/07��ͣ/08�ޱ����/09����/10����/11��ʧ��/12ˮ����ת/13����������01/14�ޱ�/15����������03) 
       NULL,                       --�ǳ�����        
       NULL,                       --����ʩ˵��
       MI.MIRCODECHAR,             --���ڳ��� 
       null,                       --���ڳ��� 
       'N',                        --��Ȩ��־(Y/N)
       NULL,                       --��Ȩ������
       NULL,                       --��Ȩ������ע 
       null,                       --��Ȩ����ʱ�� 
       MI.MISAFID,                 --��������
       'N',                        --�������� ת����־ 
       0,                          --֪ͨ����ӡ����
       MI.MIIFCHK,                 --���˱��־
       NULL,                       --������Ա 
       MI.MIPFID,                  --��ˮ��� 
       (select MDCALIBER from meterdoc md where md.mdmid = mi.miid), --�ھ�(metercaliber) 
       MI.MISIDE,                  --��λ
       null /*FGETBDMONTHSL( mi.miid, mi.mirecdate,'SYSL')*/,  --�ϴγ���ˮ�� 
       null /*FGETBDMONTHSL( mi.miid, mi.mirecdate,'SCJL')*/,  --ǰ���³���ˮ��
       null /*FGETBDMONTHSL( mi.miid, mi.mirecdate,'QNTQ')*/,  --ȥ��ͬ�ڳ���ˮ��
       null,                       --Ӧ�ս�������Ŀ01    
       null,                       --Ӧ�ս�������Ŀ02    
       null,                       --Ӧ�ս�������Ŀ03    
       null,                       --Ӧ�ս�������Ŀ04
       MI.MITYPE,                  --����                   
       null,                       --��������δ���� 
       null,                       --�ۼƼ���δ���� 
       0,                          --�ƻ�ˮ��
       0,                          --�ƻ�ˮ��
       0,                          --�ƻ���ˮ�����
       0,                          --�ƻ�ˮ��Դ��
       null,                       --�ϴ�ˮ�� 
       null,                       --ǰn�ξ�ˮ�� 
       null,                       --ȥ��ͬ��ˮ��(�ֻ��������ˮ��) 
       null,                       --�ϴ���ˮ�� 
       null,                       --ǰn�ξ���ˮ�� 
       null,                       --ȥ��ͬ����ˮ��(�ֻ����������ˮ��) 
       null,                       --�ϴ�ˮ��Դ�� 
       null,                       --ǰn�ξ�ˮ��Դ�� 
       null,                       --ȥ��ͬ��ˮ��Դ��(�ֻ�������Ѹ��ӷ�) 
       null,                       --ȥ��ȴξ��� 
       null,                       --ȥ��ȴξ�ˮ�� 
       null,                       --ȥ��ȴξ���ˮ�� 
       null,                       --ȥ��ȴξ�ˮ��Դ�� 
       BF.BFSDATE,                 --�ƻ���ʼ���� 
       BF.BFEDATE,                 --�ƻ��������� 
       0,                          --ƫ������ 
       'N',                        --�Ƿ��Ⳮ��(y-�� n-��) 
       MI.MIYL2,                   --�ܱ������־(0=��ͨ��1=�ܱ����⣬2=�༶��) 
       'N',                        --�Ƿ�Ӧ�ճ���(y-�� n-��) 
       NULL,                       --��������
       'N',                        --�����־
       NULL,                       --����
       NULL,                       --�������
       NULL                        --�ƹ���
     from meterinfo mi,
          bookframe bf 
    where mi.mibfid = bf.bfid and
          mi.mismfid = bf.bfsmfid and               
          mi.mismfid = P_MFPCODE and 
          bf.bfsmfid = P_MFPCODE and 
          bf.bfid = decode( P_BFID,null,bfid,P_BFID) and          
          FCHKMETERNEEDREAD(MIID) = 'Y' and
          mistatus='1' and
          not exists(select 1 from meterread mr where mr.mrmid = mi.miid and mr.mrmonth = P_MONTH ) and
          ( (BFNRMONTH = P_MONTH)   
              or --zhw20160312���ӽ��ݵ��ں�ǿ�����ɳ���ƻ�  
            (
               mipfid in(select pdpfid from PRICEDETAIL t where pdmethod = 'sl3') and           
               MIYL11 = ADD_MONTHS(to_date(P_MONTH,'yyyy.mm'),-12) and
               BFNRMONTH <> P_MONTH
            )  
          );
    
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'�³�.���ɳ���ƻ�',sysdate,'1','Ӫҵ��' || P_MFPCODE || 'meterread��������!');          
    commit;
          
    
    --����ǰn(n=3)�ξ��� 
    select mrmid,
           round(avg(mrsl),0) mrsl,
           round(avg(je01),3) je01,
           round(avg(je02),3) je02,
           round(avg(je03),3) je03
    BULK COLLECT INTO V_DATA_TABLE1
      from (
         select mrmid, 
                nvl(mrsl,0) mrsl,
                nvl(MRRECJE01,0) je01,
                nvl(MRRECJE02,0) je02,
                nvl(MRRECJE03,0) je03,
                rank() over(partition by mrmid order by mrmonth desc) rk 
           from meterreadhis mrh
          where mrh.mrsmfid = P_MFPCODE and
                mrsl > 0 and
                mrbfid = decode(P_BFID,null,mrbfid,P_BFID)
      ) t
    where t.rk <= 3
    group by mrmid;
    
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'�³�.���ɳ���ƻ�',sysdate,'1','n��ˮ�� ����ȡ���ڴ���!');          
    commit;
    
    v_index := V_DATA_TABLE1.first;
    if v_index > 0 then
      For varR In v_index..V_DATA_TABLE1.count Loop
          update meterread mr
             set MRTHREESL = V_DATA_TABLE1(v_index).mrsl,
                 MRTHREEJE01 = V_DATA_TABLE1(v_index).je01,
                 MRTHREEJE02 = V_DATA_TABLE1(v_index).je02,   
                 MRTHREEJE03 = V_DATA_TABLE1(v_index).je03
           where mr.mrmid = V_DATA_TABLE1(v_index).mrmid;
          v_index := V_DATA_TABLE1.next(v_index);
      End Loop;
    end if;
      
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'�³�.���ɳ���ƻ�',sysdate,'1',' n��ˮ�����ݸ������!'   );          
    commit;
 
    
    --�����ϴ�ˮ��
    select mrmid,
           round(mrsl,0) mrsl,
           round(je01,3) je01,
           round(je02,3) je02,
           round(je03,3) je03
      BULK COLLECT INTO V_DATA_TABLE2     
      from (
         select mrmid, 
                nvl(mrsl,0) mrsl,
                nvl(MRRECJE01,0) je01,
                nvl(MRRECJE02,0) je02,
                nvl(MRRECJE03,0) je03,
                rank() over(partition by mrmid order by mrmonth desc) rk 
           from meterreadhis mrh
          where mrh.mrsmfid = P_MFPCODE and
                mrbfid = decode(P_BFID,null,mrbfid,P_BFID)
      ) t
    where t.rk = 1;
		
		insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'�³�.���ɳ���ƻ�',sysdate,'1','�ϴ�ˮ������ װ���ڴ�!');          
    commit;
    
    v_index := V_DATA_TABLE2.first;
    if v_index > 0 then
      For varR In v_index..V_DATA_TABLE2.count Loop
          update meterread mr
             set MRLASTSL = V_DATA_TABLE2(v_index).mrsl,
                 MRLASTJE01 = V_DATA_TABLE2(v_index).je01,
                 MRLASTJE02 = V_DATA_TABLE2(v_index).je02,   
                 MRLASTJE03 = V_DATA_TABLE2(v_index).je03
           where mr.mrmid = V_DATA_TABLE2(v_index).mrmid;
          v_index := V_DATA_TABLE2.next(v_index);
      End Loop;
    end if;  
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'�³�.���ɳ���ƻ�',sysdate,'1','�ϴ�ˮ�����ݸ������!');          
    commit;
    
    
    --ȥ��ͬ��
    select mrmid,
           sum(round(mrsl,0)) mrsl,
           sum(round(je01,3)) je01,
           sum(round(je02,3)) je02,
           sum(round(je03,3)) je03
      BULK COLLECT INTO V_DATA_TABLE3     
      from (
         select mrmid, 
                nvl(mrsl,0) mrsl,
                nvl(MRRECJE01,0) je01,
                nvl(MRRECJE02,0) je02,
                nvl(MRRECJE03,0) je03 
           from meterreadhis mrh
          where mrh.mrsmfid = P_MFPCODE and
                mrbfid = decode(P_BFID,null,mrbfid,P_BFID) and
                mrh.mrmonth = to_char(to_number(substr(P_MONTH,1,4)) - 1) || substr(p_month,5)
      ) group by mrmid;
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'�³�.���ɳ���ƻ�',sysdate,'1','ȥ��ͬ�� ����ȡ���ڴ���!');          
    commit;
    
    v_index := V_DATA_TABLE3.first;
    if v_index > 0 then
      For varR In v_index..V_DATA_TABLE3.count Loop
          update meterread mr
             set MRYEARSL = V_DATA_TABLE3(v_index).mrsl,
                 MRYEARJE01 = V_DATA_TABLE3(v_index).je01,
                 MRYEARJE02 = V_DATA_TABLE3(v_index).je02,   
                 MRYEARJE03 = V_DATA_TABLE3(v_index).je03
           where mr.mrmid = V_DATA_TABLE3(v_index).mrmid;
          v_index := V_DATA_TABLE3.next(v_index);
      End Loop;
    end if;  
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'�³�.���ɳ���ƻ�',sysdate,'1','ȥ��ͬ�����ݸ������!');          
    commit;
 

    --ȥ��ȫ�����
    select mrmid,
           round(avg(mrsl),0) mrsl,
           round(avg(je01),3) je01,
           round(avg(je02),3) je02,
           round(avg(je03),3) je03
     BULK COLLECT INTO V_DATA_TABLE4       
      from (
         select mrmid, 
                nvl(mrsl,0) mrsl,
                nvl(MRRECJE01,0) je01,
                nvl(MRRECJE02,0) je02,
                nvl(MRRECJE03,0) je03 
           from meterreadhis mrh
          where mrh.mrsmfid = P_MFPCODE and
                mrh.mrmonth like to_char(to_number(substr(p_month,1,4)) - 1) || '%' and 
                mrsl > 0 and
                mrbfid = decode(P_BFID,null,mrbfid,P_BFID)
      ) t 
   group by mrmid;
	 
	 insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
       values(SEQ_JOB_RUNNING_LOG.Nextval,'�³�.���ɳ���ƻ�',sysdate,'1',' ȥ��ȫ������ װ���ڴ�!');          
   commit;
   
   v_index := V_DATA_TABLE4.first;
   if v_index > 0 then
     For varR In v_index..V_DATA_TABLE4.count Loop
         update meterread mr
            set MRLASTYEARSL = V_DATA_TABLE4(v_index).mrsl,
                MRLASTYEARJE01 = V_DATA_TABLE4(v_index).je01,
                MRLASTYEARJE02 = V_DATA_TABLE4(v_index).je02,   
                MRLASTYEARJE03 = V_DATA_TABLE4(v_index).je03
          where mr.mrmid = V_DATA_TABLE4(v_index).mrmid;
         v_index := V_DATA_TABLE4.next(v_index);
     End Loop;
   end if;
   
                     
   insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
       values(SEQ_JOB_RUNNING_LOG.Nextval,'�³�.���ɳ���ƻ�',sysdate,'1',' ȥ��ȫ����������!');          
   commit;
   
   
   --���µ�����Ϣ
   update meterread mr 
      set (MRDZFLAG,MRDZSYSCODE,MRDZCURCODE,MRDZTGL) =
            (
               select 'Y',
                      MTSYSCODE,
                      MTCURCODE,
                      MTTGL
                 from METERTGL  
                where mtmid = mr.mrmid 
                and MTTGL > 0  AND MTSTATUS = 'Y'
            )
     where mr.mrsmfid = P_MFPCODE and
           exists (select 1 from METERTGL mt where mt.mtmid = mr.mrmid and MTTGL > 0  AND MTSTATUS = 'Y'); 
           
  
    --���� ���� �����·�
    UPDATE METERINFO mi
       SET MIPRMON = MIRMON, --���ڳ����·� 
           MIRMON = P_MONTH  --���ڳ����·�
     WHERE exists
      (select 1 from meterread mr where mi.miid = mr.mrmid and mr.mrsmfid = P_MFPCODE and mr.mrmonth = P_MONTH and mr.mrbfid = decode(P_BFID,null,mrbfid,P_BFID) and MRDATASOURCE = '1');
          
    --������   ��meterread_ck���в�������
    IF NVL(FSYSPARA('sys5'), 'N') = 'Y' THEN
      INSERT/*+ parallel */ INTO METERREAD_CK 
        select * from meterread mr where mr.mrsmfid = P_MFPCODE and mr.mrmonth = P_MONTH and mr.mrbfid = decode(P_BFID,null,mrbfid,P_BFID) and MRDATASOURCE = '1';
    END IF;  
    
    --20131208 �����Ⳮ�������Ⳮ��ƻ� by houkai
    delete METERREAD�Ⳮ�� where mrsmfid  = P_MFPCODE AND mrbfid  = decode(P_BFID,null,mrbfid,P_BFID);
    CREATEMR�Ⳮ��(P_MFPCODE,P_MONTH,P_BFID);
    
    --���� ���ܱ� ������Դ(������Զ��) 2016.11 by byj
    update meterread mr
       set mr.mrdatasource = 'I' 
     where exists(select 1 from meterinfo mi where mr.mrmid = mi.miid and mi.mirtid in ('4','7') );
    
    --���±����Ϣ
    UPDATE BOOKFRAME
       SET BFMONTH = BFNRMONTH,  --BFMONTH ���ڳ����·�   BFNRMONTH �´γ����·�
           BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC),  --��������
                               'yyyy.mm'),
            BFSDATE = first_day(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC) )  , --�ƻ���ʼ����
            BFEDATE =  last_day(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC) ) --�ƻ���������       
     WHERE BFSMFID = P_MFPCODE
       AND bfid = decode(P_BFID,null,bfid,P_BFID)
       AND BFNRMONTH = P_MONTH;
      
    --20150407 add hb ����ֻ�������¡������Ƿ������·ݡ��Ƿ�ǰ���ص��·�
    --�ж��ֻ������·��Ƿ����ص��·��Ƿ�һ��
    update datadesign
    set �ֵ�code =P_MONTH
    where �ֵ�����='�����Ƿ�����' ;
    --��Ӱ汾��������
    update datadesign
    set �ֵ�CODE =to_char( to_number(�ֵ�CODE) + 1,'0000000000') 
    where �ֵ�����='�ֻ������汾' ; 
    
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'�³�.���ɳ���ƻ�',sysdate,'1',' Ӫҵ�����!!');  
    commit;
    
        
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
	
  
  PROCEDURE CREATEMRBYMIID(P_CICODE IN VARCHAR2,
                     P_MONTH   IN VARCHAR2,
                     P_BFID    IN VARCHAR2) is
    CI        CUSTINFO%ROWTYPE;
    MI        METERINFO%ROWTYPE;
    MD        METERDOC%ROWTYPE;
    BF        BOOKFRAME%ROWTYPE;
    MR        METERREAD%ROWTYPE;
    V_TEMPNUM NUMBER(10);
    V_ADDSL   NUMBER(10);
    V_TEMPSTR VARCHAR2(10);
    V_RET     VARCHAR2(10);
    V_DATE    DATE;
    V_MRBATCH NUMBER(20);
    ll_count1 NUMBER(10);
    ll_count2 NUMBER(10);
    v_month varchar2(7);
    --���� �Ⳮ��Ҳ��METERREAD������ֻ��Ҫ��֤METERREADΨһ
    CURSOR C_MR(VMIID IN VARCHAR2) IS
      SELECT 1
        FROM METERREAD
       WHERE MRMID = VMIID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --�ƻ�
    CURSOR C_BFMETER IS
      SELECT CICODE,
             mistatus,
             MICOLUMN5,
             MIID,
             MICID,
             MISMFID,
             MIRORDER,
             MICODE,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MIRPID,
             MIPRIID,
             MIPRIFLAG,
             MILB,
             MINEWFLAG,
             BFBATCH,
             BFRPER,
             MIRCODECHAR,
             MISAFID,
             MIIFCHK,
             MIPFID,
             MDCALIBER,
             MISIDE,
             MITYPE,
             MIYL2, --�ܱ������־(0=��ͨ��1=�ܱ����⣬2=�༶��(���ܱ�����))
             BFSDATE,
             BFEDATE,
             mirtid --����ʽ
        FROM CUSTINFO, METERINFO, METERDOC, BOOKFRAME
       WHERE CIID = MICID
         AND MIID = MDMID
         AND MISMFID = BFSMFID
         AND MIBFID = BFID
         AND MIID = P_CICODE
         AND MIBFID = P_BFID
         AND BFNRMONTH = P_MONTH
         AND FCHKMETERNEEDREAD(MIID) = 'Y';
         --and mistatus='1';
               
         
  BEGIN

    OPEN C_BFMETER;
    LOOP
      FETCH C_BFMETER
        INTO CI.CICODE,
             MI.mistatus,
             MI.MICOLUMN5,
             MI.MIID,
             MI.MICID,
             MI.MISMFID,
             MI.MIRORDER,
             MI.MICODE,
             MI.MISTID,
             MI.MIPID,
             MI.MICLASS,
             MI.MIFLAG,
             MI.MIRECDATE,
             MI.MIRCODE,
             MI.MIRPID,
             MI.MIPRIID,
             MI.MIPRIFLAG,
             MI.MILB,
             MI.MINEWFLAG,
             BF.BFBATCH,
             BF.BFRPER,
             MI.MIRCODECHAR,
             MI.MISAFID,
             MI.MIIFCHK,
             MI.MIPFID,
             MD.MDCALIBER,
             MI.MISIDE,
             MI.MITYPE,
             MI.MIYL2, --�ܱ������־(0=��ͨ��1=�ܱ����⣬2=�༶��(���ܱ�����))
             BF.BFSDATE,
             BF.BFEDATE,
             MI.MIRTID;
      EXIT WHEN C_BFMETER%NOTFOUND OR C_BFMETER%NOTFOUND IS NULL;
      --�ж��Ƿ�����ظ�����ƻ�
      OPEN C_MR(MI.MIID);
      FETCH C_MR
        INTO DUMMY;
      FOUND := C_MR%FOUND;
      CLOSE C_MR;
      IF NOT FOUND THEN
        MR.MRID     := FGETSEQUENCE('METERREAD'); --��ˮ��
        MR.MRMONTH  := P_MONTH; --�����·�
        MR.MRSMFID  := MI.MISMFID; --��Ͻ��˾
        MR.MRBFID   := P_BFID; --���
        MR.MRBATCH  := BF.BFBATCH; --��������  v_mrbatch;  --
        MR.MRRPER   := BF.BFRPER; --����Ա
        MR.MRRORDER := MI.MIRORDER; --��������

        --ȡ�ƻ��ƻ�������
        BEGIN
          SELECT MRBSDATE
            INTO MR.MRDAY
            FROM METERREADBATCH
           WHERE MRBSMFID = MI.MISMFID
             AND MRBMONTH = P_MONTH
             AND MRBBATCH = BF.BFBATCH;
        EXCEPTION
          WHEN OTHERS THEN
            IF FSYSPARA('0039') = 'Y' THEN
              --�Ƿ񰴼ƻ������ո���ʵ�ʳ�����
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      'ȡ�ƻ������մ�������ƻ��������ζ���');
            ELSE
              MR.MRDAY := SYSDATE;
            END IF;
        END;

        MR.MRCID           := MI.MICID; --�û����
        MR.MRCCODE         := CI.CICODE;
        MR.MRMID           := MI.MIID; --ˮ����
        MR.MRMCODE         := MI.MICODE; --ˮ���ֹ����
        MR.MRSTID          := MI.MISTID; --��ҵ����
        MR.MRMPID          := MI.MIPID; --�ϼ�ˮ��
        MR.MRMCLASS        := MI.MICLASS; --ˮ����
        MR.MRMFLAG         := MI.MIFLAG; --ĩ����־
        MR.MRCREADATE      := CURRENTDATE; --��������
        MR.MRINPUTDATE     := NULL; --�༭����
        MR.MRREADOK        := 'N'; --������־
        MR.MRRDATE         := NULL; --��������
        MR.MRPRDATE        := MI.MIRECDATE; --�ϴγ�������(ȡ�ϴ���Ч��������)
        MR.MRSCODE         := MI.MIRCODE; --���ڳ���
        MR.MRSCODECHAR     := MI.MIRCODECHAR; --���ڳ���char
        MR.MRECODE         := NULL; --���ڳ���
        MR.MRSL            := NULL; --����ˮ��
        MR.MRFACE          := NULL; --���
        MR.MRIFSUBMIT      := 'Y'; --�Ƿ��ύ�Ʒ�
        MR.MRIFHALT        := 'N'; --ϵͳͣ��
        if MI.MIRTID in ('4','7') then  -- 4-����Զ�� 7-����
           MR.MRDATASOURCE :=  'I'; --��������Դ
        else
           MR.MRDATASOURCE :=  '1'; --��������Դ
        end if;   
        MR.MRIFIGNOREMINSL := 'Y'; --ͣ����ͳ���
        MR.MRPDARDATE      := NULL; --���������ʱ��
        MR.MROUTFLAG       := 'N'; --�������������־
        MR.MROUTID         := NULL; --�������������ˮ��
        MR.MROUTDATE       := NULL; --���������������
        MR.MRINORDER       := NULL; --��������մ���
        MR.MRINDATE        := NULL; --�������������
        MR.MRRPID          := MI.MIRPID; --�Ƽ�����
        MR.MRMEMO          := NULL; --����ע
        MR.MRIFGU          := 'N'; --�����־
        MR.MRIFREC         := 'N'; --�ѼƷ�
        MR.MRRECDATE       := NULL; --�Ʒ�����
        MR.MRRECSL         := NULL; --Ӧ��ˮ��
        /*        --ȡδ������
        sp_fetchaddingsl(mr.mrid , --������ˮ
                         mi.miid,--ˮ���
                         v_tempnum,--�ɱ�ֹ��
                         v_tempnum,--�±����
                         v_addsl ,--����
                         v_date,--��������
                         v_tempstr,--�ӵ�����
                         v_ret  --����ֵ
                         ) ;
        mr.mraddsl         :=   v_addsl ;  --����   */
        MR.MRADDSL         := 0; --����
        MR.MRCARRYSL       := NULL; --��λˮ��
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
        MR.MRPRIMFLAG      := MI.MIPRIFLAG; --  ���ձ��־
        MR.MRLB            := MI.MILB; -- ˮ�����
        MR.MRNEWFLAG       := MI.MINEWFLAG; -- �±��־
        MR.MRFACE2         := NULL; --��������
        MR.MRFACE3         := NULL; --�ǳ�����
        MR.MRFACE4         := NULL; --����ʩ˵��

        MR.MRPRIVILEGEFLAG := 'N'; --��Ȩ��־(Y/N)
        MR.MRPRIVILEGEPER  := NULL; --��Ȩ������
        MR.MRPRIVILEGEMEMO := NULL; --��Ȩ������ע
        MR.MRSAFID         := MI.MISAFID; --��������
        MR.MRIFTRANS       := 'N'; --ת����־
        MR.MRREQUISITION   := 0; --֪ͨ����ӡ����
        MR.MRIFCHK         := MI.MIIFCHK; --���˱��־
        MR.MRINPUTPER      := NULL; --������Ա
        MR.MRPFID          := MI.MIPFID; --��ˮ���
        MR.MRCALIBER       := MD.MDCALIBER; --�ھ�
        MR.MRSIDE          := MI.MISIDE; --��λ
        MR.MRMTYPE         := MI.MITYPE; --����

        --�������ѣ��㷨
        --1��ǰn�ξ�����     ���������ˮ������ʷ�������12�γ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���
        --2���ϴ�ˮ����      �������ˮ��
        --3��ȥ��ͬ��ˮ����  ȥ��ͬ�����·ݵĳ���ˮ��
        --4��ȥ��ȴξ�����  ȥ��ȵĳ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���

     /*   mr.mrlastsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-1),mi.mirecdate); --�ϴγ���ˮ��
        mr.mrthreesl       := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-3),mi.mirecdate); --ǰ���³���ˮ��
        mr.mryearsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-12),add_months(CurrentDate,-12)); --ȥ��ͬ�ڳ���ˮ��*/
         --20140316 �޸�
        mr.mrlastsl   := FGETBDMONTHSL( mi.miid, mi.mirecdate,'SYSL'); --�ϴγ���ˮ��
        mr.mrthreesl   := FGETBDMONTHSL( mi.miid, mi.mirecdate,'SCJL'); --ǰ���³���ˮ��
        mr.mryearsl     := FGETBDMONTHSL( mi.miid, mi.mirecdate,'QNTQ'); --ȥ��ͬ�ڳ���ˮ��
        
        -- ����������ʷ�������ۼ�δ��������
        --sp_getnoread(mi.miid, mr.mrnullcont, mr.mrnulltotal); --��ʷ�������ۼ�δ��������
        MR.MRPLANSL   := 0; --�ƻ�ˮ��
        MR.MRPLANJE01 := 0; --�ƻ�ˮ��
        MR.MRPLANJE02 := 0; --�ƻ���ˮ�����
        MR.MRPLANJE03 := 0; --�ƻ�ˮ��Դ��
        MR.MRBFSDATE  := BF.BFSDATE;
        MR.MRBFEDATE  := BF.BFEDATE;
        MR.MRBFDAY    := 0;
        MR.MRIFMCH    := 'N';
        MR.MRIFYSCZ   := 'N';
        --�ܱ������־(0=��ͨ��1=�ܱ����⣬2=�༶��(���ܱ�����))
        MR.MRIFZBSM := MI.MIYL2;
        
        --�Ⳮ������
        IF MI.MISTATUS IN ('29','30') THEN
          MR.MRREADOK        := 'Y'; --������־  �Ⳮ���̶�Ϊ�ѳ���
          MR.MRRDATE         := TRUNC(SYSDATE); --��������
          MR.MRECODE         := (MI.MIRCODE+MI.MICOLUMN5); --���ڳ���  �Ⳮ��ͬ���ڳ���
          MR.MRECODECHAR     := TO_CHAR(MR.MRECODE); --�Ⳮ��ͬ���ڳ��� 
          MR.MRSL            := MI.MICOLUMN5; --����ˮ��  �Ⳮ��Ϊ�̶�ˮ��
          MR.MRFACE          := '01'; --���  �Ⳮ��ҲΪ������̬
          MR.MRMEMO          := '�Ⳮ��'; --����ע  20140408 �Ⳮ��Ҳ�ڳ���¼������ʾ���ӱ�ע�����ֿ���
          MR.MRIFMCH    := 'Y';
          MR.MRIFSUBMIT      := 'N'; --add 20140827 �����Ⳮ����Ҫ�������
        END IF;

        --�ϴ�ˮ��   ��  ȥ��ȴξ���
        GETMRHIS(MR.MRMID,
                 MR.MRMONTH,
                 MR.MRTHREESL,
                 MR.MRTHREEJE01,
                 MR.MRTHREEJE02,
                 MR.MRTHREEJE03,
                 MR.MRLASTSL,
                 MR.MRLASTJE01,
                 MR.MRLASTJE02,
                 MR.MRLASTJE03,
                 MR.MRYEARSL,
                 MR.MRYEARJE01,
                 MR.MRYEARJE02,
                 MR.MRYEARJE03,
                 MR.MRLASTYEARSL,
                 MR.MRLASTYEARJE01,
                 MR.MRLASTYEARJE02,
                 MR.MRLASTYEARJE03);

        INSERT INTO METERREAD VALUES MR;
        --������   ��meterread_ck���в�������
        IF NVL(FSYSPARA('sys5'), 'N') = 'Y' THEN
          INSERT INTO METERREAD_CK VALUES MR;
        END IF;
        UPDATE METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = MI.MIID;
         
                 --���µ�����Ϣ 201608
         update meterread mr 
            set (MRDZFLAG,MRDZSYSCODE,MRDZCURCODE,MRDZTGL) =
                  (
                     select 'Y',
                            MTSYSCODE,
                            MTCURCODE,
                            MTTGL
                       from METERTGL  
                      where mtmid = mr.mrmid 
                      and MTTGL > 0  AND MTSTATUS = 'Y'
                  )
           where mr.mrmid =MI.MIID and mr.mrbfid= P_BFID and MRMONTH = P_MONTH and 
                 exists (select 1 from METERTGL mt where mt.mtmid = mr.mrmid and MTTGL > 0  AND MTSTATUS = 'Y'); 
                 --���µ�����Ϣ 201608
                 
      END IF;
    END LOOP;
    CLOSE C_BFMETER;
    
  --------------�жϱ�����Ƿ񻹴���δ���ƻ����û���û�������---------------
  --20140902 ����Ϊǰ�˽�����ҵ���������жϴ�������.����û�״̬Ϊ29������30��ʱ��
/*  SELECT COUNT(*)
    INTO LL_COUNT1
    FROM METERINFO
   WHERE MIBFID = P_BFID
     AND MISTATUS = '1';
  SELECT COUNT(*) INTO LL_COUNT2 FROM METERREAD WHERE MRBFID = P_BFID;
  IF LL_COUNT1 IS NOT NULL AND LL_COUNT2 IS NOT NULL AND
     LL_COUNT1 = LL_COUNT2 THEN
    UPDATE BOOKFRAME
       SET BFMONTH   = BFNRMONTH,
           BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'YYYY.MM'),
                                          BFRCYC),
                               'YYYY.MM'),
           BFSDATE   = ADD_MONTHS(BFSDATE, BFRCYC),
           BFEDATE   = ADD_MONTHS(BFEDATE, BFRCYC)
     WHERE BFID = P_BFID;
  END IF;
  
  COMMIT;*/

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
  
  --�Ⳮ�������Ⳮ��ƻ�
  PROCEDURE CREATEMR�Ⳮ��(P_MFPCODE IN VARCHAR2,
                        P_MONTH   IN VARCHAR2,
                        P_BFID    IN VARCHAR2) IS
    CI        CUSTINFO%ROWTYPE;
    MI        METERINFO%ROWTYPE;
    MD        METERDOC%ROWTYPE;
    BF        BOOKFRAME%ROWTYPE;
    MR        METERREAD�Ⳮ��%ROWTYPE;
    V_TEMPNUM NUMBER(10);
    V_ADDSL   NUMBER(10);
    V_TEMPSTR VARCHAR2(10);
    V_RET     VARCHAR2(10);
    V_DATE    DATE;
    V_MRBATCH NUMBER(20);
    --����  �Ⳮ��Ҳ��METERREAD������ֻ��Ҫ��֤METERREADΨһ
    CURSOR C_MR(VMIID IN VARCHAR2) IS
      SELECT 1
        FROM METERREAD
       WHERE MRMID = VMIID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --�ƻ�
    CURSOR C_BFMETER IS
      SELECT CICODE,
             MIID,
             MICID,
             MISMFID,
             MIRORDER,
             MICODE,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MIRPID,
             MIPRIID,
             MIPRIFLAG,
             MILB,
             MINEWFLAG,
             MICOLUMN5,
             BFBATCH,
             BFRPER,
             MIRCODECHAR,
             MISAFID,
             MIIFCHK,
             MIPFID,
             MDCALIBER,
             MISIDE,
             MITYPE,
             MIYL2, --�ܱ������־(0=��ͨ��1=�ܱ����⣬2=�༶��(���ܱ�����))
             BFSDATE,
             BFSDATE,
             bfid
        FROM CUSTINFO, METERINFO, METERDOC, BOOKFRAME
       WHERE CIID = MICID
         AND MIID = MDMID
         AND MISMFID = BFSMFID
         AND MIBFID = BFID
         AND MISMFID = P_MFPCODE
         AND MIBFID = decode(P_BFID,null,mibfId,p_bfid)
         AND BFNRMONTH = P_MONTH
         AND FCHKMETERNEEDREAD(MIID) = 'Y'
         and mistatus in ('29', '30');
  
  BEGIN
  
    OPEN C_BFMETER;
    LOOP
      FETCH C_BFMETER
        INTO CI.CICODE,
             MI.MIID,
             MI.MICID,
             MI.MISMFID,
             MI.MIRORDER,
             MI.MICODE,
             MI.MISTID,
             MI.MIPID,
             MI.MICLASS,
             MI.MIFLAG,
             MI.MIRECDATE,
             MI.MIRCODE,
             MI.MIRPID,
             MI.MIPRIID,
             MI.MIPRIFLAG,
             MI.MILB,
             MI.MINEWFLAG,
             MI.MICOLUMN5,
             BF.BFBATCH,
             BF.BFRPER,
             MI.MIRCODECHAR,
             MI.MISAFID,
             MI.MIIFCHK,
             MI.MIPFID,
             MD.MDCALIBER,
             MI.MISIDE,
             MI.MITYPE,
             MI.MIYL2, --�ܱ������־(0=��ͨ��1=�ܱ����⣬2=�༶��(���ܱ�����))
             BF.BFSDATE,
             BF.BFEDATE,
             bf.bfid;
      EXIT WHEN C_BFMETER%NOTFOUND OR C_BFMETER%NOTFOUND IS NULL;
      --�ж��Ƿ�����ظ�����ƻ�
      OPEN C_MR(MI.MIID);
      FETCH C_MR
        INTO DUMMY;
      FOUND := C_MR%FOUND;
      CLOSE C_MR;
      IF NOT FOUND THEN
        MR.MRID     := FGETSEQUENCE('METERREAD'); --��ˮ��
        MR.MRMONTH  := P_MONTH; --�����·�
        MR.MRSMFID  := MI.MISMFID; --��Ͻ��˾
        MR.MRBFID   := BF.BFID; --���
        MR.MRBATCH  := BF.BFBATCH; --��������  v_mrbatch;  --
        MR.MRRPER   := BF.BFRPER; --����Ա
        MR.MRRORDER := MI.MIRORDER; --��������
      
        --ȡ�ƻ��ƻ�������
        BEGIN
          SELECT MRBSDATE
            INTO MR.MRDAY
            FROM METERREADBATCH
           WHERE MRBSMFID = MI.MISMFID
             AND MRBMONTH = P_MONTH
             AND MRBBATCH = BF.BFBATCH;
        EXCEPTION
          WHEN OTHERS THEN
            IF FSYSPARA('0039') = 'Y' THEN
              --�Ƿ񰴼ƻ������ո���ʵ�ʳ�����
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      'ȡ�ƻ������մ�������ƻ��������ζ���');
            ELSE
              MR.MRDAY := SYSDATE;
            END IF;
        END;
      
        MR.MRCID           := MI.MICID; --�û����
        MR.MRCCODE         := CI.CICODE;
        MR.MRMID           := MI.MIID; --ˮ����
        MR.MRMCODE         := MI.MICODE; --ˮ���ֹ����
        MR.MRSTID          := MI.MISTID; --��ҵ����
        MR.MRMPID          := MI.MIPID; --�ϼ�ˮ��
        MR.MRMCLASS        := MI.MICLASS; --ˮ����
        MR.MRMFLAG         := MI.MIFLAG; --ĩ����־
        MR.MRCREADATE      := CURRENTDATE; --��������
        MR.MRINPUTDATE     := null; --�༭����
        MR.MRREADOK        := 'Y'; --������־  �Ⳮ���̶�Ϊ�ѳ���
        MR.MRRDATE         := trunc(sysdate); --��������
        MR.MRPRDATE        := MI.MIRECDATE; --�ϴγ�������(ȡ�ϴ���Ч��������)
        MR.MRSCODE         := MI.MIRCODE; --���ڳ���
        MR.MRSCODECHAR     := MI.MIRCODECHAR; --���ڳ���char
        MR.MRECODE         := (MI.MIRCODE+MI.MICOLUMN5); --���ڳ��� 
        MR.MRECODECHAR     := TO_CHAR(MR.MRECODE); --���ڳ���char  
        MR.MRSL            := MI.MICOLUMN5; --����ˮ��  �Ⳮ��Ϊ�̶�ˮ��
        MR.MRFACE          := '01'; --���  �Ⳮ��ҲΪ������̬
      --  MR.MRIFSUBMIT      := 'Y'; --�Ƿ��ύ�Ʒ�  --20140827��ǰ
        MR.MRIFSUBMIT      := 'N'; --�Ƿ��ύ�Ʒ�  --20140827 ��Ϊ��Ҫ���
        MR.MRIFHALT        := 'N'; --ϵͳͣ��
        MR.MRDATASOURCE    := 1; --��������Դ
        MR.MRIFIGNOREMINSL := 'Y'; --ͣ����ͳ���
        MR.MRPDARDATE      := NULL; --���������ʱ��
        MR.MROUTFLAG       := 'N'; --�������������־
        MR.MROUTID         := NULL; --�������������ˮ��
        MR.MROUTDATE       := NULL; --���������������
        MR.MRINORDER       := NULL; --��������մ���
        MR.MRINDATE        := NULL; --�������������
        MR.MRRPID          := MI.MIRPID; --�Ƽ�����
        MR.MRMEMO          := '�Ⳮ��'; --����ע  20140408 �Ⳮ��Ҳ�ڳ���¼������ʾ���ӱ�ע�����ֿ���
        MR.MRIFGU          := 'N'; --�����־
        MR.MRIFREC         := 'N'; --�ѼƷ�
        MR.MRRECDATE       := NULL; --�Ʒ�����
        MR.MRRECSL         := NULL; --Ӧ��ˮ��
        /*        --ȡδ������
        sp_fetchaddingsl(mr.mrid , --������ˮ
                         mi.miid,--ˮ���
                         v_tempnum,--�ɱ�ֹ��
                         v_tempnum,--�±����
                         v_addsl ,--����
                         v_date,--��������
                         v_tempstr,--�ӵ�����
                         v_ret  --����ֵ
                         ) ;
        mr.mraddsl         :=   v_addsl ;  --����   */
        MR.MRADDSL         := 0; --����
        MR.MRCARRYSL       := NULL; --��λˮ��
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
        MR.MRPRIMFLAG      := MI.MIPRIFLAG; --  ���ձ��־
        MR.MRLB            := MI.MILB; -- ˮ�����
        MR.MRNEWFLAG       := MI.MINEWFLAG; -- �±��־
        MR.MRFACE2         := '01'; --��������
        MR.MRFACE3         := NULL; --�ǳ�����
        MR.MRFACE4         := NULL; --����ʩ˵��
      
        MR.MRPRIVILEGEFLAG := 'N'; --��Ȩ��־(Y/N)
        MR.MRPRIVILEGEPER  := NULL; --��Ȩ������
        MR.MRPRIVILEGEMEMO := NULL; --��Ȩ������ע
        MR.MRSAFID         := MI.MISAFID; --��������
        MR.MRIFTRANS       := 'N'; --ת����־
        MR.MRREQUISITION   := 0; --֪ͨ����ӡ����
        MR.MRIFCHK         := MI.MIIFCHK; --���˱��־
        MR.MRINPUTPER      := NULL; --������Ա
        MR.MRPFID          := MI.MIPFID; --��ˮ���
        MR.MRCALIBER       := MD.MDCALIBER; --�ھ�
        MR.MRSIDE          := MI.MISIDE; --��λ
        MR.MRMTYPE         := MI.MITYPE; --����
      
        --�������ѣ��㷨
        --1��ǰn�ξ�����     ���������ˮ������ʷ�������12�γ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���
        --2���ϴ�ˮ����      �������ˮ��
        --3��ȥ��ͬ��ˮ����  ȥ��ͬ�����·ݵĳ���ˮ��
        --4��ȥ��ȴξ�����  ȥ��ȵĳ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���
      
        /*  mr.mrlastsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-1),mi.mirecdate); --�ϴγ���ˮ��
        mr.mrthreesl       := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-3),mi.mirecdate); --ǰ���³���ˮ��
        mr.mryearsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-12),add_months(CurrentDate,-12)); --ȥ��ͬ�ڳ���ˮ��*/
        --20140316 �޸�
        mr.mrlastsl  := FGETBDMONTHSL(mi.miid, mi.mirecdate, 'SYSL'); --�ϴγ���ˮ��
        mr.mrthreesl := FGETBDMONTHSL(mi.miid, mi.mirecdate, 'SCJL'); --ǰ���³���ˮ��
        mr.mryearsl  := FGETBDMONTHSL(mi.miid, mi.mirecdate, 'QNTQ'); --ȥ��ͬ�ڳ���ˮ��
      
        -- ����������ʷ�������ۼ�δ��������
        --sp_getnoread(mi.miid, mr.mrnullcont, mr.mrnulltotal); --��ʷ�������ۼ�δ��������
        MR.MRPLANSL   := 0; --�ƻ�ˮ��
        MR.MRPLANJE01 := 0; --�ƻ�ˮ��
        MR.MRPLANJE02 := 0; --�ƻ���ˮ�����
        MR.MRPLANJE03 := 0; --�ƻ�ˮ��Դ��
        MR.MRBFSDATE  := BF.BFSDATE;
        MR.MRBFEDATE  := BF.BFEDATE;
        MR.MRBFDAY    := 0;
        MR.MRIFMCH    := 'Y';
        MR.MRIFYSCZ   := 'N';
        --�ܱ������־(0=��ͨ��1=�ܱ����⣬2=�༶��(���ܱ�����))
        MR.MRIFZBSM := MI.MIYL2;
      
        --�ϴ�ˮ��   ��  ȥ��ȴξ���
        GETMRHIS(MR.MRMID,
                 MR.MRMONTH,
                 MR.MRTHREESL,
                 MR.MRTHREEJE01,
                 MR.MRTHREEJE02,
                 MR.MRTHREEJE03,
                 MR.MRLASTSL,
                 MR.MRLASTJE01,
                 MR.MRLASTJE02,
                 MR.MRLASTJE03,
                 MR.MRYEARSL,
                 MR.MRYEARJE01,
                 MR.MRYEARJE02,
                 MR.MRYEARJE03,
                 MR.MRLASTYEARSL,
                 MR.MRLASTYEARJE01,
                 MR.MRLASTYEARJE02,
                 MR.MRLASTYEARJE03);
      
        INSERT INTO METERREAD�Ⳮ�� VALUES MR;
      
        --������   ��meterread_ck���в�������
        IF NVL(FSYSPARA('sys5'), 'N') = 'Y' THEN
          INSERT INTO METERREAD_CK VALUES MR;
        END IF;
        UPDATE METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = MI.MIID;
      END IF;
    END LOOP;
    CLOSE C_BFMETER;
  
    --- 20140412 �Ⳮ����Ҫ��meterread
    INSERT INTO METERREAD
      SELECT *
        FROM METERREAD�Ⳮ��
       WHERE MRSMFID = P_MFPCODE
         AND MRBFID = DECODE(P_BFID,null,mrbfid,p_bfid)
         AND MRMONTH = P_MONTH;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
  

  --ɾ������ƻ�
  PROCEDURE DELETEPLAN(P_TYPE    IN VARCHAR2,
                       P_MFPCODE IN VARCHAR2,
                       P_MONTH   IN VARCHAR2,
                       P_BFID    IN VARCHAR2) IS

  BEGIN
    --ɾ����������ѳ���ƻ�
    IF P_TYPE = '01' THEN
      /*      update meterinfo
        set MIRMON = MIPRMON, MIPRMON = null
      where miid in (select mrmid
                       from meterread
                      where mrbfid = p_bfid
                        and mrmonth = p_month
                        and MRSMFID = p_mfpcode
                        and MRIFREC = 'N');*/
      --��ԭ����
      INSERT INTO METERADDSL
        (SELECT MASID,
                MASSCODEO,
                MASECODEN,
                MASUNINSDATE,
                MASUNINSPER,
                MASCREDATE,
                MASCID,
                MASMID,
                MASSL,
                MASCREPER,
                MASTRANS,
                MASBILLNO,
                MASSCODEN,
                MASINSDATE,
                MASINSPER
           FROM METERADDSLHIS
          WHERE EXISTS (SELECT MRID
                   FROM METERREAD
                  WHERE MRID = MASMRID
                    AND MRBFID = P_BFID
                    AND MRMONTH = P_MONTH
                    AND MRSMFID = P_MFPCODE
                    AND MRIFREC = 'N'));
      --ɾ����ʷ����
      DELETE METERADDSLHIS
       WHERE EXISTS (SELECT MRID
                FROM METERREAD
               WHERE MRID = MASMRID
                 AND MRBFID = P_BFID
                 AND MRMONTH = P_MONTH
                 AND MRSMFID = P_MFPCODE
                 AND MRIFREC = 'N');
      --ɾ������ƻ�
      DELETE METERREAD
       WHERE MRBFID = P_BFID
         AND MRMONTH = P_MONTH
         AND MRSMFID = P_MFPCODE
         AND MRIFREC = 'N';
        --ɾ���Ⳮ������ƻ�
          DELETE METERREAD�Ⳮ��
       WHERE MRBFID = P_BFID
         AND MRMONTH = P_MONTH
         AND MRSMFID = P_MFPCODE
         AND MRIFREC = 'N';
      --ɾ������������ѳ���ˮ������ƻ�
      
      --����bookframe ��Ϣ----------
      update bookframe
       set BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'), (0-BFRCYC)),'yyyy.mm'),
           BFSDATE = add_months(BFSDATE,(0-BFRCYC)),
           BFEDATE = add_months(BFEDATE,(0-BFRCYC))       
       WHERE BFSMFID = P_MFPCODE
       AND BFID = P_BFID;
 
      --����meterinfo�ֶ�
      update meterinfo MI
       set mirmon=miprmon, 
           miprmon=(select TO_CHAR(ADD_MONTHS(TO_DATE(BFMONTH, 'yyyy.mm'), (0-BFRCYC)), 'yyyy.mm') from bookframe WHERE BFID=MIBFID) 
           WHERE MIID = MI.MIID
           and MIBFID=P_BFID;
      -------------------------------
      
    ELSIF P_TYPE = '02' THEN

      /* update meterinfo
        set MIRMON = MIPRMON, MIPRMON = null
      where miid in (select mrmid
                       from meterread
                      where mrbfid = p_bfid
                        and mrmonth = p_month
                        and MRSMFID = p_mfpcode
                        and MRIFREC = 'N'
                        AND MRREADOK = 'N'
                        AND MRSL IS NULL);*/
      --��ԭ����
      INSERT INTO METERADDSL
        (SELECT MASID,
                MASSCODEO,
                MASECODEN,
                MASUNINSDATE,
                MASUNINSPER,
                MASCREDATE,
                MASCID,
                MASMID,
                MASSL,
                MASCREPER,
                MASTRANS,
                MASBILLNO,
                MASSCODEN,
                MASINSDATE,
                MASINSPER
           FROM METERADDSLHIS
          WHERE EXISTS (SELECT MRID
                   FROM METERREAD
                  WHERE MRID = MASMRID
                    AND MRBFID = P_BFID
                    AND MRMONTH = P_MONTH
                    AND MRSMFID = P_MFPCODE
                    AND MRIFREC = 'N'
                    AND MRREADOK = 'N'
                    AND MRSL IS NULL));
      --ɾ����ʷ����
      DELETE METERADDSLHIS
       WHERE EXISTS (SELECT MRID
                FROM METERREAD
               WHERE MRID = MASMRID
                 AND MRBFID = P_BFID
                 AND MRMONTH = P_MONTH
                 AND MRSMFID = P_MFPCODE
                 AND MRIFREC = 'N'
                 AND MRREADOK = 'N'
                 AND MRSL IS NULL);
      --ɾ������ƻ�
      DELETE METERREAD
       WHERE MRBFID = P_BFID
         AND MRMONTH = P_MONTH
         AND MRSMFID = P_MFPCODE
         AND MRIFREC = 'N'
         AND MRREADOK = 'N' 
         AND MRSL IS NULL;
 
         --ɾ���Ⳮ������ƻ�
          DELETE METERREAD�Ⳮ��
       WHERE MRBFID = P_BFID
         AND MRMONTH = P_MONTH
         AND MRSMFID = P_MFPCODE
         AND MRIFREC = 'N';
       --����bookframe ��Ϣ----------
      update bookframe
       set BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'), (0-BFRCYC)),'yyyy.mm'),
           BFSDATE = add_months(BFSDATE,(0-BFRCYC)),
           BFEDATE = add_months(BFEDATE,(0-BFRCYC))       
       WHERE BFSMFID = P_MFPCODE
       AND BFID = P_BFID;
 
      --����meterinfo�ֶ�
      update meterinfo MI
       set mirmon=miprmon, 
           miprmon=(select TO_CHAR(ADD_MONTHS(TO_DATE(BFMONTH, 'yyyy.mm'), (0-BFRCYC)), 'yyyy.mm') from bookframe WHERE BFID=MIBFID) 
           WHERE MIID = MI.MIID
           and MIBFID=P_BFID;
      -------------------------------
         
    END IF;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;
  
  --����ȡ������ƻ�
  PROCEDURE DELETEPLANONE(p_mrmid    IN VARCHAR2,  --ˮ����
                          P_BFID     IN VARCHAR2,  --����
                          P_MRID     IN VARCHAR2,   --������ˮ��
                          on_appcode out number,
                          oc_error   out varchar2
  )as
   CURSOR C_MR(VMRID IN VARCHAR2) IS
     SELECT 1
       FROM METERREAD
      WHERE MRID = VMRID
        AND (MRIFREC = 'Y' or MRREADOK = 'Y');
   DUMMY    INTEGER;
   FOUND    BOOLEAN;
   LL_COUNT NUMBER(10);

 BEGIN
   on_appcode := 1;
   
   OPEN C_MR(P_MRID);
   FETCH C_MR
     INTO DUMMY;
   FOUND := C_MR%FOUND;
   CLOSE C_MR;
   IF NOT  FOUND THEN
     --��ԭ����
     INSERT INTO METERADDSL
       (SELECT MASID,
               MASSCODEO,
               MASECODEN,
               MASUNINSDATE,
               MASUNINSPER,
               MASCREDATE,
               MASCID,
               MASMID,
               MASSL,
               MASCREPER,
               MASTRANS,
               MASBILLNO,
               MASSCODEN,
               MASINSDATE,
               MASINSPER
          FROM METERADDSLHIS
         WHERE EXISTS (SELECT MRID
                  FROM METERREAD
                 WHERE MRID = MASMRID
                   AND MRID = P_MRID
                   AND MRIFREC = 'N'
                   AND MRREADOK = 'N'
                   AND MRSL IS NULL));
     --ɾ����ʷ����

     DELETE METERADDSLHIS
      WHERE EXISTS (SELECT MRID
               FROM METERREAD
              WHERE MRID = MASMRID
                AND MRID = P_MRID
                /*AND MRIFREC = 'N'
                AND MRREADOK = 'N'
                AND nvl(MRSL,0) = 0*/);

     --ɾ������ƻ�
     DELETE METERREAD
      WHERE MRID = P_MRID;/*
        AND MRIFREC = 'N'
        AND MRREADOK = 'N'
        AND nvl(MRSL,0) = 0;*/

     --ɾ���Ⳮ������ƻ�
     DELETE METERREAD�Ⳮ��
      WHERE MRID = P_MRID
        AND MRIFREC = 'N';

     --------------�жϱ�����Ƿ񻹴��������ƻ��ļ�¼��û�������---------------
     SELECT COUNT(*)
       INTO LL_COUNT
       FROM METERREAD
      WHERE MRBFID = P_BFID
        AND mrmid <> p_mrmid;
     IF LL_COUNT = 0 THEN
       UPDATE BOOKFRAME
          SET BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'YYYY.MM'),
                                             (0 - BFRCYC)),
                                  'YYYY.MM'),
              BFSDATE   = ADD_MONTHS(BFSDATE, (0 - BFRCYC)),
              BFEDATE   = ADD_MONTHS(BFEDATE, (0 - BFRCYC))
        WHERE BFID = P_BFID;
     END IF;

     --����METERINFO�ֶ�
     UPDATE METERINFO MI
        SET MIRMON  = MIPRMON,
            MIPRMON =
            (SELECT TO_CHAR(ADD_MONTHS(TO_DATE(BFMONTH, 'YYYY.MM'),
                                       (0 - BFRCYC)),
                            'YYYY.MM')
               FROM BOOKFRAME
              WHERE BFID = MIBFID)
      WHERE MIID = p_mrmid;
     -------------------------------
   else
     on_appcode := -1;
     oc_error := '��ˮ���ѳ���������,���ܳ�������ƻ�,����!';
     return;
   END IF;
 EXCEPTION
   WHEN OTHERS THEN
     on_appcode := -1;
     oc_error := sqlerrm;
 END; 

  --�����½�
  PROCEDURE CARRYFORPAY_MR(P_SMFID  IN VARCHAR2,
                            P_MONTH  IN VARCHAR2,
                            P_PER    IN VARCHAR2,
                            P_COMMIT IN VARCHAR2) IS
    V_COUNT     NUMBER;
    V_RECMONTH  VARCHAR2(7);
    V_PAYMONTH  VARCHAR2(7);
    V_ZZRMONTH   VARCHAR2(7);
    V_ZZPMONTH   VARCHAR2(7);
  BEGIN
    --Ӧ��
    /*TOOLS.FGETRECMONTH(MR.MRSMFID)
    000004 ����
    000008 ����
    --ʵ��
    TOOLS.FGETPAYMONTH(P_POSITION)
    000006 ����
    000010 ����*/
    ---START����Ƿ���©�����(�ڿͻ����м��)----------------------------------------------------------
    V_RECMONTH := TOOLS.FGETRECMONTH(P_SMFID); --Ӧ���·�
    V_PAYMONTH := TOOLS.FGETPAYMONTH(P_SMFID); --ʵ���·�
    
    
    IF V_RECMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����½�Ӧ���·��쳣,����!');
    END IF;
    IF V_PAYMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����½�ʵ���·��쳣,����!');
    END IF;
    
    --��������Ϊ����
    UPDATE SYSMANAPARA
    SET SMPPVALUE= V_RECMONTH
    WHERE SMPID=P_SMFID AND
          SMPPID='000004';
    UPDATE SYSMANAPARA
    SET SMPPVALUE= V_RECMONTH
    WHERE SMPID=P_SMFID AND
          SMPPID='000006';
          
          
    V_ZZRMONTH := TO_CHAR(ADD_MONTHS(TO_DATE(V_RECMONTH || '.01',
                                            'yyyy.mm.dd'),
                                    1),
                         'yyyy.mm');
    
    V_ZZPMONTH := TO_CHAR(ADD_MONTHS(TO_DATE(V_PAYMONTH || '.01',
                                            'yyyy.mm.dd'),
                                    1),
                         'yyyy.mm');
    
    --���±���
    UPDATE SYSMANAPARA
    SET SMPPVALUE= V_ZZRMONTH
    WHERE SMPID=P_SMFID AND
          SMPPID='000008';
    UPDATE SYSMANAPARA
    SET SMPPVALUE= V_ZZPMONTH
    WHERE SMPID=P_SMFID AND
          SMPPID='000010';
    
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '����ʧ��' || SQLERRM);
  END;
  

  -- ���մ���(����Ӧ���½�)
  --p_smfid Ӫҵ��,��ˮ��˾
  --p_month ��ǰ�·�
  --p_per ����Ա
  --p_commit �ύ��־
  --o_ret ����ֵ
  --time 2009-04-04  by wy
  PROCEDURE CARRYFORWARD_MR(P_SMFID  IN VARCHAR2,
                            P_MONTH  IN VARCHAR2,
                            P_PER    IN VARCHAR2,
                            P_COMMIT IN VARCHAR2) IS
    V_COUNT     NUMBER;
    V_TEMPMONTH VARCHAR2(7);
    V_ZZMONTH   VARCHAR2(7);
    VSCRMONTH   VARCHAR2(7);
    VDESMONTH   VARCHAR2(7);
  BEGIN
    ---START����Ƿ���©�����(�ڿͻ����м��)----------------------------------------------------------
    V_TEMPMONTH := TOOLS.FGETREADMONTH(P_SMFID);
    IF V_TEMPMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����·��쳣,����!');
    END IF;
    /*    --��¼������־20100623 BY WY ��������ˮ
          insert into mrnewlog
        (mnlgid, mnlgper, mnlgdate, mnlgmonth, mnlgmsfid, mnlgflag, mnlgtype)
      values
        (seq_mrnewlog_ID.Nextval , p_per, SYSDATE, p_month, p_smfid, 'Y','R');
    */
    --�������·ݸ��� date:20110323�� autor ��yujia��
    --�������ڳ����·�
    UPDATE SYSMANAPARA
       SET SMPPVALUE = V_TEMPMONTH
     WHERE SMPID = P_SMFID
       AND SMPPID = '000005';
    --�·ݼ�һ
    V_ZZMONTH := TO_CHAR(ADD_MONTHS(TO_DATE(V_TEMPMONTH || '.01',
                                            'yyyy.mm.dd'),
                                    1),
                         'yyyy.mm');
    --���³����·�
    UPDATE SYSMANAPARA
       SET SMPPVALUE = V_ZZMONTH
     WHERE SMPID = P_SMFID
       AND SMPPID = '000009';

    --����Ӫҵ����һ�� �����·ݺ�Ӧ���·�ͬ�� BY WY 20100528
    --��Ӧ���·ݸ��� date:20110323�� autor ��yujia��
    --�����ϸ���Ӧ���·�
    /* update sysmanapara t
       set smppvalue = V_TEMPMONTH
     where smppid = '000004'
       and smpid = p_smfid;
    --Ӧ���·�
    update sysmanapara
       set smppvalue = V_ZZMONTH
     where smppid = '000008'
       and smpid = p_smfid;*/
    /*---����Ʊ�·ݵĸ��£�date:20110323�� autor ��yujia��
      --�������ڷ�Ʊ�·�
      update sysmanapara t
         set smppvalue = V_TEMPMONTH
       where smppid = '000003'
         and smpid = p_smfid;
          --���ڷ�Ʊ�·�
      update sysmanapara
         set smppvalue = V_ZZMONTH
       where smppid = '000007'
         and smpid = p_smfid;
    ---��ʵ�����·ݵĸ��£�date:20110323�� autor ��yujia��
      --��������ʵ���·�
      update sysmanapara t
         set smppvalue =V_TEMPMONTH
       where smppid = '000006'
         and smpid = p_smfid;

      --����ʵ���·�
      update sysmanapara
         set smppvalue = V_ZZMONTH
       where smppid = '000010'
         and smpid = p_smfid;*/
    --
    /*  begin
    select distinct smppvalue into vScrMonth from sysmanapara
    where smppid='000004' and smpid=p_smfid;
    select distinct smppvalue into vDesMonth from sysmanapara
    where smppid='000008' and smpid=p_smfid;
    exception when others then
    null;
    end;
    CMDPUSH('pg_report.InitMonthly',''''||vScrMonth||''','''||vDesMonth||''',''R''');*/
    --����������ת�뵽��ʷ�����
    INSERT INTO METERREADHIS
      (SELECT *
         FROM METERREAD T
        WHERE T.MRSMFID = P_SMFID
          AND T.MRMONTH = P_MONTH);

    --ɾ����ǰ�������Ϣ
    DELETE METERREAD T
     WHERE T.MRSMFID = P_SMFID
       AND T.MRMONTH = P_MONTH;

    --ɾ����ǰ�������Ϣ
    DELETE METERREAD�Ⳮ�� T
     WHERE T.MRSMFID = P_SMFID
       AND T.MRMONTH = P_MONTH;

    --��ʷ��������
    UPDATEMRSLHIS(P_SMFID, P_MONTH);

    --����ˮ���������Ž���ˮ����

    IF NVL(FSYSPARA('sys5'), 'N') = 'Y' THEN
      --�����������ݳ��絽��ʷ��������
      INSERT INTO METERREADHIS_CK
        (SELECT *
           FROM METERREAD_CK T
          WHERE T.MRSMFID = P_SMFID
            AND T.MRMONTH = P_MONTH);

      --ɾ����ǰ���������Ϣ
      DELETE METERREAD_CK T
       WHERE T.MRSMFID = P_SMFID
         AND T.MRMONTH = P_MONTH;
    END IF;

    /* --��ʷ��������
    UPDATEMRSLHIS_CK(P_SMFID, P_MONTH);*/
    --�ύ��־
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '����ʧ��' || SQLERRM);
  END;

  -- �ֹ������½ᴦ��
  --p_smfid Ӫҵ��,��ˮ��˾
  --p_month ��ǰ�·�
  --p_per ����Ա
  --p_commit �ύ��־
  --o_ret ����ֵ
  --time 2010-08-20  by yf
  PROCEDURE CARRYFPAY_MR(P_SMFID  IN VARCHAR2,
                         P_MONTH  IN VARCHAR2,
                         P_PER    IN VARCHAR2,
                         P_COMMIT IN VARCHAR2) IS
    V_COUNT     NUMBER;
    V_TEMPMONTH VARCHAR2(7);
    VSCRMONTH   VARCHAR2(7);
    VDESMONTH   VARCHAR2(7);
  BEGIN
    ---START����Ƿ���©�����(�ڿͻ����м��)----------------------------------------------------------
    V_TEMPMONTH := TOOLS.FGETPAYMONTH(P_SMFID);
    IF V_TEMPMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�ֹ������½��·��쳣,����!');
    END IF;
    --��¼�����½���־20100623 BY WY ��������ˮ
    -- insert into mrnewlog
    --(mnlgid, mnlgper, mnlgdate, mnlgmonth, mnlgmsfid, mnlgflag, mnlgtype)
    --values
    --(seq_mrnewlog_ID.Nextval , p_per, SYSDATE, p_month, p_smfid, 'Y', 'P');
    --�������ڷ�Ʊ�·�
    UPDATE SYSMANAPARA T
       SET SMPPVALUE =
           (SELECT SMPPVALUE
              FROM SYSMANAPARA TT
             WHERE SMPPID = '000007'
               AND T.SMPID = TT.SMPID)
     WHERE SMPPID = '000003'
       AND SMPID = P_SMFID;
    --��������ʵ���·�
    UPDATE SYSMANAPARA T
       SET SMPPVALUE =
           (SELECT SMPPVALUE
              FROM SYSMANAPARA TT
             WHERE SMPPID = '000010'
               AND T.SMPID = TT.SMPID)
     WHERE SMPPID = '000006'
       AND SMPID = P_SMFID;
    --���ڷ�Ʊ�·�
    UPDATE SYSMANAPARA
       SET SMPPVALUE = TO_CHAR(ADD_MONTHS(TO_DATE(SMPPVALUE, 'yyyy.mm'), 1),
                               'yyyy.mm')
     WHERE SMPPID = '000007'
       AND SMPID = P_SMFID;
    --����ʵ���·�
    UPDATE SYSMANAPARA
       SET SMPPVALUE = TO_CHAR(ADD_MONTHS(TO_DATE(SMPPVALUE, 'yyyy.mm'), 1),
                               'yyyy.mm')
     WHERE SMPPID = '000010'
       AND SMPID = P_SMFID;
    --
    BEGIN
      SELECT DISTINCT SMPPVALUE
        INTO VSCRMONTH
        FROM SYSMANAPARA
       WHERE SMPPID = '000006'
         AND SMPID = P_SMFID;
      SELECT DISTINCT SMPPVALUE
        INTO VDESMONTH
        FROM SYSMANAPARA
       WHERE SMPPID = '000010'
         AND SMPID = P_SMFID;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    CMDPUSH('pg_report.InitMonthly',
            '''' || VSCRMONTH || ''',''' || VDESMONTH || ''',''P''');

    --�ύ��־
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '�����½�ʧ��' || SQLERRM);
  END;

  --���µ�������ƻ�
  PROCEDURE SP_UPDATEMRONE(P_TYPE   IN VARCHAR2, --�������� :01 ��������
                           P_MRID   IN VARCHAR2, --������ˮ��
                           P_COMMIT IN VARCHAR2 --�Ƿ��ύ
                           ) AS
    MR       METERREAD%ROWTYPE;
    V_TEMPSL NUMBER(10);

    V_TEMPNUM NUMBER(10);
    V_ADDSL   NUMBER(10);
    V_TEMPSTR VARCHAR2(10);
    V_RET     VARCHAR2(10);
    V_DATE    DATE;
  BEGIN
    BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '����ƻ�������');
    END;
    IF MR.MRIFREC = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '����ƻ��Ѿ����,���ܸ���');
    END IF;
    IF MR.MROUTFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '����ƻ��ѷ���,���ܸ���');
    END IF;
    --01 ��������
    IF P_TYPE = '01' THEN

      --ȡδ������
      SP_FETCHADDINGSL(MR.MRID, --������ˮ
                       MR.MRID, --ˮ���
                       V_TEMPNUM, --�ɱ�ֹ��
                       V_TEMPNUM, --�±����
                       V_ADDSL, --����
                       V_DATE, --��������
                       V_TEMPSTR, --�ӵ�����
                       V_RET --����ֵ
                       );

      MR.MRADDSL := NVL(MR.MRADDSL, 0) + V_ADDSL;
      SP_GETADDEDSL(MR.MRID, --������ˮ
                    V_TEMPNUM, --�ɱ�ֹ��
                    V_TEMPNUM, --�±����
                    V_TEMPSL, --����
                    V_DATE, --��������
                    V_TEMPSTR, --�ӵ�����
                    V_RET --����ֵ
                    );
      IF MR.MRADDSL <> V_TEMPSL THEN
        MR.MRADDSL := V_TEMPSL;
      END IF;
      UPDATE METERREAD T SET MRADDSL = MR.MRADDSL WHERE MRID = P_MRID;
    END IF;

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  --��δ������
  PROCEDURE SP_GETADDINGSL(P_MIID      IN VARCHAR2, --ˮ���
                           O_MASECODEN OUT NUMBER, --�ɱ�ֹ��
                           O_MASSCODEN OUT NUMBER, --�±����
                           O_MASSL     OUT NUMBER, --����
                           O_ADDDATE   OUT DATE, --��������
                           O_MASTRANS  OUT VARCHAR2, --�ӵ�����
                           O_STR       OUT VARCHAR2 --����ֵ
                           ) AS
    CURSOR C_MADDSL IS
      SELECT * FROM METERADDSL T WHERE MASMID = P_MIID ORDER BY MASCREDATE;
    MADD       METERADDSL%ROWTYPE;
    V_OLDECODE NUMBER := 0;
    V_NEWSCODE NUMBER := 0;
    V_SL       NUMBER := 0;
    V_TRANS    VARCHAR2(1);
    V_ADDDATE  DATE;
  BEGIN
    OPEN C_MADDSL;
    LOOP

      FETCH C_MADDSL
        INTO MADD;
      EXIT WHEN C_MADDSL%NOTFOUND OR C_MADDSL%NOTFOUND IS NULL;
      --���
      IF MADD.MASTRANS IN ('F', 'G', 'H', 'K', 'L') THEN
        V_OLDECODE := MADD.MASECODEN; --�ɱ�ֹ��
        V_SL       := V_SL + MADD.MASSL; --����
        V_TRANS    := MADD.MASTRANS; --����
        V_ADDDATE  := MADD.MASCREDATE; --��������
      END IF;

      --װ��
      IF MADD.MASTRANS IN ('I', 'J', 'K', 'L') THEN
        V_NEWSCODE := MADD.MASSCODEN; --�±�����
        V_TRANS    := MADD.MASTRANS; --����
        V_ADDDATE  := MADD.MASCREDATE; --��������
      END IF;

    END LOOP;

    CLOSE C_MADDSL;

    O_MASTRANS := V_TRANS;
    IF O_MASTRANS IS NOT NULL THEN
      O_MASECODEN := V_OLDECODE;
      O_MASSCODEN := V_NEWSCODE;
      O_MASSL     := V_SL;
      O_ADDDATE   := V_ADDDATE;
    ELSE
      O_MASTRANS  := NULL;
      O_MASECODEN := NULL;
      O_MASSCODEN := NULL;
      O_MASSL     := NULL;
      O_ADDDATE   := NULL;
    END IF;
    O_STR := '000';
  EXCEPTION
    WHEN OTHERS THEN
      O_MASTRANS  := NULL;
      O_MASECODEN := NULL;
      O_MASSCODEN := NULL;
      O_MASSL     := NULL;
      O_ADDDATE   := NULL;
      O_STR       := '999';
  END;

  --����������
  PROCEDURE SP_GETADDEDSL(P_MRID      IN VARCHAR2, --������ˮ
                          O_MASECODEN OUT NUMBER, --�ɱ�ֹ��
                          O_MASSCODEN OUT NUMBER, --�±����
                          O_MASSL     OUT NUMBER, --����
                          O_ADDDATE   OUT DATE, --��������
                          O_MASTRANS  OUT VARCHAR2, --�ӵ�����
                          O_STR       OUT VARCHAR2 --����ֵ
                          ) AS
    CURSOR C_MADDSLHIS IS
      SELECT *
        FROM METERADDSLHIS T
       WHERE MASMRID = P_MRID
       ORDER BY MASCREDATE;
    MADDHIS    METERADDSLHIS%ROWTYPE;
    V_OLDECODE NUMBER := 0;
    V_NEWSCODE NUMBER := 0;
    V_SL       NUMBER := 0;
    V_TRANS    VARCHAR2(1);
    V_ADDDATE  DATE;
  BEGIN
    OPEN C_MADDSLHIS;
    LOOP

      FETCH C_MADDSLHIS
        INTO MADDHIS;
      EXIT WHEN C_MADDSLHIS%NOTFOUND OR C_MADDSLHIS%NOTFOUND IS NULL;
      --���
      IF MADDHIS.MASTRANS IN ('F', 'G', 'H', 'K', 'L') THEN
        V_OLDECODE := MADDHIS.MASECODEN; --�ɱ�ֹ��
        V_SL       := V_SL + MADDHIS.MASSL; --����
        V_TRANS    := MADDHIS.MASTRANS; --����
        V_ADDDATE  := MADDHIS.MASCREDATE; --��������
      END IF;

      --װ��
      IF MADDHIS.MASTRANS IN ('I', 'J', 'K', 'L') THEN
        V_NEWSCODE := MADDHIS.MASSCODEN; --�±�����
        V_TRANS    := MADDHIS.MASTRANS; --����
        V_ADDDATE  := MADDHIS.MASCREDATE; --��������
      END IF;

    END LOOP;

    CLOSE C_MADDSLHIS;

    O_MASTRANS := V_TRANS;
    IF O_MASTRANS IS NOT NULL THEN
      O_MASECODEN := V_OLDECODE;
      O_MASSCODEN := V_NEWSCODE;
      O_MASSL     := V_SL;
      O_ADDDATE   := V_ADDDATE;
    ELSE
      O_MASTRANS  := NULL;
      O_MASECODEN := NULL;
      O_MASSCODEN := NULL;
      O_MASSL     := NULL;
      O_ADDDATE   := NULL;
    END IF;
    O_STR := '000';
  EXCEPTION
    WHEN OTHERS THEN
      O_MASTRANS  := NULL;
      O_MASECODEN := NULL;
      O_MASSCODEN := NULL;
      O_MASSL     := NULL;
      O_ADDDATE   := NULL;
      O_STR       := '999';
  END;

  --ȡ����
  PROCEDURE SP_FETCHADDINGSL(P_MRID      IN VARCHAR2, --������ˮ
                             P_MIID      IN VARCHAR2, --ˮ���
                             O_MASECODEN OUT NUMBER, --�ɱ�ֹ��
                             O_MASSCODEN OUT NUMBER, --�±����
                             O_MASSL     OUT NUMBER, --����
                             O_ADDDATE   OUT DATE, --��������
                             O_MASTRANS  OUT VARCHAR2, --�ӵ�����
                             O_STR       OUT VARCHAR2 --����ֵ
                             ) AS
    CURSOR C_MADDSL IS
      SELECT * FROM METERADDSL T WHERE MASMID = P_MIID ORDER BY MASCREDATE;

    MADD       METERADDSL%ROWTYPE;
    V_OLDECODE NUMBER := 0;
    V_NEWSCODE NUMBER := 0;
    V_SL       NUMBER := 0;
    V_TRANS    VARCHAR2(1);
    V_ADDDATE  DATE;
  BEGIN
    OPEN C_MADDSL;
    FETCH C_MADDSL
      INTO MADD;
    IF C_MADDSL%NOTFOUND OR C_MADDSL%NOTFOUND IS NULL THEN
      O_MASTRANS  := NULL;
      O_MASECODEN := NULL;
      O_MASSCODEN := NULL;
      O_MASSL     := NULL;
      O_ADDDATE   := NULL;
      O_STR       := '100';
      CLOSE C_MADDSL;
      RETURN;
    END IF;
    WHILE C_MADDSL%FOUND LOOP
      --���
      IF MADD.MASTRANS IN ('F', 'G', 'H', 'K', 'L') THEN
        V_OLDECODE := MADD.MASECODEN; --�ɱ�ֹ��
        V_SL       := V_SL + MADD.MASSL; --����
        V_TRANS    := MADD.MASTRANS; --����
        V_ADDDATE  := MADD.MASCREDATE; --��������
      END IF;
      --װ��
      IF MADD.MASTRANS IN ('I', 'J', 'K', 'L') THEN
        V_NEWSCODE := MADD.MASSCODEN; --�±�����
        V_TRANS    := MADD.MASTRANS; --����
        V_ADDDATE  := MADD.MASCREDATE; --��������
      END IF;
      --
      --�����õ�������Ϣת����ʷ
      INSERT INTO METERADDSLHIS
        SELECT MASID,
               MASSCODEO,
               MASECODEN,
               MASUNINSDATE,
               MASUNINSPER,
               MASCREDATE,
               MASCID,
               MASMID,
               MASSL,
               MASCREPER,
               MASTRANS,
               MASBILLNO,
               MASSCODEN,
               MASINSDATE,
               MASINSPER,
               P_MRID
          FROM METERADDSL T
         WHERE MASID = MADD.MASID;
      --ɾ����ǰ������Ϣ
      DELETE METERADDSL WHERE MASID = MADD.MASID;
      --
      FETCH C_MADDSL
        INTO MADD;
    END LOOP;
    CLOSE C_MADDSL;

    O_MASTRANS  := V_TRANS;
    O_MASECODEN := V_OLDECODE;
    O_MASSCODEN := V_NEWSCODE;
    O_MASSL     := V_SL;
    O_ADDDATE   := V_ADDDATE;
    O_STR       := '000';
  EXCEPTION
    WHEN OTHERS THEN
      O_MASTRANS  := NULL;
      O_MASECODEN := NULL;
      O_MASSCODEN := NULL;
      O_MASSL     := NULL;
      O_ADDDATE   := NULL;
      O_STR       := '999';
  END;

  --������
  PROCEDURE SP_ROLLBACKADDEDSL(P_MRID IN VARCHAR2, --������ˮ
                               O_STR  OUT VARCHAR2 --����ֵ
                               ) AS
  BEGIN
    IF P_MRID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '������ˮΪ��,����!');
    END IF;
    --����ʷ������Ϣ���뵽��ǰ������
    INSERT INTO METERADDSL
      (SELECT MASID,
              MASSCODEO,
              MASECODEN,
              MASUNINSDATE,
              MASUNINSPER,
              MASCREDATE,
              MASCID,
              MASMID,
              MASSL,
              MASCREPER,
              MASTRANS,
              MASBILLNO,
              MASSCODEN,
              MASINSDATE,
              MASINSPER
         FROM METERADDSLHIS
        WHERE MASMRID = P_MRID);
    --ɾ����ʷ������Ϣ
    DELETE METERADDSLHIS WHERE MASMRID = P_MRID;
    O_STR := '000';
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_STR := '999';
  END;

  --�����Ⱦ�������12����ʷˮ��������������ˮ��
  PROCEDURE UPDATEMRSLHIS(P_SMFID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
    CURSOR C_MRHIS IS
      SELECT MRMID, MRRDATE, MRSL, MRECODE
        FROM METERREADHIS
       WHERE MRSMFID = P_SMFID
         AND MRMONTH = P_MONTH;

    CURSOR C_MRSLHIS(VMID VARCHAR2) IS
      SELECT * FROM METERREADSLHIS WHERE MRMID = VMID FOR UPDATE NOWAIT;

    MRHIS   METERREADHIS%ROWTYPE;
    MRSLHIS METERREADSLHIS%ROWTYPE;
    N       INTEGER;
    I       INTEGER;
  BEGIN
    OPEN C_MRHIS;
    LOOP
      FETCH C_MRHIS
        INTO MRHIS.MRMID, MRHIS.MRRDATE, MRHIS.MRSL, MRHIS.MRECODE;
      EXIT WHEN C_MRHIS%NOTFOUND OR C_MRHIS%NOTFOUND IS NULL;
      -------------------------------------------------------
      OPEN C_MRSLHIS(MRHIS.MRMID);
      FETCH C_MRSLHIS
        INTO MRSLHIS;
      IF C_MRSLHIS%NOTFOUND OR C_MRSLHIS%NOTFOUND IS NULL THEN
        -------------------------------------------------------
        INSERT INTO METERREADSLHIS
          (MRMID, MRMONTH, MRRDATE1, MRECODE1, MRSL1)
        VALUES
          (MRHIS.MRMID, P_MONTH, MRHIS.MRRDATE, MRHIS.MRECODE, MRHIS.MRSL);
        -------------------------------------------------------
      END IF;
      WHILE C_MRSLHIS%FOUND LOOP
        -------------------------------------------------------
        N := MONTHS_BETWEEN(FIRST_DAY(MRHIS.MRRDATE), MRSLHIS.MRRDATE1);
        IF N > 0 THEN
          FOR I IN 1 .. N LOOP
            MRSLHIS.MRRDATE12 := MRSLHIS.MRRDATE11;
            MRSLHIS.MRRDATE11 := MRSLHIS.MRRDATE10;
            MRSLHIS.MRRDATE10 := MRSLHIS.MRRDATE9;
            MRSLHIS.MRRDATE9  := MRSLHIS.MRRDATE8;
            MRSLHIS.MRRDATE8  := MRSLHIS.MRRDATE7;
            MRSLHIS.MRRDATE7  := MRSLHIS.MRRDATE6;
            MRSLHIS.MRRDATE6  := MRSLHIS.MRRDATE5;
            MRSLHIS.MRRDATE5  := MRSLHIS.MRRDATE4;
            MRSLHIS.MRRDATE4  := MRSLHIS.MRRDATE3;
            MRSLHIS.MRRDATE3  := MRSLHIS.MRRDATE2;
            MRSLHIS.MRRDATE2  := MRSLHIS.MRRDATE1;
            MRSLHIS.MRRDATE1  := LAST_DAY(MRSLHIS.MRRDATE1) + 1;

            MRSLHIS.MRSL1 := ROUND(MRHIS.MRSL / N, 2);
            IF I = N THEN
              MRSLHIS.MRECODE1 := MRHIS.MRECODE;
            END IF;

            UPDATE METERREADSLHIS
               SET MRSL12    = MRSL11,
                   MRECODE12 = MRECODE11,
                   MRRDATE12 = MRSLHIS.MRRDATE12,
                   MRSL11    = MRSL10,
                   MRECODE11 = MRECODE10,
                   MRRDATE11 = MRSLHIS.MRRDATE11,
                   MRSL10    = MRSL9,
                   MRECODE10 = MRECODE9,
                   MRRDATE10 = MRSLHIS.MRRDATE10,
                   MRSL9     = MRSL8,
                   MRECODE9  = MRECODE8,
                   MRRDATE9  = MRSLHIS.MRRDATE9,
                   MRSL8     = MRSL7,
                   MRECODE8  = MRECODE7,
                   MRRDATE8  = MRSLHIS.MRRDATE8,
                   MRSL7     = MRSL6,
                   MRECODE7  = MRECODE6,
                   MRRDATE7  = MRSLHIS.MRRDATE7,
                   MRSL6     = MRSL5,
                   MRECODE6  = MRECODE5,
                   MRRDATE6  = MRSLHIS.MRRDATE6,
                   MRSL5     = MRSL4,
                   MRECODE5  = MRECODE4,
                   MRRDATE5  = MRSLHIS.MRRDATE5,
                   MRSL4     = MRSL3,
                   MRECODE4  = MRECODE3,
                   MRRDATE4  = MRSLHIS.MRRDATE4,
                   MRSL3     = MRSL2,
                   MRECODE3  = MRECODE2,
                   MRRDATE3  = MRSLHIS.MRRDATE3,
                   MRSL2     = MRSL1,
                   MRECODE2  = MRECODE1,
                   MRRDATE2  = MRSLHIS.MRRDATE2,
                   MRSL1     = MRSLHIS.MRSL1,
                   MRECODE1  = MRSLHIS.MRECODE1,
                   MRRDATE1  = MRSLHIS.MRRDATE1
             WHERE CURRENT OF C_MRSLHIS;
          END LOOP;
        ELSIF N <= 0 THEN
          CASE FIRST_DAY(MRHIS.MRRDATE)
            WHEN MRSLHIS.MRRDATE1 THEN
              UPDATE METERREADSLHIS
                 SET MRSL1    = MRSL1 + NVL(MRHIS.MRSL, 0),
                     MRECODE1 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE2 THEN
              UPDATE METERREADSLHIS
                 SET MRSL2    = MRSL2 + NVL(MRHIS.MRSL, 0),
                     MRECODE2 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE3 THEN
              UPDATE METERREADSLHIS
                 SET MRSL3    = MRSL3 + NVL(MRHIS.MRSL, 0),
                     MRECODE3 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE4 THEN
              UPDATE METERREADSLHIS
                 SET MRSL4    = MRSL4 + NVL(MRHIS.MRSL, 0),
                     MRECODE4 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE5 THEN
              UPDATE METERREADSLHIS
                 SET MRSL5    = MRSL5 + NVL(MRHIS.MRSL, 0),
                     MRECODE5 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE6 THEN
              UPDATE METERREADSLHIS
                 SET MRSL6    = MRSL6 + NVL(MRHIS.MRSL, 0),
                     MRECODE6 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE7 THEN
              UPDATE METERREADSLHIS
                 SET MRSL7    = MRSL7 + NVL(MRHIS.MRSL, 0),
                     MRECODE7 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE8 THEN
              UPDATE METERREADSLHIS
                 SET MRSL8    = MRSL8 + NVL(MRHIS.MRSL, 0),
                     MRECODE8 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE9 THEN
              UPDATE METERREADSLHIS
                 SET MRSL9    = MRSL9 + NVL(MRHIS.MRSL, 0),
                     MRECODE9 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE10 THEN
              UPDATE METERREADSLHIS
                 SET MRSL10    = MRSL10 + NVL(MRHIS.MRSL, 0),
                     MRECODE10 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE11 THEN
              UPDATE METERREADSLHIS
                 SET MRSL11    = MRSL11 + NVL(MRHIS.MRSL, 0),
                     MRECODE11 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE12 THEN
              UPDATE METERREADSLHIS
                 SET MRSL12    = MRSL12 + NVL(MRHIS.MRSL, 0),
                     MRECODE12 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            ELSE
              NULL;
          END CASE;
        END IF;
        -------------------------------------------------------
        FETCH C_MRSLHIS
          INTO MRSLHIS;
      END LOOP;
      CLOSE C_MRSLHIS;
      -------------------------------------------------------
    END LOOP;
    CLOSE C_MRHIS;
  END UPDATEMRSLHIS;

  --�����Ⱦ�������12����ʷˮ��������������ˮ��
  PROCEDURE UPDATEMRSLHIS_CK(P_SMFID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
    CURSOR C_MRHIS IS
      SELECT MRMID, MRRDATE, MRSL, MRECODE
        FROM METERREADHIS_CK
       WHERE MRSMFID = P_SMFID
         AND MRMONTH = P_MONTH;

    CURSOR C_MRSLHIS(VMID VARCHAR2) IS
      SELECT * FROM METERREADSLHIS_CK WHERE MRMID = VMID FOR UPDATE NOWAIT;

    MRHIS   METERREADHIS_CK%ROWTYPE;
    MRSLHIS METERREADSLHIS_CK%ROWTYPE;
    N       INTEGER;
    I       INTEGER;
  BEGIN
    OPEN C_MRHIS;
    LOOP
      FETCH C_MRHIS
        INTO MRHIS.MRMID, MRHIS.MRRDATE, MRHIS.MRSL, MRHIS.MRECODE;
      EXIT WHEN C_MRHIS%NOTFOUND OR C_MRHIS%NOTFOUND IS NULL;
      -------------------------------------------------------
      OPEN C_MRSLHIS(MRHIS.MRMID);
      FETCH C_MRSLHIS
        INTO MRSLHIS;
      IF C_MRSLHIS%NOTFOUND OR C_MRSLHIS%NOTFOUND IS NULL THEN
        -------------------------------------------------------
        INSERT INTO METERREADSLHIS_CK
          (MRMID, MRMONTH, MRRDATE1, MRECODE1, MRSL1)
        VALUES
          (MRHIS.MRMID, P_MONTH, MRHIS.MRRDATE, MRHIS.MRECODE, MRHIS.MRSL);
        -------------------------------------------------------
      END IF;
      WHILE C_MRSLHIS%FOUND LOOP
        -------------------------------------------------------
        N := MONTHS_BETWEEN(FIRST_DAY(MRHIS.MRRDATE), MRSLHIS.MRRDATE1);
        IF N > 0 THEN
          FOR I IN 1 .. N LOOP
            MRSLHIS.MRRDATE12 := MRSLHIS.MRRDATE11;
            MRSLHIS.MRRDATE11 := MRSLHIS.MRRDATE10;
            MRSLHIS.MRRDATE10 := MRSLHIS.MRRDATE9;
            MRSLHIS.MRRDATE9  := MRSLHIS.MRRDATE8;
            MRSLHIS.MRRDATE8  := MRSLHIS.MRRDATE7;
            MRSLHIS.MRRDATE7  := MRSLHIS.MRRDATE6;
            MRSLHIS.MRRDATE6  := MRSLHIS.MRRDATE5;
            MRSLHIS.MRRDATE5  := MRSLHIS.MRRDATE4;
            MRSLHIS.MRRDATE4  := MRSLHIS.MRRDATE3;
            MRSLHIS.MRRDATE3  := MRSLHIS.MRRDATE2;
            MRSLHIS.MRRDATE2  := MRSLHIS.MRRDATE1;
            MRSLHIS.MRRDATE1  := LAST_DAY(MRSLHIS.MRRDATE1) + 1;

            MRSLHIS.MRSL1 := ROUND(MRHIS.MRSL / N, 2);
            IF I = N THEN
              MRSLHIS.MRECODE1 := MRHIS.MRECODE;
            END IF;

            UPDATE METERREADSLHIS_CK
               SET MRSL12    = MRSL11,
                   MRECODE12 = MRECODE11,
                   MRRDATE12 = MRSLHIS.MRRDATE12,
                   MRSL11    = MRSL10,
                   MRECODE11 = MRECODE10,
                   MRRDATE11 = MRSLHIS.MRRDATE11,
                   MRSL10    = MRSL9,
                   MRECODE10 = MRECODE9,
                   MRRDATE10 = MRSLHIS.MRRDATE10,
                   MRSL9     = MRSL8,
                   MRECODE9  = MRECODE8,
                   MRRDATE9  = MRSLHIS.MRRDATE9,
                   MRSL8     = MRSL7,
                   MRECODE8  = MRECODE7,
                   MRRDATE8  = MRSLHIS.MRRDATE8,
                   MRSL7     = MRSL6,
                   MRECODE7  = MRECODE6,
                   MRRDATE7  = MRSLHIS.MRRDATE7,
                   MRSL6     = MRSL5,
                   MRECODE6  = MRECODE5,
                   MRRDATE6  = MRSLHIS.MRRDATE6,
                   MRSL5     = MRSL4,
                   MRECODE5  = MRECODE4,
                   MRRDATE5  = MRSLHIS.MRRDATE5,
                   MRSL4     = MRSL3,
                   MRECODE4  = MRECODE3,
                   MRRDATE4  = MRSLHIS.MRRDATE4,
                   MRSL3     = MRSL2,
                   MRECODE3  = MRECODE2,
                   MRRDATE3  = MRSLHIS.MRRDATE3,
                   MRSL2     = MRSL1,
                   MRECODE2  = MRECODE1,
                   MRRDATE2  = MRSLHIS.MRRDATE2,
                   MRSL1     = MRSLHIS.MRSL1,
                   MRECODE1  = MRSLHIS.MRECODE1,
                   MRRDATE1  = MRSLHIS.MRRDATE1
             WHERE CURRENT OF C_MRSLHIS;
          END LOOP;
        ELSIF N <= 0 THEN
          CASE FIRST_DAY(MRHIS.MRRDATE)
            WHEN MRSLHIS.MRRDATE1 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL1    = MRSL1 + NVL(MRHIS.MRSL, 0),
                     MRECODE1 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE2 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL2    = MRSL2 + NVL(MRHIS.MRSL, 0),
                     MRECODE2 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE3 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL3    = MRSL3 + NVL(MRHIS.MRSL, 0),
                     MRECODE3 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE4 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL4    = MRSL4 + NVL(MRHIS.MRSL, 0),
                     MRECODE4 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE5 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL5    = MRSL5 + NVL(MRHIS.MRSL, 0),
                     MRECODE5 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE6 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL6    = MRSL6 + NVL(MRHIS.MRSL, 0),
                     MRECODE6 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE7 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL7    = MRSL7 + NVL(MRHIS.MRSL, 0),
                     MRECODE7 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE8 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL8    = MRSL8 + NVL(MRHIS.MRSL, 0),
                     MRECODE8 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE9 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL9    = MRSL9 + NVL(MRHIS.MRSL, 0),
                     MRECODE9 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE10 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL10    = MRSL10 + NVL(MRHIS.MRSL, 0),
                     MRECODE10 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE11 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL11    = MRSL11 + NVL(MRHIS.MRSL, 0),
                     MRECODE11 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE12 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL12    = MRSL12 + NVL(MRHIS.MRSL, 0),
                     MRECODE12 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            ELSE
              NULL;
          END CASE;
        END IF;
        -------------------------------------------------------
        FETCH C_MRSLHIS
          INTO MRSLHIS;
      END LOOP;
      CLOSE C_MRSLHIS;
      -------------------------------------------------------
    END LOOP;
    CLOSE C_MRHIS;
  END UPDATEMRSLHIS_CK;

  --���˼��
  PROCEDURE SP_MRSLCHECK(P_SMFID     IN VARCHAR2,
                         P_MRMID     IN VARCHAR2,
                         P_MRSCODE   IN VARCHAR2,
                         P_MRECODE   IN NUMBER,
                         P_MRSL      IN NUMBER,
                         P_MRADDSL   IN NUMBER,
                         P_MRRDATE   IN DATE,
                         O_ERRFLAG   OUT VARCHAR2,
                         O_IFMSG     OUT VARCHAR2,
                         O_MSG       OUT VARCHAR2,
                         O_EXAMINE   OUT VARCHAR2,
                         O_SUBCOMMIT OUT VARCHAR2) AS
    V_THREEAVGSL NUMBER(12, 2);
    V_MRSL       NUMBER(12, 2);
    V_MRSLCHECK  VARCHAR2(10); --����ˮ��������ʾ
    V_MRSLSUBMIT VARCHAR2(10); --����ˮ����������
    V_MRBASECKSL NUMBER(10); --����У�����
  BEGIN
    V_MRSLCHECK  := FPARA(P_SMFID, 'MRSLCHECK');
    V_MRSLSUBMIT := FPARA(P_SMFID, 'MRSLSUBMIT');
    V_MRBASECKSL := TO_NUMBER(FPARA(P_SMFID, 'MRBASECKSL'));

    IF (V_MRSLCHECK = 'Y' AND V_MRSLSUBMIT = 'N') OR
       (V_MRSLCHECK = 'N' AND V_MRSLSUBMIT = 'Y') OR
       (V_MRSLCHECK = 'Y' AND V_MRSLSUBMIT = 'Y') AND P_MRSL > V_MRBASECKSL THEN
      IF P_MRSCODE IS NULL THEN
        O_MSG := '��������Ϊ��,����!';
        RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,����!');
      END IF;
      IF P_MRECODE IS NULL THEN
        O_MSG := '����ֹ��Ϊ��,����!';
        RAISE_APPLICATION_ERROR(ERRCODE, '����ֹ��Ϊ��,����!');
      END IF;
      IF P_MRSL IS NULL THEN
        O_MSG := '����ˮ��Ϊ��,����!';
        RAISE_APPLICATION_ERROR(ERRCODE, '����ˮ��Ϊ��,����!');
      END IF;
      IF P_MRADDSL IS NULL THEN
        O_MSG := '����Ϊ��,����!';
        RAISE_APPLICATION_ERROR(ERRCODE, '����Ϊ��,����!');
      END IF;
      IF P_MRADDSL < 0 THEN
        O_MSG := '����С����,����!';
        RAISE_APPLICATION_ERROR(ERRCODE, '����С����,����!');
      END IF;
      IF P_MRRDATE IS NULL THEN
        O_MSG := '��������Ϊ��,����!';
        RAISE_APPLICATION_ERROR(ERRCODE, '��������Ϊ��,����!');
      END IF;
      --
      IF P_MRSL < 0 THEN
        O_MSG := '����ˮ������С����!';
        RAISE_APPLICATION_ERROR(ERRCODE, '����ˮ������С����!');
      ELSIF P_MRSL = 0 THEN
        O_MSG       := '����ˮ��������,�Ƿ�ȷ��?';
        O_ERRFLAG   := 'N';
        O_IFMSG     := 'Y';
        O_EXAMINE   := V_MRSLCHECK;
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF P_MRSL > 0 THEN
        V_MRSL       := FGETMRSLMONAVG(P_MRMID, P_MRSL, P_MRRDATE);
        V_THREEAVGSL := FGETTHREEMONAVG(P_MRMID);
      END IF;

      IF V_MRSL IS NULL THEN
        O_MSG       := '���¾����쳣!';
        O_ERRFLAG   := 'Y';
        O_IFMSG     := 'Y';
        O_EXAMINE   := 'N';
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_MRSL < -100 THEN
        O_MSG       := '���¾�����������쳣!';
        O_ERRFLAG   := 'Y';
        O_IFMSG     := 'Y';
        O_EXAMINE   := 'N';
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_MRSL < 0 AND V_MRSL >= -100 THEN
        O_MSG       := '�ɺ����쳣!';
        O_ERRFLAG   := 'N';
        O_IFMSG     := 'N';
        O_EXAMINE   := 'N';
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_MRSL = 0 THEN
        O_MSG       := '����ˮΪ��,�Ƿ�ȷ��?';
        O_ERRFLAG   := 'N';
        O_IFMSG     := 'Y';
        O_EXAMINE   := V_MRSLCHECK;
        O_SUBCOMMIT := 'N';
        RETURN;
      END IF;

      IF V_THREEAVGSL IS NULL THEN
        O_MSG       := '������ƽ���쳣!';
        O_ERRFLAG   := 'Y';
        O_IFMSG     := 'Y';
        O_EXAMINE   := 'N';
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_THREEAVGSL < -100 THEN
        O_MSG       := '�����¾�����������쳣!';
        O_ERRFLAG   := 'Y';
        O_IFMSG     := 'Y';
        O_EXAMINE   := 'N';
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_THREEAVGSL < 0 AND V_THREEAVGSL >= -100 THEN
        O_MSG       := '�ɺ����쳣!';
        O_ERRFLAG   := 'N';
        O_IFMSG     := 'N';
        O_EXAMINE   := 'N';
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_THREEAVGSL = 0 THEN
        O_MSG       := 'ǰ���¾���Ϊ��,��ȷ��?';
        O_ERRFLAG   := 'N';
        O_IFMSG     := 'Y';
        O_EXAMINE   := V_MRSLCHECK;
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_THREEAVGSL > 0 THEN
        IF V_MRSL >= V_THREEAVGSL * TO_NUMBER(FPARA(P_SMFID, 'MRSLMAX')) THEN
          O_MSG       := '����ˮ���ѳ������¾�����' || FPARA(P_SMFID, 'MRSLMAX') ||
                         '��,�Ƿ����쵼��˲���ס����ƻ�?';
          O_ERRFLAG   := 'N';
          O_IFMSG     := 'Y';
          O_EXAMINE   := 'N';
          O_SUBCOMMIT := V_MRSLSUBMIT;
          RETURN;
        ELSIF V_MRSL <= V_THREEAVGSL * TO_NUMBER(FPARA(P_SMFID, 'MRSLMSG')) OR
              (V_MRSL >=
              V_THREEAVGSL * (1 + TO_NUMBER(FPARA(P_SMFID, 'MRSLMSG'))) AND
              V_MRSL < V_THREEAVGSL * TO_NUMBER(FPARA(P_SMFID, 'MRSLMAX'))) THEN
          O_MSG       := '����ˮ���ѳ������¾���������' ||
                         TO_NUMBER(FPARA(P_SMFID, 'MRSLMSG')) * 100 ||
                         '%,�Ƿ�ȷ��?';
          O_ERRFLAG   := 'N';
          O_IFMSG     := 'Y';
          O_EXAMINE   := V_MRSLCHECK;
          O_SUBCOMMIT := 'N';
          RETURN;
        ELSE
          O_MSG       := '��������!';
          O_ERRFLAG   := 'N';
          O_IFMSG     := 'N';
          O_EXAMINE   := 'N';
          O_SUBCOMMIT := 'N';
          RETURN;
        END IF;
      END IF;
    ELSE
      O_ERRFLAG   := 'N';
      O_IFMSG     := 'N';
      O_EXAMINE   := 'N';
      O_SUBCOMMIT := 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_ERRFLAG   := 'Y';
      O_IFMSG     := 'Y';
      O_EXAMINE   := 'N';
      O_SUBCOMMIT := 'N';
      RAISE;
  END;

  --��¼���¾���
  FUNCTION FGETMRSLMONAVG(P_MIID    IN VARCHAR2,
                          P_MRSL    IN NUMBER,
                          P_MRRDATE IN DATE) RETURN NUMBER IS
    V_AVGMRSL  NUMBER(12, 2);
    V_MONCOUNT NUMBER(10);
    V_LASTDATE DATE; --�ϴγ�������
    MRADSL     METERREADSLHIS%ROWTYPE;
  BEGIN
    IF P_MIID IS NULL THEN
      RETURN - 101; --������ˮ����
    END IF;
    IF P_MRSL IS NULL THEN
      RETURN - 102; --����ˮ��Ϊ��
    END IF;
    IF P_MRSL < 0 THEN
      RETURN - 103; --����ˮ��Ϊ��
    END IF;
    IF P_MRRDATE IS NULL THEN
      RETURN - 104; --��������Ϊ��
    END IF;
    BEGIN
      SELECT * INTO MRADSL FROM METERREADSLHIS WHERE MRMID = P_MIID;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN - 1; --û���ҵ���¼
    END;
    V_LASTDATE := NULL; --��ʼ������Ϊ��
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL1 IS NOT NULL THEN
        IF MRADSL.MRRDATE1 IS NULL THEN
          RETURN - 2; --���������쳣
        ELSE
          V_LASTDATE := MRADSL.MRRDATE1;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --����·��쳣
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --��������
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL2 IS NOT NULL THEN
        IF MRADSL.MRRDATE2 IS NULL THEN
          RETURN - 2; --���������쳣
        ELSE
          V_LASTDATE := MRADSL.MRRDATE2;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --����·��쳣
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --��������
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL3 IS NOT NULL THEN
        IF MRADSL.MRRDATE3 IS NULL THEN
          RETURN - 2; --���������쳣
        ELSE
          V_LASTDATE := MRADSL.MRRDATE3;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --����·��쳣
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --��������
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL4 IS NOT NULL THEN
        IF MRADSL.MRRDATE4 IS NULL THEN
          RETURN - 2; --���������쳣
        ELSE
          V_LASTDATE := MRADSL.MRRDATE4;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --����·��쳣
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --��������
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL5 IS NOT NULL THEN
        IF MRADSL.MRRDATE5 IS NULL THEN
          RETURN - 2; --���������쳣
        ELSE
          V_LASTDATE := MRADSL.MRRDATE5;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --����·��쳣
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --��������
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL6 IS NOT NULL THEN
        IF MRADSL.MRRDATE6 IS NULL THEN
          RETURN - 2; --���������쳣
        ELSE
          V_LASTDATE := MRADSL.MRRDATE6;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --����·��쳣
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --��������
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL7 IS NOT NULL THEN
        IF MRADSL.MRRDATE7 IS NULL THEN
          RETURN - 2; --���������쳣
        ELSE
          V_LASTDATE := MRADSL.MRRDATE7;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --����·��쳣
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --��������
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL8 IS NOT NULL THEN
        IF MRADSL.MRRDATE8 IS NULL THEN
          RETURN - 2; --���������쳣
        ELSE
          V_LASTDATE := MRADSL.MRRDATE8;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --����·��쳣
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --��������
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL9 IS NOT NULL THEN
        IF MRADSL.MRRDATE9 IS NULL THEN
          RETURN - 2; --���������쳣
        ELSE
          V_LASTDATE := MRADSL.MRRDATE9;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --����·��쳣
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --��������
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL10 IS NOT NULL THEN
        IF MRADSL.MRRDATE10 IS NULL THEN
          RETURN - 2; --���������쳣
        ELSE
          V_LASTDATE := MRADSL.MRRDATE10;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --����·��쳣
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --��������
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL11 IS NOT NULL THEN
        IF MRADSL.MRRDATE11 IS NULL THEN
          RETURN - 2; --���������쳣
        ELSE
          V_LASTDATE := MRADSL.MRRDATE11;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --����·��쳣
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --��������
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL12 IS NOT NULL THEN
        IF MRADSL.MRRDATE12 IS NULL THEN
          RETURN - 2; --���������쳣
        ELSE
          V_LASTDATE := MRADSL.MRRDATE12;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --����·��쳣
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --��������
          END IF;
        END IF;
      END IF;
    END IF;

    IF V_LASTDATE IS NULL THEN
      RETURN - 4; --12���������û��¼
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL; --�쳣
  END;
  --ȡ����ƽ��
  FUNCTION FGETTHREEMONAVG(P_MIID IN VARCHAR2) RETURN NUMBER IS
    V_AVGSL NUMBER(12, 2);
    V_COUNT NUMBER(10);
    V_ALLSL NUMBER(12, 2);
    MRADSL  METERREADSLHIS%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MRADSL FROM METERREADSLHIS WHERE MRMID = P_MIID;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN - 1; --û���ҵ���¼,���ø���
    END;
    V_COUNT := 0; --��ʼ����ˮ���·�
    V_ALLSL := 0; --��ʼ�ۼƳ���ˮ��
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL1 IS NOT NULL THEN
        IF MRADSL.MRSL1 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL1;
        ELSE
          RETURN - 3; --��ʷ����ˮ��Ϊ��
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL2 IS NOT NULL THEN
        IF MRADSL.MRSL2 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL2;
        ELSE
          RETURN - 3; --��ʷ����ˮ��Ϊ��
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL3 IS NOT NULL THEN
        IF MRADSL.MRSL3 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL3;
        ELSE
          RETURN - 3; --��ʷ����ˮ��Ϊ��
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL4 IS NOT NULL THEN
        IF MRADSL.MRSL4 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL4;
        ELSE
          RETURN - 3; --��ʷ����ˮ��Ϊ��
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL5 IS NOT NULL THEN
        IF MRADSL.MRSL5 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL5;
        ELSE
          RETURN - 3; --��ʷ����ˮ��Ϊ��
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL6 IS NOT NULL THEN
        IF MRADSL.MRSL6 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL6;
        ELSE
          RETURN - 3; --��ʷ����ˮ��Ϊ��
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL7 IS NOT NULL THEN
        IF MRADSL.MRSL7 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL7;
        ELSE
          RETURN - 3; --��ʷ����ˮ��Ϊ��
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL8 IS NOT NULL THEN
        IF MRADSL.MRSL8 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL8;
        ELSE
          RETURN - 3; --��ʷ����ˮ��Ϊ��
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL9 IS NOT NULL THEN
        IF MRADSL.MRSL9 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL9;
        ELSE
          RETURN - 3; --��ʷ����ˮ��Ϊ��
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL10 IS NOT NULL THEN
        IF MRADSL.MRSL10 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL10;
        ELSE
          RETURN - 3; --��ʷ����ˮ��Ϊ��
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL11 IS NOT NULL THEN
        IF MRADSL.MRSL11 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL11;
        ELSE
          RETURN - 3; --��ʷ����ˮ��Ϊ��
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL12 IS NOT NULL THEN
        IF MRADSL.MRSL12 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL12;
        ELSE
          RETURN - 3; --��ʷ����ˮ��Ϊ��
        END IF;
      END IF;
    END IF;
    --û�ĳ����ļ�¼,���踴��
    IF V_COUNT = 0 THEN
      RETURN - 2; --������¼��Ϊ��
    ELSE
      V_AVGSL := ROUND(V_ALLSL / V_COUNT, 2);
      RETURN V_AVGSL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL; --�쳣
  END;

  --������
  PROCEDURE SP_USEADDINGSL(P_MRID  IN VARCHAR2, --������ˮ
                           P_MASID IN NUMBER, --������ˮ
                           O_STR   OUT VARCHAR2 --����ֵ
                           ) AS
  BEGIN
    --�����õ�������Ϣת����ʷ
    INSERT INTO METERADDSLHIS
      SELECT MASID,
             MASSCODEO,
             MASECODEN,
             MASUNINSDATE,
             MASUNINSPER,
             MASCREDATE,
             MASCID,
             MASMID,
             MASSL,
             MASCREPER,
             MASTRANS,
             MASBILLNO,
             MASSCODEN,
             MASINSDATE,
             MASINSPER,
             P_MRID
        FROM METERADDSL T
       WHERE MASID = P_MASID;
    --ɾ����ǰ������Ϣ
    DELETE METERADDSL T WHERE MASID = P_MASID;
    O_STR := '000';
  EXCEPTION
    WHEN OTHERS THEN
      O_STR := '999';
  END;

  --������
  PROCEDURE SP_RETADDINGSL(P_MASMRID IN VARCHAR2, --������ˮ
                           O_STR     OUT VARCHAR2 --����ֵ
                           ) AS
    V_COUNT NUMBER(10);
  BEGIN
    --�����õ�������Ϣת����ʷ
    SELECT COUNT(*)
      INTO V_COUNT
      FROM METERADDSLHIS
     WHERE MASMRID = P_MASMRID;
    IF V_COUNT = 0 THEN
      O_STR := '000';
      RETURN;
    END IF;
    INSERT INTO METERADDSL
      SELECT MASID,
             MASSCODEO,
             MASECODEN,
             MASUNINSDATE,
             MASUNINSPER,
             MASCREDATE,
             MASCID,
             MASMID,
             MASSL,
             MASCREPER,
             MASTRANS,
             MASBILLNO,
             MASSCODEN,
             MASINSDATE,
             MASINSPER
        FROM METERADDSLHIS T
       WHERE MASMRID = P_MASMRID;
    --ɾ����ǰ������Ϣ
    DELETE METERADDSLHIS T WHERE MASMRID = P_MASMRID;
    O_STR := '000';
  EXCEPTION
    WHEN OTHERS THEN
      O_STR := '999';
  END;
  --�������μ��
  FUNCTION FCHECKMRBATCH(P_MRID IN VARCHAR2, P_SMFID IN VARCHAR2)
    RETURN VARCHAR2 IS
    MB METERREADBATCH%ROWTYPE;
    MR METERREAD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN '����ƻ�������!';
    END;
    IF MR.MRPRIVILEGEFLAG = 'Y' THEN
      RETURN 'Y';
    END IF;
    IF MR.MRBATCH IS NULL THEN
      RETURN '����ƻ��г�������Ϊ��!';
    END IF;
    BEGIN
      SELECT *
        INTO MB
        FROM METERREADBATCH
       WHERE MRBSMFID = MR.MRSMFID
         AND MRBMONTH = MR.MRMONTH
         AND MR.MRBATCH = MRBBATCH;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN '��������δ����!';
    END;
    IF MB.MRBSDATE IS NULL OR MB.MRBEDATE IS NULL THEN
      RETURN '�������ζ�����ֹ����Ϊ��!';
    END IF;
    IF TRUNC(SYSDATE) >= TRUNC(MB.MRBSDATE) AND
       TRUNC(SYSDATE) <=
       TRUNC(MB.MRBEDATE) + TO_NUMBER(NVL(FPARA(P_SMFID, 'MRLASTIMP'), 0)) THEN
      RETURN 'Y';
    ELSE
      RETURN '�ѳ�����¼ˮ����ʱ������:[' || TO_CHAR(MB.MRBSDATE, 'yyyymmdd') || '��' || TO_CHAR(TRUNC(MB.MRBEDATE) +
                                                                                    TO_NUMBER(NVL(FPARA(P_SMFID,
                                                                                                        'MRLASTIMP'),
                                                                                                  0)),
                                                                                    'yyyymmdd') || ']';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '����쳣!';
  END;
  --������Ȩ
  PROCEDURE SP_MRPRIVILEGE(P_MRID IN VARCHAR2,
                           P_OPER IN VARCHAR2,
                           P_MEMO IN VARCHAR2,
                           O_STR  OUT VARCHAR2) AS
    V_TYPE  VARCHAR2(10); --��Ȩ����
    V_COUNT NUMBER(10);
    MR      METERREAD%ROWTYPE;
  BEGIN
    V_TYPE := FSYSPARA('0037');
    IF V_TYPE IS NULL THEN
      O_STR := '��Ȩ����δ����!';
      RETURN;
    END IF;
    IF V_TYPE NOT IN ('1', '2', '3') THEN
      O_STR := '��Ȩ���Ͷ������!';
      RETURN;
    END IF;
    BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
    EXCEPTION
      WHEN OTHERS THEN
        O_STR := '����ƻ�������!';
        RETURN;
    END;
    IF V_TYPE = '1' THEN
      IF MR.MRPRIVILEGEFLAG = 'Y' THEN
        O_STR := '�˳���ƻ�����Ȩ����,����Ҫ�ٴδ���!';
        RETURN;
      END IF;
      UPDATE METERREAD
         SET MRPRIVILEGEFLAG = 'Y',
             MRPRIVILEGEPER  = P_OPER,
             MRPRIVILEGEMEMO = P_MEMO,
             MRPRIVILEGEDATE = SYSDATE
       WHERE MRID = P_MRID
         AND MRIFREC = 'N';
    END IF;
    IF V_TYPE = '2' THEN
      SELECT COUNT(MRID)
        INTO V_COUNT
        FROM METERREAD
       WHERE MRSMFID = MR.MRSMFID
         AND MRBFID = MR.MRBFID
         AND MRIFREC = 'N';
      IF V_COUNT < 1 THEN
        O_STR := '�˱�᳭��ƻ�����Ȩ����,����Ҫ�ٴδ���!';
        RETURN;
      END IF;

      UPDATE METERREAD
         SET MRPRIVILEGEFLAG = 'Y',
             MRPRIVILEGEPER  = P_OPER,
             MRPRIVILEGEMEMO = P_MEMO,
             MRPRIVILEGEDATE = SYSDATE
       WHERE MRSMFID = MR.MRSMFID
         AND MRBFID = MR.MRBFID
         AND MRIFREC = 'N';
    END IF;
    IF V_TYPE = '3' THEN
      SELECT COUNT(MRID)
        INTO V_COUNT
        FROM METERREAD
       WHERE MRSMFID = MR.MRSMFID
         AND MRIFREC = 'N';
      IF V_COUNT < 1 THEN
        O_STR := '��Ӫҵ������ƻ�����Ȩ����,����Ҫ�ٴδ���!';
        RETURN;
      END IF;
      UPDATE METERREAD
         SET MRPRIVILEGEFLAG = 'Y',
             MRPRIVILEGEPER  = P_OPER,
             MRPRIVILEGEMEMO = P_MEMO,
             MRPRIVILEGEDATE = SYSDATE
       WHERE MRSMFID = MR.MRSMFID
         AND MRIFREC = 'N';
    END IF;
    O_STR := 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      O_STR := '��Ȩ�����쳣!';
  END;

  --��ѯ������Ƿ���ȫ��¼��ˮ��
  FUNCTION FCKKBFIDALLIMPUTSL(P_SMFID IN VARCHAR2,
                              P_BFID  IN VARCHAR2,
                              P_MON   IN VARCHAR2) RETURN VARCHAR2 IS
    V_COUNT NUMBER(10);
  BEGIN
    SELECT COUNT(MRID)
      INTO V_COUNT
      FROM METERREAD T
     WHERE T.MRSMFID = P_SMFID
       AND T.MRBFID = P_BFID
       AND T.MRMONTH = P_MON
       AND T.MRSL IS NULL;
    IF V_COUNT = 0 THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  --��ѯ������Ƿ������
  FUNCTION FCKKBFIDALLSUBMIT(P_SMFID IN VARCHAR2,
                             P_BFID  IN VARCHAR2,
                             P_MON   IN VARCHAR2) RETURN VARCHAR2 IS
    V_COUNT NUMBER(10);
  BEGIN
    SELECT COUNT(MRID)
      INTO V_COUNT
      FROM METERREAD T
     WHERE T.MRSMFID = P_SMFID
       AND T.MRBFID = P_BFID
       AND T.MRMONTH = P_MON
       AND T.MRIFSUBMIT <> 'Y'
       AND T.MRSL IS NOT NULL;
    IF V_COUNT = 0 THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --�������
  PROCEDURE SP_MRMRIFSUBMIT(P_MRID IN VARCHAR2,
                            P_OPER IN VARCHAR2,
                            P_MEMO IN VARCHAR2,
                            P_FLAG IN VARCHAR2) AS
    V_COUNT NUMBER(10);
    MR      METERREAD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
      IF MR.MRIFSUBMIT = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�������');
      END IF;
      IF MR.MRSL IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�û��š�'||MR.Mrcid||'������ˮ��Ϊ��');
      END IF;
      IF MR.MRIFREC = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�ѼƷ��������');
      END IF;
/*    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�ĳ����¼');*/
    END;

    UPDATE METERREAD
       SET MRIFSUBMIT      = 'Y',
           MRCHKFLAG       = 'Y', --���˱�־
           MRCHKDATE       = SYSDATE, --��������
           MRCHKPER        = P_OPER, --������Ա
           MRCHKSCODE      = MR.MRSCODE, --ԭ����
           MRCHKECODE      = MR.MRECODE, --ԭֹ��
           MRCHKSL         = MR.MRSL, --ԭˮ��
           MRCHKADDSL      = MR.MRADDSL, --ԭ����
           MRCHKCARRYSL    = MR.MRCARRYSL, --ԭ��λˮ��
           MRCHKRDATE      = MR.MRRDATE, --ԭ��������
           MRCHKFACE       = MR.MRFACE, --ԭ���
           MRCHKRESULT = (CASE
                           WHEN P_FLAG = '1' THEN
                            'ȷ��ͨ��'
                           ELSE
                            '�˻�������'
                         END), --���������
           MRCHKRESULTMEMO = (CASE
                               WHEN P_FLAG = '1' THEN
                                'ȷ��ͨ��'
                               ELSE
                                '�˻�������'
                             END) --�����˵��
     WHERE MRID = P_MRID;

    IF P_FLAG = '0' THEN
      --������ͨ��
      UPDATE METERREAD
         SET MRREADOK     = 'N',
            MRIFSUBMIT    = 'N',
             MRRDATE      = NULL,
             MRECODE      = NULL,
             MRSL         = NULL,
             MRFACE       = NULL,
             MRFACE2      = NULL,
             MRFACE3      = NULL,
             MRFACE4      = NULL,
             MRECODECHAR  = NULL,
             MRDATASOURCE = NULL
       WHERE MRID = P_MRID;
    END IF;

/*  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '�����쳣');*/
  END;

  --����ˮ��¼��ʱ����ֹ����������벻�ȼ�¼������Ϣ
  PROCEDURE SP_MRSLERRCHK(P_MRID            IN VARCHAR2, --������ˮ��
                          P_MRCHKPER        IN VARCHAR2, --������Ա
                          P_MRCHKSCODE      IN NUMBER, --ԭ����
                          P_MRCHKECODE      IN NUMBER, --ԭֹ��
                          P_MRCHKSL         IN NUMBER, --ԭˮ��
                          P_MRCHKADDSL      IN NUMBER, --ԭ����
                          P_MRCHKCARRYSL    IN NUMBER, --ԭ��λˮ��
                          P_MRCHKRDATE      IN DATE, --ԭ��������
                          P_MRCHKFACE       IN VARCHAR2, --ԭ���
                          P_MRCHKRESULT     IN VARCHAR2, --���������
                          P_MRCHKRESULTMEMO IN VARCHAR2, --�����˵��
                          O_STR             OUT VARCHAR2 --����ֵ
                          ) AS
    MR METERREAD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
    EXCEPTION
      WHEN OTHERS THEN
        O_STR := '����ƻ�������';
    END;
    UPDATE METERREAD
       SET MRCHKFLAG               = 'Y', --���˱�־
           MRCHKDATE�������������� = SYSDATE, --��������
           MRCHKPER                = P_MRCHKPER, --������Ա
           MRCHKSCODE              = P_MRCHKSCODE, --ԭ����
           MRCHKECODE              = P_MRCHKECODE, --ԭֹ��
           MRCHKSL                 = P_MRCHKSL, --ԭˮ��
           MRCHKADDSL              = P_MRCHKADDSL, --ԭ����
           MRCHKCARRYSL            = P_MRCHKCARRYSL, --ԭ��λˮ��
           MRCHKRDATE              = P_MRCHKRDATE, --ԭ��������
           MRCHKFACE               = P_MRCHKFACE, --ԭ���
           MRCHKRESULT             = P_MRCHKRESULT, --���������
           MRCHKRESULTMEMO         = P_MRCHKRESULTMEMO --�����˵��
     WHERE MRID = P_MRID;
    O_STR := 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      O_STR := '��¼������Ϣ�쳣';
  END;

  /*
  �������ѣ��㷨
  1��ǰn�ξ�����     ���������ˮ������ʷ�������12�γ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���
  2���ϴ�ˮ����      ���һ�γ���ˮ��������0ˮ����
  3��ȥ��ͬ��ˮ����  ȥ��ͬ�����·ݵĳ���ˮ��������0ˮ����
  4��ȥ��ȴξ�����  ȥ��ȵĳ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���

  ��meterread/meterreadhis��������¼�ṹ
  mrthreesl   number(10)    ǰn�ξ���
  mrthreeje01 number(13,3)  ǰn�ξ�ˮ��
  mrthreeje02 number(13,3)  ǰn�ξ���ˮ��
  mrthreeje03 number(13,3)  ǰn�ξ�ˮ��Դ��

  mrlastsl    number(10)    �ϴ�ˮ��
  mrlastje01  number(13,3)  �ϴ�ˮ��
  mrlastje02  number(13,3)  �ϴ���ˮ��
  mrlastje03  number(13,3)  �ϴ�ˮ��Դ��

  mryearsl    number(10)    ȥ��ͬ��ˮ��
  mryearje01  number(13,3)  ȥ��ͬ��ˮ��
  mryearje02  number(13,3)  ȥ��ͬ����ˮ��
  mryearje03  number(13,3)  ȥ��ͬ��ˮ��Դ��

  mrlastyearsl    number(10)    ȥ��ȴξ���
  mrlastyearje01  number(13,3)  ȥ��ȴξ�ˮ��
  mrlastyearje02  number(13,3)  ȥ��ȴξ���ˮ��
  mrlastyearje03  number(13,3)  ȥ��ȴξ�ˮ��Դ��
  */
  PROCEDURE GETMRHIS(P_MIID   IN VARCHAR2,
                     P_MONTH  IN VARCHAR2,
                     O_SL_1   OUT NUMBER,
                     O_JE01_1 OUT NUMBER,
                     O_JE02_1 OUT NUMBER,
                     O_JE03_1 OUT NUMBER,
                     O_SL_2   OUT NUMBER,
                     O_JE01_2 OUT NUMBER,
                     O_JE02_2 OUT NUMBER,
                     O_JE03_2 OUT NUMBER,
                     O_SL_3   OUT NUMBER,
                     O_JE01_3 OUT NUMBER,
                     O_JE02_3 OUT NUMBER,
                     O_JE03_3 OUT NUMBER,
                     O_SL_4   OUT NUMBER,
                     O_JE01_4 OUT NUMBER,
                     O_JE02_4 OUT NUMBER,
                     O_JE03_4 OUT NUMBER) IS
    CURSOR C_MRH(V_MIID METERREAD.MRMID%TYPE) IS
      SELECT NVL(MRSL, 0),
             NVL(MRRECJE01, 0),
             NVL(MRRECJE02, 0),
             NVL(MRRECJE03, 0),
             MRMONTH
        FROM METERREADHIS
       WHERE MRMID = V_MIID
            /*and mrsl > 0*/
         AND (/*MRDATASOURCE <> '9' OR*/ MRDATASOURCE IS NULL)
       ORDER BY MRRDATE DESC;

    MRH METERREADHIS%ROWTYPE;
    N1  INTEGER := 0;
    N2  INTEGER := 0;
    N3  INTEGER := 0;
    N4  INTEGER := 0;
  BEGIN
    OPEN C_MRH(P_MIID);
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
        N1              := N1 + 1;
        MRH.MRTHREESL   := NVL(MRH.MRTHREESL, 0) + MRH.MRSL; --ǰn�ξ���
        MRH.MRTHREEJE01 := NVL(MRH.MRTHREEJE01, 0) + MRH.MRRECJE01; --ǰn�ξ�ˮ��
        MRH.MRTHREEJE02 := NVL(MRH.MRTHREEJE02, 0) + MRH.MRRECJE02; --ǰn�ξ���ˮ��
        MRH.MRTHREEJE03 := NVL(MRH.MRTHREEJE03, 0) + MRH.MRRECJE03; --ǰn�ξ�ˮ��Դ��
      END IF;

      IF C_MRH%ROWCOUNT = 1 THEN
        N2             := N2 + 1;
        MRH.MRLASTSL   := NVL(MRH.MRLASTSL, 0) + MRH.MRSL; --�ϴ�ˮ��
        MRH.MRLASTJE01 := NVL(MRH.MRLASTJE01, 0) + MRH.MRRECJE01; --�ϴ�ˮ��
        MRH.MRLASTJE02 := NVL(MRH.MRLASTJE02, 0) + MRH.MRRECJE02; --�ϴ���ˮ��
        MRH.MRLASTJE03 := NVL(MRH.MRLASTJE03, 0) + MRH.MRRECJE03; --�ϴ�ˮ��Դ��
      END IF;

      IF MRH.MRMONTH = TO_CHAR(TO_NUMBER(SUBSTR(P_MONTH, 1, 4)) - 1) || '.' ||
         SUBSTR(P_MONTH, 6, 2) THEN
        N3             := N3 + 1;
        MRH.MRYEARSL   := NVL(MRH.MRYEARSL, 0) + MRH.MRSL; --ȥ��ͬ��ˮ��
        MRH.MRYEARJE01 := NVL(MRH.MRYEARJE01, 0) + MRH.MRRECJE01; --ȥ��ͬ��ˮ��
        MRH.MRYEARJE02 := NVL(MRH.MRYEARJE02, 0) + MRH.MRRECJE02; --ȥ��ͬ����ˮ��
        MRH.MRYEARJE03 := NVL(MRH.MRYEARJE03, 0) + MRH.MRRECJE03; --ȥ��ͬ��ˮ��Դ��
      END IF;

      IF MRH.MRSL > 0 AND TO_NUMBER(SUBSTR(MRH.MRMONTH, 1, 4)) =
         TO_NUMBER(SUBSTR(P_MONTH, 1, 4)) - 1 THEN
        N4                 := N4 + 1;
        MRH.MRLASTYEARSL   := NVL(MRH.MRLASTYEARSL, 0) + MRH.MRSL; --ȥ��ȴξ���
        MRH.MRLASTYEARJE01 := NVL(MRH.MRLASTYEARJE01, 0) + MRH.MRRECJE01; --ȥ��ȴξ�ˮ��
        MRH.MRLASTYEARJE02 := NVL(MRH.MRLASTYEARJE02, 0) + MRH.MRRECJE02; --ȥ��ȴξ���ˮ��
        MRH.MRLASTYEARJE03 := NVL(MRH.MRLASTYEARJE03, 0) + MRH.MRRECJE03; --ȥ��ȴξ�ˮ��Դ��
      END IF;
    END LOOP;

    O_SL_1 := (CASE
                WHEN N1 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRTHREESL / N1, 0)
              END);
    O_JE01_1 := (CASE
                  WHEN N1 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRTHREEJE01 / N1, 3)
                END);
    O_JE02_1 := (CASE
                  WHEN N1 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRTHREEJE02 / N1, 3)
                END);
    O_JE03_1 := (CASE
                  WHEN N1 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRTHREEJE03 / N1, 3)
                END);

    O_SL_2 := (CASE
                WHEN N2 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRLASTSL / N2, 0)
              END);
    O_JE01_2 := (CASE
                  WHEN N2 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRLASTJE01 / N2, 3)
                END);
    O_JE02_2 := (CASE
                  WHEN N2 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRLASTJE02 / N2, 3)
                END);
    O_JE03_2 := (CASE
                  WHEN N2 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRLASTJE03 / N2, 3)
                END);

    O_SL_3 := (CASE
                WHEN N3 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRYEARSL / N3, 0)
              END);
    O_JE01_3 := (CASE
                  WHEN N3 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRYEARJE01 / N3, 3)
                END);
    O_JE02_3 := (CASE
                  WHEN N3 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRYEARJE02 / N3, 3)
                END);
    O_JE03_3 := (CASE
                  WHEN N3 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRYEARJE03 / N3, 3)
                END);

    O_SL_4 := (CASE
                WHEN N4 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRLASTYEARSL / N4, 0)
              END);
    O_JE01_4 := (CASE
                  WHEN N4 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRLASTYEARJE01 / N4, 3)
                END);
    O_JE02_4 := (CASE
                  WHEN N4 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRLASTYEARJE02 / N4, 3)
                END);
    O_JE03_4 := (CASE
                  WHEN N4 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRLASTYEARJE03 / N4, 3)
                END);
  EXCEPTION
    WHEN OTHERS THEN
      IF C_MRH%ISOPEN THEN
        CLOSE C_MRH;
      END IF;
  END GETMRHIS;

  PROCEDURE SP_GETNOREAD(VMID   IN VARCHAR2,
                         VCONT  OUT NUMBER,
                         VTOTAL OUT NUMBER) IS
    CURSOR C_MRHIS IS
      SELECT * FROM METERREADHIS WHERE MRMID = VMID ORDER BY MRMONTH;
    MRHIS METERREADHIS%ROWTYPE;
  BEGIN
    VCONT  := 0;
    VTOTAL := 0;

    OPEN C_MRHIS;
    LOOP
      FETCH C_MRHIS
        INTO MRHIS;
      EXIT WHEN C_MRHIS%NOTFOUND OR C_MRHIS%NOTFOUND IS NULL;
      --δ������Χ���ա�������ͳ�ơ��еġ��ǡ�ʵ�����ݷ�Χ
      IF NOT ((MRHIS.MRFACE2 IS NULL OR MRHIS.MRFACE2 = '10') AND
          MRHIS.MRECODECHAR <> '0') THEN
        VCONT  := VCONT + 1;
        VTOTAL := VTOTAL + 1;
      ELSE
        VCONT := 0;
      END IF;
    END LOOP;
    CLOSE C_MRHIS;
  EXCEPTION
    WHEN OTHERS THEN
      VCONT  := 0;
      VTOTAL := 0;
  END;

  -- �������������
  --p_cont ���ɳ������������
  --p_commit �ύ��־
  --time 2010-03-14  by wy
  PROCEDURE SP_POSHANDCREATE(P_SMFID   IN VARCHAR2,
                             P_MONTH   IN VARCHAR2,
                             P_BFIDSTR IN VARCHAR2,
                             P_OPER    IN VARCHAR2,
                             P_COMMIT  IN VARCHAR2) IS
    V_SQL VARCHAR2(4000);
    TYPE CUR IS REF CURSOR;
    C_PHMR  CUR;
    MR      METERREAD%ROWTYPE;
    V_BATCH VARCHAR2(10);
    MH      MACHINEIOLOG%ROWTYPE;
  BEGIN
    V_BATCH := FGETSEQUENCE('MACHINEIOLOG');

    MH.MILID    := V_BATCH; --�������������ˮ��
    MH.MILSMFID := P_SMFID; --Ӫ����˾
    --mh.MILMACHINETYPE        :=     ;--������ͺ�
    --mh.MILMACHINEID          :=     ;--��������
    MH.MILMONTH := P_MONTH; --�����·�
    --mh.MILOUTROWS            :=     ;--��������
    MH.MILOUTDATE     := SYSDATE; --��������
    MH.MILOUTOPERATOR := P_OPER; --���Ͳ���Ա
    --mh.MILINDATE             :=     ;--��������
    --mh.MILINOPERATOR         :=     ;--���ղ���Ա
    MH.MILREADROWS := 0; --��������
    MH.MILINORDER  := 0; --���ܴ���
    --mh.MILOPER               :=     ;--�����¼����Ա(����ʱȷ��)
    MH.MILGROUP := '1'; --����ģʽ

    INSERT INTO MACHINEIOLOG VALUES MH;

    V_SQL := ' update meterread set
MROUTID=''' || V_BATCH || ''' ,
MRINORDER=ROWNUM,
MROUTFLAG=''Y'',
MROUTDATE=TRUNC(sysdate)
where mrsmfid=''' || P_SMFID || ''' and mrmonth=''' || P_MONTH ||
             ''' and MRbfid in (''' || P_BFIDSTR || ''')
and MRREADOK=''N''
and MROUTFLAG=''N''';
    /*insert into ���Ա� (STR1) values(v_sql) ;
    commit;
    return ;*/
    EXECUTE IMMEDIATE V_SQL;
    /*v_sql := '';
    open c_phmr for v_sql;
        loop
          fetch c_phmr
            into mr;
            null;
        end loop;
    close c_phmr;*/
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  -- �����������ȡ��

  --p_commit �ύ��־
  --time 2010-06-21  by wy
  PROCEDURE SP_POSHANDCANCEL(P_SMFID   IN VARCHAR2,
                             P_MONTH   IN VARCHAR2,
                             P_BFIDSTR IN VARCHAR2,
                             P_OPER    IN VARCHAR2,
                             P_COMMIT  IN VARCHAR2) IS
    V_SQL   VARCHAR2(4000);
    ROWCNT  NUMBER;
    V_COUNT NUMBER;
    TYPE CUR IS REF CURSOR;
    C_PHMR    CUR;
    MR        METERREAD%ROWTYPE;
    V_BATCH   VARCHAR2(10);
    V_BFIDSTR VARCHAR2(1000);
    MH        MACHINEIOLOG%ROWTYPE;
  BEGIN

    UPDATE METERREAD
       SET MROUTID   = NULL,
           MRINORDER = NULL,
           MROUTFLAG = 'N',
           MROUTDATE = TRUNC(SYSDATE)
     WHERE MRSMFID = P_SMFID
       AND MRMONTH = P_MONTH
       AND INSTR(P_BFIDSTR, MRBFID) > 0;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  -- ���������ȡ��
  --p_batch �������������
  --p_commit �ύ��־
  --time 2010-03-15  by wy
  PROCEDURE SP_POSHANDDEL(P_BATCH IN VARCHAR2, P_COMMIT IN VARCHAR2) IS
    MR METERREAD%ROWTYPE;
  BEGIN
    UPDATE METERREAD
       SET MROUTFLAG = 'N', MROUTID = NULL
     WHERE MROUTID = P_BATCH
       AND MROUTFLAG = 'Y';
    DELETE MACHINEIOLOG WHERE MILID = P_BATCH;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  -- ��������
  --p_type �����������
  --p_batch �������������
  --time 2010-03-15  by wy
  PROCEDURE SP_POSHANDCHK(P_TYPE IN VARCHAR2, P_BATCH IN VARCHAR2) IS
    MR METERREAD%ROWTYPE;
  BEGIN
    NULL;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  -- ��������ݵ���
  --p_oper �������Ա
  --p_type ���ݵ��뷽ʽ
  -- ��������ݵ���
  --p_oper �������Ա
  --p_type ���ݵ��뷽ʽ
  --time 2010-03-22  by yf
  PROCEDURE SP_POSHANDIMP_HRB(P_OPER IN VARCHAR2, --����Ա
                              P_SMFID IN VARCHAR2, --Ӫҵ��
                          P_TYPE IN VARCHAR2, --���뷽ʽ
                          O_MSG OUT VARCHAR2  --���ظ�����Ϣ
                          ) IS
    PB PBPARMTEMP%ROWTYPE;
    V_COUNT NUMBER(10);
    V_RET   VARCHAR2(10);
    V_DATE       DATE;
    V_TEMPNUM    NUMBER(10);
    V_TEMPNUM1   NUMBER(10);
    V_ADDSL      NUMBER(10);
    V_TEMPSTR    VARCHAR2(10);
    V_ERRFLAG    VARCHAR2(200);
    V_IFMSG      VARCHAR2(200);
    V_MSG        VARCHAR2(200);
    V_EXAMINE    VARCHAR2(200);
    V_SUBCOMMIT  VARCHAR2(200);
    V_SEQNO      VARCHAR2(10);
    V_UROW       NUMBER(10);
    MR METERREAD%ROWTYPE;
    
    CURSOR C_READ IS
           SELECT * FROM PBPARMTEMP;
  BEGIN
    SELECT TRIM(TO_CHAR(SEQ_BILLSEQNO.NEXTVAL,'0000000000')) INTO V_SEQNO FROM DUAL;
    OPEN C_READ;
    LOOP
      FETCH C_READ
        INTO PB
      ;
      EXIT WHEN C_READ%NOTFOUND OR C_READ%NOTFOUND IS NULL;
           SELECT * INTO MR FROM METERREAD WHERE MRID=PB.C67;
           --PB�ֶ�˵��
           /*
           ˮ���C1
            �����C2
            ����C3
            ��������C4
            �û�����C5
            ����C6
            �������C7
            ����Ա���C8
            ����Ա����C9
            Ӧ������C10
            ƫ������C11
            ��̬C12
            ���C13
            �̶���C14
            �Ƿ�������C15
            ������־C16
            �û���C17
            ��ַC18
            ��C19
            ��λC20
            ���1C21
            ���2C22
            ���3C23
            ���4C24
            ���5C25
            �˿���C26
            �ֱܷ� ���ձ�־C27
            �ֱܷ����C28
            ���ձ��־C29
            ���ձ������C30
            �绰C31
            �ֻ�C32
            ˮ����Ϣ�Ƿ��޸��ϴ�C33
            ���ӱ�ǩC34
            ���ӱ�ǩ�Ƿ�ƥ��C35
            �û���C36
            �û����Ƿ�ƥ��C37
            �ޱ��־C38
            ����C39
            ֹ��C40
            ˮ��C41
            �Ʒѱ�־C42
            �ۺϵ���C43
            ˮ�����C44
            ˮ���������C45
            ��ϱ�־C46
            ˮ��C47
            ��ˮ��C48
            ������3C49
            ������4C50
            ������5C51
            ����ʱ��C52
            �ϴ�ʱ��C53
            �ϴ�ˮ��C54
            ǰ����ƽ����C55
            ��������C56
            Ƿ�ѽ��C57
            Ƿ�ѱ���C58
            ����Ƿ����C59
            �ϴνɷ�����C60
            �ϴνɷѽ��C61
            �շѽ��C62
            Ʊ�ݺ�C63
            ��ӡ����C64
            �շ������Ƿ��ϴ�C65
            �����޶�����C66
            ������ˮ��C67
           */
           --1��ȡ����
      V_COUNT  := 0;
      
      IF PB.C16 = '0' AND PB.C16 = '1' AND MR.MRREADOK='N' THEN
        --�ж��Ƿ�����������
        SELECT COUNT(*)
          INTO V_COUNT
          FROM METERADDSLHIS T
         WHERE MASMRID = PB.C67;
        IF V_COUNT > 0 THEN
          --������
          SP_ROLLBACKADDEDSL(MR.MRID, --������ˮ
                             V_RET --����ֵ
                             );
        END IF;
        --�ж���������
        SELECT COUNT(*)
          INTO V_COUNT
          FROM METERADDSL T
         WHERE MASMID = MR.MRID;
         
        V_ADDSL := 0;
         
        IF V_COUNT > 0 THEN
          --ȡδ������
          SP_FETCHADDINGSL(PB.C67, --������ˮ
                           PB.C1, --ˮ���
                           V_TEMPNUM1, --�ɱ�ֹ��
                           V_TEMPNUM, --�±����
                           V_ADDSL, --����
                           V_DATE, --��������
                           V_TEMPSTR, --�ӵ�����
                           V_RET --����ֵ
                           );
          /*MR.MRADDSL := V_ADDSL; --����
          MR.MRSL    := TO_NUMBER(PB.C16) - V_TEMPNUM + V_ADDSL;
        ELSE
          MR.MRADDSL := 0; --����
          MR.MRSL    := TO_NUMBER(PB.C21);*/
        END IF;
        MR.MRADDSL := V_ADDSL;
        MR.MRSL    := TO_NUMBER(PB.C41) - V_TEMPNUM + V_ADDSL;
        MR.MRINPUTDATE := SYSDATE;
        MR.MRRDATE     := to_date(PB.C52,'YYYY-MM-DD HH24:MI:SS')    ;
        MR.MRECODE     := TO_NUMBER(PB.C40);
        MR.MRECODECHAR := TRIM(TO_CHAR(MR.MRECODE));

        MR.MRREADOK := CASE
                         WHEN PB.C16 = '1' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        MR.MRDATASOURCE := '5';
           --2������Ƿ���
        IF PB.C12<>'01' THEN
           MR.MRIFSUBMIT := 'N';
           MR.MRFACE     := PB.C12;
           MR.MRFACE2    := PB.C13;
        END IF;   
         
           --3������Ƿ񲨶�ˮ��
        IF PB.C12='01' THEN
           SP_MRSLCHECK(MR.MRSMFID,
                     MR.MRMID,
                     MR.MRSCODE,
                     MR.MRECODE,
                     MR.MRSL,
                     0,
                     MR.MRRDATE,
                     V_ERRFLAG,
                     V_IFMSG,
                     V_MSG,
                     V_EXAMINE,
                     V_SUBCOMMIT);
        END IF;
        --MR.MRBFSDATE
        --����ƫ������
        IF TRUNC(MR.MRBFSDATE-SYSDATE)<=0 THEN
           MR.MRBFDAY := TRUNC(MR.MRBFSDATE-SYSDATE);
        ELSE
           IF TRUNC(MR.MRBFEDATE-SYSDATE)>=0 THEN
              MR.MRBFDAY := TRUNC(MR.MRBFEDATE-SYSDATE);
           ELSE
              MR.MRBFDAY := 0;
           END IF;
        END IF;
        
        UPDATE METERREAD
           SET MRINPUTDATE  = MR.MRINPUTDATE,
               MRRDATE      = MR.MRRDATE,
               MRECODE      = MR.MRECODE,
               MRECODECHAR  = MR.MRECODECHAR,
               MRSL         = MR.MRSL,
               MRREADOK     = MR.MRREADOK,
               MRDATASOURCE = MR.MRDATASOURCE,
               MRADDSL      = MR.MRADDSL,
               MRBFDAY      = MR.MRBFDAY,
               MRIFSUBMIT   = V_SUBCOMMIT
         WHERE MRID = MR.MRID;
         
         
      END IF;  
      
      IF PB.C33='1' THEN
            --�������ݣ����ɹ���
           PG_EWIDE_CUSTBASE_01.SP_CUSTCHANGE_BYMIID(
             TRIM(V_SEQNO),             --���ݱ��
             'X',                       --���ݱ��
             P_OPER,                    --������
             MR.MRMID,                  --�ͻ�����
             P_SMFID,                   --Ӫҵ��
             'N'                        --�Ƿ��ύ
             );
             
         V_UROW := V_UROW + 1;    
      END IF;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE MRID = MR.MRMID;   
    END LOOP;
    CLOSE C_READ;
    
    IF V_UROW>0 THEN
       O_MSG := '������ݺ�:��'||TRIM(V_SEQNO)||'��������'||V_UROW||'��';
       
    ELSE
       O_MSG := '�޸������ݣ�';
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      IF C_READ%ISOPEN THEN
        CLOSE C_READ;
      END IF;
      RAISE_APPLICATION_ERROR(-20010,
                              '����ʧ�ܣ�' || '�жϿͻ�����:' || PB.C1 || ', ' ||
                              SQLERRM);
      ROLLBACK;
  END;
  
  

  -- ��������ݵ���
  --p_oper �������Ա
  --p_type ���ݵ��뷽ʽ
  --time 2010-03-22  by yf
  PROCEDURE SP_POSHANDIMP(P_OPER IN VARCHAR2, --����Ա

                          P_TYPE IN VARCHAR2 --���뷽ʽ
                          ) IS
    NUM          NUMBER;
    V_COUNT      NUMBER;
    V_COUNT1     NUMBER;
    ROWCNT       NUMBER;
    V_TEMPSL     NUMBER(10);
    V_TEMPNUM    NUMBER(10);
    V_TEMPNUM1   NUMBER(10);
    V_ADDSL      NUMBER(10);
    V_TEMPSTR    VARCHAR2(10);
    V_RET        VARCHAR2(10);
    V_DATE       DATE;
    V_MAXCODE    NUMBER(10);
    MI           METERINFO%ROWTYPE;
    CI           CUSTINFO%ROWTYPE;
    MD           METERDOC%ROWTYPE;
    MR           METERREAD%ROWTYPE;
    RIMP         PBPARMTEMP%ROWTYPE;
    MRADSL       METERREADSLHIS%ROWTYPE;
    V_MRIFSUBMIT METERREAD.MRIFSUBMIT%TYPE;
    V_MRSMFID    METERREAD.MRSMFID%TYPE;
    V_ERRFLAG    VARCHAR2(200);
    V_IFMSG      VARCHAR2(200);
    V_MSG        VARCHAR2(200);
    V_EXAMINE    VARCHAR2(200);
    V_SUBCOMMIT  VARCHAR2(200);
    V_SL         NUMBER(10);
    V_FSLFLAG    VARCHAR2(1);
    CURSOR C_READ IS

      SELECT CASE
               WHEN TRIM(C9) < 0 THEN
                TO_CHAR(TO_NUMBER(C9) * -1)
               ELSE
                TRIM(C9)
             END, -- ���ڳ���
             TRIM(NULL), -- װ����
             TRIM(NULL), -- �����
             TRIM(CASE
                    WHEN TO_NUMBER(C9) >= 0 THEN
                     TO_NUMBER(C9) - TO_NUMBER(C8)
                    ELSE
                     (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                  END), -- ����ˮ��
             TRIM(NULL), -- ����ˮ��
             TRIM(CASE
                    WHEN TO_NUMBER(C9) >= 0 THEN
                     TO_NUMBER(C9) - TO_NUMBER(C8)
                    ELSE
                     (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                  END), -- �ϼ�ˮ��
             TRIM(NULL), -- ����ʱ��
             TRIM(C12), -- ����״̬
             TRIM(NULL), -- ˮ��״��
             TRIM(C3), -- ������ˮ
             MRMID,
             CASE
               WHEN (TO_NUMBER(FPARA(MRSMFID, 'MRBASECKSL')) <
                    TRIM(CASE
                            WHEN TO_NUMBER(C9) >= 0 THEN
                             TO_NUMBER(C9) - TO_NUMBER(C8)
                            ELSE
                             (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                          END) --ˮ��С��10������
                    AND TO_NUMBER(FPARA(MRSMFID, 'MRSLMSG')) * MRLASTSL <
                    TRIM(CASE
                                WHEN TO_NUMBER(C9) >= 0 THEN
                                 TO_NUMBER(C9) - TO_NUMBER(C8)
                                ELSE
                                 (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                              END) --ˮ����������2������
                    AND MRLASTSL > 1) --������ˮ�����ݲ��ж�
                    OR TO_NUMBER(C9) < 0 --����������� ��ϵͳ��Ҳ�����
                THEN
                'N'
               ELSE
                'Y'
             END --��������븺ˮ����־

        FROM PBPARMTEMP, METERREAD
       WHERE MRID = TRIM(C3)
         AND MRIFREC = 'N'
         AND ((P_TYPE = 'N' AND MRREADOK = 'N') OR P_TYPE = 'Y');
  BEGIN
    OPEN C_READ;
    LOOP
      FETCH C_READ
        INTO RIMP.C16, -- ���ڳ���
             RIMP.C17, -- װ����
             RIMP.C18, -- �����
             RIMP.C19, -- ����ˮ��
             RIMP.C20, -- ����ˮ��
             RIMP.C21, -- �ϼ�ˮ��
             RIMP.C25, -- ����ʱ��
             RIMP.C26, -- ����״̬
             RIMP.C30, -- ˮ��״��
             MR.MRID, -- ������ˮ
             MR.MRMID,
             V_FSLFLAG --��������븺ˮ����־
      ;
      EXIT WHEN C_READ%NOTFOUND OR C_READ%NOTFOUND IS NULL;

      V_COUNT  := 0;
      V_COUNT1 := 0;
      IF RIMP.C26 = '0' THEN
        --�ж��Ƿ�����������
        SELECT COUNT(*)
          INTO V_COUNT1
          FROM METERADDSLHIS T
         WHERE MASMRID = MR.MRID;
        IF V_COUNT1 > 0 THEN
          --������
          SP_ROLLBACKADDEDSL(MR.MRID, --������ˮ
                             V_RET --����ֵ
                             );
        END IF;
        --�ж���������
        SELECT COUNT(*)
          INTO V_COUNT
          FROM METERADDSL T
         WHERE MASMID = MR.MRMID;

        IF V_COUNT > 0 THEN
          --ȡδ������
          SP_FETCHADDINGSL(MR.MRID, --������ˮ
                           MR.MRMID, --ˮ���
                           V_TEMPNUM1, --�ɱ�ֹ��
                           V_TEMPNUM, --�±����
                           V_ADDSL, --����
                           V_DATE, --��������
                           V_TEMPSTR, --�ӵ�����
                           V_RET --����ֵ
                           );
          MR.MRADDSL := V_ADDSL; --����
          MR.MRSL    := TO_NUMBER(RIMP.C16) - V_TEMPNUM + V_ADDSL;
        ELSE
          MR.MRADDSL := 0; --����
          MR.MRSL    := TO_NUMBER(RIMP.C21);
        END IF;
        /*     mr.mraddsl         :=   0 ;  --����
        mr.mrsl           := to_number(rimp.c19 );*/
        MR.MRINPUTDATE := SYSDATE;
        MR.MRRDATE     := SYSDATE; --  to_date(rimp.c23,'yyyy-mm-dd')    ;
        MR.MRECODE     := TO_NUMBER(RIMP.C16);
        MR.MRECODECHAR := TRIM(TO_CHAR(MR.MRECODE));

        MR.MRREADOK := CASE
                         WHEN RIMP.C26 = '0' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        MR.MRDATASOURCE := '5';
        --������룬Ӫҵ��
        SELECT MRSCODE, MRSMFID
          INTO V_SL, V_MRSMFID
          FROM METERREAD
         WHERE MRID = MR.MRID;

        SP_MRSLCHECK(V_MRSMFID,
                     MR.MRMID,
                     V_SL,
                     MR.MRECODE,
                     MR.MRSL,
                     0,
                     MR.MRRDATE,
                     V_ERRFLAG,
                     V_IFMSG,
                     V_MSG,
                     V_EXAMINE,
                     V_SUBCOMMIT);

        /*  if v_errflag = 'N' and v_ifmsg   = 'Y' and v_examine = 'N' and v_subcommit='Y' then
          v_mrifsubmit      := 'N';
        else
            v_mrifsubmit      := 'Y';
        end if;*/

        /*v_mrifsubmit      := case when mr.mrecode-v_sl>0 then 'Y' else 'N' end  ;*/
        /*            if v_subcommit='Y' then
          v_subcommit:='N';
          else
            v_subcommit:='Y';
        end if;*/
        UPDATE METERREAD
           SET MRINPUTDATE  = MR.MRINPUTDATE,
               MRRDATE      = MR.MRRDATE,
               MRECODE      = MR.MRECODE,
               MRECODECHAR  = MR.MRECODECHAR,
               MRSL         = MR.MRSL,
               MRREADOK     = MR.MRREADOK,
               MRDATASOURCE = MR.MRDATASOURCE,
               MRADDSL      = MR.MRADDSL,
               MRIFSUBMIT   = V_FSLFLAG
         WHERE MRID = MR.MRID;
      END IF;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE MRID = MR.MRMID;
    END LOOP;
    CLOSE C_READ;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_READ%ISOPEN THEN
        CLOSE C_READ;
      END IF;
      RAISE_APPLICATION_ERROR(-20010,
                              '����ʧ�ܣ�' || '�жϿͻ�����:' || RIMP.C2 || ', ' ||
                              SQLERRM);
      ROLLBACK;
  END;
  PROCEDURE SP_POSHANDIMP1(P_OPER IN VARCHAR2, --����Ա

                           P_TYPE IN VARCHAR2 --���뷽ʽ
                           ) IS
    NUM          NUMBER;
    V_COUNT      NUMBER;
    V_COUNT1     NUMBER;
    ROWCNT       NUMBER;
    V_TEMPSL     NUMBER(10);
    V_TEMPNUM    NUMBER(10);
    V_TEMPNUM1   NUMBER(10);
    V_ADDSL      NUMBER(10);
    V_TEMPSTR    VARCHAR2(10);
    V_RET        VARCHAR2(10);
    V_DATE       DATE;
    V_MAXCODE    NUMBER(10);
    MI           METERINFO%ROWTYPE;
    CI           CUSTINFO%ROWTYPE;
    MD           METERDOC%ROWTYPE;
    MR           METERREAD%ROWTYPE;
    RIMP         PBPARMTEMP%ROWTYPE;
    MRADSL       METERREADSLHIS%ROWTYPE;
    V_MRIFSUBMIT METERREAD.MRIFSUBMIT%TYPE;
    V_MRSMFID    METERREAD.MRSMFID%TYPE;
    V_ERRFLAG    VARCHAR2(200);
    V_IFMSG      VARCHAR2(200);
    V_MSG        VARCHAR2(200);
    V_EXAMINE    VARCHAR2(200);
    V_SUBCOMMIT  VARCHAR2(200);
    V_SL         NUMBER(10);
    V_FSLFLAG    VARCHAR2(1);
    CURSOR C_READ IS

      SELECT CASE
               WHEN TRIM(C9) < 0 THEN
                TO_CHAR(TO_NUMBER(C9) * -1)
               ELSE
                TRIM(C9)
             END, -- ���ڳ���
             TRIM(C2), -- װ����
             TRIM(NULL), -- �����
             TRIM(CASE
                    WHEN TO_NUMBER(C9) >= 0 THEN
                     TO_NUMBER(C9) - TO_NUMBER(C8)
                    ELSE
                     (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                  END), -- ����ˮ��
             TRIM(NULL), -- ����ˮ��
             TRIM(CASE
                    WHEN TO_NUMBER(C9) >= 0 THEN
                     TO_NUMBER(C9) - TO_NUMBER(C8)
                    ELSE
                     (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                  END), -- �ϼ�ˮ��
             TRIM(NULL), -- ����ʱ��
             TRIM(C12), -- ����״̬
             TRIM(NULL), -- ˮ��״��
             TRIM(C3), -- ������ˮ
             MRMID,
             CASE
               WHEN (TO_NUMBER(FPARA(MRSMFID, 'MRBASECKSL')) <
                    TRIM(CASE
                            WHEN TO_NUMBER(C9) >= 0 THEN
                             TO_NUMBER(C9) - TO_NUMBER(C8)
                            ELSE
                             (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                          END) --ˮ��С��10������
                    AND TO_NUMBER(FPARA(MRSMFID, 'MRSLMSG')) * MRLASTSL <
                    TRIM(CASE
                                WHEN TO_NUMBER(C9) >= 0 THEN
                                 TO_NUMBER(C9) - TO_NUMBER(C8)
                                ELSE
                                 (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                              END) --ˮ����������2������
                    AND MRLASTSL > 1) --������ˮ�����ݲ��ж�
                    OR TO_NUMBER(C9) < 0 --����������� ��ϵͳ��Ҳ�����
                THEN
                'N'
               ELSE
                'Y'
             END --��������븺ˮ����־

        FROM PBPARMTEMP, METERREAD
       WHERE MRMCODE = TRIM(C2)
         AND MRIFREC = 'N'
         AND ((P_TYPE = 'N' AND MRREADOK = 'N') OR P_TYPE = 'Y');
  BEGIN
    OPEN C_READ;
    LOOP
      FETCH C_READ
        INTO RIMP.C16, -- ���ڳ���
             RIMP.C17, -- װ����
             RIMP.C18, -- �����
             RIMP.C19, -- ����ˮ��
             RIMP.C20, -- ����ˮ��
             RIMP.C21, -- �ϼ�ˮ��
             RIMP.C25, -- ����ʱ��
             RIMP.C26, -- ����״̬
             RIMP.C30, -- ˮ��״��
             MR.MRID, -- ������ˮ
             MR.MRMID,
             V_FSLFLAG --��������븺ˮ����־
      ;
      EXIT WHEN C_READ%NOTFOUND OR C_READ%NOTFOUND IS NULL;

      V_COUNT  := 0;
      V_COUNT1 := 0;
      IF RIMP.C26 = '0' THEN
        --�ж��Ƿ�����������
        SELECT COUNT(*)
          INTO V_COUNT1
          FROM METERADDSLHIS T
         WHERE MASMRID = MR.MRID;
        IF V_COUNT1 > 0 THEN
          --������
          SP_ROLLBACKADDEDSL(MR.MRID, --������ˮ
                             V_RET --����ֵ
                             );
        END IF;
        --�ж���������
        SELECT COUNT(*)
          INTO V_COUNT
          FROM METERADDSL T
         WHERE MASMID = MR.MRMID;

        IF V_COUNT > 0 THEN
          --ȡδ������
          SP_FETCHADDINGSL(MR.MRID, --������ˮ
                           MR.MRMID, --ˮ���
                           V_TEMPNUM1, --�ɱ�ֹ��
                           V_TEMPNUM, --�±����
                           V_ADDSL, --����
                           V_DATE, --��������
                           V_TEMPSTR, --�ӵ�����
                           V_RET --����ֵ
                           );
          MR.MRADDSL := V_ADDSL; --����
          MR.MRSL    := TO_NUMBER(RIMP.C16) - V_TEMPNUM + V_ADDSL;
        ELSE
          MR.MRADDSL := 0; --����
          MR.MRSL    := TO_NUMBER(RIMP.C21);
        END IF;
        --CXC
        MR.MRMCODE := RIMP.C17;
        /*     mr.mraddsl         :=   0 ;  --����
        mr.mrsl           := to_number(rimp.c19 );*/
        MR.MRINPUTDATE := SYSDATE;
        MR.MRRDATE     := SYSDATE; --  to_date(rimp.c23,'yyyy-mm-dd')    ;
        MR.MRECODE     := TO_NUMBER(RIMP.C16);
        MR.MRECODECHAR := TRIM(TO_CHAR(MR.MRECODE));

        MR.MRREADOK := CASE
                         WHEN RIMP.C26 = '0' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        MR.MRDATASOURCE := '5';
        --������룬Ӫҵ��
        SELECT MRSCODE, MRSMFID
          INTO V_SL, V_MRSMFID
          FROM METERREAD
         WHERE MRMCODE = MR.MRMCODE;

        SP_MRSLCHECK(V_MRSMFID,
                     MR.MRMID,
                     V_SL,
                     MR.MRECODE,
                     MR.MRSL,
                     0,
                     MR.MRRDATE,
                     V_ERRFLAG,
                     V_IFMSG,
                     V_MSG,
                     V_EXAMINE,
                     V_SUBCOMMIT);

        /*  if v_errflag = 'N' and v_ifmsg   = 'Y' and v_examine = 'N' and v_subcommit='Y' then
          v_mrifsubmit      := 'N';
        else
            v_mrifsubmit      := 'Y';
        end if;*/

        /*v_mrifsubmit      := case when mr.mrecode-v_sl>0 then 'Y' else 'N' end  ;*/
        /*            if v_subcommit='Y' then
          v_subcommit:='N';
          else
            v_subcommit:='Y';
        end if;*/
        UPDATE METERREAD
           SET MRINPUTDATE  = MR.MRINPUTDATE,
               MRRDATE      = MR.MRRDATE,
               MRECODE      = MR.MRECODE,
               MRECODECHAR  = MR.MRECODECHAR,
               MRSL         = MR.MRSL,
               MRREADOK     = MR.MRREADOK,
               MRDATASOURCE = MR.MRDATASOURCE,
               MRADDSL      = MR.MRADDSL,
               MRIFSUBMIT   = V_FSLFLAG,
               MRINPUTPER   = P_OPER
         WHERE MRMCODE = MR.MRMCODE;
      END IF;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE MRID = MR.MRMID;
    END LOOP;
    CLOSE C_READ;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_READ%ISOPEN THEN
        CLOSE C_READ;
      END IF;
      RAISE_APPLICATION_ERROR(-20010,
                              '����ʧ�ܣ�' || '�жϿͻ�����:' || RIMP.C2 || ', ' ||
                              SQLERRM);
      ROLLBACK;
  END;

  -- ��������ݵ���
  --p_oper �������Ա
  --p_type ���ݵ��뷽ʽ
  --time 2010-03-22  by yf
  PROCEDURE SP_POSHANDIMP_YCB(P_OPER  IN VARCHAR2, --����Ա
                              P_TYPE  IN VARCHAR2, --���뷽ʽ
                              P_BFID  OUT VARCHAR2,
                              P_BFID1 OUT VARCHAR2) IS
    NUM          NUMBER;
    V_COUNT      NUMBER;
    V_COUNT1     NUMBER;
    ROWCNT       NUMBER;
    V_TEMPSL     NUMBER(10);
    V_TEMPNUM    NUMBER(10);
    V_ADDSL      NUMBER(10);
    V_TEMPSTR    VARCHAR2(10);
    V_RET        VARCHAR2(10);
    V_DATE       DATE;
    V_MAXCODE    NUMBER(10);
    MI           METERINFO%ROWTYPE;
    CI           CUSTINFO%ROWTYPE;
    MD           METERDOC%ROWTYPE;
    MR           METERREAD%ROWTYPE;
    RIMP         PBPARMTEMP%ROWTYPE;
    MRADSL       METERREADSLHIS%ROWTYPE;
    V_MRIFSUBMIT METERREAD.MRIFSUBMIT%TYPE;
    V_SL         NUMBER(10);
    V_OUTCODE    VARCHAR2(4000);
    V_BFID       VARCHAR2(4000);
    V_CODECOUNT  NUMBER;
    V_MRSCODE    NUMBER(10);
    V_FSLFLAG    VARCHAR2(10);
    CURSOR C_READ IS

      SELECT TRIM(TRUNC(C4)), -- ���ڳ���
             TRIM(NULL), -- װ����
             TRIM(NULL), -- �����
             TRIM(NULL), -- ����ˮ��
             TRIM(NULL), -- ����ˮ��
             TRIM(NULL), -- �ϼ�ˮ��
             TRIM(C5), -- ����ʱ��
             CASE
               WHEN TRIM(C4) IS NULL THEN
                '-1'
               WHEN TRIM(C4) - MRSCODE >= 0 THEN
                '1'
               ELSE
                '0'
             END, -- ����״̬              , -- ����״̬(����Զ����û��δ����)
             TRIM(NULL), -- ˮ��״��
             TRIM(NULL), -- ������ˮ
             MRMCODE,
             CASE
               WHEN (TO_NUMBER(FPARA(MRSMFID, 'MRBASECKSL')) <
                    TRIM(CASE
                            WHEN TO_NUMBER(C9) >= 0 THEN
                             TO_NUMBER(C9) - TO_NUMBER(C8)
                            ELSE
                             (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                          END) --ˮ��С��10������
                    AND TO_NUMBER(FPARA(MRSMFID, 'MRSLMSG')) * MRLASTSL <
                    TRIM(CASE
                                WHEN TO_NUMBER(C9) >= 0 THEN
                                 TO_NUMBER(C9) - TO_NUMBER(C8)
                                ELSE
                                 (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                              END) --ˮ����������2������
                    AND MRLASTSL > 1) --������ˮ�����ݲ��ж�
                    OR TO_NUMBER(C9) < 0 --����������� ��ϵͳ��Ҳ�����
                THEN
                'N'
               ELSE
                'Y'
             END --��������븺ˮ����־

        FROM PBPARMTEMP, METERREAD, METERINFO
       WHERE MRIFREC = 'N'
         AND MICODE = TRIM(C1)
         AND MIID = MRMID
         AND
            /*mrmonth=trim(c2)||'.'||trim(c3) and*/
             ((P_TYPE = 'N' AND MRREADOK = 'N') OR P_TYPE = 'Y')
         AND TO_NUMBER(TRIM(C4)) > TO_NUMBER(FSYSPARA('1103'));
    CURSOR C_BFID IS
      SELECT MRBFID, COUNT(*)
        FROM METERREAD
       WHERE MRBFID IN (V_OUTCODE)
         AND MRREADOK = 'N'
       GROUP BY MRBFID;
  BEGIN
    SELECT CONNSTR(BF)
      INTO P_BFID
      FROM (SELECT DISTINCT MIBFID BF
              FROM PBPARMTEMP, METERINFO, METERREAD
             WHERE TRIM(C1) = MICODE
               AND MIID = MRMID);
    OPEN C_READ;
    LOOP
      FETCH C_READ
        INTO RIMP.C16, -- ���ڳ���
             RIMP.C17, -- װ����
             RIMP.C18, -- �����
             RIMP.C19, -- ����ˮ��
             RIMP.C20, -- ����ˮ��
             RIMP.C21, -- �ϼ�ˮ��
             RIMP.C25, -- ����ʱ��
             RIMP.C26, -- ����״̬
             RIMP.C30, -- ˮ��״��
             MR.MRID, -- ������ˮ
             MR.MRMCODE,
             V_FSLFLAG;
      EXIT WHEN C_READ%NOTFOUND OR C_READ%NOTFOUND IS NULL;

      NULL;

      V_COUNT  := 0;
      V_COUNT1 := 0;
      --  if rimp.c26 <> '0' then
      --  -�ж��Ƿ�����������
      SELECT COUNT(*)
        INTO V_COUNT1
        FROM METERADDSLHIS, METERREAD
       WHERE MASMRID = MRID
         AND MRMCODE = MR.MRMCODE;
      IF V_COUNT1 > 0 THEN
        --������
        SP_ROLLBACKADDEDSL(MR.MRID, --������ˮ
                           V_RET --����ֵ
                           );
      END IF;
      --�ж���������
      SELECT COUNT(*)
        INTO V_COUNT
        FROM METERADDSL, METERREAD
       WHERE MASMID = MRMID
         AND MRMCODE = MR.MRMCODE;
      MR.MRECODE     := TO_NUMBER(RIMP.C16);
      MR.MRECODECHAR := TRIM(TO_CHAR(RIMP.C16));
      IF V_COUNT > 0 THEN
        --ȡδ������
        SP_FETCHADDINGSL(MR.MRID, --������ˮ
                         MR.MRMID, --ˮ���
                         V_TEMPNUM, --�ɱ�ֹ��
                         V_TEMPNUM, --�±����
                         V_ADDSL, --����
                         V_DATE, --��������
                         V_TEMPSTR, --�ӵ�����
                         V_RET --����ֵ
                         );
        MR.MRADDSL := V_ADDSL; --����
        MR.MRSL    := TO_NUMBER(RIMP.C16) - V_TEMPNUM + V_ADDSL;
      ELSE
        SELECT MRSCODE INTO V_SL FROM METERREAD WHERE MRMCODE = MR.MRMCODE;
        MR.MRADDSL := 0; --����
        MR.MRSL    := TO_NUMBER(RIMP.C16) - V_SL;
        --������ڳ���С�����ڳ��룬Ĭ��Ϊ0ˮ��
        IF RIMP.C26 = '0' THEN
          MR.MRECODE := V_SL;
          MR.MRSL    := 0;
        END IF;
      END IF;

      --if rimp.c26='1' then
      /*   select MRSCODE into v_sl from meterread where mrmid=mr.mrmid;
      mr.mraddsl         :=   0 ;  --����
      if rimp.c26<>'0' then
        mr.mrsl           := to_number(rimp.c16 )-v_sl;
        mr.mrecode        := to_number(rimp.c16 ) ;
        mr.mrecodechar    := trim(to_char(mr.mrecode))  ;
      else
        select max(mrscode ) into v_mrscode from meterread where  MRMID = mr.MRMID;
        mr.mrecode        := to_number(rimp.c16 ) ;
        mr.mrsl   :=  to_number(rimp.c16 )+  mr.mraddsl  ;
        mr.mrecodechar    := trim(to_char(rimp.c16))  ;
      end if;*/
      MR.MRINPUTDATE := SYSDATE;
      IF INSTR(RIMP.C25, ' ') = 0 THEN
        MR.MRRDATE := TO_DATE(SUBSTR(RIMP.C25, 1, 10), 'YYYY-MM-DD');
      ELSE
        MR.MRRDATE := TO_DATE(SUBSTR(RIMP.C25, 1, INSTR(RIMP.C25, ' ')),
                              'YYYY-MM-DD');
      END IF;
      --  to_date(rimp.c23,'yyyy-mm-dd')    ;

      MR.MRREADOK     := 'Y';
      MR.MRDATASOURCE := '5';
      V_MRIFSUBMIT    := 'Y';

      UPDATE METERREAD
         SET MRINPUTDATE  = MR.MRINPUTDATE,
             MRRDATE      = MR.MRRDATE,
             MRECODE      = MR.MRECODE,
             MRECODECHAR  = MR.MRECODECHAR,
             MRSL         = MR.MRSL,
             MRREADOK     = MR.MRREADOK,
             MRDATASOURCE = MR.MRDATASOURCE,
             MRADDSL      = MR.MRADDSL,
             MRIFSUBMIT   = V_FSLFLAG,
             MRINPUTPER   = P_OPER
       WHERE MRMCODE = MR.MRMCODE;

      --end if;
      --  end if;
      IF RIMP.C26 = '0' THEN
        UPDATE METERREAD SET MRFACE = '8' WHERE MRMCODE = MR.MRMCODE;
      ELSIF RIMP.C26 = '-1' THEN
        SELECT MRBFID
          INTO V_BFID
          FROM METERREAD
         WHERE MRMCODE = MR.MRMCODE;
        V_BFID := V_BFID || ',';
        IF INSTR(V_OUTCODE, V_BFID) = 0 OR V_OUTCODE IS NULL THEN
          V_OUTCODE := V_OUTCODE || V_BFID;
        END IF;
      END IF;
      --UPDATE METERREAD SET MROUTFLAG = 'N' WHERE mrid = mr.MRMID;
    END LOOP;
    CLOSE C_READ;

    IF V_OUTCODE IS NOT NULL THEN
      --�ж��Ƿ���δ¼��ˮ���
      V_OUTCODE := SUBSTR(V_OUTCODE, 1, LENGTH(V_OUTCODE) - 1);
      V_BFID    := '';
      OPEN C_BFID;
      LOOP
        FETCH C_BFID
          INTO V_BFID, V_CODECOUNT;
        EXIT WHEN C_BFID%NOTFOUND OR C_BFID%NOTFOUND IS NULL;
        P_BFID1 := '����:��' || V_BFID || '��' || V_CODECOUNT || '��δ¼��;' ||
                   CHR(10);
      END LOOP;
      CLOSE C_BFID;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF P_BFID = '' THEN
        RAISE_APPLICATION_ERROR(-20010, '����ʧ�ܣ������������');
      END IF;
      IF C_READ%ISOPEN THEN
        CLOSE C_READ;
      END IF;
      --raise_application_error(-20010,'����ʧ�ܣ�'||'�жϿͻ�����:'||rimp.c2||', '||sqlerrm);
      ROLLBACK;
  END;

  PROCEDURE SP_POSHANDIMP_TP800(P_OPER IN VARCHAR2, --����Ա

                                P_TYPE IN VARCHAR2 --���뷽ʽ
                                ) IS
    --c1 mrid
    --c14 ����
    --c15 ֹ��
    --c24 ������־
    --c18 ��������
    NUM          NUMBER;
    V_COUNT      NUMBER;
    V_COUNT1     NUMBER;
    ROWCNT       NUMBER;
    V_TEMPSL     NUMBER(10);
    V_TEMPNUM    NUMBER(10);
    V_TEMPNUM1   NUMBER(10);
    V_ADDSL      NUMBER(10);
    V_TEMPSTR    VARCHAR2(10);
    V_RET        VARCHAR2(10);
    V_DATE       DATE;
    V_MAXCODE    NUMBER(10);
    MI           METERINFO%ROWTYPE;
    CI           CUSTINFO%ROWTYPE;
    MD           METERDOC%ROWTYPE;
    MR           METERREAD%ROWTYPE;
    RIMP         PBPARMTEMP%ROWTYPE;
    MRADSL       METERREADSLHIS%ROWTYPE;
    V_MRIFSUBMIT METERREAD.MRIFSUBMIT%TYPE;
    V_MRSMFID    METERREAD.MRSMFID%TYPE;
    V_ERRFLAG    VARCHAR2(200);
    V_IFMSG      VARCHAR2(200);
    V_MSG        VARCHAR2(200);
    V_EXAMINE    VARCHAR2(200);
    V_SUBCOMMIT  VARCHAR2(200);
    V_SL         NUMBER(10);
    V_FSLFLAG    VARCHAR2(1);
    CURSOR C_READ IS

      SELECT CASE
               WHEN TO_NUMBER(C15) < 0 THEN
                0
               ELSE
                TO_NUMBER(C15)
             END, -- ���ڳ���(����ˮ��Ϊ��������Ϊ0)
             TRIM(C3), -- װ����
             TRIM(NULL), -- �����
             CASE
               WHEN TO_NUMBER(C16) < 0 THEN
                0
               ELSE
                TO_NUMBER(C16)
             END, -- ����ˮ��
             TRIM(NULL), -- ����ˮ��
             CASE
               WHEN TO_NUMBER(C16) < 0 THEN
                0
               ELSE
                TO_NUMBER(C16)
             END, -- �ϼ�ˮ��
             TRIM(TO_DATE(C18, 'yyyymmdd')), -- ����ʱ��
             TRIM(TRIM(C24)), -- ������־
             TRIM(NULL), -- ˮ��״��
             TRIM(C1), -- ������ˮ
             MRMID,
             NULL, --��������븺ˮ����־
             CASE
               WHEN TRIM(C21) = '0' THEN
                '1'
               ELSE
                TRIM(C21)
             END --ˮ����ϱ�־

        FROM PBPARMTEMP, METERREAD

       WHERE MRID = TRIM(C1)
         AND MRIFREC = 'N'
         AND ((P_TYPE = 'N' AND MRREADOK = 'N') OR P_TYPE = 'Y');
  BEGIN
    OPEN C_READ;
    LOOP
      FETCH C_READ
        INTO RIMP.C16, -- ���ڳ���
             RIMP.C17, -- װ����
             RIMP.C18, -- �����
             RIMP.C19, -- ����ˮ��
             RIMP.C20, -- ����ˮ��
             RIMP.C21, -- �ϼ�ˮ��
             RIMP.C25, -- ����ʱ��
             RIMP.C26, -- ����״̬
             RIMP.C30, -- ˮ��״��
             MR.MRID, -- ������ˮ
             MR.MRMID,
             V_FSLFLAG, --��������븺ˮ����־
             MR.MRFACE; -----�������ֵ
      EXIT WHEN C_READ%NOTFOUND OR C_READ%NOTFOUND IS NULL;

      V_COUNT  := 0;
      V_COUNT1 := 0;
      IF RIMP.C26 = 'Y' THEN
        --�ж��Ƿ�����������
        SELECT COUNT(*)
          INTO V_COUNT1
          FROM METERADDSLHIS T
         WHERE MASMRID = MR.MRID;
        IF V_COUNT1 > 0 THEN
          --������
          SP_ROLLBACKADDEDSL(MR.MRID, --������ˮ
                             V_RET --����ֵ
                             );
        END IF;
        --�ж���������
        SELECT COUNT(*)
          INTO V_COUNT
          FROM METERADDSL T
         WHERE MASMID = MR.MRMID;

        IF V_COUNT > 0 THEN
          --ȡδ������
          SP_FETCHADDINGSL(MR.MRID, --������ˮ
                           MR.MRMID, --ˮ���
                           V_TEMPNUM1, --�ɱ�ֹ��
                           V_TEMPNUM, --�±����
                           V_ADDSL, --����
                           V_DATE, --��������
                           V_TEMPSTR, --�ӵ�����
                           V_RET --����ֵ
                           );
          MR.MRADDSL := V_ADDSL; --����
          MR.MRSL    := TO_NUMBER(RIMP.C16) - V_TEMPNUM + V_ADDSL;
        ELSE
          MR.MRADDSL := 0; --����
          MR.MRSL    := TO_NUMBER(RIMP.C21);
        END IF;
        --CXC
        MR.MRMCODE := RIMP.C17;
        /*     mr.mraddsl         :=   0 ;  --����
        mr.mrsl           := to_number(rimp.c19 );*/
        MR.MRINPUTDATE := SYSDATE;
        MR.MRRDATE     := SYSDATE; --  to_date(rimp.c23,'yyyy-mm-dd')    ;
        MR.MRECODE     := TO_NUMBER(RIMP.C16);
        MR.MRECODECHAR := TRIM(TO_CHAR(MR.MRECODE));

        MR.MRREADOK := CASE
                         WHEN RIMP.C26 = '0' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        MR.MRDATASOURCE := '5';
        --������룬Ӫҵ��
        SELECT MRSCODE, MRSMFID
          INTO V_SL, V_MRSMFID
          FROM METERREAD
         WHERE MRID = MR.MRID;

        SP_MRSLCHECK(V_MRSMFID,
                     MR.MRMID,
                     V_SL,
                     MR.MRECODE,
                     MR.MRSL,
                     0,
                     MR.MRRDATE,
                     V_ERRFLAG,
                     V_IFMSG,
                     V_MSG,
                     V_EXAMINE,
                     V_SUBCOMMIT);

        /*  if v_errflag = 'N' and v_ifmsg   = 'Y' and v_examine = 'N' and v_subcommit='Y' then
          v_mrifsubmit      := 'N';
        else
            v_mrifsubmit      := 'Y';
        end if;*/

        /*v_mrifsubmit      := case when mr.mrecode-v_sl>0 then 'Y' else 'N' end  ;*/
        IF V_SUBCOMMIT = 'Y' THEN
          V_SUBCOMMIT := 'N';
        ELSE
          V_SUBCOMMIT := 'Y';
        END IF;
        UPDATE METERREAD
           SET MRINPUTDATE  = MR.MRINPUTDATE,
               MRRDATE      = MR.MRRDATE,
               MRECODE      = MR.MRECODE,
               MRECODECHAR  = MR.MRECODECHAR,
               MRSL         = MR.MRSL,
               MRREADOK     = 'Y',
               MRDATASOURCE = MR.MRDATASOURCE,
               MRADDSL      = MR.MRADDSL,
               MRIFSUBMIT   = V_SUBCOMMIT,
               MRINPUTPER   = P_OPER,
               MRFACE       = MR.MRFACE
         WHERE MRMCODE = MR.MRMCODE;
      END IF;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE MRID = MR.MRMID;
    END LOOP;
    CLOSE C_READ;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_READ%ISOPEN THEN
        CLOSE C_READ;
      END IF;
      RAISE_APPLICATION_ERROR(-20010,
                              '����ʧ�ܣ�' || '�жϿͻ�����:' || RIMP.C2 || ', ' ||
                              SQLERRM);
      ROLLBACK;
  END;

  PROCEDURE SP_POSHANDCREATE_TP900(P_SMFID   IN VARCHAR2,
                                   P_MONTH   IN VARCHAR2,
                                   P_BFIDSTR IN VARCHAR2,
                                   P_OPER    IN VARCHAR2,
                                   P_COMMIT  IN VARCHAR2) IS
    V_SQL VARCHAR2(4000);
    TYPE CUR IS REF CURSOR;
    C_PHMR  CUR;
    MR      METERREAD%ROWTYPE;
    V_BATCH VARCHAR2(10);
    MH      MACHINEIOLOG%ROWTYPE;
  BEGIN
    V_BATCH := FGETSEQUENCE('MACHINEIOLOG');

    MH.MILID    := V_BATCH; --�������������ˮ��
    MH.MILSMFID := P_SMFID; --Ӫ����˾
    --mh.MILMACHINETYPE        :=     ;--������ͺ�
    --mh.MILMACHINEID          :=     ;--��������
    MH.MILMONTH := P_MONTH; --�����·�
    --mh.MILOUTROWS            :=     ;--��������
    MH.MILOUTDATE     := SYSDATE; --��������
    MH.MILOUTOPERATOR := P_OPER; --���Ͳ���Ա
    --mh.MILINDATE             :=     ;--��������
    --mh.MILINOPERATOR         :=     ;--���ղ���Ա
    MH.MILREADROWS := 0; --��������
    MH.MILINORDER  := 0; --���ܴ���
    --mh.MILOPER               :=     ;--�����¼����Ա(����ʱȷ��)
    MH.MILGROUP := '1'; --����ģʽ

    INSERT INTO MACHINEIOLOG VALUES MH;

    V_SQL := ' update meterread set
MROUTID=''' || V_BATCH || ''' ,
MRINORDER=ROWNUM,
MROUTFLAG=''Y'',
MROUTDATE=TRUNC(sysdate)
where mrsmfid=''' || P_SMFID || ''' and mrmonth=''' || P_MONTH ||
             ''' and MRbfid in (''' || P_BFIDSTR || ''')
and MRREADOK=''N''
and MROUTFLAG=''N''';

    EXECUTE IMMEDIATE V_SQL;
    INSERT INTO PBPARMTEMP
      (C1, C2)
      SELECT MRID, MRMCODE
        FROM METERREAD
       WHERE MRSMFID = P_SMFID
         AND MRMONTH = P_MONTH
         AND MRBFID = P_BFIDSTR;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;
  FUNCTION FBDSL(P_MRID IN VARCHAR2) RETURN VARCHAR2 AS
    MR           METERREAD%ROWTYPE;
    MRSLMAX      NUMBER;
    V_MRBASECKSL NUMBER;
  BEGIN

    SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
    SELECT TO_NUMBER(FPARA(MR.MRSMFID, 'MRSLMAX')) INTO MRSLMAX FROM DUAL;
    SELECT TO_NUMBER(FPARA(MR.MRSMFID, 'MRBASECKSL'))
      INTO V_MRBASECKSL
      FROM DUAL;
    IF MR.MRLASTSL > 0 AND ((MR.MRSL > (MR.MRLASTSL * (1 + MRSLMAX))) OR
       (MR.MRSL < (MR.MRLASTSL * (1 - MRSLMAX)))) AND
       MR.MRSL > V_MRBASECKSL THEN
      RETURN 'N';
    ELSE
      RETURN 'Y';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'Y';
  END;
  
  --����ˮ������(���ξ�����ȥ��ͬ�ڣ�����ˮ��)   20140316 �޸�
 /*
 *VIEW_MR_BDMONTH
 * ���ξ���---SCJL
 *ȥ��ͬ��---QNTQ
 *����ˮ��--SYSL
 */
 FUNCTION FGETBDMONTHSL(P_MIID     IN VARCHAR2,
                        P_READDATE IN DATE,
                        P_TYPE     IN VARCHAR2) RETURN NUMBER IS
 
   V_SL    NUMBER(10);
   V_COUNT NUMBER(10);
   V_MONTH VARCHAR2(10);
   V_MRNUM NUMBER;
 
 BEGIN
   NULL;
 
   V_MONTH := TO_CHAR(P_READDATE, 'YYYY.MM');
   --������ڴ���գ�����0ˮ��
   IF V_MONTH IS NULL THEN
     RETURN 0;
   END IF;
 
   --���ξ���
   IF P_TYPE = 'SCJL' THEN
     V_COUNT := 3;
     --���ϴ����
     SELECT NVL(MRNUM, 1)
       INTO V_MRNUM
       FROM VIEW_MR_BDMONTH
      WHERE MRMID = P_MIID
        AND MRMONTH = V_MONTH;
     --��ǰ����ˮ����
     SELECT NVL(SUM(MRSL), 0)
       INTO V_SL
       FROM VIEW_MR_BDMONTH
      WHERE MRMID = P_MIID
        AND MRNUM >= V_MRNUM
        AND MRNUM <= V_MRNUM + 2;
   END IF;
 
   --ȥ��ͬ��
   IF P_TYPE = 'QNTQ' THEN
     V_COUNT := 1;
     SELECT NVL(MRSL, 0)
       INTO V_SL
       FROM VIEW_MR_BDMONTH
      WHERE MRMID = P_MIID
        AND MRMONTH = TO_CHAR(ADD_MONTHS(CURRENTDATE, -12), 'YYYY.MM');
   END IF;
 
   --����ˮ��
   IF P_TYPE = 'SYSL' THEN
     V_COUNT := 1;
     SELECT NVL(MRSL, 0)
       INTO V_SL
       FROM VIEW_MR_BDMONTH
      WHERE MRMID = P_MIID
        AND MRMONTH = V_MONTH;
   END IF;
 
   IF V_COUNT = 0 THEN
     RETURN 0;
   END IF;
   RETURN TRUNC(V_SL / V_COUNT);
 EXCEPTION
   WHEN OTHERS THEN
     RETURN 0;
 END;

  
 --����ˮ������(���¾�����ȥ��ͬ�ڣ��ϴ�)  20140316 ���ϣ�����fgetbdmonthsl
 function fgetavgmonthsl(P_MIID   IN VARCHAR2,
                                   P_READDATE1   IN DATE,
                                   P_READDATE2 IN DATE) RETURN NUMBER IS
 V_SL     NUMBER(10);
 V_COUNT  NUMBER(10);
 V_MONTH1 VARCHAR2(10);
 V_MONTH2 VARCHAR2(10);
 BEGIN
    V_MONTH1 := TO_CHAR(P_READDATE1,'YYYY.MM') ;
    V_MONTH2 := TO_CHAR(P_READDATE2,'YYYY.MM') ;
    --������ڴ���գ�����0ˮ��
    IF V_MONTH1 IS NULL OR V_MONTH2 IS NULL THEN
       RETURN 0;
    END IF;
    
    --��ȡʱ���ˮ������
    SELECT SUM(MRSL),COUNT(*) INTO V_SL,V_COUNT 
    FROM METERREADHIS
    WHERE MRMID=P_MIID AND
          MRREADOK='Y' AND
          MRIFTRANS='N' AND
          MRMONTH>=V_MONTH1 AND
          MRMONTH<=V_MONTH2;
    
    IF V_COUNT=0 THEN
       RETURN 0;
    END IF;     
    RETURN  TRUNC(V_SL/V_COUNT);
 EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;    
  
  --ˮ��������飨��������
PROCEDURE SP_MRSLCHECK_HRB(P_MRMID     IN VARCHAR2,
                           P_MRSL      IN NUMBER,
                           O_SUBCOMMIT OUT VARCHAR2) AS
  V_THREEAVGSL  NUMBER(12, 2);
  V_MRSL        NUMBER(12, 2);
  V_MRSLCHECK   VARCHAR2(10); --����ˮ��������ʾ
  V_MRSLSUBMIT  VARCHAR2(10); --����ˮ����������
  V_MRBASECKSL  NUMBER(10); --����У�����
  V_TYPE        VARCHAR2(10);
  V_SCALE_H     NUMBER(10);
  V_SCALE_L     NUMBER(10);
  V_USE_H       NUMBER(10);
  V_USE_L       NUMBER(10);
  V_TOTAL_H     NUMBER(10);
  V_TOTAL_L     NUMBER(10);
  V_CODE        VARCHAR2(10); --�ͻ�����
  V_PFID        VARCHAR2(10); --��ˮ���
  V_THREEMONAVG NUMBER(10);
BEGIN
  O_SUBCOMMIT := 'Y';
  -- V_MRSLCHECK  := FPARA(P_SMFID, 'MRSLCHECK');
  -- V_MRSLSUBMIT := FPARA(P_SMFID, 'MRSLSUBMIT');
  -- V_MRBASECKSL := TO_NUMBER(FPARA(P_SMFID, 'MRBASECKSL'));
  --��ѯ���ôγ���Ŀͻ�����   
  SELECT MRCID INTO V_CODE FROM METERREAD WHERE MRID = P_MRMID;
  --��ø��û�ǰ���¾���
  SELECT MRTHREESL INTO V_THREEMONAVG FROM METERREAD WHERE MRID = P_MRMID;
  --��ø��û�����ˮ���
  SELECT MIPFID INTO V_PFID FROM METERINFO WHERE MICID = V_CODE;
  begin 
    --�������ˮ���Ĳ�������
    SELECT USETYPE, SCALE_H, SCALE_L, USE_H, USE_L, TOTAL_H, TOTAL_L
      INTO V_TYPE,
           V_SCALE_H, --�����ޱ��� 
           V_SCALE_L, --�����ޱ��� 
           V_USE_H, --������������� 
           V_USE_L, --������������� 
           V_TOTAL_H, --�����޾������� 
           V_TOTAL_L --�����޾������� 
      FROM CHK_METERREAD
     WHERE USETYPE = V_PFID;
   exception 
      when others then
           V_TYPE:='';
           V_SCALE_H:=0; --�����ޱ��� 
           V_SCALE_L:=0; --�����ޱ��� 
           V_USE_H:=0; --������������� 
           V_USE_L:=0; --������������� 
           V_TOTAL_H:=0; --�����޾������� 
           V_TOTAL_L:=0; --�����޾������� 
  end ;
  IF P_MRSL IS NOT NULL THEN
  
    --����������� ��Ϊ��
    IF V_SCALE_H <> 0 AND V_SCALE_L <> 0 THEN
      IF P_MRSL > V_THREEMONAVG * (1 + V_SCALE_H * 0.01) OR
         P_MRSL < V_THREEMONAVG * (1 - V_SCALE_L * 0.01) THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;
  
    --���������� ���Ʋ�Ϊ��
    IF V_USE_H <> 0 AND V_USE_L <> 0 THEN
      IF P_MRSL > V_THREEMONAVG + V_USE_H OR
         P_MRSL < V_THREEMONAVG - V_USE_L THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;
  
    --���������� ���Ʋ�Ϊ��
    IF V_TOTAL_H <> 0 AND V_TOTAL_L <> 0 THEN
      IF P_MRSL > V_TOTAL_H OR P_MRSL < V_TOTAL_L THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;
  
  END IF;

END;
                       
END;
/

