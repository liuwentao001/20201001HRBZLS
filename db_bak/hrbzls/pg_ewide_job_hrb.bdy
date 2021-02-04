CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_JOB_HRB" AS

  ---------------------------------------------------
  --��ʽ����ʱ��ÿ�µ����ڶ���ִ�����Զ������½�������½�������Զ����¸��µ��³�
  ---------------------------------------------------
  --�³�����  --188690 --��ʱ30 ����
  PROCEDURE �³����� AS
    CURSOR C_SMFID IS

           SELECT SMFID
        FROM SYSMANAFRAME
       WHERE SMFPID = '02'
         AND SMFCLASS = '2'  
         and ((( SMFID <> '0201' and SMFID <> '0209' ) and  to_char( Last_day(sysdate)  - 1,'yyyy.mm') = '2015.06' ) or to_char( Last_day(sysdate)  - 1,'yyyy.mm') <> '2015.06'  ) 
       ORDER BY SMFID;
   --����  �޸����ڣ�2015.06.26  ԭ�򣺵�������ʿ���7�·ݲ����ɳ���ƻ�   ����ˣ���ΰ 
   
    CURSOR C_BFID(P_SMFID VARCHAR2, P_MONTH VARCHAR2) IS
      SELECT BFID
        FROM BOOKFRAME
       WHERE BFSMFID = P_SMFID
         AND BFNRMONTH = P_MONTH
         AND BFCLASS = '3'
         AND BFFLAG = 'Y'
         AND BFSTATUS = 'Y'
       ORDER BY BFID;
  
    V_SMFID     SYSMANAFRAME%ROWTYPE;
    V_BFID      BOOKFRAME%ROWTYPE;
    V_READMONTH VARCHAR2(7);
    v_month VARCHAR2(7);
  BEGIN
    OPEN C_SMFID;
    LOOP
      FETCH C_SMFID
        INTO V_SMFID.SMFID;
      EXIT WHEN C_SMFID%NOTFOUND OR C_SMFID%NOTFOUND IS NULL;
      NULL;
      --��ȡӪҵ����ǰ���ݷ�����ʱ���Ӧ�������·ݣ������ڳ����·�

         V_READMONTH := TOOLS.FGETREADMONTH(V_SMFID.SMFID);
     
    
      OPEN C_BFID(TRIM(V_SMFID.SMFID), TRIM(V_READMONTH));
      LOOP
        FETCH C_BFID
          INTO V_BFID.BFID;
        EXIT WHEN C_BFID%NOTFOUND OR C_BFID%NOTFOUND IS NULL;
      
        --���ù������³�����
        ---by ����  �޸����ڣ�2015.06.26  ԭ�򣺵�������ʿ���7�·ݲ����ɳ���ƻ�   ����ˣ���ΰ 
       -- select to_char(sysdate,'yyyy.mm') into  v_month from dual;
/*        IF V_READMONTH='2015.07' AND (v_SMFID.SMFID='0201' OR v_SMFID.SMFID='0209') THEN
            NULL;
        ELSE*/
             PG_EWIDE_RAEDPLAN_01.CREATEMR(V_SMFID.SMFID,
                                      V_READMONTH,
                                      V_BFID.BFID);
     /*    END IF;*/
         ----
        /*        IF MOD(C_BFID%ROWCOUNT, 100) = 0 THEN
          COMMIT;
        END IF;*/
      
      END LOOP;
      CLOSE C_BFID;
      COMMIT;
    
    END LOOP;
    CLOSE C_SMFID;
    COMMIT;
  
  END �³�����;
	
	--�³�����(���԰�)
  procedure prc_monthlyInit is
    CURSOR C_SMFID IS
      SELECT SMFID
        FROM SYSMANAFRAME
       WHERE SMFPID = '02'
         AND SMFCLASS = '2'          
       ORDER BY SMFID;
    V_SMFID     SYSMANAFRAME.Smfid%type default '';
    V_BFID      BOOKFRAME%ROWTYPE;
    V_READMONTH VARCHAR2(7);
    v_msg       varchar2(500);
  begin
    for rec_smf in c_smfid loop 
       V_READMONTH := TOOLS.FGETREADMONTH(rec_smf.smfid);
       --for rec_bf in cur_bookframe(rec_smf.smfid,V_READMONTH) loop           
          --���ɳ���ƻ�......
          begin
            PG_EWIDE_RAEDPLAN_01.CREATEMR2(rec_smf.smfid,
                                           V_READMONTH,
                                           null);
            insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'�³�.���ɳ���ƻ�',sysdate,'1','Ӫҵ��[' || rec_smf.smfid || ']���ɳ���ƻ����!');
            commit;
          exception
            when others then
              rollback;
              v_msg := 'Ӫҵ��[' || rec_smf.smfid || ']���ɳ���ƻ�ʧ��!������Ϣ:' || sqlerrm;
              insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
              values(SEQ_JOB_RUNNING_LOG.Nextval,'�³�.���ɳ���ƻ�',sysdate,'1', v_msg);
              commit;
          end;    
       --end loop;
    end loop;   
  end;

  --�����½ᣬֻ����һ��JOB�Զ�����ִ�г����½ᣬ�����½ᣬ�³�����
  PROCEDURE �����½� AS
    CURSOR C_SMFID IS
      SELECT SMFID
        FROM SYSMANAFRAME
       WHERE SMFPID = '02'
         AND SMFCLASS = '2'
       ORDER BY SMFID;
  
    V_SMFID     SYSMANAFRAME%ROWTYPE;
    V_READMONTH VARCHAR2(7);
    V_NEWRUN VARCHAR2(2);
    
    RUNOVER EXCEPTION;
  BEGIN
    --�ڴ��жϳ����½��־�Ƿ��Ѿ�ִ��
    V_NEWRUN:='Y';
    select t.spvalue INTO  V_NEWRUN 
    from    syspara t
    where t.spid='YJBZ';
    IF V_NEWRUN='Y' THEN
       RAISE RUNOVER;
    END IF;
    ----------------------------------
    OPEN C_SMFID;
    LOOP
      FETCH C_SMFID
        INTO V_SMFID.SMFID;
      EXIT WHEN C_SMFID%NOTFOUND OR C_SMFID%NOTFOUND IS NULL;
      NULL;
      --��ȡӪҵ����ǰ���ݷ�����ʱ���Ӧ�������·ݣ������ڳ����·�
      V_READMONTH := TOOLS.FGETREADMONTH(V_SMFID.SMFID);
      --���ù��������մ���
      PG_EWIDE_RAEDPLAN_01.CARRYFORWARD_MR(V_SMFID.SMFID,
                                           V_READMONTH,
                                           'SYSTEM',
                                           'Y');
    END LOOP;
    CLOSE C_SMFID;
    
    --�����½�ɹ��������н�����־����ֹ�����ٴ����иù���
    UPDATE  syspara t
    SET t.spvalue = 'Y'
    where t.spid='YJBZ';    
    
    COMMIT;

  EXCEPTION
 /*    WHEN RUNOVER THEN*/
       
     WHEN OTHERS THEN  
       ROLLBACK;
  END �����½�;

  --�����½�
  PROCEDURE �����½� AS
    CURSOR C_SMFID IS
      SELECT SMFID
        FROM SYSMANAFRAME
       WHERE SMFPID = '02'
         AND SMFCLASS = '2'
       ORDER BY SMFID;
  
    V_SMFID   SYSMANAFRAME%ROWTYPE;
    V_RLMONTH VARCHAR2(7);
  
  BEGIN
    OPEN C_SMFID;
    LOOP
      FETCH C_SMFID
        INTO V_SMFID.SMFID;
      EXIT WHEN C_SMFID%NOTFOUND OR C_SMFID%NOTFOUND IS NULL;
      NULL;
      --��ȡӪҵ������Ӧ�������·�
      V_RLMONTH := TOOLS.FGETRECMONTH(V_SMFID.SMFID);
      --���ù��������մ���
      PG_EWIDE_RAEDPLAN_01.CARRYFORPAY_MR(V_SMFID.SMFID,
                                          V_RLMONTH,
                                          'SYSTEM',
                                          'Y');
    END LOOP;
    CLOSE C_SMFID;
    COMMIT;
    --�����½���Զ�ִ���³�����
    BEGIN
      NULL;
      --PG_EWIDE_JOB_HRB.�³�����;
    END;
  END �����½�;
