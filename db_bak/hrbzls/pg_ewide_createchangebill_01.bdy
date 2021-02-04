CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_CREATECHANGEBILL_01" IS
  PROCEDURE ���쵥ͷ(P_CCHNO     IN VARCHAR2, --������ˮ��
                 P_CCHLB     IN VARCHAR2, --�������
                 P_CCHSMFID  IN VARCHAR2, --Ӫ����˾
                 P_CCHDEPT   IN VARCHAR2, --������
                 P_CCHCREPER IN VARCHAR2 --������Ա
                 ) IS
    CHH CUSTCHANGEHD%ROWTYPE;
  BEGIN
    --��ֵ ��ͷ
    CHH.CCHNO      := P_CCHNO; --������ˮ��
    CHH.CCHBH      := P_CCHNO; --���ݱ��
    CHH.CCHLB      := P_CCHLB; --�������
    CHH.CCHSOURCE  := '1'; --������Դ
    CHH.CCHSMFID   := P_CCHSMFID; --Ӫ����˾
    CHH.CCHDEPT    := P_CCHDEPT; --������
    CHH.CCHCREDATE := SYSDATE; --��������
    CHH.CCHCREPER  := P_CCHCREPER; --������Ա
    CHH.CCHSHDATE  := NULL; --�������
    CHH.CCHSHPER   := NULL; --�����Ա
    CHH.CCHSHFLAG  := 'N'; --��˱�־
    CHH.CCHWFID    := NULL; --������ʵ��
    INSERT INTO CUSTCHANGEHD VALUES CHH;

  END;
  PROCEDURE ���쵥��(P_CCDNO    IN VARCHAR2, --������ˮ��
                 P_CCDROWNO IN VARCHAR2, --�к�
                 P_MIID     IN VARCHAR2 --ˮ��ID
                 ) IS
    CHD CUSTCHANGEDT%ROWTYPE;
    MI  METERINFO%ROWTYPE;
    CI  CUSTINFO%ROWTYPE;
    MD  METERDOC%ROWTYPE;
    MA  METERACCOUNT%ROWTYPE;
  BEGIN
    --��ѯˮ����Ϣ
    SELECT * INTO MI FROM METERINFO WHERE MIID = P_MIID;

    --��ѯ�û���Ϣ
    SELECT * INTO CI FROM CUSTINFO WHERE CIID = MI.MICID;

    --��ѯˮ����
    SELECT * INTO MD FROM METERDOC WHERE MDMID = P_MIID;

    --��ѯ�����ʺ�
    SELECT * INTO MA FROM METERACCOUNT WHERE MAMID = P_MIID;

    --��ֵ ����
    CHD.CCDNO         := P_CCDNO; --������ˮ��
    CHD.CCDROWNO      := P_CCDROWNO; --�к�
    CHD.CIID          := CI.CIID; --�û����
    CHD.CICODE        := CI.CICODE; --�û���
    CHD.CICONID       := CI.CICONID; --��װ��ͬ���
    CHD.CISMFID       := CI.CISMFID; --Ӫ����˾
    CHD.CIPID         := CI.CIPID; --�ϼ��û����
    CHD.CICLASS       := CI.CICLASS; --�û�����
    CHD.CIFLAG        := CI.CIFLAG; --ĩ����־
    CHD.CINAME        := CI.CINAME; --��Ȩ��
    CHD.CINAME2       := CI.CINAME2; --������
    CHD.CIADR         := CI.CIADR; --�û���ַ
    CHD.CISTATUS      := CI.CISTATUS; --�û�״̬
    CHD.CISTATUSDATE  := CI.CISTATUSDATE; --״̬����
    CHD.CISTATUSTRANS := CI.CISTATUSTRANS; --״̬����
    CHD.CINEWDATE     := CI.CINEWDATE; --��������
    CHD.CIIDENTITYLB  := CI.CIIDENTITYLB; --֤������
    CHD.CIIDENTITYNO  := CI.CIIDENTITYNO; --֤������
    CHD.CIMTEL        := CI.CIMTEL; --�ƶ��绰
    CHD.CITEL1        := CI.CITEL1; --�̶��绰1
    CHD.CITEL2        := CI.CITEL2; --�̶��绰2
    CHD.CITEL3        := CI.CITEL3; --�̶��绰3
    CHD.CICONNECTPER  := CI.CICONNECTPER; --��ϵ��
    CHD.CICONNECTTEL  := CI.CICONNECTTEL; --��ϵ�绰
    CHD.CIIFINV       := CI.CIIFINV; --�Ƿ���Ʊ
    CHD.CIIFSMS       := CI.CIIFSMS; --�Ƿ��ṩ���ŷ���
    CHD.CIIFZN        := CI.CIIFZN; --�Ƿ����ɽ�
    CHD.CIPROJNO      := CI.CIPROJNO; --���̱��
    CHD.CIFILENO      := CI.CIFILENO; --������
    CHD.CIMEMO        := CI.CIMEMO; --��ע��Ϣ
    CHD.CIDEPTID      := CI.CIDEPTID; --��������

    CHD.MICID         := MI.MICID; --�û����
    CHD.MIID          := MI.MIID; --ˮ����
    CHD.MIADR         := MI.MIADR; --���ַ
    CHD.MISAFID       := MI.MISAFID; --����
    CHD.MICODE        := MI.MICODE; --ˮ���ֹ����
    CHD.MISMFID       := MI.MISMFID; --Ӫ����˾
    CHD.MIPRMON       := MI.MIPRMON; --���ڳ����·�
    CHD.MIRMON        := MI.MIRMON; --���ڳ����·�
    CHD.MIBFID        := MI.MIBFID; --���
    CHD.MIRORDER      := MI.MIRORDER; --�������
    CHD.MIPID         := MI.MIPID; --�ϼ�ˮ����
    CHD.MICLASS       := MI.MICLASS; --ˮ����
    CHD.MIFLAG        := MI.MIFLAG; --ĩ����־
    CHD.MIRTID        := MI.MIRTID; --����ʽ
    CHD.MIIFMP        := MI.MIIFMP; --�����ˮ��־
    CHD.MIIFSP        := MI.MIIFSP; --���ⵥ�۱�־
    CHD.MISTID        := MI.MISTID; --��ҵ����
    CHD.MIPFID        := MI.MIPFID; --�۸����
    CHD.MISTATUS      := MI.MISTATUS; --״̬
    CHD.MISTATUSDATE  := MI.MISTATUSDATE; --״̬����
    CHD.MISTATUSTRANS := MI.MISTATUSTRANS; --״̬����
    CHD.MIFACE        := MI.MIFACE; --���
    CHD.MIRPID        := MI.MIRPID; --�Ƽ�����
    CHD.MISIDE        := MI.MISIDE; --��λ
    CHD.MIPOSITION    := MI.MIPOSITION; --ˮ���ˮ��ַ
    CHD.MIINSCODE     := MI.MIINSCODE; --��װ���
    CHD.MIINSDATE     := MI.MIINSDATE; --װ����
    CHD.MIINSPER      := MI.MIINSPER; --��װ��
    CHD.MIREINSCODE   := MI.MIREINSCODE; --�������
    CHD.MIREINSDATE   := MI.MIREINSDATE; --��������
    CHD.MIREINSPER    := MI.MIREINSPER; --������
    CHD.MITYPE        := MI.MITYPE; --����
    CHD.MIRCODE       := MI.MIRCODE; --���ڶ���
    CHD.MIRECDATE     := MI.MIRECDATE; --���ڳ�������
    CHD.MIRECSL       := MI.MIRECSL; --���ڳ���ˮ��
    CHD.MIIFCHARGE    := MI.MIIFCHARGE; --�Ƿ�Ʒ�
    CHD.MIIFSL        := MI.MIIFSL; --�Ƿ����
    CHD.MIIFCHK       := MI.MIIFCHK; --�Ƿ񿼺˱�
    CHD.MIIFWATCH     := MI.MIIFWATCH; --�Ƿ��ˮ
    CHD.MIICNO        := MI.MIICNO; --IC����
    CHD.MIMEMO        := MI.MIMEMO; --��ע��Ϣ
    CHD.MIPRIID       := MI.MIPRIID; --���ձ������
    CHD.MIPRIFLAG     := MI.MIPRIFLAG; --���ձ��־
    CHD.MIUSENUM      := MI.MIUSENUM; --��������
    CHD.MICHARGETYPE  := MI.MICHARGETYPE; --�շѷ�ʽ
    CHD.MISAVING      := MI.MISAVING; --Ԥ������
    CHD.MILB          := MI.MILB; --ˮ�����
    CHD.MINEWFLAG     := MI.MINEWFLAG; --�±��־
    CHD.MICPER        := MI.MICPER; --�շ�Ա
    CHD.MIIFTAX       := MI.MIIFTAX; --�Ƿ�˰Ʊ
    CHD.MITAXNO       := MI.MITAXNO; --��ֵ˰�ţ�����

    /*      CHD.PMDCID                      :=        ;--�û����
    CHD.PMDMID                      :=        ;--ˮ����
    CHD.PMDID                       :=        ;--�����
    CHD.PMDPFID                     :=        ;--�۸����
    CHD.PMDSCALE                    :=        ;--���� */
    CHD.MDMID        := MD.MDMID; --ˮ���
    CHD.MDNO         := MD.MDNO; --������
    CHD.MDCALIBER    := MD.MDCALIBER; --��ھ�
    CHD.MDBRAND      := MD.MDBRAND; --����
    CHD.MDMODEL      := MD.MDMODEL; --���ͺ�
    CHD.MDSTATUS     := MD.MDSTATUS; --��״̬
    CHD.MDSTATUSDATE := MD.MDSTATUSDATE; --��״̬����ʱ��

    CHD.MAMID         := MA.MAMID; --ˮ�����Ϻ�
    CHD.MANO          := MA.MANO; --ί����Ȩ��
    CHD.MANONAME      := MA.MANONAME; --ǩԼ����
    CHD.MABANKID      := MA.MABANKID; --�����У����У�
    CHD.MAACCOUNTNO   := MA.MAACCOUNTNO; --�����ʺţ����У�
    CHD.MAACCOUNTNAME := MA.MAACCOUNTNAME; --�����������У�
    CHD.MATSBANKID    := MA.MATSBANKID; --�����кţ��У�
    CHD.MATSBANKNAME  := MA.MATSBANKNAME; --ƾ֤���У��У�
    CHD.MAIFXEZF      := MA.MAIFXEZF; --С��֧�����У�

    /*CHD.PMDID2                      :=        ;--�����
    CHD.PMDPFID2                    :=        ;--�۸����
    CHD.PMDSCALE2                   :=        ;--����
    CHD.PMDID3                      :=        ;--�����
    CHD.PMDPFID3                    :=        ;--�۸����
    CHD.PMDSCALE3                   :=        ;--����
    CHD.PMDID4                      :=        ;--�����
    CHD.PMDPFID4                    :=        ;--�۸����
    CHD.PMDSCALE4                   :=        ;--����           */
    CHD.CCDSHFLAG := 'N'; --����˱�־
    --CHD.CCDSHDATE                   :=   ''     ;--���������
    --CHD.CCDSHPER                    :=        ;--�������
    CHD.MIIFCKF := MI.MIIFCKF; --�Ƿ�ſط�
    CHD.MIGPS   := MI.MIGPS; --GPS��ַ
    CHD.MIQFH   := MI.MIQFH; --Ǧ���
    CHD.MIBOX   := MI.MIBOX; --������

    /*CHD.CCDAPPNOTE                  :=        ;--����˵��
    CHD.CCDFILASHNOTE               :=        ;--�쵼���
    CHD.CCDMEMO                     :=        ;--��ע      */
    CHD.MAREGDATE := MA.MAREGDATE; --ǩԼ����
    CHD.MINAME    := MI.MINAME; --Ʊ������
    CHD.MINAME2   := MI.MINAME2; --��������
    /*CHD.ACCESSORYFLAG01             :=        ;--ԭ�������֤��ӡ��
    CHD.ACCESSORYFLAG02             :=        ;--�»������֤��ӡ��
    CHD.ACCESSORYFLAG03             :=        ;--���������֤��ӡ��
    CHD.ACCESSORYFLAG04             :=        ;--ˮ�ѵ�����
    CHD.ACCESSORYFLAG05             :=        ;--�޺�ͬ��ӡ��
    CHD.ACCESSORYFLAG06             :=        ;--����֤�򹺷���ͬ��ӡ��
    CHD.ACCESSORYFLAG07             :=        ;--��ҵ����Ӫҵִ�գ�����֯��������֤����ӡ��һ��
    CHD.ACCESSORYFLAG08             :=        ;--����
    CHD.ACCESSORYFLAG09             :=        ;--���֤��ӡ��
    CHD.ACCESSORYFLAG10             :=        ;--�û�������
    CHD.ACCESSORYFLAG11             :=        ;--������־11
    CHD.ACCESSORYFLAG12             :=        ;--������־12  */
    --CHD.MABANKCODE                  :=MA.MABANKCODE        ;--�û��кţ��У�
    --CHD.MABANKNAME                  :=MA.MABANKNAME        ;--�û��������У�
    CHD.MISEQNO  := MI.MISEQNO; --���ţ���ʼ��ʱ���+��ţ�
    CHD.MIJFKROW := MI.MIJFKROW; --�����׶�
    CHD.MIUIID   := MI.MIUIID; --���յ�λ���

    INSERT INTO CUSTCHANGEDT VALUES CHD;
  END;

  PROCEDURE ���쵥���û���ͨ�������(P_CCHNO     IN VARCHAR2, --������ˮ��
                         P_CCHLB     IN VARCHAR2, --�������
                         P_CCHSMFID  IN VARCHAR2, --Ӫ����˾
                         P_CCHDEPT   IN VARCHAR2, --������
                         P_CCHCREPER IN VARCHAR2, --������Ա
                         P_MIGPS     IN VARCHAR2, --��ͨ����
                         P_MIID      IN VARCHAR2 --ˮ��ID
                         ) IS
    MI      METERINFO%ROWTYPE;
    CDW     CUSTDWDM%ROWTYPE;
    V_ROWID NUMBER(10) := 0; --�к�

  BEGIN

    --���뵥ͷ
    ���쵥ͷ(P_CCHNO, --������ˮ��
         P_CCHLB, --�������
         P_CCHSMFID, --Ӫ����˾
         P_CCHDEPT, --������
         P_CCHCREPER --������Ա
         );
    --���뵥��

    ���쵥��(P_CCHNO, --������ˮ��
         1, --�к�
         P_MIID --ˮ��ID
         );

    --��������Ϣ

    UPDATE CUSTCHANGEDT SET MIGPS = P_MIGPS WHERE CCDNO = P_CCHNO;
    --ģ�����
    UPDATE CUSTCHANGEHD
       SET CCHSHDATE = SYSDATE, CCHSHPER = P_CCHCREPER, CCHSHFLAG = 'Y'
     WHERE CCHNO = P_CCHNO;
    --�����û���Ϣ����
    UPDATE METERINFO SET MIGPS = P_MIGPS WHERE MIID = P_MIID;

  END;

  PROCEDURE ���쵥λ��������(P_CCHNO     IN VARCHAR2, --������ˮ��
                      P_CCHLB     IN VARCHAR2, --�������
                      P_CCHSMFID  IN VARCHAR2, --Ӫ����˾
                      P_CCHDEPT   IN VARCHAR2, --������
                      P_CCHCREPER IN VARCHAR2, --������Ա
                      P_MIUIID    IN VARCHAR2 --��λ����
                      ) IS
    MI      METERINFO%ROWTYPE;
    CDW     CUSTDWDM%ROWTYPE;
    V_ROWID NUMBER(10) := 0; --�к�
    --��λ�α�
    CURSOR C_MI IS
      SELECT * FROM METERINFO WHERE MIUIID = P_MIUIID;
  BEGIN

    /*  --����
    UPDATE CUSTDWDM T
       SET CDMAACCOUNTNAME = '���ݵϿ���ģ�������޹�˾TEST'
     WHERE CDMID = P_MIUIID;*/

    --���뵥ͷ
    ���쵥ͷ(P_CCHNO, --������ˮ��
         P_CCHLB, --�������
         P_CCHSMFID, --Ӫ����˾
         P_CCHDEPT, --������
         P_CCHCREPER --������Ա
         );
    --���뵥��
    OPEN C_MI;
    LOOP
      FETCH C_MI
        INTO MI;
      EXIT WHEN C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL;
      V_ROWID := V_ROWID + 1;
      ���쵥��(P_CCHNO, --������ˮ��
           V_ROWID, --�к�
           MI.MIID --ˮ��ID
           );
    END LOOP;
    CLOSE C_MI;
    SELECT * INTO CDW FROM CUSTDWDM WHERE CDMID = P_MIUIID;
    --��������Ϣ

    UPDATE CUSTCHANGEDT
       SET MABANKID      = CDW.CDMABANKID,
           MAACCOUNTNO   = CDW.CDMAACCOUNTNO,
           MAACCOUNTNAME = CDW.CDMAACCOUNTNAME,
           MATSBANKID    = CDW.CDMATSBANKID,
           MANO          = CDW.CDMANO,
           /*  CIADR         = CDW.CDTXDZ,*/
           MIIFTAX = CDW.CDIFTAX,
           MITAXNO = CDW.CDTAXNO /* ,
              CICONNECTPER  = CDW.CDONNECTPER,
               CICONNECTTEL  = CDW.CDCONNECTTEL*/
     WHERE CCDNO = P_CCHNO;

    --���ñ������
    PG_EWIDE_CUSTBASE_01.APPROVE(P_CCHNO, P_CCHCREPER, P_CCHLB);

  END;

  PROCEDURE ���쵥���û���λ�����(P_CCHNO     IN VARCHAR2, --������ˮ��
                        P_CCHLB     IN VARCHAR2, --�������
                        P_CCHSMFID  IN VARCHAR2, --Ӫ����˾
                        P_CCHDEPT   IN VARCHAR2, --������
                        P_CCHCREPER IN VARCHAR2, --������Ա
                        P_MIUIID    IN VARCHAR2, --��λ����
                        P_MIID      IN VARCHAR2 --ˮ��ID
                        ) IS
    MI      METERINFO%ROWTYPE;
    CDW     CUSTDWDM%ROWTYPE;
    V_ROWID NUMBER(10) := 0; --�к�

  BEGIN

    --���뵥ͷ
    ���쵥ͷ(P_CCHNO, --������ˮ��
         P_CCHLB, --�������
         P_CCHSMFID, --Ӫ����˾
         P_CCHDEPT, --������
         P_CCHCREPER --������Ա
         );
    --���뵥��

    ���쵥��(P_CCHNO, --������ˮ��
         1, --�к�
         P_MIID --ˮ��ID
         );

    SELECT * INTO CDW FROM CUSTDWDM WHERE CDMID = P_MIUIID;
    --��������Ϣ

    UPDATE CUSTCHANGEDT
       SET MABANKID      = CDW.CDMABANKID,
           MAACCOUNTNO   = CDW.CDMAACCOUNTNO,
           MAACCOUNTNAME = CDW.CDMAACCOUNTNAME,
           MATSBANKID    = CDW.CDMATSBANKID,
           MIUIID        = P_MIUIID,
           MANO          = CDW.CDMANO,
           CIADR         = CDW.CDTXDZ,
           MIIFTAX       = CDW.CDIFTAX,
           MITAXNO       = CDW.CDTAXNO,
           CICONNECTPER  = CDW.CDONNECTPER,
           CICONNECTTEL  = CDW.CDCONNECTTEL
     WHERE CCDNO = P_CCHNO;

    --���ñ������
    PG_EWIDE_CUSTBASE_01.APPROVE(P_CCHNO, P_CCHCREPER, P_CCHLB);

  END;
  PROCEDURE ���쵥���û���λɾ��(P_CCHNO     IN VARCHAR2, --������ˮ��
                       P_CCHLB     IN VARCHAR2, --�������
                       P_CCHSMFID  IN VARCHAR2, --Ӫ����˾
                       P_CCHDEPT   IN VARCHAR2, --������
                       P_CCHCREPER IN VARCHAR2, --������Ա
                       P_MIID      IN VARCHAR2 --ˮ��ID
                       ) IS
    MI      METERINFO%ROWTYPE;
    CDW     CUSTDWDM%ROWTYPE;
    V_ROWID NUMBER(10) := 0; --�к�

  BEGIN

    --���뵥ͷ
    ���쵥ͷ(P_CCHNO, --������ˮ��
         P_CCHLB, --�������
         P_CCHSMFID, --Ӫ����˾
         P_CCHDEPT, --������
         P_CCHCREPER --������Ա
         );
    --���뵥��

    ���쵥��(P_CCHNO, --������ˮ��
         1, --�к�
         P_MIID --ˮ��ID
         );

    --��������Ϣ
    UPDATE CUSTCHANGEDT
       SET MABANKID      = '',
           MAACCOUNTNO   = '',
           MAACCOUNTNAME = '',
           MATSBANKID    = '',
           MIUIID        = ''
     WHERE CCDNO = P_CCHNO;

    --���ñ������
    PG_EWIDE_CUSTBASE_01.APPROVE(P_CCHNO, P_CCHCREPER, P_CCHLB);

  END;

  --�����û���Ϣ�����
  PROCEDURE SP_NEWCUSTMETERBILL(P_CCDNO    IN VARCHAR2,
                                P_CCDROWNO IN NUMBER,
                                P_MIID     IN VARCHAR2) IS
    V_MIIFMP METERINFO.MIIFMP%TYPE;
    V_COUNT  NUMBER(10);
    PMDT     PRICEMULTIDETAIL%ROWTYPE;
  
    V_PMDID    PRICEMULTIDETAIL.PMDID%TYPE;
    V_PMDPFID  PRICEMULTIDETAIL.PMDPFID%TYPE;
    V_PMDSCALE PRICEMULTIDETAIL.PMDSCALE%TYPE;
  
    V_PMDID2    PRICEMULTIDETAIL.PMDID%TYPE;
    V_PMDPFID2  PRICEMULTIDETAIL.PMDPFID%TYPE;
    V_PMDSCALE2 PRICEMULTIDETAIL.PMDSCALE%TYPE;
  
    V_PMDID3    PRICEMULTIDETAIL.PMDID%TYPE;
    V_PMDPFID3  PRICEMULTIDETAIL.PMDPFID%TYPE;
    V_PMDSCALE3 PRICEMULTIDETAIL.PMDSCALE%TYPE;
  
    V_PMDID4    PRICEMULTIDETAIL.PMDID%TYPE;
    V_PMDPFID4  PRICEMULTIDETAIL.PMDPFID%TYPE;
    V_PMDSCALE4 PRICEMULTIDETAIL.PMDSCALE%TYPE;
  
    V_PMDTYPE     CUSTCHANGEDT.PMDTYPE%TYPE; -- ������(01������02����)
    V_PMDCOLUMN1  CUSTCHANGEDT.PMDCOLUMN1%TYPE; -- �����ֶ�1
    V_PMDCOLUMN2  CUSTCHANGEDT.PMDCOLUMN2%TYPE; -- �����ֶ�2
    V_PMDCOLUMN3  CUSTCHANGEDT.PMDCOLUMN3%TYPE; -- �����ֶ�3
    V_PMDTYPE2    CUSTCHANGEDT.PMDTYPE2%TYPE; -- ������(01������02����)
    V_PMDCOLUMN12 CUSTCHANGEDT.PMDCOLUMN12%TYPE; -- �����ֶ�1
    V_PMDCOLUMN22 CUSTCHANGEDT.PMDCOLUMN22%TYPE; -- �����ֶ�2
    V_PMDCOLUMN32 CUSTCHANGEDT.PMDCOLUMN32%TYPE; -- �����ֶ�3
    V_PMDTYPE3    CUSTCHANGEDT.PMDTYPE3%TYPE; -- ������(01������02����)
    V_PMDCOLUMN13 CUSTCHANGEDT.PMDCOLUMN13%TYPE; -- �����ֶ�1
    V_PMDCOLUMN23 CUSTCHANGEDT.PMDCOLUMN23%TYPE; -- �����ֶ�2
    V_PMDCOLUMN33 CUSTCHANGEDT.PMDCOLUMN33%TYPE; -- �����ֶ�3
    V_PMDTYPE4    CUSTCHANGEDT.PMDTYPE4%TYPE; -- ������(01������02����)
    V_PMDCOLUMN14 CUSTCHANGEDT.PMDCOLUMN14%TYPE; -- �����ֶ�1
    V_PMDCOLUMN24 CUSTCHANGEDT.PMDCOLUMN24%TYPE; -- �����ֶ�2
    V_PMDCOLUMN34 CUSTCHANGEDT.PMDCOLUMN34%TYPE; -- �����ֶ�3
  
  BEGIN
  
    SELECT MIIFMP INTO V_MIIFMP FROM METERINFO WHERE MIID = P_MIID;
    IF V_MIIFMP = 'Y' THEN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = P_MIID
         AND PMDID = 1;
      IF V_COUNT > 0 THEN
        SELECT *
          INTO PMDT
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = P_MIID
           AND PMDID = 1;
        /*UPDATE CUSTCHANGEDTHIS
          SET PMDID = 1, PMDPFID = PMDT.PMDPFID, PMDSCALE = PMDT.PMDSCALE
        WHERE CCDNO = p_CCDNO
          AND CCDROWNO = p_CCDROWNO;*/
      
        V_PMDID      := 1;
        V_PMDPFID    := PMDT.PMDPFID;
        V_PMDSCALE   := PMDT.PMDSCALE;
        V_PMDID      := PMDT.PMDID;
        V_PMDTYPE    := PMDT.PMDTYPE;
        V_PMDCOLUMN1 := PMDT.PMDCOLUMN1;
        V_PMDCOLUMN2 := PMDT.PMDCOLUMN2;
        V_PMDCOLUMN3 := PMDT.PMDCOLUMN3;
      END IF;
      SELECT COUNT(*)
        INTO V_COUNT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = P_MIID
         AND PMDID = 2;
      IF V_COUNT > 0 THEN
        SELECT *
          INTO PMDT
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = P_MIID
           AND PMDID = 2;
        /*UPDATE CUSTCHANGEDTHIS
          SET PMDID2 = 2, PMDPFID2 = PMDT.PMDPFID, PMDSCALE2 = PMDT.PMDSCALE
        WHERE CCDNO = p_CCDNO
          AND CCDROWNO = p_CCDROWNO;*/
        V_PMDID2      := 2;
        V_PMDPFID2    := PMDT.PMDPFID;
        V_PMDSCALE2   := PMDT.PMDSCALE;
        V_PMDID2      := PMDT.PMDID;
        V_PMDTYPE2    := PMDT.PMDTYPE;
        V_PMDCOLUMN12 := PMDT.PMDCOLUMN1;
        V_PMDCOLUMN22 := PMDT.PMDCOLUMN2;
        V_PMDCOLUMN32 := PMDT.PMDCOLUMN3;
      
      END IF;
      SELECT COUNT(*)
        INTO V_COUNT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = P_MIID
         AND PMDID = 3;
      IF V_COUNT > 0 THEN
        SELECT *
          INTO PMDT
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = P_MIID
           AND PMDID = 3;
        /*UPDATE CUSTCHANGEDTHIS
          SET PMDID3 = 3, PMDPFID3 = PMDT.PMDPFID, PMDSCALE3 = PMDT.PMDSCALE
        WHERE CCDNO = p_CCDNO
          AND CCDROWNO = p_CCDROWNO;*/
      
        V_PMDID3      := 3;
        V_PMDPFID3    := PMDT.PMDPFID;
        V_PMDSCALE3   := PMDT.PMDSCALE;
        V_PMDID3      := PMDT.PMDID;
        V_PMDTYPE3    := PMDT.PMDTYPE;
        V_PMDCOLUMN13 := PMDT.PMDCOLUMN1;
        V_PMDCOLUMN23 := PMDT.PMDCOLUMN2;
        V_PMDCOLUMN33 := PMDT.PMDCOLUMN3;
      
      END IF;
      SELECT COUNT(*)
        INTO V_COUNT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = P_MIID
         AND PMDID = 4;
      IF V_COUNT > 0 THEN
        SELECT *
          INTO PMDT
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = P_MIID
           AND PMDID = 4;
        /*UPDATE CUSTCHANGEDTHIS
          SET PMDID4 = 4, PMDPFID4 = PMDT.PMDPFID, PMDSCALE4 = PMDT.PMDSCALE
        WHERE CCDNO = p_CCDNO
          AND CCDROWNO = p_CCDROWNO;*/
      
        V_PMDID4      := 4;
        V_PMDPFID4    := PMDT.PMDPFID;
        V_PMDSCALE4   := PMDT.PMDSCALE;
        V_PMDID4      := PMDT.PMDID;
        V_PMDTYPE4    := PMDT.PMDTYPE;
        V_PMDCOLUMN14 := PMDT.PMDCOLUMN1;
        V_PMDCOLUMN24 := PMDT.PMDCOLUMN2;
        V_PMDCOLUMN34 := PMDT.PMDCOLUMN3;
      
      END IF;
    END IF;
  
    INSERT INTO CUSTCHANGEDT
      (SELECT P_CCDNO, --������ˮ�� 
              P_CCDROWNO, --�к� 
              CI.CIID, --�û����
              CI.CICODE, --�û���
              CI.CICONID, --��װ��ͬ���
              CI.CISMFID, --Ӫ����˾
              CI.CIPID, --�ϼ��û����
              CI.CICLASS, --�û�����
              CI.CIFLAG, --ĩ����־
              CI.CINAME, --�û�����
              CI.CINAME2, --������
              CI.CIADR, --�û���ַ
              CI.CISTATUS, --�û�״̬
              CI.CISTATUSDATE, --״̬����
              CI.CISTATUSTRANS, --״̬����
              CI.CINEWDATE, --��������
              CI.CIIDENTITYLB, --֤������
              CI.CIIDENTITYNO, --֤������
              CI.CIMTEL, --�ƶ��绰
              CI.CITEL1, --�̶��绰1
              CI.CITEL2, --�̶��绰2
              CI.CITEL3, --�̶��绰3
              CI.CICONNECTPER, --��ϵ��
              CI.CICONNECTTEL, --��ϵ�绰
              CI.CIIFINV, --�Ƿ���Ʊ
              CI.CIIFSMS, --�Ƿ��ṩ���ŷ���
              CI.CIIFZN, --�Ƿ����ɽ�
              CI.CIPROJNO, --���̱��
              CI.CIFILENO, --������
              CI.CIMEMO, --��ע��Ϣ
              CI.CIDEPTID, --��������
              MI.MICID, --�û����
              MI.MIID, --ˮ����
              MI.MIADR, --���ַ
              MI.MISAFID, --����
              MI.MICODE, --ˮ���ֹ����
              MI.MISMFID, --Ӫ����˾
              MI.MIPRMON, --���ڳ����·�
              MI.MIRMON, --���ڳ����·�
              MI.MIBFID, --���
              MI.MIRORDER, --�������
              MI.MIPID, --�ϼ�ˮ����
              MI.MICLASS, --ˮ����
              MI.MIFLAG, --ĩ����־
              MI.MIRTID, --����ʽ
              MI.MIIFMP, --�����ˮ��־
              MI.MIIFSP, --���ⵥ�۱�־
              MI.MISTID, --��ҵ����
              MI.MIPFID, --�۸����
              MI.MISTATUS, --��Ч״̬
              MI.MISTATUSDATE, --״̬����
              MI.MISTATUSTRANS, --״̬����
              MI.MIFACE, --���
              MI.MIRPID, --�Ƽ�����
              MI.MISIDE, --��λ
              MI.MIPOSITION, --ˮ���ˮ��ַ
              MI.MIINSCODE, --��װ���
              MI.MIINSDATE, --װ������
              MI.MIINSPER, --��װ��
              MI.MIREINSCODE, --�������
              MI.MIREINSDATE, --��������
              MI.MIREINSPER, --������
              MI.MITYPE, --����
              MI.MIRCODE, --���ڶ���
              MI.MIRECDATE, --���ڳ�������
              MI.MIRECSL, --���ڳ���ˮ��
              MI.MIIFCHARGE, --�Ƿ�Ʒ�
              MI.MIIFSL, --�Ƿ����
              MI.MIIFCHK, --�Ƿ񿼺˱�
              MI.MIIFWATCH, --�Ƿ��ˮ
              MI.MIICNO, --IC����
              MI.MIMEMO, --��ע��Ϣ
              MI.MIPRIID, --���ձ������
              MI.MIPRIFLAG, --���ձ��־
              MI.MIUSENUM, --��������
              MI.MICHARGETYPE, --�շѷ�ʽ
              MI.MISAVING, --Ԥ������
              MI.MILB, --ˮ�����
              MI.MINEWFLAG, --�±��־
              MI.MICPER, --�շ�Ա
              MI.MIIFTAX, --�Ƿ�˰Ʊ
              MI.MITAXNO, --˰��
              CI.CIID, --�û���� 
              MI.MIID, --ˮ���� 
              V_PMDID, --����� 
              V_PMDPFID, --�۸���� 
              V_PMDSCALE, --���� 
              MD.MDMID, --ˮ��� 
              MD.MDNO, --������ 
              MD.MDCALIBER, --��ھ� 
              MD.MDBRAND, --���� 
              MD.MDMODEL, --���ͺ� 
              MD.MDSTATUS, --��״̬ 
              MD.MDSTATUSDATE, --��״̬����ʱ�� 
              MA.MAMID, --ˮ�����Ϻ�
              MA.MANO, --ί����Ȩ��
              MA.MANONAME, --ǩԼ����
              MA.MABANKID, --�����У����У�
              MA.MAACCOUNTNO, --�����ʺţ����У�
              MA.MAACCOUNTNAME, --�����������У�
              MA.MATSBANKID, --�����кţ��У�
              MA.MATSBANKNAME, --ƾ֤���У��У�
              MA.MAIFXEZF, --С��֧�����У�
              V_PMDID2, --����� 
              V_PMDPFID2, --�۸���� 
              V_PMDSCALE2, --���� 
              V_PMDID3, --����� 
              V_PMDPFID3, --�۸���� 
              V_PMDSCALE3, --���� 
              V_PMDID4, --����� 
              V_PMDPFID4, --�۸���� 
              V_PMDSCALE4, --���� 
              'N', --����˱�־
              NULL, --���������
              NULL, --�������
              MI.MIIFCKF, --�Ƿ�ſط�
              MI.MIGPS, --GPS��ַ
              MI.MIQFH, --Ǧ���
              MI.MIBOX, --������
              NULL, --����˵��
              NULL, --�쵼���
              NULL, --��ע
              MA.MAREGDATE, --ǩԼ����
              MI.MINAME, --Ʊ������
              MI.MINAME2, --��������
              NULL, --ԭ�������֤��ӡ��
              NULL, --�»������֤��ӡ��
              NULL, --���������֤��ӡ��
              NULL, --ˮ�ѵ�����
              NULL, --�޺�ͬ��ӡ��
              NULL, --����֤�򹺷���ͬ��ӡ��
              NULL, --��ҵ����Ӫҵִ�գ�����֯��������֤����ӡ��һ��
              NULL, --����
              NULL, --���֤��ӡ��
              NULL, --�û�������
              NULL, --������־11
              NULL, --������־12
              NULL, --�û��кţ��У�
              NULL, --�û��������У�
              MI.MISEQNO, --����
              MI.MIJFKROW, --�����׶�
              MI.MIUIID, --���յ�λ���
              MI.MICOMMUNITY, --С��
              MI.MIREMOTENO, --Զ�����
              MI.MIREMOTEHUBNO, --Զ����HUB��
              MI.MIEMAIL, --�����ʼ�
              MI.MIEMAILFLAG, --�����Ƿ��ʼ�
              MI.MICOLUMN1, --�����ֶ�1
              MI.MICOLUMN2, --�����ֶ�2
              MI.MICOLUMN3, --�����ֶ�3
              MI.MICOLUMN4, --�����ֶ�4
              V_PMDTYPE, --������(01������02����)
              V_PMDCOLUMN1, --�����ֶ�1
              V_PMDCOLUMN2, --�����ֶ�2
              V_PMDCOLUMN3, --�����ֶ�3
              V_PMDTYPE2, --������(01������02����)
              V_PMDCOLUMN12, --�����ֶ�1
              V_PMDCOLUMN22, --�����ֶ�2
              V_PMDCOLUMN32, --�����ֶ�3
              V_PMDTYPE3, --������(01������02����)
              V_PMDCOLUMN13, --�����ֶ�1
              V_PMDCOLUMN23, --�����ֶ�2
              V_PMDCOLUMN33, --�����ֶ�3
              V_PMDTYPE4, --������(01������02����)
              V_PMDCOLUMN14, --�����ֶ�1
              V_PMDCOLUMN24, --�����ֶ�2
              V_PMDCOLUMN34, --�����ֶ�3
              MI.MIPAYMENTID, --���һ��ʵ����ˮ
              MI.MICOLUMN5, --�����ֶ�5 
              MI.MICOLUMN6, --�����ֶ�6 
              MI.MICOLUMN7, --�����ֶ�7 
              MI.MICOLUMN8, --�����ֶ�8 
              MI.MICOLUMN9, --�����ֶ�9 
              MI.MICOLUMN10, --�����ֶ�10 
              MI.milh, -- ¥��
              MI.midyh, --��Ԫ��
              MI.mimph, --���ƺ�
              sfh, --�׷��
              dqsfh, -- �����ܷ��
              dqgfh, -- �����ַ��
              jcgfh, --����շ��
              qfh, --Ǧ��š���������
              MI.MIYHPJ, --�û���������
              MI.mijd, --�ֵ�
              MI.miface2, --�����
              MD.BARCODE,
              MD.RFID,
              MD.IFDZSB,
              MI.MIIFZDH,
              MI.MIDBZJH,
              MI.MIYL1,
              MI.MIYL2,
              MI.MIYL3,
              MI.MIYL4,
              MI.MIYL5,
              MI.MIYL6,
              MI.MIYL7,
              MI.MIYL8,
              MI.MIYL9,
              MI.MIYL10,
              MI.MIYL11,
              MI.MIYL12,
              MI.MIYL13,
              mi.MICOLUMN11,
              mi.MITKZJH,
              mi.MIHTBH,  --����Ϊ��ͬ�����ֶ�
              mi.MIHTZQ,
              mi.MIRQXZ,
              mi.HTDATE,
              mi.ZFDATE,
            mi.JZDATE,
            mi.SIGNPER,
            mi.SIGNID,
            mi.POCID,   --
            mi.mibankname,
            mi.mibankno
         FROM CUSTINFO CI, METERINFO MI, METERDOC MD, METERACCOUNT MA
        WHERE MI.MICID = CI.CIID
          AND MI.MIID = MD.MDMID
          AND MI.MIID = MA.MAMID(+)
          AND MI.MIID = P_MIID);
  
  END;
END;
/

