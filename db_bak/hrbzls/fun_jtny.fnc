CREATE OR REPLACE FUNCTION HRBZLS.fun_jtny  (p_miid IN VARCHAR2,P_bfid IN VARCHAR2,b_mfid in varchar2)
 RETURN VARCHAR2
AS
 LRET VARCHAR2(4000);
 v_rljtsrq varchar2(20);
 v_book   bookframe%rowtype;
 V_COUNT  NUMBER;
BEGIN
  select COUNT(*) INTO V_COUNT from pricedetail  wherE pdpfid = b_mfid AND PDMETHOD ='sl3';
  IF V_COUNT > 0 THEN
     select nvl(max(rljtsrq),'a') into v_rljtsrq from reclist where rlmid = p_miid;
      if v_rljtsrq <> 'a' then
         if MONTHS_BETWEEN(trunc(sysdate,'mm'),to_date(v_rljtsrq,'yyyy.mm')) + 1 > 12 then
            if to_char(sysdate,'mm') > substr(v_rljtsrq,6,2) then
               LRET := to_char(sysdate,'yyyy')||substr(v_rljtsrq,5,3);
            else
               LRET := to_char(sysdate,'yyyy') - 1 ||substr(v_rljtsrq,5,3);
            end if;
         else
            LRET := v_rljtsrq;
         end if;
      end if;
   END IF;
   RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

