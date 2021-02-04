CREATE OR REPLACE FUNCTION HRBZLS."FGETDJ" (P_miid IN varchar2, p_piid in varchar2)
  RETURN number

 AS
  v_count   number(10);
  V_FLAG    VARCHAR2(10);
  P_PFPRICE number(12, 2);
BEGIN
select count(palmid) into v_count  from priceadjustlist t where t.palmid=P_miid;
if v_count < 1 then
  select t2.pddj
    into P_PFPRICE
    from METERINFO T1,pricedetail t2
   WHERE T2.PDPFID = T1.MIPFID
     AND T1.MIID=P_miid
     AND T2.PDPIID=p_piid;
     --AND (T2.PDPIID=p_piid or p_piid is null);
end if ;
if v_count >= 1 then
  select t2.pddj +¡¡(t2.pddj * t3.palway * t3.palvalue)/100
    into P_PFPRICE
    from METERINFO T1,pricedetail t2,priceadjustlist t3
   WHERE T2.PDPFID = T1.MIPFID
     AND T1.MIID=P_miid
     AND T1.MIID=T3.PALMID
     AND T2.PDPIID=T3.PALPIID
     AND T2.PDPIID=p_piid;
     --AND (T2.PDPIID=p_piid or p_piid is null);
end if ;

  return P_PFPRICE;
exception
  when others then
    return null;
END;
/

