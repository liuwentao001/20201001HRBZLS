CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_DK_01" is
  CurrentDate date := tools.fGetSysDate;

  ---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid
  --note:D:代扣
  --author:wy
  --date：2011/10/19
  --input: p_bankid:银行代码
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志


  ---------------------------------------------------------------------------
  PROCEDURE sp_create_dk(p_bankid  in varchar2,
                                       p_mfsmfid in varchar2,
                                       p_oper    in varchar2,
                                       p_srldate in varchar2,
                                       p_erldate in varchar2,
                                       p_smon    in varchar2,
                                       p_emon    in varchar2,
                                       p_sftype  in varchar2,
                                       p_commit  in varchar2,
                                       o_batch   out varchar2)
is
begin

    sp_create_dk_rlid_03(p_bankid  ,
                                       p_mfsmfid  ,
                                       p_oper     ,
                                       p_srldate  ,
                                       p_erldate  ,
                                       p_smon     ,
                                       p_emon     ,
                                       p_sftype   ,
                                       p_commit   ,
                                       o_batch    );
exception
    when others then
      rollback;
      raise;
end;


  ---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid_01
  --note:D:代扣
  --author:wy
  --date：2009/04/26
  --input: p_bankid:银行代码
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志
  --说明：代扣发出一条应收一个一条代收费记录
  --收滞纳金，不收手续费
  ---------------------------------------------------------------------------
  PROCEDURE sp_create_dk_rlid_01(p_bankid  in varchar2,
                                       p_mfsmfid in varchar2,
                                       p_oper    in varchar2,
                                       p_srldate in varchar2,
                                       p_erldate in varchar2,
                                       p_smon    in varchar2,
                                       p_emon    in varchar2,
                                       p_sftype  in varchar2,
                                       p_commit  in varchar2,
                                       o_batch   out varchar2) is
    EL ENTRUSTLIST%ROWTYPE;
    eg entrustlog%ROWTYPE;
    mi meterinfo%rowtype;

    rl reclist%rowtype;
    ma meteraccount%rowtype;
    cursor c_ysz is
      select rlid, --应收流水
             miid, --水表号
             micode, --客户代码
             mabankid, --银行ID
             MAACCOUNTNO, --用户开户帐号
             maaccountname, --用户开户名
             rlje, --应收金额
             rlzndate, --滞纳金起算日
             PG_EWIDE_PAY_01.getznjadj(mismfid,
                                       rlje,
                                       rlgroup,
                                       rlzndate,
                                       mismfid,
                                       sysdate), --滞纳金
             rlmonth, --应收帐月份
             RLCADR, --用户地址
             rlmadr, --水表地址
             rlcname, --产权名
             rlmonth --应收帐月份
        from meteraccount t, meterinfo t1, /*水表欠费 T3,*/ reclist rl
       WHERE MIID = MAMID

         --AND T3.QFMIID = MIID
         and miid = rlmid
         and rloutflag='N'
         and rlje>0
         and rlcd='DE'
         and rlpaidflag='N'
         and rl.rlreverseflag='N'
        -- and t3.合计欠费>0
         and ((mismfid = p_mfsmfid and p_mfsmfid is not null) or
             p_mfsmfid is null)
         and t1.michargetype = p_sftype
         and t.mabankid like p_bankid || '%'
         and ((rlmonth >= p_smon and p_smon is not null) or p_smon is null)
         and ((rlmonth <= p_emon and p_emon is not null) or p_emon is null)
         and ((rldate >= p_srldate and p_srldate is not null) or
             p_srldate is null)
         and ((rldate <= p_erldate and p_erldate is not null) or
             p_erldate is null);
  begin
    if p_sftype<>'D' THEN
      raise_application_error(errcode, '收费方式传入错误');
    END IF;
    eg.eloutrows  := 0; --发出数
    eg.eloutmoney := 0; --发出金额
    select trim(to_char(seq_entrustlog.nextval, '0000000000'))
      into eg.elbatch
      from dual;
    open c_ysz;
    loop
      fetch c_ysz
        into rl.rlid, --应收流水
             mi.miid, --水表号
             mi.micode, --客户代码
             ma.mabankid, --银行ID
             ma.MAACCOUNTNO, --用户开户帐号
             ma.Maaccountname, --用户开户名
             rl.rlje, --应收金额
             rl.rlzndate, --滞纳金起算日
             rl.rlznj, --滞纳金
             rl.rlmonth, --应收帐月份
             rl.rlcadr, --用户地址
             rl.rlmadr, --水表地址
             rl.rlcname, --产权名
             rl.rlmonth --应收帐月份
      ;
      exit when c_ysz%notfound or c_ysz%notfound is null;
      select trim(to_char(seq_entrustlist.nextval, '0000000000'))
        into EL.ETLSEQNO
        from dual;

      EL.ETLBATCH := eg.elbatch; --代扣批次
      --EL.TLSEQNO            :=  ;--代扣流水
      EL.ETLRLID        := rl.rlid; --应收流水
      EL.ETLMID         := mi.miid; --水表编号
      EL.ETLMCODE       := mi.micode; --资料号
      EL.ETLBANKID      := ma.mabankid; --代扣银行
      EL.ETLACCOUNTNO   := ma.maaccountno; --开户帐号
      EL.ETLACCOUNTNAME := ma.maaccountname; --开户名

      EL.ETLSXF := 0; --手续费
      EL.ETLZNJ := rl.rlznj; --应收滞纳金

      EL.ETLJE     := rl.rlje + EL.ETLZNJ + EL.ETLSXF; --应收金额
      EL.ETLZNDATE := rl.rlzndate; --滞纳金起算日

      --EL.ETLPIID             :=  ;--费用项目
      ----EL.ETLPAIDDATE         :=  ;--销帐日期
      --EL.ETLPAIDCDATE        :=  ;--清算日期
      EL.ETLPAIDFLAG := 'N'; --销帐标志
      --EL.ETLRETURNCODE       :=  ;--返回信息码
      --EL.ETLRETURNMSG        :=  ;--返回信息
      --EL.ETLCHKDATE          :=  ;--对帐日期
      EL.ETLSFLAG  := 'N'; --银行成功扣款标志
      EL.ETLRLDATE := RL.RLDATE; --应收账务日期
      --EL.ETLNO               :=  ;--委托授权号
      --EL.ETLTSBANKID         :=  ;--接收行号（托）
      --EL.TLPZNO             :=  ;--凭证号

      EL.ETLCIADR := RL.RLCADR; --用户地址
      EL.ETLMIADR := RL.RLMADR; --水表地址
      --EL.ETLBANKIDNAME       :=  ;--开户银行名称
      --EL.ETLBANKIDNO         :=  ;--开户银行实际编号
      --EL.ETLTSBANKIDNAME     :=  ;--收款行名
      --EL.ETLTSBANKIDNO       :=  ;--收款行号
      --EL.ETLSFJE             :=  ;--水费
      --EL.ETLWSFJE            :=  ;--污水费
      --EL.ETLSFZNJ            :=  ;--水费滞纳金
      --EL.ETLWSFZNJ           :=  ;--污水费滞纳金
      --EL.ETLRLIDPIID         :=  ;--应收流水加费用项目
      --EL.ETLSL               :=  ;--水量
      --EL.ETLWSL              :=  ;--污水量
      --EL.ETLSFDJ             :=  ;--水费单价
      --EL.ETLWSFDJ            :=  ;--污水费单价
      EL.ETLCINAME   := RL.RLCNAME; --产权名
      EL.ETLRLMONTH  := RL.RLMONTH; --应收帐月份
      EL.ETLINVCOUNT := 0; --发票张数
      --EL.ETLCHRMODE          :=  ;--销帐方式（1：未处理 ，2：文档销帐，3：手工销帐,4:解锁,5:银行未处理的全部销帐,6:银行未处理的部分销帐,7银行反盘未处理）
      --EL.ETLPAIDPER          :=  ;--销帐员
      --EL.ETLTSACCOUNTNO      :=  ;--收款行号
      --EL.ETLTSACCOUNTNAME    :=  ;--收款户名
      --EL.ETLSZYFZNJ          :=  ;--水资源费滞纳金
      --EL.ETLLJFZNJ           :=  ;--垃圾处理费滞纳金
      --EL.ETLSZYFSL           :=  ;--水资源水量
      --EL.ETLLJFSL            :=  ;--垃圾费水量
      --EL.ETLSZYFDJ           :=  ;--水资源费单价
      --EL.ETLLJFDJ            :=  ;--垃圾费单价
      --EL.ETLINVSFCOUNT       :=  ;--垃圾费单价
      --EL.ETLINVWSFCOUNT      :=  ;--垃圾费单价
      --EL.ETLINVSZYFCOUNT     :=  ;--垃圾费单价
      --EL.ETLINVLJFCOUNT      :=  ;--垃圾费单价
      --EL.ETLMIUIID           :=  ;--合收单位编号
      --EL.ETLSZYFJE           :=  ;--水资源费
      --EL.ETLLJFJE            :=  ;--垃圾费
      EL.ETLIFINV              := 0 ;--发票是否已打印（发票托收凭证）

      INSERT INTO ENTRUSTLIST VALUES EL;

      --锁帐，更新批次号，流水，滞纳金便于回来销帐
      update reclist t
         set t.rlznj          = rl.rlznj,
             t.rloutflag      = 'Y',
             t.rlentrustbatch = el.etlbatch,
             t.rlentrustseqno = el.etlseqno
       where rlid = rl.rlid;

