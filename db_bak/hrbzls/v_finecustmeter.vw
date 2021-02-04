CREATE OR REPLACE FORCE VIEW HRBZLS.V_FINECUSTMETER AS
SELECT  MIADR           ,    --表地址
        MISAFID         ,    --区域
        BFSAFID         ,    --区域1
        fgetzhprice(MICODE)     zhsj ,
        MICODE          ,    --水表手工编号
        MICID           ,    --用户编号
        MISMFID         ,    --营销公司
        MIPRMON         ,    --上期抄表月份
        MIRMON          ,    --本期抄表月份
        MIBFID          ,    --表册
        MIRORDER        ,    --抄表次序
        MIPID           ,    --上级水表编号
        MICLASS         ,    --水表级次
        MIFLAG          ,    --末级标志
        MIRTID          ,    --抄表方式
        MIIFMP          ,    --混合用水标志
        MIIFSP          ,    --例外单价标志
        MISTID          ,    --行业分类
       fpriceframejcbm(MIPFID,1)  priceframe01,      ---用水大类
        fpriceframejcbm(MIPFID,2)  priceframe02,    ---用水中类
       fpriceframejcbm(MIPFID,3)  priceframe03,      ---用水小类
      miuiid,  -- MIPFID          ,    --价格分类
        MISTATUS        ,    --有效状态
        MISTATUSDATE    ,    --状态日期
        MISTATUSTRANS   ,    --状态表务
        MIFACE          ,    --水表故障
        MIRPID          ,    --计件类型
        MISIDE          ,    --表位
        MIPOSITION      ,    --水表接水地址
        MIINSCODE       ,    --新装起度
        MIINSDATE       ,    --装表日期
        MIINSPER        ,    --安装人
        MIREINSCODE     ,    --换表起度
        MIREINSDATE     ,    --换表日期
        MIREINSPER      ,    --换表人
        MITYPE          ,    --类型
        MIRCODE         ,    --本期读数
        MIRECDATE       ,    --本期抄见日期
        MIRECSL         ,    --本期抄见水量
        MIIFCHARGE      ,    --是否计费
        MIIFSL          ,    --是否计量
        MIIFCHK         ,    --是否考核表
        MIIFWATCH       ,    --是否节水
        MIICNO          ,    --IC卡号
        MIMEMO          ,    --备注信息
        MIPRIID         ,    --合收表主表号
        MIPRIFLAG       ,    --合收表标志
        MIUSENUM        ,    --户籍人数
        MICHARGETYPE    ,    --收费方式
        MISAVING        ,    --预存款余额
        MILB            ,    --水表类别
        MINEWFLAG       ,    --新表标志
        MICPER          ,    --收费员
        MIIFTAX         ,    --是否税票
        MITAXNO         ,    --税号
        MIUNINSCODE     ,    --拆表止度
        MIUNINSDATE     ,    --拆表日期
        MIUNINSPER      ,    --拆表人
        MIFACE2         ,    --抄见故障
        MIFACE3         ,    --非常计量
        MIFACE4         ,    --表井设施说明
        MIRCODECHAR     ,    --本期读数
        MIIFCKF         ,    --是否磁控阀
        MIGPS           ,    --GPS地址
        MIQFH           ,    --铅封号
        MIBOX           ,    --表箱规格
        MIJFKROW        ,    --缴费卡打印行数
        MINAME          ,    --票据名称
        MINAME2         ,    --招牌名称
        MISEQNO         ,    --户号（初始化时册号+序号）
        MINEWDATE       ,    --立户日期
        ----
        CICONID         ,         --报装合同编号
        CISMFID         ,         --营销公司
        CICLASS         ,         --用户级次
        CIFLAG          ,         --末级标志
        CINAME          ,         --产权名
        CINAME2         ,         --曾用名
        CIADR           ,         --用户地址
        CISTATUS        ,         --用户状态
        CISTATUSDATE    ,         --状态日期
        CISTATUSTRANS   ,         --状态表务
        CINEWDATE       ,         --立户日期
        CIIDENTITYLB    ,         --证件类型
        CIIDENTITYNO    ,         --证件号码
        CIMTEL          ,         --移动电话
        CITEL1          ,         --固定电话1
        CITEL2          ,         --固定电话2
        CITEL3          ,         --固定电话3
        CICONNECTPER    ,         --联系人
        CICONNECTTEL    ,         --联系电话
        CIIFINV         ,         --是否普票
        CIIFSMS         ,         --是否提供短信服务
        CIIFZN          ,         --是否滞纳金
        CIPROJNO        ,         --工程编号
        CIFILENO        ,         --档案号
        CIMEMO          ,         --备注信息
        CIDEPTID        ,         --立户部门
        ----
        MDNO             ,  --表身码
        MDCALIBER        ,  --表口径                Y
        MDBRAND          ,  --表厂家
        MDMODEL          ,  --表型号
        MDSTATUS         ,  --表状态
        MDSTATUSDATE     ,  --表状态发生时间
        MDCYCCHKDATE     ,  --周检起算日
        MDSTOCKDATE      ,  --新购入库日期
        MDSTORE          ,  --库存位置
        ----
        MANO            ,   --委托授权号
        MANONAME        ,   --签约户名
        MABANKID        ,   --开户行（代托）
        MAACCOUNTNO     ,   --开户帐号（代托）
        MAACCOUNTNAME   ,   --开户名（代托）
        MATSBANKID      ,   --接收行号（托）
        MATSBANKNAME    ,   --凭证银行（托）
        MAIFXEZF        ,   --小额支付（托）
        MAREGDATE       ,   --签约日期
        bfname,
        bfrper,
        case when mod(substr(bfnrmonth,4,2), bfrcyc) = 0 then '双' else '单' end  cbzq
   FROM METERINFO
        LEFT JOIN BOOKFRAME ON MIBFID=BFID AND MISMFID=BFSMFID
        LEFT JOIN METERACCOUNT ON MAMID=MIID
        LEFT JOIN PRICEFRAME ON SUBSTR(MIPFID,1,2)=PFID,
        CUSTINFO,METERDOC
  WHERE MIID = MDMID AND CIID = MICID
