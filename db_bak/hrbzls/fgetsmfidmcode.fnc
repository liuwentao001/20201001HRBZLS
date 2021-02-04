CREATE OR REPLACE FUNCTION HRBZLS."FGETSMFIDMCODE" (pmid in varchar2) return varchar2
is
  ret varchar2(10);
begin
    select mi.mismfid into ret from meterinfo mi where mi.micode=pmid;
    return ret;
   exception
       when others then
           return 'нч';
end;
/

