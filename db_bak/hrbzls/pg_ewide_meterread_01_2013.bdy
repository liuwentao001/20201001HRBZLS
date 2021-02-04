CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_METERREAD_01_2013" IS
  CALLOGTXT                 CLOB;
  ˮ������                  INTEGER;
  �ܱ����                  CHAR(1);
  �Ƿ��������              CHAR(1);
  ������ˮ��              NUMBER(10);
  ������ˮ����ˮ��          NUMBER(10);
  �����ѵ���                NUMBER(12, 2);
  �����Ѵ��ڷ�ˮ��ˮ����XԪ NUMBER(12, 2);
  ----yujia  2012-03-20
  �̶�����־   CHAR(1);
  �̶�������ֵ NUMBER(12, 2);
  �汾����       VARCHAR2(100);

  FUNCTION DEBUG(P_ARRSTR IN VARCHAR2) RETURN ARR IS
    P ARR;
  BEGIN
    FOR I IN 1 .. 1 LOOP
      IF P IS NULL THEN
        P := ARR(TOOLS.FMID(P_ARRSTR, I, 'Y', ','));
      ELSE
        P.EXTEND;
        P(P.LAST) := TOOLS.FMID(P_ARRSTR, I, 'Y', ',');
      END IF;
    END LOOP;

    RETURN P;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  PROCEDURE WLOG(P_TXT IN VARCHAR2) IS
  BEGIN
    CALLOGTXT := CALLOGTXT || CHR(10) ||
                 TO_CHAR(SYSDATE, 'mm-dd HH24:MI:SS >> ') || P_TXT;
  END;

  --�ⲿ���ã��Զ����
  PROCEDURE AUTOSUBMIT IS
  BEGIN
    FOR I IN (SELECT MRBFID, MRSMFID
                FROM METERREAD
               WHERE MRREADOK = 'Y'
                 AND MRIFREC = 'N'
               GROUP BY MRSMFID, MRBFID) LOOP
      SUBMIT(I.MRBFID || ',' || I.MRSMFID || '|');
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  --�ⲿ���ã��Զ����
  PROCEDURE SUBMIT(P_BFID IN VARCHAR2) IS
    VLOG      CLOB;
    V_FSCOUNT NUMBER(10);
  BEGIN
    IF P_BFID IS NOT NULL THEN
      SUBMIT(P_BFID, VLOG);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  PROCEDURE SUBMIT1(P_MICODE IN VARCHAR2) IS
    VLOG CLOB;
  BEGIN

    IF P_MICODE IS NOT NULL THEN
      SUBMIT1(P_MICODE, VLOG);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  --�����û��ͻ��������
  PROCEDURE SUBMIT1(P_MICODE IN VARCHAR2, LOG OUT CLOB) IS

    VMRID METERREAD.MRID%TYPE;
  BEGIN
    CALLOGTXT := NULL;
    WLOG('�ύ��ѣ��ͻ����룺' || P_MICODE);
    WLOG('������ѿͻ�����ţ�' || P_MICODE || ' ...');

    SELECT MRID
      INTO VMRID
      FROM METERREAD, METERINFO
     WHERE MRMID = MIID
       AND MICODE = P_MICODE
       AND MRIFREC = 'N' --δ�Ʒ�
       --AND MRIFSUBMIT = 'Y'
          /******* ��;���Ƿ���ѵ���������
                     ʱ�䣺2011-11-10
                    �޸��ˣ����Ⲩ
          *****/
       --AND MICLASS = 1
       --AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, '1') = 'Y'
       --AND MRIFHALT = 'N' --ͣ��(ϵͳָ��)
       AND MRREADOK = 'Y' --����״̬
     ORDER BY MICLASS DESC,
              (CASE
                WHEN MIPRIFLAG = 'Y' AND MIPRIID <> MICODE THEN
                 1
                ELSE
                 2
              END) ASC;
    --����ǰ��Դ���ܱ����²��Ҳ��ȴ����׳��쳣

    --���������¼����
    CALCULATE(VMRID);
    COMMIT;
    WLOG('��ѹ��̴������');
    WLOG('---------------------------------------------------');
    LOG := CALLOGTXT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      WLOG('�����¼' || VMRID || '���ʧ�ܣ��ѱ�����');
      LOG := CALLOGTXT;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --�ƻ��ڳ��������ύ���
  PROCEDURE SUBMIT(P_BFID IN VARCHAR2, LOG OUT CLOB) IS
    CURSOR C_MR(VBFID IN VARCHAR2, VSMFID IN VARCHAR2) IS
      SELECT MRID
        FROM METERREAD, METERINFO
       WHERE MRMID = MIID
         AND MRBFID = VBFID
         AND MRSMFID = VSMFID
         AND MRIFREC = 'N'
            /******* ��;���Ƿ���ѵ���������
                       ʱ�䣺2012-04-13
                      �޸��ˣ����Ⲩ
            *****/
         --AND MICLASS = 1
         --AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, '1') = 'Y' --δ�Ʒ�
         --AND MRIFSUBMIT = 'Y' --����Ʒ�(�û�����)
         --AND MRIFHALT = 'N' --ͣ��(ϵͳָ��)
         AND
             MRREADOK = 'Y' --����״̬
         --AND MIIFCHARGE = 'Y' -- �Ƿ����
       ORDER BY MICLASS DESC,
                (CASE
                  WHEN MIPRIFLAG = 'Y' AND MIPRIID <> MICODE THEN
                   1
                  ELSE
                   2
                END) ASC;
    --�α��в�������Դ������ǰ��Դ���ܱ����²��Ҳ��ȴ����׳��쳣

    VMRID  METERREAD.MRID%TYPE;
    VBFID  METERREAD.MRBFID%TYPE;
    VSMFID METERREAD.MRSMFID%TYPE;
  BEGIN
    CALLOGTXT := NULL;
    WLOG('�ύ��ѣ�������У�' || P_BFID);
    FOR I IN 1 .. TOOLS.FBOUNDPARA(P_BFID) LOOP
      VBFID  := TOOLS.FGETPARA(P_BFID, I, 1);
      VSMFID := TOOLS.FGETPARA(P_BFID, I, 2);
      WLOG('������ѱ��ţ�' || VBFID || ' ...');
      OPEN C_MR(VBFID, VSMFID);
      LOOP
        FETCH C_MR
          INTO VMRID;
        EXIT WHEN C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL;
        --���������¼����
        BEGIN

          CALCULATE(VMRID);
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            WLOG('�����¼' || VMRID || '���ʧ�ܣ��ѱ�����');
        END;
      END LOOP;
      CLOSE C_MR;
      WLOG('---------------------------------------------------');
    END LOOP;

    WLOG('��ѹ��̴������');
    LOG := CALLOGTXT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      LOG := CALLOGTXT;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --�ƻ����������
  PROCEDURE CALCULATE(P_MRID IN METERREAD.MRID%TYPE) IS
    CURSOR C_MR IS
      SELECT *
        FROM METERREAD
       WHERE MRID = P_MRID
         AND MRIFREC = 'N'
         FOR UPDATE NOWAIT;

    --�ֱܷ��ӱ����¼
    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2) IS
      SELECT MRSL, MRIFREC,MRREADOK
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPID = P_MPID;
    --һ������û���Ϣzhb
    CURSOR C_MR_PR(P_MIPRIID IN VARCHAR2) IS
      SELECT MIID
        FROM METERINFO, METERREAD
       WHERE MRMID(+) = MIID
         AND MIPRIID = P_MIPRIID
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y'
       ORDER BY MIID;

    --�����ӱ����¼
    CURSOR C_MR_PRI(P_PRIMCODE IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRMCODE
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPRIFLAG = 'Y'
         AND MIPRIID = P_PRIMCODE
         AND MICODE <> P_PRIMCODE
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y';

    --ȡ���ձ���Ϣ
    CURSOR C_MI(P_MID IN VARCHAR2) IS
      SELECT *
        FROM METERINFO
       WHERE MIID = P_MID;

    MR         METERREAD%ROWTYPE;
    MRCHILD    METERREAD%ROWTYPE;
    MRPRICHILD METERREAD%ROWTYPE;
    MI         METERINFO%ROWTYPE;
    MRL        METERREAD%ROWTYPE;
    MIL        METERINFO%ROWTYPE;
    MID        METERINFO.MIID%TYPE;
    V_TEMPSL   NUMBER;
    V_COUNT    NUMBER;
    V_ROW      NUMBER;
    V_READNUM  NUMBER;
  BEGIN
    OPEN C_MR;
    FETCH C_MR
      INTO MR;
    IF C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�ĳ���ƻ���ˮ��');
    END IF;
    --����������Դ  1��ʾ�ƻ�����   5��ʾԶ������   9��ʾ���������
    IF MR.MRSL < ������ˮ�� AND MR.MRDATASOURCE IN ('1', '5', '9', '2') AND
       (MR.MRRPID = '00' OR MR.MRRPID IS NULL) THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '����ˮ��С��������ˮ��������Ҫ���');
    END IF;
    --ˮ���¼
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('��Ч��ˮ����' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
    END IF;
    CLOSE C_MI;
    MR.MRRECSL := MR.MRSL;
    -----------------------------------------------------------------------------
    --�ӱ�ˮ���ּ��Ʒ��ܱ���ˮ��
    -----------------------------------------------------------------------------
    IF �ܱ���� = 'Y' THEN
      --����ֱܷ����Ƿ����δ����
      SELECT COUNT(*) INTO V_READNUM
      FROM METERINFO,METERREAD
      WHERE MIID=MRMID AND
            (MICODE=MR.MRMCODE OR MIPID=MR.MRMCODE)
            AND MRREADOK='N';
      IF V_READNUM>0 THEN
         WLOG('�����¼' || MR.MRID || '�ֱܷ��а���δ������ͣ��������');
         RAISE_APPLICATION_ERROR(ERRCODE,
                                  '�ֱܷ��а���δ������ͣ��������');
      END IF;

      OPEN C_MR_CHILD(MR.MRMCODE);
      FETCH C_MR_CHILD
        INTO MRCHILD.MRSL, MRCHILD.MRIFREC,MRCHILD.MRREADOK;
      WHILE C_MR_CHILD%FOUND LOOP
        --�ӱ�δ�Ʒ�
        /*IF MRCHILD.MRIFREC = 'N' THEN
          WLOG('�����¼' || MR.MRID || '�շ��ܱ����ӱ�δ�Ʒѣ���ͣ��������');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '�շ��ܱ��ӱ�δ�Ʒѣ���ͣ��������');
        END IF;*/
        --�ӱ�δ����
        IF MRCHILD.MRREADOK='N' THEN
           WLOG('�����¼' || MR.MRID || '�շ��ܱ����ӱ�δ������ͣ��������');
           RAISE_APPLICATION_ERROR(ERRCODE,
                                  '�շ��ܱ��ӱ�δ������ͣ��������');
        END IF;
        --����ˮ��
        MR.MRRECSL := MR.MRRECSL - MRCHILD.MRSL;
        FETCH C_MR_CHILD
          INTO MRCHILD.MRSL, MRCHILD.MRIFREC,MRCHILD.MRREADOK;
      END LOOP;
      CLOSE C_MR_CHILD;
      IF MR.MRRECSL < 0 THEN
        WLOG('�����¼' || MR.MRID || '�շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������');
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '�շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������');
      END IF;
    END IF;

    -----------------------------------------------------------------------------
    --�ж�һ��໧ �ֱ�������̯ˮ��
    IF MI.MICOLUMN9 = 'Y' THEN
      OPEN C_MR_PR(MR.MRMID);

      V_TEMPSL := MR.MRSL;
      V_ROW    := 1;
      SELECT COUNT(*)
        INTO V_COUNT
        FROM METERINFO
       WHERE MIPRIID = MR.MRMID
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y'
       ORDER BY MICOLUMN6;
      LOOP
        FETCH C_MR_PR
          INTO MID;
        EXIT WHEN C_MR_PR%NOTFOUND OR C_MR_PR%NOTFOUND IS NULL;
        MRL := MR;
        SELECT * INTO MIL FROM METERINFO WHERE MIID = MID;
        MRL.MRSMFID := MIL.MISMFID;
        MRL.MRCID   := MIL.MICID;
        MRL.MRMID   := MIL.MIID;
        MRL.MRCCODE := MIL.MICODE;
        MRL.MRBFID  := MIL.MIBFID;
        IF V_ROW >= V_COUNT THEN
          MRL.MRRECSL := TRUNC(V_TEMPSL);
        ELSE
          MRL.MRRECSL := TRUNC(MR.MRSL * MIL.MICOLUMN6);
        END IF;
        MRL.MRSAFID := MIL.MISAFID;
        V_TEMPSL    := V_TEMPSL - MRL.MRRECSL;
        V_ROW       := V_ROW + 1;
        IF MRL.mrifrec = 'N' AND
           MRL.MRIFSUBMIT = 'Y' AND
           MRL.MRIFHALT = 'N' AND
           MIL.MIIFCHARGE = 'Y' AND
           FCHKMETERNEEDCHARGE(MIL.MISTATUS, MIL.MIIFCHK, '1') = 'Y' THEN
           --�������
           CALCULATE(MRL, PG_EWIDE_METERTRANS_01.�ƻ�����, '0000.00');
        ELSIF MIL.MIIFCHARGE = 'N' OR MRL.MRIFHALT='Y' THEN
              --�������Ʒ�,�����ݼ�¼�����ÿ�
              CALCULATENP(MRL, PG_EWIDE_METERTRANS_01.�ƻ�����, '0000.00');
        END IF;

      END LOOP;
      MR.MRIFREC   := 'Y';
      MR.MRRECDATE := TRUNC(SYSDATE);
      IF C_MR_PR%ISOPEN THEN
        CLOSE C_MR_PR;
      END IF;

    ELSE
      IF MR.mrifrec = 'N' AND
         MR.MRIFSUBMIT = 'Y' AND
         MR.MRIFHALT = 'N' AND
         MI.MIIFCHARGE = 'Y' AND
         FCHKMETERNEEDCHARGE(MI.MISTATUS, MI.MIIFCHK, '1') = 'Y' THEN
         --�������
         CALCULATE(MR, PG_EWIDE_METERTRANS_01.�ƻ�����, '0000.00');
      ELSIF MI.MIIFCHARGE = 'N' OR MR.MRIFHALT='Y' THEN
            --�������Ʒ�,�����ݼ�¼�����ÿ�
            CALCULATENP(MR, PG_EWIDE_METERTRANS_01.�ƻ�����, '0000.00');
      END IF;

    END IF;
    -----------------------------------------------------------------------------
    --���µ�ǰ�����¼
    IF �Ƿ�������� = 'N' THEN
      UPDATE METERREAD
         SET MRIFREC   = MR.MRIFREC,
             MRRECDATE = MR.MRRECDATE,
             MRRECSL   = MR.MRRECSL,
             MRRECJE01 = MR.MRRECJE01,
             MRRECJE02 = MR.MRRECJE02,
             MRRECJE03 = MR.MRRECJE03,
             MRRECJE04 = MR.MRRECJE04
       WHERE CURRENT OF C_MR;
    ELSE
      UPDATE METERREAD
         SET MRRECDATE = MR.MRRECDATE,
             MRRECSL   = MR.MRRECSL,
             MRRECJE01 = MR.MRRECJE01,
             MRRECJE02 = MR.MRRECJE02,
             MRRECJE03 = MR.MRRECJE03,
             MRRECJE04 = MR.MRRECJE04
       WHERE CURRENT OF C_MR;
    END IF;
    CLOSE C_MR;
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
  END CALCULATE;

  -- ����ˮ������ѣ��ṩ�ⲿ����
  PROCEDURE CALCULATE(MR      IN OUT METERREAD%ROWTYPE,
                      P_TRANS IN CHAR,
                      P_NY    IN VARCHAR2) IS
    CURSOR C_MI(VMIID IN METERINFO.MIID%TYPE) IS
      SELECT * FROM METERINFO WHERE MIID = VMIID FOR UPDATE;

    CURSOR C_CI(VCIID IN CUSTINFO.CIID%TYPE) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCIID FOR UPDATE;

    CURSOR C_MD(VMIID IN METERDOC.MDMID%TYPE) IS
      SELECT * FROM METERDOC WHERE MDMID = VMIID FOR UPDATE;

    CURSOR C_MA(VMIID IN METERACCOUNT.MAMID%TYPE) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMIID FOR UPDATE;

    CURSOR C_PMD(VMID IN PRICEMULTIDETAIL.PMDMID%TYPE) IS
      SELECT *
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = VMID
       ORDER BY PMDID, PMDPFID
         FOR UPDATE;

    CURSOR C_PD(VPFID IN PRICEDETAIL.PDPFID%TYPE ) IS
      SELECT *
        FROM PRICEDETAIL T
       WHERE PDPFID = VPFID
       ORDER BY PDPSCID DESC;

    ----��ʷ�۸���ϵ
    CURSOR C_PD_LS(VPFID IN PRICEDETAIL.PDPFID%TYPE, PMONTH IN VARCHAR2) IS
      SELECT PDPSCID,
             PDPFID,
             PDPIID,
             PDDJ,
             PDSL,
             PDJE,
             PDMETHOD,
             PDSDATE,
             PDEDATE,
             PDSMONTH,
             PDEMONTH
        FROM PRICEDETAIL_VER T, PRICEVER
       WHERE SMONTH <= PMONTH
         AND EMONTH >= PMONTH
         AND PDPFID = VPFID
         AND ID = VERID
       ORDER BY PDPSCID DESC;

    CURSOR C_MISAVING(VMICODE VARCHAR2) IS
      SELECT *
        FROM METERINFO
       WHERE MICODE IN
             (SELECT MIPRIID FROM METERINFO WHERE MICODE = VMICODE)
         AND MICODE <> VMICODE
         AND MISAVING > 0;
    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;

    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;




    MI    METERINFO%ROWTYPE;
    CI    CUSTINFO%ROWTYPE;
    RL    RECLIST%ROWTYPE;
    RDNJF RECDETAIL%ROWTYPE;
    RL1   RECLIST%ROWTYPE;

    PMD    PRICEMULTIDETAIL%ROWTYPE;
    PD     PRICEDETAIL%ROWTYPE;
    temp_pd PRICEDETAIL%ROWTYPE;
    MD     METERDOC%ROWTYPE;
    MA     METERACCOUNT%ROWTYPE;
    RDTAB  RD_TABLE;
    PALTAB PAL_TABLE;
    temp_PALTAB PAL_TABLE ;

    TEMPJSSL  NUMBER;
    TEMPSL    NUMBER;
    MAXPMDID  NUMBER;
    TEMPPMDID NUMBER;
    CLASSCTL  CHAR(1) := 'N'; --Ĭ�ϲ�ȡ�����ݼƷѷ���

    I             NUMBER;
    VRD           RECDETAIL%ROWTYPE;
    V_DBSL        NUMBER; --���Ƚ�ˮ��
    V_SVAINGBATCH VARCHAR2(50);

    V_OUTPBATCH      VARCHAR2(1000); --Ԥ�����Σ������ձ�����
    V_��ĵ�����     NUMBER(10);
    V_�����ˮ��ֵ   NUMBER(10);
    V_��ѵĵ�����   NUMBER(10);
    V_��Ѽ������   NUMBER(10);
    V_�����Ŀ������ NUMBER(10);
    V_�����Ŀ������ NUMBER(10);
    V_��ϱ�ĵ����� NUMBER(10);
    V_FSCOUNT        NUMBER(10);
    V_PIGROUP        PRICEITEM.PIGROUP%TYPE;
    PI               PRICEITEM%ROWTYPE;
    V_RLFZCOUNT      NUMBER(10);
    V_RLFIRST        NUMBER(10);

    V_PER       NUMBER(10); --����
    V_MONTHS    NUMBER(10); --�·�
    V_PMISAVING METERINFO.MISAVING%TYPE;
    V_RETSTR    VARCHAR2(2000);
    V_BATCH     VARCHAR2(2000);
    V_TEST     VARCHAR2(2000);

    --Ԥ���Զ��ֿ�
    v_rlidlist varchar2(4000);
    v_rlid     reclist.rlid%type;
    v_rlje     number(12,3);
    v_znj      number(12,3);
    v_rljes    number(12,3);
    v_znjs      number(12,3);

    CURSOR C_YCDK IS
    select rlid,
       sum(rlje) rlje,
