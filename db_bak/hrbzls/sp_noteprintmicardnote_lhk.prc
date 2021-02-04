CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTMICARDNOTE_LHK" (
                  o_base out tools.out_base) is
  begin
    open o_base for
 SELECT  max(CICODE) AS CICODE,
         MAX(CI.CINAME) AS CINAME,
         MAX(ciadr) AS CIADR,
         MAX(MI.MIID) AS MIID,
         MAX(MI.MICODE) AS  MICODE ,
         MAX(mi.mibfid) AS  MIbFID ,
         MAX(MDCALIBER) AS  MDCALIBER ,
         '  ' AS  BFRPER ,
         max(CI.cimtel) as cimtel,
         MAX(mi.miadr) AS  MIADR ,
         MAX(MISAFID) AS  MISAFID ,
         MAX(MISMFID) AS  MISMFID ,
         max(MIIFMP) AS  MIIFMP ,
         MAX(MIPOSITION ) AS  MIPOSITION ,
         MAX(CICONNECTPER) AS  Ô¤Áô×Ö¶Î1 ,
         NULL AS  Ô¤Áô×Ö¶Î2 ,
         NULL AS  Ô¤Áô×Ö¶Î4 ,
         NULL AS  Ô¤Áô×Ö¶Î5 ,
         NULL AS  Ô¤Áô×Ö¶Î6 ,
         NULL AS  Ô¤Áô×Ö¶Î7 ,
         NULL AS  Ô¤Áô×Ö¶Î8 ,
         NULL AS  Ô¤Áô×Ö¶Î9 ,
         NULL AS  Ô¤Áô×Ö¶Î10 ,
         NULL AS  Ô¤Áô×Ö¶Î11 ,
         NULL AS  Ô¤Áô×Ö¶Î12 ,
         NULL AS  Ô¤Áô×Ö¶Î13 ,
         NULL AS  Ô¤Áô×Ö¶Î14 ,
         NULL AS  Ô¤Áô×Ö¶Î15 ,
         NULL AS  Ô¤Áô×Ö¶Î16 ,
         NULL AS  Ô¤Áô×Ö¶Î17 ,
         NULL AS  Ô¤Áô×Ö¶Î18 ,
         NULL AS  Ô¤Áô×Ö¶Î19 ,
         NULL AS  Ô¤Áô×Ö¶Î20 ,
         NULL AS  Ô¤Áô×Ö¶Î21 ,
         NULL AS  Ô¤Áô×Ö¶Î22 ,
         NULL AS  Ô¤Áô×Ö¶Î23 ,
         NULL AS  Ô¤Áô×Ö¶Î24 ,
         NULL AS  Ô¤Áô×Ö¶Î25 ,
         NULL AS  Ô¤Áô×Ö¶Î26 ,
         NULL AS  Ô¤Áô×Ö¶Î27 ,
         NULL AS  Ô¤Áô×Ö¶Î28 ,
         to_char(max(MIINSDATE),'yyyy.mm.dd') AS  Ô¤Áô×Ö¶Î29
    FROM CUSTINFO CI,
         METERINFO MI,
         METERDOC MD,
         PBPARMTEMP PP
where MI.MIID = PP.C1
AND MI.MICID = CI.CIID
AND MI.MIID = MD.MDMID(+)
GROUP BY MI.MIID ,c3
ORDER BY pp.C3;
end ;
/

