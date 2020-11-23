CREATE OR REPLACE PACKAGE BODY Pg_Arznj_01 IS
  /*====================================================================
  -- Name: Pg_Arznj_01.Approve
  -- Author:  � Gary 190388857@qq.com    date: 2020��11��11��
  ----------------------------------------------------------------------
  -- Description: ΥԼ��������̰�,�����ύ��ڹ���
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
  
    IF p_Djlb = '7' THEN
       SP_ARZNJJM(P_BILLNO, P_PERSON, 'Y');
    ELSE
      Raise_Application_Error(Errcode, p_Billno || '->1 ��Ч�ĵ������');
    END IF;
  END;

  /*====================================================================
  -- Name: Pg_Arznj_01.Sp_Arznjjm
  -- Author:  � Gary 190388857@qq.com    date: 2020��11��11��
  ----------------------------------------------------------------------
  -- Description: ΥԼ��������̰�,���ɽ����
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved. 
  ----------------------------------------------------------------------
  -- �޸���ʷ:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   �      ����
  --====================================================================*/
  PROCEDURE Sp_Arznjjm(p_Bill_Id IN VARCHAR2, --������ˮ
                       p_Per     IN VARCHAR2, --����Ա
                       p_Commit  IN VARCHAR2 --�ύ��־
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
        Raise_Application_Error(Errcode, '�����ͷ��Ϣ������!');
    END;
    --��������
    /*    V_CHKSTR :=F_CHKZNJED( P_PER ,ZNJHD.bill_id   ) ;
    IF V_CHKSTR <>'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, V_CHKSTR);
    END IF;*/
    IF Znjhd.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '����������,��������!');
    END IF;
    IF Znjhd.Check_Flag = 'Q' THEN
      Raise_Application_Error(Errcode, '�������ȡ��,������!');
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
                                  'Ӧ����ˮ��[' || Znjdt.Rec_Id || ']������');
      END;
      IF Ar.Arcd <> 'DE' THEN
        Raise_Application_Error(Errcode,
                                '���Ϻ�[' || Ar.Armcode || ']' || Ar.Armonth || '�·�' ||
                                'Ӧ����ˮ��[' || Ar.Arid || ']�ѽ��г����������������⣡');
      END IF;
    
      IF Ar.Arpaidflag <> 'N' THEN
        Raise_Application_Error(Errcode,
                                '���Ϻ�[' || Ar.Armcode || ']' || Ar.Armonth || '�·�' ||
                                'Ӧ����ˮ��[' || Ar.Arid || ']��Ϊ����״̬�����������⣡');
      END IF;
    
      /*IF AR.AROUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���Ϻ�[' || AR.ARMCODE || ']' || AR.ARMONTH || '�·�' ||
                                'Ӧ����ˮ��[' || AR.rec_id ||
                                ']Ƿ����Ϣ�ѷ������пۿ���������⣡');
      END IF;*/
      /*UPDATE ZNJADJUSTLIST T
         SET ZALSTATUS = 'N'
       WHERE T.ZALrec_id = ZNJDT.ZADrec_id
         AND ZALSTATUS = 'Y';
      
      ZNJL.ZALrec_id      := ZNJDT.ZADrec_id; --����Ӧ����ˮ
      ZNJL.ZALPIID      := ZNJDT.ZADPIID; --���������Ŀ��ȫ��ΪNA��
      ZNJL.ZALMID       := ZNJDT.ZADMID; --ˮ����
      ZNJL.ZALMCODE     := ZNJDT.ZADMCODE; --ˮ���
      ZNJL.ZALMETHOD    := ZNJDT.ZADMETHOD; --���ⷽ����1��Ŀ������⣻2�����������⣻3�������⣻4�������������ڣ�
      ZNJL.ZALVALUE     := ZNJDT.ZADVALUE; --������/����ֵ
      ZNJL.ZALZNDATE    := ZNJDT.ZADZNDATE; --����Ŀ��������
      ZNJL.ZALDATE      := ZNJHD.check_date; --��������
      ZNJL.ZALPER       := P_PER; --������Ա
      ZNJL.ZALBILLNO    := ZNJDT.bill_id; --���ⵥ�ݱ��
      ZNJL.ZALBILLROWNO := ZNJDT.ZADROWNO; --���ⵥ���к�
      ZNJL.ZALSTATUS    := 'Y'; --��Ч��־
      INSERT INTO ZNJADJUSTLIST VALUES ZNJL;*/
      UPDATE Ys_Zw_Arlist Ar
         SET Ar.Arznjreducflag = 'N', Ar.Arznj = 0
       WHERE Arid = Znjdt.Rec_Id
         AND Arznjreducflag = 'Y'
         AND Arpaidflag = 'N';
    
      IF Znjdt.Method = '4' THEN
        -- ������������  
        UPDATE Ys_Zw_Arlist Ar
           SET Ar.Arzndate = Znjdt.Late_Fee_Date
         WHERE Arid = Znjdt.Rec_Id;
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

