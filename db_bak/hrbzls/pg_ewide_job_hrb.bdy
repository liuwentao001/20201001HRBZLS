CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_JOB_HRB" AS

  ---------------------------------------------------
  --正式运行时，每月倒数第二天执行完自动抄表月结和账务月结后立即自动做下个月的月初
  ---------------------------------------------------
  --月初处理  --188690 --耗时30 分钟
  PROCEDURE 月初处理 AS
    CURSOR C_SMFID IS

           SELECT SMFID
        FROM SYSMANAFRAME
       WHERE SMFPID = '02'
         AND SMFCLASS = '2'  
         and ((( SMFID <> '0201' and SMFID <> '0209' ) and  to_char( Last_day(sysdate)  - 1,'yyyy.mm') = '2015.06' ) or to_char( Last_day(sysdate)  - 1,'yyyy.mm') <> '2015.06'  ) 
       ORDER BY SMFID;
   --陈娜  修改日期：2015.06.26  原因：道里调整帐卡号7月份不生成抄表计划   提出人：仲伟 
   
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
      --获取营业所当前数据服务器时间对应的账务月份，即本期抄表月份

         V_READMONTH := TOOLS.FGETREADMONTH(V_SMFID.SMFID);
     
    
      OPEN C_BFID(TRIM(V_SMFID.SMFID), TRIM(V_READMONTH));
      LOOP
        FETCH C_BFID
          INTO V_BFID.BFID;
        EXIT WHEN C_BFID%NOTFOUND OR C_BFID%NOTFOUND IS NULL;
      
        --调用过程做月初处理
        ---by 陈娜  修改日期：2015.06.26  原因：道里调整帐卡号7月份不生成抄表计划   提出人：仲伟 
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
  
  END 月初处理;
	
	--月初处理(测试版)
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
          --生成抄表计划......
          begin
            PG_EWIDE_RAEDPLAN_01.CREATEMR2(rec_smf.smfid,
                                           V_READMONTH,
                                           null);
            insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'月初.生成抄表计划',sysdate,'1','营业所[' || rec_smf.smfid || ']生成抄表计划完成!');
            commit;
          exception
            when others then
              rollback;
              v_msg := '营业所[' || rec_smf.smfid || ']生成抄表计划失败!错误信息:' || sqlerrm;
              insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
              values(SEQ_JOB_RUNNING_LOG.Nextval,'月初.生成抄表计划',sysdate,'1', v_msg);
              commit;
          end;    
       --end loop;
    end loop;   
  end;

  --抄表月结，只用做一个JOB自动依次执行抄表月结，账务月结，月初处理
  PROCEDURE 抄表月结 AS
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
    --在此判断抄表月结标志是否已经执行
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
      --获取营业所当前数据服务器时间对应的账务月份，即本期抄表月份
      V_READMONTH := TOOLS.FGETREADMONTH(V_SMFID.SMFID);
      --调用过程做月终处理
      PG_EWIDE_RAEDPLAN_01.CARRYFORWARD_MR(V_SMFID.SMFID,
                                           V_READMONTH,
                                           'SYSTEM',
                                           'Y');
    END LOOP;
    CLOSE C_SMFID;
    
    --抄表月结成功后，置运行结束标志，禁止本月再次运行该过程
    UPDATE  syspara t
    SET t.spvalue = 'Y'
    where t.spid='YJBZ';    
    
    COMMIT;

  EXCEPTION
 /*    WHEN RUNOVER THEN*/
       
     WHEN OTHERS THEN  
       ROLLBACK;
  END 抄表月结;

  --账务月结
  PROCEDURE 账务月结 AS
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
      --获取营业所本期应收帐务月份
      V_RLMONTH := TOOLS.FGETRECMONTH(V_SMFID.SMFID);
      --调用过程做月终处理
      PG_EWIDE_RAEDPLAN_01.CARRYFORPAY_MR(V_SMFID.SMFID,
                                          V_RLMONTH,
                                          'SYSTEM',
                                          'Y');
    END LOOP;
    CLOSE C_SMFID;
    COMMIT;
    --账务月结后自动执行月初处理
    BEGIN
      NULL;
      --PG_EWIDE_JOB_HRB.月初处理;
    END;
  END 账务月结;
