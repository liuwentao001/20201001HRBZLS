CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_CBJ AS
with
cbj_t1 as
(
  SELECT RLPRIMCODE,
        NVL(SUM(RLJE), 0) DIS_JE, --Ƿ�ѽ��
        COUNT(RLID) DIS_C, --Ƿ�ѱ���
        TO_CHAR(MIN(RLDATE), 'YYYYMMDD') DIS_M --����Ƿ���·�
   FROM RECLIST RL,HRBCBJ T1,METERINFO MI
  WHERE RLPAIDFLAG = 'N'
    AND RLJE > 0
    AND RLREVERSEFLAG = 'N'
    AND RLBADFLAG = 'N'
    --AND RL.RLPRIMCODE=MI.MIPRIID
    AND RLMID=MIID
    AND MI.MIID=T1.C1
  GROUP BY RLPRIMCODE
),
 P AS
(
    SELECT PMID, MAX(PDATETIME) PDATETIME, SUM(PPAYMENT) PPAYMENT
      FROM PAYMENT X
     WHERE (PMID, PBATCH)  in
     (SELECT PMID, max(PBATCH) pbatch FROM PAYMENT, HRBCBJ t2
     WHERE     PREVERSEFLAG = 'N'
       AND PTRANS <> 'U'
       and  PMID = t2.c1
       group by PMID)
     GROUP BY PMID
)
SELECT MIID || CHR(3) || --  ˮ����C1,
        BARCODE || CHR(3) || --  ԭˮ�˱�ʶ��C2,
        MISAFID || CHR(3) || --  ����C3,
        SUBSTR(BFMONTH, 1, 4) || SUBSTR(BFMONTH, 6, 2) || CHR(3) || --  �����·�C4,
        MICOLUMN4 || CHR(3) || --  �û�����C5,
        MIBFID || CHR(3) || --  ���C6,
        MIRORDER || CHR(3) || --  �������C7,
        BFRPER || CHR(3) || --  ����Ա���C8,
        FGETOPERNAME(BFRPER) || CHR(3) || --  ����Ա����C9,
        NULL || CHR(3) || --  Ӧ������C10,
        NVL(MRBFDAY, 0) || CHR(3) || --  ƫ������C11,
        NVL(MRFACE, '01') || CHR(3) || --  ��̬C12,
        NVL(MRFACE2, '01') || CHR(3) || --  ���C13,
        DECODE(MISTATUS, '29', NVL(MICOLUMN5, 0), '30', NVL(MICOLUMN5, 0), 0) ||
        CHR(3) || --  �̶���C14,
        DECODE(NVL(MRREADOK, 'N'), 'Y', '1', 'N', '0') || CHR(3) || --  �Ƿ�������C15,
        DECODE(NVL(MRREADOK, 'N'), 'Y', '1', 'N', '0') || CHR(3) || --  ������־C16,
        trim(MINAME) || CHR(3) || --  �û���C17,
        trim(MIADR) || CHR(3) || --  �û���ַC18,
        to_char(MD.Mdcaliber) || CHR(3) ||--��Ŀھ�
        MISIDE || CHR(3) || --  ��λC20,
        DQSFH || CHR(3) || --  ���1C21,
        DQGFH || CHR(3) || --  ���2C22,
        JCGFH || CHR(3) || --  ���3C23,
        QFH || CHR(3) || --  ���4C24,
        (SELECT BARCODE FROM GMBARCODE T WHERE BARSMFID = MISMFID) || CHR(3) || --  ����Ա����C25,
        MIUSENUM || CHR(3) || --  �˿���C26,
        MICLASS || CHR(3) || --  �ֱܷ���ձ�־C27,
        MIPID || CHR(3) || --  �ֱܷ��ܱ��C28,
        MIPRIFLAG || CHR(3) || --  ���ձ��־C29,
        MIPRIID || CHR(3) || --  ���ձ������C30,
        CITEL1 || CHR(3) || --  �绰C31,
        CIMTEL || CHR(3) || --  �ֻ�C32,
        '0' || CHR(3) || --  ˮ����Ϣ�Ƿ��ϴ�C33,
        RFID || CHR(3) || --  ���ӱ�ǩC34,
        '0' || CHR(3) || --  ���ӱ�ǩ�Ƿ�ƥ��C35,
        -- null||  CHR(3) || -- �û���C36,
        substr(MD.Mdno,1,19)  || CHR(3) || -- 20140723������,��ǰ���û���C36,
        '0' || CHR(3) || --  �û����Ƿ�ƥ��C37,
        DECODE(MISTATUS, '29', '1', '0') || CHR(3) || --  �ޱ��־C38,
        NVL(MRSCODE, MIRCODE) || CHR(3) || --  ����C39, --�ƻ��ڵ�ȡMRSCODE���ƻ���ȡMIRCODE
        NVL(MRECODE, 0) || CHR(3) || --  ֹ��C40,
        NVL(MRSL, 0) || CHR(3) || --  ˮ��C41,
        (CASE
          WHEN NVL(MRIFREC,'N') = 'N' THEN
           'N'
          ELSE
           'Y'
        END) || CHR(3) || --  �Ʒѱ�־C42,
        FGETPRICEDJ(MIPFID) || CHR(3) || --  �ۺϵ���C43,
        MIPFID || CHR(3) || --  ˮ�����C44,
        FGETPRICEFRAME_JH(MIPFID) || CHR(3) || --  ˮ���������C45,
        MIIFMP || CHR(3) || --  �����ˮ��־C46,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '01'), 2) || CHR(3) || --  ˮ��C47,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '02'), 2) || CHR(3) || --  ��ˮ��C48,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '03'), 2) || CHR(3) || --  ������3C49,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '04'), 2) || CHR(3) || --  ������4C50,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '05'), 2) || CHR(3) || --  ������5C51,
        TO_CHAR(MRRDATE, 'YYYY-MM-DD HH24:MI:SS') || CHR(3) || --  ����ʱ��C52,
        TO_CHAR(NVL(MRPRDATE, MIRECDATE), 'YYYY-MM-DD HH24:MI:SS') || CHR(3) || --  �ϴ�ʱ��C53,

       /*      NVL(MRLASTSL,
       PG_EWIDE_RAEDPLAN_01.FGETAVGMONTHSL(MI.MIID,
                                           ADD_MONTHS(MI.MIRECDATE, -1),
                                           MI.MIRECDATE))|| CHR(3) || --  �ϴ�ˮ��C54,*/
       /*       NVL(MRTHREESL,
       PG_EWIDE_RAEDPLAN_01.FGETAVGMONTHSL(MI.MIID,
                                           ADD_MONTHS(MI.MIRECDATE, -3),
                                           MI.MIRECDATE))|| CHR(3) || --  ǰ3��ƽ����C55,*/

        NVL(MRLASTSL, 0) || CHR(3) || --  �ϴ�ˮ��C54,
        NVL(MRTHREESL, 0) || CHR(3) || --  ǰ3��ƽ����C55,

        TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || CHR(3) || --  ��������C56,

       /*       TOOLS.FFORMATNUM(FGET_CBJ_REC(MIPRIID, 'QF'), 2) || CHR(3) || --  Ƿ�ѽ��C57,
       FGET_CBJ_REC(MIID, 'BS') || CHR(3) || --  Ƿ�ѱ���C58,--
       FGET_CBJ_REC(MIID, 'QFYF') || CHR(3) || --  ����Ƿ����C59,
       FGET_CBJ_REC(MIID, 'SCJFRQ') || CHR(3) || --  �ϴνɷ�����C60,
       TOOLS.FFORMATNUM(FGET_CBJ_REC(MIID, 'SCJFJE'), 2) || CHR(3) || --  �ϴνɷѽ��C61,*/

        TOOLS.FFORMATNUM((NVL(FGET_CBJ_REC(MI.MIPRIID, 'HSYC'), 0) - NVL((select DIS_JE from cbj_t1 where RLPRIMCODE = MI.MIPRIID), 0)), 2) ||
        CHR(3) || --  Ƿ�ѽ��C57,
        NVL((select DIS_C from cbj_t1 where RLPRIMCODE = MI.MIPRIID), 0) || CHR(3) || --  Ƿ�ѱ���C58,
        (select DIS_M from cbj_t1 where RLPRIMCODE = MI.MIPRIID) || CHR(3) || --  ����Ƿ����C59,
        TO_CHAR((select PDATETIME from p where PMID = MI.MIID), 'YYYY-MM-DD HH24:MI:SS') || CHR(3) || --  �ϴνɷ�����C60,
        TOOLS.FFORMATNUM(NVL((select PPAYMENT from p where PMID = MI.MIID), 0), 2) || CHR(3) || --  �ϴνɷѽ��C61,

