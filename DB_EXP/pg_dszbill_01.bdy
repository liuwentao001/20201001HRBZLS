CREATE OR REPLACE PACKAGE BODY Pg_Dszbill_01 IS

  PROCEDURE Createhd(p_Dshno     IN VARCHAR2, --������ˮ��
                     p_Dshlb     IN VARCHAR2, --�������
                     p_Dshsmfid  IN VARCHAR2, --Ӫ����˾
                     p_Dshdept   IN VARCHAR2, --������
                     p_Dshcreper IN VARCHAR2 --������Ա
                     ) IS
    Dbh Ys_Gd_Zwdhzd%ROWTYPE;
  BEGIN
    --��ֵ ��ͷ
    Dbh.Id          := Uuid();
    Dbh.Hire_Code   := f_Get_Hire_Code();
    Dbh.Bill_Id     := p_Dshno; --������ˮ��
    Dbh.Bill_No     := p_Dshno; --���ݱ��
    Dbh.Bill_Type   := p_Dshlb; --�������
    Dbh.Bill_Source := '1'; --������Դ
    Dbh.Manage_No   := p_Dshsmfid; --Ӫ����˾
    Dbh.New_Dept    := p_Dshdept; --������
    Dbh.Add_Date    := SYSDATE; --��������
    Dbh.Add_Per     := p_Dshcreper; --������Ա
    Dbh.Check_Date  := NULL; --�������
    Dbh.Check_Per   := NULL; --�����Ա
    Dbh.Check_Flag  := 'N'; --��˱�־
    INSERT INTO Ys_Gd_Zwdhzd VALUES Dbh;
  
  END Createhd;

  PROCEDURE Createdt(p_Dsdno    IN VARCHAR2, --������ˮ��
                     p_Dsdrowno IN VARCHAR2, --�к�
                     p_Arid     IN VARCHAR2 --Ӧ����ˮ
                     ) IS
    Dbt Ys_Gd_Zwdhzdt%ROWTYPE;
    Ar  Ys_Zw_Arlist%ROWTYPE;
  BEGIN
    --��ѯ������Ϣ
    SELECT * INTO Ar FROM Ys_Zw_Arlist WHERE Arid = p_Arid;
    --��ֵ ����      
    Dbt.Bill_Id   := p_Dsdno; --������ˮ��
    Dbt.Dhzrowno  := p_Dsdrowno; --�к�
    Dbt.Hire_Code := Ar.Hire_Code; --
    Dbt.Arid      := Ar.Arid; --��ˮ��
    Dbt.Manage_No := Ar.Manage_No; --Ӫ����˾
    Dbt.Armonth   := Ar.Armonth; --�����·�
    Dbt.Ardate    := Ar.Ardate; --��������
    Dbt.Yhid      := Ar.Yhid; --�û����
    Dbt.Sbid      := Ar.Sbid; --ˮ����
    /* DBT.RLMSMFID        := Ar.RLMSMFID; --ˮ��˾
    DBT.RLCSMFID        := Ar.RLCSMFID; --�û���˾
    DBT.RLCCODE         := Ar.RLCCODE; --���Ϻ�*/
    Dbt.Archargeper     := Ar.Archargeper; --�շ�Ա
    Dbt.Arcpid          := Ar.Arcpid; --�ϼ��û����
    Dbt.Arcclass        := Ar.Arcclass; --�û�����
    Dbt.Arcflag         := Ar.Arcflag; --ĩ����־
    Dbt.Arusenum        := Ar.Arusenum; --����ˮ����
    Dbt.Arcname         := Ar.Arcname; --�û�����
    Dbt.Arcadr          := Ar.Arcadr; --�û���ַ
    Dbt.Armadr          := Ar.Armadr; --ˮ���ַ
    Dbt.Arcstatus       := Ar.Arcstatus; --�û�״̬
    Dbt.Armtel          := Ar.Armtel; --�ƶ��绰
    Dbt.Artel           := Ar.Artel; --�̶��绰
    Dbt.Arbankid        := Ar.Arbankid; --��������
    Dbt.Artsbankid      := Ar.Artsbankid; --��������
    Dbt.Araccountno     := Ar.Araccountno; --�����ʺ�
    Dbt.Araccountname   := Ar.Araccountname; --��������
    Dbt.Ariftax         := Ar.Ariftax; --�Ƿ�˰Ʊ
    Dbt.Artaxno         := Ar.Artaxno; --��ֳ˰��
    Dbt.Arifinv         := Ar.Arifinv; --�Ƿ���Ʊ
    Dbt.Armcode         := Ar.Armcode; --ˮ���ֹ����
    Dbt.Armpid          := Ar.Armpid; --�ϼ�ˮ��
    Dbt.Armclass        := Ar.Armclass; --ˮ����
    Dbt.Armflag         := Ar.Armflag; --ĩ����־
    Dbt.Armsfid         := Ar.Armsfid; --ˮ�����
    Dbt.Arday           := Ar.Arday; --������
    Dbt.Arbfid          := Ar.Arbfid; --���
    Dbt.Arprdate        := Ar.Arprdate; --�ϴγ�������
    Dbt.Arrdate         := Ar.Arrdate; --���γ�������
    Dbt.Arzndate        := Ar.Arzndate; --ΥԼ��������
    Dbt.Arcaliber       := Ar.Arcaliber; --��ھ�
    Dbt.Arrtid          := Ar.Arrtid; --����ʽ
    Dbt.Armstatus       := Ar.Armstatus; --״̬
    Dbt.Armtype         := Ar.Armtype; --����
    Dbt.Armno           := Ar.Armno; --������
    Dbt.Arscode         := Ar.Arscode; --����
    Dbt.Arecode         := Ar.Arecode; --ֹ��
    Dbt.Arreadsl        := Ar.Arreadsl; --����ˮ��
    Dbt.Arinvmemo       := Ar.Arinvmemo; --��Ʊ��ע
    Dbt.Arentrustbatch  := Ar.Arentrustbatch; --���մ�������
    Dbt.Arentrustseqno  := Ar.Arentrustseqno; --���մ�����ˮ��
    Dbt.Aroutflag       := Ar.Aroutflag; --������־
    Dbt.Artrans         := Ar.Artrans; --Ӧ������
    Dbt.Arcd            := Ar.Arcd; --�������
    Dbt.Aryschargetype  := Ar.Aryschargetype; --Ӧ�շ�ʽ
    Dbt.Arsl            := Ar.Arsl; --Ӧ��ˮ��
    Dbt.Arje            := Ar.Arje; --Ӧ�ս��
    Dbt.Araddsl         := Ar.Araddsl; --�ӵ�ˮ��
    Dbt.Arscrarid       := Ar.Arscrarid; --ԭӦ������ˮ
    Dbt.Arscrartrans    := Ar.Arscrartrans; --ԭӦ��������
    Dbt.Arscrarmonth    := Ar.Arscrarmonth; --ԭӦ�����·�
    Dbt.Arpaidje        := Ar.Arpaidje; --���ʽ��
    Dbt.Arpaidflag      := Ar.Arpaidflag; --���ʱ�־(Y:Y��N:N��X:X��V:Y/N��T:Y/X��K:N/X��W:Y/N/X)
    Dbt.Arpaidper       := Ar.Arpaidper; --������Ա
    Dbt.Arpaiddate      := Ar.Arpaiddate; --��������
    Dbt.Armrid          := Ar.Armrid; --������ˮ
    Dbt.Armemo          := Ar.Armemo; --��ע
    Dbt.Arznj           := Ar.Arznj; --ΥԼ��
    Dbt.Arlb            := Ar.Arlb; --���
    Dbt.Arcname2        := Ar.Arcname2; --������
    Dbt.Arpfid          := Ar.Arpfid; --���۸����
    Dbt.Ardatetime      := Ar.Ardatetime; --��������
    Dbt.Arscrardate     := Ar.Arscrardate; --ԭ��������
    Dbt.Arprimcode      := Ar.Arprimcode; --���ձ������
    Dbt.Arpriflag       := Ar.Arpriflag; --���ձ��־
    Dbt.Arrper          := Ar.Arrper; --����Ա
    Dbt.Arsafid         := Ar.Arsafid; --����
    Dbt.Arscodechar     := Ar.Arscodechar; --���ڳ�������λ��
    Dbt.Arecodechar     := Ar.Arecodechar; --���ڳ�������λ��
    Dbt.Arilid          := Ar.Arilid; --��Ʊ��ˮ��
    Dbt.Armiuiid        := Ar.Armiuiid; --���յ�λ���
    Dbt.Argroup         := Ar.Argroup; --Ӧ���ʷ���
    Dbt.Arpid           := Ar.Arpid; --ʵ����ˮ����PAYMENT.PID��Ӧ��
    Dbt.Arpbatch        := Ar.Arpbatch; --�ɷѽ������Σ���PAYMENT.PBATCH��Ӧ��
    Dbt.Arsavingqc      := Ar.Arsavingqc; --�ڳ�Ԥ�棨����ʱ������
    Dbt.Arsavingbq      := Ar.Arsavingbq; --����Ԥ�淢��������ʱ������
    Dbt.Arsavingqm      := Ar.Arsavingqm; --��ĩԤ�棨����ʱ������
    Dbt.Arreverseflag   := Ar.Arreverseflag; --  ������־��NΪ������YΪ������
    Dbt.Arbadflag       := 'O'; --���ʱ�־��Y :�����ʣ�O:�����������У�N:�����ʣ�  --����ʱ�޸ı�־
    Dbt.Arznjreducflag  := Ar.Arznjreducflag; --���ɽ�����־,δ����ʱΪN������ʱ���ɽ�ֱ�Ӽ��㣻�����ΪY,����ʱ���ɽ�ֱ��ȡARZNJ
    Dbt.Armistid        := Ar.Armistid; --��ҵ����
    Dbt.Arminame        := Ar.Arminame; --Ʊ������
    Dbt.Arsxf           := Ar.Arsxf; --������
    Dbt.Armiface2       := Ar.Armiface2; --��������
    Dbt.Armiface3       := Ar.Armiface3; --�ǳ�����
    Dbt.Armiface4       := Ar.Armiface4; --����ʩ˵��
    Dbt.Armiifckf       := Ar.Armiifckf; --�����ѻ���
    Dbt.Armigps         := Ar.Armigps; --�Ƿ��Ʊ
    Dbt.Armiqfh         := Ar.Armiqfh; --Ǧ���
    Dbt.Armibox         := Ar.Armibox; --����ˮ�ۣ���ֵ˰ˮ�ۣ���������
    Dbt.Arminame2       := Ar.Arminame2; --��������(С��������������
    Dbt.Armiseqno       := Ar.Armiseqno; --���ţ���ʼ��ʱ���+��ţ�
    Dbt.Armisaving      := Ar.Armisaving; --���ʱԤ��
    Dbt.Arpriorje       := Ar.Arpriorje; --���֮ǰǷ��
    Dbt.Armicommunity   := Ar.Armicommunity; --С��
    Dbt.Armiremoteno    := Ar.Armiremoteno; --Զ�����
    Dbt.Armiremotehubno := Ar.Armiremotehubno; --Զ��HUB��
    Dbt.Armiemail       := Ar.Armiemail; --�����ʼ�
    Dbt.Armiemailflag   := Ar.Armiemailflag; --��Ʊ���
    Dbt.Armicolumn1     := Ar.Armicolumn1; --�����ֶ�1
    Dbt.Armicolumn2     := Ar.Armicolumn2; --�����ֶ�2(Ԥ��Ʊ��ӡ����)
    Dbt.Armicolumn3     := Ar.Armicolumn3; --�����ֶ�3
    Dbt.Armicolumn4     := Ar.Armicolumn4; --�����ֶ�3
    Dbt.Arpaidmonth     := Ar.Arpaidmonth; --�����·�
    Dbt.Arcolumn5       := Ar.Arcolumn5; --�ϴ�Ӧ��������
    Dbt.Arcolumn9       := Ar.Arcolumn9; --�ϴ�Ӧ������ˮ
    Dbt.Arcolumn10      := Ar.Arcolumn10; --�ϴ�Ӧ�����·�
    Dbt.Arcolumn11      := Ar.Arcolumn11; --�ϴ�Ӧ��������
    Dbt.Arjtmk          := Ar.Arjtmk; --���ǽ���ע��
    Dbt.Arjtsrq         := Ar.Arjtsrq; --�����ڽ��ݿ�ʼ����
    Dbt.Arcolumn12      := Ar.Arcolumn12; --����ۼ���
    Dbt.Dhzappnote      := ''; --����˵��
    Dbt.Dhzfilashnote   := ''; --�쵼���
    Dbt.Dhzmemo         := ''; --��ע
    Dbt.Dhzshflag       := 'N'; --����˱�־
    Dbt.Dhzshdate       := ''; --���������
    Dbt.Dhzshper        := ''; --�������
  
    INSERT INTO Ys_Gd_Zwdhzdt VALUES Dbt;
  END Createdt;

  PROCEDURE Createdszbill(p_Dshno     IN VARCHAR2, --������ˮ��
                          p_Dshlb     IN VARCHAR2, --�������
                          p_Dshsmfid  IN VARCHAR2, --Ӫ����˾
                          p_Dshdept   IN VARCHAR2, --������
                          p_Dshcreper IN VARCHAR2, --������Ա
                          p_Arid      IN VARCHAR2 --Ӧ����ˮ��
                          ) IS
    Ar      Ys_Zw_Arlist%ROWTYPE;
    v_Rowid NUMBER(10) := 0; --�к�
    --��λ�α�
    CURSOR c_Ar IS
      SELECT t.*
        FROM Ys_Zw_Arlist t /*, PBPARMTEMP P*/
       WHERE Arid = p_Arid;
    --ARID = '';
  BEGIN
    --���뵥ͷ
    Createhd(p_Dshno, --������ˮ��
             p_Dshlb, --�������
             p_Dshsmfid, --Ӫ����˾
             p_Dshdept, --������
             p_Dshcreper --������Ա
             );
    --���뵥��
    OPEN c_Ar;
    LOOP
      FETCH c_Ar
        INTO Ar;
      EXIT WHEN c_Ar%NOTFOUND OR c_Ar%NOTFOUND IS NULL;
      v_Rowid := v_Rowid + 1;
      Createdt(p_Dshno, --������ˮ��
               v_Rowid, --�к�
               Ar.Arid --Ӧ����ˮ��
               );
      --�޸Ĵ����ʱ�־
      UPDATE Ys_Zw_Arlist
         SET Ys_Zw_Arlist.Arbadflag = 'O'
       WHERE Arid = Ar.Arid;
    END LOOP;
    CLOSE c_Ar;
    COMMIT;
  END Createdszbill;

  --ɾ������
  PROCEDURE Cancelbill(p_Billno IN VARCHAR2, --���ݱ��
                       p_Person IN VARCHAR2, --����Ա
                       p_Djlb   IN VARCHAR2) IS
    --�������
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
      Raise_Application_Error(Errcode, '���ݲ�����' || p_Billno);
    END IF;
    IF Dbh.Check_Flag <> 'N' THEN
      Raise_Application_Error(Errcode, '���ݲ���ȡ��' || p_Billno);
    END IF;
    --�޸Ĵ����ʱ�־
    UPDATE Ys_Zw_Arlist
       SET Ys_Zw_Arlist.Arbadflag = 'N'
     WHERE Arid IN
           (SELECT Arid FROM Ys_Gd_Zwdhzdt WHERE Bill_Id = p_Billno);
    --ɾ������
    DELETE FROM Ys_Gd_Zwdhzdt t WHERE t.Bill_Id = p_Billno;
    --ɾ����ͷ
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

  --���������
  PROCEDURE Custbillmain(p_Cchno    IN VARCHAR2, --������ˮ
                         p_Per      IN VARCHAR2, --����Ա
                         p_Billid   IN VARCHAR2, --����ID
                         p_Billtype IN VARCHAR2 --�������
                         ) AS
  
  BEGIN
    Custbill(p_Cchno, p_Per, p_Billtype, 'N');
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;

  --���������
  PROCEDURE Custbill(p_Cchno    IN VARCHAR2, --������ˮ
                     p_Per      IN VARCHAR2, --����Ա
                     p_Billtype IN VARCHAR2,
                     p_Commit   IN VARCHAR2 --�ύ��־
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
        Raise_Application_Error(Errcode, '�����ͷ��Ϣ������!');
    END;
    IF Dbh.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '����������,��������!');
    END IF;
    IF Dbh.Check_Flag = 'C' THEN
      Raise_Application_Error(Errcode, '�������ȡ��,������!');
    END IF;
  
    OPEN c_Custdt;
    LOOP
      FETCH c_Custdt
        INTO Dbt;
      EXIT WHEN c_Custdt%NOTFOUND OR c_Custdt%NOTFOUND IS NULL;
      --���µ���
      UPDATE Ys_Gd_Zwdhzdt
         SET Dhzshflag = 'Y', --����˱�־
             Dhzshdate = SYSDATE, --���������
             Dhzshper  = p_Per --�������
       WHERE Bill_Id = Dbt.Bill_Id
         AND Dhzrowno = Dbt.Dhzrowno;
      --������������ʱ�־
      IF p_Billtype = '8' THEN
        --�����˱��Ϊ������  ADD 20140831
        --20140227 ���Ӵ�����Ӧ������  RECTRANS
        UPDATE Ys_Zw_Arlist
           SET Arbadflag = 'Y', Artrans = 'D'
         WHERE Arid = Dbt.Arid;
      ELSE
        --�����˱��Ϊ������ ADD 20140831
        UPDATE Ys_Zw_Arlist
           SET Arbadflag = 'N', Artrans = 'D'
         WHERE Arid = Dbt.Arid;
      END IF;
    END LOOP;
    CLOSE c_Custdt;
    --��˵�ͷ
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

