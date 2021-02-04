CREATE OR REPLACE FUNCTION HRBZLS."FTSOLDSEARCHWHERE" (P_TYPE      IN VARCHAR2,
                                             P_smfid     IN VARCHAR2,
                                             P_macname   IN VARCHAR2,
                                             P_maccount  IN VARCHAR2,
                                             P_rmonth    IN VARCHAR2,
                                             P_rldatemin IN VARCHAR2,
                                             P_rldatemax IN VARCHAR2,
                                             P_tsseqno   IN VARCHAR2)
  RETURN VARCHAR2 AS
  v_where varchar2(1000);
BEGIN
if P_TYPE='1' then
  if P_smfid is not null  then
       v_where :=v_where || ' and rlsmfid ='''|| P_smfid||'''';
  end if;
  if P_rldatemin<>'0000-00-00' and P_rldatemax<>'0000-00-00'  then
       v_where :=v_where ||' and rldate >= to_date('''|| P_rldatemin ||''',''yyyy-mm-dd'') and rldate <= to_date('''|| P_rldatemax ||''',''yyyy-mm-dd'')';
  end if;
  if P_macname is not null  then
    if P_maccount is not null then
      v_where :=v_where || ' and rlmid in(select miid  from meterinfo,meteraccount  where  miid=mamid(+) and (maaccountname ='''||P_macname||''' or maaccountno = '''||P_maccount||''' ))';
    elsif  P_maccount is null then
       v_where :=v_where || 'and rlmid in(select miid  from meterinfo,meteraccount  where  miid=mamid(+) and (maaccountname ='''||P_macname||''' ))';
    end if;
  else
    if  P_maccount is not null then
      v_where :=v_where ||' and rlmid in(select miid  from meterinfo,meteraccount  where  miid=mamid(+) and ( maaccountno = '''||P_maccount||'''))';
    end if;
  end if;
  if P_rmonth<>'0000.00'  then
       v_where :=v_where ||' and rlmonth = '''||P_rmonth||'''';
  end if;
  if P_tsseqno is not null then
       v_where :=v_where ||' and rlccode ='''||P_tsseqno||'''';
  end if;
       v_where :=v_where ||'
       and rlcd=''DE'' and rlpaidflag in (''V'',''N'')
  and rdpaidflag =''N''
       ';
       -- and rlentrustbatch is not null and rlentrustseqno is not null
  else
       raise_application_error(-20010,
                                    '类型参数传入错误');
  end if;



  RETURN v_where;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

