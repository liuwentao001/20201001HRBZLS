CREATE OR REPLACE FUNCTION HRBZLS."FBOUNDPARA2_NEW" (p_parastr in varchar2) return integer is
    --一维数组规则：#####,####,####|
    --二维数组规则：#####,####,####|#####,####,#######|##,####,####|
    i integer;
    n integer:=0;
    vchar nchar(1);
  begin
    for i in 1..length(p_parastr) loop
      vchar := substr(p_parastr,i,1);
      if vchar='&' then
        n := n+1;
      end if;
    end loop;

    return n+1;
  end;
/

