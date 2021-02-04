create or replace function hrbzls.函_水费比例(p_pfid in varchar2,p_type in varchar2,p_price in number )
return number as

  v_rate number(10,3);
begin 
  select round(PDDJ/p_price,2) into  v_rate
  from pricedetail pd 
  where pd.pdpfid=p_pfid
  and PDPFID=p_type;
  
  return v_rate;
  
exception 
  when others then
     return 0;
       
end 函_水费比例;
/