PG_EWIDE_PAY_01.getznjadj(rlid,sum(rlje),rlgroup,max(rlzndate ),RLSMFID,trunc(sysdate)) rlznj
  from reclist, meterinfo
 where rlmid = miid
   AND rlpaidflag = 'N'
   AND RLOUTFLAG = 'N'
   and RLREVERSEFLAG='N'
   AND RLJE <> 0
   AND ((MIPRIID=MI.MIPRIID AND MIPRIID='Y') OR (MIID=MI.MIID AND (MIPRIID='N' OR MIPRIID IS NULL)))

   --and rlmid in ('3120223832')
 group by rlmcode,MIID,MIPRIID,rlmonth, rlid, rlgroup,RLSMFID
 order by rlgroup,rlmonth,rlid,MIPRIID,MIID ;


  BEGIN
    --
    --yujia  2012-03-20
    /*    �̶�����־   := FPARA(MR.MRSMFID, 'GDJEFLAG');
    �̶�������ֵ := FPARA(MR.MRSMFID, 'GDJEZ');*/

    --����ˮ���¼
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('��Ч��ˮ����' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
    END IF;
    --����ˮ����
    OPEN C_MD(MR.MRMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      WLOG('��Ч��ˮ����' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
    END IF;
    --����ˮ������
    OPEN C_MA(MR.MRMID);
    FETCH C_MA
      INTO MA;
    CLOSE C_MA;
    --�����û���¼
    OPEN C_CI(MI.MICID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      WLOG('��Ч���û����' || MI.MICID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч���û����' || MI.MICID);
    END IF;
    DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;
    --�ǼƷѱ�ִ�пչ��̣������쳣
    --�����ӱ�
    IF TRUE THEN
      --reclist����������������������������������������������������������������������������������������������
      RL.RLID          := FGETSEQUENCE('RECLIST');
      RL.RLSMFID       := MR.MRSMFID;
      RL.RLMONTH       := TOOLS.FGETRECMONTH(MR.MRSMFID);
      RL.RLDATE        := TOOLS.FGETRECDATE(MR.MRSMFID);
      RL.RLCID         := MR.MRCID;
      RL.RLMID         := MR.MRMID;
      RL.RLMSMFID      := MI.MISMFID;
      RL.RLCSMFID      := CI.CISMFID;
      RL.RLCCODE       := MR.MRCCODE;
      RL.RLCHARGEPER   := MI.MICPER;
      RL.RLCPID        := CI.CIPID;
      RL.RLCCLASS      := CI.CICLASS;
      RL.RLCFLAG       := CI.CIFLAG;
      RL.RLUSENUM      := MI.MIUSENUM;
      RL.RLCNAME       := MI.MINAME;
      RL.RLCNAME2      := CI.CINAME;
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
      RL.RLIFINV       := 'N'; --CI.CIIFINV; --��Ʊ��־
      RL.RLMCODE       := MI.MICODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := MR.MRDAY;
      RL.RLBFID        := MR.MRBFID;
      RL.RLPRDATE      := MR.MRPRDATE;
      RL.RLRDATE       := MR.MRRDATE;
      --˰Ʊ�������ɽ�
      --   IF NVL(MI.MIIFTAX, 'N') = 'N' THEN
      RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);
      --  END IF;
      RL.RLCALIBER := MD.MDCALIBER;
      RL.RLRTID    := MI.MIRTID;
      RL.RLMSTATUS := MI.MISTATUS;
      RL.RLMTYPE   := MI.MITYPE;
      RL.RLMNO     := MD.MDNO;
      RL.RLSCODE   := MR.MRSCODE;
      RL.RLECODE   := MR.MRECODE;
      RL.RLREADSL := MR.MRRECSL;
      /*----����ҵ��20130307 ������������ˮ������ ��
      IF MR.MRRPID = '01' THEN
        RL.RLREADSL := 10 * MR.MRRECSL; --�����ݴ棬���ָ�
      ELSIF MR.MRRPID = '02' THEN
        RL.RLREADSL := 100 * MR.MRRECSL; --�����ݴ棬���ָ�
      ELSE
        RL.RLREADSL := MR.MRRECSL; --�����ݴ棬���ָ�
      END IF;*/
      -- RL.RLREADSL       := MR.MRRECSL; --�����ݴ棬���ָ�
      RL.RLINVMEMO      := MR.MRMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      RL.RLTRANS        := P_TRANS;
      RL.RLCD           := DEBIT;
      RL.RLYSCHARGETYPE := MI.MICHARGETYPE;
      RL.RLSL           := 0; --Ӧ��ˮ��ˮ������rlsl = rlreadsl + rladjsl��
      RL.RLJE           := 0; --������������,�ȳ�ʼ��
      RL.RLADDSL        := NVL(MR.MRADDSL, 0) - NVL(MR.MRCARRYSL, 0);
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDJE       := 0;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDPER      := NULL;
      RL.RLPAIDDATE     := NULL;
      RL.RLMRID         := MR.MRID;
      RL.RLMEMO         := MR.MRMEMO || '   [' || P_NY || '��ʷ����' || ']';
      RL.RLZNJ          := 0;
      RL.RLLB           := MI.MILB;
      RL.RLPFID         := MI.MIPFID;
      RL.RLDATETIME     := SYSDATE;
      IF MI.MIPRIFLAG='Y' THEN
         RL.RLPRIMCODE     := MI.MIPRIID; --��¼�����ӱ�
      ELSE
         RL.RLPRIMCODE     := RL.RLMID;
      END IF;

      RL.RLPRIFLAG      := MI.MIPRIFLAG;
      RL.RLRPER         := MR.MRRPER;
      RL.RLSAFID        := MR.MRSAFID;
      RL.RLSCODECHAR    := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR    := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP        := '1'; --Ӧ���ʷ���

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
      RL.RLSCRRLID      := RL.RLID; --ԭӦ������ˮ
      RL.RLSCRRLTRANS   := RL.RLTRANS; --ԭӦ��������
      RL.RLSCRRLMONTH   := RL.RLMONTH; --ԭӦ�����·�
      RL.RLSCRRLDATE    := RL.RLDATE; --ԭӦ��������
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
      RL.RLMIEMAILFLAG   := MI.MIEMAILFLAG; --�����Ƿ��ʼ�
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --�����ֶ�1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --�����ֶ�2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --�����ֶ�3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --�����ֶ�3
      RL.RLCOLUMN5       := RL.RLDATE; --�ϴ�Ӧ��������
      RL.RLCOLUMN9       := RL.RLID; --�ϴ�Ӧ������ˮ
      RL.RLCOLUMN10      := RL.RLMONTH; --�ϴ�Ӧ�����·�
      RL.RLCOLUMN11      := RL.RLTRANS; --�ϴ�Ӧ��������
      --��ĵ�����/ ��ѵĵ����� /�����Ŀ������
      V_��ĵ�����   := 0;
      V_�����ˮ��ֵ := RL.RLREADSL;
      --��ѯ�Ա�������
      PALTAB := NULL;
      CALADJUST(MR.MRMONTH,
                MR.MRSMFID,
                CI.CIID,
                MI.MIID,
                NULL,
                NULL,
                TO_CHAR(MD.MDCALIBER),
                '����ˮ��',
                PALTAB);
      --�����ȡ���ۼ�ֵ
      --����ˮ�� 02
      IF PALTAB IS NOT NULL THEN
        SP_GETJMSL(PALTAB, RL, V_��ĵ�����, V_�����ˮ��ֵ, '02', 'Y');
      END IF;

      --reclist��������������������������������������������������������������������������������������������������
      --������ϸ�㷨˵����
      --1�������ڻ�Ϸ��ʼ��������ɷ�����ϸ�����༴�ǻ�Ϸ������ȼ���ߣ�
      --2�����򻧱�����α������ɷ�����ϸ���ݣ�
      --3�������������ɷ�ʽ�£��α�ƥ���Ż����ݣ����������ϸ��
      --��Ҫ�����Ż���Чǰ���ǻ������߱������Ļ�����ʣ������Ż��޵�����Ŀ��
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN

--ȡˮ��  11 --�����Ե���  ��ˮ��+�۸����

       temp_PALTAB  := NULL;
        PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����',
                  PALTAB);
       if    PALTAB is not null then
      temp_PALTAB := f_getpfid(PALTAB);
        end if;
      if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
         MI.MIPFID := temp_PALTAB(1).palcaliber ;
         --����Ӧ����ˮ��
         rl.rlpfid :=  MI.MIPFID ;
      end if;



        --��ˮ��+�۸���� ������
        PALTAB         := NULL;
        V_��ѵĵ����� := 0;
        V_��Ѽ������ := V_�����ˮ��ֵ;



         CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����',
                  PALTAB);

        --��ˮ��+�۸���� 07
        --�����ȡ���ۼ�ֵ
        IF PALTAB IS NOT NULL THEN
          SP_GETJMSL(PALTAB, RL, V_��ѵĵ�����, V_��Ѽ������, '07', 'Y');
        END IF;

        --cmprice������ʡ���������������������������������������������������������������������������������������������
        --�Ұ汾��ߵķ�����ϸ
        IF P_NY = '0000.00' OR P_NY IS NULL THEN
          OPEN C_PD(MI.MIPFID);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;
    --ˮ�۵��� ��ˮ��+�۸����+������Ŀ
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����+������Ŀ',
                  PALTAB);
      if   PALTAB is not null then
      temp_PALTAB := f_getpfid_piid(PALTAB,PD.PDPIID);
      end if;
      if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
        begin
        select * into temp_pd from  pricedetail t  where t.pdpfid=temp_PALTAB(1).PALCALIBER  and t.pdpiid=temp_PALTAB(1).palpiid ;
          V_TEST :=temp_PALTAB(1).palpfid ;
          V_TEST :=temp_PALTAB(1).palpIid ;
          V_TEST :=temp_pd.Pddj ;
          temp_pd.PDPFID :=MI.MIPFID;
          pd :=temp_pd;
        exception when others then
          null;
        end;
      end if;

            --�������

            --���������ϸ����չ������ϸ���̶��ǻ����0
            --��ˮ��+�۸���� ������
            PALTAB := NULL;

            V_�����Ŀ������ := 0;
            V_�����Ŀ������ := V_��Ѽ������;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            --��ˮ��+�۸����+������Ŀ 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_�����Ŀ������,
                         V_�����Ŀ������,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_��ĵ�����,
                    V_��ѵĵ�����,
                    V_�����Ŀ������,
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD;

        ELSE

          OPEN C_PD_LS(MI.MIPFID, P_NY);
          LOOP
            FETCH C_PD_LS
              INTO PD;
            EXIT WHEN C_PD_LS%NOTFOUND;

            --ˮ�۵��� ��ˮ��+�۸����+������Ŀ
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����+������Ŀ',
                  PALTAB);
      if   PALTAB is not null then
      temp_PALTAB := f_getpfid_piid(PALTAB,PD.PDPIID);
      end if;
      if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
        begin
        select * into temp_pd from  pricedetail t  where t.pdpfid=temp_PALTAB(1).PALCALIBER  and t.pdpiid=temp_PALTAB(1).palpiid ;
          V_TEST :=temp_PALTAB(1).palpfid ;
          V_TEST :=temp_PALTAB(1).palpIid ;
          V_TEST :=temp_pd.Pddj ;
          temp_pd.PDPFID :=MI.MIPFID;
          pd :=temp_pd;
        exception when others then
          null;
        end;
      end if;





            --�������

            --���������ϸ����չ������ϸ���̶��ǻ����0
            --��ˮ��+�۸���� ������
            PALTAB := NULL;

            V_�����Ŀ������ := 0;
            V_�����Ŀ������ := V_��Ѽ������;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);






            --��ˮ��+�۸����+������Ŀ 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_�����Ŀ������,
                         V_�����Ŀ������,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_��ĵ�����,
                    V_��ѵĵ�����,
                    V_�����Ŀ������,
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD_LS;
        END IF;

        --cmprice������ʡ�������������������������������������������������������������������������������������������������
      ELSE
        --pricemultidetail��Ϸ��ʡ�����������������������������������������������������������������������������������

        --    v_��ĵ����� /v_�����ˮ��ֵ

        SELECT MAX(PMDID)
          INTO MAXPMDID
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = MI.MIID;
        TEMPSL := V_�����ˮ��ֵ; --������ۼ�����
        --tempsl := rl.rlreadsl; --������ۼ�����

        V_DBSL := 0; --����ˮ��
        WHILE C_PMD%FOUND AND TEMPSL >= 0 LOOP

          --�����������������
          IF PMD.PMDID = MAXPMDID THEN
            TEMPJSSL := TEMPSL;
          ELSE
            IF PMD.PMDTYPE = '00' THEN
              --�������������ϰ�����ֺ��ٰ��������
              TEMPJSSL := (CASE
                            WHEN TEMPSL >= TRUNC(PMD.PMDSCALE) THEN
                             TRUNC(PMD.PMDSCALE)
                            ELSE
                             TEMPSL
                          END);

              V_DBSL := V_DBSL + TEMPJSSL;

            ELSE
              TEMPJSSL := TRUNC((V_�����ˮ��ֵ - V_DBSL) * PMD.PMDSCALE);
            END IF;
            /* if pmd.pmdid = 0 then
              --�������������ϰ�����ֺ��ٰ��������
              tempjssl := (case when tempsl >= trunc(pmd.pmdscale) then trunc(pmd.pmdscale) else tempsl end);
              V_DBSL   := V_DBSL + tempjssl;
            else
              tempjssl := trunc((v_�����ˮ��ֵ - V_DBSL) * pmd.pmdscale);
            end if;*/
          END IF;

          ---�ֲ�ֱ� ��ϱ�ĵ����� := v_��ĵ����� ;
          V_��ϱ�ĵ����� := 0;
          IF V_��ĵ����� <> 0 THEN
            IF TEMPJSSL - V_��ĵ����� >= 0 THEN
              V_��ϱ�ĵ����� := V_��ĵ�����;
              V_��ĵ�����     := 0;
            ELSE
              V_��ϱ�ĵ����� := TEMPJSSL;
              V_��ĵ�����     := V_��ĵ����� - TEMPJSSL;
            END IF;
          END IF;


