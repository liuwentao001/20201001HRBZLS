CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_RECZNJ_01" IS

  CURRENTDATE DATE := TOOLS.FGETSYSDATE;

  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2) IS
  BEGIN
    --稽查罚款收费
    IF P_DJLB = '7' THEN
      SP_RECZNJJM(P_BILLNO, P_PERSON, 'Y');
    ELSE
      RAISE_APPLICATION_ERROR(ERRCODE, P_BILLNO || '->1 无效的单据类别！');
    END IF;
  END;
  --滞纳金减免
  PROCEDURE SP_RECZNJJM(P_ZAHNO  IN VARCHAR2, --批次流水
                        P_PER    IN VARCHAR2, --操作员
                        P_COMMIT IN VARCHAR2 --提交标志
                        ) AS
    V_EXIST  NUMBER(10);
    ZNJDT    ZNJADJUSTDT%ROWTYPE;
    ZNJHD    ZNJADJUSTHD%ROWTYPE;
    ZNJL     ZNJADJUSTLIST%ROWTYPE;
    RL       RECLIST%ROWTYPE;
    RD       RECDETAIL%ROWTYPE;
    V_CHKSTR VARCHAR2(200);
    CURSOR C_ZNJADJUSTDT IS
      SELECT * FROM ZNJADJUSTDT WHERE ZADNO = P_ZAHNO FOR UPDATE;
  BEGIN
    BEGIN
      SELECT * INTO ZNJHD FROM ZNJADJUSTHD WHERE ZAHNO = P_ZAHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
    END;
    --检查减免额度
    /*    v_chkstr :=f_chkznjed( P_PER ,znjhd.zahno   ) ;
    if v_chkstr <>'Y' then
      RAISE_APPLICATION_ERROR(ERRCODE, v_chkstr);
    end if;*/
    IF ZNJHD.ZAHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '变更单已审核,不需再审!');
    END IF;
    IF ZNJHD.ZAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '变更单已取消,不能审!');
    END IF;
    ZNJHD.ZAHSHDATE := SYSDATE;
    OPEN C_ZNJADJUSTDT;
    LOOP
      FETCH C_ZNJADJUSTDT
        INTO ZNJDT;
      EXIT WHEN C_ZNJADJUSTDT%NOTFOUND OR C_ZNJADJUSTDT%NOTFOUND IS NULL;
      BEGIN
        SELECT * INTO RL FROM RECLIST WHERE RLID = ZNJDT.ZADRLID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '应收流水号[' || ZNJDT.ZADRLID || ']不存在');
      END;
      IF RL.RLCD <> 'DE' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '资料号[' || RL.RLMCODE || ']' || RL.RLMONTH || '月份' ||
                                '应收流水号[' || RL.RLID || ']已进行冲正处理，不能做减免！');
      END IF;
      IF ZNJDT.ZADPIID = 'NA' THEN
        IF RL.RLPAIDFLAG <> 'N' THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '资料号[' || RL.RLMCODE || ']' || RL.RLMONTH || '月份' ||
                                  '应收流水号[' || RL.RLID || ']已为销帐状态，不能做减免！');
        END IF;

      END IF;
      IF RL.RLOUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '资料号[' || RL.RLMCODE || ']' || RL.RLMONTH || '月份' ||
                                '应收流水号[' || RL.RLID ||
                                ']欠费信息已发到银行扣款，不能做减免！');
      END IF;
      UPDATE ZNJADJUSTLIST T
         SET ZALSTATUS = 'N'
       WHERE T.ZALRLID = ZNJDT.ZADRLID
         AND ZALSTATUS = 'Y';

      ZNJL.ZALRLID      := ZNJDT.ZADRLID; --减免应收流水
      ZNJL.ZALPIID      := ZNJDT.ZADPIID; --减免费用项目（全部为NA）
      ZNJL.ZALMID       := ZNJDT.ZADMID; --水表编号
      ZNJL.ZALMCODE     := ZNJDT.ZADMCODE; --水表号
      ZNJL.ZALMETHOD    := ZNJDT.ZADMETHOD; --减免方法（1、目标金额减免；2、比例金额减免；3、差额减免；4、调整起算日期）
      ZNJL.ZALVALUE     := ZNJDT.ZADVALUE; --减免金额/比例值
      ZNJL.ZALZNDATE    := ZNJDT.ZADZNDATE; --减免目标起算日
      ZNJL.ZALDATE      := ZNJHD.ZAHSHDATE; --减免日期
      ZNJL.ZALPER       := P_PER; --减免人员
      ZNJL.ZALBILLNO    := ZNJDT.ZADNO; --减免单据编号
      ZNJL.ZALBILLROWNO := ZNJDT.ZADROWNO; --减免单据行号
      ZNJL.ZALSTATUS    := 'Y'; --有效标志
      INSERT INTO ZNJADJUSTLIST VALUES ZNJL;

    END LOOP;
    CLOSE C_ZNJADJUSTDT;

    UPDATE ZNJADJUSTHD
       SET ZAHSHDATE = ZNJHD.ZAHSHDATE, ZAHSHPER = P_PER, ZAHSHFLAG = 'Y'
     WHERE ZAHNO = P_ZAHNO;
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_ZAHNO);
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --滞纳金减免取消
  PROCEDURE SP_RECZNJJMCANCEL(P_ZAHNO  IN VARCHAR2, --批次流水
                              P_PER    IN VARCHAR2, --操作员
                              P_COMMIT IN VARCHAR2 --提交标志
                              ) AS
    V_EXIST NUMBER(10);
    ZNJDT   ZNJADJUSTDT%ROWTYPE;
    ZNJHD   ZNJADJUSTHD%ROWTYPE;
    ZNJL    ZNJADJUSTLIST%ROWTYPE;
    RL      RECLIST%ROWTYPE;

    CURSOR C_ZNJADJUSTDT IS
      SELECT * FROM ZNJADJUSTDT WHERE ZADNO = P_ZAHNO FOR UPDATE;
  BEGIN
    BEGIN
      SELECT * INTO ZNJHD FROM ZNJADJUSTHD WHERE ZAHNO = P_ZAHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
    END;
    IF ZNJHD.ZAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '变更单已取消,不需取消审核!');
    END IF;
    IF ZNJHD.ZAHSHFLAG <> 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '变更单非审核状态,不需取消审核!');
    END IF;
    ZNJHD.ZAHSHDATE := SYSDATE;
    OPEN C_ZNJADJUSTDT;
    LOOP
      FETCH C_ZNJADJUSTDT
        INTO ZNJDT;
      EXIT WHEN C_ZNJADJUSTDT%NOTFOUND OR C_ZNJADJUSTDT%NOTFOUND IS NULL;
      SELECT * INTO RL FROM RECLIST WHERE RLID = ZNJDT.ZADRLID;
      IF RL.RLCD <> 'DE' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '资料号[' || RL.RLMCODE || ']' || RL.RLMONTH || '月份' ||
                                '应收流水号[' || RL.RLID || ']已进行冲正处理，不能做减免！');
      END IF;
      IF ZNJDT.ZADPIID = 'NA' THEN
        IF RL.RLPAIDFLAG <> 'N' THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '资料号[' || RL.RLMCODE || ']' || RL.RLMONTH || '月份' ||
                                  '应收流水号[' || RL.RLID || ']已为销帐状态，不能做减免！');
        END IF;
      ELSE

        BEGIN
          SELECT COUNT(RDID)
            INTO V_EXIST
            FROM RECDETAIL
           WHERE RDID = ZNJDT.ZADRLID
             AND RDPIID = ZNJDT.ZADPIID
             AND RDPAIDFLAG = 'Y';
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '应收流水号[' || ZNJDT.ZADRLID || ']不存在');
        END;
        IF V_EXIST > 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '资料号[' || RL.RLMCODE || ']' || RL.RLMONTH || '月份' ||
                                  '应收流水号[' || RL.RLID || ']已为销帐状态，不能做减免！');
        END IF;
      END IF;

      /*if rl.rloutflag='Y' then
         RAISE_APPLICATION_ERROR(ERRCODE,'资料号['||rl.rlMCODE||']'||rl.rlmonth||
         '月份'||'应收流水号['||rl.rlid ||']欠费信息已发到银行扣款，不能做取消减免！');
      end if;*/
    END LOOP;
    CLOSE C_ZNJADJUSTDT;
    --取消滞纳金减免信息
    UPDATE ZNJADJUSTLIST
       SET ZALSTATUS = 'N'
     WHERE ZALBILLNO = P_ZAHNO
       AND ZALSTATUS = 'Y';
    --更新单头信息
    UPDATE ZNJADJUSTHD
       SET ZAHSHDATE = ZNJHD.ZAHSHDATE, ZAHSHPER = P_PER, ZAHSHFLAG = 'Q'
     WHERE ZAHNO = P_ZAHNO;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --检查操作员是否有审批额度
  FUNCTION F_CHKZNJED(P_OPER IN VARCHAR2, P_WYDNO IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_WYDZNJ   NUMBER(13, 3);
    V_WYDVALUE NUMBER(13, 3);
    V_OAPVALUE NUMBER(13, 3);
  BEGIN
    --查询操作员额度
    SELECT T.OAPVALUE
      INTO V_OAPVALUE
      FROM OPERACCNTPARA T
     WHERE T.OAPTYPE = 'ZNJED'
       AND T.OAPOAID = P_OPER
       AND T.OAPFLAG = 'Y';

    --查询单头减免后金额
    SELECT SUM(NVL(WYDZNJ, 0))
      INTO V_WYDZNJ
      FROM WYJADJUSTDT T
     WHERE WYDNO = P_WYDNO;
    --查询实际金额
    SELECT SUM(NVL(T.WYDVALUE, 0))
      INTO V_WYDVALUE
      FROM WYJADJUSTHD T
     WHERE T.WYHNO = P_WYDNO;
    V_WYDZNJ := V_WYDZNJ - V_WYDVALUE;
    IF V_OAPVALUE >= V_WYDZNJ THEN
      RETURN 'Y';
    ELSE
      RETURN '实际减免额度为' || V_WYDZNJ || '元，但你能减免额度为' || V_OAPVALUE || '元';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '异常';
  END;
  --滞纳金减免功能使用
  PROCEDURE SP_ZNJJM_GETZNJLIST(P_CODE    IN VARCHAR2,
                                P_BFID    IN VARCHAR2,
                                P_MINDATE IN DATE,
                                P_MAXDATE IN DATE,
                                O_FLAG    OUT VARCHAR2) IS
    CURSOR C_RL IS
      SELECT RLID, RLMID, RLMCODE, RLZNDATE, RLJE, RLGROUP, RLSMFID, RLDATE
        FROM RECLIST A
       WHERE ((RLMCODE = P_CODE AND RLBFID = P_BFID) OR (RLMCODE = P_CODE) OR
             (RLBFID = P_BFID))
         AND (RLDATE >= P_MINDATE OR P_MINDATE IS NULL)
         AND (RLDATE <= P_MAXDATE OR P_MAXDATE IS NULL)
         AND RLCD = 'DE'
         AND RLPAIDFLAG IN ('N', 'V', 'K', 'W')
         AND RLOUTFLAG = 'N'
         AND A.RLREVERSEFLAG = 'N'
         AND RLJE > 0;

    V_ROW    NUMBER;
    V_RL     RECLIST%ROWTYPE;
    V_ZNJ    NUMBER(10, 2);
    V_ZNDATE VARCHAR2(20);
  BEGIN
    --客户代码，表册都为空
    IF P_CODE IS NULL AND P_BFID IS NULL THEN
      O_FLAG := 'N';
      RETURN;
    END IF;

    --判断客户代码在系统是否存在
    IF P_CODE IS NOT NULL THEN
      SELECT COUNT(*) INTO V_ROW FROM METERINFO WHERE MICODE = P_CODE;
      IF V_ROW <= 0 THEN
        O_FLAG := 'A';
        RETURN;
      END IF;
    END IF;

    --判断表册是否为存在
    IF P_BFID IS NOT NULL THEN
      SELECT COUNT(*) INTO V_ROW FROM BOOKFRAME WHERE BFID = P_BFID;
      IF V_ROW <= 0 THEN
        O_FLAG := 'B';
        RETURN;
      END IF;
    END IF;

    --游标读取信息（滞纳金大于0）
    DELETE PBPARMTEMP;
    OPEN C_RL;
    LOOP
      FETCH C_RL
        INTO V_RL.RLID,
             V_RL.RLMID,
             V_RL.RLMCODE,
             V_RL.RLZNDATE,
             V_RL.RLJE,
             V_RL.RLGROUP,
             V_RL.RLSMFID,
             V_RL.RLDATE;
      EXIT WHEN C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL;
      --调用滞纳金算法函数
      V_ZNJ    := PG_EWIDE_PAY_01.GETZNJ(V_RL.RLSMFID,
                                         V_RL.RLGROUP,
                                         V_RL.RLZNDATE,
                                         SYSDATE,
                                         V_RL.RLJE);
      V_ZNDATE := TO_CHAR(V_RL.RLZNDATE, 'yyyy-mm-dd');
      INSERT INTO PBPARMTEMP
        (C1, C2, C3, C4, C5)
      VALUES
        (V_RL.RLID, V_RL.RLMCODE, V_RL.RLMID, V_ZNDATE, V_ZNJ);
    END LOOP;
    CLOSE C_RL;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  PROCEDURE 构造违约金减免单据(P_ZASMFID    IN VARCHAR2, --营业所
                      P_ZAHDEPT    IN VARCHAR2, -- 创建部门
                      P_ZAHCREPER  IN VARCHAR2, --创建人员
                      P_ZAHCREDATE IN VARCHAR2, --创建日期
                      P_RL         RECLIST%ROWTYPE, --应收信息
                      P_ZAHNO      IN OUT VARCHAR2, --输出单据号
                      P_ZNJ        IN NUMBER, --目标金额
                      P_COMMIT     IN VARCHAR2 --提交标志
                      ) IS

    V_ZAH ZNJADJUSTHD%ROWTYPE;
    V_ZAD ZNJADJUSTDT%ROWTYPE;
  BEGIN
    --构造单头
    IF P_ZAHNO IS NULL THEN
      TOOLS.SP_BILLSEQ('110', V_ZAH.ZAHNO, 'N'); --单据流水号
      P_ZAHNO := V_ZAH.ZAHNO;
    ELSE
      V_ZAH.ZAHNO := P_ZAHNO;
    END IF;

    V_ZAH.ZAHBH         := V_ZAH.ZAHNO; --单据编号
    V_ZAH.ZAHLB         := '7'; --单据类别
    V_ZAH.ZAHSOURCE     := '1'; --单据来源
    V_ZAH.ZAHSMFID      := P_ZASMFID; --营销公司
    V_ZAH.ZAHDEPT       := P_ZAHDEPT; --部门
    V_ZAH.ZAHCREATEDATE := P_ZAHCREDATE; --创建日期
    V_ZAH.ZAHCREATEPER  := P_ZAHCREPER; --创建人员
    V_ZAH.ZAHSHDATE     := NULL; --审核日期
    V_ZAH.ZAHSHPER      := NULL; --审核人员
    V_ZAH.ZAHSHFLAG     := 'N'; --审核标志
    INSERT INTO ZNJADJUSTHD VALUES V_ZAH;
    --构造单体
    V_ZAD.ZADNO        := V_ZAH.ZAHNO; --单据流水号
    V_ZAD.ZADROWNO     := 1; --行号
    V_ZAD.ZADRLID      := P_RL.RLID; --减免应收流水
    V_ZAD.ZADPIID      := 'NA'; --减免费用项目（全部为NA）
    V_ZAD.ZADMID       := P_RL.RLMID; --水表编号
    V_ZAD.ZADMCODE     := P_RL.RLMCODE; --水表号
    V_ZAD.ZADMETHOD    := '1'; --减免方法（1、目标金额减免；2、比例金额减免；3、差额减免；4、调整起算日期）
    V_ZAD.ZADVALUE     := P_ZNJ; --减免金额/比例值
    V_ZAD.ZADZNDATE    := NULL; --减免目标起算日
    V_ZAD.ZADINTZNJ    := P_RL.RLZNJ; --应收违约金额
    V_ZAD.ZADINTZNDATE := P_RL.RLZNDATE; --应收违约金起算日
    V_ZAD.ZADMEMO      := '减量退费';
    INSERT INTO ZNJADJUSTDT VALUES V_ZAD;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
END;
/

