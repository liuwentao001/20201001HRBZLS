CREATE OR REPLACE FUNCTION HRBZLS."FPRICEFRAME" (vpfid in varchar2) return integer is
  CNT integer;
begin
  SELECT COUNT(*) into CNT  FROM PRICEFRAME WHERE PFPID=vpfid;
  return CNT;
end FPRICEFRAME;
/

