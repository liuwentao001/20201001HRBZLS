create or replace force view hrbzls.view_rpt_sum_reaminl as
(
  select tpdate, u_month, miid , remain,rsmeain,discharge   from rpt_sum_remain
);

