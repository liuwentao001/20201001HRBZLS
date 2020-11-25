CREATE OR REPLACE PACKAGE BODY Pg_Arsplit_01 IS
  /*====================================================================
  -- Name: Pg_ARSPLIT_01.Approve
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 拆分账单过程包,单据提交入口过程
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
  
    IF p_Djlb = '3' THEN
      Sp_Arsplit(p_Billno, p_Person, 'Y');
    ELSE
      Raise_Application_Error(Errcode, p_Billno || '->1 无效的单据类别！');
    END IF;
  END;
  --分账过程
  PROCEDURE Sp_Recfzrlid(p_Arid IN VARCHAR2, --分账流水
                         p_Je   IN NUMBER --分账金额
                         
                         ) AS
  
    CURSOR c_Ar IS
      SELECT *
        FROM Ys_Zw_Arlist
       WHERE Arid = p_Arid
         AND Arreverseflag = 'N'
         AND Arbadflag = 'N'
         AND Arpaidflag = 'N'
         AND Aroutflag = 'N'
         AND Arje > 0
         FOR UPDATE;
  
    CURSOR c_Rd IS
      SELECT * FROM Ys_Zw_Ardetail WHERE Ardid = p_Arid FOR UPDATE;
  
    CURSOR c_Rdf IS
      SELECT * FROM Ys_Zw_Ardetail_Fz WHERE Ardid = p_Arid FOR UPDATE;
  
    Ar      Ys_Zw_Arlist%ROWTYPE;
    Rd      Ys_Zw_Ardetail%ROWTYPE;
    Arf     Ys_Zw_Arlist_Fz%ROWTYPE;
    Rdf     Ys_Zw_Ardetail_Fz%ROWTYPE;
    v_Je    NUMBER(12, 3);
    v_Arid  VARCHAR2(20);
    v_Arid2 VARCHAR2(20);
    v_Sl2   NUMBER(10);
    v_Je2   NUMBER(10, 3);
    v_Sls2  NUMBER(10);
    v_Jes2  NUMBER(10, 3);
    v_Count NUMBER(10);
    v_Czsl  NUMBER(10);
    p_Sl    NUMBER(10);
    Pb      Ysparmtemp%ROWTYPE;
    v_Scode NUMBER(10);
    v_Ecode NUMBER(10);
  
  BEGIN
    NULL;
    --1、调用过程检查要分拆水量
    OPEN c_Ar;
    FETCH c_Ar
      INTO Ar;
    IF c_Ar%NOTFOUND OR c_Ar%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode,
                              '应收账务不存在,或不是正常欠费,流水号:' || p_Arid || '请检查！');
    END IF;
    CLOSE c_Ar;
    p_Sl := Sf_Recfzsl(p_Arid, p_Je);
  
    IF p_Sl <= 0 THEN
      Raise_Application_Error(Errcode,
                              '分账水量必须小于' || Ar.Arsl || ',流水号:' || Ar.Arid);
    END IF;
  
    --2、将要分账 备份 
    Arf := Ar; --备份原账务
    INSERT INTO Ys_Zw_Arlist_Fz VALUES Ar;
    OPEN c_Rd;
    LOOP
      FETCH c_Rd
        INTO Rd;
      EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
      INSERT INTO Ys_Zw_Ardetail_Fz VALUES Rd;
    END LOOP;
    CLOSE c_Rd;
  
    --YS_ZW_ARDETAIL插入分账第一笔
    v_Je := 0;
    SELECT Lpad(Seq_Arid.Nextval, 10, '0') INTO v_Arid FROM Dual;
    SELECT Lpad(Seq_Arid.Nextval, 10, '0') INTO v_Arid2 FROM Dual;
    v_Sl2  := 0;
    v_Je2  := 0;
    v_Sls2 := Ar.Arsl;
    v_Jes2 := 0;
    OPEN c_Rdf;
    LOOP
      FETCH c_Rdf
        INTO Rd;
      EXIT WHEN c_Rdf%NOTFOUND OR c_Rdf%NOTFOUND IS NULL;
      --获取临时表中的水量
      SELECT * INTO Pb FROM Ysparmtemp p WHERE TRIM(p.C1) = Rd.Ardpmdid;
      p_Sl  := To_Number(TRIM(Pb.C4));
      v_Sl2 := Rd.Ardsl - p_Sl; --第二笔明细水量
      v_Je2 := Rd.Ardje;
      --第一笔明细
    
      Rd.Ardid   := TRIM(v_Arid);
      Rd.Ardyssl := p_Sl;
      Rd.Ardsl   := p_Sl;
      Rd.Ardysje := Rd.Ardysdj * Rd.Ardyssl;
      Rd.Ardje   := Rd.Arddj * Rd.Ardsl;
      INSERT INTO Ys_Zw_Ardetail VALUES Rd; --第一笔明细
      v_Je  := v_Je + Rd.Ardje; --第一笔应收合计金额
      v_Je2 := v_Je2 - Rd.Ardje; --第二笔明细金额
      --生成第二笔明细
      Rd.Ardid   := TRIM(v_Arid2);
      Rd.Ardyssl := v_Sl2;
      Rd.Ardsl   := v_Sl2;
      Rd.Ardysje := v_Je2;
      Rd.Ardje   := v_Je2;
      INSERT INTO Ys_Zw_Ardetail VALUES Rd;
      --V_SLS2          := V_SLS2 + RD.RDSL;
      v_Jes2 := v_Jes2 + Rd.Ardje;
    END LOOP;
    CLOSE c_Rdf;
  
    -- 备份起止码
    v_Scode := Ar.Arscode;
    v_Ecode := Ar.Arecode;
  
    --ys_zw_arlist插入分账第一笔
    SELECT Uuid() INTO Ar.Id FROM Dual;
  
    Ar.Hire_Code := f_Get_Hire_Code();
    Ar.Manage_No := Arf.Manage_No;
    Ar.Arid      := TRIM(v_Arid);
    Ar.Armonth   := Fobtmanapara(Arf.Manage_No, 'READ_MONTH');
    Ar.Ardate    := Trunc(SYSDATE);
  
    Ar.Arcolumn5  := Arf.Ardate; --上次应帐帐日期
    Ar.Arcolumn9  := Arf.Arid; --上次应收帐流水
    Ar.Arcolumn10 := Arf.Armonth; --上次应收帐月份
    Ar.Arcolumn11 := Arf.Artrans; --上次应收帐事务
    Ar.Artrans    := 'C';
    /*ar.arSCRarID    := arF.arID; --原账务应收流水
    ar.arSCRarTRANS := arF.arTRANS; --原账务事物
    ar.arSCRarMONTH := arF.arMONTH; --原账务月份
    ar.arSCRarDATE  := arF.arDATE;  --原账务日期*/
    SELECT SUM(To_Number(Nvl(TRIM(C4), 0))) INTO v_Czsl FROM Ysparmtemp;
    Ar.Arsl     := v_Czsl;
    Ar.Arje     := v_Je;
    Ar.Arreadsl := v_Czsl;
  
    --第一笔账起码不变，止码为起码加上应收水量 20140318
    Ar.Arscode     := v_Scode;
    Ar.Arscodechar := To_Char(Ar.Arscode);
    Ar.Arecode     := v_Scode + Ar.Arsl;
    Ar.Arecodechar := To_Char(Ar.Arecode);
    INSERT INTO Ys_Zw_Arlist VALUES Ar;
  
    --ys_zw_arlist插入分账第二笔 
    SELECT Uuid() INTO Ar.Id FROM Dual;
    Ar.Hire_Code := f_Get_Hire_Code();
    Ar.Manage_No := Arf.Manage_No;
    Ar.Arid      := TRIM(v_Arid2);
    Ar.Armonth   := Fobtmanapara(Arf.Manage_No, 'READ_MONTH');
    Ar.Ardate    := Trunc(SYSDATE);
  
    Ar.Arsl     := v_Sls2 - v_Czsl;
    Ar.Arje     := v_Jes2;
    Ar.Arreadsl := v_Sls2 - v_Czsl;
  
    --第二笔账止码不变，起码为止码减去应收水量 20140318
    Ar.Arscode     := v_Ecode - Ar.Arsl;
    Ar.Arscodechar := To_Char(Ar.Arscode);
    Ar.Arecode     := v_Ecode;
    Ar.Arecodechar := To_Char(Ar.Arecode);
  
    INSERT INTO Ys_Zw_Arlist VALUES Ar;
  
    --5、检查一下分拆两条应收后水量与金额这与与原帐 ys_zw_arlist_fz,YS_ZW_ARDETAIL_fz 是否相同
    --SELECT * INTO arF FROM ys_zw_arlist_FZ WHERE
    SELECT COUNT(*)
      INTO v_Count
      FROM (SELECT Arsl, Arje
              FROM Ys_Zw_Arlist_Fz
             WHERE Arid = p_Arid
            MINUS
            SELECT SUM(Arsl), SUM(Arje)
              FROM Ys_Zw_Arlist
             WHERE Arid IN (TRIM(v_Arid), TRIM(v_Arid2)));
    IF v_Count > 0 THEN
      Raise_Application_Error(Errcode, '分账总金额错误！');
    END IF;
  
    SELECT COUNT(*)
      INTO v_Count
      FROM (SELECT Ardsl, Ardje
              FROM Ys_Zw_Ardetail_Fz
             WHERE Ardid = p_Arid
            MINUS
            SELECT SUM(Ardsl), SUM(Ardje)
              FROM Ys_Zw_Ardetail
             WHERE Ardid IN (TRIM(v_Arid), TRIM(v_Arid2))
             GROUP BY Ardpmdid, Ardpiid, Ardpfid, Ardclass);
  
    IF v_Count > 0 THEN
      Raise_Application_Error(Errcode, '分账明细金额错误！');
    END IF;
  
    --5冲原应收帐
    Sp_Reccz_One_01(p_Arid, 'N');
  
    --O_RET := 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      IF c_Rdf%ISOPEN THEN
        CLOSE c_Rdf;
      END IF;
      ROLLBACK;
      --O_RET :='N';
      Raise_Application_Error(Errcode, SQLERRM);
  END Sp_Recfzrlid;

  /*====================================================================
  -- Name: Pg_ARSPLIT_01.Sp_ARSPLIT
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 拆分账单过程包,拆分账单
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved.
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/

  PROCEDURE Sp_Arsplit(p_Bill_Id IN VARCHAR2, --批次流水
                       p_Per     IN VARCHAR2, --操作员
                       p_Commit  IN VARCHAR2 --提交标志
                       ) AS
    CURSOR c_Hd IS
      SELECT * FROM Ys_Gd_Arsplithd WHERE Bill_Id = p_Bill_Id;
  
    CURSOR c_Dt IS
      SELECT *
        FROM Ys_Gd_Arsplitdt
       WHERE Bill_Id = p_Bill_Id
         AND Chk_Flag = 'Y'
         AND Charge_Amt > 0;    
    Hd    Ys_Gd_Arsplithd%ROWTYPE;
    Dt    Ys_Gd_Arsplitdt%ROWTYPE;
    v_Ret VARCHAR2(10);
  BEGIN
    --检查单头
    OPEN c_Hd;
    FETCH c_Hd
      INTO Hd;
    IF c_Hd%NOTFOUND OR c_Hd%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '单据不存在' || p_Bill_Id);
    END IF;
    CLOSE c_Hd;
    --检查单体
    OPEN c_Dt;
    LOOP
      FETCH c_Dt
        INTO Dt;
      EXIT WHEN c_Dt%NOTFOUND OR c_Dt%NOTFOUND IS NULL;
      Sp_Arsplit_change_one(Dt, p_Per, p_Commit);
      --Sp_Recfzrlid(c_Dt.REC_ID,c_Dt.CHARGE_AMT1);
      IF v_Ret = 'N' THEN
        Raise_Application_Error(Errcode,
                                '分账错误,账务流水:' || Dt.Rec_Id || '|应收金额:' ||
                                Dt.Charge_Amt);
      END IF;
    END LOOP;
    CLOSE c_Dt;
    UPDATE Ys_Gd_Arsplithd
       SET Check_Date = SYSDATE, Check_Per = p_Per, Check_Flag = 'Y'
     WHERE Bill_Id = p_Bill_Id;
  
    IF p_Commit = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF c_Hd%ISOPEN THEN
        CLOSE c_Hd;
      END IF;
      IF c_Dt%ISOPEN THEN
        CLOSE c_Dt;
      END IF;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
 ----------------------------------------------- 
  PROCEDURE Sp_Arsplit_change_one(p_Arsplitdt   IN Ys_Gd_Arsplitdt%rowTYPE,  
                                   p_Per     IN VARCHAR2, --操作员
                                   p_Commit  IN VARCHAR2 --提交标志
                                   ) AS
   CURSOR c_Ar IS
      SELECT *
        FROM Ys_Zw_Arlist
       WHERE Arid = p_Arsplitdt.Rec_Id
         AND Arreverseflag = 'N'
         AND Arbadflag = 'N'
         AND Arpaidflag = 'N'
         AND Aroutflag = 'N'
         AND Arje > 0
         FOR UPDATE;
  
    CURSOR c_Rd IS
      SELECT * FROM Ys_Zw_Ardetail WHERE Ardid = p_Arsplitdt.Rec_Id FOR UPDATE;
  
    CURSOR c_Rdf IS
      SELECT * FROM Ys_Zw_Ardetail_Fz WHERE Ardid = p_Arsplitdt.Rec_Id FOR UPDATE;
    Ar      Ys_Zw_Arlist%ROWTYPE;
    Rd      Ys_Zw_Ardetail%ROWTYPE;
    Arf     Ys_Zw_Arlist_Fz%ROWTYPE;
    Rdf     Ys_Zw_Ardetail_Fz%ROWTYPE;
    v_Arid  VARCHAR2(20);
    v_Arid2 VARCHAR2(20);
    v_Count NUMBER(10);
    v_Scode NUMBER(10);
    v_Ecode NUMBER(10);
  
  BEGIN
    NULL;
    --1、调用过程检查要分拆水量
    OPEN c_Ar;
    FETCH c_Ar
      INTO Ar;
    IF c_Ar%NOTFOUND OR c_Ar%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode,
                              '应收账务不存在,或不是正常欠费,流水号:' || p_Arsplitdt.Rec_Id || '请检查！');
    END IF;
    CLOSE c_Ar;
    --p_Sl := Sf_Recfzsl(p_Arid, p_Je);
  
    IF p_Arsplitdt.Water1 + p_Arsplitdt.Water2 <> Ar.Arsl THEN
      Raise_Application_Error(Errcode,
                              '分账水量必须小于' || Ar.Arsl || ',流水号:' || Ar.Arid);
    END IF;
  
    --2、将要分账 备份 
    Arf := Ar; --备份原账务
    INSERT INTO Ys_Zw_Arlist_Fz VALUES Ar;
    OPEN c_Rd;
    LOOP
      FETCH c_Rd
        INTO Rd;
      EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
      INSERT INTO Ys_Zw_Ardetail_Fz VALUES Rd;
    END LOOP;
    CLOSE c_Rd;
  
    --YS_ZW_ARDETAIL插入分账第一笔
    
    SELECT Lpad(Seq_Arid.Nextval, 10, '0') INTO v_Arid FROM Dual;
    SELECT Lpad(Seq_Arid.Nextval, 10, '0') INTO v_Arid2 FROM Dual;
    
    -- 备份起止码
    v_Scode := Ar.Arscode;
    v_Ecode := Ar.Arecode;
  
    --ys_zw_arlist插入分账第一笔
    SELECT Uuid() INTO Ar.Id FROM Dual;
  
    Ar.Hire_Code := f_Get_Hire_Code();
    Ar.Manage_No := Arf.Manage_No;
    Ar.Arid      := TRIM(v_Arid);
    Ar.Armonth   := Fobtmanapara(Arf.Manage_No, 'READ_MONTH');
    Ar.Ardate    := Trunc(SYSDATE);
  
    Ar.Arcolumn5  := Arf.Ardate; --上次应帐帐日期
    Ar.Arcolumn9  := Arf.Arid; --上次应收帐流水
    Ar.Arcolumn10 := Arf.Armonth; --上次应收帐月份
    Ar.Arcolumn11 := Arf.Artrans; --上次应收帐事务
    Ar.Artrans    := 'C';
    /*ar.arSCRarID    := arF.arID; --原账务应收流水
    ar.arSCRarTRANS := arF.arTRANS; --原账务事物
    ar.arSCRarMONTH := arF.arMONTH; --原账务月份
    ar.arSCRarDATE  := arF.arDATE;  --原账务日期*/ 
    Ar.Arsl     := p_Arsplitdt.Water1;
    Ar.Arje     := p_Arsplitdt.Charge_Amt1;
    Ar.Arreadsl :=  p_Arsplitdt.Water1;
  
    --第一笔账起码不变，止码为起码加上应收水量 20140318
    Ar.Arscode     := v_Scode;
    Ar.Arscodechar := To_Char(Ar.Arscode);
    Ar.Arecode     := v_Scode + Ar.Arsl;
    Ar.Arecodechar := To_Char(Ar.Arecode);
    INSERT INTO Ys_Zw_Arlist VALUES Ar;
  
    --ys_zw_arlist插入分账第二笔 
    SELECT Uuid() INTO Ar.Id FROM Dual;
    Ar.Hire_Code := f_Get_Hire_Code();
    Ar.Manage_No := Arf.Manage_No;
    Ar.Arid      := TRIM(v_Arid2);
    Ar.Armonth   := Fobtmanapara(Arf.Manage_No, 'READ_MONTH');
    Ar.Ardate    := Trunc(SYSDATE);
  
    Ar.Arsl     := p_Arsplitdt.Water2;
    Ar.Arje     := p_Arsplitdt.Charge_Amt2;
    Ar.Arreadsl :=  p_Arsplitdt.Water2;
  
    --第二笔账止码不变，起码为止码减去应收水量 20140318
    Ar.Arscode     := v_Ecode - Ar.Arsl;
    Ar.Arscodechar := To_Char(Ar.Arscode);
    Ar.Arecode     := v_Ecode;
    Ar.Arecodechar := To_Char(Ar.Arecode);
  
    INSERT INTO Ys_Zw_Arlist VALUES Ar;
   
   OPEN c_Rdf;
    LOOP
      FETCH c_Rdf
        INTO Rd;
      EXIT WHEN c_Rdf%NOTFOUND OR c_Rdf%NOTFOUND IS NULL;
       
      --第一笔明细    
      Rd.Ardid   := TRIM(v_Arid);
      Rd.Ardyssl := p_Arsplitdt.Water1;
      Rd.Ardsl   := p_Arsplitdt.Water1;
      Rd.Ardysje := Rd.Ardysdj * Rd.Ardyssl;
      Rd.Ardje   := Rd.Arddj * Rd.Ardsl;
      INSERT INTO Ys_Zw_Ardetail VALUES Rd; --第一笔明细 
      --生成第二笔明细
      Rd.Ardid   := TRIM(v_Arid2);
      Rd.Ardyssl := p_Arsplitdt.Water2;
      Rd.Ardsl   := p_Arsplitdt.Water2;
      Rd.Ardysje := Rd.Ardysdj * Rd.Ardyssl;
      Rd.Ardje   := Rd.Arddj * Rd.Ardsl;
      INSERT INTO Ys_Zw_Ardetail VALUES Rd; 
    END LOOP;
    CLOSE c_Rdf;
    --5、检查一下分拆两条应收后水量与金额这与与原帐 ys_zw_arlist_fz,YS_ZW_ARDETAIL_fz 是否相同
    --SELECT * INTO arF FROM ys_zw_arlist_FZ WHERE
    SELECT COUNT(*)
      INTO v_Count
      FROM (SELECT Arsl, Arje
              FROM Ys_Zw_Arlist_Fz
             WHERE Arid = p_Arsplitdt.Rec_Id
            MINUS
            SELECT SUM(Arsl), SUM(Arje)
              FROM Ys_Zw_Arlist
             WHERE Arid IN (TRIM(v_Arid), TRIM(v_Arid2)));
    IF v_Count > 0 THEN
      Raise_Application_Error(Errcode, '分账总金额错误！');
    END IF;
  
    SELECT COUNT(*)
      INTO v_Count
      FROM (SELECT Ardsl, Ardje
              FROM Ys_Zw_Ardetail_Fz
             WHERE Ardid = p_Arsplitdt.Rec_Id
            MINUS
            SELECT SUM(Ardsl), SUM(Ardje)
              FROM Ys_Zw_Ardetail
             WHERE Ardid IN (TRIM(v_Arid), TRIM(v_Arid2))
             GROUP BY Ardpmdid, Ardpiid, Ardpfid, Ardclass);
  
    IF v_Count > 0 THEN
      Raise_Application_Error(Errcode, '分账明细金额错误！');
    END IF;
  
    --5冲原应收帐
    Sp_Reccz_One_01(p_Arsplitdt.Rec_Id, p_Commit);
    --O_RET := 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      IF c_Rdf%ISOPEN THEN
        CLOSE c_Rdf;
      END IF;
      ROLLBACK;
      --O_RET :='N';
      Raise_Application_Error(Errcode, SQLERRM);
  END;

  --插入单负应收与应收冲正 --单条  
  PROCEDURE Sp_Reccz_One_01(p_Arid   IN Ys_Zw_Arlist.Arid%TYPE, --  行变量
                            p_Commit IN VARCHAR --是否提交标志
                            ) AS
  
    Arde Ys_Zw_Arlist%ROWTYPE;
    Arcr Ys_Zw_Arlist%ROWTYPE;
    Rd   Ys_Zw_Ardetail%ROWTYPE;
    Rdcr Ys_Zw_Ardetail%ROWTYPE;
    CURSOR c_Ar IS
      SELECT *
        FROM Ys_Zw_Arlist
       WHERE Arid = p_Arid
         AND Arpaidflag = 'N'
         AND Arreverseflag = 'N'
         AND Arbadflag = 'N'
         FOR UPDATE NOWAIT;
  
    CURSOR c_Rd IS
      SELECT *
        FROM Ys_Zw_Ardetail
       WHERE Ardid = Arde.Arid
         AND Ardpaidflag = 'N'
         FOR UPDATE NOWAIT;
  
  BEGIN
    OPEN c_Ar;
    FETCH c_Ar
      INTO Arde;
    IF c_Ar%NOTFOUND OR c_Ar%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode,
                              '应收账务不存在,或不是正常欠费,流水号:' || p_Arid || '请检查！');
    END IF;
    CLOSE c_Ar;
    --将被冲应收产生对应的负帐
    Arcr := Arde;
  
    --贷帐头赋值
    /*arCR.arSCRarID    := arCR.arID;
    arCR.arSCRarTRANS := arCR.arTRANS;
    arCR.arSCRarMONTH := arCR.arMONTH;
    arCR.arSCRarDATE  := arCR.arDATE;*/
    Arcr.Arcolumn5  := Arcr.Ardate; --上次应帐帐日期
    Arcr.Arcolumn9  := Arcr.Arid; --上次应收帐流水
    Arcr.Arcolumn10 := Arcr.Armonth; --上次应收帐月份
    Arcr.Arcolumn11 := Arcr.Artrans; --上次应收帐事务
  
    SELECT Uuid() INTO Arcr.Id FROM Dual;
    --arCR.HIRE_CODE     := arDE.HIRE_CODE;
    Arcr.Arid := Lpad(Seq_Arid.Nextval, 10, '0');
    --arCR.MANAGE_NO     := arDE.MANAGE_NO;
    Arcr.Armonth := Fobtmanapara(Arde.Manage_No, 'READ_MONTH');
    Arcr.Ardate  := Trunc(SYSDATE);
  
    Arcr.Arcd       := Pg_Cb_Cost.Credit;
    Arcr.Artrans    := Arde.Artrans;
    Arcr.Ardatetime := SYSDATE;
    Arcr.Arpaidflag := 'N';
    --
    Arcr.Arsl     := 0 - Arcr.Arsl;
    Arcr.Arje     := 0 - Arcr.Arje;
    Arcr.Araddsl  := 0 - Arcr.Araddsl;
    Arcr.Arpaidje := 0 - Arcr.Arpaidje;
    --数据
    Arcr.Arsavingqc := 0 - Arcr.Arsavingqc;
    Arcr.Arsavingbq := 0 - Arcr.Arsavingbq;
    Arcr.Arsavingqm := 0 - Arcr.Arsavingqm;
    Arcr.Arsxf      := 0 - Arcr.Arsxf;
  
    Arcr.Armemo        := Arde.Armemo;
    Arcr.Arreverseflag := 'Y';
  
    --贷帐体赋值,同时更新待冲目标应收明细销帐标志
    OPEN c_Rd;
    LOOP
      FETCH c_Rd
        INTO Rd;
      /*if c_rd%notfound or c_rd%notfound is null then
        raise_application_error(errcode,
                                  '无效的待冲正应收记录：无此应收费用明细');
      end if;*/
      EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
      SELECT Uuid() INTO Rdcr.Id FROM Dual;
      Rdcr.Hire_Code     := Arcr.Hire_Code;
      Rdcr.Ardid         := NULL;
      Rdcr.Ardid         := Arcr.Arid;
      Rdcr.Ardpmdid      := Rd.Ardpmdid;
      Rdcr.Ardpiid       := Rd.Ardpiid;
      Rdcr.Ardpfid       := Rd.Ardpfid;
      Rdcr.Ardpscid      := Rd.Ardpscid;
      Rdcr.Ardclass      := Rd.Ardclass;
      Rdcr.Ardysdj       := Rd.Ardysdj;
      Rdcr.Ardyssl       := 0 - Rd.Ardyssl;
      Rdcr.Ardysje       := 0 - Rd.Ardysje;
      Rdcr.Arddj         := Rd.Arddj;
      Rdcr.Ardsl         := 0 - Rd.Ardsl;
      Rdcr.Ardje         := 0 - Rd.Ardje;
      Rdcr.Ardadjdj      := Rd.Ardadjdj;
      Rdcr.Ardadjsl      := 0 - Rd.Ardadjsl;
      Rdcr.Ardadjje      := 0 - Rd.Ardadjje;
      Rdcr.Ardmethod     := Rd.Ardmethod;
      Rdcr.Ardpaidflag   := Rd.Ardpaidflag;
      Rdcr.Ardpaiddate   := Rd.Ardpaiddate;
      Rdcr.Ardpaidmonth  := Rd.Ardpaidmonth;
      Rdcr.Ardpaidper    := Rd.Ardpaidper;
      Rdcr.Ardpmdscale   := Rd.Ardpmdscale;
      Rdcr.Ardilid       := Rd.Ardilid;
      Rdcr.Ardznj        := 0 - Rd.Ardznj;
      Rdcr.Ardmemo       := Rd.Ardmemo;
      Rdcr.Ardmsmfid     := Rd.Ardmsmfid;
      Rdcr.Ardmonth      := Rd.Ardmonth;
      Rdcr.Ardmid        := Rd.Ardmid;
      Rdcr.Ardpmdtype    := Rd.Ardpmdtype;
      Rdcr.Ardpmdcolumn1 := Rd.Ardpmdcolumn1;
      Rdcr.Ardpmdcolumn2 := Rd.Ardpmdcolumn2;
      Rdcr.Ardpmdcolumn3 := Rd.Ardpmdcolumn3;
      INSERT INTO Ys_Zw_Ardetail VALUES Rdcr;
    
    END LOOP;
    CLOSE c_Rd;
    --插入贷帐头、帐体
    INSERT INTO Ys_Zw_Arlist VALUES Arcr;
  
    --更新最近水量(如果冲正的恰好最近时)
    UPDATE Ys_Zw_Arlist SET Arreverseflag = 'Y' WHERE Arid = p_Arid;
    --排除拆账单
    IF Arde.Artrans <> '3' THEN
      UPDATE Ys_Yh_Sbinfo
         SET Sbrecsl = 0
       WHERE Sbid = Arcr.Sbid
         AND Sbrecdate = Arcr.Arrdate;
    
      IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
        NULL;
      END IF;
    END IF;
  
    IF p_Commit = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Sp_Reccz_One_01;

  --应收分账处理 BY sp_recfzsl by wy  20130324
  --输入应收流水，分帐金额，
  --返回分帐水量
  --1按水量乘单价分
  --2分到不足一吨水为止
  --3从高水量减起减到水量为1吨为止
  --

  FUNCTION Sf_Recfzsl(p_Arid IN VARCHAR2, --分帐流水
                      p_Arje IN NUMBER --分帐金额
                      ) RETURN NUMBER AS
    v_Maxsl Ys_Zw_Arlist.Arsl%TYPE;
    v_Maxje Ys_Zw_Arlist.Arje%TYPE;
    v_Fzje  Ys_Zw_Arlist.Arje%TYPE;
    v_Jlje  Ys_Zw_Arlist.Arje%TYPE;
    v_Jlje1 Ys_Zw_Arlist.Arje%TYPE;
    Pb      Ysparmtemp%ROWTYPE;
    v_Czsl  Ys_Zw_Arlist.Arsl%TYPE;
  
    --需拆分 费用分组、水量、金额   应拆金额
    v_Cfz   Ys_Zw_Ardetail.Ardpmdid%TYPE;
    v_Csl   Ys_Zw_Ardetail.Ardsl%TYPE;
    v_Cje   Ys_Zw_Ardetail.Ardje%TYPE;
    v_Carje Ys_Zw_Ardetail.Ardje%TYPE;
  
    CURSOR c_Rd IS
      SELECT To_Char(Ardpmdid),
             To_Char(MAX(Nvl(Ardsl, 0))) Ardsl,
             To_Char(SUM(Nvl(Ardje, 0)))
        FROM Ys_Zw_Ardetail
       WHERE Ardid = p_Arid
       GROUP BY Ardpmdid
       ORDER BY Ardpmdid;
  
  BEGIN
    --1、取总水量
    /*SELECT SUM (ardsl) INTO v_maxsl FROM
    (
      select ARDPMDID,max(nvl(ardsl,0)) ardsl
      from YS_ZW_ARDETAIL
      where aARDID=p_arid
      GROUP BY ARDPMDID
    );*/
    /*
    PB 表金额组成结构
    拆分金额120
    
    A B C表示行
    行号  分组C1   水量C2   金额C3  拆分水量C4  拆分金额C5 行拆分水量标志C6（1表示需要计算拆分水量）
    A      0        30       90       30         90          0
    B      1        50       150      10         30          1
    C      2        60       180      0          0           0
    */
    --分类获取水量金额
    --该步骤C5拆分金额为可拆分金额
    v_Fzje  := p_Arje;
    v_Maxsl := 0;
    v_Maxje := 0;
    OPEN c_Rd;
    LOOP
      FETCH c_Rd
        INTO Pb.C1, Pb.C2, Pb.C3;
      EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
      v_Maxsl := v_Maxsl + To_Number(Nvl(Pb.C2, 0));
      v_Maxje := v_Maxje + To_Number(Nvl(Pb.C3, 0));
      IF v_Fzje = 0 THEN
        Pb.C4 := '0';
        Pb.C5 := '0';
        Pb.C6 := '0';
      ELSIF v_Fzje >= To_Number(Nvl(Pb.C3, 0)) THEN
        v_Fzje := v_Fzje - To_Number(Nvl(Pb.C3, 0));
        Pb.C4  := Pb.C2;
        Pb.C5  := Pb.C3;
        Pb.C6  := '0';
      ELSE
        Pb.C5  := To_Char(Nvl(v_Fzje, 0));
        Pb.C6  := '1';
        v_Fzje := 0;
      END IF;
      INSERT INTO Ysparmtemp VALUES Pb;
    
    END LOOP;
    CLOSE c_Rd;
  
    --拆分金额如果大于金额，不允许拆分
    IF p_Arje >= v_Maxje OR p_Arje <= 0 OR v_Maxje <= 0 OR v_Maxsl <= 0 THEN
      RETURN - 1;
    END IF;
  
    --根据C6取拆分数据行
    --该部分（C4拆账水量）、（C5拆账金额）为应拆账水量、金额
    BEGIN
      SELECT * INTO Pb FROM Ysparmtemp WHERE TRIM(C6) = '1';
      v_Cfz   := To_Number(TRIM(Pb.C1));
      v_Csl   := To_Number(TRIM(Pb.C2));
      v_Cje   := To_Number(TRIM(Pb.C3));
      v_Carje := To_Number(TRIM(Pb.C5));
      v_Czsl  := 0;
    
      FOR i IN 1 .. v_Csl LOOP
        SELECT SUM(Arddj) * i, SUM(Arddj) * (i - 1)
          INTO v_Jlje, v_Jlje1
          FROM Ys_Zw_Ardetail t
         WHERE Ardid = p_Arid
           AND Ardpmdid = v_Cfz;
        /*if v_jlje<=0 then
          return -1 ;
        end if;*/
        IF v_Carje >= v_Jlje THEN
          v_Czsl := i;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    
      UPDATE Ysparmtemp
         SET C4 = To_Char(v_Czsl), C5 = To_Char(v_Jlje1)
       WHERE TRIM(C1) = To_Char(v_Cfz)
         AND TRIM(C6) = '1';
    EXCEPTION
      WHEN OTHERS THEN
        --无需计算水量金额，拆账金额正好匹配
        RETURN v_Maxsl;
    END;
  
    RETURN 1;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN - 999;
  END;

END;
/

