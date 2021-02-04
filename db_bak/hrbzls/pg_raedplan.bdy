CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_RAEDPLAN" is
  CurrentDate date := tools.fGetSysDate;

  msl meter_static_log%rowtype;
  /*
  表册管理页面提交处理
  参数：p_mtab： 临时表类型(PBPARMTEMP.c1)，存放调段后目标表册中所有水表编号c1,抄表次序c2
        p_smfid: 目标营业所
        p_bfid:  目标表册
        p_oper： 操作员ID
  处理：1、更新抄表次序
        2、更新表册
        3、户号（表本页号）初始化
        4、生成系统变更单，形成历史变更数据
  输出：无
  */
  procedure meterbook(p_smfid in varchar2,
                      p_bfid  in varchar2,
                      p_oper  in varchar2) is
    cursor c_mtab is
      select c1, c2, c3, c4 from pbparmtemp order by to_number(C2);

    pval      PBPARMTEMP%rowtype;
    cch       custchangehd%rowtype;
    mi        meterinfo%rowtype;
    vmiseqno  varchar2(20);
    vmiseqno1 varchar2(20);
    n         integer;
    bf        bookframe%rowtype;
  begin
    select *
      into bf
      from bookframe
     where bfsmfid = p_smfid
       and bfid = p_bfid;
    --关闭临时表游标前不能commit语句,否者临时表清空
   /* Tools.SP_BillSeq('003', cch.cchno, 'N');
    --生成已审核变更单
    cch.cchbh      := cch.cchno;
    cch.cchlb      := 'B';
    cch.cchsource  := '2';
    cch.cchsmfid   := p_smfid;
    cch.cchdept    := null;
    cch.cchcredate := sysdate;
    cch.cchcreper  := p_oper;
    cch.cchshdate  := sysdate;
    cch.cchshper   := p_oper;
    cch.cchshflag  := 'Y';
    cch.cchwfid    := null;
    insert into custchangehd values cch;*/
    --更新户号，加工PBPARMTEMP.c3，规则：
    --末尾追加(加入新表的位置后无原册表)
    --中间插入(加入新表的位置后有原册表)
    n := 0;
    open c_mtab;
    loop
      fetch c_mtab
        into pval.c1, pval.c2, pval.c3, pval.c4;
      exit when c_mtab%notfound or c_mtab%notfound is null;
      begin
        select * into mi from meterinfo where miid = pval.c1;
      exception
        when others then
          raise_application_error(ErrCode, '无效的水表编号' || pval.c1);
      end;

      if mi.mibfid <> p_bfid or mi.mibfid is null then
        n := n + 1;
        update PBPARMTEMP
           set c3 = vmiseqno1, c4 = to_char(n)
         where c1 = pval.c1;
      else
        vmiseqno1 := mi.miseqno;
        n         := 0;
      end if;
    end loop;
    close c_mtab;

    open c_mtab;
    loop
      fetch c_mtab
        into pval.c1, pval.c2, pval.c3, pval.c4;
      exit when c_mtab%notfound or c_mtab%notfound is null;
      begin
        select * into mi from meterinfo where miid = pval.c1;
      exception
        when others then
          raise_application_error(ErrCode, '无效的水表编号' || pval.c1);
      end;
      if pval.c4 is not null then
        if instr(pval.c3, '-') > 0 then
          vmiseqno := substr(pval.c3, 1, instr(pval.c3, '-') - 1) || '-' ||
                      to_char(to_number(substr(pval.c3,
                                               instr(pval.c3, '-') + 1)) +
                              to_number(pval.c4));
        elsif pval.c3 is null then
          if vmiseqno1 is not null then
            vmiseqno := p_bfid || '-' || pval.c4;
          else
            vmiseqno := p_bfid || lpad(pval.c4, 3, '0');
          end if;
        else
          vmiseqno := pval.c3 || '-' || pval.c4;
        end if;
      else
        vmiseqno := mi.miseqno;
      end if;
 /*
      insert into custchangedt
        select cch.cchno,
               to_number(pval.c2),
               ci.ciid, --用户编号
               ci.cicode, --用户号
               ci.ciconid, --报装合同编号
               ci.cismfid, --营销公司
               ci.cipid, --上级用户编号
               ci.ciclass, --用户级次
               ci.ciflag, --末级标志
               ci.ciname, --用户名称
               ci.ciname2, --曾用名
               ci.ciadr, --用户地址
               ci.cistatus, --用户状态
               ci.cistatusdate, --状态日期
               ci.cistatustrans, --状态表务
               ci.cinewdate, --立户日期
               ci.ciidentitylb, --证件类型
               ci.ciidentityno, --证件号码
               ci.cimtel, --移动电话
               ci.citel1, --固定电话1
               ci.citel2, --固定电话2
               ci.citel3, --固定电话3
               ci.ciconnectper, --联系人
               ci.ciconnecttel, --联系电话
               ci.ciifinv, --是否普票
               ci.ciifsms, --是否提供短信服务
               ci.ciifzn, --是否滞纳金
               ci.ciprojno, --工程编号
               ci.cifileno, --档案号
               ci.cimemo, --备注信息
               ci.cideptid, --立户部门
               mi.micid, --用户编号
               mi.miid, --水表编号
               mi.miadr, --表地址
               bf.bfsafid, --区域
               mi.micode, --水表手工编号
               mi.mismfid, --营销公司
               mi.miprmon, --上期抄表月份
               mi.mirmon, --本期抄表月份
               \*变更列*\
               (case
                 when lower(p_bfid) = 'null' then
                  null
                 else
                  p_bfid
               end), --表册
               \*变更列*\
               (case
                 when lower(p_bfid) = 'null' then
                  null
                 else
                  to_number(pval.c2)
               end), --抄表次序
               mi.mipid, --上级水表编号
               mi.miclass, --水表级次
               mi.miflag, --末级标志
               mi.mirtid, --抄表方式
               mi.miifmp, --混合用水标志
               mi.miifsp, --例外单价标志
               mi.mistid, --行业分类
               mi.mipfid, --价格分类
               mi.mistatus, --有效状态
               mi.mistatusdate, --状态日期
               mi.mistatustrans, --状态表务
               mi.miface, --表况
               mi.mirpid, --计件类型
               mi.miside, --表位
               mi.miposition, --水表接水地址
               mi.miinscode, --新装起度
               mi.miinsdate, --装表日期
               mi.miinsper, --安装人
               mi.mireinscode, --换表起度
               mi.mireinsdate, --换表日期
               mi.mireinsper, --换表人
               mi.mitype, --类型
               mi.mircode, --本期读数
               mi.mirecdate, --本期抄见日期
               mi.mirecsl, --本期抄见水量
               mi.miifcharge, --是否计费
               mi.miifsl, --是否计量
               mi.miifchk, --是否考核表
               mi.miifwatch, --是否节水
               mi.miicno, --ic卡号
               mi.mimemo, --备注信息
               mi.mipriid, --合收表主表号
               mi.mipriflag, --合收表标志
               mi.miusenum, --户籍人数
               mi.michargetype, --收费方式
               mi.misaving, --预存款余额
               mi.milb, --水表类别
               mi.minewflag, --新表标志
               mi.micper, --收费员
               mi.miiftax, --是否税票
               mi.mitaxno, --税号
               mi.micid,
               pval.c1,
               null,
               null,
               null,
               md.mdmid,
               md.mdno,
               md.mdcaliber,
               md.mdbrand,
               md.mdmodel,
               md.mdstatus,
               md.mdstatusdate,
               ma.mamid, --水表资料号
               ma.mano, --委托授权号
               ma.manoname, --签约户名
               ma.mabankid, --开户行（代托）
               ma.maaccountno, --开户帐号（代托）
               ma.maaccountname, --开户名（代托）
               ma.matsbankid, --接收行号（托）
               ma.matsbankname, --凭证银行（托）
               ma.maifxezf, --小额支付（托）
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               'Y',
               sysdate,
               p_oper,
               mi.miifckf, --是否磁控阀
               mi.migps, --gps地址
               mi.miqfh, --铅封号
               mi.mibox, --表箱规格
               null,
               null,
               null,
               ma.maregdate, --签约日期
               mi.miname, --票据名称
               mi.miname2, --招牌名称
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               \*变更列*\
               vmiseqno --户号
              ,
               mi.mijfkrow,
               mi.miuiid
          from custinfo ci, meterinfo mi, meterdoc md, meteraccount ma
         where mi.micid = ci.ciid
           and mi.miid = md.mdmid
           and mi.miid = ma.mamid(+)
           and mi.miid = pval.c1;

*/
     --------------------------------------------------------
      --记录水表日志并提交统计
      msl              := null;
      msl.客户代码     := mi.micode;
      msl.产权名       := fgetcustname(mi.micid);
      msl.水表地址     := mi.miadr;
      msl.事务代码     := '表册维护';
      msl.原区域       := fgetmeterinfo(mi.miid, 'BFSAFID');
      msl.原营销公司   := mi.mismfid;
      msl.原抄表方式   := mi.mirtid;
      msl.原水表口径   := fgetmetercabiler(mi.miid);
      msl.原行业分类   := mi.mistid;
      msl.原水表类型   := mi.mitype;
      msl.原考核表标志 := mi.miifchk;
      msl.原收费方式   := mi.michargetype;
      msl.原水表类别   := mi.milb;
      msl.原用水大类   := fpriceframejcbm(mi.mipfid, 1);
      msl.原用水中类   := fpriceframejcbm(mi.mipfid, 2);
      msl.原用水小类   := mi.mipfid;
      msl.原表位       := mi.miside;
      msl.原表册       := mi.mibfid;
      msl.原立户日期   := trunc(mi.minewdate);
      --------------------------------------------------------
      --更新相关表
      update meterinfo
         set mibfid   = p_bfid,
             mirorder = to_number(pval.c2),
             miseqno  = vmiseqno
       where miid = pval.c1;
      --------------------------------------------------------
      --记录水表日志并提交统计
      msl.新区域       := fgetmeterinfo(mi.miid, 'BFSAFID');
      msl.新营销公司   := msl.原营销公司;
      msl.新抄表方式   := msl.原抄表方式;
      msl.新水表口径   := msl.原水表口径;
      msl.新行业分类   := msl.原行业分类;
      msl.新水表类型   := msl.原水表类型;
      msl.新考核表标志 := msl.原考核表标志;
      msl.新收费方式   := msl.原收费方式;
      msl.新水表类别   := msl.原水表类别;
      msl.新用水大类   := msl.原用水大类;
      msl.新用水中类   := msl.原用水中类;
      msl.新用水小类   := msl.原用水小类;
      msl.新表位       := msl.原表位;
      msl.新表册       := p_bfid;
      msl.新立户日期   := msl.原立户日期;

      PG_ewide_CUSTBASE_01.MeterLog(msl, 'N');
      --记录水表日志并提交统计
      --------------------------------------------------------
    end loop;
    close c_mtab;

    commit;
  exception
    when others then
      rollback;
      raise;
  end meterbook;

  --进行生成抄码表
  PROCEDURE createmr(p_mfpcode in VARCHAR2,
                     p_month   in varchar2,
                     p_bfid    in varchar2) IS
    ci        custinfo%rowtype;
    mi        meterinfo%rowtype;
    md        meterdoc%rowtype;
    bf        bookframe%rowtype;
    mr        meterread%rowtype;
    v_tempnum number(10);
    v_addsl   number(10);
    v_tempstr varchar2(10);
    v_ret     varchar2(10);
    v_date    date;
    --存在
    cursor c_mr(vmiid in varchar2) is
      select 1
        from meterread
       where mrmid = vmiid
         and mrmonth = p_month;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    cursor c_bfmeter is
      select cicode,
             miid,
             micid,
             mismfid,
             mirorder,
             micode,
             mistid,
             mipid,
             miclass,
             miflag,
             mirecdate,
             mircode,
             mirpid,
             mipriid,
             mipriflag,
             milb,
             minewflag,
             bfbatch,
             bfrper,
             mircodechar,
             misafid,
             miifchk,
             mipfid,
             mdcaliber,
             miside,
             mitype
        from custinfo, meterinfo, meterdoc, bookframe
       where ciid = micid
         and miid = mdmid
         and mismfid = bfsmfid
         and mibfid = bfid
         and mismfid = p_mfpcode
         and mibfid = p_bfid
            --and (to_char(ADD_MONTHS(to_date(MIRMON,'yyyy.mm'),BFRCYC),'yyyy.mm') = p_month or MIRMON is null)
         and bfnrmonth = p_month
         and fchkmeterneedread(miid) = 'Y';
  BEGIN
    open c_bfmeter;
    loop
      fetch c_bfmeter
        into ci.cicode,
             mi.miid,
             mi.micid,
             mi.mismfid,
             mi.mirorder,
             mi.micode,
             mi.mistid,
             mi.mipid,
             mi.miclass,
             mi.miflag,
             mi.mirecdate,
             mi.mircode,
             mi.mirpid,
             mi.mipriid,
             mi.mipriflag,
             mi.milb,
             mi.minewflag,
             bf.bfbatch,
             bf.bfrper,
             mi.mircodechar,
             mi.misafid,
             mi.miifchk,
             mi.mipfid,
             md.mdcaliber,
             mi.miside,
             mi.mitype;
      exit when c_bfmeter%notfound or c_bfmeter%notfound is null;
      --判断是否存在重复抄表计划
      OPEN c_mr(mi.miid);
      FETCH c_mr
        INTO DUMMY;
      found := c_mr%FOUND;
      close c_mr;
      if not found then
        mr.mrid     := fgetsequence('METERREAD'); --流水号
        mr.mrmonth  := p_month; --抄表月份
        mr.mrsmfid  := mi.mismfid; --管辖公司
        mr.mrbfid   := p_bfid; --表册
        mr.MRBATCH  := bf.bfbatch; --抄表批次
        mr.MRRPER   := bf.bfrper; --抄表员
        mr.mrrorder := mi.mirorder; --抄表次序号
        --取计划计划抄表日
        begin
          select mrbsdate
            into mr.mrday
            from meterreadbatch
           where mrbsmfid = mi.mismfid
             and mrbmonth = p_month
             and mrbbatch = bf.bfbatch;
        exception
          when others then
            if fsyspara('0039') = 'Y' then
              --是否按计划抄表日覆盖实际抄表日
              raise_application_error(ErrCode,
                                      '取计划抄表日错误，请检查计划抄表批次定义');
            end if;
        end;
        mr.mrcid           := mi.micid; --用户编号
        mr.mrccode         := ci.cicode;
        mr.mrmid           := mi.miid; --水表编号
        mr.mrmcode         := mi.micode; --水表手工编号
        mr.mrstid          := mi.mistid; --行业分类
        mr.mrmpid          := mi.mipid; --上级水表
        mr.mrmclass        := mi.miclass; --水表级次
        mr.mrmflag         := mi.miflag; --末级标志
        mr.mrcreadate      := CurrentDate; --创建日期
        mr.mrinputdate     := null; --编辑日期
        mr.mrreadok        := 'N'; --抄见标志
        mr.mrrdate         := null; --抄表日期
        mr.mrprdate        := mi.mirecdate; --上次抄见日期(取上次有效抄表日期)
        mr.mrscode         := mi.mircode; --上期抄见
        MR.MRSCODECHAR     := mi.mircodechar; --上期抄见char
        mr.mrecode         := null; --本期抄见
        mr.mrsl            := null; --本期水量
        mr.mrface          := null; --表况
        mr.mrifsubmit      := 'Y'; --是否提交计费
        mr.mrifhalt        := 'N'; --系统停算
        mr.mrdatasource    := 1; --抄表结果来源
        mr.mrifignoreminsl := 'Y'; --停算最低抄量
        mr.mrpdardate      := null; --抄表机抄表时间
        mr.mroutflag       := 'N'; --发出到抄表机标志
        mr.mroutid         := null; --发出到抄表机流水号
        mr.mroutdate       := null; --发出到抄表机日期
        mr.mrinorder       := null; --抄表机接收次序
        mr.mrindate        := null; --抄表机接受日期
        mr.mrrpid          := mi.mirpid; --计件类型
        mr.mrmemo          := null; --抄表备注
        mr.mrifgu          := 'N'; --估表标志
        mr.mrifrec         := 'N'; --已计费
        mr.mrrecdate       := null; --计费日期
        mr.mrrecsl         := null; --应收水量
        /*        --取未用余量
        sp_fetchaddingsl(mr.mrid , --抄表流水
                         mi.miid,--水表号
                         v_tempnum,--旧表止度
                         v_tempnum,--新表起度
                         v_addsl ,--余量
                         v_date,--创建日期
                         v_tempstr,--加调事务
                         v_ret  --返回值
                         ) ;
        mr.mraddsl         :=   v_addsl ;  --余量   */
        mr.mraddsl         := 0; --余量
        mr.mrcarrysl       := null; --进位水量
        mr.mrctrl1         := null; --抄表机控制位1
        mr.mrctrl2         := null; --抄表机控制位2
        mr.mrctrl3         := null; --抄表机控制位3
        mr.mrctrl4         := null; --抄表机控制位4
        mr.mrctrl5         := null; --抄表机控制位5
        mr.mrchkflag       := 'N'; --复核标志
        mr.mrchkdate       := null; --复核日期
        mr.mrchkper        := null; --复核人员
        mr.mrchkscode      := null; --原起数
        mr.mrchkecode      := null; --原止数
        mr.mrchksl         := null; --原水量
        mr.mrchkaddsl      := null; --原余量
        mr.mrchkcarrysl    := null; --原进位水量
        mr.mrchkrdate      := null; --原抄见日期
        mr.mrchkface       := null; --原表况
        mr.mrchkresult     := null; --检查结果类型
        mr.mrchkresultmemo := null; --检查结果说明
        mr.mrprimid        := mi.mipriid; --合收表主表
        mr.mrprimflag      := mi.mipriflag; --  合收表标志
        mr.mrlb            := mi.milb; -- 水表类别
        mr.mrnewflag       := mi.minewflag; -- 新表标志
        mr.mrface2         :=null ;--抄见故障
        mr.mrface3         :=null ;--非常计量
        mr.mrface4         :=null ;--表井设施说明

        mr.MRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
        mr.mrprivilegeper  :=null;--特权操作人
        mr.mrprivilegememo :=null;--特权操作备注
        mr.mrsafid         := mi.misafid; --管理区域
        mr.mriftrans       := 'N'; --转单标志
        mr.mrrequisition   := 0; --通知单打印次数
        mr.mrifchk         := mi.miifchk; --考核表标志
        mr.mrinputper      := null;--入账人员
        mr.mrpfid          := mi.mipfid;--用水类别
        mr.mrcaliber       := md.mdcaliber;--口径
        mr.mrside          := mi.miside;--表位
        mr.mrmtype         := mi.mitype;--表型

        --均量（费）算法
        --1、前n次均量：     从最近抄表水量向历史方向递推12次抄表累计水量（0水量不计次）/递推次数
        --2、上次水量：      最近抄表水量
        --3、去年同期水量：  去年同抄表月份的抄表水量
        --4、去年度次均量：  去年度的抄表累计水量（0水量不计次）/递推次数
