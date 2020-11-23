CREATE OR REPLACE PACKAGE BODY Pg_Artrans_01 IS

   
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2) IS
  BEGIN
    IF p_Djlb IN ('O', 'T', '6', 'N', '13', '14', '21', '23') THEN
      Sp_Rectrans(p_Billno, p_Person); --׷��
    ELSIF p_Djlb = 'G' THEN 
      RecAdjust(p_Billno, p_Person, '', 'Y'); --��������   
    ELSIF p_Djlb = '12' THEN
      Sp_Paidbak(p_Billno, p_Person); --ʵ�ճ��� 
    END IF;
  END;
  --׷���շ� V --����ԭ�� ׷���շ�
  PROCEDURE Sp_Rectrans(p_No IN VARCHAR2, p_Per IN VARCHAR2) AS
    CURSOR c_Dt IS
      SELECT * FROM Ys_Gd_Aradddt WHERE Bill_Id = p_No FOR UPDATE;
  
    CURSOR c_Ys_Yh_Custinfo(Vcid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vcid;
  
    CURSOR c_Ys_Yh_Sbinfo(Vmid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmid FOR UPDATE NOWAIT;
  
    CURSOR c_Ys_Yh_Sbdoc(Vmid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbdoc WHERE Sbid = Vmid;
  
    CURSOR c_Ys_Yh_Account(Vmid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Account WHERE Sbid = Vmid;
  
    CURSOR c_Ys_Bas_Book(Vbook_No IN VARCHAR2) IS
      SELECT * FROM Ys_Bas_Book WHERE Book_No = Vbook_No;
  
    CURSOR c_Picount IS
      SELECT DISTINCT Nvl(t.Item_Type, 1) FROM Bas_Price_Item t;
  
    CURSOR c_Pi(Vpigroup IN NUMBER) IS
      SELECT * FROM Bas_Price_Item t WHERE t.Item_Type = Vpigroup;
    Rth    Ys_Gd_Araddhd%ROWTYPE;
    Rtd    Ys_Gd_Aradddt%ROWTYPE;
    Ci     Ys_Yh_Custinfo%ROWTYPE;
    Mi     Ys_Yh_Sbinfo%ROWTYPE;
    Bf     Ys_Bas_Book%ROWTYPE;
    Md     Ys_Yh_Sbdoc%ROWTYPE;
    Ma     Ys_Yh_Account%ROWTYPE;
    Rl     Ys_Zw_Arlist%ROWTYPE;
    Rl1    Ys_Zw_Arlist%ROWTYPE;
    Rd     Ys_Zw_Ardetail%ROWTYPE;
    p_Piid VARCHAR2(4000);
  
    v_Rlfzcount NUMBER(10);
    v_Rlfirst   NUMBER(10);
    v_Pigroup   Bas_Price_Item.Item_Type%TYPE;
    Rdtab       Pg_Cb_Cost.Rd_Table;
    Pi          Bas_Price_Item%ROWTYPE;
    Mr          Ys_Cb_Mtread%ROWTYPE;
    v_Pv        NUMBER(10);
    v_Count     NUMBER := 0;
    v_Temp      NUMBER := 0;
  BEGIN
  
    BEGIN
      SELECT * INTO Rth FROM Ys_Gd_Araddhd WHERE Bill_No = p_No;
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(Errcode, '���ݲ�����!');
    END;
    --��ĩ���һ�첻�ܽ���׷�������飬���ɣ�����Ӧ�գ����������·ݿ���
    IF Trunc(SYSDATE) = Last_Day(Trunc(SYSDATE, 'MONTH')) AND
       Rth.Bill_Type IN ('O', '13', '21') THEN
      Raise_Application_Error(Errcode, '��ǰΪ�����գ���������ҵ��');
    END IF;
    IF Rth.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '���������');
    END IF;
    IF Rth.Check_Flag = 'Q' THEN
      Raise_Application_Error(Errcode, '������ȡ��');
    END IF;
    IF Rth.Bill_Type = '13' THEN
      SELECT COUNT(*)
        INTO v_Count
        FROM Ys_Cb_Mtread
       WHERE Yhid = Rth.User_No
         AND Cbmrreadok = 'Y'
         AND Nvl(Cbmrifrec, 'N') = 'N'; -- by ralph 20150213 ���Ӳ������ʱ���Ƿ񳭼�δ��ѵ��ж�
      IF v_Count > 0 THEN
        Raise_Application_Error(Errcode,
                                '���û������ѳ���δ��Ѽ�¼�������Բ������!');
      END IF;
    END IF;
    --
    OPEN c_Ys_Yh_Custinfo(Rth.User_No);
    FETCH c_Ys_Yh_Custinfo
      INTO Ci;
    IF c_Ys_Yh_Custinfo%NOTFOUND OR c_Ys_Yh_Custinfo%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '�޴��û�');
    END IF;
    CLOSE c_Ys_Yh_Custinfo;
  
    OPEN c_Ys_Yh_Sbinfo(Rth.User_No);
    FETCH c_Ys_Yh_Sbinfo
      INTO Mi;
    IF c_Ys_Yh_Sbinfo%NOTFOUND OR c_Ys_Yh_Sbinfo%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '�޴�ˮ��');
    END IF;
  
    OPEN c_Ys_Yh_Sbdoc(Rth.User_No);
    FETCH c_Ys_Yh_Sbdoc
      INTO Md;
    IF c_Ys_Yh_Sbdoc%NOTFOUND OR c_Ys_Yh_Sbdoc%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '�޴�ˮ����');
    END IF;
    CLOSE c_Ys_Yh_Sbdoc;
  
    OPEN c_Ys_Yh_Account(Rth.User_No);
    FETCH c_Ys_Yh_Account
      INTO Ma;
    IF c_Ys_Yh_Account%NOTFOUND OR c_Ys_Yh_Account%NOTFOUND IS NULL THEN
      --raise_application_error(errcode,'�޴�ˮ������');
      NULL;
    END IF;
    CLOSE c_Ys_Yh_Account;
  
    OPEN c_Ys_Bas_Book(Rth.Book_No);
    FETCH c_Ys_Bas_Book
      INTO Bf;
    IF c_Ys_Bas_Book%NOTFOUND OR c_Ys_Bas_Book%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '�޴˱��');
      NULL;
    END IF;
    CLOSE c_Ys_Bas_Book;
  
    /*--byj add 2016.4.5 �����(���鲹�� ���� ׷��),Ҫ�ж��Ƿ���δ���� ������ ����ˮ���ʱ�������������˷ѡ��������� ��Ԥ���˷ѹ���  ----------
    if RTH.BILL_TYPE in ('21','13','O' ) then
       --�ж��Ƿ���δ������ˮ���ʱ������
       select count(*) into v_count
         from custchangehd hd,
              custchangedt dt
        where hd.cchno = dt.ccdno and
              hd.cchlb = 'E' and
              dt.YHID = mi.micid and
              hd.CCHSHFLAG = 'N';
       if v_count > 0 then
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���δ���ġ�ˮ�۱��������,���ܽ������!');
       end if;
       --�ж��Ƿ��й��ϻ���
       if mi.mistatus = '24' then
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���δ���ġ����ϻ�������,���ܽ������!');
       elsif mi.mistatus = '35' then
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���δ���ġ����ڻ�������,���ܽ������!');
       elsif mi.mistatus = '36' then
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���δ���ġ�Ԥ���˷ѡ�����,���ܽ������!');
       elsif mi.mistatus = '39' then
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���δ���ġ�Ԥ�泷���˷ѡ�����,���ܽ������!');
       elsif mi.mistatus = '19' then
          RAISE_APPLICATION_ERROR(ERRCODE, '���û���δ���ġ�����������,���ܽ������!');
       end if;
       --����޸�ˮ��ָ��,Ҫ�ж����ʱ��ָ���Ƿ��뽨������ʱһ��
       if rth.rthecodeflag = 'Y' then
          if rth.rthscode <> mi.mircode then
             RAISE_APPLICATION_ERROR(ERRCODE, '��ˮ���ֹ���Թ���������Ѿ����,��˲�!');
          end if;
          \*�������ʱ,��������г���ƻ����ϴ���δ���,��ʾ�������!!! (����������ʱ) *\
          if RTH.rthlb = '21' \*���鲹��*\ then
             begin
               select 1 into v_temp
                 from ys_cb_mtread mr
                where mr.mrmid = mi.SBID and
                      mr.MRREADOK in ('X','Y') and
                      mr.mrifrec = 'N' and
                      rownum < 2;
             exception
               when no_data_found then
                 v_temp := 0;
             end;
             if v_temp > 1 then
                RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ���š�' || mi.micid ||  '���������г��������ϴ���δ��ѵļ�¼,��˲�!');
             end if;
          end if;
       end if;
    end if;*/
    --end!!!
  
    -----��ͷ����ʼ
  
    -- Ԥ�ȸ�ֵ
    Rth.Check_Per  := p_Per;
    Rth.Check_Date := Currentdate;
  
    /*******����׷����Ϣ*****/
    IF 1 = 1 THEN
      --�Ƿ�����ѹ���(���߿���ΪӪҵ��)  
      --���볭���
      Pg_Artrans_01.Sp_Insertmr(Rth, TRIM(Rth.Bill_Type), Mi, Rl.Armrid);
    
      IF Rl.Armrid IS NOT NULL THEN
        SELECT * INTO Mr FROM Ys_Cb_Mtread WHERE Id = Rl.Armrid;
        IF Rth.If_Rechis = 'Y' THEN
          IF Rth.Price_Ver IS NULL THEN
            Raise_Application_Error(Errcode, '�鵵�۸�汾����Ϊ�գ�');
          END IF;
          SELECT COUNT(*)
            INTO v_Pv
            FROM Bas_Price_Version
           WHERE Price_Ver = Rth.Price_Ver;
          IF v_Pv = 0 THEN
            Raise_Application_Error(Errcode, '���·�ˮ��δ�鵵��');
          END IF;
          --�Ƿ���ʷˮ�����(ѡ��鵵�۸�汾)
          /*  pg_cb_cost.CALCULATE(MR, TRIM(RTH.RTHLB), TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm'));*/
          Pg_Cb_Cost.Costculate(Rl.Armrid, 'N'); -- ����ʷ�鵵ˮ�ۼƷѹ��̣����õ�ǰ�Ʒѹ���
          INSERT INTO Ys_Cb_Mtreadhis
            SELECT * FROM Ys_Cb_Mtread WHERE Id = Rl.Armrid;
          DELETE Ys_Cb_Mtread WHERE Id = Rl.Armrid;
          SELECT * INTO Rl FROM Ys_Zw_Arlist WHERE Armrid = Rl.Armrid;
        ELSE
          /*  pg_cb_cost.CALCULATE(MR, TRIM(RTH.RTHLB), '0000.00');*/ -- ����ʷ�鵵ˮ�ۼƷѹ��̣����õ�ǰ�Ʒѹ���
          Pg_Cb_Cost.Costculate(Rl.Armrid, 'N');
          INSERT INTO Ys_Cb_Mtreadhis
            SELECT * FROM Ys_Cb_Mtread WHERE Id = Rl.Armrid;
        
          DELETE Ys_Cb_Mtread WHERE Id = Rl.Armrid;
          SELECT * INTO Rl FROM Ys_Zw_Arlist WHERE Armrid = Rl.Armrid;
        END IF;
        IF Rth.Ecode_Flag = 'Y' THEN
          UPDATE Ys_Yh_Sbinfo
             SET Sbrcode = Rth.Read_Ecode, Sbrcodechar = Rth.Read_Ecode
          --miface     = mr.mrface,
           WHERE CURRENT OF c_Ys_Yh_Sbinfo;
        
        END IF;
      END IF;
    END IF;
    UPDATE Ys_Gd_Araddhd
       SET Check_Date = Currentdate,
           Check_Per  = p_Per,
           --  CHECK_PER  = rthcreper ,
           Check_Flag = 'Y'
     WHERE Bill_Id = p_No;
  
    --�������������(������ѵ�ʱ��û�п��ǵ��Ƿ����ֹ�������)
    IF Rth.Ecode_Flag = 'N' THEN
      UPDATE Ys_Yh_Sbinfo
         SET Sbrcode     = Rth.Read_Ecode,
             Sbrcodechar = Rth.Read_Ecode,
             Sbnewflag   = 'N'
      --miface     = mr.mrface,
       WHERE CURRENT OF c_Ys_Yh_Sbinfo;
    END IF;
  
    CLOSE c_Ys_Yh_Sbinfo;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  -----------------------------------
  PROCEDURE Sp_Insertmr(Rth         IN Ys_Gd_Araddhd%ROWTYPE, --׷��ͷ
                        p_Mriftrans IN VARCHAR2, --������������
                        Mi          IN Ys_Yh_Sbinfo%ROWTYPE, --ˮ����Ϣ
                        Omrid       OUT Ys_Cb_Mtread.Id%TYPE) AS
    --������ˮ
    Mr Ys_Cb_Mtread%ROWTYPE; --������ʷ��
  BEGIN
    Mr.Id        := Uuid(); --��ˮ��
    Omrid        := Mr.Id;
    Mr.Cbmrmonth := Fobtmanapara(Rth.Manage_No, 'READ_MONTH'); --�����·�
    Mr.Manage_No := Rth.Manage_No; --Ӫ����˾
    Mr.Book_No   := Rth.Book_No; --���
    BEGIN
      SELECT Read_Batch, Read_Per
        INTO Mr.Cbmrbatch, Mr.Cbmrrper --��������,����Ա
        FROM Ys_Bas_Book
       WHERE Book_No = Mi.Book_No
         AND Manage_No = Mi.Manage_No;
    EXCEPTION
      WHEN OTHERS THEN
        Mr.Cbmrbatch := 1; --��������
        Mr.Cbmrrper  := 'system';
    END;
    Mr.Cbmrrorder := Mi.Sbrorder; --,��������
    Mr.Yhid       := Mi.Yhid; --�û����
  
    Mr.Sbid := Mi.Sbid; --ˮ����
  
    Mr.Trade_No          := Mi.Trade_No; --��ҵ����
    Mr.Sbpid             := Mi.Sbpid; --�ϼ�ˮ��
    Mr.Cbmrmclass        := Mi.Sbclass; --ˮ����
    Mr.Cbmrmflag         := Mi.Sbflag; --ĩ����־
    Mr.Cbmrcreadate      := SYSDATE; --��������
    Mr.Cbmrinputdate     := NULL; --�༭����
    Mr.Cbmrreadok        := 'Y'; --������־
    Mr.Cbmrrdate         := Rth.Read_Date; --��������
    Mr.Cbmrprdate        := Rth.Pread_Date; --�ϴγ�������(ȡ�ϴ���Ч��������)
    Mr.Cbmrscode         := Rth.Read_Scode; --���ڳ���
    Mr.Cbmrscodechar     := Rth.Read_Scode; --���ڳ���char
    Mr.Cbmrecode         := Rth.Read_Ecode; --���ڳ���
    Mr.Cbmrsl            := Rth.Read_Water; --����ˮ��
    Mr.Cbmrface          := NULL; --���
    Mr.Cbmrifsubmit      := 'Y'; --�Ƿ��ύ�Ʒ�
    Mr.Cbmrifhalt        := 'N'; --ϵͳͣ��
    Mr.Cbmrdatasource    := 'Z'; --��������Դ
    Mr.Cbmrifignoreminsl := 'Y'; --ͣ����ͳ���
    Mr.Cbmrpdardate      := NULL; --���������ʱ��
    Mr.Cbmroutflag       := 'N'; --�������������־
    Mr.Cbmroutid         := NULL; --�������������ˮ��
    Mr.Cbmroutdate       := NULL; --���������������
    Mr.Cbmrinorder       := NULL; --��������մ���
    Mr.Cbmrindate        := NULL; --�������������
    Mr.Cbmrrpid          := Mi.Sbrpid; --�Ƽ�����
    Mr.Cbmrmemo          := NULL; --����ע
    Mr.Cbmrifgu          := 'N'; --�����־
    Mr.Cbmrifrec         := 'Y'; --�ѼƷ�
    Mr.Cbmrrecdate       := NULL; --�Ʒ�����
    Mr.Cbmrrecsl         := NULL; --Ӧ��ˮ��
    /*        --ȡδ������
    sp_fetchaddingsl(mr.cbmrid , --������ˮ
                     sb.sbid,--ˮ���
                     v_tempnum,--�ɱ�ֹ��
                     v_tempnum,--�±����
                     v_addsl ,--����
                     v_date,--��������
                     v_tempstr,--�ӵ�����
                     v_ret  --����ֵ
                     ) ;
    mr.cbmraddsl         :=   v_addsl ;  --����   */
    Mr.Cbmraddsl         := 0; --����
    Mr.Cbmrcarrysl       := NULL; --��λˮ��
    Mr.Cbmrctrl1         := NULL; --���������λ1
    Mr.Cbmrctrl2         := NULL; --���������λ2
    Mr.Cbmrctrl3         := NULL; --���������λ3
    Mr.Cbmrctrl4         := NULL; --���������λ4
    Mr.Cbmrctrl5         := NULL; --���������λ5
    Mr.Cbmrchkflag       := 'N'; --���˱�־
    Mr.Cbmrchkdate       := NULL; --��������
    Mr.Cbmrchkper        := NULL; --������Ա
    Mr.Cbmrchkscode      := NULL; --ԭ����
    Mr.Cbmrchkecode      := NULL; --ԭֹ��
    Mr.Cbmrchksl         := NULL; --ԭˮ��
    Mr.Cbmrchkaddsl      := NULL; --ԭ����
    Mr.Cbmrchkcarrysl    := NULL; --ԭ��λˮ��
    Mr.Cbmrchkrdate      := NULL; --ԭ��������
    Mr.Cbmrchkface       := NULL; --ԭ���
    Mr.Cbmrchkresult     := NULL; --���������
    Mr.Cbmrchkresultmemo := NULL; --�����˵��
    Mr.Cbmrprimid        := Mi.Sbpriid; --���ձ�����
    Mr.Cbmrprimflag      := Mi.Sbpriflag; --  ���ձ��־
    Mr.Cbmrlb            := Mi.Sblb; -- ˮ�����
    Mr.Cbmrnewflag       := Mi.Sbnewflag; -- �±��־
    Mr.Cbmrface2         := NULL; --��������
    Mr.Cbmrface3         := NULL; --�ǳ�����
    Mr.Cbmrface4         := NULL; --����ʩ˵��
  
    Mr.Cbmrprivilegeflag := 'N'; --��Ȩ��־(Y/N)
    Mr.Cbmrprivilegeper  := NULL; --��Ȩ������
    Mr.Cbmrprivilegememo := NULL; --��Ȩ������ע
    Mr.Area_No           := Mi.Area_No; --��������
    Mr.Cbmriftrans       := 'N'; --ת����־
    Mr.Cbmrrequisition   := 0; --֪ͨ����ӡ����
    Mr.Cbmrifchk         := Mi.Sbifchk; --���˱��־
    Mr.Cbmrinputper      := NULL; --������Ա
    Mr.Price_No          := Mi.Price_No; --��ˮ���
    --mr.cbmrcaliber       := md.mdcaliber;--�ھ�
    Mr.Cbmrside  := Mi.Sbside; --��λ
    Mr.Cbmrmtype := Mi.Sbtype; --����
  
    Mr.Cbmrplansl   := 0; --�ƻ�ˮ��
    Mr.Cbmrplanje01 := 0; --�ƻ�ˮ��
    Mr.Cbmrplanje02 := 0; --�ƻ���ˮ�����
    Mr.Cbmrplanje03 := 0; --�ƻ�ˮ��Դ��
  
    INSERT INTO Ys_Cb_Mtread VALUES Mr;
  EXCEPTION
    WHEN OTHERS THEN
      --OMRID := '';
      Raise_Application_Error(Errcode, '���ݿ����!' || SQLERRM);
  END;
