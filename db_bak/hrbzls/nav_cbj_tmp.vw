CREATE OR REPLACE FORCE VIEW HRBZLS.NAV_CBJ_TMP AS
WITH  rl_dis AS
(
 SELECT RLMID,  NVL(SUM(RLJE), 0) dis_je, COUNT(RLID) dis_c, min(rlmonth) dis_m
      FROM RECLIST     WHERE  RLPAIDFLAG = 'N'        AND RLJE > 0       AND RLREVERSEFLAG = 'N'       AND RLBADFLAG = 'N'
      and rlMID IN (SELECT C1 FROM HRBCBJ T)
   group by RLMID
),
 p_max as
(
    SELECT PMID, MAX(PBATCH) PBATCH
    from payment
                      WHERE  PREVERSEFLAG = 'N'
                        AND PTRANS <> 'U' and pMID IN (SELECT C1 FROM HRBCBJ T)
                        group by PMID
),
 p as
(
    SELECT PMID PMID, PDATETIME, PPAYMENT
    from payment x
     WHERE
     PBATCH = (select  PBATCH from p_max where  pmid = x.pmid)
                        and pMID IN (SELECT C1 FROM HRBCBJ T)
)
SELECT MIID || CHR(9) || --  ˮ����C1,
        BARCODE || CHR(9) || --  ԭˮ�˱�ʶ��C2,
        MISAFID || CHR(9) || --  ����C3,
        SUBSTR(BFMONTH, 1, 4) || SUBSTR(BFMONTH, 6, 2) || CHR(9) || --  �����·�C4,
        MICOLUMN4 || CHR(9) || --  �û�����C5,
        MIBFID || CHR(9) || --  ���C6,
        MIRORDER || CHR(9) || --  �������C7,
        BFRPER || CHR(9) || --  ����Ա���C8,
        FGETOPERNAME(BFRPER) || CHR(9) || --  ����Ա����C9,
        NULL || CHR(9) || --  Ӧ������C10,
        NVL(MRBFDAY, 0) || CHR(9) || --  ƫ������C11,
        NVL(MRFACE, '01') || CHR(9) || --  ��̬C12,
        NVL(MRFACE2, '01') || CHR(9) || --  ���C13,
        DECODE(MISTATUS, '29', NVL(MICOLUMN5, 0), '30', NVL(MICOLUMN5, 0), 0) ||
        CHR(9) || --  �̶���C14,
        DECODE(NVL(MRREADOK, 'N'), 'Y', '1', 'N', '0') || CHR(9) || --  �Ƿ�������C15,
        DECODE(NVL(MRREADOK, 'N'), 'Y', '1', 'N', '0') || CHR(9) || --  ������־C16,
        MINAME || CHR(9) || --  �û���C17,
        MIADR || CHR(9) || --  �û���ַC18,
        MIFACE4 || CHR(9) || --  ��C19,
        MISIDE || CHR(9) || --  ��λC20,
        DQSFH || CHR(9) || --  ���1C21,
        DQGFH || CHR(9) || --  ���2C22,
        JCGFH || CHR(9) || --  ���3C23,
        QFH || CHR(9) || --  ���4C24,
        (SELECT BARCODE FROM GMBARCODE T WHERE BARSMFID = MISMFID) || CHR(9) || --  ����Ա����C25,
        MIUSENUM || CHR(9) || --  �˿���C26,
        MICLASS || CHR(9) || --  �ֱܷ���ձ�־C27,
        MIPID || CHR(9) || --  �ֱܷ��ܱ��C28,
        MIPRIFLAG || CHR(9) || --  ���ձ��־C29,
        MIPRIID || CHR(9) || --  ���ձ������C30,
        CITEL1 || CHR(9) || --  �绰C31,
        CIMTEL || CHR(9) || --  �ֻ�C32,
        '0' || CHR(9) || --  ˮ����Ϣ�Ƿ��ϴ�C33,
        RFID || CHR(9) || --  ���ӱ�ǩC34,
        '0' || CHR(9) || --  ���ӱ�ǩ�Ƿ�ƥ��C35,
        NULL || CHR(9) || --  �û���C36,
        '0' || CHR(9) || --  �û����Ƿ�ƥ��C37,
        DECODE(MISTATUS, '29', '1', '0') || CHR(9) || --  �ޱ��־C38,
        NVL(MRSCODE, MIRCODE) || CHR(9) || --  ����C39, --�ƻ��ڵ�ȡMRSCODE���ƻ���ȡMIRCODE
        NVL(MRECODE, 0) || CHR(9) || --  ֹ��C40,
        NVL(MRSL, 0) || CHR(9) || --  ˮ��C41,
        (CASE
          WHEN MIIFCHARGE = 'N' THEN
           'N'
          ELSE
           'Y'
        END) || CHR(9) || --  �Ʒѱ�־C42,
        FGETPRICEDJ(MIPFID) || CHR(9) || --  �ۺϵ���C43,
        MIPFID || CHR(9) || --  ˮ�����C44,
        FGETPRICEFRAME_JH(MIPFID) || CHR(9) || --  ˮ���������C45,
        MIIFMP || CHR(9) || --  �����ˮ��־C46,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '01'), 2) || CHR(9) || --  ˮ��C47,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '02'), 2) || CHR(9) || --  ��ˮ��C48,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '03'), 2) || CHR(9) || --  ������3C49,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '04'), 2) || CHR(9) || --  ������4C50,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '05'), 2) || CHR(9) || --  ������5C51,
        TO_CHAR(MRRDATE, 'YYYY-MM-DD HH24:MI:SS') || CHR(9) || --  ����ʱ��C52,
        TO_CHAR(NVL(MRPRDATE, MIRECDATE), 'YYYY-MM-DD HH24:MI:SS') || CHR(9) || --  �ϴ�ʱ��C53,
        NVL(MRLASTSL, 0) || CHR(9) || --  �ϴ�ˮ��C54,
 /*      NVL(MRLASTSL,
       PG_EWIDE_RAEDPLAN_01.FGETAVGMONTHSL(MI.MIID,
                                           ADD_MONTHS(MI.MIRECDATE, -1),
                                           MI.MIRECDATE))|| CHR(9) || --  �ϴ�ˮ��C54,*/


        NVL(MRTHREESL, 0) || CHR(9) || --  ǰ3��ƽ����C55,