/*------------------------------------------------------------------
过程名：自动算费（包含自动预存抵扣）
参数: 无
功能：后台自动批量算费，同时进行预存抵扣
-------------------------------------------------------------------*/  
  PROCEDURE 自动算费 AS
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
      --调用过程做按表册自动算费
      PG_EWIDE_METERREAD_01.SUBMIT(V_BFID);
    END LOOP;
    CLOSE C_BOOK;
    COMMIT;
  END 自动算费;
  
    --20140503 维护银行历史实收对账日期
 PROCEDURE 维护银行历史实收对账日期 AS
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
 
  --20140503 维护历史银行缴费机构
 PROCEDURE 维护历史银行缴费机构 AS
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
 
/*  PROCEDURE 维护低保标志和低保证件号 AS
  
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
  END 维护低保标志和低保证件号;*/
  
PROCEDURE 维护财务对账审核日期 AS
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

END 维护财务对账审核日期;
  
/*PROCEDURE 维护身份证号 AS

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
                              '证件号：' || TRIM(V_CLT_INFO.MST_CARD_ID) || ':' ||
                              '水表号：' || TRIM(V_SBINFO.CLT_NO) || SQLERRM);
END 维护身份证号;
 */
 
    --20140420 迁移后自动抵扣一次，以后算费时扣划
PROCEDURE 自动预存抵扣(V_SMFID IN VARCHAR2) AS
  CURSOR C_METER IS
    SELECT * FROM METERINFO WHERE MISMFID = V_SMFID;
   --- SELECT * FROM METERINFO WHERE miid = V_SMFID;
    
  CURSOR C_HS_METER(C_MIID VARCHAR2) IS
    SELECT MIID FROM METERINFO WHERE MIPRIID = C_MIID;

  MI         METERINFO%ROWTYPE;
  V_HS_METER METERINFO%ROWTYPE;
  V_HS_RLIDS VARCHAR2(1280); --应收流水
  V_HS_RLJE  NUMBER(12, 2); --应收金额
  V_HS_ZNJ   NUMBER(12, 2); --滞纳金
  V_HS_SXF   NUMBER(12, 2); --手续费
  V_HS_OUTJE NUMBER(12, 2);

  --预存自动抵扣
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
      --总预存
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
    
      --总欠费
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
        --合收表
        V_RLIDLIST := '';
        V_RLJES    := 0;
        V_ZNJ      := 0;
      
        OPEN C_YCDK;
        LOOP
          FETCH C_YCDK
            INTO V_RLID, V_RLJE, V_ZNJ;
          EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
          --预存够扣
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
        
          --插入PAY_PARA_TMP 表做合收表销账准备
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
          V_RETSTR   := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                            MI.MISMFID, --缴费机构
                                            'SYSTEM', --收款员
                                            V_RLIDLIST || '|', --应收流水串
                                            NVL(V_RLJES, 0), --应收总金额
                                            NVL(V_ZNJS, 0), --销帐违约金
                                            0, --手续费
                                            0, --实际收款
                                            PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                            MI.MIPRIID, --水表资料号
                                            'XJ', --付款方式
                                            MI.MISMFID, --缴费地点
                                            FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                            'N', --是否打票  Y 打票，N不打票， R 应收票
                                            NULL, --发票号
                                            'N' --控制是否提交（Y/N）
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
        --预存够扣
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
      --单表
      IF LENGTH(V_RLIDLIST) > 0 THEN
        V_RLIDLIST := SUBSTR(V_RLIDLIST, 1, LENGTH(V_RLIDLIST) - 1);
        V_RETSTR   := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                          MI.MISMFID, --缴费机构
                                          'SYSTEM', --收款员
                                          V_RLIDLIST || '|', --应收流水串
                                          NVL(V_RLJES, 0), --应收总金额
                                          NVL(V_ZNJS, 0), --销帐违约金
                                          0, --手续费
                                          0, --实际收款
                                          PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                          MI.MIID, --水表资料号
                                          'XJ', --付款方式
                                          MI.MISMFID, --缴费地点
                                          FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                          'N', --是否打票  Y 打票，N不打票， R 应收票
                                          NULL, --发票号
                                          'N' --控制是否提交（Y/N）
                                          );
      END IF;
    END IF;
  
    IF MOD(C_METER%ROWCOUNT, 100) = 0 THEN
      COMMIT;
    END IF;
  
  END LOOP;
  CLOSE C_METER;

  COMMIT;
