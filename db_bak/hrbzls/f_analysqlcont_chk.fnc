CREATE OR REPLACE FUNCTION HRBZLS."F_ANALYSQLCONT_CHK" (p_billno     in varchar2,
                                              p_billflowid in varchar2,
                                              p_billid     in varchar2,
                                              p_billkey    in varchar2,
                                              p_oper       in varchar2)
  return varchar2 is
  dtf        dwcontinfo%rowtype;
  fd         flow_define%rowtype;
  v_sqlstr   varchar2(4000);
  v_tablestr varchar2(4000);
  v_wherestr varchar2(4000);
  V_MICODE   METERINFO.MICODE%TYPE;
  v_TEMPJE   number(13, 3);
  v_TEMPJE1  number(13, 3);
  V_TEMPSL   number(13, 3);
  v_ret      varchar2(4000);
  v_billkey  varchar2(4000);
  v_chkje    number(13, 3);
  v_chksl    number(10);
begin
  --是否不否需要检查
  begin
    select T.*
      into fd
      from flow_define t, billmain t1
     where t1.BMFLAG2 = t.fid
       and t.fno = p_billflowid
       AND T1.BMID = p_billno;
  exception
    when others then
      return '流程定义错误';
  end;
  --前台功能查检
  if fd.fchktype is null or fd.fchktype = '0' then
    return 'Y';
  end if;



  IF fd.fchktype = '1' THEN
    begin
        select to_number(OAPVALUE)
          into v_chkje
          from operaccntpara
         where OAPOAID = p_oper
           and OAPTYPE = p_billno;
      exception
        when others then
          RETURN 'N';
      end;
      IF v_chkje IS NULL THEN
        RETURN 'N';
      end if;
      IF v_chkje <= 0 THEN
        RETURN 'N';
      end if;

    if p_billno = '110' then
      --滞纳金额减免
      begin
        select sum(ZADINTZNJ - ZADVALUE), MAX(ZADMCODE)
          into v_TEMPJE, v_micode
          from ZNJADJUSTDT t
         where t.zadno = p_billid;
      exception
        when others then
          RETURN 'N';
      end;
      IF v_TEMPJE IS NULL THEN
        RETURN 'N';
      END IF;
      --单张单处理额度
      IF v_chkje < v_TEMPJE THEN
        RETURN 'N';
      END IF;
      --一个月对用户累计减免额度检查 --减除当前重复减免应收帐滞纳金额
      begin
        select sum(ZADINTZNJ - ZADVALUE)
          into v_TEMPJE1
          from znjadjustlist t, ZNJADJUSTDT t1
         where t.ZALBILLNO = t1.zadno
           and t.zalbillrowno = t1.zadrowno
           and zalmcode = V_MICODE
           AND zalstatus = 'Y'
           AND ZALDATE >= TRUNC(SYSDATE, 'MM')
           AND ZALDATE <= SYSDATE
           AND ZALRLID not in
               (select ZADRLID from ZNJADJUSTDT where zadno = p_billid);
      exception
        when others then
          v_TEMPJE1 := 0;
      end;
      if v_TEMPJE1 is null then
        v_TEMPJE1 := 0;
      end if;
      IF v_chkje < v_TEMPJE + v_TEMPJE1 THEN
        RETURN 'N';
      END IF;
      return 'Y';

    elsif p_billno = '108' then
      --水费调整
      begin
        select -sum(RADADJSL), MAX(RADMCODE)
          into v_TEMPJE, v_micode
          from RECADJUSTDT t
         where t.RADNO = p_billid;
      exception
        when others then
          RETURN 'N';
      end;
      IF v_TEMPJE IS NULL THEN
        RETURN 'N';
      END IF;
      --单张单处理额度
      IF v_chkje < v_TEMPJE THEN
        RETURN 'N';
      END IF;
      --一个月对用户累计减免额度检查 --减除当前重复减免应收帐
      begin
        select -sum(RADADJSL)
          into v_TEMPJE1
          from RECADJUSTHD t, RECADJUSTDT t1
         where t.rahno = t1.radno
           and RAHMCODE = V_MICODE
           AND RAHSHFLAG = 'Y'
           AND RAHSHDATE >= TRUNC(SYSDATE, 'MM')
           AND RAHSHDATE <= SYSDATE
           ;
      exception
        when others then
          v_TEMPJE1 := 0;
      end;
      if v_TEMPJE1 is null then
        v_TEMPJE1 := 0;
      end if;
      IF v_chkje < v_TEMPJE + v_TEMPJE1 THEN
        RETURN 'N';
      END IF;
      return 'Y';
    end if;
  end if;

  /*--条件检查类别 与单据相关 后台检查，并过滤下一个发送人
  IF fd.fchktype='1' THEN
  begin
  select t.* into dtf   from dwcontinfo t
  where dcifowner = p_oper and  dciftype = p_billno||p_billflowid and t.dcifflag='Y' and rownum=1 ;
  exception when others then
    return '没有给此用户限定条件,请定义好限制条件后再审批';
  end;
  v_sqlstr :=f_analypbsql(dtf.dcifdwconstr );
  v_tablestr := tools.fmid_sepmore(v_sqlstr, 1, 'N', '【#$#】')  ;
  v_wherestr := tools.fmid_sepmore(v_sqlstr, 2, 'N', '【#$#】')  ;
  if dtf.dcifdwname=fd.fpara1  then
    v_billkey :=tools.fmid_sepmore(p_billkey, 1, 'N', '/')  ;
  elsif dtf.dcifdwname=fd.fpara2  then
      v_billkey :=tools.fmid_sepmore(p_billkey, 1, 'N', '/')  ;
  elsif dtf.dcifdwname=fd.fpara3  then
    v_billkey :=tools.fmid_sepmore(p_billkey, 2, 'N', '/')  ;
  else
      v_billkey :=p_billkey;
  end if;

    v_sqlstr := 'select  count(*) from ' ||v_tablestr || '  where ' ||v_wherestr ||' and '|| v_billkey ||' ='''||p_billid||'''' ;
    execute immediate v_sqlstr into v_count;
       if v_count>0 then
         v_ret :='Y';
       ELSE
         v_ret :='N';
       end if;
    return v_ret;
  END IF;
  */ --特殊情况检查
exception
  when others then
    return '异常';
end;
/

