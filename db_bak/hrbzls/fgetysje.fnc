CREATE OR REPLACE FUNCTION HRBZLS."FGETYSJE" (p_miid in varchar2) return varchar is
  v_money       number(12,3);
  V_MIPRIID     varchar2(10);
  v_count       varchar2(10);
begin

  select  MIPRIID into V_MIPRIID  From meterinfo  where miid =P_MIID ;


    --欠费金额
    select nvl(SUM(RLJE),0) INTO v_money FROM RECLIST
     WHERE RLPRIMCODE =V_MIPRIID
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       and rlbadflag ='N';


    select nvl(count(*),0) INTO v_count FROM RECLIST
     WHERE RLPRIMCODE =V_MIPRIID
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       and rlbadflag ='N'
       and nvl(RLTRANS,'NULL')  in ( lower('u'), lower('v'), '13', '14', '21','23')    /*不包含基建、补缴、客服及稽查  */;

  if v_count>0 then
    return '-';
  else
    return v_money;
  end if;

end FGETYSJE;
/

