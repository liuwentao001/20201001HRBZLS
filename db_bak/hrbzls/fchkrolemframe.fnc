CREATE OR REPLACE FUNCTION HRBZLS."FCHKROLEMFRAME"
   (vrid IN VARCHAR2,vcode IN VARCHAR2,vsort IN VARCHAR2,vsmfid IN VARCHAR2)
   Return Integer
AS
   lpcode Integer;
BEGIN
   SELECT COUNT(*) INTO lpcode FROM operseachrange
    WHERE OSROAID = vrid AND OSRID = vcode and osrsort = vsort AND osrbfsmfid = vsmfid;
   Return lpcode;
EXCEPTION WHEN OTHERS THEN
   lpcode := 0;
   Return lpcode;
END;
/

