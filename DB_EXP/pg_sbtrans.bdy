CREATE OR REPLACE PACKAGE BODY "PG_SBTRANS" IS

  ������ˮ�� NUMBER(10);
  PROCEDURE AUDIT(p_HIRE_CODE IN VARCHAR2,
                    P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2) IS
    O_MRID VARCHAR2(200);
  BEGIN
  
        SP_SBTRANS(p_HIRE_CODE,P_DJLB, P_BILLNO, P_PERSON, 'N'); 
    
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      -- raise_application_error(errcode,sqlerrm);
  END AUDIT;

  --����������
  PROCEDURE SP_SBTRANS(p_HIRE_CODE IN VARCHAR2,
                          P_TYPE      IN VARCHAR2, --��������
                          P_BILL_ID   IN VARCHAR2, --������ˮ
                          P_PER       IN VARCHAR2, --����Ա
                          P_COMMIT    IN VARCHAR2 --�ύ��־
                          ) AS
    MH ys_gd_metertranshd%ROWTYPE;
    MD ys_gd_metertransdt%ROWTYPE;
  BEGIN
    BEGIN
      SELECT *
        INTO MH
        FROM ys_gd_metertranshd
       WHERE BILL_ID = P_BILL_ID
         and HIRE_CODE = p_HIRE_CODE;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�����ͷ��Ϣ������!');
    END;
  
    --byj update 2016.10.21
    IF mh.check_flag = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѿ����,�����ظ����!');
    END IF;
  
    for md in (SELECT *
                 FROM ys_gd_metertransdt
                WHERE BILL_ID = P_BILL_ID
                  and HIRE_CODE = p_HIRE_CODE) loop
      SP_SBTRANSONE(P_TYPE, P_PER, MD);
    
    end loop;
  
    UPDATE ys_gd_metertransdt
       SET CHECK_FLAG = 'Y'
     WHERE BILL_id = P_BILL_ID
       and HIRE_CODE = p_HIRE_CODE;
    UPDATE ys_gd_metertranshd
       SET check_flag = 'Y', CHECK_DATE = SYSDATE, CHECK_PER = P_PER
     where BILL_id = P_BILL_ID
       and HIRE_CODE = p_HIRE_CODE;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --����������˹���
  PROCEDURE SP_SBTRANSONE(P_TYPE   IN VARCHAR2, --����
                             P_PERSON IN VARCHAR2, -- ����Ա
                             P_MD     IN ys_gd_metertransdt%ROWTYPE --�����б��
                             ) AS
    MH ys_gd_metertranshd%ROWTYPE;
    MD ys_gd_metertransdt%ROWTYPE;
    MI ys_yh_sbinfo%ROWTYPE;
    CI ys_yh_custinfo%ROWTYPE;
    MC ys_yh_sbdoc%ROWTYPE;
    MA ys_gd_sbaddsl%ROWTYPE;
    --v_mrmemo       meterread.mrmemo%type;
    V_COUNT     NUMBER(4);
    V_COUNTMRID NUMBER(4);
    V_COUNTFLAG NUMBER(4);
    V_NUMBER    NUMBER(10);
    v_rcode     NUMBER(10);
    V_CRHNO     VARCHAR2(10);
    V_OMRID     VARCHAR2(20);
    O_STR       VARCHAR2(20);
  
    --δ��ѳ����¼
    cursor cur_nocalc(p_sbid varchar2, p_mrmonth varchar2) is
      select *
        from ys_cb_mtread mr
       where mr.sbid = p_sbid
         and mr.CBMRMONTH = p_mrmonth;
  
  BEGIN
    BEGIN
      SELECT *
        INTO MI
        FROM ys_yh_sbinfo
       WHERE sbid = P_MD.SBID
         and HIRE_CODE = P_MD.Hire_Code;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ�����ϲ�����!');
    END;
    BEGIN
      SELECT *
        INTO CI
        FROM ys_yh_custinfo
       WHERE yhid = MI.Yhid
         and HIRE_CODE = P_MD.Hire_Code;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�û����ϲ�����!');
    END;
    BEGIN
      SELECT *
        INTO MC
        FROM ys_yh_sbdoc
       WHERE sbid = P_MD.Sbid
         and HIRE_CODE = P_MD.Hire_Code;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ������!');
    END;
  
    IF MI.sbRCODE != MD.SCODE THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���ڳ��������仯�����������ڳ���');
    END IF;
  
    --F�������
    IF P_TYPE = BT������� THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      update ys_yh_sbinfo
         set sbSTATUS      = m����,
             sbSTATUSDATE  = sysdate,
             sbSTATUSTRANS = P_TYPE,
             sbUNINSDATE   = sysdate,
             BOOK_NO       = NULL -- by 20170904 wlj �����������ÿ�
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      --������ͬ���û�״̬
      UPDATE ys_yh_custinfo
         SET yhSTATUS      = m����,
             yhstatusdate  = sysdate,
             yhstatustrans = P_TYPE
       WHERE yhid = mi.yhid
         and Hire_Code = p_md.hire_code;
    
      --METERDOC  ��״̬ ��״̬����ʱ��
      update ys_yh_sbdoc
         set MDSTATUS = m����, MDSTATUSDATE = sysdate
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --�������� METERADDSL
    
      -- MD.MASID           :=     ;--��¼��ˮ��
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
    ELSIF P_TYPE = BT�ھ���� THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      UPDATE ys_yh_sbinfo
         SET SBSTATUS      = M����,
             SBSTATUSDATE  = SYSDATE,
             SBSTATUSTRANS = P_TYPE,
             SBREINSCODE   = P_MD.NEW_CODE, --�������
             SBREINSDATE   = P_MD.TRANS_TIME, --��������
             SBREINSPER    = P_MD.TRANS_PER, --������
             SBTYPE        = P_MD.METER_TYPE, --����
             BOOK_NO       = NULL
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC  ��״̬ ��״̬����ʱ��
    
      update ys_yh_sbdoc
         set MDSTATUS     = M����,
             MDCALIBER    = P_MD.CALIBER,
             MDNO         = P_MD.MODEL, ---���ͺ�
             MDSTATUSDATE = SYSDATE,
             MDCYCCHKDATE = P_MD.MTDYCCHKDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --��ѣ�����
    
    ELSIF P_TYPE = BT������ THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M����,
             sbSTATUSDATE  = SYSDATE,
             sbSTATUSTRANS = P_TYPE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC  ��״̬ ��״̬����ʱ��
      UPDATE ys_yh_sbdoc
         SET MDSTATUS = M����, MDSTATUSDATE = SYSDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      --�������� METERADDSL
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --���
      --
    ELSIF P_TYPE = BTǷ��ͣˮ THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = MǷ��ͣˮ,
             sbSTATUSDATE  = SYSDATE,
             sbSTATUSTRANS = P_TYPE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC  ��״̬ ��״̬����ʱ��
      UPDATE ys_yh_sbdoc
         SET MDSTATUS = MǷ��ͣˮ, MDSTATUSDATE = SYSDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --���
    ELSIF P_TYPE = BT�ָ���ˮ THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      UPDATE ys_yh_sbinfo
         SET SBSTATUS      = M����,
             SBSTATUSDATE  = SYSDATE,
             SBSTATUSTRANS = P_TYPE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC  ��״̬ ��״̬����ʱ��
      UPDATE YS_YH_SBDOC
         SET MDSTATUS = M����, MDSTATUSDATE = SYSDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      /*  --METERTRANSDT �ع��������� �ع�ˮ��״̬
      UPDATE METERTRANSDT
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;*/
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --���
    ELSIF P_TYPE = BT��ͣ THEN
    
      UPDATE ys_yh_sbinfo
         SET SBSTATUS      = M��ͣ,
             SBSTATUSDATE  = SYSDATE,
             SBSTATUSTRANS = P_TYPE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      UPDATE ys_yh_sbdoc
         SET MDSTATUS = M��ͣ, MDSTATUSDATE = SYSDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
    ELSIF P_TYPE = BTУ�� THEN
      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      --�ݲ����±��ڶ���     ,MIRCODE=P_MD.MTDREINSCODE
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M����,
             sbSTATUSDATE  = SYSDATE,
             sbSTATUSTRANS = P_TYPE,
             sbREINSDATE   = P_MD.TRANS_TIME
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
       
      UPDATE ys_yh_sbdoc
         SET MDSTATUS     = M����,
             MDSTATUSDATE = SYSDATE,
             MDCYCCHKDATE = P_MD.TRANS_TIME
      where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --���
    ELSIF P_TYPE = BT��װ THEN
      --�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M����, --״̬
             sbSTATUSDATE  = SYSDATE, --״̬����
             sbSTATUSTRANS = P_TYPE, --״̬���� 
             sbREINSCODE   = P_MD.NEW_CODE, --�������
             sbREINSDATE   = P_MD.TRANS_TIME, --��������
             sbREINSPER    = P_MD.TRANS_PER --������
        where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC
      UPDATE ys_yh_sbdoc
         SET MDSTATUS     = M����, --״̬
             MDSTATUSDATE = SYSDATE, --״̬����ʱ��
             MDNO         = P_MD.WATER_CODE, --�����
             MDCALIBER    = P_MD.CALIBER, --��ھ�
             MDBRAND      = P_MD.BRAND, --����
             MDMODEL      = P_MD.MODEL, --���ͺ�
             MDCYCCHKDATE = P_MD.MTDYCCHKDATE
        where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      --METERTRANSDT �ع��������� �ع�ˮ��״̬
     
    
       MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --���
    ELSIF P_TYPE = BT���ϻ��� THEN
      SELECT COUNT(*)
        INTO V_COUNTFLAG
        FROM YS_CB_MTREAD  
       WHERE  sbid = P_MD.Sbid
         and  cbmrreadok = 'Y' --�ѳ���
         AND  cbMRIFREC <> 'Y'; --δ���
      IF V_COUNTFLAG > 0 THEN
        --������Ѿ�����δ�����������ϻ�����ȡ��������־�س�
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��' || P_MD.Sbid ||
                                '����ˮ���Ѿ�����¼��,������־�д���,���ܽ��й��ϻ������,������ʽ������¼�롿����س���Ŧ,ȡ����ǰˮ��!');
      end if;
    
      update YS_CB_MTREAD t
         set CBMRSCODE = P_MD.NEW_CODE --by ralph 20151021  ���ӵĽ�δ����ָ�������
       where SBID = P_MD.SBID
         AND CBmrreadok = 'N' /*and exists (select max(t1.mrmonth) from meterread  t1 where
           t.mrmid=t1.mrmid and t1.mrmid=P_MD.MTDMID  AND T1.mrreadok='N' )*/
      ;
    
      
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M����, --״̬
              sbSTATUSDATE  = SYSDATE, --״̬����
             sbSTATUSTRANS = P_TYPE, --״̬���� 
             sbREINSCODE   = P_MD.NEW_CODE, --�������
             sbREINSDATE   = P_MD.TRANS_TIME, --��������
             sbREINSPER    = P_MD.TRANS_PER ,--������
            
             sbRCODE       = P_MD.NEW_CODE, --�������
             
             
             SBDZBZ1       = 'N', --����� �����־���(�����)  
             sbRTID      = p_md.sbRTID --����� ���ݹ������� ����ʽ!  
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      
      
       
          UPDATE ys_yh_sbdoc
             SET MDSTATUS     = M����, --״̬
             MDSTATUSDATE = SYSDATE, --״̬����ʱ��
             MDNO         = P_MD.WATER_CODE, --�����
             MDCALIBER    = P_MD.CALIBER, --��ھ�
             MDBRAND      = P_MD.BRAND, --����
             MDMODEL      = P_MD.MODEL, --���ͺ�
             MDCYCCHKDATE = P_MD.MTDYCCHKDATE
           where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
     
     MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
   
    ELSIF P_TYPE = BT���ڻ��� THEN
    
      SELECT COUNT(*)
        INTO V_COUNTFLAG
        FROM YS_CB_MTREAD  
       WHERE  sbid = P_MD.Sbid
         and  cbmrreadok = 'Y' --�ѳ���
         AND  cbMRIFREC <> 'Y'; --δ���
      IF V_COUNTFLAG > 0 THEN
        --������Ѿ�����δ�����������ϻ�����ȡ��������־�س�
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��' || P_MD.Sbid ||
                                '����ˮ���Ѿ�����¼��,������־�д���,���ܽ��й��ϻ������,������ʽ������¼�롿����س���Ŧ,ȡ����ǰˮ��!');
      end if;
    
      update YS_CB_MTREAD t
         set CBMRSCODE = P_MD.NEW_CODE --by ralph 20151021  ���ӵĽ�δ����ָ�������
       where SBID = P_MD.SBID
         AND CBmrreadok = 'N' /*and exists (select max(t1.mrmonth) from meterread  t1 where
           t.mrmid=t1.mrmid and t1.mrmid=P_MD.MTDMID  AND T1.mrreadok='N' )*/
      ;
    
      
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M����, --״̬
              sbSTATUSDATE  = SYSDATE, --״̬����
             sbSTATUSTRANS = P_TYPE, --״̬���� 
             sbREINSCODE   = P_MD.NEW_CODE, --�������
             sbREINSDATE   = P_MD.TRANS_TIME, --��������
             sbREINSPER    = P_MD.TRANS_PER ,--������
            
             sbRCODE       = P_MD.NEW_CODE, --�������
             
             
             SBDZBZ1       = 'N', --����� �����־���(�����) byj 2016.08
             sbRTID      = p_md.sbRTID --����� ���ݹ������� ����ʽ! byj 2016.12
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      
      
       
          UPDATE ys_yh_sbdoc
             SET MDSTATUS     = M����, --״̬
             MDSTATUSDATE = SYSDATE, --״̬����ʱ��
             MDNO         = P_MD.WATER_CODE, --�����
             MDCALIBER    = P_MD.CALIBER, --��ھ�
             MDBRAND      = P_MD.BRAND, --����
             MDMODEL      = P_MD.MODEL, --���ͺ�
             MDCYCCHKDATE = P_MD.MTDYCCHKDATE
           where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
     
     MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
    
      --���
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;
 

BEGIN
  null;
END;
/

