create or replace package body pg_cb_cost is
  callogtxt clob;
  最低算费水量 number(10);
  
  procedure wlog(p_txt in varchar2) is
  begin
    callogtxt := callogtxt || chr(10) || to_char(sysdate, 'mm-dd hh24:mi:ss >> ') || p_txt;
  end;
  
  --外部调用，自动算费
  procedure autosubmit is
    vlog clob;
  begin
    for i in (select mrbfid from bs_meterread
               where mrreadok = 'Y' and mrifrec = 'N'
               group by mrsmfid, mrbfid) loop
      submit(i.mrbfid , vlog);
    end loop;
  exception
    when others then raise;
  end;
  
  --计划内抄表提交算费
  procedure submit(p_mrbfid in varchar2, log out clob) is
    cursor c_mr(vbfid in varchar2) is
    select mrid
      from bs_meterread, bs_meterinfo
     where mrmid = miid
       and mrbfid = vbfid
       and bs_meterinfo.mistatus not in ('24', '35', '36', '19') --算费时，故障换表中、周期换表中、预存冲销中、销户中的不进行算费,需把故障换表中、周期换表中单据审核完才能算费 20140628
       and mrifrec = 'N' --抄见状态
     order by miclass desc,(case when mipriflag = 'y' and miid <> mipid then 1 else 2 end) asc;
     vmrid bs_meterread.mrid%type;
  begin
    callogtxt := null;
    wlog('正在算费表册号：' || p_mrbfid || ' ...');
    open c_mr(p_mrbfid);
    loop
      fetch c_mr into vmrid;
      exit when c_mr%notfound or c_mr%notfound is null;
      --单条抄表记录处理
      begin
        calculate(vmrid);
        commit;
      exception
        when others then rollback; wlog('抄表记录' || vmrid || '算费失败，已被忽略');
      end;
    end loop;
    close c_mr;
    wlog('算费过程处理完毕');
    log := callogtxt;
  exception
    when others then
      rollback;
      log := callogtxt;
      raise_application_error(errcode, sqlerrm);
  end;
  
  --计划抄表单笔算费
  procedure calculate(p_mrid in bs_meterread.mrid%type) is
    cursor c_mr is
      select * from bs_meterread
       where mrid = p_mrid
         and mrifrec = 'N'   --已计费(Y-是 N-否)
         and mrsl >= 0 
         for update nowait;
    cursor c_mi(p_mid in varchar2) is select * from bs_meterinfo where miid = p_mid;
    mr bs_meterread%rowtype;
    mi bs_meterinfo%rowtype;
  begin
    
    open c_mr;
    fetch c_mr into mr;
    if c_mr%notfound or c_mr%notfound is null then
      raise_application_error(errcode, '无效的抄表计划流水号');
    end if;
    --抄表数据来源  1表示计划抄表   5表示远传抄表   9表示抄表机抄表
    if mr.mrsl < 最低算费水量 and mr.mrdatasource in ('1', '5', '9', '2') /*and (mr.mrrpid = '00' or mr.mrrpid is null) --计件类型*/ then
      raise_application_error(errcode, '抄表水量小于最低算费水量，不需要算费');
    end if;
    
   --水表记录
    open c_mi(mr.mrmid);
    fetch c_mi into mi;
    if c_mi%notfound or c_mi%notfound is null then
      wlog('无效的水表编号' || mr.mrmid);
      raise_application_error(errcode, '无效的水表编号' || mr.mrmid);
    end if;
    close c_mi;
  
    if mi.mistatus = '24' and mr.mrdatasource <> 'm' then
      --如果表状态为故障换表中且此抄表记录来源不是故障抄表余量，则提示不能算费，有故障换表
      wlog('此水表编号正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.' || mr.mrmid);
      raise_application_error(errcode, '此水表编号[' || mr.mrmid ||']正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.');
    end if;
    if mi.mistatus = '35' and mr.mrdatasource <> 'l' then
      --如果表状态为周期换表中且此抄表记录来源不是周期抄表余量，则提示不能算费，有周期换表
      wlog('此水表编号正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.' || mr.mrmid);
      raise_application_error(errcode,'此水表编号[' || mr.mrmid ||']正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.');
    end if;
    if mi.mistatus = '36' then
      --预存冲正中
      wlog('此水表编号正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.' || mr.mrmid);
      raise_application_error(errcode, '此水表编号[' || mr.mrmid || ']正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.');
    end if;
    if mi.mistatus = '39' then
      --预存冲正中
      wlog('此水表编号正在预存撤表退费中,不能进行算费,如需算费请先审核或删除预存冲正单据.' || mr.mrmid);
      raise_application_error(errcode, '此水表编号[' || mr.mrmid ||']正在预存冲正中,不能进行算费,如需算费请先审核或删除预存冲正单据.');
    end if;
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('m','l') then
       --水表起码已经改变
       wlog('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || mr.mrmid);
       raise_application_error(errcode,'此水表编号[' || mr.mrmid || ']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    end if;
    if mi.mistatus = '19' then
      --销户中
      wlog('此水表编号正在销户中,不能进行算费,如需算费请先审核销户单据或删除销户单据.' || mr.mrmid);
      raise_application_error(errcode, '此水表编号[' || mr.mrmid || ']正在销户中,不能进行算费,如需算费请先审核销户或删除销户单据.');
    end if;

    mr.mrrecsl := mr.mrsl; --本期水量

  end;
  
begin
  select to_number(spvalue) into 最低算费水量 from sys_para where spid='1092';
end;
/

