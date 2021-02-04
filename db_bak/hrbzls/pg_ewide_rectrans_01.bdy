CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_RECTRANS_01" IS

  �̶�����־   CHAR(1);
  �̶�������ֵ NUMBER(12, 2);
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2) IS
  BEGIN

    --���鷣���շ�
    IF P_DJLB IN ('O', 'T', '6', 'N','13','14','21','23') THEN
      SP_RECTRANS102(P_BILLNO, P_PERSON);
    ELSIF P_DJLB = 'G' THEN
      -- raise_application_error(errcode, p_billno || '->1 ��Ч�ĵ������');
      SP_RECCZ(P_BILLNO, P_PERSON, '', 'Y');  --Ӧ�ճ���
/*    ELSIF P_DJLB = '5' THEN
      SP_�����˷�(P_BILLNO, P_PERSON, '', 'Y');*/
    ELSIF P_DJLB = '5' THEN
        SP_�����˷�NEW(P_BILLNO, P_PERSON, 'Y');
    ELSIF P_DJLB = 'S' THEN
      SP_�����(P_BILLNO, P_PERSON, '', 'Y');
    ELSIF P_DJLB = 'V' THEN
      SP_PAIDRECBACK(P_BILLNO, P_PERSON);
    ELSIF P_DJLB IN ('u','v') THEN
          --��ʱ��ˮˮ������
          SP_RECTRANS104(P_BILLNO, P_PERSON,P_DJLB);
    ELSIF P_DJLB = '12' THEN
          --ʵ�ճ���
          SP_PAIDBAK(P_BILLNO, P_PERSON);
    ELSIF P_DJLB = '3' THEN
          SP_���˵�(P_BILLNO, P_PERSON,P_DJLB);
    elsif P_DJLB = '36' OR P_DJLB = '39' THEN  --36Ԥ������˷�����  39Ԥ�������˷�����
           SP_Ԥ���˷�(P_BILLNO, P_PERSON);
       --  sp_Ԥ�����(P_BILLNO, P_PERSON);
    END IF;
  END;
  --׷���շ� V --����ԭ�� ׷���շ�
  PROCEDURE SP_RECTRANS102(P_NO IN VARCHAR2, P_PER IN VARCHAR2) AS
    CURSOR C_DT IS
      SELECT * FROM RECTRANSDT WHERE RTDNO = P_NO FOR UPDATE;

    CURSOR C_CUSTINFO(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;

    CURSOR C_METERINFO(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID FOR UPDATE NOWAIT;

    CURSOR C_METERDOC(VMID IN VARCHAR2) IS
      SELECT * FROM METERDOC WHERE MDMID = VMID;

    CURSOR C_METERACCOUNT(VMID IN VARCHAR2) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMID;

    CURSOR C_BOOKFRAME(VBFID IN VARCHAR2) IS
      SELECT * FROM BOOKFRAME WHERE BFID = VBFID;

    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;

    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;

    RTH    RECTRANSHD%ROWTYPE;
    RTD    RECTRANSDT%ROWTYPE;
    CI     CUSTINFO%ROWTYPE;
    MI     METERINFO%ROWTYPE;
    BF     BOOKFRAME%ROWTYPE;
    MD     METERDOC%ROWTYPE;
    MA     METERACCOUNT%ROWTYPE;
    RL     RECLIST%ROWTYPE;
    RL1    RECLIST%ROWTYPE;
    RD     RECDETAIL%ROWTYPE;
    P_PIID VARCHAR2(4000);

    V_RLFZCOUNT NUMBER(10);
    V_RLFIRST   NUMBER(10);
    V_PIGROUP   PRICEITEM.PIGROUP%TYPE;
    RDTAB       PG_EWIDE_METERREAD_01.RD_TABLE;
    PI          PRICEITEM%ROWTYPE;
    MR          METERREAD%ROWTYPE;
    V_PV        NUMBER(10);
    v_count     number :=0;
    v_temp      number := 0;
  BEGIN

    BEGIN

      SELECT * INTO RTH FROM RECTRANSHD WHERE RTHNO = P_NO;
      --yujia  2012-03-20
      �̶�����־   := FPARA(RTH.RTHSMFID, 'GDJEFLAG');
      �̶�������ֵ := FPARA(RTH.RTHSMFID, 'GDJEZ');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ�����!');
    END;
    --20160622 �����ж� ��ĩ���һ�첻�ܽ���׷�������飬���ɣ�����Ӧ�գ����������·ݿ���
    if trunc(sysdate) = last_day(trunc(sysdate,'MONTH')) and rth.rthlb in('O','13','21') THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '��ǰΪ�����գ���������ҵ��');
    end if;
    IF RTH.RTHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���������');
    END IF;
    IF RTH.RTHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '������ȡ��');
    END IF;
    if RTH.rthlb='13' then
      select count(*) into v_count from meterread where mrcid=RTH.RTHCID
      and MRREADOK='Y' AND NvL(MRIFREC,'N')='N'; -- by ralph 20150213 ���Ӳ������ʱ���Ƿ񳭼�δ��ѵ��ж�
      IF v_count>0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '���û������ѳ���δ��Ѽ�¼�������Բ������!');
      end if;
    end if;
    --
    OPEN C_CUSTINFO(RTH.RTHCID);
    FETCH C_CUSTINFO
      INTO CI;
    IF C_CUSTINFO%NOTFOUND OR C_CUSTINFO%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�޴��û�');
    END IF;
    CLOSE C_CUSTINFO;

    OPEN C_METERINFO(RTH.RTHMID);
    FETCH C_METERINFO
      INTO MI;
    IF C_METERINFO%NOTFOUND OR C_METERINFO%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�޴�ˮ��');
    END IF;

    OPEN C_METERDOC(RTH.RTHMID);
    FETCH C_METERDOC
      INTO MD;
    IF C_METERDOC%NOTFOUND OR C_METERDOC%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�޴�ˮ����');
    END IF;
    CLOSE C_METERDOC;

    OPEN C_METERACCOUNT(RTH.RTHMID);
    FETCH C_METERACCOUNT
      INTO MA;
    IF C_METERACCOUNT%NOTFOUND OR C_METERACCOUNT%NOTFOUND IS NULL THEN
      --raise_application_error(errcode,'�޴�ˮ������');
      NULL;
    END IF;
    CLOSE C_METERACCOUNT;

    OPEN C_BOOKFRAME(RTH.RTHBFID);
    FETCH C_BOOKFRAME
      INTO BF;
    IF C_BOOKFRAME%NOTFOUND OR C_BOOKFRAME%NOTFOUND IS NULL THEN
      --raise_application_error(errcode,'�޴˱��');
      NULL;
    END IF;
    CLOSE C_BOOKFRAME;

    --byj add 2016.4.5 �����(���鲹�� ���� ׷��),Ҫ�ж��Ƿ���δ���� ������ ����ˮ���ʱ�������������˷ѡ��������� ��Ԥ���˷ѹ���  ----------
    if RTH.rthlb in ('21','13','O' ) then
       --�ж��Ƿ���δ������ˮ���ʱ������
       select count(*) into v_count
         from custchangehd hd,
              custchangedt dt
        where hd.cchno = dt.ccdno and
              hd.cchlb = 'E' and
              dt.ciid = mi.micid and
              hd.CCHSHFLAG = 'N';
       if v_count > 0 then
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���δ���ġ�ˮ�۱��������,���ܽ������!');
       end if;
       --�ж��Ƿ��й��ϻ���
       if mi.mistatus = '24' then
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���δ���ġ����ϻ�������,���ܽ������!');
       elsif mi.mistatus = '35' then
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���δ���ġ����ڻ�������,���ܽ������!');
       elsif mi.mistatus = '36' then
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���δ���ġ�Ԥ���˷ѡ�����,���ܽ������!');
       elsif mi.mistatus = '39' then
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���δ���ġ�Ԥ�泷���˷ѡ�����,���ܽ������!');
       elsif mi.mistatus = '19' then
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���δ���ġ�����������,���ܽ������!');
       end if;
       --����޸�ˮ��ָ��,Ҫ�ж����ʱ��ָ���Ƿ��뽨������ʱһ��
       if rth.rthecodeflag = 'Y' then
          if rth.rthscode <> mi.mircode then
             RAISE_APPLICATION_ERROR(ERRCODE, '��ˮ���ֹ���Թ���������Ѿ����,��˲�!');
          end if;
          /*�������ʱ,��������г���ƻ����ϴ���δ���,��ʾ�������!!! (����������ʱ) */
          if RTH.rthlb = '21' /*���鲹��*/ then
             begin
               select 1 into v_temp
                 from meterread mr
                where mr.mrmid = mi.miid and
                      mr.MRREADOK in ('X','Y') and
                      mr.mrifrec = 'N' and
                      rownum < 2;
             exception
               when no_data_found then
                 v_temp := 0;
             end;
             if v_temp > 1 then
                RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ���š�' || mi.micid ||  '���������г��������ϴ���δ��ѵļ�¼,��˲�!');
             end if;
          end if;
       end if;
    end if;
    --end!!!

    -----��ͷ����ʼ

    -- Ԥ�ȸ�ֵ
    RTH.RTHSHPER  := P_PER;
    RTH.RTHSHDATE := CURRENTDATE;

    /*******����׷����Ϣ*****/
    IF RTH.IFREC = 'Y' THEN

      --�Ƿ�����ѹ���(���߿���ΪӪҵ��)
      --���볭���
      SP_INSERTMR(RTH, TRIM(RTH.RTHLB), MI, RL.RLMRID);
       --zhw20160329----------start
      IF RTH.RTHLB = 'O' THEN
         RTH.RTHLB := RTH.RTHLB || NVL(TRIM(RTH.IFSLMK),'N');
      END IF;
      ------------------------end
      IF RL.RLMRID IS NOT NULL THEN
        SELECT * INTO MR FROM METERREAD WHERE MRID = RL.RLMRID;
        IF RTH.IFRECHIS = 'Y' THEN
          IF RTH.PRICEMONTH IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '�۸��·ݲ���Ϊ�գ�');
          END IF;
          SELECT COUNT(*)
            INTO V_PV
            FROM PRICEVER
           WHERE (TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm') >= SMONTH AND
                 TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm') <= EMONTH);
          IF V_PV = 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '���·�ˮ��δ�鵵��');
          END IF;
          --�Ƿ���ʷˮ�����(ѡ��鵵�۸�汾)
          PG_EWIDE_METERREAD_01.CALCULATE(MR,
                                          TRIM(RTH.RTHLB),
                                          TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm'));
          INSERT INTO METERREADHIS
            SELECT * FROM METERREAD WHERE MRID = RL.RLMRID;
          DELETE METERREAD WHERE MRID = RL.RLMRID;
          SELECT * INTO RL FROM RECLIST WHERE RLMRID = RL.RLMRID;
          /*   UPDATE RECLIST RL
            SET RL.RLMEMO = RTH.RTHMEMO
          WHERE RL.RLID = RL.RLID;*/
        ELSE
          PG_EWIDE_METERREAD_01.CALCULATE(MR, TRIM(RTH.RTHLB), '0000.00');
          INSERT INTO METERREADHIS
            SELECT * FROM METERREAD WHERE MRID = RL.RLMRID;

          DELETE METERREAD WHERE MRID = RL.RLMRID;
          SELECT * INTO RL FROM RECLIST WHERE RLMRID = RL.RLMRID;
          /*   UPDATE RECLIST RL
            SET RL.RLMEMO = RTH.RTHMEMO
          WHERE RL.RLID = RL.RLID;*/
        END IF;
        IF RTH.RTHECODEFLAG = 'N' THEN
          UPDATE METERINFO
             SET MIRCODE = RTH.RTHSCODE, MIRCODECHAR = RTH.RTHSCODECHAR
          --miface     = mr.mrface,
           WHERE CURRENT OF C_METERINFO;

        END IF;
      END IF;
    ELSE
      --������ʷ��������Ϣ
      SP_INSERTMRHIS(RTH, TRIM(RTH.RTHLB), MI, RL.RLMRID);
      RL.RLID        := FGETSEQUENCE('RECLIST');
      RL.RLSMFID     := MI.MISMFID;
      RL.RLMONTH     := TOOLS.FGETRECMONTH(MI.MISMFID);
      RL.RLDATE      := TOOLS.FGETRECDATE(MI.MISMFID);
      RL.RLCID       := RTH.RTHCID;
      RL.RLMID       := RTH.RTHMID;
      RL.RLMSMFID    := MI.MISMFID;
      RL.RLCSMFID    := CI.CISMFID;
      RL.RLCCODE     := RTH.RTHCCODE;
      RL.RLCHARGEPER := RTH.RTHCPER;
      RL.RLCPID      := CI.CIPID;
      RL.RLCCLASS    := CI.CICLASS;
      RL.RLCFLAG     := CI.CIFLAG;
      RL.RLUSENUM    := RTH.RTHUSENUM;
      RL.RLCNAME     := RTH.RTHMNAME;
      --rl.rlcname2      := ;
      RL.RLCADR        := RTH.RTHCADR;
      RL.RLMADR        := RTH.RTHMADR;
      if  RL.RLCADR <>RL.RLMADR  then
        RL.RLCADR        :=  RL.RLMADR; --���ɡ����顢����ֱ��ȡǰ̨��ĵ�ַ
      end if;
      RL.RLCSTATUS     := CI.CISTATUS;
      RL.RLMTEL        := CI.CIMTEL;
      RL.RLTEL         := CI.CITEL1;
      RL.RLBANKID      := MA.MABANKID;
      RL.RLTSBANKID    := MA.MATSBANKID;
      RL.RLACCOUNTNO   := MA.MAACCOUNTNO;
      RL.RLACCOUNTNAME := MA.MAACCOUNTNAME;
      RL.RLIFTAX       := MI.MIIFTAX;
      RL.RLTAXNO       := MI.MITAXNO;
      RL.RLIFINV       := CI.CIIFINV; --��Ʊ��־
      RL.RLMCODE       := RTH.RTHMCODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := NULL; --???
      RL.RLBFID        := RTH.RTHBFID; --
      RL.RLPRDATE      := RTH.RTHPRDATE; --
      RL.RLRDATE       := RTH.RTHRDATE;
      RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '08',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   1),
                                        'yyyymm') || '08',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);
      RL.RLCALIBER     := MD.MDCALIBER;
      RL.RLRTID        := RTH.RTHRTID;
      RL.RLMSTATUS     := MI.MISTATUS;
      RL.RLMTYPE       := RTH.RTHMTYPE;
      RL.RLMNO         := MD.MDNO;
      /*     \*    rl.rlscode       := rth.rthscode;
      rl.rlecode       := rth.rthecode;*\*/

      RL.RLSCODE := NVL(RTH.RTHSCODECHAR, RTH.RTHSCODE);
      RL.RLECODE := NVL(RTH.RTHECODECHAR, RTH.RTHECODE);

      RL.RLREADSL       := RTH.RTHREADSL;
      RL.RLINVMEMO      := RTH.RTHINVMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      RL.RLTRANS        := TRIM(RTH.RTHLB); --�����Ӧ������ID�뵥������ɺ���ͬ
      RL.RLCD           := PG_EWIDE_METERREAD_01.DEBIT;
      RL.RLYSCHARGETYPE := RTH.RTHCHARGETYPE;
      RL.RLSL           := RTH.RTHSL; --Ӧ��ˮ��ˮ������rlsl = rlreadsl + rladdsl��
      RL.RLJE           := RTH.RTHJE; --������������,�ȳ�ʼ��
      RL.RLADDSL        := RTH.RTHADDSL;
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDJE       := 0;
      RL.RLPAIDDATE     := NULL;
      RL.RLPAIDPER      := NULL;
      --rl.rlmrid        := rth.rthmrid;
      RL.RLMEMO      := RTH.RTHMEMO;
      RL.RLZNJ       := 0;
      RL.RLLB        := RTH.RTHMLB;
      RL.RLPFID      := RTH.RTHPFID;
      RL.RLDATETIME  := SYSDATE;
      RL.RLPRIMCODE  := FGETMCODE(MI.MIPRIID);
      RL.RLPRIFLAG   := MI.MIPRIFLAG;
      RL.RLRPER      := BF.BFRPER;
      RL.RLSAFID     := MI.MISAFID;
      RL.RLSCODECHAR := RTH.RTHSCODECHAR;
      RL.RLECODECHAR := RTH.RTHECODECHAR;
      RL.RLILID      := NULL; --��Ʊ��ˮ��
      RL.RLMIUIID    := MI.MIUIID; --��λ����
      RL.RLGROUP     := 1; --Ӧ���ʷ���

      ---��ṹ�޸ĺ����������
      RL.RLPID          := NULL; --ʵ����ˮ����payment.pid��Ӧ��
      RL.RLPBATCH       := NULL; --�ɷѽ������Σ���payment.pbatch��Ӧ��
      RL.RLSAVINGQC     := 0; --�ڳ�Ԥ�棨����ʱ������
      RL.RLSAVINGBQ     := 0; --����Ԥ�淢��������ʱ������
      RL.RLSAVINGQM     := 0; --��ĩԤ�棨����ʱ������
      RL.RLREVERSEFLAG  := 'N'; --  ������־��nΪ������yΪ������
      RL.RLBADFLAG      := 'N'; --���ʱ�־��y :�����ʣ�o:�����������У�n:�����ʣ�
      RL.RLZNJREDUCFLAG := 'N'; --���ɽ�����־,δ����ʱΪn������ʱ���ɽ�ֱ�Ӽ��㣻�����Ϊy,����ʱ���ɽ�ֱ��ȡrlznj
      RL.RLMISTID       := MI.MISTID; --��ҵ����
      RL.RLMINAME       := MI.MINAME; --Ʊ������
      RL.RLSXF          := 0; --������
      RL.RLMIFACE2      := MI.MIFACE2; --��������
      RL.RLMIFACE3      := MI.MIFACE3; --�ǳ�����
      RL.RLMIFACE4      := MI.MIFACE4; --����ʩ˵��
      RL.RLMIIFCKF      := MI.MIIFCHK; --�����ѻ���
      RL.RLMIGPS        := MI.MIGPS; --�Ƿ��Ʊ
      RL.RLMIQFH        := MI.MIQFH; --Ǧ���
      RL.RLMIBOX        := MI.MIBOX; --����ˮ�ۣ���ֵ˰ˮ�ۣ���������
      RL.RLMINAME2      := MI.MINAME2; --��������(С��������������
      RL.RLMISEQNO      := MI.MISEQNO; --���ţ���ʼ��ʱ���+��ţ�
      RL.RLSCRRLID      := RL.RLID; --ԭӦ����ˮ
      RL.RLSCRRLTRANS   := RL.RLTRANS; --ԭӦ������
      RL.RLSCRRLMONTH   := RL.RLMONTH; --ԭӦ���·�
      RL.RLSCRRLDATE    := RL.RLDATE; --ԭӦ��������
      RL.RLCOLUMN5      := RL.RLDATE; --�ϴ�Ӧ��������
      RL.RLCOLUMN9      := RL.RLID; --�ϴ�Ӧ������ˮ
      RL.RLCOLUMN10     := RL.RLMONTH; --�ϴ�Ӧ�����·�
      RL.RLCOLUMN11     := RL.RLTRANS; --�ϴ�Ӧ��������
      BEGIN
        SELECT NVL(SUM(NVL(RLJE, 0) - NVL(RLPAIDJE, 0)), 0)
          INTO RL.RLPRIORJE
          FROM RECLIST T
         WHERE T.RLREVERSEFLAG = 'Y'
           AND T.RLPAIDFLAG = 'N'
           AND RLJE > 0
           AND RLMID = MI.MIID;
      EXCEPTION
        WHEN OTHERS THEN
          RL.RLPRIORJE := 0; --���֮ǰǷ��
      END;
      IF RL.RLPRIORJE > 0 THEN
        RL.RLMISAVING := 0;
      ELSE
        RL.RLMISAVING := MI.MISAVING; --���ʱԤ��
      END IF;

      RL.RLMICOMMUNITY   := MI.MICOMMUNITY; --С��
      RL.RLMIREMOTENO    := MI.MIREMOTENO; --Զ�����
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --Զ��hub��
      RL.RLMIEMAIL       := MI.MIEMAIL; --�����ʼ�
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --�����ֶ�1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --�����ֶ�2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --�����ֶ�3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --�����ֶ�3
     if rl.rltrans = '23' then
         --Ӫ��������ʱRLMICOLUMN4����λ��¼�Ƿ����´���ȱ�־
         --�������ڴ�ӡ��Ʊ�жϱ�ʾ���Ƿ��ӡ ΪYʱ�Ŵ�ӡ
        RL.RLMICOLUMN4     :=  RTH.RTHECODEFLAG ;
     end if ;
      --����Ӧ��
      --insert into reclist values rl;
      --ֹ�봦��
      IF RTH.RTHECODEFLAG = 'Y' THEN
        UPDATE METERINFO
           SET MIRCODE = RTH.RTHECODE,

               MIRCODECHAR = RTH.RTHECODECHAR,
               MIRECDATE   = RTH.RTHRDATE,
               MIRECSL     = RTH.RTHSL, --ȡ����ˮ��
               --miface     = mr.mrface,
               MINEWFLAG = 'N'
         WHERE CURRENT OF C_METERINFO;

      END IF;
      -----��ͷ�������
      ---------------------------------------------------------
      -----���崦��ʼ
      OPEN C_DT;
      LOOP
        FETCH C_DT
          INTO RTD;
        EXIT WHEN C_DT%NOTFOUND OR C_DT%NOTFOUND IS NULL;
        RD.RDID        := RL.RLID;
        RD.RDPMDID     := RTD.RTDPMDID;
        RD.RDPIID      := RTD.RTDPIID;
        P_PIID := (CASE
                    WHEN P_PIID IS NULL THEN
                     ''
                    ELSE
                     P_PIID || '/'
                  END) || RTD.RTDPIID;
        RD.RDPFID      := RTD.RTDPFID;
        RD.RDPSCID     := RTD.RTDPSCID;
        RD.RDCLASS     := 0; --�ݲ�֧�ֽ���Ʒ�
        RD.RDYSDJ      := RTD.RTDYSDJ;
        RD.RDYSSL      := RTD.RTDYSSL;
        RD.RDYSJE      := RTD.RTDYSJE;
        RD.RDDJ        := RTD.RTDDJ;
        RD.RDSL        := RTD.RTDSL;
        RD.RDJE        := RTD.RTDJE;
        RD.RDADJDJ     := RTD.RTDADJDJ;
        RD.RDADJSL     := RTD.RTDADJSL;
        RD.RDADJJE     := RTD.RTDADJJE;
        RD.RDMETHOD    := 'dj1'; --ֻ֧�̶ֹ�����
        RD.RDPAIDFLAG  := 'N';
        RD.RDPAIDDATE  := NULL;
        RD.RDPAIDMONTH := NULL;
        RD.RDPAIDPER   := NULL;
        RD.RDPMDSCALE  := RTD.RTDSCALE;
        RD.RDILID      := NULL;
        RD.RDZNJ       := 0;
        RD.RDMEMO      := NULL;

        RD.RDMSMFID     := RL.RLMSMFID; --Ӫ����˾
        RD.RDMONTH      := RL.RLMONTH; --�����·�
        RD.RDMID        := RL.RLMID; --ˮ����
        RD.RDPMDTYPE    := '01'; --������
        RD.RDPMDCOLUMN1 := NULL; --�����ֶ�1
        RD.RDPMDCOLUMN2 := NULL; --�����ֶ�2
        RD.RDPMDCOLUMN3 := NULL; --�����ֶ�3

        /*     \*insert into recdetail values rd;*\*/

        IF RDTAB IS NULL THEN
          RDTAB := PG_EWIDE_METERREAD_01.RD_TABLE(RD);
        ELSE
          RDTAB.EXTEND;
          RDTAB(RDTAB.LAST) := RD;
        END IF;

      END LOOP;

      IF FSYSPARA('1104') = 'Y' THEN
        --�ּ�������
        V_RLFIRST := 0;
        OPEN C_PICOUNT;
        LOOP
          FETCH C_PICOUNT
            INTO V_PIGROUP;
          EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;
          IF V_RLFIRST = 0 THEN
            V_RLFIRST := V_RLFIRST + 1;
          ELSE
            RL1.RLID  := FGETSEQUENCE('RECLIST');
            V_RLFIRST := V_RLFIRST + 1;
          END IF;
          RL1.RLJE := 0;
          RL1.RLSL := 0;

          IF RL1.RLGROUP = 1 OR RL1.RLGROUP = 3 THEN
            RL1.RLMIEMAILFLAG := 'S'; --��Ʊ��ӡ
          ELSE
            RL1.RLMIEMAILFLAG := 'W';
          END IF;

          V_RLFZCOUNT := 0;
          OPEN C_PI(V_PIGROUP);
          LOOP
            FETCH C_PI
              INTO PI;
            EXIT WHEN C_PI%NOTFOUND OR C_PI%NOTFOUND IS NULL;

            FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
              IF RDTAB(I).RDPIID = PI.PIID THEN
                V_RLFZCOUNT := V_RLFZCOUNT + 1;
                RDTAB(I).RDID := RL1.RLID;
                RL1.RLJE := RL1.RLJE + RDTAB(I).RDJE;
                IF RDTAB(I).RDPIID = '01' OR RDTAB(I).RDPIID = '04' THEN
                  RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;
                END IF;
                INSERT INTO RECDETAIL VALUES RDTAB (I);
              END IF;
            END LOOP;

          END LOOP;
          CLOSE C_PI;
          IF V_RLFZCOUNT > 0 THEN
            INSERT INTO RECLIST VALUES RL1;
          END IF;
        END LOOP;
        CLOSE C_PICOUNT;
      ELSE

        --���� ���������  �̶�������ֵ
        IF �̶�����־ = 'Y' AND RL.RLJE <= �̶�������ֵ THEN
          RL.RLJE := ROUND(�̶�������ֵ);
        END IF;

        PG_EWIDE_METERREAD_01.INSRD(RDTAB);
        SELECT SUM(RDJE) INTO RL.RLJE FROM RECDETAIL WHERE RDID = RL.RLID;
        INSERT INTO RECLIST VALUES RL;

      END IF;

      CLOSE C_DT;
      -----���崦�����
    END IF;
    UPDATE RECTRANSHD
       SET RTHSHDATE = CURRENTDATE,
            RTHSHPER  = P_PER,
         --  RTHSHPER  = rthcreper ,
           RTHSHFLAG = 'Y',
           RTHRLID   = RL.RLID,
           RTHMRID   = RL.RLMRID,
           RTHJE     = RL.RLJE
     WHERE RTHNO = P_NO;

    --�������������(������ѵ�ʱ��û�п��ǵ��Ƿ����ֹ�������)
    IF RTH.RTHECODEFLAG = 'N' THEN
      UPDATE METERINFO
         SET MIRCODE     = RTH.RTHSCODE,
             MIRCODECHAR = RTH.RTHSCODE,
             MINEWFLAG   = 'N'
       WHERE CURRENT OF C_METERINFO;
    END IF;

    CLOSE C_METERINFO;
    -----���崦�����
    --zhw 20160303�޸� --start- ------------------
    update reclist set RLJTMK = RTH.IFSLMK where rlid = RL.RLID;
    -----------------------------------------------end
    --add 2013.03.22      ��reclist_charge_01���в�������
    SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.03.22

    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_NO);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --׷���շ� V --����ԭ�� ������ �������󣬲����ֹ��
  PROCEDURE SP_RECTRANS103(P_NO IN VARCHAR2, P_PER IN VARCHAR2) AS
    CURSOR C_DT IS
      SELECT * FROM RECTRANSDT WHERE RTDNO = P_NO FOR UPDATE;

    CURSOR C_CUSTINFO(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;

    CURSOR C_METERINFO(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID FOR UPDATE NOWAIT;

    CURSOR C_METERDOC(VMID IN VARCHAR2) IS
      SELECT * FROM METERDOC WHERE MDMID = VMID;

    CURSOR C_METERACCOUNT(VMID IN VARCHAR2) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMID;

    CURSOR C_BOOKFRAME(VBFID IN VARCHAR2) IS
      SELECT * FROM BOOKFRAME WHERE BFID = VBFID;

    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;

    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;

    RTH    RECTRANSHD%ROWTYPE;
    RTD    RECTRANSDT%ROWTYPE;
    CI     CUSTINFO%ROWTYPE;
    MI     METERINFO%ROWTYPE;
    BF     BOOKFRAME%ROWTYPE;
    MD     METERDOC%ROWTYPE;
    MA     METERACCOUNT%ROWTYPE;
    RL     RECLIST%ROWTYPE;
    RL1    RECLIST%ROWTYPE;
    RD     RECDETAIL%ROWTYPE;
    P_PIID VARCHAR2(4000);

    V_RLFZCOUNT NUMBER(10);
    V_RLFIRST   NUMBER(10);
    V_PIGROUP   PRICEITEM.PIGROUP%TYPE;
    RDTAB       PG_EWIDE_METERREAD_01.RD_TABLE;
    PI          PRICEITEM%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO RTH FROM RECTRANSHD WHERE RTHNO = P_NO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ�����!');
    END;
    IF RTH.RTHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���������');
    END IF;
    IF RTH.RTHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '������ȡ��');
    END IF;
    --
    OPEN C_CUSTINFO(RTH.RTHCID);
    FETCH C_CUSTINFO
      INTO CI;
    IF C_CUSTINFO%NOTFOUND OR C_CUSTINFO%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�޴��û�');
    END IF;
    CLOSE C_CUSTINFO;

    OPEN C_METERINFO(RTH.RTHMID);
    FETCH C_METERINFO
      INTO MI;
    IF C_METERINFO%NOTFOUND OR C_METERINFO%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�޴�ˮ��');
    END IF;

    OPEN C_METERDOC(RTH.RTHMID);
    FETCH C_METERDOC
      INTO MD;
    IF C_METERDOC%NOTFOUND OR C_METERDOC%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�޴�ˮ����');
    END IF;
    CLOSE C_METERDOC;

    OPEN C_METERACCOUNT(RTH.RTHMID);
    FETCH C_METERACCOUNT
      INTO MA;
    IF C_METERACCOUNT%NOTFOUND OR C_METERACCOUNT%NOTFOUND IS NULL THEN
      --raise_application_error(errcode,'�޴�ˮ������');
      NULL;
    END IF;
    CLOSE C_METERACCOUNT;

    OPEN C_BOOKFRAME(RTH.RTHBFID);
    FETCH C_BOOKFRAME
      INTO BF;
    IF C_BOOKFRAME%NOTFOUND OR C_BOOKFRAME%NOTFOUND IS NULL THEN
      --raise_application_error(errcode,'�޴˱��');
      NULL;
    END IF;
    CLOSE C_BOOKFRAME;
    -----��ͷ����ʼ

    -- Ԥ�ȸ�ֵ
    RTH.RTHSHPER  := P_PER;
    RTH.RTHSHDATE := CURRENTDATE;

    --������ʷ��������Ϣ
    SP_INSERTMRHIS(RTH, RTH.RTHLB, MI, RL.RLMRID);
    RL.RLID          := FGETSEQUENCE('RECLIST');
    RL.RLSMFID       := MI.MISMFID;
    RL.RLMONTH       := TOOLS.FGETRECMONTH(MI.MISMFID);
    RL.RLDATE        := TOOLS.FGETRECDATE(MI.MISMFID);
    RL.RLCID         := RTH.RTHCID;
    RL.RLMID         := RTH.RTHMID;
    RL.RLMSMFID      := MI.MISMFID;
    RL.RLCSMFID      := CI.CISMFID;
    RL.RLCCODE       := RTH.RTHCCODE;
    RL.RLCHARGEPER   := RTH.RTHCPER;
    RL.RLCPID        := CI.CIPID;
    RL.RLCCLASS      := CI.CICLASS;
    RL.RLCFLAG       := CI.CIFLAG;
    RL.RLUSENUM      := RTH.RTHUSENUM;
    RL.RLCNAME       := RTH.RTHMNAME;
    RL.RLCNAME2      := MI.MINAME2;
    RL.RLCADR        := RTH.RTHCADR;
    RL.RLMADR        := RTH.RTHMADR;
    RL.RLCSTATUS     := CI.CISTATUS;
    RL.RLMTEL        := CI.CIMTEL;
    RL.RLTEL         := CI.CITEL1;
    RL.RLBANKID      := MA.MABANKID;
    RL.RLTSBANKID    := MA.MATSBANKID;
    RL.RLACCOUNTNO   := MA.MAACCOUNTNO;
    RL.RLACCOUNTNAME := MA.MAACCOUNTNAME;
    RL.RLIFTAX       := MI.MIIFTAX;
    RL.RLTAXNO       := MI.MITAXNO;
    RL.RLIFINV       := CI.CIIFINV; --��Ʊ��־
    RL.RLMCODE       := RTH.RTHMCODE;
    RL.RLMPID        := MI.MIPID;
    RL.RLMCLASS      := MI.MICLASS;
    RL.RLMFLAG       := MI.MIFLAG;
    RL.RLMSFID       := MI.MISTID;
    RL.RLDAY         := NULL; --???
    RL.RLBFID        := RTH.RTHBFID; --
    RL.RLPRDATE      := RTH.RTHPRDATE; --
    RL.RLRDATE       := RTH.RTHRDATE;
    RL.RLZNDATE := (CASE
                     WHEN FSYSPARA('0041') = '1' THEN
                      TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                 1),
                                      'yyyymm') || '08',
                              'yyyymmdd')
                     WHEN FSYSPARA('0041') = '2' THEN
                      TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                 1),
                                      'yyyymm') || '08',
                              'yyyymmdd')
                     ELSE
                      NULL
                   END);
    RL.RLCALIBER     := MD.MDCALIBER;
    RL.RLRTID        := RTH.RTHRTID;
    RL.RLMSTATUS     := MI.MISTATUS;
    RL.RLMTYPE       := RTH.RTHMTYPE;
    RL.RLMNO         := MD.MDNO;
    /*    rl.rlscode       := rth.rthscode;
    rl.rlecode       := rth.rthecode;*/

    RL.RLSCODE := NVL(RTH.RTHSCODECHAR, RTH.RTHSCODE);
    RL.RLECODE := NVL(RTH.RTHECODECHAR, RTH.RTHECODE);

    RL.RLREADSL       := RTH.RTHREADSL;
    RL.RLINVMEMO      := RTH.RTHINVMEMO;
    RL.RLENTRUSTBATCH := NULL;
    RL.RLENTRUSTSEQNO := NULL;
    RL.RLOUTFLAG      := 'N';
    RL.RLTRANS        := RTH.RTHLB; --�����Ӧ������ID�뵥������ɺ���ͬ
    RL.RLCD           := PG_EWIDE_METERREAD_01.DEBIT;
    RL.RLYSCHARGETYPE := RTH.RTHCHARGETYPE;
    RL.RLSL           := RTH.RTHSL; --Ӧ��ˮ��ˮ������rlsl = rlreadsl + rladdsl��
    RL.RLJE           := RTH.RTHJE; --������������,�ȳ�ʼ��
    RL.RLADDSL        := RTH.RTHADDSL;
    RL.RLSCRRLID      := NULL;
    RL.RLSCRRLTRANS   := NULL;
    RL.RLSCRRLMONTH   := NULL;
    RL.RLPAIDFLAG     := 'N';
    RL.RLPAIDJE       := 0;
    RL.RLPAIDDATE     := NULL;
    RL.RLPAIDPER      := NULL;
    --rl.rlmrid        := rth.rthmrid;
    RL.RLMEMO      := RTH.RTHMEMO;
    RL.RLZNJ       := 0;
    RL.RLLB        := RTH.RTHMLB;
    RL.RLPFID      := RTH.RTHPFID;
    RL.RLDATETIME  := SYSDATE;
    RL.RLPRIMCODE  := FGETMCODE(MI.MIPRIID);
    RL.RLPRIFLAG   := MI.MIPRIFLAG;
    RL.RLRPER      := BF.BFRPER;
    RL.RLSAFID     := MI.MISAFID;
    RL.RLSCODECHAR := RTH.RTHSCODECHAR;
    RL.RLECODECHAR := RTH.RTHECODECHAR;
    RL.RLILID      := NULL; --��Ʊ��ˮ��
    RL.RLMIUIID    := MI.MIUIID; --��λ����
    RL.RLGROUP     := 1; --Ӧ���ʷ���

    ---��ṹ�޸ĺ����������
    RL.RLPID          := NULL; --ʵ����ˮ����payment.pid��Ӧ��
    RL.RLPBATCH       := NULL; --�ɷѽ������Σ���payment.pbatch��Ӧ��
    RL.RLSAVINGQC     := 0; --�ڳ�Ԥ�棨����ʱ������
    RL.RLSAVINGBQ     := 0; --����Ԥ�淢��������ʱ������
    RL.RLSAVINGQM     := 0; --��ĩԤ�棨����ʱ������
    RL.RLREVERSEFLAG  := 'N'; --  ������־��nΪ������yΪ������
    RL.RLBADFLAG      := 'N'; --���ʱ�־��y :�����ʣ�o:�����������У�n:�����ʣ�
    RL.RLZNJREDUCFLAG := 'N'; --���ɽ�����־,δ����ʱΪn������ʱ���ɽ�ֱ�Ӽ��㣻�����Ϊy,����ʱ���ɽ�ֱ��ȡrlznj
    RL.RLMISTID       := MI.MISTID; --��ҵ����
    RL.RLMINAME       := MI.MINAME; --Ʊ������
    RL.RLSXF          := 0; --������
    RL.RLMIFACE2      := MI.MIFACE2; --��������
    RL.RLMIFACE3      := MI.MIFACE3; --�ǳ�����
    RL.RLMIFACE4      := MI.MIFACE4; --����ʩ˵��
    RL.RLMIIFCKF      := MI.MIIFCHK; --�����ѻ���
    RL.RLMIGPS        := MI.MIGPS; --�Ƿ��Ʊ
    RL.RLMIQFH        := MI.MIQFH; --Ǧ���
    RL.RLMIBOX        := MI.MIBOX; --����ˮ�ۣ���ֵ˰ˮ�ۣ���������
    RL.RLMINAME2      := MI.MINAME2; --��������(С��������������
    RL.RLMISEQNO      := MI.MISEQNO; --���ţ���ʼ��ʱ���+��ţ�

    --
    BEGIN
      SELECT NVL(SUM(NVL(RLJE, 0) - NVL(RLPAIDJE, 0)), 0)
        INTO RL.RLPRIORJE
        FROM RECLIST T
       WHERE T.RLREVERSEFLAG = 'Y'
         AND T.RLPAIDFLAG = 'N'
         AND RLJE > 0
         AND RLMID = MI.MIID;
    EXCEPTION
      WHEN OTHERS THEN
        RL.RLPRIORJE := 0; --���֮ǰǷ��
    END;
    IF RL.RLPRIORJE > 0 THEN
      RL.RLMISAVING := 0;
    ELSE
      RL.RLMISAVING := MI.MISAVING; --���ʱԤ��
    END IF;

    RL.RLMICOMMUNITY   := MI.MICOMMUNITY; --С��
    RL.RLMIREMOTENO    := MI.MIREMOTENO; --Զ�����
    RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --Զ��hub��
    RL.RLMIEMAIL       := MI.MIEMAIL; --�����ʼ�
    RL.RLMICOLUMN1     := MI.MICOLUMN1; --�����ֶ�1
    RL.RLMICOLUMN2     := MI.MICOLUMN2; --�����ֶ�2
    RL.RLMICOLUMN3     := MI.MICOLUMN3; --�����ֶ�3
    RL.RLMICOLUMN4     := MI.MICOLUMN4; --�����ֶ�3
    RL.RLSCRRLID       := RL.RLID; --ԭӦ����ˮ
    RL.RLSCRRLTRANS    := RL.RLTRANS; --ԭӦ������
    RL.RLSCRRLMONTH    := RL.RLMONTH; --ԭӦ���·�
    RL.RLSCRRLDATE     := RL.RLDATE; --ԭӦ��������
    RL.RLCOLUMN5       := RL.RLDATE; --�ϴ�Ӧ��������
    RL.RLCOLUMN9       := RL.RLID; --�ϴ�Ӧ������ˮ
    RL.RLCOLUMN10      := RL.RLMONTH; --�ϴ�Ӧ�����·�
    RL.RLCOLUMN11      := RL.RLTRANS; --�ϴ�Ӧ��������
    --����Ӧ��
    --insert into reclist values rl;
    --ֹ�봦��
    IF RTH.RTHECODEFLAG = 'Y' THEN
      UPDATE METERINFO
         SET --mircode    = rth.rthecode,

             --mircodechar= rth.rthecodechar,
               MIRECDATE = RTH.RTHRDATE,
             --mirecsl    = rth.rthsl,--ȡ����ˮ��
             --miface     = mr.mrface,
             MINEWFLAG = 'N'
       WHERE CURRENT OF C_METERINFO;
    END IF;
    -----��ͷ�������
    ---------------------------------------------------------
    -----���崦��ʼ
    OPEN C_DT;
    LOOP
      FETCH C_DT
        INTO RTD;
      EXIT WHEN C_DT%NOTFOUND OR C_DT%NOTFOUND IS NULL;
      RD.RDID        := RL.RLID;
      RD.RDPMDID     := RTD.RTDPMDID;
      RD.RDPIID      := RTD.RTDPIID;
      P_PIID := (CASE
                  WHEN P_PIID IS NULL THEN
                   ''
                  ELSE
                   P_PIID || '/'
                END) || RTD.RTDPIID;
      RD.RDPFID      := RTD.RTDPFID;
      RD.RDPSCID     := RTD.RTDPSCID;
      RD.RDCLASS     := 0; --�ݲ�֧�ֽ���Ʒ�
      RD.RDYSDJ      := RTD.RTDYSDJ;
      RD.RDYSSL      := RTD.RTDYSSL;
      RD.RDYSJE      := RTD.RTDYSJE;
      RD.RDDJ        := RTD.RTDDJ;
      RD.RDSL        := RTD.RTDSL;
      RD.RDJE        := RTD.RTDJE;
      RD.RDADJDJ     := RTD.RTDADJDJ;
      RD.RDADJSL     := RTD.RTDADJSL;
      RD.RDADJJE     := RTD.RTDADJJE;
      RD.RDMETHOD    := 'dj1'; --ֻ֧�̶ֹ�����
      RD.RDPAIDFLAG  := 'N';
      RD.RDPAIDDATE  := NULL;
      RD.RDPAIDMONTH := NULL;
      RD.RDPAIDPER   := NULL;
      RD.RDPMDSCALE  := RTD.RTDSCALE;
      RD.RDILID      := NULL;
      RD.RDZNJ       := 0;
      RD.RDMEMO      := NULL;

      /*insert into recdetail values rd;*/

      IF RDTAB IS NULL THEN
        RDTAB := PG_EWIDE_METERREAD_01.RD_TABLE(RD);
      ELSE
        RDTAB.EXTEND;
        RDTAB(RDTAB.LAST) := RD;
      END IF;

    END LOOP;

    IF FSYSPARA('1104') = 'Y' THEN
      --�ּ�������
      V_RLFIRST := 0;
      OPEN C_PICOUNT;
      LOOP
        FETCH C_PICOUNT
          INTO V_PIGROUP;
        EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
        RL1         := RL;
        RL1.RLGROUP := V_PIGROUP;
        IF V_RLFIRST = 0 THEN
          V_RLFIRST := V_RLFIRST + 1;
        ELSE
          RL1.RLID  := FGETSEQUENCE('RECLIST');
          V_RLFIRST := V_RLFIRST + 1;
        END IF;
        RL1.RLJE := 0;
        RL1.RLSL := 0;

        IF RL1.RLGROUP = 1 OR RL1.RLGROUP = 3 THEN
          RL1.RLMIEMAILFLAG := 'S'; --��Ʊ��ӡ
        ELSE
          RL1.RLMIEMAILFLAG := 'W';
        END IF;

        V_RLFZCOUNT := 0;
        OPEN C_PI(V_PIGROUP);
        LOOP
          FETCH C_PI
            INTO PI;
          EXIT WHEN C_PI%NOTFOUND OR C_PI%NOTFOUND IS NULL;

          FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
            IF RDTAB(I).RDPIID = PI.PIID THEN
              V_RLFZCOUNT := V_RLFZCOUNT + 1;
              RDTAB(I).RDID := RL1.RLID;
              RL1.RLJE := RL1.RLJE + RDTAB(I).RDJE;
              IF RDTAB(I).RDPIID = '01' OR RDTAB(I).RDPIID = '04' THEN
                RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;

              END IF;
              INSERT INTO RECDETAIL VALUES RDTAB (I);
            END IF;
          END LOOP;

        END LOOP;
        CLOSE C_PI;
        IF V_RLFZCOUNT > 0 THEN
          INSERT INTO RECLIST VALUES RL1;
        END IF;
      END LOOP;
      CLOSE C_PICOUNT;
    ELSE
      INSERT INTO RECLIST VALUES RL;

      PG_EWIDE_METERREAD_01.INSRD(RDTAB);

    END IF;

    CLOSE C_DT;

    UPDATE RECTRANSHD
       SET RTHSHDATE = CURRENTDATE,
           RTHSHPER  = P_PER,
           RTHSHFLAG = 'Y',
           RTHRLID   = RL.RLID,
           RTHMRID   = RL.RLMRID
     WHERE RTHNO = P_NO;

    -----���崦�����
    --add 2013.03.22      ��reclist_charge_01���в�������
    SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.03.22
    CLOSE C_METERINFO;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  PROCEDURE SP_RECTRANS104(P_NO IN VARCHAR2, P_PER IN VARCHAR2,P_DJLB IN VARCHAR2) AS
    CURSOR C_PD(C_PFID IN VARCHAR2) IS
      SELECT * FROM PRICEDETAIL WHERE PDPFID = C_PFID AND PDPIID='01';

    CURSOR C_PD1(C_PFID IN VARCHAR2) IS
      SELECT * FROM PRICEDETAIL WHERE PDPFID = C_PFID AND PDPIID='02';

    CURSOR C_CUSTINFO(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;

    CURSOR C_METERINFO(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID FOR UPDATE NOWAIT;

    CURSOR C_METERDOC(VMID IN VARCHAR2) IS
      SELECT * FROM METERDOC WHERE MDMID = VMID;

    CURSOR C_METERACCOUNT(VMID IN VARCHAR2) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMID;



    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;

    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;

    RTH    RECTRANSHD%ROWTYPE;
    RTD    RECTRANSDT%ROWTYPE;
    CI     CUSTINFO%ROWTYPE;
    MI     METERINFO%ROWTYPE;
    BF     BOOKFRAME%ROWTYPE;
    MD     METERDOC%ROWTYPE;
    MA     METERACCOUNT%ROWTYPE;
    RL     RECLIST%ROWTYPE;
    RL1    RECLIST%ROWTYPE;
    RD     RECDETAIL%ROWTYPE;
    PD     PRICEDETAIL%ROWTYPE;
    P_PIID VARCHAR2(4000);

    V_RLFZCOUNT NUMBER(10);
    V_RLFIRST   NUMBER(10);
    V_PIGROUP   PRICEITEM.PIGROUP%TYPE;
    RDTAB       PG_EWIDE_METERREAD_01.RD_TABLE;
    PI          PRICEITEM%ROWTYPE;
    MR          METERREAD%ROWTYPE;
    V_PV        NUMBER(10);
  BEGIN

    BEGIN

      SELECT * INTO RTH FROM RECTRANSHD WHERE RTHNO = P_NO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ�����!');
    END;
    IF RTH.RTHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���������');
    END IF;
    IF RTH.RTHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '������ȡ��');
    END IF;
    --
    OPEN C_CUSTINFO(RTH.RTHCID);
    FETCH C_CUSTINFO
      INTO CI;
    IF C_CUSTINFO%NOTFOUND OR C_CUSTINFO%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�޴��û�');
    END IF;
    CLOSE C_CUSTINFO;

    IF P_DJLB='u' THEN
       OPEN C_PD(RTH.RTHPFID);
        FETCH C_PD
          INTO PD;
        IF C_PD%NOTFOUND OR C_PD%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���ˮ��ˮ�ۣ�');
        END IF;
       CLOSE C_PD;
    ELSIF  P_DJLB='v' THEN
       OPEN C_PD1(RTH.RTHPFID);
        FETCH C_PD1
          INTO PD;
        IF C_PD1%NOTFOUND OR C_PD1%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���ˮ��ˮ�ۣ�');
        END IF;
       CLOSE C_PD1;
    END IF;


    OPEN C_METERINFO(RTH.RTHMID);
    FETCH C_METERINFO
      INTO MI;
    IF C_METERINFO%NOTFOUND OR C_METERINFO%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�޴�ˮ��');
    END IF;

    OPEN C_METERDOC(RTH.RTHMID);
    FETCH C_METERDOC
      INTO MD;
    IF C_METERDOC%NOTFOUND OR C_METERDOC%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�޴�ˮ����');
    END IF;
    CLOSE C_METERDOC;

    OPEN C_METERACCOUNT(RTH.RTHMID);
    FETCH C_METERACCOUNT
      INTO MA;
    IF C_METERACCOUNT%NOTFOUND OR C_METERACCOUNT%NOTFOUND IS NULL THEN
      raise_application_error(errcode,'�޴�ˮ������');
    END IF;
    CLOSE C_METERACCOUNT;


    -----��ͷ����ʼ

    -- Ԥ�ȸ�ֵ
    RTH.RTHSHPER  := P_PER;
    RTH.RTHSHDATE := CURRENTDATE;

    /*******����׷����Ϣ*****/
    IF RTH.IFREC = 'Y' THEN

      --�Ƿ�����ѹ���(���߿���ΪӪҵ��)
      --���볭���
      SP_INSERTMR(RTH, RTH.RTHLB, MI, RL.RLMRID);
      IF RL.RLMRID IS NOT NULL THEN
        SELECT * INTO MR FROM METERREAD WHERE MRID = RL.RLMRID;
        IF RTH.IFRECHIS = 'Y' THEN
          IF RTH.PRICEMONTH IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '�۸��·ݲ���Ϊ�գ�');
          END IF;
          SELECT COUNT(*)
            INTO V_PV
            FROM PRICEVER
           WHERE (TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm') >= SMONTH AND
                 TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm') <= EMONTH);
          IF V_PV = 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '���·�ˮ��δ�鵵��');
          END IF;
          --�Ƿ���ʷˮ�����(ѡ��鵵�۸�汾)
          PG_EWIDE_METERREAD_01.CALCULATE(MR,
                                          RTH.RTHLB,
                                          TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm'));
          INSERT INTO METERREADHIS
            SELECT * FROM METERREAD WHERE MRID = RL.RLMRID;
          DELETE METERREAD WHERE MRID = RL.RLMRID;
          SELECT * INTO RL FROM RECLIST WHERE RLMRID = RL.RLMRID;
          /*   UPDATE RECLIST RL
            SET RL.RLMEMO = RTH.RTHMEMO
          WHERE RL.RLID = RL.RLID;*/
        ELSE
          PG_EWIDE_METERREAD_01.CALCULATE(MR, RTH.RTHLB, '0000.00');
          INSERT INTO METERREADHIS
            SELECT * FROM METERREAD WHERE MRID = RL.RLMRID;

          DELETE METERREAD WHERE MRID = RL.RLMRID;
          SELECT * INTO RL FROM RECLIST WHERE RLMRID = RL.RLMRID;
          /*   UPDATE RECLIST RL
            SET RL.RLMEMO = RTH.RTHMEMO
          WHERE RL.RLID = RL.RLID;*/
        END IF;
        IF RTH.RTHECODEFLAG = 'N' THEN
          UPDATE METERINFO
             SET MIRCODE = RTH.RTHSCODE, MIRCODECHAR = RTH.RTHSCODECHAR
          --miface     = mr.mrface,
           WHERE CURRENT OF C_METERINFO;

        END IF;
      END IF;
    ELSE
      --������ʷ��������Ϣ
      SP_INSERTMRHIS(RTH, RTH.RTHLB, MI, RL.RLMRID);
      RL.RLID        := FGETSEQUENCE('RECLIST');
      RL.RLSMFID     := MI.MISMFID;
      RL.RLMONTH     := TOOLS.FGETRECMONTH(MI.MISMFID);
      RL.RLDATE      := TOOLS.FGETRECDATE(MI.MISMFID);
      RL.RLCID       := RTH.RTHCID;
      RL.RLMID       := RTH.RTHMID;
      RL.RLMSMFID    := MI.MISMFID;
      RL.RLCSMFID    := CI.CISMFID;
      RL.RLCCODE     := RTH.RTHCCODE;
      RL.RLCHARGEPER := RTH.RTHCPER;
      RL.RLCPID      := CI.CIPID;
      RL.RLCCLASS    := CI.CICLASS;
      RL.RLCFLAG     := CI.CIFLAG;
      RL.RLUSENUM    := RTH.RTHUSENUM;
      RL.RLCNAME     := RTH.RTHMNAME;
      --rl.rlcname2      := ;
      RL.RLCADR        := RTH.RTHCADR;
      RL.RLMADR        := RTH.RTHMADR;
      RL.RLCSTATUS     := CI.CISTATUS;
      RL.RLMTEL        := CI.CIMTEL;
      RL.RLTEL         := CI.CITEL1;
      RL.RLBANKID      := MA.MABANKID;
      RL.RLTSBANKID    := MA.MATSBANKID;
      RL.RLACCOUNTNO   := MA.MAACCOUNTNO;
      RL.RLACCOUNTNAME := MA.MAACCOUNTNAME;
      RL.RLIFTAX       := MI.MIIFTAX;
      RL.RLTAXNO       := MI.MITAXNO;
      RL.RLIFINV       := CI.CIIFINV; --��Ʊ��־
      RL.RLMCODE       := RTH.RTHMCODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := NULL; --???
      RL.RLBFID        := RTH.RTHBFID; --
      RL.RLPRDATE      := RTH.RTHPRDATE; --
      RL.RLRDATE       := RTH.RTHRDATE;
      /*RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '08',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   1),
                                        'yyyymm') || '08',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);*/
      RL.RLZNDATE      := NULL;  --�����ɽ�
      RL.RLCALIBER     := MD.MDCALIBER;
      RL.RLRTID        := RTH.RTHRTID;
      RL.RLMSTATUS     := MI.MISTATUS;
      RL.RLMTYPE       := RTH.RTHMTYPE;
      RL.RLMNO         := MD.MDNO;
      /*     \*    rl.rlscode       := rth.rthscode;
      rl.rlecode       := rth.rthecode;*\*/

      --byj edit 2016.7.15 ������ʱ��ˮ�����շ�
      RL.RLSCODE := RTH.RTHSCODE;
      RL.RLECODE := RTH.RTHECODE;
			rl.rlscodechar := RTH.RTHSCODECHAR ;
			rl.rlecodechar := RTH.RTHECODECHAR ;
			--end!!!




      RL.RLREADSL       := RTH.RTHREADSL;
      RL.RLINVMEMO      := RTH.RTHINVMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      RL.RLTRANS        := RTH.RTHLB; --�����Ӧ������ID�뵥�������ͬ
      RL.RLCD           := PG_EWIDE_METERREAD_01.DEBIT;
      RL.RLYSCHARGETYPE := RTH.RTHCHARGETYPE;
      RL.RLSL           := RTH.RTHSL; --Ӧ��ˮ��ˮ������rlsl = rlreadsl + rladdsl��
      RL.RLJE           := RTH.RTHJE; --������������,�ȳ�ʼ��
      RL.RLADDSL        := RTH.RTHADDSL;
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDJE       := 0;
      RL.RLPAIDDATE     := NULL;
      RL.RLPAIDPER      := NULL;
      --rl.rlmrid        := rth.rthmrid;
      RL.RLMEMO      := RTH.RTHMEMO;
      RL.RLZNJ       := 0;
      RL.RLLB        := RTH.RTHMLB;
      RL.RLPFID      := RTH.RTHPFID;
      RL.RLDATETIME  := SYSDATE;
      RL.RLPRIMCODE  := FGETMCODE(MI.MIPRIID);
      RL.RLPRIFLAG   := MI.MIPRIFLAG;
      RL.RLRPER      := BF.BFRPER;
      RL.RLSAFID     := MI.MISAFID;
      RL.RLSCODECHAR := RTH.RTHSCODECHAR;
      RL.RLECODECHAR := RTH.RTHECODECHAR;
      RL.RLILID      := NULL; --��Ʊ��ˮ��
      RL.RLMIUIID    := MI.MIUIID; --��λ����
      RL.RLGROUP     := 1; --Ӧ���ʷ���

      ---��ṹ�޸ĺ����������
      RL.RLPID          := NULL; --ʵ����ˮ����payment.pid��Ӧ��
      RL.RLPBATCH       := NULL; --�ɷѽ������Σ���payment.pbatch��Ӧ��
      RL.RLSAVINGQC     := 0; --�ڳ�Ԥ�棨����ʱ������
      RL.RLSAVINGBQ     := 0; --����Ԥ�淢��������ʱ������
      RL.RLSAVINGQM     := 0; --��ĩԤ�棨����ʱ������
      RL.RLREVERSEFLAG  := 'N'; --  ������־��nΪ������yΪ������
      RL.RLBADFLAG      := 'N'; --���ʱ�־��y :�����ʣ�o:�����������У�n:�����ʣ�
      RL.RLZNJREDUCFLAG := 'N'; --���ɽ�����־,δ����ʱΪn������ʱ���ɽ�ֱ�Ӽ��㣻�����Ϊy,����ʱ���ɽ�ֱ��ȡrlznj
      RL.RLMISTID       := MI.MISTID; --��ҵ����
      RL.RLMINAME       := MI.MINAME; --Ʊ������
      RL.RLSXF          := 0; --������
      RL.RLMIFACE2      := MI.MIFACE2; --��������
      RL.RLMIFACE3      := MI.MIFACE3; --�ǳ�����
      RL.RLMIFACE4      := MI.MIFACE4; --����ʩ˵��
      RL.RLMIIFCKF      := MI.MIIFCHK; --�����ѻ���
      RL.RLMIGPS        := MI.MIGPS; --�Ƿ��Ʊ
      RL.RLMIQFH        := MI.MIQFH; --Ǧ���
      RL.RLMIBOX        := MI.MIBOX; --����ˮ�ۣ���ֵ˰ˮ�ۣ���������
      RL.RLMINAME2      := MI.MINAME2; --��������(С��������������
      RL.RLMISEQNO      := MI.MISEQNO; --���ţ���ʼ��ʱ���+��ţ�
      RL.RLSCRRLID      := RL.RLID; --ԭӦ����ˮ
      RL.RLSCRRLTRANS   := RL.RLTRANS; --ԭӦ������
      RL.RLSCRRLMONTH   := RL.RLMONTH; --ԭӦ���·�
      RL.RLSCRRLDATE    := RL.RLDATE; --ԭӦ��������
      RL.RLCOLUMN5      := RL.RLDATE; --�ϴ�Ӧ��������
      RL.RLCOLUMN9      := RL.RLID; --�ϴ�Ӧ������ˮ
      RL.RLCOLUMN10     := RL.RLMONTH; --�ϴ�Ӧ�����·�
      RL.RLCOLUMN11     := RL.RLTRANS; --�ϴ�Ӧ��������
      BEGIN
        SELECT NVL(SUM(NVL(RLJE, 0) - NVL(RLPAIDJE, 0)), 0)
          INTO RL.RLPRIORJE
          FROM RECLIST T
         WHERE T.RLREVERSEFLAG = 'Y'
           AND T.RLPAIDFLAG = 'N'
           AND RLJE > 0
           AND RLMID = MI.MIID;
      EXCEPTION
        WHEN OTHERS THEN
          RL.RLPRIORJE := 0; --���֮ǰǷ��
      END;
      IF RL.RLPRIORJE > 0 THEN
        RL.RLMISAVING := 0;
      ELSE
        RL.RLMISAVING := MI.MISAVING; --���ʱԤ��
      END IF;

      RL.RLMICOMMUNITY   := MI.MICOMMUNITY; --С��
      RL.RLMIREMOTENO    := MI.MIREMOTENO; --Զ�����
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --Զ��hub��
      RL.RLMIEMAIL       := MI.MIEMAIL; --�����ʼ�
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --�����ֶ�1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --�����ֶ�2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --�����ֶ�3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --�����ֶ�3

      --����Ӧ��
      --insert into reclist values rl;
      --ֹ�봦��
      IF RTH.RTHECODEFLAG = 'Y' THEN
        UPDATE METERINFO
           SET MIRCODE = RTH.RTHECODE,

               MIRCODECHAR = RTH.RTHECODECHAR,
               MIRECDATE   = RTH.RTHRDATE,
               MIRECSL     = RTH.RTHSL, --ȡ����ˮ��
               --miface     = mr.mrface,
               MINEWFLAG = 'N'
         WHERE CURRENT OF C_METERINFO;

      END IF;
      -----RECLIST�������
      ---------------------------------------------------------
      -----RECDETAIL����ʼ
        INSERT INTO RECLIST VALUES RL;

        RD.RDID        := RL.RLID;
        RD.RDPMDID     := 0;

        RD.RDPIID      := PD.PDPIID;
        RD.RDPFID      := RL.RLPFID;
        RD.RDPSCID     := 0;
        RD.RDCLASS     := 0; --�ݲ�֧�ֽ���Ʒ�
        RD.RDYSDJ      := PD.PDDJ;
        RD.RDYSSL      := RL.RLSL;
        RD.RDYSJE      := RL.RLJE;
        RD.RDDJ        := PD.PDDJ;
        RD.RDSL        := RL.RLSL;
        RD.RDJE        := RL.RLJE;
        RD.RDADJDJ     := 0;
        RD.RDADJSL     := 0;
        RD.RDADJJE     := 0;
        RD.RDMETHOD    := 'dj1'; --ֻ֧�̶ֹ�����
        RD.RDPAIDFLAG  := 'N';
        RD.RDPAIDDATE  := NULL;
        RD.RDPAIDMONTH := NULL;
        RD.RDPAIDPER   := NULL;
        RD.RDPMDSCALE  := 1;
        RD.RDILID      := NULL;
        RD.RDZNJ       := 0;
        RD.RDMEMO      := NULL;

        RD.RDMSMFID     := RL.RLMSMFID; --Ӫ����˾
        RD.RDMONTH      := RL.RLMONTH; --�����·�
        RD.RDMID        := RL.RLMID; --ˮ����
        RD.RDPMDTYPE    := '01'; --������
        RD.RDPMDCOLUMN1 := NULL; --�����ֶ�1
        RD.RDPMDCOLUMN2 := NULL; --�����ֶ�2
        RD.RDPMDCOLUMN3 := NULL; --�����ֶ�3

        INSERT INTO RECDETAIL VALUES RD;




      -----���崦�����
    END IF;
    UPDATE RECTRANSHD
       SET RTHSHDATE = CURRENTDATE,
           RTHSHPER  = P_PER,
        --   RTHSHPER  = rthcreper ,
           RTHSHFLAG = 'Y',
           RTHRLID   = RL.RLID,
           RTHMRID   = RL.RLMRID,
           RTHJE     = RL.RLJE
     WHERE RTHNO = P_NO;

    --�������������(������ѵ�ʱ��û�п��ǵ��Ƿ����ֹ�������)
    /*IF RTH.RTHECODEFLAG = 'N' THEN
      UPDATE METERINFO
         SET MIRCODE     = RTH.RTHSCODE,
             MIRCODECHAR = RTH.RTHSCODE,
             MINEWFLAG   = 'N'
       WHERE CURRENT OF C_METERINFO;
    END IF;*/

    CLOSE C_METERINFO;
    -----���崦�����
    --add 2013.03.22      ��reclist_charge_01���в�������
    SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.03.22

    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_NO);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;


  PROCEDURE SP_INSERTMR(RTH         IN RECTRANSHD%ROWTYPE, --׷��ͷ
                        P_MRIFTRANS IN VARCHAR2, --������������
                        MI          IN METERINFO%ROWTYPE, --ˮ����Ϣ
                        OMRID       OUT METERREAD.MRID%TYPE) AS
    --������ˮ
    MR METERREAD%ROWTYPE; --������ʷ��
  BEGIN
    MR.MRID    := FGETSEQUENCE('METERREAD'); --��ˮ��
    OMRID      := MR.MRID;
    MR.MRMONTH := TOOLS.FGETREADMONTH(MI.MISMFID); --�����·�
    MR.MRSMFID := FGETMETERINFO(MI.MIID, 'MISMFID'); --Ӫ����˾
    MR.MRBFID  := RTH.RTHBFID; --���
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
    MR.MRCID       := RTH.RTHCID; --�û����
    MR.MRCCODE     := RTH.RTHCCODE; --�û���
    MR.MRMID       := RTH.RTHMID; --ˮ����
    MR.MRMCODE     := RTH.RTHMCODE; --ˮ���ֹ����
    MR.MRSTID      := MI.MISTID; --��ҵ����
    MR.MRMPID      := MI.MIPID; --�ϼ�ˮ��
    MR.MRMCLASS    := MI.MICLASS; --ˮ����
    MR.MRMFLAG     := MI.MIFLAG; --ĩ����־
    MR.MRCREADATE  := SYSDATE; --��������
    MR.MRINPUTDATE := SYSDATE; --�༭����
    MR.MRREADOK    := 'Y'; --������־
    MR.MRRDATE     := RTH.RTHRDATE; --��������
    BEGIN
      SELECT MAX(T.BFRPER)
        INTO MR.MRRPER
        FROM BOOKFRAME T
       WHERE T.BFID = MI.MIBFID
         AND T.BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRRPER := RTH.RTHSHPER; --����Ա
    END;

    MR.MRPRDATE        := RTH.RTHPRDATE; --�ϴγ�������
    MR.MRSCODE         := RTH.RTHSCODE; --���ڳ���
    MR.MRECODE         := RTH.RTHECODE; --���ڳ���
    MR.MRSL            := RTH.RTHREADSL; --����ˮ��
    MR.MRFACE          := NULL; --ˮ�����
    MR.MRIFSUBMIT      := 'Y'; --�Ƿ��ύ�Ʒ�
    MR.MRIFHALT        := 'N'; --ϵͳͣ��
    MR.MRDATASOURCE    := 'Z'; --��������Դ�����񳭱�
    MR.MRIFIGNOREMINSL := 'N'; --ͣ����ͳ���
    MR.MRPDARDATE      := NULL; --���������ʱ��
    MR.MROUTFLAG       := 'N'; --�������������־
    MR.MROUTID         := NULL; --�������������ˮ��
    MR.MROUTDATE       := NULL; --���������������
    MR.MRINORDER       := NULL; --��������մ���
    MR.MRINDATE        := NULL; --�������������
    MR.MRRPID          := RTH.RTHMRPID; --�Ƽ�����
    MR.MRMEMO          := RTH.RTHMEMO; --����ע
    MR.MRIFGU          := 'N'; --�����־
    MR.MRIFREC         := 'Y'; --�ѼƷ�
    MR.MRRECDATE       := SYSDATE; --�Ʒ�����
    MR.MRRECSL         := RTH.RTHSL; --Ӧ��ˮ��
    MR.MRADDSL         := RTH.RTHADDSL; --����
    MR.MRCARRYSL       := 0; --��λˮ��
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
    MR.MRPRIMID        := RTH.RTHPRIID; --���ձ�����
    MR.MRPRIMFLAG      := RTH.RTHPRIFLAG; --���ձ��־
    MR.MRLB            := RTH.RTHMLB; --ˮ�����
    MR.MRNEWFLAG       := NULL; --�±��־
    MR.MRFACE2         := NULL; --��������
    MR.MRFACE3         := NULL; --�ǳ�����
    MR.MRFACE4         := NULL; --����ʩ˵��
    MR.MRSCODECHAR     := RTH.RTHSCODECHAR; --���ڳ���
    MR.MRECODECHAR     := RTH.RTHECODECHAR; --���ڳ���
    MR.MRPRIVILEGEFLAG := 'N'; --��Ȩ��־(Y/N)
    MR.MRPRIVILEGEPER  := NULL; --��Ȩ������
    MR.MRPRIVILEGEMEMO := NULL; --��Ȩ������ע
    MR.MRPRIVILEGEDATE := NULL; --��Ȩ����ʱ��
    MR.MRSAFID         := MI.MISAFID; --��������
    MR.MRIFTRANS       := P_MRIFTRANS; --������������
    MR.MRREQUISITION   := 0; --֪ͨ����ӡ����
    MR.MRIFCHK         := MI.MIIFCHK; --���˱�
    INSERT INTO METERREAD VALUES MR;
  EXCEPTION
    WHEN OTHERS THEN
      --OMRID := '';
     RAISE_APPLICATION_ERROR(ERRCODE, '���ݿ����!'||sqlerrm);
  END;

  --׷�ղ��볭��ƻ�����ʷ��
  PROCEDURE SP_INSERTMRHIS(RTH         IN RECTRANSHD%ROWTYPE, --׷��ͷ
                           P_MRIFTRANS IN VARCHAR2, --������������
                           MI          IN METERINFO%ROWTYPE, --ˮ����Ϣ
                           OMRID       OUT METERREADHIS.MRID%TYPE) AS
    --������ˮ
    MRHIS METERREADHIS%ROWTYPE; --������ʷ��
  BEGIN
    MRHIS.MRID    := FGETSEQUENCE('METERREAD'); --��ˮ��
    OMRID         := MRHIS.MRID;
    MRHIS.MRMONTH := TOOLS.FGETREADMONTH(MI.MISMFID); --�����·�
    MRHIS.MRSMFID := FGETMETERINFO(MI.MIID, 'MISMFID'); --Ӫ����˾
    MRHIS.MRBFID  := RTH.RTHBFID; --���
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
    MRHIS.MRCID       := RTH.RTHCID; --�û����
    MRHIS.MRCCODE     := RTH.RTHCCODE; --�û���
    MRHIS.MRMID       := RTH.RTHMID; --ˮ����
    MRHIS.MRMCODE     := RTH.RTHMCODE; --ˮ���ֹ����
    MRHIS.MRSTID      := MI.MISTID; --��ҵ����
    MRHIS.MRMPID      := MI.MIPID; --�ϼ�ˮ��
    MRHIS.MRMCLASS    := MI.MICLASS; --ˮ����
    MRHIS.MRMFLAG     := MI.MIFLAG; --ĩ����־
    MRHIS.MRCREADATE  := SYSDATE; --��������
    MRHIS.MRINPUTDATE := SYSDATE; --�༭����
    MRHIS.MRREADOK    := 'Y'; --������־
    MRHIS.MRRDATE     := RTH.RTHRDATE; --��������
    BEGIN
      SELECT MAX(T.BFRPER)
        INTO MRHIS.MRRPER
        FROM BOOKFRAME T
       WHERE T.BFID = MI.MIBFID
         AND T.BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MRHIS.MRRPER := RTH.RTHSHPER; --����Ա
    END;

    MRHIS.MRPRDATE        := RTH.RTHPRDATE; --�ϴγ�������
    MRHIS.MRSCODE         := RTH.RTHSCODE; --���ڳ���
    MRHIS.MRECODE         := RTH.RTHECODE; --���ڳ���
    MRHIS.MRSL            := RTH.RTHREADSL; --����ˮ��
    MRHIS.MRFACE          := NULL; --ˮ�����
    MRHIS.MRIFSUBMIT      := 'Y'; --�Ƿ��ύ�Ʒ�
    MRHIS.MRIFHALT        := 'N'; --ϵͳͣ��
    MRHIS.MRDATASOURCE    := 'Z'; --׷��
    MRHIS.MRIFIGNOREMINSL := 'N'; --ͣ����ͳ���
    MRHIS.MRPDARDATE      := NULL; --���������ʱ��
    MRHIS.MROUTFLAG       := 'N'; --�������������־
    MRHIS.MROUTID         := NULL; --�������������ˮ��
    MRHIS.MROUTDATE       := NULL; --���������������
    MRHIS.MRINORDER       := NULL; --��������մ���
    MRHIS.MRINDATE        := NULL; --�������������
    MRHIS.MRRPID          := RTH.RTHMRPID; --�Ƽ�����
    MRHIS.MRMEMO          := RTH.RTHMEMO; --����ע
    MRHIS.MRIFGU          := 'N'; --�����־
    MRHIS.MRIFREC         := 'Y'; --�ѼƷ�
    MRHIS.MRRECDATE       := SYSDATE; --�Ʒ�����
    MRHIS.MRRECSL         := RTH.RTHSL; --Ӧ��ˮ��
    MRHIS.MRADDSL         := RTH.RTHADDSL; --����
    MRHIS.MRCARRYSL       := 0; --��λˮ��
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
    MRHIS.MRPRIMID        := RTH.RTHPRIID; --���ձ�����
    MRHIS.MRPRIMFLAG      := RTH.RTHPRIFLAG; --���ձ��־
    MRHIS.MRLB            := RTH.RTHMLB; --ˮ�����
    MRHIS.MRNEWFLAG       := NULL; --�±��־
    MRHIS.MRFACE2         := NULL; --��������
    MRHIS.MRFACE3         := NULL; --�ǳ�����
    MRHIS.MRFACE4         := NULL; --����ʩ˵��
    MRHIS.MRSCODECHAR     := RTH.RTHSCODECHAR; --���ڳ���
    MRHIS.MRECODECHAR     := RTH.RTHECODECHAR; --���ڳ���
    MRHIS.MRPRIVILEGEFLAG := 'N'; --��Ȩ��־(Y/N)
    MRHIS.MRPRIVILEGEPER  := NULL; --��Ȩ������
    MRHIS.MRPRIVILEGEMEMO := NULL; --��Ȩ������ע
    MRHIS.MRPRIVILEGEDATE := NULL; --��Ȩ����ʱ��
    MRHIS.MRSAFID         := MI.MISAFID; --��������
    MRHIS.MRIFTRANS       := P_MRIFTRANS; --������������
    MRHIS.MRREQUISITION   := 0; --֪ͨ����ӡ����
    MRHIS.MRIFCHK         := MI.MIIFCHK; --���˱�
    INSERT INTO METERREADHIS VALUES MRHIS;
  END;

  --Ӧ�ճ��������� BY WANGYONG DATE 20111014
  --   ��鵥�Ƿ������
  --FORѭ������ÿһ����������ϸ
  --��鵥�Ƿ�����˹���
  --�����ᣬֱ��·��
  --���ѻ�����������
  --�������������
  --��û����˵���ϸ�������
  --  ����    sp_reccz_one_01

  --ѭ���������������־
  --�ж��ύ��־�����ΪY�ύ COMMIT
  --������쳣�׳��쳣
  PROCEDURE SP_RECCZ(P_BILLNO IN VARCHAR2, --���ݱ��
                     P_PER    IN VARCHAR2, --�����
                     P_MEMO   IN VARCHAR2, --��ע
                     P_COMMIT IN VARCHAR --�Ƿ��ύ��־
                     ) AS

    CURSOR C_RCCH IS
      SELECT * FROM RECCZHD T WHERE T.RCHNO = P_BILLNO FOR UPDATE;
    CURSOR C_RCCD IS
      SELECT *
        FROM RECCZDT T
       WHERE T.RCDNO = P_BILLNO
         AND T.RCDFLASHFLAG = 'N'
         AND NVL(RCIFSUBMIT, 'N') = 'Y'
       ORDER BY T.RCDROWNO
         FOR UPDATE;
    CURSOR C_RLDE(VRLID IN VARCHAR2) IS
      SELECT * FROM RECLIST T WHERE T.RLID = VRLID FOR UPDATE;
    
    TYPE TYPE_RLID IS TABLE OF pbparmtemp%rowtype INDEX BY BINARY_INTEGER;
    --TYPE TYPE_RLID IS VARRAY(2) OF VARCHAR2(100);
    LLCOUNT NUMBER(10) := 0;
    RCCH RECCZHD%ROWTYPE;
    RCCD RECCZDT%ROWTYPE;
    RLDE RECLIST%ROWTYPE;
    RLCR RECLIST%ROWTYPE;
    V_COUNT NUMBER(10);
    IFINMR   VARCHAR2(1);
    
    V_ISBCNO VARCHAR2(50); --��Ʊ����
    V_ISNO   VARCHAR2(50); --��Ʊ����
    V_CODE   VARCHAR2(50);
    V_ERRMSG VARCHAR2(50);
    TYPE_RLID1 TYPE_RLID;
    VC1        VARCHAR2(100);
    VC2        VARCHAR2(100);

  BEGIN
    --����״̬У��
   
    --   ��鵥�Ƿ������
    OPEN C_RCCH;
    FETCH C_RCCH
      INTO RCCH;
    IF C_RCCH%NOTFOUND OR C_RCCH%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ�����');
    END IF;
    IF RCCH.RCHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���������');
    END IF;
    IF RCCH.RCHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '������ȡ��');
    END IF;

    --�α���������¼
    OPEN C_RCCD;
    LOOP
      FETCH C_RCCD
        INTO RCCD;
      EXIT WHEN C_RCCD%NOTFOUND OR C_RCCD%NOTFOUND IS NULL;
      IF RCCD.RCDFLASHFLAG <> 'N' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���ݺ�' || RCCD.RCDNO || '�к�' ||
                                RCCD.RCDROWNO || '������ϸ����δ���־');
      END IF;
      IF RCCD.RCDRLID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���ݺ�' || RCCD.RCDNO || '�к�' ||
                                RCCD.RCDROWNO || 'Ӧ����ˮΪ��');
      END IF;

      --ȡ��Ӧ��
      RLDE := NULL;
      OPEN C_RLDE(RCCD.RCDRLID);
      LOOP
        FETCH C_RLDE
          INTO RLDE;
        EXIT WHEN C_RLDE%NOTFOUND OR C_RLDE%NOTFOUND IS NULL;
        NULL;
      END LOOP;
      CLOSE C_RLDE;

      --�����ᣬֱ��·��
      --���ѻ�����������
      --�������������
      --��û����˵���ϸ�������
      IF RLDE.RLID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���ݺ�' || RCCD.RCDNO || '�к�' ||
                                RCCD.RCDROWNO || 'Ӧ����ϸΪ��');
      END IF;
      IF RLDE.RLID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'Ӧ��' || RLDE.RLID || '������');
      END IF;
    /*  IF RLDE.RLOUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                'Ӧ��' || RLDE.RLID || '�ѿ�Ʊ����');
      END IF;*/
      IF RLDE.RLREVERSEFLAG <> 'N' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'Ӧ��' || RLDE.RLID || '�Ѿ�������');
      END IF;
      IF RLDE.RLPAIDFLAG <> 'N' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,'Ӧ��' || RLDE.RLID || '����Ƿ��״̬��״̬��־Ϊ' ||RLDE.RLPAIDFLAG);
      END IF;
      IF RLDE.RLCD <> 'DE' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'Ӧ��' || RLDE.RLID || '�������ʣ�');
      END IF;

