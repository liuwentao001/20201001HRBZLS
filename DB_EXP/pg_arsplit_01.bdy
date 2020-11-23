CREATE OR REPLACE PACKAGE BODY Pg_Arsplit_01 IS
  /*====================================================================
  -- Name: Pg_ARSPLIT_01.Approve
  -- Author:  � Gary 190388857@qq.com    date: 2020��11��11��
  ----------------------------------------------------------------------
  -- Description: ����˵����̰�,�����ύ��ڹ���
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved.
  ----------------------------------------------------------------------
  -- �޸���ʷ:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   �      ����
  --====================================================================*/
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2) IS
  BEGIN
  
    IF p_Djlb = '3' THEN
      Sp_Arsplit(p_Billno, p_Person, 'Y');
    ELSE
      Raise_Application_Error(Errcode, p_Billno || '->1 ��Ч�ĵ������');
    END IF;
  END;
  --���˹���
  PROCEDURE Sp_Recfzrlid(p_Arid IN VARCHAR2, --������ˮ
                         p_Je   IN NUMBER --���˽��
                         
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
    --1�����ù��̼��Ҫ�ֲ�ˮ��
    OPEN c_Ar;
    FETCH c_Ar
      INTO Ar;
    IF c_Ar%NOTFOUND OR c_Ar%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode,
                              'Ӧ�����񲻴���,��������Ƿ��,��ˮ��:' || p_Arid || '���飡');
    END IF;
    CLOSE c_Ar;
    p_Sl := Sf_Recfzsl(p_Arid, p_Je);
  
    IF p_Sl <= 0 THEN
      Raise_Application_Error(Errcode,
                              '����ˮ������С��' || Ar.Arsl || ',��ˮ��:' || Ar.Arid);
    END IF;
  
    --2����Ҫ���� ���� 
    Arf := Ar; --����ԭ����
    INSERT INTO Ys_Zw_Arlist_Fz VALUES Ar;
    OPEN c_Rd;
    LOOP
      FETCH c_Rd
        INTO Rd;
      EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
      INSERT INTO Ys_Zw_Ardetail_Fz VALUES Rd;
    END LOOP;
    CLOSE c_Rd;
  
    --YS_ZW_ARDETAIL������˵�һ��
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
      --��ȡ��ʱ���е�ˮ��
      SELECT * INTO Pb FROM Ysparmtemp p WHERE TRIM(p.C1) = Rd.Ardpmdid;
      p_Sl  := To_Number(TRIM(Pb.C4));
      v_Sl2 := Rd.Ardsl - p_Sl; --�ڶ�����ϸˮ��
      v_Je2 := Rd.Ardje;
      --��һ����ϸ
    
      Rd.Ardid   := TRIM(v_Arid);
      Rd.Ardyssl := p_Sl;
      Rd.Ardsl   := p_Sl;
      Rd.Ardysje := Rd.Ardysdj * Rd.Ardyssl;
      Rd.Ardje   := Rd.Arddj * Rd.Ardsl;
      INSERT INTO Ys_Zw_Ardetail VALUES Rd; --��һ����ϸ
      v_Je  := v_Je + Rd.Ardje; --��һ��Ӧ�պϼƽ��
      v_Je2 := v_Je2 - Rd.Ardje; --�ڶ�����ϸ���
      --���ɵڶ�����ϸ
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
  
    -- ������ֹ��
    v_Scode := Ar.Arscode;
    v_Ecode := Ar.Arecode;
  
    --ys_zw_arlist������˵�һ��
    SELECT Uuid() INTO Ar.Id FROM Dual;
  
    Ar.Hire_Code := f_Get_Hire_Code();
    Ar.Manage_No := Arf.Manage_No;
    Ar.Arid      := TRIM(v_Arid);
    Ar.Armonth   := Fobtmanapara(Arf.Manage_No, 'READ_MONTH');
    Ar.Ardate    := Trunc(SYSDATE);
  
    Ar.Arcolumn5  := Arf.Ardate; --�ϴ�Ӧ��������
    Ar.Arcolumn9  := Arf.Arid; --�ϴ�Ӧ������ˮ
    Ar.Arcolumn10 := Arf.Armonth; --�ϴ�Ӧ�����·�
    Ar.Arcolumn11 := Arf.Artrans; --�ϴ�Ӧ��������
    Ar.Artrans    := 'C';
    /*ar.arSCRarID    := arF.arID; --ԭ����Ӧ����ˮ
    ar.arSCRarTRANS := arF.arTRANS; --ԭ��������
    ar.arSCRarMONTH := arF.arMONTH; --ԭ�����·�
    ar.arSCRarDATE  := arF.arDATE;  --ԭ��������*/
    SELECT SUM(To_Number(Nvl(TRIM(C4), 0))) INTO v_Czsl FROM Ysparmtemp;
    Ar.Arsl     := v_Czsl;
    Ar.Arje     := v_Je;
    Ar.Arreadsl := v_Czsl;
  
    --��һ�������벻�䣬ֹ��Ϊ�������Ӧ��ˮ�� 20140318
    Ar.Arscode     := v_Scode;
    Ar.Arscodechar := To_Char(Ar.Arscode);
    Ar.Arecode     := v_Scode + Ar.Arsl;
    Ar.Arecodechar := To_Char(Ar.Arecode);
    INSERT INTO Ys_Zw_Arlist VALUES Ar;
  
    --ys_zw_arlist������˵ڶ��� 
    SELECT Uuid() INTO Ar.Id FROM Dual;
    Ar.Hire_Code := f_Get_Hire_Code();
    Ar.Manage_No := Arf.Manage_No;
    Ar.Arid      := TRIM(v_Arid2);
    Ar.Armonth   := Fobtmanapara(Arf.Manage_No, 'READ_MONTH');
    Ar.Ardate    := Trunc(SYSDATE);
  
    Ar.Arsl     := v_Sls2 - v_Czsl;
    Ar.Arje     := v_Jes2;
    Ar.Arreadsl := v_Sls2 - v_Czsl;
  
    --�ڶ�����ֹ�벻�䣬����Ϊֹ���ȥӦ��ˮ�� 20140318
    Ar.Arscode     := v_Ecode - Ar.Arsl;
    Ar.Arscodechar := To_Char(Ar.Arscode);
    Ar.Arecode     := v_Ecode;
    Ar.Arecodechar := To_Char(Ar.Arecode);
  
    INSERT INTO Ys_Zw_Arlist VALUES Ar;
  
    --5�����һ�·ֲ�����Ӧ�պ�ˮ������������ԭ�� ys_zw_arlist_fz,YS_ZW_ARDETAIL_fz �Ƿ���ͬ
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
      Raise_Application_Error(Errcode, '�����ܽ�����');
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
      Raise_Application_Error(Errcode, '������ϸ������');
    END IF;
  
    --5��ԭӦ����
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
  -- Author:  � Gary 190388857@qq.com    date: 2020��11��11��
  ----------------------------------------------------------------------
  -- Description: ����˵����̰�,����˵�
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved.
  ----------------------------------------------------------------------
  -- �޸���ʷ:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   �      ����
  --====================================================================*/

  PROCEDURE Sp_Arsplit(p_Bill_Id IN VARCHAR2, --������ˮ
                       p_Per     IN VARCHAR2, --����Ա
                       p_Commit  IN VARCHAR2 --�ύ��־
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
    --��鵥ͷ
    OPEN c_Hd;
    FETCH c_Hd
      INTO Hd;
    IF c_Hd%NOTFOUND OR c_Hd%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '���ݲ�����' || p_Bill_Id);
    END IF;
    CLOSE c_Hd;
    --��鵥��
    OPEN c_Dt;
    LOOP
      FETCH c_Dt
        INTO Dt;
      EXIT WHEN c_Dt%NOTFOUND OR c_Dt%NOTFOUND IS NULL;
      Sp_Arsplit_change_one(Dt, p_Per, p_Commit);
      --Sp_Recfzrlid(c_Dt.REC_ID,c_Dt.CHARGE_AMT1);
      IF v_Ret = 'N' THEN
        Raise_Application_Error(Errcode,
                                '���˴���,������ˮ:' || Dt.Rec_Id || '|Ӧ�ս��:' ||
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
                                   p_Per     IN VARCHAR2, --����Ա
                                   p_Commit  IN VARCHAR2 --�ύ��־
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
    --1�����ù��̼��Ҫ�ֲ�ˮ��
    OPEN c_Ar;
    FETCH c_Ar
      INTO Ar;
    IF c_Ar%NOTFOUND OR c_Ar%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode,
                              'Ӧ�����񲻴���,��������Ƿ��,��ˮ��:' || p_Arsplitdt.Rec_Id || '���飡');
    END IF;
    CLOSE c_Ar;
    --p_Sl := Sf_Recfzsl(p_Arid, p_Je);
  
    IF p_Arsplitdt.Water1 + p_Arsplitdt.Water2 <> Ar.Arsl THEN
      Raise_Application_Error(Errcode,
                              '����ˮ������С��' || Ar.Arsl || ',��ˮ��:' || Ar.Arid);
    END IF;
  
    --2����Ҫ���� ���� 
    Arf := Ar; --����ԭ����
    INSERT INTO Ys_Zw_Arlist_Fz VALUES Ar;
    OPEN c_Rd;
    LOOP
      FETCH c_Rd
        INTO Rd;
      EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
      INSERT INTO Ys_Zw_Ardetail_Fz VALUES Rd;
    END LOOP;
    CLOSE c_Rd;
  
    --YS_ZW_ARDETAIL������˵�һ��
    
    SELECT Lpad(Seq_Arid.Nextval, 10, '0') INTO v_Arid FROM Dual;
    SELECT Lpad(Seq_Arid.Nextval, 10, '0') INTO v_Arid2 FROM Dual;
    
    -- ������ֹ��
    v_Scode := Ar.Arscode;
    v_Ecode := Ar.Arecode;
  
    --ys_zw_arlist������˵�һ��
    SELECT Uuid() INTO Ar.Id FROM Dual;
  
    Ar.Hire_Code := f_Get_Hire_Code();
    Ar.Manage_No := Arf.Manage_No;
    Ar.Arid      := TRIM(v_Arid);
    Ar.Armonth   := Fobtmanapara(Arf.Manage_No, 'READ_MONTH');
    Ar.Ardate    := Trunc(SYSDATE);
  
    Ar.Arcolumn5  := Arf.Ardate; --�ϴ�Ӧ��������
    Ar.Arcolumn9  := Arf.Arid; --�ϴ�Ӧ������ˮ
    Ar.Arcolumn10 := Arf.Armonth; --�ϴ�Ӧ�����·�
    Ar.Arcolumn11 := Arf.Artrans; --�ϴ�Ӧ��������
    Ar.Artrans    := 'C';
    /*ar.arSCRarID    := arF.arID; --ԭ����Ӧ����ˮ
    ar.arSCRarTRANS := arF.arTRANS; --ԭ��������
    ar.arSCRarMONTH := arF.arMONTH; --ԭ�����·�
    ar.arSCRarDATE  := arF.arDATE;  --ԭ��������*/ 
    Ar.Arsl     := p_Arsplitdt.Water1;
    Ar.Arje     := p_Arsplitdt.Charge_Amt1;
    Ar.Arreadsl :=  p_Arsplitdt.Water1;
  
    --��һ�������벻�䣬ֹ��Ϊ�������Ӧ��ˮ�� 20140318
    Ar.Arscode     := v_Scode;
    Ar.Arscodechar := To_Char(Ar.Arscode);
    Ar.Arecode     := v_Scode + Ar.Arsl;
    Ar.Arecodechar := To_Char(Ar.Arecode);
    INSERT INTO Ys_Zw_Arlist VALUES Ar;
  
    --ys_zw_arlist������˵ڶ��� 
    SELECT Uuid() INTO Ar.Id FROM Dual;
    Ar.Hire_Code := f_Get_Hire_Code();
    Ar.Manage_No := Arf.Manage_No;
    Ar.Arid      := TRIM(v_Arid2);
    Ar.Armonth   := Fobtmanapara(Arf.Manage_No, 'READ_MONTH');
    Ar.Ardate    := Trunc(SYSDATE);
  
    Ar.Arsl     := p_Arsplitdt.Water2;
    Ar.Arje     := p_Arsplitdt.Charge_Amt2;
    Ar.Arreadsl :=  p_Arsplitdt.Water2;
  
    --�ڶ�����ֹ�벻�䣬����Ϊֹ���ȥӦ��ˮ�� 20140318
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
       
      --��һ����ϸ    
      Rd.Ardid   := TRIM(v_Arid);
      Rd.Ardyssl := p_Arsplitdt.Water1;
      Rd.Ardsl   := p_Arsplitdt.Water1;
      Rd.Ardysje := Rd.Ardysdj * Rd.Ardyssl;
      Rd.Ardje   := Rd.Arddj * Rd.Ardsl;
      INSERT INTO Ys_Zw_Ardetail VALUES Rd; --��һ����ϸ 
      --���ɵڶ�����ϸ
      Rd.Ardid   := TRIM(v_Arid2);
      Rd.Ardyssl := p_Arsplitdt.Water2;
      Rd.Ardsl   := p_Arsplitdt.Water2;
      Rd.Ardysje := Rd.Ardysdj * Rd.Ardyssl;
      Rd.Ardje   := Rd.Arddj * Rd.Ardsl;
      INSERT INTO Ys_Zw_Ardetail VALUES Rd; 
    END LOOP;
    CLOSE c_Rdf;
    --5�����һ�·ֲ�����Ӧ�պ�ˮ������������ԭ�� ys_zw_arlist_fz,YS_ZW_ARDETAIL_fz �Ƿ���ͬ
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
      Raise_Application_Error(Errcode, '�����ܽ�����');
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
      Raise_Application_Error(Errcode, '������ϸ������');
    END IF;
  
    --5��ԭӦ����
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

  --���뵥��Ӧ����Ӧ�ճ��� --����  
  PROCEDURE Sp_Reccz_One_01(p_Arid   IN Ys_Zw_Arlist.Arid%TYPE, --  �б���
                            p_Commit IN VARCHAR --�Ƿ��ύ��־
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
                              'Ӧ�����񲻴���,��������Ƿ��,��ˮ��:' || p_Arid || '���飡');
    END IF;
    CLOSE c_Ar;
    --������Ӧ�ղ�����Ӧ�ĸ���
    Arcr := Arde;
  
    --����ͷ��ֵ
    /*arCR.arSCRarID    := arCR.arID;
    arCR.arSCRarTRANS := arCR.arTRANS;
    arCR.arSCRarMONTH := arCR.arMONTH;
    arCR.arSCRarDATE  := arCR.arDATE;*/
    Arcr.Arcolumn5  := Arcr.Ardate; --�ϴ�Ӧ��������
    Arcr.Arcolumn9  := Arcr.Arid; --�ϴ�Ӧ������ˮ
    Arcr.Arcolumn10 := Arcr.Armonth; --�ϴ�Ӧ�����·�
    Arcr.Arcolumn11 := Arcr.Artrans; --�ϴ�Ӧ��������
  
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
    --����
    Arcr.Arsavingqc := 0 - Arcr.Arsavingqc;
    Arcr.Arsavingbq := 0 - Arcr.Arsavingbq;
    Arcr.Arsavingqm := 0 - Arcr.Arsavingqm;
    Arcr.Arsxf      := 0 - Arcr.Arsxf;
  
    Arcr.Armemo        := Arde.Armemo;
    Arcr.Arreverseflag := 'Y';
  
    --�����帳ֵ,ͬʱ���´���Ŀ��Ӧ����ϸ���ʱ�־
    OPEN c_Rd;
    LOOP
      FETCH c_Rd
        INTO Rd;
      /*if c_rd%notfound or c_rd%notfound is null then
        raise_application_error(errcode,
                                  '��Ч�Ĵ�����Ӧ�ռ�¼���޴�Ӧ�շ�����ϸ');
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
    --�������ͷ������
    INSERT INTO Ys_Zw_Arlist VALUES Arcr;
  
    --�������ˮ��(���������ǡ�����ʱ)
    UPDATE Ys_Zw_Arlist SET Arreverseflag = 'Y' WHERE Arid = p_Arid;
    --�ų����˵�
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

  --Ӧ�շ��˴��� BY sp_recfzsl by wy  20130324
  --����Ӧ����ˮ�����ʽ�
  --���ط���ˮ��
  --1��ˮ���˵��۷�
  --2�ֵ�����һ��ˮΪֹ
  --3�Ӹ�ˮ���������ˮ��Ϊ1��Ϊֹ
  --

  FUNCTION Sf_Recfzsl(p_Arid IN VARCHAR2, --������ˮ
                      p_Arje IN NUMBER --���ʽ��
                      ) RETURN NUMBER AS
    v_Maxsl Ys_Zw_Arlist.Arsl%TYPE;
    v_Maxje Ys_Zw_Arlist.Arje%TYPE;
    v_Fzje  Ys_Zw_Arlist.Arje%TYPE;
    v_Jlje  Ys_Zw_Arlist.Arje%TYPE;
    v_Jlje1 Ys_Zw_Arlist.Arje%TYPE;
    Pb      Ysparmtemp%ROWTYPE;
    v_Czsl  Ys_Zw_Arlist.Arsl%TYPE;
  
    --���� ���÷��顢ˮ�������   Ӧ����
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
    --1��ȡ��ˮ��
    /*SELECT SUM (ardsl) INTO v_maxsl FROM
    (
      select ARDPMDID,max(nvl(ardsl,0)) ardsl
      from YS_ZW_ARDETAIL
      where aARDID=p_arid
      GROUP BY ARDPMDID
    );*/
    /*
    PB ������ɽṹ
    ��ֽ��120
    
    A B C��ʾ��
    �к�  ����C1   ˮ��C2   ���C3  ���ˮ��C4  ��ֽ��C5 �в��ˮ����־C6��1��ʾ��Ҫ������ˮ����
    A      0        30       90       30         90          0
    B      1        50       150      10         30          1
    C      2        60       180      0          0           0
    */
    --�����ȡˮ�����
    --�ò���C5��ֽ��Ϊ�ɲ�ֽ��
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
  
    --��ֽ��������ڽ���������
    IF p_Arje >= v_Maxje OR p_Arje <= 0 OR v_Maxje <= 0 OR v_Maxsl <= 0 THEN
      RETURN - 1;
    END IF;
  
    --����C6ȡ���������
    --�ò��֣�C4����ˮ��������C5���˽�ΪӦ����ˮ�������
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
        --�������ˮ�������˽������ƥ��
        RETURN v_Maxsl;
    END;
  
    RETURN 1;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN - 999;
  END;

END;
/