-----------------------------------------------------------
  --׷�ղ��볭��ƻ�����ʷ��
  PROCEDURE Sp_Insertmrhis(Rth         IN Ys_Gd_Araddhd%ROWTYPE, --׷��ͷ
                        p_Mriftrans IN VARCHAR2, --������������
                        Mi          IN Ys_Yh_Sbinfo%ROWTYPE, --ˮ����Ϣ
                        Omrid       OUT Ys_Cb_Mtread.Id%TYPE)  AS
    --������ˮ
    Mrhis Ys_Cb_Mtreadhis%ROWTYPE; --������ʷ��
  BEGIN
    Mrhis.Id        := Uuid(); --��ˮ��
    Omrid           := Mrhis.Id;
    Mrhis.Cbmrmonth := Fobtmanapara(Rth.Manage_No, 'READ_MONTH'); --�����·�
    Mrhis.Manage_No := Rth.Manage_No; --Ӫ����˾
    Mrhis.Book_No   := Rth.Book_No; --���
    BEGIN
      SELECT Read_Batch, Read_Per
        INTO Mrhis.Cbmrbatch, Mrhis.Cbmrrper --��������,����Ա
        FROM Ys_Bas_Book
       WHERE Book_No = Mi.Book_No
         AND Manage_No = Mi.Manage_No;
    EXCEPTION
      WHEN OTHERS THEN
        Mrhis.Cbmrbatch := 1; --��������
        Mrhis.Cbmrrper  := 'system';
    END;
    Mrhis.Cbmrrorder := Mi.Sbrorder; --,��������
    Mrhis.Yhid       := Mi.Yhid; --�û����
  
    Mrhis.Sbid := Mi.Sbid; --ˮ����
  
    Mrhis.Trade_No          := Mi.Trade_No; --��ҵ����
    Mrhis.Sbpid             := Mi.Sbpid; --�ϼ�ˮ��
    Mrhis.Cbmrmclass        := Mi.Sbclass; --ˮ����
    Mrhis.Cbmrmflag         := Mi.Sbflag; --ĩ����־
    Mrhis.Cbmrcreadate      := SYSDATE; --��������
    Mrhis.Cbmrinputdate     := NULL; --�༭����
    Mrhis.Cbmrreadok        := 'Y'; --������־
    Mrhis.Cbmrrdate         := Rth.Read_Date; --��������
    Mrhis.Cbmrprdate        := Rth.Pread_Date; --�ϴγ�������(ȡ�ϴ���Ч��������)
    Mrhis.Cbmrscode         := Rth.Read_Scode; --���ڳ���
    Mrhis.Cbmrscodechar     := Rth.Read_Scode; --���ڳ���char
    Mrhis.Cbmrecode         := Rth.Read_Ecode; --���ڳ���
    Mrhis.Cbmrsl            := Rth.Read_Water; --����ˮ��
    Mrhis.Cbmrface          := NULL; --���
    Mrhis.Cbmrifsubmit      := 'Y'; --�Ƿ��ύ�Ʒ�
    Mrhis.Cbmrifhalt        := 'N'; --ϵͳͣ��
    Mrhis.Cbmrdatasource    := 'Z'; --��������Դ
    Mrhis.Cbmrifignoreminsl := 'Y'; --ͣ����ͳ���
    Mrhis.Cbmrpdardate      := NULL; --���������ʱ��
    Mrhis.Cbmroutflag       := 'N'; --�������������־
    Mrhis.Cbmroutid         := NULL; --�������������ˮ��
    Mrhis.Cbmroutdate       := NULL; --���������������
    Mrhis.Cbmrinorder       := NULL; --��������մ���
    Mrhis.Cbmrindate        := NULL; --�������������
    Mrhis.Cbmrrpid          := Mi.Sbrpid; --�Ƽ�����
    Mrhis.Cbmrmemo          := NULL; --����ע
    Mrhis.Cbmrifgu          := 'N'; --�����־
    Mrhis.Cbmrifrec         := 'Y'; --�ѼƷ�
    Mrhis.Cbmrrecdate       := NULL; --�Ʒ�����
    Mrhis.Cbmrrecsl         := NULL; --Ӧ��ˮ��
    /*        --ȡδ������
    sp_fetchaddingsl(mrHIS.cbmrid , --������ˮ
                     sb.sbid,--ˮ���
                     v_tempnum,--�ɱ�ֹ��
                     v_tempnum,--�±����
                     v_addsl ,--����
                     v_date,--��������
                     v_tempstr,--�ӵ�����
                     v_ret  --����ֵ
                     ) ;
    mrHIS.cbmraddsl         :=   v_addsl ;  --����   */
    Mrhis.Cbmraddsl         := 0; --����
    Mrhis.Cbmrcarrysl       := NULL; --��λˮ��
    Mrhis.Cbmrctrl1         := NULL; --���������λ1
    Mrhis.Cbmrctrl2         := NULL; --���������λ2
    Mrhis.Cbmrctrl3         := NULL; --���������λ3
    Mrhis.Cbmrctrl4         := NULL; --���������λ4
    Mrhis.Cbmrctrl5         := NULL; --���������λ5
    Mrhis.Cbmrchkflag       := 'N'; --���˱�־
    Mrhis.Cbmrchkdate       := NULL; --��������
    Mrhis.Cbmrchkper        := NULL; --������Ա
    Mrhis.Cbmrchkscode      := NULL; --ԭ����
    Mrhis.Cbmrchkecode      := NULL; --ԭֹ��
    Mrhis.Cbmrchksl         := NULL; --ԭˮ��
    Mrhis.Cbmrchkaddsl      := NULL; --ԭ����
    Mrhis.Cbmrchkcarrysl    := NULL; --ԭ��λˮ��
    Mrhis.Cbmrchkrdate      := NULL; --ԭ��������
    Mrhis.Cbmrchkface       := NULL; --ԭ���
    Mrhis.Cbmrchkresult     := NULL; --���������
    Mrhis.Cbmrchkresultmemo := NULL; --�����˵��
    Mrhis.Cbmrprimid        := Mi.Sbpriid; --���ձ�����
    Mrhis.Cbmrprimflag      := Mi.Sbpriflag; --  ���ձ��־
    Mrhis.Cbmrlb            := Mi.Sblb; -- ˮ�����
    Mrhis.Cbmrnewflag       := Mi.Sbnewflag; -- �±��־
    Mrhis.Cbmrface2         := NULL; --��������
    Mrhis.Cbmrface3         := NULL; --�ǳ�����
    Mrhis.Cbmrface4         := NULL; --����ʩ˵��
  
    Mrhis.Cbmrprivilegeflag := 'N'; --��Ȩ��־(Y/N)
    Mrhis.Cbmrprivilegeper  := NULL; --��Ȩ������
    Mrhis.Cbmrprivilegememo := NULL; --��Ȩ������ע
    Mrhis.Area_No           := Mi.Area_No; --��������
    Mrhis.Cbmriftrans       := 'N'; --ת����־
    Mrhis.Cbmrrequisition   := 0; --֪ͨ����ӡ����
    Mrhis.Cbmrifchk         := Mi.Sbifchk; --���˱��־
    Mrhis.Cbmrinputper      := NULL; --������Ա
    Mrhis.Price_No          := Mi.Price_No; --��ˮ���
    --mrHIS.cbmrcaliber       := md.mdcaliber;--�ھ�
    Mrhis.Cbmrside  := Mi.Sbside; --��λ
    Mrhis.Cbmrmtype := Mi.Sbtype; --����
  
    Mrhis.Cbmrplansl   := 0; --�ƻ�ˮ��
    Mrhis.Cbmrplanje01 := 0; --�ƻ�ˮ��
    Mrhis.Cbmrplanje02 := 0; --�ƻ���ˮ�����
    Mrhis.Cbmrplanje03 := 0; --�ƻ�ˮ��Դ��
    INSERT INTO Ys_Cb_Mtreadhis VALUES Mrhis;
  END;

  --��������
 --Ӧ�յ���������Ӧ�ճ��������ߡ����͡�����ۣ�
  procedure RecAdjust(p_billno in varchar2, --���ݱ��
                      p_per    in varchar2, --�����
                      p_memo   in varchar2, --��ע
                      p_commit in varchar --�Ƿ��ύ��־
                     ) as
    cursor c_rah is
    select * from YS_GD_ARADJUSTHD
    where BILL_ID = p_billno
    for update;

    cursor c_rad is
    select * from YS_GD_ARADJUSTDT
    where BILL_ID = p_billno and CHK_FLAG = 'Y'
    order by ID
    for update;

    cursor c_rlsource(vrlid in varchar2) is
    select * from  ys_zw_arlist
    where arid = vrlid
      and arpaidflag='N'
      and arreverseflag='N'
      and arbadflag='N'
      and aroutflag='N';

    cursor c_raddall( vrd_ID in varchar2) is
    select * from YS_GD_ARADJUSTDDT
    where rd_ID = vrd_ID
    order by id
    for update;

    rah   YS_GD_ARADJUSTHD%rowtype;
    rad   YS_GD_ARADJUSTDT%rowtype;
    radd  YS_GD_ARADJUSTDDT%rowtype;
    rlsource ys_zw_arlist%rowtype;
    --
    vrd  parm_append1rd:=parm_append1rd(null,null,null,null,null,null,null,null,null,null);
    vrds parm_append1rd_tab:= parm_append1rd_tab();
    vsumraddje number:=0;--�ٴ�У�鵥ͷ���������������Ҫ
  BEGIN
    --����״̬У��
    --��鵥�Ƿ������
    open c_rah;
    fetch c_rah into rah;
    if c_rah%notfound or c_rah%notfound is null then
      raise_application_error(errcode, '���ݲ�����');
    end if;
    if rah.CHECK_FLAG = 'Y' then
      raise_application_error(errcode, '���������');
    end if;
    if rah.CHECK_FLAG = 'Q' then
      raise_application_error(errcode, '������ȡ��');
    end if;

    open c_rad;
    fetch c_rad into rad;
    if c_rad%notfound or c_rad%notfound is null then
      raise_application_error(errcode,'�����в�����ѡ�еĵ�����¼');
    end if;
    while c_rad%found loop
      open c_rlsource(rad.REC_ID);
      fetch c_rlsource into rlsource;
      if c_rlsource%notfound or c_rlsource%notfound is null then
        raise_application_error(errcode, '������Ӧ�����񲻴��ڣ����������ѵ������˴������մ�����;��ԭ��');
      end if;
      close c_rlsource;
      -------------------------------------------------
      vsumraddje := 0;
      vrds       := null;
      open c_raddall(rad.ID);
      loop
        fetch c_raddall into radd;
        exit when c_raddall%notfound or c_raddall%notfound is null;
        
        vrd.HIRE_CODE  := radd.HIRE_CODE;
        vrd.ardpmdid  := radd.GROUP_NO;
        vrd.ardpfid   := radd.PRICE_NO;
        vrd.ardpscid  := radd.ardpscid; --������ϸ����
        vrd.ardpiid   := radd.PRICE_ITEM;
        vrd.ardclass  := radd.STEP_CLASS;
        vrd.arddj     := radd.ADJUST_PRICE;
       /* vrd.rdsl     := case when rah.rahmemo='����' then radd.raddyssl
                             when rah.rahmemo='����' then radd.raddsl
                             else radd.raddsl end;*/
        vrd.ardsl     :=radd.ADJUST_WATER;
        vrd.ardje     := radd.ADJUST_PRICE;
        if vrds is null then
          vrds := parm_append1rd_tab(vrd);
        else
          vrds.extend;
          vrds(vrds.last) := vrd;
        end if;
        vsumraddje := vsumraddje + vrd.ardje;
      end loop;
      close c_raddall;
      if vsumraddje<>rad.CHARGE_AMT then
         raise_application_error(errcode, '����'||rad.REC_ID||'���ݴ��󣬵�������'||vsumraddje||'�뵥����ϸ�ϼ�'||rad.CHARGE_AMT||'����');
      end if;
      -------------------------------------------------
       pg_paid.RecAdjust(p_rlmid => rad.USER_NO,
                       p_rlcname => rah.USER_NAME,
                       p_rlpfid => rad.PRICE_NO,
                       p_rlrdate => rad.READ_DATE,
                       p_rlscode => rad.READ_SCODE,
                       p_rlecode => rad.READ_ECODE,
                       p_rlsl => rad.WATER,
                       p_rlje => rad.CHARGE_AMT,
                       p_rlznj => 0,
                       p_rltrans => 'X',
                       p_rlmemo => rah.ADJ_MEMO,
                       p_rlid_source => rad.REC_ID,
                       p_parm_append1rds => vrds,
                       p_commit => pg_pay.���ύ,
                       p_ctl_mircode => case when rah.NCODE_FLAG='Y' then rah.NEXT_CODE else null end,
                       o_rlid_reverse => rad.REC_ID_CR,
                       o_rlid => rad.REC_ID_de);
      ----��������
      update YS_GD_ARADJUSTDT
         set REC_ID_CR = rad.REC_ID_CR,
             REC_ID_de = rad.REC_ID_de
       where current of c_rad; 
      fetch c_rad into rad;
    end loop;
    close c_rad;

    --��˵�ͷ
    UPDATE YS_GD_ARADJUSTHD
       SET CHECK_DATE = CURRENTDATE, CHECK_PER = P_PER, CHECK_FLAG = 'Y'
     WHERE CURRENT OF c_rah;
    CLOSE c_rah; 
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;

  exception when others then
    if c_rah%isopen then
      close c_rah;
    end if;
    if c_rad%isopen then
      close c_rad;
    end if;
    if c_raddall%isopen then
      close c_raddall;
    end if;
    if c_rlsource%isopen then
      close c_rlsource;
    end if;
    rollback;
    raise_application_error(errcode, sqlerrm);
  END RecAdjust;
   
  --ʵ�ճ���
  PROCEDURE Sp_Paidbak(p_No IN VARCHAR2, p_Per IN VARCHAR2) IS
    Ls_Retstr VARCHAR2(100);
    --��ͷ
    CURSOR c_Hd IS
      SELECT * FROM YS_GD_PAIDADJUSTHD WHERE BILL_ID = p_No FOR UPDATE;
    --����
    CURSOR c_Dt IS
      SELECT *
        FROM YS_GD_PAIDADJUSTDT
       WHERE BILL_ID = p_No
         FOR UPDATE;
  
    v_Hd   YS_GD_PAIDADJUSTHD%ROWTYPE;
    v_Dt   YS_GD_PAIDADJUSTDT %ROWTYPE;
    v_Temp NUMBER DEFAULT 0;
    p_pid_reverse  VARCHAR2(50);
  BEGIN
    OPEN c_Hd;
    FETCH c_Hd
      INTO v_Hd;
    /*��鴦��*/
    IF c_Hd%ROWCOUNT = 0 THEN
      Raise_Application_Error(Errcode,
                              '���ݲ�����,�����Ѿ�����������Ա������');
    END IF;
    IF v_Hd.CHECK_FLAG = 'Y' THEN
      Raise_Application_Error(Errcode, '�����Ѿ���ˣ�');
    END IF;
    IF v_Hd.CHECK_FLAG = 'Q' THEN
      Raise_Application_Error(Errcode, '������ȡ����');
    END IF;
    /*������*/
    OPEN c_Dt;
    LOOP
      FETCH c_Dt
        INTO v_Dt;
      EXIT WHEN c_Dt%NOTFOUND OR c_Dt%NOTFOUND IS NULL;
    
      IF v_Dt.PAID_TRANS = 'H'  THEN
        Raise_Application_Error(Errcode,
                                '�ɷ����κ�' || v_Dt.PAID_BATCH ||
                                '��������ʵʩǰ�ɷ�,��ʱ���ܳ���!');
      END IF;
       
      --end!!!
      pg_paid.PosReverse(v_Dt.Paid_Id ,
                       p_Per       ,
                       ''        ,
                       0    ,
                       p_pid_reverse );
     
    END LOOP;
    UPDATE YS_GD_PAIDADJUSTHD
       SET CHECK_FLAG = 'Y', CHECK_DATE = SYSDATE, CHECK_PER = p_Per
    --  PAHSHPER = pahcreper
     WHERE CURRENT OF c_Hd;
   
    IF c_Hd%ISOPEN THEN
      CLOSE c_Hd;
    END IF;
    IF c_Dt%ISOPEN THEN
      CLOSE c_Dt;
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
END;
/