/*------------------------------------------------------------------
���������Զ���ѣ������Զ�Ԥ��ֿۣ�
����: ��
���ܣ���̨�Զ�������ѣ�ͬʱ����Ԥ��ֿ�
-------------------------------------------------------------------*/  
  PROCEDURE �Զ���� AS
    CURSOR C_BOOK IS
      SELECT BFID || ',' || BFSMFID || '|'
        FROM BOOKFRAME
       WHERE BFCLASS = 3
         AND BFFLAG = 'Y'
         AND BFSTATUS = 'Y'
      --AND BFID='06099070'
       ORDER BY BFID;
  
    V_BOOK BOOKFRAME%ROWTYPE;
    V_BFID VARCHAR2(100);
  
  BEGIN
    OPEN C_BOOK;
    LOOP
      FETCH C_BOOK
        INTO V_BFID;
      EXIT WHEN C_BOOK%NOTFOUND OR C_BOOK%NOTFOUND IS NULL;
      NULL;
      --���ù�����������Զ����
      PG_EWIDE_METERREAD_01.SUBMIT(V_BFID);
    END LOOP;
    CLOSE C_BOOK;
    COMMIT;
  END �Զ����;
  
    --20140503 ά��������ʷʵ�ն�������
 PROCEDURE ά��������ʷʵ�ն������� AS
   CURSOR C_BANK_PAY IS
     SELECT *
       FROM PAYMENT
      WHERE PTRANS = 'B'
        AND PDATE <= TO_DATE('2014-04-16', 'YYYY-MM-DD')
        AND PCHKNO IS NOT NULL
        AND PCHKDATE >= TO_DATE('2014-05-01', 'YYYY-MM-DD');
 
   V_BANK_PAY PAYMENT%ROWTYPE;
 BEGIN
   NULL;
   OPEN C_BANK_PAY;
   LOOP
     FETCH C_BANK_PAY
       INTO V_BANK_PAY;
     EXIT WHEN C_BANK_PAY%NOTFOUND OR C_BANK_PAY%NOTFOUND IS NULL;
     
     UPDATE PAYMENT
        SET PCHKDATE = PDATE, PCHKNO = NULL, TCHKDATE = PDATE
      WHERE PID = V_BANK_PAY.PID;
      
     IF MOD(C_BANK_PAY%ROWCOUNT, 100) = 0 THEN
       COMMIT;
     END IF;
   
   END LOOP;
   COMMIT;
   CLOSE C_BANK_PAY;
 
 END;
 
  --20140503 ά����ʷ���нɷѻ���
 PROCEDURE ά����ʷ���нɷѻ��� AS
   CURSOR C_BANK_PAY IS
     SELECT *
       FROM PAYMENT
      WHERE PTRANS = 'B'
        AND PDATE <= TO_DATE('2014-04-16', 'YYYY-MM-DD')
        and LENGTH(PPOSITION) = 4
        AND SUBSTR(PPOSITION, 1, 2) = '03'
        and pmonth < '2014.04';
 
   V_BANK_PAY PAYMENT%ROWTYPE;
 BEGIN
   NULL;
   OPEN C_BANK_PAY;
   LOOP
     FETCH C_BANK_PAY
       INTO V_BANK_PAY;
     EXIT WHEN C_BANK_PAY%NOTFOUND OR C_BANK_PAY%NOTFOUND IS NULL;
   
    /* IF LENGTH(V_BANK_PAY.PPOSITION) = 4 AND
        SUBSTR(V_BANK_PAY.PPOSITION, 1, 2) = '03' THEN*/
       UPDATE PAYMENT
          SET PPOSITION = TRIM(V_BANK_PAY.PPOSITION || '01')
        WHERE PID = V_BANK_PAY.PID;
 /*    END IF;*/
   
     IF MOD(C_BANK_PAY%ROWCOUNT, 100) = 0 THEN
       COMMIT;
     END IF;
   
   END LOOP;
   COMMIT;
   CLOSE C_BANK_PAY;
 
 END;
 
/*  PROCEDURE ά���ͱ���־�͵ͱ�֤���� AS
  
    CURSOR C_HEB_DB IS
      SELECT C.CLT_ID, C.DESCRIPTION2, S.CLT_NO
        FROM CLT_INFO@HRBOLD C, SBINFO@HRBOLD S
       WHERE C.CLT_ID = S.CLT_ID
         AND C.FLAG = '1'
         AND S.USE_TYPE = 'A0104';
  
    CURSOR C_METER(V_NO VARCHAR2) IS
      SELECT MIID, MICOLUMN2, MIDBZJH, MIPFID
        FROM METERINFO
       WHERE MIEMAIL = V_NO;
  
    V_CLT_INFO CLT_INFO@HRBOLD%ROWTYPE;
    V_SBINFO   SBINFO@HRBOLD%ROWTYPE;
    V_METER    METERINFO%ROWTYPE;
  
  BEGIN
    NULL;
    OPEN C_HEB_DB;
    LOOP
      FETCH C_HEB_DB
        INTO V_CLT_INFO.CLT_ID, V_CLT_INFO.DESCRIPTION2, V_SBINFO.CLT_NO;
      EXIT WHEN C_HEB_DB%NOTFOUND OR C_HEB_DB%NOTFOUND IS NULL;
    
      OPEN C_METER(V_SBINFO.CLT_NO);
      LOOP
        FETCH C_METER
          INTO V_METER.MIID,
               V_METER.MICOLUMN2,
               V_METER.MIDBZJH,
               V_METER.MIPFID;
        EXIT WHEN C_METER%NOTFOUND OR C_METER%NOTFOUND IS NULL;
        IF NVL(V_METER.MICOLUMN2,'N') = 'N' AND V_METER.MIPFID = 'A0104' THEN
          UPDATE METERINFO
             SET MICOLUMN2 = 'Y', MIDBZJH = TRIM(V_CLT_INFO.DESCRIPTION2)
           WHERE MIID = V_METER.MIID;
        END IF;
      END LOOP;
      CLOSE C_METER;
    
      IF MOD(C_HEB_DB%ROWCOUNT, 100) = 0 THEN
        COMMIT;
      END IF;
    
    END LOOP;
    COMMIT;
    CLOSE C_HEB_DB;
  END ά���ͱ���־�͵ͱ�֤����;*/
  
