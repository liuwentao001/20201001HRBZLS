CREATE OR REPLACE FUNCTION HRBZLS."FGETMICODE" return varchar2 is
  v_num       number(10);
  v_newmicode varchar2(10);
  v_modnum    number(10);
  v_micode    varchar2(10);
begin
  --�ͻ����롾��������Ҫ��ǰ��9λ�Ǵ����ȡ������һλ��ǰ��9λ������ӣ�ȡ4��Ĥ
  v_micode := FGETSEQUENCE('SEQ_MICODE');
  v_num := 0 ;
  for i in 1 .. length(v_micode) loop
    v_num := nvl(v_num,0) + to_number(substr(v_micode, (i), 1));
  end loop;
  v_modnum    := mod(v_num, 4);
  v_newmicode := v_micode || v_modnum;
  return(v_newmicode);
exception
  when others then
    return '';
end;
/

