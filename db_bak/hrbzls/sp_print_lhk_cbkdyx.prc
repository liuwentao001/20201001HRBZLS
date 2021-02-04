CREATE OR REPLACE PROCEDURE HRBZLS."SP_PRINT_LHK_CBKDYX" (
                  o_base out tools.out_base) is
  begin
    open o_base for
 SELECT  max(CICODE) AS �û���,
         max(miseqno) as  ����˳���,
          MAX(CI.CINAME) AS �û�����,
          MAX(ciadr) AS �û���ַ,
          MAX(mi.miadr) AS װ���ַ ,
         max(CI.cimtel) as �绰,
         MAX(MDCALIBER) AS  �ھ� ,
         max(mircode)  as ֹ��,
         NULL AS  �� ,
         NULL AS  ˮ�� ,
         NULL AS  �� ,
         NULL AS  ˮ�� ,
         NULL AS  ��,
         NULL AS  ˮ�� ,
         NULL AS  �� ,
         NULL AS  ˮ�� ,
         NULL AS  �� ,
         NULL AS  ˮ�� ,
         NULL AS  �� ,
         NULL AS  ˮ��
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

