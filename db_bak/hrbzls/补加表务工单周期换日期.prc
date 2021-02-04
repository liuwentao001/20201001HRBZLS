CREATE OR REPLACE PROCEDURE HRBZLS."补加表务工单周期换日期" is
/*
select mtdycchkdate,mi.mireinsdate,md.mdcycchkdate from metertranshd mth,metertransdt mtd,meterinfo  mi ,meterdoc md
where mthno = mtdno and mtd.mtdmid = miid and mtdmid=md.mdmid and mthshflag  in ('A','N','W','D') and mth.mthsource='2';
*/
cursor c1 is   select * from metertranshd where  mthshflag  in ('A','N','W','D') and mthsource='2';
  mth metertranshd%rowtype;



begin
  open c1;
  loop
    fetch c1 into mth;
    exit when c1%notfound or c1%notfound is null;



    update metertransdt
    set mtdycchkdate=(select mdcycchkdate from meterdoc where  mtdmid = mdmid )
    where mtdno = mth.mthno
    and exists (select 1 from meterdoc where  mtdmid = mdmid);


    commit;
  end loop;
  close c1;
exception when others then
  if c1%isopen then
    close c1;
  end if;
  rollback;
  raise_application_error(-20010,sqlerrm);

end 补加表务工单周期换日期;
/

