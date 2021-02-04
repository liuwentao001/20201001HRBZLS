CREATE OR REPLACE PROCEDURE HRBZLS."SP_PRINT_LHK_CBKDYX" (
                  o_base out tools.out_base) is
  begin
    open o_base for
 SELECT  max(CICODE) AS 用户号,
         max(miseqno) as  抄表顺序号,
          MAX(CI.CINAME) AS 用户名称,
          MAX(ciadr) AS 用户地址,
          MAX(mi.miadr) AS 装表地址 ,
         max(CI.cimtel) as 电话,
         MAX(MDCALIBER) AS  口径 ,
         max(mircode)  as 止码,
         NULL AS  月 ,
         NULL AS  水量 ,
         NULL AS  月 ,
         NULL AS  水量 ,
         NULL AS  月,
         NULL AS  水量 ,
         NULL AS  月 ,
         NULL AS  水量 ,
         NULL AS  月 ,
         NULL AS  水量 ,
         NULL AS  月 ,
         NULL AS  水量
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

