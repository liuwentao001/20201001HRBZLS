create or replace package body pg_find is

  /*
  功能：前台页面综合查询_详细信息
  参数说明
  p_yhid          用户id
  p_bookno        表册编码
  p_sbid          水表编码
  p_manageno      营销公司编码
  out             输出结果集
  */
  procedure find_zhcx_xxxx(p_yhid in varchar2,p_bookno in varchar2,p_sbid in varchar2,p_manageno in varchar2 ,out_tab out sys_refcursor) is
    begin
    open out_tab for select
      t.yhid 用户编号,
      t.manage_no  营销公司编码,
      t.yhname 用户名,
      t.yhadr 用户地址,
      t.yhstatus 用户状态,--【syscuststatus】(1正常/7销户/2预立户)
      t.yhnewdate 立户日期,
      t.yhidentitylb 证件类型,--(1-身份证 2-营业执照  0-无)
      t.yhidentityno 证件号码,
      t.yhmtel 移动电话,
      t.yhconnectper 联系人,
      t.yhconnecttel 联系电话,
      t.yhprojno 工程编号,--(水账标识号)
      t.yhfileno 档案号,--(供水合同号)
      t.yhmemo 备注信息,
      sb.sbiftax 是否税票,
      sb.sbtaxno 税号,
      sb.sbifmp 混合用水标志,--(y-是,n-否 )
      sb.sbifcharge 是否计费,--(y-是,n-否 )
      sb.sbifsl 是否计量,--(y-是,n-否 )
      sb.sbifchk 是否考核表,--(y-是,n-否 )
      sb.sbpid 上级水表编号,
      sb.book_no 表册编码,
      sb.area_no 区域,
      sb.trade_no 行业分类,--【metersortframe】(20政府/21视同/22区域用户/26集体户/1居民/2企业/3特困企业/4破产企业/5增值税企业/6银行/7市直行政事业/8区行政事业/10学校/11医院/12环卫公厕/13非环卫公厕/14绿  化/15暂不开票/16销  户/17表  拆/18分  户/19报  停/23农郊用户/24校核表/25消防表/30一户一表)
      sb.sbinsdate 装表日期,
      md.sbid  水表档案编号,--(户号，入库时为空)
      md.mdno 表身码,
      md.barcode 条形码,
      md.rfid 电子标签,
      md.mdcaliber 表口径,
      md.mdbrand 表厂家,
      sb.sbname2 招牌名称,--(小区名）
      sb.sbusenum 户籍人数,
      sb.sbrecdate 本期抄见日期,
      sb.sbrecsl 本期抄见水量,
      sb.sbrcodechar 本期读数,
      sb.sbinscode 新装起度,
      sb.sbinsdate 装表日期,
      sb.sbinsper 安装人,
      sb.sbposition 水表接水地址,
      sb.sbchargetype 收费方式,--(x坐收m走收)
      sb.sbcommunity 远传表小区号,
      sb.sbremoteno 远传表号,--采集机（哈尔滨：借用建账存放合收主表表身码）
      sb.sbremotehubno 远传表hub号,--端口（哈尔滨：借用存放用户编号clt_id，坐收老号查询）
      sb.sbhtbh 合同编号,
      sb.sbmemo 备注信息,
      sb.sbicno ic卡号,
      sb.sbusenum 户籍人数,
      sb.sbface 水表故障,--(01正常/02表异常/03零水量)
      sb.sbstatus 有效状态,--【sysmeterstatus】(28基建临时用水/27移表中/19销户中/21欠费停水/24故障换表中/25周检中/7销户/1立户/2预立户/29无表/30故障表/31基建正式用水/32基建拆迁止水/34营销部收入用户/36预存冲正中/33补缴用户/35周期换表中)
      sb.sbrpid 计件类型,
      sb.sbface3 非常计量,
      sb.sbsaving 预存款余额,
      sb.sbjtkssj11 阶梯开始日期
    from
      ys_yh_custinfo t,
      ys_yh_sbinfo sb,
      ys_yh_sbdoc md
    where
      t.yhid = sb.yhid
      and sb.hire_code = t.hire_code
      and sb.sbid = md.sbid
      and (t.yhid = p_yhid or p_yhid is null)
      and (sb.book_no = p_bookno or p_bookno is null)
      and (sb.sbid = p_sbid or p_sbid is null)
      and (t.manage_no = p_manageno or p_manageno is null)
    ;
  end find_zhcx_xxxx;

  /*
  功能：柜台缴费页面基本信息查询
  参数说明
  p_yhid          用户id
  p_yhname        用户名
  p_sbposition    用水地址
  p_yhmtel        移动电话
  out             输出结果集
  */
  procedure find_gtjf_jbxx(p_yhid in varchar2,p_yhname in varchar2,p_sbposition in varchar2,p_yhmtel in varchar2 ,out_tab out sys_refcursor) is
    begin
    open out_tab for select
      t.yhname 用户名称,
      t.yhid 客户代码,
      t.yhconnecttel 联系电话,
      t.yhmtel 移动电话,
      sb.sbposition 用水地址,
      case t.yhstatus when '1' then '正常' when '7' then '销户' when '2' then '预立户' end 用户状态,--(1正常/7销户/2预立户)
      sb.book_no 表册,
      price_name||'('||price||')' 价格分类,
      case sb.sbchargetype when 'X' then '坐收' when 'M' then '走收' end 收费方式,-- 收费方式(x坐收m走收)
      dp.dept_name 营销公司, 
      t.yhifinv 增值税发票,--是否普票（哈尔滨：借用做是否已打印增值税收据，reclist取值，置空）
      sb.sbpriflag 合收标志,--合收表标志(y-合收表标志,n-非合收主表 )
      sb.sbpriflag 合收主表,
      sb.sbifmp 混合用水,--混合用水标志(y-是,n-否 )
      sum(nvl(sb.sbsaving,0)) 预存余额
    from 
      ys_yh_custinfo t,
      ys_yh_sbinfo sb,
      base_dept dp,
      (select bas_price_name.price_no,bas_price_name.price_name,sum(bas_price_detail.price) price
      from bas_price_name,bas_price_detail 
      where bas_price_name.price_no=bas_price_detail.price_no 
      group by bas_price_name.price_no,bas_price_name.price_name) p
    where
      t.yhid = sb.yhid
      and sb.hire_code = t.hire_code
      and t.manage_no = dp.dept_no
      and dp.hire_code = 'kings'
      and sb.price_no = p.price_no
      and (t.yhid like '%'||p_yhid||'%' or p_yhid is null)
      and (t.yhname like '%'||p_yhname||'%' or p_yhname is null)
      and (sb.sbposition like '%'||p_sbposition||'%' or p_sbposition is null)
      and (t.yhmtel like '%'||p_yhmtel||'%' or p_yhmtel is null)
    group by t.yhname,
      t.yhid,
      t.yhconnecttel,
      t.yhmtel,
      sb.sbposition,
      t.yhstatus,
      sb.book_no,
      price_name||'('||price||')',
      sb.sbchargetype,
      dp.dept_name,
      t.yhifinv,
      sb.sbpriflag,
      sb.sbpriflag,
      sb.sbifmp
      ;
  end find_gtjf_jbxx;
  
  /*
  功能：柜台缴费页面欠费信息查询
  参数说明
  p_yhid          用户id
  out             输出结果集
  */
  procedure find_gtjf_qf(p_yhid in varchar2,out_tab out sys_refcursor) is
    begin
    open out_tab for select
       armonth   账务月份, 
        ardate    账务日期, 
        arscode   起数,   
        arecode   止数,   
        arsl    应收水量, 
        arje    应收金额, 
        arpaidje  销账金额, 
        arznj   违约金,   
        arzndate  违约金起算日,
        arpfid 价格分类, 
        artrans   应收事务, 
        arid    流水号   
      from ys_zw_arlist 
      where 
        arpaidflag='N'         --销帐标志(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
        and arreverseflag='N'  --冲正标志（N为正常，Y为冲正）
        and aroutflag='N'      --发出标志(Y-发出 N-未发出)
        and yhid = p_yhid
      order by ardatetime desc
      ;
  end find_gtjf_qf;
  
  /*
  功能：柜台缴费页面欠费信息明细查询
  参数说明
  p_arid          流水号
  out             输出结果集
  */
  procedure find_gtjf_qfmx(p_arid in varchar2,out_tab out sys_refcursor) is
    begin
    open out_tab for select
      ardpiid 费用项目,
      item_name 费用项目名称,
      ardysje 应收金额,
      price_name||'('||price||')' 价格分类,
      ardclass 阶梯级别,
      ardysdj 单价,
      ardyssl 水量,
      ardysje 金额,
      ardznj 违约金
    from ys_zw_ardetail ard, 
       ys_zw_arlist ar,
      (select bas_price_name.price_no,bas_price_name.price_name,sum(bas_price_detail.price) price
      from bas_price_name,bas_price_detail 
      where bas_price_name.price_no=bas_price_detail.price_no 
      group by bas_price_name.price_no,bas_price_name.price_name) p,
      bas_price_item pi
    where ar.arid = ard.ardid
      and ar.arpfid = p.price_no
      and ardpiid = pi.price_item
      and ard.ardid = p_arid
    ;
  end find_gtjf_qfmx;
  
  /*
  功能：柜台缴费页面缴费入口
  参数说明
  p_yhid          用户编码
  p_arid          流水号，多个流水号用逗号分隔，例如：0000012726,70105341
  p_oper          销帐员，柜台缴费时销帐人员与收款员统一
  p_payway        资金来源
  p_payment       实收，即为（付款-找零），付款与找零在前台计算和校验
  p_gnm           功能码， 正常999 错误000
  p_cwxx          错误信息
  */
  procedure find_gtjf_jf(p_yhid in varchar2,
            p_arid in varchar2,
            p_oper     in varchar2,
            p_payway in varchar2,
            p_payment in number,
            p_gnm out varchar2,
            p_cwxx out varchar2) is
  v_sbid varchar2(10);
  v_arstr varchar2(1000);
  v_position varchar(32);
  v_paypoint varchar(32);
  v_pid varchar(32);
  begin
      --获取水表编码
      select sbid into v_sbid from ys_yh_sbinfo where yhid = p_yhid;
      
      if p_oper is not null then
	      select base_dept.dept_no into v_position from base_user join base_dept on base_user.dept_id = base_dept.id and base_user.user_name = p_oper;
        v_paypoint := v_position;
      end if;
      
      if p_arid is not null then
        --字符串转换
        --例如：0000012726,70105341 转换成 0000012726,Y*01!Y*02!Y*03!Y*04!,0,0,0,0|70105341,Y*01!Y*02!Y*03!,0,0,0,0|
        with arstr_tab as(
          select 
            --to_char(ardid||',Y*'||replace(wm_concat(distinct ardpiid),',','!Y*')||','||sum(nvl(ardznj,0))||',0,0,0') arstr
            to_char(ardid||',Y*'||replace(regexp_replace(listagg(ardpiid, ',') within group(order by ardpiid),'([^,]+)(,\1)+','\1'),',','!Y*')||'!,'||sum(nvl(ardznj,0))||',0,0,0') arstr
          from ys_zw_ardetail 
          where ardid in (select regexp_substr(p_arid, '[^,]+', 1, level) column_value from dual
                          connect by --prior dbms_random.value is not null and
                          level <= length(p_arid) - length(replace(p_arid, ',', '')) + 1) 
          group by ardid
        )
        select listagg(arstr,'|') within group(order by arstr)||'|' into v_arstr from arstr_tab;
      end if;
      
      --调用水司柜台缴费      
      pg_paid.poscustforys(p_sbid => v_sbid,
           p_arstr => v_arstr,
           p_position => v_position,
           p_oper => p_oper,
           p_paypoint => v_paypoint,
           p_payway => p_payway,
           p_payment => p_payment,
           p_batch => null,
           p_pid => v_pid);
           
     p_gnm := '999';
     p_cwxx := '缴费成功';
  exception
    when others then
      p_gnm := '000';
      p_cwxx := '缴费失败';
  end find_gtjf_jf;
  
  /*
  功能：柜台缴费页面缴费记录查询
  参数说明
  p_yhid          用户id
  out             输出结果集
  */
  procedure find_gtjf_jfjl(p_yhid in varchar2,out_tab out sys_refcursor) is
  begin
    open out_tab for select 
      pdatetime 缴费时间,  -- ys_zw_paidment  付款交易【p】 pdatetime 发生日期
      base_user.true_name 销账人员,  --  ys_zw_paidment  付款交易【p】 pdpers  销帐人员
      paidment 实收金额,  --  ys_zw_paidment  付款交易【p】 paidment  付款金额
      pdspje 销账金额,  --  ys_zw_paidment  付款交易【p】 pdspje  销帐金额（如果销帐交易中水费，销帐金额则为水费金额，如果是预存帐为0）
      pdwyj 违约金,
      pdsavingqc 期初预存,  --  ys_zw_paidment  付款交易【p】 pdsavingqc  期初预存余额
      pdsavingbq 本期预存,  --  ys_zw_paidment  付款交易【p】 pdsavingbq  本期发生预存金额
      pdsavingqm 期末预存,  --  ys_zw_paidment  付款交易【p】 pdsavingqm  期末预存余额
      swms_sys_paidtrans.dic_name 缴费事务,  --  ys_zw_paidment  付款交易【p】 pdtran  缴费事务(paidtrans)
      pdpaypoint 缴费地点,  --  ys_zw_paidment  付款交易【p】 pdpaypoint  缴费地点（可细化到窗口）
      preverseflag 冲正标志,  --  ys_zw_paidment  付款交易【p】 preverseflag  冲正标志（收水费收预存是为n,冲水费冲预存被冲实收和冲实收产生负帐匀为y）
      coalesce(swms_sys_chequetype.dic_name,pdpayway) 付款方式,  --  ys_zw_paidment  付款交易【p】 pdpayway  付款方式(xj-现金 zp-支票 mz-抹账 dc-倒存)
      pddate 账务日期,  --  ys_zw_paidment  付款交易【p】 pddate  帐务日期（收费日期）
      pdmonth 缴费月份,  -- ys_zw_paidment  付款交易【p】 pdmonth 缴费月份
      pid 实收流水,  -- ys_zw_paidment  付款交易【p】 pid 流水号
      pdmemo 备注  --  ys_zw_paidment  付款交易【p】 pdmemo  备注
    from ys_zw_paidment
      left join (select dic_value,dic_name from base_user_dictionary where parent_id = (select id from base_user_dictionary where dic_value='SWMS_SYS_PAIDTRANS')) swms_sys_paidtrans
        on swms_sys_paidtrans.dic_value = ys_zw_paidment.pdtran
      left join (select dic_value,dic_name from base_user_dictionary where parent_id = (select id from base_user_dictionary where dic_value='SWMS_SYS_CHEQUETYPE')) swms_sys_chequetype
        on swms_sys_chequetype.dic_value = ys_zw_paidment.pdpayway
      left join base_user 
        on base_user.user_name = pdpers
    where yhid=p_yhid
    ;
  end find_gtjf_jfjl;

  /*
  功能：柜台缴费页面缴费记录明细
  参数说明
  p_arpid         实收流水id
  out             输出结果集
  */
  procedure find_gtjf_jfjlmx(p_arpid in varchar2,out_tab out sys_refcursor) is
  begin
    open out_tab for select 
      yhid 客户代码,
      arrdate 抄表日期,
      armonth 账务月份,
      ardate 账务日期,
      arscode 起数,
      arecode 止数,
      arsl 应收水量,
      arje 应收金额,
      arznj 违约金
    from ys_zw_arlist 
    where arpid=p_arpid
    ;
  end find_gtjf_jfjlmx;
  
  /*
  功能：柜台缴费页面抄表记录查询
  参数说明
  p_yhid          用户id
  out             输出结果集
  */
  procedure find_gtjf_cbjl(p_yhid in varchar2,out_tab out sys_refcursor) is
  begin
    open out_tab for select 
      yhid 客户代码  ,-- ys_cb_mtread  抄表库【cbmr】 yhid  用户编号
      cbmrmonth 抄表月份  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrmonth 抄表月份
      cbmrrdate 抄表日期  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrrdate 抄表日期
      cbmrscode 起码  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrscode 上期抄见
      cbmrecode 止码  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrecode 本期抄见
      cbmrsl 抄表水量  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrsl  本期水量
      cbmrrecsl 计费水量  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrrecsl 应收水量
      cbmrcarrysl 校验水量  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrcarrysl 校验水量
      cbmrchkflag 已复核 ,-- ys_cb_mtread  抄表库【cbmr】 cbmrchkflag 复核标志(y-是 n-否)
      cbmrifhalt 是否停算  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrifhalt  系统停算(y-是 n-否)
      cbmrlastsl 上次水量  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrlastsl  上次抄表水量
      cbmrthreesl 前三次抄表水量 ,-- ys_cb_mtread  抄表库【cbmr】 cbmrthreesl 前三月抄表水量
      cbmryearsl 去年同期抄表水量  ,-- ys_cb_mtread  抄表库【cbmr】 cbmryearsl  去年同期抄表水量
      case cbmrface when '01' then '正常' when '02' then '表异常' when '03' then '零水量' else cbmrface end 抄表表况  ,-- 外包	YS_CB_MTREAD	抄表库【CBMR】	cbmrface	水表故障（哈尔滨需求：查表表态）(01正常/02表异常/03零水量)
      case cbmrdatasource 
        when '1' then '手工' when '5' then '抄表器' when '9' then '手机抄表' 
        when 'K' then '故障换表' when 'L' then '周期换表' when 'Z' then '追量' when 'I' then '智能表接口'
        when '6' then '视频直读' when '7' then '集抄'
        else cbmrdatasource
      end 抄表来源  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrdatasource  抄表结果来源(1-手工,5-抄表器,9-手机抄表,k-故障换表,l-周期换表,z-追量  i-智能表接口)(新加：6-视频直读，7-集抄)
      book_no 表册   ,--  ys_cb_mtread  抄表库【cbmr】 book_no 表册
      cbmrrper 抄表员 ,-- ys_cb_mtread  抄表库【cbmr】 cbmrrper  抄表员
      cbmrmemo 抄表备注  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrmemo  抄表备注
      cbmrinputper 入账人员  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrinputper  入账人员
      cbmrifrec 已计费 ,-- ys_cb_mtread  抄表库【cbmr】 cbmrifrec 已计费(y-是 n-否)
      cbmrrecdate 计费日期  -- ys_cb_mtread  抄表库【cbmr】 cbmrrecdate 计费日期
    from ys_cb_mtread
    where yhid=p_yhid
    union
    select 
      yhid 客户代码  ,-- ys_cb_mtread  抄表库【cbmr】 yhid  用户编号
      cbmrmonth 抄表月份  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrmonth 抄表月份
      cbmrrdate 抄表日期  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrrdate 抄表日期
      cbmrscode 起码  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrscode 上期抄见
      cbmrecode 止码  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrecode 本期抄见
      cbmrsl 抄表水量  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrsl  本期水量
      cbmrrecsl 计费水量  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrrecsl 应收水量
      cbmrcarrysl 校验水量  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrcarrysl 校验水量
      cbmrchkflag 已复核 ,-- ys_cb_mtread  抄表库【cbmr】 cbmrchkflag 复核标志(y-是 n-否)
      cbmrifhalt 是否停算  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrifhalt  系统停算(y-是 n-否)
      cbmrlastsl 上次水量  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrlastsl  上次抄表水量
      cbmrthreesl 前三次抄表水量 ,-- ys_cb_mtread  抄表库【cbmr】 cbmrthreesl 前三月抄表水量
      cbmryearsl 去年同期抄表水量  ,-- ys_cb_mtread  抄表库【cbmr】 cbmryearsl  去年同期抄表水量
      case cbmrface when '01' then '正常' when '02' then '表异常' when '03' then '零水量' else cbmrface end 抄表表况  ,-- 外包	YS_CB_MTREAD	抄表库【CBMR】	cbmrface	水表故障（哈尔滨需求：查表表态）(01正常/02表异常/03零水量)
      case cbmrdatasource 
        when '1' then '手工' when '5' then '抄表器' when '9' then '手机抄表' 
        when 'K' then '故障换表' when 'L' then '周期换表' when 'Z' then '追量' when 'I' then '智能表接口'
        when '6' then '视频直读' when '7' then '集抄'
        else cbmrdatasource
      end 抄表来源  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrdatasource  抄表结果来源(1-手工,5-抄表器,9-手机抄表,k-故障换表,l-周期换表,z-追量  i-智能表接口)(新加：6-视频直读，7-集抄)
      book_no 表册   ,--  ys_cb_mtread  抄表库【cbmr】 book_no 表册
      cbmrrper 抄表员 ,-- ys_cb_mtread  抄表库【cbmr】 cbmrrper  抄表员
      cbmrmemo 抄表备注  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrmemo  抄表备注
      cbmrinputper 入账人员  ,-- ys_cb_mtread  抄表库【cbmr】 cbmrinputper  入账人员
      cbmrifrec 已计费 ,-- ys_cb_mtread  抄表库【cbmr】 cbmrifrec 已计费(y-是 n-否)
      cbmrrecdate 计费日期  -- ys_cb_mtread  抄表库【cbmr】 cbmrrecdate 计费日期
    from ys_cb_mtreadhis
    where yhid=p_yhid
    ;
  end find_gtjf_cbjl;
end;
/

