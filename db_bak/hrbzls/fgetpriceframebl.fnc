CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICEFRAMEBL" (p_code in varchar2,p_lb in varchar2) return string is
  pfstr varchar2(500);
  mi_row meterinfo%rowtype;
begin
  select * into mi_row from meterinfo where micode = p_code;
  if mi_row.miifmp = 'N' then
    if substr(mi_row.mipfid,1,2) =p_lb then
      pfstr :='100%';
    end if;
  else
    select pmdscale into pfstr from pricemultidetail where pmdcid = mi_row.micid and substr(pmdpfid,1,2)= p_lb;
    pfstr := to_number(pfstr)*100 || '%';
  end if;
  return pfstr;

exception when others then
  return 0;
end ;
/