PROCEDURE ά���������������� AS
  CURSOR C_CWSH IS
    SELECT PID, HSHDATE
      FROM PAYMENT PM, STPAYMENTCWDZREGHD A, PAY_DAILY_YXHD B
     WHERE PM.PCHKNO = B.PDDID
       AND A.HNO = B.PDHID
       AND A.HSHFLAG = 'Y';

  V_PID     PAYMENT.PID%TYPE;
  V_HSHDATE STPAYMENTCWDZREGHD.HSHDATE%TYPE;

BEGIN
  NULL;
  OPEN C_CWSH;
  LOOP
    FETCH C_CWSH
      INTO V_PID, V_HSHDATE;
    EXIT WHEN C_CWSH%NOTFOUND OR C_CWSH%NOTFOUND IS NULL;
    
    UPDATE PAYMENT SET PDZDATE = V_HSHDATE WHERE PID = V_PID;
  
    IF MOD(C_CWSH%ROWCOUNT, 100) = 0 THEN
      COMMIT;
    END IF;
  
  END LOOP;
  COMMIT;
  CLOSE C_CWSH;

END ά����������������;
  
/*PROCEDURE ά�����֤�� AS

  CURSOR C_HEB_DB IS
    SELECT C.CLT_ID, C.MST_CARD_ID, S.CLT_NO
      FROM CLT_INFO@HRBOLD C, SBINFO@HRBOLD S
     WHERE C.CLT_ID = S.CLT_ID
       AND TRIM(MST_CARD_ID) IS NOT NULL
       AND C.FLAG = '1';

  CURSOR C_METER(V_NO VARCHAR2) IS
    SELECT MIID
      FROM METERINFO
     WHERE MIEMAIL = V_NO;

  V_CLT_INFO CLT_INFO@HRBOLD%ROWTYPE;
  V_SBINFO   SBINFO@HRBOLD%ROWTYPE;
  V_METER    METERINFO%ROWTYPE;

BEGIN
  NULL;
  OPEN C_HEB_DB;
  LOOP
    FETCH C_HEB_DB
      INTO V_CLT_INFO.CLT_ID, V_CLT_INFO.MST_CARD_ID, V_SBINFO.CLT_NO;
    EXIT WHEN C_HEB_DB%NOTFOUND OR C_HEB_DB%NOTFOUND IS NULL;
  
    OPEN C_METER(V_SBINFO.CLT_NO);
    LOOP
      FETCH C_METER
        INTO V_METER.MIID;
      EXIT WHEN C_METER%NOTFOUND OR C_METER%NOTFOUND IS NULL;
      UPDATE CUSTINFO
         SET CIIDENTITYNO = TRIM(V_CLT_INFO.MST_CARD_ID)
       WHERE CIID = V_METER.MIID;
    END LOOP;
    CLOSE C_METER;
  
    IF MOD(C_HEB_DB%ROWCOUNT, 100) = 0 THEN
      COMMIT;
    END IF;
  
  END LOOP;
  COMMIT;
  CLOSE C_HEB_DB;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '֤���ţ�' || TRIM(V_CLT_INFO.MST_CARD_ID) || ':' ||
                              'ˮ��ţ�' || TRIM(V_SBINFO.CLT_NO) || SQLERRM);
END ά�����֤��;
 */
 
    --20140420 Ǩ�ƺ��Զ��ֿ�һ�Σ��Ժ����ʱ�ۻ�
PROCEDURE �Զ�Ԥ��ֿ�(V_SMFID IN VARCHAR2) AS
  CURSOR C_METER IS
    SELECT * FROM METERINFO WHERE MISMFID = V_SMFID;
   --- SELECT * FROM METERINFO WHERE miid = V_SMFID;
    
  CURSOR C_HS_METER(C_MIID VARCHAR2) IS
    SELECT MIID FROM METERINFO WHERE MIPRIID = C_MIID;

  MI         METERINFO%ROWTYPE;
  V_HS_METER METERINFO%ROWTYPE;
  V_HS_RLIDS VARCHAR2(1280); --Ӧ����ˮ
  V_HS_RLJE  NUMBER(12, 2); --Ӧ�ս��
  V_HS_ZNJ   NUMBER(12, 2); --���ɽ�
  V_HS_SXF   NUMBER(12, 2); --������
  V_HS_OUTJE NUMBER(12, 2);

  --Ԥ���Զ��ֿ�
  V_PMISAVING METERINFO.MISAVING%TYPE;
  V_PSUMRLJE  RECLIST.RLJE%TYPE;
  V_RETSTR    VARCHAR2(2000);
  V_RLIDLIST  VARCHAR2(4000);
  V_RLID      RECLIST.RLID%TYPE;
  V_RLJE      NUMBER(12, 3);
  V_ZNJ       NUMBER(12, 3);
  V_RLJES     NUMBER(12, 3);
  V_ZNJS      NUMBER(12, 3);

  CURSOR C_YCDK IS
    SELECT RLID,
           SUM(RLJE) RLJE,
           PG_EWIDE_PAY_01.GETZNJADJ(RLID,
                                     SUM(RLJE),
                                     RLGROUP,
                                     MAX(RLZNDATE),
                                     RLSMFID,
                                     TRUNC(SYSDATE)) RLZNJ
      FROM RECLIST, METERINFO T
     WHERE RLMID = T.MIID
       AND RLPAIDFLAG = 'N'
       AND RLOUTFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       AND RLJE <> 0
       AND RLTRANS NOT IN ('13','14','u','v','21')
       AND ((T.MIPRIID = MI.MIPRIID AND MI.MIPRIFLAG = 'Y') OR
           (T.MIID = MI.MIID AND
           (MI.MIPRIFLAG = 'N' OR MI.MIPRIID IS NULL)))
     GROUP BY RLMCODE, T.MIID, T.MIPRIID, RLMONTH, RLID, RLGROUP, RLSMFID
     ORDER BY RLGROUP, RLMONTH, RLID, MIPRIID, MIID;

BEGIN
  OPEN C_METER;
  LOOP
    FETCH C_METER
      INTO MI;
    EXIT WHEN C_METER%NOTFOUND OR C_METER%NOTFOUND IS NULL;
    NULL;
  
    IF MI.MIPRIID IS NOT NULL AND MI.MIPRIFLAG = 'Y' THEN
      --��Ԥ��
      V_PMISAVING := 0;
      BEGIN