/*      IF RLDE.RLJE <= 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                'Ӧ��' || RLDE.RLID || 'Ӧ���ʽ��Ӧ�ô����㣡');
      END IF;*/
      --20140522 Ӧ�ճ����������0���
      IF RLDE.RLJE < 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                'Ӧ��' || RLDE.RLID || 'Ӧ���ʽ��Ӧ�ô��ڵ����㣡');
      END IF; 
      
      IF RLDE.RLPAIDJE > 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                'Ӧ��' || RLDE.RLID || '�Ѳ������ʲ��ܳ���');
      END IF;
      LLCOUNT := LLCOUNT + 1;
      
      --���ò��븺Ӧ�գ���������Ӧ��
      SP_RECCZ_INSERT_01(RCCH, --RECCZHT �б���
                         RCCD, --RECCZDT �б���
                         RLDE, --reclist Ӧ��
                         RLCR, --reclist Ӧ��
                         'V', --Ӧ������
                         P_PER, --�����
                         P_MEMO, --��ע
                         'N' --�Ƿ��ύ��־
                         );
      --TYPE_RLID1(LLCOUNT).c1 := RLDE.Rlid;
      --������Ӧ�մ�ӡԭ���룬ʵ�ճ����������Ʊ
      TYPE_RLID1(LLCOUNT).c1 := RLDE.Rlscrrlid;
      TYPE_RLID1(LLCOUNT).c2 := RLCR.Rlid;
      --T_RLID_INFO_VARRAY1  := T_RLID_INFO_VARRAY(T_RLID_VARRAY(RLDE,RLCR));
      --T_RLID_INFO_VARRAY
