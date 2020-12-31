CREATE OR REPLACE PROCEDURE "PROC_METERREAD_BATCH_MAKE" (aa IN VARCHAR2, bb OUT INTEGER)
AS
BEGIN
	-- routine body goes here, e.g.
	-- DBMS_OUTPUT.PUT_LINE('Navicat for Oracle');
  
  --1 先根据原有抄表计划算费，生成应收账（未算过费的抄表记录）
  
  --2 根据表册（bookframe）筛选出当前月的表册号，对应此表册号的所有户表记录(meterinfo)
  
  
  NULL; 
END;
/