/*        SELECT MISAVING
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
                (V_HS_METER.MIID, V_HS_RLIDS, V_HS_RLJE, 0, V_HS_ZNJ);
            END IF;
          END LOOP;
          CLOSE C_HS_METER;
        
          V_RLIDLIST := SUBSTR(V_RLIDLIST, 1, LENGTH(V_RLIDLIST) - 1);
          V_RETSTR   := PG_EWIDE_PAY_01.POS('02', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                            MI.MISMFID, --�ɷѻ���
                                            'SYSTEM', --�տ�Ա
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
                                          'SYSTEM', --�տ�Ա
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
  
    IF MOD(C_METER%ROWCOUNT, 100) = 0 THEN
      COMMIT;
    END IF;
  
  END LOOP;
  CLOSE C_METER;

  COMMIT;
END �Զ�Ԥ��ֿ�;
  
 
PROCEDURE ��ĩ�Զ�Ԥ��ֿ�  AS
  CURSOR C_METER IS
  ---���ںϱ�֮ǰ��Ƿ�ѣ����ºϱ��������Ԥ�治�ܽ��еֿ�
/*  SELECT mi.*
  FROM METERINFO MI,
       (select sum(rlje) RLJE, RLPRIMCODE
          from RECLIST RL
         where    rl.RLPAIDFLAG <> 'Y'
           AND RL.RLREVERSEFLAG <> 'Y'
           AND RL.RLBADFLAG <> 'Y'
           and RL.RLJE > 0
           and  RLTRANS NOT IN ('13', '14', 'u', 'v', '21')
         group by RLPRIMCODE) RLL
 WHERE MI.miid = RLL.RLPRIMCODE
   AND    mi.misaving >= rll.rlje ;*/ 
   SELECT mi.*
  FROM METERINFO MI,
       (select sum(rlje) RLJE, mii.MIPRIID 
          from RECLIST RL,METERINFO mii
         where    rl.RLMID=mii.MIID
           and rl.RLPAIDFLAG <> 'Y'
           AND RL.RLREVERSEFLAG <> 'Y'
           AND RL.RLBADFLAG <> 'Y'
           and RL.RLJE > 0
           and  RLTRANS NOT IN ('13', '14', 'u', 'v', '21')
         group by mii.MIPRIID ) RLL
 WHERE MI.miid = RLL.MIPRIID
   AND    mi.misaving >= rll.rlje ;
   --and mi.miid='3031154099';
   
/*    SELECT * FROM METERINFO WHERE miid  in (   select a.miid from (
  SELECT '1',mi.miid,  (select sum(md.MISAVING)
                            from meterinfo md
                           where md.mipriid = mi.miid   ) MISAVING ,
            (select sum(rd.rlje)
                        from reclist rd
                       where rd.rlmid in
                             (select meterinfo.miid
                                from meterinfo
                               where meterinfo.mipriid = mi.miid)
                         AND Rd.RLBADFLAG = 'N'
                         AND Rd.RLREVERSEFLAG = 'N'
                         AND Rd.RLPAIDFLAG = 'N'
                         AND Rd.RLJE <> 0)  rlje
    
      FROM RECLIST RL, meterinfo MI
     WHERE RL.RLMID = MI.MIID
       AND MI.MIPRIID = MI.MIID --��������
       AND RLTRANS NOT IN ('13','14','u','v','21')
       AND MI.MIPRIFLAG = 'Y'
       AND RL.RLBADFLAG = 'N'
       AND RL.RLREVERSEFLAG = 'N'
       AND RL.RLPAIDFLAG = 'N'
       AND RL.RLJE <> 0  
      union
       SELECT '2',mi.miid,MI.MISAVING,SUM(RL.rlje)
        FROM RECLIST RL, meterinfo MI
     WHERE RL.RLMID = MI.MIID
       AND MI.MIPRIID = MI.MIID --��������
       AND RLTRANS NOT IN ('13','14','u','v','21')
       AND MI.MIPRIFLAG = 'N'
       AND RL.RLBADFLAG = 'N'
       AND RL.RLREVERSEFLAG = 'N'
       AND RL.RLPAIDFLAG = 'N'
       AND RL.RLJE <> 0 
       GROUP BY mi.miid,MI.MISAVING
          
       ) a where a.MISAVING >= a.rlje \*and miid ='1304944905'*\ );*/
       
       --Ԥ��ֿ��������������ĩ�Զ�ִ��
       
   --- SELECT * FROM METERINFO WHERE miid = V_SMFID;
    
  CURSOR C_HS_METER(C_MIID VARCHAR2) IS
    SELECT MIID FROM METERINFO WHERE MIPRIID = C_MIID;

  MI         METERINFO%ROWTYPE;
  V_HS_METER METERINFO%ROWTYPE;
  V_HS_RLIDS VARCHAR2(1280); --Ӧ����ˮ
  V_HS_RLJE  NUMBER(12, 2); --Ӧ�ս��
  V_HS_ZNJ   NUMBER(12, 2); --���ɽ�
  V_HS_SXF   NUMBER(12, 2); --������
  V_HS_OUTJE NUMBER(12, 2);

  --Ԥ���Զ��ֿ�
  V_PMISAVING METERINFO.MISAVING%TYPE;
  V_PSUMRLJE  RECLIST.RLJE%TYPE;
  V_RETSTR    VARCHAR2(2000);
  V_RLIDLIST  VARCHAR2(4000);
  V_RLID      RECLIST.RLID%TYPE;
  V_RLJE      NUMBER(12, 3);
  V_ZNJ       NUMBER(12, 3);
  V_RLJES     NUMBER(12, 3);
  V_ZNJS      NUMBER(12, 3);

  CURSOR C_YCDK IS
    SELECT RLID,
           SUM(RLJE) RLJE,
           PG_EWIDE_PAY_01.GETZNJADJ(RLID,
                                     SUM(RLJE),
                                     RLGROUP,
                                     MAX(RLZNDATE),
                                     RLSMFID,
                                     TRUNC(SYSDATE)) RLZNJ
      FROM RECLIST, METERINFO T
     WHERE RLMID = T.MIID
       AND RLPAIDFLAG = 'N'
       AND RLBADFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       AND RLJE <> 0
       AND RLTRANS NOT IN ('13','14','u','v','21')
       AND ((T.MIPRIID = MI.MIPRIID AND MI.MIPRIFLAG = 'Y') OR
           (T.MIID = MI.MIID AND
           (MI.MIPRIFLAG = 'N' OR MI.MIPRIID IS NULL)))
     GROUP BY RLMCODE, T.MIID, T.MIPRIID, RLMONTH, RLID, RLGROUP, RLSMFID
     ORDER BY RLGROUP, RLMONTH, RLID, MIPRIID, MIID;

BEGIN
  OPEN C_METER;
  LOOP
    FETCH C_METER
      INTO MI;
    EXIT WHEN C_METER%NOTFOUND OR C_METER%NOTFOUND IS NULL;
    NULL;
  
    IF MI.MIPRIID IS NOT NULL AND MI.MIPRIFLAG = 'Y' THEN
      --��Ԥ��
      V_PMISAVING := 0;
      BEGIN