/*      --ֹ�봦��
      
      IF RCCD.RCDRCODEFLAG = 'Y' THEN
        UPDATE METERINFO
        --set mircode = rccd.rcdecodechar,mircodechar=rccd.rcdecodechar  rcdscode
           SET MIRCODE = RCCD.RCDSCODECHAR, MIRCODECHAR = RCCD.RCDSCODECHAR
         WHERE MIID = RCCD.RCDMID;
      END IF;
      
      --�嵱��������ѱ�־,���ҵ��³����������˵ġ����������� 20140523
      SELECT COUNT(*) 
             INTO IFINMR 
      FROM METERREAD 
      WHERE MRID=RCCD.RCDMRID ;
      IF IFINMR=1 THEN
        UPDATE METERREAD 
        SET MRIFSUBMIT='N',
            MRIFREC ='N',
            MRIFYSCZ='Y' 
        WHERE MRID=RCCD.RCDMRID; 
      END IF;

      --�ٴθ������ˮ��
      UPDATE METERINFO
         SET MIRECDATE = RCCD.RCDRDATE,  --���ڳ���ˮ�� =Ӧ���˳�������
             MIRECSL   = RCCD.RCDSL + RCCD.RCDADJSL  --���ڳ���ˮ�� =����ˮ��+����ˮ��
       WHERE MIID = RCCD.RCDMID
         AND (MIRECDATE <= RCCD.RCDRDATE OR MIRECDATE IS NULL);
      IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
        NULL;
      END IF;*/  
      -- modify 20140621 ��������Ϊ֮ǰ��.
         IF RCCD.RCDRCODEFLAG = 'Y' THEN  --Ӧ�ճ����д��� ���ó������ʱ
            UPDATE METERINFO
               SET MIRCODE     = RCCD.RCDSCODECHAR,
                   MIRCODECHAR = RCCD.RCDSCODECHAR 
             WHERE MIID = RCCD.RCDMID;
                 
             IF ( RLDE.RLTRANS ='1' or RLDE.RLTRANS ='O' ) and trim(nvl(RLDE.RLINVMEMO,'NULL')) <> '��������Ƿ��'  THEN  --Ӧ�ճ���ʱ����Ӧ������Ϊ�ƻ��ڳ���1��׷��O����³����,�������񲻸��³����
                 --������������ϻ���trim(nvl(RLDE.RLINVMEMO,'NULL')) <> '��������Ƿ��'�������������ɶ���д�볭����ʷ�⣬�����ⲿ�ݲ�����³����
                
                --Ϊʲô�ڴ˸���METERINFO ��ֻ���ڼƻ��ڳ���׷��ʱ�Ÿ��³������ڼ����ڳ���ˮ��Ϊ��
                UPDATE METERINFO
                SET   MIRECDATE   = RCCD.RCDRDATE ,   --���ڳ�������
                      MIRECSL = null    --���ڳ���ˮ��
               WHERE MIID = RCCD.RCDMID;
