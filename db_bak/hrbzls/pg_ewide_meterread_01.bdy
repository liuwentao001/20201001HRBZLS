CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_METERREAD_01" IS
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
         and METERINFO.mistatus not in ('24', '35', '36', '19') --���ʱ�����ϻ����С����ڻ����С�Ԥ������С������еĲ��������,��ѹ��ϻ����С����ڻ����е�������������� 20140628
         AND MRIFREC = 'N'
            /******* ��;���Ƿ���ѵ���������
                       ʱ�䣺2012-04-13
                      �޸��ˣ����Ⲩ
            *****/
            --AND MICLASS = 1
            --AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, '1') = 'Y' --δ�Ʒ�
            --AND MRIFSUBMIT = 'Y' --����Ʒ�(�û�����)
            --AND MRIFHALT = 'N' --ͣ��(ϵͳָ��)
         AND MRREADOK = 'Y' --����״̬
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

  --���ǰ������ѣ����³�����ϸ����
  FUNCTION CALCULATEBF(P_MRID IN VARCHAR2, P_TYPE IN VARCHAR2) RETURN NUMBER AS
    --ȡ������Ϣ
    CURSOR C_MR IS
      SELECT *
        FROM VIEW_METERREADALL
       WHERE MRID = P_MRID
            --AND MRIFREC = 'N'
         AND MRSL > 0;
  
    --ȡˮ����Ϣ
    CURSOR C_MI(P_MID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = P_MID;
  
    --20140512 �ܱ�����޸�
    --�ܱ����=�ӱ���������M��+�ӱ�����³���ˮ����1��
    --׷���շѵ�
    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRREADOK, mrcarrysl --����ˮ��Ralph 20150511
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
      UNION ALL
      SELECT MRSL, MRIFREC, MRREADOK, mrcarrysl --����ˮ��Ralph 20150511
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
         AND MRDATASOURCE = 'M'
         AND RLREVERSEFLAG = 'N';
  
    CURSOR C_PRICEAD(P_MRCODE IN VARCHAR2, P_MRMONTH IN VARCHAR2) IS
      SELECT *
        FROM PRICEADJUSTLIST
       WHERE PALCID = P_MRCODE
         AND PALSTATUS = 'Y'
         AND PALSTARTMON <= P_MRMONTH
         AND (PALENDMON >= P_MRMONTH OR PALENDMON IS NULL);
  
    --ȡ�����Ӧ����Ϣ
    CURSOR C_REC(P_MRID VARCHAR2) IS
      SELECT RL.RLSL, (RD.DJ1 + RD.DJ2 + RD.DJ3) RLDJ, RL.RLJE
        FROM RECLIST RL, VIEW_RECLIST_CHARGE RD
       WHERE RL.RLID = RD.RDID
         AND RL.RLMRID = P_MRID;
  
    MR        VIEW_METERREADALL%ROWTYPE;
    MRCHILD   METERREAD%ROWTYPE;
    MI        METERINFO%ROWTYPE;
    V_PRICEAD PRICEADJUSTLIST%ROWTYPE;
  
    ERR_READ EXCEPTION; --�ӱ�δ����
    GET_SL   EXCEPTION; --ȡˮ��
    GET_DJ   EXCEPTION; --ȡ����
    GET_JE   EXCEPTION; --ȡ���
  
    REC_SL NUMBER;
    REC_DJ NUMBER(10, 2);
    REC_JE NUMBER(10, 2);
  
    V_SL  NUMBER;
    V_DJ  NUMBER;
    V_JE  NUMBER;
    V_RET VARCHAR2(400);
  
    V_SUMNUM  NUMBER; --�ӱ���
    V_READNUM NUMBER; --�����ӱ���
    V_RECNUM  NUMBER; --����ӱ���
    V_MRMCODE VARCHAR2(10);
  
  BEGIN
  
    OPEN C_MR;
    FETCH C_MR
      INTO MR;
  
    IF MR.MRIFREC = 'N' THEN
    
      OPEN C_MI(MR.MRMID);
      FETCH C_MI
        INTO MI;
      CLOSE C_MI;
    
      MR.MRRECSL := MR.MRSL;
      -----------------------------------------------------------------------------
      --�ӱ�ˮ���ּ��Ʒ��ܱ���ˮ��
      -----------------------------------------------------------------------------
      --STEP1 ����Ƿ��ܱ�
      IF MI.MICLASS = 2 THEN
        --���ܱ�
        V_MRMCODE := MR.MRMCODE; --��ֵΪ�ܱ��
      
        --STEP2 �ж��ܱ��µķֱ����Ƿ����δ���ӱ� ���ӱ�δ�³���δ��������δ����ӱ�
        SELECT COUNT(*),
               SUM(DECODE(NVL(MRREADOK, 'N'), 'Y', 1, 0)),
               SUM(DECODE(NVL(MRIFREC, 'N'), 'Y', 1, 0))
          INTO V_SUMNUM, V_READNUM, V_RECNUM
          FROM METERINFO, METERREAD
         WHERE MIID = MRMID(+)
           AND MIPID = V_MRMCODE
           AND MICLASS = '3';
        --����ӱ����ʹ����ӱ��ѳ������ͣ������δ���ӱ�
        IF V_SUMNUM > V_READNUM THEN
          RAISE ERR_READ;
        ELSE
          --STEP3 ȡ�����ӱ�ˮ�������
          OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
          LOOP
            FETCH C_MR_CHILD
              INTO MRCHILD.MRSL,
                   MRCHILD.MRIFREC,
                   MRCHILD.MRREADOK,
                   MRCHILD.mrcarrysl;
            EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
            --����ˮ��
            MR.MRRECSL := MR.MRRECSL - MRCHILD.MRSL -
                          nvl(MRCHILD.mrcarrysl, 0); --���ӶԼ���ˮ���ٳ� 20150511 ralph
          END LOOP;
          CLOSE C_MR_CHILD;
          --����շ��ܱ�ˮ��С���ӱ�ˮ�����ܱ�ˮ������0
          IF MR.MRRECSL < 0 THEN
            V_SL := 0;
          ELSE
            V_SL := MR.MRRECSL;
          END IF;
        END IF;
      ELSE
        V_SL := MR.MRRECSL;
      END IF;
    
      -----------------------------------------------------------------------------
      --��Ʒѵ���ˮ��
      -----------------------------------------------------------------------------
      IF V_SL > 0 THEN
        OPEN C_PRICEAD(MR.MRMCODE, MR.MRMONTH);
        FETCH C_PRICEAD
          INTO V_PRICEAD;
        IF V_PRICEAD.PALMETHOD = '02' THEN
          V_SL := V_SL + V_PRICEAD.PALWAY * V_PRICEAD.PALVALUE;
        ELSIF V_PRICEAD.PALMETHOD = '03' THEN
          V_SL := V_SL + (V_SL * V_PRICEAD.PALWAY * V_PRICEAD.PALVALUE);
        END IF;
        CLOSE C_PRICEAD;
      END IF;
    
      CLOSE C_MR;
    
      -----------------------------------------------------------------------------
      --ȡӦ�յ�����Ӧ��ˮ��
      -----------------------------------------------------------------------------
      V_DJ := FGETPRICEDJ(MI.MIPFID) + FGEWSCBDJ(MR.MRMCODE, MR.MRMONTH); --Ӧ�յ��ۣ�����ˮ���꣩
      V_JE := V_SL * V_DJ;
    
    ELSE
      OPEN C_REC(MR.MRID);
      FETCH C_REC
        INTO REC_SL, REC_DJ, REC_JE;
      V_SL := REC_SL;
      V_DJ := REC_DJ;
      V_JE := REC_JE;
      CLOSE C_REC;
    END IF;
  
    IF UPPER(P_TYPE) = 'SL' THEN
      RAISE GET_SL;
    ELSIF UPPER(P_TYPE) = 'DJ' THEN
      RAISE GET_DJ;
    ELSIF UPPER(P_TYPE) = 'JE' THEN
      RAISE GET_JE;
    END IF;
  
    RETURN V_RET;
  
  EXCEPTION
    WHEN ERR_READ THEN
      RETURN NULL;
    WHEN GET_SL THEN
      V_RET := V_SL;
      RETURN V_RET;
    WHEN GET_DJ THEN
      V_RET := V_DJ;
      RETURN V_RET;
    WHEN GET_JE THEN
      V_RET := V_JE;
      RETURN V_RET;
    WHEN OTHERS THEN
      V_RET := NULL;
      RETURN V_RET;
  END;

  --�ƻ����������
  PROCEDURE CALCULATE(P_MRID IN METERREAD.MRID%TYPE) IS
    CURSOR C_MR IS
      SELECT *
        FROM METERREAD
       WHERE MRID = P_MRID
         AND MRIFREC = 'N'
         AND MRSL >= 0 --20140522 0��ˮ�������
         FOR UPDATE NOWAIT;
  
    --�ֱܷ��ӱ����¼
    /*    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2) IS
    SELECT MRSL, MRIFREC, MRREADOK
      FROM METERINFO, METERREAD
     WHERE MRMID = MIID
       AND MIPID = P_MPID;*/
  
    --20140512 �ܱ�����޸�
    --�ܱ����=�ӱ���������M��+�ӱ�����³���ˮ����1��
    --׷���շѵ�
    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRREADOK, nvl(MRCARRYSL, 0) MRCARRYSL --У��ˮ��
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
      UNION ALL
      SELECT MRSL, MRIFREC, MRREADOK, nvl(MRCARRYSL, 0) MRCARRYSL
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --���ڻ������ϻ���
         AND RLREVERSEFLAG = 'N';
  
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
      SELECT * FROM METERINFO WHERE MIID = P_MID;
    --�ܱ������ڻ������ϻ��������ץȡ  20140809
    CURSOR C_MI_CLASS(P_MRMID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT nvl(DECODE(NVL(SUM(MRADDSL), 0), 0, SUM(MRSL), SUM(MRADDSL)),
                 0)
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MRMID = P_MRMID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --���ڻ������ϻ���
         AND RLREVERSEFLAG = 'N' --δ����
         and rlsl > 0;
  
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
  
    V_SUMNUM      NUMBER; --�ӱ���
    V_READNUM     NUMBER; --�����ӱ���
    V_RECNUM      NUMBER; --����ӱ���
    V_MICLASS     NUMBER;
    V_MIPID       VARCHAR2(10);
    V_MRMCODE     VARCHAR2(10);
    V_MDHIS_ADDSL METERREADHIS.MRADDSL%TYPE;
    V_PD_ADDSL    METERREADHIS.MRADDSL%TYPE;
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
  
    IF MI.mistatus = '24' AND MR.MRDATASOURCE <> 'M' THEN
      --�����״̬Ϊ���ϻ������Ҵ˳����¼��Դ���ǹ��ϳ�������������ʾ������ѣ��й��ϻ���
      WLOG('��ˮ�������ڹ��ϻ�����,���ܽ������,�������������˹��ϻ����ɾ�����ϻ�����.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']���ڹ��ϻ�����,���ܽ������,�������������˹��ϻ����ɾ�����ϻ�����.');
    END IF;
  
    IF MI.mistatus = '35' AND MR.MRDATASOURCE <> 'L' THEN
      --�����״̬Ϊ���ڻ������Ҵ˳����¼��Դ�������ڳ�������������ʾ������ѣ������ڻ���
      WLOG('��ˮ�����������ڻ�����,���ܽ������,�����������������ڻ����ɾ�����ڻ�����.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']�������ڻ�����,���ܽ������,�����������������ڻ����ɾ�����ڻ�����.');
    END IF;
  
    if MI.mistatus = '36' then
      --Ԥ�������
      WLOG('��ˮ��������Ԥ�������,���ܽ������,��������������Ԥ�������ɾ��Ԥ���������.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']����Ԥ�������,���ܽ������,��������������Ԥ�������ɾ��Ԥ���������.');
    end if;
    
    --byj add 
    if MI.mistatus = '39' then
      --Ԥ�������
      WLOG('��ˮ��������Ԥ�泷���˷���,���ܽ������,�������������˻�ɾ��Ԥ���������.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']����Ԥ�������,���ܽ������,�������������˻�ɾ��Ԥ���������.');
    end if;
    
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L') then
       --ˮ�������Ѿ��ı�
       WLOG('��ˮ���ŵ����������ɳ���ƻ����Ѿ��ı�,���ܽ������,��˲飡' || MR.MRMID);
       RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']��ˮ���ŵ����������ɳ���ƻ����Ѿ��ı�,���ܽ������,��˲飡');
    end if;
    --end!!!
  
    if MI.mistatus = '19' then
      --������
      WLOG('��ˮ��������������,���ܽ������,���������������������ݻ�ɾ����������.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']����������,���ܽ������,��������������������ɾ����������.');
    end if;
  
    -------
    MR.MRRECSL := MR.MRSL; --����ˮ��
    -----------------------------------------------------------------------------
    --�ӱ�ˮ���ּ��Ʒ��ܱ���ˮ��
    -----------------------------------------------------------------------------
    IF �ܱ���� = 'Y' THEN
    
      --######�ֱܷ����   20140412 BY HK#######
      /*
      ����
      1��ͬһ��ᣬ�ֱ�����ѣ����ͬ��ͨ��
      2���ܱ���Ҫ���жϷֱ��Ƿ�����ѣ��ֱ�ȫ����˲������ܱ����
      3���ܱ��ܱ������ѣ��ܱ��� - �ֱ����ͣ�������ܱ����С��0�����ܱ����
      */
      --MICLASS����ͨ��=1���ܱ�=2���ֱ�=3
    
      --STEP1 ����Ƿ��ܱ�
      SELECT MICLASS, MIPID
        INTO V_MICLASS, V_MIPID
        FROM METERINFO
       WHERE MICODE = MR.MRMCODE;
    
      IF V_MICLASS = 2 THEN
        --���ܱ�
        V_MRMCODE := MR.MRMCODE; --��ֵΪ�ܱ��
      
        --STEP2 �ж��ܱ��µķֱ����Ƿ����δ���ӱ� ���ӱ�δ�³���δ��������δ����ӱ�
        SELECT COUNT(*),
               SUM(DECODE(NVL(MRREADOK, 'N'), 'Y', 1, 0)),
               SUM(DECODE(NVL(MRIFREC, 'N'), 'Y', 1, 0))
          INTO V_SUMNUM, V_READNUM, V_RECNUM
          FROM METERINFO, METERREAD
         WHERE MIID = MRMID(+)
           AND MIPID = V_MRMCODE
           AND MICLASS = '3';
        --����ӱ����ʹ����ӱ��ѳ������ͣ������δ���ӱ�
        IF V_SUMNUM > V_READNUM THEN
          WLOG('�����¼' || MR.MRID || '�ֱܷ��а���δ���ӱ���ͣ��������');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '�ֱܷ��а���δ���ӱ���ͣ��������');
        END IF;
      
        --20140512 �ֱܷ�ֱ��ѳ����������
        --����ӱ����ʹ����ӱ���������ͣ������δ����ӱ�
        IF V_SUMNUM > V_RECNUM THEN
          WLOG('�����¼' || MR.MRID || '�շ��ܱ����ӱ�δ�Ʒѣ���ͣ��������');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '�շ��ܱ��ӱ�δ�Ʒѣ���ͣ��������');
        END IF;
        --add modiby  20140809  hb 
        --�ܱ��³������������ϸʱ,ץȡ�����Ƿ��������ϻ����еĻ�ץȡ���ϻ�������
      
        OPEN C_MI_CLASS(V_MRMCODE, MR.MRMONTH);
        FETCH C_MI_CLASS
          INTO V_MDHIS_ADDSL; --���ϻ�������
        IF C_MI_CLASS%NOTFOUND OR C_MI_CLASS%NOTFOUND IS NULL THEN
          V_MDHIS_ADDSL := 0;
        END IF;
        CLOSE C_MI_CLASS;
      
        V_PD_ADDSL := V_MDHIS_ADDSL; --�ж�ˮ��=���ϻ�������
      
        OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
        LOOP
          FETCH C_MR_CHILD
            INTO MRCHILD.MRSL,
                 MRCHILD.MRIFREC,
                 MRCHILD.MRREADOK,
                 MRCHILD.MRCARRYSL;
          EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
          --�жϵ�ˮ�� V_PD_ADDSL ʵ��Ϊ���ϻ���ˮ��
          V_PD_ADDSL := V_PD_ADDSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
          --�ܱ���ϻ���ˮ�� =�ܱ���ϻ���ˮ�� -�ӱ���ˮ�� - �ӱ�У��ˮ�� modiby hb 20140614
        END LOOP;
        CLOSE C_MR_CHILD;
      
        if V_PD_ADDSL < 0 then
          --���������������
          --1�ܱ���ʱ ����-�ֱ��ܳ��� С��0ʱ������   ������
          --2�ܱ���ʱ,����й��ϻ��� �򳭼�ˮ��=����ˮ��+�������� -�ֱ��ܳ���   ����
          --3 �ܱ���ϻ��� ���ֱ���˺�ˮ�������� �ܱ����
          MR.MRRECSL := MR.MRRECSL + V_MDHIS_ADDSL;
          --end add 20140809 
          --STEP3 �ж��ֱܷ��շ��ܱ�ˮ���Ƿ�С���ӱ�ˮ��
          --ȡ�����ӱ�ˮ�������
          OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
          LOOP
            FETCH C_MR_CHILD
              INTO MRCHILD.MRSL,
                   MRCHILD.MRIFREC,
                   MRCHILD.MRREADOK,
                   MRCHILD.MRCARRYSL;
            EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
            --����ˮ��
            MR.MRRECSL := MR.MRRECSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
            --�ܱ�Ӧ��ˮ�� =�ܱ���ˮ�� -�ӱ���ˮ�� - �ӱ�У��ˮ�� modiby hb 20140614
          END LOOP;
          CLOSE C_MR_CHILD;
        
        else
          --4  �ܱ����������ϻ������ϻ����������ڷֱ�����ʱ���ܱ��ٴ�����������ˮ���͵����ܱ���ˮ��
          MR.MRRECSL := MR.MRRECSL;
        end if;
      
        --����շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������
        IF MR.MRRECSL < 0 THEN
          --����ܱ����С��0�����ܱ�ͣ�����
          WLOG('�����¼' || MR.MRID || '�շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '�շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������');
        END IF;
      
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
        IF MRL.mrifrec = 'N' AND MRL.MRIFSUBMIT = 'Y' AND
           MRL.MRIFHALT = 'N' AND MIL.MIIFCHARGE = 'Y' AND
           FCHKMETERNEEDCHARGE(MIL.MISTATUS, MIL.MIIFCHK, '1') = 'Y' THEN
          --�������
          CALCULATE(MRL, PG_EWIDE_METERTRANS_01.�ƻ�����, '0000.00');
        ELSIF MIL.MIIFCHARGE = 'N' OR MRL.MRIFHALT = 'Y' THEN
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
      IF MR.mrifrec = 'N' AND MR.MRIFSUBMIT = 'Y' AND MR.MRIFHALT = 'N' AND
         MI.MIIFCHARGE = 'Y' AND
         FCHKMETERNEEDCHARGE(MI.MISTATUS, MI.MIIFCHK, '1') = 'Y' THEN
        --�������
        CALCULATE(MR, PG_EWIDE_METERTRANS_01.�ƻ�����, '0000.00');
      ELSIF MI.MIIFCHARGE = 'N' OR MR.MRIFHALT = 'Y' THEN
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

  --�ֻ�����Ԥ��� 20150309
  PROCEDURE CALCULATE_YSFH(P_MRID    IN METERREAD.MRID%TYPE,
                           o_rlje    out reclist.rlje%type,
                           o_message out varchar2) IS
    CURSOR C_MR IS
      SELECT *
        FROM METERREAD
       WHERE MRID = P_MRID
            --  AND MRIFREC = 'N'
         AND MRSL >= 0 --20140522 0��ˮ�������
         FOR UPDATE NOWAIT;
  
    --�ֱܷ��ӱ����¼
    /*    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2) IS
    SELECT MRSL, MRIFREC, MRREADOK
      FROM METERINFO, METERREAD
     WHERE MRMID = MIID
       AND MIPID = P_MPID;*/
  
    --20140512 �ܱ�����޸�
    --�ܱ����=�ӱ���������M��+�ӱ�����³���ˮ����1��
    --׷���շѵ�
    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRREADOK, nvl(MRCARRYSL, 0) MRCARRYSL --У��ˮ��
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
      UNION ALL
      SELECT MRSL, MRIFREC, MRREADOK, nvl(MRCARRYSL, 0) MRCARRYSL
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --���ڻ������ϻ���
         AND RLREVERSEFLAG = 'N';
  
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
      SELECT * FROM METERINFO WHERE MIID = P_MID;
    --�ܱ������ڻ������ϻ��������ץȡ  20140809
    CURSOR C_MI_CLASS(P_MRMID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT nvl(DECODE(NVL(SUM(MRADDSL), 0), 0, SUM(MRSL), SUM(MRADDSL)),
                 0)
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MRMID = P_MRMID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --���ڻ������ϻ���
         AND RLREVERSEFLAG = 'N' --δ����
         and rlsl > 0;
  
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
  
    V_SUMNUM      NUMBER; --�ӱ���
    V_READNUM     NUMBER; --�����ӱ���
    V_RECNUM      NUMBER; --����ӱ���
    V_MICLASS     NUMBER;
    V_MIPID       VARCHAR2(10);
    V_MRMCODE     VARCHAR2(10);
    V_MDHIS_ADDSL METERREADHIS.MRADDSL%TYPE;
    V_PD_ADDSL    METERREADHIS.MRADDSL%TYPE;
  BEGIN
  
    OPEN C_MR;
    FETCH C_MR
      INTO MR;
    IF C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL THEN
      -- RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�ĳ���ƻ���ˮ��');
      o_rlje    := 0;
      o_message := '��Ч�ĳ���ƻ���ˮ�Ż��ˮ���Ѿ����';
      return;
    END IF;
  
    --����������Դ  1��ʾ�ƻ�����   5��ʾ�ֳֳ����   9��ʾ�ֻ������
    IF MR.MRSL < ������ˮ�� AND MR.MRDATASOURCE IN ('1', '5', '9', '2') AND
       (MR.MRRPID = '00' OR MR.MRRPID IS NULL) THEN
      o_rlje    := 0;
      o_message := '����ˮ��С��������ˮ��������Ҫ���';
      return;
      /*    RAISE_APPLICATION_ERROR(ERRCODE,
      '����ˮ��С��������ˮ��������Ҫ���');
      */
    END IF;
    --ˮ���¼
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('��Ч��ˮ����' || MR.MRMID);
      --  RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
      o_rlje    := 0;
      o_message := '��Ч��ˮ����' || MR.MRMID;
      return;
    
    END IF;
    CLOSE C_MI;
  
    /*  IF  MI.mistatus='24' AND MR.MRDATASOURCE <> 'M' THEN --�����״̬Ϊ���ϻ������Ҵ˳����¼��Դ���ǹ��ϳ�������������ʾ������ѣ��й��ϻ���
         WLOG('��ˮ�������ڹ��ϻ�����,���ܽ������,�������������˹��ϻ����ɾ�����ϻ�����.' || MR.MRMID);
        -- RAISE_APPLICATION_ERROR(ERRCODE, '��ˮ����['|| MR.MRMID||']���ڹ��ϻ�����,���ܽ������,�������������˹��ϻ����ɾ�����ϻ�����.');
         o_rlje :=0 ;
         o_message := '��ˮ����['|| MR.MRMID||']���ڹ��ϻ�����,���ܽ������,�������������˹��ϻ����ɾ�����ϻ�����.';
        return ;
    END IF ;
     
    IF  MI.mistatus='35' AND MR.MRDATASOURCE <> 'L' THEN --�����״̬Ϊ���ڻ������Ҵ˳����¼��Դ�������ڳ�������������ʾ������ѣ������ڻ���
         WLOG('��ˮ�����������ڻ�����,���ܽ������,�����������������ڻ����ɾ�����ڻ�����.' || MR.MRMID);
        -- RAISE_APPLICATION_ERROR(ERRCODE, '��ˮ����['|| MR.MRMID||']�������ڻ�����,���ܽ������,�����������������ڻ����ɾ�����ڻ�����.');
          o_rlje :=0 ;
         o_message := '��ˮ����['|| MR.MRMID||']�������ڻ�����,���ܽ������,�����������������ڻ����ɾ�����ڻ�����.';
        return ;
     END IF ;
     
     if  MI.mistatus='36'  then  --Ԥ�������
             WLOG('��ˮ��������Ԥ�������,���ܽ������,��������������Ԥ�������ɾ��Ԥ���������.' || MR.MRMID);
        -- RAISE_APPLICATION_ERROR(ERRCODE, '��ˮ����['|| MR.MRMID||']����Ԥ�������,���ܽ������,��������������Ԥ�������ɾ��Ԥ���������.');
          o_rlje :=0 ;
         o_message :=  '��ˮ����['|| MR.MRMID||']����Ԥ�������,���ܽ������,��������������Ԥ�������ɾ��Ԥ���������.';
        return ;
     end if ;
     
     if  MI.mistatus='19'  then  --������
             WLOG('��ˮ��������������,���ܽ������,���������������������ݻ�ɾ����������.' || MR.MRMID);
        --  RAISE_APPLICATION_ERROR(ERRCODE, '��ˮ����['|| MR.MRMID||']����������,���ܽ������,��������������������ɾ����������.');
            o_rlje :=0 ;
         o_message :='��ˮ����['|| MR.MRMID||']����������,���ܽ������,��������������������ɾ����������.';
        return ;
     end if ;*/
  
    -------
    MR.MRRECSL := MR.MRSL; --����ˮ��
    -----------------------------------------------------------------------------
    --�ӱ�ˮ���ּ��Ʒ��ܱ���ˮ��
    -----------------------------------------------------------------------------
    IF �ܱ���� = 'Y' THEN
    
      --######�ֱܷ����   20140412 BY HK#######
      /*
      ����
      1��ͬһ��ᣬ�ֱ�����ѣ����ͬ��ͨ��
      2���ܱ���Ҫ���жϷֱ��Ƿ�����ѣ��ֱ�ȫ����˲������ܱ����
      3���ܱ��ܱ������ѣ��ܱ��� - �ֱ����ͣ�������ܱ����С��0�����ܱ����
      */
      --MICLASS����ͨ��=1���ܱ�=2���ֱ�=3
    
      /*    --STEP1 ����Ƿ��ܱ�
      SELECT MICLASS, MIPID
        INTO V_MICLASS, V_MIPID
        FROM METERINFO
       WHERE MICODE = MR.MRMCODE;--20150328ȡ���ظ�ȡmeterinfo*/
    
      IF mi.MICLASS = 2 THEN
        --���ܱ�
        V_MRMCODE := MR.MRMCODE; --��ֵΪ�ܱ��
      
        --STEP2 �ж��ܱ��µķֱ����Ƿ����δ���ӱ� ���ӱ�δ�³���δ��������δ����ӱ�
        /*      SELECT COUNT(*),
              SUM(DECODE(NVL(MRREADOK, 'N'), 'Y', 1, 0)),
              SUM(DECODE(NVL(MRIFREC, 'N'), 'Y', 1, 0))
         INTO V_SUMNUM, V_READNUM, V_RECNUM
         FROM METERINFO, METERREAD
        WHERE MIID = MRMID(+)
          AND MIPID = V_MRMCODE
          AND MICLASS = '3';*/
        --20150325 ���� ��Ԥ��ѻ�δ���  HB
        SELECT COUNT(*),
               SUM(DECODE(NVL(MRREADOK, 'N'), 'Y', 1, 'X', 1, 0)), --�򳭱��ؼ�¼ΪX
               SUM(DECODE(NVL(MRIFREC, 'N'), 'Y', 1, 0))
          INTO V_SUMNUM, V_READNUM, V_RECNUM
          FROM METERINFO, METERREAD
         WHERE MIID = MRMID(+)
           AND MIPID = V_MRMCODE
           AND MICLASS = '3';
      
        --����ӱ����ʹ����ӱ��ѳ������ͣ������δ���ӱ�
        IF V_SUMNUM > V_READNUM THEN
          WLOG('�����¼' || MR.MRID || '�ֱܷ��а���δ���ӱ���ͣ��������');
          --   RAISE_APPLICATION_ERROR(ERRCODE,  '�ֱܷ��а���δ���ӱ���ͣ��������');
          o_rlje    := 0;
          o_message := '�ֱܷ��а���δ���ӱ���ͣ��������';
          return;
        
        END IF;
      
        -- 20150325 ȡ��
        --20140512 �ֱܷ�ֱ��ѳ����������
        --����ӱ����ʹ����ӱ���������ͣ������δ����ӱ�
        /*        IF V_SUMNUM>V_RECNUM THEN
            WLOG('�����¼' || MR.MRID || '�շ��ܱ����ӱ�δ�Ʒѣ���ͣ��������');
        --   RAISE_APPLICATION_ERROR(ERRCODE,   '�շ��ܱ��ӱ�δ�Ʒѣ���ͣ��������');
             o_rlje :=0 ;
              o_message :='�ֱܷ��а���δ���ӱ���ͣ��������';
             return ;
         
          END IF;*/
        --add modiby  20140809  hb 
        --�ܱ��³������������ϸʱ,ץȡ�����Ƿ��������ϻ����еĻ�ץȡ���ϻ�������
      
        OPEN C_MI_CLASS(V_MRMCODE, MR.MRMONTH);
        FETCH C_MI_CLASS
          INTO V_MDHIS_ADDSL; --���ϻ�������
        IF C_MI_CLASS%NOTFOUND OR C_MI_CLASS%NOTFOUND IS NULL THEN
          V_MDHIS_ADDSL := 0;
        END IF;
        CLOSE C_MI_CLASS;
      
        V_PD_ADDSL := V_MDHIS_ADDSL; --�ж�ˮ��=���ϻ�������
      
        OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
        LOOP
          FETCH C_MR_CHILD
            INTO MRCHILD.MRSL,
                 MRCHILD.MRIFREC,
                 MRCHILD.MRREADOK,
                 MRCHILD.MRCARRYSL;
          EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
          --�жϵ�ˮ�� V_PD_ADDSL ʵ��Ϊ���ϻ���ˮ��
          V_PD_ADDSL := V_PD_ADDSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
          --�ܱ���ϻ���ˮ�� =�ܱ���ϻ���ˮ�� -�ӱ���ˮ�� - �ӱ�У��ˮ�� modiby hb 20140614
        END LOOP;
        CLOSE C_MR_CHILD;
      
        if V_PD_ADDSL < 0 then
          --���������������
          --1�ܱ���ʱ ����-�ֱ��ܳ��� С��0ʱ������   ������
          --2�ܱ���ʱ,����й��ϻ��� �򳭼�ˮ��=����ˮ��+�������� -�ֱ��ܳ���   ����
          --3 �ܱ���ϻ��� ���ֱ���˺�ˮ�������� �ܱ����
          MR.MRRECSL := MR.MRRECSL + V_MDHIS_ADDSL;
          --end add 20140809 
          --STEP3 �ж��ֱܷ��շ��ܱ�ˮ���Ƿ�С���ӱ�ˮ��
          --ȡ�����ӱ�ˮ�������
          OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
          LOOP
            FETCH C_MR_CHILD
              INTO MRCHILD.MRSL,
                   MRCHILD.MRIFREC,
                   MRCHILD.MRREADOK,
                   MRCHILD.MRCARRYSL;
            EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
            --����ˮ��
            MR.MRRECSL := MR.MRRECSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
            --�ܱ�Ӧ��ˮ�� =�ܱ���ˮ�� -�ӱ���ˮ�� - �ӱ�У��ˮ�� modiby hb 20140614
          END LOOP;
          CLOSE C_MR_CHILD;
        
        else
          --4  �ܱ����������ϻ������ϻ����������ڷֱ�����ʱ���ܱ��ٴ�����������ˮ���͵����ܱ���ˮ��
          MR.MRRECSL := MR.MRRECSL;
        end if;
      
        --����շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������
        IF MR.MRRECSL < 0 THEN
          --����ܱ����С��0�����ܱ�ͣ�����
          WLOG('�����¼' || MR.MRID || '�շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������');
          --  RAISE_APPLICATION_ERROR(ERRCODE,  '�շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������');
          o_rlje    := 0;
          o_message := '�շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������';
          return;
        END IF;
      
      END IF;
    END IF;
  
    o_rlje    := 0;
    o_message := 'δִ�����';
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
        /*      IF MRL.mrifrec = 'N' AND MRL.MRIFSUBMIT = 'Y' AND MRL.MRIFHALT = 'N' AND
        MIL.MIIFCHARGE = 'Y' AND
        FCHKMETERNEEDCHARGE(MIL.MISTATUS, MIL.MIIFCHK, '1') = 'Y' THEN*/
        --�������
        CALCULATE_YSFD(MRL,
                       PG_EWIDE_METERTRANS_01.�ƻ�����,
                       '0000.00',
                       o_rlje,
                       o_message);
        /*      ELSIF MIL.MIIFCHARGE = 'N' OR MRL.MRIFHALT = 'Y' THEN
        --�������Ʒ�,�����ݼ�¼�����ÿ�
        CALCULATENP(MRL, PG_EWIDE_METERTRANS_01.�ƻ�����, '0000.00');*/
        /*      END IF;*/
      
      END LOOP;
      MR.MRIFREC   := 'Y';
      MR.MRRECDATE := TRUNC(SYSDATE);
      IF C_MR_PR%ISOPEN THEN
        CLOSE C_MR_PR;
      END IF;
    
    ELSE
      /*    IF MR.mrifrec = 'N' AND MR.MRIFSUBMIT = 'Y' AND MR.MRIFHALT = 'N' AND
      MI.MIIFCHARGE = 'Y' AND
      FCHKMETERNEEDCHARGE(MI.MISTATUS, MI.MIIFCHK, '1') = 'Y' THEN*/
      --�������
      CALCULATE_YSFD(MR,
                     PG_EWIDE_METERTRANS_01.�ƻ�����,
                     '0000.00',
                     o_rlje,
                     o_message);
      /*    ELSIF MI.MIIFCHARGE = 'N' OR MR.MRIFHALT = 'Y' THEN
      --�������Ʒ�,�����ݼ�¼�����ÿ�
      CALCULATENP(MR, PG_EWIDE_METERTRANS_01.�ƻ�����, '0000.00');*/
      /*    END IF;*/
    
    END IF;
    -----------------------------------------------------------------------------
    --���µ�ǰ�����¼ �ֻ���������Ԥ���
    UPDATE METERREAD
       SET MRPLANSL   = MR.MRPLANSL, --Ӧ��ˮ��
           MRPLANJE01 = MR.MRPLANJE01,
           MRPLANJE02 = MR.MRPLANJE02,
           MRPLANJE03 = MR.MRPLANJE03,
           MRYEARJE01 = MR.MRYEARJE01, --ˮ��
           MRYEARJE02 = MR.MRYEARJE02, --��ˮ��
           MRYEARJE03 = MR.MRYEARJE03 --���ӷ�
     WHERE CURRENT OF C_MR;
  
    /*  IF �Ƿ�������� = 'N' THEN
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
    END IF;*/
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
  END CALCULATE_YSFH;

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
  
    CURSOR C_PD(VPFID IN PRICEDETAIL.PDPFID%TYPE) IS
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
  
    PMD         PRICEMULTIDETAIL%ROWTYPE;
    PD          PRICEDETAIL%ROWTYPE;
    temp_pd     PRICEDETAIL%ROWTYPE;
    MD          METERDOC%ROWTYPE;
    MA          METERACCOUNT%ROWTYPE;
    RDTAB       RD_TABLE;
    PALTAB      PAL_TABLE;
    temp_PALTAB PAL_TABLE;
  
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
    V_�����Ч����   NUMBER(10);
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
    V_TEST      VARCHAR2(2000);
  
    CURSOR C_HS_METER(C_MIID VARCHAR2) IS
      SELECT MIID FROM METERINFO WHERE MIPRIID = C_MIID;
  
    V_HS_METER METERINFO%ROWTYPE;
    V_PSUMRLJE RECLIST.RLJE%TYPE;
    V_HS_RLIDS VARCHAR2(1280); --Ӧ����ˮ
    V_HS_RLJE  NUMBER(12, 2); --Ӧ�ս��
    V_HS_ZNJ   NUMBER(12, 2); --���ɽ�
    V_HS_SXF   NUMBER(12, 2); --������
    V_HS_OUTJE NUMBER(12, 2);
  
    --Ԥ���Զ��ֿ�
    v_rlidlist varchar2(4000);
    v_rlid     reclist.rlid%type;
    v_rlje     number(12, 3);
    v_znj      number(12, 3);
    v_rljes    number(12, 3);
    v_znjs     number(12, 3);
    v_countall number;
    CURSOR C_YCDK IS
      select rlid,
             sum(rlje) rlje,
             pg_ewide_pay_01.getznjadj(rlid,
                                       sum(rlje),
                                       rlgroup,
                                       max(rlzndate),
                                       rlsmfid,
                                       trunc(sysdate)) rlznj
        from reclist, meterinfo t
       where rlmid = t.miid
         and rlpaidflag = 'N'
         and rloutflag = 'N'
         and rlreverseflag = 'N'
         and RLBADFLAG = 'N' --add 20151217 ��Ӵ����ʹ�������
         and rlje <> 0
         and rltrans not in ('13', '14', 'u')
         and ((t.mipriid = MI.MIPRIID and MI.MIPRIFLAG = 'Y') or
             (t.miid = MI.MIID and
             (MI.MIPRIFLAG = 'N' or MI.MIPRIID is null)))
       group by rlmcode, t.miid, t.mipriid, rlmonth, rlid, rlgroup, rlsmfid
       order by rlgroup, rlmonth, rlid, mipriid, miid;
  
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
    
    --byj add �ж������Ƿ�ı�!!!
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L') then
       --ˮ�������Ѿ��ı�
       WLOG('��ˮ���ŵ����������ɳ���ƻ����Ѿ��ı�,���ܽ������,��˲飡' || MR.MRMID);
       RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']��ˮ���ŵ����������ɳ���ƻ����Ѿ��ı�,���ܽ������,��˲飡');
    end if;
    --end!!!
    
    DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;
    --�ǼƷѱ�ִ�пչ��̣������쳣
    --�����ӱ�
    if md.ifdzsb = 'Y' THEN
      --����ǵ��� Ҫ�ж�һ��ָ�������
      IF MR.MRECODE > MR.MRSCODE THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���û�' || MI.MICID || '�ǵ����û�,����Ӧ����ֹ��');
      END IF;
    elsif mi.miyl1 <> 'Y' and mi.miyl9 is null then
        if MR.MRECODE < MR.MRSCODE then
           RAISE_APPLICATION_ERROR(ERRCODE,
                                '���û�' || MI.MICID || '���ǵ������롢�������û�,����ӦС��ֹ��');
        end if;
  
    /*ELSE
      if MR.MRECODE < MR.MRSCODE  then
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���û�' || MI.MICID || '���ǵ����û�,����ӦС��ֹ��');
      end if;*/
    END IF;
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
      RL.RLREADSL  := MR.MRRECSL; --reclist����ˮ�� = Mr.����ˮ��+mr У��ˮ��
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
      --ZHW2O160329�޸�---start
      IF P_TRANS = 'OY' THEN
        RL.RLTRANS := 'O';
        RL.RLJTMK  := 'Y';
      ELSIF P_TRANS = 'ON' THEN
        RL.RLTRANS := 'O';
        RL.RLJTMK  := 'N';
      ELSE
        RL.RLTRANS := P_TRANS;
      END IF;
      ---------------------end
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
      IF MI.MIPRIFLAG = 'Y' THEN
        RL.RLPRIMCODE := MI.MIPRIID; --��¼�����ӱ�
      ELSE
        RL.RLPRIMCODE := RL.RLMID;
      END IF;
    
      RL.RLPRIFLAG := MI.MIPRIFLAG;
      IF MR.MRRPER IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���û�' || MI.MICID || '�ĳ���Ա����Ϊ��!');
      END IF;
      RL.RLRPER      := MR.MRRPER;
      RL.RLSAFID     := MR.MRSAFID;
      RL.RLSCODECHAR := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP     := '1'; --Ӧ���ʷ���
    
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
    
      --reclist��������������������������������������������������������������������������������������������������
      --�Ʒѵ���
      --����02 ����ˮ��
      --��ĵ����� ����Ӧ��ˮ������������=��02��03��04��05��06��
      V_��ĵ�����   := 0;
      V_�����ˮ��ֵ := RL.RLREADSL;
      V_�����Ч���� := MR.MRCARRYSL; --Ч������
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
    
      --������ϸ�㷨˵����
      --1�������ڻ�Ϸ��ʼ��������ɷ�����ϸ�����༴�ǻ�Ϸ������ȼ���ߣ�
      --2�����򻧱�����α������ɷ�����ϸ���ݣ�
      --3�������������ɷ�ʽ�£��α�ƥ���Ż����ݣ����������ϸ��
      --��Ҫ�����Ż���Чǰ���ǻ������߱������Ļ�����ʣ������Ż��޵�����Ŀ��
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN
      
        ---########  �൱����ʱˮ�����������������޴�ҵ��  ########---
        temp_PALTAB := NULL;
        PALTAB      := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����',
                  PALTAB);
        if PALTAB is not null then
          temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
          .palcaliber IS NOT NULL THEN
          MI.MIPFID := temp_PALTAB(1).palcaliber;
          --����Ӧ����ˮ��
          rl.rlpfid := MI.MIPFID;
        end if;
        ---########  �൱����ʱˮ�����������������޴�ҵ��  ########---
      
        --����07 ��ˮ��+�۸����
        --��ѵĵ����� �����ۺϵ��ۣ���������=��01 �̶����۵�����
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
          
            ---########  �൱����ʱˮ�����������������޴�ҵ��  ########--- 
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;
            ---########  �൱����ʱˮ�����������������޴�ҵ��  ########---
          
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
                    V_�����Ч����,
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
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
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
                    V_�����Ч����,
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
        
          temp_PALTAB := NULL;
          PALTAB      := NULL;
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    MI.MIPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '��ˮ��+�۸����',
                    PALTAB);
          if PALTAB is not null then
            temp_PALTAB := f_getpfid(PALTAB);
          end if;
          if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
            .palcaliber IS NOT NULL THEN
            PMD.PMDPFID := temp_PALTAB(1).palcaliber;
            --����Ӧ����ˮ��
            rl.rlpfid := PMD.PMDPFID;
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
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
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
                      V_�����Ч����,
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
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
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
                      V_�����Ч����,
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
    
      --   RL.RLREADSL := MR.MRSL; 
      if MI.MICLASS = '2' then
        --�ֱܷ�
        RL.RLREADSL := MR.MRSL + nvl(MR.MRCARRYSL, 0); --���Ϊ���ձ���rl�ĳ���ˮ��Ϊmr����ˮ��+mrУ��ˮ��
      else
        RL.RLREADSL := MR.MRRECSL + nvl(MR.MRCARRYSL, 0); --reclist����ˮ�� = Mr.����ˮ��+mr У��ˮ��
      end if;
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
              IF MI.MIPRIFLAG = 'Y' and MI.MIPRIID IS NOT NULL THEN
                V_PMISAVING := 0;
                --ZHW 20160329--------START
                select count(*)
                  into v_countall
                  from meterread
                 where mrmid <> MR.MRMID
                   and MRIFREC <> 'Y'
                   and mrmid in (SELECT miid
                                   FROM METERINFO
                                  WHERE MIPRIID = MI.MIPRIID);
                IF v_countall < 1 THEN
                  ----------------------------------------end
                  BEGIN
                    SELECT sum(MISAVING)
                      INTO V_PMISAVING
                      FROM METERINFO
                     WHERE MIPRIID = MI.MIPRIID;
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
                end if;
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
          IF MI.MIPRIID IS NOT NULL AND MI.MIPRIFLAG = 'Y' THEN
            --��Ԥ��
            V_PMISAVING := 0;
            --ZHW 20160329--------START
            select count(*)
              into v_countall
              from meterread
             where mrmid <> MR.MRMID
               and MRIFREC <> 'Y'
               and mrmid in
                   (SELECT miid FROM METERINFO WHERE MIPRIID = MI.MIPRIID);
            IF v_countall < 1 THEN
              ----------------------------------------end
              BEGIN
                /*            SELECT MISAVING
                 INTO V_PMISAVING
                 FROM METERINFO
                WHERE MIID = MI.MIPRIID;*/
                SELECT sum(MISAVING)
                  INTO V_PMISAVING
                  FROM METERINFO
                 WHERE MIPRIID = MI.MIPRIID;
              
              EXCEPTION
                WHEN OTHERS THEN
                  V_PMISAVING := 0;
              END;
            
              --��Ƿ��
              V_PSUMRLJE := 0;
              BEGIN
                SELECT SUM(RLJE)
                  INTO V_PSUMRLJE
                  FROM RECLIST
                 WHERE RLPRIMCODE = MI.MIPRIID
                   AND RLBADFLAG = 'N'
                   AND RLREVERSEFLAG = 'N'
                   AND RLPAIDFLAG = 'N';
              EXCEPTION
                WHEN OTHERS THEN
                  V_PSUMRLJE := 0;
              END;
            
              IF V_PMISAVING >= V_PSUMRLJE THEN
                --���ձ�
                V_RLIDLIST := '';
                V_RLJES    := 0;
                V_ZNJ      := 0;
              
                OPEN C_YCDK;
                LOOP
                  FETCH C_YCDK
                    INTO V_RLID, V_RLJE, V_ZNJ;
                  EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
                  --Ԥ�湻��
                  IF V_PMISAVING >= V_RLJE + V_ZNJ THEN
                    V_RLIDLIST  := V_RLIDLIST || V_RLID || ',';
                    V_PMISAVING := V_PMISAVING - (V_RLJE + V_ZNJ);
                    V_RLJES     := V_RLJES + V_RLJE;
                    V_ZNJS      := V_ZNJS + V_ZNJ;
                  ELSE
                    EXIT;
                  END IF;
                END LOOP;
                CLOSE C_YCDK;
              
                IF LENGTH(V_RLIDLIST) > 0 THEN
                  --����PAY_PARA_TMP �������ձ�����׼��
                  DELETE PAY_PARA_TMP;
                
                  OPEN C_HS_METER(MI.MIPRIID);
                  LOOP
                    FETCH C_HS_METER
                      INTO V_HS_METER.MIID;
                    EXIT WHEN C_HS_METER%NOTFOUND OR C_HS_METER%NOTFOUND IS NULL;
                    V_HS_OUTJE := 0;
                    V_HS_RLIDS := '';
                    V_HS_RLJE  := 0;
                    V_HS_ZNJ   := 0;
                    SELECT SUM(DECODE(RLOUTFLAG, 'Y', 1, 0)),
                           REPLACE(CONNSTR(RLID), '/', ',') || '|',
                           SUM(RLJE),
                           SUM(PG_EWIDE_PAY_01.GETZNJADJ(RLID,
                                                         NVL(RLJE, 0),
                                                         RLGROUP,
                                                         RLZNDATE,
                                                         RLSMFID,
                                                         SYSDATE))
                      INTO V_HS_OUTJE, V_HS_RLIDS, V_HS_RLJE, V_HS_ZNJ
                      FROM RECLIST RL
                     WHERE RL.RLMID = V_HS_METER.MIID
                       AND RL.RLJE > 0
                       AND RL.RLPAIDFLAG = 'N'
                          --AND RL.RLOUTFLAG = 'N'
                       AND RL.RLREVERSEFLAG = 'N'
                       AND RL.RLBADFLAG = 'N';
                    IF V_HS_RLJE > 0 THEN
                      INSERT INTO PAY_PARA_TMP
                      VALUES
                        (V_HS_METER.MIID,
                         V_HS_RLIDS,
                         V_HS_RLJE,
                         0,
                         V_HS_ZNJ);
                    END IF;
                  END LOOP;
                  CLOSE C_HS_METER;
                
                  V_RLIDLIST := SUBSTR(V_RLIDLIST,
                                       1,
                                       LENGTH(V_RLIDLIST) - 1);
                  V_RETSTR   := PG_EWIDE_PAY_01.POS('02', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                    MI.MISMFID, --�ɷѻ���
                                                    'system', --�տ�Ա
                                                    V_RLIDLIST || '|', --Ӧ����ˮ��
                                                    NVL(V_RLJES, 0), --Ӧ���ܽ��
                                                    NVL(V_ZNJS, 0), --����ΥԼ��
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
              END IF;
            end if;
          ELSE
            V_RLIDLIST  := '';
            V_RLJES     := 0;
            V_ZNJ       := 0;
            V_PMISAVING := MI.MISAVING;
          
            OPEN C_YCDK;
            LOOP
              FETCH C_YCDK
                INTO V_RLID, V_RLJE, V_ZNJ;
              EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
              --Ԥ�湻��
              IF V_PMISAVING >= V_RLJE + V_ZNJ THEN
                V_RLIDLIST  := V_RLIDLIST || V_RLID || ',';
                V_PMISAVING := V_PMISAVING - (V_RLJE + V_ZNJ);
                V_RLJES     := V_RLJES + V_RLJE;
                V_ZNJS      := V_ZNJS + V_ZNJ;
              ELSE
                EXIT;
              
              END IF;
            
            END LOOP;
            CLOSE C_YCDK;
            --����
            IF LENGTH(V_RLIDLIST) > 0 THEN
              V_RLIDLIST := SUBSTR(V_RLIDLIST, 1, LENGTH(V_RLIDLIST) - 1);
              V_RETSTR   := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                MI.MISMFID, --�ɷѻ���
                                                'system', --�տ�Ա
                                                V_RLIDLIST || '|', --Ӧ����ˮ��
                                                NVL(V_RLJES, 0), --Ӧ���ܽ��
                                                NVL(V_ZNJS, 0), --����ΥԼ��
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
           MIRCODECHAR = MR.MRECODECHAR,
           --zhw-------------------start
           MIYL11      = to_date(rl.rljtsrq, 'yyyy.mm')
           ------------------------------end
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

  -- �ֻ�����Ԥ����ӹ���
  PROCEDURE CALCULATE_YSFD(MR        IN OUT METERREAD%ROWTYPE,
                           P_TRANS   IN CHAR,
                           P_NY      IN VARCHAR2,
                           o_rlje    out reclist.rlje%type,
                           o_message out varchar2) IS
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
  
    CURSOR C_PD(VPFID IN PRICEDETAIL.PDPFID%TYPE) IS
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
  
    PMD         PRICEMULTIDETAIL%ROWTYPE;
    PD          PRICEDETAIL%ROWTYPE;
    temp_pd     PRICEDETAIL%ROWTYPE;
    MD          METERDOC%ROWTYPE;
    MA          METERACCOUNT%ROWTYPE;
    RDTAB       RD_TABLE;
    PALTAB      PAL_TABLE;
    temp_PALTAB PAL_TABLE;
  
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
    V_�����Ч����   NUMBER(10);
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
    V_TEST      VARCHAR2(2000);
  
    CURSOR C_HS_METER(C_MIID VARCHAR2) IS
      SELECT MIID FROM METERINFO WHERE MIPRIID = C_MIID;
  
    V_HS_METER METERINFO%ROWTYPE;
    V_PSUMRLJE RECLIST.RLJE%TYPE;
    V_HS_RLIDS VARCHAR2(1280); --Ӧ����ˮ
    V_HS_RLJE  NUMBER(12, 2); --Ӧ�ս��
    V_HS_ZNJ   NUMBER(12, 2); --���ɽ�
    V_HS_SXF   NUMBER(12, 2); --������
    V_HS_OUTJE NUMBER(12, 2);
  
    --Ԥ���Զ��ֿ�
    v_rlidlist   varchar2(4000);
    v_rlid       reclist.rlid%type;
    v_rlje       number(12, 3);
    v_znj        number(12, 3);
    v_rljes      number(12, 3);
    v_znjs       number(12, 3);
    v_rlje_sf    number(12, 3);
    v_rlje_wsf   number(12, 3);
    v_rlje_fjf   number(12, 3);
    v_rlje_qf    number(12, 3); --����Ԥ�����
    v_rlje_qf1   number(12, 3); --����Ԥ�����
    v_qf_mk      char(1);
    v_qf_mk1     char(1);
    v_rlje_sfdj  number(12, 3);
    v_rlje_wsfdj number(12, 3);
    V_COUNT123   NUMBER;
    v_MRRECSL    number(12, 3);
    v_mrsl       number;
    v_sum_old_qfhes      number(12,4);
      v_misaving           number(12,4);
      V_COUNT1234  number(12,4);
    CURSOR C_YCDK IS
      select rlid,
             sum(rlje) rlje,
             pg_ewide_pay_01.getznjadj(rlid,
                                       sum(rlje),
                                       rlgroup,
                                       max(rlzndate),
                                       rlsmfid,
                                       trunc(sysdate)) rlznj
        from reclist, meterinfo t
       where rlmid = t.miid
         and rlpaidflag = 'N'
         and rloutflag = 'N'
         and rlreverseflag = 'N'
         and rlje <> 0
         and rltrans not in ('13', '14', 'u')
         and ((t.mipriid = MI.MIPRIID and MI.MIPRIFLAG = 'Y') or
             (t.miid = MI.MIID and
             (MI.MIPRIFLAG = 'N' or MI.MIPRIID is null)))
       group by rlmcode, t.miid, t.mipriid, rlmonth, rlid, rlgroup, rlsmfid
       order by rlgroup, rlmonth, rlid, mipriid, miid;
    --20150325 ץȡ
    CURSOR C_old_qf IS
      select sum(rlje) rlje
        from reclist
       where rlpaidflag = 'N'
         and rloutflag = 'N'
         and rlreverseflag = 'N'
         and rlje <> 0
            -- and rltrans not in ('13', '14', 'u')
           
         and RLMID = MI.MIID
         --and rlmid in( SELECT MICODE FROM METERINFO WHERE MIPRIID = mi.MIPRIID )
         /*and mi.MIPRIID in (SELECT MIPRIID FROM METERINFO WHERE MICODE = MR.mrmid)*/;
    v_sum_old_qf reclist.rlje%type;
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
      -- RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
      o_rlje    := 0;
      o_message := '��Ч��ˮ����';
      return;
    END IF;
    --����ˮ����
    OPEN C_MD(MR.MRMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      WLOG('��Ч��ˮ����' || MR.MRMID);
      -- RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
      o_rlje    := 0;
      o_message := '��Ч��ˮ����';
      return;
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
      --  RAISE_APPLICATION_ERROR(ERRCODE, '��Ч���û����' || MI.MICID);
      o_rlje    := 0;
      o_message := '��Ч���û����';
      return;
    
    END IF;
  
    -- DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;   20150309
  
    --�ǼƷѱ�ִ�пչ��̣������쳣
    --�����ӱ�
    IF TRUE THEN
      --reclist����������������������������������������������������������������������������������������������
      if mr.mrdatasource <> '9' THEN
        --Ԥ���ʱ�������ԴΪ9�򲻽���id����
        RL.RLID := FGETSEQUENCE('RECLIST'); -- 20150309
      END IF;
      --zhw 20160415
      select SUM(DECODE(MRREADOK, 'N', 1, 0)), SUM(mrsl) ,count(*)
        INTO V_COUNT123,  v_mrsl ,V_COUNT1234
      
        from meterread
       where mrmid in (select micid
                         from METERINFO
                        where MIPRIID in (select distinct MIPRIID
                                            from METERINFO
                                          where miid = MR.MRMID));
      if V_COUNT1234 > 1 then
        if V_COUNT123 > 0 then
          mr.mrsl := 0;
          mr.MRRECSL := 0 ; 
        else
          mr.mrsl := v_mrsl; --reclist����ˮ�� = Mr.����ˮ��+mr У��ˮ��
          mr.MRRECSL := v_mrsl ; 
        end if;
      end if;
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
      --  RL.RLRTID    := MI.MIRTID;--20150309 ����ʽ����
      RL.RLRTID    := MR.Mrdatasource; --����ʽ
      RL.RLMSTATUS := MI.MISTATUS;
      RL.RLMTYPE   := MI.MITYPE;
      RL.RLMNO     := MD.MDNO;
      RL.RLSCODE   := MR.MRSCODE;
      RL.RLECODE   := MR.MRECODE;
    /*  --zhw 20160415
      select SUM(DECODE(MRREADOK, 'N', 1, 0)), SUM(MRRECSL)
        INTO V_COUNT123, v_MRRECSL
      
        from meterread
       where mrmid in (select micid
                         from METERINFO
                        where MIPRIID in (select distinct MIPRIID
                                            from METERINFO
                                           where miid = MR.MRMID));
      if V_COUNT123 > 0 then
        RL.RLREADSL := 0;
      else
        RL.RLREADSL := v_MRRECSL; --reclist����ˮ�� = Mr.����ˮ��+mr У��ˮ��
      end if;*/
      RL.RLREADSL := MR.MRRECSL; --reclist����ˮ�� = Mr.����ˮ��+mr У��ˮ��
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
      IF MI.MIPRIFLAG = 'Y' THEN
        RL.RLPRIMCODE := MI.MIPRIID; --��¼�����ӱ�
      ELSE
        RL.RLPRIMCODE := RL.RLMID;
      END IF;
    
      RL.RLPRIFLAG   := MI.MIPRIFLAG;
      RL.RLRPER      := MR.MRRPER;
      RL.RLSAFID     := MR.MRSAFID;
      RL.RLSCODECHAR := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP     := '1'; --Ӧ���ʷ���
    
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
    
      --reclist��������������������������������������������������������������������������������������������������
      --�Ʒѵ���
      --����02 ����ˮ��
      --��ĵ����� ����Ӧ��ˮ������������=��02��03��04��05��06��
      V_��ĵ�����   := 0;
      V_�����ˮ��ֵ := RL.RLREADSL;
      V_�����Ч���� := MR.MRCARRYSL; --Ч������
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
    
      --������ϸ�㷨˵����
      --1�������ڻ�Ϸ��ʼ��������ɷ�����ϸ�����༴�ǻ�Ϸ������ȼ���ߣ�
      --2�����򻧱�����α������ɷ�����ϸ���ݣ�
      --3�������������ɷ�ʽ�£��α�ƥ���Ż����ݣ����������ϸ��
      --��Ҫ�����Ż���Чǰ���ǻ������߱������Ļ�����ʣ������Ż��޵�����Ŀ��
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN
      
        ---########  �൱����ʱˮ�����������������޴�ҵ��  ########---
        temp_PALTAB := NULL;
        PALTAB      := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����',
                  PALTAB);
        if PALTAB is not null then
          temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
          .palcaliber IS NOT NULL THEN
          MI.MIPFID := temp_PALTAB(1).palcaliber;
          --����Ӧ����ˮ��
          rl.rlpfid := MI.MIPFID;
        end if;
        ---########  �൱����ʱˮ�����������������޴�ҵ��  ########---
      
        --����07 ��ˮ��+�۸����
        --��ѵĵ����� �����ۺϵ��ۣ���������=��01 �̶����۵�����
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
          
            ---########  �൱����ʱˮ�����������������޴�ҵ��  ########--- 
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;
            ---########  �൱����ʱˮ�����������������޴�ҵ��  ########---
          
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
                    V_�����Ч����,
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
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
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
                    V_�����Ч����,
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
        
          temp_PALTAB := NULL;
          PALTAB      := NULL;
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    MI.MIPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '��ˮ��+�۸����',
                    PALTAB);
          if PALTAB is not null then
            temp_PALTAB := f_getpfid(PALTAB);
          end if;
          if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
            .palcaliber IS NOT NULL THEN
            PMD.PMDPFID := temp_PALTAB(1).palcaliber;
            --����Ӧ����ˮ��
            rl.rlpfid := PMD.PMDPFID;
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
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
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
                      V_�����Ч����,
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
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
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
                      V_�����Ч����,
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
    
      --   RL.RLREADSL := MR.MRSL; 
      if MI.MICLASS = '2' then
        --�ֱܷ�
        RL.RLREADSL := MR.MRSL + nvl(MR.MRCARRYSL, 0); --���Ϊ���ձ���rl�ĳ���ˮ��Ϊmr����ˮ��+mrУ��ˮ��
      else
        RL.RLREADSL := MR.MRRECSL + nvl(MR.MRCARRYSL, 0); --reclist����ˮ�� = Mr.����ˮ��+mr У��ˮ��
      end if;
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
                --20150309ȡ��
                /*             IF �Ƿ�������� = 'N' THEN
                  INSERT INTO RECDETAIL VALUES RDTAB (I);
                ELSE
                  INSERT INTO RECDETAILTEMP VALUES RDTAB (I);
                END IF;*/
              END IF;
            END LOOP;
          
          END LOOP;
        
          CLOSE C_PI;
          IF V_RLFZCOUNT > 0 THEN
            null;
            --20150309ȡ��
            /*          IF �Ƿ�������� = 'N' THEN
              INSERT INTO RECLIST VALUES RL1;
            ELSE
              INSERT INTO RECLISTTEMP VALUES RL1;
            END IF;*/
            --20150309 end ȡ��
            /*          --Ԥ���Զ��ۿ�
            IF FSYSPARA('0006') = 'Y' AND �Ƿ�������� = 'N' THEN
              IF MI.MIPRIFLAG = 'Y' and MI.MIPRIID IS NOT NULL THEN
                V_PMISAVING := 0;
                BEGIN
                  SELECT sum(MISAVING)
                    INTO V_PMISAVING
                    FROM METERINFO
                   WHERE MIPRIID = MI.MIPRIID;
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
      
        v_rlje_sf    := 0; --ˮ��
        v_rlje_wsf   := 0; --��ˮ��
        v_rlje_fjf   := 0; --���ӷ�
        RL.RLJE      := 0;
        v_rlje_sfdj  := 0; --ˮ��
        v_rlje_wsfdj := 0; --��ˮ��
        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          RL.RLJE := RL.RLJE + RDTAB(I).RDJE;
          if RDTAB(I).rdpiid = '01' then
            v_rlje_sf := v_rlje_sf + RDTAB(I).RDJE; --ˮ��
            --zhw20160415�޸�
            if RDTAB(I).RDPSCID <> '-1' then
              v_rlje_sfdj := TOOLS.GETMAX(v_rlje_sfdj, RDTAB(I).rddj);
            end if;
            ----------------------------------------end
          end if;
          if RDTAB(I).rdpiid = '02' then
            v_rlje_wsf := v_rlje_wsf + RDTAB(I).RDJE; --��ˮ��
            --zhw20160415�޸�
            v_rlje_wsfdj := TOOLS.GETMAX(v_rlje_wsfdj, RDTAB(I).rddj);
            ----------------------------------------end
          end if;
          if RDTAB(I).rdpiid = '03' then
            v_rlje_fjf := v_rlje_fjf + RDTAB(I).RDJE; --���ӷ�
          end if;
        END LOOP;
       SELECT  nvl(max(misaving),0)
       into mi.misaving
        FROM METERINFO
       WHERE MICODE IN
             (SELECT MIPRIID FROM METERINFO WHERE MICODE = MR.mrmid)
         AND MISAVING > 0;
         if V_COUNT123 > 0 then
            mi.misaving := 0 ;
           
            /*v_rlje_sfdj := TOOLS.GETMAX(v_rlje_sfdj, RDTAB(I).rddj);
            v_rlje_wsfdj := TOOLS.GETMAX(v_rlje_wsfdj, RDTAB(I).rddj);*/
         end if;
        /*
          --���� ���������  �̶�������ֵ
          if �̶�����־ = 'Y' AND rl.rlje <= �̶�������ֵ THEN
            rl.rlje := round(�̶�������ֵ);
          END IF;
        */
        --add 20150309
        --
        if rl.rlje = 0 then
           select fun_getjtdqdj(MIPFID, MIPRIID, miid, '1') ˮ�ѵ���,
                 fgetwsf(mipfid) ��ˮ�ѵ���
              into v_rlje_sfdj,v_rlje_wsfdj
            from meterinfo
           where miid = MR.mrmid;
         end if;
        o_rlje := rl.rlje;
        /*       if rl.rlje > mi.misaving then
              v_rlje_qf:= rl.rlje - mi.misaving ;
        else
                 v_rlje_qf:=  0;
        end if ;*/
     /* if V_COUNT123 > 0 then
           v_sum_old_qf := 0 ;
      else*/
       
        open C_old_qf;
        fetch C_old_qf
          into v_sum_old_qf;
        if C_old_qf%notfound then
          v_sum_old_qf := 0;
        end if;
        close C_old_qf;
       
      
       
      select nvl(sum(rlje),0) rlje
      into v_sum_old_qfhes
        from reclist
       where rlpaidflag = 'N'
         and rloutflag = 'N'
         and rlreverseflag = 'N'
         and rlje <> 0
          and rlmid in( SELECT MICODE FROM METERINFO WHERE MIPRIID = mi.MIPRIID );
          
           SELECT  nvl(max(misaving),0)
             into v_misaving
              FROM METERINFO
             WHERE MICODE = MR.mrmid;
      /* end if;*/
        if v_sum_old_qf is null then
          v_sum_old_qf := 0;
        end if;
       if V_COUNT123 > 0 then 
          v_sum_old_qfhes := 0 ;
        end if;
        if mr.mrifrec = 'Y' THEN
          --�������ѣ�������Ԥ��������Ԥ�����ץȡ֮ǰ��¼��(���̶���)
          o_rlje     := mr.MRPLANJE01;
          v_rlje_qf  := mr.MRPLANJE02;
          v_rlje_qf1 := mr.MRPLANJE03;
        ELSE
          --add 20150325 ����Ԥ�����=ˮ��Ԥ����� -  ��ʷǷ��
          --v_rlje_qf := mi.misaving - v_sum_old_qf;
          v_rlje_qf := v_misaving  - v_sum_old_qf;
          --add 20150325 ����Ԥ�����=ˮ��Ԥ����� -  ��ʷǷ�� -����Ӧ�պϼ�
         -- v_rlje_qf1 := mi.misaving - v_sum_old_qf - rl.rlje;
          v_rlje_qf1 := mi.misaving - v_sum_old_qfhes - rl.rlje;
          --Ӧ��ˮ��|Ӧ��ˮ��|Ӧ����ˮ��|Ӧ����������|Ӧ�պϼ�|����Ԥ�����|����Ԥ�����
        END IF;
        mr.MRPLANSL   := rl.rlsl; --Ӧ��ˮ��
        mr.MRPLANJE01 := o_rlje; --Ӧ�պϼ�
        mr.MRPLANJE02 := v_rlje_qf; --(�ֻ������������Ԥ��)
        mr.MRPLANJE03 := v_rlje_qf1; --(�ֻ�������ѱ���Ԥ��)
        mr.MRYEARJE01 := v_rlje_sf; --ˮ��
        mr.MRYEARJE02 := v_rlje_wsf; --��ˮ��
        mr.MRYEARJE03 := v_rlje_fjf; --���ӷ�
      
        if v_rlje_qf >= 0 then
          v_qf_mk := '+';
        else
          v_qf_mk := '-';
        end if;
        if v_rlje_qf1 >= 0 then
          v_qf_mk1 := '+';
        else
          v_qf_mk1 := '-';
        end if;
        ---zhw 20160415�޸�����ˮ�Ѻ���ˮ�Ѽ۸�
        o_message := trim(to_char(rl.rlsl * 100, '0000000000')) || '|' ||
                     trim(to_char(v_rlje_sf * 100, '0000000000')) || '|' ||
                     trim(to_char(v_rlje_wsf * 100, '0000000000')) || '|' ||
                     trim(to_char(v_rlje_fjf * 100, '0000000000')) || '|' ||
                     trim(to_char(o_rlje * 100, '0000000000')) || '|' ||
                     v_qf_mk ||
                     trim(to_char(abs(v_rlje_qf) * 100, '0000000000')) || '|' ||
                     v_qf_mk1 ||
                     trim(to_char(abs(v_rlje_qf1) * 100, '0000000000')) || '|' ||
                     '+' ||
                     trim(to_char(abs(v_rlje_sfdj) * 100, '0000000000')) || '|' ||
                     '+' ||
                     trim(to_char(abs(v_rlje_wsfdj) * 100, '0000000000'));
        -----------------------------------------------------end
      
        --20150309  ȡ�� 
        /*      IF �Ƿ�������� = 'N' THEN
            INSERT INTO RECLIST VALUES RL;
          ELSE
            INSERT INTO RECLISTTEMP VALUES RL;
          END IF;
        INSRD(RDTAB); */ --20150309  ȡ��
      
        /*      --Ԥ���Զ��ۿ�  --20150309 Ԥ��ȡ��
              IF FSYSPARA('0006') = 'Y' AND �Ƿ�������� = 'N' THEN
                IF MI.MIPRIID IS NOT NULL AND MI.MIPRIFLAG = 'Y' THEN
                  --��Ԥ��
                  V_PMISAVING := 0;
                  BEGIN
        \*            SELECT MISAVING
                      INTO V_PMISAVING
                      FROM METERINFO
                     WHERE MIID = MI.MIPRIID;*\
                      SELECT sum(MISAVING)
                          INTO V_PMISAVING
                          FROM METERINFO
                         WHERE MIPRIID = MI.MIPRIID;
                         
                  EXCEPTION
                    WHEN OTHERS THEN
                      V_PMISAVING := 0;
                  END;
                
                  --��Ƿ��
                  V_PSUMRLJE := 0;
                  BEGIN
                    SELECT SUM(RLJE)
                      INTO V_PSUMRLJE
                      FROM RECLIST
                     WHERE RLPRIMCODE = MI.MIPRIID
                       AND RLBADFLAG = 'N'
                       AND RLREVERSEFLAG = 'N'
                       AND RLPAIDFLAG = 'N';
                  EXCEPTION
                    WHEN OTHERS THEN
                      V_PSUMRLJE := 0;
                  END;
                
                  IF V_PMISAVING >= V_PSUMRLJE THEN
                    --���ձ�
                    V_RLIDLIST := '';
                    V_RLJES    := 0;
                    V_ZNJ      := 0;
                  
                    OPEN C_YCDK;
                    LOOP
                      FETCH C_YCDK
                        INTO V_RLID, V_RLJE, V_ZNJ;
                      EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
                      --Ԥ�湻��
                      IF V_PMISAVING >= V_RLJE + V_ZNJ THEN
                        V_RLIDLIST  := V_RLIDLIST || V_RLID || ',';
                        V_PMISAVING := V_PMISAVING - (V_RLJE + V_ZNJ);
                        V_RLJES     := V_RLJES + V_RLJE;
                        V_ZNJS      := V_ZNJS + V_ZNJ;
                      ELSE
                        EXIT;
                      END IF;
                    END LOOP;
                    CLOSE C_YCDK;
                  
                    IF LENGTH(V_RLIDLIST) > 0 THEN
                      --����PAY_PARA_TMP �������ձ�����׼��
                      DELETE PAY_PARA_TMP;
                    
                      OPEN C_HS_METER(MI.MIPRIID);
                      LOOP
                        FETCH C_HS_METER
                          INTO V_HS_METER.MIID;
                        EXIT WHEN C_HS_METER%NOTFOUND OR C_HS_METER%NOTFOUND IS NULL;
                        V_HS_OUTJE := 0;
                        V_HS_RLIDS := '';
                        V_HS_RLJE  := 0;
                        V_HS_ZNJ   := 0;
                        SELECT SUM(DECODE(RLOUTFLAG, 'Y', 1, 0)),
                               REPLACE(CONNSTR(RLID), '/', ',') || '|',
                               SUM(RLJE),
                               SUM(PG_EWIDE_PAY_01.GETZNJADJ(RLID,
                                                             NVL(RLJE, 0),
                                                             RLGROUP,
                                                             RLZNDATE,
                                                             RLSMFID,
                                                             SYSDATE))
                          INTO V_HS_OUTJE, V_HS_RLIDS, V_HS_RLJE, V_HS_ZNJ
                          FROM RECLIST RL
                         WHERE RL.RLMID = V_HS_METER.MIID
                           AND RL.RLJE > 0
                           AND RL.RLPAIDFLAG = 'N'
                              --AND RL.RLOUTFLAG = 'N'
                           AND RL.RLREVERSEFLAG = 'N'
                           AND RL.RLBADFLAG = 'N';
                        IF V_HS_RLJE > 0 THEN
                          INSERT INTO PAY_PARA_TMP
                          VALUES
                            (V_HS_METER.MIID, V_HS_RLIDS, V_HS_RLJE, 0, V_HS_ZNJ);
                        END IF;
                      END LOOP;
                      CLOSE C_HS_METER;
                    
                      V_RLIDLIST := SUBSTR(V_RLIDLIST, 1, LENGTH(V_RLIDLIST) - 1);
                      V_RETSTR   := PG_EWIDE_PAY_01.POS('02', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                        MI.MISMFID, --�ɷѻ���
                                                        'system', --�տ�Ա
                                                        V_RLIDLIST || '|', --Ӧ����ˮ��
                                                        NVL(V_RLJES, 0), --Ӧ���ܽ��
                                                        NVL(V_ZNJS, 0), --����ΥԼ��
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
                  END IF;
                ELSE
                  V_RLIDLIST  := '';
                  V_RLJES     := 0;
                  V_ZNJ       := 0;
                  V_PMISAVING := MI.MISAVING;
                
                  OPEN C_YCDK;
                  LOOP
                    FETCH C_YCDK
                      INTO V_RLID, V_RLJE, V_ZNJ;
                    EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
                    --Ԥ�湻��
                    IF V_PMISAVING >= V_RLJE + V_ZNJ THEN
                      V_RLIDLIST  := V_RLIDLIST || V_RLID || ',';
                      V_PMISAVING := V_PMISAVING - (V_RLJE + V_ZNJ);
                      V_RLJES     := V_RLJES + V_RLJE;
                      V_ZNJS      := V_ZNJS + V_ZNJ;
                    ELSE
                      EXIT;
                    
                    END IF;
                  
                  END LOOP;
                  CLOSE C_YCDK;
                  --����
                  IF LENGTH(V_RLIDLIST) > 0 THEN
                    V_RLIDLIST := SUBSTR(V_RLIDLIST, 1, LENGTH(V_RLIDLIST) - 1);
                    V_RETSTR   := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                      MI.MISMFID, --�ɷѻ���
                                                      'system', --�տ�Ա
                                                      V_RLIDLIST || '|', --Ӧ����ˮ��
                                                      NVL(V_RLJES, 0), --Ӧ���ܽ��
                                                      NVL(V_ZNJS, 0), --����ΥԼ��
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
              
              END IF;*/
      
      END IF;
    
    END IF;
  
    --add 2013.01.16      ��reclist_charge_01���в�������
    --SP_RECLIST_CHARGE_01(RL.RLID, '1'); 20150309ȡ��
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
  
    --����20150309ȡ��
    /*  UPDATE METERINFO
         SET MIRCODE     = MR.MRECODE,
             MIRECDATE   = MR.MRRDATE,
             MIRECSL     = MR.MRSL, --ȡ����ˮ����������
             MIFACE      = MR.MRFACE,
             MINEWFLAG   = 'N',
             MIRCODECHAR = MR.MRECODECHAR
       WHERE CURRENT OF C_MI;
    */
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
  
    CURSOR C_PD(VPFID IN PRICEDETAIL.PDPFID%TYPE) IS
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
  
    PMD     PRICEMULTIDETAIL%ROWTYPE;
    PD      PRICEDETAIL%ROWTYPE;
    temp_pd PRICEDETAIL%ROWTYPE;
    MD      METERDOC%ROWTYPE;
    MA      METERACCOUNT%ROWTYPE;
    RDTAB   RD_TABLE;
    --VRD    RECDETAILNP%ROWTYPE;
    PALTAB      PAL_TABLE;
    temp_PALTAB PAL_TABLE;
  
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
    V_�����Ч����   NUMBER(10);
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
    V_TEST      VARCHAR2(2000);
  
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
      RL.RLREADSL  := MR.MRRECSL;
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
      V_�����Ч���� := MR.MRCARRYSL; --Ч������
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
      
        temp_PALTAB := NULL;
        PALTAB      := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����',
                  PALTAB);
        if PALTAB is not null then
          temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
          .palcaliber IS NOT NULL THEN
          MI.MIPFID := temp_PALTAB(1).palcaliber;
          --����Ӧ����ˮ��
          rl.rlpfid := MI.MIPFID;
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
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
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
                    V_�����Ч����,
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
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
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
                    V_�����Ч����, --Ч������
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
        
          temp_PALTAB := NULL;
          PALTAB      := NULL;
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    MI.MIPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '��ˮ��+�۸����',
                    PALTAB);
          if PALTAB is not null then
            temp_PALTAB := f_getpfid(PALTAB);
          end if;
          if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
            .palcaliber IS NOT NULL THEN
            PMD.PMDPFID := temp_PALTAB(1).palcaliber;
            --����Ӧ����ˮ��
            rl.rlpfid := PMD.PMDPFID;
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
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
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
                      V_�����Ч����,
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
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
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
                      V_�����Ч����,
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
      -- RL.RLREADSL := MR.MRSL;
      if MI.MICLASS = '2' then
        --���ձ�
        RL.RLREADSL := MR.MRSL + nvl(MR.MRCARRYSL, 0); --���Ϊ���ձ���rl�ĳ���ˮ��Ϊmr����ˮ��+mrУ��ˮ��
      else
        RL.RLREADSL := MR.MRRECSL + nvl(MR.MRCARRYSL, 0); --reclist����ˮ�� = Mr.����ˮ��+mr У��ˮ��
      end if;
    
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
          VRD := RDTAB(I);
        
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
         and ((PALDATETYPE is null or PALDATETYPE = '0') or
             (PALDATETYPE = '1' and
             instr(PALMONTHSTR, substr(P_MONTH, 6)) > 0) or
             (PALDATETYPE = '2' and instr(PALMONTHSTR, P_MONTH) > 0))
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
      if PALTAB(I).PALTACTIC in ('02', '07', '09') then
      
        --�̶����۵���
        IF PALTAB(I).PALMETHOD = '01' THEN
          null; --ˮ���ޱ仯
        end if;
      
        --�̶�������
        IF PALTAB(I).PALMETHOD = '02' THEN
        
          /*20131206 ȷ�ϣ������޸ĵ�����Ч��֮ǰ���·ݲ��ۼƼƷѵ���*/
          NMONTH := 1; --�Ʒ�ʱ������
          /* BEGIN
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
          END IF;*/
        
          --����Ϊ1 ����Ϊ-1
          IF PALTAB(I).PALWAY = 0 then
            P_����ˮ��ֵ := PALTAB(I).PALVALUE;
          else
            IF P_����ˮ��ֵ + PALTAB(I).PALVALUE * PALTAB(I).PALWAY * NMONTH >= 0 THEN
              IF P_�������ۼ������ = 'Y' THEN
                P_����ˮ��ֵ := P_����ˮ��ֵ + PALTAB(I)
                          .PALVALUE * PALTAB(I).PALWAY * NMONTH;
              END IF;
              P_������ := P_������ + PALTAB(I)
                      .PALVALUE * PALTAB(I).PALWAY * NMONTH;
            ELSE
              P_������ := P_������ - P_����ˮ��ֵ;
              IF P_�������ۼ������ = 'Y' THEN
                P_����ˮ��ֵ := 0;
              END IF;
            end if;
          
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
            if P_RL.RLRTID <> '9' then
              --�ֻ�����Ԥ��Ѳ�д���� 20150309
              UPDATE PRICEADJUSTLIST
                 SET PALVALUE = 0
               WHERE PALID = PALTAB(I).PALID;
            end if;
          ELSE
            --�����ۼ���
            if P_RL.RLRTID <> '9' then
              --�ֻ�����Ԥ��Ѳ�д���� 20150309
              UPDATE PRICEADJUSTLIST
                 SET PALVALUE = PALVALUE - P_����ˮ��ֵ
               WHERE PALID = PALTAB(I).PALID;
            end if;
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
  function f_GETpfid(PALTAB IN PAL_TABLE) return PAL_TABLE AS
    paj PAL_TABLE;
  
  BEGIN
    FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
      if PALTAB(I).PALTACTIC = '07' and PALTAB(I).palmethod in ('01', '07') then
        return PALTAB;
      end if;
      return paj;
    END LOOP;
    return paj;
  END;

  --����ˮ��+������Ŀ����   BY WY 20130531   
  function f_GETpfid_piid(PALTAB IN PAL_TABLE, p_piid in varchar2)
    return PAL_TABLE AS
    paj PAL_TABLE;
  
  BEGIN
    FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
      if PALTAB(I).PALTACTIC = '09' and PALTAB(I).palmethod = '01' and PALTAB(I)
         .palpiid = p_piid then
        return PALTAB;
      end if;
      return paj;
    END LOOP;
    return paj;
  END;

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
                    p_�����Ч����   IN NUMBER,
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
  
    RD.RDID       := P_RL.RLID; --��ˮ�� 
    RD.RDPMDID    := P_PMDID; --�����ˮ���� 
    RD.RDPMDSCALE := P_PMDSCALE; --��ϱ���  
    RD.RDPIID     := PD.PDPIID; --������Ŀ  
    RD.RDPFID     := PD.PDPFID; --����  
    RD.RDPSCID    := PD.PDPSCID; --������ϸ����  
    RD.RDYSDJ     := 0; --Ӧ�յ��� 
    RD.RDYSSL     := 0; --Ӧ��ˮ�� 
    RD.RDYSJE     := 0; --Ӧ�ս�� 
  
    RD.RDADJDJ    := 0; --�������� 
    RD.RDADJSL    := 0; --����ˮ�� 
    RD.RDADJJE    := 0; --������� 
    RD.RDMETHOD   := PD.PDMETHOD; --�Ʒѷ��� 
    RD.RDPAIDFLAG := 'N'; --���ʱ�־ 
  
    RD.RDMSMFID     := P_RL.RLMSMFID; --Ӫ����˾
    RD.RDMONTH      := P_RL.RLMONTH; --�����·�
    RD.RDMID        := P_RL.RLMID; --ˮ����
    RD.RDPMDTYPE    := NVL(PMD.PMDTYPE, '01'); --������
    RD.RDPMDCOLUMN1 := PMD.PMDCOLUMN1; --�����ֶ�1
    RD.RDPMDCOLUMN2 := PMD.PMDCOLUMN2; --�����ֶ�2
    RD.RDPMDCOLUMN3 := PMD.PMDCOLUMN3; --�����ֶ�3
  
    /*    --yujia  2012-03-20
    �̶�����־   := FPARA(P_RL.RLMSMFID, 'GDJEFLAG');
    �̶�������ֵ := FPARA(P_RL.RLMSMFID, 'GDJEZ');*/
  
    CASE PD.PDMETHOD
      WHEN 'dj1' THEN
        --�̶�����  Ĭ�Ϸ�ʽ���볭���й�  ����������dj1
        BEGIN
          RD.RDCLASS := 0; --���ݼ��� 
          RD.RDYSDJ  := PD.PDDJ; --Ӧ�յ��� 
          RD.RDYSSL  := P_SL + p_�����Ч���� - P_��ϱ������; --Ӧ��ˮ�� 
        
          RD.RDADJDJ := FGET��������(RD.RDMID, RD.RDPIID); --�������� 
          RD.RDADJSL := P_��ĵ����� + P_��ѵĵ����� + P_�����Ŀ������ + P_��ϱ������; --����ˮ�� 
          RD.RDADJJE := 0; --������� 
        
          RD.RDDJ := PD.PDDJ + RD.RDADJDJ; --ʵ�յ��� 
          RD.RDSL := P_SL + RD.RDADJSL - P_��ϱ������; --ʵ��ˮ�� 
        
          --�������
          RD.RDYSJE := ROUND(RD.RDYSDJ * RD.RDYSSL, 2); --Ӧ�ս�� 
          RD.RDJE   := ROUND(RD.RDDJ * RD.RDSL, 2); --ʵ�ս�� 
        
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
          --  RD.RDADJSL := 0;
          -- modify by hb 20140703 ��ϸ����ˮ������reclist����ˮ��
          RD.RDADJSL := P_RL.Rladdsl;
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

  /*  --���ݼƷѲ���
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
        \*
        ��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
        ���人ˮ����ݹ��򣨻�/�˾���ˮ����ͬһ��ַ������ˮ����ˮ��֮��Ϊ�������㣩                      ��
        ��1����ͥ�����˿���4�����£���4�ˣ�����ˮ����������ˮ�����ֽ���ʽ����ˮ�ۡ�                      ��
        ��2����ͥ�����˿���5�ˣ���5�ˣ����ϵ���ˮ�������˾���ˮ�����ֽ���ʽ����ˮ�ۡ�                    ��
        ���������������������Щ����������������������������������������������Щ����������������������������������������������������������������������Щ���������������������������������������������������
        ���������� ������ˮ���� 25������     ��25�����ף�����ˮ����33������        ������ˮ���� 33������      ��
        �����˼��� ���˾���ˮ���� 6.25������ ��6.25�����ף��˾���ˮ���� 8.25������ ���˾���ˮ���� 8.25������  ��
        ��ˮ��     ��1.1                    ��1.65                               ��2.2                      ��
        ���������������������ة����������������������������������������������ة����������������������������������������������������������������������ة���������������������������������������������������
        *\ --һ��ֹ������Ҫ������ֵ��ͬ����������
        \*if nvl(p_rl.rlusenum, 0) >= 5 then
          if ps.psclass = 1 then
            ps.psecode := 6.25 * p_rl.rlusenum;
          elsif ps.psclass = 2 then
            ps.psscode := 6.25 * p_rl.rlusenum;
            ps.psecode := 8.25 * p_rl.rlusenum;
          else
            ps.psscode := 8.25 * p_rl.rlusenum;
          end if;
        end if;*\
  
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
        \*
        ��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
        ���人ˮ����ݹ��򣨻�/�˾���ˮ����ͬһ��ַ������ˮ����ˮ��֮��Ϊ�������㣩                      ��
        ��1����ͥ�����˿���4�����£���4�ˣ�����ˮ����������ˮ�����ֽ���ʽ����ˮ�ۡ�                      ��
        ��2����ͥ�����˿���5�ˣ���5�ˣ����ϵ���ˮ�������˾���ˮ�����ֽ���ʽ����ˮ�ۡ�                    ��
        ���������������������Щ����������������������������������������������Щ����������������������������������������������������������������������Щ���������������������������������������������������
        ���������� ������ˮ���� 25������     ��25�����ף�����ˮ����33������        ������ˮ���� 33������      ��
        �����˼��� ���˾���ˮ���� 6.25������ ��6.25�����ף��˾���ˮ���� 8.25������ ���˾���ˮ���� 8.25������  ��
        ��ˮ��     ��1.1                    ��1.65                               ��2.2                      ��
        ���������������������ة����������������������������������������������ة����������������������������������������������������������������������ة���������������������������������������������������
        *\ --һ��ֹ������Ҫ������ֵ��ͬ����������
        \*if nvl(p_rl.rlusenum, 0) >= 5 then
          if ps.psclass = 1 then
            ps.psecode := 6.25 * p_rl.rlusenum;
          elsif ps.psclass = 2 then
            ps.psscode := 6.25 * p_rl.rlusenum;
            ps.psecode := 8.25 * p_rl.rlusenum;
          else
            ps.psscode := 8.25 * p_rl.rlusenum;
          end if;
        end if;*\
  
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
  END;*/
  PROCEDURE CalStep(P_RL       IN OUT RECLIST%ROWTYPE,
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
        FROM PRICESTEP_VER
       WHERE PSPFID = PD.PDPFID
         AND PSPIID = PD.PDPIID
         AND VERID = PMONTH
       ORDER BY PSCLASS;
  
    TMPYSSL        NUMBER;
    TMPSL          NUMBER;
    RD             RECDETAIL%ROWTYPE;
    PS             PRICESTEP%ROWTYPE;
    N              NUMBER; --�Ʒ�����
    ���ۼ�ˮ��     NUMBER;
    MINFO          METERINFO%ROWTYPE;
    USENUM         NUMBER; --�Ʒ��˿���
    v_bfid         meterinfo.mibfid%type;
    V_DATE         date;
    V_DATEOLD      DATE;
    V_DATEjtq      date;
    v_monbet       number;
    v_yyyymm       varchar2(10);
    v_rljtmk       varchar2(1);
    bk             BOOKFRAME%rowtype;
    v_RLSCRRLMONTH reclist.rlmonth%type;
    v_rlmonth      reclist.rlmonth%type;
    v_RLJTSRQ      reclist.rljtsrq%type;
    v_RLJTSRQold   reclist.rljtsrq%type;
    v_jgyf         number;
    v_jtny         number;
    v_newmk        CHAR(1);
    V_jtqzny       reclist.rljtsrq%type;
    v_betweenny    number;
  
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
  
    TMPYSSL := P_SL; --�����ۼ�Ӧ��ˮ�����
    TMPSL   := P_SL; --�����ۼ�ʵ��ˮ�����
    v_newmk := 'N';
    --ȡ�ϴ�����·ݣ��Լ����ݿ�ʼ�·�
   select nvl(max(RLSCRRLMONTH), 'a'), nvl(max(RLJTSRQ), 'a'),nvl(max(rlmonth),'2015.12')
      into v_RLSCRRLMONTH, v_RLJTSRQold,v_rlmonth
      from reclist
     where rlmid = P_RL.rlmid
       and rlreverseflag = 'N';
    --��һ����ѱȽ������
  
    SELECT * INTO bk FROM BOOKFRAME WHERE BFID = P_RL.RLBFID;
    --�ж������Ƿ�������ȡ���ݵ�����
    SELECT MI.* INTO MINFO FROM METERINFO MI WHERE MI.miid = P_RL.rlmid;
    --�ж��˿�
    /*  USENUM := NVL(MINFO.MIUSENUM, 0);*/
    --ȡ���ձ��˿�������û���
    select nvl(max(MIUSENUM),0)
      into USENUM
      from meterinfo
     where mipriid = MINFO.Mipriid;
    IF USENUM <= 5 THEN
      USENUM := 5;
    END IF;
    bk.bfjtsny := nvl(bk.bfjtsny, '01');
    bk.bfjtsny := TO_CHAR(TO_NUMBER(bk.bfjtsny), 'FM00');
    if substr(P_RL.Rlmonth, 6, 2) >= bk.bfjtsny then
      v_RLJTSRQ := substr(P_RL.Rlmonth, 1, 4) || '.' || bk.bfjtsny;
    else
      v_RLJTSRQ := substr(P_RL.Rlmonth, 1, 4) - 1 || '.' || bk.bfjtsny;
    end if;
    --�½�����ֹ
    V_DATE := ADD_MONTHS(to_date(v_RLJTSRQ, 'yyyy.mm'), 12);
    if v_RLJTSRQold <> 'a' then
      --�ɽ�����ֹ
      V_DATEOLD := ADD_MONTHS(to_date(v_RLJTSRQold, 'yyyy.mm'), 12);
    else
      V_DATEOLD := V_DATE;
    end if;
    --else
    V_DATEjtq := V_DATEOLD;
    --end if;
    --�ɽ�����ֹ�������½�����ֹ
    if V_DATEOLD <> V_DATE then
    
      v_betweenny := MONTHS_BETWEEN(V_DATE, V_DATEOLD);
      if substr(v_RLJTSRQ, 1, 4) <> to_char(V_DATEOLD, 'yyyy') then
        IF v_RLJTSRQ < to_char(V_DATEOLD, 'yyyy.MM') THEN
          IF v_RLJTSRQ = P_RL.RLMONTH THEN
            P_RL.RLJTMK  := 'Y';
            P_RL.Rljtsrq := v_RLJTSRQ;
          ELSE
            P_RL.Rljtsrq := v_RLJTSRQold;
            V_jtqzny     := v_RLJTSRQold;
          END IF;
        ELSE
          P_RL.RLJTMK  := 'Y';
          P_RL.Rljtsrq := v_RLJTSRQ;
        END IF;
      
      else
      
        if mod(v_betweenny, 12) = 0 then
          --��������
          if v_betweenny / 12 > 1 then
            P_RL.RLJTMK  := 'Y';
            P_RL.Rljtsrq := v_RLJTSRQ;
          else
          
            P_RL.Rljtsrq := v_RLJTSRQ;
            V_jtqzny     := v_RLJTSRQold;
          end if;
        elsif v_betweenny < 12 then
          if P_RL.Rlmonth = v_RLJTSRQ then
            P_RL.Rljtsrq := v_RLJTSRQ;
            V_jtqzny     := v_RLJTSRQold;
          elsif P_RL.Rlmonth < v_RLJTSRQ then
            P_RL.Rljtsrq := v_RLJTSRQold;
            V_jtqzny     := v_RLJTSRQold;
          else
            P_RL.Rljtsrq := v_RLJTSRQ;
            V_jtqzny     := v_RLJTSRQold;
          end if;
          V_DATEjtq := to_date(v_RLJTSRQ, 'yyyy.mm');
        elsif v_betweenny > 12 then
          if P_RL.Rlmonth = v_RLJTSRQ then
            if substr(P_RL.Rlmonth, 1, 4) = substr(v_RLSCRRLMONTH, 1, 4) then
              --if substr(P_RL.Rlmonth, 1, 4) = substr(v_RLJTSRQold, 1, 4) then
              P_RL.Rljtsrq := v_RLJTSRQ;
              P_RL.RLJTMK  := 'Y';
            else
              P_RL.Rljtsrq := v_RLJTSRQ;
              v_newmk      := 'Y';
              V_jtqzny     := v_RLJTSRQold;
            end if;
          else
            if P_RL.Rlmonth = v_RLJTSRQold then
              P_RL.Rljtsrq := to_char(V_DATEOLD, 'yyyy.mm');
              V_jtqzny     := v_RLJTSRQold;
            else
              P_RL.Rljtsrq := v_RLJTSRQold;
              V_jtqzny     := v_RLJTSRQold;
            end if;
          end if;
        end if;
      
        /*elsif v_betweenny > 12 then
        if P_RL.Rlmonth = to_char(V_DATE , 'yyyy.mm') then
           if substr(P_RL.Rlmonth,1,4) = 
        else
        end if;*/
        /*end if;
        end if;*/
      end if;
      --P_RL.Rljtsrq := v_RLJTSRQ;
    else
      if P_RL.Rlmonth = v_RLJTSRQ then
        V_jtqzny := substr(P_RL.Rlmonth, 1, 4) - 1 || '.' || bk.bfjtsny;
      else
        V_jtqzny := v_RLJTSRQ;
      end if;
      P_RL.Rljtsrq := v_RLJTSRQ;
    
    end if;
    /* if v_RLJTSRQ > v_RLJTSRQold then
      if P_RL.Rlmonth = v_RLJTSRQ then
        P_RL.Rljtsrq := v_RLJTSRQ;
      
      else
        if P_RL.Rlmonth < to_char(V_DATE, 'yyyy.mm') then
          P_RL.RLJTMK := 'Y';
        else
          v_newmk := 'Y';
        end if;
        --V_jtqzny := v_RLJTSRQ;
      end if;
      V_jtqzny     := v_RLJTSRQold;
      P_RL.Rljtsrq := v_RLJTSRQ;
    else
      P_RL.Rljtsrq := v_RLJTSRQ;
      V_jtqzny     := v_RLJTSRQ;
    end if;*/
    --ȡ����
    SELECT nvl(MONTHS_BETWEEN(V_DATE, TRUNC(MAX(CCHSHDATE), 'MM')), 99) + 1,
           to_char(TRUNC(MAX(CCHSHDATE), 'MM'), 'yyyy.mm')
      into v_monbet, v_yyyymm
      FROM CUSTCHANGEHD, CUSTCHANGEDTHIS, CUSTCHANGEDT
     WHERE CUSTCHANGEHD.CCHNO = CUSTCHANGEDTHIS.CCDNO
       AND CUSTCHANGEHD.CCHNO = CUSTCHANGEDT.CCDNO
       AND CUSTCHANGEDTHIS.CCDROWNO = CUSTCHANGEDT.CCDROWNO
       AND CUSTCHANGEHD.CCHLB in ('D')
       and CUSTCHANGEDTHIS.MIID = P_RL.rlmid;
    if v_monbet = 100 or v_yyyymm <= V_jtqzny then
    
      v_yyyymm := V_jtqzny;
    else
      v_yyyymm := v_yyyymm;
    end if;
    v_monbet := 12;
    -- ��һ����Ѳ�������� 
    --by wlj 20170321  2016��1���𣨺�һ�£��״γ����������
    IF P_RL.RLJTMK = 'Y' or v_RLSCRRLMONTH = 'a' or p_rl.rltrans in('14', '21') or v_rlmonth <='2015.12' then
      v_rljtmk := 'Y';
    ELSE
      v_rljtmk := 'N';
    END IF;
    --û�п�������³�����
    if V_DATEOLD >= to_date(P_RL.RLMONTH, 'yyyy.mm') or v_rljtmk = 'Y' then
       select nvl(sum(rdsl), 0)
        into P_RL.RLCOLUMN12
        from reclist, recdetail,meterinfo
       where rlid = rdid
         and rlmid = miid
         AND NVL(rljtmk, 'N') = 'N'
         and RLSCRRLTRANS not in ('14', '21')
         and RDPMDCOLUMN3 = substr(V_jtqzny, 1, 4)
         and rdpiid = '01'
         and rdmethod = 'sl3'
         and RLSCRRLMONTH <= P_RL.Rlmonth
         and RLSCRRLMONTH > v_yyyymm
         and mipriid = MINFO.Mipriid;
        /* and rlmid in
             (select miid from meterinfo where mipriid = MINFO.Mipriid);*/
      /*select nvl(sum(rdsl), 0)
        into P_RL.RLCOLUMN12
        from reclist, recdetail
       where rlid = rdid
         AND NVL(rljtmk, 'N') = 'N'
         and RLSCRRLTRANS not in ('14', '21')
         and RDPMDCOLUMN3 = substr(V_jtqzny, 1, 4)
         and rdpiid = '01'
         and rdmethod = 'sl3'
         and rlmonth <= P_RL.Rlmonth
         and rlmonth > v_yyyymm
         and rlmid in
             (select miid from meterinfo where mipriid = MINFO.Mipriid);*/
      RD.RDPMDCOLUMN3 := substr(V_jtqzny, 1, 4);
      ���ۼ�ˮ��      := TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), 0) + P_SL;
      IF PMONTH = '0000.00' OR PMONTH IS NULL or PMONTH = 'ָ��' THEN
        OPEN C_PS;
        FETCH C_PS
          INTO PS;
        IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�Ľ��ݼƷ�����');
        END IF;
        WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --����ˮ�ѽ������������������й�
          -- if nvl(p_rl.rlusenum, 0) >= 4 then
          IF ps.psscode = 0 THEN
            ps.psscode := 0;
          ELSE
            ps.psscode := round((ps.psscode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
          END IF;
          ps.psecode := round((ps.psecode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
        
          -- end if;
          --RD.RDPMDCOLUMN1 := PS.PSSCODE; --�������ݶ�������
          --RD.RDPMDCOLUMN2 := PS.PSECODE; --�������ݶ�ֹ����
          RD.RDCLASS := PS.PSCLASS;
          RD.RDYSDJ  := PS.psprice;
          RD.RDYSSL := case
                         when v_rljtmk = 'Y' then
                          TMPYSSL
                         else
                          case
                            when ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                             ���ۼ�ˮ�� - TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                  PS.PSSCODE)
                            when ���ۼ�ˮ�� >= PS.PSECODE then
                             TOOLS.GETMAX(0,
                                          TOOLS.GETMIN(PS.PSECODE -
                                                       to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                       PS.PSECODE - PS.PSSCODE))
                            else
                             0
                          end
                       end;
          RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;
          RD.RDDJ    := PS.psprice;
          RD.RDSL := case
                       when v_rljtmk = 'Y' then
                        TMPSL
                       else
                        case
                          when ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                           ���ۼ�ˮ�� -
                           TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                          when ���ۼ�ˮ�� > PS.PSECODE then
                           TOOLS.GETMAX(0,
                                        TOOLS.GETMIN(PS.PSECODE -
                                                     to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                     PS.PSECODE - PS.PSSCODE))
                          else
                           0
                        end
                     end;
          RD.RDJE    := RD.RDDJ * RD.RDSL;
          RD.RDADJDJ := 0;
          RD.RDADJSL := RD.RDSL - RD.RDYSSL;
          RD.RDADJJE := 0;
          if v_rljtmk <> 'Y' then
            /*if ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
               RD.RDPMDCOLUMN1 := PS.PSECODE - ���ۼ�ˮ��;
            else*/
            RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
            if ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
              RD.RDPMDCOLUMN2 := ���ۼ�ˮ�� - PS.PSSCODE;
            elsif ���ۼ�ˮ�� > PS.PSECODE then
              RD.RDPMDCOLUMN2 := PS.PSECODE - PS.PSSCODE;
            else
              RD.RDPMDCOLUMN2 := 0;
            end if;
            --end if;
          end if;
        
          if RD.RDSL > 0 then
            IF RDTAB IS NULL THEN
              RDTAB := RD_TABLE(RD);
            ELSE
              RDTAB.EXTEND;
              RDTAB(RDTAB.LAST) := RD;
            END IF;
          END IF;
          --����
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
          --�ۼ��������һ���α�
          --TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
          --TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
        
          TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
          TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
        
          EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
          FETCH C_PS
            INTO PS;
        END LOOP;
        CLOSE C_PS;
      ELSE
        OPEN C_PS_JT;
        FETCH C_PS_JT
          INTO PS;
        IF C_PS_JT%NOTFOUND OR C_PS_JT%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�Ľ��ݼƷ�����');
        END IF;
        WHILE C_PS_JT%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --����ˮ�ѽ������������������й�
          if nvl(p_rl.rlusenum, 0) >= 4 then
            IF ps.psscode = 0 THEN
              ps.psscode := 0;
            ELSE
              ps.psscode := round((ps.psscode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
            END IF;
            ps.psecode := round((ps.psecode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
          
          end if;
          RD.RDCLASS := PS.PSCLASS;
          RD.RDYSDJ  := PS.psprice;
          RD.RDYSSL := case
                         when v_rljtmk = 'Y' then
                          TMPYSSL
                         else
                          case
                            when ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                             ���ۼ�ˮ�� - TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                  PS.PSSCODE)
                            when ���ۼ�ˮ�� > PS.PSECODE then
                             TOOLS.GETMAX(0,
                                          TOOLS.GETMIN(PS.PSECODE -
                                                       to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                       PS.PSECODE - PS.PSSCODE))
                            else
                             0
                          end
                       end;
          RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;
          RD.RDDJ    := PS.psprice;
          RD.RDSL := case
                       when v_rljtmk = 'Y' then
                        TMPSL
                       else
                        case
                          when ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                           ���ۼ�ˮ�� -
                           TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                          when ���ۼ�ˮ�� > PS.PSECODE then
                           TOOLS.GETMAX(0,
                                        TOOLS.GETMIN(PS.PSECODE -
                                                     to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                     PS.PSECODE - PS.PSSCODE))
                          else
                           0
                        end
                     end;
          RD.RDJE    := RD.RDDJ * RD.RDSL;
          RD.RDADJDJ := 0;
          RD.RDADJSL := RD.RDSL - RD.RDYSSL;
          RD.RDADJJE := 0;
          if v_rljtmk <> 'Y' then
            /*if ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
               RD.RDPMDCOLUMN1 := PS.PSECODE - ���ۼ�ˮ��;
            else*/
            RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
            if ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
              RD.RDPMDCOLUMN2 := ���ۼ�ˮ�� - PS.PSSCODE;
            elsif ���ۼ�ˮ�� > PS.PSECODE then
              RD.RDPMDCOLUMN2 := PS.PSECODE - PS.PSSCODE;
            else
              RD.RDPMDCOLUMN2 := 0;
            end if;
            --end if;
          end if;
        
          if RD.RDSL > 0 then
            IF RDTAB IS NULL THEN
              RDTAB := RD_TABLE(RD);
            ELSE
              RDTAB.EXTEND;
              RDTAB(RDTAB.LAST) := RD;
            END IF;
          END IF;
          --����
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
        
          TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
          TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
        
          EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
          FETCH C_PS_JT
            INTO PS;
        END LOOP;
        CLOSE C_PS_JT;
      END IF;
    
    else
      --���꣬��Ҫ����ˮ�·ݱ������
      v_jgyf := MONTHS_BETWEEN(to_date(P_RL.RLMONTH, 'yyyy.mm'), V_DATEOLD);
      v_jtny := MONTHS_BETWEEN(to_date(P_RL.RLMONTH, 'yyyy.mm'),
                               to_date(v_RLSCRRLMONTH, 'yyyy.mm'));
      if v_jgyf / v_jtny  > 1 then
        v_jtny := v_jgyf;
      end if;                
      if v_jgyf > 12 then
        TMPYSSL  := P_SL;
        TMPSL    := P_SL;
        v_rljtmk := 'Y';
      else
        TMPYSSL := P_SL - round(P_SL * v_jgyf / v_jtny); --�����ۼ�Ӧ��ˮ�����
        TMPSL   := P_SL - round(P_SL * v_jgyf / v_jtny); --�����ۼ�ʵ��ˮ����� 
      end if;
      RD.RDPSCID := -1;
      if v_rljtmk = 'Y' then
        P_RL.RLCOLUMN12 := 0;
      else
        select nvl(sum(rdsl), 0)
          into P_RL.RLCOLUMN12
          from reclist, recdetail
         where rlid = rdid
           AND NVL(rljtmk, 'N') = 'N'
           and RLSCRRLTRANS not in ('14', '21')
           and RDPMDCOLUMN3 = substr(v_RLJTSRQold, 1, 4)
           and rdpiid = '01'
           and rdmethod = 'sl3'
           and RLSCRRLMONTH <= P_RL.Rlmonth
           and RLSCRRLMONTH > v_yyyymm
           and rlmid in
               (select miid from meterinfo where mipriid = MINFO.Mipriid);
      end if;
      RD.RDPMDCOLUMN3 := substr(v_RLJTSRQold, 1, 4);
      ���ۼ�ˮ��      := TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), 0) +
                    (P_SL - round(P_SL * v_jgyf / v_jtny));
      --����ȥ��Ľ���
      IF PMONTH = '0000.00' OR PMONTH IS NULL or PMONTH = 'ָ��' THEN
        OPEN C_PS;
        FETCH C_PS
          INTO PS;
        IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�Ľ��ݼƷ�����');
        END IF;
        WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --����ˮ�ѽ������������������й�
          -- if nvl(p_rl.rlusenum, 0) >= 4 then
          IF ps.psscode = 0 THEN
            ps.psscode := 0;
          ELSE
            ps.psscode := round((ps.psscode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
          END IF;
          ps.psecode := round((ps.psecode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
        
          -- end if;
          --RD.RDPMDCOLUMN1 := PS.PSSCODE; --�������ݶ�������
          --RD.RDPMDCOLUMN2 := PS.PSECODE; --�������ݶ�ֹ����
          RD.RDCLASS := PS.PSCLASS;
          RD.RDYSDJ  := PS.psprice;
          RD.RDYSSL := case
                         when v_rljtmk = 'Y' then
                          TMPYSSL
                         else
                          case
                            when ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                             ���ۼ�ˮ�� - TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                  PS.PSSCODE)
                            when ���ۼ�ˮ�� > PS.PSECODE then
                             TOOLS.GETMAX(0,
                                          TOOLS.GETMIN(PS.PSECODE -
                                                       to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                       PS.PSECODE - PS.PSSCODE))
                            else
                             0
                          end
                       end;
          RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;
          RD.RDDJ    := PS.psprice;
          RD.RDSL := case
                       when v_rljtmk = 'Y' then
                        TMPSL
                       else
                        case
                          when ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                           ���ۼ�ˮ�� -
                           TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                          when ���ۼ�ˮ�� > PS.PSECODE then
                           TOOLS.GETMAX(0,
                                        TOOLS.GETMIN(PS.PSECODE -
                                                     to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                     PS.PSECODE - PS.PSSCODE))
                          else
                           0
                        end
                     end;
          RD.RDJE    := RD.RDDJ * RD.RDSL;
          RD.RDADJDJ := 0;
          RD.RDADJSL := RD.RDSL - RD.RDYSSL;
          RD.RDADJJE := 0;
          if v_rljtmk <> 'Y' then
            /*if ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
               RD.RDPMDCOLUMN1 := PS.PSECODE - ���ۼ�ˮ��;
            else*/
            RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
            if ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
              RD.RDPMDCOLUMN2 := ���ۼ�ˮ�� - PS.PSSCODE;
            elsif ���ۼ�ˮ�� > PS.PSECODE then
              RD.RDPMDCOLUMN2 := PS.PSECODE - PS.PSSCODE;
            else
              RD.RDPMDCOLUMN2 := 0;
            end if;
            --end if;
          end if;
        
          if RD.RDSL > 0 then
            IF RDTAB IS NULL THEN
              RDTAB := RD_TABLE(RD);
            ELSE
              RDTAB.EXTEND;
              RDTAB(RDTAB.LAST) := RD;
            END IF;
          END IF;
          --����
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
          --�ۼ��������һ���α�
          --TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
          --TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
        
          TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
          TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
        
          EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
          FETCH C_PS
            INTO PS;
        END LOOP;
        CLOSE C_PS;
      ELSE
        OPEN C_PS_JT;
        FETCH C_PS_JT
          INTO PS;
        IF C_PS_JT%NOTFOUND OR C_PS_JT%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�Ľ��ݼƷ�����');
        END IF;
        WHILE C_PS_JT%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --����ˮ�ѽ������������������й�
          if nvl(p_rl.rlusenum, 0) >= 4 then
            IF ps.psscode = 0 THEN
              ps.psscode := 0;
            ELSE
              ps.psscode := round((ps.psscode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
            END IF;
            ps.psecode := round((ps.psecode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
          
          end if;
          RD.RDCLASS := PS.PSCLASS;
          RD.RDYSDJ  := PS.psprice;
          RD.RDYSSL := case
                         when v_rljtmk = 'Y' then
                          TMPYSSL
                         else
                          case
                            when ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                             ���ۼ�ˮ�� - TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                  PS.PSSCODE)
                            when ���ۼ�ˮ�� > PS.PSECODE then
                             TOOLS.GETMAX(0,
                                          TOOLS.GETMIN(PS.PSECODE -
                                                       to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                       PS.PSECODE - PS.PSSCODE))
                            else
                             0
                          end
                       end;
          RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;
          RD.RDDJ    := PS.psprice;
          RD.RDSL := case
                       when v_rljtmk = 'Y' then
                        TMPSL
                       else
                        case
                          when ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                           ���ۼ�ˮ�� -
                           TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                          when ���ۼ�ˮ�� > PS.PSECODE then
                           TOOLS.GETMAX(0,
                                        TOOLS.GETMIN(PS.PSECODE -
                                                     to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                     PS.PSECODE - PS.PSSCODE))
                          else
                           0
                        end
                     end;
          RD.RDJE    := RD.RDDJ * RD.RDSL;
          RD.RDADJDJ := 0;
          RD.RDADJSL := RD.RDSL - RD.RDYSSL;
          RD.RDADJJE := 0;
          if v_rljtmk <> 'Y' then
            /*if ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
               RD.RDPMDCOLUMN1 := PS.PSECODE - ���ۼ�ˮ��;
            else*/
            RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
            if ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
              RD.RDPMDCOLUMN2 := ���ۼ�ˮ�� - PS.PSSCODE;
            elsif ���ۼ�ˮ�� > PS.PSECODE then
              RD.RDPMDCOLUMN2 := PS.PSECODE - PS.PSSCODE;
            else
              RD.RDPMDCOLUMN2 := 0;
            end if;
            --end if;
          end if;
        
          if RD.RDSL > 0 then
            IF RDTAB IS NULL THEN
              RDTAB := RD_TABLE(RD);
            ELSE
              RDTAB.EXTEND;
              RDTAB(RDTAB.LAST) := RD;
            END IF;
          END IF;
          --����
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
        
          TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
          TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
        
          EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
          FETCH C_PS_JT
            INTO PS;
        END LOOP;
        CLOSE C_PS_JT;
      END IF;
    
      if v_jgyf <= 12 then
        IF v_newmk = 'Y' THEN
          v_rljtmk := 'Y';
        END IF;
        RD.RDPSCID := PD.PDPSCID;
        TMPYSSL    := round(P_SL * (v_jgyf / v_jtny)); --�����ۼ�Ӧ��ˮ�����
        TMPSL      := round(P_SL * (v_jgyf / v_jtny)); --�����ۼ�ʵ��ˮ����� 
      
        select nvl(sum(rdsl), 0)
          into P_RL.RLCOLUMN12
          from reclist, recdetail
         where rlid = rdid
           AND NVL(rljtmk, 'N') = 'N'
           and RLSCRRLTRANS not in ('14', '21')
           and RDPMDCOLUMN3 = substr(P_RL.Rlmonth, 1, 4)
           and rdpiid = '01'
           and rdmethod = 'sl3'
           and RLSCRRLMONTH <= P_RL.Rlmonth
           and RLSCRRLMONTH > v_yyyymm
           and rlmid in
               (select miid from meterinfo where mipriid = MINFO.Mipriid);
        RD.RDPMDCOLUMN3 := substr(P_RL.Rlmonth, 1, 4);
        ���ۼ�ˮ��      := TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), 0) +
                      (round(P_SL * v_jgyf / v_jtny));
        --����ȥ��Ľ���
        IF PMONTH = '0000.00' OR PMONTH IS NULL or PMONTH = 'ָ��' THEN
          OPEN C_PS;
          FETCH C_PS
            INTO PS;
          IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�Ľ��ݼƷ�����');
          END IF;
          WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
            --����ˮ�ѽ������������������й�
            -- if nvl(p_rl.rlusenum, 0) >= 4 then
            IF ps.psscode = 0 THEN
              ps.psscode := 0;
            ELSE
              ps.psscode := round((ps.psscode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
            END IF;
            ps.psecode := round((ps.psecode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
          
            -- end if;
            --RD.RDPMDCOLUMN1 := PS.PSSCODE; --�������ݶ�������
            --RD.RDPMDCOLUMN2 := PS.PSECODE; --�������ݶ�ֹ����
            RD.RDCLASS := PS.PSCLASS;
            RD.RDYSDJ  := PS.psprice;
            RD.RDYSSL := case
                           when v_rljtmk = 'Y' then
                            TMPYSSL
                           else
                            case
                              when ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                               ���ۼ�ˮ�� - TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                    PS.PSSCODE)
                              when ���ۼ�ˮ�� > PS.PSECODE then
                               TOOLS.GETMAX(0,
                                            TOOLS.GETMIN(PS.PSECODE -
                                                         to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                         PS.PSECODE - PS.PSSCODE))
                              else
                               0
                            end
                         end;
            RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;
            RD.RDDJ    := PS.psprice;
            RD.RDSL := case
                         when v_rljtmk = 'Y' then
                          TMPSL
                         else
                          case
                            when ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                             ���ۼ�ˮ�� -
                             TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                            when ���ۼ�ˮ�� > PS.PSECODE then
                             TOOLS.GETMAX(0,
                                          TOOLS.GETMIN(PS.PSECODE -
                                                       to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                       PS.PSECODE - PS.PSSCODE))
                            else
                             0
                          end
                       end;
            RD.RDJE    := RD.RDDJ * RD.RDSL;
            RD.RDADJDJ := 0;
            RD.RDADJSL := RD.RDSL - RD.RDYSSL;
            RD.RDADJJE := 0;
            if v_rljtmk <> 'Y' then
              /*if ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                 RD.RDPMDCOLUMN1 := PS.PSECODE - ���ۼ�ˮ��;
              else*/
              RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
              if ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                RD.RDPMDCOLUMN2 := ���ۼ�ˮ�� - PS.PSSCODE;
              elsif ���ۼ�ˮ�� > PS.PSECODE then
                RD.RDPMDCOLUMN2 := PS.PSECODE - PS.PSSCODE;
              else
                RD.RDPMDCOLUMN2 := 0;
              end if;
              --end if;
            end if;
          
            if RD.RDSL > 0 then
              IF RDTAB IS NULL THEN
                RDTAB := RD_TABLE(RD);
              ELSE
                RDTAB.EXTEND;
                RDTAB(RDTAB.LAST) := RD;
              END IF;
            END IF;
            --����
            P_RL.RLJE := P_RL.RLJE + RD.RDJE;
            P_RL.RLSL := P_RL.RLSL + (CASE
                           WHEN RD.RDPIID = '01' THEN
                            RD.RDSL
                           ELSE
                            0
                         END);
            --�ۼ��������һ���α�
            --TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
            --TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
          
            TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
            TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
          
            EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
            FETCH C_PS
              INTO PS;
          END LOOP;
          CLOSE C_PS;
        ELSE
          OPEN C_PS_JT;
          FETCH C_PS_JT
            INTO PS;
          IF C_PS_JT%NOTFOUND OR C_PS_JT%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�Ľ��ݼƷ�����');
          END IF;
          WHILE C_PS_JT%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
            --����ˮ�ѽ������������������й�
            if nvl(p_rl.rlusenum, 0) >= 4 then
              IF ps.psscode = 0 THEN
                ps.psscode := 0;
              ELSE
                ps.psscode := round((ps.psscode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
              END IF;
              ps.psecode := round((ps.psecode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
            
            end if;
            RD.RDCLASS := PS.PSCLASS;
            RD.RDYSDJ  := PS.psprice;
            RD.RDYSSL := case
                           when v_rljtmk = 'Y' then
                            TMPYSSL
                           else
                            case
                              when ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                               ���ۼ�ˮ�� - TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                    PS.PSSCODE)
                              when ���ۼ�ˮ�� > PS.PSECODE then
                               TOOLS.GETMAX(0,
                                            TOOLS.GETMIN(PS.PSECODE -
                                                         to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                         PS.PSECODE - PS.PSSCODE))
                              else
                               0
                            end
                         end;
            RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;
            RD.RDDJ    := PS.psprice;
            RD.RDSL := case
                         when v_rljtmk = 'Y' then
                          TMPSL
                         else
                          case
                            when ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                             ���ۼ�ˮ�� -
                             TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                            when ���ۼ�ˮ�� > PS.PSECODE then
                             TOOLS.GETMAX(0,
                                          TOOLS.GETMIN(PS.PSECODE -
                                                       to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                       PS.PSECODE - PS.PSSCODE))
                            else
                             0
                          end
                       end;
            RD.RDJE    := RD.RDDJ * RD.RDSL;
            RD.RDADJDJ := 0;
            RD.RDADJSL := RD.RDSL - RD.RDYSSL;
            RD.RDADJJE := 0;
            if v_rljtmk <> 'Y' then
              /*if ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                 RD.RDPMDCOLUMN1 := PS.PSECODE - ���ۼ�ˮ��;
              else*/
              RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
              if ���ۼ�ˮ�� >= PS.PSSCODE and ���ۼ�ˮ�� <= PS.PSECODE then
                RD.RDPMDCOLUMN2 := ���ۼ�ˮ�� - PS.PSSCODE;
              elsif ���ۼ�ˮ�� > PS.PSECODE then
                RD.RDPMDCOLUMN2 := PS.PSECODE - PS.PSSCODE;
              else
                RD.RDPMDCOLUMN2 := 0;
              end if;
              --end if;
            end if;
          
            if RD.RDSL > 0 then
              IF RDTAB IS NULL THEN
                RDTAB := RD_TABLE(RD);
              ELSE
                RDTAB.EXTEND;
                RDTAB(RDTAB.LAST) := RD;
              END IF;
            END IF;
            --����
            P_RL.RLJE := P_RL.RLJE + RD.RDJE;
            P_RL.RLSL := P_RL.RLSL + (CASE
                           WHEN RD.RDPIID = '01' THEN
                            RD.RDSL
                           ELSE
                            0
                         END);
          
            TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
            TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
          
            EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
            FETCH C_PS_JT
              INTO PS;
          END LOOP;
          CLOSE C_PS_JT;
        END IF;
      end if;
    end if;
  
    /* --�ۼ������
    select nvl(sum(rdsl), 0)
      into P_RL.RLCOLUMN12
      from reclist, recdetail
     where rlid = rdid
       AND NVL(rljtmk, 'N') = 'N'
       and rdpiid = '01'
       and rdmethod = 'sl3'
       and rlmonth >= v_yyyymm
       and rlmid = P_RL.rlmid;*/
  
    if v_rljtmk = 'N' then
      P_RL.RLCOLUMN12 := ���ۼ�ˮ��;
    ELSE
      P_RL.RLJTMK := 'Y';
    end if;
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
  
  --������� for pb ǰ̨
  procedure submit_forpb(p_bfid in  varchar2,   --���Id  
                         p_app  out number,     --������ 1-�ɹ� -1 �д��� 
                         p_err  out varchar2    --������Ϣ 
  ) is
  CURSOR C_MR(VBFID IN VARCHAR2, VSMFID IN VARCHAR2) IS
      SELECT MRID��mrmid
        FROM METERREAD, METERINFO
       WHERE MRMID = MIID
         AND MRBFID = VBFID
         AND MRSMFID = VSMFID
         and METERINFO.mistatus not in ('24', '35', '36', '19') --���ʱ�����ϻ����С����ڻ����С�Ԥ������С������еĲ��������,��ѹ��ϻ����С����ڻ����е�������������� 20140628
         AND MRIFREC = 'N'            
         AND MRREADOK = 'Y' --����״̬
       ORDER BY MICLASS DESC,
                (CASE
                  WHEN MIPRIFLAG = 'Y' AND MIPRIID <> MICODE THEN
                   1
                  ELSE
                   2
                END) ASC;
    VMRID  METERREAD.MRID%TYPE;
    vmrmid meterread.mrmid%type;
    VBFID  METERREAD.MRBFID%TYPE;
    VSMFID METERREAD.MRSMFID%TYPE;
    VLOG   CLOB;
  begin
    p_app := 1;
    CALLOGTXT := NULL;
    WLOG('�ύ��ѣ�������У�' || P_BFID);
    
    FOR I IN 1 .. TOOLS.FBOUNDPARA(P_BFID) LOOP
      VBFID  := TOOLS.FGETPARA(P_BFID, I, 1);
      VSMFID := TOOLS.FGETPARA(P_BFID, I, 2);
      WLOG('������ѱ��ţ�' || VBFID || ' ...');
      OPEN C_MR(VBFID, VSMFID);
      LOOP
        FETCH C_MR INTO VMRID,vmrmid;
        EXIT WHEN C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL;
        --���������¼����
        BEGIN        
          CALCULATE(VMRID);
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            p_app := -1;
            ROLLBACK;
            --WLOG('�����¼' || VMRID || '���ʧ�ܣ��ѱ�����');
            p_err := p_err || sqlerrm || chr(13) || chr(10);
        END;
      END LOOP;
      CLOSE C_MR;
      WLOG('---------------------------------------------------');
    END LOOP;
  
    WLOG('��ѹ��̴������');
    VLOG := CALLOGTXT;
    
  exception
    when others then 
    p_app := -1;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  end;
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