;
comment on column HRBZLS.V_FINECUSTMETER.MIADR is '表地址';
comment on column HRBZLS.V_FINECUSTMETER.MISAFID is '区域';
comment on column HRBZLS.V_FINECUSTMETER.MICODE is '客户代码';
comment on column HRBZLS.V_FINECUSTMETER.MICID is '用户编号';
comment on column HRBZLS.V_FINECUSTMETER.MISMFID is '营销公司';
comment on column HRBZLS.V_FINECUSTMETER.MIPRMON is '上期抄表月份';
comment on column HRBZLS.V_FINECUSTMETER.MIRMON is '本期抄表月份';
comment on column HRBZLS.V_FINECUSTMETER.MIBFID is '表册';
comment on column HRBZLS.V_FINECUSTMETER.MIRORDER is '抄表次序';
comment on column HRBZLS.V_FINECUSTMETER.MIPID is '上级水表编号';
comment on column HRBZLS.V_FINECUSTMETER.MICLASS is '水表级次';
comment on column HRBZLS.V_FINECUSTMETER.MIFLAG is '末级标志';
comment on column HRBZLS.V_FINECUSTMETER.MIRTID is '抄表方式';
comment on column HRBZLS.V_FINECUSTMETER.MIIFMP is '混合用水标志';
comment on column HRBZLS.V_FINECUSTMETER.MIIFSP is '例外单价标志';
comment on column HRBZLS.V_FINECUSTMETER.MISTID is '行业分类';
comment on column HRBZLS.V_FINECUSTMETER.MIUIID is '合收单位编号';
comment on column HRBZLS.V_FINECUSTMETER.MISTATUS is '有效状态';
comment on column HRBZLS.V_FINECUSTMETER.MISTATUSDATE is '状态日期';
comment on column HRBZLS.V_FINECUSTMETER.MISTATUSTRANS is '状态表务';
comment on column HRBZLS.V_FINECUSTMETER.MIFACE is '水表故障';
comment on column HRBZLS.V_FINECUSTMETER.MIRPID is '计件类型';
comment on column HRBZLS.V_FINECUSTMETER.MISIDE is '表位';
comment on column HRBZLS.V_FINECUSTMETER.MIPOSITION is '水表接水地址';
comment on column HRBZLS.V_FINECUSTMETER.MIINSCODE is '新装起度';
comment on column HRBZLS.V_FINECUSTMETER.MIINSDATE is '装表日期';
comment on column HRBZLS.V_FINECUSTMETER.MIINSPER is '安装人';
comment on column HRBZLS.V_FINECUSTMETER.MIREINSCODE is '换表起度';
comment on column HRBZLS.V_FINECUSTMETER.MIREINSDATE is '换表日期';
comment on column HRBZLS.V_FINECUSTMETER.MIREINSPER is '换表人';
comment on column HRBZLS.V_FINECUSTMETER.MITYPE is '类型';
comment on column HRBZLS.V_FINECUSTMETER.MIRCODE is '本期读数';
comment on column HRBZLS.V_FINECUSTMETER.MIRECDATE is '本期抄见日期';
comment on column HRBZLS.V_FINECUSTMETER.MIRECSL is '本期抄见水量';
comment on column HRBZLS.V_FINECUSTMETER.MIIFCHARGE is '是否计费';
comment on column HRBZLS.V_FINECUSTMETER.MIIFSL is '是否计量';
comment on column HRBZLS.V_FINECUSTMETER.MIIFCHK is '是否考核表';
comment on column HRBZLS.V_FINECUSTMETER.MIIFWATCH is '是否节水';
comment on column HRBZLS.V_FINECUSTMETER.MIICNO is 'IC卡号';
comment on column HRBZLS.V_FINECUSTMETER.MIMEMO is '备注信息';
comment on column HRBZLS.V_FINECUSTMETER.MIPRIID is '合收表主表号';
comment on column HRBZLS.V_FINECUSTMETER.MIPRIFLAG is '合收表标志';
comment on column HRBZLS.V_FINECUSTMETER.MIUSENUM is '户籍人数';
comment on column HRBZLS.V_FINECUSTMETER.MICHARGETYPE is '收费方式';
comment on column HRBZLS.V_FINECUSTMETER.MISAVING is '预存款余额';
comment on column HRBZLS.V_FINECUSTMETER.MILB is '水表类别';
comment on column HRBZLS.V_FINECUSTMETER.MINEWFLAG is '新表标志';
comment on column HRBZLS.V_FINECUSTMETER.MICPER is '收费员';
comment on column HRBZLS.V_FINECUSTMETER.MIIFTAX is '是否税票';
comment on column HRBZLS.V_FINECUSTMETER.MITAXNO is '税号';
comment on column HRBZLS.V_FINECUSTMETER.MIUNINSCODE is '拆表止度';
comment on column HRBZLS.V_FINECUSTMETER.MIUNINSDATE is '拆表日期';
comment on column HRBZLS.V_FINECUSTMETER.MIUNINSPER is '拆表人';
comment on column HRBZLS.V_FINECUSTMETER.MIFACE2 is '抄见故障';
comment on column HRBZLS.V_FINECUSTMETER.MIFACE3 is '非常计量';
comment on column HRBZLS.V_FINECUSTMETER.MIFACE4 is '表井设施说明';
comment on column HRBZLS.V_FINECUSTMETER.MIRCODECHAR is '本期读数';
comment on column HRBZLS.V_FINECUSTMETER.MIIFCKF is '垃圾费户数';
comment on column HRBZLS.V_FINECUSTMETER.MIGPS is '是否合票';
comment on column HRBZLS.V_FINECUSTMETER.MIQFH is '铅封号';
comment on column HRBZLS.V_FINECUSTMETER.MIBOX is '消防水价（增值税水价，襄阳需求）';
comment on column HRBZLS.V_FINECUSTMETER.MIJFKROW is '消防底度';
comment on column HRBZLS.V_FINECUSTMETER.MINAME is '票据名称';
comment on column HRBZLS.V_FINECUSTMETER.MINAME2 is '招牌名称(小区名，襄阳需求）';
comment on column HRBZLS.V_FINECUSTMETER.MISEQNO is '户号（初始化时册号+序号）';
comment on column HRBZLS.V_FINECUSTMETER.MINEWDATE is '立户日期';
comment on column HRBZLS.V_FINECUSTMETER.CICONID is '供水牌号';
comment on column HRBZLS.V_FINECUSTMETER.CISMFID is '营销公司';
comment on column HRBZLS.V_FINECUSTMETER.CICLASS is '用户级次';
comment on column HRBZLS.V_FINECUSTMETER.CIFLAG is '末级标志';
comment on column HRBZLS.V_FINECUSTMETER.CINAME is '产权名';
comment on column HRBZLS.V_FINECUSTMETER.CINAME2 is '曾用名';
comment on column HRBZLS.V_FINECUSTMETER.CIADR is '用户地址';
comment on column HRBZLS.V_FINECUSTMETER.CISTATUS is '用户状态';
comment on column HRBZLS.V_FINECUSTMETER.CISTATUSDATE is '状态日期';
comment on column HRBZLS.V_FINECUSTMETER.CISTATUSTRANS is '状态表务';
comment on column HRBZLS.V_FINECUSTMETER.CINEWDATE is '立户日期';
comment on column HRBZLS.V_FINECUSTMETER.CIIDENTITYLB is '证件类型';
comment on column HRBZLS.V_FINECUSTMETER.CIIDENTITYNO is '证件号码';
comment on column HRBZLS.V_FINECUSTMETER.CIMTEL is '移动电话';
comment on column HRBZLS.V_FINECUSTMETER.CITEL1 is '固定电话1';
comment on column HRBZLS.V_FINECUSTMETER.CITEL2 is '固定电话2';
comment on column HRBZLS.V_FINECUSTMETER.CITEL3 is '固定电话3';
comment on column HRBZLS.V_FINECUSTMETER.CICONNECTPER is '联系人';
comment on column HRBZLS.V_FINECUSTMETER.CICONNECTTEL is '联系电话';
comment on column HRBZLS.V_FINECUSTMETER.CIIFINV is '是否普票';
comment on column HRBZLS.V_FINECUSTMETER.CIIFSMS is '是否提供短信服务';
comment on column HRBZLS.V_FINECUSTMETER.CIIFZN is '是否滞纳金';
comment on column HRBZLS.V_FINECUSTMETER.CIPROJNO is '工程编号';
comment on column HRBZLS.V_FINECUSTMETER.CIFILENO is '档案号';
comment on column HRBZLS.V_FINECUSTMETER.CIMEMO is '备注信息';
comment on column HRBZLS.V_FINECUSTMETER.CIDEPTID is '立户部门';

