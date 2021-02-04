CREATE OR REPLACE TRIGGER HRBZLS."SERVEGUIDE_SHOWINDEX_TRIGGER"
    before insert on SERVEGUIDE
    for each row
    begin
    select SERVEGUIDE_SHOWINDEX_squ.nextval into :new.SHOWINDEX from dual;
    end ;
/

