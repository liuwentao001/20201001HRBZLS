CREATE OR REPLACE FUNCTION HRBZLS."FGETRLID" (p_code in varchar2,p_mindate in date,p_maxdate in date) --查询用户欠费应收帐流水
 RETURN VARCHAR2 AS
  cursor c_rl is
    select rlid
      from reclist a
     where rlmcode = p_code
       and rldate>= p_mindate
       and rldate<= p_maxdate
       and RLCD = 'DE'
       AND rlpaidflag in ('N', 'V', 'K', 'W')
       AND RLOUTFLAG = 'N'
       AND RLJE > 0;
  v_rlid varchar2(20);
  lret VARCHAR2(4000);
  v_code varchar2(20);
BEGIN
    --判断用户号是否为空
    begin
         select micode into v_code from meterinfo where micode=p_code;
    exception
  when others then
    return 'N';
    END;


    open c_rl;
  LOOP
    FETCH c_rl
      INTO v_rlid;
    EXIT WHEN c_rl%NOTFOUND OR c_rl%NOTFOUND IS NULL;
    lret := lret||v_rlid||',';
  end loop;
  close c_rl;

  if lret is not null then
     lret := substr(lret,1,length(lret)-1);
  else
     lret := 'Y';
  end if;
  Return lret;
exception
  when others then
    lret := 'Y';
END;
/

