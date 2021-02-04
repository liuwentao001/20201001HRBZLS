CREATE OR REPLACE PROCEDURE HRBZLS."SP_PRINT_CBK_OCX" (
p_modelno in varchar2 --·¢Æ±¸ñÊ½ºÅ
)  is
v_constructhd varchar2(30000);
v_constructdt varchar2(30000);
v_contentstrorder varchar2(30000);
v_hd varchar2(30000);
v_tempstr varchar2(30000);
v_conlen number(10);
I NUMBER(10);
V_C1         VARCHAR2(3000);
V_C2         VARCHAR2(3000);
V_C3         VARCHAR2(3000);
V_C4         VARCHAR2(3000);
V_C5         VARCHAR2(3000);
V_C6         VARCHAR2(3000);
V_C7         VARCHAR2(3000);
V_C8         VARCHAR2(3000);
V_C9         VARCHAR2(3000);
V_C10        VARCHAR2(3000);
V_C11        VARCHAR2(3000);
V_C12        VARCHAR2(3000);
V_C13        VARCHAR2(3000);
V_C14        VARCHAR2(3000);
V_C15        VARCHAR2(3000);
V_C16        VARCHAR2(3000);
V_C17        VARCHAR2(3000);
V_C18        VARCHAR2(3000);
V_C19        VARCHAR2(3000);
V_C20        VARCHAR2(3000);
V_C21        VARCHAR2(3000);
V_C22        VARCHAR2(3000);
V_C23        VARCHAR2(3000);
V_C24        VARCHAR2(3000);
V_C25        VARCHAR2(3000);
V_C26        VARCHAR2(3000);
V_C27        VARCHAR2(3000);
V_C28        VARCHAR2(3000);
V_C29        VARCHAR2(3000);
V_C30        VARCHAR2(3000);
V_C31        VARCHAR2(3000);
V_C32        VARCHAR2(3000);
V_C33        VARCHAR2(3000);
V_C34        VARCHAR2(3000);
V_C35        VARCHAR2(3000);
V_C36        VARCHAR2(3000);
V_C37        VARCHAR2(3000);
V_C38        VARCHAR2(3000);
V_C39        VARCHAR2(3000);
V_C40        VARCHAR2(3000);
V_C41        VARCHAR2(3000);
V_C42        VARCHAR2(3000);
V_C43        VARCHAR2(3000);
V_C44        VARCHAR2(3000);
V_C45        VARCHAR2(3000);
V_C46        VARCHAR2(3000);
V_C47        VARCHAR2(3000);
V_C48        VARCHAR2(3000);
V_C49        VARCHAR2(3000);
V_C50        VARCHAR2(3000);
V_C51        VARCHAR2(3000);
V_C52        VARCHAR2(3000);
V_C53        VARCHAR2(3000);
V_C54        VARCHAR2(3000);
V_C55        VARCHAR2(3000);
V_C56        VARCHAR2(3000);
V_C57        VARCHAR2(3000);
V_C58        VARCHAR2(3000);
V_C59        VARCHAR2(3000);
V_C60        VARCHAR2(3000);
cursor c_hd is
select
        constructhd,
        constructdt,
        contentstrorder
        from (
select
replace(connstr(
trim(t.ptditemno)||'^'||trim(round(t.ptdx ) )||'^'||trim(round(t.ptdy  ))||'^'||trim(round(t.ptdheight ))||'^'||
trim(round(t.ptdwidth ))||'^'||trim(t.ptdfontname)||'^'||trim(t.ptdfontsize*-1)||'^'||trim(ftransformaling(t.ptdfontalign))||'|'),'|/','|') constructdt,
 replace(connstr(trim(t.ptditemno)),'/','^')||'|'  contentstrorder
 from printtemplatedt_str t where ptdid= p_modelno
 --2
  ) b,
(
select pthpaperheight||'^'||pthpaperwidth||'^'||lastpage||'^'||1||'|' constructhd  from printtemplatehd t1 where  pthid =p_modelno --2
) c ;


cursor c_dt is