/*      --更新明细滞金
      update recdetail t set t.rdznj = 0 where rdid = rl.rlid;
      update recdetail t
         set t.rdznj = rl.rlznj
       where rdid = rl.rlid
         and rownum = 1;*/

      eg.eloutrows  := eg.eloutrows + 1; --发出数
      eg.eloutmoney := eg.eloutmoney + el.etlje; --发出金额
    end loop;
    close c_ysz;
    if eg.eloutmoney > 0 then

      --eg.ELBATCH          :=    ;--托收代扣批号
      eg.ELBANKID     := p_bankid; --代扣文档银行
      eg.ELCHARGETYPE := p_sftype; --收费方式
      eg.ELOUTOER     := p_oper; --发出操作员
      eg.ELOUTDATE    := sysdate; --发出日期
      --eg.ELOUTROWS        :=    ;--发出条数
      --eg.ELOUTMONEY       :=    ;--发出金额
      --eg.ELCHKDATE        :=    ;--对账日期
      eg.ELCHKROWS := 0; --对账总条数
      eg.ELCHKJE   := 0; --对账总金额
      --eg.ELSCHKDATE       :=    ;--成功文件导入日期
      eg.ELSROWS := 0; --银行成功条数
      eg.ELSJE   := 0; --银行成功金额
      --eg.ELFCHKDATE       :=    ;--失败文件导入日期
      eg.ELFROWS := 0; --银行失败条数
      eg.ELFJE   := 0; --银行失败金额
      --eg.ELPAIDDATE       :=    ;--本地销帐日期
      eg.ELPAIDROWS := 0; --本地已销帐条数
      eg.ELPAIDJE   := 0; --本地已销帐金额
      eg.ELCHKNUM   := 0; --本地对账次数
      eg.ELCHKEND   := 'N'; --本地对账截止标志
      eg.ELSTATUS   := 'Y'; --有效状态
      --eg.ELSMFID          :=    ;--营业所
      --eg.ELTSTYPE         :=    ;--托收类型（1批量托收,2零托）
      --eg.ELPLANIMPDATE    :=    ;--计划导入日期
      --eg.ELIMPTYPE        :=    ;--文件导入类型1：未处理，2：手工，3：自动
      --eg.ELRECMONTH       :=    ;--应收帐月份
      INSERT INTO ENTRUSTLOG VALUES EG;
      o_batch := EG.ELBATCH;
      IF p_commit = 'Y' THEN
        COMMIT;
      END IF;
    else
      rollback;
    end if;
  exception
    when others then
      rollback;
      if c_ysz%isopen then
        close c_ysz;
      end if;
      raise;
  end;
PROCEDURE sp_create_dk_rlid_03(
                                      p_bankid  in varchar2,
                                      p_mfsmfid in varchar2,
                                      p_oper    in varchar2,
                                      p_srldate in varchar2,
                                      p_erldate in varchar2,
                                      p_smon    in varchar2,
                                      p_emon    in varchar2,
                                      p_sftype  in varchar2,
                                      p_commit  in varchar2,
                                      o_batch   out varchar2) is
  EL       ENTRUSTLIST%ROWTYPE;
  eg       entrustlog%ROWTYPE;
  mi       meterinfo%rowtype;
  rl       reclist%rowtype;
  ma       meteraccount%rowtype;
  v_rlid   reclist.rlid%type;
  v_miid   meterinfo.miid%type;

  /*代扣信息*/
  cursor c_tsinfo is
    select rlid, miid
        from meteraccount t, meterinfo t1,  reclist rl
       WHERE    miid = rlmid
         and MIID = MAMID
         and rloutflag='N'
         and rlje>0
         and rlpaidflag='N'
         and rl.rlreverseflag='N'
         and ((mismfid = p_mfsmfid and p_mfsmfid is not null) or
             p_mfsmfid is null)
         and t.mabankid like p_bankid || '%'
         and t1.michargetype = p_sftype
         and ((rlmonth >= p_smon and p_smon is not null) or p_smon is null)
         and ((rlmonth <= p_emon and p_emon is not null) or p_emon is null)
         and ((rldate >= p_srldate and p_srldate is not null) or
             p_srldate is null)
         and ((rldate <= p_erldate and p_erldate is not null) or
             p_erldate is null)
     GROUP BY rlid, miid, MAACCOUNTNO
     order by MAACCOUNTNO;