/*             
                  SELECT COUNT(*)
                    INTO IFINMR
                    FROM METERREAD
                   WHERE MRMCODE \* mrcid *\  = RCCD.rcdcid ;
                  IF IFINMR > 0 THEN 
                    UPDATE METERREAD
                       SET MRIFSUBMIT = 'N',
                           MRIFREC    = 'N',
                           MRIFYSCZ   = 'Y',
                           MRREADOK  ='N', --������־
                           mrscode    = RCCD.RCDSCODECHAR, --���ڳ��� 
                           mrscodechar = RCCD.RCDSCODECHAR,--���ڳ��� 
                           mrecode    = NULL , --���ڳ��� 
                           mrsl       = NULL  --����ˮ�� 
                     WHERE MRMCODE \* mrcid *\  = RCCD.rcdcid;
                  end if ;*/
                  -- 20140628��ǰ 
                               
                  SELECT COUNT(*)
                    INTO IFINMR
                    FROM METERREAD
                   WHERE MRMCODE /* mrcid */  = RCCD.rcdcid and MRIFREC ='Y' ;
                  IF IFINMR > 0 THEN   --���������¼���������£����û����ֱ��ɾ����ǰ�����,�û����½��г���¼��
                    UPDATE METERREAD
                       SET MRIFSUBMIT = 'N',
                           MRIFREC    = 'N',
                           MRIFYSCZ   = 'Y',
                           MRREADOK  ='N', --������־
                           mrscode    = RCCD.RCDSCODECHAR, --���ڳ��� 
                           mrscodechar = RCCD.RCDSCODECHAR,--���ڳ��� 
                           mrecode    = NULL , --���ڳ��� 
                           mrsl       = NULL  --����ˮ�� 
                     WHERE MRMCODE /* mrcid */  = RCCD.rcdcid;
                  else
                     delete from METERREAD  WHERE MRMCODE /* mrcid */  = RCCD.rcdcid;
                  end if ;
                  
             END IF ;
           
             --�ٴθ������ˮ��
             UPDATE METERINFO
                SET MIRECDATE = RCCD.RCDRDATE, --���ڳ������� =Ӧ���˳�������
                    MIRECSL   = RCCD.RCDSL + RCCD.RCDADJSL --���ڳ���ˮ�� =����ˮ��+����ˮ��
              WHERE MIID = RCCD.RCDMID
                AND (MIRECDATE <= RCCD.RCDRDATE OR MIRECDATE IS NULL);
              IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
                NULL;
              END IF;
          
          END IF;
      
      --�����д
      UPDATE RECCZDT T
         SET RCDRLIDCR      = RLCR.RLID, --����Ӧ����ˮ
             T.RCDFLASHDATE = SYSDATE, --���ʱ��
             T.RCDFLASHPER  = P_PER, --�����
             T.RCDFLASHFLAG = 'Y'/*, --��˱�־
             T.RCDMEMO      = P_MEMO*/
       WHERE CURRENT OF C_RCCD;

      --add 2013.01.16      ��reclist_charge_01���в�������
      SP_RECLIST_CHARGE_01(RLCR.RLID, '1');
      --add 2013.01.16

    END LOOP;
    CLOSE C_RCCD;
    --��˵�ͷ
    UPDATE RECCZHD
       SET RCHSHDATE = SYSDATE, 
       --RCHSHPER = P_PER, 
              RCHSHPER = rchcreper , 
       RCHSHFLAG = 'Y'
     WHERE CURRENT OF C_RCCH;
     --���ӷ�Ʊǰ���ͨ��
     IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
     --��ӡ��Ʊ
     LLCOUNT := 1;
     BEGIN
     FOR INT IN  LLCOUNT .. TYPE_RLID1.LAST LOOP
       VC1 := TRIM(TYPE_RLID1(LLCOUNT).C1);
       VC2 := TRIM(TYPE_RLID1(LLCOUNT).C2);
         --1���ж��Ƿ��ѿ�Ʊ,����Ϊ������Ʊ
         SELECT COUNT(*) INTO V_COUNT
      FROM INVSTOCK_SP IT, INV_INFO_SP II
     WHERE IT.ISID = II.ISID
       AND IT.ISTYPE = 'P'
       AND IT.ISSTATUS = '1'
       --AND ii.status = '0'
       AND RLID = trim(VC1);
       IF V_COUNT > 0 THEN
          SELECT ISBCNO,ISNO INTO V_ISBCNO,V_ISNO
         FROM INVSTOCK_SP IT, INV_INFO_SP II
             WHERE IT.ISID = II.ISID AND
                   RLID=VC1;
          --2����ӡ���Ӹ�Ʊ
          PG_EWIDE_EINVOICE.P_CANCEL_HRB(V_ISBCNO,V_ISNO,VC2,V_CODE,V_ERRMSG);
          --PG_EWIDE_EINVOICE.P_CANCEL(V_ISBCNO,V_ISNO,V_CODE,V_ERRMSG);
          if V_CODE = '0000' then
             pg_ewide_invmanage_sp.sp_invmang_modifystatus('P',
                                                V_ISNO,
                                                V_ISNO,
                                                V_ISBCNO,
                                                rcch.rchshper,
                                                2,
                                                'Ӧ�ճ�����Ʊ����',
                                                V_ERRMSG);
          end if;
       END IF;
         LLCOUNT := LLCOUNT +1;
     END LOOP;
     EXCEPTION
     WHEN OTHERS THEN
          NULL;
     END;
     
    CLOSE C_RCCH;
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_BILLNO);
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_RCCH%ISOPEN THEN
        CLOSE C_RCCH;
      END IF;
      IF C_RCCD%ISOPEN THEN
        CLOSE C_RCCD;
      END IF;
      IF C_RLDE%ISOPEN THEN
        CLOSE C_RLDE;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --���뵥��Ӧ��   �� Ӧ�ճ�������  ��sp_reccz_one_01��   ���ʹ��    BY WANGYONG DATE 20111014
  PROCEDURE SP_RECCZ_INSERT_01(RCCH     IN RECCZHD%ROWTYPE, --RECCZHT �б���
                               RCCD     IN RECCZDT%ROWTYPE, --RECCZDT �б���
                               RLDE     IN OUT RECLIST%ROWTYPE, --reclist Ӧ��
                               RLCR     IN OUT RECLIST%ROWTYPE, --reclist Ӧ��
                               P_TRANS  IN RECLIST.RLTRANS%TYPE, --Ӧ������
                               P_PER    IN VARCHAR2, --�����
                               P_MEMO   IN VARCHAR2, --��ע
                               P_COMMIT IN VARCHAR --�Ƿ��ύ��־
                               ) AS

    VRDPAIDFLAG VARCHAR2(4000);

    RD    RECDETAIL%ROWTYPE;
    RDCR  RECDETAIL%ROWTYPE;
    RDTAB PG_EWIDE_METERREAD_01.RD_TABLE;
    V_ISBCNO    VARCHAR2(32);
    V_ISNO      VARCHAR2(12);
    o_errmsg    VARCHAR2(1000);
    O_CODE      VARCHAR2(100);
    V_sqlrow    number;
    CURSOR C_RD IS
      SELECT *
        FROM RECDETAIL
       WHERE RDID = RLDE.RLID
         AND RDPAIDFLAG = 'N'
         FOR UPDATE NOWAIT;

  BEGIN

    --������Ӧ�ղ�����Ӧ�ĸ���
    RLCR := RLDE;

    --����ͷ��ֵ
    /*    RLCR.RLSCRRLID    := RLCR.RLID;
    RLCR.RLSCRRLTRANS := RLCR.RLTRANS;
    RLCR.RLSCRRLMONTH := RLCR.RLMONTH;
    RLCR.RLSCRRLDATE  := RLCR.RLDATE;*/
    RLCR.RLCOLUMN5  := RLCR.RLDATE; --�ϴ�Ӧ��������
    RLCR.RLCOLUMN9  := RLCR.RLID; --�ϴ�Ӧ������ˮ
    RLCR.RLCOLUMN10 := RLCR.RLMONTH; --�ϴ�Ӧ�����·�
    RLCR.RLCOLUMN11 := RLCR.RLTRANS; --�ϴ�Ӧ��������

    RLCR.RLID       := FGETSEQUENCE('RECLIST');
    RLCR.RLMONTH    := TOOLS.FGETRECMONTH(RLCR.RLSMFID);
    RLCR.RLDATE     := TOOLS.FGETRECDATE(RLCR.RLSMFID);
    RLCR.RLCD       := PG_EWIDE_METERREAD_01.CREDIT;
    if RLCR.RLTRANS ='1' then --modify hb 20140625 ֻ�������ĳ���Ӧ������'1'�����������дV������дԭӦ������ ����׷�ɡ�������ʱˮ�ѡ�����
      RLCR.RLTRANS    := P_TRANS;
    end if ;
    RLCR.RLDATETIME := SYSDATE;
    RLCR.RLPAIDFLAG := 'N';
    --
    RLCR.RLSL     := 0 - RLCR.RLSL;
    RLCR.RLJE     := 0 - RLCR.RLJE;
    RLCR.RLADDSL  := 0 - RLCR.RLADDSL;
    RLCR.RLPAIDJE := 0 - RLCR.RLPAIDJE;
    --����
    RLCR.RLSAVINGQC := 0 - RLCR.RLSAVINGQC;
    RLCR.RLSAVINGBQ := 0 - RLCR.RLSAVINGBQ;
    RLCR.RLSAVINGQM := 0 - RLCR.RLSAVINGQM;
    RLCR.RLSXF      := 0 - RLCR.RLSXF;

    RLCR.RLMEMO        := P_MEMO;
    RLCR.RLREVERSEFLAG := 'Y';

    --�����帳ֵ,ͬʱ���´���Ŀ��Ӧ����ϸ���ʱ�־
    OPEN C_RD;
    LOOP
      FETCH C_RD
        INTO RD;
      /*if c_rd%notfound or c_rd%notfound is null then
        raise_application_error(errcode,
                                  '��Ч�Ĵ�����Ӧ�ռ�¼���޴�Ӧ�շ�����ϸ');
      end if;*/
      EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;

      RDCR.RDID := NULL;

      RDCR.RDID         := RLCR.RLID;
      RDCR.RDPMDID      := RD.RDPMDID;
      RDCR.RDPFID       := RD.RDPFID;
      RDCR.RDPIID       := RD.RDPIID;
      RDCR.RDPSCID      := RD.RDPSCID;
      RDCR.RDCLASS      := RD.RDCLASS;
      RDCR.RDYSDJ       := RD.RDYSDJ;
      RDCR.RDDJ         := RD.RDDJ;
      RDCR.RDADJDJ      := RD.RDADJDJ;
      RDCR.RDYSSL       := 0 - RD.RDYSSL;
      RDCR.RDYSJE       := 0 - RD.RDYSJE;
      RDCR.RDSL         := 0 - RD.RDSL;
      RDCR.RDJE         := 0 - RD.RDJE;
      RDCR.RDADJSL      := 0 - RD.RDADJSL;
      RDCR.RDADJJE      := 0 - RD.RDADJJE;
      RDCR.RDZNJ        := 0 - RD.RDZNJ;
      RDCR.RDMETHOD     := RD.RDMETHOD;
      RDCR.RDPAIDFLAG   := RD.RDPAIDFLAG;
      RDCR.RDPAIDDATE   := RD.RDPAIDDATE;
      RDCR.RDPAIDMONTH  := RD.RDPAIDMONTH;
      RDCR.RDILID       := RD.RDILID;
      RDCR.RDMONTH      := RLCR.RLMONTH;
      RDCR.RDPMDSCALE   := RD.RDPMDSCALE;
      RDCR.RDPAIDPER    := RD.RDPAIDPER;
      RDCR.RDMEMO       := RD.RDMEMO;
      RDCR.RDPMDTYPE    := RD.RDPMDTYPE;
      RDCR.RDMID        := RD.RDMID;
      RDCR.RDPMDTYPE    := RD.RDPMDTYPE;
      RDCR.RDPMDCOLUMN1 := RD.RDPMDCOLUMN1;
      RDCR.RDPMDCOLUMN2 := RD.RDPMDCOLUMN2;
      RDCR.RDPMDCOLUMN3 := RD.RDPMDCOLUMN3;

      INSERT INTO RECDETAIL VALUES RDCR;

    END LOOP;
    CLOSE C_RD;
    --�������ͷ������
    INSERT INTO RECLIST VALUES RLCR;
    V_sqlrow := sql%rowcount;

    /*  --�����¼Ӧ����ͷ��־
    select connstr(rdpaidflag)
      into vrdpaidflag
      from recdetail
     where rdid = rlcr.rlscrrlid;
    --��ʽ�����ʱ�־(Y:Y��N:N��X:X��V:Y/N��T:Y/X��K:N/X��W:Y/N/X)
    vrdpaidflag := (case when instr(vrdpaidflag, 'Y') > 0 then 'Y' else null end) || (case when instr(vrdpaidflag, 'N') > 0 then 'N' else null end) || (case when instr(vrdpaidflag, 'X') > 0 then 'X' else null end);
    if vrdpaidflag = 'X' then
      rlcr.rlpaidflag := 'X';
    elsif vrdpaidflag = 'YX' then
      rlcr.rlpaidflag := 'T';
    elsif vrdpaidflag = 'NX' then
      rlcr.rlpaidflag := 'K';
    elsif vrdpaidflag = 'YNX' then
      rlcr.rlpaidflag := 'W';
    else
      raise_application_error(errcode, '���ʱ�־�쳣');
    end if;*/

    RLDE.RLPAIDFLAG    := RLCR.RLPAIDFLAG;
    RLDE.RLPAIDDATE    := RLCR.RLDATE;
    RLDE.RLPAIDPER     := P_PER;
    RLDE.RLPAIDJE      := RLDE.RLPAIDJE + RLCR.RLJE;
    RLDE.RLREVERSEFLAG := RLCR.RLREVERSEFLAG;
    --���±��Դ��
    UPDATE RECLIST
       SET RLPAIDFLAG    = RLCR.RLPAIDFLAG,
           RLPAIDDATE    = RLCR.RLDATE,
           RLPAIDPER     = P_PER,
           RLREVERSEFLAG = RLDE.RLREVERSEFLAG
     WHERE RLID = RLDE.RLID;

    --�������ˮ��(���������ǡ�����ʱ)
    UPDATE METERINFO
       SET MIRECSL = 0
     WHERE MIID = RLCR.RLMID
       AND MIRECDATE = RLCR.RLRDATE;
    IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
      NULL;
    END IF;


    /*SELECT MAX(isp.isbcno),MAX(isp.isno) INTO V_ISBCNO,V_ISNO
          FROM INV_EINVOICE_ST IE, INV_INFO_SP II,INVSTOCK_SP isp
         WHERE IE.ID = II.ID and ii.isid = isp.isid  and isp.isstatus = '1'
           and (II.MICODE = RLDE.RLMID AND ii.rlid = RLDE.RLID)
           AND II.ISID IS not NULL;
    IF V_ISBCNO IS NOT NULL AND V_ISNO IS NOT NULL THEN
    insert into pbparmtemp_sms(c1,c2) values (rcch.rchcreper,rcch.rchcreper);
    pg_ewide_einvoice.p_cancel(V_ISBCNO,
                             V_ISNO,
                             o_code,
                             o_errmsg);
      if o_code = '0000' then
        pg_ewide_invmanage_sp.sp_invmang_modifystatus('P',
                                                V_ISNO,
                                                V_ISNO,
                                                V_ISBCNO,
                                                rcch.rchshper,
                                                2,
                                                'Ӧ�ճ�����Ʊ����',
                                                o_errmsg);
      end if;
    END IF;*/

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;



   --���뵥��Ӧ��   �� Ӧ�ճ�������  ��sp_reccz_one_01��   ���ʹ��    BY WANGYONG DATE 20111014
  PROCEDURE SP_RECCZ_ONE_01(P_RLID     IN RECLIST.RLID%TYPE, --RECCZHT �б���
                               P_COMMIT IN VARCHAR --�Ƿ��ύ��־
                               ) AS

    VRDPAIDFLAG VARCHAR2(4000);
    RDTAB PG_EWIDE_METERREAD_01.RD_TABLE;
    RLDE      RECLIST%ROWTYPE;
    RLCR      RECLIST%ROWTYPE;
    RD        RECDETAIL%ROWTYPE;
    RDCR      RECDETAIL%ROWTYPE;
    V_COUNT   NUMBER(10);
    V_ISBCNO  VARCHAR2(100);
    V_ISNO    VARCHAR2(100);
    V_CODE    VARCHAR2(100);
    V_ERRMSG  VARCHAR2(4000);
    CURSOR C_RL IS
      SELECT *
        FROM RECLIST
       WHERE RLID=P_RLID AND
             RLPAIDFLAG='N' AND
             rlreverseflag='N' AND
             rlbadflag='N'
             FOR UPDATE NOWAIT;

    CURSOR C_RD IS
      SELECT *
        FROM RECDETAIL
       WHERE RDID = RLDE.RLID
         AND RDPAIDFLAG = 'N'
         FOR UPDATE NOWAIT;


  BEGIN
    OPEN C_RL;
      FETCH C_RL
        INTO RLDE;
      IF C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'Ӧ�����񲻴���,��������Ƿ��,��ˮ��:'||P_RLID||'���飡');
      END IF;
    CLOSE C_RL;
    --������Ӧ�ղ�����Ӧ�ĸ���
    RLCR := RLDE;

    --����ͷ��ֵ
    /*RLCR.RLSCRRLID    := RLCR.RLID;
    RLCR.RLSCRRLTRANS := RLCR.RLTRANS;
    RLCR.RLSCRRLMONTH := RLCR.RLMONTH;
    RLCR.RLSCRRLDATE  := RLCR.RLDATE;*/
    RLCR.RLCOLUMN5  := RLCR.RLDATE; --�ϴ�Ӧ��������
    RLCR.RLCOLUMN9  := RLCR.RLID; --�ϴ�Ӧ������ˮ
    RLCR.RLCOLUMN10 := RLCR.RLMONTH; --�ϴ�Ӧ�����·�
    RLCR.RLCOLUMN11 := RLCR.RLTRANS; --�ϴ�Ӧ��������

    RLCR.RLID       := FGETSEQUENCE('RECLIST');
    RLCR.RLMONTH    := TOOLS.FGETRECMONTH(RLCR.RLSMFID);
    RLCR.RLDATE     := TOOLS.FGETRECDATE(RLCR.RLSMFID);
    RLCR.RLCD       := PG_EWIDE_METERREAD_01.CREDIT;
    RLCR.RLTRANS    := RLDE.RLTRANS;
    RLCR.RLDATETIME := SYSDATE;
    RLCR.RLPAIDFLAG := 'N';
    --
    RLCR.RLSL     := 0 - RLCR.RLSL;
    RLCR.RLJE     := 0 - RLCR.RLJE;
    RLCR.RLADDSL  := 0 - RLCR.RLADDSL;
    RLCR.RLPAIDJE := 0 - RLCR.RLPAIDJE;
    --����
    RLCR.RLSAVINGQC := 0 - RLCR.RLSAVINGQC;
    RLCR.RLSAVINGBQ := 0 - RLCR.RLSAVINGBQ;
    RLCR.RLSAVINGQM := 0 - RLCR.RLSAVINGQM;
    RLCR.RLSXF      := 0 - RLCR.RLSXF;

    RLCR.RLMEMO        := RLDE.RLMEMO;
    RLCR.RLREVERSEFLAG := 'Y';


    --�����帳ֵ,ͬʱ���´���Ŀ��Ӧ����ϸ���ʱ�־
    OPEN C_RD;
    LOOP
      FETCH C_RD
        INTO RD;
      /*if c_rd%notfound or c_rd%notfound is null then
        raise_application_error(errcode,
                                  '��Ч�Ĵ�����Ӧ�ռ�¼���޴�Ӧ�շ�����ϸ');
      end if;*/
      EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;

      RDCR.RDID := NULL;

      RDCR.RDID         := RLCR.RLID;
      RDCR.RDPMDID      := RD.RDPMDID;
      RDCR.RDPFID       := RD.RDPFID;
      RDCR.RDPIID       := RD.RDPIID;
      RDCR.RDPSCID      := RD.RDPSCID;
      RDCR.RDCLASS      := RD.RDCLASS;
      RDCR.RDYSDJ       := RD.RDYSDJ;
      RDCR.RDDJ         := RD.RDDJ;
      RDCR.RDADJDJ      := RD.RDADJDJ;
      RDCR.RDYSSL       := 0 - RD.RDYSSL;
      RDCR.RDYSJE       := 0 - RD.RDYSJE;
      RDCR.RDSL         := 0 - RD.RDSL;
      RDCR.RDJE         := 0 - RD.RDJE;
      RDCR.RDADJSL      := 0 - RD.RDADJSL;
      RDCR.RDADJJE      := 0 - RD.RDADJJE;
      RDCR.RDZNJ        := 0 - RD.RDZNJ;
      RDCR.RDMETHOD     := RD.RDMETHOD;
      RDCR.RDPAIDFLAG   := RD.RDPAIDFLAG;
      RDCR.RDPAIDDATE   := RD.RDPAIDDATE;
      RDCR.RDPAIDMONTH  := RD.RDPAIDMONTH;
      RDCR.RDILID       := RD.RDILID;
      RDCR.RDMONTH      := RLCR.RLMONTH;
      RDCR.RDPMDSCALE   := RD.RDPMDSCALE;
      RDCR.RDPAIDPER    := RD.RDPAIDPER;
      RDCR.RDMEMO       := RD.RDMEMO;
      RDCR.RDPMDTYPE    := RD.RDPMDTYPE;
      RDCR.RDMID        := RD.RDMID;
      RDCR.RDPMDTYPE    := RD.RDPMDTYPE;
      RDCR.RDPMDCOLUMN1 := RD.RDPMDCOLUMN1;
      RDCR.RDPMDCOLUMN2 := RD.RDPMDCOLUMN2;
      RDCR.RDPMDCOLUMN3 := RD.RDPMDCOLUMN3;

      INSERT INTO RECDETAIL VALUES RDCR;

    END LOOP;
    CLOSE C_RD;
    --�������ͷ������
    INSERT INTO RECLIST VALUES RLCR;

    /*  --�����¼Ӧ����ͷ��־
    select connstr(rdpaidflag)
      into vrdpaidflag
      from recdetail
     where rdid = rlcr.rlscrrlid;
    --��ʽ�����ʱ�־(Y:Y��N:N��X:X��V:Y/N��T:Y/X��K:N/X��W:Y/N/X)
    vrdpaidflag := (case when instr(vrdpaidflag, 'Y') > 0 then 'Y' else null end) || (case when instr(vrdpaidflag, 'N') > 0 then 'N' else null end) || (case when instr(vrdpaidflag, 'X') > 0 then 'X' else null end);
    if vrdpaidflag = 'X' then
      rlcr.rlpaidflag := 'X';
    elsif vrdpaidflag = 'YX' then
      rlcr.rlpaidflag := 'T';
    elsif vrdpaidflag = 'NX' then
      rlcr.rlpaidflag := 'K';
    elsif vrdpaidflag = 'YNX' then
      rlcr.rlpaidflag := 'W';
    else
      raise_application_error(errcode, '���ʱ�־�쳣');
    end if;*/




    --�������ˮ��(���������ǡ�����ʱ)
    UPDATE RECLIST
    SET RLREVERSEFLAG='Y'
    WHERE RLID=P_RLID;
    --�ų����˵�
    IF RLDE.RLTRANS<>'3' THEN
       UPDATE METERINFO
         SET MIRECSL = 0
       WHERE MIID = RLCR.RLMID
         AND MIRECDATE = RLCR.RLRDATE;
      IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
        NULL;
      END IF;
    END IF;

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
     --1���ж��Ƿ��ѿ�Ʊ,����Ϊ������Ʊ
         SELECT COUNT(*) INTO V_COUNT
      FROM INVSTOCK_SP IT, INV_INFO_SP II
     WHERE IT.ISID = II.ISID
       AND IT.ISTYPE = 'P'
       AND IT.ISSTATUS = '1'
       --AND ii.status = '0'
       AND RLID = P_RLID;
       IF V_COUNT > 0 THEN
          SELECT ISBCNO,ISNO INTO V_ISBCNO,V_ISNO
         FROM INVSTOCK_SP IT, INV_INFO_SP II
             WHERE IT.ISID = II.ISID AND
                   RLID=P_RLID;
          --2����ӡ���Ӹ�Ʊ
          --PG_EWIDE_EINVOICE.P_CANCEL_HRB(V_ISBCNO,V_ISNO,VC2,V_CODE,V_ERRMSG);
          PG_EWIDE_EINVOICE.P_CANCEL(V_ISBCNO,V_ISNO,V_CODE,V_ERRMSG);
          if V_CODE = '0000' then
             pg_ewide_invmanage_sp.sp_invmang_modifystatus('P',
                                                V_ISNO,
                                                V_ISNO,
                                                V_ISBCNO,
                                                fgetoperid,
                                                2,
                                                'Ӧ�ճ�����Ʊ����',
                                                V_ERRMSG);
          end if;
       END IF;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_RECCZ_one_01;


  --Ӧ�շ��˴��� BY sp_recfzsl by wy  20130324
  --����Ӧ����ˮ�����ʽ�
  --���ط���ˮ��
  --1��ˮ���˵��۷�
  --2�ֵ�����һ��ˮΪֹ
  --3�Ӹ�ˮ���������ˮ��Ϊ1��Ϊֹ
  --

  function sp_recfzsl(p_rlid in VARCHAR2, --������ˮ
                      p_rlje    in number --���ʽ��
                     ) return number as
  v_maxsl reclist.rlsl%type;
  v_maxje reclist.rlje%type;
  V_FZJE  reclist.rlje%type;
  v_jlje  reclist.rlje%type;
  v_jlje1  reclist.rlje%type;
  PB      PBPARMTEMP%ROWTYPE;
  v_czsl  reclist.rlsl%type;

  --���� ���÷��顢ˮ�������   Ӧ����
  v_cfz   recdetail.rdpmdid%type;
  v_csl   recdetail.rdsl%type;
  v_cje   recdetail.rdje%type;
  v_crlje recdetail.rdje%type;


  CURSOR C_RD IS
  select TO_CHAR(RDPMDID),TO_CHAR(max(nvl(rdsl,0))) rdsl,TO_CHAR(sum(nvl(rdje,0)))
      from recdetail
      where rdid=p_rlid
      GROUP BY RDPMDID
      ORDER BY RDPMDID;

  begin
    --1��ȡ��ˮ��
    /*SELECT SUM (rdsl) INTO v_maxsl FROM
    (
      select RDPMDID,max(nvl(rdsl,0)) rdsl
      from recdetail
      where rdid=p_rlid
      GROUP BY RDPMDID
    );*/
    /*
    PB ������ɽṹ
    ��ֽ��120

    A B C��ʾ��
    �к�  ����C1   ˮ��C2   ���C3  ���ˮ��C4  ��ֽ��C5 �в��ˮ����־C6��1��ʾ��Ҫ������ˮ����
    A      0        30       90       30         90          0
    B      1        50       150      10         30          1
    C      2        60       180      0          0           0
    */
    --�����ȡˮ�����
    --�ò���C5��ֽ��Ϊ�ɲ�ֽ��
    V_FZJE  := p_rlje;
    v_maxsl := 0;
    v_maxje := 0;
    OPEN C_RD;
    LOOP
      FETCH C_RD
        INTO PB.C1,
             PB.C2,
             PB.C3;
      EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;
           v_maxsl := v_maxsl + to_number(nvl(PB.C2,0));
           v_maxje := v_maxje+ to_number(nvl(PB.C3,0));
           IF V_FZJE = 0 THEN
              PB.C4  := '0';
              PB.C5  := '0';
              PB.C6  := '0';
           ELSIF V_FZJE >= to_number(nvl(PB.C3,0)) THEN
              V_FZJE := V_FZJE - to_number(nvl(PB.C3,0));
              PB.C4  := PB.C2;
              PB.C5  := PB.C3;
              PB.C6  := '0';
           ELSE
              PB.C5  := TO_CHAR(NVL(V_FZJE,0));
              PB.C6  := '1';
              V_FZJE := 0;
           END IF;
           INSERT INTO PBPARMTEMP VALUES PB;

    END LOOP;
    CLOSE C_RD;

    --��ֽ��������ڽ���������
    if p_rlje>=v_maxje or p_rlje<=0 or v_maxje<=0 or v_maxsl<=0 then
       return -1;
    end if;

    --����C6ȡ���������
    --�ò��֣�C4����ˮ��������C5���˽�ΪӦ����ˮ�������
    BEGIN
          SELECT * INTO PB FROM PBPARMTEMP WHERE TRIM(C6)='1';
          v_cfz := TO_NUMBER(TRIM(PB.C1));
          v_csl := TO_NUMBER(TRIM(PB.C2));
          v_cje := TO_NUMBER(TRIM(PB.C3));
          v_crlje := TO_NUMBER(TRIM(PB.C5));
          v_czsl  := 0;

          for i in  1..v_csl loop
              select sum(rddj)*I,sum(rddj)*(I-1) into v_jlje , v_jlje1
              from recdetail t where rdid= p_rlid and RDPMDID=v_cfz ;
              /*if v_jlje<=0 then
                return -1 ;
              end if;*/
              if v_crlje>=v_jlje then
                v_czsl := i;
              else
                exit;
              end if;
          end loop;

          UPDATE PBPARMTEMP
                SET C4=TO_CHAR(v_czsl),
                    C5=TO_CHAR(v_jlje1)
                WHERE TRIM(C1)=TO_CHAR(v_cfz) AND
                      TRIM(C6)='1';
    EXCEPTION
    WHEN OTHERS THEN
    --�������ˮ�������˽������ƥ��
    return v_maxsl;
    END;


    /*if v_maxsl<=1 then
      return -1;
    end if;
    for i in  1..v_maxsl loop
    select sum(tools.getmax(0,rdsl - i)*rddj) into v_jlje from recdetail t where rdid= p_rlid ;--'0066377182' ;
    if v_jlje<=0 then
      return -1 ;
    end if;
    if p_rlje>=v_jlje then
      return i;
    end if;
    end loop;
    return -1 ;*/
    return 1;
  exception
    when others then
     return -999 ;
  end;

  --���˹���
  PROCEDURE SP_RECFZRLID(P_RLID IN VARCHAR2,   --������ˮ
                         P_JE   IN NUMBER     --���˽��

                               ) AS

CURSOR C_RL IS
SELECT * FROM RECLIST
WHERE RLID=P_RLID AND
      rlreverseflag='N' AND
      rlbadflag='N' AND
      RLPAIDFLAG='N' AND
      RLOUTFLAG='N' AND
      RLJE>0
      FOR UPDATE;

CURSOR C_RD IS
SELECT * FROM RECDETAIL WHERE RDID=P_RLID FOR UPDATE;

CURSOR C_RDF IS
SELECT * FROM RECDETAIL_FZ WHERE RDID=P_RLID FOR UPDATE;


RL          RECLIST%ROWTYPE;
RD          RECDETAIL%ROWTYPE;
RLF         RECLIST_FZ%ROWTYPE;
RDF         RECDETAIL_FZ%ROWTYPE;
V_JE        NUMBER(12,3);
V_RLID      VARCHAR2(20);
V_RLID2      VARCHAR2(20);
V_SL2        NUMBER(10);
V_JE2        NUMBER(10,3);
V_SLS2        NUMBER(10);
V_JES2        NUMBER(10,3);
V_COUNT       NUMBER(10);
V_CZSL        NUMBER(10);
P_SL          NUMBER(10);
PB            PBPARMTEMP%ROWTYPE;
  v_scode NUMBER(10);
  v_ecode NUMBER(10);

