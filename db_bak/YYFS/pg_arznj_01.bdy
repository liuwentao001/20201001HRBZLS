CREATE OR REPLACE PACKAGE BODY Pg_Arznj_01 IS
  /*====================================================================
  -- Name: Pg_Arznj_01.Approve
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 违约金调整过程包,单据提交入口过程
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved. 
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2) IS
  BEGIN
  
    IF p_Djlb = '7' THEN
      SP_ARZNJJM(P_BILLNO, P_PERSON, 'Y');
    ELSE
      Raise_Application_Error(Errcode, p_Billno || '->1 无效的单据类别！');
    END IF;
  END;

  /*====================================================================
  -- Name: Pg_Arznj_01.Sp_Arznjjm
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 违约金调整过程包,滞纳金减免
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved. 
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/
  PROCEDURE Sp_Arznjjm(p_Bill_Id IN VARCHAR2, --批次流水
                       p_Per     IN VARCHAR2, --操作员
                       p_Commit  IN VARCHAR2 --提交标志
                       ) AS
    v_Exist NUMBER(10);
    Znjdt   Ys_Gd_Znjadjustdt%ROWTYPE;
    Znjhd   Ys_Gd_Znjadjusthd%ROWTYPE;
    --ZNJL     ZNJADJUSTLIST%ROWTYPE;
    Ar       Ys_Zw_Arlist%ROWTYPE;
    Rd       Ys_Zw_Ardetail%ROWTYPE;
    v_Chkstr VARCHAR2(200);
    CURSOR c_Ys_Gd_Znjadjustdt IS
      SELECT * FROM Ys_Gd_Znjadjustdt WHERE Bill_Id = p_Bill_Id FOR UPDATE;
  BEGIN
    BEGIN
      SELECT * INTO Znjhd FROM Ys_Gd_Znjadjusthd WHERE Bill_Id = p_Bill_Id;
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(Errcode, '变更单头信息不存在!');
    END;
    --检查减免额度
    /*    V_CHKSTR :=F_CHKZNJED( P_PER ,ZNJHD.bill_id   ) ;
    IF V_CHKSTR <>'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, V_CHKSTR);
    END IF;*/
    IF Znjhd.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '变更单已审核,不需再审!');
    END IF;
    IF Znjhd.Check_Flag = 'Q' THEN
      Raise_Application_Error(Errcode, '变更单已取消,不能审!');
    END IF;
    Znjhd.Check_Date := SYSDATE;
    OPEN c_Ys_Gd_Znjadjustdt;
    LOOP
      FETCH c_Ys_Gd_Znjadjustdt
        INTO Znjdt;
      EXIT WHEN c_Ys_Gd_Znjadjustdt%NOTFOUND OR c_Ys_Gd_Znjadjustdt%NOTFOUND IS NULL;
      BEGIN
        SELECT * INTO Ar FROM Ys_Zw_Arlist WHERE Arid = Znjdt.Rec_Id;
      EXCEPTION
        WHEN OTHERS THEN
          Raise_Application_Error(Errcode,
                                  '应收流水号[' || Znjdt.Rec_Id || ']不存在');
      END;
      IF Ar.Arcd <> 'DE' THEN
        Raise_Application_Error(Errcode,
                                '资料号[' || Ar.Armcode || ']' || Ar.Armonth || '月份' ||
                                '应收流水号[' || Ar.Arid || ']已进行冲正处理，不能做减免！');
      END IF;
    
      IF Ar.Arpaidflag <> 'N' THEN
        Raise_Application_Error(Errcode,
                                '资料号[' || Ar.Armcode || ']' || Ar.Armonth || '月份' ||
                                '应收流水号[' || Ar.Arid || ']已为销帐状态，不能做减免！');
      END IF;
    
      /*IF AR.AROUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '资料号[' || AR.ARMCODE || ']' || AR.ARMONTH || '月份' ||
                                '应收流水号[' || AR.rec_id ||
                                ']欠费信息已发到银行扣款，不能做减免！');
      END IF;*/
      /*UPDATE ZNJADJUSTLIST T
         SET ZALSTATUS = 'N'
       WHERE T.ZALrec_id = ZNJDT.ZADrec_id
         AND ZALSTATUS = 'Y';
      
      ZNJL.ZALrec_id      := ZNJDT.ZADrec_id; --减免应收流水
      ZNJL.ZALPIID      := ZNJDT.ZADPIID; --减免费用项目（全部为NA）
      ZNJL.ZALMID       := ZNJDT.ZADMID; --水表编号
      ZNJL.ZALMCODE     := ZNJDT.ZADMCODE; --水表号
      ZNJL.ZALMETHOD    := ZNJDT.ZADMETHOD; --减免方法（1、目标金额减免；2、比例金额减免；3、差额减免；4、调整起算日期）
      ZNJL.ZALVALUE     := ZNJDT.ZADVALUE; --减免金额/比例值
      ZNJL.ZALZNDATE    := ZNJDT.ZADZNDATE; --减免目标起算日
      ZNJL.ZALDATE      := ZNJHD.check_date; --减免日期
      ZNJL.ZALPER       := P_PER; --减免人员
      ZNJL.ZALBILLNO    := ZNJDT.bill_id; --减免单据编号
      ZNJL.ZALBILLROWNO := ZNJDT.ZADROWNO; --减免单据行号
      ZNJL.ZALSTATUS    := 'Y'; --有效标志
      INSERT INTO ZNJADJUSTLIST VALUES ZNJL;*/
      if Znjdt.Method = '01' then
        UPDATE Ys_Zw_Arlist Ar
           SET Ar.Arznjreducflag = 'Y', Ar.Arznj = Znjdt.Adjust_Value
         WHERE Arid = Znjdt.Rec_Id
           --AND Arznjreducflag = 'N'
           AND Arpaidflag = 'N';
      end if;
      if Znjdt.Method = '03' then
        UPDATE Ys_Zw_Arlist Ar
           SET Ar.Arznjreducflag = 'Y',
               Ar.Arznj          = round(Znjdt.Adjust_Value *
                                         Znjdt.Adjust_Ratio,
                                         2)
         WHERE Arid = Znjdt.Rec_Id
           --AND Arznjreducflag = 'N'
           AND Arpaidflag = 'N';
      end if;
    
      IF Znjdt.Method = '02' THEN
        -- 调整起算日期  
        UPDATE Ys_Zw_Arlist Ar
           SET Ar.Arzndate = Znjdt.Late_Fee_Date
         WHERE Arid = Znjdt.Rec_Id
         AND Arpaidflag = 'N';
      END IF;
    END LOOP;
    CLOSE c_Ys_Gd_Znjadjustdt;
  
    UPDATE Ys_Gd_Znjadjusthd
       SET Check_Date = Znjhd.Check_Date,
           Check_Per  = p_Per,
           Check_Flag = 'Y'
     WHERE Bill_Id = p_Bill_Id;
  
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

