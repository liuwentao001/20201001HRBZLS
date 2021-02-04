CREATE OR REPLACE TRIGGER HRBZLS."IMAGEINFOID_TRIGGER"
    before insert on IMAGEINFO
    for each row
    begin
    select IMAGEINFOID_squ.nextval into :new.IMAGEINFOID from dual;
    end ;
/

