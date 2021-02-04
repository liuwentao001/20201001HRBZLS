CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTMICARDNOTE" (
                  o_base out tools.out_base) is
  begin
    open o_base for
 select
 CICODE,-----�û���
CINAME,-------�û���
CIADR,--------�û���ַ
MIBFID,
MIID ,
MICODE,
MIPFID,
MDCALIBER,-----��ھ�
BFRPER ,
MIADR ,------���ַ
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
Ԥ���ֶ�2 ,
rlecode ,
Ԥ���ֶ�4 ,
Ԥ���ֶ�5 ,
Ԥ���ֶ�6 ,
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
         NULL AS  ��ˮ���� ,
         NULL AS  ��ӡԱ��� ,
         NULL AS  ��ӡԱ���� ,
         NULL AS  ��� ,
         MAX(CICONNECTPER) AS  Ԥ���ֶ�1 ,
         NULL AS  Ԥ���ֶ�2 ,
         NULL AS  rlecode ,
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
         to_char(max(MIINSDATE),'yyyy.mm.dd') AS  Ԥ���ֶ�20

    FROM CUSTINFO CI,
         METERINFO MI,
         METERDOC MD,
         BOOKFRAME BF,
         PBPARMTEMP PP,
         reclist,
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

