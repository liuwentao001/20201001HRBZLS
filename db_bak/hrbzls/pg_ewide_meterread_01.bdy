CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_METERREAD_01" IS
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
         and METERINFO.mistatus not in ('24', '35', '36', '19') --算费时，故障换表中、周期换表中、预存冲销中、销户中的不进行算费,需把故障换表中、周期换表中单据审核完才能算费 20140628
         AND MRIFREC = 'N'
            /******* 用途：是否算费的条件控制
                       时间：2012-04-13
                      修改人：刘光波
            *****/
            --AND MICLASS = 1
            --AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, '1') = 'Y' --未计费
            --AND MRIFSUBMIT = 'Y' --允许计费(用户挂起)
            --AND MRIFHALT = 'N' --停算(系统指定)
         AND MRREADOK = 'Y' --抄见状态
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

  --算费前虚拟算费，供月抄表明细调用
  FUNCTION CALCULATEBF(P_MRID IN VARCHAR2, P_TYPE IN VARCHAR2) RETURN NUMBER AS
    --取抄表信息
    CURSOR C_MR IS
      SELECT *
        FROM VIEW_METERREADALL
       WHERE MRID = P_MRID
            --AND MRIFREC = 'N'
         AND MRSL > 0;
  
    --取水表信息
    CURSOR C_MI(P_MID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = P_MID;
  
    --20140512 总表截量修改
    --总表截量=子表换表余量（M）+子表换表后当月抄见水量（1）
    --追量收费的
    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRREADOK, mrcarrysl --减免水量Ralph 20150511
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
      UNION ALL
      SELECT MRSL, MRIFREC, MRREADOK, mrcarrysl --减免水量Ralph 20150511
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
  
    --取已算费应收信息
    CURSOR C_REC(P_MRID VARCHAR2) IS
      SELECT RL.RLSL, (RD.DJ1 + RD.DJ2 + RD.DJ3) RLDJ, RL.RLJE
        FROM RECLIST RL, VIEW_RECLIST_CHARGE RD
       WHERE RL.RLID = RD.RDID
         AND RL.RLMRID = P_MRID;
  
    MR        VIEW_METERREADALL%ROWTYPE;
    MRCHILD   METERREAD%ROWTYPE;
    MI        METERINFO%ROWTYPE;
    V_PRICEAD PRICEADJUSTLIST%ROWTYPE;
  
    ERR_READ EXCEPTION; --子表未抄见
    GET_SL   EXCEPTION; --取水量
    GET_DJ   EXCEPTION; --取单价
    GET_JE   EXCEPTION; --取金额
  
    REC_SL NUMBER;
    REC_DJ NUMBER(10, 2);
    REC_JE NUMBER(10, 2);
  
    V_SL  NUMBER;
    V_DJ  NUMBER;
    V_JE  NUMBER;
    V_RET VARCHAR2(400);
  
    V_SUMNUM  NUMBER; --子表数
    V_READNUM NUMBER; --抄见子表数
    V_RECNUM  NUMBER; --算费子表数
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
      --子表水量抵减计费总表抄见水量
      -----------------------------------------------------------------------------
      --STEP1 检查是否总表
      IF MI.MICLASS = 2 THEN
        --是总表
        V_MRMCODE := MR.MRMCODE; --赋值为总表号
      
        --STEP2 判断总表下的分表中是否存在未抄子表 （子表未月初或未抄见）和未算费子表
        SELECT COUNT(*),
               SUM(DECODE(NVL(MRREADOK, 'N'), 'Y', 1, 0)),
               SUM(DECODE(NVL(MRIFREC, 'N'), 'Y', 1, 0))
          INTO V_SUMNUM, V_READNUM, V_RECNUM
          FROM METERINFO, METERREAD
         WHERE MIID = MRMID(+)
           AND MIPID = V_MRMCODE
           AND MICLASS = '3';
        --如果子表数和大于子表已抄见数和，则存在未抄子表
        IF V_SUMNUM > V_READNUM THEN
          RAISE ERR_READ;
        ELSE
          --STEP3 取正常子表水量算截量
          OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
          LOOP
            FETCH C_MR_CHILD
              INTO MRCHILD.MRSL,
                   MRCHILD.MRIFREC,
                   MRCHILD.MRREADOK,
                   MRCHILD.mrcarrysl;
            EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
            --抵消水量
            MR.MRRECSL := MR.MRRECSL - MRCHILD.MRSL -
                          nvl(MRCHILD.mrcarrysl, 0); --增加对减免水量刨除 20150511 ralph
          END LOOP;
          CLOSE C_MR_CHILD;
          --如果收费总表水量小于子表水量，总表水量返回0
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
      --算计费调整水量
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
      --取应收单价算应收水费
      -----------------------------------------------------------------------------
      V_DJ := FGETPRICEDJ(MI.MIPFID) + FGEWSCBDJ(MR.MRMCODE, MR.MRMONTH); --应收单价（含污水超标）
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

  --计划抄表单笔算费
  PROCEDURE CALCULATE(P_MRID IN METERREAD.MRID%TYPE) IS
    CURSOR C_MR IS
      SELECT *
        FROM METERREAD
       WHERE MRID = P_MRID
         AND MRIFREC = 'N'
         AND MRSL >= 0 --20140522 0用水允许算费
         FOR UPDATE NOWAIT;
  
    --总分表子表抄表记录
    /*    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2) IS
    SELECT MRSL, MRIFREC, MRREADOK
      FROM METERINFO, METERREAD
     WHERE MRMID = MIID
       AND MIPID = P_MPID;*/
  
    --20140512 总表截量修改
    --总表截量=子表换表余量（M）+子表换表后当月抄见水量（1）
    --追量收费的
    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRREADOK, nvl(MRCARRYSL, 0) MRCARRYSL --校验水量
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
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --周期换表、故障换表
         AND RLREVERSEFLAG = 'N';
  
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
      SELECT * FROM METERINFO WHERE MIID = P_MID;
    --总表有周期换表、故障换表的余量抓取  20140809
    CURSOR C_MI_CLASS(P_MRMID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT nvl(DECODE(NVL(SUM(MRADDSL), 0), 0, SUM(MRSL), SUM(MRADDSL)),
                 0)
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MRMID = P_MRMID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --周期换表、故障换表
         AND RLREVERSEFLAG = 'N' --未冲正
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
  
    V_SUMNUM      NUMBER; --子表数
    V_READNUM     NUMBER; --抄见子表数
    V_RECNUM      NUMBER; --算费子表数
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
  
    IF MI.mistatus = '24' AND MR.MRDATASOURCE <> 'M' THEN
      --如果表状态为故障换表中且此抄表记录来源不是故障抄表余量，则提示不能算费，有故障换表
      WLOG('此水表编号正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.');
    END IF;
  
    IF MI.mistatus = '35' AND MR.MRDATASOURCE <> 'L' THEN
      --如果表状态为周期换表中且此抄表记录来源不是周期抄表余量，则提示不能算费，有周期换表
      WLOG('此水表编号正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.');
    END IF;
  
    if MI.mistatus = '36' then
      --预存冲正中
      WLOG('此水表编号正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.');
    end if;
    
    --byj add 
    if MI.mistatus = '39' then
      --预存冲正中
      WLOG('此水表编号正在预存撤表退费中,不能进行算费,如需算费请先审核或删除预存冲正单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在预存冲正中,不能进行算费,如需算费请先审核或删除预存冲正单据.');
    end if;
    
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L') then
       --水表起码已经改变
       WLOG('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || MR.MRMID);
       RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    end if;
    --end!!!
  
    if MI.mistatus = '19' then
      --销户中
      WLOG('此水表编号正在销户中,不能进行算费,如需算费请先审核销户单据或删除销户单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在销户中,不能进行算费,如需算费请先审核销户或删除销户单据.');
    end if;
  
    -------
    MR.MRRECSL := MR.MRSL; --本期水量
    -----------------------------------------------------------------------------
    --子表水量抵减计费总表抄见水量
    -----------------------------------------------------------------------------
    IF 总表截量 = 'Y' THEN
    
      --######总分表算费   20140412 BY HK#######
      /*
      规则：
      1、同一表册，分表先算费，算费同普通表
      2、总表需要先判断分表是否都已算费，分表全算费了才允许总表算费
      3、总表按总表截量算费（总表抄见 - 分表抄见和），如果总表截量小于0，则总表不算费
      */
      --MICLASS：普通表=1，总表=2，分表=3
    
      --STEP1 检查是否总表
      SELECT MICLASS, MIPID
        INTO V_MICLASS, V_MIPID
        FROM METERINFO
       WHERE MICODE = MR.MRMCODE;
    
      IF V_MICLASS = 2 THEN
        --是总表
        V_MRMCODE := MR.MRMCODE; --赋值为总表号
      
        --STEP2 判断总表下的分表中是否存在未抄子表 （子表未月初或未抄见）和未算费子表
        SELECT COUNT(*),
               SUM(DECODE(NVL(MRREADOK, 'N'), 'Y', 1, 0)),
               SUM(DECODE(NVL(MRIFREC, 'N'), 'Y', 1, 0))
          INTO V_SUMNUM, V_READNUM, V_RECNUM
          FROM METERINFO, METERREAD
         WHERE MIID = MRMID(+)
           AND MIPID = V_MRMCODE
           AND MICLASS = '3';
        --如果子表数和大于子表已抄见数和，则存在未抄子表
        IF V_SUMNUM > V_READNUM THEN
          WLOG('抄表记录' || MR.MRID || '总分表中包含未抄子表，暂停产生费用');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '总分表中包含未抄子表，暂停产生费用');
        END IF;
      
        --20140512 总分表分表已抄见就让算费
        --如果子表数和大于子表已算费数和，则存在未算费子表
        IF V_SUMNUM > V_RECNUM THEN
          WLOG('抄表记录' || MR.MRID || '收费总表发现子表未计费，暂停产生费用');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '收费总表子表未计费，暂停产生费用');
        END IF;
        --add modiby  20140809  hb 
        --总表本月抄表产生账务明细时,抓取本月是否有做故障换表，有的话抓取故障换表余量
      
        OPEN C_MI_CLASS(V_MRMCODE, MR.MRMONTH);
        FETCH C_MI_CLASS
          INTO V_MDHIS_ADDSL; --故障换表余量
        IF C_MI_CLASS%NOTFOUND OR C_MI_CLASS%NOTFOUND IS NULL THEN
          V_MDHIS_ADDSL := 0;
        END IF;
        CLOSE C_MI_CLASS;
      
        V_PD_ADDSL := V_MDHIS_ADDSL; --判断水量=故障换表余量
      
        OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
        LOOP
          FETCH C_MR_CHILD
            INTO MRCHILD.MRSL,
                 MRCHILD.MRIFREC,
                 MRCHILD.MRREADOK,
                 MRCHILD.MRCARRYSL;
          EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
          --判断的水量 V_PD_ADDSL 实际为故障换表水量
          V_PD_ADDSL := V_PD_ADDSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
          --总表故障换表水量 =总表故障换表水量 -子表抄表水量 - 子表校验水量 modiby hb 20140614
        END LOOP;
        CLOSE C_MR_CHILD;
      
        if V_PD_ADDSL < 0 then
          --下述包含三种情况
          --1总表换表时 余量-分表总出账 小于0时不出账   不出账
          --2总表抄见时,如果有故障换表 则抄见水量=抄见水量+换表余量 -分表总出账   出账
          --3 总表故障换表 、分表出账后水量够减， 总表出账
          MR.MRRECSL := MR.MRRECSL + V_MDHIS_ADDSL;
          --end add 20140809 
          --STEP3 判断总分表收费总表水量是否小于子表水量
          --取正常子表水量算截量
          OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
          LOOP
            FETCH C_MR_CHILD
              INTO MRCHILD.MRSL,
                   MRCHILD.MRIFREC,
                   MRCHILD.MRREADOK,
                   MRCHILD.MRCARRYSL;
            EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
            --抵消水量
            MR.MRRECSL := MR.MRRECSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
            --总表应收水量 =总表抄表水量 -子表抄表水量 - 子表校验水量 modiby hb 20140614
          END LOOP;
          CLOSE C_MR_CHILD;
        
        else
          --4  总表本月有做故障换表，故障换表余量大于分表总量时，总表再次做抄表，出账水量就等于总表抄见水量
          MR.MRRECSL := MR.MRRECSL;
        end if;
      
        --如果收费总表水量小于子表水量，暂停产生费用
        IF MR.MRRECSL < 0 THEN
          --如果总表截量小于0，则总表停算费用
          WLOG('抄表记录' || MR.MRID || '收费总表水量小于子表水量，暂停产生费用');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '收费总表水量小于子表水量，暂停产生费用');
        END IF;
      
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
        IF MRL.mrifrec = 'N' AND MRL.MRIFSUBMIT = 'Y' AND
           MRL.MRIFHALT = 'N' AND MIL.MIIFCHARGE = 'Y' AND
           FCHKMETERNEEDCHARGE(MIL.MISTATUS, MIL.MIIFCHK, '1') = 'Y' THEN
          --正常算费
          CALCULATE(MRL, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
        ELSIF MIL.MIIFCHARGE = 'N' OR MRL.MRIFHALT = 'Y' THEN
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
      IF MR.mrifrec = 'N' AND MR.MRIFSUBMIT = 'Y' AND MR.MRIFHALT = 'N' AND
         MI.MIIFCHARGE = 'Y' AND
         FCHKMETERNEEDCHARGE(MI.MISTATUS, MI.MIIFCHK, '1') = 'Y' THEN
        --正常算费
        CALCULATE(MR, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
      ELSIF MI.MIIFCHARGE = 'N' OR MR.MRIFHALT = 'Y' THEN
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

  --手机抄表预算费 20150309
  PROCEDURE CALCULATE_YSFH(P_MRID    IN METERREAD.MRID%TYPE,
                           o_rlje    out reclist.rlje%type,
                           o_message out varchar2) IS
    CURSOR C_MR IS
      SELECT *
        FROM METERREAD
       WHERE MRID = P_MRID
            --  AND MRIFREC = 'N'
         AND MRSL >= 0 --20140522 0用水允许算费
         FOR UPDATE NOWAIT;
  
    --总分表子表抄表记录
    /*    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2) IS
    SELECT MRSL, MRIFREC, MRREADOK
      FROM METERINFO, METERREAD
     WHERE MRMID = MIID
       AND MIPID = P_MPID;*/
  
    --20140512 总表截量修改
    --总表截量=子表换表余量（M）+子表换表后当月抄见水量（1）
    --追量收费的
    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRREADOK, nvl(MRCARRYSL, 0) MRCARRYSL --校验水量
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
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --周期换表、故障换表
         AND RLREVERSEFLAG = 'N';
  
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
      SELECT * FROM METERINFO WHERE MIID = P_MID;
    --总表有周期换表、故障换表的余量抓取  20140809
    CURSOR C_MI_CLASS(P_MRMID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT nvl(DECODE(NVL(SUM(MRADDSL), 0), 0, SUM(MRSL), SUM(MRADDSL)),
                 0)
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MRMID = P_MRMID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --周期换表、故障换表
         AND RLREVERSEFLAG = 'N' --未冲正
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
  
    V_SUMNUM      NUMBER; --子表数
    V_READNUM     NUMBER; --抄见子表数
    V_RECNUM      NUMBER; --算费子表数
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
      -- RAISE_APPLICATION_ERROR(ERRCODE, '无效的抄表计划流水号');
      o_rlje    := 0;
      o_message := '无效的抄表计划流水号或此水表已经算费';
      return;
    END IF;
  
    --抄表数据来源  1表示计划抄表   5表示手持抄表机   9表示手机抄表机
    IF MR.MRSL < 最低算费水量 AND MR.MRDATASOURCE IN ('1', '5', '9', '2') AND
       (MR.MRRPID = '00' OR MR.MRRPID IS NULL) THEN
      o_rlje    := 0;
      o_message := '抄表水量小于最低算费水量，不需要算费';
      return;
      /*    RAISE_APPLICATION_ERROR(ERRCODE,
      '抄表水量小于最低算费水量，不需要算费');
      */
    END IF;
    --水表记录
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('无效的水表编号' || MR.MRMID);
      --  RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
      o_rlje    := 0;
      o_message := '无效的水表编号' || MR.MRMID;
      return;
    
    END IF;
    CLOSE C_MI;
  
    /*  IF  MI.mistatus='24' AND MR.MRDATASOURCE <> 'M' THEN --如果表状态为故障换表中且此抄表记录来源不是故障抄表余量，则提示不能算费，有故障换表
         WLOG('此水表编号正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.' || MR.MRMID);
        -- RAISE_APPLICATION_ERROR(ERRCODE, '此水表编号['|| MR.MRMID||']正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.');
         o_rlje :=0 ;
         o_message := '此水表编号['|| MR.MRMID||']正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.';
        return ;
    END IF ;
     
    IF  MI.mistatus='35' AND MR.MRDATASOURCE <> 'L' THEN --如果表状态为周期换表中且此抄表记录来源不是周期抄表余量，则提示不能算费，有周期换表
         WLOG('此水表编号正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.' || MR.MRMID);
        -- RAISE_APPLICATION_ERROR(ERRCODE, '此水表编号['|| MR.MRMID||']正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.');
          o_rlje :=0 ;
         o_message := '此水表编号['|| MR.MRMID||']正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.';
        return ;
     END IF ;
     
     if  MI.mistatus='36'  then  --预存冲正中
             WLOG('此水表编号正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.' || MR.MRMID);
        -- RAISE_APPLICATION_ERROR(ERRCODE, '此水表编号['|| MR.MRMID||']正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.');
          o_rlje :=0 ;
         o_message :=  '此水表编号['|| MR.MRMID||']正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.';
        return ;
     end if ;
     
     if  MI.mistatus='19'  then  --销户中
             WLOG('此水表编号正在销户中,不能进行算费,如需算费请先审核销户单据或删除销户单据.' || MR.MRMID);
        --  RAISE_APPLICATION_ERROR(ERRCODE, '此水表编号['|| MR.MRMID||']正在销户中,不能进行算费,如需算费请先审核销户或删除销户单据.');
            o_rlje :=0 ;
         o_message :='此水表编号['|| MR.MRMID||']正在销户中,不能进行算费,如需算费请先审核销户或删除销户单据.';
        return ;
     end if ;*/
  
    -------
    MR.MRRECSL := MR.MRSL; --本期水量
    -----------------------------------------------------------------------------
    --子表水量抵减计费总表抄见水量
    -----------------------------------------------------------------------------
    IF 总表截量 = 'Y' THEN
    
      --######总分表算费   20140412 BY HK#######
      /*
      规则：
      1、同一表册，分表先算费，算费同普通表
      2、总表需要先判断分表是否都已算费，分表全算费了才允许总表算费
      3、总表按总表截量算费（总表抄见 - 分表抄见和），如果总表截量小于0，则总表不算费
      */
      --MICLASS：普通表=1，总表=2，分表=3
    
      /*    --STEP1 检查是否总表
      SELECT MICLASS, MIPID
        INTO V_MICLASS, V_MIPID
        FROM METERINFO
       WHERE MICODE = MR.MRMCODE;--20150328取消重复取meterinfo*/
    
      IF mi.MICLASS = 2 THEN
        --是总表
        V_MRMCODE := MR.MRMCODE; --赋值为总表号
      
        --STEP2 判断总表下的分表中是否存在未抄子表 （子表未月初或未抄见）和未算费子表
        /*      SELECT COUNT(*),
              SUM(DECODE(NVL(MRREADOK, 'N'), 'Y', 1, 0)),
              SUM(DECODE(NVL(MRIFREC, 'N'), 'Y', 1, 0))
         INTO V_SUMNUM, V_READNUM, V_RECNUM
         FROM METERINFO, METERREAD
        WHERE MIID = MRMID(+)
          AND MIPID = V_MRMCODE
          AND MICLASS = '3';*/
        --20150325 调整 因预算费还未算费  HB
        SELECT COUNT(*),
               SUM(DECODE(NVL(MRREADOK, 'N'), 'Y', 1, 'X', 1, 0)), --因抄表返回记录为X
               SUM(DECODE(NVL(MRIFREC, 'N'), 'Y', 1, 0))
          INTO V_SUMNUM, V_READNUM, V_RECNUM
          FROM METERINFO, METERREAD
         WHERE MIID = MRMID(+)
           AND MIPID = V_MRMCODE
           AND MICLASS = '3';
      
        --如果子表数和大于子表已抄见数和，则存在未抄子表
        IF V_SUMNUM > V_READNUM THEN
          WLOG('抄表记录' || MR.MRID || '总分表中包含未抄子表，暂停产生费用');
          --   RAISE_APPLICATION_ERROR(ERRCODE,  '总分表中包含未抄子表，暂停产生费用');
          o_rlje    := 0;
          o_message := '总分表中包含未抄子表，暂停产生费用';
          return;
        
        END IF;
      
        -- 20150325 取消
        --20140512 总分表分表已抄见就让算费
        --如果子表数和大于子表已算费数和，则存在未算费子表
        /*        IF V_SUMNUM>V_RECNUM THEN
            WLOG('抄表记录' || MR.MRID || '收费总表发现子表未计费，暂停产生费用');
        --   RAISE_APPLICATION_ERROR(ERRCODE,   '收费总表子表未计费，暂停产生费用');
             o_rlje :=0 ;
              o_message :='总分表中包含未抄子表，暂停产生费用';
             return ;
         
          END IF;*/
        --add modiby  20140809  hb 
        --总表本月抄表产生账务明细时,抓取本月是否有做故障换表，有的话抓取故障换表余量
      
        OPEN C_MI_CLASS(V_MRMCODE, MR.MRMONTH);
        FETCH C_MI_CLASS
          INTO V_MDHIS_ADDSL; --故障换表余量
        IF C_MI_CLASS%NOTFOUND OR C_MI_CLASS%NOTFOUND IS NULL THEN
          V_MDHIS_ADDSL := 0;
        END IF;
        CLOSE C_MI_CLASS;
      
        V_PD_ADDSL := V_MDHIS_ADDSL; --判断水量=故障换表余量
      
        OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
        LOOP
          FETCH C_MR_CHILD
            INTO MRCHILD.MRSL,
                 MRCHILD.MRIFREC,
                 MRCHILD.MRREADOK,
                 MRCHILD.MRCARRYSL;
          EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
          --判断的水量 V_PD_ADDSL 实际为故障换表水量
          V_PD_ADDSL := V_PD_ADDSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
          --总表故障换表水量 =总表故障换表水量 -子表抄表水量 - 子表校验水量 modiby hb 20140614
        END LOOP;
        CLOSE C_MR_CHILD;
      
        if V_PD_ADDSL < 0 then
          --下述包含三种情况
          --1总表换表时 余量-分表总出账 小于0时不出账   不出账
          --2总表抄见时,如果有故障换表 则抄见水量=抄见水量+换表余量 -分表总出账   出账
          --3 总表故障换表 、分表出账后水量够减， 总表出账
          MR.MRRECSL := MR.MRRECSL + V_MDHIS_ADDSL;
          --end add 20140809 
          --STEP3 判断总分表收费总表水量是否小于子表水量
          --取正常子表水量算截量
          OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
          LOOP
            FETCH C_MR_CHILD
              INTO MRCHILD.MRSL,
                   MRCHILD.MRIFREC,
                   MRCHILD.MRREADOK,
                   MRCHILD.MRCARRYSL;
            EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
            --抵消水量
            MR.MRRECSL := MR.MRRECSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
            --总表应收水量 =总表抄表水量 -子表抄表水量 - 子表校验水量 modiby hb 20140614
          END LOOP;
          CLOSE C_MR_CHILD;
        
        else
          --4  总表本月有做故障换表，故障换表余量大于分表总量时，总表再次做抄表，出账水量就等于总表抄见水量
          MR.MRRECSL := MR.MRRECSL;
        end if;
      
        --如果收费总表水量小于子表水量，暂停产生费用
        IF MR.MRRECSL < 0 THEN
          --如果总表截量小于0，则总表停算费用
          WLOG('抄表记录' || MR.MRID || '收费总表水量小于子表水量，暂停产生费用');
          --  RAISE_APPLICATION_ERROR(ERRCODE,  '收费总表水量小于子表水量，暂停产生费用');
          o_rlje    := 0;
          o_message := '收费总表水量小于子表水量，暂停产生费用';
          return;
        END IF;
      
      END IF;
    END IF;
  
    o_rlje    := 0;
    o_message := '未执行算费';
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
        /*      IF MRL.mrifrec = 'N' AND MRL.MRIFSUBMIT = 'Y' AND MRL.MRIFHALT = 'N' AND
        MIL.MIIFCHARGE = 'Y' AND
        FCHKMETERNEEDCHARGE(MIL.MISTATUS, MIL.MIIFCHK, '1') = 'Y' THEN*/
        --正常算费
        CALCULATE_YSFD(MRL,
                       PG_EWIDE_METERTRANS_01.计划抄表,
                       '0000.00',
                       o_rlje,
                       o_message);
        /*      ELSIF MIL.MIIFCHARGE = 'N' OR MRL.MRIFHALT = 'Y' THEN
        --计量不计费,将数据记录到费用库
        CALCULATENP(MRL, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');*/
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
      --正常算费
      CALCULATE_YSFD(MR,
                     PG_EWIDE_METERTRANS_01.计划抄表,
                     '0000.00',
                     o_rlje,
                     o_message);
      /*    ELSIF MI.MIIFCHARGE = 'N' OR MR.MRIFHALT = 'Y' THEN
      --计量不计费,将数据记录到费用库
      CALCULATENP(MR, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');*/
      /*    END IF;*/
    
    END IF;
    -----------------------------------------------------------------------------
    --更新当前抄表记录 手机抄表不更新预算费
    UPDATE METERREAD
       SET MRPLANSL   = MR.MRPLANSL, --应收水量
           MRPLANJE01 = MR.MRPLANJE01,
           MRPLANJE02 = MR.MRPLANJE02,
           MRPLANJE03 = MR.MRPLANJE03,
           MRYEARJE01 = MR.MRYEARJE01, --水费
           MRYEARJE02 = MR.MRYEARJE02, --污水费
           MRYEARJE03 = MR.MRYEARJE03 --附加费
     WHERE CURRENT OF C_MR;
  
    /*  IF 是否审批算费 = 'N' THEN
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
  
    CURSOR C_PD(VPFID IN PRICEDETAIL.PDPFID%TYPE) IS
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
    V_表的验效数量   NUMBER(10);
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
    V_TEST      VARCHAR2(2000);
  
    CURSOR C_HS_METER(C_MIID VARCHAR2) IS
      SELECT MIID FROM METERINFO WHERE MIPRIID = C_MIID;
  
    V_HS_METER METERINFO%ROWTYPE;
    V_PSUMRLJE RECLIST.RLJE%TYPE;
    V_HS_RLIDS VARCHAR2(1280); --应收流水
    V_HS_RLJE  NUMBER(12, 2); --应收金额
    V_HS_ZNJ   NUMBER(12, 2); --滞纳金
    V_HS_SXF   NUMBER(12, 2); --手续费
    V_HS_OUTJE NUMBER(12, 2);
  
    --预存自动抵扣
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
         and RLBADFLAG = 'N' --add 20151217 添加呆坏帐过滤条件
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
    
    --byj add 判断起码是否改变!!!
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L') then
       --水表起码已经改变
       WLOG('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || MR.MRMID);
       RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    end if;
    --end!!!
    
    DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;
    --非计费表执行空过程，不抛异常
    --合收子表
    if md.ifdzsb = 'Y' THEN
      --如果是倒表 要判断一下指针的问题
      IF MR.MRECODE > MR.MRSCODE THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '是倒表用户,起码应大于止码');
      END IF;
    elsif mi.miyl1 <> 'Y' and mi.miyl9 is null then
        if MR.MRECODE < MR.MRSCODE then
           RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '不是倒表、等针、超量程用户,起码应小于止码');
        end if;
  
    /*ELSE
      if MR.MRECODE < MR.MRSCODE  then
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '不是倒表用户,起码应小于止码');
      end if;*/
    END IF;
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
      RL.RLREADSL  := MR.MRRECSL; --reclist抄见水量 = Mr.抄见水量+mr 校验水量
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
      --ZHW2O160329修改---start
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
      IF MI.MIPRIFLAG = 'Y' THEN
        RL.RLPRIMCODE := MI.MIPRIID; --记录合收子表串
      ELSE
        RL.RLPRIMCODE := RL.RLMID;
      END IF;
    
      RL.RLPRIFLAG := MI.MIPRIFLAG;
      IF MR.MRRPER IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '的抄表员不能为空!');
      END IF;
      RL.RLRPER      := MR.MRRPER;
      RL.RLSAFID     := MR.MRSAFID;
      RL.RLSCODECHAR := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP     := '1'; --应收帐分组
    
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
    
      --reclist↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      --计费调整
      --策略02 仅按水表
      --表的调整量 调整应收水量，调整方法=（02，03，04，05，06）
      V_表的调整量   := 0;
      V_表减后水量值 := RL.RLREADSL;
      V_表的验效数量 := MR.MRCARRYSL; --效验数量
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
    
      --费用明细算法说明：
      --1、若存在混合费率即按其生成费用明细包，亦即是混合费率优先级最高；
      --2、否则户表费率游标内生成费用明细数据；
      --3、无论以上生成方式下，游标匹配优惠数据，重算费用明细；
      --重要规则；优惠生效前提是户表必须具备正常的户表费率，否则优惠无调整的目标
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN
      
        ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---
        temp_PALTAB := NULL;
        PALTAB      := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);
        if PALTAB is not null then
          temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
          .palcaliber IS NOT NULL THEN
          MI.MIPFID := temp_PALTAB(1).palcaliber;
          --覆盖应收帐水价
          rl.rlpfid := MI.MIPFID;
        end if;
        ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---
      
        --策略07 按水表+价格类别
        --表费的调整量 调整综合单价，调整方法=（01 固定单价调整）
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
          
            ---########  相当于临时水价类别调整，哈尔滨无此业务  ########--- 
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
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
            ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---
          
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
                    V_表的验效数量,
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
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
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
                    V_表的验效数量,
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
        
          temp_PALTAB := NULL;
          PALTAB      := NULL;
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    MI.MIPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '按水表+价格类别',
                    PALTAB);
          if PALTAB is not null then
            temp_PALTAB := f_getpfid(PALTAB);
          end if;
          if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
            .palcaliber IS NOT NULL THEN
            PMD.PMDPFID := temp_PALTAB(1).palcaliber;
            --覆盖应收帐水价
            rl.rlpfid := PMD.PMDPFID;
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
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
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
                      V_表的验效数量,
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
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
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
                      V_表的验效数量,
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
    
      --   RL.RLREADSL := MR.MRSL; 
      if MI.MICLASS = '2' then
        --总分表
        RL.RLREADSL := MR.MRSL + nvl(MR.MRCARRYSL, 0); --如果为合收表，则rl的抄见水量为mr抄表水量+mr校验水量
      else
        RL.RLREADSL := MR.MRRECSL + nvl(MR.MRCARRYSL, 0); --reclist抄见水量 = Mr.抄见水量+mr 校验水量
      end if;
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
                end if;
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
          IF MI.MIPRIID IS NOT NULL AND MI.MIPRIFLAG = 'Y' THEN
            --总预存
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
                  V_RETSTR   := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                    MI.MISMFID, --缴费机构
                                                    'system', --收款员
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
                                                'system', --收款员
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

  -- 手机抄表预算费子过程
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
    V_表的验效数量   NUMBER(10);
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
    V_TEST      VARCHAR2(2000);
  
    CURSOR C_HS_METER(C_MIID VARCHAR2) IS
      SELECT MIID FROM METERINFO WHERE MIPRIID = C_MIID;
  
    V_HS_METER METERINFO%ROWTYPE;
    V_PSUMRLJE RECLIST.RLJE%TYPE;
    V_HS_RLIDS VARCHAR2(1280); --应收流水
    V_HS_RLJE  NUMBER(12, 2); --应收金额
    V_HS_ZNJ   NUMBER(12, 2); --滞纳金
    V_HS_SXF   NUMBER(12, 2); --手续费
    V_HS_OUTJE NUMBER(12, 2);
  
    --预存自动抵扣
    v_rlidlist   varchar2(4000);
    v_rlid       reclist.rlid%type;
    v_rlje       number(12, 3);
    v_znj        number(12, 3);
    v_rljes      number(12, 3);
    v_znjs       number(12, 3);
    v_rlje_sf    number(12, 3);
    v_rlje_wsf   number(12, 3);
    v_rlje_fjf   number(12, 3);
    v_rlje_qf    number(12, 3); --上期预存余额
    v_rlje_qf1   number(12, 3); --本期预存余额
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
    --20150325 抓取
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
    /*    固定金额标志   := FPARA(MR.MRSMFID, 'GDJEFLAG');
    固定金额最低值 := FPARA(MR.MRSMFID, 'GDJEZ');*/
  
    --锁定水表记录
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('无效的水表编号' || MR.MRMID);
      -- RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
      o_rlje    := 0;
      o_message := '无效的水表编号';
      return;
    END IF;
    --锁定水表档案
    OPEN C_MD(MR.MRMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      WLOG('无效的水表档案' || MR.MRMID);
      -- RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
      o_rlje    := 0;
      o_message := '无效的水表编号';
      return;
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
      --  RAISE_APPLICATION_ERROR(ERRCODE, '无效的用户编号' || MI.MICID);
      o_rlje    := 0;
      o_message := '无效的用户编号';
      return;
    
    END IF;
  
    -- DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;   20150309
  
    --非计费表执行空过程，不抛异常
    --合收子表
    IF TRUE THEN
      --reclist↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
      if mr.mrdatasource <> '9' THEN
        --预算费时，如果来源为9则不进行id递增
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
          mr.mrsl := v_mrsl; --reclist抄见水量 = Mr.抄见水量+mr 校验水量
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
      --  RL.RLRTID    := MI.MIRTID;--20150309 抄表方式调整
      RL.RLRTID    := MR.Mrdatasource; --抄表方式
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
        RL.RLREADSL := v_MRRECSL; --reclist抄见水量 = Mr.抄见水量+mr 校验水量
      end if;*/
      RL.RLREADSL := MR.MRRECSL; --reclist抄见水量 = Mr.抄见水量+mr 校验水量
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
      IF MI.MIPRIFLAG = 'Y' THEN
        RL.RLPRIMCODE := MI.MIPRIID; --记录合收子表串
      ELSE
        RL.RLPRIMCODE := RL.RLMID;
      END IF;
    
      RL.RLPRIFLAG   := MI.MIPRIFLAG;
      RL.RLRPER      := MR.MRRPER;
      RL.RLSAFID     := MR.MRSAFID;
      RL.RLSCODECHAR := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP     := '1'; --应收帐分组
    
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
    
      --reclist↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      --计费调整
      --策略02 仅按水表
      --表的调整量 调整应收水量，调整方法=（02，03，04，05，06）
      V_表的调整量   := 0;
      V_表减后水量值 := RL.RLREADSL;
      V_表的验效数量 := MR.MRCARRYSL; --效验数量
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
    
      --费用明细算法说明：
      --1、若存在混合费率即按其生成费用明细包，亦即是混合费率优先级最高；
      --2、否则户表费率游标内生成费用明细数据；
      --3、无论以上生成方式下，游标匹配优惠数据，重算费用明细；
      --重要规则；优惠生效前提是户表必须具备正常的户表费率，否则优惠无调整的目标
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN
      
        ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---
        temp_PALTAB := NULL;
        PALTAB      := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);
        if PALTAB is not null then
          temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
          .palcaliber IS NOT NULL THEN
          MI.MIPFID := temp_PALTAB(1).palcaliber;
          --覆盖应收帐水价
          rl.rlpfid := MI.MIPFID;
        end if;
        ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---
      
        --策略07 按水表+价格类别
        --表费的调整量 调整综合单价，调整方法=（01 固定单价调整）
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
          
            ---########  相当于临时水价类别调整，哈尔滨无此业务  ########--- 
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
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
            ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---
          
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
                    V_表的验效数量,
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
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
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
                    V_表的验效数量,
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
        
          temp_PALTAB := NULL;
          PALTAB      := NULL;
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    MI.MIPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '按水表+价格类别',
                    PALTAB);
          if PALTAB is not null then
            temp_PALTAB := f_getpfid(PALTAB);
          end if;
          if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
            .palcaliber IS NOT NULL THEN
            PMD.PMDPFID := temp_PALTAB(1).palcaliber;
            --覆盖应收帐水价
            rl.rlpfid := PMD.PMDPFID;
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
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
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
                      V_表的验效数量,
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
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
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
                      V_表的验效数量,
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
    
      --   RL.RLREADSL := MR.MRSL; 
      if MI.MICLASS = '2' then
        --总分表
        RL.RLREADSL := MR.MRSL + nvl(MR.MRCARRYSL, 0); --如果为合收表，则rl的抄见水量为mr抄表水量+mr校验水量
      else
        RL.RLREADSL := MR.MRRECSL + nvl(MR.MRCARRYSL, 0); --reclist抄见水量 = Mr.抄见水量+mr 校验水量
      end if;
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
                --20150309取消
                /*             IF 是否审批算费 = 'N' THEN
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
            --20150309取消
            /*          IF 是否审批算费 = 'N' THEN
              INSERT INTO RECLIST VALUES RL1;
            ELSE
              INSERT INTO RECLISTTEMP VALUES RL1;
            END IF;*/
            --20150309 end 取消
            /*          --预存自动扣款
            IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
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
      
        v_rlje_sf    := 0; --水费
        v_rlje_wsf   := 0; --污水费
        v_rlje_fjf   := 0; --附加费
        RL.RLJE      := 0;
        v_rlje_sfdj  := 0; --水费
        v_rlje_wsfdj := 0; --污水费
        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          RL.RLJE := RL.RLJE + RDTAB(I).RDJE;
          if RDTAB(I).rdpiid = '01' then
            v_rlje_sf := v_rlje_sf + RDTAB(I).RDJE; --水费
            --zhw20160415修改
            if RDTAB(I).RDPSCID <> '-1' then
              v_rlje_sfdj := TOOLS.GETMAX(v_rlje_sfdj, RDTAB(I).rddj);
            end if;
            ----------------------------------------end
          end if;
          if RDTAB(I).rdpiid = '02' then
            v_rlje_wsf := v_rlje_wsf + RDTAB(I).RDJE; --污水费
            --zhw20160415修改
            v_rlje_wsfdj := TOOLS.GETMAX(v_rlje_wsfdj, RDTAB(I).rddj);
            ----------------------------------------end
          end if;
          if RDTAB(I).rdpiid = '03' then
            v_rlje_fjf := v_rlje_fjf + RDTAB(I).RDJE; --附加费
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
          --设置 输入的数据  固定金额最低值
          if 固定金额标志 = 'Y' AND rl.rlje <= 固定金额最低值 THEN
            rl.rlje := round(固定金额最低值);
          END IF;
        */
        --add 20150309
        --
        if rl.rlje = 0 then
           select fun_getjtdqdj(MIPFID, MIPRIID, miid, '1') 水费单价,
                 fgetwsf(mipfid) 污水费单价
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
          --如果有算费，则上期预存余额、本期预存余额抓取之前记录的(含固定量)
          o_rlje     := mr.MRPLANJE01;
          v_rlje_qf  := mr.MRPLANJE02;
          v_rlje_qf1 := mr.MRPLANJE03;
        ELSE
          --add 20150325 上期预存余额=水表预存余额 -  历史欠费
          --v_rlje_qf := mi.misaving - v_sum_old_qf;
          v_rlje_qf := v_misaving  - v_sum_old_qf;
          --add 20150325 本期预存余额=水表预存余额 -  历史欠费 -本次应收合计
         -- v_rlje_qf1 := mi.misaving - v_sum_old_qf - rl.rlje;
          v_rlje_qf1 := mi.misaving - v_sum_old_qfhes - rl.rlje;
          --应收水量|应收水费|应收污水费|应收其它费用|应收合计|上期预存余额|本期预存余额
        END IF;
        mr.MRPLANSL   := rl.rlsl; --应收水量
        mr.MRPLANJE01 := o_rlje; --应收合计
        mr.MRPLANJE02 := v_rlje_qf; --(手机抄表算费上期预存)
        mr.MRPLANJE03 := v_rlje_qf1; --(手机抄表算费本期预存)
        mr.MRYEARJE01 := v_rlje_sf; --水费
        mr.MRYEARJE02 := v_rlje_wsf; --污水费
        mr.MRYEARJE03 := v_rlje_fjf; --附加费
      
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
        ---zhw 20160415修改增加水费和污水费价格
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
      
        --20150309  取消 
        /*      IF 是否审批算费 = 'N' THEN
            INSERT INTO RECLIST VALUES RL;
          ELSE
            INSERT INTO RECLISTTEMP VALUES RL;
          END IF;
        INSRD(RDTAB); */ --20150309  取消
      
        /*      --预存自动扣款  --20150309 预存取消
              IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
                IF MI.MIPRIID IS NOT NULL AND MI.MIPRIFLAG = 'Y' THEN
                  --总预存
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
                                                        'system', --收款员
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
                                                      'system', --收款员
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
              
              END IF;*/
      
      END IF;
    
    END IF;
  
    --add 2013.01.16      向reclist_charge_01表中插入数据
    --SP_RECLIST_CHARGE_01(RL.RLID, '1'); 20150309取消
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
  
    --下述20150309取消
    /*  UPDATE METERINFO
         SET MIRCODE     = MR.MRECODE,
             MIRECDATE   = MR.MRRDATE,
             MIRECSL     = MR.MRSL, --取本期水量（抄量）
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
  
    CURSOR C_PD(VPFID IN PRICEDETAIL.PDPFID%TYPE) IS
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
    V_表的验效数量   NUMBER(10);
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
    V_TEST      VARCHAR2(2000);
  
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
      RL.RLREADSL  := MR.MRRECSL;
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
      V_表的验效数量 := MR.MRCARRYSL; --效验数量
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
      
        temp_PALTAB := NULL;
        PALTAB      := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);
        if PALTAB is not null then
          temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
          .palcaliber IS NOT NULL THEN
          MI.MIPFID := temp_PALTAB(1).palcaliber;
          --覆盖应收帐水价
          rl.rlpfid := MI.MIPFID;
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
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
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
                    V_表的验效数量,
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
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
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
                    V_表的验效数量, --效验数量
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
        
          temp_PALTAB := NULL;
          PALTAB      := NULL;
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    MI.MIPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '按水表+价格类别',
                    PALTAB);
          if PALTAB is not null then
            temp_PALTAB := f_getpfid(PALTAB);
          end if;
          if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
            .palcaliber IS NOT NULL THEN
            PMD.PMDPFID := temp_PALTAB(1).palcaliber;
            --覆盖应收帐水价
            rl.rlpfid := PMD.PMDPFID;
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
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
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
                      V_表的验效数量,
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
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
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
                      V_表的验效数量,
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
      -- RL.RLREADSL := MR.MRSL;
      if MI.MICLASS = '2' then
        --合收表
        RL.RLREADSL := MR.MRSL + nvl(MR.MRCARRYSL, 0); --如果为合收表，则rl的抄见水量为mr抄表水量+mr校验水量
      else
        RL.RLREADSL := MR.MRRECSL + nvl(MR.MRCARRYSL, 0); --reclist抄见水量 = Mr.抄见水量+mr 校验水量
      end if;
    
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
          VRD := RDTAB(I);
        
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
      if PALTAB(I).PALTACTIC in ('02', '07', '09') then
      
        --固定单价调整
        IF PALTAB(I).PALMETHOD = '01' THEN
          null; --水量无变化
        end if;
      
        --固定量调整
        IF PALTAB(I).PALMETHOD = '02' THEN
        
          /*20131206 确认：当月修改当月生效，之前的月份不累计计费调整*/
          NMONTH := 1; --计费时段月数
          /* BEGIN
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
          END IF;*/
        
          --增加为1 减免为-1
          IF PALTAB(I).PALWAY = 0 then
            P_减后水量值 := PALTAB(I).PALVALUE;
          else
            IF P_减后水量值 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY * NMONTH >= 0 THEN
              IF P_基础量累计是与否 = 'Y' THEN
                P_减后水量值 := P_减后水量值 + PALTAB(I)
                          .PALVALUE * PALTAB(I).PALWAY * NMONTH;
              END IF;
              P_调整量 := P_调整量 + PALTAB(I)
                      .PALVALUE * PALTAB(I).PALWAY * NMONTH;
            ELSE
              P_调整量 := P_调整量 - P_减后水量值;
              IF P_基础量累计是与否 = 'Y' THEN
                P_减后水量值 := 0;
              END IF;
            end if;
          
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
            if P_RL.RLRTID <> '9' then
              --手机抄表预算费不写资料 20150309
              UPDATE PRICEADJUSTLIST
                 SET PALVALUE = 0
               WHERE PALID = PALTAB(I).PALID;
            end if;
          ELSE
            --更新累计量
            if P_RL.RLRTID <> '9' then
              --手机抄表预算费不写资料 20150309
              UPDATE PRICEADJUSTLIST
                 SET PALVALUE = PALVALUE - P_减后水量值
               WHERE PALID = PALTAB(I).PALID;
            end if;
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

  --调整水价+费用项目函数   BY WY 20130531   
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
                    P_表的调整量     IN NUMBER,
                    P_表费的调整量   IN NUMBER,
                    P_表费项目调整量 IN NUMBER,
                    p_表的验效数量   IN NUMBER,
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
  
    RD.RDID       := P_RL.RLID; --流水号 
    RD.RDPMDID    := P_PMDID; --混合用水分组 
    RD.RDPMDSCALE := P_PMDSCALE; --混合比例  
    RD.RDPIID     := PD.PDPIID; --费用项目  
    RD.RDPFID     := PD.PDPFID; --费率  
    RD.RDPSCID    := PD.PDPSCID; --费率明细方案  
    RD.RDYSDJ     := 0; --应收单价 
    RD.RDYSSL     := 0; --应收水量 
    RD.RDYSJE     := 0; --应收金额 
  
    RD.RDADJDJ    := 0; --调整单价 
    RD.RDADJSL    := 0; --调整水量 
    RD.RDADJJE    := 0; --调整金额 
    RD.RDMETHOD   := PD.PDMETHOD; --计费方法 
    RD.RDPAIDFLAG := 'N'; --销帐标志 
  
    RD.RDMSMFID     := P_RL.RLMSMFID; --营销公司
    RD.RDMONTH      := P_RL.RLMONTH; --帐务月份
    RD.RDMID        := P_RL.RLMID; --水表编号
    RD.RDPMDTYPE    := NVL(PMD.PMDTYPE, '01'); --混合类别
    RD.RDPMDCOLUMN1 := PMD.PMDCOLUMN1; --备用字段1
    RD.RDPMDCOLUMN2 := PMD.PMDCOLUMN2; --备用字段2
    RD.RDPMDCOLUMN3 := PMD.PMDCOLUMN3; --备用字段3
  
    /*    --yujia  2012-03-20
    固定金额标志   := FPARA(P_RL.RLMSMFID, 'GDJEFLAG');
    固定金额最低值 := FPARA(P_RL.RLMSMFID, 'GDJEZ');*/
  
    CASE PD.PDMETHOD
      WHEN 'dj1' THEN
        --固定单价  默认方式，与抄量有关  哈尔滨都是dj1
        BEGIN
          RD.RDCLASS := 0; --阶梯级别 
          RD.RDYSDJ  := PD.PDDJ; --应收单价 
          RD.RDYSSL  := P_SL + p_表的验效数量 - P_混合表调整量; --应收水量 
        
          RD.RDADJDJ := FGET调整单价(RD.RDMID, RD.RDPIID); --调整单价 
          RD.RDADJSL := P_表的调整量 + P_表费的调整量 + P_表费项目调整量 + P_混合表调整量; --调整水量 
          RD.RDADJJE := 0; --调整金额 
        
          RD.RDDJ := PD.PDDJ + RD.RDADJDJ; --实收单价 
          RD.RDSL := P_SL + RD.RDADJSL - P_混合表调整量; --实收水量 
        
          --计算调整
          RD.RDYSJE := ROUND(RD.RDYSDJ * RD.RDYSSL, 2); --应收金额 
          RD.RDJE   := ROUND(RD.RDDJ * RD.RDSL, 2); --实收金额 
        
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
          --  RD.RDADJSL := 0;
          -- modify by hb 20140703 明细调整水量等于reclist调整水量
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

  /*  --阶梯计费步骤
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
        \*
        ┌───────────────────────────────────────────────────────────────────────────────────────────────┐
        │武汉水务阶梯规则（户/人均用水量以同一地址的所有水表用水量之和为基础计算）                      │
        │1、家庭户籍人口在4人以下（含4人）的用水户，按户用水量划分阶梯式计量水价。                      │
        │2、家庭户籍人口在5人（含5人）以上的用水户，按人均用水量划分阶梯式计量水价。                    │
        ┌─────────┬───────────────────────┬───────────────────────────────────┬─────────────────────────┐
        │按户计算 │户用水量≤ 25立方米     │25立方米＜户用水量≤33立方米        │户用水量＞ 33立方米      │
        │按人计算 │人均用水量≤ 6.25立方米 │6.25立方米＜人均用水量≤ 8.25立方米 │人均用水量＞ 8.25立方米  │
        │水价     │1.1                    │1.65                               │2.2                      │
        └─────────┴───────────────────────┴───────────────────────────────────┴─────────────────────────┘
        *\ --一阶止二阶起要求设置值相同，依此类推
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
        \*
        ┌───────────────────────────────────────────────────────────────────────────────────────────────┐
        │武汉水务阶梯规则（户/人均用水量以同一地址的所有水表用水量之和为基础计算）                      │
        │1、家庭户籍人口在4人以下（含4人）的用水户，按户用水量划分阶梯式计量水价。                      │
        │2、家庭户籍人口在5人（含5人）以上的用水户，按人均用水量划分阶梯式计量水价。                    │
        ┌─────────┬───────────────────────┬───────────────────────────────────┬─────────────────────────┐
        │按户计算 │户用水量≤ 25立方米     │25立方米＜户用水量≤33立方米        │户用水量＞ 33立方米      │
        │按人计算 │人均用水量≤ 6.25立方米 │6.25立方米＜人均用水量≤ 8.25立方米 │人均用水量＞ 8.25立方米  │
        │水价     │1.1                    │1.65                               │2.2                      │
        └─────────┴───────────────────────┴───────────────────────────────────┴─────────────────────────┘
        *\ --一阶止二阶起要求设置值相同，依此类推
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
        FROM PRICESTEP_VER
       WHERE PSPFID = PD.PDPFID
         AND PSPIID = PD.PDPIID
         AND VERID = PMONTH
       ORDER BY PSCLASS;
  
    TMPYSSL        NUMBER;
    TMPSL          NUMBER;
    RD             RECDETAIL%ROWTYPE;
    PS             PRICESTEP%ROWTYPE;
    N              NUMBER; --计费期数
    年累计水量     NUMBER;
    MINFO          METERINFO%ROWTYPE;
    USENUM         NUMBER; --计费人口数
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
  
    RD.RDMSMFID  := P_RL.RLMSMFID; --营销公司
    RD.RDMONTH   := P_RL.RLMONTH; --帐务月份
    RD.RDMID     := P_RL.RLMID; --水表编号
    RD.RDPMDTYPE := NVL(PMD.PMDTYPE, '01'); --混合类别
  
    TMPYSSL := P_SL; --阶梯累减应收水量余额
    TMPSL   := P_SL; --阶梯累减实收水量余额
    v_newmk := 'N';
    --取上次算费月份，以及阶梯开始月份
   select nvl(max(RLSCRRLMONTH), 'a'), nvl(max(RLJTSRQ), 'a'),nvl(max(rlmonth),'2015.12')
      into v_RLSCRRLMONTH, v_RLJTSRQold,v_rlmonth
      from reclist
     where rlmid = P_RL.rlmid
       and rlreverseflag = 'N';
    --第一次算费比进入阶梯
  
    SELECT * INTO bk FROM BOOKFRAME WHERE BFID = P_RL.RLBFID;
    --判断数据是否满足收取阶梯的条件
    SELECT MI.* INTO MINFO FROM METERINFO MI WHERE MI.miid = P_RL.rlmid;
    --判断人口
    /*  USENUM := NVL(MINFO.MIUSENUM, 0);*/
    --取合收表人口最大表的用户数
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
          --跨年的情况
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
    --取日期
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
    -- 第一次算费不进入阶梯 
    --by wlj 20170321  2016年1月起（含一月）首次抄表不计入阶梯
    IF P_RL.RLJTMK = 'Y' or v_RLSCRRLMONTH = 'a' or p_rl.rltrans in('14', '21') or v_rlmonth <='2015.12' then
      v_rljtmk := 'Y';
    ELSE
      v_rljtmk := 'N';
    END IF;
    --没有跨阶梯年月程序处理
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
      年累计水量      := TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), 0) + P_SL;
      IF PMONTH = '0000.00' OR PMONTH IS NULL or PMONTH = '指定' THEN
        OPEN C_PS;
        FETCH C_PS
          INTO PS;
        IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
        END IF;
        WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --居民水费阶梯数量跟户籍人数有关
          -- if nvl(p_rl.rlusenum, 0) >= 4 then
          IF ps.psscode = 0 THEN
            ps.psscode := 0;
          ELSE
            ps.psscode := round((ps.psscode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
          END IF;
          ps.psecode := round((ps.psecode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
        
          -- end if;
          --RD.RDPMDCOLUMN1 := PS.PSSCODE; --银川阶梯段起算量
          --RD.RDPMDCOLUMN2 := PS.PSECODE; --银川阶梯段止算量
          RD.RDCLASS := PS.PSCLASS;
          RD.RDYSDJ  := PS.psprice;
          RD.RDYSSL := case
                         when v_rljtmk = 'Y' then
                          TMPYSSL
                         else
                          case
                            when 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                             年累计水量 - TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                  PS.PSSCODE)
                            when 年累计水量 >= PS.PSECODE then
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
                          when 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                           年累计水量 -
                           TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                          when 年累计水量 > PS.PSECODE then
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
            /*if 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
               RD.RDPMDCOLUMN1 := PS.PSECODE - 年累计水量;
            else*/
            RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
            if 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
              RD.RDPMDCOLUMN2 := 年累计水量 - PS.PSSCODE;
            elsif 年累计水量 > PS.PSECODE then
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
          --汇总
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
          --累减后带入下一行游标
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
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
        END IF;
        WHILE C_PS_JT%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --居民水费阶梯数量跟户籍人数有关
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
                            when 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                             年累计水量 - TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                  PS.PSSCODE)
                            when 年累计水量 > PS.PSECODE then
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
                          when 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                           年累计水量 -
                           TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                          when 年累计水量 > PS.PSECODE then
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
            /*if 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
               RD.RDPMDCOLUMN1 := PS.PSECODE - 年累计水量;
            else*/
            RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
            if 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
              RD.RDPMDCOLUMN2 := 年累计水量 - PS.PSSCODE;
            elsif 年累计水量 > PS.PSECODE then
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
          --汇总
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
      --跨年，需要按用水月份比例拆分
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
        TMPYSSL := P_SL - round(P_SL * v_jgyf / v_jtny); --阶梯累减应收水量余额
        TMPSL   := P_SL - round(P_SL * v_jgyf / v_jtny); --阶梯累减实收水量余额 
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
      年累计水量      := TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), 0) +
                    (P_SL - round(P_SL * v_jgyf / v_jtny));
      --计算去年的阶梯
      IF PMONTH = '0000.00' OR PMONTH IS NULL or PMONTH = '指定' THEN
        OPEN C_PS;
        FETCH C_PS
          INTO PS;
        IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
        END IF;
        WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --居民水费阶梯数量跟户籍人数有关
          -- if nvl(p_rl.rlusenum, 0) >= 4 then
          IF ps.psscode = 0 THEN
            ps.psscode := 0;
          ELSE
            ps.psscode := round((ps.psscode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
          END IF;
          ps.psecode := round((ps.psecode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
        
          -- end if;
          --RD.RDPMDCOLUMN1 := PS.PSSCODE; --银川阶梯段起算量
          --RD.RDPMDCOLUMN2 := PS.PSECODE; --银川阶梯段止算量
          RD.RDCLASS := PS.PSCLASS;
          RD.RDYSDJ  := PS.psprice;
          RD.RDYSSL := case
                         when v_rljtmk = 'Y' then
                          TMPYSSL
                         else
                          case
                            when 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                             年累计水量 - TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                  PS.PSSCODE)
                            when 年累计水量 > PS.PSECODE then
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
                          when 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                           年累计水量 -
                           TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                          when 年累计水量 > PS.PSECODE then
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
            /*if 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
               RD.RDPMDCOLUMN1 := PS.PSECODE - 年累计水量;
            else*/
            RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
            if 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
              RD.RDPMDCOLUMN2 := 年累计水量 - PS.PSSCODE;
            elsif 年累计水量 > PS.PSECODE then
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
          --汇总
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
          --累减后带入下一行游标
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
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
        END IF;
        WHILE C_PS_JT%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --居民水费阶梯数量跟户籍人数有关
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
                            when 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                             年累计水量 - TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                  PS.PSSCODE)
                            when 年累计水量 > PS.PSECODE then
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
                          when 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                           年累计水量 -
                           TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                          when 年累计水量 > PS.PSECODE then
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
            /*if 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
               RD.RDPMDCOLUMN1 := PS.PSECODE - 年累计水量;
            else*/
            RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
            if 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
              RD.RDPMDCOLUMN2 := 年累计水量 - PS.PSSCODE;
            elsif 年累计水量 > PS.PSECODE then
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
          --汇总
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
        TMPYSSL    := round(P_SL * (v_jgyf / v_jtny)); --阶梯累减应收水量余额
        TMPSL      := round(P_SL * (v_jgyf / v_jtny)); --阶梯累减实收水量余额 
      
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
        年累计水量      := TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), 0) +
                      (round(P_SL * v_jgyf / v_jtny));
        --计算去年的阶梯
        IF PMONTH = '0000.00' OR PMONTH IS NULL or PMONTH = '指定' THEN
          OPEN C_PS;
          FETCH C_PS
            INTO PS;
          IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
          END IF;
          WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
            --居民水费阶梯数量跟户籍人数有关
            -- if nvl(p_rl.rlusenum, 0) >= 4 then
            IF ps.psscode = 0 THEN
              ps.psscode := 0;
            ELSE
              ps.psscode := round((ps.psscode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
            END IF;
            ps.psecode := round((ps.psecode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
          
            -- end if;
            --RD.RDPMDCOLUMN1 := PS.PSSCODE; --银川阶梯段起算量
            --RD.RDPMDCOLUMN2 := PS.PSECODE; --银川阶梯段止算量
            RD.RDCLASS := PS.PSCLASS;
            RD.RDYSDJ  := PS.psprice;
            RD.RDYSSL := case
                           when v_rljtmk = 'Y' then
                            TMPYSSL
                           else
                            case
                              when 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                               年累计水量 - TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                    PS.PSSCODE)
                              when 年累计水量 > PS.PSECODE then
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
                            when 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                             年累计水量 -
                             TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                            when 年累计水量 > PS.PSECODE then
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
              /*if 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                 RD.RDPMDCOLUMN1 := PS.PSECODE - 年累计水量;
              else*/
              RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
              if 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                RD.RDPMDCOLUMN2 := 年累计水量 - PS.PSSCODE;
              elsif 年累计水量 > PS.PSECODE then
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
            --汇总
            P_RL.RLJE := P_RL.RLJE + RD.RDJE;
            P_RL.RLSL := P_RL.RLSL + (CASE
                           WHEN RD.RDPIID = '01' THEN
                            RD.RDSL
                           ELSE
                            0
                         END);
            --累减后带入下一行游标
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
            RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
          END IF;
          WHILE C_PS_JT%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
            --居民水费阶梯数量跟户籍人数有关
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
                              when 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                               年累计水量 - TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)),
                                                    PS.PSSCODE)
                              when 年累计水量 > PS.PSECODE then
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
                            when 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                             年累计水量 -
                             TOOLS.GETMAX(to_number(nvl(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                            when 年累计水量 > PS.PSECODE then
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
              /*if 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                 RD.RDPMDCOLUMN1 := PS.PSECODE - 年累计水量;
              else*/
              RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
              if 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                RD.RDPMDCOLUMN2 := 年累计水量 - PS.PSSCODE;
              elsif 年累计水量 > PS.PSECODE then
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
            --汇总
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
  
    /* --累计年阶梯
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
      P_RL.RLCOLUMN12 := 年累计水量;
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
  
  --批量算费 for pb 前台
  procedure submit_forpb(p_bfid in  varchar2,   --表册Id  
                         p_app  out number,     --返回码 1-成功 -1 有错误 
                         p_err  out varchar2    --错误信息 
  ) is
  CURSOR C_MR(VBFID IN VARCHAR2, VSMFID IN VARCHAR2) IS
      SELECT MRID，mrmid
        FROM METERREAD, METERINFO
       WHERE MRMID = MIID
         AND MRBFID = VBFID
         AND MRSMFID = VSMFID
         and METERINFO.mistatus not in ('24', '35', '36', '19') --算费时，故障换表中、周期换表中、预存冲销中、销户中的不进行算费,需把故障换表中、周期换表中单据审核完才能算费 20140628
         AND MRIFREC = 'N'            
         AND MRREADOK = 'Y' --抄见状态
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
    WLOG('提交算费，表册序列：' || P_BFID);
    
    FOR I IN 1 .. TOOLS.FBOUNDPARA(P_BFID) LOOP
      VBFID  := TOOLS.FGETPARA(P_BFID, I, 1);
      VSMFID := TOOLS.FGETPARA(P_BFID, I, 2);
      WLOG('正在算费表册号：' || VBFID || ' ...');
      OPEN C_MR(VBFID, VSMFID);
      LOOP
        FETCH C_MR INTO VMRID,vmrmid;
        EXIT WHEN C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL;
        --单条抄表记录处理
        BEGIN        
          CALCULATE(VMRID);
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            p_app := -1;
            ROLLBACK;
            --WLOG('抄表记录' || VMRID || '算费失败，已被忽略');
            p_err := p_err || sqlerrm || chr(13) || chr(10);
        END;
      END LOOP;
      CLOSE C_MR;
      WLOG('---------------------------------------------------');
    END LOOP;
  
    WLOG('算费过程处理完毕');
    VLOG := CALLOGTXT;
    
  exception
    when others then 
    p_app := -1;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  end;
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

