create or replace package body pg_rectrans is

  --追量收费 工单
  --源表：request_zlsf
  procedure rectrans_gd(p_reno request_zlsf.reno%type, o_log out varchar2) is
    v_miid varchar(20);
    v_mrscode number;
    v_mrecode number;
    v_mrsl number;
    v_mrdatasource varchar2(1);
    v_mrid varchar2(20);
    o_mrrecje01 bs_meterread.mrrecje01%type;
    o_mrrecje02 bs_meterread.mrrecje02%type;
    o_mrrecje03 bs_meterread.mrrecje03%type;
    o_mrrecje04 bs_meterread.mrrecje04%type;
    v_insmr_log varchar2(2000);
    v_cal_log varchar2(2000);
    v_reshbz varchar2(1);
    v_rewcbz varchar(1);
    v_reifreset varchar(1);
    v_reifstep varchar(1);
  begin
    select miid, mircode, rercode, abs(rercode - mircode), 'Z', reshbz, rewcbz, reifreset, reifstep
           into v_miid , v_mrscode , v_mrecode , v_mrsl , v_mrdatasource ,v_reshbz, v_rewcbz, v_reifreset, v_reifstep
    from request_zlsf where reno = p_reno;
    
    if v_reshbz <> 'Y' or v_reshbz is null then o_log := '工单未审核，无法追量收费'; return; end if;
    if v_rewcbz = 'Y' then  o_log := '工单已完成，无法追量收费'; return; end if; 
    
    --生成抄表信息
    ins_mr(v_miid , v_mrscode , v_mrecode , v_mrsl , v_mrdatasource, p_reno, v_reifreset, v_reifstep, v_mrid, v_insmr_log);
    --算费
    pg_cb_cost.calculatebf(v_mrid, '02', o_mrrecje01, o_mrrecje02, o_mrrecje03, o_mrrecje04, v_cal_log);    
    
    update request_zlsf set rewcbz = 'Y' where reno = p_reno;
    commit;
    o_log := '追量收费工单完成';
    
  exception
      when no_data_found then o_log := '无效的工单号：' || p_reno;
      return;
  end;

  --生成抄表记录
  procedure ins_mr(p_miid varchar2, p_mrscode number, p_mrecode number, p_mrsl number, 
            p_mrdatasource varchar2, p_mrgdid varchar2, p_mrifreset varchar2, p_mrifstep varchar2,
            o_mrid out varchar2, o_log out varchar2) is
    v_rowcount number;
  begin
    o_mrid := fgetsequence('METERREAD');
    
    insert into bs_meterread (mrid, mrmonth, mrsmfid, mrbfid, mrccode, mrmid, mrstid, mrcreadate, mrreadok, mrrdate, mrprdate, mrrper,
       mrscode, mrecode, mrsl, mrifsubmit, mrifhalt, mrdatasource, mrifrec, mrrecsl, mrpfid, mrgdid, mrifreset, mrifstep)
    select o_mrid, to_char(sysdate, 'yyyy.mm'), mismfid, mibfid, micode, miid, mistid, sysdate, 'N', sysdate, sysdate, '1',
           p_mrscode, p_mrecode, p_mrsl, 'Y', 'N', p_mrdatasource, 'N', 0, mipfid, p_mrgdid, p_mrifreset, p_mrifstep
    from bs_meterinfo 
    where miid = p_miid;
    
    commit;
    v_rowcount := sql%rowcount;
    if v_rowcount = 1 then
      o_log := '生产抄表记录成功';
    else
      o_log := '生产抄表记录失败';
    end if;
    
  end;
  
end pg_rectrans;
/