begin
  /*参数检查**/
  if p_sftype is null then
    raise_application_error(errcode, '收费方式传入不能为空');
  end if;
  if p_sftype <> 'D' THEN
    raise_application_error(errcode, '收费方式传入错误');
  END IF;

  /**代扣日志初始化*/
  select trim(to_char(seq_entrustlog.nextval, '000000000'))
    into eg.elbatch
    from dual; --批次
  eg.ELCHARGETYPE := p_sftype;
  eg.elbankid     := p_bankid;
  eg.ELOUTOER     := p_oper; --发出操作员
  eg.ELOUTDATE    := sysdate; --发出日期
  eg.ELOUTROWS    := 0; --发出条数
  eg.ELOUTMONEY   := 0; --发出金额
  eg.ELCHKDATE    := null; --对账日期
  eg.ELCHKROWS    := 0; --对账总条数
  eg.ELCHKJE      := 0; --对账总金额
  eg.ELSCHKDATE   := null; --成功文件导入日期
  eg.ELSROWS      := 0; --银行成功条数
  eg.ELSJE        := 0; --银行成功金额
  eg.ELFCHKDATE   := null; --失败文件导入日期
  eg.ELFROWS      := 0; --银行失败条数
  eg.ELFJE        := 0; --银行失败金额
  eg.ELPAIDDATE   := null; --本地销帐日期
  eg.ELPAIDROWS   := 0; --本地已销帐条数
  eg.ELPAIDJE     := 0; --本地已销帐金额
  eg.ELCHKNUM     := 0; --本地对账次数
  eg.ELCHKEND     := 'N'; --本地对账截止标志
  eg.ELSTATUS     := 'Y'; --有效状态
  eg.ELSMFID      := p_mfsmfid; --
    eg.eltstype := '1'; --批量代扣
  eg.ELPLANIMPDATE := null; --计划导入日期
  eg.ELIMPTYPE     := null; --文件导入类型1：未处理，2：手工，3：自动
  eg.ELRECMONTH    := p_smon; --应收帐月份
  /***代扣信息**/
  open c_tsinfo;

  loop
    fetch c_tsinfo
      into v_rlid, v_miid;
    exit when c_tsinfo%notfound or c_tsinfo%notfound is null;

    --应收信息
    select * into rl from reclist where rlid = v_rlid;
    --用户信息
    select * into mi from meterinfo where miid = v_miid;
    --用户银行信息
    select * into ma from meteraccount where MAMID = v_miid;

    ---2012-11-7 modify by zhb  诸暨代扣发出金额包括滞纳金
    rl.rlznj := PG_EWIDE_PAY_lyg.GETZNJADJ(rl.RLID,
          rl.RLJE,
          rl.RLGROUP,
          rl.RLZNDATE,
          rl.RLMSMFID,
          TRUNC(SYSDATE));
   -----end -----------------------

    EL.ETLBATCH := eg.elbatch; --代扣批次
    select trim(to_char(seq_entrustlist.nextval, '0000000000'))
      into EL.ETLSEQNO
      from dual; --代扣流水
    EL.ETLRLID          := rl.rlid; --应收流水
    EL.ETLMID           := mi.miid; --水表编号
    EL.ETLMCODE         := mi.micode; --资料号
    EL.ETLBANKID        := ma.mabankid; --代扣银行
    EL.ETLACCOUNTNO     := ma.maaccountno; --开户帐号
    EL.ETLACCOUNTNAME   := ma.maaccountname; --开户名
    EL.ETLZNDATE        := rl.rlzndate; --滞纳金起算日
    EL.ETLPIID          := NULL; --费用项目
    EL.ETLPAIDDATE      := NULL; --销帐日期
    EL.ETLPAIDCDATE     := NULL; --清算日期
    EL.ETLPAIDFLAG      := 'N'; --销帐标志
    EL.ETLRETURNCODE    := NULL; --返回信息码
    EL.ETLRETURNMSG     := NULL; --返回信息
    EL.ETLCHKDATE       := NULL; --对帐日期
    EL.ETLSFLAG         := 'N'; --银行成功扣款标志
    EL.ETLRLDATE        := RL.RLDATE; --应收账务日期
    EL.ETLNO            := NULL; --委托授权号
    EL.ETLTSBANKID      := ma.matsbankid; --接收行号（托）
    EL.ETLPZNO          := null; --凭证号
    EL.ETLCIADR         := RL.RLCADR; --用户地址
    EL.ETLMIADR         := RL.RLMADR; --水表地址
    EL.ETLBANKIDNAME    := fgetsysmanaframe(ma.mabankid); --开户银行名称
    EL.ETLBANKIDNO      := ma.mabankid; --开户银行实际编号
    EL.ETLTSBANKIDNAME  := fgetsysmanaframe(ma.matsbankid); --收款行名
    EL.ETLTSBANKIDNO    := ma.matsbankid; --收款行号
    EL.ETLSFJE          := null; --水费
    EL.ETLWSFJE         := null; --污水费
    EL.ETLSFZNJ         := null; --水费滞纳金
    EL.ETLWSFZNJ        := null; --污水费滞纳金
    EL.ETLRLIDPIID      := null; --应收流水加费用项目
    EL.ETLSL            := null; --水量
    EL.ETLWSL           := null; --污水量
    EL.ETLSFDJ          := null; --水费单价
    EL.ETLWSFDJ         := null; --污水费单价
    EL.ETLCINAME        := RL.RLCNAME; --产权名
    EL.ETLRLMONTH       := RL.RLMONTH; --应收帐月份
    EL.ETLCHRMODE       := null; --销帐方式（1：未处理 ，2：文档销帐，3：手工销帐,4:解锁,5:银行未处理的全部销帐,6:银行未处理的部分销帐,7银行反盘未处理）
    EL.ETLPAIDPER       := null; --销帐员
    EL.ETLTSACCOUNTNO   := fgetsysmanapara(ma.matsbankid, 'ZH'); --收款行号
    EL.ETLTSACCOUNTNAME := fgetsysmanapara(ma.matsbankid, 'HM'); --收款户名
    EL.ETLSZYFZNJ       := null; --水资源费滞纳金
    EL.ETLLJFZNJ        := null; --垃圾处理费滞纳金
    EL.ETLSZYFSL        := null; --水资源水量
    EL.ETLLJFSL         := null; --垃圾费水量
    EL.ETLSZYFDJ        := null; --水资源费单价
    EL.ETLLJFDJ         := null; --垃圾费单价
    EL.ETLINVSFCOUNT    := null; --垃圾费单价
    EL.ETLINVWSFCOUNT   := null; --垃圾费单价
    EL.ETLINVSZYFCOUNT  := null; --垃圾费单价
    EL.ETLINVLJFCOUNT   := null; --垃圾费单价
    EL.ETLMIUIID        := mi.MIUIID; --合收单位编号
    EL.ETLSZYFJE        := null; --水资源费
    EL.ETLLJFJE         := null; --垃圾费
    EL.ETLIFINV         := 0; --发票是否已打印（发票代扣凭证）
    EL.ETLIFINVPZ       := 0; --凭证是否已经打印
    EL.ETLSXF           := null; --手续费
    EL.ETLZNJ           := rl.rlznj; --应收滞纳金
    EL.ETLJE            := rl.rlje + rl.rlznj + 0; --应收金额
    EL.ETLWSFJE         := null; --污水费
    EL.ETLINVCOUNT      := 1; --发票张数
    EL.ETLINVWSFCOUNT   := null; --垃圾费单价
    eg.eloutrows        := eg.eloutrows + 1; --发出数
    eg.ELOUTMONEY       := eg.ELOUTMONEY + EL.ETLJE;
    INSERT INTO ENTRUSTLIST VALUES EL;
    /**更新应收信息**/
    update reclist t
       set t.rlznj          = rl.rlznj,
           t.rloutflag      = 'Y',
           t.rlentrustbatch = el.etlbatch,
           t.rlentrustseqno = el.etlseqno
     where rlid = rl.rlid;
  end loop;
  if c_tsinfo%rowcount = 0 then
    raise_application_error(errcode, '本次没有需要发出代扣用户信息');
  end if;
  if eg.ELOUTMONEY = 0 then
    raise_application_error(errcode, '发出金额为0');
  end if;
  /*插入日志*/
  INSERT INTO ENTRUSTLOG VALUES EG;

   o_batch :=EG.ELBATCH;

  IF p_commit = 'Y' THEN
    COMMIT;
  END IF;
exception
  when others then
    rollback;
    if c_tsinfo%isopen then
      close c_tsinfo;
    end if;
    raise;
end;
---------------------------------------------------------------------------
  --                        撤销总过程代扣批次数据
  --name:sp_cancle_dk
  --note:撤销代扣批次数据
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_dk 代扣批次号
 -- p_oper in varchar2,--操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  procedure sp_cancle_dk(p_entrust_batch in varchar2,
                         p_oper in varchar2,--操作员
                               p_commit        in varchar2)
                               IS
    BEGIN
      sp_cancle_dk_batch_01(p_entrust_batch  ,
                                p_oper,
                               p_commit     );
    exception
    when others then
      rollback;
      raise;
    END;

