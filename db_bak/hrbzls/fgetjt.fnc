create or replace function hrbzls.fgetjt(mipfid in varchar2, MIPRIID in varchar2)
  return varchar2 is
  v_pddj   number;
  v_RDCLASS number;
  v_count  number;
  v_string varchar2(300);
begin
  select count(*)
    into v_count
    from pricedetail
   where pdpfid = mipfid
     AND PDMETHOD = 'sl3';
  if v_count > 0 then
    select max(rddj), nvl(max(RDCLASS),99)
      into v_pddj, v_RDCLASS
      from recdetail
     where rdid in
           (select max(rlid) from reclist where RLPRIMCODE = MIPRIID)
       and rdpfid = mipfid
       and rdpiid = '01';
    if v_RDCLASS in (0, 99) then
      select pddj
        into v_pddj
        from PRICEDETAIL t
       where pdpiid = '01'
         and pdpfid = mipfid;
    end if;
    v_string := v_pddj;
  else
    select pddj
      into v_pddj
      from PRICEDETAIL t
     where pdpiid = '01'
       and pdpfid = mipfid;
    v_string := v_pddj;
  end if;
  return v_pddj;
end fgetjt;
/