BEGIN
  NULL;
  --1�����ù��̼��Ҫ�ֲ�ˮ��
  OPEN C_RL;
    FETCH C_RL
      INTO RL;
    IF C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'Ӧ�����񲻴���,��������Ƿ��,��ˮ��:'||P_RLID||'���飡');
    END IF;
  CLOSE C_RL;
  P_SL := sp_recfzsl(P_RLID,P_JE);

  IF P_SL<=0 THEN
     RAISE_APPLICATION_ERROR(ERRCODE, '����ˮ������С��'||RL.RLSL||',��ˮ��:'||RL.RLID);
  END IF;


  --2����Ҫ���� reclist,recdetail ���ݵ�   reclist_fz,recdetail_fz
  RLF      := RL; --����ԭ����
  INSERT INTO RECLIST_FZ VALUES RL;
  OPEN C_RD;
    LOOP
    FETCH C_RD
      INTO RD;
    EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;
         INSERT INTO recdetail_fz VALUES RD;
    END LOOP;
  CLOSE C_RD;

  --3����Ϊ���ó�������
  /*DELETE RECDETAIL WHERE RDID=P_RLID;
  DELETE RECLIST WHERE RLID=P_RLID;*/
  --4��ͨ�� reclist_fz,recdetail_fz  ��֯�÷��˵ĵ�һ���˵�Ӧ���ˣ��²���һ��Ӧ����ˮ���ٲ�����  reclist,recdetail ��

  --RECDETAIL������˵�һ��
  V_JE := 0;
  SELECT TO_CHAR(SEQ_RLID.NEXTVAL,'0000000000')INTO V_RLID FROM DUAL;
  SELECT TO_CHAR(SEQ_RLID.NEXTVAL,'0000000000')INTO V_RLID2 FROM DUAL;
  V_SL2 := 0;
  V_JE2 := 0;
  V_SLS2 := RL.Rlsl;
  V_JES2 := 0;
  OPEN C_RDF;
    LOOP
    FETCH C_RDF
      INTO RD;
    EXIT WHEN C_RDF%NOTFOUND OR C_RDF%NOTFOUND IS NULL;
         --��ȡ��ʱ���е�ˮ��
         SELECT * INTO PB FROM PBPARMTEMP P WHERE TRIM(P.C1)=RD.RDPMDID;
         P_SL                := TO_NUMBER(TRIM(PB.C4));
         V_SL2               := RD.RDSL-P_SL;  --�ڶ�����ϸˮ��
         V_JE2               := RD.RDJE;
         --��һ����ϸ

         RD.RDID         := TRIM(V_RLID);
         RD.RDYSSL           := P_SL;
         RD.RDSL             := P_SL;
         RD.RDYSJE           := RD.RDYSDJ*RD.RDYSSL;
         RD.RDJE             := RD.RDDJ*RD.RDSL;
         INSERT INTO RECDETAIL VALUES RD;      --��һ����ϸ
         V_JE   := V_JE + RD.RDJE;    --��һ��Ӧ�պϼƽ��
         V_JE2  := V_JE2 - RD.RDJE;   --�ڶ�����ϸ���
         --���ɵڶ�����ϸ
         RD.RDID         := TRIM(V_RLID2);
         RD.RDYSSL       := V_SL2;
         RD.RDSL         := V_SL2;
         RD.RDYSJE       := V_JE2;
         RD.RDJE         := V_JE2;
         INSERT INTO RECDETAIL VALUES RD;
         --V_SLS2          := V_SLS2 + RD.RDSL;
         V_JES2          := V_JES2 + RD.RDJE;
    END LOOP;
  CLOSE C_RDF;

    --20140318 ������ֹ��
  v_scode := RL.rlscode;
  v_ecode := RL.rlecode;

  --RECLIST������˵�һ��
  RL.RLID       :=   TRIM(V_RLID);
  RL.RLMONTH    :=   TOOLS.FGETRECMONTH(RL.RLSMFID);
  RL.RLDATE     :=   TOOLS.FGETRECDATE(RL.RLSMFID);
  RL.RLCOLUMN5  :=   RLF.RLDATE; --�ϴ�Ӧ��������
  RL.RLCOLUMN9  :=   RLF.RLID; --�ϴ�Ӧ������ˮ
  RL.RLCOLUMN10 :=   RLF.RLMONTH; --�ϴ�Ӧ�����·�
  RL.RLCOLUMN11 :=   RLF.RLTRANS; --�ϴ�Ӧ��������
  RL.RLTRANS    := 'C';
  /*RL.RLSCRRLID    := RLF.RLID; --ԭ����Ӧ����ˮ
  RL.RLSCRRLTRANS := RLF.RLTRANS; --ԭ��������
  RL.RLSCRRLMONTH := RLF.RLMONTH; --ԭ�����·�
  RL.RLSCRRLDATE  := RLF.RLDATE;  --ԭ��������*/
  SELECT SUM(TO_NUMBER(NVL(TRIM(C4),0))) INTO V_CZSL FROM PBPARMTEMP;
  RL.RLSL       :=   V_CZSL;
  RL.RLJE       :=   V_JE;
  RL.RLREADSL   :=   V_CZSL;

    --��һ�������벻�䣬ֹ��Ϊ�������Ӧ��ˮ�� 20140318
  RL.rlscode      :=v_scode;
  RL.rlscodechar  := to_char(RL.rlscode);
  RL.rlecode     := v_scode + RL.RLSL;
  RL.rlecodechar := to_char(RL.rlecode);
  INSERT INTO RECLIST VALUES RL;


  --RECLIST������˵ڶ���
  RL.RLID       :=   TRIM(V_RLID2);
  RL.RLSL       :=   V_SLS2 - V_CZSL;
  RL.RLJE       :=   V_JES2;
  RL.RLREADSL   :=   V_SLS2 - V_CZSL;

    --�ڶ�����ֹ�벻�䣬����Ϊֹ���ȥӦ��ˮ�� 20140318
  RL.rlscode      := v_ecode - RL.RLSL;
  RL.rlscodechar  := to_char(RL.rlscode);
  RL.rlecode     := v_ecode;
  RL.rlecodechar := to_char(RL.rlecode);

  INSERT INTO RECLIST VALUES RL;

  --5�����һ�·ֲ�����Ӧ�պ�ˮ������������ԭ�� reclist_fz,recdetail_fz �Ƿ���ͬ
  --SELECT * INTO RLF FROM RECLIST_FZ WHERE
  SELECT COUNT(*) INTO V_COUNT FROM (
  SELECT RLSL,RLJE FROM RECLIST_FZ WHERE RLID=P_RLID
  MINUS
  SELECT SUM(RLSL),SUM(RLJE) FROM RECLIST WHERE RLID IN (TRIM(V_RLID),TRIM(V_RLID2))
  );
  IF V_COUNT>0 THEN
     RAISE_APPLICATION_ERROR(ERRCODE, '�����ܽ�����');
  END IF;

  SELECT COUNT(*) INTO V_COUNT FROM (
  SELECT RDSL,RDJE
  FROM RECDETAIL_FZ
  WHERE RDID=P_RLID
  MINUS
  SELECT SUM(RDSL),SUM(RDJE)
  FROM RECDETAIL
  WHERE RDID IN (TRIM(V_RLID),TRIM(V_RLID2))
  GROUP BY rdpmdid,
           rdpiid ,
           rdpfid ,
           RDCLASS
  );

  IF V_COUNT>0 THEN
     RAISE_APPLICATION_ERROR(ERRCODE, '������ϸ������');
  END IF;

  --5��ԭӦ����
  SP_RECCZ_ONE_01(P_RLID,'N');




  --O_RET := 'Y';
EXCEPTION
  WHEN OTHERS THEN
    IF C_RD%ISOPEN THEN
           CLOSE C_RD;
    END IF;
    IF C_RDF%ISOPEN THEN
           CLOSE C_RDF;
    END IF;
    ROLLBACK;
    --O_RET :='N';
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END SP_RECFZRLID;

--�����˷�
  --1�������ʣ���ʵ�գ��˿ +��Ӧ�� +��Ӧ�� +��Ӧ��
  --2��δ���ʣ���Ӧ�� +��Ӧ��
  PROCEDURE SP_PAIDRECBACK(P_NO IN VARCHAR2, P_PER IN VARCHAR2) AS
    CURSOR C_RAH IS
      SELECT * FROM RECADJUSTHD WHERE RAHNO = P_NO FOR UPDATE;

    CURSOR C_RAD IS
      SELECT *
        FROM RECADJUSTDT
       WHERE RADNO = P_NO
         AND RADCHKFLAG = 'Y'
       ORDER BY RADROWNO
         FOR UPDATE;

    RAH        RECADJUSTHD%ROWTYPE;
    RAD        RECADJUSTDT%ROWTYPE;
    RLDE       RECLIST%ROWTYPE;
    RLCR       RECLIST%ROWTYPE;
    VPIIDLIST  VARCHAR2(100);
    VPIIDLIST2 VARCHAR2(100);
  BEGIN
    --����״̬У��
    OPEN C_RAH;
    FETCH C_RAH
      INTO RAH;
    IF C_RAH%NOTFOUND OR C_RAH%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ�����');
    END IF;
    IF RAH.RAHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���������');
    END IF;
    IF RAH.RAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '������ȡ��');
    END IF;
    --�α���������¼
    OPEN C_RAD;
    LOOP
      FETCH C_RAD
        INTO RAD;
      EXIT WHEN C_RAD%NOTFOUND OR C_RAD%NOTFOUND IS NULL;
      IF RAD.RADRLID IS NOT NULL THEN
        --֧�ַ�������������翼�˱�����������ݣ�

        --Ӧ�յ���(��Ӧ�� +��Ӧ��)
        RECADJUST(RAH, RAD, P_PER, RLCR, RLDE);
        RAD.RADRLIDCR := RLCR.RLID;
        RAD.RADRLIDDE := RLDE.RLID;

      END IF;
      --ֹ�봦��
      IF RAD.RADRCODEFLAG = 'Y' THEN
        UPDATE METERINFO
           SET MIRCODE     = TO_NUMBER(RAD.RADECODECHAR),
               MIRCODECHAR = RAD.RADECODECHAR
         WHERE MIID = RAD.RADMID;
      END IF;
      --�ٴθ��³����Ӧ��¼
      UPDATE METERREAD
         SET MRRECSL     = RAD.RADSL + RAD.RADADJSL,
             MRRDATE     = RAD.RADRDATE,
             MRECODE     = TO_NUMBER(RAD.RADECODECHAR),
             MRECODECHAR = RAD.RADECODECHAR
       WHERE MRID = RAD.RADMRID;
      IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
        UPDATE METERREADHIS
           SET MRRECSL = RAD.RADSL + RAD.RADADJSL, MRRDATE = RAD.RADRDATE
         WHERE MRID = RAD.RADMRID;
        IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
          NULL;
          --raise_application_error(errcode, '���³����¼����');
        END IF;
      END IF;
      RAD.RADMRIDCR := RAD.RADMRID;
      RAD.RADMRIDDE := RAD.RADMRID;

      --�ٴθ������ˮ��
      UPDATE METERINFO
         SET MIRECDATE = RAD.RADRDATE, MIRECSL = RAD.RADSL + RAD.RADADJSL
       WHERE MIID = RAD.RADMID
         AND (MIRECDATE <= RAD.RADRDATE OR MIRECDATE IS NULL);
      IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
        NULL;
      END IF;

      --�����д
      UPDATE RECADJUSTDT
         SET RADPLID   = RAD.RADPLID, --����������ˮ
             RADPLIDCR = RAD.RADPLIDCR, --����������ˮ
             RADRLIDCR = RAD.RADRLIDCR, --����Ӧ����ˮ
             RADRLIDDE = RAD.RADRLIDDE, --��Ӧ����ˮ
             RADPLIDDE = RAD.RADPLIDDE, --��������ˮ
             RADILIDCR = RAD.RADILIDCR,
             RADILIDDE = RAD.RADILIDDE,
             RADMRIDCR = RAD.RADMRIDCR,
             RADMRIDDE = RAD.RADMRIDDE
       WHERE CURRENT OF C_RAD;
    END LOOP;
    CLOSE C_RAD;
    --��˵�ͷ
    UPDATE RECADJUSTHD
       SET RAHSHDATE = CURRENTDATE,
       RAHSHPER = P_PER,
   --  RAHSHPER =rahcreper  ,
        RAHSHFLAG = 'Y'
     WHERE CURRENT OF C_RAH;
    CLOSE C_RAH;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;



