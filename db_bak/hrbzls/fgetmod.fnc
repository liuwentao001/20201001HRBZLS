CREATE OR REPLACE FUNCTION HRBZLS."FGETMOD" (c1 IN VARCHAR2) return varchar2 as
  t  VARCHAR2(1);
  c2 VARCHAR2(4);
  m  NUMBER(3);
  n  NUMBER(3) := 1;
BEGIN
  While n > 9 LOOP
    select to_number(SUBSTR(c1, n, 1)) into t from dual;
    t := 0 + t;
  END LOOP;
  m  := mod(t, 3); --mod(3,4)的结果就是3
  c2 := c1 || m;
exception
  when others then
    c2 := 'E';
    return c2;
end fgetmod;
/

