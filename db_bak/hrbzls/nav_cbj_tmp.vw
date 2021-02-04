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
SELECT MIID || CHR(9) || --  水表编号C1,
        BARCODE || CHR(9) || --  原水账标识号C2,
        MISAFID || CHR(9) || --  区域C3,
        SUBSTR(BFMONTH, 1, 4) || SUBSTR(BFMONTH, 6, 2) || CHR(9) || --  抄表月份C4,
        MICOLUMN4 || CHR(9) || --  用户性质C5,
        MIBFID || CHR(9) || --  表册C6,
        MIRORDER || CHR(9) || --  抄表次序C7,
        BFRPER || CHR(9) || --  抄表员编号C8,
        FGETOPERNAME(BFRPER) || CHR(9) || --  抄表员姓名C9,
        NULL || CHR(9) || --  应抄日期C10,
        NVL(MRBFDAY, 0) || CHR(9) || --  偏移天数C11,
        NVL(MRFACE, '01') || CHR(9) || --  表态C12,
        NVL(MRFACE2, '01') || CHR(9) || --  表况C13,
        DECODE(MISTATUS, '29', NVL(MICOLUMN5, 0), '30', NVL(MICOLUMN5, 0), 0) ||
        CHR(9) || --  固定量C14,
        DECODE(NVL(MRREADOK, 'N'), 'Y', '1', 'N', '0') || CHR(9) || --  是否已入账C15,
        DECODE(NVL(MRREADOK, 'N'), 'Y', '1', 'N', '0') || CHR(9) || --  抄见标志C16,
        MINAME || CHR(9) || --  用户名C17,
        MIADR || CHR(9) || --  用户地址C18,
        MIFACE4 || CHR(9) || --  表井C19,
        MISIDE || CHR(9) || --  表位C20,
        DQSFH || CHR(9) || --  封号1C21,
        DQGFH || CHR(9) || --  封号2C22,
        JCGFH || CHR(9) || --  封号3C23,
        QFH || CHR(9) || --  封号4C24,
        (SELECT BARCODE FROM GMBARCODE T WHERE BARSMFID = MISMFID) || CHR(9) || --  管理员条码C25,
        MIUSENUM || CHR(9) || --  人口数C26,
        MICLASS || CHR(9) || --  总分表合收标志C27,
        MIPID || CHR(9) || --  总分表总表号C28,
        MIPRIFLAG || CHR(9) || --  合收表标志C29,
        MIPRIID || CHR(9) || --  合收表主表号C30,
        CITEL1 || CHR(9) || --  电话C31,
        CIMTEL || CHR(9) || --  手机C32,
        '0' || CHR(9) || --  水表信息是否上传C33,
        RFID || CHR(9) || --  电子标签C34,
        '0' || CHR(9) || --  电子标签是否匹配C35,
        NULL || CHR(9) || --  用户卡C36,
        '0' || CHR(9) || --  用户卡是否匹配C37,
        DECODE(MISTATUS, '29', '1', '0') || CHR(9) || --  无表标志C38,
        NVL(MRSCODE, MIRCODE) || CHR(9) || --  起码C39, --计划内的取MRSCODE，计划外取MIRCODE
        NVL(MRECODE, 0) || CHR(9) || --  止码C40,
        NVL(MRSL, 0) || CHR(9) || --  水量C41,
        (CASE
          WHEN MIIFCHARGE = 'N' THEN
           'N'
          ELSE
           'Y'
        END) || CHR(9) || --  计费标志C42,
        FGETPRICEDJ(MIPFID) || CHR(9) || --  综合单价C43,
        MIPFID || CHR(9) || --  水价类别C44,
        FGETPRICEFRAME_JH(MIPFID) || CHR(9) || --  水价类别描述C45,
        MIIFMP || CHR(9) || --  混合用水标志C46,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '01'), 2) || CHR(9) || --  水价C47,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '02'), 2) || CHR(9) || --  污水价C48,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '03'), 2) || CHR(9) || --  其他费3C49,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '04'), 2) || CHR(9) || --  其他费4C50,
        TOOLS.FFORMATNUM(FGETPRICEPIIDDJ(MIPFID, '05'), 2) || CHR(9) || --  其他费5C51,
        TO_CHAR(MRRDATE, 'YYYY-MM-DD HH24:MI:SS') || CHR(9) || --  抄表时间C52,
        TO_CHAR(NVL(MRPRDATE, MIRECDATE), 'YYYY-MM-DD HH24:MI:SS') || CHR(9) || --  上次时间C53,
        NVL(MRLASTSL, 0) || CHR(9) || --  上次水量C54,
 /*      NVL(MRLASTSL,
       PG_EWIDE_RAEDPLAN_01.FGETAVGMONTHSL(MI.MIID,
                                           ADD_MONTHS(MI.MIRECDATE, -1),
                                           MI.MIRECDATE))|| CHR(9) || --  上次水量C54,*/


        NVL(MRTHREESL, 0) || CHR(9) || --  前3月平均量C55,
/*       NVL(MRTHREESL,
       PG_EWIDE_RAEDPLAN_01.FGETAVGMONTHSL(MI.MIID,
                                           ADD_MONTHS(MI.MIRECDATE, -3),
                                           MI.MIRECDATE))|| CHR(9) || --  前3月平均量C55,*/
        TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || CHR(9) || --  下载日期C56,
--        TOOLS.FFORMATNUM(FGET_CBJ_REC(MIPRIID, 'QF'), 2) || CHR(9) || --  欠费金额C57,
--        FGET_CBJ_REC(MIID, 'BS') || CHR(9) || --  欠费笔数C58,--
--        FGET_CBJ_REC(MIID, 'QFYF') || CHR(9) || --  最早欠费月C59,


       to_char(nvl(mi.misaving, 0)  - nvl(rl_dis.dis_je, 0)) || CHR(9) || --  欠费金额C57,
         to_char(nvl(rl_dis.dis_c, 0)) || CHR(9) || --  欠费笔数C58,
        to_char(nvl(rl_dis.dis_m, 0)) || CHR(9) || --  最早欠费月C59,

/*       FGET_CBJ_REC(MIID, 'SCJFRQ') || CHR(9) || --  上次缴费日期C60,
        TOOLS.FFORMATNUM(FGET_CBJ_REC(MIID, 'SCJFJE'), 2) || CHR(9) || --  上次缴费金额C61,*/

        PDATETIME  || CHR(9) || --  上次缴费日期C60,
        PPAYMENT || CHR(9) || --  上次缴费金额C61,

        0 || CHR(9) || --  收费金额C62,
        NULL || CHR(9) || --  票据号C63,
        0 || CHR(9) || --  打印次数C64,
        'N' || CHR(9) || --  收费数据是否上传C65,
        0 || CHR(9) || --  报警限额上限C66,
        MRID || CHR(9) || --抄表流水号C67
        DECODE(MD.IFDZSB, 'Y', '1', '0') str --倒表标志C68
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

