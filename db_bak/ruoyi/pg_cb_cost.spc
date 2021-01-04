create or replace package pg_cb_cost is

  --应收明细包
  subtype rd_type is bs_recdetail%rowtype;
  type rd_table is table of rd_type;
  
  
  --错误返回码
  errcode constant integer := -20012;
  
	procedure wlog(p_txt in varchar2);
  
  procedure autosubmit;
  --计划内抄表提交算费
  procedure submit(p_mrbfids in varchar2, log out varchar2);
  --算费前虚拟算费，供月抄表明细调用
  procedure calculatebf(p_mrid in bs_meterread.mrid%type,
             p_caltype in varchar2,    -- 01 虚拟算费; 02 正式算费
             o_mrrecje01 out bs_meterread.mrrecje01%type,
             o_mrrecje02 out bs_meterread.mrrecje02%type,
             o_mrrecje03 out bs_meterread.mrrecje03%type,
             o_mrrecje04 out bs_meterread.mrrecje04%type,
             err_log out varchar2);
  --计划抄表单笔算费
  procedure calculate(p_mrid in bs_meterread.mrid%type);
  -- 自来水单笔算费，提供外部调用
  procedure calculate(mr      in out bs_meterread%rowtype,
                      p_trans in char,
                      p_ny    in varchar2);
  --自来水单笔算费，只用于记账不计费（哈尔滨）
  procedure calculatenp(mr      in out bs_meterread%rowtype,
                        p_trans in char,
                        p_ny    in varchar2);
  --费率计算步骤
  procedure calpiid(p_rl             in out bs_reclist%rowtype,
                  p_sl             in number,
                  pd               in bs_pricedetail%rowtype,
                  rdtab            in out rd_table)  ;
  --阶梯计费步骤
  procedure calstep(p_rl       in out bs_reclist%rowtype,
                    p_sl       in number,
                    pd         in bs_pricedetail%rowtype,
                    rdtab      in out rd_table);
                        
  procedure insrd(rd in rd_table);
  
  --应收冲正
  procedure yscz(p_reno   in varchar2, --单据编号
                 p_per    in varchar2, --完结人
                 p_memo   in varchar2 --备注
                 );
end;
/

