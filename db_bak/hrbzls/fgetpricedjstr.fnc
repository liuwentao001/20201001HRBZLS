CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICEDJSTR" (p_smfid in varchar2,
                                          p_cid in varchar2,
                                          p_mid in varchar2,
                                          /*p_piid,*/
                                          p_pfid in varchar2,
                                          p_caliber in varchar2)
  RETURN varchar2
AS
  vdj    number:=0;
BEGIN
  for pd in (select * from pricedetail where pdpfid=p_pfid) loop
    if pd.pdmethod='sl3' then
      return '½×ÌÝ¼Æ·Ñ';
    end if;
    if pd.pdpiid='02' then
      begin
        select pd.pddj*(1+palway*palvalue)
        into pd.pddj
        from priceadjustlist
        where palmid=p_mid and palpiid='02';
      exception when others then
        null;
      end;
    end if;
    vdj := vdj+pd.pddj;
  end loop;

  return to_char(vdj);
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
/

