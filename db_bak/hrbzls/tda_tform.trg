CREATE OR REPLACE TRIGGER HRBZLS."TDA_TFORM" BEFORE DELETE
ON tform  FOR EACH ROW
DECLARE


BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  DELETE tdetail T WHERE T.CCDNO=:OLD.CCHNO;
END ;
/

