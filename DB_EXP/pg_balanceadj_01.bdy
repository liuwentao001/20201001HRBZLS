CREATE OR REPLACE PACKAGE BODY Pg_Balanceadj_01 IS
  /*====================================================================
  -- Name: Pg_BALANCEADJ_01.Approve
  -- Author:  � Gary 190388857@qq.com    date: 2020��11��11��
  ----------------------------------------------------------------------
  -- Description: ���������̰�,�����ύ��ڹ���
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
  
    IF p_Djlb = '36' OR p_Djlb = '39' THEN
      --36Ԥ������˷�����  39Ԥ�������˷�����
      Sp_Balanceadj(p_Billno, p_Person, 'Y');
    ELSE
      Raise_Application_Error(Errcode, p_Billno || '->1 ��Ч�ĵ������');
    END IF;
  END;

  /*====================================================================
  -- Name: Pg_BALANCEADJ_01.Sp_Balanceadj
  -- Author:  � Gary 190388857@qq.com    date: 2020��11��11��
  ----------------------------------------------------------------------
  -- Description: ���������̰�,������
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved.
  ----------------------------------------------------------------------
  -- �޸���ʷ:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   �      ����
  --====================================================================*/
  PROCEDURE Sp_Balanceadj(p_Bill_Id IN VARCHAR2, --������ˮ
                          p_Per     IN VARCHAR2, --����Ա
                          p_Commit  IN VARCHAR2 --�ύ��־
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
        Raise_Application_Error(Errcode, '�����ͷ��Ϣ������!');
    END;
  
    IF Znjhd.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '����������,��������!');
    END IF;
    IF Znjhd.Check_Flag = 'Q' THEN
      Raise_Application_Error(Errcode, '�������ȡ��,������!');
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
        Raise_Application_Error(Errcode, '�޴��û�');
      END IF;
      CLOSE c_Custinfo;
    
      OPEN c_Meterinfo(Znjdt.Yhid);
      FETCH c_Meterinfo
        INTO Mi;
      IF c_Meterinfo%NOTFOUND OR c_Meterinfo%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode, '�޴�ˮ��');
      END IF;
      CLOSE c_Meterinfo;
    
      IF Mi.Sbsaving + Znjdt.Adjust_Balance < 0 THEN
        Raise_Application_Error(Errcode,
                                '�ڴ˹���������û�[' || Znjdt.Yhid ||
                                ']��Ԥ������,����ɸ�Ԥ��,��˲�!');
      END IF;
      IF Mi.Sbsaving <> Znjdt.Balance THEN
        Raise_Application_Error(Errcode,
                                '�ڴ˹���������û�[' || Znjdt.Yhid ||
                                ']��Ԥ������ѱ�����,��˲�!');
      END IF;
      --�ж��Ƿ���Ƿ��
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
                                '�ڴ˹���������û�[' || Znjdt.Yhid || ']��Ƿ��,��˲�!');
      END IF;
    
      IF Znjdt.Change_Type = '36' THEN
        c_Ptrans := 'y';
        --yc.ycnote := 'Ԥ������˷�����';
      ELSIF Znjdt.Change_Type = '39' THEN
        c_Ptrans := 'Y';
        --yc.ycnote := 'Ԥ�������˷�����';
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