--Ӧ�յ�����׷��/׷����
  PROCEDURE RECADJUST(RAH   IN RECADJUSTHD%ROWTYPE,
                      RAD   IN RECADJUSTDT%ROWTYPE,
                      P_PER IN VARCHAR2,
                      RLCR  OUT RECLIST%ROWTYPE,
                      RLDE  OUT RECLIST%ROWTYPE) AS
    CURSOR C_CI(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;

    CURSOR C_MI(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID FOR UPDATE NOWAIT;

    CURSOR C_MD(VMID IN VARCHAR2) IS
      SELECT * FROM METERDOC WHERE MDMID = VMID;

    CURSOR C_MA(VMID IN VARCHAR2) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMID;

    CURSOR C_RADD IS
      SELECT *
        FROM RECADJUSTDDT
       WHERE RADDNO = RAD.RADNO
         AND RADDROWNO = RAD.RADROWNO
      --  AND RADDCHKFLAG = 'Y'
       ORDER BY RADDROWNO2
         FOR UPDATE;

    RL          RECLIST%ROWTYPE;
    CI          CUSTINFO%ROWTYPE;
    MI          METERINFO%ROWTYPE;
    MD          METERDOC%ROWTYPE;
    MA          METERACCOUNT%ROWTYPE;
    RADD        RECADJUSTDDT%ROWTYPE;
    RDDE        RECDETAIL%ROWTYPE;
    VRDPIIDLIST VARCHAR2(100);
    RDTAB       PG_EWIDE_METERREAD_01.RD_TABLE;
  BEGIN
    OPEN C_CI(RAD.RADCID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�޴��û�');
    END IF;
    CLOSE C_CI;

    OPEN C_MI(RAD.RADMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�޴�ˮ��');
    END IF;

    OPEN C_MD(RAD.RADMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�޴�ˮ����');
    END IF;
    CLOSE C_MD;

    OPEN C_MA(RAD.RADMID);
    FETCH C_MA
      INTO MA;
    IF C_MA%NOTFOUND OR C_MA%NOTFOUND IS NULL THEN
      --raise_application_error(errcode,'�޴�ˮ������');
      NULL;
    END IF;
    CLOSE C_MA;
    --��ѯ���������Ա�׷����������
    SELECT * INTO RL FROM RECLIST T WHERE T.RLID = RAD.RADRLID;

    --���ʴ���,��¼ԭ��˵�������ʼ�¼
    SELECT CONNSTR(RADDPIID)
      INTO VRDPIIDLIST
      FROM RECADJUSTDDT
     WHERE RADDNO = RAD.RADNO
       AND RADDROWNO = RAD.RADROWNO
       AND RADDCHKFLAG = 'Y';
    RECBACK(RAD.RADRLID, VRDPIIDLIST, RAH.RAHLB, P_PER, RAH.RAHMEMO, RLCR); --'V'�����Ӧ������ID�뵥������ɺ���ͬ
    --�����ֵ���޸�
    RLDE      := RL;
    RLDE.RLJE := 0; --�������

    -----���崦��ʼ
    RLDE.RLID := FGETSEQUENCE('RECLIST');
    OPEN C_RADD;
    LOOP
      FETCH C_RADD
        INTO RADD;
      EXIT WHEN C_RADD%NOTFOUND OR C_RADD%NOTFOUND IS NULL;
      RDDE.RDID    := RLDE.RLID;
      RDDE.RDPMDID := RADD.RADDPMDID;
      RDDE.RDPIID  := RADD.RADDPIID;
      RDDE.RDPFID  := RADD.RADDPFID;
      RDDE.RDPSCID := RADD.RADDPSCID;
      RDDE.RDCLASS := 0; --�ݲ�֧�ֽ���Ʒ�
      RDDE.RDYSDJ  := RADD.RADDYSDJ;
      RDDE.RDYSSL  := RADD.RADDYSSL;
      RDDE.RDYSJE  := RADD.RADDYSJE;
      IF RADD.RADDCHKFLAG = 'N' THEN
        RDDE.RDDJ    := RADD.RADDYSDJ;
        RDDE.RDSL    := RADD.RADDYSSL;
        RDDE.RDJE    := RADD.RADDYSJE;
        RDDE.RDADJDJ := 0;
        RDDE.RDADJSL := 0;
        RDDE.RDADJJE := 0;
      ELSE
        RDDE.RDDJ    := RADD.RADDDJ;
        RDDE.RDSL    := RADD.RADDSL;
        RDDE.RDJE    := RADD.RADDJE;
        RDDE.RDADJDJ := RADD.RADDADJDJ;
        RDDE.RDADJSL := RADD.RADDADJSL;
        RDDE.RDADJJE := RADD.RADDADJJE;
      END IF;
      RDDE.RDMETHOD    := 'dj1'; --ֻ֧�̶ֹ�����
      RDDE.RDPAIDFLAG  := 'N';
      RDDE.RDPAIDDATE  := NULL;
      RDDE.RDPAIDMONTH := NULL;
      RDDE.RDPAIDPER   := NULL;
      RDDE.RDPMDSCALE  := RADD.RADDSCALE;
      RDDE.RDILID      := NULL;

      RDDE.RDMSMFID  := MI.MISMFID; --Ӫ����˾
      RDDE.RDMONTH   := TOOLS.FGETRECMONTH(MI.MISMFID); --�����·�
      RDDE.RDMID     := MI.MIID; --ˮ����
      RDDE.RDPMDTYPE := '01'; --������
      /*  rdde.RDPMDCOLUMN1 := rdde.PMDCOLUMN1; --�����ֶ�1
      rdde.RDPMDCOLUMN2 := rdde.PMDCOLUMN2; --�����ֶ�2
      rdde.RDPMDCOLUMN3 := rdde.PMDCOLUMN3; --�����ֶ�3*/

      RLDE.RLJE := NVL(RLDE.RLJE, 0) + RDDE.RDJE;
      --������ϸ��
      IF RDTAB IS NULL THEN
        RDTAB := PG_EWIDE_METERREAD_01.RD_TABLE(RDDE);
      ELSE
        RDTAB.EXTEND;
        RDTAB(RDTAB.LAST) := RDDE;
      END IF;
    END LOOP;
    CLOSE C_RADD;

    --���ʴ���,����0Ҳ���ɽ��˼�¼������ͳ�Ƶ������
    /*    RLDE.RLSCRRLID    := RLCR.RLSCRRLID;
    RLDE.RLSCRRLTRANS := RLCR.RLSCRRLTRANS;
    RLDE.RLSCRRLMONTH := RLCR.RLSCRRLMONTH;
    RLDE.RLSCRRLDATE  := RLCR.RLSCRRLDATE;*/

    RLDE.RLSMFID       := MI.MISMFID;
    RLDE.RLMONTH       := TOOLS.FGETRECMONTH(MI.MISMFID);
    RLDE.RLDATE        := TOOLS.FGETRECDATE(MI.MISMFID);
    RLDE.RLCID         := RAD.RADCID;
    RLDE.RLMID         := RAD.RADMID;
    RLDE.RLMSMFID      := MI.MISMFID;
    RLDE.RLCSMFID      := CI.CISMFID;
    RLDE.RLCCODE       := RAD.RADCCODE;
    RLDE.RLCHARGEPER   := RAD.RADCPER;
    RLDE.RLCPID        := CI.CIPID;
    RLDE.RLCCLASS      := CI.CICLASS;
    RLDE.RLCFLAG       := CI.CIFLAG;
    RLDE.RLUSENUM      := RAD.RADUSENUM;
    RLDE.RLCNAME       := CI.CINAME;
    RLDE.RLCADR        := CI.CIADR;
    RLDE.RLMADR        := MI.MIADR;
    RLDE.RLCSTATUS     := CI.CISTATUS;
    RLDE.RLMTEL        := CI.CIMTEL;
    RLDE.RLTEL         := CI.CITEL1;
    RLDE.RLBANKID      := MA.MABANKID;
    RLDE.RLTSBANKID    := MA.MATSBANKID;
    RLDE.RLACCOUNTNO   := MA.MAACCOUNTNO;
    RLDE.RLACCOUNTNAME := MA.MAACCOUNTNAME;
    RLDE.RLIFTAX       := MI.MIIFTAX;
    RLDE.RLTAXNO       := MI.MITAXNO;
    RLDE.RLIFINV       := CI.CIIFINV; --��Ʊ��־
    RLDE.RLMCODE       := RAD.RADMCODE;
    RLDE.RLMPID        := MI.MIPID;
    RLDE.RLMCLASS      := MI.MICLASS;
    RLDE.RLMFLAG       := MI.MIFLAG;
    RLDE.RLMSFID       := MI.MISTID;
    --RLDE.RLDAY          := NULL; --???
    RLDE.RLBFID   := MI.MIBFID; --
    RLDE.RLPRDATE := RAD.RADPRDATE; --
    RLDE.RLRDATE  := RAD.RADRDATE;
    --RLDE.RLZNDATE       := CURRENTDATE + 1; --ΥԼ�������հ���������
    RLDE.RLCALIBER      := MD.MDCALIBER;
    RLDE.RLRTID         := RAD.RADRTID;
    RLDE.RLMSTATUS      := MI.MISTATUS;
    RLDE.RLMTYPE        := MI.MITYPE;
    RLDE.RLMNO          := MD.MDNO;
    RLDE.RLSCODE        := RAD.RADSCODE;
    RLDE.RLECODE        := RAD.RADECODE;
    RLDE.RLREADSL       := RAD.RADREADSL;
    RLDE.RLINVMEMO      := NULL;
    RLDE.RLENTRUSTBATCH := NULL;
    RLDE.RLENTRUSTSEQNO := NULL;
    RLDE.RLOUTFLAG      := 'N';
    RLDE.RLTRANS        := RAH.RAHLB; --'V'�����Ӧ������ID�뵥������ɺ���ͬ
    RLDE.RLCD           := PG_EWIDE_METERREAD_01.DEBIT;

    RLDE.RLREVERSEFLAG  := 'N'; --������־
    RLDE.RLYSCHARGETYPE := MI.MICHARGETYPE;
    RLDE.RLSL           := RAD.RADSL + RAD.RADADJSL; --Ӧ��ˮ��ˮ��
    --rlde.rlje          := rad.radje+rad.radadjje;--������������,�ȳ�ʼ��
    RLDE.RLADDSL    := RAD.RADADDSL;
    RLDE.RLPAIDFLAG := 'N';
    RLDE.RLPAIDJE   := 0;
    RLDE.RLPAIDDATE := NULL;
    RLDE.RLPAIDPER  := NULL;
    RLDE.RLMRID     := NULL;
    --RLDE.RLMRID      := RAD.RADMRID;
    RLDE.RLMEMO     := RAH.RAHMEMO;
    RLDE.RLZNJ      := 0;
    RLDE.RLLB       := MI.MILB;
    RLDE.RLPFID     := RAD.RADPFID;
    RLDE.RLDATETIME := SYSDATE;
    RLDE.RLPRIMCODE := MI.MIPRIID;
    RLDE.RLPRIFLAG  := MI.MIPRIFLAG;
    --RLDE.RLRPER      := NULL; --??

    RLDE.RLCOLUMN5  := RL.RLDATE; --�ϴ�Ӧ��������
    RLDE.RLCOLUMN9  := RL.RLID; --�ϴ�Ӧ������ˮ
    RLDE.RLCOLUMN10 := RL.RLMONTH; --�ϴ�Ӧ�����·�
    RLDE.RLCOLUMN11 := RL.RLTRANS; --�ϴ�Ӧ��������

    RLDE.RLCNAME2 := CI.CINAME2; --������
    RLDE.RLGROUP  := RL.RLGROUP; --Ӧ�����
    BEGIN
      SELECT NVL(SUM(NVL(RLJE, 0) - NVL(RLPAIDJE, 0)), 0)
        INTO RLDE.RLPRIORJE
        FROM RECLIST T
       WHERE T.RLREVERSEFLAG = 'N'
         AND T.RLPAIDFLAG = 'N'
         AND RLJE > 0
         AND RLMID = RLDE.RLMID;
    EXCEPTION
      WHEN OTHERS THEN
        RL.RLPRIORJE := 0; --���֮ǰǷ��
    END;
    IF RLDE.RLPRIORJE > 0 THEN
      RLDE.RLMISAVING := 0;
    ELSE
      RLDE.RLMISAVING := MI.MISAVING; --���ʱԤ��
    END IF;

    BEGIN
      SELECT T0.BFCREPER
        INTO RLDE.RLRPER
        FROM BOOKFRAME T0
       WHERE T0.BFSMFID = MI.MISMFID
         AND T0.BFID = MI.MIBFID;
    EXCEPTION
      WHEN OTHERS THEN
        RLDE.RLRPER := NULL; --??
    END;

    RLDE.RLSAFID     := MI.MISAFID;
    RLDE.RLSCODECHAR := RAD.RADSCODECHAR;
    RLDE.RLECODECHAR := RAD.RADECODECHAR;
    ---�¼��ֶ�
    RLDE.RLPID          := NULL; --ʵ����ˮ����payment.pid��Ӧ��
    RLDE.RLPBATCH       := NULL; --�ɷѽ������Σ���payment.pbatch��Ӧ��
    RLDE.RLSAVINGQC     := 0; --�ڳ�Ԥ�棨����ʱ������
    RLDE.RLSAVINGBQ     := 0; --����Ԥ�淢��������ʱ������
    RLDE.RLSAVINGQM     := 0; --��ĩԤ�棨����ʱ������
    RLDE.RLREVERSEFLAG  := 'N'; --  ������־��nΪ������yΪ������
    RLDE.RLBADFLAG      := 'N'; --���ʱ�־��y :�����ʣ�o:�����������У�n:�����ʣ�
    RLDE.RLZNJREDUCFLAG := 'N'; --���ɽ�����־,δ����ʱΪn������ʱ���ɽ�ֱ�Ӽ��㣻�����Ϊy,����ʱ���ɽ�ֱ��ȡrlznj
    RLDE.RLMISTID       := MI.MISTID; --��ҵ����
    RLDE.RLMINAME       := MI.MINAME; --Ʊ������
    RLDE.RLSXF          := 0; --������
    RLDE.RLMIFACE2      := MI.MIFACE2; --��������
    RLDE.RLMIFACE3      := MI.MIFACE3; --�ǳ�����
    RLDE.RLMIFACE4      := MI.MIFACE4; --����ʩ˵��
    RLDE.RLMIIFCKF      := MI.MIIFCHK; --�����ѻ���
    RLDE.RLMIGPS        := MI.MIGPS; --�Ƿ��Ʊ
    RLDE.RLMIQFH        := MI.MIQFH; --Ǧ���
    RLDE.RLMIBOX        := MI.MIBOX; --����ˮ�ۣ���ֵ˰ˮ�ۣ���������
    RLDE.RLMINAME2      := MI.MINAME2; --��������(С��������������
    RLDE.RLMISEQNO      := MI.MISEQNO; --���ţ���ʼ��ʱ���+��ţ�

    --����Ӧ��
    INSERT INTO RECLIST VALUES RLDE;
    PG_EWIDE_METERREAD_01.INSRD(RDTAB);
    ---------------------------------------------------------
    CLOSE C_MI;

  END;

  PROCEDURE RECBACK(P_RLID       IN VARCHAR2,
                    P_RDPIIDLIST IN VARCHAR2,
                    P_TRANS      IN VARCHAR2,
                    P_PER        IN VARCHAR2,
                    P_MEMO       IN VARCHAR2,
                    RLCR         OUT RECLIST%ROWTYPE) AS
    VILNO VARCHAR2(10);
    FOUND BOOLEAN;

    CURSOR C_RL IS
      SELECT * FROM RECLIST WHERE RLID = P_RLID FOR UPDATE NOWAIT;

    CURSOR C_RD IS
      SELECT *
        FROM RECDETAIL
       WHERE RDID = P_RLID
         AND RDPAIDFLAG = 'N'
         AND INSTR(P_RDPIIDLIST, RDPIID) > 0
         FOR UPDATE NOWAIT;

    CURSOR C_INV IS
      SELECT ILNO
        FROM INVOICELIST
       WHERE ILRLID = P_RLID
         AND ILSTATUS = 'Y';

    RL          RECLIST%ROWTYPE;
    RD          RECDETAIL%ROWTYPE;
    RDCR        RECDETAIL%ROWTYPE;
    VRDPAIDFLAG VARCHAR2(100);
    RDTAB       PG_EWIDE_METERREAD_01.RD_TABLE;
  BEGIN

    --������Ӧ����У��
    OPEN C_RL;
    FETCH C_RL
      INTO RLCR;
    FOUND := C_RL%FOUND;
    IF NOT FOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��Ч�Ĵ�����Ӧ�ռ�¼���޴�Ӧ����ˮ');
    ELSE
      IF RLCR.RLOUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '������;Ӧ���ʲ��ܳ���');
      END IF;
      --����Ӧ����ͷ��־�ж�(Y:Y��N:N��X:X��V:Y/N��T:Y/X��K:N/X��W:Y/N/X)
      IF RLCR.RLPAIDFLAG = 'Y' OR RLCR.RLPAIDFLAG = 'X' OR
         RLCR.RLPAIDFLAG = 'T' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�����ʻ��ѱ�����Ӧ���ʲ��ܳ���');
      END IF;
    END IF;

    --������Ӧ�ղ�����Ӧ�ĸ���

    RLCR.RLCOLUMN5  := RLCR.RLDATE; --�ϴ�Ӧ��������
    RLCR.RLCOLUMN9  := RLCR.RLID; --�ϴ�Ӧ������ˮ
    RLCR.RLCOLUMN10 := RLCR.RLMONTH; --�ϴ�Ӧ�����·�
    RLCR.RLCOLUMN11 := RLCR.RLTRANS; --�ϴ�Ӧ��������
    --����ͷ��ֵ
    /*  RLCR.RLSCRRLID    := RLCR.RLID;
    RLCR.RLSCRRLTRANS := RLCR.RLTRANS;
    RLCR.RLSCRRLMONTH := RLCR.RLMONTH;
    RLCR.RLSCRRLDATE  := RLCR.RLDATE;*/

    RLCR.RLID       := FGETSEQUENCE('RECLIST');
    RLCR.RLMONTH    := TOOLS.FGETRECMONTH(RLCR.RLSMFID);
    RLCR.RLDATE     := TOOLS.FGETRECDATE(RLCR.RLSMFID);
    RLCR.RLCD       := PG_EWIDE_METERREAD_01.CREDIT;
    RLCR.RLTRANS    := P_TRANS;
    RLCR.RLDATETIME := SYSDATE;
    RLCR.RLPAIDFLAG := 'N';
    --
    RLCR.RLSL     := 0 - RLCR.RLSL;
    RLCR.RLJE     := 0 - RLCR.RLJE;
    RLCR.RLADDSL  := 0 - RLCR.RLADDSL;
    RLCR.RLPAIDJE := 0 - RLCR.RLPAIDJE;
    --����
    RLCR.RLSAVINGQC    := 0 - RLCR.RLSAVINGQC;
    RLCR.RLSAVINGBQ    := 0 - RLCR.RLSAVINGBQ;
    RLCR.RLSAVINGQM    := 0 - RLCR.RLSAVINGQM;
    RLCR.RLSXF         := 0 - RLCR.RLSXF;
    RLCR.RLMEMO        := P_MEMO;
    RLCR.RLREVERSEFLAG := 'Y';

    RLCR.RLPAIDDATE  := SYSDATE;
    RLCR.RLPAIDMONTH := RLCR.RLMONTH;
    RLCR.RLPAIDPER   := P_PER;
    RLCR.RLREADSL    := 0 - RLCR.RLREADSL; --����ˮ��
    RLCR.RLMRID      := NULL; --������ˮ
    RLCR.RLZNJ       := 0 - RLCR.RLZNJ; --ΥԼ��
    RLCR.RLILID      := NULL; --��Ʊ��ˮ��
    RLCR.RLPID       := NULL; --ʵ����ˮ����payment.pid��Ӧ��
    RLCR.RLPBATCH    := NULL; --�ɷѽ������Σ���payment.pbatch��Ӧ��
    RLCR.RLSXF       := 0 - RLCR.RLSXF; --������

    --�����帳ֵ,ͬʱ���´���Ŀ��Ӧ����ϸ���ʱ�־
    OPEN C_RD;
    FETCH C_RD
      INTO RD;
    IF C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��Ч�Ĵ�����Ӧ�ռ�¼���޴�Ӧ�շ�����ϸ');
    END IF;
    WHILE C_RD%FOUND LOOP

      RDCR.RDID := NULL;

      RDCR.RDID         := RLCR.RLID;
      RDCR.RDPMDID      := RD.RDPMDID;
      RDCR.RDPFID       := RD.RDPFID;
      RDCR.RDPIID       := RD.RDPIID;
      RDCR.RDPSCID      := RD.RDPSCID;
      RDCR.RDCLASS      := RD.RDCLASS;
      RDCR.RDYSDJ       := RD.RDYSDJ;
      RDCR.RDDJ         := RD.RDDJ;
      RDCR.RDADJDJ      := RD.RDADJDJ;
      RDCR.RDYSSL       := 0 - RD.RDYSSL;
      RDCR.RDYSJE       := 0 - RD.RDYSJE;
      RDCR.RDSL         := 0 - RD.RDSL;
      RDCR.RDJE         := 0 - RD.RDJE;
      RDCR.RDADJSL      := 0 - RD.RDADJSL;
      RDCR.RDADJJE      := 0 - RD.RDADJJE;
      RDCR.RDZNJ        := 0 - RD.RDZNJ;
      RDCR.RDMETHOD     := RD.RDMETHOD;
      RDCR.RDPAIDFLAG   := RLCR.RLPAIDFLAG; --���ʱ�־  rdpaidper
      RDCR.RDPAIDDATE   := RLCR.RLPAIDDATE; --��������
      RDCR.RDPAIDMONTH  := RLCR.RLPAIDMONTH; --�����·�
      RDCR.RDILID       := RLCR.RLILID;
      RDCR.RDMONTH      := RLCR.RLMONTH;
      RDCR.RDMSMFID     := RLCR.RLSMFID;
      RDCR.RDPMDSCALE   := RD.RDPMDSCALE;
      RDCR.RDPAIDPER    := RLCR.RLPAIDPER; --������Ա
      RDCR.RDMEMO       := RD.RDMEMO;
      RDCR.RDPMDTYPE    := RD.RDPMDTYPE;
      RDCR.RDMID        := RD.RDMID;
      RDCR.RDPMDTYPE    := RD.RDPMDTYPE;
      RDCR.RDPMDCOLUMN1 := RD.RDPMDCOLUMN1;
      RDCR.RDPMDCOLUMN2 := RD.RDPMDCOLUMN2;
      RDCR.RDPMDCOLUMN3 := RD.RDPMDCOLUMN3;

      --  RDCR.RDPAIDFLAG   := 'X';

      INSERT INTO RECDETAIL VALUES RDCR;
      --add 2013.02.01
      SP_RECLIST_CHARGE_01(RDCR.RDID, '1');
      --add 2013.02.01
      FETCH C_RD
        INTO RD;
    END LOOP;

    CLOSE C_RD;
    --�������ͷ������

    INSERT INTO RECLIST VALUES RLCR;

    /*  --�����¼Ӧ����ͷ��־
    select connstr(rdpaidflag)
      into vrdpaidflag
      from recdetail
     where rdid = rlcr.rlscrrlid;
    --��ʽ�����ʱ�־(Y:Y��N:N��X:X��V:Y/N��T:Y/X��K:N/X��W:Y/N/X)
    vrdpaidflag := (case when instr(vrdpaidflag, 'Y') > 0 then 'Y' else null end) || (case when instr(vrdpaidflag, 'N') > 0 then 'N' else null end) || (case when instr(vrdpaidflag, 'X') > 0 then 'X' else null end);
    if vrdpaidflag = 'X' then
      rl.rlpaidflag := 'X';
    elsif vrdpaidflag = 'YX' then
      rl.rlpaidflag := 'X';
    elsif vrdpaidflag = 'NX' then
      rl.rlpaidflag := 'X';
    elsif vrdpaidflag = 'YNX' then
      rl.rlpaidflag := 'X';
    else
      raise_application_error(errcode, '���ʱ�־�쳣');
    end if;*/
    --���±��Դ��
    --���±��Դ��
    UPDATE RECLIST
       SET /*RLPAIDFLAG = 'X',*/ RLREVERSEFLAG = 'Y' --,--������־
    --RLPAIDDATE = RLCR.RLDATE,
    --RLPAIDPER  = P_PER
     WHERE CURRENT OF C_RL;

    --���³����Ӧ��¼
    /*    update meterread set mrrecsl = 0 where mrid = rlcr.rlmrid;
    if sql%rowcount <> 1 or sql%rowcount is null then
      update meterreadhis set mrrecsl = 0 where mrid = rlcr.rlmrid;
      if sql%rowcount <> 1 or sql%rowcount is null then
        null;
        --raise_application_error(errcode, '���³����¼����');
      end if;
    end if;*/
    --�������ˮ��(���������ǡ�����ʱ)
    /*    update meterinfo
       set mirecsl = 0
     where miid = rlcr.rlmid
       and mirecdate = rlcr.rlrdate;
    if sql%rowcount <> 1 or sql%rowcount is null then
      null;
    end if;*/

    CLOSE C_RL;

  EXCEPTION

    WHEN OTHERS THEN
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      IF C_INV%ISOPEN THEN
        CLOSE C_INV;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;




--���˵�
PROCEDURE SP_���˵�(P_NO IN VARCHAR2, P_PER IN VARCHAR2,P_DJLB IN VARCHAR2) AS

CURSOR C_HD IS
SELECT * FROM RECADJUSTHD WHERE RAHNO=P_NO;

CURSOR C_DT IS
SELECT * FROM RECADJUSTDT WHERE RADNO=P_NO AND RADCHKFLAG='Y' AND RADADJJE>0;

HD     RECADJUSTHD%ROWTYPE;
DT     RECADJUSTDT%ROWTYPE;
v_ret  varchar2(10);
BEGIN
  --��鵥ͷ
  OPEN C_HD;
    FETCH C_HD
      INTO HD;
    IF C_HD%NOTFOUND OR C_HD%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ�����' || P_NO);
    END IF;
  CLOSE C_HD;
  --��鵥��
  OPEN C_DT;
    LOOP
      FETCH C_DT
        INTO DT;
      EXIT WHEN C_DT%NOTFOUND OR C_DT%NOTFOUND IS NULL;
           SP_RECFZRLID(DT.RADRLID,DT.RADADJJE);
           --SP_RECFZRLID('',0,v_ret);
           IF v_ret='N' THEN
              RAISE_APPLICATION_ERROR(ERRCODE, '���˴���,Ӧ����ˮ:' || DT.RADRLID||'|Ӧ�ս��:'||DT.RADADJJE);
           END IF;
    END LOOP;
  CLOSE C_DT;
  UPDATE RECADJUSTHD
  SET RAHSHDATE=SYSDATE,
     RAHSHPER=P_PER,
   --   RAHSHPER=rahcreper ,
      RAHSHFLAG='Y'
  WHERE rahno=P_NO ;

    --��������
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_NO);

EXCEPTION
  WHEN OTHERS THEN
    IF C_HD%ISOPEN THEN
        CLOSE C_HD;
    END IF;
    IF C_DT%ISOPEN THEN
        CLOSE C_DT;
    END IF;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END SP_���˵�;


  PROCEDURE �����������(P_RCHSMFID   IN VARCHAR2, --Ӫҵ��
                   P_RCHDEPT    IN VARCHAR2, -- ��������
                   P_RCHCREPER  IN VARCHAR2, --������Ա
                   P_RCHCREDATE IN VARCHAR2, --��������
                   P_RL         RECLIST%ROWTYPE, --Ӧ����Ϣ
                   P_RCHNO      IN OUT VARCHAR2, --������ݺ�
                   P_COMMIT     IN VARCHAR2 --������־
                   ) IS

    V_RCH RECCZHD%ROWTYPE;
    RCD   RECCZDT%ROWTYPE;
  BEGIN
    --���쵥ͷ
    IF P_RCHNO IS NULL THEN
      TOOLS.SP_BILLSEQ('108', V_RCH.RCHNO, 'N'); --������ˮ��
      P_RCHNO := V_RCH.RCHNO;
    ELSE
      V_RCH.RCHNO := P_RCHNO;
    END IF;
    V_RCH.RCHBH      := V_RCH.RCHNO;
    V_RCH.RCHLB      := 'G';
    V_RCH.RCHSOURCE  := '1';
    V_RCH.RCHSMFID   := P_RCHSMFID;
    V_RCH.RCHDEPT    := P_RCHDEPT;
    V_RCH.RCHCREDATE := P_RCHCREDATE;
    V_RCH.RCHCREPER  := P_RCHCREPER;
    V_RCH.RCHSHDATE  := NULL;
    V_RCH.RCHSHPER   := NULL;
    V_RCH.RCHSHFLAG  := 'N';
    INSERT INTO RECCZHD VALUES V_RCH;
    --���쵥��
    RCD.RCDNO        := V_RCH.RCHNO; --������ˮ��
    RCD.RCDROWNO     := 1; --�к�
    RCD.RCDMRID      := P_RL.RLMRID; --ԭ������ˮ��
    RCD.RCDRLID      := P_RL.RLID; --ԭ��ˮ��
    RCD.RCDCID       := P_RL.RLCID; --�û����
    RCD.RCDCCODE     := P_RL.RLCCODE; --�û���
    RCD.RCDMID       := P_RL.RLMID; --ˮ����
    RCD.RCDMCODE     := P_RL.RLMCODE; --���Ϻ�
    RCD.RCDPRDATE    := P_RL.RLPRDATE; --�ϴγ�������
    RCD.RCDRDATE     := P_RL.RLRDATE; --���γ�������
    RCD.RCDSCODE     := P_RL.RLSCODE; --���ڳ���
    RCD.RCDECODE     := P_RL.RLECODE; --���ڳ���
    RCD.RCDSCODECHAR := P_RL.RLSCODECHAR; --���ڳ���
    RCD.RCDECODECHAR := P_RL.RLECODECHAR; --���ڳ���
    RCD.RCDREADSL    := P_RL.RLREADSL; --����ˮ��
    RCD.RCDADDSL     := P_RL.RLADDSL; --����
    RCD.RCDSL        := P_RL.RLSL; --Ӧ��ˮ��
    RCD.RCDADJSL     := P_RL.RLADDSL; --����ˮ��
    RCD.RCDPFID      := P_RL.RLPFID; --�۸����
    RCD.RCDJE        := P_RL.RLJE; --Ӧ�ս��
    RCD.RCDCNAME     := P_RL.RLCNAME; --�û�����
    RCD.RCDCADR      := P_RL.RLCADR; --�û���ַ
    RCD.RCDMADR      := P_RL.RLMADR; --ˮ���ַ
    RCD.RCDRTID      := P_RL.RLRTID; --����ʽ
    RCD.RCDUSENUM    := P_RL.RLUSENUM; --����ˮ����
    RCD.RCDZNJ       := P_RL.RLZNJ; --ΥԼ��
    RCD.RCDZNDATE    := P_RL.RLZNDATE; --ΥԼ��������
    RCD.RCDPRIFLAG   := P_RL.RLPRIFLAG; --���ձ��־
    RCD.RCDPRIID     := NULL; --���ձ������
    RCD.RCDRLIDCR    := NULL; --����Ӧ����ˮ�ţ���д��
    RCD.RCDRCODEFLAG := 'N'; --���´γ������
    RCD.RCDMEMO      := '����׷��'; --��ע
    RCD.RCDFLASHDATE := NULL; --���ʱ��
    RCD.RCDFLASHPER  := NULL; --�����
    RCD.RCDFLASHFLAG := 'N'; --��˱�־
    RCD.RCIFSUBMIT   := 'Y'; --�Ƿ��ύ
    INSERT INTO RECCZDT VALUES RCD;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN

      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  PROCEDURE ����׷������(P_RTHSMFID   IN VARCHAR2, --Ӫҵ��
                   P_RTHDEPT    IN VARCHAR2, -- ��������
                   P_RTHCREPER  IN VARCHAR2, --������Ա
                   P_RTHCREDATE IN VARCHAR2, --��������
                   P_RL         RECLIST%ROWTYPE, --Ӧ����Ϣ
                   P_RTHNO      IN OUT VARCHAR2, --������ݺ�
                   P_COMMIT     IN VARCHAR2, --�ύ��־
                   P_MEMO       IN VARCHAR2) IS

    V_RTH RECTRANSHD%ROWTYPE;
    V_MI  METERINFO%ROWTYPE;
  BEGIN
    --���쵥ͷ
    IF P_RTHNO IS NULL THEN
      TOOLS.SP_BILLSEQ('102', V_RTH.RTHNO, 'N'); --������ˮ��
      P_RTHNO := V_RTH.RTHNO;
    ELSE
      V_RTH.RTHNO := P_RTHNO;
    END IF;
    SELECT * INTO V_MI FROM METERINFO WHERE MIID = P_RL.RLMID;
    V_RTH.RTHBH         := V_RTH.RTHNO; --���ݱ��
    V_RTH.RTHLB         := 'O'; --�������
    V_RTH.RTHSMFID      := P_RTHSMFID; --Ӫҵ��
    V_RTH.RTHDEPT       := P_RTHDEPT; --����
    V_RTH.RTHSOURCE     := '1'; --������Դ
    V_RTH.RTHCREDATE    := P_RTHCREDATE; --��������
    V_RTH.RTHCREPER     := P_RTHCREPER; --������Ա
    V_RTH.RTHSHDATE     := NULL; --�������
    V_RTH.RTHDATE       := NULL; --�����������
    V_RTH.RTHSHPER      := NULL; --�����Ա
    V_RTH.RTHSHFLAG     := 'N'; --��˱�־
    V_RTH.RTHMEMO       := P_MEMO; --��ע
    V_RTH.RTHCID        := P_RL.RLCID; --�û����
    V_RTH.RTHMID        := P_RL.RLMID; --ˮ����
    V_RTH.RTHCCODE      := P_RL.RLCCODE; --�û���
    V_RTH.RTHMCODE      := P_RL.RLMCODE; --���Ϻ�
    V_RTH.RTHMLB        := V_MI.MILB; --ˮ�����
    V_RTH.RTHCPER       := V_MI.MICPER; --�շ�Ա
    V_RTH.RTHBFID       := P_RL.RLBFID; --���
    V_RTH.RTHIFMP       := V_MI.MIIFMP; --�����ˮ
    V_RTH.RTHPFID       := P_RL.RLPFID; --���۸����
    V_RTH.RTHCNAME      := P_RL.RLCNAME; --�û�����
    V_RTH.RTHMNAME      := V_MI.MINAME; --Ʊ������
    V_RTH.RTHCADR       := P_RL.RLCADR; --�û���ַ
    V_RTH.RTHMADR       := P_RL.RLMADR; --ˮ���ַ
    V_RTH.RTHRTID       := P_RL.RLRTID; --����ʽ
    V_RTH.RTHMFACE      := V_MI.MIFACE; --���
    V_RTH.RTHMRPID      := V_MI.MIRPID; --�Ƽ�����
    V_RTH.RTHMSIDE      := V_MI.MISIDE; --��λ
    V_RTH.RTHMPOSITION  := V_MI.MIPOSITION; --��ˮ��ַ
    V_RTH.RTHMTYPE      := V_MI.MITYPE; --ˮ������
    V_RTH.RTHCHARGETYPE := V_MI.MICHARGETYPE; --Ӧ���շѷ�ʽ
    V_RTH.RTHSAVING     := V_MI.MISAVING; --Ԥ�����
    V_RTH.RTHSCODE      := P_RL.RLSCODE; --����
    V_RTH.RTHECODE      := P_RL.RLECODE; --ֹ��
    V_RTH.RTHECODEFLAG  := 'N'; --���´γ������
    V_RTH.RTHREADSL     := P_RL.RLREADSL; --����ˮ��
    V_RTH.RTHADDSL      := P_RL.RLADDSL; --����
    V_RTH.RTHSL         := P_RL.RLSL; --Ӧ��ˮ��
    V_RTH.RTHJE         := P_RL.RLJE; --Ӧ�ս��
    V_RTH.RTHUSENUM     := P_RL.RLUSENUM; --����ˮ����
    V_RTH.RTHPRDATE     := P_RL.RLPRDATE; --�ϴγ�������
    V_RTH.RTHRDATE      := P_RL.RLRDATE; --���γ�������
    V_RTH.RTHZNJ        := P_RL.RLZNJ; --ΥԼ��
    V_RTH.RTHZNDATE     := P_RL.RLZNDATE; --ΥԼ��������
    V_RTH.RTHPRIFLAG    := P_RL.RLPRIFLAG; --���ձ��־
    V_RTH.RTHPRIID      := V_MI.MIPRIID; --���ձ������
    V_RTH.RTHIFPAY      := P_RL.RLPAIDFLAG; --�Ƿ�����
    V_RTH.RTHPID        := NULL; --ʵ�ս�����ˮ����д��
    V_RTH.RTHMRID       := NULL; --������ˮ����д��
    V_RTH.RTHRLID       := NULL; --��ˮ�ţ���д��
    V_RTH.RTHILID       := NULL; --Ʊ����ˮ����д��
    V_RTH.RTHIFINV      := NULL; --�Ƿ��Ʊ
    V_RTH.RTHINVMEMO    := P_MEMO; --��Ʊ��ע
    V_RTH.RTHSCODECHAR  := P_RL.RLSCODECHAR; --����������λ��
    V_RTH.RTHECODECHAR  := P_RL.RLECODECHAR; --ֹ��������λ��
    V_RTH.IFREC         := 'Y'; --�Ƿ�����ѹ���(���߿���ΪӪҵ��)
    V_RTH.IFRECHIS      := 'N'; --�Ƿ���ʷˮ�����(ѡ��鵵�۸�汾)
    V_RTH.PRICEMONTH    := NULL; --�۸��·�
    INSERT INTO RECTRANSHD VALUES V_RTH;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  PROCEDURE SP_�����˷�(P_BILLNO IN VARCHAR2, --���ݱ��
                    P_PER    IN VARCHAR2, --�����
                    P_MEMO   IN VARCHAR2, --��ע
                    P_COMMIT IN VARCHAR --�Ƿ��ύ��־
                    ) IS
    CURSOR C_PH IS
      SELECT * FROM PAIDADJUSTHD T WHERE T.PAHNO = P_BILLNO FOR UPDATE;
    CURSOR C_PDT IS
      SELECT *
        FROM PAIDADJUSTDT T
       WHERE T.PADNO = P_BILLNO
         AND NVL(T.PADSHFLAG, 'N') = 'N'
         AND NVL(PADCHKFLAG, 'N') = 'Y'
       ORDER BY T.PADROWNO
         FOR UPDATE;
    CURSOR C_RL(P_RLID IN VARCHAR2, P_PADPLRLID IN VARCHAR2) IS
      SELECT *
        FROM RECLIST RL
       WHERE RL.RLPAIDFLAG = 'N'
         AND RL.RLREVERSEFLAG = 'N'
         AND RLID IN
             (SELECT RLID
                FROM RECLISTTEMPCZ
              -- WHERE RLSCRRLID = P_PADPLRLID
              UNION
              SELECT RLID FROM RECLIST RL WHERE RL.RLID = P_RLID);
    V_PH    PAIDADJUSTHD%ROWTYPE;
    V_PDT   C_PDT%ROWTYPE;
    V_RL    RECLIST%ROWTYPE;
    V_RET   VARCHAR2(10);
    V_YSHNO VARCHAR2(10); --Ӧ�ճ���������ˮ��
    V_RLID  VARCHAR2(10);
    V_SL    NUMBER;
    V_MRID  VARCHAR2(10);
    V_ZNJ   RECLIST.RLZNJ%TYPE;
    V_BATCH PAYMENT.PBATCH%TYPE;

    V_BJMZJE RECLIST.RLJE%TYPE; --����ǰ�ܽ��
    V_BJE1   RECDETAIL.RDJE%TYPE; --����ǰ���1
    V_BJE2   RECDETAIL.RDJE%TYPE; --����ǰ���2
    V_BJE3   RECDETAIL.RDJE%TYPE; --����ǰ���3
    V_BJE4   RECDETAIL.RDJE%TYPE; --����ǰ���4
    V_BJE5   RECDETAIL.RDJE%TYPE; --����ǰ���5
    V_BJE6   RECDETAIL.RDJE%TYPE; --����ǰ���6
    V_BJE7   RECDETAIL.RDJE%TYPE; --����ǰ���7

    V_AJMZJE RECLIST.RLJE%TYPE; --������ܽ��
    V_AJE1   RECDETAIL.RDJE%TYPE; --�������1
    V_AJE2   RECDETAIL.RDJE%TYPE; --�������2
    V_AJE3   RECDETAIL.RDJE%TYPE; --�������3
    V_AJE4   RECDETAIL.RDJE%TYPE; --�������4
    V_AJE5   RECDETAIL.RDJE%TYPE; --�������5
    V_AJE6   RECDETAIL.RDJE%TYPE; --�������6
    V_AJE7   RECDETAIL.RDJE%TYPE; --�������7
  BEGIN

    /* ��ͷУ�� */
    OPEN C_PH;
    FETCH C_PH
      INTO V_PH;
    IF C_PH%NOTFOUND OR C_PH%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ�����');
    END IF;
    IF V_PH.PAHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���������');
    END IF;
    IF V_PH.PAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '������ȡ��');
    END IF;
    /*ҵ����**/
    OPEN C_PDT;
    LOOP
      FETCH C_PDT
        INTO V_PDT;
      EXIT WHEN C_PDT%NOTFOUND OR C_PDT%NOTFOUND IS NULL;
      --ʵ�ճ���

      V_RET := PG_EWIDE_PAY_01.F_PAYBACK_BY_BATCH(V_PDT.PADPBATCH,
                                                  V_PH.PAHSMFID,
                                                  P_PER,
                                                  V_PH.PAHSMFID,
                                                  'C');
      IF V_RET <> '000' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '����ʧ�ܣ�');
      END IF;
      --ȡ��ʵ�ճ�����Ƿ����Ϣ
      SELECT *
        INTO V_RL
        FROM RECLIST RL
       WHERE RL.RLPAIDFLAG = 'N'
         AND RL.RLREVERSEFLAG = 'N'
         AND RLID IN (SELECT RLID
                        FROM RECLISTTEMPCZ
                       WHERE RLSCRRLID = V_PDT.PADPLRLID);
      --Ӧ�ճ���
      PG_EWIDE_RECTRANS_01.�����������(V_PH.PAHSMFID,
                                  V_PH.PAHDEPT,
                                  V_PH.PAHCREPER,
                                  V_PH.PAHCREDATE,
                                  V_RL,
                                  V_YSHNO,
                                  'N');
      PG_EWIDE_RECTRANS_01.SP_RECCZ(V_YSHNO, P_PER, '�����˷ѳ���', 'N');

      --׷���շ�
      --������ˮ��
      V_YSHNO       := NULL;
      V_RL.RLREADSL := V_RL.RLSL - NVL(V_PDT.PADCRSL, 0);
      V_RL.RLSL     := V_RL.RLREADSL;
      IF V_RL.RLSL > 0 THEN
        PG_EWIDE_RECTRANS_01.����׷������(V_PH.PAHSMFID,
                                    V_PH.PAHDEPT,
                                    V_PH.PAHCREPER,
                                    V_PH.PAHCREDATE,
                                    V_RL,
                                    V_YSHNO,
                                    'N',
                                    '�����˷�׷��');
        PG_EWIDE_RECTRANS_01.SP_RECTRANS102(V_YSHNO, P_PER);

        --����ˮ��
        --�õ��������Ƿ����Ϣ
        SELECT T.RTHRLID, T.RTHREADSL, T.RTHMRID
          INTO V_RLID, V_SL, V_MRID
          FROM RECTRANSHD T
         WHERE T.RTHNO = V_YSHNO;
      END IF;
      OPEN C_RL(V_RLID, V_PDT.PADPLRLID);
      LOOP
        FETCH C_RL
          INTO V_RL;
        EXIT WHEN C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL;
        TOOLS.SP_BILLSEQ('110', V_YSHNO, 'N');
        BEGIN
          --û�м��������
          SELECT RL.RLZNJ
            INTO V_ZNJ
            FROM RECLIST RL
           WHERE RL.RLID IN
                 (SELECT RLSCRRLID FROM RECLISTTEMPCZ WHERE RLID = V_RL.RLID);
          --   V_RL.RLZNJ := V_ZNJ;
        EXCEPTION
          WHEN OTHERS THEN
            --���������
            V_ZNJ := V_PDT.PADPLZNJ - NVL(V_PDT.PADCRZNJ, 0);
        END;
        -- V_RL.RLZNJ := V_PDT.PADPLZNJ;
        --ΥԼ�����
        PG_EWIDE_RECZNJ_01.����ΥԼ����ⵥ��(V_PH.PAHSMFID,
                                     V_PH.PAHDEPT,
                                     V_PH.PAHCREPER,
                                     V_PH.PAHCREDATE,
                                     V_RL,
                                     V_YSHNO,
                                     V_ZNJ,
                                     'N');
        PG_EWIDE_RECZNJ_01.SP_RECZNJJM(V_YSHNO, P_PER, 'N');

        V_RL.RLZNJ := V_ZNJ;
        V_BATCH    := FGETSEQUENCE('ENTRUSTLOG');
        V_RET      := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                          V_PH.PAHSMFID, --�ɷѻ���
                                          P_PER, --�տ�Ա
                                          V_RL.RLID || '|', --Ӧ����ˮ
                                          V_RL.RLJE, --Ӧ�ս��
                                          V_RL.RLZNJ, --����ΥԼ��
                                          0, --������
                                          V_RL.RLJE + V_RL.RLZNJ, --ʵ���տ�
                                          'P', --�ɷ�����
                                          V_RL.RLMID, --����
                                          'XJ', --���ʽ
                                          V_PH.PAHSMFID, --�ɷѵص�
                                          V_BATCH, --�ɷ�������ˮ
                                          'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                          '', --��Ʊ��
                                          'N' --�����Ƿ��ύ��Y/N��
                                          );
        IF V_RET <> '000' THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '����ʧ��');
        END IF;
      END LOOP;

      --�������
      SELECT SUM(RD.RDJE),
             SUM(DECODE(RD.RDPIID, '01', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '02', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '03', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '04', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '05', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '06', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '07', RDJE, 0))
        INTO V_BJMZJE,
             V_BJE1,
             V_BJE2,
             V_BJE3,
             V_BJE4,
             V_BJE5,
             V_BJE6,
             V_BJE7
        FROM RECDETAIL RD
       WHERE RD.RDID = V_PDT.PADPLRLID;
      BEGIN
        --���ݼ������
        SELECT SUM(RD.RDJE),
               SUM(DECODE(RD.RDPIID, '01', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '02', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '03', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '04', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '05', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '06', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '07', RDJE, 0))
          INTO V_AJMZJE,
               V_AJE1,
               V_AJE2,
               V_AJE3,
               V_AJE4,
               V_AJE5,
               V_AJE6,
               V_AJE7
          FROM RECDETAIL RD
         WHERE RD.RDID = V_RLID;
      EXCEPTION
        WHEN OTHERS THEN
          V_AJMZJE := 0;
          V_AJE1   := 0;
          V_AJE2   := 0;
          V_AJE3   := 0;
          V_AJE4   := 0;
          V_AJE5   := 0;
          V_AJE6   := 0;
          V_AJE7   := 0;
      END;
      --ȫ��
      IF V_RLID IS NULL THEN
        --���µ�����˱�־
        UPDATE PAIDADJUSTDT T
           SET PADSHFLAG  = 'Y', --��˱�־
               T.PADNRLID = V_RLID, -- ��Ӧ����id
               T.PADCRJE  = 0, --�����ܽ��
               T.PADCRJE1 = 0, --������1
               T.PADCRJE2 = 0, --������2
               T.PADCRJE3 = 0, --������3
               T.PADCRJE4 = 0, --������4
               T.PADCRJE5 = 0, --������5
               T.PADCRJE6 = 0, --������6
               T.PADCRJE7 = 0 --������7
         WHERE CURRENT OF C_PDT;
      ELSE
        --���µ�����˱�־
        UPDATE PAIDADJUSTDT T
           SET PADSHFLAG  = 'Y', --��˱�־
               T.PADNRLID = V_RLID, -- ��Ӧ����id
               T.PADCRJE  = V_BJMZJE - V_AJMZJE, --�����ܽ��
               T.PADCRJE1 = V_BJE1 - V_AJE1, --������1
               T.PADCRJE2 = V_BJE2 - V_AJE2, --������2
               T.PADCRJE3 = V_BJE3 - V_AJE3, --������3
               T.PADCRJE4 = V_BJE4 - V_AJE4, --������4
               T.PADCRJE5 = V_BJE5 - V_AJE5, --������5
               T.PADCRJE6 = V_BJE6 - V_AJE6, --������6
               T.PADCRJE7 = V_BJE7 - V_AJE7 --������7
         WHERE CURRENT OF C_PDT;

      END IF;

    END LOOP;

    --���µ�ͷ��˱�־
    --���µ�����˱�־
    UPDATE PAIDADJUSTHD
       SET PAHSHDATE = SYSDATE, PAHSHPER = P_PER, PAHSHFLAG = 'Y'
     WHERE PAHNO = P_BILLNO;

      --��������
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_BILLNO);

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    --�ر��α�
    IF C_PH%ISOPEN THEN
      CLOSE C_PH;
    END IF;
    IF C_PDT%ISOPEN THEN
      CLOSE C_PDT;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_PH%ISOPEN THEN
        CLOSE C_PH;
      END IF;
      IF C_PDT%ISOPEN THEN
        CLOSE C_PDT;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  PROCEDURE SP_�����(P_BILLNO IN VARCHAR2, --���ݱ��
                   P_PER    IN VARCHAR2, --�����
                   P_MEMO   IN VARCHAR2, --��ע
                   P_COMMIT IN VARCHAR --�Ƿ��ύ��־
                   ) IS
    CURSOR C_PH IS
      SELECT * FROM PAIDADJUSTHD T WHERE T.PAHNO = P_BILLNO FOR UPDATE;
    CURSOR C_PDT IS
      SELECT *
        FROM PAIDADJUSTDT T
       WHERE T.PADNO = P_BILLNO
         AND NVL(T.PADSHFLAG, 'N') = 'N'
         AND NVL(PADCHKFLAG, 'N') = 'Y'
       ORDER BY T.PADROWNO
         FOR UPDATE;
    CURSOR C_RL(P_RLID IN VARCHAR2, P_PADPLRLID IN VARCHAR2) IS
      SELECT *
        FROM RECLIST RL
       WHERE RL.RLPAIDFLAG = 'N'
         AND RL.RLREVERSEFLAG = 'N'
         AND RLID IN
             (SELECT RLID
                FROM RECLISTTEMPCZ
              -- WHERE RLSCRRLID = P_PADPLRLID
              UNION
              SELECT RLID FROM RECLIST RL WHERE RL.RLID = P_RLID);
    V_PH    PAIDADJUSTHD%ROWTYPE;
    V_PDT   C_PDT%ROWTYPE;
    V_RL    RECLIST%ROWTYPE;
    V_RET   VARCHAR2(10);
    V_YSHNO VARCHAR2(10); --Ӧ�ճ���������ˮ��
    V_RLID  VARCHAR2(10);
    V_SL    NUMBER;
    V_MRID  VARCHAR2(10);
    V_ZNJ   RECLIST.RLZNJ%TYPE;
    V_BATCH PAYMENT.PBATCH%TYPE;

    V_BJMZJE RECLIST.RLJE%TYPE; --����ǰ�ܽ��
    V_BJE1   RECDETAIL.RDJE%TYPE; --����ǰ���1
    V_BJE2   RECDETAIL.RDJE%TYPE; --����ǰ���2
    V_BJE3   RECDETAIL.RDJE%TYPE; --����ǰ���3
    V_BJE4   RECDETAIL.RDJE%TYPE; --����ǰ���4
    V_BJE5   RECDETAIL.RDJE%TYPE; --����ǰ���5
    V_BJE6   RECDETAIL.RDJE%TYPE; --����ǰ���6
    V_BJE7   RECDETAIL.RDJE%TYPE; --����ǰ���7

    V_AJMZJE RECLIST.RLJE%TYPE; --������ܽ��
    V_AJE1   RECDETAIL.RDJE%TYPE; --�������1
    V_AJE2   RECDETAIL.RDJE%TYPE; --�������2
    V_AJE3   RECDETAIL.RDJE%TYPE; --�������3
    V_AJE4   RECDETAIL.RDJE%TYPE; --�������4
    V_AJE5   RECDETAIL.RDJE%TYPE; --�������5
    V_AJE6   RECDETAIL.RDJE%TYPE; --�������6
    V_AJE7   RECDETAIL.RDJE%TYPE; --�������7
  BEGIN

    /* ��ͷУ�� */
    OPEN C_PH;
    FETCH C_PH
      INTO V_PH;
    IF C_PH%NOTFOUND OR C_PH%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ�����');
    END IF;
    IF V_PH.PAHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���������');
    END IF;
    IF V_PH.PAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '������ȡ��');
    END IF;
    /*ҵ����**/
    OPEN C_PDT;
    LOOP
      FETCH C_PDT
        INTO V_PDT;
      EXIT WHEN C_PDT%NOTFOUND OR C_PDT%NOTFOUND IS NULL;
      --ʵ�ճ���

      V_RET := PG_EWIDE_PAY_01.F_PAYBACK_BY_BATCH(V_PDT.PADPBATCH,
                                                  V_PH.PAHSMFID,
                                                  P_PER,
                                                  V_PH.PAHSMFID,
                                                  'C');
      IF V_RET <> '000' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '����ʧ�ܣ�');
      END IF;
      --ȡ��ʵ�ճ�����Ƿ����Ϣ
      SELECT *
        INTO V_RL
        FROM RECLIST RL
       WHERE RL.RLPAIDFLAG = 'N'
         AND RL.RLREVERSEFLAG = 'N'
         AND RLID IN (SELECT RLID
                        FROM RECLISTTEMPCZ
                       WHERE RLSCRRLID = V_PDT.PADPLRLID);
      --Ӧ�ճ���
      PG_EWIDE_RECTRANS_01.�����������(V_PH.PAHSMFID,
                                  V_PH.PAHDEPT,
                                  V_PH.PAHCREPER,
                                  V_PH.PAHCREDATE,
                                  V_RL,
                                  V_YSHNO,
                                  'N');
      PG_EWIDE_RECTRANS_01.SP_RECCZ(V_YSHNO, P_PER, '����۳���', 'N');

      --׷���շ�
      --������ˮ��
      V_YSHNO       := NULL;
      V_RL.RLREADSL := V_RL.RLSL - NVL(V_PDT.PADCRSL, 0);
      V_RL.RLSL     := V_RL.RLREADSL;
      --ˮ�۱Ƚ�
      IF V_PDT.PADPLPRICEDJ <= FGETPRICEDJ(V_PDT.PADPLPFIDN) THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��ǰˮ�۲�����ʷˮ�۵ͣ����ܼ����');
      END IF;
      V_RL.RLPFID := V_PDT.PADPLPFIDN;
      IF V_RL.RLSL > 0 THEN
        PG_EWIDE_RECTRANS_01.����׷������(V_PH.PAHSMFID,
                                    V_PH.PAHDEPT,
                                    V_PH.PAHCREPER,
                                    V_PH.PAHCREDATE,
                                    V_RL,
                                    V_YSHNO,
                                    'N',
                                    '�����˷�׷��');
        PG_EWIDE_RECTRANS_01.SP_RECTRANS102(V_YSHNO, P_PER);
        --����ˮ��
        --�õ��������Ƿ����Ϣ
        SELECT T.RTHRLID, T.RTHREADSL, T.RTHMRID
          INTO V_RLID, V_SL, V_MRID
          FROM RECTRANSHD T
         WHERE T.RTHNO = V_YSHNO;
      END IF;
      OPEN C_RL(V_RLID, V_PDT.PADPLRLID);
      LOOP
        FETCH C_RL
          INTO V_RL;
        EXIT WHEN C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL;
        TOOLS.SP_BILLSEQ('110', V_YSHNO, 'N');
        BEGIN
          --û�м��������
          SELECT RL.RLZNJ
            INTO V_ZNJ
            FROM RECLIST RL
           WHERE RL.RLID IN
                 (SELECT RLSCRRLID FROM RECLISTTEMPCZ WHERE RLID = V_RL.RLID);
          --   V_RL.RLZNJ := V_ZNJ;
        EXCEPTION
          WHEN OTHERS THEN
            --���������
            V_ZNJ := V_PDT.PADPLZNJ - NVL(V_PDT.PADCRZNJ, 0);
        END;
        --  V_RL.RLZNJ := V_PDT.PADPLZNJ;
        --ΥԼ�����
        PG_EWIDE_RECZNJ_01.����ΥԼ����ⵥ��(V_PH.PAHSMFID,
                                     V_PH.PAHDEPT,
                                     V_PH.PAHCREPER,
                                     V_PH.PAHCREDATE,
                                     V_RL,
                                     V_YSHNO,
                                     V_ZNJ,
                                     'N');
        PG_EWIDE_RECZNJ_01.SP_RECZNJJM(V_YSHNO, P_PER, 'N');

        V_RL.RLZNJ := V_ZNJ;
        V_BATCH    := FGETSEQUENCE('ENTRUSTLOG');
        V_RET      := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                          V_PH.PAHSMFID, --�ɷѻ���
                                          P_PER, --�տ�Ա
                                          V_RL.RLID || '|', --Ӧ����ˮ
                                          V_RL.RLJE, --Ӧ�ս��
                                          V_RL.RLZNJ, --����ΥԼ��
                                          0, --������
                                          V_RL.RLJE + V_RL.RLZNJ, --ʵ���տ�
                                          'P', --�ɷ�����
                                          V_RL.RLMID, --����
                                          'XJ', --���ʽ
                                          V_PH.PAHSMFID, --�ɷѵص�
                                          V_BATCH, --�ɷ�������ˮ
                                          'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                          '', --��Ʊ��
                                          'N' --�����Ƿ��ύ��Y/N��
                                          );
        IF V_RET <> '000' THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '����ʧ��');
        END IF;
      END LOOP;

      --�������
      SELECT SUM(RD.RDJE),
             SUM(DECODE(RD.RDPIID, '01', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '02', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '03', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '04', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '05', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '06', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '07', RDJE, 0))
        INTO V_BJMZJE,
             V_BJE1,
             V_BJE2,
             V_BJE3,
             V_BJE4,
             V_BJE5,
             V_BJE6,
             V_BJE7
        FROM RECDETAIL RD
       WHERE RD.RDID = V_PDT.PADPLRLID;
      BEGIN
        --���ݼ������
        SELECT SUM(RD.RDJE),
               SUM(DECODE(RD.RDPIID, '01', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '02', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '03', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '04', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '05', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '06', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '07', RDJE, 0))
          INTO V_AJMZJE,
               V_AJE1,
               V_AJE2,
               V_AJE3,
               V_AJE4,
               V_AJE5,
               V_AJE6,
               V_AJE7
          FROM RECDETAIL RD
         WHERE RD.RDID = V_RLID;
      EXCEPTION
        WHEN OTHERS THEN
          V_AJMZJE := 0;
          V_AJE1   := 0;
          V_AJE2   := 0;
          V_AJE3   := 0;
          V_AJE4   := 0;
          V_AJE5   := 0;
          V_AJE6   := 0;
          V_AJE7   := 0;
      END;
      --ȫ��
      IF V_RLID IS NULL THEN
        V_AJMZJE := 0;
        V_AJE1   := 0;
        V_AJE2   := 0;
        V_AJE3   := 0;
        V_AJE4   := 0;
        V_AJE5   := 0;
        V_AJE6   := 0;
        V_AJE7   := 0;
      END IF;
      --���µ�����˱�־
      UPDATE PAIDADJUSTDT T
         SET PADSHFLAG  = 'Y', --��˱�־
             T.PADNRLID = V_RLID, -- ��Ӧ����id
             T.PADCRJE  = V_BJMZJE - V_AJMZJE, --�����ܽ��
             T.PADCRJE1 = V_BJE1 - V_AJE1, --������1
             T.PADCRJE2 = V_BJE2 - V_AJE2, --������2
             T.PADCRJE3 = V_BJE3 - V_AJE3, --������3
             T.PADCRJE4 = V_BJE4 - V_AJE4, --������4
             T.PADCRJE5 = V_BJE5 - V_AJE5, --������5
             T.PADCRJE6 = V_BJE6 - V_AJE6, --������6
             T.PADCRJE7 = V_BJE7 - V_AJE7 --������7
       WHERE CURRENT OF C_PDT;

    END LOOP;

    --���µ�ͷ��˱�־
    --���µ�����˱�־
    UPDATE PAIDADJUSTHD
       SET PAHSHDATE = SYSDATE,
       PAHSHPER = P_PER,
        -- PAHSHPER = pahcreper ,
        PAHSHFLAG = 'Y'
     WHERE PAHNO = P_BILLNO;

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    --�ر��α�
    IF C_PH%ISOPEN THEN
      CLOSE C_PH;
    END IF;
    IF C_PDT%ISOPEN THEN
      CLOSE C_PDT;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_PH%ISOPEN THEN
        CLOSE C_PH;
      END IF;
      IF C_PDT%ISOPEN THEN
        CLOSE C_PDT;
      END IF;
      ROLLBACK;
      TOOLS.SP_BKEVENT_REC('SP_�����˷�',
                           1,
                           V_RL.RLID || ',' || TO_CHAR(V_RL.RLJE),
                           '');
      COMMIT;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