select CICODE,
       CINAME,
       CIADR,
       MIBFID,
       MIID,
       MICODE,
       MIPFID,
       MDCALIBER,
       BFRPER,
       MIADR,
       MISAFID,
       MISMFID,
       MIRTID,
       MIIFMP,
       MIPOSITION,
       MISIDE,
       MIIFCHARGE,
       MIIFSL,
       MIIFCHK,
       MIIFWATCH,
       MIICNO,
       MIPRIID,
       MIPRIFLAG,
       MICHARGETYPE,
       MILB,
       MICPER,
       MIIFCKF,
       MIGPS,
       MIQFH,
       MIBOX,
       ÓÃË®ÐÔÖÊ,
       ´òÓ¡Ô±±àºÅ,
       ´òÓ¡Ô±·­Òë,
       ÐòºÅ,
       Ô¤Áô×Ö¶Î1,
       Ô¤Áô×Ö¶Î2,
       Ô¤Áô×Ö¶Î3,
       Ô¤Áô×Ö¶Î4,
       Ô¤Áô×Ö¶Î5,
       Ô¤Áô×Ö¶Î6,
       Ô¤Áô×Ö¶Î7,
       Ô¤Áô×Ö¶Î8,
       Ô¤Áô×Ö¶Î9,
       Ô¤Áô×Ö¶Î10,
       Ô¤Áô×Ö¶Î11,
       Ô¤Áô×Ö¶Î12,
       Ô¤Áô×Ö¶Î13,
       Ô¤Áô×Ö¶Î14,
       Ô¤Áô×Ö¶Î15,
       Ô¤Áô×Ö¶Î16,
       Ô¤Áô×Ö¶Î17,
       Ô¤Áô×Ö¶Î18,
       Ô¤Áô×Ö¶Î19,
       Ô¤Áô×Ö¶Î20

  from (SELECT MI.MIID AS CICODE,
               MAX(CI.CINAME) AS CINAME,
               MAX(mi.miADR) AS CIADR,
               MAX(SH1.SCLVALUE || MI.MIPOSITION) AS MIBFID,
               MAX(MI.MISEQNO) AS MIID,
               MAX(MI.MICODE) AS MICODE,
               MAX(PC.PFNAME) AS MIPFID,
               MAX(MDCALIBER) MDCALIBER,
               MAX(SH2.SCLVALUE) AS BFRPER,
               MAX('D' || TO_CHAR(MD.MDCALIBER)) AS MIADR,
               MAX(MD.MDNO) AS MISAFID,
               MAX(MC.MAACCOUNTNAME) AS MISMFID,
               TO_CHAR(MAX(MC.MAACCOUNTNO)) AS MIRTID,
               TO_CHAR(MAX(GH.CCHCREDATE), 'YYYY   MM   DD') AS MIIFMP,
               MAX(CI.cimtel) AS MIPOSITION,
               TO_CHAR(MAX(CI.CINEWDATE), 'YYYY   MM   DD') AS MISIDE,
               MAX(SCT.SCTNAME) AS MIIFCHARGE,
               NULL AS MIIFSL,
               NULL AS MIIFCHK,
               NULL AS MIIFWATCH,
               NULL AS MIICNO,
               NULL AS MIPRIID,
               NULL AS MIPRIFLAG,
               NULL AS MICHARGETYPE,
               NULL AS MILB,
               NULL AS MICPER,
               NULL AS MIIFCKF,
               NULL AS MIGPS,
               NULL AS MIQFH,
               NULL AS MIBOX,
               NULL AS ÓÃË®ÐÔÖÊ,
               NULL AS ´òÓ¡Ô±±àºÅ,
               NULL AS ´òÓ¡Ô±·­Òë,
               max(c2) AS ÐòºÅ,
               MAX(CICONNECTPER) AS Ô¤Áô×Ö¶Î1,
               NULL AS Ô¤Áô×Ö¶Î2,
               NULL AS Ô¤Áô×Ö¶Î3,
               NULL AS Ô¤Áô×Ö¶Î4,
               NULL AS Ô¤Áô×Ö¶Î5,
               NULL AS Ô¤Áô×Ö¶Î6,
               NULL AS Ô¤Áô×Ö¶Î7,
               NULL AS Ô¤Áô×Ö¶Î8,
               NULL AS Ô¤Áô×Ö¶Î9,
               NULL AS Ô¤Áô×Ö¶Î10,
               NULL AS Ô¤Áô×Ö¶Î11,
               NULL AS Ô¤Áô×Ö¶Î12,
               NULL AS Ô¤Áô×Ö¶Î13,
               NULL AS Ô¤Áô×Ö¶Î14,
               NULL AS Ô¤Áô×Ö¶Î15,
               NULL AS Ô¤Áô×Ö¶Î16,
               NULL AS Ô¤Áô×Ö¶Î17,
               NULL AS Ô¤Áô×Ö¶Î18,
               NULL AS Ô¤Áô×Ö¶Î19,
               to_char(max(MIINSDATE), 'yyyy.mm.dd') AS Ô¤Áô×Ö¶Î20

          FROM CUSTINFO CI,
               METERINFO MI,
               METERDOC MD,
               BOOKFRAME BF,
               PBPARMTEMP,
               (SELECT * FROM SYSCHARLIST t WHERE T.SCLTYPE = ' ±íÎ»') SH1,
               PRICEFRAME PC,
               (SELECT * FROM SYSCHARLIST t WHERE T.SCLTYPE = '±í²ÎÊýÆ·ÅÆ') SH2,
               METERACCOUNT MC,
               (SELECT CD.MIID, CH.CCHCREDATE
                  FROM CUSTCHANGEHD CH, CUSTCHANGEDT CD
                 WHERE CH.CCHNO = CD.CCDNO
                   AND CH.CCHSHFLAG = 'Y'
                   AND CH.CCHLB = 'D') GH,
               SYSCHARGETYPE SCT
         where mi.micode = trim(c1)
           AND MI.MICID = CI.CIID
           AND MI.MIID = MD.MDMID(+)
           AND MI.MIBFID = BF.BFID
           AND MI.MISMFID = BF.BFSMFID
           AND MI.MISIDE = SH1.SCLID(+)
           AND MD.MDBRAND = SH2.SCLID(+)
           AND MI.MIPFID = PC.PFID
           AND MI.MIID = MC.MAMID(+)
           AND MI.MIID = GH.MIID(+)
           AND MI.MICHARGETYPE = SCT.SCTID
         GROUP BY MI.MIID)
 order by ÐòºÅ;