END 自动预存抵扣;
  
 
PROCEDURE 月末自动预存抵扣  AS
  CURSOR C_METER IS
  ---由于合表之前有欠费，导致合表后主表有预存不能进行抵扣
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
       AND MI.MIPRIID = MI.MIID --合收主表
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
       AND MI.MIPRIID = MI.MIID --合收主表
       AND RLTRANS NOT IN ('13','14','u','v','21')
       AND MI.MIPRIFLAG = 'N'
       AND RL.RLBADFLAG = 'N'
       AND RL.RLREVERSEFLAG = 'N'
       AND RL.RLPAIDFLAG = 'N'
       AND RL.RLJE <> 0 
       GROUP BY mi.miid,MI.MISAVING
          
       ) a where a.MISAVING >= a.rlje \*and miid ='1304944905'*\ );*/
       
       --预存抵扣有问题的资料月末自动执行
       
   --- SELECT * FROM METERINFO WHERE miid = V_SMFID;
    
  CURSOR C_HS_METER(C_MIID VARCHAR2) IS
    SELECT MIID FROM METERINFO WHERE MIPRIID = C_MIID;

  MI         METERINFO%ROWTYPE;
  V_HS_METER METERINFO%ROWTYPE;
  V_HS_RLIDS VARCHAR2(1280); --应收流水
  V_HS_RLJE  NUMBER(12, 2); --应收金额
  V_HS_ZNJ   NUMBER(12, 2); --滞纳金
  V_HS_SXF   NUMBER(12, 2); --手续费
  V_HS_OUTJE NUMBER(12, 2);

  --预存自动抵扣
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
      --总预存
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
    
      --总欠费
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
        --合收表
        V_RLIDLIST := '';
        V_RLJES    := 0;
        V_ZNJ      := 0;
      
        OPEN C_YCDK;
        LOOP
          FETCH C_YCDK
            INTO V_RLID, V_RLJE, V_ZNJ;
          EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
          --预存够扣
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
        
          --插入PAY_PARA_TMP 表做合收表销账准备
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
          V_RETSTR   := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                            MI.MISMFID, --缴费机构
                                            'SYSTEM', --收款员
                                            V_RLIDLIST || '|', --应收流水串
                                            NVL(V_RLJES, 0), --应收总金额
                                            NVL(V_ZNJS, 0), --销帐违约金
                                            0, --手续费
                                            0, --实际收款
                                            PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                            MI.MIPRIID, --水表资料号
                                            'XJ', --付款方式
                                            MI.MISMFID, --缴费地点
                                            FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                            'N', --是否打票  Y 打票，N不打票， R 应收票
                                            NULL, --发票号
                                            'N' --控制是否提交（Y/N）
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
        --预存够扣
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
      --单表
      IF LENGTH(V_RLIDLIST) > 0 THEN
        V_RLIDLIST := SUBSTR(V_RLIDLIST, 1, LENGTH(V_RLIDLIST) - 1);
        V_RETSTR   := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                          MI.MISMFID, --缴费机构
                                          'SYSTEM', --收款员
                                          V_RLIDLIST || '|', --应收流水串
                                          NVL(V_RLJES, 0), --应收总金额
                                          NVL(V_ZNJS, 0), --销帐违约金
                                          0, --手续费
                                          0, --实际收款
                                          PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                          MI.MIID, --水表资料号
                                          'XJ', --付款方式
                                          MI.MISMFID, --缴费地点
                                          FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                          'N', --是否打票  Y 打票，N不打票， R 应收票
                                          NULL, --发票号
                                          'N' --控制是否提交（Y/N）
                                          );
      END IF;
    END IF;
  
    IF MOD(C_METER%ROWCOUNT, 100) = 0 THEN
      COMMIT;
    END IF;
  
  END LOOP;
  CLOSE C_METER;

  COMMIT;
