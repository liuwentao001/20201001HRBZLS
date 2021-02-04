create or replace function hrbzls.fgetjtsf(mipfid  in varchar2,
                                    MIPRIID in varchar2) return varchar2 is
  v_pddj    number;
  v_RDCLASS number;
  v_count   number;
  v_string   varchar2(300);
begin
  select count(*) into v_count from pricedetail where pdpfid = mipfid AND PDMETHOD = 'sl3';
  if v_count > 0 then
    select max(rddj), nvl(max(RDCLASS),99)
      into v_pddj, v_RDCLASS
      from recdetail
     where rdid in (select max(rlid) from reclist where RLPRIMCODE = MIPRIID)
       and rdpfid = mipfid
       and rdpiid = '01';
       if v_RDCLASS in (0,99) then
          v_RDCLASS := 1;
          select pddj into v_pddj  from PRICEDETAIL t where pdpiid = '01' and pdpfid = mipfid;

       end if;
       v_string := '(' || v_RDCLASS || '½×)' || TOOLS.FFORMATNUM(v_pddj, 2);
  else
     select pddj into v_pddj  from PRICEDETAIL t where pdpiid = '01' and pdpfid = mipfid;
     v_string :=    TOOLS.FFORMATNUM(v_pddj, 2);
  end if;
  /*if v_RDCLASS = 0 then
    return '(-)' || v_pddj;
  else
    return
  end if;*/
  return v_string;
exception
  when others then
   return null;
end fgetjtsf;
/