/*       NVL(MRTHREESL,
       PG_EWIDE_RAEDPLAN_01.FGETAVGMONTHSL(MI.MIID,
                                           ADD_MONTHS(MI.MIRECDATE, -3),
                                           MI.MIRECDATE))|| CHR(9) || --  ǰ3��ƽ����C55,*/
        TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || CHR(9) || --  ��������C56,
--        TOOLS.FFORMATNUM(FGET_CBJ_REC(MIPRIID, 'QF'), 2) || CHR(9) || --  Ƿ�ѽ��C57,
--        FGET_CBJ_REC(MIID, 'BS') || CHR(9) || --  Ƿ�ѱ���C58,--
--        FGET_CBJ_REC(MIID, 'QFYF') || CHR(9) || --  ����Ƿ����C59,


       to_char(nvl(mi.misaving, 0)  - nvl(rl_dis.dis_je, 0)) || CHR(9) || --  Ƿ�ѽ��C57,
         to_char(nvl(rl_dis.dis_c, 0)) || CHR(9) || --  Ƿ�ѱ���C58,
        to_char(nvl(rl_dis.dis_m, 0)) || CHR(9) || --  ����Ƿ����C59,

/*       FGET_CBJ_REC(MIID, 'SCJFRQ') || CHR(9) || --  �ϴνɷ�����C60,
        TOOLS.FFORMATNUM(FGET_CBJ_REC(MIID, 'SCJFJE'), 2) || CHR(9) || --  �ϴνɷѽ��C61,*/

        PDATETIME  || CHR(9) || --  �ϴνɷ�����C60,
        PPAYMENT || CHR(9) || --  �ϴνɷѽ��C61,

        0 || CHR(9) || --  �շѽ��C62,
        NULL || CHR(9) || --  Ʊ�ݺ�C63,
        0 || CHR(9) || --  ��ӡ����C64,
        'N' || CHR(9) || --  �շ������Ƿ��ϴ�C65,
        0 || CHR(9) || --  �����޶�����C66,
        MRID || CHR(9) || --������ˮ��C67
        DECODE(MD.IFDZSB, 'Y', '1', '0') str --�����־C68
  FROM BOOKFRAME BF, METERINFO MI, METERDOC MD, CUSTINFO CI, METERREAD MR,
rl_dis rl_dis, p
 WHERE BF.BFID = MI.MIBFID
   AND MI.MIID = MD.MDMID
   AND MI.MIID = CI.CIID
   AND MI.MIID = MR.MRMCODE(+)
     and  rl_dis.rlmid(+) = MI.MIID
     and p.PMID(+) =  MI.MIID
   AND MIID IN (SELECT C1 FROM HRBCBJ T)
--AND MRREADOK = 'N'
--AND NVL(MROUTFLAG, 'N') = 'N'
--AND MI.MISTATUS = '1'
 ORDER BY MIBFID, MIRORDER
;