PROCEDURE SP_PAIDBAK(P_NO IN VARCHAR2, P_PER IN VARCHAR2) IS
    LS_RETSTR VARCHAR2(100);
    --��ͷ
    CURSOR C_HD IS
      SELECT * FROM PAIDADJUSTHD WHERE PAHNO = P_NO FOR UPDATE;
    --����
    CURSOR C_DT IS
      SELECT *
        FROM PAIDADJUSTDT
       WHERE PADNO = P_NO
         AND NVL(PADCHKFLAG, 'N') = 'Y'
         FOR UPDATE;

    V_HD PAIDADJUSTHD%ROWTYPE;
    V_DT PAIDADJUSTDT %ROWTYPE;
		v_temp number default 0;
  BEGIN
    OPEN C_HD;
    FETCH C_HD
      INTO V_HD;
    /*��鴦��*/
    IF C_HD%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '���ݲ�����,�����Ѿ�����������Ա������');
    END IF;
    IF V_HD.PAHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѿ���ˣ�');
    END IF;
    IF V_HD.PAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '������ȡ����');
    END IF;
    /*������*/
    OPEN C_DT;
    LOOP
      FETCH C_DT INTO V_DT;
      EXIT WHEN C_DT%NOTFOUND OR C_DT%NOTFOUND IS NULL;

			--�ж�����ǻ���Ԥ�潻��,��������˵���,���������!!! byj add
      if v_dt.padptrans = 'H' and v_dt.padpmonth < '2016.05' then
         RAISE_APPLICATION_ERROR(ERRCODE,'�ɷ����κ�' || v_dt.padpbatch || '��������ʵʩǰ�ɷ�,��ʱ���ܳ���!' );
      end if;
      begin
        select 1
          into v_temp
          from baseallot ba
         where ba.bapid in (select pid from payment where pbatch = v_dt.padpbatch and v_dt.padptrans = 'H') and
               ba.bastatus = 'Y' and
               rownum < 2;
      exception
        when no_data_found then
          null;
      end;
      if v_temp = 1 then
         RAISE_APPLICATION_ERROR(ERRCODE,'�ɷ����κ�' || v_dt.padpbatch || '���������������,���ܳ���!' );
      end if;
      --end!!!

      --�˵�
      insert into pbparmtemp_sms(c1,c2) values (v_hd.pahcreper,v_hd.pahcreper);
      LS_RETSTR := PG_EWIDE_PAY_01.F_PAYBACK_BY_BATCH(V_DT.PADPBATCH,
                                                      V_HD.PAHSMFID,
                                                       V_HD.PAHCREPER, -- P_PER,
                                                       V_HD.PAHSMFID,
                                                      'C');
      IF LS_RETSTR <> '000' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�˵�ʧ�ܣ�');
      END IF;
    END LOOP;
    UPDATE PAIDADJUSTHD
       SET PAHSHFLAG = 'Y',
        PAHSHDATE = SYSDATE,
       PAHSHPER = P_PER
       --  PAHSHPER = pahcreper
     WHERE CURRENT OF C_HD;

    --���´�������
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(V_HD.PAHNO);
    IF C_HD%ISOPEN THEN
      CLOSE C_HD;
    END IF;
    IF C_DT%ISOPEN THEN
      CLOSE C_DT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF C_HD%ISOPEN THEN
        CLOSE C_HD;
      END IF;
      IF C_DT%ISOPEN THEN
        CLOSE C_DT;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;


PROCEDURE SP_�ޱ���� IS

--�ޱ������ϱ��α�
CURSOR C_MI IS
SELECT MI.*
FROM METERINFO MI,BOOKFRAME BF
WHERE MIBFID=BFID AND
      MISTATUS IN ('29','30') AND
      MICOLUMN5>0 and
      mipfid is not null AND
      --TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH,'YYYY.MM'),-BFRCYC),'YYYY.MM')=TOOLS.FGETREADMONTH(MISMFID)
      BFMONTH=TOOLS.FGETREADMONTH(MISMFID)
      /*BFNRMONTH=TOOLS.FGETREADMONTH(MISMFID)*/;



MI    METERINFO%ROWTYPE;
RL    RECLIST%ROWTYPE;
CI    CUSTINFO%ROWTYPE;
MD    METERDOC%ROWTYPE;
MA    METERACCOUNT%ROWTYPE;
PD    PRICEDETAIL%ROWTYPE;
RD    RECDETAIL%ROWTYPE;
V_DJ  NUMBER(12,3);
MR    METERREAD%ROWTYPE;


CURSOR C_PD IS
SELECT * FROM PRICEDETAIL WHERE PDPFID=MI.MIPFID;

