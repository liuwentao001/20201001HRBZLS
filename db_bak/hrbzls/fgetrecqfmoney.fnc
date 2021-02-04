CREATE OR REPLACE FUNCTION HRBZLS."FGETRECQFMONEY" (p_miid in varchar2) return varchar2 is
  v_msg         varchar2(500);
  v_qfnum       number(5);
  v_money       number(12,3);
  v_code varchar2(20);
begin
  select count(mipriid ),sum(nvl(misaving,0)),max(mipriid)
  into v_qfnum,v_money,v_code
  from meterinfo
  where  mipriid in (select  distinct mipriid from meterinfo where    micode=p_miid ) group by mipriid;
  
  if v_money>0 then
    v_msg:='此用户存在预存'||to_char(v_money)||'金额，';
    return(v_msg);
  end if;
  select count(RLID),sum(t.rlje - T.RLPAIDJE),max(rlccode )
  into v_qfnum,v_money,v_code
  from reclist t
  where t.rlmid = p_miid
  and   t.rlpaidflag in ('N','V','K','W')
  and   t.rlcd = 'DE'
  and   t.rlreverseflag = 'N'
  and   t.rlje >0
  and   t.rlje - T.RLPAIDJE>0;

  if v_qfnum > 0 then
     v_msg :=v_code|| '已发生累计欠费共 '||to_char(v_qfnum)||'笔,总金额 '||trim(to_char(v_money,'999999999990.00'))||'元';
  else
     v_msg :='0';
  end if;

  return(v_msg);
end FGETRECQFMONEY;
/

