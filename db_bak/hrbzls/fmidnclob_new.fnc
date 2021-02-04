CREATE OR REPLACE FUNCTION HRBZLS."FMIDNCLOB_NEW" (p_str in varchar2 ,p_sep in varchar2) return integer is
  --help:
  --tools.fmidn('/123/123/123/','/')=5
  --tools.fmidn(null,'/')=0
  --tools.fmidn('','/')=0
  --tools.fmidn('null','/')=1
    i integer;
    n integer:=1;
  begin
    if trim(p_str) is null then
      return 0;
    else
      for i in 1..length(p_str)
      loop
        if substr(p_str,i,1)=p_sep then
          n := n +1;
        end if;
      end loop;
    end if;

    return n;
  end;
/