/*
        mr.mrlastsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-1),mi.mirecdate); --上次抄表水量
        mr.mrthreesl       := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-3),mi.mirecdate); --前三月抄表水量
        mr.mryearsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-12),add_months(CurrentDate,-12)); --去年同期抄表水量
        */
         -- 截至本月历史连续、累计未抄见月数
        --sp_getnoread(mi.miid, mr.mrnullcont, mr.mrnulltotal); --历史连续、累计未抄见月数
        mr.mrplansl   := 0;--计划水量
        mr.mrplanje01 := 0;--计划水费
        mr.mrplanje02 := 0;--计划污水处理费
        mr.mrplanje03 := 0;--计划水资源费

        --上次水费   至  去年度次均量
        getmrhis(mr.mrmid,
                 mr.mrmonth,
                 mr.mrthreesl,
                 mr.mrthreeje01,
                 mr.mrthreeje02,
                 mr.mrthreeje03,
                 mr.mrlastsl,
                 mr.mrlastje01,
                 mr.mrlastje02,
                 mr.mrlastje03,
                 mr.mryearsl,
                 mr.mryearje01,
                 mr.mryearje02,
                 mr.mryearje03,
                 mr.mrlastyearsl,
                 mr.mrlastyearje01,
                 mr.mrlastyearje02,
                 mr.mrlastyearje03);




        insert into meterread VALUES MR;

        update meterinfo
           set MIPRMON = MIRMON, MIRMON = p_month
         where miid = mi.miid;
      end if;
    end loop;
    close c_bfmeter;

    update bookframe
       set bfnrmonth = to_char(add_months(to_date(bfnrmonth, 'yyyy.mm'),
                                          bfrcyc),
                               'yyyy.mm')
     where bfsmfid = p_mfpcode
       and bfid = p_bfid;

    commit;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  --删除抄表计划
  PROCEDURE deleteplan(p_type    in varchar2,
                       p_mfpcode in varchar2,
                       p_month   in varchar2,
                       p_bfid    in varchar2) is

  BEGIN
    --删除除掉已算费抄表计划
    if p_type = '01' then
