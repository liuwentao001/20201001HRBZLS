CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_METERREAD_01_2013" IS
  CALLOGTXT                 CLOB;
  水量精度                  INTEGER;
  总表截量                  CHAR(1);
  是否审批算费              CHAR(1);
  最低算费水量              NUMBER(10);
  垃圾费水量分水岭          NUMBER(10);
  垃圾费单价                NUMBER(12, 2);
  垃圾费大于分水岭水量收X元 NUMBER(12, 2);
  ----yujia  2012-03-20
  固定金额标志   CHAR(1);
  固定金额最低值 NUMBER(12, 2);
  版本号码       VARCHAR2(100);

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

  --外部调用，自动算费
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

  --外部调用，自动算费
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

  --单个用户客户代码算费
  PROCEDURE SUBMIT1(P_MICODE IN VARCHAR2, LOG OUT CLOB) IS

    VMRID METERREAD.MRID%TYPE;
  BEGIN
    CALLOGTXT := NULL;
    WLOG('提交算费，客户代码：' || P_MICODE);
    WLOG('正在算费客户代码号：' || P_MICODE || ' ...');

    SELECT MRID
      INTO VMRID
      FROM METERREAD, METERINFO
     WHERE MRMID = MIID
       AND MICODE = P_MICODE
       AND MRIFREC = 'N' --未计费
       --AND MRIFSUBMIT = 'Y'
          /******* 用途：是否算费的条件控制
                     时间：2011-11-10
                    修改人：刘光波
          *****/
       --AND MICLASS = 1
       --AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, '1') = 'Y'
       --AND MRIFHALT = 'N' --停算(系统指定)
       AND MRREADOK = 'Y' --抄见状态
     ORDER BY MICLASS DESC,
              (CASE
                WHEN MIPRIFLAG = 'Y' AND MIPRIID <> MICODE THEN
                 1
                ELSE
                 2
              END) ASC;
    --解锁前资源不能被更新并且不等待并抛出异常

    --单条抄表记录处理
    CALCULATE(VMRID);
    COMMIT;
    WLOG('算费过程处理完毕');
    WLOG('---------------------------------------------------');
    LOG := CALLOGTXT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      WLOG('抄表记录' || VMRID || '算费失败，已被忽略');
      LOG := CALLOGTXT;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --计划内抄表批量提交算费
  PROCEDURE SUBMIT(P_BFID IN VARCHAR2, LOG OUT CLOB) IS
    CURSOR C_MR(VBFID IN VARCHAR2, VSMFID IN VARCHAR2) IS
      SELECT MRID
        FROM METERREAD, METERINFO
       WHERE MRMID = MIID
         AND MRBFID = VBFID
         AND MRSMFID = VSMFID
         AND MRIFREC = 'N'
            /******* 用途：是否算费的条件控制
                       时间：2012-04-13
                      修改人：刘光波
            *****/
         --AND MICLASS = 1
         --AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, '1') = 'Y' --未计费
         --AND MRIFSUBMIT = 'Y' --允许计费(用户挂起)
         --AND MRIFHALT = 'N' --停算(系统指定)
         AND
             MRREADOK = 'Y' --抄见状态
         --AND MIIFCHARGE = 'Y' -- 是否算费
       ORDER BY MICLASS DESC,
                (CASE
                  WHEN MIPRIFLAG = 'Y' AND MIPRIID <> MICODE THEN
                   1
                  ELSE
                   2
                END) ASC;
    --游标中不共享资源，解锁前资源不能被更新并且不等待并抛出异常

    VMRID  METERREAD.MRID%TYPE;
    VBFID  METERREAD.MRBFID%TYPE;
    VSMFID METERREAD.MRSMFID%TYPE;
  BEGIN
    CALLOGTXT := NULL;
    WLOG('提交算费，表册序列：' || P_BFID);
    FOR I IN 1 .. TOOLS.FBOUNDPARA(P_BFID) LOOP
      VBFID  := TOOLS.FGETPARA(P_BFID, I, 1);
      VSMFID := TOOLS.FGETPARA(P_BFID, I, 2);
      WLOG('正在算费表册号：' || VBFID || ' ...');
      OPEN C_MR(VBFID, VSMFID);
      LOOP
        FETCH C_MR
          INTO VMRID;
        EXIT WHEN C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL;
        --单条抄表记录处理
        BEGIN

          CALCULATE(VMRID);
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            WLOG('抄表记录' || VMRID || '算费失败，已被忽略');
        END;
      END LOOP;
      CLOSE C_MR;
      WLOG('---------------------------------------------------');
    END LOOP;

    WLOG('算费过程处理完毕');
    LOG := CALLOGTXT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      LOG := CALLOGTXT;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --计划抄表单笔算费
  PROCEDURE CALCULATE(P_MRID IN METERREAD.MRID%TYPE) IS
    CURSOR C_MR IS
      SELECT *
        FROM METERREAD
       WHERE MRID = P_MRID
         AND MRIFREC = 'N'
         FOR UPDATE NOWAIT;

    --总分表子表抄表记录
    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2) IS
      SELECT MRSL, MRIFREC,MRREADOK
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPID = P_MPID;
    --一户多表用户信息zhb
    CURSOR C_MR_PR(P_MIPRIID IN VARCHAR2) IS
      SELECT MIID
        FROM METERINFO, METERREAD
       WHERE MRMID(+) = MIID
         AND MIPRIID = P_MIPRIID
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y'
       ORDER BY MIID;

    --合收子表抄表记录
    CURSOR C_MR_PRI(P_PRIMCODE IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRMCODE
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPRIFLAG = 'Y'
         AND MIPRIID = P_PRIMCODE
         AND MICODE <> P_PRIMCODE
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y';

    --取合收表信息
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
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的抄表计划流水号');
    END IF;
    --抄表数据来源  1表示计划抄表   5表示远传抄表   9表示抄表机抄表
    IF MR.MRSL < 最低算费水量 AND MR.MRDATASOURCE IN ('1', '5', '9', '2') AND
       (MR.MRRPID = '00' OR MR.MRRPID IS NULL) THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '抄表水量小于最低算费水量，不需要算费');
    END IF;
    --水表记录
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('无效的水表编号' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    CLOSE C_MI;
    MR.MRRECSL := MR.MRSL;
    -----------------------------------------------------------------------------
    --子表水量抵减计费总表抄见水量
    -----------------------------------------------------------------------------
    IF 总表截量 = 'Y' THEN
      --检查总分表中是否存在未抄表
      SELECT COUNT(*) INTO V_READNUM
      FROM METERINFO,METERREAD
      WHERE MIID=MRMID AND
            (MICODE=MR.MRMCODE OR MIPID=MR.MRMCODE)
            AND MRREADOK='N';
      IF V_READNUM>0 THEN
         WLOG('抄表记录' || MR.MRID || '总分表中包含未抄表，暂停产生费用');
         RAISE_APPLICATION_ERROR(ERRCODE,
                                  '总分表中包含未抄表，暂停产生费用');
      END IF;

      OPEN C_MR_CHILD(MR.MRMCODE);
      FETCH C_MR_CHILD
        INTO MRCHILD.MRSL, MRCHILD.MRIFREC,MRCHILD.MRREADOK;
      WHILE C_MR_CHILD%FOUND LOOP
        --子表未计费
        /*IF MRCHILD.MRIFREC = 'N' THEN
          WLOG('抄表记录' || MR.MRID || '收费总表发现子表未计费，暂停产生费用');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '收费总表子表未计费，暂停产生费用');
        END IF;*/
        --子表未抄表
        IF MRCHILD.MRREADOK='N' THEN
           WLOG('抄表记录' || MR.MRID || '收费总表发现子表未抄表，暂停产生费用');
           RAISE_APPLICATION_ERROR(ERRCODE,
                                  '收费总表子表未抄表，暂停产生费用');
        END IF;
        --抵消水量
        MR.MRRECSL := MR.MRRECSL - MRCHILD.MRSL;
        FETCH C_MR_CHILD
          INTO MRCHILD.MRSL, MRCHILD.MRIFREC,MRCHILD.MRREADOK;
      END LOOP;
      CLOSE C_MR_CHILD;
      IF MR.MRRECSL < 0 THEN
        WLOG('抄表记录' || MR.MRID || '收费总表水量小于子表水量，暂停产生费用');
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '收费总表水量小于子表水量，暂停产生费用');
      END IF;
    END IF;

    -----------------------------------------------------------------------------
    --判断一表多户 分表按比例分摊水量
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
           --正常算费
           CALCULATE(MRL, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
        ELSIF MIL.MIIFCHARGE = 'N' OR MRL.MRIFHALT='Y' THEN
              --计量不计费,将数据记录到费用库
              CALCULATENP(MRL, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
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
         --正常算费
         CALCULATE(MR, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
      ELSIF MI.MIIFCHARGE = 'N' OR MR.MRIFHALT='Y' THEN
            --计量不计费,将数据记录到费用库
            CALCULATENP(MR, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
      END IF;

    END IF;
    -----------------------------------------------------------------------------
    --更新当前抄表记录
    IF 是否审批算费 = 'N' THEN
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

  -- 自来水单笔算费，提供外部调用
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

    ----历史价格体系
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
    CLASSCTL  CHAR(1) := 'N'; --默认不取消阶梯计费方法

    I             NUMBER;
    VRD           RECDETAIL%ROWTYPE;
    V_DBSL        NUMBER; --定比较水量
    V_SVAINGBATCH VARCHAR2(50);

    V_OUTPBATCH      VARCHAR2(1000); --预存批次，但最终被复盖
    V_表的调整量     NUMBER(10);
    V_表减后水量值   NUMBER(10);
    V_表费的调整量   NUMBER(10);
    V_表费减后的量   NUMBER(10);
    V_表费项目调整量 NUMBER(10);
    V_表费项目减后量 NUMBER(10);
    V_混合表的调整量 NUMBER(10);
    V_FSCOUNT        NUMBER(10);
    V_PIGROUP        PRICEITEM.PIGROUP%TYPE;
    PI               PRICEITEM%ROWTYPE;
    V_RLFZCOUNT      NUMBER(10);
    V_RLFIRST        NUMBER(10);

    V_PER       NUMBER(10); --人数
    V_MONTHS    NUMBER(10); --月份
    V_PMISAVING METERINFO.MISAVING%TYPE;
    V_RETSTR    VARCHAR2(2000);
    V_BATCH     VARCHAR2(2000);
    V_TEST     VARCHAR2(2000);

    --预存自动抵扣
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
    /*    固定金额标志   := FPARA(MR.MRSMFID, 'GDJEFLAG');
    固定金额最低值 := FPARA(MR.MRSMFID, 'GDJEZ');*/

    --锁定水表记录
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('无效的水表编号' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    --锁定水表档案
    OPEN C_MD(MR.MRMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      WLOG('无效的水表档案' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    --锁定水表银行
    OPEN C_MA(MR.MRMID);
    FETCH C_MA
      INTO MA;
    CLOSE C_MA;
    --锁定用户记录
    OPEN C_CI(MI.MICID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      WLOG('无效的用户编号' || MI.MICID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的用户编号' || MI.MICID);
    END IF;
    DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;
    --非计费表执行空过程，不抛异常
    --合收子表
    IF TRUE THEN
      --reclist↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
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
      RL.RLIFINV       := 'N'; --CI.CIIFINV; --开票标志
      RL.RLMCODE       := MI.MICODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := MR.MRDAY;
      RL.RLBFID        := MR.MRBFID;
      RL.RLPRDATE      := MR.MRPRDATE;
      RL.RLRDATE       := MR.MRRDATE;
      --税票不收滞纳金
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
      /*----特殊业务（20130307 处理消防倍数水量问题 ）
      IF MR.MRRPID = '01' THEN
        RL.RLREADSL := 10 * MR.MRRECSL; --变量暂存，最后恢复
      ELSIF MR.MRRPID = '02' THEN
        RL.RLREADSL := 100 * MR.MRRECSL; --变量暂存，最后恢复
      ELSE
        RL.RLREADSL := MR.MRRECSL; --变量暂存，最后恢复
      END IF;*/
      -- RL.RLREADSL       := MR.MRRECSL; --变量暂存，最后恢复
      RL.RLINVMEMO      := MR.MRMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      RL.RLTRANS        := P_TRANS;
      RL.RLCD           := DEBIT;
      RL.RLYSCHARGETYPE := MI.MICHARGETYPE;
      RL.RLSL           := 0; --应收水费水量，【rlsl = rlreadsl + rladjsl】
      RL.RLJE           := 0; --生成帐体后计算,先初始化
      RL.RLADDSL        := NVL(MR.MRADDSL, 0) - NVL(MR.MRCARRYSL, 0);
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDJE       := 0;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDPER      := NULL;
      RL.RLPAIDDATE     := NULL;
      RL.RLMRID         := MR.MRID;
      RL.RLMEMO         := MR.MRMEMO || '   [' || P_NY || '历史单价' || ']';
      RL.RLZNJ          := 0;
      RL.RLLB           := MI.MILB;
      RL.RLPFID         := MI.MIPFID;
      RL.RLDATETIME     := SYSDATE;
      IF MI.MIPRIFLAG='Y' THEN
         RL.RLPRIMCODE     := MI.MIPRIID; --记录合收子表串
      ELSE
         RL.RLPRIMCODE     := RL.RLMID;
      END IF;

      RL.RLPRIFLAG      := MI.MIPRIFLAG;
      RL.RLRPER         := MR.MRRPER;
      RL.RLSAFID        := MR.MRSAFID;
      RL.RLSCODECHAR    := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR    := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP        := '1'; --应收帐分组

      RL.RLPID          := NULL; --实收流水（与payment.pid对应）
      RL.RLPBATCH       := NULL; --缴费交易批次（与payment.pbatch对应）
      RL.RLSAVINGQC     := 0; --期初预存（销帐时产生）
      RL.RLSAVINGBQ     := 0; --本期预存发生（销帐时产生）
      RL.RLSAVINGQM     := 0; --期末预存（销帐时产生）
      RL.RLREVERSEFLAG  := 'N'; --  冲正标志（n为正常，y为冲正）
      RL.RLBADFLAG      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
      RL.RLZNJREDUCFLAG := 'N'; --滞纳金减免标志,未减免时为n，销帐时滞纳金直接计算；减免后为y,销帐时滞纳金直接取rlznj
      RL.RLMISTID       := MI.MISTID; --行业分类
      RL.RLMINAME       := MI.MINAME; --票据名称
      RL.RLSXF          := 0; --手续费
      RL.RLMIFACE2      := MI.MIFACE2; --抄见故障
      RL.RLMIFACE3      := MI.MIFACE3; --非常计量
      RL.RLMIFACE4      := MI.MIFACE4; --表井设施说明
      RL.RLMIIFCKF      := MI.MIIFCHK; --垃圾费户数
      RL.RLMIGPS        := MI.MIGPS; --是否合票
      RL.RLMIQFH        := MI.MIQFH; --铅封号
      RL.RLMIBOX        := MI.MIBOX; --消防水价（增值税水价，襄阳需求）
      RL.RLMINAME2      := MI.MINAME2; --招牌名称(小区名，襄阳需求）
      RL.RLMISEQNO      := MI.MISEQNO; --户号（初始化时册号+序号）
      RL.RLSCRRLID      := RL.RLID; --原应收帐流水
      RL.RLSCRRLTRANS   := RL.RLTRANS; --原应收帐事务
      RL.RLSCRRLMONTH   := RL.RLMONTH; --原应收帐月份
      RL.RLSCRRLDATE    := RL.RLDATE; --原应收帐日期
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
          RL.RLPRIORJE := 0; --算费之前欠费
      END;
      IF RL.RLPRIORJE > 0 THEN
        RL.RLMISAVING := 0;
      ELSE
        RL.RLMISAVING := MI.MISAVING; --算费时预存
      END IF;

      RL.RLMICOMMUNITY   := MI.MICOMMUNITY; --小区
      RL.RLMIREMOTENO    := MI.MIREMOTENO; --远传表号
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --远传hub号
      RL.RLMIEMAIL       := MI.MIEMAIL; --电子邮件
      RL.RLMIEMAILFLAG   := MI.MIEMAILFLAG; --发账是否发邮件
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --备用字段1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --备用字段2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --备用字段3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --备用字段3
      RL.RLCOLUMN5       := RL.RLDATE; --上次应帐帐日期
      RL.RLCOLUMN9       := RL.RLID; --上次应收帐流水
      RL.RLCOLUMN10      := RL.RLMONTH; --上次应收帐月份
      RL.RLCOLUMN11      := RL.RLTRANS; --上次应收帐事务
      --表的调整量/ 表费的调整量 /表费项目调整量
      V_表的调整量   := 0;
      V_表减后水量值 := RL.RLREADSL;
      --查询对表量调理
      PALTAB := NULL;
      CALADJUST(MR.MRMONTH,
                MR.MRSMFID,
                CI.CIID,
                MI.MIID,
                NULL,
                NULL,
                TO_CHAR(MD.MDCALIBER),
                '仅按水表',
                PALTAB);
      --如果有取出累计值
      --仅按水表 02
      IF PALTAB IS NOT NULL THEN
        SP_GETJMSL(PALTAB, RL, V_表的调整量, V_表减后水量值, '02', 'Y');
      END IF;

      --reclist↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      --费用明细算法说明：
      --1、若存在混合费率即按其生成费用明细包，亦即是混合费率优先级最高；
      --2、否则户表费率游标内生成费用明细数据；
      --3、无论以上生成方式下，游标匹配优惠数据，重算费用明细；
      --重要规则；优惠生效前提是户表必须具备正常的户表费率，否则优惠无调整的目标
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN

--取水价  11 --周期性单价  按水表+价格类别

       temp_PALTAB  := NULL;
        PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);
       if    PALTAB is not null then
      temp_PALTAB := f_getpfid(PALTAB);
        end if;
      if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
         MI.MIPFID := temp_PALTAB(1).palcaliber ;
         --覆盖应收帐水价
         rl.rlpfid :=  MI.MIPFID ;
      end if;



        --按水表+价格类别 调整量
        PALTAB         := NULL;
        V_表费的调整量 := 0;
        V_表费减后的量 := V_表减后水量值;



         CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);

        --按水表+价格类别 07
        --如果有取出累计值
        IF PALTAB IS NOT NULL THEN
          SP_GETJMSL(PALTAB, RL, V_表费的调整量, V_表费减后的量, '07', 'Y');
        END IF;

        --cmprice户表费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        --找版本最高的费率明细
        IF P_NY = '0000.00' OR P_NY IS NULL THEN
          OPEN C_PD(MI.MIPFID);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;
    --水价调整 按水表+价格类别+费用项目
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别+费用项目',
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

            --计算调整

            --计算费率明细，扩展阶梯明细，固定非混合组0
            --按水表+价格类别 调整量
            PALTAB := NULL;

            V_表费项目调整量 := 0;
            V_表费项目减后量 := V_表费减后的量;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            --按水表+价格类别+费用项目 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_表费项目调整量,
                         V_表费项目减后量,
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
                    V_表的调整量,
                    V_表费的调整量,
                    V_表费项目调整量,
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

            --水价调整 按水表+价格类别+费用项目
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别+费用项目',
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





            --计算调整

            --计算费率明细，扩展阶梯明细，固定非混合组0
            --按水表+价格类别 调整量
            PALTAB := NULL;

            V_表费项目调整量 := 0;
            V_表费项目减后量 := V_表费减后的量;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);






            --按水表+价格类别+费用项目 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_表费项目调整量,
                         V_表费项目减后量,
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
                    V_表的调整量,
                    V_表费的调整量,
                    V_表费项目调整量,
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD_LS;
        END IF;

        --cmprice户表费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      ELSE
        --pricemultidetail混合费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

        --    v_表的调整量 /v_表减后水量值

        SELECT MAX(PMDID)
          INTO MAXPMDID
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = MI.MIID;
        TEMPSL := V_表减后水量值; --组分配累计余量
        --tempsl := rl.rlreadsl; --组分配累计余量

        V_DBSL := 0; --定比水量
        WHILE C_PMD%FOUND AND TEMPSL >= 0 LOOP

          --拆分余量记入最后费上
          IF PMD.PMDID = MAXPMDID THEN
            TEMPJSSL := TEMPSL;
          ELSE
            IF PMD.PMDTYPE = '00' THEN
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              TEMPJSSL := (CASE
                            WHEN TEMPSL >= TRUNC(PMD.PMDSCALE) THEN
                             TRUNC(PMD.PMDSCALE)
                            ELSE
                             TEMPSL
                          END);

              V_DBSL := V_DBSL + TEMPJSSL;

            ELSE
              TEMPJSSL := TRUNC((V_表减后水量值 - V_DBSL) * PMD.PMDSCALE);
            END IF;
            /* if pmd.pmdid = 0 then
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              tempjssl := (case when tempsl >= trunc(pmd.pmdscale) then trunc(pmd.pmdscale) else tempsl end);
              V_DBSL   := V_DBSL + tempjssl;
            else
              tempjssl := trunc((v_表减后水量值 - V_DBSL) * pmd.pmdscale);
            end if;*/
          END IF;

          ---分拆分表 混合表的调整量 := v_表的调整量 ;
          V_混合表的调整量 := 0;
          IF V_表的调整量 <> 0 THEN
            IF TEMPJSSL - V_表的调整量 >= 0 THEN
              V_混合表的调整量 := V_表的调整量;
              V_表的调整量     := 0;
            ELSE
              V_混合表的调整量 := TEMPJSSL;
              V_表的调整量     := V_表的调整量 - TEMPJSSL;
            END IF;
          END IF;


--取水价  11 --周期性单价  按水表+价格类别

       temp_PALTAB  := NULL;
        PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);
       if    PALTAB is not null then
      temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
         PMD.PMDPFID := temp_PALTAB(1).palcaliber ;
         --覆盖应收帐水价
         rl.rlpfid :=  PMD.PMDPFID ;
        end if;

          --按水表+价格类别 调整量
          PALTAB         := NULL;
          V_表费的调整量 := 0;
          V_表费减后的量 := TEMPJSSL;




          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    PMD.PMDPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '按水表+价格类别',
                    PALTAB);

          --按水表+价格类别 07
          --如果有取出累计值
          IF PALTAB IS NOT NULL THEN
            SP_GETJMSL(PALTAB,
                       RL,
                       V_表费的调整量,
                       V_表费减后的量,
                       '07',
                       'Y');
          END IF;

          --找版本最高的费率明细
          IF P_NY = '0000.00' OR P_NY IS NULL THEN
            OPEN C_PD(PMD.PMDPFID);
            LOOP
              FETCH C_PD
                INTO PD;
              EXIT WHEN C_PD%NOTFOUND;

 --水价调整 按水表+价格类别+费用项目
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  PMD.PMDPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别+费用项目',
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





              --计算费率明细，扩展阶梯明细，固定非混合组0
              --按水表+价格类别+费用项目 09
              PALTAB := NULL;

              V_表费项目调整量 := 0;
              V_表费项目减后量 := V_表费减后的量;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              --按水表+价格类别+费用项目 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_表费项目调整量,
                           V_表费项目减后量,
                           '09',
                           'Y');
              END IF;

              --计算费率明细，扩展阶梯明细，混合
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
                      V_表费的调整量,
                      V_表费项目调整量,
                      V_混合表的调整量,
                      P_NY);
            END LOOP;
            CLOSE C_PD;
          ELSE
            OPEN C_PD_LS(PMD.PMDPFID, P_NY);
            LOOP
              FETCH C_PD_LS
                INTO PD;
              EXIT WHEN C_PD_LS%NOTFOUND;




--水价调整 按水表+价格类别+费用项目
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  PMD.PMDPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别+费用项目',
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


              --计算费率明细，扩展阶梯明细，固定非混合组0
              --按水表+价格类别+费用项目 09
              PALTAB := NULL;

              V_表费项目调整量 := 0;
              V_表费项目减后量 := V_表费减后的量;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              --按水表+价格类别+费用项目 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_表费项目调整量,
                           V_表费项目减后量,
                           '09',
                           'Y');
              END IF;

              --计算费率明细，扩展阶梯明细，混合
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
                      V_表费的调整量,
                      V_表费项目调整量,
                      V_混合表的调整量,
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
      --pricemultidetail混合费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      RL.RLREADSL := MR.MRSL;
      --插入帐务
      --垃圾费基本数据
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

            --初始化垃圾费变量
            rdnjf := null;
            if v_months > 0 and v_per > 0 then
              if rdtab is null then
                raise_application_error(errcode, '缺少水费项目，请检查');
              else
                rdnjf            := rdtab(rdtab.last);
                rdnjf.rdpiid     := '05'; --费用项目
                rdnjf.rdysdj     := 垃圾费单价; --应收单价
                rdnjf.rdyssl     := v_per * v_months; --应收水量
                rdnjf.rdysje     := 垃圾费单价 * v_per * v_months; --应收金额
                rdnjf.rddj       := rdnjf.rdysdj; --实收单价
                rdnjf.rdsl       := rdnjf.rdyssl; --实收水量
                rdnjf.rdje       := rdnjf.rdysje; --实收金额
                rdnjf.rdadjdj    := 0; --实收单价
                rdnjf.rdadjsl    := 0; --实收水量
                rdnjf.rdadjje    := 0; --实收金额
                rdnjf.rdpmdscale := 0; --混合比例
                rdtab.extend;
                rdtab(rdtab.last) := rdnjf;
              end if;
            end if;
      */
      --分帐
      IF FSYSPARA('1104') = 'Y' THEN
        --分几条件帐
        V_RLFIRST := 0;
        V_BATCH   := NULL;
        OPEN C_PICOUNT;
        LOOP
          FETCH C_PICOUNT
            INTO V_PIGROUP;
          EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
          --rl1.rlgroup := v_pigroup;
          --松滋需求
          --if    rl1.rlgroup=2 then

          /*if    v_pigroup=2 then
            rl.rlsl:=0 ;
            rl.rlreadsl :=0;
          end if;*/

          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;

          --yujia 20120210 做为打印的预留

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
                IF 是否审批算费 = 'N' THEN
                  INSERT INTO RECDETAIL VALUES RDTAB (I);
                ELSE
                  INSERT INTO RECDETAILTEMP VALUES RDTAB (I);
                END IF;
              END IF;
            END LOOP;

          END LOOP;

          CLOSE C_PI;
          IF V_RLFZCOUNT > 0 THEN
            IF 是否审批算费 = 'N' THEN
              INSERT INTO RECLIST VALUES RL1;
            ELSE
              INSERT INTO RECLISTTEMP VALUES RL1;
            END IF;
            --预存自动扣款
            IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
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
                --合收表
                IF V_PMISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                  MI.MISMFID, --缴费机构
                                                  'system', --收款员
                                                  RL1.RLID || '|', --应收流水串
                                                  RL1.RLJE, --应收总金额
                                                  0, --销帐违约金
                                                  0, --手续费
                                                  0, --实际收款
                                                  PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                  MI.MIPRIID, --水表资料号
                                                  'XJ', --付款方式
                                                  MI.MISMFID, --缴费地点
                                                  V_BATCH, --销帐批次
                                                  'N', --是否打票  Y 打票，N不打票， R 应收票
                                                  NULL, --发票号
                                                  'N' --控制是否提交（Y/N）
                                                  );
                END IF;
              ELSE
                --单表
                SELECT MISAVING
                  INTO MI.MISAVING
                  FROM METERINFO T
                 WHERE MIID = MI.MIID;
                IF MI.MISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                  MI.MISMFID, --缴费机构
                                                  'system', --收款员
                                                  RL1.RLID || '|', --应收流水串
                                                  RL1.RLJE, --应收总金额
                                                  0, --销帐违约金
                                                  0, --手续费
                                                  0, --实际收款
                                                  PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                  MI.MIID, --水表资料号
                                                  'XJ', --付款方式
                                                  MI.MISMFID, --缴费地点
                                                  V_BATCH, --销帐批次
                                                  'N', --是否打票  Y 打票，N不打票， R 应收票
                                                  NULL, --发票号
                                                  'N' --控制是否提交（Y/N）
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
          --设置 输入的数据  固定金额最低值
          if 固定金额标志 = 'Y' AND rl.rlje <= 固定金额最低值 THEN
            rl.rlje := round(固定金额最低值);
          END IF;
        */
        IF 是否审批算费 = 'N' THEN
          INSERT INTO RECLIST VALUES RL;
        ELSE
          INSERT INTO RECLISTTEMP VALUES RL;
        END IF;
        INSRD(RDTAB);
        --预存自动扣款
        IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
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
            --合收表
            V_RLIDLIST := '';
            V_RLJES    := 0;
            V_ZNJ      := 0;

            OPEN C_YCDK;
            LOOP
              FETCH C_YCDK
                INTO V_RLID,V_RLJE,V_ZNJ;
              EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
              --预存够扣
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
              V_RETSTR := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                              MI.MISMFID, --缴费机构
                                              'system', --收款员
                                              V_RLIDLIST || '|', --应收流水串
                                              NVL(V_RLJES,0), --应收总金额
                                              NVL(V_ZNJS,0), --销帐违约金
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
              --预存够扣
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
            --单表
            IF LENGTH(V_RLIDLIST)>0 THEN
               V_RLIDLIST := SUBSTR(V_RLIDLIST,1,LENGTH(V_RLIDLIST)-1);
               V_RETSTR := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                              MI.MISMFID, --缴费机构
                                              'system', --收款员
                                              V_RLIDLIST || '|', --应收流水串
                                              NVL(V_RLJES,0), --应收总金额
                                              NVL(V_ZNJS,0), --销帐违约金
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



        END IF;


      END IF;

    END IF;

    --add 2013.01.16      向reclist_charge_01表中插入数据
    SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.01.16

    --推演历史水量信息
    --if   FChkMeterNeedCharge_xbqs(MI.MINEWFLAG,MR.MRSL)='Y'  then
/*    IF 是否审批算费 = 'N' THEN
      IF MR.MRMEMO = '换表余量欠费' THEN
        UPDATE METERINFO
           SET MIRCODE     = MIREINSCODE,
               MIRECDATE   = MR.MRRDATE,
               MIRECSL     = MR.MRSL, --取本期水量（抄量）
               MIFACE      = MR.MRFACE,
               MINEWFLAG   = 'N',
               MIRCODECHAR = MIREINSCODE
         WHERE CURRENT OF C_MI;

      ELSE
        UPDATE METERINFO
           SET MIRCODE     = MR.MRECODE,
               MIRECDATE   = MR.MRRDATE,
               MIRECSL     = MR.MRSL, --取本期水量（抄量）
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
               MIRECSL     = MR.MRSL, --取本期水量（抄量）
               MIFACE      = MR.MRFACE,
               MINEWFLAG   = 'N',
               MIRCODECHAR = MR.MRECODECHAR
         WHERE CURRENT OF C_MI;

   --end if;
    --
    CLOSE C_MI;
    CLOSE C_MD;
    CLOSE C_CI;
    --反馈应收水量水费到原始抄表记录
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
      WLOG('其他异常：' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --自来水单笔算费，只用于记账不计费（哈尔滨）
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

    ----历史价格体系
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
    CLASSCTL  CHAR(1) := 'N'; --默认不取消阶梯计费方法

    I             NUMBER;
    VRD           RECDETAIL%ROWTYPE;
    V_DBSL        NUMBER; --定比较水量
    V_SVAINGBATCH VARCHAR2(50);

    V_OUTPBATCH      VARCHAR2(1000); --预存批次，但最终被复盖
    V_表的调整量     NUMBER(10);
    V_表减后水量值   NUMBER(10);
    V_表费的调整量  NUMBER(10);
    V_表费减后的量   NUMBER(10);
    V_表费项目调整量 NUMBER(10);
    V_表费项目减后量 NUMBER(10);
    V_混合表的调整量 NUMBER(10);
    V_FSCOUNT        NUMBER(10);
    V_PIGROUP        PRICEITEM.PIGROUP%TYPE;
    PI               PRICEITEM%ROWTYPE;
    V_RLFZCOUNT      NUMBER(10);
    V_RLFIRST        NUMBER(10);

    V_PER       NUMBER(10); --人数
    V_MONTHS    NUMBER(10); --月份
    V_PMISAVING METERINFO.MISAVING%TYPE;
    V_RETSTR    VARCHAR2(2000);
    V_BATCH     VARCHAR2(2000);
     V_TEST     VARCHAR2(2000);

  BEGIN
    --
    --yujia  2012-03-20
    /*    固定金额标志   := FPARA(MR.MRSMFID, 'GDJEFLAG');
    固定金额最低值 := FPARA(MR.MRSMFID, 'GDJEZ');*/

    --锁定水表记录
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('无效的水表编号' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    --锁定水表档案
    OPEN C_MD(MR.MRMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      WLOG('无效的水表档案' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    --锁定水表银行
    OPEN C_MA(MR.MRMID);
    FETCH C_MA
      INTO MA;
    CLOSE C_MA;
    --锁定用户记录
    OPEN C_CI(MI.MICID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      WLOG('无效的用户编号' || MI.MICID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的用户编号' || MI.MICID);
    END IF;
    DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;
    --非计费表执行空过程，不抛异常
    --合收子表
    IF TRUE THEN
      --reclist↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
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
      RL.RLIFINV       := 'N';--CI.CIIFINV; --开票标志
      RL.RLMCODE       := MI.MICODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := MR.MRDAY;
      RL.RLBFID        := MR.MRBFID;
      RL.RLPRDATE      := MR.MRPRDATE;
      RL.RLRDATE       := MR.MRRDATE;
      --税票不收滞纳金
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
      /*----特殊业务（20130307 处理消防倍数水量问题 ）
      IF MR.MRRPID = '01' THEN
        RL.RLREADSL := 10 * MR.MRRECSL; --变量暂存，最后恢复
      ELSIF MR.MRRPID = '02' THEN
        RL.RLREADSL := 100 * MR.MRRECSL; --变量暂存，最后恢复
      ELSE
        RL.RLREADSL := MR.MRRECSL; --变量暂存，最后恢复
      END IF;*/
      -- RL.RLREADSL       := MR.MRRECSL; --变量暂存，最后恢复
      RL.RLINVMEMO      := MR.MRMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      RL.RLTRANS        := P_TRANS;
      RL.RLCD           := DEBIT;
      RL.RLYSCHARGETYPE := MI.MICHARGETYPE;
      RL.RLSL           := 0; --应收水费水量，【rlsl = rlreadsl + rladjsl】
      RL.RLJE           := 0; --生成帐体后计算,先初始化
      RL.RLADDSL        := NVL(MR.MRADDSL, 0) - NVL(MR.MRCARRYSL, 0);
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDJE       := 0;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDPER      := NULL;
      RL.RLPAIDDATE     := NULL;
      RL.RLMRID         := MR.MRID;
      RL.RLMEMO         := MR.MRMEMO || '   [' || P_NY || '历史单价' || ']';
      RL.RLZNJ          := 0;
      RL.RLLB           := MI.MILB;
      RL.RLPFID         := MI.MIPFID;
      RL.RLDATETIME     := SYSDATE;
      RL.RLPRIMCODE     := MR.MRPRIMID; --记录合收子表串
      RL.RLPRIFLAG      := MI.MIPRIFLAG;
      RL.RLRPER         := MR.MRRPER;
      RL.RLSAFID        := MR.MRSAFID;
      RL.RLSCODECHAR    := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR    := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP        := '1'; --应收帐分组

      RL.RLPID          := NULL; --实收流水（与payment.pid对应）
      RL.RLPBATCH       := NULL; --缴费交易批次（与payment.pbatch对应）
      RL.RLSAVINGQC     := 0; --期初预存（销帐时产生）
      RL.RLSAVINGBQ     := 0; --本期预存发生（销帐时产生）
      RL.RLSAVINGQM     := 0; --期末预存（销帐时产生）
      RL.RLREVERSEFLAG  := 'N'; --  冲正标志（n为正常，y为冲正）
      RL.RLBADFLAG      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
      RL.RLZNJREDUCFLAG := 'N'; --滞纳金减免标志,未减免时为n，销帐时滞纳金直接计算；减免后为y,销帐时滞纳金直接取rlznj
      RL.RLMISTID       := MI.MISTID; --行业分类
      RL.RLMINAME       := MI.MINAME; --票据名称
      RL.RLSXF          := 0; --手续费
      RL.RLMIFACE2      := MI.MIFACE2; --抄见故障
      RL.RLMIFACE3      := MI.MIFACE3; --非常计量
      RL.RLMIFACE4      := MI.MIFACE4; --表井设施说明
      RL.RLMIIFCKF      := MI.MIIFCHK; --垃圾费户数
      RL.RLMIGPS        := MI.MIGPS; --是否合票
      RL.RLMIQFH        := MI.MIQFH; --铅封号
      RL.RLMIBOX        := MI.MIBOX; --消防水价（增值税水价，襄阳需求）
      RL.RLMINAME2      := MI.MINAME2; --招牌名称(小区名，襄阳需求）
      RL.RLMISEQNO      := MI.MISEQNO; --户号（初始化时册号+序号）
      RL.RLSCRRLID      := RL.RLID; --原应收帐流水
      RL.RLSCRRLTRANS   := RL.RLTRANS; --原应收帐事务
      RL.RLSCRRLMONTH   := RL.RLMONTH; --原应收帐月份
      RL.RLSCRRLDATE    := RL.RLDATE; --原应收帐日期
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
          RL.RLPRIORJE := 0; --算费之前欠费
      END;
      IF RL.RLPRIORJE > 0 THEN
        RL.RLMISAVING := 0;
      ELSE
        RL.RLMISAVING := MI.MISAVING; --算费时预存
      END IF;

      RL.RLMICOMMUNITY   := MI.MICOMMUNITY; --小区
      RL.RLMIREMOTENO    := MI.MIREMOTENO; --远传表号
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --远传hub号
      RL.RLMIEMAIL       := MI.MIEMAIL; --电子邮件
      RL.RLMIEMAILFLAG   := MI.MIEMAILFLAG; --发账是否发邮件
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --备用字段1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --备用字段2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --备用字段3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --备用字段3
      RL.RLCOLUMN5       := RL.RLDATE; --上次应帐帐日期
      RL.RLCOLUMN9       := RL.RLID; --上次应收帐流水
      RL.RLCOLUMN10      := RL.RLMONTH; --上次应收帐月份
      RL.RLCOLUMN11      := RL.RLTRANS; --上次应收帐事务
      --表的调整量/ 表费的调整量 /表费项目调整量
      V_表的调整量   := 0;
      V_表减后水量值 := RL.RLREADSL;
      --查询对表量调理
      PALTAB := NULL;
      CALADJUST(MR.MRMONTH,
                MR.MRSMFID,
                CI.CIID,
                MI.MIID,
                NULL,
                NULL,
                TO_CHAR(MD.MDCALIBER),
                '仅按水表',
                PALTAB);
      --如果有取出累计值
      --仅按水表 02
      IF PALTAB IS NOT NULL THEN
        SP_GETJMSL(PALTAB, RL, V_表的调整量, V_表减后水量值, '02', 'Y');
      END IF;

      --reclist↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      --费用明细算法说明：
      --1、若存在混合费率即按其生成费用明细包，亦即是混合费率优先级最高；
      --2、否则户表费率游标内生成费用明细数据；
      --3、无论以上生成方式下，游标匹配优惠数据，重算费用明细；
      --重要规则；优惠生效前提是户表必须具备正常的户表费率，否则优惠无调整的目标
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN

--取水价  11 --周期性单价  按水表+价格类别

       temp_PALTAB  := NULL;
        PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);
       if    PALTAB is not null then
      temp_PALTAB := f_getpfid(PALTAB);
        end if;
      if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
         MI.MIPFID := temp_PALTAB(1).palcaliber ;
         --覆盖应收帐水价
         rl.rlpfid :=  MI.MIPFID ;
        end if;



        --按水表+价格类别 调整量
        PALTAB         := NULL;
        V_表费的调整量 := 0;
        V_表费减后的量 := V_表减后水量值;



         CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);

        --按水表+价格类别 07
        --如果有取出累计值
        IF PALTAB IS NOT NULL THEN
          SP_GETJMSL(PALTAB, RL, V_表费的调整量, V_表费减后的量, '07', 'Y');
        END IF;

        --cmprice户表费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        --找版本最高的费率明细
        IF P_NY = '0000.00' OR P_NY IS NULL THEN
          OPEN C_PD(MI.MIPFID);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;
    --水价调整 按水表+价格类别+费用项目
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别+费用项目',
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

            --计算调整

            --计算费率明细，扩展阶梯明细，固定非混合组0
            --按水表+价格类别 调整量
            PALTAB := NULL;

            V_表费项目调整量 := 0;
            V_表费项目减后量 := V_表费减后的量;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            --按水表+价格类别+费用项目 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_表费项目调整量,
                         V_表费项目减后量,
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
                    V_表的调整量,
                    V_表费的调整量,
                    V_表费项目调整量,
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

            --水价调整 按水表+价格类别+费用项目
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别+费用项目',
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





            --计算调整

            --计算费率明细，扩展阶梯明细，固定非混合组0
            --按水表+价格类别 调整量
            PALTAB := NULL;

            V_表费项目调整量 := 0;
            V_表费项目减后量 := V_表费减后的量;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);






            --按水表+价格类别+费用项目 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_表费项目调整量,
                         V_表费项目减后量,
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
                    V_表的调整量,
                    V_表费的调整量,
                    V_表费项目调整量,
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD_LS;
        END IF;

        --cmprice户表费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      ELSE
        --pricemultidetail混合费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

        --    v_表的调整量 /v_表减后水量值

        SELECT MAX(PMDID)
          INTO MAXPMDID
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = MI.MIID;
        TEMPSL := V_表减后水量值; --组分配累计余量
        --tempsl := rl.rlreadsl; --组分配累计余量

        V_DBSL := 0; --定比水量
        WHILE C_PMD%FOUND AND TEMPSL >= 0 LOOP

          --拆分余量记入最后费上
          IF PMD.PMDID = MAXPMDID THEN
            TEMPJSSL := TEMPSL;
          ELSE
            IF PMD.PMDTYPE = '00' THEN
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              TEMPJSSL := (CASE
                            WHEN TEMPSL >= TRUNC(PMD.PMDSCALE) THEN
                             TRUNC(PMD.PMDSCALE)
                            ELSE
                             TEMPSL
                          END);

              V_DBSL := V_DBSL + TEMPJSSL;

            ELSE
              TEMPJSSL := TRUNC((V_表减后水量值 - V_DBSL) * PMD.PMDSCALE);
            END IF;
            /* if pmd.pmdid = 0 then
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              tempjssl := (case when tempsl >= trunc(pmd.pmdscale) then trunc(pmd.pmdscale) else tempsl end);
              V_DBSL   := V_DBSL + tempjssl;
            else
              tempjssl := trunc((v_表减后水量值 - V_DBSL) * pmd.pmdscale);
            end if;*/
          END IF;

          ---分拆分表 混合表的调整量 := v_表的调整量 ;
          V_混合表的调整量 := 0;
          IF V_表的调整量 <> 0 THEN
            IF TEMPJSSL - V_表的调整量 >= 0 THEN
              V_混合表的调整量 := V_表的调整量;
              V_表的调整量     := 0;
            ELSE
              V_混合表的调整量 := TEMPJSSL;
              V_表的调整量     := V_表的调整量 - TEMPJSSL;
            END IF;
          END IF;


--取水价  11 --周期性单价  按水表+价格类别

       temp_PALTAB  := NULL;
        PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);
       if    PALTAB is not null then
      temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1).palcaliber IS NOT NULL THEN
         PMD.PMDPFID := temp_PALTAB(1).palcaliber ;
         --覆盖应收帐水价
         rl.rlpfid :=  PMD.PMDPFID ;
        end if;

          --按水表+价格类别 调整量
          PALTAB         := NULL;
          V_表费的调整量 := 0;
          V_表费减后的量 := TEMPJSSL;




          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    PMD.PMDPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '按水表+价格类别',
                    PALTAB);

          --按水表+价格类别 07
          --如果有取出累计值
          IF PALTAB IS NOT NULL THEN
            SP_GETJMSL(PALTAB,
                       RL,
                       V_表费的调整量,
                       V_表费减后的量,
                       '07',
                       'Y');
          END IF;

          --找版本最高的费率明细
          IF P_NY = '0000.00' OR P_NY IS NULL THEN
            OPEN C_PD(PMD.PMDPFID);
            LOOP
              FETCH C_PD
                INTO PD;
              EXIT WHEN C_PD%NOTFOUND;

 --水价调整 按水表+价格类别+费用项目
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  PMD.PMDPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别+费用项目',
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





              --计算费率明细，扩展阶梯明细，固定非混合组0
              --按水表+价格类别+费用项目 09
              PALTAB := NULL;

              V_表费项目调整量 := 0;
              V_表费项目减后量 := V_表费减后的量;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              --按水表+价格类别+费用项目 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_表费项目调整量,
                           V_表费项目减后量,
                           '09',
                           'Y');
              END IF;

              --计算费率明细，扩展阶梯明细，混合
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
                      V_表费的调整量,
                      V_表费项目调整量,
                      V_混合表的调整量,
                      P_NY);
            END LOOP;
            CLOSE C_PD;
          ELSE
            OPEN C_PD_LS(PMD.PMDPFID, P_NY);
            LOOP
              FETCH C_PD_LS
                INTO PD;
              EXIT WHEN C_PD_LS%NOTFOUND;




