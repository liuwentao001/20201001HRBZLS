create or replace package body pg_dhz is

    --呆账坏账 批量工单处理
    procedure dhgl_gd_pl(p_reno varchar2, p_oper in varchar2, o_log out varchar2) is
      v_log varchar(500);
    begin
      for i in (select regexp_substr(p_reno, '[^,]+', 1, level) reno from dual connect by level <= length(p_reno) - length(replace(p_reno, ',', '')) + 1) loop
        dhgl_gd(i.reno , p_oper , v_log );
        o_log := o_log || v_log;
      end loop;
    end;

    --呆账坏账 工单处理
    procedure dhgl_gd(p_reno varchar2, p_oper in varchar2, o_log out varchar2) is
      v_reshbz char(1);
      v_rewcbz char(1);
      v_rlid varchar(2000);
      v_rlcid varchar2(10);
      v_rlpaidflag char(1);
      v_rlreverseflag char(1);
    begin
      begin
        select reshbz, rewcbz, rlid, rlcid into v_reshbz, v_rewcbz, v_rlid, v_rlcid from request_dhgl where reno = p_reno;
      exception
        when no_data_found then o_log := o_log || p_reno || '无效的工单号' || chr(10);
        return;
      end;

      if v_reshbz <> 'Y' then
        o_log := o_log || p_reno || '工单未完成审核，无法提交' || chr(10);
        return;
      elsif v_rewcbz = 'Y' then
        o_log := o_log || p_reno || '工单已完成，无法重复提交'|| chr(10);
        return;
      end if;

      o_log := o_log || p_reno || '呆账坏账工单开始执行'|| chr(10);

      begin
        select rlpaidflag, rlreverseflag into v_rlpaidflag, v_rlreverseflag from bs_reclist where rlid = v_rlid;
      exception
        when no_data_found then o_log := o_log || v_rlid || '无效的应收账流水号' || chr(10);
        return;
      end;

      if v_rlpaidflag = 'Y' then
        o_log := o_log || v_rlid || '应收账已销账，无法变更状态' || chr(10);
      elsif v_rlreverseflag = 'Y' then
        o_log := o_log || v_rlid || '应收账已冲正，无法变更状态' || chr(10);
      else
        update bs_reclist set rlbadflag = 'Y' where rlid = v_rlid;
        o_log := o_log || v_rlid || ' 应收账已转为呆坏账'|| chr(10);
        --更新工单状态
        update request_dhgl
           set rewcbz = 'Y',
               modifydate = sysdate,
               modifyuserid = p_oper,
               modifyusername = (select user_name from sys_user where user_id = p_oper)
         where reno = p_reno;
        --更改 用户 有审核状态的工单 状态
        update bs_custinfo set reflag = 'N' where ciid = v_rlcid;
        o_log := o_log || p_reno || '呆账坏账工单执行完成'|| chr(10);
        commit;
      end if;
    exception
      when others then
        o_log := o_log || p_reno || '无效的工单号' ;
        rollback;
    end;

    --呆账坏账 销账
    procedure dhgl_xz(p_rlids varchar2, p_oper varchar2, p_payway varchar2, o_log out varchar2, o_status out varchar2) is
      v_rlcid varchar2(100);
      v_pid varchar2(100);
      v_rlje number;
      v_misaving number;
    begin
      for i in (select regexp_substr(p_rlids, '[^,]+', 1, level) rlid from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1) loop

        begin
          select bs_reclist.rlcid , bs_reclist.rlje, bs_custinfo.misaving into v_rlcid ,v_rlje, v_misaving
          from bs_reclist left join bs_custinfo on bs_reclist.rlcid = bs_custinfo.ciid
          where bs_reclist.rlid = i.rlid;
        exception
          when no_data_found then 
            o_log := o_log || i.rlid || '无效的应收帐流水号' || chr(10);
            o_status := '000';
          return;
        end;

        if v_rlje > v_misaving then
           o_log := o_log || i.rlid ||  '用户余额不足无法销账' || chr(10);
           o_status := '000';
        else
          pg_paid.poscustforys(v_rlcid, i.rlid, p_oper, p_payway, 0, v_pid);
          o_log := o_log || i.rlid || '应收帐，销账完成'|| chr(10);
          o_status := '999';
        end if;
      end loop;
    exception
      when others then
        o_status := '000';
        rollback;
    end;

end pg_dhz;
/

