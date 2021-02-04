CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_RHZS_01" is
  CurrentDate date := tools.fGetSysDate;



  ---------------------------------------------------------------------------
  --name:sp_create_rhzs
  --note:M:入户直收
  --author:wy
  --date：2011/10/19
  --input: p_micode   --水表号
  --       p_mibfid   --表册号
  --       p_miCHARGEPER  --催费员
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志
  --说明：入户直收不收滞金,不收手续费


  ---------------------------------------------------------------------------
    PROCEDURE sp_create_rhzs(
                         p_micode in varchar2, --水表号
                         p_mibfid in varchar2,--表册号
                         p_MICPER in varchar2,--催费员
                         p_mfsmfid in varchar2,--营业所代码
                         p_oper    in varchar2,--操作员
                         p_srldate in varchar2,--起始帐务日期 格式: yyyymmdd
                         p_erldate in varchar2,--终止帐务日期 格式: yyyymmdd
                         p_smon    in varchar2,--起始帐务月份 格式: yyyy.mm
                         p_emon    in varchar2,--终止帐务月份 格式: yyyy.mm
                         p_sftype  in varchar2,--银行缴费类型 D:代扣 ,T 托收,M 入户直收
                         p_commit  in varchar2,--提交标志
                         o_batch   out varchar2
                         )
