create or replace package pg_rectrans is

  -- Author  : lwt
  -- Created : 2021-1-14 14:43:52
  -- Purpose : 水量、账务调整
  errcode constant integer := -20012;

  --追量收费 工单
  --源表：request_zlsf
  procedure rectrans_zlsf_gd(p_reno request_zlsf.reno%type,
                             o_log  out varchar2);

  --生成抄表记录
  procedure ins_mr(p_miid         varchar2,
                   p_mrscode      number,
                   p_mrecode      number,
                   p_mrsl         number,
                   p_mrdatasource varchar2,
                   p_mrgdid       varchar2,
                   p_mrifreset    varchar2,
                   p_mrifstep     varchar2,
                   o_mrid         out varchar2,
                   o_log          out varchar2);

end pg_rectrans;
/