--ȡˮ��  11 --�����Ե���  ��ˮ��+�۸����

       temp_PALTAB  := NULL;
        PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����',
                  PALTAB);
       if    PALTAB is not null then
      temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
         PMD.PMDPFID := temp_PALTAB(1).palcaliber ;
         --����Ӧ����ˮ��
         rl.rlpfid :=  PMD.PMDPFID ;
        end if;

          --��ˮ��+�۸���� ������
          PALTAB         := NULL;
          V_��ѵĵ����� := 0;
          V_��Ѽ������ := TEMPJSSL;




          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    PMD.PMDPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '��ˮ��+�۸����',
                    PALTAB);

          --��ˮ��+�۸���� 07
          --�����ȡ���ۼ�ֵ
          IF PALTAB IS NOT NULL THEN
            SP_GETJMSL(PALTAB,
                       RL,
                       V_��ѵĵ�����,
                       V_��Ѽ������,
                       '07',
                       'Y');
          END IF;

          --�Ұ汾��ߵķ�����ϸ
          IF P_NY = '0000.00' OR P_NY IS NULL THEN
            OPEN C_PD(PMD.PMDPFID);
            LOOP
              FETCH C_PD
                INTO PD;
              EXIT WHEN C_PD%NOTFOUND;

 --ˮ�۵��� ��ˮ��+�۸����+������Ŀ
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  PMD.PMDPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����+������Ŀ',
                  PALTAB);
      if   PALTAB is not null then
      temp_PALTAB := f_getpfid_piid(PALTAB,PD.PDPIID);
      end if;
      if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
        begin
        select * into temp_pd from  pricedetail t  where t.pdpfid=temp_PALTAB(1).PALCALIBER  and t.pdpiid=temp_PALTAB(1).palpiid ;
          V_TEST :=temp_PALTAB(1).palpfid ;
          V_TEST :=temp_PALTAB(1).palpIid ;
          V_TEST :=temp_pd.Pddj ;
          temp_pd.PDPFID :=PMD.PMDPFID;
          pd :=temp_pd;
        exception when others then
          null;
        end;
      end if;





              --���������ϸ����չ������ϸ���̶��ǻ����0
              --��ˮ��+�۸����+������Ŀ 09
              PALTAB := NULL;

              V_�����Ŀ������ := 0;
              V_�����Ŀ������ := V_��Ѽ������;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              --��ˮ��+�۸����+������Ŀ 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_�����Ŀ������,
                           V_�����Ŀ������,
                           '09',
                           'Y');
              END IF;

              --���������ϸ����չ������ϸ�����
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_��ѵĵ�����,
                      V_�����Ŀ������,
                      V_��ϱ�ĵ�����,
                      P_NY);
            END LOOP;
            CLOSE C_PD;
          ELSE
            OPEN C_PD_LS(PMD.PMDPFID, P_NY);
            LOOP
              FETCH C_PD_LS
                INTO PD;
              EXIT WHEN C_PD_LS%NOTFOUND;




--ˮ�۵��� ��ˮ��+�۸����+������Ŀ
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  PMD.PMDPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����+������Ŀ',
                  PALTAB);
      if   PALTAB is not null then
      temp_PALTAB := f_getpfid_piid(PALTAB,PD.PDPIID);
      end if;
      if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
        begin
        select * into temp_pd from  pricedetail t  where t.pdpfid=temp_PALTAB(1).PALCALIBER  and t.pdpiid=temp_PALTAB(1).palpiid ;
          V_TEST :=temp_PALTAB(1).palpfid ;
          V_TEST :=temp_PALTAB(1).palpIid ;
          V_TEST :=temp_pd.Pddj ;
          temp_pd.PDPFID :=PMD.PMDPFID;
          pd :=temp_pd;
        exception when others then
          null;
        end;
      end if;


              --���������ϸ����չ������ϸ���̶��ǻ����0
              --��ˮ��+�۸����+������Ŀ 09
              PALTAB := NULL;

              V_�����Ŀ������ := 0;
              V_�����Ŀ������ := V_��Ѽ������;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              --��ˮ��+�۸����+������Ŀ 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_�����Ŀ������,
                           V_�����Ŀ������,
                           '09',
                           'Y');
              END IF;

              --���������ϸ����չ������ϸ�����
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_��ѵĵ�����,
                      V_�����Ŀ������,
                      V_��ϱ�ĵ�����,
                      P_NY);
            END LOOP;
            CLOSE C_PD_LS;
          END IF;

          --
          FETCH C_PMD
            INTO PMD;
          TEMPSL := TEMPSL - TEMPJSSL;
        END LOOP;
      END IF;
      CLOSE C_PMD;
      --pricemultidetail��Ϸ��ʡ�����������������������������������������������������������������������������������
      RL.RLREADSL := MR.MRSL;
      --��������
      --�����ѻ�������
      /*  begin
              if mi.migps is null or mi.migps = '0' then
                v_per := 0;
              else
                begin
                  v_per := to_number(mi.migps);
                exception
                  when others then
                    v_per := 0;
                end;
              end if;
            exception
              when others then
                v_per := 0;
            end;
            if rl.RLPRDATE is null then
              v_months := 1;
            else
              v_months := trunc(months_between(rl.RLRDATE, rl.RLPRDATE));
            end if;

            if v_months < 1 then
              v_months := 1;
            end if;

            --��ʼ�������ѱ���
            rdnjf := null;
            if v_months > 0 and v_per > 0 then
              if rdtab is null then
                raise_application_error(errcode, 'ȱ��ˮ����Ŀ������');
              else
                rdnjf            := rdtab(rdtab.last);
                rdnjf.rdpiid     := '05'; --������Ŀ
                rdnjf.rdysdj     := �����ѵ���; --Ӧ�յ���
                rdnjf.rdyssl     := v_per * v_months; --Ӧ��ˮ��
                rdnjf.rdysje     := �����ѵ��� * v_per * v_months; --Ӧ�ս��
                rdnjf.rddj       := rdnjf.rdysdj; --ʵ�յ���
                rdnjf.rdsl       := rdnjf.rdyssl; --ʵ��ˮ��
                rdnjf.rdje       := rdnjf.rdysje; --ʵ�ս��
                rdnjf.rdadjdj    := 0; --ʵ�յ���
                rdnjf.rdadjsl    := 0; --ʵ��ˮ��
                rdnjf.rdadjje    := 0; --ʵ�ս��
                rdnjf.rdpmdscale := 0; --��ϱ���
                rdtab.extend;
                rdtab(rdtab.last) := rdnjf;
              end if;
            end if;
      */
      --����
      IF FSYSPARA('1104') = 'Y' THEN
        --�ּ�������
        V_RLFIRST := 0;
        V_BATCH   := NULL;
        OPEN C_PICOUNT;
        LOOP
          FETCH C_PICOUNT
            INTO V_PIGROUP;
          EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
          --rl1.rlgroup := v_pigroup;
          --��������
          --if    rl1.rlgroup=2 then

          /*if    v_pigroup=2 then
            rl.rlsl:=0 ;
            rl.rlreadsl :=0;
          end if;*/

          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;

          --yujia 20120210 ��Ϊ��ӡ��Ԥ��

          IF RL1.RLGROUP = 1 OR RL1.RLGROUP = 3 THEN
            RL1.RLMIEMAILFLAG := 'S';
          ELSE
            RL1.RLMIEMAILFLAG := 'W';
          END IF;

          IF V_RLFIRST = 0 THEN
            V_RLFIRST := V_RLFIRST + 1;
          ELSE
            RL1.RLID  := FGETSEQUENCE('RECLIST');
            V_RLFIRST := V_RLFIRST + 1;
          END IF;
          RL1.RLJE := 0;
          RL1.RLSL := 0;

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
                /*                if rdtab(i).rdpiid = '01' or rdtab(i)
                .rdpiid = '04' or rdtab(i).rdpiid = '05' then
                  rl1.rlsl := rl1.rlsl + rdtab(i).rdsl;
                end if;*/

                /*** lgb tm 20120412**/
                IF RDTAB(I).RDPIID = '01' THEN
                  RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;
                END IF;
                IF �Ƿ�������� = 'N' THEN
                  INSERT INTO RECDETAIL VALUES RDTAB (I);
                ELSE
                  INSERT INTO RECDETAILTEMP VALUES RDTAB (I);
                END IF;
              END IF;
            END LOOP;

          END LOOP;

          CLOSE C_PI;
          IF V_RLFZCOUNT > 0 THEN
            IF �Ƿ�������� = 'N' THEN
              INSERT INTO RECLIST VALUES RL1;
            ELSE
              INSERT INTO RECLISTTEMP VALUES RL1;
            END IF;
            --Ԥ���Զ��ۿ�
            IF FSYSPARA('0006') = 'Y' AND �Ƿ�������� = 'N' THEN
              IF MI.MIPRIID IS NOT NULL THEN
                V_PMISAVING := 0;
                BEGIN
                  SELECT MISAVING
                    INTO V_PMISAVING
                    FROM METERINFO
                   WHERE MIID = MI.MIPRIID;
                EXCEPTION
                  WHEN OTHERS THEN
                    V_PMISAVING := 0;
                END;
                --���ձ�
                IF V_PMISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('02', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                  MI.MISMFID, --�ɷѻ���
                                                  'system', --�տ�Ա
                                                  RL1.RLID || '|', --Ӧ����ˮ��
                                                  RL1.RLJE, --Ӧ���ܽ��
                                                  0, --����ΥԼ��
                                                  0, --������
                                                  0, --ʵ���տ�
                                                  PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                                  MI.MIPRIID, --ˮ�����Ϻ�
                                                  'XJ', --���ʽ
                                                  MI.MISMFID, --�ɷѵص�
                                                  V_BATCH, --��������
                                                  'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                                  NULL, --��Ʊ��
                                                  'N' --�����Ƿ��ύ��Y/N��
                                                  );
                END IF;
              ELSE
                --����
                SELECT MISAVING
                  INTO MI.MISAVING
                  FROM METERINFO T
                 WHERE MIID = MI.MIID;
                IF MI.MISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                  MI.MISMFID, --�ɷѻ���
                                                  'system', --�տ�Ա
                                                  RL1.RLID || '|', --Ӧ����ˮ��
                                                  RL1.RLJE, --Ӧ���ܽ��
                                                  0, --����ΥԼ��
                                                  0, --������
                                                  0, --ʵ���տ�
                                                  PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                                  MI.MIID, --ˮ�����Ϻ�
                                                  'XJ', --���ʽ
                                                  MI.MISMFID, --�ɷѵص�
                                                  V_BATCH, --��������
                                                  'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                                  NULL, --��Ʊ��
                                                  'N' --�����Ƿ��ύ��Y/N��
                                                  );
                END IF;
              END IF;

            END IF;

          END IF;
        END LOOP;
        CLOSE C_PICOUNT;

      ELSE

        RL.RLJE := 0;
        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          RL.RLJE := RL.RLJE + RDTAB(I).RDJE;
        END LOOP;
        /*
          --���� ���������  �̶�������ֵ
          if �̶�����־ = 'Y' AND rl.rlje <= �̶�������ֵ THEN
            rl.rlje := round(�̶�������ֵ);
          END IF;
        */
        IF �Ƿ�������� = 'N' THEN
          INSERT INTO RECLIST VALUES RL;
        ELSE
          INSERT INTO RECLISTTEMP VALUES RL;
        END IF;
        INSRD(RDTAB);
        --Ԥ���Զ��ۿ�
        IF FSYSPARA('0006') = 'Y' AND �Ƿ�������� = 'N' THEN
          IF MI.MIPRIID IS NOT NULL AND MI.MIPRIFLAG='Y' THEN
            V_PMISAVING := 0;
            BEGIN
              SELECT MISAVING
                INTO V_PMISAVING
                FROM METERINFO
               WHERE MIID = MI.MIPRIID;
            EXCEPTION
              WHEN OTHERS THEN
                V_PMISAVING := 0;
            END;
            --���ձ�
            V_RLIDLIST := '';
            V_RLJES    := 0;
            V_ZNJ      := 0;

            OPEN C_YCDK;
            LOOP
              FETCH C_YCDK
                INTO V_RLID,V_RLJE,V_ZNJ;
              EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
              --Ԥ�湻��
              IF V_PMISAVING>=V_RLJE+V_ZNJ THEN
                 V_RLIDLIST  := V_RLID||',';
                 V_PMISAVING := V_PMISAVING - (V_RLJE+V_ZNJ);
                 V_RLJES     := V_RLJES + V_RLJE;
                 V_ZNJS      := V_ZNJS + V_ZNJ;
              ELSE
                 EXIT;
              END IF;
            END LOOP;
            CLOSE C_YCDK;


            IF LENGTH(V_RLIDLIST)>0 THEN
              V_RLIDLIST := SUBSTR(V_RLIDLIST,1,LENGTH(V_RLIDLIST)-1);
              V_RETSTR := PG_EWIDE_PAY_01.POS('02', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                              MI.MISMFID, --�ɷѻ���
                                              'system', --�տ�Ա
                                              V_RLIDLIST || '|', --Ӧ����ˮ��
                                              NVL(V_RLJES,0), --Ӧ���ܽ��
                                              NVL(V_ZNJS,0), --����ΥԼ��
                                              0, --������
                                              0, --ʵ���տ�
                                              PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                              MI.MIPRIID, --ˮ�����Ϻ�
                                              'XJ', --���ʽ
                                              MI.MISMFID, --�ɷѵص�
                                              FGETSEQUENCE('ENTRUSTLOG'), --��������
                                              'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                              NULL, --��Ʊ��
                                              'N' --�����Ƿ��ύ��Y/N��
                                              );
            END IF;
          ELSE
            V_RLIDLIST := '';
            V_RLJES    := 0;
            V_ZNJ      := 0;
            V_PMISAVING := MI.MISAVING;

            OPEN C_YCDK;
            LOOP
              FETCH C_YCDK
                INTO V_RLID,V_RLJE,V_ZNJ;
              EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
              --Ԥ�湻��
              IF V_PMISAVING>=V_RLJE+V_ZNJ THEN
                 V_RLIDLIST := V_RLID||',';
                 V_PMISAVING := V_PMISAVING - (V_RLJE+V_ZNJ);
                 V_RLJES     := V_RLJES + V_RLJE;
                 V_ZNJS      := V_ZNJS + V_ZNJ;
              ELSE
                 EXIT;

              END IF;

            END LOOP;
            CLOSE C_YCDK;
            --����
            IF LENGTH(V_RLIDLIST)>0 THEN
               V_RLIDLIST := SUBSTR(V_RLIDLIST,1,LENGTH(V_RLIDLIST)-1);
               V_RETSTR := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                              MI.MISMFID, --�ɷѻ���
                                              'system', --�տ�Ա
                                              V_RLIDLIST || '|', --Ӧ����ˮ��
                                              NVL(V_RLJES,0), --Ӧ���ܽ��
                                              NVL(V_ZNJS,0), --����ΥԼ��
                                              0, --������
                                              0, --ʵ���տ�
                                              PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                              MI.MIID, --ˮ�����Ϻ�
                                              'XJ', --���ʽ
                                              MI.MISMFID, --�ɷѵص�
                                              FGETSEQUENCE('ENTRUSTLOG'), --��������
                                              'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                              NULL, --��Ʊ��
                                              'N' --�����Ƿ��ύ��Y/N��
                                              );
            END IF;
          END IF;



        END IF;


      END IF;

    END IF;

    --add 2013.01.16      ��reclist_charge_01���в�������
    SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.01.16

    --������ʷˮ����Ϣ
    --if   FChkMeterNeedCharge_xbqs(MI.MINEWFLAG,MR.MRSL)='Y'  then
/*    IF �Ƿ�������� = 'N' THEN
      IF MR.MRMEMO = '��������Ƿ��' THEN
        UPDATE METERINFO
           SET MIRCODE     = MIREINSCODE,
               MIRECDATE   = MR.MRRDATE,
               MIRECSL     = MR.MRSL, --ȡ����ˮ����������
               MIFACE      = MR.MRFACE,
               MINEWFLAG   = 'N',
               MIRCODECHAR = MIREINSCODE
         WHERE CURRENT OF C_MI;

      ELSE
        UPDATE METERINFO
           SET MIRCODE     = MR.MRECODE,
               MIRECDATE   = MR.MRRDATE,
               MIRECSL     = MR.MRSL, --ȡ����ˮ����������
               MIFACE      = MR.MRFACE,
               MINEWFLAG   = 'N',
               MIRCODECHAR = MR.MRECODECHAR
         WHERE CURRENT OF C_MI;
      END IF;
    END IF;
*/