---------------------------------------------------------------------------
  --                        撤销代扣批次数据
  --name:sp_cancle_dk_batch
  --note:撤销代扣批次数据
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_dk_batch_01 代扣批次号
  --p_oper in varchar2,--操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  procedure sp_cancle_dk_batch_01(p_entrust_batch in varchar2,
                                p_oper in varchar2,--操作员
                               p_commit        in varchar2) is

    v_dk_log entrustlog%rowtype; --代扣日志
    V_TEST   VARCHAR2(10);
  begin
    IF p_entrust_batch IS NULL THEN
      V_TEST := '000';
    END IF;
    begin
      select *
        into v_dk_log
        from entrustlog
       where elbatch = p_entrust_batch;
    exception
      when others then
        raise_application_error(errcode,
                                '批次号[' || p_entrust_batch || ']不存在,请检查!');
    end;
    --撤销检查
    if v_dk_log.elstatus = 'N' then
      raise_application_error(errcode,
                              '批次号[' || p_entrust_batch || ']已作废,无需再次作废!');
    end if;
    if v_dk_log.elchknum > 0 then
      RAISE_application_error(errcode,
                              '该代扣批次[' || p_entrust_batch || ']已经导入，不能撤销！');
    end if;
   /* --清空应收账发出流水,批次号,发出标志
    update recdetail set rdznj=0
    where rdid in (
    select rlid from reclist WHERE RLENTRUSTBATCH = p_entrust_batch
    )
    and rdpaidflag='N' ;*/

    update reclist
       set RLENTRUSTBATCH = null, RLENTRUSTSEQNO = null, RLOUTFLAG = 'N',RLZNJ =0
     WHERE RLENTRUSTBATCH = p_entrust_batch;
    --更新代扣发出日志有效标志
    update entrustlog set elstatus = 'N' where elbatch = p_entrust_batch;
  ---插入日志表
   insert into eldelbak
    select p_oper, sysdate, t.* from entrustlog t where elbatch = p_entrust_batch;

  ---插入日志表
   insert into etldelbak
    select p_oper, sysdate, t.* from entrustlist t where etlbatch = p_entrust_batch;

    --删除
     DELETE entrustlog where  elbatch = p_entrust_batch;
   --删除代扣的中间表
    delete  entrustlist  where  etlbatch =p_entrust_batch;
   ---删除文件同步
   update  entrustfile t
   set t.efflag='4'
    where t.efelbatch= p_entrust_batch;

    --提交
    if p_commit = 'Y' THEN
      commit;
    end if;
    --错误处理
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise;
  END;

---------------------------------------------------------------------------
  --                        撤销代扣导入
  --name:sp_cancle_dk_imp
  --note:撤销代扣导入
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_dk_imp 撤销代扣导入

  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  procedure sp_cancle_dk_imp_01(p_entrust_batch in varchar2,

                               p_commit        in varchar2) is

    v_dk_log entrustlog%rowtype; --代扣日志
    V_TEST   VARCHAR2(10);
    V_EXIT NUMBER(10);
  begin
    IF p_entrust_batch IS NULL THEN
      V_TEST := '000';
    END IF;
    begin
      select *
        into v_dk_log
        from entrustlog
       where elbatch = p_entrust_batch and elchargetype='D' ;
    exception
      when others then
        raise_application_error(errcode,
                                '代扣批次号[' || p_entrust_batch || ']不存在,请检查!');
    end;
    --撤销检查
    if v_dk_log.elstatus = 'N' then
      raise_application_error(errcode,
                              '批次号[' || p_entrust_batch || ']已作废,无需要取消导入!');
    end if;
    if v_dk_log.ELPAIDDATE  IS NOT NULL then
      raise_application_error(errcode,
                              '批次号[' || p_entrust_batch || ']已经销帐处理[销帐日期不为空]，不能取消导入!');
    end if;
    if v_dk_log.ELPAIDROWS  >0  then
      raise_application_error(errcode,
                              '批次号[' || p_entrust_batch || ']已经销帐处理[销帐记录条件大于0]，不能取消导入!');
    end if;
    if v_dk_log.elchknum < 1 then
      RAISE_application_error(errcode,
                              '该代扣批次[' || p_entrust_batch || ']没有导入，无需要取消导入！');
    end if;
    select count(*) INTO V_EXIT from entrustlist
    where  ETLPAIDFLAG='Y'  AND etlbatch = p_entrust_batch;
    IF V_EXIT>0 THEN
      raise_application_error(errcode,
                              '批次号[' || p_entrust_batch || ']已经销帐处理，不能取消导入!');
    END IF;
    --更新代扣发出日志有效标志
    update entrustlog set
     ELCHKEND = 'N',
     ELCHKNUM=0,
     ELPAIDJE=0,
     ELPAIDROWS=0,
     ELPAIDDATE=null,
     ELFJE =0 ,
     ELFROWS =0 ,
     ELFCHKDATE =null ,
     ELSJE = 0 ,
     ELSROWS = 0 ,
     ELSCHKDATE = null ,
     ELCHKJE = 0 ,
     ELCHKROWS = 0 ,
     ELCHKDATE = null
      where elbatch = p_entrust_batch;
update entrustlist set
      ETLRETURNCODE=null ,
      ETLRETURNMSG =null ,
      ETLCHKDATE = null  ,
      ETLSFLAG   = 'N'
 where etlbatch=  p_entrust_batch;
    --提交
    if p_commit = 'Y' THEN
      commit;
    end if;
    --错误处理
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise;
  END;
