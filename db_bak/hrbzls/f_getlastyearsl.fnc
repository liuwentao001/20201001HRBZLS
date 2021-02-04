CREATE OR REPLACE FUNCTION HRBZLS."F_GETLASTYEARSL" (P_MIID  varchar2,
                                           P_DATE IN DATE)
  return number IS
  isl number;
BEGIN
  select T.mrsl
    into isl
    FROM METERREADHIS T
   WHERE T.MRMID = P_MIID
     AND T.MRMONTH = to_char(ADD_MONTHS(P_DATE,-12),'yyyy.mm');
     isl := NVL(isl, 0);
  return isl;
EXCEPTION
  WHEN OTHERS THEN
    Return 0;
END f_GETLASTYEARSL;
/

