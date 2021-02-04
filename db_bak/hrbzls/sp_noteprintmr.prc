CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTMR" (
                  o_base out tools.out_base) is
  begin
    open o_base for
SELECT MAX(X.MICODE),
       MAX(X.MISEQNO),
       MAX(X.CBR),
       MAX(X.CINAME),
       MAX(X.MIADR),
       MAX(X.SCTNAME),
       MAX(X.BW),
       '',--MAX(X.RLECODE),
       '',--MAX(X.RLREADSL),
       MAX(X.MRSCODECHAR),
       MAX(X.PRICE),
       '',--MAX(X.RLJE),
       MAX(X.ZH),
       MAX(X.ITPROPERTY5),
       MAX(X.YE),
       MAX(X.SCQF),
       MAX(X.ZQF),
       MAX(X.C3),
       MAX(MRBFID),
       MAX(MDNO),
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL
FROM
(SELECT MR.MRID,
       MI.MICODE,
       MI.MISEQNO,
       TO_CHAR(MCH.MRBSDATE,'YYYY-MM-DD') AS CBR,
       CI.CINAME,
       MI.MIADR,
       SCT.SCTNAME,
       DECODE(TRIM(SH.SCLVALUE),NULL,NULL,'BW:'||SH.SCLVALUE) as BW,
       MR.MRSCODECHAR,
       FGETPRICEDJSTR(NULL,NULL,MR.MRMID,MI.MIPFID,NULL) AS PRICE,
       DECODE(TRIM(MC.MAACCOUNTNO),NULL,NULL,'帐号：'||SUBSTR(MC.MAACCOUNTNO,1,7)||'*****'||SUBSTR(MC.MAACCOUNTNO,LENGTH(MC.MAACCOUNTNO)-2,3)) as ZH,
       '你户属于'||fgetsysmanaframe( fgetmeterinfo( mi.miid, 'MISMFID'))||','||IT.ITPROPERTY5 ITPROPERTY5,
       DECODE(MI.MISAVING,0,NULL,'营业所预存余额为：'||TRIM(TO_CHAR(MI.MISAVING,'99999999990.00'))) AS YE,
       TRIM(TO_CHAR(FGETRECMONEY_SY(MI.MIID,MR.MRMONTH),'999999999990.00')) AS SCQF,
       FGETRECQFMONEY(MI.MIID) AS ZQF,
       PP.C3,
       MR.MRBFID,
       '表号：'||MD.MDNO AS MDNO
 FROM METERREAD MR,
      METERINFO MI,
      CUSTINFO CI,
      SYSCHARGETYPE SCT,
     (SELECT * FROM SYSCHARLIST WHERE SCLTYPE = ' 表位') SH,
      METERACCOUNT MC,
      INVOICETYPE IT,
      PBPARMTEMP PP,
      METERDOC MD,
      METERREADBATCH MCH
WHERE MR.MRMID = MI.MIID
AND   MI.MICID = CI.CIID
AND   MI.MICHARGETYPE = SCT.SCTID
AND   MI.MISIDE =  SH.SCLID(+)
AND   MI.MIID = MC.MAMID(+)
AND   IT.ITID = 'C'
AND   MR.MRID = PP.C1
AND   MR.MRBATCH = MCH.MRBBATCH
AND   MR.MRSMFID = MCH.MRBSMFID
AND   MR.MRMONTH=MCH.MRBMONTH
AND   MR.MRMID = MD.MDMID ) X
GROUP BY X.MRID
ORDER BY MAX(X.C3);
end ;
/