is
begin

    sp_create_rhzs_rlid_01(p_micode  ,
                           p_mibfid  ,
                           p_MICPER   ,
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
  --name:sp_create_rhzs_rlid_01
  --note:M:入户直收
  --author:wy
  --date：2011/10/19
  --input: p_micode   --水表号
  --       p_mibfid   --表册号
  --       p_miCHARGEPER  --催费员
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志
  --说明：入户直收不收滞金,不收手续费
  ---------------------------------------------------------------------------
  PROCEDURE sp_create_rhzs_rlid_01(
                                     p_micode in varchar2, --水表号
                                     p_mibfid in varchar2,--表册号
                                     p_MICPER in varchar2,--催费员
                                     p_mfsmfid in varchar2,--营业所代码
                                     p_oper    in varchar2,--操作员
                                     p_srldate in varchar2,--起始帐务日期 格式: yyyymmdd
                                     p_erldate in varchar2,--终止帐务日期 格式: yyyymmdd
                                     p_smon    in varchar2,--起始帐务月份 格式: yyyy.mm
                                     p_emon    in varchar2,--终止帐务月份 格式: yyyy.mm
                                     p_sftype  in varchar2,--银行缴费类型 D:代扣 ,T 托收,M 入户直收
                                     p_commit  in varchar2,--提交标志
                                     o_batch   out varchar2
                                         ) is
    EL ENTRUSTLIST%ROWTYPE;
    eg entrustlog%ROWTYPE;
    mi meterinfo%rowtype;

    rl reclist%rowtype;
    ma meteraccount%rowtype;
    cursor c_ysz is
      select rlid, --应收流水
             miid, --水表号
             micode, --客户代码



             rlje, --应收金额
             rlzndate, --滞纳金起算日
/*             PG_EWIDE_PAY_01.getznjadj(mismfid,
                                       rlje,
                                       rlgroup,
                                       rlzndate,
                                       mismfid,
                                       sysdate), --滞纳金*/
                0,   --滞纳金
             rlmonth, --应收帐月份
             RLCADR, --用户地址
             rlmadr, --水表地址
             rlcname, --产权名
             rlmonth --应收帐月份
        from   meterinfo t1,   reclist t
       WHERE
           miid = rlmid
         and  ((micode = p_micode and p_micode is not null) or
             p_micode is null)
         and  ((mibfid = p_mibfid and p_mibfid is not null) or
             p_mibfid is null)
         and  ((t1.MICPER  = p_MICPER and p_MICPER is not null) or
             p_MICPER is null)
         and rloutflag='N'
         and rlje>0
         and rlcd='DE'
         and rlpaidflag='N'
         and ((mismfid = p_mfsmfid and p_mfsmfid is not null) or
             p_mfsmfid is null)
         and t1.michargetype = p_sftype
         and ((rlmonth >= p_smon and p_smon is not null) or p_smon is null)
         and ((rlmonth <= p_emon and p_emon is not null) or p_emon is null)
         and ((rldate >= p_srldate and p_srldate is not null) or
             p_srldate is null)
         and ((rldate <= p_erldate and p_erldate is not null) or
             p_erldate is null);
  begin
    if p_sftype<>'M' THEN
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
      --EL.ETLBANKID      := ma.mabankid; --代扣银行
      --EL.ETLACCOUNTNO   := ma.maaccountno; --开户帐号
      --EL.ETLACCOUNTNAME := ma.maaccountname; --开户名

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
      EL.ETLIFINV              := 0;--发票是否已打印（发票托收凭证）

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
      --eg.ELBANKID     := p_bankid; --代扣文档银行
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

---------------------------------------------------------------------------
  --                        撤销总过程入户直收批次数据
  --name:sp_cancle_rhzs
  --note:撤销入户直收批次数据
  --author:wy
  --date：2009/04/26
  --input: p_entrust_batch 入户直收
  --p_oper in varchar2,操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  procedure sp_cancle_rhzs(p_entrust_batch in varchar2,
                              p_oper in varchar2,--操作员
                               p_commit        in varchar2)
                               IS
    BEGIN
      sp_cancle_rhzs_batch_01(p_entrust_batch  ,
                               p_oper,
                               p_commit     );
    exception
    when others then
      rollback;
      raise;
    END;
---------------------------------------------------------------------------
  --                        撤销入户直收批次数据
  --name:sp_cancle_rhzs_batch_01
  --note:撤销代扣批次数据
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_dk_batch_01 入户直收批次号
  --p_oper in varchar2,--操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  procedure sp_cancle_rhzs_batch_01(p_entrust_batch in varchar2,
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
   --删除托收的中间表
    delete  entrustlist  where  etlbatch =p_entrust_batch;

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
  --                        撤销入户直收批次流水数据
  --name:sp_cancle_rhzs_entpzseqno_01
  --note:撤销入户直收批次流水数据
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_rhzs_entpzseqno_01  批次号
   --     p_enterst_pzseqno  in varchar2,流水号
   --      p_oper in varchar2,--操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  procedure sp_cancle_rhzs_entpzseqno_01(p_entrust_batch in varchar2,
                                 p_enterst_pzseqno  in varchar2,
                                 p_oper in varchar2,--操作员
                                 p_commit        in varchar2) is

    v_ts_log  entrustlog%rowtype; --入户直收日志
    v_ts_list entrustlist%rowtype;--入户直收凭证
    --v_rl      reclist%rowtype; --应收
    --v_rd      recdetail%rowtype;--应收明细
    v_je      number(12,2);
    V_TEST   VARCHAR2(10);
  begin
    IF p_entrust_batch IS NULL THEN
      V_TEST := '000';
    END IF;
    begin
      select *
        into v_ts_log
        from entrustlog
       where elbatch = p_entrust_batch;
    exception
      when others then
        raise_application_error(errcode,
                                '批次号[' || p_entrust_batch || ']不存在,请检查!');
    end;
    begin
       select *
        into v_ts_list
        from entrustlist
       where ETLBATCH = p_entrust_batch and ETLSEQNO = p_enterst_pzseqno;
    exception
      when others then
        raise_application_error(errcode,
                                '批次号[' || p_entrust_batch ||'中托收流水'||p_enterst_pzseqno|| ']不存在,请检查!');
    end;
    --撤销检查
    if v_ts_log.elstatus = 'N' then
      raise_application_error(errcode,
                              '批次号[' || p_entrust_batch || ']已作废,无需再次作废!');
    end if;
/*    if v_ts_log.elchknum > 0 or v_ts_log.elchkend='Y'  then
        sp_cancle_ts_imp_01(p_entrust_batch,'N');
      --RAISE_application_error(errcode, '该托收批次[' || p_entrust_batch || ']已经导入，不能撤销！');
    end if;*/
    /*--清空应收账发出流水,批次号,发出标志
    update recdetail set rdznj=0
    where rdid in (
    select rlid from reclist WHERE RLENTRUSTBATCH = p_entrust_batch and  RLENTRUSTSEQNO = p_enterst_pzseqno
    )
    and rdpaidflag='N' ;*/

    update reclist
       set RLENTRUSTBATCH = null, RLENTRUSTSEQNO = null, RLOUTFLAG = 'N',RLZNJ =0
     WHERE RLENTRUSTBATCH = p_entrust_batch and RLENTRUSTSEQNO = p_enterst_pzseqno;
    --更新托收发出日志
    select ETLJE into v_je from entrustlist where etlbatch =p_entrust_batch and ETLSEQNO=p_enterst_pzseqno;
    update entrustlog
       set ELFROWS = nvl(ELFROWS,0) -1 ,ELFJE = nvl(ELFJE,0) - v_je,
       ELOUTROWS = nvl(ELOUTROWS,0) -1 ,eloutmoney = nvl(eloutmoney ,0) - v_je
     where elbatch = p_entrust_batch;


  ---插入日志表
   insert into etldelbak
    select p_oper, sysdate, t.* from entrustlist t where etlbatch = p_entrust_batch;

      --删除托收的中间表
    delete  entrustlist  where  etlbatch =p_entrust_batch;


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



end;
/

