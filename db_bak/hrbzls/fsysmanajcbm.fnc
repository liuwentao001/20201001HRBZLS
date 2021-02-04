CREATE OR REPLACE FUNCTION HRBZLS."FSYSMANAJCBM"
   (tcode IN CHAR,lclass IN number)
   Return char
  AS
   lcode varchar2(15);
  BEGIN
   SELECT smfid INTO lcode FROM sysmanaframe WHERE smfclass=lclass
         START WITH smfid=tcode CONNECT BY PRIOR smfpid=smfid;
   Return lcode;
  EXCEPTION WHEN OTHERS THEN
   lcode := tcode;
   Return lcode;
  END fsysmanajcbm;
/

