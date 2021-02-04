CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_METERPROP2 AS
SELECT fgetsysmanaframe(a.mismfid) AS 营业所, --营业所
       a.micid AS 用户编号, --用户编号
       CINAME 用户名, --用户名
       C.CIADR AS 地址, --地址
       c.CIMTEL 移动电话, --移动电话
       c.CITEL1 住宅电话, --住宅电话
       a."MISAVING" 预存款余额, --预存款余额
       fgetsysreadtype(a."MIRTID") 抄表方式, --抄表方式
       case when a.MICHARGETYPE='X' THEN '坐收' else '走收'end  收费方式,
       nvl(B.BFRPER, '无') AS 抄表员, --抄表员
       A.MIBFID AS 表册, --表册
       d.mdno 表身码, --表身码
       d.barcode 条形码, --条形码
       (case when a."MILB" = 'D' then '总表' else '户表' end） 水表类别, --水表类别
       fgetpriceframe(A.MIPFID) AS 用水类别, --用水类别
       fgetsysmeterstatus(a.mistatus) 水表状态, --水表状态
       fgetsyscharlist('表位', a."MISIDE") 表位, --表位
       (case a.miface when '01' then '正常' when '02' then '表异常' when '03' then '零水量' else '' end） 表况, a."MINEWDATE" 报装日期, --立户日期
       a."MIINSDATE" 装表日期, --装表日期
       a."MIREINSDATE" 换表日期, --换表日期
       a."MIRCODE" 当前表针, --当前表针
       a."MIRECDATE" 上次抄表日期, --上次抄表日期
       a."MIRECSL" 上期水量, --上期水量
       d.MDCALIBER 口径, --口径
       d.dqsfh 塑封号, a."MIPRIID" 合收表主表号, --合收表主表号
       a."MIPRIFLAG" 合收表标志, --合收表标志
       a."MIIFTAX" 是否税票, --是否税票
       a."MITAXNO" 税号, --税号
       A."MIYL4" 密码,
       a."MIREMOTEHUBNO" 老户号
       FROM METERINFO A, CUSTINFO C, BOOKFRAME B, meterdoc d
       WHERE A.MIBFID = B.BFID(+)
       and a.micid = d.mdmid
       AND C.ciid = A.micid
;

