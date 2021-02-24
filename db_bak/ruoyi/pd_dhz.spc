create or replace package pd_dhz is
  --呆账坏账过程包
  
  
  --呆账坏账工单处理
  procedure dhgl_gd(p_reno   in varchar2,--工单流水号
                    p_oper   in varchar2,--完结人
                    p_memo   in varchar2 --备注
                    );

end pd_dhz;
/

