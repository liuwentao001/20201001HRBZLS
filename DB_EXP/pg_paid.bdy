CREATE OR REPLACE PACKAGE BODY Pg_Paid IS
  Curdatetime DATE;

  FUNCTION Obtwyj(p_Sdate IN DATE, p_Edate IN DATE, p_Je IN NUMBER)
    RETURN NUMBER IS
    v_Result NUMBER;
  BEGIN
    v_Result := p_Je * (Trunc(p_Edate) - Trunc(p_Sdate) + 1) * 0.003;
    v_Result := Pg_Cb_Cost.Getmax(v_Result, 0);
    RETURN v_Result;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  --违约金计算
  FUNCTION Obtwyjadj(p_Arid     IN VARCHAR2, --应收流水
                     p_Ardpiids IN VARCHAR2, --应收明细费项串'01|02|03'
                     p_Edate    IN DATE --终算日'不计入'违约日,参数格式'yyyy-mm-dd'
                     ) RETURN NUMBER IS
    Vresult          NUMBER;
    v_Arzndate       Ys_Zw_Arlist.Arzndate%TYPE;
    v_Arznj          Ys_Zw_Arlist.Arznj%TYPE;
    v_Outflag        Ys_Zw_Arlist.Aroutflag%TYPE;
    v_Sbid           Ys_Zw_Arlist.Sbid%TYPE;
    v_Arje           Ys_Zw_Arlist.Arje%TYPE;
    v_Yhifzn         Ys_Yh_Custinfo.Yhifzn%TYPE;
    v_Arznjreducflag Ys_Zw_Arlist.Arznjreducflag%TYPE;
    v_Chargetype     VARCHAR2(10);
  BEGIN
    BEGIN
      SELECT a.Sbid,
             MAX(Arzndate),
             MAX(Arznj),
             MAX(Aroutflag),
             SUM(Ardje),
             MAX(Yhifzn),
             MAX(Arznjreducflag),
             MAX(Nvl(Sbchargetype, 'X'))
        INTO v_Sbid,
             v_Arzndate,
             v_Arznj,
             v_Outflag,
             v_Arje,
             v_Yhifzn,
             v_Arznjreducflag,
             v_Chargetype
        FROM Ys_Zw_Arlist   a,
             Ys_Yh_Custinfo b,
             Ys_Zw_Ardetail c,
             Ys_Yh_Sbinfo   d
       WHERE a.Sbid = d.Sbid
         AND b.Yhid = d.Yhid
         AND a.Arid = c.Ardid
         AND Instr(p_Ardpiids, Ardpiid) > 0
         AND Arid = p_Arid
       GROUP BY Arid, a.Sbid;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
    END;
  
    --暂时屏蔽
    --return 0;
  
    IF v_Yhifzn = 'N' OR v_Chargetype IN ('D', 'T') THEN
      RETURN 0;
    END IF;
    IF v_Arje < 0 THEN
      v_Arje := 0;
    END IF;
    IF v_Arznjreducflag = 'Y' THEN
      RETURN v_Arznj;
    END IF;
  
    Vresult := Obtwyj(v_Arzndate, p_Edate, v_Arje);
    --不得超过本金
    IF Vresult > v_Arje THEN
      Vresult := v_Arje;
    END IF;
  
    RETURN Trunc(Vresult, 2);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  /*==========================================================================
  水司柜台缴费（一表）,参数简化版
  '123456789,Y*01!Y*02!Y*03!,0.10,0,0,0|123456789,Y*01!Y*02!Y*03!,0.10,0,0,0|'
  */
  PROCEDURE Poscustforys(p_Sbid     IN VARCHAR2,
                         p_Arstr    IN VARCHAR2,
                         p_Position IN VARCHAR2,
                         p_Oper     IN VARCHAR2,
                         p_Paypoint IN VARCHAR2,
                         p_Payway   IN VARCHAR2,
                         p_Payment  IN NUMBER,
                         p_Batch    IN VARCHAR2,
                         p_Pid      OUT VARCHAR2) IS
  
    v_Parm_Ar  Parm_Payar;
    v_Parm_Ars Parm_Payar_Tab;
  BEGIN
    v_Parm_Ar  := Parm_Payar(NULL, NULL, NULL, NULL, NULL, NULL);
    v_Parm_Ars := Parm_Payar_Tab();
    FOR i IN 1 .. Fmid(p_Arstr, '|') - 1 LOOP
      v_Parm_Ar.Arid     := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 1);
      v_Parm_Ar.Ardpiids := REPLACE(REPLACE(Pg_Cb_Cost.Fgetpara(p_Arstr,
                                                                i,
                                                                2),
                                            '*',
                                            ','),
                                    '!',
                                    '|');
      v_Parm_Ar.Arwyj    := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 3);
      v_Parm_Ar.Fee1     := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 4);
      v_Parm_Ar.Fee2     := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 5);
      v_Parm_Ar.Fee3     := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 6);
      v_Parm_Ars.Extend;
      v_Parm_Ars(v_Parm_Ars.Last) := v_Parm_Ar;
    END LOOP;
  
    Poscust(p_Sbid,
            v_Parm_Ars,
            p_Position,
            p_Oper,
            p_Paypoint,
            p_Payway,
            p_Payment,
            p_Batch,
            p_Pid);
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Poscust(p_Sbid     IN VARCHAR2,
                    p_Parm_Ars IN Parm_Payar_Tab,
                    p_Position IN VARCHAR2,
                    p_Oper     IN VARCHAR2,
                    p_Paypoint IN VARCHAR2,
                    p_Payway   IN VARCHAR2,
                    p_Payment  IN NUMBER,
                    p_Batch    IN VARCHAR2,
                    p_Pid      OUT VARCHAR2) IS
    Vbatch       VARCHAR2(10);
    Vseqno       VARCHAR2(10);
    v_Parm_Ars   Parm_Payar_Tab;
    Vremainafter NUMBER;
    v_Parm_Count NUMBER;
  BEGIN
    Vbatch     := p_Batch;
    v_Parm_Ars := p_Parm_Ars;
    --核心部分校验
    FOR i IN (SELECT a.Aroutflag
                FROM Ys_Zw_Arlist a, TABLE(v_Parm_Ars) b
               WHERE a.Arid = b.Arid) LOOP
      IF 允许重复销帐 = 0 AND i.Aroutflag = 'Y' THEN
        Raise_Application_Error(Errcode,
                                '当前系统规则不允许划扣中进行应收冲正');
      END IF;
    END LOOP;
  
    SELECT COUNT(*) INTO v_Parm_Count FROM TABLE(v_Parm_Ars) b;
    IF v_Parm_Count = 0 THEN
      IF p_Payment > 0 THEN
        --单缴预存核心
        Precust(p_Sbid        => p_Sbid,
                p_Position    => p_Position,
                p_Oper        => p_Oper,
                p_Payway      => p_Payway,
                p_Payment     => p_Payment,
                p_Memo        => NULL,
                p_Batch       => Vbatch,
                o_Pid         => p_Pid,
                o_Remainafter => Vremainafter);
      ELSE
        NULL;
        --退预存核心
        Precustback(p_Sbid        => p_Sbid,
                    p_Position    => p_Position,
                    p_Oper        => p_Oper,
                    p_Payway      => p_Payway,
                    p_Payment     => p_Payment,
                    p_Memo        => NULL,
                    p_Batch       => Vbatch,
                    o_Pid         => p_Pid,
                    o_Remainafter => Vremainafter);
      END IF;
    ELSE
      Paycust(p_Sbid,
              v_Parm_Ars,
              Ptrans_柜台缴费,
              p_Position,
              p_Paypoint,
              NULL,
              NULL,
              p_Oper,
              p_Payway,
              p_Payment,
              NULL,
              不提交,
              局部屏蔽通知,
              允许拆帐,
              Vbatch,
              Vseqno,
              p_Pid,
              Vremainafter);
    END IF;
  
    --提交处理
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --PG_EWIDE_INTERFACE.ERRLOG(DBMS_UTILITY.FORMAT_CALL_STACK(), P_SBID);
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Paycust(p_Sbid        IN VARCHAR2,
                    p_Parm_Ars    IN Parm_Payar_Tab,
                    p_Trans       IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Paypoint    IN VARCHAR2,
                    p_Bdate       IN DATE,
                    p_Bseqno      IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Pid_Source  IN VARCHAR2,
                    p_Commit      IN NUMBER,
                    p_Ctl_Msg     IN NUMBER,
                    p_Ctl_Pre     IN NUMBER,
                    p_Batch       IN OUT VARCHAR2,
                    p_Seqno       IN OUT VARCHAR2,
                    p_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER) IS
    CURSOR c_Ma(Vmamid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Account WHERE Sbid = Vmamid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_Ci(Vciid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vciid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    Mi         Ys_Yh_Sbinfo%ROWTYPE;
    Ci         Ys_Yh_Custinfo%ROWTYPE;
    Ma         Ys_Yh_Account%ROWTYPE;
    p          Ys_Zw_Paidment%ROWTYPE;
    v_Parm_Ars Parm_Payar_Tab;
    p_Parm_Ar  Parm_Payar;
    v_Exists   NUMBER;
  BEGIN
    v_Parm_Ars := p_Parm_Ars;
    --1、实参校验、必要变量准备
    --------------------------------------------------------------------------
    BEGIN
      --取水表信息
      OPEN c_Mi(p_Sbid);
      FETCH c_Mi
        INTO Mi;
      IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                '水表编码【' || p_Sbid || '】不存在！');
      END IF;
      --取用户信息
      OPEN c_Ci(Mi.Yhid);
      FETCH c_Ci
        INTO Ci;
      IF c_Ci%NOTFOUND OR c_Ci%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                '这个水表编码没对应用户！' || p_Sbid);
      END IF;
      --取用户银行账户信息
      OPEN c_Ma(Mi.Sbid);
      FETCH c_Ma
        INTO Ma;
      IF c_Ma%NOTFOUND OR c_Ma%NOTFOUND IS NULL THEN
        NULL;
      END IF;
      --参数校验
      /*if p_parm_rls is null then
        raise_application_error(errcode, '待销帐包是空的怎么办？');
      end if;*/
      --添加核心校验,避免户号与待销账列表不一致
      IF p_Parm_Ars.Count > 0 THEN
        --可以为空（预存充值时）
        FOR i IN p_Parm_Ars.First .. p_Parm_Ars.Last LOOP
          p_Parm_Ar := p_Parm_Ars(i);
          SELECT COUNT(1)
            INTO v_Exists
            FROM Ys_Zw_Arlist a, Ys_Yh_Sbinfo b
           WHERE Arid = p_Parm_Ar.Arid
             AND a.Sbid = b.Sbid
             AND (b.Sbid = p_Sbid OR Sbpriid = p_Sbid);
          IF v_Exists = 0 THEN
            Raise_Application_Error(Errcode,
                                    '请求参数错误，请刷新页面后重新操作!');
          END IF;
        END LOOP;
      END IF;
    
    END;
  
    --2、记录实收
    --------------------------------------------------------------------------
    BEGIN
      SELECT TRIM(To_Char(Seq_Paidment.Nextval, '0000000000'))
        INTO p_Pid
        FROM Dual;
      SELECT Sys_Guid() INTO p.Id FROM Dual;
      p.Hire_Code  := Mi.Hire_Code;
      p.Pid        := p_Pid; --varchar2(10)      流水号
      p.Yhid       := Ci.Yhid; --varchar2(10)      用户编号
      p.Sbid       := p_Sbid; --varchar2(10)  y    水表编号
      p.Pddate     := Trunc(SYSDATE); --date  y    帐务日期
      p.Pdatetime  := SYSDATE; --date  y    发生日期
      p.Pdmonth    := Fobtmanapara(Mi.Manage_No, 'READ_MONTH'); --varchar2(7)  y    缴费月份
      p.Manage_No  := p_Position; --varchar2(10)  y    缴费机构
      p.Pdtran     := p_Trans; --char(1)      缴费事务
      p.Pdpers     := p_Oper; --varchar2(20)  y    销帐人员
      p.Pdsavingqc := Nvl(Mi.Sbsaving, 0); --number(12,2)  y    期初预存余额
      p.Pdsavingbq := p_Payment; --number(12,2)  y    本期发生预存金额
      p.Pdsavingqm := p.Pdsavingqc + p.Pdsavingbq; --number(12,2)  y    期末预存余额
      p.Paidment   := p_Payment; --number(12,2)  y    付款金额
      p.Pdifsaving := NULL; --char(1)  y    找零转预存
      p.Pdchange   := NULL; --number(12,2)  y    找零金额
      p.Pdpayway   := p_Payway; --varchar2(6)  y    付款方式
      p.Pdbseqno   := p_Bseqno; --varchar2(20)  y    银行流水(银行实时收费交易流水)
      p.Pdcseqno   := NULL; --varchar2(20)  y    清算中心流水(no use)
      p.Pdbdate    := p_Bdate; --date  y    银行日期(银行缴费账务日期)
      p.Pdchkdate  := NULL; --date  y    对帐日期
      p.Pdcchkflag := 'N'; --char(1)  y    标志(no use)
      p.Pdcdate    := NULL; --date  y    清算日期
      IF p_Batch IS NULL THEN
        SELECT TRIM(To_Char(Seq_Paidbatch.Nextval, '0000000000'))
          INTO p.Pdbatch
          FROM Dual;
      ELSE
        p.Pdbatch := p_Batch;
      END IF;
      p.Pdseqno      := p_Seqno; --varchar2(10)  y    缴费交易流水(no use)
      p.Pdpayee      := p_Oper; --varchar2(20)  y    收款员
      p.Pdchbatch    := NULL; --varchar2(10)  y    支票交易批次
      p.Pdmemo       := NULL; --varchar2(200)  y    备注
      p.Pdpaypoint   := p_Paypoint; --varchar2(10)  y    缴费地点
      p.Pdsxf        := 0; --number(12,2)  y    手续费
      p.Pdilid       := NULL; --varchar2(40)  y    发票流水号
      p.Pdflag       := 'Y'; --varchar2(1)  y    实收标志（全部为y.暂无启用）
      p.Pdwyj        := 0; --number(12,2)  y    实收滞金
      p.Pdrcreceived := p_Payment; --number(12,2)  y      实际收款金额（实际收款金额 =  付款金额 -找零金额；销帐金额 + 实收滞金 + 手续费 + 本期发生预存金额）
      p.Pdspje       := 0; --number(12,2)  y    销帐金额(如果销帐交易中水费，销帐金额则为水费金额，如果是预存帐为0)
      p.Preverseflag := 'N'; --varchar2(1)  y    冲正标志（收水费收预存是为n,冲水费冲预存被冲实收和冲实收产生负帐匀为y）
      IF p_Pid_Source IS NULL THEN
        p.Pdscrid    := p.Pid;
        p.Pdscrtrans := p.Pdtran;
        p.Pdscrmonth := p.Pdmonth;
        p.Pdscrdate  := p.Pddate;
      ELSE
        SELECT Pid, Pdtran, Pdmonth, Pddate
          INTO p.Pdscrid, p.Pdscrtrans, p.Pdscrmonth, p.Pdscrdate
          FROM Ys_Zw_Paidment
         WHERE Pid = p_Pid_Source;
      END IF;
      p.Pdchkno  := NULL; --varchar2(10)  y    进账单号
      p.Pdpriid  := Mi.Sbpriid; --varchar2(20)  y    合收主表号  20150105
      p.Tchkdate := NULL; --date  y    到账日期
    END;
  
    --3、部分费项销帐分帐
    --------------------------------------------------------------------------
    IF p_Ctl_Pre = 允许拆帐 THEN
      Payzwarpre(v_Parm_Ars, 不提交);
    END IF;
  
    --3.1、含违约金销帐分帐
    --------------------------------------------------------------------------
    IF 允许销帐违约金分帐 THEN
      Paywyjpre(v_Parm_Ars, 不提交);
    END IF;
  
    --4、销帐核心调用（应收记录处理、反馈实收数据）
    --------------------------------------------------------------------------
    Payzwarcore(p.Pid,
                p.Pdbatch,
                p_Payment,
                Mi.Sbsaving,
                p.Pddate,
                p.Pdmonth,
                v_Parm_Ars,
                不提交,
                p.Pdspje,
                p.Pdwyj,
                p.Pdsxf);
  
    --5、重算预存发生、预存期末、更新用户预存余额
    p.Pdsavingqm := p.Pdsavingqc + p_Payment - p.Pdspje - p.Pdwyj - p.Pdsxf;
    p.Pdsavingbq := p.Pdsavingqm - p.Pdsavingqc;
    UPDATE Ys_Yh_Sbinfo SET Sbsaving = p.Pdsavingqm WHERE CURRENT OF c_Mi;
  
    --6、返回预存余额
    o_Remainafter := p.Pdsavingqm;
  
    --7、事务内应实收帐务平衡校验，及校验后分支子过程
    --------------------------------------------------------------------------
  
    --8、其他缴费事务反馈过程
  
    --5、提交处理
    BEGIN
      CLOSE c_Ma;
      CLOSE c_Ci;
      CLOSE c_Mi;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        INSERT INTO Ys_Zw_Paidment VALUES p;
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
      IF c_Ma%ISOPEN THEN
        CLOSE c_Ma;
      END IF;
      IF c_Ci%ISOPEN THEN
        CLOSE c_Ci;
      END IF;
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Payzwarpre(p_Parm_Ars IN OUT Parm_Payar_Tab,
                       p_Commit   IN NUMBER DEFAULT 不提交) IS
    CURSOR c_Rl(Varid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Varid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_Rd(Varid VARCHAR2, Vardpiid VARCHAR2) IS
      SELECT *
        FROM Ys_Zw_Ardetail
       WHERE Ardid = Varid
         AND Ardpiid = Vardpiid
       ORDER BY Ardclass
         FOR UPDATE NOWAIT; --若被锁直接抛出异常
    p_Parm_Ar          Parm_Payar; --销帐包内成员之一
    i                  INTEGER;
    j                  INTEGER;
    k                  INTEGER;
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
    Rl Ys_Zw_Arlist%ROWTYPE;
    Rd Ys_Zw_Ardetail%ROWTYPE;
    --拆后应收1（要销的）
    Rly    Ys_Zw_Arlist%ROWTYPE;
    Rdy    Ys_Zw_Ardetail%ROWTYPE;
    Rdtaby Rd_Table;
    --拆后应收2（不销继续挂欠费的）
    Rln    Ys_Zw_Arlist%ROWTYPE;
    Rdn    Ys_Zw_Ardetail%ROWTYPE;
    Rdtabn Rd_Table;
    --
    o_Arid_Reverse        Ys_Zw_Arlist.Arid%TYPE;
    o_Artrans_Reverse     VARCHAR2(10);
    o_Arje_Reverse        NUMBER;
    o_Arznj_Reverse       NUMBER;
    o_Arsxf_Reverse       NUMBER;
    o_Arsavingbq_Reverse  NUMBER;
    Io_Arsavingqm_Reverse NUMBER;
    --
    Currentdate DATE;
  BEGIN
    Currentdate := SYSDATE;
    --可以为空（预存充值时），空包返回
    IF p_Parm_Ars.Count > 0 THEN
      FOR i IN p_Parm_Ars.First .. p_Parm_Ars.Last LOOP
        p_Parm_Ar := p_Parm_Ars(i);
        IF p_Parm_Ar.Arid IS NOT NULL THEN
          OPEN c_Rl(p_Parm_Ar.Arid);
          FETCH c_Rl
            INTO Rl;
          IF c_Rl%NOTFOUND OR c_Rl%NOTFOUND IS NULL THEN
            Raise_Application_Error(Errcode,
                                    '销帐包中应收流水不存在' || p_Parm_Ar.Arid);
          END IF;
          IF p_Parm_Ar.Ardpiids IS NOT NULL THEN
            Rly      := Rl;
            Rly.Arje := 0;
            Rdtaby   := NULL;
          
            Rln        := Rl;
            Rln.Arje   := 0;
            Rln.Arsxf  := 0; --Rlfee（如有）都放rlY，且必须销帐，暂不支持拆分
            Rdtabn     := NULL;
            待销笔数   := 0;
            不销笔数   := 0;
            待销水量   := 0;
            不销水量   := 0;
            待销金额   := 0;
            不销金额   := 0;
            一行费项数 := Pg_Cb_Cost.Fboundpara(p_Parm_Ar.Ardpiids);
            FOR j IN 1 .. 一行费项数 LOOP
              一行一费项待销标志 := Pg_Cb_Cost.Fgetpara(p_Parm_Ar.Ardpiids, j, 1);
              一行一费项         := Pg_Cb_Cost.Fgetpara(p_Parm_Ar.Ardpiids, j, 2);
              OPEN c_Rd(p_Parm_Ar.Arid, 一行一费项);
              LOOP
                --存在阶梯，所以要循环
                FETCH c_Rd
                  INTO Rd;
                EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
                Rdy    := Rd;
                Rdn    := Rd;
                总金额 := 总金额 + Rd.Ardje;
                IF 一行一费项待销标志 = 'Y' THEN
                  Rly.Arje     := Rly.Arje + Rdy.Ardje;
                  待销笔数     := 待销笔数 + 1;
                  待销水量     := 待销水量 + Rd.Ardsl;
                  待销金额     := 待销金额 + Rd.Ardje;
                  Rdn.Ardyssl  := 0;
                  Rdn.Ardysje  := 0;
                  Rdn.Ardsl    := 0;
                  Rdn.Ardje    := 0;
                  Rdn.Ardadjsl := 0;
                  Rdn.Ardadjje := 0;
                ELSIF 一行一费项待销标志 = 'N' THEN
                  Rln.Arje     := Rln.Arje + Rdn.Ardje;
                  不销笔数     := 不销笔数 + 1;
                  不销水量     := 不销水量 + Rd.Ardsl;
                  不销金额     := 不销金额 + Rd.Ardje;
                  Rdy.Ardyssl  := 0;
                  Rdy.Ardysje  := 0;
                  Rdy.Ardsl    := 0;
                  Rdy.Ardje    := 0;
                  Rdy.Ardadjsl := 0;
                  Rdy.Ardadjje := 0;
                ELSE
                  Raise_Application_Error(Errcode,
                                          '无法识别销帐包中待销帐标志');
                END IF;
                --复制到rdY
                IF Rdtaby IS NULL THEN
                  Rdtaby := Rd_Table(Rdy);
                ELSE
                  Rdtaby.Extend;
                  Rdtaby(Rdtaby.Last) := Rdy;
                END IF;
                --复制到rdN
                IF Rdtabn IS NULL THEN
                  Rdtabn := Rd_Table(Rdn);
                ELSE
                  Rdtabn.Extend;
                  Rdtabn(Rdtabn.Last) := Rdn;
                END IF;
              END LOOP;
              CLOSE c_Rd;
            END LOOP;
            --某一条应收帐发生部分销帐标志才拆分
            IF 待销笔数 != 0 THEN
              IF 不销笔数 != 0 THEN
                --应收调整1：在本期全额冲减
                Zwarreversecore(p_Parm_Ar.Arid,
                                Rl.Artrans,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                不提交,
                                o_Arid_Reverse,
                                o_Artrans_Reverse,
                                o_Arje_Reverse,
                                o_Arznj_Reverse,
                                o_Arsxf_Reverse,
                                o_Arsavingbq_Reverse,
                                Io_Arsavingqm_Reverse);
                --应收调整2.1：在本期追加目标应收（待销帐部分）
                Rly.Arid       := Lpad(Seq_Arid.Nextval, 10, '0');
                Rly.Armonth    := Fobtmanapara(Rly.Manage_No, 'READ_MONTH');
                Rly.Ardate     := Trunc(SYSDATE);
                Rly.Ardatetime := Currentdate;
                Rly.Arreadsl   := 0;
                FOR k IN Rdtaby.First .. Rdtaby.Last LOOP
                  SELECT Seq_Arid.Nextval INTO Rdtaby(k).Ardid FROM Dual;
                  Rdtaby(k).Ardid := Rly.Arid;
                END LOOP;
                INSERT INTO Ys_Zw_Arlist VALUES Rly;
                FOR k IN Rdtaby.First .. Rdtaby.Last LOOP
                  INSERT INTO Ys_Zw_Ardetail VALUES Rdtaby (k);
                END LOOP;
                --应收调整2.2：在本期追加目标应收（继续挂欠费部分）
                Rln.Arid       := Lpad(Seq_Arid.Nextval, 10, '0');
                Rln.Armonth    := Fobtmanapara(Rln.Manage_No, 'READ_MONTH');
                Rln.Ardate     := Trunc(SYSDATE);
                Rln.Ardatetime := Currentdate;
                FOR k IN Rdtabn.First .. Rdtabn.Last LOOP
                  SELECT Seq_Arid.Nextval INTO Rdtabn(k).Ardid FROM Dual;
                  Rdtabn(k).Ardid := Rln.Arid;
                END LOOP;
                INSERT INTO Ys_Zw_Arlist VALUES Rln;
                FOR k IN Rdtabn.First .. Rdtabn.Last LOOP
                  INSERT INTO Ys_Zw_Ardetail VALUES Rdtabn (k);
                END LOOP;
                --重构销帐包返回
                p_Parm_Ars(i).Arid := Rly.Arid;
                p_Parm_Ars(i).Ardpiids := REPLACE(p_Parm_Ars(i).Ardpiids,
                                                  'N',
                                                  'Y');
              END IF;
            ELSE
              --待销笔数=0
              p_Parm_Ars.Delete(i);
            END IF;
          END IF;
          CLOSE c_Rl;
        END IF;
      END LOOP;
    
    END IF;
    --5、提交处理
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
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Zwarreversecore(p_Arid_Source         IN VARCHAR2,
                            p_Artrans_Reverse     IN VARCHAR2,
                            p_Pbatch_Reverse      IN VARCHAR2,
                            p_Pid_Reverse         IN VARCHAR2,
                            p_Ppayment_Reverse    IN NUMBER,
                            p_Memo                IN VARCHAR2,
                            p_Ctl_Mircode         IN VARCHAR2,
                            p_Commit              IN NUMBER DEFAULT 不提交,
                            o_Arid_Reverse        OUT VARCHAR2,
                            o_Artrans_Reverse     OUT VARCHAR2,
                            o_Arje_Reverse        OUT NUMBER,
                            o_Arznj_Reverse       OUT NUMBER,
                            o_Arsxf_Reverse       OUT NUMBER,
                            o_Arsavingbq_Reverse  OUT NUMBER,
                            Io_Arsavingqm_Reverse IN OUT NUMBER) IS
    CURSOR c_Rl(Varid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Varid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_Rd(Varid VARCHAR2) IS
      SELECT *
        FROM Ys_Zw_Ardetail
       WHERE Ardid = Varid
       ORDER BY Ardpiid, Ardclass
         FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_p_Reverse(Vrpid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Paidment WHERE Pid = Vrpid FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    SUBTYPE Rd_Type IS Ys_Zw_Ardetail%ROWTYPE;
    TYPE Rd_Table IS TABLE OF Rd_Type;
    --被冲正原应收
    Rl_Source Ys_Zw_Arlist%ROWTYPE;
    Rd_Source Ys_Zw_Ardetail%ROWTYPE;
    --冲正应收
    Rl_Reverse     Ys_Zw_Arlist%ROWTYPE;
    Rd_Reverse     Ys_Zw_Ardetail%ROWTYPE;
    Rd_Reverse_Tab Rd_Table;
    --
    p_Reverse Ys_Zw_Paidment%ROWTYPE;
  BEGIN
    OPEN c_Rl(p_Arid_Source);
    FETCH c_Rl
      INTO Rl_Source;
    IF c_Rl%FOUND THEN
      --核心部分校验
      IF 允许重复销帐 = 0 AND Rl_Source.Aroutflag = 'Y' THEN
        Raise_Application_Error(Errcode,
                                '当前系统规则不允许划扣中进行应收冲正');
      END IF;
    
      Rl_Reverse                := Rl_Source;
      Rl_Reverse.Arid           := Lpad(Seq_Arid.Nextval, 10, '0');
      Rl_Reverse.Ardate         := Trunc(SYSDATE);
      Rl_Reverse.Ardatetime     := SYSDATE; --20140514 add
      Rl_Reverse.Armonth        := Fobtmanapara(Rl_Reverse.Manage_No,
                                                'READ_MONTH');
      Rl_Reverse.Arcd           := 贷方;
      Rl_Reverse.Arreadsl       := -Rl_Reverse.Arreadsl; --20140707 add
      Rl_Reverse.Arsl           := -Rl_Reverse.Arsl;
      Rl_Reverse.Arje           := -Rl_Reverse.Arje; --须全冲
      Rl_Reverse.Arznjreducflag := Rl_Reverse.Arznjreducflag;
      Rl_Reverse.Arznj          := -Rl_Reverse.Arznj; --若销帐则冲正原应收销帐违约金,未销则冲应收违约金
      Rl_Reverse.Arsxf          := -Rl_Reverse.Arsxf; --若销帐则冲正原应收销帐其他费1，,未销则冲应收其他费1
      Rl_Reverse.Arreverseflag  := 'Y';
      Rl_Reverse.Armemo         := p_Memo;
      Rl_Reverse.Artrans        := p_Artrans_Reverse;
      --应收冲正父过程调用下，销帐信息继承源帐
      --实收冲正父过程调用下，销帐信息改写，并判断实收冲正方法
      --退款：实收计‘实收冲销’事务C，应收计‘冲正’事务C
      --不退款：继承原实收、应收事务
      IF p_Pid_Reverse IS NOT NULL THEN
        OPEN c_p_Reverse(p_Pid_Reverse);
        FETCH c_p_Reverse
          INTO p_Reverse;
        IF c_p_Reverse%NOTFOUND OR c_p_Reverse%NOTFOUND IS NULL THEN
          Raise_Application_Error(Errcode, '冲正负帐不存在');
        END IF;
        CLOSE c_p_Reverse;
      
        Rl_Reverse.Arpaiddate  := Trunc(SYSDATE); --若销帐则记录冲正帐期
        Rl_Reverse.Arpaidmonth := Fobtmanapara(Rl_Reverse.Manage_No,
                                               'READ_MONTH'); --若销帐则记录冲正帐期
      
        Rl_Reverse.Arpaidje   := p_Ppayment_Reverse; --销帐信息改写
        Rl_Reverse.Arsavingqc := (CASE
                                   WHEN Io_Arsavingqm_Reverse IS NULL THEN
                                    p_Reverse.Pdsavingqc
                                   ELSE
                                    Io_Arsavingqm_Reverse
                                 END); --销帐信息初改写
        Rl_Reverse.Arsavingbq := Rl_Reverse.Arpaidje - Rl_Reverse.Arje -
                                 Rl_Reverse.Arznj - Rl_Reverse.Arsxf; --销帐信息改写
        Rl_Reverse.Arsavingqm := Rl_Reverse.Arsavingqc +
                                 Rl_Reverse.Arsavingbq; --销帐信息改写
        Rl_Reverse.Arpid      := p_Pid_Reverse;
        Rl_Reverse.Arpbatch   := p_Pbatch_Reverse;
        Io_Arsavingqm_Reverse := Rl_Reverse.Arsavingqm;
      END IF;
      --rlscrrlid    := ;--继承原应收值
      --rlscrrldate  := ;--继承原应收值
      --rlscrrlmonth := ;--继承原应收值
      --rlscrrllb    := ;--继承原应收值
      OPEN c_Rd(p_Arid_Source);
      LOOP
        FETCH c_Rd
          INTO Rd_Source;
        EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
        Rd_Reverse := Rd_Source;
        SELECT Seq_Arid.Nextval INTO Rd_Reverse.Ardid FROM Dual;
        Rd_Reverse.Ardid    := Rl_Reverse.Arid;
        Rd_Reverse.Ardyssl  := -Rd_Reverse.Ardyssl;
        Rd_Reverse.Ardysje  := -Rd_Reverse.Ardysje;
        Rd_Reverse.Ardsl    := -Rd_Reverse.Ardsl;
        Rd_Reverse.Ardje    := -Rd_Reverse.Ardje;
        Rd_Reverse.Ardadjsl := -Rd_Reverse.Ardadjsl;
        Rd_Reverse.Ardadjje := -Rd_Reverse.Ardadjje;
        --复制到rd_reverse_tab
        IF Rd_Reverse_Tab IS NULL THEN
          Rd_Reverse_Tab := Rd_Table(Rd_Reverse);
        ELSE
          Rd_Reverse_Tab.Extend;
          Rd_Reverse_Tab(Rd_Reverse_Tab.Last) := Rd_Reverse;
        END IF;
      END LOOP;
      CLOSE c_Rd;
    ELSE
      Raise_Application_Error(Errcode, '无效的应收流水号');
    END IF;
    --返回值
    o_Arid_Reverse       := Rl_Reverse.Arid;
    o_Artrans_Reverse    := Rl_Reverse.Artrans;
    o_Arje_Reverse       := Rl_Reverse.Arje;
    o_Arznj_Reverse      := Rl_Reverse.Arznj;
    o_Arsxf_Reverse      := Rl_Reverse.Arsxf;
    o_Arsavingbq_Reverse := Rl_Reverse.Arsavingbq;
    --2、提交处理
    BEGIN
      CLOSE c_Rl;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        INSERT INTO Ys_Zw_Arlist VALUES Rl_Reverse;
        FOR k IN Rd_Reverse_Tab.First .. Rd_Reverse_Tab.Last LOOP
          INSERT INTO Ys_Zw_Ardetail VALUES Rd_Reverse_Tab (k);
        END LOOP;
        UPDATE Ys_Zw_Arlist
           SET Arreverseflag = 'Y'
         WHERE Arid = p_Arid_Source;
        --其他控制赋值
        IF p_Ctl_Mircode IS NOT NULL THEN
          UPDATE Ys_Yh_Sbinfo
             SET Sbrcode = To_Number(p_Ctl_Mircode)
           WHERE Sbid = Rl_Source.Sbid;
        END IF;
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
      IF c_p_Reverse%ISOPEN THEN
        CLOSE c_p_Reverse;
      END IF;
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Paywyjpre(p_Parm_Ars IN OUT Parm_Payar_Tab,
                      p_Commit   IN NUMBER DEFAULT 不提交) IS
    CURSOR c_Rl(Varid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Varid;
    CURSOR c_Rd(Varid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Ardetail WHERE Ardid = Varid;
    p_Parm_Ar  Parm_Payar := Parm_Payar(NULL, NULL, NULL, NULL, NULL, NULL);
    v_Parm_Ars Parm_Payar_Tab := Parm_Payar_Tab();
    --被调整原应收
    Rl                 Ys_Zw_Arlist%ROWTYPE;
    Rd                 Ys_Zw_Ardetail%ROWTYPE;
    Vexist             NUMBER := 0;
    一行费项数         INTEGER;
    一行一费项         VARCHAR2(10);
    一行一费项待销标志 CHAR(1);
  BEGIN
    --可以为空（预存充值时），空包返回
    IF p_Parm_Ars.Count > 0 THEN
      FOR i IN p_Parm_Ars.First .. p_Parm_Ars.Last LOOP
        p_Parm_Ar := p_Parm_Ars(i);
        IF p_Parm_Ar.Arwyj <> 0 AND p_Parm_Ar.Arid IS NOT NULL THEN
          OPEN c_Rl(p_Parm_Ar.Arid);
          FETCH c_Rl
            INTO Rl;
          IF c_Rl%NOTFOUND OR c_Rl%NOTFOUND IS NULL THEN
            Raise_Application_Error(Errcode,
                                    '销帐包中应收流水不存在' || p_Parm_Ar.Arid);
          END IF;
          一行费项数 := Pg_Cb_Cost.Fboundpara(p_Parm_Ar.Ardpiids);
          FOR j IN 1 .. 一行费项数 LOOP
            一行一费项待销标志 := Pg_Cb_Cost.Fgetpara(p_Parm_Ar.Ardpiids, j, 1);
            一行一费项         := Pg_Cb_Cost.Fgetpara(p_Parm_Ar.Ardpiids, j, 2);
            IF 一行一费项待销标志 = 'N' AND Upper(一行一费项) = 'ZNJ' THEN
              Vexist := 1;
            END IF;
          END LOOP;
          IF Vexist = 1 THEN
            Rl.Arid           := Lpad(Seq_Arid.Nextval, 10, '0');
            Rl.Arje           := 0;
            Rl.Arsl           := 0;
            Rl.Arznj          := p_Parm_Ar.Arwyj;
            Rl.Armemo         := '违约金追补';
            Rl.Arznjreducflag := 'Y';
            OPEN c_Rd(p_Parm_Ar.Arid);
            LOOP
              FETCH c_Rd
                INTO Rd;
              EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
              Rd.Ardid    := Rl.Arid;
              Rd.Ardsl    := 0;
              Rd.Ardje    := 0;
              Rd.Ardyssl  := 0;
              Rd.Ardysje  := 0;
              Rd.Ardadjsl := 0;
              Rd.Ardadjje := 0;
              INSERT INTO Ys_Zw_Ardetail VALUES Rd;
            END LOOP;
            INSERT INTO Ys_Zw_Arlist VALUES Rl;
            CLOSE c_Rd;
            --
            p_Parm_Ar.Arid := Rl.Arid;
            IF v_Parm_Ars IS NULL THEN
              v_Parm_Ars := Parm_Payar_Tab(p_Parm_Ar);
            ELSE
              v_Parm_Ars.Extend;
              v_Parm_Ars(v_Parm_Ars.Last) := p_Parm_Ar;
            END IF;
            --
            p_Parm_Ars(i).Arwyj := 0;
          END IF;
          CLOSE c_Rl;
        END IF;
      END LOOP;
    END IF;
    --5、提交处理
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
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Payzwarcore(p_Pid          IN VARCHAR2,
                        p_Batch        IN VARCHAR2,
                        p_Payment      IN NUMBER,
                        p_Remainbefore IN NUMBER,
                        p_Paiddate     IN DATE,
                        p_Paidmonth    IN VARCHAR2,
                        p_Parm_Ars     IN Parm_Payar_Tab,
                        p_Commit       IN NUMBER DEFAULT 不提交,
                        o_Sum_Arje     OUT NUMBER,
                        o_Sum_Arznj    OUT NUMBER,
                        o_Sum_Arsxf    OUT NUMBER) IS
    CURSOR c_Rl(Varid VARCHAR2) IS
      SELECT *
        FROM Ys_Zw_Arlist
       WHERE Arid = Varid
         AND Arpaidflag = 'N'
         AND Arreverseflag = 'N' /*and rlje>0*/ /*支持0金额销帐*/
         FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    Rl          Ys_Zw_Arlist%ROWTYPE;
    p_Parm_Ar   Parm_Payar;
    Sumrlpaidje NUMBER(13, 3) := 0; --累计实收金额（应收金额+实收违约金+实收其他非系统费项123）
    p_Remaind   NUMBER(13, 3); --期初预存累减器
  BEGIN
    --期初预存累减器初始化
    p_Remaind := p_Remainbefore;
    --返回值初始化，若销帐包非空但无游标此值返回
    o_Sum_Arje  := 0;
    o_Sum_Arznj := 0;
    o_Sum_Arsxf := 0;
    SAVEPOINT 未销状态;
    IF p_Parm_Ars.Count > 0 THEN
      --可以为空（预存充值时）
      FOR i IN p_Parm_Ars.First .. p_Parm_Ars.Last LOOP
        p_Parm_Ar := p_Parm_Ars(i);
        OPEN c_Rl(p_Parm_Ar.Arid);
        --销帐包非空时，也允许包含不符合销帐条件的应收id，例如代扣隔日销帐本地已销情况下
        FETCH c_Rl
          INTO Rl;
        IF c_Rl%FOUND THEN
          --组织一条待销应收记录更新变量
          Rl.Arpaidflag  := 'Y'; --varchar2(1)  y  'n'    是否销账标志（全额销帐、不存在中间状态）
          Rl.Arsavingqc  := p_Remaind; --number(13,2)  y  0    销帐期初预存
          Rl.Arsavingbq  := -Pg_Cb_Cost.Getmin(p_Remaind,
                                               Rl.Arje + p_Parm_Ar.Arwyj +
                                               p_Parm_Ar.Fee1); --number(13,2)  y  0    销帐预存发生（净减）
          Rl.Arsavingqm  := Rl.Arsavingqc + Rl.Arsavingbq; --number(13,2)  y  0    销帐期末预存
          Rl.Arznj       := p_Parm_Ar.Arwyj; --number(13,2)  y  0    实收违约金
          Rl.Arsxf       := p_Parm_Ar.Fee1; --number(13,2)  y  0    实收其他非系统费项1
          Rl.Arpaiddate  := p_Paiddate; --date  y      销帐日期（实收帐务时钟）
          Rl.Arpaidmonth := p_Paidmonth; --varchar2(7)  y      销帐月份（实收帐务时钟）
          Rl.Arpaidje    := Rl.Arje + Rl.Arznj + Rl.Arsxf + Rl.Arsavingbq; --number(13,2)  y  0    实收金额（实收金额=应收金额+实收违约金+实收其他非系统费项123+预存发生）；sum(rl.rlpaidje)=p.ppayment
          Rl.Arpid       := p_Pid; --
          Rl.Arpbatch    := p_Batch;
          Rl.Armicolumn1 := '';
          --中间变量运算
          Sumrlpaidje := Sumrlpaidje + Rl.Arpaidje;
          --末条销帐记录处理，销帐溢出的实收金额计入末笔销帐记录的预存发生中！！！
          IF i = p_Parm_Ars.Last THEN
            Rl.Arsavingbq := Rl.Arsavingbq + (p_Payment - Sumrlpaidje);
            Rl.Arsavingqm := Rl.Arsavingqc + Rl.Arsavingbq;
            Rl.Arpaidje   := Rl.Arje + Rl.Arznj + Rl.Arsxf + Rl.Arsavingbq; --number(13,2)  y  0    实收金额（实收金额=应收金额+实收违约金+实收其他非系统费项123+预存发生）；sum(rl.rlpaidje)=p.ppayment
          END IF;
          --核心部分校验
          IF NOT 允许预存发生 AND Rl.Arsavingbq != 0 THEN
            Raise_Application_Error(Errcode,
                                    '当前系统规则为不支持预存发生');
          END IF;
          --反馈实收记录
          o_Sum_Arje  := o_Sum_Arje + Rl.Arje;
          o_Sum_Arznj := o_Sum_Arznj + Rl.Arznj;
          o_Sum_Arsxf := o_Sum_Arsxf + Rl.Arsxf;
          p_Remaind   := p_Remaind + Rl.Arsavingbq;
          --更新待销帐应收记录
          UPDATE Ys_Zw_Arlist
             SET Arpaidflag  = Rl.Arpaidflag,
                 Arsavingqc  = Rl.Arsavingqc,
                 Arsavingbq  = Rl.Arsavingbq,
                 Arsavingqm  = Rl.Arsavingqm,
                 Arznj       = Rl.Arznj,
                 Armicolumn1 = Rl.Armicolumn1,
                 Arsxf       = Rl.Arsxf,
                 Arpaiddate  = Rl.Arpaiddate,
                 Arpaidmonth = Rl.Arpaidmonth,
                 Arpaidje    = Rl.Arpaidje,
                 Arpid       = Rl.Arpid,
                 Arpbatch    = Rl.Arpbatch,
                 Aroutflag   = 'N'
           WHERE Arid = Rl.Arid; --current of c_rl;效率低
        ELSE
          o_Sum_Arsxf := o_Sum_Arsxf + p_Parm_Ar.Fee1;
        END IF;
        CLOSE c_Rl;
      END LOOP;
    END IF;
  
    --核心部分校验
    IF 净减为负预存不销帐 AND p_Remaind < 0 AND p_Remaind < p_Remainbefore THEN
      o_Sum_Arje  := 0;
      o_Sum_Arznj := 0;
      o_Sum_Arsxf := 0;
      ROLLBACK TO 未销状态;
    END IF;
  
    --核心部分校验
    IF NOT 允许净减后负预存 AND p_Remaind < 0 AND p_Remaind < p_Remainbefore THEN
      Raise_Application_Error(Errcode,
                              '当前系统规则为不支持发生更多期末负预存');
    END IF;
  
    --5、提交处理
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
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  /*==========================================================================
  预存充值（一表）
  【输入参数说明】：
  【输出参数说明】：
  【过程说明】：
  【更新日志】：
  */
  PROCEDURE Precust(p_Sbid        IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Memo        IN VARCHAR2,
                    p_Batch       IN OUT VARCHAR2,
                    o_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER) IS
  
    p_Seqno VARCHAR2(10);
  BEGIN
    --校验
    IF p_Payment <= 0 THEN
      Raise_Application_Error(Errcode, '预存充值业务金额必须为正数哦');
    END IF;
    --调用核心
    Precore(p_Sbid,
            Ptrans_独立预存,
            p_Position,
            NULL,
            NULL,
            NULL,
            p_Oper,
            p_Payway,
            p_Payment,
            不提交,
            p_Memo,
            p_Batch,
            p_Seqno,
            o_Pid,
            o_Remainafter);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  /*==========================================================================
  预存退费（一表）
  【输入参数说明】：
  【输出参数说明】：
  【过程说明】：
  【更新日志】：
  */
  PROCEDURE Precustback(p_Sbid        IN VARCHAR2,
                        p_Position    IN VARCHAR2,
                        p_Oper        IN VARCHAR2,
                        p_Payway      IN VARCHAR2,
                        p_Payment     IN NUMBER,
                        p_Memo        IN VARCHAR2,
                        p_Batch       IN OUT VARCHAR2,
                        o_Pid         OUT VARCHAR2,
                        o_Remainafter OUT NUMBER) IS
  
    p_Seqno VARCHAR2(10);
  BEGIN
    --校验
    IF p_Payment >= 0 THEN
      Raise_Application_Error(Errcode, '预存充值业务金额必须为负数哦');
    END IF;
    --调用核心
    Precore(p_Sbid,
            Ptrans_独立预存,
            p_Position,
            NULL,
            NULL,
            NULL,
            p_Oper,
            p_Payway,
            p_Payment,
            不提交,
            p_Memo,
            p_Batch,
            p_Seqno,
            o_Pid,
            o_Remainafter);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Precore(p_Sbid        IN VARCHAR2,
                    p_Trans       IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Paypoint    IN VARCHAR2,
                    p_Bdate       IN DATE,
                    p_Bseqno      IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Commit      IN NUMBER,
                    p_Memo        IN VARCHAR2,
                    p_Batch       IN OUT VARCHAR2,
                    p_Seqno       IN OUT VARCHAR2,
                    o_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER) IS
    CURSOR c_Ci(Vciid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vciid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    Mi Ys_Yh_Sbinfo%ROWTYPE;
    Ci Ys_Yh_Custinfo%ROWTYPE;
    p  Ys_Zw_Paidment%ROWTYPE;
  BEGIN
    IF NOT 允许预存发生 THEN
      Raise_Application_Error(Errcode, '当前系统规则为不支持预存发生');
    END IF;
    --1、校验及其初始化
    BEGIN
      --取水表信息
      OPEN c_Mi(p_Sbid);
      FETCH c_Mi
        INTO Mi;
      IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode, '这是传的水表编码？' || p_Sbid);
      END IF;
      --取用户信息
      OPEN c_Ci(Mi.Yhid);
      FETCH c_Ci
        INTO Ci;
      IF c_Ci%NOTFOUND OR c_Ci%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                '这个水表编码没对应用户！' || p_Sbid);
      END IF;
    END;
  
    --2、记录实收
    BEGIN
      SELECT TRIM(To_Char(Seq_Paidment.Nextval, '0000000000'))
        INTO o_Pid
        FROM Dual;
      SELECT Sys_Guid() INTO p.Id FROM Dual;
      p.Hire_Code    := Mi.Hire_Code;
      p.Pid          := o_Pid;
      p.Yhid         := Ci.Yhid;
      p.Sbid         := Mi.Sbid;
      p.Pdrcreceived := p_Payment;
      p.Pddate       := Trunc(SYSDATE);
      p.Pdatetime    := SYSDATE;
      p.Pdmonth      := Fobtmanapara(Mi.Manage_No, 'READ_MONTH');
      p.Manage_No    := p_Position;
      p.Pdpaypoint   := p_Paypoint;
      p.Pdtran       := p_Trans;
      p.Pdpers       := p_Oper;
      p.Pdpayee      := p_Oper;
      p.Pdpayway     := p_Payway;
      p.Paidment     := p_Payment;
      p.Pdspje       := 0;
      p.Pdwyj        := 0;
      p.Pdsavingqc   := Nvl(Mi.Sbsaving, 0);
      p.Pdsavingbq   := p_Payment;
      p.Pdsavingqm   := p.Pdsavingqc + p.Pdsavingbq;
      p.Pdsxf        := 0; --若为独立押金;
      p.Preverseflag := 'N'; --帐务状态（收水费收预存是为N,冲水费冲预存被冲实收和冲实收产生负帐匀为Y）
      p.Pdbdate      := Trunc(p_Bdate);
      p.Pdbseqno     := p_Bseqno;
      p.Pdchkdate    := NULL;
      p.Pdcchkflag   := NULL;
      p.Pdcdate      := NULL;
      p.Pdcseqno     := NULL;
      p.Pdmemo       := p_Memo;
      IF p_Batch IS NULL THEN
        SELECT TRIM(To_Char(Seq_Paidbatch.Nextval, '0000000000'))
          INTO p.Pdbatch
          FROM Dual;
      ELSE
        p.Pdbatch := p_Batch;
      END IF;
      p.Pdseqno    := p_Seqno;
      p.Pdscrid    := p.Pid;
      p.Pdscrtrans := p.Pdtran;
      p.Pdscrmonth := p.Pdmonth;
      p.Pdscrdate  := p.Pddate;
    END;
    p.Pdchkno     := NULL; --varchar2(10)  y    进账单号
    p.Pdpriid     := Mi.Sbpriid; --varchar2(20)  y    合收主表号  20150105
    p.Tchkdate    := NULL; --date  y    到账日期
    o_Remainafter := p.Pdsavingqm;
  
    --校验
    IF NOT 允许净减后负预存 AND p.Pdsavingqm < 0 AND p.Pdsavingqm < p.Pdsavingqc THEN
      Raise_Application_Error(Errcode,
                              '当前系统规则为不支持发生更多的期末负预存');
    END IF;
    INSERT INTO Ys_Zw_Paidment VALUES p;
    UPDATE Ys_Yh_Sbinfo SET Sbsaving = p.Pdsavingqm WHERE CURRENT OF c_Mi;
  
    --5、提交处理
    BEGIN
      CLOSE c_Ci;
      CLOSE c_Mi;
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
      IF c_Ci%ISOPEN THEN
        CLOSE c_Ci;
      END IF;
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  --
  FUNCTION Fmid(p_Str IN VARCHAR2, p_Sep IN VARCHAR2) RETURN INTEGER IS
    --help:
    --tools.fmidn('/123/123/123/','/')=5
    --tools.fmidn(null,'/')=0
    --tools.fmidn('','/')=0
    --tools.fmidn('null','/')=1
    i INTEGER;
    n INTEGER := 1;
  BEGIN
    IF TRIM(p_Str) IS NULL THEN
      RETURN 0;
    ELSE
      FOR i IN 1 .. Length(p_Str) LOOP
        IF Substr(p_Str, i, 1) = p_Sep THEN
          n := n + 1;
        END IF;
      END LOOP;
    END IF;
  
    RETURN n;
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
      p_Reverse.Pid        := o_Pid_Reverse;
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
      Dbms_Output.Put_Line(SQLERRM);
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
  --   2020-11-12   杨华        制作
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
  --   2020-11-12   杨华        制作
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
  --   2020-11-12   杨华        制作
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
                        '0',
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
  --   2020-11-12   杨华        制作
  --
  */
  PROCEDURE Posreverse(p_Pid_Source  IN VARCHAR2,
                       p_Oper        IN VARCHAR2,
                       p_Memo        IN VARCHAR2,
                       p_Commit      IN NUMBER DEFAULT 不提交,
                       p_Pid_Reverse OUT VARCHAR2) IS
    p                Ys_Zw_Paidment%ROWTYPE;
    Vppaymentreverse NUMBER(12, 2);
    Vappendrlid      VARCHAR2(10);
  BEGIN
    SELECT * INTO p FROM Ys_Zw_Paidment WHERE Pid = p_Pid_Source;
    --校验
    IF NOT (p.Preverseflag = 'N' AND p.Paidment >= 0) THEN
      Raise_Application_Error(Errcode,
                              '待冲正实收记录无效，必须为未冲正的正常缴费');
    END IF;
    Payreverse(p_Pid_Source,
               p.Manage_No,
               p.Pdpaypoint,
               p.Pdtran,
               NULL,
               NULL,
               p_Oper,
               p.Pdpayway,
               p_Memo,
               不提交,
               p_Pid_Reverse,
               Vppaymentreverse,
               Vappendrlid);
  
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
      Raise_Application_Error(Errcode,
                              '是否提交参数不正确' || p_Pid_Source);
      RAISE;
      --raise_application_error(errcode, sqlerrm);
  END Posreverse;

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
  --   2020-11-12   杨华        制作
  --
  */
  PROCEDURE Recappendadj(p_Rlmid           IN VARCHAR2,
                         p_Rlcname         IN VARCHAR2,
                         p_Rlpfid          IN VARCHAR2,
                         p_Rlrdate         IN DATE,
                         p_Rlscode         IN NUMBER,
                         p_Rlecode         IN NUMBER,
                         p_Rlsl            IN NUMBER,
                         p_Rlje            IN NUMBER,
                         p_Rlznj           IN NUMBER,
                         p_Rltrans         IN VARCHAR2,
                         p_Rlmemo          IN VARCHAR2,
                         p_Rlid_Source     IN VARCHAR2,
                         p_Parm_Append1rds Parm_Append1rd_Tab,
                         p_Ctl_Mircode     IN VARCHAR2,
                         p_Commit          IN NUMBER DEFAULT 不提交,
                         o_Rlid            OUT VARCHAR2) IS
    CURSOR c_Rl(Vrlid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Vrlid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    Rl_Source Ys_Zw_Arlist%ROWTYPE;
  BEGIN
    --退费正帐应收事务继承原帐务
    OPEN c_Rl(p_Rlid_Source);
    FETCH c_Rl
      INTO Rl_Source;
    IF c_Rl%NOTFOUND OR c_Rl%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '无原帐务应收记录');
    END IF;
    CLOSE c_Rl;
  
    Recappendcore(p_Rlmid,
                  p_Rlcname,
                  p_Rlpfid,
                  p_Rlrdate,
                  p_Rlscode,
                  p_Rlecode,
                  p_Rlsl,
                  p_Rlje,
                  Rl_Source.Arznjreducflag,
                  Rl_Source.Arzndate,
                  p_Rlznj,
                  p_Rltrans,
                  p_Rlmemo,
                  p_Rlid_Source,
                  p_Parm_Append1rds,
                  p_Ctl_Mircode,
                  不提交,
                  o_Rlid);
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
  END Recappendadj;
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
  --   2020-12-12   杨华        制作
  --
  */
  PROCEDURE Recadjust(p_Rlmid           IN VARCHAR2,
                      p_Rlcname         IN VARCHAR2,
                      p_Rlpfid          IN VARCHAR2,
                      p_Rlrdate         IN DATE,
                      p_Rlscode         IN NUMBER,
                      p_Rlecode         IN NUMBER,
                      p_Rlsl            IN NUMBER,
                      p_Rlje            IN NUMBER,
                      p_Rlznj           IN NUMBER,
                      p_Rltrans         IN VARCHAR2,
                      p_Rlmemo          IN VARCHAR2,
                      p_Rlid_Source     IN VARCHAR2,
                      p_Parm_Append1rds Parm_Append1rd_Tab,
                      p_Commit          IN NUMBER DEFAULT 不提交,
                      p_Ctl_Mircode     IN VARCHAR2,
                      o_Rlid_Reverse    OUT VARCHAR2,
                      o_Rlid            OUT VARCHAR2) IS
    --
    o_Rltrans_Reverse     VARCHAR2(10);
    o_Rlje_Reverse        NUMBER;
    o_Rlznj_Reverse       NUMBER;
    o_Rlsxf_Reverse       NUMBER;
    o_Rlsavingbq_Reverse  NUMBER;
    Io_Rlsavingqm_Reverse NUMBER;
  BEGIN
    Zwarreversecore(p_Rlid_Source,
                    p_Rltrans,
                    NULL,
                    NULL, --应收调整无关联实收记录p_pid_reverse
                    NULL, --应收调整无关联实收记录
                    p_Rlmemo,
                    NULL, --此过程不重置止码，让追补核心处理
                    p_Commit,
                    o_Rlid_Reverse,
                    o_Rltrans_Reverse,
                    o_Rlje_Reverse,
                    o_Rlznj_Reverse,
                    o_Rlsxf_Reverse,
                    o_Rlsavingbq_Reverse,
                    Io_Rlsavingqm_Reverse);
    IF NOT (p_Rlsl = 0 AND p_Rlje = 0 AND p_Rlznj = 0) THEN
      Recappendadj(p_Rlmid,
                   p_Rlcname,
                   p_Rlpfid,
                   p_Rlrdate,
                   p_Rlscode,
                   p_Rlecode,
                   p_Rlsl,
                   p_Rlje,
                   p_Rlznj,
                   o_Rltrans_Reverse,
                   p_Rlmemo,
                   p_Rlid_Source,
                   p_Parm_Append1rds,
                   p_Ctl_Mircode,
                   p_Commit,
                   o_Rlid);
    ELSE
      --其他控制赋值
      IF p_Ctl_Mircode IS NOT NULL THEN
        UPDATE Ys_Yh_Sbinfo
           SET Sbrcode     = To_Number(p_Ctl_Mircode),
               Sbrcodechar = p_Ctl_Mircode
         WHERE Sbid = p_Rlmid;
      END IF;
    
    END IF;
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
      /*pg_ewide_interface.ErrLog(dbms_utility.format_call_stack(),
      'RecAdjust,p_rlmid:' || p_rlmid);*/
      --raise;
      Raise_Application_Error(Errcode, SQLERRM);
  END Recadjust;
  /*==========================================================================
  预存转账
  【输入参数说明】：
  【输出参数说明】：
  【过程说明】：
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2020-11-12   杨华        制作
  --
  */
  PROCEDURE Remainc2c(p_Mid_Out IN VARCHAR2,
                      p_Mid_In  IN VARCHAR2,
                      p_Oper    IN VARCHAR2,
                      p_Ptrans  IN VARCHAR2,
                      p_Payment IN NUMBER,
                      p_Memo    IN VARCHAR2,
                      p_Commit  IN NUMBER DEFAULT 不提交,
                      p_Batch   IN OUT VARCHAR2) IS
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT Manage_No, Yhid FROM Ys_Yh_Sbinfo WHERE Yhid = Vmiid;
  
    p_Seqno        VARCHAR2(10);
    o_Pid          VARCHAR2(10);
    o_Remainafter  NUMBER;
    p_Position_Out VARCHAR2(10);
    p_Position_In  VARCHAR2(10);
    p_Cid_Out      VARCHAR2(20);
    p_Cid_In       VARCHAR2(20);
  BEGIN
    --校验
    /*    if p_payment <= 0 then
          raise_application_error(errcode, '预存转账业务金额必须为正数哦');
        end if;
    */
    OPEN c_Mi(p_Mid_Out);
    FETCH c_Mi
      INTO p_Position_Out, p_Cid_Out;
    IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '这是传的水表编码？' || p_Mid_Out);
    END IF;
    CLOSE c_Mi;
    IF p_Mid_In IS NOT NULL THEN
      OPEN c_Mi(p_Mid_In);
      FETCH c_Mi
        INTO p_Position_In, p_Cid_In;
      IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode, '这是传的水表编码？' || p_Mid_In);
      END IF;
      CLOSE c_Mi;
    
      --校验
      IF p_Cid_In = p_Cid_Out THEN
        Raise_Application_Error(Errcode,
                                '预存转账业务不能在一户多表内进行！');
      END IF;
    END IF;
  
    --调用核心
    Precore(p_Mid_Out,
            p_Ptrans,
            p_Position_Out,
            NULL,
            NULL,
            NULL,
            p_Oper,
            '01',
            p_Payment,
            不提交,
            p_Memo,
            p_Batch,
            p_Seqno,
            o_Pid,
            o_Remainafter);
    --调用核心
    IF p_Mid_In IS NOT NULL THEN
      Precore(p_Mid_In,
              p_Ptrans,
              p_Position_In,
              NULL,
              NULL,
              NULL,
              p_Oper,
              '01',
              -p_Payment,
              不提交,
              p_Memo,
              p_Batch,
              p_Seqno,
              o_Pid,
              o_Remainafter);
    END IF;
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
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Remainc2c;

BEGIN
  NULL;

END;
/

