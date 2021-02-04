CREATE OR REPLACE FUNCTION HRBZLS."FGETLJF_À¬»ø·Ñ" (p_rlid in varchar2 )
	RETURN number
AS
	lret    number;
BEGIN
   SELECT rlje
     INTO lret
     FROM reclist t
    WHERE t.rlpbatch = (select rlpbatch
                         from reclist where rlid= p_rlid)
    and  rlpaidflag='Y'
    and rlreverseflag ='N'
    and rlbadflag ='N'
    and rlgroup=3;
   Return lret;
exception when others then
   return 0;
END;
/