UPDATE METERINFO
           SET MIRCODE     = MR.MRECODE,
               MIRECDATE   = MR.MRRDATE,
               MIRECSL     = MR.MRSL, --ȡ����ˮ����������
               MIFACE      = MR.MRFACE,
               MINEWFLAG   = 'N',
               MIRCODECHAR = MR.MRECODECHAR
         WHERE CURRENT OF C_MI;

   --end if;
    --
    CLOSE C_MI;
    CLOSE C_MD;
    CLOSE C_CI;
    --����Ӧ��ˮ��ˮ�ѵ�ԭʼ�����¼
    MR.MRRECSL   := NVL(RL.RLSL, 0);
    MR.MRIFREC   := 'Y';
    MR.MRRECDATE := RL.RLDATE;
    IF RDTAB IS NOT NULL THEN
      FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
        VRD := RDTAB(I);
        CASE VRD.RDPIID
          WHEN '01' THEN
            MR.MRRECJE01 := NVL(MR.MRRECJE01, 0) + VRD.RDJE;
          WHEN '02' THEN
            MR.MRRECJE02 := NVL(MR.MRRECJE02, 0) + VRD.RDJE;
          WHEN '03' THEN
            MR.MRRECJE03 := NVL(MR.MRRECJE03, 0) + VRD.RDJE;
          WHEN '04' THEN
            MR.MRRECJE04 := NVL(MR.MRRECJE04, 0) + VRD.RDJE;
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
      IF C_MISAVING%ISOPEN THEN
        CLOSE C_MISAVING;
      END IF;
      IF C_MD%ISOPEN THEN
        CLOSE C_MD;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
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
      WLOG('�����쳣��' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --����ˮ������ѣ�ֻ���ڼ��˲��Ʒѣ���������
  PROCEDURE CALCULATENP(MR      IN OUT METERREAD%ROWTYPE,
                      P_TRANS IN CHAR,
                      P_NY    IN VARCHAR2) IS
    CURSOR C_MI(VMIID IN METERINFO.MIID%TYPE) IS
      SELECT * FROM METERINFO WHERE MIID = VMIID FOR UPDATE;

    CURSOR C_CI(VCIID IN CUSTINFO.CIID%TYPE) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCIID FOR UPDATE;

    CURSOR C_MD(VMIID IN METERDOC.MDMID%TYPE) IS
      SELECT * FROM METERDOC WHERE MDMID = VMIID FOR UPDATE;

    CURSOR C_MA(VMIID IN METERACCOUNT.MAMID%TYPE) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMIID FOR UPDATE;

    CURSOR C_PMD(VMID IN PRICEMULTIDETAIL.PMDMID%TYPE) IS
      SELECT *
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = VMID
       ORDER BY PMDID, PMDPFID
         FOR UPDATE;

    CURSOR C_PD(VPFID IN PRICEDETAIL.PDPFID%TYPE ) IS
      SELECT *
        FROM PRICEDETAIL T
       WHERE PDPFID = VPFID
       ORDER BY PDPSCID DESC;

    ----��ʷ�۸���ϵ
    CURSOR C_PD_LS(VPFID IN PRICEDETAIL.PDPFID%TYPE, PMONTH IN VARCHAR2) IS
      SELECT PDPSCID,
             PDPFID,
             PDPIID,
             PDDJ,
             PDSL,
             PDJE,
             PDMETHOD,
             PDSDATE,
             PDEDATE,
             PDSMONTH,
             PDEMONTH
        FROM PRICEDETAIL_VER T, PRICEVER
       WHERE SMONTH <= PMONTH
         AND EMONTH >= PMONTH
         AND PDPFID = VPFID
         AND ID = VERID
       ORDER BY PDPSCID DESC;

    CURSOR C_MISAVING(VMICODE VARCHAR2) IS
      SELECT *
        FROM METERINFO
       WHERE MICODE IN
             (SELECT MIPRIID FROM METERINFO WHERE MICODE = VMICODE)
         AND MICODE <> VMICODE
         AND MISAVING > 0;
    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;

    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;

    MI    METERINFO%ROWTYPE;
    CI    CUSTINFO%ROWTYPE;
    RL    RECLIST%ROWTYPE;
    RDNJF RECDETAIL%ROWTYPE;
    RL1   RECLIST%ROWTYPE;

    PMD    PRICEMULTIDETAIL%ROWTYPE;
    PD     PRICEDETAIL%ROWTYPE;
    temp_pd PRICEDETAIL%ROWTYPE;
    MD     METERDOC%ROWTYPE;
    MA     METERACCOUNT%ROWTYPE;
    RDTAB  RD_TABLE;
    --VRD    RECDETAILNP%ROWTYPE;
    PALTAB PAL_TABLE;
    temp_PALTAB PAL_TABLE ;

    TEMPJSSL  NUMBER;
    TEMPSL    NUMBER;
    MAXPMDID  NUMBER;
    TEMPPMDID NUMBER;
    CLASSCTL  CHAR(1) := 'N'; --Ĭ�ϲ�ȡ�����ݼƷѷ���

    I             NUMBER;
    VRD           RECDETAIL%ROWTYPE;
    V_DBSL        NUMBER; --���Ƚ�ˮ��
    V_SVAINGBATCH VARCHAR2(50);

    V_OUTPBATCH      VARCHAR2(1000); --Ԥ�����Σ������ձ�����
    V_��ĵ�����     NUMBER(10);
    V_�����ˮ��ֵ   NUMBER(10);
    V_��ѵĵ�����  NUMBER(10);
    V_��Ѽ������   NUMBER(10);
    V_�����Ŀ������ NUMBER(10);
    V_�����Ŀ������ NUMBER(10);
    V_��ϱ�ĵ����� NUMBER(10);
    V_FSCOUNT        NUMBER(10);
    V_PIGROUP        PRICEITEM.PIGROUP%TYPE;
    PI               PRICEITEM%ROWTYPE;
    V_RLFZCOUNT      NUMBER(10);
    V_RLFIRST        NUMBER(10);

    V_PER       NUMBER(10); --����
    V_MONTHS    NUMBER(10); --�·�
    V_PMISAVING METERINFO.MISAVING%TYPE;
    V_RETSTR    VARCHAR2(2000);
    V_BATCH     VARCHAR2(2000);
     V_TEST     VARCHAR2(2000);

  BEGIN
    --
    --yujia  2012-03-20
    /*    �̶�����־   := FPARA(MR.MRSMFID, 'GDJEFLAG');
    �̶�������ֵ := FPARA(MR.MRSMFID, 'GDJEZ');*/

    --����ˮ���¼
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('��Ч��ˮ����' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
    END IF;
    --����ˮ����
    OPEN C_MD(MR.MRMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      WLOG('��Ч��ˮ����' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
    END IF;
    --����ˮ������
    OPEN C_MA(MR.MRMID);
    FETCH C_MA
      INTO MA;
    CLOSE C_MA;
    --�����û���¼
    OPEN C_CI(MI.MICID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      WLOG('��Ч���û����' || MI.MICID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч���û����' || MI.MICID);
    END IF;
    DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;
    --�ǼƷѱ�ִ�пչ��̣������쳣
    --�����ӱ�
    IF TRUE THEN
      --reclist����������������������������������������������������������������������������������������������
      RL.RLID          := FGETSEQUENCE('RECLIST');
      RL.RLSMFID       := MR.MRSMFID;
      RL.RLMONTH       := TOOLS.FGETRECMONTH(MR.MRSMFID);
      RL.RLDATE        := TOOLS.FGETRECDATE(MR.MRSMFID);
      RL.RLCID         := MR.MRCID;
      RL.RLMID         := MR.MRMID;
      RL.RLMSMFID      := MI.MISMFID;
      RL.RLCSMFID      := CI.CISMFID;
      RL.RLCCODE       := MR.MRCCODE;
      RL.RLCHARGEPER   := MI.MICPER;
      RL.RLCPID        := CI.CIPID;
      RL.RLCCLASS      := CI.CICLASS;
      RL.RLCFLAG       := CI.CIFLAG;
      RL.RLUSENUM      := MI.MIUSENUM;
      RL.RLCNAME       := MI.MINAME;
      RL.RLCNAME2      := CI.CINAME;
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
      RL.RLIFINV       := 'N';--CI.CIIFINV; --��Ʊ��־
      RL.RLMCODE       := MI.MICODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := MR.MRDAY;
      RL.RLBFID        := MR.MRBFID;
      RL.RLPRDATE      := MR.MRPRDATE;
      RL.RLRDATE       := MR.MRRDATE;
      --˰Ʊ�������ɽ�
      --   IF NVL(MI.MIIFTAX, 'N') = 'N' THEN
      RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);
      --  END IF;
      RL.RLCALIBER := MD.MDCALIBER;
      RL.RLRTID    := MI.MIRTID;
      RL.RLMSTATUS := MI.MISTATUS;
      RL.RLMTYPE   := MI.MITYPE;
      RL.RLMNO     := MD.MDNO;
      RL.RLSCODE   := MR.MRSCODE;
      RL.RLECODE   := MR.MRECODE;
      RL.RLREADSL := MR.MRRECSL;
      /*----����ҵ��20130307 ������������ˮ������ ��
      IF MR.MRRPID = '01' THEN
        RL.RLREADSL := 10 * MR.MRRECSL; --�����ݴ棬���ָ�
      ELSIF MR.MRRPID = '02' THEN
        RL.RLREADSL := 100 * MR.MRRECSL; --�����ݴ棬���ָ�
      ELSE
        RL.RLREADSL := MR.MRRECSL; --�����ݴ棬���ָ�
      END IF;*/
      -- RL.RLREADSL       := MR.MRRECSL; --�����ݴ棬���ָ�
      RL.RLINVMEMO      := MR.MRMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      RL.RLTRANS        := P_TRANS;
      RL.RLCD           := DEBIT;
      RL.RLYSCHARGETYPE := MI.MICHARGETYPE;
      RL.RLSL           := 0; --Ӧ��ˮ��ˮ������rlsl = rlreadsl + rladjsl��
      RL.RLJE           := 0; --������������,�ȳ�ʼ��
      RL.RLADDSL        := NVL(MR.MRADDSL, 0) - NVL(MR.MRCARRYSL, 0);
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDJE       := 0;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDPER      := NULL;
      RL.RLPAIDDATE     := NULL;
      RL.RLMRID         := MR.MRID;
      RL.RLMEMO         := MR.MRMEMO || '   [' || P_NY || '��ʷ����' || ']';
      RL.RLZNJ          := 0;
      RL.RLLB           := MI.MILB;
      RL.RLPFID         := MI.MIPFID;
      RL.RLDATETIME     := SYSDATE;
      RL.RLPRIMCODE     := MR.MRPRIMID; --��¼�����ӱ�
      RL.RLPRIFLAG      := MI.MIPRIFLAG;
      RL.RLRPER         := MR.MRRPER;
      RL.RLSAFID        := MR.MRSAFID;
      RL.RLSCODECHAR    := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR    := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP        := '1'; --Ӧ���ʷ���

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
      RL.RLSCRRLID      := RL.RLID; --ԭӦ������ˮ
      RL.RLSCRRLTRANS   := RL.RLTRANS; --ԭӦ��������
      RL.RLSCRRLMONTH   := RL.RLMONTH; --ԭӦ�����·�
      RL.RLSCRRLDATE    := RL.RLDATE; --ԭӦ��������
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
      RL.RLMIEMAILFLAG   := MI.MIEMAILFLAG; --�����Ƿ��ʼ�
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --�����ֶ�1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --�����ֶ�2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --�����ֶ�3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --�����ֶ�3
      RL.RLCOLUMN5       := RL.RLDATE; --�ϴ�Ӧ��������
      RL.RLCOLUMN9       := RL.RLID; --�ϴ�Ӧ������ˮ
      RL.RLCOLUMN10      := RL.RLMONTH; --�ϴ�Ӧ�����·�
      RL.RLCOLUMN11      := RL.RLTRANS; --�ϴ�Ӧ��������
      --��ĵ�����/ ��ѵĵ����� /�����Ŀ������
      V_��ĵ�����   := 0;
      V_�����ˮ��ֵ := RL.RLREADSL;
      --��ѯ�Ա�������
      PALTAB := NULL;
      CALADJUST(MR.MRMONTH,
                MR.MRSMFID,
                CI.CIID,
                MI.MIID,
                NULL,
                NULL,
                TO_CHAR(MD.MDCALIBER),
                '����ˮ��',
                PALTAB);
      --�����ȡ���ۼ�ֵ
      --����ˮ�� 02
      IF PALTAB IS NOT NULL THEN
        SP_GETJMSL(PALTAB, RL, V_��ĵ�����, V_�����ˮ��ֵ, '02', 'Y');
      END IF;

      --reclist��������������������������������������������������������������������������������������������������
      --������ϸ�㷨˵����
      --1�������ڻ�Ϸ��ʼ��������ɷ�����ϸ�����༴�ǻ�Ϸ������ȼ���ߣ�
      --2�����򻧱�����α������ɷ�����ϸ���ݣ�
      --3�������������ɷ�ʽ�£��α�ƥ���Ż����ݣ����������ϸ��
      --��Ҫ�����Ż���Чǰ���ǻ������߱������Ļ�����ʣ������Ż��޵�����Ŀ��
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN

--ȡˮ��  11 --�����Ե���  ��ˮ��+�۸����

       temp_PALTAB  := NULL;
        PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����',
                  PALTAB);
       if    PALTAB is not null then
      temp_PALTAB := f_getpfid(PALTAB);
        end if;
      if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
         MI.MIPFID := temp_PALTAB(1).palcaliber ;
         --����Ӧ����ˮ��
         rl.rlpfid :=  MI.MIPFID ;
        end if;



        --��ˮ��+�۸���� ������
        PALTAB         := NULL;
        V_��ѵĵ����� := 0;
        V_��Ѽ������ := V_�����ˮ��ֵ;



         CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����',
                  PALTAB);

        --��ˮ��+�۸���� 07
        --�����ȡ���ۼ�ֵ
        IF PALTAB IS NOT NULL THEN
          SP_GETJMSL(PALTAB, RL, V_��ѵĵ�����, V_��Ѽ������, '07', 'Y');
        END IF;

        --cmprice������ʡ���������������������������������������������������������������������������������������������
        --�Ұ汾��ߵķ�����ϸ
        IF P_NY = '0000.00' OR P_NY IS NULL THEN
          OPEN C_PD(MI.MIPFID);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;
    --ˮ�۵��� ��ˮ��+�۸����+������Ŀ
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����+������Ŀ',
                  PALTAB);
      if   PALTAB is not null then
      temp_PALTAB := f_getpfid_piid(PALTAB,PD.PDPIID);
      end if;
      if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
        begin
        select * into temp_pd from  pricedetail t  where t.pdpfid=temp_PALTAB(1).PALCALIBER  and t.pdpiid=temp_PALTAB(1).palpiid ;
          V_TEST :=temp_PALTAB(1).palpfid ;
          V_TEST :=temp_PALTAB(1).palpIid ;
          V_TEST :=temp_pd.Pddj ;
          temp_pd.PDPFID :=MI.MIPFID;
          pd :=temp_pd;
        exception when others then
          null;
        end;
      end if;

            --�������

            --���������ϸ����չ������ϸ���̶��ǻ����0
            --��ˮ��+�۸���� ������
            PALTAB := NULL;

            V_�����Ŀ������ := 0;
            V_�����Ŀ������ := V_��Ѽ������;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            --��ˮ��+�۸����+������Ŀ 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_�����Ŀ������,
                         V_�����Ŀ������,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_��ĵ�����,
                    V_��ѵĵ�����,
                    V_�����Ŀ������,
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD;

        ELSE

          OPEN C_PD_LS(MI.MIPFID, P_NY);
          LOOP
            FETCH C_PD_LS
              INTO PD;
            EXIT WHEN C_PD_LS%NOTFOUND;

            --ˮ�۵��� ��ˮ��+�۸����+������Ŀ
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����+������Ŀ',
                  PALTAB);
      if   PALTAB is not null then
      temp_PALTAB := f_getpfid_piid(PALTAB,PD.PDPIID);
      end if;
      if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
        begin
        select * into temp_pd from  pricedetail t  where t.pdpfid=temp_PALTAB(1).PALCALIBER  and t.pdpiid=temp_PALTAB(1).palpiid ;
          V_TEST :=temp_PALTAB(1).palpfid ;
          V_TEST :=temp_PALTAB(1).palpIid ;
          V_TEST :=temp_pd.Pddj ;
          temp_pd.PDPFID :=MI.MIPFID;
          pd :=temp_pd;
        exception when others then
          null;
        end;
      end if;





            --�������

            --���������ϸ����չ������ϸ���̶��ǻ����0
            --��ˮ��+�۸���� ������
            PALTAB := NULL;

            V_�����Ŀ������ := 0;
            V_�����Ŀ������ := V_��Ѽ������;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);






            --��ˮ��+�۸����+������Ŀ 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_�����Ŀ������,
                         V_�����Ŀ������,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_��ĵ�����,
                    V_��ѵĵ�����,
                    V_�����Ŀ������,
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD_LS;
        END IF;

        --cmprice������ʡ�������������������������������������������������������������������������������������������������
      ELSE
        --pricemultidetail��Ϸ��ʡ�����������������������������������������������������������������������������������

        --    v_��ĵ����� /v_�����ˮ��ֵ

        SELECT MAX(PMDID)
          INTO MAXPMDID
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = MI.MIID;
        TEMPSL := V_�����ˮ��ֵ; --������ۼ�����
        --tempsl := rl.rlreadsl; --������ۼ�����

        V_DBSL := 0; --����ˮ��
        WHILE C_PMD%FOUND AND TEMPSL >= 0 LOOP

          --�����������������
          IF PMD.PMDID = MAXPMDID THEN
            TEMPJSSL := TEMPSL;
          ELSE
            IF PMD.PMDTYPE = '00' THEN
              --�������������ϰ�����ֺ��ٰ��������
              TEMPJSSL := (CASE
                            WHEN TEMPSL >= TRUNC(PMD.PMDSCALE) THEN
                             TRUNC(PMD.PMDSCALE)
                            ELSE
                             TEMPSL
                          END);

              V_DBSL := V_DBSL + TEMPJSSL;

            ELSE
              TEMPJSSL := TRUNC((V_�����ˮ��ֵ - V_DBSL) * PMD.PMDSCALE);
            END IF;
            /* if pmd.pmdid = 0 then
              --�������������ϰ�����ֺ��ٰ��������
              tempjssl := (case when tempsl >= trunc(pmd.pmdscale) then trunc(pmd.pmdscale) else tempsl end);
              V_DBSL   := V_DBSL + tempjssl;
            else
              tempjssl := trunc((v_�����ˮ��ֵ - V_DBSL) * pmd.pmdscale);
            end if;*/
          END IF;

          ---�ֲ�ֱ� ��ϱ�ĵ����� := v_��ĵ����� ;
          V_��ϱ�ĵ����� := 0;
          IF V_��ĵ����� <> 0 THEN
            IF TEMPJSSL - V_��ĵ����� >= 0 THEN
              V_��ϱ�ĵ����� := V_��ĵ�����;
              V_��ĵ�����     := 0;
            ELSE
              V_��ϱ�ĵ����� := TEMPJSSL;
              V_��ĵ�����     := V_��ĵ����� - TEMPJSSL;
            END IF;
          END IF;