/*        SELECT MISAVING
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
            AND RLTRANS NOT IN ('13','14','u','v','21')
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
                AND RLTRANS NOT IN ('13','14','u','v','21')
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
                                            'SYSTEM', --�տ�Ա
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
                                          'SYSTEM', --�տ�Ա
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
  
    IF MOD(C_METER%ROWCOUNT, 100) = 0 THEN
      COMMIT;
    END IF;
  
  END LOOP;
  CLOSE C_METER;

  COMMIT;
END ��ĩ�Զ�Ԥ��ֿ�;


 --�Ż�20150401 hb
PROCEDURE ��ĩ�Զ�Ԥ��ֿ�_test150401  AS
  CURSOR C_METER IS
SELECT mi.*
  FROM METERINFO MI,
       (select sum(rlje) RLJE, RLPRIMCODE
          from RECLIST RL
         where /*RL.RLDATE >= TO_date('20030101', 'yyyymmdd')
           and RL.RLDATE <= TO_date('20150401', 'yyyymmdd')
           and*/  rl.RLPAIDFLAG <> 'Y'
           AND RL.RLREVERSEFLAG <> 'Y'
           AND RL.RLBADFLAG <> 'Y'
           and RL.RLJE > 0
           and rl.RLMONTH < '2015.04'  
            and rl.RLMONTH >= '2003.01' 
           and  RLTRANS NOT IN ('13', '14', 'u', 'v', '21')
         group by RLPRIMCODE) RLL
 WHERE MI.miid = RLL.RLPRIMCODE
   --and mi.miid='3120382330'
   AND    mi.misaving >= rll.rlje ;
       
       --Ԥ��ֿ��������������ĩ�Զ�ִ��
       
       
       
   --- SELECT * FROM METERINFO WHERE miid = V_SMFID;
    
  CURSOR C_HS_METER(C_MIID VARCHAR2) IS
    SELECT MIID FROM METERINFO WHERE MIPRIID = C_MIID;

  MI         METERINFO%ROWTYPE;
  V_HS_METER METERINFO%ROWTYPE;
  V_HS_RLIDS VARCHAR2(1280); --Ӧ����ˮ
  V_HS_RLJE  NUMBER(12, 2); --Ӧ�ս��
  V_HS_ZNJ   NUMBER(12, 2); --���ɽ�
  V_HS_SXF   NUMBER(12, 2); --������
  V_HS_OUTJE NUMBER(12, 2);

  --Ԥ���Զ��ֿ�
  V_PMISAVING METERINFO.MISAVING%TYPE;
  V_PSUMRLJE  RECLIST.RLJE%TYPE;
  V_RETSTR    VARCHAR2(2000);
  V_RLIDLIST  VARCHAR2(4000);
  V_RLID      RECLIST.RLID%TYPE;
  V_RLJE      NUMBER(12, 3);
  V_ZNJ       NUMBER(12, 3);
  V_RLJES     NUMBER(12, 3);
  V_ZNJS      NUMBER(12, 3);

  CURSOR C_YCDK IS
    SELECT RLID,
           SUM(RLJE) RLJE,
           PG_EWIDE_PAY_01.GETZNJADJ(RLID,
                                     SUM(RLJE),
                                     RLGROUP,
                                     MAX(RLZNDATE),
                                     RLSMFID,
                                     TRUNC(SYSDATE)) RLZNJ
      FROM RECLIST, METERINFO T
     WHERE RLMID = T.MIID
       AND RLPAIDFLAG = 'N'
       AND RLBADFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       AND RLJE <> 0
       AND RLTRANS NOT IN ('13','14','u','v','21')
       AND ((T.MIPRIID = MI.MIPRIID AND MI.MIPRIFLAG = 'Y') OR
           (T.MIID = MI.MIID AND
           (MI.MIPRIFLAG = 'N' OR MI.MIPRIID IS NULL)))
     GROUP BY RLMCODE, T.MIID, T.MIPRIID, RLMONTH, RLID, RLGROUP, RLSMFID
     ORDER BY RLGROUP, RLMONTH, RLID, MIPRIID, MIID;

BEGIN
  OPEN C_METER;
  LOOP
    FETCH C_METER
      INTO MI;
    EXIT WHEN C_METER%NOTFOUND OR C_METER%NOTFOUND IS NULL;
    NULL;
  
    IF MI.MIPRIID IS NOT NULL AND MI.MIPRIFLAG = 'Y' THEN
      --��Ԥ��
      V_PMISAVING := 0;
      BEGIN
