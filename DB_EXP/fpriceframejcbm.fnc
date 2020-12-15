CREATE OR REPLACE FUNCTION "FPRICEFRAMEJCBM"
   (tcode IN CHAR,lclass IN number)
   Return char
  AS
   lcode varchar2(10);
  BEGIN
   SELECT pfid INTO lcode FROM priceframe WHERE pfclass=lclass
         START WITH pfid=tcode CONNECT BY PRIOR pfpid=pfid;
   Return lcode;
  EXCEPTION WHEN OTHERS THEN
   --lcode := tcode;
      lcode := null;  --20150108 by hk
   Return lcode;
  END fpriceframejcbm;
/

