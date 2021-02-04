CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_CUSTBASE_01" IS

  CURRENTDATE DATE := TOOLS.FGETSYSDATE;
  CALLOGTXT                 CLOB;
  --单据审核路由过程 
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2) IS
  BEGIN
    IF P_DJLB IN ('R', '0', '8', '3', '4', 'p') THEN
      SP_REGISTER(P_DJLB, P_BILLNO, P_PERSON, 'N');
      --p预立户
      --4 用户建账管理
 
    ELSIF P_DJLB = 'x' then
      sp_临时用水立户(P_DJLB, P_BILLNO, P_PERSON, 'N');
    ELSIF P_DJLB = 'w' then
      sp_污水超标管理(P_DJLB, P_BILLNO, P_PERSON, 'N');
    ELSIF P_DJLB = '18' then
      sp_特惠户管理(P_DJLB, P_BILLNO, P_PERSON, 'N');
    ELSIF P_DJLB = 'z' then
      sp_正式用水管理(P_DJLB, P_BILLNO, P_PERSON, 'N');
    ELSIF P_DJLB = '10' then
      sp_营业所变更(P_DJLB, P_BILLNO, P_PERSON, 'N');
    ELSIF P_DJLB = 'q' then
      sp_拆迁止水(P_DJLB, P_BILLNO, P_PERSON, 'N');
    ELSIF P_DJLB in ('15', '16', 'g', 'i', 'h', 'j') then
      sp_封号管理(P_DJLB, P_BILLNO, P_PERSON, 'N');
    ELSIF P_DJLB in ('34') then --营销部收入建账
        SP_营销部收入建账(P_DJLB, P_BILLNO, P_PERSON, 'N');
    ELSIF P_DJLB in ('Y') then --合收表维护
        SP_合收表维护2( P_BILLNO, P_PERSON, 'N');
    ELSE
      SP_CUSTCHANGE(P_DJLB, P_BILLNO, P_PERSON, 'N');
    END IF;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END APPROVE;

  --单据审核路由过程（简化）
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_DJLB   IN VARCHAR2) IS
  BEGIN
    IF P_DJLB IN ('R', '0') THEN
      SP_REGISTER(P_DJLB, P_BILLNO, P_PERSON, 'N');
    ELSE
      SP_CUSTCHANGE(P_DJLB, P_BILLNO, P_PERSON, 'N');
    END IF;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END APPROVE;

  PROCEDURE WLOG(P_TXT IN VARCHAR2) IS
  BEGIN
    CALLOGTXT := CALLOGTXT || CHR(10) ||
                 TO_CHAR(SYSDATE, 'mm-dd HH24:MI:SS >> ') || P_TXT;
  END;

  --变更单取消
  PROCEDURE CANCEL(P_BILLNO IN VARCHAR2,
                   P_PERSON IN VARCHAR2,
                   P_DJLB   IN VARCHAR2) IS
    CURSOR C_CCH IS
      SELECT *
        FROM CUSTCHANGEHD
       WHERE CCHNO = P_BILLNO
         AND CCHLB = P_DJLB
         FOR UPDATE;
    CCH CUSTCHANGEHD%ROWTYPE;
  BEGIN
    OPEN C_CCH;
    FETCH C_CCH
      INTO CCH;
    IF C_CCH%NOTFOUND OR C_CCH%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据不存在' || P_BILLNO);
    END IF;
    IF CCH.CCHSHFLAG <> 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据不能取消' || P_BILLNO);
    END IF;
    --设置取消标志
    UPDATE CUSTCHANGEHD
       SET CCHSHFLAG = 'Q', CCHSHPER = P_PERSON, CCHSHDATE = SYSDATE
     WHERE CURRENT OF C_CCH;
    CLOSE C_CCH;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_CCH%ISOPEN THEN
        CLOSE C_CCH;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END CANCEL;

  --变更单行审核
  PROCEDURE APPROVEROW(P_BILLNO IN VARCHAR2,
                       P_PERSON IN VARCHAR2,
                       P_BILLID IN VARCHAR2,
                       P_DJLB   IN VARCHAR2,
                       P_ROWNO  IN NUMBER) IS
  BEGIN
    SP_CUSTCHANGEBYROW(P_DJLB, P_BILLNO, P_ROWNO, P_PERSON, 'N');
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END APPROVEROW;
 --营销部收入建账
  PROCEDURE SP_营销部收入建账(P_TYPE   IN VARCHAR2,
                        P_CRHNO  IN VARCHAR2,
                        P_PER    IN VARCHAR2,
                        P_COMMIT IN VARCHAR2) AS
    CURSOR C_CMRD IS
      SELECT * FROM CUSTMETERREGDT WHERE CMRDNO = P_CRHNO FOR UPDATE;
  
    CURSOR C_CMRD1 IS
      SELECT * FROM CUSTREGHD WHERE CRHNO = P_CRHNO;
  
    CURSOR C_PCI(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;
  
    CURSOR C_PMI(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MICODE = VMID;
  
    -----------------------------------------
    --哈尔滨需求：建账时通过表身码直接维护合收表
    CURSOR C_AFCMRD IS
      SELECT *
        FROM CUSTMETERREGDT
       WHERE CMRDNO = P_CRHNO
       ORDER BY DECODE(MDNO, MIREMOTENO, 1, 0) DESC
         FOR UPDATE;
  
    V_AFCMRD    CUSTMETERREGDT%ROWTYPE;
    V_MIPRIFLAG VARCHAR2(1);
    V_MIPRIID   VARCHAR2(10);
    -----------------------------------------
  
    V_I           VARCHAR2(50);
    HD            CUSTREGHD%ROWTYPE;
    CRH           CUSTREGHD%ROWTYPE;
    CR            CUSTREGHD%ROWTYPE;
    CMRD          CUSTMETERREGDT%ROWTYPE;
    CI            CUSTINFO%ROWTYPE;
    MI            METERINFO%ROWTYPE;
    MD            METERDOC%ROWTYPE;
    MA            METERACCOUNT%ROWTYPE;
    PCI           CUSTINFO%ROWTYPE;
    PMI           METERINFO%ROWTYPE;
    PMD           PRICEMULTIDETAIL%ROWTYPE;
    FLAGN         NUMBER;
    FLAGY         NUMBER;
    V_SEQTEMP     VARCHAR2(200);
    V_BILLID      VARCHAR2(200);
    V_METERSTATUS METERSTATUS%ROWTYPE;
    V_NUM         NUMBER;
    V_COUNT       NUMBER;
  
  BEGIN
    CALLOGTXT := NULL;
    V_COUNT := 0;
    V_NUM := 0;
    BEGIN
      SELECT * INTO CRH FROM CUSTREGHD WHERE CRHNO = P_CRHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '立户单不存在!');
    END;
    IF CRH.CRHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF CRH.CRHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    SELECT COUNT(*)
      INTO FLAGY
      FROM CUSTMETERREGDT
     WHERE CMRDNO = P_CRHNO
       AND PREDISPOSEFLAG = 'Y';
    IF FLAGY = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要立户的水表!');
    END IF;
    SELECT COUNT(*)
      INTO FLAGN
      FROM CUSTMETERREGDT
     WHERE CMRDNO = P_CRHNO
       AND PREDISPOSEFLAG = 'N';
  
    IF FLAGN > 0 THEN
      BEGIN
        SELECT BMID INTO V_BILLID FROM BILLMAIN WHERE BMTYPE = CRH.CRHLB;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '此种类型单据未定义!');
      END;
      TOOLS.SP_BILLSEQ('108', V_SEQTEMP, 'N');
      CR.CRHNO      := V_SEQTEMP; --单据流水号
      CR.CRHBH      := V_SEQTEMP; --单据编号
      CR.CRHLB      := CRH.CRHLB; --单据类别
      CR.CRHSOURCE  := CRH.CRHSOURCE; --单据来源
      CR.CRHSMFID   := CRH.CRHSMFID; --营销公司
      CR.CRHDEPT    := CRH.CRHDEPT; --立户部门
      CR.CRHCREDATE := SYSDATE; --创建日期
      CR.CRHCREPER  := P_PER; --创建人员
      CR.CRHSHFLAG  := 'N'; --审核标志
      INSERT INTO CUSTREGHD VALUES CR;
      UPDATE CUSTMETERREGDT
         SET CMRDNO = V_SEQTEMP, PREDISPOSEFLAG = 'Y'
       WHERE CMRDNO = P_CRHNO
         AND PREDISPOSEFLAG = 'N';
    END IF;
  
    OPEN C_CMRD;
    LOOP
      FETCH C_CMRD
        INTO CMRD;
      EXIT WHEN C_CMRD%NOTFOUND OR C_CMRD%NOTFOUND IS NULL;
 
      --增加用户--------------------------
      --CI.CIID          := FGETSEQUENCE('CUSTINFO');--
      --CI.CICODE        := NVL(CMRD.CICODE,FNEWCICODE(CMRD.CISMFID));--
      CI.CICONID := CMRD.CICONID; --
      CI.CISMFID := CMRD.CISMFID; --
      CI.CIPID   := CMRD.CIPID; --
      --校验上级用户
      IF CMRD.CIPID IS NOT NULL THEN
        OPEN C_PCI(CMRD.CIPID);
        FETCH C_PCI
          INTO PCI;
        IF C_PCI%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_CRHNO || '无效的上级用户');
        END IF;
        CI.CICLASS := PCI.CICLASS + 1; --
        CLOSE C_PCI;
      ELSE
        CI.CICLASS := 1; --
      END IF;
      CI.CIFLAG        := 'Y'; --
      CI.CINAME        := CMRD.CINAME; --
      CI.CINAME2       := CMRD.CINAME2; --
      CI.CIADR         := CMRD.CIADR; --
      CI.CISTATUS      := CMRD.CISTATUS; --
      CI.CISTATUSDATE  := NULL; --
      CI.CISTATUSTRANS := NULL; --
      CI.CINEWDATE     := CURRENTDATE; --
      CI.CIIDENTITYLB  := CMRD.CIIDENTITYLB; --
      CI.CIIDENTITYNO  := CMRD.CIIDENTITYNO; --
      CI.CIMTEL        := CMRD.CIMTEL; --
      CI.CITEL1        := CMRD.CITEL1; --
      CI.CITEL2        := CMRD.CITEL2; --
      CI.CITEL3        := CMRD.CITEL3; --
      CI.CICONNECTPER  := CMRD.CICONNECTPER; --
      CI.CICONNECTTEL  := CMRD.CICONNECTTEL; --
      CI.CIIFINV       := CMRD.CIIFINV; --
      CI.CIIFSMS       := CMRD.CIIFSMS; --
      CI.CIIFZN        := CMRD.CIIFZN; --
      CI.CIPROJNO      := CMRD.CIPROJNO; --
      CI.CIFILENO      := CMRD.CIFILENO; --
      CI.CIMEMO        := CMRD.CIMEMO; --
      CI.CIDEPTID      := CMRD.CIDEPTID; --
      ----------------------------
      IF 客户代码是否营业所 = 'Y' THEN
        MI.MIID := NVL(CMRD.MICODE, FNEWMICODE(CMRD.MISMFID)); --FGETSEQUENCE('METERINFO');--
      ELSIF 客户代码是否营业所 = 'N' THEN
        IF CMRD.MISAFID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '水表区域不能为NULL');
        END IF;
        IF FNEWMICODEAREA(CMRD.MISAFID) IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '编码规则未定义');
        END IF;
        MI.MIID := NVL(CMRD.MICODE, FNEWMICODEAREA(CMRD.MISAFID));
        --客户代码【哈尔滨需要】前面9位是从序号取，后面一位是前面9位数据相加，取4的膜
      ELSIF 客户代码是否营业所 = 'O' THEN
        MI.MIID := FGETMICODE;
      ELSE
        MI.MIID := NVL(CMRD.MICODE, FNEWMICODE('020101')); --FGETSEQUENCE('METERINFO');--
      END IF;
    
      CI.CIID      := MI.MIID;
      MI.MICID     := CI.CIID; --
      MI.MIADR     := CMRD.MIADR; --
      MI.MINAME    := CMRD.MINAME; --
      MI.MINAME2   := CMRD.MINAME2; --
      MI.MISAFID   := CMRD.MISAFID; --
      MI.MICODE    := CMRD.MICODE; --
      MI.MICODE    := MI.MIID; --NVL(CMRD.MICODE,FNEWMICODE(CMRD.MISMFID));--
      CI.CICODE    := MI.MICODE;
      MI.MISMFID   := CI.CISMFID; --
      MI.MIPRMON   := NULL; --
      MI.MIRMON    := NULL; --
      MI.MIBFID    := CMRD.MIBFID; --表册 
      MI.MIRORDER  := CMRD.MIRORDER; --抄表次序 
      MI.MISEQNO   := MI.MIBFID || MI.MIRORDER; --户号（初始化时册号+序号）（哈尔滨：帐卡号） 
      MI.MIPID     := CMRD.MIPID; --
      MI.MINEWDATE := CURRENTDATE;
      MI.MIGPS     := CMRD.MIGPS;
      MI.MIQFH     := CMRD.MIQFH;
      /*MI.MISAVING      := CMRD.MISAVING;*/
      --校验上级水表
      IF CMRD.MIPID IS NOT NULL THEN
        OPEN C_PMI(CMRD.MIPID);
        FETCH C_PMI
          INTO PMI;
        IF C_PMI%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_CRHNO || '无效的上级水表');
        END IF;
        MI.MICLASS := PMI.MICLASS + 1; --
        CLOSE C_PMI;
      ELSE
        MI.MICLASS := 1; --
      END IF;
      MI.MIFLAG := 'Y'; --
      MI.MIRTID := CMRD.MIRTID; --
      MI.MIIFMP := CMRD.MIIFMP; --
      MI.MIIFSP := CMRD.MIIFSP; --
      MI.MISTID := CMRD.MISTID; --
      MI.MIPFID := CMRD.MIPFID; --
      
      MI.MISTATUS := CMRD.MISTATUS; --
      MI.MISTATUS := '34'; --营销部收入用户
      MI.MISTATUSDATE  := NULL; --
      MI.MISTATUSTRANS := NULL; --
      MI.MIRPID        := CMRD.MIRPID; --
      MI.MISIDE        := CMRD.MISIDE; --
      MI.MIPOSITION    := CMRD.MIPOSITION; --
      MI.MIINSCODE     := TO_NUMBER(CMRD.MIINSCODECHAR); --
      MI.MIINSDATE     := CMRD.MIINSDATE; --
      MI.MIINSPER      := CMRD.MIREINSPER; --
      MI.MIREINSCODE   := NULL; --
      MI.MIREINSDATE   := NULL; --
      MI.MIREINSPER    := NULL; --
      MI.MITYPE        := CMRD.MITYPE; --
      MI.MIRCODE       := CMRD.MIINSCODE; --
      MI.MIRCODECHAR   := CMRD.MIINSCODECHAR;
      MI.MIRECDATE     := NULL; --
      MI.MIRECSL       := NULL; --
      MI.MIIFCHARGE    := CMRD.MIIFCHARGE; --
      MI.MIIFSL        := CMRD.MIIFSL; --
      MI.MIIFCHK       := CMRD.MIIFCHK; --
      MI.MIIFWATCH     := CMRD.MIIFWATCH; --
      MI.MIICNO        := CMRD.MIICNO; --
      MI.MIMEMO        := CMRD.MIMEMO; --
      MI.MIPRIID       := CMRD.MIPRIID; --
      MI.MIPRIFLAG     := CMRD.MIPRIFLAG; --
      IF MI.MIPRIFLAG = 'N' THEN
        --如果不是合收表，则合收主表号为自己
        MI.MIPRIID := MI.MIID;
      END IF;
      MI.MIUSENUM      := CMRD.MIUSENUM; --
      MI.MICHARGETYPE  := CMRD.MICHARGETYPE; --
      MI.MIIFCKF       := CMRD.MIIFCKF; --
      MI.MISAVING      := 0; --
      MI.MILB          := CMRD.MILB; --
      MI.MINEWFLAG     := 'Y'; --
      MI.MICPER        := CMRD.MICPER; --
      MI.MIIFTAX       := CMRD.MIIFTAX; --
      MI.MITAXNO       := CMRD.MITAXNO; --
      MI.MIJFKROW      := 0; --
      MI.MIUIID        := CMRD.MIUIID; --
      MI.MICOMMUNITY   := CMRD.MICOMMUNITY; --小区
      MI.MIREMOTENO    := CMRD.MIREMOTENO; --远传表号
      MI.MIREMOTEHUBNO := CMRD.MIREMOTEHUBNO; --远传表HUB号
      MI.MIEMAIL       := CMRD.MIEMAIL; --电子邮件
      MI.MIEMAILFLAG   := CMRD.MIEMAILFLAG; --发账是否发邮件
      MI.MICOLUMN1     := CMRD.MICOLUMN1; --备用字段1
      MI.MICOLUMN2     := CMRD.MICOLUMN2; --备用字段2
      MI.MICOLUMN3     := CMRD.MICOLUMN3; --备用字段3
      MI.MICOLUMN4     := CMRD.MICOLUMN4; --备用字段4
      MI.MIFACE        := CMRD.MIFACE; --备用字段4
      --MI.MICOLUMN9     := CMRD.MICOLUMN9;
      -- MI.MICOLUMN10    := CMRD.MICOLUMN10;
    
      /*MI.MISAVING      := CMRD.MISAVING;*/
      MD.MDMID        := MI.MIID; --
      MD.MDID         := MI.MIID; --FGETSEQUENCE('METERDOC');--立户即入库新水表表
      MD.MDNO         := CMRD.MDNO; --
      MD.MDCALIBER    := CMRD.MDCALIBER; --
      MD.MDBRAND      := CMRD.MDBRAND; --
      MD.MDMODEL      := CMRD.MDMODEL; --
      MD.MDSTATUS     := CMRD.MDSTATUS; --
      MD.MDSTATUSDATE := NULL; --
      MD.MDSTOCKDATE  := CURRENTDATE;
      MD.MDSTORE      := MI.MIID; --安装后位置为水表安装地址
      --MD.BARCODE      := CMRD.BARCODE;
      MD.RFID   := CMRD.RFID;
      MD.IFDZSB := 'N'; --初装水表默认是正常水表，倒装走水表信息维护
      --条形码自动生成=1位区号+8位年月日+10位客户代码。20140411
      MD.BARCODE := SUBSTR(MI.MISMFID, 4, 1) ||
                    TO_CHAR(SYSDATE, 'YYYYMMDD') || MI.MIID;
      MD.DQSFH   := CMRD.DQSFH; --塑封号
      MD.DQGFH   := CMRD.DQGFH; --钢封号
      MD.JCGFH   := CMRD.JCGFH; --稽查封号
      MD.QFH     := CMRD.QHF; --铅封号
    
      MA.MAMID         := MI.MIID; --
      MA.MANO          := CMRD.MANO; --
      MA.MANONAME      := CMRD.MANONAME; --
      MA.MABANKID      := CMRD.MABANKID; --
      MA.MAACCOUNTNO   := CMRD.MAACCOUNTNO; --
      MA.MAACCOUNTNAME := CMRD.MAACCOUNTNAME; --
      MA.MATSBANKID    := CMRD.MATSBANKID; --
      MA.MATSBANKNAME  := CMRD.MATSBANKNAME; --
      MA.MAIFXEZF      := CMRD.MAIFXEZF; --
    
  /*    --判断表身码是否已使用
      SELECT COUNT(*)
        INTO V_NUM
        FROM ST_METERINFO_STORE
       WHERE STATUS = '3'
         AND BSM = CMRD.MDNO;
      IF V_NUM > 0 THEN
        V_COUNT := V_COUNT + 1;
        WLOG( '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 用户名【' || CMRD.CINAME || '】表身码【' || CMRD.MDNO || '】已使用，审核不通过！');
       -- RAISE_APPLICATION_ERROR(ERRCODE, '表身码已使用，审核不通过');
       RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 用户名【' || CMRD.CINAME || '】表身码【' || CMRD.MDNO || '】已使用，审核不通过！');
  
      ELSE
        --设置表身码为已使用
        UPDATE ST_METERINFO_STORE
           SET MIID = MI.MIID, STATUS = '3'
         WHERE BSM = CMRD.MDNO and STATUS = '3' ;
      END IF;
    
      IF MD.DQSFH IS NOT NULL THEN
        --判断塑封号是否已使用  按地区+口径
        SELECT COUNT(*)
          INTO V_NUM
          FROM ST_METERFH_STORE
         WHERE FHSTATUS = '1'
           AND METERFH = MD.DQSFH
           AND FHTYPE = '1' 
           and storeid= MI.MISMFID 
           and caliber =MD.MDCALIBER ;
        IF V_NUM > 0 THEN
          V_COUNT := V_COUNT + 1;
          WLOG('单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中塑封号【' || MD.DQSFH || '】已使用，审核不通过！');
           RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中 用户名【' || CMRD.CINAME || '】中塑封号【' || MD.DQSFH || '】已使用，审核不通过！');
                 
         -- RAISE_APPLICATION_ERROR(ERRCODE, '塑封号已使用，审核不通过');
        ELSE
          --设置塑封号为已使用  按地区+口径
          UPDATE ST_METERFH_STORE
             SET BSM      = MD.MDNO,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = MD.DQSFH
             AND FHTYPE = '1'
             and storeid= MI.MISMFID 
             and caliber =MD.MDCALIBER ;
        END IF;
      END IF;
    
      IF MD.DQGFH IS NOT NULL THEN
        --判断钢封号是否已使用  按地区
        SELECT COUNT(*)
          INTO V_NUM
          FROM ST_METERFH_STORE
         WHERE FHSTATUS = '1'
           AND METERFH = MD.DQGFH
           AND FHTYPE = '2' 
           and storeid= MI.MISMFID  ;
        IF V_NUM > 0 THEN
          V_COUNT := V_COUNT + 1;
          WLOG('单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中钢封号【' || MD.DQGFH || '】已使用，审核不通过！');
        --  RAISE_APPLICATION_ERROR(ERRCODE, '钢封号已使用，审核不通过');
          RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中 用户名【' || CMRD.CINAME || '】中钢封号【' || MD.DQGFH || '】已使用，审核不通过！');
              
          
        ELSE
          --设置钢封号为已使用
          UPDATE ST_METERFH_STORE
             SET BSM      = MD.MDNO,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = MD.DQGFH
             AND FHTYPE = '2'
             and storeid= MI.MISMFID;
        END IF;
      END IF;
    
      IF MD.JCGFH IS NOT NULL THEN
        --判断稽查封号是否已使用
        SELECT COUNT(*)
          INTO V_NUM
          FROM ST_METERFH_STORE
         WHERE FHSTATUS = '1'
           AND METERFH = MD.JCGFH
           AND FHTYPE = '3'
           and storeid= MI.MISMFID;
        IF V_NUM > 0 THEN
          V_COUNT := V_COUNT + 1;
          WLOG('单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中稽查封号【' || MD.JCGFH || '】已使用，审核不通过！');
        --  RAISE_APPLICATION_ERROR(ERRCODE, '稽查封号已使用，审核不通过');
                RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中 用户名【' || CMRD.CINAME || '】中稽查封号【' || MD.JCGFH || '】已使用，审核不通过！');
              
        ELSE
          --设置稽查封号为已使用
          UPDATE ST_METERFH_STORE
             SET BSM      = MD.MDNO,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = MD.JCGFH
             AND FHTYPE = '3'
             and storeid= MI.MISMFID;
        END IF;
      END IF;
    
      IF MD.QFH IS NOT NULL THEN
        --判断铅封号是否已使用
        SELECT COUNT(*)
          INTO V_NUM
          FROM ST_METERFH_STORE
         WHERE FHSTATUS = '1'
           AND METERFH = MD.QFH
           AND FHTYPE = '4'
             and storeid= MI.MISMFID;
        IF V_NUM > 0 THEN
          V_COUNT := V_COUNT + 1;
          WLOG('单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中铅封号【' || MD.QFH || '】已使用，审核不通过！');
         -- RAISE_APPLICATION_ERROR(ERRCODE, '铅封号已使用，审核不通过');
          
         RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中 用户名【' || CMRD.CINAME || '】中铅封号【' || MD.QFH || '】已使用，审核不通过！');
              
        ELSE
          --设置铅封号为已使用
          UPDATE ST_METERFH_STORE
             SET BSM      = MD.MDNO,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = MD.QFH
             AND FHTYPE = '4'
            and storeid= MI.MISMFID; 
        END IF;
      END IF;*/
    
      ----------------------------
      INSERT INTO CUSTINFO VALUES CI;
      INSERT INTO METERINFO VALUES MI;
      INSERT INTO METERDOC VALUES MD;
      INSERT INTO METERACCOUNT VALUES MA;
      --混合用水
      IF CMRD.MIIFMP = 'Y' THEN
        PMD.PMDCID := CI.CIID;
        PMD.PMDMID := MI.MIID;
      
        PMD.PMDPFID    := CMRD.PMDPFID;
        PMD.PMDSCALE   := CMRD.PMDSCALE;
        PMD.PMDID      := 1;
        PMD.PMDTYPE    := CMRD.PMDTYPE;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN1;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN2;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN3;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        PMD.PMDPFID    := CMRD.PMDPFID2;
        PMD.PMDSCALE   := CMRD.PMDSCALE2;
        PMD.PMDID      := 2;
        PMD.PMDTYPE    := CMRD.PMDTYPE2;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN12;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN22;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN32;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        PMD.PMDPFID    := CMRD.PMDPFID3;
        PMD.PMDSCALE   := CMRD.PMDSCALE3;
        PMD.PMDID      := 3;
        PMD.PMDTYPE    := CMRD.PMDTYPE3;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN13;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN23;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN33;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        PMD.PMDPFID    := CMRD.PMDPFID4;
        PMD.PMDSCALE   := CMRD.PMDSCALE4;
        PMD.PMDID      := 4;
        PMD.PMDTYPE    := CMRD.PMDTYPE4;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN14;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN24;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN34;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        UPDATE METERINFO T
           SET T.MIPFID =
               (SELECT MIN(PMDPFID)
                  FROM PRICEMULTIDETAIL
                 WHERE PMDMID = MI.MIID)
         WHERE T.MIID = MI.MIID;
      
      END IF;
      --
      UPDATE CUSTMETERREGDT
         SET CIID    = CI.CIID,
             MIID    = MI.MIID,
             MICODE  = MI.MICODE,
             BARCODE = MD.BARCODE
       WHERE CURRENT OF C_CMRD;
/*      --库存管理开关
      IF FSYSPARA('SYS4') = 'Y' THEN
        UPDATE ST_METERINFO_STORE
           SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = CMRD.MDNO;
      END IF;*/
    END LOOP;
    CLOSE C_CMRD;
  
    IF V_COUNT = 0 THEN
      UPDATE CUSTREGHD
         SET CRHSHDATE = SYSDATE,    CRHSHPER = P_PER, CRHSHFLAG = 'Y'
       WHERE CRHNO = P_CRHNO;
    
       --系统中营销相关流程审批修改人记录发起人，发起人相当于资料受理人员
     
     
     
      UPDATE KPI_TASK T
         SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
       WHERE T.REPORT_ID = TRIM(P_CRHNO);
    END IF;
    --人工立户缴预存  暂不支持
    /*OPEN C_CMRD1;
    LOOP
      FETCH C_CMRD1 INTO HD;
      EXIT WHEN C_CMRD1%NOTFOUND OR C_CMRD1%NOTFOUND IS NULL;
    \*PA_PAY.POSSAVING(MI.MISMFID,HD.CCHCREPER,MI.MIID,CMRD.MISAVING,'XJ','DE',MI.MISMFID);*\
    
    SP_SAVETRANS(MI.MISMFID,HD.CRHCREPER,MI.MIID,CMRD.MISAVING,'S','XJ','DE',FGETSEQUENCE('ENTRUSTLOG'),MI.MISMFID,V_I);
    END LOOP;
    CLOSE C_CMRD1;*/
    --更新流程
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  
/*    -----------------------------------------
    --哈尔滨需求：建账时通过表身码直接维护合收表
    OPEN C_AFCMRD;
    LOOP
      FETCH C_AFCMRD
        INTO V_AFCMRD;
      EXIT WHEN C_AFCMRD%NOTFOUND OR C_AFCMRD%NOTFOUND IS NULL;
      --需要修改UF_CHECK中关于合收标志的校验
      IF V_AFCMRD.MIPRIFLAG = 'Y' AND V_AFCMRD.MIREMOTENO IS NOT NULL THEN
        --根据合收表主表表身码求主表水表号
        SELECT MDMID
          INTO V_MIPRIID
          FROM METERDOC
         WHERE MDNO = V_AFCMRD.MIREMOTENO;
        IF V_MIPRIID IS NOT NULL THEN
          --更新合收子表的合收表主表号
          UPDATE METERINFO
             SET MIPRIID = V_MIPRIID
           WHERE MIID = V_AFCMRD.CIID;
          UPDATE CUSTMETERREGDT
             SET MIPRIID = V_MIPRIID
           WHERE CIID = V_AFCMRD.CIID;
          --检查绑定的合收主表是否维护了合收表标志
          SELECT MIPRIFLAG
            INTO V_MIPRIFLAG
            FROM METERINFO
           WHERE MIID = V_MIPRIID;
          IF V_MIPRIFLAG = 'N' THEN
            UPDATE METERINFO
               SET MIPRIFLAG = 'Y', MIPRIID = MIID
             WHERE MIID = V_MIPRIID;
            UPDATE CUSTMETERREGDT
               SET MIPRIFLAG  = 'Y',
                   MIPRIID    = V_MIPRIID,
                   MIREMOTENO = V_AFCMRD.MIREMOTENO
             WHERE CIID = V_MIPRIID;
          END IF;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '该表身码【' || V_AFCMRD.MIREMOTENO ||
                                  '】不存在，请检查！');
        END IF;
      END IF;
    END LOOP;
    CLOSE C_AFCMRD;*/
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    -----------------------------------------
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  
  --立户审核（一户一表）
  PROCEDURE SP_REGISTER(P_TYPE   IN VARCHAR2,
                        P_CRHNO  IN VARCHAR2,
                        P_PER    IN VARCHAR2,
                        P_COMMIT IN VARCHAR2) AS
    CURSOR C_CMRD IS
      SELECT * FROM CUSTMETERREGDT WHERE CMRDNO = P_CRHNO FOR UPDATE;
  
    CURSOR C_CMRD1 IS
      SELECT * FROM CUSTREGHD WHERE CRHNO = P_CRHNO;
  
    CURSOR C_PCI(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;
  
    CURSOR C_PMI(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MICODE = VMID;
  
    -----------------------------------------
    --哈尔滨需求：建账时通过表身码直接维护合收表
    CURSOR C_AFCMRD IS
      SELECT *
        FROM CUSTMETERREGDT
       WHERE CMRDNO = P_CRHNO
       ORDER BY DECODE(MDNO, MIREMOTENO, 1, 0) DESC
         FOR UPDATE;
  
    V_AFCMRD    CUSTMETERREGDT%ROWTYPE;
    V_MIPRIFLAG VARCHAR2(1);
    V_MIPRIID   VARCHAR2(10);
    -----------------------------------------
  
    V_I           VARCHAR2(50);
    HD            CUSTREGHD%ROWTYPE;
    CRH           CUSTREGHD%ROWTYPE;
    CR            CUSTREGHD%ROWTYPE;
    CMRD          CUSTMETERREGDT%ROWTYPE;
    CI            CUSTINFO%ROWTYPE;
    MI            METERINFO%ROWTYPE;
    MD            METERDOC%ROWTYPE;
    MA            METERACCOUNT%ROWTYPE;
    PCI           CUSTINFO%ROWTYPE;
    PMI           METERINFO%ROWTYPE;
    PMD           PRICEMULTIDETAIL%ROWTYPE;
    FLAGN         NUMBER;
    FLAGY         NUMBER;
    V_SEQTEMP     VARCHAR2(200);
    V_BILLID      VARCHAR2(200);
    V_METERSTATUS METERSTATUS%ROWTYPE;
    V_NUM         NUMBER;
    V_COUNT       NUMBER;
  
  BEGIN
    CALLOGTXT := NULL;
    V_COUNT := 0;
    V_NUM := 0;
    BEGIN
      SELECT * INTO CRH FROM CUSTREGHD WHERE CRHNO = P_CRHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '立户单不存在!');
    END;
    IF CRH.CRHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF CRH.CRHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    SELECT COUNT(*)
      INTO FLAGY
      FROM CUSTMETERREGDT
     WHERE CMRDNO = P_CRHNO
       AND PREDISPOSEFLAG = 'Y';
    IF FLAGY = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要立户的水表!');
    END IF;
    SELECT COUNT(*)
      INTO FLAGN
      FROM CUSTMETERREGDT
     WHERE CMRDNO = P_CRHNO
       AND PREDISPOSEFLAG = 'N';
  
    IF FLAGN > 0 THEN
      BEGIN
        SELECT max(BMID) INTO V_BILLID FROM BILLMAIN WHERE BMTYPE = CRH.CRHLB;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '此种类型单据未定义!');
      END;
      TOOLS.SP_BILLSEQ('108', V_SEQTEMP, 'N');
      CR.CRHNO      := V_SEQTEMP; --单据流水号
      CR.CRHBH      := V_SEQTEMP; --单据编号
      CR.CRHLB      := CRH.CRHLB; --单据类别
      CR.CRHSOURCE  := CRH.CRHSOURCE; --单据来源
      CR.CRHSMFID   := CRH.CRHSMFID; --营销公司
      CR.CRHDEPT    := CRH.CRHDEPT; --立户部门
      CR.CRHCREDATE := SYSDATE; --创建日期
      CR.CRHCREPER  := P_PER; --创建人员
      CR.CRHSHFLAG  := 'N'; --审核标志
      INSERT INTO CUSTREGHD VALUES CR;
      UPDATE CUSTMETERREGDT
         SET CMRDNO = V_SEQTEMP, PREDISPOSEFLAG = 'Y'
       WHERE CMRDNO = P_CRHNO
         AND PREDISPOSEFLAG = 'N';
    END IF;
  
    OPEN C_CMRD;
    LOOP
      FETCH C_CMRD
        INTO CMRD;
      EXIT WHEN C_CMRD%NOTFOUND OR C_CMRD%NOTFOUND IS NULL;
    
      IF FSYSPARA('SYS4') = 'Y' THEN
        IF CMRD.MDNO <> '' THEN
          --START合收表建虚拟表时没有表身码，不做检查 2012-12-21 BY ZHB
          BEGIN
            SELECT STATUS
              INTO V_METERSTATUS.SID
              FROM ST_METERINFO_STORE
             WHERE BSM = CMRD.MDNO;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '该水表未入库【' || CMRD.MDNO || '】不能使用！');
          END;
        
          IF TRIM(V_METERSTATUS.SID) <> '0' THEN
            SELECT SNAME
              INTO V_METERSTATUS.SNAME
              FROM METERSTATUS
             WHERE SID = V_METERSTATUS.SID;
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '该水表状态为【' || V_METERSTATUS.SNAME ||
                                    '】不能使用！');
          END IF; ---END---
        END IF;
      END IF;
      --增加用户--------------------------
      --CI.CIID          := FGETSEQUENCE('CUSTINFO');--
      --CI.CICODE        := NVL(CMRD.CICODE,FNEWCICODE(CMRD.CISMFID));--
      CI.CICONID := CMRD.CICONID; --
      CI.CISMFID := CMRD.CISMFID; --
      CI.CIPID   := CMRD.CIPID; --
      --校验上级用户
      IF CMRD.CIPID IS NOT NULL THEN
        OPEN C_PCI(CMRD.CIPID);
        FETCH C_PCI
          INTO PCI;
        IF C_PCI%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_CRHNO || '无效的上级用户');
        END IF;
        CI.CICLASS := PCI.CICLASS + 1; --
        CLOSE C_PCI;
      ELSE
        CI.CICLASS := 1; --
      END IF;
      CI.CIFLAG        := 'Y'; --
      CI.CINAME        := CMRD.CINAME; --
      CI.CINAME2       := CMRD.CINAME2; --
      CI.CIADR         := CMRD.CIADR; --
      CI.CISTATUS      := CMRD.CISTATUS; --
      CI.CISTATUSDATE  := NULL; --
      CI.CISTATUSTRANS := NULL; --
      CI.CINEWDATE     := CURRENTDATE; --
      CI.CIIDENTITYLB  := CMRD.CIIDENTITYLB; --
      CI.CIIDENTITYNO  := CMRD.CIIDENTITYNO; --
      CI.CIMTEL        := CMRD.CIMTEL; --
      CI.CITEL1        := CMRD.CITEL1; --
      CI.CITEL2        := CMRD.CITEL2; --
      CI.CITEL3        := CMRD.CITEL3; --
      CI.CICONNECTPER  := CMRD.CICONNECTPER; --
      CI.CICONNECTTEL  := CMRD.CICONNECTTEL; --
      CI.CIIFINV       := CMRD.CIIFINV; --
      CI.CIIFSMS       := CMRD.CIIFSMS; --
      CI.CIIFZN        := CMRD.CIIFZN; --
      CI.CIPROJNO      := CMRD.CIPROJNO; --
      CI.CIFILENO      := CMRD.CIFILENO; --
      CI.CIMEMO        := CMRD.CIMEMO; --
      CI.CIDEPTID      := CMRD.CIDEPTID; --
      ----------------------------
      IF 客户代码是否营业所 = 'Y' THEN
        MI.MIID := NVL(CMRD.MICODE, FNEWMICODE(CMRD.MISMFID)); --FGETSEQUENCE('METERINFO');--
      ELSIF 客户代码是否营业所 = 'N' THEN
        IF CMRD.MISAFID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '水表区域不能为NULL');
        END IF;
        IF FNEWMICODEAREA(CMRD.MISAFID) IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '编码规则未定义');
        END IF;
        MI.MIID := NVL(CMRD.MICODE, FNEWMICODEAREA(CMRD.MISAFID));
        --客户代码【哈尔滨需要】前面9位是从序号取，后面一位是前面9位数据相加，取4的膜
      ELSIF 客户代码是否营业所 = 'O' THEN
        MI.MIID := nvl(cmrd.micode,FGETMICODE);
      ELSE
        MI.MIID := NVL(CMRD.MICODE, FNEWMICODE('020101')); --FGETSEQUENCE('METERINFO');--
      END IF;
    
      CI.CIID      := MI.MIID;
      MI.MICID     := CI.CIID; --
      MI.MIADR     := CMRD.MIADR; --
      MI.MINAME    := CMRD.MINAME; --
      MI.MINAME2   := CMRD.MINAME2; --
      MI.MISAFID   := CMRD.MISAFID; --
      MI.MICODE    := CMRD.MICODE; --
      MI.MICODE    := MI.MIID; --NVL(CMRD.MICODE,FNEWMICODE(CMRD.MISMFID));--
      CI.CICODE    := MI.MICODE;
      MI.MISMFID   := CI.CISMFID; --
      MI.MIPRMON   := NULL; --
      MI.MIRMON    := NULL; --
      MI.MIBFID    := CMRD.MIBFID; --表册 
      MI.MIRORDER  := CMRD.MIRORDER; --抄表次序 
      MI.MISEQNO   := MI.MIBFID || MI.MIRORDER; --户号（初始化时册号+序号）（哈尔滨：帐卡号） 
      MI.MIPID     := CMRD.MIPID; --
      MI.MINEWDATE := CURRENTDATE;
      MI.MIGPS     := CMRD.MIGPS;
      MI.MIQFH     := CMRD.MIQFH;
      /*MI.MISAVING      := CMRD.MISAVING;*/
      --校验上级水表
      IF CMRD.MIPID IS NOT NULL THEN
        OPEN C_PMI(CMRD.MIPID);
        FETCH C_PMI
          INTO PMI;
        IF C_PMI%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_CRHNO || '无效的上级水表');
        END IF;
        MI.MICLASS := PMI.MICLASS + 1; --
        CLOSE C_PMI;
      ELSE
        MI.MICLASS := 1; --
      END IF;
      MI.MIFLAG := 'Y'; --
      MI.MIRTID := CMRD.MIRTID; --
      MI.MIIFMP := CMRD.MIIFMP; --
      MI.MIIFSP := CMRD.MIIFSP; --
      MI.MISTID := CMRD.MISTID; --
      MI.MIPFID := CMRD.MIPFID; --
      IF  P_TYPE = 'p' THEN --预立户
        MI.MISTATUS := '2';
      ELSE
        MI.MISTATUS := CMRD.MISTATUS; --
      END IF;
      MI.MISTATUSDATE  := NULL; --
      MI.MISTATUSTRANS := NULL; --
      MI.MIRPID        := CMRD.MIRPID; --
      MI.MISIDE        := CMRD.MISIDE; --
      MI.MIPOSITION    := CMRD.MIPOSITION; --
      MI.MIINSCODE     := TO_NUMBER(CMRD.MIINSCODECHAR); --
      MI.MIINSDATE     := CMRD.MIINSDATE; --
      MI.MIINSPER      := CMRD.MIREINSPER; --
      MI.MIREINSCODE   := NULL; --
      MI.MIREINSDATE   := NULL; --
      MI.MIREINSPER    := NULL; --
      MI.MITYPE        := CMRD.MITYPE; --
      MI.MIRCODE       := CMRD.MIINSCODE; --
      MI.MIRCODECHAR   := CMRD.MIINSCODECHAR;
      MI.MIRECDATE     := NULL; --
      MI.MIRECSL       := NULL; --
      MI.MIIFCHARGE    := CMRD.MIIFCHARGE; --
      MI.MIIFSL        := CMRD.MIIFSL; --
      MI.MIIFCHK       := CMRD.MIIFCHK; --
      MI.MIIFWATCH     := CMRD.MIIFWATCH; --
      MI.MIICNO        := CMRD.MIICNO; --
      MI.MIMEMO        := CMRD.MIMEMO; --
      MI.MIPRIID       := CMRD.MIPRIID; --
      MI.MIPRIFLAG     := CMRD.MIPRIFLAG; --
      IF MI.MIPRIFLAG = 'N' THEN
        --如果不是合收表，则合收主表号为自己
        MI.MIPRIID := MI.MIID;
      END IF;
      MI.MIUSENUM      := CMRD.MIUSENUM; --
      MI.MICHARGETYPE  := CMRD.MICHARGETYPE; --
      MI.MIIFCKF       := CMRD.MIIFCKF; --
      MI.MISAVING      := 0; --
      MI.MILB          := CMRD.MILB; --
      MI.MINEWFLAG     := 'Y'; --
      MI.MICPER        := CMRD.MICPER; --
      MI.MIIFTAX       := CMRD.MIIFTAX; --
      MI.MITAXNO       := CMRD.MITAXNO; --
      MI.MIJFKROW      := 0; --
      MI.MIUIID        := CMRD.MIUIID; --
      MI.MICOMMUNITY   := CMRD.MICOMMUNITY; --小区
      MI.MIREMOTENO    := CMRD.MIREMOTENO; --远传表号
      MI.MIREMOTEHUBNO := CMRD.MIREMOTEHUBNO; --远传表HUB号
      MI.MIEMAIL       := CMRD.MIEMAIL; --电子邮件
      MI.MIEMAILFLAG   := CMRD.MIEMAILFLAG; --发账是否发邮件
      MI.MICOLUMN1     := CMRD.MICOLUMN1; --备用字段1
      MI.MICOLUMN2     := CMRD.MICOLUMN2; --备用字段2
      MI.MICOLUMN3     := CMRD.MICOLUMN3; --备用字段3
      MI.MICOLUMN4     := CMRD.MICOLUMN4; --备用字段4
      MI.MIFACE        := CMRD.MIFACE; --备用字段4
      --加入街道号-- 2016.9
      mi.miyl13 := cmrd.micolumn11;    --街道号
      
      --MI.MICOLUMN9     := CMRD.MICOLUMN9;
      -- MI.MICOLUMN10    := CMRD.MICOLUMN10;
    
      /*MI.MISAVING      := CMRD.MISAVING;*/
      MD.MDMID        := MI.MIID; --
      MD.MDID         := MI.MIID; --FGETSEQUENCE('METERDOC');--立户即入库新水表表
      MD.MDNO         := CMRD.MDNO; --
      MD.MDCALIBER    := CMRD.MDCALIBER; --
      MD.MDBRAND      := CMRD.MDBRAND; --
      MD.MDMODEL      := CMRD.MDMODEL; --
      MD.MDSTATUS     := CMRD.MDSTATUS; --
      MD.MDSTATUSDATE := NULL; --
      MD.MDSTOCKDATE  := CURRENTDATE;
      MD.MDSTORE      := MI.MIID; --安装后位置为水表安装地址
      --MD.BARCODE      := CMRD.BARCODE;
      MD.RFID   := CMRD.RFID;
      MD.IFDZSB := 'N'; --初装水表默认是正常水表，倒装走水表信息维护
      --条形码自动生成=1位区号+8位年月日+10位客户代码。20140411
      MD.BARCODE := SUBSTR(MI.MISMFID, 4, 1) ||
                    TO_CHAR(SYSDATE, 'YYYYMMDD') || MI.MIID;
      MD.DQSFH   := CMRD.DQSFH; --塑封号
      MD.DQGFH   := CMRD.DQGFH; --钢封号
      MD.JCGFH   := CMRD.JCGFH; --稽查封号
      MD.QFH     := CMRD.QHF; --铅封号
    
      MA.MAMID         := MI.MIID; --
      MA.MANO          := CMRD.MANO; --
      MA.MANONAME      := CMRD.MANONAME; --
      MA.MABANKID      := CMRD.MABANKID; --
      MA.MAACCOUNTNO   := CMRD.MAACCOUNTNO; --
      MA.MAACCOUNTNAME := CMRD.MAACCOUNTNAME; --
      MA.MATSBANKID    := CMRD.MATSBANKID; --
      MA.MATSBANKNAME  := CMRD.MATSBANKNAME; --
      MA.MAIFXEZF      := CMRD.MAIFXEZF; --
    
      --判断表身码是否已使用
      SELECT COUNT(*)
        INTO V_NUM
        FROM ST_METERINFO_STORE
       WHERE STATUS = '3'
         AND BSM = CMRD.MDNO;
      IF V_NUM > 0 THEN
        V_COUNT := V_COUNT + 1;
        WLOG( '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 用户名【' || CMRD.CINAME || '】表身码【' || CMRD.MDNO || '】已使用，审核不通过！');
       -- RAISE_APPLICATION_ERROR(ERRCODE, '表身码已使用，审核不通过');
       RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 用户名【' || CMRD.CINAME || '】表身码【' || CMRD.MDNO || '】已使用，审核不通过！');
  
      ELSE
/*        --设置表身码为已使用
        UPDATE ST_METERINFO_STORE
           SET MIID = MI.MIID, STATUS = '3'
         WHERE BSM = CMRD.MDNO and STATUS = '3' ;*/
       --设置表身码为已使用  20140812调整 modiby hb 之前判断错误
        UPDATE ST_METERINFO_STORE
           SET MIID = MI.MIID, STATUS = '3'
         WHERE BSM = CMRD.MDNO  ;
         
      END IF;
    
      IF MD.DQSFH IS NOT NULL THEN
        --判断塑封号是否已使用  按地区+口径
        SELECT COUNT(*)
          INTO V_NUM
          FROM ST_METERFH_STORE
         WHERE FHSTATUS = '1'
           AND METERFH = MD.DQSFH
           AND FHTYPE = '1' 
           and storeid= MI.MISMFID 
           and caliber =MD.MDCALIBER ;
        IF V_NUM > 0 THEN
          V_COUNT := V_COUNT + 1;
          WLOG('单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中塑封号【' || MD.DQSFH || '】已使用，审核不通过！');
           --RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中 用户名【' || CMRD.CINAME || '】中塑封号【' || MD.DQSFH || '】已使用，审核不通过！');
             RAISE_APPLICATION_ERROR(ERRCODE, '第' || CMRD.CMRDROWNO || '行,用户名【' || trim(CMRD.CINAME) || '】 塑封号【' || MD.DQSFH || '】已使用，审核不通过！');
              
         -- RAISE_APPLICATION_ERROR(ERRCODE, '塑封号已使用，审核不通过');
        ELSE
          --设置塑封号为已使用  按地区+口径
          UPDATE ST_METERFH_STORE
             SET BSM      = MD.MDNO,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = MD.DQSFH
             AND FHTYPE = '1'
             and storeid= MI.MISMFID 
             and caliber =MD.MDCALIBER ;
        END IF;
      END IF;
    
      IF MD.DQGFH IS NOT NULL THEN
        --判断钢封号是否已使用  按地区
        SELECT COUNT(*)
          INTO V_NUM
          FROM ST_METERFH_STORE
         WHERE FHSTATUS = '1'
           AND METERFH = MD.DQGFH
           AND FHTYPE = '2' 
           and storeid= MI.MISMFID  ;
        IF V_NUM > 0 THEN
          V_COUNT := V_COUNT + 1;
          WLOG('单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中钢封号【' || MD.DQGFH || '】已使用，审核不通过！');
        --  RAISE_APPLICATION_ERROR(ERRCODE, '钢封号已使用，审核不通过');
          RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中 用户名【' || CMRD.CINAME || '】中钢封号【' || MD.DQGFH || '】已使用，审核不通过！');
              
          
        ELSE
          --设置钢封号为已使用
          UPDATE ST_METERFH_STORE
             SET BSM      = MD.MDNO,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = MD.DQGFH
             AND FHTYPE = '2'
             and storeid= MI.MISMFID;
        END IF;
      END IF;
    
      IF MD.JCGFH IS NOT NULL THEN
        --判断稽查封号是否已使用
        SELECT COUNT(*)
          INTO V_NUM
          FROM ST_METERFH_STORE
         WHERE FHSTATUS = '1'
           AND METERFH = MD.JCGFH
           AND FHTYPE = '3'
           and storeid= MI.MISMFID;
        IF V_NUM > 0 THEN
          V_COUNT := V_COUNT + 1;
          WLOG('单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中稽查封号【' || MD.JCGFH || '】已使用，审核不通过！');
        --  RAISE_APPLICATION_ERROR(ERRCODE, '稽查封号已使用，审核不通过');
                RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中 用户名【' || CMRD.CINAME || '】中稽查封号【' || MD.JCGFH || '】已使用，审核不通过！');
              
        ELSE
          --设置稽查封号为已使用
          UPDATE ST_METERFH_STORE
             SET BSM      = MD.MDNO,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = MD.JCGFH
             AND FHTYPE = '3'
             and storeid= MI.MISMFID;
        END IF;
      END IF;
    
      IF MD.QFH IS NOT NULL THEN
        --判断铅封号是否已使用
        SELECT COUNT(*)
          INTO V_NUM
          FROM ST_METERFH_STORE
         WHERE FHSTATUS = '1'
           AND METERFH = MD.QFH
           AND FHTYPE = '4'
             and storeid= MI.MISMFID;
        IF V_NUM > 0 THEN
          V_COUNT := V_COUNT + 1;
          WLOG('单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中铅封号【' || MD.QFH || '】已使用，审核不通过！');
         -- RAISE_APPLICATION_ERROR(ERRCODE, '铅封号已使用，审核不通过');
          
         RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中 用户名【' || CMRD.CINAME || '】中铅封号【' || MD.QFH || '】已使用，审核不通过！');
              
        ELSE
          --设置铅封号为已使用
          UPDATE ST_METERFH_STORE
             SET BSM      = MD.MDNO,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = MD.QFH
             AND FHTYPE = '4'
            and storeid= MI.MISMFID; 
        END IF;
      END IF;
    
      ----------------------------
      INSERT INTO CUSTINFO VALUES CI;
      INSERT INTO METERINFO VALUES MI;
      INSERT INTO METERDOC VALUES MD;
      INSERT INTO METERACCOUNT VALUES MA;
      --混合用水
      IF CMRD.MIIFMP = 'Y' THEN
        PMD.PMDCID := CI.CIID;
        PMD.PMDMID := MI.MIID;
      
        PMD.PMDPFID    := CMRD.PMDPFID;
        PMD.PMDSCALE   := CMRD.PMDSCALE;
        PMD.PMDID      := 1;
        PMD.PMDTYPE    := CMRD.PMDTYPE;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN1;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN2;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN3;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        PMD.PMDPFID    := CMRD.PMDPFID2;
        PMD.PMDSCALE   := CMRD.PMDSCALE2;
        PMD.PMDID      := 2;
        PMD.PMDTYPE    := CMRD.PMDTYPE2;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN12;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN22;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN32;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        PMD.PMDPFID    := CMRD.PMDPFID3;
        PMD.PMDSCALE   := CMRD.PMDSCALE3;
        PMD.PMDID      := 3;
        PMD.PMDTYPE    := CMRD.PMDTYPE3;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN13;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN23;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN33;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        PMD.PMDPFID    := CMRD.PMDPFID4;
        PMD.PMDSCALE   := CMRD.PMDSCALE4;
        PMD.PMDID      := 4;
        PMD.PMDTYPE    := CMRD.PMDTYPE4;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN14;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN24;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN34;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        UPDATE METERINFO T
           SET T.MIPFID =
               (SELECT MIN(PMDPFID)
                  FROM PRICEMULTIDETAIL
                 WHERE PMDMID = MI.MIID)
         WHERE T.MIID = MI.MIID;
      
      END IF;
      --
      UPDATE CUSTMETERREGDT
         SET CIID    = CI.CIID,
             MIID    = MI.MIID,
             MICODE  = MI.MICODE,
             BARCODE = MD.BARCODE
       WHERE CURRENT OF C_CMRD;
      --库存管理开关
      IF FSYSPARA('SYS4') = 'Y' THEN
        UPDATE ST_METERINFO_STORE
           SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = CMRD.MDNO;
      END IF;
    END LOOP;
    CLOSE C_CMRD;
  
    IF V_COUNT = 0 THEN
      UPDATE CUSTREGHD
         SET CRHSHDATE = SYSDATE,    CRHSHPER = P_PER, CRHSHFLAG = 'Y'
       WHERE CRHNO = P_CRHNO;
    
       --系统中营销相关流程审批修改人记录发起人，发起人相当于资料受理人员
     
     
     
      UPDATE KPI_TASK T
         SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
       WHERE T.REPORT_ID = TRIM(P_CRHNO);
    END IF;
    --人工立户缴预存  暂不支持
    /*OPEN C_CMRD1;
    LOOP
      FETCH C_CMRD1 INTO HD;
      EXIT WHEN C_CMRD1%NOTFOUND OR C_CMRD1%NOTFOUND IS NULL;
    \*PA_PAY.POSSAVING(MI.MISMFID,HD.CCHCREPER,MI.MIID,CMRD.MISAVING,'XJ','DE',MI.MISMFID);*\
    
    SP_SAVETRANS(MI.MISMFID,HD.CRHCREPER,MI.MIID,CMRD.MISAVING,'S','XJ','DE',FGETSEQUENCE('ENTRUSTLOG'),MI.MISMFID,V_I);
    END LOOP;
    CLOSE C_CMRD1;*/
    --更新流程
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  
    -----------------------------------------
    --哈尔滨需求：建账时通过表身码直接维护合收表
    OPEN C_AFCMRD;
    LOOP
      FETCH C_AFCMRD
        INTO V_AFCMRD;
      EXIT WHEN C_AFCMRD%NOTFOUND OR C_AFCMRD%NOTFOUND IS NULL;
      --需要修改UF_CHECK中关于合收标志的校验
      IF V_AFCMRD.MIPRIFLAG = 'Y' AND V_AFCMRD.MIREMOTENO IS NOT NULL THEN
        --根据合收表主表表身码求主表水表号
        SELECT MDMID
          INTO V_MIPRIID
          FROM METERDOC
         WHERE MDNO = V_AFCMRD.MIREMOTENO;
        IF V_MIPRIID IS NOT NULL THEN
          --更新合收子表的合收表主表号
          UPDATE METERINFO
             SET MIPRIID = V_MIPRIID
           WHERE MIID = V_AFCMRD.CIID;
          UPDATE CUSTMETERREGDT
             SET MIPRIID = V_MIPRIID
           WHERE CIID = V_AFCMRD.CIID;
          --检查绑定的合收主表是否维护了合收表标志
          SELECT MIPRIFLAG
            INTO V_MIPRIFLAG
            FROM METERINFO
           WHERE MIID = V_MIPRIID;
          IF V_MIPRIFLAG = 'N' THEN
            UPDATE METERINFO
               SET MIPRIFLAG = 'Y', MIPRIID = MIID
             WHERE MIID = V_MIPRIID;
            UPDATE CUSTMETERREGDT
               SET MIPRIFLAG  = 'Y',
                   MIPRIID    = V_MIPRIID,
                   MIREMOTENO = V_AFCMRD.MIREMOTENO
             WHERE CIID = V_MIPRIID;
          END IF;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '该表身码【' || V_AFCMRD.MIREMOTENO ||
                                  '】不存在，请检查！');
        END IF;
      END IF;
    END LOOP;
    CLOSE C_AFCMRD;
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    -----------------------------------------
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --立户建账管理
  PROCEDURE SP_REGISTER1(P_TYPE   IN VARCHAR2,
                         P_CRHNO  IN VARCHAR2,
                         P_PER    IN VARCHAR2,
                         P_COMMIT IN VARCHAR2) AS
    CURSOR C_CMRD IS
      SELECT * FROM CUSTMETERREGDT WHERE CMRDNO = P_CRHNO FOR UPDATE;
  
    CURSOR C_CMRD1 IS
      SELECT * FROM CUSTREGHD WHERE CRHNO = P_CRHNO;
  
    CURSOR C_PCI(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;
  
    CURSOR C_PMI(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MICODE = VMID;
    V_I           VARCHAR2(50);
    HD            CUSTREGHD%ROWTYPE;
    CRH           CUSTREGHD%ROWTYPE;
    CR            CUSTREGHD%ROWTYPE;
    CMRD          CUSTMETERREGDT%ROWTYPE;
    CI            CUSTINFO%ROWTYPE;
    MI            METERINFO%ROWTYPE;
    MD            METERDOC%ROWTYPE;
    MA            METERACCOUNT%ROWTYPE;
    PCI           CUSTINFO%ROWTYPE;
    PMI           METERINFO%ROWTYPE;
    PMD           PRICEMULTIDETAIL%ROWTYPE;
    FLAGN         NUMBER;
    FLAGY         NUMBER;
    V_NUM         NUMBER;
    V_COUNT       NUMBER;
    V_SEQTEMP     VARCHAR2(200);
    V_BILLID      VARCHAR2(200);
    V_METERSTATUS METERSTATUS%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO CRH FROM CUSTREGHD WHERE CRHNO = P_CRHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '立户单不存在!');
    END;
    IF CRH.CRHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF CRH.CRHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    SELECT COUNT(*)
      INTO FLAGY
      FROM CUSTMETERREGDT
     WHERE CMRDNO = P_CRHNO
       AND PREDISPOSEFLAG = 'Y';
    IF FLAGY = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要立户的水表!');
    END IF;
    SELECT COUNT(*)
      INTO FLAGN
      FROM CUSTMETERREGDT
     WHERE CMRDNO = P_CRHNO
       AND PREDISPOSEFLAG = 'N';
  
    IF FLAGN > 0 THEN
      BEGIN
        SELECT BMID INTO V_BILLID FROM BILLMAIN WHERE BMTYPE = CRH.CRHLB;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '此种类型单据未定义!');
      END;
      TOOLS.SP_BILLSEQ('108', V_SEQTEMP, 'N');
      CR.CRHNO      := V_SEQTEMP; --单据流水号
      CR.CRHBH      := V_SEQTEMP; --单据编号
      CR.CRHLB      := CRH.CRHLB; --单据类别
      CR.CRHSOURCE  := CRH.CRHSOURCE; --单据来源
      CR.CRHSMFID   := CRH.CRHSMFID; --营销公司
      CR.CRHDEPT    := CRH.CRHDEPT; --立户部门
      CR.CRHCREDATE := SYSDATE; --创建日期
      CR.CRHCREPER  := P_PER; --创建人员
      CR.CRHSHFLAG  := 'N'; --审核标志
      INSERT INTO CUSTREGHD VALUES CR;
      UPDATE CUSTMETERREGDT
         SET CMRDNO = V_SEQTEMP, PREDISPOSEFLAG = 'Y'
       WHERE CMRDNO = P_CRHNO
         AND PREDISPOSEFLAG = 'N';
    END IF;
  
    OPEN C_CMRD;
    LOOP
      FETCH C_CMRD
        INTO CMRD;
      EXIT WHEN C_CMRD%NOTFOUND OR C_CMRD%NOTFOUND IS NULL;
    
      IF FSYSPARA('sys4') = 'Y' THEN
        IF CMRD.MDNO <> '' THEN
          --start合收表建虚拟表时没有表身码，不做检查 2012-12-21 by zhb
          BEGIN
            SELECT STATUS
              INTO V_METERSTATUS.SID
              FROM ST_METERINFO_STORE
             WHERE BSM = CMRD.MDNO;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '该水表未入库【' || CMRD.MDNO || '】不能使用！');
          END;
        
          IF TRIM(V_METERSTATUS.SID) <> '0' THEN
            SELECT SNAME
              INTO V_METERSTATUS.SNAME
              FROM METERSTATUS
             WHERE SID = V_METERSTATUS.SID;
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '该水表状态为【' || V_METERSTATUS.SNAME ||
                                    '】不能使用！');
          END IF; ---end---
        END IF;
      END IF;
      --增加用户--------------------------
      --CI.CIID          := fgetsequence('CUSTINFO');--
      --CI.CICODE        := nvl(cmrd.cicode,fnewcicode(cmrd.cismfid));--
      CI.CICONID := CMRD.CICONID; --
      CI.CISMFID := CMRD.CISMFID; --
      CI.CIPID   := CMRD.CIPID; --
      --校验上级用户
      IF CMRD.CIPID IS NOT NULL THEN
        OPEN C_PCI(CMRD.CIPID);
        FETCH C_PCI
          INTO PCI;
        IF C_PCI%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_CRHNO || '无效的上级用户');
        END IF;
        CI.CICLASS := PCI.CICLASS + 1; --
        CLOSE C_PCI;
      ELSE
        CI.CICLASS := 1; --
      END IF;
      CI.CIFLAG        := 'Y'; --
      CI.CINAME        := CMRD.CINAME; --
      CI.CINAME2       := CMRD.CINAME2; --
      CI.CIADR         := CMRD.CIADR; --
      CI.CISTATUS      := CMRD.CISTATUS; --
      CI.CISTATUSDATE  := NULL; --
      CI.CISTATUSTRANS := NULL; --
      CI.CINEWDATE     := CURRENTDATE; --
      CI.CIIDENTITYLB  := CMRD.CIIDENTITYLB; --
      CI.CIIDENTITYNO  := CMRD.CIIDENTITYNO; --
      CI.CIMTEL        := CMRD.CIMTEL; --
      CI.CITEL1        := CMRD.CITEL1; --
      CI.CITEL2        := CMRD.CITEL2; --
      CI.CITEL3        := CMRD.CITEL3; --
      CI.CICONNECTPER  := CMRD.CICONNECTPER; --
      CI.CICONNECTTEL  := CMRD.CICONNECTTEL; --
      CI.CIIFINV       := CMRD.CIIFINV; --
      CI.CIIFSMS       := CMRD.CIIFSMS; --
      CI.CIIFZN        := CMRD.CIIFZN; --
      CI.CIPROJNO      := CMRD.CIPROJNO; --
      CI.CIFILENO      := CMRD.CIFILENO; --
      CI.CIMEMO        := CMRD.CIMEMO; --
      CI.CIDEPTID      := CMRD.CIDEPTID; --
      ----------------------------
      IF 客户代码是否营业所 = 'Y' THEN
        MI.MIID := NVL(CMRD.MICODE, FNEWMICODE(CMRD.MISMFID)); --fgetsequence('METERINFO');--
      ELSIF 客户代码是否营业所 = 'N' THEN
        IF CMRD.MISAFID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '水表区域不能为null');
        END IF;
        IF FNEWMICODEAREA(CMRD.MISAFID) IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '编码规则未定义');
        END IF;
        MI.MIID := NVL(CMRD.MICODE, FNEWMICODEAREA(CMRD.MISAFID));
        --客户代码【哈尔滨需要】前面9位是从序号取，后面一位是前面9位数据相加，取4的膜
      ELSIF 客户代码是否营业所 = 'O' THEN
        MI.MIID := fgetmicode;
      ELSE
        MI.MIID := NVL(CMRD.MICODE, FNEWMICODE('020101')); --fgetsequence('METERINFO');--
      END IF;
    
      CI.CIID      := MI.MIID;
      MI.MICID     := CI.CIID; --
      MI.MIADR     := CMRD.MIADR; --
      MI.MINAME    := CMRD.MINAME; --
      MI.MINAME2   := CMRD.MINAME2; --
      MI.MISAFID   := CMRD.MISAFID; --
      MI.MICODE    := CMRD.MICODE; --
      MI.MICODE    := MI.MIID; --nvl(cmrd.micode,fnewmicode(cmrd.mismfid));--
      CI.CICODE    := MI.MICODE;
      MI.MISMFID   := CI.CISMFID; --
      MI.MIPRMON   := NULL; --
      MI.MIRMON    := NULL; --
      MI.MIBFID    := CMRD.MIBFID; --
      MI.MIRORDER  := CMRD.MIRORDER; --
      MI.MIPID     := CMRD.MIPID; --
      MI.MINEWDATE := CURRENTDATE;
      MI.MIGPS     := CMRD.MIGPS;
      MI.MIQFH     := CMRD.MIQFH;
      /*MI.MISAVING      := cmrd.misaving;*/
      --校验上级水表
      IF CMRD.MIPID IS NOT NULL THEN
        OPEN C_PMI(CMRD.MIPID);
        FETCH C_PMI
          INTO PMI;
        IF C_PMI%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_CRHNO || '无效的上级水表');
        END IF;
        MI.MICLASS := PMI.MICLASS + 1; --
        CLOSE C_PMI;
      ELSE
        MI.MICLASS := 1; --
      END IF;
      MI.MIFLAG        := 'Y'; --
      MI.MIRTID        := CMRD.MIRTID; --
      MI.MIIFMP        := CMRD.MIIFMP; --
      MI.MIIFSP        := CMRD.MIIFSP; --
      MI.MISTID        := CMRD.MISTID; --
      MI.MIPFID        := CMRD.MIPFID; --
      MI.MISTATUS      := CMRD.MISTATUS; --
      MI.MISTATUSDATE  := NULL; --
      MI.MISTATUSTRANS := NULL; --
      MI.MIRPID        := CMRD.MIRPID; --
      MI.MISIDE        := CMRD.MISIDE; --
      MI.MIPOSITION    := CMRD.MIPOSITION; --
      MI.MIINSCODE     := TO_NUMBER(CMRD.MIINSCODECHAR); --
      MI.MIINSDATE     := CMRD.MIINSDATE; --
      MI.MIINSPER      := CMRD.MIREINSPER; --
      MI.MIREINSCODE   := NULL; --
      MI.MIREINSDATE   := NULL; --
      MI.MIREINSPER    := NULL; --
      MI.MITYPE        := CMRD.MITYPE; --
      MI.MIRCODE       := CMRD.MIINSCODE; --
      MI.MIRCODECHAR   := CMRD.MIINSCODECHAR;
      MI.MIRECDATE     := NULL; --
      MI.MIRECSL       := NULL; --
      MI.MIIFCHARGE    := CMRD.MIIFCHARGE; --
      MI.MIIFSL        := CMRD.MIIFSL; --
      MI.MIIFCHK       := CMRD.MIIFCHK; --
      MI.MIIFWATCH     := CMRD.MIIFWATCH; --
      MI.MIICNO        := CMRD.MIICNO; --
      MI.MIMEMO        := CMRD.MIMEMO; --
      MI.MIPRIID       := CMRD.MIPRIID; --
      MI.MIPRIFLAG     := CMRD.MIPRIFLAG; --
      MI.MIUSENUM      := CMRD.MIUSENUM; --
      MI.MICHARGETYPE  := CMRD.MICHARGETYPE; --
      MI.MIIFCKF       := CMRD.MIIFCKF; --
      MI.MISAVING      := 0; --
      MI.MILB          := CMRD.MILB; --
      MI.MINEWFLAG     := 'Y'; --
      MI.MICPER        := CMRD.MICPER; --
      MI.MIIFTAX       := CMRD.MIIFTAX; --
      MI.MITAXNO       := CMRD.MITAXNO; --
      MI.MIJFKROW      := 0; --
      MI.MIUIID        := CMRD.MIUIID; --
      MI.MICOMMUNITY   := CMRD.MICOMMUNITY; --小区
      MI.MIREMOTENO    := CMRD.MIREMOTENO; --远传表号
      MI.MIREMOTEHUBNO := CMRD.MIREMOTEHUBNO; --远传表HUB号
      MI.MIEMAIL       := CMRD.MIEMAIL; --电子邮件
      MI.MIEMAILFLAG   := CMRD.MIEMAILFLAG; --发账是否发邮件
      MI.MICOLUMN1     := CMRD.MICOLUMN1; --备用字段1
      MI.MICOLUMN2     := CMRD.MICOLUMN2; --备用字段2
      MI.MICOLUMN3     := CMRD.MICOLUMN3; --备用字段3
      MI.MICOLUMN4     := CMRD.MICOLUMN4; --备用字段4
      MI.MIFACE        := cmrd.miface; --备用字段4
      --MI.MICOLUMN9     := CMRD.MICOLUMN9;
      -- MI.MICOLUMN10    := CMRD.MICOLUMN10;
    
      /*MI.MISAVING      := cmrd.misaving;*/
      MD.MDMID        := MI.MIID; --
      MD.MDID         := MI.MIID; --fgetsequence('METERDOC');--立户即入库新水表表
      MD.MDNO         := CMRD.MDNO; --
      MD.MDCALIBER    := CMRD.MDCALIBER; --
      MD.MDBRAND      := CMRD.MDBRAND; --
      MD.MDMODEL      := CMRD.MDMODEL; --
      MD.MDSTATUS     := CMRD.MDSTATUS; --
      MD.MDSTATUSDATE := NULL; --
      MD.MDSTOCKDATE  := CURRENTDATE;
      MD.MDSTORE      := MI.MIID; --安装后位置为水表安装地址
      --条形码自动生成=1位区号+8位年月日+10位客户代码。20140411
      MD.BARCODE := substr(MI.MISMFID,4,1)||to_char(sysdate,'YYYYMMDD')||MI.MIID;
      MD.RFID    := CMRD.RFID;
      MD.IFDZSB  := 'N'; --初装水表默认是正常水表，倒装走水表信息维护
       MD.DQSFH   := CMRD.DQSFH; --塑封号
      MD.DQGFH   := CMRD.DQGFH; --钢封号
      MD.JCGFH   := CMRD.JCGFH; --稽查封号
      MD.QFH     := CMRD.QHF; --铅封号
    
      MA.MAMID         := MI.MIID; --
      MA.MANO          := CMRD.MANO; --
      MA.MANONAME      := CMRD.MANONAME; --
      MA.MABANKID      := CMRD.MABANKID; --
      MA.MAACCOUNTNO   := CMRD.MAACCOUNTNO; --
      MA.MAACCOUNTNAME := CMRD.MAACCOUNTNAME; --
      MA.MATSBANKID    := CMRD.MATSBANKID; --
      MA.MATSBANKNAME  := CMRD.MATSBANKNAME; --
      MA.MAIFXEZF      := CMRD.MAIFXEZF; --
      --判断表身码是否已使用
      SELECT COUNT(*)
        INTO V_NUM
        FROM ST_METERINFO_STORE
       WHERE STATUS = '3'
         AND BSM = CMRD.MDNO;
      IF V_NUM > 0 THEN
        V_COUNT := V_COUNT + 1;
        WLOG( '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 用户名【' || CMRD.CINAME || '】表身码【' || CMRD.MDNO || '】已使用，审核不通过！');
       -- RAISE_APPLICATION_ERROR(ERRCODE, '表身码已使用，审核不通过');
       RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 用户名【' || CMRD.CINAME || '】表身码【' || CMRD.MDNO || '】已使用，审核不通过！');
  
      ELSE
/*        --设置表身码为已使用
        UPDATE ST_METERINFO_STORE
           SET MIID = MI.MIID, STATUS = '3'
         WHERE BSM = CMRD.MDNO and STATUS = '3' ;*/
       ---  设置表身码为已使用  20140812调整 modiby hb 之前判断错误
          UPDATE ST_METERINFO_STORE
           SET MIID = MI.MIID, STATUS = '3'
         WHERE BSM = CMRD.MDNO;
      END IF;
    
      IF MD.DQSFH IS NOT NULL THEN
        --判断塑封号是否已使用  按地区+口径
        SELECT COUNT(*)
          INTO V_NUM
          FROM ST_METERFH_STORE
         WHERE FHSTATUS = '1'
           AND METERFH = MD.DQSFH
           AND FHTYPE = '1' 
           and storeid= MI.MISMFID 
           and caliber =MD.MDCALIBER ;
        IF V_NUM > 0 THEN
          V_COUNT := V_COUNT + 1;
          WLOG('单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中塑封号【' || MD.DQSFH || '】已使用，审核不通过！');
           RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中 用户名【' || CMRD.CINAME || '】中塑封号【' || MD.DQSFH || '】已使用，审核不通过！');
                 
         -- RAISE_APPLICATION_ERROR(ERRCODE, '塑封号已使用，审核不通过');
        ELSE
          --设置塑封号为已使用  按地区+口径
          UPDATE ST_METERFH_STORE
             SET BSM      = MD.MDNO,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = MD.DQSFH
             AND FHTYPE = '1'
             and storeid= MI.MISMFID 
             and caliber =MD.MDCALIBER ;
        END IF;
      END IF;
    
      IF MD.DQGFH IS NOT NULL THEN
        --判断钢封号是否已使用  按地区
        SELECT COUNT(*)
          INTO V_NUM
          FROM ST_METERFH_STORE
         WHERE FHSTATUS = '1'
           AND METERFH = MD.DQGFH
           AND FHTYPE = '2' 
           and storeid= MI.MISMFID  ;
        IF V_NUM > 0 THEN
          V_COUNT := V_COUNT + 1;
          WLOG('单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中钢封号【' || MD.DQGFH || '】已使用，审核不通过！');
        --  RAISE_APPLICATION_ERROR(ERRCODE, '钢封号已使用，审核不通过');
          RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中 用户名【' || CMRD.CINAME || '】中钢封号【' || MD.DQGFH || '】已使用，审核不通过！');
              
          
        ELSE
          --设置钢封号为已使用
          UPDATE ST_METERFH_STORE
             SET BSM      = MD.MDNO,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = MD.DQGFH
             AND FHTYPE = '2'
             and storeid= MI.MISMFID;
        END IF;
      END IF;
    
      IF MD.JCGFH IS NOT NULL THEN
        --判断稽查封号是否已使用
        SELECT COUNT(*)
          INTO V_NUM
          FROM ST_METERFH_STORE
         WHERE FHSTATUS = '1'
           AND METERFH = MD.JCGFH
           AND FHTYPE = '3'
           and storeid= MI.MISMFID;
        IF V_NUM > 0 THEN
          V_COUNT := V_COUNT + 1;
          WLOG('单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中稽查封号【' || MD.JCGFH || '】已使用，审核不通过！');
        --  RAISE_APPLICATION_ERROR(ERRCODE, '稽查封号已使用，审核不通过');
                RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中 用户名【' || CMRD.CINAME || '】中稽查封号【' || MD.JCGFH || '】已使用，审核不通过！');
              
        ELSE
          --设置稽查封号为已使用
          UPDATE ST_METERFH_STORE
             SET BSM      = MD.MDNO,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = MD.JCGFH
             AND FHTYPE = '3'
             and storeid= MI.MISMFID;
        END IF;
      END IF;
    
      IF MD.QFH IS NOT NULL THEN
        --判断铅封号是否已使用
        SELECT COUNT(*)
          INTO V_NUM
          FROM ST_METERFH_STORE
         WHERE FHSTATUS = '1'
           AND METERFH = MD.QFH
           AND FHTYPE = '4'
             and storeid= MI.MISMFID;
        IF V_NUM > 0 THEN
          V_COUNT := V_COUNT + 1;
          WLOG('单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中铅封号【' || MD.QFH || '】已使用，审核不通过！');
         -- RAISE_APPLICATION_ERROR(ERRCODE, '铅封号已使用，审核不通过');
          
         RAISE_APPLICATION_ERROR(ERRCODE, '单据【' || P_CRHNO || '】第' || CMRD.CMRDROWNO || '行 中 用户名【' || CMRD.CINAME || '】中铅封号【' || MD.QFH || '】已使用，审核不通过！');
              
        ELSE
          --设置铅封号为已使用
          UPDATE ST_METERFH_STORE
             SET BSM      = MD.MDNO,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = MD.QFH
             AND FHTYPE = '4'
            and storeid= MI.MISMFID; 
        END IF;
      END IF;
      ----------------------------
      INSERT INTO CUSTINFO VALUES CI;
      INSERT INTO METERINFO VALUES MI;
      INSERT INTO METERDOC VALUES MD;
      INSERT INTO METERACCOUNT VALUES MA;
      --混合用水
      IF CMRD.MIIFMP = 'Y' THEN
        PMD.PMDCID := CI.CIID;
        PMD.PMDMID := MI.MIID;
      
        PMD.PMDPFID    := CMRD.PMDPFID;
        PMD.PMDSCALE   := CMRD.PMDSCALE;
        PMD.PMDID      := 1;
        PMD.PMDTYPE    := CMRD.PMDTYPE;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN1;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN2;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN3;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        PMD.PMDPFID    := CMRD.PMDPFID2;
        PMD.PMDSCALE   := CMRD.PMDSCALE2;
        PMD.PMDID      := 2;
        PMD.PMDTYPE    := CMRD.PMDTYPE2;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN12;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN22;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN32;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        PMD.PMDPFID    := CMRD.PMDPFID3;
        PMD.PMDSCALE   := CMRD.PMDSCALE3;
        PMD.PMDID      := 3;
        PMD.PMDTYPE    := CMRD.PMDTYPE3;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN13;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN23;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN33;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        PMD.PMDPFID    := CMRD.PMDPFID4;
        PMD.PMDSCALE   := CMRD.PMDSCALE4;
        PMD.PMDID      := 4;
        PMD.PMDTYPE    := CMRD.PMDTYPE4;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN14;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN24;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN34;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        UPDATE METERINFO T
           SET T.MIPFID =
               (SELECT MIN(PMDPFID)
                  FROM PRICEMULTIDETAIL
                 WHERE PMDMID = MI.MIID)
         WHERE T.MIID = MI.MIID;
      
      END IF;
      --
      UPDATE CUSTMETERREGDT
         SET CIID    = CI.CIID,
             MIID    = MI.MIID,
             MICODE  = MI.MICODE,
             BARCODE = MD.BARCODE
       WHERE CURRENT OF C_CMRD;
      --库存管理开关
      IF FSYSPARA('sys4') = 'Y' THEN
        UPDATE ST_METERINFO_STORE
           SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = CMRD.MDNO;
      END IF;
    END LOOP;
    CLOSE C_CMRD;
  
    UPDATE CUSTREGHD
       SET CRHSHDATE = SYSDATE, CRHSHPER = P_PER, CRHSHFLAG = 'Y'
     WHERE CRHNO = P_CRHNO;
    --人工立户缴预存  暂不支持
    /*open c_cmrd1;
    loop
      fetch c_cmrd1 into hd;
      exit when c_cmrd1%notfound or c_cmrd1%notfound is null;
    \*pa_pay.possaving(mi.mismfid,hd.cchcreper,mi.miid,cmrd.misaving,'XJ','DE',mi.mismfid);*\
    
    sp_savetrans(mi.mismfid,hd.crhcreper,mi.miid,cmrd.misaving,'S','XJ','DE',fgetsequence('ENTRUSTLOG'),mi.mismfid,v_i);
    end loop;
    close c_cmrd1;*/
    --更新流程
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_CRHNO);
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --立户审核（一户多表）
  PROCEDURE SP_REGISTER12(P_TYPE   IN VARCHAR2,
                          P_CRHNO  IN VARCHAR2,
                          P_PER    IN VARCHAR2,
                          P_COMMIT IN VARCHAR2) AS
    CURSOR C_CUSTREGDT IS
      SELECT * FROM CUSTREGDT WHERE CRDNO = P_CRHNO FOR UPDATE;
  
    CURSOR C_METERREGDT(VROWNO IN NUMBER) IS
      SELECT *
        FROM METERREGDT
       WHERE MRDNO = P_CRHNO
         AND MRDROWNO = VROWNO
         FOR UPDATE;
  
    CURSOR C_CUSTINFO(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;
  
    CURSOR C_METERINFO(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID;
  
    CRH CUSTREGHD%ROWTYPE;
    CRD CUSTREGDT%ROWTYPE;
    MRD METERREGDT%ROWTYPE;
    CI  CUSTINFO%ROWTYPE;
    MI  METERINFO%ROWTYPE;
    MD  METERDOC%ROWTYPE;
    MA  METERACCOUNT%ROWTYPE;
    PCI CUSTINFO%ROWTYPE;
    PMI METERINFO%ROWTYPE;
    PMD PRICEMULTIDETAIL%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO CRH FROM CUSTREGHD WHERE CRHNO = P_CRHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '立户单不存在!');
    END;
    IF CRH.CRHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF CRH.CRHSHFLAG = 'C' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
  
    OPEN C_CUSTREGDT;
    LOOP
      FETCH C_CUSTREGDT
        INTO CRD;
      EXIT WHEN C_CUSTREGDT%NOTFOUND OR C_CUSTREGDT%NOTFOUND IS NULL;
      --增加用户--------------------------
      CI.CIID    := FGETSEQUENCE('CUSTINFO'); --
      CI.CICODE  := NVL(CRD.CICODE, FNEWCICODE(CRD.CISMFID)); --
      CI.CICONID := CRD.CICONID; --
      CI.CISMFID := CRD.CISMFID; --
      CI.CIPID   := CRD.CIPID; --
      --校验上级用户
      IF CRD.CIPID IS NOT NULL THEN
        OPEN C_CUSTINFO(CRD.CIPID);
        FETCH C_CUSTINFO
          INTO PCI;
        IF C_CUSTINFO%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_CRHNO || '无效的上级用户');
        END IF;
        CI.CICLASS := PCI.CICLASS + 1; --
        CLOSE C_CUSTINFO;
      ELSE
        CI.CICLASS := 1; --
      END IF;
      CI.CIFLAG        := 'Y'; --
      CI.CINAME        := CRD.CINAME; --
      CI.CINAME2       := CRD.CINAME2; --
      CI.CIADR         := CRD.CIADR; --
      CI.CISTATUS      := CRD.CISTATUS; --
      CI.CISTATUSDATE  := NULL; --
      CI.CISTATUSTRANS := NULL; --
      CI.CINEWDATE     := CURRENTDATE; --
      CI.CIIDENTITYLB  := CRD.CIIDENTITYLB; --
      CI.CIIDENTITYNO  := CRD.CIIDENTITYNO; --
      CI.CIMTEL        := CRD.CIMTEL; --
      CI.CITEL1        := CRD.CITEL1; --
      CI.CITEL2        := CRD.CITEL2; --
      CI.CITEL3        := CRD.CITEL3; --
      CI.CICONNECTPER  := CRD.CICONNECTPER; --
      CI.CICONNECTTEL  := CRD.CICONNECTTEL; --
      CI.CIIFINV       := CRD.CIIFINV; --
      CI.CIIFSMS       := CRD.CIIFSMS; --
      CI.CIIFZN        := CRD.CIIFZN; --
      CI.CIPROJNO      := CRD.CIPROJNO; --
      CI.CIFILENO      := CRD.CIFILENO; --
      CI.CIMEMO        := CRD.CIMEMO; --
      CI.CIDEPTID      := CRD.CIDEPTID; --
    
      INSERT INTO CUSTINFO VALUES CI;
      UPDATE CUSTREGDT SET CIID = CI.CIID WHERE CURRENT OF C_CUSTREGDT;
      --增加水表--------------------------
      OPEN C_METERREGDT(CRD.CRDROWNO);
      LOOP
        FETCH C_METERREGDT
          INTO MRD;
        EXIT WHEN C_METERREGDT%NOTFOUND OR C_METERREGDT%NOTFOUND IS NULL;
        ----------------------------
        MI.MICID := CI.CIID; --
        IF 客户代码是否营业所 = 'Y' THEN
          MI.MIID := NVL(MRD.MICODE, FNEWMICODE(MRD.MISMFID)); --fgetsequence('METERINFO');--
        ELSE
          MI.MIID := NVL(MRD.MICODE, FNEWMICODEAREA(MRD.MISAFID));
        END IF;
        MI.MIADR    := MRD.MIADR; --
        MI.MINAME   := MRD.MINAME; --
        MI.MINAME2  := MRD.MINAME2; --
        MI.MISAFID  := MRD.MISAFID; --
        MI.MICODE   := MRD.MICODE; --
        MI.MICODE   := MI.MIID; --nvl(mrd.micode,fnewmicode(mrd.mismfid));--
        MI.MISMFID  := MRD.MISMFID; --
        MI.MIPRMON  := NULL; --
        MI.MIRMON   := NULL; --
        MI.MIBFID   := MRD.MIBFID; --
        MI.MIRORDER := MRD.MIRORDER; --
        MI.MIPID    := MRD.MIPID; --
        --校验上级水表
        IF MRD.MIPID IS NOT NULL THEN
          OPEN C_METERINFO(MRD.MIPID);
          FETCH C_METERINFO
            INTO PMI;
          IF C_METERINFO%NOTFOUND THEN
            RAISE_APPLICATION_ERROR(ERRCODE, P_CRHNO || '无效的上级水表');
          END IF;
          MI.MICLASS := PMI.MICLASS + 1; --
          CLOSE C_METERINFO;
        ELSE
          MI.MICLASS := 1; --
        END IF;
        MI.MIFLAG        := 'Y'; --
        MI.MIRTID        := MRD.MIRTID; --
        MI.MIIFMP        := MRD.MIIFMP; --
        MI.MIIFSP        := MRD.MIIFSP; --
        MI.MISTID        := MRD.MISTID; --
        MI.MIPFID        := MRD.MIPFID; --
        MI.MISTATUS      := MRD.MISTATUS; --
        MI.MISTATUSDATE  := NULL; --
        MI.MISTATUSTRANS := NULL; --
        MI.MIRPID        := MRD.MIRPID; --
        MI.MISIDE        := MRD.MISIDE; --
        MI.MIPOSITION    := MRD.MIPOSITION; --
        MI.MIINSCODE     := MRD.MIINSCODE; --
        MI.MIINSDATE     := MRD.MIINSDATE; --
        MI.MIINSPER      := MRD.MIREINSPER; --
        MI.MIREINSCODE   := NULL; --
        MI.MIREINSDATE   := NULL; --
        MI.MIREINSPER    := NULL; --
        MI.MITYPE        := MRD.MITYPE; --
        MI.MIRCODE       := MRD.MIINSCODE; --
        MI.MIRECDATE     := NULL; --
        MI.MIRECSL       := NULL; --
        MI.MIIFCHARGE    := MRD.MIIFCHARGE; --
        MI.MIIFSL        := MRD.MIIFSL; --
        MI.MIIFCHK       := MRD.MIIFCHK; --
        MI.MIIFWATCH     := MRD.MIIFWATCH; --
        MI.MIICNO        := MRD.MIICNO; --
        MI.MIMEMO        := MRD.MIMEMO; --
        MI.MIPRIID       := MRD.MIPRIID; --
        MI.MIPRIFLAG     := MRD.MIPRIFLAG; --
        MI.MIUSENUM      := MRD.MIUSENUM; --
        MI.MICHARGETYPE  := MRD.MICHARGETYPE; --
        MI.MISAVING      := 0; --
        MI.MILB          := MRD.MILB; --
        MI.MINEWFLAG     := 'Y'; --
        MI.MICPER        := MRD.MICPER; --
        MI.MIIFTAX       := MRD.MIIFTAX; --
        MI.MITAXNO       := MRD.MITAXNO; --
      
        MD.MDMID        := MI.MIID; --
        MD.MDID         := FGETSEQUENCE('METERDOC'); --立户即入库新水表表
        MD.MDNO         := MRD.MDNO; --
        MD.MDCALIBER    := MRD.MDCALIBER; --
        MD.MDBRAND      := MRD.MDBRAND; --
        MD.MDMODEL      := MRD.MDMODEL; --
        MD.MDSTATUS     := MRD.MDSTATUS; --
        MD.MDSTATUSDATE := NULL; --
        MD.MDSTOCKDATE  := CURRENTDATE;
        MD.MDSTORE      := MI.MIID; --安装后位置为水表安装地址
      
        MA.MAMID         := MI.MIID; --
        MA.MANO          := MRD.MANO; --
        MA.MANONAME      := MRD.MANONAME; --
        MA.MABANKID      := MRD.MABANKID; --
        MA.MAACCOUNTNO   := MRD.MAACCOUNTNO; --
        MA.MAACCOUNTNAME := MRD.MAACCOUNTNAME; --
        MA.MATSBANKID    := MRD.MATSBANKID; --
        MA.MATSBANKNAME  := MRD.MATSBANKNAME; --
        MA.MAIFXEZF      := MRD.MAIFXEZF; --
        ----------------------------
        INSERT INTO METERINFO VALUES MI;
        INSERT INTO METERDOC VALUES MD;
        INSERT INTO METERACCOUNT VALUES MA;
        --混合用水
        IF MRD.MIIFMP = 'Y' THEN
          PMD.PMDCID := CI.CIID;
          PMD.PMDMID := MI.MIID;
        
          PMD.PMDID    := 1;
          PMD.PMDPFID  := MRD.PMDPFID;
          PMD.PMDSCALE := MRD.PMDSCALE;
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
          PMD.PMDID    := 2;
          PMD.PMDPFID  := MRD.PMDPFID2;
          PMD.PMDSCALE := MRD.PMDSCALE2;
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
        --
        UPDATE METERREGDT SET MIID = MI.MIID WHERE CURRENT OF C_METERREGDT;
      END LOOP;
      CLOSE C_METERREGDT;
    
    END LOOP;
    CLOSE C_CUSTREGDT;
  
    UPDATE CUSTREGHD
       SET CRHSHDATE = SYSDATE,  CRHSHPER = P_PER, CRHSHFLAG = 'Y'
     WHERE CRHNO = P_CRHNO;
  
    --更新流程
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_CRHNO);
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  PROCEDURE sp_临时用水立户(P_TYPE   IN VARCHAR2,
                      P_CRHNO  IN VARCHAR2,
                      P_PER    IN VARCHAR2,
                      P_COMMIT IN VARCHAR2) AS
    CURSOR C_CMRD IS
      SELECT * FROM LSYSXXGLDT WHERE CMRDNO = P_CRHNO FOR UPDATE;
  
    CURSOR C_CMRD1 IS
      SELECT * FROM LSYSDT WHERE CRHNO = P_CRHNO;
  
    CURSOR C_PCI(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;
  
    CURSOR C_PMI(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MICODE = VMID;
    V_I           VARCHAR2(50);
    HD            LSYSDT%ROWTYPE;
    CRH           LSYSDT%ROWTYPE;
    CR            LSYSDT%ROWTYPE;
    CMRD          LSYSXXGLDT%ROWTYPE;
    CI            CUSTINFO%ROWTYPE;
    MI            METERINFO%ROWTYPE;
    MD            METERDOC%ROWTYPE;
    MA            METERACCOUNT%ROWTYPE;
    PCI           CUSTINFO%ROWTYPE;
    PMI           METERINFO%ROWTYPE;
    PMD           PRICEMULTIDETAIL%ROWTYPE;
    FLAGN         NUMBER;
    FLAGY         NUMBER;
    V_SEQTEMP     VARCHAR2(200);
    V_BILLID      VARCHAR2(200);
    V_METERSTATUS METERSTATUS%ROWTYPE;
    V_ROW         NUMBER(10);
  BEGIN
    BEGIN
      SELECT * INTO CRH FROM LSYSDT WHERE CRHNO = P_CRHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '立户单不存在!');
    END;
    IF CRH.CRHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF CRH.CRHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    SELECT COUNT(*) INTO FLAGY FROM LSYSXXGLDT WHERE CMRDNO = P_CRHNO;
    IF FLAGY = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要立户的水表!');
    
    END IF;
  
    OPEN C_CMRD;
    LOOP
      FETCH C_CMRD
        INTO CMRD;
      EXIT WHEN C_CMRD%NOTFOUND OR C_CMRD%NOTFOUND IS NULL;
    
      /*IF FSYSPARA('sys4') = 'Y' THEN
        IF CMRD.MDNO <> '' THEN
          --start合收表建虚拟表时没有表身码，不做检查 2012-12-21 by zhb
          BEGIN
            SELECT STATUS
              INTO V_METERSTATUS.SID
              FROM ST_METERINFO_STORE
             WHERE BSM = CMRD.MDNO;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '该水表未入库【' || CMRD.MDNO || '】不能使用！');
          END;
      
          IF TRIM(V_METERSTATUS.SID) <> '0' THEN
            SELECT SNAME
              INTO V_METERSTATUS.SNAME
              FROM METERSTATUS
             WHERE SID = V_METERSTATUS.SID;
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '该水表状态为【' || V_METERSTATUS.SNAME ||
                                    '】不能使用！');
          END IF; ---end---
        END IF;
      END IF;*/
      --增加用户--------------------------
      --CI.CIID          := fgetsequence('CUSTINFO');--
      --CI.CICODE        := nvl(cmrd.cicode,fnewcicode(cmrd.cismfid));--
      CI.CICONID := NULL; --
      CI.CISMFID := CRH.CRHSMFID; --
      CI.CIPID   := NULL; --
      --校验上级用户
    
      CI.CICLASS       := 1;
      CI.CIFLAG        := 'Y'; --
      CI.CINAME        := CMRD.lssqdw; --申请单位
      CI.CINAME2       := CMRD.Lsxmname; --项目名称
      CI.CIADR         := CMRD.lsplace; --
      CI.CISTATUS      := '1'; --
      CI.CISTATUSDATE  := NULL; --
      CI.CISTATUSTRANS := NULL; --
      CI.CINEWDATE     := CURRENTDATE; --
      CI.CIIDENTITYLB  := NULL; --
      CI.CIIDENTITYNO  := NULL; --
      CI.CIMTEL        := CMRD.LSPHONE; --
      CI.CITEL1        := NULL; --
      CI.CITEL2        := NULL; --
      CI.CITEL3        := NULL; --
      CI.CICONNECTPER  := CMRD.LSJBR; --
      CI.CICONNECTTEL  := CMRD.LSPHONE; --
      CI.CIIFINV       := 'N'; --
      CI.CIIFSMS       := 'N'; --
      CI.CIIFZN        := 'N'; --
      CI.CIPROJNO      := CMRD.CMRDNO; --
      CI.CIFILENO      := NULL; --
      CI.CIMEMO        := NULL; --
      CI.CIDEPTID      := CRH.crhdept; --
      ----------------------------
      IF 客户代码是否营业所 = 'Y' THEN
        MI.MIID := NVL(CMRD.LSJJID, FNEWMICODE(CRH.CRHSMFID)); --fgetsequence('METERINFO');--
      ELSIF 客户代码是否营业所 = 'N' THEN
      
        /*IF FNEWMICODEAREA(CMRD.MISAFID) IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '编码规则未定义');
        END IF;*/
        MI.MIID := NVL(CMRD.LSJJID, FNEWMICODEAREA(NULL));
        --客户代码【哈尔滨需要】前面9位是从序号取，后面一位是前面9位数据相加，取4的膜
      ELSIF 客户代码是否营业所 = 'O' THEN
        MI.MIID := fgetmicode;
      ELSE
        MI.MIID := NVL(CMRD.LSJJID, FNEWMICODE('020101')); --fgetsequence('METERINFO');--
      END IF;
      --检查立户信息是否在系统中存在，如果存在提示
      SELECT COUNT(*) INTO V_ROW FROM METERINFO WHERE MIID = MI.MIID;
      IF V_ROW > 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '客户代码:' || MI.MIID || '在系统中已存在！');
      END IF;
      CI.CIID      := MI.MIID;
      MI.MICID     := CI.CIID; --
      MI.MIADR     := CI.CIADR; --
      MI.MINAME    := CI.CINAME; --
      MI.MINAME2   := CI.CINAME2; --
      MI.MISAFID   := NULL; --
      MI.MICODE    := MI.MIID; --nvl(cmrd.micode,fnewmicode(cmrd.mismfid));--
      CI.CICODE    := MI.MICODE;
      MI.MISMFID   := CRH.CRHSMFID; --
      MI.MIPRMON   := NULL; --
      MI.MIRMON    := NULL; --
      MI.MIBFID    := NULL; --
      MI.MIRORDER  := NULL; --
      MI.MIPID     := NULL; --
      MI.MINEWDATE := CURRENTDATE;
      MI.MIGPS     := 'N';
      MI.MIQFH     := NULL;
      /*MI.MISAVING      := cmrd.misaving;*/
      --校验上级水表
      /*IF CMRD.MIPID IS NOT NULL THEN
        OPEN C_PMI(CMRD.MIPID);
        FETCH C_PMI
          INTO PMI;
        IF C_PMI%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_CRHNO || '无效的上级水表');
        END IF;
        MI.MICLASS := PMI.MICLASS + 1; --
        CLOSE C_PMI;
      ELSE
        MI.MICLASS := 1; --
      END IF;*/
      MI.MICLASS       := 1;
      MI.MIFLAG        := 'Y'; --
      MI.MIRTID        := NULL; --
      MI.MIIFMP        := 'N'; --
      MI.MIIFSP        := 'N'; --
      MI.MISTID        := NULL; --行业分类需确定是否需要？
      MI.MIPFID        := 'E09'; --临时用水单价固定基建用水E09 20131122修改
      MI.MISTATUS      := '28'; --临时
      MI.MISTATUSDATE  := NULL; --
      MI.MISTATUSTRANS := NULL; --
      MI.MIRPID        := NULL; --
      MI.MISIDE        := NULL; --
      MI.MIPOSITION    := substrb(CI.CIADR,1,64); --
      MI.MIINSCODE     := 0; --
      MI.MIINSDATE     := CURRENTDATE; --
      MI.MIINSPER      := NULL; --
      MI.MIREINSCODE   := NULL; --
      MI.MIREINSDATE   := NULL; --
      MI.MIREINSPER    := NULL; --
      MI.MITYPE        := '1'; --
      MI.MIRCODE       := 0; --
      MI.MIRCODECHAR   := '0';
      MI.MIRECDATE     := NULL; --
      MI.MIRECSL       := NULL; --
      MI.MIIFCHARGE    := 'Y'; --
      MI.MIIFSL        := 'Y'; --
      MI.MIIFCHK       := 'N'; --
      MI.MIIFWATCH     := 'N'; --
      MI.MIICNO        := NULL; --
      MI.MIMEMO        := NULL; --
      MI.MIPRIID       := MI.MIID; --
      MI.MIPRIFLAG     := 'N'; --
      MI.MIUSENUM      := 0; --
      MI.MICHARGETYPE  := 'X'; --
      MI.MIIFCKF       := '0'; --
      MI.MISAVING      := 0; --
      MI.MILB          := 'H'; --
      MI.MINEWFLAG     := 'Y'; --
      MI.MICPER        := NULL; --
      MI.MIIFTAX       := 'N'; --
      MI.MITAXNO       := NULL; --
      MI.MIJFKROW      := 0; --
      MI.MIUIID        := NULL; --
      MI.MICOMMUNITY   := NULL; --小区
      MI.MIREMOTENO    := NULL; --远传表号
      MI.MIREMOTEHUBNO := NULL; --远传表HUB号
      MI.MIEMAIL       := NULL; --电子邮件
      MI.MIEMAILFLAG   := NULL; --发账是否发邮件
      MI.MICOLUMN1     := NULL; --备用字段1
      MI.MICOLUMN2     := NULL; --备用字段2
      MI.MICOLUMN3     := NULL; --备用字段3
      MI.MICOLUMN4     := NULL; --备用字段4
      MI.MIFACE        := NULL; --备用字段4
      --MI.MICOLUMN9     := CMRD.MICOLUMN9;
      -- MI.MICOLUMN10    := CMRD.MICOLUMN10;
    
      /*MI.MISAVING      := cmrd.misaving;*/
      MD.MDMID        := MI.MIID; --
      MD.MDID         := MI.MIID; --fgetsequence('METERDOC');--立户即入库新水表表
      MD.MDNO         := NULL; --
      MD.MDCALIBER    := NULL; --
      MD.MDBRAND      := NULL; --
      MD.MDMODEL      := NULL; --
      MD.MDSTATUS     := '1'; --
      MD.MDSTATUSDATE := NULL; --
      MD.MDSTOCKDATE  := CURRENTDATE;
      MD.MDSTORE      := MI.MIID; --安装后位置为水表安装地址
      --条形码自动生成=1位区号+8位年月日+10位客户代码。20140411
      MD.BARCODE := substr(MI.MISMFID,4,1)||to_char(sysdate,'YYYYMMDD')||MI.MIID;
      MD.RFID    := NULL;
      MD.IFDZSB  := 'N'; --初装水表默认是正常水表，倒装走水表信息维护
    
      MA.MAMID         := MI.MIID; --
      MA.MANO          := NULL; --
      MA.MANONAME      := NULL; --
      MA.MABANKID      := NULL; --
      MA.MAACCOUNTNO   := NULL; --
      MA.MAACCOUNTNAME := NULL; --
      MA.MATSBANKID    := NULL; --
      MA.MATSBANKNAME  := NULL; --
      MA.MAIFXEZF      := NULL; --
    
      ----------------------------
      INSERT INTO CUSTINFO VALUES CI;
      INSERT INTO METERINFO VALUES MI;
      INSERT INTO METERDOC VALUES MD;
      INSERT INTO METERACCOUNT VALUES MA;
      --混合用水
      /*IF CMRD.MIIFMP = 'Y' THEN
        PMD.PMDCID := CI.CIID;
        PMD.PMDMID := MI.MIID;
      
        PMD.PMDPFID    := CMRD.PMDPFID;
        PMD.PMDSCALE   := CMRD.PMDSCALE;
        PMD.PMDID      := 1;
        PMD.PMDTYPE    := CMRD.PMDTYPE;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN1;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN2;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN3;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        PMD.PMDPFID    := CMRD.PMDPFID2;
        PMD.PMDSCALE   := CMRD.PMDSCALE2;
        PMD.PMDID      := 2;
        PMD.PMDTYPE    := CMRD.PMDTYPE2;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN12;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN22;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN32;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        PMD.PMDPFID    := CMRD.PMDPFID3;
        PMD.PMDSCALE   := CMRD.PMDSCALE3;
        PMD.PMDID      := 3;
        PMD.PMDTYPE    := CMRD.PMDTYPE3;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN13;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN23;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN33;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        PMD.PMDPFID    := CMRD.PMDPFID4;
        PMD.PMDSCALE   := CMRD.PMDSCALE4;
        PMD.PMDID      := 4;
        PMD.PMDTYPE    := CMRD.PMDTYPE4;
        PMD.PMDCOLUMN1 := CMRD.PMDCOLUMN14;
        PMD.PMDCOLUMN2 := CMRD.PMDCOLUMN24;
        PMD.PMDCOLUMN3 := CMRD.PMDCOLUMN34;
      
        IF PMD.PMDPFID IS NOT NULL AND CMRD.PMDSCALE > 0 THEN
          INSERT INTO PRICEMULTIDETAIL VALUES PMD;
        END IF;
      
        UPDATE METERINFO T
           SET T.MIPFID =
               (SELECT MIN(PMDPFID)
                  FROM PRICEMULTIDETAIL
                 WHERE PMDMID = MI.MIID)
         WHERE T.MIID = MI.MIID;
      
      END IF;*/
      --
    
      --库存管理开关
      /*IF FSYSPARA('sys4') = 'Y' THEN
        UPDATE ST_METERINFO_STORE
           SET STATUS = '1', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = CMRD.MDNO;
      END IF;*/
    
      -------------临时用水审核后将客户代码回写到单据单体表lsysxxgldt 的lspzid 临时用水批准编号 -------
      update lsysxxgldt
         set lspzid = mi.miid
       where cmrdno = P_CRHNO
         and cmrdrowno = CMRD.CMRDROWNO;
      -----------------------------------------
    
    END LOOP;
    CLOSE C_CMRD;
  
    UPDATE LSYSDT
       SET CRHSHDATE = SYSDATE,  CRHSHPER = P_PER, CRHSHFLAG = 'Y'
     WHERE CRHNO = P_CRHNO;
  
    --人工立户缴预存  暂不支持
    /*open c_cmrd1;
    loop
      fetch c_cmrd1 into hd;
      exit when c_cmrd1%notfound or c_cmrd1%notfound is null;
    \*pa_pay.possaving(mi.mismfid,hd.cchcreper,mi.miid,cmrd.misaving,'XJ','DE',mi.mismfid);*\
    
    sp_savetrans(mi.mismfid,hd.crhcreper,mi.miid,cmrd.misaving,'S','XJ','DE',fgetsequence('ENTRUSTLOG'),mi.mismfid,v_i);
    end loop;
    close c_cmrd1;*/
    --更新流程
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_CRHNO);
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --变更主程序
  PROCEDURE SP_CUSTCHANGE(P_TYPE   IN VARCHAR2, --操作类型
                          P_CCHNO  IN VARCHAR2, --批次流水
                          P_PER    IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2 --提交标志
                          ) AS
    CH CUSTCHANGEHD%ROWTYPE;
    CD CUSTCHANGEDT%ROWTYPE;
    V_COUNT NUMBER :=0;
    CURSOR C_CUSTCHANGEDT IS
      SELECT *
        FROM CUSTCHANGEDT
       WHERE CCDNO = P_CCHNO
         AND CCDSHFLAG = 'N'
         FOR UPDATE;
  BEGIN
    BEGIN
      SELECT * INTO CH FROM CUSTCHANGEHD WHERE CCHNO = P_CCHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
    END;
    IF CH.CCHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '变更单已审核,不需再审!');
    END IF;
    IF CH.CCHSHFLAG = 'C' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '变更单已取消,不能审!');
    END IF;
  
    if ch.CCHSOURCE = '3' and ch.cchlb ='E'  then  --add 20150419 
     -- 如果单据来源为手机抄表、且变更用水性质 则需要判断当月抄表资料是否有算费通过，算费通过此工单才能审核
     select COUNT(*)
     INTO V_COUNT
      from meterread
     where   mrifrec = 'N' --未算费
       and mrreadok ='Y'  --已经抄表
       and mrdatasource = '9' --资料来源为手机抄表
       AND mrmid = (  SELECT MIID
                      FROM CUSTCHANGEDT
                     WHERE CCDNO = P_CCHNO
                       AND CCDSHFLAG = 'N')
       AND MRMONTH=TO_CHAR(ch.CCHCREDATE,'YYYY.MM') ;
        IF V_COUNT > 0 THEN
           RAISE_APPLICATION_ERROR(ERRCODE, '单据来源为手机抄表、且变更用水性质,当月抄表未进行算费，需算费通过才能审核.请知悉');
         end if ;
    end if ;
    
    OPEN C_CUSTCHANGEDT;
    LOOP
      FETCH C_CUSTCHANGEDT
        INTO CD;
      EXIT WHEN C_CUSTCHANGEDT%NOTFOUND OR C_CUSTCHANGEDT%NOTFOUND IS NULL;
      SP_CUSTCHANGEONE(P_TYPE, CD);
      --
      UPDATE CUSTCHANGEDT
         SET CCDSHFLAG = 'Y', CCDSHDATE = CURRENTDATE, CCDSHPER = P_PER
       WHERE CURRENT OF C_CUSTCHANGEDT;
    END LOOP;
    CLOSE C_CUSTCHANGEDT;
  
    UPDATE CUSTCHANGEHD
       SET CCHSHDATE = SYSDATE,  CCHSHPER = P_PER, CCHSHFLAG = 'Y'
      
     WHERE CCHNO = P_CCHNO;
  
    --更新流程
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_CCHNO);
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --变更主程序单行
  PROCEDURE SP_CUSTCHANGEBYROW(P_TYPE   IN VARCHAR2, --操作类型
                               P_CCHNO  IN VARCHAR2, --批次流水
                               P_ROWNO  IN NUMBER, --行号
                               P_PER    IN VARCHAR2, --操作员
                               P_COMMIT IN VARCHAR2 --提交标志
                               ) AS
    CH CUSTCHANGEHD%ROWTYPE;
    CD CUSTCHANGEDT%ROWTYPE;
  
  BEGIN
    BEGIN
      SELECT * INTO CH FROM CUSTCHANGEHD WHERE CCHNO = P_CCHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
    END;
    /*    IF CH.CCHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '变更单已审核,不需再审!');
    END IF;
    IF CH.CCHSHFLAG = 'C' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '变更单已取消,不能审!');
    END IF;*/
    BEGIN
      SELECT *
        INTO CD
        FROM CUSTCHANGEDT
       WHERE CCDNO = P_CCHNO
         AND CCDROWNO = P_ROWNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '工单信息不存在!');
    END;
    --已经审核不能再审
    IF CD.CCDSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已审核,不需再审!');
    END IF;
    SP_CUSTCHANGEONE(P_TYPE, CD);
    --
    UPDATE CUSTCHANGEDT
       SET CCDSHFLAG = 'Y', CCDSHDATE = CURRENTDATE, CCDSHPER = P_PER
     WHERE CCDNO = P_CCHNO
       AND CCDROWNO = P_ROWNO;
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --变更单个审核过程
  PROCEDURE SP_CUSTCHANGEONE(P_TYPE IN VARCHAR2, --类型
                             P_CD   IN OUT CUSTCHANGEDT%ROWTYPE --单体行变更
                             ) AS
    CDHIS             CUSTCHANGEDTHIS%ROWTYPE;
    CUST              CUSTINFO%ROWTYPE;
    CUSTNEW           CUSTINFO%ROWTYPE;
    METER             METERINFO%ROWTYPE;
    MDOC              METERDOC%ROWTYPE;
    MACCT             METERACCOUNT%ROWTYPE;
    MI                METERINFO%ROWTYPE;
    V_EXIST           NUMBER(10);
    V_COUNT           NUMBER(10);
    v_rcode       NUMBER(10);
    V_MIPID1          METERINFO.MIPID%TYPE;
    V_MIPID2          METERINFO.MIPID%TYPE;
    V_MIPRIID1        METERINFO.MIPRIID%TYPE;
    V_MIPRIID2        METERINFO.MIPRIID%TYPE;
    V_TEMPPMDPFID     PRICEMULTIDETAIL.PMDPFID%TYPE;
    V_PRICEADJUSTLIST PRICEADJUSTLIST%ROWTYPE;
    CUSTMETERCOUNT    NUMBER;
      L_COUNT       NUMBER;
      v_countjh     number;
      V_MDNO   VARCHAR2(20);  
  BEGIN
  
    --查询历史信息
    SELECT *
      INTO CDHIS
      FROM CUSTCHANGEDTHIS T
     WHERE T.CCDNO = P_CD.CCDNO
       AND T.CCDROWNO = P_CD.CCDROWNO; ---  20160509
       --and t.miid = p_cd.miid;           --- 将行号替换成水表编号 解决单据表删除中间行数据后与his表数据行号不一致的问题
    --查询用户信息
    SELECT * INTO CUST FROM CUSTINFO WHERE CIID = P_CD.CIID;
    
    --查询水表信息
    SELECT * INTO METER FROM METERINFO WHERE MIID = P_CD.MIID;
    --查询水表档案信息
    SELECT * INTO MDOC FROM METERDOC WHERE MDMID = P_CD.MDMID;
    --银行信息
    SELECT COUNT(*)
      INTO V_EXIST
      FROM METERACCOUNT
     WHERE MAMID = P_CD.MAMID;
    IF V_EXIST = 1 THEN
      SELECT * INTO MACCT FROM METERACCOUNT WHERE MAMID = P_CD.MAMID;
    END IF;
  
    --更名过户前一户多表拆分
    IF P_TYPE IN ('D', 'Z') THEN
      --查询一户多表信息
      SELECT COUNT(*)
        INTO CUSTMETERCOUNT
        FROM METERINFO
       WHERE MICID = P_CD.CIID;
      IF CUSTMETERCOUNT > 1 THEN
        CUSTNEW        := CUST;
        CUSTNEW.CIID   := FGETSEQUENCE('CUSTINFO');
        CUSTNEW.CICODE := FNEWCICODE(CUST.CISMFID); --
        INSERT INTO CUSTINFO VALUES CUSTNEW;
        UPDATE METERINFO SET MICID = CUSTNEW.CIID WHERE MIID = P_CD.MIID;
        --替换变更目的用户ID
        P_CD.CIID := CUSTNEW.CIID;
      END IF;
    END IF;
    if p_type='50' then
      IF (P_CD.Mircode IS NOT NULL AND CDHIS.Mircode IS NOT NULL AND
       P_CD.Mircode <> CDHIS.Mircode) OR
       (P_CD.Mircode IS NULL AND CDHIS.Mircode IS NOT NULL) OR
       (P_CD.Mircode IS NOT NULL AND CDHIS.Mircode IS NULL) THEN
          IF (METER.Mircode IS NOT NULL AND CDHIS.Mircode IS NOT NULL AND
             METER.Mircode = CDHIS.Mircode) OR
             (METER.Mircode IS NULL AND CDHIS.Mircode IS NULL) THEN
             select count(*) into l_count from meterread where  MrmID = P_CD.MIID;
             if l_count>0 then
                 ROLLBACK;
                  RAISE_APPLICATION_ERROR(ERRCODE,
                                    '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                    P_CD.MIID || ']的' ||
                                    '已经存在抄表计划,请删除此行记录后再进行审核!');
             else
               select count(*) into l_count from meterinfo where  MIID = P_CD.MIID and mistatus in ('1','2');
               if l_count>0 then
                  UPDATE METERINFO SET Mircode = P_CD.Mircode WHERE MIID = P_CD.MIID;
               else
                 ROLLBACK;
                  RAISE_APPLICATION_ERROR(ERRCODE,
                                    '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                    P_CD.MIID || ']的' ||
                                    '不是立户或者预科立户,请删除此行记录后再进行审核!');
               end if;
             end if;
            
          ELSE
            ROLLBACK;
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                    P_CD.MIID || ']的' ||
                                    '营业所已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
          END IF;
       END IF;
    end if;
    --营业所
    IF (P_CD.MISMFID IS NOT NULL AND CDHIS.MISMFID IS NOT NULL AND
       P_CD.MISMFID <> CDHIS.MISMFID) OR
       (P_CD.MISMFID IS NULL AND CDHIS.MISMFID IS NOT NULL) OR
       (P_CD.MISMFID IS NOT NULL AND CDHIS.MISMFID IS NULL) THEN
      IF (METER.MISMFID IS NOT NULL AND CDHIS.MISMFID IS NOT NULL AND
         METER.MISMFID = CDHIS.MISMFID) OR
         (METER.MISMFID IS NULL AND CDHIS.MISMFID IS NULL) THEN
        UPDATE METERINFO SET MISMFID = P_CD.MISMFID WHERE MIID = P_CD.MIID;
        UPDATE CUSTINFO SET CISMFID = P_CD.MISMFID WHERE CIID = P_CD.CIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '营业所已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --产权名
    IF (P_CD.CINAME IS NOT NULL AND CDHIS.CINAME IS NOT NULL AND
       P_CD.CINAME <> CDHIS.CINAME) OR
       (P_CD.CINAME IS NULL AND CDHIS.CINAME IS NOT NULL) OR
       (P_CD.CINAME IS NOT NULL AND CDHIS.CINAME IS NULL) THEN
      IF (CUST.CINAME IS NOT NULL AND CDHIS.CINAME IS NOT NULL AND
         CUST.CINAME = CDHIS.CINAME) OR
         (CUST.CINAME IS NULL AND CDHIS.CINAME IS NULL) THEN
        if  trim(METER.Mipriflag)<>'Y' then  --增肌合抄表判断20140804 王伟
          UPDATE CUSTINFO SET CINAME = P_CD.CINAME WHERE CIID = P_CD.CIID;
        else
          update CUSTINFO SET CINAME = P_CD.CINAME where CIID in ( select micid from METERINFO where MIPRIID in (select distinct MIPRIID from METERINFO where micid=P_CD.CIID ) and mipriflag='Y');
        end if;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,户号:[' ||
                                P_CD.CIID || ']的' ||
                                '用户名称已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --用户地址
    IF (P_CD.CIADR IS NOT NULL AND CDHIS.CIADR IS NOT NULL AND
       P_CD.CIADR <> CDHIS.CIADR) OR
       (P_CD.CIADR IS NULL AND CDHIS.CIADR IS NOT NULL) OR
       (P_CD.CIADR IS NOT NULL AND CDHIS.CIADR IS NULL) THEN
       select count(*)
           into v_countjh
            from CUSTCHANGEDT t
           where T.CCDNO = P_CD.CCDNO
             and CCDSHFLAG = 'Y'
             and t.ciid in 
                 (select micid
                    from METERINFO
                   where MIPRIID in (select distinct MIPRIID
                                       from METERINFO
                                      where micid = P_CD.CIID)
                     and mipriflag = 'Y');
      if v_countjh < 1 then
      IF (CUST.CIADR IS NOT NULL AND CDHIS.CIADR IS NOT NULL AND
         CUST.CIADR = CDHIS.CIADR) OR
         (CUST.CIADR IS NULL AND CDHIS.CIADR IS NULL) THEN
         if  trim(METER.Mipriflag)<>'Y' then
             UPDATE CUSTINFO SET CIADR = P_CD.CIADR WHERE CIID = P_CD.CIID;
         else
           --zhw
           
              /*if v_countjh < 1 then*/
                   update CUSTINFO SET CIADR = P_CD.CIADR where CIID in ( select micid from METERINFO where MIPRIID in (select distinct MIPRIID from METERINFO where micid=P_CD.CIID ) and mipriflag='Y');
              /*end if;*/
         end IF ;
         
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,户号:[' ||
                                P_CD.CIID || ']的' ||
                                '用户地址已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
      end if;
    END IF;
  
    --用户状态
    IF (P_CD.CISTATUS IS NOT NULL AND CDHIS.CISTATUS IS NOT NULL AND
       P_CD.CISTATUS <> CDHIS.CISTATUS) OR
       (P_CD.CISTATUS IS NULL AND CDHIS.CISTATUS IS NOT NULL) OR
       (P_CD.CISTATUS IS NOT NULL AND CDHIS.CISTATUS IS NULL) THEN
      IF (CUST.CISTATUS IS NOT NULL AND CDHIS.CISTATUS IS NOT NULL AND
         CUST.CISTATUS = CDHIS.CISTATUS) OR
         (CUST.CISTATUS IS NULL AND CDHIS.CISTATUS IS NULL) THEN
        UPDATE CUSTINFO
           SET CISTATUS = P_CD.CISTATUS
         WHERE CIID = P_CD.CIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,户号:[' ||
                                P_CD.CIID || ']的' ||
                                '用户状态已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --消防底度
    IF (P_CD.MIJFKROW IS NOT NULL AND CDHIS.MIJFKROW IS NOT NULL AND
       P_CD.MIJFKROW <> CDHIS.MIJFKROW) OR
       (P_CD.MIJFKROW IS NULL AND CDHIS.MIJFKROW IS NOT NULL) OR
       (P_CD.MIJFKROW IS NOT NULL AND CDHIS.MIJFKROW IS NULL) THEN
      IF (METER.MIJFKROW IS NOT NULL AND CDHIS.MIJFKROW IS NOT NULL AND
         METER.MIJFKROW = CDHIS.MIJFKROW) OR
         (METER.MIJFKROW IS NULL AND CDHIS.MIJFKROW IS NULL) THEN
        UPDATE METERINFO
           SET MIJFKROW = P_CD.MIJFKROW
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '消防底度已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --是否提供短信服务
    IF (P_CD.CIIFSMS IS NOT NULL AND CDHIS.CIIFSMS IS NOT NULL AND
       P_CD.CIIFSMS <> CDHIS.CIIFSMS) OR
       (P_CD.CIIFSMS IS NULL AND CDHIS.CIIFSMS IS NOT NULL) OR
       (P_CD.CIIFSMS IS NOT NULL AND CDHIS.CIIFSMS IS NULL) THEN
      IF (CUST.CIIFSMS IS NOT NULL AND CDHIS.CIIFSMS IS NOT NULL AND
         CUST.CIIFSMS = CDHIS.CIIFSMS) OR
         (CUST.CIIFSMS IS NULL AND CDHIS.CIIFSMS IS NULL) THEN
        UPDATE CUSTINFO SET CIIFSMS = P_CD.CIIFSMS WHERE CIID = P_CD.CIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,户号:[' ||
                                P_CD.CIID || ']的' ||
                                '是否提供短信服务已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --档案号
    IF (P_CD.CIFILENO IS NOT NULL AND CDHIS.CIFILENO IS NOT NULL AND
       P_CD.CIFILENO <> CDHIS.CIFILENO) OR
       (P_CD.CIFILENO IS NULL AND CDHIS.CIFILENO IS NOT NULL) OR
       (P_CD.CIFILENO IS NOT NULL AND CDHIS.CIFILENO IS NULL) THEN
      IF (CUST.CIFILENO IS NOT NULL AND CDHIS.CIFILENO IS NOT NULL AND
         CUST.CIFILENO = CDHIS.CIFILENO) OR
         (CUST.CIFILENO IS NULL AND CDHIS.CIFILENO IS NULL) THEN
        UPDATE CUSTINFO
           SET CIFILENO = P_CD.CIFILENO
         WHERE CIID = P_CD.CIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,户号:[' ||
                                P_CD.CIID || ']的' ||
                                '档案号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --用户备注信息
    IF (P_CD.CIMEMO IS NOT NULL AND CDHIS.CIMEMO IS NOT NULL AND
       P_CD.CIMEMO <> CDHIS.CIMEMO) OR
       (P_CD.CIMEMO IS NULL AND CDHIS.CIMEMO IS NOT NULL) OR
       (P_CD.CIMEMO IS NOT NULL AND CDHIS.CIMEMO IS NULL) THEN
      IF (CUST.CIMEMO IS NOT NULL AND CDHIS.CIMEMO IS NOT NULL AND
         CUST.CIMEMO = CDHIS.CIMEMO) OR
         (CUST.CIMEMO IS NULL AND CDHIS.CIMEMO IS NULL) THEN
        UPDATE CUSTINFO SET CIMEMO = P_CD.CIMEMO WHERE CIID = P_CD.CIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,户号:[' ||
                                P_CD.CIID || ']的' ||
                                '用户备注信息已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --表地址
    IF (P_CD.MIADR IS NOT NULL AND CDHIS.MIADR IS NOT NULL AND
       P_CD.MIADR <> CDHIS.MIADR) OR
       (P_CD.MIADR IS NULL AND CDHIS.MIADR IS NOT NULL) OR
       (P_CD.MIADR IS NOT NULL AND CDHIS.MIADR IS NULL) THEN
      IF (METER.MIADR IS NOT NULL AND CDHIS.MIADR IS NOT NULL AND
         METER.MIADR = CDHIS.MIADR) OR
         (METER.MIADR IS NULL AND CDHIS.MIADR IS NULL) THEN
         if  trim(METER.Mipriflag)<>'Y' then
              UPDATE METERINFO SET MIADR = P_CD.MIADR WHERE MIID = P_CD.MIID;
         ELSE
              UPDATE METERINFO SET MIADR = P_CD.MIADR WHERE MIPRIID in (select distinct MIPRIID from METERINFO where micid=P_CD.CIID ) and mipriflag='Y';
         END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '表地址已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --区域
    IF (P_CD.MISAFID IS NOT NULL AND CDHIS.MISAFID IS NOT NULL AND
       P_CD.MISAFID <> CDHIS.MISAFID) OR
       (P_CD.MISAFID IS NULL AND CDHIS.MISAFID IS NOT NULL) OR
       (P_CD.MISAFID IS NOT NULL AND CDHIS.MISAFID IS NULL) THEN
      IF (METER.MISAFID IS NOT NULL AND CDHIS.MISAFID IS NOT NULL AND
         METER.MISAFID = CDHIS.MISAFID) OR
         (METER.MISAFID IS NULL AND CDHIS.MISAFID IS NULL) THEN
        UPDATE METERINFO SET MISAFID = P_CD.MISAFID WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '区域已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --水表备注
    IF (P_CD.MIMEMO IS NOT NULL AND CDHIS.MIMEMO IS NOT NULL AND
       P_CD.MIMEMO <> CDHIS.MIMEMO) OR
       (P_CD.MIMEMO IS NULL AND CDHIS.MIMEMO IS NOT NULL) OR
       (P_CD.MIMEMO IS NOT NULL AND CDHIS.MIMEMO IS NULL) THEN
      IF (METER.MIMEMO IS NOT NULL AND CDHIS.MIMEMO IS NOT NULL AND
         METER.MIMEMO = CDHIS.MIMEMO) OR
         (METER.MIMEMO IS NULL AND CDHIS.MIMEMO IS NULL) THEN
        UPDATE METERINFO SET MIMEMO = P_CD.MIMEMO WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '水表备注已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --条形码
    IF (P_CD.BARCODE IS NOT NULL AND CDHIS.BARCODE IS NOT NULL AND
       P_CD.BARCODE <> CDHIS.BARCODE) OR
       (P_CD.BARCODE IS NULL AND CDHIS.BARCODE IS NOT NULL) OR
       (P_CD.BARCODE IS NOT NULL AND CDHIS.BARCODE IS NULL) THEN
      IF (MDOC.BARCODE IS NOT NULL AND CDHIS.BARCODE IS NOT NULL AND
         MDOC.BARCODE = CDHIS.BARCODE) OR
         (MDOC.BARCODE IS NULL AND CDHIS.BARCODE IS NULL) THEN
        UPDATE METERDOC SET BARCODE = P_CD.BARCODE WHERE MDMID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MDMID || ']的' ||
                                '条形码已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --电子标签
    IF (P_CD.RFID IS NOT NULL AND CDHIS.RFID IS NOT NULL AND
       P_CD.RFID <> CDHIS.RFID) OR
       (P_CD.RFID IS NULL AND CDHIS.RFID IS NOT NULL) OR
       (P_CD.RFID IS NOT NULL AND CDHIS.RFID IS NULL) THEN
      IF (MDOC.RFID IS NOT NULL AND CDHIS.RFID IS NOT NULL AND
         MDOC.RFID = CDHIS.RFID) OR
         (MDOC.RFID IS NULL AND CDHIS.RFID IS NULL) THEN
        UPDATE METERDOC SET RFID = P_CD.RFID WHERE MDMID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MDMID || ']的' ||
                                '电子标签已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --塑封号
    IF (P_CD.DQSFH IS NOT NULL AND CDHIS.DQSFH IS NOT NULL AND
       P_CD.DQSFH <> CDHIS.DQSFH) OR
       (P_CD.DQSFH IS NULL AND CDHIS.DQSFH IS NOT NULL) OR
       (P_CD.DQSFH IS NOT NULL AND CDHIS.DQSFH IS NULL) THEN
      IF (MDOC.DQSFH IS NOT NULL AND CDHIS.DQSFH IS NOT NULL AND
         MDOC.DQSFH = CDHIS.DQSFH) OR
         (MDOC.DQSFH IS NULL AND CDHIS.DQSFH IS NULL) THEN
        UPDATE METERDOC SET DQSFH = P_CD.DQSFH WHERE MDMID = P_CD.MIID;
        UPDATE ST_METERFH_STORE
           SET BSM      = P_CD.MDNO,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_CD.DQSFH
         AND FHTYPE ='1';
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MDMID || ']的' ||
                                '塑封号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --钢封号
    IF (P_CD.DQGFH IS NOT NULL AND CDHIS.DQGFH IS NOT NULL AND
       P_CD.DQGFH <> CDHIS.DQGFH) OR
       (P_CD.DQGFH IS NULL AND CDHIS.DQGFH IS NOT NULL) OR
       (P_CD.DQGFH IS NOT NULL AND CDHIS.DQGFH IS NULL) THEN
      IF (MDOC.DQGFH IS NOT NULL AND CDHIS.DQGFH IS NOT NULL AND
         MDOC.DQGFH = CDHIS.DQGFH) OR
         (MDOC.DQGFH IS NULL AND CDHIS.DQGFH IS NULL) THEN
        UPDATE METERDOC SET DQGFH = P_CD.DQGFH WHERE MDMID = P_CD.MIID;
        UPDATE ST_METERFH_STORE
           SET BSM      = P_CD.MDNO,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_CD.DQGFH
         AND FHTYPE ='2';
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MDMID || ']的' ||
                                '钢封号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --稽查封号
    IF (P_CD.JCGFH IS NOT NULL AND CDHIS.JCGFH IS NOT NULL AND
       P_CD.JCGFH <> CDHIS.JCGFH) OR
       (P_CD.JCGFH IS NULL AND CDHIS.JCGFH IS NOT NULL) OR
       (P_CD.JCGFH IS NOT NULL AND CDHIS.JCGFH IS NULL) THEN
      IF (MDOC.JCGFH IS NOT NULL AND CDHIS.JCGFH IS NOT NULL AND
         MDOC.JCGFH = CDHIS.JCGFH) OR
         (MDOC.JCGFH IS NULL AND CDHIS.JCGFH IS NULL) THEN
        UPDATE METERDOC SET JCGFH = P_CD.JCGFH WHERE MDMID = P_CD.MIID;
        UPDATE ST_METERFH_STORE
           SET BSM      = P_CD.MDNO,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_CD.JCGFH
         AND FHTYPE ='3';
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MDMID || ']的' ||
                                '稽查封号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --铅封号
    IF (P_CD.QHF IS NOT NULL AND CDHIS.QHF IS NOT NULL AND
       P_CD.QHF <> CDHIS.QHF) OR
       (P_CD.QHF IS NULL AND CDHIS.QHF IS NOT NULL) OR
       (P_CD.QHF IS NOT NULL AND CDHIS.QHF IS NULL) THEN
      IF (MDOC.QFH IS NOT NULL AND CDHIS.QHF IS NOT NULL AND
         MDOC.QFH = CDHIS.QHF) OR (MDOC.QFH IS NULL AND CDHIS.QHF IS NULL) THEN
        UPDATE METERDOC SET QFH = P_CD.QHF WHERE MDMID = P_CD.MIID;
        UPDATE ST_METERFH_STORE
           SET BSM      = P_CD.MDNO,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_CD.QHF
         AND FHTYPE ='4';
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MDMID || ']的' ||
                                '铅封号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --是否倒装水表
    IF (P_CD.IFDZSB IS NOT NULL AND CDHIS.IFDZSB IS NOT NULL AND
       P_CD.IFDZSB <> CDHIS.IFDZSB) OR
       (P_CD.IFDZSB IS NULL AND CDHIS.IFDZSB IS NOT NULL) OR
       (P_CD.IFDZSB IS NOT NULL AND CDHIS.IFDZSB IS NULL) THEN
      IF (MDOC.IFDZSB IS NOT NULL AND CDHIS.IFDZSB IS NOT NULL AND
         MDOC.IFDZSB = CDHIS.IFDZSB) OR
         (MDOC.IFDZSB IS NULL AND CDHIS.IFDZSB IS NULL) THEN
        UPDATE METERDOC SET IFDZSB = P_CD.IFDZSB WHERE MDMID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MDMID || ']的' ||
                                '是否倒装水表已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
   
    --合收单位编号
    IF (P_CD.MIUIID IS NOT NULL AND CDHIS.MIUIID IS NOT NULL AND
       P_CD.MIUIID <> CDHIS.MIUIID) OR
       (P_CD.MIUIID IS NULL AND CDHIS.MIUIID IS NOT NULL) OR
       (P_CD.MIUIID IS NOT NULL AND CDHIS.MIUIID IS NULL) THEN
      IF (METER.MIUIID IS NOT NULL AND CDHIS.MIUIID IS NOT NULL AND
         METER.MIUIID = CDHIS.MIUIID) OR
         (METER.MIUIID IS NULL AND CDHIS.MIUIID IS NULL) THEN
        UPDATE METERINFO SET MIUIID = P_CD.MIUIID WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '合收单位编号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --上级水表编号
    IF (P_CD.MIPID IS NOT NULL AND CDHIS.MIPID IS NOT NULL AND
       P_CD.MIPID <> CDHIS.MIPID) OR
       (P_CD.MIPID IS NULL AND CDHIS.MIPID IS NOT NULL) OR
       (P_CD.MIPID IS NOT NULL AND CDHIS.MIPID IS NULL) THEN
      IF (METER.MIPID IS NOT NULL AND CDHIS.MIPID IS NOT NULL AND
         METER.MIPID = CDHIS.MIPID) OR
         (METER.MIPID IS NULL AND CDHIS.MIPID IS NULL) THEN
        IF P_CD.MIPID IS NOT NULL THEN
          IF P_CD.MIPID = P_CD.MICODE THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                    P_CD.MICODE || ']的' ||
                                    '上级水表编不能与自身的客户的代码同!');
          END IF;
          BEGIN
            SELECT *
              INTO MI
              FROM METERINFO
             WHERE MICODE = P_CD.MIPID
               AND MISTATUS <> '7';
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK;
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '变更单体第[' || P_CD.CCDROWNO ||
                                      ']行,水表号:[' || P_CD.MIID || ']的' ||
                                      '上级水表编号不存在!');
          END;
        
          SELECT MIPID
            INTO V_MIPID1
            FROM METERINFO
           WHERE MICODE = P_CD.MIPID
             AND MISTATUS <> '7';
          SELECT MIPID
            INTO V_MIPID2
            FROM METERINFO
           WHERE MIID = P_CD.MIID
             AND MISTATUS <> '7';
          IF (V_MIPID1 IS NOT NULL AND P_CD.MICODE = V_MIPID1) OR
             (V_MIPID2 IS NOT NULL AND V_MIPRIID2 = P_CD.MIPID) THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                    P_CD.MIID || ']的' ||
                                    '此表已是总分表关系，上能再能建总分表关系!');
          END IF;
        
          SELECT MIPRIID
            INTO V_MIPRIID1
            FROM METERINFO
           WHERE MICODE = P_CD.MIPID
             AND MISTATUS <> '7';
          SELECT MIPRIID
            INTO V_MIPRIID2
            FROM METERINFO
           WHERE MIID = P_CD.MIID
             AND MISTATUS <> '7';
          IF V_MIPRIID1 IS NOT NULL AND V_MIPRIID2 IS NOT NULL AND
             V_MIPRIID1 = V_MIPRIID2 THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                    P_CD.MIID || ']的' ||
                                    '上级水表编号与本表为同一连通主表号，请检查!');
          END IF;
        
          BEGIN
            SELECT *
              INTO MI
              FROM METERINFO
             WHERE MICODE = P_CD.MIPID
               AND MISTATUS <> '7'
               AND (MIPRIFLAG = 'N' OR MIPRIFLAG IS NULL OR
                   MICODE = MIPRIID);
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK;
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '变更单体第[' || P_CD.CCDROWNO ||
                                      ']行,水表号:[' || P_CD.MIID || ']的' ||
                                      '上级水表编号为连通表，但不是连通主表，请输入其连通主表号再审核!');
          END;
        
          UPDATE METERINFO
             SET MIPID = P_CD.MIPID, MICLASS = NVL(MI.MICLASS, 1) + 1
           WHERE MIID = P_CD.MIID
              OR MIPRIID = P_CD.MICODE;
        
          UPDATE METERINFO
             SET MIFLAG = 'N'
           WHERE MICODE = P_CD.MIPID
              OR MIPRIID = P_CD.MICODE;
        ELSE
          UPDATE METERINFO
             SET MIPID   = P_CD.MIPID,
                 MICLASS = (CASE
                             WHEN (MICLASS - 1) <= 0 OR MICLASS IS NULL THEN
                              1
                             ELSE
                              (MICLASS - 1)
                           END)
           WHERE MIID = P_CD.MIID
              OR MIPRIID = P_CD.MICODE;
        
          BEGIN
          
            SELECT * INTO MI FROM METERINFO WHERE MICODE = CDHIS.MIPID;
          EXCEPTION
            WHEN OTHERS THEN
              MI.MIID := NULL;
          END;
          IF MI.MIID IS NOT NULL THEN
            SELECT COUNT(*)
              INTO V_EXIST
              FROM METERINFO
             WHERE MIPID = MI.MICODE;
            IF V_EXIST < 1 THEN
              UPDATE METERINFO
                 SET MICLASS = 1, MIFLAG = 'Y'
               WHERE MICODE = CDHIS.MIPID
                  OR MIPRIID = MI.MICODE;
            END IF;
          END IF;
        
        END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '上级水表编号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --抄表方式
    IF (P_CD.MIRTID IS NOT NULL AND CDHIS.MIRTID IS NOT NULL AND
       P_CD.MIRTID <> CDHIS.MIRTID) OR
       (P_CD.MIRTID IS NULL AND CDHIS.MIRTID IS NOT NULL) OR
       (P_CD.MIRTID IS NOT NULL AND CDHIS.MIRTID IS NULL) THEN
      IF (METER.MIRTID IS NOT NULL AND CDHIS.MIRTID IS NOT NULL AND
         METER.MIRTID = CDHIS.MIRTID) OR
         (METER.MIRTID IS NULL AND CDHIS.MIRTID IS NULL) THEN
        UPDATE METERINFO SET MIRTID = P_CD.MIRTID WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '抄表方式已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --移动电话
    IF (P_CD.CIMTEL IS NOT NULL AND CDHIS.CIMTEL IS NOT NULL AND
       P_CD.CIMTEL <> CDHIS.CIMTEL) OR
       (P_CD.CIMTEL IS NULL AND CDHIS.CIMTEL IS NOT NULL) OR
       (P_CD.CIMTEL IS NOT NULL AND CDHIS.CIMTEL IS NULL) THEN
       if  trim(METER.Mipriflag)<>'Y' then
           UPDATE CUSTINFO SET CIMTEL = P_CD.CIMTEL WHERE CIID = P_CD.CIID;
       ELSE
           update CUSTINFO SET CIMTEL = P_CD.CIMTEL where CIID in ( select micid from METERINFO where MIPRIID in (select distinct MIPRIID from METERINFO where micid=P_CD.CIID ) and mipriflag='Y');
       END IF;
    END IF;
    --固定电话1
    IF (P_CD.CITEL1 IS NOT NULL AND CDHIS.CITEL1 IS NOT NULL AND
       P_CD.CITEL1 <> CDHIS.CITEL1) OR
       (P_CD.CITEL1 IS NULL AND CDHIS.CITEL1 IS NOT NULL) OR
       (P_CD.CITEL1 IS NOT NULL AND CDHIS.CITEL1 IS NULL) THEN
       if  trim(METER.Mipriflag)<>'Y' then
            UPDATE CUSTINFO SET CITEL1 = P_CD.CITEL1 WHERE CIID = P_CD.CIID;
       ELSE
           update CUSTINFO SET CITEL1 = P_CD.CITEL1 where CIID in ( select micid from METERINFO where MIPRIID in (select distinct MIPRIID from METERINFO where micid=P_CD.CIID ) and mipriflag='Y');
       END IF;
    END IF;
    --固定电话2
    IF (P_CD.CITEL2 IS NOT NULL AND CDHIS.CITEL2 IS NOT NULL AND
       P_CD.CITEL2 <> CDHIS.CITEL2) OR
       (P_CD.CITEL2 IS NULL AND CDHIS.CITEL2 IS NOT NULL) OR
       (P_CD.CITEL2 IS NOT NULL AND CDHIS.CITEL2 IS NULL) THEN
       if  trim(METER.Mipriflag)<>'Y' then
           UPDATE CUSTINFO SET CITEL2 = P_CD.CITEL2 WHERE CIID = P_CD.CIID;
       ELSE
           update CUSTINFO SET CITEL2 = P_CD.CITEL2 where CIID in ( select micid from METERINFO where MIPRIID in (select distinct MIPRIID from METERINFO where micid=P_CD.CIID ) and mipriflag='Y');
       END  IF;
    END IF;
    --固定电话3
    IF (P_CD.CITEL3 IS NOT NULL AND CDHIS.CITEL3 IS NOT NULL AND
       P_CD.CITEL3 <> CDHIS.CITEL3) OR
       (P_CD.CITEL3 IS NULL AND CDHIS.CITEL3 IS NOT NULL) OR
       (P_CD.CITEL3 IS NOT NULL AND CDHIS.CITEL3 IS NULL) THEN
       if  trim(METER.Mipriflag)<>'Y' then
           UPDATE CUSTINFO SET CITEL3 = P_CD.CITEL3 WHERE CIID = P_CD.CIID;
       ELSE
           update CUSTINFO SET CITEL3 = P_CD.CITEL3 where CIID in ( select micid from METERINFO where MIPRIID in (select distinct MIPRIID from METERINFO where micid=P_CD.CIID ) and mipriflag='Y');
       END IF;
    END IF;
    --证件类型
    IF (P_CD.CIIDENTITYLB IS NOT NULL AND CDHIS.CIIDENTITYLB IS NOT NULL AND
       P_CD.CIIDENTITYLB <> CDHIS.CIIDENTITYLB) OR
       (P_CD.CIIDENTITYLB IS NULL AND CDHIS.CIIDENTITYLB IS NOT NULL) OR
       (P_CD.CIIDENTITYLB IS NOT NULL AND CDHIS.CIIDENTITYLB IS NULL) THEN
       if  trim(METER.Mipriflag)<>'Y' then
            UPDATE CUSTINFO SET CIIDENTITYLB = P_CD.CIIDENTITYLB WHERE CIID = P_CD.CIID;
       ELSE     
            update CUSTINFO SET CIIDENTITYLB = P_CD.CIIDENTITYLB where CIID in ( select micid from METERINFO where MIPRIID in (select distinct MIPRIID from METERINFO where micid=P_CD.CIID ) and mipriflag='Y');
       END IF;
    END IF;
    --证件号码
    IF (P_CD.CIIDENTITYNO IS NOT NULL AND CDHIS.CIIDENTITYNO IS NOT NULL AND
       P_CD.CIIDENTITYNO <> CDHIS.CIIDENTITYNO) OR
       (P_CD.CIIDENTITYNO IS NULL AND CDHIS.CIIDENTITYNO IS NOT NULL) OR
       (P_CD.CIIDENTITYNO IS NOT NULL AND CDHIS.CIIDENTITYNO IS NULL) THEN
       if  trim(METER.Mipriflag)<>'Y' then
           UPDATE CUSTINFO    SET CIIDENTITYNO = P_CD.CIIDENTITYNO  WHERE CIID = P_CD.CIID;
       ELSE  
           update CUSTINFO SET CIIDENTITYNO = P_CD.CIIDENTITYNO where CIID in ( select micid from METERINFO where MIPRIID in (select distinct MIPRIID from METERINFO where micid=P_CD.CIID ) and mipriflag='Y');
       END IF;
    END IF;
    --联系人
    IF (P_CD.CICONNECTPER IS NOT NULL AND CDHIS.CICONNECTPER IS NOT NULL AND
       P_CD.CICONNECTPER <> CDHIS.CICONNECTPER) OR
       (P_CD.CICONNECTPER IS NULL AND CDHIS.CICONNECTPER IS NOT NULL) OR
       (P_CD.CICONNECTPER IS NOT NULL AND CDHIS.CICONNECTPER IS NULL) THEN
       if  trim(METER.Mipriflag)<>'Y' then
            UPDATE CUSTINFO  SET CICONNECTPER = P_CD.CICONNECTPER   WHERE CIID = P_CD.CIID;
       ELSE
            update CUSTINFO SET CICONNECTPER = P_CD.CICONNECTPER where CIID in ( select micid from METERINFO where MIPRIID in (select distinct MIPRIID from METERINFO where micid=P_CD.CIID ) and mipriflag='Y');
       END IF;
    END IF;
    --联系电话
    IF (P_CD.CICONNECTTEL IS NOT NULL AND CDHIS.CICONNECTTEL IS NOT NULL AND
       P_CD.CICONNECTTEL <> CDHIS.CICONNECTTEL) OR
       (P_CD.CICONNECTTEL IS NULL AND CDHIS.CICONNECTTEL IS NOT NULL) OR
       (P_CD.CICONNECTTEL IS NOT NULL AND CDHIS.CICONNECTTEL IS NULL) THEN
       if  trim(METER.Mipriflag)<>'Y' then
           UPDATE CUSTINFO   SET CICONNECTTEL = P_CD.CICONNECTTEL  WHERE CIID = P_CD.CIID;
       ELSE
           update CUSTINFO SET CICONNECTTEL = P_CD.CICONNECTTEL where CIID in ( select micid from METERINFO where MIPRIID in (select distinct MIPRIID from METERINFO where micid=P_CD.CIID ) and mipriflag='Y');
       END IF;
    END IF;
    --是否滞纳金
    IF (P_CD.CIIFZN IS NOT NULL AND CDHIS.CIIFZN IS NOT NULL AND
       P_CD.CIIFZN <> CDHIS.CIIFZN) OR
       (P_CD.CIIFZN IS NULL AND CDHIS.CIIFZN IS NOT NULL) OR
       (P_CD.CIIFZN IS NOT NULL AND CDHIS.CIIFZN IS NULL) THEN
      UPDATE CUSTINFO SET CIIFZN = P_CD.CIIFZN WHERE CIID = P_CD.CIID;
    END IF;
    --单一用水
    IF P_CD.MIIFMP = 'N' THEN
      --价格分类
      --单价变更单价
      IF (METER.MIIFMP = 'N' AND
         ((P_CD.MIPFID IS NOT NULL AND CDHIS.MIPFID IS NOT NULL AND
         P_CD.MIPFID <> CDHIS.MIPFID) OR
         (P_CD.MIPFID IS NULL AND CDHIS.MIPFID IS NOT NULL) OR
         (P_CD.MIPFID IS NOT NULL AND CDHIS.MIPFID IS NULL))) OR
         (METER.MIIFMP = 'Y') THEN
      
        IF CDHIS.MIIFMP <> METER.MIIFMP THEN
          ROLLBACK;
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                  P_CD.MIID || ']的' ||
                                  '价格分类已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
        
        END IF;
        IF CDHIS.MIIFMP = METER.MIIFMP AND CDHIS.MIIFMP = 'N' AND
           METER.MIIFMP = 'N' AND
           NOT ((METER.MIPFID IS NOT NULL AND CDHIS.MIPFID IS NOT NULL AND
            METER.MIPFID = CDHIS.MIPFID) OR
            (METER.MIPFID IS NULL AND CDHIS.MIPFID IS NULL)) THEN
        
          ROLLBACK;
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                  P_CD.MIID || ']的' ||
                                  '价格分类已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
        
        END IF;
      
        IF CDHIS.MIIFMP = METER.MIIFMP AND CDHIS.MIIFMP = 'Y' AND
           METER.MIIFMP = 'Y' THEN
        
          IF CDHIS.PMDPFID IS NOT NULL THEN
            SELECT COUNT(*)
              INTO V_COUNT
              FROM PRICEMULTIDETAIL
             WHERE PMDMID = CDHIS.MIID
               AND PMDPFID = CDHIS.PMDPFID
               AND PMDID = CDHIS.PMDID
               AND PMDSCALE = CDHIS.PMDSCALE
                  -- AND PMDTYPE =CDHIS.PMDTYPE
                  
               AND (PMDTYPE = CDHIS.PMDTYPE OR
                   (PMDTYPE IS NULL AND CDHIS.PMDTYPE IS NULL))
                  
               AND (PMDCOLUMN1 = CDHIS.PMDCOLUMN1 OR
                   (PMDCOLUMN1 IS NULL AND CDHIS.PMDCOLUMN1 IS NULL))
               AND (PMDCOLUMN2 = CDHIS.PMDCOLUMN2 OR
                   (PMDCOLUMN2 IS NULL AND CDHIS.PMDCOLUMN2 IS NULL))
               AND (PMDCOLUMN3 = CDHIS.PMDCOLUMN3 OR
                   (PMDCOLUMN3 IS NULL AND CDHIS.PMDCOLUMN3 IS NULL));
            IF V_COUNT = 0 THEN
              ROLLBACK;
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '变更单体第[' || P_CD.CCDROWNO ||
                                      ']行,水表号:[' || P_CD.MIID || ']的' ||
                                      '价格分类已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
            
            END IF;
          END IF;
          IF CDHIS.PMDPFID2 IS NOT NULL AND P_CD.MIIFMP = METER.MIIFMP THEN
            SELECT COUNT(*)
              INTO V_COUNT
              FROM PRICEMULTIDETAIL
             WHERE PMDMID = CDHIS.MIID
               AND PMDPFID = CDHIS.PMDPFID2
               AND PMDID = CDHIS.PMDID2
               AND PMDSCALE = CDHIS.PMDSCALE2
                  --  AND PMDTYPE =CDHIS.PMDTYPE2
               AND (PMDTYPE = CDHIS.PMDTYPE OR
                   (PMDTYPE IS NULL AND CDHIS.PMDTYPE IS NULL))
                  
               AND (PMDCOLUMN1 = CDHIS.PMDCOLUMN12 OR
                   (PMDCOLUMN1 IS NULL AND CDHIS.PMDCOLUMN12 IS NULL))
               AND (PMDCOLUMN2 = CDHIS.PMDCOLUMN22 OR
                   (PMDCOLUMN2 IS NULL AND CDHIS.PMDCOLUMN22 IS NULL))
               AND (PMDCOLUMN3 = CDHIS.PMDCOLUMN32 OR
                   (PMDCOLUMN3 IS NULL AND CDHIS.PMDCOLUMN32 IS NULL));
            IF V_COUNT = 0 THEN
              ROLLBACK;
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '变更单体第[' || P_CD.CCDROWNO ||
                                      ']行1,水表号:[' || P_CD.MIID || ']的' ||
                                      '价格分类已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
            
            END IF;
          END IF;
          IF CDHIS.PMDPFID3 IS NOT NULL THEN
            SELECT COUNT(*)
              INTO V_COUNT
              FROM PRICEMULTIDETAIL
             WHERE PMDMID = CDHIS.MIID
               AND PMDPFID = CDHIS.PMDPFID3
               AND PMDID = CDHIS.PMDID3
               AND PMDSCALE = CDHIS.PMDSCALE3
                  -- AND PMDTYPE =CDHIS.PMDTYPE3
               AND (PMDTYPE = CDHIS.PMDTYPE OR
                   (PMDTYPE IS NULL AND CDHIS.PMDTYPE IS NULL))
                  
               AND (PMDCOLUMN1 = CDHIS.PMDCOLUMN13 OR
                   (PMDCOLUMN1 IS NULL AND CDHIS.PMDCOLUMN13 IS NULL))
               AND (PMDCOLUMN2 = CDHIS.PMDCOLUMN23 OR
                   (PMDCOLUMN2 IS NULL AND CDHIS.PMDCOLUMN23 IS NULL))
               AND (PMDCOLUMN3 = CDHIS.PMDCOLUMN33 OR
                   (PMDCOLUMN3 IS NULL AND CDHIS.PMDCOLUMN33 IS NULL));
            IF V_COUNT = 0 THEN
              ROLLBACK;
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '变更单体第[' || P_CD.CCDROWNO ||
                                      ']行,水表号:[' || P_CD.MIID || ']的' ||
                                      '价格分类已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
            
            END IF;
          END IF;
          IF CDHIS.PMDPFID4 IS NOT NULL THEN
            SELECT COUNT(*)
              INTO V_COUNT
              FROM PRICEMULTIDETAIL
             WHERE PMDMID = CDHIS.MIID
               AND PMDPFID = CDHIS.PMDPFID4
               AND PMDID = CDHIS.PMDID4
               AND PMDSCALE = CDHIS.PMDSCALE4
                  -- AND PMDTYPE =CDHIS.PMDTYPE4
               AND (PMDTYPE = CDHIS.PMDTYPE OR
                   (PMDTYPE IS NULL AND CDHIS.PMDTYPE IS NULL))
                  
               AND (PMDCOLUMN1 = CDHIS.PMDCOLUMN14 OR
                   (PMDCOLUMN1 IS NULL AND CDHIS.PMDCOLUMN14 IS NULL))
               AND (PMDCOLUMN2 = CDHIS.PMDCOLUMN24 OR
                   (PMDCOLUMN2 IS NULL AND CDHIS.PMDCOLUMN24 IS NULL))
               AND (PMDCOLUMN3 = CDHIS.PMDCOLUMN34 OR
                   (PMDCOLUMN3 IS NULL AND CDHIS.PMDCOLUMN34 IS NULL));
            IF V_COUNT = 0 THEN
              ROLLBACK;
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '变更单体第[' || P_CD.CCDROWNO ||
                                      ']行,水表号:[' || P_CD.MIID || ']的' ||
                                      '价格分类已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
            
            END IF;
          END IF;
        END IF;
      
        DELETE PRICEMULTIDETAIL WHERE PMDMID = P_CD.MIID;
      
        UPDATE METERINFO
           SET MIPFID = P_CD.MIPFID, MIIFMP = 'N'
         WHERE MIID = P_CD.MIID;
      
      END IF;
    ELSIF P_CD.MIIFMP = 'Y' THEN
      --用水性质
      IF (METER.MIIFMP = 'Y' AND
         (((P_CD.PMDPFID IS NOT NULL AND CDHIS.PMDPFID IS NOT NULL AND
         P_CD.PMDPFID <> CDHIS.PMDPFID) OR
         (P_CD.PMDPFID IS NULL AND CDHIS.PMDPFID IS NOT NULL) OR
         (P_CD.PMDPFID IS NOT NULL AND CDHIS.PMDPFID IS NULL) OR
         (P_CD.PMDSCALE IS NOT NULL AND CDHIS.PMDSCALE IS NOT NULL AND
         P_CD.PMDSCALE <> CDHIS.PMDSCALE) OR
         (P_CD.PMDSCALE IS NULL AND CDHIS.PMDSCALE IS NOT NULL) OR
         (P_CD.PMDSCALE IS NOT NULL AND CDHIS.PMDSCALE IS NULL) OR
         (P_CD.PMDTYPE IS NOT NULL AND CDHIS.PMDTYPE IS NOT NULL AND
         P_CD.PMDTYPE <> CDHIS.PMDTYPE) OR
         (P_CD.PMDTYPE IS NULL AND CDHIS.PMDTYPE IS NOT NULL) OR
         (P_CD.PMDTYPE IS NOT NULL AND CDHIS.PMDTYPE IS NULL) OR
         (P_CD.PMDCOLUMN1 IS NOT NULL AND CDHIS.PMDCOLUMN1 IS NOT NULL AND
         P_CD.PMDCOLUMN1 <> CDHIS.PMDCOLUMN1) OR
         (P_CD.PMDCOLUMN1 IS NULL AND CDHIS.PMDCOLUMN1 IS NOT NULL) OR
         (P_CD.PMDCOLUMN1 IS NOT NULL AND CDHIS.PMDCOLUMN1 IS NULL) OR
         (P_CD.PMDCOLUMN2 IS NOT NULL AND CDHIS.PMDCOLUMN2 IS NOT NULL AND
         P_CD.PMDCOLUMN2 <> CDHIS.PMDCOLUMN2) OR
         (P_CD.PMDCOLUMN2 IS NULL AND CDHIS.PMDCOLUMN2 IS NOT NULL) OR
         (P_CD.PMDCOLUMN2 IS NOT NULL AND CDHIS.PMDCOLUMN2 IS NULL) OR
         (P_CD.PMDCOLUMN3 IS NOT NULL AND CDHIS.PMDCOLUMN3 IS NOT NULL AND
         P_CD.PMDCOLUMN3 <> CDHIS.PMDCOLUMN3) OR
         (P_CD.PMDCOLUMN3 IS NULL AND CDHIS.PMDCOLUMN3 IS NOT NULL) OR
         (P_CD.PMDCOLUMN3 IS NOT NULL AND CDHIS.PMDCOLUMN3 IS NULL)
         
         ) OR
         ((P_CD.PMDPFID2 IS NOT NULL AND CDHIS.PMDPFID2 IS NOT NULL AND
         P_CD.PMDPFID2 <> CDHIS.PMDPFID2) OR
         (P_CD.PMDPFID2 IS NULL AND CDHIS.PMDPFID2 IS NOT NULL) OR
         (P_CD.PMDPFID2 IS NOT NULL AND CDHIS.PMDPFID2 IS NULL) OR
         (P_CD.PMDSCALE2 IS NOT NULL AND CDHIS.PMDSCALE2 IS NOT NULL AND
         P_CD.PMDSCALE2 <> CDHIS.PMDSCALE2) OR
         (P_CD.PMDSCALE2 IS NULL AND CDHIS.PMDSCALE2 IS NOT NULL) OR
         (P_CD.PMDSCALE2 IS NOT NULL AND CDHIS.PMDSCALE2 IS NULL) OR
         (P_CD.PMDTYPE2 IS NOT NULL AND CDHIS.PMDTYPE2 IS NOT NULL AND
         P_CD.PMDTYPE2 <> CDHIS.PMDTYPE2) OR
         (P_CD.PMDTYPE2 IS NULL AND CDHIS.PMDTYPE2 IS NOT NULL) OR
         (P_CD.PMDTYPE2 IS NOT NULL AND CDHIS.PMDTYPE2 IS NULL) OR
         (P_CD.PMDCOLUMN12 IS NOT NULL AND CDHIS.PMDCOLUMN12 IS NOT NULL AND
         P_CD.PMDCOLUMN12 <> CDHIS.PMDCOLUMN12) OR
         (P_CD.PMDCOLUMN12 IS NULL AND CDHIS.PMDCOLUMN12 IS NOT NULL) OR
         (P_CD.PMDCOLUMN12 IS NOT NULL AND CDHIS.PMDCOLUMN12 IS NULL) OR
         (P_CD.PMDCOLUMN22 IS NOT NULL AND CDHIS.PMDCOLUMN22 IS NOT NULL AND
         P_CD.PMDCOLUMN22 <> CDHIS.PMDCOLUMN22) OR
         (P_CD.PMDCOLUMN22 IS NULL AND CDHIS.PMDCOLUMN22 IS NOT NULL) OR
         (P_CD.PMDCOLUMN22 IS NOT NULL AND CDHIS.PMDCOLUMN22 IS NULL) OR
         (P_CD.PMDCOLUMN32 IS NOT NULL AND CDHIS.PMDCOLUMN32 IS NOT NULL AND
         P_CD.PMDCOLUMN32 <> CDHIS.PMDCOLUMN32) OR
         (P_CD.PMDCOLUMN32 IS NULL AND CDHIS.PMDCOLUMN32 IS NOT NULL) OR
         (P_CD.PMDCOLUMN32 IS NOT NULL AND CDHIS.PMDCOLUMN32 IS NULL)
         
         ) OR
         
         ((P_CD.PMDPFID3 IS NOT NULL AND CDHIS.PMDPFID3 IS NOT NULL AND
         P_CD.PMDPFID3 <> CDHIS.PMDPFID3) OR
         (P_CD.PMDPFID3 IS NULL AND CDHIS.PMDPFID3 IS NOT NULL) OR
         (P_CD.PMDPFID3 IS NOT NULL AND CDHIS.PMDPFID3 IS NULL) OR
         (P_CD.PMDSCALE3 IS NOT NULL AND CDHIS.PMDSCALE3 IS NOT NULL AND
         P_CD.PMDSCALE3 <> CDHIS.PMDSCALE3) OR
         (P_CD.PMDSCALE3 IS NULL AND CDHIS.PMDSCALE3 IS NOT NULL) OR
         (P_CD.PMDSCALE3 IS NOT NULL AND CDHIS.PMDSCALE3 IS NULL) OR
         (P_CD.PMDTYPE3 IS NOT NULL AND CDHIS.PMDTYPE3 IS NOT NULL AND
         P_CD.PMDTYPE3 <> CDHIS.PMDTYPE3) OR
         (P_CD.PMDTYPE3 IS NULL AND CDHIS.PMDTYPE3 IS NOT NULL) OR
         (P_CD.PMDTYPE3 IS NOT NULL AND CDHIS.PMDTYPE3 IS NULL) OR
         (P_CD.PMDCOLUMN13 IS NOT NULL AND CDHIS.PMDCOLUMN13 IS NOT NULL AND
         P_CD.PMDCOLUMN13 <> CDHIS.PMDCOLUMN13) OR
         (P_CD.PMDCOLUMN13 IS NULL AND CDHIS.PMDCOLUMN13 IS NOT NULL) OR
         (P_CD.PMDCOLUMN13 IS NOT NULL AND CDHIS.PMDCOLUMN13 IS NULL) OR
         (P_CD.PMDCOLUMN23 IS NOT NULL AND CDHIS.PMDCOLUMN23 IS NOT NULL AND
         P_CD.PMDCOLUMN23 <> CDHIS.PMDCOLUMN23) OR
         (P_CD.PMDCOLUMN23 IS NULL AND CDHIS.PMDCOLUMN23 IS NOT NULL) OR
         (P_CD.PMDCOLUMN23 IS NOT NULL AND CDHIS.PMDCOLUMN23 IS NULL) OR
         (P_CD.PMDCOLUMN33 IS NOT NULL AND CDHIS.PMDCOLUMN33 IS NOT NULL AND
         P_CD.PMDCOLUMN33 <> CDHIS.PMDCOLUMN33) OR
         (P_CD.PMDCOLUMN33 IS NULL AND CDHIS.PMDCOLUMN33 IS NOT NULL) OR
         (P_CD.PMDCOLUMN33 IS NOT NULL AND CDHIS.PMDCOLUMN33 IS NULL)
         
         ) OR
         ((P_CD.PMDPFID4 IS NOT NULL AND CDHIS.PMDPFID4 IS NOT NULL AND
         P_CD.PMDPFID4 <> CDHIS.PMDPFID4) OR
         (P_CD.PMDPFID4 IS NULL AND CDHIS.PMDPFID4 IS NOT NULL) OR
         (P_CD.PMDPFID4 IS NOT NULL AND CDHIS.PMDPFID4 IS NULL) OR
         (P_CD.PMDSCALE4 IS NOT NULL AND CDHIS.PMDSCALE4 IS NOT NULL AND
         P_CD.PMDSCALE4 <> CDHIS.PMDSCALE4) OR
         (P_CD.PMDSCALE4 IS NULL AND CDHIS.PMDSCALE4 IS NOT NULL) OR
         (P_CD.PMDSCALE4 IS NOT NULL AND CDHIS.PMDSCALE4 IS NULL) OR
         (P_CD.PMDTYPE4 IS NOT NULL AND CDHIS.PMDTYPE4 IS NOT NULL AND
         P_CD.PMDTYPE4 <> CDHIS.PMDTYPE4) OR
         (P_CD.PMDTYPE4 IS NULL AND CDHIS.PMDTYPE4 IS NOT NULL) OR
         (P_CD.PMDTYPE4 IS NOT NULL AND CDHIS.PMDTYPE4 IS NULL) OR
         (P_CD.PMDCOLUMN14 IS NOT NULL AND CDHIS.PMDCOLUMN14 IS NOT NULL AND
         P_CD.PMDCOLUMN14 <> CDHIS.PMDCOLUMN14) OR
         (P_CD.PMDCOLUMN14 IS NULL AND CDHIS.PMDCOLUMN14 IS NOT NULL) OR
         (P_CD.PMDCOLUMN14 IS NOT NULL AND CDHIS.PMDCOLUMN14 IS NULL) OR
         (P_CD.PMDCOLUMN24 IS NOT NULL AND CDHIS.PMDCOLUMN24 IS NOT NULL AND
         P_CD.PMDCOLUMN24 <> CDHIS.PMDCOLUMN24) OR
         (P_CD.PMDCOLUMN24 IS NULL AND CDHIS.PMDCOLUMN24 IS NOT NULL) OR
         (P_CD.PMDCOLUMN24 IS NOT NULL AND CDHIS.PMDCOLUMN24 IS NULL) OR
         (P_CD.PMDCOLUMN34 IS NOT NULL AND CDHIS.PMDCOLUMN34 IS NOT NULL AND
         P_CD.PMDCOLUMN34 <> CDHIS.PMDCOLUMN34) OR
         (P_CD.PMDCOLUMN34 IS NULL AND CDHIS.PMDCOLUMN34 IS NOT NULL) OR
         (P_CD.PMDCOLUMN34 IS NOT NULL AND CDHIS.PMDCOLUMN34 IS NULL)
         
         )))
        
         OR (METER.MIIFMP = 'N')
      
       THEN
      
        IF CDHIS.MIIFMP <> METER.MIIFMP THEN
          ROLLBACK;
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                  P_CD.MIID || ']的' ||
                                  '价格分类已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
        
        END IF;
        IF CDHIS.MIIFMP = METER.MIIFMP AND CDHIS.MIIFMP = 'N' AND
           METER.MIIFMP = 'N' AND
           NOT ((METER.MIPFID IS NOT NULL AND CDHIS.MIPFID IS NOT NULL AND
            METER.MIPFID = CDHIS.MIPFID) OR
            (METER.MIPFID IS NULL AND CDHIS.MIPFID IS NULL)) THEN
        
          ROLLBACK;
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                  P_CD.MIID || ']的' ||
                                  '价格分类已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
        
        END IF;
      
        IF CDHIS.MIIFMP = METER.MIIFMP AND CDHIS.MIIFMP = 'Y' AND
           METER.MIIFMP = 'Y' THEN
          IF CDHIS.PMDPFID IS NOT NULL THEN
            SELECT COUNT(*)
              INTO V_COUNT
              FROM PRICEMULTIDETAIL
             WHERE PMDMID = CDHIS.MIID
               AND PMDPFID = CDHIS.PMDPFID
               AND PMDID = CDHIS.PMDID
               AND PMDSCALE = CDHIS.PMDSCALE
               AND (PMDTYPE = CDHIS.PMDTYPE OR PMDTYPE IS NULL)
               AND (PMDCOLUMN1 = CDHIS.PMDCOLUMN1 OR
                   (PMDCOLUMN1 IS NULL AND CDHIS.PMDCOLUMN1 IS NULL))
               AND (PMDCOLUMN2 = CDHIS.PMDCOLUMN2 OR
                   (PMDCOLUMN2 IS NULL AND CDHIS.PMDCOLUMN2 IS NULL))
               AND (PMDCOLUMN3 = CDHIS.PMDCOLUMN3 OR
                   (PMDCOLUMN3 IS NULL AND CDHIS.PMDCOLUMN3 IS NULL))
            
            ;
            IF V_COUNT = 0 THEN
              ROLLBACK;
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '变更单体第[' || P_CD.CCDROWNO ||
                                      ']行,水表号:[' || P_CD.MIID || ']的' ||
                                      '价格分类已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
            
            END IF;
          END IF;
          IF CDHIS.PMDPFID2 IS NOT NULL THEN
            SELECT COUNT(*)
              INTO V_COUNT
              FROM PRICEMULTIDETAIL
             WHERE PMDMID = CDHIS.MIID
               AND PMDPFID = CDHIS.PMDPFID2
               AND PMDID = CDHIS.PMDID2
               AND PMDSCALE = CDHIS.PMDSCALE2
               AND (PMDTYPE = CDHIS.PMDTYPE2 OR PMDTYPE IS NULL)
               AND (PMDCOLUMN1 = CDHIS.PMDCOLUMN12 OR
                   (PMDCOLUMN1 IS NULL AND CDHIS.PMDCOLUMN12 IS NULL))
               AND (PMDCOLUMN2 = CDHIS.PMDCOLUMN22 OR
                   (PMDCOLUMN2 IS NULL AND CDHIS.PMDCOLUMN22 IS NULL))
               AND (PMDCOLUMN3 = CDHIS.PMDCOLUMN32 OR
                   (PMDCOLUMN3 IS NULL AND CDHIS.PMDCOLUMN32 IS NULL))
            
            ;
            IF V_COUNT = 0 THEN
              ROLLBACK;
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '变更单体第[' || P_CD.CCDROWNO ||
                                      ']行,水表号:[' || P_CD.MIID || ']的' ||
                                      '价格分类已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
            
            END IF;
          END IF;
          IF CDHIS.PMDPFID3 IS NOT NULL THEN
            SELECT COUNT(*)
              INTO V_COUNT
              FROM PRICEMULTIDETAIL
             WHERE PMDMID = CDHIS.MIID
               AND PMDPFID = CDHIS.PMDPFID3
               AND PMDID = CDHIS.PMDID3
               AND PMDSCALE = CDHIS.PMDSCALE3
               AND (PMDTYPE = CDHIS.PMDTYPE3 OR PMDTYPE IS NULL)
               AND (PMDCOLUMN1 = CDHIS.PMDCOLUMN13 OR
                   (PMDCOLUMN1 IS NULL AND CDHIS.PMDCOLUMN13 IS NULL))
               AND (PMDCOLUMN2 = CDHIS.PMDCOLUMN23 OR
                   (PMDCOLUMN2 IS NULL AND CDHIS.PMDCOLUMN23 IS NULL))
               AND (PMDCOLUMN3 = CDHIS.PMDCOLUMN33 OR
                   (PMDCOLUMN3 IS NULL AND CDHIS.PMDCOLUMN33 IS NULL))
            
            ;
            IF V_COUNT = 0 THEN
              ROLLBACK;
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '变更单体第[' || P_CD.CCDROWNO ||
                                      ']行,水表号:[' || P_CD.MIID || ']的' ||
                                      '价格分类已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
            
            END IF;
          END IF;
          IF CDHIS.PMDPFID4 IS NOT NULL THEN
            SELECT COUNT(*)
              INTO V_COUNT
              FROM PRICEMULTIDETAIL
             WHERE PMDMID = CDHIS.MIID
               AND PMDPFID = CDHIS.PMDPFID4
               AND PMDID = CDHIS.PMDID4
               AND PMDSCALE = CDHIS.PMDSCALE4
               AND (PMDTYPE = CDHIS.PMDTYPE4 OR PMDTYPE IS NULL)
               AND (PMDCOLUMN1 = CDHIS.PMDCOLUMN14 OR
                   (PMDCOLUMN1 IS NULL AND CDHIS.PMDCOLUMN14 IS NULL))
               AND (PMDCOLUMN2 = CDHIS.PMDCOLUMN24 OR
                   (PMDCOLUMN2 IS NULL AND CDHIS.PMDCOLUMN24 IS NULL))
               AND (PMDCOLUMN3 = CDHIS.PMDCOLUMN34 OR
                   (PMDCOLUMN3 IS NULL AND CDHIS.PMDCOLUMN34 IS NULL))
            
            ;
            IF V_COUNT = 0 THEN
              ROLLBACK;
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '变更单体第[' || P_CD.CCDROWNO ||
                                      ']行,水表号:[' || P_CD.MIID || ']的' ||
                                      '价格分类已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
            
            END IF;
          END IF;
        END IF;
      
        DELETE PRICEMULTIDETAIL WHERE PMDMID = P_CD.MIID;
        IF P_CD.PMDPFID IS NOT NULL THEN
          INSERT INTO PRICEMULTIDETAIL
          VALUES
            (P_CD.MICID,
             P_CD.MIID,
             1,
             P_CD.PMDPFID,
             P_CD.PMDSCALE,
             P_CD.PMDTYPE,
             P_CD.PMDCOLUMN1,
             P_CD.PMDCOLUMN2,
             P_CD.PMDCOLUMN3);
        END IF;
        IF P_CD.PMDPFID2 IS NOT NULL THEN
          INSERT INTO PRICEMULTIDETAIL
          VALUES
            (P_CD.MICID,
             P_CD.MIID,
             2,
             P_CD.PMDPFID2,
             P_CD.PMDSCALE2,
             P_CD.PMDTYPE2,
             P_CD.PMDCOLUMN12,
             P_CD.PMDCOLUMN22,
             P_CD.PMDCOLUMN32);
        END IF;
        IF P_CD.PMDPFID3 IS NOT NULL THEN
          INSERT INTO PRICEMULTIDETAIL
          VALUES
            (P_CD.MICID,
             P_CD.MIID,
             3,
             P_CD.PMDPFID3,
             P_CD.PMDSCALE3,
             P_CD.PMDTYPE3,
             P_CD.PMDCOLUMN13,
             P_CD.PMDCOLUMN23,
             P_CD.PMDCOLUMN33);
        END IF;
        IF P_CD.PMDPFID4 IS NOT NULL THEN
          INSERT INTO PRICEMULTIDETAIL
          VALUES
            (P_CD.MICID,
             P_CD.MIID,
             4,
             P_CD.PMDPFID4,
             P_CD.PMDSCALE4,
             P_CD.PMDTYPE4,
             P_CD.PMDCOLUMN14,
             P_CD.PMDCOLUMN24,
             P_CD.PMDCOLUMN34);
        END IF;
      
        SELECT MAX(PMDPFID)
          INTO V_TEMPPMDPFID
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = P_CD.MIID
           AND PMDSCALE IN (SELECT MAX(PMDSCALE)
                              FROM PRICEMULTIDETAIL
                             WHERE PMDMID = P_CD.MIID);
      
        IF V_TEMPPMDPFID IS NULL THEN
          V_TEMPPMDPFID := P_CD.PMDPFID;
        END IF;
        UPDATE METERINFO
           SET MIPFID = V_TEMPPMDPFID, MIIFMP = 'Y'
         WHERE MIID = P_CD.MIID;
      
      END IF;
    END IF;
    --计件类型
    IF (P_CD.MIRPID IS NOT NULL AND CDHIS.MIRPID IS NOT NULL AND
       P_CD.MIRPID <> CDHIS.MIRPID) OR
       (P_CD.MIRPID IS NULL AND CDHIS.MIRPID IS NOT NULL) OR
       (P_CD.MIRPID IS NOT NULL AND CDHIS.MIRPID IS NULL) THEN
      IF (METER.MIRPID IS NOT NULL AND CDHIS.MIRPID IS NOT NULL AND
         METER.MIRPID = CDHIS.MIRPID) OR
         (METER.MIRPID IS NULL AND CDHIS.MIRPID IS NULL) THEN
        UPDATE METERINFO SET MIRPID = P_CD.MIRPID WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '计件类型已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --表位
    IF (P_CD.MISIDE IS NOT NULL AND CDHIS.MISIDE IS NOT NULL AND
       P_CD.MISIDE <> CDHIS.MISIDE) OR
       (P_CD.MISIDE IS NULL AND CDHIS.MISIDE IS NOT NULL) OR
       (P_CD.MISIDE IS NOT NULL AND CDHIS.MISIDE IS NULL) THEN
      IF (METER.MISIDE IS NOT NULL AND CDHIS.MISIDE IS NOT NULL AND
         METER.MISIDE = CDHIS.MISIDE) OR
         (METER.MISIDE IS NULL AND CDHIS.MISIDE IS NULL) THEN
        UPDATE METERINFO SET MISIDE = P_CD.MISIDE WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '表位已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --水表接水地址
    IF (P_CD.MIPOSITION IS NOT NULL AND CDHIS.MIPOSITION IS NOT NULL AND
       P_CD.MIPOSITION <> CDHIS.MIPOSITION) OR
       (P_CD.MIPOSITION IS NULL AND CDHIS.MIPOSITION IS NOT NULL) OR
       (P_CD.MIPOSITION IS NOT NULL AND CDHIS.MIPOSITION IS NULL) THEN
      IF (METER.MIPOSITION IS NOT NULL AND CDHIS.MIPOSITION IS NOT NULL AND
         METER.MIPOSITION = CDHIS.MIPOSITION) OR
         (METER.MIPOSITION IS NULL AND CDHIS.MIPOSITION IS NULL) THEN
        UPDATE METERINFO
           SET MIPOSITION = P_CD.MIPOSITION
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '水表接水地址已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --新装起度
    IF (P_CD.MIINSCODE IS NOT NULL AND CDHIS.MIINSCODE IS NOT NULL AND
       P_CD.MIINSCODE <> CDHIS.MIINSCODE) OR
       (P_CD.MIINSCODE IS NULL AND CDHIS.MIINSCODE IS NOT NULL) OR
       (P_CD.MIINSCODE IS NOT NULL AND CDHIS.MIINSCODE IS NULL) THEN
      IF (METER.MIINSCODE IS NOT NULL AND CDHIS.MIINSCODE IS NOT NULL AND
         METER.MIINSCODE = CDHIS.MIINSCODE) OR
         (METER.MIINSCODE IS NULL AND CDHIS.MIINSCODE IS NULL) THEN
        UPDATE METERINFO
           SET MIINSCODE = P_CD.MIINSCODE
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '新装起度已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --本期读数  BY 20190618  基建临时用水档案变更 变更指针
    --本期读数  BY 20190916  预立户转正式户更改指针 变更指针
    IF P_TYPE IN ('52','53') THEN
    IF (P_CD.MIRCODE IS NOT NULL AND CDHIS.MIRCODE IS NOT NULL AND
       P_CD.MIRCODE <> CDHIS.MIRCODE) OR
       (P_CD.MIRCODE IS NULL AND CDHIS.MIRCODE IS NOT NULL) OR
       (P_CD.MIRCODE IS NOT NULL AND CDHIS.MIRCODE IS NULL) THEN
      IF (METER.MIRCODE IS NOT NULL AND CDHIS.MIRCODE IS NOT NULL AND
         METER.MIRCODE = CDHIS.MIRCODE) OR
         (METER.MIRCODE IS NULL AND CDHIS.MIRCODE IS NULL) THEN
        UPDATE METERINFO
           SET MIRCODE = P_CD.MIRCODE,
               MIRCODECHAR = P_CD.MIRCODE
         WHERE MIID = P_CD.MIID;
         SELECT MDNO INTO V_MDNO FROM METERDOC WHERE  MDMID = P_CD.MIID;
         IF V_MDNO IS NULL THEN
        UPDATE METERINFO
           SET MIINSCODE = P_CD.MIRCODE
         WHERE MIID = P_CD.MIID;
         END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '新装起度已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    END IF;
    
    --换表日期
    IF (P_CD.MIREINSDATE IS NOT NULL AND CDHIS.MIREINSDATE IS NOT NULL AND
       P_CD.MIREINSDATE <> CDHIS.MIREINSDATE) OR
       (P_CD.MIREINSDATE IS NULL AND CDHIS.MIREINSDATE IS NOT NULL) OR
       (P_CD.MIREINSDATE IS NOT NULL AND CDHIS.MIREINSDATE IS NULL) THEN
      IF (METER.MIREINSDATE IS NOT NULL AND CDHIS.MIREINSDATE IS NOT NULL AND
         METER.MIREINSDATE = CDHIS.MIREINSDATE) OR
         (METER.MIREINSDATE IS NULL AND CDHIS.MIREINSDATE IS NULL) THEN
        UPDATE METERINFO
           SET MIREINSDATE = P_CD.MIREINSDATE
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '换表日期已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --最近一次实收流水
   /* IF (P_CD.MIPAYMENTID IS NOT NULL AND CDHIS.MIPAYMENTID IS NOT NULL AND
       P_CD.MIPAYMENTID <> CDHIS.MIPAYMENTID) OR
       (P_CD.MIPAYMENTID IS NULL AND CDHIS.MIPAYMENTID IS NOT NULL) OR
       (P_CD.MIPAYMENTID IS NOT NULL AND CDHIS.MIPAYMENTID IS NULL) THEN
      IF (METER.MIPAYMENTID IS NOT NULL AND CDHIS.MIPAYMENTID IS NOT NULL AND
         METER.MIPAYMENTID = CDHIS.MIPAYMENTID) OR
         (METER.MIPAYMENTID IS NULL AND CDHIS.MIPAYMENTID IS NULL) THEN
        UPDATE METERINFO
           SET MIPAYMENTID = P_CD.MIPAYMENTID
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '最近一次实收已经发生变化不能通过变更审核？请删除此行记录后再进行审核!');
      END IF;
    END IF;*/
    --是否计费
    IF (P_CD.MIIFCHARGE IS NOT NULL AND CDHIS.MIIFCHARGE IS NOT NULL AND
       P_CD.MIIFCHARGE <> CDHIS.MIIFCHARGE) OR
       (P_CD.MIIFCHARGE IS NULL AND CDHIS.MIIFCHARGE IS NOT NULL) OR
       (P_CD.MIIFCHARGE IS NOT NULL AND CDHIS.MIIFCHARGE IS NULL) THEN
      IF (METER.MIIFCHARGE IS NOT NULL AND CDHIS.MIIFCHARGE IS NOT NULL AND
         METER.MIIFCHARGE = CDHIS.MIIFCHARGE) OR
         (METER.MIIFCHARGE IS NULL AND CDHIS.MIIFCHARGE IS NULL) THEN
        UPDATE METERINFO
           SET MIIFCHARGE = P_CD.MIIFCHARGE
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '是否计费已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --是否计量
    IF (P_CD.MIIFSL IS NOT NULL AND CDHIS.MIIFSL IS NOT NULL AND
       P_CD.MIIFSL <> CDHIS.MIIFSL) OR
       (P_CD.MIIFSL IS NULL AND CDHIS.MIIFSL IS NOT NULL) OR
       (P_CD.MIIFSL IS NOT NULL AND CDHIS.MIIFSL IS NULL) THEN
      IF (METER.MIIFSL IS NOT NULL AND CDHIS.MIIFSL IS NOT NULL AND
         METER.MIIFSL = CDHIS.MIIFSL) OR
         (METER.MIIFSL IS NULL AND CDHIS.MIIFSL IS NULL) THEN
        UPDATE METERINFO SET MIIFSL = P_CD.MIIFSL WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '是否计量已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --考核表
    IF (P_CD.MIIFCHK IS NOT NULL AND CDHIS.MIIFCHK IS NOT NULL AND
       P_CD.MIIFCHK <> CDHIS.MIIFCHK) OR
       (P_CD.MIIFCHK IS NULL AND CDHIS.MIIFCHK IS NOT NULL) OR
       (P_CD.MIIFCHK IS NOT NULL AND CDHIS.MIIFCHK IS NULL) THEN
      IF (METER.MIIFCHK IS NOT NULL AND CDHIS.MIIFCHK IS NOT NULL AND
         METER.MIIFCHK = CDHIS.MIIFCHK) OR
         (METER.MIIFCHK IS NULL AND CDHIS.MIIFCHK IS NULL) THEN
        UPDATE METERINFO SET MIIFCHK = P_CD.MIIFCHK WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '考核表已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --节水
    IF (P_CD.MIIFWATCH IS NOT NULL AND CDHIS.MIIFWATCH IS NOT NULL AND
       P_CD.MIIFWATCH <> CDHIS.MIIFWATCH) OR
       (P_CD.MIIFWATCH IS NULL AND CDHIS.MIIFWATCH IS NOT NULL) OR
       (P_CD.MIIFWATCH IS NOT NULL AND CDHIS.MIIFWATCH IS NULL) THEN
      IF (METER.MIIFWATCH IS NOT NULL AND CDHIS.MIIFWATCH IS NOT NULL AND
         METER.MIIFWATCH = CDHIS.MIIFWATCH) OR
         (METER.MIIFWATCH IS NULL AND CDHIS.MIIFWATCH IS NULL) THEN
        UPDATE METERINFO
           SET MIIFWATCH = P_CD.MIIFWATCH
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '节水已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --IC卡号
    IF (P_CD.MIICNO IS NOT NULL AND CDHIS.MIICNO IS NOT NULL AND
       P_CD.MIICNO <> CDHIS.MIICNO) OR
       (P_CD.MIICNO IS NULL AND CDHIS.MIICNO IS NOT NULL) OR
       (P_CD.MIICNO IS NOT NULL AND CDHIS.MIICNO IS NULL) THEN
      IF (METER.MIICNO IS NOT NULL AND CDHIS.MIICNO IS NOT NULL AND
         METER.MIICNO = CDHIS.MIICNO) OR
         (METER.MIICNO IS NULL AND CDHIS.MIICNO IS NULL) THEN
        UPDATE METERINFO SET MIICNO = P_CD.MIICNO WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                'IC卡号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --合收表主表号
    IF (P_CD.MIPRIID IS NOT NULL AND CDHIS.MIPRIID IS NOT NULL AND
       P_CD.MIPRIID <> CDHIS.MIPRIID) OR
       (P_CD.MIPRIID IS NULL AND CDHIS.MIPRIID IS NOT NULL) OR
       (P_CD.MIPRIID IS NOT NULL AND CDHIS.MIPRIID IS NULL) THEN
      IF (METER.MIPRIID IS NOT NULL AND CDHIS.MIPRIID IS NOT NULL AND
         METER.MIPRIID = CDHIS.MIPRIID) OR
         (METER.MIPRIID IS NULL AND CDHIS.MIPRIID IS NULL) THEN
        UPDATE METERINFO SET MIPRIID = P_CD.MIPRIID WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '合收表主表号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --合收表标志
    IF (P_CD.MIPRIFLAG IS NOT NULL AND CDHIS.MIPRIFLAG IS NOT NULL AND
       P_CD.MIPRIFLAG <> CDHIS.MIPRIFLAG) OR
       (P_CD.MIPRIFLAG IS NULL AND CDHIS.MIPRIFLAG IS NOT NULL) OR
       (P_CD.MIPRIFLAG IS NOT NULL AND CDHIS.MIPRIFLAG IS NULL) THEN
      IF (METER.MIPRIFLAG IS NOT NULL AND CDHIS.MIPRIFLAG IS NOT NULL AND
         METER.MIPRIFLAG = CDHIS.MIPRIFLAG) OR
         (METER.MIPRIFLAG IS NULL AND CDHIS.MIPRIFLAG IS NULL) THEN
        UPDATE METERINFO
           SET MIPRIFLAG = P_CD.MIPRIFLAG
         WHERE MIID = P_CD.MIID;
         --如果不是合收表，则合收表主表号为自己
         IF P_CD.MIPRIFLAG='N' OR P_CD.MIPRIFLAG IS NULL THEN
             UPDATE METERINFO
             SET MIPRIID = MIID
           WHERE MIID = P_CD.MIID;
           --如果下面挂有分表，分表也置为普通表
             UPDATE METERINFO
                SET MIPRIID = MIID, MIPRIFLAG = 'N'
              WHERE MIPRIID = P_CD.MIID
                AND MIPRIFLAG = 'Y'
                AND MIID <> MIPRIID;
         END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '合收表标志已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --户籍人数
    IF (P_CD.MIUSENUM IS NOT NULL AND CDHIS.MIUSENUM IS NOT NULL AND
       P_CD.MIUSENUM <> CDHIS.MIUSENUM) OR
       (P_CD.MIUSENUM IS NULL AND CDHIS.MIUSENUM IS NOT NULL) OR
       (P_CD.MIUSENUM IS NOT NULL AND CDHIS.MIUSENUM IS NULL) THEN
      IF (METER.MIUSENUM IS NOT NULL AND CDHIS.MIUSENUM IS NOT NULL AND
         METER.MIUSENUM = CDHIS.MIUSENUM) OR
         (METER.MIUSENUM IS NULL AND CDHIS.MIUSENUM IS NULL) THEN
        UPDATE METERINFO
           SET MIUSENUM = P_CD.MIUSENUM
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '户籍人数已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --收费方式
    IF (P_CD.MICHARGETYPE IS NOT NULL AND CDHIS.MICHARGETYPE IS NOT NULL AND
       P_CD.MICHARGETYPE <> CDHIS.MICHARGETYPE) OR
       (P_CD.MICHARGETYPE IS NULL AND CDHIS.MICHARGETYPE IS NOT NULL) OR
       (P_CD.MICHARGETYPE IS NOT NULL AND CDHIS.MICHARGETYPE IS NULL) THEN
      IF (METER.MICHARGETYPE IS NOT NULL AND CDHIS.MICHARGETYPE IS NOT NULL AND
         METER.MICHARGETYPE = CDHIS.MICHARGETYPE) OR
         (METER.MICHARGETYPE IS NULL AND CDHIS.MICHARGETYPE IS NULL) THEN
        UPDATE METERINFO
           SET MICHARGETYPE = P_CD.MICHARGETYPE
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '收费方式已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --水表类别
    IF (P_CD.MILB IS NOT NULL AND CDHIS.MILB IS NOT NULL AND
       P_CD.MILB <> CDHIS.MILB) OR
       (P_CD.MILB IS NULL AND CDHIS.MILB IS NOT NULL) OR
       (P_CD.MILB IS NOT NULL AND CDHIS.MILB IS NULL) THEN
      IF (METER.MILB IS NOT NULL AND CDHIS.MILB IS NOT NULL AND
         METER.MILB = CDHIS.MILB) OR
         (METER.MILB IS NULL AND CDHIS.MILB IS NULL) THEN
        UPDATE METERINFO SET MILB = P_CD.MILB WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '水表类型已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --新表标志
    IF (P_CD.MINEWFLAG IS NOT NULL AND CDHIS.MINEWFLAG IS NOT NULL AND
       P_CD.MINEWFLAG <> CDHIS.MINEWFLAG) OR
       (P_CD.MINEWFLAG IS NULL AND CDHIS.MINEWFLAG IS NOT NULL) OR
       (P_CD.MINEWFLAG IS NOT NULL AND CDHIS.MINEWFLAG IS NULL) THEN
      IF (METER.MINEWFLAG IS NOT NULL AND CDHIS.MINEWFLAG IS NOT NULL AND
         METER.MINEWFLAG = CDHIS.MINEWFLAG) OR
         (METER.MINEWFLAG IS NULL AND CDHIS.MINEWFLAG IS NULL) THEN
        UPDATE METERINFO
           SET MINEWFLAG = P_CD.MINEWFLAG
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '新表标志已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --收费员
    IF (P_CD.MICPER IS NOT NULL AND CDHIS.MICPER IS NOT NULL AND
       P_CD.MICPER <> CDHIS.MICPER) OR
       (P_CD.MICPER IS NULL AND CDHIS.MICPER IS NOT NULL) OR
       (P_CD.MICPER IS NOT NULL AND CDHIS.MICPER IS NULL) THEN
      IF (METER.MICPER IS NOT NULL AND CDHIS.MICPER IS NOT NULL AND
         METER.MICPER = CDHIS.MICPER) OR
         (METER.MICPER IS NULL AND CDHIS.MICPER IS NULL) THEN
        UPDATE METERINFO SET MICPER = P_CD.MICPER WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '表地址已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --是否税票
    IF (P_CD.MIIFTAX IS NOT NULL AND CDHIS.MIIFTAX IS NOT NULL AND
       P_CD.MIIFTAX <> CDHIS.MIIFTAX) OR
       (P_CD.MIIFTAX IS NULL AND CDHIS.MIIFTAX IS NOT NULL) OR
       (P_CD.MIIFTAX IS NOT NULL AND CDHIS.MIIFTAX IS NULL) THEN
      IF (METER.MIIFTAX IS NOT NULL AND CDHIS.MIIFTAX IS NOT NULL AND
         METER.MIIFTAX = CDHIS.MIIFTAX) OR
         (METER.MIIFTAX IS NULL AND CDHIS.MIIFTAX IS NULL) THEN
        UPDATE METERINFO SET MIIFTAX = P_CD.MIIFTAX WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '是否税票已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --小区
    IF (P_CD.MICOMMUNITY IS NOT NULL AND CDHIS.MICOMMUNITY IS NOT NULL AND
       P_CD.MICOMMUNITY <> CDHIS.MICOMMUNITY) OR
       (P_CD.MICOMMUNITY IS NULL AND CDHIS.MICOMMUNITY IS NOT NULL) OR
       (P_CD.MICOMMUNITY IS NOT NULL AND CDHIS.MICOMMUNITY IS NULL) THEN
      IF (METER.MICOMMUNITY IS NOT NULL AND CDHIS.MICOMMUNITY IS NOT NULL AND
         METER.MICOMMUNITY = CDHIS.MICOMMUNITY) OR
         (METER.MICOMMUNITY IS NULL AND CDHIS.MICOMMUNITY IS NULL) THEN
        UPDATE METERINFO
           SET MICOMMUNITY = P_CD.MICOMMUNITY
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '小区已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --远传表号
    IF (P_CD.MIREMOTENO IS NOT NULL AND CDHIS.MIREMOTENO IS NOT NULL AND
       P_CD.MIREMOTENO <> CDHIS.MIREMOTENO) OR
       (P_CD.MIREMOTENO IS NULL AND CDHIS.MIREMOTENO IS NOT NULL) OR
       (P_CD.MIREMOTENO IS NOT NULL AND CDHIS.MIREMOTENO IS NULL) THEN
      IF (METER.MIREMOTENO IS NOT NULL AND CDHIS.MIREMOTENO IS NOT NULL AND
         METER.MIREMOTENO = CDHIS.MIREMOTENO) OR
         (METER.MIREMOTENO IS NULL AND CDHIS.MIREMOTENO IS NULL) THEN
        UPDATE METERINFO
           SET MIREMOTENO = P_CD.MIREMOTENO
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '远传表号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --远传表HUB号
    IF (P_CD.MIREMOTEHUBNO IS NOT NULL AND CDHIS.MIREMOTEHUBNO IS NOT NULL AND
       P_CD.MIREMOTEHUBNO <> CDHIS.MIREMOTEHUBNO) OR
       (P_CD.MIREMOTEHUBNO IS NULL AND CDHIS.MIREMOTEHUBNO IS NOT NULL) OR
       (P_CD.MIREMOTEHUBNO IS NOT NULL AND CDHIS.MIREMOTEHUBNO IS NULL) THEN
      IF (METER.MIREMOTEHUBNO IS NOT NULL AND
         CDHIS.MIREMOTEHUBNO IS NOT NULL AND
         METER.MIREMOTEHUBNO = CDHIS.MIREMOTEHUBNO) OR
         (METER.MIREMOTEHUBNO IS NULL AND CDHIS.MIREMOTEHUBNO IS NULL) THEN
        UPDATE METERINFO
           SET MIREMOTEHUBNO = P_CD.MIREMOTEHUBNO
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '远传表HUB号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --电子邮件
    IF (P_CD.MIREMOTEHUBNO IS NOT NULL AND CDHIS.MIREMOTEHUBNO IS NOT NULL AND
       P_CD.MIREMOTEHUBNO <> CDHIS.MIREMOTEHUBNO) OR
       (P_CD.MIREMOTEHUBNO IS NULL AND CDHIS.MIREMOTEHUBNO IS NOT NULL) OR
       (P_CD.MIREMOTEHUBNO IS NOT NULL AND CDHIS.MIREMOTEHUBNO IS NULL) THEN
      IF (METER.MIREMOTEHUBNO IS NOT NULL AND
         CDHIS.MIREMOTEHUBNO IS NOT NULL AND
         METER.MIREMOTEHUBNO = CDHIS.MIREMOTEHUBNO) OR
         (METER.MIREMOTEHUBNO IS NULL AND CDHIS.MIREMOTEHUBNO IS NULL) THEN
        UPDATE METERINFO
           SET MIREMOTEHUBNO = P_CD.MIREMOTEHUBNO
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '电子邮件已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --发账是否发邮件
    IF (P_CD.MIREMOTEHUBNO IS NOT NULL AND CDHIS.MIREMOTEHUBNO IS NOT NULL AND
       P_CD.MIREMOTEHUBNO <> CDHIS.MIREMOTEHUBNO) OR
       (P_CD.MIREMOTEHUBNO IS NULL AND CDHIS.MIREMOTEHUBNO IS NOT NULL) OR
       (P_CD.MIREMOTEHUBNO IS NOT NULL AND CDHIS.MIREMOTEHUBNO IS NULL) THEN
      IF (METER.MIREMOTEHUBNO IS NOT NULL AND
         CDHIS.MIREMOTEHUBNO IS NOT NULL AND
         METER.MIREMOTEHUBNO = CDHIS.MIREMOTEHUBNO) OR
         (METER.MIREMOTEHUBNO IS NULL AND CDHIS.MIREMOTEHUBNO IS NULL) THEN
        UPDATE METERINFO
           SET MIREMOTEHUBNO = P_CD.MIREMOTEHUBNO
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '发账是否发邮件已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --备用字段1
    IF (P_CD.MICOLUMN1 IS NOT NULL AND CDHIS.MICOLUMN1 IS NOT NULL AND
       P_CD.MICOLUMN1 <> CDHIS.MICOLUMN1) OR
       (P_CD.MICOLUMN1 IS NULL AND CDHIS.MICOLUMN1 IS NOT NULL) OR
       (P_CD.MICOLUMN1 IS NOT NULL AND CDHIS.MICOLUMN1 IS NULL) THEN
      IF (METER.MICOLUMN1 IS NOT NULL AND CDHIS.MICOLUMN1 IS NOT NULL AND
         METER.MICOLUMN1 = CDHIS.MICOLUMN1) OR
         (METER.MICOLUMN1 IS NULL AND CDHIS.MICOLUMN1 IS NULL) THEN
        UPDATE METERINFO
           SET MICOLUMN1 = P_CD.MICOLUMN1
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '低保减免水量已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --备用字段2
    IF (P_CD.MICOLUMN2 IS NOT NULL AND CDHIS.MICOLUMN2 IS NOT NULL AND
       P_CD.MICOLUMN2 <> CDHIS.MICOLUMN2) OR
       (P_CD.MICOLUMN2 IS NULL AND CDHIS.MICOLUMN2 IS NOT NULL) OR
       (P_CD.MICOLUMN2 IS NOT NULL AND CDHIS.MICOLUMN2 IS NULL) THEN
      IF (METER.MICOLUMN2 IS NOT NULL AND CDHIS.MICOLUMN2 IS NOT NULL AND
         METER.MICOLUMN2 = CDHIS.MICOLUMN2) OR
         (METER.MICOLUMN2 IS NULL AND CDHIS.MICOLUMN2 IS NULL) THEN
        IF NVL(P_CD.MICOLUMN2, 'N') = 'N' THEN
          --取消低保默认给居民水价A0103
          UPDATE METERINFO
             SET MICOLUMN2 = P_CD.MICOLUMN2, MICOLUMN1 = 0, MICOLUMN3 = '',MIPFID='A0103'
           WHERE MIID = P_CD.MIID;
           
           --【哈尔滨】低保户有专门水价，维护低保信息只是打上标记，不增加计费调整记录  20140312
       /*   \*******保低计费调整******\
          DELETE PRICEADJUSTLIST T
           WHERE T.PALMETHOD = '02'
             AND T.PALTACTIC = '02'
             AND PALWAY = -1
             AND PALMID = P_CD.MIID;*/
        ELSE
          UPDATE METERINFO
             SET MICOLUMN2 = P_CD.MICOLUMN2
           WHERE MIID = P_CD.MIID;
           
             --【哈尔滨】低保户有专门水价，维护低保信息只是打上标记，不增加计费调整记录  20140312
     /*     \*******保低计费调整******\
          SELECT COUNT(*)
            INTO V_COUNT
            FROM PRICEADJUSTLIST T
           WHERE T.PALMETHOD = '02'
             AND T.PALTACTIC = '02'
             AND PALWAY = -1
             AND PALMID = P_CD.MIID;
        
          IF V_COUNT > 0 THEN
            UPDATE PRICEADJUSTLIST T
               SET PALVALUE  = -P_CD.MICOLUMN1,
                   PALENDMON = P_CD.MICOLUMN3,
                   PALPER    = FGETPBOPER,
                   PALDATE   = SYSDATE
             WHERE T.PALMETHOD = '02'
               AND T.PALTACTIC = '02'
               AND PALWAY = -1
               AND PALMID = P_CD.MIID;
          ELSE
            SELECT SEQ_PALID.NEXTVAL
              INTO V_PRICEADJUSTLIST.PALID
              FROM DUAL;
            V_PRICEADJUSTLIST.PALTACTIC   := '02';
            V_PRICEADJUSTLIST.PALMETHOD   := '02';
            V_PRICEADJUSTLIST.PALSMFID    := P_CD.MISMFID;
            V_PRICEADJUSTLIST.PALCID      := P_CD.CIID;
            V_PRICEADJUSTLIST.PALMID      := P_CD.MIID;
            V_PRICEADJUSTLIST.PALWAY      := -1;
            V_PRICEADJUSTLIST.PALVALUE    := P_CD.MICOLUMN1;
            V_PRICEADJUSTLIST.PALSTARTMON := TO_CHAR(SYSDATE, 'yyyy.mm');
            V_PRICEADJUSTLIST.PALENDMON   := P_CD.MICOLUMN3;
            V_PRICEADJUSTLIST.PALSTATUS   := 'Y';
            V_PRICEADJUSTLIST.PALPER      := FGETPBOPER;
            V_PRICEADJUSTLIST.PALDATE     := SYSDATE;
            INSERT INTO PRICEADJUSTLIST VALUES V_PRICEADJUSTLIST;
          END IF;*/
        
        END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '低保户已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
  
       --特困标志
    IF (P_CD.MICOLUMN11 IS NOT NULL AND CDHIS.MICOLUMN11 IS NOT NULL AND
       P_CD.MICOLUMN11 <> CDHIS.MICOLUMN11) OR
       (P_CD.MICOLUMN11 IS NULL AND CDHIS.MICOLUMN11 IS NOT NULL) OR
       (P_CD.MICOLUMN11 IS NOT NULL AND CDHIS.MICOLUMN11 IS NULL) THEN
      IF (METER.MICOLUMN11 IS NOT NULL AND CDHIS.MICOLUMN11 IS NOT NULL AND
         METER.MICOLUMN11 = CDHIS.MICOLUMN11) OR
         (METER.MICOLUMN11 IS NULL AND CDHIS.MICOLUMN11 IS NULL) THEN
        IF NVL(P_CD.MICOLUMN11, 'N') = 'N' THEN
          --取消低保默认给居民水价A0108
          UPDATE METERINFO
             SET MICOLUMN11 = P_CD.MICOLUMN11, MICOLUMN1 = 0, MICOLUMN3 = '',MIPFID='A0108'
           WHERE MIID = P_CD.MIID;
           
        ELSE
          UPDATE METERINFO
             SET MICOLUMN11 = P_CD.MICOLUMN11
           WHERE MIID = P_CD.MIID;
        END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '低保户已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
  
  
    --备用字段3
    IF (P_CD.MICOLUMN3 IS NOT NULL AND CDHIS.MICOLUMN3 IS NOT NULL AND
       P_CD.MICOLUMN3 <> CDHIS.MICOLUMN3) OR
       (P_CD.MICOLUMN3 IS NULL AND CDHIS.MICOLUMN3 IS NOT NULL) OR
       (P_CD.MICOLUMN3 IS NOT NULL AND CDHIS.MICOLUMN3 IS NULL) THEN
      IF (METER.MICOLUMN3 IS NOT NULL AND CDHIS.MICOLUMN3 IS NOT NULL AND
         METER.MICOLUMN3 = CDHIS.MICOLUMN3) OR
         (METER.MICOLUMN3 IS NULL AND CDHIS.MICOLUMN3 IS NULL) THEN
        UPDATE METERINFO
           SET MICOLUMN3 = P_CD.MICOLUMN3
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '低保有效期已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    ---新增字段  20140307
    --低保证件号
    IF (P_CD.MIDBZJH IS NOT NULL AND CDHIS.MIDBZJH IS NOT NULL AND
       P_CD.MIDBZJH <> CDHIS.MIDBZJH) OR
       (P_CD.MIDBZJH IS NULL AND CDHIS.MIDBZJH IS NOT NULL) OR
       (P_CD.MIDBZJH IS NOT NULL AND CDHIS.MIDBZJH IS NULL) THEN
      IF (METER.MIDBZJH IS NOT NULL AND CDHIS.MIDBZJH IS NOT NULL AND
         METER.MIDBZJH = CDHIS.MIDBZJH) OR
         (METER.MIDBZJH IS NULL AND CDHIS.MIDBZJH IS NULL) THEN
        UPDATE METERINFO
           SET MIDBZJH = P_CD.MIDBZJH
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '低保证件号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
       ---新增字段  20170328
    --特困证件号
    IF (P_CD.MITKZJH IS NOT NULL AND CDHIS.MITKZJH IS NOT NULL AND
       P_CD.MITKZJH <> CDHIS.MITKZJH) OR
       (P_CD.MITKZJH IS NULL AND CDHIS.MITKZJH IS NOT NULL) OR
       (P_CD.MITKZJH IS NOT NULL AND CDHIS.MITKZJH IS NULL) THEN
      IF (METER.MITKZJH IS NOT NULL AND CDHIS.MITKZJH IS NOT NULL AND
         METER.MITKZJH = CDHIS.MITKZJH) OR
         (METER.MITKZJH IS NULL AND CDHIS.MITKZJH IS NULL) THEN
        UPDATE METERINFO
           SET MITKZJH = P_CD.MITKZJH
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '低保证件号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --重点户标志
    IF (P_CD.MIIFZDH IS NOT NULL AND CDHIS.MIIFZDH IS NOT NULL AND
       P_CD.MIIFZDH <> CDHIS.MIIFZDH) OR
       (P_CD.MIIFZDH IS NULL AND CDHIS.MIIFZDH IS NOT NULL) OR
       (P_CD.MIIFZDH IS NOT NULL AND CDHIS.MIIFZDH IS NULL) THEN
      IF (METER.MIIFZDH IS NOT NULL AND CDHIS.MIIFZDH IS NOT NULL AND
         METER.MIIFZDH = CDHIS.MIIFZDH) OR
         (METER.MIIFZDH IS NULL AND CDHIS.MIIFZDH IS NULL) THEN
        UPDATE METERINFO
           SET MIIFZDH = P_CD.MIIFZDH
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '重点户标志已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --预留字段1
    IF (P_CD.MIYL1 IS NOT NULL AND CDHIS.MIYL1 IS NOT NULL AND
       P_CD.MIYL1 <> CDHIS.MIYL1) OR
       (P_CD.MIYL1 IS NULL AND CDHIS.MIYL1 IS NOT NULL) OR
       (P_CD.MIYL1 IS NOT NULL AND CDHIS.MIYL1 IS NULL) THEN
      IF (METER.MIYL1 IS NOT NULL AND CDHIS.MIYL1 IS NOT NULL AND
         METER.MIYL1 = CDHIS.MIYL1) OR
         (METER.MIYL1 IS NULL AND CDHIS.MIYL1 IS NULL) THEN
        UPDATE METERINFO
           SET MIYL1 = P_CD.MIYL1
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段1已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --预留字段2
    IF (P_CD.MIYL2 IS NOT NULL AND CDHIS.MIYL2 IS NOT NULL AND
       P_CD.MIYL2 <> CDHIS.MIYL2) OR
       (P_CD.MIYL2 IS NULL AND CDHIS.MIYL2 IS NOT NULL) OR
       (P_CD.MIYL2 IS NOT NULL AND CDHIS.MIYL2 IS NULL) THEN
      IF (METER.MIYL2 IS NOT NULL AND CDHIS.MIYL2 IS NOT NULL AND
         METER.MIYL2 = CDHIS.MIYL2) OR
         (METER.MIYL2 IS NULL AND CDHIS.MIYL2 IS NULL) THEN
        UPDATE METERINFO
           SET MIYL2 = P_CD.MIYL2,
               MIYL7 = P_CD.MIYL7  --总表收免最大水量
         WHERE MIID = P_CD.MIID;
         --判断当月有没有抄表记录，有则同步抄表库标志
          SELECT COUNT(*)
            INTO L_COUNT
            FROM METERREAD
           WHERE MRMCODE = P_CD.MIID;
          IF L_COUNT > 0 THEN
            UPDATE METERREAD SET MRIFZBSM = P_CD.MIYL2 WHERE MRMCODE=P_CD.MIID ;
          END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段2已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --预留字段3
    IF (P_CD.MIYL3 IS NOT NULL AND CDHIS.MIYL3 IS NOT NULL AND
       P_CD.MIYL3 <> CDHIS.MIYL3) OR
       (P_CD.MIYL3 IS NULL AND CDHIS.MIYL3 IS NOT NULL) OR
       (P_CD.MIYL3 IS NOT NULL AND CDHIS.MIYL3 IS NULL) THEN
      IF (METER.MIYL3 IS NOT NULL AND CDHIS.MIYL3 IS NOT NULL AND
         METER.MIYL3 = CDHIS.MIYL3) OR
         (METER.MIYL3 IS NULL AND CDHIS.MIYL3 IS NULL) THEN
        UPDATE METERINFO
           SET MIYL3 = P_CD.MIYL3
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段3已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --预留字段4
    IF (P_CD.MIYL4 IS NOT NULL AND CDHIS.MIYL4 IS NOT NULL AND
       P_CD.MIYL4 <> CDHIS.MIYL4) OR
       (P_CD.MIYL4 IS NULL AND CDHIS.MIYL4 IS NOT NULL) OR
       (P_CD.MIYL4 IS NOT NULL AND CDHIS.MIYL4 IS NULL) THEN
      IF (METER.MIYL4 IS NOT NULL AND CDHIS.MIYL4 IS NOT NULL AND
         METER.MIYL4 = CDHIS.MIYL4) OR
         (METER.MIYL4 IS NULL AND CDHIS.MIYL4 IS NULL) THEN
        if P_CD.MIYL4 is null then
          P_CD.MIYL4  := substr(p_cd.miid,0-6);
        end if;
        IF LENGTH(trim(P_CD.MIYL4)) <> '32' THEN
          UPDATE METERINFO
             SET MIYL4 = md5(P_CD.MIYL4)
           WHERE MIID = P_CD.MIID;
        END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段4已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --预留字段5
    IF (P_CD.MIYL5 IS NOT NULL AND CDHIS.MIYL5 IS NOT NULL AND
       P_CD.MIYL5 <> CDHIS.MIYL5) OR
       (P_CD.MIYL5 IS NULL AND CDHIS.MIYL5 IS NOT NULL) OR
       (P_CD.MIYL5 IS NOT NULL AND CDHIS.MIYL5 IS NULL) THEN
      IF (METER.MIYL5 IS NOT NULL AND CDHIS.MIYL5 IS NOT NULL AND
         METER.MIYL5 = CDHIS.MIYL5) OR
         (METER.MIYL5 IS NULL AND CDHIS.MIYL5 IS NULL) THEN
        UPDATE METERINFO
           SET MIYL5 = P_CD.MIYL5
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段5已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --预留字段6
    IF (P_CD.MIYL6 IS NOT NULL AND CDHIS.MIYL6 IS NOT NULL AND
       P_CD.MIYL6 <> CDHIS.MIYL6) OR
       (P_CD.MIYL6 IS NULL AND CDHIS.MIYL6 IS NOT NULL) OR
       (P_CD.MIYL6 IS NOT NULL AND CDHIS.MIYL6 IS NULL) THEN
      IF (METER.MIYL6 IS NOT NULL AND CDHIS.MIYL6 IS NOT NULL AND
         METER.MIYL6 = CDHIS.MIYL6) OR
         (METER.MIYL6 IS NULL AND CDHIS.MIYL6 IS NULL) THEN
        UPDATE METERINFO
           SET MIYL6 = P_CD.MIYL6
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段6已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    
    --开户名称(电票)
    IF (P_CD.MIBANKNAME IS NOT NULL AND CDHIS.MIBANKNAME IS NOT NULL AND
       P_CD.MIBANKNAME <> CDHIS.MIBANKNAME) OR
       (P_CD.MIBANKNAME IS NULL AND CDHIS.MIBANKNAME IS NOT NULL) OR
       (P_CD.MIBANKNAME IS NOT NULL AND CDHIS.MIBANKNAME IS NULL) THEN
      IF (METER.MIBANKNAME IS NOT NULL AND CDHIS.MIBANKNAME IS NOT NULL AND
         METER.MIBANKNAME = CDHIS.MIBANKNAME) OR
         (METER.MIBANKNAME IS NULL AND CDHIS.MIBANKNAME IS NULL) THEN
        UPDATE METERINFO SET MIBANKNAME = P_CD.MIBANKNAME WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,户号:[' ||
                                P_CD.CIID || ']的' ||
                                '开户行名称(电票)信息已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --开户账号(电票)
    IF (P_CD.MIBANKNO IS NOT NULL AND CDHIS.MIBANKNO IS NOT NULL AND
       P_CD.MIBANKNO <> CDHIS.MIBANKNO) OR
       (P_CD.MIBANKNO IS NULL AND CDHIS.MIBANKNO IS NOT NULL) OR
       (P_CD.MIBANKNO IS NOT NULL AND CDHIS.MIBANKNO IS NULL) THEN
      IF (METER.MIBANKNO IS NOT NULL AND CDHIS.MIBANKNO IS NOT NULL AND
         METER.MIBANKNO = CDHIS.MIBANKNO) OR
         (METER.MIBANKNO IS NULL AND CDHIS.MIBANKNO IS NULL) THEN
        UPDATE METERINFO SET MIBANKNO = P_CD.MIBANKNO WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,户号:[' ||
                                P_CD.CIID || ']的' ||
                                '开户账号(电票)信息已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --预留字段7
    IF (P_CD.MIYL7 IS NOT NULL AND nvl(CDHIS.MIYL7,0) IS NOT NULL AND
       P_CD.MIYL7 <> nvl(CDHIS.MIYL7,0)) OR
       (P_CD.MIYL7 IS NULL AND nvl(CDHIS.MIYL7,0) IS NOT NULL) OR
       (P_CD.MIYL7 IS NOT NULL AND nvl(CDHIS.MIYL7,0) IS NULL) THEN
      IF (nvl(METER.MIYL7,0) IS NOT NULL AND nvl(CDHIS.MIYL7,0) IS NOT NULL AND
         nvl(METER.MIYL7,0) = nvl(CDHIS.MIYL7,0)) OR
         ( nvl(METER.MIYL7,0) IS NULL AND nvl(CDHIS.MIYL7,0) IS NULL) THEN
        UPDATE METERINFO
           SET MIYL7 = P_CD.MIYL7
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段7已经1发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --预留字段8
    IF (P_CD.MIYL8 IS NOT NULL AND CDHIS.MIYL8 IS NOT NULL AND
       P_CD.MIYL8 <> CDHIS.MIYL8) OR
       (P_CD.MIYL8 IS NULL AND CDHIS.MIYL8 IS NOT NULL) OR
       (P_CD.MIYL8 IS NOT NULL AND CDHIS.MIYL8 IS NULL) THEN
      IF (METER.MIYL8 IS NOT NULL AND CDHIS.MIYL8 IS NOT NULL AND
         METER.MIYL8 = CDHIS.MIYL8) OR
         (METER.MIYL8 IS NULL AND CDHIS.MIYL8 IS NULL) THEN
        UPDATE METERINFO
           SET MIYL8 = P_CD.MIYL8
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段8已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --预留字段9
    IF (P_CD.MIYL9 IS NOT NULL AND CDHIS.MIYL9 IS NOT NULL AND
       P_CD.MIYL9 <> CDHIS.MIYL9) OR
       (P_CD.MIYL9 IS NULL AND CDHIS.MIYL9 IS NOT NULL) OR
       (P_CD.MIYL9 IS NOT NULL AND CDHIS.MIYL9 IS NULL) THEN
      IF (METER.MIYL9 IS NOT NULL AND CDHIS.MIYL9 IS NOT NULL AND
         METER.MIYL9 = CDHIS.MIYL9) OR
         (METER.MIYL9 IS NULL AND CDHIS.MIYL9 IS NULL) THEN
         SELECT nvl(mrecode,mircode) 
           INTO v_rcode
           FROM meterinfo 
           left join ( select mrecode,mrmcode from  METERREAD MR 
                       WHERE MR.MRMID = P_CD.MIID
                             and MR.mrreadok ='Y' --已抄表
                             AND MR.MRIFREC <> 'Y'--未算费
                      ) on micode=mrmcode
           where micode=P_CD.MIID; 
           
         IF v_rcode > p_cd.miyl9 THEN  --检查水表量程是否合理，不能小于当前水表读数
               RAISE_APPLICATION_ERROR(ERRCODE, '此水表当前读数已超过该工单中设置的最大量程，请检查!');
         else
          UPDATE METERINFO
             SET MIYL9 = P_CD.MIYL9
           WHERE MIID = P_CD.MIID;
         end if;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段9已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --预留字段10
    IF (P_CD.MIYL10 IS NOT NULL AND CDHIS.MIYL10 IS NOT NULL AND
       P_CD.MIYL10 <> CDHIS.MIYL10) OR
       (P_CD.MIYL10 IS NULL AND CDHIS.MIYL10 IS NOT NULL) OR
       (P_CD.MIYL10 IS NOT NULL AND CDHIS.MIYL10 IS NULL) THEN
      IF (METER.MIYL10 IS NOT NULL AND CDHIS.MIYL10 IS NOT NULL AND
         METER.MIYL10 = CDHIS.MIYL10) OR
         (METER.MIYL10 IS NULL AND CDHIS.MIYL10 IS NULL) THEN
        UPDATE METERINFO
           SET MIYL10 = P_CD.MIYL10
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段10已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --预留字段11
    IF (P_CD.MIYL11 IS NOT NULL AND CDHIS.MIYL11 IS NOT NULL AND
       P_CD.MIYL11 <> CDHIS.MIYL11) OR
       (P_CD.MIYL11 IS NULL AND CDHIS.MIYL11 IS NOT NULL) OR
       (P_CD.MIYL11 IS NOT NULL AND CDHIS.MIYL11 IS NULL) THEN
      IF (METER.MIYL11 IS NOT NULL AND CDHIS.MIYL11 IS NOT NULL AND
         METER.MIYL11 = CDHIS.MIYL11) OR
         (METER.MIYL11 IS NULL AND CDHIS.MIYL11 IS NULL) THEN
        UPDATE METERINFO
           SET MIYL11 = P_CD.MIYL11
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段11已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    --预留字段12
    IF (P_CD.MIYL12 IS NOT NULL AND CDHIS.MIYL12 IS NOT NULL AND
       P_CD.MIYL12 <> CDHIS.MIYL12) OR
       (P_CD.MIYL12 IS NULL AND CDHIS.MIYL12 IS NOT NULL) OR
       (P_CD.MIYL12 IS NOT NULL AND CDHIS.MIYL12 IS NULL) THEN
      IF (METER.MIYL12 IS NOT NULL AND CDHIS.MIYL12 IS NOT NULL AND
         METER.MIYL12 = CDHIS.MIYL12) OR
         (METER.MIYL12 IS NULL AND CDHIS.MIYL12 IS NULL) THEN
        UPDATE METERINFO
           SET MIYL12 = P_CD.MIYL12
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段12已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    
    --备用字段4
    IF (P_CD.MICOLUMN4 IS NOT NULL AND CDHIS.MICOLUMN4 IS NOT NULL AND
       P_CD.MICOLUMN4 <> CDHIS.MICOLUMN4) OR
       (P_CD.MICOLUMN4 IS NULL AND CDHIS.MICOLUMN4 IS NOT NULL) OR
       (P_CD.MICOLUMN4 IS NOT NULL AND CDHIS.MICOLUMN4 IS NULL) THEN
      IF (METER.MICOLUMN4 IS NOT NULL AND CDHIS.MICOLUMN4 IS NOT NULL AND
         METER.MICOLUMN4 = CDHIS.MICOLUMN4) OR
         (METER.MICOLUMN4 IS NULL AND CDHIS.MICOLUMN4 IS NULL) THEN
        UPDATE METERINFO
           SET MICOLUMN4 = P_CD.MICOLUMN4
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '备用字段4已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --备用字段5
    IF (P_CD.MICOLUMN5 IS NOT NULL AND CDHIS.MICOLUMN5 IS NOT NULL AND
       P_CD.MICOLUMN5 <> CDHIS.MICOLUMN5) OR
       (P_CD.MICOLUMN5 IS NULL AND CDHIS.MICOLUMN5 IS NOT NULL) OR
       (P_CD.MICOLUMN5 IS NOT NULL AND CDHIS.MICOLUMN5 IS NULL) THEN
      IF (METER.MICOLUMN5 IS NOT NULL AND CDHIS.MICOLUMN5 IS NOT NULL AND
         METER.MICOLUMN5 = CDHIS.MICOLUMN5) OR
         (METER.MICOLUMN5 IS NULL AND CDHIS.MICOLUMN5 IS NULL) THEN
        UPDATE METERINFO
           SET MICOLUMN5 = P_CD.MICOLUMN5
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '用水额度已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --备用字段6
    IF (P_CD.MICOLUMN6 IS NOT NULL AND CDHIS.MICOLUMN6 IS NOT NULL AND
       P_CD.MICOLUMN6 <> CDHIS.MICOLUMN6) OR
       (P_CD.MICOLUMN6 IS NULL AND CDHIS.MICOLUMN6 IS NOT NULL) OR
       (P_CD.MICOLUMN6 IS NOT NULL AND CDHIS.MICOLUMN6 IS NULL) THEN
      IF (METER.MICOLUMN6 IS NOT NULL AND CDHIS.MICOLUMN6 IS NOT NULL AND
         METER.MICOLUMN6 = CDHIS.MICOLUMN6) OR
         (METER.MICOLUMN6 IS NULL AND CDHIS.MICOLUMN6 IS NULL) THEN
        UPDATE METERINFO
           SET MICOLUMN6 = P_CD.MICOLUMN6
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段6已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --备用字段7
    IF (P_CD.MICOLUMN7 IS NOT NULL AND CDHIS.MICOLUMN7 IS NOT NULL AND
       P_CD.MICOLUMN7 <> CDHIS.MICOLUMN7) OR
       (P_CD.MICOLUMN7 IS NULL AND CDHIS.MICOLUMN7 IS NOT NULL) OR
       (P_CD.MICOLUMN7 IS NOT NULL AND CDHIS.MICOLUMN7 IS NULL) THEN
      IF (METER.MICOLUMN7 IS NOT NULL AND  CDHIS.MICOLUMN7 IS NOT NULL AND
         METER.MICOLUMN7 = CDHIS.MICOLUMN7) OR
         (METER.MICOLUMN7 IS NULL AND CDHIS.MICOLUMN7 IS NULL) THEN
        UPDATE METERINFO
           SET MICOLUMN7 = P_CD.MICOLUMN7
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段7已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --备用字段8
    IF (P_CD.MICOLUMN8 IS NOT NULL AND CDHIS.MICOLUMN8 IS NOT NULL AND
       P_CD.MICOLUMN8 <> CDHIS.MICOLUMN8) OR
       (P_CD.MICOLUMN8 IS NULL AND CDHIS.MICOLUMN8 IS NOT NULL) OR
       (P_CD.MICOLUMN8 IS NOT NULL AND CDHIS.MICOLUMN8 IS NULL) THEN
      IF (METER.MICOLUMN8 IS NOT NULL AND CDHIS.MICOLUMN8 IS NOT NULL AND
         METER.MICOLUMN8 = CDHIS.MICOLUMN8) OR
         (METER.MICOLUMN8 IS NULL AND CDHIS.MICOLUMN8 IS NULL) THEN
        UPDATE METERINFO
           SET MICOLUMN8 = P_CD.MICOLUMN8
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段8已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --备用字段9
    IF (P_CD.MICOLUMN9 IS NOT NULL AND CDHIS.MICOLUMN9 IS NOT NULL AND
       P_CD.MICOLUMN9 <> CDHIS.MICOLUMN9) OR
       (P_CD.MICOLUMN9 IS NULL AND CDHIS.MICOLUMN9 IS NOT NULL) OR
       (P_CD.MICOLUMN9 IS NOT NULL AND CDHIS.MICOLUMN9 IS NULL) THEN
      IF (METER.MICOLUMN9 IS NOT NULL AND CDHIS.MICOLUMN9 IS NOT NULL AND
         METER.MICOLUMN9 = CDHIS.MICOLUMN9) OR
         (METER.MICOLUMN9 IS NULL AND CDHIS.MICOLUMN9 IS NULL) THEN
        UPDATE METERINFO
           SET MICOLUMN9 = P_CD.MICOLUMN9
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段9已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --备用字段10
    IF (P_CD.MICOLUMN10 IS NOT NULL AND CDHIS.MICOLUMN10 IS NOT NULL AND
       P_CD.MICOLUMN10 <> CDHIS.MICOLUMN10) OR
       (P_CD.MICOLUMN10 IS NULL AND CDHIS.MICOLUMN10 IS NOT NULL) OR
       (P_CD.MICOLUMN10 IS NOT NULL AND CDHIS.MICOLUMN10 IS NULL) THEN
      IF (METER.MICOLUMN10 IS NOT NULL AND CDHIS.MICOLUMN10 IS NOT NULL AND
         METER.MICOLUMN10 = CDHIS.MICOLUMN10) OR
         (METER.MICOLUMN10 IS NULL AND CDHIS.MICOLUMN10 IS NULL) THEN
        UPDATE METERINFO
           SET MICOLUMN10 = P_CD.MICOLUMN10
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '预留字段10已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    
    ---新增字段 20171212
    --周期（合同用）
    IF P_TYPE IN ('45') THEN
    IF (P_CD.MIHTZQ IS NOT NULL AND CDHIS.MIHTZQ IS NOT NULL AND
       P_CD.MIHTZQ <> CDHIS.MIHTZQ) OR
       (P_CD.MIHTZQ IS NULL AND CDHIS.MIHTZQ IS NOT NULL) OR
       (P_CD.MIHTZQ IS NOT NULL AND CDHIS.MIHTZQ IS NULL) THEN
      IF (METER.MIHTZQ IS NOT NULL AND CDHIS.MIHTZQ IS NOT NULL AND
         METER.MIHTZQ = CDHIS.MIHTZQ) OR
         (METER.MIHTZQ IS NULL AND CDHIS.MIHTZQ IS NULL) THEN
        UPDATE METERINFO
           SET MIHTZQ = P_CD.MIHTZQ
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '收费周期已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    
    ---新增字段 20171212
    --合同编号
    IF (P_CD.MIHTBH IS NOT NULL AND CDHIS.MIHTBH IS NOT NULL AND
       P_CD.MIHTBH <> CDHIS.MIHTBH) OR
       (P_CD.MIHTBH IS NULL AND CDHIS.MIHTBH IS NOT NULL) OR
       (P_CD.MIHTBH IS NOT NULL AND CDHIS.MIHTBH IS NULL) THEN
      IF (METER.MIHTBH IS NOT NULL AND CDHIS.MIHTBH IS NOT NULL AND
         METER.MIHTBH = CDHIS.MIHTBH) OR
         (METER.MIHTBH IS NULL AND CDHIS.MIHTBH IS NULL) THEN
        UPDATE METERINFO
           SET MIHTBH = P_CD.MIHTBH,ZFDATE = NULL
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '合同编号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    ---新增字段 20171212
    --日期限制
    IF (P_CD.MIRQXZ IS NOT NULL AND CDHIS.MIRQXZ IS NOT NULL AND
       P_CD.MIRQXZ <> CDHIS.MIRQXZ) OR
       (P_CD.MIRQXZ IS NULL AND CDHIS.MIRQXZ IS NOT NULL) OR
       (P_CD.MIRQXZ IS NOT NULL AND CDHIS.MIRQXZ IS NULL) THEN
      IF (METER.MIRQXZ IS NOT NULL AND CDHIS.MIRQXZ IS NOT NULL AND
         METER.MIRQXZ = CDHIS.MIRQXZ) OR
         (METER.MIRQXZ IS NULL AND CDHIS.MIRQXZ IS NULL) THEN
        UPDATE METERINFO
           SET MIRQXZ = P_CD.MIRQXZ
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '缴费期限已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    
    ---新增字段 20171212
    --合同签订日期
    IF (P_CD.HTDATE IS NOT NULL AND CDHIS.HTDATE IS NOT NULL AND
       P_CD.HTDATE <> CDHIS.HTDATE) OR
       (P_CD.HTDATE IS NULL AND CDHIS.HTDATE IS NOT NULL) OR
       (P_CD.HTDATE IS NOT NULL AND CDHIS.HTDATE IS NULL) THEN
      IF (METER.HTDATE IS NOT NULL AND CDHIS.HTDATE IS NOT NULL AND
         METER.HTDATE = CDHIS.HTDATE) OR
         (METER.HTDATE IS NULL AND CDHIS.HTDATE IS NULL) THEN
        UPDATE METERINFO
           SET HTDATE = P_CD.HTDATE
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '合同签订日期已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
        ---新增字段 20171212
    --合同签订截止日期
    IF (P_CD.JZDATE IS NOT NULL AND CDHIS.JZDATE IS NOT NULL AND
       P_CD.JZDATE <> CDHIS.JZDATE) OR
       (P_CD.JZDATE IS NULL AND CDHIS.JZDATE IS NOT NULL) OR
       (P_CD.JZDATE IS NOT NULL AND CDHIS.JZDATE IS NULL) THEN
      IF (METER.JZDATE IS NOT NULL AND CDHIS.JZDATE IS NOT NULL AND
         METER.JZDATE = CDHIS.JZDATE) OR
         (METER.JZDATE IS NULL AND CDHIS.JZDATE IS NULL) THEN
        UPDATE METERINFO
           SET JZDATE = P_CD.JZDATE
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '合同签订截止日期已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
        ---新增字段 20171212
    --合同签订人
    IF (P_CD.SIGNPER IS NOT NULL AND CDHIS.SIGNPER IS NOT NULL AND
       P_CD.SIGNPER <> CDHIS.SIGNPER) OR
       (P_CD.SIGNPER IS NULL AND CDHIS.SIGNPER IS NOT NULL) OR
       (P_CD.SIGNPER IS NOT NULL AND CDHIS.SIGNPER IS NULL) THEN
      IF (METER.SIGNPER IS NOT NULL AND CDHIS.SIGNPER IS NOT NULL AND
         METER.SIGNPER = CDHIS.SIGNPER) OR
         (METER.SIGNPER IS NULL AND CDHIS.SIGNPER IS NULL) THEN
        UPDATE METERINFO
           SET SIGNPER = P_CD.SIGNPER
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '合同签订人已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
        ---新增字段 20171212
    --签订人身份证号
    IF (P_CD.SIGNID IS NOT NULL AND CDHIS.SIGNID IS NOT NULL AND
       P_CD.SIGNID <> CDHIS.SIGNID) OR
       (P_CD.SIGNID IS NULL AND CDHIS.SIGNID IS NOT NULL) OR
       (P_CD.SIGNID IS NOT NULL AND CDHIS.SIGNID IS NULL) THEN
      IF (METER.SIGNID IS NOT NULL AND CDHIS.SIGNID IS NOT NULL AND
         METER.SIGNID = CDHIS.SIGNID) OR
         (METER.SIGNID IS NULL AND CDHIS.SIGNID IS NULL) THEN
        UPDATE METERINFO
           SET SIGNID = P_CD.SIGNID
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '签订人身份证号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
        ---新增字段 20171212
    --房产证号
    IF (P_CD.POCID IS NOT NULL AND CDHIS.POCID IS NOT NULL AND
       P_CD.POCID <> CDHIS.POCID) OR
       (P_CD.POCID IS NULL AND CDHIS.POCID IS NOT NULL) OR
       (P_CD.POCID IS NOT NULL AND CDHIS.POCID IS NULL) THEN
      IF (METER.POCID IS NOT NULL AND CDHIS.POCID IS NOT NULL AND
         METER.POCID = CDHIS.POCID) OR
         (METER.POCID IS NULL AND CDHIS.POCID IS NULL) THEN
        UPDATE METERINFO
           SET POCID = P_CD.POCID
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '房产证号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    END IF;
    
    ---新增字段 20171212
    --合同作废日期
    IF P_TYPE IN ('46') THEN
      IF (P_CD.ZFDATE IS NOT NULL AND CDHIS.ZFDATE IS NOT NULL AND
         P_CD.ZFDATE <> CDHIS.ZFDATE) OR
         (P_CD.ZFDATE IS NULL AND CDHIS.ZFDATE IS NOT NULL) OR
         (P_CD.ZFDATE IS NOT NULL AND CDHIS.ZFDATE IS NULL) THEN
        IF (METER.ZFDATE IS NOT NULL AND CDHIS.ZFDATE IS NOT NULL AND
           METER.ZFDATE = CDHIS.ZFDATE) OR
           (METER.ZFDATE IS NULL AND CDHIS.ZFDATE IS NULL) THEN
          UPDATE METERINFO
             SET ZFDATE = SYSDATE
           WHERE MIID = P_CD.MIID;
        ELSE
          ROLLBACK;
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                  P_CD.MIID || ']的' ||
                                  '合同作废日期已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
        END IF;
      END IF;
    END IF;
    IF P_TYPE IN ('45') THEN
      IF (P_CD.ZFDATE IS NOT NULL AND CDHIS.ZFDATE IS NOT NULL AND
         P_CD.ZFDATE <> CDHIS.ZFDATE) OR
         (P_CD.ZFDATE IS NULL AND CDHIS.ZFDATE IS NOT NULL) OR
         (P_CD.ZFDATE IS NOT NULL AND CDHIS.ZFDATE IS NULL) THEN
        IF (METER.ZFDATE IS NOT NULL AND CDHIS.ZFDATE IS NOT NULL AND
           METER.ZFDATE = CDHIS.ZFDATE) OR
           (METER.ZFDATE IS NULL AND CDHIS.ZFDATE IS NULL) THEN
          UPDATE METERINFO
             SET ZFDATE = ''
           WHERE MIID = P_CD.MIID;
        ELSE
          ROLLBACK;
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                  P_CD.MIID || ']的' ||
                                  '合同作废日期已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
        END IF;
      END IF;
    END IF;
    
    --税号
    IF (P_CD.MITAXNO IS NOT NULL AND CDHIS.MITAXNO IS NOT NULL AND
       P_CD.MITAXNO <> CDHIS.MITAXNO) OR
       (P_CD.MITAXNO IS NULL AND CDHIS.MITAXNO IS NOT NULL) OR
       (P_CD.MITAXNO IS NOT NULL AND CDHIS.MITAXNO IS NULL) THEN
      IF (METER.MITAXNO IS NOT NULL AND CDHIS.MITAXNO IS NOT NULL AND
         METER.MITAXNO = CDHIS.MITAXNO) OR
         (METER.MITAXNO IS NULL AND CDHIS.MITAXNO IS NULL) THEN
        UPDATE METERINFO SET MITAXNO = P_CD.MITAXNO WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '税号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --行业分类
    IF (P_CD.MISTID IS NOT NULL AND CDHIS.MISTID IS NOT NULL AND
       P_CD.MISTID <> CDHIS.MISTID) OR
       (P_CD.MISTID IS NULL AND CDHIS.MISTID IS NOT NULL) OR
       (P_CD.MISTID IS NOT NULL AND CDHIS.MISTID IS NULL) THEN
      IF (METER.MISTID IS NOT NULL AND CDHIS.MISTID IS NOT NULL AND
         METER.MISTID = CDHIS.MISTID) OR
         (METER.MISTID IS NULL AND CDHIS.MISTID IS NULL) THEN
        UPDATE METERINFO SET MISTID = P_CD.MISTID WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '行业分类已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --装表日期
    IF (P_CD.MIINSDATE IS NOT NULL AND CDHIS.MIINSDATE IS NOT NULL AND
       P_CD.MIINSDATE <> CDHIS.MIINSDATE) OR
       (P_CD.MIINSDATE IS NULL AND CDHIS.MIINSDATE IS NOT NULL) OR
       (P_CD.MIINSDATE IS NOT NULL AND CDHIS.MIINSDATE IS NULL) THEN
      IF (METER.MIINSDATE IS NOT NULL AND CDHIS.MIINSDATE IS NOT NULL AND
         METER.MIINSDATE = CDHIS.MIINSDATE) OR
         (METER.MIINSDATE IS NULL AND CDHIS.MIINSDATE IS NULL) THEN
        UPDATE METERINFO
           SET MIINSDATE = P_CD.MIINSDATE
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '装表日期已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --类型
    IF (P_CD.MITYPE IS NOT NULL AND CDHIS.MITYPE IS NOT NULL AND
       P_CD.MITYPE <> CDHIS.MITYPE) OR
       (P_CD.MITYPE IS NULL AND CDHIS.MITYPE IS NOT NULL) OR
       (P_CD.MITYPE IS NOT NULL AND CDHIS.MITYPE IS NULL) THEN
      IF (METER.MITYPE IS NOT NULL AND CDHIS.MITYPE IS NOT NULL AND
         METER.MITYPE = CDHIS.MITYPE) OR
         (METER.MITYPE IS NULL AND CDHIS.MITYPE IS NULL) THEN
        UPDATE METERINFO SET MITYPE = P_CD.MITYPE WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '类型已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --表口径
    IF (P_CD.MDCALIBER IS NOT NULL AND CDHIS.MDCALIBER IS NOT NULL AND
       P_CD.MDCALIBER <> CDHIS.MDCALIBER) OR
       (P_CD.MDCALIBER IS NULL AND CDHIS.MDCALIBER IS NOT NULL) OR
       (P_CD.MDCALIBER IS NOT NULL AND CDHIS.MDCALIBER IS NULL) THEN
      IF (MDOC.MDCALIBER IS NOT NULL AND CDHIS.MDCALIBER IS NOT NULL AND
         MDOC.MDCALIBER = CDHIS.MDCALIBER) OR
         (MDOC.MDCALIBER IS NULL AND CDHIS.MDCALIBER IS NULL) THEN
        UPDATE METERDOC
           SET MDCALIBER = P_CD.MDCALIBER
         WHERE MDMID = P_CD.MDMID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MDMID || ']的' ||
                                '表口径已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --表厂家
    IF (P_CD.MDBRAND IS NOT NULL AND CDHIS.MDBRAND IS NOT NULL AND
       P_CD.MDBRAND <> CDHIS.MDBRAND) OR
       (P_CD.MDBRAND IS NULL AND CDHIS.MDBRAND IS NOT NULL) OR
       (P_CD.MDBRAND IS NOT NULL AND CDHIS.MDBRAND IS NULL) THEN
      IF (MDOC.MDBRAND IS NOT NULL AND CDHIS.MDBRAND IS NOT NULL AND
         MDOC.MDBRAND = CDHIS.MDBRAND) OR
         (MDOC.MDBRAND IS NULL AND CDHIS.MDBRAND IS NULL) THEN
        UPDATE METERDOC
           SET MDBRAND = P_CD.MDBRAND
         WHERE MDMID = P_CD.MDMID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MDMID || ']的' ||
                                '表厂家已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --表型号
    IF (P_CD.MDMODEL IS NOT NULL AND CDHIS.MDMODEL IS NOT NULL AND
       P_CD.MDMODEL <> CDHIS.MDMODEL) OR
       (P_CD.MDMODEL IS NULL AND CDHIS.MDMODEL IS NOT NULL) OR
       (P_CD.MDMODEL IS NOT NULL AND CDHIS.MDMODEL IS NULL) THEN
      IF (MDOC.MDMODEL IS NOT NULL AND CDHIS.MDMODEL IS NOT NULL AND
         MDOC.MDMODEL = CDHIS.MDMODEL) OR
         (MDOC.MDMODEL IS NULL AND CDHIS.MDMODEL IS NULL) THEN
        UPDATE METERDOC
           SET MDMODEL = P_CD.MDMODEL
         WHERE MDMID = P_CD.MDMID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MDMID || ']的' ||
                                '表型号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --付款银行
    IF (P_CD.MABANKID IS NOT NULL AND CDHIS.MABANKID IS NOT NULL AND
       P_CD.MABANKID <> CDHIS.MABANKID) OR
       (P_CD.MABANKID IS NULL AND CDHIS.MABANKID IS NOT NULL) OR
       (P_CD.MABANKID IS NOT NULL AND CDHIS.MABANKID IS NULL) THEN
      IF (MACCT.MABANKID IS NOT NULL AND CDHIS.MABANKID IS NOT NULL AND
         MACCT.MABANKID = CDHIS.MABANKID) OR
         (MACCT.MABANKID IS NULL AND CDHIS.MABANKID IS NULL) THEN
        UPDATE METERACCOUNT
           SET MABANKID = P_CD.MABANKID
         WHERE MAMID = P_CD.MIID;
        IF SQL%ROWCOUNT <= 0 OR SQL%ROWCOUNT IS NULL THEN
          INSERT INTO METERACCOUNT
            (MAMID,
             MANO,
             MANONAME,
             MABANKID,
             MAACCOUNTNO,
             MAACCOUNTNAME,
             MATSBANKID,
             MATSBANKNAME,
             MAIFXEZF,
             MAREGDATE,
             MAMICODE)
          VALUES
            (P_CD.MIID,
             NULL,
             NULL,
             P_CD.MABANKID,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             CURRENTDATE,
             P_CD.MICODE);
        END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '付款银行已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --付款帐号
    IF (P_CD.MAACCOUNTNO IS NOT NULL AND CDHIS.MAACCOUNTNO IS NOT NULL AND
       P_CD.MAACCOUNTNO <> CDHIS.MAACCOUNTNO) OR
       (P_CD.MAACCOUNTNO IS NULL AND CDHIS.MAACCOUNTNO IS NOT NULL) OR
       (P_CD.MAACCOUNTNO IS NOT NULL AND CDHIS.MAACCOUNTNO IS NULL) THEN
      IF (MACCT.MAACCOUNTNO IS NOT NULL AND CDHIS.MAACCOUNTNO IS NOT NULL AND
         MACCT.MAACCOUNTNO = CDHIS.MAACCOUNTNO) OR
         (MACCT.MAACCOUNTNO IS NULL AND CDHIS.MAACCOUNTNO IS NULL) THEN
        UPDATE METERACCOUNT
           SET MAACCOUNTNO = P_CD.MAACCOUNTNO
         WHERE MAMID = P_CD.MIID;
        IF SQL%ROWCOUNT <= 0 OR SQL%ROWCOUNT IS NULL THEN
          INSERT INTO METERACCOUNT
            (MAMID,
             MANO,
             MANONAME,
             MABANKID,
             MAACCOUNTNO,
             MAACCOUNTNAME,
             MATSBANKID,
             MATSBANKNAME,
             MAIFXEZF,
             MAREGDATE,
             MAMICODE)
          VALUES
            (P_CD.MIID,
             NULL,
             NULL,
             NULL,
             P_CD.MAACCOUNTNO,
             NULL,
             NULL,
             NULL,
             NULL,
             CURRENTDATE,
             P_CD.MICODE);
        END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '付款帐号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --付款帐户名
    IF (P_CD.MAACCOUNTNAME IS NOT NULL AND CDHIS.MAACCOUNTNAME IS NOT NULL AND
       P_CD.MAACCOUNTNAME <> CDHIS.MAACCOUNTNAME) OR
       (P_CD.MAACCOUNTNAME IS NULL AND CDHIS.MAACCOUNTNAME IS NOT NULL) OR
       (P_CD.MAACCOUNTNAME IS NOT NULL AND CDHIS.MAACCOUNTNAME IS NULL) THEN
      IF (MACCT.MAACCOUNTNAME IS NOT NULL AND
         CDHIS.MAACCOUNTNAME IS NOT NULL AND
         MACCT.MAACCOUNTNAME = CDHIS.MAACCOUNTNAME) OR
         (MACCT.MAACCOUNTNAME IS NULL AND CDHIS.MAACCOUNTNAME IS NULL) THEN
        UPDATE METERACCOUNT
           SET MAACCOUNTNAME = P_CD.MAACCOUNTNAME
         WHERE MAMID = P_CD.MIID;
        IF SQL%ROWCOUNT <= 0 OR SQL%ROWCOUNT IS NULL THEN
          INSERT INTO METERACCOUNT
            (MAMID,
             MANO,
             MANONAME,
             MABANKID,
             MAACCOUNTNO,
             MAACCOUNTNAME,
             MATSBANKID,
             MATSBANKNAME,
             MAIFXEZF,
             MAREGDATE,
             MAMICODE)
          VALUES
            (P_CD.MIID,
             NULL,
             NULL,
             NULL,
             NULL,
             P_CD.MAACCOUNTNAME,
             NULL,
             NULL,
             NULL,
             CURRENTDATE,
             P_CD.MICODE);
        END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '付款帐户名已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --收款银行
    IF (P_CD.MATSBANKID IS NOT NULL AND CDHIS.MATSBANKID IS NOT NULL AND
       P_CD.MATSBANKID <> CDHIS.MATSBANKID) OR
       (P_CD.MATSBANKID IS NULL AND CDHIS.MATSBANKID IS NOT NULL) OR
       (P_CD.MATSBANKID IS NOT NULL AND CDHIS.MATSBANKID IS NULL) THEN
      IF (MACCT.MATSBANKID IS NOT NULL AND CDHIS.MATSBANKID IS NOT NULL AND
         MACCT.MATSBANKID = CDHIS.MATSBANKID) OR
         (MACCT.MATSBANKID IS NULL AND CDHIS.MATSBANKID IS NULL) THEN
        UPDATE METERACCOUNT
           SET MATSBANKID = P_CD.MATSBANKID
         WHERE MAMID = P_CD.MIID;
        IF SQL%ROWCOUNT <= 0 OR SQL%ROWCOUNT IS NULL THEN
          INSERT INTO METERACCOUNT
            (MAMID,
             MANO,
             MANONAME,
             MABANKID,
             MAACCOUNTNO,
             MAACCOUNTNAME,
             MATSBANKID,
             MATSBANKNAME,
             MAIFXEZF,
             MAREGDATE,
             MAMICODE)
          VALUES
            (P_CD.MIID,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             P_CD.MATSBANKID,
             NULL,
             NULL,
             CURRENTDATE,
             P_CD.MICODE);
        END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '收款银行已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --签约日期
    IF (P_CD.MAREGDATE IS NOT NULL AND CDHIS.MAREGDATE IS NOT NULL AND
       P_CD.MAREGDATE <> CDHIS.MAREGDATE) OR
       (P_CD.MAREGDATE IS NULL AND CDHIS.MAREGDATE IS NOT NULL) OR
       (P_CD.MAREGDATE IS NOT NULL AND CDHIS.MAREGDATE IS NULL) THEN
      IF (MACCT.MAREGDATE IS NOT NULL AND CDHIS.MAREGDATE IS NOT NULL AND
         MACCT.MAREGDATE = CDHIS.MAREGDATE) OR
         (MACCT.MAREGDATE IS NULL AND CDHIS.MAREGDATE IS NULL) THEN
        UPDATE METERACCOUNT
           SET MAREGDATE = P_CD.MAREGDATE
         WHERE MAMID = P_CD.MIID;
        IF SQL%ROWCOUNT <= 0 OR SQL%ROWCOUNT IS NULL THEN
          INSERT INTO METERACCOUNT
            (MAMID,
             MANO,
             MANONAME,
             MABANKID,
             MAACCOUNTNO,
             MAACCOUNTNAME,
             MATSBANKID,
             MATSBANKNAME,
             MAIFXEZF,
             MAREGDATE,
             MAMICODE)
          VALUES
            (P_CD.MIID,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             P_CD.MAREGDATE,
             P_CD.MICODE);
        END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '签约日期已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --委托授权号
    IF (P_CD.MANO IS NOT NULL AND CDHIS.MANO IS NOT NULL AND
       P_CD.MANO <> CDHIS.MANO) OR
       (P_CD.MANO IS NULL AND CDHIS.MANO IS NOT NULL) OR
       (P_CD.MANO IS NOT NULL AND CDHIS.MANO IS NULL) THEN
      IF (MACCT.MANO IS NOT NULL AND CDHIS.MANO IS NOT NULL AND
         MACCT.MANO = CDHIS.MANO) OR
         (MACCT.MANO IS NULL AND CDHIS.MANO IS NULL) THEN
        UPDATE METERACCOUNT SET MANO = P_CD.MANO WHERE MAMID = P_CD.MIID;
        IF SQL%ROWCOUNT <= 0 OR SQL%ROWCOUNT IS NULL THEN
          INSERT INTO METERACCOUNT
            (MAMID,
             MANO,
             MANONAME,
             MABANKID,
             MAACCOUNTNO,
             MAACCOUNTNAME,
             MATSBANKID,
             MATSBANKNAME,
             MAIFXEZF,
             MAREGDATE,
             MAMICODE)
          VALUES
            (P_CD.MIID,
             P_CD.MANO,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             CURRENTDATE,
             P_CD.MICODE);
        END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '委托授权号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --签约户名
    IF (P_CD.MANONAME IS NOT NULL AND CDHIS.MANONAME IS NOT NULL AND
       P_CD.MANONAME <> CDHIS.MANONAME) OR
       (P_CD.MANONAME IS NULL AND CDHIS.MANONAME IS NOT NULL) OR
       (P_CD.MANONAME IS NOT NULL AND CDHIS.MANONAME IS NULL) THEN
      IF (MACCT.MANONAME IS NOT NULL AND CDHIS.MANONAME IS NOT NULL AND
         MACCT.MANONAME = CDHIS.MANONAME) OR
         (MACCT.MANONAME IS NULL AND CDHIS.MANONAME IS NULL) THEN
        UPDATE METERACCOUNT
           SET MANONAME = P_CD.MANONAME
         WHERE MAMID = P_CD.MIID;
        IF SQL%ROWCOUNT <= 0 OR SQL%ROWCOUNT IS NULL THEN
          INSERT INTO METERACCOUNT
            (MAMID,
             MANO,
             MANONAME,
             MABANKID,
             MAACCOUNTNO,
             MAACCOUNTNAME,
             MATSBANKID,
             MATSBANKNAME,
             MAIFXEZF,
             MAREGDATE,
             MAMICODE)
          VALUES
            (P_CD.MIID,
             NULL,
             P_CD.MANONAME,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             CURRENTDATE,
             P_CD.MICODE);
        END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '签约户名已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --凭证银行（托）
    IF (P_CD.MATSBANKNAME IS NOT NULL AND CDHIS.MATSBANKNAME IS NOT NULL AND
       P_CD.MATSBANKNAME <> CDHIS.MATSBANKNAME) OR
       (P_CD.MATSBANKNAME IS NULL AND CDHIS.MATSBANKNAME IS NOT NULL) OR
       (P_CD.MATSBANKNAME IS NOT NULL AND CDHIS.MATSBANKNAME IS NULL) THEN
      IF (MACCT.MATSBANKNAME IS NOT NULL AND CDHIS.MATSBANKNAME IS NOT NULL AND
         MACCT.MATSBANKNAME = CDHIS.MATSBANKNAME) OR
         (MACCT.MATSBANKNAME IS NULL AND CDHIS.MATSBANKNAME IS NULL) THEN
        UPDATE METERACCOUNT
           SET MATSBANKNAME = P_CD.MATSBANKNAME
         WHERE MAMID = P_CD.MIID;
        IF SQL%ROWCOUNT <= 0 OR SQL%ROWCOUNT IS NULL THEN
          INSERT INTO METERACCOUNT
            (MAMID,
             MANO,
             MANONAME,
             MABANKID,
             MAACCOUNTNO,
             MAACCOUNTNAME,
             MATSBANKID,
             MATSBANKNAME,
             MAIFXEZF,
             MAREGDATE,
             MAMICODE)
          VALUES
            (P_CD.MIID,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             P_CD.MATSBANKNAME,
             NULL,
             CURRENTDATE,
             P_CD.MICODE);
        END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '凭证银行已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --小额支付（托）
    IF (P_CD.MAIFXEZF IS NOT NULL AND CDHIS.MAIFXEZF IS NOT NULL AND
       P_CD.MAIFXEZF <> CDHIS.MAIFXEZF) OR
       (P_CD.MAIFXEZF IS NULL AND CDHIS.MAIFXEZF IS NOT NULL) OR
       (P_CD.MAIFXEZF IS NOT NULL AND CDHIS.MAIFXEZF IS NULL) THEN
      IF (MACCT.MAIFXEZF IS NOT NULL AND CDHIS.MAIFXEZF IS NOT NULL AND
         MACCT.MAIFXEZF = CDHIS.MAIFXEZF) OR
         (MACCT.MAIFXEZF IS NULL AND CDHIS.MAIFXEZF IS NULL) THEN
        UPDATE METERACCOUNT
           SET MAIFXEZF = P_CD.MAIFXEZF
         WHERE MAMID = P_CD.MIID;
        IF SQL%ROWCOUNT <= 0 OR SQL%ROWCOUNT IS NULL THEN
          INSERT INTO METERACCOUNT
            (MAMID,
             MANO,
             MANONAME,
             MABANKID,
             MAACCOUNTNO,
             MAACCOUNTNAME,
             MATSBANKID,
             MATSBANKNAME,
             MAIFXEZF,
             MAREGDATE,
             MAMICODE)
          VALUES
            (P_CD.MIID,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             P_CD.MAIFXEZF,
             CURRENTDATE,
             P_CD.MICODE);
        END IF;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '小额支付标志已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
    --是否磁控阀
    IF (P_CD.MIIFCKF IS NOT NULL AND CDHIS.MIIFCKF IS NOT NULL AND
       P_CD.MIIFCKF <> CDHIS.MIIFCKF) OR
       (P_CD.MIIFCKF IS NULL AND CDHIS.MIIFCKF IS NOT NULL) OR
       (P_CD.MIIFCKF IS NOT NULL AND CDHIS.MIIFCKF IS NULL) THEN
      IF (METER.MIIFCKF IS NOT NULL AND CDHIS.MIIFCKF IS NOT NULL AND
         METER.MIIFCKF = CDHIS.MIIFCKF) OR
         (METER.MIIFCKF IS NULL AND CDHIS.MIIFCKF IS NULL) THEN
        UPDATE METERINFO SET MIIFCKF = P_CD.MIIFCKF WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '是否磁控阀已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --GPS地址
    IF (P_CD.MIGPS IS NOT NULL AND CDHIS.MIGPS IS NOT NULL AND
       P_CD.MIGPS <> CDHIS.MIGPS) OR
       (P_CD.MIGPS IS NULL AND CDHIS.MIGPS IS NOT NULL) OR
       (P_CD.MIGPS IS NOT NULL AND CDHIS.MIGPS IS NULL) THEN
      IF (METER.MIGPS IS NOT NULL AND CDHIS.MIGPS IS NOT NULL AND
         METER.MIGPS = CDHIS.MIGPS) OR
         (METER.MIGPS IS NULL AND CDHIS.MIGPS IS NULL) THEN
        UPDATE METERINFO SET MIGPS = P_CD.MIGPS WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                'GPS地址已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --铅封号
    IF (P_CD.MIQFH IS NOT NULL AND CDHIS.MIQFH IS NOT NULL AND
       P_CD.MIQFH <> CDHIS.MIQFH) OR
       (P_CD.MIQFH IS NULL AND CDHIS.MIQFH IS NOT NULL) OR
       (P_CD.MIQFH IS NOT NULL AND CDHIS.MIQFH IS NULL) THEN
      IF (METER.MIQFH IS NOT NULL AND CDHIS.MIQFH IS NOT NULL AND
         METER.MIQFH = CDHIS.MIQFH) OR
         (METER.MIQFH IS NULL AND CDHIS.MIQFH IS NULL) THEN
        UPDATE METERINFO SET MIQFH = P_CD.MIQFH WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '铅封号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --消防水价
    IF (P_CD.MIBOX IS NOT NULL AND CDHIS.MIBOX IS NOT NULL AND
       P_CD.MIBOX <> CDHIS.MIBOX) OR
       (P_CD.MIBOX IS NULL AND CDHIS.MIBOX IS NOT NULL) OR
       (P_CD.MIBOX IS NOT NULL AND CDHIS.MIBOX IS NULL) THEN
      IF (METER.MIBOX IS NOT NULL AND CDHIS.MIBOX IS NOT NULL AND
         METER.MIBOX = CDHIS.MIBOX) OR
         (METER.MIBOX IS NULL AND CDHIS.MIBOX IS NULL) THEN
        UPDATE METERINFO SET MIBOX = P_CD.MIBOX WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '消防水价已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --招牌名称
    IF (P_CD.MINAME2 IS NOT NULL AND CDHIS.MINAME2 IS NOT NULL AND
       P_CD.MINAME2 <> CDHIS.MINAME2) OR
       (P_CD.MINAME2 IS NULL AND CDHIS.MINAME2 IS NOT NULL) OR
       (P_CD.MINAME2 IS NOT NULL AND CDHIS.MINAME2 IS NULL) THEN
      IF (METER.MINAME2 IS NOT NULL AND CDHIS.MINAME2 IS NOT NULL AND
         METER.MINAME2 = CDHIS.MINAME2) OR
         (METER.MINAME2 IS NULL AND CDHIS.MINAME2 IS NULL) THEN
        UPDATE METERINFO SET MINAME2 = P_CD.MINAME2 WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '招牌名称已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --票据名称
    IF (P_CD.MINAME IS NOT NULL AND CDHIS.MINAME IS NOT NULL AND
       P_CD.MINAME <> CDHIS.MINAME) OR
       (P_CD.MINAME IS NULL AND CDHIS.MINAME IS NOT NULL) OR
       (P_CD.MINAME IS NOT NULL AND CDHIS.MINAME IS NULL) THEN
      IF (METER.MINAME IS NOT NULL AND CDHIS.MINAME IS NOT NULL AND
         METER.MINAME = CDHIS.MINAME) OR
         (METER.MINAME IS NULL AND CDHIS.MINAME IS NULL) THEN
        UPDATE METERINFO SET MINAME = P_CD.MINAME WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '票据名称已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --表身号
    IF (P_CD.MDNO IS NOT NULL AND CDHIS.MDNO IS NOT NULL AND
       P_CD.MDNO <> CDHIS.MDNO) OR
       (P_CD.MDNO IS NULL AND CDHIS.MDNO IS NOT NULL) OR
       (P_CD.MDNO IS NOT NULL AND CDHIS.MDNO IS NULL) THEN
      IF (MDOC.MDNO IS NOT NULL AND CDHIS.MDNO IS NOT NULL AND
         MDOC.MDNO = CDHIS.MDNO) OR
         (MDOC.MDNO IS NULL AND CDHIS.MDNO IS NULL) THEN
      
        UPDATE METERDOC SET MDNO = P_CD.MDNO WHERE MDMID = P_CD.MDMID;
        
                
    --by wlj  20170328 水表档案变更 换下来的表身码作废新表打相应标志
     UPDATE ST_METERINFO_STORE
       SET STATUS = '3',       --表身码作废
           MIID = P_CD.MDMID, 
           STATUSDATE = SYSDATE
     WHERE BSM = P_CD.MDNO;  
     UPDATE ST_METERINFO_STORE
       SET STATUS = '6',       --表身码作废
           MIID = P_CD.MDMID, 
           STATUSDATE = SYSDATE
     WHERE BSM = CDHIS.MDNO;  
        
        
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MDMID || ']的' ||
                                '表身号已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --是否考核表
    IF (P_CD.MIIFCHK IS NOT NULL AND CDHIS.MIIFCHK IS NOT NULL AND
       P_CD.MIIFCHK <> CDHIS.MIIFCHK) OR
       (P_CD.MIIFCHK IS NULL AND CDHIS.MIIFCHK IS NOT NULL) OR
       (P_CD.MIIFCHK IS NOT NULL AND CDHIS.MIIFCHK IS NULL) THEN
      IF (METER.MIIFCHK IS NOT NULL AND CDHIS.MIIFCHK IS NOT NULL AND
         METER.MIIFCHK = CDHIS.MIIFCHK) OR
         (METER.MIIFCHK IS NULL AND CDHIS.MIIFCHK IS NULL) THEN
        UPDATE METERINFO SET MIIFCHK = P_CD.MIIFCHK WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '是否考核表已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --是否节水
    IF (P_CD.MIIFWATCH IS NOT NULL AND CDHIS.MIIFWATCH IS NOT NULL AND
       P_CD.MIIFWATCH <> CDHIS.MIIFWATCH) OR
       (P_CD.MIIFWATCH IS NULL AND CDHIS.MIIFWATCH IS NOT NULL) OR
       (P_CD.MIIFWATCH IS NOT NULL AND CDHIS.MIIFWATCH IS NULL) THEN
      IF (METER.MIIFWATCH IS NOT NULL AND CDHIS.MIIFWATCH IS NOT NULL AND
         METER.MIIFWATCH = CDHIS.MIIFWATCH) OR
         (METER.MIIFWATCH IS NULL AND CDHIS.MIIFWATCH IS NULL) THEN
        UPDATE METERINFO
           SET MIIFWATCH = P_CD.MIIFWATCH
         WHERE MIID = P_CD.MIID;
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '是否节水已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
    --水表状态
    IF (P_CD.MISTATUS IS NOT NULL AND CDHIS.MISTATUS IS NOT NULL AND
       P_CD.MISTATUS <> CDHIS.MISTATUS) OR
       (P_CD.MISTATUS IS NULL AND CDHIS.MISTATUS IS NOT NULL) OR
       (P_CD.MISTATUS IS NOT NULL AND CDHIS.MISTATUS IS NULL) THEN
      IF (METER.MISTATUS IS NOT NULL AND CDHIS.MISTATUS IS NOT NULL AND
         METER.MISTATUS = CDHIS.MISTATUS) OR
         (METER.MISTATUS IS NULL AND CDHIS.MISTATUS IS NULL) THEN
        UPDATE METERINFO
           SET MISTATUS = P_CD.MISTATUS
         WHERE MIID = P_CD.MIID;
      
        --同步用户状态
        IF P_CD.MISTATUS = '1' OR P_CD.MISTATUS = '2' OR
           P_CD.MISTATUS = '7' THEN
          UPDATE CUSTINFO
             SET CISTATUS = P_CD.MISTATUS
           WHERE CICODE = P_CD.MIID;
        END IF;
        
        --故障表保存故障原因
        IF P_CD.MISTATUS = '29' OR P_CD.MISTATUS = '30' THEN
          UPDATE METERINFO
             SET MIFACE2 = P_CD.MIFACE2
           WHERE MIID = P_CD.MIID;
        END IF;
      
      ELSE
        ROLLBACK;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '变更单体第[' || P_CD.CCDROWNO || ']行,水表号:[' ||
                                P_CD.MIID || ']的' ||
                                '水表状态已经发生变化不能通过变更审核,请删除此行记录后再进行审核!');
      END IF;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --插入水表日志并提交统计
  PROCEDURE METERLOG(P_MSL    IN OUT METER_STATIC_LOG%ROWTYPE,
                     P_COMMIT IN VARCHAR2) IS
  BEGIN
    --过滤掉其中无任何维度值发生变化的记录后提交统计
    IF P_MSL.事务代码 IN ('F') OR --销户
       P_MSL.事务代码 IN ('R', '0', '8') OR --立户
       NOT (NVL(P_MSL.原区域, 'N/A') = NVL(P_MSL.新区域, 'N/A') AND
        NVL(P_MSL.原营销公司, 'N/A') = NVL(P_MSL.新营销公司, 'N/A') AND
        NVL(P_MSL.原抄表方式, 'N/A') = NVL(P_MSL.新抄表方式, 'N/A') AND
        NVL(TO_CHAR(P_MSL.原水表口径), 'N/A') =
        NVL(TO_CHAR(P_MSL.新水表口径), 'N/A') AND
        NVL(P_MSL.原行业分类, 'N/A') = NVL(P_MSL.新行业分类, 'N/A') AND
        NVL(P_MSL.原水表类型, 'N/A') = NVL(P_MSL.新水表类型, 'N/A') AND
        NVL(P_MSL.原考核表标志, 'N/A') = NVL(P_MSL.新考核表标志, 'N/A') AND
        NVL(P_MSL.原收费方式, 'N/A') = NVL(P_MSL.新收费方式, 'N/A') AND
        NVL(P_MSL.原水表类别, 'N/A') = NVL(P_MSL.新水表类别, 'N/A') AND
        NVL(P_MSL.原用水大类, 'N/A') = NVL(P_MSL.新用水大类, 'N/A') AND
        NVL(P_MSL.原用水中类, 'N/A') = NVL(P_MSL.新用水中类, 'N/A') AND
        NVL(P_MSL.原用水小类, 'N/A') = NVL(P_MSL.新用水小类, 'N/A') AND
        NVL(P_MSL.原表位, 'N/A') = NVL(P_MSL.新表位, 'N/A') AND
        NVL(P_MSL.原表册, 'N/A') = NVL(P_MSL.新表册, 'N/A') AND
        NVL(TO_CHAR(P_MSL.原立户日期, 'yyyymmdd'), 'N/A') =
        NVL(TO_CHAR(P_MSL.新立户日期, 'yyyymmdd'), 'N/A')) THEN
      SELECT SEQ_METER_STATIC_LOG.NEXTVAL INTO P_MSL.MSLID FROM DUAL;
      P_MSL.统计日期 := TRUNC(SYSDATE);
      INSERT INTO METER_STATIC_LOG VALUES P_MSL;
      CMDPUSH('pg_custmeter.submit$meterlog', P_MSL.MSLID);
    END IF;
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  /*-----------------------------------------------------------------------
  --name:f_1day
  --note:生成每天的水表统计数字,每天JOB执行
  --Input: None
  -----------------------------------------------------------------------*/
  PROCEDURE METERSTATICREFRESH(P_SDATE IN VARCHAR2, P_EDATE IN VARCHAR2) AS
    CURSOR C_M1(V_DATE IN DATE) IS
      SELECT MIID,
             MICID,
             MISMFID,
             MIRTID,
             MIPFID,
             MITYPE,
             MIIFCHK,
             MILB,
             MIUNINSDATE,
             MINEWDATE
        FROM METERINFO
       WHERE MINEWDATE >= V_DATE
         AND MINEWDATE < V_DATE + 1;
    CURSOR C_M7(V_DATE IN DATE) IS
      SELECT MIID,
             MICID,
             MISMFID,
             MIRTID,
             MIPFID,
             MITYPE,
             MIIFCHK,
             MILB,
             MIUNINSDATE,
             MINEWDATE
        FROM METERINFO
       WHERE MISTATUS = '7'
         AND MIUNINSDATE >= V_DATE
         AND MIUNINSDATE < V_DATE + 1;
  
    MI    METERINFO%ROWTYPE;
    VDATE DATE;
  BEGIN
    IF TO_DATE(P_SDATE, 'yyyy.mm.dd') > TO_DATE(P_EDATE, 'yyyy.mm.dd') THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '日期参数定义错误: ' || SQLERRM);
    END IF;
  
    DELETE METER_STATIC
     WHERE 统计日期 >= TO_DATE(P_SDATE, 'yyyy.mm.dd')
       AND 统计日期 <= TO_DATE(P_EDATE, 'yyyy.mm.dd');
    DELETE METERINFOSTATIC
     WHERE MISTATICDATE >= TO_DATE(P_SDATE, 'yyyy.mm.dd')
       AND MISTATICDATE <= TO_DATE(P_EDATE, 'yyyy.mm.dd');
    DELETE METERDOCSTATIC
     WHERE MDSTATICDATE >= TO_DATE(P_SDATE, 'yyyy.mm.dd')
       AND MDSTATICDATE <= TO_DATE(P_EDATE, 'yyyy.mm.dd');
    DELETE CUSTINFOSTATIC
     WHERE CISTATICDATE >= TO_DATE(P_SDATE, 'yyyy.mm.dd')
       AND CISTATICDATE <= TO_DATE(P_EDATE, 'yyyy.mm.dd');
  
    VDATE := TO_DATE(P_SDATE, 'yyyy.mm.dd');
    WHILE VDATE <= TO_DATE(P_EDATE, 'yyyy.mm.dd') LOOP
      INITMETER_STATIC(VDATE - 1, VDATE);
      OPEN C_M1(VDATE);
      LOOP
        FETCH C_M1
          INTO MI.MIID,
               MI.MICID,
               MI.MISMFID,
               MI.MIRTID,
               MI.MIPFID,
               MI.MITYPE,
               MI.MIIFCHK,
               MI.MILB,
               MI.MIUNINSDATE,
               MI.MINEWDATE;
        EXIT WHEN C_M1%NOTFOUND OR C_M1%NOTFOUND IS NULL;
        SUM$DAY$METER(MI, '1', 'N');
      END LOOP;
      CLOSE C_M1;
      OPEN C_M7(VDATE);
      LOOP
        FETCH C_M7
          INTO MI.MIID,
               MI.MICID,
               MI.MISMFID,
               MI.MIRTID,
               MI.MIPFID,
               MI.MITYPE,
               MI.MIIFCHK,
               MI.MILB,
               MI.MIUNINSDATE,
               MI.MINEWDATE;
        EXIT WHEN C_M7%NOTFOUND OR C_M7%NOTFOUND IS NULL;
        SUM$DAY$METER(MI, '7', 'N');
      END LOOP;
      CLOSE C_M7;
      VDATE := VDATE + 1;
      COMMIT;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_M1%ISOPEN THEN
        CLOSE C_M1;
      END IF;
      IF C_M7%ISOPEN THEN
        CLOSE C_M7;
      END IF;
      ROLLBACK;
      RAISE;
  END;

  --水表日结
  PROCEDURE SUM$DAY$METER(P_MIID   VARCHAR2,
                          P_TYPE   VARCHAR2,
                          P_COMMIT VARCHAR2) AS
    MI METERINFO%ROWTYPE;
  BEGIN
    SELECT * INTO MI FROM METERINFO WHERE MIID = P_MIID;
    SUM$DAY$METER(MI, P_TYPE, P_COMMIT);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  --水表日结
  PROCEDURE SUM$DAY$METER(P_MI     IN METERINFO%ROWTYPE,
                          P_TYPE   VARCHAR2,
                          P_COMMIT VARCHAR2) AS
    MD METERDOC%ROWTYPE;
    MS METER_STATIC%ROWTYPE;
  
    STATIC_ID   VARCHAR2(10);
    STATIC_FLAG CHAR(1); --立销户标志 0立户，1销户
  
  BEGIN
    SELECT MDCALIBER
      INTO MD.MDCALIBER
      FROM METERDOC T1
     WHERE T1.MDMID = P_MI.MIID;
  
    --meterinfo取值
    MS.区域       := NULL; --m.MISAFID;
    MS.营销公司   := P_MI.MISMFID;
    MS.抄表方式   := P_MI.MIRTID;
    MS.水表口径   := MD.MDCALIBER;
    MS.行业分类   := NULL; --m.MISTID;
    MS.用水小类   := P_MI.MIPFID;
    MS.用水中类   := SUBSTR(P_MI.MIPFID, 0, 4);
    MS.用水大类   := SUBSTR(P_MI.MIPFID, 0, 2);
    MS.水表类型   := P_MI.MITYPE;
    MS.考核表标志 := P_MI.MIIFCHK;
    MS.收费方式   := NULL; --m.MICHARGETYPE;
    MS.水表类别   := P_MI.MILB;
    MS.上期数量   := 0;
    MS.表位       := P_MI.MISIDE;
  
    IF P_TYPE = '7' THEN
      MS.统计日期 := TRUNC(P_MI.MIUNINSDATE);
      MS.新增水表 := 0;
      MS.销户水表 := 1;
      STATIC_FLAG := 1;
    END IF;
    IF P_TYPE = '1' THEN
      MS.统计日期 := TRUNC(P_MI.MINEWDATE);
      MS.新增水表 := 1;
      MS.销户水表 := 0;
      STATIC_FLAG := 0;
    END IF;
    MS.当前数量 := MS.新增水表 - MS.销户水表;
    --判断是否有记录（有：update，没有：insert）
    --日结存
    UPDATE METER_STATIC
       SET 新增水表 = 新增水表 + MS.新增水表,
           销户水表 = 销户水表 + MS.销户水表,
           当前数量 = 当前数量 + MS.当前数量
     WHERE 统计日期 = MS.统计日期
       AND (区域 = MS.区域 OR (区域 IS NULL AND MS.区域 IS NULL))
       AND (营销公司 = MS.营销公司 OR (营销公司 IS NULL AND MS.营销公司 IS NULL))
       AND (抄表方式 = MS.抄表方式 OR (抄表方式 IS NULL AND MS.抄表方式 IS NULL))
       AND (水表口径 = MS.水表口径 OR (水表口径 IS NULL AND MS.水表口径 IS NULL))
       AND (行业分类 = MS.行业分类 OR (行业分类 IS NULL AND MS.行业分类 IS NULL))
       AND (用水小类 = MS.用水小类 OR (用水小类 IS NULL AND MS.用水小类 IS NULL))
       AND (用水中类 = MS.用水中类 OR (用水中类 IS NULL AND MS.用水中类 IS NULL))
       AND (用水大类 = MS.用水大类 OR (用水大类 IS NULL AND MS.用水大类 IS NULL))
       AND (水表类型 = MS.水表类型 OR (水表类型 IS NULL AND MS.水表类型 IS NULL))
       AND (考核表标志 = MS.考核表标志 OR (考核表标志 IS NULL AND MS.考核表标志 IS NULL))
       AND (收费方式 = MS.收费方式 OR (收费方式 IS NULL AND MS.收费方式 IS NULL))
       AND (水表类别 = MS.水表类别 OR (水表类别 IS NULL AND MS.水表类别 IS NULL))
       AND (表位 = MS.表位 OR (表位 IS NULL AND MS.表位 IS NULL));
  
    IF SQL%ROWCOUNT <= 0 OR SQL%ROWCOUNT IS NULL THEN
      SELECT TRIM(TO_CHAR(SEQ_METER_STATIC.NEXTVAL, '0000000000'))
        INTO MS.ID
        FROM DUAL;
      INSERT INTO METER_STATIC VALUES MS;
    END IF;
  
    SELECT LPAD(SEQ_METERINFOSTATIC.NEXTVAL, 10, '0')
      INTO STATIC_ID
      FROM DUAL;
  
    INSERT INTO METERINFOSTATIC
      SELECT MS.统计日期,
             MICID,
             MIID,
             MIADR,
             MISAFID,
             MICODE,
             MISMFID,
             MIPRMON,
             MIRMON,
             MIBFID,
             MIRORDER,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRTID,
             MIIFMP,
             MIIFSP,
             MISTID,
             MIPFID,
             MISTATUS,
             MISTATUSDATE,
             MISTATUSTRANS,
             MIFACE,
             MIRPID,
             MISIDE,
             MIPOSITION,
             MIINSCODE,
             MIINSDATE,
             MIINSPER,
             MIREINSCODE,
             MIREINSDATE,
             MIREINSPER,
             MITYPE,
             MIRCODE,
             MIRECDATE,
             MIRECSL,
             MIIFCHARGE,
             MIIFSL,
             MIIFCHK,
             MIIFWATCH,
             MIICNO,
             MIMEMO,
             MIPRIID,
             MIPRIFLAG,
             MIUSENUM,
             MICHARGETYPE,
             MISAVING,
             MILB,
             MINEWFLAG,
             MICPER,
             MIIFTAX,
             MITAXNO,
             MIUNINSCODE,
             MIUNINSDATE,
             MIUNINSPER,
             MIFACE2,
             MIFACE3,
             MIFACE4,
             MIRCODECHAR,
             MIIFCKF,
             MIGPS,
             MIQFH,
             MIBOX,
             MIJFKROW,
             MINAME,
             MINAME2,
             MISEQNO,
             MINEWDATE,
             STATIC_ID,
             STATIC_FLAG
        FROM METERINFO
       WHERE MIID = P_MI.MIID;
  
    INSERT INTO METERDOCSTATIC
      SELECT MS.统计日期,
             MDMID,
             MDID,
             MDNO,
             MDCALIBER,
             MDBRAND,
             MDMODEL,
             MDSTATUS,
             MDSTATUSDATE,
             MDCYCCHKDATE,
             MDSTOCKDATE,
             MDSTORE,
             STATIC_ID,
             STATIC_FLAG
        FROM METERDOC
       WHERE MDMID = P_MI.MIID;
  
    INSERT INTO CUSTINFOSTATIC
      SELECT MS.统计日期,
             CIID,
             CICODE,
             CICONID,
             CISMFID,
             CIPID,
             CICLASS,
             CIFLAG,
             CINAME,
             CINAME2,
             CIADR,
             CISTATUS,
             CISTATUSDATE,
             CISTATUSTRANS,
             CINEWDATE,
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
             CIPROJNO,
             CIFILENO,
             CIMEMO,
             CIDEPTID,
             STATIC_ID,
             STATIC_FLAG
        FROM CUSTINFO
       WHERE CIID = P_MI.MICID;
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF P_COMMIT = 'Y' THEN
        ROLLBACK;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --初始化
  PROCEDURE INITMETER_STATIC(P_SCRDATE IN DATE, P_DESDATE IN DATE) IS
  BEGIN
    IF P_SCRDATE >= P_DESDATE THEN
      RETURN;
    END IF;
    INSERT INTO METER_STATIC
      SELECT TRIM(TO_CHAR(SEQ_METER_STATIC.NEXTVAL, '0000000000')),
             区域,
             营销公司,
             抄表方式,
             水表口径,
             行业分类,
             
             水表类型,
             考核表标志,
             收费方式,
             水表类别,
             当前数量,
             当前数量,
             0,
             0,
             P_DESDATE,
             用水大类,
             用水中类,
             用水小类,
             表位
        FROM METER_STATIC
      
       WHERE 统计日期 = P_SCRDATE;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END INITMETER_STATIC;

  PROCEDURE sp_正式用水管理(P_TYPE   IN VARCHAR2, --单据类别
                      P_billNO IN VARCHAR2, --单据编号
                      P_PER    IN VARCHAR2, --审批人
                      P_COMMIT IN VARCHAR2) --是否提交
   IS
    CURSOR C_ZS IS
      SELECT * FROM ZSYSDT WHERE CRHNO = P_billNO;
  
    CURSOR C_DT IS
      SELECT * FROM ZSYSXXGLDT WHERE CMRDNO = P_billNO;
  
    ZS    ZSYSDT%ROWTYPE;
    DT    ZSYSXXGLDT%ROWTYPE;
    CI    CUSTINFO%ROWTYPE;
    MI    METERINFO%ROWTYPE;
    MD    METERDOC%ROWTYPE;
    MA    METERACCOUNT%ROWTYPE;
    V_ROW NUMBER(10);
    FLAGY NUMBER(10);
  
  BEGIN
    --检查单据是否存在
    BEGIN
      SELECT * INTO ZS FROM ZSYSDT WHERE CRHNO = P_billNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '立户单不存在!');
    END;
    IF ZS.CRHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF ZS.CRHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
  
    --检查立户单体是否存在水表
    SELECT COUNT(*) INTO FLAGY FROM ZSYSXXGLDT WHERE CMRDNO = P_billNO;
    IF FLAGY = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要立户的水表!');
    END IF;
  
    OPEN C_DT;
    LOOP
      FETCH C_DT
        INTO DT;
      EXIT WHEN C_DT%NOTFOUND OR C_DT%NOTFOUND IS NULL;
       --20140314 修改为临时用水转正式用水只修改水表状态
      update meterinfo set mistatus = '31' where miid=DT.LSXYID;
    
     /* --增加用户--------------------------
      --CI.CIID          := fgetsequence('CUSTINFO');--
      --CI.CICODE        := nvl(cmrd.cicode,fnewcicode(cmrd.cismfid));--
      CI.CICONID := NULL; --
      CI.CISMFID := ZS.CRHSMFID; --
      CI.CIPID   := NULL; --
      --校验上级用户
    
      CI.CICLASS       := 1;
      CI.CIFLAG        := 'Y'; --
      CI.CINAME        := DT.XMNAME; --项目名称
      CI.CINAME2       := DT.XMNAME; --
      CI.CIADR         := DT.JSDD; --
      CI.CISTATUS      := '1'; --
      CI.CISTATUSDATE  := NULL; --
      CI.CISTATUSTRANS := NULL; --
      CI.CINEWDATE     := CURRENTDATE; --
      CI.CIIDENTITYLB  := NULL; --
      CI.CIIDENTITYNO  := NULL; --
      CI.CIMTEL        := DT.contactcell; --
      CI.CITEL1        := NULL; --
      CI.CITEL2        := NULL; --
      CI.CITEL3        := NULL; --
      CI.CICONNECTPER  := DT.CONTACTMAN; --
      CI.CICONNECTTEL  := DT.CONTACTCELL; --
      CI.CIIFINV       := 'N'; --
      CI.CIIFSMS       := 'N'; --
      CI.CIIFZN        := 'N'; --
      CI.CIPROJNO      := DT.ZSYSSQID; --
      CI.CIFILENO      := NULL; --
      CI.CIMEMO        := NULL; --
      CI.CIDEPTID      := ZS.CRHDEPT; --
      ----------------------------
      IF 客户代码是否营业所 = 'Y' THEN
        MI.MIID := NVL(NULL, FNEWMICODE(ZS.CRHSMFID)); --fgetsequence('METERINFO');--
      ELSIF 客户代码是否营业所 = 'N' THEN
      
        \*IF FNEWMICODEAREA(CMRD.MISAFID) IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '编码规则未定义');
        END IF;*\
        MI.MIID := NVL(NULL, FNEWMICODEAREA(NULL));
        --客户代码【哈尔滨需要】前面9位是从序号取，后面一位是前面9位数据相加，取4的膜
      ELSIF 客户代码是否营业所 = 'O' THEN
        MI.MIID := fgetmicode;
      ELSE
        MI.MIID := NVL(NULL, FNEWMICODE('020101')); --fgetsequence('METERINFO');--
      END IF;
      --检查立户信息是否在系统中存在，如果存在提示
      SELECT COUNT(*) INTO V_ROW FROM METERINFO WHERE MIID = MI.MIID;
      IF V_ROW > 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '客户代码:' || MI.MIID || '在系统中已存在！');
      END IF;
      CI.CIID      := MI.MIID;
      MI.MICID     := CI.CIID; --
      MI.MIADR     := CI.CIADR; --
      MI.MINAME    := CI.CINAME; --
      MI.MINAME2   := CI.CINAME; --
      MI.MISAFID   := NULL; --
      MI.MICODE    := MI.MIID; --nvl(cmrd.micode,fnewmicode(cmrd.mismfid));--
      CI.CICODE    := MI.MICODE;
      MI.MISMFID   := ZS.CRHSMFID; --
      MI.MIPRMON   := NULL; --
      MI.MIRMON    := NULL; --
      MI.MIBFID    := NULL; --
      MI.MIRORDER  := NULL; --
      MI.MIPID     := NULL; --
      MI.MINEWDATE := CURRENTDATE;
      MI.MIGPS     := 'N';
      MI.MIQFH     := NULL;
      \*MI.MISAVING      := cmrd.misaving;*\
      --校验上级水表
      \*IF CMRD.MIPID IS NOT NULL THEN
        OPEN C_PMI(CMRD.MIPID);
        FETCH C_PMI
          INTO PMI;
        IF C_PMI%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_CRHNO || '无效的上级水表');
        END IF;
        MI.MICLASS := PMI.MICLASS + 1; --
        CLOSE C_PMI;
      ELSE
        MI.MICLASS := 1; --
      END IF;*\
      MI.MICLASS       := 1;
      MI.MIFLAG        := 'Y'; --
      MI.MIRTID        := NULL; --
      MI.MIIFMP        := 'N'; --
      MI.MIIFSP        := 'N'; --
      MI.MISTID        := NULL; --行业分类需确定是否需要？
      MI.MIPFID        := DT.zspfid; --
      MI.MISTATUS      := '31'; --基建正式用水
      MI.MISTATUSDATE  := NULL; --
      MI.MISTATUSTRANS := NULL; --
      MI.MIRPID        := NULL; --
      MI.MISIDE        := NULL; --
      MI.MIPOSITION    := CI.CIADR; --
      MI.MIINSCODE     := 0; --
      MI.MIINSDATE     := CURRENTDATE; --
      MI.MIINSPER      := NULL; --
      MI.MIREINSCODE   := NULL; --
      MI.MIREINSDATE   := NULL; --
      MI.MIREINSPER    := NULL; --
      MI.MITYPE        := '1'; --
      MI.MIRCODE       := 0; --
      MI.MIRCODECHAR   := '0';
      MI.MIRECDATE     := NULL; --
      MI.MIRECSL       := NULL; --
      MI.MIIFCHARGE    := 'Y'; --
      MI.MIIFSL        := 'Y'; --
      MI.MIIFCHK       := 'N'; --
      MI.MIIFWATCH     := 'N'; --
      MI.MIICNO        := NULL; --
      MI.MIMEMO        := NULL; --
      MI.MIPRIID       := NULL; --
      MI.MIPRIFLAG     := 'N'; --
      MI.MIUSENUM      := 0; --
      MI.MICHARGETYPE  := 'X'; --
      MI.MIIFCKF       := '0'; --
      MI.MISAVING      := 0; --
      MI.MILB          := 'H'; --
      MI.MINEWFLAG     := 'Y'; --
      MI.MICPER        := NULL; --
      MI.MIIFTAX       := 'N'; --
      MI.MITAXNO       := NULL; --
      MI.MIJFKROW      := 0; --
      MI.MIUIID        := NULL; --
      MI.MICOMMUNITY   := NULL; --小区
      MI.MIREMOTENO    := NULL; --远传表号
      MI.MIREMOTEHUBNO := NULL; --远传表HUB号
      MI.MIEMAIL       := NULL; --电子邮件
      MI.MIEMAILFLAG   := NULL; --发账是否发邮件
      MI.MICOLUMN1     := NULL; --备用字段1
      MI.MICOLUMN2     := NULL; --备用字段2
      MI.MICOLUMN3     := NULL; --备用字段3
      MI.MICOLUMN4     := NULL; --备用字段4
      MI.MIFACE        := NULL; --备用字段4
      --MI.MICOLUMN9     := CMRD.MICOLUMN9;
      -- MI.MICOLUMN10    := CMRD.MICOLUMN10;
    
      \*MI.MISAVING      := cmrd.misaving;*\
      MD.MDMID        := MI.MIID; --
      MD.MDID         := MI.MIID; --fgetsequence('METERDOC');--立户即入库新水表表
      MD.MDNO         := NULL; --
      MD.MDCALIBER    := NULL; --
      MD.MDBRAND      := NULL; --
      MD.MDMODEL      := NULL; --
      MD.MDSTATUS     := '1'; --
      MD.MDSTATUSDATE := NULL; --
      MD.MDSTOCKDATE  := CURRENTDATE;
      MD.MDSTORE      := MI.MIID; --安装后位置为水表安装地址
    
      MA.MAMID         := MI.MIID; --
      MA.MANO          := NULL; --
      MA.MANONAME      := NULL; --
      MA.MABANKID      := NULL; --
      MA.MAACCOUNTNO   := NULL; --
      MA.MAACCOUNTNAME := NULL; --
      MA.MATSBANKID    := NULL; --
      MA.MATSBANKNAME  := NULL; --
      MA.MAIFXEZF      := NULL; --
    
      ----------------------------
      INSERT INTO CUSTINFO VALUES CI;
      INSERT INTO METERINFO VALUES MI;
      INSERT INTO METERDOC VALUES MD;
      INSERT INTO METERACCOUNT VALUES MA;
    
      --库存管理开关
      \*IF FSYSPARA('sys4') = 'Y' THEN
        UPDATE ST_METERINFO_STORE
           SET STATUS = '1', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = CMRD.MDNO;
      END IF;*\*/
      
    END LOOP;
    CLOSE C_DT;
  
    UPDATE ZSYSDT
       SET CRHSHDATE = SYSDATE,/*crhshper =crhcreper  */ CRHSHPER = P_PER, CRHSHFLAG = 'Y'
     WHERE CRHNO = P_billNO;
    --人工立户缴预存  暂不支持
    /*open c_cmrd1;
    loop
      fetch c_cmrd1 into hd;
      exit when c_cmrd1%notfound or c_cmrd1%notfound is null;
    \*pa_pay.possaving(mi.mismfid,hd.cchcreper,mi.miid,cmrd.misaving,'XJ','DE',mi.mismfid);*\
    
    sp_savetrans(mi.mismfid,hd.crhcreper,mi.miid,cmrd.misaving,'S','XJ','DE',fgetsequence('ENTRUSTLOG'),mi.mismfid,v_i);
    end loop;
    close c_cmrd1;*/
    --更新流程
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_billNO);
  
    --提交标志
  
    if P_COMMIT = 'Y' then
      commit;
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_ZS%ISOPEN THEN
        CLOSE C_ZS;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END sp_正式用水管理;

  PROCEDURE sp_临时用水管理(P_TYPE   IN VARCHAR2, --单据类别
                      P_billNO IN VARCHAR2, --单据编号
                      P_PER    IN VARCHAR2, --审批人
                      P_COMMIT IN VARCHAR2) --是否提交
   IS
    CURSOR C_LS IS
      SELECT * FROM LSYSDT WHERE CRHNO = P_billNO;
  
    LS LSYSDT%ROWTYPE;
  BEGIN
    --检查单据是否存在
    OPEN C_LS;
    FETCH C_LS
      INTO LS;
    IF C_LS%NOTFOUND OR C_LS%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据不存在' || P_billNO);
    END IF;
    CLOSE C_LS;
    --更新审核标志
    UPDATE LSYSDT
       SET /*crhshper =crhcreper */ crhshper = P_PER, crhshdate = SYSDATE, crhshflag = 'Y'
     WHERE CRHNO = LS.CRHNO;
    --提交标志
  
    if P_COMMIT = 'Y' then
      commit;
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_LS%ISOPEN THEN
        CLOSE C_LS;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END sp_临时用水管理;

  PROCEDURE sp_污水超标管理(P_TYPE   IN VARCHAR2, --单据类别
                      P_billNO IN VARCHAR2, --单据编号
                      P_PER    IN VARCHAR2, --审批人
                      P_COMMIT IN VARCHAR2) --是否提交
   IS
    --单头
    CURSOR C_TH IS
      SELECT * FROM TDSJHD WHERE CRHNO = P_billNO;
  
    --单体
    CURSOR C_TD(C_CMRDNO IN VARCHAR2) IS
      SELECT * FROM TDSJDT WHERE CMRDNO = C_CMRDNO;
  
    TH      TDSJHD%ROWTYPE; --单头对象
    TD      TDSJDT%ROWTYPE; --单体对象
    PAL     PRICEADJUSTLIST%ROWTYPE; --策略单价
    V_PALID VARCHAR2(20);
  BEGIN
    --检查单据是否存在
    OPEN C_TH;
    FETCH C_TH
      INTO TH;
    IF C_TH%NOTFOUND OR C_TH%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据不存在' || P_billNO);
    END IF;
    CLOSE C_TH;
  
    OPEN C_TD(TH.CRHNO);
    LOOP
      FETCH C_TD
        INTO TD;
      EXIT WHEN C_TD%NOTFOUND OR C_TD%NOTFOUND IS NULL;
      if  TD.CMTYPE='Y' THEN  --增加取消污水标志记录，并获得以前调整的记录
          insert into PRICEADJUSTLIST_his select * from PRICEADJUSTLIST WHERE PALMID = TH.MIID;
          delete PRICEADJUSTLIST WHERE PALMID = TH.MIID;
      else
          DELETE PRICEADJUSTLIST WHERE PALMID = TH.MIID; 
          SELECT TO_CHAR(SEQ_PALID.NEXTVAL, '0000000000')
          INTO V_PALID
          FROM DUAL;
          PAL.PALID        := TRIM(V_PALID); --流水号
          PAL.PALTACTIC    := '09'; --策略
          PAL.PALMETHOD    := '01'; --调整方法
          PAL.PALSMFID     := TH.CRHSMFID; --营销公司
          PAL.PALCID       := TH.CIID; --用户编号
          PAL.PALMID       := TH.MIID; --水表编号
          PAL.PALPIID      := '02'; --费用项目
          PAL.PALPFID      := TD.PMDPFIDOLD; --费率编码
          PAL.PALCALIBER   := NULL; --新水价
          PAL.PALPRICE     := NULL; --例外单价
          PAL.PALWAY       := '1'; --调整方向(+/-)
          PAL.PALVALUE     := TD.CMNEWVALUE; --调整值
          PAL.PALSTARTMON  := TO_CHAR(TH.CRSDATE, 'YYYY.MM'); --开始月份
          PAL.PALENDMON    := TO_CHAR(TH.CREDATE, 'YYYY.MM'); --结束月份
          PAL.PALSTATUS    := 'Y'; --有效状态
          PAL.PALRLID      := NULL; --最近生效应收记录
          PAL.PALINITVALUE := NULL; --调整值初值
          PAL.PALPER       := P_PER; --调整人员
          PAL.PALDATE      := SYSDATE; --调整日期
          PAL.PALMONTHSTR  := TH.CRMONVALUE; --周期月份串(1、周期月分【以年为单】如果：1/3/5/7/9，2、指定年月分串 如 2013.04/2013.08)
          INSERT INTO PRICEADJUSTLIST VALUES PAL;
        END IF;
    END LOOP;
    CLOSE C_TD;
  
    --更新审核标志
    UPDATE TDSJHD
       SET /*crhshper=crhcreper*/  crhshper = P_PER, crhshdate = SYSDATE, crhshflag = 'Y'
     WHERE CRHNO = TH.CRHNO;
     
      --更新流程
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_billNO);
     
    --提交标志
    if P_COMMIT = 'Y' then
      commit;
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_TH%ISOPEN THEN
        CLOSE C_TH;
      END IF;
      IF C_TD%ISOPEN THEN
        CLOSE C_TD;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END sp_污水超标管理;
  
  
  PROCEDURE sp_特惠户管理(P_TYPE   IN VARCHAR2, --单据类别
                      P_billNO IN VARCHAR2, --单据编号
                      P_PER    IN VARCHAR2, --审批人
                      P_COMMIT IN VARCHAR2) --是否提交
   IS
    --单头
    CURSOR C_TH IS
      SELECT * FROM TDSJHD WHERE CRHNO = P_billNO;
  
    --单体
    CURSOR C_TD(C_CMRDNO IN VARCHAR2) IS
      SELECT * FROM TDSJDT WHERE CMRDNO = C_CMRDNO;
  
    TH      TDSJHD%ROWTYPE; --单头对象
    TD      TDSJDT%ROWTYPE; --单体对象
    PAL     PRICEADJUSTLIST%ROWTYPE; --策略单价
    V_PALID VARCHAR2(20);
  BEGIN
    --检查单据是否存在
    OPEN C_TH;
    FETCH C_TH
      INTO TH;
    IF C_TH%NOTFOUND OR C_TH%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据不存在' || P_billNO);
    END IF;
    CLOSE C_TH;
  
    OPEN C_TD(TH.CRHNO);
    LOOP
      FETCH C_TD
        INTO TD;
      EXIT WHEN C_TD%NOTFOUND OR C_TD%NOTFOUND IS NULL;
      DELETE PRICEADJUSTLIST WHERE PALMID = TH.MIID;
      SELECT TO_CHAR(SEQ_PALID.NEXTVAL, '0000000000')
        INTO V_PALID
        FROM DUAL;
      /*
      *【哈尔滨】特惠户管理功能只提供减免水量功能
      */
      PAL.PALID        := TRIM(V_PALID); --流水号
      PAL.PALTACTIC    := '02'; --策略（02=仅按水表，07=按水表+价格类别，09=按水表+价格类别+费用项目） 
      PAL.PALMETHOD    :=TD.PAMID; --调整方法（02=固定水量调整,03=比例水量调整）
      PAL.PALSMFID     := TH.CRHSMFID; --营销公司
      PAL.PALCID       := TH.CIID; --用户编号
      PAL.PALMID       := TH.MIID; --水表编号
      PAL.PALPIID      := NULL; --费用项目
      PAL.PALPFID      := TD.PMDPFIDOLD; --费率编码
      PAL.PALCALIBER   := NULL; --新水价
      PAL.PALPRICE     := NULL; --例外单价
      PAL.PALWAY       := '-1'; --调整方向(+/-)
      PAL.PALVALUE     := TD.CMNEWVALUE; --调整值
      PAL.PALSTARTMON  := TO_CHAR(TH.CRSDATE, 'YYYY.MM'); --开始月份
      PAL.PALENDMON    := TO_CHAR(TH.CREDATE, 'YYYY.MM'); --结束月份
      PAL.PALSTATUS    := 'Y'; --有效状态
      PAL.PALRLID      := NULL; --最近生效应收记录
      PAL.PALINITVALUE := NULL; --调整值初值
      PAL.PALPER       := P_PER; --调整人员
      PAL.PALDATE      := SYSDATE; --调整日期
      PAL.PALMONTHSTR  := TH.CRMONVALUE; --周期月份串(1、周期月分【以年为单】如果：1/3/5/7/9，2、指定年月分串 如 2013.04/2013.08)
      INSERT INTO PRICEADJUSTLIST VALUES PAL;
    END LOOP;
    CLOSE C_TD;
  
    --更新审核标志
    UPDATE TDSJHD
       SET /*crhshper=crhcreper */ crhshper = P_PER, crhshdate = SYSDATE, crhshflag = 'Y'
     WHERE CRHNO = TH.CRHNO;
     
    --更新流程
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_billNO);
     
     
    --提交标志
  
    if P_COMMIT = 'Y' then
      commit;
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_TH%ISOPEN THEN
        CLOSE C_TH;
      END IF;
      IF C_TD%ISOPEN THEN
        CLOSE C_TD;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END sp_特惠户管理;
  

  PROCEDURE sp_营业所变更(P_TYPE   IN VARCHAR2, --单据类别
                     P_CCHNO  IN VARCHAR2, --单据编号
                     P_PER    IN VARCHAR2, --审批人
                     P_COMMIT IN VARCHAR2) --是否提交
   IS
    CH  CUSTCHANGEHD%ROWTYPE;
    CD  CUSTCHANGEDT%ROWTYPE;
    MI  METERINFO%ROWTYPE;
    RL  RECLIST%ROWTYPE;
    RD  RECDETAIL%ROWTYPE;
    NRL RECLIST%ROWTYPE;
    NRD RECDETAIL%ROWTYPE;
    --单体游标
    CURSOR C_CUSTCHANGEDT IS
      SELECT *
        FROM CUSTCHANGEDT
       WHERE CCDNO = P_CCHNO
         AND CCDSHFLAG = 'N'
         FOR UPDATE;
    --欠费RECLIST游标
    CURSOR C_QF(C_MIID VARCHAR2) IS
      SELECT *
        FROM RECLIST
       WHERE RLREVERSEFLAG = 'N'
         AND RLPAIDFLAG = 'N'
         AND RLBADFLAG = 'N'
         AND RLMID = C_MIID;
    --欠费RECDETAIL游标
    CURSOR C_QFD(C_RLID VARCHAR2) IS
      SELECT * FROM RECDETAIL WHERE RDID = C_RLID;
  BEGIN
    BEGIN
      SELECT * INTO CH FROM CUSTCHANGEHD WHERE CCHNO = P_CCHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
    END;
    IF CH.CCHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '变更单已审核,不需再审!');
    END IF;
    IF CH.CCHSHFLAG = 'C' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '变更单已取消,不能审!');
    END IF;
  
    OPEN C_CUSTCHANGEDT;
    LOOP
      FETCH C_CUSTCHANGEDT
        INTO CD;
      EXIT WHEN C_CUSTCHANGEDT%NOTFOUND OR C_CUSTCHANGEDT%NOTFOUND IS NULL;
      --1、资料变更
      SP_CUSTCHANGEONE(P_TYPE, CD);
      --2、获取用户号
      SELECT * INTO MI FROM METERINFO M WHERE M.MIID = CD.Miid;
      --3、查询用户欠费
      OPEN C_QF(MI.MIID);
      LOOP
        FETCH C_QF
          INTO RL;
        EXIT WHEN C_QF%NOTFOUND OR C_QF%NOTFOUND IS NULL;
        --4、欠费游标(新增欠费（修改营业所、水价）；)
        IF RL.RLOUTFLAG = 'Y' THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '客户代码:' || RL.RLMCODE ||
                                  ',存在发出欠费,不允许变更营业所！');
        END IF;
        NRL      := RL;
        NRL.RLID := FGETSEQUENCE('RECLIST');
        --NRL.RLPFID   := MI.MIPFID;
      
        NRL.RLMEMO  := FGETSYSMANAFRAME(NRL.RLSMFID) || '-转到-' ||
                       FGETSYSMANAFRAME(MI.MISMFID);
        NRL.RLSMFID := MI.MISMFID;
      
        --新增RECDETAIL明细表
        OPEN C_QFD(RL.RLID);
        LOOP
          FETCH C_QFD
            INTO RD;
          EXIT WHEN C_QFD%NOTFOUND OR C_QFD%NOTFOUND IS NULL;
          NRD      := RD;
          NRD.RDID := NRL.RLID;
          INSERT INTO RECDETAIL VALUES NRD;
        END LOOP;
        CLOSE C_QFD;
      
        --新增RECLIST
        INSERT INTO RECLIST VALUES NRL;
      
        --5、冲销原欠费
        PG_EWIDE_RECTRANS_01.SP_RECCZ_ONE_01(RL.RLID, 'N');
      END LOOP;
      CLOSE C_QF;
    
      --SP_CUSTCHANGEONE(P_TYPE, CD);
      --
      UPDATE CUSTCHANGEDT
         SET CCDSHFLAG = 'Y', CCDSHDATE = CURRENTDATE, CCDSHPER = P_PER
       WHERE CURRENT OF C_CUSTCHANGEDT;
    END LOOP;
    CLOSE C_CUSTCHANGEDT;
  
    UPDATE CUSTCHANGEHD
       SET CCHSHDATE = SYSDATE,/*CCHSHPER= cchshper*/  CCHSHPER = P_PER, CCHSHFLAG = 'Y'
     WHERE CCHNO = P_CCHNO;
  
    --更新流程
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_CCHNO);
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_CUSTCHANGEDT%ISOPEN THEN
        CLOSE C_CUSTCHANGEDT;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END sp_营业所变更;

  PROCEDURE sp_批量预存(P_MICODE IN VARCHAR2, --客户代码
                    P_OPER   IN VARCHAR2, --收款人
                    P_SAVING IN NUMBER, --预存
                    O_PBATCH OUT VARCHAR2) --缴费批次
   IS
  
    TD        CUSTMETERREGDT%ROWTYPE; --立户单体对象
    MI        METERINFO%ROWTYPE;
    ls_pbatch VARCHAR2(50); --批次
    ls_pid    varchar2(50); --缴费流水
    ls_ret    varchar2(100);
    ls_ppayway payment.ppayway%type;
    ls_OPER    payment.PPER%type;
  BEGIN
  
    --检查单据是否存在
    BEGIN
      SELECT * into TD FROM CUSTMETERREGDT WHERE MICODE = P_MICODE;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '用户' || P_MICODE || '立户单不存在!');
    END;
  
    IF TD.MISAVINGFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '用户' || P_MICODE || '预存已缴,请确认!');
    END IF;
  
    BEGIN
      SELECT * into MI FROM METERINFO WHERE MICODE = P_MICODE;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '用户' || P_MICODE || '水表信息不存在!');
    END;
    /*FUNCTION F_PAY_CORE(P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
    P_OPER     IN PAYMENT.PPER%TYPE, --收款员
    P_MIID     IN PAYMENT.PMID%TYPE, --水表资料号
    P_RLJE     IN NUMBER, --应收金额
    P_ZNJ      IN NUMBER, --销帐违约金
    P_SXF      IN NUMBER, --手续费
    P_PAYJE    IN NUMBER, --实际收款
    P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
    P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
    P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
    P_PAYBATCH IN VARCHAR2, --缴费事务流水
    P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
    P_INVNO    IN PAYMENT.PILID%TYPE, --发票号
    P_PAYID    OUT PAYMENT.PID%TYPE --实收流水，返回此次记账的实收流水号
    )*/
    select fgetsequence('ENTRUSTLOG') into ls_pbatch from dual;
    if instr(P_OPER,'|') >0 then
      ls_ppayway:=substr(P_OPER,instr(P_OPER,'|')+1);
      ls_OPER:=substr(P_OPER,1,instr(P_OPER,'|') - 1);
    else
      Ls_ppayway:='XJ';
      ls_OPER:=P_OPER;
    end if;
    --销账
    --原来是PG_EWIDE_PAY_LYG，缺字段    20140406
    ls_ret := PG_EWIDE_PAY_HRB.F_PAY_CORE(MI.MISMFID,
                                          ls_OPER,
                                          MI.MIID,
                                          0,
                                          0,
                                          0,
                                          P_SAVING,
                                          'S',
                                          Ls_ppayway,
                                          MI.MISMFID,
                                          ls_pbatch,
                                          'N',
                                          '',
                                          ls_pid);
    IF ls_ret = '000' THEN
      NULL;
    ELSE
      ROLLBACK;
      RETURN;
    END IF;
    O_PBATCH := ls_pbatch;
    -- 回写立户
    UPDATE CUSTMETERREGDT
       SET PBATCH = ls_pbatch, PID = ls_pid, MISAVINGFLAG = 'Y'
     WHERE MICODE = P_MICODE;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END sp_批量预存;

  PROCEDURE sp_撤销预存(P_BATCH    IN VARCHAR2, --缴费批次
                    P_PID      IN VARCHAR2, --缴费流水
                    P_MICODE   IN VARCHAR2, --客户代码
                    P_POSITION IN VARCHAR2, --缴费地点
                    P_OPER     IN VARCHAR2, --缴费人
                    P_TYPE     IN VARCHAR2) --冲销类别 1、批次冲销2、缴费流水冲销
   IS
  
    TD     CUSTMETERREGDT%ROWTYPE; --单体对象
    PAL    PRICEADJUSTLIST%ROWTYPE; --策略单价
    ls_ret varchar(50);
  
  BEGIN
    --检查单据是否存在
    BEGIN
      SELECT * into TD FROM CUSTMETERREGDT WHERE MICODE = P_MICODE;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '用户' || P_MICODE || '立户单不存在!');
    END;
  
    IF P_BATCH IS NULL OR P_PID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '冲销流水号不存在!');
    END IF;
  
    IF P_POSITION IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '缴费地点不存在!');
    END IF;
  
    IF P_OPER IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '缴费人不存在!');
    END IF;
  
    IF P_TYPE = '1' THEN
      ls_ret := PG_EWIDE_PAY_HRB.F_PAYBACK_BY_BATCH(P_BATCH,
                                                    P_POSITION,
                                                    P_OPER,
                                                    P_POSITION,
                                                    'S');
    ELSIF P_TYPE = '2' THEN
      ls_ret := PG_EWIDE_PAY_HRB.F_PAYBACK_BY_PMID(P_PID,
                                                   P_POSITION,
                                                   P_OPER,
                                                   P_BATCH,
                                                   P_POSITION,
                                                   'S',
                                                   'N');
    END IF;
  
    UPDATE CUSTMETERREGDT
       SET PBATCH = '', PID = '', MISAVINGFLAG = 'N'
     WHERE MICODE = P_MICODE;
  
    IF ls_ret = '000' THEN
      COMMIT;
    ELSE
      ROLLBACK;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END sp_撤销预存;

  PROCEDURE SP_拆迁止水(P_TYPE   IN VARCHAR2, --单据类别
                    P_BILLNO IN VARCHAR2, --单据编号
                    P_OPER   IN VARCHAR2, --审批人
                    P_COMMIT IN VARCHAR2) --是否提交
   IS
    --单头
    CURSOR C_TH IS
      SELECT * FROM DEMO_WATERSH WHERE CRHNO = P_BILLNO;
  
    --单体
    CURSOR C_TD IS
      SELECT * FROM DEMO_WATERSB WHERE CMRDNO = P_BILLNO;
  
    TH      DEMO_WATERSH%ROWTYPE; --单头对象
    TD      DEMO_WATERSB%ROWTYPE; --单体对象
    PAL     PRICEADJUSTLIST%ROWTYPE; --策略单价
    V_PALID VARCHAR2(20);
    V_ROW   NUMBER;
  BEGIN
  
    BEGIN
      SELECT * INTO TH FROM DEMO_WATERSH WHERE CRHNO = P_BILLNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '立户单不存在!');
    END;
    IF TH.CRHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF TH.CRHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    SELECT COUNT(*) INTO V_ROW FROM DEMO_WATERSB WHERE CMRDNO = P_BILLNO;
    IF V_ROW = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '拆迁止水无单体数据!');
    END IF;
  
    OPEN C_TD;
    LOOP
      FETCH C_TD
        INTO TD;
      EXIT WHEN C_TD%NOTFOUND OR C_TD%NOTFOUND IS NULL;
      --20140314 修改为拆迁止水只修改用户状态
      UPDATE METERINFO SET MISTATUS = '32' WHERE MIID = TD.RGMARK;
    
    END LOOP;
    CLOSE C_TD;
  
    --提交标志
    UPDATE DEMO_WATERSH
       SET CRHSHDATE = SYSDATE,/*CRHSHPER=crhcreper   */ CRHSHPER = P_OPER, CRHSHFLAG = 'Y'
     WHERE CRHNO = P_BILLNO;
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_拆迁止水;

  PROCEDURE sp_异常表态审批(P_TYPE   IN VARCHAR2, --单据类别
                      P_billNO IN VARCHAR2, --单据编号
                      P_PER    IN VARCHAR2, --审批人
                      P_COMMIT IN VARCHAR2) --是否提交
   IS
    --单头
    CURSOR C_ZS IS
      SELECT * FROM ZSYSDT WHERE CRHNO = P_billNO;
  
    -- 
    CURSOR C_DT IS
      SELECT * FROM MRFACEBILLDT WHERE MBDNO = P_billNO;
  
    ZS ZSYSDT%ROWTYPE;
    DT MRFACEBILLDT%ROWTYPE;
  BEGIN
    --检查单据是否存在
    --1、检查单据
    OPEN C_ZS;
    FETCH C_ZS
      INTO ZS;
    IF C_ZS%NOTFOUND OR C_ZS%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '异常表态审批单据不存在' || P_billNO);
    END IF;
    CLOSE C_ZS;
  
    OPEN C_DT;
    LOOP
      FETCH C_DT
        INTO DT;
      EXIT WHEN C_DT%NOTFOUND OR C_DT%NOTFOUND IS NULL;
      --2、检查标志
      IF DT.MBDSHFLAG = 'Y' THEN
        --审批通过
        UPDATE METERREAD SET mrifsubmit = 'Y' WHERE MRID = DT.MRID;
      ELSE
        --审批不通过，重新入账
        UPDATE METERREAD
           SET mrifsubmit  = 'Y',
               mrinputdate = NULL,
               mrreadok    = 'N',
               mrrdate     = NULL,
               mrecode     = NULL,
               mrsl        = NULL,
               mrface      = '01',
               mrface2     = NULL,
               mrifgu      = 'N',
               mrscodechar = NULL,
               mrecodechar = NULL
         WHERE MRID = DT.MRID;
      END IF;
    
    END LOOP;
    CLOSE C_DT;
  
    --3、通过取消停算标志，则重新入账
    null;
  END sp_异常表态审批;

  procedure sp_封号管理(p_type   in varchar2, --单据类别
                    p_billno in varchar2, --单据编号
                    p_per    in varchar2, --审批人
                    p_commit in varchar2 --是否提交
                    ) as
    th stmeterchangehd%rowtype; --单头对象
    td stmeterchangedt%rowtype; --单体对象
  begin
    --1、检查单据
    begin
      select * into th from stmeterchangehd where hno = p_billno;
    exception
      when others then
        raise_application_error(errcode, '单据不存在!');
    end;
    if th.hshflag = 'Y' then
      raise_application_error(errcode, '单据已审核');
    end if;
    if th.hshflag = 'Q' then
      raise_application_error(errcode, '单据已取消');
    end if;
  
    --2、审批通过
    select * into td from stmeterchangedt where dno = p_billno;
    if p_type = '15' then
      --锁封 
      update meterdoc set lfh = td.lfhn where mdmid = td.miid;
    elsif p_type = '16' then
      --钢封号
      update meterdoc set dqgfh = td.dqgfhn where mdmid = td.miid;
    elsif p_type = 'g' then
      --塑封
      update meterdoc set dqsfh = td.dqsfhn where mdmid = td.miid;
    elsif p_type = 'i' then
      --首检封
      update meterdoc set sfh = td.sfhn where mdmid = td.miid;
    elsif p_type = 'h' then
      --铅封
      update meterdoc set qfh = td.qfhn1 where mdmid = td.miid;
    elsif p_type = 'j' then
      --稽查封
      update meterdoc set jcgfh = td.jcgfhn where mdmid = td.miid;
    end if;
  
    --3、审批后回写
    update stmeterchangehd
       set hshflag = 'Y',/*hshper=heper  */hshper = p_per, hshdate = sysdate
     where hno = p_billno;
    update stmeterchangedt set dflag = 'Y' where dno = p_billno;
  
    if p_commit = 'Y' then
      commit;
    end if;
  exception
    when others then
      raise_application_error(errcode, sqlerrm);
  end sp_封号管理;

  procedure SP_CUSTCHANGE_BYMIID(P_BILLNO   in varchar2, --单据编号
                                 p_BILLTYPE in varchar2, --单据编号
                                 p_per      in varchar2, --创建人
                                 P_MIID     IN VARCHAR2, --客户代码
                                 P_SMFID    IN VARCHAR2, --营业所
                                 p_commit   in varchar2 --是否提交
                                 ) as
    CH      CUSTCHANGEHD%ROWTYPE;
    DT      CUSTCHANGEDT%ROWTYPE;
    CI      CUSTINFO%ROWTYPE;
    MI      METERINFO%ROWTYPE;
    MD      METERDOC%ROWTYPE;
    MA      METERACCOUNT%ROWTYPE;
    PMD     PRICEMULTIDETAIL%ROWTYPE;
    OA      OPERACCNT%ROWTYPE;
    V_COUNT NUMBER(10);
  
    CURSOR C_PMD IS
      SELECT * FROM PRICEMULTIDETAIL WHERE PMDMID = MI.MIID;
  begin
  
    begin
      SELECT * INTO CH FROM CUSTCHANGEHD WHERE CCHNO = P_BILLNO;
    exception
      when others then
      
        SELECT * INTO OA FROM OPERACCNT WHERE OAID = p_per;
        --新增单头
        CH.cchno      := P_BILLNO;
        CH.cchbh      := P_BILLNO;
        CH.cchlb      := p_BILLTYPE;
        CH.cchsource  := '2';
        CH.cchsmfid   := P_SMFID;
        CH.cchdept    := OA.OADEPT;
        CH.cchcredate := SYSDATE;
        CH.cchcreper  := p_per;
        CH.cchshdate  := NULL;
        CH.cchshper   := NULL;
        CH.cchshflag  := 'N';
        CH.cchwfid    := NULL;
        INSERT INTO CUSTCHANGEHD VALUES CH;
    end;
    IF CH.CCHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '单据:' || P_billNO || '已审核,不允许添加单体！');
    END IF;
    --添加单体
    SELECT * INTO MI FROM METERINFO WHERE MIID = P_MIID;
    SELECT * INTO CI FROM CUSTINFO WHERE CIID = MI.MICID;
    SELECT * INTO MD FROM METERDOC WHERE MDMID = MI.MIID;
    SELECT * INTO MA FROM METERACCOUNT WHERE MAMID = MI.MIID;
    SELECT COUNT(*) INTO V_COUNT FROM CUSTCHANGEHD WHERE CCHNO = P_BILLNO;
  
    IF V_COUNT <= 0 THEN
      NULL;
    END IF;
  
    dt.ccdno         := NULL;
    dt.ccdrowno      := NULL;
    dt.ciid          := ci.ciid;
    dt.cicode        := ci.cicode;
    dt.ciconid       := ci.ciconid;
    dt.cismfid       := ci.cismfid;
    dt.cipid         := ci.cipid;
    dt.ciclass       := ci.ciclass;
    dt.ciflag        := ci.ciflag;
    dt.ciname        := ci.ciname;
    dt.ciname2       := ci.ciname2;
    dt.ciadr         := ci.ciadr;
    dt.cistatus      := ci.cistatus;
    dt.cistatusdate  := ci.cistatusdate;
    dt.cistatustrans := ci.cistatustrans;
    dt.cinewdate     := ci.cinewdate;
    dt.ciidentitylb  := ci.ciidentitylb;
    dt.ciidentityno  := ci.ciidentityno;
    dt.cimtel        := ci.cimtel;
    dt.citel1        := ci.citel1;
    dt.citel2        := ci.citel2;
    dt.citel3        := ci.citel3;
    dt.ciconnectper  := ci.ciconnectper;
    dt.ciconnecttel  := ci.ciconnecttel;
    dt.ciifinv       := ci.ciifinv;
    dt.ciifsms       := ci.ciifsms;
    dt.ciifzn        := ci.ciifzn;
    dt.ciprojno      := ci.ciprojno;
    dt.cifileno      := ci.cifileno;
    dt.cimemo        := ci.cimemo;
    dt.cideptid      := ci.cideptid;
    dt.micid         := mi.micid;
    dt.miid          := mi.miid;
    dt.miadr         := mi.miadr;
    dt.misafid       := mi.misafid;
    dt.micode        := mi.micode;
    dt.mismfid       := mi.mismfid;
    dt.miprmon       := mi.miprmon;
    dt.mirmon        := mi.mirmon;
    dt.mibfid        := mi.mibfid;
    dt.mirorder      := mi.mirorder;
    dt.mipid         := mi.mipid;
    dt.miclass       := mi.miclass;
    dt.miflag        := mi.miflag;
    dt.mirtid        := mi.mirtid;
    dt.miifmp        := mi.miifmp;
    dt.miifsp        := mi.miifsp;
    dt.mistid        := mi.mistid;
    dt.mipfid        := mi.mipfid;
    dt.mistatus      := mi.mistatus;
    dt.mistatusdate  := mi.mistatusdate;
    dt.mistatustrans := mi.mistatustrans;
    dt.miface        := mi.miface;
    dt.mirpid        := mi.mirpid;
    dt.miside        := mi.miside;
    dt.miposition    := mi.miposition;
    dt.miinscode     := mi.miinscode;
    dt.miinsdate     := mi.miinsdate;
    dt.miinsper      := mi.miinsper;
    dt.mireinscode   := mi.mireinscode;
    dt.mireinsdate   := mi.mireinsdate;
    dt.mireinsper    := mi.mireinsper;
    dt.mitype        := mi.mitype;
    dt.mircode       := mi.mircode;
    dt.mirecdate     := mi.mirecdate;
    dt.mirecsl       := mi.mirecsl;
    dt.miifcharge    := mi.miifcharge;
    dt.miifsl        := mi.miifsl;
    dt.miifchk       := mi.miifchk;
    dt.miifwatch     := mi.miifwatch;
    dt.miicno        := mi.miicno;
    dt.mimemo        := mi.mimemo;
    dt.mipriid       := mi.mipriid;
    dt.mipriflag     := mi.mipriflag;
    dt.miusenum      := mi.miusenum;
    dt.michargetype  := mi.michargetype;
    dt.misaving      := mi.misaving;
    dt.milb          := mi.milb;
    dt.minewflag     := mi.minewflag;
    dt.micper        := mi.micper;
    dt.miiftax       := mi.miiftax;
    dt.mitaxno       := mi.mitaxno;
  
    dt.mdmid         := md.mdmid;
    dt.mdno          := md.mdno;
    dt.mdcaliber     := md.mdcaliber;
    dt.mdbrand       := md.mdbrand;
    dt.mdmodel       := md.mdmodel;
    dt.mdstatus      := md.mdstatus;
    dt.mdstatusdate  := md.mdstatusdate;
    dt.mamid         := ma.mamid;
    dt.mano          := ma.mano;
    dt.manoname      := ma.manoname;
    dt.mabankid      := ma.mabankid;
    dt.maaccountno   := ma.maaccountno;
    dt.maaccountname := ma.maaccountname;
    dt.matsbankid    := ma.matsbankid;
    dt.matsbankname  := ma.matsbankname;
    dt.maifxezf      := ma.maifxezf;
    OPEN C_PMD;
    LOOP
      FETCH C_PMD
        INTO PMD;
      EXIT WHEN C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL;
      IF PMD.PMDID = 1 THEN
        dt.pmdcid     := pmd.pmdcid;
        dt.pmdmid     := pmd.pmdmid;
        dt.pmdid      := pmd.pmdid;
        dt.pmdpfid    := pmd.pmdpfid;
        dt.pmdscale   := pmd.pmdscale;
        dt.pmdtype    := pmd.pmdtype;
        dt.pmdcolumn1 := pmd.pmdcolumn1;
        dt.pmdcolumn2 := pmd.pmdcolumn2;
        dt.pmdcolumn3 := pmd.pmdcolumn3;
      ELSIF PMD.PMDID = 2 THEN
        dt.pmdid2      := pmd.pmdid;
        dt.pmdpfid2    := pmd.pmdpfid;
        dt.pmdscale2   := pmd.pmdscale;
        dt.pmdtype2    := pmd.pmdtype;
        dt.pmdcolumn12 := pmd.pmdcolumn1;
        dt.pmdcolumn22 := pmd.pmdcolumn2;
        dt.pmdcolumn32 := pmd.pmdcolumn3;
      ELSIF PMD.PMDID = 3 THEN
        dt.pmdid3      := pmd.pmdid;
        dt.pmdpfid3    := pmd.pmdpfid;
        dt.pmdscale3   := pmd.pmdscale;
        dt.pmdtype3    := pmd.pmdtype;
        dt.pmdcolumn13 := pmd.pmdcolumn1;
        dt.pmdcolumn23 := pmd.pmdcolumn2;
        dt.pmdcolumn33 := pmd.pmdcolumn3;
      ELSIF PMD.PMDID = 4 THEN
        dt.pmdid4      := pmd.pmdid;
        dt.pmdpfid4    := pmd.pmdpfid;
        dt.pmdscale4   := pmd.pmdscale;
        dt.pmdtype4    := pmd.pmdtype;
        dt.pmdcolumn14 := pmd.pmdcolumn1;
        dt.pmdcolumn24 := pmd.pmdcolumn2;
        dt.pmdcolumn34 := pmd.pmdcolumn3;
      END IF;
    END LOOP;
    CLOSE C_PMD;
  
    dt.ccdshflag       := 'N';
    dt.ccdshdate       := NULL;
    dt.ccdshper        := NULL;
    dt.miifckf         := mi.miifckf;
    dt.migps           := mi.migps;
    dt.miqfh           := mi.miqfh;
    dt.mibox           := mi.mibox;
    dt.ccdappnote      := NULL;
    dt.ccdfilashnote   := NULL;
    dt.ccdmemo         := '抄表器导入变更';
    dt.maregdate       := ma.maregdate;
    dt.miname          := mi.miname;
    dt.miname2         := mi.miname2;
    dt.accessoryflag01 := 'N';
    dt.accessoryflag02 := 'N';
    dt.accessoryflag03 := 'N';
    dt.accessoryflag04 := 'N';
    dt.accessoryflag05 := 'N';
    dt.accessoryflag06 := 'N';
    dt.accessoryflag07 := 'N';
    dt.accessoryflag08 := 'N';
    dt.accessoryflag09 := 'N';
    dt.accessoryflag10 := 'N';
    dt.accessoryflag11 := 'N';
    dt.accessoryflag12 := 'N';
    dt.mabankcode      := ma.MABANKID;
    dt.mabankname      := ma.MABANKID;
    dt.miseqno         := mi.miseqno;
    dt.mijfkrow        := mi.mijfkrow;
    dt.miuiid          := mi.miuiid;
    dt.micommunity     := mi.micommunity;
    dt.miremoteno      := mi.miremoteno;
    dt.miremotehubno   := mi.miremotehubno;
    dt.miemail         := mi.miemail;
    dt.miemailflag     := mi.miemailflag;
    dt.micolumn1       := mi.micolumn1;
    dt.micolumn2       := mi.micolumn2;
    dt.micolumn3       := mi.micolumn3;
    dt.micolumn4       := mi.micolumn4;
    dt.mipaymentid     := mi.mipaymentid;
    dt.micolumn5       := mi.micolumn5;
    dt.micolumn6       := mi.micolumn6;
    dt.micolumn7       := mi.micolumn7;
    dt.micolumn8       := mi.micolumn8;
    dt.micolumn9       := mi.micolumn9;
    dt.micolumn10      := mi.micolumn10;
    dt.lh              := mi.milh;
    dt.dyh             := mi.midyh;
    dt.mph             := mi.mimph;
    dt.sfh             := md.sfh;
    dt.dqsfh           := md.dqsfh;
    dt.dqgfh           := md.dqgfh;
    dt.jcgfh           := md.jcgfh;
    dt.qhf             := md.qfh;
    dt.miyhpj          := mi.MIYHPJ;
    dt.mijd            := mi.mijd;
    INSERT INTO CUSTCHANGEDT VALUES DT;
  exception
    when others then
      raise_application_error(errcode, sqlerrm);
  end SP_CUSTCHANGE_BYMIID;
  
   
PROCEDURE       SP_远传建账 AS
    CURSOR C_CMRD IS
      SELECT * FROM CUSTMETERREGDTYC WHERE JZFLAG='N' FOR UPDATE;
  

    CURSOR C_PCI(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID; 
  
    CURSOR C_PMI(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MICODE = VMID;
  
  
    V_I           VARCHAR2(50);
    HD            CUSTREGHD%ROWTYPE;
    CRH           CUSTREGHD%ROWTYPE;
    CR            CUSTREGHD%ROWTYPE;
    CMRD          CUSTMETERREGDTYC%ROWTYPE;
    CI            CUSTINFO%ROWTYPE;
    MI            METERINFO%ROWTYPE;
    MD            METERDOC%ROWTYPE;
    MA            METERACCOUNT%ROWTYPE;
    PCI           CUSTINFO%ROWTYPE;
    PMI           METERINFO%ROWTYPE;
    PMD           PRICEMULTIDETAIL%ROWTYPE;
    FLAGN         NUMBER;
    FLAGY         NUMBER;
    V_SEQTEMP     VARCHAR2(200);
    V_BILLID      VARCHAR2(200);
    V_METERSTATUS METERSTATUS%ROWTYPE;
    V_NUM         NUMBER;
    V_COUNT       NUMBER;
  
  BEGIN
    CALLOGTXT := NULL;
    V_COUNT := 0;
    V_NUM := 0;
  
    OPEN C_CMRD;
    LOOP
      FETCH C_CMRD
        INTO CMRD;
      EXIT WHEN C_CMRD%NOTFOUND OR C_CMRD%NOTFOUND IS NULL;
 
      --增加用户--------------------------
      --CI.CIID          := FGETSEQUENCE('CUSTINFO');--
      --CI.CICODE        := NVL(CMRD.CICODE,FNEWCICODE(CMRD.CISMFID));--
      CI.CICONID := CMRD.CICONID; --
      CI.CISMFID := CMRD.CISMFID; --
      CI.CIPID   := CMRD.CIPID; --
      --校验上级用户
      IF CMRD.CIPID IS NOT NULL THEN
        OPEN C_PCI(CMRD.CIPID);
        FETCH C_PCI
          INTO PCI;
/*        IF C_PCI%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_CRHNO || '无效的上级用户');
        END IF;*/
        CI.CICLASS := PCI.CICLASS + 1; --
        CLOSE C_PCI;
      ELSE
        CI.CICLASS := 1; --
      END IF;
      CI.CIFLAG        := 'Y'; --
      CI.CINAME        := CMRD.CINAME; --
      CI.CINAME2       := CMRD.CINAME2; --
      CI.CIADR         := CMRD.CIADR; --
      CI.CISTATUS      := CMRD.CISTATUS; --
      CI.CISTATUSDATE  := NULL; --
      CI.CISTATUSTRANS := NULL; --
      CI.CINEWDATE     := CURRENTDATE; --
      CI.CIIDENTITYLB  := CMRD.CIIDENTITYLB; --
      CI.CIIDENTITYNO  := CMRD.CIIDENTITYNO; --
      CI.CIMTEL        := CMRD.CIMTEL; --
      CI.CITEL1        := CMRD.CITEL1; --
      CI.CITEL2        := CMRD.CITEL2; --
      CI.CITEL3        := CMRD.CITEL3; --
      CI.CICONNECTPER  := CMRD.CICONNECTPER; --
      CI.CICONNECTTEL  := CMRD.CICONNECTTEL; --
      CI.CIIFINV       := CMRD.CIIFINV; --
      CI.CIIFSMS       := CMRD.CIIFSMS; --
      CI.CIIFZN        := CMRD.CIIFZN; --
      CI.CIPROJNO      := CMRD.CIPROJNO; --
      CI.CIFILENO      := CMRD.CIFILENO; --
      CI.CIMEMO        := CMRD.CIMEMO; --
      CI.CIDEPTID      := CMRD.CIDEPTID; --
      ----------------------------
/*      IF 客户代码是否营业所 = 'Y' THEN
        MI.MIID := NVL(CMRD.MICODE, FNEWMICODE(CMRD.MISMFID)); --FGETSEQUENCE('METERINFO');--
      ELSIF 客户代码是否营业所 = 'N' THEN
        IF CMRD.MISAFID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '水表区域不能为NULL');
        END IF;
        IF FNEWMICODEAREA(CMRD.MISAFID) IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '编码规则未定义');
        END IF;
        MI.MIID := NVL(CMRD.MICODE, FNEWMICODEAREA(CMRD.MISAFID));
        --客户代码【哈尔滨需要】前面9位是从序号取，后面一位是前面9位数据相加，取4的膜
      ELSIF 客户代码是否营业所 = 'O' THEN
        MI.MIID := FGETMICODE;
      ELSE
        MI.MIID := NVL(CMRD.MICODE, FNEWMICODE('020101')); --FGETSEQUENCE('METERINFO');--
      END IF;*/
      MI.MIID := NVL(CMRD.MICODE, FNEWMICODE(CMRD.MISMFID)); 
    
      CI.CIID      := MI.MIID;
      MI.MICID     := CI.CIID; --
      MI.MIADR     := CMRD.MIADR; --
      MI.MINAME    := CMRD.MINAME; --
      MI.MINAME2   := CMRD.MINAME2; --
      MI.MISAFID   := CMRD.MISAFID; --
      MI.MICODE    := CMRD.MICODE; --
      MI.MICODE    := MI.MIID; --NVL(CMRD.MICODE,FNEWMICODE(CMRD.MISMFID));--
      CI.CICODE    := MI.MICODE;
      MI.MISMFID   := CI.CISMFID; --
      MI.MIPRMON   := NULL; --
      MI.MIRMON    := NULL; --
      MI.MIBFID    := CMRD.MIBFID; --表册 
      MI.MIRORDER  := CMRD.MIRORDER; --抄表次序 
      MI.MISEQNO   := MI.MIBFID || MI.MIRORDER; --户号（初始化时册号+序号）（哈尔滨：帐卡号） 
      MI.MIPID     := CMRD.MIPID; --
      MI.MINEWDATE := CURRENTDATE;
      MI.MIGPS     := CMRD.MIGPS;
      MI.MIQFH     := CMRD.MIQFH;
      /*MI.MISAVING      := CMRD.MISAVING;*/
      --校验上级水表
      IF CMRD.MIPID IS NOT NULL THEN
        OPEN C_PMI(CMRD.MIPID);
        FETCH C_PMI
          INTO PMI;
/*        IF C_PMI%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_CRHNO || '无效的上级水表');
        END IF;*/
        MI.MICLASS := PMI.MICLASS + 1; --
        CLOSE C_PMI;
      ELSE
        MI.MICLASS := 1; --
      END IF;
      MI.MIFLAG := 'Y'; --
      MI.MIRTID := CMRD.MIRTID; --
      MI.MIIFMP := CMRD.MIIFMP; --
      MI.MIIFSP := CMRD.MIIFSP; --
      MI.MISTID := CMRD.MISTID; --
      MI.MIPFID := CMRD.MIPFID; --
      
      MI.MISTATUS := CMRD.MISTATUS; --
      MI.MISTATUS := '2'; --预立户状态
      MI.MISTATUSDATE  := NULL; --
      MI.MISTATUSTRANS := NULL; --
      MI.MIRPID        := CMRD.MIRPID; --
      MI.MISIDE        := CMRD.MISIDE; --
      MI.MIPOSITION    := CMRD.MIPOSITION; --
      MI.MIINSCODE     := TO_NUMBER(CMRD.MIINSCODECHAR); --
      MI.MIINSDATE     := CMRD.MIINSDATE; --
      MI.MIINSPER      := CMRD.MIREINSPER; --
      MI.MIREINSCODE   := NULL; --
      MI.MIREINSDATE   := NULL; --
      MI.MIREINSPER    := NULL; --
      MI.MITYPE        := CMRD.MITYPE; --
      MI.MIRCODE       := CMRD.MIINSCODE; --
      MI.MIRCODECHAR   := CMRD.MIINSCODECHAR;
      MI.MIRECDATE     := NULL; --
      MI.MIRECSL       := NULL; --
      MI.MIIFCHARGE    := CMRD.MIIFCHARGE; --
      MI.MIIFSL        := CMRD.MIIFSL; --
      MI.MIIFCHK       := CMRD.MIIFCHK; --
      MI.MIIFWATCH     := CMRD.MIIFWATCH; --
      MI.MIICNO        := CMRD.MIICNO; --
      MI.MIMEMO        := CMRD.MIMEMO; --
      MI.MIPRIID       := CMRD.MIPRIID; --
      MI.MIPRIFLAG     := CMRD.MIPRIFLAG; --
      IF MI.MIPRIFLAG = 'N' THEN
        --如果不是合收表，则合收主表号为自己
        MI.MIPRIID := MI.MIID;
      END IF;
      MI.MIUSENUM      := CMRD.MIUSENUM; --
      MI.MICHARGETYPE  := CMRD.MICHARGETYPE; --
      MI.MIIFCKF       := CMRD.MIIFCKF; --
      MI.MISAVING      := 0; --
      MI.MILB          := CMRD.MILB; --
      MI.MINEWFLAG     := 'Y'; --
      MI.MICPER        := CMRD.MICPER; --
      MI.MIIFTAX       := CMRD.MIIFTAX; --
      MI.MITAXNO       := CMRD.MITAXNO; --
      MI.MIJFKROW      := 0; --
      MI.MIUIID        := CMRD.MIUIID; --
      MI.MICOMMUNITY   := CMRD.MICOMMUNITY; --小区
      MI.MIREMOTENO    := CMRD.MIREMOTENO; --远传表号
      MI.MIREMOTEHUBNO := CMRD.MIREMOTEHUBNO; --远传表HUB号
      MI.MIEMAIL       := CMRD.MIEMAIL; --电子邮件
      MI.MIEMAILFLAG   := CMRD.MIEMAILFLAG; --发账是否发邮件
      MI.MICOLUMN1     := CMRD.MICOLUMN1; --备用字段1
      MI.MICOLUMN2     := CMRD.MICOLUMN2; --备用字段2
      MI.MICOLUMN3     := CMRD.MICOLUMN3; --备用字段3
      MI.MICOLUMN4     := CMRD.MICOLUMN4; --备用字段4
      MI.MIFACE        := CMRD.MIFACE; --备用字段4
      --MI.MICOLUMN9     := CMRD.MICOLUMN9;
      -- MI.MICOLUMN10    := CMRD.MICOLUMN10;
    
      /*MI.MISAVING      := CMRD.MISAVING;*/
      MD.MDMID        := MI.MIID; --
      MD.MDID         := MI.MIID; --FGETSEQUENCE('METERDOC');--立户即入库新水表表
      MD.MDNO         := CMRD.MDNO; --
      MD.MDCALIBER    := CMRD.MDCALIBER; --
      MD.MDBRAND      := CMRD.MDBRAND; --
      MD.MDMODEL      := CMRD.MDMODEL; --
      MD.MDSTATUS     := CMRD.MDSTATUS; --
      MD.MDSTATUSDATE := NULL; --
      MD.MDSTOCKDATE  := CURRENTDATE;
      MD.MDSTORE      := MI.MIID; --安装后位置为水表安装地址
      --MD.BARCODE      := CMRD.BARCODE;
      MD.RFID   := CMRD.RFID;
      MD.IFDZSB := 'N'; --初装水表默认是正常水表，倒装走水表信息维护
      --条形码自动生成=1位区号+8位年月日+10位客户代码。20140411
      MD.BARCODE := SUBSTR(MI.MISMFID, 4, 1) ||
                    TO_CHAR(SYSDATE, 'YYYYMMDD') || MI.MIID;
      MD.DQSFH   := CMRD.DQSFH; --塑封号
      MD.DQGFH   := CMRD.DQGFH; --钢封号
      MD.JCGFH   := CMRD.JCGFH; --稽查封号
      MD.QFH     := CMRD.QHF; --铅封号
    
      MA.MAMID         := MI.MIID; --
      MA.MANO          := CMRD.MANO; --
      MA.MANONAME      := CMRD.MANONAME; --
      MA.MABANKID      := CMRD.MABANKID; --
      MA.MAACCOUNTNO   := CMRD.MAACCOUNTNO; --
      MA.MAACCOUNTNAME := CMRD.MAACCOUNTNAME; --
      MA.MATSBANKID    := CMRD.MATSBANKID; --
      MA.MATSBANKNAME  := CMRD.MATSBANKNAME; --
      MA.MAIFXEZF      := CMRD.MAIFXEZF; --
    

    
      ----------------------------
      INSERT INTO CUSTINFO VALUES CI;
      INSERT INTO METERINFO VALUES MI;
      INSERT INTO METERDOC VALUES MD;
      INSERT INTO METERACCOUNT VALUES MA;

      UPDATE CUSTMETERREGDTYC
         SET CIID    = CI.CIID,
             MIID    = MI.MIID,
             MICODE  = MI.MICODE,
             BARCODE = MD.BARCODE,
             JZFLAG  = 'Y'
       WHERE CURRENT OF C_CMRD;
       
       --设置表身码为已使用
        UPDATE ST_METERINFO_STORE
           SET MIID = MI.MIID, STATUS = '3'
         WHERE BSM = CMRD.MDNO  ;
       
    END LOOP;
    CLOSE C_CMRD;
  
       COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

END;
/

