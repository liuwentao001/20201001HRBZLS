CREATE OR REPLACE FUNCTION HRBZLS."FCUSTINFOPRINT_OCX" (P_micode IN VARCHAR2,p_modelno in varchar2) RETURN varchar2  is

v_invprintstr varchar2(32767);
  begin
select  trim(to_char(lengthb( constructhd||constructdt ),'0000000000'))||
        trim(to_char(lengthb( contentstrorder||contentstr ),'0000000000'))||
        constructhd||
        constructdt||
        contentstrorder||
        contentstr into v_invprintstr
          from

   ( select
replace(
connstr(
  trim(CICODE  )||'^'
||trim(CINAME )||'^'
||trim(CIADR  )||'^'
||trim(MIBFID  )||'^'
||trim(MIID  )||'^'
||trim(MICODE  )||'^'
||trim( MIPFID  )||'^'
||trim(MDCALIBER   )||'^'
||trim(BFRPER )||'^'
||trim(MIADR)||'^'
||trim(MISAFID )||'^'
||trim(MISMFID )||'^'
||trim(MIRTID )||'^'
||trim( MIIFMP )||'^'
||trim(MIPOSITION)||'^'
||trim(MISIDE)||'^'
||trim( MIIFCHARGE )||'^'
||trim(MIIFSL )||'^'
||trim(MIIFCHK )||'^'
||trim(MIIFWATCH )||'^'
||trim(MIICNO )||'^'
||trim(MIPRIID )||'^'
||trim(MIPRIFLAG)||'^'
||trim(MICHARGETYPE )||'^'
||trim(MILB )||'^'
||trim(MICPER )||'^'
||trim(MIIFCKF )||'^'
||trim(MIGPS)||'^'
||trim(MIQFH)||'^'
||trim(MIBOX)||'^'
||trim(ÓÃË®ÐÔÖÊ)||'^'
||trim(´òÓ¡Ô±±àºÅ )||'^'
||trim(´òÓ¡Ô±·­Òë )||'^'
||trim(ÐòºÅ )||'^'
||trim( Ô¤Áô×Ö¶Î1 )||'^'
||trim(Ô¤Áô×Ö¶Î2)||'^'
||trim(Ô¤Áô×Ö¶Î3)||'^'
||trim(Ô¤Áô×Ö¶Î4 )||'^'
||trim(Ô¤Áô×Ö¶Î5 )||'^'
||trim(Ô¤Áô×Ö¶Î6 )||'^'
||trim(Ô¤Áô×Ö¶Î7 )||'^'
||trim(Ô¤Áô×Ö¶Î8 )||'^'
||trim(Ô¤Áô×Ö¶Î9 )||'^'
||trim(Ô¤Áô×Ö¶Î10 )||'^'
||trim(Ô¤Áô×Ö¶Î11 )||'^'
||trim(Ô¤Áô×Ö¶Î12 )||'^'
||trim(Ô¤Áô×Ö¶Î13 )||'^'
||trim(Ô¤Áô×Ö¶Î14  )||'^'
||trim(Ô¤Áô×Ö¶Î15  )||'^'
||trim(Ô¤Áô×Ö¶Î16 )||'^'
||trim(Ô¤Áô×Ö¶Î17 )||'^'
||trim(Ô¤Áô×Ö¶Î18 )||'^'
||trim(Ô¤Áô×Ö¶Î19)||'^'
||trim(Ô¤Áô×Ö¶Î20)
||'|' )
,'|/','|') contentstr
from
(
 select
 CICODE,
CINAME,
CIADR,
MIBFID,
MIID ,
MICODE,
MIPFID,
MDCALIBER,
BFRPER ,
MIADR ,
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
Ô¤Áô×Ö¶Î2,
Ô¤Áô×Ö¶Î3 ,
Ô¤Áô×Ö¶Î4  ,
Ô¤Áô×Ö¶Î5  ,
Ô¤Áô×Ö¶Î6,
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
         MAX(TRIM(TO_CHAR(PC.PFPRICE,'9999999999990.00'))) AS  MDCALIBER ,
         MAX(SH2.SCLVALUE) AS  BFRPER ,
         MAX('D'||TO_CHAR(MD.MDCALIBER)) AS  MIADR ,
         MAX(MD.MDNO) AS  MISAFID ,
         MAX(MC.MAACCOUNTNAME) AS  MISMFID ,
         TO_CHAR(MAX(MC.MAACCOUNTNO)) AS  MIRTID ,
         TO_CHAR(MAX(GH.CCHCREDATE),'YYYY   MM   DD') AS  MIIFMP ,
         MAX(CI.CICONNECTTEL) AS  MIPOSITION ,
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
         null AS  Ô¤Áô×Ö¶Î1 ,
         NULL AS  Ô¤Áô×Ö¶Î2 ,
         NULL AS  Ô¤Áô×Ö¶Î3 ,
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
         '1 - 15' AS  Ô¤Áô×Ö¶Î16 ,
         '16' AS  Ô¤Áô×Ö¶Î17 ,
         '28' AS  Ô¤Áô×Ö¶Î18 ,
          max(case when bf.bfrcyc=1 then 'Ã¿ÔÂ' when bf.bfrcyc=2 and mod(to_number(substr(bf.BFNRMONTH,6,2)),2)=1 then 'µ¥ÔÂ' when bf.bfrcyc=2 and mod(to_number(substr(bf.BFNRMONTH,6,2)),2)=0 then 'Ë«ÔÂ' else 'µ¥ÔÂ' end) AS  Ô¤Áô×Ö¶Î19 ,
         to_char(max(MIINSDATE),'yyyy.mm.dd') AS  Ô¤Áô×Ö¶Î20

    FROM CUSTINFO CI,
         METERINFO MI,
         METERDOC MD,
         BOOKFRAME BF,
         /*PBPARMTEMP PP,*/
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
where /*MI.MIID = PP.C1*/
MI.micode = P_micode
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
GROUP BY MI.MIID) /*X,
PBPARMTEMP Y
WHERE X.CICODE = Y.C1
ORDER BY Y.C3*/
)
)  a,

(
select
replace(connstr(
trim(t.ptditemno)||'^'||trim(round(t.ptdx ) )||'^'||trim(round(t.ptdy  ))||'^'||trim(round(t.ptdheight ))||'^'||
trim(round(t.ptdwidth ))||'^'||trim(t.ptdfontname)||'^'||trim(t.ptdfontsize*-1)||'^'||trim(t.ptdfontalign)||'|'),'|/','|') constructdt,
 replace(connstr(trim(t.ptditemno)),'/','^')||'|'  contentstrorder
 from printtemplatedt_str t where ptdid= p_modelno
 --2
  ) b,
(
select pthpaperheight||'^'||pthpaperwidth||'^'||lastpage||'^'||1||'|' constructhd  from printtemplatehd t1 where  pthid =p_modelno --2
) c ;
    return v_invprintstr;
end ;
/

