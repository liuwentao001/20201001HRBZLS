CREATE OR REPLACE TRIGGER HRBZLS."TBI_ENTRUSTFILE"
  before insert on entrustfile
  for each row
declare
  nextid number;
begin
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  IF :new.efid IS NULL THEN
    select seq_entrustfile.nextval
    into nextid
    from dual;
    :new.efid:=nextid;
  end if;
end tbi_entrustfile;
/