--生成代扣文件名函数
  ---------------------------------------------------------------------------
  --                        生成代扣文件名函数
  --name:fgetDKexpname
  --note:生成代扣文件名函数
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --       p_batch 代扣批次号
  --return DKDS(4位)+银行编号(6位)+日期(8位)+批次号+(10位)
  -- 如:DK03001200904280000000001
  ---------------------------------------------------------------------------
  function fgetDKexpname(p_type   in varchar2,
                         p_bankid in varchar2,
                         p_batch  in varchar2) return varchar2 is
    v_ret varchar2(100);
    etlog entrustlog%rowtype;
  begin
    --生成代扣文件名 格式：DKDS(4位)+银行编号(6位)+日期(8位)+批次号+(10位)
    -- 如:DK031200904280000000001
    if p_type is null then
      raise_application_error(errcode, '传入类型为空,请系统管理员检查!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '传入银行为空,请系统管理员检查!');
    end if;
    if p_batch is null then
      raise_application_error(errcode, '传入批次为空,请系统管理员检查!');
    end if;
    begin
      select * into etlog from entrustlog where elbatch = p_batch;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(errcode, '代扣批次不存在!');
    end;
    if p_type = '01' then

         v_ret := FPARA(p_bankid, 'DKEXPNAME') || to_char(etlog.eloutdate, 'yyyymmdd');

    else
      return null;
    end if;
    return v_ret;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;

  --取代扣导出格文件类型
  ---------------------------------------------------------------------------
  --                        取代扣导出格文件类型
  --name:fgetDKexpfiletype
  --note:取代扣导出格文件类型
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

   function fgetDKexpfiletype(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '传入类型为空,请系统管理员检查!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '传入银行为空,请系统管理员检查!');
    end if;

    if p_type = '01' then

       v_reDKql := FPARA(p_bankid, 'DKEXPTYPE');

    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;


function fgetDKexpfilepath(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '传入类型为空,请系统管理员检查!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '传入银行为空,请系统管理员检查!');
    end if;

    if p_type = '01' then
         v_reDKql := FPARA(p_bankid, 'DKLPATH');
    else
      return null;
    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;
function fgetDKexpfilegs(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '传入类型为空,请系统管理员检查!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '传入银行为空,请系统管理员检查!');
    end if;

    if p_type = '01' then

       v_reDKql := FPARA(p_bankid, 'DKEXP');

    else
      return null;
    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;
  function fgetDKexpfilehz(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '传入类型为空,请系统管理员检查!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '传入银行为空,请系统管理员检查!');
    end if;

    if p_type = '01' then

      v_reDKql := FPARA(p_bankid, 'DKFILETAIL');

    else
      return null;
    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;
  --取代扣导入格文件类型
  ---------------------------------------------------------------------------
  --                        取代扣导入格文件类型
  --name:fgetDKimpfiletype
  --note:取代扣导出格文件类型
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid
  --return
  --
  ---------------------------------------------------------------------------

  function fgetDKimpfiletype(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '传入类型为空,请系统管理员检查!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '传入银行为空,请系统管理员检查!');
    end if;

    if p_type = '01' then

       v_reDKql := FPARA(p_bankid, 'DKIMPTYPE');

    else
      return null;
    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;

  --取代扣导入格式字符串
  ---------------------------------------------------------------------------
  --                        取代扣导入格式字符串
  --name:fgetDKimpsqlstr
  --note:取代扣导入格式字符串
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------
  function fgetDKimpsqlstr(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '传入类型为空,请系统管理员检查!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '传入银行为空,请系统管理员检查!');
    end if;
    if p_type = '01' then

         v_reDKql := FPARA(p_bankid, 'DKIMP');

    else
      return null;
    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;

  --取代扣导出格式字符串
  ---------------------------------------------------------------------------
  --                        取代扣导出格式字符串
  --name:fgetdkexpsqlstr
  --note:取代扣导出格式字符串
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  function fgetDKexpsqlstr(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '传入类型为空,请系统管理员检查!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '传入银行为空,请系统管理员检查!');
    end if;

    if p_type = '02' then
      v_reDKql := FPARA(p_bankid, 'DK');
      ELSIF  p_type = '03' THEN
      v_reDKql := FPARA(p_bankid, 'PKDZ');
    else
      return null;
    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;

  --代扣数据导入过程
  ---------------------------------------------------------------------------
  --                        代扣数据导入过程
  --name:sq_dkfileimp
  --note:代扣数据导入过程
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  ---------------------------------------------------------------------------
  procedure sp_DKfileimp(p_batch    in varchar2,
                         p_count    in number,
                         p_lasttime in varchar2) is
    etsl     entrustlist%rowtype;
    etsltemp entrustlist%rowtype;
    etrg     entrustlog%rowtype;
    type cur is ref cursor;
    c_imp cur;
    cursor c_entruslist(batch VARCHAR2) is
      select *
        from entrustlist
       where etlbatch = batch
         and (etlsflag = 'N' and ETLPAIDFLAG = 'N');
    v_sql            varchar2(10000);
    v_sqlimpcur      varchar2(10000);
    v_multifile      varchar2(1);
    v_multiimp       varchar2(1);
    v_multisucccount number(10);
    v_allcount       number(10);
  begin
    /*    v_multifile := fsyspara('0045');
    v_multiimp  := fsyspara('0046');*/
    /*    if v_multifile is null or v_multifile not in ('Y', 'N') THEN
      raise_application_error(errcode, '代扣是否分文件对账标志设置错误!');
    END IF;*/
    /*    if v_multiimp is null or v_multiimp not in ('Y', 'N') THEN
      raise_application_error(errcode, '代扣是否多次对账标志设置错误!');
    END IF;*/
    begin
      select * into etrg from entrustlog t where t.elbatch = p_batch;
    exception
      when others then
        raise_application_error(errcode, '代扣批次不存在!');
    end;
    if etrg.elchkend = 'Y' then
      sp_cancle_dk_imp_01(p_batch, 'N');
    end if;
    v_sql := trim(fgetdkimpsqlstr('01', etrg.elbankid));
    if v_sql is null then
      raise_application_error(errcode, '代扣导入格式未定义!');
    end if;
    open c_entruslist(p_batch);
    fetch c_entruslist
      into etsl;
    if c_entruslist%notfound or c_entruslist%notfound is null then
      close c_entruslist;
      raise_application_error(errcode,
                              '代扣批次[' || p_batch || ']已经全部对帐!');
    end if;
    if c_entruslist%isopen then
      close c_entruslist;
    end if;

    open c_entruslist(p_batch);
    loop
      fetch c_entruslist
        into etsl;
      exit when c_entruslist%notfound or c_entruslist%notfound is null;

      v_sqlimpcur := replace(v_sql, '@PARM1', '''' || etsl.etlseqno || '''');
      open c_imp for v_sqlimpcur;
      fetch c_imp
        into etsltemp;
      if c_imp%rowcount > 1 then
        raise_application_error(errcode,
                                '代扣流水[' || etsltemp.etlseqno || ']重复!');
      end if;
      if c_imp%found then
        --导入检查
        if trim(etsl.etlseqno) <> trim(etsltemp.etlseqno) then
          raise_application_error(errcode,
                                  '系统流水号[' || etsl.etlseqno || ']' ||
                                  '实际系统流水号[' || etsl.etlseqno || ']' || '与[' ||
                                  etsltemp.etlseqno || ']' ||
                                  '导出文件与导入电子文档的不一致!');
        end if;
        if trim(etsl.ETLBANKIDNO) <> trim(etsltemp.ETLBANKIDNO) then
          raise_application_error(errcode,
                                  '资料号[' || etsl.ETLMCODE || ']' ||
                                  '开户银行实际编号[' || etsl.ETLBANKIDNO || ']' || '与[' ||
                                  etsltemp.ETLBANKIDNO || ']' ||
                                  '导出文件与导入电子文档的不一致!');
        end if;
        if trim(etsl.ETLACCOUNTNAME) <> trim(etsltemp.ETLACCOUNTNAME) then
          raise_application_error(errcode,
                                  '资料号[' || etsl.ETLMCODE || ']' || '开户名[' ||
                                  etsl.ETLACCOUNTNAME || ']' || '与[' ||
                                  etsltemp.ETLACCOUNTNAME || ']' ||
                                  '导出文件与导入电子文档的不一致!');
        end if;
        if etsl.ETLJE <> etsltemp.ETLJE then
          raise_application_error(errcode,
                                  '资料号[' || etsl.ETLMCODE || ']' || '扣款金额[' ||
                                  etsl.ETLJE || ']' || '与[' ||
                                  etsltemp.ETLJE || ']' ||
                                  '导出文件与导入电子文档的不一致!');
        end if;
        if etsltemp.etlsflag not in ('Y', 'N') then
          raise_application_error(errcode, '银行返回扣款成功标志错误!');
        end if;

        --扣款信息
        update entrustlist
           set etlsflag      = etsltemp.etlsflag,
               etlchkdate    = sysdate,
               etlreturncode = etsltemp.etlreturncode,
               etlreturnmsg  = etsltemp.etlreturnmsg,
               etlchrmode    = etsltemp.etlchrmode
         where etlbatch = etsl.etlbatch
           and etlseqno = etsl.etlseqno;
      end if;
      if c_imp%isopen then
        close c_imp;
      end if;
    end loop;
    v_allcount := c_entruslist%rowcount;
    if c_imp%isopen then
      close c_entruslist;
    end if;
    if c_entruslist%isopen then
      close c_entruslist;
    end if;
    if v_multisucccount >= v_allcount then
      raise_application_error(errcode, '对帐文件异常!');
    end if;
    --更新代扣头
    begin
  /*
      update entrustlog
         set elchkdate  = sysdate,
             elchkrows  = (case when v_multiimp = 'N' OR (v_multiimp = 'Y' and p_lasttime = 'Y') then etrg.eloutrows else (select count(*)
                                                                                                     from entrustlist
                                                                                                    where etlbatch =
                                                                                                          p_batch
                                                                                                      and etlsflag = 'Y') end), --对帐条数
             eloutmoney = (case when v_multiimp = 'N' OR (v_multiimp = 'Y' and p_lasttime = 'Y') then etrg.eloutmoney else (select sum(etlje)
                                                                                                      from entrustlist
                                                                                                     where etlbatch =
                                                                                                           p_batch
                                                                                                       and etlsflag = 'Y') end), --对帐金额
             elschkdate = (case when v_multifile = 'N' then sysdate else null end),
             elsrows    = (select count(*)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'Y'),
             elsje      = (select sum(etlje)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'Y'),
             elfchkdate = sysdate,
             elfrows    = (select count(*)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'N'),
             elfje      = (select sum(etlje)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'N'),
             elchknum   = nvl(elchknum, 0) + 1,
             elchkend   = (case when v_multiimp = 'N' then 'Y' when v_multiimp = 'Y' then p_lasttime end),
             ELIMPTYPE  = 2,
             ELIMFLAG   = 'Y'
       where ELBATCH = p_batch;*/

    update entrustlog
       set (elchkdate,
            elschkdate,
            ELFCHKDATE,
           eloutrows, --发出条数
           eloutmoney, --发出金额
           elchkrows, --对账总条数
           elchkje, --对账总金额
           elsrows, --银行成功条数
           elsje, --银行成功金额
           elfrows, --银行失败条数
           elfje, --银行失败金额
           elpaidrows, --本地已销账条数
           elpaidje) --本地已销账金额
           = (select sysdate,
                     sysdate,
                     sysdate,
                     count(*),
                     sum(etlje ),
                     sum(decode(etlsflag,'Y',1,0)),
                     sum(decode(etlsflag,'Y',etlje,0)),
                     sum(decode(etlsflag,'Y',1,0)),
                     sum(decode(etlsflag,'Y',etlje,0)),
                     sum(decode(etlsflag,'N',1,0)),
                     sum(decode(etlsflag,'N',etlje,0)),
                     sum(decode(el.ETLPAIDFLAG,'Y',1,0)),
                     sum(decode(ETLPAIDFLAG,'Y',etlje,0))
                from entrustlist el
               where el.etlbatch = p_batch),
              elchknum   = nvl(elchknum, 0) + 1,
             elchkend   = 'N',
             ELIMPTYPE  = 2,
             ELIMFLAG   = 'Y'
     where elbatch = p_batch;


    exception
      when others then
        raise_application_error(errcode, '更新代扣汇总信息失败!');
    end;
  exception
    when others then
      if c_entruslist%isopen then
        close c_entruslist;
      end if;
      if c_imp%isopen then
        close c_imp;
      end if;
      rollback;
      raise;
  end;

  --代扣批次销帐和解锁 by lgb 2012-09-22
  procedure sp_DKpos(p_batch  in varchar2, --代扣批次流水 序列
                     p_oper   in varchar2, ----销帐员
                     p_commit in varchar2 --提交标志
                     ) is
    v_count NUMBER(10);
    cursor c_entrustlog(vid varchar2) is
      select *
        from entrustlog
       where ELBATCH = vid
         and ELCHARGETYPE = pg_ewide_pay_01.PAYTRANS_DK; --被锁直接抛出
    elog entrustlog%rowtype;

    cursor c_entrustlist(vid varchar2) is
      select * from entrustlist where etlbatch = vid ; --被锁直接抛出
    elist entrustlist%rowtype;

    --注：回盘重复销帐规则：代扣成功金额预存
    cursor c_rl(vbatch varchar2, vseqno varchar2) is
      select *
        from reclist
       where rlentrustbatch = vbatch
         and rlentrustseqno = vseqno
         and rloutflag = 'Y'
         and rlcd = pg_ewide_pay_01.DEBIT
       order by rlid; --被锁直接抛出

    cursor c_mi(vmid varchar2) is
      select * from meterinfo where miid = vmid; --被锁直接抛出

    cursor c_ci(vcid varchar2) is
      select * from custinfo where ciid = vcid; --被锁直接抛出

    i          number;
    mi         meterinfo%rowtype;
    vp         payment%rowtype;
    rl         reclist%rowtype;
    pl         paidlist%rowtype;
    ci         custinfo%rowtype;
    vpiid      varchar2(100);
    vznj       varchar2(100);
    vplje      number;
    vpid       varchar2(10); --预存返回pid
    v_sxfcount number(10); --手续费回到第一条应收对应的实收上
    v_sxf      number(12, 2); --手续费
    V_RET      VARCHAR2(5);
  begin
    for i in 1 .. tools.FboundPara(p_batch) loop
      --取发出批次信息
      open c_entrustlog(tools.FGetPara(p_batch, i, 1));
      fetch c_entrustlog
        into elog;
      if c_entrustlog%notfound or c_entrustlog%notfound is null then
        raise_application_error(errcode, '无效的代扣批次' || p_batch);
      end if;
      --游标批次下明细流水
      open c_entrustlist(elog.elbatch);
      fetch c_entrustlist
        into elist;
      if c_entrustlist%notfound or c_entrustlist%notfound is null then
        raise_application_error(errcode, '无效的代扣批次明细' || p_batch);
      end if;
      while c_entrustlist%found loop
        if elist.etlpaidflag = 'N' and elist.etlsflag = 'Y' then

          ------------------------------
          --游标批次、明细流水下应收流水（考虑合帐代扣）
          vplje      := 0; --累计销帐金额
          v_sxfcount := 0;
          open c_rl(elist.etlbatch, elist.etlseqno);
          fetch c_rl
            into rl;
          if c_rl%notfound or c_rl%notfound is null then
            NULL;
            --raise_application_error(errcode,'无效的代扣应收帐记录'||elist.etlbatch||','||elist.etlseqno);
          end if;
          while c_rl%found and rl.rlpaidflag = 'N' loop

            --手续费控制
            if v_sxfcount = 0 then
              v_sxfcount := v_sxfcount + 1;
              v_sxf      := 0;
            else
              v_sxf := elist.etlsxf;
            end if;
            V_RET := PG_ewide_PAY_01.pos('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                         elog.elbankid, --缴费机构
                                         p_oper, --收款员
                                         rl.rlid || '|', --应收流水
                                         rl.rlje, --应收金额
                                         rl.rlznj, --销帐违约金
                                         v_sxf, --手续费
                                         RL.RLJE + RL.RLZNJ + v_sxf, --实际收款
                                         PG_ewide_PAY_01.PAYTRANS_DK, --缴费事务
                                         rl.rlmid, --户号
                                         'HZ', --付款方式
                                         rl.rlsmfid, --缴费地点
                                         FGETSEQUENCE('ENTRUSTLOG'), --缴费事务流水
                                         'N', --是否打票  Y 打票，N不打票， R 应收票
                                         '', --发票号
                                         'N' --控制是否提交（Y/N）
                                         );
             if V_RET<>'000' then
              raise_application_error(errcode, '销账失败' || p_batch);
            end if;
            --累计销帐金额
            vplje := vplje + RL.RLJE + RL.RLZNJ + v_sxf;
            fetch c_rl
              into rl;
          end loop;
          close c_rl;
          if elist.etlje > vplje then
            --多出补预存

            V_RET := PG_ewide_PAY_01.pos('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                         elog.elbankid, --缴费机构
                                         p_oper, --收款员
                                         NULL, --应收流水
                                         0, --应收金额
                                         0, --销帐违约金
                                         0, --手续费
                                         elist.etlje - vplje, --实际收款
                                         'S', --缴费事务
                                         rl.rlmid, --户号
                                         'HZ', --付款方式
                                         elog.elbankid, --缴费地点
                                         elist.etlbatch, --缴费事务流水
                                         'N', --是否打票  Y 打票，N不打票， R 应收票
                                         '', --发票号
                                         'N' --控制是否提交（Y/N）
                                         );
           if V_RET<>'000' then
              raise_application_error(errcode, '销账失败' || p_batch);
            end if;
          end if;

              --回写elist,elog
          update entrustlist
             set etlpaiddate = vp.pdatetime, etlpaidflag = 'Y'
           where etlbatch = elist.etlbatch
             and etlseqno = elist.etlseqno;
          update entrustlog
             set elpaiddate = vp.pdatetime,
                 elpaidrows = nvl(elpaidrows, 0) + 1,
                 elpaidje   = nvl(elpaidje, 0) + elist.etlje
           where elbatch = elist.etlbatch;
          update reclist
             set rloutflag = 'N'
           where rlentrustbatch = elist.etlbatch
             and rlentrustseqno = elist.etlseqno;

        else
          --elist游标内若最后返盘则解锁应收，否则只解锁代扣成功的应收
          update reclist
             set rloutflag = 'N',
                 rlznj=  0
           where rlentrustbatch = elist.etlbatch
             and rlentrustseqno = elist.etlseqno;
        end if;
        fetch c_entrustlist
          into elist;
      end loop;
      close c_entrustlist;
      close c_entrustlog;

      --如果银行销帐条数等于本地销帐时,结束终止导入标志
      select count(*)
        into v_count
        from entrustlog
       where elbatch = tools.FGetPara(p_batch, i, 1)
         and ELSROWS = ELPAIDROWS;

      if v_count > 0 then
        update entrustlog
           set ELCHKEND = 'Y'
         where elbatch = tools.FGetPara(p_batch, i, 1)
           and ELSROWS = ELPAIDROWS;
      end if;

    end loop;
    if p_commit = 'Y' then
      commit;
    end if;
  exception
    when others then
      if c_entrustlog%isopen then
        close c_entrustlog;
      end if;
      if c_entrustlist%isopen then
        close c_entrustlist;
      end if;
      if c_rl%isopen then
        close c_rl;
      end if;
      if c_mi%isopen then
        close c_mi;
      end if;
      if c_ci%isopen then
        close c_ci;
      end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  procedure sp_DK_exp(p_type  in varchar2, --导出类
                                   p_batch in varchar2, --导出批次
                                    o_base  out tools.out_base) is
  v_sqlstr  varchar2(2000);
  v_bankid  varchar2(10);
  v_tempstr varchar2(30000);
  v_clob     clob;
  EF        ENTRUSTFILE%rowtype;
  etlog     entrustlog%rowtype;
  type cur is ref cursor;
  c_cdk cur;
  v_smfid   varchar2(2000);
  v_smfname varchar2(2000);
  v_smppvalue1 varchar2(2000);
  v_smppvalue2 varchar2(2000);
cursor  c_ftppath(vsmfid in varchar2 ) is
      select smfid,smfname,b.smppvalue,a.smppvalue
        from sysmanaframe,sysmanapara a,sysmanapara b
        where smfid=a.smpid and smfid=b.smpid and
             a.smppid='FTPDKDIR' and b.smppid='FTPDKSRV'
             and smfid=vsmfid ;

begin
  begin
    select * into etlog from entrustlog where elbatch = p_batch and ELOUTMONEY > 0 ;
  exception
    when others then
      return;
      raise_application_error(-20012, '代扣批次不存在,请检查!');
  end;
  if FSYSPARA('DK01')='Y' then
  v_bankid := etlog.elbankid;
  v_sqlstr := pg_ewide_DK_01.fgetDKexpsqlstr(p_type, v_bankid);
  else
     v_sqlstr := FSYSPARA('0044');
  end if;

  if v_sqlstr is null then
      return ;
    raise_application_error(-20012, '该银行代扣格式未定义请检查!');
  end if;
  v_sqlstr := replace(v_sqlstr, '@PARM1', '''' || p_batch || '''');
  if p_type = '01' then
    open o_base for v_sqlstr;
  elsif p_type = '02' then
    dbms_lob.createtemporary(v_clob,TRUE);
    open c_cdk for 'select c1 from ( '||v_sqlstr||' )' ;
    loop
      fetch c_cdk
        into v_tempstr;
      exit when c_cdk%notfound or c_cdk%notfound is null;
      v_tempstr:=v_tempstr||chr(13)||chr(10);
      dbms_lob.writeappend(v_clob, LENGTH(v_tempstr), v_tempstr);
    end loop;
    close c_cdk;
    open c_ftppath(etlog.elbankid);
        fetch c_ftppath into v_smfid,v_smfname,v_smppvalue1,v_smppvalue2 ;
        if  c_ftppath%found  then
          select  SEQ_ENTRUSTFILE.NEXTVAL into EF.EFID  from dual;
              --EF.EFID                     :=   ;--代扣文档流水
              EF.EFSRVID                  :=  v_smppvalue1 ;--存放机器标识（文件服务本地pfile.ini中标识）
              EF.EFPATH                   :=  v_smppvalue2 ;--存放路径
              EF.EFFILENAME               :=  fgetDKexpname('01' ,etlog.elbankid, p_batch  )||'.TXT' ;--代扣文档名
              EF.EFELBATCH                := p_batch  ;--代扣批次
              EF.EFFILEDATA               := c2b(v_clob) ; --v_cdk.c1 ;--代扣文档
              EF.EFSOURCE                 := '自来水公司系统自动生成'  ;--文档来源
              EF.EFNEWDATETIME            := sysdate ;--文档创建时间
              --EF.EFSYNDATETIME            :=  ;--文档同步时间
              EF.EFFLAG                   := '0' ;--文档标志位
              --EF.EFREADDATETIME           :=  ;--文档访问时间
              EF.EFMEMO                   := '自来水公司系统自动生成' ;--文档说明

             insert into  ENTRUSTFILE values EF;
             --插入空文件
             select  SEQ_ENTRUSTFILE.NEXTVAL into EF.EFID  from dual;
             EF.EFFILENAME               := EF.EFFILENAME ||'.CHK';
             EF.EFFILEDATA               := c2b('0') ; --v_cdk.c1 ;--代扣文档
             insert into  ENTRUSTFILE values EF;
             commit;
        end if;
   close c_ftppath;

  else
    return;
    --raise_application_error(-20012, '暂不支持此类型银行代扣数据导出!');
  end if;
exception
  when others then
  if c_cdk%isopen then
    close c_cdk;
  end if;
  if c_ftppath%isopen then
    close c_ftppath;
  end if;
  rollback;
end;

---银行批扣（20121204）
procedure sp_YHPLDK_exp(p_type  in varchar2, --导出类
                                   p_batch in varchar2, --导出批次
                                    p_filename in varchar2, ---文件名称
                                    o_base  out tools.out_base) is
  v_sqlstr  varchar2(2000);
  v_bankid  varchar2(10);
  v_tempstr varchar2(30000);
  v_clob     clob;
  EF        ENTRUSTFILE%rowtype;
  etlog     entrustlog%rowtype;
  type cur is ref cursor;
  c_cdk cur;
  v_smfid   varchar2(2000);
  v_smfname varchar2(2000);
  v_smppvalue1 varchar2(2000);
  v_smppvalue2 varchar2(2000);
cursor  c_ftppath(vsmfid in varchar2 ) is
      select smfid,smfname,b.smppvalue,a.smppvalue
        from sysmanaframe,sysmanapara a,sysmanapara b
        where smfid=a.smpid and smfid=b.smpid and
             a.smppid='FTPDKDIR' and b.smppid='FTPDKSRV'
             and smfid=vsmfid ;

begin
  begin
    select * into etlog from entrustlog where elbatch = p_batch and ELOUTMONEY > 0 ;
  exception
    when others then
      return;
      raise_application_error(-20012, '代扣批次不存在,请检查!');
  end;
  if FSYSPARA('DK01')='Y' then
       v_bankid := etlog.elbankid;
      v_sqlstr := pg_ewide_DK_01.fgetDKexpsqlstr(p_type, v_bankid);
  else
     v_sqlstr := FSYSPARA('0044');
  end if;

  if v_sqlstr is null then
      return ;
    raise_application_error(-20012, '该银行代扣格式未定义请检查!');
  end if;
  v_sqlstr := replace(v_sqlstr, '@PARM1', '''' || p_batch || '''');
  if p_type = '01' then
    open o_base for v_sqlstr;
  elsif p_type = '02' then
    dbms_lob.createtemporary(v_clob,TRUE);
    open c_cdk for 'select c1 from ( '||v_sqlstr||' )' ;
    loop
      fetch c_cdk
        into v_tempstr;
      exit when c_cdk%notfound or c_cdk%notfound is null;
      v_tempstr:=v_tempstr||chr(13)||chr(10);
      dbms_lob.writeappend(v_clob, LENGTH(v_tempstr), v_tempstr);
    end loop;
    close c_cdk;
    open c_ftppath(etlog.elbankid);
        fetch c_ftppath into v_smfid,v_smfname,v_smppvalue1,v_smppvalue2 ;
        if  c_ftppath%found  then
          select  SEQ_ENTRUSTFILE.NEXTVAL into EF.EFID  from dual;
              --EF.EFID                     :=   ;--代扣文档流水
              EF.EFSRVID                  :=  v_smppvalue1 ;--存放机器标识（文件服务本地pfile.ini中标识）
              EF.EFPATH                   :=  v_smppvalue2 ;--存放路径
              EF.EFFILENAME               :=  p_filename ;--代扣文档名
              EF.EFELBATCH                := p_batch  ;--代扣批次
              EF.EFFILEDATA               := c2b(v_clob) ; --v_cdk.c1 ;--代扣文档
              EF.EFSOURCE                 := '自来水公司系统自动生成'  ;--文档来源
              EF.EFNEWDATETIME            := sysdate ;--文档创建时间
              --EF.EFSYNDATETIME            :=  ;--文档同步时间
              EF.EFFLAG                   := '0' ;--文档标志位
              --EF.EFREADDATETIME           :=  ;--文档访问时间
              EF.EFMEMO                   := '自来水公司系统自动生成' ;--文档说明

             insert into  ENTRUSTFILE values EF;
             --插入空文件
          /*   select  SEQ_ENTRUSTFILE.NEXTVAL into EF.EFID  from dual;
             EF.EFFILENAME               := EF.EFFILENAME ||'.CHK';
             EF.EFFILEDATA               := c2b('0') ; --v_cdk.c1 ;--代扣文档
             insert into  ENTRUSTFILE values EF;*/
             commit;
        end if;
   close c_ftppath;

  else
    return;
    --raise_application_error(-20012, '暂不支持此类型银行代扣数据导出!');
  end if;
exception
  when others then
  if c_cdk%isopen then
    close c_cdk;
  end if;
  if c_ftppath%isopen then
    close c_ftppath;
  end if;
  rollback;
end;


---银行批扣对账（20121211）
procedure sp_yhpkdz_exp(p_type  in varchar2, --导出类
                                     p_batch in varchar2, --导出批次
                                     p_filename in varchar2 ---文件名称
                              ) is
  v_sqlstr  varchar2(2000);
  v_bankid  varchar2(10);
  v_tempstr varchar2(30000);
  v_clob     clob;
  EF        ENTRUSTFILE%rowtype;
  etlog     entrustlog%rowtype;
  type cur is ref cursor;
  c_cdk cur;
  v_smfid   varchar2(2000);
  v_smfname varchar2(2000);
  v_smppvalue1 varchar2(2000);
  v_smppvalue2 varchar2(2000);
cursor  c_ftppath(vsmfid in varchar2 ) is
      select smfid,smfname,b.smppvalue,a.smppvalue
        from sysmanaframe,sysmanapara a,sysmanapara b
        where smfid=a.smpid and smfid=b.smpid and
             a.smppid='FTPDKDIR' and b.smppid='FTPDKSRV'
             and smfid=vsmfid ;

begin
  begin
    select * into etlog from entrustlog where elbatch = p_batch and ELOUTMONEY > 0 ;
  exception
    when others then
      return;
      raise_application_error(-20012, '代扣批次不存在,请检查!');
  end;
  if FSYSPARA('DK01')='Y' then
       v_bankid := etlog.elbankid;
       v_sqlstr := pg_ewide_DK_01.fgetDKexpsqlstr(p_type, v_bankid);
  else
     v_sqlstr := FSYSPARA('0044');
  end if;

  if v_sqlstr is null then
      return ;
    raise_application_error(-20012, '该银行代扣格式未定义请检查!');
  end if;
  v_sqlstr := replace(v_sqlstr, '@PARM1', '''' || p_batch || '''');

 if p_type = '03' then
    dbms_lob.createtemporary(v_clob,TRUE);
    open c_cdk for 'select c1 from ( '||v_sqlstr||' )' ;
    loop
      fetch c_cdk
        into v_tempstr;
      exit when c_cdk%notfound or c_cdk%notfound is null;
      v_tempstr:=v_tempstr||chr(13)||chr(10);
      dbms_lob.writeappend(v_clob, LENGTH(v_tempstr), v_tempstr);
    end loop;
    close c_cdk;
    open c_ftppath(etlog.elbankid);
        fetch c_ftppath into v_smfid,v_smfname,v_smppvalue1,v_smppvalue2 ;
        if  c_ftppath%found  then
          select  SEQ_ENTRUSTFILE.NEXTVAL into EF.EFID  from dual;
              --EF.EFID                     :=   ;--代扣文档流水
              EF.EFSRVID                  :=  v_smppvalue1 ;--存放机器标识（文件服务本地pfile.ini中标识）
              EF.EFPATH                   :=  v_smppvalue2 ;--存放路径
              EF.EFFILENAME               :=  p_filename ;--代扣文档名
              EF.EFELBATCH                := p_batch  ;--代扣批次
              EF.EFFILEDATA               := c2b(v_clob) ; --v_cdk.c1 ;--代扣文档
              EF.EFSOURCE                 := '自来水公司系统自动生成'  ;--文档来源
              EF.EFNEWDATETIME            := sysdate ;--文档创建时间
              --EF.EFSYNDATETIME            :=  ;--文档同步时间
              EF.EFFLAG                   := '0' ;--文档标志位
              --EF.EFREADDATETIME           :=  ;--文档访问时间
              EF.EFMEMO                   := '自来水公司系统自动生成' ;--文档说明

             insert into  ENTRUSTFILE values EF;
             --插入空文件
          /*   select  SEQ_ENTRUSTFILE.NEXTVAL into EF.EFID  from dual;
             EF.EFFILENAME               := EF.EFFILENAME ||'.CHK';
             EF.EFFILEDATA               := c2b('0') ; --v_cdk.c1 ;--代扣文档
             insert into  ENTRUSTFILE values EF;*/
             commit;
        end if;
   close c_ftppath;

  else
    return;
    --raise_application_error(-20012, '暂不支持此类型银行代扣数据导出!');
  end if;
exception
  when others then
  if c_cdk%isopen then
    close c_cdk;
  end if;
  if c_ftppath%isopen then
    close c_ftppath;
  end if;
  rollback;
end;


end;
/

