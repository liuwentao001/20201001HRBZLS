CREATE OR REPLACE FUNCTION HRBZLS."FGETYSQF" (p_miid in varchar2) return varchar is
  v_money       number(12,3);
  V_MIPRIID     varchar2(10);
begin

  select  MIPRIID into V_MIPRIID  From meterinfo  where miid =P_MIID ;


    --Ç··Ñ½ð¶î
    select nvl(SUM(RLJE),0) INTO v_money FROM RECLIST
     WHERE RLPRIMCODE =V_MIPRIID
           and nvl(RLTRANS, 'NULL') not in
           (lower('u'), lower('v'), '13', '14', '21', '23')
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       and rlbadflag ='N';

    return v_money;


end FGETYSQF;
/