/*      update meterinfo
         set MIRMON = MIPRMON, MIPRMON = null
       where miid in (select mrmid
                        from meterread
                       where mrbfid = p_bfid
                         and mrmonth = p_month
                         and MRSMFID = p_mfpcode
                         and MRIFREC = 'N');*/
      --还原余量
      insert into METERADDSL
        (select masid,
                masscodeo,
                masecoden,
                masuninsdate,
                masuninsper,
                mascredate,
                mascid,
                masmid,
                massl,
                mascreper,
                mastrans,
                masbillno,
                masscoden,
                masinsdate,
                masinsper
           from METERADDSLhis
          where exists (select mrid
                   from meterread
                  where mrid = MASMRID
                    and mrbfid = p_bfid
                    and mrmonth = p_month
                    and MRSMFID = p_mfpcode
                    and MRIFREC = 'N'));
      --删除历史余量
      delete METERADDSLhis
       where exists (select mrid
                from meterread
               where mrid = MASMRID
                 and mrbfid = p_bfid
                 and mrmonth = p_month
                 and MRSMFID = p_mfpcode
                 and MRIFREC = 'N');
      --删除抄表计划
      delete meterread
       where mrbfid = p_bfid
         and mrmonth = p_month
         and MRSMFID = p_mfpcode
         and MRIFREC = 'N';
      --删除除掉已算费已抄见水量抄表计划
    elsif p_type = '02' then

     /* update meterinfo
         set MIRMON = MIPRMON, MIPRMON = null
       where miid in (select mrmid
                        from meterread
                       where mrbfid = p_bfid
                         and mrmonth = p_month
                         and MRSMFID = p_mfpcode
                         and MRIFREC = 'N'
                         AND MRREADOK = 'N'
                         AND MRSL IS NULL);*/
      --还原余量
      insert into METERADDSL
        (select masid,
                masscodeo,
                masecoden,
                masuninsdate,
                masuninsper,
                mascredate,
                mascid,
                masmid,
                massl,
                mascreper,
                mastrans,
                masbillno,
                masscoden,
                masinsdate,
                masinsper
           from METERADDSLhis
          where exists (select mrid
                   from meterread
                  where mrid = MASMRID
                    and mrbfid = p_bfid
                    and mrmonth = p_month
                    and MRSMFID = p_mfpcode
                    and MRIFREC = 'N'
                    AND MRREADOK = 'N'
                    AND MRSL IS NULL));
      --删除历史余量
      delete METERADDSLhis
       where exists (select mrid
                from meterread
               where mrid = MASMRID
                 and mrbfid = p_bfid
                 and mrmonth = p_month
                 and MRSMFID = p_mfpcode
                 and MRIFREC = 'N'
                 AND MRREADOK = 'N'
                 AND MRSL IS NULL);
      --删除抄表计划
      delete meterread
       where mrbfid = p_bfid
         and mrmonth = p_month
         and MRSMFID = p_mfpcode
         and MRIFREC = 'N'
         AND MRREADOK = 'N'
         AND MRSL IS NULL;
    end if;

    commit;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise;
  END;

  -- 月终处理
  --p_smfid 营业所,售水公司
  --p_month 当前月份
  --p_per 操作员
  --p_commit 提交标志
  --o_ret 返回值
  --time 2009-04-04  by wy
  procedure CarryForward_mr(p_smfid  in varchar2,
                            p_month  in varchar2,
                            p_per    in varchar2,
                            p_commit in varchar2) is
    v_count     number;
    V_TEMPMONTH varchar2(7);
    V_ZZMONTH   VARCHAR2(7);
    vScrMonth   varchar2(7);
    vDesMonth   varchar2(7);
  begin
    ---START检查是否有漏算情况(在客户端中检查)----------------------------------------------------------
    V_TEMPMONTH := tools.fgetreadmonth(p_smfid);
    if V_TEMPMONTH <> p_month then
      raise_application_error(ErrCode, '月终月份异常,请检查!');
    end if;
    /*    --记录月终日志20100623 BY WY 衡阳自来水
          insert into mrnewlog
        (mnlgid, mnlgper, mnlgdate, mnlgmonth, mnlgmsfid, mnlgflag, mnlgtype)
      values
        (seq_mrnewlog_ID.Nextval , p_per, SYSDATE, p_month, p_smfid, 'Y','R');
    */
    --【抄表月份更新 date:20110323， autor ：yujia】
    --更新上期抄表月份
    update sysmanapara
       set smppvalue = V_TEMPMONTH
     where smpid = p_smfid
       and smppid = '000005';
    --月份加一
    V_ZZMONTH := to_char(add_months(to_date(V_TEMPMONTH || '.01',
                                            'yyyy.mm.dd'),
                                    1),
                         'yyyy.mm');
    --更新抄表月份
    update sysmanapara
       set smppvalue = V_ZZMONTH
     where smpid = p_smfid
       and smppid = '000009';

    --所有营业所都一样 抄表月份和应收月份同步 BY WY 20100528
    --【应收月份更新 date:20110323， autor ：yujia】
    --更新上个月应收月份
   /* update sysmanapara t
       set smppvalue = V_TEMPMONTH
     where smppid = '000004'
       and smpid = p_smfid;
    --应收月份
    update sysmanapara
       set smppvalue = V_ZZMONTH
     where smppid = '000008'
       and smpid = p_smfid;*/
    /*---【发票月份的更新，date:20110323， autor ：yujia】
      --更新上期发票月份
      update sysmanapara t
         set smppvalue = V_TEMPMONTH
       where smppid = '000003'
         and smpid = p_smfid;
          --本期发票月份
      update sysmanapara
         set smppvalue = V_ZZMONTH
       where smppid = '000007'
         and smpid = p_smfid;
    ---【实收帐月份的更新，date:20110323， autor ：yujia】
      --更新上期实收月份
      update sysmanapara t
         set smppvalue =V_TEMPMONTH
       where smppid = '000006'
         and smpid = p_smfid;

      --本期实收月份
      update sysmanapara
         set smppvalue = V_ZZMONTH
       where smppid = '000010'
         and smpid = p_smfid;*/
    --
    /*  begin
    select distinct smppvalue into vScrMonth from sysmanapara
    where smppid='000004' and smpid=p_smfid;
    select distinct smppvalue into vDesMonth from sysmanapara
    where smppid='000008' and smpid=p_smfid;
    exception when others then
    null;
    end;
    CMDPUSH('pg_report.InitMonthly',''''||vScrMonth||''','''||vDesMonth||''',''R''');*/
    --将抄表数据转入到历史抄表库
    INSERT INTO METERREADHIS
      (SELECT *
         FROM METERREAD T
        WHERE T.MRSMFID = p_smfid
          and T.MRMONTH = p_month);

    --删除当前抄表库信息
    delete METERREAD T
     WHERE T.MRSMFID = p_smfid
       and T.MRMONTH = p_month;

    --历史均量计算
    updatemrslhis(p_smfid, p_month);
    --提交标志
    if p_commit = 'Y' THEN
      COMMIT;
    END IF;
  exception
    when others then
      rollback;
      raise_application_error(ErrCode, '月终失败' || sqlerrm);
  end;

  -- 手工账务月结处理
  --p_smfid 营业所,售水公司
  --p_month 当前月份
  --p_per 操作员
  --p_commit 提交标志
  --o_ret 返回值
  --time 2010-08-20  by yf
  procedure CarryFpay_mr(p_smfid  in varchar2,
                         p_month  in varchar2,
                         p_per    in varchar2,
                         p_commit in varchar2) is
    v_count     number;
    V_TEMPMONTH varchar2(7);
    vScrMonth   varchar2(7);
    vDesMonth   varchar2(7);
  begin
    ---START检查是否有漏算情况(在客户端中检查)----------------------------------------------------------
    V_TEMPMONTH := tools.fgetpaymonth(p_smfid);
    if V_TEMPMONTH <> p_month then
      raise_application_error(ErrCode, '手工账务月结月份异常,请检查!');
    end if;
    --记录账务月结日志20100623 BY WY 衡阳自来水
    -- insert into mrnewlog
    --(mnlgid, mnlgper, mnlgdate, mnlgmonth, mnlgmsfid, mnlgflag, mnlgtype)
    --values
    --(seq_mrnewlog_ID.Nextval , p_per, SYSDATE, p_month, p_smfid, 'Y', 'P');
    --更新上期发票月份
    update sysmanapara t
       set smppvalue =
           (select smppvalue
              from sysmanapara tt
             where smppid = '000007'
               and t.smpid = tt.smpid)
     where smppid = '000003'
       and smpid = p_smfid;
    --更新上期实收月份
    update sysmanapara t
       set smppvalue =
           (select smppvalue
              from sysmanapara tt
             where smppid = '000010'
               and t.smpid = tt.smpid)
     where smppid = '000006'
       and smpid = p_smfid;
    --本期发票月份
    update sysmanapara
       set smppvalue = to_char(add_months(to_date(smppvalue, 'yyyy.mm'), 1),
                               'yyyy.mm')
     where smppid = '000007'
       and smpid = p_smfid;
    --本期实收月份
    update sysmanapara
       set smppvalue = to_char(add_months(to_date(smppvalue, 'yyyy.mm'), 1),
                               'yyyy.mm')
     where smppid = '000010'
       and smpid = p_smfid;
    --
    begin
      select distinct smppvalue
        into vScrMonth
        from sysmanapara
       where smppid = '000006'
         and smpid = p_smfid;
      select distinct smppvalue
        into vDesMonth
        from sysmanapara
       where smppid = '000010'
         and smpid = p_smfid;
    exception
      when others then
        null;
    end;
    CMDPUSH('pg_report.InitMonthly',
            '''' || vScrMonth || ''',''' || vDesMonth || ''',''P''');

    --提交标志
    if p_commit = 'Y' THEN
      COMMIT;
    END IF;
  exception
    when others then
      rollback;
      raise_application_error(ErrCode, '账务月结失败' || sqlerrm);
  end;

  --更新单个抄表计划
  procedure sp_updatemrone(p_type   in varchar2, --更新类型 :01 更新余量
                           p_mrid   in varchar2, --抄表流水号
                           p_commit in varchar2 --是否提交
                           ) as
    MR       meterread%ROWTYPE;
    v_tempsl number(10);

    v_tempnum number(10);
    v_addsl   number(10);
    v_tempstr varchar2(10);
    v_ret     varchar2(10);
    v_date    date;
  begin
    BEGIN
      SELECT * INTO MR FROM meterread WHERE MRID = p_mrid;
    exception
      when others then
        raise_application_error(ErrCode, '抄表计划不存在');
    end;
    IF MR.MRIFREC = 'Y' THEN
      raise_application_error(ErrCode, '抄表计划已经算费,不能更新');
    END IF;
    IF MR.MROUTFLAG = 'Y' THEN
      raise_application_error(ErrCode, '抄表计划已发出,不能更新');
    END IF;
    --01 更新余量
    if p_type = '01' then

      --取未用余量
      sp_fetchaddingsl(mr.mrid, --抄表流水
                       mr.mrid, --水表号
                       v_tempnum, --旧表止度
                       v_tempnum, --新表起度
                       v_addsl, --余量
                       v_date, --创建日期
                       v_tempstr, --加调事务
                       v_ret --返回值
                       );

      mr.mraddsl := nvl(mr.mraddsl, 0) + v_addsl;
      sp_getaddedsl(mr.mrid, --抄表流水
                    v_tempnum, --旧表止度
                    v_tempnum, --新表起度
                    v_tempsl, --余量
                    v_date, --创建日期
                    v_tempstr, --加调事务
                    v_ret --返回值
                    );
      if mr.MRADDSL <> v_tempsl then
        mr.MRADDSL := v_tempsl;
      end if;
      update meterread t set mraddsl = mr.mraddsl where mrid = p_mrid;
    end if;

    if p_commit = 'Y' THEN
      Commit;
    end if;

  exception
    when others then
      rollback;
  end;

  --查未用余量
  procedure sp_getaddingsl(p_miid      in varchar2, --水表号
                           o_masecoden out number, --旧表止度
                           o_masscoden out number, --新表起度
                           o_massl     out number, --余量
                           o_adddate   out date, --创建日期
                           o_mastrans  out varchar2, --加调事务
                           o_str       out varchar2 --返回值
                           ) as
    cursor c_maddsl is
      select * from METERADDSL t where MASMID = p_miid ORDER BY MASCREDATE;
    madd       meteraddsl%rowtype;
    v_oldecode number := 0;
    v_newscode number := 0;
    v_sl       number := 0;
    v_trans    varchar2(1);
    v_adddate  date;
  begin
    open c_maddsl;
    loop

      fetch c_maddsl
        into madd;
      exit when c_maddsl%notfound or c_maddsl%notfound is null;
      --拆表
      if madd.MASTRANS in ('F', 'G', 'H', 'K', 'L') then
        v_oldecode := madd.masecoden; --旧表止数
        v_sl       := v_sl + madd.massl; --余量
        v_trans    := madd.mastrans; --事务
        v_adddate  := madd.mascredate; --创建日期
      end if;

      --装表
      if madd.MASTRANS in ('I', 'J', 'K', 'L') then
        v_newscode := madd.masscoden; --新表起数
        v_trans    := madd.mastrans; --事务
        v_adddate  := madd.mascredate; --创建日期
      end if;

    end loop;

    close c_maddsl;

    o_mastrans := v_trans;
    if o_mastrans is not null then
      o_masecoden := v_oldecode;
      o_masscoden := v_newscode;
      o_massl     := v_sl;
      o_adddate   := v_adddate;
    else
      o_mastrans  := null;
      o_masecoden := null;
      o_masscoden := null;
      o_massl     := null;
      o_adddate   := null;
    end if;
    o_str := '000';
  exception
    when others then
      o_mastrans  := null;
      o_masecoden := null;
      o_masscoden := null;
      o_massl     := null;
      o_adddate   := null;
      o_str       := '999';
  end;

  --查已用余量
  procedure sp_getaddedsl(p_mrid      in varchar2, --抄表流水
                          o_masecoden out number, --旧表止度
                          o_masscoden out number, --新表起度
                          o_massl     out number, --余量
                          o_adddate   out date, --创建日期
                          o_mastrans  out varchar2, --加调事务
                          o_str       out varchar2 --返回值
                          ) as
    cursor c_maddslhis is
      select *
        from meteraddslhis t
       where masmrid = p_mrid
       order by mascredate;
    maddhis    meteraddslhis%rowtype;
    v_oldecode number := 0;
    v_newscode number := 0;
    v_sl       number := 0;
    v_trans    varchar2(1);
    v_adddate  date;
  begin
    open c_maddslhis;
    loop

      fetch c_maddslhis
        into maddhis;
      exit when c_maddslhis%notfound or c_maddslhis%notfound is null;
      --拆表
      if maddhis.MASTRANS in ('F', 'G', 'H', 'K', 'L') then
        v_oldecode := maddhis.masecoden; --旧表止数
        v_sl       := v_sl + maddhis.massl; --余量
        v_trans    := maddhis.mastrans; --事务
        v_adddate  := maddhis.mascredate; --创建日期
      end if;

      --装表
      if maddhis.MASTRANS in ('I', 'J', 'K', 'L') then
        v_newscode := maddhis.masscoden; --新表起数
        v_trans    := maddhis.mastrans; --事务
        v_adddate  := maddhis.mascredate; --创建日期
      end if;

    end loop;

    close c_maddslhis;

    o_mastrans := v_trans;
    if o_mastrans is not null then
      o_masecoden := v_oldecode;
      o_masscoden := v_newscode;
      o_massl     := v_sl;
      o_adddate   := v_adddate;
    else
      o_mastrans  := null;
      o_masecoden := null;
      o_masscoden := null;
      o_massl     := null;
      o_adddate   := null;
    end if;
    o_str := '000';
  exception
    when others then
      o_mastrans  := null;
      o_masecoden := null;
      o_masscoden := null;
      o_massl     := null;
      o_adddate   := null;
      o_str       := '999';
  end;

  --取余量
  procedure sp_fetchaddingsl(p_mrid      in varchar2, --抄表流水
                             p_miid      in varchar2, --水表号
                             o_masecoden out number, --旧表止度
                             o_masscoden out number, --新表起度
                             o_massl     out number, --余量
                             o_adddate   out date, --创建日期
                             o_mastrans  out varchar2, --加调事务
                             o_str       out varchar2 --返回值
                             ) as
    cursor c_maddsl is
      select * from METERADDSL t where MASMID = p_miid ORDER BY MASCREDATE;

    madd       METERADDSL%rowtype;
    v_oldecode number := 0;
    v_newscode number := 0;
    v_sl       number := 0;
    v_trans    varchar2(1);
    v_adddate  date;
  begin
    open c_maddsl;
    fetch c_maddsl
      into madd;
    if c_maddsl%notfound or c_maddsl%notfound is null then
      o_mastrans  := null;
      o_masecoden := null;
      o_masscoden := null;
      o_massl     := null;
      o_adddate   := null;
      o_str       := '100';
      close c_maddsl;
      return;
    end if;
    while c_maddsl%found loop
      --拆表
      if madd.MASTRANS in ('F', 'G', 'H', 'K', 'L') then
        v_oldecode := madd.masecoden; --旧表止数
        v_sl       := v_sl + madd.massl; --余量
        v_trans    := madd.mastrans; --事务
        v_adddate  := madd.mascredate; --创建日期
      end if;
      --装表
      if madd.MASTRANS in ('I', 'J', 'K', 'L') then
        v_newscode := madd.masscoden; --新表起数
        v_trans    := madd.mastrans; --事务
        v_adddate  := madd.mascredate; --创建日期
      end if;
      --
      --将领用的余量信息转到历史
      insert into meteraddslhis
        select masid,
               masscodeo,
               masecoden,
               masuninsdate,
               masuninsper,
               mascredate,
               mascid,
               masmid,
               massl,
               mascreper,
               mastrans,
               masbillno,
               masscoden,
               masinsdate,
               masinsper,
               p_mrid
          from meteraddsl t
         where masid = madd.masid;
      --删除当前余量信息
      delete meteraddsl where masid = madd.masid;
      --
      fetch c_maddsl
        into madd;
    end loop;
    close c_maddsl;

    o_mastrans  := v_trans;
    o_masecoden := v_oldecode;
    o_masscoden := v_newscode;
    o_massl     := v_sl;
    o_adddate   := v_adddate;
    o_str       := '000';
  exception
    when others then
      o_mastrans  := null;
      o_masecoden := null;
      o_masscoden := null;
      o_massl     := null;
      o_adddate   := null;
      o_str       := '999';
  end;

  --退余量
  procedure sp_rollbackaddedsl(p_mrid in varchar2, --抄表流水
                               o_str  out varchar2 --返回值
                               ) as
  begin
    if p_mrid is null then
      raise_application_error(ErrCode, '抄表流水为空,请检查!');
    end if;
    --将历史余量信息插入到当前余量表
    insert into METERADDSL
      (select masid,
              masscodeo,
              masecoden,
              masuninsdate,
              masuninsper,
              mascredate,
              mascid,
              masmid,
              massl,
              mascreper,
              mastrans,
              masbillno,
              masscoden,
              masinsdate,
              masinsper
         from meteraddslhis
        where masmrid = p_mrid);
    --删除历史余量信息
    delete meteraddslhis where masmrid = p_mrid;
    o_str := '000';
  exception
    when others then
      rollback;
      o_str := '999';
  end;

  --挫峰填谷均量计算12月历史水量表中增量抄表水量
  procedure updatemrslhis(p_smfid in varchar2, p_month in varchar2) is
    cursor c_mrhis is
      select mrmid, mrrdate, mrsl, mrecode
        from meterreadhis
       where mrsmfid = p_smfid
         and mrmonth = p_month;

    cursor c_mrslhis(vmid varchar2) is
      select * from meterreadslhis where mrmid = vmid for update nowait;

    mrhis   meterreadhis%rowtype;
    mrslhis meterreadslhis%rowtype;
    n       integer;
    i       integer;
  begin
    open c_mrhis;
    loop
      fetch c_mrhis
        into mrhis.mrmid, mrhis.mrrdate, mrhis.mrsl, mrhis.mrecode;
      exit when c_mrhis%notfound or c_mrhis%notfound is null;
      -------------------------------------------------------
      open c_mrslhis(mrhis.mrmid);
      fetch c_mrslhis
        into mrslhis;
      if c_mrslhis%notfound or c_mrslhis%notfound is null then
        -------------------------------------------------------
        insert into meterreadslhis
          (mrmid, mrmonth, mrrdate1, mrecode1, mrsl1)
        values
          (mrhis.mrmid, p_month, mrhis.mrrdate, mrhis.mrecode, mrhis.mrsl);
        -------------------------------------------------------
      end if;
      while c_mrslhis%found loop
        -------------------------------------------------------
        n := Months_between(first_day(mrhis.mrrdate), mrslhis.mrrdate1);
        if n > 0 then
          for i in 1 .. n loop
            mrslhis.mrrdate12 := mrslhis.mrrdate11;
            mrslhis.mrrdate11 := mrslhis.mrrdate10;
            mrslhis.mrrdate10 := mrslhis.mrrdate9;
            mrslhis.mrrdate9  := mrslhis.mrrdate8;
            mrslhis.mrrdate8  := mrslhis.mrrdate7;
            mrslhis.mrrdate7  := mrslhis.mrrdate6;
            mrslhis.mrrdate6  := mrslhis.mrrdate5;
            mrslhis.mrrdate5  := mrslhis.mrrdate4;
            mrslhis.mrrdate4  := mrslhis.mrrdate3;
            mrslhis.mrrdate3  := mrslhis.mrrdate2;
            mrslhis.mrrdate2  := mrslhis.mrrdate1;
            mrslhis.mrrdate1  := last_day(mrslhis.mrrdate1) + 1;

            mrslhis.mrsl1 := round(mrhis.mrsl / n, 2);
            if i = n then
              mrslhis.mrecode1 := mrhis.mrecode;
            end if;

            update meterreadslhis
               set mrsl12    = mrsl11,
                   mrecode12 = mrecode11,
                   mrrdate12 = mrslhis.mrrdate12,
                   mrsl11    = mrsl10,
                   mrecode11 = mrecode10,
                   mrrdate11 = mrslhis.mrrdate11,
                   mrsl10    = mrsl9,
                   mrecode10 = mrecode9,
                   mrrdate10 = mrslhis.mrrdate10,
                   mrsl9     = mrsl8,
                   mrecode9  = mrecode8,
                   mrrdate9  = mrslhis.mrrdate9,
                   mrsl8     = mrsl7,
                   mrecode8  = mrecode7,
                   mrrdate8  = mrslhis.mrrdate8,
                   mrsl7     = mrsl6,
                   mrecode7  = mrecode6,
                   mrrdate7  = mrslhis.mrrdate7,
                   mrsl6     = mrsl5,
                   mrecode6  = mrecode5,
                   mrrdate6  = mrslhis.mrrdate6,
                   mrsl5     = mrsl4,
                   mrecode5  = mrecode4,
                   mrrdate5  = mrslhis.mrrdate5,
                   mrsl4     = mrsl3,
                   mrecode4  = mrecode3,
                   mrrdate4  = mrslhis.mrrdate4,
                   mrsl3     = mrsl2,
                   mrecode3  = mrecode2,
                   mrrdate3  = mrslhis.mrrdate3,
                   mrsl2     = mrsl1,
                   mrecode2  = mrecode1,
                   mrrdate2  = mrslhis.mrrdate2,
                   mrsl1     = mrslhis.mrsl1,
                   mrecode1  = mrslhis.mrecode1,
                   mrrdate1  = mrslhis.mrrdate1
             where current of c_mrslhis;
          end loop;
        elsif n <= 0 then
          case first_day(mrhis.mrrdate)
            when mrslhis.mrrdate1 then
              update meterreadslhis
                 set mrsl1    = mrsl1 + nvl(mrhis.mrsl, 0),
                     mrecode1 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate2 then
              update meterreadslhis
                 set mrsl2    = mrsl2 + nvl(mrhis.mrsl, 0),
                     mrecode2 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate3 then
              update meterreadslhis
                 set mrsl3    = mrsl3 + nvl(mrhis.mrsl, 0),
                     mrecode3 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate4 then
              update meterreadslhis
                 set mrsl4    = mrsl4 + nvl(mrhis.mrsl, 0),
                     mrecode4 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate5 then
              update meterreadslhis
                 set mrsl5    = mrsl5 + nvl(mrhis.mrsl, 0),
                     mrecode5 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate6 then
              update meterreadslhis
                 set mrsl6    = mrsl6 + nvl(mrhis.mrsl, 0),
                     mrecode6 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate7 then
              update meterreadslhis
                 set mrsl7    = mrsl7 + nvl(mrhis.mrsl, 0),
                     mrecode7 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate8 then
              update meterreadslhis
                 set mrsl8    = mrsl8 + nvl(mrhis.mrsl, 0),
                     mrecode8 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate9 then
              update meterreadslhis
                 set mrsl9    = mrsl9 + nvl(mrhis.mrsl, 0),
                     mrecode9 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate10 then
              update meterreadslhis
                 set mrsl10    = mrsl10 + nvl(mrhis.mrsl, 0),
                     mrecode10 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate11 then
              update meterreadslhis
                 set mrsl11    = mrsl11 + nvl(mrhis.mrsl, 0),
                     mrecode11 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate12 then
              update meterreadslhis
                 set mrsl12    = mrsl12 + nvl(mrhis.mrsl, 0),
                     mrecode12 = mrhis.mrecode
               where current of c_mrslhis;
            else
              null;
          end case;
        end if;
        -------------------------------------------------------
        fetch c_mrslhis
          into mrslhis;
      end loop;
      close c_mrslhis;
      -------------------------------------------------------
    end loop;
    close c_mrhis;
  end updatemrslhis;

  --复核检查
  procedure sp_mrslcheck(p_smfid     in varchar2,
                         p_mrmid     in varchar2,
                         p_MRSCODE   in varchar2,
                         p_MRECODE   in number,
                         p_MRSL      in number,
                         p_MRADDSL   in number,
                         p_MRRDATE   in date,
                         o_errflag   out varchar2,
                         o_ifmsg     out varchar2,
                         o_msg       out varchar2,
                         o_examine   out varchar2,
                         o_subcommit out varchar2) as
    v_threeavgsl number(12, 2);
    v_mrsl       number(12, 2);
    v_MRSLCHECK  varchar2(10); --抄表水量过大提示
    v_MRSLSUBMIT varchar2(10); --抄表水量过大锁定
    v_MRBASECKSL NUMBER(10); --波动校验基量
  begin
    v_MRSLCHECK  := FPARA(p_smfid, 'MRSLCHECK');
    v_MRSLSUBMIT := FPARA(p_smfid, 'MRSLSUBMIT');
    v_MRBASECKSL := TO_NUMBER(FPARA(p_smfid, 'MRBASECKSL'));

    if (v_MRSLCHECK = 'Y' AND v_MRSLSUBMIT = 'N') OR
       (v_MRSLCHECK = 'N' AND v_MRSLSUBMIT = 'Y') OR
       (v_MRSLCHECK = 'Y' AND v_MRSLSUBMIT = 'Y') AND p_MRSL > v_MRBASECKSL THEN
      if p_MRSCODE is null then
        o_msg := '抄表起码为空,请检查!';
        raise_application_error(ErrCode, '抄表起码为空,请检查!');
      end if;
      if p_MRECODE is null then
        o_msg := '抄表止码为空,请检查!';
        raise_application_error(ErrCode, '抄表止码为空,请检查!');
      end if;
      if p_MRSL is null then
        o_msg := '抄表水量为空,请检查!';
        raise_application_error(ErrCode, '抄表水量为空,请检查!');
      end if;
      if p_MRADDSL is null then
        o_msg := '余量为空,请检查!';
        raise_application_error(ErrCode, '余量为空,请检查!');
      end if;
      if p_MRADDSL < 0 then
        o_msg := '余量小于零,请检查!';
        raise_application_error(ErrCode, '余量小于零,请检查!');
      end if;
      if p_MRRDATE is null then
        o_msg := '抄表日期为空,请检查!';
        raise_application_error(ErrCode, '抄表日期为空,请检查!');
      end if;
      --
      if p_mrsl < 0 then
        o_msg := '抄表水量不能小于零!';
        raise_application_error(errcode, '抄表水量不能小于零!');
      elsif p_mrsl = 0 then
        o_msg       := '抄表水量等于零,是否确认?';
        o_errflag   := 'N';
        o_ifmsg     := 'Y';
        o_examine   := v_MRSLCHECK;
        o_subcommit := 'N';
        return;
      elsif p_mrsl > 0 then
        v_mrsl       := fgetmrslmonavg(p_mrmid, p_mrsl, p_mrrdate);
        v_threeavgsl := fgetthreemonavg(p_mrmid);
      end if;

      if v_mrsl is null then
        o_msg       := '求月均量异常!';
        o_errflag   := 'Y';
        o_ifmsg     := 'Y';
        o_examine   := 'N';
        o_subcommit := 'N';
        RETURN;
      elsif v_mrsl < -100 then
        o_msg       := '求月均量传入参数异常!';
        o_errflag   := 'Y';
        o_ifmsg     := 'Y';
        o_examine   := 'N';
        o_subcommit := 'N';
        RETURN;
      elsif v_mrsl < 0 and v_mrsl >= -100 then
        o_msg       := '可忽略异常!';
        o_errflag   := 'N';
        o_ifmsg     := 'N';
        o_examine   := 'N';
        o_subcommit := 'N';
        RETURN;
      elsif v_mrsl = 0 then
        o_msg       := '抄表水为零,是否确定?';
        o_errflag   := 'N';
        o_ifmsg     := 'Y';
        o_examine   := v_MRSLCHECK;
        o_subcommit := 'N';
        RETURN;
      end if;

      if v_threeavgsl is null then
        o_msg       := '求三月平均异常!';
        o_errflag   := 'Y';
        o_ifmsg     := 'Y';
        o_examine   := 'N';
        o_subcommit := 'N';
        RETURN;
      elsif v_threeavgsl < -100 then
        o_msg       := '求三月均量传入参数异常!';
        o_errflag   := 'Y';
        o_ifmsg     := 'Y';
        o_examine   := 'N';
        o_subcommit := 'N';
        RETURN;
      elsif v_threeavgsl < 0 and v_threeavgsl >= -100 then
        o_msg       := '可忽略异常!';
        o_errflag   := 'N';
        o_ifmsg     := 'N';
        o_examine   := 'N';
        o_subcommit := 'N';
        RETURN;
      elsif v_threeavgsl = 0 then
        o_msg       := '前三月均量为零,请确定?';
        o_errflag   := 'N';
        o_ifmsg     := 'Y';
        o_examine   := v_MRSLCHECK;
        o_subcommit := 'N';
        RETURN;
      elsif v_threeavgsl > 0 then
        if v_mrsl >= v_threeavgsl * to_number(FPARA(p_smfid, 'MRSLMAX')) then
          o_msg       := '抄表水量已超出三月均量的'||FPARA(p_smfid, 'MRSLMAX')||'倍,是否发送领导审核并销住抄表计划?';
          o_errflag   := 'N';
          o_ifmsg     := 'Y';
          o_examine   := 'N';
          o_subcommit := v_MRSLSUBMIT;
          RETURN;
        elsif v_mrsl <= v_threeavgsl * to_number(FPARA(p_smfid, 'MRSLMSG')) OR
              (v_mrsl >=
              v_threeavgsl * (1 + to_number(FPARA(p_smfid, 'MRSLMSG'))) and
              v_mrsl < v_threeavgsl * to_number(FPARA(p_smfid, 'MRSLMAX'))) then
          o_msg       := '抄表水量已超出三月均量的正负'||to_number(FPARA(p_smfid, 'MRSLMSG'))*100||'%,是否确认?';
          o_errflag   := 'N';
          o_ifmsg     := 'Y';
          o_examine   := v_MRSLCHECK;
          o_subcommit := 'N';
          RETURN;
        else
          o_msg       := '正常抄量!';
          o_errflag   := 'N';
          o_ifmsg     := 'N';
          o_examine   := 'N';
          o_subcommit := 'N';
          RETURN;
        end if;
      end if;
    ELSE
      o_errflag   := 'N';
      o_ifmsg     := 'N';
      o_examine   := 'N';
      o_subcommit := 'N';
    END IF;
  exception
    when others then
      rollback;
      o_errflag   := 'Y';
      o_ifmsg     := 'Y';
      o_examine   := 'N';
      o_subcommit := 'N';
      raise;
  end;

  --求录入月均量
  function fgetmrslmonavg(p_miid    in varchar2,
                          p_mrsl    in number,
                          p_mrrdate in date) return number is
    v_avgmrsl  number(12, 2);
    v_moncount number(10);
    v_lastdate date; --上次抄见日期
    mradsl     METERREADSLHIS%rowtype;
  begin
    if p_miid is null then
      return - 101; --抄表流水不空
    end if;
    if p_mrsl is null then
      return - 102; --抄表水量为空
    end if;
    if p_mrsl < 0 then
      return - 103; --抄表水量为负
    end if;
    if p_mrrdate is null then
      return - 104; --抄表日期为空
    end if;
    begin
      select * into mradsl from METERREADSLHIS where mrmid = p_miid;
    exception
      when others then
        return - 1; --没的找到记录
    end;
    v_lastdate := null; --初始化日期为空
    if v_lastdate is null then
      if mradsl.mrsl1 is not null then
        if mradsl.mrrdate1 is null then
          return - 2; --抄见日期异常
        else
          v_lastdate := mradsl.mrrdate1;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --间隔月份异常
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --正常返回
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl2 is not null then
        if mradsl.mrrdate2 is null then
          return - 2; --抄见日期异常
        else
          v_lastdate := mradsl.mrrdate2;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --间隔月份异常
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --正常返回
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl3 is not null then
        if mradsl.mrrdate3 is null then
          return - 2; --抄见日期异常
        else
          v_lastdate := mradsl.mrrdate3;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --间隔月份异常
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --正常返回
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl4 is not null then
        if mradsl.mrrdate4 is null then
          return - 2; --抄见日期异常
        else
          v_lastdate := mradsl.mrrdate4;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --间隔月份异常
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --正常返回
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl5 is not null then
        if mradsl.mrrdate5 is null then
          return - 2; --抄见日期异常
        else
          v_lastdate := mradsl.mrrdate5;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --间隔月份异常
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --正常返回
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl6 is not null then
        if mradsl.mrrdate6 is null then
          return - 2; --抄见日期异常
        else
          v_lastdate := mradsl.mrrdate6;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --间隔月份异常
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --正常返回
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl7 is not null then
        if mradsl.mrrdate7 is null then
          return - 2; --抄见日期异常
        else
          v_lastdate := mradsl.mrrdate7;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --间隔月份异常
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --正常返回
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl8 is not null then
        if mradsl.mrrdate8 is null then
          return - 2; --抄见日期异常
        else
          v_lastdate := mradsl.mrrdate8;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --间隔月份异常
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --正常返回
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl9 is not null then
        if mradsl.mrrdate9 is null then
          return - 2; --抄见日期异常
        else
          v_lastdate := mradsl.mrrdate9;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --间隔月份异常
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --正常返回
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl10 is not null then
        if mradsl.mrrdate10 is null then
          return - 2; --抄见日期异常
        else
          v_lastdate := mradsl.mrrdate10;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --间隔月份异常
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --正常返回
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl11 is not null then
        if mradsl.mrrdate11 is null then
          return - 2; --抄见日期异常
        else
          v_lastdate := mradsl.mrrdate11;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --间隔月份异常
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --正常返回
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl12 is not null then
        if mradsl.mrrdate12 is null then
          return - 2; --抄见日期异常
        else
          v_lastdate := mradsl.mrrdate12;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --间隔月份异常
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --正常返回
          end if;
        end if;
      end if;
    end if;

    if v_lastdate is null then
      return - 4; --12个月找完后还没记录
    end if;

  exception
    when others then
      return null; --异常
  end;
  --取三月平均
  function fgetthreemonavg(p_miid in varchar2) return number is
    v_avgsl number(12, 2);
    v_count number(10);
    v_allsl number(12, 2);
    mradsl  METERREADSLHIS%rowtype;
  begin
    begin
      select * into mradsl from METERREADSLHIS where mrmid = p_miid;
    exception
      when others then
        return - 1; --没的找到记录,不用复核
    end;
    v_count := 0; --初始抄见水量月份
    v_allsl := 0; --初始累计抄见水量
    if v_count < 3 then
      if mradsl.mrsl1 is not null then
        if mradsl.mrsl1 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl1;
        else
          return - 3; --历史抄见水量为负
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl2 is not null then
        if mradsl.mrsl2 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl2;
        else
          return - 3; --历史抄见水量为负
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl3 is not null then
        if mradsl.mrsl3 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl3;
        else
          return - 3; --历史抄见水量为负
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl4 is not null then
        if mradsl.mrsl4 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl4;
        else
          return - 3; --历史抄见水量为负
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl5 is not null then
        if mradsl.mrsl5 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl5;
        else
          return - 3; --历史抄见水量为负
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl6 is not null then
        if mradsl.mrsl6 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl6;
        else
          return - 3; --历史抄见水量为负
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl7 is not null then
        if mradsl.mrsl7 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl7;
        else
          return - 3; --历史抄见水量为负
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl8 is not null then
        if mradsl.mrsl8 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl8;
        else
          return - 3; --历史抄见水量为负
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl9 is not null then
        if mradsl.mrsl9 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl9;
        else
          return - 3; --历史抄见水量为负
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl10 is not null then
        if mradsl.mrsl10 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl10;
        else
          return - 3; --历史抄见水量为负
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl11 is not null then
        if mradsl.mrsl11 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl11;
        else
          return - 3; --历史抄见水量为负
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl12 is not null then
        if mradsl.mrsl12 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl12;
        else
          return - 3; --历史抄见水量为负
        end if;
      end if;
    end if;
    --没的抄见的记录,无需复核
    if v_count = 0 then
      return - 2; --抄见记录数为零
    else
      v_avgsl := ROUND(v_allsl / v_count, 2);
      return v_avgsl;
    end if;
  exception
    when others then
      return null; --异常
  end;

  --用余量
  procedure sp_useaddingsl(p_mrid  in varchar2, --抄表流水
                           p_masid in number, --余量流水
                           o_str   out varchar2 --返回值
                           ) as
  begin
    --将领用的余量信息转到历史
    insert into meteraddslhis
      select masid,
             masscodeo,
             masecoden,
             masuninsdate,
             masuninsper,
             mascredate,
             mascid,
             masmid,
             massl,
             mascreper,
             mastrans,
             masbillno,
             masscoden,
             masinsdate,
             masinsper,
             p_mrid
        from meteraddsl t
       where masid = p_masid;
    --删除当前余量信息
    delete meteraddsl t where masid = p_masid;
    o_str := '000';
  exception
    when others then
      o_str := '999';
  end;

  --还余量
  procedure sp_retaddingsl(p_MASMRID in varchar2, --抄表流水
                           o_str     out varchar2 --返回值
                           ) as
    v_count number(10);
  begin
    --将领用的余量信息转到历史
    select count(*)
      into v_count
      from meteraddslhis
     where MASMRID = p_MASMRID;
    if v_count = 0 then
      o_str := '000';
      return;
    end if;
    insert into meteraddsl
      select masid,
             masscodeo,
             masecoden,
             masuninsdate,
             masuninsper,
             mascredate,
             mascid,
             masmid,
             massl,
             mascreper,
             mastrans,
             masbillno,
             masscoden,
             masinsdate,
             masinsper
        from meteraddslhis t
       where MASMRID = p_MASMRID;
    --删除当前余量信息
    delete meteraddslhis t where MASMRID = p_MASMRID;
    o_str := '000';
  exception
    when others then
      o_str := '999';
  end;
  --抄表批次检查
  function fcheckmrbatch(p_mrid in varchar2, p_smfid in varchar2)
    return varchar2 is
    mb meterreadbatch%rowtype;
    mr meterread%rowtype;
  begin
    begin
      select * into mr from meterread where mrid = p_mrid;
    exception
      when others then
        return '抄表计划不存在!';
    end;
    if mr.mrprivilegeflag = 'Y' then
      return 'Y';
    end if;
    if mr.mrbatch is null then
      return '抄表计划中抄表批次为空!';
    end if;
    begin
      select *
        into mb
        from meterreadbatch
       where mrbsmfid = mr.mrsmfid
         and mrbmonth = mr.mrmonth
         and mr.mrbatch = mrbbatch;
    exception
      when others then
        return '抄表批次未定义!';
    end;
    if mb.mrbsdate is null or mb.mrbedate is null then
      return '抄表批次定义起止日期为空!';
    end if;
    if trunc(sysdate) >= trunc(mb.mrbsdate) and
       trunc(sysdate) <=
       trunc(mb.mrbedate) + to_number(nvl(fpara(p_smfid, 'MRLASTIMP'), 0)) then
      return 'Y';
    else
      return '已超过抄录水量的时间期限:[' || to_char(mb.mrbsdate, 'yyyymmdd') || '至' || to_char(trunc(mb.mrbedate) +
                                                                                    to_number(nvl(fpara(p_smfid,
                                                                                                        'MRLASTIMP'),
                                                                                                  0)),
                                                                                    'yyyymmdd') || ']';
    end if;
  exception
    when others then
      return '检查异常!';
  end;
  --抄表特权
  procedure sp_mrprivilege(p_mrid in varchar2,
                           p_oper in varchar2,
                           p_memo in varchar2,
                           o_str  out varchar2) as
    v_type  varchar2(10); --特权类型
    v_count number(10);
    mr      meterread%rowtype;
  begin
    v_type := fsyspara('0037');
    if v_type is null then
      o_str := '特权类型未定义!';
      return;
    end if;
    if v_type not in ('1', '2', '3') then
      o_str := '特权类型定义错误!';
      return;
    end if;
    begin
      select * into mr from meterread where mrid = p_mrid;
    exception
      when others then
        o_str := '抄表计划不存在!';
        return;
    end;
    if v_type = '1' then
      if mr.mrprivilegeflag = 'Y' then
        o_str := '此抄表计划已特权处理,不需要再次处理!';
        return;
      end if;
      update meterread
         set MRPRIVILEGEFLAG = 'Y',
             MRPRIVILEGEPER  = P_OPER,
             MRPRIVILEGEMEMO = P_MEMO,
             MRPRIVILEGEDATE = SYSDATE
       where mrid = p_mrid
         and mrifrec = 'N';
    end if;
    if v_type = '2' then
      select count(mrid)
        into v_count
        from meterread
       where MRSMFID = MR.MRSMFID
         AND MRBFID = MR.MRBFID
         and mrifrec = 'N';
      if v_count < 1 then
        o_str := '此表册抄表计划已特权处理,不需要再次处理!';
        return;
      end if;

      update meterread
         set MRPRIVILEGEFLAG = 'Y',
             MRPRIVILEGEPER  = P_OPER,
             MRPRIVILEGEMEMO = P_MEMO,
             MRPRIVILEGEDATE = SYSDATE
       where MRSMFID = MR.MRSMFID
         AND MRBFID = MR.MRBFID
         and mrifrec = 'N';
    end if;
    if v_type = '3' then
      select count(mrid)
        into v_count
        from meterread
       where MRSMFID = MR.MRSMFID
         and mrifrec = 'N';
      if v_count < 1 then
        o_str := '此营业所抄表计划已特权处理,不需要再次处理!';
        return;
      end if;
      update meterread
         set MRPRIVILEGEFLAG = 'Y',
             MRPRIVILEGEPER  = P_OPER,
             MRPRIVILEGEMEMO = P_MEMO,
             MRPRIVILEGEDATE = SYSDATE
       where MRSMFID = MR.MRSMFID
         and mrifrec = 'N';
    end if;
    o_str := 'Y';
  exception
    when others then
      o_str := '特权处理异常!';
  end;

  --查询整表册是否已全部录入水量
  function fckkbfidallimputsl(p_smfid in varchar2,
                              p_bfid  in varchar2,
                              p_mon   in varchar2) return varchar2 is
    v_count number(10);
  begin
    select count(mrid)
      into v_count
      from meterread t
     where t.mrsmfid = p_smfid
       and t.mrbfid = p_bfid
       and t.mrmonth = p_mon
       and t.mrsl is null;
    if v_count = 0 then
      return 'Y';
    ELSE
      return 'N';
    END IF;
  exception
    when others then
      return null;
  end;
  --查询整表册是否已审核
  function fckkbfidallsubmit(p_smfid in varchar2,
                             p_bfid  in varchar2,
                             p_mon   in varchar2) return varchar2 is
    v_count number(10);
  begin
    select count(mrid)
      into v_count
      from meterread t
     where t.mrsmfid = p_smfid
       and t.mrbfid = p_bfid
       and t.mrmonth = p_mon
       and t.MRIFSUBMIT <> 'Y'
       and t.mrsl is not null;
    if v_count = 0 then
      return 'Y';
    ELSE
      return 'N';
    END IF;
  exception
    when others then
      return null;
  end;

  --批量审核
  procedure sp_mrmrifsubmit(p_mrid in varchar2,
                            p_oper in varchar2,
                            p_memo in varchar2,
                            p_flag in varchar2) as
    v_count number(10);
    mr      meterread%rowtype;
  begin
    begin
      select * into mr from meterread where mrid = p_mrid;
      if mr.mrifsubmit = 'Y' then
        raise_application_error(ErrCode, '无需审核');
      end if;
      if mr.mrsl is null then
        raise_application_error(ErrCode, '抄表水量为空');
      end if;
      if mr.mrifrec = 'Y' then
        raise_application_error(ErrCode, '已计费无需审核');
      end if;
    exception
      when others then
        raise_application_error(ErrCode, '无效的抄表记录');
    end;

    update meterread
       set mrifsubmit      = 'Y',
           mrchkflag       = 'Y', --复核标志
           mrchkdate       = sysdate, --复核日期
           mrchkper        = p_oper, --复核人员
           mrchkscode      = mr.mrscode, --原起数
           mrchkecode      = mr.mrecode, --原止数
           mrchksl         = mr.mrsl, --原水量
           mrchkaddsl      = mr.mraddsl, --原余量
           mrchkcarrysl    = mr.mrcarrysl, --原进位水量
           mrchkrdate      = mr.mrrdate, --原抄见日期
           mrchkface       = mr.mrface, --原表况
           mrchkresult = (case
                           when p_flag = '1' then
                            '确认通过'
                           else
                            '退回重入帐'
                         end), --检查结果类型
           mrchkresultmemo = (case
                               when p_flag = '1' then
                                '确认通过'
                               else
                                '退回重入帐'
                             end) --检查结果说明
     where mrid = p_mrid;

    if p_flag = '0' then
      --审批不通过
      update meterread
         set mrreadok     = 'N',
             mrrdate      = null,
             mrecode      = null,
             mrsl         = null,
             mrface       = null,
             mrface2      = null,
             mrface3      = null,
             mrface4      = null,
             mrecodechar  = null,
             mrdatasource = null
       where mrid = p_mrid;
    end if;

  exception
    when others then
      rollback;
      raise_application_error(ErrCode, '审批异常');
  end;

  --抄表水量录入时抄表止码减抄表起码不等记录复核信息
  procedure sp_mrslerrchk(p_mrid            in varchar2, --抄表流水呈
                          p_MRCHKPER        in varchar2, --复核人员
                          p_MRCHKSCODE      in number, --原起数
                          p_MRCHKECODE      in number, --原止数
                          p_MRCHKSL         in number, --原水量
                          p_MRCHKADDSL      in number, --原余量
                          p_MRCHKCARRYSL    in number, --原进位水量
                          p_MRCHKRDATE      in date, --原抄见日期
                          p_MRCHKFACE       in varchar2, --原表况
                          p_MRCHKRESULT     in varchar2, --检查结果类型
                          p_MRCHKRESULTMEMO in varchar2, --检查结果说明
                          o_str             out varchar2 --返回值
                          ) as
    mr meterread%rowtype;
  begin
    begin
      select * into mr from meterread where mrid = p_mrid;
    exception
      when others then
        o_str := '抄表计划不存在';
    end;
    update meterread
       set mrchkflag               = 'Y', --复核标志
           mrchkdate　　　　　　　 = sysdate, --复核日期
           mrchkper                = p_mrchkper, --复核人员
           mrchkscode              = p_mrchkscode, --原起数
           mrchkecode              = p_mrchkecode, --原止数
           mrchksl                 = p_mrchksl, --原水量
           mrchkaddsl              = p_mrchkaddsl, --原余量
           mrchkcarrysl            = p_mrchkcarrysl, --原进位水量
           mrchkrdate              = p_mrchkrdate, --原抄见日期
           mrchkface               = p_mrchkface, --原表况
           mrchkresult             = p_mrchkresult, --检查结果类型
           mrchkresultmemo         = p_mrchkresultmemo --检查结果说明
     where mrid = p_mrid;
    o_str := 'Y';
  exception
    when others then
      o_str := '记录复核信息异常';
  end;

  /*
  均量（费）算法
  1、前n次均量：     从最近抄表水量向历史方向递推12次抄表累计水量（0水量不计次）/递推次数
  2、上次水量：      最近一次抄表水量（包括0水量）
  3、去年同期水量：  去年同抄表月份的抄表水量（包括0水量）
  4、去年度次均量：  去年度的抄表累计水量（0水量不计次）/递推次数

  【meterread/meterreadhis】均量记录结构
  mrthreesl   number(10)    前n次均量
  mrthreeje01 number(13,3)  前n次均水费
  mrthreeje02 number(13,3)  前n次均污水费
  mrthreeje03 number(13,3)  前n次均水资源费

  mrlastsl    number(10)    上次水量
  mrlastje01  number(13,3)  上次水费
  mrlastje02  number(13,3)  上次污水费
  mrlastje03  number(13,3)  上次水资源费

  mryearsl    number(10)    去年同期水量
  mryearje01  number(13,3)  去年同期水费
  mryearje02  number(13,3)  去年同期污水费
  mryearje03  number(13,3)  去年同期水资源费

  mrlastyearsl    number(10)    去年度次均量
  mrlastyearje01  number(13,3)  去年度次均水费
  mrlastyearje02  number(13,3)  去年度次均污水费
  mrlastyearje03  number(13,3)  去年度次均水资源费
  */
  procedure getmrhis(p_miid   in varchar2,
                     p_month  in varchar2,
                     o_sl_1   out number,
                     o_je01_1 out number,
                     o_je02_1 out number,
                     o_je03_1 out number,
                     o_sl_2   out number,
                     o_je01_2 out number,
                     o_je02_2 out number,
                     o_je03_2 out number,
                     o_sl_3   out number,
                     o_je01_3 out number,
                     o_je02_3 out number,
                     o_je03_3 out number,
                     o_sl_4   out number,
                     o_je01_4 out number,
                     o_je02_4 out number,
                     o_je03_4 out number) is
    cursor c_mrh(v_miid meterread.mrmid%type) is
      select nvl(mrsl, 0),
             nvl(mrrecje01, 0),
             nvl(mrrecje02, 0),
             nvl(mrrecje03, 0),
             mrmonth
        from meterreadhis
       where mrmid = v_miid
            /*and mrsl > 0*/
         and (mrdatasource <> '9' or mrdatasource is null)
       order by mrrdate desc;

    mrh meterreadhis%rowtype;
    n1  integer := 0;
    n2  integer := 0;
    n3  integer := 0;
    n4  integer := 0;
  begin
    open c_mrh(p_miid);
    loop
      fetch c_mrh
        into mrh.mrsl,
             mrh.mrrecje01,
             mrh.mrrecje02,
             mrh.mrrecje03,
             mrh.mrmonth;
      exit when c_mrh%notfound is null or c_mrh%notfound or(n1 > 12 and
                                                            n2 > 1 and
                                                            n3 > 1 and
                                                            n4 > 12);
      if mrh.mrsl > 0 and n1 <= 12 then
        n1              := n1 + 1;
        mrh.mrthreesl   := nvl(mrh.mrthreesl, 0) + mrh.mrsl; --前n次均量
        mrh.mrthreeje01 := nvl(mrh.mrthreeje01, 0) + mrh.mrrecje01; --前n次均水费
        mrh.mrthreeje02 := nvl(mrh.mrthreeje02, 0) + mrh.mrrecje02; --前n次均污水费
        mrh.mrthreeje03 := nvl(mrh.mrthreeje03, 0) + mrh.mrrecje03; --前n次均水资源费
      end if;

      if c_mrh%rowcount = 1 then
        n2             := n2 + 1;
        mrh.mrlastsl   := nvl(mrh.mrlastsl, 0) + mrh.mrsl; --上次水量
        mrh.mrlastje01 := nvl(mrh.mrlastje01, 0) + mrh.mrrecje01; --上次水费
        mrh.mrlastje02 := nvl(mrh.mrlastje02, 0) + mrh.mrrecje02; --上次污水费
        mrh.mrlastje03 := nvl(mrh.mrlastje03, 0) + mrh.mrrecje03; --上次水资源费
      end if;

      if mrh.mrmonth = to_char(to_number(substr(p_month, 1, 4)) - 1) || '.' ||
         substr(p_month, 6, 2) then
        n3             := n3 + 1;
        mrh.mryearsl   := nvl(mrh.mryearsl, 0) + mrh.mrsl; --去年同期水量
        mrh.mryearje01 := nvl(mrh.mryearje01, 0) + mrh.mrrecje01; --去年同期水费
        mrh.mryearje02 := nvl(mrh.mryearje02, 0) + mrh.mrrecje02; --去年同期污水费
        mrh.mryearje03 := nvl(mrh.mryearje03, 0) + mrh.mrrecje03; --去年同期水资源费
      end if;

      if mrh.mrsl > 0 and to_number(substr(mrh.mrmonth, 1, 4)) =
         to_number(substr(p_month, 1, 4)) - 1 then
        n4                 := n4 + 1;
        mrh.mrlastyearsl   := nvl(mrh.mrlastyearsl, 0) + mrh.mrsl; --去年度次均量
        mrh.mrlastyearje01 := nvl(mrh.mrlastyearje01, 0) + mrh.mrrecje01; --去年度次均水费
        mrh.mrlastyearje02 := nvl(mrh.mrlastyearje02, 0) + mrh.mrrecje02; --去年度次均污水费
        mrh.mrlastyearje03 := nvl(mrh.mrlastyearje03, 0) + mrh.mrrecje03; --去年度次均水资源费
      end if;
    end loop;

    o_sl_1 := (case
                when n1 = 0 then
                 0
                else
                 round(mrh.mrthreesl / n1, 0)
              end);
    o_je01_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.mrthreeje01 / n1, 3)
                end);
    o_je02_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.mrthreeje02 / n1, 3)
                end);
    o_je03_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.mrthreeje03 / n1, 3)
                end);

    o_sl_2 := (case
                when n2 = 0 then
                 0
                else
                 round(mrh.mrlastsl / n2, 0)
              end);
    o_je01_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.mrlastje01 / n2, 3)
                end);
    o_je02_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.mrlastje02 / n2, 3)
                end);
    o_je03_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.mrlastje03 / n2, 3)
                end);

    o_sl_3 := (case
                when n3 = 0 then
                 0
                else
                 round(mrh.mryearsl / n3, 0)
              end);
    o_je01_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.mryearje01 / n3, 3)
                end);
    o_je02_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.mryearje02 / n3, 3)
                end);
    o_je03_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.mryearje03 / n3, 3)
                end);

    o_sl_4 := (case
                when n4 = 0 then
                 0
                else
                 round(mrh.mrlastyearsl / n4, 0)
              end);
    o_je01_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.mrlastyearje01 / n4, 3)
                end);
    o_je02_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.mrlastyearje02 / n4, 3)
                end);
    o_je03_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.mrlastyearje03 / n4, 3)
                end);
  exception
    when others then
      if c_mrh%isopen then
        close c_mrh;
      end if;
  end getmrhis;

  procedure sp_getnoread(vmid   in varchar2,
                         vcont  out number,
                         vtotal out number) is
    cursor c_mrhis is
      select * from meterreadhis where mrmid = vmid order by mrmonth;
    mrhis meterreadhis%rowtype;
  begin
    vcont  := 0;
    vtotal := 0;

    open c_mrhis;
    loop
      fetch c_mrhis
        into mrhis;
      exit when c_mrhis%notfound or c_mrhis%notfound is null;
      --未抄见范围参照《抄见率统计》中的‘非’实抄数据范围
      if not ((mrhis.mrface2 is null or mrhis.mrface2 = '10') and
          mrhis.mrecodechar <> '0') then
        vcont  := vcont + 1;
        vtotal := vtotal + 1;
      else
        vcont := 0;
      end if;
    end loop;
    close c_mrhis;
  exception
    when others then
      vcont  := 0;
      vtotal := 0;
  end;

  -- 抄表机数据生成
  --p_cont 生成抄表机发出条件
  --p_commit 提交标志
  --time 2010-03-14  by wy
  procedure sp_poshandcreate(p_smfid   in varchar2,
                             p_month   in varchar2,
                             p_bfidstr in varchar2,
                             p_oper    in varchar2,
                             p_commit  in varchar2) is
    v_sql varchar2(4000);
    type cur is ref cursor;
    c_phmr  cur;
    mr      meterread%rowtype;
    v_batch varchar2(10);
    mh      MACHINEIOLOG%rowtype;
  begin
    v_batch := FGETSEQUENCE('MACHINEIOLOG');

    mh.MILID    := v_batch; --发出到抄表机流水号
    mh.MILSMFID := p_smfid; --营销公司
    --mh.MILMACHINETYPE        :=     ;--抄表机型号
    --mh.MILMACHINEID          :=     ;--抄表机编号
    mh.MILMONTH := p_month; --抄表月份
    --mh.MILOUTROWS            :=     ;--发送条数
    mh.MILOUTDATE     := sysdate; --发送日期
    mh.MILOUTOPERATOR := p_oper; --发送操作员
    --mh.MILINDATE             :=     ;--接收日期
    --mh.MILINOPERATOR         :=     ;--接收操作员
    mh.MILREADROWS := 0; --抄见条数
    mh.MILINORDER  := 0; --接受次数
    --mh.MILOPER               :=     ;--抄表机录入人员(接收时确定)
    mh.MILGROUP := '1'; --发送模式

    insert into MACHINEIOLOG values mh;

    v_sql := ' update meterread set
MROUTID=''' || v_batch || ''' ,
MRINORDER=ROWNUM,
MROUTFLAG=''Y'',
MROUTDATE=TRUNC(sysdate)
where mrsmfid=''' || p_smfid || ''' and mrmonth=''' || p_month ||
             ''' and MRbfid in (''' || p_bfidstr || ''')
and MRREADOK=''N''
and MROUTFLAG=''N''';
    /*insert into 测试表 (STR1) values(v_sql) ;
    commit;
    return ;*/
    execute immediate v_sql;
    /*v_sql := '';
    open c_phmr for v_sql;
        loop
          fetch c_phmr
            into mr;
            null;
        end loop;
    close c_phmr;*/
    if p_commit = 'Y' then
      commit;
    end if;
  exception
    when others then
      rollback;
  end;

  -- 抄表机年批次取消

  --p_commit 提交标志
  --time 2010-06-21  by wy
  procedure sp_poshandcancel(p_smfid   in varchar2,
                             p_month   in varchar2,
                             p_bfidstr in varchar2,
                             p_oper    in varchar2,
                             p_commit  in varchar2) is
    v_sql   varchar2(4000);
    ROWCNT  number;
    v_count number;
    type cur is ref cursor;
    c_phmr    cur;
    mr        meterread%rowtype;
    v_batch   varchar2(10);
    v_bfidstr varchar2(1000);
    mh        MACHINEIOLOG%rowtype;
  begin

    update meterread
       set MROUTID   = NULL,
           MRINORDER = NULL,
           MROUTFLAG = 'N',
           MROUTDATE = TRUNC(sysdate)
     where mrsmfid = p_smfid
       and mrmonth = p_month
       and instr(p_bfidstr, mrbfid) > 0;
    if p_commit = 'Y' then
      commit;
    end if;
  exception
    when others then
      rollback;
      raise;
  end;

  -- 抄表机数据取消
  --p_batch 抄表机发出批次
  --p_commit 提交标志
  --time 2010-03-15  by wy
  procedure sp_poshanddel(p_batch in varchar2, p_commit in varchar2) is
    mr meterread%rowtype;
  begin
    update METERREAD
       set MROUTFLAG = 'N', MROUTID = null
     WHERE MROUTID = p_batch
       AND MROUTFLAG = 'Y';
    delete MACHINEIOLOG where MILID = p_batch;
    if p_commit = 'Y' then
      commit;
    end if;
  exception
    when others then
      rollback;
  end;

  -- 抄表机检查
  --p_type 抄表机检查类别
  --p_batch 抄表机发出批次
  --time 2010-03-15  by wy
  procedure sp_poshandchk(p_type in varchar2, p_batch in varchar2) is
    mr meterread%rowtype;
  begin
    null;
  exception
    when others then
      rollback;
  end;

  -- 抄表机数据导入
  --p_oper 导入操作员
  --p_type 数据导入方式
  --time 2010-03-22  by yf

  -- 抄表机数据导入
  --p_oper 导入操作员
  --p_type 数据导入方式
  --time 2010-03-22  by yf
  procedure sp_poshandimp(p_oper in varchar2, --操作员

                          p_type in varchar2 --导入方式
                          ) is
    NUM          number;
    v_count      number;
    v_count1     number;
    ROWCNT       number;
    v_tempsl     number(10);
    v_tempnum    number(10);
    v_tempnum1   number(10);
    v_addsl      number(10);
    v_tempstr    varchar2(10);
    v_ret        varchar2(10);
    v_date       date;
    v_maxcode    number(10);
    mi           meterinfo%rowtype;
    ci           custinfo%rowtype;
    md           meterdoc%rowtype;
    mr           meterread%rowtype;
    rimp         pbparmtemp%rowtype;
    mradsl       METERREADSLHIS%rowtype;
    v_mrifsubmit meterread.mrifsubmit%type;
    v_mrsmfid    meterread.mrsmfid%type;
    v_errflag    varchar2(200);
    v_ifmsg      varchar2(200);
    v_msg        varchar2(200);
    v_examine    varchar2(200);
    v_subcommit  varchar2(200);
    v_sl         number(10);
    v_fslflag    varchar2(1);
    cursor c_read is

      select case
               when trim(c9) < 0 then
                to_char(to_number(c9) * -1)
               else
                trim(c9)
             end, -- 本期抄见
             trim(null), -- 装表抄见
             trim(null), -- 拆表抄见
             trim(case
                    when to_number(c9) >= 0 then
                     to_number(c9) - to_number(c8)
                    else
                     (to_number(c9) * -1) - to_number(c8)
                  end), -- 本期水量
             trim(null), -- 其它水量
             trim(case
                    when to_number(c9) >= 0 then
                     to_number(c9) - to_number(c8)
                    else
                     (to_number(c9) * -1) - to_number(c8)
                  end), -- 合计水量
             trim(null), -- 抄表时间
             trim(c12), -- 抄表状态
             trim(null), -- 水表状况
             trim(c3), -- 抄表流水
             mRMid,
             case
               when (to_number(FPARA(MRSMFID, 'MRBASECKSL')) <
                    trim(case
                            when to_number(c9) >= 0 then
                             to_number(c9) - to_number(c8)
                            else
                             (to_number(c9) * -1) - to_number(c8)
                          end) --水量小于10不报警
                    and to_number(FPARA(MRSMFID, 'MRSLMSG')) * MRLASTSL <
                    trim(case
                                when to_number(c9) >= 0 then
                                 to_number(c9) - to_number(c8)
                                else
                                 (to_number(c9) * -1) - to_number(c8)
                              end) --水量大于上月2倍报警
                    and MRLASTSL > 1) --上月有水量数据才判断
                    or to_number(c9) < 0 --抄表机报警后 在系统中也不算费
                then
                'N'
               else
                'Y'
             end --抄表机导入负水量标志

        from pbparmtemp, meterread
       where MRID = trim(c3)
         and MRIFREC = 'N'
         and ((p_type = 'N' and MRREADOK = 'N') or p_type = 'Y');
  begin
    open c_read;
    loop
      fetch c_read
        into rimp.c16, -- 本期抄见
             rimp.c17, -- 装表抄见
             rimp.c18, -- 拆表抄见
             rimp.c19, -- 本期水量
             rimp.c20, -- 其它水量
             rimp.c21, -- 合计水量
             rimp.c25, -- 抄表时间
             rimp.c26, -- 抄表状态
             rimp.c30, -- 水表状况
             mr.mrid, -- 抄表流水
             mR.mRMid,
             v_fslflag --抄表机导入负水量标志
      ;
      exit when c_read%notfound or c_read%notfound is null;

      v_count  := 0;
      v_count1 := 0;
      if rimp.c26 = '0' then
        --判断是否已领用余量
        select count(*)
          into v_count1
          from meteraddslhis t
         where masmrid = mr.mrid;
        if v_count1 > 0 then
          --退余量
          sp_rollbackaddedsl(mr.mrid, --抄表流水
                             v_ret --返回值
                             );
        end if;
        --判断有无余量
        select count(*)
          into v_count
          from METERADDSL t
         where MASMID = mR.mRMid;

        if v_count > 0 then
          --取未用余量
          sp_fetchaddingsl(mr.mrid, --抄表流水
                           mR.mRMid, --水表号
                           v_tempnum1, --旧表止度
                           v_tempnum, --新表起度
                           v_addsl, --余量
                           v_date, --创建日期
                           v_tempstr, --加调事务
                           v_ret --返回值
                           );
          mr.mraddsl := v_addsl; --余量
          mr.mrsl    := to_number(rimp.c16) - v_tempnum + v_addsl;
        else
          mr.mraddsl := 0; --余量
          mr.mrsl    := to_number(rimp.c21);
        end if;
        /*     mr.mraddsl         :=   0 ;  --余量
        mr.mrsl           := to_number(rimp.c19 );*/
        mr.mrinputdate := sysdate;
        mr.mrrdate     := sysdate; --  to_date(rimp.c23,'yyyy-mm-dd')    ;
        mr.mrecode     := to_number(rimp.c16);
        mr.mrecodechar := trim(to_char(mr.mrecode));

        mr.mrreadok := CASE
                         WHEN rimp.c26 = '0' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        mr.mrdatasource := '5';
        --获得起码，营业所
        select MRSCODE, mrsmfid
          into v_sl, v_mrsmfid
          from meterread
         where mrid = mr.mrid;

        sp_mrslcheck(v_mrsmfid,
                     mR.mRMid,
                     v_sl,
                     mr.mrecode,
                     mr.mrsl,
                     0,
                     mr.mrrdate,
                     v_errflag,
                     v_ifmsg,
                     v_msg,
                     v_examine,
                     v_subcommit);

        /*  if v_errflag = 'N' and v_ifmsg   = 'Y' and v_examine = 'N' and v_subcommit='Y' then
          v_mrifsubmit      := 'N';
        else
            v_mrifsubmit      := 'Y';
        end if;*/

        /*v_mrifsubmit      := case when mr.mrecode-v_sl>0 then 'Y' else 'N' end  ;*/
        /*            if v_subcommit='Y' then
          v_subcommit:='N';
          else
            v_subcommit:='Y';
        end if;*/
        update meterread
           set mrinputdate  = mr.mrinputdate,
               mrrdate      = mr.mrrdate,
               mrecode      = mr.mrecode,
               mrecodechar  = mr.mrecodechar,
               mrsl         = mr.mrsl,
               mrreadok     = mr.mrreadok,
               mrdatasource = mr.mrdatasource,
               MRADDSL      = mr.mraddsl,
               mrifsubmit   = v_fslflag
         where MRID = mr.MRID;
      end if;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE mrid = mr.MRMID;
    end loop;
    close c_read;

  exception
    when others then
      if c_read%isopen then
        close c_read;
      end if;
      raise_application_error(-20010,
                              '导入失败，' || '中断客户代码:' || rimp.c2 || ', ' ||
                              sqlerrm);
      rollback;
  end;
  procedure sp_poshandimp1(p_oper in varchar2, --操作员

                           p_type in varchar2 --导入方式
                           ) is
    NUM          number;
    v_count      number;
    v_count1     number;
    ROWCNT       number;
    v_tempsl     number(10);
    v_tempnum    number(10);
    v_tempnum1   number(10);
    v_addsl      number(10);
    v_tempstr    varchar2(10);
    v_ret        varchar2(10);
    v_date       date;
    v_maxcode    number(10);
    mi           meterinfo%rowtype;
    ci           custinfo%rowtype;
    md           meterdoc%rowtype;
    mr           meterread%rowtype;
    rimp         pbparmtemp%rowtype;
    mradsl       METERREADSLHIS%rowtype;
    v_mrifsubmit meterread.mrifsubmit%type;
    v_mrsmfid    meterread.mrsmfid%type;
    v_errflag    varchar2(200);
    v_ifmsg      varchar2(200);
    v_msg        varchar2(200);
    v_examine    varchar2(200);
    v_subcommit  varchar2(200);
    v_sl         number(10);
    v_fslflag    varchar2(1);
    cursor c_read is

      select case
               when trim(c9) < 0 then
                to_char(to_number(c9) * -1)
               else
                trim(c9)
             end, -- 本期抄见
             trim(C2), -- 装表抄见
             trim(null), -- 拆表抄见
             trim(case
                    when to_number(c9) >= 0 then
                     to_number(c9) - to_number(c8)
                    else
                     (to_number(c9) * -1) - to_number(c8)
                  end), -- 本期水量
             trim(null), -- 其它水量
             trim(case
                    when to_number(c9) >= 0 then
                     to_number(c9) - to_number(c8)
                    else
                     (to_number(c9) * -1) - to_number(c8)
                  end), -- 合计水量
             trim(null), -- 抄表时间
             trim(c12), -- 抄表状态
             trim(null), -- 水表状况
             trim(c3), -- 抄表流水
             mRMid,
             case
               when (to_number(FPARA(MRSMFID, 'MRBASECKSL')) <
                    trim(case
                            when to_number(c9) >= 0 then
                             to_number(c9) - to_number(c8)
                            else
                             (to_number(c9) * -1) - to_number(c8)
                          end) --水量小于10不报警
                    and to_number(FPARA(MRSMFID, 'MRSLMSG')) * MRLASTSL <
                    trim(case
                                when to_number(c9) >= 0 then
                                 to_number(c9) - to_number(c8)
                                else
                                 (to_number(c9) * -1) - to_number(c8)
                              end) --水量大于上月2倍报警
                    and MRLASTSL > 1) --上月有水量数据才判断
                    or to_number(c9) < 0 --抄表机报警后 在系统中也不算费
                then
                'N'
               else
                'Y'
             end --抄表机导入负水量标志

        from pbparmtemp, meterread
       where MRMCODE = trim(c2)
         and MRIFREC = 'N'
         and ((p_type = 'N' and MRREADOK = 'N') or p_type = 'Y');
  begin
    open c_read;
    loop
      fetch c_read
        into rimp.c16, -- 本期抄见
             rimp.c17, -- 装表抄见
             rimp.c18, -- 拆表抄见
             rimp.c19, -- 本期水量
             rimp.c20, -- 其它水量
             rimp.c21, -- 合计水量
             rimp.c25, -- 抄表时间
             rimp.c26, -- 抄表状态
             rimp.c30, -- 水表状况
             mr.mrid, -- 抄表流水
             mR.mRMid,
             v_fslflag --抄表机导入负水量标志
      ;
      exit when c_read%notfound or c_read%notfound is null;

      v_count  := 0;
      v_count1 := 0;
      if rimp.c26 = '0' then
        --判断是否已领用余量
        select count(*)
          into v_count1
          from meteraddslhis t
         where masmrid = mr.mrid;
        if v_count1 > 0 then
          --退余量
          sp_rollbackaddedsl(mr.mrid, --抄表流水
                             v_ret --返回值
                             );
        end if;
        --判断有无余量
        select count(*)
          into v_count
          from METERADDSL t
         where MASMID = mR.mRMid;

        if v_count > 0 then
          --取未用余量
          sp_fetchaddingsl(mr.mrid, --抄表流水
                           mR.mRMid, --水表号
                           v_tempnum1, --旧表止度
                           v_tempnum, --新表起度
                           v_addsl, --余量
                           v_date, --创建日期
                           v_tempstr, --加调事务
                           v_ret --返回值
                           );
          mr.mraddsl := v_addsl; --余量
          mr.mrsl    := to_number(rimp.c16) - v_tempnum + v_addsl;
        else
          mr.mraddsl := 0; --余量
          mr.mrsl    := to_number(rimp.c21);
        end if;
        --CXC
        MR.Mrmcode := rimp.c17;
        /*     mr.mraddsl         :=   0 ;  --余量
        mr.mrsl           := to_number(rimp.c19 );*/
        mr.mrinputdate := sysdate;
        mr.mrrdate     := sysdate; --  to_date(rimp.c23,'yyyy-mm-dd')    ;
        mr.mrecode     := to_number(rimp.c16);
        mr.mrecodechar := trim(to_char(mr.mrecode));

        mr.mrreadok := CASE
                         WHEN rimp.c26 = '0' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        mr.mrdatasource := '5';
        --获得起码，营业所
        select MRSCODE, mrsmfid
          into v_sl, v_mrsmfid
          from meterread
         where MRmCODE = mr.Mrmcode;

        sp_mrslcheck(v_mrsmfid,
                     mR.mRMid,
                     v_sl,
                     mr.mrecode,
                     mr.mrsl,
                     0,
                     mr.mrrdate,
                     v_errflag,
                     v_ifmsg,
                     v_msg,
                     v_examine,
                     v_subcommit);

        /*  if v_errflag = 'N' and v_ifmsg   = 'Y' and v_examine = 'N' and v_subcommit='Y' then
          v_mrifsubmit      := 'N';
        else
            v_mrifsubmit      := 'Y';
        end if;*/

        /*v_mrifsubmit      := case when mr.mrecode-v_sl>0 then 'Y' else 'N' end  ;*/
        /*            if v_subcommit='Y' then
          v_subcommit:='N';
          else
            v_subcommit:='Y';
        end if;*/
        update meterread
           set mrinputdate  = mr.mrinputdate,
               mrrdate      = mr.mrrdate,
               mrecode      = mr.mrecode,
               mrecodechar  = mr.mrecodechar,
               mrsl         = mr.mrsl,
               mrreadok     = mr.mrreadok,
               mrdatasource = mr.mrdatasource,
               MRADDSL      = mr.mraddsl,
               mrifsubmit   = v_fslflag,
               MRINPUTPER   = p_oper
         where MRmCODE = mr.Mrmcode;
      end if;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE mrid = mr.MRMID;
    end loop;
    close c_read;

  exception
    when others then
      if c_read%isopen then
        close c_read;
      end if;
      raise_application_error(-20010,
                              '导入失败，' || '中断客户代码:' || rimp.c2 || ', ' ||
                              sqlerrm);
      rollback;
  end;

  -- 抄表机数据导入
  --p_oper 导入操作员
  --p_type 数据导入方式
  --time 2010-03-22  by yf
  procedure sp_poshandimp_ycb(p_oper  in varchar2, --操作员
                              p_type  in varchar2, --导入方式
                              p_bfid  out varchar2,
                              p_bfid1 out varchar2) is
    NUM          number;
    v_count      number;
    v_count1     number;
    ROWCNT       number;
    v_tempsl     number(10);
    v_tempnum    number(10);
    v_addsl      number(10);
    v_tempstr    varchar2(10);
    v_ret        varchar2(10);
    v_date       date;
    v_maxcode    number(10);
    mi           meterinfo%rowtype;
    ci           custinfo%rowtype;
    md           meterdoc%rowtype;
    mr           meterread%rowtype;
    rimp         pbparmtemp%rowtype;
    mradsl       METERREADSLHIS%rowtype;
    v_mrifsubmit meterread.mrifsubmit%type;
    v_sl         number(10);
    v_outcode    varchar2(4000);
    v_bfid       varchar2(4000);
    v_codecount  number;
    v_mrscode    number(10);
    v_fslflag    varchar2(10);
    cursor c_read is

      select trim(trunc(c4)), -- 本期抄见
             trim(null), -- 装表抄见
             trim(null), -- 拆表抄见
             trim(null), -- 本期水量
             trim(null), -- 其它水量
             trim(null), -- 合计水量
             trim(c5), -- 抄表时间
             case
               when trim(c4) is null then
                '-1'
               when trim(c4) - MRSCODE >= 0 then
                '1'
               else
                '0'
             end, -- 抄表状态              , -- 抄表状态(鄂州远传表没有未抄见)
             trim(null), -- 水表状况
             trim(null), -- 抄表流水
             mRmcode,
             case
               when (to_number(FPARA(MRSMFID, 'MRBASECKSL')) <
                    trim(case
                            when to_number(c9) >= 0 then
                             to_number(c9) - to_number(c8)
                            else
                             (to_number(c9) * -1) - to_number(c8)
                          end) --水量小于10不报警
                    and to_number(FPARA(MRSMFID, 'MRSLMSG')) * MRLASTSL <
                    trim(case
                                when to_number(c9) >= 0 then
                                 to_number(c9) - to_number(c8)
                                else
                                 (to_number(c9) * -1) - to_number(c8)
                              end) --水量大于上月2倍报警
                    and MRLASTSL > 1) --上月有水量数据才判断
                    or to_number(c9) < 0 --抄表机报警后 在系统中也不算费
                then
                'N'
               else
                'Y'
             end --抄表机导入负水量标志

        from pbparmtemp, meterread, meterinfo
       where MRIFREC = 'N'
         and MICODE = trim(c1)
         and miid = mrmid
         and
            /*mrmonth=trim(c2)||'.'||trim(c3) and*/
             ((p_type = 'N' and MRREADOK = 'N') or p_type = 'Y')
             and
             to_number(trim(c4))>to_number( FSYSPARA('1103') );
    cursor c_bfid is
      select mrbfid, count(*)
        from meterread
       where mrbfid in (v_outcode)
         and mrreadok = 'N'
       group by mrbfid;
  begin
    select connstr(bf)
      into p_bfid
      from (select distinct mibfid bf
              from pbparmtemp, meterinfo, meterread
             where trim(c1) = micode
               and miid = mrmid);
    open c_read;
    loop
      fetch c_read
        into rimp.c16, -- 本期抄见
             rimp.c17, -- 装表抄见
             rimp.c18, -- 拆表抄见
             rimp.c19, -- 本期水量
             rimp.c20, -- 其它水量
             rimp.c21, -- 合计水量
             rimp.c25, -- 抄表时间
             rimp.c26, -- 抄表状态
             rimp.c30, -- 水表状况
             mr.mrid, -- 抄表流水
             mR.mrmcode,
             v_fslflag;
      exit when c_read%notfound or c_read%notfound is null;

      null;

      v_count  := 0;
      v_count1 := 0;
      --  if rimp.c26 <> '0' then
      --  -判断是否已领用余量
      select count(*)
        into v_count1
        from meteraddslhis, meterread
       where masmrid = mrid
         and mrmcode = mr.mrmcode;
      if v_count1 > 0 then
        --退余量
        sp_rollbackaddedsl(mr.mrid, --抄表流水
                           v_ret --返回值
                           );
      end if;
      --判断有无余量
      select count(*)
        into v_count
        from METERADDSL, meterread
       where MASMID = mrmid
         and mrmcode = mr.mrmcode;
      mr.mrecode     := to_number(rimp.c16);
      mr.mrecodechar := trim(to_char(rimp.c16));
      if v_count > 0 then
        --取未用余量
        sp_fetchaddingsl(mr.mrid, --抄表流水
                         mR.mRMid, --水表号
                         v_tempnum, --旧表止度
                         v_tempnum, --新表起度
                         v_addsl, --余量
                         v_date, --创建日期
                         v_tempstr, --加调事务
                         v_ret --返回值
                         );
        mr.mraddsl := v_addsl; --余量
        mr.mrsl    := to_number(rimp.c16) - v_tempnum + v_addsl;
      else
        select MRSCODE into v_sl from meterread where mrmcode = mr.mrmcode;
        mr.mraddsl := 0; --余量
        mr.mrsl    := to_number(rimp.c16) - v_sl;
        --如果本期抄码小于上期抄码，默认为0水量
        if rimp.c26 = '0' then
          mr.MReCODE := v_sl;
          mr.mrsl    := 0;
        end if;
      end if;

      --if rimp.c26='1' then
      /*   select MRSCODE into v_sl from meterread where mrmid=mr.mrmid;
      mr.mraddsl         :=   0 ;  --余量
      if rimp.c26<>'0' then
        mr.mrsl           := to_number(rimp.c16 )-v_sl;
        mr.mrecode        := to_number(rimp.c16 ) ;
        mr.mrecodechar    := trim(to_char(mr.mrecode))  ;
      else
        select max(mrscode ) into v_mrscode from meterread where  MRMID = mr.MRMID;
        mr.mrecode        := to_number(rimp.c16 ) ;
        mr.mrsl   :=  to_number(rimp.c16 )+  mr.mraddsl  ;
        mr.mrecodechar    := trim(to_char(rimp.c16))  ;
      end if;*/
      mr.mrinputdate := sysdate;
      if instr(rimp.c25,' ')=0 then
         mr.mrrdate  := to_date(substr(rimp.c25,1,10),'YYYY-MM-DD');
      else
         mr.mrrdate  := to_date(substr(rimp.c25,1,instr(rimp.c25,' ')),'YYYY-MM-DD');
      end if;
       --  to_date(rimp.c23,'yyyy-mm-dd')    ;

      mr.mrreadok     := 'Y';
      mr.mrdatasource := '5';
      v_mrifsubmit    := 'Y';

      update meterread
         set mrinputdate  = mr.mrinputdate,
             mrrdate      = mr.mrrdate,
             mrecode      = mr.mrecode,
             mrecodechar  = mr.mrecodechar,
             mrsl         = mr.mrsl,
             mrreadok     = mr.mrreadok,
             mrdatasource = mr.mrdatasource,
             MRADDSL      = mr.mraddsl,
             mrifsubmit   = v_fslflag,
             MRINPUTPER   = p_oper
       where MRMCODE = mr.mrmcode;

      --end if;
      --  end if;
      if rimp.c26 = '0' then
        update meterread set mrface = '8' where mrmcode = mR.Mrmcode;
      elsif rimp.c26 = '-1' then
        select mrbfid
          into v_bfid
          from meterread
         where mrmcode = mr.mrmcode;
        v_bfid := v_bfid || ',';
        if instr(v_outcode, v_bfid) = 0 or v_outcode is null then
          v_outcode := v_outcode || v_bfid;
        end if;
      end if;
      --UPDATE METERREAD SET MROUTFLAG = 'N' WHERE mrid = mr.MRMID;
    end loop;
    close c_read;

    if v_outcode is not null then
      --判断是否有未录入水表号
      v_outcode := substr(v_outcode, 1, length(v_outcode) - 1);
      v_bfid    := '';
      open c_bfid;
      loop
        fetch c_bfid
          into v_bfid, v_codecount;
        exit when c_bfid%notfound or c_bfid%notfound is null;
        p_bfid1 := '表册号:【' || v_bfid || '】' || v_codecount || '条未录入;' ||
                   chr(10);
      end loop;
      close c_bfid;
    end if;
  exception
    when others then
      if p_bfid = '' then
        raise_application_error(-20010, '导入失败，抄表机无数据');
      end if;
      if c_read%isopen then
        close c_read;
      end if;
      --raise_application_error(-20010,'导入失败，'||'中断客户代码:'||rimp.c2||', '||sqlerrm);
      rollback;
  end;

   procedure sp_poshandimp_tp800(p_oper in varchar2, --操作员

                                p_type in varchar2 --导入方式
                                ) is
    --c1 mrid
    --c14 起码
    --c15 止码
    --c24 抄见标志
    --c18 抄见日期
    NUM          number;
    v_count      number;
    v_count1     number;
    ROWCNT       number;
    v_tempsl     number(10);
    v_tempnum    number(10);
    v_tempnum1   number(10);
    v_addsl      number(10);
    v_tempstr    varchar2(10);
    v_ret        varchar2(10);
    v_date       date;
    v_maxcode    number(10);
    mi           meterinfo%rowtype;
    ci           custinfo%rowtype;
    md           meterdoc%rowtype;
    mr           meterread%rowtype;
    rimp         pbparmtemp%rowtype;
    mradsl       METERREADSLHIS%rowtype;
    v_mrifsubmit meterread.mrifsubmit%type;
    v_mrsmfid    meterread.mrsmfid%type;
    v_errflag    varchar2(200);
    v_ifmsg      varchar2(200);
    v_msg        varchar2(200);
    v_examine    varchar2(200);
    v_subcommit  varchar2(200);
    v_sl         number(10);
    v_fslflag    varchar2(1);
    cursor c_read is

      select case
               when to_number(c15) < 0 then
                0
               else
                to_number(c15)
             end, -- 本期抄见(抄表水量为负数，则为0)
             trim(C3), -- 装表抄见
             trim(null), -- 拆表抄见
             case
               when to_number(c16) < 0 then
                0
               else
                to_number(c16)
             end, -- 本期水量
             trim(null), -- 其它水量
             case
               when to_number(c16) < 0 then
                0
               else
                to_number(c16)
             end, -- 合计水量
             trim(to_date(c18, 'yyyymmdd')), -- 抄表时间
             trim(trim(c24)), -- 抄见标志
             trim(null), -- 水表状况
             trim(c1), -- 抄表流水
             mRMid,
             null,--抄表机导入负水量标志
             case
               when trim(c21) ='0' then
                '1'
               else
                trim(c21)
             end --水表故障标志

        from pbparmtemp,
             meterread

       where MRID = trim(c1)
         and MRIFREC = 'N'
         and ((p_type = 'N' and MRREADOK = 'N') or p_type = 'Y');
  begin
    open c_read;
    loop
      fetch c_read
        into rimp.c16, -- 本期抄见
             rimp.c17, -- 装表抄见
             rimp.c18, -- 拆表抄见
             rimp.c19, -- 本期水量
             rimp.c20, -- 其它水量
             rimp.c21, -- 合计水量
             rimp.c25, -- 抄表时间
             rimp.c26, -- 抄表状态
             rimp.c30, -- 水表状况
             mr.mrid, -- 抄表流水
             mR.mRMid,
             v_fslflag,              --抄表机导入负水量标志
             mr.MRFACE ;   -----抄表故障值
      exit when c_read%notfound or c_read%notfound is null;

      v_count  := 0;
      v_count1 := 0;
      if rimp.c26 = 'Y' then
        --判断是否已领用余量
        select count(*)
          into v_count1
          from meteraddslhis t
         where masmrid = mr.mrid;
        if v_count1 > 0 then
          --退余量
          sp_rollbackaddedsl(mr.mrid, --抄表流水
                             v_ret --返回值
                             );
        end if;
        --判断有无余量
        select count(*)
          into v_count
          from METERADDSL t
         where MASMID = mR.mRMid;

        if v_count > 0 then
          --取未用余量
          sp_fetchaddingsl(mr.mrid, --抄表流水
                           mR.mRMid, --水表号
                           v_tempnum1, --旧表止度
                           v_tempnum, --新表起度
                           v_addsl, --余量
                           v_date, --创建日期
                           v_tempstr, --加调事务
                           v_ret --返回值
                           );
          mr.mraddsl := v_addsl; --余量
          mr.mrsl    := to_number(rimp.c16) - v_tempnum + v_addsl;
        else
          mr.mraddsl := 0; --余量
          mr.mrsl    := to_number(rimp.c21);
        end if;
        --CXC
        MR.Mrmcode := rimp.c17;
        /*     mr.mraddsl         :=   0 ;  --余量
        mr.mrsl           := to_number(rimp.c19 );*/
        mr.mrinputdate := sysdate;
        mr.mrrdate     := sysdate; --  to_date(rimp.c23,'yyyy-mm-dd')    ;
        mr.mrecode     := to_number(rimp.c16);
        mr.mrecodechar := trim(to_char(mr.mrecode));

        mr.mrreadok := CASE
                         WHEN rimp.c26 = '0' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        mr.mrdatasource := '5';
        --获得起码，营业所
        select MRSCODE, mrsmfid
          into v_sl, v_mrsmfid
          from meterread
         where mrid = mr.mrid;

        sp_mrslcheck(v_mrsmfid,
                     mR.mRMid,
                     v_sl,
                     mr.mrecode,
                     mr.mrsl,
                     0,
                     mr.mrrdate,
                     v_errflag,
                     v_ifmsg,
                     v_msg,
                     v_examine,
                     v_subcommit);

        /*  if v_errflag = 'N' and v_ifmsg   = 'Y' and v_examine = 'N' and v_subcommit='Y' then
          v_mrifsubmit      := 'N';
        else
            v_mrifsubmit      := 'Y';
        end if;*/

        /*v_mrifsubmit      := case when mr.mrecode-v_sl>0 then 'Y' else 'N' end  ;*/
        if v_subcommit = 'Y' then
          v_subcommit := 'N';
        else
          v_subcommit := 'Y';
        end if;
        update meterread
           set mrinputdate  = mr.mrinputdate,
               mrrdate      = mr.mrrdate,
               mrecode      = mr.mrecode,
               mrecodechar  = mr.mrecodechar,
               mrsl         = mr.mrsl,
               mrreadok     = 'Y',
               mrdatasource = mr.mrdatasource,
               MRADDSL      = mr.mraddsl,
               mrifsubmit   = v_subcommit,
               MRINPUTPER   = p_oper,
               mrface       = mr.mrface
         where MRmCODE = mr.Mrmcode;
      end if;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE mrid = mr.MRMID;
    end loop;
    close c_read;

  exception
    when others then
      if c_read%isopen then
        close c_read;
      end if;
      raise_application_error(-20010,
                              '导入失败，' || '中断客户代码:' || rimp.c2 || ', ' ||
                              sqlerrm);
      rollback;
  end;

  procedure sp_poshandcreate_tp900(p_smfid   in varchar2,
                                   p_month   in varchar2,
                                   p_bfidstr in varchar2,
                                   p_oper    in varchar2,
                                   p_commit  in varchar2) is
    v_sql varchar2(4000);
    type cur is ref cursor;
    c_phmr  cur;
    mr      meterread%rowtype;
    v_batch varchar2(10);
    mh      MACHINEIOLOG%rowtype;
  begin
    v_batch := FGETSEQUENCE('MACHINEIOLOG');

    mh.MILID    := v_batch; --发出到抄表机流水号
    mh.MILSMFID := p_smfid; --营销公司
    --mh.MILMACHINETYPE        :=     ;--抄表机型号
    --mh.MILMACHINEID          :=     ;--抄表机编号
    mh.MILMONTH := p_month; --抄表月份
    --mh.MILOUTROWS            :=     ;--发送条数
    mh.MILOUTDATE     := sysdate; --发送日期
    mh.MILOUTOPERATOR := p_oper; --发送操作员
    --mh.MILINDATE             :=     ;--接收日期
    --mh.MILINOPERATOR         :=     ;--接收操作员
    mh.MILREADROWS := 0; --抄见条数
    mh.MILINORDER  := 0; --接受次数
    --mh.MILOPER               :=     ;--抄表机录入人员(接收时确定)
    mh.MILGROUP := '1'; --发送模式

    insert into MACHINEIOLOG values mh;

    v_sql := ' update meterread set
MROUTID=''' || v_batch || ''' ,
MRINORDER=ROWNUM,
MROUTFLAG=''Y'',
MROUTDATE=TRUNC(sysdate)
where mrsmfid=''' || p_smfid || ''' and mrmonth=''' || p_month ||
             ''' and MRbfid in (''' || p_bfidstr || ''')
and MRREADOK=''N''
and MROUTFLAG=''N''';

    execute immediate v_sql;
    insert into pbparmtemp
      (c1, c2)
      select mrid, mrmcode
        from meterread
       where mrsmfid = p_smfid
         and mrmonth = p_month
         and mrbfid = p_bfidstr;
    if p_commit = 'Y' then
      commit;
    end if;
  exception
    when others then
      rollback;
  end;
 function  fbdsl(p_mrid   in varchar2)  RETURN VARCHAR2
  as
      mr   meterread%rowtype;
      MRSLMAX  number;
     v_mrbasecksl number;
  begin

       select * into mr from meterread where mrid=p_mrid;
       select to_number(FPARA(mr.mrsmfid, 'MRSLMAX')) into   MRSLMAX from dual;
       select to_number(FPARA(mr.mrsmfid, 'MRBASECKSL')) into   v_mrbasecksl from dual;
       if  mr.mrlastsl>0 and ( ( mr.mrsl>(mr.mrlastsl*(1+MRSLMAX)))  or  ( mr.mrsl<(mr.mrlastsl*(1-MRSLMAX)))  )and mr.mrsl>v_mrbasecksl  then
            return 'N';
       else
            return 'Y';
       end if;
    exception
        when others  then
            return 'Y';
  end;

end;
/