END 月末自动预存抵扣;


 --优化20150401 hb
PROCEDURE 月末自动预存抵扣_test150401  AS
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
       
       --预存抵扣有问题的资料月末自动执行
       
       
       
   --- SELECT * FROM METERINFO WHERE miid = V_SMFID;
    
  CURSOR C_HS_METER(C_MIID VARCHAR2) IS
    SELECT MIID FROM METERINFO WHERE MIPRIID = C_MIID;

  MI         METERINFO%ROWTYPE;
  V_HS_METER METERINFO%ROWTYPE;
  V_HS_RLIDS VARCHAR2(1280); --应收流水
  V_HS_RLJE  NUMBER(12, 2); --应收金额
  V_HS_ZNJ   NUMBER(12, 2); --滞纳金
  V_HS_SXF   NUMBER(12, 2); --手续费
  V_HS_OUTJE NUMBER(12, 2);

  --预存自动抵扣
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
      --总预存
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
    
      --总欠费
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
        --合收表
        V_RLIDLIST := '';
        V_RLJES    := 0;
        V_ZNJ      := 0;
      
        OPEN C_YCDK;
        LOOP
          FETCH C_YCDK
            INTO V_RLID, V_RLJE, V_ZNJ;
          EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
          --预存够扣
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
        
          --插入PAY_PARA_TMP 表做合收表销账准备
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
          V_RETSTR   := PG_EWIDE_PAY_01.POS_test('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                            MI.MISMFID, --缴费机构
                                            'SYSTEM', --收款员
                                            V_RLIDLIST || '|', --应收流水串
                                            NVL(V_RLJES, 0), --应收总金额
                                            NVL(V_ZNJS, 0), --销帐违约金
                                            0, --手续费
                                            0, --实际收款
                                            PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                            MI.MIPRIID, --水表资料号
                                            'XJ', --付款方式
                                            MI.MISMFID, --缴费地点
                                            FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                            'N', --是否打票  Y 打票，N不打票， R 应收票
                                            NULL, --发票号
                                            'N' --控制是否提交（Y/N）
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
        --预存够扣
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
      --单表
      IF LENGTH(V_RLIDLIST) > 0 THEN
        V_RLIDLIST := SUBSTR(V_RLIDLIST, 1, LENGTH(V_RLIDLIST) - 1);
        V_RETSTR   := PG_EWIDE_PAY_01.POS_test('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                          MI.MISMFID, --缴费机构
                                          'SYSTEM', --收款员
                                          V_RLIDLIST || '|', --应收流水串
                                          NVL(V_RLJES, 0), --应收总金额
                                          NVL(V_ZNJS, 0), --销帐违约金
                                          0, --手续费
                                          0, --实际收款
                                          PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                          MI.MIID, --水表资料号
                                          'XJ', --付款方式
                                          MI.MISMFID, --缴费地点
                                          FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                          'N', --是否打票  Y 打票，N不打票， R 应收票
                                          NULL, --发票号
                                          'N' --控制是否提交（Y/N）
                                          );
      END IF;
    END IF;
  
    IF MOD(C_METER%ROWCOUNT, 100) = 0 THEN
      COMMIT;
    END IF;
  
  END LOOP;
  CLOSE C_METER;

  COMMIT;
END 月末自动预存抵扣_test150401;

  PROCEDURE 验证码 AS
    
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
      --产生随机码
      SELECT TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(0, 10))) ||
             TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(0, 10))) ||
             TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(0, 10))) ||
             TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(0, 10))) ||
             TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(0, 10)))
        INTO V_STR
        FROM DUAL;
      --修改验证码
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
    
  END 验证码;
  
--月售水情况归档 月底生成各区回收静态数据，CE038报表数据源
PROCEDURE 月售水情况归档 AS

  V_SMFID   SYSMANAFRAME%ROWTYPE;
  V_RLMONTH VARCHAR2(7);
  V_RPT     RPT_HRBZLS_RLCHARGE%ROWTYPE;

