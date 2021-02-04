CREATE OR REPLACE FUNCTION HRBZLS."FCHKACCNTRANGE"
   (Vid IN VARCHAR2,vcode IN VARCHAR2)
   Return CHAR
AS
   lret    number;
   lvalue  char(1);
BEGIN
SELECT COUNT(*) INTO lret FROM operaccnt
  WHERE oaid   =vid and  oadrange='Y';
if lret>0 then
    lvalue := 'Y';
else
    select count(1)
      into lret
      from dual
     where exists (SELECT 1
              FROM operseachrange
             WHERE OSROAID = vid
               and OSRID = vcode
               and OSRSORT = 'S');
    if lret>0 then
       lvalue := 'Y';
    else
       lvalue := 'N';
    end if;
end if;
if vcode ='0106' then  --20141121 add 表身码为特殊库时，地区都能用，计量中心提出
    lvalue := 'Y';
end if ;

Return lvalue;
/*  lvalue := 'N';
  SELECT COUNT(*) INTO lret FROM operaccnt
  WHERE oaid   =vid;
  IF lret>0 THEN
    SELECT oadrange INTO lvalue FROM operaccnt
     WHERE oaid = vid;
    If lvalue = 'N' Then
      SELECT count(*) INTO lret FROM operseachrange
      WHERE OSROAID = vid and OSRID = vcode and OSRSORT='S';
      IF lret>0 THEN
         lvalue := 'Y';
      Else
         lvalue := 'N';
      End If;
    End If;
  END IF;
  Return lvalue;*/
EXCEPTION WHEN OTHERS THEN
   Return 'N';
END;
/