begin

open c_hd   ;
  fetch c_hd
    into v_constructhd,v_constructdt,v_contentstrorder;
  null;
close c_hd;

I := 1 ;
v_conlen := 0 ;
DELETE PRINTLISTTEMP;
    open c_dt   ;
    loop
      fetch c_dt
        into V_C1       ,
V_C2       ,
V_C3       ,
V_C4       ,
V_C5       ,
V_C6       ,
V_C7       ,
V_C8       ,
V_C9       ,
V_C10      ,
V_C11      ,
V_C12      ,
V_C13      ,
V_C14      ,
V_C15      ,
V_C16      ,
V_C17      ,
V_C18      ,
V_C19      ,
V_C20      ,
V_C21      ,
V_C22      ,
V_C23      ,
V_C24      ,
V_C25      ,
V_C26      ,
V_C27      ,
V_C28      ,
V_C29      ,
V_C30      ,
V_C31     ,
V_C32      ,
V_C33      ,
V_C34      ,
V_C35      ,
V_C36      ,
V_C37      ,
V_C38      ,
V_C39      ,
V_C40      ,
V_C41      ,
V_C42      ,
V_C43      ,
V_C44      ,
V_C45      ,
V_C46      ,
V_C47      ,
V_C48      ,
V_C49     ,
V_C50      ,
V_C51       ,
V_C52    ,
V_C53      ,
V_C54
;
      exit when c_dt%notfound or c_dt%notfound is null;
     select replace(
connstr(
  trim(v_c1  )||'^'
||trim(v_c2  )||'^'
||trim(v_c3  )||'^'
||trim(v_c4  )||'^'
||trim(v_c5  )||'^'
||trim(v_c6  )||'^'
||trim(v_c7  )||'^'
||trim(v_c8  )||'^'
||trim(v_c9  )||'^'
||trim(v_c10 )||'^'
||trim(v_c11 )||'^'
||trim(v_c12 )||'^'
||trim(v_c13 )||'^'
||trim(v_c14 )||'^'
||trim(v_c15 )||'^'
||trim(v_c16 )||'^'
||trim(v_c17 )||'^'
||trim(v_c18 )||'^'
||trim(v_c19 )||'^'
||trim(v_c20 )||'^'
||trim(v_c21 )||'^'
||trim(v_c22 )||'^'
||trim(v_c23 )||'^'
||trim(v_c24 )||'^'
||trim(v_c25 )||'^'
||trim(v_c26 )||'^'
||trim(v_c27 )||'^'
||trim(v_c28 )||'^'
||trim(v_c29 )||'^'
||trim(v_c30 )||'^'
||trim(v_c31 )||'^'
||trim(v_c32 )||'^'
||trim(v_c33 )||'^'
||trim(v_c34 )||'^'
||trim(v_c35 )||'^'
||trim(v_c36 )||'^'
||trim(v_c37 )||'^'
||trim(v_c38 )||'^'
||trim(v_c39 )||'^'
||trim(v_c40 )||'^'
||trim(v_c41 )||'^'
||trim(v_c42 )||'^'
||trim(v_c43 )||'^'
||trim(v_c44 )||'^'
||trim(v_c45 )||'^'
||trim(v_c46 )||'^'
||trim(v_c47 )||'^'
||trim(v_c48 )||'^'
||trim(v_c49 )||'^'
||trim(v_c50 )||'^'
||trim(v_c51 )||'^'
||trim(v_c52 )||'^'
||trim(v_c53 )||'^'
||trim(v_c54 )
||'|' )
,'|/','|') into v_tempstr   from dual;
     I := I + 1;
     v_conlen :=v_conlen +  lengthb( v_tempstr ) ;
    INSERT INTO PRINTLISTTEMP VALUES (I,v_tempstr);
    end loop;
    close c_dt;
    v_hd :=  trim(to_char(lengthb( v_constructhd||v_constructdt ),'0000000000'))||
        trim(to_char(lengthb( v_contentstrorder )  + v_conlen,'0000000000'))||
        v_constructhd||
        v_constructdt||
        v_contentstrorder  ;
     INSERT INTO PRINTLISTTEMP VALUES (1,v_hd);


  end ;
/

