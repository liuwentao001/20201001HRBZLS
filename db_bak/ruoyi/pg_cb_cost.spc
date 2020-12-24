create or replace package pg_cb_cost is

  --应收明细包
  subtype rd_type is bs_recdetail%rowtype;
  type rd_table is table of rd_type;
  
  
  --错误返回码
  errcode constant integer := -20012;
  
	procedure wlog(p_txt in varchar2);
  
  procedure autosubmit;
  --计划内抄表提交算费
  procedure submit(p_mrbfid in varchar2, log out clob);
  --计划抄表单笔算费
  procedure calculate(p_mrid in bs_meterread.mrid%type);
  -- 自来水单笔算费，提供外部调用
  procedure calculate(mr      in out bs_meterread%rowtype,
                      p_trans in char,
                      p_ny    in varchar2);
                      
  procedure insrd(rd in rd_table);
end;
/

