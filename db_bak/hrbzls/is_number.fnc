CREATE OR REPLACE FUNCTION HRBZLS."IS_NUMBER" (v in varchar2) return varchar2
is
v_num number;
BEGIN
v_num := to_number(v);
  return 'Y';
  Exception
   when others then
   return 'N';
END ;
/