BEGIN
  --V_RLMONTH := TO_CHAR(SYSDATE, 'YYYY-MM');
  V_RLMONTH := '2014.06';

  --CE038 售水量统计月报表原始数据
  DELETE RPT_HRBZLS_RLCHARGE WHERE RLMONTH = V_RLMONTH;
  COMMIT;
  INSERT INTO RPT_HRBZLS_RLCHARGE
    SELECT OFAGENT 营业所,
           U_MONTH 账务月份,
           T19 费用项目,
           T20 费用类别,
           NVL(SUM(M11), 0) 按表水费件数,
           NVL(SUM(M15), 0) 按表水费水量,
           NVL(SUM(M13), 0) 按人水费件数,
           NVL(SUM(M16), 0) 按人水费水量,
           NVL(SUM(M21), 0) 按表污水件数,
           NVL(SUM(M25), 0) 按表污水水量,
           NVL(SUM(M23), 0) 按人污水件数,
           NVL(SUM(M26), 0) 按人污水水量,
           MAX(case when X37 > 0 then p4 else  0 end) 水费单价,
           NVL(SUM(X37), 0) 水费,
           MAX(case when x38 > 0 then p5 else  0 end) 污水费单价,
           NVL(SUM(X38), 0) 污水费,
           MAX(case when x39 > 0 then p6 else  0 end ) 附加费单价,
           NVL(SUM(X39), 0) 附加费,
           'N' 是否归档,
          NVL(SUM(M7), 0)  收免水量按表 ,
          NVL(SUM(M8), 0)  收免水量按人,
          NVL(SUM(M9), 0)  收免件数按表 ,
          NVL(SUM(M10), 0)  收免件数按人,
          NVL(SUM(M17), 0)  收免污水量按表 ,
          NVL(SUM(M18), 0) 收免污水量按人,
          NVL(SUM(M19), 0) 收免污水件数按表 ,
           NVL(SUM(M20), 0) 收免污水件数按人,null
      FROM RPT_SUM_DETAIL 
     WHERE U_MONTH = V_RLMONTH and T20<>'补当'
     GROUP BY OFAGENT, U_MONTH, T19, T20
     ORDER BY OFAGENT, U_MONTH, T19, T20;
  COMMIT;
  INSERT INTO RPT_HRBZLS_RLCHARGE
    SELECT OFAGENT 营业所,
           U_MONTH 账务月份,
           T19 费用项目,
           T20 费用类别,
           NVL(SUM(M11), 0) 按表水费件数,
           NVL(SUM(M15), 0) 按表水费水量,
           NVL(SUM(M13), 0) 按人水费件数,
           NVL(SUM(M16), 0) 按人水费水量,
           NVL(SUM(M21), 0) 按表污水件数,
           NVL(SUM(M25), 0) 按表污水水量,
           NVL(SUM(M23), 0) 按人污水件数,
           NVL(SUM(M26), 0) 按人污水水量,
           MAX(case when X37 > 0 then p4 else  0 end) 水费单价,
           NVL(SUM(X37), 0) 水费,
           MAX(case when x38 > 0 then p5 else  0 end) 污水费单价,
           NVL(SUM(X38), 0) 污水费,
           MAX(case when x39 > 0 then p6 else  0 end ) 附加费单价,
           NVL(SUM(X39), 0) 附加费,
           'N' 是否归档,
          NVL(SUM(M7), 0)  收免水量按表 ,
          NVL(SUM(M8), 0)  收免水量按人,
          NVL(SUM(M9), 0)  收免件数按表 ,
          NVL(SUM(M10), 0)  收免件数按人,
          NVL(SUM(M17), 0)  收免污水量按表 ,
          NVL(SUM(M18), 0) 收免污水量按人,
          NVL(SUM(M19), 0) 收免污水件数按表 ,
           NVL(SUM(M20), 0) 收免污水件数按人,'居民'
      FROM RPT_SUM_DETAIL
     WHERE U_MONTH = V_RLMONTH    and T20='补当' and watertype_b='A' AND T19<>'其他'
     GROUP BY OFAGENT, U_MONTH, T19, T20
     ORDER BY OFAGENT, U_MONTH, T19, T20;
  COMMIT;
  INSERT INTO RPT_HRBZLS_RLCHARGE
    SELECT OFAGENT 营业所,
           U_MONTH 账务月份,
           T19 费用项目,
           T20 费用类别,
           NVL(SUM(M11), 0) 按表水费件数,
           NVL(SUM(M15), 0) 按表水费水量,
           NVL(SUM(M13), 0) 按人水费件数,
           NVL(SUM(M16), 0) 按人水费水量,
           NVL(SUM(M21), 0) 按表污水件数,
           NVL(SUM(M25), 0) 按表污水水量,
           NVL(SUM(M23), 0) 按人污水件数,
           NVL(SUM(M26), 0) 按人污水水量,
           MAX(case when X37 > 0 then p4 else  0 end) 水费单价,
           NVL(SUM(X37), 0) 水费,
           MAX(case when x38 > 0 then p5 else  0 end) 污水费单价,
           NVL(SUM(X38), 0) 污水费,
           MAX(case when x39 > 0 then p6 else  0 end ) 附加费单价,
           NVL(SUM(X39), 0) 附加费,
           'N' 是否归档,
          NVL(SUM(M7), 0)  收免水量按表 ,
          NVL(SUM(M8), 0)  收免水量按人,
          NVL(SUM(M9), 0)  收免件数按表 ,
          NVL(SUM(M10), 0)  收免件数按人,
          NVL(SUM(M17), 0)  收免污水量按表 ,
          NVL(SUM(M18), 0) 收免污水量按人,
          NVL(SUM(M19), 0) 收免污水件数按表 ,
           NVL(SUM(M20), 0) 收免污水件数按人,'非居民'
      FROM RPT_SUM_DETAIL
     WHERE U_MONTH = V_RLMONTH    and T20='补当' and watertype_b<>'A' AND T19<>'其他'
     GROUP BY OFAGENT, U_MONTH, T19, T20
     ORDER BY OFAGENT, U_MONTH, T19, T20;
  COMMIT;
  INSERT INTO RPT_HRBZLS_RLCHARGE
    SELECT OFAGENT 营业所,
           U_MONTH 账务月份,
           T19 费用项目,
           T20 费用类别,
           NVL(SUM(M11), 0) 按表水费件数,
           NVL(SUM(M15), 0) 按表水费水量,
           NVL(SUM(M13), 0) 按人水费件数,
           NVL(SUM(M16), 0) 按人水费水量,
           NVL(SUM(M21), 0) 按表污水件数,
           NVL(SUM(M25), 0) 按表污水水量,
           NVL(SUM(M23), 0) 按人污水件数,
           NVL(SUM(M26), 0) 按人污水水量,
           MAX(case when X37 > 0 then p4 else  0 end) 水费单价,
           NVL(SUM(X37), 0) 水费,
           MAX(case when x38 > 0 then p5 else  0 end) 污水费单价,
           NVL(SUM(X38), 0) 污水费,
           MAX(case when x39 > 0 then p6 else  0 end ) 附加费单价,
           NVL(SUM(X39), 0) 附加费,
           'N' 是否归档,
          NVL(SUM(M7), 0)  收免水量按表 ,
          NVL(SUM(M8), 0)  收免水量按人,
          NVL(SUM(M9), 0)  收免件数按表 ,
          NVL(SUM(M10), 0)  收免件数按人,
          NVL(SUM(M17), 0)  收免污水量按表 ,
          NVL(SUM(M18), 0) 收免污水量按人,
          NVL(SUM(M19), 0) 收免污水件数按表 ,
           NVL(SUM(M20), 0) 收免污水件数按人,null
      FROM RPT_SUM_DETAIL
     WHERE U_MONTH = V_RLMONTH    and T20='补当'  AND T19='其他'
     GROUP BY OFAGENT, U_MONTH, T19, T20
     ORDER BY OFAGENT, U_MONTH, T19, T20;
  COMMIT;
  --同步CE038编辑数据
  DELETE RPT_HRBZLS_RLCHARGENEW WHERE RLMONTH = V_RLMONTH;
  COMMIT;
  INSERT INTO RPT_HRBZLS_RLCHARGENEW
    SELECT t.* FROM RPT_HRBZLS_RLCHARGE T WHERE T.RLMONTH = V_RLMONTH;
  COMMIT;

