CREATE OR REPLACE FUNCTION F_GET_SBID return varchar2 is
 -- --------------------------------------------------------------------------
  -- Name         : F_GET_SBID
  -- Author       : Tim
  -- Description  : 取水表编号
  -- Ammedments   : 水表编号前面9位是从序号取，后面一位是前面9位数据相加，取4的膜
  --   When         Who       What
  --   ===========  ========  =================================================
  --   2020-12-01  Tim      Initial Creation
  -- --------------------------------------------------------------------------

  v_num       number(10);
  v_newsbid   varchar2(10);
  v_modnum    number(10);
  v_sbid    varchar2(10);
begin

  v_sbid := f_get_seq_next('SEQ_SBID');
  v_num := 0 ;
  for i in 1 .. length(v_sbid) loop
    v_num := nvl(v_num,0) + to_number(substr(v_sbid, (i), 1));
  end loop;
  v_modnum    := mod(v_num, 4);
  v_newsbid := v_sbid || v_modnum;
  return(v_newsbid);
exception
  when others then
    return '';
end;
/

