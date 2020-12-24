CREATE OR REPLACE PACKAGE BODY PG_CB_COST IS

  总表截量     VARCHAR2(10);
  最低算费水量 NUMBER(10);
  
  
  
  --提供外部批量调用
  PROCEDURE COSTBATCH(P_BFID IN VARCHAR2) IS
    CURSOR C_MR(VBFID IN VARCHAR2, VSMFID IN VARCHAR2) IS
      SELECT YCM.ID
        FROM YS_CB_MTREAD YCM, YS_YH_SBINFO YYS
       WHERE YCM.SBID = YYS.SBID
         AND YCM.BOOK_NO = VBFID
         AND YCM.MANAGE_NO = VSMFID
         AND CBMRIFREC = 'N' --未计费
         AND CBMRREADOK = 'Y' --抄见
       ORDER BY SBCLASS DESC,
                (CASE
                  WHEN SBPRIFLAG = 'Y' AND SBPRIID <> SBCODE THEN
                   1
                  ELSE
                   2
                END) ASC;
    --游标中不共享资源，解锁前资源不能被更新并且不等待并抛出异常
  
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
        --单条抄表记录处理
        BEGIN
          COSTCULATE(VMRID, 提交);
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
  
  
  
  --计划抄表单笔算费-按抄表流水
  PROCEDURE COSTCULATE(P_MRID IN YS_CB_MTREAD.ID%TYPE, P_COMMIT IN NUMBER) IS
    CURSOR C_MR IS
      SELECT *
        FROM YS_CB_MTREAD
       WHERE ID = P_MRID
         AND CBMRIFREC = 'N'
         AND CBMRREADOK = 'Y' --抄见
         AND CBMRSL >= 0
         FOR UPDATE NOWAIT;
  
    --合收子表抄表记录
    CURSOR C_MR_PRI(P_PRIMCODE IN VARCHAR2) IS
      SELECT CBMRSL, CBMRIFREC, YCM.SBID
        FROM YS_YH_SBINFO YYS, YS_CB_MTREAD YCM
       WHERE YYS.SBID = YCM.SBID
         AND SBPRIFLAG = 'Y'
         AND SBPRIID = P_PRIMCODE
         AND YYS.SBID <> P_PRIMCODE;
  
    --取合收表信息
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
                              '抄表流水号:' || P_MRID || '无效的抄表计划流水号，或不符合计费条件');
    END IF;
    MR.CBMRCHKSL := MR.CBMRSL;
  
    --水表记录
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
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.SBID);
    END IF;
    CLOSE C_MI;
  
    MR.CBMRRECSL := MR.CBMRSL;
    IF MR.CBMRSL > 0 AND MR.CBMRSL < 最低算费水量 AND
       MR.CBMRDATASOURCE IN ('1', '5', '9') THEN
      MR.CBMRIFREC   := 'Y';
      MR.CBMRRECDATE := TRUNC(SYSDATE);
      MR.CBMRMEMO    := MR.CBMRMEMO || ',' || 最低算费水量 || '吨以下不计费';
    ELSIF 总表截量 = 'Y' THEN
      --查找是否有多级表关系 预留
    
      --计费核心----------------------------------------------------------
      IF MR.CBMRIFREC = 'N' AND (MR.CBMRIFSUBMIT = 'Y' OR P_COMMIT = 调试) AND
         MI.SBIFCHARGE = 'Y' THEN
        COSTCULATECORE(MR, 计划抄表, '0', P_COMMIT); --均已当前水价进行计费，水价版本号默认0，后续可扩展
      END IF;
      --推止码------------------------------------------------------------
      IF P_COMMIT != 调试 THEN
        UPDATE YS_YH_SBINFO
           SET SBRCODE     = MR.CBMRECODE,
               SBRECDATE   = MR.CBMRRDATE,
               SBRECSL     = MR.CBMRSL, --取本期水量（抄量）
               SBFACE      = MR.CBMRFACE,
               SBNEWFLAG   = 'N',
               SBRCODECHAR = MR.CBMRECODECHAR
         WHERE SBID = MR.SBID;
      END IF;
    ELSE
      --计费核心----------------------------------------------------------
      IF MR.CBMRIFREC = 'N' AND (MR.CBMRIFSUBMIT = 'Y' OR P_COMMIT = 调试) AND
         MI.SBIFCHARGE = 'Y' THEN
        COSTCULATECORE(MR, 计划抄表, '0', P_COMMIT); --均已当前水价进行计费，水价版本号默认0，后续可扩展
      END IF;
      --推止码------------------------------------------------------------
      IF P_COMMIT != 调试 AND MR.CBMRIFREC = 'Y' THEN
        UPDATE YS_YH_SBINFO
           SET SBRCODE     = MR.CBMRECODE,
               SBRECDATE   = MR.CBMRRDATE,
               SBRECSL     = MR.CBMRSL, --取本期水量（抄量）
               SBFACE      = MR.CBMRFACE,
               SBNEWFLAG   = 'N',
               SBRCODECHAR = MR.CBMRECODECHAR
         WHERE SBID = MR.SBID;
      END IF;
    END IF;
    --更新当前抄表记录、反馈最后计费信息
    IF P_COMMIT != 调试 AND MR.CBMRIFREC = 'Y' THEN
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
    --2、提交处理
    BEGIN
      CLOSE C_MR;
      IF P_COMMIT = 调试 THEN
        NULL;
        --rollback;
      ELSE
        IF P_COMMIT = 提交 THEN
          COMMIT;
        ELSIF P_COMMIT = 不提交 THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '是否提交参数不正确');
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
  --单笔算费核心
  PROCEDURE COSTCULATECORE(MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                           P_TRANS  IN CHAR,
                           P_PSCID  IN VARCHAR2,
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
  
    --混合用水先定量再定比
    CURSOR C_PMD(VPSCID IN NUMBER, VMID IN ys_yh_pricegroup.SBID%TYPE) IS
      SELECT *
        FROM (SELECT * FROM ys_yh_pricegroup WHERE SBID = VMID)
       ORDER BY GRPTYPE DESC, GRPID; --按维护先后顺序
  
    PMD YS_YH_PRICEGROUP%ROWTYPE;
  
    --价格体系
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
    CLASSCTL  CHAR(1) := 'N'; --默认不取消阶梯计费方法
  
    I   NUMBER;
    VRD YS_ZW_ARDETAIL%ROWTYPE;
  
  BEGIN
    --锁定水表记录
    OPEN C_MI(MR.SBID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.SBID);
    END IF;
    --锁定水表档案
    OPEN C_MD(MR.SBID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.SBID);
    END IF;
    --锁定水表银行
    OPEN C_MA(MR.SBID);
    FETCH C_MA
      INTO MA;
    CLOSE C_MA;
    --锁定用户记录
    OPEN C_CI(MI.SBID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的用户编号' || MI.SBID);
    END IF;
    --如果是计费调整按工单水价进行计费
    IF MR.ID = '?' OR P_TRANS = 'O' THEN
      MI.PRICE_NO := MR.PRICE_NO;
    END IF;
    /*------------------增加年阶梯校验-------------------
    IF 是否含年阶梯水价(MI.SBID) = 'Y' AND MI.SBYEARDATE IS NULL THEN
      MI.SBYEARSL := 0; --年累计量
      MI.SBYEARDATE := TRUNC(SYSDATE, 'YYYY'); --年阶梯起算日
      UPDATE YS_YH_SBINFO
         SET SBYEARSL = MI.SBYEARSL, SBYEARDATE = MI.SBYEARDATE
       WHERE SBID = MI.SBID;
    END IF;
    ------------------增加年阶梯校验-------------------*/
  
    --非计费表执行空过程，不抛异常
    --reclist↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
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
      RL.ARIFINV       := CI.YHIFINV; --开票标志
      RL.ARMCODE       := MI.SBCODE;
      RL.ARMPID        := MI.SBPID;
      RL.ARMCLASS      := MI.SBCLASS;
      RL.ARMFLAG       := MI.SBFLAG;
      RL.ARDAY         := MR.CBMRDAY;
      RL.ARBFID        := MI.BOOK_NO; --
      --分段算法要求上期抄表日期和本期抄表日期非空
      RL.ARPRDATE := NVL(NVL(NVL(MR.CBMRPRDATE, MI.SBINSDATE), MI.SBNEWDATE),
                         TRUNC(SYSDATE));
      RL.ARRDATE  := NVL(NVL(MR.CBMRRDATE, TRUNC(MR.CBMRINPUTDATE)),
                         TRUNC(SYSDATE));
    
      --违约金起算日期（注意同步修改营业外收入审核）
      /*A  当月定日起算
      B  下月定日起算
      C  计费日起算*/
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
      RL.ARREADSL       := MR.CBMRSL; --变量暂存，最后恢复
      RL.ARINVMEMO := CASE
                        WHEN NOT (P_PSCID = '0000.00' OR P_PSCID IS NULL) THEN
                         '[' || P_PSCID || ']历史单价'
                        ELSE
                         ''
                      END;
      RL.ARENTRUSTBATCH := NULL;
      RL.ARENTRUSTSEQNO := NULL;
      RL.AROUTFLAG      := 'N';
      RL.ARTRANS        := P_TRANS;
      RL.ARCD           := DEBIT;
      RL.ARYSCHARGETYPE := MI.SBCHARGETYPE;
      RL.ARSL           := 0; --应收水费水量，【rlsl = rlreadsl + rladjsl】
      RL.ARJE           := 0; --生成帐体后计算,先初始化
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
      RL.ARPRIMCODE     := MI.SBPRIID; --记录合收子表串
      RL.ARPRIFLAG      := MI.SBPRIFLAG;
      RL.ARRPER         := MR.CBMRRPER;
      RL.ARSCODECHAR    := MR.CBMRSCODE;
      RL.ARECODECHAR    := MR.CBMRECODE;
      RL.ARGROUP        := '1'; --应收帐分组
      RL.ARPID          := NULL; --实收流水（与payment.pid对应）
      RL.ARPBATCH       := NULL; --缴费交易批次（与payment.pbatch对应）
      RL.ARSAVINGQC     := 0; --期初预存（销帐时产生）
      RL.ARSAVINGBQ     := 0; --本期预存发生（销帐时产生）
      RL.ARSAVINGQM     := 0; --期末预存（销帐时产生）
      RL.ARREVERSEFLAG  := 'N'; --  冲正标志（n为正常，y为冲正）
      RL.ARBADFLAG      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
      RL.ARZNJREDUCFLAG := 'N'; --滞纳金减免标志,未减免时为n，销帐时滞纳金直接计算；减免后为y,销帐时滞纳金直接取rlznj
      RL.ARSXF          := 0; --手续费
      RL.ARMIFACE2      := MI.SBFACE2; --抄见故障
      RL.ARMIFACE3      := MI.SBFACE3; --非常计量
      RL.ARMIFACE4      := MI.SBFACE4; --表井设施说明
      RL.ARMIIFCKF      := MI.SBIFCHK; --垃圾费户数
      RL.ARMIGPS        := MI.SBGPS; --是否合票
      RL.ARMIQFH        := MI.SBQFH; --铅封号
      RL.ARMIBOX        := MI.SBBOX; --消防水价（增值税水价）
      RL.ARMINAME2      := MI.SBNAME2; --招牌名称(小区名）
      RL.ARMISEQNO      := MI.SBSEQNO; --户号（初始化时册号+序号）
      RL.ARSCRARID      := RL.ARID; --原应收帐流水
      RL.ARSCRARTRANS   := RL.ARTRANS; --原应收帐事务
      RL.ARSCRARMONTH   := RL.ARMONTH; --原应收帐月份
      RL.ARSCRARDATE    := RL.ARDATE; --原应收帐日期
    
      IF (MR.CBMRNEWFLAG = 'Y' AND (MR.ID = '?' OR P_TRANS = 'O')) THEN
        --应收追补勾选不计阶梯标志
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
          RL.ARPRIORJE := 0; --算费之前欠费
      END;
      RL.ARMISAVING := MI.SBSAVING; --算费时预存
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
      RL.ARCOLUMN5       := NULL; --上次应帐帐日期
      RL.ARCOLUMN9       := NULL; --上次应收帐流水
      RL.ARCOLUMN10      := NULL; --上次应收帐月份
      RL.ARCOLUMN11      := NULL; --上次应收帐事务
    END;
    --reclist↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
  
    --0、‘按归档价格系分段’或‘指定价格系’前置数据集准备
    IF P_PSCID IS NOT NULL THEN
      --指定价格系
      IF P_PSCID = 0 THEN
        SELECT MAX(PRICE_VER) INTO RL.ARMICOLUMN1 FROM BAS_PRICE_NAME;
      END IF;
      RLTAB := RL_TABLE(RL);
    ELSE
      --分段
      OPEN C_VER;
      FETCH C_VER
        INTO V_VERID, V_ODATE;
      IF C_VER%NOTFOUND OR C_VER%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '无法获取有效的价格系1');
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
          --插入算费临时分段包
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
      RAISE_APPLICATION_ERROR(ERRCODE, '无法获取有效的价格系2');
    END IF;
  
    --1、按价格体系（含归档价格）
    FOR I IN RLTAB.FIRST .. RLTAB.LAST LOOP
      RLVER := RLTAB(I);
      OPEN C_PMD(RLVER.ARMICOLUMN1, MI.SBID);
      FETCH C_PMD
        INTO PMD;
      --1.1、单一用水
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN
        --1.1.1、非特别单价
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
        --1.2、混合用水
      ELSE
        SELECT COUNT(GRPID)
          INTO MAXPMDID
          FROM (SELECT * FROM YS_YH_PRICEGROUP WHERE SBID = MI.SBID);
      
        V_PMDSL   := 0; --组分配水量
        PMNUM     := 0;
        V_PMDDBSL := RLVER.ARREADSL; --定比元水量
        TEMPSL    := RLVER.ARREADSL; --分配后剩余水量
      
        WHILE C_PMD%FOUND AND TEMPSL >= 0 LOOP
          PMNUM := PMNUM + 1;
          --拆分余量记入最后费上
          IF PMNUM = MAXPMDID THEN
            V_PMDSL := TEMPSL;
          ELSE
            IF PMD.GRPTYPE = '01' THEN
              --定比混合
              V_PMDSL := CEIL(PMD.GRPSCALE * V_PMDDBSL);
            ELSE
              --定量混合
              V_PMDSL := (CASE
                           WHEN TEMPSL >= TRUNC(PMD.GRPSCALE) THEN
                            TRUNC(PMD.GRPSCALE)
                           ELSE
                            TEMPSL
                         END);
              V_PMDDBSL := V_PMDDBSL - V_PMDSL;
            END IF;
          END IF;
        
          --此处按基本价格类别正常计费--------------------------
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
    --统一重算汇总应收水量、金额到总账上
    RL.ARREADSL := MR.CBMRSL; --还原
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
                              '无法生成应收帐务明细，可能无用水性质');
    END IF;
    IF P_COMMIT != 调试 THEN
      INSERT INTO YS_ZW_ARLIST VALUES RL;
    ELSE
      INSERT INTO YS_ZW_ARLIST_BUDGET VALUES RL;
      INSERT INTO YS_ZW_ARLIST_virtual VALUES RL;
    END IF;
    INSRD(RDTAB, P_COMMIT);
  
    CLOSE C_MI;
    CLOSE C_MD;
    CLOSE C_CI;
    --反馈应收水量水费到原始抄表记录
    MR.CBMRRECSL        := NVL(RL.ARSL, 0);
    MR.CBMRIFREC        := 'Y';
    MR.CBMRRECDATE      := RL.ARDATE;
    MR.CBMRPRIVILEGEPER := RL.ARID; --借字段记录rlid返回，供即时销帐20140507
  
    --为适应抄表录入中的账本小结，这里先初始化为0
    MR.CBMRRECJE01 := 0;
    MR.CBMRRECJE02 := 0;
    MR.CBMRRECJE03 := 0;
    MR.CBMRRECJE04 := 0;
    MR.CBMRRECSL   := 0;
    IF RDTAB IS NOT NULL THEN
      FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
        VRD := RDTAB(I);
        --反馈总金额到
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
  --费率明细计算步骤
  PROCEDURE COSTPIID(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                     P_MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                     P_SL       IN NUMBER,
                     PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                     PMD        IN YS_YH_PRICEGROUP%ROWTYPE,
                     RDTAB      IN OUT RD_TABLE,
                     P_CLASSCTL IN CHAR,
                     P_PSCID    IN NUMBER,
                     P_COMMIT   IN NUMBER) IS
    --p_classctl（Y：强制不使用阶梯计费方法；N：计算阶梯，如果是的话）
    RD        YS_ZW_ARDETAIL%ROWTYPE;
    I         INTEGER;
    V_MONTHS  NUMBER(10);
    N         NUMBER;
    M         NUMBER;
    TEMPADJSL NUMBER(10);
    VPDMETHOD BAS_PRICE_DETAIL.METHOD%TYPE;
    BF        YS_BAS_BOOK%ROWTYPE;
  BEGIN
  
    --不计阶梯控制不进入阶梯子过程，不产生1阶金额
    IF P_CLASSCTL = 'Y' AND PD.METHOD IN ('yjt', 'njt') THEN
      VPDMETHOD := 'dj';
    ELSE
      VPDMETHOD := PD.METHOD;
    END IF;
  
    BEGIN
      SELECT ROUND(MONTHS_BETWEEN(TRUNC(P_RL.ARRDATE, 'MM'),
                                  TRUNC(P_RL.ARPRDATE, 'MM')))
        INTO N --计费时段月数
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
    RD.ARDID         := P_RL.ARID; --流水号
    RD.ARDPMDID      := NVL(PMD.GRPID, 0); --混合用水分组
    RD.ARDPMDSCALE   := NVL(PMD.GRPSCALE, 1);
    RD.ARDPIID       := PD.PRICE_ITEM; --费用项目
    RD.ARDPFID       := PD.PRICE_NO; --费率
    RD.ARDPSCID      := PD.PRICE_VER; --费率明细方案
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
    RD.ARDMSMFID     := P_RL.MANAGE_NO; --营销公司
    RD.ARDMONTH      := P_RL.ARMONTH; --帐务月份
    RD.ARDMID        := P_RL.SBID; --水表编号
    RD.ARDPMDTYPE    := NVL(PMD.GRPTYPE, '01'); --混合类别
    RD.ARDPMDCOLUMN1 := PMD.GRPCOLUMN1; --备用字段1
  
    CASE VPDMETHOD
      WHEN '01' THEN
        --固定单价  默认方式，与抄量有关
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
          --插入明细包
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
        END;
      WHEN '02' THEN
        --固定金额，与抄量无关
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
          --插入明细包
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
          COSTSTEP_YEARhrb(P_RL,
                        P_SL,
                        0,
                        0,
                        0,
                        PD,
                        RDTAB,
                        P_CLASSCTL,
                        PMD,
                        P_PSCID);
        END;
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '不支持的计费方法' || VPDMETHOD);
    END CASE;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --月阶梯计费步骤
  PROCEDURE COSTSTEP_MON(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                         P_MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                         P_SL       IN NUMBER,
                         P_ADJSL    IN NUMBER,
                         P_ADJDJ    IN NUMBER,
                         PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                         RDTAB      IN OUT RD_TABLE,
                         P_CLASSCTL IN CHAR,
                         PMD        IN YS_YH_PRICEGROUP%ROWTYPE) IS
    --RD.ARDpiid；RD.ARDpfid；RD.ARDpscid为必要参数
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
    N            NUMBER(38, 12); --计费期数
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
  
    RD.ARDMSMFID  := P_RL.MANAGE_NO; --营销公司
    RD.ARDMONTH   := P_RL.ARMONTH; --帐务月份
    RD.ARDMID     := P_RL.SBID; --水表编号
    RD.ARDPMDTYPE := NVL(PMD.GRPTYPE, '01'); --混合类别
  
    TMPYSSL := P_SL; --阶梯累减应收水量余额
    TMPSL   := P_SL + P_ADJSL; --阶梯累减实收水量余额
  
    --判断数据是否满足收取阶梯的条件
    SELECT MI.* INTO MINFO FROM YS_YH_SBINFO MI WHERE MI.SBID = P_RL.SBID;
  
    --阶梯计费周期
    --间隔月(即每次计费按实际间隔月数计费)
    BEGIN
      SELECT ROUND(MONTHS_BETWEEN(TRUNC(P_RL.ARRDATE, 'MM'),
                                  TRUNC(P_RL.ARPRDATE, 'MM')))
        INTO N --计费时段月数
        FROM DUAL;
    
      IF N <= 0 OR N IS NULL THEN
        N := 1; --异常周期都算一个月阶梯
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
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
    END IF;
    WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
      -->=0保证0用水至少一条费用明细
      /*
      ┌───────────────────────────────────────────────────────────────────────────────────────────────┐
      │阶梯规则（户/人均用水量以同一地址的所有水表用水量之和为基础计算）                      │
      │1、家庭户籍人口在4人以下（含4人）的用水户，按户用水量划分阶梯式计量水价。                      │
      │2、家庭户籍人口在5人（含5人）以上的用水户，按人均用水量划分阶梯式计量水价。                    │
      └─────────┴───────────────────────┴───────────────────────────────────┴─────────────────────────┘
      */ --一阶止二阶起要求设置值相同，依此类推
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
                           PS.ADD_WATERQTY + LASTPSSLPERS)); --阶梯段止算量
      TMPSCODE     := PS.END_CODE;
      LASTPSSLPERS := GETMAX(P_RL.ARUSENUM - PS.PEOPLES, 0) *
                      PS.ADD_WATERQTY;
      --以上CEIL保持入，尽量拉款子阶梯段，让利与客户
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
      --插入明细包
      IF RDTAB IS NULL THEN
        RDTAB := RD_TABLE(RD);
      ELSE
        RDTAB.EXTEND;
        RDTAB(RDTAB.LAST) := RD;
      END IF;
      --累减后带入下一行游标
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
    --rd.ardpiid；rd.ardpfid；rd.ardpscid为必要参数
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
    N              NUMBER; --计费期数
    年累计已用水量 NUMBER;
    年累计应收水量 NUMBER;
    年累计实收水量 NUMBER;
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
  
    RD.ARDMSMFID  := P_RL.MANAGE_NO; --营销公司
    RD.ARDMONTH   := P_RL.ARMONTH; --帐务月份
    RD.ARDMID     := P_RL.SBID; --水表编号
    RD.ARDPMDTYPE := NVL(PMD.GRPTYPE, '01'); --混合类别
  
    TMPYSSL := P_SL; --阶梯累减应收水量余额
    TMPSL   := P_SL + P_ADJSL; --阶梯累减实收水量余额
  
    --判断数据是否满足收取阶梯的条件
    SELECT * INTO MI FROM YS_YH_SBINFO WHERE SBID = P_RL.SBID;
  
    --实时计算年累计已用水量
    年累计已用水量 := 实时计算年累计已用量(MI.SBID, TRUNC(SYSDATE, 'YYYY'));
    --计入本次用量
    年累计应收水量 := GETMAX(TO_NUMBER(NVL(年累计已用水量, 0)), 0) + TMPYSSL;
    年累计实收水量 := GETMAX(TO_NUMBER(NVL(年累计已用水量, 0)), 0) + TMPSL;
  
    OPEN C_PS;
    FETCH C_PS
      INTO PS;
    IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
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
                          PS.ADD_WATERQTY + LASTPSSLPERS; --阶梯段止算量
      TMPSCODE         := PS.END_CODE;
      LASTPSSLPERS     := GETMAX(P_RL.ARUSENUM - PS.PEOPLES, 0) *
                          PS.ADD_WATERQTY + LASTPSSLPERS;
      RD.ARDPMDCOLUMN1 := PS.START_CODE;
      RD.ARDPMDCOLUMN2 := PS.END_CODE;
      RD.ARDCLASS      := PS.STEP_CLASS;
    
      RD.ARDYSDJ := PS.PRICE;
      RD.ARDYSSL := CASE
                      WHEN P_CLASSCTL = 'Y' THEN
                       TMPYSSL
                      ELSE
                       CASE
                         WHEN 年累计应收水量 >= PS.START_CODE AND 年累计应收水量 <= PS.END_CODE THEN
                          年累计应收水量 -
                          GETMAX(TO_NUMBER(NVL(年累计已用水量, 0)), PS.START_CODE)
                         WHEN 年累计应收水量 > PS.END_CODE THEN
                          GETMAX(0,
                                 GETMIN(PS.END_CODE -
                                        TO_NUMBER(NVL(年累计已用水量, 0)),
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
                       WHEN 年累计实收水量 >= PS.START_CODE AND 年累计实收水量 <= PS.END_CODE THEN
                        年累计实收水量 -
                        GETMAX(TO_NUMBER(NVL(年累计已用水量, 0)), PS.START_CODE)
                       WHEN 年累计实收水量 > PS.END_CODE THEN
                        GETMAX(0,
                               GETMIN(PS.END_CODE - TO_NUMBER(NVL(年累计已用水量, 0)),
                                      PS.END_CODE - PS.START_CODE))
                       ELSE
                        0
                     END
                  END;
      RD.ARDJE := ROUND(RD.ARDDJ * RD.ARDSL, 2); --实收金额
    
      RD.ARDADJDJ := RD.ARDDJ - RD.ARDYSDJ;
      RD.ARDADJSL := RD.ARDSL - RD.ARDYSSL;
      RD.ARDADJJE := RD.ARDJE - RD.ARDYSJE;
    
      --插入明细包
      IF RDTAB IS NULL THEN
        RDTAB := RD_TABLE(RD);
      ELSE
        RDTAB.EXTEND;
        RDTAB(RDTAB.LAST) := RD;
      END IF;
      --汇总
      P_RL.ARJE := P_RL.ARJE + RD.ARDJE;
      P_RL.ARSL := P_RL.ARSL + (CASE
                     WHEN RD.ARDPIID = '01' THEN
                      RD.ARDSL
                     ELSE
                      0
                   END);
      --累减后带入下一行游标
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
  
  PROCEDURE COSTSTEP_YEARhrb(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                    P_SL       IN NUMBER,
                    P_ADJSL    IN NUMBER,
                    P_PMDID    IN NUMBER,
                    P_PMDSCALE IN NUMBER,
                    PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                    RDTAB      IN OUT RD_TABLE,
                    P_CLASSCTL IN CHAR,
                    PMD        YS_YH_PRICEGROUP%ROWTYPE,
                    PMONTH     IN VARCHAR2) IS
    --RD.ARDpiid；RD.ARDpfid；RD.ARDpscid为必要参数
    CURSOR C_PS IS
      SELECT id,
       hire_code,
       price_ver    pspscid,
       price_no     pspfid,
       price_item   pspiid,
       step_class   psclass,
       start_code   psscode,
       end_code     psecode,
       price        psprice,
       peoples,
       add_waterqty,
       add_price
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
   
    N              NUMBER; --计费期数
    年累计水量     NUMBER;
     MINFO         YS_YH_SBINFO%ROWTYPE;
    USENUM         NUMBER; --计费人口数
    v_bfid         ys_yh_sbinfo.book_no%type;
    V_DATE         date;
    V_DATEOLD      DATE;
    V_DATEjtq      date;
    v_monbet       number;
    v_yyyymm       varchar2(10);
    v_rljtmk       varchar2(1);
    bk             ys_bas_book%rowtype;
    v_RLSCRRLMONTH YS_ZW_ARLIST.ARMONTH%type;
    v_rlmonth      YS_ZW_ARLIST.ARMONTH%type;
    v_RLJTSRQ      YS_ZW_ARLIST.ARJTSRQ%type;
    v_RLJTSRQold   YS_ZW_ARLIST.ARJTSRQ%type;
    v_jgyf         number;
    v_jtny         number;
    v_newmk        CHAR(1);
    V_jtqzny       YS_ZW_ARLIST.ARJTSRQ%type;
    v_betweenny    number;

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
  
    RD.ARDMSMFID  := P_RL.MANAGE_NO; --营销公司
    RD.ARDMONTH   := P_RL.ARMONTH; --帐务月份
    RD.ARDMID     := P_RL.SBID; --水表编号
    RD.ARDPMDTYPE := NVL(PMD.GRPTYPE, '01'); --混合类别
  
    TMPYSSL := P_SL; --阶梯累减应收水量余额
    TMPSL   := P_SL + P_ADJSL; --阶梯累减实收水量余额 
    v_newmk := 'N';
    --取上次算费月份，以及阶梯开始月份
   select nvl(max(ARSCRARMONTH), 'a'), nvl(max(ARJTSRQ), 'a'),nvl(max(ARMONTH),'2015.12')
      into v_RLSCRRLMONTH, v_RLJTSRQold,v_rlmonth
      from YS_ZW_ARLIST
     where sbid = P_RL.Sbid
       and ARREVERSEFLAG = 'N';
    --第一次算费比进入阶梯

    SELECT * INTO bk FROM ys_bas_book WHERE BOOK_NO = P_RL.ARBFID;
    --判断数据是否满足收取阶梯的条件
    SELECT MI.* INTO MINFO FROM YS_YH_SBINFO MI WHERE MI.sbid = P_RL.sbid;
    --判断人口
    /*  USENUM := NVL(MINFO.MIUSENUM, 0);*/
    --取合收表人口最大表的用户数
    select nvl(max(SBUSENUM),0)
      into USENUM
      from YS_YH_SBINFO
     where SBPRIID = MINFO.SBPRIID;
    IF USENUM <= 5 THEN
      USENUM := 5;
    END IF;
    bk.BFJTSNY := nvl(bk.BFJTSNY, '01');
    bk.bfjtsny := TO_CHAR(TO_NUMBER(bk.bfjtsny), 'FM00');
    if substr(P_RL.Armonth, 6, 2) >= bk.bfjtsny then
      v_RLJTSRQ := substr(P_RL.Armonth, 1, 4) || '.' || bk.bfjtsny;
    else
      v_RLJTSRQ := substr(P_RL.Armonth, 1, 4) - 1 || '.' || bk.bfjtsny;
    end if;
    --新阶梯起止
    V_DATE := ADD_MONTHS(to_date(v_RLJTSRQ, 'yyyy.mm'), 12);
    if v_RLJTSRQold <> 'a' then
      --旧阶梯起止
      V_DATEOLD := ADD_MONTHS(to_date(v_RLJTSRQold, 'yyyy.mm'), 12);
    else
      V_DATEOLD := V_DATE;
    end if;
    --else
    V_DATEjtq := V_DATEOLD;
    --end if;
    --旧阶梯起止不等于新阶梯起止
    if V_DATEOLD <> V_DATE then

      v_betweenny := MONTHS_BETWEEN(V_DATE, V_DATEOLD);
      if substr(v_RLJTSRQ, 1, 4) <> to_char(V_DATEOLD, 'yyyy') then
        IF v_RLJTSRQ < to_char(V_DATEOLD, 'yyyy.MM') THEN
          IF v_RLJTSRQ = P_RL.Armonth THEN
            P_RL.ARJTMK  := 'Y';
            P_RL.ARjtsrq := v_RLJTSRQ;
          ELSE
            P_RL.ARjtsrq := v_RLJTSRQold;
            V_jtqzny     := v_RLJTSRQold;
          END IF;
        ELSE
          P_RL.ARJTMK  := 'Y';
          P_RL.ARjtsrq := v_RLJTSRQ;
        END IF;

      else

        if mod(v_betweenny, 12) = 0 then
          --跨年的情况
          if v_betweenny / 12 > 1 then
            P_RL.ARJTMK  := 'Y';
            P_RL.ARjtsrq := v_RLJTSRQ;
          else

            P_RL.ARjtsrq := v_RLJTSRQ;
            V_jtqzny     := v_RLJTSRQold;
          end if;
        elsif v_betweenny < 12 then
          if P_RL.Armonth = v_RLJTSRQ then
            P_RL.ARjtsrq := v_RLJTSRQ;
            V_jtqzny     := v_RLJTSRQold;
          elsif P_RL.Armonth < v_RLJTSRQ then
            P_RL.ARjtsrq := v_RLJTSRQold;
            V_jtqzny     := v_RLJTSRQold;
          else
            P_RL.ARjtsrq := v_RLJTSRQ;
            V_jtqzny     := v_RLJTSRQold;
          end if;
          V_DATEjtq := to_date(v_RLJTSRQ, 'yyyy.mm');
        elsif v_betweenny > 12 then
          if P_RL.Armonth = v_RLJTSRQ then
            if substr(P_RL.Armonth, 1, 4) = substr(v_RLSCRRLMONTH, 1, 4) then
              --if substr(P_RL.Armonth, 1, 4) = substr(v_RLJTSRQold, 1, 4) then
              P_RL.ARjtsrq := v_RLJTSRQ;
              P_RL.ARJTMK  := 'Y';
            else
              P_RL.ARjtsrq := v_RLJTSRQ;
              v_newmk      := 'Y';
              V_jtqzny     := v_RLJTSRQold;
            end if;
          else
            if P_RL.Armonth = v_RLJTSRQold then
              P_RL.ARjtsrq := to_char(V_DATEOLD, 'yyyy.mm');
              V_jtqzny     := v_RLJTSRQold;
            else
              P_RL.ARjtsrq := v_RLJTSRQold;
              V_jtqzny     := v_RLJTSRQold;
            end if;
          end if;
        end if;

        /*elsif v_betweenny > 12 then
        if P_RL.Armonth = to_char(V_DATE , 'yyyy.mm') then
           if substr(P_RL.Armonth,1,4) =
        else
        end if;*/
        /*end if;
        end if;*/
      end if;
      --P_RL.ARjtsrq := v_RLJTSRQ;
    else
      if P_RL.Armonth = v_RLJTSRQ then
        V_jtqzny := substr(P_RL.Armonth, 1, 4) - 1 || '.' || bk.bfjtsny;
      else
        V_jtqzny := v_RLJTSRQ;
      end if;
      P_RL.ARjtsrq := v_RLJTSRQ;

    end if;
    /* if v_RLJTSRQ > v_RLJTSRQold then
      if P_RL.Armonth = v_RLJTSRQ then
        P_RL.ARjtsrq := v_RLJTSRQ;

      else
        if P_RL.Armonth < to_char(V_DATE, 'yyyy.mm') then
          P_RL.ARJTMK := 'Y';
        else
          v_newmk := 'Y';
        end if;
        --V_jtqzny := v_RLJTSRQ;
      end if;
      V_jtqzny     := v_RLJTSRQold;
      P_RL.ARjtsrq := v_RLJTSRQ;
    else
      P_RL.ARjtsrq := v_RLJTSRQ;
      V_jtqzny     := v_RLJTSRQ;
    end if;*/
    --取日期
   /* SELECT nvl(MONTHS_BETWEEN(V_DATE, TRUNC(MAX(CCHSHDATE), 'MM')), 99) + 1,
           to_char(TRUNC(MAX(CCHSHDATE), 'MM'), 'yyyy.mm')
      into v_monbet, v_yyyymm
      FROM CUSTCHANGEHD, CUSTCHANGEDTHIS, CUSTCHANGEDT
     WHERE CUSTCHANGEHD.CCHNO = CUSTCHANGEDTHIS.CCDNO
       AND CUSTCHANGEHD.CCHNO = CUSTCHANGEDT.CCDNO
       AND CUSTCHANGEDTHIS.CCDROWNO = CUSTCHANGEDT.CCDROWNO
       AND CUSTCHANGEHD.CCHLB in ('D')
       and CUSTCHANGEDTHIS.MIID = P_RL.ARmid;*/
     select nvl(MONTHS_BETWEEN(V_DATE, TRUNC(MAX(add_date), 'MM')), 99) + 1,
           to_char(TRUNC(MAX(add_date), 'MM'), 'yyyy.mm')
      into v_monbet, v_yyyymm 
      from ys_gd_yhsbmodifyd d ,ys_gd_yhsbmodifyt t 
      where d.bill_id = t.bill_id
      and d.bill_type = 'GH'
      and t.sbid = P_RL.sbid;
    if v_monbet = 100 or v_yyyymm <= V_jtqzny then

      v_yyyymm := V_jtqzny;
    else
      v_yyyymm := v_yyyymm;
    end if;
    v_monbet := 12;
    -- 第一次算费不进入阶梯
    --by wlj 20170321  2016年1月起（含一月）首次抄表不计入阶梯
    IF P_RL.ARJTMK = 'Y' or v_RLSCRRLMONTH = 'a' or P_RL.ARtrans in('14', '21') or v_rlmonth <='2015.12' then
      v_rljtmk := 'Y';
    ELSE
      v_rljtmk := 'N';
    END IF;
    --没有跨阶梯年月程序处理
    if V_DATEOLD >= to_date(P_RL.Armonth, 'yyyy.mm') or v_rljtmk = 'Y' then
       select nvl(sum(ARDSL), 0)
        into P_RL.ARCOLUMN12
        from YS_ZW_ARLIST t , ys_zw_ardetail,ys_yh_sbinfo o
       where ARID = ARDID
         and t.sbid = o.sbid
         AND NVL(arjtmk, 'N') = 'N'
         and ARSCRARTRANS not in ('14', '21')
         and ARDPMDCOLUMN3 = substr(V_jtqzny, 1, 4)
         and ARDPIID = '01'
         and ARDMETHOD = '04'
         and ARSCRARMONTH <= P_RL.Armonth
         and ARSCRARMONTH > v_yyyymm
         and SBPRIID = MINFO.SBPRIID;
        /* and rlmid in
             (select miid from meterinfo where mipriid = MINFO.Mipriid);*/
      /*select nvl(sum(rdsl), 0)
        into P_RL.ARCOLUMN12
        from reclist, recdetail
       where rlid = rdid
         AND NVL(rljtmk, 'N') = 'N'
         and RLSCRRLTRANS not in ('14', '21')
         and RDPMDCOLUMN3 = substr(V_jtqzny, 1, 4)
         and rdpiid = '01'
         and rdmethod = 'sl3'
         and rlmonth <= P_RL.Armonth
         and rlmonth > v_yyyymm
         and rlmid in
             (select miid from meterinfo where mipriid = MINFO.Mipriid);*/
      RD.ARDPMDCOLUMN3 := substr(V_jtqzny, 1, 4);
      年累计水量      := GETMAX(to_number(nvl(P_RL.ARCOLUMN12, 0)), 0) + P_SL;
        OPEN C_PS;
        FETCH C_PS
          INTO PS;
        IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
        END IF;
        WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --居民水费阶梯数量跟户籍人数有关
          -- if nvl(P_RL.ARusenum, 0) >= 4 then
          IF ps.start_code = 0 THEN
            ps.start_code := 0;
          ELSE
            ps.start_code := round((ps.start_code + 30 * (USENUM - 5)) /** v_monbet / 12*/);
          END IF;
          ps.start_code := round((ps.start_code + 30 * (USENUM - 5)) /** v_monbet / 12*/);

          -- end if;
          --RD.ARDPMDCOLUMN1 := ps.start_code; --银川阶梯段起算量
          --RD.ARDPMDCOLUMN2 := ps.start_code; --银川阶梯段止算量
          RD.ARDCLASS := ps.step_class;
          RD.ARDYSDJ  := ps.price;
          RD.ARDYSSL := case
                         when v_rljtmk = 'Y' then
                          TMPYSSL
                         else
                          case
                            when 年累计水量 >= ps.start_code and 年累计水量 <= ps.start_code then
                             年累计水量 - GETMAX(to_number(nvl(P_RL.ARCOLUMN12, 0)),
                                                  ps.start_code)
                            when 年累计水量 >= ps.start_code then
                             GETMAX(0,
                                          GETMIN(ps.start_code -
                                                       to_number(nvl(P_RL.ARCOLUMN12, 0)),
                                                       ps.start_code - ps.start_code))
                            else
                             0
                          end
                       end;
          RD.ARDYSJE  := RD.ARDYSDJ * RD.ARDYSSL;
          RD.ARDDJ    := ps.price;
          RD.ARDSL := case
                       when v_rljtmk = 'Y' then
                        TMPSL
                       else
                        case
                          when 年累计水量 >= ps.start_code and 年累计水量 <= ps.start_code then
                           年累计水量 -
                           GETMAX(to_number(nvl(P_RL.ARCOLUMN12, 0)), ps.start_code)
                          when 年累计水量 > ps.start_code then
                           GETMAX(0,
                                        GETMIN(ps.start_code -
                                                     to_number(nvl(P_RL.ARCOLUMN12, 0)),
                                                     ps.start_code - ps.start_code))
                          else
                           0
                        end
                     end;
          RD.ARDJE    := RD.ARDDJ * RD.ARDSL;
          RD.ARDADJDJ := 0;
          RD.ARDADJSL := RD.ARDSL - RD.ARDYSSL;
          RD.ARDADJJE := 0;
          if v_rljtmk <> 'Y' then
            /*if 年累计水量 >= ps.start_code and 年累计水量 <= ps.start_code then
               RD.ARDPMDCOLUMN1 := ps.start_code - 年累计水量;
            else*/
            RD.ARDPMDCOLUMN1 := ps.start_code - ps.start_code;
            if 年累计水量 >= ps.start_code and 年累计水量 <= ps.start_code then
              RD.ARDPMDCOLUMN2 := 年累计水量 - ps.start_code;
            elsif 年累计水量 > ps.start_code then
              RD.ARDPMDCOLUMN2 := ps.start_code - ps.start_code;
            else
              RD.ARDPMDCOLUMN2 := 0;
            end if;
            --end if;
          end if;

          if RD.ARDSL > 0 then
            IF RDTAB IS NULL THEN
              RDTAB := RD_TABLE(RD);
            ELSE
              RDTAB.EXTEND;
              RDTAB(RDTAB.LAST) := RD;
            END IF;
          END IF;
          --汇总
          P_RL.ARJE := P_RL.ARJE + RD.ARDJE;
          P_RL.ARSL := P_RL.ARSL + (CASE
                         WHEN RD.ARDPIID = '01' THEN
                          RD.ARDSL
                         ELSE
                          0
                       END);
          --累减后带入下一行游标
          --TMPYSSL := GETMAX(TMPYSSL - RD.ARDYSSL, 0);
          --TMPSL   := GETMAX(TMPSL - RD.ARDSL, 0);

          TMPYSSL := GETMAX(TMPYSSL - RD.ARDYSSL, 0);
          TMPSL   := GETMAX(TMPSL - RD.ARDSL, 0);

          EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
          FETCH C_PS
            INTO PS;
        END LOOP;
        CLOSE C_PS;
      

    else
      --跨年，需要按用水月份比例拆分
      v_jgyf := MONTHS_BETWEEN(to_date(P_RL.Armonth, 'yyyy.mm'), V_DATEOLD);
      v_jtny := MONTHS_BETWEEN(to_date(P_RL.Armonth, 'yyyy.mm'),
                               to_date(v_RLSCRRLMONTH, 'yyyy.mm'));
      if v_jgyf / v_jtny  > 1 then
        v_jtny := v_jgyf;
      end if;
      if v_jgyf > 12 then
        TMPYSSL  := P_SL;
        TMPSL    := P_SL;
        v_rljtmk := 'Y';
      else
        TMPYSSL := P_SL - round(P_SL * v_jgyf / v_jtny); --阶梯累减应收水量余额
        TMPSL   := P_SL - round(P_SL * v_jgyf / v_jtny); --阶梯累减实收水量余额
      end if;
      RD.ARDPSCID := -1;
      if v_rljtmk = 'Y' then
        P_RL.ARCOLUMN12 := 0;
      else
         select nvl(sum(ARDSL), 0)
        into P_RL.ARCOLUMN12
        from YS_ZW_ARLIST t , ys_zw_ardetail,ys_yh_sbinfo o
       where ARID = ARDID
         and t.sbid = o.sbid
         AND NVL(arjtmk, 'N') = 'N'
         and ARSCRARTRANS not in ('14', '21')
         and ARDPMDCOLUMN3 = substr(v_RLJTSRQold, 1, 4)
         and ARDPIID = '01'
         and ARDMETHOD = '04'
         and ARSCRARMONTH <= P_RL.Armonth
         and ARSCRARMONTH > v_yyyymm
         and SBPRIID = MINFO.SBPRIID;
     /*   select nvl(sum(rdsl), 0)
          into P_RL.ARCOLUMN12
          from reclist, recdetail
         where rlid = rdid
           AND NVL(rljtmk, 'N') = 'N'
           and RLSCRRLTRANS not in ('14', '21')
           and RDPMDCOLUMN3 = substr(v_RLJTSRQold, 1, 4)
           and rdpiid = '01'
           and rdmethod = 'sl3'
           and RLSCRRLMONTH <= P_RL.Armonth
           and RLSCRRLMONTH > v_yyyymm
           and rlmid in
               (select miid from meterinfo where mipriid = MINFO.Mipriid);*/
      end if;
      RD.ARDPMDCOLUMN3 := substr(v_RLJTSRQold, 1, 4);
      年累计水量      := GETMAX(to_number(nvl(P_RL.ARCOLUMN12, 0)), 0) +
                    (P_SL - round(P_SL * v_jgyf / v_jtny));
      --计算去年的阶梯
       
        OPEN C_PS;
        FETCH C_PS
          INTO PS;
        IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
        END IF;
        WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --居民水费阶梯数量跟户籍人数有关
          -- if nvl(P_RL.ARusenum, 0) >= 4 then
          IF ps.start_code = 0 THEN
            ps.start_code := 0;
          ELSE
            ps.start_code := round((ps.start_code + 30 * (USENUM - 5)) /** v_monbet / 12*/);
          END IF;
          ps.start_code := round((ps.start_code + 30 * (USENUM - 5)) /** v_monbet / 12*/);

          -- end if;
          --RD.ARDPMDCOLUMN1 := ps.start_code; --银川阶梯段起算量
          --RD.ARDPMDCOLUMN2 := ps.start_code; --银川阶梯段止算量
          RD.ARDCLASS := ps.step_class;
          RD.ARDYSDJ  := ps.price;
          RD.ARDYSSL := case
                         when v_rljtmk = 'Y' then
                          TMPYSSL
                         else
                          case
                            when 年累计水量 >= ps.start_code and 年累计水量 <= ps.start_code then
                             年累计水量 - GETMAX(to_number(nvl(P_RL.ARCOLUMN12, 0)),
                                                  ps.start_code)
                            when 年累计水量 > ps.start_code then
                             GETMAX(0,
                                          GETMIN(ps.start_code -
                                                       to_number(nvl(P_RL.ARCOLUMN12, 0)),
                                                       ps.start_code - ps.start_code))
                            else
                             0
                          end
                       end;
          RD.ARDYSJE  := RD.ARDYSDJ * RD.ARDYSSL;
          RD.ARDDJ    := ps.price;
          RD.ARDSL := case
                       when v_rljtmk = 'Y' then
                        TMPSL
                       else
                        case
                          when 年累计水量 >= ps.start_code and 年累计水量 <= ps.start_code then
                           年累计水量 -
                           GETMAX(to_number(nvl(P_RL.ARCOLUMN12, 0)), ps.start_code)
                          when 年累计水量 > ps.start_code then
                           GETMAX(0,
                                        GETMIN(ps.start_code -
                                                     to_number(nvl(P_RL.ARCOLUMN12, 0)),
                                                     ps.start_code - ps.start_code))
                          else
                           0
                        end
                     end;
          RD.ARDJE    := RD.ARDDJ * RD.ARDSL;
          RD.ARDADJDJ := 0;
          RD.ARDADJSL := RD.ARDSL - RD.ARDYSSL;
          RD.ARDADJJE := 0;
          if v_rljtmk <> 'Y' then
            /*if 年累计水量 >= ps.start_code and 年累计水量 <= ps.start_code then
               RD.ARDPMDCOLUMN1 := ps.start_code - 年累计水量;
            else*/
            RD.ARDPMDCOLUMN1 := ps.start_code - ps.start_code;
            if 年累计水量 >= ps.start_code and 年累计水量 <= ps.start_code then
              RD.ARDPMDCOLUMN2 := 年累计水量 - ps.start_code;
            elsif 年累计水量 > ps.start_code then
              RD.ARDPMDCOLUMN2 := ps.start_code - ps.start_code;
            else
              RD.ARDPMDCOLUMN2 := 0;
            end if;
            --end if;
          end if;

          if RD.ARDSL > 0 then
            IF RDTAB IS NULL THEN
              RDTAB := RD_TABLE(RD);
            ELSE
              RDTAB.EXTEND;
              RDTAB(RDTAB.LAST) := RD;
            END IF;
          END IF;
          --汇总
          P_RL.ARJE := P_RL.ARJE + RD.ARDJE;
          P_RL.ARSL := P_RL.ARSL + (CASE
                         WHEN RD.ARDPIID = '01' THEN
                          RD.ARDSL
                         ELSE
                          0
                       END);
          --累减后带入下一行游标
          --TMPYSSL := GETMAX(TMPYSSL - RD.ARDYSSL, 0);
          --TMPSL   := GETMAX(TMPSL - RD.ARDSL, 0);

          TMPYSSL := GETMAX(TMPYSSL - RD.ARDYSSL, 0);
          TMPSL   := GETMAX(TMPSL - RD.ARDSL, 0);

          EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
          FETCH C_PS
            INTO PS;
        END LOOP;
        CLOSE C_PS;
       

      if v_jgyf <= 12 then
        IF v_newmk = 'Y' THEN
          v_rljtmk := 'Y';
        END IF;
        RD.ARDPSCID := PD.PRICE_VER;
        TMPYSSL    := round(P_SL * (v_jgyf / v_jtny)); --阶梯累减应收水量余额
        TMPSL      := round(P_SL * (v_jgyf / v_jtny)); --阶梯累减实收水量余额
       select nvl(sum(ARDSL), 0)
        into P_RL.ARCOLUMN12
        from YS_ZW_ARLIST t , ys_zw_ardetail,ys_yh_sbinfo o
       where ARID = ARDID
         and t.sbid = o.sbid
         AND NVL(arjtmk, 'N') = 'N'
         and ARSCRARTRANS not in ('14', '21')
         and ARDPMDCOLUMN3 = substr(P_RL.Armonth, 1, 4)
         and ARDPIID = '01'
         and ARDMETHOD = '04'
         and ARSCRARMONTH <= P_RL.Armonth
         and ARSCRARMONTH > v_yyyymm
         and SBPRIID = MINFO.SBPRIID;
        /*select nvl(sum(rdsl), 0)
          into P_RL.ARCOLUMN12
          from reclist, recdetail
         where rlid = rdid
           AND NVL(rljtmk, 'N') = 'N'
           and RLSCRRLTRANS not in ('14', '21')
           and RDPMDCOLUMN3 = substr(P_RL.Armonth, 1, 4)
           and rdpiid = '01'
           and rdmethod = 'sl3'
           and RLSCRRLMONTH <= P_RL.Armonth
           and RLSCRRLMONTH > v_yyyymm
           and rlmid in
               (select miid from meterinfo where mipriid = MINFO.Mipriid);*/
        RD.ARDPMDCOLUMN3 := substr(P_RL.Armonth, 1, 4);
        年累计水量      := GETMAX(to_number(nvl(P_RL.ARCOLUMN12, 0)), 0) +
                      (round(P_SL * v_jgyf / v_jtny));
        --计算去年的阶梯
        --IF PMONTH = '0000.00' OR PMONTH IS NULL or PMONTH = '指定' THEN
          OPEN C_PS;
          FETCH C_PS
            INTO PS;
          IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
          END IF;
          WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
            --居民水费阶梯数量跟户籍人数有关
            -- if nvl(P_RL.ARusenum, 0) >= 4 then
            IF ps.start_code = 0 THEN
              ps.start_code := 0;
            ELSE
              ps.start_code := round((ps.start_code + 30 * (USENUM - 5)) /** v_monbet / 12*/);
            END IF;
            ps.start_code := round((ps.start_code + 30 * (USENUM - 5)) /** v_monbet / 12*/);

            -- end if;
            --RD.ARDPMDCOLUMN1 := ps.start_code; --银川阶梯段起算量
            --RD.ARDPMDCOLUMN2 := ps.start_code; --银川阶梯段止算量
            RD.ARDCLASS := ps.step_class;
            RD.ARDYSDJ  := ps.price;
            RD.ARDYSSL := case
                           when v_rljtmk = 'Y' then
                            TMPYSSL
                           else
                            case
                              when 年累计水量 >= ps.start_code and 年累计水量 <= ps.start_code then
                               年累计水量 - GETMAX(to_number(nvl(P_RL.ARCOLUMN12, 0)),
                                                    ps.start_code)
                              when 年累计水量 > ps.start_code then
                               GETMAX(0,
                                            GETMIN(ps.start_code -
                                                         to_number(nvl(P_RL.ARCOLUMN12, 0)),
                                                         ps.start_code - ps.start_code))
                              else
                               0
                            end
                         end;
            RD.ARDYSJE  := RD.ARDYSDJ * RD.ARDYSSL;
            RD.ARDDJ    := ps.price;
            RD.ARDSL := case
                         when v_rljtmk = 'Y' then
                          TMPSL
                         else
                          case
                            when 年累计水量 >= ps.start_code and 年累计水量 <= ps.start_code then
                             年累计水量 -
                             GETMAX(to_number(nvl(P_RL.ARCOLUMN12, 0)), ps.start_code)
                            when 年累计水量 > ps.start_code then
                             GETMAX(0,
                                          GETMIN(ps.start_code -
                                                       to_number(nvl(P_RL.ARCOLUMN12, 0)),
                                                       ps.start_code - ps.start_code))
                            else
                             0
                          end
                       end;
            RD.ARDJE    := RD.ARDDJ * RD.ARDSL;
            RD.ARDADJDJ := 0;
            RD.ARDADJSL := RD.ARDSL - RD.ARDYSSL;
            RD.ARDADJJE := 0;
            if v_rljtmk <> 'Y' then
              /*if 年累计水量 >= ps.start_code and 年累计水量 <= ps.start_code then
                 RD.ARDPMDCOLUMN1 := ps.start_code - 年累计水量;
              else*/
              RD.ARDPMDCOLUMN1 := ps.start_code - ps.start_code;
              if 年累计水量 >= ps.start_code and 年累计水量 <= ps.start_code then
                RD.ARDPMDCOLUMN2 := 年累计水量 - ps.start_code;
              elsif 年累计水量 > ps.start_code then
                RD.ARDPMDCOLUMN2 := ps.start_code - ps.start_code;
              else
                RD.ARDPMDCOLUMN2 := 0;
              end if;
              --end if;
            end if;

            if RD.ARDSL > 0 then
              IF RDTAB IS NULL THEN
                RDTAB := RD_TABLE(RD);
              ELSE
                RDTAB.EXTEND;
                RDTAB(RDTAB.LAST) := RD;
              END IF;
            END IF;
            --汇总
            P_RL.ARJE := P_RL.ARJE + RD.ARDJE;
            P_RL.ARSL := P_RL.ARSL + (CASE
                           WHEN RD.ARDPIID = '01' THEN
                            RD.ARDSL
                           ELSE
                            0
                         END);
            --累减后带入下一行游标
            --TMPYSSL := GETMAX(TMPYSSL - RD.ARDYSSL, 0);
            --TMPSL   := GETMAX(TMPSL - RD.ARDSL, 0);

            TMPYSSL := GETMAX(TMPYSSL - RD.ARDYSSL, 0);
            TMPSL   := GETMAX(TMPSL - RD.ARDSL, 0);

            EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
            FETCH C_PS
              INTO PS;
          END LOOP;
          CLOSE C_PS;
        
      end if;
    end if;

    /* --累计年阶梯
    select nvl(sum(rdsl), 0)
      into P_RL.ARCOLUMN12
      from reclist, recdetail
     where rlid = rdid
       AND NVL(rljtmk, 'N') = 'N'
       and rdpiid = '01'
       and rdmethod = 'sl3'
       and rlmonth >= v_yyyymm
       and rlmid = P_RL.ARmid;*/

    if v_rljtmk = 'N' then
      P_RL.ARCOLUMN12 := 年累计水量;
    ELSE
      P_RL.ARJTMK := 'Y';
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_PS%ISOPEN THEN
        CLOSE C_PS;
      END IF;
      
    
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  
  
  PROCEDURE INSRD(RD IN RD_TABLE, P_COMMIT IN NUMBER) IS
    VRD YS_ZW_ARDETAIL%ROWTYPE;
    I   NUMBER;
  BEGIN
    FOR I IN RD.FIRST .. RD.LAST LOOP
      VRD := RD(I);
      IF P_COMMIT != 调试 THEN
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
    --一维数组规则：#####,####,####|
    --二维数组规则：#####,####,####|#####,####,#######|##,####,####|
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
    --一维数组规则：#####|####|####|
    --二维数组规则：#####,####,####|#####,####,#######|##,####,####|
    VCHAR NCHAR(1);
    V     VARCHAR2(10000);
    VSTR  VARCHAR2(10000) := '';
    R     INTEGER := 1;
    C     INTEGER := 0;
  BEGIN
    V := TRIM(P_PARASTR);
    IF LENGTH(V) = 0 OR SUBSTR(V, LENGTH(V)) != '|' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '数组字符串格式错误' || P_PARASTR);
    END IF;
    FOR I IN 1 .. LENGTH(V) LOOP
      VCHAR := SUBSTR(V, I, 1);
      CASE VCHAR
        WHEN '|' THEN
          --一行读完
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
          --一列读完
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
  --预算费，提供追补、应收调整、退费单据中重算费中间数据
 PROCEDURE SUBMIT_VIRTUAL(p_mid    in varchar2,
                           p_PRICE_VER  IN  VARCHAR2,
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
    cb Ys_Cb_Mtread%ROWTYPE; --抄表历史库
    mi ys_yh_sbinfo%rowtype;
  BEGIN
    delete ys_zw_arlist_virtual;
    delete ys_zw_ardetail_virtual;
    BEGIN
      select * into mi from ys_yh_sbinfo where SBID = p_mid; 
      cb.id            := '?'; --varchar2(10)  流水号 
      cb.CBMRMONTH         := to_char(p_rdate, 'yyyy.mm'); --varchar2(7)  抄表月份
      cb.MANAGE_NO         := mi.MANAGE_NO; --varchar2(10)  营销公司
      cb.BOOK_NO          := mi.BOOK_NO; --varchar2(10)  表册 
      cb.cbmrbatch         := null; --number(20)  抄表批次
      cb.cbmrday           := null; --date  计划抄表日
      cb.cbmrrorder        := null; --number(10)  抄表次序
      cb.YHID           := p_mid; --varchar2(10)  用户编号 
      cb.SBID           := p_mid; --varchar2(10)  水表编号 
      cb.TRADE_NO          := null; --varchar2(10)  行业分类
      cb.SBPID          := null; --varchar2(10)  上级水表
      cb.CBMRMCLASS        := null; --number  水表级次
      cb.cbmrmflag         := null; --char(1)  末级标志
      cb.cbmrcreadate      := p_rdate; --date  创建日期
      cb.cbmrinputdate     := p_rdate; --date  编辑日期
      cb.cbmrreadok        := 'Y'; --char(1)  抄见标志
      cb.cbmrrdate         := p_rdate; --date  抄表日期
      cb.cbmrrper          := p_rper; --varchar2(15)  抄表员
      cb.cbmrprdate        := p_prdate; --date  上次抄见日期
      cb.cbmrscode         := p_scode; --number(10)  上期抄见
      cb.cbmrecode         := p_ecode; --number(10)  本期抄见
      cb.cbmrsl            := p_sl; --number(10)  本期水量
      cb.cbmrface          := null; --varchar2(2)  水表故障
      cb.cbmrifsubmit      := 'Y'; --char(1)  是否提交计费
      cb.cbmrifhalt        := null; --char(1)  系统停算
      cb.cbmrdatasource    := null; --char(1)  抄表结果来源
      cb.cbmrifignoreminsl := null; --char(1)  停算最低抄量
      cb.cbmrpdardate      := null; --date  抄表机抄表时间
      cb.cbmroutflag       := null; --char(1)  发出到抄表机标志
      cb.cbmroutid         := null; --varchar2(10)  发出到抄表机流水号
      cb.cbmroutdate       := null; --date  发出到抄表机日期
      cb.cbmrinorder       := null; --number(4)  抄表机接收次序
      cb.cbmrindate        := null; --date  抄表机接受日期
      cb.cbmrrpid          := null; --varchar2(3)  计件类型
      cb.cbmrmemo          := null; --varchar2(120)  抄表备注
      cb.cbmrifgu          := null; --char(1)  估表标志
      cb.cbmrifrec         := null; --char(1)  已计费
      cb.cbmrrecdate       := null; --date  计费日期
      cb.cbmrrecsl         := p_sl; --number(10)  应收水量
      cb.cbmraddsl         := null; --number(10)  余量
      cb.cbmrcarrysl       := null; --number(10)  校验水量
      cb.cbmrctrl1         := null; --varchar2(10)  抄表机控制位1
      cb.cbmrctrl2         := null; --varchar2(10)  抄表机控制位2
      cb.cbmrctrl3         := null; --varchar2(10)  抄表机控制位3
      cb.cbmrctrl4         := null; --varchar2(10)  抄表机控制位4
      cb.cbmrctrl5         := null; --varchar2(10)  换表单据号
      cb.cbmrchkflag       := null; --char(1)  复核标志
      cb.cbmrchkdate       := null; --date  复核日期
      cb.cbmrchkper        := null; --varchar2(10)  复核人员
      cb.cbmrchkscode      := null; --number(10)  原起数
      cb.cbmrchkecode      := null; --number(10)  原止数
      cb.cbmrchksl         := null; --number(10)  原水量
      cb.cbmrchkaddsl      := null; --number(10)  原余量
      cb.cbmrchkcarrysl    := null; --number(10)  原进位水量
      cb.cbmrchkrdate      := null; --date  原抄见日期
      cb.cbmrchkface       := null; --varchar2(2)  原表况
      cb.cbmrchkresult     := null; --varchar2(100)  检查结果类型
      cb.cbmrchkresultmemo := null; --varchar2(100)  检查结果说明
      cb.cbmrprimid        := null; --varchar2(200)  合收表主表
      cb.cbmrprimflag      := null; --char(1)  合收表标志
      cb.cbmrlb            := null; --char(1)  水表类别
      cb.cbmrnewflag       := null; --char(1)  新表标志
      cb.cbmrface2         := null; --varchar2(2)  抄见故障
      cb.cbmrface3         := null; --varchar2(2)  非常计量
      cb.cbmrface4         := null; --varchar2(2)  表井设施说明
      cb.cbmrscodechar     := p_scode; --varchar2(10)  上期抄见
      cb.cbmrecodechar     := p_ecode; --varchar2(10)  本期抄见
      cb.cbmrprivilegeflag := null; --varchar2(1)  特权标志(y/n)
      cb.cbmrprivilegeper  := null; --varchar2(10)  特权操作人
      cb.cbmrprivilegememo := null; --varchar2(200)  特权操作备注
      cb.cbmrprivilegedate := null; --date  特权操作时间
      cb.AREA_NO         := null; --varchar2(10)  管理区域
      cb.cbmriftrans       := null; --char(1)  抄表事务
      cb.cbmrrequisition   := null; --number(2)  通知单打印次数
      cb.cbmrifchk         := null; --char(1)  考核表
      cb.cbmrinputper      := null; --varchar2(10)  入账人员
      cb.Price_No          := p_pfid; --varchar2(10)  用水类别
      cb.cbmrcaliber       := null; --number(10)  口径
      cb.cbmrside          := null; --varchar2(100)  表位
      cb.cbmrlastsl        := null; --number(10)  上次抄表水量
      cb.cbmrthreesl       := null; --number(10)  前三月抄表水量
      cb.cbmryearsl        := null; --number(10)  去年同期抄表水量
      cb.cbmrrecje01       := null; --number(13,3)  应收金额费用项目01
      cb.cbmrrecje02       := null; --number(13,3)  应收金额费用项目02
      cb.cbmrrecje03       := null; --number(13,3)  应收金额费用项目03
      cb.cbmrrecje04       := null; --number(13,3)  应收金额费用项目04
      cb.cbmrmtype         := null; --varchar2(10)  表型
      cb.cbmrnullcont      := null; --number(10)  连续几月未抄见
      cb.cbmrnulltotal     := null; --number(10)  累计几月未抄见
      cb.cbmrplansl        := null; --number(18,8)  计划水量
      cb.cbmrplanje01      := null; --number(18,8)  计划水费
      cb.cbmrplanje02      := null; --number(18,8)  计划污水处理费
      cb.cbmrplanje03      := null; --number(18,8)  计划水资源费
      cb.cbmrlastje01      := null; --number(13,3)  上次水费
      cb.cbmrthreeje01     := null; --number(13,3)  前n次均水费
      cb.cbmryearje01      := null; --number(13,3)  去年同期水费
      cb.cbmrlastje02      := null; --number(13,3)  上次污水费
      cb.cbmrthreeje02     := null; --number(13,3)  前n次均污水费
      cb.cbmryearje02      := null; --number(13,3)  去年同期污水费
      cb.cbmrlastje03      := null; --number(13,3)  上次水资源费
      cb.cbmrthreeje03     := null; --number(13,3)  前n次均水资源费
      cb.cbmryearje03      := null; --number(13,3)  去年同期水资源费
      cb.cbmrlastyearsl    := null; --number(10)  去年度次均量
      cb.cbmrlastyearje01  := null; --number(13,3)  去年度次均水费
      cb.cbmrlastyearje02  := null; --number(13,3)  去年度次均污水费
      cb.cbmrlastyearje03  := null; --number(13,3)  去年度次均水资源费  
      --
      COSTCULATECORE(cb, p_trans, p_PRICE_VER, 调试);
      --20150414 应收追补预算费支持历史水价算费
      --CALCULATE(cb, p_trans, to_char(p_rdate,'yyyy.mm'), 调试);

      o_rlid := cb.cbmrprivilegeper;
    EXCEPTION
      WHEN OTHERS THEN
        /*WLOG(p_mid || ',' || p_prdate || ',' || p_rdate || ',' || p_sl || ',' ||
             p_pfid || ',' || p_usenum || ',' || p_trans || '预算费失败2，已被忽略' ||
             sqlerrm);*/
              RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    END;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

 BEGIN
  总表截量     := 'Y';
  最低算费水量 := 0;
END;
/

