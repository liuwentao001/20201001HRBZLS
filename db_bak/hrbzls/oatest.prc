CREATE OR REPLACE PROCEDURE HRBZLS."OATEST" (code out number, msg out varchar2) is

begin
  insert into pbparmtemp_test
    (c1, c2, c3)
    select c1, c2, c3 from OAPARMTEMP;
  code := 0;
  msg  := '插入成功!';
      exception when others then
      code := -1;
  msg := '插入失败';
end;
/

