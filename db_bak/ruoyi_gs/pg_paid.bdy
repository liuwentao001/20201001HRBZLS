create or replace package body pg_paid is
  err_str varchar2(1000);
  --缴费入口
  /*
  p_yhid          用户编码
  p_arstr          欠费流水号，多个流水号用逗号分隔，例如：0000012726,70105341
  p_oper          销帐员，柜台缴费时销帐人员与收款员统一
  p_payway        付款方式(XJ-现金 ZP-支票 MZ-抹账 DC-倒存)
  p_payment       实收，即为（付款-找零），付款与找零在前台计算和校验
  p_pid           返回交易流水号*/
  procedure poscustforys(p_yhid     in varchar2,
             p_arstr    in varchar2,
             p_oper     in varchar2,
             p_payway   in varchar2,
             p_payment  in varchar2,
             p_pid      out varchar2) is
  v_remainafter number;
  v_payment number;
  v_position varchar(32);
  begin
    v_payment := to_number(p_payment);
    if p_oper is not null then
      select dept_id into v_position from sys_user where to_char(user_id) = p_oper;
    end if;

    if p_arstr is null then
      --单缴预存
      precust(p_yhid        => p_yhid,
              p_position    => v_position,
              p_oper        => p_oper,
              p_payway      => p_payway,
              p_payment     => v_payment,
              p_memo        => null,
              p_pid         => p_pid,
              o_remainafter => v_remainafter);
    else
      paycust(p_yhid,
             p_arstr,
             v_position,
             'P',  --缴费事务   柜台缴费
             p_oper,
             p_payway,
             v_payment,
             null,
             p_pid,
             v_remainafter);
    end if;
    commit;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --一水表多应收销帐
  procedure paycust(p_yhid     in varchar2,
             p_arstr    in varchar2,
             p_position in varchar2,
             p_trans    in varchar2,
             p_oper     in varchar2,
             p_payway   in varchar2,
             p_payment  in number,
             p_pid_source in varchar2,
             p_pid      out varchar2,
             o_remainafter out number) is
    cursor c_ci(vciid varchar2) is
        select * from bs_custinfo where ciid = vciid for update nowait; --若被锁直接抛出异常
    cursor c_mi(vmiid varchar2) is
        select * from bs_meterinfo where micode = vmiid for update nowait; --若被锁直接抛出异常
    p bs_payment%rowtype;
    mi bs_meterinfo%rowtype;
    ci bs_custinfo%rowtype;
    v_pdspje number;  --销账金额
    v_pdwyj number;   --违约金
    v_pdsxf number;   --手续费
  begin
    --1、实参校验、必要变量准备
    --------------------------------------------------------------------------
      --取用户信息
      open c_ci(p_yhid);
      fetch c_ci into ci;
      if c_ci%notfound or c_ci%notfound is null then
        raise_application_error(errcode,'用户编码【' || p_yhid || '】不存在！');
      end if;
      --取水表信息
      open c_mi(ci.ciid);
      fetch c_mi into mi;
      if c_mi%notfound or c_mi%notfound is null then
        raise_application_error(errcode, '这个用户编码没对应水表！' || p_yhid);
      end if;
    --2、记录实收
      select trim(to_char(seq_paidment.nextval, '0000000000'))
        into p_pid
        from dual;
      p.pid := p_pid;             --流水号
      p.pcid := ci.ciid;          --用户编号
      p.pmid := mi.miid;           --水表编号
      p.pdate := trunc(sysdate);  --帐务日期
      p.pdatetime := sysdate;     --发生日期
      p.pmonth := to_char(sysdate,'yyyy-mm');        --缴费月份
      p.pposition := p_position;  --缴费机构
      p.ptrans := p_trans;        --缴费事务
      p.ppayee := p_oper;         --销帐人员
      p.psavingqc := nvl(ci.misaving,0);        --期初预存余额
      p.psavingbq := p_payment;                 --本期发生预存金额
      p.psavingqm := p.psavingqc + p.psavingbq; --期末预存余额
      p.ppayment := p_payment;                  --付款金额
      p.ppayway := p_payway;       --付款方式(xj-现金 zp-支票 mz-抹账 dc-倒存)
      p.pbseqno := null;           --缴费机构流水(银行实时收费交易流水)
      p.pbdate := null;            --银行日期(银行缴费账务日期)
      p.pchkdate := null;          --扎帐日期（收费员结账后回写审核日期）
      select trim(to_char(seq_paidbatch.nextval,'0000000000')) into p.pbatch from dual; --缴费交易批次
      p.pmemo := null;        --备注
      p.preverseflag := 'N';  --冲正标志
      if p_pid_source is null then
        p.pscrid    := p.pid;     --原实收帐流水（应收冲实产生的负帐时payment.pscrid不空，且为被冲实收帐流水号，用于关联冲与被冲的关联，其它情况payment.pscrid为空）
        p.pscrtrans := p.ptrans;  --原实收缴费事务（实收冲正产生的负帐时payment.pscrtrans不空，且为被冲应收帐事务，用于关联冲与被冲的关联，其它情况payment.pscrtrans为空）
        p.pscrmonth := p.pmonth; --原实收收月份（实收冲正（因冲帐产生负实收帐）：新生成负实收帐的原实收帐月份与被冲正实由帐月份相同（如：a用户2011年8月缴一笔水费，自来水公司在2011年9月发现这笔有问题，需要做实收冲正，做实收冲正时会产生一笔2011年9月负实帐，2011年9月负帐原实收帐月份为2011年8月）
        p.pscrdate  := p.pdate;  --原实收日期
      else
        select pid, ptrans, pmonth, pdate
          into p.pscrid, p.pscrtrans, p.pscrmonth, p.pscrdate
          from bs_payment
         where pid = p_pid_source;
      end if;
    --------------------------------------------------------------------------
    --4、销帐核心调用（应收记录处理、反馈实收数据）
    payzwarcore(p.pid,
                p.pbatch,
                p_payment,
                ci.misaving,
                p_oper,
                p.pdate,
                p.pmonth,
                p_arstr,
                v_pdspje,
                v_pdwyj,
                v_pdsxf);
    --------------------------------------------------------------------------
    --5、重算预存发生、预存期末、更新用户预存余额
    p.psavingqm := p.psavingqc + p_payment - v_pdspje - v_pdwyj - v_pdsxf;
    p.psavingbq := p.psavingqm - p.psavingqc;
    update bs_custinfo set misaving = p.psavingqm where ciid = p_yhid;
    --6、返回预存余额
    o_remainafter := p.psavingqm;

    insert into bs_payment values p;

    close c_ci;
    close c_mi;
  exception
    when others then
      if c_ci%isopen then close c_ci; end if;
      if c_mi%isopen then close c_mi; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --实收销帐处理核心
  procedure payzwarcore(p_pid          in varchar2,
                        p_batch        in varchar2,
                        p_payment      in number,
                        p_remainbefore in number,
                        p_oper         in varchar,
                        p_paiddate     in date,
                        p_paidmonth    in varchar2,
                        p_arstr        in varchar2,
                        o_sum_arje     out number,
                        o_sum_arznj    out number,
                        o_sum_arsxf    out number) is
    rl bs_reclist%rowtype;
    cursor c_rl is
      select *
      from bs_reclist
      where rlpaidflag = 'N' and
        rlreverseflag = 'N' and
        rlid in (select regexp_substr(p_arstr, '[^,]+', 1, level) column_value from dual
                        connect by level <= length(p_arstr) - length(replace(p_arstr, ',', '')) + 1);
    sumrlpaidje number(13, 3) := 0; --累计实收金额（应收金额+实收违约金+实收其他非系统费项123）
    p_remaind   number(13, 3);      --期初预存累减器
    v_rlid varchar2(20);
  begin
    --期初预存累减器初始化
    p_remaind := p_remainbefore;
    --返回值初始化，若销帐包非空但无游标此值返回
    o_sum_arje  := 0;
    o_sum_arznj := 0;
    o_sum_arsxf := 0;
    if p_arstr is not null then
      open c_rl;
      loop
        fetch c_rl into rl;
        if c_rl%notfound then
          exit;
        else
          --组织一条待销应收记录更新变量
          rl.rlpaidflag := 'Y';
          rl.rlsavingqc := p_remaind;   --期初预存（销帐时产生）
          if p_remaind > rl.rlje then
            rl.rlsavingbq := rl.rlje;   --本期预存发生（销帐时产生）
          else
            rl.rlsavingbq := p_remaind;
          end if;
          rl.rlsavingqm := rl.rlsavingqc - rl.rlsavingbq;   --期末预存（销帐时产生）
          rl.rlpaiddate := p_paiddate;            --销帐日期
          rl.rlpaidmonth := p_paidmonth;          --销账月份
          rl.rlpid := p_pid;                      --实收流水（与payment.pid对应）
          rl.rlpbatch := p_batch;                 --缴费交易批次（与payment.pbatch对应）
          rl.rlpaidje := rl.rlje + rl.rlsavingbq; --销帐金额（实收金额=应收金额+预存发生）
          rl.rlpaidper := p_oper;                 --销账人员
          --中间变量运算
          sumrlpaidje := sumrlpaidje + rl.rlpaidje;
          --记录末条销帐记录
          v_rlid := rl.rlid;
          --反馈实收记录
          o_sum_arje  := o_sum_arje + rl.rlje;
          p_remaind   := p_remaind + rl.rlsavingbq;
          --更新待销帐应收记录
          update bs_reclist
             set rlpaidflag  = rl.rlpaidflag,
                 rlsavingqc  = rl.rlsavingqc,
                 rlsavingbq  = rl.rlsavingbq,
                 rlsavingqm  = rl.rlsavingqm,
                 rlpaiddate  = rl.rlpaiddate,
                 rlpaidmonth = rl.rlpaidmonth,
                 rlpaidje    = rl.rlpaidje,
                 rlpid       = rl.rlpid,
                 rlpbatch    = rl.rlpbatch
           where rlid = rl.rlid;
        end if;
      end loop;
      close c_rl;
      --末条销帐记录处理，销帐溢出的实收金额计入末笔销帐记录的预存发生中！！！
      update bs_reclist set rlsavingbq = rlsavingbq + (p_payment - sumrlpaidje) where rlid = v_rlid;
    end if;
  exception
    when others then
      if c_rl%isopen then close c_rl; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --预存充值
  procedure precust(p_yhid        in varchar2,
                    p_position    in varchar2,
                    p_oper        in varchar2,
                    p_payway      in varchar2,
                    p_payment     in number,
                    p_memo        in varchar2,
                    p_pid         out varchar2,
                    o_remainafter out number) is
    cursor c_ci(vciid varchar2) is
        select * from bs_custinfo where ciid = vciid for update nowait; --若被锁直接抛出异常
    cursor c_mi(vmiid varchar2) is
        select * from bs_meterinfo where micode = vmiid for update nowait; --若被锁直接抛出异常
    p bs_payment%rowtype;
    mi bs_meterinfo%rowtype;
    ci bs_custinfo%rowtype;
  begin
    --1、实参校验、必要变量准备
    --------------------------------------------------------------------------
      --取用户信息
      open c_ci(p_yhid);
      fetch c_ci into ci;
      if c_ci%notfound or c_ci%notfound is null then
        raise_application_error(errcode,'用户编码【' || p_yhid || '】不存在！');
      end if;
      --取水表信息
      open c_mi(ci.ciid);
      fetch c_mi into mi;
      if c_mi%notfound or c_mi%notfound is null then
        raise_application_error(errcode, '这个用户编码没对应水表！' || p_yhid);
      end if;
    --2、记录实收
      select trim(to_char(seq_paidment.nextval, '0000000000'))
        into p_pid
        from dual;
      p.pid := p_pid;             --流水号
      p.pcid := ci.ciid;          --用户编号
      p.pmid := mi.miid;          --水表编号
      p.pdate := trunc(sysdate);  --帐务日期
      p.pdatetime := sysdate;     --发生日期
      p.pmonth := to_char(sysdate,'yyyy-mm');        --缴费月份
      p.pposition := p_position;  --缴费机构
      p.ptrans := 'S';            --缴费事务  独立预存S
      p.ppayee := p_oper;         --销帐人员
      p.psavingqc := nvl(ci.misaving,0);        --期初预存余额
      p.psavingbq := p_payment;                 --本期发生预存金额
      p.psavingqm := p.psavingqc + p.psavingbq; --期末预存余额
      p.ppayment := p_payment;                  --付款金额
      p.ppayway := p_payway;       --付款方式(xj-现金 zp-支票 mz-抹账 dc-倒存)
      p.pbseqno := null;           --缴费机构流水(银行实时收费交易流水)
      p.pbdate := null;            --银行日期(银行缴费账务日期)
      p.pchkdate := null;          --扎帐日期（收费员结账后回写审核日期）
      select trim(to_char(seq_paidbatch.nextval,'0000000000')) into p.pbatch from dual; --缴费交易批次
      p.pmemo := p_memo;        --备注
      p.preverseflag := 'N';    --冲正标志
      p.pscrid    := p.pid;     --原实收帐流水（应收冲实产生的负帐时payment.pscrid不空，且为被冲实收帐流水号，用于关联冲与被冲的关联，其它情况payment.pscrid为空）
      p.pscrtrans := p.ptrans;  --原实收缴费事务（实收冲正产生的负帐时payment.pscrtrans不空，且为被冲应收帐事务，用于关联冲与被冲的关联，其它情况payment.pscrtrans为空）
      p.pscrmonth := p.pmonth;  --原实收收月份（实收冲正（因冲帐产生负实收帐）：新生成负实收帐的原实收帐月份与被冲正实由帐月份相同（如：a用户2011年8月缴一笔水费，自来水公司在2011年9月发现这笔有问题，需要做实收冲正，做实收冲正时会产生一笔2011年9月负实帐，2011年9月负帐原实收帐月份为2011年8月）
      p.pscrdate  := p.pdate;   --原实收日期
      p.pchkno      := NULL;    --进账单号
      p.tchkdate    := NULL;    --到账日期
      o_remainafter := p.psavingqm;

      insert into bs_payment values p;
      update bs_custinfo set misaving = p.psavingqm where ciid = p_yhid;

      close c_ci;
      close c_mi;
  exception
    when others then
      if c_ci%isopen then close c_ci; end if;
      if c_mi%isopen then close c_mi; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --实收冲正，多流水号批量冲正
  procedure pay_back_by_pids(p_payids in varchar2, p_oper in varchar2, o_pid_reverse out varchar2) is
    v_pid_reverse varchar(100);
  begin
    o_pid_reverse := null;
    for i in (select regexp_substr(p_payids, '[^,]+', 1, level) pid from dual connect by level <= length(p_payids) - length(replace(p_payids, ',', '')) + 1) loop
      v_pid_reverse := null;
      pay_back_by_pid(i.pid,p_oper,v_pid_reverse);
      if o_pid_reverse is null then
         o_pid_reverse := v_pid_reverse;
      else
         o_pid_reverse := o_pid_reverse || ',' || v_pid_reverse;
      end if;
    end loop;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --实收冲正
  procedure pay_back_by_pid(p_payid in varchar2, p_oper in varchar2, o_pid_reverse out varchar2) is
    cursor c_p(vpid varchar2) is
      select * from bs_payment where pid = vpid and preverseflag <> 'Y' for update nowait;
    cursor c_mi(vmiid varchar2) is
      select * from bs_meterinfo where miid = vmiid for update nowait;
    mi        bs_meterinfo%rowtype;
    p_source  bs_payment%rowtype;
    p_reverse bs_payment%rowtype;
    v_call number;
  begin
    --STEP 1:实收帐处理----------------------------------
    open c_p(p_payid);
    fetch c_p into p_source;
    if c_p%found then
      open c_mi(p_source.pmid);
      fetch c_mi into mi;
      if c_mi%notfound or c_mi%notfound is null then
        raise_application_error(errcode, '无效的用户编号');
      end if;
      select trim(to_char(seq_paidment.nextval, '0000000000')) into o_pid_reverse from dual;
      p_reverse.pid        := o_pid_reverse;
      p_reverse.pcid       := p_source.pcid;
      p_reverse.pmid       := p_source.pmid;
      p_reverse.pdate      := trunc(sysdate);
      p_reverse.pdatetime  := sysdate;
      p_reverse.pmonth     := to_char(sysdate,'yyyy-mm');        --缴费月份
      p_reverse.pposition  := p_source.pposition;
      p_reverse.ptrans     := p_source.ptrans;
      select misaving into p_reverse.psavingqc from bs_custinfo where ciid = p_source.pcid;      --期初预存余额
      p_reverse.psavingbq := -p_source.psavingbq;
      p_reverse.psavingqm := p_reverse.psavingqc + p_reverse.psavingbq; --期末预存余额;
      p_reverse.ppayment  := -p_source.ppayment;
      p_reverse.ppayway   := null;
      p_reverse.pbseqno   := p_source.pbseqno;
      p_reverse.pbdate    := p_source.pbdate;
      p_reverse.pchkdate  := p_source.pchkdate;
      p_reverse.pbatch    := p_source.pbatch;
      p_reverse.ppayee    := p_oper;
      p_reverse.pmemo     := p_source.pmemo;
      p_reverse.preverseflag := 'Y';
      p_reverse.pscrid    := p_source.pid;
      p_reverse.pscrtrans := p_source.ptrans;
      p_reverse.pscrmonth := p_source.pmonth;
      p_reverse.pscrdate  := p_source.pdate;
      p_reverse.pchkno    := null;
      p_reverse.tchkdate  := null;
      p_reverse.pdzdate   := null;
      p_reverse.pcseqno   := p_source.pcseqno;
      p_reverse.pcchkflag := p_source.pcchkflag;
      p_reverse.pcdate    := p_source.pcdate;
      p_reverse.pwseqno   := null;
      p_reverse.pwdate    := null;
    else
      err_str :=  '无效的实收流水号：'|| p_payid;
      raise_application_error(errcode, '无效的实收流水号：'|| p_payid);
    end if;
    insert into bs_payment values p_reverse;
    update bs_payment set preverseflag = 'Y' where pid = p_payid;
    --END OF STEP 1: 处理结果：---------------------------------------------------
    --PAYMENT 增加了了一条负记录
    -- 被冲正记录的冲正标志为Y

    -----STEP 10: 增加负应收记录
    ---保存需要冲正处理的应收总账记录
    delete from bs_reclist_sscz_temp;
    insert into bs_reclist_sscz_temp select * from bs_reclist where rlpid = p_payid and rlpaidflag = 'Y';
    --保存需要冲正处理的应收明细帐记录
    delete from bs_recdetail_sscz_temp;
    insert into bs_recdetail_sscz_temp t (select a.* from bs_recdetail a, bs_reclist_sscz_temp b where a.rdid = b.rlid);

    --冲正时应收帐负数据
    v_call := f_set_cr_reclist(p_reverse);

    --将应收冲正负记录插入到应收总账中
    insert into bs_reclist t (select * from bs_reclist_sscz_temp);

    ---在应收明细临时表中做负记录的调整
    --一般字段调整
    update bs_recdetail_sscz_temp t
       set t.rdsl  = 0 - t.rdsl,
           t.rdje  = 0 - t.rdje;
    --流水id调整
    update bs_recdetail_sscz_temp t
       set t.rdid =
           (select s.rlid
              from bs_reclist_sscz_temp s
             where t.rdid = s.rlcolumn9)
     where t.rdid in (select rlcolumn9 from bs_reclist_sscz_temp);
    --插入到应收明细表
    insert into bs_recdetail t (select s.* from bs_recdetail_sscz_temp s);

    -----STEP 20: 增加正应收记录--------------------------------------------------------------
    ---保存需要冲正处理的应收总账记录
    delete from bs_reclist_sscz_temp;
    insert into bs_reclist_sscz_temp select * from bs_reclist where rlpid = p_payid and rlpaidflag = 'Y';
    ---保存需要冲正处理的应收明细帐记录
    delete from bs_recdetail_sscz_temp;
    insert into bs_recdetail_sscz_temp t(select a.* from bs_recdetail a, bs_reclist_sscz_temp b where a.rdid = b.rlid);

    ---在应收总账临时表中做正记录的调整
    update bs_reclist_sscz_temp t
       set t.rlid    = trim(to_char(seq_reclist.nextval, '0000000000')), --新生成
           t.rlmonth = to_char(sysdate, 'yyyy.mm'), --当前              帐务月份
           t.rldate  = sysdate, --当前              帐务日期
           t.rlscrrlid = t.rlid,--上次应收帐流水
           t.rlscrrltrans = t.rltrans,--上次应收帐事务
           t.rlscrrlmonth = t.rlmonth,--上次应收帐月份
           t.rlpaidflag = 'N',
           t.rlpaidper  = '', --无
           t.rlpaiddate = '', --无
           t.rldatetime = sysdate, --sysdate
           t.rlpid         = null, --无
           t.rlpbatch      = null, --无
           t.rlsavingqc    = 0, --无
           t.rlsavingbq    = 0, --无
           t.rlsavingqm    = 0, --无
           t.rlreverseflag = 'N';
    --将应收冲正正记录插入到应收总账中
    insert into bs_reclist t (select * from bs_reclist_sscz_temp);

    ---在应收明细临时表中做正记录的调整
    update bs_recdetail_sscz_temp t
       set t.rdid =
           (select s.rlid
              from bs_reclist_sscz_temp s
             where t.rdid = s.rlcolumn9)
     where t.rdid in (select rlcolumn9 from bs_reclist_sscz_temp);
    --插入到应收明细表
    insert into bs_recdetail t (select s.* from bs_recdetail_sscz_temp s);

    ----STEP 30 原应收记录打冲正标记
    update bs_reclist t set t.rlreverseflag = 'Y' where t.rlpid = p_payid and t.rlpaidflag = 'Y';

    ----STEP 40 水表资料预存余额调整--------------------------------------------------------------
    update bs_custinfo set misaving = p_reverse.psavingqm where ciid = p_source.pcid;
    commit;
    close c_p;
    close c_mi;
  exception
    when others then
      if c_p%isopen then close c_p; end if;
      if c_mi%isopen then close c_mi; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

