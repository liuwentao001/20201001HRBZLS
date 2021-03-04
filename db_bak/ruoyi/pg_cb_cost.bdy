create or replace package body pg_cb_cost is
  callogtxt varchar2(20000);
  v_cal_min_sl        number(10);    --最低算费水量
  v_cal_zbjl          char(1);       --总表截量
  v_cal_auto_pay      char(1); --算费时预存自动销账
  v_smtifcharge1      char(1); --是否计费 1 普表

  procedure wlog(p_txt in varchar2) is
  begin
    callogtxt := callogtxt || chr(10) || to_char(sysdate, 'mm-dd hh24:mi:ss >> ') || p_txt;
  end;

  --外部调用，自动算费
  procedure autosubmit is
  begin
    for i in (select mrbfid from bs_meterread
               where mrreadok = 'Y' and mrifrec = 'N'
               group by mrsmfid, mrbfid) loop
      submit(i.mrbfid , callogtxt);
    end loop;
  exception
    when others then raise;
  end;

  --计划内抄表提交算费
  procedure submit(p_mrbfids in varchar2, log out varchar2) is
    cursor c_mr(vbfid in varchar2) is
      select mr.mrid
        from bs_meterread mr
             left join bs_meterinfo mi on mr.mrmid = mi.miid
             left join bs_custinfo ci on ci.ciid = mr.mrccode
       where ((mr.mrdatasource in ('1','5','6','7','9') and  (ci.reflag <> 'Y' or ci.reflag is null)) or (mr.mrdatasource not in ('1','5','6','7','9') and ci.reflag = 'Y')) --有审核状态的工单按工单状态算费
         and mr.mrbfid in (select regexp_substr(vbfid, '[^,]+', 1, level) mrbfid from dual connect by level <= length(vbfid) - length(replace(vbfid, ',', '')) + 1)
         --and bs_meterinfo.mistatus not in ('24', '35', '36', '19') --算费时，故障换表中、周期换表中、预存冲销中、销户中的不进行算费,需把故障换表中、周期换表中单据审核完才能算费
         and mr.mrifrec = 'N' --是否已计费
         and mr.mrsl >= 0
       order by miclass desc,(case when mipriflag = 'Y' and miid <> mipid then 1 else 2 end) asc;
     vmrid bs_meterread.mrid%type;
     v_mrrecje01 bs_meterread.mrrecje01%type;
     v_mrrecje02 bs_meterread.mrrecje02%type;
     v_mrrecje03 bs_meterread.mrrecje03%type;
     v_mrrecje04 bs_meterread.mrrecje04%type;
     v_mrsumje   number;
  begin
    callogtxt := null;
    wlog('正在算费表册号：' || p_mrbfids || ' ...');
    open c_mr(p_mrbfids);
    loop
      fetch c_mr into vmrid;
      exit when c_mr%notfound or c_mr%notfound is null;
      --单条抄表记录处理
      begin
        calculatebf(vmrid, '02',v_mrrecje01, v_mrrecje02, v_mrrecje03, v_mrrecje04, v_mrsumje, log);
        wlog('抄表流水：'||vmrid || ' 算费完成'|| ' ' || v_mrrecje01 || ' ' ||  v_mrrecje02 || ' ' ||  v_mrrecje03 || ' ' ||  v_mrrecje04 );
        commit;
      exception
        when others then rollback; wlog('抄表记录' || vmrid || '算费失败，已被忽略');
      end;
    end loop;
    close c_mr;
    wlog('算费过程处理完毕：'||p_mrbfids);
    log := callogtxt;
  exception
    when others then
      rollback;
      log := callogtxt;
      if c_mr%isopen then close c_mr; end if;
      --raise_application_error(errcode, sqlerrm);
  end;

  --简单算费，仅供抄表时参考
  procedure calculate_simp(p_mrid in bs_meterread.mrid%type,
             o_mrrecje01 out number,
             o_mrrecje02 out number,
             o_mrrecje03 out number,
             o_mrrecje04 out number,
             o_mrsumje   out number) is
  begin
    select sum((mr.mrecode - mr.mrscode) * pd.pddj),
         sum(case when pd.pdpiid = '01' then (mr.mrecode - mr.mrscode) * pd.pddj else 0 end),
         sum(case when pd.pdpiid = '02' then (mr.mrecode - mr.mrscode) * pd.pddj else 0 end),
         sum(case when pd.pdpiid = '03' then (mr.mrecode - mr.mrscode) * pd.pddj else 0 end),
         sum(case when pd.pdpiid = '04' then (mr.mrecode - mr.mrscode) * pd.pddj else 0 end)
         into o_mrsumje,o_mrrecje01,o_mrrecje02,o_mrrecje03,o_mrrecje04
    from bs_meterread mr 
         left join bs_meterinfo mi on mr.mrmid = mi.miid 
         left join bs_pricedetail pd on mi.mipfid = pd.pdpfid
    where mr.mrid = p_mrid;
  end;
  
  --算费前虚拟算费，供月抄表明细调用
  procedure calculatebf(p_mrid in bs_meterread.mrid%type,
             p_caltype   in  varchar2,    -- 01 虚拟算费; 02 正式算费
             o_mrrecje01 out bs_meterread.mrrecje01%type,
             o_mrrecje02 out bs_meterread.mrrecje02%type,
             o_mrrecje03 out bs_meterread.mrrecje03%type,
             o_mrrecje04 out bs_meterread.mrrecje04%type,
             o_mrsumje   out number,
             err_log out varchar2) is
    mr bs_meterread%rowtype;
    v_reflag varchar(10);          --工单状态(Y:存在审批过程中的工单；N:不存在)
  begin
    select * into mr from bs_meterread where mrid = p_mrid;
    select reflag into v_reflag from bs_custinfo where ciid = mr.mrccode;

    if mr.mrdatasource in ('1','5','6','7','9') and v_reflag = 'Y' then
      wlog('存在审批过程中的工单，无法算费');
      err_log := callogtxt;
      return;
    end if;

    if mr.mrifrec = 'N' then
      --重置水表信息
      if p_caltype = '01' then
        update bs_meterinfo mi
        set    mi.miifcharge = 'N',
               mi.mircode = mr.mrscode
        where  mi.miid = mr.mrmid;
      elsif p_caltype = '02' then
        update bs_meterinfo mi
        set    mi.miifcharge = 'Y',
               mi.mircode = mr.mrscode
        where  mi.miid = mr.mrmid;
      else
        wlog('请正确输入算费类型：01 虚拟算费，02 正式算费');
        err_log := callogtxt;
        return;
      end if;

      --重置抄表库
      update bs_meterread
      set    mrrecje01 = null,
             mrrecje02 = null,
             mrrecje03 = null,
             mrrecje04 = null
      where  mrid = p_mrid and mrifrec = 'N';

      --删除应收账务信息
      delete from bs_recdetail where rdid in (select rlid from bs_reclist where rlmrid = p_mrid and rlreverseflag <> 'Y');
      delete from bs_reclist where rlmrid = p_mrid and rlreverseflag <> 'Y';

      commit;
      calculate(p_mrid);

      --更改 用户 有审核状态的工单 状态
      if v_reflag = 'Y' then
        update bs_custinfo set reflag = 'N' where ciid = mr.mrccode;
      end if;

      commit;
      select mrrecje01,mrrecje02,mrrecje03,mrrecje04 ,nvl(mrrecje01,0) + nvl(mrrecje02,0) + nvl(mrrecje03,0) + nvl(mrrecje04,0)
             into o_mrrecje01, o_mrrecje02, o_mrrecje03, o_mrrecje04, o_mrsumje
       from bs_meterread
      where mrid = p_mrid;
      err_log := callogtxt;
    else
      wlog('当前抄表计划流水号已正式算费，无法重算');
      err_log := callogtxt;
    end if;
  exception
    when others then
      rollback;
      wlog('无效的抄表计划流水号：'|| p_mrid );
      err_log := callogtxt;
      --raise_application_error(errcode, sqlerrm);
  end;

  --计划抄表单笔算费
  procedure calculate(p_mrid in bs_meterread.mrid%type) is
   cursor c_mr is
      select * from bs_meterread
       where mrid = p_mrid
         and mrifrec = 'N'   --已计费(Y-是 N-否)
         and mrsl >= 0
         for update nowait;
   cursor c_mr_child(p_mpid in varchar2, p_month in varchar2) is
      select mrsl, mrifrec, mrreadok, nvl(mrcarrysl, 0) mrcarrysl --校验水量
        from bs_meterinfo, bs_meterread
       where mrmid = miid
         and mipid = p_mpid
         and mrmonth = p_month
      union all
      select mrsl, mrifrec, mrreadok, nvl(mrcarrysl, 0) mrcarrysl
        from bs_meterinfo, bs_meterread_his, bs_reclist
       where mrmid = miid
         and mrid = rlmrid
         and mipid = p_mpid
         and mrmonth = p_month
         and (mrdatasource = 'M' or mrdatasource = 'L') --周期换表、故障换表
         and rlreverseflag = 'N';
    --一户多表用户信息zhb
    cursor c_mr_pr(p_mipriid in varchar2) is
      select miid
        from bs_meterinfo, bs_meterread
       where mrmid(+) = miid
         and mipid = p_mipriid
       order by miid;
    --合收子表抄表记录
    cursor c_mr_pri(p_primcode in varchar2) is
      select mrsl, mrifrec, mrmid
        from bs_meterinfo, bs_meterread
       where mrmid = miid
         and mipriflag = 'Y'
         and mipid = p_primcode
         and micode <> p_primcode;
    --取合收表信息
    cursor c_mi(p_mid in varchar2) is
      select * from bs_meterinfo where miid = p_mid;
    --总表有周期换表、故障换表的余量抓取
    cursor c_mi_class(p_mrmid in varchar2, p_month in varchar2) is
      select nvl(decode(nvl(sum(mraddsl), 0), 0, sum(mrsl), sum(mraddsl)),0)
        from bs_meterinfo, bs_meterread_his, bs_reclist
       where mrmid = miid
         and mrid = rlmrid
         and mrmid = p_mrmid
         and mrmonth = p_month
         and (mrdatasource = 'M' or mrdatasource = 'L') --周期换表、故障换表
         and rlreverseflag = 'N' --未冲正
         and rlsl > 0;
    mr         bs_meterread%rowtype;
    mrchild    bs_meterread%rowtype;
    mi         bs_meterinfo%rowtype;
    mil        bs_meterinfo%rowtype;
    v_sumnum      number; --子表数
    v_readnum     number; --抄见子表数
    v_recnum      number; --算费子表数
    v_miclass     number;
    v_mipid       varchar2(10);
    v_mrmcode     varchar2(10);
    v_mdhis_addsl bs_meterread_his.mraddsl%type;
    v_pd_addsl    bs_meterread_his.mraddsl%type;
    v_mrcode_tmp number;
    v_rec_cal varchar2(1);
  begin
    open c_mr;
    fetch c_mr into mr;
    if c_mr%notfound or c_mr%notfound is null then
      wlog('无效的抄表计划流水号：'|| p_mrid);
      raise_application_error(errcode, '无效的抄表计划流水号：'||p_mrid);
    end if;
    --抄表数据来源  1表示计划抄表   5表示远传抄表   9表示抄表机抄表
    if mr.mrsl < v_cal_min_sl and mr.mrdatasource in ('1', '5', '9', '2') /*and (mr.mrrpid = '00' or mr.mrrpid is null) --计件类型*/ then
      wlog('抄表水量小于最低算费水量，不需要算费');
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

    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L') then
       --水表起码已经改变
       wlog('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || mr.mrmid);
       raise_application_error(errcode,'此水表编号[' || mr.mrmid || ']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    end if;
    if mi.miyl1 = 'Y' then
       wlog('此水表等针状态，无法算费！' || mr.mrmid);
       raise_application_error(errcode,'此水表编号[' || mr.mrmid || ']此水表等针状态，无法算费！');
    end if;

    --反向算费，计算负向指针先把指针互换
    if mr.mrscode > mr.mrecode then
      v_mrcode_tmp := mr.mrscode;
      mr.mrscode := mr.mrecode;
      mr.mrecode := v_mrcode_tmp;
      mi.mircode := mr.mrscode;
      v_rec_cal := 'Y';        --反向算费标志
    end if;

    --总表收免  真实水量等于抄表水量 减去 总表收免水量最大值
    if mi.miyl2 = '1' then
       mr.mrrecsl := mr.mrsl - nvl(mi.miyl7,0);
    else
       mr.mrrecsl := mr.mrsl; --本期水量
    end if;

    -----------------------------------------------------------------------------
    --子表水量抵减计费总表抄见水量
    -----------------------------------------------------------------------------
    if v_cal_zbjl = 'Y' then
      --######总分表算费   20140412 BY HK#######
      /*
      规则：
      1、同一表册，分表先算费，算费同普通表
      2、总表需要先判断分表是否都已算费，分表全算费了才允许总表算费
      3、总表按总表截量算费（总表抄见 - 分表抄见和），如果总表截量小于0，则总表不算费
      */
      --MICLASS：普通表=1，总表=2，分表=3
      --STEP1 检查是否总表
      select miclass, mipid into v_miclass, v_mipid from bs_meterinfo where micode = mr.mrccode;
      if v_miclass = 2 then
        --是总表
        v_mrmcode := mr.mrmid; --赋值为总表号
        --step2 判断总表下的分表中是否存在未抄子表 （子表未月初或未抄见）和未算费子表
        select count(*),
               sum(decode(nvl(mrreadok, 'N'), 'Y', 1, 0)),
               sum(decode(nvl(mrifrec, 'N'), 'Y', 1, 0))
          into v_sumnum, v_readnum, v_recnum
          from bs_meterinfo, bs_meterread
         where miid = mrmid(+)
           and mipid = v_mrmcode
           and miclass = '3';
        --如果子表数和大于子表已抄见数和，则存在未抄子表
        if v_sumnum > v_readnum then
          wlog('抄表记录' || mr.mrid || '总分表中包含未抄子表，暂停产生费用');
          raise_application_error(errcode,'总分表中包含未抄子表，暂停产生费用');
        end if;
        --总分表分表已抄见就让算费
        --如果子表数和大于子表已算费数和，则存在未算费子表
        if v_sumnum > v_recnum then
          wlog('抄表记录' || mr.mrid || '收费总表发现子表未计费，暂停产生费用');
          raise_application_error(errcode, '收费总表子表未计费，暂停产生费用');
        end if;
        --总表本月抄表产生账务明细时,抓取本月是否有做故障换表，有的话抓取故障换表余量
        open c_mi_class(v_mrmcode, mr.mrmonth);
        fetch c_mi_class
          into v_mdhis_addsl; --故障换表余量
        if c_mi_class%notfound or c_mi_class%notfound is null then
          v_mdhis_addsl := 0;
        end if;
        close c_mi_class;

        v_pd_addsl := v_mdhis_addsl; --判断水量=故障换表余量

        open c_mr_child(v_mrmcode, mr.mrmonth);
        loop
          fetch c_mr_child
            into mrchild.mrsl,
                 mrchild.mrifrec,
                 mrchild.mrreadok,
                 mrchild.mrcarrysl;
          exit when c_mr_child%notfound or c_mr_child%notfound is null;
          --判断的水量 v_pd_addsl 实际为故障换表水量
          v_pd_addsl := v_pd_addsl - mrchild.mrsl - mrchild.mrcarrysl;
          --总表故障换表水量 =总表故障换表水量 -子表抄表水量 - 子表校验水量
        end loop;
        close c_mr_child;

        if v_pd_addsl < 0 then
          --下述包含三种情况
          --1总表换表时 余量-分表总出账 小于0时不出账   不出账
          --2总表抄见时,如果有故障换表 则抄见水量=抄见水量+换表余量 -分表总出账   出账
          --3 总表故障换表 、分表出账后水量够减， 总表出账
          mr.mrrecsl := mr.mrrecsl + v_mdhis_addsl;
          --step3 判断总分表收费总表水量是否小于子表水量
          --取正常子表水量算截量
          open c_mr_child(v_mrmcode, mr.mrmonth);
          loop
            fetch c_mr_child
              into mrchild.mrsl,
                   mrchild.mrifrec,
                   mrchild.mrreadok,
                   mrchild.mrcarrysl;
            exit when c_mr_child%notfound or c_mr_child%notfound is null;
            --抵消水量
            mr.mrrecsl := mr.mrrecsl - mrchild.mrsl - mrchild.mrcarrysl;
            --总表应收水量 =总表抄表水量 -子表抄表水量 - 子表校验水量
          end loop;
          close c_mr_child;
        else
          --4  总表本月有做故障换表，故障换表余量大于分表总量时，总表再次做抄表，出账水量就等于总表抄见水量
          mr.mrrecsl := mr.mrrecsl;
        end if;
        --如果收费总表水量小于子表水量，暂停产生费用
        if mr.mrrecsl < 0 then
          --如果总表截量小于0，则总表停算费用
          wlog('抄表记录' || mr.mrid || '收费总表水量小于子表水量，暂停产生费用');
          raise_application_error(errcode, '收费总表水量小于子表水量，暂停产生费用');
        end if;
      end if;
    end if;
    -----------------------------------------------------------------------------
    if mr.mrifrec = 'N' and --mr.mrifsubmit = 'Y' and
       mr.mrifhalt = 'N' and
       mi.miifcharge = 'Y' and
       (mil.miifchk <> 'Y' or mil.miifchk is null) and
       v_smtifcharge1 <> 'N'  ----是否计费 1 普表
       then
      --正常算费
      calculate(mr, '1', v_rec_cal);
    elsif mi.miifcharge = 'N' or mr.mrifhalt = 'Y' then
      --计量不计费,将数据记录到费用库
      v_cal_auto_pay := 'N';  --算费时预存自动销账
      calculate(mr, '1', v_rec_cal);
      mr.mrifrec := 'N';
    end if;
    -----------------------------------------------------------------------------
    --更新当前抄表记录
    update bs_meterread
       set mrifrec   = mr.mrifrec,
           mrrecdate = mr.mrrecdate,
           mrsl      = mr.mrsl,
           mrrecsl   = mr.mrrecsl,
           mrrecje01 = mr.mrrecje01,
           mrrecje02 = mr.mrrecje02,
           mrrecje03 = mr.mrrecje03,
           mrrecje04 = mr.mrrecje04
     where current of c_mr;
    close c_mr;
    commit;
    
    if c_mr_pr%isopen then close c_mr_pr; end if;
    if c_mr_pri%isopen then close c_mr_pri; end if;
    if c_mr_child%isopen then close c_mr_child; end if;
    if c_mr%isopen then close c_mr; end if;
    if c_mi%isopen then close c_mi; end if;
    if c_mi_class%isopen then close c_mi_class; end if;
  exception
    when others then
      if c_mr_pr%isopen then close c_mr_pr; end if;
      if c_mr_pri%isopen then close c_mr_pri; end if;
      if c_mr_child%isopen then close c_mr_child; end if;
      if c_mr%isopen then close c_mr; end if;
      if c_mi%isopen then close c_mi; end if;
      if c_mi_class%isopen then close c_mi_class; end if;
      raise_application_error(errcode, sqlerrm);
  end;

  procedure calculate(mr in out bs_meterread%rowtype,p_trans in char, p_rec_cal in varchar2) is
    cursor c_mi(vmiid in bs_meterinfo.miid%type) is select * from bs_meterinfo where miid = vmiid for update;
    cursor c_ci(vciid in bs_custinfo.ciid%type) is select * from bs_custinfo where ciid = vciid for update;
    cursor c_md(vmiid in bs_meterdoc.mdid%type) is select * from bs_meterdoc where mdid = vmiid for update;
    cursor c_pd(vpfid in bs_pricedetail.pdpfid%type) is select * from bs_pricedetail t where pdpfid = vpfid order by pdpscid desc;
    cursor c_misaving(vmicode varchar2) is select * from bs_meterinfo where micode in (select mipid from bs_meterinfo where micode = vmicode) and micode <> vmicode;
    mi    bs_meterinfo%rowtype;
    ci    bs_custinfo%rowtype;
    rl    bs_reclist%rowtype;
    md    bs_meterdoc%rowtype;
    pd    bs_pricedetail%rowtype;
    rdtab rd_table;
    i     number;
    vrd   bs_recdetail%rowtype;
    v_log varchar2(1000);
  begin
    --锁定水表记录
    open c_mi(mr.mrmid);
    fetch c_mi into mi;
    if c_mi%notfound or c_mi%notfound is null then
      wlog('无效的水表编号' || mr.mrmid);
      raise_application_error(errcode, '无效的水表编号' || mr.mrmid);
    end if;
    --锁定水表档案
    open c_md(mr.mrmid);
    fetch c_md into md;
    if c_md%notfound or c_md%notfound is null then
      wlog('无效的水表档案' || mr.mrmid);
      raise_application_error(errcode, '无效的水表编号' || mr.mrmid);
    end if;
    --锁定用户记录
    open c_ci(mi.micode);
    fetch c_ci into ci;
    if c_ci%notfound or c_ci%notfound is null then
      wlog('无效的用户编号' || mi.micode);
      raise_application_error(errcode, '无效的用户编号' || mi.micode);
    end if;
    --判断起码是否改变
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L','Z') then
       --水表起码已经改变
       wlog('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || mr.mrmid);
       raise_application_error(errcode, '此水表编号[' || mr.mrmid ||']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    end if;

    delete bs_reclist_temp where rlmrid = mr.mrid;
    --非计费表执行空过程，不抛异常
    --合收子表
    if md.ifdzsb = 'Y' then
      --如果是倒表 要判断一下指针的问题
      if mr.mrecode > mr.mrscode then
        raise_application_error(errcode, '该用户' || mi.micode || '是倒表用户,起码应大于止码');
      end if;
    elsif mi.miyl1 <> 'Y' and mi.miyl9 is null then
        if mr.mrecode < mr.mrscode then
           raise_application_error(errcode,'该用户' || mi.micode || '不是倒表、等针、超量程用户,起码应小于止码');
        end if;
    end if;
    if true then
      rl.rlid          := trim(to_char(seq_reclist.nextval,'0000000000'));
      rl.rlsmfid       := mr.mrsmfid;
      rl.rlmonth       := mr.mrmonth;
      rl.rldate        := sysdate;
      rl.rlcid         := mr.mrccode;
      rl.rlmid         := mr.mrmid;
      rl.rlsmfid       := mi.mismfid;
      rl.rlchargeper   := mi.micper;
      rl.rlmflag       := ci.ciflag;
      rl.rlcname       := ci.ciname;
      rl.rlcadr        := ci.ciadr;
      rl.rlmadr        := mi.miadr;
      rl.rlcstatus     := ci.cistatus;
      rl.rlmtel        := ci.cimtel;
      rl.rltel         := ci.citel1;
      rl.rlifinv       := 'N'; --ci.ciifinv; --开票标志
      rl.rlmpid        := mi.mipid;
      rl.rlmclass      := mi.miclass;
      rl.rlmflag       := mi.miflag;
      rl.rlmsfid       := mi.mistid;
      rl.rlday         := mr.mrrdate;
      rl.rlbfid        := mr.mrbfid;
      rl.rlscode       := mr.mrscode;
      rl.rlecode       := mr.mrecode;
      rl.rlreadsl      := mr.mrrecsl; --reclist抄见水量 = mr.抄见水量+mr 校验水量
      if p_trans = 'OY' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'Y';
      elsif p_trans = 'ON' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'N';
      else
        rl.rltrans := p_trans;
      end if;
      rl.rlsl           := 0; --应收水费水量，【rlsl = rlreadsl + rladjsl】
      rl.rlje           := 0; --生成帐体后计算,先初始化
      rl.rlscrrlid      := null;
      rl.rlscrrltrans   := null;
      rl.rlscrrlmonth   := null;
      rl.rlpaidje       := 0;
      rl.rlpaidflag     := 'N';
      rl.rlpaidper      := null;
      rl.rlpaiddate     := null;
      rl.rlmrid         := mr.mrid;
      rl.rlmemo         := mr.mrmemo;
      rl.rlpfid         := mi.mipfid;
      rl.rldatetime     := sysdate;
      if mi.mipriflag = 'Y' then
        rl.rlmpid := mi.mipid; --记录合收子表串
      else
        rl.rlmpid := rl.rlmid;
      end if;
      rl.rlpriflag := mi.mipriflag;
      if mr.mrrper is null then
        raise_application_error(errcode, '该用户' || mi.micode || '的抄表员不能为空!');
      end if;
      rl.rlrper      := mr.mrrper;
      rl.rlscode        := mr.mrscode;
      rl.rlecode        := mr.mrecode;
      rl.rlpid          := null; --实收流水（与payment.pid对应）
      rl.rlpbatch       := null; --缴费交易批次（与payment.pbatch对应）
      rl.rlsavingqc     := 0; --期初预存（销帐时产生）
      rl.rlsavingbq     := 0; --本期预存发生（销帐时产生）
      rl.rlsavingqm     := 0; --期末预存（销帐时产生）
      rl.rlreverseflag  := 'N'; --  冲正标志（n为正常，y为冲正）
      rl.rlbadflag      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
      rl.rlscrrlid      := null; --原应收帐流水
      rl.rlscrrltrans   := null; --原应收帐事务
      rl.rlscrrlmonth   := null; --原应收帐月份
      rl.rlscrrldate    := null; --原应收帐日期
      rl.rlifstep       := mr.mrifstep; --是否纳入阶梯,数据来源：追量收费表request_zlsf
      rl.rldatasource   := mr.mrdatasource;--来源(1-手工,5-抄表器,9-手机抄表,K-故障换表,L-周期换表,Z-追量  I-智能表接口，6-视频直读，7-集抄)
      /*
      begin
        select nvl(sum(nvl(rlje, 0) - nvl(rlpaidje, 0)), 0)
          into rl.rlpriorje
          from bs_reclist t
         where t.rlreverseflag = 'Y'
           and t.rlpaidflag = 'N'
           and rlje > 0
           and rlmid = mi.miid;
      exception
        when others then
          rl.rlpriorje := 0; --算费之前欠费
      end;
      */
      if rl.rlpriorje > 0 then
        rl.rlmisaving := 0;
      else
        rl.rlmisaving := ci.misaving; --算费时预存
      end if;
      rl.rlcolumn9       := rl.rlid; --上次应收帐流水
    end if;

    -------------调用算费过程-------------
    open c_pd(mi.mipfid);
    loop
      fetch c_pd into pd;
      exit when c_pd%notfound;
      calpiid(rl, rl.rlreadsl, pd, rdtab);
    end loop;
    close c_pd;
    --------------------------------------

    if mi.miclass = '2' then
      --总分表
      rl.rlreadsl := mr.mrsl + nvl(mr.mrcarrysl, 0); --如果为合收表，则rl的抄见水量为mr抄表水量+mr校验水量
    else
      rl.rlreadsl := mr.mrrecsl + nvl(mr.mrcarrysl, 0); --reclist抄见水量 = mr.抄见水量+mr 校验水量
    end if;

    rl.rlje := 0;
    for i in rdtab.first .. rdtab.last loop
      rl.rlje := rl.rlje + rdtab(i).rdje;
    end loop;

    insert into bs_reclist values rl;

    insrd(rdtab);

    --根据负账标志，把金额水量改成负值
    if p_rec_cal = 'Y' then
      mr.mrsl := 0 - mr.mrsl;
      mr.mrrecje01 := 0 - mr.mrrecje01;
      mr.mrrecje02 := 0 - mr.mrrecje02;
      mr.mrrecje03 := 0 - mr.mrrecje03;
      mr.mrrecje04 := 0 - mr.mrrecje04;

      update bs_reclist
         set rlscode = rlecode,
             rlecode = rlscode,
             rlreadsl = 0 - rlreadsl,
             rlsl = 0 - rlsl,
             rlje = 0 - rlje
       where rlmrid = mr.mrid;

      update bs_recdetail
         set rdsl = 0 - rdsl,
             rdje = 0 - rdje
       where rdid = (select rlid from bs_reclist where rlmrid = mr.mrid);
    end if;

    --预存自动扣款-------------------------
    if v_cal_auto_pay = 'Y' then
      pg_paid.paycust_by_yh(
                 p_yhid => ci.ciid,
                 p_oper => null,
                 p_payway => null,
                 o_log => v_log
                 );
    end if;
    ---------------------------------------
    
    --不重置指针   追量收费工单，补缴收费工单
    if mr.mrifreset = 'N' then
      null;
    else
      update bs_meterinfo
         set mircode     = mr.mrecode,
             mirecdate   = mr.mrrdate,
             mirecsl     = mr.mrsl, --取本期水量（抄量）
             miface      = mr.mrface,
             miyl11      = to_date(rl.rljtsrq, 'yyyy.mm')
       where current of c_mi;
    end if;
    close c_mi;
    close c_md;
    close c_ci;
    --反馈应收水量水费到原始抄表记录
    mr.mrrecsl   := nvl(rl.rlsl, 0);
    mr.mrifrec   := 'Y';
    mr.mrrecdate := rl.rldate;
    if rdtab is not null then
      for i in rdtab.first .. rdtab.last loop
        vrd := rdtab(i);
        case vrd.rdpiid
          when '01' then mr.mrrecje01 := nvl(mr.mrrecje01, 0) + vrd.rdje;
          when '02' then mr.mrrecje02 := nvl(mr.mrrecje02, 0) + vrd.rdje;
          when '03' then mr.mrrecje03 := nvl(mr.mrrecje03, 0) + vrd.rdje;
          when '04' then mr.mrrecje04 := nvl(mr.mrrecje04, 0) + vrd.rdje;
          else null;
        end case;
      end loop;
    end if;
      if c_mi%isopen then close c_mi; end if;
      if c_misaving%isopen then close c_misaving; end if;
      if c_md%isopen then close c_md; end if;
      if c_ci%isopen then close c_ci; end if;
      if c_pd%isopen then close c_pd; end if;
  exception
    when others then
      if c_mi%isopen then close c_mi; end if;
      if c_misaving%isopen then close c_misaving; end if;
      if c_md%isopen then close c_md; end if;
      if c_ci%isopen then close c_ci; end if;
      if c_pd%isopen then close c_pd; end if;
      wlog('其他异常：' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;

  procedure calpiid(p_rl           in out bs_reclist%rowtype,
                  p_sl             in number,
                  pd               in bs_pricedetail%rowtype,
                  rdtab            in out rd_table) is
    rd       bs_recdetail%rowtype;
  begin
    rd.rdid       := p_rl.rlid; --流水号
    rd.rdpiid     := pd.pdpiid; --费用项目
    rd.rdpfid     := pd.pdpfid; --费率
    rd.rdpscid    := pd.pdpscid; --费率明细方案
    rd.rddj     := 0; --单价
    rd.rdsl     := 0; --水量
    rd.rdje     := 0; --金额
    rd.rdmethod   := pd.pdmethod; --计费方法
    if pd.pdmethod = '01' /*or (pd.pdmethod = '02' and p_rl.rlifstep = 'N' )*/ then
    --case pd.pdmethod
    --  when '01' then
        --固定单价  默认方式，与抄量有关  哈尔滨都是dj1
        begin
          rd.rdclass := 0; --阶梯级别
          rd.rddj  := pd.pddj; --单价
          rd.rdsl  := p_sl; --水量
          rd.rdje := 0; --调整金额
          --计算调整
          rd.rdje   := round(rd.rddj * rd.rdsl, 2); --实收金额
          --插入明细包
          if rdtab is null then
            rdtab := rd_table(rd);
          else
            rdtab.extend;
            rdtab(rdtab.last) := rd;
          end if;
          --汇总
          p_rl.rlje := p_rl.rlje + rd.rdje;
          p_rl.rlsl := p_rl.rlsl + (case when rd.rdpiid = '01' then rd.rdsl else 0 end);
        end;
    elsif pd.pdmethod = '02' then
    --  when '02' then
        --阶梯计费  简单模式阶梯水价
        rd.rdsl    := p_sl;
        begin
          --阶梯计费
          calstep(p_rl,
                  rd.rdsl,
                  pd,
                  rdtab);
        end;
      else raise_application_error(errcode, '不支持的计费方法' || pd.pdmethod);
    --end case;
    end if;
  exception
    when others then
      wlog(p_rl.rlid || '计算费用项目费用异常：' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;

  procedure calstep(p_rl       in out bs_reclist%rowtype,
                    p_sl       in number,
                    pd         in bs_pricedetail%rowtype,
                    rdtab      in out rd_table) is
    cursor c_ps is select * from bs_pricestep where pspscid = pd.pdpscid and pspfid = pd.pdpfid and pspiid = pd.pdpiid order by psclass;
    tmpyssl        number;
    tmpsl          number;
    rd             bs_recdetail%rowtype;
    ps             bs_pricestep%rowtype;
    v_total_sl_year number;     --年累计水量
    minfo          bs_meterinfo%rowtype;
    usenum         number;     --计费人口数
    v_date         date;
    v_dateold      date;
    v_rljtmk       varchar2(1);
    bk             bs_bookframe%rowtype;
    v_rlscrrlmonth bs_reclist.rlmonth%type;     --原应收账月份
    v_rlmonth      bs_reclist.rlmonth%type;     --账务月份
    v_rljtsrq      bs_reclist.rljtsrq%type;     --本周期阶梯开始日期 ==> 表册阶梯开始月份           v_date
    v_rljtsrqold   bs_reclist.rljtsrq%type;     --本周期阶梯开始日期                                v_date_old
    v_jgyf         number;
    v_jtny         number;
    v_newmk        char(1);
    v_jtqzny       bs_reclist.rljtsrq%type;
    v_betweenny    number;
  begin
    rd.rdid       := p_rl.rlid;
    rd.rdpiid     := pd.pdpiid;
    rd.rdpfid     := pd.pdpfid;
    rd.rdpscid    := pd.pdpscid;
    rd.rdmethod   := pd.pdmethod;
    tmpyssl := p_sl; --阶梯累减应收水量余额
    tmpsl   := p_sl; --阶梯累减实收水量余额
    v_newmk := 'N';
    --取上次算费月份，以及阶梯开始月份
   select nvl(max(rlscrrlmonth), 'a'), nvl(max(rljtsrq), 'a'),nvl(max(rlmonth),'2015.12')
      into v_rlscrrlmonth, v_rljtsrqold,v_rlmonth        --rlscrrlmonth  原应收帐月份   rljtsrq  本周期阶梯开始日期    rlmonth  帐务月份
      from bs_reclist
     where rlmid = p_rl.rlmid
       and rlreverseflag = 'N';
    --第一次算费比进入阶梯

    select * into bk from bs_bookframe where bfid = p_rl.rlbfid;
    --判断数据是否满足收取阶梯的条件
    select mi.* into minfo from bs_meterinfo mi where mi.miid = p_rl.rlmid;
    --取合收表人口最大表的用户数
    select nvl(max(miusenum),0)
      into usenum
      from bs_meterinfo
     where mipid = minfo.mipid;
    if usenum <= 5 then
      usenum := 5;
    end if;
    bk.bfjtsny := nvl(bk.bfjtsny, '01');              --bfjtsny  阶梯开始月
    bk.bfjtsny := to_char(to_number(bk.bfjtsny), 'FM00');
    if substr(p_rl.rlmonth, 6, 2) >= bk.bfjtsny then
      v_rljtsrq := substr(p_rl.rlmonth, 1, 4) || '.' || bk.bfjtsny;
    else
      v_rljtsrq := substr(p_rl.rlmonth, 1, 4) - 1 || '.' || bk.bfjtsny;
    end if;
    --新阶梯起止
    v_date := add_months(to_date(v_rljtsrq, 'yyyy.mm'), 12);
    if v_rljtsrqold <> 'a' then
      --旧阶梯起止
      v_dateold := add_months(to_date(v_rljtsrqold, 'yyyy.mm'), 12);
    else
      v_dateold := v_date;
    end if;
    --旧阶梯起止不等于新阶梯起止
    if v_dateold <> v_date then

      v_betweenny := months_between(v_date, v_dateold);
      if substr(v_rljtsrq, 1, 4) <> to_char(v_dateold, 'yyyy') then
        if v_rljtsrq < to_char(v_dateold, 'yyyy.mm') then
          if v_rljtsrq = p_rl.rlmonth then
            p_rl.rljtmk  := 'Y';          --rljtmk  不记阶梯注记
            p_rl.rljtsrq := v_rljtsrq;
          else
            p_rl.rljtsrq := v_rljtsrqold;
            v_jtqzny     := v_rljtsrqold;
          end if;
        else
          p_rl.rljtmk  := 'Y';
          p_rl.rljtsrq := v_rljtsrq;
        end if;
      else
        if mod(v_betweenny, 12) = 0 then
          --跨年的情况
          if v_betweenny / 12 > 1 then
            p_rl.rljtmk  := 'Y';
            p_rl.rljtsrq := v_rljtsrq;
          else
            p_rl.rljtsrq := v_rljtsrq;
            v_jtqzny     := v_rljtsrqold;
          end if;
        elsif v_betweenny < 12 then
          if p_rl.rlmonth = v_rljtsrq then
            p_rl.rljtsrq := v_rljtsrq;
            v_jtqzny     := v_rljtsrqold;
          elsif p_rl.rlmonth < v_rljtsrq then
            p_rl.rljtsrq := v_rljtsrqold;
            v_jtqzny     := v_rljtsrqold;
          else
            p_rl.rljtsrq := v_rljtsrq;
            v_jtqzny     := v_rljtsrqold;
          end if;
        elsif v_betweenny > 12 then
          if p_rl.rlmonth = v_rljtsrq then
            if substr(p_rl.rlmonth, 1, 4) = substr(v_rlscrrlmonth, 1, 4) then
              p_rl.rljtsrq := v_rljtsrq;
              p_rl.rljtmk  := 'Y';
            else
              p_rl.rljtsrq := v_rljtsrq;
              v_newmk      := 'Y';
              v_jtqzny     := v_rljtsrqold;
            end if;
          else
            if p_rl.rlmonth = v_rljtsrqold then
              p_rl.rljtsrq := to_char(v_dateold, 'yyyy.mm');
              v_jtqzny     := v_rljtsrqold;
            else
              p_rl.rljtsrq := v_rljtsrqold;
              v_jtqzny     := v_rljtsrqold;
            end if;
          end if;
        end if;
      end if;
    else
      if p_rl.rlmonth = v_rljtsrq then
        v_jtqzny := substr(p_rl.rlmonth, 1, 4) - 1 || '.' || bk.bfjtsny;
      else
        v_jtqzny := v_rljtsrq;
      end if;
      p_rl.rljtsrq := v_rljtsrq;

    end if;

    -- 第一次算费不进入阶梯
    -- 2016年1月起（含一月）首次抄表不计入阶梯

    if p_rl.rljtmk = 'Y' or p_rl.rltrans in('14', '21') or v_rlscrrlmonth = 'a' or v_rlmonth <='2015.12' or p_rl.rlifstep = 'N'
      then
      v_rljtmk := 'Y';
    else
      v_rljtmk := 'N';
    end if;

    --没有跨阶梯年月程序处理
    if v_dateold >= to_date(p_rl.rlmonth, 'yyyy.mm') or v_rljtmk = 'Y' then
       select nvl(sum(rdsl), 0)
        into p_rl.rlcolumn12
        from bs_reclist, bs_recdetail,bs_meterinfo
       where rlid = rdid
         and rlmid = miid
         and nvl(rljtmk, 'N') = 'N'
         and (rlifstep <> 'N' or rlifstep is null)
         and rlscrrltrans not in ('14', '21')
         and rdpmdcolumn3 = substr(v_jtqzny, 1, 4)
         and rdpiid = '01'
         and rdmethod = '02'
         and rlscrrlmonth <= p_rl.rlmonth
         and micode = minfo.micode;
      rd.rdpmdcolumn3 := substr(v_jtqzny, 1, 4);
      v_total_sl_year := case when p_rl.rlcolumn12<0 then 0 else to_number(nvl(p_rl.rlcolumn12, 0)) end + p_sl;  --年累计水量

      open c_ps;
      fetch c_ps
        into ps;
      if c_ps%notfound or c_ps%notfound is null then
        raise_application_error(errcode, '无效的阶梯计费设置');
      end if;
      while c_ps%found and (tmpyssl >= 0 or tmpsl >= 0) loop
        --居民水费阶梯数量跟户籍人数有关
        if ps.psscode = 0 then
          ps.psscode := 0;
        else
          ps.psscode := round((ps.psscode + 30 * (usenum - 5)) );
        end if;
        ps.psecode := round((ps.psecode + 30 * (usenum - 5)) );
        rd.rdclass := ps.psclass;
        rd.rddj  := ps.psprice;
        rd.rdsl := case when v_rljtmk = 'Y' then tmpyssl else
                        case
                          when v_total_sl_year >= ps.psscode and v_total_sl_year <= ps.psecode then
                            v_total_sl_year - tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)),ps.psscode)
                          when v_total_sl_year >= ps.psecode then
                            tools.getmax(0, tools.getmin(ps.psecode - to_number(nvl(p_rl.rlcolumn12, 0)),ps.psecode - ps.psscode))
                          else
                            0
                        end
                    end
                    ;
        rd.rdje  := rd.rddj * rd.rdsl;
        if v_rljtmk <> 'Y' then
          rd.rdpmdcolumn1 := ps.psecode - ps.psscode;
          if v_total_sl_year >= ps.psscode and v_total_sl_year <= ps.psecode then
            rd.rdpmdcolumn2 := v_total_sl_year - ps.psscode;
          elsif v_total_sl_year > ps.psecode then
            rd.rdpmdcolumn2 := ps.psecode - ps.psscode;
          else
            rd.rdpmdcolumn2 := 0;
          end if;
        end if;

        if rd.rdsl > 0 then
          if rdtab is null then
            rdtab := rd_table(rd);
          else
            rdtab.extend;
            rdtab(rdtab.last) := rd;
          end if;
        end if;
        --汇总
        p_rl.rlje := p_rl.rlje + rd.rdje;
        p_rl.rlsl := p_rl.rlsl + (case
                       when rd.rdpiid = '01' then
                        rd.rdsl
                       else
                        0
                     end);
        tmpyssl := tools.getmax(tmpyssl - rd.rdsl, 0);
        tmpsl   := tools.getmax(tmpsl - rd.rdsl, 0);
        exit when tmpyssl <= 0 and tmpsl <= 0;
        fetch c_ps into ps;
      end loop;
      close c_ps;
    else
      --跨年，需要按用水月份比例拆分
      v_jgyf := months_between(to_date(p_rl.rlmonth, 'yyyy.mm'), v_dateold);
      v_jtny := months_between(to_date(p_rl.rlmonth, 'yyyy.mm'),
                               to_date(v_rlscrrlmonth, 'yyyy.mm'));
      if v_jgyf / v_jtny  > 1 then
        v_jtny := v_jgyf;
      end if;
      if v_jgyf > 12 then
        tmpyssl  := p_sl;
        tmpsl    := p_sl;
        v_rljtmk := 'Y';
      else
        tmpyssl := p_sl - round(p_sl * v_jgyf / v_jtny); --阶梯累减应收水量余额
        tmpsl   := p_sl - round(p_sl * v_jgyf / v_jtny); --阶梯累减实收水量余额
      end if;
      rd.rdpscid := -1;
      if v_rljtmk = 'Y' then
        p_rl.rlcolumn12 := 0;
      else
        select nvl(sum(rdsl), 0)
          into p_rl.rlcolumn12
          from bs_reclist, bs_recdetail
         where rlid = rdid
           and nvl(rljtmk, 'N') = 'N'
           and (rlifstep <> 'N' or rlifstep is null)
           and rlscrrltrans not in ('14', '21')
           and rdpmdcolumn3 = substr(v_rljtsrqold, 1, 4)
           and rdpiid = '01'
           and rdmethod = '02'
           and rlscrrlmonth <= p_rl.rlmonth
           and rlmid = minfo.micode;
      end if;
      rd.rdpmdcolumn3 := substr(v_rljtsrqold, 1, 4);
      v_total_sl_year := tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), 0) + (p_sl - round(p_sl * v_jgyf / v_jtny));
      --计算去年的阶梯
      open c_ps;
      fetch c_ps
        into ps;
      if c_ps%notfound or c_ps%notfound is null then
        raise_application_error(errcode, '无效的阶梯计费设置');
      end if;
      while c_ps%found and (tmpyssl >= 0 or tmpsl >= 0) loop
        --居民水费阶梯数量跟户籍人数有关
        if ps.psscode = 0 then
          ps.psscode := 0;
        else
          ps.psscode := round((ps.psscode + 30 * (usenum - 5)) );
        end if;
        ps.psecode := round((ps.psecode + 30 * (usenum - 5)) );

        rd.rdclass := ps.psclass;
        rd.rddj  := ps.psprice;
        rd.rdsl := case when v_rljtmk = 'Y' then tmpyssl else
                        case
                          when v_total_sl_year >= ps.psscode and v_total_sl_year <= ps.psecode then
                            v_total_sl_year - tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), ps.psscode)
                          when v_total_sl_year > ps.psecode then
                            tools.getmax(0, tools.getmin(ps.psecode - to_number(nvl(p_rl.rlcolumn12, 0)), ps.psecode - ps.psscode))
                          else
                            0
                        end
                     end
                     ;
        rd.rdje  := rd.rddj * rd.rdsl;
        rd.rddj    := ps.psprice;
        if v_rljtmk <> 'Y' then
          rd.rdpmdcolumn1 := ps.psecode - ps.psscode;
          if v_total_sl_year >= ps.psscode and v_total_sl_year <= ps.psecode then
            rd.rdpmdcolumn2 := v_total_sl_year - ps.psscode;
          elsif v_total_sl_year > ps.psecode then
            rd.rdpmdcolumn2 := ps.psecode - ps.psscode;
          else
            rd.rdpmdcolumn2 := 0;
          end if;
        end if;

        if rd.rdsl > 0 then
          if rdtab is null then
            rdtab := rd_table(rd);
          else
            rdtab.extend;
            rdtab(rdtab.last) := rd;
          end if;
        end if;
        --汇总
        p_rl.rlje := p_rl.rlje + rd.rdje;
        p_rl.rlsl := p_rl.rlsl + (case when rd.rdpiid = '01'then rd.rdsl else 0 end);
        tmpyssl := tools.getmax(tmpyssl - rd.rdsl, 0);
        tmpsl   := tools.getmax(tmpsl - rd.rdsl, 0);
        exit when tmpyssl <= 0 and tmpsl <= 0;
        fetch c_ps into ps;
      end loop;
      close c_ps;

      if v_jgyf <= 12 then
        if v_newmk = 'Y' then
          v_rljtmk := 'Y';
        end if;
        rd.rdpscid := pd.pdpscid;
        tmpyssl    := round(p_sl * (v_jgyf / v_jtny)); --阶梯累减应收水量余额
        tmpsl      := round(p_sl * (v_jgyf / v_jtny)); --阶梯累减实收水量余额
        select nvl(sum(rdsl), 0)
          into p_rl.rlcolumn12
          from bs_reclist, bs_recdetail
         where rlid = rdid
           and nvl(rljtmk, 'N') = 'N'
           and (rlifstep <> 'N' or rlifstep is null)
           and rlscrrltrans not in ('14', '21')
           and rdpmdcolumn3 = substr(p_rl.rlmonth, 1, 4)
           and rdpiid = '01'
           and rdmethod = '02'
           and rlscrrlmonth <= p_rl.rlmonth
           and rlmid = minfo.micode;
        rd.rdpmdcolumn3 := substr(p_rl.rlmonth, 1, 4);
        v_total_sl_year := tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), 0) + (round(p_sl * v_jgyf / v_jtny));

        --计算去年的阶梯
          open c_ps;
          fetch c_ps
            into ps;
          if c_ps%notfound or c_ps%notfound is null then
            raise_application_error(errcode, '无效的阶梯计费设置');
          end if;
          while c_ps%found and (tmpyssl >= 0 or tmpsl >= 0) loop
            --居民水费阶梯数量跟户籍人数有关
            if ps.psscode = 0 then
              ps.psscode := 0;
            else
              ps.psscode := round((ps.psscode + 30 * (usenum - 5)));
            end if;
            ps.psecode := round((ps.psecode + 30 * (usenum - 5)));
            rd.rdclass := ps.psclass;
            rd.rddj    := ps.psprice;
            rd.rdsl := case when v_rljtmk = 'Y' then tmpsl else
                          case
                            when v_total_sl_year >= ps.psscode and v_total_sl_year <= ps.psecode then
                              v_total_sl_year - tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), ps.psscode)
                            when v_total_sl_year > ps.psecode then
                              tools.getmax(0,tools.getmin(ps.psecode -  to_number(nvl(p_rl.rlcolumn12, 0)), ps.psecode - ps.psscode))
                            else
                              0
                          end
                       end
                       ;
            rd.rdje    := rd.rddj * rd.rdsl;
            if v_rljtmk <> 'Y' then
              rd.rdpmdcolumn1 := ps.psecode - ps.psscode;
              if v_total_sl_year >= ps.psscode and v_total_sl_year <= ps.psecode then
                rd.rdpmdcolumn2 := v_total_sl_year - ps.psscode;
              elsif v_total_sl_year > ps.psecode then
                rd.rdpmdcolumn2 := ps.psecode - ps.psscode;
              else
                rd.rdpmdcolumn2 := 0;
              end if;
            end if;

            if rd.rdsl > 0 then
              if rdtab is null then
                rdtab := rd_table(rd);
              else
                rdtab.extend;
                rdtab(rdtab.last) := rd;
              end if;
            end if;
            --汇总
            p_rl.rlje := p_rl.rlje + rd.rdje;
            p_rl.rlsl := p_rl.rlsl + (case
                           when rd.rdpiid = '01' then
                            rd.rdsl
                           else
                            0
                         end);
            --累减后带入下一行游标
            tmpyssl := tools.getmax(tmpyssl - rd.rdsl, 0);
            tmpsl   := tools.getmax(tmpsl - rd.rdsl, 0);
            exit when tmpyssl <= 0 and tmpsl <= 0;
            fetch c_ps into ps;
          end loop;
          close c_ps;
      end if;
    end if;
    if v_rljtmk = 'N' then
      p_rl.rlcolumn12 := v_total_sl_year;
    else p_rl.rljtmk := 'Y';
    end if;
    if c_ps%isopen then close c_ps; end if;
  exception
    when others then
      if c_ps%isopen then close c_ps; end if;
      wlog(p_rl.rlmid || '计算阶梯水量费用异常：' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;

  procedure insrd(rd in rd_table) is
    vrd      bs_recdetail%rowtype;
    i        number;
    v_rdpiid varchar2(10);
  begin
    for i in rd.first .. rd.last loop
      vrd      := rd(i);
      v_rdpiid := vrd.rdpiid;

      insert into bs_recdetail values vrd;
      
    end loop;
  exception
    when others then
      raise_application_error(errcode, sqlerrm);
  end;

  --应收冲正_按工单
  procedure yscz_gd(p_reno   in varchar2,--工单流水号
                 p_oper    in varchar2,--完结人
                 p_memo   in varchar2 --备注
                 ) is
    o_rerid        varchar2(20);
    r_yscz         request_yscz%rowtype;
    --o_pid_reverse  bs_reclist.rlpid%type;
    rlcr bs_reclist%rowtype;
    v_oldrecsl number;
  begin
    select * into r_yscz from request_yscz where reno = p_reno;

    if r_yscz.reno is null then raise_application_error(errcode, '工单不存在'); end if;
    if r_yscz.reshbz <> 'Y' then raise_application_error(errcode, '工单未审核'); end if;
    if r_yscz.rewcbz = 'Y' then raise_application_error(errcode, '工单已冲正'); end if;

    for rlde in (select * from bs_reclist t where t.rlid in
                     (select regexp_substr(r_yscz.rerlid, '[^,]+', 1, level) pid from dual connect by level <= length(r_yscz.rerlid) - length(replace(r_yscz.rerlid, ',', '')) + 1)
                 order by rlday desc) loop
      if rlde.rlid is null then
        wlog('无效的应收账流水号：'|| r_yscz.rerlid);
        raise_application_error(errcode, '无效的应收账流水号：'||r_yscz.rerlid);
      end if;
      if rlde.rlreverseflag <> 'N' then
        raise_application_error(errcode, '应收' || rlde.rlid || '已经冲正！');
      end if;
      if rlde.rlpaidflag <> 'N' then
        raise_application_error(errcode,'应收' || rlde.rlid || '不是欠费状态，状态标志为' ||rlde.rlpaidflag);
      end if;
      if rlde.rlje < 0 then
        raise_application_error(errcode,'应收' || rlde.rlid || '应收帐金额应该大于等于零！');
      end if;
      /*
      if rlde.rlpaidje > 0 then
        raise_application_error(errcode, '应收' || rlde.rlid || '已部分销帐不能冲正');
      end if;
      */

      rlcr := rlde;
      rlcr.rlcolumn9  := rlcr.rlid; --上次应收帐流水
      rlcr.rlid       := trim(to_char(seq_reclist.nextval,'0000000000'));
      rlcr.rlmonth    := to_char(sysdate, 'yyyy.mm');
      rlcr.rldate     := sysdate;
      rlcr.rldatetime := sysdate;
      rlcr.rlpaidflag := 'N';
      rlcr.rlsl       := 0 - rlcr.rlsl;
      rlcr.rlje       := 0 - rlcr.rlje;
      rlcr.rlpaidje   := 0 - rlcr.rlpaidje;
      rlcr.rlsavingqc := 0 - rlcr.rlsavingqc;
      rlcr.rlsavingbq := 0 - rlcr.rlsavingbq;
      rlcr.rlsavingqm := 0 - rlcr.rlsavingqm;
      rlcr.rlmemo        := p_memo;
      rlcr.rlreverseflag := 'Y';
      --插入负应收记录
      insert into bs_reclist values rlcr;

      rlde.rlpaidflag    := rlcr.rlpaidflag;
      rlde.rlpaiddate    := rlcr.rldate;
      rlde.rlpaidper     := p_oper;
      rlde.rlpaidje      := rlde.rlpaidje + rlcr.rlje;
      rlde.rlreverseflag := rlcr.rlreverseflag;
      --更新标记源帐
      update bs_reclist
         set rlpaidflag    = rlcr.rlpaidflag,
             rlpaiddate    = rlcr.rldate,
             rlpaidper     = p_oper,
             rlreverseflag = rlde.rlreverseflag
       where rlid = rlde.rlid;

      insert into bs_recdetail(rdid, rdpiid, rdpfid, rdpscid, rdclass, rddj, rdsl, rdje, rdmethod, rdmemo, rdpmdcolumn1, rdpmdcolumn2, rdpmdcolumn3)
      select rlcr.rlid,
             rdpiid,
             rdpfid,
             rdpscid,
             rdclass,
             rddj,
             0 - rdsl,
             0 - rdje,
             rdmethod,
             rdmemo,
             rdpmdcolumn1,
             rdpmdcolumn2,
             rdpmdcolumn3
      from bs_recdetail
      where rdid = rlde.rlid;

      v_oldrecsl := null;
      begin
        select mr.mrsl into v_oldrecsl from bs_meterread mr where mr.mrmid = rlde.rlmid and mr.mrecode = rlde.rlscode;
      exception
        when no_data_found then v_oldrecsl := null;
      end;

      if v_oldrecsl is null then
        begin
          select mrh.mrsl into v_oldrecsl from bs_meterread_his mrh where mrh.mrmid = rlde.rlmid and mrh.mrecode = rlde.rlscode;
        exception
          when no_data_found then v_oldrecsl := null;
        end;
      end if;

      --rercodeflag      是否重置抄表指针
      if r_yscz.rercodeflag = 'Y' then
        update bs_meterinfo
           set mircode   = rlde.rlscode,
               mirecdate = rlde.rlday, --本期抄见日期 =应收账抄表日期
               mirecsl   = v_oldrecsl
               --mirecsl   = rlde.rlreadsl
         where miid = rlde.rlmid;

        if to_char(rlde.rlday,'yyyymm') = to_char(sysdate,'yyyymm') then
          update bs_meterread
             set mrifsubmit = 'N',
                 mrifrec    = 'N',
                 mrifyscz   = 'Y',
                 mrreadok   = 'N',  --抄见标志
                 mrrecje01  = null,
                 mrrecje02  = null,
                 mrrecje03  = null,
                 mrrecje04  = null,
                 mrscode    = rlde.rlscode, --上期抄见
                 mrecode    = null , --本期抄见
                 mrsl       = null  --本期水量
           where mrid = rlde.rlmrid;
         end if;
      else
        update bs_meterinfo
           set --mirecsl = 0
               mirecsl = v_oldrecsl
         where miid = rlde.rlmid;

        if to_char(rlde.rlday,'yyyymm') = to_char(sysdate,'yyyymm') then
          update bs_meterread
             set mrifsubmit = 'N',
                 mrifrec    = 'N',
                 mrifyscz   = 'Y',
                 mrreadok   = 'N',  --抄见标志
                 mrrecje01  = null,
                 mrrecje02  = null,
                 mrrecje03  = null,
                 mrrecje04  = null
           where mrid       = rlde.rlmrid;
         end if;
      end if;
      commit;
    end loop;
   --更新工单状态
    update request_yscz
       set rewcbz = 'Y',
           rerlid_rev = o_rerid,
           modifydate = sysdate,
           modifyuserid = p_oper,
           modifyusername = (select user_name from sys_user where user_id = p_oper),
           remark = p_memo
     where reno = p_reno;
    --更改 用户 有审核状态的工单 状态
    update bs_custinfo set reflag = 'N' where ciid = r_yscz.rlcid;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --应收冲正_按应收账流水
  procedure yscz_rl(p_rlid   in varchar2, --应收账流水号
                 p_oper    in varchar2,    --完结人
                 p_memo   in varchar2,    --备注
                 o_rlcrid out varchar2    --返回负应收账流水号
                 ) is
    cursor c_rl is select * from bs_reclist t where t.rlid = p_rlid;
    rlde bs_reclist%rowtype;
    rlcr bs_reclist%rowtype;
  begin
    open c_rl;
    fetch c_rl into rlde;

    if c_rl%notfound or c_rl%notfound is null then
      wlog('无效的应收账流水号：'|| p_rlid);
      raise_application_error(errcode, '无效的应收账流水号：'||p_rlid);
    end if;
    if rlde.rlreverseflag <> 'N' then
      raise_application_error(errcode, '应收' || rlde.rlid || '已经冲正！');
    end if;
    if rlde.rlpaidflag <> 'N' then
      raise_application_error(errcode,'应收' || rlde.rlid || '不是欠费状态，状态标志为' ||rlde.rlpaidflag);
    end if;
    if rlde.rlje < 0 then
      raise_application_error(errcode,'应收' || rlde.rlid || '应收帐金额应该大于等于零！');
    end if;
    /*
    if rlde.rlpaidje > 0 then
      raise_application_error(errcode, '应收' || rlde.rlid || '已部分销帐不能冲正');
    end if;
    */
    rlcr := rlde;
    rlcr.rlcolumn9  := rlcr.rlid; --上次应收帐流水
    rlcr.rlid       := trim(to_char(seq_reclist.nextval,'0000000000'));
    rlcr.rlmonth    := to_char(sysdate, 'yyyy.mm');
    rlcr.rldate     := trunc(sysdate);
    rlcr.rldatetime := sysdate;
    rlcr.rlpaidflag := 'N';
    rlcr.rlsl       := 0 - rlcr.rlsl;
    rlcr.rlje       := 0 - rlcr.rlje;
    rlcr.rlpaidje   := 0 - rlcr.rlpaidje;
    rlcr.rlsavingqc := 0 - rlcr.rlsavingqc;
    rlcr.rlsavingbq := 0 - rlcr.rlsavingbq;
    rlcr.rlsavingqm := 0 - rlcr.rlsavingqm;
    rlcr.rlmemo        := p_memo;
    rlcr.rlreverseflag := 'Y';
    o_rlcrid := rlcr.rlid;
    --插入负应收记录
    insert into bs_reclist values rlcr;

    rlde.rlpaidflag    := rlcr.rlpaidflag;
    rlde.rlpaiddate    := rlcr.rldate;
    rlde.rlpaidper     := p_oper;
    rlde.rlpaidje      := rlde.rlpaidje + rlcr.rlje;
    rlde.rlreverseflag := rlcr.rlreverseflag;
    --更新标记源帐
    update bs_reclist
       set rlpaidflag    = rlcr.rlpaidflag,
           rlpaiddate    = rlcr.rldate,
           rlpaidper     = p_oper,
           rlreverseflag = rlde.rlreverseflag
     where rlid = rlde.rlid;

    insert into bs_recdetail(rdid, rdpiid, rdpfid, rdpscid, rdclass, rddj, rdsl, rdje, rdmethod, rdmemo, rdpmdcolumn1, rdpmdcolumn2, rdpmdcolumn3)
    select rlcr.rlid,
           rdpiid,
           rdpfid,
           rdpscid,
           rdclass,
           rddj,
           0 - rdsl,
           0 - rdje,
           rdmethod,
           rdmemo,
           rdpmdcolumn1,
           rdpmdcolumn2,
           rdpmdcolumn3
    from bs_recdetail
    where rdid = rlde.rlid;

    update bs_meterinfo
       set mirecsl = 0
     where miid = rlcr.rlmid;

    update bs_meterread
       set mrifsubmit = 'N',
           mrifrec    = 'N',
           mrifyscz   = 'Y',
           mrreadok   = 'N',  --抄见标志
           mrrecje01  = null,
           mrrecje02  = null,
           mrrecje03  = null,
           mrrecje04  = null
     where mrid       = rlcr.rlmrid;

    commit;
    close c_rl;
  exception
    when others then
      if c_rl%isopen then close c_rl; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

begin
  select to_number(spvalue) into v_cal_min_sl from sys_para where spid='1092';   --最低算费水量
  select spvalue into v_cal_zbjl from sys_para where spid='1069';                --总表截量
  select spvalue into v_cal_auto_pay from sys_para where spid='0006';            --算费时预存自动销账
  select smtifcharge into v_smtifcharge1 from sysmetertype where smtid='1';      --是否计费 1 普表
end;
/

