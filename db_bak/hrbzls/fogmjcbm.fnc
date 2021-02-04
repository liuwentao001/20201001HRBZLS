CREATE OR REPLACE FUNCTION HRBZLS."FOGMJCBM"
   (groupid IN CHAR,tcode IN CHAR,lclass IN number)
   Return char
  AS
   lcode varchar2(15);
  BEGIN
   SELECT ogmid INTO lcode FROM (select * from opergroupmod where ogmgid=groupid)
   WHERE ogmclass=lclass
         START WITH ogmid=tcode CONNECT BY PRIOR ogmpid=ogmid ;
   Return lcode;
  EXCEPTION WHEN OTHERS THEN
   lcode := tcode;
   Return lcode;
  END fogmjcbm;
/

