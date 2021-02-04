CREATE OR REPLACE TRIGGER HRBZLS."TRG_BI_ERPFUNCTIONPARALOG"
 before insert on erpfunctionparalog
 for each row
begin

 select trim(to_char(seq_erpfunctionparalog.nextval,'0000000000')) into :new.EFSEQ from dual;
end;
/