--水价调整 按水表+价格类别+费用项目
            temp_PALTAB := null;
            PALTAB         := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  PD.PDPIID,
                  PMD.PMDPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别+费用项目',
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


              --计算费率明细，扩展阶梯明细，固定非混合组0
              --按水表+价格类别+费用项目 09
              PALTAB := NULL;

              V_表费项目调整量 := 0;
              V_表费项目减后量 := V_表费减后的量;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              --按水表+价格类别+费用项目 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_表费项目调整量,
                           V_表费项目减后量,
                           '09',
                           'Y');
              END IF;

              --计算费率明细，扩展阶梯明细，混合
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
                      V_表费的调整量,
                      V_表费项目调整量,
                      V_混合表的调整量,
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
      --pricemultidetail混合费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      RL.RLREADSL := MR.MRSL;
      --插入帐务
      --垃圾费基本数据
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

            --初始化垃圾费变量
            rdnjf := null;
            if v_months > 0 and v_per > 0 then
              if rdtab is null then
                raise_application_error(errcode, '缺少水费项目，请检查');
              else
                rdnjf            := rdtab(rdtab.last);
                rdnjf.rdpiid     := '05'; --费用项目
                rdnjf.rdysdj     := 垃圾费单价; --应收单价
                rdnjf.rdyssl     := v_per * v_months; --应收水量
                rdnjf.rdysje     := 垃圾费单价 * v_per * v_months; --应收金额
                rdnjf.rddj       := rdnjf.rdysdj; --实收单价
                rdnjf.rdsl       := rdnjf.rdyssl; --实收水量
                rdnjf.rdje       := rdnjf.rdysje; --实收金额
                rdnjf.rdadjdj    := 0; --实收单价
                rdnjf.rdadjsl    := 0; --实收水量
                rdnjf.rdadjje    := 0; --实收金额
                rdnjf.rdpmdscale := 0; --混合比例
                rdtab.extend;
                rdtab(rdtab.last) := rdnjf;
              end if;
            end if;
      */
      --分帐
      IF FSYSPARA('1104') = 'Y' THEN
        --分几条件帐
        V_RLFIRST := 0;
        V_BATCH   := NULL;
        OPEN C_PICOUNT;
        LOOP
          FETCH C_PICOUNT
            INTO V_PIGROUP;
          EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
          --rl1.rlgroup := v_pigroup;
          --松滋需求
          --if    rl1.rlgroup=2 then

          /*if    v_pigroup=2 then
            rl.rlsl:=0 ;
            rl.rlreadsl :=0;
          end if;*/

          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;

          --yujia 20120210 做为打印的预留

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
                IF 是否审批算费 = 'N' THEN
                  INSERT INTO RECDETAILNP VALUES RDTAB (I);
                ELSE
                  INSERT INTO RECDETAILTEMP VALUES RDTAB (I);
                END IF;
              END IF;
            END LOOP;

          END LOOP;

          CLOSE C_PI;
          IF V_RLFZCOUNT > 0 THEN
            IF 是否审批算费 = 'N' THEN
              INSERT INTO RECLISTNP VALUES RL1;
            ELSE
              INSERT INTO RECLISTTEMP VALUES RL1;
            END IF;
            --预存自动扣款
            /*IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
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
                --合收表
                IF V_PMISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                  MI.MISMFID, --缴费机构
                                                  'system', --收款员
                                                  RL1.RLID || '|', --应收流水串
                                                  RL1.RLJE, --应收总金额
                                                  0, --销帐违约金
                                                  0, --手续费
                                                  0, --实际收款
                                                  PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                  MI.MIPRIID, --水表资料号
                                                  'XJ', --付款方式
                                                  MI.MISMFID, --缴费地点
                                                  V_BATCH, --销帐批次
                                                  'N', --是否打票  Y 打票，N不打票， R 应收票
                                                  NULL, --发票号
                                                  'N' --控制是否提交（Y/N）
                                                  );
                END IF;
              ELSE
                --单表
                SELECT MISAVING
                  INTO MI.MISAVING
                  FROM METERINFO T
                 WHERE MIID = MI.MIID;
                IF MI.MISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                  MI.MISMFID, --缴费机构
                                                  'system', --收款员
                                                  RL1.RLID || '|', --应收流水串
                                                  RL1.RLJE, --应收总金额
                                                  0, --销帐违约金
                                                  0, --手续费
                                                  0, --实际收款
                                                  PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                  MI.MIID, --水表资料号
                                                  'XJ', --付款方式
                                                  MI.MISMFID, --缴费地点
                                                  V_BATCH, --销帐批次
                                                  'N', --是否打票  Y 打票，N不打票， R 应收票
                                                  NULL, --发票号
                                                  'N' --控制是否提交（Y/N）
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
          --设置 输入的数据  固定金额最低值
          if 固定金额标志 = 'Y' AND rl.rlje <= 固定金额最低值 THEN
            rl.rlje := round(固定金额最低值);
          END IF;
        */
        IF 是否审批算费 = 'N' THEN
          INSERT INTO RECLISTNP VALUES RL;
        ELSE
          INSERT INTO RECLISTTEMP VALUES RL;
        END IF;

        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          VRD      := RDTAB(I);

          IF 是否审批算费 = 'N' THEN
            INSERT INTO RECDETAILNP VALUES VRD;
          ELSE
            INSERT INTO RECDETAILTEMP VALUES VRD;
          END IF;
        END LOOP;

        --INSRD(RDTAB);
        --预存自动扣款
        /*IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
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
            --合收表
            IF V_PMISAVING >= RL.RLJE THEN
              V_RETSTR := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                              MI.MISMFID, --缴费机构
                                              'system', --收款员
                                              RL.RLID || '|', --应收流水串
                                              RL.RLJE, --应收总金额
                                              0, --销帐违约金
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
          ELSE
            --单表
            IF MI.MISAVING >= RL.RLJE THEN

              V_RETSTR := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                              MI.MISMFID, --缴费机构
                                              'system', --收款员
                                              RL.RLID || '|', --应收流水串
                                              RL.RLJE, --应收总金额
                                              0, --饰ピ冀？                                              0, --手续费
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
          \*PG_EWIDE_PAY_01.SP_RLSAVING(mi,
          RL,
          fgetsequence('ENTRUSTLOG'),
          mi.mismfid,
          'system',
          'XJ',
          mi.mismfid,
          0,
          PG_ewide_PAY_01.PAYTRANS_预存抵扣,
          'N',
          NULL,
          'N');*\
        END IF;*/
      END IF;

    END IF;

    --add 2013.01.16      向reclist_charge_01表中插入数据
    --SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.01.16

    --推演历史水量信息
    --if   FChkMeterNeedCharge_xbqs(MI.MINEWFLAG,MR.MRSL)='Y'  then
