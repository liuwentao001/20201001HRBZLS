CREATE OR REPLACE PACKAGE BODY Pg_Dszbill_01 IS

  PROCEDURE Createhd(p_Dshno     IN VARCHAR2, --单据流水号
                     p_Dshlb     IN VARCHAR2, --单据类别
                     p_Dshsmfid  IN VARCHAR2, --营销公司
                     p_Dshdept   IN VARCHAR2, --受理部门
                     p_Dshcreper IN VARCHAR2 --受理人员
                     ) IS
    Dbh Ys_Gd_Zwdhzd%ROWTYPE;
  BEGIN
    --赋值 单头
    Dbh.Id          := Uuid();
    Dbh.Hire_Code   := f_Get_Hire_Code();
    Dbh.Bill_Id     := p_Dshno; --单据流水号
    Dbh.Bill_No     := p_Dshno; --单据编号
    Dbh.Bill_Type   := p_Dshlb; --单据类别
    Dbh.Bill_Source := '1'; --单据来源
    Dbh.Manage_No   := p_Dshsmfid; --营销公司
    Dbh.New_Dept    := p_Dshdept; --受理部门
    Dbh.Add_Date    := SYSDATE; --受理日期
    Dbh.Add_Per     := p_Dshcreper; --受理人员
    Dbh.Check_Date  := NULL; --审核日期
    Dbh.Check_Per   := NULL; --审核人员
    Dbh.Check_Flag  := 'N'; --审核标志
    INSERT INTO Ys_Gd_Zwdhzd VALUES Dbh;
  
  END Createhd;

  PROCEDURE Createdt(p_Dsdno    IN VARCHAR2, --单据流水号
                     p_Dsdrowno IN VARCHAR2, --行号
                     p_Arid     IN VARCHAR2 --应收流水
                     ) IS
    Dbt Ys_Gd_Zwdhzdt%ROWTYPE;
    Ar  Ys_Zw_Arlist%ROWTYPE;
  BEGIN
    --查询账务信息
    SELECT * INTO Ar FROM Ys_Zw_Arlist WHERE Arid = p_Arid;
    --赋值 单体      
    Dbt.Bill_Id   := p_Dsdno; --单据流水号
    Dbt.Dhzrowno  := p_Dsdrowno; --行号
    Dbt.Hire_Code := Ar.Hire_Code; --
    Dbt.Arid      := Ar.Arid; --流水号
    Dbt.Manage_No := Ar.Manage_No; --营销公司
    Dbt.Armonth   := Ar.Armonth; --帐务月份
    Dbt.Ardate    := Ar.Ardate; --帐务日期
    Dbt.Yhid      := Ar.Yhid; --用户编号
    Dbt.Sbid      := Ar.Sbid; --水表编号
    /* DBT.RLMSMFID        := Ar.RLMSMFID; --水表公司
    DBT.RLCSMFID        := Ar.RLCSMFID; --用户公司
    DBT.RLCCODE         := Ar.RLCCODE; --资料号*/
    Dbt.Archargeper     := Ar.Archargeper; --收费员
    Dbt.Arcpid          := Ar.Arcpid; --上级用户编号
    Dbt.Arcclass        := Ar.Arcclass; --用户级次
    Dbt.Arcflag         := Ar.Arcflag; --末级标志
    Dbt.Arusenum        := Ar.Arusenum; --户用水人数
    Dbt.Arcname         := Ar.Arcname; --用户名称
    Dbt.Arcadr          := Ar.Arcadr; --用户地址
    Dbt.Armadr          := Ar.Armadr; --水表地址
    Dbt.Arcstatus       := Ar.Arcstatus; --用户状态
    Dbt.Armtel          := Ar.Armtel; --移动电话
    Dbt.Artel           := Ar.Artel; --固定电话
    Dbt.Arbankid        := Ar.Arbankid; --代扣银行
    Dbt.Artsbankid      := Ar.Artsbankid; --托收银行
    Dbt.Araccountno     := Ar.Araccountno; --开户帐号
    Dbt.Araccountname   := Ar.Araccountname; --开户名称
    Dbt.Ariftax         := Ar.Ariftax; --是否税票
    Dbt.Artaxno         := Ar.Artaxno; --增殖税号
    Dbt.Arifinv         := Ar.Arifinv; --是否普票
    Dbt.Armcode         := Ar.Armcode; --水表手工编号
    Dbt.Armpid          := Ar.Armpid; --上级水表
    Dbt.Armclass        := Ar.Armclass; --水表级次
    Dbt.Armflag         := Ar.Armflag; --末级标志
    Dbt.Armsfid         := Ar.Armsfid; --水表类别
    Dbt.Arday           := Ar.Arday; --抄表日
    Dbt.Arbfid          := Ar.Arbfid; --表册
    Dbt.Arprdate        := Ar.Arprdate; --上次抄表日期
    Dbt.Arrdate         := Ar.Arrdate; --本次抄表日期
    Dbt.Arzndate        := Ar.Arzndate; --违约金起算日
    Dbt.Arcaliber       := Ar.Arcaliber; --表口径
    Dbt.Arrtid          := Ar.Arrtid; --抄表方式
    Dbt.Armstatus       := Ar.Armstatus; --状态
    Dbt.Armtype         := Ar.Armtype; --类型
    Dbt.Armno           := Ar.Armno; --表身码
    Dbt.Arscode         := Ar.Arscode; --起数
    Dbt.Arecode         := Ar.Arecode; --止数
    Dbt.Arreadsl        := Ar.Arreadsl; --抄见水量
    Dbt.Arinvmemo       := Ar.Arinvmemo; --发票备注
    Dbt.Arentrustbatch  := Ar.Arentrustbatch; --托收代扣批号
    Dbt.Arentrustseqno  := Ar.Arentrustseqno; --托收代扣流水号
    Dbt.Aroutflag       := Ar.Aroutflag; --发出标志
    Dbt.Artrans         := Ar.Artrans; --应收事务
    Dbt.Arcd            := Ar.Arcd; --借贷方向
    Dbt.Aryschargetype  := Ar.Aryschargetype; --应收方式
    Dbt.Arsl            := Ar.Arsl; --应收水量
    Dbt.Arje            := Ar.Arje; --应收金额
    Dbt.Araddsl         := Ar.Araddsl; --加调水量
    Dbt.Arscrarid       := Ar.Arscrarid; --原应收帐流水
    Dbt.Arscrartrans    := Ar.Arscrartrans; --原应收帐事务
    Dbt.Arscrarmonth    := Ar.Arscrarmonth; --原应收帐月份
    Dbt.Arpaidje        := Ar.Arpaidje; --销帐金额
    Dbt.Arpaidflag      := Ar.Arpaidflag; --销帐标志(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
    Dbt.Arpaidper       := Ar.Arpaidper; --销帐人员
    Dbt.Arpaiddate      := Ar.Arpaiddate; --销帐日期
    Dbt.Armrid          := Ar.Armrid; --抄表流水
    Dbt.Armemo          := Ar.Armemo; --备注
    Dbt.Arznj           := Ar.Arznj; --违约金
    Dbt.Arlb            := Ar.Arlb; --类别
    Dbt.Arcname2        := Ar.Arcname2; --曾用名
    Dbt.Arpfid          := Ar.Arpfid; --主价格类别
    Dbt.Ardatetime      := Ar.Ardatetime; --发生日期
    Dbt.Arscrardate     := Ar.Arscrardate; --原帐务日期
    Dbt.Arprimcode      := Ar.Arprimcode; --合收表主表号
    Dbt.Arpriflag       := Ar.Arpriflag; --合收表标志
    Dbt.Arrper          := Ar.Arrper; --抄表员
    Dbt.Arsafid         := Ar.Arsafid; --区域
    Dbt.Arscodechar     := Ar.Arscodechar; --上期抄表（带表位）
    Dbt.Arecodechar     := Ar.Arecodechar; --本期抄表（带表位）
    Dbt.Arilid          := Ar.Arilid; --发票流水号
    Dbt.Armiuiid        := Ar.Armiuiid; --合收单位编号
    Dbt.Argroup         := Ar.Argroup; --应收帐分组
    Dbt.Arpid           := Ar.Arpid; --实收流水（与PAYMENT.PID对应）
    Dbt.Arpbatch        := Ar.Arpbatch; --缴费交易批次（与PAYMENT.PBATCH对应）
    Dbt.Arsavingqc      := Ar.Arsavingqc; --期初预存（销帐时产生）
    Dbt.Arsavingbq      := Ar.Arsavingbq; --本期预存发生（销帐时产生）
    Dbt.Arsavingqm      := Ar.Arsavingqm; --期末预存（销帐时产生）
    Dbt.Arreverseflag   := Ar.Arreverseflag; --  冲正标志（N为正常，Y为冲正）
    Dbt.Arbadflag       := 'O'; --呆帐标志（Y :呆坏帐，O:呆坏帐审批中，N:正常帐）  --发出时修改标志
    Dbt.Arznjreducflag  := Ar.Arznjreducflag; --滞纳金减免标志,未减免时为N，销帐时滞纳金直接计算；减免后为Y,销帐时滞纳金直接取ARZNJ
    Dbt.Armistid        := Ar.Armistid; --行业分类
    Dbt.Arminame        := Ar.Arminame; --票据名称
    Dbt.Arsxf           := Ar.Arsxf; --手续费
    Dbt.Armiface2       := Ar.Armiface2; --抄见故障
    Dbt.Armiface3       := Ar.Armiface3; --非常计量
    Dbt.Armiface4       := Ar.Armiface4; --表井设施说明
    Dbt.Armiifckf       := Ar.Armiifckf; --垃圾费户数
    Dbt.Armigps         := Ar.Armigps; --是否合票
    Dbt.Armiqfh         := Ar.Armiqfh; --铅封号
    Dbt.Armibox         := Ar.Armibox; --消防水价（增值税水价，襄阳需求）
    Dbt.Arminame2       := Ar.Arminame2; --招牌名称(小区名，襄阳需求）
    Dbt.Armiseqno       := Ar.Armiseqno; --户号（初始化时册号+序号）
    Dbt.Armisaving      := Ar.Armisaving; --算费时预存
    Dbt.Arpriorje       := Ar.Arpriorje; --算费之前欠费
    Dbt.Armicommunity   := Ar.Armicommunity; --小区
    Dbt.Armiremoteno    := Ar.Armiremoteno; --远传表号
    Dbt.Armiremotehubno := Ar.Armiremotehubno; --远传HUB号
    Dbt.Armiemail       := Ar.Armiemail; --电子邮件
    Dbt.Armiemailflag   := Ar.Armiemailflag; --发票类别
    Dbt.Armicolumn1     := Ar.Armicolumn1; --备用字段1
    Dbt.Armicolumn2     := Ar.Armicolumn2; --备用字段2(预开票打印批次)
    Dbt.Armicolumn3     := Ar.Armicolumn3; --备用字段3
    Dbt.Armicolumn4     := Ar.Armicolumn4; --备用字段3
    Dbt.Arpaidmonth     := Ar.Arpaidmonth; --销账月份
    Dbt.Arcolumn5       := Ar.Arcolumn5; --上次应帐帐日期
    Dbt.Arcolumn9       := Ar.Arcolumn9; --上次应收帐流水
    Dbt.Arcolumn10      := Ar.Arcolumn10; --上次应收帐月份
    Dbt.Arcolumn11      := Ar.Arcolumn11; --上次应收帐事务
    Dbt.Arjtmk          := Ar.Arjtmk; --不记阶梯注记
    Dbt.Arjtsrq         := Ar.Arjtsrq; --本周期阶梯开始日期
    Dbt.Arcolumn12      := Ar.Arcolumn12; --年度累计量
    Dbt.Dhzappnote      := ''; --申请说明
    Dbt.Dhzfilashnote   := ''; --领导意见
    Dbt.Dhzmemo         := ''; --备注
    Dbt.Dhzshflag       := 'N'; --行审核标志
    Dbt.Dhzshdate       := ''; --行审核日期
    Dbt.Dhzshper        := ''; --行审核人
  
    INSERT INTO Ys_Gd_Zwdhzdt VALUES Dbt;
  END Createdt;

  PROCEDURE Createdszbill(p_Dshno     IN VARCHAR2, --单据流水号
                          p_Dshlb     IN VARCHAR2, --单据类别
                          p_Dshsmfid  IN VARCHAR2, --营销公司
                          p_Dshdept   IN VARCHAR2, --受理部门
                          p_Dshcreper IN VARCHAR2, --受理人员
                          p_Arid      IN VARCHAR2 --应收流水号
                          ) IS
    Ar      Ys_Zw_Arlist%ROWTYPE;
    v_Rowid NUMBER(10) := 0; --行号
    --单位游标
    CURSOR c_Ar IS
      SELECT t.*
        FROM Ys_Zw_Arlist t /*, PBPARMTEMP P*/
       WHERE Arid = p_Arid;
    --ARID = '';
  BEGIN
    --插入单头
    Createhd(p_Dshno, --单据流水号
             p_Dshlb, --单据类别
             p_Dshsmfid, --营销公司
             p_Dshdept, --受理部门
             p_Dshcreper --受理人员
             );
    --插入单体
    OPEN c_Ar;
    LOOP
      FETCH c_Ar
        INTO Ar;
      EXIT WHEN c_Ar%NOTFOUND OR c_Ar%NOTFOUND IS NULL;
      v_Rowid := v_Rowid + 1;
      Createdt(p_Dshno, --单据流水号
               v_Rowid, --行号
               Ar.Arid --应收流水号
               );
      --修改呆死帐标志
      UPDATE Ys_Zw_Arlist
         SET Ys_Zw_Arlist.Arbadflag = 'O'
       WHERE Arid = Ar.Arid;
    END LOOP;
    CLOSE c_Ar;
    COMMIT;
  END Createdszbill;

  --删除单据
  PROCEDURE Cancelbill(p_Billno IN VARCHAR2, --单据编号
                       p_Person IN VARCHAR2, --操作员
                       p_Djlb   IN VARCHAR2) IS
    --单据类别
    CURSOR c_Dbh IS
      SELECT *
        FROM Ys_Gd_Zwdhzd
       WHERE Bill_Id = p_Billno
      --AND BILL_TYPE = P_DJLB
         FOR UPDATE;
    Dbh Ys_Gd_Zwdhzd%ROWTYPE;
  BEGIN
    OPEN c_Dbh;
    FETCH c_Dbh
      INTO Dbh;
    IF c_Dbh%NOTFOUND OR c_Dbh%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '单据不存在' || p_Billno);
    END IF;
    IF Dbh.Check_Flag <> 'N' THEN
      Raise_Application_Error(Errcode, '单据不能取消' || p_Billno);
    END IF;
    --修改呆死帐标志
    UPDATE Ys_Zw_Arlist
       SET Ys_Zw_Arlist.Arbadflag = 'N'
     WHERE Arid IN
           (SELECT Arid FROM Ys_Gd_Zwdhzdt WHERE Bill_Id = p_Billno);
    --删除单体
    DELETE FROM Ys_Gd_Zwdhzdt t WHERE t.Bill_Id = p_Billno;
    --删除单头
    DELETE FROM Ys_Gd_Zwdhzd t WHERE t.Bill_Id = p_Billno;
    CLOSE c_Dbh;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Dbh%ISOPEN THEN
        CLOSE c_Dbh;
      END IF;
      Raise_Application_Error(Errcode, SQLERRM);
  END Cancelbill;

  --审核主程序
  PROCEDURE Custbillmain(p_Cchno    IN VARCHAR2, --批次流水
                         p_Per      IN VARCHAR2, --操作员
                         p_Billid   IN VARCHAR2, --单据ID
                         p_Billtype IN VARCHAR2 --单据类别
                         ) AS
  
  BEGIN
    Custbill(p_Cchno, p_Per, p_Billtype, 'N');
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;

  --审核主程序
  PROCEDURE Custbill(p_Cchno    IN VARCHAR2, --批次流水
                     p_Per      IN VARCHAR2, --操作员
                     p_Billtype IN VARCHAR2,
                     p_Commit   IN VARCHAR2 --提交标志
                     ) AS 
    Dbh     Ys_Gd_Zwdhzd%ROWTYPE;
    Dbt     Ys_Gd_Zwdhzdt%ROWTYPE; 
    CURSOR c_Custdt IS
      SELECT * FROM Ys_Gd_Zwdhzdt WHERE Bill_Id = p_Cchno FOR UPDATE;
  BEGIN
    BEGIN
      SELECT * INTO Dbh FROM Ys_Gd_Zwdhzd WHERE Bill_Id = p_Cchno;
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(Errcode, '变更单头信息不存在!');
    END;
    IF Dbh.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '变更单已审核,不需再审!');
    END IF;
    IF Dbh.Check_Flag = 'C' THEN
      Raise_Application_Error(Errcode, '变更单已取消,不能审!');
    END IF;
  
    OPEN c_Custdt;
    LOOP
      FETCH c_Custdt
        INTO Dbt;
      EXIT WHEN c_Custdt%NOTFOUND OR c_Custdt%NOTFOUND IS NULL;
      --更新单体
      UPDATE Ys_Gd_Zwdhzdt
         SET Dhzshflag = 'Y', --行审核标志
             Dhzshdate = SYSDATE, --行审核日期
             Dhzshper  = p_Per --行审核人
       WHERE Bill_Id = Dbt.Bill_Id
         AND Dhzrowno = Dbt.Dhzrowno;
      --更新账务呆死帐标志
      IF p_Billtype = '8' THEN
        --正常账变更为呆坏账  ADD 20140831
        --20140227 增加呆坏账应收事务  RECTRANS
        UPDATE Ys_Zw_Arlist
           SET Arbadflag = 'Y', Artrans = 'D'
         WHERE Arid = Dbt.Arid;
      ELSE
        --呆坏账变更为正常账 ADD 20140831
        UPDATE Ys_Zw_Arlist
           SET Arbadflag = 'N', Artrans = 'D'
         WHERE Arid = Dbt.Arid;
      END IF;
    END LOOP;
    CLOSE c_Custdt;
    --审核单头
    UPDATE Ys_Gd_Zwdhzd
       SET Check_Date = SYSDATE, Check_Per = p_Per, Check_Flag = 'Y'
     WHERE Bill_Id = p_Cchno;
  
  
    IF p_Commit = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;

END;
/

