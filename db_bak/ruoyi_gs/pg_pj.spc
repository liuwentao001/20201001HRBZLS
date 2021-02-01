create or replace package pg_pj is
  --票据处理包
  
  --票据 收费 上门收费
  procedure pg_smsf(p_rlids varchar2, p_fkfs varchar2, o_log out varchar2 );

  --票据 收费
  procedure pg_sf(p_rlids varchar2,  p_fkfs varchar2);

end pg_pj;
/