/*    IF 是否审批算费 = 'N' THEN
      IF MR.MRMEMO = '换表余量欠费' THEN
        UPDATE METERINFO
           SET MIRCODE     = MIREINSCODE,
               MIRECDATE   = MR.MRRDATE,
               MIRECSL     = MR.MRSL, --取本期水量（抄量）
               MIFACE      = MR.MRFACE,
               MINEWFLAG   = 'N',
               MIRCODECHAR = MIREINSCODE
         WHERE CURRENT OF C_MI;

      ELSE
        UPDATE METERINFO
           SET MIRCODE     = MR.MRECODE,
               MIRECDATE   = MR.MRRDATE,
               MIRECSL     = MR.MRSL, --取本期水量（抄量）
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
               MIRECSL     = MR.MRSL, --取本期水量（抄量）
               MIFACE      = MR.MRFACE,
               MINEWFLAG   = 'N',
               MIRCODECHAR = MR.MRECODECHAR
         WHERE CURRENT OF C_MI;

   --end if;
    --
    CLOSE C_MI;
    CLOSE C_MD;
    CLOSE C_CI;
    --反馈应收水量水费到原始抄表记录
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
      WLOG('其他异常：' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --匹配计费调整记录
  PROCEDURE CALADJUST(P_MONTH   IN VARCHAR2, --抄表月份
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
         AND ((PALTACTIC = '02' AND PALMID = P_MID AND P_TYPE = '仅按水表') OR --仅按水表
             (PALTACTIC = '07' AND PALMID = P_MID AND PALPFID = P_PFID AND
             P_TYPE = '按水表+价格类别') OR --按水表+价格类别
             (PALTACTIC = '09' AND PALMID = P_MID AND PALPFID = P_PFID AND
             PALPIID = P_PIID AND P_TYPE = '按水表+价格类别+费用项目') --按水表+价格类别+费用项目
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
      --插入明细包
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
      WLOG('查找计费预调整信息异常：' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --水量调整函数   BY WY 20110703
  PROCEDURE SP_GETJMSL(PALTAB             IN OUT PAL_TABLE,
                       P_RL               IN RECLIST%ROWTYPE,
                       P_调整量           IN OUT NUMBER,
                       P_减后水量值       IN OUT NUMBER,
                       P_策略             IN VARCHAR2,
                       P_基础量累计是与否 IN VARCHAR2) IS

    NMONTH   NUMBER(12);
    V_SMONTH VARCHAR2(20);
    V_EMONTH VARCHAR2(20);
  BEGIN
   -- IF P_策略 IN ('02', '07', '09') THEN

      FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
if PALTAB(I).PALTACTIC  in ('02', '07', '09')  then
        --固定量调整
        IF PALTAB(I).PALMETHOD = '02' THEN
          BEGIN
            SELECT CEIL(NVL(MONTHS_BETWEEN(P_RL.RLRDATE,
                                           NVL(P_RL.RLPRDATE,
                                               ADD_MONTHS(P_RL.RLRDATE, 1)) + 1),
                            0))
              INTO NMONTH --计费时段月数
              FROM DUAL;
          EXCEPTION
            WHEN OTHERS THEN
              NMONTH := 1;
          END;
          IF NMONTH <= 0 THEN
            NMONTH := 1; --异常周期都不算阶梯
          END IF;

          IF P_减后水量值 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY * NMONTH >= 0 THEN
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := P_减后水量值 + PALTAB(I)
                        .PALVALUE * PALTAB(I).PALWAY * NMONTH;
            END IF;
            P_调整量 := P_调整量 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY * NMONTH;
          ELSE
            P_调整量 := P_调整量 - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := 0;
            END IF;
          END IF;
        END IF;
        --比例调整
        IF PALTAB(I).PALMETHOD = '03' THEN
          IF P_减后水量值 +
             TRUNC(P_减后水量值 * PALTAB(I).PALVALUE * PALTAB(I).PALWAY) >= 0 THEN
            P_调整量 := P_调整量 +
                     TRUNC(P_减后水量值 * PALTAB(I).PALVALUE * PALTAB(I).PALWAY);
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := P_减后水量值 + TRUNC(P_减后水量值 * PALTAB(I).PALVALUE * PALTAB(I)
                                         .PALWAY);
            END IF;
          ELSE
            P_调整量 := P_调整量 - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := 0;
            END IF;
          END IF;
        END IF;
        --保底调整(保低值为正)
        IF PALTAB(I).PALMETHOD = '05' THEN
          IF P_减后水量值 >= PALTAB(I).PALVALUE THEN
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := P_减后水量值;
            END IF;
            P_调整量 := P_调整量;
          ELSE
            P_调整量 := P_调整量 + PALTAB(I).PALVALUE - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
          END IF;
        END IF;
        --封顶量调整(保低值为正)
        IF PALTAB(I).PALMETHOD = '06' THEN
          IF P_减后水量值 <= PALTAB(I).PALVALUE THEN
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := P_减后水量值;
            END IF;
            P_调整量 := P_调整量;
          ELSE
            P_调整量 := P_调整量 + PALTAB(I).PALVALUE - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
          END IF;
        END IF;

        --累计减免量
        IF PALTAB(I).PALMETHOD = '04' THEN
          IF P_减后水量值 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY >= 0 THEN
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := P_减后水量值 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
            P_调整量 := P_调整量 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            --累计量用完，更新累计量0
            UPDATE PRICEADJUSTLIST
               SET PALVALUE = 0
             WHERE PALID = PALTAB(I).PALID;
          ELSE
            --更新累计量
            UPDATE PRICEADJUSTLIST
               SET PALVALUE = PALVALUE - P_减后水量值
             WHERE PALID = PALTAB(I).PALID;
            P_调整量 := P_调整量 - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := 0;
            END IF;
          END IF;
        END IF;
      end if;
      END LOOP;

  --  END IF;
  END;

  --水价调整函数   BY WY 20130531
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

  --调整水价+费用项目函数   BY WY 20130531
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
                    P_表的调整量     IN NUMBER,
                    P_表费的调整量   IN NUMBER,
                    P_表费项目调整量 IN NUMBER,
                    P_混合表调整量   IN NUMBER,
                    P_NY             IN VARCHAR2) IS
    --p_classctl 2008.11.16增加（Y：强制不使用阶梯计费方法
    --N：计算阶梯，如果是的话）
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

    RD.RDMSMFID  := P_RL.RLMSMFID; --营销公司
    RD.RDMONTH   := P_RL.RLMONTH; --帐务月份
    RD.RDMID     := P_RL.RLMID; --水表编号
    RD.RDPMDTYPE := NVL(PMD.PMDTYPE, '01'); --混合类别

    RD.RDPMDCOLUMN1 := PMD.PMDCOLUMN1; --备用字段1
    RD.RDPMDCOLUMN2 := PMD.PMDCOLUMN2; --备用字段2
    RD.RDPMDCOLUMN3 := PMD.PMDCOLUMN3; --备用字段3

/*    --yujia  2012-03-20
    固定金额标志   := FPARA(P_RL.RLMSMFID, 'GDJEFLAG');
    固定金额最低值 := FPARA(P_RL.RLMSMFID, 'GDJEZ');*/

    CASE PD.PDMETHOD
      WHEN 'dj1' THEN
        --固定单价  默认方式，与抄量有关
        BEGIN
          RD.RDCLASS := 0;
          RD.RDYSDJ  := PD.PDDJ;
          RD.RDYSSL  := P_SL - P_混合表调整量;
          RD.RDADJDJ := 0;
          RD.RDADJSL := P_表的调整量 + P_表费的调整量 + P_表费项目调整量 + P_混合表调整量;
          RD.RDADJJE := 0;
          RD.RDDJ    := PD.PDDJ;
          RD.RDSL    := P_SL + RD.RDADJSL - P_混合表调整量;
          --计算调整
          RD.RDYSJE := ROUND(RD.RDYSDJ*RD.RDSL, 2);
          RD.RDJE   := ROUND(RD.RDDJ*RD.RDSL, 2);


