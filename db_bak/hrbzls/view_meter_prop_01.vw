CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_METER_PROP_01 AS
SELECT /*+  index(b PK_BFID)  */
 A.MISAFID AS METER_AREA, --水表区域
 A.MICPER AS CSY, --抄收员
 nvl(B.BFRPER, '无') AS CBY, --抄表员
 a.mismfid AS OFAGENT, --营业所
 nvl(B.Bfid, '无') AS AREA, --表册区域
 MICHARGETYPE AS CHARGETYPE, --收费方式
 A.MIBFID AS BFID, --表册
 A.MIPFID AS WATERTYPE, --用水类别
 C.cicode AS custid, --用户编号
 CINAME NAME,--用户名

 C.CIADR AS address, --地址
 MIID as meterno,--水表编号
 BFRCYC,--抄表周期
 bfday,--抄表天数
 bfnrmonth,--下次抄表月份
 (case
   when bfrcyc = 1 then
    'S'
   else
    decode(mod(to_number(substr(bfnrmonth, 6, 2)), 2), 0, 'S', 'D')
 end) mrmonthtype, --抄表单双月
 DECODE(MIPRIFLAG, 'Y', mipriid, micode) ccode, --主表号合收表为一户
 a."MICID",--用户编号
 a."MIID",--水表编号
 a."MIADR",--表地址
 a."MISAFID",--区域
 a."MICODE",--客户代码
 a."MISMFID",--营销公司
 a."MIPRMON",--上期抄表月份
 a."MIRMON",--本期抄表月份
 a."MIBFID",--表册
 a."MIRORDER",--抄表次序
 a."MIPID",--上级水表编号
 a."MICLASS",--水表级次
 a."MIFLAG",--末级标志
 a."MIRTID",--抄表方式
 a."MIIFMP",--混合用水标志
 a."MIIFSP",--例外单价标志
 a."MISTID",--行业分类
 a."MIPFID",--价格分类
 a."MISTATUS",--有效状态
 a."MISTATUSDATE",--状态日期
 a."MISTATUSTRANS",--状态表务
 a."MIFACE",--水表故障
 a."MIRPID",--计件类型
 a."MISIDE",--表位
 a."MIPOSITION",--水表接水地址
 a."MIINSCODE",--新装起度
 a."MIINSDATE",--装表日期
 a."MIINSPER",--安装人
 a."MIREINSCODE",--换表起度
 a."MIREINSDATE",--换表日期
 a."MIREINSPER",--换表人
 a."MITYPE",--类型
 a."MIRCODE",--本期读数
 a."MIRECDATE",--本期抄见日期
 a."MIRECSL",--本期抄见水量
 a."MIIFCHARGE",--是否计费
 a."MIIFSL",--是否计量
 a."MIIFCHK",--是否考核表
 a."MIIFWATCH",--是否节水
 a."MIICNO",--ic卡号
 a."MIMEMO",--备注信息
 a."MIPRIID",--合收表主表号
 a."MIPRIFLAG",--合收表标志
 a."MIUSENUM",--户籍人数
 a."MICHARGETYPE",--收费方式
 a."MISAVING",--预存款余额
 a."MILB",--水表类别
 a."MINEWFLAG",--新表标志
 a."MICPER",--收费员
 a."MIIFTAX",--是否税票
 a."MITAXNO",--税号
 a."MIUNINSCODE",--拆表止度
 a."MIUNINSDATE",--拆表日期
 a."MIUNINSPER",--拆表人
 a."MIFACE2",--抄见故障
 a."MIFACE3",--非常计量
 a."MIFACE4",--表井设施说明
 a."MIRCODECHAR",--本期读数
 a."MIIFCKF",--垃圾费户数
 a."MIGPS",--是否合票
 a."MIQFH",--铅封号
 a."MIBOX",--消防水价（增值税水价，襄阳需求）
 a."MIJFKROW",--消防底度
 a."MINAME",--票据名称
 a."MINAME2",--招牌名称(小区名，襄阳需求）
 a."MISEQNO",--户号（初始化时册号+序号）
 a."MINEWDATE",--立户日期
 a."MIUIID",--合收单位编号
 a."MICOMMUNITY",--远传表小区号
 a."MIREMOTENO",--远传表号|采集机
 a."MIREMOTEHUBNO",--远传表hub号|端口
 a."MIEMAIL",--电子邮件 (借用暂存水账标识号clt_no)
 a."MIEMAILFLAG",--发账是否发邮件
 a."MICOLUMN1",--备用字段1(低保减免水量)
 a."MICOLUMN2",--备用字段2(低保用户标志)
 a."MICOLUMN3",--备用字段3(低保截止月份)
 a."MICOLUMN4",--用户性质(gq 公企 sm收免 tk 特困 gd 定量 pt 普通)
 a."MIPAYMENTID",--最近一次实收流水
 a."MICOLUMN5",--备用字段5(用水额度告警)
 --a.micolumn10 ,--备用字段10(是否签订供用水合同)
 ma."MAMID",--水表资料号
 ma."MANO",--委托授权号
 ma."MANONAME",--签约户名
 ma."MABANKID",--开户行（代托）
 ma."MAACCOUNTNO",--开户帐号（代托）
 ma."MAACCOUNTNAME",--开户名（代托）
 ma."MATSBANKID",--接收行号（托）
 ma."MATSBANKNAME",--凭证银行（托）
 ma."MAIFXEZF",--小额支付（托）
 ma."MAREGDATE",--签约日期
 ma."MAMICODE"--资料号
  FROM METERINFO A, CUSTINFO C, meteraccount ma, BOOKFRAME B
 WHERE A.MIBFID = B.BFID(+)
   AND C.ciid = A.micid
   AND a.miid = ma.mamid
;