END 月售水情况归档;

--月售水情况归档 月底生成各区回收静态数据，CE038报表数据源
/*-------------------------------------------------------------------------
修改说明：原过程需要在JOB中执行后，才能从客户端上查询数据,现改为直接在客户端上生成中间数据，方便明了
业务要点说明：
    1、本过程是给各个分公司修改售水报表数据后再上报用
    2、执行本过程后，从中间表RPT_SUM_DETAIL将所需数据统计到RPT_HRBZLS_RLCHARGE中来，
    3、所以需要当月的售水数据完整统计到中间表RPT_SUM_DETAIL后，本过程执行才有效
    4、按照原设计者思路，将数据过渡到RPT_HRBZLS_RLCHARGE来后，通过客户端修改相关统计数据。
       修改后的统计数据保存到RPT_HRBZLS_RLCHARGE中来，以后再出相关报表上报

相关数据库对象说明：
    1、视图V_可修改售水量中间表，就是从RPT_SUM_DETAIL 到  RPT_HRBZLS_RLCHARGE 的关系映射
    2、每次直接从视图将数据插入到RPT_HRBZLS_RLCHARGE即可, 在包过程：【综合月报】中被调用
-------------------------------------------------------------------------*/
PROCEDURE 月售水情况归档_1(P_MOUTH IN VARCHAR2) AS

  --V_SMFID   SYSMANAFRAME%ROWTYPE;
  V_RLMONTH VARCHAR2(7);

  --V_RPT     RPT_HRBZLS_RLCHARGE%ROWTYPE;

