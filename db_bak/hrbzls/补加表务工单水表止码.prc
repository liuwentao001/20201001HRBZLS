CREATE OR REPLACE PROCEDURE HRBZLS."补加表务工单水表止码" is
/*
select * from metertranshd,metertransdt where mthno = mtdno
 and mthlb = 'L' and mthsource =2  and mthsmfid ='020103'
 and mthcredate >sysdate -1
*/
cursor c1 is   select * from metertranshd where  mthlb='L' and mthsource='2' and mthsmfid='020103' and mthcredate >sysdate -1 ;
  mth metertranshd%rowtype;



begin
  open c1;
  loop
    fetch c1 into mth;
    exit when c1%notfound or c1%notfound is null;



    update metertransdt
    set (MTDSCODE,mtdscodechar,mtface1,mtface2,miface4)
        = (select mi.mircode,mi.mircodechar,mi.miface,mi.miface2,mi.miface4
          from meterinfo mi where mi.miid = mtdmid)
    where mtdno = mth.mthno
    and exists (select 1    from meterinfo mi where mi.miid = mtdmid);


    commit;
  end loop;
  close c1;
exception when others then
  if c1%isopen then
    close c1;
  end if;
  rollback;
  raise_application_error(-20010,sqlerrm);

end 补加表务工单水表止码;
/