/*     20140518
       TOOLS.FFORMATNUM((NVL(FGET_CBJ_REC(MI.MIPRIID, 'HSYC'), 0) - NVL(RL_DIS.DIS_JE, 0)), 2) ||
        CHR(3) || --  Ƿ�ѽ��C57,
        NVL(RL_DIS.DIS_C, 0) || CHR(3) || --  Ƿ�ѱ���C58,
        RL_DIS.DIS_M || CHR(3) || --  ����Ƿ����C59,
        TO_CHAR(P.PDATETIME, 'YYYY-MM-DD HH24:MI:SS') || CHR(3) || --  �ϴνɷ�����C60,
        TOOLS.FFORMATNUM(NVL(P.PPAYMENT, 0), 2) || CHR(3) || --  �ϴνɷѽ��C61,*/

        0 || CHR(3) || --  �շѽ��C62,
        NULL || CHR(3) || --  Ʊ�ݺ�C63,
        0 || CHR(3) || --  ��ӡ����C64,
        'N' || CHR(3) || --  �շ������Ƿ��ϴ�C65,
        0 || CHR(3) || --  �����޶�����C66,
        MRID || CHR(3) || --������ˮ��C67
        DECODE(MD.IFDZSB, 'Y', '1', '0') STR --�����־C68
  FROM BOOKFRAME BF,
       METERINFO MI,
       METERDOC  MD,
       CUSTINFO  CI,
       METERREAD MR,
       HRBCBJ t
  WHERE MI.MIID = MR.MRMID(+)
   AND BF.BFID = MI.MIBFID
   AND MI.MIID = CI.CIID
   AND MI.MIID = MD.MDMID
   AND MIID=T.C1
 ORDER BY MIPRIID,MIBFID, MIRORDER
;

