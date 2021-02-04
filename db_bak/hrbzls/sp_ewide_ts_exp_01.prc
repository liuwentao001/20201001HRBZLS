CREATE OR REPLACE PROCEDURE HRBZLS."SP_EWIDE_TS_EXP_01" (p_type  in varchar2, --导出类
                                      p_batch in varchar2, --导出批次
                                      o_base  out tools.out_base) is
                                        --name:sp_dk_exp
                                        --note:导出
                                        --author:wy
                                        --date：2009/04/26
                                        --input: p_type:导出类
                                        --       p_batch:导出批次
                                        --说明：导出



begin
 pg_ewide_ts_01.sp_ts_exp(p_type,p_batch,o_base);
end;
/

