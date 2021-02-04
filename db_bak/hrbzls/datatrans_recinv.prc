CREATE OR REPLACE PROCEDURE HRBZLS."DATATRANS_RECINV" is
  cursor c1 is
    select * from invoicelist;
  cursor c2 is
    select * from priceitem;
  il     invoicelist%rowtype;
  ri     recinv%rowtype;
  pi     priceitem%rowtype;
  v_piid varchar2(10000);
begin
  open c1;
  loop
    fetch c1
      into il;
    exit when c1%notfound or c1%notfound is null;

    if il.ilrlid is not null and il.ilrdpiid is not null then
      ri.riilid := to_char(il.ilid);
      for i in 1 .. tools.FboundPara2(il.ilrlid) loop
        ri.rirlid := fgetpara3(il.ilrlid, 1, i);
        v_piid    := fgetpara3(il.ilrdpiid, 1, i);

        open c2;
        loop
          fetch c2
            into pi;
          exit when c2%notfound or c2%notfound is null;

          if instr(v_piid, pi.piid) != 0 then
            ri.ripiid := pi.piid;
            insert into recinv values ri;
          end if;

        end loop;
        close c2;
      end loop;
    end if;

    if mod(c1%rowcount, 100) = 0 then
      commit;
    end if;

  end loop;
  close c1;

  commit;
exception
  when others then
    if c1%isopen then
      close c1;
    end if;
    if c2%isopen then
      close c2;
    end if;
    rollback;
    raise_application_error(-20012, sqlerrm || sqlcode);
end datatrans_recinv;
/

