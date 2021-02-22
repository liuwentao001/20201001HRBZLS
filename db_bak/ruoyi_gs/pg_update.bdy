﻿CREATE OR REPLACE PACKAGE BODY PG_UPDATE IS

  --变更管理
  PROCEDURE PROC_USER(I_RENO  IN VARCHAR2, --流水号
                      I_TPYE  IN VARCHAR2, --更新类型
                      I_OPER  IN VARCHAR2, --操作人
                      O_STATE OUT NUMBER) IS --执行状态
  V_MDNO VARCHAR2(100);
  BEGIN
    --用户信息维护
    IF I_TPYE = 'A' THEN
      FOR I IN (SELECT * FROM REQUEST_YHXX WHERE RENO = I_RENO) LOOP
        --备份用户信息表
        INSERT INTO BS_CUSTINFO_HIS
        SELECT A.*,'用户信息维护',I.RENO,SYSDATE 
        FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
      --更新用户信息表
      UPDATE BS_CUSTINFO A SET
      CINAME = CASE WHEN I.CINAME IS NULL THEN A.CINAME ELSE I.CINAME END,  --用户名
      CIADR = CASE WHEN I.CIADR IS NULL THEN A.CIADR ELSE I.CIADR END,  --用户地址
      CIMTEL = CASE WHEN I.CIMTEL IS NULL THEN A.CIMTEL ELSE I.CIMTEL END,  --移动电话
      CICONNECTPER = CASE WHEN I.CICONNECTPER IS NULL THEN A.CICONNECTPER ELSE I.CICONNECTPER END,  --联系人
      CIIFINV = CASE WHEN I.CIIFINV IS NULL THEN A.CIIFINV ELSE I.CIIFINV END,  --是否普票
      CINAME1 = CASE WHEN I.CINAME1 IS NULL THEN A.CINAME1 ELSE I.CINAME1 END,  --票据名称
      CITAXNO = CASE WHEN I.CITAXNO IS NULL THEN A.CITAXNO ELSE I.CITAXNO END,  --税号
      CIBANKNAME = CASE WHEN I.CIBANKNAME IS NULL THEN A.CIBANKNAME ELSE I.CIBANKNAME END,  --开户行名称(电票)
      CIBANKNO = CASE WHEN I.CIBANKNO IS NULL THEN A.CIBANKNO ELSE I.CIBANKNO END,  --开户行账号(电票)
      CIADR1 = CASE WHEN I.CIADR1 IS NULL THEN A.CIADR1 ELSE I.CIADR1 END,  --票据地址
      CITEL4 = CASE WHEN I.CITEL4 IS NULL THEN A.CITEL4 ELSE I.CITEL4 END,  --票据电话
      CINAME2 = CASE WHEN I.CINAME2 IS NULL THEN A.CINAME2 ELSE I.CINAME2 END,  --招牌名称
      CIIFSMS = CASE WHEN I.CIIFSMS IS NULL THEN A.CIIFSMS ELSE I.CIIFSMS END,  --是否提供短信服务
      CIIDENTITYLB = CASE WHEN I.CIIDENTITYLB IS NULL THEN A.CIIDENTITYLB ELSE I.CIIDENTITYLB END,  --证件类型(1-身份证 2-营业执照  0-无)
      CIIDENTITYNO = CASE WHEN I.CIIDENTITYNO IS NULL THEN A.CIIDENTITYNO ELSE I.CIIDENTITYNO END,  --证件号码
      CIWXNO = CASE WHEN I.CIWXNO IS NULL THEN A.CIWXNO ELSE I.CIWXNO END,  --微信号码
      CICQNO = CASE WHEN I.CICQNO IS NULL THEN A.CICQNO ELSE I.CICQNO END  --产权证号
      WHERE A.CIID = I.CIID;
    END LOOP;
    --票据信息维护
    ELSIF I_TPYE = 'B' THEN
      FOR I IN (SELECT * FROM REQUEST_PJXX WHERE RENO = I_RENO) LOOP
        --备份用户信息表
        INSERT INTO BS_CUSTINFO_HIS
        SELECT A.*,'票据信息维护',I.RENO,SYSDATE 
        FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
      --更新用户信息表
      UPDATE BS_CUSTINFO A SET
      CIMTEL = CASE WHEN I.CIMTEL IS NULL THEN A.CIMTEL ELSE I.CIMTEL END,  --移动电话
      CICONNECTPER = CASE WHEN I.CICONNECTPER IS NULL THEN A.CICONNECTPER ELSE I.CICONNECTPER END,  --联系人
      CIIFINV = CASE WHEN I.CIIFINV IS NULL THEN A.CIIFINV ELSE I.CIIFINV END,  --是否普票
      CINAME1 = CASE WHEN I.CINAME1 IS NULL THEN A.CINAME1 ELSE I.CINAME1 END,  --票据名称
      CITAXNO = CASE WHEN I.CITAXNO IS NULL THEN A.CITAXNO ELSE I.CITAXNO END,  --税号
      CIBANKNAME = CASE WHEN I.CIBANKNAME IS NULL THEN A.CIBANKNAME ELSE I.CIBANKNAME END,  --开户行名称(电票)
      CIBANKNO = CASE WHEN I.CIBANKNO IS NULL THEN A.CIBANKNO ELSE I.CIBANKNO END,  --开户行账号(电票)
      CIADR1 = CASE WHEN I.CIADR1 IS NULL THEN A.CIADR1 ELSE I.CIADR1 END,  --票据地址
      CITEL4 = CASE WHEN I.CITEL4 IS NULL THEN A.CITEL4 ELSE I.CITEL4 END  --票据电话
      WHERE A.CIID = I.CIID;
        END LOOP;
    --收费方式变更
    ELSIF I_TPYE = 'C' THEN
      FOR I IN (SELECT * FROM REQUEST_SFFS WHERE RENO = I_RENO) LOOP
        --备份用户信息表
        INSERT INTO BS_CUSTINFO_HIS
        SELECT A.*,'收费方式变更',I.RENO,SYSDATE 
        FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
      --更新用户信息表
      UPDATE BS_CUSTINFO A SET
      MICHARGETYPE = CASE WHEN I.MICHARGETYPE IS NULL THEN A.MICHARGETYPE ELSE I.MICHARGETYPE END  --类型（1=坐收，2=走收,收费方式）
      WHERE A.CIID = I.CIID;
        END LOOP;
     --用水性质变更
    ELSIF I_TPYE = 'D' THEN
      FOR I IN (SELECT * FROM REQUEST_SJBG WHERE RENO = I_RENO) LOOP
        --备份户表信息
        INSERT INTO BS_METERINFO_HIS
        SELECT A.*,'用水性质变更',I.RENO,SYSDATE 
        FROM BS_METERINFO A WHERE A.MIID=I.MIID;
        --更新户表信息
        UPDATE BS_METERINFO A SET 
        MIPFID = CASE WHEN I.MIPFID IS NULL THEN A.MIPFID ELSE I.MIPFID END  --用水性质(priceframe)
        WHERE A.MIID=I.MIID;
        --备份用户信息表
        INSERT INTO BS_CUSTINFO_HIS
        SELECT A.*,'用水性质变更',I.RENO,SYSDATE 
        FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
        --更新用户信息表
        UPDATE BS_CUSTINFO A SET 
        CICOLUMN11 = CASE WHEN I.CICOLUMN11 IS NULL THEN A.CICOLUMN11 ELSE I.CICOLUMN11 END,  --特困标志
        CITKZJH = CASE WHEN I.CITKZJH IS NULL THEN A.CITKZJH ELSE I.CITKZJH END,  --特困证件号
        CICOLUMN2 = CASE WHEN I.CICOLUMN2 IS NULL THEN A.CICOLUMN2 ELSE I.CICOLUMN2 END,  --低保用户标志
        CIDBZJH = CASE WHEN I.CIDBZJH IS NULL THEN A.CIDBZJH ELSE I.CIDBZJH END  --低保证件号
        WHERE A.CIID=I.CIID;
       END LOOP;
      --水表档案变更
    ELSIF I_TPYE = 'E' THEN
     FOR I IN (SELECT * FROM REQUEST_SBDA WHERE RENO = I_RENO) LOOP
       SELECT MDNO INTO V_MDNO FROM BS_METERDOC A WHERE A.MDID=I.MIID;
       --备份水表档案
       INSERT INTO BS_METERDOC_HIS
       SELECT A.*,'水表档案变更',I.RENO,SYSDATE 
       FROM BS_METERDOC A WHERE A.MDID=I.MIID;
       --更新水表档案
       UPDATE BS_METERDOC A SET 
       MDNO = CASE WHEN I.MDNO IS NULL THEN A.MDNO ELSE I.MDNO END,  --表身码
       MDBRAND = CASE WHEN I.MDBRAND IS NULL THEN A.MDBRAND ELSE I.MDBRAND END,  --表厂家(meterbrand)
       MDCALIBER = CASE WHEN I.MDCALIBER IS NULL THEN A.MDCALIBER ELSE I.MDCALIBER END,  --表口径(METERCALIBER)
       BARCODE = CASE WHEN I.BARCODE IS NULL THEN A.BARCODE ELSE I.BARCODE END,  --条形码
       RFID = CASE WHEN I.RFID IS NULL THEN A.RFID ELSE I.RFID END,  --电子标签
       COLLENTTYPE = CASE WHEN I.MIRTID IS NULL THEN A.COLLENTTYPE ELSE I.MIRTID END,  --采集类型（原抄表方式【sysreadtype】）
       DQSFH = CASE WHEN I.DQSFH IS NULL THEN A.DQSFH ELSE I.DQSFH END,  --塑封号
       DQGFH = CASE WHEN I.DQGFH IS NULL THEN A.DQGFH ELSE I.DQGFH END,  --钢封号
       JCGFH = CASE WHEN I.JCGFH IS NULL THEN A.JCGFH ELSE I.JCGFH END,  --稽查刚封号
       QFH = CASE WHEN I.QFH IS NULL THEN A.QFH ELSE I.QFH END  --铅封号
       WHERE A.MDID=I.MIID;
       --备份户表信息
       INSERT INTO BS_METERINFO_HIS
       SELECT A.*,'水表档案变更',I.RENO,SYSDATE 
       FROM BS_METERINFO A WHERE A.MIID=I.MIID;
       --更新户表信息
       UPDATE BS_METERINFO A SET 
       MIADR = CASE WHEN I.MIADR IS NULL THEN A.MIADR ELSE I.MIADR END,  --表地址
       MISIDE = CASE WHEN I.MISIDE IS NULL THEN A.MISIDE ELSE I.MISIDE END,  --表位【syscharlist】
       DQSFH = CASE WHEN I.DQSFH IS NULL THEN A.DQSFH ELSE I.DQSFH END,  --塑封号
       DQGFH = CASE WHEN I.DQGFH IS NULL THEN A.DQGFH ELSE I.DQGFH END,  --钢封号
       JCGFH = CASE WHEN I.JCGFH IS NULL THEN A.JCGFH ELSE I.JCGFH END,  --稽查刚封号
       QFH = CASE WHEN I.QFH IS NULL THEN A.QFH ELSE I.QFH END,  --铅封号
       MICARDNO = CASE WHEN I.OMICARDNO IS NULL THEN A.MICARDNO ELSE I.OMICARDNO END  --卡片图号
       WHERE A.MIID=I.MIID;
       --封号表：塑封号更新
       IF I.DQSFH IS NOT NULL THEN
         UPDATE BS_METERFH_STORE SET FHSTATUS = '2',MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '1' AND BSM = NVL(I.OMDNO,V_MDNO);
         UPDATE BS_METERFH_STORE SET FHSTATUS = '1',BSM = NVL(I.MDNO,V_MDNO), MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '1' AND FHSTATUS = '0' AND METERFH = I.DQSFH;
         END IF;
       --封号表：钢封号更新
       IF I.DQGFH IS NOT NULL THEN
         UPDATE BS_METERFH_STORE SET FHSTATUS = '2',MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '2' AND BSM = NVL(I.OMDNO,V_MDNO);
         UPDATE BS_METERFH_STORE SET FHSTATUS = '1',BSM = NVL(I.MDNO,V_MDNO), MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '2' AND FHSTATUS = '0' AND METERFH = I.DQGFH;
         END IF;
       --封号表：稽查刚封号更新
       IF I.JCGFH IS NOT NULL THEN
         UPDATE BS_METERFH_STORE SET FHSTATUS = '2',MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '3' AND BSM = NVL(I.OMDNO,V_MDNO);
         UPDATE BS_METERFH_STORE SET FHSTATUS = '1',BSM = NVL(I.MDNO,V_MDNO), MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '3' AND FHSTATUS = '0' AND METERFH = I.JCGFH;
         END IF;
       --封号表：铅封号更新
       IF I.QFH IS NOT NULL THEN
         UPDATE BS_METERFH_STORE SET FHSTATUS = '2',MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '4' AND BSM = NVL(I.OMDNO,V_MDNO);
         UPDATE BS_METERFH_STORE SET FHSTATUS = '1',BSM = NVL(I.MDNO,V_MDNO), MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '4' AND FHSTATUS = '0' AND METERFH = I.QFH;
         END IF;
      END LOOP;
    --过户
    ELSIF I_TPYE = 'F' THEN
      FOR I IN (SELECT * FROM REQUEST_GH WHERE RENO = I_RENO) LOOP
       --备份用户信息表
       INSERT INTO BS_CUSTINFO_HIS
       SELECT A.*,'过户',I.RENO,SYSDATE 
       FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
       --更新用户信息表
       UPDATE BS_CUSTINFO A SET 
       A.CICQNO = CASE WHEN I.CICQNO IS NULL THEN A.CICQNO ELSE I.CICQNO END,  --产权证号
       --A.?????? = I.ACCESSORYFLAG5, --新户主身份证复印件标识  暂不确定对应字段 对应表
       A.CIBANKNAME = CASE WHEN I.CIBANKNAME IS NULL THEN A.CIBANKNAME ELSE I.CIBANKNAME END,  --开户行名称(电票)
       A.CIBANKNO = CASE WHEN I.CIBANKNO IS NULL THEN A.CIBANKNO ELSE I.CIBANKNO END,  --开户行账号(电票)
       A.CICONNECTPER = CASE WHEN I.CICONNECTPER IS NULL THEN A.CICONNECTPER ELSE I.CICONNECTPER END,  --联系人
       A.CIADR1 = CASE WHEN I.CIADR1 IS NULL THEN A.CIADR1 ELSE I.CIADR1 END,  --票据地址
       A.CITEL4 = CASE WHEN I.CITEL4 IS NULL THEN A.CITEL4 ELSE I.CITEL4 END,  --票据电话
       A.CINAME1 = CASE WHEN I.CINAME1 IS NULL THEN A.CINAME1 ELSE I.CINAME1 END,  --票据名称
       A.CIIFSMS = CASE WHEN I.CIIFSMS IS NULL THEN A.CIIFSMS ELSE I.CIIFSMS END,  --是否提供短信服务（短信号码同移动电话）
       A.CITAXNO = CASE WHEN I.CITAXNO IS NULL THEN A.CITAXNO ELSE I.CITAXNO END,  --税号
       A.CIWXNO = CASE WHEN I.CIWXNO IS NULL THEN A.CIWXNO ELSE I.CIWXNO END,  --微信号码
       A.CIMTEL = CASE WHEN I.CIMTEL IS NULL THEN A.CIMTEL ELSE I.CIMTEL END,  --移动电话
       A.CIADR = CASE WHEN I.CIADR IS NULL THEN A.CIADR ELSE I.CIADR END,  --用户地址
       A.CINAME = CASE WHEN I.CINAME IS NULL THEN A.CINAME ELSE I.CINAME END,  --用户名
       A.CIIFINV = CASE WHEN I.CIIFINV IS NULL THEN A.CIIFINV ELSE I.CIIFINV END,  --是否普票（迁移数据时同步bs_meterinfo.MIIFTAX(是否税票)）
       A.CIIDENTITYNO = CASE WHEN I.CIIDENTITYNO IS NULL THEN A.CIIDENTITYNO ELSE I.CIIDENTITYNO END,  --证件号码
       A.CIIDENTITYLB = CASE WHEN I.CIIDENTITYLB IS NULL THEN A.CIIDENTITYLB ELSE I.CIIDENTITYLB END  --证件类型
       WHERE A.CIID=I.CIID;
       --备份户表信息
       INSERT INTO BS_METERINFO_HIS
       SELECT A.*,'过户',I.RENO,SYSDATE 
       FROM BS_METERINFO A 
       WHERE A.MICODE=I.CIID;
       --更新户表信息
       UPDATE BS_METERINFO A SET 
       MICARDNO = CASE WHEN I.OMICARDNO IS NULL THEN A.MICARDNO ELSE I.OMICARDNO END  --卡片图号
       WHERE A.MICODE=I.CIID;
       UPDATE REQUEST_GH A SET A.MODIFYDATE = SYSDATE, MODIFYUSERNAME = I_OPER WHERE A.RENO=I.RENO;
        END LOOP;
    END IF;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;
  --表册调整
  PROCEDURE PROC_LIST(I_RENO  IN VARCHAR2, --流水号
                      I_TPYE  IN VARCHAR2, --更新类型
                      I_OPER  IN VARCHAR2, --操作人
                      O_STATE OUT NUMBER) IS --执行状态
  V_DEPT VARCHAR2(100);
  V_COUNT NUMBER(10);
  BEGIN
    -- A 跨区域调整
    IF I_TPYE = 'A' THEN
    FOR I IN (SELECT *
                FROM (SELECT REGEXP_SUBSTR(YBFID, '[^,]+', 1, LEVEL) YBFID,
                             REGEXP_SUBSTR(MBFID, '[^,]+', 1, LEVEL) MBFID
                        FROM REQUEST_QYDZ
                       WHERE RENO = I_RENO
                      CONNECT BY LEVEL <= LENGTH(YBFID) -
                                 LENGTH(REPLACE(YBFID, ',', '')) + 1)
               GROUP BY YBFID, MBFID
               ORDER BY YBFID, MBFID) LOOP
      V_DEPT := SUBSTR(I.MBFID,1,2);
      
      UPDATE BS_METERINFO SET MIBFID = I.MBFID,MISMFID  = '02'||V_DEPT,MIRORDER='' WHERE MIBFID = I.YBFID;
      UPDATE BS_METERINFO_HIS SET MIBFID = I.MBFID,MISMFID  = '02'||V_DEPT WHERE MIBFID = I.YBFID;
      UPDATE BS_METERREAD SET MRBFID = I.MBFID,MRSMFID = '02'||V_DEPT,MRRORDER='' WHERE MRBFID = I.YBFID;
      UPDATE BS_METERREAD_HIS SET MRBFID = I.MBFID,MRSMFID = '02'||V_DEPT WHERE MRBFID = I.YBFID;
      UPDATE BS_RECLIST SET RLBFID = I.MBFID,RLSMFID = '02'||V_DEPT WHERE RLBFID = I.YBFID;
      
      FOR A IN (SELECT * FROM BS_METERINFO WHERE MIBFID = I.MBFID AND MIRORDER IS NULL) LOOP
        SELECT COUNT(*)+1 INTO V_COUNT FROM BS_METERINFO WHERE MIBFID=I.MBFID AND MIRORDER IS NOT NULL;
        UPDATE BS_METERINFO SET MIRORDER=V_COUNT,MISEQNO=I.MBFID||V_COUNT WHERE MIID=A.MIID;
        UPDATE BS_METERREAD SET MRRORDER=V_COUNT,MRZKH=I.MBFID||V_COUNT WHERE MRMID=A.MIID;
        END LOOP;
    END LOOP;
    END IF;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;
  
  --抄表员间表册转移
  PROCEDURE PROC_LIST2(I_BFID    IN VARCHAR2, --表册号
                       I_BFRPER  IN VARCHAR2, --新抄表员
                       I_BFRCYC  IN VARCHAR2, --新抄表周期
                       I_BFSDATE IN VARCHAR2, --新计划起始日期
                       I_BFEDATE IN VARCHAR2, --新计划结束日期
                       I_BFNRMONTH IN VARCHAR2, --新下次抄表月份
                       O_STATE   OUT NUMBER) IS --执行状态
  BEGIN
    FOR I IN (SELECT REGEXP_SUBSTR(BFID, '[^,]+', 1, LEVEL) BFID
                        FROM (SELECT I_BFID AS BFID FROM DUAL)
                      CONNECT BY LEVEL <= LENGTH(BFID) -
                                 LENGTH(REPLACE(BFID, ',', '')) + 1) LOOP
    UPDATE BS_BOOKFRAME 
    SET BFRPER = I_BFRPER,  --抄表员
        BFRCYC = NVL(I_BFRCYC,BFRCYC), --抄表周期
        BFSDATE = NVL(TO_DATE(I_BFSDATE,'YYYY/MM/DD'),BFSDATE),  --计划起始日期
        BFEDATE = NVL(TO_DATE(I_BFEDATE,'YYYY/MM/DD'),BFEDATE),  --计划结束日期
        BFNRMONTH = NVL(I_BFNRMONTH,BFNRMONTH)  --下次抄表月份
         WHERE BFID = I.BFID;
    END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --账卡号调整
  PROCEDURE PROC_INFO(I_MIID    IN VARCHAR2, --水表档案编号
                      I_MIBFID  IN VARCHAR2, --表册号
                      O_STATE   OUT NUMBER) IS --执行状态
  V_COUNT NUMBER(10);
  BEGIN
    FOR I IN (SELECT REGEXP_SUBSTR(I_MIID, '[^,]+', 1, LEVEL) I_MIID
                        FROM (SELECT I_MIID AS I_MIID FROM DUAL)
                      CONNECT BY LEVEL <= LENGTH(I_MIID) -
                                 LENGTH(REPLACE(I_MIID, ',', '')) + 1) LOOP
    INSERT INTO BS_METERINFO_HIS
    SELECT A.*,'账卡号调整','',SYSDATE FROM BS_METERINFO A WHERE A.MIID=I_MIID;
    UPDATE BS_METERINFO SET MIBFID = I_MIBFID,MIRORDER='' WHERE MIID=I_MIID;
    FOR I IN (SELECT * FROM BS_METERINFO WHERE MIBFID = I_MIID AND MIRORDER IS NULL) LOOP
        SELECT COUNT(*)+1 INTO V_COUNT FROM BS_METERINFO WHERE MIBFID=I_MIBFID AND MIRORDER IS NOT NULL;
        UPDATE BS_METERINFO SET MIRORDER=V_COUNT,MISEQNO=I_MIBFID||V_COUNT WHERE MIID=I_MIID;
        END LOOP;
        END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --等针
  PROCEDURE PROC_DZ(I_RENO    IN VARCHAR2, --流水号
                    O_STATE   OUT NUMBER) IS --执行状态
  BEGIN
    FOR I IN (SELECT * FROM REQUEST_DZ WHERE RENO = I_RENO) LOOP
    UPDATE BS_METERINFO A SET A.MIYL1 = 'Y', A.MIENEED=I.MIWCODE WHERE MIID=I.MIID;
        END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --固定量
  PROCEDURE PROC_GDL(I_RENO    IN VARCHAR2, --流水号
                     O_STATE   OUT NUMBER) IS --执行状态
  BEGIN
    FOR I IN (SELECT * FROM REQUEST_GDL WHERE RENO = I_RENO) LOOP
    UPDATE BS_METERINFO A SET A.MICOLUMN5 = I.MICOLUMN5 WHERE MIID=I.MIID;
        END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --总表收免
  PROCEDURE PROC_ZBSM(I_RENO    IN VARCHAR2, --流水号
                      O_STATE   OUT NUMBER) IS --执行状态
  BEGIN
    FOR I IN (SELECT * FROM REQUEST_ZBSM WHERE RENO = I_RENO) LOOP
    UPDATE BS_METERINFO A SET A.MIYL2 = I.MIYL2,A.MIYL7=I.MIYL7  WHERE MIID=I.MIID;
        END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

END;
/

