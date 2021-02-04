CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_DSZBILL_01" IS

  PROCEDURE CREATEHD(P_DSHNO     IN VARCHAR2, --单据流水号
                     P_DSHLB     IN VARCHAR2, --单据类别
                     P_DSHSMFID  IN VARCHAR2, --营销公司
                     P_DSHDEPT   IN VARCHAR2, --受理部门
                     P_DSHCREPER IN VARCHAR2 --受理人员
                     ) IS
    DBH DSZBILLHD%ROWTYPE;
  BEGIN
    --赋值 单头
    DBH.DBHNO      := P_DSHNO; --单据流水号
    DBH.DBHBH      := P_DSHNO; --单据编号
    DBH.DBHLB      := P_DSHLB; --单据类别
    DBH.DBHSOURCE  := '1'; --单据来源
    DBH.DBHSMFID   := P_DSHSMFID; --营销公司
    DBH.DBHDEPT    := P_DSHDEPT; --受理部门
    DBH.DBHCREDATE := SYSDATE; --受理日期
    DBH.DBHCREPER  := P_DSHCREPER; --受理人员
    DBH.DBHSHDATE  := NULL; --审核日期
    DBH.DBHSHPER   := NULL; --审核人员
    DBH.DBHSHFLAG  := 'N'; --审核标志
    INSERT INTO DSZBILLHD VALUES DBH;

  END CREATEHD;

  PROCEDURE CREATEDT(P_DSDNO    IN VARCHAR2, --单据流水号
                     P_DSDROWNO IN VARCHAR2, --行号
                     P_RLID     IN VARCHAR2 --应收流水
                     ) IS
    DBT DSZBILLDT%ROWTYPE;
    RL  RECLIST%ROWTYPE;
  BEGIN
    --查询账务信息
    SELECT * INTO RL FROM RECLIST WHERE RLID = P_RLID;
    --赋值 单体
    DBT.DBDNO           := P_DSDNO; --单据流水号
    DBT.DBDROWNO        := P_DSDROWNO; --行号
    DBT.RLID            := RL.RLID; --流水号
    DBT.RLSMFID         := RL.RLSMFID; --营销公司
    DBT.RLMONTH         := RL.RLMONTH; --帐务月份
    DBT.RLDATE          := RL.RLDATE; --帐务日期
    DBT.RLCID           := RL.RLCID; --用户编号
    DBT.RLMID           := RL.RLMID; --水表编号
    DBT.RLMSMFID        := RL.RLMSMFID; --水表公司
    DBT.RLCSMFID        := RL.RLCSMFID; --用户公司
    DBT.RLCCODE         := RL.RLCCODE; --资料号
    DBT.RLCHARGEPER     := RL.RLCHARGEPER; --收费员
    DBT.RLCPID          := RL.RLCPID; --上级用户编号
    DBT.RLCCLASS        := RL.RLCCLASS; --用户级次
    DBT.RLCFLAG         := RL.RLCFLAG; --末级标志
    DBT.RLUSENUM        := RL.RLUSENUM; --户用水人数
    DBT.RLCNAME         := RL.RLCNAME; --用户名称
    DBT.RLCADR          := RL.RLCADR; --用户地址
    DBT.RLMADR          := RL.RLMADR; --水表地址
    DBT.RLCSTATUS       := RL.RLCSTATUS; --用户状态
    DBT.RLMTEL          := RL.RLMTEL; --移动电话
    DBT.RLTEL           := RL.RLTEL; --固定电话
    DBT.RLBANKID        := RL.RLBANKID; --代扣银行
    DBT.RLTSBANKID      := RL.RLTSBANKID; --托收银行
    DBT.RLACCOUNTNO     := RL.RLACCOUNTNO; --开户帐号
    DBT.RLACCOUNTNAME   := RL.RLACCOUNTNAME; --开户名称
    DBT.RLIFTAX         := RL.RLIFTAX; --是否税票
    DBT.RLTAXNO         := RL.RLTAXNO; --增殖税号
    DBT.RLIFINV         := RL.RLIFINV; --是否普票
    DBT.RLMCODE         := RL.RLMCODE; --水表手工编号
    DBT.RLMPID          := RL.RLMPID; --上级水表
    DBT.RLMCLASS        := RL.RLMCLASS; --水表级次
    DBT.RLMFLAG         := RL.RLMFLAG; --末级标志
    DBT.RLMSFID         := RL.RLMSFID; --水表类别
    DBT.RLDAY           := RL.RLDAY; --抄表日
    DBT.RLBFID          := RL.RLBFID; --表册
    DBT.RLPRDATE        := RL.RLPRDATE; --上次抄表日期
    DBT.RLRDATE         := RL.RLRDATE; --本次抄表日期
    DBT.RLZNDATE        := RL.RLZNDATE; --违约金起算日
    DBT.RLCALIBER       := RL.RLCALIBER; --表口径
    DBT.RLRTID          := RL.RLRTID; --抄表方式
    DBT.RLMSTATUS       := RL.RLMSTATUS; --状态
    DBT.RLMTYPE         := RL.RLMTYPE; --类型
    DBT.RLMNO           := RL.RLMNO; --表身码
    DBT.RLSCODE         := RL.RLSCODE; --起数
    DBT.RLECODE         := RL.RLECODE; --止数
    DBT.RLREADSL        := RL.RLREADSL; --抄见水量
    DBT.RLINVMEMO       := RL.RLINVMEMO; --发票备注
    DBT.RLENTRUSTBATCH  := RL.RLENTRUSTBATCH; --托收代扣批号
    DBT.RLENTRUSTSEQNO  := RL.RLENTRUSTSEQNO; --托收代扣流水号
    DBT.RLOUTFLAG       := RL.RLOUTFLAG; --发出标志
    DBT.RLTRANS         := RL.RLTRANS; --应收事务
    DBT.RLCD            := RL.RLCD; --借贷方向
    DBT.RLYSCHARGETYPE  := RL.RLYSCHARGETYPE; --应收方式
    DBT.RLSL            := RL.RLSL; --应收水量
    DBT.RLJE            := RL.RLJE; --应收金额
    DBT.RLADDSL         := RL.RLADDSL; --加调水量
    DBT.RLSCRRLID       := RL.RLSCRRLID; --原应收帐流水
    DBT.RLSCRRLTRANS    := RL.RLSCRRLTRANS; --原应收帐事务
    DBT.RLSCRRLMONTH    := RL.RLSCRRLMONTH; --原应收帐月份
    DBT.RLPAIDJE        := RL.RLPAIDJE; --销帐金额
    DBT.RLPAIDFLAG      := RL.RLPAIDFLAG; --销帐标志(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
    DBT.RLPAIDPER       := RL.RLPAIDPER; --销帐人员
    DBT.RLPAIDDATE      := RL.RLPAIDDATE; --销帐日期
    DBT.RLMRID          := RL.RLMRID; --抄表流水
    DBT.RLMEMO          := RL.RLMEMO; --备注
    DBT.RLZNJ           := RL.RLZNJ; --违约金
    DBT.RLLB            := RL.RLLB; --类别
    DBT.RLCNAME2        := RL.RLCNAME2; --曾用名
    DBT.RLPFID          := RL.RLPFID; --主价格类别
    DBT.RLDATETIME      := RL.RLDATETIME; --发生日期
    DBT.RLSCRRLDATE     := RL.RLSCRRLDATE; --原帐务日期
    DBT.RLPRIMCODE      := RL.RLPRIMCODE; --合收表主表号
    DBT.RLPRIFLAG       := RL.RLPRIFLAG; --合收表标志
    DBT.RLRPER          := RL.RLRPER; --抄表员
    DBT.RLSAFID         := RL.RLSAFID; --区域
    DBT.RLSCODECHAR     := RL.RLSCODECHAR; --上期抄表（带表位）
    DBT.RLECODECHAR     := RL.RLECODECHAR; --本期抄表（带表位）
    DBT.RLILID          := RL.RLILID; --发票流水号
    DBT.RLMIUIID        := RL.RLMIUIID; --合收单位编号
    DBT.RLGROUP         := RL.RLGROUP; --应收帐分组
    DBT.RLPID           := RL.RLPID; --实收流水（与payment.pid对应）
    DBT.RLPBATCH        := RL.RLPBATCH; --缴费交易批次（与payment.PBATCH对应）
    DBT.RLSAVINGQC      := RL.RLSAVINGQC; --期初预存（销帐时产生）
    DBT.RLSAVINGBQ      := RL.RLSAVINGBQ; --本期预存发生（销帐时产生）
    DBT.RLSAVINGQM      := RL.RLSAVINGQM; --期末预存（销帐时产生）
    DBT.RLREVERSEFLAG   := RL.RLREVERSEFLAG; --  冲正标志（N为正常，Y为冲正）
    DBT.RLBADFLAG       := 'O'; --呆帐标志（Y :呆坏帐，O:呆坏帐审批中，N:正常帐）  --发出时修改标志
    DBT.RLZNJREDUCFLAG  := RL.RLZNJREDUCFLAG; --滞纳金减免标志,未减免时为N，销帐时滞纳金直接计算；减免后为Y,销帐时滞纳金直接取rlznj
    DBT.RLMISTID        := RL.RLMISTID; --行业分类
    DBT.RLMINAME        := RL.RLMINAME; --票据名称
    DBT.RLSXF           := RL.RLSXF; --手续费
    DBT.RLMIFACE2       := RL.RLMIFACE2; --抄见故障
    DBT.RLMIFACE3       := RL.RLMIFACE3; --非常计量
    DBT.RLMIFACE4       := RL.RLMIFACE4; --表井设施说明
    DBT.RLMIIFCKF       := RL.RLMIIFCKF; --垃圾费户数
    DBT.RLMIGPS         := RL.RLMIGPS; --是否合票
    DBT.RLMIQFH         := RL.RLMIQFH; --铅封号
    DBT.RLMIBOX         := RL.RLMIBOX; --消防水价（增值税水价，襄阳需求）
    DBT.RLMINAME2       := RL.RLMINAME2; --招牌名称(小区名，襄阳需求）
    DBT.RLMISEQNO       := RL.RLMISEQNO; --户号（初始化时册号+序号）
    DBT.RLMISAVING      := RL.RLMISAVING; --算费时预存
    DBT.RLPRIORJE       := RL.RLPRIORJE; --算费之前欠费
    DBT.RLMICOMMUNITY   := RL.RLMICOMMUNITY; --小区
    DBT.RLMIREMOTENO    := RL.RLMIREMOTENO; --远传表号
    DBT.RLMIREMOTEHUBNO := RL.RLMIREMOTEHUBNO; --远传HUB号
    DBT.RLMIEMAIL       := RL.RLMIEMAIL; --电子邮件
    DBT.RLMIEMAILFLAG   := RL.RLMIEMAILFLAG; --发票类别
    DBT.RLMICOLUMN1     := RL.RLMICOLUMN1; --备用字段1
    DBT.RLMICOLUMN2     := RL.RLMICOLUMN2; --备用字段2(预开票打印批次)
    DBT.RLMICOLUMN3     := RL.RLMICOLUMN3; --备用字段3
    DBT.RLMICOLUMN4     := RL.RLMICOLUMN4; --备用字段3
    DBT.RLPAIDMONTH     := RL.RLPAIDMONTH; --销账月份
    DBT.DBDAPPNOTE      := ''; --申请说明
    DBT.DBDFILASHNOTE   := ''; --领导意见
    DBT.DBDMEMO         := ''; --备注
    DBT.DBDSHFLAG       := 'N'; --行审核标志
    DBT.DBDSHDATE       := ''; --行审核日期
    DBT.DBDSHPER        := ''; --行审核人

    INSERT INTO DSZBILLDT VALUES DBT;
  END CREATEDT;

  PROCEDURE CREATEDSZBILL(P_DSHNO     IN VARCHAR2, --单据流水号
                          P_DSHLB     IN VARCHAR2, --单据类别
                          P_DSHSMFID  IN VARCHAR2, --营销公司
                          P_DSHDEPT   IN VARCHAR2, --受理部门
                          P_DSHCREPER IN VARCHAR2, --受理人员
                          P_RLID      IN VARCHAR2 --应收流水号
                          ) IS
    RL      RECLIST%ROWTYPE;
    V_ROWID NUMBER(10) := 0; --行号
    --单位游标
    CURSOR C_RL IS
      SELECT T.* FROM RECLIST T, PBPARMTEMP P WHERE RLID = C1;
    --RLID = '';
  BEGIN
    --插入单头
    CREATEHD(P_DSHNO, --单据流水号
             P_DSHLB, --单据类别
             P_DSHSMFID, --营销公司
             P_DSHDEPT, --受理部门
             P_DSHCREPER --受理人员
             );
    --插入单体
    OPEN C_RL;
    LOOP
      FETCH C_RL
        INTO RL;
      EXIT WHEN C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL;
      V_ROWID := V_ROWID + 1;
      CREATEDT(P_DSHNO, --单据流水号
               V_ROWID, --行号
               RL.RLID --应收流水号
               );
      --修改呆死帐标志
      UPDATE RECLIST SET RECLIST.RLBADFLAG = 'O' WHERE RLID = RL.RLID;
    END LOOP;
    CLOSE C_RL;
    COMMIT;
  END CREATEDSZBILL;

  --删除单据
  PROCEDURE CANCELBILL(P_BILLNO IN VARCHAR2, --单据编号
                       P_PERSON IN VARCHAR2, --操作员
                       P_DJLB   IN VARCHAR2) IS
    --单据类别
    CURSOR C_DBH IS
      SELECT *
        FROM DSZBILLHD
       WHERE DBHNO = P_BILLNO
      --and dbhlb = p_djlb
         FOR UPDATE;
    DBH DSZBILLHD%ROWTYPE;
  BEGIN
    OPEN C_DBH;
    FETCH C_DBH
      INTO DBH;
    IF C_DBH%NOTFOUND OR C_DBH%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据不存在' || P_BILLNO);
    END IF;
    IF DBH.DBHSHFLAG <> 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据不能取消' || P_BILLNO);
    END IF;
    --修改呆死帐标志
    UPDATE RECLIST
       SET RECLIST.RLBADFLAG = 'N'
     WHERE RLID IN (SELECT RLID FROM DSZBILLDT WHERE DBDNO = P_BILLNO);
    --删除单体
    DELETE FROM DSZBILLDT T WHERE T.DBDNO = P_BILLNO;
    --删除单头
    DELETE FROM DSZBILLHD T WHERE T.DBHNO = P_BILLNO;
    CLOSE C_DBH;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_DBH%ISOPEN THEN
        CLOSE C_DBH;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END CANCELBILL;


 --审核主程序
  PROCEDURE CUSTBILLMAIN      (P_CCHNO  IN VARCHAR2, --批次流水
                     P_PER    IN VARCHAR2, --操作员
                     P_billid IN VARCHAR2, --单据id
                     P_BILLTYPE IN VARCHAR2 --单据类别
                     ) AS

  BEGIN
               CUSTBILL(P_CCHNO,P_PER,P_BILLTYPE,'N');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;


  --审核主程序
  PROCEDURE CUSTBILL(P_CCHNO  IN VARCHAR2, --批次流水
                     P_PER    IN VARCHAR2, --操作员
                     P_BILLTYPE IN VARCHAR2,
                     P_COMMIT IN VARCHAR2 --提交标志
                     ) AS
    RL      RECLIST%ROWTYPE;
    DBH     DSZBILLHD%ROWTYPE;
    DBT     DSZBILLDT%ROWTYPE;
    V_ROWID NUMBER(10) := 0; --行号
    CURSOR C_CUSTDT IS
      SELECT * FROM DSZBILLDT WHERE DBDNO = P_CCHNO FOR UPDATE;
  BEGIN
    BEGIN
      SELECT * INTO DBH FROM DSZBILLHD WHERE DBHNO = P_CCHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
    END;
    IF DBH.DBHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '变更单已审核,不需再审!');
    END IF;
    IF DBH.DBHSHFLAG = 'C' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '变更单已取消,不能审!');
    END IF;

    OPEN C_CUSTDT;
    LOOP
      FETCH C_CUSTDT
        INTO DBT;
      EXIT WHEN C_CUSTDT%NOTFOUND OR C_CUSTDT%NOTFOUND IS NULL;
      --更新单体
      UPDATE DSZBILLDT
         SET DBDSHFLAG = 'Y', --行审核标志
             DBDSHDATE = SYSDATE, --行审核日期
             DBDSHPER  = P_PER --行审核人
       WHERE DBDNO = DBT.DBDNO
         AND DBDROWNO = DBT.DBDROWNO;
      --更新账务呆死帐标志
      IF P_BILLTYPE = '8' THEN --正常账变更为呆坏账  add 20140831
        --20140227 增加呆坏账应收事务  rectrans
            UPDATE RECLIST SET RLBADFLAG = 'Y',RLTRANS='D' WHERE RLID = DBT.RLID;
      else  --呆坏账变更为正常账 add 20140831
            UPDATE RECLIST SET RLBADFLAG = 'N',RLTRANS='D' WHERE RLID = DBT.RLID;
      end if ;
    END LOOP;
    CLOSE C_CUSTDT;
    --审核单头
    UPDATE DSZBILLHD
       SET DBHSHDATE = SYSDATE, DBHSHPER = P_PER, DBHSHFLAG = 'Y'
     WHERE DBHNO = P_CCHNO;

    /*--更新流程
    update kpi_task t
       set t.do_date = sysdate, t.isfinish = 'Y'
     where t.report_id = trim(P_CCHNO);*/

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

END;
/

