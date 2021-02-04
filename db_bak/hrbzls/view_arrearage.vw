CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_ARREARAGE AS
SELECT RLID 流水号,
         RLDATE 帐务日期,
         RLcid 客户代码,
         RLPRIMCODE  合收表主表号,
         RLSCODECHAR 起码,
         RLECODECHAR 止码,
         MIN(RLSL) 水量,
         SUM(RDJE) 欠费金额,
         0 违约金,
         sum(decode(RDPIID,'01',rdje,0)) 水费,
         sum(decode(RDPIID,'02',rdje,0)) 污水费,
         sum(decode(RDPIID,'03',rdje,0)) 附加费
    FROM RECLIST, RECDETAIL
   WHERE RLID = RDID
     --AND RLcid IN ('9121265479')
          and  rlcd='DE'
and (rlje-rlpaidje)>0
and rlpaidflag ='N'
and rlreverseflag ='N'
AND rlbadflag ='N'
     AND RLJE<>0
GROUP BY RLID,
         RLPRIMCODE,
         RLDATE,
         RLcid,
         RLSCODECHAR,
         RLECODECHAR,
         RLPFID,
         rlgroup,
         RLSMFID
ORDER BY 帐务日期
;

