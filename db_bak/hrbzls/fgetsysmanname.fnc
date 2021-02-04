CREATE OR REPLACE FUNCTION HRBZLS."FGETSYSMANNAME"
        (sid IN varchar2)
        RETURN varchar2

AS
  siname varchar2(30);
BEGIN
   select smfname into siname from sysmanaframe where smfid=sid;
   return siname;
   exception when others then
   return null;
END;
/

