CREATE OR REPLACE PROCEDURE HRBZLS."SP_GTJFPARA_PRINT" (
p_type in varchar2,--类别
p_pchkno in varchar2 --进帐单
                                        ) is
pm payment%rowtype;
cursor c_pm is
select pbatch from payment t where t.pchkno=p_pchkno;

begin
  delete GDJFPRINTPARA_print;
if p_type='1' then
  open c_pm;
  loop fetch c_pm into pm.pbatch;
   exit when c_pm%notfound or c_pm%notfound is  null;
    sp_gtjfpara(pm.pbatch);
    begin
    insert into GDJFPRINTPARA_print
    select t.*,pm.pbatch from GDJFPRINTPARA t;
    commit;
    exception when others then
      null;
    end;
   end loop;
   close c_pm;

end if;
if p_type='2' then

    sp_gtjfpara(p_pchkno);
    begin
    insert into GDJFPRINTPARA_print
    select t.*,p_pchkno from GDJFPRINTPARA t;
    exception when others then
      null;
    end;
end if;
commit;
end;
/

