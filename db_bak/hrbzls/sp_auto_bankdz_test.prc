CREATE OR REPLACE PROCEDURE HRBZLS."SP_AUTO_BANKDZ_TEST"(p_date  in VARCHAR2,
                                             p_smfid in varchar2) AS
  v_date date;
begin
  v_date := to_date(p_date, 'yyyymmdd');
  zhongbe.sp_bankdz(v_date, p_smfid);
  sp_auto_bankdzimp(v_date, p_smfid);
  --【哈尔滨】20140401 如果是当日银行对账则自动平账
/*  if v_date = to_date(sysdate,'yyyymmdd') then
    zhongbe.SP_AUTOBANKPZ(v_date, p_smfid);
  end if;*/
exception
  when others then
    rollback;
end SP_AUTO_BANKDZ_TEST;
/

