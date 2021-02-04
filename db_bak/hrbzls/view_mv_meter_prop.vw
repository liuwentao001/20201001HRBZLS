CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_MV_METER_PROP AS
SELECT /*+  INDEX(B PK_BFID)  */
      A.ROWID AROWID,
       C.ROWID CROWID,
       B.ROWID BROWID,
       A.MISAFID AS METER_AREA,                                         --水表区域
       A.MICPER AS CSY,                                                  --抄收员
       NVL (B.BFRPER, '无') AS CBY,                                     --抄表员
       A.MISMFID AS OFAGENT,                                             --营业所
       SUBSTR (B.BFID, 1, 5) AS AREA,                                   --表册区域
       MICHARGETYPE AS CHARGETYPE,                           --收费方式（M：走收，X：坐收）
       A.MIBFID AS BFID,                                                  --表册
       A.MIPFID AS WATERTYPE,                                           --用水类别
       C.CICODE AS CUSTID,                                              --用户编号
       C.CINAME AS NAME,                                                 --用户名
       MIID AS METERNO,                                                 --水表编号
       A.MIADR,                                                          --表地址
       BFRCYC,                                                          --抄表周期
       BFDAY,                                                           --抄表天数
       BFNRMONTH,                                                     --下次抄表月份
       (CASE
           WHEN BFRCYC = 1
           THEN
              'S'
           ELSE
              DECODE (MOD (TO_NUMBER (SUBSTR (BFNRMONTH, 6, 2)), 2),
                      0, 'S',
                      'D')
        END)
          MRMONTHTYPE,                                                 --抄表单双月
       A.MIPRIFLAG,                                                    --合收表标志
       DECODE (MIPRIFLAG, 'Y', MIPRIID, MICODE) CCODE,             --主表号合收表为一户
       A.MIINSDATE,                                                     --装表日期
       A.MIBFID,                                                          --表册
       A.MISTATUS,                                                      --有效状态
       A.MIIFCHK,                                                      --是否考核表
       A.MILB,                                                          --水表类别
       A.MIIFCKF AS HOUSEHOLDS,                    --户数（迁移时普通表、合收主表有值，合收子表值为空）
       A.MIUSENUM                                --户籍人数（迁移时普通表、合收主表有值，合收子表值为空）
  FROM METERINFO A,
       CUSTINFO C,
       BOOKFRAME B
 WHERE A.MIBFID = B.BFID AND C.CIID = A.MICID
;