/*        SELECT MISAVING
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
           and  RLTRANS NOT IN ('13', '14', 'u', 'v', '21')
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
                and  RLTRANS NOT IN ('13', '14', 'u', 'v', '21')
               AND RL.RLBADFLAG = 'N';
            IF V_HS_RLJE > 0 THEN
              INSERT INTO PAY_PARA_TMP
              VALUES
                (V_HS_METER.MIID, V_HS_RLIDS, V_HS_RLJE, 0, V_HS_ZNJ);
            END IF;
          END LOOP;
          CLOSE C_HS_METER;
        
          V_RLIDLIST := SUBSTR(V_RLIDLIST, 1, LENGTH(V_RLIDLIST) - 1);
          V_RETSTR   := PG_EWIDE_PAY_01.POS_test('02', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                            MI.MISMFID, --�ɷѻ���
                                            'SYSTEM', --�տ�Ա
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
        V_RETSTR   := PG_EWIDE_PAY_01.POS_test('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                          MI.MISMFID, --�ɷѻ���
                                          'SYSTEM', --�տ�Ա
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
  
    IF MOD(C_METER%ROWCOUNT, 100) = 0 THEN
      COMMIT;
    END IF;
  
  END LOOP;
  CLOSE C_METER;

  COMMIT;
END ��ĩ�Զ�Ԥ��ֿ�_test150401;

  PROCEDURE ��֤�� AS
    
    CURSOR C_OPERACCNT IS
      SELECT *  FROM OPERACCNT WHERE OAICFLAG = 'Y';
      
    V_OPER OPERACCNT%ROWTYPE;
    V_STR  VARCHAR2(10);
    
  BEGIN
    OPEN C_OPERACCNT;
    LOOP
      FETCH C_OPERACCNT
        INTO V_OPER;
      EXIT WHEN C_OPERACCNT%NOTFOUND OR C_OPERACCNT%NOTFOUND IS NULL;
      --���������
      SELECT TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(0, 10))) ||
             TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(0, 10))) ||
             TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(0, 10))) ||
             TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(0, 10))) ||
             TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(0, 10)))
        INTO V_STR
        FROM DUAL;
      --�޸���֤��
      UPDATE OPERACCNT
         SET OAIC = V_STR
       WHERE OAID = V_OPER.OAID
         AND OAICFLAG = 'Y';
    
      IF MOD(C_OPERACCNT%ROWCOUNT, 100) = 0 THEN
        COMMIT;
      END IF;
      
    END LOOP;
    COMMIT;
    CLOSE C_OPERACCNT;
    
  END ��֤��;
  
--����ˮ����鵵 �µ����ɸ������վ�̬���ݣ�CE038��������Դ
PROCEDURE ����ˮ����鵵 AS

  V_SMFID   SYSMANAFRAME%ROWTYPE;
  V_RLMONTH VARCHAR2(7);
  V_RPT     RPT_HRBZLS_RLCHARGE%ROWTYPE;

BEGIN
  --V_RLMONTH := TO_CHAR(SYSDATE, 'YYYY-MM');
  V_RLMONTH := '2014.06';

  --CE038 ��ˮ��ͳ���±���ԭʼ����
  DELETE RPT_HRBZLS_RLCHARGE WHERE RLMONTH = V_RLMONTH;
  COMMIT;
  INSERT INTO RPT_HRBZLS_RLCHARGE
    SELECT OFAGENT Ӫҵ��,
           U_MONTH �����·�,
           T19 ������Ŀ,
           T20 �������,
           NVL(SUM(M11), 0) ����ˮ�Ѽ���,
           NVL(SUM(M15), 0) ����ˮ��ˮ��,
           NVL(SUM(M13), 0) ����ˮ�Ѽ���,
           NVL(SUM(M16), 0) ����ˮ��ˮ��,
           NVL(SUM(M21), 0) ������ˮ����,
           NVL(SUM(M25), 0) ������ˮˮ��,
           NVL(SUM(M23), 0) ������ˮ����,
           NVL(SUM(M26), 0) ������ˮˮ��,
           MAX(case when X37 > 0 then p4 else  0 end) ˮ�ѵ���,
           NVL(SUM(X37), 0) ˮ��,
           MAX(case when x38 > 0 then p5 else  0 end) ��ˮ�ѵ���,
           NVL(SUM(X38), 0) ��ˮ��,
           MAX(case when x39 > 0 then p6 else  0 end ) ���ӷѵ���,
           NVL(SUM(X39), 0) ���ӷ�,
           'N' �Ƿ�鵵,
          NVL(SUM(M7), 0)  ����ˮ������ ,
          NVL(SUM(M8), 0)  ����ˮ������,
          NVL(SUM(M9), 0)  ����������� ,
          NVL(SUM(M10), 0)  �����������,
          NVL(SUM(M17), 0)  ������ˮ������ ,
          NVL(SUM(M18), 0) ������ˮ������,
          NVL(SUM(M19), 0) ������ˮ�������� ,
           NVL(SUM(M20), 0) ������ˮ��������,null
      FROM RPT_SUM_DETAIL 
     WHERE U_MONTH = V_RLMONTH and T20<>'����'
     GROUP BY OFAGENT, U_MONTH, T19, T20
     ORDER BY OFAGENT, U_MONTH, T19, T20;
  COMMIT;
  INSERT INTO RPT_HRBZLS_RLCHARGE
    SELECT OFAGENT Ӫҵ��,
           U_MONTH �����·�,
           T19 ������Ŀ,
           T20 �������,
           NVL(SUM(M11), 0) ����ˮ�Ѽ���,
           NVL(SUM(M15), 0) ����ˮ��ˮ��,
           NVL(SUM(M13), 0) ����ˮ�Ѽ���,
           NVL(SUM(M16), 0) ����ˮ��ˮ��,
           NVL(SUM(M21), 0) ������ˮ����,
           NVL(SUM(M25), 0) ������ˮˮ��,
           NVL(SUM(M23), 0) ������ˮ����,
           NVL(SUM(M26), 0) ������ˮˮ��,
           MAX(case when X37 > 0 then p4 else  0 end) ˮ�ѵ���,
           NVL(SUM(X37), 0) ˮ��,
           MAX(case when x38 > 0 then p5 else  0 end) ��ˮ�ѵ���,
           NVL(SUM(X38), 0) ��ˮ��,
           MAX(case when x39 > 0 then p6 else  0 end ) ���ӷѵ���,
           NVL(SUM(X39), 0) ���ӷ�,
           'N' �Ƿ�鵵,
          NVL(SUM(M7), 0)  ����ˮ������ ,
          NVL(SUM(M8), 0)  ����ˮ������,
          NVL(SUM(M9), 0)  ����������� ,
          NVL(SUM(M10), 0)  �����������,
          NVL(SUM(M17), 0)  ������ˮ������ ,
          NVL(SUM(M18), 0) ������ˮ������,
          NVL(SUM(M19), 0) ������ˮ�������� ,
           NVL(SUM(M20), 0) ������ˮ��������,'����'
      FROM RPT_SUM_DETAIL
     WHERE U_MONTH = V_RLMONTH    and T20='����' and watertype_b='A' AND T19<>'����'
     GROUP BY OFAGENT, U_MONTH, T19, T20
     ORDER BY OFAGENT, U_MONTH, T19, T20;
  COMMIT;
  INSERT INTO RPT_HRBZLS_RLCHARGE
    SELECT OFAGENT Ӫҵ��,
           U_MONTH �����·�,
           T19 ������Ŀ,
           T20 �������,
           NVL(SUM(M11), 0) ����ˮ�Ѽ���,
           NVL(SUM(M15), 0) ����ˮ��ˮ��,
           NVL(SUM(M13), 0) ����ˮ�Ѽ���,
           NVL(SUM(M16), 0) ����ˮ��ˮ��,
           NVL(SUM(M21), 0) ������ˮ����,
           NVL(SUM(M25), 0) ������ˮˮ��,
           NVL(SUM(M23), 0) ������ˮ����,
           NVL(SUM(M26), 0) ������ˮˮ��,
           MAX(case when X37 > 0 then p4 else  0 end) ˮ�ѵ���,
           NVL(SUM(X37), 0) ˮ��,
           MAX(case when x38 > 0 then p5 else  0 end) ��ˮ�ѵ���,
           NVL(SUM(X38), 0) ��ˮ��,
           MAX(case when x39 > 0 then p6 else  0 end ) ���ӷѵ���,
           NVL(SUM(X39), 0) ���ӷ�,
           'N' �Ƿ�鵵,
          NVL(SUM(M7), 0)  ����ˮ������ ,
          NVL(SUM(M8), 0)  ����ˮ������,
          NVL(SUM(M9), 0)  ����������� ,
          NVL(SUM(M10), 0)  �����������,
          NVL(SUM(M17), 0)  ������ˮ������ ,
          NVL(SUM(M18), 0) ������ˮ������,
          NVL(SUM(M19), 0) ������ˮ�������� ,
           NVL(SUM(M20), 0) ������ˮ��������,'�Ǿ���'
      FROM RPT_SUM_DETAIL
     WHERE U_MONTH = V_RLMONTH    and T20='����' and watertype_b<>'A' AND T19<>'����'
     GROUP BY OFAGENT, U_MONTH, T19, T20
     ORDER BY OFAGENT, U_MONTH, T19, T20;
  COMMIT;
  INSERT INTO RPT_HRBZLS_RLCHARGE
    SELECT OFAGENT Ӫҵ��,
           U_MONTH �����·�,
           T19 ������Ŀ,
           T20 �������,
           NVL(SUM(M11), 0) ����ˮ�Ѽ���,
           NVL(SUM(M15), 0) ����ˮ��ˮ��,
           NVL(SUM(M13), 0) ����ˮ�Ѽ���,
           NVL(SUM(M16), 0) ����ˮ��ˮ��,
           NVL(SUM(M21), 0) ������ˮ����,
           NVL(SUM(M25), 0) ������ˮˮ��,
           NVL(SUM(M23), 0) ������ˮ����,
           NVL(SUM(M26), 0) ������ˮˮ��,
           MAX(case when X37 > 0 then p4 else  0 end) ˮ�ѵ���,
           NVL(SUM(X37), 0) ˮ��,
           MAX(case when x38 > 0 then p5 else  0 end) ��ˮ�ѵ���,
           NVL(SUM(X38), 0) ��ˮ��,
           MAX(case when x39 > 0 then p6 else  0 end ) ���ӷѵ���,
           NVL(SUM(X39), 0) ���ӷ�,
           'N' �Ƿ�鵵,
          NVL(SUM(M7), 0)  ����ˮ������ ,
          NVL(SUM(M8), 0)  ����ˮ������,
          NVL(SUM(M9), 0)  ����������� ,
          NVL(SUM(M10), 0)  �����������,
          NVL(SUM(M17), 0)  ������ˮ������ ,
          NVL(SUM(M18), 0) ������ˮ������,
          NVL(SUM(M19), 0) ������ˮ�������� ,
           NVL(SUM(M20), 0) ������ˮ��������,null
      FROM RPT_SUM_DETAIL
     WHERE U_MONTH = V_RLMONTH    and T20='����'  AND T19='����'
     GROUP BY OFAGENT, U_MONTH, T19, T20
     ORDER BY OFAGENT, U_MONTH, T19, T20;
  COMMIT;
  --ͬ��CE038�༭����
  DELETE RPT_HRBZLS_RLCHARGENEW WHERE RLMONTH = V_RLMONTH;
  COMMIT;
  INSERT INTO RPT_HRBZLS_RLCHARGENEW
    SELECT t.* FROM RPT_HRBZLS_RLCHARGE T WHERE T.RLMONTH = V_RLMONTH;
  COMMIT;

END ����ˮ����鵵;

--����ˮ����鵵 �µ����ɸ������վ�̬���ݣ�CE038��������Դ
/*-------------------------------------------------------------------------
�޸�˵����ԭ������Ҫ��JOB��ִ�к󣬲��ܴӿͻ����ϲ�ѯ����,�ָ�Ϊֱ���ڿͻ����������м����ݣ���������
ҵ��Ҫ��˵����
    1���������Ǹ������ֹ�˾�޸���ˮ�������ݺ����ϱ���
    2��ִ�б����̺󣬴��м��RPT_SUM_DETAIL����������ͳ�Ƶ�RPT_HRBZLS_RLCHARGE������
    3��������Ҫ���µ���ˮ��������ͳ�Ƶ��м��RPT_SUM_DETAIL�󣬱�����ִ�в���Ч
    4������ԭ�����˼·�������ݹ��ɵ�RPT_HRBZLS_RLCHARGE����ͨ���ͻ����޸����ͳ�����ݡ�
       �޸ĺ��ͳ�����ݱ��浽RPT_HRBZLS_RLCHARGE�������Ժ��ٳ���ر����ϱ�

������ݿ����˵����
    1����ͼV_���޸���ˮ���м�����Ǵ�RPT_SUM_DETAIL ��  RPT_HRBZLS_RLCHARGE �Ĺ�ϵӳ��
    2��ÿ��ֱ�Ӵ���ͼ�����ݲ��뵽RPT_HRBZLS_RLCHARGE����, �ڰ����̣����ۺ��±����б�����
-------------------------------------------------------------------------*/
PROCEDURE ����ˮ����鵵_1(P_MOUTH IN VARCHAR2) AS

  --V_SMFID   SYSMANAFRAME%ROWTYPE;
  V_RLMONTH VARCHAR2(7);

  --V_RPT     RPT_HRBZLS_RLCHARGE%ROWTYPE;

