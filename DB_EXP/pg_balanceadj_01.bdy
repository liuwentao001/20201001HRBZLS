CREATE OR REPLACE PACKAGE BODY Pg_Balanceadj_01 IS
  /*====================================================================
  -- Name: Pg_BALANCEADJ_01.Approve
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 余额调整过程包,单据提交入口过程
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
  
    IF p_Djlb = '36' OR p_Djlb = '39' THEN
      --36预存余额退费申请  39预存余额撤表退费申请
      Sp_Balanceadj(p_Billno, p_Person, 'Y');
    ELSE
      Raise_Application_Error(Errcode, p_Billno || '->1 无效的单据类别！');
    END IF;
  END;

  /*====================================================================
  -- Name: Pg_BALANCEADJ_01.Sp_Balanceadj
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 余额调整过程包,余额调整
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved.
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/
  PROCEDURE Sp_Balanceadj(p_Bill_Id IN VARCHAR2, --批次流水
                          p_Per     IN VARCHAR2, --操作员
                          p_Commit  IN VARCHAR2 --提交标志
                          ) AS
    v_Exist NUMBER(10);
    Znjdt   Ys_Gd_Balanceadjdt%ROWTYPE;
    Znjhd   Ys_Gd_Balanceadjhd%ROWTYPE;
    --ZNJL     ZNJADJUSTLIST%ROWTYPE;
    Ar             Ys_Zw_Arlist%ROWTYPE;
    Mi             Ys_Yh_Sbinfo%ROWTYPE;
    Ci             Ys_Yh_Custinfo%ROWTYPE;
    c_Ptrans       VARCHAR2(3);
    v_Batch        Ys_Zw_Paidment.Pdbatch%TYPE;
    v_Pid          Ys_Zw_Paidment.Pid%TYPE;
    Vn_Remainafter Ys_Zw_Paidment.Pdsavingqm%TYPE;
    CURSOR c_Ys_Gd_Balanceadjdt IS
      SELECT *
        FROM Ys_Gd_Balanceadjdt
       WHERE Bill_Id = p_Bill_Id
         FOR UPDATE;
    CURSOR c_Custinfo(Vcid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vcid;
    CURSOR c_Meterinfo(Vmid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Yhid = Vmid;
  BEGIN
    BEGIN
      SELECT *
        INTO Znjhd
        FROM Ys_Gd_Balanceadjhd
       WHERE Bill_Id = p_Bill_Id;
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(Errcode, '变更单头信息不存在!');
    END;
  
    IF Znjhd.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '变更单已审核,不需再审!');
    END IF;
    IF Znjhd.Check_Flag = 'Q' THEN
      Raise_Application_Error(Errcode, '变更单已取消,不能审!');
    END IF;
    Znjhd.Check_Date := SYSDATE;
    OPEN c_Ys_Gd_Balanceadjdt;
    LOOP
      FETCH c_Ys_Gd_Balanceadjdt
        INTO Znjdt;
      EXIT WHEN c_Ys_Gd_Balanceadjdt%NOTFOUND OR c_Ys_Gd_Balanceadjdt%NOTFOUND IS NULL;
      --SBSAVING 
      OPEN c_Custinfo(Znjdt.Yhid);
      FETCH c_Custinfo
        INTO Ci;
      IF c_Custinfo%NOTFOUND OR c_Custinfo%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode, '无此用户');
      END IF;
      CLOSE c_Custinfo;
    
      OPEN c_Meterinfo(Znjdt.Yhid);
      FETCH c_Meterinfo
        INTO Mi;
      IF c_Meterinfo%NOTFOUND OR c_Meterinfo%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode, '无此水表');
      END IF;
      CLOSE c_Meterinfo;
    
      IF Mi.Sbsaving + Znjdt.Adjust_Balance < 0 THEN
        Raise_Application_Error(Errcode,
                                '在此工单申请后，用户[' || Znjdt.Yhid ||
                                ']的预存余额不够,会造成负预存,请核查!');
      END IF;
      IF Mi.Sbsaving <> Znjdt.Balance THEN
        Raise_Application_Error(Errcode,
                                '在此工单申请后，用户[' || Znjdt.Yhid ||
                                ']的预存余额已被更改,请核查!');
      END IF;
      --判断是否有欠费
      BEGIN
        SELECT 1
          INTO v_Exist
          FROM Ys_Zw_Arlist Ar
         WHERE Yhid = Znjdt.Yhid
           AND Arreverseflag = 'N'
           AND Arbadflag = 'N'
           AND Arpaidflag = 'N'
           AND Arje > 0
           AND Rownum < 2;
      EXCEPTION
        WHEN No_Data_Found THEN
          NULL;
      END;
      IF v_Exist > 0 THEN
        Raise_Application_Error(Errcode,
                                '在此工单申请后，用户[' || Znjdt.Yhid || ']有欠费,请核查!');
      END IF;
    
      IF Znjdt.Change_Type = '36' THEN
        c_Ptrans := 'y';
        --yc.ycnote := '预存余额退费申请';
      ELSIF Znjdt.Change_Type = '39' THEN
        c_Ptrans := 'Y';
        --yc.ycnote := '预存余额撤表退费申请';
      END IF;
    
      SELECT TRIM(To_Char(Seq_Paidbatch.Nextval, '0000000000'))
        INTO v_Batch
        FROM Dual;
    
      Pg_Paid.Precustback(Znjdt.Yhid, --     IN VARCHAR2,
                          Znjhd.Manage_No, --   IN VARCHAR2,
                          p_Per, --       IN VARCHAR2,
                          c_Ptrans, --    IN VARCHAR2,
                          Znjdt.Adjust_Balance, --     IN NUMBER,
                          Znjdt.Adjust_Memo, --      IN VARCHAR2,
                          v_Batch, --      IN OUT VARCHAR2,
                          v_Pid, --    OUT VARCHAR2,
                          Vn_Remainafter --OUT NUMBER
                          );
    
    END LOOP;
    CLOSE c_Ys_Gd_Balanceadjdt;
  
    UPDATE Ys_Gd_Balanceadjhd
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

