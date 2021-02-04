CREATE OR REPLACE FUNCTION HRBZLS."FCHKMETERNEEDCHARGE_XBQS"
   (
    vMINEWFLAG   IN VARCHAR2,
    vmrsl   IN number)
   Return CHAR
AS
   lret char(1);
BEGIN
    if vMINEWFLAG='Y'    AND    vmrsl <10     then
      return 'N';
      else
    return 'Y';
     end if;


exception WHEN OTHERS THEN
   Return 'N';
END;
/