BEGIN
  --V_RLMONTH := TO_CHAR(SYSDATE, 'YYYY-MM');
  V_RLMONTH := P_MOUTH;
  

     
  --CE038 ��ˮ��ͳ���±���ԭʼ����
  DELETE RPT_HRBZLS_RLCHARGE S
   WHERE S.RLMONTH = V_RLMONTH;
  COMMIT;
  
  INSERT INTO RPT_HRBZLS_RLCHARGE
    SELECT s.* 
      FROM V_���޸���ˮ���м�� S
     WHERE S.�����·� = V_RLMONTH;
  COMMIT;
	
	--�޸Ļ�������(��ʵ����)
	update RPT_HRBZLS_RLCHARGE rpt
	   set rpt.rlnum = PG_EWIDE_JOB_HRB2.f_getAllotNumber(rlsmfid,rlmonth),
		     rpt.rlsl = PG_EWIDE_JOB_HRB2.f_getAllotSl(rlsmfid,rlmonth),
				 rpt.rljsje = PG_EWIDE_JOB_HRB2.f_getAllotMoney(rlsmfid,rlmonth)
	 where rlmonth = V_RLMONTH and 
	       rlrfname = '����';

  --ͬ��CE038�༭����
  DELETE RPT_HRBZLS_RLCHARGENEW S
   WHERE S.RLMONTH = V_RLMONTH;
  COMMIT;
  
  INSERT INTO RPT_HRBZLS_RLCHARGENEW T
    SELECT s.* FROM RPT_HRBZLS_RLCHARGE S 
     WHERE S.RLMONTH = V_RLMONTH;
  COMMIT;

