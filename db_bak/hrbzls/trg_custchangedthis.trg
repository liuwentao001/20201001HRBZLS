CREATE OR REPLACE TRIGGER HRBZLS."TRG_CUSTCHANGEDTHIS"
  after insert on custchangedt
  for each row
DECLARE
  -- local variables here
  V_MIIFMP METERINFO.MIIFMP%TYPE;
  V_COUNT  NUMBER(10);
  PMDT     PRICEMULTIDETAIL%ROWTYPE;
BEGIN

  IF NVL(FSYSPARA('data'), 'N') = 'Y' THEN
    RETURN;
  END IF;
  INSERT INTO CUSTCHANGEDTHIS
    (SELECT :NEW.CCDNO, --������ˮ��
            :NEW.CCDROWNO, --�к�
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
            MI.MIIFCHK, --�����ѻ���
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
            :NEW.PMDCID, --�û����
            :NEW.PMDMID, --ˮ����
            NULL, --�����
            NULL, --�۸����
            NULL, --����
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
            NULL, --�����
            NULL, --�۸����
            NULL, --����
            NULL, --�����
            NULL, --�۸����
            NULL, --����
            NULL, --�����
            NULL, --�۸����
            NULL, --����
            MI.MIIFCKF, --�Ƿ�ſط� �����ѻ���
            MI.MIGPS, --GPS��ַ
            MI.MIQFH, --Ǧ���
            MI.MIBOX, --������
            MA.MAREGDATE, --ǩԼ����
            MI.MINAME, --Ʊ������
            MI.MINAME2, --��������
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
            NULL, --������(01������02����)
            NULL, --�����ֶ�1
            NULL, --�����ֶ�2
            NULL, --�����֣�
            NULL, --������(01������02����)
            NULL, --�����ֶ�1
            NULL, --�����ֶ�2
            NULL, --�����ֶ�3
            NULL, --������(01������02����)
            NULL, --�����ֶ�1
            NULL, --�����ֶ�2
            NULL, --�����ֶ�3
            NULL, --������(01������02����)
            NULL, --�����ֶ�1
            NULL, --�����ֶ�2
            NULL, --�����ֶ�3
            MI.MIPAYMENTID, --���һ��ʵ����ˮ
            MI.MICOLUMN5,
            MI.MICOLUMN6,
            MI.MICOLUMN7,
            MI.MICOLUMN8,
            MI.MICOLUMN9,
            MI.MICOLUMN10,
            MI.MILH,
            MI.MIDYH,
            MI.MIMPH,
            MD.SFH,
            MD.DQSFH,
            MD.DQGFH,
            MD.JCGFH,
            MD.QFH,
            MI.MIYHPJ,
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
            mi.POCID,
            mi.MIBANKNAME,
            mi.MIBANKNO
       FROM CUSTINFO CI, METERINFO MI, METERDOC MD, METERACCOUNT MA
      WHERE MI.MICID = CI.CIID
        AND MI.MIID = MD.MDMID
        AND MI.MIID = MA.MAMID(+)
        AND MI.MIID = :NEW.MIID);

  SELECT MIIFMP INTO V_MIIFMP FROM METERINFO WHERE MIID = :NEW.MIID;
  IF V_MIIFMP = 'Y' THEN
    SELECT COUNT(*)
      INTO V_COUNT
      FROM PRICEMULTIDETAIL
     WHERE PMDMID = :NEW.MIID
       AND PMDID = 1;
    IF V_COUNT > 0 THEN
      SELECT *
        INTO PMDT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = :NEW.MIID
         AND PMDID = 1;
      UPDATE CUSTCHANGEDTHIS
         SET PMDID      = 1,
             PMDPFID    = PMDT.PMDPFID,
             PMDSCALE   = PMDT.PMDSCALE,
             PMDTYPE    = PMDT.PMDTYPE,
             PMDCOLUMN1 = PMDT.PMDCOLUMN1,
             PMDCOLUMN2 = PMDT.PMDCOLUMN2,
             PMDCOLUMN3 = PMDT.PMDCOLUMN3
       WHERE CCDNO = :NEW.CCDNO
         AND CCDROWNO = :NEW.CCDROWNO;
    END IF;
    SELECT COUNT(*)
      INTO V_COUNT
      FROM PRICEMULTIDETAIL
     WHERE PMDMID = :NEW.MIID
       AND PMDID = 2;
    IF V_COUNT > 0 THEN
      SELECT *
        INTO PMDT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = :NEW.MIID
         AND PMDID = 2;
      UPDATE CUSTCHANGEDTHIS
         SET PMDID2      = 2,
             PMDPFID2    = PMDT.PMDPFID,
             PMDSCALE2   = PMDT.PMDSCALE,
             PMDTYPE2    = PMDT.PMDTYPE,
             PMDCOLUMN12 = PMDT.PMDCOLUMN1,
             PMDCOLUMN22 = PMDT.PMDCOLUMN2,
             PMDCOLUMN32 = PMDT.PMDCOLUMN3
       WHERE CCDNO = :NEW.CCDNO
         AND CCDROWNO = :NEW.CCDROWNO;
    END IF;
    SELECT COUNT(*)
      INTO V_COUNT
      FROM PRICEMULTIDETAIL
     WHERE PMDMID = :NEW.MIID
       AND PMDID = 3;
    IF V_COUNT > 0 THEN
      SELECT *
        INTO PMDT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = :NEW.MIID
         AND PMDID = 3;
      UPDATE CUSTCHANGEDTHIS
         SET PMDID3      = 3,
             PMDPFID3    = PMDT.PMDPFID,
             PMDSCALE3   = PMDT.PMDSCALE,
             PMDTYPE3    = PMDT.PMDTYPE,
             PMDCOLUMN13 = PMDT.PMDCOLUMN1,
             PMDCOLUMN23 = PMDT.PMDCOLUMN2,
             PMDCOLUMN33 = PMDT.PMDCOLUMN3
       WHERE CCDNO = :NEW.CCDNO
         AND CCDROWNO = :NEW.CCDROWNO;
    END IF;
    SELECT COUNT(*)
      INTO V_COUNT
      FROM PRICEMULTIDETAIL
     WHERE PMDMID = :NEW.MIID
       AND PMDID = 4;
    IF V_COUNT > 0 THEN
      SELECT *
        INTO PMDT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = :NEW.MIID
         AND PMDID = 4;
      UPDATE CUSTCHANGEDTHIS
         SET PMDID4      = 4,
             PMDPFID4    = PMDT.PMDPFID,
             PMDSCALE4   = PMDT.PMDSCALE,
             PMDTYPE4    = PMDT.PMDTYPE,
             PMDCOLUMN14 = PMDT.PMDCOLUMN1,
             PMDCOLUMN24 = PMDT.PMDCOLUMN2,
             PMDCOLUMN34 = PMDT.PMDCOLUMN3
       WHERE CCDNO = :NEW.CCDNO
         AND CCDROWNO = :NEW.CCDROWNO;
    END IF;
  END IF;

END;
/