--ȡˮ��  11 --�����Ե���  ��ˮ��+�۸����

       temp_PALTAB  := NULL;
        PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����',
                  PALTAB);
       if    PALTAB is not null then
      temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
         PMD.PMDPFID := temp_PALTAB(1).palcaliber ;
         --����Ӧ����ˮ��
         rl.rlpfid :=  PMD.PMDPFID ;
        end if;

          --��ˮ��+�۸���� ������
          PALTAB         := NULL;
          V_��ѵĵ����� := 0;
          V_��Ѽ������ := TEMPJSSL;




          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    PMD.PMDPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '��ˮ��+�۸����',
                    PALTAB);

          --��ˮ��+�۸���� 07
          --�����ȡ���ۼ�ֵ
          IF PALTAB IS NOT NULL THEN
            SP_GETJMSL(PALTAB,
                       RL,
                       V_��ѵĵ�����,
                       V_��Ѽ������,
                       '07',
                       'Y');
          END IF;

          --�Ұ汾��ߵķ�����ϸ
          IF P_NY = '0000.00' OR P_NY IS NULL THEN
            OPEN C_PD(PMD.PMDPFID);
            LOOP
              FETCH C_PD
                INTO PD;
              EXIT WHEN C_PD%NOTFOUND;

 --ˮ�۵��� ��ˮ��+�۸����+������Ŀ
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  PMD.PMDPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����+������Ŀ',
                  PALTAB);
      if   PALTAB is not null then
      temp_PALTAB := f_getpfid_piid(PALTAB,PD.PDPIID);
      end if;
      if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
        begin
        select * into temp_pd from  pricedetail t  where t.pdpfid=temp_PALTAB(1).PALCALIBER  and t.pdpiid=temp_PALTAB(1).palpiid ;
          V_TEST :=temp_PALTAB(1).palpfid ;
          V_TEST :=temp_PALTAB(1).palpIid ;
          V_TEST :=temp_pd.Pddj ;
          temp_pd.PDPFID :=PMD.PMDPFID;
          pd :=temp_pd;
        exception when others then
          null;
        end;
      end if;





              --���������ϸ����չ������ϸ���̶��ǻ����0
              --��ˮ��+�۸����+������Ŀ 09
              PALTAB := NULL;

              V_�����Ŀ������ := 0;
              V_�����Ŀ������ := V_��Ѽ������;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              --��ˮ��+�۸����+������Ŀ 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_�����Ŀ������,
                           V_�����Ŀ������,
                           '09',
                           'Y');
              END IF;

              --���������ϸ����չ������ϸ�����
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_��ѵĵ�����,
                      V_�����Ŀ������,
                      V_��ϱ�ĵ�����,
                      P_NY);
            END LOOP;
            CLOSE C_PD;
          ELSE
            OPEN C_PD_LS(PMD.PMDPFID, P_NY);
            LOOP
              FETCH C_PD_LS
                INTO PD;
              EXIT WHEN C_PD_LS%NOTFOUND;




--ˮ�۵��� ��ˮ��+�۸����+������Ŀ
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  PMD.PMDPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����+������Ŀ',
                  PALTAB);
      if   PALTAB is not null then
      temp_PALTAB := f_getpfid_piid(PALTAB,PD.PDPIID);
      end if;
      if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
        begin
        select * into temp_pd from  pricedetail t  where t.pdpfid=temp_PALTAB(1).PALCALIBER  and t.pdpiid=temp_PALTAB(1).palpiid ;
          V_TEST :=temp_PALTAB(1).palpfid ;
          V_TEST :=temp_PALTAB(1).palpIid ;
          V_TEST :=temp_pd.Pddj ;
          temp_pd.PDPFID :=PMD.PMDPFID;
          pd :=temp_pd;
        exception when others then
          null;
        end;
      end if;


              --���������ϸ����չ������ϸ���̶��ǻ����0
              --��ˮ��+�۸����+������Ŀ 09
              PALTAB := NULL;

              V_�����Ŀ������ := 0;
              V_�����Ŀ������ := V_��Ѽ������;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              --��ˮ��+�۸����+������Ŀ 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_�����Ŀ������,
                           V_�����Ŀ������,
                           '09',
                           'Y');
              END IF;

              --���������ϸ����չ������ϸ�����
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_��ѵĵ�����,
                      V_�����Ŀ������,
                      V_��ϱ�ĵ�����,
                      P_NY);
            END LOOP;
            CLOSE C_PD_LS;
          END IF;

          --
          FETCH C_PMD
            INTO PMD;
          TEMPSL := TEMPSL - TEMPJSSL;
        END LOOP;
      END IF;
      CLOSE C_PMD;
      --pricemultidetail��Ϸ��ʡ�����������������������������������������������������������������������������������
      RL.RLREADSL := MR.MRSL;
      --��������
      --�����ѻ�������
      /*  begin
              if mi.migps is null or mi.migps = '0' then
                v_per := 0;
              else
                begin
                  v_per := to_number(mi.migps);
                exception
                  when others then
                    v_per := 0;
                end;
              end if;
            exception
              when others then
                v_per := 0;
            end;
            if rl.RLPRDATE is null then
              v_months := 1;
            else
              v_months := trunc(months_between(rl.RLRDATE, rl.RLPRDATE));
            end if;

            if v_months < 1 then
              v_months := 1;
            end if;

            --��ʼ�������ѱ���
            rdnjf := null;
            if v_months > 0 and v_per > 0 then
              if rdtab is null then
                raise_application_error(errcode, 'ȱ��ˮ����Ŀ������');
              else
                rdnjf            := rdtab(rdtab.last);
                rdnjf.rdpiid     := '05'; --������Ŀ
                rdnjf.rdysdj     := �����ѵ���; --Ӧ�յ���
                rdnjf.rdyssl     := v_per * v_months; --Ӧ��ˮ��
                rdnjf.rdysje     := �����ѵ��� * v_per * v_months; --Ӧ�ս��
                rdnjf.rddj       := rdnjf.rdysdj; --ʵ�յ���
                rdnjf.rdsl       := rdnjf.rdyssl; --ʵ��ˮ��
                rdnjf.rdje       := rdnjf.rdysje; --ʵ�ս��
                rdnjf.rdadjdj    := 0; --ʵ�յ���
                rdnjf.rdadjsl    := 0; --ʵ��ˮ��
                rdnjf.rdadjje    := 0; --ʵ�ս��
                rdnjf.rdpmdscale := 0; --��ϱ���
                rdtab.extend;
                rdtab(rdtab.last) := rdnjf;
              end if;
            end if;
      */
      --����
      IF FSYSPARA('1104') = 'Y' THEN
        --�ּ�������
        V_RLFIRST := 0;
        V_BATCH   := NULL;
        OPEN C_PICOUNT;
        LOOP
          FETCH C_PICOUNT
            INTO V_PIGROUP;
          EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
          --rl1.rlgroup := v_pigroup;
          --��������
          --if    rl1.rlgroup=2 then

          /*if    v_pigroup=2 then
            rl.rlsl:=0 ;
            rl.rlreadsl :=0;
          end if;*/

          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;

          --yujia 20120210 ��Ϊ��ӡ��Ԥ��

          IF RL1.RLGROUP = 1 OR RL1.RLGROUP = 3 THEN
            RL1.RLMIEMAILFLAG := 'S';
          ELSE
            RL1.RLMIEMAILFLAG := 'W';
          END IF;

          IF V_RLFIRST = 0 THEN
            V_RLFIRST := V_RLFIRST + 1;
          ELSE
            RL1.RLID  := FGETSEQUENCE('RECLIST');
            V_RLFIRST := V_RLFIRST + 1;
          END IF;
          RL1.RLJE := 0;
          RL1.RLSL := 0;

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
                /*                if rdtab(i).rdpiid = '01' or rdtab(i)
                .rdpiid = '04' or rdtab(i).rdpiid = '05' then
                  rl1.rlsl := rl1.rlsl + rdtab(i).rdsl;
                end if;*/

                /*** lgb tm 20120412**/
                IF RDTAB(I).RDPIID = '01' THEN
                  RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;
                END IF;
                IF �Ƿ�������� = 'N' THEN
                  INSERT INTO RECDETAILNP VALUES RDTAB (I);
                ELSE
                  INSERT INTO RECDETAILTEMP VALUES RDTAB (I);
                END IF;
              END IF;
            END LOOP;

          END LOOP;

          CLOSE C_PI;
          IF V_RLFZCOUNT > 0 THEN
            IF �Ƿ�������� = 'N' THEN
              INSERT INTO RECLISTNP VALUES RL1;
            ELSE
              INSERT INTO RECLISTTEMP VALUES RL1;
            END IF;
            --Ԥ���Զ��ۿ�
            /*IF FSYSPARA('0006') = 'Y' AND �Ƿ�������� = 'N' THEN
              IF MI.MIPRIID IS NOT NULL THEN
                V_PMISAVING := 0;
                BEGIN
                  SELECT MISAVING
                    INTO V_PMISAVING
                    FROM METERINFO
                   WHERE MIID = MI.MIPRIID;
                EXCEPTION
                  WHEN OTHERS THEN
                    V_PMISAVING := 0;
                END;
                --���ձ�
                IF V_PMISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('02', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                  MI.MISMFID, --�ɷѻ���
                                                  'system', --�տ�Ա
                                                  RL1.RLID || '|', --Ӧ����ˮ��
                                                  RL1.RLJE, --Ӧ���ܽ��
                                                  0, --����ΥԼ��
                                                  0, --������
                                                  0, --ʵ���տ�
                                                  PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                                  MI.MIPRIID, --ˮ�����Ϻ�
                                                  'XJ', --���ʽ
                                                  MI.MISMFID, --�ɷѵص�
                                                  V_BATCH, --��������
                                                  'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                                  NULL, --��Ʊ��
                                                  'N' --�����Ƿ��ύ��Y/N��
                                                  );
                END IF;
              ELSE
                --����
                SELECT MISAVING
                  INTO MI.MISAVING
                  FROM METERINFO T
                 WHERE MIID = MI.MIID;
                IF MI.MISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                  MI.MISMFID, --�ɷѻ���
                                                  'system', --�տ�Ա
                                                  RL1.RLID || '|', --Ӧ����ˮ��
                                                  RL1.RLJE, --Ӧ���ܽ��
                                                  0, --����ΥԼ��
                                                  0, --������
                                                  0, --ʵ���տ�
                                                  PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                                  MI.MIID, --ˮ�����Ϻ�
                                                  'XJ', --���ʽ
                                                  MI.MISMFID, --�ɷѵص�
                                                  V_BATCH, --��������
                                                  'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                                  NULL, --��Ʊ��
                                                  'N' --�����Ƿ��ύ��Y/N��
                                                  );
                END IF;
              END IF;

            END IF;*/

          END IF;
        END LOOP;
        CLOSE C_PICOUNT;

      ELSE

        RL.RLJE := 0;
        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          RL.RLJE := RL.RLJE + RDTAB(I).RDJE;
        END LOOP;
        /*
          --���� ���������  �̶�������ֵ
          if �̶�����־ = 'Y' AND rl.rlje <= �̶�������ֵ THEN
            rl.rlje := round(�̶�������ֵ);
          END IF;
        */
        IF �Ƿ�������� = 'N' THEN
          INSERT INTO RECLISTNP VALUES RL;
        ELSE
          INSERT INTO RECLISTTEMP VALUES RL;
        END IF;

        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          VRD      := RDTAB(I);

          IF �Ƿ�������� = 'N' THEN
            INSERT INTO RECDETAILNP VALUES VRD;
          ELSE
            INSERT INTO RECDETAILTEMP VALUES VRD;
          END IF;
        END LOOP;

        --INSRD(RDTAB);
        --Ԥ���Զ��ۿ�
        /*IF FSYSPARA('0006') = 'Y' AND �Ƿ�������� = 'N' THEN
          IF MI.MIPRIID IS NOT NULL THEN
            V_PMISAVING := 0;
            BEGIN
              SELECT MISAVING
                INTO V_PMISAVING
                FROM METERINFO
               WHERE MIID = MI.MIPRIID;
            EXCEPTION
              WHEN OTHERS THEN
                V_PMISAVING := 0;
            END;
            --���ձ�
            IF V_PMISAVING >= RL.RLJE THEN
              V_RETSTR := PG_EWIDE_PAY_01.POS('02', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                              MI.MISMFID, --�ɷѻ���
                                              'system', --�տ�Ա
                                              RL.RLID || '|', --Ӧ����ˮ��
                                              RL.RLJE, --Ӧ���ܽ��
                                              0, --����ΥԼ��
                                              0, --������
                                              0, --ʵ���տ�
                                              PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                              MI.MIPRIID, --ˮ�����Ϻ�
                                              'XJ', --���ʽ
                                              MI.MISMFID, --�ɷѵص�
                                              FGETSEQUENCE('ENTRUSTLOG'), --��������
                                              'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                              NULL, --��Ʊ��
                                              'N' --�����Ƿ��ύ��Y/N��
                                              );
            END IF;
          ELSE
            --����
            IF MI.MISAVING >= RL.RLJE THEN

              V_RETSTR := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                              MI.MISMFID, --�ɷѻ���
                                              'system', --�տ�Ա
                                              RL.RLID || '|', --Ӧ����ˮ��
                                              RL.RLJE, --Ӧ���ܽ��
                                              0, --���ΥԼ���                                              0, --������
                                              0, --ʵ���տ�
                                              PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                              MI.MIID, --ˮ�����Ϻ�
                                              'XJ', --���ʽ
                                              MI.MISMFID, --�ɷѵص�
                                              FGETSEQUENCE('ENTRUSTLOG'), --��������
                                              'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                              NULL, --��Ʊ��
                                              'N' --�����Ƿ��ύ��Y/N��
                                              );
            END IF;
          END IF;
          \*PG_EWIDE_PAY_01.SP_RLSAVING(mi,
          RL,
          fgetsequence('ENTRUSTLOG'),
          mi.mismfid,
          'system',
          'XJ',
          mi.mismfid,
          0,
          PG_ewide_PAY_01.PAYTRANS_Ԥ��ֿ�,
          'N',
          NULL,
          'N');*\
        END IF;*/
      END IF;

    END IF;

    --add 2013.01.16      ��reclist_charge_01���в�������
    --SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.01.16

    --������ʷˮ����Ϣ
    --if   FChkMeterNeedCharge_xbqs(MI.MINEWFLAG,MR.MRSL)='Y'  then
/*    IF �Ƿ�������� = 'N' THEN
      IF MR.MRMEMO = '��������Ƿ��' THEN
        UPDATE METERINFO
           SET MIRCODE     = MIREINSCODE,
               MIRECDATE   = MR.MRRDATE,
               MIRECSL     = MR.MRSL, --ȡ����ˮ����������
               MIFACE      = MR.MRFACE,
               MINEWFLAG   = 'N',
               MIRCODECHAR = MIREINSCODE
         WHERE CURRENT OF C_MI;

      ELSE
        UPDATE METERINFO
           SET MIRCODE     = MR.MRECODE,
               MIRECDATE   = MR.MRRDATE,
               MIRECSL     = MR.MRSL, --ȡ����ˮ����������
               MIFACE      = MR.MRFACE,
               MINEWFLAG   = 'N',
               MIRCODECHAR = MR.MRECODECHAR
         WHERE CURRENT OF C_MI;
      END IF;
    END IF;
*/

