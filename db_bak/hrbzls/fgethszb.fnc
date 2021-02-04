CREATE OR REPLACE FUNCTION HRBZLS."FGETHSZB" (p_pbatch in varchar2)
       return varchar2
       is
v_code varchar2(50);
begin
       /*select max(mipriid) into v_code from meterinfo mi,(select pmcode from payment where pbatch=p_pbatch) p
       where mi.micode=p.pmcode and mipriflag='Y';*/
       select MAX(PPRIID) INTO v_code
       from payment
       where pbatch=p_pbatch ;

       return v_code;
exception
       when others then
       return 'N';
end fgethszb;
/

