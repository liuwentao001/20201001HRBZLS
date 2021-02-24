create or replace package body pg_dhz is
  --呆账坏账过程包
  
  --呆账坏账工单处理
  procedure dhgl_gd(p_reno varchar2, p_oper varchar2, o_log out varchar2) is
    v_rlid           varchar(2000);  --应收账流水号，多个逗号分隔
    v_rlcid          varchar2(10);   --用户编码
    v_reshbz         char(1);        --工单审核标志
    v_rewcbz         char(1);        --工单完成标志
    v_rlreverseflag  char(1);        --冲正标志
    v_rlpaidflag     char(1);        --销账标志
  begin
    o_log := p_reno || '呆坏账工单处理开始' || chr(10);
    
    --工单有效验证
    begin
      select rlid, rlcid, reshbz, rewcbz into v_rlid, v_rlcid, v_reshbz, v_rewcbz from request_dhgl where reno = p_reno;
    exception 
      when no_data_found then 
        o_log := p_reno || '无效的工单号';
      return;
    end;
    
    if v_reshbz <> 'Y' then
      o_log := p_reno || '工单未完成审核，无法执行'|| chr(10);
      return;
    elsif v_rewcbz = 'Y' then
      o_log := p_reno || '工单已完成，无法重复执行'|| chr(10);
      return;
    end if;
    
    --更新应收账状态为呆账坏账
    for i in(select regexp_substr(v_rlid, '[^,]+', 1, level) rlid from dual connect by level <= length(v_rlid) - length(replace(v_rlid, ',', '')) + 1) loop
      begin
        v_rlreverseflag := null;
        v_rlpaidflag := null;
        select rlreverseflag, rlpaidflag into v_rlreverseflag, v_rlpaidflag from bs_reclist where rlid = i.rlid;
      exception 
        when no_data_found then
          o_log := o_log || i.rlid ||'无效的应收账流水号' || chr(10);
        continue;
      end;
      
      if v_rlreverseflag = 'Y' then
        o_log := o_log || i.rlid ||'应收账已冲正，无法更新呆坏账状态' || chr(10);
        continue;
      elsif v_rlpaidflag = 'Y' then
        o_log := o_log || i.rlid ||'应收账已销账，无法更新呆坏账状态' || chr(10);
        continue;
      else
        update bs_reclist 
           set rlbadflag = 'Y'
         where rlid = i.rlid;
         o_log := o_log || i.rlid || '应收账呆坏账状态更新完成' || chr(10);
      end if;
    end loop;
    
    --更新应收账状态为呆账坏账
    update bs_reclist 
       set rlbadflag = 'Y'
     where rlid in (select regexp_substr(v_rlid, '[^,]+', 1, level) pid from dual connect by level <= length(v_rlid) - length(replace(v_rlid, ',', '')) + 1)
           and rlreverseflag = 'N'
           and rlpaidflag = 'N';
    
    --更新工单状态
    update request_dhgl 
       set rewcbz = 'Y',
           modifydate = sysdate,
           modifyuserid = p_oper,
           modifyusername = (select user_name from sys_user where user_id = p_oper)
     where reno = p_reno;
    --更改 用户 有审核状态的工单 状态
    update bs_custinfo set reflag = 'N' where ciid = v_rlcid;
    
    o_log := o_log || p_reno || '呆坏账工单处理完成' || chr(10);
    commit;
  exception
    when others then o_log := p_reno || '呆坏账工单处理失败';
  end;
  
  
  --呆账坏账销账
  procedure dhgl_pay(p_rlid varchar2, p_oper varchar, o_log out varchar2) is
    v_rlcid         varchar2(10);
    v_rlreverseflag char(1);
    v_rlpaidflag    char(1);
    v_rlje          number;
    v_misaving      number;
    v_pid           varchar2(20);
    v_remainafter   number;
  begin
    
    begin
      select rl.rlcid, rl.rlreverseflag, rl.rlpaidflag , rl.rlje, ci.misaving
             into v_rlcid, v_rlreverseflag, v_rlpaidflag , v_rlje, v_misaving
      from bs_reclist rl left join bs_custinfo ci on rl.rlcid = ci.ciid
      where rl.rlid = p_rlid;
    exception 
      when no_data_found then
        o_log := o_log || p_rlid ||'无效的应收账流水号' || chr(10);
    end;
    
    if v_rlreverseflag = 'Y' then
      o_log := o_log || p_rlid ||'应收账已冲正，无法销账' || chr(10);
    elsif v_rlpaidflag = 'Y' then
      o_log := o_log || p_rlid ||'应收账已销账，无法销账' || chr(10);
    elsif v_rlje > v_misaving then
      o_log := o_log || p_rlid ||'预存余额不足，无法销账' || chr(10);
    else
      --销账
      pg_paid.paycust( v_rlcid,
                       p_rlid,
                       '',
                       '',       --v_position,
                       'U',      --缴费事务   柜台缴费
                       p_oper,
                       '',       --payway
                       0,
                       null,
                       v_pid,
                       v_remainafter);
      o_log := p_rlid || '呆坏账销账完成';
    end if;  
  exception
    when others then o_log := p_rlid || '呆坏账销账失败';
  end;
  
end pg_dhz;
/

