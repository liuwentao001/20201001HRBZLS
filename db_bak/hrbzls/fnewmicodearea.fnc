CREATE OR REPLACE FUNCTION HRBZLS."FNEWMICODEAREA" (p_area in varchar2) return varchar2 is
  Result varchar2(20);
  CODESQL varchar2(100);
begin
 CODESQL := fareapara(p_area,'MICODE');
  --取当前序列
  if CODESQL is not null then
     execute immediate CODESQL into Result;
  else
     return null;
  end if;
  --递增sql中序列
  if Result is not null then
     CODESQL := tools.fmid(CODESQL,1,'N','#')||'#'||trim(to_char(to_number(tools.fmid(CODESQL,2,'N','#'))+1))||'#'||tools.fmid(CODESQL,3,'N','#')||'#'||tools.fmid(CODESQL,4,'N','#');

     update sysareapara
     set smppvalue=CODESQL
     where smpid=p_area and smppid='MICODE';
  else
     return null;
  end if;


  return(Result);
exception when others then
  return null;
end fnewmicodearea;
/