BEGIN
 OPEN C_MI;
    LOOP
      FETCH C_MI
        INTO MI;
      EXIT WHEN C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL;
      IF MI.MICOLUMN5 IS NULL THEN
         RAISE_APPLICATION_ERROR(ERRCODE, MI.Miid||'δ����ˮ��');
      END IF;
      IF MI.MIPFID IS NULL THEN
         RAISE_APPLICATION_ERROR(ERRCODE, MI.Miid||'δ����ˮ��');
      END IF;

      SELECT * INTO CI FROM CUSTINFO WHERE CIID=MI.MICID;
      SELECT * INTO MD FROM METERDOC WHERE MDMID=MI.MIID;
      SELECT * INTO MA FROM METERACCOUNT WHERE MAMID=MI.MIID;

      --��ӳ����
      MR.MRID    := FGETSEQUENCE('METERREAD'); --��ˮ��
      MR.MRMONTH := TOOLS.FGETREADMONTH(MI.MISMFID); --�����·�
      MR.MRSMFID := FGETMETERINFO(MI.MIID, 'MISMFID'); --Ӫ����˾
      MR.MRBFID  := MI.MIBFID; --���
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
      MR.MRRDATE     := SYSDATE; --��������
      BEGIN
        SELECT MAX(T.BFRPER)
          INTO MR.MRRPER
          FROM BOOKFRAME T
         WHERE T.BFID = MI.MIBFID
           AND T.BFSMFID = MI.MISMFID;
      EXCEPTION
        WHEN OTHERS THEN
          MR.MRRPER := NULL; --����Ա
      END;

      MR.MRPRDATE        := NULL; --�ϴγ�������
      MR.MRSCODE         := 0; --���ڳ���
      MR.MRECODE         := 0; --���ڳ���
      MR.MRSL            := MI.MICOLUMN5; --����ˮ��
      MR.MRFACE          := NULL; --ˮ�����
      MR.MRIFSUBMIT      := 'Y'; --�Ƿ��ύ�Ʒ�
      MR.MRIFHALT        := 'N'; --ϵͳͣ��
      MR.MRDATASOURCE    := 'Z'; --��������Դ�����񳭱�
      MR.MRIFIGNOREMINSL := 'N'; --ͣ����ͳ���
      MR.MRPDARDATE      := NULL; --���������ʱ��
      MR.MROUTFLAG       := 'N'; --�������������־
      MR.MROUTID         := NULL; --�������������ˮ��
      MR.MROUTDATE       := NULL; --���������������
      MR.MRINORDER       := NULL; --��������մ���
      MR.MRINDATE        := NULL; --�������������
      MR.MRRPID          := '00'; --�Ƽ�����
      MR.MRMEMO          := '�ޱ�����'; --����ע
      MR.MRIFGU          := 'N'; --�����־
      MR.MRIFREC         := 'Y'; --�ѼƷ�
      MR.MRRECDATE       := SYSDATE; --�Ʒ�����
      MR.MRRECSL         := MI.MICOLUMN5; --Ӧ��ˮ��
      MR.MRADDSL         := 0; --����
      MR.MRCARRYSL       := 0; --��λˮ��
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
      MR.MRSCODECHAR     := '0'; --���ڳ���
      MR.MRECODECHAR     := '0'; --���ڳ���
      MR.MRPRIVILEGEFLAG := 'N'; --��Ȩ��־(Y/N)
      MR.MRPRIVILEGEPER  := NULL; --��Ȩ������
      MR.MRPRIVILEGEMEMO := NULL; --��Ȩ������ע
      MR.MRPRIVILEGEDATE := NULL; --��Ȩ����ʱ��
      MR.MRSAFID         := MI.MISAFID; --��������
      MR.MRIFTRANS       := MI.MISTATUS; --������������
      MR.MRREQUISITION   := 0; --֪ͨ����ӡ����
      MR.MRIFCHK         := MI.MIIFCHK; --���˱�

      INSERT INTO METERREAD VALUES MR;

      --���Ӧ��

      RL.RLID        := FGETSEQUENCE('RECLIST');
      RL.RLSMFID     := MI.MISMFID;
      RL.RLMONTH     := TOOLS.FGETRECMONTH(MI.MISMFID);
      RL.RLDATE      := TOOLS.FGETRECDATE(MI.MISMFID);
      RL.RLCID       := MI.MICID;
      RL.RLMID       := MI.MIID;
      RL.RLMSMFID    := MI.MISMFID;
      RL.RLCSMFID    := CI.CISMFID;
      RL.RLCCODE     := CI.CICODE;
      RL.RLCHARGEPER := MI.MICPER;
      RL.RLCPID      := CI.CIPID;
      RL.RLCCLASS    := CI.CICLASS;
      RL.RLCFLAG     := CI.CIFLAG;
      RL.RLUSENUM    := MI.MIUSENUM;
      RL.RLCNAME     := CI.CINAME;
      --rl.rlcname2      := ;
      RL.RLCADR        := CI.CIADR;
      RL.RLMADR        := MI.MIADR;
      RL.RLCSTATUS     := CI.CISTATUS;
      RL.RLMTEL        := CI.CIMTEL;
      RL.RLTEL         := CI.CITEL1;
      RL.RLBANKID      := MA.MABANKID;
      RL.RLTSBANKID    := MA.MATSBANKID;
      RL.RLACCOUNTNO   := MA.MAACCOUNTNO;
      RL.RLACCOUNTNAME := MA.MAACCOUNTNAME;
      RL.RLIFTAX       := MI.MIIFTAX;
      RL.RLTAXNO       := MI.MITAXNO;
      RL.RLIFINV       := CI.CIIFINV; --��Ʊ��־
      RL.RLMCODE       := MI.MICODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := NULL; --???
      RL.RLBFID        := MI.MIBFID; --
      RL.RLPRDATE      := NULL; --
      RL.RLRDATE       := NULL;
      RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '08',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   1),
                                        'yyyymm') || '08',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);
      RL.RLCALIBER     := MD.MDCALIBER;
      RL.RLRTID        := '1';
      RL.RLMSTATUS     := MI.MISTATUS;
      RL.RLMTYPE       := '1';
      RL.RLMNO         := MD.MDNO;
      /*     \*    rl.rlscode       := rth.rthscode;
      rl.rlecode       := rth.rthecode;*\*/

      RL.RLSCODE := 0;
      RL.RLECODE := 0;

      RL.RLREADSL       := 0;
      RL.RLINVMEMO      := '�ޱ�Ӧ��';
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      RL.RLTRANS        := MI.MISTATUS; --�����Ӧ������ID�뵥������ɺ���ͬ
      RL.RLCD           := PG_EWIDE_METERREAD_01.DEBIT;
      RL.RLYSCHARGETYPE := MI.MICHARGETYPE;
      RL.RLSL           := MI.MICOLUMN5; --Ӧ��ˮ��ˮ������rlsl = rlreadsl + rladdsl��
      RL.RLJE           := 0; --������������,�ȳ�ʼ��
      RL.RLADDSL        := 0;
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDJE       := 0;
      RL.RLPAIDDATE     := NULL;
      RL.RLPAIDPER      := NULL;
      rl.rlmrid        := MR.MRID;
      RL.RLMEMO      := '�ޱ�Ӧ��';
      RL.RLZNJ       := 0;
      RL.RLLB        := MI.MILB;
      RL.RLPFID      := MI.MIPFID;
      RL.RLDATETIME  := SYSDATE;
      RL.RLPRIMCODE  := FGETMCODE(MI.MIPRIID);
      RL.RLPRIFLAG   := MI.MIPRIFLAG;
      RL.RLRPER      := NULL;
      RL.RLSAFID     := MI.MISAFID;
      RL.RLSCODECHAR := '0';
      RL.RLECODECHAR := '0';
      RL.RLILID      := NULL; --��Ʊ��ˮ��
      RL.RLMIUIID    := MI.MIUIID; --��λ����
      RL.RLGROUP     := 1; --Ӧ���ʷ���

      ---��ṹ�޸ĺ����������
      RL.RLPID          := NULL; --ʵ����ˮ����payment.pid��Ӧ��
      RL.RLPBATCH       := NULL; --�ɷѽ������Σ���payment.pbatch��Ӧ��
      RL.RLSAVINGQC     := 0; --�ڳ�Ԥ�棨����ʱ������
      RL.RLSAVINGBQ     := 0; --����Ԥ�淢��������ʱ������
      RL.RLSAVINGQM     := 0; --��ĩԤ�棨����ʱ������
      RL.RLREVERSEFLAG  := 'N'; --  ������־��nΪ������yΪ������
      RL.RLBADFLAG      := 'N'; --���ʱ�־��y :�����ʣ�o:�����������У�n:�����ʣ�
      RL.RLZNJREDUCFLAG := 'N'; --���ɽ�����־,δ����ʱΪn������ʱ���ɽ�ֱ�Ӽ��㣻�����Ϊy,����ʱ���ɽ�ֱ��ȡrlznj
      RL.RLMISTID       := MI.MISTID; --��ҵ����
      RL.RLMINAME       := MI.MINAME; --Ʊ������
      RL.RLSXF          := 0; --������
      RL.RLMIFACE2      := MI.MIFACE2; --��������
      RL.RLMIFACE3      := MI.MIFACE3; --�ǳ�����
      RL.RLMIFACE4      := MI.MIFACE4; --����ʩ˵��
      RL.RLMIIFCKF      := MI.MIIFCHK; --�����ѻ���
      RL.RLMIGPS        := MI.MIGPS; --�Ƿ��Ʊ
      RL.RLMIQFH        := MI.MIQFH; --Ǧ���
      RL.RLMIBOX        := MI.MIBOX; --����ˮ�ۣ���ֵ˰ˮ�ۣ���������
      RL.RLMINAME2      := MI.MINAME2; --��������(С��������������
      RL.RLMISEQNO      := MI.MISEQNO; --���ţ���ʼ��ʱ���+��ţ�
      RL.RLSCRRLID      := RL.RLID; --ԭӦ����ˮ
      RL.RLSCRRLTRANS   := RL.RLTRANS; --ԭӦ������
      RL.RLSCRRLMONTH   := RL.RLMONTH; --ԭӦ���·�
      RL.RLSCRRLDATE    := RL.RLDATE; --ԭӦ��������
      RL.RLCOLUMN5      := RL.RLDATE; --�ϴ�Ӧ��������
      RL.RLCOLUMN9      := RL.RLID; --�ϴ�Ӧ������ˮ
      RL.RLCOLUMN10     := RL.RLMONTH; --�ϴ�Ӧ�����·�
      RL.RLCOLUMN11     := RL.RLTRANS; --�ϴ�Ӧ��������


      RL.RLMICOMMUNITY   := MI.MICOMMUNITY; --С��
      RL.RLMIREMOTENO    := MI.MIREMOTENO; --Զ�����
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --Զ��hub��
      RL.RLMIEMAIL       := MI.MIEMAIL; --�����ʼ�
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --�����ֶ�1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --�����ֶ�2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --�����ֶ�3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --�����ֶ�3

      --�����ϸ
      OPEN C_PD;
      LOOP
        FETCH C_PD
          INTO PD;
        EXIT WHEN C_PD%NOTFOUND OR C_PD%NOTFOUND IS NULL;
        RD.RDID        := RL.RLID;
        RD.RDPMDID     := '1';
        RD.RDPIID      := PD.PDPIID;

        RD.RDPFID      := PD.PDPFID;
        RD.RDPSCID     := PD.PDPSCID;
        RD.RDCLASS     := 0; --�ݲ�֧�ֽ���Ʒ�
        RD.RDYSDJ      := PD.PDDJ;
        RD.RDYSSL      := RL.RLSL;
        RD.RDYSJE      := PD.PDDJ*RL.RLSL;
        RD.RDDJ        := PD.PDDJ;
        RD.RDSL        := RL.RLSL;
        RD.RDJE        := PD.PDDJ*RL.RLSL;
        RD.RDADJDJ     := 0;
        RD.RDADJSL     := 0;
        RD.RDADJJE     := 0;
        RD.RDMETHOD    := 'dj1'; --ֻ֧�̶ֹ�����
        RD.RDPAIDFLAG  := 'N';
        RD.RDPAIDDATE  := NULL;
        RD.RDPAIDMONTH := NULL;
        RD.RDPAIDPER   := NULL;
        RD.RDPMDSCALE  := 1;
        RD.RDILID      := NULL;
        RD.RDZNJ       := 0;
        RD.RDMEMO      := NULL;

        RD.RDMSMFID     := RL.RLSMFID; --Ӫ����˾
        RD.RDMONTH      := RL.RLMONTH; --�����·�
        RD.RDMID        := RL.RLMID; --ˮ����
        RD.RDPMDTYPE    := '01'; --������
        RD.RDPMDCOLUMN1 := NULL; --�����ֶ�1
        RD.RDPMDCOLUMN2 := NULL; --�����ֶ�2
        RD.RDPMDCOLUMN3 := NULL; --�����ֶ�3
        RL.RLJE         := RL.RLJE+ RD.RDJE;
        insert into recdetail values rd;

      END LOOP;
      CLOSE C_PD;
      BEGIN
        SELECT NVL(SUM(NVL(RLJE, 0) - NVL(RLPAIDJE, 0)), 0)
          INTO RL.RLPRIORJE
          FROM RECLIST T
         WHERE T.RLREVERSEFLAG = 'Y'
           AND T.RLPAIDFLAG = 'N'
           AND RLJE > 0
           AND RLMID = MI.MIID;
      EXCEPTION
        WHEN OTHERS THEN
          RL.RLPRIORJE := 0; --���֮ǰǷ��
      END;
      IF RL.RLPRIORJE > 0 THEN
        RL.RLMISAVING := 0;
      ELSE
        RL.RLMISAVING := MI.MISAVING; --���ʱԤ��
      END IF;
      INSERT INTO RECLIST VALUES RL;
    END LOOP;
 CLOSE C_MI;
 EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END;

------------by lmc 20131112
PROCEDURE SP_�����˷�NEW(P_RAHNO  IN VARCHAR2, --���ݱ��
                       P_PER    IN VARCHAR2, --�����
                       P_COMMIT IN VARCHAR --�Ƿ��ύ��־
                       ) IS
    CURSOR C_RHD IS
      SELECT * FROM RECADJUSTHD WHERE RAHNO = P_RAHNO;
    CURSOR C_RDT IS
      SELECT * FROM RECADJUSTDT WHERE RADNO = P_RAHNO;
    CURSOR C_RDTT(P_ROWNO IN NUMBER) IS
      SELECT *
        FROM RECADJUSTDDT
       WHERE RADDNO = P_RAHNO
         AND RADDROWNO = P_ROWNO;
    V_RHD     RECADJUSTHD%ROWTYPE;
    V_RDT     RECADJUSTDT%ROWTYPE;
    V_RET     VARCHAR2(10);
    V_RDTT    RECADJUSTDDT%ROWTYPE;
    V_STEP    NUMBER; --��������ȱ������������
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������
    V_RL      RECLIST%ROWTYPE;
    V_YSHNO   VARCHAR2(10);
    V_RLID    RECLIST.RLID%TYPE;
    V_PAYRLID VARCHAR2(3000); --��Ҫ������Ӧ��id
    V_PAYRL   RECLIST%ROWTYPE;
    V_BATCH   VARCHAR2(10);
  BEGIN

    V_PAYRL.RLZNJ := 0;
    V_PAYRL.RLJE  := 0;
    /*******begin:������ϢУ��*********/
    V_STEP    := 10;
    V_PRC_MSG := '������Ϣ���';
    OPEN C_RHD;
    FETCH C_RHD
      INTO V_RHD;
    IF C_RHD%NOTFOUND OR C_RHD%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(-20012, '���ݲ�������' || '��ͷ��Ϣ�����ڣ�');
    END IF;
    IF V_RHD.RAHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(-20012, '��������ˣ�');
    END IF;
    IF V_RHD.RAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(-20012, '������ȡ����');
    END IF;
    IF C_RHD%ISOPEN THEN
      CLOSE C_RHD;
    END IF;
    OPEN C_RDT;
    FETCH C_RDT
      INTO V_RDT;
    IF C_RDT%NOTFOUND OR C_RDT%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(-20012, '���ݲ�������' || '������Ϣ�����ڣ�');
    END IF;
    IF C_RDT%ISOPEN THEN
      CLOSE C_RDT;
    END IF;

    OPEN C_RDTT(V_RDT.RADROWNO);
    FETCH C_RDTT
      INTO V_RDTT;
    IF C_RDTT%NOTFOUND OR C_RDTT%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(-20012,
                              '���ݲ�������' || '�ӵ�����Ϣ�����ڣ�');
    END IF;
    IF C_RDTT%ISOPEN THEN
      CLOSE C_RDTT;
    END IF;
    /*******End:������ϢУ��*********/

    /*******begin:ҵ����*********/
    V_STEP    := 20;
    V_PRC_MSG := 'ʵ�ճ���';

    for i in(SELECT distinct radpbatch  FROM RECADJUSTDT where RADNO=P_RAHNO) loop

        V_RET := PG_EWIDE_PAY_01.F_PAYBACK_BY_BATCH(i.RADPBATCH,
                                                    V_RHD.RAHSMFID,
                                                    P_PER,
                                                    V_RHD.RAHSMFID,
                                                    'C');

        IF V_RET <> '000' THEN
          RAISE_APPLICATION_ERROR(-20012, '����ʧ�ܣ�');
        END IF;
    end loop;

    OPEN C_RDT;
    LOOP
      FETCH C_RDT
        INTO V_RDT;
      EXIT WHEN C_RDT%NOTFOUND OR C_RDT%NOTFOUND IS NULL;
      V_YSHNO:=null;
      --���ѡ�У�Ӧ�ճ�����׷������,����ֱ�Ӳ���
      IF NVL(V_RDT.RADCHKFLAG, 'N') = 'Y' THEN
        SELECT *
          INTO V_RL
          FROM RECLIST RL
         WHERE RL.RLPAIDFLAG = 'N'
           AND RL.RLREVERSEFLAG = 'N'
           AND RLID IN (SELECT RLID
                          FROM RECLISTTEMPCZ
                         WHERE RLSCRRLID = V_RDT.RADRLID);
        V_STEP    := 30;
        V_PRC_MSG := 'Ӧ�ճ���' || V_RL.RLID;
        PG_EWIDE_RECTRANS_01.�����������(V_RHD.RAHSMFID,
                                    V_RHD.RAHDEPT,
                                    V_RHD.RAHCREPER,
                                    V_RHD.RAHCREDATE,
                                    V_RL,
                                    V_YSHNO,
                                    'N');
        PG_EWIDE_RECTRANS_01.SP_RECCZ(V_YSHNO, P_PER, '�����˷ѳ���', 'N');

        V_STEP    := 40;
        V_PRC_MSG := '׷��' || V_RL.RLID;
        --�����ʱ��
        DELETE RECLIST_1METER_TMP;
        DELETE RECDETAIL_TMP;
        --������ʱ��
        INSERT INTO RECLIST_1METER_TMP
          SELECT * FROM RECLIST RL WHERE RLID = V_RL.RLID;

        INSERT INTO RECDETAIL_TMP
          SELECT * FROM RECDETAIL RD WHERE RDID = V_RL.RLID;
        -----------------------------------------------------
        ------------------------------------------------------
        V_RLID := FGETSEQUENCE('RECLIST');
        --������ʱ��Ϊ����������
        UPDATE RECDETAIL_TMP T
           SET (     T.RDSL, T.RDDJ, T.RDJE, T.RDADJDJ, T.RDADJSL, T.RDADJJE) = (SELECT nvl(DTT.RADDSL,0),
                                                                                        nvl(DTT.RADDYSDJ,0),
                                                                                        nvl(DTT.RADDJE,0),
                                                                                        nvl(DTT.RADDADJDJ,0),
                                                                                        nvl(DTT.RADDADJSL,0),
                                                                                        nvl(DTT.RADDADJJE,0)
                                                                                   FROM RECADJUSTDDT DTT
                                                                                  WHERE DTT.RADDNO =
                                                                                        P_RAHNO
                                                                                    AND DTT.RADDROWNO =
                                                                                        V_RDT.RADROWNO
                                                                                    AND DTT.RADDPIID =
                                                                                        T.RDPIID
                                                                                    AND DTT.RADDPFID =
                                                                                        T.RDPFID
                                                                                    ),
               T.RDID = V_RLID;

        UPDATE RECLIST_1METER_TMP RL
           SET (               RLSL, RLJE) = (SELECT SUM(DECODE(C.RDPIID,
                                                                '01',
                                                                C.RDSL,
                                                                0)),
                                                     SUM(RDJE)
                                                FROM RECDETAIL_TMP C),
               RLID             = V_RLID,
               RL.RLMEMO        = '�����˷�׷��',
               RL.RLZNJ         = NVL(V_RDT.RADZNJ, 0) +
                                  NVL(V_RDT.RADADZNJ, 0),
               RL.RLOUTFLAG     = 'Y', --�������Ƚ�������
               RL.RLREVERSEFLAG = 'N',
               RL.RLTRANS       = 'O';

        --��������������
        INSERT INTO RECLIST RL
          SELECT * FROM RECLIST_1METER_TMP;
        INSERT INTO RECDETAIL RD
          SELECT * FROM RECDETAIL_TMP;
        SELECT * INTO V_RL FROM RECLIST_1METER_TMP;

      ELSE
        SELECT *
          INTO V_RL
          FROM RECLIST RL
         WHERE RL.RLPAIDFLAG = 'N'
           AND RL.RLREVERSEFLAG = 'N'
           AND RLID IN (SELECT RLID
                          FROM RECLISTTEMPCZ
                         WHERE RLSCRRLID = V_RDT.RADRLID);
        UPDATE RECLIST RL
           SET RL.RLZNJ     = NVL(V_RDT.RADZNJ, 0) + NVL(V_RDT.RADADZNJ, 0),
               RL.RLOUTFLAG = 'Y'
         WHERE RLID = V_RL.RLID;

      END IF;

      IF V_PAYRLID IS NULL THEN
        V_PAYRLID := V_RL.RLID;
      ELSE
        V_PAYRLID := V_PAYRLID || ',' || V_RL.RLID;
      END IF;
      V_PAYRL.RLZNJ := V_PAYRL.RLZNJ + V_RL.RLZNJ;
      V_PAYRL.RLJE  := V_PAYRL.RLJE + V_RL.RLJE;
    END LOOP;
    V_PAYRLID := V_PAYRLID || '|';
    V_STEP    := 40;
    V_PRC_MSG := '����';
    V_BATCH   := FGETSEQUENCE('ENTRUSTLOG');
    if nvl(V_PAYRL.RLJE,0) + nvl(V_PAYRL.RLZNJ,0) >0  then
    V_RET := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                 V_RHD.RAHSMFID, --�ɷѻ���
                                 P_PER, --�տ�Ա
                                 V_PAYRLID, --Ӧ����ˮ
                                 V_PAYRL.RLJE, --Ӧ�ս��
                                 V_PAYRL.RLZNJ, --����ΥԼ��
                                 0, --������
                                 V_PAYRL.RLJE + V_PAYRL.RLZNJ, --ʵ���տ�
                                 'P', --�ɷ�����
                                 V_RDT.RADMID, --����
                                 'XJ', --���ʽ
                                 V_RHD.RAHSMFID, --�ɷѵص�
                                 V_BATCH, --�ɷ�������ˮ
                                 'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                 '', --��Ʊ��
                                 'N' --�����Ƿ��ύ��Y/N��
                                 );
    IF V_RET <> '000' THEN
      RAISE_APPLICATION_ERROR(-20012, '����ʧ��');
    END IF;
  end if;
    --���µ�����˱�־
    UPDATE RECADJUSTHD
       SET RAHSHDATE = SYSDATE,
       RAHSHPER = P_PER,
      -- RAHSHPER = rahcreper ,
        RAHSHFLAG = 'Y'
     WHERE RAHNO = P_RAHNO;

    /*******End:ҵ�������*********/
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;

    IF C_RHD%ISOPEN THEN
      CLOSE C_RHD;
    END IF;
    IF C_RDT%ISOPEN THEN
      CLOSE C_RDT;
    END IF;
    IF C_RDTT%ISOPEN THEN
      CLOSE C_RDTT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20012,
                              '��˴���ִ�в���[' || V_STEP || ']����ԭ��' || SQLERRM);
  END;

  PROCEDURE SP_Ԥ�����(P_NO IN VARCHAR2, P_PER IN VARCHAR2) AS
     CH CUSTCHANGEhd%ROWTYPE ;
     CD CUSTCHANGEDT%ROWTYPE;
     MI METERINFO%ROWTYPE;
     CI CUSTINFO%ROWTYPE ;

    V_RET   VARCHAR2(10);
    V_BATCH PAYMENT.PBATCH%TYPE;
     FLAGY         NUMBER;
    CURSOR C_CHD IS
      SELECT * FROM CUSTCHANGEhd WHERE cchno = P_NO;
     CURSOR C_CUSTINFO(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;
    CURSOR C_METERINFO(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID ;
    begin

       OPEN C_CHD ;
      FETCH C_CHD  INTO CH;
      IF C_CHD%NOTFOUND OR C_CHD%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�޴˵���');
      END IF;
      CLOSE C_CHD;


      IF CH.CCHSHFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '���������');
      END IF;
      IF CH.CCHSHFLAG = 'Q' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '������ȡ��');
      END IF;

      SELECT COUNT(*)
        INTO FLAGY
        FROM CUSTCHANGEDT
       WHERE ccdno = P_NO
         and CCDSHFLAG <>  'Y' ;
      IF FLAGY = 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'û����ҪԤ�������ˮ��!');
      END IF;


       FOR v_cursor in ( SELECT * FROM CUSTCHANGEDT WHERE ccdno = P_NO  ) loop
           select��*  into CD from CUSTCHANGEDT where ccdno =v_cursor.ccdno and  CCDROWNO =v_cursor.ccdrowno ;
              OPEN C_CUSTINFO(CD.CIID);
              FETCH C_CUSTINFO
                INTO CI;
              IF C_CUSTINFO%NOTFOUND OR C_CUSTINFO%NOTFOUND IS NULL THEN
                RAISE_APPLICATION_ERROR(ERRCODE, '�޴��û�');
              END IF;
              CLOSE C_CUSTINFO;

              OPEN C_METERINFO(CD.MIID);
              FETCH C_METERINFO
                INTO MI;
              IF C_METERINFO%NOTFOUND OR C_METERINFO%NOTFOUND IS NULL THEN
                RAISE_APPLICATION_ERROR(ERRCODE, '�޴�ˮ��');
              END IF;
              close C_METERINFO;
              if mi.misaving <= 0  then
                   RAISE_APPLICATION_ERROR(ERRCODE, '��Ԥ�������ܳ���');
               end if ;
              if CD.MISAVING > mi.misaving then
                   RAISE_APPLICATION_ERROR(ERRCODE, 'Ԥ������Ľ��ܴ���ʵ�ʵ�Ԥ�����');
              end if ;
             begin
                  select count(*)
                  into FLAGY
                  from reclist
                 where  rlreverseflag = 'N'
                  and rlbadflag = 'N'
                  and rlpaidflag = 'N'
                  and rlje >0
                  and rlcid =mi.miid;
               exception
                 when  others then
                  FLAGY:=0;
              end ;
              if FLAGY > 0 then
                  RAISE_APPLICATION_ERROR(ERRCODE, '��ˮ����Ƿ�Ѳ��ܽ���Ԥ�����');
               end if ;

                 V_BATCH    := FGETSEQUENCE('ENTRUSTLOG');
                  V_RET      := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                          CD.mismfid, --�ɷѻ���
                                          P_PER, --�տ�Ա
                                          '', --Ӧ����ˮ
                                          0, --Ӧ�ս��
                                          0, --����ΥԼ��
                                          0, --������
                                          - CD.MISAVING, --ʵ���տ�
                                          'S', --�ɷ�����  --��ʱԤ��ֿ�
                                          CD.MIID, --����
                                          'XJ', --���ʽ
                                          CD.mismfid, --�ɷѵص�
                                          V_BATCH, --�ɷ�������ˮ
                                          'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                          '', --��Ʊ��
                                          'N' --�����Ƿ��ύ��Y/N��
                                          );
                  IF V_RET <> '000' THEN
                    RAISE_APPLICATION_ERROR(ERRCODE, '����ʧ��');
                  END IF;

                  UPDATE METERINFO
                  SET MISTATUS=cd.MISTATUS   --ɾ����ʱ��ԭ֮ǰ��״̬
                  WHERE MIID=cd.miid;

                  UPDATE CUSTCHANGEDT
                 SET CCDSHFLAG = 'Y', CCDSHDATE = CURRENTDATE, CCDSHPER = P_PER,
                 MICOLUMN2 =V_BATCH  --��payment������
                 where ccdno =v_cursor.ccdno and  CCDROWNO =v_cursor.ccdrowno ;

          end loop ;

        UPDATE CUSTCHANGEHD
         SET CCHSHDATE = SYSDATE,  CCHSHPER = P_PER, CCHSHFLAG = 'Y'
       WHERE CCHNO = P_NO;

      --��������
      UPDATE KPI_TASK T
         SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
       WHERE T.REPORT_ID = TRIM(P_NO);
       commit ;
      end  ;


  PROCEDURE SP_Ԥ���˷�(P_NO IN VARCHAR2, P_PER IN VARCHAR2) AS  --add 20141126
     CH CUSTCHANGEhd%ROWTYPE ;
     CD CUSTCHANGEDT%ROWTYPE;
     MI METERINFO%ROWTYPE;
     CI CUSTINFO%ROWTYPE ;
     yc meterinfo_yccz%ROWTYPE ;
     V_RET    VARCHAR2(10);
     V_BATCH  PAYMENT.PBATCH%TYPE;
     FLAGY    NUMBER default 0;
     n_app    number default 1;
     c_ptrans varchar2(3);
     c_err    varchar2(100);
     v_result varchar2(100);
     n_flag   number;
    CURSOR C_CHD IS
      SELECT * FROM CUSTCHANGEhd WHERE cchno = P_NO;
     CURSOR C_CUSTINFO(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;
    CURSOR C_METERINFO(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID ;
    cursor c_meters(v_priid varchar2,v_billType varchar2) is
      select micid,misaving from meterinfo where mipriid = v_priid and mistatus = v_billType;
    begin

      OPEN C_CHD ;
      FETCH C_CHD  INTO CH;
      IF C_CHD%NOTFOUND OR C_CHD%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�޴˵���');
      END IF;
      CLOSE C_CHD;


      IF CH.CCHSHFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '���������');
      END IF;
      IF CH.CCHSHFLAG = 'Q' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '������ȡ��');
      END IF;

      SELECT COUNT(*)
        INTO FLAGY
        FROM CUSTCHANGEDT
       WHERE ccdno = P_NO
         and CCDSHFLAG <>  'Y' ;
      IF FLAGY = 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'û����ҪԤ�������ˮ��!');
      END IF;


      FOR v_cursor in ( SELECT * FROM CUSTCHANGEDT WHERE ccdno = P_NO  ) loop
           select��*  into CD from CUSTCHANGEDT where ccdno =v_cursor.ccdno and  CCDROWNO =v_cursor.ccdrowno ;
           OPEN C_CUSTINFO(CD.CIID);
           FETCH C_CUSTINFO INTO CI;
           IF C_CUSTINFO%NOTFOUND OR C_CUSTINFO%NOTFOUND IS NULL THEN
              RAISE_APPLICATION_ERROR(ERRCODE, '�޴��û�');
           END IF;
           CLOSE C_CUSTINFO;

           OPEN C_METERINFO(CD.MIID);
           FETCH C_METERINFO INTO MI;
           IF C_METERINFO%NOTFOUND OR C_METERINFO%NOTFOUND IS NULL THEN
               RAISE_APPLICATION_ERROR(ERRCODE, '�޴�ˮ��');
           END IF;
           close C_METERINFO;

           --�ж��û����Ƿ����
           if mi.miname <> cd.miname then
              RAISE_APPLICATION_ERROR(ERRCODE, '�ڴ˹���������û�[' || cd.micid || ']�Ѹ���,��˲�!');
           end if;

           if pg_ewide_job_hrb2.f_getAccountPrecash(cd.micid) <> cd.misaving then
              RAISE_APPLICATION_ERROR(ERRCODE, '�ڴ˹���������û�[' || cd.micid || ']��Ԥ������ѱ�����,��˲�!');
           end if;

           --�ж��Ƿ���Ƿ��
           begin
             select 1 into n_flag
               from reclist rl
              where rlprimcode = cd.mipriid
                and rlreverseflag = 'N'
                and rlbadflag = 'N'
                and rlpaidflag = 'N'
                and rlje >0
                and rownum < 2;
           exception
              when no_data_found then
                null;
           end;
           if n_flag = 1 then
              RAISE_APPLICATION_ERROR(ERRCODE, '�ڴ˹���������û�[' || cd.micid || ']��Ƿ��,��˲�!');
           end if;



            /*if mi.misaving <= 0  then
                 RAISE_APPLICATION_ERROR(ERRCODE, '��Ԥ�������ܳ���');
            end if ;*/
           /* if CD.MISAVING > mi.misaving then
                 RAISE_APPLICATION_ERROR(ERRCODE, 'Ԥ������Ľ��ܴ���ʵ�ʵ�Ԥ�����');
            end if ;*/

            /*begin
              select 1
                into FLAGY
                from reclist
               where rlreverseflag = 'N'
                     and RLPRIMCODE = mi.mipriid
                     and rlbadflag = 'N'
                     and rlpaidflag = 'N'
                     and rlje >0
                     and rownum < 2;
            exception
               when  others then
                 flagy := 0;
            end ;
            if FLAGY > 0 then
                RAISE_APPLICATION_ERROR(ERRCODE, '���û���Ƿ�Ѳ��ܽ���Ԥ���˷�����!!');
            end if ;*/

            --Ԥ���ת�� ������Ǻ��ձ����ӱ�����Ԥ���,�Ȱ�Ǯת�Ƶ������ϣ�
            for rec_meter in c_meters(mi.mipriid,CH.CCHLB) loop
               if rec_meter.micid <> mi.mipriid and nvl(rec_meter.misaving,0) > 0 then
                  select fgetsequence('ENTRUSTLOG') INTO V_BATCH from dual;
                  v_result := pg_ewide_pay_hrb.f_remaind_trans1(rec_meter.micid, --ת��ˮ���
                              mi.mipriid,                                        --ת��ˮ�����Ϻ�
                              nvl(rec_meter.misaving,0),                         --ת�ƽ��=��ˮ�����ʽ��
                              V_BATCH,                                           --ʵ�����κ�
                              cd.mismfid,                                        --�ɷѻ���
                               'system',                                         --ת����Ա
                              cd.mismfid,                                        --
                               'N',                                              --�Ƿ��ύ
                              mi.mipriid);                                       --���ձ��
                  if v_result <> '000' then
                     RAISE_APPLICATION_ERROR(ERRCODE, 'Ԥ���ת�ƴ���!' );
                  end if;
               end if;
            end loop;

            --Ԥ���˿�ʱˮ��ָ�뱣���� ycnote��
            select connstr(miid || ':' || MIRCODE)
              into yc.ycnote
              from meterinfo mi
             where mi.mipriid = cd.mipriid and
                   mi.mistatus = ch.cchlb;

            if ch.cchlb = '36' then
               c_ptrans := 'y';
               --yc.ycnote := 'Ԥ������˷�����';
            elsif ch.cchlb = '39' then
               c_ptrans := 'Y';
               --yc.ycnote := 'Ԥ�������˷�����';
            end if;




            select fgetsequence('ENTRUSTLOG') into V_BATCH from dual;
            v_result := PG_EWIDE_PAY_01.pos(  '01',                                            --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                               cd.mismfid,                                     --�ɷѻ���
                                               P_PER,                                          --�տ�Ա
                                               '',                                             --Ӧ����ˮ��
                                               0,                                              --Ӧ�ս��
                                               0,                                              --���ɽ�
                                               0,                                              --������
                                               0 - cd.misaving,                                --ʵ���տ� ����Ԥ���
                                               c_ptrans,                                       --�ɷ����� ����Ԥ��
                                               cd.mipriid,                                     --ˮ�����Ϻ�(��������)
                                               'XJ',                                           --���ʽ(�ֽ�)
                                               cd.mismfid,                                     --�ɷѵص�
                                               v_batch,                                        --��������
                                               'N',                                            --����Ʊ
                                               '',                                             --��Ʊ��
                                               'N'                                             --�Ƿ��ύ

            );
            if v_result <> '000' then
               RAISE_APPLICATION_ERROR(ERRCODE, '��Ԥ����������!'|| v_result );
            end if;

            if CH.CCHLB ='36' then --Ԥ������˷�����
                 /*yc.yctype :='1' ;
                 yc.ycnote :='Ԥ������˷�����' ;*/
               UPDATE METERINFO
                  SET MISTATUS = cd.miyl5 ,  --ɾ����ʱ��ԭ֮ǰ��״̬(������miyl5��)
                      MIYL8 = to_number(yc.yctype)
                WHERE mipriid = mi.mipriid and
                      mistatus = CH.CCHLB ;
            elsif CH.CCHLB ='39' then --Ԥ�������˷�����
                /*yc.yctype :='2' ;
                yc.ycnote :='Ԥ�������˷�����' ;*/

                --ѭ��ע������ǰ�������û���ÿ��ˮ��
                for rec_meter in c_meters(mi.mipriid,CH.CCHLB) loop
                   PG_EWIDE_JOB_HRB2.prc_meterCancellation( rec_meter.micid,
                                                            ch.cchlb,
                                                            p_per,
                                                            n_app,
                                                            c_err
                   );
                   if n_app < 0 then
                      RAISE_APPLICATION_ERROR(ERRCODE, c_err);
                   end if;
                end loop;
            end if ;

            yc.ycmonth :=to_char(sysdate,'yyyy.mm') ;
            select to_char(seq_meterinfo_yccb.nextval,'00000000') into yc.ycinvno from dual ;
            yc.ycinvno :=trim(substrb(mi.mismfid,3,2))||trim(yc.ycinvno);
            insert into meterinfo_yccz
              (ycid,                       --Ԥ���˿�����(������)
               ycmonth,                    --Ԥ���˿��·�
               ycmfid,                     --�ֹ�˾
               ycmibfid,                   --���ID
               ycmid,                      --ˮ����(���������)
               ycminame,                   --��Ȩ��
               ycmisaving,                 --��Ԥ�����
               yccredate,                  --Ԥ���˿��趨ʱ��
               yccreuser,                  --Ԥ���˿��趨��Ա
               ycfinflag,                  --Ԥ���˿���ɱ��
               ycfindate,                  --Ԥ���˿����ʱ��
               ycfinuser,                  --Ԥ���˿������Ա
               ycfinpid,                   --Ԥ���˿�ʵ�յ��ݺ�(��payment.PBATCH)��Ӧ
               ycnote,                     --Ԥ���˿ע
               ycinvflag,                  --Ԥ���˿Ʊע��
               ycinvno,                    --Ԥ���˿Ʊ����
               yctype)                     --Ԥ���˿�����
            values
              (CD.ccdno,
               yc.ycmonth,
               cd.cismfid,
               MI.MIBFID,
               cd.mipriid,
               MI.Miname,
               cd.Misaving,
               SYSDATE,
               P_PER,
               'N',
               null,
               null,
               v_batch,
               yc.ycnote,
               'N',
               yc.ycinvno,
               decode(CH.CCHLB,'36','1','39','2'));


            UPDATE CUSTCHANGEDT
               SET CCDSHFLAG = 'Y',
                   CCDSHDATE = CURRENTDATE,
                   CCDSHPER = P_PER,
                   MICOLUMN2 = V_BATCH  --��payment������
             where ccdno =v_cursor.ccdno and
                   CCDROWNO =v_cursor.ccdrowno ;

      end loop ;

      --���¹�����ͷ
      UPDATE CUSTCHANGEHD
         SET CCHSHDATE = SYSDATE,
             CCHSHPER = P_PER,
             CCHSHFLAG = 'Y'
       WHERE CCHNO = P_NO;

      --��������
      UPDATE KPI_TASK T
         SET T.DO_DATE = SYSDATE,
             T.ISFINISH = 'Y'
       WHERE T.REPORT_ID = TRIM(P_NO);
       commit ;
  end;
BEGIN
  CURRENTDATE := TOOLS.FGETSYSDATE;
END;
/

