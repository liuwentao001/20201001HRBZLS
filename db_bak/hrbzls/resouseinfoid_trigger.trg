CREATE OR REPLACE TRIGGER HRBZLS."RESOUSEINFOID_TRIGGER"
    before insert on RESOUSEINFO
    for each row
    begin
    select RESOUSEINFOID_squ.nextval into :new.RESOUSEID from dual;
    end ;
/

