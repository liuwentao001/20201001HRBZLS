CREATE OR REPLACE FUNCTION HRBZLS."FGETTAXSL" (P_MIID in varchar2,P_JE NUMBER )
  RETURN NUMBER
AS
  LL_SL number;
  ls_mipfid VARCHAR2(10);
  LL_RLSL NUMBER;
  LL_RLJE NUMBER;
  LS_PALSTARTMON VARCHAR2(10);
  LS_PALENDMON VARCHAR2(10);
  id_pddj NUMBER;
  ID_PALVALUE NUMBER;
  ll_star  NUMBER;
  ll_end  NUMBER;
  ll_today  NUMBER;
  ll_count number;
BEGIN
   select mipfid into ls_mipfid from meterinfo where  miid = P_MIID;

select SUM(RLSL),SUM(RLJE) INTO LL_RLSL,LL_RLJE from reclist where  rlcid = P_MIID and rlpaidflag='N' ;

select  nvl(sum(pddj),0) into id_pddj from PRICEDETAIL where pdpfid = ls_mipfid ;

select count(p.palid) into ll_count from priceadjustlist p where palmid=P_MIID and PALSTATUS='Y';
if ll_count > 0 then
  select nvl(PALVALUE,0),PALSTARTMON,PALENDMON INTO ID_PALVALUE,LS_PALSTARTMON,LS_PALENDMON from priceadjustlist where palmid=P_MIID and PALSTATUS='Y';
  ll_star := TO_NUMBER(SUBSTR(LS_PALSTARTMON,1,4)+SUBSTR(LS_PALSTARTMON,-2,2));
  ll_end := TO_NUMBER(SUBSTR(LS_PALENDMON,1,4)+SUBSTR(LS_PALENDMON,-2,2));
  ll_today := TO_NUMBER(SUBSTR(TO_CHAR(SYSDATE,'yyyy.mm'),1,4)+SUBSTR(TO_CHAR(SYSDATE,'yyyy.mm'),-2,2));
  if ll_today >=ll_star and ll_today <=ll_end then
    NULL;
  else
    ID_PALVALUE := 0;
  end if;
else
  ID_PALVALUE := 0;
end if;

  if id_pddj > 0 then
      LL_SL :=  Ceil(P_JE/(id_pddj+ID_PALVALUE));
  else
      LL_SL := 0;
  end if;
RETURN LL_SL;
exception when others then
   return null;
END;
/

