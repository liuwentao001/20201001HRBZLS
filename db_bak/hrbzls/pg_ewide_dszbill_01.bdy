CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_DSZBILL_01" IS

  PROCEDURE CREATEHD(P_DSHNO     IN VARCHAR2, --������ˮ��
                     P_DSHLB     IN VARCHAR2, --�������
                     P_DSHSMFID  IN VARCHAR2, --Ӫ����˾
                     P_DSHDEPT   IN VARCHAR2, --������
                     P_DSHCREPER IN VARCHAR2 --������Ա
                     ) IS
    DBH DSZBILLHD%ROWTYPE;
  BEGIN
    --��ֵ ��ͷ
    DBH.DBHNO      := P_DSHNO; --������ˮ��
    DBH.DBHBH      := P_DSHNO; --���ݱ��
    DBH.DBHLB      := P_DSHLB; --�������
    DBH.DBHSOURCE  := '1'; --������Դ
    DBH.DBHSMFID   := P_DSHSMFID; --Ӫ����˾
    DBH.DBHDEPT    := P_DSHDEPT; --������
    DBH.DBHCREDATE := SYSDATE; --��������
    DBH.DBHCREPER  := P_DSHCREPER; --������Ա
    DBH.DBHSHDATE  := NULL; --�������
    DBH.DBHSHPER   := NULL; --�����Ա
    DBH.DBHSHFLAG  := 'N'; --��˱�־
    INSERT INTO DSZBILLHD VALUES DBH;

  END CREATEHD;

  PROCEDURE CREATEDT(P_DSDNO    IN VARCHAR2, --������ˮ��
                     P_DSDROWNO IN VARCHAR2, --�к�
                     P_RLID     IN VARCHAR2 --Ӧ����ˮ
                     ) IS
    DBT DSZBILLDT%ROWTYPE;
    RL  RECLIST%ROWTYPE;
  BEGIN
    --��ѯ������Ϣ
    SELECT * INTO RL FROM RECLIST WHERE RLID = P_RLID;
    --��ֵ ����
    DBT.DBDNO           := P_DSDNO; --������ˮ��
    DBT.DBDROWNO        := P_DSDROWNO; --�к�
    DBT.RLID            := RL.RLID; --��ˮ��
    DBT.RLSMFID         := RL.RLSMFID; --Ӫ����˾
    DBT.RLMONTH         := RL.RLMONTH; --�����·�
    DBT.RLDATE          := RL.RLDATE; --��������
    DBT.RLCID           := RL.RLCID; --�û����
    DBT.RLMID           := RL.RLMID; --ˮ����
    DBT.RLMSMFID        := RL.RLMSMFID; --ˮ��˾
    DBT.RLCSMFID        := RL.RLCSMFID; --�û���˾
    DBT.RLCCODE         := RL.RLCCODE; --���Ϻ�
    DBT.RLCHARGEPER     := RL.RLCHARGEPER; --�շ�Ա
    DBT.RLCPID          := RL.RLCPID; --�ϼ��û����
    DBT.RLCCLASS        := RL.RLCCLASS; --�û�����
    DBT.RLCFLAG         := RL.RLCFLAG; --ĩ����־
    DBT.RLUSENUM        := RL.RLUSENUM; --����ˮ����
    DBT.RLCNAME         := RL.RLCNAME; --�û�����
    DBT.RLCADR          := RL.RLCADR; --�û���ַ
    DBT.RLMADR          := RL.RLMADR; --ˮ���ַ
    DBT.RLCSTATUS       := RL.RLCSTATUS; --�û�״̬
    DBT.RLMTEL          := RL.RLMTEL; --�ƶ��绰
    DBT.RLTEL           := RL.RLTEL; --�̶��绰
    DBT.RLBANKID        := RL.RLBANKID; --��������
    DBT.RLTSBANKID      := RL.RLTSBANKID; --��������
    DBT.RLACCOUNTNO     := RL.RLACCOUNTNO; --�����ʺ�
    DBT.RLACCOUNTNAME   := RL.RLACCOUNTNAME; --��������
    DBT.RLIFTAX         := RL.RLIFTAX; --�Ƿ�˰Ʊ
    DBT.RLTAXNO         := RL.RLTAXNO; --��ֳ˰��
    DBT.RLIFINV         := RL.RLIFINV; --�Ƿ���Ʊ
    DBT.RLMCODE         := RL.RLMCODE; --ˮ���ֹ����
    DBT.RLMPID          := RL.RLMPID; --�ϼ�ˮ��
    DBT.RLMCLASS        := RL.RLMCLASS; --ˮ����
    DBT.RLMFLAG         := RL.RLMFLAG; --ĩ����־
    DBT.RLMSFID         := RL.RLMSFID; --ˮ�����
    DBT.RLDAY           := RL.RLDAY; --������
    DBT.RLBFID          := RL.RLBFID; --���
    DBT.RLPRDATE        := RL.RLPRDATE; --�ϴγ�������
    DBT.RLRDATE         := RL.RLRDATE; --���γ�������
    DBT.RLZNDATE        := RL.RLZNDATE; --ΥԼ��������
    DBT.RLCALIBER       := RL.RLCALIBER; --��ھ�
    DBT.RLRTID          := RL.RLRTID; --����ʽ
    DBT.RLMSTATUS       := RL.RLMSTATUS; --״̬
    DBT.RLMTYPE         := RL.RLMTYPE; --����
    DBT.RLMNO           := RL.RLMNO; --������
    DBT.RLSCODE         := RL.RLSCODE; --����
    DBT.RLECODE         := RL.RLECODE; --ֹ��
    DBT.RLREADSL        := RL.RLREADSL; --����ˮ��
    DBT.RLINVMEMO       := RL.RLINVMEMO; --��Ʊ��ע
    DBT.RLENTRUSTBATCH  := RL.RLENTRUSTBATCH; --���մ�������
    DBT.RLENTRUSTSEQNO  := RL.RLENTRUSTSEQNO; --���մ�����ˮ��
    DBT.RLOUTFLAG       := RL.RLOUTFLAG; --������־
    DBT.RLTRANS         := RL.RLTRANS; --Ӧ������
    DBT.RLCD            := RL.RLCD; --�������
    DBT.RLYSCHARGETYPE  := RL.RLYSCHARGETYPE; --Ӧ�շ�ʽ
    DBT.RLSL            := RL.RLSL; --Ӧ��ˮ��
    DBT.RLJE            := RL.RLJE; --Ӧ�ս��
    DBT.RLADDSL         := RL.RLADDSL; --�ӵ�ˮ��
    DBT.RLSCRRLID       := RL.RLSCRRLID; --ԭӦ������ˮ
    DBT.RLSCRRLTRANS    := RL.RLSCRRLTRANS; --ԭӦ��������
    DBT.RLSCRRLMONTH    := RL.RLSCRRLMONTH; --ԭӦ�����·�
    DBT.RLPAIDJE        := RL.RLPAIDJE; --���ʽ��
    DBT.RLPAIDFLAG      := RL.RLPAIDFLAG; --���ʱ�־(Y:Y��N:N��X:X��V:Y/N��T:Y/X��K:N/X��W:Y/N/X)
    DBT.RLPAIDPER       := RL.RLPAIDPER; --������Ա
    DBT.RLPAIDDATE      := RL.RLPAIDDATE; --��������
    DBT.RLMRID          := RL.RLMRID; --������ˮ
    DBT.RLMEMO          := RL.RLMEMO; --��ע
    DBT.RLZNJ           := RL.RLZNJ; --ΥԼ��
    DBT.RLLB            := RL.RLLB; --���
    DBT.RLCNAME2        := RL.RLCNAME2; --������
    DBT.RLPFID          := RL.RLPFID; --���۸����
    DBT.RLDATETIME      := RL.RLDATETIME; --��������
    DBT.RLSCRRLDATE     := RL.RLSCRRLDATE; --ԭ��������
    DBT.RLPRIMCODE      := RL.RLPRIMCODE; --���ձ������
    DBT.RLPRIFLAG       := RL.RLPRIFLAG; --���ձ��־
    DBT.RLRPER          := RL.RLRPER; --����Ա
    DBT.RLSAFID         := RL.RLSAFID; --����
    DBT.RLSCODECHAR     := RL.RLSCODECHAR; --���ڳ�������λ��
    DBT.RLECODECHAR     := RL.RLECODECHAR; --���ڳ�������λ��
    DBT.RLILID          := RL.RLILID; --��Ʊ��ˮ��
    DBT.RLMIUIID        := RL.RLMIUIID; --���յ�λ���
    DBT.RLGROUP         := RL.RLGROUP; --Ӧ���ʷ���
    DBT.RLPID           := RL.RLPID; --ʵ����ˮ����payment.pid��Ӧ��
    DBT.RLPBATCH        := RL.RLPBATCH; --�ɷѽ������Σ���payment.PBATCH��Ӧ��
    DBT.RLSAVINGQC      := RL.RLSAVINGQC; --�ڳ�Ԥ�棨����ʱ������
    DBT.RLSAVINGBQ      := RL.RLSAVINGBQ; --����Ԥ�淢��������ʱ������
    DBT.RLSAVINGQM      := RL.RLSAVINGQM; --��ĩԤ�棨����ʱ������
    DBT.RLREVERSEFLAG   := RL.RLREVERSEFLAG; --  ������־��NΪ������YΪ������
    DBT.RLBADFLAG       := 'O'; --���ʱ�־��Y :�����ʣ�O:�����������У�N:�����ʣ�  --����ʱ�޸ı�־
    DBT.RLZNJREDUCFLAG  := RL.RLZNJREDUCFLAG; --���ɽ�����־,δ����ʱΪN������ʱ���ɽ�ֱ�Ӽ��㣻�����ΪY,����ʱ���ɽ�ֱ��ȡrlznj
    DBT.RLMISTID        := RL.RLMISTID; --��ҵ����
    DBT.RLMINAME        := RL.RLMINAME; --Ʊ������
    DBT.RLSXF           := RL.RLSXF; --������
    DBT.RLMIFACE2       := RL.RLMIFACE2; --��������
    DBT.RLMIFACE3       := RL.RLMIFACE3; --�ǳ�����
    DBT.RLMIFACE4       := RL.RLMIFACE4; --����ʩ˵��
    DBT.RLMIIFCKF       := RL.RLMIIFCKF; --�����ѻ���
    DBT.RLMIGPS         := RL.RLMIGPS; --�Ƿ��Ʊ
    DBT.RLMIQFH         := RL.RLMIQFH; --Ǧ���
    DBT.RLMIBOX         := RL.RLMIBOX; --����ˮ�ۣ���ֵ˰ˮ�ۣ���������
    DBT.RLMINAME2       := RL.RLMINAME2; --��������(С��������������
    DBT.RLMISEQNO       := RL.RLMISEQNO; --���ţ���ʼ��ʱ���+��ţ�
    DBT.RLMISAVING      := RL.RLMISAVING; --���ʱԤ��
    DBT.RLPRIORJE       := RL.RLPRIORJE; --���֮ǰǷ��
    DBT.RLMICOMMUNITY   := RL.RLMICOMMUNITY; --С��
    DBT.RLMIREMOTENO    := RL.RLMIREMOTENO; --Զ�����
    DBT.RLMIREMOTEHUBNO := RL.RLMIREMOTEHUBNO; --Զ��HUB��
    DBT.RLMIEMAIL       := RL.RLMIEMAIL; --�����ʼ�
    DBT.RLMIEMAILFLAG   := RL.RLMIEMAILFLAG; --��Ʊ���
    DBT.RLMICOLUMN1     := RL.RLMICOLUMN1; --�����ֶ�1
    DBT.RLMICOLUMN2     := RL.RLMICOLUMN2; --�����ֶ�2(Ԥ��Ʊ��ӡ����)
    DBT.RLMICOLUMN3     := RL.RLMICOLUMN3; --�����ֶ�3
    DBT.RLMICOLUMN4     := RL.RLMICOLUMN4; --�����ֶ�3
    DBT.RLPAIDMONTH     := RL.RLPAIDMONTH; --�����·�
    DBT.DBDAPPNOTE      := ''; --����˵��
    DBT.DBDFILASHNOTE   := ''; --�쵼���
    DBT.DBDMEMO         := ''; --��ע
    DBT.DBDSHFLAG       := 'N'; --����˱�־
    DBT.DBDSHDATE       := ''; --���������
    DBT.DBDSHPER        := ''; --�������

    INSERT INTO DSZBILLDT VALUES DBT;
  END CREATEDT;

  PROCEDURE CREATEDSZBILL(P_DSHNO     IN VARCHAR2, --������ˮ��
                          P_DSHLB     IN VARCHAR2, --�������
                          P_DSHSMFID  IN VARCHAR2, --Ӫ����˾
                          P_DSHDEPT   IN VARCHAR2, --������
                          P_DSHCREPER IN VARCHAR2, --������Ա
                          P_RLID      IN VARCHAR2 --Ӧ����ˮ��
                          ) IS
    RL      RECLIST%ROWTYPE;
    V_ROWID NUMBER(10) := 0; --�к�
    --��λ�α�
    CURSOR C_RL IS
      SELECT T.* FROM RECLIST T, PBPARMTEMP P WHERE RLID = C1;
    --RLID = '';
  BEGIN
    --���뵥ͷ
    CREATEHD(P_DSHNO, --������ˮ��
             P_DSHLB, --�������
             P_DSHSMFID, --Ӫ����˾
             P_DSHDEPT, --������
             P_DSHCREPER --������Ա
             );
    --���뵥��
    OPEN C_RL;
    LOOP
      FETCH C_RL
        INTO RL;
      EXIT WHEN C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL;
      V_ROWID := V_ROWID + 1;
      CREATEDT(P_DSHNO, --������ˮ��
               V_ROWID, --�к�
               RL.RLID --Ӧ����ˮ��
               );
      --�޸Ĵ����ʱ�־
      UPDATE RECLIST SET RECLIST.RLBADFLAG = 'O' WHERE RLID = RL.RLID;
    END LOOP;
    CLOSE C_RL;
    COMMIT;
  END CREATEDSZBILL;

  --ɾ������
  PROCEDURE CANCELBILL(P_BILLNO IN VARCHAR2, --���ݱ��
                       P_PERSON IN VARCHAR2, --����Ա
                       P_DJLB   IN VARCHAR2) IS
    --�������
    CURSOR C_DBH IS
      SELECT *
        FROM DSZBILLHD
       WHERE DBHNO = P_BILLNO
      --and dbhlb = p_djlb
         FOR UPDATE;
    DBH DSZBILLHD%ROWTYPE;
  BEGIN
    OPEN C_DBH;
    FETCH C_DBH
      INTO DBH;
    IF C_DBH%NOTFOUND OR C_DBH%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ�����' || P_BILLNO);
    END IF;
    IF DBH.DBHSHFLAG <> 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ���ȡ��' || P_BILLNO);
    END IF;
    --�޸Ĵ����ʱ�־
    UPDATE RECLIST
       SET RECLIST.RLBADFLAG = 'N'
     WHERE RLID IN (SELECT RLID FROM DSZBILLDT WHERE DBDNO = P_BILLNO);
    --ɾ������
    DELETE FROM DSZBILLDT T WHERE T.DBDNO = P_BILLNO;
    --ɾ����ͷ
    DELETE FROM DSZBILLHD T WHERE T.DBHNO = P_BILLNO;
    CLOSE C_DBH;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_DBH%ISOPEN THEN
        CLOSE C_DBH;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END CANCELBILL;


 --���������
  PROCEDURE CUSTBILLMAIN      (P_CCHNO  IN VARCHAR2, --������ˮ
                     P_PER    IN VARCHAR2, --����Ա
                     P_billid IN VARCHAR2, --����id
                     P_BILLTYPE IN VARCHAR2 --�������
                     ) AS

  BEGIN
               CUSTBILL(P_CCHNO,P_PER,P_BILLTYPE,'N');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;


  --���������
  PROCEDURE CUSTBILL(P_CCHNO  IN VARCHAR2, --������ˮ
                     P_PER    IN VARCHAR2, --����Ա
                     P_BILLTYPE IN VARCHAR2,
                     P_COMMIT IN VARCHAR2 --�ύ��־
                     ) AS
    RL      RECLIST%ROWTYPE;
    DBH     DSZBILLHD%ROWTYPE;
    DBT     DSZBILLDT%ROWTYPE;
    V_ROWID NUMBER(10) := 0; --�к�
    CURSOR C_CUSTDT IS
      SELECT * FROM DSZBILLDT WHERE DBDNO = P_CCHNO FOR UPDATE;
  BEGIN
    BEGIN
      SELECT * INTO DBH FROM DSZBILLHD WHERE DBHNO = P_CCHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�����ͷ��Ϣ������!');
    END;
    IF DBH.DBHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '����������,��������!');
    END IF;
    IF DBH.DBHSHFLAG = 'C' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�������ȡ��,������!');
    END IF;

    OPEN C_CUSTDT;
    LOOP
      FETCH C_CUSTDT
        INTO DBT;
      EXIT WHEN C_CUSTDT%NOTFOUND OR C_CUSTDT%NOTFOUND IS NULL;
      --���µ���
      UPDATE DSZBILLDT
         SET DBDSHFLAG = 'Y', --����˱�־
             DBDSHDATE = SYSDATE, --���������
             DBDSHPER  = P_PER --�������
       WHERE DBDNO = DBT.DBDNO
         AND DBDROWNO = DBT.DBDROWNO;
      --������������ʱ�־
      IF P_BILLTYPE = '8' THEN --�����˱��Ϊ������  add 20140831
        --20140227 ���Ӵ�����Ӧ������  rectrans
            UPDATE RECLIST SET RLBADFLAG = 'Y',RLTRANS='D' WHERE RLID = DBT.RLID;
      else  --�����˱��Ϊ������ add 20140831
            UPDATE RECLIST SET RLBADFLAG = 'N',RLTRANS='D' WHERE RLID = DBT.RLID;
      end if ;
    END LOOP;
    CLOSE C_CUSTDT;
    --��˵�ͷ
    UPDATE DSZBILLHD
       SET DBHSHDATE = SYSDATE, DBHSHPER = P_PER, DBHSHFLAG = 'Y'
     WHERE DBHNO = P_CCHNO;

    /*--��������
    update kpi_task t
       set t.do_date = sysdate, t.isfinish = 'Y'
     where t.report_id = trim(P_CCHNO);*/

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

END;
/

