CREATE OR REPLACE FUNCTION HRBZLS."FGETPAYLISTCHAR" (p_pbatch in payment.pid%type,type in varchar2)
  RETURN varchar2
AS
  v_inv inv_info.ispcisno%type;
BEGIN
   IF TYPE='INV' THEN
         SELECT NVL(rtrim(MAX(ispcisno)),'') into v_inv FROM INV_INFO WHERE BATCH=p_pbatch;
         return v_inv;
   end if;
   Return 0;

exception
      when others then
      Return 0;

END;
/

