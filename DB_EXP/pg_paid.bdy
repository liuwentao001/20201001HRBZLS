CREATE OR REPLACE PACKAGE BODY PG_PAID IS
  CURDATETIME DATE;

  FUNCTION OBTWYJ(P_SDATE IN DATE, P_EDATE IN DATE, P_JE IN NUMBER)
    RETURN NUMBER IS
    V_RESULT NUMBER;
  BEGIN
    V_RESULT := P_JE * (TRUNC(P_EDATE) - TRUNC(P_SDATE) + 1) * 0.003;
    V_RESULT := PG_CB_COST.GETMAX(V_RESULT, 0);
    RETURN V_RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  --违约金计算
  function ObtWyjAdj(p_arid     in varchar2, --应收流水
                     p_ardpiids in varchar2, --应收明细费项串'01|02|03'
                     p_edate    in date --终算日'不计入'违约日,参数格式'yyyy-mm-dd'
                     ) return number is
    vresult          number;
    v_arzndate       ys_zw_arlist.arzndate%type;
    v_arznj          ys_zw_arlist.arznj%type;
    v_outflag        ys_zw_arlist.aroutflag%type;
    v_sbid           ys_zw_arlist.sbid%type;
    v_arje           ys_zw_arlist.arje%type;
    v_yhifzn         ys_yh_custinfo.yhifzn%type;
    v_arznjreducflag ys_zw_arlist.arznjreducflag%type;
    v_chargetype     varchar2(10);
  begin
    BEGIN
      select a.sbid,
             max(arzndate),
             max(arznj),
             max(aroutflag),
             sum(ardje),
             max(yhifzn),
             max(arznjreducflag),
             max(NVL(sbchargetype, 'X'))
        into v_sbid,
             v_arzndate,
             v_arznj,
             v_outflag,
             v_arje,
             v_yhifzn,
             v_arznjreducflag,
             v_chargetype
        from ys_zw_arlist   a,
             ys_yh_custinfo b,
             ys_zw_ardetail c,
             ys_yh_sbinfo   d
       where a.sbid = d.sbid
         and b.yhid = d.yhid
         and a.arid = c.ardid
         and instr(p_ardpiids, ardpiid) > 0
         and arid = p_arid
       group by arid, a.sbid;
    exception
      when others then
        raise;
    END;
  
    --暂时屏蔽
    --return 0;
  
    if v_yhifzn = 'N' or v_chargetype in ('D', 'T') then
      return 0;
    end if;
    if v_arje < 0 then
      v_arje := 0;
    end if;
    if v_arznjreducflag = 'Y' then
      return v_arznj;
    end if;
  
    vresult := ObtWyj(v_arzndate, p_edate, v_arje);
    --不得超过本金
    if vresult > v_arje then
      vresult := v_arje;
    end if;
  
    return trunc(vresult, 2);
  exception
    when others then
      return 0;
  end;
  /*==========================================================================
  水司柜台缴费（一表）,参数简化版
  '123456789,Y*01!Y*02!Y*03!,0.10,0,0,0|123456789,Y*01!Y*02!Y*03!,0.10,0,0,0|'
  */
  PROCEDURE POSCUSTFORYS(P_SBID     IN VARCHAR2,
                         P_ARSTR    IN VARCHAR2,
                         P_POSITION IN VARCHAR2,
                         P_OPER     IN VARCHAR2,
                         P_PAYPOINT IN VARCHAR2,
                         P_PAYWAY   IN VARCHAR2,
                         P_PAYMENT  IN NUMBER,
                         P_BATCH    IN VARCHAR2,
                         P_PID      OUT VARCHAR2) IS
  
    V_PARM_AR  PARM_PAYAR;
    V_PARM_ARS PARM_PAYAR_TAB;
  BEGIN
    V_PARM_AR  := PARM_PAYAR(NULL, NULL, NULL, NULL, NULL, NULL);
    V_PARM_ARS := PARM_PAYAR_TAB();
    FOR I IN 1 .. FMID(P_ARSTR, '|') - 1 LOOP
      V_PARM_AR.ARID     := PG_CB_COST.FGETPARA(P_ARSTR, I, 1);
      V_PARM_AR.ARDPIIDS := REPLACE(REPLACE(PG_CB_COST.FGETPARA(P_ARSTR,
                                                                I,
                                                                2),
                                            '*',
                                            ','),
                                    '!',
                                    '|');
      V_PARM_AR.ARWYJ    := PG_CB_COST.FGETPARA(P_ARSTR, I, 3);
      V_PARM_AR.FEE1     := PG_CB_COST.FGETPARA(P_ARSTR, I, 4);
      V_PARM_AR.FEE2     := PG_CB_COST.FGETPARA(P_ARSTR, I, 5);
      V_PARM_AR.FEE3     := PG_CB_COST.FGETPARA(P_ARSTR, I, 6);
      V_PARM_ARS.EXTEND;
      V_PARM_ARS(V_PARM_ARS.LAST) := V_PARM_AR;
    END LOOP;
  
    POSCUST(P_SBID,
            V_PARM_ARS,
            P_POSITION,
            P_OPER,
            P_PAYPOINT,
            P_PAYWAY,
            P_PAYMENT,
            P_BATCH,
            P_PID);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  水司柜台缴费（一表）
  【输入参数说明】：
  p_sbid        in varchar2 :单一水表编号
  p_parm_ars   in out parm_payr_tab :单表待销应收包成员参数如下：
                            arid  in number :应收流水（依此成员次序销帐）
                            ardpiids in varchar2 :费用项目串（待销费用项目,由前台勾选否(Y/N)+费项ID组成的二维数组（基于PG_CB_COST.FGETPARA二维数组规范），例如：Y,01|Y,02|N,03|,次序很重要）
                            arznj in number :传入的违约金（本过程内不计算不校验），传多少销多少
                            fee1 in number  :其他非系统费项1
  p_position      in varchar2 :缴费单位，营销架构中营业所编码，实收计帐单位
  p_oper       in varchar2 :销帐员，柜台缴费时销帐人员与收款员统一
  p_payway     in varchar2 :付款方式，每交易有且仅有一种付款方式
  p_payment    in number   :实收，即为（付款-找零），付款与找零在前台计算和校验
  */
  PROCEDURE POSCUST(P_SBID     IN VARCHAR2,
                    P_PARM_ARS IN PARM_PAYAR_TAB,
                    P_POSITION IN VARCHAR2,
                    P_OPER     IN VARCHAR2,
                    P_PAYPOINT IN VARCHAR2,
                    P_PAYWAY   IN VARCHAR2,
                    P_PAYMENT  IN NUMBER,
                    P_BATCH    IN VARCHAR2,
                    P_PID      OUT VARCHAR2) IS
    VBATCH       VARCHAR2(10);
    VSEQNO       VARCHAR2(10);
    V_PARM_ARS   PARM_PAYAR_TAB;
    VREMAINAFTER NUMBER;
    V_PARM_COUNT NUMBER;
  BEGIN
    VBATCH     := P_BATCH;
    V_PARM_ARS := P_PARM_ARS;
    --核心部分校验
    FOR I IN (SELECT A.AROUTFLAG
                FROM YS_ZW_ARLIST A, TABLE(V_PARM_ARS) B
               WHERE A.ARID = B.ARID) LOOP
      IF 允许重复销帐 = 0 AND I.AROUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '当前系统规则不允许划扣中进行应收冲正');
      END IF;
    END LOOP;
  
    SELECT COUNT(*) INTO V_PARM_COUNT FROM TABLE(V_PARM_ARS) B;
    IF V_PARM_COUNT = 0 THEN
      IF P_PAYMENT > 0 THEN
        --单缴预存核心
        PRECUST(P_SBID        => P_SBID,
                P_POSITION    => P_POSITION,
                P_OPER        => P_OPER,
                P_PAYWAY      => P_PAYWAY,
                P_PAYMENT     => P_PAYMENT,
                P_MEMO        => NULL,
                P_BATCH       => VBATCH,
                O_PID         => P_PID,
                O_REMAINAFTER => VREMAINAFTER);
      ELSE
        NULL;
        --退预存核心
        PRECUSTBACK(P_SBID        => P_SBID,
                    P_POSITION    => P_POSITION,
                    P_OPER        => P_OPER,
                    P_PAYWAY      => P_PAYWAY,
                    P_PAYMENT     => P_PAYMENT,
                    P_MEMO        => NULL,
                    P_BATCH       => VBATCH,
                    O_PID         => P_PID,
                    O_REMAINAFTER => VREMAINAFTER);
      END IF;
    ELSE
      PAYCUST(P_SBID,
              V_PARM_ARS,
              PTRANS_柜台缴费,
              P_POSITION,
              P_PAYPOINT,
              NULL,
              NULL,
              P_OPER,
              P_PAYWAY,
              P_PAYMENT,
              NULL,
              不提交,
              局部屏蔽通知,
              允许拆帐,
              VBATCH,
              VSEQNO,
              P_PID,
              VREMAINAFTER);
    END IF;
  
    --提交处理
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --PG_EWIDE_INTERFACE.ERRLOG(DBMS_UTILITY.FORMAT_CALL_STACK(), P_SBID);
      raise_application_error(errcode, sqlerrm);
  END;
  /*==========================================================================
  一水表多应收销帐
  paymeter
  【输入参数说明】：
  p_sbid        in varchar2 :单一水表编号
  p_parm_ARs   in out parm_payAR_tab :可以为空（预存充值），待销应收包结构如下：
                            ARid  in number :应收流水（依此成员次序销帐）
                            Ardpiids in varchar2 :费用项目串，必须是YS_ZW_ARDETAIL的全集（待销费用项目,由前台勾选否(Y/N)+费项ID组成的二维数组（基于PG_CB_COST.FGETPARA二维数组规范），例如：Y,01|Y,02|N,03|,次序很重要）
                            ARznj in number :传入的实收违约金（本过程内不计算不校验），传多少销多少
                            fee1 in number  :其他非系统实收费项1
  p_trans      in varchar2 :缴费事务
  p_position      in varchar2 :缴费单位，营销架构中营业所编码，实收计帐单位
  p_paypoint   in varchar2 :缴费点，缴费单位下级需要分收费网点点统计需要，可以为空
  p_bdate      in date :前台日期，银行交易日期(yyyy-mm-dd hh24:mi:ss '2014-02-10 13:53:01')
  p_bseqno     in varchar2 :前台流水，银行交易流水
  p_oper       in varchar2 :销帐员，柜台缴费时销帐人员与收款员统一
  p_payee      in varchar2 :收款员，柜台缴费时销帐人员与收款员统一
  p_payway     in varchar2 :付款方式，每交易有且仅有一种付款方式
  p_payment    in number   :实收，即为（付款-找零），付款与找零在前台计算和校验
  p_pid_source in number   :可空，正常销帐时为空，也即实参为空赋值为新的实收流水号，部分退费追销时许传原实收流水用于实收行绑定
  p_commit     in number   :提交方式（0:执行成功后不提交；
                                      1:执行成功后提交；
                                      2:调试，或执行成功后提交，到模拟表）
  p_ctl_msg  in number   :全局控制参数“禁止所有通知”条件下，是否发送通知服务，组织统一缴费交易通知内容，通过sendmsg发送到外部接口（短信、微信等），
                            外部调用时选择是否需要本缴费交易核心统一组织内容（退费时通知内容得在退费头过程中组织，调用时避免本过程重复发送需要屏蔽）
                            通知客户  = 1
                            不通知客户= 0
  【输出参数说明】：
  p_batch      in out number：传空值时本过程生成，非空时用此值绑定实收记录，返回销帐成功后的交易批次，供打印时二次查询
  p_seqno      in out number：传空值时本过程生成，非空时用此值绑定实收记录，返回销帐成功后的交易批次，供打印时二次查询
  p_pid        out number：返回销帐成功后的交易流水，供父过程调用
  【过程说明】：
  1、一水表任意多月销帐次核心过程，提供各缴费事务过程调用；
  2、实收 = 销帐+实收违约金+预存（净增）+预存（净减）+其他非系统费项123；
  3、支持预存、期末负预存（依赖全局包常量：是否预存、是否负预存）；
  4、支持有且仅有违约金应收记录（无水费、追补违约金功能产生）；
  5、最小销帐单元为应收明细行或仅应收违约金，销帐前p_parm_rls.rdpiids中成员如有N勾选状态时先执行【应收调整.部分销帐】，之后重构【待销应收包】
  6、【重构待销应收包】基础上对其中目前是未销状态的全部销帐
  7、最后判断整体实收溢出时（待销中存在其它实收事务已销、前台预存）
     1）启用预存时，销帐后做期末预存，且记录在分解之销帐预存到最后销帐记录上（即待销应收包末尾销帐单元）；
     2）未启用预存时，抛出异常；
  8、整体实收不足时
     1）启用负预存时，销帐后做期末负预存，且记录在分解之销帐预存到最后销帐记录上（即待销应收包末尾销帐单元）；
     2）未启用负预存时，抛出异常；
  9、关于部分勾选费项缴费时补充说明，违约金在前台重算，并且违约金只从属于应收帐头无须分解到应收明细
  【更新日志】：
  */
  PROCEDURE PAYCUST(P_SBID        IN VARCHAR2,
                    P_PARM_ARS    IN PARM_PAYAR_TAB,
                    P_TRANS       IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_PAYPOINT    IN VARCHAR2,
                    P_BDATE       IN DATE,
                    P_BSEQNO      IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_PID_SOURCE  IN VARCHAR2,
                    P_COMMIT      IN NUMBER,
                    P_CTL_MSG     IN NUMBER,
                    P_CTL_PRE     IN NUMBER,
                    P_BATCH       IN OUT VARCHAR2,
                    P_SEQNO       IN OUT VARCHAR2,
                    P_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER) IS
    CURSOR C_MA(VMAMID VARCHAR2) IS
      SELECT * FROM YS_YH_ACCOUNT WHERE SBID = VMAMID FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR C_CI(VCIID VARCHAR2) IS
      SELECT * FROM YS_YH_CUSTINFO WHERE YHID = VCIID FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR C_MI(VMIID VARCHAR2) IS
      SELECT * FROM YS_YH_SBINFO WHERE SBID = VMIID FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    MI         YS_YH_SBINFO%ROWTYPE;
    CI         YS_YH_CUSTINFO%ROWTYPE;
    MA         YS_YH_ACCOUNT%ROWTYPE;
    P          YS_ZW_PAIDMENT%ROWTYPE;
    V_PARM_ARS PARM_PAYAR_TAB;
    P_PARM_AR  parm_payar;
    v_exists   NUMBER;
  BEGIN
    V_PARM_ARS := P_PARM_ARS;
    --1、实参校验、必要变量准备
    --------------------------------------------------------------------------
    BEGIN
      --取水表信息
      OPEN C_MI(P_SBID);
      FETCH C_MI
        INTO MI;
      IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '水表编码【' || P_SBID || '】不存在！');
      END IF;
      --取用户信息
      OPEN C_CI(MI.YHID);
      FETCH C_CI
        INTO CI;
      IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '这个水表编码没对应用户！' || P_SBID);
      END IF;
      --取用户银行账户信息
      OPEN C_MA(MI.SBID);
      FETCH C_MA
        INTO MA;
      IF C_MA%NOTFOUND OR C_MA%NOTFOUND IS NULL THEN
        NULL;
      END IF;
      --参数校验
      /*if p_parm_rls is null then
        raise_application_error(errcode, '待销帐包是空的怎么办？');
      end if;*/
      --添加核心校验,避免户号与待销账列表不一致
      IF P_PARM_ARS.COUNT > 0 THEN
        --可以为空（预存充值时）
        FOR I IN P_PARM_ARS.FIRST .. P_PARM_ARS.LAST LOOP
          P_PARM_AR := P_PARM_ARS(I);
          SELECT COUNT(1)
            INTO V_EXISTS
            FROM YS_ZW_ARLIST A, YS_YH_SBINFO B
           WHERE ARID = P_PARM_AR.ARID
             AND A.SBID = B.SBID
             AND (B.SBID = P_SBID OR SBPRIID = P_SBID);
          IF V_EXISTS = 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '请求参数错误，请刷新页面后重新操作!');
          END IF;
        END LOOP;
      END IF;
    
    END;
  
    --2、记录实收
    --------------------------------------------------------------------------
    BEGIN
      SELECT TRIM(TO_CHAR(SEQ_PAIDMENT.NEXTVAL, '0000000000'))
        INTO P_PID
        FROM DUAL;
      SELECT SYS_GUID() INTO P.ID FROM DUAL;
      P.HIRE_CODE  := MI.HIRE_CODE;
      P.PID        := P_PID; --varchar2(10)      流水号
      P.YHID       := CI.YHID; --varchar2(10)      用户编号
      P.SBID       := P_SBID; --varchar2(10)  y    水表编号
      P.PDDATE     := TRUNC(SYSDATE); --date  y    帐务日期
      P.PDATETIME  := SYSDATE; --date  y    发生日期
      P.PDMONTH    := FOBTMANAPARA(MI.MANAGE_NO, 'READ_MONTH'); --varchar2(7)  y    缴费月份
      P.MANAGE_NO  := P_POSITION; --varchar2(10)  y    缴费机构
      P.PDTRAN     := P_TRANS; --char(1)      缴费事务
      P.PDPERS     := P_OPER; --varchar2(20)  y    销帐人员
      P.PDSAVINGQC := NVL(MI.SBSAVING, 0); --number(12,2)  y    期初预存余额
      P.PDSAVINGBQ := P_PAYMENT; --number(12,2)  y    本期发生预存金额
      P.PDSAVINGQM := P.PDSAVINGQC + P.PDSAVINGBQ; --number(12,2)  y    期末预存余额
      P.PAIDMENT   := P_PAYMENT; --number(12,2)  y    付款金额
      P.PDIFSAVING := NULL; --char(1)  y    找零转预存
      P.PDCHANGE   := NULL; --number(12,2)  y    找零金额
      P.PDPAYWAY   := P_PAYWAY; --varchar2(6)  y    付款方式
      P.PDBSEQNO   := P_BSEQNO; --varchar2(20)  y    银行流水(银行实时收费交易流水)
      P.PDCSEQNO   := NULL; --varchar2(20)  y    清算中心流水(no use)
      P.PDBDATE    := P_BDATE; --date  y    银行日期(银行缴费账务日期)
      P.PDCHKDATE  := NULL; --date  y    对帐日期
      P.PDCCHKFLAG := 'N'; --char(1)  y    标志(no use)
      P.PDCDATE    := NULL; --date  y    清算日期
      IF P_BATCH IS NULL THEN
        SELECT TRIM(TO_CHAR(SEQ_PAIDBATCH.NEXTVAL, '0000000000'))
          INTO P.PDBATCH
          FROM DUAL;
      ELSE
        P.PDBATCH := P_BATCH;
      END IF;
      P.PDSEQNO      := P_SEQNO; --varchar2(10)  y    缴费交易流水(no use)
      P.PDPAYEE      := P_OPER; --varchar2(20)  y    收款员
      P.PDCHBATCH    := NULL; --varchar2(10)  y    支票交易批次
      P.PDMEMO       := NULL; --varchar2(200)  y    备注
      P.PDPAYPOINT   := P_PAYPOINT; --varchar2(10)  y    缴费地点
      P.PDSXF        := 0; --number(12,2)  y    手续费
      P.PDILID       := NULL; --varchar2(40)  y    发票流水号
      P.PDFLAG       := 'Y'; --varchar2(1)  y    实收标志（全部为y.暂无启用）
      P.PDWYJ        := 0; --number(12,2)  y    实收滞金
      P.PDRCRECEIVED := P_PAYMENT; --number(12,2)  y      实际收款金额（实际收款金额 =  付款金额 -找零金额；销帐金额 + 实收滞金 + 手续费 + 本期发生预存金额）
      P.PDSPJE       := 0; --number(12,2)  y    销帐金额(如果销帐交易中水费，销帐金额则为水费金额，如果是预存帐为0)
      P.PREVERSEFLAG := 'N'; --varchar2(1)  y    冲正标志（收水费收预存是为n,冲水费冲预存被冲实收和冲实收产生负帐匀为y）
      IF P_PID_SOURCE IS NULL THEN
        P.PDSCRID    := P.PID;
        P.PDSCRTRANS := P.PDTRAN;
        P.PDSCRMONTH := P.PDMONTH;
        P.PDSCRDATE  := P.PDDATE;
      ELSE
        SELECT PID, PDTRAN, PDMONTH, PDDATE
          INTO P.PDSCRID, P.PDSCRTRANS, P.PDSCRMONTH, P.PDSCRDATE
          FROM YS_ZW_PAIDMENT
         WHERE PID = P_PID_SOURCE;
      END IF;
      P.PDCHKNO  := NULL; --varchar2(10)  y    进账单号
      P.PDPRIID  := MI.SBPRIID; --varchar2(20)  y    合收主表号  20150105
      P.TCHKDATE := NULL; --date  y    到账日期
    END;
  
    --3、部分费项销帐分帐
    --------------------------------------------------------------------------
    IF P_CTL_PRE = 允许拆帐 THEN
      PAYZWARPRE(V_PARM_ARS, 不提交);
    END IF;
  
    --3.1、含违约金销帐分帐
    --------------------------------------------------------------------------
    IF 允许销帐违约金分帐 THEN
      PAYWYJPRE(V_PARM_ARS, 不提交);
    END IF;
  
    --4、销帐核心调用（应收记录处理、反馈实收数据）
    --------------------------------------------------------------------------
    PAYZWARCORE(P.PID,
                P.PDBATCH,
                P_PAYMENT,
                MI.SBSAVING,
                P.PDDATE,
                P.PDMONTH,
                V_PARM_ARS,
                不提交,
                P.PDSPJE,
                P.PDWYJ,
                P.PDSXF);
  
    --5、重算预存发生、预存期末、更新用户预存余额
    P.PDSAVINGQM := P.PDSAVINGQC + P_PAYMENT - P.PDSPJE - P.PDWYJ - P.PDSXF;
    P.PDSAVINGBQ := P.PDSAVINGQM - P.PDSAVINGQC;
    UPDATE YS_YH_SBINFO SET SBSAVING = P.PDSAVINGQM WHERE CURRENT OF C_MI;
  
    --6、返回预存余额
    O_REMAINAFTER := P.PDSAVINGQM;
  
    --7、事务内应实收帐务平衡校验，及校验后分支子过程
    --------------------------------------------------------------------------
  
    --8、其他缴费事务反馈过程
  
    --5、提交处理
    BEGIN
      CLOSE C_MA;
      CLOSE C_CI;
      CLOSE C_MI;
      IF P_COMMIT = 调试 THEN
        ROLLBACK;
      ELSE
        INSERT INTO YS_ZW_PAIDMENT VALUES P;
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
      IF C_MA%ISOPEN THEN
        CLOSE C_MA;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  部分费用项目销帐前拆分应收（一应收帐）：重要规则：销帐包非空时拒绝0金额实销
  【输入参数说明】：
  p_parm_ars in out parm_payar_tab：可以为空（预存充值），待销应收包
                arid  in number :应收流水（依此成员次序销帐）
                ardpiids in varchar2 : 待销费用项目,由是否销帐(Y/N)+费项ID组成的二维数组（基于PG_CB_COST.FGETPARA二维数组规范），例如：Y,01|Y,02|N,03|,次序很重要）
                        为空时：忽略，不拆
                        非空时：1）必须是YS_ZW_ARDETAIL的全集费用项目串；
                                2）YN两集合必须均含有非0金额，否则忽略，不拆；
                arznj in number :传入的违约金（本过程内不计算不校验），传多少销多少
                fee1 in number  :其他非系统费项1
  p_commit in number default 不提交
  【输出参数说明】：
  【过程说明】：
  1、解析销帐包完成校验；
  2、若存在部分费用销帐标志位（且费项额非0）则按应收调整方式拆分应收帐，否则原包返回；
  3、重构待全额销帐包并返回否则原包返回；
  【更新日志】：
  */
  PROCEDURE PAYZWARPRE(P_PARM_ARS IN OUT PARM_PAYAR_TAB,
                       P_COMMIT   IN NUMBER DEFAULT 不提交) IS
    CURSOR C_RL(VARID VARCHAR2) IS
      SELECT * FROM YS_ZW_ARLIST WHERE ARID = VARID FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR C_RD(VARID VARCHAR2, VARDPIID VARCHAR2) IS
      SELECT *
        FROM YS_ZW_ARDETAIL
       WHERE ARDID = VARID
         AND ARDPIID = VARDPIID
       ORDER BY ARDCLASS
         FOR UPDATE NOWAIT; --若被锁直接抛出异常
    P_PARM_AR          PARM_PAYAR; --销帐包内成员之一
    I                  INTEGER;
    J                  INTEGER;
    K                  INTEGER;
    一行费项数         INTEGER;
    一行一费项         VARCHAR2(10);
    一行一费项待销标志 CHAR(1);
    总金额             NUMBER(13, 3) := 0;
    待销笔数           NUMBER(10) := 0;
    不销笔数           NUMBER(10) := 0;
    待销水量           NUMBER(10) := 0;
    不销水量           NUMBER(10) := 0;
    待销金额           NUMBER(13, 3) := 0;
    不销金额           NUMBER(13, 3) := 0;
    --被调整原应收
    RL YS_ZW_ARLIST%ROWTYPE;
    RD YS_ZW_ARDETAIL%ROWTYPE;
    --拆后应收1（要销的）
    RLY    YS_ZW_ARLIST%ROWTYPE;
    RDY    YS_ZW_ARDETAIL%ROWTYPE;
    RDTABY RD_TABLE;
    --拆后应收2（不销继续挂欠费的）
    RLN    YS_ZW_ARLIST%ROWTYPE;
    RDN    YS_ZW_ARDETAIL%ROWTYPE;
    RDTABN RD_TABLE;
    --
    O_ARID_REVERSE        YS_ZW_ARLIST.ARID%TYPE;
    O_ARTRANS_REVERSE     VARCHAR2(10);
    O_ARJE_REVERSE        NUMBER;
    O_ARZNJ_REVERSE       NUMBER;
    O_ARSXF_REVERSE       NUMBER;
    O_ARSAVINGBQ_REVERSE  NUMBER;
    IO_ARSAVINGQM_REVERSE NUMBER;
    --
    CURRENTDATE DATE;
  BEGIN
    CURRENTDATE := SYSDATE;
    --可以为空（预存充值时），空包返回
    IF P_PARM_ARS.COUNT > 0 THEN
      FOR I IN P_PARM_ARS.FIRST .. P_PARM_ARS.LAST LOOP
        P_PARM_AR := P_PARM_ARS(I);
        IF P_PARM_AR.ARID IS NOT NULL THEN
          OPEN C_RL(P_PARM_AR.ARID);
          FETCH C_RL
            INTO RL;
          IF C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '销帐包中应收流水不存在' || P_PARM_AR.ARID);
          END IF;
          IF P_PARM_AR.ARDPIIDS IS NOT NULL THEN
            RLY      := RL;
            RLY.ARJE := 0;
            RDTABY   := NULL;
          
            RLN        := RL;
            RLN.ARJE   := 0;
            RLN.ARSXF  := 0; --Rlfee（如有）都放rlY，且必须销帐，暂不支持拆分
            RDTABN     := NULL;
            待销笔数   := 0;
            不销笔数   := 0;
            待销水量   := 0;
            不销水量   := 0;
            待销金额   := 0;
            不销金额   := 0;
            一行费项数 := PG_CB_COST.FBOUNDPARA(P_PARM_AR.ARDPIIDS);
            FOR J IN 1 .. 一行费项数 LOOP
              一行一费项待销标志 := PG_CB_COST.FGETPARA(P_PARM_AR.ARDPIIDS, J, 1);
              一行一费项         := PG_CB_COST.FGETPARA(P_PARM_AR.ARDPIIDS, J, 2);
              OPEN C_RD(P_PARM_AR.ARID, 一行一费项);
              LOOP
                --存在阶梯，所以要循环
                FETCH C_RD
                  INTO RD;
                EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;
                RDY    := RD;
                RDN    := RD;
                总金额 := 总金额 + RD.ARDJE;
                IF 一行一费项待销标志 = 'Y' THEN
                  RLY.ARJE     := RLY.ARJE + RDY.ARDJE;
                  待销笔数     := 待销笔数 + 1;
                  待销水量     := 待销水量 + RD.ARDSL;
                  待销金额     := 待销金额 + RD.ARDJE;
                  RDN.ARDYSSL  := 0;
                  RDN.ARDYSJE  := 0;
                  RDN.ARDSL    := 0;
                  RDN.ARDJE    := 0;
                  RDN.ARDADJSL := 0;
                  RDN.ARDADJJE := 0;
                ELSIF 一行一费项待销标志 = 'N' THEN
                  RLN.ARJE     := RLN.ARJE + RDN.ARDJE;
                  不销笔数     := 不销笔数 + 1;
                  不销水量     := 不销水量 + RD.ARDSL;
                  不销金额     := 不销金额 + RD.ARDJE;
                  RDY.ARDYSSL  := 0;
                  RDY.ARDYSJE  := 0;
                  RDY.ARDSL    := 0;
                  RDY.ARDJE    := 0;
                  RDY.ARDADJSL := 0;
                  RDY.ARDADJJE := 0;
                ELSE
                  RAISE_APPLICATION_ERROR(ERRCODE,
                                          '无法识别销帐包中待销帐标志');
                END IF;
                --复制到rdY
                IF RDTABY IS NULL THEN
                  RDTABY := RD_TABLE(RDY);
                ELSE
                  RDTABY.EXTEND;
                  RDTABY(RDTABY.LAST) := RDY;
                END IF;
                --复制到rdN
                IF RDTABN IS NULL THEN
                  RDTABN := RD_TABLE(RDN);
                ELSE
                  RDTABN.EXTEND;
                  RDTABN(RDTABN.LAST) := RDN;
                END IF;
              END LOOP;
              CLOSE C_RD;
            END LOOP;
            --某一条应收帐发生部分销帐标志才拆分
            IF 待销笔数 != 0 THEN
              IF 不销笔数 != 0 THEN
                --应收调整1：在本期全额冲减
                ZWARREVERSECORE(P_PARM_AR.ARID,
                                RL.ARTRANS,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                不提交,
                                O_ARID_REVERSE,
                                O_ARTRANS_REVERSE,
                                O_ARJE_REVERSE,
                                O_ARZNJ_REVERSE,
                                O_ARSXF_REVERSE,
                                O_ARSAVINGBQ_REVERSE,
                                IO_ARSAVINGQM_REVERSE);
                --应收调整2.1：在本期追加目标应收（待销帐部分）
                RLY.ARID       := LPAD(SEQ_ARID.NEXTVAL, 10, '0');
                RLY.ARMONTH    := FOBTMANAPARA(RLY.MANAGE_NO, 'READ_MONTH');
                RLY.ARDATE     := TRUNC(SYSDATE);
                RLY.ARDATETIME := CURRENTDATE;
                RLY.ARREADSL   := 0;
                FOR K IN RDTABY.FIRST .. RDTABY.LAST LOOP
                  SELECT SEQ_ARID.NEXTVAL INTO RDTABY(K).ARDID FROM DUAL;
                  RDTABY(K).ARDID := RLY.ARID;
                END LOOP;
                INSERT INTO YS_ZW_ARLIST VALUES RLY;
                FOR K IN RDTABY.FIRST .. RDTABY.LAST LOOP
                  INSERT INTO YS_ZW_ARDETAIL VALUES RDTABY (K);
                END LOOP;
                --应收调整2.2：在本期追加目标应收（继续挂欠费部分）
                RLN.ARID       := LPAD(SEQ_ARID.NEXTVAL, 10, '0');
                RLN.ARMONTH    := FOBTMANAPARA(RLN.MANAGE_NO, 'READ_MONTH');
                RLN.ARDATE     := TRUNC(SYSDATE);
                RLN.ARDATETIME := CURRENTDATE;
                FOR K IN RDTABN.FIRST .. RDTABN.LAST LOOP
                  SELECT SEQ_ARID.NEXTVAL INTO RDTABN(K).ARDID FROM DUAL;
                  RDTABN(K).ARDID := RLN.ARID;
                END LOOP;
                INSERT INTO YS_ZW_ARLIST VALUES RLN;
                FOR K IN RDTABN.FIRST .. RDTABN.LAST LOOP
                  INSERT INTO YS_ZW_ARDETAIL VALUES RDTABN (K);
                END LOOP;
                --重构销帐包返回
                P_PARM_ARS(I).ARID := RLY.ARID;
                P_PARM_ARS(I).ARDPIIDS := REPLACE(P_PARM_ARS(I).ARDPIIDS,
                                                  'N',
                                                  'Y');
              END IF;
            ELSE
              --待销笔数=0
              P_PARM_ARS.DELETE(I);
            END IF;
          END IF;
          CLOSE C_RL;
        END IF;
      END LOOP;
    
    END IF;
    --5、提交处理
    BEGIN
      IF P_COMMIT = 调试 THEN
        ROLLBACK;
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
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  应收冲正核心
  【输入参数说明】：
  p_arid_source  in number ：被冲的原应收记录流水号；
  p_pid_reverse  in number ：（可空参数），冲正、退费调用时需要传前置过程产生的冲正实收流水号；
                              在此过程中依此与冲正应收记录绑定
  p_ppayment_reverse in number ：（可空参数），同上参数冲正、退费调用时需要传前置过程产生的冲正实收金额（负），
                                  对已销帐应收的冲正时：
                                  1）依此保持的销帐记录和实收记录的帐务平衡；
                                  2）依此控制销帐预存发生（例如退费不需要发生预存增减、实收冲正时可能有）;
  p_memo ：外部传入帐务备注信息
  p_commit ： 是否过程内提交
  【输出参数说明】：
  o_arid_reverse out varchar2：冲正应收流水
  o_artrans_reverse out varchar2：冲正应收事务
  o_arje_reverse out number：冲正销帐金额
  o_arznj_reverse out number：冲正销帐违约金
  o_arsxf_reverse out number：冲正销帐其他费1
  o_arsavingbq_reverse out number：冲正销帐预存发生
  io_arsavingqm_reverse in out number：外部冲正'销帐应收'循环时的期末预存（累减器）
  【过程说明】：
  基于一条应收总帐记录全额冲正，如应收总账同时为销帐记录，还要更新本冲正帐记录的销帐信息；
  提供销帐预处理、实收冲正、退费、应收调整等业务过程调用；
  【更新日志】：
  */
  PROCEDURE ZWARREVERSECORE(P_ARID_SOURCE         IN VARCHAR2,
                            P_ARTRANS_REVERSE     IN VARCHAR2,
                            P_PBATCH_REVERSE      IN VARCHAR2,
                            P_PID_REVERSE         IN VARCHAR2,
                            P_PPAYMENT_REVERSE    IN NUMBER,
                            P_MEMO                IN VARCHAR2,
                            P_CTL_MIRCODE         IN VARCHAR2,
                            P_COMMIT              IN NUMBER DEFAULT 不提交,
                            O_ARID_REVERSE        OUT VARCHAR2,
                            O_ARTRANS_REVERSE     OUT VARCHAR2,
                            O_ARJE_REVERSE        OUT NUMBER,
                            O_ARZNJ_REVERSE       OUT NUMBER,
                            O_ARSXF_REVERSE       OUT NUMBER,
                            O_ARSAVINGBQ_REVERSE  OUT NUMBER,
                            IO_ARSAVINGQM_REVERSE IN OUT NUMBER) IS
    CURSOR C_RL(VARID VARCHAR2) IS
      SELECT * FROM YS_ZW_ARLIST WHERE ARID = VARID FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR C_RD(VARID VARCHAR2) IS
      SELECT *
        FROM YS_ZW_ARDETAIL
       WHERE ARDID = VARID
       ORDER BY ARDPIID, ARDCLASS
         FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR C_P_REVERSE(VRPID VARCHAR2) IS
      SELECT * FROM YS_ZW_PAIDMENT WHERE PID = VRPID FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    SUBTYPE RD_TYPE IS YS_ZW_ARDETAIL%ROWTYPE;
    TYPE RD_TABLE IS TABLE OF RD_TYPE;
    --被冲正原应收
    RL_SOURCE YS_ZW_ARLIST%ROWTYPE;
    RD_SOURCE YS_ZW_ARDETAIL%ROWTYPE;
    --冲正应收
    RL_REVERSE     YS_ZW_ARLIST%ROWTYPE;
    RD_REVERSE     YS_ZW_ARDETAIL%ROWTYPE;
    RD_REVERSE_TAB RD_TABLE;
    --
    P_REVERSE YS_ZW_PAIDMENT%ROWTYPE;
  BEGIN
    OPEN C_RL(P_ARID_SOURCE);
    FETCH C_RL
      INTO RL_SOURCE;
    IF C_RL%FOUND THEN
      --核心部分校验
      IF 允许重复销帐 = 0 AND RL_SOURCE.AROUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '当前系统规则不允许划扣中进行应收冲正');
      END IF;
    
      RL_REVERSE                := RL_SOURCE;
      RL_REVERSE.ARID           := LPAD(SEQ_ARID.NEXTVAL, 10, '0');
      RL_REVERSE.ARDATE         := TRUNC(SYSDATE);
      RL_REVERSE.ARDATETIME     := SYSDATE; --20140514 add
      RL_REVERSE.ARMONTH        := FOBTMANAPARA(RL_REVERSE.MANAGE_NO,
                                                'READ_MONTH');
      RL_REVERSE.ARCD           := 贷方;
      RL_REVERSE.ARREADSL       := -RL_REVERSE.ARREADSL; --20140707 add
      RL_REVERSE.ARSL           := -RL_REVERSE.ARSL;
      RL_REVERSE.ARJE           := -RL_REVERSE.ARJE; --须全冲
      RL_REVERSE.ARZNJREDUCFLAG := RL_REVERSE.ARZNJREDUCFLAG;
      RL_REVERSE.ARZNJ          := -RL_REVERSE.ARZNJ; --若销帐则冲正原应收销帐违约金,未销则冲应收违约金
      RL_REVERSE.ARSXF          := -RL_REVERSE.ARSXF; --若销帐则冲正原应收销帐其他费1，,未销则冲应收其他费1
      RL_REVERSE.ARREVERSEFLAG  := 'Y';
      RL_REVERSE.ARMEMO         := P_MEMO;
      RL_REVERSE.ARTRANS        := P_ARTRANS_REVERSE;
      --应收冲正父过程调用下，销帐信息继承源帐
      --实收冲正父过程调用下，销帐信息改写，并判断实收冲正方法
      --退款：实收计‘实收冲销’事务C，应收计‘冲正’事务C
      --不退款：继承原实收、应收事务
      IF P_PID_REVERSE IS NOT NULL THEN
        OPEN C_P_REVERSE(P_PID_REVERSE);
        FETCH C_P_REVERSE
          INTO P_REVERSE;
        IF C_P_REVERSE%NOTFOUND OR C_P_REVERSE%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '冲正负帐不存在');
        END IF;
        CLOSE C_P_REVERSE;
      
        RL_REVERSE.ARPAIDDATE  := TRUNC(SYSDATE); --若销帐则记录冲正帐期
        RL_REVERSE.ARPAIDMONTH := FOBTMANAPARA(RL_REVERSE.MANAGE_NO,
                                               'READ_MONTH'); --若销帐则记录冲正帐期
      
        RL_REVERSE.ARPAIDJE   := P_PPAYMENT_REVERSE; --销帐信息改写
        RL_REVERSE.ARSAVINGQC := (CASE
                                   WHEN IO_ARSAVINGQM_REVERSE IS NULL THEN
                                    P_REVERSE.PDSAVINGQC
                                   ELSE
                                    IO_ARSAVINGQM_REVERSE
                                 END); --销帐信息初改写
        RL_REVERSE.ARSAVINGBQ := RL_REVERSE.ARPAIDJE - RL_REVERSE.ARJE -
                                 RL_REVERSE.ARZNJ - RL_REVERSE.ARSXF; --销帐信息改写
        RL_REVERSE.ARSAVINGQM := RL_REVERSE.ARSAVINGQC +
                                 RL_REVERSE.ARSAVINGBQ; --销帐信息改写
        RL_REVERSE.ARPID      := P_PID_REVERSE;
        RL_REVERSE.ARPBATCH   := P_PBATCH_REVERSE;
        IO_ARSAVINGQM_REVERSE := RL_REVERSE.ARSAVINGQM;
      END IF;
      --rlscrrlid    := ;--继承原应收值
      --rlscrrldate  := ;--继承原应收值
      --rlscrrlmonth := ;--继承原应收值
      --rlscrrllb    := ;--继承原应收值
      OPEN C_RD(P_ARID_SOURCE);
      LOOP
        FETCH C_RD
          INTO RD_SOURCE;
        EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;
        RD_REVERSE := RD_SOURCE;
        SELECT SEQ_ARID.NEXTVAL INTO RD_REVERSE.ARDID FROM DUAL;
        RD_REVERSE.ARDID    := RL_REVERSE.ARID;
        RD_REVERSE.ARDYSSL  := -RD_REVERSE.ARDYSSL;
        RD_REVERSE.ARDYSJE  := -RD_REVERSE.ARDYSJE;
        RD_REVERSE.ARDSL    := -RD_REVERSE.ARDSL;
        RD_REVERSE.ARDJE    := -RD_REVERSE.ARDJE;
        RD_REVERSE.ARDADJSL := -RD_REVERSE.ARDADJSL;
        RD_REVERSE.ARDADJJE := -RD_REVERSE.ARDADJJE;
        --复制到rd_reverse_tab
        IF RD_REVERSE_TAB IS NULL THEN
          RD_REVERSE_TAB := RD_TABLE(RD_REVERSE);
        ELSE
          RD_REVERSE_TAB.EXTEND;
          RD_REVERSE_TAB(RD_REVERSE_TAB.LAST) := RD_REVERSE;
        END IF;
      END LOOP;
      CLOSE C_RD;
    ELSE
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的应收流水号');
    END IF;
    --返回值
    O_ARID_REVERSE       := RL_REVERSE.ARID;
    O_ARTRANS_REVERSE    := RL_REVERSE.ARTRANS;
    O_ARJE_REVERSE       := RL_REVERSE.ARJE;
    O_ARZNJ_REVERSE      := RL_REVERSE.ARZNJ;
    O_ARSXF_REVERSE      := RL_REVERSE.ARSXF;
    O_ARSAVINGBQ_REVERSE := RL_REVERSE.ARSAVINGBQ;
    --2、提交处理
    BEGIN
      CLOSE C_RL;
      IF P_COMMIT = 调试 THEN
        ROLLBACK;
      ELSE
        INSERT INTO YS_ZW_ARLIST VALUES RL_REVERSE;
        FOR K IN RD_REVERSE_TAB.FIRST .. RD_REVERSE_TAB.LAST LOOP
          INSERT INTO YS_ZW_ARDETAIL VALUES RD_REVERSE_TAB (K);
        END LOOP;
        UPDATE YS_ZW_ARLIST
           SET ARREVERSEFLAG = 'Y'
         WHERE ARID = P_ARID_SOURCE;
        --其他控制赋值
        IF P_CTL_MIRCODE IS NOT NULL THEN
          UPDATE YS_YH_SBINFO
             SET SBRCODE = TO_NUMBER(P_CTL_MIRCODE)
           WHERE SBID = RL_SOURCE.SBID;
        END IF;
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
      IF C_P_REVERSE%ISOPEN THEN
        CLOSE C_P_REVERSE;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  销帐违约金分帐销帐包预处理
  【输入参数说明】：
  p_parm_ars in out parm_payar_tab：可以为空（预存充值），待销应收包
                arid  in number :应收流水（依此成员次序销帐）
                ardpiids in varchar2 : 待销费用项目,由是否销帐(Y/N)+费项ID组成的二维数组（基于PG_CB_COST.FGETPARA二维数组规范），例如：Y,01|Y,02|N,03|,次序很重要）
                        为空时：忽略，不拆
                        非空时：1）必须是ys_zw_ardetail的全集费用项目串；
                                2）YN两集合必须均含有非0金额，否则忽略，不拆；
                arznj in number :传入的违约金（本过程内不计算不校验），传多少销多少
                fee1 in number  :其他非系统费项1
  p_commit in number default 不提交
  【输出参数说明】：
  【过程说明】：
  1、解析销帐包完成校验；
  3、重构待销帐包并返回否则原包返回；
  【更新日志】：
  */
  PROCEDURE PAYWYJPRE(P_PARM_ARS IN OUT PARM_PAYAR_TAB,
                      P_COMMIT   IN NUMBER DEFAULT 不提交) IS
    CURSOR C_RL(VARID VARCHAR2) IS
      SELECT * FROM YS_ZW_ARLIST WHERE ARID = VARID;
    CURSOR C_RD(VARID VARCHAR2) IS
      SELECT * FROM YS_ZW_ARDETAIL WHERE ARDID = VARID;
    P_PARM_AR  PARM_PAYAR := PARM_PAYAR(NULL, NULL, NULL, NULL, NULL, NULL);
    V_PARM_ARS PARM_PAYAR_TAB := PARM_PAYAR_TAB();
    --被调整原应收
    RL                 YS_ZW_ARLIST%ROWTYPE;
    RD                 YS_ZW_ARDETAIL%ROWTYPE;
    VEXIST             NUMBER := 0;
    一行费项数         INTEGER;
    一行一费项         VARCHAR2(10);
    一行一费项待销标志 CHAR(1);
  BEGIN
    --可以为空（预存充值时），空包返回
    IF P_PARM_ARS.COUNT > 0 THEN
      FOR I IN P_PARM_ARS.FIRST .. P_PARM_ARS.LAST LOOP
        P_PARM_AR := P_PARM_ARS(I);
        IF P_PARM_AR.ARWYJ <> 0 AND P_PARM_AR.ARID IS NOT NULL THEN
          OPEN C_RL(P_PARM_AR.ARID);
          FETCH C_RL
            INTO RL;
          IF C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '销帐包中应收流水不存在' || P_PARM_AR.ARID);
          END IF;
          一行费项数 := PG_CB_COST.FBOUNDPARA(P_PARM_AR.ARDPIIDS);
          FOR J IN 1 .. 一行费项数 LOOP
            一行一费项待销标志 := PG_CB_COST.FGETPARA(P_PARM_AR.ARDPIIDS, J, 1);
            一行一费项         := PG_CB_COST.FGETPARA(P_PARM_AR.ARDPIIDS, J, 2);
            IF 一行一费项待销标志 = 'N' AND UPPER(一行一费项) = 'ZNJ' THEN
              VEXIST := 1;
            END IF;
          END LOOP;
          IF VEXIST = 1 THEN
            RL.ARID           := LPAD(SEQ_ARID.NEXTVAL, 10, '0');
            RL.ARJE           := 0;
            RL.ARSL           := 0;
            RL.ARZNJ          := P_PARM_AR.ARWYJ;
            RL.ARMEMO         := '违约金追补';
            RL.ARZNJREDUCFLAG := 'Y';
            OPEN C_RD(P_PARM_AR.ARID);
            LOOP
              FETCH C_RD
                INTO RD;
              EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;
              RD.ARDID    := RL.ARID;
              RD.ARDSL    := 0;
              RD.ARDJE    := 0;
              RD.ARDYSSL  := 0;
              RD.ARDYSJE  := 0;
              RD.ARDADJSL := 0;
              RD.ARDADJJE := 0;
              INSERT INTO YS_ZW_ARDETAIL VALUES RD;
            END LOOP;
            INSERT INTO YS_ZW_ARLIST VALUES RL;
            CLOSE C_RD;
            --
            P_PARM_AR.ARID := RL.ARID;
            IF V_PARM_ARS IS NULL THEN
              V_PARM_ARS := PARM_PAYAR_TAB(P_PARM_AR);
            ELSE
              V_PARM_ARS.EXTEND;
              V_PARM_ARS(V_PARM_ARS.LAST) := P_PARM_AR;
            END IF;
            --
            P_PARM_ARS(I).ARWYJ := 0;
          END IF;
          CLOSE C_RL;
        END IF;
      END LOOP;
    END IF;
    --5、提交处理
    BEGIN
      IF P_COMMIT = 调试 THEN
        ROLLBACK;
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
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  实收销帐处理核心
  【输入参数说明】：
  p_pid in varchar2,
  p_payment in number：实收金额
  p_remainbefore in number：销帐包处理前的期初用户预存余额
  p_paiddate in date,
  p_paidmonth in varchar2,
  p_parm_rls in parm_pay1rl_tab,可以为空（预存充值时），销帐包说明
                                本过程忽略其rdpiids成员值，默认‘整笔应收总账和关联应收明细全集’全部销帐
                                其它成员详见paymeter说明包构造
  p_commit in number default 不提交：是否提交
  
  【输出参数说明】：
  o_sum_arje out number：累计销帐金额（只含待销应收明细中的金额）
  o_sum_arsavingbq out number：累计预存发生
  
  【过程说明】：
  1、应收销帐包可以为空（预存充值时）；
  2、非空时，也允许销帐包含不符合销帐条件的应收id，例如代扣隔日销帐本地已销情况下；
  3、包内应收总账及其关联应收明细全部销帐；
  4、允许应收总账0金额销帐；
  5、更新应收帐头、明细表中的销帐信息
  6、返回实收结果信息
  7、预存销帐逻辑：按销帐包内应收次序销帐，资金先进先销，销帐后‘实收金额’余额记录（无论正负）到最后一笔销帐记录上
  
  【更新日志】：
  */
  PROCEDURE PAYZWARCORE(P_PID          IN VARCHAR2,
                        P_BATCH        IN VARCHAR2,
                        P_PAYMENT      IN NUMBER,
                        P_REMAINBEFORE IN NUMBER,
                        P_PAIDDATE     IN DATE,
                        P_PAIDMONTH    IN VARCHAR2,
                        P_PARM_ARS     IN PARM_PAYAR_TAB,
                        P_COMMIT       IN NUMBER DEFAULT 不提交,
                        O_SUM_ARJE     OUT NUMBER,
                        O_SUM_ARZNJ    OUT NUMBER,
                        O_SUM_ARSXF    OUT NUMBER) IS
    CURSOR C_RL(VARID VARCHAR2) IS
      SELECT *
        FROM YS_ZW_ARLIST
       WHERE ARID = VARID
         AND ARPAIDFLAG = 'N'
         AND ARREVERSEFLAG = 'N' /*and rlje>0*/ /*支持0金额销帐*/
         FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    RL          YS_ZW_ARLIST%ROWTYPE;
    P_PARM_AR   PARM_PAYAR;
    SUMRLPAIDJE NUMBER(13, 3) := 0; --累计实收金额（应收金额+实收违约金+实收其他非系统费项123）
    P_REMAIND   NUMBER(13, 3); --期初预存累减器
  BEGIN
    --期初预存累减器初始化
    P_REMAIND := P_REMAINBEFORE;
    --返回值初始化，若销帐包非空但无游标此值返回
    O_SUM_ARJE  := 0;
    O_SUM_ARZNJ := 0;
    O_SUM_ARSXF := 0;
    SAVEPOINT 未销状态;
    IF P_PARM_ARS.COUNT > 0 THEN
      --可以为空（预存充值时）
      FOR I IN P_PARM_ARS.FIRST .. P_PARM_ARS.LAST LOOP
        P_PARM_AR := P_PARM_ARS(I);
        OPEN C_RL(P_PARM_AR.ARID);
        --销帐包非空时，也允许包含不符合销帐条件的应收id，例如代扣隔日销帐本地已销情况下
        FETCH C_RL
          INTO RL;
        IF C_RL%FOUND THEN
          --组织一条待销应收记录更新变量
          RL.ARPAIDFLAG  := 'Y'; --varchar2(1)  y  'n'    是否销账标志（全额销帐、不存在中间状态）
          RL.ARSAVINGQC  := P_REMAIND; --number(13,2)  y  0    销帐期初预存
          RL.ARSAVINGBQ  := -PG_CB_COST.GETMIN(P_REMAIND,
                                               RL.ARJE + P_PARM_AR.ARWYJ +
                                               P_PARM_AR.FEE1); --number(13,2)  y  0    销帐预存发生（净减）
          RL.ARSAVINGQM  := RL.ARSAVINGQC + RL.ARSAVINGBQ; --number(13,2)  y  0    销帐期末预存
          RL.ARZNJ       := P_PARM_AR.ARWYJ; --number(13,2)  y  0    实收违约金
          RL.ARSXF       := P_PARM_AR.FEE1; --number(13,2)  y  0    实收其他非系统费项1
          RL.ARPAIDDATE  := P_PAIDDATE; --date  y      销帐日期（实收帐务时钟）
          RL.ARPAIDMONTH := P_PAIDMONTH; --varchar2(7)  y      销帐月份（实收帐务时钟）
          RL.ARPAIDJE    := RL.ARJE + RL.ARZNJ + RL.ARSXF + RL.ARSAVINGBQ; --number(13,2)  y  0    实收金额（实收金额=应收金额+实收违约金+实收其他非系统费项123+预存发生）；sum(rl.rlpaidje)=p.ppayment
          RL.ARPID       := P_PID; --
          RL.ARPBATCH    := P_BATCH;
          RL.ARMICOLUMN1 := '';
          --中间变量运算
          SUMRLPAIDJE := SUMRLPAIDJE + RL.ARPAIDJE;
          --末条销帐记录处理，销帐溢出的实收金额计入末笔销帐记录的预存发生中！！！
          IF I = P_PARM_ARS.LAST THEN
            RL.ARSAVINGBQ := RL.ARSAVINGBQ + (P_PAYMENT - SUMRLPAIDJE);
            RL.ARSAVINGQM := RL.ARSAVINGQC + RL.ARSAVINGBQ;
            RL.ARPAIDJE   := RL.ARJE + RL.ARZNJ + RL.ARSXF + RL.ARSAVINGBQ; --number(13,2)  y  0    实收金额（实收金额=应收金额+实收违约金+实收其他非系统费项123+预存发生）；sum(rl.rlpaidje)=p.ppayment
          END IF;
          --核心部分校验
          IF NOT 允许预存发生 AND RL.ARSAVINGBQ != 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '当前系统规则为不支持预存发生');
          END IF;
          --反馈实收记录
          O_SUM_ARJE  := O_SUM_ARJE + RL.ARJE;
          O_SUM_ARZNJ := O_SUM_ARZNJ + RL.ARZNJ;
          O_SUM_ARSXF := O_SUM_ARSXF + RL.ARSXF;
          P_REMAIND   := P_REMAIND + RL.ARSAVINGBQ;
          --更新待销帐应收记录
          UPDATE YS_ZW_ARLIST
             SET ARPAIDFLAG  = RL.ARPAIDFLAG,
                 ARSAVINGQC  = RL.ARSAVINGQC,
                 ARSAVINGBQ  = RL.ARSAVINGBQ,
                 ARSAVINGQM  = RL.ARSAVINGQM,
                 ARZNJ       = RL.ARZNJ,
                 ARMICOLUMN1 = RL.ARMICOLUMN1,
                 ARSXF       = RL.ARSXF,
                 ARPAIDDATE  = RL.ARPAIDDATE,
                 ARPAIDMONTH = RL.ARPAIDMONTH,
                 ARPAIDJE    = RL.ARPAIDJE,
                 ARPID       = RL.ARPID,
                 ARPBATCH    = RL.ARPBATCH,
                 AROUTFLAG   = 'N'
           WHERE ARID = RL.ARID; --current of c_rl;效率低
        ELSE
          O_SUM_ARSXF := O_SUM_ARSXF + P_PARM_AR.FEE1;
        END IF;
        CLOSE C_RL;
      END LOOP;
    END IF;
  
    --核心部分校验
    IF 净减为负预存不销帐 AND P_REMAIND < 0 AND P_REMAIND < P_REMAINBEFORE THEN
      O_SUM_ARJE  := 0;
      O_SUM_ARZNJ := 0;
      O_SUM_ARSXF := 0;
      ROLLBACK TO 未销状态;
    END IF;
  
    --核心部分校验
    IF NOT 允许净减后负预存 AND P_REMAIND < 0 AND P_REMAIND < P_REMAINBEFORE THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '当前系统规则为不支持发生更多期末负预存');
    END IF;
  
    --5、提交处理
    BEGIN
      IF P_COMMIT = 调试 THEN
        ROLLBACK;
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
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  预存充值（一表）
  【输入参数说明】：
  【输出参数说明】：
  【过程说明】：
  【更新日志】：
  */
  PROCEDURE PRECUST(P_SBID        IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_MEMO        IN VARCHAR2,
                    P_BATCH       IN OUT VARCHAR2,
                    O_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER) IS
  
    P_SEQNO VARCHAR2(10);
  BEGIN
    --校验
    IF P_PAYMENT <= 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '预存充值业务金额必须为正数哦');
    END IF;
    --调用核心
    PRECORE(P_SBID,
            PTRANS_独立预存,
            P_POSITION,
            NULL,
            NULL,
            NULL,
            P_OPER,
            P_PAYWAY,
            P_PAYMENT,
            不提交,
            P_MEMO,
            P_BATCH,
            P_SEQNO,
            O_PID,
            O_REMAINAFTER);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  预存退费（一表）
  【输入参数说明】：
  【输出参数说明】：
  【过程说明】：
  【更新日志】：
  */
  PROCEDURE PRECUSTBACK(P_SBID        IN VARCHAR2,
                        P_POSITION    IN VARCHAR2,
                        P_OPER        IN VARCHAR2,
                        P_PAYWAY      IN VARCHAR2,
                        P_PAYMENT     IN NUMBER,
                        P_MEMO        IN VARCHAR2,
                        P_BATCH       IN OUT VARCHAR2,
                        O_PID         OUT VARCHAR2,
                        O_REMAINAFTER OUT NUMBER) IS
  
    P_SEQNO VARCHAR2(10);
  BEGIN
    --校验
    IF P_PAYMENT >= 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '预存充值业务金额必须为负数哦');
    END IF;
    --调用核心
    PRECORE(P_SBID,
            PTRANS_独立预存,
            P_POSITION,
            NULL,
            NULL,
            NULL,
            P_OPER,
            P_PAYWAY,
            P_PAYMENT,
            不提交,
            P_MEMO,
            P_BATCH,
            P_SEQNO,
            O_PID,
            O_REMAINAFTER);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  预存实收处理核心
  【输入参数说明】：
  p_sbid        in varchar2：指定预存发生的水表编号
  p_trans      in varchar2：指定预存发生计帐实收事务
  p_position      in varchar2：指定预存发生缴费单位
  p_paypoint   in varchar2：指定预存发生缴费地点
  p_bdate      in date：指定预存发生银行帐务日期
  p_bseqno     in varchar2：指定预存发生银行交易流水
  p_oper       in varchar2：预存收款人
  p_payway     in varchar2：预存发生付款方式
  p_payment    in number：预存发生金额（+/-）
  p_commit     in number：是否提交
  p_memo       in varchar2：备注信息
  p_batch      in out number：可空，绑定批次
  p_seqno      in out number：可空，绑定批次流水
  【输出参数说明】：
  p_pid        out number：预存发生记录计帐成功后返回的实收流水号
  【过程说明】：
  【更新日志】：
  */
  PROCEDURE PRECORE(P_SBID        IN VARCHAR2,
                    P_TRANS       IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_PAYPOINT    IN VARCHAR2,
                    P_BDATE       IN DATE,
                    P_BSEQNO      IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_COMMIT      IN NUMBER,
                    P_MEMO        IN VARCHAR2,
                    P_BATCH       IN OUT VARCHAR2,
                    P_SEQNO       IN OUT VARCHAR2,
                    O_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER) IS
    CURSOR C_CI(VCIID VARCHAR2) IS
      SELECT * FROM YS_YH_CUSTINFO WHERE YHID = VCIID FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR C_MI(VMIID VARCHAR2) IS
      SELECT * FROM YS_YH_SBINFO WHERE SBID = VMIID FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    MI YS_YH_SBINFO%ROWTYPE;
    CI YS_YH_CUSTINFO%ROWTYPE;
    P  YS_ZW_PAIDMENT%ROWTYPE;
  BEGIN
    IF NOT 允许预存发生 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '当前系统规则为不支持预存发生');
    END IF;
    --1、校验及其初始化
    BEGIN
      --取水表信息
      OPEN C_MI(P_SBID);
      FETCH C_MI
        INTO MI;
      IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '这是传的水表编码？' || P_SBID);
      END IF;
      --取用户信息
      OPEN C_CI(MI.YHID);
      FETCH C_CI
        INTO CI;
      IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '这个水表编码没对应用户！' || P_SBID);
      END IF;
    END;
  
    --2、记录实收
    BEGIN
      SELECT TRIM(TO_CHAR(SEQ_PAIDMENT.NEXTVAL, '0000000000'))
        INTO O_PID
        FROM DUAL;
      SELECT SYS_GUID() INTO P.ID FROM DUAL;
      P.HIRE_CODE    := MI.HIRE_CODE;
      P.PID          := O_PID;
      P.YHID         := CI.YHID;
      P.SBID         := MI.SBID;
      P.PDRCRECEIVED := P_PAYMENT;
      P.PDDATE       := TRUNC(SYSDATE);
      P.PDATETIME    := SYSDATE;
      P.PDMONTH      := FOBTMANAPARA(MI.MANAGE_NO, 'READ_MONTH');
      P.MANAGE_NO    := P_POSITION;
      P.PDPAYPOINT   := P_PAYPOINT;
      P.PDTRAN       := P_TRANS;
      P.PDPERS       := P_OPER;
      P.PDPAYEE      := P_OPER;
      P.PDPAYWAY     := P_PAYWAY;
      P.PAIDMENT     := P_PAYMENT;
      P.PDSPJE       := 0;
      P.PDWYJ        := 0;
      P.PDSAVINGQC   := NVL(MI.SBSAVING, 0);
      P.PDSAVINGBQ   := P_PAYMENT;
      P.PDSAVINGQM   := P.PDSAVINGQC + P.PDSAVINGBQ;
      P.PDSXF        := 0; --若为独立押金;
      P.PREVERSEFLAG := 'N'; --帐务状态（收水费收预存是为N,冲水费冲预存被冲实收和冲实收产生负帐匀为Y）
      P.PDBDATE      := TRUNC(P_BDATE);
      P.PDBSEQNO     := P_BSEQNO;
      P.PDCHKDATE    := NULL;
      P.PDCCHKFLAG   := NULL;
      P.PDCDATE      := NULL;
      P.PDCSEQNO     := NULL;
      P.PDMEMO       := P_MEMO;
      IF P_BATCH IS NULL THEN
        SELECT TRIM(TO_CHAR(SEQ_PAIDBATCH.NEXTVAL, '0000000000'))
          INTO P.PDBATCH
          FROM DUAL;
      ELSE
        P.PDBATCH := P_BATCH;
      END IF;
      P.PDSEQNO    := P_SEQNO;
      P.PDSCRID    := P.PID;
      P.PDSCRTRANS := P.PDTRAN;
      P.PDSCRMONTH := P.PDMONTH;
      P.PDSCRDATE  := P.PDDATE;
    END;
    P.PDCHKNO     := NULL; --varchar2(10)  y    进账单号
    P.PDPRIID     := MI.SBPRIID; --varchar2(20)  y    合收主表号  20150105
    P.TCHKDATE    := NULL; --date  y    到账日期
    O_REMAINAFTER := P.PDSAVINGQM;
  
    --校验
    IF NOT 允许净减后负预存 AND P.PDSAVINGQM < 0 AND P.PDSAVINGQM < P.PDSAVINGQC THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '当前系统规则为不支持发生更多的期末负预存');
    END IF;
    INSERT INTO YS_ZW_PAIDMENT VALUES P;
    UPDATE YS_YH_SBINFO SET SBSAVING = P.PDSAVINGQM WHERE CURRENT OF C_MI;
  
    --5、提交处理
    BEGIN
      CLOSE C_CI;
      CLOSE C_MI;
      IF P_COMMIT = 调试 THEN
        ROLLBACK;
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
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --
  FUNCTION FMID(P_STR IN VARCHAR2, P_SEP IN VARCHAR2) RETURN INTEGER IS
    --help:
    --tools.fmidn('/123/123/123/','/')=5
    --tools.fmidn(null,'/')=0
    --tools.fmidn('','/')=0
    --tools.fmidn('null','/')=1
    I INTEGER;
    N INTEGER := 1;
  BEGIN
    IF TRIM(P_STR) IS NULL THEN
      RETURN 0;
    ELSE
      FOR I IN 1 .. LENGTH(P_STR) LOOP
        IF SUBSTR(P_STR, I, 1) = P_SEP THEN
          N := N + 1;
        END IF;
      END LOOP;
    END IF;
  
    RETURN N;
  END;
  
   --1、实收冲正（当月负实收）
  PROCEDURE Payreversecorebypid(p_Pid_Source       IN VARCHAR2,
                                p_Position         IN VARCHAR2,
                                p_Paypoint         IN VARCHAR2,
                                p_Ptrans           IN VARCHAR2,
                                p_Bdate            IN DATE,
                                p_Bseqno           IN VARCHAR2,
                                p_Oper             IN VARCHAR2,
                                p_Payway           IN VARCHAR2,
                                p_Memo             IN VARCHAR2,
                                p_Commit           IN NUMBER,
                                p_Ctl_Msg          IN NUMBER,
                                o_Pid_Reverse      OUT VARCHAR2,
                                o_Ppayment_Reverse OUT NUMBER) IS
    CURSOR c_p(Vpid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Paidment WHERE Pid = Vpid FOR UPDATE NOWAIT;
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    Mi        Ys_Yh_Sbinfo%ROWTYPE;
    p_Source  Ys_Zw_Paidment%ROWTYPE;
    p_Reverse Ys_Zw_Paidment%ROWTYPE;
  BEGIN
    OPEN c_p(p_Pid_Source);
    FETCH c_p
      INTO p_Source;
    IF c_p%FOUND THEN
      OPEN c_Mi(p_Source.Sbid);
      FETCH c_Mi
        INTO Mi;
      IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode, '无效的用户编号');
      END IF;
      SELECT TRIM(To_Char(Seq_Paidment.Nextval, '0000000000'))
        INTO o_Pid_Reverse
        FROM Dual;
      SELECT Sys_Guid() INTO p_Reverse.Id FROM Dual;
      p_Reverse.Hire_Code  := Mi.Hire_Code;
      p_Reverse.Pid        := p_Source.Pid;
      p_Reverse.Yhid       := p_Source.Yhid;
      p_Reverse.Sbid       := p_Source.Sbid;
      p_Reverse.Pddate     := Trunc(SYSDATE);
      p_Reverse.Pdatetime  := SYSDATE;
      p_Reverse.Pdmonth    := Fobtmanapara(Mi.Manage_No, 'READ_MONTH'); --varchar2(7)  y    缴费月份
      p_Reverse.Manage_No  := p_Position;
      p_Reverse.Pdtran     := p_Ptrans;
      p_Reverse.Pdpers     := p_Oper;
      p_Reverse.Pdsavingqc := Nvl(Mi.Sbsaving, 0); --number(12,2)  y    期初预存余额
      p_Reverse.Pdsavingbq := -p_Source.Pdsavingbq;
      p_Reverse.Pdsavingqm := p_Reverse.Pdsavingqc + p_Reverse.Pdsavingbq; --number(12,2)  y    期末预存余额;
      p_Reverse.Paidment   := -p_Source.Paidment;
      /* --核心部分校验
      if not 允许预存发生 and p_reverse.psavingbq != 0 then
        raise_application_error(errcode, '当前系统规则为不支持预存发生');
      end if;
      if not 允许净减后负预存 and p_reverse.pdsavingqm < 0 and
         p_reverse.pdsavingqm < p_reverse.pdsavingqc then
        raise_application_error(errcode,
                                '当前系统规则为不支持发生更多的期末负预存');
      end if;*/
      UPDATE Ys_Yh_Sbinfo
         SET Sbsaving = p_Reverse.Pdsavingqm
       WHERE CURRENT OF c_Mi;
    
      p_Reverse.Pdifsaving := NULL;
      p_Reverse.Pdchange   := NULL;
      p_Reverse.Pdpayway   := p_Payway;
      p_Reverse.Pdbseqno   := p_Source.Pdbseqno;
      p_Reverse.Pdcseqno   := p_Source.Pdcseqno;
      p_Reverse.Pdbdate    := p_Source.Pdbdate;
      p_Reverse.Pdchkdate  := p_Source.Pdchkdate;
      p_Reverse.Pdcchkflag := p_Source.Pdcchkflag;
      p_Reverse.Pdcdate    := p_Source.Pdcdate;
      /*IF P_BATCH IS NULL THEN
        SELECT TRIM(TO_CHAR(SEQ_PAIDBATCH.NEXTVAL, '0000000000'))
          INTO p_reverse.PDBATCH
          FROM DUAL;
      ELSE
        p_reverse.PDBATCH := P_BATCH;
      END IF;*/
      p_Reverse.Pdbatch      := p_Source.Pdbatch;
      p_Reverse.Pdseqno      := p_Source.Pdseqno;
      p_Reverse.Pdpayee      := p_Source.Pdpayee;
      p_Reverse.Pdchbatch    := p_Source.Pdchbatch;
      p_Reverse.Pdmemo       := p_Source.Pdmemo;
      p_Reverse.Pdpaypoint   := p_Source.Pdpaypoint;
      p_Reverse.Pdsxf        := -p_Source.Pdsxf;
      p_Reverse.Pdilid       := p_Source.Pdilid;
      p_Reverse.Pdflag       := p_Source.Pdflag;
      p_Reverse.Pdwyj        := -p_Source.Pdwyj;
      p_Reverse.Pdrcreceived := -p_Source.Pdrcreceived;
      p_Reverse.Pdspje       := p_Source.Pdspje;
      p_Reverse.Preverseflag := 'Y';
      IF p_Pid_Source IS NULL THEN
        p_Reverse.Pdscrid    := p_Source.Pid;
        p_Reverse.Pdscrtrans := p_Source.Pdtran;
        p_Reverse.Pdscrmonth := p_Source.Pdmonth;
        p_Reverse.Pdscrdate  := p_Source.Pddate;
      ELSE
        SELECT Pid, Pdtran, Pdmonth, Pddate
          INTO p_Reverse.Pdscrid,
               p_Reverse.Pdscrtrans,
               p_Reverse.Pdscrmonth,
               p_Reverse.Pdscrdate
          FROM Ys_Zw_Paidment
         WHERE Pid = p_Pid_Source;
      END IF;
    
      p_Reverse.Pdchkno  := p_Source.Pdchkno;
      p_Reverse.Pdpriid  := p_Source.Pdpriid;
      p_Reverse.Tchkdate := p_Source.Tchkdate;
      p_Reverse.Pdtax    := p_Source.Pdtax;
      p_Reverse.Pdzdate  := p_Source.Pdzdate;
    
    ELSE
      Raise_Application_Error(Errcode, '无效的实收流水号');
    END IF;
    o_Ppayment_Reverse := p_Reverse.Paidment;
  
    --------------------------------------------------------------------------
    --2、提交处理
    BEGIN
      CLOSE c_Mi;
      CLOSE c_p;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        INSERT INTO Ys_Zw_Paidment VALUES p_Reverse;
        UPDATE Ys_Zw_Paidment
           SET Preverseflag = 'Y'
         WHERE Pid = p_Pid_Source;
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      IF c_p%ISOPEN THEN
        CLOSE c_p;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Payreversecorebypid;

  /*==========================================================================
  应收追帐核心
  【输入参数说明】：
  p_rlmid  varchar2(20)  ：非空，水表编号
  p_rlcname in varchar2 ：为空时reclist.rlcname取实时ci.ciname，非空时去传入值（营业外收费业务中指定票据名称）
  p_rlpfid  varchar2(10)  ：非空，价格类别编号
  p_rlrmonth  varchar2(7)  ：非空，抄表月份
  p_rlrdate  date  ：非空，抄表日期
  p_rlscode  number(10)  ：非空，上次抄表读数
  p_rlecode  number(10)  ：非空，本次抄表读数
  p_rlsl  number(10)  ：非空，应收水量
  p_rlje  number(13,2)  ：非空，应收金额
  p_rltrans in varchar2 ：非空，应收事务（类别），reclist.rllb
  p_rlmemo  varchar2(100)  ：可空，备注信息
  p_rlid_source in number ：可空，绑定原应收帐
  p_parm_append1rds parm_append1rd_tab ：非空，应收帐明细包
  p_ctl_mircode ：非空时以此值覆盖meterinfo.mircode(即重置下期起码)，为空时不进行此处理
  【输出参数说明】：
  o_rlid out number：返回追补的应收记录流水号
  【过程说明】：
  根据参数追加一套应收总账和关联应收明细（且须追加为欠费）；
  提供应收调整中追加调整目标帐、追补、营业外、冲正中追正、退费中追正等业务过程调用
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  PROCEDURE Recappendcore(p_Rlmid           IN VARCHAR2,
                          p_Rlcname         IN VARCHAR2,
                          p_Rlpfid          IN VARCHAR2,
                          p_Rlrdate         IN DATE,
                          p_Rlscode         IN NUMBER,
                          p_Rlecode         IN NUMBER,
                          p_Rlsl            IN NUMBER,
                          p_Rlje            IN NUMBER,
                          p_Rlznjreducflag  IN VARCHAR2,
                          p_Rlzndate        IN DATE,
                          p_Rlznj           IN NUMBER,
                          p_Rltrans         IN VARCHAR2,
                          p_Rlmemo          IN VARCHAR2,
                          p_Rlid_Source     IN VARCHAR2,
                          p_Parm_Append1rds Parm_Append1rd_Tab,
                          p_Ctl_Mircode     IN VARCHAR2,
                          p_Commit          IN NUMBER DEFAULT 不提交,
                          o_Rlid            OUT VARCHAR2) IS
    CURSOR c_Ci(Vciid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vciid;
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid;
    CURSOR c_Md(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbdoc WHERE Sbid = Vmiid;
    CURSOR c_Ma(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Account WHERE Sbid = Vmiid;
    Mi Ys_Yh_Sbinfo%ROWTYPE;
    Md Ys_Yh_Sbdoc%ROWTYPE;
    Ma Ys_Yh_Account%ROWTYPE;
    Ci Ys_Yh_Custinfo%ROWTYPE;
    Bf Ys_Bas_Book%ROWTYPE;
    CURSOR c_Rlsource(Vrlid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Vrlid;
    Rl_Source Ys_Zw_Arlist%ROWTYPE;
    Rl_Append Ys_Zw_Arlist%ROWTYPE;
    Rd_Append Ys_Zw_Ardetail%ROWTYPE;
    SUBTYPE Rd_Type IS Ys_Zw_Ardetail%ROWTYPE;
    TYPE Rd_Table IS TABLE OF Rd_Type;
    Rdtab_Append Rd_Table;
  
    Vappend1rd Parm_Append1rd;
  BEGIN
    --取水表信息
    OPEN c_Mi(p_Rlmid);
    FETCH c_Mi
      INTO Mi;
    IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '这是传的水表编码？' || p_Rlmid);
    END IF;
    BEGIN
      SELECT * INTO Bf FROM Ys_Bas_Book WHERE Book_No = Mi.Book_No;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    --
    OPEN c_Md(p_Rlmid);
    FETCH c_Md
      INTO Md;
    IF c_Md%NOTFOUND OR c_Md%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '这是传的水表编码？' || p_Rlmid);
    END IF;
    --
    OPEN c_Ma(p_Rlmid);
    FETCH c_Ma
      INTO Ma;
    IF c_Ma%NOTFOUND OR c_Ma%NOTFOUND IS NULL THEN
      NULL;
    END IF;
    --取用户信息
    OPEN c_Ci(Mi.Yhid);
    FETCH c_Ci
      INTO Ci;
    IF c_Ci%NOTFOUND OR c_Ci%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode,
                              '这个水表编码没对应用户！' || p_Rlmid);
    END IF;
    --组织追加应收总账和明细行变量
    IF p_Rlid_Source IS NOT NULL THEN
      OPEN c_Rlsource(p_Rlid_Source);
      FETCH c_Rlsource
        INTO Rl_Source;
      IF c_Rlsource%NOTFOUND THEN
        Raise_Application_Error(Errcode,
                                '可以为空的原应收帐流水号非空但无效');
      END IF;
      CLOSE c_Rlsource;
    END IF;
    SELECT TRIM(Lpad(Seq_Arid.Nextval, 10, '0')) INTO o_Rlid FROM Dual;
    SELECT Uuid() INTO Rl_Append.Id FROM Dual;
  
    Rl_Append.Hire_Code   := f_Get_Hire_Code();
    Rl_Append.Manage_No   := Mi.Manage_No;
    Rl_Append.Arid        := o_Rlid;
    Rl_Append.Armonth     := Fobtmanapara(Rl_Source.Manage_No, 'READ_MONTH');
    Rl_Append.Ardate      := p_Rlrdate; --Trunc(SYSDATE);
    Rl_Append.Yhid        := Mi.Yhid;
    Rl_Append.Sbid        := Mi.Sbid;
    Rl_Append.Archargeper := (CASE
                               WHEN Rl_Source.Arid IS NOT NULL THEN
                                Rl_Source.Archargeper
                               ELSE
                                Bf.Read_Per
                             END);
  
    Rl_Append.Arcpid        := Ci.Yhpid;
    Rl_Append.Arcclass      := Ci.Yhclass;
    Rl_Append.Arcflag       := Ci.Yhflag;
    Rl_Append.Arusenum      := Mi.Sbusenum;
    Rl_Append.Arcname       := Ci.Yhname;
    Rl_Append.Arcadr        := Ci.Yhadr;
    Rl_Append.Armadr        := Mi.Sbadr;
    Rl_Append.Arcstatus     := Ci.Yhstatus;
    Rl_Append.Armtel        := Ci.Yhmtel;
    Rl_Append.Artel         := Ci.Yhtel1;
    Rl_Append.Arbankid := (CASE
                            WHEN Rl_Source.Arid IS NOT NULL THEN
                             Rl_Source.Arbankid
                            ELSE
                             Ma.Yhabankid
                          END);
    Rl_Append.Artsbankid := (CASE
                              WHEN Rl_Source.Arid IS NOT NULL THEN
                               Rl_Source.Artsbankid
                              ELSE
                               Ma.Yhatsbankid
                            END);
    Rl_Append.Araccountno := (CASE
                               WHEN Rl_Source.Arid IS NOT NULL THEN
                                Rl_Source.Araccountno
                               ELSE
                                Ma.Yhaaccountno
                             END);
    Rl_Append.Araccountname := (CASE
                                 WHEN Rl_Source.Arid IS NOT NULL THEN
                                  Rl_Source.Araccountname
                                 ELSE
                                  Ma.Yhaaccountname
                               END);
    Rl_Append.Ariftax := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Ariftax
                           ELSE
                            Mi.Sbiftax
                         END);
    Rl_Append.Artaxno := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Artaxno
                           ELSE
                            Mi.Sbtaxno
                         END);
    Rl_Append.Arifinv := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Arifinv
                           ELSE
                            Ci.Yhifinv
                         END); --开票标志 
    Rl_Append.Armcode       := Mi.Sbcode;
    Rl_Append.Armpid        := Mi.Sbpid;
    Rl_Append.Armclass      := Mi.Sbclass;
    Rl_Append.Armflag       := Mi.Sbflag;
    Rl_Append.Arday := (CASE
                         WHEN Rl_Source.Arid IS NOT NULL THEN
                          Rl_Source.Arday
                         ELSE
                          Trunc(SYSDATE)
                       END);
    Rl_Append.Arbfid := (CASE
                          WHEN Rl_Source.Arid IS NOT NULL THEN
                           Rl_Source.Arbfid
                          ELSE
                           Mi.Book_No
                        END);
    Rl_Append.Arprdate := (CASE
                            WHEN Rl_Source.Arid IS NOT NULL THEN
                             Rl_Source.Arprdate
                            ELSE
                             Trunc(SYSDATE)
                          END);
    Rl_Append.Arrdate := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Arrdate
                           ELSE
                            Trunc(SYSDATE)
                         END);
    Rl_Append.Arzndate      := Rl_Append.Ardate + 30;
    Rl_Append.Arcaliber     := Md.Mdcaliber;
    Rl_Append.Arrtid        := Mi.Sbrtid;
    Rl_Append.Armstatus     := Mi.Sbstatus;
    Rl_Append.Armtype       := Mi.Sbtype;
    Rl_Append.Armno         := Md.Mdno;
    Rl_Append.Arscode       := p_Rlscode; --NUMBER(10)  Y    起数 
    Rl_Append.Arecode       := p_Rlecode; --NUMBER(10)  Y    止数 
    Rl_Append.Arreadsl      := p_Rlsl; --NUMBER(10)  Y    抄见水量 
  
    Rl_Append.Arinvmemo       := Rl_Source.Arinvmemo;
    Rl_Append.Arentrustbatch  := Rl_Source.Arentrustbatch;
    Rl_Append.Arentrustseqno  := Rl_Source.Arentrustseqno;
    Rl_Append.Aroutflag := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Aroutflag
                             ELSE
                              'N'
                           END);
    Rl_Append.Artrans         := p_Rltrans;
    Rl_Append.Arcd            := 'DE';
    Rl_Append.Aryschargetype := (CASE
                                  WHEN Rl_Source.Arid IS NOT NULL THEN
                                   Rl_Source.Aryschargetype
                                  ELSE
                                   Mi.Sbchargetype
                                END);
    Rl_Append.Arsl            := 0;
    Rl_Append.Arje            := 0;
    Rl_Append.Araddsl         := Rl_Source.Araddsl;
    Rl_Append.Arscrarid := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Arscrarid
                             ELSE
                              Rl_Append.Arid
                           END);
    Rl_Append.Arscrartrans := (CASE
                                WHEN Rl_Source.Arid IS NOT NULL THEN
                                 Rl_Source.Arscrartrans
                                ELSE
                                 Rl_Append.Artrans
                              END);
    Rl_Append.Arscrarmonth := (CASE
                                WHEN Rl_Source.Arid IS NOT NULL THEN
                                 Rl_Source.Arscrarmonth
                                ELSE
                                 Rl_Append.Armonth
                              END);
    Rl_Append.Arpaidje        := Rl_Source.Arpaidje;
    Rl_Append.Arpaidflag      := Rl_Source.Arpaidflag;
    Rl_Append.Arpaidper       := Rl_Source.Arpaidper;
    Rl_Append.Arpaiddate      := Rl_Source.Arpaiddate;
    Rl_Append.Armrid          := Rl_Source.Armrid;
    Rl_Append.Armemo          := Nvl(p_Rlmemo, Rl_Source.Armemo);
    Rl_Append.Arznj           := Rl_Source.Arznj;
    Rl_Append.Arlb            := Rl_Source.Arlb;
    Rl_Append.Arcname2        := Rl_Source.Arcname2;
    Rl_Append.Arpfid          := p_Rlpfid; --VARCHAR2(10)  Y    主价格类别
    Rl_Append.Ardatetime      := SYSDATE;
    Rl_Append.Arscrardate := (CASE
                               WHEN Rl_Source.Arid IS NOT NULL THEN
                                Rl_Source.Arscrardate
                               ELSE
                                Rl_Append.Ardate
                             END);
    Rl_Append.Arprimcode      := Rl_Source.Arprimcode;
    Rl_Append.Arpriflag       := Rl_Source.Arpriflag;
    Rl_Append.Arrper          := Rl_Source.Arrper;
    Rl_Append.Arsafid         := Rl_Source.Arsafid;
    Rl_Append.Arscodechar     := Rl_Source.Arscodechar;
    Rl_Append.Arecodechar     := Rl_Source.Arecodechar;
    Rl_Append.Arilid          := Rl_Source.Arilid;
    Rl_Append.Armiuiid        := Rl_Source.Armiuiid;
    Rl_Append.Argroup         := Rl_Source.Argroup;
    Rl_Append.Arpid           := Rl_Source.Arpid;
    Rl_Append.Arpbatch        := Rl_Source.Arpbatch;
    Rl_Append.Arsavingqc      := Rl_Source.Arsavingqc;
    Rl_Append.Arsavingbq      := Rl_Source.Arsavingbq;
    Rl_Append.Arsavingqm      := Rl_Source.Arsavingqm;
    Rl_Append.Arreverseflag   := Rl_Source.Arreverseflag;
    Rl_Append.Arbadflag       := Rl_Source.Arbadflag;
    Rl_Append.Arznjreducflag  := Rl_Source.Arznjreducflag;
    Rl_Append.Armistid        := Rl_Source.Armistid;
    Rl_Append.Arminame        := Rl_Source.Arminame;
    Rl_Append.Arsxf           := Rl_Source.Arsxf;
    Rl_Append.Armiface2       := Rl_Source.Armiface2;
    Rl_Append.Armiface3       := Rl_Source.Armiface3;
    Rl_Append.Armiface4       := Rl_Source.Armiface4;
    Rl_Append.Armiifckf       := Rl_Source.Armiifckf;
    Rl_Append.Armigps         := Rl_Source.Armigps;
    Rl_Append.Armiqfh         := Rl_Source.Armiqfh;
    Rl_Append.Armibox         := Rl_Source.Armibox;
    Rl_Append.Arminame2       := Rl_Source.Arminame2;
    Rl_Append.Armiseqno       := Rl_Source.Armiseqno;
    Rl_Append.Armisaving      := Rl_Source.Armisaving;
    Rl_Append.Arpriorje       := Rl_Source.Arpriorje;
    Rl_Append.Armicommunity   := Rl_Source.Armicommunity;
    Rl_Append.Armiremoteno    := Rl_Source.Armiremoteno;
    Rl_Append.Armiremotehubno := Rl_Source.Armiremotehubno;
    Rl_Append.Armiemail       := Rl_Source.Armiemail;
    Rl_Append.Armiemailflag   := Rl_Source.Armiemailflag;
    Rl_Append.Armicolumn1     := Rl_Source.Armicolumn1;
    Rl_Append.Armicolumn2     := Rl_Source.Armicolumn2;
    Rl_Append.Armicolumn3     := Rl_Source.Armicolumn3;
    Rl_Append.Armicolumn4     := Rl_Source.Armicolumn4;
    Rl_Append.Arpaidmonth     := Rl_Source.Arpaidmonth;
    Rl_Append.Arcolumn5       := Rl_Source.Arcolumn5;
    Rl_Append.Arcolumn9       := Rl_Source.Arcolumn9;
    Rl_Append.Arcolumn10      := Rl_Source.Arcolumn10;
    Rl_Append.Arcolumn11      := Rl_Source.Arcolumn11;
    Rl_Append.Arjtmk          := Rl_Source.Arjtmk;
    Rl_Append.Arjtsrq         := Rl_Source.Arjtsrq;
    Rl_Append.Arcolumn12      := Rl_Source.Arcolumn12;
  
    Rl_Append.Arprimcode  := Mi.Sbpriid; --VARCHAR2(200)  Y    合收表主表号
    Rl_Append.Arpriflag   := Mi.Sbpriflag; --CHAR(1)  Y    合收表标志
    Rl_Append.Arrper := (CASE
                          WHEN Rl_Source.Arid IS NOT NULL THEN
                           Rl_Source.Arrper
                          ELSE
                           Bf.Read_Per
                        END); --VARCHAR2(10)  Y    抄表员
    Rl_Append.Arsafid := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Arsafid
                           ELSE
                            NULL
                         END); --VARCHAR2(10)  Y    区域
    Rl_Append.Arscodechar := To_Char(p_Rlscode); --VARCHAR2(10)  Y    上期抄表（带表位）
    Rl_Append.Arecodechar := To_Char(p_Rlecode); --VARCHAR2(10)  Y    本期抄表（带表位）
    Rl_Append.Arilid := (CASE
                          WHEN Rl_Source.Arid IS NOT NULL THEN
                           Rl_Source.Arilid
                          ELSE
                           NULL
                        END); --VARCHAR2(40)  Y    发票打印批次
    Rl_Append.Armiuiid    := Mi.Sbuiid; --VARCHAR2(10)  Y    合收单位编号
    Rl_Append.Argroup := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Argroup
                           ELSE
                            NULL
                         END); --NUMBER(2)  Y    应收帐分组
    /**/
    Rl_Append.Arznj := p_Rlznj; --NUMBER(13,3)  Y    违约金
    /**/
    Rl_Append.Arzndate := p_Rlzndate; --DATE  Y    违约金起算日
    /**/
    Rl_Append.Arznjreducflag := p_Rlznjreducflag; --VARCHAR2(1)  Y    滞纳金减免标志,未减免时为N，销帐时滞纳金直接计算；减免后为Y,销帐时滞纳金直接取rlznj
    Rl_Append.Armistid := (CASE
                            WHEN Rl_Source.Arid IS NOT NULL THEN
                             Rl_Source.Armistid
                            ELSE
                             NULL
                          END); --VARCHAR2(10)  Y    行业分类
    /**/
    Rl_Append.Arminame      := Nvl(p_Rlcname, Mi.Sbname); --VARCHAR2(64)  Y    票据名称
    Rl_Append.Arsxf         := 0; --NUMBER(12,2)  Y    手续费
    Rl_Append.Armiface2 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiface2
                             ELSE
                              NULL
                           END); --VARCHAR2(2)  Y    抄见故障
    Rl_Append.Armiface3 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiface3
                             ELSE
                              NULL
                           END); --VARCHAR2(2)  Y    非常计量
    Rl_Append.Armiface4 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiface4
                             ELSE
                              NULL
                           END); --VARCHAR2(2)  Y    表井设施说明
    Rl_Append.Armiifckf := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiifckf
                             ELSE
                              NULL
                           END); --CHAR(1)  Y    垃圾费户数
    Rl_Append.Armigps := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Armigps
                           ELSE
                            NULL
                         END); --VARCHAR2(60)  Y    是否合票
    Rl_Append.Armiqfh := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Armiqfh
                           ELSE
                            NULL
                         END); --VARCHAR2(20)  Y    铅封号
    Rl_Append.Armibox := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Armibox
                           ELSE
                            NULL
                         END); --VARCHAR2(10)  Y    消防水价（增值税水价，襄阳需求）
    Rl_Append.Arminame2 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Arminame2
                             ELSE
                              NULL
                           END); --VARCHAR2(64)  Y    招牌名称(小区名，襄阳需求）
    Rl_Append.Armiseqno := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiseqno
                             ELSE
                              NULL
                           END); --VARCHAR2(50)  Y    户号（初始化时册号+序号）
    Rl_Append.Arsavingqc    := Mi.Sbsaving; --NUMBER(13,3)  Y    算费时预存
    Rl_Append.Armicommunity := (CASE
                                 WHEN Rl_Source.Arid IS NOT NULL THEN
                                  Rl_Source.Armicommunity
                                 ELSE
                                  NULL
                               END); --VARCHAR2(10)  Y    小区
  
    --rl_append.ARbddsl         := 0; --NUMBER(10)  Y    估抄水量
    /**/
    Rl_Append.Arsl := p_Rlsl; --NUMBER(10)  Y    应收水量
    /**/
    Rl_Append.Arje          := p_Rlje; --NUMBER(13,3)  Y    应收金额
    Rl_Append.Arpaidje      := 0; --NUMBER(13,3)  Y    销帐金额
    Rl_Append.Arpaidflag    := 'N'; --CHAR(1)  Y    销帐标志(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
    Rl_Append.Arpaidper     := NULL; --VARCHAR2(20)  Y    销帐人员
    Rl_Append.Arpaiddate    := NULL; --DATE  Y    销帐日期
    Rl_Append.Arpaidmonth   := NULL; --VARCHAR2(7)  Y    销账月份
    Rl_Append.Arcolumn11    := NULL; --VARCHAR2(7)  Y    实收事务
    Rl_Append.Arpid         := NULL; --VARCHAR2(10)  Y    实收流水（与payment.pid对应）
    Rl_Append.Arpbatch      := NULL; --VARCHAR2(10)  Y    缴费交易批次（与payment.PBATCH对应）
    Rl_Append.Arsavingqc    := 0; --NUMBER(12,2)  Y    期初预存（销帐时产生）
    Rl_Append.Arsavingbq    := 0; --NUMBER(12,2)  Y    本期预存发生（销帐时产生）
    Rl_Append.Arsavingqm    := 0; --NUMBER(12,2)  Y    期末预存（销帐时产生）
    Rl_Append.Arreverseflag := 'N'; --VARCHAR2(1)  Y      冲正标志（N为正常，Y为冲正）
    Rl_Append.Arbadflag     := 'N'; --VARCHAR2(1)  Y    呆帐标志（Y :呆坏帐，O:呆坏帐审批中，N:正常帐）
    BEGIN
      --NUMBER(13,3)  Y  之前欠费
      SELECT Nvl(SUM(Nvl(Arje, 0) - Nvl(Arpaidje, 0)), 0)
        INTO Rl_Append.Arpriorje
        FROM Ys_Zw_Arlist
       WHERE Arreverseflag = 'Y'
         AND Arpaidflag = 'N'
         AND Arje > 0
         AND Sbid = Rl_Append.Sbid;
    EXCEPTION
      WHEN OTHERS THEN
        Rl_Append.Arpriorje := 0;
    END;
    IF p_Parm_Append1rds IS NOT NULL THEN
      FOR i IN p_Parm_Append1rds.First .. p_Parm_Append1rds.Last LOOP
        Vappend1rd := p_Parm_Append1rds(i);
        --
        Rd_Append.Id            := Uuid();
        Rd_Append.Hire_Code     := f_Get_Hire_Code();
        Rd_Append.Ardid         := o_Rlid; --VARCHAR2(10)      流水号
        Rd_Append.Ardpmdid      := Vappend1rd.Ardpmdid; --NUMBER      混合用水分组
        Rd_Append.Ardpiid       := Vappend1rd.Ardpiid; --CHAR(2)      费用项目
        Rd_Append.Ardpfid       := Nvl(Vappend1rd.Ardpfid, p_Rlpfid); --VARCHAR2(10)      费率
        Rd_Append.Ardpscid      := Vappend1rd.Ardpscid; --NUMBER      费率明细方案
        Rd_Append.Ardclass      := Vappend1rd.Ardclass; --NUMBER      阶梯级别
        Rd_Append.Ardysdj       := Vappend1rd.Arddj; --NUMBER(13,3)  Y    应收单价
        Rd_Append.Ardyssl       := Vappend1rd.Ardsl; --NUMBER(12,2)  Y    应收水量
        Rd_Append.Ardysje       := Vappend1rd.Ardje; --NUMBER(13,3)  Y    应收金额
        Rd_Append.Arddj         := Vappend1rd.Arddj; --NUMBER(13,3)  Y    实收单价
        Rd_Append.Ardsl         := Vappend1rd.Ardsl; --NUMBER(12,2)  Y    实收水量
        Rd_Append.Ardje         := Vappend1rd.Ardje; --NUMBER(13,3)  Y    实收金额
        Rd_Append.Ardadjdj      := 0; --NUMBER(13,3)  Y    调整单价
        Rd_Append.Ardadjsl      := 0; --NUMBER(12,2)  Y    调整水量
        Rd_Append.Ardadjje      := 0; --NUMBER(13,3)  Y    调整金额
        Rd_Append.Ardmethod     := NULL; --CHAR(3)  Y    计费方法
        Rd_Append.Ardpaidflag   := NULL; --CHAR(1)  Y    销帐标志
        Rd_Append.Ardpaiddate   := NULL; --DATE  Y    销帐日期
        Rd_Append.Ardpaidmonth  := NULL; --VARCHAR2(7)  Y    销帐月份
        Rd_Append.Ardpaidper    := NULL; --VARCHAR2(20)  Y    销帐人员
        Rd_Append.Ardpmdscale   := NULL; --NUMBER(10,2)  Y    混合比例
        Rd_Append.Ardilid       := Vappend1rd.Ardilid; --VARCHAR2(10)  Y    票据流水
        Rd_Append.Ardznj        := NULL; --NUMBER(12,2)  Y    违约金
        Rd_Append.Ardmemo       := p_Rlmemo; --VARCHAR2(200)  Y    备注
        Rd_Append.Ardmsmfid     := NULL; --VARCHAR2(10)  Y    营销公司
        Rd_Append.Ardmonth      := NULL; --VARCHAR2(7)  Y    帐务月份
        Rd_Append.Ardmid        := NULL; --VARCHAR2(10)  Y    水表编号
        Rd_Append.Ardpmdtype    := NULL; --VARCHAR2(2)  Y    混合类别
        Rd_Append.Ardpmdcolumn1 := NULL; --VARCHAR2(10)  Y    备用字段1
        Rd_Append.Ardpmdcolumn2 := NULL; --VARCHAR2(10)  Y    备用字段2
        Rd_Append.Ardpmdcolumn3 := NULL; --VARCHAR2(10)  Y    备用字段3
      
        --复制到rdTab_append
        IF Rdtab_Append IS NULL THEN
          Rdtab_Append := Rd_Table(Rd_Append);
        ELSE
          Rdtab_Append.Extend;
          Rdtab_Append(Rdtab_Append.Last) := Rd_Append;
        END IF;
      END LOOP;
    END IF;
  
    --其他控制赋值
    IF p_Ctl_Mircode IS NOT NULL THEN
      UPDATE Ys_Yh_Sbinfo
         SET Sbrcode     = To_Number(p_Ctl_Mircode),
             Sbrcodechar = p_Ctl_Mircode
       WHERE Sbid = p_Rlmid;
    END IF;
  
    --2、提交处理
    BEGIN
      INSERT INTO Ys_Zw_Arlist VALUES Rl_Append;
      FOR k IN Rdtab_Append.First .. Rdtab_Append.Last LOOP
        INSERT INTO Ys_Zw_Ardetail VALUES Rdtab_Append (k);
      END LOOP;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rlsource%ISOPEN THEN
        CLOSE c_Rlsource;
      END IF;
      IF c_Ci%ISOPEN THEN
        CLOSE c_Ci;
      END IF;
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Recappendcore;

  /*==========================================================================
  应收追正
  【输入参数说明】：
  p_rlid_source in number：源应收流水号
  p_rdpiids ：指定基于原应收帐派生的枚举费项（一位数组字符串，基于TOOLS.FGETPARA二维数组规范），例'01|02|03|'）;
              应收总账下全部费项传'ALL'；
              此参数为空，追正帐应收明细依然按应收总账下全部应收明细记录数生成，但量费均置0；
  p_memo in varchar2：冲正备注
  p_commit in number default 不提交：是否提交
  【输出参数说明】：
  【过程说明】：
  基于原应收记录复制追加一条应收（欠费状态）记录及关联应收明细（可指定枚举的费用项目）；
  提供给部分销帐预处理（拆分应收）、实收冲正、退费业务过程中调用
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  PROCEDURE Recappendinherit(p_Rlid_Source IN VARCHAR2,
                             p_Rdpiids     IN VARCHAR2,
                             p_Rltrans     IN VARCHAR2,
                             p_Memo        IN VARCHAR2,
                             p_Commit      IN NUMBER DEFAULT 不提交,
                             o_Rlid        OUT VARCHAR2,
                             o_Rlje        OUT NUMBER) IS
    CURSOR c_Rl(Vrlid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Vrlid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_Rd(Vrlid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Ardetail WHERE Ardid = Vrlid FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    --原应收
    Rl_Source Ys_Zw_Arlist%ROWTYPE;
    Rd_Source Ys_Zw_Ardetail%ROWTYPE;
  
    Vappend1rd  Parm_Append1rd;
    Vappend1rds Parm_Append1rd_Tab;
  BEGIN
    o_Rlje     := Nvl(o_Rlje, 0);
    Vappend1rd := Parm_Append1rd(NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL);
    OPEN c_Rl(p_Rlid_Source);
    FETCH c_Rl
      INTO Rl_Source;
    IF c_Rl%FOUND THEN
      OPEN c_Rd(p_Rlid_Source);
      FETCH c_Rd
        INTO Rd_Source;
      IF c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                '无效的应收流水号' || p_Rlid_Source);
      END IF;
      WHILE c_Rd%FOUND LOOP
        ------------------------------------------------
        IF Instr(p_Rdpiids, Rd_Source.Ardpiid || '|') > 0 OR
           Upper(p_Rdpiids) = 'ALL' THEN
          Vappend1rd.Hire_Code := Rd_Source.Hire_Code;
          Vappend1rd.Ardpmdid  := Rd_Source.Ardpmdid;
          Vappend1rd.Ardpfid   := Rd_Source.Ardpfid;
          Vappend1rd.Ardpscid  := Rd_Source.Ardpscid;
          Vappend1rd.Ardpiid   := Rd_Source.Ardpiid;
          Vappend1rd.Ardclass  := Rd_Source.Ardclass;
          Vappend1rd.Arddj     := Rd_Source.Arddj;
          Vappend1rd.Ardsl     := Rd_Source.Ardsl;
          Vappend1rd.Ardje     := Rd_Source.Ardje;
          Vappend1rd.Ardilid   := Rd_Source.Ardilid;
        ELSE
          Vappend1rd.Hire_Code := Rd_Source.Hire_Code;
          Vappend1rd.Ardpmdid  := Rd_Source.Ardpmdid;
          Vappend1rd.Ardpfid   := Rd_Source.Ardpfid;
          Vappend1rd.Ardpscid  := Rd_Source.Ardpscid;
          Vappend1rd.Ardpiid   := Rd_Source.Ardpiid;
          Vappend1rd.Ardclass  := Rd_Source.Ardclass;
          Vappend1rd.Arddj     := Rd_Source.Arddj;
          Vappend1rd.Ardsl     := 0;
          Vappend1rd.Ardje     := 0;
          Vappend1rd.Ardilid   := Rd_Source.Ardilid;
        END IF;
        --复制到vappend1rds
        IF Vappend1rds IS NULL THEN
          Vappend1rds := Parm_Append1rd_Tab(Vappend1rd);
        ELSE
          Vappend1rds.Extend;
          Vappend1rds(Vappend1rds.Last) := Vappend1rd;
        END IF;
        o_Rlje := o_Rlje + Vappend1rd.Ardje;
        ------------------------------------------------
        FETCH c_Rd
          INTO Rd_Source;
      END LOOP;
      CLOSE c_Rd;
    ELSE
      Raise_Application_Error(Errcode, '无效的应收流水号');
    END IF;
  
    Recappendcore(Rl_Source.Sbid,
                  Rl_Source.Arminame,
                  Rl_Source.Arpfid,
                  Rl_Source.Arrdate,
                  Rl_Source.Arscode,
                  Rl_Source.Arecode,
                  Rl_Source.Arsl,
                  o_Rlje,
                  Rl_Source.Arznjreducflag,
                  Rl_Source.Arzndate,
                  Rl_Source.Arznj,
                  p_Rltrans, --rl_source.rltrans,
                  p_Memo,
                  Rl_Source.Arid,
                  Vappend1rds,
                  NULL, --不重置起码
                  不提交,
                  o_Rlid);
  
    --2、提交处理
    BEGIN
      CLOSE c_Rl;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Recappendinherit;

  /*==========================================================================
  实收冲正次核心
  【输入参数说明】：
  p_pid_source  in number：待冲正实收流水号，允许预存充值实收类型（无关联应收销帐）
  p_position      in varchar2：冲正到缴费单位
  p_paypoint    in varchar2：冲正到缴费点
  p_ptrans      in varchar2：冲正到实收事务
  p_bdate       in date：银行冲正日期
  p_bseqno      in varchar2：银行冲正流水
  p_oper        in varchar2：冲正操作员
  p_payway      in varchar2：冲正到付款方式
  p_memo        in varchar2：冲正备注
  p_commit      in number：是否提交
  
  【输出参数说明】：
  o_pid_reverse out number：冲正（负帐）记录实收流水号
  o_ppayment_reverse out number：冲正（负帐）记录实收冲正金额
  【过程说明】：
  提供水司柜台冲正、银行实时退单、银行单边帐冲正调用
  基于一条实收记录payment.pid进行实收冲正的操作，且对全部关联应收进行逆销帐，
  与退费本质不同在于
  1）同时冲正预存发生金额；
  2）应收冲正后进行应收追正，而退费视部分退费与否或追正后追销或不追；
  冲正流程为：实收冲正（当月负实收）-->应收冲正（追加当月全额负帐）-->应收追补（追加当月全额正帐）
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  PROCEDURE Payreverse(p_Pid_Source       IN VARCHAR2,
                       p_Position         IN VARCHAR2,
                       p_Paypoint         IN VARCHAR2,
                       p_Ptrans           IN VARCHAR2,
                       p_Bdate            IN DATE,
                       p_Bseqno           IN VARCHAR2,
                       p_Oper             IN VARCHAR2,
                       p_Payway           IN VARCHAR2,
                       p_Memo             IN VARCHAR2,
                       p_Commit           IN NUMBER,
                       o_Pid_Reverse      OUT VARCHAR2,
                       o_Ppayment_Reverse OUT NUMBER,
                       o_Append_Rlid      OUT VARCHAR2) IS
    o_Append_Rlje NUMBER;
    --
    o_Rlid_Reverse        VARCHAR2(10);
    o_Rltrans_Reverse     VARCHAR2(10);
    o_Rlje_Reverse        NUMBER;
    o_Rlznj_Reverse       NUMBER;
    o_Rlsxf_Reverse       NUMBER;
    o_Rlsavingbq_Reverse  NUMBER;
    Io_Rlsavingqm_Reverse NUMBER;
  BEGIN
    --实收冲正（当月负实收）
    Payreversecorebypid(p_Pid_Source,
                        p_Position,
                        p_Paypoint,
                        p_Ptrans,
                        p_Bdate,
                        p_Bseqno,
                        p_Oper,
                        p_Payway,
                        p_Memo,
                        不提交,
                        'Y',
                        o_Pid_Reverse,
                        o_Ppayment_Reverse);
    FOR i IN (SELECT Arid, Arpaidje, Artrans
                FROM Ys_Zw_Arlist
               WHERE Arpid = p_Pid_Source
                 AND Arreverseflag = 'N'
               ORDER BY Arid) LOOP
      --应收冲正（追加当月全额负帐）
      Zwarreversecore(i.Arid, -- P_ARID_SOURCE         IN VARCHAR2,
                      i.Artrans, --P_ARTRANS_REVERSE     IN VARCHAR2,
                      NULL, --    P_PBATCH_REVERSE      IN VARCHAR2,
                      o_Pid_Reverse, --     P_PID_REVERSE         IN VARCHAR2,
                      -i.Arpaidje, --    P_PPAYMENT_REVERSE    IN NUMBER,
                      p_Memo, --    P_MEMO                IN VARCHAR2,
                      NULL, --    P_CTL_MIRCODE         IN VARCHAR2,
                      不提交, --    P_COMMIT              IN NUMBER DEFAULT 不提交,
                      o_Rlid_Reverse,
                      o_Rltrans_Reverse,
                      o_Rlje_Reverse,
                      o_Rlznj_Reverse,
                      o_Rlsxf_Reverse,
                      o_Rlsavingbq_Reverse,
                      Io_Rlsavingqm_Reverse); /* O_ARID_REVERSE        OUT VARCHAR2,
                                O_ARTRANS_REVERSE     OUT VARCHAR2,
                                O_ARJE_REVERSE        OUT NUMBER,
                                O_ARZNJ_REVERSE       OUT NUMBER,
                                O_ARSXF_REVERSE       OUT NUMBER,
                                O_ARSAVINGBQ_REVERSE  OUT NUMBER,
                                IO_ARSAVINGQM_REVERSE IN OUT NUMBER
                                */
      --应收追补（追加当月全额正帐）
      Recappendinherit(i.Arid,
                       'ALL',
                       o_Rltrans_Reverse,
                       p_Memo,
                       不提交,
                       o_Append_Rlid,
                       o_Append_Rlje);
    END LOOP;
  
    --2、提交处理
    BEGIN
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Payreverse;
  
  /*==========================================================================
  水司柜台冲正(不退款)，不记独立实收事务
  【输入参数说明】：
  p_pid_source  in number：待冲正原实收流水号
  p_oper        in varchar2：冲正操作员
  p_memo        in varchar2：其他冲正备注信息
  
  【输出参数说明】：
  p_pid_reverse out number：冲正成功后返回的冲正记录（负实收记录）流水号
  
  【过程说明】：
  柜台缴费页面集成功能，当日或隔日均冲正到本期，计帐为原实收单位、原实收缴费点、原实收事务、原付款方式
  支持冲正预存充值交易
  其他【过程说明】见子过程PayReverse《实收冲正次核心》说明
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  procedure PosReverse(p_pid_source  in varchar2,
                       p_oper        in varchar2,
                       p_memo        in varchar2,
                       p_commit      in number default 不提交,
                       p_pid_reverse out varchar2) is
    p                  ys_zw_paidment%rowtype;
    vppaymentreverse number(12, 2);
    vappendrlid      varchar2(10);
  begin
    select * into p from ys_zw_paidment  where pid = p_pid_source;
    --校验
    if not (p.PREVERSEFLAG = 'N' and p.PAIDMENT >= 0) then
      raise_application_error(errcode,
                              '待冲正实收记录无效，必须为未冲正的正常缴费');
    end if;
    PayReverse(p_pid_source,
               p.MANAGE_NO,
               p.PDPAYPOINT,
               p.PDTRAN,
               null,
               null,
               p_oper,
               p.PDPAYWAY,
               p_memo,
               不提交,
               p_pid_reverse,
               vppaymentreverse,
               vappendrlid);
  
    --2、提交处理
    begin
      if p_commit = 调试 then
        rollback;
      else
        if p_commit = 提交 then
          commit;
        elsif p_commit = 不提交 then
          null;
        else
          raise_application_error(errcode, '是否提交参数不正确');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      raise_application_error(errcode, '是否提交参数不正确' || p_pid_source); 
      raise;
      --raise_application_error(errcode, sqlerrm);
  end PosReverse;

/*==========================================================================
  应收追调
  【输入参数说明】：
  p_rlmid  varchar2(20)  ：非空，水表编号
  p_rlcname in varchar2 ：为空时reclist.rlcname取实时ci.ciname，非空时去传入值（营业外收费业务中指定票据名称）
  p_rlpfid  varchar2(10)  ：非空，价格类别编号
  p_rlrmonth  varchar2(7)  ：非空，抄表月份
  p_rlrdate  date  ：非空，抄表日期
  p_rlscode  number(10)  ：非空，上次抄表读数
  p_rlecode  number(10)  ：非空，本次抄表读数
  p_rlsl  number(10)  ：非空，应收水量
  p_rlje  number(13,2)  ：非空，应收金额
  p_rltrans in varchar2 ：非空，应收事务（类别），reclist.rllb
  p_rlmemo  varchar2(100)  ：可空，备注信息
  p_rlid_source in number ：可空，绑定原应收帐
  p_parm_append1rds parm_append1rd_tab ：非空，应收帐明细包
  p_ctl_mircode ：非空时以此值覆盖meterinfo.mircode(即重置下期起码)，为空时不进行此处理
  【输出参数说明】：
  o_rlid out number：返回追补的应收记录流水号
  【过程说明】：
  基于应收调整业务中的调整目标账务（总账+明细）追加一条应收记录及关联应收明细
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  procedure RecAppendAdj(p_rlmid           in varchar2,
                         p_rlcname         in varchar2,
                         p_rlpfid          in varchar2,
                         p_rlrdate         in date,
                         p_rlscode         in number,
                         p_rlecode         in number,
                         p_rlsl            in number,
                         p_rlje            in number,
                         p_rlznj           in number,
                         p_rltrans         in varchar2,
                         p_rlmemo          in varchar2,
                         p_rlid_source     in varchar2,
                         p_parm_append1rds parm_append1rd_tab,
                         p_ctl_mircode     in varchar2,
                         p_commit          in number default 不提交,
                         o_rlid            out varchar2) is
    cursor c_rl(vrlid varchar2) is
      select * from ys_zw_arlist  where arid = vrlid for update nowait; --若被锁直接抛出异常
    rl_source ys_zw_arlist%rowtype;
  begin
    --退费正帐应收事务继承原帐务
    open c_rl(p_rlid_source);
    fetch c_rl
      into rl_source;
    if c_rl%notfound or c_rl%notfound is null then
      raise_application_error(errcode, '无原帐务应收记录');
    end if;
    close c_rl;
  
    RecAppendCore(p_rlmid,
                  p_rlcname,
                  p_rlpfid,
                  p_rlrdate,
                  p_rlscode,
                  p_rlecode,
                  p_rlsl,
                  p_rlje,
                  rl_source.arznjreducflag,
                  rl_source.arzndate,
                  p_rlznj,
                  p_rltrans,
                  p_rlmemo,
                  p_rlid_source,
                  p_parm_append1rds,
                  p_ctl_mircode,
                  不提交,
                  o_rlid);
    --2、提交处理
    begin
      if p_commit = 调试 then
        rollback;
      else
        if p_commit = 提交 then
          commit;
        elsif p_commit = 不提交 then
          null;
        else
          raise_application_error(errcode, '是否提交参数不正确');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end RecAppendAdj;
/*==========================================================================
  应收调整
  【输入参数说明】：
  p_rlmid  varchar2(20)  ：非空，水表编号
  p_rlcname in varchar2 ：为空时reclist.rlcname取实时ci.ciname，非空时去传入值（营业外收费业务中指定票据名称）
  p_rlpfid  varchar2(10)  ：非空，价格类别编号
  p_rlrmonth  varchar2(7)  ：非空，抄表月份
  p_rlrdate  date  ：非空，抄表日期
  p_rlscode  number(10)  ：非空，上次抄表读数
  p_rlecode  number(10)  ：非空，本次抄表读数
  p_rlsl  number(10)  ：非空，应收水量
  p_rlje  number(13,2)  ：非空，应收金额
  p_rltrans in varchar2 ：非空，应收事务（类别），reclist.rllb
  p_rlmemo  varchar2(100)  ：可空，备注信息
  p_rlid_source in number ：非空，绑定原应收帐
  p_parm_append1rds parm_append1rd_tab ：非空，应收帐明细包
  p_ctl_mircode ：非空时以此值覆盖meterinfo.mircode(即重置下期起码)，为空时不进行此处理
  【输出参数说明】：
  o_rlid_reverse out varchar2：
  o_rlid out varchar2：返回追补的应收记录流水号
  【过程说明】：
  基于单据调整应收价量费
  调整流程为：应收冲正（追加当月全额负帐）-->应收追补
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  procedure RecAdjust(p_rlmid           in varchar2,
                      p_rlcname         in varchar2,
                      p_rlpfid          in varchar2,
                      p_rlrdate         in date,
                      p_rlscode         in number,
                      p_rlecode         in number,
                      p_rlsl            in number,
                      p_rlje            in number,
                      p_rlznj           in number,
                      p_rltrans         in varchar2,
                      p_rlmemo          in varchar2,
                      p_rlid_source     in varchar2,
                      p_parm_append1rds parm_append1rd_tab,
                      p_commit          in number default 不提交,
                      p_ctl_mircode     in varchar2,
                      o_rlid_reverse    out varchar2,
                      o_rlid            out varchar2) is
    --
    o_rltrans_reverse     varchar2(10);
    o_rlje_reverse        number;
    o_rlznj_reverse       number;
    o_rlsxf_reverse       number;
    o_rlsavingbq_reverse  number;
    io_rlsavingqm_reverse number;
  begin
    Zwarreversecore(p_rlid_source,
                   p_rltrans,
                   null,
                   null, --应收调整无关联实收记录p_pid_reverse
                   null, --应收调整无关联实收记录
                   p_rlmemo,
                   null, --此过程不重置止码，让追补核心处理
                   p_commit,
                   o_rlid_reverse,
                   o_rltrans_reverse,
                   o_rlje_reverse,
                   o_rlznj_reverse,
                   o_rlsxf_reverse,
                   o_rlsavingbq_reverse,
                   io_rlsavingqm_reverse);
    if not (p_rlsl = 0 and p_rlje = 0 and p_rlznj = 0) then
      RecAppendAdj(p_rlmid,
                   p_rlcname,
                   p_rlpfid,
                   p_rlrdate,
                   p_rlscode,
                   p_rlecode,
                   p_rlsl,
                   p_rlje,
                   p_rlznj,
                   o_rltrans_reverse,
                   p_rlmemo,
                   p_rlid_source,
                   p_parm_append1rds,
                   p_ctl_mircode,
                   p_commit,
                   o_rlid);
    else
      --其他控制赋值
      if p_ctl_mircode is not null then
        update ys_yh_sbinfo
           set sbrcode     = to_number(p_ctl_mircode),
               sbrcodechar = p_ctl_mircode
         where sbid = p_rlmid;
      end if;
    
    end if;
    --2、提交处理
    begin
      if p_commit = 调试 then
        rollback;
      else
        if p_commit = 提交 then
          commit;
        elsif p_commit = 不提交 then
          null;
        else
          raise_application_error(errcode, '是否提交参数不正确');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      /*pg_ewide_interface.ErrLog(dbms_utility.format_call_stack(),
                                'RecAdjust,p_rlmid:' || p_rlmid);*/
      --raise;
      raise_application_error(errcode, sqlerrm);
  end RecAdjust;
BEGIN
  NULL;

END;
/

