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
||trim(��ˮ����)||'^'
||trim(��ӡԱ��� )||'^'
||trim(��ӡԱ���� )||'^'
||trim(��� )||'^'
||trim( Ԥ���ֶ�1 )||'^'
||trim(Ԥ���ֶ�2)||'^'
||trim(Ԥ���ֶ�3)||'^'
||trim(Ԥ���ֶ�4 )||'^'
||trim(Ԥ���ֶ�5 )||'^'
||trim(Ԥ���ֶ�6 )||'^'
||trim(Ԥ���ֶ�7 )||'^'
||trim(Ԥ���ֶ�8 )||'^'
||trim(Ԥ���ֶ�9 )||'^'
||trim(Ԥ���ֶ�10 )||'^'
||trim(Ԥ���ֶ�11 )||'^'
||trim(Ԥ���ֶ�12 )||'^'
||trim(Ԥ���ֶ�13 )||'^'
||trim(Ԥ���ֶ�14  )||'^'
||trim(Ԥ���ֶ�15  )||'^'
||trim(Ԥ���ֶ�16 )||'^'
||trim(Ԥ���ֶ�17 )||'^'
||trim(Ԥ���ֶ�18 )||'^'
||trim(Ԥ���ֶ�19)||'^'
||trim(Ԥ���ֶ�20)
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
��ˮ����,
��ӡԱ���,
��ӡԱ���� ,
���,
Ԥ���ֶ�1,
Ԥ���ֶ�2,
Ԥ���ֶ�3 ,
Ԥ���ֶ�4  ,
Ԥ���ֶ�5  ,
Ԥ���ֶ�6,
Ԥ���ֶ�7  ,
Ԥ���ֶ�8  ,
Ԥ���ֶ�9    ,
Ԥ���ֶ�10   ,
Ԥ���ֶ�11    ,
Ԥ���ֶ�12    ,
Ԥ���ֶ�13    ,
Ԥ���ֶ�14    ,
Ԥ���ֶ�15    ,
Ԥ���ֶ�16    ,
Ԥ���ֶ�17   ,
Ԥ���ֶ�18    ,
Ԥ���ֶ�19    ,
Ԥ���ֶ�20

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
         NULL AS  ��ˮ���� ,
         NULL AS  ��ӡԱ��� ,
         NULL AS  ��ӡԱ���� ,
         NULL AS  ��� ,
         null AS  Ԥ���ֶ�1 ,
         NULL AS  Ԥ���ֶ�2 ,
         NULL AS  Ԥ���ֶ�3 ,
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
         '1 - 15' AS  Ԥ���ֶ�16 ,
         '16' AS  Ԥ���ֶ�17 ,
         '28' AS  Ԥ���ֶ�18 ,
          max(case when bf.bfrcyc=1 then 'ÿ��' when bf.bfrcyc=2 and mod(to_number(substr(bf.BFNRMONTH,6,2)),2)=1 then '����' when bf.bfrcyc=2 and mod(to_number(substr(bf.BFNRMONTH,6,2)),2)=0 then '˫��' else '����' end) AS  Ԥ���ֶ�19 ,
         to_char(max(MIINSDATE),'yyyy.mm.dd') AS  Ԥ���ֶ�20

    FROM CUSTINFO CI,
         METERINFO MI,
         METERDOC MD,
         BOOKFRAME BF,
         /*PBPARMTEMP PP,*/
         (SELECT * FROM SYSCHARLIST t
          WHERE T.SCLTYPE = ' ��λ') SH1,
         PRICEFRAME PC,
         (SELECT * FROM SYSCHARLIST t
          WHERE T.SCLTYPE = '�����Ʒ��') SH2,
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

