CREATE OR REPLACE FUNCTION HRBZLS."FGETMETERMRMAX"
   (p_mmcmcid IN VARCHAR2,p_mmcmmid IN VARCHAR2,p_mmcmbid IN VARCHAR2)
   Return number
AS
   lret   number(10);

BEGIN

 select mmccode into lret from metermaxcode
  where mmcmcid=p_mmcmcid and  mmcmmid=p_mmcmmid and mmcmbid=p_mmcmbid;
    return lret;
EXCEPTION WHEN OTHERS THEN
   Return null;
END ;
/

