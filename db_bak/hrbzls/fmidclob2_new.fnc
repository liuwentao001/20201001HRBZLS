CREATE OR REPLACE FUNCTION HRBZLS."FMIDCLOB2_NEW" (p_str in varchar2  ,p_n in number,p_null in char,p_sep in varchar2) return varchar2 is
  --help:
  --tools.fmid('/null/123/321/456/',2,'N','/')='null'
  --tools.fmid('/null/123/321/456/',2,'Y','/')=NULL
    vstr arr;
    vintstr varchar2(4000);
    i number;

    start_position number;
    end_position number;
    find_count number;
    clob_length number;

  begin
    start_position:=0;
    end_position:=0;
    find_count:=0;
    clob_length := length(p_str);
    for i in 1..clob_length
    loop
      if (substr(p_str,1,i)= p_sep)  then
        find_count:=find_count+1;
        start_position:=end_position;
        end_position:=i;
      end if;
      exit when find_count=p_n ;
   end loop;
      if    find_count < p_n then
        start_position:=end_position;
        end_position:=clob_length+1;
      end if;
      return trim(substr(p_str,end_position-start_position-1,start_position+1));

  exception when others then
    return null;
  end;
/

