CREATE OR REPLACE PROCEDURE HRBZLS."SP_EWIDE_TS_EXP_01" (p_type  in varchar2, --������
                                      p_batch in varchar2, --��������
                                      o_base  out tools.out_base) is
                                        --name:sp_dk_exp
                                        --note:����
                                        --author:wy
                                        --date��2009/04/26
                                        --input: p_type:������
                                        --       p_batch:��������
                                        --˵��������



begin
 pg_ewide_ts_01.sp_ts_exp(p_type,p_batch,o_base);
end;
/

