CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTMICARDNOTE" (
                  o_base out tools.out_base) is
  begin
    open o_base for
 select
 CICODE,-----ÓÃ»§ºÅ
CINAME,-------ÓÃ»§Ãû
CIADR,--------ÓÃ»§µØÖ·
MIBFID,
MIID ,
MICODE,
MIPFID,
MDCALIBER,-----±í¿Ú¾¶
BFRPER ,
MIADR ,------±íµØÖ·
MISAFID ,
MISMFID ,
MIRTID ,
MIIFMP ,
MIPOSITION ,
MISIDE ,
MIIFCHARGE ,
MIIFSL ,
MIIFCHK ,
MIIFWATCH ,
MIICNO ,
MIPRIID ,
MIPRIFLAG ,
MICHARGETYPE ,
MILB ,
MICPER,
MIIFCKF,
MIGPS ,
MIQFH ,
MIBOX ,
ÓÃË®ÐÔÖÊ,
´òÓ¡Ô±±àºÅ,
´òÓ¡Ô±·­Òë ,
ÐòºÅ,
Ô¤Áô×Ö¶Î1,
Ô¤Áô×Ö¶Î2 ,
rlecode ,
Ô¤Áô×Ö¶Î4 ,
Ô¤Áô×Ö¶Î5 ,
Ô¤Áô×Ö¶Î6 ,
Ô¤Áô×Ö¶Î7  ,
Ô¤Áô×Ö¶Î8  ,
Ô¤Áô×Ö¶Î9    ,
Ô¤Áô×Ö¶Î10   ,
Ô¤Áô×Ö¶Î11    ,
Ô¤Áô×Ö¶Î12    ,
Ô¤Áô×Ö¶Î13    ,
Ô¤Áô×Ö¶Î14    ,
Ô¤Áô×Ö¶Î15    ,
Ô¤Áô×Ö¶Î16    ,
Ô¤Áô×Ö¶Î17   ,
Ô¤Áô×Ö¶Î18    ,
Ô¤Áô×Ö¶Î19    ,
Ô¤Áô×Ö¶Î20

 from
(SELECT  MI.MIID AS CICODE,
         MAX(CI.CINAME) AS CINAME,
         MAX(mi.miADR) AS CIADR,
         MAX(SH1.SCLVALUE||MI.MIPOSITION) AS MIBFID,
         MAX(MI.MISEQNO) AS MIID,
         MAX(MI.MICODE) AS  MICODE ,
         MAX(PC.PFNAME) AS  MIPFID ,
         MAX(MDCALIBER) AS  MDCALIBER ,
         MAX(SH2.SCLVALUE) AS  BFRPER ,
         MAX('D'||TO_CHAR(MD.MDCALIBER)) AS  MIADR ,
         MAX(MD.MDNO) AS  MISAFID ,
         MAX(MC.MAACCOUNTNAME) AS  MISMFID ,
         TO_CHAR(MAX(MC.MAACCOUNTNO)) AS  MIRTID ,
         TO_CHAR(MAX(GH.CCHCREDATE),'YYYY   MM   DD') AS  MIIFMP ,
         MAX(CI.cimtel ) AS  MIPOSITION ,
         TO_CHAR(MAX(CI.CINEWDATE),'YYYY   MM   DD') AS  MISIDE ,
         MAX(SCT.SCTNAME) AS  MIIFCHARGE ,
         NULL AS  MIIFSL ,
         NULL AS  MIIFCHK ,
         NULL AS  MIIFWATCH ,
         NULL AS  MIICNO ,
         NULL AS  MIPRIID ,
         NULL AS  MIPRIFLAG ,
         NULL AS  MICHARGETYPE ,
         NULL AS  MILB ,
         NULL AS  MICPER ,
         NULL AS  MIIFCKF ,
         NULL AS  MIGPS ,
         NULL AS  MIQFH ,
         NULL AS  MIBOX ,
         NULL AS  ÓÃË®ÐÔÖÊ ,
         NULL AS  ´òÓ¡Ô±±àºÅ ,
         NULL AS  ´òÓ¡Ô±·­Òë ,
         NULL AS  ÐòºÅ ,
         MAX(CICONNECTPER) AS  Ô¤Áô×Ö¶Î1 ,
         NULL AS  Ô¤Áô×Ö¶Î2 ,
         NULL AS  rlecode ,
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
         to_char(max(MIINSDATE),'yyyy.mm.dd') AS  Ô¤Áô×Ö¶Î20

    FROM CUSTINFO CI,
         METERINFO MI,
         METERDOC MD,
         BOOKFRAME BF,
         PBPARMTEMP PP,
         reclist,
         (SELECT * FROM SYSCHARLIST t
          WHERE T.SCLTYPE = ' ±íÎ»') SH1,
         PRICEFRAME PC,
         (SELECT * FROM SYSCHARLIST t
          WHERE T.SCLTYPE = '±í²ÎÊýÆ·ÅÆ') SH2,
         METERACCOUNT MC,
        (SELECT CD.MIID,CH.CCHCREDATE
         FROM CUSTCHANGEHD CH,
              CUSTCHANGEDT CD
         WHERE CH.CCHNO = CD.CCDNO
         AND   CH.CCHSHFLAG = 'Y'
         AND   CH.CCHLB = 'D') GH,
         SYSCHARGETYPE SCT
where MI.MIID = PP.C1
AND MI.MICID = CI.CIID
AND MI.MIID = MD.MDMID(+)
AND MI.MIBFID = BF.BFID
AND MI.MISMFID = BF.BFSMFID
AND MI.MISIDE =  SH1.SCLID(+)
AND MD.MDBRAND =  SH2.SCLID(+)
AND MI.MIPFID = PC.PFID
AND MI.MIID = MC.MAMID(+)
AND MI.MIID = GH.MIID(+)
AND MI.MICHARGETYPE = SCT.SCTID
GROUP BY MI.MIID) X,
PBPARMTEMP Y
WHERE X.CICODE = Y.C1
ORDER BY Y.C3;
end ;
/

