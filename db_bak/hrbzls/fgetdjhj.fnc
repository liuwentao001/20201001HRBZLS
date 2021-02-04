CREATE OR REPLACE FUNCTION HRBZLS."FGETDJHJ" (P_miid IN varchar2)
  RETURN number

 AS
  v_count   number(10);
  V_FLAG    VARCHAR2(10);
  P_PFPRICE number(12, 2);
BEGIN
select count(palmid) into v_count  from priceadjustlist t where t.palmid=P_miid;
if v_count < 1 then
  select sum(t2.pddj)
    into P_PFPRICE
    from METERINFO T1,pricedetail t2
   WHERE T2.PDPFID = T1.MIPFID
     AND T1.MIID=P_miid;
end if ;
if v_count >= 1 then
  select sum(t2.pddj) +¡¡sum(t2.pddj * t3.palway * t3.palvalue)/100
    into P_PFPRICE
    from METERINFO T1,pricedetail t2,priceadjustlist t3
   WHERE T2.PDPFID = T1.MIPFID
     AND T1.MIID=P_miid
     AND T1.MIID=T3.PALMID
     AND T2.PDPIID=T3.PALPIID;
end if ;

  return P_PFPRICE;
exception
  when others then
    return null;
END;
/