/*          IF RD.RDPFID = '0102' AND 固定金额标志 = 'Y' AND RD.RDJE <= 固定金额最低值 THEN
            RD.RDJE := ROUND(固定金额最低值);
          END IF;*/



          --插入明细包
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --汇总
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
        END;
      WHEN 'dj2' THEN
        --COD单价  绍兴需求：COD单价×水量，其中COD单价＝抄见COD值即化学含氧量对应单价，与抄量有关
        BEGIN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '暂不支持的计费方法' || PD.PDMETHOD);
        END;
      WHEN 'je1' THEN
        --固定金额  许昌需求：比如对全市所有水表加收1元钱的水表维修费，与抄量无关
        BEGIN
          RD.RDCLASS := 0;
          RD.RDYSDJ  := PD.PDJE;
          RD.RDYSSL  := 0;
          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
          RD.RDDJ    := PD.PDJE;
          RD.RDSL    := 0;
          --计算调整
          IF PALTAB IS NOT NULL THEN
            FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
              PALTAB(I).PALRLID := P_RL.RLID; --回写作用rlid到pal
              CASE PALTAB(I).PALMETHOD
                WHEN '07' THEN
                  --例外单价+优惠单价（COD调整）
                  RD.RDYSDJ  := PALTAB(I).PALPRICE;
                  RD.RDDJ    := TOOLS.GETMAX(PALTAB(I)
                                             .PALPRICE + PALTAB(I)
                                             .PALWAY * PALTAB(I).PALVALUE,
                                             0);
                  RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                WHEN '01' THEN
                  --单价调整
                  BEGIN
                    RD.RDDJ    := TOOLS.GETMAX(RD.RDDJ + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE,
                                               0);
                    RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                  END;
                WHEN '02' THEN
                  --固定水量调整

                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '03' THEN
                  --比例水量调整（明细实收水量保留两位小数2009.7.6）
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '04' THEN
                  --累计水量调整
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '08' THEN
                  --比例单价调整（2009.10.4增补）
                  BEGIN
                    RD.RDADJDJ := TOOLS.GETMAX(RD.RDDJ *
                                               (1 + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE),
                                               0) - RD.RDDJ;
                    RD.RDDJ    := RD.RDDJ + RD.RDADJDJ;
                  END;
                ELSE
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
              END CASE;
            END LOOP;
          END IF;

          --插入明细包
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --汇总
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          --p_rl.rlsl := p_rl.rlsl + (case when rd.rdpiid='01' then rd.rdsl else 0 end);
        END;
      WHEN 'sl1' THEN
        --固定单价、用量  许昌需求：包月用户，与抄量无关
        BEGIN
          RD.RDCLASS := 0;
          RD.RDYSDJ  := PD.PDDJ;
          RD.RDYSSL  := PD.PDSL;
          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
          RD.RDDJ    := PD.PDDJ;
          RD.RDSL    := PD.PDSL;
          --计算调整
          IF PALTAB IS NOT NULL THEN
            FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
              PALTAB(I).PALRLID := P_RL.RLID; --回写作用rlid到pal
              CASE PALTAB(I).PALMETHOD
                WHEN '07' THEN
                  --例外单价+优惠单价（COD调整）
                  RD.RDYSDJ  := PALTAB(I).PALPRICE;
                  RD.RDDJ    := TOOLS.GETMAX(PALTAB(I)
                                             .PALPRICE + PALTAB(I)
                                             .PALWAY * PALTAB(I).PALVALUE,
                                             0);
                  RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                WHEN '01' THEN
                  --单价调整
                  BEGIN
                    RD.RDDJ    := TOOLS.GETMAX(RD.RDDJ + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE,
                                               0);
                    RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                  END;
                WHEN '02' THEN
                  --固定水量调整
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '03' THEN
                  --比例水量调整（明细实收水量保留两位小数2009.7.6）
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '04' THEN
                  --累计水量调整
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '08' THEN
                  --比例单价调整（2009.10.4增补）
                  BEGIN
                    RD.RDADJDJ := TOOLS.GETMAX(RD.RDDJ *
                                               (1 + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE),
                                               0) - RD.RDDJ;
                    RD.RDDJ    := RD.RDDJ + RD.RDADJDJ;
                  END;
                ELSE
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
              END CASE;
            END LOOP;
          END IF;
          RD.RDYSJE := ROUND(RD.RDYSDJ * RD.RDYSSL, 2);
          RD.RDJE   := ROUND(RD.RDDJ * RD.RDSL, 2);
          --插入明细包
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --汇总
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
        --固定单价、用量/户口  承德需求：楼户 按3吨/人月计算；平房 按2吨/人月计算，与抄量无关
        BEGIN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '暂不支持的计费方法' || PD.PDMETHOD);
        END;
      WHEN 'sl3' THEN
        -- raise_application_error(errcode, '阶梯水价');
        --阶梯计费  简单模式阶梯水价

        RD.RDYSSL  := P_SL - P_混合表调整量;
        RD.RDADJDJ := 0;
        RD.RDADJSL := P_表的调整量 + P_表费的调整量 + P_表费项目调整量 + P_混合表调整量;
        RD.RDADJJE := 0;
        RD.RDSL    := P_SL + RD.RDADJSL - P_混合表调整量;
        /*          rd.rdsl    := p_sl  ;*/
        BEGIN
          --计算调整

          --阶梯计费
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

          /* --阶梯计费
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
        --与水量有关，小于等于X吨收固定Y元，大于X吨收固定Z元(苏州吴中需求)
        SELECT * INTO MINFO FROM METERINFO MI WHERE MI.MIID = P_RL.RLMID;
        RD.RDCLASS := 0;
        /*
        if minfo.miusenum is null or minfo.miusenum = 0 then
             v_per := 1;
           else
             v_per := nvl(to_number(minfo.miusenum), 1);
           end if;*/

        -- yujia 20120208  垃圾费从2012年一月份开始征收

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
              INTO V_MONTHS --计费时段月数
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

        ---yujia [20120208 默认为一户]
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
          RD.RDYSDJ := 垃圾费单价;
          RD.RDYSSL := V_PER * V_MONTHS;
          RD.RDYSJE := 垃圾费单价 * V_PER * V_MONTHS;

          RD.RDDJ    := 垃圾费单价;
          RD.RDSL    := V_PER * V_MONTHS;
          RD.RDJE    := 垃圾费单价 * V_PER * V_MONTHS;
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
          --插入明细包

          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
        END IF;
        --汇总
        P_RL.RLJE := P_RL.RLJE + RD.RDJE;
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '不支持的计费方法' || PD.PDMETHOD);
    END CASE;

  EXCEPTION
    WHEN OTHERS THEN
      WLOG(P_RL.RLCCODE || '计算费用项目费用异常：' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --阶梯计费步骤
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
    --rd.rdpiid；rd.rdpfid；rd.rdpscid为必要参数
    CURSOR C_PS IS
      SELECT *
        FROM PRICESTEP
       WHERE PSPSCID = PD.PDPSCID
         AND PSPFID = PD.PDPFID
         AND PSPIID = PD.PDPIID
       ORDER BY PSCLASS;
    --历史水价阶梯
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
    N       NUMBER; --计费期数
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

    RD.RDMSMFID  := P_RL.RLMSMFID; --营销公司
    RD.RDMONTH   := P_RL.RLMONTH; --帐务月份
    RD.RDMID     := P_RL.RLMID; --水表编号
    RD.RDPMDTYPE := NVL(PMD.PMDTYPE, '01'); --混合类别

    RD.RDPMDCOLUMN1 := PMD.PMDCOLUMN1; --备用字段1
    RD.RDPMDCOLUMN2 := PMD.PMDCOLUMN2; --备用字段2
    RD.RDPMDCOLUMN3 := PMD.PMDCOLUMN3; --备用字段3

    TMPYSSL := P_SL; --阶梯累减应收水量余额
    TMPSL   := P_SL + P_ADJSL; --阶梯累减实收水量余额

    --判断数据是否满足收取阶梯的条件
    SELECT MI.*
      INTO MINFO
      FROM METERINFO MI
     WHERE MI.MICODE = P_RL.RLMCODE;

    --- yujia20120208 [只有私户和集体用户才用阶梯级次]
    BEGIN
      SELECT CEIL(NVL(MONTHS_BETWEEN(P_RL.RLRDATE,
                                     NVL(P_RL.RLPRDATE,
                                         ADD_MONTHS(P_RL.RLRDATE, 1)) + 1),
                      0))
        INTO N --计费时段月数
        FROM DUAL;
    EXCEPTION
      WHEN OTHERS THEN
        N := 0;
    END;
    IF N <= 0 THEN
      N := 999999; --异常周期都不算阶梯
    END IF;

    IF PMONTH = '0000.00' OR PMONTH IS NULL THEN
      OPEN C_PS;
      FETCH C_PS
        INTO PS;
      IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
      END IF;
      WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
        -- >=0保证0用水至少一条费用明细
        /*
        ┌───────────────────────────────────────────────────────────────────────────────────────────────┐
        │武汉水务阶梯规则（户/人均用水量以同一地址的所有水表用水量之和为基础计算）                      │
        │1、家庭户籍人口在4人以下（含4人）的用水户，按户用水量划分阶梯式计量水价。                      │
        │2、家庭户籍人口在5人（含5人）以上的用水户，按人均用水量划分阶梯式计量水价。                    │
        ┌─────────┬───────────────────────┬───────────────────────────────────┬─────────────────────────┐
        │按户计算 │户用水量≤ 25立方米     │25立方米＜户用水量≤33立方米        │户用水量＞ 33立方米      │
        │按人计算 │人均用水量≤ 6.25立方米 │6.25立方米＜人均用水量≤ 8.25立方米 │人均用水量＞ 8.25立方米  │
        │水价     │1.1                    │1.65                               │2.2                      │
        └─────────┴───────────────────────┴───────────────────────────────────┴─────────────────────────┘
        */ --一阶止二阶起要求设置值相同，依此类推
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

        --插入明细包
        IF RDTAB IS NULL THEN
          RDTAB := RD_TABLE(RD);
        ELSE
          RDTAB.EXTEND;
          RDTAB(RDTAB.LAST) := RD;
        END IF;
        --汇总
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
        RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
      END IF;
      WHILE C_PS_JT%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
        -- >=0保证0用水至少一条费用明细
        /*
        ┌───────────────────────────────────────────────────────────────────────────────────────────────┐
        │武汉水务阶梯规则（户/人均用水量以同一地址的所有水表用水量之和为基础计算）                      │
        │1、家庭户籍人口在4人以下（含4人）的用水户，按户用水量划分阶梯式计量水价。                      │
        │2、家庭户籍人口在5人（含5人）以上的用水户，按人均用水量划分阶梯式计量水价。                    │
        ┌─────────┬───────────────────────┬───────────────────────────────────┬─────────────────────────┐
        │按户计算 │户用水量≤ 25立方米     │25立方米＜户用水量≤33立方米        │户用水量＞ 33立方米      │
        │按人计算 │人均用水量≤ 6.25立方米 │6.25立方米＜人均用水量≤ 8.25立方米 │人均用水量＞ 8.25立方米  │
        │水价     │1.1                    │1.65                               │2.2                      │
        └─────────┴───────────────────────┴───────────────────────────────────┴─────────────────────────┘
        */ --一阶止二阶起要求设置值相同，依此类推
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

        --插入明细包
        IF RDTAB IS NULL THEN
          RDTAB := RD_TABLE(RD);
        ELSE
          RDTAB.EXTEND;
          RDTAB(RDTAB.LAST) := RD;
        END IF;
        --汇总
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
      WLOG(P_RL.RLCCODE || '计算阶梯水量费用异常：' || SQLERRM);
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
      IF 是否审批算费 = 'N' THEN
        INSERT INTO RECDETAIL VALUES VRD;
      ELSE
        INSERT INTO RECDETAILTEMP VALUES VRD;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --预存扣款(预存抵扣，不含手续费)
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
    V_OUTPBATCH   VARCHAR2(1000); --预存批次，但最终被复盖
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

    --全局开关：算费时预存自动销账
    IF TRIM(MI.MIPRIID) IS NOT NULL THEN
      --合收表用户
      IF NVL(MI.MISAVING, 0) >= RL.RLJE + V_RLZNJ AND RL.RLJE > 0 THEN
        --合收表水表预存足够直接销账
        BEGIN

          /*          PG_ewide_PAY_01.pos(rl.rlsmfid, --缴费机构
          'system', --收款员
          rl.rlid, --应收流水
          rl.rlmid, --户号
          rl.rlje, --应收金额
          v_rlznj, --销帐违约金
          0, --手续费
          0, --实际收款
          PG_ewide_PAY_01.PAYTRANS_预存抵扣, --缴费事务
          PG_ewide_PAY_01.DEBIT, --借代方向
          'XJ', --付款方式
          rl.rlsmfid, --缴费地点
          p_batch, --缴费事务流水
          'N', --是否打票  Y 打票，N不打票， R 应收票
          NULL, --发票号
          'N' --提交标志
          );*/
          V_RET := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                       RL.RLSMFID, --缴费机构
                                       'system', --收款员
                                       RL.RLID || '|', --应收流水
                                       RL.RLJE, --应收金额
                                       V_RLZNJ, --销帐违约金
                                       0, --手续费
                                       0, --实际收款
                                       PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                       RL.RLMID, --户号
                                       'XJ', --付款方式
                                       RL.RLSMFID, --缴费地点
                                       FGETSEQUENCE('ENTRUSTLOG'), --缴费事务流水
                                       'N', --是否打票  Y 打票，N不打票， R 应收票
                                       '', --发票号
                                       'N' --控制是否提交（Y/N）
                                       );

        EXCEPTION
          WHEN OTHERS THEN
            WLOG('预存余额即时抵扣应收帐时发生错误' || MI.MIID);
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '预存余额即时抵扣应收帐时发生错误' || MI.MIID);
        END;
      ELSIF RL.RLJE > 0 THEN
        --金额不足，需找其他水表提取预存
        SELECT SUM(MISAVING)
          INTO YCSUM
          FROM METERINFO
         WHERE MIPRIID = MI.MIPRIID;

        IF YCSUM IS NOT NULL AND YCSUM >= RL.RLJE + V_RLZNJ AND YCSUM > 0 THEN
          --判断合收表所有预存，是否大于欠费金额

          V_BKJE := RL.RLJE + V_RLZNJ - MI.MISAVING; --获取欠费金额
          V_YCJE := V_BKJE;
          OPEN C_MISAVING(MI.MICODE);
          LOOP
            FETCH C_MISAVING
              INTO MIS;
            EXIT WHEN C_MISAVING%NOTFOUND OR C_MISAVING%NOTFOUND IS NULL;
            IF MIS.MISAVING >= V_BKJE THEN

              /*              PG_ewide_PAY_01.pos(mis.mismfid, --缴费机构
              'system', --收款员
              NULL, --应收流水
              mis.miid, --户号
              0, --应收金额
              0, --销帐违约金
              0, --手续费
              -v_bkje, --实际收款
              PG_ewide_PAY_01.PAYTRANS_SAV, --缴费事务
              PG_ewide_PAY_01.CREDIT, --借代方向
              'XJ', --付款方式
              mis.mismfid, --缴费地点
              p_batch, --缴费事务流水
              'N', --是否打票  Y 打票，N不打票， R 应收票
              NULL, --发票号
              'N' --提交标志
              );*/

              V_RET  := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                            RL.RLSMFID, --缴费机构
                                            'system', --收款员
                                            NULL, --应收流水
                                            0, --应收金额
                                            V_RLZNJ, --销帐违约金
                                            0, --手续费
                                            V_BKJE, --实际收款
                                            PG_EWIDE_PAY_01.PAYTRANS_SAV, --缴费事务
                                            RL.RLMID, --户号
                                            'XJ', --付款方式
                                            RL.RLSMFID, --缴费地点
                                            FGETSEQUENCE('ENTRUSTLOG'), --缴费事务流水
                                            'N', --是否打票  Y 打票，N不打票， R 应收票
                                            '', --发票号
                                            'N' --控制是否提交（Y/N）
                                            );
              V_BKJE := 0;
              EXIT;
            ELSE
              /*              PG_ewide_PAY_01.pos(mis.mismfid, --缴费机构
              'system', --收款员
              NULL, --应收流水
              mis.miid, --户号
              0, --应收金额
              0, --销帐违约金
              0, --手续费
              -mis.misaving, --实际收款
              PG_ewide_PAY_01.PAYTRANS_SAV, --缴费事务
              PG_ewide_PAY_01.CREDIT, --借代方向
              'XJ', --付款方式
              mis.mismfid, --缴费地点
              p_batch, --缴费事务流水
              'N', --是否打票  Y 打票，N不打票， R 应收票
              NULL, --发票号
              'N' --提交标志
              );*/

              V_RET  := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                            RL.RLSMFID, --缴费机构
                                            'system', --收款员
                                            NULL, --应收流水
                                            0, --应收金额
                                            V_RLZNJ, --销帐违约金
                                            0, --手续费
                                            MIS.MISAVING, --实际收款
                                            PG_EWIDE_PAY_01.PAYTRANS_SAV, --缴费事务
                                            RL.RLMID, --户号
                                            'XJ', --付款方式
                                            RL.RLSMFID, --缴费地点
                                            FGETSEQUENCE('ENTRUSTLOG'), --缴费事务流水
                                            'N', --是否打票  Y 打票，N不打票， R 应收票
                                            '', --发票号
                                            'N' --控制是否提交（Y/N）
                                            );
              V_BKJE := V_BKJE - MIS.MISAVING;
            END IF;
          END LOOP;
          CLOSE C_MISAVING;

          IF V_BKJE <> 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '金额不符,不能销帐' || MI.MICODE);
          END IF;

          /*          PG_ewide_PAY_01.pos(mi.mismfid, --缴费机构
          'system', --收款员
          NULL, --应收流水
          mi.miid, --户号
          0, --应收金额
          0, --销帐违约金
          0, --手续费
          v_ycje, --实际收款
          PG_ewide_PAY_01.PAYTRANS_SAV, --缴费事务
          PG_ewide_PAY_01.DEBIT, --借代方向
          'XJ', --付款方式
          mi.mismfid, --缴费地点
          p_batch, --缴费事务流水
          'N', --是否打票  Y 打票，N不打票， R 应收票
          NULL, --发票号
          'N' --提交标志
          );*/

          V_RET := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                       RL.RLSMFID, --缴费机构
                                       'system', --收款员
                                       NULL, --应收流水
                                       0, --应收金额
                                       V_RLZNJ, --销帐违约金
                                       0, --手续费
                                       V_YCJE, --实际收款
                                       PG_EWIDE_PAY_01.PAYTRANS_SAV, --缴费事务
                                       RL.RLMID, --户号
                                       'XJ', --付款方式
                                       RL.RLSMFID, --缴费地点
                                       FGETSEQUENCE('ENTRUSTLOG'), --缴费事务流水
                                       'N', --是否打票  Y 打票，N不打票， R 应收票
                                       '', --发票号
                                       'N' --控制是否提交（Y/N）
                                       );

          --重新取预存

          /*          PG_ewide_PAY_01.pos(rl.rlsmfid, --缴费机构
          'system', --收款员
          rl.rlid, --应收流水
          rl.rlmid, --户号
          rl.rlje, --应收金额
          v_rlznj, --销帐违约金
          0, --手续费
          0, --实际收款
          PG_ewide_PAY_01.PAYTRANS_预存抵扣, --缴费事务
          PG_ewide_PAY_01.DEBIT, --借代方向
          'XJ', --付款方式
          rl.rlsmfid, --缴费地点
          p_batch, --缴费事务流水
          'N', --是否打票  Y 打票，N不打票， R 应收票
          NULL, --发票号
          'N' --提交标志
          );*/
          V_RET := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                       RL.RLSMFID, --缴费机构
                                       'system', --收款员
                                       RL.RLID || '|', --应收流水
                                       RL.RLJE, --应收金额
                                       V_RLZNJ, --销帐违约金
                                       0, --手续费
                                       0, --实际收款
                                       PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                       RL.RLMID, --户号
                                       'XJ', --付款方式
                                       RL.RLSMFID, --缴费地点
                                       FGETSEQUENCE('ENTRUSTLOG'), --缴费事务流水
                                       'N', --是否打票  Y 打票，N不打票， R 应收票
                                       '', --发票号
                                       'N' --控制是否提交（Y/N）
                                       );
        END IF;

      END IF;
    ELSE

      IF NVL(MI.MISAVING, 0) >= RL.RLJE + V_RLZNJ AND RL.RLJE > 0 THEN
        -- 非合收表水表预存足够直接销账
        BEGIN
          /*          PG_ewide_PAY_01.pos(rl.rlsmfid, --缴费机构
          'system', --收款员
          rl.rlid, --应收流水
          rl.rlmid, --户号
          rl.rlje, --应收金额
          v_rlznj, --销帐违约金
          0, --手续费
          0, --实际收款
          PG_ewide_PAY_01.PAYTRANS_预存抵扣, --缴费事务
          PG_ewide_PAY_01.DEBIT, --借代方向
          'XJ', --付款方式
          rl.rlsmfid, --缴费地点
          p_batch, --缴费事务流水
          'N', --是否打票  Y 打票，N不打票， R 应收票
          NULL, --发票号
          'N' --提交标志
          );*/
          V_RET := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                       RL.RLSMFID, --缴费机构
                                       'system', --收款员
                                       RL.RLID || '|', --应收流水
                                       RL.RLJE, --应收金额
                                       V_RLZNJ, --销帐违约金
                                       0, --手续费
                                       0, --实际收款
                                       PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                       RL.RLMID, --户号
                                       'XJ', --付款方式
                                       RL.RLSMFID, --缴费地点
                                       FGETSEQUENCE('ENTRUSTLOG'), --缴费事务流水
                                       'N', --是否打票  Y 打票，N不打票， R 应收票
                                       '', --发票号
                                       'N' --控制是否提交（Y/N）
                                       );
        EXCEPTION
          WHEN OTHERS THEN
            WLOG('预存余额即时抵扣应收帐时发生错误' || MI.MIID);
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '预存余额即时抵扣应收帐时发生错误' || MI.MIID);
        END;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  PROCEDURE 账务审批(P_BFID IN VARCHAR2) IS
    /****审批应收汇总*/
    CURSOR C_RLTEMP(P_RLBFID IN VARCHAR2, P_RLSMFID IN VARCHAR2) IS
      SELECT *
        FROM RECLISTTEMP RLT
       WHERE RLT.RLBFID = P_RLBFID
         AND RLT.RLSMFID = P_RLSMFID
         FOR UPDATE NOWAIT;
    /****审批应收明细*/
    CURSOR C_RDTEMP(P_RLID IN VARCHAR2) IS
      SELECT *
        FROM RECDETAILTEMP RDT
       WHERE RDT.RDID = P_RLID
         FOR UPDATE NOWAIT;
    /***抄表信息**/
    CURSOR C_MR(P_MRID IN VARCHAR2) IS
      SELECT * FROM METERREAD WHERE MRID = P_MRID FOR UPDATE NOWAIT;
    /*********用户信息**********/
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

        --锁定抄表记录
        OPEN C_MR(V_RLTEMP.RLMRID);
        FETCH C_MR
          INTO MR;
        IF C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的抄表计划流水号');
        END IF;

        --锁定水表记录
        OPEN C_MI(MR.MRMID);
        FETCH C_MI
          INTO MI;
        IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
        END IF;
        /***********插入正式应收汇总************/
        INSERT INTO RECLIST VALUES V_RLTEMP;
        --锁定应收明细记录
        OPEN C_RDTEMP(V_RLTEMP.RLID);
        LOOP
          FETCH C_RDTEMP
            INTO V_RD;
          EXIT WHEN C_RDTEMP%NOTFOUND OR C_RDTEMP%NOTFOUND IS NULL;

          /***********插入正式应收明细************/
          INSERT INTO RECDETAIL VALUES V_RD;
        END LOOP;

        /**************更新抄表记录******************/
        UPDATE METERREAD
           SET MRIFREC   = 'Y',
               MRRECDATE = V_RLTEMP.RLDATE,
               MRRECSL   = V_RLTEMP.RLSL
         WHERE CURRENT OF C_MR;
        /**************更新水表******************/
        IF MR.MRMEMO = '换表余量欠费' THEN
          UPDATE METERINFO
             SET MIRCODE     = MIREINSCODE,
                 MIRECDATE   = MR.MRRDATE,
                 MIRECSL     = MR.MRSL, --取本期水量（抄量）
                 MIFACE      = MR.MRFACE,
                 MINEWFLAG   = 'N',
                 MIRCODECHAR = MIREINSCODE
           WHERE CURRENT OF C_MI;
        ELSE
          UPDATE METERINFO
             SET MIRCODE     = MR.MRECODE,
                 MIRECDATE   = MR.MRRDATE,
                 MIRECSL     = MR.MRSL, --取本期水量（抄量）
                 MIFACE      = MR.MRFACE,
                 MINEWFLAG   = 'N',
                 MIRCODECHAR = MR.MRECODECHAR
           WHERE CURRENT OF C_MI;
        END IF;
        /*******删除临时表账务信息*********/
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
      /*********关闭相关游标********/
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
  水量精度                  := TO_NUMBER(FSYSPARA('0042'));
  总表截量                  := FSYSPARA('1069');
  最低算费水量              := TO_NUMBER(FSYSPARA('1092'));
  垃圾费水量分水岭          := TO_NUMBER(FSYSPARA('1096'));
  垃圾费单价                := TO_NUMBER(FSYSPARA('1097'));
  垃圾费大于分水岭水量收X元 := TO_NUMBER(FSYSPARA('1098'));
  版本号码                  := FSYSPARA('sys1');
  是否审批算费              := FSYSPARA('ifrl');
END;
/