BEGIN
  --V_RLMONTH := TO_CHAR(SYSDATE, 'YYYY-MM');
  V_RLMONTH := P_MOUTH;
  

     
  --CE038 售水量统计月报表原始数据
  DELETE RPT_HRBZLS_RLCHARGE S
   WHERE S.RLMONTH = V_RLMONTH;
  COMMIT;
  
  INSERT INTO RPT_HRBZLS_RLCHARGE
    SELECT s.* 
      FROM V_可修改售水量中间表 S
     WHERE S.账务月份 = V_RLMONTH;
  COMMIT;
	
	--修改基建部分(按实收算)
	update RPT_HRBZLS_RLCHARGE rpt
	   set rpt.rlnum = PG_EWIDE_JOB_HRB2.f_getAllotNumber(rlsmfid,rlmonth),
		     rpt.rlsl = PG_EWIDE_JOB_HRB2.f_getAllotSl(rlsmfid,rlmonth),
				 rpt.rljsje = PG_EWIDE_JOB_HRB2.f_getAllotMoney(rlsmfid,rlmonth)
	 where rlmonth = V_RLMONTH and 
	       rlrfname = '基建';

  --同步CE038编辑数据
  DELETE RPT_HRBZLS_RLCHARGENEW S
   WHERE S.RLMONTH = V_RLMONTH;
  COMMIT;
  
  INSERT INTO RPT_HRBZLS_RLCHARGENEW T
    SELECT s.* FROM RPT_HRBZLS_RLCHARGE S 
     WHERE S.RLMONTH = V_RLMONTH;
  COMMIT;