END ����ˮ����鵵_1;
------------------------------------------------------------------------------------------
  --��4.8Сʱ������ˮ����鵵 �µ����ɸ������վ�̬���ݣ�CE038��������Դ
  PROCEDURE ����ˮ����鵵_old AS
    CURSOR C_SMFID IS
      SELECT SMFID
        FROM SYSMANAFRAME
       WHERE SMFPID = '02'
         AND SMFCLASS = '2'
       ORDER BY SMFID;
  
    V_SMFID   SYSMANAFRAME%ROWTYPE;
    V_RLMONTH VARCHAR2(7);
    V_RPT     RPT_HRBZLS_RLCHARGE%ROWTYPE;
  
  BEGIN
    OPEN C_SMFID;
    LOOP
      FETCH C_SMFID
        INTO V_SMFID.SMFID;
      EXIT WHEN C_SMFID%NOTFOUND OR C_SMFID%NOTFOUND IS NULL;
      NULL;
      --��ȡӪҵ������Ӧ�������·�
      --V_RLMONTH := TOOLS.FGETRECMONTH(V_SMFID.SMFID);
      V_RLMONTH := '2014.02';
    
      /*
      * CE038 ��ˮ��ͳ���±���ԭʼ����
      */
      DELETE RPT_HRBZLS_RLCHARGE
       WHERE RLSMFID = V_SMFID.SMFID
         AND RLMONTH = V_RLMONTH;
      COMMIT;
    
      --�������ݣ�
      V_RPT         := NULL;
      V_RPT.RLSMFID := V_SMFID.SMFID;
      V_RPT.RLMONTH := V_RLMONTH;
    
      --ˮվ
      SELECT 'ˮվ' RLRFNAME,
             '����' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '1'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID = 'A03';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --����
      SELECT '�ͱ�' RLRFNAME,
             '����' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '1'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID = 'A0104';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --������ˮ
      SELECT '������ˮ' RLRFNAME,
             '����' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '1'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID NOT IN ('A03', 'A0104')
         AND RL.RLPFID LIKE 'A%';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --����ҵ
      SELECT '����ҵ' RLRFNAME,
             '�Ǿ���' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '1'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID IN (SELECT T1.PDPFID
                             FROM PRICEDETAIL T1, PRICEFRAME T2
                            WHERE T1.PDPFID = T2.PFID
                              AND PFFLAG = 'Y'
                              AND T1.PDPFID LIKE 'B%'
                              AND T1.PDPIID = '01'
                              AND T1.PDDJ = '4.3')
         AND RL.RLPFID LIKE 'B%';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --ѧУ
      SELECT 'ѧУ' RLRFNAME,
             '�Ǿ���' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '1'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID IN (SELECT T1.PDPFID
                             FROM PRICEDETAIL T1, PRICEFRAME T2
                            WHERE T1.PDPFID = T2.PFID
                              AND PFFLAG = 'Y'
                              AND T1.PDPFID LIKE 'B%'
                              AND T1.PDPIID = '01'
                              AND T1.PDDJ = '2.4')
         AND RL.RLPFID LIKE 'B%';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --��������ҵ
      SELECT '��������ҵ' RLRFNAME,
             '�Ǿ���' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '1'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID IN
             (SELECT T1.PDPFID
                FROM PRICEDETAIL T1, PRICEFRAME T2
               WHERE T1.PDPFID = T2.PFID
                 AND PFFLAG = 'Y'
                 AND T1.PDPFID LIKE 'B%'
                 AND T1.PDPIID = '01'
                 AND T1.PDDJ NOT IN ('4.3', '2.4'))
         AND RL.RLPFID LIKE 'B%';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --����ˮ��
      SELECT '����ˮ��' RLRFNAME,
             '�Ǿ���' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '1'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID = 'B040101';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --�̷�ҵ
      SELECT '�̷�ҵ' RLRFNAME,
             '�Ǿ���' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '1'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID LIKE 'C%';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --���ݲ���
      SELECT '���ݲ���' RLRFNAME,
             '�Ǿ���' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '1'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID LIKE 'D%';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --����
      SELECT '�����Ǿ���' RLRFNAME,
             '�Ǿ���' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '1'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID IN (SELECT T1.PDPFID
                             FROM PRICEDETAIL T1, PRICEFRAME T2
                            WHERE T1.PDPFID = T2.PFID
                              AND PFFLAG = 'Y'
                              AND T1.PDPFID LIKE 'E%'
                              AND T1.PDPIID = '01'
                              AND T1.PDDJ = '4.3')
         AND RL.RLPFID LIKE 'E%';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --��ҵ1
      SELECT '��ҵ1' RLRFNAME,
             '��ҵ' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '1'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID IN (SELECT T1.PDPFID
                             FROM PRICEDETAIL T1, PRICEFRAME T2
                            WHERE T1.PDPFID = T2.PFID
                              AND PFFLAG = 'Y'
                              AND T1.PDPFID LIKE 'E%'
                              AND T1.PDPIID = '01'
                              AND T1.PDDJ = '10')
         AND RL.RLPFID LIKE 'E%';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --��ҵ2
      SELECT '��ҵ2' RLRFNAME,
             '��ҵ' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '1'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID IN (SELECT T1.PDPFID
                             FROM PRICEDETAIL T1, PRICEFRAME T2
                            WHERE T1.PDPFID = T2.PFID
                              AND PFFLAG = 'Y'
                              AND T1.PDPFID LIKE 'E%'
                              AND T1.PDPIID = '01'
                              AND T1.PDDJ = '16.4')
         AND RL.RLPFID LIKE 'E%';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --���⣨ͳ���ܼ�ʱ�ų���
      SELECT '����' RLRFNAME,
             '����' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    (RL.RLREADSL - RL.RLSL)
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    (RL.RLREADSL - RL.RLSL)
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '1'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%') --AND RLCSTATUS<>'7'
         AND RL.RLCID IN (SELECT PALCID
                            FROM PRICEADJUSTLIST T
                           WHERE PALTACTIC = '02'
                             AND PALWAY = '-1');
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --����
      SELECT '����' RLRFNAME,
             '����' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS IN ('u', 'v')
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%'); --AND RLCSTATUS<>'7'
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --����
      SELECT '����' RLRFNAME,
             '����' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --����������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --ˮ��������
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --���������ˣ�
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --ˮ�������ˣ�
             MAX(RD.DJ1) DJ1, --��ˮ�ѵ���
             SUM(RD.CHARGE1) CHARGE1, --��ˮ��
             MAX(RD.DJ2) DJ2, --��ˮ�ѵ���
             SUM(RD.CHARGE2) CHARGE2, --��ˮ��
             MAX(RD.DJ3) DJ3, --���ӷѵ���
             SUM(RD.CHARGE3) CHARGE3 --���ӷ�
        INTO V_RPT.RLRFNAME,
             V_RPT.RLTYPE,
             V_RPT.RLNUM,
             V_RPT.RLSL,
             V_RPT.RLNUMMC,
             V_RPT.RLSLMC,
             V_RPT.RLJSDJ,
             V_RPT.RLJSJE,
             V_RPT.RLWSDJ,
             V_RPT.RLWSJE,
             V_RPT.RLFJDJ,
             V_RPT.RLFJJE
        FROM RECLIST RL, METERINFO MI, VIEW_RECLIST_CHARGE RD, PAYMENT PM
       WHERE RL.RLCID = MI.MIID
         AND RL.RLID = RD.RDID
         AND RL.RLPID = PM.PID
         AND PM.PMONTH = V_RLMONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = V_RLMONTH
         AND RL.RLSMFID = V_SMFID.SMFID
         AND RL.RLTRANS = '13'
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '����%'); --AND RLCSTATUS<>'7'
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
    END LOOP;
    CLOSE C_SMFID;
    COMMIT;
  
    --ͬ��CE038�༭����
    DELETE RPT_HRBZLS_RLCHARGENEW WHERE RLMONTH = V_RLMONTH;
    INSERT INTO RPT_HRBZLS_RLCHARGENEW
      SELECT t.* FROM RPT_HRBZLS_RLCHARGE T WHERE T.RLMONTH = V_RLMONTH;
    COMMIT;
  
  END ����ˮ����鵵_old;


END;
/

