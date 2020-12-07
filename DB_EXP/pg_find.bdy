﻿create or replace package body pg_find is

  /*
  功能：前台页面综合查询
  参数说明
  p_yhid          用户id
  p_bookno        表册编码
  p_sbid          水表编码
  p_manageno      营销公司编码
  out             输出结果集
  */
  procedure findcustmetercomplexdoc(p_yhid in varchar2,p_bookno in varchar2,p_sbid in varchar2,p_manageno in varchar2 ,out_tab out sys_refcursor) is
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
      sb.sbname2 招牌名称,--(小区名，襄阳需求）
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
  end findcustmetercomplexdoc;

  procedure findpaymentbase(p_yhid in varchar2,p_yhname in varchar2,p_sbposition in varchar2,p_yhmtel in varchar2 ,out_tab out sys_refcursor) is
    begin
    open out_tab for select
      t.yhname 用户名称,
      t.yhid 客户代码,
      sb.sbsaving 用户余额,
      t.yhconnecttel 联系电话,
      t.yhmtel 移动电话,
      sb.sbposition 用水地址,--ys_yh_sbinfo  户表信息【sb】  sbposition  水表接水地址
      t.yhstatus 用户状态,--yhstatus 用户状态【syscuststatus】(1正常/7销户/2预立户)
      sb.book_no 表册,--ys_yh_sbinfo 户表信息【sb】  book_no 表册(bookframe)
      sb.price_no 价格分类,--  ys_yh_sbinfo  户表信息【sb】  price_no  价格分类(priceframe)
      sb.sbchargetype 收费方式,--  ys_yh_sbinfo  户表信息【sb】  sbchargetype  收费方式(x坐收m走收)
      t.manage_no 营销公司,--  ys_yh_custinfo  用户信息表【yh】 manage_no 营销公司
      t.yhifinv 增值税发票,--外包 ys_yh_custinfo  用户信息表【yh】 yhifinv 是否普票（哈尔滨：借用做是否已打印增值税收据，reclist取值，置空）
      sb.sbpriflag 合收标志,--外包 ys_yh_sbinfo  户表信息【sb】  sbpriflag 合收表标志(y-合收表标志,n-非合收主表 )
      sb.sbpriflag 合收主表,--外包 ys_yh_sbinfo  户表信息【sb】  sbpriid 合收表主表号
      sb.sbifmp 混合用水,--外包  ys_yh_sbinfo  户表信息【sb】  sbifmp  混合用水标志(y-是,n-否 )
      ar.arznj+ar.arje 合计水费,
      sb.sbsaving 预存余额,--外包  ys_yh_sbinfo  户表信息【sb】  sbsaving  预存款余额
      ar.arznj 违约金,--外包  ys_zw_arlist  应收总帐明细【ar】  arznj 违约金
      ar.arje 本次应缴--外包 ys_zw_arlist  应收总帐明细【ar】  arje  应收金额
    from 
      ys_yh_custinfo t,
      ys_yh_sbinfo sb,
      ys_zw_arlist ar
    where
      t.yhid = sb.yhid
      and sb.hire_code = t.hire_code
      and t.yhid = ar.yhid
      and sb.sbid = ar.sbid
      and (t.yhid = p_yhid or p_yhid is null)
      and (t.yhname = p_yhname or p_yhname is null)
      and (sb.sbposition like '%'||p_sbposition||'%' or p_sbposition is null)
      and (t.yhmtel = p_yhmtel or p_yhmtel is null)
      ;
  end findpaymentbase;
end;
/
