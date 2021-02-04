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
         MAX(CICONNECTPER) AS  Ԥ���ֶ�1 ,
         NULL AS  Ԥ���ֶ�2 ,
         NULL AS  Ԥ���ֶ�4 ,
         NULL AS  Ԥ���ֶ�5 ,
         NULL AS  Ԥ���ֶ�6 ,
         NULL AS  Ԥ���ֶ�7 ,
         NULL AS  Ԥ���ֶ�8 ,
         NULL AS  Ԥ���ֶ�9 ,
         NULL AS  Ԥ���ֶ�10 ,
         NULL AS  Ԥ���ֶ�11 ,
         NULL AS  Ԥ���ֶ�12 ,
         NULL AS  Ԥ���ֶ�13 ,
         NULL AS  Ԥ���ֶ�14 ,
         NULL AS  Ԥ���ֶ�15 ,
         NULL AS  Ԥ���ֶ�16 ,
         NULL AS  Ԥ���ֶ�17 ,
         NULL AS  Ԥ���ֶ�18 ,
         NULL AS  Ԥ���ֶ�19 ,
         NULL AS  Ԥ���ֶ�20 ,
         NULL AS  Ԥ���ֶ�21 ,
         NULL AS  Ԥ���ֶ�22 ,
         NULL AS  Ԥ���ֶ�23 ,
         NULL AS  Ԥ���ֶ�24 ,
         NULL AS  Ԥ���ֶ�25 ,
         NULL AS  Ԥ���ֶ�26 ,
         NULL AS  Ԥ���ֶ�27 ,
         NULL AS  Ԥ���ֶ�28 ,
         to_char(max(MIINSDATE),'yyyy.mm.dd') AS  Ԥ���ֶ�29
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