UPDATE METERINFO
           SET MIRCODE     = MR.MRECODE,
               MIRECDATE   = MR.MRRDATE,
               MIRECSL     = MR.MRSL, --ȡ����ˮ����������
               MIFACE      = MR.MRFACE,
               MINEWFLAG   = 'N',
               MIRCODECHAR = MR.MRECODECHAR
         WHERE CURRENT OF C_MI;

   --end if;
    --
    CLOSE C_MI;
    CLOSE C_MD;
    CLOSE C_CI;
    --����Ӧ��ˮ��ˮ�ѵ�ԭʼ�����¼
    MR.MRRECSL   := NVL(RL.RLSL, 0);
    MR.MRIFREC   := 'Y';
    MR.MRRECDATE := RL.RLDATE;
    IF RDTAB IS NOT NULL THEN
      FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
        VRD := RDTAB(I);
        CASE VRD.RDPIID
          WHEN '01' THEN
            MR.MRRECJE01 := NVL(MR.MRRECJE01, 0) + VRD.RDJE;
          WHEN '02' THEN
            MR.MRRECJE02 := NVL(MR.MRRECJE02, 0) + VRD.RDJE;
          WHEN '03' THEN
            MR.MRRECJE03 := NVL(MR.MRRECJE03, 0) + VRD.RDJE;
          WHEN '04' THEN
            MR.MRRECJE04 := NVL(MR.MRRECJE04, 0) + VRD.RDJE;
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
      IF C_MISAVING%ISOPEN THEN
        CLOSE C_MISAVING;
      END IF;
      IF C_MD%ISOPEN THEN
        CLOSE C_MD;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
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
      WLOG('�����쳣��' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --ƥ��Ʒѵ�����¼
  PROCEDURE CALADJUST(P_MONTH   IN VARCHAR2, --�����·�
                      P_SMFID   IN PRICEADJUSTLIST.PALSMFID%TYPE,
                      P_CID     IN PRICEADJUSTLIST.PALCID%TYPE,
                      P_MID     IN PRICEADJUSTLIST.PALMID%TYPE,
                      P_PIID    IN PRICEADJUSTLIST.PALPIID%TYPE,
                      P_PFID    IN PRICEADJUSTLIST.PALPFID%TYPE,
                      P_CALIBER IN PRICEADJUSTLIST.PALCALIBER%TYPE,
                      P_TYPE    IN VARCHAR2,
                      PALTAB    IN OUT PAL_TABLE) IS
    CURSOR C_PAL IS
      SELECT *
        FROM PRICEADJUSTLIST
       WHERE PALSTATUS = 'Y'
         AND PALSTARTMON <= P_MONTH
         AND (PALENDMON IS NULL OR PALENDMON >= P_MONTH)
         AND ((PALTACTIC = '02' AND PALMID = P_MID AND P_TYPE = '����ˮ��') OR --����ˮ��
             (PALTACTIC = '07' AND PALMID = P_MID AND PALPFID = P_PFID AND
             P_TYPE = '��ˮ��+�۸����') OR --��ˮ��+�۸����
             (PALTACTIC = '09' AND PALMID = P_MID AND PALPFID = P_PFID AND
             PALPIID = P_PIID AND P_TYPE = '��ˮ��+�۸����+������Ŀ') --��ˮ��+�۸����+������Ŀ
             )
         and (  (PALDATETYPE is null or PALDATETYPE ='0' )
               or
                (PALDATETYPE='1' and instr(PALMONTHSTR, substr(P_MONTH,6 ))>0 )
                or
                (PALDATETYPE='2' and instr(PALMONTHSTR, P_MONTH)>0 )
                )
       ORDER BY PALID;

    PAL PRICEADJUSTLIST%ROWTYPE;
  BEGIN
    OPEN C_PAL;
    LOOP
      FETCH C_PAL
        INTO PAL;
      EXIT WHEN C_PAL%NOTFOUND OR C_PAL%NOTFOUND IS NULL;
      --������ϸ��
      IF PALTAB IS NULL THEN
        PALTAB := PAL_TABLE(PAL);
      ELSE
        PALTAB.EXTEND;
        PALTAB(PALTAB.LAST) := PAL;
      END IF;
    END LOOP;
    CLOSE C_PAL;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_PAL%ISOPEN THEN
        CLOSE C_PAL;
      END IF;
      WLOG('���ҼƷ�Ԥ������Ϣ�쳣��' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --ˮ����������   BY WY 20110703
  PROCEDURE SP_GETJMSL(PALTAB             IN OUT PAL_TABLE,
                       P_RL               IN RECLIST%ROWTYPE,
                       P_������           IN OUT NUMBER,
                       P_����ˮ��ֵ       IN OUT NUMBER,
                       P_����             IN VARCHAR2,
                       P_�������ۼ������ IN VARCHAR2) IS

    NMONTH   NUMBER(12);
    V_SMONTH VARCHAR2(20);
    V_EMONTH VARCHAR2(20);
  BEGIN
   -- IF P_���� IN ('02', '07', '09') THEN

      FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
if PALTAB(I).PALTACTIC  in ('02', '07', '09')  then
        --�̶�������
        IF PALTAB(I).PALMETHOD = '02' THEN
          BEGIN
            SELECT CEIL(NVL(MONTHS_BETWEEN(P_RL.RLRDATE,
                                           NVL(P_RL.RLPRDATE,
                                               ADD_MONTHS(P_RL.RLRDATE, 1)) + 1),
                            0))
              INTO NMONTH --�Ʒ�ʱ������
              FROM DUAL;
          EXCEPTION
            WHEN OTHERS THEN
              NMONTH := 1;
          END;
          IF NMONTH <= 0 THEN
            NMONTH := 1; --�쳣���ڶ��������
          END IF;

          IF P_����ˮ��ֵ + PALTAB(I).PALVALUE * PALTAB(I).PALWAY * NMONTH >= 0 THEN
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := P_����ˮ��ֵ + PALTAB(I)
                        .PALVALUE * PALTAB(I).PALWAY * NMONTH;
            END IF;
            P_������ := P_������ + PALTAB(I).PALVALUE * PALTAB(I).PALWAY * NMONTH;
          ELSE
            P_������ := P_������ - P_����ˮ��ֵ;
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := 0;
            END IF;
          END IF;
        END IF;
        --��������
        IF PALTAB(I).PALMETHOD = '03' THEN
          IF P_����ˮ��ֵ +
             TRUNC(P_����ˮ��ֵ * PALTAB(I).PALVALUE * PALTAB(I).PALWAY) >= 0 THEN
            P_������ := P_������ +
                     TRUNC(P_����ˮ��ֵ * PALTAB(I).PALVALUE * PALTAB(I).PALWAY);
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := P_����ˮ��ֵ + TRUNC(P_����ˮ��ֵ * PALTAB(I).PALVALUE * PALTAB(I)
                                         .PALWAY);
            END IF;
          ELSE
            P_������ := P_������ - P_����ˮ��ֵ;
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := 0;
            END IF;
          END IF;
        END IF;
        --���׵���(����ֵΪ��)
        IF PALTAB(I).PALMETHOD = '05' THEN
          IF P_����ˮ��ֵ >= PALTAB(I).PALVALUE THEN
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := P_����ˮ��ֵ;
            END IF;
            P_������ := P_������;
          ELSE
            P_������ := P_������ + PALTAB(I).PALVALUE - P_����ˮ��ֵ;
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
          END IF;
        END IF;
        --�ⶥ������(����ֵΪ��)
        IF PALTAB(I).PALMETHOD = '06' THEN
          IF P_����ˮ��ֵ <= PALTAB(I).PALVALUE THEN
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := P_����ˮ��ֵ;
            END IF;
            P_������ := P_������;
          ELSE
            P_������ := P_������ + PALTAB(I).PALVALUE - P_����ˮ��ֵ;
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
          END IF;
        END IF;

        --�ۼƼ�����
        IF PALTAB(I).PALMETHOD = '04' THEN
          IF P_����ˮ��ֵ + PALTAB(I).PALVALUE * PALTAB(I).PALWAY >= 0 THEN
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := P_����ˮ��ֵ + PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
            P_������ := P_������ + PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            --�ۼ������꣬�����ۼ���0
            UPDATE PRICEADJUSTLIST
               SET PALVALUE = 0
             WHERE PALID = PALTAB(I).PALID;
          ELSE
            --�����ۼ���
            UPDATE PRICEADJUSTLIST
               SET PALVALUE = PALVALUE - P_����ˮ��ֵ
             WHERE PALID = PALTAB(I).PALID;
            P_������ := P_������ - P_����ˮ��ֵ;
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := 0;
            END IF;
          END IF;
        END IF;
      end if;
      END LOOP;

  --  END IF;
  END;

  --ˮ�۵�������   BY WY 20130531
function  f_GETpfid(PALTAB   IN  PAL_TABLE )
  return PAL_TABLE
  AS
  paj  PAL_TABLE  ;

 BEGIN
    FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
      if PALTAB(I).PALTACTIC  ='07' and PALTAB(I).palmethod='11' then
         return  PALTAB;
       end if;
   return paj;
    END LOOP;
    return paj;
 END ;

  --����ˮ��+������Ŀ����   BY WY 20130531
function  f_GETpfid_piid(PALTAB   IN  PAL_TABLE ,p_piid in varchar2 )
  return PAL_TABLE
  AS
  paj  PAL_TABLE  ;

 BEGIN
    FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
      if PALTAB(I).PALTACTIC  ='09' and PALTAB(I).palmethod='11' and PALTAB(I).palpiid = p_piid then
         return  PALTAB;
       end if;
       return paj;
    END LOOP;
    return paj;
 END ;


  PROCEDURE CALPIID(P_RL             IN OUT RECLIST%ROWTYPE,
                    P_SL             IN NUMBER,
                    P_PMDID          IN NUMBER,
                    P_PMDSCALE       IN NUMBER,
                    PD               IN PRICEDETAIL%ROWTYPE,
                    PMD              PRICEMULTIDETAIL%ROWTYPE,
                    PALTAB           IN OUT PAL_TABLE,
                    RDTAB            IN OUT RD_TABLE,
                    P_CLASSCTL       IN CHAR,
                    P_��ĵ�����     IN NUMBER,
                    P_��ѵĵ�����   IN NUMBER,
                    P_�����Ŀ������ IN NUMBER,
                    P_��ϱ������   IN NUMBER,
                    P_NY             IN VARCHAR2) IS
    --p_classctl 2008.11.16���ӣ�Y��ǿ�Ʋ�ʹ�ý��ݼƷѷ���
    --N��������ݣ�����ǵĻ���
    RD       RECDETAIL%ROWTYPE;
    MINFO    METERINFO%ROWTYPE;
    I        INTEGER;
    V_PER    INTEGER;
    V_PALSL  VARCHAR2(10);
    V_ZQ     VARCHAR2(10);
    V_MONTHS NUMBER(10);
  BEGIN

    RD.RDID       := P_RL.RLID;
    RD.RDPMDID    := P_PMDID;
    RD.RDPMDSCALE := P_PMDSCALE;
    RD.RDPIID     := PD.PDPIID;
    RD.RDPFID     := PD.PDPFID;
    RD.RDPSCID    := PD.PDPSCID;
    RD.RDMETHOD   := PD.PDMETHOD;
    RD.RDPAIDFLAG := 'N';
    RD.RDYSDJ     := 0;
    RD.RDYSSL     := 0;
    RD.RDYSJE     := 0;
    RD.RDADJDJ    := 0;
    RD.RDADJSL    := 0;
    RD.RDADJJE    := 0;

    RD.RDMSMFID  := P_RL.RLMSMFID; --Ӫ����˾
    RD.RDMONTH   := P_RL.RLMONTH; --�����·�
    RD.RDMID     := P_RL.RLMID; --ˮ����
    RD.RDPMDTYPE := NVL(PMD.PMDTYPE, '01'); --������

    RD.RDPMDCOLUMN1 := PMD.PMDCOLUMN1; --�����ֶ�1
    RD.RDPMDCOLUMN2 := PMD.PMDCOLUMN2; --�����ֶ�2
    RD.RDPMDCOLUMN3 := PMD.PMDCOLUMN3; --�����ֶ�3

/*    --yujia  2012-03-20
    �̶�����־   := FPARA(P_RL.RLMSMFID, 'GDJEFLAG');
    �̶�������ֵ := FPARA(P_RL.RLMSMFID, 'GDJEZ');*/

    CASE PD.PDMETHOD
      WHEN 'dj1' THEN
        --�̶�����  Ĭ�Ϸ�ʽ���볭���й�
        BEGIN
          RD.RDCLASS := 0;
          RD.RDYSDJ  := PD.PDDJ;
          RD.RDYSSL  := P_SL - P_��ϱ������;
          RD.RDADJDJ := 0;
          RD.RDADJSL := P_��ĵ����� + P_��ѵĵ����� + P_�����Ŀ������ + P_��ϱ������;
          RD.RDADJJE := 0;
          RD.RDDJ    := PD.PDDJ;
          RD.RDSL    := P_SL + RD.RDADJSL - P_��ϱ������;
          --�������
          RD.RDYSJE := ROUND(RD.RDYSDJ*RD.RDSL, 2);
          RD.RDJE   := ROUND(RD.RDDJ*RD.RDSL, 2);


/*          IF RD.RDPFID = '0102' AND �̶�����־ = 'Y' AND RD.RDJE <= �̶�������ֵ THEN
            RD.RDJE := ROUND(�̶�������ֵ);
          END IF;*/



          --������ϸ��
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --����
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
        END;
      WHEN 'dj2' THEN
        --COD����  ��������COD���ۡ�ˮ��������COD���ۣ�����CODֵ����ѧ��������Ӧ���ۣ��볭���й�
        BEGIN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '�ݲ�֧�ֵļƷѷ���' || PD.PDMETHOD);
        END;
      WHEN 'je1' THEN
        --�̶����  ������󣺱����ȫ������ˮ�����1ԪǮ��ˮ��ά�޷ѣ��볭���޹�
        BEGIN
          RD.RDCLASS := 0;
          RD.RDYSDJ  := PD.PDJE;
          RD.RDYSSL  := 0;
          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
          RD.RDDJ    := PD.PDJE;
          RD.RDSL    := 0;
          --�������
          IF PALTAB IS NOT NULL THEN
            FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
              PALTAB(I).PALRLID := P_RL.RLID; --��д����rlid��pal
              CASE PALTAB(I).PALMETHOD
                WHEN '07' THEN
                  --���ⵥ��+�Żݵ��ۣ�COD������
                  RD.RDYSDJ  := PALTAB(I).PALPRICE;
                  RD.RDDJ    := TOOLS.GETMAX(PALTAB(I)
                                             .PALPRICE + PALTAB(I)
                                             .PALWAY * PALTAB(I).PALVALUE,
                                             0);
                  RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                WHEN '01' THEN
                  --���۵���
                  BEGIN
                    RD.RDDJ    := TOOLS.GETMAX(RD.RDDJ + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE,
                                               0);
                    RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                  END;
                WHEN '02' THEN
                  --�̶�ˮ������

                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
                WHEN '03' THEN
                  --����ˮ����������ϸʵ��ˮ��������λС��2009.7.6��
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
                WHEN '04' THEN
                  --�ۼ�ˮ������
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
                WHEN '08' THEN
                  --�������۵�����2009.10.4������
                  BEGIN
                    RD.RDADJDJ := TOOLS.GETMAX(RD.RDDJ *
                                               (1 + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE),
                                               0) - RD.RDDJ;
                    RD.RDDJ    := RD.RDDJ + RD.RDADJDJ;
                  END;
                ELSE
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
              END CASE;
            END LOOP;
          END IF;

          --������ϸ��
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --����
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          --p_rl.rlsl := p_rl.rlsl + (case when rd.rdpiid='01' then rd.rdsl else 0 end);
        END;
      WHEN 'sl1' THEN
        --�̶����ۡ�����  ������󣺰����û����볭���޹�
        BEGIN
          RD.RDCLASS := 0;
          RD.RDYSDJ  := PD.PDDJ;
          RD.RDYSSL  := PD.PDSL;
          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
          RD.RDDJ    := PD.PDDJ;
          RD.RDSL    := PD.PDSL;
          --�������
          IF PALTAB IS NOT NULL THEN
            FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
              PALTAB(I).PALRLID := P_RL.RLID; --��д����rlid��pal
              CASE PALTAB(I).PALMETHOD
                WHEN '07' THEN
                  --���ⵥ��+�Żݵ��ۣ�COD������
                  RD.RDYSDJ  := PALTAB(I).PALPRICE;
                  RD.RDDJ    := TOOLS.GETMAX(PALTAB(I)
                                             .PALPRICE + PALTAB(I)
                                             .PALWAY * PALTAB(I).PALVALUE,
                                             0);
                  RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                WHEN '01' THEN
                  --���۵���
                  BEGIN
                    RD.RDDJ    := TOOLS.GETMAX(RD.RDDJ + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE,
                                               0);
                    RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                  END;
                WHEN '02' THEN
                  --�̶�ˮ������
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
                WHEN '03' THEN
                  --����ˮ����������ϸʵ��ˮ��������λС��2009.7.6��
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
                WHEN '04' THEN
                  --�ۼ�ˮ������
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
                WHEN '08' THEN
                  --�������۵�����2009.10.4������
                  BEGIN
                    RD.RDADJDJ := TOOLS.GETMAX(RD.RDDJ *
                                               (1 + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE),
                                               0) - RD.RDDJ;
                    RD.RDDJ    := RD.RDDJ + RD.RDADJDJ;
                  END;
                ELSE
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
              END CASE;
            END LOOP;
          END IF;
          RD.RDYSJE := ROUND(RD.RDYSDJ * RD.RDYSSL, 2);
          RD.RDJE   := ROUND(RD.RDDJ * RD.RDSL, 2);
          --������ϸ��
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --����
          /*lgb tm 20120412*/
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
        END;
      WHEN 'sl2' THEN
        --�̶����ۡ�����/����  �е�����¥�� ��3��/���¼��㣻ƽ�� ��2��/���¼��㣬�볭���޹�
        BEGIN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '�ݲ�֧�ֵļƷѷ���' || PD.PDMETHOD);
        END;
      WHEN 'sl3' THEN
        -- raise_application_error(errcode, '����ˮ��');
        --���ݼƷ�  ��ģʽ����ˮ��

        RD.RDYSSL  := P_SL - P_��ϱ������;
        RD.RDADJDJ := 0;
        RD.RDADJSL := P_��ĵ����� + P_��ѵĵ����� + P_�����Ŀ������ + P_��ϱ������;
        RD.RDADJJE := 0;
        RD.RDSL    := P_SL + RD.RDADJSL - P_��ϱ������;
        /*          rd.rdsl    := p_sl  ;*/
        BEGIN
          --�������

          --���ݼƷ�
          CALSTEP(P_RL,
                  RD.RDYSSL,
                  RD.RDADJSL,
                  P_PMDID,
                  P_PMDSCALE,
                  PD,
                  RDTAB,
                  P_CLASSCTL,
                  PMD,
                  P_NY);

          /* --���ݼƷ�
          calstep(p_rl,
                  rd.rdsl,
                  rd.rdadjsl,
                  p_pmdid,
                  p_pmdscale,
                  pd,
                  rdtab,
                  p_classctl);*/

        END;
      WHEN 'njf' THEN
        --��ˮ���йأ�С�ڵ���X���չ̶�YԪ������X���չ̶�ZԪ(������������)
        SELECT * INTO MINFO FROM METERINFO MI WHERE MI.MIID = P_RL.RLMID;
        RD.RDCLASS := 0;
        /*
        if minfo.miusenum is null or minfo.miusenum = 0 then
             v_per := 1;
           else
             v_per := nvl(to_number(minfo.miusenum), 1);
           end if;*/

        -- yujia 20120208  �����Ѵ�2012��һ�·ݿ�ʼ����

        IF P_RL.RLPRDATE < TO_DATE('20120101', 'YYYY-MM-DD') THEN
          P_RL.RLPRDATE := TO_DATE('20120101', 'YYYY-MM-DD');
        END IF;

        IF P_RL.RLPRDATE IS NULL THEN
          V_MONTHS := 1;
        ELSE
          BEGIN
            SELECT NVL(MONTHS_BETWEEN(TRUNC(P_RL.RLRDATE, 'mm'),
                                      NVL(TRUNC(P_RL.RLPRDATE, 'mm'),
                                          ADD_MONTHS(TRUNC(P_RL.RLRDATE, 'mm'),
                                                     -1))),
                       0)
              INTO V_MONTHS --�Ʒ�ʱ������
              FROM DUAL;
          EXCEPTION
            WHEN OTHERS THEN
              V_MONTHS := 1;
          END;

          /*  --v_months := months_between(to_date(to_char(p_rl.RLRDATE,'yyyy.mm')), to_date(to_char(p_rl.RLPRDATE,'yyyy.mm')));
          v_months := trunc(months_between(p_rl.RLRDATE, p_rl.RLPRDATE));*/

        END IF;

        IF V_MONTHS < 1 THEN
          V_MONTHS := 1;
        END IF;

        /*  if minfo.miifmp = 'N' and minfo.mipfid in ('A1', 'A2') and
           minfo.MISTID = '30' then
          v_per    := 1;
          v_months := 2;
        end if;*/

        ---yujia [20120208 Ĭ��Ϊһ��]
        BEGIN
          V_PER := TO_NUMBER(MINFO.MIGPS);
          IF V_PER < 0 THEN
            V_PER := 0;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            V_PER := 0;
        END;

        IF V_PER >= 1 AND MINFO.MIIFMP = 'N' AND
           MINFO.MIPFID IN ('A1', 'A2') AND MINFO.MISTID = '30' AND
           P_RL.RLREADSL > 0 THEN
          RD.RDYSDJ := �����ѵ���;
          RD.RDYSSL := V_PER * V_MONTHS;
          RD.RDYSJE := �����ѵ��� * V_PER * V_MONTHS;

          RD.RDDJ    := �����ѵ���;
          RD.RDSL    := V_PER * V_MONTHS;
          RD.RDJE    := �����ѵ��� * V_PER * V_MONTHS;
          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;

        ELSE
          RD.RDYSDJ := 0;
          RD.RDYSSL := 0;
          RD.RDYSJE := 0;

          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;

          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
        END IF;

        ----$$$$$$$$$$$$$$$$$$$$$$$$4
        IF RD.RDJE > 0 THEN
          --������ϸ��

          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
        END IF;
        --����
        P_RL.RLJE := P_RL.RLJE + RD.RDJE;
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '��֧�ֵļƷѷ���' || PD.PDMETHOD);
    END CASE;

  EXCEPTION
    WHEN OTHERS THEN
      WLOG(P_RL.RLCCODE || '���������Ŀ�����쳣��' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --���ݼƷѲ���
  PROCEDURE CALSTEP(P_RL       IN OUT RECLIST%ROWTYPE,
                    P_SL       IN NUMBER,
                    P_ADJSL    IN NUMBER,
                    P_PMDID    IN NUMBER,
                    P_PMDSCALE IN NUMBER,
                    PD         IN PRICEDETAIL%ROWTYPE,
                    RDTAB      IN OUT RD_TABLE,
                    P_CLASSCTL IN CHAR,
                    PMD        PRICEMULTIDETAIL%ROWTYPE,
                    PMONTH     IN VARCHAR2) IS
    --rd.rdpiid��rd.rdpfid��rd.rdpscidΪ��Ҫ����
    CURSOR C_PS IS
      SELECT *
        FROM PRICESTEP
       WHERE PSPSCID = PD.PDPSCID
         AND PSPFID = PD.PDPFID
         AND PSPIID = PD.PDPIID
       ORDER BY PSCLASS;
    --��ʷˮ�۽���
    CURSOR C_PS_JT IS
      SELECT PSPSCID,
             PSPFID,
             PSPIID,
             PSCLASS,
             PSSCODE,
             PSECODE,
             PSPRICE,
             PSMEMO
        FROM PRICESTEP_VER T1, PRICEVER T
       WHERE SMONTH <= PMONTH
         AND EMONTH >= PMONTH
         AND PSPSCID = PD.PDPSCID
         AND PSPFID = PD.PDPFID
         AND PSPIID = PD.PDPIID
         AND ID = VERID
       ORDER BY PSCLASS;

    TMPYSSL NUMBER;
    TMPSL   NUMBER;
    RD      RECDETAIL%ROWTYPE;
    PS      PRICESTEP%ROWTYPE;
    MINFO   METERINFO%ROWTYPE;
    N       NUMBER; --�Ʒ�����
    V_NUM   NUMBER;
  BEGIN
    RD.RDID       := P_RL.RLID;
    RD.RDPMDID    := P_PMDID;
    RD.RDPMDSCALE := P_PMDSCALE;
    RD.RDPIID     := PD.PDPIID;
    RD.RDPFID     := PD.PDPFID;
    RD.RDPSCID    := PD.PDPSCID;
    RD.RDMETHOD   := PD.PDMETHOD;
    RD.RDPAIDFLAG := 'N';

    RD.RDMSMFID  := P_RL.RLMSMFID; --Ӫ����˾
    RD.RDMONTH   := P_RL.RLMONTH; --�����·�
    RD.RDMID     := P_RL.RLMID; --ˮ����
    RD.RDPMDTYPE := NVL(PMD.PMDTYPE, '01'); --������

    RD.RDPMDCOLUMN1 := PMD.PMDCOLUMN1; --�����ֶ�1
    RD.RDPMDCOLUMN2 := PMD.PMDCOLUMN2; --�����ֶ�2
    RD.RDPMDCOLUMN3 := PMD.PMDCOLUMN3; --�����ֶ�3

    TMPYSSL := P_SL; --�����ۼ�Ӧ��ˮ�����
    TMPSL   := P_SL + P_ADJSL; --�����ۼ�ʵ��ˮ�����

    --�ж������Ƿ�������ȡ���ݵ�����
    SELECT MI.*
      INTO MINFO
      FROM METERINFO MI
     WHERE MI.MICODE = P_RL.RLMCODE;

    --- yujia20120208 [ֻ��˽���ͼ����û����ý��ݼ���]
    BEGIN
      SELECT CEIL(NVL(MONTHS_BETWEEN(P_RL.RLRDATE,
                                     NVL(P_RL.RLPRDATE,
                                         ADD_MONTHS(P_RL.RLRDATE, 1)) + 1),
                      0))
        INTO N --�Ʒ�ʱ������
        FROM DUAL;
    EXCEPTION
      WHEN OTHERS THEN
        N := 0;
    END;
    IF N <= 0 THEN
      N := 999999; --�쳣���ڶ��������
    END IF;

    IF PMONTH = '0000.00' OR PMONTH IS NULL THEN
      OPEN C_PS;
      FETCH C_PS
        INTO PS;
      IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�Ľ��ݼƷ�����');
      END IF;
      WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
        -- >=0��֤0��ˮ����һ��������ϸ
        /*
        ��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
        ���人ˮ����ݹ��򣨻�/�˾���ˮ����ͬһ��ַ������ˮ����ˮ��֮��Ϊ�������㣩                      ��
        ��1����ͥ�����˿���4�����£���4�ˣ�����ˮ����������ˮ�����ֽ���ʽ����ˮ�ۡ�                      ��
        ��2����ͥ�����˿���5�ˣ���5�ˣ����ϵ���ˮ�������˾���ˮ�����ֽ���ʽ����ˮ�ۡ�                    ��
        ���������������������Щ����������������������������������������������Щ����������������������������������������������������������������������Щ���������������������������������������������������
        ���������� ������ˮ���� 25������     ��25�����ף�����ˮ����33������        ������ˮ���� 33������      ��
        �����˼��� ���˾���ˮ���� 6.25������ ��6.25�����ף��˾���ˮ���� 8.25������ ���˾���ˮ���� 8.25������  ��
        ��ˮ��     ��1.1                    ��1.65                               ��2.2                      ��
        ���������������������ة����������������������������������������������ة����������������������������������������������������������������������ة���������������������������������������������������
        */ --һ��ֹ������Ҫ������ֵ��ͬ����������
        /*if nvl(p_rl.rlusenum, 0) >= 5 then
          if ps.psclass = 1 then
            ps.psecode := 6.25 * p_rl.rlusenum;
          elsif ps.psclass = 2 then
            ps.psscode := 6.25 * p_rl.rlusenum;
            ps.psecode := 8.25 * p_rl.rlusenum;
          else
            ps.psscode := 8.25 * p_rl.rlusenum;
          end if;
        end if;*/

        IF MINFO.MIUSENUM IS NULL OR MINFO.MIUSENUM = 0 THEN
          V_NUM := 1;
        ELSE
          V_NUM := NVL(MINFO.MIUSENUM, 1) / 4;
        END IF;

        RD.RDCLASS := PS.PSCLASS;
        RD.RDYSDJ  := PS.PSPRICE;
        RD.RDYSSL  := TOOLS.GETMIN(TMPYSSL,
                                   CEIL(V_NUM * N *
                                        (PS.PSECODE - PS.PSSCODE + 1)));
        RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;

        RD.RDDJ := PS.PSPRICE;
        RD.RDSL := TOOLS.GETMIN(TMPSL,
                                CEIL(V_NUM * N *
                                     (PS.PSECODE - PS.PSSCODE + 1)));
        RD.RDJE := RD.RDDJ * RD.RDSL;

        RD.RDADJDJ := 0;
        RD.RDADJSL := RD.RDSL - RD.RDYSSL;
        RD.RDADJJE := 0;

        --������ϸ��
        IF RDTAB IS NULL THEN
          RDTAB := RD_TABLE(RD);
        ELSE
          RDTAB.EXTEND;
          RDTAB(RDTAB.LAST) := RD;
        END IF;
        --����
        P_RL.RLJE := P_RL.RLJE + RD.RDJE;
        P_RL.RLSL := P_RL.RLSL + (CASE
                       WHEN RD.RDPIID = '01' THEN
                        RD.RDSL
                       ELSE
                        0
                     END);

        TMPYSSL := TOOLS.GETMAX(TMPYSSL -
                                CEIL(V_NUM * N *
                                     (PS.PSECODE - PS.PSSCODE + 1)),
                                0);
        TMPSL   := TOOLS.GETMAX(TMPSL -
                                CEIL(V_NUM * N *
                                     (PS.PSECODE - PS.PSSCODE + 1)),
                                0);
        EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
        FETCH C_PS
          INTO PS;
      END LOOP;
      CLOSE C_PS;
    ELSE
      --
      OPEN C_PS_JT;
      FETCH C_PS_JT
        INTO PS;
      IF C_PS_JT%NOTFOUND OR C_PS_JT%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�Ľ��ݼƷ�����');
      END IF;
      WHILE C_PS_JT%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
        -- >=0��֤0��ˮ����һ��������ϸ
        /*
        ��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
        ���人ˮ����ݹ��򣨻�/�˾���ˮ����ͬһ��ַ������ˮ����ˮ��֮��Ϊ�������㣩                      ��
        ��1����ͥ�����˿���4�����£���4�ˣ�����ˮ����������ˮ�����ֽ���ʽ����ˮ�ۡ�                      ��
        ��2����ͥ�����˿���5�ˣ���5�ˣ����ϵ���ˮ�������˾���ˮ�����ֽ���ʽ����ˮ�ۡ�                    ��
        ���������������������Щ����������������������������������������������Щ����������������������������������������������������������������������Щ���������������������������������������������������
        ���������� ������ˮ���� 25������     ��25�����ף�����ˮ����33������        ������ˮ���� 33������      ��
        �����˼��� ���˾���ˮ���� 6.25������ ��6.25�����ף��˾���ˮ���� 8.25������ ���˾���ˮ���� 8.25������  ��
        ��ˮ��     ��1.1                    ��1.65                               ��2.2                      ��
        ���������������������ة����������������������������������������������ة����������������������������������������������������������������������ة���������������������������������������������������
        */ --һ��ֹ������Ҫ������ֵ��ͬ����������
        /*if nvl(p_rl.rlusenum, 0) >= 5 then
          if ps.psclass = 1 then
            ps.psecode := 6.25 * p_rl.rlusenum;
          elsif ps.psclass = 2 then
            ps.psscode := 6.25 * p_rl.rlusenum;
            ps.psecode := 8.25 * p_rl.rlusenum;
          else
            ps.psscode := 8.25 * p_rl.rlusenum;
          end if;
        end if;*/

        IF MINFO.MIUSENUM IS NULL THEN
          V_NUM := 1;
        ELSE
          V_NUM := NVL(MINFO.MIUSENUM, 1) / 4;
        END IF;

        RD.RDCLASS := PS.PSCLASS;
        RD.RDYSDJ  := PS.PSPRICE;
        RD.RDYSSL  := TOOLS.GETMIN(TMPYSSL,
                                   CEIL(V_NUM * N *
                                        (PS.PSECODE - PS.PSSCODE + 1)));
        RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;

        RD.RDDJ := PS.PSPRICE;
        RD.RDSL := TOOLS.GETMIN(TMPSL,
                                CEIL(V_NUM * N *
                                     (PS.PSECODE - PS.PSSCODE + 1)));
        RD.RDJE := RD.RDDJ * RD.RDSL;

        RD.RDADJDJ := 0;
        RD.RDADJSL := RD.RDSL - RD.RDYSSL;
        RD.RDADJJE := 0;

        --������ϸ��
        IF RDTAB IS NULL THEN
          RDTAB := RD_TABLE(RD);
        ELSE
          RDTAB.EXTEND;
          RDTAB(RDTAB.LAST) := RD;
        END IF;
        --����
        P_RL.RLJE := P_RL.RLJE + RD.RDJE;
        P_RL.RLSL := P_RL.RLSL + (CASE
                       WHEN RD.RDPIID = '01' THEN
                        RD.RDSL
                       ELSE
                        0
                     END);

        TMPYSSL := TOOLS.GETMAX(TMPYSSL -
                                CEIL(V_NUM * N *
                                     (PS.PSECODE - PS.PSSCODE + 1)),
                                0);
        TMPSL   := TOOLS.GETMAX(TMPSL -
                                CEIL(V_NUM * N *
                                     (PS.PSECODE - PS.PSSCODE + 1)),
                                0);
        EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
        FETCH C_PS_JT
          INTO PS;
      END LOOP;
      CLOSE C_PS_JT;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_PS%ISOPEN THEN
        CLOSE C_PS;
      END IF;
      IF C_PS_JT%ISOPEN THEN
        CLOSE C_PS_JT;
      END IF;
      WLOG(P_RL.RLCCODE || '�������ˮ�������쳣��' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  PROCEDURE INSRD(RD IN RD_TABLE) IS
    VRD      RECDETAIL%ROWTYPE;
    I        NUMBER;
    V_RDPIID VARCHAR2(10);
  BEGIN
    FOR I IN RD.FIRST .. RD.LAST LOOP
      VRD      := RD(I);
      V_RDPIID := VRD.RDPIID;
      IF �Ƿ�������� = 'N' THEN
        INSERT INTO RECDETAIL VALUES VRD;
      ELSE
        INSERT INTO RECDETAILTEMP VALUES VRD;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --Ԥ��ۿ�(Ԥ��ֿۣ�����������)
  PROCEDURE SP_RLSAVING(MI      IN METERINFO%ROWTYPE,
                        RL      IN RECLIST%ROWTYPE,
                        P_BATCH VARCHAR2) IS
    V_RDPIID      VARCHAR2(4000);
    YCSUM         METERINFO.MISAVING%TYPE;
    VBATCH        VARCHAR2(10);
    V_BKJE        NUMBER;
    V_YCJE        NUMBER;
    MIS           METERINFO%ROWTYPE;
    V_SVAINGBATCH VARCHAR2(50);
    V_OUTPBATCH   VARCHAR2(1000); --Ԥ�����Σ������ձ�����
    V_RLZNJ       NUMBER(12, 2);
    V_RET         VARCHAR2(5);
    CURSOR C_MISAVING(VMICODE VARCHAR2) IS
      SELECT *
        FROM METERINFO
       WHERE MIPRIID IN
             (SELECT MIPRIID FROM METERINFO WHERE MICODE = VMICODE)
         AND MICODE <> VMICODE
         AND MISAVING > 0;
  BEGIN

    SELECT PG_EWIDE_PAY_01.GETZNJADJ(RL.RLID,
                                     RL.RLJE,
                                     RL.RLGROUP,
                                     RL.RLZNDATE,
                                     RL.RLSMFID,
                                     SYSDATE)
      INTO V_RLZNJ
      FROM DUAL;

    --ȫ�ֿ��أ����ʱԤ���Զ�����
    IF TRIM(MI.MIPRIID) IS NOT NULL THEN
      --���ձ��û�
      IF NVL(MI.MISAVING, 0) >= RL.RLJE + V_RLZNJ AND RL.RLJE > 0 THEN
        --���ձ�ˮ��Ԥ���㹻ֱ������
        BEGIN

          /*          PG_ewide_PAY_01.pos(rl.rlsmfid, --�ɷѻ���
          'system', --�տ�Ա
          rl.rlid, --Ӧ����ˮ
          rl.rlmid, --����
          rl.rlje, --Ӧ�ս��
          v_rlznj, --����ΥԼ��
          0, --������
          0, --ʵ���տ�
          PG_ewide_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
          PG_ewide_PAY_01.DEBIT, --�������
          'XJ', --���ʽ
          rl.rlsmfid, --�ɷѵص�
          p_batch, --�ɷ�������ˮ
          'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
          NULL, --��Ʊ��
          'N' --�ύ��־
          );*/
          V_RET := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                       RL.RLSMFID, --�ɷѻ���
                                       'system', --�տ�Ա
                                       RL.RLID || '|', --Ӧ����ˮ
                                       RL.RLJE, --Ӧ�ս��
                                       V_RLZNJ, --����ΥԼ��
                                       0, --������
                                       0, --ʵ���տ�
                                       PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                       RL.RLMID, --����
                                       'XJ', --���ʽ
                                       RL.RLSMFID, --�ɷѵص�
                                       FGETSEQUENCE('ENTRUSTLOG'), --�ɷ�������ˮ
                                       'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                       '', --��Ʊ��
                                       'N' --�����Ƿ��ύ��Y/N��
                                       );

        EXCEPTION
          WHEN OTHERS THEN
            WLOG('Ԥ����ʱ�ֿ�Ӧ����ʱ��������' || MI.MIID);
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    'Ԥ����ʱ�ֿ�Ӧ����ʱ��������' || MI.MIID);
        END;
      ELSIF RL.RLJE > 0 THEN
        --���㣬��������ˮ����ȡԤ��
        SELECT SUM(MISAVING)
          INTO YCSUM
          FROM METERINFO
         WHERE MIPRIID = MI.MIPRIID;

        IF YCSUM IS NOT NULL AND YCSUM >= RL.RLJE + V_RLZNJ AND YCSUM > 0 THEN
          --�жϺ��ձ�����Ԥ�棬�Ƿ����Ƿ�ѽ��

          V_BKJE := RL.RLJE + V_RLZNJ - MI.MISAVING; --��ȡǷ�ѽ��
          V_YCJE := V_BKJE;
          OPEN C_MISAVING(MI.MICODE);
          LOOP
            FETCH C_MISAVING
              INTO MIS;
            EXIT WHEN C_MISAVING%NOTFOUND OR C_MISAVING%NOTFOUND IS NULL;
            IF MIS.MISAVING >= V_BKJE THEN

              /*              PG_ewide_PAY_01.pos(mis.mismfid, --�ɷѻ���
              'system', --�տ�Ա
              NULL, --Ӧ����ˮ
              mis.miid, --����
              0, --Ӧ�ս��
              0, --����ΥԼ��
              0, --������
              -v_bkje, --ʵ���տ�
              PG_ewide_PAY_01.PAYTRANS_SAV, --�ɷ�����
              PG_ewide_PAY_01.CREDIT, --�������
              'XJ', --���ʽ
              mis.mismfid, --�ɷѵص�
              p_batch, --�ɷ�������ˮ
              'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
              NULL, --��Ʊ��
              'N' --�ύ��־
              );*/

              V_RET  := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                            RL.RLSMFID, --�ɷѻ���
                                            'system', --�տ�Ա
                                            NULL, --Ӧ����ˮ
                                            0, --Ӧ�ս��
                                            V_RLZNJ, --����ΥԼ��
                                            0, --������
                                            V_BKJE, --ʵ���տ�
                                            PG_EWIDE_PAY_01.PAYTRANS_SAV, --�ɷ�����
                                            RL.RLMID, --����
                                            'XJ', --���ʽ
                                            RL.RLSMFID, --�ɷѵص�
                                            FGETSEQUENCE('ENTRUSTLOG'), --�ɷ�������ˮ
                                            'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                            '', --��Ʊ��
                                            'N' --�����Ƿ��ύ��Y/N��
                                            );
              V_BKJE := 0;
              EXIT;
            ELSE
              /*              PG_ewide_PAY_01.pos(mis.mismfid, --�ɷѻ���
              'system', --�տ�Ա
              NULL, --Ӧ����ˮ
              mis.miid, --����
              0, --Ӧ�ս��
              0, --����ΥԼ��
              0, --������
              -mis.misaving, --ʵ���տ�
              PG_ewide_PAY_01.PAYTRANS_SAV, --�ɷ�����
              PG_ewide_PAY_01.CREDIT, --�������
              'XJ', --���ʽ
              mis.mismfid, --�ɷѵص�
              p_batch, --�ɷ�������ˮ
              'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
              NULL, --��Ʊ��
              'N' --�ύ��־
              );*/

              V_RET  := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                            RL.RLSMFID, --�ɷѻ���
                                            'system', --�տ�Ա
                                            NULL, --Ӧ����ˮ
                                            0, --Ӧ�ս��
                                            V_RLZNJ, --����ΥԼ��
                                            0, --������
                                            MIS.MISAVING, --ʵ���տ�
                                            PG_EWIDE_PAY_01.PAYTRANS_SAV, --�ɷ�����
                                            RL.RLMID, --����
                                            'XJ', --���ʽ
                                            RL.RLSMFID, --�ɷѵص�
                                            FGETSEQUENCE('ENTRUSTLOG'), --�ɷ�������ˮ
                                            'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                            '', --��Ʊ��
                                            'N' --�����Ƿ��ύ��Y/N��
                                            );
              V_BKJE := V_BKJE - MIS.MISAVING;
            END IF;
          END LOOP;
          CLOSE C_MISAVING;

          IF V_BKJE <> 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '����,��������' || MI.MICODE);
          END IF;

          /*          PG_ewide_PAY_01.pos(mi.mismfid, --�ɷѻ���
          'system', --�տ�Ա
          NULL, --Ӧ����ˮ
          mi.miid, --����
          0, --Ӧ�ս��
          0, --����ΥԼ��
          0, --������
          v_ycje, --ʵ���տ�
          PG_ewide_PAY_01.PAYTRANS_SAV, --�ɷ�����
          PG_ewide_PAY_01.DEBIT, --�������
          'XJ', --���ʽ
          mi.mismfid, --�ɷѵص�
          p_batch, --�ɷ�������ˮ
          'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
          NULL, --��Ʊ��
          'N' --�ύ��־
          );*/

          V_RET := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                       RL.RLSMFID, --�ɷѻ���
                                       'system', --�տ�Ա
                                       NULL, --Ӧ����ˮ
                                       0, --Ӧ�ս��
                                       V_RLZNJ, --����ΥԼ��
                                       0, --������
                                       V_YCJE, --ʵ���տ�
                                       PG_EWIDE_PAY_01.PAYTRANS_SAV, --�ɷ�����
                                       RL.RLMID, --����
                                       'XJ', --���ʽ
                                       RL.RLSMFID, --�ɷѵص�
                                       FGETSEQUENCE('ENTRUSTLOG'), --�ɷ�������ˮ
                                       'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                       '', --��Ʊ��
                                       'N' --�����Ƿ��ύ��Y/N��
                                       );

          --����ȡԤ��

          /*          PG_ewide_PAY_01.pos(rl.rlsmfid, --�ɷѻ���
          'system', --�տ�Ա
          rl.rlid, --Ӧ����ˮ
          rl.rlmid, --����
          rl.rlje, --Ӧ�ս��
          v_rlznj, --����ΥԼ��
          0, --������
          0, --ʵ���տ�
          PG_ewide_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
          PG_ewide_PAY_01.DEBIT, --�������
          'XJ', --���ʽ
          rl.rlsmfid, --�ɷѵص�
          p_batch, --�ɷ�������ˮ
          'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
          NULL, --��Ʊ��
          'N' --�ύ��־
          );*/
          V_RET := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                       RL.RLSMFID, --�ɷѻ���
                                       'system', --�տ�Ա
                                       RL.RLID || '|', --Ӧ����ˮ
                                       RL.RLJE, --Ӧ�ս��
                                       V_RLZNJ, --����ΥԼ��
                                       0, --������
                                       0, --ʵ���տ�
                                       PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                       RL.RLMID, --����
                                       'XJ', --���ʽ
                                       RL.RLSMFID, --�ɷѵص�
                                       FGETSEQUENCE('ENTRUSTLOG'), --�ɷ�������ˮ
                                       'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                       '', --��Ʊ��
                                       'N' --�����Ƿ��ύ��Y/N��
                                       );
        END IF;

      END IF;
    ELSE

      IF NVL(MI.MISAVING, 0) >= RL.RLJE + V_RLZNJ AND RL.RLJE > 0 THEN
        -- �Ǻ��ձ�ˮ��Ԥ���㹻ֱ������
        BEGIN
          /*          PG_ewide_PAY_01.pos(rl.rlsmfid, --�ɷѻ���
          'system', --�տ�Ա
          rl.rlid, --Ӧ����ˮ
          rl.rlmid, --����
          rl.rlje, --Ӧ�ս��
          v_rlznj, --����ΥԼ��
          0, --������
          0, --ʵ���տ�
          PG_ewide_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
          PG_ewide_PAY_01.DEBIT, --�������
          'XJ', --���ʽ
          rl.rlsmfid, --�ɷѵص�
          p_batch, --�ɷ�������ˮ
          'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
          NULL, --��Ʊ��
          'N' --�ύ��־
          );*/
          V_RET := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                       RL.RLSMFID, --�ɷѻ���
                                       'system', --�տ�Ա
                                       RL.RLID || '|', --Ӧ����ˮ
                                       RL.RLJE, --Ӧ�ս��
                                       V_RLZNJ, --����ΥԼ��
                                       0, --������
                                       0, --ʵ���տ�
                                       PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                       RL.RLMID, --����
                                       'XJ', --���ʽ
                                       RL.RLSMFID, --�ɷѵص�
                                       FGETSEQUENCE('ENTRUSTLOG'), --�ɷ�������ˮ
                                       'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                       '', --��Ʊ��
                                       'N' --�����Ƿ��ύ��Y/N��
                                       );
        EXCEPTION
          WHEN OTHERS THEN
            WLOG('Ԥ����ʱ�ֿ�Ӧ����ʱ��������' || MI.MIID);
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    'Ԥ����ʱ�ֿ�Ӧ����ʱ��������' || MI.MIID);
        END;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  PROCEDURE ��������(P_BFID IN VARCHAR2) IS
    /****����Ӧ�ջ���*/
    CURSOR C_RLTEMP(P_RLBFID IN VARCHAR2, P_RLSMFID IN VARCHAR2) IS
      SELECT *
        FROM RECLISTTEMP RLT
       WHERE RLT.RLBFID = P_RLBFID
         AND RLT.RLSMFID = P_RLSMFID
         FOR UPDATE NOWAIT;
    /****����Ӧ����ϸ*/
    CURSOR C_RDTEMP(P_RLID IN VARCHAR2) IS
      SELECT *
        FROM RECDETAILTEMP RDT
       WHERE RDT.RDID = P_RLID
         FOR UPDATE NOWAIT;
    /***������Ϣ**/
    CURSOR C_MR(P_MRID IN VARCHAR2) IS
      SELECT * FROM METERREAD WHERE MRID = P_MRID FOR UPDATE NOWAIT;
    /*********�û���Ϣ**********/
    CURSOR C_MI(VMIID IN METERINFO.MIID%TYPE) IS
      SELECT * FROM METERINFO WHERE MIID = VMIID FOR UPDATE;
    VMRID    METERREAD.MRID%TYPE;
    VBFID    METERREAD.MRBFID%TYPE;
    VSMFID   METERREAD.MRSMFID%TYPE;
    V_RLTEMP RECLISTTEMP%ROWTYPE;
    V_RD     RECDETAILTEMP%ROWTYPE;
    MR       METERREAD%ROWTYPE;
    MI       METERINFO%ROWTYPE;
    RDTAB    RDT_TABLE;

  BEGIN
    FOR I IN 1 .. TOOLS.FBOUNDPARA(P_BFID) LOOP
      VBFID  := TOOLS.FGETPARA(P_BFID, I, 1);
      VSMFID := TOOLS.FGETPARA(P_BFID, I, 2);
      OPEN C_RLTEMP(VBFID, VSMFID);
      LOOP
        FETCH C_RLTEMP
          INTO V_RLTEMP;
        EXIT WHEN C_RLTEMP%NOTFOUND OR C_RLTEMP%NOTFOUND IS NULL;

        --���������¼
        OPEN C_MR(V_RLTEMP.RLMRID);
        FETCH C_MR
          INTO MR;
        IF C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�ĳ���ƻ���ˮ��');
        END IF;

        --����ˮ���¼
        OPEN C_MI(MR.MRMID);
        FETCH C_MI
          INTO MI;
        IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
        END IF;
        /***********������ʽӦ�ջ���************/
        INSERT INTO RECLIST VALUES V_RLTEMP;
        --����Ӧ����ϸ��¼
        OPEN C_RDTEMP(V_RLTEMP.RLID);
        LOOP
          FETCH C_RDTEMP
            INTO V_RD;
          EXIT WHEN C_RDTEMP%NOTFOUND OR C_RDTEMP%NOTFOUND IS NULL;

          /***********������ʽӦ����ϸ************/
          INSERT INTO RECDETAIL VALUES V_RD;
        END LOOP;

        /**************���³����¼******************/
        UPDATE METERREAD
           SET MRIFREC   = 'Y',
               MRRECDATE = V_RLTEMP.RLDATE,
               MRRECSL   = V_RLTEMP.RLSL
         WHERE CURRENT OF C_MR;
        /**************����ˮ��******************/
        IF MR.MRMEMO = '��������Ƿ��' THEN
          UPDATE METERINFO
             SET MIRCODE     = MIREINSCODE,
                 MIRECDATE   = MR.MRRDATE,
                 MIRECSL     = MR.MRSL, --ȡ����ˮ����������
                 MIFACE      = MR.MRFACE,
                 MINEWFLAG   = 'N',
                 MIRCODECHAR = MIREINSCODE
           WHERE CURRENT OF C_MI;
        ELSE
          UPDATE METERINFO
             SET MIRCODE     = MR.MRECODE,
                 MIRECDATE   = MR.MRRDATE,
                 MIRECSL     = MR.MRSL, --ȡ����ˮ����������
                 MIFACE      = MR.MRFACE,
                 MINEWFLAG   = 'N',
                 MIRCODECHAR = MR.MRECODECHAR
           WHERE CURRENT OF C_MI;
        END IF;
        /*******ɾ����ʱ��������Ϣ*********/
        DELETE RECLISTTEMP WHERE RLID = V_RLTEMP.RLID;

        IF C_MR%ISOPEN THEN
          CLOSE C_MR;
        END IF;
        IF C_MI%ISOPEN THEN
          CLOSE C_MI;
        END IF;
        IF C_RDTEMP%ISOPEN THEN
          CLOSE C_RDTEMP;
        END IF;
      END LOOP;
      /*********�ر�����α�********/
      IF C_RLTEMP%ISOPEN THEN
        CLOSE C_RLTEMP;
      END IF; 

    END LOOP;
  END;
  PROCEDURE INSRD01(RD IN RD_TABLE) IS
    VRD      RECDETAIL%ROWTYPE;
    I        NUMBER;
    V_RDPIID VARCHAR2(10);
  BEGIN
    FOR I IN RD.FIRST .. RD.LAST LOOP
      VRD      := RD(I);
      V_RDPIID := VRD.RDPIID;
      INSERT INTO RECDETAIL VALUES VRD;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
BEGIN
  ˮ������                  := TO_NUMBER(FSYSPARA('0042'));
  �ܱ����                  := FSYSPARA('1069');
  ������ˮ��              := TO_NUMBER(FSYSPARA('1092'));
  ������ˮ����ˮ��          := TO_NUMBER(FSYSPARA('1096'));
  �����ѵ���                := TO_NUMBER(FSYSPARA('1097'));
  �����Ѵ��ڷ�ˮ��ˮ����XԪ := TO_NUMBER(FSYSPARA('1098'));
  �汾����                  := FSYSPARA('sys1');
  �Ƿ��������              := FSYSPARA('ifrl');
END;
/