/*******************************************************************************************
函数名：f_set_cr_reclist
用途： 本函数由核心实收冲正帐过程调用，调用前【待冲正应收记录记录】已经在从reclist 中拷贝到临时表中，本函数对临时表进行逐条冲正处理，
返回主程序后，核心冲正过程根据临时表更新reclist ，达到快捷冲正目的。
       逐条处理的目的：将冲正金额和预存逐条分配到应收帐记录上，预存管理
例子： a水表，个月欠费110元，期初预存30元，本次收费100元，违约金5元，应收冲正后记录如下：
----------------------------------------------------------------------------------------------------
月     份       预初     本次收费    应缴水费     违约金    预存期末   预存发生
----------------------------------------------------------------------------------------------------
原  2011.06         30          100           110         5        15         15
新  2011.06         30         -100           -110       -5        15        -15
-----------------------------------------------------------------------------------------------------
参数：pm 负实收 。
*******************************************************************************************/
  function f_set_cr_reclist(pm in bs_payment%rowtype --负的实收
                            ) return number as
    --应收帐销帐临时表游标,按原应收帐月份排序
    cursor c_rl is
      select t.*
        from bs_reclist_sscz_temp t
       order by t.rlscrrlmonth;
    v_rcount number;
    v_rl     bs_reclist%rowtype;
    v_qc     number;
  begin
    v_rcount := 0;
    open c_rl;
    v_qc := pm.psavingqm;
    loop
      fetch c_rl into v_rl;
      exit when c_rl%notfound or c_rl%notfound is null;
      --销本应收记录后的预存期末
      v_rl.rlsavingqm := v_qc;
      v_rl.rlsavingbq := -v_rl.rlsavingbq;
      v_rl.rlsavingqc := v_rl.rlsavingqm - v_rl.rlsavingbq; --销本应收记录时的预存期初
      ----销本应收记录时的预存发生
      v_qc := v_rl.rlsavingqc; --上一条期末，成为下一条期初
      ----金额处理完毕------------------------------------------------------------------------------------------------
      ---更新临时应收表
      update bs_reclist_sscz_temp t
         set t.rlid    = trim(to_char(seq_reclist.nextval, '0000000000')),
             t.rlmonth = to_char(sysdate, 'yyyy.mm'), --当前              帐务月份
             t.rldate  = sysdate, --当前              帐务日期
             t.rlreadsl       = 0 - t.rlreadsl, --抄见水量
             t.rlsl    = 0 - t.rlsl, --取负              应收水量
             t.rlje    = 0 - t.rlje, --取负              应收金额
             t.rlcolumn9  = t.rlid, --原记录.rlid       原应收帐流水
             t.rlscrrlid = t.rlid,--上次应收帐流水
             t.rlscrrltrans = t.rltrans,--上次应收帐事务
             t.rlscrrlmonth = t.rlmonth,--上次应收帐月份
             t.rlpaidje = 0 - t.rlpaidje, --取负              销帐金额
             t.rlpaidper  = pm.ppayee, --同实收            销帐人员
             t.rlpaiddate = pm.pdate, --同实收            销帐日期
             t.rldatetime = sysdate, --sysdate           发生日期
             t.rlpid         = pm.pid, --对应的负实收流水  实收流水（与payment.pid对应）
             t.rlpbatch      = pm.pbatch, --对应的负实收流水  缴费交易批次（与payment.pbatch对应）
             t.rlsavingqc    = v_rl.rlsavingqc, --计算              期初预存（销帐时产生）
             t.rlsavingbq    = 0 - t.rlsavingbq, --计算              本期预存发生（销帐时产生）
             t.rlsavingqm    = v_rl.rlsavingqm, --计算              期末预存（销帐时产生）
             t.rlreverseflag = 'Y', --y                   冲正标志（n为正常，y为冲正）
             t.rlmisaving    = 0, --算费时预存
             t.rlpriorje     = 0 --算费之前欠费
             --t.rlpaidmonth   = tools.fgetrecmonth(t.rlmsmfid)
       where t.rlid = v_rl.rlid;
      v_rcount := v_rcount + 1;
    end loop;
    return v_rcount;
  exception
    when others then return 0;
  end;

end;
/

