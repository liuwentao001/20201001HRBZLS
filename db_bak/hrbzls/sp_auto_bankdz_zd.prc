CREATE OR REPLACE PROCEDURE HRBZLS."SP_AUTO_BANKDZ_ZD"(p_date  in date,
                                             p_smfid in varchar2) AS
begin
  zhongbe.sp_bankdz(p_date, p_smfid);
  sp_auto_bankdzimp(p_date, p_smfid);

exception
  when others then
    rollback;
    raise_application_error('-20002', '¸üÐÂÊ§°Ü2£¡!'|| sqlerrm);
end sp_auto_bankdz_zd;
/