END 月售水情况归档_1;
------------------------------------------------------------------------------------------
  --【4.8小时】月售水情况归档 月底生成各区回收静态数据，CE038报表数据源
  PROCEDURE 月售水情况归档_old AS
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
      --获取营业所本期应收帐务月份
      --V_RLMONTH := TOOLS.FGETRECMONTH(V_SMFID.SMFID);
      V_RLMONTH := '2014.02';
    
      /*
      * CE038 售水量统计月报表原始数据
      */
      DELETE RPT_HRBZLS_RLCHARGE
       WHERE RLSMFID = V_SMFID.SMFID
         AND RLMONTH = V_RLMONTH;
      COMMIT;
    
      --插入数据：
      V_RPT         := NULL;
      V_RPT.RLSMFID := V_SMFID.SMFID;
      V_RPT.RLMONTH := V_RLMONTH;
    
      --水站
      SELECT '水站' RLRFNAME,
             '居民' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID = 'A03';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --特困
      SELECT '低保' RLRFNAME,
             '居民' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID = 'A0104';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --正常用水
      SELECT '正常用水' RLRFNAME,
             '居民' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID NOT IN ('A03', 'A0104')
         AND RL.RLPFID LIKE 'A%';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --企事业
      SELECT '企事业' RLRFNAME,
             '非居民' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%') --AND RLCSTATUS<>'7'
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
    
      --学校
      SELECT '学校' RLRFNAME,
             '非居民' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%') --AND RLCSTATUS<>'7'
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
    
      --其它企事业
      SELECT '其它企事业' RLRFNAME,
             '非居民' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%') --AND RLCSTATUS<>'7'
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
    
      --消防水鹤
      SELECT '消防水鹤' RLRFNAME,
             '非居民' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID = 'B040101';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --商服业
      SELECT '商服业' RLRFNAME,
             '非居民' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID LIKE 'C%';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --宾馆餐饮
      SELECT '宾馆餐饮' RLRFNAME,
             '非居民' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%') --AND RLCSTATUS<>'7'
         AND RL.RLPFID LIKE 'D%';
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --其它
      SELECT '其它非居民' RLRFNAME,
             '非居民' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%') --AND RLCSTATUS<>'7'
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
    
      --特业1
      SELECT '特业1' RLRFNAME,
             '特业' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%') --AND RLCSTATUS<>'7'
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
    
      --特业2
      SELECT '特业2' RLRFNAME,
             '特业' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%') --AND RLCSTATUS<>'7'
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
    
      --收免（统计总计时排除）
      SELECT '收免' RLRFNAME,
             '补当' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    (RL.RLREADSL - RL.RLSL)
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    (RL.RLREADSL - RL.RLSL)
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%') --AND RLCSTATUS<>'7'
         AND RL.RLCID IN (SELECT PALCID
                            FROM PRICEADJUSTLIST T
                           WHERE PALTACTIC = '02'
                             AND PALWAY = '-1');
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --基建
      SELECT '基建' RLRFNAME,
             '补当' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%'); --AND RLCSTATUS<>'7'
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
      --补缴
      SELECT '补缴' RLRFNAME,
             '补当' RLTYPE,
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    1
                 END)) RLNUM, --件数（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    0
                   ELSE
                    RL.RLSL
                 END)) RLSL, --水量（按表）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    1
                   ELSE
                    0
                 END)) RLNUM, --件数（按人）
             SUM((CASE
                   WHEN MI.MISTATUS IN ('29', '30') THEN
                    RL.RLSL
                   ELSE
                    0
                 END)) RLSL, --水量（按人）
             MAX(RD.DJ1) DJ1, --净水费单价
             SUM(RD.CHARGE1) CHARGE1, --净水费
             MAX(RD.DJ2) DJ2, --污水费单价
             SUM(RD.CHARGE2) CHARGE2, --污水费
             MAX(RD.DJ3) DJ3, --附加费单价
             SUM(RD.CHARGE3) CHARGE3 --附加费
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
         AND RLCID IN (SELECT CIID FROM CUSTINFO WHERE CIMEMO LIKE '正常%'); --AND RLCSTATUS<>'7'
      INSERT INTO RPT_HRBZLS_RLCHARGE VALUES V_RPT;
      COMMIT;
    
    END LOOP;
    CLOSE C_SMFID;
    COMMIT;
  
    --同步CE038编辑数据
    DELETE RPT_HRBZLS_RLCHARGENEW WHERE RLMONTH = V_RLMONTH;
    INSERT INTO RPT_HRBZLS_RLCHARGENEW
      SELECT t.* FROM RPT_HRBZLS_RLCHARGE T WHERE T.RLMONTH = V_RLMONTH;
    COMMIT;
  
  END 月售水情况归档_old;


END;
/

