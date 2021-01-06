create or replace procedure test is
       p_mrid     varchar2(20);
       p_caltype  varchar2(10);
       o_mrrecje01 number;
       o_mrrecje02 number;
       o_mrrecje03 number;
       o_mrrecje04 number;
       err_log     varchar(100);
begin
  p_mrid := '2372463611';
  p_caltype := '01';
  for i in 1 .. 1000 loop
      pg_cb_cost.calculatebf(p_mrid,p_caltype,o_mrrecje01,o_mrrecje02,o_mrrecje03,o_mrrecje04,err_log);
  end loop;
end test;
/

