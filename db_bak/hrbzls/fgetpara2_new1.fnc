CREATE OR REPLACE FUNCTION HRBZLS."FGETPARA2_NEW1" (p_parastr in varchar2 ,rown in integer,coln in integer)
  return varchar2 is
    --һά�������#####|####|####|
    vchar nchar(1);
    v     varchar2(10000);
    vstr  varchar2(10000):='';
    r integer:=1;
    c integer:=0;
  begin
    v := trim(p_parastr);
    if length(v)=0 or substr(v,length(v))!='#' then
      raise_application_error('-200002','�����ַ�����ʽ����'||p_parastr);
    end if;
    for i in 1..length(v) loop
      vchar := substr(v,i,1);
      case vchar
       when '#' then--һ�ж���(ÿ��ֻһ��)
          begin
            c := c+1;
            if r=rown and c=coln then
               return vstr;
            end if;
            r := r+1;
            c := 0;
            vstr := '';
          end;

       else
          begin
            vstr := vstr||vchar;
          end;
      end case;
    end loop;

    return '';
  end;
/

